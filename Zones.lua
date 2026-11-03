local ADDON_NAME, ns = ...

-- Where next: rates your current zone for your level and suggests where to
-- go, from Classic zone level ranges plus the quests you're carrying.

local format = string.format
local Safe = ns.Safe

local SUGGESTIONS = 3
local QUEST_BONUS, QUEST_BONUS_CAP = 1.5, 9 -- per useful open quest in a zone

-- uiMapID, English name, min level, max level, faction ("A", "H" or nil for both).
-- Classic ranges, adjusted where WoW Forever's beta guides differ. Zones new
-- in Forever have no known map ID yet (0), so they match by English name;
-- `new` tags them in the panel and `starter` keeps a starting zone out of
-- suggestions unless you're already there.
local ZONES = {
    -- new in WoW Forever
    { 0, "Zephras Isle", 1, 12, nil, new = true, starter = true }, -- Skyborne start
    { 0, "Riverglades", 35, 45, nil, new = true },  -- Eastern Kingdoms, off Redridge / Burning Steppes
    { 0, "Shen'dralas", 40, 46, nil, new = true },  -- estimated: not announced, beta shows level 43 mobs
    { 0, "Mount Hyjal", 58, 60, nil, new = true },  -- endgame, via Darkwhisper Gorge in Winterspring

    -- Classic
    { 1429, "Elwynn Forest", 1, 10, "A" }, { 1426, "Dun Morogh", 1, 10, "A" }, { 1438, "Teldrassil", 1, 10, "A" },
    { 1411, "Durotar", 1, 10, "H" }, { 1412, "Mulgore", 1, 10, "H" }, { 1420, "Tirisfal Glades", 1, 10, "H" },
    { 1436, "Westfall", 10, 20, "A" }, { 1432, "Loch Modan", 10, 20, "A" }, { 1439, "Darkshore", 10, 20, "A" },
    { 1413, "The Barrens", 10, 25, "H" }, { 1421, "Silverpine Forest", 10, 20, "H" },
    { 1433, "Redridge Mountains", 15, 25, "A" }, { 1442, "Stonetalon Mountains", 15, 27 },
    { 1431, "Duskwood", 18, 30, "A" }, { 1440, "Ashenvale", 18, 30 }, { 1437, "Wetlands", 20, 30, "A" },
    { 1424, "Hillsbrad Foothills", 20, 30 }, { 1441, "Thousand Needles", 25, 35 },
    { 1416, "Alterac Mountains", 30, 40 }, { 1417, "Arathi Highlands", 30, 40 }, { 1443, "Desolace", 30, 40 },
    { 1434, "Stranglethorn Vale", 30, 45 }, { 1445, "Dustwallow Marsh", 35, 45 },
    { 1418, "Badlands", 35, 45 }, { 1435, "Swamp of Sorrows", 35, 45 },
    { 1444, "Feralas", 40, 50 }, { 1446, "Tanaris", 40, 50 }, { 1425, "The Hinterlands", 40, 50 },
    { 1427, "Searing Gorge", 43, 50 }, { 1447, "Azshara", 45, 55 }, { 1419, "Blasted Lands", 45, 55 },
    { 1449, "Un'Goro Crater", 48, 55 }, { 1448, "Felwood", 48, 55 }, { 1428, "Burning Steppes", 50, 58 },
    { 1422, "Western Plaguelands", 51, 58 }, { 1423, "Eastern Plaguelands", 53, 60 },
    { 1452, "Winterspring", 53, 60 }, { 1451, "Silithus", 53, 60 }, -- 55-60 in Classic
}

local DUNGEON_SUGGESTIONS = 2

local zones = {}  -- built at login with localized names
local byName = {}

