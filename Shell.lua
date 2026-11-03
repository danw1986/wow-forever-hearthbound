local ADDON_NAME, ns = ...

-- The addon's one window: a shell of columns.
--   | rail | menu | content                       |
-- The rail down the left is a fixed set of tabs (an icon and a word each).
-- Each tab opens its panel in the content column; a panel with choices of
-- its own lists them, as text, in the full-height menu column beside it.
-- Every panel gets the same header: a title and a one-line summary.
--
-- Panels register with ns.ShellSection{ ... } when their file loads:
--   key, label, icon (texture), order, bottom (sits at the foot of the rail)
--   build(parent)  - makes the panel inside parent, once, on first open
--   menu()         - the menu's lines: { header = true, label } or
--                    { label, count, selected, onClick, indent, tip, colour }
--   title(), subtitle() - the panel's header
--   onShow(sub)    - each time it's opened (sub: a part of it to go to)
-- ns.ShellOpen(key, sub), ns.ShellToggle(key, sub), ns.ShellRefresh().

local format = string.format

local RAIL_W, MENU_W = 68, 212
local HEADER_H = 76
local HEIGHT = 640
local MENU_TOP = 78     -- below the addon's name, at the top of the menu column
local MENU_LINE = 24    -- a menu entry
local MENU_HEAD = 30    -- a menu section label (with the gap above it)

local sections, byKey = {}, {}
local frame, current
local railButtons, menuLines = {}, {}

function ns.ShellSection(def)
    sections[#sections + 1] = def
    byKey[def.key] = def
    def.order = def.order or #sections
end

local function Width() return RAIL_W + MENU_W + ns.UI.width end

---------------------------------------------------------------------------
-- Building
---------------------------------------------------------------------------
local function Line(parent, layer)
    local t = parent:CreateTexture(nil, layer or "BORDER")
    t:SetColorTexture(1, 1, 1, 0.07)
    return t
end

-- a tab in the rail: an icon over its word
local function RailButton(def)
    local b = CreateFrame("Button", nil, frame)
    b:SetSize(RAIL_W, 54)
    b.bg = b:CreateTexture(nil, "BACKGROUND", nil, 2)
    b.bg:SetAllPoints()
    b.bg:SetColorTexture(1, 1, 1, 0.06)
    b.bar = b:CreateTexture(nil, "ARTWORK")
    b.bar:SetPoint("TOPLEFT", 0, 0)
    b.bar:SetPoint("BOTTOMLEFT", 0, 0)
    b.bar:SetWidth(3)
    b.bar:SetColorTexture(unpack(ns.color.gold))
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(22, 22)
    b.icon:SetPoint("TOP", 0, -8)
    b.icon:SetTexture(def.icon)
    b.label = ns.Text(b, 10)
    b.label:SetPoint("TOP", b.icon, "BOTTOM", 0, -4)
    b.label:SetText(def.label)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.04)
    b:SetScript("OnClick", function() ns.ShellOpen(def.key) end)
    b.key = def.key
    return b
end

-- a line in the menu: plain text, no button chrome
local function MenuLine(i)
    local l = menuLines[i]
    if l then return l end
    l = CreateFrame("Button", nil, frame.menuChild)
    l:SetHeight(MENU_LINE)
    l.sel = l:CreateTexture(nil, "BACKGROUND")
    l.sel:SetAllPoints()
    l.sel:SetColorTexture(1, 1, 1, 0.07)
    l.bar = l:CreateTexture(nil, "ARTWORK")
    l.bar:SetPoint("TOPLEFT", 0, 0)
    l.bar:SetPoint("BOTTOMLEFT", 0, 0)
    l.bar:SetWidth(3)
    l.bar:SetColorTexture(unpack(ns.color.gold))
    l.text = ns.Text(l, 12)
    l.text:SetJustifyH("LEFT")
    l.text:SetWordWrap(false)
    l.count = ns.Text(l, 11, ns.color.dim)
    l.count:SetPoint("RIGHT", -14, 0)
    l.count:SetJustifyH("RIGHT")
    l:SetScript("OnEnter", function(self)
        if self.item and not self.item.header then
            if not self.item.selected then self.text:SetTextColor(1, 1, 1) end
            if self.item.tip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.item.label, 1, 1, 1)
                GameTooltip:AddLine(self.item.tip, 0.8, 0.8, 0.8, true)
                GameTooltip:Show()
            end
        end
    end)
    l:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if self.item and not self.item.header and not self.item.selected then
            self.text:SetTextColor(unpack(self.item.colour or ns.color.text))
        end
    end)
    l:SetScript("OnClick", function(self)
        local item = self.item
        if item and item.onClick then
            item.onClick()
            ns.ShellRefresh()
        end
    end)
    l:EnableMouseWheel(true)
    l:SetScript("OnMouseWheel", function(_, delta) frame.menuScroll:GetScript("OnMouseWheel")(frame.menuScroll, delta) end)
    menuLines[i] = l
    return l
