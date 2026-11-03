local ADDON_NAME, ns = ...

local format = string.format

local WHITE = "Interface\\Buttons\\WHITE8X8"
local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

ns.WHITE = WHITE
ns.FONT = FONT
ns.BACKDROP = BackdropTemplateMixin and "BackdropTemplate" or nil

-- Settings window layout, shared by every tab
ns.UI = { width = 640, pad = 22, gap = 24 }
ns.UI.colW = math.floor((ns.UI.width - ns.UI.pad * 2 - ns.UI.gap) / 2) -- two-column tabs
ns.UI.col2X = ns.UI.pad + ns.UI.colW + ns.UI.gap

ns.color = {
    bg      = { 0.05, 0.05, 0.06, 0.92 },
    panel   = { 0.13, 0.13, 0.15, 1 },
    border  = { 0, 0, 0, 1 },
    accent  = { 0.80, 0.18, 0.12, 1 }, -- rage red
    gold    = { 0.78, 0.61, 0.43, 1 }, -- warrior class colour
    text    = { 0.92, 0.92, 0.92, 1 },
    dim     = { 0.58, 0.58, 0.60, 1 },
}

local SOUND_CLICK = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856

---------------------------------------------------------------------------
-- Colour themes: applied when the addon loads (changing one needs a /reload,
-- as every frame is coloured when it's built)
---------------------------------------------------------------------------
ns.THEMES = {
    { key = "warrior", label = "Warrior", accent = { 0.80, 0.18, 0.12, 1 }, gold = { 0.78, 0.61, 0.43, 1 },
      bg = { 0.05, 0.05, 0.06, 0.92 }, panel = { 0.13, 0.13, 0.15, 1 } },
    { key = "slate", label = "Slate", accent = { 0.25, 0.55, 0.85, 1 }, gold = { 0.62, 0.74, 0.86, 1 },
      bg = { 0.04, 0.06, 0.09, 0.92 }, panel = { 0.10, 0.13, 0.17, 1 } },
    { key = "midnight", label = "Midnight", accent = { 0.55, 0.30, 0.85, 1 }, gold = { 0.78, 0.66, 0.95, 1 },
      bg = { 0.05, 0.03, 0.08, 0.92 }, panel = { 0.12, 0.09, 0.16, 1 } },
    { key = "class", label = "Class colour" },
}

local function Copy(into, from)
    for i = 1, 4 do into[i] = from[i] end
end

function ns.ApplyTheme(key)
    local theme
    for _, t in ipairs(ns.THEMES) do if t.key == key then theme = t end end
    theme = theme or ns.THEMES[1]
    local warrior = ns.THEMES[1]
    if theme.key == "class" then
        local _, class = UnitClass("player")
        local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if c then
            Copy(ns.color.accent, { c.r * 0.85, c.g * 0.85, c.b * 0.85, 1 })
            Copy(ns.color.gold, { c.r + (1 - c.r) * 0.3, c.g + (1 - c.g) * 0.3, c.b + (1 - c.b) * 0.3, 1 })
        end
        Copy(ns.color.bg, warrior.bg)
        Copy(ns.color.panel, warrior.panel)
        return
    end
    Copy(ns.color.accent, theme.accent)
    Copy(ns.color.gold, theme.gold)
    Copy(ns.color.bg, theme.bg)
    Copy(ns.color.panel, theme.panel)
end

---------------------------------------------------------------------------
-- Heading icons: every section heading gets a small icon, matched by how
-- its text starts (headings like "Road to 60" or "Slayer 3/34" still match)
---------------------------------------------------------------------------
local I = "Interface\\Icons\\"
local HEADING_ICONS = {
    { "trainer", I .. "INV_Misc_Book_11" },
    { "guide", I .. "INV_Misc_Map_01" },
    { "levelling guide", I .. "INV_Misc_Map_01" },
    { "left behind", I .. "INV_Misc_Note_02" },
    { "class quests", I .. "INV_Sword_27" },
    { "coming up", I .. "INV_Misc_PocketWatch_01" },
    { "road to", I .. "Ability_Mount_RidingHorse" },
    { "best xp quests", I .. "INV_Misc_Gem_Pearl_04" },
    { "quest log", I .. "INV_Misc_Book_08" },
    { "objectives nearby", I .. "Ability_Hunter_SniperShot" },
    { "where next", I .. "INV_Misc_Map02" },
    { "dungeons", I .. "INV_Misc_Key_14" },
    { "grind", I .. "Ability_Warrior_Rampage" },
    { "gold", I .. "INV_Misc_Coin_02" },
    { "gear", I .. "Trade_BlackSmithing" },
    { "weapon skill", I .. "INV_Sword_04" },
    { "supplies", I .. "INV_Misc_Food_15" },
    { "travel", I .. "INV_Misc_Rune_01" },
    { "session goal", I .. "INV_Misc_Note_02" },
    { "level history", I .. "INV_Misc_PocketWatch_02" },
    { "this session", I .. "Spell_Nature_TimeStop" },
    { "xp sources", I .. "INV_Misc_Gem_Pearl_04" },
    { "milestones", I .. "INV_Misc_Note_02" },
    { "deaths", I .. "INV_Misc_Bone_HumanSkull_01" },
    { "most deadly", I .. "INV_Misc_Bone_HumanSkull_01" },
    { "screenshots", I .. "INV_Misc_Spyglass_02" },
    { "kill record", I .. "INV_Sword_04" },
    { "most killed", I .. "INV_Sword_04" },
    { "by rank", I .. "Ability_Warrior_BattleShout" },
    { "bosses", I .. "INV_Misc_Bone_ElfSkull_01" },
    { "slayer", I .. "Ability_Warrior_DecisiveStrike" },
    { "your achievements", I .. "INV_Misc_Gem_Diamond_01" },
    { "closest to unlocking", I .. "Spell_Holy_HolyBolt" },
    { "recently unlocked", I .. "INV_Misc_Note_01" },
    { "panel sections", I .. "INV_Misc_Note_01" },
    { "questing", I .. "INV_Misc_Book_08" },
    { "experience", I .. "INV_Misc_Coin_02" },
    { "layout", I .. "INV_Misc_Spyglass_02" },
    { "companion", I .. "Ability_Warrior_BattleShout" },
}

-- an inline icon for a texture, cropped like the game's own buttons
function ns.InlineIcon(texture, size)
    if not texture then return "" end
    size = size or 14
    return format("|T%s:%d:%d:0:0:64:64:5:59:5:59|t ", texture, size, size)
end

-- the icon for a heading, or "" when it has none
function ns.HeadingIcon(text, explicit)
    if explicit then return ns.InlineIcon(explicit) end
    local lower = (text or ""):lower()
    for _, entry in ipairs(HEADING_ICONS) do
        if lower:sub(1, #entry[1]) == entry[1] then return ns.InlineIcon(entry[2]) end
    end
    return ""
end

function ns.Skin(f, bg, border)
    f:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    f:SetBackdropColor(unpack(bg or ns.color.bg))
    f:SetBackdropBorderColor(unpack(border or ns.color.border))
end

function ns.Text(parent, size, color, flags, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(FONT, size or 12, flags or "")
    fs:SetTextColor(unpack(color or ns.color.text))
    if not flags or flags == "" then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 0.9)
    end
    return fs
end

-- Square icon with a 1px border; returns frame with .icon
function ns.CreateIcon(parent, size)
    local f = CreateFrame("Frame", nil, parent, ns.BACKDROP)
    f:SetSize(size, size)
    ns.Skin(f, { 0, 0, 0, 1 }, ns.color.border)
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon = icon
    return f
end

-- Bordered status bar; returns holder with .bar, .left, .right
function ns.CreateBar(parent, width, height, color)
    local holder = CreateFrame("Frame", nil, parent, ns.BACKDROP)
    holder:SetSize(width, height)
    ns.Skin(holder, { 0.08, 0.08, 0.09, 0.9 }, ns.color.border)

    local bar = CreateFrame("StatusBar", nil, holder)
    bar:SetPoint("TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", -1, 1)
    bar:SetStatusBarTexture(WHITE)
    bar:SetStatusBarColor(unpack(color or ns.color.gold))
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    holder.bar = bar

    -- subtle top highlight for depth
    local shine = bar:CreateTexture(nil, "OVERLAY")
    shine:SetPoint("TOPLEFT")
    shine:SetPoint("TOPRIGHT")
    shine:SetHeight(math.max(1, math.floor(height / 2.5)))
    shine:SetColorTexture(1, 1, 1, 0.08)

    local textSize = math.max(9, math.min(12, height - 2))
    holder.left = ns.Text(bar, textSize, ns.color.text, "OUTLINE")
    holder.left:SetPoint("LEFT", 4, 0)
    holder.right = ns.Text(bar, textSize, ns.color.text, "OUTLINE")
    holder.right:SetPoint("RIGHT", -4, 0)
    return holder
end

local function AttachTooltip(f, title, tip)
    if not tip then return end
    f:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1)
        GameTooltip:AddLine(tip, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    f:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

function ns.CreateHeader(parent, text, width)
    local fs = ns.Text(parent, 11, ns.color.gold)
    fs:SetText(ns.HeadingIcon(text) .. text:upper()) -- the icon after the capitals: |t must stay lower case
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.78, 0.61, 0.43, 0.3)
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 8, 0)
    line:SetWidth(math.max(10, width - fs:GetStringWidth() - 8))
    return fs
