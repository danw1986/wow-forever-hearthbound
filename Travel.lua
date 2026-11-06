local ADDON_NAME, ns = ...

-- Travel: a "don't leave yet" alert when you walk away from quests you could
-- pick up or hand in, and a Travel section with your hearthstone and flight
-- paths you haven't learned in this zone.

local format = string.format
local Safe = ns.Safe

local HEARTHSTONE = 6948
local NEAR_YARDS = 100   -- givers this close count as "here"
local LEAVE_YARDS = 250  -- this far from where they were, you've left
local CHECK_SECONDS = 5

---------------------------------------------------------------------------
-- Don't leave yet
---------------------------------------------------------------------------
local hub          -- { continent, wx, wy, place, pickups = { title = spot }, handins = { title = spot } }
local alerted = {} -- hubs already warned about this session
local MAX_LEFT = 10 -- quests remembered in the Left behind list

local function Distance(continent, wx, wy, spot)
    if not spot or spot.continent ~= continent then return nil end
    return math.sqrt((spot.wx - wx) ^ 2 + (spot.wy - wy) ^ 2)
end

-- what's waiting within NEAR_YARDS of you
local function WaitingHere(continent, wx, wy)
    local pickups, handins = {}, {}
    local level = UnitLevel("player")
    for _, e in ipairs(ns.AvailableQuests and ns.AvailableQuests() or {}) do
        local diff = e.level and e.level > 0 and ns.QuestDifficulty(e.level, level)
        if diff ~= "trivial" and diff ~= "impossible" and e.kind ~= "item" then
            local spot, yards = ns.QuestieNearestSpot(e, continent, wx, wy)
            if yards and yards <= NEAR_YARDS then
                pickups[e.title] = { mapID = spot.mapID, x = spot.x, y = spot.y, who = e.giver, id = e.id }
            end
        end
    end
    for _, q in ipairs(ns.openQuests or {}) do
        if q.complete then
            local finish = ns.QuestieFinish and ns.QuestieFinish(q.title, q.id)
            if finish and finish.mapID and ns.WorldPos then
                local c, fx, fy = ns.WorldPos(finish.mapID, finish.x, finish.y)
                local d = c == continent and math.sqrt((fx - wx) ^ 2 + (fy - wy) ^ 2)
                if d and d <= NEAR_YARDS then
                    handins[q.title] = { mapID = finish.mapID, x = finish.x, y = finish.y, who = finish.giver, id = q.id }
                end
            end
        end
    end
    return pickups, handins
end