end

local function SavePosition()
    local p, _, rp, x, y = frame:GetPoint()
    ns.db.positions = ns.db.positions or {}
    ns.db.positions.shell = { p, rp, x, y }
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundShell", UIParent, ns.BACKDROP)
    frame:SetSize(Width(), HEIGHT)
    local pos = ns.db.positions and ns.db.positions.shell
    if pos then frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else frame:SetPoint("CENTER") end
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    ns.Skin(frame, { ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], 0.97 }, ns.color.border)
    table.insert(UISpecialFrames, "HearthboundShell") -- Escape closes it

    -- the three columns' backgrounds and the lines between them
    local rail = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    rail:SetPoint("TOPLEFT", 1, -1)
    rail:SetPoint("BOTTOMLEFT", 1, 1)
    rail:SetWidth(RAIL_W - 1)
    rail:SetColorTexture(0, 0, 0, 0.35)
    local menuBg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    menuBg:SetPoint("TOPLEFT", RAIL_W, -1)
    menuBg:SetPoint("BOTTOMLEFT", RAIL_W, 1)
    menuBg:SetWidth(MENU_W)
    menuBg:SetColorTexture(1, 1, 1, 0.025)
    local l1 = Line(frame)
    l1:SetPoint("TOPLEFT", RAIL_W, -1)
    l1:SetPoint("BOTTOMLEFT", RAIL_W, 1)
    l1:SetWidth(1)
    local l2 = Line(frame)
    l2:SetPoint("TOPLEFT", RAIL_W + MENU_W, -1)
    l2:SetPoint("BOTTOMLEFT", RAIL_W + MENU_W, 1)
    l2:SetWidth(1)
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)

    -- rail: the addon's mark, then the tabs; Settings and the like at the foot
    local logo = frame:CreateTexture(nil, "ARTWORK")
    logo:SetSize(30, 30)
    logo:SetPoint("TOP", frame, "TOPLEFT", RAIL_W / 2, -16)
    logo:SetTexture(ns.SpellIcon and ns.SpellIcon(6673) or "Interface\\Icons\\Ability_Warrior_BattleShout")
    logo:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    table.sort(sections, function(a, b) return a.order < b.order end)
    local top, bottom = -62, 8
    for _, def in ipairs(sections) do
        local b = RailButton(def)
        if def.bottom then
            b:SetPoint("BOTTOMLEFT", 0, bottom)
            bottom = bottom + 56
        else
            b:SetPoint("TOPLEFT", 0, top)
            top = top - 56
        end
        railButtons[#railButtons + 1] = b
    end

    -- menu column: the addon's name, then the panel's menu (scrolls when long)
    local name = ns.Text(frame, 18, ns.color.gold)
    name:SetPoint("TOPLEFT", RAIL_W + 18, -18)
    name:SetText("HEARTHBOUND")
    local tagline = ns.Text(frame, 10, ns.color.dim)
    tagline:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 1, -4)
    tagline:SetText("Leveling Companion")
    local menuRule = Line(frame)
    menuRule:SetPoint("TOPLEFT", RAIL_W + 1, -(MENU_TOP - 12))
    menuRule:SetSize(MENU_W - 1, 1)
    frame.menuScroll = CreateFrame("ScrollFrame", nil, frame)
    frame.menuScroll:SetPoint("TOPLEFT", RAIL_W + 1, -MENU_TOP)
    frame.menuScroll:SetPoint("BOTTOMLEFT", RAIL_W + 1, 30)
    frame.menuScroll:SetWidth(MENU_W - 1)
    frame.menuChild = CreateFrame("Frame", nil, frame.menuScroll)
    frame.menuChild:SetSize(MENU_W - 1, 10)
    frame.menuScroll:SetScrollChild(frame.menuChild)
    frame.menuScroll:EnableMouseWheel(true)
    frame.menuScroll:SetScript("OnMouseWheel", function(self, delta)
        local max = math.max(0, frame.menuChild:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(max, self:GetVerticalScroll() - delta * MENU_LINE * 3)))
    end)
    local version = ns.Text(frame, 10, ns.color.dim)
    version:SetPoint("BOTTOMLEFT", RAIL_W + 18, 11)
    version:SetText("Version " .. (ns.version or "dev") .. "   |cff777777/hb help|r")

    -- content column: the panel's header, then the panel
    local x = RAIL_W + MENU_W
    frame.title = ns.Text(frame, 22, ns.color.text)
    frame.title:SetPoint("TOPLEFT", x + 24, -18)
    frame.subtitle = ns.Text(frame, 11, ns.color.dim)
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 1, -6)
    frame.subtitle:SetWidth(ns.UI.width - 70)
    frame.subtitle:SetJustifyH("LEFT")
    frame.subtitle:SetWordWrap(false)
    local headRule = Line(frame)
    headRule:SetPoint("TOPLEFT", x + 1, -HEADER_H)
    headRule:SetPoint("TOPRIGHT", -1, -HEADER_H)
    headRule:SetHeight(1)
    local close = ns.CreateButton(frame, "x", 20, 20, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -10, -10)
    frame.contentX = x

    -- headers and counts change as you play: keep them current while open
    local elapsed = 0
    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= 2 then
            elapsed = 0
            if not frame.menuScroll:IsMouseOver() then ns.ShellRefresh() end
        end
    end)
    frame:Hide()
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------
local function DrawMenu(def)
    local items = def and def.menu and def.menu() or {}
    local y = 0
    for i, item in ipairs(items) do
        local l = MenuLine(i)
        l.item = item
        l:ClearAllPoints()
        if item.header then
            y = y + (i > 1 and 10 or 2)
            l:SetHeight(MENU_HEAD - 10)
            l:SetPoint("TOPLEFT", 0, -y)
            l:SetPoint("RIGHT", frame.menuChild, "RIGHT", 0, 0)
            l.text:ClearAllPoints()
            l.text:SetPoint("LEFT", 18, 0)
            l.text:SetPoint("RIGHT", l.count, "LEFT", -6, 0)
            l.text:SetFont(ns.FONT, 10, "")
            l.text:SetText(item.label:upper())
            l.text:SetTextColor(unpack(ns.color.gold))
            l.count:SetText(item.count and tostring(item.count) or "")
            l.sel:Hide()
            l.bar:Hide()
            l:EnableMouse(item.onClick ~= nil)
            y = y + MENU_HEAD - 10
        else
            l:SetHeight(MENU_LINE)
            l:SetPoint("TOPLEFT", 0, -y)
            l:SetPoint("RIGHT", frame.menuChild, "RIGHT", 0, 0)
            l.text:ClearAllPoints()
            l.text:SetPoint("LEFT", 18 + (item.indent or 0) * 12, 0)
            l.text:SetPoint("RIGHT", l.count, "LEFT", -6, 0)
            l.text:SetFont(ns.FONT, item.indent and item.indent > 0 and 11 or 12, "")
            l.text:SetText(item.label)
            l.text:SetTextColor(unpack(item.selected and { 1, 1, 1, 1 } or (item.colour or ns.color.text)))
            l.count:SetText(item.count and tostring(item.count) or "")
            l.sel:SetShown(item.selected and true or false)
            l.bar:SetShown(item.selected and true or false)
            l:EnableMouse(true)
            y = y + MENU_LINE
        end
        l:Show()
    end
    for i = #items + 1, #menuLines do
        menuLines[i]:Hide()
        menuLines[i].item = nil
    end
    frame.menuChild:SetHeight(math.max(10, y + 6))
    local max = math.max(0, frame.menuChild:GetHeight() - frame.menuScroll:GetHeight())
    if frame.menuScroll:GetVerticalScroll() > max then frame.menuScroll:SetVerticalScroll(max) end
