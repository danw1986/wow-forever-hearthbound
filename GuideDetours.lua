local ADDON_NAME, ns = ...

-- Guide detours: the levelling guide follows a fixed route, but these let it
-- adapt to where you are and what you're playing:
--
--   nearby  quests in your log you can get on with here - an objective whose
--           mobs, items or places are close, or a finished quest whose hand-in
--           is close - nearest first
--   class   your class's quests from QuestieDB (Forever's new ones included,
--           like the Undead paladin's): the ones you can pick up now, and the
--           ones in your log
--
-- Each is { kind = "progress"|"turnin"|"pickup", quest = id, title, label,
-- spot = { mapID, x, y, continent, wx, wy }, yards, class = true? }.
-- Guide.lua shows them and points the arrow at them.

local format = string.format
local Safe = ns.Safe

local RECALC_SECONDS = 2
local SCAN_PER_TICK = 200
local SKIP_SECONDS = 15 * 60

local function Get(datatype, id, field)
    return ns.QuestieGet and ns.QuestieGet(datatype, id, field)
end

---------------------------------------------------------------------------
-- Your class's quests, read from QuestieDB once (a slice per frame)
---------------------------------------------------------------------------
local classQuests          -- list of quest IDs for your class
local classScanning = false
local classReady = {}      -- callbacks for when the list is read

local function Bits(n)
    local count = 0
    while n > 0 do
        if n % 2 == 1 then count = count + 1 end
        n = math.floor(n / 2)
    end
    return count
end

