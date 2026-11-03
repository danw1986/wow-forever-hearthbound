local ADDON_NAME, ns = ...

-- Threat on enemy nameplates, in combat: a glowing edge round the plate, the
-- health bar tinted to match, and your threat on its side.
--   red    - you have it (tanking it securely)
--   yellow - you're losing it (tanking it, someone's catching up), or you're
--            about to pull it off whoever has it - the edge pulses
--   green  - it's on someone else and you're well below them
-- Settings > Look & layout > Enemy nameplates.

local Safe = ns.Safe
local format = string.format
local WHITE = "Interface\\Buttons\\WHITE8X8"

local COLOURS = {
    [3] = { 1.00, 0.16, 0.12 }, -- aggro
    [2] = { 1.00, 0.80, 0.10 }, -- losing it
    [1] = { 1.00, 0.80, 0.10 }, -- about to pull it
    [0] = { 0.25, 0.95, 0.40 }, -- no aggro
}
local GLOW = 7          -- how far the glow reaches past the plate's edge
local TICK = 0.25       -- seconds between threat checks in combat

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

-- the overlay on one nameplate, made the first time it's needed
local function Overlay(plate)
    if plate.hbThreat then return plate.hbThreat end
    local anchor = HealthBar(plate) or plate
    local o = CreateFrame("Frame", nil, plate)
    o:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
    o:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
    o:SetFrameLevel((anchor.GetFrameLevel and anchor:GetFrameLevel() or 1) + 3)
    -- a 1px edge right round the bar
    o.edges = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local t = o:CreateTexture(nil, "OVERLAY")
        t:SetTexture(WHITE)
        if side == "TOP" or side == "BOTTOM" then
            t:SetPoint(side .. "LEFT")
            t:SetPoint(side .. "RIGHT")
            t:SetHeight(1)
        else
            t:SetPoint("TOP" .. side)
            t:SetPoint("BOTTOM" .. side)
            t:SetWidth(1)
        end
        o.edges[#o.edges + 1] = t
    end
    -- the glow: four soft bands fading away from the edge
    o.glow = CreateFrame("Frame", nil, o)
    o.glow:SetAllPoints()
    o.bands = {}
    -- (a gradient runs bottom to top, or left to right: a1 at the start, a2 at the end)
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
    Band("BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "TOPRIGHT", nil, GLOW, "VERTICAL", 0.55, 0)     -- above
    Band("TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "BOTTOMRIGHT", nil, GLOW, "VERTICAL", 0, 0.55)     -- below
    Band("TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT", GLOW, nil, "HORIZONTAL", 0, 0.55)   -- left
    Band("TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", GLOW, nil, "HORIZONTAL", 0.55, 0)   -- right
    -- your threat, on the right of the bar
    o.text = o:CreateFontString(nil, "OVERLAY")
    o.text:SetFont(ns.FONT, 9, "OUTLINE")
    o.text:SetPoint("LEFT", o, "RIGHT", 4, 0)
    -- losing it (or about to pull it): the glow pulses
    o.pulse = o.glow:CreateAnimationGroup()
    local a = o.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.25)
        a:SetDuration(0.45)
        a:SetSmoothing("IN_OUT")
    end
    o.pulse:SetLooping("BOUNCE")
    o:Hide()
    plate.hbThreat = o
    return o
end

local function Paint(o, status)
    local c = COLOURS[status]
    for _, t in ipairs(o.edges) do t:SetVertexColor(c[1], c[2], c[3], 0.95) end
    for _, t in ipairs(o.bands) do Fade(t, t.orientation, c[1], c[2], c[3], t.a1, t.a2) end
    o.text:SetTextColor(c[1], c[2], c[3])
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

local function Update(unit)
    if not (unit and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return end
    local plate = Safe(C_NamePlate.GetNamePlateForUnit, unit)
    if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
    local status, pct
    if On("threatPlates") then status, pct = Threat(unit) end
    local o = (status or plate.hbThreat) and Overlay(plate)
    if not o then return end
    o.status = status
    Tint(plate, status)
    if not status then
        o.pulse:Stop()
        o:Hide()
        return
    end
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
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) Update(unit) end)
    ns.On("NAME_PLATE_UNIT_REMOVED", function(_, unit)
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, unit)
        local o = plate and plate.hbThreat
        if o then
            o.status = nil
            o.pulse:Stop()
            o:Hide()
            Tint(plate, nil)
        end
    end)
    ns.On("UNIT_THREAT_LIST_UPDATE", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("UNIT_THREAT_SITUATION_UPDATE", function() UpdateAll() end)
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
