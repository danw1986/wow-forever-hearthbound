local ADDON_NAME, ns = ...

-- Dungeon pick-ups: a guide of its own, in its own window beside the levelling
-- guide, that collects one dungeon's quests before you go in. Your place in the
-- levelling guide is never touched: while this window is open the arrow follows
-- it, and closing it hands the arrow back to your route.
--
-- For each of the dungeon's quests you can do (QuestieDB: yours, not done, not
-- in your log, given outside), the quests that have to come first - the whole
-- chain, in order - each picked up, done and handed in, then the quest itself
-- picked up. The chains are walked nearest stop first, and the guide ends at
-- the entrance. Quests above your level, or that need a quest only a dungeon
-- gives, wait in a list of their own; ones given inside are listed too.
--
--   ns.OpenDungeonPickup(key)     open it on a dungeon (its journal page, /hb pickup <name>)
--   ns.ToggleDungeonPickup()      show or hide it (on the last dungeon, or a choice)
--   ns.DungeonPickupArrowStep()   the step the arrow follows, while it's open (Guide.lua)
--   ns.DungeonPickupPlan(key)     the plan for a dungeon (also for the tests)

local format = string.format

local WIDTH = 320
local ROW_H = 30
local MAX_ROWS = 10
local ARRIVE_YARDS = 40 -- this close to the entrance: there
local FAR = 1e9         -- the next stop is on another continent (or nowhere known)

local I = "Interface\\Icons\\"
local ICONS = {
    A = "Interface\\GossipFrame\\AvailableQuestIcon", T = "Interface\\GossipFrame\\ActiveQuestIcon",
    C = I .. "Ability_Warrior_Rampage", G = I .. "INV_Misc_Key_14",
}
local TICK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t"

local frame, plan, focus
local rows = {}
local offset = 0 -- the first step shown (scrolled with the mouse wheel)

---------------------------------------------------------------------------
-- What the game says
---------------------------------------------------------------------------
local function InLog(id)
    for _, e in ipairs(ns.openQuests or {}) do
        if e.id == id then return true, e.complete == true end
    end
    return false, false
end

local function Done(id) return ns.QuestDone and ns.QuestDone(id) and true or false end

local function AnyOf(ids, test)
    for _, id in ipairs(ids) do if test(id) then return true end end
    return false
end

local function Spot(sp)
    if not (sp and sp.mapID and sp.x and sp.y) then return nil end
    if sp.continent then return sp end
    local c, wx, wy
    if ns.WorldPos then c, wx, wy = ns.WorldPos(sp.mapID, sp.x, sp.y) end
    return { mapID = sp.mapID, x = sp.x, y = sp.y, continent = c, wx = wx, wy = wy }
end

local function Distance(a, b)
    if not (a and b and a.continent and b.continent) then return FAR end
    if a.continent ~= b.continent then return FAR / 2 end
    return math.sqrt((a.wx - b.wx) ^ 2 + (a.wy - b.wy) ^ 2)
end

local function Here()
    if not ns.PlayerWorldPos then return nil end
    local c, wx, wy = ns.PlayerWorldPos()
    return c and { continent = c, wx = wx, wy = wy } or nil
end

local function MapName(mapID)
    local info = mapID and C_Map and C_Map.GetMapInfo and ns.Safe(C_Map.GetMapInfo, mapID)
    return type(info) == "table" and info.name or nil
end

---------------------------------------------------------------------------
-- Where things are, from QuestieDB
---------------------------------------------------------------------------
local function Spots(datatype, id)
    return ns.QuestieSpawnSpots and ns.QuestieSpawnSpots(datatype, id) or {}
end