local function ScanClassQuests()
    if classQuests or classScanning then return end
    local l = rawget(_G, "LibQuestieDB")
    if not (l and l.Quest and l.Quest.GetAllIds and l.Quest.GetAll) then return end
    local ok, ids = pcall(l.Quest.GetAllIds)
    if not ok or type(ids) ~= "table" then return end
    local classId = select(3, UnitClass("player"))
    if type(classId) ~= "number" then return end
    local myBit = 2 ^ (classId - 1)
    classScanning = true
    local found, i = {}, 1
    local FIELDS = { "requiredClasses" }
    local function Step()
        local stop = math.min(#ids, i + SCAN_PER_TICK - 1)
        for k = i, stop do
            local okRow, v = pcall(l.Quest.GetAll, ids[k], FIELDS)
            local mask = okRow and v and v[1]
            -- a class quest: names your class, and only a class or two (not "everyone")
            if type(mask) == "number" and mask > 0 and math.floor(mask / myBit) % 2 == 1 and Bits(mask) <= 2 then
                found[#found + 1] = ids[k]
            end
        end
        i = stop + 1
        if i <= #ids then
            C_Timer.After(0, function() pcall(Step) end)
        else
            classQuests = found
            classScanning = false
            for _, fn in ipairs(classReady) do pcall(fn, found) end
        end
    end
    pcall(Step)
end

---------------------------------------------------------------------------
-- Where things are
---------------------------------------------------------------------------
local function InLog(id)
    for _, q in ipairs(ns.openQuests or {}) do
        if q.id == id then return q end
    end
end

local function SpotFor(mapID, x, y)
    if not (mapID and x and y and ns.WorldPos) then return nil end
    local continent, wx, wy = ns.WorldPos(mapID, x, y)
    return continent and { mapID = mapID, x = x, y = y, continent = continent, wx = wx, wy = wy } or nil
end

-- with "Skip quests too low for XP" on, grey quests aren't offered
local function Grey(level)
    if not (ns.db.guideSkipGrey and type(level) == "number" and level > 0 and ns.QuestDifficulty) then return false end
    return ns.QuestDifficulty(level, UnitLevel("player")) == "trivial"
end

local function Distance(spot, continent, wx, wy)
    if not (spot and continent and spot.continent == continent) then return nil end
    return math.sqrt((spot.wx - wx) ^ 2 + (spot.wy - wy) ^ 2)
end

-- where a quest is handed in
local finishSpots = {}
local function FinishSpot(q)
    local cached = finishSpots[q.id]
    if cached ~= nil then return cached or nil end
    local finish = ns.QuestieFinish and ns.QuestieFinish(q.title, q.id)
    local spot = finish and SpotFor(finish.mapID, finish.x, finish.y)
    if finish then finishSpots[q.id] = spot or false end
    return spot, finish and finish.giver
end

-- where a quest is picked up: its giver's nearest spawn
local function StartSpot(id, continent, wx, wy)
    local giver = ns.QuestieGiverById and ns.QuestieGiverById(id)
    if giver and giver.mapID then
        local spot = SpotFor(giver.mapID, giver.x, giver.y)
        if spot then return spot, giver.giver end
    end
    local startedBy = Get("Quest", id, "startedBy")
    if type(startedBy) ~= "table" then return nil end
    local spots, who = {}, nil
    for _, npcId in ipairs(type(startedBy[1]) == "table" and startedBy[1] or {}) do
        for _, s in ipairs(ns.QuestieSpawnSpots("Npc", npcId)) do spots[#spots + 1] = s end
        who = who or Get("Npc", npcId, "name")
    end
    for _, objectId in ipairs(type(startedBy[2]) == "table" and startedBy[2] or {}) do
        for _, s in ipairs(ns.QuestieSpawnSpots("Object", objectId)) do spots[#spots + 1] = s end
        who = who or Get("Object", objectId, "name")
    end
    local best = ns.NearestSpot(spots, continent, wx, wy) or spots[1]
    return best, who
end

---------------------------------------------------------------------------
-- Skipping: right-click a detour to leave it alone for a while
---------------------------------------------------------------------------
local skipped = {} -- key -> GetTime() it can come back

local function Key(d)
    return d.kind .. ":" .. tostring(d.quest) .. ":" .. tostring(d.label or "")
end

function ns.GuideSkipDetour(d)
    if d then skipped[Key(d)] = GetTime() + SKIP_SECONDS end
end

local function Skipped(d)
    local untilTime = skipped[Key(d)]
    return untilTime and GetTime() < untilTime
end

---------------------------------------------------------------------------
-- Working it out
---------------------------------------------------------------------------
local cache, cachedAt = { nearby = {}, class = {} }, 0

local function Compute()
    local nearby, class = {}, {}
    local continent, wx, wy
    if ns.PlayerWorldPos then continent, wx, wy = ns.PlayerWorldPos() end
    local radius = ns.db.guideAdaptYards or 300
    local classSet = {}
    for _, id in ipairs(classQuests or {}) do classSet[id] = true end

    -- objectives still to do, near you
    if ns.db.guideAdaptive and continent and ns.QuestObjectives then
        local best = {} -- one per quest and objective: its nearest spot
        for _, e in ipairs(ns.QuestObjectives()) do
            local progress = ns.ObjectiveProgress and ns.ObjectiveProgress(e)
            if not (progress and (progress.done or progress.ready)) and e.spots and #e.spots > 0 and not Grey(e.quest.level) then
                local spot, yards = ns.NearestSpot(e.spots, continent, wx, wy)
                if spot and yards and yards <= radius then
                    local d = { kind = "progress", quest = e.quest.id, title = e.quest.title, label = e.label,
                                objective = e.kind, progress = progress, spot = spot, yards = yards,
                                class = classSet[e.quest.id] }
                    local key = Key(d)
                    if not Skipped(d) and (not best[key] or yards < best[key].yards) then best[key] = d end
                end
            end
        end
        for _, d in pairs(best) do nearby[#nearby + 1] = d end
        -- finished quests to hand in, near you
        for _, q in ipairs(ns.openQuests or {}) do
            if q.complete and not Grey(q.level) then
                local spot, giver = FinishSpot(q)
                local yards = Distance(spot, continent, wx, wy)
                if yards and yards <= radius then
                    local d = { kind = "turnin", quest = q.id, title = q.title, label = giver, spot = spot, yards = yards,
                                class = classSet[q.id] }
                    if not Skipped(d) then nearby[#nearby + 1] = d end
                end
            end
        end
        table.sort(nearby, function(a, b)
            -- hand-ins first when they're as close: they're quick
            if a.kind ~= b.kind and math.abs(a.yards - b.yards) < 40 then return a.kind == "turnin" end
            return a.yards < b.yards
        end)
    end

    -- class quests: in your log, or ready to pick up
    if ns.db.guideClassQuests then
        for _, id in ipairs(classQuests or {}) do
            local q = InLog(id)
            local d
            if q and q.complete then
                local spot, giver = FinishSpot(q)
                d = { kind = "turnin", quest = id, title = q.title, label = giver, spot = spot }
            elseif q then
                -- its nearest unfinished objective, if QuestieDB knows where
                local bestSpot, bestYards, bestLabel
                for _, e in ipairs(ns.QuestObjectives and ns.QuestObjectives() or {}) do
                    if e.quest.id == id and e.spots then
                        local progress = ns.ObjectiveProgress and ns.ObjectiveProgress(e)
                        if not (progress and (progress.done or progress.ready)) then
                            local spot, yards = ns.NearestSpot(e.spots, continent, wx, wy)
                            if spot and (not bestYards or (yards or math.huge) < bestYards) then
                                bestSpot, bestYards, bestLabel = spot, yards or math.huge, e.label
                            end
                        end
                    end
                end
                d = { kind = "progress", quest = id, title = q.title, label = bestLabel, spot = bestSpot }
            elseif not (ns.QuestDone and ns.QuestDone(id)) and ns.QuestieIsDoable and ns.QuestieIsDoable(id) == true
                and (not ns.GuideClassQuestForYou or ns.GuideClassQuestForYou(id)) then
                local spot, giver = StartSpot(id, continent, wx, wy)
                d = { kind = "pickup", quest = id, title = Get("Quest", id, "name") or ("Quest " .. id), label = giver, spot = spot,
                      level = Get("Quest", id, "questLevel") }
            end
            local level = (q and q.level) or (d and d.level) or Get("Quest", id, "questLevel")
            if d and Grey(level) then d = nil end
            if d then
                d.class = true
                d.yards = Distance(d.spot, continent, wx, wy)
                if not Skipped(d) then class[#class + 1] = d end
            end
        end
        table.sort(class, function(a, b)
            -- the ones in your log, then the nearest
            local la, lb = a.kind ~= "pickup", b.kind ~= "pickup"
            if la ~= lb then return la end
            return (a.yards or math.huge) < (b.yards or math.huge)
        end)
    end
    return { nearby = nearby, class = class }
end

-- { nearby = {...}, class = {...} }, worked out at most every couple of seconds
function ns.GuideDetours(force)
    if force or GetTime() - cachedAt >= RECALC_SECONDS then
        cachedAt = GetTime()
        local ok, result = pcall(Compute)
        if ok then cache = result end
    end
    return cache
end

-- your class's quest IDs (nil until read), and a call when they are
function ns.GuideClassQuests() return classQuests end
function ns.OnGuideClassQuests(fn) classReady[#classReady + 1] = fn end

-- for the debug line: how many class quests were found
function ns.GuideClassQuestCount()
    return classQuests and #classQuests or nil
end

-- a one-line description: "Kill Bristleback Quilboar (4/10) - Lost in Battle"
function ns.GuideDetourText(d)
    if not d then return "" end
    local what
    if d.kind == "turnin" then
        what = "Hand in |cffffd200" .. d.title .. "|r" .. (d.label and (" to " .. d.label) or "")
    elseif d.kind == "pickup" then
        what = "Pick up |cffffd200" .. d.title .. "|r" .. (d.label and (" from " .. d.label) or "")
    else
        local verb = ({ kill = "Kill", loot = "Loot", object = "Use", explore = "Go to" })[d.objective or ""] or "Do"
        local p = d.progress
        local count = p and p.have and p.need and format(" (%d/%d)", p.have, p.need) or ""
        what = (d.label and (verb .. " " .. d.label .. count .. " - ") or "") .. "|cffffd200" .. d.title .. "|r"
    end
    return what
end

table.insert(ns.inits, function()
    -- read the class quests a little after login, and again on a level-up (nothing new
    -- is found then, but it's cheap insurance if the first read came too early)
    ns.On("PLAYER_LOGIN", function() C_Timer.After(12, ScanClassQuests) end)
    ns.On("QUEST_LOG_UPDATE", function() finishSpots = {} end)
end)
