local ADDON_NAME, ns = ...

local WIDTH, HEIGHT = ns.UI.width, 660
local PAGE_TOP = -98  -- below the header and tab buttons
local PAGE_BOTTOM = 34 -- above the footer

local frame, lockButton
local widgets = {}
local searchable = {} -- settings the search box can find: { widget, text (lower case), y, cat }
local buildingCat     -- the settings category being built, stamped on each searchable entry
local RefreshWidgets -- defined below; the order list needs it
local format = string.format
local pages, tabs = {}, {}

local function NewColumn(parent, x, width)
    local col = { x = x, y = 0, w = width }

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

local currentTab

local function SelectTab(key)
    currentTab = key
    for k, page in pairs(pages) do page:SetShown(k == key) end
    for _, tab in ipairs(tabs) do tab:SetSelected(tab.key == key) end
end

local function NewPage(key)
    local page = CreateFrame("Frame", nil, frame)
    page:SetPoint("TOPLEFT", 0, PAGE_TOP)
    page:SetPoint("BOTTOMRIGHT", 0, PAGE_BOTTOM)
    page:Hide()
    pages[key] = page
    return page
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
        c.button.text:SetText(c.label .. ((text ~= "" and n) and format("  |cff6fdc6f%d|r", n) or ""))
        c.button:SetAlpha((text == "" or n) and 1 or 0.45)
        if n and not target then target = c end
    end
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

local SIDEBAR_W = 150

-- the categories, in the order they're listed
local CATEGORY_LIST = {
    { key = "panel", label = "Panel" },
    { key = "guide", label = "Levelling guide" },
    { key = "quests", label = "Questing" },
    { key = "cards", label = "Enemy cards" },
    { key = "xp", label = "XP & gold" },
    { key = "vendors", label = "Vendors & bags" },
    { key = "layout", label = "Look & layout" },
    { key = "extras", label = "Pop-ups & extras" },
    { key = "order", label = "Panel order" },
    { key = "profiles", label = "Profiles & help" },
}

local function BuildSettingsPage(page)
    local search = ns.CreateEditBox(page, 220, 22, "Search settings...")
    search:SetPoint("TOPLEFT", ns.UI.pad, -4)
    search:HookScript("OnTextChanged", function(box) Search(box:GetText()) end)

    local areaW = WIDTH - SIDEBAR_W - ns.UI.pad
    local colW = areaW - 14 - ns.UI.pad * 2
    local selected

    function SelectCategory(key)
        selected = key
        for _, c in ipairs(categories) do
            local on = c.key == key
            c.area:SetShown(on)
            c.button:SetBackdropColor(unpack(on and { ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.35 }
                or ns.color.panel))
        end
        ns.db.settingsCategory = key
    end

    -- each category: a button down the left and its own scrolling column on the right
    local columns = {}
    for i, info in ipairs(CATEGORY_LIST) do
        local c = { key = info.key, label = info.label }
        c.button = ns.CreateButton(page, info.label, SIDEBAR_W - ns.UI.pad, 24, function() SelectCategory(info.key) end)
        c.button:SetPoint("TOPLEFT", ns.UI.pad, -SEARCH_H - 6 - (i - 1) * 28)
        c.button.text:SetFont(ns.FONT, 11, "")
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
    col:Check("Class quests", "showQuests", "Reminders for the Defensive Stance, Berserker Stance and Whirlwind weapon quests.")
    col:Check("Objectives nearby", "showObjectives",
        "The closest mobs, items, objects and places your quests still need, with distances. Click one to mark it.")
    col:Check("Grind spots", "showGrind",
        "When quests run dry: the best mobs to kill in your zone for your level. Click one to mark the nearest.")
    col:Check("Travel", "showTravel", "Your hearthstone, and flight paths in this zone you haven't learned (open a flight map once first).")
    col:Check("Supplies & bag space", "showSupplies", "Warns when food runs low, there's better food for your level, or your bags are nearly full.")
    col:Check("Repair warning", "showGear", "Shows your most worn gear and warns in chat when it gets low.")
    col:Check("Weapon skill warning", "weaponSkillTips", "Warns when the skill for a weapon you're using is behind for your level.")
    col:Check("Level history", "showHistory", "How long this level is taking, plus your average and fastest levels.")

    -- Levelling guide
    col = In("guide")
    col:Header("Levelling guide")
    col:Check("Show the guide", "guide",
        "A RestedXP-style step-by-step Horde route that ticks off steps as you quest. Back and Next let you look over or skip steps. /hb guide")
    col:Check("Guide arrow", "guideArrow", "A movable arrow pointing at the current guide step, with the yards to go. Right-click it to hide.")
    col:Check("Current step in the panel", "guidePanel", "The current guide step as a line in the levelling panel.")
    col:Check("Skip quests too low for XP", "guideSkipGrey",
        "The guide passes quests that are grey for you (picked up in an area you've outlevelled). They stay in the route, greyed, and come back if you turn this off.")
    col:Check("Turn the arrow round", "guideArrowTurned", "Only if the arrow points the wrong way on your client.")
    col:Check("Steps on the map", "guideMapPins",
        "The next few steps as numbered pins on the world map and minimap, joined by a dotted trail.")
    col:Check("Next step pop-up", "guideStepPopup", "A short note in the middle of the screen each time the guide moves on.")
    col:Check("Compact guide", "guideCompact", "The guide window shows only the current step. The - button on the window does the same.")
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
    col:Check("Show my class quests", "guideClassQuests",
        "Your class's quests from QuestieDB - including Forever's new ones, like the Undead paladin's - as a Class quest line: the ones in your log, then the ones you can pick up. Click it to follow it.")
    col:Header("Route")
    local forever, classic
    local function RouteLabels()
        local on = ns.db.guideEdition or "forever"
        forever.text:SetText((on == "forever" and "|cff6fdc6f>|r " or "") .. "Forever route")
        classic.text:SetText((on == "classic" and "|cff6fdc6f>|r " or "") .. "Classic route")
    end
    local function Pick(edition)
        if ns.GuideSetEdition then ns.GuideSetEdition(edition) else ns.db.guideEdition = edition end
        RouteLabels()
    end
    forever, classic = col:ButtonPair("Forever route", function() Pick("forever") end,
        "Classic route", function() Pick("classic") end)
    RouteLabels()
    Find(col, forever, "guide route forever classic edition")
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
    col:Check("Raid markers on quest targets", "targetSkull",
        "Clicking a mob in the quest targets window also marks it: skull for the first row, then cross, square, moon, triangle and diamond.")
    col:Check("Don't leave yet alert", "leaveTownAlert",
        "Warns when you walk away from quests you could pick up or hand in, and lists them under Left behind.")
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
        return "Theme: Warrior"
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

