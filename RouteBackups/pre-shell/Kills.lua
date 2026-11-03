local ADDON_NAME, ns = ...

-- Kill record: what you've killed by creature type (Beast, Humanoid, Undead...)
-- and rank (normal, elite, rare), plus dungeon bosses.
--
-- Kills are counted from the XP message, which only names the mob, so the
-- type and rank are remembered from when you last saw that mob as a target,
-- under your mouse or as a nameplate (the game hides the combat log here).
-- Bosses come from the game's boss-kill events.

local Safe = ns.Safe

local MAX_CREATURES = 4000  -- names remembered (account-wide)
local MAX_BOSS_LOG = 100

local RANKS = { normal = "normal", trivial = "normal", minus = "normal", elite = "elite",
                rare = "rare", rareelite = "rareelite", worldboss = "boss" }

-- name -> { t = creature type, c = rank }
local function Creatures()
    ns.db.creatureInfo = ns.db.creatureInfo or {}
    return ns.db.creatureInfo
end

local seenCount -- how many names are remembered (counted once, then kept up to date)

local function Remember(unit)
    if not unit or Safe(UnitExists, unit) ~= true then return end
    if Safe(UnitIsPlayer, unit) ~= false or Safe(UnitCanAttack, "player", unit) ~= true then return end
    local name = Safe(UnitName, unit)
    if not name then return end
    local creatureType = Safe(UnitCreatureType, unit)
    local rank = RANKS[Safe(UnitClassification, unit) or ""] or "normal"
    local list = Creatures()
    local known = list[name]
    if known and known.t == creatureType and known.c == rank then return end
    if not known then
        if not seenCount then
            seenCount = 0
            for _ in pairs(list) do seenCount = seenCount + 1 end
        end
        if seenCount >= MAX_CREATURES then return end
        seenCount = seenCount + 1
    end
    list[name] = { t = creatureType, c = rank }
end

-- rank from QuestieDB for mobs never seen up close: 1 elite, 2 rare elite, 3 boss, 4 rare
local QUESTIE_RANKS = { [1] = "elite", [2] = "rareelite", [3] = "boss", [4] = "rare" }

local function QuestieRank(name)
    if not (ns.QuestieIdsByName and ns.QuestieGet) then return nil end
    local ids = ns.QuestieIdsByName("Npc", name)
    local id = ids and ids[1]
    return id and QUESTIE_RANKS[ns.QuestieGet("Npc", id, "rank") or 0]
end

-- Called by the XP tracker for every kill that gave XP
function ns.RecordKillType(name)
    if not name or ns.IsSecret(name) then return end
    local info = Creatures()[name]
    local creatureType = (info and info.t) or "Unknown"
    local rank = (info and info.c) or QuestieRank(name) or "normal"
    ns.cdb.killsByType = ns.cdb.killsByType or {}
    ns.cdb.killsByRank = ns.cdb.killsByRank or {}
    ns.cdb.killsByType[creatureType] = (ns.cdb.killsByType[creatureType] or 0) + 1
    ns.cdb.killsByRank[rank] = (ns.cdb.killsByRank[rank] or 0) + 1
end

-- Every boss you take down (any dungeon boss, not only the last)
local lastBoss, lastBossAt = nil, 0
local function OnBoss(name)
    if type(name) ~= "string" or ns.IsSecret(name) then return end
    -- the game can send both boss events for the same kill
    if name == lastBoss and GetTime() - lastBossAt < 30 then return end
    lastBoss, lastBossAt = name, GetTime()
    ns.cdb.bossKills = (ns.cdb.bossKills or 0) + 1
    ns.cdb.bossesKilled = ns.cdb.bossesKilled or {}
    ns.cdb.bossesKilled[name] = (ns.cdb.bossesKilled[name] or 0) + 1
    ns.cdb.bossLog = ns.cdb.bossLog or {}
    local ok, dungeon = pcall(GetInstanceInfo)
    table.insert(ns.cdb.bossLog, 1, { name = name, time = time(),
                                      dungeon = ok and type(dungeon) == "string" and not ns.IsSecret(dungeon) and dungeon or nil })
    while #ns.cdb.bossLog > MAX_BOSS_LOG do table.remove(ns.cdb.bossLog) end
end

-- Everything for the record: { total, byType, byRank, bosses, uniqueBosses, bossLog, mostKilled }
function ns.KillRecord()
    local r = { total = ns.cdb.totalKills or 0, byType = ns.cdb.killsByType or {}, byRank = ns.cdb.killsByRank or {},
                bosses = ns.cdb.bossKills or 0, uniqueBosses = 0, bossLog = ns.cdb.bossLog or {} }
    for _ in pairs(ns.cdb.bossesKilled or {}) do r.uniqueBosses = r.uniqueBosses + 1 end
    -- most killed across every zone
    local byName = {}
    for _, mobs in pairs(ns.cdb.mobs or {}) do
        for name, m in pairs(mobs) do byName[name] = (byName[name] or 0) + (m.kills or 0) end
    end
    local most = {}
    for name, n in pairs(byName) do most[#most + 1] = { name = name, n = n } end
    table.sort(most, function(a, b) return a.n > b.n end)
    r.mostKilled = most
    return r
end

table.insert(ns.inits, function()
    ns.On("PLAYER_TARGET_CHANGED", function() Remember("target") end)
    ns.On("UPDATE_MOUSEOVER_UNIT", function() Remember("mouseover") end)
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) Remember(unit) end)
    ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
        if success == 1 or success == true then OnBoss(name) end
    end)
    ns.On("BOSS_KILL", function(_, _, name) OnBoss(name) end)
end)
