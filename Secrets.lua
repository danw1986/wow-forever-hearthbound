local ADDON_NAME, ns = ...

-- The Secrets view of the Quests tab: WoW Forever's hidden quests, toys, pets
-- and collections (ns.SECRETS), with where to go for each step and whether
-- you've done it. Click a step to mark it on the map (or open its dungeon in
-- the journal); right-click a step to tick it off by hand.

local format = string.format

local page, scroll, content, view, scrollBar, summary, allButton
local showAll = false
local expanded = {}
local SCROLL_STEP = 40

---------------------------------------------------------------------------
-- What applies to you, and what you've done
---------------------------------------------------------------------------
local function Faction()
    local f = UnitFactionGroup("player")
    return f == "Alliance" and "A" or (f == "Horde" and "H") or nil
end

local function ForMe(entry)
    local _, class = UnitClass("player")
    local _, race = UnitRace("player")
    if entry.faction and entry.faction ~= Faction() then return false end
    if entry.class and not entry.class[class] then return false end
    if entry.race and entry.race ~= race then return false end
    return true
end

local function Norm(title) return (title or ""):lower():gsub("[^%w]", "") end

-- normalised titles of every quest you've handed in
local function DoneTitles()
    local done = {}
    for _, r in pairs(ns.cdb.quests or {}) do
        if type(r) == "table" and r.title then done[Norm(r.title)] = true end
    end
    return done
end

local function HasItem(name)
    local count = (C_Item and C_Item.GetItemCount) and ns.Safe(C_Item.GetItemCount, name, true)
        or (GetItemCount and ns.Safe(GetItemCount, name, true))
    return type(count) == "number" and count > 0
end

local function Ticks()
    ns.cdb.secretsTicked = ns.cdb.secretsTicked or {}
    return ns.cdb.secretsTicked
end

local function StepKey(entry, i) return entry.key .. ":" .. i end

local function StepDone(entry, i, step, done)
    if Ticks()[StepKey(entry, i)] then return true end
    return step.quest ~= nil and done[Norm(step.quest)] == true
end

local function EntryDone(entry, done)
    if Ticks()[entry.key] then return true end
    for _, title in ipairs(entry.doneQuests or {}) do
        if done[Norm(title)] then return true end
    end
    for _, item in ipairs(entry.doneItems or {}) do
        if HasItem(item) then return true end
    end
    return false
end

local function StepApplies(step)
    return not step.faction or step.faction == Faction()
end