local function Build()
    frame = CreateFrame("Frame", "HearthboundOptionsFrame", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.96 }, ns.color.border)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    table.insert(UISpecialFrames, "HearthboundOptionsFrame") -- Escape closes it

    -- header
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(3)

    local band = frame:CreateTexture(nil, "BORDER")
    band:SetColorTexture(1, 1, 1, 0.035)
    band:SetPoint("TOPLEFT", 1, -4)
    band:SetPoint("TOPRIGHT", -1, -4)
    band:SetHeight(56)

    local icon = ns.CreateIcon(frame, 38)
    icon:SetPoint("TOPLEFT", 14, -13)
    icon.icon:SetTexture(ns.SpellIcon(6673) or "Interface\\Icons\\Ability_Warrior_BattleShout")
    icon:SetBackdropBorderColor(unpack(ns.color.gold))

    local title = ns.Text(frame, 20, ns.color.gold)
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -1)
    title:SetText("HEARTHBOUND")
    local subtitle = ns.Text(frame, 11, ns.color.dim)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Leveling Companion")

    local close = ns.CreateButton(frame, "X", 24, 24, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -12, -16)

    -- tabs
    local x = 22
    local tabDefs = {
        { key = "settings", label = "Settings" },
        { key = "quests", label = "Quests" },
        { key = "stats", label = "Stats" },
        { key = "journey", label = "Journey" },
        { key = "dungeons", label = "Dungeons" },
        { key = "alts", label = "Alts" },
        { key = "achievements", label = "Achievements" },
    }
    -- share the width between the tabs
    local tabW = math.floor((WIDTH - 44 - (#tabDefs - 1) * 4) / #tabDefs)
    for _, def in ipairs(tabDefs) do
        local tab = ns.CreateButton(frame, def.label, tabW, 24, function() SelectTab(def.key) end)
        tab.text:SetFont(ns.FONT, 11, "")
        tab.key = def.key
        tab:SetPoint("TOPLEFT", x, -66)
        x = x + tabW + 4
        tabs[#tabs + 1] = tab
    end
    local tabLine = frame:CreateTexture(nil, "ARTWORK")
    tabLine:SetColorTexture(1, 1, 1, 0.06)
    tabLine:SetHeight(1)
    tabLine:SetPoint("TOPLEFT", 1, -94)
    tabLine:SetPoint("TOPRIGHT", -1, -94)

    BuildSettingsPage(NewPage("settings"))
    ns.BuildQuestTab(NewPage("quests"))
    ns.BuildStatsTab(NewPage("stats"))
    ns.BuildJourneyTab(NewPage("journey"))
    ns.BuildJournalTab(NewPage("dungeons"))
    ns.BuildAltsTab(NewPage("alts"))
    ns.BuildAchievementsTab(NewPage("achievements"))

    -- footer
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.06)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", 1, 30)
    divider:SetPoint("BOTTOMRIGHT", -1, 30)

    local version = ns.Text(frame, 10, ns.color.dim)
    version:SetPoint("BOTTOMLEFT", 14, 11)
    version:SetText("v" .. ns.version)

    local footer = ns.Text(frame, 10, ns.color.dim)
    footer:SetPoint("BOTTOMRIGHT", -14, 11)
    footer:SetText("/hb help   -   Esc to close")

    frame:SetScript("OnShow", RefreshWidgets)
    frame:Hide()
    SelectTab("settings")
end

-- tab: optional "settings", "quests" or "stats" to open on
-- closeIfOpen: clicking the button for the tab already showing closes the window
function ns.ToggleOptions(tab, closeIfOpen)
    if not frame then Build() end
    if tab then
        if closeIfOpen and frame:IsShown() and currentTab == tab then
            frame:Hide()
            return
        end
        SelectTab(tab)
        frame:Show()
        return
    end
    frame:SetShown(not frame:IsShown())
end