end

function ns.ShellRefresh()
    if not (frame and frame:IsShown() and current) then return end
    local def = byKey[current]
    local function Get(v) if type(v) == "function" then return v() end return v end
    frame.title:SetText(Get(def.title) or def.label)
    frame.subtitle:SetText(Get(def.subtitle) or "")
    for _, b in ipairs(railButtons) do
        local on = b.key == current
        b.bg:SetShown(on)
        b.bar:SetShown(on)
        b.icon:SetDesaturated(not on)
        b.icon:SetAlpha(on and 1 or 0.65)
        b.label:SetTextColor(unpack(on and { 1, 1, 1, 1 } or ns.color.dim))
    end
    DrawMenu(def)
end

---------------------------------------------------------------------------
-- Opening
---------------------------------------------------------------------------
function ns.ShellOpen(key, sub)
    if not frame then Build() end
    local def = byKey[key] or sections[1]
    if not def then return end
    if current ~= def.key then frame.menuScroll:SetVerticalScroll(0) end
    for _, d in ipairs(sections) do
        if d.panel then d.panel:SetShown(d == def) end
    end
    current = def.key
    frame:Show()
    if not def.panel then
        def.panel = CreateFrame("Frame", nil, frame)
        def.panel:SetPoint("TOPLEFT", frame.contentX + 1, -(HEADER_H + 1))
        def.panel:SetPoint("BOTTOMRIGHT", -1, 1)
        -- built hidden, so its OnShow (the panels refresh in it) fires when it's shown
        def.panel:Hide()
        if def.build then def.build(def.panel) end
    end
    def.panel:Show()
    if ns.db then ns.db.shellLast = def.key end
    if def.onShow then def.onShow(sub) end
    ns.ShellRefresh()
end

function ns.ShellToggle(key, sub)
    if frame and frame:IsShown() and current == key and not sub then
        frame:Hide()
        return
    end
    ns.ShellOpen(key, sub)
end

function ns.ShellCurrent() return frame and frame:IsShown() and current or nil end
function ns.ShellPanel(key) return byKey[key] and byKey[key].panel end
