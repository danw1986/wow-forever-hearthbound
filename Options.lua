local ADDON_NAME, ns = ...

local WIDTH = ns.UI.width -- the shell's content column (Shell.lua)

local lockButton
local widgets = {}
local searchable = {} -- settings the search box can find: { widget, text (lower case), y, cat }
local buildingCat     -- the settings category being built, stamped on each searchable entry
local RefreshWidgets -- defined below; the order list needs it
local format = string.format

local function NewColumn(parent, x, width)
    local col = { x = x, y = 0, w = width, parent = parent }

    function col:Header(text)
        self.y = self.y - 8
        local h = ns.CreateHeader(parent, text, self.w)
        h:SetPoint("TOPLEFT", self.x, self.y)
        self.y = self.y - 22
    end

    function col:Check(label, key, tip)
        local c = ns.CreateCheck(parent, label, tip,
            function() return ns.db[key] end,
            function(v) ns.db[key] = v; ns.RefreshAll() end)
        c:SetWidth(self.w)
        c:SetPoint("TOPLEFT", self.x, self.y)
        table.insert(widgets, c)
        searchable[#searchable + 1] = { widget = c, text = (label .. " " .. (tip or "")):lower(), y = -self.y, cat = buildingCat }
        self.y = self.y - 24
    end

    function col:Slider(label, key, tip, minV, maxV, step, fmt)
        local s = ns.CreateSlider(parent, label, tip, minV, maxV, step, fmt,
            function() return ns.db[key] end,
            function(v) ns.db[key] = v; ns.RefreshAll() end)
        s:SetWidth(self.w)
        s:SetPoint("TOPLEFT", self.x, self.y)
        table.insert(widgets, s)
        searchable[#searchable + 1] = { widget = s, text = (label .. " " .. (tip or "")):lower(), y = -self.y, cat = buildingCat }
        self.y = self.y - 46
    end

    -- numeric input with a label to its left
    function col:Input(label, tip, getter, setter)
        local text = ns.Text(parent, 12)
        text:SetPoint("TOPLEFT", self.x, self.y - 4)
        text:SetText(label)
        local eb = ns.CreateEditBox(parent, 80, 22, "none")
        eb:SetPoint("TOPRIGHT", parent, "TOPLEFT", self.x + self.w, self.y)
        eb:SetNumeric(true)
        eb:SetMaxLetters(6)
        eb:HookScript("OnTextChanged", function(box, userInput)
            if userInput then setter(tonumber(box:GetText())) end
        end)
        if tip then
            eb:SetScript("OnEnter", function(box)
                GameTooltip:SetOwner(box, "ANCHOR_RIGHT")
                GameTooltip:SetText(label, 1, 1, 1)
                GameTooltip:AddLine(tip, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            eb:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        eb.Refresh = function()
            local v = getter()
            eb:SetText(v and v > 0 and tostring(v) or "")
        end
        table.insert(widgets, eb)
        self.y = self.y - 30
    end

    function col:Button(label, onClick)
        local b = ns.CreateButton(parent, label, self.w, 24, onClick)
        b:SetPoint("TOPLEFT", self.x, self.y)
        self.y = self.y - 32
        return b
    end

    -- the panel's sections in order, each with up / down buttons
    function col:OrderList()
        local rows = {}
        local function Current()
            local list = {}
            for _, s in ipairs(ns.OrderedSections()) do
                local seen = false
                for _, o in ipairs(list) do if o == s.order then seen = true end end
                if not seen then list[#list + 1] = s.order end
            end
            return list
        end
        local function Move(i, delta)
            local list = Current()
            local j = i + delta
            if j < 1 or j > #list then return end
            list[i], list[j] = list[j], list[i]
            ns.db.sectionOrder = list
            RefreshWidgets()
            ns.UpdatePanel()
        end
        local count = #Current()
        for i = 1, count do
            local row = CreateFrame("Frame", nil, parent)
            row:SetSize(self.w, 20)
            row:SetPoint("TOPLEFT", self.x, self.y)
            row.label = ns.Text(row, 11)
            row.label:SetPoint("LEFT", 4, 0)
            local down = ns.CreateButton(row, "Down", 44, 18, function() Move(i, 1) end)
            down:SetPoint("RIGHT", 0, 0)
            local up = ns.CreateButton(row, "Up", 34, 18, function() Move(i, -1) end)
            up:SetPoint("RIGHT", down, "LEFT", -3, 0)
            up.text:SetFont(ns.FONT, 10, "")
            down.text:SetFont(ns.FONT, 10, "")
            row.Refresh = function()
                local order = Current()[i]
                row.label:SetText(format("|cff999999%d.|r %s", i, order and (ns.SECTION_NAMES[order] or ("Section " .. order)) or ""))
                up:SetEnabled(i > 1)
                down:SetEnabled(i < count)
            end
            table.insert(widgets, row)
            rows[i] = row
            self.y = self.y - 22
        end
        searchable[#searchable + 1] = { widget = rows[1] or parent, text = "panel order sections move up down reorder", y = -self.y, cat = buildingCat }
    end

    -- a list of choices, one of them picked: { value, label, desc } each
    function col:Choice(choices, getter, setter, findText)
        local first
        for _, c in ipairs(choices) do
            local h = c.desc and c.desc ~= "" and 40 or 24
            local b = ns.CreateButton(parent, "", self.w, h, function()
                setter(c.value)
                RefreshWidgets()
            end)
            b:SetPoint("TOPLEFT", self.x, self.y)
            b.text:ClearAllPoints()
            b.text:SetPoint("TOPLEFT", 8, -6)
            b.text:SetJustifyH("LEFT")
            b:SetScript("OnMouseDown", nil)
            b:SetScript("OnMouseUp", nil)
            if h > 24 then
                b.desc = ns.Text(b, 10, ns.color.dim)
                b.desc:SetPoint("TOPLEFT", b.text, "BOTTOMLEFT", 0, -3)
                b.desc:SetPoint("RIGHT", -8, 0)
                b.desc:SetJustifyH("LEFT")
                b.desc:SetWordWrap(false)
                b.desc:SetText(c.desc)
            end
            b.Refresh = function()
                local on = getter() == c.value
                b.text:SetText((on and "|cff6fdc6f>|r " or "") .. c.label)
                b:SetSelected(on)
            end
            table.insert(widgets, b)
            first = first or b
            self.y = self.y - h - 4
        end
        if first then
            searchable[#searchable + 1] = { widget = first, text = findText or "", y = -self.y, cat = buildingCat }
        end
        self.y = self.y - 4
    end

    -- something built elsewhere, the column's width: make(parent, width) returns it
    function col:Widget(height, make)
        local w = make(parent, self.w)
        w:SetPoint("TOPLEFT", self.x, self.y)
        self.y = self.y - height - 6
        return w
    end

    -- two half-width buttons side by side
    function col:ButtonPair(label1, onClick1, label2, onClick2)
        local w = (self.w - 6) / 2
        local b1 = ns.CreateButton(parent, label1, w, 24, onClick1)
        b1:SetPoint("TOPLEFT", self.x, self.y)
        local b2 = ns.CreateButton(parent, label2, w, 24, onClick2)
        b2:SetPoint("TOPLEFT", self.x + w + 6, self.y)
        self.y = self.y - 32
        return b1, b2
    end

    return col
end

function RefreshWidgets()
    for _, w in ipairs(widgets) do w.Refresh() end
    if lockButton then
        lockButton.text:SetText(ns.unlocked and "Lock position" or "Unlock position")
    end
end


-- The settings outgrew the window: they sit in a scrolling frame
local SCROLL_STEP = 40

local SEARCH_H = 30

-- top: room left above it (the search box), width: of the area
local function ScrollingContent(page, top, width)
    top = top or SEARCH_H
    local scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", 0, -top) -- the search box sits above
    scroll:SetPoint("BOTTOMRIGHT", -14, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize((width or WIDTH) - 14, 10)
    scroll:SetScrollChild(content)

    local bar = CreateFrame("Slider", nil, page, ns.BACKDROP)
    bar:SetPoint("TOPRIGHT", -4, -top - 2)
    bar:SetPoint("BOTTOMRIGHT", -4, 2)
    bar:SetWidth(8)
    ns.Skin(bar, ns.color.panel, ns.color.border)
    bar:SetOrientation("VERTICAL")
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ns.color.gold))
    thumb:SetSize(6, 30)
    bar:SetThumbTexture(thumb)
    bar:SetScript("OnValueChanged", function(_, v) scroll:SetVerticalScroll(v) end)

    local function Range()
        return math.max(0, content:GetHeight() - scroll:GetHeight())
    end
    local function Update()
        local range = Range()
        bar:SetMinMaxValues(0, range)
        bar:SetShown(range > 0)
        if scroll:GetVerticalScroll() > range then bar:SetValue(range) end
    end
    scroll:SetScript("OnSizeChanged", Update)
    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", function(_, delta)
        bar:SetValue(math.max(0, math.min(Range(), bar:GetValue() - delta * SCROLL_STEP)))
    end)
    -- called once the columns are built, with how tall they ended up
    function content.SetContentHeight(_, height)
        content:SetHeight(height)
        Update()
    end
    -- bring a spot (y below the top) into view
    function content.ScrollTo(_, y)
        bar:SetValue(math.max(0, math.min(Range(), y - 20)))
    end
    return content
end

-- Settings search: dims every option that doesn't match, counts the matches in
-- each category, and shows the first category (and setting) that matches
local categories = {}   -- { key, label, button, area, content }
local SelectCategory    -- defined with the page

local function Search(text)
    text = strtrim(text or ""):lower()
    local counts, first = {}, {}
    for _, e in ipairs(searchable) do
        local match = text == "" or e.text:find(text, 1, true) ~= nil
        e.widget:SetAlpha(match and 1 or 0.3)
        if match and text ~= "" and e.cat then
            counts[e.cat] = (counts[e.cat] or 0) + 1
            if not first[e.cat] or e.y < first[e.cat] then first[e.cat] = e.y end
        end
    end
    local target
    for _, c in ipairs(categories) do
        local n = counts[c.key]
        c.matches = (text ~= "" and n) or nil
        c.dimmed = text ~= "" and not n
        if n and not target then target = c end
    end
    if ns.ShellRefresh then ns.ShellRefresh() end
    if text == "" then return end
    -- stay on this category if it has a match, otherwise go to the first that does
    local current
    for _, c in ipairs(categories) do if c.area:IsShown() then current = c end end
    if current and counts[current.key] then target = current end
    if target then
        SelectCategory(target.key)
        target.content:ScrollTo(first[target.key])
    end
end

local SIDEBAR_W = 0 -- the categories are listed in the shell's menu column
local settingsSelected

-- the categories, in the order they're listed, under their menu headings
local CATEGORY_LIST = {
    { key = "panel", label = "Panel", group = "General" },
    { key = "layout", label = "Look & layout", group = "General" },
    { key = "order", label = "Panel order", group = "General" },
    { key = "extras", label = "Pop-ups & extras", group = "General" },
    { key = "guide", label = "Levelling guide", group = "Levelling" },
    { key = "quests", label = "Questing", group = "Levelling" },
    { key = "xp", label = "XP & gold", group = "Levelling" },
    { key = "vendors", label = "Vendors & bags", group = "Levelling" },
    { key = "cards", label = "Enemy cards", group = "Levelling" },
    { key = "profiles", label = "Profiles & help", group = "Account" },
}

-- the settings menu (in the shell's menu column): each category, under its heading
function ns.SettingsMenu()
    local items, group = {}, nil
    for _, c in ipairs(categories) do
        if c.group ~= group then
            group = c.group
            items[#items + 1] = { header = true, label = group }
        end
        items[#items + 1] = { label = c.label, count = c.matches, selected = c.key == settingsSelected,
                              colour = c.dimmed and { 0.45, 0.45, 0.45, 1 } or nil,
                              onClick = function() SelectCategory(c.key) end }
    end
    return items
end
function ns.SettingsCategoryLabel()
    for _, c in ipairs(categories) do if c.key == settingsSelected then return c.label end end
end

local function BuildSettingsPage(page)
    local search = ns.CreateEditBox(page, 220, 22, "Search settings...")
    search:SetPoint("TOPLEFT", ns.UI.pad, -4)
    search:HookScript("OnTextChanged", function(box) Search(box:GetText()) end)

    local areaW = WIDTH - SIDEBAR_W - ns.UI.pad
    local colW = areaW - 14 - ns.UI.pad * 2
    local selected

    function SelectCategory(key)
        selected, settingsSelected = key, key
        for _, c in ipairs(categories) do c.area:SetShown(c.key == key) end
        ns.db.settingsCategory = key
        if ns.ShellRefresh then ns.ShellRefresh() end
    end

    -- each category: a button down the left and its own scrolling column on the right
    local columns = {}
    for i, info in ipairs(CATEGORY_LIST) do
        local c = { key = info.key, label = info.label, group = info.group }
        c.area = CreateFrame("Frame", nil, page)
        c.area:SetPoint("TOPLEFT", SIDEBAR_W, -SEARCH_H)
        c.area:SetPoint("BOTTOMRIGHT", 0, 0)
        c.content = ScrollingContent(c.area, 0, areaW)
        c.area:Hide()
        categories[#categories + 1] = c
        columns[info.key] = NewColumn(c.content, ns.UI.pad, colW)
    end
    -- what each category holds
    local function In(key)
        buildingCat = key
        return columns[key]
    end
    local function Find(col, widget, text)
        searchable[#searchable + 1] = { widget = widget, text = text, y = -col.y, cat = buildingCat }
    end

    -- Panel: what the levelling panel shows
    local col = In("panel")
    col:Header("Panel sections")
    col:Check("Show leveling panel", "xp", "The whole panel: XP bar, XP per hour, time to level and more.")
    col:Check("Trainer reminder", "showTrainer",
        "Lists skills waiting at your class trainer. Open the trainer once so it knows exactly what you've learned.")
    col:Check("Road to 60", "showRoad", "Forecast of the play time to your next milestone levels, from your pace.")
    col:Check("Quest log helper", "showQuestLog",
        "Your open quests: what's ready to hand in, about to turn grey or too hard to solo.")
    col:Check("Best XP quests", "showQuestXP", "Under Quest log: your open quests with the biggest XP rewards.")
    col:Check("Rested XP tip", "restedTip",
        "While you have rested XP, a reminder that mobs give double XP and roughly how many kills of bonus are left.")
    col:Check("Where next", "showZones",
        "Rates your zone for your level and suggests where to go, using zone level ranges and the quests you carry.")
    col:Check("Dungeon suggestions", "showDungeons",
        "Under Where next: the dungeons that suit your level, including WoW Forever's nine new ones.")
    col:Check("Upcoming skills", "showUpcoming", "Skills unlocking in your next few levels - something to look forward to.")
    col:Slider("Upcoming levels shown", "upcomingLevels", "How many future levels to list.", 1, 6, 1, "%d")
    col:Check("Class quests", "showQuests", "Reminders for your class's quest chains when your level reaches them: spells, pets, forms, totems and weapons.")
    col:Check("Objectives nearby", "showObjectives",
        "The closest mobs, items, objects and places your quests still need, with distances. Click one to mark it.")
    col:Check("Grind spots", "showGrind",
        "When quests run dry: the best mobs to kill in your zone for your level. Click one to mark the nearest.")
    col:Check("Travel", "showTravel", "Your hearthstone, and flight paths in this zone you haven't learned (open a flight map once first).")
    col:Check("Left behind", "showLeftBehind", "Lists the quests you walked away from: click one to mark it, right-click to forget it.")
    col:Check("Supplies & bag space", "showSupplies", "Warns when food runs low, there's better food for your level, or your bags are nearly full.")
    col:Check("Repair warning", "showGear", "Shows your most worn gear and warns in chat when it gets low.")
    col:Check("Weapon skill warning", "weaponSkillTips", "Warns when the skill for a weapon you're using is behind for your level.")
    col:Check("Level history", "showHistory", "How long this level is taking, plus your average and fastest levels.")

    -- Levelling guide
    col = In("guide")
    col:Header("Levelling guide")
    col:Check("Show the guide", "guide",
        "A RestedXP-style step-by-step Horde route that ticks off steps as you quest. Back and Next let you look over or skip steps. /hb guide")
    col:Check("Guide arrow", "guideArrow", "A movable arrow pointing at the current guide step, with the yards to go. Shift-right-click it to hide.")
    col:Check("Current step in the panel", "guidePanel", "The current guide step as a line in the levelling panel.")
    col:Check("Skip quests too low for XP", "guideSkipGrey",
        "The guide passes quests that are grey for you (picked up in an area you've outlevelled). They stay in the route, greyed, and come back if you turn this off.")
    col:Check("Turn the arrow round", "guideArrowTurned", "Only if the arrow points the wrong way on your client.")
    col:Check("Steps on the map", "guideMapPins",
        "The next few steps as numbered pins on the world map and minimap, joined by a dotted trail.")
    col:Check("Next step pop-up", "guideStepPopup", "A short note in the middle of the screen each time the guide moves on.")
    col:Check("Compact guide", "guideCompact", "The guide window shows only the current step. The - button on the window does the same.")
    col:Header("Guide look")
    col:Check("Old list layout", "guideListLayout",
        "The guide window lists the steps before and after yours, with buttons along the bottom. Off (the default): just the step you're on - the place, what to do there with tick boxes, and its details. The guide moves on by itself either way.")
    col:Slider("Guide size", "guideScale", "How big the guide window (and its step panel) is.", 0.7, 1.5, 0.05, "%.2f")
    col:Check("Current step under the window", "guideCardBelow",
        "The current step's panel hangs under the guide window instead of sitting on top of it.")
    col:Slider("Current step text size", "guideStepFont", "How big the current step's text is.", 10, 16, 1, "%d")
    col:Slider("Steps after the current one", "guideUpcoming", "How many coming steps the window lists (compact shows none).", 0, 10, 1, "%d")
    col:Check("Colour the step by its kind", "guideTypeColours",
        "The current step's panel is yellow for a pick-up, green for a hand-in, blue for a quest to do, purple for a dungeon... Off: always the addon's accent colour.")
    col:Check("Step numbers", "guideStepNumbers", "Each step's number in the route, on the right.")
    col:Header("What to leave out")
    col:Check("Skip group (elite) quests", "guideSkipGroup", "Leaves out quests marked Group - elite quests outside dungeons.")
    col:Check("Skip dungeons", "guideSkipDungeons", "Leaves out dungeon steps and the quests done inside dungeons.")
    local unskip = col:Button("Stop skipping right-clicked quests", function() if ns.GuideCommand then ns.GuideCommand("unskip") end end)
    Find(col, unskip, "guide unskip skip list always skip right-click")
    col:Header("Adapting to you")
    col:Check("Follow the zone I'm in", "guideAutoZone",
        "Arriving in a zone (or logging in) where the route has steps worth doing, the guide switches to that zone's section by itself - the one nearest your level - and says so in chat.")
    col:Check("Ask to switch when I arrive in a new zone", "guideZonePrompt",
        "Arriving in a zone the guide isn't following, a prompt offers that zone's section (the one nearest your level). Stay: it won't ask about that zone again until you leave and come back.")
    col:Check("Send me to nearby quests", "guideAdaptive",
        "When a quest in your log can be got on with close by - mobs or items it needs, or its hand-in - the guide shows it as Nearby and the arrow points there until it's done.")
    col:Slider("How near is nearby (yards)", "guideAdaptYards", "How close a quest objective or hand-in has to be to send you there.", 100, 800, 25, "%d")
    col:Check("Quest item button", "guideItemButton",
        "A button for the item the current step needs you to use (a totem, a taming rod, an item that starts a quest...). Click it to use the item; drag to move it.")
    col:Check("Skip low-value quests", "guideSkipLowValue",
        "Passes by quests marked optional: ones that are a long walk for the XP they give (worked out from the route and QuestieDB's XP). Quests you've already picked up are never skipped.")
    col:Check("Learn from my play", "guideLearn",
        "Writes down which quests NPCs offer you, the XP and levels of the quests you do and how long each level takes - so the route can be ordered by Forever's real quest chains. Kept only on this computer; /hb learn shows it.")
    col:Slider("Route steps close by (yards)", "guideNearYards", "A pick-up, quest or hand-in from the route this close to you becomes the step to do, so quests near each other get done together.", 30, 300, 10, "%d")
    col:Check("Show my class quests", "guideClassQuests",
        "Your class's quests from QuestieDB - including Forever's new ones, like the Undead paladin's - as a Class quest line: the ones in your log, then the ones you can pick up. Click it to follow it.")
    col:Header("Route")
    col:Button("Route overview: zones to follow or skip  >", function() ns.ShellOpen("guide", "zones") end)
    local find = col:ButtonPair("Find my place", function() if ns.GuideCommand then ns.GuideCommand("find") end end,
        "Choose a section", function()
            if not ns.db.guide then
                ns.db.guide = true
                ns.RefreshAll()
            end
            if ns.ToggleGuidePicker then ns.ToggleGuidePicker() end
        end)
    Find(col, find, "guide find place section zone jump")
    local reset = col:Button("Reset guide progress", function() if ns.GuideCommand then ns.GuideCommand("reset") end end)
    Find(col, reset, "guide reset progress start over")

    -- Questing
    col = In("quests")
    col:Header("Picking up and handing in")
    col:Check("Auto accept quests", "autoAccept",
        "Accepts quests when you talk to a quest giver. Hold Shift to do it by hand. Toggle quickly with /hb accept.")
    col:Check("Auto hand in quests", "autoQuest",
        "Hands in finished quests and skips quest NPCs' chat. Stops when there's a reward to choose. Hold Shift to do it by hand.")
    col:Check("Skip grey quests", "autoQuestSkipGrey", "Don't auto-accept quests that are too low to give much XP.")
    col:Check("Reward picker", "rewardPicker",
        "When a quest offers a choice, highlights the best upgrade for your class (or the best to sell) and says why.")
    col:Check("Pick rewards for me", "rewardAutoPick",
        "With auto hand in on, takes the reward the picker chose instead of waiting for you.")
    col:Header("Finding your way")
    col:Check("Quest pins on maps", "questPins",
        "! on the world map and minimap for quests you can pick up, ? for quests ready to hand in. Click a pin to mark it.")
    col:Check("Quest targets window", "showTargets",
        "A small window of the mobs your quests still need, nearest first. Left-click one to target it, right-click to mark it on the map. Drag it to move it.")
    col:Slider("Quest targets within (yards)", "targetsYards", "The quest targets window only lists mobs this close to you, or that you can see.", 100, 1000, 25, "%d")
    col:Check("Quest NPCs in quest targets", "targetsNpcs",
        "The quest targets window also lists NPCs close by that you can pick a quest up from or hand one in to, so you can target and mark them. They drop off once there's nothing left to do with them.")
    col:Check("Raid markers on quest targets", "targetSkull",
        "Clicking a mob in the quest targets window also marks it: skull for the first row, then cross, square, moon, triangle and diamond.")
    col:Check("Don't leave yet alert", "leaveTownAlert",
        "Warns when you walk away from quests you could pick up or hand in. /hb left lists them.")
    col:Header("Tooltips and chat")
    col:Check("Quest mob tooltips", "mobQuestTips",
        "Hover a mob to see which of your quests want it: kills (3/10) and the quest items it drops.")
    col:Check("Mob XP & danger tooltips", "mobXPTips", "Mob tooltips show XP per kill, kills to level and how often it has killed you.")
    col:Check("Completed quest links", "questLinkLabels",
        "Adds (Completed) after quest links in chat for quests you've already done.")
    col:Check("Announce in party chat", "announceParty",
        "Posts to party chat while grouped: when you finish one of a quest's objectives, when a quest is ready to hand in, and when you turn one in.")
    col:Check("Include XP gained", "announceXP", "Adds the quest's XP reward to the party message.")

    -- Enemy cards
    col = In("cards")
    col:Header("Enemy cards")
    col:Check("Collect enemy cards", "cards",
        "Every different enemy you defeat adds its card to your collection, filed by zone. /hb cards opens it.")
    col:Check("New card pop-up", "cardPopups", "Shows each new card for a few seconds at the top of the screen as you collect it.")
    col:Check("Card sounds", "cardSounds", "A sound when a card drops and when you take it.")
    col:Check("Card line in enemy tooltips", "cardTooltips",
        "Hovering an enemy says whether you have its card yet, and how many you've defeated.")
    local open = col:ButtonPair("Open the collection", function() if ns.ToggleCards then ns.ToggleCards() end end,
        "Card debug", function() if ns.CardsDebug then ns.CardsDebug() end end)
    Find(col, open, "cards collection open debug")

    -- XP & gold
    col = In("xp")
    col:Header("Experience")
    col:Check("Quest XP on the XP bar", "questXPPreview",
        "A gold stretch on the panel's XP bar shows what handing in your finished quests would add.")
    col:Check("Quest XP on the game's XP bar", "blizzQuestXP",
        "The same gold stretch on the XP bar along the bottom of the screen.")
    local resetXP = col:Button("Reset XP session", function() ns.ResetXPSession() end)
    Find(col, resetXP, "reset xp session experience")
    col:Header("Gold")
    col:Check("Gold tracker", "showGold", "Gold earned per hour, this session's gold and your savings goal.")
    col:Input("Savings goal (gold)", "Shows a progress bar towards this much gold, e.g. for your mount. Per character; leave empty for none.",
        function() return ns.cdb.goldGoal end,
        function(v) ns.cdb.goldGoal = v; ns.UpdatePanel() end)

    -- Vendors & bags
    col = In("vendors")
    col:Header("Vendors & bags")
    col:Check("Sell junk at vendors", "autoSell",
        "Sells grey items, and quest items whose quests are all finished, when you open a vendor. Hold Shift to skip.")
    col:Check("Auto repair", "autoRepair", "Repairs all gear when you open a vendor who can repair. Hold Shift to skip.")
    col:Check("Quest item help", "questItemTips",
        "Item tooltips say which quest needs an item (keep it) or that its quests are done (safe to sell), and you get a pop-up when something in your bags starts a quest.")
    col:Check("All characters' gold in bags", "bagGoldTooltip",
        "Hover the gold in your bags to see every character's gold and the total.")

    -- Look & layout
    col = In("layout")
    col:Header("Enemy nameplates")
    col:Check("Nameplates in Hearthbound's style", "hbPlates",
        "Nameplates drawn in the addon's look: the level and name above a flat health bar on a dark panel with a crisp border, health %, the threat bar and the cast bar under it, your debuffs above, the raid marker beside it - and your target in gold, with the others dimmed. Off: the game's own nameplates, with just the threat bar under them.")
    col:Check("Threat bar under enemy nameplates", "threatPlates",
        "In combat, a thin bar under each enemy's nameplate, filled to your threat: red - you have aggro, yellow - you're losing it (or about to pull it off someone), green - it's on someone else. The plate itself isn't changed. Needs the game's enemy nameplates on (V). Try it: target an enemy and type /hb plates test.")
    col:Check("Health bar in the threat colour", "threatHealth",
        "In a fight, the enemy's health bar turns the threat bar's colour too: red - you have aggro, yellow - you're losing it, green - it's on someone else. (Hearthbound's nameplates only.)")
    col:Check("Hide the threat glow on my unit frames", "hideFrameThreat",
        "The game's own red glow (and threat number) on your player and target frames - hidden, so threat only shows on the enemies.")
    col:Check("Threat % in a group", "threatPlatesText", "Your threat %, left of the bar in its colour - in a group or with a pet out (solo it's always you).")
    col:Check("My debuffs above nameplates", "threatPlatesDebuffs",
        "With the game's own nameplates (Hearthbound's style off): your own debuffs in a row above the name, instead of the game's. (Hearthbound's style always shows yours.)")
    col:Header("The panel")
    col:Check("Quick buttons", "quickButtons",
        "Buttons along the bottom of the panel to open Quests, Dungeons, Stats, Journey, Alts, Cards and Settings, and to toggle the targets window, the guide and compact mode.")
    col:Check("Compact panel", "compactPanel",
        "A slimmer panel: the XP bar, XP per hour and time to level, plus the most useful line from each section.")
    col:Check("Hide panel in combat", "combatHide",
        "Gets the panel out of the way during fights (the Cooldown Manager covers combat). It comes back when combat ends.")
    col:Check("Fade instead of hiding", "combatFade", "Keep the panel faintly visible in combat rather than hiding it.")
    col:Slider("Panel scale", "xpScale", nil, 0.5, 1.8, 0.05, "%.2f")
    col:Slider("Panel opacity", "panelOpacity", "How see-through the panel's background is.", 0.3, 1, 0.05, "%.2f")
    col:Slider("Panel max height", "panelMaxHeight",
        "Past this height the panel's sections scroll (mouse wheel over them).", 250, 1200, 10, "%d")
    col:Slider("Lines per section", "sectionMaxLines",
        "Longer sections (Left behind, Travel...) show this many lines and a \"+N more\" line to open the rest. 0: no limit.", 0, 20, 1, "%d")
    lockButton = col:ButtonPair("Unlock position", function()
        ns.SetUnlocked(not ns.unlocked)
        RefreshWidgets()
    end, "Reset position", function()
        ns.ResetPositions()
        ns.Print("Frame position reset.")
    end)
    Find(col, lockButton, "unlock lock reset position move panel")
    col:Header("Colours")
    local function ThemeLabel()
        for _, t in ipairs(ns.THEMES) do if t.key == ns.db.theme then return "Theme: " .. t.label end end
        return "Theme: Hearthbound"
    end
    local themeButton = col:ButtonPair(ThemeLabel(), function(self)
        local index = 1
        for i, t in ipairs(ns.THEMES) do if t.key == ns.db.theme then index = i end end
        ns.db.theme = ns.THEMES[index % #ns.THEMES + 1].key
        self.text:SetText(ThemeLabel())
        ns.Print("Theme saved - press |cffc79c6eReload UI|r to see it.")
    end, "Reload UI", function() ReloadUI() end)
    Find(col, themeButton, "theme colour colours reload")
    col:Check("Minimap XP ring", "minimapRing", "A ring of dots around the minimap button that fills with your XP.")

    -- Pop-ups & extras
    col = In("extras")
    col:Header("Pop-ups & extras")
    col:Check("Milestone pop-ups", "toasts", "A banner and sound for level 10s, mount time, quest and kill counts and achievements.")
    col:Check("Share milestones with guild", "announceGuild",
        "Posts your milestones to guild chat when you're in a guild, e.g. \"[Hearthbound] Level 30! 30 levels to go.\"")
    col:Check("Level-up screenshots", "screenshots", "Takes a screenshot each time you level up - a picture diary of your journey.")
    col:Check("Minimap button", "showMinimap", "Left-click for settings, right-click for quests, hover for a summary.")
    col:Check("Welcome back window", "welcomeBack", "On login: time away, rested XP gained, your last session and your alts.")
    col:Check("Talent point reminder", "talentReminder", "A pop-up and a panel line when you have talent points to spend.")

    -- Panel order
    col = In("order")
    col:Header("Panel order")
    col:OrderList()

    -- Profiles & help
    col = In("profiles")
    col:Header("Profiles & help")
    local exportButton = col:ButtonPair("Export settings", function() ns.ExportSettings() end,
        "Import settings", function() ns.ImportSettingsWindow() end)
    Find(col, exportButton, "profile export import copy settings")
    local debugButton = col:Button("Debug report", function() ns.DebugReport() end)
    Find(col, debugButton, "debug report bug error help")
    local setupButton = col:Button("Run setup again", function() ns.ShowSetup() end)
    Find(col, setupButton, "setup wizard first time start new character")

    buildingCat = nil
    for _, c in ipairs(categories) do c.content:SetContentHeight(-columns[c.key].y + 12) end
    local remembered = ns.db.settingsCategory
    SelectCategory(columns[remembered or ""] and remembered or "panel")
end

---------------------------------------------------------------------------
-- The shell's panels from this file and the old tabs (Shell.lua draws them)
---------------------------------------------------------------------------
local function Call(name, ...)
    local fn = ns[name]
    if fn then return fn(...) end
end

ns.ShellSection({
    key = "quests", label = "Quests", order = 2, icon = "Interface\\GossipFrame\\AvailableQuestIcon",
    build = function(parent) ns.BuildQuestTab(parent) end,
    menu = function() return Call("QuestTabMenu") or {} end,
    title = function() return Call("QuestTabTitle") or "Quests" end,
    subtitle = function() return Call("QuestTabSummary") or "" end,
    onShow = function(sub) Call("QuestTabSelect", sub) end,
})

ns.ShellSection({
    key = "dungeons", label = "Dungeons", order = 3, icon = "Interface\\GossipFrame\\BattleMasterGossipIcon",
    build = function(parent) ns.BuildJournalTab(parent) end,
    menu = function() return Call("JournalMenu") or {} end,
    title = function() return Call("JournalTitle") or "Dungeons" end,
    subtitle = function() return Call("JournalSummary") or "" end,
})

-- Character: your stats and journey, and your alts - one panel each, chosen in the menu
local characterPages, characterShown = {}, "stats"
local CHARACTER = {
    { key = "stats", label = "Stats", group = "This character", build = "BuildStatsTab", refresh = "RefreshStats",
      title = "Stats", summary = "This session, where your XP comes from and the best mobs" },
    { key = "journey", label = "Journey", group = "This character", build = "BuildJourneyTab", refresh = "RefreshJourney",
      title = "Journey", summary = "Road to 60, milestones and deaths" },
    { key = "alts", label = "Alts", group = "Account", build = "BuildAltsTab", refresh = "RefreshAlts",
      title = "Alts", summary = "All your characters: level, rested XP and gold" },
}
local function ShowCharacter(key)
    if not characterPages[key] then key = "stats" end
    characterShown = key
    for k, p in pairs(characterPages) do p:SetShown(k == key) end
end
ns.ShellSection({
    key = "character", label = "Character", order = 5, icon = "Interface\\GossipFrame\\TrainerGossipIcon",
    build = function(parent)
        for _, c in ipairs(CHARACTER) do
            local p = CreateFrame("Frame", nil, parent)
            p:SetAllPoints()
            p:Hide()
            characterPages[c.key] = p
            Call(c.build, p)
        end
    end,
    menu = function()
        local items, group = {}, nil
        for _, c in ipairs(CHARACTER) do
            if c.group ~= group then
                group = c.group
                items[#items + 1] = { header = true, label = group }
            end
            items[#items + 1] = { label = c.label, selected = c.key == characterShown, onClick = function() ShowCharacter(c.key) end }
        end
        return items
    end,
    title = function()
        for _, c in ipairs(CHARACTER) do if c.key == characterShown then return c.title end end
    end,
    subtitle = function()
        for _, c in ipairs(CHARACTER) do if c.key == characterShown then return c.summary end end
    end,
    onShow = function(sub) ShowCharacter(sub or characterShown) end,
})

ns.ShellSection({
    key = "achievements", label = "Awards", order = 6, icon = "Interface\\GossipFrame\\PetitionGossipIcon",
    build = function(parent) ns.BuildAchievementsTab(parent) end,
    menu = function() return Call("AchievementsMenu") or {} end,
    title = function() return Call("AchievementsTitle") or "Achievements" end,
    subtitle = function() return Call("AchievementsSummary") or "" end,
})

ns.ShellSection({
    key = "settings", label = "Settings", order = 99, bottom = true, icon = "Interface\\Buttons\\UI-OptionsButton",
    build = function(parent) BuildSettingsPage(parent) end,
    menu = function() return ns.SettingsMenu() end,
    title = function() return ns.SettingsCategoryLabel() or "Settings" end,
    subtitle = "Settings  |cff777777-|r  search them all with the box at the top",
    onShow = function(sub)
        if sub and SelectCategory then SelectCategory(sub) end
        RefreshWidgets()
    end,
})

-- the old tab names, for everything that opens a part of the window
local OLD_TABS = {
    settings = { "settings" }, quests = { "quests" }, dungeons = { "dungeons" }, achievements = { "achievements" },
    stats = { "character", "stats" }, journey = { "character", "journey" }, alts = { "character", "alts" },
    cards = { "cards" }, guide = { "guide" },
}

-- tab: optional part of the window to open on ("settings", "quests", "stats"...)
-- closeIfOpen: clicking the button for the part already showing closes the window
function ns.ToggleOptions(tab, closeIfOpen)
    local where = OLD_TABS[tab or ""]
    if not where then
        if ns.ShellCurrent() then return ns.ShellToggle(ns.ShellCurrent()) end
        return ns.ShellOpen(ns.db.shellLast or "guide")
    end
    local key, sub = where[1], where[2]
    if closeIfOpen and ns.ShellCurrent() == key and (not sub or key ~= "character" or characterShown == sub) then
        return ns.ShellToggle(key)
    end
    ns.ShellOpen(key, sub)
end
