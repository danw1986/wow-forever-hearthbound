local ADDON_NAME, ns = ...

-- Enemy nameplates, drawn to match the game's own:
--   the health bar (tinted with your threat, if you like - off by default)
--   a thin threat line along the top of the bar, softly glowing, in combat:
--     red    - you have it (tanking it securely)
--     yellow - you're losing it, or about to pull it off whoever has it (it pulses)
--     green  - it's on someone else and you're well below them
--   your debuffs on it, in a row above the name, each with its time left
-- Above the bar, so the game's own highlight on the target you've selected
-- doesn't hide it. Settings > Look & layout > Enemy nameplates.

local Safe = ns.Safe
local format = string.format
local WHITE = "Interface\\Buttons\\WHITE8X8"

-- (close to the game's own reaction colours, so they sit well on its plates)
local COLOURS = {
    [3] = { 0.95, 0.22, 0.16 }, -- aggro
    [2] = { 1.00, 0.78, 0.20 }, -- losing it
    [1] = { 1.00, 0.78, 0.20 }, -- about to pull it
    [0] = { 0.35, 0.88, 0.42 }, -- no aggro
}
local STRIP_H = 2      -- the threat line along the top of the health bar
local GLOW = 4         -- its soft glow, above it
local ICON_W, ICON_H = 18, 12 -- a debuff icon: wide and short, like the game's
local MAX_DEBUFFS = 6
local TICK = 0.25      -- seconds between threat checks in combat

local function On(key) return ns.db and ns.db[key] ~= false end

-- a texture fading from alpha a1 to a2 (the newer and the older client API)
local function Fade(tex, orientation, r, g, b, a1, a2)
    if CreateColor and pcall(tex.SetGradient, tex, orientation, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2)) then return end
    if tex.SetGradientAlpha then pcall(tex.SetGradientAlpha, tex, orientation, r, g, b, a1, r, g, b, a2) end
end

local function HealthBar(plate)
    local uf = plate and plate.UnitFrame
    return uf and (uf.healthBar or uf.HealthBar)
end

-- what sits on top of the bar: the name, if the plate shows one
local function Top(plate)
    local uf = plate.UnitFrame
    local name = uf and (uf.name or uf.Name)
    if name and name.IsShown and name:IsShown() then return name end
    return HealthBar(plate) or plate
end

---------------------------------------------------------------------------
-- The threat strip
---------------------------------------------------------------------------
-- the font the plate's name uses, so our text matches it
local function PlateFont(plate, size)
    local uf = plate.UnitFrame
    local name = uf and (uf.name or uf.Name)
    local font, _, flags = nil, nil, nil
    if name and name.GetFont then font, _, flags = name:GetFont() end
    return font or ns.FONT, size, flags or "OUTLINE"
end

local function Strip(plate)
    if plate.hbThreat then return plate.hbThreat end
    local bar = HealthBar(plate) or plate
    local o = CreateFrame("Frame", nil, plate)
    o:SetHeight(STRIP_H)
    o:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 1)
    o:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 1)
    o:SetFrameLevel((bar.GetFrameLevel and bar:GetFrameLevel() or 1) + 3)
    o.fill = o:CreateTexture(nil, "ARTWORK")
    o.fill:SetTexture(WHITE)
    o.fill:SetAllPoints()
    -- a faint glow above the line, fading out
    o.glow = CreateFrame("Frame", nil, o)
    o.glow:SetAllPoints()
    o.bands = {}
    local t = o.glow:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(WHITE)
    t:SetBlendMode("ADD")
    t:SetPoint("BOTTOMLEFT", o, "TOPLEFT")
    t:SetPoint("BOTTOMRIGHT", o, "TOPRIGHT")
    t:SetHeight(GLOW)
    t.a1, t.a2 = 0.35, 0 -- (a gradient runs bottom to top)
    o.bands[1] = t
    -- LOSING, or your threat %, beside the bar - in the plate's own font
    o.text = o:CreateFontString(nil, "OVERLAY")
    o.text:SetFont(PlateFont(plate, 8))
    o.text:SetPoint("LEFT", bar, "RIGHT", 3, 0)
    -- losing it (or about to pull it): a gentle pulse
    o.pulse = o:CreateAnimationGroup()
    local a = o.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.4)
        a:SetDuration(0.6)
        a:SetSmoothing("IN_OUT")
    end
    o.pulse:SetLooping("BOUNCE")
    o:Hide()
    plate.hbThreat = o
    return o
end

