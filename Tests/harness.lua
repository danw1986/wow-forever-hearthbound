-- A fake WoW around Guide.lua, to run the guide's logic outside the game.
-- Everything not stubbed here is a "fake": callable, indexable, arithmetic-safe.
local fakeMT
local function fake() return setmetatable({}, fakeMT) end
fakeMT = {
    __index = function(t, k)
        if type(k) == "number" then return nil end
        local f = fake()
        rawset(t, k, f)
        return f
    end,
    __call = function() return fake() end,
    __add = function() return 0 end, __sub = function() return 0 end, __mul = function() return 0 end,
    __div = function() return 0 end, __unm = function() return 0 end, __mod = function() return 0 end,
    __concat = function(a, b) return (type(a) == "string" and a or "") .. (type(b) == "string" and b or "") end,
    __len = function() return 0 end,
    __lt = function() return false end, __le = function() return false end,
}

W = {} -- the fake world the tests change
W.completed, W.log, W.level, W.time, W.events = {}, {}, 10, 1, {}

local G = setmetatable({}, { __index = function(_, k)
    local v = rawget(_G, k)
    if v ~= nil then return v end
    return fake()
end })

-- what the guide asks the game
G.GetTime = function() return W.time end
G.UnitRace = function() return W.race or "Orc", W.raceFile or "Orc", W.raceId or 2 end
G.UnitClass = function() return W.class or "Warrior", W.classFile or "WARRIOR", W.classId or 1 end
G.UnitLevel = function() return W.level end
G.UnitFactionGroup = function() return "Horde" end
G.UnitXP = function() return 0 end
G.UnitXPMax = function() return 1000 end
G.GetMoney = function() return W.money or 0 end
G.GetNumSkillLines = function() return 0 end
G.GetMaxPlayerLevel = function() return 60 end
G.IsInInstance = function() return false end
G.InCombatLockdown = function() return false end
G.GetRealZoneText = function() return W.zone or "Durotar" end
G.GetSubZoneText = function() return "" end
G.GetMinimapZoneText = function() return "" end
G.GetBindLocation = function() return W.bind or "Nowhere" end
G.UnitOnTaxi = function() return false end
G.IsQuestFlaggedCompleted = nil
G.GetQuestLogIndexByID = nil
G.GetQuestLogTitle = nil
G.IsShiftKeyDown = function() return false end
G.GetItemCount = function(id) return W.items and W.items[id] or 0 end
G.C_Item = { GetItemCount = function(id) return W.items and W.items[id] or 0 end }
G.IsInGroup = function() return W.inGroup == true end
G.UnitExists = function() return false end
G.GetItemCooldown = function() return 0, 0 end
G.C_Container = { GetItemCooldown = function() return 0, 0 end }
G.C_QuestLog = {
    IsQuestFlaggedCompleted = function(q) return W.completed[q] == true end,
    IsOnQuest = function(q) return W.log[q] ~= nil end,
    IsComplete = function(q) return W.log[q] == "complete" end,
    GetQuestObjectives = function() return nil end,
}
G.C_Timer = {
    After = function(_, fn) W.timers = W.timers or {} table.insert(W.timers, fn) end,
    NewTicker = function(_, fn) W.tickers = W.tickers or {} table.insert(W.tickers, fn) return fake() end,
}
G.SOUNDKIT = {}
G.strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
G.select = select
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
G.math = math G.string = string G.table = table G.format = string.format
G.bit = { band = function(a, b) return a & b end }
G.unpack = table.unpack
G.LibStub = nil

-- Hearthbound's own helpers the guide uses
local ns = setmetatable({}, { __index = function(t, k)
    local f = function() return nil end
    rawset(t, k, f)
    return f
end })
ns.inits, ns.refreshers = {}, {}
ns.HordeGuides = {}
ns.QuestObjectives = function() return W.objectives or {} end
ns.ObjectiveProgress = function() return nil end
ns.MaxQuests = function() return 20 end
ns.movers = {}
ns.Safe = function(fn, ...)
    if not fn then return end
    local r = table.pack(pcall(fn, ...))
    if r[1] then return table.unpack(r, 2, r.n) end