---------------------------------------------------------------------------
-- Where a step is: published coordinates, or QuestieDB by name
---------------------------------------------------------------------------
-- second result true: QuestieDB's name index isn't ready yet, try again later
local function ByName(datatype, name)
    if not (ns.QuestieIdsByName and ns.QuestieSpawnSpots) then return nil end
    local ids, pending = ns.QuestieIdsByName(datatype, name)
    if pending then return nil, true end
    if type(ids) ~= "table" then return nil end
    local spots = {}
    for _, id in ipairs(ids) do
        for _, s in ipairs(ns.QuestieSpawnSpots(datatype, id)) do spots[#spots + 1] = s end
    end
    if #spots == 0 then return nil end
    -- the nearest one to you, or the first
    local continent, wx, wy
    if ns.PlayerWorldPos then continent, wx, wy = ns.PlayerWorldPos() end
    local nearest = ns.NearestSpot and ns.NearestSpot(spots, continent, wx, wy)
    return nearest or spots[1]
end

local spotCache = {}
local function Spot(step)
    if step.x and step.zone then
        local mapID = ns.FindMapID and ns.FindMapID(step.zone)
        if mapID then return { mapID = mapID, x = step.x, y = step.y } end
    end
    local key = (step.npc and ("Npc:" .. step.npc)) or (step.object and ("Object:" .. step.object))
    if not key then return nil end
    if spotCache[key] == nil then
        local spot, pending
        if step.npc then spot, pending = ByName("Npc", step.npc) end
        if not spot and not pending and step.object then spot, pending = ByName("Object", step.object) end
        if pending then return nil end -- not known yet: look again next time
        spotCache[key] = spot or false
    end
    return spotCache[key] or nil
end

local function OnStepClick(entry, i, step, label)
    return function(button)
        if button == "RightButton" then
            local ticks = Ticks()
            local key = StepKey(entry, i)
            ticks[key] = (not ticks[key]) or nil
            ns.RefreshSecrets()
            return
        end
        if step.dungeon then
            local key = ns.DungeonKeyForName(step.dungeon)
            if key and ns.ShowDungeon then ns.ShowDungeon(key) return end
        end
        local spot = Spot(step)
        if spot then
            ns.SetWaypoint(spot.mapID, spot.x, spot.y, label)
        else
            ns.Print("No exact spot known for this one yet" .. (step.zone and (" - it's in " .. step.zone) or "") .. ".")
        end
    end
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------
local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12|t "
local TODO = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:12|t "

local GREEN_BAR, GOLD_BAR = { 0.30, 0.75, 0.30 }, { 0.85, 0.68, 0.20 }
local KIND_ICONS = {
    ["Quest chain"] = "Interface\\Icons\\INV_Misc_Note_02", ["Toy"] = "Interface\\Icons\\INV_Torch_Lit",
    ["Pet"] = "Interface\\Icons\\INV_Box_PetCarrier_01", ["Hidden quest"] = "Interface\\Icons\\INV_Misc_Note_01",
    ["Fun item"] = "Interface\\Icons\\INV_Misc_Food_15", ["Hidden item"] = "Interface\\Icons\\INV_Misc_Bag_10",
    ["Set"] = "Interface\\Icons\\INV_Chest_Leather_01", ["Collection"] = "Interface\\Icons\\INV_Misc_Book_11",
    ["Class quest"] = "Interface\\Icons\\INV_Sword_27",
}
local REWARD = "|cff6fdc6f"

---------------------------------------------------------------------------
-- Reward items: names -> { name, id, icon, count, quality } for the icon rows
---------------------------------------------------------------------------
local idCache = {}

local function ItemID(name)
    if idCache[name] ~= nil then return idCache[name] or nil end
    local id = ns.QuestieItemId and ns.QuestieItemId(name)
    local instant = C_Item and C_Item.GetItemInfoInstant
    if not id and instant then
        local ok, found = pcall(instant, name)
        if ok and type(found) == "number" then id = found end
    end
    -- QuestieDB may still be loading: only remember a miss once it's there
    if id or (ns.QuestieAvailable and ns.QuestieAvailable()) then idCache[name] = id or false end
    return id
end

local function Items(names)
    local list = {}
    for _, spec in ipairs(names) do
        local name, count = spec:match("^(.-) x(%d+)$")
        name = name or spec
        local item = { name = name, count = tonumber(count) }
        item.id = ItemID(name)
        if item.id then
            item.icon = C_Item and C_Item.GetItemIconByID and ns.Safe(C_Item.GetItemIconByID, item.id)
            item.quality = C_Item and C_Item.GetItemQualityByID and ns.Safe(C_Item.GetItemQualityByID, item.id)
            if not item.quality and C_Item and C_Item.RequestLoadItemDataByID then
                pcall(C_Item.RequestLoadItemDataByID, item.id) -- colours fill in when it arrives
            end
        end
        list[#list + 1] = item
    end
    return list
end

local function DrawEntry(add, entry, done)
    local isDone = EntryDone(entry, done)
    local steps, stepsDone = 0, 0
    for i, step in ipairs(entry.steps) do
        if StepApplies(step) and not step.header then
            steps = steps + 1
            if StepDone(entry, i, step, done) then stepsDone = stepsDone + 1 end
        end
    end
    local open = expanded[entry.key]
    local status = isDone and " - done" or ""
    -- headings are shown in capitals, so no colour codes in here
    local headIcon = entry.items and Items({ entry.items[1] })[1].icon or KIND_ICONS[entry.kind]
    add.header(format("%s - %s%s", entry.name, entry.kind, status), {
        icon = headIcon,
        collapsed = not open,
        onClick = function()
            expanded[entry.key] = not open or nil
            ns.RefreshSecrets()
        end,
    })

    -- always shown: the reward, and how far along you are
    local level = entry.level and format("Level %d+", entry.level) or nil
    add.note((level and ("|cff999999" .. level .. "  |r") or "") .. REWARD .. "Reward:|r " .. entry.reward)
    if entry.items then add.items(Items(entry.items)) end
    if entry.books then
        add.bar(stepsDone / math.max(1, steps), "Books found", format("%d / %d", stepsDone, steps), GOLD_BAR)
    elseif steps > 1 then
        add.bar(isDone and 1 or stepsDone / steps, "Progress",
            isDone and "done" or format("%d / %d steps", stepsDone, steps), isDone and GREEN_BAR or GOLD_BAR)
    end
    if not open then return end

    add.note(entry.what, ns.color.dim)
    -- the library's rewards along the way
    for _, m in ipairs(entry.milestones or {}) do
        local reached = stepsDone >= m[1]
        add.note(format("%s%d books: %s", reached and CHECK or TODO, m[1], m[2]), reached and ns.color.dim or nil)
        if m.items then add.items(Items(m.items), 18) end
    end
    local number = 0
    for i, step in ipairs(entry.steps) do
        if StepApplies(step) then
            local stepDone = (isDone and not entry.collection) or StepDone(entry, i, step, done)
            local prefix = ""
            if not step.header then
                number = number + 1
                prefix = (stepDone and CHECK or TODO) .. (entry.books and "" or (number .. ". "))
            end
            local where = ""
            if step.x then
                where = format("  |cffc0c0c0%s%.1f, %.1f|r", step.approx and "~" or "", step.x, step.y)
            end
            local text = prefix .. step.text .. where
            if step.reward then
                text = text .. "\n      " .. REWARD .. "Reward:|r " .. (step.items and "" or step.reward)
            end
            local label = step.book and step.object or entry.name
            local tip = (step.dungeon and ("Click: open " .. step.dungeon .. " in the dungeon journal"))
                or "Click: mark it on your map"
            tip = tip .. "\nRight-click: tick it off" .. (step.approx and "\n\nApproximate - no exact spot is published." or "")
            add.note(text, stepDone and ns.color.dim or nil, OnStepClick(entry, i, step, label), tip)
            if step.items then add.items(Items(step.items), 18) end
        end
    end
    if entry.collection and not entry.books then
        add.note("Right-click a step to tick it off - this one can't be detected automatically.", ns.color.dim)
    end
end

function ns.RefreshSecrets()
    if not page or not page:IsVisible() then return end
    local done = DoneTitles()
    view:Begin()
    local shown, finished, hidden = 0, 0, 0
    for _, entry in ipairs(ns.SECRETS or {}) do
        if showAll or ForMe(entry) then
            shown = shown + 1
            if EntryDone(entry, done) then finished = finished + 1 end
            DrawEntry(view.add, entry, done)
        else
            hidden = hidden + 1
        end
    end
    local bottom = view:Render(0)
    summary:SetText(format("%d of %d secrets done%s", finished, shown,
        hidden > 0 and format("  |cff999999(%d for other classes or factions hidden)|r", hidden) or ""))
    allButton.text:SetText(showAll and "Just mine" or "Show all")
    content:SetHeight(-bottom + 10)
    local range = math.max(0, content:GetHeight() - scroll:GetHeight())
    scrollBar:SetMinMaxValues(0, range)
    scrollBar:SetShown(range > 0)
    if scrollBar:GetValue() > range then scrollBar:SetValue(range) end
end

function ns.BuildSecrets(parent)
    page = parent
    summary = ns.Text(page, 11, ns.color.dim)
    summary:SetPoint("TOPLEFT", ns.UI.pad, -6)
    allButton = ns.CreateButton(page, "Show all", 90, 20, function()
        showAll = not showAll
        ns.RefreshSecrets()
    end)
    allButton:SetPoint("TOPRIGHT", -ns.UI.pad, -2)

    scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", 0, -28)
    scroll:SetPoint("BOTTOMRIGHT", -14, 0)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(ns.UI.width - 14, 10)
    scroll:SetScrollChild(content)
    scrollBar = CreateFrame("Slider", nil, page, ns.BACKDROP)
    scrollBar:SetPoint("TOPRIGHT", -4, -30)
    scrollBar:SetPoint("BOTTOMRIGHT", -4, 2)
    scrollBar:SetWidth(8)
    ns.Skin(scrollBar, ns.color.panel, ns.color.border)
    scrollBar:SetOrientation("VERTICAL")
    local thumb = scrollBar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ns.color.gold))
    thumb:SetSize(6, 30)
    scrollBar:SetThumbTexture(thumb)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValue(0)
    scrollBar:SetScript("OnValueChanged", function(_, v) scroll:SetVerticalScroll(v) end)
    scrollBar:Hide()
    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", function(_, delta)
        local _, maxV = scrollBar:GetMinMaxValues()
        scrollBar:SetValue(math.max(0, math.min(maxV, scrollBar:GetValue() - delta * SCROLL_STEP)))
    end)
    view = ns.CreateLineView(content, ns.UI.pad, ns.UI.width - ns.UI.pad * 2 - 14)
    page:SetScript("OnShow", ns.RefreshSecrets)
end

local redrawQueued = false
local function QueueRedraw()
    if redrawQueued then return end
    redrawQueued = true
    C_Timer.After(0.5, function()
        redrawQueued = false
        ns.RefreshSecrets()
    end)
end

table.insert(ns.inits, function()
    ns.On("GET_ITEM_INFO_RECEIVED", function() if page and page:IsVisible() then QueueRedraw() end end)
    ns.On("QUEST_TURNED_IN", function() C_Timer.After(1, ns.RefreshSecrets) end)
    ns.On("BAG_UPDATE_DELAYED", function() ns.RefreshSecrets() end)
end)