local function BuildZones()
    for _, z in ipairs(ZONES) do
        local name = z[2]
        if z[1] > 0 and C_Map and C_Map.GetMapInfo then
            local info = Safe(C_Map.GetMapInfo, z[1])
            if info and info.name and info.name ~= "" then name = info.name end
        end
        local zone = { name = name, min = z[3], max = z[4], faction = z[5], new = z.new, starter = z.starter }
        zones[#zones + 1] = zone
        byName[name] = zone
    end
end

local function MyFaction()
    local faction = Safe(UnitFactionGroup, "player")
    if faction == "Alliance" then return "A" end
    if faction == "Horde" then return "H" end
end

-- Open quests per zone that are still worth doing (not grey, not handed-in ready)
local function UsefulQuestsByZone(level)
    local counts = {}
    for _, q in ipairs(ns.openQuests or {}) do
        if q.zone and q.level and q.level > 0 and not q.complete
            and ns.QuestDifficulty(q.level, level) ~= "trivial" then
            counts[q.zone] = (counts[q.zone] or 0) + 1
        end
    end
    return counts
end

-- How well a level fits a zone: best around 40% into its range
local function LevelFit(zone, level)
    if level < zone.min - 2 or level > zone.max then return nil end
    local sweet = zone.min + (zone.max - zone.min) * 0.4
    return 10 - math.abs(level - sweet)
end

local function Range(zone)
    local text = format("|cff999999%d-%d|r", zone.min, zone.max)
    if zone.new then text = text .. " |cff40c0ffnew|r" end
    return text
end

-- good / low / danger status of the zone you're in
local function CurrentStatus(zone, level)
    if level > zone.max then return "|cff999999Outlevelled - time to move on|r" end
    if level >= zone.max - 2 then return "|cffffd200Getting low for you|r" end
    if level < zone.min - 2 then return "|cffff5544Dangerous for your level|r" end
    if level < zone.min then return "|cffff8040A little high - careful|r" end
    return "|cff6fdc6fGood fit|r"
end

function ns.ZoneSuggestions(level)
    local faction = MyFaction()
    local questsByZone = UsefulQuestsByZone(level)
    local here = Safe(GetRealZoneText)
    local list = {}
    for _, zone in ipairs(zones) do
        local allowed = (not zone.faction or not faction or zone.faction == faction)
            and (not zone.starter or zone.name == here)
        if allowed then
            local fit = LevelFit(zone, level)
            local quests = questsByZone[zone.name] or 0
            -- quests you're carrying make a zone worth it even near the edge of its range
            if fit or quests > 0 then
                local score = (fit or 0) + math.min(QUEST_BONUS_CAP, quests * QUEST_BONUS)
                list[#list + 1] = { zone = zone, score = score, quests = quests, here = zone.name == here }
            end
        end
    end
    table.sort(list, function(a, b) return a.score > b.score end)
    return list
end

ns.AddSection(24, function(add, level)
    if not ns.db.showZones then return end
    local max = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    if level >= max then return end

    add.header("Where next")
    local here = Safe(GetRealZoneText)
    local current = here and byName[here]
    if current then
        add.row(current.name .. " " .. Range(current), CurrentStatus(current, level))
    end

    local shown = 0
    for _, s in ipairs(ns.ZoneSuggestions(level)) do
        if not s.here then
            local right = s.quests > 0
                and format("|cffffd200%d quest%s|r", s.quests, s.quests == 1 and "" or "s")
                or "|cff999999no quests yet|r"
            add.row(s.zone.name .. " " .. Range(s.zone), right)
            shown = shown + 1
            if shown >= SUGGESTIONS then break end
        end
    end
    if shown == 0 then
        add.note("Nowhere better right now - stay put.", ns.color.dim)
    end

    if not ns.db.showDungeons then return end
    local dungeons = ns.DungeonSuggestions(level)
    if #dungeons == 0 then return end
    add.header("Dungeons")
    for i = 1, math.min(DUNGEON_SUGGESTIONS, #dungeons) do
        local d = dungeons[i]
        local range = format("|cff999999%d-%d|r", d.min, d.max)
        if d.new then range = range .. " |cff40c0ffnew|r" end
        add.row(d.name .. " " .. range, "|cff999999" .. d.zone .. "|r")
    end
    add.note("|cff999999Quests, loot and map markers:|r /hb dungeons")
end)

-- How well a level fits a dungeon: best a little into its range, and never
-- below its minimum (those pulls hurt in a group of five too)
local function DungeonFit(d, level)
    if level < d.min - 1 or level > d.max - 1 then return nil end
    local sweet = d.min + (d.max - d.min) * 0.3
    return 10 - math.abs(level - sweet)
end

-- Dungeons (from ns.DUNGEONS) that suit `level`, best first
function ns.DungeonSuggestions(level)
    local faction = MyFaction()
    local list = {}
    for _, d in ipairs(ns.DUNGEONS) do
        if not d.faction or not faction or d.faction == faction then
            local fit = DungeonFit(d, level)
            if fit then
                -- break ties towards Forever's new dungeons
                list[#list + 1] = { dungeon = d, name = d.name, min = d.min, max = d.max, zone = d.zone, new = d.new,
                                    score = fit + (d.new and 0.5 or 0) }
            end
        end
    end
    table.sort(list, function(a, b) return a.score > b.score end)
    return list
end

function ns.PlayerFaction()
    return MyFaction()
end

-- How well a dungeon fits `level` (nil if it doesn't), for the journal list
function ns.DungeonFitsLevel(d, level)
    return DungeonFit(d, level) ~= nil
end

table.insert(ns.inits, function()
    ns.On("PLAYER_LOGIN", BuildZones)
end)
