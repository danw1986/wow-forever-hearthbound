local ADDON_NAME, ns = ...

-- The levelling guide on the map: the next few steps as numbered pins on the
-- world map (and the next three on the minimap), joined by a dotted trail so
-- you can see the way the route goes. Drawn with the HereBeDragons pins
-- library Questie ships, like the quest pins.

local format = string.format

local REF = "HearthboundGuidePins"
local WORLD_STEPS, MINIMAP_STEPS = 6, 3
local TRAIL_SPACING = 1.6 -- map percent between trail dots
local TRAIL_MAX = 140
local PIN_TEXTURE = "Interface\\AddOns\\Hearthbound\\Media\\Cards\\Gem"
local GOLD = { 1, 0.82, 0.35 }
local CURRENT = { 1, 0.45, 0.2 }

local Pins
local function Library()
    if Pins == nil then
        local stub = rawget(_G, "LibStub")
        Pins = stub and stub("HereBeDragonsQuestie-Pins-2.0", true) or false
    end
    return Pins or nil
end

local stepPool, miniPool, dotPool = {}, {}, {}

local function StepPin(pool, i, size)
    local p = pool[i]
    if not p then
        p = CreateFrame("Button", nil, UIParent)
        p:SetSize(size, size)
        p.gem = p:CreateTexture(nil, "ARTWORK")
        p.gem:SetAllPoints()
        p.gem:SetTexture(PIN_TEXTURE)
        p.num = p:CreateFontString(nil, "OVERLAY")
        p.num:SetFont(ns.FONT, math.floor(size * 0.55), "OUTLINE")
        p.num:SetPoint("CENTER", 0, 0)
        p:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(format("Guide step %d", self.index or 0), 1, 0.82, 0.35)
            GameTooltip:AddLine(self.title or "", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        p:SetScript("OnLeave", function() GameTooltip:Hide() end)
        pool[i] = p
    end
    return p
end

local function Dot(i)
    local d = dotPool[i]
    if not d then
        d = CreateFrame("Frame", nil, UIParent)
        d:SetSize(5, 5)
        d.tex = d:CreateTexture(nil, "ARTWORK")
        d.tex:SetAllPoints()
        d.tex:SetTexture(PIN_TEXTURE)
        d.tex:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], 0.85)
        dotPool[i] = d
    end
    return d
end

local lastSignature

local function Clear(lib)
    lib:RemoveAllWorldMapIcons(REF)
    lib:RemoveAllMinimapIcons(REF)
end

