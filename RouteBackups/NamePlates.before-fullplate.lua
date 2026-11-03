local ADDON_NAME, ns = ...

-- A threat bar under each enemy's nameplate, in a fight: a thin dark track the
-- width of the plate, filled to your threat in its colour -
--   red    - you have aggro (full)
--   yellow - you're losing it, or about to pull it off whoever has it
--   green  - it's on someone else, well clear of you (filled to your threat %)
-- The plates can take the addon's look (flat bar, dark backing, crisp border -
-- gold on your target - and its font); the bar keeps the game's colours. Your
-- unit frames are never touched (the game's red threat glow on them can be hidden).
-- An option: your own debuffs in a row above the name, instead of the game's.
-- /hb plates test: your target's bar shows each colour in turn.
-- /hb plates debug: what the addon finds on your target's plate.
-- Settings > Look & layout > Enemy nameplates.

local Safe = ns.Safe
local format = string.format
local WHITE = "Interface\\Buttons\\WHITE8X8"

local COLOURS = {
    [3] = { 0.90, 0.18, 0.14 }, -- aggro
    [2] = { 1.00, 0.76, 0.16 }, -- losing it
    [1] = { 1.00, 0.76, 0.16 }, -- about to pull it
    [0] = { 0.32, 0.84, 0.34 }, -- no aggro
}
local BAR_H = 4                -- the threat bar's height
local GAP = 3                  -- between the plate's health bar and it
local ICON_W, ICON_H = 20, 14  -- one of your debuffs (the option)
local MAX_DEBUFFS = 6
local TICK = 0.25              -- seconds between threat checks in combat

local preview = {}             -- unit -> status, while /hb plates test runs

local function On(key) return ns.db and ns.db[key] ~= false end

-- the plate's health bar, to line our bar up under it (we never change it).
-- It has moved between client versions; else the first status bar on the plate.
local function FindStatusBar(frame, depth)
    if not (frame and frame.GetChildren) or depth > 3 then return nil end
    for _, c in ipairs({ frame:GetChildren() }) do
        if c.GetObjectType and c:GetObjectType() == "StatusBar" then return c end
        local found = FindStatusBar(c, depth + 1)
        if found then return found end
    end
end

local function HealthBar(plate)
    if not plate then return nil end
    if plate.hbBar then return plate.hbBar end
    local function Frame(v) return type(v) == "table" and v.GetObjectType and v or nil end
    local uf = type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
    local box = uf and type(uf.HealthBarsContainer) == "table" and uf.HealthBarsContainer or nil
    local direct = uf and (Frame(uf.healthBar) or Frame(uf.HealthBar))
    local boxed = box and (Frame(box.healthBar) or Frame(box.HealthBar))
    local bar = direct or boxed or FindStatusBar(uf or plate, 1)
    if bar then
        plate.hbBar = bar
        plate.hbBarFrom = direct and "UnitFrame.healthBar" or (boxed and "UnitFrame.HealthBarsContainer.healthBar") or "a status bar on the plate"
    end
    return bar
end

-- the font the plate's name uses, so our text matches it
local function PlateFont(plate, size)
    local uf = type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
    local name = uf and (uf.name or uf.Name)
    local font, flags
    if type(name) == "table" and name.GetFont then
        local f, _, fl = name:GetFont()
        font, flags = f, fl
    end
    return font or ns.FONT, size, (flags and flags ~= "") and flags or "OUTLINE"
end

---------------------------------------------------------------------------
-- The plate in the addon's style (a setting): a flat bar on a dark backing, a
-- crisp 1px border (gold on your target), the addon's font for the name. The
-- game's colours for the bar stay; switching it off puts the game's look back.
---------------------------------------------------------------------------
local function Edges(frame, layer)
    local t = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local e = frame:CreateTexture(nil, layer or "OVERLAY")
        e:SetTexture(WHITE)
        if side == "TOP" or side == "BOTTOM" then
            e:SetPoint(side .. "LEFT", -1, side == "TOP" and 1 or -1)
            e:SetPoint(side .. "RIGHT", 1, side == "TOP" and 1 or -1)
            e:SetHeight(1)
        else
            e:SetPoint("TOP" .. side, side == "LEFT" and -1 or 1, 1)
            e:SetPoint("BOTTOM" .. side, side == "LEFT" and -1 or 1, -1)
            e:SetWidth(1)
        end
        t[#t + 1] = e
    end
    return t
end

local function EdgeColour(edges, r, g, b, a)
    for _, e in ipairs(edges) do e:SetVertexColor(r, g, b, a or 1) end
end

-- the game's frame round the health bar (it has moved between client versions)
local function GameBorder(bar)
    for _, key in ipairs({ "border", "Border", "barBorder" }) do
        local b = bar[key]
        if type(b) == "table" and b.SetAlpha then return b end
    end
end

local function Skin(plate, unit)
    local bar = HealthBar(plate)
    if not bar then return end
    local uf = type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
    local name = uf and (uf.name or uf.Name)
    name = type(name) == "table" and name.SetFont and name or nil
    if not On("hbPlates") then
        -- back to the game's look
        local sk = plate.hbSkin
        if sk and sk.on then
            sk.on = false
            if sk.texture and bar.SetStatusBarTexture then bar:SetStatusBarTexture(sk.texture) end
            if sk.border then sk.border:SetAlpha(1) end
            if name and sk.font then name:SetFont(sk.font, sk.size, sk.flags) end
            sk.frame:Hide()
        end
        return
    end
    local sk = plate.hbSkin
    if not sk then
        sk = {}
        local tex = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
        sk.texture = type(tex) == "table" and tex.GetTexture and tex:GetTexture() or nil
        sk.border = GameBorder(bar)
        if name then sk.font, sk.size, sk.flags = name:GetFont() end
        -- our backing and border: a frame of our own, round the bar
        sk.frame = CreateFrame("Frame", nil, plate)
        sk.frame:SetPoint("TOPLEFT", bar, "TOPLEFT")
        sk.frame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
        sk.frame:SetFrameLevel(math.max(0, (bar.GetFrameLevel and bar:GetFrameLevel() or 1) + 2))
        sk.back = bar:CreateTexture(nil, "BACKGROUND")
        sk.back:SetTexture(WHITE)
        sk.back:SetAllPoints()
        sk.edges = Edges(sk.frame)
        plate.hbSkin = sk
    end
    -- (every time: the game can reset a plate when it reuses it for another enemy)
    sk.on = true
    if bar.SetStatusBarTexture then bar:SetStatusBarTexture(WHITE) end
    if sk.border then sk.border:SetAlpha(0) end
    if name and sk.size then name:SetFont(ns.FONT, math.max(8, math.floor(sk.size + 0.5)), "OUTLINE") end
    sk.frame:Show()
    local bg = ns.color.bg
    sk.back:SetVertexColor(bg[1], bg[2], bg[3], 0.85)
    -- your target: the addon's gold
    if unit and Safe(UnitIsUnit, unit, "target") == true then
        local g = ns.color.gold
        EdgeColour(sk.edges, g[1], g[2], g[3], 1)
    else
        EdgeColour(sk.edges, 0, 0, 0, 1)
    end
end

---------------------------------------------------------------------------
-- The threat bar
---------------------------------------------------------------------------
local function ThreatBar(plate)
    if plate.hbThreat then return plate.hbThreat end
    local bar = HealthBar(plate)
    local o = CreateFrame("Frame", nil, plate)
    o:SetHeight(BAR_H)
    if bar then
        o:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -GAP)
        o:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -GAP)
    else
        -- no health bar found: under the middle of the plate itself
        o:SetPoint("TOP", plate, "CENTER", 0, -8)
        o:SetWidth(100)
    end
    o:SetFrameStrata(plate.GetFrameStrata and plate:GetFrameStrata() or "MEDIUM")
    o:SetFrameLevel((plate.GetFrameLevel and plate:GetFrameLevel() or 1) + 10)
    -- the addon's look: a dark track with a crisp 1px black edge
    o.track = o:CreateTexture(nil, "BACKGROUND")
    o.track:SetTexture(WHITE)
    o.track:SetAllPoints()
    o.track:SetVertexColor(ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], 0.85)
    o.edges = Edges(o, "BORDER")
    EdgeColour(o.edges, 0, 0, 0, 1)
    -- the fill: your threat, in its colour (a status bar: it fills by share, whatever the width)
    o.meter = CreateFrame("StatusBar", nil, o)
    o.meter:SetAllPoints()
    o.meter:SetStatusBarTexture(WHITE)
    o.meter:SetMinMaxValues(0, 1)
    o.meter:SetValue(0)
    o.shine = o.meter:CreateTexture(nil, "OVERLAY") -- a lighter top edge, for depth
    o.shine:SetTexture(WHITE)
    o.shine:SetPoint("TOPLEFT")
    o.shine:SetPoint("TOPRIGHT")
    o.shine:SetHeight(1)
    o.shine:SetVertexColor(1, 1, 1, 0.12)
    -- losing it: the fill breathes
    o.pulse = o.meter:CreateAnimationGroup()
    local a = o.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.45)
        a:SetDuration(0.6)
        a:SetSmoothing("IN_OUT")
    end
    o.pulse:SetLooping("BOUNCE")
    -- your threat %, at the right-hand end (in a group)
    o.text = o:CreateFontString(nil, "OVERLAY")
    o.text:SetFont(ns.FONT, 8, "OUTLINE")
    o.text:SetPoint("LEFT", o, "RIGHT", 3, 0)
    o:Hide()
    plate.hbThreat = o
    return o
