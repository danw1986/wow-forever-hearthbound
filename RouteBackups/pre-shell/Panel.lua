local ADDON_NAME, ns = ...

-- The levelling panel: a header with the XP bar, then a stack of sections
-- that modules register with ns.AddSection. It resizes to fit its contents.

local floor, format = math.floor, string.format

local WIDTH = 250
local PAD = 10
local INNER = WIDTH - PAD * 2
local TOP = -50

---------------------------------------------------------------------------
-- Formatting
---------------------------------------------------------------------------
function ns.Comma(n)
    local s = tostring(floor(n))
    local result = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (result:gsub("^,", ""))
end

function ns.Short(n)
    if n >= 1e6 then return format("%.1fm", n / 1e6) end
    if n >= 1e4 then return format("%.1fk", n / 1e3) end
    return ns.Comma(n)
end

function ns.Duration(sec)
    sec = floor(sec)
    if sec >= 3600 then return format("%dh %02dm", floor(sec / 3600), floor(sec % 3600 / 60)) end
    if sec >= 60 then return format("%dm %02ds", floor(sec / 60), sec % 60) end
    return format("%ds", sec)
end

-- 43210 copper -> "4g 32s 10c" with coin colours; signed when asked
function ns.Money(copper, signed)
    copper = floor(copper or 0)
    local sign = ""
    if copper < 0 then
        sign, copper = "-", -copper
    elseif signed then
        sign = "+"
    end
    local g, s, c = floor(copper / 10000), floor(copper % 10000 / 100), copper % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = ns.Comma(g) .. "|cffffd700g|r" end
    if s > 0 or g > 0 then parts[#parts + 1] = s .. "|cffc7c7cfs|r" end
    if g == 0 then parts[#parts + 1] = c .. "|cffeda55fc|r" end
    return sign .. table.concat(parts, " ")
end

function ns.IconText(icon, size)
    if not icon then return "" end
    size = size or 12
    return format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t ", tostring(icon), size, size)
end

---------------------------------------------------------------------------
-- Sections
---------------------------------------------------------------------------
ns.sections = {}

-- build(add, level) adds lines through add.header/row/note/list/bar
function ns.AddSection(order, build)
    table.insert(ns.sections, { order = order, build = build })
    table.sort(ns.sections, function(a, b) return a.order < b.order end)
end

-- Names for the Settings "Panel order" list (sections are known by their order number)
ns.SECTION_NAMES = {
    [5] = "Guide", [10] = "XP numbers", [11] = "Session goal", [12] = "Road to 60", [20] = "Trainer", [22] = "Quest log", [23] = "Objectives nearby",
    [24] = "Where next", [25] = "Class quests", [26] = "Grind spots", [27] = "Travel", [28] = "Left behind", [30] = "Coming up",
    [35] = "Gold", [40] = "Gear", [41] = "Supplies", [42] = "Weapon skill", [50] = "Level history",
}

-- the sections in the order you chose (Settings), then any you haven't placed in their usual order
function ns.OrderedSections()
    local chosen = ns.db.sectionOrder
    if type(chosen) ~= "table" or #chosen == 0 then return ns.sections end
    local byOrder, placed, list = {}, {}, {}
    for _, s in ipairs(ns.sections) do byOrder[s.order] = byOrder[s.order] or {} table.insert(byOrder[s.order], s) end
    for _, order in ipairs(chosen) do
        if byOrder[order] and not placed[order] then
            placed[order] = true
            for _, s in ipairs(byOrder[order]) do list[#list + 1] = s end
        end
    end
    for _, s in ipairs(ns.sections) do
        if not placed[s.order] then list[#list + 1] = s end
    end
    return list
end

---------------------------------------------------------------------------
-- Frame
---------------------------------------------------------------------------
local frame, view, xpBar, restBar, questBar, levelText, pctText, barText
local scroll, content, thumb -- the sections scroll once the panel reaches its height limit
local scrollOffset, scrollMax = 0, 0
local SCROLL_STEP = 40

---------------------------------------------------------------------------
-- Quick buttons along the bottom: open the companion window's tabs and
-- toggle a couple of things, without going through the minimap button
---------------------------------------------------------------------------
local QI = "Interface\\Icons\\"
local QUICK = {
    { label = "Quests", tab = "quests", icon = QI .. "INV_Misc_Book_08", tip = "Completed quests, quests nearby and Forever's secrets" },
    { label = "Dungeons", tab = "dungeons", icon = QI .. "INV_Misc_Key_14", tip = "The dungeon journal: quests, loot and map markers" },
    { label = "Stats", tab = "stats", icon = QI .. "INV_Misc_Note_01", tip = "This session, where your XP comes from and the best mobs" },
    { label = "Journey", tab = "journey", icon = QI .. "Ability_Mount_RidingHorse", tip = "Road to 60, milestones and deaths" },
    { label = "Achievements", tab = "achievements", icon = QI .. "INV_Misc_Gem_Diamond_01", tip = "Every achievement and how close you are" },
    { label = "Alts", tab = "alts", icon = QI .. "INV_Misc_GroupLooking", tip = "All your characters: level, rested XP and gold" },
    { label = "Quest targets", short = "Targets", icon = QI .. "Ability_Hunter_SniperShot", tip = "Show or hide the quest targets window",
      onClick = function() ns.ToggleQuestTargets() end },
    { label = "Cards", icon = QI .. "INV_Misc_Ticket_Tarot_Stack_01", tip = "Your enemy card collection, zone by zone",
      onClick = function() ns.ToggleCards() end },
    { label = "Guide", icon = QI .. "INV_Misc_Map_01", tip = "Show or hide the levelling guide and its arrow",
      onClick = function() ns.ToggleGuide() end },
    { label = "Compact", icon = QI .. "INV_Misc_Spyglass_02", tip = "Switch the panel between full and compact",
      onClick = function()
          ns.db.compactPanel = not ns.db.compactPanel
          ns.RefreshAll()
      end },
    { label = "Settings", tab = "settings", icon = QI .. "Trade_Engineering", tip = "All of Hearthbound's settings" },
}
local QUICK_PER_ROW, QUICK_H, QUICK_GAP = 3, 18, 3
local quickBar

local function BuildQuickBar()
    quickBar = CreateFrame("Frame", nil, frame)
    -- labelled buttons, three to a row
    local rowsCount = math.ceil(#QUICK / QUICK_PER_ROW)
    quickBar:SetSize(INNER, rowsCount * QUICK_H + (rowsCount - 1) * QUICK_GAP)
    local w = (INNER - (QUICK_PER_ROW - 1) * QUICK_GAP) / QUICK_PER_ROW
    for i, q in ipairs(QUICK) do
        local onClick = q.onClick or function() ns.ToggleOptions(q.tab, true) end
        local b = ns.CreateButton(quickBar, q.short or q.label, w, QUICK_H, onClick)
        b.text:SetFont(ns.FONT, 10, "")
        local col, row = (i - 1) % QUICK_PER_ROW, math.floor((i - 1) / QUICK_PER_ROW)
        b:SetPoint("TOPLEFT", col * (w + QUICK_GAP), -row * (QUICK_H + QUICK_GAP))
        b:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(q.label, 1, 1, 1)
            GameTooltip:AddLine(q.tip, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        b:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

-- The bars glide to their new value rather than jumping (a level-up starts from empty)
local SMOOTH_SPEED = 6
local smoothing = {}

local function SmoothSet(bar, value)
    if not bar.shown then
        bar.shown = value
        bar:SetValue(value)
        return
    end
    if value < bar.shown - 0.5 then bar.shown = 0 end -- levelled up: refill from the start
    bar.target = value
    smoothing[bar] = true
end

local function OnSmoothUpdate(_, elapsed)
    for bar in pairs(smoothing) do
        local step = (bar.target - bar.shown) * math.min(1, elapsed * SMOOTH_SPEED)
        if math.abs(bar.target - bar.shown) < 0.002 then
            bar.shown = bar.target
            smoothing[bar] = nil
        else
            bar.shown = bar.shown + step
        end
        bar:SetValue(bar.shown)
    end
end

local function UpdateHeader(level)
    local maxLevel = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    if level >= maxLevel then
        levelText:SetText("LEVEL " .. level)
        pctText:SetText("")
        xpBar:SetValue(1)
        restBar:SetValue(0)
        questBar:SetValue(0)
        barText:SetText("Maximum level")
        return
    end
    local cur, max = UnitXP("player"), UnitXPMax("player")
    if not max or max == 0 then max = 1 end
    local rested = GetXPExhaustion() or 0
    levelText:SetText(format("LEVEL %d  |cff999999>  %d|r", level, level + 1))
    pctText:SetText(format("%.1f%%", cur / max * 100))
    SmoothSet(xpBar, cur / max)
    SmoothSet(restBar, math.min(1, (cur + rested) / max))
    -- XP waiting in finished quests
    local waiting = 0
    if ns.db.questXPPreview then
        for _, q in ipairs(ns.openQuests or {}) do
            if q.complete and q.xp then waiting = waiting + q.xp end
        end
    end
    SmoothSet(questBar, math.min(1, (cur + waiting) / max))
    local text = ns.Comma(cur) .. " / " .. ns.Comma(max)
    if waiting > 0 then
        text = text .. (cur + waiting >= max and "  |cff6fdc6fhand in to level!|r"
            or format("  |cffffd200+%s ready|r", ns.Short(waiting)))
    end
    barText:SetText(text)
end

local reported = {}

-- What each section writes to: folds collapsed headings, and in compact mode
-- drops the headings and keeps only the most useful line under each (the
-- first one; two for the heading-less XP numbers)
local COMPACT_LINES_NO_HEADER = 2
local LINE_KINDS = { "row", "note", "list", "bar" }

-- In the full panel each heading shows at most ns.db.sectionMaxLines lines
-- (0: no limit); the rest fold into a "+N more" line you can click open.
local function SectionWriter()
    local compact = ns.db.compactPanel
    local folded = false
    local budget = compact and COMPACT_LINES_NO_HEADER or math.huge
    local cap = (ns.db.sectionMaxLines or 0) > 0 and ns.db.sectionMaxLines or math.huge
    local key, count, hidden, expanded, over = nil, 0, 0, false, false
    local writer = {}

    -- the "+N more" / "Show less" line at the end of a capped section
    function writer.flush()
        if compact or not key or folded then return end
        local k = key
        if hidden > 0 then
            view.add.note(format("|cff999999+%d more - click to show|r", hidden), nil, function()
                ns.db.expandedSections[k] = true
                ns.UpdatePanel()
            end, "Show every line in this section")
        elseif over then
            view.add.note("|cff999999Show less|r", nil, function()
                ns.db.expandedSections[k] = nil
                ns.UpdatePanel()
            end, "Fold this section back to its first lines")
        end
        hidden, over = 0, false
    end

    function writer.header(text)
        writer.flush()
        key = text:lower()
        folded = ns.db.collapsedSections[key] and true or false
        expanded = ns.db.expandedSections[key] and true or false
        count = 0
        budget = compact and 1 or math.huge
        if compact then return end -- compact has no headings; folded sections vanish
        view.add.header(text, {
            collapsed = folded,
            onClick = function()
                ns.db.collapsedSections[key] = (not folded) or nil
                ns.UpdatePanel()
            end,
        })
    end

    for _, kind in ipairs(LINE_KINDS) do
        writer[kind] = function(...)
            if folded or budget <= 0 then return end
            if key and not compact then
                count = count + 1
                if count > cap then
                    if not expanded then
                        hidden = hidden + 1
                        return
                    end
                    over = true
                end
            end
            budget = budget - 1
            view.add[kind](...)
        end
    end
    return writer
end

-- scroll the sections to offset (clamped), and place the scrollbar thumb
local function SetScroll(offset)
    scrollOffset = math.max(0, math.min(scrollMax, offset))
    scroll:SetVerticalScroll(scrollOffset)
    if scrollMax <= 0 then
        thumb:Hide()
        return
    end
    local visible = scroll:GetHeight()
    local total = visible + scrollMax
    local h = math.max(16, visible * visible / total)
    thumb:SetHeight(h)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, TOP - (visible - h) * scrollOffset / scrollMax)
    thumb:Show()
end

function ns.UpdatePanel()
    if not frame or not frame:IsShown() then return end
    local level = UnitLevel("player")
    UpdateHeader(level)
    view:Begin()
    for _, section in ipairs(ns.OrderedSections()) do
        local writer = SectionWriter()
        local ok, err = pcall(section.build, writer, level)
        if ok then ok, err = pcall(writer.flush) end
        if not ok and not reported[section] then
            reported[section] = true -- once, rather than every second
            ns.Print("|cffff5544Panel error:|r " .. tostring(err))
        end
    end
    -- the sections, scrolling once they're taller than the limit
    local contentHeight = -view:Render(0) + 4
    content:SetHeight(math.max(1, contentHeight))
    local limit = math.max(150, ns.db.panelMaxHeight or 600)
    local visible = math.min(contentHeight, limit)
    scroll:SetHeight(math.max(1, visible))
    scrollMax = math.max(0, contentHeight - visible)
    scroll:EnableMouseWheel(scrollMax > 0) -- otherwise the wheel still zooms the camera
    SetScroll(scrollOffset)
    local height = -TOP + visible + 8
    if ns.db.quickButtons then
        if not quickBar then BuildQuickBar() end
        quickBar:ClearAllPoints()
        quickBar:SetPoint("TOPLEFT", PAD, -height)
        quickBar:Show()
        height = height + quickBar:GetHeight() + 8
    elseif quickBar then
        quickBar:Hide()
    end
    frame:SetHeight(height)
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundXP", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, 120)
    ns.Skin(frame, ns.color.bg, ns.color.border)
    ns.RegisterMover(frame, "xp", "LEVELING PANEL", "RIGHT", "RIGHT", -60, 120)
    scroll = CreateFrame("ScrollFrame", nil, frame)
    scroll:SetPoint("TOPLEFT", 0, TOP)
    scroll:SetSize(WIDTH, 1)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(WIDTH, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnMouseWheel", function(_, delta) SetScroll(scrollOffset - delta * SCROLL_STEP) end)
    thumb = frame:CreateTexture(nil, "OVERLAY")
    thumb:SetWidth(3)
    thumb:SetColorTexture(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.7)
    thumb:Hide()
    view = ns.CreateLineView(content, PAD, INNER)

    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)

    -- your character's face in a thin gold circle beside the level, kept inside the
    -- header (between the top edge and the XP bar)
    local CIRCLE = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
    local function Round(texture)
        pcall(function()
            local mask = frame:CreateMaskTexture()
            mask:SetTexture(CIRCLE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(texture)
            texture:AddMaskTexture(mask)
        end)
    end
    local ring = frame:CreateTexture(nil, "BORDER")
    ring:SetSize(20, 20)
    ring:SetPoint("TOPLEFT", PAD - 2, -6)
    ring:SetColorTexture(unpack(ns.color.gold))
    Round(ring)
    local portrait = frame:CreateTexture(nil, "ARTWORK")
    portrait:SetPoint("TOPLEFT", ring, "TOPLEFT", 1, -1)
    portrait:SetPoint("BOTTOMRIGHT", ring, "BOTTOMRIGHT", -1, 1)
    Round(portrait)
    local function UpdatePortrait() if SetPortraitTexture then pcall(SetPortraitTexture, portrait, "player") end end
    UpdatePortrait()
    ns.On("UNIT_PORTRAIT_UPDATE", function(_, unit) if unit == "player" then UpdatePortrait() end end)
    ns.On("PLAYER_ENTERING_WORLD", UpdatePortrait)

    frame:SetScript("OnUpdate", OnSmoothUpdate)
    levelText = ns.Text(frame, 13, ns.color.gold)
    levelText:SetPoint("LEFT", ring, "RIGHT", 6, 0)
    pctText = ns.Text(frame, 13, ns.color.text)
    pctText:SetPoint("TOPRIGHT", -PAD, -10)

    -- rested bar sits behind the XP bar, showing how far rested XP reaches
    local holder = ns.CreateBar(frame, INNER, 14, { 0.30, 0.50, 0.95 })
    holder:SetPoint("TOPLEFT", PAD, -30)
    restBar = holder.bar
    restBar:SetStatusBarColor(0.30, 0.50, 0.95, 0.45)
    holder.left:Hide()
    holder.right:Hide()

    -- what handing in your finished quests would add, between the rested and XP bars
    questBar = CreateFrame("StatusBar", nil, holder)
    questBar:SetAllPoints(restBar)
    questBar:SetFrameLevel(restBar:GetFrameLevel() + 1)
    questBar:SetStatusBarTexture(ns.WHITE)
    questBar:SetStatusBarColor(0.95, 0.78, 0.25, 0.55)
    questBar:SetMinMaxValues(0, 1)
    questBar:SetValue(0)

    xpBar = CreateFrame("StatusBar", nil, holder)
    xpBar:SetAllPoints(restBar)
    xpBar:SetFrameLevel(restBar:GetFrameLevel() + 2)
    xpBar:SetStatusBarTexture(ns.WHITE)
    xpBar:SetStatusBarColor(0.62, 0.30, 0.95)
    xpBar:SetMinMaxValues(0, 1)
    barText = ns.Text(xpBar, 10, ns.color.text, "OUTLINE")
    barText:SetPoint("CENTER")
end

-- In combat the panel steps aside for the Cooldown Manager: hidden, or faded
local COMBAT_ALPHA = 0.25
local inCombat = false

local function Refresh()
    if not frame then return end
    frame:SetScale(ns.db.xpScale)
    local bg = ns.color.bg
    frame:SetBackdropColor(bg[1], bg[2], bg[3], ns.db.panelOpacity or bg[4])
    local away = inCombat and ns.db.combatHide and not ns.unlocked
    local shown = (ns.db.xp or ns.unlocked) and not (away and not ns.db.combatFade)
    frame:SetShown(shown)
    frame:SetAlpha((away and ns.db.combatFade) and COMBAT_ALPHA or 1)
    ns.UpdatePanel()
end
table.insert(ns.refreshers, Refresh)

table.insert(ns.inits, function()
    Build()
    inCombat = UnitAffectingCombat("player") and true or false
    ns.On("PLAYER_REGEN_DISABLED", function()
        inCombat = true
        Refresh()
    end)
    ns.On("PLAYER_REGEN_ENABLED", function()
        inCombat = false
        Refresh()
    end)
    ns.On("PLAYER_ENTERING_WORLD", Refresh)
    ns.On("PLAYER_XP_UPDATE", function() ns.UpdatePanel() end)
    ns.On("UPDATE_EXHAUSTION", function() ns.UpdatePanel() end)
    ns.On("PLAYER_LEVEL_UP", function() C_Timer.After(0.5, ns.UpdatePanel) end)
    C_Timer.NewTicker(1, ns.UpdatePanel)
end)
