local ADDON_NAME, ns = ...

-- Threat on enemy nameplates, the way the well-liked nameplate addons do it
-- (SimpleClassicThreatNameplates, Threat Plates, SmartPlates): the game's own
-- plate, with its health bar coloured by your threat - nothing bolted on.
--   red    - you have aggro
--   yellow - you're losing it, or about to pull it off whoever has it
--            (only then: a soft glow round the plate, slowly pulsing)
--   green  - it's on someone else, well clear of you
-- In a group (or with a pet out) your threat % sits beside the bar, in its colour.
-- The game's own debuffs stay as they are (a row of yours above the name is an option).
-- /hb plates test: your target's plate shows each colour in turn.
-- Settings > Look & layout > Enemy nameplates.

local Safe = ns.Safe
local format = string.format
local WHITE = "Interface\\Buttons\\WHITE8X8"

-- (in the game's own shades, so a coloured bar still looks like a nameplate)
local COLOURS = {
    [3] = { 0.86, 0.16, 0.12 }, -- aggro
    [2] = { 1.00, 0.74, 0.12 }, -- losing it
    [1] = { 1.00, 0.74, 0.12 }, -- about to pull it
    [0] = { 0.30, 0.80, 0.28 }, -- no aggro
}
local GLOW = 6                -- how far the warning glow reaches out from the bar
local ICON_W, ICON_H = 20, 14 -- one of your debuffs (the option)
local MAX_DEBUFFS = 6
local TICK = 0.25             -- seconds between threat checks in combat

local preview = {}            -- unit -> status, while /hb plates test runs

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

-- the font the plate's name uses, so our text matches it
local function PlateFont(plate, size)
    local uf = plate.UnitFrame
    local name = uf and (uf.name or uf.Name)
    local font, flags
    if name and name.GetFont then
        local f, _, fl = name:GetFont()
        font, flags = f, fl
    end
    return font or ns.FONT, size, (flags and flags ~= "") and flags or "OUTLINE"
end

---------------------------------------------------------------------------
-- What we add to a plate: the warning glow and the threat %
---------------------------------------------------------------------------
local function Extras(plate)
    if plate.hbThreat then return plate.hbThreat end
    local bar = HealthBar(plate) or plate
    local o = CreateFrame("Frame", nil, plate)
    o:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
    o:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
    o:SetFrameLevel(math.max(0, (bar.GetFrameLevel and bar:GetFrameLevel() or 1) - 1))
    -- the glow: four soft bands fading out from the bar's edge
    o.glow = CreateFrame("Frame", nil, o)
    o.glow:SetAllPoints()
    o.bands = {}
    -- (a gradient runs bottom to top, or left to right)
    local function Band(p1, r1, p2, r2, w, h, orientation, a1, a2)
        local t = o.glow:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(WHITE)
        t:SetBlendMode("ADD")
        t:SetPoint(p1, o, r1)
        t:SetPoint(p2, o, r2)
        if w then t:SetWidth(w) end
        if h then t:SetHeight(h) end
        t.orientation, t.a1, t.a2 = orientation, a1, a2
        o.bands[#o.bands + 1] = t
    end
    Band("BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "TOPRIGHT", nil, GLOW, "VERTICAL", 0.5, 0)      -- above
    Band("TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "BOTTOMRIGHT", nil, GLOW, "VERTICAL", 0, 0.5)      -- below
    Band("TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT", GLOW, nil, "HORIZONTAL", 0, 0.5)    -- left
    Band("TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", GLOW, nil, "HORIZONTAL", 0.5, 0)    -- right
    o.pulse = o.glow:CreateAnimationGroup()
    local a = o.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.3)
        a:SetDuration(0.8)
        a:SetSmoothing("IN_OUT")
    end
    o.pulse:SetLooping("BOUNCE")
    -- your threat %, left of the bar (the game's level sits on the right)
    o.text = o:CreateFontString(nil, "OVERLAY")
    o.text:SetFont(PlateFont(plate, 9))
    o.text:SetPoint("RIGHT", bar, "LEFT", -4, 0)
    o:Hide()
    plate.hbThreat = o
    return o
end

-- your threat on unit: status 0-3 and percent (nil when you're not on its threat list)
local function Threat(unit)
    if preview[unit] then return preview[unit], ({ [0] = 35, [1] = 92, [2] = 100, [3] = 100 })[preview[unit]] end
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

-- the health bar in your threat colour (and back to the game's when there's none)
local function Tint(plate, status)
    local bar = HealthBar(plate)
    if not bar then return end
    if status then
        local c = COLOURS[status]
        bar:SetStatusBarColor(c[1], c[2], c[3])
        plate.hbTinted = true
    elseif plate.hbTinted then
        plate.hbTinted = nil
        if CompactUnitFrame_UpdateHealthColor and plate.UnitFrame then pcall(CompactUnitFrame_UpdateHealthColor, plate.UnitFrame) end
    end
end

-- the % only matters with someone else on the threat list
local function ShowNumbers()
    return (IsInGroup and IsInGroup()) or (UnitExists and UnitExists("pet")) or next(preview) ~= nil
end

---------------------------------------------------------------------------
-- Your debuffs above the name (an option - the game's own show otherwise)
---------------------------------------------------------------------------
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
    b.back:SetVertexColor(0, 0, 0, 0.9)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexCoord(0.08, 0.92, 0.22, 0.78)
    b.cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cd:SetAllPoints()
    if b.cd.SetDrawEdge then b.cd:SetDrawEdge(false) end
    if b.cd.SetHideCountdownNumbers then b.cd:SetHideCountdownNumbers(true) end
    if b.cd.SetReverse then b.cd:SetReverse(true) end
    if b.cd.SetSwipeColor then b.cd:SetSwipeColor(0, 0, 0, 0.55) end
    b.count = b:CreateFontString(nil, "OVERLAY")
    b.count:SetFont(PlateFont(row:GetParent(), 9))
    b.count:SetPoint("BOTTOMRIGHT", 2, -2)
    row.icons[i] = b
    return b
end

local function TheirDebuffs(plate, shown)
    local uf = plate.UnitFrame
    local theirs = uf and (uf.BuffFrame or uf.AurasFrame or uf.DebuffFrame)
    if theirs and theirs.SetAlpha then theirs:SetAlpha(shown and 1 or 0) end
end

local function Debuffs(plate, unit)
    local mine = ns.db and ns.db.threatPlatesDebuffs == true
    TheirDebuffs(plate, not mine)
    local row = plate.hbDebuffs
    local list = (mine and Safe(UnitCanAttack, "player", unit) == true) and MyDebuffs(unit) or {}
    if #list == 0 then
        if row then row:Hide() end
        return
    end
    if not row then
        row = CreateFrame("Frame", nil, plate)
        row:SetHeight(ICON_H)
        row.icons = {}
        plate.hbDebuffs = row
    end
    local uf = plate.UnitFrame
    local name = uf and (uf.name or uf.Name)
    local bar = HealthBar(plate) or plate
    local top = (name and name.IsShown and name:IsShown()) and name or bar
    row:ClearAllPoints()
    row:SetPoint("BOTTOM", top, "TOP", 0, 4)
    row:SetPoint("LEFT", bar, "LEFT", 0, 0)
    row:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
    local width = #list * ICON_W + math.max(0, #list - 1) * 3
    for i, d in ipairs(list) do
        local b = DebuffIcon(row, i)
        b:ClearAllPoints()
        b:SetPoint("BOTTOMLEFT", row, "BOTTOM", -width / 2 + (i - 1) * (ICON_W + 3), 0)
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
    row:Show()
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
    Tint(plate, status)
    local o = (status or plate.hbThreat) and Extras(plate)
    if o then
        o.status = status
        if status then
            local c = COLOURS[status]
            -- the warning glow: only when it's slipping (yellow)
            local warn = (status == 1 or status == 2) and On("threatPlatesGlow")
            if warn then
                if o.painted ~= status then
                    for _, t in ipairs(o.bands) do Fade(t, t.orientation, c[1], c[2], c[3], t.a1, t.a2) end
                end
                if not o.pulse:IsPlaying() then o.pulse:Play() end
            else
                o.pulse:Stop()
            end
            o.glow:SetShown(warn and true or false)
            o.painted = status
            -- the %: in a group, and not when you have it
            if On("threatPlatesText") and status ~= 3 and pct and ShowNumbers() then
                o.text:SetText(format("%d%%", pct))
                o.text:SetTextColor(c[1], c[2], c[3])
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

-- /hb plates test: your target's plate shows each colour in turn, two seconds each
function ns.ThreatPlatesTest()
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, "target")
    if not plate then
        return ns.Print("Nameplates: target an enemy with its nameplate showing (V), then try again.")
    end
    local unit = plate.namePlateUnitToken or "target"
    local steps = { { 3, "red - you have aggro" }, { 2, "yellow - you're losing it" },
                    { 1, "yellow - you're about to pull it" }, { 0, "green - it's on someone else" } }
    for n, step in ipairs(steps) do
        C_Timer.After((n - 1) * 2, function()
            preview[unit] = step[1]
            Update(unit)
            ns.Print("Nameplates: " .. step[2])
        end)
    end
    C_Timer.After(#steps * 2, function()
        preview[unit] = nil
        Update(unit)
    end)
end

table.insert(ns.inits, function()
    -- once: the new look - colour in the bar, the game's own debuffs back
    if not ns.db.threatPlatesV3 then
        ns.db.threatPlatesV3 = true
        ns.db.threatPlatesDebuffs = false
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
        end
        Tint(plate, nil)
        if plate.hbDebuffs then plate.hbDebuffs:Hide() end
    end)
    ns.On("UNIT_THREAT_LIST_UPDATE", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("UNIT_THREAT_SITUATION_UPDATE", function() UpdateAll() end)
    ns.On("UNIT_AURA", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("PLAYER_TARGET_CHANGED", function() C_Timer.After(0, UpdateAll) end)
    ns.On("PLAYER_REGEN_ENABLED", function() C_Timer.After(0.2, UpdateAll) end)
    ns.On("PLAYER_REGEN_DISABLED", UpdateAll)
    -- the game sets the health bar's colour again now and then: colour it back
    if hooksecurefunc and CompactUnitFrame_UpdateHealthColor then
        hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
            local plate = frame and frame.GetParent and frame:GetParent()
            local o = plate and plate.hbThreat
            if o and o.status and On("threatPlates") then
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
