local ADDON_NAME, ns = ...

-- The game's own XP bar (along the bottom of the screen) gets the same gold
-- stretch as the panel: the XP waiting in finished quests, drawn just past
-- your current XP. Classic's MainMenuExpBar and the newer status tracking
-- bars are both looked for, since Forever could use either.

local format = string.format
local GOLD = { 0.95, 0.78, 0.25, 0.6 }

local bar     -- the StatusBar we found
local overlay -- our gold texture on it

local function IsXPBar(b)
    if not (b and b.GetObjectType and b:GetObjectType() == "StatusBar") then return false end
    local ok, low, high = pcall(b.GetMinMaxValues, b)
    if not ok or ns.IsSecret(high) then return false end
    local max = UnitXPMax("player")
    return high and max and max > 0 and math.abs(high - max) < 1 and low == 0
end

-- look through a frame's children for the XP status bar (a few levels deep)
local function Search(f, depth)
    if not f or depth > 4 then return nil end
    if IsXPBar(f) then return f end
    if f.StatusBar and IsXPBar(f.StatusBar) then return f.StatusBar end
    local ok, children = pcall(function() return { f:GetChildren() } end)
    if not ok then return nil end
    for _, child in ipairs(children) do
        local found = Search(child, depth + 1)
        if found then return found end
    end
end

local function FindBar()
    if IsXPBar(rawget(_G, "MainMenuExpBar")) then return MainMenuExpBar end -- Classic
    for _, name in ipairs({ "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer",
                            "StatusTrackingBarManager", "MainMenuBar" }) do
        local found = Search(rawget(_G, name), 0)
        if found then return found end
    end
end

local function Waiting()
    local waiting = 0
    for _, q in ipairs(ns.openQuests or {}) do
        if q.complete and q.xp then waiting = waiting + q.xp end
    end
    return waiting
end

local function Attach(b)
    bar = b
    overlay = b:CreateTexture(nil, "ARTWORK", nil, 7)
    overlay:SetColorTexture(unpack(GOLD))
    overlay:Hide()
    b:HookScript("OnSizeChanged", function() ns.UpdateBlizzXPBar() end)
    -- a line in the bar's tooltip, when it has one
    b:HookScript("OnEnter", function(self)
        local w = Waiting()
        if w > 0 and ns.db.blizzQuestXP and GameTooltip:IsOwned(self) then
            GameTooltip:AddLine(format("+%s XP ready to hand in", ns.Comma and ns.Comma(w) or w), GOLD[1], GOLD[2], GOLD[3])
            GameTooltip:Show()
        end
    end)
end

function ns.UpdateBlizzXPBar()
    if not bar then
        local b = FindBar()
        if not b then return end
        Attach(b)
    end
    local max, cur = UnitXPMax("player"), UnitXP("player")
    local waiting = ns.db.blizzQuestXP and Waiting() or 0
    local width = bar:GetWidth()
    if waiting <= 0 or not max or max <= 0 or not width or width <= 0 or not bar:IsVisible() then
        overlay:Hide()
        return
    end
    -- from the end of your XP to where handing everything in takes you (stops at the level)
    local from = math.min(1, cur / max)
    local to = math.min(1, (cur + waiting) / max)
    if to - from < 0.002 then
        overlay:Hide()
        return
    end
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPLEFT", bar, "TOPLEFT", width * from, 0)
    overlay:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", width * from, 0)
    overlay:SetWidth(width * (to - from))
    overlay:Show()
end

table.insert(ns.inits, function()
    local function Update() pcall(ns.UpdateBlizzXPBar) end
    for _, event in ipairs({ "PLAYER_XP_UPDATE", "QUEST_LOG_UPDATE", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD" }) do
        ns.On(event, function() C_Timer.After(0.5, Update) end)
    end
    -- the quest list fills in a moment after events, and Edit Mode can move the bar
    C_Timer.NewTicker(2, Update)
    table.insert(ns.refreshers, Update)
end)