end

function ns.CreateCheck(parent, label, tip, getter, setter)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(200, 20)

    local box = CreateFrame("Frame", nil, b, ns.BACKDROP)
    box:SetSize(16, 16)
    box:SetPoint("LEFT")
    ns.Skin(box, ns.color.panel, ns.color.border)

    local fill = box:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    fill:SetColorTexture(unpack(ns.color.accent))

    local text = ns.Text(b, 12)
    text:SetPoint("LEFT", box, "RIGHT", 8, 0)
    text:SetText(label)

    b:SetScript("OnEnter", function()
        box:SetBackdropBorderColor(unpack(ns.color.gold))
        text:SetTextColor(1, 1, 1)
    end)
    b:SetScript("OnLeave", function()
        box:SetBackdropBorderColor(unpack(ns.color.border))
        text:SetTextColor(unpack(ns.color.text))
    end)
    AttachTooltip(b, label, tip)

    function b.Refresh()
        fill:SetShown(getter() and true or false)
    end
    b:SetScript("OnClick", function()
        setter(not getter())
        b.Refresh()
        ns.PlaySound(SOUND_CLICK)
    end)
    b.Refresh()
    return b
end

function ns.CreateButton(parent, label, width, height, onClick)
    local b = CreateFrame("Button", nil, parent, ns.BACKDROP)
    b:SetSize(width, height)
    ns.Skin(b, ns.color.panel, ns.color.border)
    b.text = ns.Text(b, 12, ns.color.gold)
    b.text:SetPoint("CENTER")
    b.text:SetText(label)
    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ns.color.accent))
        self.text:SetTextColor(1, 1, 1)
    end)
    b:SetScript("OnLeave", function(self)
        if self.selected then
            self:SetBackdropBorderColor(unpack(ns.color.accent))
            self.text:SetTextColor(1, 1, 1)
        else
            self:SetBackdropBorderColor(unpack(ns.color.border))
            self.text:SetTextColor(unpack(ns.color.gold))
        end
    end)
    b:SetScript("OnMouseDown", function(self) self.text:SetPoint("CENTER", 1, -1) end)
    b:SetScript("OnMouseUp", function(self) self.text:SetPoint("CENTER") end)
    b:SetScript("OnClick", function(self)
        ns.PlaySound(SOUND_CLICK)
        onClick(self)
    end)
    -- selected buttons (tabs, filters) keep the accent border
    function b.SetSelected(_, selected)
        b.selected = selected
        b:GetScript("OnLeave")(b)
    end
    return b
