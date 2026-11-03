local ADDON_NAME, ns = ...

-- Reads quest givers, hand-ins, dungeon quests and dungeon entrances from
-- Questie's database while the game runs. Nothing is copied into Hearthbound:
-- without Questie installed, every function here returns nil.
--
-- Data comes through LibQuestieDB, QuestieDB's public provider API (contract
-- version 2), plus Questie's ZoneDB module for area ID -> map ID conversion.

local format = string.format
local CONTRACT = 2

local lib
local startCache, finishCache = {}, {}
local dungeonQuests -- dungeonKey -> list, built in the background
local scanning = false
local questGivers
local giversById = {} -- questId -> giver entry
local itemUses = {}   -- itemId -> quest IDs that need it
local itemStarts = {} -- itemId -> quest ID it starts
local nextOf = {}     -- questId -> quests that need it done first (the chain onwards)
local areaQuests = {} -- zone area ID -> quest IDs filed under it (not dungeons)
local giversByTitle = {} -- normalised title -> giver entry, for loose name matching
local scanWaiters = {}

-- "Oh Brother. . ." / "oh brother..." -> "ohbrother"
local function NormalTitle(title)
    return (title or ""):lower():gsub("[^%w]", "")
end
ns.NormalTitle = NormalTitle
local ScanQuests -- defined below; used by the giver lookup above it

---------------------------------------------------------------------------
-- Access
---------------------------------------------------------------------------
local function Lib()
    if lib ~= nil then return lib or nil end
    local candidate = rawget(_G, "LibQuestieDB")
    if candidate and candidate.RequireContract and candidate.Quest and candidate.Npc then
        local ok, compatible = pcall(candidate.RequireContract, CONTRACT)
        if ok and compatible then
            lib = candidate
            return lib
        end
    end
    lib = false
    return nil
end

function ns.QuestieAvailable()
    return Lib() ~= nil
end

local function Get(datatype, id, field)
    local l = Lib()
    if not l or not id then return nil end
    local ok, value = pcall(l[datatype].Get, id, field)
    if ok then return value end
end

-- Questie's modules, looked up once (these are called thousands of times in a scan)
local modules = {}
local function QuestieModule(name)
    if modules[name] then return modules[name] end
    local loader = rawget(_G, "QuestieLoader")
    if not loader or not loader.ImportModule then return nil end
    local ok, module = pcall(loader.ImportModule, loader, name)
    if ok and module then modules[name] = module end
    return ok and module or nil
end

-- Questie finishes starting up some time after login; until then its zone
-- tables are empty and every lookup fails
local function QuestieReady()
    local questie = rawget(_G, "Questie")
    return type(questie) == "table" and questie.started == true
end
ns.QuestieReady = QuestieReady

-- QuestieDB's own zone data (it ships Forever's tables), readable even when
-- Questie itself never finishes starting up
local zoneSupport
local function ZoneSupport()
    if zoneSupport ~= nil then return zoneSupport or nil end
    local l = Lib()
    local support = l and type(l.Support) == "table" and l.Support.Get and l.Support.Get("ZoneDB")
    zoneSupport = type(support) == "table" and type(support.private) == "table" and support.private or false
    return zoneSupport or nil
end

-- support tables are stored as "return { ... }" source text
local function Decode(value)
    if type(value) == "table" then return value end
    if type(value) ~= "string" or not loadstring then return nil end
    local chunk = loadstring(value)
    if not chunk then return nil end
    local ok, result = pcall(chunk)
    return ok and type(result) == "table" and result or nil
end

local areaMaps
local function AreaMaps()
    if areaMaps ~= nil then return areaMaps or nil end
    local private = ZoneSupport()
    local base = private and Decode(private.areaIdToUiMapId)
    if base then
        for areaId, mapID in pairs(Decode(private.areaIdToUiMapIdOverride) or {}) do base[areaId] = mapID end
    end
    areaMaps = base or false
    return base
end

local uiMapCache = {}
local function UiMapForArea(areaId)
    local cached = uiMapCache[areaId]
    if cached ~= nil then return cached or nil end
    local fromSupport = AreaMaps() and AreaMaps()[areaId]
    if type(fromSupport) == "number" then
        -- 0 means "never show on a map"
        uiMapCache[areaId] = fromSupport > 0 and fromSupport or false
        return uiMapCache[areaId] or nil
    end
    local zoneDB = QuestieModule("ZoneDB")
    local ok, mapID
    if QuestieReady() and zoneDB and zoneDB.GetUiMapIdByAreaId then ok, mapID = pcall(zoneDB.GetUiMapIdByAreaId, zoneDB, areaId) end
    if ok and type(mapID) == "number" and mapID > 0 then
        uiMapCache[areaId] = mapID
        return mapID
    end
    -- Questie couldn't say: find the map by the zone's name instead
    local area = C_Map.GetAreaInfo and ns.Safe(C_Map.GetAreaInfo, areaId)
    local byName = area and ns.FindMapID and ns.FindMapID(area)
    if byName then
        uiMapCache[areaId] = byName
        return byName
    end
    uiMapCache[areaId] = false
    return nil
end
ns.UiMapForArea = UiMapForArea

local hiddenQuests
local function Hidden(questId)
    if hiddenQuests == nil then
        local corrections = QuestieModule("QuestieCorrections")
        hiddenQuests = corrections and type(corrections.hiddenQuests) == "table" and corrections.hiddenQuests or false
    end
    return hiddenQuests and hiddenQuests[questId] ~= nil or false
