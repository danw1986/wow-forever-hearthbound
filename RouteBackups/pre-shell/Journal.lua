local ADDON_NAME, ns = ...

-- Dungeon journal: quests (with map markers), bosses and loot for every
-- dungeon in ns.DUNGEONS, plus what it learns as you play:
--   * accepting a dungeon quest records the quest giver and where you stood
--   * loot you see inside a dungeon is recorded under the mob that dropped it
--   * loot is also read from the game's Encounter Journal when it has data
-- Learned data is account-wide (db.journal) so alts share it.

local format = string.format
local Safe = ns.Safe

local PAD = 22
local PAGE_W = ns.UI.width
local INNER_W = PAGE_W - PAD * 2
local CONTENT_W = INNER_W - 30  -- the dungeon page's scroll area, inside its border
local CELL_GAP = 8              -- loot grid: two item cells per row
local CELL_W = (CONTENT_W - CELL_GAP) / 2
local CELL_H = 38
local CARD_COLS, CARD_GAP, CARD_H = 3, 10, 92 -- dungeon browser cards
local CARD_W = (INNER_W - 14 - CARD_GAP * (CARD_COLS - 1)) / CARD_COLS
local BANNER_H = 86

-- Encounter Journal instance IDs (from Atlas's Classic Era data; sm and strat
-- are their retail IDs). Used only to fetch Blizzard's dungeon artwork.
local JOURNAL_IDS = {
    rfc = 226, wc = 240, dm = 63, sfk = 64, bfd = 227, stocks = 238, gnomer = 231, rfk = 234,
    sm = 316, rfd = 233, ulda = 239, zf = 241, mara = 232, st = 237, brd = 228, lbrs = 229,
    ubrs = 559, diremaul = 230, scholo = 246, strat = 236,
}

local FACTION_COLOR = { A = "6f9cff", H = "ff5544" }

---------------------------------------------------------------------------
-- Lookups
---------------------------------------------------------------------------
local byKey, byName = {}, {}

local function Normalize(name)
    return name and name:lower():gsub("^the ", "") or nil
end

local function IndexDungeons()
    for _, d in ipairs(ns.DUNGEONS) do
        byKey[d.key] = d
        byName[Normalize(d.name)] = d.key
    end
    for alias, key in pairs(ns.DUNGEON_ALIASES) do byName[Normalize(alias)] = key end
end

function ns.DungeonKeyForName(name)
    return name and byName[Normalize(name)]
end

local function Journal()
    return ns.db.journal
end

local function Learned(kind, key)
    local t = Journal()[kind]
    t[key] = t[key] or {}
    return t[key]
end

---------------------------------------------------------------------------
-- Map markers
---------------------------------------------------------------------------
local mapIndex

-- uiMapID for a zone name, found by walking the game's own map tree
-- Short names people (and guides) use for zones, and the map they belong to.
-- Coordinates given for a town are in its zone's map (Kargath -> Badlands).
local ZONE_ALIASES = {
    ["stormwind"] = "Stormwind City", ["hillsbrad"] = "Hillsbrad Foothills", ["redridge"] = "Redridge Mountains",
    ["kargath"] = "Badlands", ["booty bay"] = "Stranglethorn Vale", ["theramore"] = "Dustwallow Marsh",
    ["stv"] = "Stranglethorn Vale", ["epl"] = "Eastern Plaguelands", ["wpl"] = "Western Plaguelands",
    ["thousand needles"] = "Thousand Needles", ["hinterlands"] = "The Hinterlands", ["barrens"] = "The Barrens",
    ["ratchet"] = "The Barrens", ["gadgetzan"] = "Tanaris", ["southshore"] = "Hillsbrad Foothills",
    ["sentinel hill"] = "Westfall", ["lakeshire"] = "Redridge Mountains", ["darkshire"] = "Duskwood",
    ["auberdine"] = "Darkshore", ["astranaar"] = "Ashenvale", ["kharanos"] = "Dun Morogh", ["brill"] = "Tirisfal Glades",
}
-- Kalimdor and the Eastern Kingdoms, so the index never depends on where you stand
local ROOT_MAPS = { 1414, 1415, 947 }
local MIN_INDEX_SIZE = 20

local function IndexMapsUnder(root, index)
    local children = Safe(C_Map.GetMapChildrenInfo, root, nil, true)
    if type(children) ~= "table" then return end
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    for _, info in ipairs(children) do
        local key = info.name and info.name:lower()
        -- prefer zone maps over sub-areas with the same name
        if key and (not index[key] or info.mapType == zoneType) then index[key] = info.mapID end
    end
end

-- uiMapID for a zone name (any capitalisation, common short names allowed)
function ns.FindMapID(zoneName)
    if not zoneName or not C_Map or not C_Map.GetMapChildrenInfo then return nil end
    if not mapIndex then
        local index = {}
        for _, root in ipairs(ROOT_MAPS) do IndexMapsUnder(root, index) end
        -- and the world above wherever you are, in case those IDs differ on this client
        local id = Safe(C_Map.GetBestMapForUnit, "player")
        while id do
            local info = Safe(C_Map.GetMapInfo, id)
            if not info or not info.parentMapID or info.parentMapID == 0 then break end
            id = info.parentMapID
        end
        if id then IndexMapsUnder(id, index) end
        local count = 0
        for _ in pairs(index) do count = count + 1 end
        if count < MIN_INDEX_SIZE then return nil end -- try again later rather than keep a broken index
        mapIndex = index
    end
    local key = zoneName:lower()
    return mapIndex[key] or (ZONE_ALIASES[key] and mapIndex[ZONE_ALIASES[key]:lower()])
end

-- WoW's own map pin (the one you get by ctrl-clicking the map): true, or
-- false and why the game wouldn't take it
function ns.SetMapPin(mapID, x, y)
    if not (C_Map and C_Map.SetUserWaypoint) then return false, "this client has no map pins for addons (C_Map.SetUserWaypoint is missing)" end
    if not (UiMapPoint and UiMapPoint.CreateFromCoordinates) then return false, "this client has no UiMapPoint" end
    if C_Map.CanSetUserWaypointOnMap and not Safe(C_Map.CanSetUserWaypointOnMap, mapID) then
        return false, "the game says pins can't go on that map (" .. tostring(mapID) .. ")"
    end
    local ok, err = pcall(function()
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x / 100, y / 100))
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(true) -- the on-screen arrow
        end
    end)
    if not ok then return false, "the game refused it: " .. tostring(err) end
    return true
end

-- x, y are 0-100. pinOnly: WoW's own map pin and nothing else (no TomTom, no
-- Hearthbound marker) - if the game won't place it, just say where it is
function ns.SetWaypoint(mapID, x, y, title, pinOnly)
    local placed, why = false, nil
    if not pinOnly and TomTom and TomTom.AddWaypoint then
        placed = pcall(TomTom.AddWaypoint, TomTom, mapID, x / 100, y / 100, { title = title })
    end
    local pinned
    pinned, why = ns.SetMapPin(mapID, x, y)
    placed = placed or pinned
    local info = Safe(C_Map.GetMapInfo, mapID)
    local where = info and info.name or "?"
    if placed then
        ns.Print(format("Marked |cffffd200%s|r on your map: %s %.1f, %.1f", title, where, x, y))
    elseif pinOnly then
        ns.Print(format("%s: %s %.1f, %.1f |cff999999(couldn't place a map pin - %s)|r", title, where, x, y, why or "?"))
    elseif ns.SetGuideMarker and ns.SetGuideMarker(mapID, x, y, title) then
        -- the game won't take a waypoint from addons here: use Hearthbound's own marker
        ns.Print(format("Marked |cffffd200%s|r: %s %.1f, %.1f - the guide arrow points there (click the green pin to clear it).",
            title, where, x, y))
    else
        ns.Print(format("%s: %s %.1f, %.1f |cff999999(no map position to mark)|r", title, where, x, y))
    end
end

