local ADDON_NAME, ns = ...

-- Setup: a few pages of choices the first time you log in on a level 1
-- character (the guide, quest automation, vendors, pop-ups). Every choice is
-- an ordinary setting, so Settings can change it later, and /hb setup or
-- the button in Settings brings the whole thing back.

local format = string.format

local WIDTH, HEIGHT = 440, 380
local I = "Interface\\Icons\\"

local frame, pageIndex = nil, 1
local widgets = {} -- what the current page put up, hidden on the next one

local function Set(key, value)
    if ns.db[key] == value then return end
    if key == "showTargets" and ns.ToggleQuestTargets then
        ns.ToggleQuestTargets() -- also shows or hides the window
    else
        ns.db[key] = value
    end
    ns.RefreshAll()
end

-- { label, key, tip } per tick box
local PAGES = {
    {
        title = "Welcome", icon = I .. "Ability_Warrior_BattleShout",
        text = function()
            return format("Welcome, |cffffd200%s|r! Let's set Hearthbound up for the road to 60.\n\n"
                .. "This takes about a minute. Every choice here is an ordinary setting, so you can change it "
                .. "any time in |cffc79c6e/hb|r - and you can run this setup again later with "
                .. "|cffc79c6e/hb setup|r or the |cffffd200Run setup again|r button in Settings.\n\n"
                .. "Your settings are shared by all your characters, so changes here apply to your alts too.",
                UnitName("player") or "adventurer")
        end,
    },
    {
        title = "Levelling guide", icon = I .. "INV_Misc_Map_01",
        text = function()
            if UnitFactionGroup("player") ~= "Horde" then
                return "The step-by-step route is Horde only for now, so it stays hidden on this character. "
                    .. "These choices still apply to your Horde characters."
            end
            return "A RestedXP-style route from 1 to 60. Steps tick off by themselves as you pick up, finish and "
                .. "hand in quests, and Back / Next let you look ahead or skip. The arrow points at the current step "
                .. "with the yards to go."
        end,
        checks = {
            { "Show the levelling guide", "guide", "The step-by-step window. /hb guide shows or hides it." },
            { "Show the guide arrow", "guideArrow", "A movable arrow pointing at the current step. Shift-right-click it to hide." },
            { "Current step in the panel", "guidePanel", "One line in the levelling panel with the step you're on." },
            { "Skip quests too low for XP", "guideSkipGrey", "Passes quests that are grey for you, e.g. in an area you've come back to. They stay in the route." },
        },
    },
    {
        title = "Questing", icon = I .. "INV_Misc_Book_08",
        text = function() return "How much of the quest clicking Hearthbound does for you." end,
        checks = {
            { "Accept quests automatically", "autoAccept", "Picks up quests as soon as you talk to the quest giver. Hold Shift to stop it." },
            { "Hand in finished quests", "autoQuest", "Turns in completed quests when you talk to the NPC. Rewards with a choice wait for you." },
            { "Skip grey (trivial) quests", "autoQuestSkipGrey", "Doesn't auto accept quests too low to give decent XP." },
            { "Suggest the best reward", "rewardPicker", "Highlights the quest reward that's best for you, or worth most at a vendor." },
            { "Pick that reward for me", "rewardAutoPick", "Takes the suggested reward without asking." },
            { "Quest targets window", "showTargets", "A small window listing the mobs and objects your quests need, with distances." },
            { "Quest markers on the map", "questPins", "Pins for quest givers and hand-ins on the world map." },
        },
    },
    {
        title = "On the road", icon = I .. "INV_Misc_Bag_08",
        text = function() return "Vendors, repairs and how the panel behaves." end,
        checks = {
            { "Sell grey junk at vendors", "autoSell", "Sells your grey items whenever you open a vendor." },
            { "Repair at vendors", "autoRepair", "Repairs your gear whenever you talk to a vendor who can." },
            { "Compact panel", "compactPanel", "A smaller panel with just the most useful line of each section." },
            { "Hide the panel in combat", "combatHide", "Steps aside while you fight (it fades rather than vanishing)." },
            { "Minimap button", "showMinimap", "Left-click for settings, right-click for quests." },
            { "Welcome back window", "welcomeBack", "On login: time away, rested XP gained and how your last session went." },
        },
    },
    {
        title = "Celebrations", icon = I .. "INV_Misc_Gem_Diamond_01",
        text = function() return "Pop-ups and announcements for levels, milestones and achievements." end,
        checks = {
            { "Achievement pop-ups", "toasts", "A pop-up when you level up or unlock an achievement." },
            { "Tell my party when I level", "announceParty", "A short message in party chat when you ding." },
            { "Share milestones with my guild", "announceGuild", "Posts milestones like level 60 to guild chat." },
            { "Screenshot each level-up", "screenshots", "Takes a screenshot just after the level-up glow starts." },
        },
    },
    {
        title = "All set", icon = I .. "Ability_Warrior_Rampage",
        text = function()
            return "You're ready to go. Good luck out there - and remember, this isn't hardcore, so a death "
                .. "or two is only a corpse run.\n\n"
                .. "|cffffd200Handy commands|r\n"
                .. "|cffc79c6e/hb|r  settings (also the minimap button)\n"
                .. "|cffc79c6e/hb guide|r  show or hide the levelling guide\n"
                .. "|cffc79c6e/hb setup|r  run this setup again\n"
                .. "|cffc79c6e/hb help|r  every command"
        end,
    },
}