end

-- "A", "H" or nil for the player's faction
local function MyFaction()
    local faction = UnitFactionGroup("player")
    return (faction == "Alliance" and "A") or (faction == "Horde" and "H") or nil
end

local function FriendlyTo(friendly, faction)
    if not friendly or not faction then return true end
    return friendly == "AH" or friendly == faction
end

-- QuestieDB keeps Classic Era positions; Forever redrew a few zone maps
-- (Mulgore, Stormwind, Redridge, Eastern Plaguelands), so move them onto
-- Forever's maps. Other zones pass through unchanged.
local function ForeverCoords(areaId, x, y)
    local l = Lib()
    if l and l.EraToForever then
        local ok, fx, fy = pcall(l.EraToForever, areaId, x, y)
        if ok and fx and fy then return fx, fy end
    end
    return x, y
end

-- First usable spawn on a world map: mapID, x, y (0-100), or nil
local function FirstSpawn(spawns)
    if type(spawns) ~= "table" then return nil end
    for areaId, coords in pairs(spawns) do
        local mapID = UiMapForArea(areaId)
        if mapID and type(coords) == "table" then
            for _, c in ipairs(coords) do
                if c[1] and c[2] and c[1] >= 0 and c[2] >= 0 then return mapID, ForeverCoords(areaId, c[1], c[2]) end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Quest starters and finishers
---------------------------------------------------------------------------
-- Who (NPC or object) a list of NPC / object IDs points to, and where
local function Locate(npcIds, objectIds, faction)
    for _, npcId in ipairs(npcIds or {}) do
        if FriendlyTo(Get("Npc", npcId, "friendlyToFaction"), faction) then
            local mapID, x, y = FirstSpawn(Get("Npc", npcId, "spawns"))
            local name = Get("Npc", npcId, "name")
            if mapID or name then
                return { giver = name, mapID = mapID, x = x, y = y, kind = "npc" }
            end
        end
    end
    for _, objectId in ipairs(objectIds or {}) do
        local mapID, x, y = FirstSpawn(Get("Object", objectId, "spawns"))
        local name = Get("Object", objectId, "name")
        if mapID or name then
            return { giver = name, mapID = mapID, x = x, y = y, kind = "object" }
        end
    end
end

-- What the scan learned about a quest title: { id, giver, mapID, x, y, kind, level }, or nil.
-- Before the scan has finished this starts it (in the background) and returns nil.
local function Indexed(title)
    if not title or not Lib() then return nil end
    if not questGivers then
        ScanQuests(function()
            wipe(startCache)
            wipe(finishCache)
            if ns.ClearJournalQuestCache then ns.ClearJournalQuestCache() end
            if ns.RefreshJournal then ns.RefreshJournal() end
        end)
        return nil, true
    end
    return giversByTitle[NormalTitle(title)]
end

-- Where a quest starts: { giver, mapID, x, y, kind, questId, level } or nil
function ns.QuestieStart(title)
    if not title then return nil end
    local key = title:lower()
    if startCache[key] ~= nil then return startCache[key] or nil end
    local entry, pending = Indexed(title)
    if pending then return nil end -- don't remember a miss before the index exists
    local result = entry and { giver = entry.giver, mapID = entry.mapID, x = entry.x, y = entry.y, kind = entry.kind,
                               questId = entry.id, level = entry.level } or nil
    startCache[key] = result or false
    return result
end

-- Where a quest is handed in: { giver, mapID, x, y } or nil
-- (pass the quest ID when you have it: some titles are shared by a whole chain -
-- "Further Instructions" is two quests handed in at opposite ends of the map)
function ns.QuestieFinish(title, id)
    if not (title or id) then return nil end
    local key = id and ("#" .. id) or title:lower()
    if finishCache[key] ~= nil then return finishCache[key] or nil end
    local entry, pending
    if id then
        if not Lib() then return nil end
        entry = { id = id }
    else
        entry, pending = Indexed(title)
        if pending then return nil end
    end
    local result
    if entry then
        local finishedBy = Get("Quest", entry.id, "finishedBy")
        if type(finishedBy) == "table" then result = Locate(finishedBy[1], finishedBy[2], MyFaction()) end
    end
    finishCache[key] = result or false
    return result
end
---------------------------------------------------------------------------
-- Dungeons: entrances and the quests Questie files under each dungeon
---------------------------------------------------------------------------
-- dungeonKey -> { areaIds = set, entrance = { mapID, x, y } }
local dungeonIndex

local function BuildDungeonIndex()
    if dungeonIndex then return dungeonIndex end
    local zoneDB = QuestieModule("ZoneDB")
    local ok, dungeons = false, nil
    if zoneDB and zoneDB.GetDungeons then ok, dungeons = pcall(zoneDB.GetDungeons, zoneDB) end
    if not ok or type(dungeons) ~= "table" then
        local private = ZoneSupport()
        dungeons = private and type(private.dungeons) == "table" and private.dungeons or nil
    end
    if type(dungeons) ~= "table" then return nil end
    dungeonIndex = {}
    for areaId, entry in pairs(dungeons) do
        local key = ns.DungeonKeyForName and ns.DungeonKeyForName(entry[1])
        if key then
            local info = dungeonIndex[key] or { areaIds = {} }
            info.areaIds[areaId] = true
            for _, alt in ipairs(entry[2] or {}) do info.areaIds[alt] = true end
            local first = entry[4] and entry[4][1]
            if first and not info.entrance then
                local mapID = UiMapForArea(first[1])
                if mapID then
                    local x, y = ForeverCoords(first[1], first[2], first[3])
                    info.entrance = { mapID = mapID, x = x, y = y }
                end
            end
            dungeonIndex[key] = info
        end
    end
    return dungeonIndex