local function PlayerPosition()
    if IsInInstance() then return nil end
    local mapID = Safe(C_Map.GetBestMapForUnit, "player")
    if not mapID then return nil end
    local pos = Safe(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos then return nil end
    local ok, x, y = pcall(pos.GetXY, pos)
    if not ok or not x or ns.IsSecret(x) or (x == 0 and y == 0) then return nil end
    return mapID, x * 100, y * 100
end

---------------------------------------------------------------------------
-- Learning quests
---------------------------------------------------------------------------
local lastGiver -- { name, mapID, x, y } of the NPC whose quest window is open

local function OnQuestDetail()
    local mapID, x, y = PlayerPosition()
    lastGiver = { name = Safe(UnitName, "npc"), mapID = mapID, x = x, y = y }
end

-- Which dungeon a quest belongs to: its quest log heading, or a known title
local function DungeonForQuest(q)
    local key = ns.DungeonKeyForName(q.zone)
    if key then return key end
    local title = q.title and q.title:lower()
    for _, d in ipairs(ns.DUNGEONS) do
        for _, known in ipairs(d.quests or {}) do
            if known.title:lower() == title then return d.key end
        end
    end
end

---------------------------------------------------------------------------
-- Pick-up and hand-in spots for every quest, keyed by lowercase title
---------------------------------------------------------------------------
local PICKUP_RETRIES, RETRY_DELAY = 6, 0.5

function ns.QuestPickup(title)
    return title and ns.db.journal.pickups[title:lower()]
end

function ns.QuestTurnIn(title)
    return title and ns.db.journal.turnins[title:lower()]
end

local function MapName(mapID)
    local info = mapID and Safe(C_Map.GetMapInfo, mapID)
    return info and info.name or nil
end

local function FindOpenQuest(questID)
    for _, q in ipairs(ns.openQuests or {}) do
        if q.id == questID then return q end
    end
end

-- Files a freshly accepted quest: its pick-up spot, and its dungeon if it has one
local function RecordAccepted(questID, q, spot)
    local title = q and q.title or (C_QuestLog and C_QuestLog.GetTitleForQuestID
        and Safe(C_QuestLog.GetTitleForQuestID, questID))
    if not title then return end

    if spot.mapID then
        ns.db.journal.pickups[title:lower()] = {
            id = questID, title = title, giver = spot.giver,
            mapID = spot.mapID, x = spot.x, y = spot.y, zone = MapName(spot.mapID), time = time(),
        }
    end

    local key = q and DungeonForQuest(q)
    if not key then return end
    local quests = Learned("quests", key)
    local isNew = not quests[title]
    quests[title] = {
        id = questID, level = q.level, giver = spot.giver,
        mapID = spot.mapID, x = spot.x, y = spot.y, zone = MapName(spot.mapID),
        faction = ns.PlayerFaction(), learned = time(),
    }
    if isNew then
        ns.Print(format("Added |cffffd200%s|r to the %s journal%s.", title, byKey[key].name,
            spot.mapID and " with a map marker" or ""))
    end
    if ns.RefreshJournal then ns.RefreshJournal() end
end

local function OnQuestAccepted(_, a, b)
    local questID = b or a -- older clients pass (logIndex, questID)
    if ns.IsSecret(questID) or type(questID) ~= "number" then return end

    -- where you're standing right now is where the quest giver is
    local mapID, x, y = PlayerPosition()
    local giver = lastGiver or {}
    local spot = {
        giver = Safe(UnitName, "npc") or giver.name,
        mapID = mapID or giver.mapID, x = mapID and x or giver.x, y = mapID and y or giver.y,
    }
    lastGiver = nil

    -- the quest log can take a moment to show the new quest
    local tries = 0
    local function Try()
        tries = tries + 1
        local q = FindOpenQuest(questID)
        if q or tries >= PICKUP_RETRIES then
            RecordAccepted(questID, q, spot)
        else
            C_Timer.After(RETRY_DELAY, Try)
        end
    end
    C_Timer.After(RETRY_DELAY, Try)
end

local function OnQuestTurnedIn(_, questID)
    if ns.IsSecret(questID) or type(questID) ~= "number" then return end
    local record = ns.cdb.quests and ns.cdb.quests[questID] -- written by Quests.lua just before this
    if not record or not record.title then return end
    local mapID, x, y = PlayerPosition()
    if mapID then
        ns.db.journal.turnins[record.title:lower()] = {
            npc = Safe(UnitName, "npc"), mapID = mapID, x = x, y = y, zone = MapName(mapID), time = time(),
        }
    end
    -- keep the pick-up spot with the completed quest too
    record.pickup = record.pickup or ns.QuestPickup(record.title)
end

---------------------------------------------------------------------------
-- Learning loot
---------------------------------------------------------------------------
local function ItemID(link)
    return link and tonumber(link:match("item:(%d+)"))
end

local function OnLootOpened()
    if not IsInInstance() then return end
    local key = ns.DungeonKeyForName(Safe(GetInstanceInfo))
    if not key then return end
    local source = Safe(UnitName, "target") or "Unknown"
    local loot = Learned("loot", key)
    for i = 1, Safe(GetNumLootItems) or 0 do
        local id = ItemID(Safe(GetLootSlotLink, i))
        local quality = id and C_Item and C_Item.GetItemInfo and select(3, Safe(C_Item.GetItemInfo, id))
        if id and (quality or 0) >= 2 then -- uncommon and better
            loot[source] = loot[source] or {}
            loot[source][id] = (loot[source][id] or 0) + 1
        end
    end
end

---------------------------------------------------------------------------
-- Loot from the game's Encounter Journal (if this client has data in it)
---------------------------------------------------------------------------
local ejCache = {}

local function EncounterJournalLoot(d)
    if ejCache[d.key] ~= nil then return ejCache[d.key] or nil end
    ejCache[d.key] = false
    if not (EJ_GetNumTiers and EJ_SelectTier and EJ_GetInstanceByIndex and EJ_SelectInstance and EJ_GetNumLoot
        and C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex) then
        return nil
    end
    local ok, groups = pcall(function()
        for tier = 1, EJ_GetNumTiers() do
            EJ_SelectTier(tier)
            for _, isRaid in ipairs({ false, true }) do
                local i = 1
                while true do
                    local id, name = EJ_GetInstanceByIndex(i, isRaid)
                    if not id then break end
                    if ns.DungeonKeyForName(name) == d.key then
                        EJ_SelectInstance(id)
                        if EJ_ResetLootFilter then EJ_ResetLootFilter() end
                        local byBoss, order = {}, {}
                        for n = 1, EJ_GetNumLoot() do
                            local info = C_EncounterJournal.GetLootInfoByIndex(n)
                            if info and info.itemID then
                                local boss = info.encounterID and EJ_GetEncounterInfo(info.encounterID) or "Loot"
                                if not byBoss[boss] then
                                    byBoss[boss] = {}
                                    order[#order + 1] = boss
                                end
                                table.insert(byBoss[boss], info.itemID)
                            end
                        end
                        local result = {}
                        for _, boss in ipairs(order) do result[#result + 1] = { boss = boss, items = byBoss[boss] } end
                        return #result > 0 and result or nil
                    end
                    i = i + 1
                end
            end
        end
    end)
    if ok and groups then
        ejCache[d.key] = groups
        return groups
    end
    return nil
end

---------------------------------------------------------------------------
-- Quest status from your history and quest log
---------------------------------------------------------------------------
local doneTitles = {} -- lowercase titles of completed quests, rebuilt each journal redraw

local function QuestStatus(title)
    local lower = title:lower()
    for _, q in ipairs(ns.openQuests or {}) do
        if q.title and q.title:lower() == lower then
            return q.complete and "|cff6fdc6fready to hand in|r" or "|cffffd200in your log|r"
        end
    end
    if doneTitles[lower] then return "|cff6fdc6fdone|r" end
end

---------------------------------------------------------------------------
-- Tab UI
---------------------------------------------------------------------------
local page, browser, dungeonPage, banner, detailScroll, detailContent
local detailRows, cards, tabButtons = {}, {}, {}
local view = "browser"        -- "browser" (dungeon cards) or "page" (one dungeon)
local selectedKey, activeTab = nil, "overview"
local lastSelected, lastTab
local expanded = {} -- "dungeonKey|boss" -> true/false
local IsOpen
local ShowRowTooltip
local lootFilter = { usable = true, slot = 1, boss = nil }
local browserState = { search = "", recommended = false }
local QuestsFor -- defined further down

---------------------------------------------------------------------------
-- Blizzard's dungeon artwork, from the Encounter Journal when this client has
-- it; cards and banners fall back to a colour wash when it doesn't
---------------------------------------------------------------------------
local artCache = {}
local FALLBACK_COLORS = {
    { 0.35, 0.18, 0.12 }, { 0.16, 0.26, 0.34 }, { 0.20, 0.30, 0.18 }, { 0.32, 0.26, 0.12 },
    { 0.26, 0.16, 0.32 }, { 0.14, 0.28, 0.28 }, { 0.34, 0.14, 0.20 }, { 0.22, 0.22, 0.26 },
}

-- Dungeon Finder IDs (from Atlas's Classic Era data), for its dungeon artwork
local FINDER_IDS = {
    wc = 1, scholo = 2, rfc = 3, dm = 5, sfk = 7, bfd = 9, stocks = 11, gnomer = 13, rfk = 15, sm = 17,
    rfd = 19, ulda = 21, zf = 23, mara = 25, st = 27, brd = 29, lbrs = 31, diremaul = 33, strat = 39, ubrs = 43,
}
local FULL = { 0, 1, 0, 1 }

local function Valid(f)
    return f and f ~= 0 and f ~= "" and f or nil
end

-- A picture in Hearthbound\Images for this dungeon (see PhotoData.lua and the backup script)
local function PhotoArt(d)
    local path = ns.PHOTOS and ns.PHOTOS[d.key]
    if not path then return nil end
    -- the banner is a thin strip: Classic pictures are boss line-ups, so show the
    -- upper part where the faces are; the new dungeons' scenery reads best in the middle
    local band = d.new and { 0, 1, 0.34, 0.63 } or { 0, 1, 0.04, 0.33 }
    return { source = "added picture", card = path, cardCoords = FULL, banner = path, bannerCoords = band }
end

-- The Adventure Guide's (Encounter Journal) images and description
local function JournalArt(d)
    local id = JOURNAL_IDS[d.key]
    if not id or not EJ_GetInstanceInfo then return nil end
    local ok, name, description, _, button, lore = pcall(EJ_GetInstanceInfo, id)
    if not ok or not name then return nil end
    button, lore = Valid(button), Valid(lore)
    if not button and not lore then return { description = description } end
    return { source = "Adventure Guide", description = description,
             card = button or lore, cardCoords = button and { 0, 0.68359375, 0, 0.7421875 } or { 0, 0.71, 0.1, 0.6 },
             banner = lore or button, bannerCoords = lore and { 0, 0.71, 0.12, 0.56 } or { 0, 0.68, 0.2, 0.55 } }
end

-- The Dungeon Finder's background picture, found the same way Blizzard's UI does
local function FinderArt(d)
    local id = FINDER_IDS[d.key]
    if not id or not GetLFGDungeonInfo then return nil end
    -- the 11th value is the dungeon's texture name
    local ok, name, _, _, _, _, _, _, _, _, _, texture = pcall(GetLFGDungeonInfo, id)
    if not ok or not name or type(texture) ~= "string" or texture == "" then return nil end
    local file = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-" .. texture
    return { source = "Dungeon Finder", card = file, cardCoords = FULL, banner = file,
             bannerCoords = { 0, 1, 0.25, 0.75 } }
end

-- Best artwork available: your screenshot, then the Adventure Guide, then the Dungeon Finder
-- Only asks the game when there's no picture of our own (keeps the list instant)
local function DungeonArt(d)
    if artCache[d.key] ~= nil then return artCache[d.key] or nil end
    local art = PhotoArt(d)
    if not art then
        local journal = JournalArt(d)
        art = (journal and journal.card and journal) or FinderArt(d)
    end
    artCache[d.key] = art or false
    return art or nil
end

-- Blizzard's description of a dungeon, looked up only when its Overview is shown
local descriptionCache = {}
local function DungeonDescription(d)
    if descriptionCache[d.key] == nil then
        local journal = JournalArt(d)
        descriptionCache[d.key] = journal and journal.description or false
    end
    return descriptionCache[d.key] or nil
end

function ns.DungeonArtSource(key)
    local d = byKey[key]
    local art = d and DungeonArt(d)
    return art and art.source or nil
end

local function FallbackColor(d)
    local sum = 0
    for i = 1, #d.key do sum = sum + d.key:byte(i) end
    return FALLBACK_COLORS[sum % #FALLBACK_COLORS + 1]
end

-- Paints `fill` (a colour wash) and `art` (artwork if any) for a dungeon;
-- which: "card" or "banner"
local function PaintArt(d, fill, art, which)
    local c = FallbackColor(d)
    fill:SetColorTexture(c[1], c[2], c[3], 1)
    local a = DungeonArt(d)
    local file = a and a[which]
    if file then
        art:SetTexture(file)
        art:SetTexCoord(unpack(a[which .. "Coords"] or FULL))
        art:Show()
    else
        art:Hide()
    end
end

---------------------------------------------------------------------------
-- "Usable by me": armour and weapon types each class can use in Classic
---------------------------------------------------------------------------
local ITEM_CLASS_WEAPON, ITEM_CLASS_ARMOR = 2, 4
local CLASS_ARMOR = { -- armour subclasses: 1 cloth, 2 leather, 3 mail, 4 plate, 6 shield
    WARRIOR = { 1, 2, 3, 4, 6 }, PALADIN = { 1, 2, 3, 4, 6 }, HUNTER = { 1, 2, 3 }, ROGUE = { 1, 2 },
    PRIEST = { 1 }, SHAMAN = { 1, 2, 3, 6 }, MAGE = { 1 }, WARLOCK = { 1 }, DRUID = { 1, 2 },
}
local ARMOR_AT_40 = { [3] = { HUNTER = true, SHAMAN = true }, [4] = { WARRIOR = true, PALADIN = true } }
local RELICS = { [7] = "PALADIN", [8] = "DRUID", [9] = "SHAMAN" } -- libram, idol, totem
local CLASS_WEAPONS = { -- weapon subclasses
    WARRIOR = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 }, PALADIN = { 0, 1, 4, 5, 6, 7, 8 },
    HUNTER = { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 16, 18 }, ROGUE = { 2, 3, 4, 7, 13, 15, 16, 18 },
    PRIEST = { 4, 10, 15, 19 }, SHAMAN = { 0, 1, 4, 5, 10, 13, 15 }, MAGE = { 7, 10, 15, 19 },
    WARLOCK = { 7, 10, 15, 19 }, DRUID = { 4, 5, 10, 13, 15 },
}

local function Contains(list, v)
    for _, x in ipairs(list or {}) do if x == v then return true end end
    return false
end

local function ItemBasics(id)
    if not id or id == 0 or not (C_Item and C_Item.GetItemInfoInstant) then return nil end
    local ok, _, _, _, equipLoc, _, classID, subClassID = pcall(C_Item.GetItemInfoInstant, id)
    if ok then return equipLoc, classID, subClassID end
end

local function UsableByMe(id)
    local _, classID, subClassID = ItemBasics(id)
    if not classID then return true end -- unknown: don't hide it
    local _, class = UnitClass("player")
    if classID == ITEM_CLASS_ARMOR then
        if subClassID == 0 or subClassID == 5 then return true end -- jewellery, trinkets, cosmetic
        if RELICS[subClassID] then return RELICS[subClassID] == class end
        if not Contains(CLASS_ARMOR[class], subClassID) then return false end
        local late = ARMOR_AT_40[subClassID]
        return not (late and late[class] and UnitLevel("player") < 40)
    elseif classID == ITEM_CLASS_WEAPON then
        return Contains(CLASS_WEAPONS[class], subClassID)
    end
    return true
end

local SLOT_FILTERS = {
    { label = "All slots" },
    { label = "Head", locs = { "INVTYPE_HEAD" } }, { label = "Neck", locs = { "INVTYPE_NECK" } },
    { label = "Shoulder", locs = { "INVTYPE_SHOULDER" } }, { label = "Back", locs = { "INVTYPE_CLOAK" } },
    { label = "Chest", locs = { "INVTYPE_CHEST", "INVTYPE_ROBE" } }, { label = "Wrist", locs = { "INVTYPE_WRIST" } },
    { label = "Hands", locs = { "INVTYPE_HAND" } }, { label = "Waist", locs = { "INVTYPE_WAIST" } },
    { label = "Legs", locs = { "INVTYPE_LEGS" } }, { label = "Feet", locs = { "INVTYPE_FEET" } },
    { label = "Finger", locs = { "INVTYPE_FINGER" } }, { label = "Trinket", locs = { "INVTYPE_TRINKET" } },
    { label = "Weapon", locs = { "INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_WEAPONOFFHAND" } },
    { label = "Off-hand", locs = { "INVTYPE_SHIELD", "INVTYPE_HOLDABLE" } },
    { label = "Ranged", locs = { "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT", "INVTYPE_THROWN", "INVTYPE_RELIC" } },
    { label = "Other", other = true },
}

local function MatchesSlot(id)
    local f = SLOT_FILTERS[lootFilter.slot]
    if not f.locs and not f.other then return true end
    local equipLoc = ItemBasics(id)
    if not equipLoc then return f.other or false end
    if f.other then return equipLoc == "" or equipLoc == "INVTYPE_NON_EQUIP_IGNORE" end
    return Contains(f.locs, equipLoc)
end

---------------------------------------------------------------------------
-- Dungeon browser (cards)
---------------------------------------------------------------------------
local function VisibleDungeons()
    local mine = ns.PlayerFaction()
    local level = UnitLevel("player")
    local text = browserState.search:lower()
    local list = {}
    for _, d in ipairs(ns.DUNGEONS) do
        local keep = not d.faction or not mine or d.faction == mine
        if keep and browserState.recommended then keep = ns.DungeonFitsLevel(d, level) end
        if keep and text ~= "" then
            local haystack = (d.name .. " " .. (d.zone or "") .. " " .. table.concat(d.bosses or {}, " ")):lower()
            keep = haystack:find(text, 1, true) ~= nil
        end
        if keep then list[#list + 1] = d end
    end
    table.sort(list, function(a, b)
        if a.min ~= b.min then return a.min < b.min end
        return a.name < b.name
    end)
    return list
end

local function CreateCard(i)
    local c = CreateFrame("Button", nil, browser.content, ns.BACKDROP)
    c:SetSize(CARD_W, CARD_H)
    ns.Skin(c, { 0, 0, 0, 1 }, ns.color.border)
    c.fill = c:CreateTexture(nil, "BACKGROUND", nil, 1)
    c.fill:SetPoint("TOPLEFT", 1, -1)
    c.fill:SetPoint("BOTTOMRIGHT", -1, 1)
    c.art = c:CreateTexture(nil, "ARTWORK")
    c.art:SetAllPoints(c.fill)
    c.shade = c:CreateTexture(nil, "ARTWORK", nil, 2)
    c.shade:SetPoint("BOTTOMLEFT", 1, 1)
    c.shade:SetPoint("BOTTOMRIGHT", -1, 1)
    c.shade:SetHeight(36)
    c.shade:SetColorTexture(0, 0, 0, 0.7)
    local hover = c:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(c.fill)
    hover:SetColorTexture(1, 0.82, 0.4, 0.12)
    c.name = ns.Text(c, 13, ns.color.text, "OUTLINE")
    c.name:SetPoint("BOTTOMLEFT", 8, 18)
    c.name:SetPoint("RIGHT", -8, 0)
    c.name:SetJustifyH("LEFT")
    c.name:SetWordWrap(false)
    c.sub = ns.Text(c, 10, { 0.85, 0.85, 0.85, 1 }, "OUTLINE")
    c.sub:SetPoint("BOTTOMLEFT", 8, 5)
    c.ribbon = ns.Text(c, 10, { 0.4, 0.8, 1, 1 }, "OUTLINE")
    c.ribbon:SetPoint("TOPRIGHT", -6, -5)
    c.tag = ns.Text(c, 10, { 0.45, 0.95, 0.45, 1 }, "OUTLINE")
    c.tag:SetPoint("TOPLEFT", 7, -5)
    c:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(ns.color.gold)) end)
    c:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(ns.color.border)) end)
    c:SetScript("OnClick", function(self)
        selectedKey, view, activeTab = self.key, "page", "overview"
        lootFilter.boss = nil
        ns.RefreshJournal()
    end)
    cards[i] = c
    return c
end

local function DrawBrowser()
    local list = VisibleDungeons()
    local level = UnitLevel("player")
    for i, d in ipairs(list) do
        local c = cards[i] or CreateCard(i)
        local row, col = math.floor((i - 1) / CARD_COLS), (i - 1) % CARD_COLS
        c:ClearAllPoints()
        c:SetPoint("TOPLEFT", col * (CARD_W + CARD_GAP), -row * (CARD_H + CARD_GAP))
        c.key = d.key
        PaintArt(d, c.fill, c.art, "card")
        c.name:SetText(d.name)
        c.sub:SetText(format("%d-%d  |cffbbbbbb%s|r", d.min, d.max, d.zone or ""))
        c.ribbon:SetText(d.new and "NEW" or "")
        c.tag:SetText(ns.DungeonFitsLevel(d, level) and "RECOMMENDED" or (level < d.min and "|cffff8040TOO HIGH|r" or ""))
        c:Show()
    end
    for i = #list + 1, #cards do cards[i]:Hide() end
    local rows = math.ceil(#list / CARD_COLS)
    browser.content:SetHeight(math.max(10, rows * (CARD_H + CARD_GAP)))
    browser.count:SetText(format("%d dungeon%s", #list, #list == 1 and "" or "s"))
    browser.empty:SetShown(#list == 0)
end

---------------------------------------------------------------------------
-- Item tooltips: full stats, where it drops, and a comparison with what you
-- wear (hold Shift, or always with the game's "always compare items" option)
---------------------------------------------------------------------------
local hoveredRow

-- True if any line of the item tooltip contains `text` (lowercase)
local function TooltipMentions(text)
    for i = 1, GameTooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local value = line and line:GetText()
        if value and not ns.IsSecret(value) and value:lower():find(text, 1, true) then return true end
    end
    return false
end

local function WantsCompare()
    if IsModifiedClick and IsModifiedClick("COMPAREITEMS") then return true end
    return GetCVarBool and GetCVarBool("alwaysCompareItems") or false
end

function ShowRowTooltip(row)
    hoveredRow = row
    if row.tooltip and not row.itemID then
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:SetText(row.tooltip, 1, 0.82, 0)
        GameTooltip:Show()
        return
    end
    if not row.itemID or row.itemID == 0 then
        if row.itemName then
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetText(row.itemName, 1, 1, 1)
            GameTooltip:AddLine("No item ID has been published for this drop yet, so its stats aren't available.",
                0.6, 0.6, 0.6, true)
            GameTooltip:Show()
        end
        return
    end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    if GameTooltip.SetItemByID then
        GameTooltip:SetItemByID(row.itemID)
    else
        GameTooltip:SetHyperlink("item:" .. row.itemID)
    end
    if TooltipMentions("not discovered") then
        -- Forever holds back an item's stats until your character has discovered it,
        -- so add what we know from the loot data and Questie
        GameTooltip:AddLine(" ")
        if row.itemName and not TooltipMentions(row.itemName:lower()) then
            GameTooltip:AddLine(row.itemName, 1, 1, 1)
        end
        if row.slot and row.slot ~= "" then GameTooltip:AddLine(row.slot, 1, 1, 1) end
        local itemLevel, requiredLevel
        if ns.QuestieItemLevels then itemLevel, requiredLevel = ns.QuestieItemLevels(row.itemID) end
        if type(itemLevel) == "number" and itemLevel > 0 then
            GameTooltip:AddLine("Item level " .. itemLevel, 1, 0.82, 0)
        end
        if type(requiredLevel) == "number" and requiredLevel > 0 then
            GameTooltip:AddLine("Requires level " .. requiredLevel, 1, 1, 1)
        end
        if row.badge == "new" then
            GameTooltip:AddLine("New in WoW Forever", 0.25, 0.75, 1)
        elseif row.badge == "updated" then
            GameTooltip:AddLine("Updated for WoW Forever", 1, 0.82, 0)
        end
        GameTooltip:AddLine("Full stats appear once your character has discovered this item.", 0.6, 0.6, 0.6, true)
    end
    if row.source then GameTooltip:AddLine("Drops from: " .. row.source, 0.6, 0.6, 0.6) end
    if row.seen then GameTooltip:AddLine(row.seen, 0.6, 0.6, 0.6) end
    GameTooltip:Show()
    if WantsCompare() and GameTooltip_ShowCompareItem then
        pcall(GameTooltip_ShowCompareItem, GameTooltip)
    end
end

-- Re-show the tooltip when its item finishes loading or Shift is pressed
local function RefreshHoveredTooltip(itemID)
    if hoveredRow and hoveredRow:IsMouseOver() and (not itemID or hoveredRow.itemID == itemID) then
        ShowRowTooltip(hoveredRow)
    end
end

-- Ask the game for every item in a dungeon up front, so tooltips are instant
local preloaded = {}
local function PreloadItems(d, loot)
    if preloaded[d.key] or not loot or not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    preloaded[d.key] = true
    for _, group in ipairs(loot) do
        for _, item in ipairs(group.items) do
            local cached = C_Item.IsItemDataCachedByID and Safe(C_Item.IsItemDataCachedByID, item.id)
            if item.id and item.id > 0 and not cached then pcall(C_Item.RequestLoadItemDataByID, item.id) end
        end
    end
end

local function DetailRow(i)
    local row = detailRows[i]
    if row then return row end
    row = CreateFrame("Button", nil, detailContent)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(16, 16)
    row.icon:SetPoint("TOPLEFT", 0, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    -- loot grid cells: a quality-coloured frame and a dark card behind the icon
    row.cellBg = row:CreateTexture(nil, "BACKGROUND")
    row.cellBg:SetAllPoints()
    row.cellBg:SetColorTexture(1, 1, 1, 0.04)
    row.cellBg:Hide()
    row.iconBorder = row:CreateTexture(nil, "BORDER")
    row.iconBorder:SetPoint("TOPLEFT", row.icon, "TOPLEFT", -2, 2)
    row.iconBorder:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 2, -2)
    row.iconBorder:Hide()
    row.text = ns.Text(row, 11)
    row.text:SetJustifyH("LEFT")
    row.text:SetJustifyV("TOP")
    row.right = ns.Text(row, 10, ns.color.dim)
    row.right:SetJustifyH("RIGHT")
    row.right:SetPoint("TOPRIGHT", 0, -2)
    row.mark = ns.CreateButton(row, "Mark", 40, 18, function(self)
        local parent = self:GetParent()
        if parent.onMark then parent.onMark() end
    end)
    row.mark:SetPoint("TOPRIGHT", 0, 0)
    row.set = ns.CreateButton(row, "Set", 34, 18, function(self)
        local parent = self:GetParent()
        if parent.onSet then parent.onSet() end
    end)
    row.set:SetPoint("TOPRIGHT", row.mark, "TOPLEFT", -4, 0)
    row.set:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Set marker here", 1, 1, 1)
        GameTooltip:AddLine("Saves where you're standing as this location. Stand next to the quest giver or "
            .. "entrance first. Right-click to remove a marker you set.", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    row.set:HookScript("OnLeave", function() GameTooltip:Hide() end)
    row.set:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row.set:SetScript("OnClick", function(self, mouse)
        local parent = self:GetParent()
        if mouse == "RightButton" then
            if parent.onClearSet then parent.onClearSet() end
        elseif parent.onSet then
            parent.onSet()
        end
    end)
    row:SetScript("OnEnter", ShowRowTooltip)
    row:SetScript("OnLeave", function()
        hoveredRow = nil
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if self.onClick then
            self.onClick() -- boss headings expand and collapse
        elseif self.link and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink then
            ChatEdit_InsertLink(self.link) -- shift-click an item to link it in chat
        end
    end)
    detailRows[i] = row
    return row
end

-- Display text, link and icon for an item; knownName is shown until the game
-- has the item cached (and always for items with no published ID)
local function ItemDisplay(id, knownName)
    if not id or id == 0 then
        return "|cffa0a0a0" .. (knownName or "?") .. "|r", nil, nil
    end
    local name, link, _, _, _, _, _, _, _, icon
    if C_Item and C_Item.GetItemInfo then
        name, link, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
    end
    if not name and C_Item and C_Item.RequestLoadItemDataByID then
        pcall(C_Item.RequestLoadItemDataByID, id) -- GET_ITEM_INFO_RECEIVED redraws
    end
    icon = icon or (C_Item and C_Item.GetItemIconByID and Safe(C_Item.GetItemIconByID, id))
    return link or ("|cffa0a0a0" .. (knownName or ("item " .. id)) .. "|r"), link, icon
end

---------------------------------------------------------------------------
-- Markers you set yourself ("Set" buttons); these beat learned and curated ones
---------------------------------------------------------------------------
local function Markers(key)
    return Learned("markers", key)
end

local function SetMarkerHere(key, id, label)
    local mapID, x, y = PlayerPosition()
    if not mapID then
        ns.Print("|cffff5544Can't read your position here|r - map positions aren't available inside dungeons. "
            .. "Stand outside next to it and try again.")
        return
    end
    Markers(key)[id] = { mapID = mapID, x = x, y = y, set = time() }
    local info = Safe(C_Map.GetMapInfo, mapID)
    ns.Print(format("Saved |cffffd200%s|r at %s %.1f, %.1f.", label, info and info.name or "?", x, y))
    ns.RefreshJournal()
end

local function ClearMarker(key, id, label)
    if Markers(key)[id] then
        Markers(key)[id] = nil
        ns.Print("Removed your marker for " .. label .. ".")
        ns.RefreshJournal()
    end
end

-- Turns a quest into its display text plus Mark / Set actions
local function QuestSpec(q, dungeonKey)
    local level = UnitLevel("player")
    local color = q.faction and FACTION_COLOR[q.faction] or "ffffff"
    local title = format("|cff%s%s|r", color, q.title)
    if q.level then
        local diff = ns.QuestDifficulty(q.level, level)
        local diffColor = ({ impossible = "ff2020", hard = "ff8040", normal = "ffff00", easy = "40c040", trivial = "808080" })[diff]
        title = format("|cff%s[%d]|r %s", diffColor, q.level, title)
    end
    local status = QuestStatus(q.title)
    if status then title = title .. "  " .. status end
    local lines = { title }
    local who = q.giver or "?"
    if q.place then who = who .. " - " .. q.place end
    local own = Markers(dungeonKey)["q:" .. q.title]
    local pickup = ns.QuestPickup(q.title)
    local questie = ns.QuestieStart and ns.QuestieStart(q.title)
    if questie and (not q.giver or q.giver == "?") and not own and not pickup then
        who = (questie.giver or "?") .. (q.place and " - " .. q.place or "") -- item starters have no position
    end

    -- your own marker, then where you accepted it, then the published position
    local mapID, x, y, origin
    if own then
        mapID, x, y, origin = own.mapID, own.x, own.y, "your marker"
    elseif pickup then
        mapID, x, y, origin = pickup.mapID, pickup.x, pickup.y, "where you picked it up"
        if not q.giver or q.giver == "?" then who = (pickup.giver or "?") .. (q.place and " - " .. q.place or "") end
    elseif questie and questie.mapID then
        mapID, x, y, origin = questie.mapID, questie.x, questie.y, "Questie"
        if not q.giver or q.giver == "?" then who = (questie.giver or "?") .. (q.place and " - " .. q.place or "") end
    elseif ns.MapQuest and ns.MapQuest(q.title) then
        local m = ns.MapQuest(q.title)
        mapID, x, y, origin = m.mapID, m.x, m.y, "game map"
    else
        mapID = q.mapID or (q.zone and q.x and ns.FindMapID(q.zone))
        x, y = q.x, q.y
        origin = q.learned and "learned" or nil
    end
    -- givers standing at the entrance: use the entrance's position
    if not (mapID and x) and q.atEntrance then
        local d = byKey[dungeonKey]
        local e = d and d.entrance or {}
        local entrance = Markers(dungeonKey).entrance or (ns.QuestieEntrance and ns.QuestieEntrance(dungeonKey))
        if entrance then
            mapID, x, y = entrance.mapID, entrance.x, entrance.y
        elseif e.x then
            mapID, x, y = ns.FindMapID(e.zone or (d and d.zone)), e.x, e.y
        end
        origin = mapID and "dungeon entrance" or origin
    end
    local hasSpot = mapID and x and y
    local coords = hasSpot and format(" |cffc0c0c0%.1f, %.1f|r", x, y) or ""
    lines[#lines + 1] = "|cff999999" .. who .. "|r" .. coords .. (origin and ("  |cff999999(" .. origin .. ")|r") or "")
    if not hasSpot and not q.inside then
        lines[#lines + 1] = "|cffa0a0a0No location known yet - stand next to the quest giver and press Set.|r"
    end
    if q.reward then lines[#lines + 1] = "|cff999999Reward: " .. q.reward .. "|r" end
    local finish = ns.QuestieFinish and ns.QuestieFinish(q.title, q.id)
    if finish and finish.giver then
        local where = finish.mapID and (Safe(C_Map.GetMapInfo, finish.mapID) or {}).name
        lines[#lines + 1] = "|cff999999Hand in: " .. finish.giver .. (where and (" - " .. where) or "") .. "|r"
    end
    local onMark
    if mapID and x and y then
        onMark = function() ns.SetWaypoint(mapID, x, y, q.giver or q.title) end
    end
    -- quests that start inside the dungeon can't be pinned on the world map
    local onSet, onClearSet
    if not q.inside then
        onSet = function() SetMarkerHere(dungeonKey, "q:" .. q.title, q.title) end
        onClearSet = function() ClearMarker(dungeonKey, "q:" .. q.title, q.title) end
    end
    return { text = table.concat(lines, "\n"), onMark = onMark, onSet = onSet, onClearSet = onClearSet,
             spot = hasSpot and { mapID = mapID, x = x, y = y } or nil, who = who }
end

-- Curated quests merged with the ones learned in game
local function BuildQuestList(d)
    local mine = ns.PlayerFaction()
    local learned = Journal().quests[d.key] or {}
    local list, seen = {}, {}
    for _, q in ipairs(d.quests or {}) do
        if not q.faction or not mine or q.faction == mine then
            local copy = {}
            for k, v in pairs(q) do copy[k] = v end
            local l = learned[q.title]
            if l and l.x and not copy.x then
                copy.mapID, copy.x, copy.y = l.mapID, l.x, l.y -- a real position beats none
            end
            list[#list + 1] = copy
        end
        seen[q.title] = true
    end
    for title, l in pairs(learned) do
        if not seen[title] and (not l.faction or not mine or l.faction == mine) then
            list[#list + 1] = { title = title, giver = l.giver, place = l.zone, level = l.level,
                                mapID = l.mapID, x = l.x, y = l.y, learned = true }
            seen[title] = true
        end
    end

    -- every quest Questie files under this dungeon (already filtered to your faction)
    local fromQuestie = ns.QuestieDungeonQuests and ns.QuestieDungeonQuests(d.key)
    if fromQuestie then
        local lowerSeen = {}
        for title in pairs(seen) do lowerSeen[title:lower()] = true end
        for _, q in ipairs(fromQuestie) do
            if not lowerSeen[q.title:lower()] then
                list[#list + 1] = { title = q.title, level = q.level, fromQuestie = true }
                lowerSeen[q.title:lower()] = true
            end
        end
    end

    -- fill in quest levels the published data didn't have
    for _, q in ipairs(list) do
        if not q.level and ns.QuestieStart then
            local s = ns.QuestieStart(q.title)
            q.level = s and s.level
        end
    end
    table.sort(list, function(a, b)
        if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) < (b.level or 0) end
        return a.title < b.title
    end)
    return list, ns.QuestieAvailable and ns.QuestieAvailable() and fromQuestie == nil
end
-- Each dungeon's quest list, built once and reused: the dungeon cards need it for
-- every dungeon on every redraw. Rebuilt when your quests change or Questie loads.
local questListCache = {}

function ns.ClearJournalQuestCache()
    wipe(questListCache)
end

function QuestsFor(d)
    local cached = questListCache[d.key]
    if cached then return cached.list, false end
    local list, loading = BuildQuestList(d)
    if not loading then questListCache[d.key] = { list = list } end
    return list, loading
end

-- Loot as { { boss, items = { { id, name, slot, badge } } } }, from the
-- generated tables (LootData.lua), the curated ones, or the game's journal
local function LootFor(d)
    local generated = ns.LOOT and ns.LOOT[d.key]
    if generated and #generated > 0 then
        local groups = {}
        for _, g in ipairs(generated) do
            local items = {}
            for _, it in ipairs(g.items) do
                local id = it[1]
                if id == 0 then
                    -- published without an ID: find it by name so it gets stats and an icon
                    id = (ns.QuestieItemId and ns.QuestieItemId(it[2])) or 0
                end
                items[#items + 1] = { id = id, name = it[2], slot = it[3], badge = it[4] ~= "" and it[4] or nil }
            end
            groups[#groups + 1] = { boss = g.boss, items = items }
        end
        return groups
    end
    local idGroups = d.loot or EncounterJournalLoot(d)
    if not idGroups then return nil end
    local groups = {}
    for _, g in ipairs(idGroups) do
        local items = {}
        for _, id in ipairs(g.items) do items[#items + 1] = { id = id } end
        groups[#groups + 1] = { boss = g.boss, items = items }
    end
    return groups
end

-- Every boss's loot starts open so all items can be hovered; "Hide all" folds them
local OPEN_BY_DEFAULT_UP_TO = math.huge
function IsOpen(d, boss, bossCount)
    local state = expanded[d.key .. "|" .. boss]
    if state == nil then return bossCount <= OPEN_BY_DEFAULT_UP_TO end
    return state
end

---------------------------------------------------------------------------
-- Dungeon page: a header banner, four tabs, and a builder per tab producing
-- rows (and loot grid cells) for DrawDetail
---------------------------------------------------------------------------
local TABS = {
    { key = "overview", label = "Overview" },
    { key = "bosses", label = "Bosses" },
    { key = "loot", label = "Loot" },
    { key = "quests", label = "Quests" },
}

local function Header(Add, text)
    Add({ text = text:upper(), size = 10, color = ns.color.gold, top = 8 })
end

local function GoTo(tab, boss)
    return function()
        activeTab = tab
        lootFilter.boss = boss
        ns.RefreshJournal()
    end
end

-- Where the entrance is: your marker, then Questie's Forever-checked one, then the published one
local function Entrance(d)
    local e = d.entrance or {}
    local own = Markers(d.key).entrance
    local questie = ns.QuestieEntrance and ns.QuestieEntrance(d.key)
    if own then return own.mapID, own.x, own.y, "your marker" end
    if questie then return questie.mapID, questie.x, questie.y, "Questie" end
    if e.x then return ns.FindMapID(e.zone or d.zone), e.x, e.y, e.approx and "approx." or nil end
end

local function EntranceSpec(d)
    local e = d.entrance or {}
    local mapID, x, y, origin = Entrance(d)
    local where = "|cff999999Location:|r " .. (e.zone or d.zone)
    if x then where = where .. format(" %.1f, %.1f", x, y) end
    if origin then where = where .. " |cff999999(" .. origin .. ")|r" end
    if e.note then where = where .. "\n|cff999999" .. e.note .. "|r" end
    local label = d.name .. " entrance"
    return { text = where,
             onMark = mapID and function() ns.SetWaypoint(mapID, x, y, label) end or nil,
             onSet = function() SetMarkerHere(d.key, "entrance", label) end,
             onClearSet = function() ClearMarker(d.key, "entrance", label) end }
end

-- Bosses in kill order: from the loot tables, else the published names
local function BossList(d)
    local list, loot = {}, LootFor(d)
    if loot then
        for _, g in ipairs(loot) do
            if g.boss ~= "Trash" then list[#list + 1] = { name = g.boss, items = #g.items } end
        end
    elseif d.bosses then
        for _, name in ipairs(d.bosses) do list[#list + 1] = { name = name } end
    end
    return list
end

local function ItemCount(loot)
    local n = 0
    for _, g in ipairs(loot or {}) do n = n + #g.items end
    return n
end

---------------------------------------------------------------------------
-- Pick up first: the dungeon's quests you can take but haven't, nearest
-- first, with a route that marks each giver in turn and then the entrance
---------------------------------------------------------------------------
local route -- { key, items = { { title, giver, mapID, x, y } } }

local function YardsTo(spot)
    if not (spot and ns.PlayerWorldPos and ns.WorldPos) then return nil end
    local continent, px, py = ns.PlayerWorldPos()
    local c, wx, wy = ns.WorldPos(spot.mapID, spot.x, spot.y)
    if not continent or c ~= continent then return nil end
    return math.sqrt((wx - px) ^ 2 + (wy - py) ^ 2)
end

local function YardsText(yards)
    if not yards then return "" end
    if yards < 1000 then return format("%d yd", math.floor(yards / 10 + 0.5) * 10) end
    return format("%.1fk yd", yards / 1000)
end

-- Quests to collect before going in: not started inside, not done, not in your
-- log, and (when Questie knows the quest) ones you're allowed to take now
local function PickupList(d)
    local list = {}
    for _, q in ipairs((QuestsFor(d))) do
        if not q.inside and not QuestStatus(q.title) then
            local start = ns.QuestieStart and ns.QuestieStart(q.title)
            local doable = true
            if start and start.questId and ns.QuestieIsDoable then
                doable = ns.QuestieIsDoable(start.questId) ~= false
            end
            if doable then
                local spec = QuestSpec(q, d.key)
                list[#list + 1] = { q = q, spec = spec, yards = YardsTo(spec.spot) }
            end
        end
    end
    table.sort(list, function(a, b)
        local ya, yb = a.yards or math.huge, b.yards or math.huge
        if ya ~= yb then return ya < yb end
        return a.q.title < b.q.title
    end)
    return list
end

local function MarkNextInRoute()
    if not route then return end
    for i = #route.items, 1, -1 do
        if QuestStatus(route.items[i].title) then table.remove(route.items, i) end
    end
    local d = byKey[route.key]
    if #route.items == 0 then
        route = nil
        if not d then return end
        ns.Print(format("All of %s's quests picked up - marking the entrance.", d.name))
        local mapID, x, y = Entrance(d)
        if mapID and x then ns.SetWaypoint(mapID, x, y, d.name .. " entrance") end
        return
    end
    for _, item in ipairs(route.items) do item.yards = YardsTo(item) end
    table.sort(route.items, function(a, b) return (a.yards or math.huge) < (b.yards or math.huge) end)
    local nextStop = route.items[1]
    ns.SetWaypoint(nextStop.mapID, nextStop.x, nextStop.y, (nextStop.giver or "?") .. " - " .. nextStop.title)
    if #route.items > 1 then
        ns.Print(format("%s route: %d more quest%s to pick up after this one.", d and d.name or "Dungeon",
            #route.items - 1, #route.items == 2 and "" or "s"))
    end
end

local function StartRoute(d, list)
    route = { key = d.key, items = {} }
    for _, entry in ipairs(list) do
        local spot = entry.spec.spot
        if spot then
            local giver = entry.q.giver
            if not giver or giver == "?" then giver = entry.spec.who end
            route.items[#route.items + 1] = { title = entry.q.title, giver = giver, mapID = spot.mapID, x = spot.x, y = spot.y }
        end
    end
    -- TomTom can show every stop at once
    if TomTom and TomTom.AddWaypoint then
        for i = 2, #route.items do
            local stop = route.items[i]
            pcall(TomTom.AddWaypoint, TomTom, stop.mapID, stop.x / 100, stop.y / 100, { title = stop.title })
        end
    end
    MarkNextInRoute()
end

-- picking up a quest on the route moves the marker on to the next giver
table.insert(ns.inits, function()
    ns.On("QUEST_ACCEPTED", function()
        if route then C_Timer.After(0.6, MarkNextInRoute) end
    end)
end)

local function AddPickupSection(d, Add)
    if d.max and UnitLevel("player") > d.max + 5 then return end -- long past it
    local list = PickupList(d)
    Header(Add, "Pick up first")
    if #list == 0 then
        local inLog = 0
        for _, q in ipairs((QuestsFor(d))) do
            if QuestStatus(q.title) and not doneTitles[q.title:lower()] then inLog = inLog + 1 end
        end
        local text = inLog > 0
            and format("|cff6fdc6fAll set|r - %d of its quest%s in your log.", inLog, inLog == 1 and " is" or "s are")
            or "Nothing to pick up outside - any other quests start inside the dungeon."
        Add({ text = text })
        return
    end
    local withSpot = 0
    for _, entry in ipairs(list) do if entry.spec.spot then withSpot = withSpot + 1 end end
    local count = format("%d quest%s to collect before you go in.", #list, #list == 1 and "" or "s")
    if withSpot > 0 then
        Add({ text = count .. "   |cffffd200Mark route (nearest first) >|r",
              onClick = function() StartRoute(d, list) end,
              tooltip = "Marks the nearest quest giver. Each time you pick one up, the marker moves on to the next, then to the entrance." })
    else
        Add({ text = count })
    end
    for _, entry in ipairs(list) do
        local q, spec = entry.q, entry.spec
        local level = q.level and format("[%d] ", q.level) or ""
        local distance = entry.yards and ("  |cffc0c0c0" .. YardsText(entry.yards) .. "|r") or ""
        local where = spec.spot and "" or "  |cffa0a0a0(no location known)|r"
        Add({ text = format("%s|cffffd200%s|r\n|cff999999%s|r%s%s", level, q.title, spec.who or "?", distance, where),
              onMark = spec.onMark, gap = 6 })
    end
end

local function BuildOverview(d, Add)
    local description = DungeonDescription(d)
    if description and description ~= "" then
        Add({ text = description, color = { 0.85, 0.85, 0.85, 1 }, gap = 6 })
    end

    Header(Add, "Location")
    Add(EntranceSpec(d))

    Header(Add, "At a glance")
    local level = UnitLevel("player")
    local fit
    if ns.DungeonFitsLevel(d, level) then
        fit = "|cff6fdc6fRecommended for your level|r"
    elseif level < d.min then
        fit = format("|cffff8040Come back around level %d|r", d.min)
    else
        fit = "|cff999999Below your level now|r"
    end
    Add({ text = format("Levels %d-%d   %s", d.min, d.max, fit) })
    local quests = QuestsFor(d)
    local done = 0
    for _, q in ipairs(quests) do if doneTitles[q.title:lower()] then done = done + 1 end end
    Add({ text = format("Quests: %d of %d done   |cffffd200Open the Quests tab >|r", done, #quests),
          onClick = GoTo("quests"), tooltip = "See every quest, its giver and a map marker" })
    local bosses, loot = BossList(d), LootFor(d)
    Add({ text = format("Bosses: %d   Loot: %d items   |cffffd200Open the Loot tab >|r", #bosses, ItemCount(loot)),
          onClick = GoTo("loot"), tooltip = "Browse the loot, filtered to what you can use" })

    AddPickupSection(d, Add)

    if #bosses > 0 then
        Header(Add, "Bosses")
        for i, b in ipairs(bosses) do
            Add({ text = format("|cffffd200%d.|r %s", i, b.name), gap = 2,
                  onClick = GoTo("loot", b.items and b.name or nil), tooltip = b.items and ("Show " .. b.name .. "'s loot") or nil })
        end
    end
end

local function BuildBosses(d, Add)
    local bosses = BossList(d)
    if #bosses == 0 then
        Add({ text = "No bosses published for this dungeon yet.", color = ns.color.dim })
        return
    end
    Add({ text = "Click a boss to see what it drops.", color = ns.color.dim, gap = 8 })
    for i, b in ipairs(bosses) do
        local count = b.items and format("   |cff999999%d item%s|r", b.items, b.items == 1 and "" or "s") or ""
        Add({ text = format("|cffffd200%d.|r  %s%s", i, b.name, count), size = 13, gap = 8,
              onClick = b.items and GoTo("loot", b.name) or nil,
              tooltip = b.items and ("Show " .. b.name .. "'s loot") or nil })
    end
end

local function Quality(id)
    if not id or id == 0 then return nil end
    if C_Item and C_Item.GetItemQualityByID then return Safe(C_Item.GetItemQualityByID, id) end
end

local function ItemCell(id, name, slot, badge, source, seen)
    local text, link, icon = ItemDisplay(id, name)
    local second = slot or ""
    if badge == "new" then
        second = "|cff40c0ffnew|r  " .. second
    elseif badge == "updated" then
        second = "|cffffd200updated|r  " .. second
    end
    return { cell = true, text = text .. "\n|cff999999" .. second .. "|r", icon = icon or 134400,
             itemID = id, itemName = name, link = link, source = source, slot = slot, badge = badge,
             quality = Quality(id), seen = seen }
end

local function PassesFilters(id)
    if lootFilter.usable and not UsableByMe(id) then return false end
    return MatchesSlot(id)
end

local function BuildLoot(d, Add)
    local loot = LootFor(d)
    PreloadItems(d, loot)

    -- filter bar
    Add({ text = (lootFilter.usable and "|cff6fdc6f[x]|r" or "|cff999999[  ]|r") .. "  Usable by me", gap = 3,
          onClick = function()
              lootFilter.usable = not lootFilter.usable
              ns.RefreshJournal()
          end, tooltip = "Only show gear your class can wear or wield" })
    Add({ text = "|cffffd200Slot:|r " .. SLOT_FILTERS[lootFilter.slot].label .. "   |cff999999(click to change)|r", gap = 3,
          onClick = function()
              lootFilter.slot = lootFilter.slot % #SLOT_FILTERS + 1
              ns.RefreshJournal()
          end })
    if lootFilter.boss then
        Add({ text = "|cffffd200Boss:|r " .. lootFilter.boss .. "   |cff999999(click to show every boss)|r",
              onClick = GoTo("loot", nil) })
    end

    local shown = 0
    if loot then
        for _, g in ipairs(loot) do
            if not lootFilter.boss or g.boss == lootFilter.boss then
                local cells = {}
                for _, item in ipairs(g.items) do
                    if PassesFilters(item.id) then
                        cells[#cells + 1] = ItemCell(item.id, item.name, item.slot, item.badge, g.boss)
                    end
                end
                if #cells > 0 then
                    Add({ text = g.boss, color = ns.color.gold, size = 12, top = 8, gap = 4 })
                    for _, c in ipairs(cells) do Add(c) end
                    shown = shown + #cells
                end
            end
        end
    end

    local seen = Journal().loot[d.key]
    if seen and next(seen) and not lootFilter.boss then
        local cells = {}
        for source, items in pairs(seen) do
            for id, count in pairs(items) do
                if PassesFilters(id) then
                    cells[#cells + 1] = ItemCell(id, nil, nil, nil, source,
                        format("Seen %d time%s", count, count == 1 and "" or "s"))
                end
            end
        end
        if #cells > 0 then
            Add({ text = "Seen in your runs", color = ns.color.gold, size = 12, top = 10, gap = 4 })
            for _, c in ipairs(cells) do Add(c) end
            shown = shown + #cells
        end
    end

    if shown == 0 then
        Add({ text = loot and "Nothing here matches these filters." or
              "No loot published yet. Drops you see in this dungeon are recorded here.", color = ns.color.dim, top = 8 })
    end
end

local function BuildQuests(d, Add)
    local quests, loadingQuestie = QuestsFor(d)
    if loadingQuestie then
        Add({ text = "|cffffd200Loading this dungeon's quests from Questie...|r" })
    end
    if d.classicQuests and not (ns.QuestieAvailable and ns.QuestieAvailable()) then
        Add({ text = "Classic quest data - may differ in Forever. Install Questie for Forever's own data.",
              color = ns.color.dim })
    end
    if #quests == 0 then
        Add({ text = "None published yet. Accept one of this dungeon's quests and it's added here with a map marker.",
              color = ns.color.dim })
    end
    for _, q in ipairs(quests) do
        local spec = QuestSpec(q, d.key)
        spec.gap = 9
        Add(spec)
    end
end

local BUILDERS = { overview = BuildOverview, bosses = BuildBosses, loot = BuildLoot, quests = BuildQuests }

local function QualityColor(q)
    local c = q and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
    if c then return c.r, c.g, c.b end
    return 0.4, 0.4, 0.4
end

local function DrawDetail(d)
    local specs = {}
    BUILDERS[activeTab](d, function(spec) specs[#specs + 1] = spec end)

    local y, col, rowTop = 0, 0, 0
    for i, spec in ipairs(specs) do
        local row = DetailRow(i)
        row.itemID, row.link, row.seen = spec.itemID, spec.link, spec.seen
        row.itemName, row.source, row.slot, row.badge = spec.itemName, spec.source, spec.slot, spec.badge
        row.onMark, row.onSet, row.onClearSet, row.onClick = spec.onMark, spec.onSet, spec.onClearSet, spec.onClick
        row.tooltip = spec.tooltip
        row.icon:ClearAllPoints()
        row.text:ClearAllPoints()

        if spec.cell then
            -- loot grid: two cells per row
            if col == 0 then rowTop = y end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", col * (CELL_W + CELL_GAP), rowTop)
            row:SetSize(CELL_W, CELL_H)
            row.cellBg:Show()
            row.icon:SetSize(30, 30)
            row.icon:SetPoint("LEFT", 5, 0)
            row.icon:SetTexture(spec.icon)
            row.icon:Show()
            row.iconBorder:SetColorTexture(QualityColor(spec.quality))
            row.iconBorder:Show()
            row.mark:Hide()
            row.set:Hide()
            row.right:Hide()
            row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
            row.text:SetWidth(CELL_W - 52)
            row.text:SetWordWrap(false)
            row.text:SetFont(ns.FONT, 11, "")
            row.text:SetTextColor(unpack(ns.color.text))
            row.text:SetText(spec.text or "")
            row:Show()
            col = col + 1
            if col == 2 then
                col = 0
                y = rowTop - CELL_H - 4
            end
        else
            if col ~= 0 then
                col = 0
                y = rowTop - CELL_H - 4
            end
            y = y - (spec.top or 0)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, y)
            row:SetWidth(CONTENT_W)
            row.cellBg:Hide()
            row.iconBorder:Hide()
            row.icon:SetSize(16, 16)
            row.icon:SetPoint("TOPLEFT", 0, 0)
            local left = 0
            if spec.icon then
                row.icon:SetTexture(spec.icon)
                row.icon:Show()
                left = 20
            else
                row.icon:Hide()
            end
            -- buttons sit on the right: [Set] [Mark]; Mark keeps its place even when hidden
            local hasButtons = spec.onMark or spec.onSet
            row.mark:SetShown(spec.onMark ~= nil)
            row.set:SetShown(spec.onSet ~= nil)
            local reserved = hasButtons and 82 or 0
            row.right:SetText(spec.right or "")
            row.right:SetShown(spec.right ~= nil and not hasButtons)
            if spec.right and not hasButtons then reserved = math.min(130, row.right:GetStringWidth() + 6) end
            row.text:SetPoint("TOPLEFT", left, -1)
            row.text:SetWidth(CONTENT_W - left - reserved)
            row.text:SetWordWrap(spec.right == nil)
            row.text:SetFont(ns.FONT, spec.size or 11, "")
            row.text:SetTextColor(unpack(spec.color or ns.color.text))
            row.text:SetText(spec.text or "")
            local h = math.max(row.text:GetStringHeight() + 2, spec.icon and 16 or 0, hasButtons and 18 or 0)
            row:SetHeight(h)
            row:Show()
            y = y - h - (spec.gap or 5)
        end
    end
    if col ~= 0 then y = rowTop - CELL_H - 4 end
    for i = #specs + 1, #detailRows do detailRows[i]:Hide() end
    detailContent:SetHeight(-y + 10)
end

local function DrawBanner(d)
    PaintArt(d, banner.fill, banner.art, "banner")
    banner.title:SetText(d.name)
    banner.sub:SetText(format("Levels %d-%d   |cffcccccc%s|r", d.min, d.max, d.zone or ""))
    banner.ribbon:SetText(d.new and "NEW IN FOREVER" or "")
    local mapID, x, y = Entrance(d)
    banner.mark.onMark = mapID and function() ns.SetWaypoint(mapID, x, y, d.name .. " entrance") end or nil
    banner.mark:SetShown(mapID ~= nil)
    for _, tab in ipairs(tabButtons) do tab:SetSelected(tab.key == activeTab) end
end

local function BuildDoneTitles()
    local done = {}
    for _, r in pairs(ns.cdb.quests or {}) do
        if r.title and not r.hidden then done[r.title:lower()] = true end
    end
    return done
end

-- For achievements: a dungeon's last boss, and how many of its quests you've done
function ns.DungeonFinalBoss(key)
    local d = byKey[key]
    local bosses = d and BossList(d)
    return bosses and bosses[#bosses] and bosses[#bosses].name
end

-- dungeons whose every quest (for your faction) you've completed
function ns.DungeonScholarCount()
    local done, count = BuildDoneTitles(), 0
    for _, d in ipairs(ns.DUNGEONS) do
        local list, loading = QuestsFor(d)
        if not loading and #list > 0 then
            local all = true
            for _, q in ipairs(list) do
                if not done[q.title:lower()] then all = false break end
            end
            if all then count = count + 1 end
        end
    end
    return count
end

-- how many different dungeon quests you've handed in (from your quest history)
function ns.DungeonQuestsHandedIn()
    local done, seen, count = BuildDoneTitles(), {}, 0
    for _, d in ipairs(ns.DUNGEONS) do
        local list, loading = QuestsFor(d)
        if not loading then
            for _, q in ipairs(list) do
                local title = q.title:lower()
                if done[title] and not seen[title] then
                    seen[title] = true
                    count = count + 1
                end
            end
        end
    end
    return count
end

function ns.NewDungeonCount()
    local n = 0
    for _, d in ipairs(ns.DUNGEONS) do if d.new then n = n + 1 end end
    return n
end

function ns.DungeonInfo(key)
    return byKey[key]
end

function ns.RefreshJournal()
    if not page or not page:IsVisible() then return end
    local d = selectedKey and byKey[selectedKey]
    if view == "page" and not d then view = "browser" end
    browser:SetShown(view == "browser")
    dungeonPage:SetShown(view == "page")
    if view == "browser" then
        DrawBrowser()
        return
    end
    -- everything below is for this one dungeon only
    doneTitles = BuildDoneTitles()
    DrawBanner(d)
    DrawDetail(d)
    if lastSelected ~= selectedKey or lastTab ~= activeTab then
        detailScroll:SetVerticalScroll(0)
        lastSelected, lastTab = selectedKey, activeTab
    end
end

-- Opens the journal on a dungeon (used by other parts of the addon)
function ns.ShowDungeon(key)
    if not byKey[key] then return end
    selectedKey, view, activeTab = key, "page", "overview"
    ns.ToggleOptions("dungeons")
    ns.RefreshJournal()
end

local function ScrollBy(scroll, child, delta, step)
    local max = math.max(0, child:GetHeight() - scroll:GetHeight())
    scroll:SetVerticalScroll(math.max(0, math.min(max, scroll:GetVerticalScroll() - delta * step)))
end

local function BuildBrowser()
    browser = CreateFrame("Frame", nil, page)
    browser:SetPoint("TOPLEFT", PAD, -4)
    browser:SetPoint("BOTTOMRIGHT", -PAD, 22)

    local search = ns.CreateEditBox(browser, 220, 24, "Search dungeons, zones or bosses...")
    search:SetPoint("TOPLEFT", 0, 0)
    search:HookScript("OnTextChanged", function(self)
        browserState.search = self:GetText() or ""
        ns.RefreshJournal()
    end)
    local recommended = ns.CreateButton(browser, "Recommended for me", 150, 24, function(self)
        browserState.recommended = not browserState.recommended
        self:SetSelected(browserState.recommended)
        ns.RefreshJournal()
    end)
    recommended:SetPoint("LEFT", search, "RIGHT", 8, 0)
    browser.count = ns.Text(browser, 11, ns.color.dim)
    browser.count:SetPoint("TOPRIGHT", 0, -6)

    local holder = CreateFrame("Frame", nil, browser, ns.BACKDROP)
    holder:SetPoint("TOPLEFT", 0, -32)
    holder:SetPoint("BOTTOMRIGHT")
    ns.Skin(holder, { 0.06, 0.06, 0.07, 0.9 }, ns.color.border)
    local scroll = CreateFrame("ScrollFrame", nil, holder)
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -6, 6)
    browser.content = CreateFrame("Frame", nil, scroll)
    browser.content:SetSize(INNER_W - 14, 10)
    scroll:SetScrollChild(browser.content)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta) ScrollBy(self, browser.content, delta, CARD_H + CARD_GAP) end)
    browser.empty = ns.Text(holder, 12, ns.color.dim)
    browser.empty:SetPoint("CENTER")
    browser.empty:SetText("No dungeons match.")
end

local function BuildPage()
    dungeonPage = CreateFrame("Frame", nil, page)
    dungeonPage:SetPoint("TOPLEFT", PAD, -4)
    dungeonPage:SetPoint("BOTTOMRIGHT", -PAD, 22)

    -- header banner with the dungeon's artwork
    banner = CreateFrame("Frame", nil, dungeonPage, ns.BACKDROP)
    banner:SetPoint("TOPLEFT")
    banner:SetPoint("TOPRIGHT")
    banner:SetHeight(BANNER_H)
    ns.Skin(banner, { 0, 0, 0, 1 }, ns.color.border)
    banner.fill = banner:CreateTexture(nil, "BACKGROUND", nil, 1)
    banner.fill:SetPoint("TOPLEFT", 1, -1)
    banner.fill:SetPoint("BOTTOMRIGHT", -1, 1)
    banner.art = banner:CreateTexture(nil, "ARTWORK")
    banner.art:SetAllPoints(banner.fill)
    local shade = banner:CreateTexture(nil, "ARTWORK", nil, 2)
    shade:SetPoint("BOTTOMLEFT", 1, 1)
    shade:SetPoint("BOTTOMRIGHT", -1, 1)
    shade:SetHeight(48)
    shade:SetColorTexture(0, 0, 0, 0.65)
    banner.title = ns.Text(banner, 20, ns.color.gold, "OUTLINE")
    banner.title:SetPoint("BOTTOMLEFT", 12, 24)
    banner.sub = ns.Text(banner, 11, ns.color.text, "OUTLINE")
    banner.sub:SetPoint("BOTTOMLEFT", 12, 8)
    banner.ribbon = ns.Text(banner, 10, { 0.4, 0.8, 1, 1 }, "OUTLINE")
    banner.ribbon:SetPoint("TOPRIGHT", -10, -8)
    local back = ns.CreateButton(banner, "< All dungeons", 110, 22, function()
        view = "browser"
        ns.RefreshJournal()
    end)
    back:SetPoint("TOPLEFT", 8, -8)
    banner.mark = ns.CreateButton(banner, "Mark entrance", 110, 22, function(self)
        if self.onMark then self.onMark() end
    end)
    banner.mark:SetPoint("BOTTOMRIGHT", -10, 10)

    -- tabs
    local x = 0
    for _, def in ipairs(TABS) do
        local tab = ns.CreateButton(dungeonPage, def.label, 96, 24, function()
            activeTab = def.key
            if def.key ~= "loot" then lootFilter.boss = nil end
            ns.RefreshJournal()
        end)
        tab.key = def.key
        tab:SetPoint("TOPLEFT", banner, "BOTTOMLEFT", x, -6)
        x = x + 100
        tabButtons[#tabButtons + 1] = tab
    end

    local holder = CreateFrame("Frame", nil, dungeonPage, ns.BACKDROP)
    holder:SetPoint("TOPLEFT", banner, "BOTTOMLEFT", 0, -36)
    holder:SetPoint("BOTTOMRIGHT")
    ns.Skin(holder, { 0.08, 0.08, 0.09, 0.9 }, ns.color.border)
    detailScroll = CreateFrame("ScrollFrame", nil, holder)
    detailScroll:SetPoint("TOPLEFT", 10, -10)
    detailScroll:SetPoint("BOTTOMRIGHT", -10, 10)
    detailContent = CreateFrame("Frame", nil, detailScroll)
    detailContent:SetSize(CONTENT_W, 10)
    detailScroll:SetScrollChild(detailContent)
    detailScroll:EnableMouseWheel(true)
    detailScroll:SetScript("OnMouseWheel", function(self, delta) ScrollBy(self, detailContent, delta, 40) end)
end

function ns.BuildJournalTab(parent)
    page = parent
    BuildBrowser()
    BuildPage()
    dungeonPage:Hide()
    local legend = ns.Text(page, 10, ns.color.dim)
    legend:SetPoint("BOTTOMLEFT", PAD, 6)
    legend:SetText("Mark: show on your map   Set: save where you stand   Shift: compare items   Shift-click: link in chat")
    page:SetScript("OnShow", ns.RefreshJournal)
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------
local refreshQueued = false
local function QueueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0.3, function()
        refreshQueued = false
        ns.RefreshJournal()
    end)
end

table.insert(ns.inits, function()
    ns.db.journal = ns.db.journal or {}
    ns.db.journal.quests = ns.db.journal.quests or {}
    ns.db.journal.loot = ns.db.journal.loot or {}
    ns.db.journal.markers = ns.db.journal.markers or {} -- your own "Set" positions
    ns.db.journal.pickups = ns.db.journal.pickups or {} -- where each quest was accepted
    ns.db.journal.turnins = ns.db.journal.turnins or {} -- where each quest was handed in
    IndexDungeons()

    ns.On("QUEST_DETAIL", OnQuestDetail)
    ns.On("QUEST_ACCEPTED", OnQuestAccepted)
    ns.On("QUEST_TURNED_IN", OnQuestTurnedIn)
    ns.On("LOOT_OPENED", OnLootOpened)
    ns.On("GET_ITEM_INFO_RECEIVED", function(_, itemID)
        RefreshHoveredTooltip(itemID)
        -- only the loot grid shows item names and icons that arrive late
        if view == "page" and activeTab == "loot" then QueueRefresh() end
    end)
    ns.On("MODIFIER_STATE_CHANGED", function() RefreshHoveredTooltip() end) -- Shift toggles comparison
    -- quest status and progress only change when you take, finish or drop a quest
    -- (QUEST_LOG_UPDATE fires constantly, so it isn't used here)
    for _, event in ipairs({ "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED" }) do
        ns.On(event, function()
            ns.ClearJournalQuestCache()
            C_Timer.After(0.5, QueueRefresh)
        end)
    end
end)
