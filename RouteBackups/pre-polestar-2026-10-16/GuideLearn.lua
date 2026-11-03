local ADDON_NAME, ns = ...

-- The guide learns from your play. QuestieDB doesn't know many of Forever's
-- quest chains, so while you play this quietly writes down what the game shows
-- you, account-wide (ns.db.learn) so every character adds to it:
--
--   offers  every quest an NPC (or object) offers you: the NPC, the level you
--           were, and the quests you'd handed in just before the first time -
--           over a few characters that shows what each quest needs first
--   quests  for each quest: the level you took it at, the XP it gave and the
--           level you handed it in at, and how long it took
--   path    each pick-up and hand-in, in order, with time, level and place
--           (per character): the route you actually played
--   levels  per character and level: XP from quests and from everything else
--           (kills, exploring), and the time it took
--
-- Tests/route_optimize.py reads this from the saved variables to order the
-- route by real quest chains and levels. /hb learn shows what's been seen.

local format = string.format
local Safe = ns.Safe

local RECENT = 8         -- hand-ins remembered as "just before" a new offer
local PATH_MAX = 4000    -- path entries kept per character

-- your last hand-ins, newest last: { q, time } - kept per character so a /reload
-- doesn't lose them (ns.cdb.learnRecent)
local function Recent()
    ns.cdb.learnRecent = ns.cdb.learnRecent or {}
    return ns.cdb.learnRecent
end
local accepted = {}      -- quest ID -> GetTime() when you took it (this session)
local lastQuestXP = { xp = 0, at = 0 } -- the last hand-in's XP, to tell quest XP from kill XP
local lastXP, lastMax, lastLevel

local function DB()
    ns.db.learn = ns.db.learn or {}
    local d = ns.db.learn
    d.version = 1
    d.offers = d.offers or {}
    d.quests = d.quests or {}
    d.path = d.path or {}
    d.levels = d.levels or {}
    return d
end

local function CharKey()
    local name = Safe(UnitName, "player") or "?"
    local realm = Safe(GetRealmName) or "?"
    return name .. "-" .. realm
end

local function Who()
    local _, raceFile, raceID = Safe(UnitRace, "player")
    local _, classFile = Safe(UnitClass, "player")
    return (raceFile or "?"):lower(), raceID, (classFile or "?"):lower()
end

