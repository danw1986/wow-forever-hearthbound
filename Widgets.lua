local ADDON_NAME, ns = ...

local format = string.format

local WHITE = "Interface\\Buttons\\WHITE8X8"
local MEDIA = "Interface\\AddOns\\Hearthbound\\Media\\"
local GAME_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

ns.WHITE = WHITE
ns.MEDIA = MEDIA
ns.BAR = MEDIA .. "Bar"   -- status bar fill: lit at the top, a little darker at the foot
ns.SOFT = MEDIA .. "Soft" -- a soft round blob, sliced up for shadows and glows
ns.FONT = GAME_FONT       -- body text (ns.ApplyFont may swap these for the modern font)
ns.FONT_BOLD = GAME_FONT  -- titles, headings and values
ns.FONT_BUMP = 0          -- added to every size: the modern font is narrower, so it goes up one
ns.BACKDROP = BackdropTemplateMixin and "BackdropTemplate" or nil

-- Settings window layout, shared by every tab
ns.UI = { width = 700, pad = 22, gap = 24 } -- the shell's content column (Shell.lua)
ns.UI.colW = math.floor((ns.UI.width - ns.UI.pad * 2 - ns.UI.gap) / 2) -- two-column tabs
ns.UI.col2X = ns.UI.pad + ns.UI.colW + ns.UI.gap

ns.color = {
    bg      = { 0.045, 0.048, 0.056, 0.92 },
    panel   = { 0.12, 0.125, 0.14, 1 },
    border  = { 1, 1, 1, 0.09 },    -- a hairline: the glass's edge
    button  = { 1, 1, 1, 0.05 },
    well    = { 0, 0, 0, 0.35 },    -- inputs, check boxes and bar tracks sit in a darker well
    accent  = { 0.86, 0.24, 0.16, 1 }, -- rage red
    gold    = { 0.84, 0.67, 0.47, 1 }, -- warrior class colour
    text    = { 0.93, 0.93, 0.94, 1 },
    label   = { 0.84, 0.85, 0.87, 1 }, -- button words (white when the mouse is over)
    dim     = { 0.60, 0.62, 0.66, 1 },
}

---------------------------------------------------------------------------
-- The font: Barlow (Media/Fonts, SIL Open Font License) for languages written
-- in Latin letters, the game's own font for the rest or when switched off.
-- Applied when the addon loads, before any frame is built (so a change needs
-- a /reload, like the theme).
---------------------------------------------------------------------------
local LATIN = { enUS = true, enGB = true, deDE = true, frFR = true, esES = true, esMX = true, itIT = true,
                ptBR = true, ptPT = true }

function ns.ApplyFont(modern)
    ns.FONT, ns.FONT_BOLD, ns.FONT_BUMP = GAME_FONT, GAME_FONT, 0
    if not modern or not LATIN[GetLocale and GetLocale() or "enUS"] then return end
    local body, bold = MEDIA .. "Fonts\\Barlow-Medium.ttf", MEDIA .. "Fonts\\Barlow-SemiBold.ttf"
    -- a client that can't load it says so (SetFont returns false): keep the game's font then
    local probe = UIParent and UIParent:CreateFontString(nil, "OVERLAY")
    if probe and probe:SetFont(body, 12, "") == false then return end
    ns.FONT, ns.FONT_BOLD, ns.FONT_BUMP = body, bold, 1
end

-- every font in the addon is set through here: bold for titles, headings and values
function ns.SetFont(fs, size, flags, bold)
    fs:SetFont(bold and ns.FONT_BOLD or ns.FONT, (size or 12) + ns.FONT_BUMP, flags or "")
end

