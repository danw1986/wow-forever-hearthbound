local ADDON_NAME, ns = ...

-- Quest targets window: the mobs your quests still need (to kill, or that drop
-- your quest items), nearest first. Left-click a row to target that mob and
-- put that row's raid marker on it (skull, cross, square...); right-click to
-- mark its nearest spawn on the map.
--
-- Both are done by the row's own macro (/targetexact, /tm): addons may not set
-- raid markers themselves on this client, but a macro you click can. Those
-- secure buttons can't be changed in combat, so the list of names stays put
-- during a fight (counts and distances still update).

local format = string.format
local Safe = ns.Safe

local MAX_ROWS = 6
local MAX_DROPPERS = 30 -- mobs looked at per quest item
local ROW_H = 20
local WIDTH = 240
-- only mobs this close are listed (Settings: ns.db.targetsYards), or ones you can see
local function NearbyYards() return ns.db.targetsYards or 350 end
-- one marker per row: skull, cross, square, moon, triangle, diamond
local ROW_MARKERS = { 8, 7, 6, 5, 4, 3 }

local frame, title, emptyText
local rows = {}
local missWarned = {}

---------------------------------------------------------------------------
-- Who to list
---------------------------------------------------------------------------
local function TitleCase(text)
    return (text:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end))
end

-- mobs whose nameplates are on screen (the game shows them within ~40 yards)
local function InSight()
    local seen = {}
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return seen end
    for _, plate in ipairs(Safe(C_NamePlate.GetNamePlates) or {}) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        local name = unit and Safe(UnitName, unit)
        if name and Safe(UnitIsDead, unit) == false and Safe(UnitCanAttack, "player", unit) == true then
            seen[name:lower()] = true
        end
    end
    return seen
end

-- QuestieDB IDs for a name ("Npc" or "Item"), cached; {} when it doesn't know it
local nameCache = { Npc = {}, Item = {} }
local function IdsByName(datatype, name)
    local cache = nameCache[datatype]
    local key = name:lower()
    if cache[key] then return cache[key] end
    local ids = {}
    -- the quest log can differ in capitals from the database
    for _, try in ipairs({ name, TitleCase(name) }) do
        local found, pending = ns.QuestieIdsByName(datatype, try)
        if pending then return ids end -- the name index is still being built: don't remember the miss
        if found and #found > 0 then
            ids = found
            break
        end
    end
    cache[key] = ids
    return ids
end