end

-- your threat on unit: status 0-3 and percent (nil when you're not on its threat list)
local function Threat(unit)
    if preview[unit] then return preview[unit], ({ [0] = 35, [1] = 92, [2] = 100, [3] = 100 })[preview[unit]] end
    if Safe(UnitCanAttack, "player", unit) ~= true or Safe(UnitIsDead, unit) == true then return nil end
    local status, pct
    if UnitDetailedThreatSituation then
        local _, s, scaled = Safe(UnitDetailedThreatSituation, "player", unit)
        status, pct = s, scaled
    end
    if status == nil and UnitThreatSituation then status = Safe(UnitThreatSituation, "player", unit) end
    -- no threat figures from the game: at least, a mob in a fight that's after you is your aggro
    if status == nil and Safe(UnitAffectingCombat, unit) == true then
        local target = unit .. "target"
        if Safe(UnitIsUnit, target, "player") == true then status, pct = 3, 100
        elseif Safe(UnitExists, target) == true and (Safe(UnitInParty, target) == true or Safe(UnitInRaid, target)
            or Safe(UnitIsUnit, target, "pet") == true) then status = 0 end
    end
    if type(status) ~= "number" or not COLOURS[status] then return nil end
    return status, pct
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
    local uf = type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
    local theirs = uf and (uf.BuffFrame or uf.AurasFrame or uf.DebuffFrame)
    if type(theirs) == "table" and theirs.SetAlpha then theirs:SetAlpha(shown and 1 or 0) end
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
    local uf = type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
    local name = uf and (uf.name or uf.Name)
    local bar = HealthBar(plate) or plate
    local top = (type(name) == "table" and name.IsShown and name:IsShown()) and name or bar
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
    Skin(plate, unit)
    local status, pct
    if On("threatPlates") then status, pct = Threat(unit) end
    local o = (status or plate.hbThreat) and ThreatBar(plate)
    if o then
        if status then
            local c = COLOURS[status]
            -- filled to your threat: full when you have it (or losing it), your % otherwise
            local share = (status >= 2) and 1 or math.max(0.06, math.min(1, (pct or 50) / 100))
            o.meter:SetValue(share)
            o.meter:SetStatusBarColor(c[1], c[2], c[3])
            if status == 1 or status == 2 then
                if not o.pulse:IsPlaying() then o.pulse:Play() end
            else
                o.pulse:Stop()
                o.meter:SetAlpha(1)
            end
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
        local unit = plate.namePlateUnitToken or (type(plate.UnitFrame) == "table" and plate.UnitFrame.unit)
        if unit then Update(unit) end
    end
end
ns.UpdateThreatPlates = UpdateAll

---------------------------------------------------------------------------
-- Your unit frames: the game's own red threat glow on them, hidden (a setting)
---------------------------------------------------------------------------
local GLOWS = { "PlayerFrameFlash", "TargetFrameFlash", "FocusFrameFlash", "TargetFrameNumericalThreat", "FocusFrameNumericalThreat" }
local function UnitFrameGlows()
    local hide = On("hideFrameThreat")
    for _, name in ipairs(GLOWS) do
        local f = rawget(_G, name)
        if type(f) == "table" and f.SetAlpha then
            f:SetAlpha(hide and 0 or 1)
            if not f.hbHooked and f.HookScript then
                f.hbHooked = true
                f:HookScript("OnShow", function(self) if On("hideFrameThreat") then self:SetAlpha(0) end end)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------
-- /hb plates debug: what the addon finds on your target's plate
function ns.ThreatPlatesDebug()
    local P = function(t) ns.Print("|cff999999plates|r " .. t) end
    P(format("setting %s, threat API: detailed %s, situation %s", tostring(On("threatPlates")),
        tostring(UnitDetailedThreatSituation ~= nil), tostring(UnitThreatSituation ~= nil)))
    if not UnitExists("target") then return P("no target - target an enemy and try again") end
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, "target")
    if not plate then return P("your target has no nameplate showing (press V for enemy nameplates)") end
    if plate.IsForbidden and plate:IsForbidden() then
        return P("|cffff6666your client won't let addons touch this nameplate (it's 'forbidden')|r")
    end
    local unit = plate.namePlateUnitToken
    P("plate found, unit " .. tostring(unit))
    local bar = HealthBar(plate)
    P("its health bar: " .. (bar and (plate.hbBarFrom or "?") or "not found - the threat bar sits under the plate's middle"))
    if UnitDetailedThreatSituation then
        local tanking, s, scaled, raw, value = Safe(UnitDetailedThreatSituation, "player", "target")
        P(format("your threat on it: tanking %s, status %s, %s%%, raw %s, value %s", tostring(tanking), tostring(s),
            tostring(scaled), tostring(raw), tostring(value)))
    end
    local status = unit and Threat(unit)
    local o = plate.hbThreat
    P(format("so its threat bar is: %s (shown now: %s); in combat %s; it targets you %s",
        status and ({ [3] = "red", [2] = "yellow", [1] = "yellow", [0] = "green" })[status] or "not shown (not fighting you)",
        tostring(o and o:IsShown()), tostring(Safe(UnitAffectingCombat, "target")), tostring(Safe(UnitIsUnit, "targettarget", "player"))))
