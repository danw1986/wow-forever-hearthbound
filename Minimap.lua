local ADDON_NAME, ns = ...

-- Minimap button: left-click settings, right-click quests, drag to move
-- around the minimap, hover for a quick summary.

local format = string.format
local RADIUS_OFFSET = 10

local button

local function UpdatePosition()
    local angle = math.rad(ns.db.minimapAngle or 220)
    local radius = (Minimap:GetWidth() / 2) + RADIUS_OFFSET
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    ns.db.minimapAngle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
    UpdatePosition()
end

local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("|cffc79c6eHearthbound|r - Leveling Companion")
    local level = UnitLevel("player")
    local cur, max = UnitXP("player"), UnitXPMax("player")
    if max and max > 0 then
        GameTooltip:AddDoubleLine(format("Level %d", level), format("%.1f%%", cur / max * 100), 1, 0.82, 0, 1, 1, 1)
    end
    local s = ns.Session()
    local elapsed = math.max(1, time() - s.start)
    if (s.xp or 0) > 0 and elapsed >= 30 then
        local perSecond = s.xp / elapsed
        GameTooltip:AddDoubleLine("XP / hour", ns.Short(perSecond * 3600), 0.7, 0.7, 0.7, 1, 1, 1)
        GameTooltip:AddDoubleLine("Time to level", ns.Duration((max - cur) / perSecond), 0.7, 0.7, 0.7, 1, 1, 1)
    end
    local rested = GetXPExhaustion() or 0
    if rested > 0 then
        GameTooltip:AddDoubleLine("Rested", ns.Short(rested), 0.7, 0.7, 0.7, 0.44, 0.61, 1)
    end
    GameTooltip:AddDoubleLine("Session", format("%d quests, %d kills", s.quests or 0, s.kills or 0), 0.7, 0.7, 0.7, 1, 1, 1)
    GameTooltip:AddDoubleLine("Gold", ns.Money((s.income or 0) - (s.spent or 0), true), 0.7, 0.7, 0.7, 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffffd200Left-click|r settings   |cffffd200Right-click|r quests", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("|cffffd200Drag|r to move", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

local function Build()
    button = CreateFrame("Button", "HearthboundMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetSize(20, 20)
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ns.SpellIcon(6673) or "Interface\\Icons\\Ability_Warrior_BattleShout")
    icon:SetSize(17, 17)
    icon:SetPoint("TOPLEFT", 7, -6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    button:SetScript("OnClick", function(_, mouse)
        if mouse == "RightButton" then
            ns.ToggleOptions("quests")
        else
            ns.ToggleOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", OnDragUpdate)
        GameTooltip:Hide()
    end)
    button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    button:SetScript("OnEnter", ShowTooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- a ring of dots around the icon that fills with your XP for the level
    local DOTS, RING_RADIUS = 24, 13
    button.dots = {}
    for i = 1, DOTS do
        local angle = math.rad(90 - (i - 1) * 360 / DOTS) -- from the top, clockwise
        local dot = button:CreateTexture(nil, "OVERLAY", nil, 2)
        dot:SetTexture("Interface\\Buttons\\WHITE8X8")
        dot:SetSize(2, 2)
        dot:SetPoint("CENTER", icon, "CENTER", math.cos(angle) * RING_RADIUS, math.sin(angle) * RING_RADIUS)
        button.dots[i] = dot
    end

    UpdatePosition()
end

local function UpdateRing()
    if not button or not button.dots then return end
    local cur, max = UnitXP("player"), UnitXPMax("player")
    local filled = (ns.db.minimapRing and max and max > 0) and math.floor(cur / max * #button.dots + 0.5) or 0
    for i, dot in ipairs(button.dots) do
        dot:SetShown(ns.db.minimapRing)
        if i <= filled then dot:SetVertexColor(0.70, 0.40, 1, 1) else dot:SetVertexColor(0.2, 0.2, 0.22, 0.9) end
    end
end

local function Refresh()
    if not button then return end
    button:SetShown(ns.db.showMinimap)
    UpdateRing()
end
table.insert(ns.refreshers, Refresh)

table.insert(ns.inits, function()
    if not Minimap then return end
    Build()
    Refresh()
    ns.On("PLAYER_XP_UPDATE", UpdateRing)
    ns.On("PLAYER_LEVEL_UP", function() C_Timer.After(0.5, UpdateRing) end)
end)
