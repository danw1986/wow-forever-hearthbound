local ADDON_NAME, ns = ...

-- Enemy cards: every different enemy you kill adds its card to your
-- collection, filed by zone. Each zone's list is the enemies its quests send
-- you after (QuestieDB's kill objectives and quest item drops), so you can see
-- what you've got and what's still out there. Anything else you defeat gets a
-- card too, filed under where you got it.
--
-- A card is the enemy's own 3D model standing in front of a scene for its
-- creature type (Media\Cards\Art_*.tga), inside that type's frame, with a
-- gem for its rank: grey normal, gold elite, blue rare, purple rare elite,
-- orange boss.
--
-- Collected cards are kept per character in ns.cdb.cards[name].

local format = string.format
local Safe = ns.Safe

local MEDIA = "Interface\\AddOns\\Hearthbound\\Media\\Cards\\"
local CARD_V = 360 / 512 -- the card uses the top 360 rows of its 512-high textures
local CARD_W, CARD_H = 120, 168
local SCALE = CARD_W / 256
local ART = { 18 * SCALE, 44 * SCALE, 238 * SCALE, 236 * SCALE } -- the art window inside the frame
local GRID_COLS, GRID_ROWS = 5, 3
local GAP_X, GAP_Y = 14, 16
local HEADER_H = 98   -- title, your total and the rarity chips
local GRID_TOP = 38   -- the zone's title and the filters, above the cards
local ZONE_W, ZONE_ROW_H = 236, 22
local GRID_W = GRID_COLS * CARD_W + (GRID_COLS - 1) * GAP_X
local WIN_W = 14 + ZONE_W + 12 + GRID_W + 26 + 14
local WIN_H = HEADER_H + GRID_TOP + GRID_ROWS * CARD_H + (GRID_ROWS - 1) * GAP_Y + 40 + 14
-- as many zones as fit in their panel
local ZONE_ROWS = math.floor((WIN_H - HEADER_H - 14 - 54 - 24) / ZONE_ROW_H)
local SCAN_PER_TICK = 150 -- NPCs read per frame: about a second for all of them, without a hitch

local RANK_COLOUR = {
    normal = { 0.75, 0.75, 0.78 }, elite = { 1.0, 0.82, 0.35 }, rare = { 0.55, 0.75, 1.0 },
    rareelite = { 0.8, 0.5, 1.0 }, boss = { 1.0, 0.55, 0.2 },
}
local RANK_LABEL = { normal = "", elite = "Elite ", rare = "Rare ", rareelite = "Rare Elite ", boss = "Boss " }
local QUESTIE_RANKS = { [1] = "elite", [2] = "rareelite", [3] = "boss", [4] = "rare" }

-- creature type (as the game names it) -> backdrop
local ART_FOR = {
    Beast = "Beast", Humanoid = "Humanoid", Undead = "Undead", Demon = "Demon", Elemental = "Elemental",
    Dragonkin = "Dragonkin", Giant = "Giant", Mechanical = "Mechanical", Critter = "Critter", Totem = "Totem",
    ["Non-combat Pet"] = "Critter", ["Wild Pet"] = "Critter", ["Gas Cloud"] = "Elemental",
}

---------------------------------------------------------------------------
-- The collection
---------------------------------------------------------------------------
local function Collected()
    ns.cdb.cards = ns.cdb.cards or {}
    return ns.cdb.cards
end

local function CollectedCount()
    local n = 0
    for _ in pairs(Collected()) do n = n + 1 end
    return n
end
ns.CardCount = CollectedCount

-- what Kills.lua remembers about a mob it has seen: { t = type, c = rank }
local function SeenInfo(name)
    return ns.db.creatureInfo and ns.db.creatureInfo[name]
end

---------------------------------------------------------------------------
-- Every enemy, from QuestieDB, built a little at a time
---------------------------------------------------------------------------
local index       -- { byName = { name -> card }, zones = { areaId -> zone }, zoneList = { zone... }, total }
local scanning = false
local scanWaiters = {}
local scanProblem -- why the enemy list couldn't be read, for /hb cards debug

local JUNK = { "Spawn Point", "Trigger", "Bunny", "DND", "Invisible", "Dummy", "[PH]", "(", "Test", "TEST",
               " Totem", "Reveler", "KILL CREDIT", "Kill Credit", "Brazier", "Wardrobe" }
local function Junk(name)
    if name == "" then return true end
    for _, word in ipairs(JUNK) do
        if name:find(word, 1, true) then return true end
    end
    return false
end

local function ZoneName(areaId)
    if C_Map and C_Map.GetAreaInfo then
        local name = Safe(C_Map.GetAreaInfo, areaId)
        if type(name) == "string" and name ~= "" then return name end
    end
    local mapID = ns.UiMapForArea and ns.UiMapForArea(areaId)
    local info = mapID and Safe(C_Map.GetMapInfo, mapID)
    return info and info.name or nil
end

local FIELDS = { "name", "minLevel", "maxLevel", "rank", "zoneID", "friendlyToFaction", "subName",
                 "npcFlags", "questStarts", "questEnds", "factionID" }
local MAX_LEVEL = 63 -- above this it's a placeholder ("9999") rather than a real enemy

-- QuestieDB's faction table: faction template -> who it's hostile to
-- (bit 1 every player, 2 the Alliance, 4 the Horde, 8 monsters)
local factionEnemies
local function FactionEnemies()
    if factionEnemies ~= nil then return factionEnemies or nil end
    factionEnemies = false
    local l = rawget(_G, "LibQuestieDB")
    local ok, db = pcall(function() return l.Support.Get("QuestieDB") end)
    local t = ok and type(db) == "table" and db.factionTemplate
    if type(t) == "string" and loadstring then
        local chunk = loadstring(t)
        local okRun, result = pcall(chunk or function() end)
        t = okRun and result or nil
    end
    if type(t) == "table" then factionEnemies = t end
    return factionEnemies or nil
end

-- "yes" an enemy, "no" not, "maybe" can't tell from the data (shown once you meet one you can attack)
-- v: the FIELDS row
local function Verdict(v, mine)
    local friendly, title, flags = v[6], v[7], v[8]
    local townsfolk = (type(title) == "string" and title ~= "") or (type(flags) == "number" and flags > 0)
        or type(v[9]) == "table" or type(v[10]) == "table"
    local enemies = FactionEnemies()
    local mask = type(v[11]) == "number" and enemies and enemies[v[11]]
    if type(mask) == "number" then
        local myBit = mine == "A" and 2 or 4
        if math.floor(mask / myBit) % 2 == 1 or mask % 2 == 1 then return "yes" end -- hostile to you
        if mask == 0 then return townsfolk and "no" or "yes" end                  -- neutral: boars and the like
        return "no"                                                                 -- friendly
    end
    -- no faction recorded (most of Forever's new NPCs): go by who it's friendly to
    if type(friendly) ~= "string" or friendly == "" then return townsfolk and "maybe" or "yes" end
    if townsfolk then return "no" end
    if not (friendly:find("A", 1, true) and friendly:find("H", 1, true)) then
        -- friendly to one faction only, with no faction recorded: one side's own people
        -- (Forever's new NPCs; the old ones all have a faction)
        return "no"
    end
    return "maybe" -- "friendly to both" with nothing else to go on: villagers and cultists look alike
end

-- QuestieDB's dungeons: area ID (and each wing's extra IDs) -> { id = the dungeon's area, name }
local dungeonAreas
local function DungeonAreas()
    if dungeonAreas then return dungeonAreas end
    dungeonAreas = {}
    local l = rawget(_G, "LibQuestieDB")
    local ok, zoneDB = pcall(function() return l.Support.Get("ZoneDB") end)
    local list = ok and type(zoneDB) == "table" and type(zoneDB.private) == "table" and zoneDB.private.dungeons
    if type(list) == "string" and loadstring then
        local chunk = loadstring(list)
        local okRun, result = pcall(chunk or function() end)
        list = okRun and result or nil
    end
    for areaId, entry in pairs(type(list) == "table" and list or {}) do
        if type(areaId) == "number" and type(entry) == "table" and type(entry[1]) == "string" then
            local info = { id = areaId, name = entry[1] }
            dungeonAreas[areaId] = info
            for _, alt in ipairs(type(entry[2]) == "table" and entry[2] or {}) do
                if type(alt) == "number" then dungeonAreas[alt] = info end
            end
        end
    end
    return dungeonAreas
end

-- put one QuestieDB NPC (id, FIELDS row) into an index's cards and zones
local function AddCard(built, id, v)
    local name, zoneId = v[1], v[5]
    -- a dungeon's wings are filed under the dungeon
    local dungeon = DungeonAreas()[zoneId]
    if dungeon then zoneId = dungeon.id end
    local card = built.byName[name]
    if not card then
        card = { name = name, ids = {}, minLevel = v[2], maxLevel = v[3] or v[2],
                 rank = QUESTIE_RANKS[v[4] or 0] or "normal", sub = v[7], zones = {} }
        built.byName[name] = card
        built.total = built.total + 1
    else
        card.minLevel = math.min(card.minLevel, v[2])
        card.maxLevel = math.max(card.maxLevel, v[3] or v[2])
    end
    card.ids[#card.ids + 1] = id
    if not card.zones[zoneId] then
        local zone = built.zones[zoneId]
        if not zone then
            local zname = (dungeon and dungeon.name) or ZoneName(zoneId)
            if zname then
                zone = { id = zoneId, name = zname, cards = {}, dungeon = dungeon and true or nil }
                built.zones[zoneId] = zone
            end
        end
        if zone then
            card.zones[zoneId] = true
            zone.cards[#zone.cards + 1] = card
        end
    end
    return card
end

local function ByLevel(a, b)
    if a.minLevel ~= b.minLevel then return a.minLevel < b.minLevel end
    return a.name < b.name
end

local function Finish(built)
    local list = {}
    for _, zone in pairs(built.zones) do
        table.sort(zone.cards, function(a, b)
            if a.minLevel ~= b.minLevel then return a.minLevel < b.minLevel end
            return a.name < b.name
        end)
        zone.minLevel = zone.cards[1] and zone.cards[1].minLevel or 0
        list[#list + 1] = zone
    end
    table.sort(list, function(a, b)
        if a.minLevel ~= b.minLevel then return a.minLevel < b.minLevel end
        return a.name < b.name
    end)
    built.zoneList = list
    index = built
    scanning = false
    local waiters = scanWaiters
    scanWaiters = {}
    for _, fn in ipairs(waiters) do pcall(fn) end
end

-- Quest objectives: { creatures {{id, text}}, objects, items {{id}}, reputation, kill credit {{{ids}, base, text}} }
local function ObjectiveIds(objectives, mobs, items)
    if type(objectives) ~= "table" then return end
    for _, o in ipairs(type(objectives[1]) == "table" and objectives[1] or {}) do
        if type(o) == "table" and type(o[1]) == "number" then mobs[o[1]] = true end
    end
    for _, o in ipairs(type(objectives[3]) == "table" and objectives[3] or {}) do
        if type(o) == "table" and type(o[1]) == "number" then items[o[1]] = true end
    end
    for _, o in ipairs(type(objectives[5]) == "table" and objectives[5] or {}) do
        if type(o) == "table" and type(o[1]) == "table" then
            for _, id in ipairs(o[1]) do if type(id) == "number" then mobs[id] = true end end
        end
    end
end

-- The cards are the enemies quests send you after: every NPC a quest needs
-- killed, and the ones that drop the items quests ask for (and that aren't on
-- your side - quests also list people you only talk to) - plus every enemy
-- inside a dungeon, quest or not. Read in passes, a slice per frame: quests,
-- quest items, those NPCs, then the NPCs filed in dungeons.
local function Scan(onDone)
    if index then
        if onDone then onDone() end
        return
    end
    if onDone then scanWaiters[#scanWaiters + 1] = onDone end
    if scanning then return end
    local l = rawget(_G, "LibQuestieDB")
    local function GiveUp(why)
        scanProblem = why
        scanning = false
        local waiters = scanWaiters
        scanWaiters = {}
        for _, fn in ipairs(waiters) do pcall(fn) end
    end
    if not (l and l.Npc and l.Npc.GetAll and l.Quest and l.Quest.GetAllIds and l.Quest.Get and l.Item and l.Item.Get) then
        return GiveUp("QuestieDB isn't loaded")
    end
    local ok, questIds = pcall(l.Quest.GetAllIds)
    if not ok or type(questIds) ~= "table" then return GiveUp("QuestieDB wouldn't list its quests: " .. tostring(questIds)) end
    scanning = true
    local mine = UnitFactionGroup("player") == "Alliance" and "A" or "H"
    local built = { byName = {}, zones = {}, total = 0 }
    local mobs, items = {}, {}
    local pass, list, i = "quests", questIds, 1
    local Step
    local function Guarded()
        local okStep, err = pcall(Step)
        if not okStep then
            -- keep what was read so far rather than waiting for ever
            scanProblem = "stopped in " .. pass .. " at " .. tostring(list[i]) .. ": " .. tostring(err)
            Finish(built)
        end
    end
    local function Keys(set)
        local out = {}
        for id in pairs(set) do out[#out + 1] = id end
        table.sort(out)
        return out
    end
    function Step()
        local stop = math.min(#list, i + SCAN_PER_TICK - 1)
        for k = i, stop do
            local id = list[k]
            if pass == "quests" then
                local okQ, objectives = pcall(l.Quest.Get, id, "objectives")
                if okQ then ObjectiveIds(objectives, mobs, items) end
            elseif pass == "items" then
                local okI, drops = pcall(l.Item.Get, id, "npcDrops")
                if okI and type(drops) == "table" then
                    for _, npcId in ipairs(drops) do if type(npcId) == "number" then mobs[npcId] = true end end
                end
            else
                -- in the dungeon pass, only NPCs filed in a dungeon (one cheap field first)
                local wanted = true
                if pass == "dungeons" then
                    local okZ, zoneId = pcall(l.Npc.Get, id, "zoneID")
                    wanted = okZ and DungeonAreas()[zoneId] ~= nil and not mobs[id]
                end
                local okRow, v
                if wanted then okRow, v = pcall(l.Npc.GetAll, id, FIELDS) end
                local name, zoneId = okRow and v and v[1], okRow and v and v[5]
                if type(name) == "string" and not Junk(name) and type(zoneId) == "number" and zoneId > 0
                    and type(v[2]) == "number" and v[2] > 0 and v[2] <= MAX_LEVEL
                    -- a quest wants it dead, or it's in a dungeon: either way "maybe" is settled
                    and Verdict(v, mine) ~= "no" then
                    AddCard(built, id, v)
                end
            end
        end
        i = stop + 1
        if i <= #list then
            C_Timer.After(0, Guarded)
        elseif pass == "quests" then
            pass, list, i = "items", Keys(items), 1
            C_Timer.After(0, Guarded)
        elseif pass == "items" then
            pass, list, i = "enemies", Keys(mobs), 1
            C_Timer.After(0, Guarded)
        elseif pass == "enemies" and next(DungeonAreas()) and l.Npc.GetAllIds then
            local okIds, npcIds = pcall(l.Npc.GetAllIds)
            if okIds and type(npcIds) == "table" then
                pass, list, i = "dungeons", npcIds, 1
                C_Timer.After(0, Guarded)
            else
                Finish(built)
            end
        else
            Finish(built)
        end
    end
    Guarded()
end

---------------------------------------------------------------------------
-- Enemies you've defeated that aren't on the quest list: filed under the zone
-- you got them in (account-wide). ns.db.cardsFound[zone name][enemy] = { id, lo, hi, c }
---------------------------------------------------------------------------
local FOUND_RANKS = { elite = "elite", rare = "rare", rareelite = "rareelite", worldboss = "boss" }

local function Found()
    ns.db.cardsFound = ns.db.cardsFound or {}
    if not ns.db.cardsFoundKillsOnly then
        -- earlier versions also noted enemies you'd only seen: keep the ones you've collected
        local got = ns.cdb.cards or {}
        for zoneName, enemies in pairs(ns.db.cardsFound) do
            for name in pairs(enemies) do
                if not got[name] then enemies[name] = nil end
            end
            if not next(enemies) then ns.db.cardsFound[zoneName] = nil end
        end
        ns.db.cardsConfirmed = nil
        ns.db.cardsFoundKillsOnly = true
    end
    return ns.db.cardsFound
end

local function NoteFound(name, zoneName, id, level, rank)
    if not (index and type(name) == "string" and type(zoneName) == "string") then return end
    if index.byName[name] then return end -- QuestieDB has it
    local zone = Found()[zoneName]
    if not zone then
        zone = {}
        Found()[zoneName] = zone
    end
    local f = zone[name] or {}
    f.id = f.id or id
    if type(level) == "number" and level > 0 then
        f.lo = math.min(f.lo or level, level)
        f.hi = math.max(f.hi or level, level)
    end
    f.c = f.c or rank
    zone[name] = f
end

-- the index's zones plus the found ones (and found enemies added to known zones),
-- rebuilt whenever the window draws
local combined = { list = {}, byId = {}, byName = {}, extra = 0 }

local function Combine()
    local list, byId, byName, extra = {}, {}, {}, 0
    for _, z in ipairs(index and index.zoneList or {}) do
        local zone = { id = z.id, name = z.name, minLevel = z.minLevel, cards = z.cards, dungeon = z.dungeon }
        list[#list + 1] = zone
        byId[zone.id] = zone
        byName[zone.name] = byName[zone.name] or zone
    end
    for zoneName, enemies in pairs(Found()) do
        local zone = byName[zoneName]
        if not zone then
            zone = { id = "found:" .. zoneName, name = zoneName, cards = {}, found = true }
            list[#list + 1] = zone
            byId[zone.id] = zone
            byName[zoneName] = zone
        else
            local copy = {} -- leave the index's own list alone
            for i, c in ipairs(zone.cards) do copy[i] = c end
            zone.cards = copy
        end
        for name, f in pairs(enemies) do
            if not (index and index.byName[name]) then
                zone.cards[#zone.cards + 1] = { name = name, ids = { f.id }, minLevel = f.lo or 0, maxLevel = f.hi or f.lo or 0,
                                                rank = f.c or "normal", zones = {}, found = zoneName }
                extra = extra + 1
            end
        end
        table.sort(zone.cards, ByLevel)
        zone.minLevel = zone.cards[1] and zone.cards[1].minLevel or 0
    end
    table.sort(list, ByLevel)
    combined = { list = list, byId = byId, byName = byName, extra = extra }
    return combined
end

-- one card's numbers for a zone (or every zone)
local function ZoneProgress(zone)
    local have = 0
    local got = Collected()
    for _, card in ipairs(zone.cards) do
        if got[card.name] then have = have + 1 end
    end
    return have, #zone.cards
end

local function ZonesText(card)
    if card.found then return card.found end
    local names = {}
    for zoneId in pairs(card.zones or {}) do
        local zone = index and index.zones[zoneId]
        if zone then names[#names + 1] = zone.name end
    end
    table.sort(names)
    return table.concat(names, ", ")
end

---------------------------------------------------------------------------
-- A card on screen
--
-- Layers, back to front: the type's scene, the enemy's 3D model, a vignette,
-- then the type's frame with the name, rank gem, level badge and stats.
-- Cards lift a little on hover, and the model turns.
---------------------------------------------------------------------------
local function TypeOf(name, entry)
    local seen = SeenInfo(name)
    return (entry and entry.t) or (seen and seen.t) or nil
end

local function RankOf(name, card, entry)
    local seen = SeenInfo(name)
    return (seen and seen.c ~= "normal" and seen.c) or (card and card.rank) or (entry and entry.c) or "normal"
end

local function LevelText(card, entry)
    if card then
        return card.minLevel == card.maxLevel and tostring(card.minLevel) or (card.minLevel .. "-" .. card.maxLevel)
    end
    return entry and entry.level and tostring(entry.level) or "?"
end

local RANK_NAME = { normal = "Common", elite = "Elite", rare = "Rare", rareelite = "Rare Elite", boss = "Boss" }
local ICON_KILLS = "|TInterface\\Icons\\INV_Sword_04:10:10:0:0:64:64:5:59:5:59|t"
local ICON_ZONE = "|TInterface\\Icons\\INV_Misc_Map02:10:10:0:0:64:64:5:59:5:59|t"
local ICON_LOCK = "|TInterface\\Icons\\INV_Misc_Key_03:12:12:0:0:64:64:5:59:5:59|t"

-- every card on screen is animated by one driver (see below)
local liveCards = {}

local function OverArt(tex, parent)
    tex:SetPoint("TOPLEFT", parent, "TOPLEFT", ART[1], -ART[2])
    tex:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", ART[3], -ART[4])
end

local function BuildCard(parent)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(CARD_W, CARD_H)
    -- everything sits on a body centred in the button, so it can grow on hover
    local body = CreateFrame("Frame", nil, f)
    body:SetSize(CARD_W, CARD_H)
    body:SetPoint("CENTER")
    f.body = body

    f.art = body:CreateTexture(nil, "BACKGROUND")
    OverArt(f.art, body)

    f.model = CreateFrame("PlayerModel", nil, body)
    OverArt(f.model, body)
    f.model:SetFrameLevel(body:GetFrameLevel() + 1)

    -- a vignette over the picture
    f.fx = CreateFrame("Frame", nil, body)
    f.fx:SetAllPoints(body)
    f.fx:SetFrameLevel(body:GetFrameLevel() + 2)
    f.shade = f.fx:CreateTexture(nil, "ARTWORK")
    f.shade:SetTexture(MEDIA .. "ArtShade")
    OverArt(f.shade, body)

    f.over = CreateFrame("Frame", nil, body)
    f.over:SetAllPoints(body)
    f.over:SetFrameLevel(body:GetFrameLevel() + 3)
    f.frame = f.over:CreateTexture(nil, "ARTWORK")
    f.frame:SetAllPoints(body)
    f.frame:SetTexture(MEDIA .. "Frame_Unknown") -- each type has its own frame (FillCard)
    f.frame:SetTexCoord(0, 1, 0, CARD_V)
    f.back = f.over:CreateTexture(nil, "ARTWORK", nil, 2)
    f.back:SetAllPoints(body)
    f.back:SetTexture(MEDIA .. "Back")
    f.back:SetTexCoord(0, 1, 0, CARD_V)

    -- the level: a badge on the picture's top-left corner, as wide as its text
    f.badge = CreateFrame("Frame", nil, f.over, ns.BACKDROP)
    f.badge:SetPoint("TOPLEFT", body, "TOPLEFT", ART[1] + 5, -ART[2] - 4)
    f.badge:SetHeight(14)
    ns.Skin(f.badge, { 0.04, 0.04, 0.05, 0.9 }, ns.color.border)
    f.level = ns.Text(f.badge, 9, { 1, 1, 1, 1 }, "OUTLINE")
    f.level:SetPoint("CENTER", 0, 0)
    -- the name, between the corner ornaments
    f.name = ns.Text(f.over, 10, { 1, 0.97, 0.9, 1 })
    f.name:SetPoint("TOPLEFT", body, "TOPLEFT", 20, -8)
    f.name:SetPoint("TOPRIGHT", body, "TOPRIGHT", -20, -8)
    f.name:SetJustifyH("CENTER")
    f.name:SetWordWrap(false)
    -- the rank gem, set in the divider under the picture
    f.gem = f.over:CreateTexture(nil, "OVERLAY")
    f.gem:SetSize(15, 15)
    f.gem:SetPoint("CENTER", body, "TOPLEFT", CARD_W / 2, -241 * SCALE)
    f.gem:SetTexture(MEDIA .. "Gem")
    -- under it: rank and type, then the stats
    f.kind = ns.Text(f.over, 9, ns.color.gold, "OUTLINE")
    f.kind:SetPoint("TOPLEFT", body, "TOPLEFT", 11, -ART[4] - 11)
    f.kind:SetPoint("TOPRIGHT", body, "TOPRIGHT", -11, -ART[4] - 11)
    f.kind:SetJustifyH("CENTER")
    f.kind:SetWordWrap(false)
    f.info = ns.Text(f.over, 9, { 0.85, 0.85, 0.85, 1 })
    f.info:SetPoint("TOPLEFT", f.kind, "BOTTOMLEFT", 0, -4)
    f.info:SetPoint("TOPRIGHT", f.kind, "BOTTOMRIGHT", 0, -4)
    f.info:SetJustifyH("CENTER")
    f.info:SetWordWrap(false)
    -- the back of an uncollected card: what it is, greyed, with a lock
    f.missing = ns.Text(f.over, 10, { 0.85, 0.78, 0.62, 1 }, "OUTLINE")
    f.missing:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 8, 18)
    f.missing:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -8, 18)
    f.missing:SetJustifyH("CENTER")

    f.scale, f.facing, f.phase = 1, -0.35, math.random() * 5
    f:SetScript("OnEnter", function(self)
        self.hover = true
        if not self.cardName then return end
        local card, entry = self.card, Collected()[self.cardName]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.cardName, 1, 1, 1)
        if card and card.sub then GameTooltip:AddLine("<" .. card.sub .. ">", 0.8, 0.8, 0.8) end
        local rank = RankOf(self.cardName, card, entry)
        local kind = (RANK_LABEL[rank] or "") .. (TypeOf(self.cardName, entry) or "Enemy")
        GameTooltip:AddLine(format("Level %s %s", LevelText(card, entry), kind), unpack(RANK_COLOUR[rank] or RANK_COLOUR.normal))
        if card then GameTooltip:AddLine(ZonesText(card), 0.7, 0.7, 0.7, true) end
        if entry then
            GameTooltip:AddLine(format("Collected %s - killed %d time%s", date("%d %b %Y", entry.at or time()),
                entry.kills or 1, (entry.kills or 1) == 1 and "" or "s"), 0.45, 0.85, 0.45)
            if entry.zone then GameTooltip:AddLine("First taken down in " .. entry.zone, 0.6, 0.6, 0.6) end
        else
            GameTooltip:AddLine("Not collected yet - defeat one to add its card.", 0.6, 0.6, 0.6)
        end
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function(self)
        self.hover = false
        GameTooltip:Hide()
    end)
    liveCards[#liveCards + 1] = f
    return f
end

-- show one enemy on a card: name, and the card from the index (or nil)
local function FillCard(f, name, card)
    f.cardName, f.card = name, card
    local entry = Collected()[name]
    if not name then
        f:Hide()
        return
    end
    f:Show()
    local rank = RankOf(name, card, entry)
    local tint = RANK_COLOUR[rank] or RANK_COLOUR.normal
    f.tint = tint
    if not entry then
        f.back:Show()
        for _, part in ipairs({ f.art, f.model, f.frame, f.gem, f.badge, f.shade }) do part:Hide() end
        f.back:SetVertexColor(0.8, 0.8, 0.8)
        f.name:SetText("")
        f.kind:SetText("")
        f.info:SetText("")
        f.missing:SetText(ICON_LOCK .. "\n" .. name .. "\n|cff999999Level " .. LevelText(card, entry) .. "|r")
        return
    end
    f.back:Hide()
    f.missing:SetText("")
    local creatureType = TypeOf(name, entry)
    local style = ART_FOR[creatureType or ""] or "Unknown"
    -- a frame in the style of its creature type; the gem says its rank
    f.frame:SetTexture(MEDIA .. "Frame_" .. style)
    f.frame:Show()
    f.gem:SetVertexColor(tint[1], tint[2], tint[3])
    f.gem:Show()
    f.art:SetTexture(MEDIA .. "Art_" .. style)
    f.art:Show()
    f.shade:Show()
    f.level:SetText(LevelText(card, entry))
    f.badge:SetWidth(math.ceil(f.level:GetStringWidth()) + 10)
    f.badge:SetBackdropBorderColor(tint[1], tint[2], tint[3], 0.95)
    f.badge:Show()
    f.name:SetText(name)
    f.kind:SetText(((RANK_LABEL[rank] or "") .. (creatureType or "Enemy")):upper())
    f.kind:SetTextColor(tint[1], tint[2], tint[3])
    local where = entry.zone or (card and ZonesText(card)) or ""
    f.info:SetText(format("%s %d   %s %s", ICON_KILLS, entry.kills or 1, ICON_ZONE, where))
    -- the enemy itself: its 3D model, if the game has it to hand
    local npcId = entry.npc or (card and card.ids[1])
    f.model:ClearModel()
    f.facing = -0.35
    if npcId and f.model.SetCreature then
        f.model:Show()
        pcall(f.model.SetCreature, f.model, npcId)
        pcall(f.model.SetFacing, f.model, f.facing)
    else
        f.model:Hide()
    end
end

-- One OnUpdate for every card: the hover lift and the turning model. Cards
-- that aren't on screen cost nothing.
local function Animate(f, now, dt)
    local target = f.hover and 1.05 or 1
    if math.abs(f.scale - target) > 0.001 then
        f.scale = f.scale + (target - f.scale) * math.min(1, dt * 14)
        f.body:SetScale(f.scale)
    end
    -- the model turns slowly while you look at it
    if f.hover and f.model:IsShown() then
        f.facing = f.facing + dt * 0.9
        pcall(f.model.SetFacing, f.model, f.facing)
    end
end

local driver = CreateFrame("Frame")
driver:SetScript("OnUpdate", function(_, dt)
    local now = GetTime()
    for _, f in ipairs(liveCards) do
        if f:IsVisible() then Animate(f, now, dt) end
    end
end)

---------------------------------------------------------------------------
-- New card pop-up: the card springing in, with its rank
---------------------------------------------------------------------------
local popup, popupQueue = nil, {}
local POPUP_SCALE, POPUP_HOLD = 1.45, 5

local function ShowNextPopup()
    if not popup or popup.busy or #popupQueue == 0 then return end
    local item = table.remove(popupQueue, 1)
    popup.busy = true
    FillCard(popup.card, item.name, item.card)
    local rank = RankOf(item.name, item.card, Collected()[item.name])
    local tint = RANK_COLOUR[rank] or RANK_COLOUR.normal
    popup.rank:SetText((RANK_NAME[rank] or "Common"):upper())
    popup.rank:SetTextColor(tint[1], tint[2], tint[3])
    popup.count:SetText(item.count)
    popup:SetAlpha(0)
    popup:Show()
    popup.elapsed = 0
end

local function BuildPopup()
    popup = CreateFrame("Frame", "HearthboundCardPopup", UIParent)
    popup:SetSize(CARD_W * POPUP_SCALE + 40, CARD_H * POPUP_SCALE + 70)
    popup:SetPoint("TOP", UIParent, "TOP", 0, -110) -- top middle, below the minimap row and buffs
    popup:SetFrameStrata("HIGH")
    popup.title = ns.Text(popup, 18, { 1, 0.86, 0.45, 1 }, "OUTLINE")
    popup.title:SetPoint("TOP", 0, 0)
    popup.title:SetText("NEW CARD")
    popup.rank = ns.Text(popup, 11, ns.color.gold, "OUTLINE")
    popup.rank:SetPoint("TOP", popup.title, "BOTTOM", 0, -2)
    popup.card = BuildCard(popup)
    -- one size, set once: the 3D model's camera is fitted to the card when it loads
    popup.card:SetScale(POPUP_SCALE)
    popup.card:SetPoint("CENTER", popup, "CENTER", 0, -6 / POPUP_SCALE)
    popup.card:EnableMouse(false)
    popup.count = ns.Text(popup, 11, ns.color.text, "OUTLINE")
    popup.count:SetPoint("BOTTOM", 0, 0)
    popup:EnableMouse(true)
    popup:SetScript("OnMouseUp", function() ns.ToggleCards() end)
    popup:SetScript("OnUpdate", function(self, dt)
        self.elapsed = self.elapsed + dt
        local t = self.elapsed
        if t < 0.2 then
            self:SetAlpha(t / 0.2)
        elseif t < POPUP_HOLD then
            self:SetAlpha(1)
        elseif t < POPUP_HOLD + 0.6 then
            self:SetAlpha(1 - (t - POPUP_HOLD) / 0.6)
        else
            self:Hide()
            self.busy = false
            ShowNextPopup()
        end
    end)
    popup:Hide()
end

---------------------------------------------------------------------------
-- Collecting
---------------------------------------------------------------------------
local npcByName = {} -- name -> NPC ID, from units you've looked at this session
local seenUnit = {}  -- name -> { id, level, rank } for enemies outside the quest list, this session

local function NpcIdOf(unit)
    local guid = Safe(UnitGUID, unit)
    if type(guid) ~= "string" then return nil end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind == "Creature" or kind == "Vehicle" then return tonumber(id) end
end

local function Look(unit)
    if Safe(UnitExists, unit) ~= true or Safe(UnitIsPlayer, unit) ~= false then return end
    local name = Safe(UnitName, unit)
    local id = NpcIdOf(unit)
    if type(name) == "string" and id then npcByName[name] = id end
    -- remember its level and rank, in case you defeat one that isn't a quest enemy
    if type(name) == "string" and index and not index.byName[name] and Safe(UnitCanAttack, "player", unit) == true then
        seenUnit[name] = { id = id, level = Safe(UnitLevel, unit), rank = FOUND_RANKS[Safe(UnitClassification, unit) or ""] }
    end
end

local hooked = false
local recent = {} -- name -> time, so an XP kill and a target death don't count twice
local lastKill    -- what the last kill did, for /hb cards debug
local watching    -- the enemy you're targeting: { name, guid }, collected if it dies while targeted

local function Announce(name)
    local card = index and index.byName[name]
    local count = format("%d cards collected", CollectedCount())
    -- how this zone's set is going
    local here = Safe(GetRealZoneText)
    local zone = here and Combine().byName[here]
    if zone then
        for _, c in ipairs(zone.cards) do
            if c.name == name then
                card = card or c
                local have, total = ZoneProgress(zone)
                count = format("%s: %d / %d", zone.name, have, total)
                break
            end
        end
    end
    if ns.db.cardPopups then
        if not popup then BuildPopup() end
        popupQueue[#popupQueue + 1] = { name = name, card = card, count = count }
        ShowNextPopup()
    end
    ns.Print(format("New card: |cffffd200%s|r  (%s)  |cffc79c6e/hb cards|r", name, count))
    if ns.RefreshCards then ns.RefreshCards() end
end

-- A new enemy's card is yours the moment you defeat it (spotted by the XP for
-- the kill, your target dying, or looting the corpse - whichever comes first)
local pending = {} -- name -> GetTime(): a card being handed over
local Claim

function ns.CollectCard(name, how)
    lastKill = { name = tostring(name), how = how or "?", at = time() }
    if not ns.db.cards then lastKill.result = "card collection is switched off" return end
    if type(name) ~= "string" or ns.IsSecret(name) or name == "" then lastKill.result = "no usable name" return end
    local now = GetTime()
    local got = Collected()
    local entry = got[name]
    if how == "looted" then
        -- the loot window: offer a card that's waiting; the kill itself was counted already
        if pending[name] then lastKill.result = "card waiting in the loot" return true end
        if recent[name] and now - recent[name] < 300 then lastKill.result = "looting a kill already counted" return false end
    elseif recent[name] and now - recent[name] < 2 then
        lastKill.result = "same kill, already counted"
        return false
    end
    recent[name] = now
    if entry then
        entry.kills = (entry.kills or 1) + 1
        lastKill.result = "already collected - kill " .. entry.kills
        return false
    end
    -- the card is yours as soon as it's defeated: straight into the collection
    pending[name] = now
    lastKill.result = "new card"
    Claim(name)
    return false
end

-- the card is yours: into the collection, with the pop-up
function Claim(name)
    if not pending[name] then return end
    pending[name] = nil
    local got = Collected()
    if got[name] then return end
    local seen = SeenInfo(name)
    local entry = { at = time(), kills = 1, level = UnitLevel("player"), npc = npcByName[name],
                    zone = Safe(GetRealZoneText), t = seen and seen.t, c = seen and seen.c }
    got[name] = entry
    local unit = seenUnit[name] or {}
    NoteFound(name, entry.zone, entry.npc or unit.id, unit.level, unit.rank or (entry.c ~= "normal" and entry.c or nil))
    if ns.db.cardSounds then ns.PlaySound(SOUNDKIT and SOUNDKIT.UI_EPICLOOT_TOAST or 31578) end
    if index or scanProblem then
        Announce(name)
    else
        Scan() -- the zone count follows once the enemy list is read; the card is yours now
        Announce(name)
    end
end

---------------------------------------------------------------------------
-- The card in the loot window
---------------------------------------------------------------------------
local lootButtons = {}

local function LootButton(i)
    local b = lootButtons[i]
    if b then return b end
    b = CreateFrame("Button", nil, UIParent, ns.BACKDROP)
    b:SetSize(230, 50)
    b:SetFrameStrata("DIALOG")
    ns.Skin(b, { 0.08, 0.06, 0.03, 0.95 }, { 1, 0.82, 0.35, 1 })
    b.card = b:CreateTexture(nil, "ARTWORK")
    b.card:SetSize(31, 44)
    b.card:SetPoint("LEFT", 4, 0)
    b.card:SetTexture(MEDIA .. "Back")
    b.card:SetTexCoord(0, 1, 0, CARD_V)
    b.title = ns.Text(b, 11, ns.color.gold)
    b.title:SetPoint("TOPLEFT", b.card, "TOPRIGHT", 8, -4)
    b.title:SetText("Enemy card")
    b.name = ns.Text(b, 12, { 1, 1, 1, 1 })
    b.name:SetPoint("TOPLEFT", b.title, "BOTTOMLEFT", 0, -3)
    b.name:SetPoint("RIGHT", -6, 0)
    b.name:SetJustifyH("LEFT")
    b.name:SetWordWrap(false)
    local glow = b:CreateTexture(nil, "BACKGROUND")
    glow:SetPoint("TOPLEFT", -4, 4)
    glow:SetPoint("BOTTOMRIGHT", 4, -4)
    glow:SetColorTexture(1, 0.82, 0.35, 0.25)
    b:SetScript("OnUpdate", function() glow:SetAlpha(0.4 + 0.4 * math.sin(GetTime() * 4)) end)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 0.82, 0.35, 0.15)
    b:SetScript("OnClick", function(self)
        self:Hide()
        if self.cardName then Claim(self.cardName) end
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Enemy card: " .. (self.cardName or "?"), 1, 0.82, 0.35)
        GameTooltip:AddLine("A new card for your collection. Click to take it.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    lootButtons[i] = b
    return b
end

local function HideLootCards()
    for _, b in ipairs(lootButtons) do b:Hide() end
end

-- show the waiting cards under the loot window (or take them, when auto looting)
local function OfferCards(names, autoLoot)
    HideLootCards()
    if #names == 0 then return end
    if autoLoot then
        for _, name in ipairs(names) do Claim(name) end
        return
    end
    -- after the loot window has opened and found its place
    C_Timer.After(0, function()
        local anchor = LootFrame and LootFrame:IsShown() and LootFrame or nil
        for i, name in ipairs(names) do
            if pending[name] then
                local b = LootButton(i)
                b.cardName = name
                b.name:SetText(name)
                b:ClearAllPoints()
                if anchor then
                    b:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6 - (i - 1) * 54)
                else
                    b:SetPoint("CENTER", UIParent, "CENTER", 0, -120 - (i - 1) * 54)
                end
                b:Show()
            end
        end
    end)
end

function ns.CardsDebug()
    ns.Print(format("Cards: %s, pop-ups %s, %d collected.", ns.db.cards and "on" or "|cffff5544off|r",
        ns.db.cardPopups and "on" or "off", CollectedCount()))
    ns.Print("Kill hook: " .. (hooked and "attached to the XP kill tracker" or "|cffff5544not attached|r"))
    ns.Print("Enemy list: " .. (index and format("%d enemies in %d zones", index.total, #index.zoneList)
        or (scanning and "still reading" or "not read yet")) .. (scanProblem and ("  |cffff5544(" .. scanProblem .. ")|r") or ""))
    ns.Print("Watching target: " .. (watching and watching.name or "none (target an enemy to start)"))
    local waiting = {}
    for name, at in pairs(pending) do waiting[#waiting + 1] = format("%s (%ds)", name, GetTime() - at) end
    ns.Print("Cards waiting on corpses: " .. (#waiting > 0 and table.concat(waiting, ", ") or "none"))
    local function Read(fn, ...)
        if not fn then return "missing" end
        local ok, v = pcall(fn, ...)
        if not ok then return "error" end
        if ns.IsSecret(v) then return "|cffff5544hidden|r" end
        return tostring(v)
    end
    if Safe(UnitExists, "target") == true then
        ns.Print(format("Target now: name %s, dead %s, health %s, ID %s, tapped by others %s",
            Read(UnitName, "target"), Read(UnitIsDead, "target"), Read(UnitHealth, "target"),
            Read(UnitGUID, "target") ~= "nil" and (Read(UnitGUID, "target"):find("hidden") and "|cffff5544hidden|r" or "readable") or "nil",
            Read(UnitIsTapDenied, "target")))
    end
    ns.Print(format("XP kills counted this session: %d", ns.cdb.session and ns.cdb.session.kills or 0))
    if lastKill then
        ns.Print(format("Last kill: %s (%s, %ds ago) - %s", lastKill.name, lastKill.how, time() - lastKill.at, lastKill.result or "?"))
    else
        ns.Print("Last kill: none seen since login - if you've killed something, the kill tracker isn't reaching the cards.")
    end
end

-- a line for enemy tooltips (MobTips.lua)
function ns.CardTooltipLine(name)
    if not (ns.db.cards and ns.db.cardTooltips and type(name) == "string") then return nil end
    local entry = Collected()[name]
    if entry then
        return format("Card collected (killed %d)", entry.kills or 1), 0.45, 0.85, 0.45
    end
    return "New card - defeat it to collect", 1, 0.82, 0.35
end

---------------------------------------------------------------------------
-- The collection window
--
-- A header with your total and a chip per rarity; zones down the left in
-- their own panel; the cards in a display panel on the right, with filters
-- and page dots.
---------------------------------------------------------------------------
local win, selected, zoneOffset, page, filter = nil, nil, 0, 1, "all"
local zoneRows, cardFrames = {}, {}
local RARITY_ORDER = { "normal", "elite", "rare", "rareelite", "boss" }
local MAX_DOTS = 16

local function ZoneList()
    return combined.list
end

-- the cards the grid shows for the chosen zone and filter
local function Shown()
    local out = {}
    local got = Collected()
    if selected == "other" then
        -- collected enemies with no zone to file them under
        for name, entry in pairs(got) do
            local filed = entry.zone and combined.byName[entry.zone]
            if not (index and index.byName[name]) and not filed then out[#out + 1] = { name = name } end
        end
        table.sort(out, function(a, b) return a.name < b.name end)
        return out
    end
    local zone = combined.byId[selected]
    for _, card in ipairs(zone and zone.cards or {}) do
        local have = got[card.name] ~= nil
        if filter == "all" or (filter == "have" and have) or (filter == "missing" and not have) then
            out[#out + 1] = { name = card.name, card = card }
        end
    end
    return out
end

local RefreshWindow
local function SelectZone(id)
    selected, page = id, 1
    RefreshWindow()
end

-- a dark inset panel with a thin gold edge
local function Panel(parent)
    local p = CreateFrame("Frame", nil, parent, ns.BACKDROP)
    ns.Skin(p, { 0.02, 0.02, 0.03, 0.55 }, { ns.color.gold[1], ns.color.gold[2], ns.color.gold[3], 0.35 })
    local sheen = p:CreateTexture(nil, "BORDER")
    sheen:SetPoint("TOPLEFT", 1, -1)
    sheen:SetPoint("TOPRIGHT", -1, -1)
    sheen:SetHeight(26)
    sheen:SetColorTexture(1, 1, 1, 0.035)
    return p
end

-- buttons that sit side by side and light up when chosen
local function Segmented(parent, items, width, onPick)
    local buttons = {}
    for i, item in ipairs(items) do
        local b = ns.CreateButton(parent, item[2], width, 20, function() onPick(item[1]) end)
        b.text:SetFont(ns.FONT, 10, "")
        b.key = item[1]
        if i > 1 then b:SetPoint("LEFT", buttons[i - 1], "RIGHT", -1, 0) end
        buttons[i] = b
    end
    function buttons.Select(key)
        for _, b in ipairs(buttons) do
            local on = b.key == key
            b:SetBackdropColor(unpack(on and { ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.55 } or { 0.08, 0.08, 0.1, 0.9 }))
            b.text:SetTextColor(unpack(on and { 1, 1, 1, 1 } or ns.color.gold))
        end
    end
    return buttons
end

local function BuildWindow()
    win = CreateFrame("Frame", "HearthboundCardsFrame", UIParent, ns.BACKDROP)
    win:SetSize(WIN_W, WIN_H)
    win:SetPoint("CENTER")
    win:SetFrameStrata("DIALOG")
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop", win.StopMovingOrSizing)
    ns.Skin(win, { 0.04, 0.04, 0.05, 1 }, { ns.color.gold[1], ns.color.gold[2], ns.color.gold[3], 0.8 })
    table.insert(UISpecialFrames, "HearthboundCardsFrame")
    local bg = win:CreateTexture(nil, "BACKGROUND", nil, 1)
    bg:SetTexture(MEDIA .. "WindowBG")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    local accent = win:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)

    -- header: title on the left, your total on the right, rarity chips beneath
    local icon = win:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("TOPLEFT", 18, -14)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Ticket_Tarot_Stack_01")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local title = ns.Text(win, 20, { 1, 0.86, 0.5, 1 })
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -2)
    title:SetText("CARD COLLECTION")
    local subtitle = ns.Text(win, 10, ns.color.dim)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -4)
    subtitle:SetText("Every different enemy you defeat earns its card")
    local close = ns.CreateButton(win, "x", 20, 20, function() win:Hide() end)
    close:SetPoint("TOPRIGHT", -10, -10)

    win.have = ns.Text(win, 28, { 1, 1, 1, 1 })
    win.have:SetPoint("TOPRIGHT", -130, -12)
    win.outOf = ns.Text(win, 13, ns.color.dim)
    win.outOf:SetPoint("BOTTOMLEFT", win.have, "BOTTOMRIGHT", 6, 4)
    win.totalBar = ns.CreateBar(win, 250, 8, { 1, 0.78, 0.3, 1 })
    win.totalBar:SetPoint("TOPRIGHT", -40, -50)
    win.percent = ns.Text(win, 11, { 1, 0.86, 0.45, 1 })
    win.percent:SetPoint("TOPRIGHT", win.totalBar, "BOTTOMRIGHT", 0, -4)

    win.chips = {}
    for i, rank in ipairs(RARITY_ORDER) do
        local chip = CreateFrame("Frame", nil, win, ns.BACKDROP)
        chip:SetSize(112, 30)
        chip:SetPoint("TOPLEFT", 18 + (i - 1) * 118, -62)
        ns.Skin(chip, { 0.03, 0.03, 0.04, 0.75 }, { RANK_COLOUR[rank][1], RANK_COLOUR[rank][2], RANK_COLOUR[rank][3], 0.55 })
        local gem = chip:CreateTexture(nil, "ARTWORK")
        gem:SetTexture(MEDIA .. "Gem")
        gem:SetSize(14, 14)
        gem:SetPoint("LEFT", 5, 0)
        gem:SetVertexColor(RANK_COLOUR[rank][1], RANK_COLOUR[rank][2], RANK_COLOUR[rank][3])
        chip.label = ns.Text(chip, 8, RANK_COLOUR[rank])
        chip.label:SetPoint("TOPLEFT", gem, "TOPRIGHT", 6, 4)
        chip.label:SetPoint("RIGHT", chip, "RIGHT", -5, 0)
        chip.label:SetJustifyH("LEFT")
        chip.label:SetWordWrap(false)
        chip.label:SetText((RANK_NAME[rank] or ""):upper())
        chip.count = ns.Text(chip, 11, { 1, 1, 1, 1 })
        chip.count:SetPoint("TOPLEFT", chip.label, "BOTTOMLEFT", 0, -2)
        chip.count:SetPoint("RIGHT", chip, "RIGHT", -5, 0)
        chip.count:SetJustifyH("LEFT")
        chip.count:SetWordWrap(false)
        chip.rank = rank
        win.chips[i] = chip
    end

    -- zones panel
    local top = -HEADER_H
    local zp = Panel(win)
    zp:SetPoint("TOPLEFT", 14, top)
    zp:SetPoint("BOTTOMLEFT", 14, 14)
    zp:SetWidth(ZONE_W)
    local zt = ns.Text(zp, 11, ns.color.gold)
    zt:SetPoint("TOPLEFT", 10, -8)
    zt:SetText("ZONES & DUNGEONS")
    local here = ns.CreateButton(zp, "This zone", (ZONE_W - 26) / 2, 20, function()
        local zone = Safe(GetRealZoneText)
        for i, z in ipairs(ZoneList()) do
            if z.name == zone then
                zoneOffset = math.max(0, math.min(i - 3, #ZoneList() - ZONE_ROWS))
                return SelectZone(z.id)
            end
        end
        ns.Print("No cards listed for " .. (zone or "this zone") .. ".")
    end)
    here.text:SetFont(ns.FONT, 10, "")
    here:SetPoint("TOPLEFT", 9, -26)
    local other = ns.CreateButton(zp, "Elsewhere", (ZONE_W - 26) / 2, 20, function() SelectZone("other") end)
    other.text:SetFont(ns.FONT, 10, "")
    other:SetPoint("LEFT", here, "RIGHT", 8, 0)
    other:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Elsewhere", 1, 1, 1)
        GameTooltip:AddLine("Cards for enemies with no zone to file them under.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    other:HookScript("OnLeave", function() GameTooltip:Hide() end)

    local list = CreateFrame("Frame", nil, zp)
    list:SetPoint("TOPLEFT", 6, -54)
    list:SetSize(ZONE_W - 12, ZONE_ROWS * ZONE_ROW_H)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, delta)
        zoneOffset = math.max(0, math.min(#ZoneList() - ZONE_ROWS, zoneOffset - delta * 3))
        RefreshWindow()
    end)
    for i = 1, ZONE_ROWS do
        local r = CreateFrame("Button", nil, list, ns.BACKDROP)
        ns.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
        r:SetSize(ZONE_W - 12, ZONE_ROW_H - 2)
        r:SetPoint("TOPLEFT", 0, -(i - 1) * ZONE_ROW_H)
        r.mark = r:CreateTexture(nil, "ARTWORK") -- dungeon key, finished tick or you-are-here dot
        r.mark:SetSize(12, 12)
        r.mark:SetPoint("LEFT", 4, 2)
        r.name = ns.Text(r, 10)
        r.name:SetPoint("LEFT", r.mark, "RIGHT", 5, 0)
        r.name:SetWidth(ZONE_W - 84)
        r.name:SetJustifyH("LEFT")
        r.name:SetWordWrap(false)
        r.count = ns.Text(r, 9, ns.color.dim)
        r.count:SetPoint("RIGHT", -5, 2)
        r.track = r:CreateTexture(nil, "ARTWORK")
        r.track:SetPoint("BOTTOMLEFT", 21, 3)
        r.track:SetPoint("BOTTOMRIGHT", -5, 3)
        r.track:SetHeight(3)
        r.track:SetColorTexture(1, 1, 1, 0.08)
        r.fill = r:CreateTexture(nil, "ARTWORK", nil, 1)
        r.fill:SetPoint("BOTTOMLEFT", r.track, "BOTTOMLEFT")
        r.fill:SetHeight(3)
        r.fill:SetColorTexture(1, 1, 1, 1)
        r.sel = r:CreateTexture(nil, "ARTWORK", nil, 2) -- a bar on the left of the chosen zone
        r.sel:SetPoint("TOPLEFT", 0, 0)
        r.sel:SetPoint("BOTTOMLEFT", 0, 0)
        r.sel:SetWidth(2)
        r.sel:SetColorTexture(unpack(ns.color.accent))
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 0.85, 0.5, 0.08)
        r:SetScript("OnClick", function(self) if self.zoneId then SelectZone(self.zoneId) end end)
        r:SetScript("OnEnter", function(self)
            if not self.found then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Found as you go", 1, 1, 1)
            GameTooltip:AddLine("Cards you've won here for enemies outside the quest list.", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        zoneRows[i] = r
    end
    win.zoneScroll = ns.Text(zp, 9, ns.color.dim)
    win.zoneScroll:SetPoint("BOTTOM", 0, 8)

    -- cards panel
    local cp = Panel(win)
    cp:SetPoint("TOPLEFT", zp, "TOPRIGHT", 12, 0)
    cp:SetPoint("BOTTOMRIGHT", -14, 14)
    win.zoneTitle = ns.Text(cp, 16, { 1, 0.86, 0.5, 1 })
    win.zoneTitle:SetPoint("TOPLEFT", 14, -9)
    win.zoneCount = ns.Text(cp, 10, ns.color.dim)
    win.zoneCount:SetPoint("BOTTOMLEFT", win.zoneTitle, "BOTTOMRIGHT", 10, 1)
    win.filters = Segmented(cp, { { "all", "All" }, { "have", "Collected" }, { "missing", "Missing" } }, 76, function(key)
        filter, page = key, 1
        RefreshWindow()
    end)
    win.filters[1]:SetPoint("TOPRIGHT", cp, "TOPRIGHT", -14 - 76 * 2 + 2, -8)

    local grid = CreateFrame("Frame", nil, cp)
    grid:SetPoint("TOP", cp, "TOP", 0, -GRID_TOP)
    grid:SetSize(GRID_COLS * CARD_W + (GRID_COLS - 1) * GAP_X, GRID_ROWS * CARD_H + (GRID_ROWS - 1) * GAP_Y)
    grid:EnableMouseWheel(true)
    grid:SetScript("OnMouseWheel", function(_, delta)
        page = page - delta
        RefreshWindow()
    end)
    for i = 1, GRID_COLS * GRID_ROWS do
        local c = BuildCard(grid)
        local col, row = (i - 1) % GRID_COLS, math.floor((i - 1) / GRID_COLS)
        c:SetPoint("TOPLEFT", col * (CARD_W + GAP_X), -row * (CARD_H + GAP_Y))
        cardFrames[i] = c
    end
    win.empty = ns.Text(grid, 13, ns.color.dim)
    win.empty:SetPoint("CENTER")

    -- pages: arrows either side of a row of dots
    local pager = CreateFrame("Frame", nil, cp)
    pager:SetSize(MAX_DOTS * 12 + 80, 20)
    pager:SetPoint("BOTTOM", cp, "BOTTOM", 0, 8)
    local prev = ns.CreateButton(pager, "<", 26, 20, function() page = page - 1 RefreshWindow() end)
    prev:SetPoint("LEFT")
    local nextB = ns.CreateButton(pager, ">", 26, 20, function() page = page + 1 RefreshWindow() end)
    nextB:SetPoint("RIGHT")
    win.dots = {}
    for i = 1, MAX_DOTS do
        local d = CreateFrame("Button", nil, pager)
        d:SetSize(10, 10)
        d.tex = d:CreateTexture(nil, "ARTWORK")
        d.tex:SetAllPoints()
        d.tex:SetTexture(MEDIA .. "Gem")
        d:SetScript("OnClick", function(self) page = self.page RefreshWindow() end)
        win.dots[i] = d
    end
    win.pageText = ns.Text(pager, 10, ns.color.dim)
    win.pageText:SetPoint("CENTER")

    win.loading = ns.Text(cp, 12, ns.color.dim)
    win.loading:SetPoint("CENTER")
    win:Hide()
end

-- how many cards of each rank there are, and how many you have
local function RarityCounts()
    local total, have = {}, {}
    for _, rank in ipairs(RARITY_ORDER) do total[rank], have[rank] = 0, 0 end
    local got = Collected()
    local seen = {}
    for _, zone in ipairs(combined.list) do
        for _, card in ipairs(zone.cards) do
            if not seen[card.name] then
                seen[card.name] = true
                local rank = RankOf(card.name, card, got[card.name])
                total[rank] = (total[rank] or 0) + 1
                if got[card.name] then have[rank] = (have[rank] or 0) + 1 end
            end
        end
    end
    return have, total
end

function RefreshWindow()
    if not (win and win:IsShown()) then return end
    if not index then
        win.loading:SetText(rawget(_G, "LibQuestieDB") and "Reading every enemy from QuestieDB..."
            or "QuestieDB isn't loaded - only the cards you've collected can be listed.")
    else
        win.loading:SetText("")
    end
    Combine()
    local total = (index and index.total or 0) + combined.extra
    local have = CollectedCount()
    win.have:SetText(have)
    win.outOf:SetText(total > 0 and ("/ " .. total) or "")
    win.percent:SetText(total > 0 and format("%d%% complete", math.floor(have / total * 100)) or "")
    win.totalBar.bar:SetValue(total > 0 and have / total or 0)
    local rh, rt = RarityCounts()
    for _, chip in ipairs(win.chips) do
        chip.count:SetText(format("%d |cff999999/ %d|r", rh[chip.rank] or 0, rt[chip.rank] or 0))
    end

    -- zones
    local zones = ZoneList()
    zoneOffset = math.max(0, math.min(zoneOffset, #zones - ZONE_ROWS))
    local here = Safe(GetRealZoneText)
    for i, r in ipairs(zoneRows) do
        local zone = zones[zoneOffset + i]
        if zone then
            local zh, zt = ZoneProgress(zone)
            local done = zt > 0 and zh == zt
            r.zoneId = zone.id
            r.found = zone.found
            r.name:SetText(zone.name)
            r.name:SetTextColor(unpack(zone.name == here and { 0.45, 1, 0.6, 1 } or (done and { 1, 0.84, 0.4, 1 } or ns.color.text)))
            r.count:SetText(format("%d/%d", zh, zt))
            if done then
                r.mark:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
                r.mark:SetTexCoord(0, 1, 0, 1)
            elseif zone.dungeon then
                r.mark:SetTexture("Interface\\Icons\\INV_Misc_Key_14")
                r.mark:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            elseif zone.name == here then
                r.mark:SetTexture(MEDIA .. "Gem")
                r.mark:SetTexCoord(0, 1, 0, 1)
            else
                r.mark:SetTexture(nil)
            end
            r.mark:SetVertexColor(1, 1, 1)
            if zone.name == here and not done and not zone.dungeon then r.mark:SetVertexColor(0.45, 1, 0.6) end
            local frac = zh / math.max(1, zt)
            r.fill:SetWidth(math.max(0.01, (ZONE_W - 38) * frac))
            r.fill:SetShown(zh > 0)
            r.fill:SetVertexColor(unpack(done and { 1, 0.82, 0.35, 1 } or { ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 1 }))
            local chosen = zone.id == selected
            r.sel:SetShown(chosen)
            r:SetBackdropColor(1, 0.85, 0.5, chosen and 0.12 or 0)
            r:Show()
        else
            r.zoneId = nil
            r:Hide()
        end
    end
    win.zoneScroll:SetText(#zones > ZONE_ROWS and format("%d-%d of %d  (scroll)", zoneOffset + 1,
        math.min(#zones, zoneOffset + ZONE_ROWS), #zones) or "")

    -- cards
    local zone = combined.byId[selected]
    if selected == "other" then
        win.zoneTitle:SetText("Elsewhere")
        win.zoneCount:SetText("")
    elseif zone then
        local zh, zt = ZoneProgress(zone)
        win.zoneTitle:SetText(zone.name)
        win.zoneCount:SetText(format("%d of %d collected%s", zh, zt, zone.dungeon and "  -  dungeon" or ""))
    else
        win.zoneTitle:SetText(index and "Pick a zone" or "")
        win.zoneCount:SetText("")
    end
    win.filters.Select(filter)
    local shown = Shown()
    local perPage = GRID_COLS * GRID_ROWS
    local pages = math.max(1, math.ceil(#shown / perPage))
    page = math.max(1, math.min(pages, page))
    for i, c in ipairs(cardFrames) do
        local item = shown[(page - 1) * perPage + i]
        FillCard(c, item and item.name, item and item.card)
    end
    win.empty:SetText(((zone or selected == "other") and #shown == 0) and "Nothing here yet." or "")
    -- page dots (or "page x / y" when there are too many to show)
    local useDots = pages > 1 and pages <= MAX_DOTS
    local width = pages * 12 - 2
    for i, d in ipairs(win.dots) do
        if useDots and i <= pages then
            d.page = i
            d:ClearAllPoints()
            d:SetPoint("CENTER", d:GetParent(), "CENTER", -width / 2 + (i - 1) * 12 + 5, 0)
            local on = i == page
            d.tex:SetVertexColor(unpack(on and { 1, 0.82, 0.35 } or { 0.35, 0.35, 0.4 }))
            d:SetSize(on and 12 or 9, on and 12 or 9)
            d:Show()
        else
            d:Hide()
        end
    end
    win.pageText:SetText((pages > 1 and not useDots) and format("Page %d / %d", page, pages) or "")
end
ns.RefreshCards = RefreshWindow

function ns.ToggleCards()
    if not win then BuildWindow() end
    if win:IsShown() then return win:Hide() end
    win:Show()
    if not selected then
        -- start on the zone you're in
        local here = Safe(GetRealZoneText)
        Scan(function()
            Combine()
            for i, z in ipairs(ZoneList()) do
                if z.name == here and not selected then
                    selected = z.id
                    zoneOffset = math.max(0, i - 3)
                end
            end
            RefreshWindow()
        end)
    else
        Scan(RefreshWindow)
    end
    RefreshWindow()
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------
table.insert(ns.inits, function()
    -- every kill that gives XP (XP.lua -> Kills.lua)
    if ns.RecordKillType then
        hooksecurefunc(ns, "RecordKillType", function(name) pcall(ns.CollectCard, name, "XP kill") end)
        hooked = true
    end
    -- and the ones that don't (grey mobs, critters): your target dying
    -- Some of these answers are hidden in combat on Forever, so "dead" is
    -- any of: the game says dead, or its health is 0
    local function TargetDead()
        if Safe(UnitIsDead, "target") == true then return true end
        local hp = Safe(UnitHealth, "target")
        return type(hp) == "number" and hp <= 0
    end
    local function SameTarget()
        if Safe(UnitExists, "target") ~= true then return false end
        local guid = Safe(UnitGUID, "target")
        if watching.guid and guid then return guid == watching.guid end
        return true -- changing target clears watching, so this is still the one we started with
    end
    local function CheckTarget()
        if not watching or not SameTarget() or not TargetDead() then return end
        local name = watching.name
        watching = nil
        -- someone else's kill doesn't count
        if Safe(UnitIsTapDenied, "target") == true then return end
        pcall(ns.CollectCard, name, "target died")
    end
    ns.On("PLAYER_TARGET_CHANGED", function()
        Look("target")
        watching = nil
        if Safe(UnitExists, "target") == true and Safe(UnitIsPlayer, "target") == false
            and Safe(UnitCanAttack, "player", "target") == true and not TargetDead() then
            local name = Safe(UnitName, "target")
            if type(name) == "string" then watching = { name = name, guid = Safe(UnitGUID, "target") } end
        end
    end)
    ns.On("UPDATE_MOUSEOVER_UNIT", function() Look("mouseover") end)
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) Look(unit) end)
    ns.On("UNIT_HEALTH", function(_, unit) if unit == "target" then CheckTarget() end end)
    C_Timer.NewTicker(0.3, CheckTarget) -- in case the health event doesn't come through
    ns.On("PLAYER_REGEN_ENABLED", CheckTarget) -- hidden values come back once the fight's over

    -- looting a corpse: the kill was yours (and works when the death itself is hidden)
    local function NameFromGuid(guid)
        if type(guid) ~= "string" then return nil end
        local kind, _, _, _, _, id = strsplit("-", guid)
        id = tonumber(id)
        if not (id and (kind == "Creature" or kind == "Vehicle")) then return nil end
        local l = rawget(_G, "LibQuestieDB")
        if l and l.Npc and l.Npc.Get then
            local ok, name = pcall(l.Npc.Get, id, "name")
            if ok and type(name) == "string" then return name, id end
        end
    end
    ns.On("LOOT_OPENED", function(_, autoLoot)
        local names = {}
        -- whose loot is in the window (several corpses with area loot)
        local count = Safe(GetNumLootItems) or 0
        for slot = 1, count do
            local sources = { pcall(GetLootSourceInfo, slot) }
            if sources[1] then
                for k = 2, #sources, 2 do
                    if not ns.IsSecret(sources[k]) then
                        local name, id = NameFromGuid(sources[k])
                        if name then
                            names[name] = true
                            npcByName[name] = npcByName[name] or id
                        end
                    end
                end
            end
        end
        -- or the enemy you were fighting, if the window can't say
        if not next(names) and watching then names[watching.name] = true end
        if not next(names) and Safe(UnitExists, "target") == true then
            local name = Safe(UnitName, "target")
            if type(name) == "string" and Safe(UnitIsPlayer, "target") == false then names[name] = true end
        end
        watching = nil
        local offer = {}
        for name in pairs(names) do
            local ok, waiting = pcall(ns.CollectCard, name, "looted")
            if ok and waiting then offer[#offer + 1] = name end
        end
        table.sort(offer)
        OfferCards(offer, autoLoot == true or autoLoot == 1)
    end)
    ns.On("LOOT_CLOSED", HideLootCards) -- left behind: it's still on the corpse, or comes to you later
    -- read the enemy list a while after login, so the first new card can say how the zone's set is going
    ns.On("PLAYER_LOGIN", function() C_Timer.After(25, function() Scan() end) end)
end)