local function Clear()
    for _, w in ipairs(widgets) do w:Hide() end
    wipe(widgets)
end

local checkPool = {}
local function Check(i, def)
    local c = checkPool[i]
    if not c then
        -- the box reads its setting as soon as it's made, before c is set
        c = ns.CreateCheck(frame, "", nil, function() return c and ns.db[c.key] end, function(v) Set(c.key, v) end)
        c:SetWidth(WIDTH - 40)
        c:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.label, 1, 1, 1)
            GameTooltip:AddLine(self.tip, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        c:HookScript("OnLeave", function() GameTooltip:Hide() end)
        checkPool[i] = c
    end
    c.key, c.label, c.tip = def[2], def[1], def[3]
    -- the label is the check's only font string besides the box
    for _, region in ipairs({ c:GetRegions() }) do
        if region.SetText then region:SetText(def[1]) end
    end
    c.Refresh()
    return c
end

local function ShowPage(index)
    pageIndex = math.max(1, math.min(#PAGES, index))
    local page = PAGES[pageIndex]
    Clear()
    frame.title:SetText(ns.InlineIcon(page.icon, 16) .. page.title)
    frame.step:SetText(format("%d / %d", pageIndex, #PAGES))
    frame.body:SetText(page.text())
    local y = -58 - frame.body:GetStringHeight() - 14
    for i, def in ipairs(page.checks or {}) do
        local c = Check(i, def)
        c:ClearAllPoints()
        c:SetPoint("TOPLEFT", 20, y)
        c:Show()
        widgets[#widgets + 1] = c
        y = y - 24
    end
    frame.back:SetShown(pageIndex > 1)
    frame.next.text:SetText(pageIndex == #PAGES and "Finish" or "Next")
    frame.skip:SetShown(pageIndex < #PAGES)
    -- progress dots
    for i, dot in ipairs(frame.dots) do
        dot:SetColorTexture(unpack(i <= pageIndex and ns.color.accent or ns.color.border))
    end
end

local function Finish()
    ns.cdb.setupDone = true
    frame:Hide()
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundSetupFrame", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER", 0, 60)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.97 }, ns.color.gold)
    -- closing it counts as done (it won't pop up again by itself) - but not the game
    -- hiding the whole interface (a cinematic), nor an Escape pressed the moment it
    -- appeared (that one was meant for the cinematic)
    frame:SetScript("OnShow", function(self) self.shownAt = GetTime() end)
    frame:SetScript("OnHide", function(self)
        if not UIParent:IsShown() then return end
        if GetTime() - (self.shownAt or 0) < 1.5 then
            C_Timer.After(1, function() if not ns.cdb.setupDone then self:Show() end end)
            return
        end
        ns.cdb.setupDone = true
    end)
    table.insert(UISpecialFrames, "HearthboundSetupFrame")

    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)

    local brand = ns.Text(frame, 10, ns.color.dim)
    brand:SetPoint("TOPLEFT", 20, -12)
    brand:SetText("HEARTHBOUND SETUP")
    frame.step = ns.Text(frame, 10, ns.color.dim)
    frame.step:SetPoint("TOPRIGHT", -32, -12)
    local close = ns.CreateButton(frame, "x", 18, 18, function()
        ns.cdb.setupDone = true -- closed on purpose, however soon
        frame:Hide()
    end)
    close:SetPoint("TOPRIGHT", -8, -8)

    frame.title = ns.Text(frame, 16, ns.color.gold)
    frame.title:SetPoint("TOPLEFT", 20, -30)
    frame.body = ns.Text(frame, 12)
    frame.body:SetPoint("TOPLEFT", 20, -58)
    frame.body:SetWidth(WIDTH - 40)
    frame.body:SetJustifyH("LEFT")
    frame.body:SetSpacing(2)

    frame.dots = {}
    for i = 1, #PAGES do
        local dot = frame:CreateTexture(nil, "ARTWORK")
        dot:SetSize(18, 3)
        dot:SetPoint("BOTTOM", (i - (#PAGES + 1) / 2) * 22, 44)
        frame.dots[i] = dot
    end

    frame.skip = ns.CreateButton(frame, "Skip setup", 96, 24, function()
        Finish()
        ns.Print("Setup skipped - |cffc79c6e/hb setup|r runs it any time.")
    end)
    frame.skip:SetPoint("BOTTOMLEFT", 16, 12)
    frame.next = ns.CreateButton(frame, "Next", 96, 24, function()
        if pageIndex == #PAGES then
            Finish()
            ns.Print("All set. |cffc79c6e/hb setup|r runs the setup again.")
        else
            ShowPage(pageIndex + 1)
        end
    end)
    frame.next:SetPoint("BOTTOMRIGHT", -16, 12)
    frame.back = ns.CreateButton(frame, "Back", 96, 24, function() ShowPage(pageIndex - 1) end)
    frame.back:SetPoint("RIGHT", frame.next, "LEFT", -6, 0)
end

function ns.ShowSetup()
    if InCombatLockdown() then
        return ns.Print("Setup will be easier out of combat - try again in a moment.")
    end
    if not frame then Build() end
    ShowPage(1)
    frame.shownAt = GetTime()
    frame:Show()
end

-- is the game showing something over the interface? (a new character's opening
-- cinematic, a movie, the loading screen)
local function Busy()
    if InCinematic and InCinematic() then return true end
    if CinematicFrame and CinematicFrame:IsShown() then return true end
    if MovieFrame and MovieFrame:IsShown() then return true end
    if not UIParent:IsShown() then return true end
    return InCombatLockdown()
end

table.insert(ns.inits, function()
    ns.On("PLAYER_LOGIN", function()
        if ns.cdb.setupDone or UnitLevel("player") > 2 then return end
        -- a brand new character: offer the setup once - after its opening cinematic
        -- and the login messages (checked each second, for up to five minutes)
        local waited, quiet = 0, 0
        local function Try()
            if ns.cdb.setupDone then return end
            waited = waited + 1
            quiet = Busy() and 0 or quiet + 1
            if quiet >= 3 then return ns.ShowSetup() end
            if waited < 300 then C_Timer.After(1, Try) end
        end
        C_Timer.After(1, Try)
    end)
end)