-- fades a texture (or frame) to an alpha over a moment: buttons' hover washes
local fading, fader = {}, nil
function ns.FadeTo(region, alpha, seconds)
    if not region then return end
    fading[region] = { alpha, (seconds or 0.15) }
    if not fader then
        fader = CreateFrame("Frame")
        fader:SetScript("OnUpdate", function(self, dt)
            local any = false
            for r, f in pairs(fading) do
                local now = r:GetAlpha() or 0
                local step = dt / math.max(0.01, f[2])
                local nextA = now < f[1] and math.min(f[1], now + step) or math.max(f[1], now - step)
                r:SetAlpha(nextA)
                if nextA == f[1] then fading[r] = nil else any = true end
            end
            if not any then self:Hide() end
        end)
    end
    fader:Show()
end

-- a two-colour gradient on a texture: VERTICAL runs from a (bottom) to b (top),
-- HORIZONTAL from a (left) to b (right)
function ns.Gradient(tex, orient, a, b)
    tex:SetTexture(WHITE)
    if CreateColor and tex.SetGradient then
        local ok = pcall(tex.SetGradient, tex, orient, CreateColor(a[1], a[2], a[3], a[4] or 1),
            CreateColor(b[1], b[2], b[3], b[4] or 1))
        if ok then return tex end
    end
    if tex.SetGradientAlpha then
        tex:SetGradientAlpha(orient, a[1], a[2], a[3], a[4] or 1, b[1], b[2], b[3], b[4] or 1)
    end
    return tex
end
local Gradient = ns.Gradient

local function Tint(c, alpha) return { c[1], c[2], c[3], alpha } end
ns.Tint = Tint
local SOUND_CLICK = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856

