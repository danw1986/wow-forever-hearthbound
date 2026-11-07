local ADDON_NAME, ns = ...

-- Nameplates in the addon's style ("Hearthbound plates", a setting): the game's plate
-- art is hidden and a plate of our own is drawn in its place - the way Kui
-- Nameplates and Plater do it - so nothing of the game's look clashes with it.
--   the name line: the level (coloured like quest difficulty, + elite, R rare), then the name
--   the health bar: flat, on the addon's dark panel colour, crisp 1px border, faint sheen,
--     in soft reaction colours (class colours for players); health % inside when hurt.
--     In a fight it takes the threat colour (a setting), so aggro shows at a glance
--   the threat bar under it, in a fight: red - you have aggro, yellow - you're losing
--     it (or about to pull it off someone), green - it's on someone else
--   the cast bar under that: the spell's icon and name (gold - you can interrupt it)
--   your target: a gold border and glow; the other plates dim a little
--   the raid marker left of the bar; your debuffs above the name
-- With it off, the game's plates stay, with just the threat bar under them.
-- Your unit frames are never touched (the game's red threat glow on them can be hidden).
-- /hb plates test - your target's plate shows each threat colour in turn
-- /hb plates debug - what the addon finds on your target's plate
-- Settings > Look & layout > Enemy nameplates.

local Safe = ns.Safe
local format = string.format
local WHITE = "Interface\\Buttons\\WHITE8X8"

-- threat
local COLOURS = {
    [3] = { 0.90, 0.18, 0.14 }, -- aggro
    [2] = { 1.00, 0.76, 0.16 }, -- losing it
    [1] = { 1.00, 0.76, 0.16 }, -- about to pull it
    [0] = { 0.32, 0.84, 0.34 }, -- no aggro
}
-- the health bar's colours: soft versions of the game's reaction colours
-- (bright and rich, so the filled part stands well clear of the dark empty part)
local REACTION = {
    hostile = { 0.90, 0.22, 0.18 },
    neutral = { 1.00, 0.80, 0.22 },
    friendly = { 0.32, 0.82, 0.34 },
    tapped = { 0.58, 0.58, 0.60 },
}
-- sizes of our plate
local W, HP_H = 120, 11
local THREAT_H, CAST_H = 2, 8   -- (the threat line runs along the bottom of the health bar)
local SMOOTH = 8                -- how fast the health bar slides to the new value (per second)
local TRAIL_WAIT = 0.25         -- how long the "just lost" chunk waits before draining
local TRAIL_SPEED = 1.6         -- how fast it drains (a share of the bar per second)
local ICON_W, ICON_H = 20, 14 -- one of your debuffs
local MAX_DEBUFFS = 6
local TICK = 0.25            -- seconds between threat checks in combat
local DIM = 0.7              -- other plates, while you have a target

local preview = {}           -- unit -> status, while /hb plates test runs

local function On(key) return ns.db and ns.db[key] ~= false end
local function Styled() return On("hbPlates") end

-- Some clients hide figures from addons ("secret" values: an enemy's health, say).
-- They can go straight into a bar or a text, but any sum or comparison on them
-- is an error - so they're never added up, compared or joined here.
local function Secret(v)
    if ns.IsSecret then return ns.IsSecret(v) end
    return issecretvalue and issecretvalue(v) or false
end

-- call the game, keeping hidden figures (ns.Safe drops them - here they're wanted,
-- to go straight into a bar or a text)
local function Raw(fn, ...)
    if not fn then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

-- run one part of a plate's update; a failure in it doesn't stop the others
local function Try(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok and ns.db and ns.db.debugPlates then ns.Print("|cff999999plates|r " .. tostring(err)) end
    return ok
end

---------------------------------------------------------------------------
-- Little drawing helpers
---------------------------------------------------------------------------
-- a 1px border just outside a frame
local function Edges(frame, layer)
    local t = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local e = frame:CreateTexture(nil, layer or "OVERLAY")
        e:SetTexture(WHITE)
        if side == "TOP" or side == "BOTTOM" then
            local y = side == "TOP" and 1 or -1
            e:SetPoint(side .. "LEFT", -1, y)
            e:SetPoint(side .. "RIGHT", 1, y)
            e:SetHeight(1)
        else
            local x = side == "LEFT" and -1 or 1
            e:SetPoint("TOP" .. side, x, 1)
            e:SetPoint("BOTTOM" .. side, x, -1)
            e:SetWidth(1)
        end
        t[#t + 1] = e
    end
    return t
end

local function EdgeColour(edges, r, g, b, a)
    for _, e in ipairs(edges) do e:SetVertexColor(r, g, b, a or 1) end
end

-- a texture fading from alpha a1 to a2 (the newer and the older client API)
local function Fade(tex, orientation, r, g, b, a1, a2)
    if CreateColor and pcall(tex.SetGradient, tex, orientation, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2)) then return end
    if tex.SetGradientAlpha then pcall(tex.SetGradientAlpha, tex, orientation, r, g, b, a1, r, g, b, a2) end
end

local function Text(parent, size, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(ns.FONT, size, "OUTLINE")
    fs:SetShadowOffset(0, 0)
    return fs
end

-- a flat bar on the addon's dark panel colour, with a crisp border
local function Bar(parent, h)
    local b = CreateFrame("StatusBar", nil, parent)
    b:SetHeight(h)
    b:SetStatusBarTexture(WHITE)
    b:SetMinMaxValues(0, 1)
    b:SetValue(1)
    b.back = b:CreateTexture(nil, "BACKGROUND")
    b.back:SetTexture(WHITE)
    b.back:SetAllPoints()
    b.back:SetVertexColor(ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], 0.9)
    b.edges = Edges(b, "BORDER")
    EdgeColour(b.edges, 0, 0, 0, 1)
    return b
end

---------------------------------------------------------------------------
-- The game's plate: its health bar (to line things up with) and its art
---------------------------------------------------------------------------
local function FindStatusBar(frame, depth)
    if not (frame and frame.GetChildren) or depth > 3 then return nil end
    for _, c in ipairs({ frame:GetChildren() }) do
        if c.GetObjectType and c:GetObjectType() == "StatusBar" then return c end
        local found = FindStatusBar(c, depth + 1)
        if found then return found end
    end
end

local function GameFrame(plate)
    return type(plate.UnitFrame) == "table" and plate.UnitFrame or nil
end

local function HealthBar(plate)
    if not plate then return nil end
    if plate.hbBar then return plate.hbBar end
    local function Frame(v) return type(v) == "table" and v.GetObjectType and v or nil end
    local uf = GameFrame(plate)
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

-- hide the game's plate art (our plate takes its place), or show it again
local function GameArt(plate, shown)
    plate.hbHideArt = not shown
    -- the plate frame, its health bar, and whatever holds the bar (some clients
    -- draw the bar outside the plate frame, so hiding that alone isn't enough)
    local uf = GameFrame(plate)
    local bar = HealthBar(plate)
    local parts = { uf, bar, bar and bar.GetParent and bar:GetParent() ~= plate and bar:GetParent() or nil }
    for _, f in ipairs(parts) do
        if type(f) == "table" and f.SetAlpha and f ~= plate then
            f:SetAlpha(shown and 1 or 0)
            if not f.hbHooked and hooksecurefunc then
                f.hbHooked = true
                -- the game sets their alpha now and then: keep them hidden
                hooksecurefunc(f, "SetAlpha", function(self, a)
                    if plate.hbHideArt and a ~= 0 and not self.hbSetting then
                        self.hbSetting = true
                        self:SetAlpha(0)
                        self.hbSetting = false
                    end
                end)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Threat
---------------------------------------------------------------------------
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

-- paint a threat meter (ours, or the one under the game's plate)
local function PaintThreat(m, status, pct)
    if not status then
        m.pulse:Stop()
        m:Hide()
        return
    end
    local c = COLOURS[status]
    -- full when you have it (or are losing it), your % otherwise
    m:SetValue((status >= 2) and 1 or math.max(0.06, math.min(1, (pct or 50) / 100)))
    m:SetStatusBarColor(c[1], c[2], c[3])
    if status == 1 or status == 2 then
        if not m.pulse:IsPlaying() then m.pulse:Play() end
    else
        m.pulse:Stop()
        m:SetAlpha(1)
    end
    if On("threatPlatesText") and status ~= 3 and pct and ShowNumbers() then
        m.text:SetText(format("%d%%", pct))
        m.text:SetTextColor(c[1], c[2], c[3])
        m.text:Show()
    else
        m.text:Hide()
    end
    m:Show()
end

local function ThreatMeter(parent)
    local m = Bar(parent, THREAT_H)
    m:SetValue(0)
    m.pulse = m:CreateAnimationGroup()
    local a = m.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.45)
        a:SetDuration(0.6)
        a:SetSmoothing("IN_OUT")
    end
    m.pulse:SetLooping("BOUNCE")
    m.text = Text(m, 8)
    m.text:SetPoint("LEFT", m, "RIGHT", 4, 0)
    m:Hide()
    return m
end

---------------------------------------------------------------------------
-- Our plate
---------------------------------------------------------------------------
local function Build(plate)
    if plate.hb then return plate.hb end
    local d = CreateFrame("Frame", nil, plate)
    d:SetSize(W, HP_H)
    d:SetPoint("CENTER", plate, "CENTER", 0, 0)
    local base = (plate.GetFrameLevel and plate:GetFrameLevel() or 1) + 5
    d:SetFrameLevel(base)
    -- the bar's dark panel (on the plate itself, so the "just lost" chunk can show above it)
    d.back = d:CreateTexture(nil, "BACKGROUND")
    d.back:SetTexture(WHITE)
    d.back:SetAllPoints()
    d.back:SetVertexColor(0.04, 0.04, 0.05, 0.95) -- the empty part: clearly dark
    -- the health you've just knocked off: a pale chunk that drains away after a moment
    d.trail = CreateFrame("StatusBar", nil, d)
    d.trail:SetAllPoints()
    d.trail:SetStatusBarTexture(WHITE)
    d.trail:SetMinMaxValues(0, 1)
    d.trail:SetValue(1)
    d.trail:SetStatusBarColor(0.55, 0.10, 0.08, 0.9) -- the health just lost: a darker red that drains
    d.trail:SetFrameLevel(base + 1)
    -- the health bar
    d.hp = CreateFrame("StatusBar", nil, d)
    d.hp:SetAllPoints()
    d.hp:SetStatusBarTexture(WHITE)
    d.hp:SetMinMaxValues(0, 1)
    d.hp:SetValue(1)
    d.hp:SetFrameLevel(base + 2)
    d.sheen = d.hp:CreateTexture(nil, "OVERLAY")
    d.sheen:SetTexture(WHITE)
    d.sheen:SetPoint("TOPLEFT")
    d.sheen:SetPoint("TOPRIGHT")
    d.sheen:SetHeight(HP_H / 2)
    Fade(d.sheen, "VERTICAL", 1, 1, 1, 0, 0.10) -- (bottom to top)
    -- the border: black, your threat colour in a fight, gold on your target
    d.frame = CreateFrame("Frame", nil, d)
    d.frame:SetAllPoints()
    d.frame:SetFrameLevel(base + 4)
    d.edges = Edges(d.frame, "OVERLAY")
    EdgeColour(d.edges, 0, 0, 0, 1)
    d.hpText = Text(d.frame, 8)
    d.hpText:SetPoint("RIGHT", d, "RIGHT", -3, 1)
    -- your threat, built into the bar: a line along its bottom, filled to your threat
    d.threat = CreateFrame("StatusBar", nil, d)
    d.threat:SetPoint("BOTTOMLEFT", d, "BOTTOMLEFT", 0, 0)
    d.threat:SetPoint("BOTTOMRIGHT", d, "BOTTOMRIGHT", 0, 0)
    d.threat:SetHeight(THREAT_H)
    d.threat:SetStatusBarTexture(WHITE)
    d.threat:SetMinMaxValues(0, 1)
    d.threat:SetValue(0)
    d.threat:SetFrameLevel(base + 3)
    d.threat.back = d.threat:CreateTexture(nil, "BACKGROUND")
    d.threat.back:SetTexture(WHITE)
    d.threat.back:SetAllPoints()
    d.threat.back:SetVertexColor(0, 0, 0, 0.55)
    d.threat.pulse = d.frame:CreateAnimationGroup() -- (losing it: the coloured border breathes)
    local a = d.threat.pulse:CreateAnimation("Alpha")
    if a then
        a:SetFromAlpha(1)
        a:SetToAlpha(0.45)
        a:SetDuration(0.6)
        a:SetSmoothing("IN_OUT")
    end
    d.threat.pulse:SetLooping("BOUNCE")
    d.threat.text = Text(d.frame, 8)
    d.threat.text:SetPoint("LEFT", d, "RIGHT", 4, 0)
    d.threat:Hide()
    -- your target: a soft gold glow round the bar
    d.glow = d:CreateTexture(nil, "BACKGROUND", nil, -1)
    d.glow:SetTexture(WHITE)
    d.glow:SetBlendMode("ADD")
    d.glow:SetPoint("TOPLEFT", d, "TOPLEFT", -4, 4)
    d.glow:SetPoint("BOTTOMRIGHT", d, "BOTTOMRIGHT", 4, -4)
    d.glow:Hide()
    -- the name line, above the bar: the level, then the name
    d.level = Text(d.frame, 9)
    d.level:SetPoint("BOTTOMLEFT", d, "TOPLEFT", 0, 3)
    d.name = Text(d.frame, 9)
    d.name:SetPoint("LEFT", d.level, "RIGHT", 4, 0)
    d.name:SetPoint("RIGHT", d, "RIGHT", 0, 0)
    d.name:SetJustifyH("LEFT")
    d.name:SetWordWrap(false)
    -- the raid marker, left of the bar
    d.raid = d.frame:CreateTexture(nil, "OVERLAY")
    d.raid:SetSize(16, 16)
    d.raid:SetPoint("RIGHT", d, "LEFT", -5, 0)
    d.raid:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    d.raid:Hide()
    -- the cast bar under it
    d.cast = Bar(d, CAST_H)
    d.cast:SetValue(0)
    d.cast:SetPoint("TOPLEFT", d, "BOTTOMLEFT", 0, -3)
    d.cast:SetPoint("TOPRIGHT", d, "BOTTOMRIGHT", 0, -3)
    d.cast.icon = d.cast:CreateTexture(nil, "OVERLAY")
    d.cast.icon:SetSize(CAST_H + 4, CAST_H + 4)
    d.cast.icon:SetPoint("RIGHT", d.cast, "LEFT", -3, 0)
    d.cast.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    d.cast.text = Text(d.cast, 7)
    d.cast.text:SetPoint("CENTER", d.cast, "CENTER", 0, 0)
    d.cast.text:SetWidth(W - 8)
    d.cast.text:SetWordWrap(false)
    d.cast:Hide()
    d.cast:SetScript("OnUpdate", function(self)
        if not self.ends then return end
        local now = GetTime() * 1000
        if now >= self.ends then
            self.ends = nil
            self:Hide()
            return
        end
        local share = (now - self.starts) / math.max(1, self.ends - self.starts)
        self:SetValue(self.channel and (1 - share) or share)
    end)
    -- your debuffs, above the name
    d.debuffs = CreateFrame("Frame", nil, d)
    d.debuffs:SetHeight(ICON_H)
    d.debuffs:SetPoint("BOTTOMLEFT", d, "TOPLEFT", 0, 16)
    d.debuffs:SetPoint("BOTTOMRIGHT", d, "TOPRIGHT", 0, 16)
    d.debuffs.icons = {}
    -- the health bar slides to its new value; the lost chunk drains after a moment
    d.shown, d.goal, d.trailAt = 1, 1, 0
    d:SetScript("OnUpdate", function(self, dt)
        if self.secret then return end -- (hidden figures: the game smooths the bar itself)
        dt = math.min(dt or 0, 0.1)
        if self.shown ~= self.goal then
            local step = (self.goal - self.shown) * math.min(1, dt * SMOOTH)
            if math.abs(self.goal - self.shown) < 0.002 then self.shown = self.goal else self.shown = self.shown + step end
            self.hp:SetValue(self.shown)
        end
        local trail = self.trail:GetValue() or 1
        if trail > self.shown and GetTime() >= self.trailAt then
            self.trail:SetValue(math.max(self.shown, trail - dt * TRAIL_SPEED))
        elseif trail < self.shown then
            self.trail:SetValue(self.shown)
        end
    end)
    d.plate = plate
    d:Hide()
    plate.hb = d
    return d
end

-- (the cast bar sits under the health bar; the threat line is inside it now)
local function PlaceCast() end

local DIFFICULTY = { impossible = "ff4040", hard = "ff8040", normal = "ffd200", easy = "40c040", trivial = "808080" }

-- the name (as it comes - it may be hidden from us) and the level, coloured like quest difficulty
local function Names(d, unit)
    d.name:SetText(Raw(UnitName, unit) or "")
    local level = Raw(UnitLevel, unit)
    if Secret(level) then
        d.level:SetText("")
        return
    end
    local class = Safe(UnitClassification, unit)
    if Secret(class) then class = nil end
    local tag = (class == "elite" or class == "worldboss") and "+" or ((class == "rare" or class == "rareelite") and "R" or "")
    if type(level) == "number" and level > 0 then
        local diff = ns.QuestDifficulty and ns.QuestDifficulty(level, UnitLevel("player")) or "normal"
        d.level:SetText(format("|cff%s%d%s|r", DIFFICULTY[diff] or "ffd200", level, tag))
    else
        d.level:SetText("|cffff4040??|r") -- far above you
    end
end

local function HealthColour(unit)
    if Safe(UnitIsPlayer, unit) == true then
        local _, class = Safe(UnitClass, unit)
        local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if c then return c.r, c.g, c.b end
    end
    if Safe(UnitIsTapDenied, unit) == true then return unpack(REACTION.tapped) end
    local r = Safe(UnitReaction, unit, "player")
    if type(r) == "number" then
        if r <= 3 then return unpack(REACTION.hostile) end
        if r == 4 then return unpack(REACTION.neutral) end
        return unpack(REACTION.friendly)
    end
    return unpack(Safe(UnitCanAttack, "player", unit) == true and REACTION.hostile or REACTION.friendly)
end

-- the enemy's health as a share: from the game's own health bar on the plate (it
-- always has the right figure, whatever the client tells addons), else from the unit
local function HealthShare(d, unit)
    local gb = d.plate and HealthBar(d.plate)
    if gb and gb.GetValue and gb.GetMinMaxValues then
        local v = gb:GetValue()
        local lo, hi = gb:GetMinMaxValues()
        if not (Secret(v) or Secret(lo) or Secret(hi)) and type(v) == "number" and type(lo) == "number" and type(hi) == "number" and hi > lo then
            return math.max(0, math.min(1, (v - lo) / (hi - lo))), "the game's bar"
        end
    end
    local hp, max = Safe(UnitHealth, unit) or 0, Safe(UnitHealthMax, unit) or 1
    if max <= 0 then max = 1 end
    return math.max(0, math.min(1, hp / max)), "the unit"
end

-- the health % as the game formats it (works with hidden figures too)
local function HiddenPercent(d, unit)
    if not (UnitHealthPercent and CurveConstants and CurveConstants.ScaleTo100) then return d.hpText:SetText("") end
    if not pcall(function() d.hpText:SetFormattedText("%d%%", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)) end) then
        d.hpText:SetText("")
    end
end

local function Health(d, unit, instant)
    local hp, max = Raw(UnitHealth, unit), Raw(UnitHealthMax, unit)
    if Secret(hp) or Secret(max) then
        -- hidden figures: straight into the bar, with the game's own smoothing
        d.secret = true
        d.hp:SetMinMaxValues(0, max)
        local ease = Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut
        if not (ease and pcall(d.hp.SetValue, d.hp, hp, ease)) then d.hp:SetValue(hp) end
        d.trail:Hide()
        d.unitShown = unit
        HiddenPercent(d, unit)
        return
    end
    if d.secret then
        -- (real figures again, after hidden ones)
        d.secret = false
        d.hp:SetMinMaxValues(0, 1)
        d.trail:Show()
        instant = true
    end
    local share = HealthShare(d, unit)
    if instant or d.unitShown ~= unit then
        -- a new enemy on this plate: straight to its health, no slide
        d.unitShown = unit
        d.shown, d.goal = share, share
        d.hp:SetValue(share)
        d.trail:SetValue(share)
    elseif share ~= d.goal then
        if share < d.goal then d.trailAt = GetTime() + TRAIL_WAIT end -- it was hit: the lost chunk waits, then drains
        d.goal = share
    end
    local pct = math.floor(share * 100 + 0.5)
    d.hpText:SetText((pct < 100 and share > 0) and (pct .. "%") or "")
end

local function Colour(d, unit)
    local ok, r, g, b = pcall(HealthColour, unit)
    if not ok or Secret(r) then r, g, b = unpack(Safe(UnitCanAttack, "player", unit) == true and REACTION.hostile or REACTION.friendly) end
    d.hp:SetStatusBarColor(r, g, b)
end

local function Cast(d, unit)
    local name, _, icon, starts, ends, _, _, notInterruptible = nil, nil, nil, nil, nil, nil, nil, nil
    local channel = false
    if UnitCastingInfo then name, _, icon, starts, ends, _, _, notInterruptible = Safe(UnitCastingInfo, unit) end
    if not name and UnitChannelInfo then
        name, _, icon, starts, ends, _, notInterruptible = Safe(UnitChannelInfo, unit)
        channel = name ~= nil
    end
    if not (name and starts and ends) then
        d.cast.ends = nil
        d.cast:Hide()
        return
    end
    d.cast.starts, d.cast.ends, d.cast.channel = starts, ends, channel
    local c = notInterruptible and { 0.55, 0.55, 0.58 } or ns.color.gold
    d.cast:SetStatusBarColor(c[1], c[2], c[3])
    d.cast.icon:SetTexture(icon)
    d.cast.text:SetText(name)
    PlaceCast(d)
    d.cast:Show()
end

local function Raid(d, unit)
    local i = GetRaidTargetIndex and Safe(GetRaidTargetIndex, unit)
    if i and SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(d.raid, i)
        d.raid:Show()
    else
        d.raid:Hide()
    end
end

local function Border(d)
    local g = ns.color.gold
    local c = d.status and COLOURS[d.status]
    if c then EdgeColour(d.edges, c[1], c[2], c[3], 1)
    elseif d.isTarget then EdgeColour(d.edges, g[1], g[2], g[3], 1)
    else EdgeColour(d.edges, 0, 0, 0, 1) end
end

local function Target(d, unit)
    local isTarget = Safe(UnitIsUnit, unit, "target") == true
    local g = ns.color.gold
    d.isTarget = isTarget
    if isTarget then
        d.glow:SetVertexColor(g[1], g[2], g[3], 0.22)
        d.glow:Show()
    else
        d.glow:Hide()
    end
    Border(d)
    -- the other plates dim a little while you have a target
    d:SetAlpha((isTarget or not UnitExists("target")) and 1 or DIM)
end

---------------------------------------------------------------------------
-- Your debuffs
---------------------------------------------------------------------------
local function MyDebuffs(unit)
    local out = {}
    for i = 1, 40 do
        local icon, count, duration, expires
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a = Raw(C_UnitAuras.GetAuraDataByIndex, unit, i, "HARMFUL|PLAYER")
            if type(a) ~= "table" then break end
            icon, count, duration, expires = a.icon, a.applications, a.duration, a.expirationTime
        elseif UnitAura then
            local name, tex, c, _, dur, e = Raw(UnitAura, unit, i, "HARMFUL|PLAYER")
            if name == nil then break end
            icon, count, duration, expires = tex, c, dur, e
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
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexCoord(0.08, 0.92, 0.22, 0.78)
    b.edges = Edges(b, "OVERLAY")
    EdgeColour(b.edges, 0, 0, 0, 1)
    b.cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
    b.cd:SetAllPoints()
    if b.cd.SetDrawEdge then b.cd:SetDrawEdge(false) end
    if b.cd.SetHideCountdownNumbers then b.cd:SetHideCountdownNumbers(true) end
    if b.cd.SetReverse then b.cd:SetReverse(true) end
    if b.cd.SetSwipeColor then b.cd:SetSwipeColor(0, 0, 0, 0.55) end
    b.count = Text(b, 9)
    b.count:SetPoint("BOTTOMRIGHT", 2, -2)
    row.icons[i] = b
    return b
end

-- fill a row of debuff icons (centred), and hide it when there are none
local function FillDebuffs(row, list)
    local width = #list * ICON_W + math.max(0, #list - 1) * 3
    for i, dd in ipairs(list) do
        local b = DebuffIcon(row, i)
        b:ClearAllPoints()
        b:SetPoint("BOTTOMLEFT", row, "BOTTOM", -width / 2 + (i - 1) * (ICON_W + 3), 0)
        b.tex:SetTexture(dd.icon)
        -- (a figure the client hides can't be compared: no stack count or timer for it)
        local count = not Secret(dd.count) and dd.count or nil
        b.count:SetText((count and count > 1) and count or "")
        local timed = not (Secret(dd.duration) or Secret(dd.expires))
        if timed and dd.duration and dd.duration > 0 and dd.expires then
            b.cd:SetCooldown(dd.expires - dd.duration, dd.duration)
            b.cd:Show()
        else
            b.cd:Hide()
        end
        b:Show()
    end
    for i = #list + 1, #row.icons do row.icons[i]:Hide() end
    row:SetShown(#list > 0)
end

---------------------------------------------------------------------------
-- The game's own nameplate debuffs, on our plate: exactly what the original
-- plates show (the game keeps them up to date), moved above our name
---------------------------------------------------------------------------
local function GameAuras(plate)
    local uf = GameFrame(plate)
    if not uf then return nil end
    for _, key in ipairs({ "BuffFrame", "AurasFrame", "DebuffFrame" }) do
        local f = uf[key]
        if type(f) == "table" and f.SetParent and f.GetParent then return f end
    end
end

-- onto our plate (d), or back to the game's (d nil)
local function MoveAuras(plate, d)
    local f = GameAuras(plate)
    if not f then return false end
    if d then
        if not f.hbHome then
            -- remember where the game had it, to put it back
            f.hbHome = { parent = f:GetParent(), points = {} }
            for i = 1, (f.GetNumPoints and f:GetNumPoints() or 0) do f.hbHome.points[i] = { f:GetPoint(i) } end
        end
        if f:GetParent() ~= d then f:SetParent(d) end
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", d, "TOPLEFT", 0, 16)
        f:SetAlpha(1)
        if f.SetFrameLevel and d.frame.GetFrameLevel then f:SetFrameLevel(d.frame:GetFrameLevel() + 2) end
        f:Show()
        return true
    end
    local home = f.hbHome
    if home then
        f:SetParent(home.parent)
        f:ClearAllPoints()
        for _, p in ipairs(home.points) do f:SetPoint(unpack(p)) end
        f.hbHome = nil
    end
    return true
end

---------------------------------------------------------------------------
-- The game's plate, kept (the style off): just the threat bar under it, and
-- your debuffs above it if you want them instead of the game's
---------------------------------------------------------------------------
local function UnderBar(plate)
    if plate.hbThreat then return plate.hbThreat end
    local bar = HealthBar(plate)
    local m = ThreatMeter(plate)
    m:SetHeight(4)
    if bar then
        m:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
        m:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -3)
    else
        m:SetPoint("TOP", plate, "CENTER", 0, -8)
        m:SetWidth(100)
    end
    m:SetFrameLevel((plate.GetFrameLevel and plate:GetFrameLevel() or 1) + 10)
    plate.hbThreat = m
    return m
end

local function TheirDebuffs(plate, shown)
    local uf = GameFrame(plate)
    local theirs = uf and (uf.BuffFrame or uf.AurasFrame or uf.DebuffFrame)
    if type(theirs) == "table" and theirs.SetAlpha then theirs:SetAlpha(shown and 1 or 0) end
end

local function GameDebuffs(plate, unit)
    local mine = ns.db and ns.db.threatPlatesDebuffs == true
    TheirDebuffs(plate, not mine)
    local list = (mine and Safe(UnitCanAttack, "player", unit) == true) and MyDebuffs(unit) or {}
    local row = plate.hbDebuffs
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
    local uf = GameFrame(plate)
    local name = uf and (uf.name or uf.Name)
    local bar = HealthBar(plate) or plate
    local top = (type(name) == "table" and name.IsShown and name:IsShown()) and name or bar
    row:ClearAllPoints()
    row:SetPoint("BOTTOM", top, "TOP", 0, 4)
    row:SetPoint("LEFT", bar, "LEFT", 0, 0)
    row:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
    FillDebuffs(row, list)
end

---------------------------------------------------------------------------
-- Updating
---------------------------------------------------------------------------
local function PlateFor(unit)
    if not (unit and C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return nil end
    local plate = Safe(C_NamePlate.GetNamePlateForUnit, unit)
    if not plate or (plate.IsForbidden and plate:IsForbidden()) then return nil end
    return plate
end

local function Update(unit, what)
    local plate = PlateFor(unit)
    if not plate then return end
    local status, pct
    if On("threatPlates") then
        local ok, s1, p1 = pcall(Threat, unit)
        if ok then status, pct = s1, p1 end
    end
    if Secret(pct) then pct = nil end
    if Styled() then
        GameArt(plate, false)
        if plate.hbThreat then plate.hbThreat:Hide() end
        if plate.hbDebuffs then plate.hbDebuffs:Hide() end
        local d = Build(plate)
        d.unit = unit
        -- the game's health bar moves: ours follows, straight away
        local gb = HealthBar(plate)
        if gb and hooksecurefunc and not gb.hbWatch then
            gb.hbWatch = true
            local function Follow()
                local dd = plate.hb
                if dd and dd:IsShown() and dd.unitShown and Styled() then Try(Health, dd, dd.unitShown) end
            end
            if gb.SetValue then hooksecurefunc(gb, "SetValue", Follow) end
            if gb.SetMinMaxValues then hooksecurefunc(gb, "SetMinMaxValues", Follow) end
        end
        if what ~= "threat" then
            Try(Colour, d, unit)
            Try(Health, d, unit, what == "new")
            Try(Names, d, unit)
            Try(Raid, d, unit)
            Try(Target, d, unit)
            Try(function()
                if MoveAuras(plate, d) then
                    d.debuffs:Hide() -- the game's own debuffs are on the plate instead
                else
                    FillDebuffs(d.debuffs, Safe(UnitCanAttack, "player", unit) == true and MyDebuffs(unit) or {})
                end
            end)
        end
        d.status = status
        PaintThreat(d.threat, status, pct)
        -- the health bar in the threat colour; its own colour back once the fight's over
        if status and On("threatHealth") then
            local c = COLOURS[status]
            d.hp:SetStatusBarColor(c[1], c[2], c[3])
            d.threatTinted = true
        elseif d.threatTinted then
            d.threatTinted = nil
            Try(Colour, d, unit)
        end
        if not (status == 1 or status == 2) then d.frame:SetAlpha(1) end -- (only yellow breathes)
        Border(d)
        d:Show()
    else
        if plate.hb then plate.hb:Hide() end
        Try(MoveAuras, plate, nil)
        GameArt(plate, true)
        local m = (status or plate.hbThreat) and UnderBar(plate)
        if m then PaintThreat(m, status, pct) end
        GameDebuffs(plate, unit)
    end
end

-- which enemy each plate is showing: written down as the game hands plates out
-- (some clients don't put the unit on the plate itself)
local unitOf = {} -- plate -> "nameplateN"

local function UnitOn(plate)
    if not plate then return nil end
    local uf = GameFrame(plate)
    return unitOf[plate] or plate.namePlateUnitToken or (uf and type(uf.unit) == "string" and uf.unit) or nil
end

local function EachPlate(fn)
    for plate, unit in pairs(unitOf) do
        fn(unit, plate)
    end
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end
    for _, plate in ipairs(Safe(C_NamePlate.GetNamePlates) or {}) do
        local unit = not unitOf[plate] and UnitOn(plate)
        if unit then fn(unit, plate) end
    end
end

-- look through the nameplate slots for plates we haven't written down (after a /reload, say)
local function Sweep()
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return end
    for i = 1, 40 do
        local unit = "nameplate" .. i
        local plate = Safe(C_NamePlate.GetNamePlateForUnit, unit)
        if plate and unitOf[plate] ~= unit then
            unitOf[plate] = unit
            Update(unit, "new")
        end
    end
    -- and drop any that have gone
    for plate, unit in pairs(unitOf) do
        if Safe(C_NamePlate.GetNamePlateForUnit, unit) ~= plate then unitOf[plate] = nil end
    end
end

-- your target's plate and its unit
local function TargetPlate()
    for plate, unit in pairs(unitOf) do
        if Safe(UnitIsUnit, unit, "target") == true then return plate, unit end
    end
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, "target")
    return plate, UnitOn(plate)
end

local function UpdateAll(what)
    EachPlate(function(unit) Update(unit, what) end)
end
ns.UpdateThreatPlates = UpdateAll

-- an event for one nameplate unit: just that part of its plate
local function OnUnit(fn)
    return function(_, unit)
        if not (unit and unit:find("^nameplate")) then return end
        local plate = PlateFor(unit)
        local d = plate and plate.hb
        if d and d:IsShown() and Styled() then fn(d, unit) else Update(unit) end
    end
end

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
    -- (a figure the client hides from addons can't be printed: it says so)
    local function Show(v) if Secret(v) then return "hidden" end return tostring(v) end
    local P = function(t) ns.Print("|cff999999plates|r " .. t) end
    P(format("style %s, threat %s, threat API: detailed %s, situation %s", Show(Styled()), Show(On("threatPlates")),
        Show(UnitDetailedThreatSituation ~= nil), Show(UnitThreatSituation ~= nil)))
    if not UnitExists("target") then return P("no target - target an enemy and try again") end
    local plate, unit = TargetPlate()
    if not plate then return P("your target has no nameplate showing (press V for enemy nameplates)") end
    if plate.IsForbidden and plate:IsForbidden() then
        return P("|cffff6666your client won't let addons touch this nameplate (it's 'forbidden')|r")
    end
    P(format("plate found, unit %s (the game's own label on it: %s)", Show(unit), Show(plate.namePlateUnitToken)))
    local bar = HealthBar(plate)
    P("the game's health bar: " .. (bar and (plate.hbBarFrom or "?") or "not found"))
    if UnitDetailedThreatSituation then
        local tanking, s, scaled, raw, value = Safe(UnitDetailedThreatSituation, "player", "target")
        P(format("your threat on it: tanking %s, status %s, %s%%, raw %s, value %s", Show(tanking), Show(s),
            Show(scaled), Show(raw), Show(value)))
    end
    local status = unit and Threat(unit)
    P(format("so its threat bar is: %s; our plate shown %s", status and ({ [3] = "red", [2] = "yellow", [1] = "yellow", [0] = "green" })[status]
        or "not shown (not fighting you)", Show(plate.hb and plate.hb:IsShown())))
    P(format("health as the game reports it: target %s / %s, its plate (%s) %s / %s", Show(Safe(UnitHealth, "target")),
        Show(Safe(UnitHealthMax, "target")), Show(unit), Show(unit and Safe(UnitHealth, unit)), Show(unit and Safe(UnitHealthMax, unit))))
    local d = plate.hb
    if d then
        local okShare, share, from = pcall(HealthShare, d, unit or "target")
        if not okShare then share, from = nil, "an error: " .. Show(share) end
        local gb = HealthBar(plate)
        local gv = gb and gb.GetValue and gb:GetValue()
        local glo, ghi = nil, nil
        if gb and gb.GetMinMaxValues then glo, ghi = gb:GetMinMaxValues() end
        P(format("the game's bar: %s of %s-%s; our health %s (from %s)", Show(gv), Show(glo), Show(ghi), Show(share), Show(from)))
        P(format("our health bar: showing %s, heading to %s, lost chunk %s, text '%s', hidden figures %s", Show(d.hp:GetValue()), Show(d.goal),
            Show(d.trail:GetValue()), Show(d.hpText:GetText()), Show(d.secret)))
    end
end

-- /hb plates test: your target's plate shows each threat colour in turn, two seconds each
function ns.ThreatPlatesTest()
    local plate, targetUnit = TargetPlate()
    if not plate then
        return ns.Print("Nameplates: target an enemy with its nameplate showing (V), then try again.")
    end
    if plate.IsForbidden and plate:IsForbidden() then
        return ns.Print("Nameplates: your client won't let addons draw on this nameplate.")
    end
    local unit = targetUnit or "target"
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
    -- once: the game's own debuffs back on its plates (ours show on Hearthbound plates)
    if not ns.db.threatPlatesV3 then
        ns.db.threatPlatesV3 = true
        ns.db.threatPlatesDebuffs = false
    end
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit)
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, unit)
        if plate then
            -- (a plate moving to another enemy: forget whichever unit it had)
            for p, u in pairs(unitOf) do if u == unit and p ~= plate then unitOf[p] = nil end end
            unitOf[plate] = unit
        end
        Update(unit, "new")
    end)
    ns.On("NAME_PLATE_UNIT_REMOVED", function(_, unit)
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and Safe(C_NamePlate.GetNamePlateForUnit, unit)
        if not plate then
            for p, u in pairs(unitOf) do if u == unit then plate = p end end
        end
        if not plate then return end
        unitOf[plate] = nil
        if plate.hb then
            plate.hb.cast.ends = nil
            plate.hb.cast:Hide()
            plate.hb.threat.pulse:Stop()
            Try(MoveAuras, plate, nil)
            plate.hb:Hide()
        end
        if plate.hbThreat then
            plate.hbThreat.pulse:Stop()
            plate.hbThreat:Hide()
        end
        if plate.hbDebuffs then plate.hbDebuffs:Hide() end
    end)
    -- the parts that change: health, names and levels, markers, casts, debuffs, threat
    for _, e in ipairs({ "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_HEALTH_FREQUENT" }) do
        ns.On(e, OnUnit(function(d, unit) Try(Health, d, unit) end))
    end
    for _, e in ipairs({ "UNIT_NAME_UPDATE", "UNIT_LEVEL", "UNIT_CLASSIFICATION_CHANGED", "UNIT_FACTION" }) do
        ns.On(e, OnUnit(function(d, unit)
            Try(Names, d, unit)
            Try(Colour, d, unit)
            Try(Health, d, unit)
        end))
    end
    for _, e in ipairs({ "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
                         "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
                         "UNIT_SPELLCAST_CHANNEL_UPDATE" }) do
        ns.On(e, OnUnit(function(d, unit) Try(Cast, d, unit) end))
    end
    ns.On("UNIT_AURA", function(_, unit) if unit and unit:find("^nameplate") then Update(unit) end end)
    ns.On("RAID_TARGET_UPDATE", function() EachPlate(function(unit, plate) if plate.hb then Raid(plate.hb, unit) end end) end)
    ns.On("UNIT_THREAT_LIST_UPDATE", function(_, unit) if unit and unit:find("^nameplate") then Update(unit, "threat") end end)
    ns.On("UNIT_THREAT_SITUATION_UPDATE", function() UpdateAll("threat") end)
    ns.On("PLAYER_TARGET_CHANGED", function()
        EachPlate(function(unit, plate) if plate.hb and Styled() then Target(plate.hb, unit) end end)
        C_Timer.After(0, UpdateAll)
        UnitFrameGlows()
    end)
    ns.On("PLAYER_REGEN_ENABLED", function() C_Timer.After(0.2, UpdateAll) end)
    ns.On("PLAYER_REGEN_DISABLED", function() UpdateAll("threat") end)
    ns.On("PLAYER_ENTERING_WORLD", function()
        UnitFrameGlows()
        C_Timer.After(0.5, Sweep)
    end)
    -- threat changes all the time in a fight: check every quarter second while you're in one;
    -- and health on every plate ten times a second (some clients send few health events)
    local elapsed, hpElapsed, sweepElapsed = 0, 0, 0
    local function PlateHealth(unit, plate)
        local d = plate.hb
        if d and d:IsShown() and not (plate.IsForbidden and plate:IsForbidden()) then Try(Health, d, unit) end
    end
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(_, dt)
        elapsed, hpElapsed = elapsed + dt, hpElapsed + dt
        sweepElapsed = sweepElapsed + dt
        if sweepElapsed >= 1 then
            sweepElapsed = 0
            Sweep()
        end
        if hpElapsed >= 0.1 and Styled() then
            hpElapsed = 0
            EachPlate(PlateHealth)
        end
        if elapsed < TICK then return end
        elapsed = 0
        if InCombatLockdown() or (UnitAffectingCombat and UnitAffectingCombat("player")) then UpdateAll("threat") end
    end)
    table.insert(ns.refreshers, function()
        UpdateAll()
        UnitFrameGlows()
    end)
end)