function ns.RefreshGuideMap()
    local lib = Library()
    if not lib then return end
    local wanted = ns.db.guide and ns.db.guideMapPins and ns.GuideRouteAhead
    local steps = wanted and ns.GuideRouteAhead(WORLD_STEPS) or {}
    -- only redraw when the route ahead changed
    local parts = {}
    for _, e in ipairs(steps) do parts[#parts + 1] = e.index .. ":" .. e.target.mapID end
    local signature = table.concat(parts, "|")
    if signature == lastSignature then return end
    lastSignature = signature
    Clear(lib)
    if #steps == 0 then return end

    local flag = HBD_PINS_WORLDMAP_SHOW_PARENT or 1
    -- the trail: dots between each step and the next, on the same map
    local dots = 0
    for k = 1, #steps - 1 do
        local a, b = steps[k], steps[k + 1]
        if a.target.mapID == b.target.mapID then
            local ax, ay, bx, by = a.step.x, a.step.y, b.step.x, b.step.y
            local dist = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
            local n = math.floor(dist / TRAIL_SPACING)
            for t = 1, n - 1 do
                if dots >= TRAIL_MAX then break end
                dots = dots + 1
                local f = t / n
                pcall(lib.AddWorldMapIconMap, lib, REF, Dot(dots), a.target.mapID,
                    (ax + (bx - ax) * f) / 100, (ay + (by - ay) * f) / 100, flag)
            end
        end
    end
    -- the numbered steps, over the trail
    for k, e in ipairs(steps) do
        local colour = k == 1 and CURRENT or GOLD
        local p = StepPin(stepPool, k, k == 1 and 22 or 18)
        p.index, p.title = e.index, e.title
        p.gem:SetVertexColor(colour[1], colour[2], colour[3])
        p.num:SetText(k)
        pcall(lib.AddWorldMapIconMap, lib, REF, p, e.target.mapID, e.step.x / 100, e.step.y / 100, flag)
        if k <= MINIMAP_STEPS then
            local m = StepPin(miniPool, k, k == 1 and 16 or 13)
            m.index, m.title = e.index, e.title
            m.gem:SetVertexColor(colour[1], colour[2], colour[3])
            m.num:SetText(k)
            pcall(lib.AddMinimapIconMap, lib, REF, m, e.target.mapID, e.step.x / 100, e.step.y / 100, true, false)
        end
    end
end

---------------------------------------------------------------------------
-- Your own map marker: where the game won't let addons set its waypoint
-- (Forever) and TomTom isn't there, "mark it" clicks put this pin on the world
-- map and minimap, and the guide arrow points at it with the yards to go. It
-- clears itself when you get there; click the pin to clear it sooner.
---------------------------------------------------------------------------
local MARK_REF = "HearthboundMarker"
local ARRIVE_YARDS = 12
local marker -- { mapID, x, y, title, spot = { mapID, continent, wx, wy, x, y } }
local markWorld, markMini

local function MarkPin(size)
    local p = CreateFrame("Button", nil, UIParent)
    p:SetSize(size, size)
    local ring = p:CreateTexture(nil, "BACKGROUND")
    ring:SetAllPoints()
    ring:SetTexture(PIN_TEXTURE)
    ring:SetVertexColor(0.1, 0.1, 0.1, 0.9)
    local gem = p:CreateTexture(nil, "ARTWORK")
    gem:SetPoint("TOPLEFT", 2, -2)
    gem:SetPoint("BOTTOMRIGHT", -2, 2)
    gem:SetTexture(PIN_TEXTURE)
    gem:SetVertexColor(0.3, 1, 0.5)
    p:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(marker and marker.title or "Marker", 0.3, 1, 0.5)
        GameTooltip:AddLine("Your marker - the guide arrow points here.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Click: clear it", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:SetScript("OnClick", function() ns.ClearGuideMarker() end)
    return p
end

function ns.ClearGuideMarker(silent)
    if not marker then return end
    local lib = Library()
    if lib then
        lib:RemoveAllWorldMapIcons(MARK_REF)
        lib:RemoveAllMinimapIcons(MARK_REF)
    end
    if not silent then ns.Print("Marker cleared.") end
    marker = nil
end

-- a marker at mapID, x, y (0-100): true if it could be placed
function ns.SetGuideMarker(mapID, x, y, title)
    if not (mapID and x and y and ns.WorldPos) then return false end
    local continent, wx, wy = ns.WorldPos(mapID, x, y)
    if not continent then return false end
    ns.ClearGuideMarker(true)
    marker = { mapID = mapID, x = x, y = y, title = title or "Marker",
               spot = { mapID = mapID, continent = continent, wx = wx, wy = wy, x = x, y = y } }
    local lib = Library()
    if lib then
        markWorld = markWorld or MarkPin(18)
        markMini = markMini or MarkPin(14)
        pcall(lib.AddWorldMapIconMap, lib, MARK_REF, markWorld, mapID, x / 100, y / 100, HBD_PINS_WORLDMAP_SHOW_PARENT or 1)
        pcall(lib.AddMinimapIconMap, lib, MARK_REF, markMini, mapID, x / 100, y / 100, true, true)
    end
    -- make sure the arrow is there to follow it
    if ns.db.guide == false or ns.db.guideArrow == false then
        ns.Print("Turn the guide and its arrow on (|cffc79c6e/hb guide|r) to have an arrow to the marker.")
    end
    return true
end

-- for the guide arrow: a stand-in step pointing at the marker (nil without one)
function ns.GuideMarker()
    if not marker then return nil end
    marker.step = marker.step or { t = "G", name = marker.title, x = marker.x, y = marker.y, spot = marker.spot,
                                   arrowLabel = "Marker: " .. marker.title }
    return marker.step
end

-- got there: clear it
local function CheckMarker()
    if not marker or not ns.PlayerWorldPos then return end
    local c, wx, wy = ns.PlayerWorldPos()
    local sp = marker.spot
    if c and c == sp.continent and math.sqrt((sp.wx - wx) ^ 2 + (sp.wy - wy) ^ 2) <= ARRIVE_YARDS then
        ns.Print(format("You've reached |cffffd200%s|r.", marker.title))
        ns.ClearGuideMarker(true)
    end
end

table.insert(ns.inits, function()
    C_Timer.NewTicker(1, function() pcall(CheckMarker) end)
    -- the route moves on as you quest: check every couple of seconds (it only redraws on a change)
    C_Timer.NewTicker(2, function() pcall(ns.RefreshGuideMap) end)
    table.insert(ns.refreshers, function()
        lastSignature = nil
        pcall(ns.RefreshGuideMap)
    end)
end)