---------------------------------------------------------------------------
-- Colour themes: applied when the addon loads (changing one needs a /reload,
-- as every frame is coloured when it's built)
---------------------------------------------------------------------------
ns.THEMES = {
    { key = "warrior", label = "Hearthbound", accent = { 0.86, 0.24, 0.16, 1 }, gold = { 0.84, 0.67, 0.47, 1 },
      bg = { 0.045, 0.048, 0.056, 0.92 }, panel = { 0.12, 0.125, 0.14, 1 } },
    { key = "slate", label = "Slate", accent = { 0.27, 0.58, 0.90, 1 }, gold = { 0.66, 0.78, 0.90, 1 },
      bg = { 0.035, 0.05, 0.075, 0.92 }, panel = { 0.10, 0.13, 0.17, 1 } },
    { key = "midnight", label = "Midnight", accent = { 0.60, 0.36, 0.92, 1 }, gold = { 0.80, 0.69, 0.96, 1 },
      bg = { 0.045, 0.035, 0.07, 0.92 }, panel = { 0.12, 0.09, 0.16, 1 } },
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
    if not texture or (ns.IsSecret and ns.IsSecret(texture)) then return "" end
    if type(size) ~= "number" or size < 6 or size > 64 then size = 14 end
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

---------------------------------------------------------------------------
-- Glass: the look of every Hearthbound window
---------------------------------------------------------------------------
-- a soft shadow around a frame, sliced from the Soft blob: corners from its
-- quarters, edges from its middle row and column
function ns.Shadow(f, size, alpha)
    if f.hbShadow then return end
    size, alpha = size or 14, alpha or 0.55
    local pieces = {}
    local function Piece(l, r, t, b)
        local tx = f:CreateTexture(nil, "BACKGROUND", nil, -8)
        tx:SetTexture(ns.SOFT)
        tx:SetTexCoord(l, r, t, b)
        tx:SetVertexColor(0, 0, 0, alpha)
        pieces[#pieces + 1] = tx
        return tx
    end
    local m1, m2 = 0.49, 0.51
    local tl = Piece(0, 0.5, 0, 0.5)
    tl:SetSize(size, size)
    tl:SetPoint("BOTTOMRIGHT", f, "TOPLEFT")
    local tr = Piece(0.5, 1, 0, 0.5)
    tr:SetSize(size, size)
    tr:SetPoint("BOTTOMLEFT", f, "TOPRIGHT")
    local bl = Piece(0, 0.5, 0.5, 1)
    bl:SetSize(size, size)
    bl:SetPoint("TOPRIGHT", f, "BOTTOMLEFT")
    local br = Piece(0.5, 1, 0.5, 1)
    br:SetSize(size, size)
    br:SetPoint("TOPLEFT", f, "BOTTOMRIGHT")
    local top = Piece(m1, m2, 0, 0.5)
    top:SetPoint("BOTTOMLEFT", tl, "BOTTOMRIGHT")
    top:SetPoint("TOPRIGHT", tr, "TOPLEFT")
    local bottom = Piece(m1, m2, 0.5, 1)
    bottom:SetPoint("TOPLEFT", bl, "TOPRIGHT")
    bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT")
    local left = Piece(0, 0.5, m1, m2)
    left:SetPoint("TOPRIGHT", tl, "BOTTOMRIGHT")
    left:SetPoint("BOTTOMLEFT", bl, "TOPLEFT")
    local right = Piece(0.5, 1, m1, m2)
    right:SetPoint("TOPLEFT", tr, "BOTTOMLEFT")
    right:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
    f.hbShadow = pieces
end

-- a line of colour across the top of a frame, brightest in the middle, with a
-- faint glow of it falling down into the frame
function ns.AccentLine(f, colour, height)
    local c = colour or ns.color.accent
    local left = Gradient(f:CreateTexture(nil, "ARTWORK", nil, 7), "HORIZONTAL", Tint(c, 0.25), Tint(c, 1))
    left:SetPoint("TOPLEFT", 1, -1)
    left:SetPoint("TOPRIGHT", f, "TOP", 0, -1)
    left:SetHeight(height or 2)
    local right = Gradient(f:CreateTexture(nil, "ARTWORK", nil, 7), "HORIZONTAL", Tint(c, 1), Tint(c, 0.25))
    right:SetPoint("TOPLEFT", f, "TOP", 0, -1)
    right:SetPoint("TOPRIGHT", -1, -1)
    right:SetHeight(height or 2)
    local glow = Gradient(f:CreateTexture(nil, "BACKGROUND", nil, 6), "VERTICAL", Tint(c, 0), Tint(c, 0.10))
    glow:SetPoint("TOPLEFT", 1, -1)
    glow:SetPoint("TOPRIGHT", -1, -1)
    glow:SetHeight(26)
    return left, right, glow
end

-- a window: the backdrop (bg, or the theme's), a hairline edge, a sheen down
-- from the lit top edge, the accent line (opts.line: another colour, or false
-- for none) and a soft shadow outside
function ns.Window(f, bg, opts)
    opts = opts or {}
    ns.Skin(f, bg or ns.color.bg, opts.border or ns.color.border)
    if f.hbGlass then return f end
    f.hbGlass = true
    local sheen = Gradient(f:CreateTexture(nil, "BACKGROUND", nil, 7), "VERTICAL", { 1, 1, 1, 0 }, { 1, 1, 1, 0.045 })
    sheen:SetPoint("TOPLEFT", 1, -1)
    sheen:SetPoint("TOPRIGHT", -1, -1)
    sheen:SetHeight(opts.sheen or 90)
    local lit = f:CreateTexture(nil, "BORDER", nil, 7)
    lit:SetColorTexture(1, 1, 1, 0.10)
    lit:SetPoint("TOPLEFT", 1, -1)
    lit:SetPoint("TOPRIGHT", -1, -1)
    lit:SetHeight(1)
    if opts.line ~= false then ns.AccentLine(f, opts.line, opts.lineHeight) end
    if opts.shadow ~= false then ns.Shadow(f) end
    return f
end

-- bold: the semi-bold weight (titles, headings, values)
function ns.Text(parent, size, color, flags, layer, bold)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    ns.SetFont(fs, size, flags, bold)
    fs:SetTextColor(unpack(color or ns.color.text))
    if not flags or flags == "" then
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 0.75)
    end
    return fs
end

-- Square icon with a 1px border; returns frame with .icon
function ns.CreateIcon(parent, size)
    local f = CreateFrame("Frame", nil, parent, ns.BACKDROP)
    f:SetSize(size, size)
    ns.Skin(f, { 0, 0, 0, 1 }, { 0, 0, 0, 1 })
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
    ns.Skin(holder, ns.color.well, { 0, 0, 0, 0.8 })

    local bar = CreateFrame("StatusBar", nil, holder)
    bar:SetPoint("TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", -1, 1)
    bar:SetStatusBarTexture(ns.BAR)
    bar:SetStatusBarColor(unpack(color or ns.color.gold))
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    holder.bar = bar

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

-- a section heading: small semi-bold capitals with a rule after them that fades
-- out - the same in every panel (Lines.lua's headings and the shell's menu match it)
function ns.HeaderRule(tex, colour)
    local c = colour or ns.color.gold
    return Gradient(tex, "HORIZONTAL", Tint(c, 0.35), Tint(c, 0))
end

function ns.CreateHeader(parent, text, width)
    local fs = ns.Text(parent, 10, ns.color.gold, nil, nil, true)
    fs:SetText(ns.HeadingIcon(text) .. text:upper()) -- the icon after the capitals: |t must stay lower case
    local line = ns.HeaderRule(parent:CreateTexture(nil, "ARTWORK"))
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 8, 0)
    line:SetWidth(math.max(10, width - fs:GetStringWidth() - 8))
    return fs
end

function ns.CreateCheck(parent, label, tip, getter, setter)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(200, 20)

    local box = CreateFrame("Frame", nil, b, ns.BACKDROP)
    box:SetSize(15, 15)
    box:SetPoint("LEFT")
    ns.Skin(box, ns.color.well, { 1, 1, 1, 0.18 })

    local fill = box:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    fill:SetTexture(ns.BAR)
    fill:SetVertexColor(unpack(ns.color.accent))

    local text = ns.Text(b, 12)
    text:SetPoint("LEFT", box, "RIGHT", 8, 0)
    text:SetText(label)

    local function Edge(hover)
        local on = getter() and true or false
        if hover or on then
            box:SetBackdropBorderColor(unpack(Tint(ns.color.accent, hover and 1 or 0.7)))
        else
            box:SetBackdropBorderColor(1, 1, 1, 0.18)
        end
    end
    b:SetScript("OnEnter", function()
        Edge(true)
        text:SetTextColor(1, 1, 1)
    end)
    b:SetScript("OnLeave", function()
        Edge(false)
        text:SetTextColor(unpack(ns.color.text))
    end)
    AttachTooltip(b, label, tip)

    function b.Refresh()
        fill:SetShown(getter() and true or false)
        Edge(b:IsMouseOver())
    end
    b:SetScript("OnClick", function()
        setter(not getter())
        b.Refresh()
        ns.PlaySound(SOUND_CLICK)
    end)
    b.Refresh()
    return b
end

-- a button: a faint pane with a hairline edge; the accent washes up through it
-- when the mouse is over it, and stays on a selected one (tabs, filters).
-- "x" makes a close button: no pane until the mouse is over it
function ns.CreateButton(parent, label, width, height, onClick)
    local b = CreateFrame("Button", nil, parent, ns.BACKDROP)
    b:SetSize(width, height)
    local ghost = label == "x"
    if ghost and ns.FONT_BUMP > 0 then label = "×" end
    local restBg = ghost and { 0, 0, 0, 0 } or ns.color.button
    local restEdge = ghost and { 0, 0, 0, 0 } or ns.color.border
    ns.Skin(b, restBg, restEdge)
    b.wash = Gradient(b:CreateTexture(nil, "BACKGROUND", nil, 7), "VERTICAL",
        Tint(ns.color.accent, 0.08), Tint(ns.color.accent, 0.30))
    b.wash:SetPoint("TOPLEFT", 1, -1)
    b.wash:SetPoint("BOTTOMRIGHT", -1, 1)
    b.wash:SetAlpha(0)
    b.text = ns.Text(b, ghost and 13 or 12, ns.color.label)
    b.text:SetPoint("CENTER")
    b.text:SetText(label)
    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(Tint(ns.color.accent, 0.9)))
        self.text:SetTextColor(1, 1, 1)
        ns.FadeTo(self.wash, 1, 0.12)
    end)
    b:SetScript("OnLeave", function(self)
        if self.selected then
            self:SetBackdropBorderColor(unpack(Tint(ns.color.accent, 0.75)))
            self.text:SetTextColor(1, 1, 1)
            ns.FadeTo(self.wash, 0.7, 0.2)
        else
            self:SetBackdropBorderColor(unpack(restEdge))
            self.text:SetTextColor(unpack(ns.color.label))
            ns.FadeTo(self.wash, 0, 0.2)
        end
    end)
    b:SetScript("OnMouseDown", function(self) self.text:SetPoint("CENTER", 0, -1) end)
    b:SetScript("OnMouseUp", function(self) self.text:SetPoint("CENTER") end)
    b:SetScript("OnClick", function(self)
        ns.PlaySound(SOUND_CLICK)
        onClick(self)
    end)
    -- selected buttons (tabs, filters) keep the accent
    function b.SetSelected(_, selected)
        b.selected = selected
        b:GetScript("OnLeave")(b)
    end
    return b
