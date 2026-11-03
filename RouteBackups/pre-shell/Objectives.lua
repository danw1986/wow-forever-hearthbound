local ADDON_NAME, ns = ...

-- Panel section "Objectives nearby": the closest things your quests still
-- need (mobs to kill, items to loot, objects to use, places to explore), with
-- how far away they are. Click one to mark it on the map.
--
-- Positions come from QuestieDB; progress (3/10) from your quest log.

local format = string.format

local MAX_SHOWN = 4
local RECALC_SECONDS = 3

local objectives      -- { { quest, kind, label, spots, npcs } }, rebuilt when the log changes
local ranked = {}     -- nearest first: { entry, spot, yards, progress }
local lastRank = 0
local itemSpots = {}  -- itemId -> spots of every mob / object that drops it

local function Get(datatype, id, field)
    return ns.QuestieGet and ns.QuestieGet(datatype, id, field)
end

local function Concat(into, list)
    for _, s in ipairs(list or {}) do into[#into + 1] = s end
end

local function ItemSpots(itemId)
    if itemSpots[itemId] then return itemSpots[itemId] end
    local spots = {}
    local npcs = Get("Item", itemId, "npcDrops")
    for _, npcId in ipairs(type(npcs) == "table" and npcs or {}) do Concat(spots, ns.QuestieSpawnSpots("Npc", npcId)) end
    local objects = Get("Item", itemId, "objectDrops")
    for _, objectId in ipairs(type(objects) == "table" and objects or {}) do Concat(spots, ns.QuestieSpawnSpots("Object", objectId)) end
    itemSpots[itemId] = spots
    return spots
end

local function Build()
    objectives = {}
    if not (ns.QuestieGet and ns.QuestieSpawnSpots) then return end
    for _, q in ipairs(ns.openQuests or {}) do
        if not q.complete then
            local o = Get("Quest", q.id, "objectives")
            -- npcs: the mobs involved (to kill, or that drop the item), for the targets window
            -- kept even without known spawns when the mobs are known: the targets
            -- window can still target them by name (the nearby list skips them)
            local function Add(kind, label, spots, npcs)
                if (spots and #spots > 0) or (npcs and #npcs > 0) then
                    objectives[#objectives + 1] = { quest = q, kind = kind, label = label or "?", spots = spots, npcs = npcs }
                end
            end
            if type(o) == "table" then
                for _, c in ipairs(type(o[1]) == "table" and o[1] or {}) do
                    local npcId = type(c) == "table" and c[1] or c
                    Add("kill", Get("Npc", npcId, "name"), ns.QuestieSpawnSpots("Npc", npcId), { npcId })
                end
                for _, c in ipairs(type(o[2]) == "table" and o[2] or {}) do
                    local objectId = type(c) == "table" and c[1] or c
                    local label = (type(c) == "table" and c[2]) or Get("Object", objectId, "name")
                    Add("object", label, ns.QuestieSpawnSpots("Object", objectId))
                end
                for _, c in ipairs(type(o[3]) == "table" and o[3] or {}) do
                    local itemId = type(c) == "table" and c[1] or c
                    local drops = Get("Item", itemId, "npcDrops")
                    Add("loot", Get("Item", itemId, "name"), ItemSpots(itemId), type(drops) == "table" and drops or nil)
                end
                for _, c in ipairs(type(o[5]) == "table" and o[5] or {}) do
                    if type(c) == "table" and type(c[1]) == "table" then
                        local spots = {}
                        for _, npcId in ipairs(c[1]) do Concat(spots, ns.QuestieSpawnSpots("Npc", npcId)) end
                        Add("kill", (c[2] and Get("Npc", c[2], "name")) or c[3], spots, c[1])
                    end
                end
            end
            -- "explore" objectives: a place to reach
            local trigger = Get("Quest", q.id, "triggerEnd")
            if type(trigger) == "table" and type(trigger[2]) == "table" and ns.SpotsFromSpawns then
                Add("explore", trigger[1], ns.SpotsFromSpawns(trigger[2]))
            end
        end
    end
end

-- live progress for an objective, matched by name within its quest
local function Progress(entry)
    if not ns.QuestNeeds then return nil end
    local needs, kills = ns.QuestNeeds()
    local list = entry.kind == "loot" and needs or (entry.kind == "kill" and kills) or nil
    for _, n in ipairs(list and list[entry.label:lower()] or {}) do
        if n.id == entry.quest.id then return n end
    end
end

-- For the targets window: what your quests still need, and their live progress
function ns.QuestObjectives()
    if not objectives then Build() end
    return objectives
end
ns.ObjectiveProgress = function(entry) return Progress(entry) end

local function Rank()
    lastRank = GetTime()
    wipe(ranked)
    if not objectives then Build() end
    local continent, wx, wy
    if ns.PlayerWorldPos then continent, wx, wy = ns.PlayerWorldPos() end
    if not continent then return end
    for _, entry in ipairs(objectives) do
        local progress = Progress(entry)
        if not (progress and progress.done) then
            local spot, yards = ns.NearestSpot(entry.spots, continent, wx, wy)
            if spot then ranked[#ranked + 1] = { entry = entry, spot = spot, yards = yards, progress = progress } end
        end
    end
    table.sort(ranked, function(a, b) return a.yards < b.yards end)
end

local function YardsText(yards)
    if yards < 1000 then return format("%d yd", math.floor(yards / 10 + 0.5) * 10) end
    return format("%.1fk yd", yards / 1000)
end

local VERB = { kill = "Kill", loot = "Loot", object = "Use", explore = "Go to" }

ns.AddSection(23, function(add)
    if not ns.db.showObjectives then return end
    if not objectives or GetTime() - lastRank >= RECALC_SECONDS then Rank() end
    if #ranked == 0 then return end
    add.header("Objectives nearby")
    for i = 1, math.min(MAX_SHOWN, #ranked) do
        local r = ranked[i]
        local entry, p = r.entry, r.progress
        local count = (p and p.have and p.need) and format(" %d/%d", p.have, p.need) or ""
        local tip = format("%s: %s\n%s\n\nClick: mark the nearest one", VERB[entry.kind] or "Objective", entry.label, entry.quest.title)
        add.note(format("|cffffd200%s|r%s  |cffc0c0c0%s|r", entry.label, count, YardsText(r.yards)), nil, function()
            ns.SetWaypoint(r.spot.mapID, r.spot.x, r.spot.y, entry.label .. " - " .. entry.quest.title)
        end, tip)
    end
end)

table.insert(ns.inits, function()
    -- the quest list itself changed: rebuild what to look for
    ns.On("QUEST_LOG_UPDATE", function()
        objectives = nil
        lastRank = 0
    end)
end)
