local ADDON_NAME, ns = ...

-- Route overview: every zone and section of the levelling route, in order -
-- its levels, how much is done and left, and which one you're on. Click one
-- to follow it in the guide window; Skip leaves a whole zone out.
-- In Settings > Levelling guide, and as a window from the guide's More menu
-- or /hb guide route.

local format = string.format

local ROW_H = 26
local DOTS = {
    current = "Interface\\COMMON\\Indicator-Yellow", done = "Interface\\COMMON\\Indicator-Green",
    skipped = "Interface\\COMMON\\Indicator-Red", ahead = "Interface\\COMMON\\Indicator-Gray",
}

-- quest-level colours, from your level
local function LevelColour(level)
    if not level then return "999999" end
    local d = ns.QuestDifficulty and ns.QuestDifficulty(level, UnitLevel("player")) or "normal"
    return ({ impossible = "ff4040", hard = "ff8040", normal = "ffd200", easy = "40c040", trivial = "808080" })[d] or "ffd200"
end

local function RowTooltip(row)
    local g = row.group
    if not g then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(g.name, 1, 1, 1)
    if g.zone and g.zone ~= g.name then GameTooltip:AddLine(g.zone, 0.78, 0.61, 0.43) end
    if g.levelLo then GameTooltip:AddLine(format("Quests: level %d-%d", g.levelLo, g.levelHi), 0.8, 0.8, 0.8) end
    GameTooltip:AddLine(format("%d of %d steps done, %d left to do", g.done, g.steps, g.left), 0.8, 0.8, 0.8)
    if g.skipped then GameTooltip:AddLine("Skipped: the guide leaves it out (quests from it you've got still count).", 1, 0.5, 0.3, true) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Click: follow it in the guide window", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("Skip: leave the whole zone out, on all your characters", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