end

function ns.QuestieEntrance(dungeonKey)
    local index = BuildDungeonIndex()
    return index and index[dungeonKey] and index[dungeonKey].entrance
end

---------------------------------------------------------------------------
-- One background pass over every quest, building:
--   questGivers:   every quest whose giver has a known spot, for the quest finder
--   dungeonQuests: dungeonKey -> quests Questie files under that dungeon
---------------------------------------------------------------------------

local SCAN_BUDGET_MS = 3 -- work per frame, so the scan never causes a stutter
local MAX_EMPTY_SCANS = 5
local emptyScans = 0
ns.questieScanStats = {}

function ScanQuests(onDone)
    if questGivers then return onDone() end
    table.insert(scanWaiters, onDone)
    if scanning then return end
    local l = Lib()
    if not l then return end

    local areaToKey = {}
    for key, info in pairs(BuildDungeonIndex() or {}) do
        for areaId in pairs(info.areaIds) do areaToKey[areaId] = key end
    end

    local ok, ids = pcall(l.Quest.GetAllIds)
    if not ok or type(ids) ~= "table" then return end
    scanning = true
    local givers, byDungeon, i = {}, {}, 1
    local stats = { quests = #ids, named = 0, withStarter = 0, located = 0 }
    local faction = MyFaction()
    local clock = debugprofilestop or function() return GetTime() * 1000 end

    local function ScanOne(id)
        if Hidden(id) then return end
        local title = Get("Quest", id, "name")
        if not title then return end
        stats.named = stats.named + 1
        local startedBy = Get("Quest", id, "startedBy")
        local starter = type(startedBy) == "table" and Locate(startedBy[1], startedBy[2], faction)
        if starter then stats.withStarter = stats.withStarter + 1 end
        local fromItem = type(startedBy) == "table" and startedBy[3] and startedBy[3][1]
        local level = Get("Quest", id, "questLevel")
        local zoneOrSort = Get("Quest", id, "zoneOrSort")
        local key = areaToKey[zoneOrSort]
        if type(zoneOrSort) == "number" and zoneOrSort > 0 and not key then
            areaQuests[zoneOrSort] = areaQuests[zoneOrSort] or {}
            table.insert(areaQuests[zoneOrSort], id)
        end
        -- items: what each quest needs, and items that start quests
        local function Uses(itemId)
            if type(itemId) ~= "number" or itemId <= 0 then return end
            local list = itemUses[itemId]
            if not list then
                list = {}
                itemUses[itemId] = list
            end
            if list[#list] ~= id then list[#list + 1] = id end
        end
        local objectives = Get("Quest", id, "objectives")
        local itemObjectives = type(objectives) == "table" and objectives[3]
        for _, o in ipairs(type(itemObjectives) == "table" and itemObjectives or {}) do
            Uses(type(o) == "table" and o[1] or o)
        end
        local sourceItems = Get("Quest", id, "requiredSourceItems")
        for _, itemId in ipairs(type(sourceItems) == "table" and sourceItems or {}) do Uses(itemId) end
        Uses(Get("Quest", id, "sourceItemId"))
        -- the chain: this quest follows each of its prerequisites
        for _, field in ipairs({ "preQuestSingle", "preQuestGroup" }) do
            local pre = Get("Quest", id, field)
            for _, preId in ipairs(type(pre) == "table" and pre or {}) do
                local list = nextOf[preId]
                if not list then
                    list = {}
                    nextOf[preId] = list
                end
                if list[#list] ~= id then list[#list + 1] = id end
            end
        end
        for _, itemId in ipairs(type(startedBy) == "table" and type(startedBy[3]) == "table" and startedBy[3] or {}) do
            if not itemStarts[itemId] then itemStarts[itemId] = id end
        end

        if key and (starter or fromItem) then
            byDungeon[key] = byDungeon[key] or {}
            table.insert(byDungeon[key], { title = title, level = level, questieId = id })
        end
        local entry = { id = id, title = title, level = level, requiredLevel = Get("Quest", id, "requiredLevel"),
                        dungeonKey = key }
        if starter then
            entry.giver, entry.kind, entry.mapID, entry.x, entry.y = starter.giver, starter.kind, starter.mapID, starter.x, starter.y
            -- every NPC / object that starts it, for finding the nearest spawn later
            entry.npcIds, entry.objectIds = startedBy[1], startedBy[2]
        elseif fromItem then
            local itemName = Get("Item", fromItem, "name")
            entry.giver, entry.kind = itemName and ("Item: " .. itemName) or "An item", "item"
        end
        if entry.mapID then
            stats.located = stats.located + 1
            givers[#givers + 1] = entry
            giversById[id] = entry
        end
        -- one entry per title: prefer the version whose giver has a position (your faction's)
        local norm = NormalTitle(title)
        local existing = giversByTitle[norm]
        if not existing or (not existing.mapID and entry.mapID) then giversByTitle[norm] = entry end
    end

    local function Step()
        local stopAt = clock() + SCAN_BUDGET_MS
        while i <= #ids and clock() < stopAt do
            ScanOne(ids[i])
            i = i + 1
        end
        if i <= #ids then
            C_Timer.After(0, Step)
        elseif #givers == 0 and emptyScans < MAX_EMPTY_SCANS then
            -- nothing could be placed on a map: Questie wasn't really ready. Start over shortly
            emptyScans = emptyScans + 1
            ns.questieScanStats = stats
            scanning = false
            wipe(giversByTitle)
            wipe(giversById)
            wipe(itemUses)
            wipe(itemStarts)
            wipe(nextOf)
            wipe(areaQuests)
            C_Timer.After(10, function()
                if scanWaiters[1] then ScanQuests(table.remove(scanWaiters, 1)) end
            end)
        else
            ns.questieScanStats = stats
            questGivers, dungeonQuests, scanning = givers, byDungeon, false
            local waiters = scanWaiters
            scanWaiters = {}
            for _, fn in ipairs(waiters) do pcall(fn) end
        end
    end
    Step()
end
-- Quests Questie files under this dungeon, or nil while the scan is still running
function ns.QuestieDungeonQuests(dungeonKey)
    if not Lib() then return nil end
    if dungeonQuests then return dungeonQuests[dungeonKey] or {} end
    ScanQuests(function()
        if ns.ClearJournalQuestCache then ns.ClearJournalQuestCache() end
        if ns.RefreshJournal then ns.RefreshJournal() end
    end)
    return nil
end

-- Every quest with a known giver spot, or nil while the scan runs (onReady fires after)
function ns.QuestieQuestGivers(onReady)
    if not Lib() then return nil end
    if questGivers then return questGivers end
    ScanQuests(onReady or function() end)
    return nil
end

-- Quests that need this item (objectives and items the quest relies on), or nil
function ns.QuestieItemUses(itemId)
    return itemUses[itemId]
end

-- The quest this item starts, or nil
function ns.QuestieItemStarts(itemId)
    return itemStarts[itemId]
end

-- Any QuestieDB field: ns.QuestieGet("Npc", id, "name"), or nil without QuestieDB
function ns.QuestieGet(datatype, id, field)
    return Get(datatype, id, field)
end

function ns.QuestieQuestName(questId)
    return Get("Quest", questId, "name")
end

function ns.QuestieGiverById(questId)
    return giversById[questId]
end

-- The quests Questie currently shows as "!" on your map (its own level range,
-- quest log, completion and requirement checks), or nil if it hasn't worked
-- them out yet
function ns.QuestieAvailableSet()
    local module = QuestieModule("AvailableQuests")
    local set = module and rawget(module, "__availableQuests")
    if type(set) ~= "table" or next(set) == nil then return nil end
    return set
end

---------------------------------------------------------------------------
-- Distances: every spawn of a quest giver, in world yards
---------------------------------------------------------------------------
-- Questie's copy of HereBeDragons: its own map sizes, proven on this client
-- (it's what Questie uses for every distance it shows)
local function Dragons()
    local stub = rawget(_G, "LibStub")
    return stub and stub("HereBeDragonsQuestie-2.0", true) or nil
end

local function Plain(...)
    for i = 1, select("#", ...) do
        if ns.IsSecret((select(i, ...))) then return false end
    end
    return true
end

-- uiMap + (0-100 coords) -> continent, world x, world y (yards)
local function WorldPos(mapID, x, y)
    if not (mapID and x and y) then return nil end
    local hbd = Dragons()
    if hbd then
        local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, x / 100, y / 100, mapID)
        if ok and wx and instance and Plain(wx, wy, instance) then return instance, wx, wy end
        return nil -- don't mix in another coordinate system
    end
    if not (C_Map.GetWorldPosFromMapPos and CreateVector2D) then return nil end
    local ok, continent, pos = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(x / 100, y / 100))
    if not ok or not continent or not pos or ns.IsSecret(continent) then return nil end
    local wx, wy = pos:GetXY()
    if ns.IsSecret(wx) then return nil end
    return continent, wx, wy
end

-- Where you are in the same world yards: continent, x, y (nil if unknown)
function ns.PlayerWorldPos()
    local hbd = Dragons()
    if hbd then
        local ok, wx, wy, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
        if ok and wx and instance and Plain(wx, wy, instance) then return instance, wx, wy end
        local ok2, zx, zy, mapID = pcall(hbd.GetPlayerZonePosition, hbd)
        if ok2 and zx and mapID and Plain(zx, zy, mapID) then return WorldPos(mapID, zx * 100, zy * 100) end
    end
    local mapID = ns.Safe(C_Map.GetBestMapForUnit, "player")
    local pos = mapID and ns.Safe(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos then return nil end
    local ok, x, y = pcall(pos.GetXY, pos)
    if not ok or not x or ns.IsSecret(x) then return nil end
    return WorldPos(mapID, x * 100, y * 100)
end
ns.WorldPos = WorldPos

-- QuestieDB spawns ({ [areaId] = { {x, y}, ... } }) added to a list of
-- { mapID, x, y, continent, wx, wy } on Forever's maps
local function AddSpawnSpots(spots, spawns)
    if type(spawns) ~= "table" then return end
    for areaId, coords in pairs(spawns) do
        local mapID = UiMapForArea(areaId)
        if mapID and type(coords) == "table" then
            for _, c in ipairs(coords) do
                if c[1] and c[2] and c[1] >= 0 and c[2] >= 0 then
                    local x, y = ForeverCoords(areaId, c[1], c[2])
                    local continent, wx, wy = WorldPos(mapID, x, y)
                    spots[#spots + 1] = { mapID = mapID, x = x, y = y, continent = continent, wx = wx, wy = wy }
                end
            end
        end
    end
end

-- Spots for a raw QuestieDB spawn table (e.g. an "explore" objective's area)
function ns.SpotsFromSpawns(spawns)
    local spots = {}
    AddSpawnSpots(spots, spawns)
    return spots
end

-- Every spot an NPC or object stands at, cached: ns.QuestieSpawnSpots("Npc", id)
local spawnSpotCache = {}
function ns.QuestieSpawnSpots(datatype, id)
    if not id then return {} end
    local key = datatype .. ":" .. id
    local cached = spawnSpotCache[key]
    if cached then return cached end
    local spots = {}
    AddSpawnSpots(spots, Get(datatype, id, "spawns"))
    spawnSpotCache[key] = spots
    return spots
end

-- The closest of some spots to a world position: spot, yards (nil if none on this continent)
function ns.NearestSpot(spots, continent, wx, wy)
    if not (continent and wx and wy) then return nil end
    local best, bestDist
    for _, s in ipairs(spots or {}) do
        if s.continent and s.continent == continent then
            local d = math.sqrt((s.wx - wx) ^ 2 + (s.wy - wy) ^ 2)
            if not bestDist or d < bestDist then best, bestDist = s, d end
        end
    end
    return best, bestDist
end

-- All the places this quest can be picked up: { mapID, x, y, continent, wx, wy }
local function Spots(entry)
    if entry.spots then return entry.spots end
    local spots, faction = {}, MyFaction()
    local function Add(spawns) AddSpawnSpots(spots, spawns) end
    for _, npcId in ipairs(entry.npcIds or {}) do
        if FriendlyTo(Get("Npc", npcId, "friendlyToFaction"), faction) then Add(Get("Npc", npcId, "spawns")) end
    end
    for _, objectId in ipairs(entry.objectIds or {}) do Add(Get("Object", objectId, "spawns")) end
    if #spots == 0 and entry.mapID then
        local continent, wx, wy = WorldPos(entry.mapID, entry.x, entry.y)
        spots[1] = { mapID = entry.mapID, x = entry.x, y = entry.y, continent = continent, wx = wx, wy = wy }
    end
    entry.spots = spots
    return spots
end

-- The closest spot to a world position and its distance in yards (nil when
-- every spot is on another continent)
function ns.QuestieNearestSpot(entry, continent, wx, wy)
    -- quick check on the main spawn first, so quests on other continents never
    -- need their full spawn list worked out
    if entry.continent == nil then entry.continent = WorldPos(entry.mapID, entry.x, entry.y) or false end
    if entry.continent and entry.continent ~= continent and not entry.spots then return nil end
    local best, bestDist
    for _, s in ipairs(Spots(entry)) do
        if s.continent and s.continent == continent then
            local d = math.sqrt((s.wx - wx) ^ 2 + (s.wy - wy) ^ 2)
            if not bestDist or d < bestDist then best, bestDist = s, d end
        end
    end
    return best, bestDist
end

-- Our own check from QuestieDB's quest data, for when Questie isn't running:
-- done already (the server's record), race, class, level, prerequisites and
-- quests that rule each other out
-- Is bit n (0 = the lowest) set in a mask? Plain arithmetic, not bit.band:
-- the game's bit library only works on 32 bits, and QuestieDB's masks for
-- Forever's races go past that (Skyborne is bit 33), so band gives wrong answers
local function HasBit(mask, n)
    return math.floor(mask / 2 ^ n) % 2 == 1
end

-- any of the bits of `bits` (a small mask) set in `mask`?
local function AnyBit(mask, bits)
    for n = 0, 31 do
        if HasBit(bits, n) and HasBit(mask, n) then return true end
    end
    return false
end

local function Done(questId)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, questId)
        if ok and done == true then return true end
    end
    return ns.cdb and ns.cdb.quests and ns.cdb.quests[questId] ~= nil or false
end

local function FitsMask(mask, id)
    if type(mask) ~= "number" or mask == 0 or not id then return true end
    return HasBit(mask, id - 1)
end

local function QuestName(id)
    return format("%s (%d)", Get("Quest", id, "name") or "?", id)
end

-- false plus the reason when you can't take it
-- QuestieDB's race masks only know the eight Classic races (bit = race ID).
-- Forever's new races have IDs beyond those, so for them check the faction
-- instead: a quest for "any Horde race" is one for you too
local CLASSIC_RACE_BITS = 0xFF
local FACTION_RACES = { Alliance = 1 + 4 + 8 + 64, Horde = 2 + 16 + 32 + 128 }
-- Forever's Skyborne in QuestieDB's masks: bit 33 Horde, bit 34 Alliance
local SKYBORNE_BIT = { Horde = 33, Alliance = 34 }

local function FitsRace(mask)
    if type(mask) ~= "number" or mask == 0 then return true end
    local raceID = select(3, UnitRace("player"))
    -- the eight Classic races: their own bit
    if raceID and raceID >= 1 and raceID <= 8 then return HasBit(mask, raceID - 1) end
    -- Skyborne (and any other new race): named outright, or "any race of your faction"
    local faction = UnitFactionGroup("player") or ""
    local sky = SKYBORNE_BIT[faction]
    if sky and HasBit(mask, sky) then return true end
    if not AnyBit(mask, CLASSIC_RACE_BITS) then
        -- names only new races: yours if it doesn't name the other faction's Skyborne alone
        local other = SKYBORNE_BIT[faction == "Horde" and "Alliance" or "Horde"]
        return not (other and HasBit(mask, other) and not (sky and HasBit(mask, sky)))
    end
    local races = FACTION_RACES[faction]
    return not races or AnyBit(mask, races)
end

local function OwnDoable(questId)
    if Done(questId) then return false, "already completed" end
    local required = Get("Quest", questId, "requiredLevel") or 0
    if required > UnitLevel("player") then return false, "needs level " .. required end
    local races = Get("Quest", questId, "requiredRaces")
    if not FitsRace(races) then
        return false, format("not for your race (mask %s, your race id %s)", tostring(races), tostring(select(3, UnitRace("player"))))
    end
    local classes = Get("Quest", questId, "requiredClasses")
    if not FitsMask(classes, select(3, UnitClass("player"))) then
        return false, format("not for your class (mask %s, your class id %s)", tostring(classes), tostring(select(3, UnitClass("player"))))
    end
    local single = Get("Quest", questId, "preQuestSingle")
    if type(single) == "table" and #single > 0 then
        local any = false
        for _, id in ipairs(single) do if Done(id) then any = true break end end
        if not any then
            local names = {}
            for _, id in ipairs(single) do names[#names + 1] = QuestName(id) end
            return false, "needs one of: " .. table.concat(names, ", ")
        end
    end
    local group = Get("Quest", questId, "preQuestGroup")
    for _, id in ipairs(type(group) == "table" and group or {}) do
        if not Done(id) then return false, "needs " .. QuestName(id) .. " first" end
    end
    local exclusive = Get("Quest", questId, "exclusiveTo")
    for _, id in ipairs(type(exclusive) == "table" and exclusive or {}) do
        if Done(id) then return false, "you did " .. QuestName(id) .. " instead" end
    end
    return true
end
ns.QuestDone = Done

-- Whether a quest is for your race and class at all (not level or prerequisites)
function ns.QuestieFitsYou(questId)
    if not Lib() then return nil end
    if not FitsRace(Get("Quest", questId, "requiredRaces")) then return false end
    return FitsMask(Get("Quest", questId, "requiredClasses"), select(3, UnitClass("player")))
end

ns.QuestieWhyNot = function(questId)
    local ok, why = OwnDoable(questId)
    return not ok and why or nil
end

-- The first quest you can take in the chain leading to this one, walking back
-- through its prerequisites (all of a group, any one of a "single" list).
-- Returns that quest's ID, or nil when nothing earlier is missing.
local MAX_CHAIN_DEPTH = 20

local function ChainStart(questId, depth, visited)
    if depth > MAX_CHAIN_DEPTH or visited[questId] then return nil end
    visited[questId] = true
    local missing = {}
    local group = Get("Quest", questId, "preQuestGroup")
    for _, id in ipairs(type(group) == "table" and group or {}) do
        if not Done(id) then missing[#missing + 1] = id end
    end
    local single = Get("Quest", questId, "preQuestSingle")
    if type(single) == "table" and #single > 0 then
        local any = false
        for _, id in ipairs(single) do if Done(id) then any = true break end end
        if not any then
            -- any one will do: try the ones with a giver you can reach first
            local options = {}
            for _, id in ipairs(single) do options[#options + 1] = id end
            table.sort(options, function(a, b) return (giversById[a] and 0 or 1) < (giversById[b] and 0 or 1) end)
            for _, id in ipairs(options) do missing[#missing + 1] = id end
        end
    end
    for _, id in ipairs(missing) do
        if OwnDoable(id) and not visited[id] then return id end
        local deeper = ChainStart(id, depth + 1, visited)
        if deeper then return deeper end
    end
    return nil
end

-- A quest meant for you at all: not hidden, and your race and class
local function ForYou(questId)
    if Hidden(questId) then return false end
    if not FitsRace(Get("Quest", questId, "requiredRaces")) then return false end
    return FitsMask(Get("Quest", questId, "requiredClasses"), select(3, UnitClass("player")))
end

-- Base XP for a quest, from QuestieDB's XP table (what you'd get at its level)
local questXP
function ns.QuestieXP(questId)
    if questXP == nil then
        local l = Lib()
        local support = l and type(l.Support) == "table" and l.Support.Get and l.Support.Get("QuestXP")
        questXP = support and type(support.db) == "table" and support.db or false
    end
    local row = questXP and questXP[questId]
    return type(row) == "table" and row[2] or nil
end

-- Where this quest leads: { titles = next few in order, count = quests after
-- it, xp = their total base XP }, or nil when it isn't part of a chain
local MAX_CHAIN_AHEAD = 40
local chainAheadCache = {} -- questId -> result or false; chains don't change in a session

local function ChainAhead(questId)
    local seen, queue, titles = { [questId] = true }, { questId }, {}
    local count, xp, head = 0, 0, 1
    while head <= #queue and count < MAX_CHAIN_AHEAD do
        local current = queue[head]
        head = head + 1
        local firstOnPath = true
        for _, nextId in ipairs(nextOf[current] or {}) do
            if not seen[nextId] and ForYou(nextId) then
                seen[nextId] = true
                count = count + 1
                xp = xp + (ns.QuestieXP(nextId) or 0)
                queue[#queue + 1] = nextId
                -- the straight line onwards: the first follow-up of each step
                if firstOnPath and #titles < 4 and (current == questId or titles[#titles] == current) then
                    titles[#titles + 1] = nextId
                    firstOnPath = false
                end
            end
        end
    end
    if count == 0 then return nil end
    local names = {}
    for i, id in ipairs(titles) do names[i] = Get("Quest", id, "name") or ("quest " .. id) end
    return { titles = names, count = count, xp = xp }
end

function ns.QuestieChainAhead(questId)
    if not questId or not next(nextOf) then return nil end -- the scan hasn't finished
    local cached = chainAheadCache[questId]
    if cached == nil then
        cached = ChainAhead(questId) or false
        chainAheadCache[questId] = cached
    end
    return cached or nil
end

-- Each zone's quests meant for you (a giver of your faction, your race and
-- class) and how many you've done: { { areaId, name, done, total } }, or nil
-- before the scan has finished. Zones with only a handful of quests are left out.
local MIN_ZONE_QUESTS = 5
function ns.QuestieZoneProgress()
    if not next(areaQuests) then return nil end
    local out = {}
    for areaId, ids in pairs(areaQuests) do
        local total, done = 0, 0
        for _, id in ipairs(ids) do
            if giversById[id] and ForYou(id) then
                total = total + 1
                if Done(id) then done = done + 1 end
            end
        end
        if total >= MIN_ZONE_QUESTS then
            local ok, name = pcall(C_Map.GetAreaInfo, areaId)
            out[#out + 1] = { areaId = areaId, name = ok and name or ("Zone " .. areaId), done = done, total = total }
        end
    end
    return out
end

-- How many quest chains of at least minLength steps you've finished (the last
-- quest done, counting the done quests before it), or nil before the scan
function ns.QuestieChainsCompleted(minLength)
    if not next(nextOf) then return nil end
    local memo = {}
    local function Length(id, depth)
        if memo[id] then return memo[id] end
        memo[id] = 1 -- guards against loops in the data
        if depth > MAX_CHAIN_DEPTH then return 1 end
        local best = 0
        for _, field in ipairs({ "preQuestGroup", "preQuestSingle" }) do
            local pre = Get("Quest", id, field)
            for _, preId in ipairs(type(pre) == "table" and pre or {}) do
                if Done(preId) then best = math.max(best, Length(preId, depth + 1)) end
            end
        end
        memo[id] = 1 + best
        return memo[id]
    end
    local function ChainEnd(id)
        for _, nextId in ipairs(nextOf[id] or {}) do
            if ForYou(nextId) then return false end
        end
        return true
    end
    local count = 0
    for id in pairs(ns.cdb.quests or {}) do
        if type(id) == "number" and nextOf and Done(id) and ChainEnd(id) and Length(id, 0) >= minLength then
            count = count + 1
        end
    end
    return count
end

function ns.QuestieChainStart(questId)
    if not Lib() or not questId then return nil end
    return ChainStart(questId, 0, {})
end

-- Whether you can take a quest right now: Questie's own verdict when it's
-- running (it also knows reputation and professions), otherwise our check
function ns.QuestieIsDoable(questId)
    local db = QuestieReady() and QuestieModule("QuestieDB")
    if db and db.IsDoable then
        local ok, doable = pcall(db.IsDoable, questId)
        if ok then return doable and true or false end
    end
    if not Lib() then return nil end
    return OwnDoable(questId)
end

---------------------------------------------------------------------------
-- Mobs by zone, for grind spots: one background pass over every NPC
---------------------------------------------------------------------------
local mobsByArea           -- areaId -> { { id, name, min, max, count } }
local mobScanWaiters = {}
local mobScanning = false

-- hostile to everyone, a normal (not elite) mob, and a level we can use
local function GrindableMob(id)
    if Get("Npc", id, "friendlyToFaction") ~= nil then return nil end
    local rank = Get("Npc", id, "rank")
    if rank and rank ~= 0 then return nil end
    local minLevel, maxLevel = Get("Npc", id, "minLevel"), Get("Npc", id, "maxLevel")
    if type(minLevel) ~= "number" or minLevel < 2 then return nil end
    return minLevel, (type(maxLevel) == "number" and maxLevel or minLevel)
end

local function ScanMobs(onDone)
    if mobsByArea then return onDone() end
    table.insert(mobScanWaiters, onDone)
    if mobScanning then return end
    local l = Lib()
    if not l or not l.Npc or not l.Npc.GetAllIds then return end
    local ok, ids = pcall(l.Npc.GetAllIds)
    if not ok or type(ids) ~= "table" then return end
    mobScanning = true
    local byArea, i = {}, 1
    local clock = debugprofilestop or function() return GetTime() * 1000 end
    local function Step()
        local stopAt = clock() + SCAN_BUDGET_MS
        while i <= #ids and clock() < stopAt do
            local id = ids[i]
            i = i + 1
            local minLevel, maxLevel = GrindableMob(id)
            if minLevel then
                local spawns = Get("Npc", id, "spawns")
                if type(spawns) == "table" then
                    for areaId, coords in pairs(spawns) do
                        if type(coords) == "table" and #coords > 0 then
                            byArea[areaId] = byArea[areaId] or {}
                            table.insert(byArea[areaId], { id = id, min = minLevel, max = maxLevel, count = #coords })
                        end
                    end
                end
            end
        end
        if i <= #ids then
            C_Timer.After(0, Step)
        else
            mobsByArea, mobScanning = byArea, false
            local waiters = mobScanWaiters
            mobScanWaiters = {}
            for _, fn in ipairs(waiters) do pcall(fn) end
        end
    end
    Step()
end

-- Grindable mobs in an area, or nil while the background pass runs (onReady fires after)
function ns.QuestieMobsInArea(areaId, onReady)
    if not Lib() then return nil end
    if mobsByArea then return mobsByArea[areaId] or {} end
    ScanMobs(onReady or function() end)
    return nil
end

-- uiMap -> QuestieDB area ID (the zone), from QuestieDB's Forever tables
local mapAreas
function ns.AreaForMap(mapID)
    if mapAreas == nil then
        local private = ZoneSupport()
        local base = private and Decode(private.uiMapIdToAreaId)
        if base then
            for uiMap, areaId in pairs(Decode(private.uiMapIdToAreaIdOverride) or {}) do base[uiMap] = areaId end
        end
        mapAreas = base or false
    end
    return mapAreas and mapAreas[mapID] or nil
end

---------------------------------------------------------------------------
-- Items
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Looking things up by name
--
-- QuestieDB's first IdsByName call for a type builds an index of every name
-- (28,000 items, 13,000 NPCs) in one go - long enough to trip "script ran too
-- long". So the indexes are built here a slice per frame (BuildNameIndexAsync,
-- in our own coroutine) shortly after login; until a type's index is ready,
-- lookups say "not yet" rather than build it on the spot.
---------------------------------------------------------------------------
local NAME_TYPES = { "Npc", "Item", "Object", "Quest" }
local NAMES_PER_FRAME = 300
local namesReady = {}    -- datatype -> true once its index is built
local namesBuilding = false

local function BuildNameIndexes()
    local l = Lib()
    if namesBuilding or not l then return end
    namesBuilding = true
    local job = coroutine.create(function()
        for _, datatype in ipairs(NAME_TYPES) do
            local db = l[datatype]
            if db and db.BuildNameIndexAsync then
                db.BuildNameIndexAsync(NAMES_PER_FRAME)
                namesReady[datatype] = true
            end
        end
    end)
    local ticker
    ticker = C_Timer.NewTicker(0.01, function()
        local ok = coroutine.resume(job)
        if not ok or coroutine.status(job) == "dead" then
            ticker:Cancel()
            -- an older QuestieDB without the async build (or a failed one): fall back to its own lazy build
            for _, datatype in ipairs(NAME_TYPES) do
                if not ok or not (l[datatype] and l[datatype].BuildNameIndexAsync) then namesReady[datatype] = true end
            end
        end
    end)
end

-- QuestieDB IDs with exactly this name ("Npc", "Item", "Object" or "Quest"), or nil.
-- Second result true: the name index isn't ready yet - ask again later, and
-- don't remember the miss.
function ns.QuestieIdsByName(datatype, name)
    local l = Lib()
    local db = l and l[datatype]
    if type(name) ~= "string" or not (db and db.IdsByName) then return nil end
    if db.BuildNameIndexAsync and not namesReady[datatype] then
        BuildNameIndexes()
        return nil, true
    end
    local ok, ids = pcall(db.IdsByName, name)
    return ok and type(ids) == "table" and ids or nil
end

table.insert(ns.inits, function()
    ns.On("PLAYER_LOGIN", function() C_Timer.After(8, BuildNameIndexes) end)
end)

local itemIdCache = {}

-- Item ID for an exact item name, for loot that was published without IDs
function ns.QuestieItemId(name)
    if not name or name == "" then return nil end
    if itemIdCache[name] ~= nil then return itemIdCache[name] or nil end
    local ids, pending = ns.QuestieIdsByName("Item", name)
    if pending then return nil end -- ask again once the index is built
    local id = ids and ids[1]
    itemIdCache[name] = id or false
    return id
end

-- Item level and required level, for items the game won't describe yet
function ns.QuestieItemLevels(itemID)
    if not itemID or itemID == 0 or not Lib() then return nil end
    return Get("Item", itemID, "itemLevel"), Get("Item", itemID, "requiredLevel")
end

function ns.QuestieStatus()
    if not rawget(_G, "LibQuestieDB") then return "Questie isn't installed (or not enabled)." end
    if not Lib() then
        return format("Questie's database is a different version than this addon expects (needs contract %d).", CONTRACT)
    end
    local index = BuildDungeonIndex()
    local dungeons = 0
    for _ in pairs(index or {}) do dungeons = dungeons + 1 end
    return format("Connected to Questie's database. %d of the journal's dungeons have Questie entrances.", dungeons)
end

-- Read Questie's quests in the background soon after login, so the journal and
-- quest finder have everything ready before they're opened
local BACKGROUND_SCAN_DELAY = 8
table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReload)
        if not (isInitialLogin or isReload) then return end
        C_Timer.After(BACKGROUND_SCAN_DELAY, function()
            if Lib() then ScanQuests(function() if ns.ClearJournalQuestCache then ns.ClearJournalQuestCache() end end) end
        end)
    end)
end)