end

function ns.CreateEditBox(parent, width, height, placeholder)
    local eb = CreateFrame("EditBox", nil, parent, ns.BACKDROP)
    eb:SetSize(width, height)
    ns.Skin(eb, ns.color.well, ns.color.border)
    ns.SetFont(eb, 12)
    eb:SetTextColor(unpack(ns.color.text))
    eb:SetTextInsets(8, 8, 0, 0)
    eb:SetAutoFocus(false)
    local hint = ns.Text(eb, 12, ns.color.dim)
    hint:SetPoint("LEFT", 8, 0)
    hint:SetText(placeholder or "")
    eb:SetScript("OnEscapePressed", eb.ClearFocus)
    eb:SetScript("OnEnterPressed", eb.ClearFocus)
    eb:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(ns.color.accent)) end)
    eb:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(ns.color.border)) end)
    eb:HookScript("OnTextChanged", function(self)
        hint:SetShown(self:GetText() == "")
    end)
    return eb
end

-- a slider: a thin track, filled with the accent up to a light thumb
function ns.CreateSlider(parent, label, tip, minV, maxV, step, fmt, getter, setter)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 36)

    local title = ns.Text(f, 12)
    title:SetPoint("TOPLEFT")
    title:SetText(label)
    local value = ns.Text(f, 12, ns.color.gold, nil, nil, true)
    value:SetPoint("TOPRIGHT")

    local s = CreateFrame("Slider", nil, f)
    s:SetPoint("TOPLEFT", 0, -18)
    s:SetPoint("TOPRIGHT", 0, -18)
    s:SetHeight(14)
    s:SetOrientation("HORIZONTAL")
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    s:EnableMouse(true)
    s:EnableMouseWheel(true)

    local track = s:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(1, 1, 1, 0.10)
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(4)

    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(0.95, 0.95, 0.97, 1)
    thumb:SetSize(6, 14)
    s:SetThumbTexture(thumb)

    local fill = Gradient(s:CreateTexture(nil, "ARTWORK"), "HORIZONTAL", Tint(ns.color.accent, 0.55), Tint(ns.color.accent, 1))
    fill:SetPoint("LEFT", track, "LEFT")
    fill:SetPoint("RIGHT", thumb, "CENTER")
    fill:SetHeight(4)

    local function Round(v) return math.floor(v / step + 0.5) * step end

    s:SetScript("OnValueChanged", function(_, v)
        v = Round(v)
        value:SetText(string.format(fmt, v))
        if not f.updating then setter(v) end
    end)
    s:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(math.min(maxV, math.max(minV, self:GetValue() + delta * step)))
    end)
    s:SetScript("OnEnter", function() thumb:SetColorTexture(1, 1, 1, 1) end)
    s:SetScript("OnLeave", function() thumb:SetColorTexture(0.95, 0.95, 0.97, 1) end)
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