end

-- /hb plates test: your target's threat bar shows each colour in turn, two seconds each
function ns.ThreatPlatesTest()
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, "target")
    if not plate then
        return ns.Print("Nameplates: target an enemy with its nameplate showing (V), then try again.")
    end
    if plate.IsForbidden and plate:IsForbidden() then
        return ns.Print("Nameplates: your client won't let addons draw on this nameplate.")
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
    -- once: the game's own debuffs back on the plates
    if not ns.db.threatPlatesV3 then
        ns.db.threatPlatesV3 = true
        ns.db.threatPlatesDebuffs = false
    end
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) Update(unit) end)
    ns.On("NAME_PLATE_UNIT_REMOVED", function(_, unit)
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, unit)
        if not plate then return end
        if plate.hbThreat then
            plate.hbThreat.pulse:Stop()
            plate.hbThreat:Hide()
        end
        if plate.hbDebuffs then plate.hbDebuffs:Hide() end
    end)
    ns.On("UNIT_THREAT_LIST_UPDATE", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("UNIT_THREAT_SITUATION_UPDATE", function() UpdateAll() end)
    ns.On("UNIT_AURA", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("PLAYER_TARGET_CHANGED", function()
        C_Timer.After(0, UpdateAll)
        UnitFrameGlows()
    end)
    ns.On("PLAYER_REGEN_ENABLED", function() C_Timer.After(0.2, UpdateAll) end)
    ns.On("PLAYER_REGEN_DISABLED", UpdateAll)
    ns.On("PLAYER_ENTERING_WORLD", UnitFrameGlows)
    -- threat changes all the time in a fight: check every quarter second while you're in one
    local elapsed = 0
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < TICK then return end
        elapsed = 0
        if InCombatLockdown() or (UnitAffectingCombat and UnitAffectingCombat("player")) then UpdateAll() end
    end)
    table.insert(ns.refreshers, function()
        UpdateAll()
        UnitFrameGlows()
    end)
end)