end

function ns.CreateEditBox(parent, width, height, placeholder)
    local eb = CreateFrame("EditBox", nil, parent, ns.BACKDROP)
    eb:SetSize(width, height)
    ns.Skin(eb, ns.color.panel, ns.color.border)
    eb:SetFont(FONT, 12, "")
    eb:SetTextColor(unpack(ns.color.text))
    eb:SetTextInsets(8, 8, 0, 0)
    eb:SetAutoFocus(false)
    local hint = ns.Text(eb, 12, ns.color.dim)
    hint:SetPoint("LEFT", 8, 0)
    hint:SetText(placeholder or "")
    eb:SetScript("OnEscapePressed", eb.ClearFocus)
    eb:SetScript("OnEnterPressed", eb.ClearFocus)
    eb:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(ns.color.gold)) end)
    eb:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(ns.color.border)) end)
    eb:HookScript("OnTextChanged", function(self)
        hint:SetShown(self:GetText() == "")
    end)
    return eb
end

function ns.CreateSlider(parent, label, tip, minV, maxV, step, fmt, getter, setter)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 36)

    local title = ns.Text(f, 12)
    title:SetPoint("TOPLEFT")
    title:SetText(label)
    local value = ns.Text(f, 12, ns.color.gold)
    value:SetPoint("TOPRIGHT")

    local s = CreateFrame("Slider", nil, f, ns.BACKDROP)
    s:SetPoint("TOPLEFT", 0, -20)
    s:SetPoint("TOPRIGHT", 0, -20)
    s:SetHeight(10)
    ns.Skin(s, ns.color.panel, ns.color.border)
    s:SetOrientation("HORIZONTAL")
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    s:EnableMouse(true)
    s:EnableMouseWheel(true)

    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ns.color.gold))
    thumb:SetSize(8, 14)
    s:SetThumbTexture(thumb)

    local fill = s:CreateTexture(nil, "ARTWORK")
    fill:SetColorTexture(unpack(ns.color.accent))
    fill:SetPoint("TOPLEFT", 1, -1)
    fill:SetPoint("BOTTOMLEFT", 1, 1)
    fill:SetPoint("RIGHT", thumb, "CENTER")

    local function Round(v) return math.floor(v / step + 0.5) * step end

    s:SetScript("OnValueChanged", function(_, v)
        v = Round(v)
        value:SetText(string.format(fmt, v))
        if not f.updating then setter(v) end
    end)
    s:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(math.min(maxV, math.max(minV, self:GetValue() + delta * step)))
    end)
    AttachTooltip(s, label, tip)

    function f.Refresh()
        f.updating = true
        s:SetValue(getter())
        value:SetText(string.format(fmt, getter()))
        f.updating = false
    end
    f.Refresh()
    return f
end