local function Paint(o, status)
    local c = COLOURS[status]
    o.fill:SetVertexColor(c[1], c[2], c[3], 1)
    for _, t in ipairs(o.bands) do Fade(t, "VERTICAL", c[1], c[2], c[3], t.a1, t.a2) end
    -- LOSING in its colour; a plain % in the plate's off-white
    if status == 2 then o.text:SetTextColor(c[1], c[2], c[3]) else o.text:SetTextColor(0.85, 0.85, 0.85) end
end

-- your threat on unit: status 0-3 and percent (nil when you're not on its threat list)
local function Threat(unit)
    if not (UnitDetailedThreatSituation or UnitThreatSituation) then return nil end
    if Safe(UnitCanAttack, "player", unit) ~= true or Safe(UnitIsDead, unit) == true then return nil end
    local status, pct
    if UnitDetailedThreatSituation then
        local _, s, scaled = Safe(UnitDetailedThreatSituation, "player", unit)
        status, pct = s, scaled
    end
    if status == nil and UnitThreatSituation then status = Safe(UnitThreatSituation, "player", unit) end
    if type(status) ~= "number" or not COLOURS[status] then return nil end
    return status, pct
end

-- tint the plate's health bar (and put the game's colour back when there's no threat)
local function Tint(plate, status)
    local bar = HealthBar(plate)
    if not bar then return end
    if status and On("threatPlatesBar") then
        local c = COLOURS[status]
        bar:SetStatusBarColor(c[1], c[2], c[3])
        plate.hbTinted = true
    elseif plate.hbTinted then
        plate.hbTinted = nil
        if CompactUnitFrame_UpdateHealthColor and plate.UnitFrame then pcall(CompactUnitFrame_UpdateHealthColor, plate.UnitFrame) end
    end
end

---------------------------------------------------------------------------
-- Your debuffs, above the strip
---------------------------------------------------------------------------
-- the debuffs you've put on unit: { icon, count, duration, expires }
local function MyDebuffs(unit)
    local out = {}
    for i = 1, 40 do
        local icon, count, duration, expires
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a = Safe(C_UnitAuras.GetAuraDataByIndex, unit, i, "HARMFUL|PLAYER")
            if type(a) ~= "table" then break end
            icon, count, duration, expires = a.icon, a.applications, a.duration, a.expirationTime
        elseif UnitAura then
            local name, tex, c, _, d, e = Safe(UnitAura, unit, i, "HARMFUL|PLAYER")
            if not name then break end
            icon, count, duration, expires = tex, c, d, e
        else
            break
        end
        out[#out + 1] = { icon = icon, count = count, duration = duration, expires = expires }
        if #out >= MAX_DEBUFFS then break end
    end
    return out
end

local function DebuffIcon(row, i)
    local b = row.icons[i]
    if b then return b end
    b = CreateFrame("Frame", nil, row)
    b:SetSize(ICON_W, ICON_H)
    b.back = b:CreateTexture(nil, "BACKGROUND")
    b.back:SetTexture(WHITE)
    b.back:SetPoint("TOPLEFT", -1, 1)
    b.back:SetPoint("BOTTOMRIGHT", 1, -1)
    b.back:SetVertexColor(0, 0, 0, 0.6)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexCoord(0.1, 0.9, 0.28, 0.72) -- the middle band of the icon, to fit the wide shape
    b.cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cd:SetAllPoints()
    if b.cd.SetDrawEdge then b.cd:SetDrawEdge(false) end
    if b.cd.SetHideCountdownNumbers then b.cd:SetHideCountdownNumbers(true) end
    if b.cd.SetReverse then b.cd:SetReverse(true) end
    if b.cd.SetSwipeColor then b.cd:SetSwipeColor(0, 0, 0, 0.55) end
    b.count = b:CreateFontString(nil, "OVERLAY")
    b.count:SetFont(PlateFont(row:GetParent(), 8))
    b.count:SetPoint("BOTTOMRIGHT", 1, 0)
    row.icons[i] = b
    return b
end

local function Debuffs(plate, unit)
    local row = plate.hbDebuffs
    local list = (On("threatPlatesDebuffs") and Safe(UnitCanAttack, "player", unit) == true) and MyDebuffs(unit) or {}
    if #list == 0 and not row then return end
    if not row then
        row = CreateFrame("Frame", nil, plate)
        row:SetHeight(ICON_H)
        row.icons = {}
        plate.hbDebuffs = row
    end
    -- above the name (above the bar and its threat line), where the game puts its own
    local top = Top(plate)
    local bar = HealthBar(plate) or plate
    row:ClearAllPoints()
    row:SetPoint("BOTTOM", top, "TOP", 0, top == bar and (STRIP_H + GLOW + 2) or 3)
    row:SetPoint("LEFT", bar, "LEFT", 0, 0)
    row:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
    -- the icons, centred
    local width = #list * ICON_W + math.max(0, #list - 1) * 2
    for i, d in ipairs(list) do
        local b = DebuffIcon(row, i)
        b:ClearAllPoints()
        b:SetPoint("BOTTOMLEFT", row, "BOTTOM", -width / 2 + (i - 1) * (ICON_W + 2), 0)
        b.tex:SetTexture(d.icon)
        b.count:SetText((d.count and d.count > 1) and d.count or "")
        if d.duration and d.duration > 0 and d.expires then
            b.cd:SetCooldown(d.expires - d.duration, d.duration)
            b.cd:Show()
        else
            b.cd:Hide()
        end
        b:Show()
    end
    for i = #list + 1, #row.icons do row.icons[i]:Hide() end
    row:SetShown(#list > 0)
    -- the game's own debuffs on the plate would sit in the same place: hide them while ours show
    local uf = plate.UnitFrame
    local theirs = uf and (uf.BuffFrame or uf.AurasFrame)
    if theirs and theirs.SetAlpha then theirs:SetAlpha(#list > 0 and 0 or 1) end
end

---------------------------------------------------------------------------
-- Updating
---------------------------------------------------------------------------
local function Update(unit)
    if not (unit and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return end
    local plate = Safe(C_NamePlate.GetNamePlateForUnit, unit)
    if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
    local status, pct
    if On("threatPlates") then status, pct = Threat(unit) end
    local o = (status or plate.hbThreat) and Strip(plate)
    if o then
        o.status = status
        Tint(plate, status)
        if status then
            if o.painted ~= status then
                Paint(o, status)
                o.painted = status
            end
            o.glow:SetShown(On("threatPlatesGlow"))
            if (status == 1 or status == 2) and On("threatPlatesGlow") then
                if not o.pulse:IsPlaying() then o.pulse:Play() end
            else
                o.pulse:Stop()
                o.glow:SetAlpha(1)
            end
            if On("threatPlatesText") then
                -- (nothing when you have it: the red says so)
                o.text:SetText(status == 3 and "" or (status == 2 and "LOSING") or (pct and format("%d%%", pct)) or "")
                o.text:Show()
            else
                o.text:Hide()
            end
            o:Show()
        else
            o.pulse:Stop()
            o:Hide()
        end
    end
    Debuffs(plate, unit)
end

local function UpdateAll()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end
    for _, plate in ipairs(Safe(C_NamePlate.GetNamePlates) or {}) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        if unit then Update(unit) end
    end
end
ns.UpdateThreatPlates = UpdateAll

table.insert(ns.inits, function()
    -- once: the tinted health bar is off now (the plate keeps the game's colours)
    if not ns.db.threatPlatesBlend then
        ns.db.threatPlatesBlend = true
        ns.db.threatPlatesBar = false
    end
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) Update(unit) end)
    ns.On("NAME_PLATE_UNIT_REMOVED", function(_, unit)
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, unit)
        if not plate then return end
        local o = plate.hbThreat
        if o then
            o.status = nil
            o.pulse:Stop()
            o:Hide()
            Tint(plate, nil)
        end
        if plate.hbDebuffs then plate.hbDebuffs:Hide() end
    end)
    ns.On("UNIT_THREAT_LIST_UPDATE", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("UNIT_THREAT_SITUATION_UPDATE", function() UpdateAll() end)
    ns.On("UNIT_AURA", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("PLAYER_TARGET_CHANGED", function() C_Timer.After(0, UpdateAll) end) -- the selected plate grows
    ns.On("PLAYER_REGEN_ENABLED", function() C_Timer.After(0.2, UpdateAll) end)
    ns.On("PLAYER_REGEN_DISABLED", UpdateAll)
    -- the game sets the health bar's colour again now and then: tint it back
    if hooksecurefunc and CompactUnitFrame_UpdateHealthColor then
        hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
            local plate = frame and frame.GetParent and frame:GetParent()
            local o = plate and plate.hbThreat
            if o and o.status and On("threatPlates") and On("threatPlatesBar") then
                local bar = HealthBar(plate)
                local c = COLOURS[o.status]
                if bar then bar:SetStatusBarColor(c[1], c[2], c[3]) end
            end
        end)
    end
    -- threat changes all the time in a fight: check every quarter second while you're in one
    local elapsed = 0
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < TICK then return end
        elapsed = 0
        if InCombatLockdown() or (UnitAffectingCombat and UnitAffectingCombat("player")) then UpdateAll() end
    end)
    table.insert(ns.refreshers, UpdateAll)
end)