-- where to do a quest's objectives: its mobs, the objects to use, or what drops its items
local function ObjectiveSpots(id)
    local o = ns.QuestieGet and ns.QuestieGet("Quest", id, "objectives")
    local out = {}
    if type(o) ~= "table" then return out end
    local function Add(list)
        for _, sp in ipairs(list) do out[#out + 1] = Spot(sp) end
    end
    for _, c in ipairs(type(o[1]) == "table" and o[1] or {}) do Add(Spots("Npc", type(c) == "table" and c[1] or c)) end
    for _, c in ipairs(type(o[2]) == "table" and o[2] or {}) do Add(Spots("Object", type(c) == "table" and c[1] or c)) end
    if #out == 0 then
        for _, c in ipairs(type(o[3]) == "table" and o[3] or {}) do
            local item = type(c) == "table" and c[1] or c
            for _, field in ipairs({ "npcDrops", "objectDrops" }) do
                local from = ns.QuestieGet("Item", item, field)
                for _, src in ipairs(type(from) == "table" and from or {}) do
                    Add(Spots(field == "npcDrops" and "Npc" or "Object", src))
                    if #out > 60 then return out end
                end
            end
        end
    end
    return out
end

local function Nearest(spots, near)
    local best, bestD
    for _, sp in ipairs(spots) do
        local d = Distance(sp, near)
        if not bestD or d < bestD then best, bestD = sp, d end
    end
    return best
end

local function Entrance(d)
    local e = ns.QuestieEntrance and ns.QuestieEntrance(d.key)
    if e then return Spot(e) end
    local p = d.entrance
    local mapID = p and p.x and ns.FindMapID and ns.FindMapID(p.zone or d.zone)
    return mapID and Spot({ mapID = mapID, x = p.x, y = p.y }) or nil
end

---------------------------------------------------------------------------
-- The plan
---------------------------------------------------------------------------
-- a step: { t = "A"|"C"|"T"|"G", q, ids (versions of the quest), name, who, spot, why (the
-- dungeon quest it's for, when it's one that comes first), key (for skipping) }
local function Step(t, info, who, spot, why)
    return { t = t, q = info.id, ids = info.alts or { info.id }, name = info.title, who = who, spot = spot, why = why,
             key = t .. info.id }
end

local function Applies(id)
    if ns.QuestieFitsYou and ns.QuestieFitsYou(id) == false then return false end
    local why = ns.QuestieWhyNot and ns.QuestieWhyNot(id)
    return not (type(why) == "string" and why:find("^you did ")) -- another quest instead of it
end

-- nil, "reading" while QuestieDB's lists are still being read; nil, "questie" without it
function ns.DungeonPickupPlan(key)
    local d = ns.DungeonInfo and ns.DungeonInfo(key)
    if not d then return nil, "unknown" end
    if not (ns.QuestieAvailable and ns.QuestieAvailable()) then return nil, "questie" end
    local filed = ns.QuestieDungeonQuestIds and ns.QuestieDungeonQuestIds(key)
    if not filed then return nil, "reading" end
    -- the ones QuestieDB files under the dungeon, and the ones it files elsewhere (no
    -- zone, or a city: Forever's new dungeons) that the journal knows are its (d.questIds)
    local ids, have = {}, {}
    for _, list in ipairs({ filed, d.questIds or {} }) do
        for _, id in ipairs(list) do
            if not have[id] then have[id], ids[#ids + 1] = true, id end
        end
    end
    local level = UnitLevel("player") or 1
    local p = { key = key, name = d.name, steps = {}, later = {}, inside = {}, carried = 0, total = 0 }
    -- the dungeon's quests for you, one per name (versions of one quest: any one counts)
    local quests, byTitle = {}, {}
    for _, id in ipairs(ids) do
        local info = ns.QuestieQuestInfo(id)
        if info and Applies(id) then
            local same = byTitle[info.title]
            if same then
                same.alts[#same.alts + 1] = id
            else
                local copy = {}
                for k, v in pairs(info) do copy[k] = v end
                copy.alts = { id }
                byTitle[info.title] = copy
                quests[#quests + 1] = copy
            end
        end
    end
    table.sort(quests, function(a, b)
        if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) < (b.level or 0) end
        return a.id < b.id
    end)
    -- each quest's state, and what has to come first (the rest of its chain, in
    -- order; optional lead-ins left out)
    for _, info in ipairs(quests) do
        info.isDone = AnyOf(info.alts, Done)
        info.held = AnyOf(info.alts, InLog)
        if not info.isDone and not info.held and info.start and info.start.mapID then
            local before, wait, blocked = {}, nil, nil
            for _, c in ipairs(ns.QuestieChain and ns.QuestieChain(info.id) or {}) do
                if not c.lead and not c.done and not Done(c.id) then
                    local ci = ns.QuestieQuestInfo(c.id)
                    if ci then
                        local inLog = InLog(ci.id)
                        if not inLog and (ci.requiredLevel or 0) > level then
                            wait = math.max(wait or 0, ci.requiredLevel)
                        end
                        if not inLog and not (ci.start and ci.start.mapID) then blocked = blocked or ci.title end
                        before[#before + 1] = ci
                    end
                end
            end
            if (info.requiredLevel or 0) > level then wait = math.max(wait or 0, info.requiredLevel) end
            info.before, info.wait, info.blocked = before, wait, blocked
        end
    end
    -- one of these that leads to another of them is done on the way, in that one's
    -- chain (Hamuul Runetotem and Nara Wildmane before Leaders of the Fang)
    local onTheWay = {}
    for _, info in ipairs(quests) do
        if info.before and not info.wait and not info.blocked then
            for _, ci in ipairs(info.before) do onTheWay[ci.id] = true end
        end
    end
    local chains, owner = {}, {} -- owner: a quest that comes first -> the chain it's done in
    for _, info in ipairs(quests) do
        if not info.isDone then p.total = p.total + 1 end
        if info.isDone or AnyOf(info.alts, function(id) return onTheWay[id] end) then
            -- nothing to do, or done as part of another's chain
        elseif info.held then
            p.carried = p.carried + 1
        elseif not (info.start and info.start.mapID) then
            p.inside[#p.inside + 1] = info.title .. (info.startItem and (" (starts from " .. info.startItem .. ")")
                or (info.start and info.start.giver and (" (from " .. info.start.giver .. ")") or ""))
        elseif info.wait then
            p.later[#p.later + 1] = { title = info.title, level = info.wait }
        elseif info.blocked then
            p.later[#p.later + 1] = { title = info.title, needs = info.blocked }
        else
            -- a quest another chain does first already: this one goes on the end of that
            -- chain, so its giver isn't visited before it's open to you
            local into
            for _, ci in ipairs(info.before) do
                if owner[ci.id] then into = math.max(into or 0, owner[ci.id]) end
            end
            local chain = into and chains[into] or {}
            local index = into or (#chains + 1)
            for _, ci in ipairs(info.before) do
                if not owner[ci.id] then
                    owner[ci.id] = index
                    local inLog, complete = InLog(ci.id)
                    local why = info.title
                    if not inLog then
                        chain[#chain + 1] = Step("A", ci, ci.start.giver, Spot(ci.start), why)
                    end
                    if not ci.talkOnly and not complete then
                        local spots = ObjectiveSpots(ci.id)
                        if #spots > 0 then
                            local s = Step("C", ci, nil, nil, why)
                            s.spots = spots -- the nearest is picked when the walk gets there
                            chain[#chain + 1] = s
                        end
                    end
                    if ci.finish and ci.finish.mapID then
                        chain[#chain + 1] = Step("T", ci, ci.finish.giver, Spot(ci.finish), why)
                    end
                end
            end
            chain[#chain + 1] = Step("A", info, info.start.giver, Spot(info.start))
            chains[index] = chain
        end
    end
    -- walk the chains nearest stop first, each in its own order
    local at, heads = Here(), {}
    for n = 1, #chains do heads[n] = 1 end
    while true do
        local best, bestD
        for n, chain in ipairs(chains) do
            local s = chain[heads[n]]
            if s then
                local sp = s.spot or Nearest(s.spots or {}, at)
                local dist = Distance(sp, at)
                if not bestD or dist < bestD then best, bestD = n, dist end
            end
        end
        if not best then break end
        local s = chains[best][heads[best]]
        heads[best] = heads[best] + 1
        if not s.spot and s.spots then s.spot = Nearest(s.spots, at) or s.spots[1] end
        s.spots = nil
        p.steps[#p.steps + 1] = s
        if s.spot and s.spot.continent then at = s.spot end
    end
    -- then in (when the entrance's known)
    local gate = Entrance(d)
    if gate then p.steps[#p.steps + 1] = { t = "G", name = d.name, spot = gate, key = "G" .. key, gate = true } end
    return p
end

---------------------------------------------------------------------------
-- Following it
---------------------------------------------------------------------------
local function Skipped(s)
    local skips = ns.cdb and ns.cdb.pickup and ns.cdb.pickup.skips
    return skips and skips[s.key] and true or false
end

local function InDungeon(name)
    local inside = IsInInstance and ns.Safe(IsInInstance)
    if not inside then return false end
    local instance = GetInstanceInfo and ns.Safe(GetInstanceInfo)
    return instance == name
end

local function StepDone(s)
    if Skipped(s) then return true end
    if s.t == "A" then return AnyOf(s.ids, InLog) or AnyOf(s.ids, Done) end
    if s.t == "C" then
        if AnyOf(s.ids, Done) then return true end
        for _, id in ipairs(s.ids) do
            local inLog, complete = InLog(id)
            if inLog and complete then return true end
        end
        return false
    end
    if s.t == "T" then return AnyOf(s.ids, Done) end
    if s.t == "G" then
        if s.reached or InDungeon(s.name) then return true end
        if Distance(s.spot, Here()) <= ARRIVE_YARDS then s.reached = true end
        return s.reached or false
    end
    return false
end

local function Current()
    if not plan then return nil end
    if focus and not StepDone(focus) then return focus end
    focus = nil
    for k, s in ipairs(plan.steps) do
        if not StepDone(s) then return s, k end
    end
end

local function StepText(s)
    if s.t == "A" then return "Accept |cffffd200" .. s.name .. "|r" end
    if s.t == "C" then return "Do |cffffd200" .. s.name .. "|r" end
    if s.t == "T" then return "Turn in |cffffd200" .. s.name .. "|r" end
    return "Go into |cffffd200" .. s.name .. "|r"
end

local function StepWhere(s)
    local parts = {}
    if s.who then parts[#parts + 1] = s.who end
    local zone = s.spot and MapName(s.spot.mapID)
    if zone then parts[#parts + 1] = zone end
    if s.t ~= "G" and not s.spot then parts[#parts + 1] = "no location known" end
    local text = table.concat(parts, " - ")
    if s.why then text = text .. (text ~= "" and "  " or "") .. "|cff8cc8fffor " .. s.why .. "|r" end
    return text
end

-- the step the arrow follows while the window's open (nil: the route has it)
function ns.DungeonPickupArrowStep()
    if not (frame and frame:IsShown() and plan) then return nil end
    local s = Current()
    if not (s and s.spot and s.spot.continent) then return nil end
    if s.arrow then return s.arrow end
    local label = s.t == "A" and "Accept: " or (s.t == "T" and "Turn in: " or (s.t == "C" and "" or "Into "))
    s.arrow = { t = s.t == "G" and "G" or s.t, name = s.name, x = s.spot.x, y = s.spot.y, spot = s.spot,
                dungeonName = s.gate and s.name or nil,
                arrowLabel = plan.name .. ": " .. label .. s.name }
    return s.arrow
end

---------------------------------------------------------------------------
-- The window
---------------------------------------------------------------------------
local function Row(i)
    local r = rows[i]
    if r then return r end
    r = CreateFrame("Button", nil, frame)
    r:SetSize(WIDTH - 16, ROW_H)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.sel = ns.Gradient(r:CreateTexture(nil, "BACKGROUND"), "HORIZONTAL", ns.Tint(ns.color.accent, 0.20), ns.Tint(ns.color.accent, 0.02))
    r.sel:SetAllPoints()
    r.bar = r:CreateTexture(nil, "ARTWORK")
    r.bar:SetPoint("TOPLEFT")
    r.bar:SetPoint("BOTTOMLEFT")
    r.bar:SetWidth(2)
    r.bar:SetColorTexture(unpack(ns.color.accent))
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(16, 16)
    r.icon:SetPoint("TOPLEFT", 6, -3)
    r.text = ns.Text(r, 11)
    r.text:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 6, 0)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetJustifyH("LEFT")
    r.text:SetWordWrap(false)
    r.sub = ns.Text(r, 9, ns.color.dim)
    r.sub:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -2)
    r.sub:SetPoint("RIGHT", -4, 0)
    r.sub:SetJustifyH("LEFT")
    r.sub:SetWordWrap(false)
    local hl = r:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.04)
    r:SetScript("OnClick", function(self, button)
        local s = self.step
        if not s then return end
        if button == "RightButton" then
            ns.cdb.pickup = ns.cdb.pickup or {}
            ns.cdb.pickup.skips = ns.cdb.pickup.skips or {}
            ns.cdb.pickup.skips[s.key] = (not ns.cdb.pickup.skips[s.key]) or nil
            if focus == s then focus = nil end
        else
            focus = not StepDone(s) and s or nil
            if s.spot and ns.SetWaypoint then ns.SetWaypoint(s.spot.mapID, s.spot.x, s.spot.y, s.name, true) end
        end
        ns.RefreshDungeonPickup()
    end)
    r:SetScript("OnEnter", function(self)
        local s = self.step
        if not s then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(s.name, 1, 1, 1)
        if s.why then GameTooltip:AddLine("Comes first, for " .. s.why .. ".", 0.55, 0.78, 1, true) end
        GameTooltip:AddLine("Click: the arrow and a map pin go to this step. Right-click: skip it (or bring it back).",
            0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r:EnableMouseWheel(true)
    r:SetScript("OnMouseWheel", function(_, delta) frame:GetScript("OnMouseWheel")(frame, delta) end)
    rows[i] = r
    return r
end

local function DungeonMenu()
    local level = UnitLevel("player") or 1
    local mine = ns.PlayerFaction and ns.PlayerFaction()
    local list = {}
    for _, d in ipairs(ns.DUNGEONS or {}) do
        local yours = not d.faction or not mine or d.faction == mine
        if yours and (d.max or 60) >= level - 3 and (d.min or 1) <= level + 12 then list[#list + 1] = d end
    end
    table.sort(list, function(a, b) return (a.min or 0) < (b.min or 0) end)
    local items = {}
    for _, d in ipairs(list) do
        local fits = level >= (d.min or 1) and level <= (d.max or 60)
        local colour = fits and "|cff6fdc6f" or "|cffc0c0c0"
        items[#items + 1] = { format("%s%s|r  |cff999999%d-%d|r", colour, d.name, d.min or 0, d.max or 0),
                              function() ns.OpenDungeonPickup(d.key) end }
    end
    if #items == 0 then items[#items + 1] = { "|cff999999No dungeons near your level|r", nil } end
    if plan then items[#items + 1] = { "Work it out again from here", function() ns.OpenDungeonPickup(plan.key) end } end
    items[#items + 1] = { "|cff999999Cancel|r", nil }
    if ns.GuideMenu then ns.GuideMenu("Pick up quests for", items) end
end

local function SavePosition()
    local p, _, rp, x, y = frame:GetPoint()
    ns.db.positions = ns.db.positions or {}
    ns.db.positions.pickup = { p, rp, x, y }
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundDungeonPickup", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, 120)
    ns.Window(frame, { ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], 0.94 }, { sheen = 60 })
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    local pos = ns.db.positions and ns.db.positions.pickup
    if pos then frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else frame:SetPoint("RIGHT", -360, 80) end

    local label = ns.Text(frame, 9, ns.color.gold, nil, nil, true)
    label:SetPoint("TOPLEFT", 10, -9)
    label:SetText(ns.InlineIcon(I .. "INV_Misc_Key_14", 11) .. "DUNGEON PICK-UPS")
    local close = ns.CreateButton(frame, "x", 18, 18, function() ns.CloseDungeonPickup() end)
    close:SetPoint("TOPRIGHT", -5, -5)

    -- the dungeon's name: click for another
    frame.choose = CreateFrame("Button", nil, frame)
    frame.choose:SetPoint("TOPLEFT", 10, -22)
    frame.choose:SetSize(WIDTH - 40, 18)
    frame.title = ns.Text(frame.choose, 14, ns.color.text, nil, nil, true)
    frame.title:SetPoint("LEFT")
    frame.choose:SetScript("OnClick", DungeonMenu)
    frame.choose:SetScript("OnEnter", function(self)
        frame.title:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Choose a dungeon", 1, 1, 1)
        GameTooltip:AddLine("The dungeons near your level. Your place in the levelling guide stays where it is.",
            0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame.choose:SetScript("OnLeave", function()
        frame.title:SetTextColor(unpack(ns.color.text))
        GameTooltip:Hide()
    end)
    frame.summary = ns.Text(frame, 10, ns.color.dim)
    frame.summary:SetPoint("TOPLEFT", 10, -42)
    frame.summary:SetWidth(WIDTH - 20)
    frame.summary:SetJustifyH("LEFT")

    frame.notes = ns.Text(frame, 10, ns.color.dim)
    frame.notes:SetWidth(WIDTH - 20)
    frame.notes:SetJustifyH("LEFT")
    frame.notes:SetSpacing(2)

    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta)
        if not plan then return end
        offset = math.max(0, math.min(#plan.steps - MAX_ROWS, offset - delta))
        ns.RefreshDungeonPickup(true)
    end)
    local elapsed = 0
    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < 1 then return end
        elapsed = 0
        ns.RefreshDungeonPickup()
    end)
    frame:Hide()
end

local function Summary()
    if not plan then return "" end
    local left, total = 0, 0
    for _, s in ipairs(plan.steps) do
        if s.t ~= "G" then
            total = total + 1
            if not StepDone(s) then left = left + 1 end
        end
    end
    local parts = {}
    if total > 0 then parts[#parts + 1] = format("%d of %d steps done", total - left, total) end
    if plan.carried > 0 then
        parts[#parts + 1] = format("%d already in your log", plan.carried)
    end
    if total == 0 and plan.carried == 0 then parts[#parts + 1] = "Nothing to pick up outside" end
    return table.concat(parts, "  -  ")
end

local function Notes()
    if not plan then return "" end
    local lines = {}
    for _, w in ipairs(plan.later) do
        lines[#lines + 1] = w.level and format("|cffc0c0c0Later:|r %s |cff999999(from level %d)|r", w.title, w.level)
            or format("|cffc0c0c0Later:|r %s |cff999999(after %s, which isn't given out here)|r", w.title, w.needs or "?")
    end
    for _, text in ipairs(plan.inside) do lines[#lines + 1] = "|cffc0c0c0Inside:|r " .. text end
    return table.concat(lines, "\n")
end

-- keepOffset: scrolling, so don't jump back to the current step
function ns.RefreshDungeonPickup(keepOffset)
    if not (frame and frame:IsShown()) then return end
    if not plan then
        frame.title:SetText(ns.cdb.pickup and ns.cdb.pickup.key and (ns.DungeonInfo(ns.cdb.pickup.key) or {}).name or "Choose a dungeon")
        frame.summary:SetText(frame.reason or "Click the name to choose a dungeon.")
        for _, r in ipairs(rows) do r:Hide() end
        frame.notes:SetText("")
        frame:SetHeight(76)
        return
    end
    frame.title:SetText(plan.name .. "  |cff999999v|r")
    frame.summary:SetText(Summary())
    local cur, curIndex = Current()
    if not keepOffset then
        local k = curIndex
        if cur and not k then for n, s in ipairs(plan.steps) do if s == cur then k = n end end end
        offset = math.max(0, math.min(#plan.steps - MAX_ROWS, (k or 1) - 3))
    end
    local y = -60
    local shown = 0
    for i = 1, MAX_ROWS do
        local s = plan.steps[offset + i]
        local r = Row(i)
        if s then
            shown = shown + 1
            r.step = s
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", 8, y)
            local done = StepDone(s)
            local skipped = Skipped(s)
            r.icon:SetTexture(ICONS[s.t])
            r.icon:SetDesaturated(done)
            r.icon:SetAlpha(done and 0.5 or 1)
            local text = StepText(s)
            if done then text = TICK .. " |cff8a8a8a" .. text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") .. "|r" end
            r.text:SetText(text)
            local where = skipped and "skipped (right-click to bring it back)" or StepWhere(s)
            local yards = not done and s.spot and Distance(s.spot, Here())
            if yards and yards < FAR / 2 then
                where = where .. format("  |cffc0c0c0%s|r", yards < 1000 and format("%d yd", yards) or format("%.1fk yd", yards / 1000))
            end
            r.sub:SetText(where)
            local isCur = s == cur
            r.sel:SetShown(isCur)
            r.bar:SetShown(isCur)
            r:Show()
            y = y - ROW_H
        else
            r:Hide()
            r.step = nil
        end
    end
    for i = MAX_ROWS + 1, #rows do rows[i]:Hide() end
    local notes = Notes()
    frame.notes:ClearAllPoints()
    frame.notes:SetPoint("TOPLEFT", 10, y - 6)
    frame.notes:SetText(notes)
    local more = #plan.steps - (offset + shown)
    if more > 0 or offset > 0 then
        frame.notes:SetText(format("|cff999999%s%s|r%s", offset > 0 and format("%d above  ", offset) or "",
            more > 0 and format("%d more below (scroll)", more) or "", notes ~= "" and ("\n" .. notes) or ""))
    end
    local notesH = frame.notes:GetText() ~= "" and (frame.notes:GetStringHeight() + 8) or 0
    frame:SetHeight(-y + notesH + 6)
end

---------------------------------------------------------------------------
-- Opening and closing
---------------------------------------------------------------------------
local retry

function ns.OpenDungeonPickup(key)
    if not frame then Build() end
    ns.cdb.pickup = ns.cdb.pickup or {}
    if ns.cdb.pickup.key ~= key then ns.cdb.pickup.skips = nil end
    ns.cdb.pickup.key, ns.cdb.pickup.open = key, true
    focus, offset = nil, 0
    local p, why = ns.DungeonPickupPlan(key)
    plan = p
    frame.reason = (why == "reading" and "Reading Questie's quest lists - a moment...")
        or (why == "questie" and "Needs QuestieDB, for who gives the quests and what comes first.")
        or nil
    if why == "reading" and not retry and ns.QuestieQuestGivers then
        retry = true
        ns.QuestieQuestGivers(function()
            retry = nil
            if ns.cdb.pickup and ns.cdb.pickup.open and ns.cdb.pickup.key == key then ns.OpenDungeonPickup(key) end
        end)
    end
    frame:Show()
    ns.RefreshDungeonPickup()
end

function ns.CloseDungeonPickup()
    if frame then frame:Hide() end
    if ns.cdb.pickup then ns.cdb.pickup.open = nil end
    focus = nil
end

function ns.ToggleDungeonPickup()
    if frame and frame:IsShown() then return ns.CloseDungeonPickup() end
    local key = ns.cdb.pickup and ns.cdb.pickup.key
    if key and ns.DungeonInfo and ns.DungeonInfo(key) then return ns.OpenDungeonPickup(key) end
    if not frame then Build() end
    plan = nil
    frame:Show()
    ns.RefreshDungeonPickup()
    DungeonMenu()
end

-- /hb pickup [part of a dungeon's name]
function ns.DungeonPickupCommand(text)
    text = (text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return ns.ToggleDungeonPickup() end
    for _, d in ipairs(ns.DUNGEONS or {}) do
        if d.key == text or d.name:lower():find(text, 1, true) then return ns.OpenDungeonPickup(d.key) end
    end
    ns.Print("No dungeon called \"" .. text .. "\". |cffc79c6e/hb pickup|r lists the ones near your level.")
end

table.insert(ns.inits, function()
    -- open after a /reload or login, where you left it
    local saved = ns.cdb.pickup
    if saved and saved.open and saved.key then
        C_Timer.After(3, function()
            if ns.cdb.pickup and ns.cdb.pickup.open then ns.OpenDungeonPickup(saved.key) end
        end)
    end
    ns.On("QUEST_ACCEPTED", function() C_Timer.After(0.3, ns.RefreshDungeonPickup) end)
    ns.On("QUEST_TURNED_IN", function() C_Timer.After(0.3, ns.RefreshDungeonPickup) end)
end)
