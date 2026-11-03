local ADDON_NAME, ns = ...

-- The Quests tab of the settings window, in two modes:
--   Completed - searchable, filterable list of the quests you've done
--   Available - every quest you can pick up now (from Questie's database),
--               with where its giver stands and a map marker for each

local format = string.format
local Safe = ns.Safe

local ROW_H = 20
local PAD = 22

-- filter / sort sets per mode; the third filter means something different in each
local MODES = {
    done = {
        filters = { { key = "all", label = "All" }, { key = "zone", label = "This zone" }, { key = "session", label = "This session" } },
        sorts = { { key = "recent", label = "Newest" }, { key = "name", label = "Name" }, { key = "level", label = "Level" },
                  { key = "zone", label = "Zone" } },
    },
    available = {
        filters = { { key = "all", label = "All" }, { key = "nearby", label = "Nearby" }, { key = "mylevel", label = "My level" } },
        sorts = { { key = "nearest", label = "Nearest" }, { key = "level", label = "Level" }, { key = "name", label = "Name" },
                  { key = "zone", label = "Zone" } },
    },
}

local page, search, countText, listFrame, scrollBar, emptyText, minBox, maxBox, markNearest
local filterButtons, modeButtons, sortButton = {}, {}, nil
local listControls, secretsFrame = {}, nil -- the list's own controls; the Secrets view
local rows = {}
local state = { mode = "done", filter = "all", sort = 1, offset = 0 }
local savedFilters = { done = { filter = "all", sort = 1 }, available = { filter = "nearby", sort = 1 } }
local results = {}

local function Mode() return MODES[state.mode] end

local function VisibleRows()
    return math.max(1, math.floor((listFrame:GetHeight() - 4) / ROW_H))
end

local function ShowTooltip(row)
    local item = row.item
    if not item then return end
    local r = item.r
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(r.title, 1, 0.82, 0)
    if r.imported then
        GameTooltip:AddLine("Completed before Hearthbound was installed", 0.7, 0.7, 0.7)
    else
        if r.zone and r.zone ~= "" then GameTooltip:AddDoubleLine("Zone", r.zone, 0.6, 0.6, 0.6, 1, 1, 1) end
        if r.questLevel then GameTooltip:AddDoubleLine("Quest level", r.questLevel, 0.6, 0.6, 0.6, 1, 1, 1) end
        GameTooltip:AddDoubleLine("Your level", r.level or "?", 0.6, 0.6, 0.6, 1, 1, 1)
        if r.xp and r.xp > 0 then
            GameTooltip:AddDoubleLine("Experience", ns.Comma(r.xp), 0.6, 0.6, 0.6, 1, 1, 1)
        end
        if r.money and r.money > 0 and GetCoinTextureString then
            GameTooltip:AddDoubleLine("Money", GetCoinTextureString(r.money), 0.6, 0.6, 0.6, 1, 1, 1)
        end
        if r.time then
            GameTooltip:AddDoubleLine("Completed", date("%d %b %Y  %H:%M", r.time), 0.6, 0.6, 0.6, 1, 1, 1)
        end
    end
    local pickup = r.pickup or (ns.QuestPickup and ns.QuestPickup(r.title))
    local turnin = ns.QuestTurnIn and ns.QuestTurnIn(r.title)
    if pickup then
        GameTooltip:AddDoubleLine("Picked up", string.format("%s%s %.1f, %.1f", pickup.giver and (pickup.giver .. ", ") or "",
            pickup.zone or "?", pickup.x, pickup.y), 0.6, 0.6, 0.6, 1, 1, 1)
    end
    if turnin then
        GameTooltip:AddDoubleLine("Handed in", string.format("%s%s %.1f, %.1f", turnin.npc and (turnin.npc .. ", ") or "",
            turnin.zone or "?", turnin.x, turnin.y), 0.6, 0.6, 0.6, 1, 1, 1)
    end
    GameTooltip:AddDoubleLine("Quest ID", item.id, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6)
    if pickup or turnin then
        GameTooltip:AddLine(" ")
        if pickup then GameTooltip:AddLine("Right-click: mark where you picked it up", 1, 0.82, 0) end
        if turnin then GameTooltip:AddLine("Shift-right-click: mark where you handed it in", 1, 0.82, 0) end
    end
    GameTooltip:Show()
end

local function MarkQuest(row)
    local item = row.item
    if not item then return end
    local r = item.r
    if IsShiftKeyDown() then
        local turnin = ns.QuestTurnIn and ns.QuestTurnIn(r.title)
        if turnin then return ns.SetWaypoint(turnin.mapID, turnin.x, turnin.y, (turnin.npc or r.title) .. " (hand in)") end
    else
        local pickup = r.pickup or (ns.QuestPickup and ns.QuestPickup(r.title))
        if pickup then return ns.SetWaypoint(pickup.mapID, pickup.x, pickup.y, pickup.giver or r.title) end
    end
    ns.Print("No location recorded for " .. r.title .. " - it was done before Hearthbound started recording.")
end

---------------------------------------------------------------------------
-- Available mode
---------------------------------------------------------------------------
local candidates -- quests you can take now; rebuilt when your quests or level change
local mapNames = {}
local NEARBY_YARDS = 3000

local function MapName(mapID)
    if not mapNames[mapID] then
        local info = Safe(C_Map.GetMapInfo, mapID)
        mapNames[mapID] = info and info.name or "?"
    end
    return mapNames[mapID]
end

local function InvalidateCandidates()
    candidates = nil
end

-- Quests you could pick up right now, using Questie's own eligibility check
local function Candidates()
    local givers = ns.QuestieQuestGivers and ns.QuestieQuestGivers(function()
        InvalidateCandidates()
        ns.RefreshQuestList()
        if ns.RefreshQuestPins then ns.RefreshQuestPins() end
    end)
    if not givers then return nil end
    local inLog = {}
    for _, q in ipairs(ns.openQuests or {}) do inLog[q.id] = true end

    -- best source: the quests Questie itself shows as "!" on the map. It keeps
    -- this up to date, so read it fresh every time
    local shown = ns.QuestieAvailableSet and ns.QuestieAvailableSet()
    if shown then
        local list = {}
        for questId in pairs(shown) do
            local e = not inLog[questId] and ns.QuestieGiverById(questId)
            if e then list[#list + 1] = e end
        end
        return list
    end

    -- otherwise check every quest ourselves
    if candidates then return candidates end
    local level = UnitLevel("player")
    local list = {}
    for _, e in ipairs(givers) do
        -- quests well above you are red ("impossible") anyway; skip them early
        if not inLog[e.id] and (e.requiredLevel or 0) <= level and (e.level or 0) < level + 5 then
            local doable = ns.QuestieIsDoable(e.id)
            if doable == nil then
                -- Questie can't say: fall back to our own history
                doable = not (ns.cdb.quests and ns.cdb.quests[e.id])
            end
            if doable then list[#list + 1] = e end
        end
    end
    candidates = list
    return list
end

-- Where you are in world yards: continent, x, y (nil inside instances)
-- the same list for the map pins (nil while Questie's data is still loading)
function ns.AvailableQuests()
    return Candidates()
end

local function PlayerWorld()
    return ns.PlayerWorldPos()
end

-- The nearest place to pick a quest up and the yards to it (nil when it's on
-- another continent or your position is unknown)
local function Nearest(e, continent, wx, wy)
    if not continent then return nil end
    return ns.QuestieNearestSpot(e, continent, wx, wy)
end

local AVAILABLE_SORTS = {
    nearest = function(a, b)
        local da, db = a.distance or math.huge, b.distance or math.huge
        if da ~= db then return da < db end
        return (a.e.level or 0) < (b.e.level or 0)
    end,
    level = function(a, b)
        if (a.e.level or 0) ~= (b.e.level or 0) then return (a.e.level or 0) < (b.e.level or 0) end
        return a.e.title < b.e.title
    end,
    name = function(a, b) return a.e.title < b.e.title end,
    zone = function(a, b)
        if a.zone ~= b.zone then return a.zone < b.zone end
        return a.e.title < b.e.title
    end,
}

local function QueryAvailable()
    local list = Candidates()
    if not list then return nil, 0 end
    local level = UnitLevel("player")
    local continent, wx, wy = PlayerWorld()
    local text = strtrim(search:GetText() or ""):lower()
    local minLevel, maxLevel = tonumber(minBox:GetText()), tonumber(maxBox:GetText())
    local out = {}
    for _, e in ipairs(list) do
        local keep = true
        local spot, distance = Nearest(e, continent, wx, wy)
        if state.filter == "nearby" then
            keep = distance ~= nil and distance <= NEARBY_YARDS
        elseif state.filter == "mylevel" and e.level then
            local diff = ns.QuestDifficulty(e.level, level)
            keep = diff ~= "trivial" and diff ~= "impossible"
        end
        if keep and (minLevel or maxLevel) then
            keep = e.level ~= nil and e.level >= (minLevel or 0) and e.level <= (maxLevel or 999)
        end
        local zone = MapName(spot and spot.mapID or e.mapID)
        if keep and text ~= "" then
            local haystack = (e.title .. " " .. zone .. " " .. (e.giver or "")):lower()
            keep = haystack:find(text, 1, true) ~= nil
        end
        if keep then
            out[#out + 1] = { e = e, spot = spot, zone = zone, distance = distance, available = true }
        end
    end
    table.sort(out, AVAILABLE_SORTS[Mode().sorts[state.sort].key] or AVAILABLE_SORTS.nearest)
    return out, #list
end

-- /hb nearby: walks through each step of the Nearby list, to see which one comes up empty
function ns.NearbyProbe()
    local P = ns.Print
    if not (ns.QuestieAvailable and ns.QuestieAvailable()) then return P("Nearby: Questie's database isn't connected.") end
    P(ns.QuestieReady() and "Nearby: Questie is running." or "Nearby: Questie hasn't finished starting up - using QuestieDB directly.")
    local givers = ns.QuestieQuestGivers()
    local st = ns.questieScanStats or {}
    if st.quests then
        P(format("Nearby: last read of Questie - %d quests, %d named, %d with a giver, %d placed on a map.",
            st.quests, st.named, st.withStarter, st.located))
    end
    if not givers then return P("Nearby: still reading Questie's quests, try again in a few seconds.") end
    local shown = ns.QuestieAvailableSet and ns.QuestieAvailableSet()
    local shownCount = 0
    for _ in pairs(shown or {}) do shownCount = shownCount + 1 end
    local list = Candidates() or {}
    P(format("Nearby: %d quest givers known, Questie shows %d quests on the map, %d you can take (%s).",
        #givers, shownCount, #list, shown and "Questie's list" or "own check"))
    local continent, wx, wy = PlayerWorld()
    P(continent and format("Nearby: you are at %.0f, %.0f on continent %s.", wx, wy, tostring(continent))
        or "Nearby: couldn't work out where you are.")
    if not continent then return end
    local near = {}
    for _, e in ipairs(list) do
        local spot, d = Nearest(e, continent, wx, wy)
        if d then near[#near + 1] = { e = e, d = d, spot = spot } end
    end
    table.sort(near, function(a, b) return a.d < b.d end)
    P(format("Nearby: %d of them are on your continent. Closest:", #near))
    for i = 1, math.min(5, #near) do
        local n = near[i]
        P(format("   %s - %s, %d yd (%s %.1f, %.1f)", n.e.title, n.e.giver or "?", n.d, MapName(n.spot.mapID), n.spot.x, n.spot.y))
    end
    local inLogIds = {}
    for _, q in ipairs(ns.openQuests or {}) do inLogIds[q.id] = true end
    local target = UnitExists("target") and not UnitIsPlayer("target") and UnitGUID("target")
    local npcId = target and tonumber((select(6, strsplit("-", target))))
    if npcId then
        local found = 0
        for _, e in ipairs(givers) do
            for _, id in ipairs(e.npcIds or {}) do
                if id == npcId then
                    found = found + 1
                    local why = shown and (shown[e.id] and "on Questie's map" or "not on Questie's map")
                        or (ns.QuestieIsDoable(e.id) and "doable" or "not doable")
                    P(format("   Target gives: %s (quest %d, level %s) - %s", e.title, e.id, tostring(e.level), why))
                    local reason = ns.QuestieWhyNot and ns.QuestieWhyNot(e.id)
                    if reason then P("      why: " .. reason) end
                    if inLogIds[e.id] then P("      it's in your quest log") end
                end
            end
        end
        if found == 0 then P(format("   Questie has no quests from your target (NPC %d).", npcId)) end
    end
end

local function DistanceText(yards)
    if not yards then return "" end
    if yards < 1000 then return format("%d yd", math.floor(yards / 10 + 0.5) * 10) end
    return format("%.1fk yd", yards / 1000)
end

local function MarkGiver(item)
    local e, s = item.e, item.spot or item.e
    ns.SetWaypoint(s.mapID, s.x, s.y, (e.giver or e.title) .. " - " .. e.title)
end

local function AvailableTooltip(row, item)
    local e = item.e
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(e.title, 1, 0.82, 0)
    if e.level then GameTooltip:AddDoubleLine("Quest level", e.level, 0.6, 0.6, 0.6, 1, 1, 1) end
    if e.requiredLevel and e.requiredLevel > 0 then
        GameTooltip:AddDoubleLine("Requires level", e.requiredLevel, 0.6, 0.6, 0.6, 1, 1, 1)
    end
    GameTooltip:AddDoubleLine(e.kind == "object" and "Starts at" or "Quest giver", e.giver or "?", 0.6, 0.6, 0.6, 1, 1, 1)
    local s = item.spot or e
    GameTooltip:AddDoubleLine("Where", format("%s %.1f, %.1f", item.zone, s.x, s.y), 0.6, 0.6, 0.6, 1, 1, 1)
    if item.distance then GameTooltip:AddDoubleLine("Distance", DistanceText(item.distance), 0.6, 0.6, 0.6, 1, 1, 1) end
    if e.dungeonKey then GameTooltip:AddLine("Dungeon quest", 1, 0.5, 0.25) end
    local tag = ns.QuestGroupTag and ns.QuestGroupTag(e.id)
    if tag == "group" then GameTooltip:AddLine("Group quest - bring friends", 1, 0.35, 0.3) end
    if ns.AddQuestExtras then ns.AddQuestExtras(GameTooltip, e.id) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click: mark the quest giver on your map", 1, 0.82, 0)
    GameTooltip:Show()
end

local function CreateRow(i)
    local row = CreateFrame("Button", nil, listFrame)
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", 2, -2 - (i - 1) * ROW_H)
    row:SetPoint("TOPRIGHT", -14, -2 - (i - 1) * ROW_H)

    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints()
    stripe:SetColorTexture(1, 1, 1, (i % 2 == 0) and 0.025 or 0)
    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(0.78, 0.61, 0.43, 0.12)

    row.level = ns.Text(row, 11, ns.color.gold)
    row.level:SetPoint("LEFT", 6, 0)
    row.level:SetWidth(34)
    row.level:SetJustifyH("LEFT")

    row.when = ns.Text(row, 10, ns.color.dim)
    row.when:SetPoint("RIGHT", -6, 0)
    row.when:SetWidth(64)
    row.when:SetJustifyH("RIGHT")

    row.zone = ns.Text(row, 10, ns.color.dim)
    row.zone:SetPoint("RIGHT", row.when, "LEFT", -6, 0)
    row.zone:SetWidth(160)
    row.zone:SetJustifyH("LEFT")
    row.zone:SetWordWrap(false)

    row.title = ns.Text(row, 12)
    row.title:SetPoint("LEFT", row.level, "RIGHT", 2, 0)
    row.title:SetPoint("RIGHT", row.zone, "LEFT", -6, 0)
    row.title:SetJustifyH("LEFT")
    row.title:SetWordWrap(false)

    row:SetScript("OnEnter", function(self)
        if self.item and self.item.available then
            AvailableTooltip(self, self.item)
        else
            ShowTooltip(self)
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, mouse)
        if self.item and self.item.available then
            MarkGiver(self.item)
        elseif mouse == "RightButton" then
            MarkQuest(self) -- completed quests: right-click marks where you picked it up
        end
    end)
    rows[i] = row
    return row
end

local function WhenText(r)
    if not r.time then return "earlier" end
    local age = time() - r.time
    if age < 3600 then return format("%dm ago", math.max(1, math.floor(age / 60))) end
    if age < 86400 then return format("%dh ago", math.floor(age / 3600)) end
    return date("%d %b", r.time)
end

local function DrawRows()
    local visible = VisibleRows()
    local maxOffset = math.max(0, #results - visible)
    state.offset = math.min(math.max(0, state.offset), maxOffset)

    for i = 1, visible do
        local row = rows[i] or CreateRow(i)
        local item = results[state.offset + i]
        row.item = item
        if item and item.available then
            local e = item.e
            local color = "ffd200"
            if e.level then
                local diff = ns.QuestDifficulty(e.level, UnitLevel("player"))
                color = ({ impossible = "ff2020", hard = "ff8040", normal = "ffff00", easy = "40c040", trivial = "808080" })[diff]
            end
            row.level:SetText(e.level and format("|cff%s[%d]|r", color, e.level) or "")
            local chain = ns.ChainMarker and ns.ChainMarker(e.id) or ""
            local tag = ns.QuestGroupTag and ns.QuestGroupTag(e.id)
            local tagText = (e.dungeonKey or tag == "dungeon") and " |cffff8040(dungeon)|r"
                or (tag == "group" and " |cffff5544(group)|r") or (tag == "raid" and " |cffff5544(raid)|r") or ""
            row.title:SetText(e.title .. chain .. tagText)
            row.zone:SetText(item.zone)
            row.when:SetText(DistanceText(item.distance))
            row:Show()
        elseif item then
            local r = item.r
            row.level:SetText(r.questLevel and ("[" .. r.questLevel .. "]") or "")
            row.title:SetText(r.title)
            row.zone:SetText(r.zone or "")
            row.when:SetText(WhenText(r))
            row:Show()
        else
            row:Hide()
        end
    end
    for i = visible + 1, #rows do rows[i]:Hide() end

    scrollBar.updating = true
    scrollBar:SetMinMaxValues(0, maxOffset)
    scrollBar:SetValue(state.offset)
    scrollBar.updating = false
    scrollBar:SetShown(maxOffset > 0)
end

local function UpdateControls()
    local mode = Mode()
    for i, b in ipairs(filterButtons) do
        local f = mode.filters[i]
        b.key = f.key
        b.text:SetText(f.label)
        b:SetSelected(f.key == state.filter)
    end
    for _, b in ipairs(modeButtons) do b:SetSelected(b.mode == state.mode) end
    sortButton.text:SetText("Sort: " .. mode.sorts[state.sort].label)
    markNearest:SetShown(state.mode == "available")
end

function ns.RefreshQuestList()
    if not page or not page:IsVisible() then return end
    -- the Secrets view replaces the list and its controls
    local secrets = state.mode == "secrets"
    for _, control in ipairs(listControls) do control:SetShown(not secrets) end
    if secretsFrame then secretsFrame:SetShown(secrets) end
    if secrets then
        for _, b in ipairs(modeButtons) do b:SetSelected(b.mode == "secrets") end
        markNearest:Hide()
        if ns.RefreshSecrets then ns.RefreshSecrets() end
        return
    end
    UpdateControls()
    local total
    if state.mode == "available" then
        if not (ns.QuestieAvailable and ns.QuestieAvailable()) then
            results, total = {}, 0
            emptyText:SetText("Finding quests needs Questie installed.\nIt knows where every quest starts.")
        else
            local found
            found, total = QueryAvailable()
            results = found or {}
            if not found then
                emptyText:SetText("Reading every quest giver from Questie...")
            elseif total == 0 then
                emptyText:SetText("Nothing left to pick up at your level right now.")
            elseif state.filter == "nearby" then
                emptyText:SetText(format("No quests to pick up within %d yards.\nTry |cffffd200All|r or |cffffd200My level|r.", NEARBY_YARDS))
            else
                emptyText:SetText("No quests match.")
            end
        end
    else
        results, total = ns.QueryQuests(search:GetText(), state.filter, Mode().sorts[state.sort].key,
            tonumber(minBox:GetText()), tonumber(maxBox:GetText()))
        if total == 0 then
            emptyText:SetText("No completed quests yet.\nTurn in a quest and it will appear here.")
        else
            emptyText:SetText("No quests match.")
        end
    end
    local noun = state.mode == "available" and "available" or ("quest" .. (total == 1 and "" or "s"))
    if #results == total then
        countText:SetText(format("%d %s", total, noun))
    else
        countText:SetText(format("%d of %d %s", #results, total, state.mode == "available" and "available" or ""))
    end
    emptyText:SetShown(#results == 0)
    DrawRows()
end

local function SetMode(mode)
    if mode == state.mode then return end
    if state.mode ~= "secrets" then savedFilters[state.mode] = { filter = state.filter, sort = state.sort } end
    state.mode = mode
    if mode ~= "secrets" then
        state.filter, state.sort = savedFilters[mode].filter, savedFilters[mode].sort
    end
    state.offset = 0
    ns.RefreshQuestList()
end

local function MarkNearestGiver()
    local nearest
    for _, item in ipairs(results) do
        if item.available and item.distance and (not nearest or item.distance < nearest.distance) then nearest = item end
    end
    if nearest then
        MarkGiver(nearest)
    else
        ns.Print("No available quest givers on this continent match the current filter.")
    end
end

function ns.BuildQuestTab(parent)
    page = parent

    -- the top row is search, three filters and three mode buttons: sized to fit the window
    search = ns.CreateEditBox(page, 120, 24, "Search...")
    search:SetPoint("TOPLEFT", PAD, -4)
    search:HookScript("OnTextChanged", function()
        state.offset = 0
        ns.RefreshQuestList()
    end)

    local x = PAD + 126
    for i, width in ipairs({ 40, 70, 86 }) do
        local b = ns.CreateButton(page, Mode().filters[i].label, width, 24, function(self)
            state.filter, state.offset = self.key, 0
            ns.RefreshQuestList()
        end)
        b.key = Mode().filters[i].key
        b:SetPoint("TOPLEFT", x, -4)
        x = x + width + 4
        filterButtons[#filterButtons + 1] = b
    end

    -- Completed / Available switch
    local available = ns.CreateButton(page, "Available", 76, 24, function() SetMode("available") end)
    available:SetPoint("TOPRIGHT", -PAD, -4)
    available.mode = "available"
    local done = ns.CreateButton(page, "Completed", 80, 24, function() SetMode("done") end)
    done:SetPoint("RIGHT", available, "LEFT", -4, 0)
    done.mode = "done"
    local secretsButton = ns.CreateButton(page, "Secrets", 64, 24, function() SetMode("secrets") end)
    secretsButton:SetPoint("RIGHT", done, "LEFT", -4, 0)
    secretsButton.mode = "secrets"
    secretsButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Secrets", 1, 1, 1)
        GameTooltip:AddLine("WoW Forever's hidden quests, toys, pets and collections - the Cozy Sleeping Bag, the Night Watchman's Torch, library books and more - with where to find each step.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    secretsButton:HookScript("OnLeave", function() GameTooltip:Hide() end)
    modeButtons = { done, available, secretsButton }

    sortButton = ns.CreateButton(page, "Sort", 110, 22, function()
        state.sort = state.sort % #Mode().sorts + 1
        ns.RefreshQuestList()
    end)
    sortButton:SetPoint("TOPLEFT", PAD, -34)

    -- quest level range
    local levelLabel = ns.Text(page, 11, ns.color.dim)
    levelLabel:SetPoint("LEFT", sortButton, "RIGHT", 12, 0)
    levelLabel:SetText("Level")
    minBox = ns.CreateEditBox(page, 34, 22, "")
    minBox:SetPoint("LEFT", levelLabel, "RIGHT", 6, 0)
    minBox:SetNumeric(true)
    minBox:SetMaxLetters(2)
    local toLabel = ns.Text(page, 11, ns.color.dim)
    toLabel:SetPoint("LEFT", minBox, "RIGHT", 5, 0)
    toLabel:SetText("to")
    maxBox = ns.CreateEditBox(page, 34, 22, "")
    maxBox:SetPoint("LEFT", toLabel, "RIGHT", 5, 0)
    maxBox:SetNumeric(true)
    maxBox:SetMaxLetters(2)
    for _, box in ipairs({ minBox, maxBox }) do
        box:SetJustifyH("CENTER")
        box:SetTextInsets(2, 2, 0, 0)
        box:HookScript("OnTextChanged", function()
            state.offset = 0
            ns.RefreshQuestList()
        end)
    end

    markNearest = ns.CreateButton(page, "Mark nearest", 100, 22, MarkNearestGiver)
    markNearest:SetPoint("TOPRIGHT", -PAD, -34)
    markNearest:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Mark nearest", 1, 1, 1)
        GameTooltip:AddLine("Puts a map marker on the closest quest giver that matches the list.",
            nil, nil, nil, true)
        GameTooltip:Show()
    end)
    markNearest:HookScript("OnLeave", function() GameTooltip:Hide() end)
    markNearest:Hide()

    countText = ns.Text(page, 11, ns.color.dim)
    countText:SetPoint("RIGHT", markNearest, "LEFT", -10, 0)

    listFrame = CreateFrame("Frame", nil, page, ns.BACKDROP)
    listFrame:SetPoint("TOPLEFT", PAD, -62)
    listFrame:SetPoint("BOTTOMRIGHT", -PAD, 6)
    ns.Skin(listFrame, { 0.08, 0.08, 0.09, 0.9 }, ns.color.border)
    listFrame:EnableMouseWheel(true)
    listFrame:SetScript("OnMouseWheel", function(_, delta)
        state.offset = state.offset - delta * 3
        DrawRows()
    end)

    scrollBar = CreateFrame("Slider", nil, listFrame, ns.BACKDROP)
    scrollBar:SetPoint("TOPRIGHT", -3, -3)
    scrollBar:SetPoint("BOTTOMRIGHT", -3, 3)
    scrollBar:SetWidth(8)
    ns.Skin(scrollBar, ns.color.panel, ns.color.border)
    scrollBar:SetOrientation("VERTICAL")
    scrollBar:SetValueStep(1)
    if scrollBar.SetObeyStepOnDrag then scrollBar:SetObeyStepOnDrag(true) end
    local thumb = scrollBar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ns.color.gold))
    thumb:SetSize(6, 24)
    scrollBar:SetThumbTexture(thumb)
    scrollBar:SetScript("OnValueChanged", function(self, v)
        if self.updating then return end
        state.offset = math.floor(v + 0.5)
        DrawRows()
    end)

    emptyText = ns.Text(listFrame, 12, ns.color.dim)
    emptyText:SetPoint("CENTER")
    emptyText:SetJustifyH("CENTER")

    -- everything that belongs to the list, hidden while Secrets is showing
    listControls = { search, sortButton, levelLabel, minBox, toLabel, maxBox, countText, listFrame }
    for _, b in ipairs(filterButtons) do listControls[#listControls + 1] = b end
    secretsFrame = CreateFrame("Frame", nil, page)
    secretsFrame:SetPoint("TOPLEFT", 0, -32)
    secretsFrame:SetPoint("BOTTOMRIGHT")
    secretsFrame:Hide()
    if ns.BuildSecrets then ns.BuildSecrets(secretsFrame) end

    page:SetScript("OnShow", ns.RefreshQuestList)
end

table.insert(ns.inits, function()
    -- what you can pick up changes when you take, finish or drop a quest, or level
    for _, event in ipairs({ "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED", "PLAYER_LEVEL_UP" }) do
        ns.On(event, function()
            InvalidateCandidates()
            C_Timer.After(0.5, ns.RefreshQuestList)
        end)
    end
    ns.On("ZONE_CHANGED_NEW_AREA", function() ns.RefreshQuestList() end)
    -- distances change as you move, so keep the list fresh while it's open
    C_Timer.NewTicker(3, function()
        if state.mode == "available" then ns.RefreshQuestList() end
    end)
end)
