local ADDON_NAME, ns = ...

-- Panel section "Grind spots": for when the quests run dry, the best mobs to
-- kill in your zone - normal (not elite) mobs at a level that gives good XP,
-- with plenty of them about. Click one to mark the nearest.
--
-- Mobs and their spawns come from QuestieDB; XP per kill is the Classic
-- formula, or what you actually got from that mob if the Stats tab saw it.

local format = string.format
local Safe = ns.Safe

local MAX_SHOWN = 3
local SECTION = "grind spots" -- its heading, as the collapse setting stores it
local DENSITY_CAP = 40        -- beyond this many spawns, more doesn't help

local cache = {} -- "areaId:level" -> ranked list (without distances)

-- Classic: how far below you a mob can be before it stops giving XP
local function ZeroDiff(level)
    if level <= 7 then return 5 elseif level <= 9 then return 6 elseif level <= 11 then return 7
    elseif level <= 15 then return 8 elseif level <= 19 then return 9 elseif level <= 29 then return 11
    elseif level <= 39 then return 12 elseif level <= 44 then return 13 elseif level <= 49 then return 14
    elseif level <= 54 then return 15 elseif level <= 59 then return 16 end
    return 17
end

-- XP for killing a normal mob (before rested bonus)
local function MobXP(playerLevel, mobLevel)
    local base = playerLevel * 5 + 45
    if mobLevel >= playerLevel then return base * (1 + 0.05 * math.min(mobLevel - playerLevel, 4)) end
    if ns.GrayLevel and mobLevel <= ns.GrayLevel(playerLevel) then return 0 end
    return base * (1 - (playerLevel - mobLevel) / ZeroDiff(playerLevel))
end
ns.MobXP = MobXP -- for mob tooltips

-- The zone map you're in (not a city district or cave level)
local function ZoneMap()
    local mapID = Safe(C_Map.GetBestMapForUnit, "player")
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    while mapID do
        local info = Safe(C_Map.GetMapInfo, mapID)
        if not info then return nil end
        if info.mapType == zoneType then return mapID, info.name end
        if not info.parentMapID or info.parentMapID == 0 then return nil end
        mapID = info.parentMapID
    end
end

-- XP you actually got for your last kill of this mob, if it was at your
-- current level (from the Stats tab's records)
local function SeenXP(zoneName, name, level)
    local mobs = ns.cdb.mobs and zoneName and ns.cdb.mobs[zoneName]
    local m = mobs and name and mobs[name]
    if m and m.lastXP and m.lastLevel == level then return m.lastXP end
end

local function Rank(areaId, mobs, level, zoneName)
    local key = areaId .. ":" .. level
    if cache[key] then return cache[key] end
    local list = {}
    for _, mob in ipairs(mobs) do
        -- the level you'd mostly meet it at, kept to what's sensible to fight
        local mobLevel = math.min(math.floor((mob.min + mob.max) / 2 + 0.5), level + 2)
        if mob.max >= level - 6 and mob.min <= level + 2 then
            local name = ns.QuestieGet("Npc", mob.id, "name")
            local seen = SeenXP(zoneName, name, level)
            local xp = seen or MobXP(level, mobLevel)
            if name and xp > 0 then
                local score = xp * math.sqrt(math.min(mob.count, DENSITY_CAP))
                list[#list + 1] = { id = mob.id, name = name, min = mob.min, max = mob.max, count = mob.count,
                                    xp = xp, seen = seen ~= nil, score = score }
            end
        end
    end
    table.sort(list, function(a, b) return a.score > b.score end)
    cache[key] = list
    return list
end

ns.AddSection(26, function(add, level)
    if not ns.db.showGrind or not ns.QuestieMobsInArea then return end
    add.header("Grind spots")
    if ns.db.collapsedSections[SECTION] then return end -- folded: skip the work

    local mapID, zoneName = ZoneMap()
    local areaId = mapID and ns.AreaForMap and ns.AreaForMap(mapID)
    if not areaId then
        add.note("Not available here.", ns.color.dim)
        return
    end
    local mobs = ns.QuestieMobsInArea(areaId, function() ns.UpdatePanel() end)
    if not mobs then
        add.note("Reading this zone's mobs from QuestieDB...", ns.color.dim)
        return
    end
    local list = Rank(areaId, mobs, level, zoneName)
    if #list == 0 then
        add.note("No good mobs for your level in " .. (zoneName or "this zone") .. ".", ns.color.dim)
        return
    end
    local continent, wx, wy = ns.PlayerWorldPos()
    local toLevel = (UnitXPMax("player") or 0) - (UnitXP("player") or 0)
    for i = 1, math.min(MAX_SHOWN, #list) do
        local m = list[i]
        local spot, yards
        if continent then spot, yards = ns.NearestSpot(ns.QuestieSpawnSpots("Npc", m.id), continent, wx, wy) end
        local levels = m.min == m.max and tostring(m.min) or (m.min .. "-" .. m.max)
        local distance = yards and format("  |cffc0c0c0%s|r", yards < 1000 and format("%d yd", math.floor(yards / 10 + 0.5) * 10)
            or format("%.1fk yd", yards / 1000)) or ""
        local kills = toLevel > 0 and math.ceil(toLevel / m.xp) or 0
        local tip = format("%s, level %s\n%d in %s\n%s%d XP a kill - about %d kills to level\n\nClick: mark the nearest one",
            m.name, levels, m.count, zoneName or "this zone", m.seen and "" or "~", math.floor(m.xp + 0.5), kills)
        add.note(format("|cffffd200%s|r |cff999999(%s)|r %s%d xp%s", m.name, levels, m.seen and "" or "~",
            math.floor(m.xp + 0.5), distance), nil, spot and function()
            ns.SetWaypoint(spot.mapID, spot.x, spot.y, m.name)
        end or nil, tip)
    end
end)

table.insert(ns.inits, function()
    -- starts folded the first time, so its first read of the mobs only happens when you want it
    if not ns.db.grindSectionSeen then
        ns.db.grindSectionSeen = true
        if ns.db.collapsedSections[SECTION] == nil then ns.db.collapsedSections[SECTION] = true end
    end
    ns.On("PLAYER_LEVEL_UP", function() wipe(cache) end)
    ns.On("PLAYER_XP_UPDATE", function() wipe(cache) end) -- kills update what each mob really gives
end)