-- { name, yards, spot, inSight, quests = { { title, label, progress } } }, best first
local function Targets()
    local list, byName = {}, {}
    local continent, wx, wy
    if ns.PlayerWorldPos then continent, wx, wy = ns.PlayerWorldPos() end
    local function Note(name, quest, label, progress, spot, yards)
        local key = name:lower()
        local t = byName[key]
        if not t then
            t = { name = name, quests = {}, yards = yards, spot = spot }
            byName[key] = t
            list[#list + 1] = t
        elseif yards and (not t.yards or yards < t.yards) then
            t.yards, t.spot = yards, spot
        end
        for _, q in ipairs(t.quests) do
            if q.title == quest and q.label == label then return end
        end
        t.quests[#t.quests + 1] = { title = quest, label = label, progress = progress }
    end

    -- quests in your log that still need doing (not ones ready to hand in)
    local open = {}
    for _, q in ipairs(ns.openQuests or {}) do
        if not q.complete then open[q.id] = true end
    end

    -- from QuestieDB: kill targets and the mobs that drop your quest items
    for _, e in ipairs(ns.QuestObjectives and ns.QuestObjectives() or {}) do
        if (e.kind == "kill" or e.kind == "loot") and e.npcs and e.quest and open[e.quest.id] then
            local progress = ns.ObjectiveProgress(e)
            if not (progress and (progress.done or progress.ready)) then
                for _, npcId in ipairs(e.npcs) do
                    local name = ns.QuestieGet("Npc", npcId, "name")
                    if name then
                        local spot, yards
                        if continent then spot, yards = ns.NearestSpot(ns.QuestieSpawnSpots("Npc", npcId), continent, wx, wy) end
                        Note(name, e.quest.title, e.kind == "loot" and e.label or nil, progress, spot, yards)
                    end
                end
            end
        end
    end
    -- straight from the quest log, for quests QuestieDB doesn't know by ID
    -- (Forever's own): look the mob - or the mobs that drop the item - up by name
    local function NoteNpc(npcId, quest, label, progress)
        local name = ns.QuestieGet and ns.QuestieGet("Npc", npcId, "name")
        if not name then return end
        local spot, yards
        if continent then spot, yards = ns.NearestSpot(ns.QuestieSpawnSpots("Npc", npcId), continent, wx, wy) end
        Note(name, quest, label, progress, spot, yards)
    end
    if ns.QuestNeeds then
        local needs, kills = ns.QuestNeeds()
        for key, entries in pairs(kills) do
            for _, n in ipairs(entries) do
                if not n.done and not n.ready and not byName[key] then
                    local ids = IdsByName("Npc", key)
                    if #ids > 0 then
                        for _, npcId in ipairs(ids) do NoteNpc(npcId, n.title, nil, n) end
                    end
                    -- still list it (position unknown) so it can be targeted by name
                    if not byName[key] then Note(TitleCase(key), n.title, nil, n) end
                end
            end
        end
        for key, entries in pairs(needs) do
            for _, n in ipairs(entries) do
                if not n.done and not n.ready then
                    for _, itemId in ipairs(IdsByName("Item", key)) do
                        local drops = ns.QuestieGet and ns.QuestieGet("Item", itemId, "npcDrops")
                        local itemName = ns.QuestieGet("Item", itemId, "name") or TitleCase(key)
                        for count, npcId in ipairs(type(drops) == "table" and drops or {}) do
                            if count > MAX_DROPPERS then break end -- common items (cloth...) drop from hundreds
                            if not byName[(ns.QuestieGet("Npc", npcId, "name") or ""):lower()] then
                                NoteNpc(npcId, n.title, itemName, n)
                            end
                        end
                    end
                end
            end
        end
    end

    local seen = InSight()
    for _, t in ipairs(list) do t.inSight = seen[t.name:lower()] or false end
    table.sort(list, function(a, b)
        if a.inSight ~= b.inSight then return a.inSight end
        return (a.yards or math.huge) < (b.yards or math.huge)
    end)
    -- only what's around you: in sight, or within the distance in Settings.
    -- (Mobs with no known position only show once you can see them.)
    local near, limit = {}, NearbyYards()
    for _, t in ipairs(list) do
        if t.inSight or (t.yards and t.yards <= limit) then near[#near + 1] = t end
    end
    return near, #list
end

---------------------------------------------------------------------------
-- Rows
---------------------------------------------------------------------------
local function DistanceText(t)
    if t.inSight then return "|cff6fdc6fin sight|r" end
    if not t.yards then return "|cff999999location unknown|r" end
    if t.yards < 1000 then return format("|cffc0c0c0%d yd|r", math.floor(t.yards / 10 + 0.5) * 10) end
    return format("|cffc0c0c0%.1fk yd|r", t.yards / 1000)
end

local function ProgressText(t)
    for _, q in ipairs(t.quests) do
        local p = q.progress
        if p and p.have and p.need and not q.label then return format(" |cffffd200%d/%d|r", p.have, p.need) end
    end
    return ""
end

local function ShowRowTooltip(row)
    local t = row.target
    if not t then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(t.name, 1, 1, 1)
    for _, q in ipairs(t.quests) do
        local p = q.progress
        local count = (p and p.have and p.need) and format(" (%d/%d)", p.have, p.need) or ""
        local what = q.label and ("drops " .. q.label) or "kill"
        GameTooltip:AddLine(format("%s: %s%s", q.title, what, count), 1, 0.82, 0, true)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-click: target it" .. (ns.db.targetSkull and " and put this row's marker on it" or ""), 0.7, 0.7, 0.7)
    if t.spot then GameTooltip:AddLine("Right-click: mark the nearest on your map", 0.7, 0.7, 0.7) end
    GameTooltip:Show()
end

-- after the row's macro has run: say so when there was nothing to target
local function AfterTarget(row)
    local wanted = row.target and row.target.name
    if not wanted then return end
    C_Timer.After(0.1, function()
        local name = Safe(UnitName, "target")
        if not name or name:lower() ~= wanted:lower() then
            if not missWarned[wanted] then
                missWarned[wanted] = true
                ns.Print(format("No %s close enough to target yet.", wanted))
            end
            return
        end
        missWarned[wanted] = nil
    end)
end

local function CreateRow(i)
    local row = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", 6, -24 - (i - 1) * ROW_H)
    row:SetPoint("TOPRIGHT", -6, -24 - (i - 1) * ROW_H)
    row:RegisterForClicks("AnyUp", "AnyDown")
    row:SetAttribute("type1", "macro")
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(0.78, 0.61, 0.43, 0.15)
    row.marker = ROW_MARKERS[i]
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(14, 14)
    row.icon:SetPoint("LEFT", 3, 0)
    row.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    local col, line = (row.marker - 1) % 4, math.floor((row.marker - 1) / 4)
    row.icon:SetTexCoord(col * 0.25, col * 0.25 + 0.25, line * 0.25, line * 0.25 + 0.25)
    row.name = ns.Text(row, 11, ns.color.text)
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.info = ns.Text(row, 10, ns.color.dim)
    row.info:SetPoint("RIGHT", -4, 0)
    row.info:SetJustifyH("RIGHT")
    row.name:SetPoint("RIGHT", row.info, "LEFT", -6, 0)
    row:HookScript("OnEnter", ShowRowTooltip)
    row:HookScript("OnLeave", function() GameTooltip:Hide() end)
    row:HookScript("PostClick", function(self, button, down)
        if down then return end -- each click arrives as a press and a release
        if button == "RightButton" then
            local t = self.target
            if t and t.spot then ns.SetWaypoint(t.spot.mapID, t.spot.x, t.spot.y, t.name) end
        else
            AfterTarget(self)
        end
    end)
    rows[i] = row
    return row
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local function SavePosition()
    local p, _, rp, x, y = frame:GetPoint()
    ns.db.positions.targets = { p, rp, x, y }
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundQuestTargets", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, 60)
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.9 }, ns.color.border)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    local pos = ns.db.positions.targets
    if pos then
        frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    else
        frame:SetPoint("RIGHT", UIParent, "RIGHT", -260, 80)
    end
    title = ns.Text(frame, 10, ns.color.gold)
    title:SetPoint("TOPLEFT", 10, -8)
    title:SetText("QUEST TARGETS")
    emptyText = ns.Text(frame, 11, ns.color.dim)
    emptyText:SetPoint("TOPLEFT", 10, -26)
    emptyText:SetText("No quest mobs nearby.")
    emptyText:SetWordWrap(true)
    emptyText:SetWidth(WIDTH - 20)
    for i = 1, MAX_ROWS do CreateRow(i):Hide() end
    frame:Hide()
end

local function Update()
    if not frame then return end
    local combat = InCombatLockdown()
    local wanted = ns.db.showTargets
    local targets, total = {}, 0
    if wanted then targets, total = Targets() end

    if combat then
        -- names are locked in: just refresh what each row says
        local byName = {}
        for _, t in ipairs(targets) do byName[t.name:lower()] = t end
        for _, row in ipairs(rows) do
            local t = row:IsShown() and row.target and byName[row.target.name:lower()]
            if t then
                row.target = t
                row.info:SetText(ProgressText(t) .. "  " .. DistanceText(t))
            elseif row.target then
                row.info:SetText("|cff6fdc6fdone|r")
            end
        end
        return
    end

    -- hide when switched off or when no quest in your log wants any mob
    if not wanted or total == 0 then
        frame:Hide()
        return
    end
    local shown = math.min(MAX_ROWS, #targets)
    for i, row in ipairs(rows) do
        local t = targets[i]
        if t and i <= shown then
            -- clear first, so a miss doesn't put the marker on whatever you had targeted
            local macro = "/cleartarget\n/targetexact " .. t.name
            if ns.db.targetSkull then macro = macro .. "\n/tm [exists,harm,nodead] " .. row.marker end
            if row.macro ~= macro then
                row:SetAttribute("macrotext1", macro)
                row.macro = macro
            end
            row.icon:SetShown(ns.db.targetSkull and true or false)
            row.target = t
            row.name:SetText(t.name)
            row.info:SetText(ProgressText(t) .. "  " .. DistanceText(t))
            row:Show()
        else
            row.target = nil
            row:Hide()
        end
    end
    if shown == 0 then emptyText:SetText(format("No quest mobs within %d yards.", NearbyYards())) end
    emptyText:SetShown(shown == 0)
    frame:SetHeight(30 + math.max(1, shown) * ROW_H)
    frame:Show()
end
ns.UpdateQuestTargets = Update

function ns.QuestTargetsProbe()
    local P = ns.Print
    P(format("Targets: %d quests in your log, window %s.", #(ns.openQuests or {}), ns.db.showTargets and "on" or "off"))
    local continent = ns.PlayerWorldPos and ns.PlayerWorldPos()
    P("Targets: your position is " .. (continent and "known" or "|cffff5544not known|r") .. ".")
    local objectives = ns.QuestObjectives and ns.QuestObjectives() or {}
    P(format("Targets: QuestieDB knows %d objectives for your quests.", #objectives))
    if ns.QuestNeeds then
        local needs, kills = ns.QuestNeeds()
        for key, entries in pairs(kills) do
            P(format("   kill \"%s\" - %s, QuestieDB knows it: %s", key, entries[1].title,
                #IdsByName("Npc", key) > 0 and "yes" or "no"))
        end
        for key, entries in pairs(needs) do
            local ids = IdsByName("Item", key)
            local drops = ids[1] and ns.QuestieGet("Item", ids[1], "npcDrops")
            P(format("   loot \"%s\" - %s, droppers known: %d", key, entries[1].title, type(drops) == "table" and #drops or 0))
        end
    end
    local targets, total = Targets()
    P(format("Targets: %d mobs wanted, %d listed:", total, #targets))
    for i = 1, math.min(MAX_ROWS, #targets) do
        local t = targets[i]
        P(format("   %s - %s", t.name, t.inSight and "in sight" or (t.yards and format("%d yd", t.yards) or "location unknown")))
    end
    if InCombatLockdown() then P("Targets: you're in combat - the list can't change until it ends.") end
end

function ns.ToggleQuestTargets()
    ns.db.showTargets = not ns.db.showTargets
    if InCombatLockdown() then
        ns.Print("The quest targets window will " .. (ns.db.showTargets and "show" or "hide") .. " after combat.")
    end
    Update()
end

table.insert(ns.inits, function()
    Build()
    C_Timer.NewTicker(1, Update)
    ns.On("PLAYER_REGEN_ENABLED", Update) -- catch up on anything held back during combat
    table.insert(ns.refreshers, function() if not InCombatLockdown() then Update() end end)
end)