-- The list itself, in any parent: width wide, numRows rows tall, with its
-- filter buttons along the bottom. Returns the frame; :Reload(fresh) works
-- the zones out again, :Update() just redraws, :ToCurrent() scrolls to you.
function ns.CreateRouteList(parent, width, numRows)
    local box = CreateFrame("Frame", nil, parent)
    box:SetSize(width, numRows * ROW_H + 28)
    local rows, all, shown = {}, {}, {}
    local offset, hideDone, hideClass = 0, false, false
    local nameW = width - 64 - 60 - 5 - 44 - 44

    local function Filter()
        shown = {}
        -- by level (the default) or in route order. A section with no quests
        -- (class training, travel) takes the level of the zone before it
        local carry = 0
        for n, g in ipairs(all) do
            g.order = n
            carry = g.levelLo or carry
            g.sortLevel, g.sortHigh = carry, g.levelHi or carry
        end
        for _, g in ipairs(all) do
            local finished = g.left == 0 and not g.skipped
            if not ((hideDone and finished and not g.current) or (hideClass and g.class and not g.current)) then
                shown[#shown + 1] = g
            end
        end
        if ns.db.guideRouteSort ~= "route" then
            table.sort(shown, function(a, b)
                if a.sortLevel ~= b.sortLevel then return a.sortLevel < b.sortLevel end
                if a.sortHigh ~= b.sortHigh then return a.sortHigh < b.sortHigh end
                return a.order < b.order
            end)
        end
    end

    -- work the zones out again (walks the whole route: not on every scroll)
    function box.Reload(_, fresh)
        all = ns.GuideSectionGroups and ns.GuideSectionGroups(fresh) or {}
    end

    function box.ToCurrent()
        Filter()
        for n, g in ipairs(shown) do
            if g.current then offset = math.max(0, n - 4) return end
        end
    end

    local function Row(i)
        if rows[i] then return rows[i] end
        local r = CreateFrame("Button", nil, box, ns.BACKDROP)
        r:SetSize(width, ROW_H - 2)
        r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
        ns.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(0.78, 0.61, 0.43, 0.10)
        -- the route line down the left: a dot per zone, joined up
        r.line = r:CreateTexture(nil, "BACKGROUND")
        r.line:SetColorTexture(0.5, 0.5, 0.5, 0.5)
        r.line:SetWidth(2)
        r.line:SetPoint("TOP", r, "TOPLEFT", 10, 0)
        r.line:SetPoint("BOTTOM", r, "BOTTOMLEFT", 10, -2)
        r.dot = r:CreateTexture(nil, "ARTWORK")
        r.dot:SetSize(10, 10)
        r.dot:SetPoint("CENTER", r, "LEFT", 10, 0)
        r.level = ns.Text(r, 10)
        r.level:SetPoint("LEFT", 22, 0)
        r.level:SetWidth(40)
        r.level:SetJustifyH("LEFT")
        r.name = ns.Text(r, 11)
        r.name:SetPoint("LEFT", 64, 0)
        r.name:SetWidth(nameW)
        r.name:SetJustifyH("LEFT")
        r.name:SetWordWrap(false)
        r.bar = ns.CreateBar(r, 60, 8, { 0.35, 0.85, 0.35 })
        r.bar:SetPoint("LEFT", 64 + nameW + 4, 0)
        r.left = ns.Text(r, 9, ns.color.dim)
        r.left:SetPoint("LEFT", r.bar, "RIGHT", 5, 0)
        r.left:SetWidth(42)
        r.left:SetJustifyH("LEFT")
        r.skip = ns.CreateButton(r, "Skip", 40, 18, function(self)
            local g = self:GetParent().group
            if g and ns.GuideSkipSection then ns.GuideSkipSection(g.name, not g.skipped) end
            box:Reload(true)
            box:Update()
        end)
        r.skip.text:SetFont(ns.FONT, 9, "")
        r.skip:SetPoint("RIGHT", -2, 0)
        r:SetScript("OnEnter", RowTooltip)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        r:SetScript("OnClick", function(self)
            local g = self.group
            if not g then return end
            if not ns.db.guide then
                ns.db.guide = true
                ns.RefreshAll()
            end
            if ns.GuideFollowSection then ns.GuideFollowSection(g.name) end
            box:Reload(true)
            box:Update()
        end)
        rows[i] = r
        return r
    end

    -- draw the rows from what's worked out (cheap: scrolling and filters only do this)
    function box.Update()
        Filter()
        offset = math.max(0, math.min(offset, #shown - numRows))
        local me = UnitLevel("player")
        for i = 1, numRows do
            local r = Row(i)
            local g = shown[offset + i]
            r.group = g
            if g then
                local finished = g.left == 0
                r.level:SetText(g.levelLo and format("|cff%s%d-%d|r", LevelColour(g.levelLo), g.levelLo, g.levelHi) or "|cff999999-|r")
                local colour = g.current and "ffffff" or (g.skipped and "777777" or (finished and "6fdc6f" or "e0e0e0"))
                local tag = g.current and "  |cff33ff99< you're here|r" or (g.skipped and "  |cffff8040skipped|r" or "")
                r.name:SetText(format("|cff%s%s|r%s", colour, g.name, tag))
                r.bar.bar:SetValue(g.steps > 0 and g.done / g.steps or 0)
                r.bar:SetAlpha(g.skipped and 0.4 or 1)
                r.left:SetText(g.skipped and "" or (finished and "done" or format("%d left", g.left)))
                r.skip.text:SetText(g.skipped and "Do" or "Skip")
                r.dot:SetTexture(DOTS[g.current and "current" or (g.skipped and "skipped" or (finished and "done" or "ahead"))])
                r.line:SetShown(offset + i < #shown)
                -- zones at your level stand out
                local atLevel = g.levelLo and me >= g.levelLo - 2 and me <= g.levelHi + 1 and not finished and not g.skipped
                if g.current then
                    r:SetBackdropColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.20)
                    r:SetBackdropBorderColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.8)
                elseif atLevel then
                    r:SetBackdropColor(0.3, 0.8, 0.4, 0.08)
                    r:SetBackdropBorderColor(0, 0, 0, 0)
                else
                    r:SetBackdropColor(0, 0, 0, 0)
                    r:SetBackdropBorderColor(0, 0, 0, 0)
                end
                r:Show()
            else
                r:Hide()
            end
        end
        box.empty:SetShown(#shown == 0)
        box.scrollText:SetText(#shown > numRows
            and format("%d-%d of %d", offset + 1, math.min(#shown, offset + numRows), #shown)
            or format("%d zones", #shown))
        box.hideDone.text:SetText((hideDone and "|cff6fdc6f>|r " or "") .. "Hide done")
        box.hideClass.text:SetText((hideClass and "|cff6fdc6f>|r " or "") .. "Hide class")
        box.sort.text:SetText(ns.db.guideRouteSort == "route" and "Sort: route" or "Sort: level")
    end

    box.empty = ns.Text(box, 11, ns.color.dim)
    box.empty:SetPoint("TOPLEFT", 4, -6)
    box.empty:SetText("No route loaded yet.")
    box.hideDone = ns.CreateButton(box, "Hide done", 76, 18, function()
        hideDone = not hideDone
        box:Update()
    end)
    box.hideDone.text:SetFont(ns.FONT, 10, "")
    box.hideDone:SetPoint("BOTTOMLEFT", 0, 2)
    box.hideClass = ns.CreateButton(box, "Hide class", 76, 18, function()
        hideClass = not hideClass
        box:Update()
    end)
    box.hideClass.text:SetFont(ns.FONT, 10, "")
    box.hideClass:SetPoint("LEFT", box.hideDone, "RIGHT", 4, 0)
    local here = ns.CreateButton(box, "Where I am", 76, 18, function()
        box:ToCurrent()
        box:Update()
    end)
    here.text:SetFont(ns.FONT, 10, "")
    here:SetPoint("LEFT", box.hideClass, "RIGHT", 4, 0)
    -- by level, or in the order the route goes
    box.sort = ns.CreateButton(box, "Sort: level", 80, 18, function()
        ns.db.guideRouteSort = ns.db.guideRouteSort == "route" and "level" or "route"
        box:ToCurrent()
        box:Update()
    end)
    box.sort.text:SetFont(ns.FONT, 10, "")
    box.sort:SetPoint("LEFT", here, "RIGHT", 4, 0)
    box.sort:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Order", 1, 1, 1)
        GameTooltip:AddLine("Sort: level - lowest quests first. Sort: route - the order the guide takes you.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    box.sort:HookScript("OnLeave", function() GameTooltip:Hide() end)
    box.scrollText = ns.Text(box, 9, ns.color.dim)
    box.scrollText:SetPoint("BOTTOMRIGHT", 0, 5)

    -- its own scrolling (over the list, the wheel scrolls the zones, not the page)
    box:EnableMouseWheel(true)
    box:SetScript("OnMouseWheel", function(_, delta)
        offset = offset - delta * 3
        box:Update()
    end)
    -- fresh each time it comes into view; kept current while shown (steps get
    -- done, levels go up) - but not while you're scrolling or clicking in it
    box:SetScript("OnShow", function()
        box:Reload(true)
        box:ToCurrent()
        box:Update()
    end)
    local elapsed = 0
    box:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= 5 and not box:IsMouseOver() then
            elapsed = 0
            box:Reload()
            box:Update()
        end
    end)
    return box
end

---------------------------------------------------------------------------
-- The window (the guide's More menu, /hb guide route)
---------------------------------------------------------------------------
local frame

local function Build()
    local W, ROWS = 460, 16
    frame = CreateFrame("Frame", "HearthboundGuideRoute", UIParent, ns.BACKDROP)
    frame:SetSize(W, 72 + ROWS * ROW_H + 28)
    frame:SetPoint("CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    ns.Skin(frame, { ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], 0.97 }, ns.color.border)
    table.insert(UISpecialFrames, "HearthboundGuideRoute")
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)
    frame.title = ns.Text(frame, 12, ns.color.gold)
    frame.title:SetPoint("TOPLEFT", 10, -10)
    frame.title:SetText("Route overview")
    local close = ns.CreateButton(frame, "x", 16, 16, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -5, -5)
    local help = ns.Text(frame, 10, ns.color.dim)
    help:SetPoint("TOPLEFT", 10, -28)
    help:SetText("Click a zone to follow it in the guide. Skip leaves a whole zone out of the route.")
    frame.list = ns.CreateRouteList(frame, W - 20, ROWS)
    frame.list:SetPoint("TOPLEFT", 10, -50)
    frame:Hide()
end

function ns.ToggleGuideRoute()
    if not frame then Build() end
    frame:SetShown(not frame:IsShown())
end