end
ns.db = { guide = true, guideArrow = true, guideSkipGrey = false, guideEdition = "forever", guidePanel = false, positions = {}, guideNever = {} }
ns.cdb = { quests = {} }
ns.color = setmetatable({}, { __index = function() return { 1, 1, 1, 1 } end })
ns.FONT = "font"
ns.BACKDROP = nil
ns.printed = {}
ns.Print = function(msg) table.insert(ns.printed, msg) end
ns.On = function(event, fn) W.events[event] = W.events[event] or {} table.insert(W.events[event], fn) end
ns.Text = function() return fake() end
ns.CreateButton = function() return fake() end
ns.CreateBar = function() return fake() end
ns.Skin = function() end
ns.InlineIcon = function() return "" end
ns.QuestDifficulty = function(ql, pl) return (pl - ql >= 6) and "trivial" or "normal" end
ns.Short = function(n) return tostring(n) end
ns.Comma = function(n) return tostring(n) end
ns.openQuests = {}
ns.QuestieWhyNot = function(q)
    if W.whyNot and W.whyNot[q] then return W.whyNot[q] end
    local need = W.requiredLevels and W.requiredLevels[q]
    if need and need > W.level then return "needs level " .. need end
end
ns.QuestDone = function(q) return W.completed[q] == true end
ns.LearnedPrereqs = function(q) return W.learned and W.learned[q] or {} end
ns.QuestieIdsByName = function() return {}, false end
ns.QuestieAvailable = function() return true end
W.questLevels = { [896] = 18 } -- quest levels the fake QuestieDB knows
ns.QuestieGet = function(t, id, field)
    if t == "Quest" and field == "questLevel" then return W.questLevels[id] end
    if t == "Quest" and field == "requiredLevel" then return W.requiredLevels and W.requiredLevels[id] end
    if t == "Quest" and field == "startedBy" then return W.starters and W.starters[id] end
    if t == "Npc" and field == "spawns" then return W.npcSpawns and W.npcSpawns[id] end
    if t == "Quest" and field == "preQuestSingle" then return W.prereqs and W.prereqs[id] end
end
ns.GuideDetours = function() return W.detours or { nearby = {}, class = {} } end
ns.GuideDetourText = function() return "" end
-- positions: the route's map percent is the "world" (1 percent = 10 yards), one continent
ns.WorldPos = function(mapID, x, y) return 1, x * 60, y * 60 end
ns.UiMapForArea = function(z) return z end
ns.PlayerWorldPos = function() if W.pos then return 1, W.pos[1] * 60, W.pos[2] * 60 end end
ns.NearestSpot = function(spots, c, wx, wy)
    local best, bd
    for _, sp in ipairs(spots) do
        local d = wx and math.sqrt((sp.wx - wx) ^ 2 + (sp.wy - wy) ^ 2)
        if d and (not bd or d < bd) then best, bd = sp, d end
    end
    return best or spots[1], bd
end
ns.QuestieSpawnSpots = function() return {} end

HARNESS_NS = ns
HARNESS_G = G

function W.load(path)
    local src = assert(io.open(path, "r")):read("a")
    if path:find("Guide.lua$") then
        src = src .. [[

ns._dbg = {
    passed = function(j) passMemo = {} return PassedRaw(j) end,
    list = function() return list end,
    state = function() return state end,
    byNumber = function() return byNumber end,
    routeCur = function() return routeCur end,
    details = function(st) return Details(st) end,
    chainOpened = function(q) return ChainOpened(q) end,
    prereqMissing = function(q) return PrereqMissing(q) end,
    routeLevel = function(j) return routeLevel[j] end,
    xp = function() return XPToLevel() end,
    reload = function() Load() end,
    todo = function() local t = {} for _, k in ipairs(LeftBehind()) do t[#t + 1] = list[k].q end return t end,
    group = function() return StepGroup() end,
    groupTitle = function() return GroupTitle(StepGroup()) end,
    why = function(j) local s = list[j] return LevelBlocked(s), Low(s), Orphan(s, j), GameDone(s) end,
    goalLine = function(s) return K.GoalLine(s) end,
    whenHolds = function(s) return K.WhenHolds(s) end,
    places = function() return K.SectionPlaces() end,
    stepPlace = function(d) K.StepPlace(d) end,
    hearthHint = function(t, short) return K.HearthHint(t, short) end,
    target = function(s) return Target(s) end,
}]]
    end
    local f = assert(load(src, "@" .. path, "t", G))
    f("Hearthbound", ns)
end

function W.fire(event, ...)
    for _, fn in ipairs(W.events[event] or {}) do fn(event, ...) end
end

function W.runTimers()
    for _ = 1, 5 do
        local t = W.timers or {}
        W.timers = {}
        if #t == 0 then return end
        for _, fn in ipairs(t) do fn() end
    end
end

function W.tick()
    W.time = W.time + 1
    ns.openQuests = {}
    for q, st in pairs(W.log) do table.insert(ns.openQuests, { id = q, title = "Q" .. q, complete = st == "complete", level = 5 }) end
    W.runTimers()
    for _, fn in ipairs(W.tickers or {}) do fn() end
    W.runTimers()
end