-- where you are: uiMap ID and map percent
local function Where()
    local mapID = Safe(C_Map.GetBestMapForUnit, "player")
    if not mapID then return nil end
    local pos = Safe(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos then return mapID end
    local ok, x, y = pcall(pos.GetXY, pos)
    if not ok or not x or ns.IsSecret and ns.IsSecret(x) then return mapID end
    return mapID, math.floor(x * 1000 + 0.5) / 10, math.floor(y * 1000 + 0.5) / 10
end

-- the NPC or object you're talking to: "npc:1234" / "object:5678", or nil
local function Talker()
    local guid = Safe(UnitGUID, "npc") or Safe(UnitGUID, "target")
    if type(guid) ~= "string" then return nil end
    local kind, id = guid:match("^(%a+)%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    if not kind then return nil end
    if kind == "Creature" or kind == "Vehicle" then return "npc:" .. id end
    if kind == "GameObject" then return "object:" .. id end
    return nil
end

local function PathAdd(entry)
    local d = DB()
    local key = CharKey()
    local path = d.path[key]
    if not path then
        local race, raceID, class = Who()
        path = { race = race, raceID = raceID, class = class }
        d.path[key] = path
    end
    entry.time = time()
    entry.level = UnitLevel("player")
    entry.map, entry.x, entry.y = Where()
    path[#path + 1] = entry
    while #path > PATH_MAX do table.remove(path, 1) end
end

---------------------------------------------------------------------------
-- Offers: what an NPC offers you right now
---------------------------------------------------------------------------
local function NoteOffer(q)
    q = tonumber(q)
    if not q or q <= 0 then return end
    local d = DB()
    local o = d.offers[q]
    local level = UnitLevel("player")
    local race, _, class = Who()
    local talker = Talker()
    if not o then
        o = { minLevel = level, seen = 0, givers = {}, races = {}, classes = {}, after = {} }
        d.offers[q] = o
    end
    o.seen = o.seen + 1
    if level < (o.minLevel or level) then o.minLevel = level end
    if talker then o.givers[talker] = true end
    o.races[race] = true
    o.classes[class] = true
    -- the first time this character sees it: the hand-ins just before it
    local key = CharKey()
    o.firstBy = o.firstBy or {}
    if not o.firstBy[key] then
        o.firstBy[key] = level
        o.afterSamples = (o.afterSamples or 0) + 1
        local seen = {}
        local recentTurnIns = Recent()
        for k = #recentTurnIns, math.max(1, #recentTurnIns - RECENT + 1), -1 do
            local prev = recentTurnIns[k].q
            if not seen[prev] then
                seen[prev] = true
                o.after[prev] = (o.after[prev] or 0) + 1
            end
        end
    end
end

-- a gossip window: its available quests come with IDs
local function OnGossip()
    if not (C_GossipInfo and C_GossipInfo.GetAvailableQuests) then return end
    for _, info in ipairs(Safe(C_GossipInfo.GetAvailableQuests) or {}) do
        if info.questID then NoteOffer(info.questID) end
    end
end

-- a quest's own window (offered to you): its ID
local function OnQuestDetail()
    NoteOffer(Safe(GetQuestID))
end

---------------------------------------------------------------------------
-- Taking and handing in quests
---------------------------------------------------------------------------
local function OnAccepted(_, a, b)
    local q = tonumber(b) or tonumber(a)
    if not q or q < 1 then return end
    -- an index (old clients) rather than an ID: look it up
    if not b and GetQuestLogTitle and q < 100 then
        local _, _, _, _, _, _, _, id = Safe(GetQuestLogTitle, q)
        if id then q = id end
    end
    NoteOffer(q) -- you can take it, so it's offered
    accepted[q] = GetTime()
    local rec = DB().quests[q] or {}
    rec.takenAt = rec.takenAt or UnitLevel("player")
    if UnitLevel("player") < rec.takenAt then rec.takenAt = UnitLevel("player") end
    DB().quests[q] = rec
    PathAdd({ t = "A", q = q })
end

local function OnTurnedIn(_, q, xp)
    q = tonumber(q)
    if not q then return end
    xp = tonumber(xp) or 0
    local rec = DB().quests[q] or {}
    rec.xp, rec.xpLevel = xp, UnitLevel("player")
    if accepted[q] then
        local took = GetTime() - accepted[q]
        rec.seconds = math.floor(took)
        accepted[q] = nil
    end
    rec.count = (rec.count or 0) + 1
    DB().quests[q] = rec
    local recentTurnIns = Recent()
    recentTurnIns[#recentTurnIns + 1] = { q = q, time = time() }
    while #recentTurnIns > RECENT * 2 do table.remove(recentTurnIns, 1) end
    lastQuestXP.xp, lastQuestXP.at = xp, GetTime()
    PathAdd({ t = "T", q = q, xp = xp })
end

---------------------------------------------------------------------------
-- Levels: XP from quests and from everything else, and time per level
---------------------------------------------------------------------------
local function LevelRec(level)
    local d = DB()
    local key = CharKey()
    d.levels[key] = d.levels[key] or {}
    local rec = d.levels[key][level]
    if not rec then
        rec = { questXP = 0, otherXP = 0, seconds = 0, quests = 0 }
        d.levels[key][level] = rec
    end
    return rec
end

local function OnXPUpdate()
    local xp, max, level = UnitXP("player"), UnitXPMax("player"), UnitLevel("player")
    if not (lastXP and lastLevel) then
        lastXP, lastMax, lastLevel = xp, max, level
        return
    end
    local gain
    if level > lastLevel then gain = (lastMax - lastXP) + xp else gain = xp - lastXP end
    if gain > 0 then
        local rec = LevelRec(lastLevel)
        -- a hand-in's XP arrives as this update: the rest is kills, exploring...
        local fromQuest = 0
        if GetTime() - lastQuestXP.at < 2 and lastQuestXP.xp > 0 then
            fromQuest = math.min(gain, lastQuestXP.xp)
            lastQuestXP.xp = lastQuestXP.xp - fromQuest
            rec.quests = rec.quests + 1
        end
        rec.questXP = rec.questXP + fromQuest
        rec.otherXP = rec.otherXP + (gain - fromQuest)
    end
    lastXP, lastMax, lastLevel = xp, max, level
end

-- time per level, counted while you're logged in
local function Tick()
    local level = UnitLevel("player")
    if level and level > 0 then
        local rec = LevelRec(level)
        rec.seconds = rec.seconds + 10
    end
end

-- Your pace on this level: minutes so far, XP per hour, and minutes to the
-- next level at that pace (nil until there's enough to go on)
function ns.LevelPace()
    local level = UnitLevel("player")
    local rec = DB().levels[CharKey()]
    rec = rec and rec[level]
    if not rec or rec.seconds < 120 then return nil end
    local gained = rec.questXP + rec.otherXP
    if gained <= 0 then return nil end
    local perHour = gained / rec.seconds * 3600
    local left = (UnitXPMax("player") or 0) - (UnitXP("player") or 0)
    return math.floor(rec.seconds / 60), math.floor(perHour), math.ceil(left / perHour * 60)
end

---------------------------------------------------------------------------
-- What it's learned
---------------------------------------------------------------------------
-- the quests an offer was always preceded by (the likely prerequisites)
function ns.LearnedPrereqs(q)
    local o = DB().offers[q]
    if not (o and o.afterSamples and o.afterSamples > 0) then return {} end
    local out = {}
    for prev, n in pairs(o.after) do
        if n >= o.afterSamples then out[#out + 1] = prev end
    end
    return out
end

function ns.LearnedQuest(q) return DB().quests[q] end
function ns.LearnedOffer(q) return DB().offers[q] end

function ns.LearnStatus()
    local d = DB()
    local offers, quests, chars, steps = 0, 0, 0, 0
    for _ in pairs(d.offers) do offers = offers + 1 end
    for _ in pairs(d.quests) do quests = quests + 1 end
    for _, path in pairs(d.path) do chars = chars + 1 steps = steps + #path end
    ns.Print(format("Learned so far: %d quest offers seen, %d quests with XP and levels, %d pick-ups and hand-ins on %d character%s.",
        offers, quests, steps, chars, chars == 1 and "" or "s"))
    local key = CharKey()
    local lv = d.levels[key] or {}
    local lines = {}
    for level = 1, 60 do
        local r = lv[level]
        if r and r.seconds > 0 then
            lines[#lines + 1] = format("%d: %dm (%d%% quests)", level, math.floor(r.seconds / 60),
                (r.questXP + r.otherXP) > 0 and math.floor(100 * r.questXP / (r.questXP + r.otherXP)) or 0)
        end
    end
    if #lines > 0 then ns.Print("Time per level (share of XP from quests): " .. table.concat(lines, ", ")) end
    local mins, perHour, eta = ns.LevelPace()
    if mins then
        ns.Print(format("This level: %dm so far, %s XP an hour - about %dm to level %d at this pace.",
            mins, ns.Comma and ns.Comma(perHour) or perHour, eta, UnitLevel("player") + 1))
    end
    ns.Print("Turn it off in Settings > Levelling guide (\"Learn from my play\"). It's only kept on this computer.")
end

table.insert(ns.inits, function()
    if ns.db.guideLearn == nil then ns.db.guideLearn = true end
    local function on(fn) return function(...) if ns.db.guideLearn then pcall(fn, ...) end end end
    ns.On("GOSSIP_SHOW", on(OnGossip))
    ns.On("QUEST_DETAIL", on(OnQuestDetail))
    ns.On("QUEST_ACCEPTED", on(OnAccepted))
    ns.On("QUEST_TURNED_IN", on(OnTurnedIn))
    ns.On("PLAYER_XP_UPDATE", on(OnXPUpdate))
    ns.On("PLAYER_LEVEL_UP", on(function() C_Timer.After(0.5, function() pcall(OnXPUpdate) end) end))
    ns.On("PLAYER_ENTERING_WORLD", on(function()
        lastXP, lastMax, lastLevel = UnitXP("player"), UnitXPMax("player"), UnitLevel("player")
    end))
    C_Timer.NewTicker(10, on(Tick))
end)
