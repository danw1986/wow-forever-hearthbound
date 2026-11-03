local ADDON_NAME, ns = ...

-- Death tracker: when, where and (when the client lets us see it) to what.

local Safe = ns.Safe
local MAX_DEATHS = 500

-- Enemy names are hidden in combat on this client, so remember the last
-- hostile target we could read before the fight started
local lastEnemy

local function OnTargetChanged()
    local hostile = Safe(UnitCanAttack, "player", "target")
    if hostile then
        local name = Safe(UnitName, "target")
        if name then lastEnemy = name end
    end
end

local function OnDeath()
    local deaths = ns.cdb.deaths
    deaths[#deaths + 1] = {
        time = time(),
        level = UnitLevel("player"),
        zone = Safe(GetRealZoneText) or "?",
        killer = lastEnemy,
    }
    while #deaths > MAX_DEATHS do table.remove(deaths, 1) end
    local s = ns.Session()
    s.deaths = (s.deaths or 0) + 1
end

-- Totals for the Journey tab
function ns.DeathStats()
    local level = UnitLevel("player")
    local since = ns.Session().start
    local stats = { total = 0, thisLevel = 0, session = 0, zones = {}, killers = {} }
    for _, d in ipairs(ns.cdb.deaths) do
        stats.total = stats.total + 1
        if d.level == level then stats.thisLevel = stats.thisLevel + 1 end
        if d.time >= since then stats.session = stats.session + 1 end
        stats.zones[d.zone] = (stats.zones[d.zone] or 0) + 1
        if d.killer then stats.killers[d.killer] = (stats.killers[d.killer] or 0) + 1 end
    end
    return stats
end

table.insert(ns.inits, function()
    ns.cdb.deaths = ns.cdb.deaths or {}
    ns.On("PLAYER_TARGET_CHANGED", OnTargetChanged)
    ns.On("PLAYER_DEAD", OnDeath)
end)