local function Still(set, test)
    local list = {}
    for title in pairs(set) do if test(title) then list[#list + 1] = title end end
    table.sort(list)
    return list
end

local function InLog(title)
    for _, q in ipairs(ns.openQuests or {}) do
        if q.title == title then return q end
    end
end

---------------------------------------------------------------------------
-- Left behind: the quests from the last few alerts, so you can find them
---------------------------------------------------------------------------
local function ZoneName(mapID)
    local info = mapID and Safe(C_Map.GetMapInfo, mapID)
    return info and info.name or nil
end

-- still worth going back for?
local function StillLeft(e)
    local q = InLog(e.title)
    if e.kind == "pickup" then return not q end
    return q ~= nil and q.complete -- handed in (or dropped): gone from the log
end

local function LeftList()
    ns.cdb.leftBehind = ns.cdb.leftBehind or {}
    local list = ns.cdb.leftBehind
    for i = #list, 1, -1 do
        if not StillLeft(list[i]) then table.remove(list, i) end
    end
    return list
end

local function Where(e)
    local parts = {}
    if e.who then parts[#parts + 1] = (e.kind == "pickup" and "from " or "to ") .. e.who end
    local zone = ZoneName(e.mapID)
    if e.x and e.y then
        parts[#parts + 1] = format("%s %.1f, %.1f", zone or e.place or "", e.x, e.y)
    elseif zone or e.place then
        parts[#parts + 1] = zone or e.place
    end
    return table.concat(parts, " - ")
end

local function Mark(e)
    if not (e and e.mapID and e.x and e.y) then
        return ns.Print(format("No map position for |cffffd200%s|r - it was %s.", e and e.title or "?", e and Where(e) or "?"))
    end
    ns.SetWaypoint(e.mapID, e.x, e.y, (e.kind == "pickup" and "Pick up: " or "Hand in: ") .. e.title)
end

function ns.MarkLeftBehind(index)
    local list = LeftList()
    if #list == 0 then return ns.Print("Nothing left behind.") end
    if index then return Mark(list[index]) end
    ns.Print("|cffffd200Left behind|r (|cffc79c6e/hb left 2|r marks the 2nd, |cffc79c6e/hb left clear|r empties the list):")
    for i, e in ipairs(list) do
        ns.Print(format("  %d. %s |cffffd200%s|r - %s", i, e.kind == "pickup" and "Pick up" or "Hand in", e.title, Where(e)))
    end
end

function ns.ClearLeftBehind()
    ns.cdb.leftBehind = {}
    if ns.UpdatePanel then ns.UpdatePanel() end
    ns.Print("Left behind list cleared.")
end

-- a [Mark] link in chat: clicking it runs SetItemRef with our addon link
local LINK = "|Haddon:Hearthbound:left:%d|h|cff33ff99[Mark]|r|h"
local lastClick, lastClickAt = nil, 0
local function OnLink(link)
    local n = type(link) == "string" and tonumber(link:match("^addon:Hearthbound:left:(%d+)"))
    if not n then return end
    if link == lastClick and GetTime() - lastClickAt < 0.5 then return end -- heard twice
    lastClick, lastClickAt = link, GetTime()
    for _, e in ipairs(LeftList()) do
        if e.n == n then return Mark(e) end
    end
    ns.Print("That quest isn't on the Left behind list any more.")
end

-- adds to the list; returns the new entries
local function Remember(left, kind, titles, spots, added)
    local list = LeftList()
    for _, title in ipairs(titles) do
        for i = #list, 1, -1 do
            if list[i].title == title and list[i].kind == kind then table.remove(list, i) end
        end
        local spot = spots[title] or {}
        ns.cdb.leftCounter = (ns.cdb.leftCounter or 0) + 1
        local e = { n = ns.cdb.leftCounter, title = title, kind = kind, mapID = spot.mapID, x = spot.x, y = spot.y,
                    who = spot.who, id = spot.id, place = left.place, time = time() }
        table.insert(list, 1, e)
        added[#added + 1] = e
    end
    while #list > MAX_LEFT do table.remove(list) end
    return added
end

local function CheckLeaving()
    if not ns.db.leaveTownAlert or IsInInstance() or InCombatLockdown() then return end
    if not ns.PlayerWorldPos then return end
    local continent, wx, wy = ns.PlayerWorldPos()
    if not continent then return end
    local pickups, handins = WaitingHere(continent, wx, wy)
    if next(pickups) or next(handins) then
        -- you're at a hub: remember what's here (and where)
        hub = hub and hub.continent == continent and math.sqrt((hub.wx - wx) ^ 2 + (hub.wy - wy) ^ 2) < LEAVE_YARDS and hub
            or { continent = continent, wx = wx, wy = wy, pickups = {}, handins = {} }
        hub.wx, hub.wy = wx, wy
        hub.place = Safe(GetSubZoneText) or Safe(GetRealZoneText) or "here"
        for t, spot in pairs(pickups) do hub.pickups[t] = spot end
        for t, spot in pairs(handins) do hub.handins[t] = spot end
        return
    end
    if not hub or hub.continent ~= continent then return end
    if math.sqrt((hub.wx - wx) ^ 2 + (hub.wy - wy) ^ 2) < LEAVE_YARDS then return end
    -- you've left: anything still undone there?
    local left = hub
    hub = nil
    local key = format("%d:%d:%d", left.continent, left.wx / 50, left.wy / 50)
    if alerted[key] then return end
    local stillPickups = Still(left.pickups, function(t) return not InLog(t) end)
    local stillHandins = Still(left.handins, function(t) local q = InLog(t) return q and q.complete end)
    if #stillPickups == 0 and #stillHandins == 0 then return end
    alerted[key] = true
    local parts = {}
    if #stillPickups > 0 then parts[#parts + 1] = format("%d to pick up", #stillPickups) end
    if #stillHandins > 0 then parts[#parts + 1] = format("%d to hand in", #stillHandins) end
    local summary = table.concat(parts, " and ")
    local added = {}
    Remember(left, "handin", stillHandins, left.handins, added)
    Remember(left, "pickup", stillPickups, left.pickups, added)
    if ns.Toast then
        ns.Toast("Leaving " .. left.place .. "?", "You left " .. summary .. " behind - /hb left lists them.",
            "Interface\\Icons\\INV_Misc_Note_02")
    end
    ns.Print(format("|cffffd200Leaving %s?|r You left %s behind:", left.place, summary))
    for _, e in ipairs(added) do
        ns.Print(format("  %s %s |cffffd200%s|r - %s", LINK:format(e.n), e.kind == "pickup" and "Pick up" or "Hand in",
            e.title, Where(e)))
    end
    ns.Print("  Click |cff33ff99[Mark]|r, or |cffc79c6e/hb left|r to list them.")
    if ns.UpdatePanel then ns.UpdatePanel() end
end

---------------------------------------------------------------------------
-- Travel section: hearthstone and flight paths
---------------------------------------------------------------------------
local function HearthCooldown()
    local getCooldown = (C_Container and C_Container.GetItemCooldown) or GetItemCooldown
    if not getCooldown then return nil end
    local start, duration = Safe(getCooldown, HEARTHSTONE)
    if not start or start == 0 or not duration then return 0 end
    return math.max(0, start + duration - GetTime())
end

local function HasHearthstone()
    local count = (C_Item and C_Item.GetItemCount) and Safe(C_Item.GetItemCount, HEARTHSTONE)
        or (GetItemCount and Safe(GetItemCount, HEARTHSTONE))
    return type(count) == "number" and count > 0
end

-- flight paths you've learned, read whenever you open a flight map
local function OnTaxiMap()
    if not (C_TaxiMap and C_TaxiMap.GetAllTaxiNodes) then return end
    local mapID = Safe(GetTaxiMapID) or Safe(C_Map.GetBestMapForUnit, "player")
    local ok, nodes = pcall(C_TaxiMap.GetAllTaxiNodes, mapID)
    if not ok or type(nodes) ~= "table" then return end
    ns.cdb.flightsKnown = ns.cdb.flightsKnown or {}
    local unreachable = Enum and Enum.FlightPathState and Enum.FlightPathState.Unreachable
    for _, node in ipairs(nodes) do
        if node.name and node.state ~= unreachable then ns.cdb.flightsKnown[node.name] = true end
    end
end

local FACTION = { Horde = 1, Alliance = 2 }

-- this zone's flight paths of your faction you haven't learned: { name, mapID, x, y }
local function UnlearnedFlights()
    if not (ns.cdb.flightsKnown and C_TaxiMap and C_TaxiMap.GetTaxiNodesForMap) then return {} end
    local mapID = Safe(C_Map.GetBestMapForUnit, "player")
    if not mapID then return {} end
    local ok, nodes = pcall(C_TaxiMap.GetTaxiNodesForMap, mapID)
    if not ok or type(nodes) ~= "table" then return {} end
    local mine = FACTION[UnitFactionGroup("player") or ""]
    local list = {}
    for _, node in ipairs(nodes) do
        local faction = node.faction
        local forMe = faction == nil or faction == 0 or faction == mine
        if node.name and forMe and not ns.cdb.flightsKnown[node.name] and node.position then
            local ok2, x, y = pcall(node.position.GetXY, node.position)
            if ok2 and x then list[#list + 1] = { name = node.name, mapID = mapID, x = x * 100, y = y * 100 } end
        end
    end
    return list
end

ns.AddSection(27, function(add)
    if not ns.db.showTravel then return end
    local lines = {}
    if HasHearthstone() then
        local bind = Safe(GetBindLocation) or "?"
        local cd = HearthCooldown()
        local ready = cd == 0
        lines[#lines + 1] = { "Hearthstone", format("%s  %s", bind, ready and "|cff6fdc6fready|r" or ("|cff999999" .. ns.Duration(cd or 0) .. "|r")) }
        -- several hand-ins waiting somewhere else: a hint to head back
        local here, away = Safe(GetRealZoneText), 0
        for _, q in ipairs(ns.openQuests or {}) do
            if q.complete and q.zone ~= here then away = away + 1 end
        end
        if ready and away >= 3 then lines.hint = format("%d hand-ins waiting elsewhere - is %s on the way?", away, bind) end
    end
    local flights = UnlearnedFlights()
    if #lines == 0 and #flights == 0 then return end
    add.header("Travel")
    for _, l in ipairs(lines) do add.row(l[1], l[2]) end
    if lines.hint then add.note(lines.hint, ns.color.dim) end
    for _, f in ipairs(flights) do
        add.note(format("|cffffd200Flight path not learned:|r %s", f.name), nil,
            function() ns.SetWaypoint(f.mapID, f.x, f.y, f.name .. " flight master") end, "Click: mark the flight master")
    end
end)

-- the Left behind list in the panel, if you want it: click to mark, right-click to forget
ns.AddSection(28, function(add)
    if not ns.db.showLeftBehind then return end
    local list = LeftList()
    if #list == 0 then return end
    add.header("Left behind")
    for i, e in ipairs(list) do
        local verb = e.kind == "pickup" and "|cffffd200Pick up|r " or "|cff6fdc6fHand in|r "
        add.note(verb .. e.title .. "  |cff999999" .. Where(e) .. "|r", nil, function(button)
            if button == "RightButton" then
                table.remove(ns.cdb.leftBehind, i)
                ns.UpdatePanel()
            else
                Mark(e)
            end
        end, "Click: put a waypoint on it. Right-click: forget it.")
    end
end)

table.insert(ns.inits, function()
    C_Timer.NewTicker(CHECK_SECONDS, function() pcall(CheckLeaving) end)
    -- clicks on our [Mark] chat links (newer clients pass addon links on here)
    if EventRegistry and EventRegistry.RegisterCallback then
        pcall(EventRegistry.RegisterCallback, EventRegistry, "SetItemRef", function(_, link) OnLink(link) end, "HearthboundLeft")
    end
    if hooksecurefunc and SetItemRef then hooksecurefunc("SetItemRef", OnLink) end
    ns.On("TAXIMAP_OPENED", OnTaxiMap)
end)
