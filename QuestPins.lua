local ADDON_NAME, ns = ...

-- Map pins: "!" on the world map and minimap for quests you can pick up, "?"
-- for quests ready to hand in. Click a pin to set a map marker.
--
-- Drawn with the HereBeDragons pins library that Questie ships (it works even
-- though Questie itself doesn't finish starting on Forever).

local format = string.format

local REF = "HearthboundQuestPins"
local ICON_AVAILABLE = "Interface\\GossipFrame\\AvailableQuestIcon"
local ICON_TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon"
local WORLD_SIZE, MINIMAP_SIZE = 16, 13
local MAX_LISTED = 6
local PIN_TINTS = { easy = { 0.45, 1, 0.45 }, normal = { 1, 1, 1 }, hard = { 1, 0.6, 0.3 } }

local Pins
local worldPool, miniPool = {}, {}
local lastSignature
local refreshQueued = false

local function Library()
    if Pins == nil then
        local stub = rawget(_G, "LibStub")
        Pins = stub and stub("HereBeDragonsQuestie-Pins-2.0", true) or false
    end
    return Pins or nil
end

---------------------------------------------------------------------------
-- Pin frames
---------------------------------------------------------------------------
local function ShowTooltip(self)
    local g = self.group
    if not g then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(g.giver or "Quest", 1, 1, 1)
    local level = UnitLevel("player")
    for i, q in ipairs(g.quests) do
        if i > MAX_LISTED then
            GameTooltip:AddLine(format("+%d more", #g.quests - MAX_LISTED), 0.6, 0.6, 0.6)
            break
        end
        if q.turnin then
            GameTooltip:AddLine(q.title .. " - ready to hand in", 0.25, 1, 0.25)
        else
            local prefix = q.level and format("[%d] ", q.level) or ""
            local diff = q.level and ns.QuestDifficulty(q.level, level)
            local c = ({ impossible = { 1, 0.13, 0.13 }, hard = { 1, 0.5, 0.25 }, normal = { 1, 1, 0 },
                         easy = { 0.25, 0.75, 0.25 }, trivial = { 0.5, 0.5, 0.5 } })[diff or "normal"]
            local tag = (q.tag == "group" or q.tag == "dungeon") and ("  (" .. q.tag .. ")") or ""
            GameTooltip:AddLine(prefix .. q.title .. tag, c[1], c[2], c[3])
        end
    end
    GameTooltip:AddLine("Click: set a map marker", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

local function NewPin(size)
    local pin = CreateFrame("Button", nil, UIParent)
    pin:SetSize(size, size)
    pin.icon = pin:CreateTexture(nil, "OVERLAY")
    pin.icon:SetAllPoints()
    pin:SetScript("OnEnter", ShowTooltip)
    pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
    pin:SetScript("OnClick", function(self)
        local g = self.group
        if g then ns.SetWaypoint(g.mapID, g.x, g.y, (g.giver or "?") .. " - " .. g.quests[1].title) end
    end)
    pin:Hide()
    return pin
end

local function Acquire(pool, index, size, group)
    local pin = pool[index] or NewPin(size)
    pool[index] = pin
    pin.group = group
    pin.icon:SetTexture(group.turnin and ICON_TURNIN or ICON_AVAILABLE)
    -- "!" coloured by difficulty like the quest log: green easy, yellow on level, orange hard
    local tint = not group.turnin and PIN_TINTS[group.diff or "normal"] or { 1, 1, 1 }
    pin.icon:SetVertexColor(tint[1], tint[2], tint[3])
    -- hand-ins a touch bigger: they're the ones to head for
    local grow = group.turnin and 3 or 0
    pin:SetSize(size + grow, size + grow)
    return pin
end

---------------------------------------------------------------------------
-- What to pin
---------------------------------------------------------------------------
-- quest givers grouped by spot: { mapID, x, y, giver, turnin, quests = { { title, level, turnin } } }
local function Groups()
    local groups, byKey = {}, {}
    local function Add(mapID, x, y, giver, quest)
        if not (mapID and x and y) then return end
        local key = format("%d:%.1f:%.1f", mapID, x, y)
        local g = byKey[key]
        if not g then
            g = { mapID = mapID, x = x, y = y, giver = giver, quests = {} }
            byKey[key] = g
            groups[#groups + 1] = g
        end
        g.quests[#g.quests + 1] = quest
        if quest.turnin then g.turnin = true end
        -- the pin takes the colour of the quest nearest your level there
        local rank = { normal = 3, easy = 2, hard = 1 }
        if quest.diff and (rank[quest.diff] or 0) > (rank[g.diff or ""] or 0) then g.diff = quest.diff end
    end

    -- hand-ins first, so a giver with both shows "?"
    for _, q in ipairs(ns.openQuests or {}) do
        if q.complete then
            local finish = ns.QuestieFinish and ns.QuestieFinish(q.title, q.id)
            if finish then Add(finish.mapID, finish.x, finish.y, finish.giver, { title = q.title, turnin = true }) end
        end
    end
    -- quests to pick up: worth doing at your level (not grey, not red)
    local level = UnitLevel("player")
    for _, e in ipairs(ns.AvailableQuests and ns.AvailableQuests() or {}) do
        local diff = e.level and e.level > 0 and ns.QuestDifficulty(e.level, level)
        if diff ~= "trivial" and diff ~= "impossible" and e.kind ~= "item" then
            Add(e.mapID, e.x, e.y, e.giver, { title = e.title, level = e.level, diff = diff or "normal",
                tag = ns.QuestGroupTag and ns.QuestGroupTag(e.id) })
        end
    end
    return groups
end

local function Clear()
    local lib = Library()
    if lib then
        lib:RemoveAllWorldMapIcons(REF)
        lib:RemoveAllMinimapIcons(REF)
    end
    for _, pin in ipairs(worldPool) do pin:Hide() end
    for _, pin in ipairs(miniPool) do pin:Hide() end
end

function ns.RefreshQuestPins()
    local lib = Library()
    if not lib then return end
    if not ns.db.questPins then
        if lastSignature then Clear() end
        lastSignature = nil
        return
    end
    local groups = Groups()
    -- skip the redraw when nothing changed
    local parts = {}
    for _, g in ipairs(groups) do
        parts[#parts + 1] = format("%d%.1f%.1f%s%d%s", g.mapID, g.x, g.y, g.turnin and "?" or "!", #g.quests, g.diff or "")
    end
    local signature = table.concat(parts, "|")
    if signature == lastSignature then return end
    lastSignature = signature

    Clear()
    local flag = HBD_PINS_WORLDMAP_SHOW_PARENT or 1
    for i, g in ipairs(groups) do
        local x, y = g.x / 100, g.y / 100
        pcall(lib.AddWorldMapIconMap, lib, REF, Acquire(worldPool, i, WORLD_SIZE, g), g.mapID, x, y, flag)
        pcall(lib.AddMinimapIconMap, lib, REF, Acquire(miniPool, i, MINIMAP_SIZE, g), g.mapID, x, y, true, false)
    end
end

-- many events arrive in bursts; redraw once shortly after
local function QueueRefresh(delay)
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(delay or 1, function()
        refreshQueued = false
        ns.RefreshQuestPins()
    end)
end

table.insert(ns.inits, function()
    ns.On("QUEST_LOG_UPDATE", function() QueueRefresh(1) end)
    for _, event in ipairs({ "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED", "PLAYER_LEVEL_UP" }) do
        ns.On(event, function() QueueRefresh(1) end)
    end
    ns.On("PLAYER_ENTERING_WORLD", function() QueueRefresh(12) end)
    table.insert(ns.refreshers, function() QueueRefresh(0.1) end) -- the setting was changed
end)
