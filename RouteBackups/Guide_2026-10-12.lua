local ADDON_NAME, ns = ...

-- Levelling guide: walks the Horde 1-60 route (GuideData_*.lua) one step at a
-- time, like RestedXP. Steps tick off by themselves as you accept, finish and
-- hand in quests, reach a spot, fly, hearth, train or enter a dungeon. Back and
-- Next let you look over or skip steps, and a movable arrow points at the step
-- with the yards to go.
--
-- Where you are is kept per character (ns.cdb.guide[edition]): pos is the
-- step's number in the route, done the steps you skipped or passed.

local format = string.format
local Safe = ns.Safe

local LOOKAHEAD = 25    -- how far ahead a finished quest step can pull the guide forward
local ARRIVE_YARDS = 25 -- a "go to" step counts once you're this close
local UPCOMING = 4      -- rows after the current step
local WIDTH = 320
local ARROW_TEXTURE = "Interface\\AddOns\\Hearthbound\\Media\\GuideArrow"
local HERE_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready"
local QUEST_STEP = { A = true, C = true, T = true }

local I = "Interface\\Icons\\"
local STEP_ICONS = {
    A = "Interface\\GossipFrame\\AvailableQuestIcon", T = "Interface\\GossipFrame\\ActiveQuestIcon",
    C = I .. "Ability_Warrior_Rampage", D = I .. "INV_Misc_Key_14", G = I .. "INV_Misc_Map02",
    N = I .. "INV_Misc_Note_01", SH = I .. "INV_Misc_Rune_01", H = I .. "INV_Misc_Rune_01",
    FP = I .. "Ability_Mount_Wyvern_01", F = I .. "Ability_Mount_Wyvern_01", TR = I .. "INV_Misc_Book_11",
}

-- uiMap IDs for the route's zone IDs, used when QuestieDB and the zone name can't say
local ZONE_MAPS = {
    [14] = 1411, [215] = 1412, [17] = 1413, [85] = 1420, [130] = 1421, [1637] = 1454, [1638] = 1456,
    [1497] = 1458, [406] = 1442, [331] = 1440, [267] = 1424, [400] = 1441, [33] = 1434, [45] = 1417,
    [405] = 1443, [15] = 1445, [8] = 1435, [440] = 1446, [357] = 1444, [47] = 1425, [490] = 1449,
    [361] = 1448, [618] = 1452, [3] = 1418, [51] = 1427, [28] = 1422, [139] = 1423,
}

local list = {}    -- this character's steps, in order
local byNumber = {} -- step number in the route -> index in list
local acceptAt = {} -- quest ID -> index in list of its first accept step
local questLogReady = false -- the game has sent the quest log since login
local sections = {} -- { name, first, last, zone } in route order
local sectionOf = {} -- index in list -> index in sections
local zoneHint      -- a section in the zone you've just walked into, offered in the window
local routeLevel = {} -- index in list -> the route's quest level there (for the "falling behind" line)
local cur = 1      -- index in list of the step on screen
local state        -- ns.cdb.guide[edition]
local edition

local frame, arrow -- built on first use
local Refresh       -- forward declarations: used before they're defined
local UpdateArrow
local RefreshPicker
local ZoneMark
local HideZonePrompt
local handledZone -- the zone an arrival has been dealt with for (switched, asked, or you chose a section)
local XPToLevel
local Title
local StepXP

---------------------------------------------------------------------------
-- Who you are
---------------------------------------------------------------------------
local function PlayerRace()
    local _, file, id = UnitRace("player")
    if id == 96 then return "skyborne" end -- Forever's new race
    file = (file or ""):lower()
    if file == "scourge" then return "undead" end
    if file:find("sky", 1, true) then return "skyborne" end
    return file
end

local function PlayerClass()
    local _, file = UnitClass("player")
    return (file or ""):lower()
end

local function Applies(step, race, class)
    if step.races then
        local ok = false
        for _, r in ipairs(step.races) do if r == race then ok = true end end
        if not ok then return false end
    end
    if step.classes then
        local wanted, onlyNot = false, true
        for _, c in ipairs(step.classes) do
            if c:sub(1, 1) == "!" then
                if c:sub(2):lower() == class then return false end
            else
                onlyNot = false
                if c:lower() == class then wanted = true end
            end
        end
        if not wanted and not onlyNot then return false end
    end
    return true
end

---------------------------------------------------------------------------
-- Quest and world state
---------------------------------------------------------------------------
local function Completed(q)
    if not q then return false end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local v = Safe(C_QuestLog.IsQuestFlaggedCompleted, q)
        if v ~= nil then return v == true end
    end
    return IsQuestFlaggedCompleted and Safe(IsQuestFlaggedCompleted, q) == true or false
end

-- in the log?, ready to hand in?
local function InLog(q)
    for _, e in ipairs(ns.openQuests or {}) do
        if e.id == q then return true, e.complete and true or false end
    end
    if C_QuestLog and C_QuestLog.IsOnQuest and Safe(C_QuestLog.IsOnQuest, q) == true then
        return true, C_QuestLog.IsComplete and Safe(C_QuestLog.IsComplete, q) == true or false
    end
    return false, false
end

local function Matches(a, b)
    if not a or not b or a == "" or b == "" then return false end
    a, b = a:lower(), b:lower()
    return a:find(b, 1, true) ~= nil or b:find(a, 1, true) ~= nil
end

-- are you somewhere called this (zone, subzone or the minimap's name)?
local function AtPlace(text)
    for _, fn in ipairs({ GetRealZoneText, GetSubZoneText, GetMinimapZoneText }) do
        local name = fn and Safe(fn)
        if type(name) == "string" and Matches(text, name) then return true end
    end
    return false
end

local function BoundAt(text)
    local bind = GetBindLocation and Safe(GetBindLocation)
    return type(bind) == "string" and Matches(text, bind)
end

local function InDungeon(name)
    local inside, kind = IsInInstance()
    if not inside or kind ~= "party" and kind ~= "raid" then return false end
    local instanceName = Safe(GetInstanceInfo)
    return type(instanceName) == "string" and Matches(name, instanceName)
end

-- done as far as the game can tell (not counting steps you skipped)
-- A step's quest can come in versions (class quests with the same name, where
-- you do one of them): s.alts lists them, and any one counts.
local function StepInLog(s)
    if not s.alts then return InLog(s.q) end
    for _, id in ipairs(s.alts) do
        local inLog, complete = InLog(id)
        if inLog then return inLog, complete end
    end
    return false, false
end

local function StepCompleted(s)
    if not s.alts then return Completed(s.q) end
    for _, id in ipairs(s.alts) do
        if Completed(id) then return true end
    end
    return false
end

local function GameDone(s)
    local t = s.t
    if t == "A" then return StepInLog(s) or StepCompleted(s) end
    if t == "C" then
        if StepCompleted(s) then return true end
        local inLog, complete = StepInLog(s)
        return inLog and complete
    end
    if t == "T" then return StepCompleted(s) end
    if t == "SH" then return BoundAt(s.text) end
    return false
end

local function Done(s)
    return state.done[s.i] and true or GameDone(s)
end

-- A complete or turn-in step for a quest you don't have: not in your log,
-- not handed in, and its accept step (if the route has one) is already
-- behind you. Nothing to do there, so the guide passes it by.
-- before: the index the accept step has to come before
-- Quests you've picked yourself (Continue from here, or clicking a step): the
-- guide doesn't skip them - for being grey, on your skip list or not in your
-- log yet - it waits until they're done. state.wanted[quest ID] = true
local function Wanted(s)
    return s.q and state and state.wanted and state.wanted[s.q] or false
end

local function Want(s)
    if not (s and s.q and state) then return end
    state.wanted = state.wanted or {}
    state.wanted[s.q] = true
    for _, id in ipairs(s.alts or {}) do state.wanted[id] = true end
end

local function Orphan(s, before)
    if not (questLogReady and s.q and (s.t == "C" or s.t == "T")) then return false end
    if Wanted(s) then return false end
    local a = acceptAt[s.q]
    if a and a >= before then return false end -- you'll pick it up on the way
    return not StepInLog(s) and not StepCompleted(s)
end

-- quest levels from QuestieDB, read once each
local questLevels = {}
local function QuestLevel(q)
    local level = questLevels[q]
    if level == nil then
        level = ns.QuestieGet and ns.QuestieGet("Quest", q, "questLevel")
        if type(level) == "number" and level > 0 then
            questLevels[q] = level
        elseif ns.QuestieAvailable and ns.QuestieAvailable() then
            questLevels[q] = false -- QuestieDB doesn't know it (it may still be in your log, below)
        end
    end
    if type(level) == "number" and level > 0 then return level end
    -- the level your quest log shows, for quests QuestieDB doesn't have
    for _, e in ipairs(ns.openQuests or {}) do
        if e.id == q and type(e.level) == "number" and e.level > 0 then return e.level end
    end
    return nil
end

-- With "Skip quests too low for XP" on: any step (pick up, complete, hand in)
-- of a quest that's grey for you - only green and harder quests are left.
-- Passed by and hidden from the list, but kept in the route, so they come
-- back if you turn the setting off.
-- Steps you've chosen never to do: a quest you right-clicked ("always skip"),
-- group (elite) quests, or dungeons, as set in Settings
local function UserSkip(s)
    if s.q and ns.db.guideNever and ns.db.guideNever[s.q] then return true end
    if ns.db.guideSkipGroup and s.group then return true end
    if ns.db.guideSkipDungeons and (s.t == "D" or s.instance or s.dungeonName) then return true end
    return false
end

local function Low(s)
    if Wanted(s) then return false end
    if UserSkip(s) then return not (s.q and StepCompleted(s)) end
    if not (ns.db.guideSkipGrey and s.q and QUEST_STEP[s.t]) then return false end
    local level = QuestLevel(s.q)
    if not level or ns.QuestDifficulty(level, UnitLevel("player")) ~= "trivial" then return false end
    return not StepCompleted(s)
end

-- "go to" and note steps can pass with skipped quests around them; flight
-- paths, hearths, trainers and dungeons never do
local TRAVEL_STEP = { G = true, N = true }

---------------------------------------------------------------------------
-- Where a step is
---------------------------------------------------------------------------
local mapCache = {}
local function MapFor(s)
    if not s.z then return nil end
    local cached = mapCache[s.z]
    if cached ~= nil then return cached or nil end
    local mapID = ns.UiMapForArea and ns.UiMapForArea(s.z)
    if not mapID and s.zoneName and ns.FindMapID then mapID = ns.FindMapID(s.zoneName) end
    if not mapID and ZONE_MAPS[s.z] and Safe(C_Map.GetMapInfo, ZONE_MAPS[s.z]) then mapID = ZONE_MAPS[s.z] end
    -- don't remember a miss: QuestieDB may simply not have loaded yet
    if mapID then mapCache[s.z] = mapID end
    return mapID
end

-- { mapID, continent, wx, wy } for a step with coordinates, cached
local targets = {}
-- When a step's own position can't be put on a map: where QuestieDB has the
-- NPC (or object) it's about - for a hand-in, the quest's finisher - nearest you
local function FallbackSpot(s)
    if not (ns.QuestieSpawnSpots and ns.NearestSpot) then return nil end
    local spots = {}
    local tg = s.target
    if type(tg) == "table" and tg.id and tg.kind ~= "item" then
        spots = ns.QuestieSpawnSpots(tg.kind == "object" and "Object" or "Npc", tg.id)
    end
    if #spots == 0 and s.q and ns.QuestieGet and (s.t == "A" or s.t == "T") then
        local who = ns.QuestieGet("Quest", s.q, s.t == "T" and "finishedBy" or "startedBy")
        if type(who) == "table" then
            for _, npcId in ipairs(type(who[1]) == "table" and who[1] or {}) do
                for _, sp in ipairs(ns.QuestieSpawnSpots("Npc", npcId)) do spots[#spots + 1] = sp end
            end
            for _, objectId in ipairs(type(who[2]) == "table" and who[2] or {}) do
                for _, sp in ipairs(ns.QuestieSpawnSpots("Object", objectId)) do spots[#spots + 1] = sp end
            end
        end
    end
    if #spots == 0 then return nil end
    local pc, px, py = ns.PlayerWorldPos()
    return ns.NearestSpot(spots, pc, px, py) or spots[1]
end

local function Target(s)
    if s and s.spot then return s.spot end -- a detour or marker: where it is was worked out already
    if not s then return nil end
    local t = targets[s.i]
    if t then return t end
    if (s.z or s.mapID) and s.x and s.y then
        local mapID = s.mapID or MapFor(s) -- class quest steps know their map already
        if mapID then
            local continent, wx, wy = ns.WorldPos(mapID, s.x, s.y)
            if continent then
                t = { mapID = mapID, continent = continent, wx = wx, wy = wy, x = s.x, y = s.y }
                targets[s.i] = t
                return t
            end
        end
    end
    -- the step's own position didn't work out: try its NPC
    local spot = FallbackSpot(s)
    if spot and spot.continent then
        t = { mapID = spot.mapID, continent = spot.continent, wx = spot.wx, wy = spot.wy, x = spot.x, y = spot.y }
        targets[s.i] = t
        return t
    end
    return nil
end

local function Dragons()
    local stub = rawget(_G, "LibStub")
    return stub and stub("HereBeDragonsQuestie-2.0", true) or nil
end

-- yards to a step and the direction to it (radians, anticlockwise from north),
-- or nil, reason
local function Vector(s)
    local t = Target(s)
    if not t then return nil, "none" end
    local pc, px, py = ns.PlayerWorldPos()
    if not pc or not t.continent then return nil, "unknown" end
    if pc ~= t.continent then return nil, "continent" end
    local dx, dy = t.wx - px, t.wy - py
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle
    if Dragons() then
        -- HereBeDragons yards: x grows to the west, y to the north
        angle = math.atan2(dx, dy)
    else
        -- the game's own world positions (no HereBeDragons): x is north, y is west
        angle = math.atan2(dy, dx)
    end
    return dist, angle % (2 * math.pi)
end

local function Yards(d)
    if d >= 10000 then return format("%.1fk yd", d / 1000) end
    return format("%d yd", math.floor(d + 0.5))
end

---------------------------------------------------------------------------
-- Moving through the route
---------------------------------------------------------------------------
-- the zone a step belongs to: its section's main zone
local function ZoneOf(j)
    local sec = sections[sectionOf[j] or 0]
    return sec and sec.zone or nil
end

local HISTORY = 6 -- zones remembered for the "previous zone" buttons

-- Your place: the step, and - while you're following the route, not just
-- looking - a bookmark for the step's zone (state.zoneMarks[zone] = step
-- number) and the zones you've followed, newest first (state.zoneHistory)
local function Save()
    local s = list[cur]
    if not s then return end
    state.pos = s.i
    if state.hold then return end
    local zone = ZoneOf(cur)
    if not zone then return end
    state.zoneMarks = state.zoneMarks or {}
    state.zoneMarks[zone] = s.i
    state.zoneHistory = state.zoneHistory or {}
    local h = state.zoneHistory
    if h[1] ~= zone then
        for k = #h, 1, -1 do if h[k] == zone then table.remove(h, k) end end
        table.insert(h, 1, zone)
        while #h > HISTORY do table.remove(h) end
    end
end

-- Forward past every finished step. Steps that aren't quests (notes, travel,
-- trainers) also pass once a quest step after them is done, so the guide
-- keeps up when you do things in a different order.
local function Advance()
    local before = cur
    local last = 0
    for j = cur, math.min(#list, cur + LOOKAHEAD) do
        local s = list[j]
        if QUEST_STEP[s.t] and Done(s) then last = j end
    end
    -- the furthest quest step ahead that's done or skipped (too low, or not in your
    -- log), looked for as far ahead of each step as the window above
    local lastPass, scanned = 0, cur - 1
    local function ScanAhead(upTo)
        while scanned < math.min(#list, upTo) do
            scanned = scanned + 1
            local s = list[scanned]
            if QUEST_STEP[s.t] and (Done(s) or Low(s) or Orphan(s, scanned)) then lastPass = scanned end
        end
    end
    local j = cur
    while j < #list do
        local s = list[j]
        ScanAhead(j + LOOKAHEAD)
        local caughtUp = not QUEST_STEP[s.t] and j < last
        local passed = Done(s) or Orphan(s, j) or Low(s) or caughtUp
            or (TRAVEL_STEP[s.t] and j < lastPass)
        if not passed then break end
        -- only steps you've really moved past count as done; ones passed with
        -- skipped quests stay open, in case you turn skipping off
        if not QUEST_STEP[s.t] and (caughtUp or Done(s)) then state.done[s.i] = true end
        j = j + 1
    end
    -- the very last step stays on screen once everything is done
    if j == #list and Done(list[j]) then state.done[list[j].i] = true end
    cur = j
    state.live = list[cur] and list[cur].i -- where you're up to, kept while you browse
    Save()
    if cur ~= before and ns.PlaySound then ns.PlaySound(SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_SELECT or 875) end
    return cur ~= before
end

-- The step after the last quest you've handed in: a good guess at your place
local function FindPlace()
    local last = 0
    for j, s in ipairs(list) do
        if s.t == "T" and Completed(s.q) then last = j end
    end
    cur = math.max(1, math.min(#list, last + 1))
    state.hold = false
    Advance()
end

-- things only the step on screen can notice (being near it, landing, hearthing)
local function CheckCurrent()
    local s = list[cur]
    if not s or state.done[s.i] then return end
    if s.t == "G" then
        local d = Vector(s)
        if d and d <= ARRIVE_YARDS then state.done[s.i] = true end
    elseif s.t == "H" or s.t == "F" then
        if not Safe(UnitOnTaxi, "player") and AtPlace(s.text) then state.done[s.i] = true end
    elseif s.t == "D" then
        if InDungeon(s.dungeonName) then state.done[s.i] = true end
    end
end

-- A short note in the middle of the screen when the guide moves on, so the
-- window can stay small
local toast
local function StepToast(s)
    if not (s and ns.db.guideStepPopup and ns.db.guide) then return end
    if not toast then
        toast = CreateFrame("Frame", "HearthboundGuideStepToast", UIParent, ns.BACKDROP)
        toast:SetSize(360, 46)
        toast:SetPoint("TOP", UIParent, "TOP", 0, -210)
        toast:SetFrameStrata("HIGH")
        ns.Skin(toast, { 0.05, 0.05, 0.06, 0.85 }, { ns.color.gold[1], ns.color.gold[2], ns.color.gold[3], 0.7 })
        toast.label = ns.Text(toast, 9, ns.color.gold)
        toast.label:SetPoint("TOP", 0, -7)
        toast.label:SetText("NEXT STEP")
        toast.text = ns.Text(toast, 12, { 1, 1, 1, 1 })
        toast.text:SetPoint("TOP", toast.label, "BOTTOM", 0, -4)
        toast.text:SetWidth(340)
        toast.text:SetWordWrap(false)
        toast:SetScript("OnUpdate", function(self, dt)
            self.t = self.t + dt
            local t = self.t
            self:SetAlpha(t < 0.2 and t / 0.2 or (t < 3 and 1 or math.max(0, 1 - (t - 3) / 0.6)))
            if t > 3.6 then self:Hide() end
        end)
    end
    toast.text:SetText(Title(s))
    toast.t = 0
    toast:SetAlpha(0)
    toast:Show()
end

local function Evaluate()
    if #list == 0 or not state then return end
    CheckCurrent()
    local before = cur
    if not state.hold then Advance() end
    if cur ~= before then StepToast(list[cur]) end
    Refresh()
end

local queued = false
local function QueueEvaluate(delay)
    if queued then return end
    queued = true
    C_Timer.After(delay or 0.3, function()
        queued = false
        Evaluate()
    end)
end

-- mode: "back" (you went back to it), "look" (just browsing), nil (moving on)
local function Go(index, mode)
    if #list == 0 then return end
    cur = math.max(1, math.min(#list, index))
    if mode == "look" then
        state.hold = true
    elseif mode == "back" then
        -- you came back to it: count it as not done yet, unless the game says it is
        state.done[list[cur].i] = nil
        state.hold = true -- stay here until you do something
    else
        state.hold = false
        Advance()
    end
    Save()
    Refresh()
end

function ns.GuideNext()
    local s = list[cur]
    if s and not Done(s) then state.done[s.i] = true end -- skipped
    Go(cur + 1)
end

function ns.GuideBack()
    Go(cur - 1, "back")
end

function ns.GuideResume()
    local live = state.live and byNumber[state.live]
    if live then cur = live end -- back from wherever you were browsing
    state.hold = false
    Evaluate()
end

function ns.GuideFindPlace()
    FindPlace()
    Refresh()
    ns.Print(format("Guide: step %d of %d.", cur, #list))
end

local function SectionStart(index)
    local section = list[index] and list[index].section
    while index > 1 and list[index - 1].section == section do index = index - 1 end
    return index
end

function ns.GuideNextSection()
    local section = list[cur] and list[cur].section
    local j = cur
    while j <= #list and list[j].section == section do
        if not Done(list[j]) then state.done[list[j].i] = true end -- skipping the rest of it
        j = j + 1
    end
    Go(j)
end

function ns.GuidePrevSection()
    local start = SectionStart(cur)
    local target = (start == cur and cur > 1) and SectionStart(cur - 1) or start
    for j = target, cur do state.done[list[j].i] = nil end -- the section is live again
    Go(target, "back")
end

---------------------------------------------------------------------------
-- Sections: pick where you're questing and the guide follows from there
---------------------------------------------------------------------------
local function SectionProgress(sec)
    local done = 0
    for j = sec.first, sec.last do
        if Done(list[j]) then done = done + 1 end
    end
    return done, sec.last - sec.first + 1
end

local function HereZone()
    local zone = Safe(GetRealZoneText)
    return type(zone) == "string" and zone or nil
end

-- the first section in the zone you're standing in that still has steps to do
-- a section's level: its first quest's
local function SectionLevel(sec)
    if sec.level == nil then
        sec.level = false
        for j = sec.first, sec.last do
            local l = list[j].q and QuestLevel(list[j].q)
            if l then sec.level = l break end
        end
    end
    return sec.level or nil
end

-- the section in the zone you're standing in to follow: one with steps left,
-- whose quests are nearest your level (the earlier one when it's a tie)
-- the first step in a section that's still worth doing: not done, not
-- skipped (too low for XP, or chosen never to do), not a quest you haven't got
local function SectionUseful(sec)
    for j = sec.first, sec.last do
        local s = list[j]
        if not Done(s) and not Low(s) and not Orphan(s, j) then return j end
    end
end

local function HereSection()
    local zone = HereZone()
    if not zone then return nil end
    local me = UnitLevel("player")
    local best, bestGap
    for k, sec in ipairs(sections) do
        if sec.zone and Matches(sec.zone, zone) then
            if SectionUseful(sec) then
                local l = SectionLevel(sec)
                local gap = l and math.abs(l - me) or 50
                if not bestGap or gap < bestGap then best, bestGap = k, gap end
            end
        end
    end
    return best
end

function ns.GuideJumpSection(k, quiet)
    local sec = sections[k]
    if not sec then return end
    handledZone = HereZone()
    zoneHint = nil
    HideZonePrompt()
    local j = SectionUseful(sec)
    local mark = ZoneMark(sec.zone)
    if mark and mark >= sec.first and mark <= sec.last then j = mark end -- where you'd got to in it
    if j then
        Go(j) -- follows from here: the guide moves on as you quest
        if not quiet then ns.Print(format("Guide: following |cffffd200%s|r (step %d).", sec.name, cur)) end
    else
        -- nothing there is worth doing now (all done, or too low for XP): show it, but
        -- don't let the guide skip straight back out of it
        j = sec.first
        while j < sec.last and Done(list[j]) do j = j + 1 end
        Go(j, "look")
        ns.Print(format("Guide: nothing left in |cffffd200%s|r gives you XP - showing it anyway. "
            .. "Press |cffffd200Current|r to go back to where you were.", sec.name))
    end
    if RefreshPicker then RefreshPicker() end
end

-- the step to pick up at in a zone: its bookmark, moved on past anything done
-- or skipped since, as long as it's still in that zone; nil without one
function ZoneMark(zone)
    local mark = zone and state.zoneMarks and state.zoneMarks[zone]
    local j = mark and byNumber[mark]
    if not j then return nil end
    for k = j, math.min(#list, j + 400) do
        if ZoneOf(k) ~= zone then return nil end
        local s = list[k]
        if not Done(s) and not Low(s) and not Orphan(s, k) then return k end
    end
end

-- the best section in a zone (by name): unfinished, nearest your level
local function SectionForZone(zone)
    local me = UnitLevel("player")
    local best, bestGap
    for k, sec in ipairs(sections) do
        if sec.zone and Matches(sec.zone, zone) and SectionUseful(sec) then
            local l = SectionLevel(sec)
            local gap = l and math.abs(l - me) or 50
            if not bestGap or gap < bestGap then best, bestGap = k, gap end
        end
    end
    return best
end

-- Follow a zone: back to where you were in it, or its best section if you've
-- not been there with the guide
function ns.GuideResumeZone(zone, quiet)
    if not (state and zone) then return end
    local j = ZoneMark(zone)
    if j then
        handledZone = HereZone()
        zoneHint = nil
        HideZonePrompt()
        Go(j)
        if not quiet then
            ns.Print(format("Guide: back in |cffffd200%s|r - picking up where you left off (step %d).", zone, cur))
        end
        return true
    end
    local k = SectionForZone(zone)
    if k then
        ns.GuideJumpSection(k, quiet)
        return true
    end
    if not quiet then ns.Print("Guide: nothing left in " .. zone .. " that's worth doing.") end
end

-- the zone you were following before this one
function ns.GuidePreviousZone()
    local h = state and state.zoneHistory or {}
    local now = ZoneOf(cur)
    for _, zone in ipairs(h) do
        if zone ~= now then return ns.GuideResumeZone(zone) end
    end
    ns.Print("Guide: no previous zone yet.")
end

function ns.GuideHere()
    local here = HereZone()
    if here and ZoneMark(here) then return ns.GuideResumeZone(here) end
    local k = HereSection()
    if not k then
        return ns.Print("The guide has nothing left to do in " .. (HereZone() or "this zone") .. ".")
    end
    ns.GuideJumpSection(k)
end

-- walked into another zone: offer its section if the guide is elsewhere
local function CheckZoneHint()
    local s = list[cur]
    local zone = HereZone()
    if not (s and zone) or IsInInstance() then return end
    local mine = sections[sectionOf[cur]]
    if (mine and mine.zone and Matches(mine.zone, zone)) or (s.zoneName and Matches(s.zoneName, zone)) then
        zoneHint = nil
        return
    end
    zoneHint = HereSection()
end

---------------------------------------------------------------------------
-- Arriving somewhere new: a prompt by the guide offering to switch to this
-- zone's section. Waits until you've landed and aren't fighting; "Stay" means
-- it won't ask about this zone again until you've left it and come back.
---------------------------------------------------------------------------
local zonePrompt
local declinedZone = {} -- zone name -> true, until you leave it
local lastZone

function HideZonePrompt()
    if zonePrompt then zonePrompt:Hide() end
end

local function BuildZonePrompt()
    zonePrompt = CreateFrame("Frame", "HearthboundGuideZonePrompt", UIParent, ns.BACKDROP)
    zonePrompt:SetSize(WIDTH, 96)
    zonePrompt:SetFrameStrata("DIALOG")
    zonePrompt:SetClampedToScreen(true)
    ns.Skin(zonePrompt, { 0.05, 0.05, 0.06, 0.96 }, { 0.2, 0.9, 0.5, 0.9 })
    zonePrompt.title = ns.Text(zonePrompt, 12, { 0.4, 1, 0.6, 1 })
    zonePrompt.title:SetPoint("TOPLEFT", 10, -9)
    zonePrompt.text = ns.Text(zonePrompt, 11)
    zonePrompt.text:SetPoint("TOPLEFT", zonePrompt.title, "BOTTOMLEFT", 0, -5)
    zonePrompt.text:SetPoint("RIGHT", -10, 0)
    zonePrompt.text:SetJustifyH("LEFT")
    zonePrompt.switch = ns.CreateButton(zonePrompt, "Switch", 110, 22, function()
        local k, resume = zonePrompt.section, zonePrompt.resume
        HideZonePrompt()
        if resume then ns.GuideResumeZone(resume) elseif k then ns.GuideJumpSection(k) end
    end)
    zonePrompt.switch:SetPoint("BOTTOMRIGHT", -126, 8)
    zonePrompt.stay = ns.CreateButton(zonePrompt, "Stay", 110, 22, function()
        if zonePrompt.zone then declinedZone[zonePrompt.zone] = true end
        zoneHint = nil
        HideZonePrompt()
        Refresh()
    end)
    zonePrompt.stay:SetPoint("BOTTOMRIGHT", -10, 8)
    zonePrompt:Hide()
end

local function PromptZone()
    if not (state and ns.db.guide and (ns.db.guideZonePrompt or ns.db.guideAutoZone)) then return HideZonePrompt() end
    local zone = HereZone()
    if not zone then return end
    -- you've left the last zone: it can ask about that one again next time
    if lastZone and lastZone ~= zone then declinedZone[lastZone] = nil end
    lastZone = zone
    -- not now: flying, fighting or in a dungeon (asked again when that ends)
    if Safe(UnitOnTaxi, "player") or InCombatLockdown() or IsInInstance() then return end
    -- once per arrival: after a fight or a landing it only finishes what it couldn't do then
    if handledZone == zone then return end
    handledZone = zone
    if declinedZone[zone] then return HideZonePrompt() end
    CheckZoneHint()
    local k = zoneHint
    local offer = k and sections[k]
    if not offer then return HideZonePrompt() end
    -- following your zone by itself: switch, and say so (but not away from a quest you picked)
    if ns.db.guideAutoZone and list[cur] and Wanted(list[cur]) and not Done(list[cur]) then return HideZonePrompt() end
    local markJ = ZoneMark(zone)
    if ns.db.guideAutoZone then
        HideZonePrompt()
        if markJ then
            ns.GuideResumeZone(zone)
        else
            ns.GuideJumpSection(k, true)
            ns.Print(format("Guide: you're in |cffffd200%s|r - now following |cff33ff99%s|r. "
                .. "(|cffc79c6eZones|r to pick another.)", zone, offer.name))
        end
        return
    end
    if not zonePrompt then BuildZonePrompt() end
    local mine = sections[sectionOf[cur]]
    local done, total = SectionProgress(offer)
    zonePrompt.zone, zonePrompt.section = zone, k
    zonePrompt.title:SetText("You've arrived in " .. zone)
    zonePrompt.resume = markJ and zone or nil
    if markJ then
        zonePrompt.text:SetText(format("The guide is on |cffffd200%s|r%s.\nPick up where you left off here? (step %d: %s)",
            mine and mine.name or "?", (mine and mine.zone) and (" (" .. mine.zone .. ")") or "",
            markJ, list[markJ].name or list[markJ].text or ""))
    else
        zonePrompt.text:SetText(format("The guide is on |cffffd200%s|r%s.\nSwitch to |cff33ff99%s|r? (%d of %d steps left)",
            mine and mine.name or "?", (mine and mine.zone) and (" (" .. mine.zone .. ")") or "",
            offer.name, total - done, total))
    end
    zonePrompt:SetHeight(zonePrompt.text:GetStringHeight() + 64)
    zonePrompt:ClearAllPoints()
    if frame and frame:IsShown() then
        zonePrompt:SetPoint("BOTTOM", frame, "TOP", 0, 6)
    else
        zonePrompt:SetPoint("TOP", UIParent, "TOP", 0, -180)
    end
    if not zonePrompt:IsShown() then ns.PlaySound(SOUNDKIT and SOUNDKIT.IG_QUEST_LOG_OPEN or 844) end
    zonePrompt:Show()
end

---------------------------------------------------------------------------
-- Detours (GuideDetours.lua): quests near you that you can get on with, and
-- your class quests. The nearest nearby one takes the arrow until it's done;
-- a class quest takes it when you click its line.
---------------------------------------------------------------------------
local followKey     -- the class quest you clicked to follow
local nearbyDetour, classDetour
local objectiveDetour -- the current "complete" step's nearest unfinished objective

local function DetourKey(d)
    return d and (d.kind .. ":" .. tostring(d.quest) .. ":" .. tostring(d.label or "")) or nil
end

local function UpdateDetours()
    nearbyDetour, classDetour = nil, nil
    if not ns.GuideDetours then return end
    local det = ns.GuideDetours()
    local s = list[cur]
    for _, d in ipairs(det.nearby or {}) do
        -- the route's own step already covers this one
        if not (s and s.q == d.quest and ((s.t == "T") == (d.kind == "turnin"))) then
            nearbyDetour = d
            break
        end
    end
    local followed, first
    for _, d in ipairs(det.class or {}) do
        -- class quests still ahead in the route come up as steps; the line is for ones behind you
        local ahead = acceptAt[d.quest] and acceptAt[d.quest] >= cur
        if not ahead then
            first = first or d
            if DetourKey(d) == followKey then followed = d end
        end
    end
    if followKey and not followed then followKey = nil end -- done, or gone
    classDetour = followed or first
    -- a "complete" step: the arrow goes to the nearest thing it still needs
    objectiveDetour = nil
    if s and s.t == "C" and s.q and ns.QuestObjectives and ns.PlayerWorldPos then
        local continent, wx, wy = ns.PlayerWorldPos()
        local best, bestYards
        for _, e in ipairs(ns.QuestObjectives()) do
            if e.quest.id == s.q and e.spots and #e.spots > 0 then
                local progress = ns.ObjectiveProgress and ns.ObjectiveProgress(e)
                if not (progress and (progress.done or progress.ready)) then
                    local spot, yards = ns.NearestSpot(e.spots, continent, wx, wy)
                    if spot and yards and (not bestYards or yards < bestYards) then
                        local verb = ({ kill = "Kill", loot = "Loot", object = "Use", explore = "Go to" })[e.kind] or "Do"
                        local count = progress and progress.have and progress.need and format(" (%d/%d)", progress.have, progress.need) or ""
                        best = { kind = "progress", quest = s.q, title = s.name, label = e.label, spot = spot,
                                 arrowText = verb .. " " .. (e.label or "?") .. count }
                        bestYards = yards
                    end
                end
            end
        end
        objectiveDetour = best
    end
end

-- a stand-in step for the arrow, pointing at a detour
local function DetourStep(d, why)
    if not (d and d.spot and d.spot.continent) then return nil end
    -- kept on the detour (they're rebuilt every couple of seconds), not made afresh each frame
    if d.arrowStep and d.arrowWhy == why then return d.arrowStep end
    d.arrowWhy = why
    d.arrowStep = {
        t = d.kind == "turnin" and "T" or (d.kind == "pickup" and "A" or "C"),
        name = d.title, x = d.spot.x, y = d.spot.y, zoneName = nil,
        spot = { mapID = d.spot.mapID, continent = d.spot.continent, wx = d.spot.wx, wy = d.spot.wy, x = d.spot.x, y = d.spot.y },
        arrowLabel = d.arrowText or (why .. (d.kind == "turnin" and "Hand in: " or (d.kind == "pickup" and "Pick up: " or "")) .. d.title),
    }
    return d.arrowStep
end

-- what the arrow points at: your own map marker, a class quest you chose, a
-- nearby detour, or the route
local function ArrowStep()
    local m = ns.GuideMarker and ns.GuideMarker()
    if m then return m end
    if followKey and classDetour and DetourKey(classDetour) == followKey then
        local st = DetourStep(classDetour, "Class: ")
        if st then return st end
    end
    if nearbyDetour then
        local st = DetourStep(nearbyDetour, "Nearby: ")
        if st then return st end
    end
    if objectiveDetour then
        local st = DetourStep(objectiveDetour, "")
        if st then return st end
    end
    return list[cur]
end

---------------------------------------------------------------------------
-- Text for a step
---------------------------------------------------------------------------
local function Icon(s)
    local tex = STEP_ICONS[s.t] or STEP_ICONS.N
    if tex:find("Icons", 1, true) then return ns.InlineIcon(tex, 13) end
    return format("|T%s:13:13|t ", tex)
end

local function Q(name) return "|cffffd200" .. (name or "?") .. "|r" end

function Title(s)
    local badge = (s.classQuest and "|cffc79c6eClass|r " or "") .. (s.foreverOnly and "|cff33ff99NEW|r " or "")
        .. (s.group and "|cffff6644Group|r " or "")
    local t = s.t
    local text
    if t == "A" then text = "Accept " .. Q(s.name)
    elseif t == "C" then text = "Complete " .. Q(s.name)
    elseif t == "T" then text = "Turn in " .. Q(s.name)
    elseif t == "D" then text = "|cffc79c6e" .. (s.dungeonName or "Dungeon") .. "|r - " .. (s.text or "")
    elseif t == "SH" then text = "Set your hearthstone: " .. (s.text or "")
    elseif t == "H" then text = "Hearth to " .. (s.text or "")
    elseif t == "FP" then text = "Get the " .. (s.text or "flight path")
    elseif t == "F" then text = "Fly to " .. (s.text or "")
    else text = s.text or "" end
    local xp = t == "T" and s.q and StepXP(s)
    if xp then text = text .. format("  |cff6fdc6f+%s|r", ns.Short and ns.Short(xp) or xp) end
    return Icon(s) .. badge .. text
end

-- XP for a quest step: what your quest log says it gives (the real figure for
-- your level), otherwise QuestieDB's base XP
function StepXP(s)
    for _, e in ipairs(ns.openQuests or {}) do
        if e.id == s.q and type(e.xp) == "number" and e.xp > 0 then return e.xp end
    end
    local xp = ns.QuestieXP and ns.QuestieXP(s.q)
    return type(xp) == "number" and xp > 0 and xp or nil
end

local HEARTHSTONE = 6948
local function HearthCooldown()
    local getCooldown = (C_Container and C_Container.GetItemCooldown) or GetItemCooldown
    if not getCooldown then return nil end
    local start, duration = Safe(getCooldown, HEARTHSTONE)
    if not start or start == 0 or not duration then return 0 end
    return math.max(0, start + duration - GetTime())
end

-- the lines under the current step: who, where, objectives, distance
local function Details(s)
    local lines = {}
    if s.target and s.target.name then
        local who = s.target.kind == "item" and "Item: " or (s.t == "T" and "To " or "From ")
        lines[#lines + 1] = who .. s.target.name
    end
    if s.note then lines[#lines + 1] = s.note end
    -- what it's worth
    local xp = s.q and StepXP(s)
    if xp and (s.t == "T" or s.t == "A") then
        lines[#lines + 1] = format("|cff6fdc6f%s%s XP|r", s.t == "A" and "Worth " or "+", ns.Comma and ns.Comma(xp) or xp)
    end
    -- hearthing: is it ready, and is it set where this step expects?
    if s.t == "H" then
        local cd = HearthCooldown()
        local bind = Safe(GetBindLocation)
        if cd and cd > 0 then
            lines[#lines + 1] = format("|cffff8844Hearthstone ready in %s|r - or travel there another way.", ns.Duration and ns.Duration(cd) or (math.ceil(cd / 60) .. "m"))
        end
        if type(bind) == "string" and s.text and not Matches(s.text, bind) then
            lines[#lines + 1] = "|cffff8844Your hearthstone is set to " .. bind .. ", not here.|r"
        end
    end
    -- flying: do you have the flight path yet?
    if s.t == "F" and s.text and ns.cdb.flightsKnown then
        local known = false
        for node in pairs(ns.cdb.flightsKnown) do
            if Matches(s.text, node) or Matches(node:match("^[^,]+") or node, s.text) then known = true break end
        end
        if not known then
            lines[#lines + 1] = "|cffff8844You haven't got this flight path yet - run there, or learn it on the way.|r"
        end
    end
    if s.t == "C" and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local objectives = Safe(C_QuestLog.GetQuestObjectives, s.q)
        for _, o in ipairs(type(objectives) == "table" and objectives or {}) do
            if o.text and o.text ~= "" then
                lines[#lines + 1] = (o.finished and "|cff6fdc6f" or "|cffcccccc") .. "- " .. o.text .. "|r"
            end
        end
    end
    if s.x and s.y then
        local where = format("%s %.1f, %.1f", s.zoneName or "", s.x, s.y)
        local d, why = Vector(s)
        if d then where = where .. "  |cffffffff" .. Yards(d) .. "|r"
        elseif why == "continent" then where = where .. "  |cff999999(another continent)|r" end
        lines[#lines + 1] = where
    end
    if GameDone(s) or (state.done[s.i] and not QUEST_STEP[s.t]) then
        lines[#lines + 1] = "|cff6fdc6fDone|r"
    elseif state.done[s.i] then
        lines[#lines + 1] = "|cff999999Skipped|r"
    elseif Orphan(s, cur) then
        lines[#lines + 1] = "|cff999999Not in your quest log - the guide passes this step. Press > or Current to move on.|r"
    elseif UserSkip(s) and not (s.q and StepCompleted(s)) then
        lines[#lines + 1] = "|cff999999You've chosen to skip this (right-click the step, or Settings > Levelling guide).|r"
    elseif Low(s) then
        lines[#lines + 1] = format("|cff999999Level %d - too low to give you real XP, so the guide passes it. "
            .. "Turn off \"Skip quests too low for XP\" in Settings to do it anyway.|r", QuestLevel(s.q) or 0)
    end
    return table.concat(lines, "\n")
end

---------------------------------------------------------------------------
-- The step window
---------------------------------------------------------------------------
local rows = {}
local header, counter, progress, holdText

local function RowTooltip(self)
    local s = self.step
    if not s then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(Title(s), 1, 1, 1, 1, true)
    GameTooltip:AddLine(Details(s), 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine(s.section or "", 0.78, 0.61, 0.43, true)
    GameTooltip:AddLine("Click: make this the current step", 0.6, 0.6, 0.6)
    if s.q then
        GameTooltip:AddLine(ns.db.guideNever and ns.db.guideNever[s.q] and "Right-click: stop skipping this quest"
            or "Right-click: always skip this quest", 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local function Row(i)
    local r = rows[i]
    if r then return r end
    r = CreateFrame("Button", nil, frame, ns.BACKDROP)
    ns.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
    r.text = ns.Text(r, 11)
    r.text:SetPoint("TOPLEFT", 6, -4)
    r.text:SetWidth(WIDTH - 24)
    r.text:SetJustifyH("LEFT")
    r.sub = ns.Text(r, 10, ns.color.dim)
    r.sub:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -3)
    r.sub:SetWidth(WIDTH - 24)
    r.sub:SetJustifyH("LEFT")
    r.number = ns.Text(r, 9, ns.color.dim)
    r.number:SetPoint("TOPRIGHT", -4, -4)
    r.stripe = r:CreateTexture(nil, "ARTWORK") -- green edge on finished steps
    r.stripe:SetPoint("TOPLEFT", 1, -1)
    r.stripe:SetPoint("BOTTOMLEFT", 1, 1)
    r.stripe:SetWidth(3)
    r.stripe:SetColorTexture(0.35, 0.85, 0.35, 0.9)
    local hl = r:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(0.78, 0.61, 0.43, 0.10)
    r:SetScript("OnEnter", RowTooltip)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            local q = self.step and self.step.q
            if not q then return end
            ns.db.guideNever = ns.db.guideNever or {}
            ns.db.guideNever[q] = not ns.db.guideNever[q] or nil
            ns.Print(format("Guide: |cffffd200%s|r %s.", self.step.name or q,
                ns.db.guideNever[q] and "will always be skipped" or "is back in the route"))
            state.hold = false
            Evaluate()
            return
        end
        if self.index then
            Want(self.step) -- you picked this one: don't skip it
            Go(self.index, self.index < cur and "back" or nil)
        end
    end)
    rows[i] = r
    return r
end

local function SavePosition()
    local p, _, rp, x, y = frame:GetPoint()
    ns.db.positions.guide = { p, rp, x, y }
end

local function BuildWindow()
    frame = CreateFrame("Frame", "HearthboundGuideFrame", UIParent, ns.BACKDROP)
    frame:SetSize(WIDTH, 120)
    ns.Skin(frame, { ns.color.bg[1], ns.color.bg[2], ns.color.bg[3], ns.db.panelOpacity or 0.92 }, ns.color.border)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    local pos = ns.db.positions.guide
    if pos then frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else frame:SetPoint("TOPRIGHT", -220, -180) end

    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)

    local title = ns.Text(frame, 10, ns.color.gold)
    title:SetPoint("TOPLEFT", 8, -8)
    title:SetText(ns.InlineIcon(I .. "INV_Misc_Map_01", 12) .. "LEVELLING GUIDE")
    counter = ns.Text(frame, 10, ns.color.dim)
    counter:SetPoint("TOPRIGHT", -26, -8)
    local close = ns.CreateButton(frame, "x", 16, 16, function()
        ns.db.guide = false
        ns.RefreshAll()
        ns.Print("Guide hidden. |cffc79c6e/hb guide|r brings it back.")
    end)
    close:SetPoint("TOPRIGHT", -5, -5)
    close.text:SetFont(ns.FONT, 10, "")
    -- compact: only the current step
    frame.compact = ns.CreateButton(frame, "-", 16, 16, function()
        ns.db.guideCompact = not ns.db.guideCompact
        Refresh()
    end)
    frame.compact:SetPoint("TOPLEFT", 120, -5)
    frame.compact.text:SetFont(ns.FONT, 11, "")
    frame.compact:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Compact guide", 1, 1, 1)
        GameTooltip:AddLine("Show only the current step (and the arrow), or the full list.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame.compact:HookScript("OnLeave", function() GameTooltip:Hide() end)

    header = ns.Text(frame, 11, ns.color.text)
    header:SetPoint("TOPLEFT", 8, -24)
    header:SetWidth(WIDTH - 70)
    header:SetJustifyH("LEFT")
    header:SetWordWrap(false)
    -- the section name opens the section list too
    local headerButton = CreateFrame("Button", nil, frame)
    headerButton:SetPoint("TOPLEFT", header, "TOPLEFT", -2, 2)
    headerButton:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 2, -2)
    headerButton:SetScript("OnClick", function() ns.ToggleGuidePicker() end)
    headerButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Choose a section", 1, 1, 1)
        GameTooltip:AddLine("Click to pick a different zone or section to follow.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    headerButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- "you're in another zone" offer, shown under the steps
    frame.hint = CreateFrame("Button", nil, frame, ns.BACKDROP)
    ns.Skin(frame.hint, { 0.2, 0.9, 0.5, 0.12 }, { 0.2, 0.9, 0.5, 0.6 })
    frame.hint:SetSize(WIDTH - 8, 30)
    frame.hint:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame.hint.text = ns.Text(frame.hint, 10)
    frame.hint.text:SetPoint("LEFT", 6, 0)
    frame.hint.text:SetWidth(WIDTH - 20)
    frame.hint.text:SetJustifyH("LEFT")
    frame.hint:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            zoneHint = nil
            Refresh()
        elseif zoneHint then
            ns.GuideJumpSection(zoneHint)
        end
    end)
    frame.hint:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Follow this zone", 1, 1, 1)
        GameTooltip:AddLine("Click: switch the guide to this section. Right-click: stay on the current route.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame.hint:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.hint:Hide()

    -- detour lines above the steps: "Nearby" (the arrow follows it) and "Class quest"
    local function DetourLine(colour, tip)
        local b = CreateFrame("Button", nil, frame, ns.BACKDROP)
        ns.Skin(b, { colour[1], colour[2], colour[3], 0.12 }, { colour[1], colour[2], colour[3], 0.6 })
        b:SetWidth(WIDTH - 8)
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetSize(14, 14)
        b.icon:SetPoint("TOPLEFT", 5, -5)
        b.text = ns.Text(b, 10)
        b.text:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 5, 1)
        b.text:SetPoint("RIGHT", -6, 0)
        b.text:SetJustifyH("LEFT")
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(tip[1], 1, 1, 1)
            GameTooltip:AddLine(tip[2], 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        b:Hide()
        return b
    end
    frame.nearby = DetourLine({ 0.2, 0.9, 0.5 }, { "Nearby",
        "A quest in your log you can get on with here. The arrow points at it until it's done, then goes back to the route.\n"
        .. "Click: map marker. Right-click: leave it for 15 minutes." })
    frame.nearby.icon:SetTexture("Interface\\Minimap\\Tracking\\TrivialQuests")
    frame.nearby:SetScript("OnClick", function(_, button)
        local d = nearbyDetour
        if not d then return end
        if button == "RightButton" then
            ns.GuideSkipDetour(d)
            ns.GuideDetours(true)
            UpdateDetours()
            Refresh()
        elseif d.spot then
            ns.SetWaypoint(d.spot.mapID, d.spot.x, d.spot.y, d.title)
        end
    end)
    frame.behind = DetourLine({ 1, 0.55, 0.2 }, { "Falling behind",
        "Your level is below the route's here, so its quests will be hard work.\n"
        .. "Kill things for a bit (see Grind spots in the panel), do a dungeon, or pick up quests you skipped." })
    frame.behind.icon:SetTexture("Interface\\Icons\\Ability_Warrior_Rampage")
    frame.behind.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.behind:SetScript("OnClick", function() end)
    frame.classLine = DetourLine({ 0.78, 0.61, 0.43 }, { "Class quest",
        "Your class's quests, from QuestieDB: the ones in your log, then the ones you can pick up now.\n"
        .. "Click: point the arrow at it (click again to stop). Right-click: leave it for 15 minutes." })
    frame.classLine.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    frame.classLine.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.classLine:SetScript("OnClick", function(_, button)
        local d = classDetour
        if not d then return end
        if button == "RightButton" then
            if DetourKey(d) == followKey then followKey = nil end
            ns.GuideSkipDetour(d)
            ns.GuideDetours(true)
        else
            followKey = (DetourKey(d) ~= followKey) and DetourKey(d) or nil
            if d.spot then ns.SetWaypoint(d.spot.mapID, d.spot.x, d.spot.y, d.title) end
        end
        UpdateDetours()
        Refresh()
    end)
    holdText = ns.Text(frame, 9, { 1, 0.6, 0.3, 1 })
    holdText:SetPoint("TOPRIGHT", -8, -24)
    -- while you're looking at another step: make it the guide's place
    frame.continue = ns.CreateButton(frame, "Continue from here", 120, 16, function()
        if not state then return end
        Want(list[cur]) -- you picked this one: don't skip it
        state.hold = false
        state.live = list[cur] and list[cur].i
        Save()
        Advance() -- past anything here that's already done
        Refresh()
        ns.Print(format("Guide: carrying on from step %d.", cur))
    end)
    frame.continue:SetPoint("TOPRIGHT", -6, -21)
    frame.continue.text:SetFont(ns.FONT, 10, "")
    frame.continue:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Continue from here", 1, 1, 1)
        GameTooltip:AddLine("You're looking at another step. Make it the guide's place, and carry on from it. "
            .. "(Current goes back to where you were instead.)", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame.continue:HookScript("OnLeave", function() GameTooltip:Hide() end)
    frame.continue:Hide()

    progress = ns.CreateBar(frame, WIDTH - 16, 5, ns.color.accent)
    progress:SetPoint("TOPLEFT", 8, -40)

    -- the zones you've followed lately: click one to go back to where you were in it
    frame.recent = {}
    for i = 1, 3 do
        local b = ns.CreateButton(frame, "", 100, 16, function(self)
            if self.zone then ns.GuideResumeZone(self.zone) end
        end)
        b.text:SetFont(ns.FONT, 9, "")
        b:HookScript("OnEnter", function(self)
            if not self.zone then return end
            local mark = state and state.zoneMarks and state.zoneMarks[self.zone]
            local j = mark and byNumber[mark]
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText((i == 1 and "Back to " or "Go to ") .. self.zone, 1, 1, 1)
            if j then GameTooltip:AddLine(format("Where you left off: step %d - %s", j, list[j].name or list[j].text or ""), 0.8, 0.8, 0.8, true) end
            GameTooltip:Show()
        end)
        b:HookScript("OnLeave", function() GameTooltip:Hide() end)
        b:Hide()
        frame.recent[i] = b
    end

    local buttons = {
        { "<<", function() ns.GuidePrevSection() end, "Previous section", "Back to the start of this section (or the one before)." },
        { "<", function() ns.GuideBack() end, "Back", "The step before. The guide waits here until you do something." },
        { "Current", function() if IsShiftKeyDown() then ns.GuideFindPlace() else ns.GuideResume() end end,
          "Current step", "Back to where you are in the route.\nShift-click: work out your place from the quests you've handed in." },
        { ">", function() ns.GuideNext() end, "Next", "Skip this step." },
        { ">>", function() ns.GuideNextSection() end, "Next section", "Skip the rest of this section (a dungeon you don't want, say)." },
        { "Zones", function() if IsShiftKeyDown() then ns.GuideHere() else ns.ToggleGuidePicker() end end, "Choose a section",
          "Pick the zone or section you want to quest in, and the guide follows from there.\nShift-click: jump to the zone you're in." },
    }
    local gap = 3
    local w = (WIDTH - 16 - gap * (#buttons - 1)) / #buttons
    frame.buttons = {}
    for i, b in ipairs(buttons) do
        local btn = ns.CreateButton(frame, b[1], w, 18, b[2])
        btn.text:SetFont(ns.FONT, 10, "")
        btn:SetPoint("BOTTOMLEFT", 8 + (i - 1) * (w + gap), 7)
        btn:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(b[3], 1, 1, 1)
            GameTooltip:AddLine(b[4], 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
        frame.buttons[i] = btn
    end

    -- mouse wheel: look up and down the route
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta)
        Go(cur + (delta > 0 and -1 or 1), "look")
    end)
end

-- 2. The current step and the ones right after it that are the same kind
-- (pick up / hand in) at the same NPC or spot: shown as one step
local function StepGroup()
    local s = list[cur]
    local group = { cur }
    if not (s and (s.t == "A" or s.t == "T")) then return group end
    local who = (s.target and s.target.name) or s.targetName
    for j = cur + 1, math.min(#list, cur + 12) do
        local n = list[j]
        if n.t ~= s.t then break end
        local nwho = (n.target and n.target.name) or n.targetName
        local same = (who and nwho == who)
            or (not who and s.x and n.x and math.abs(s.x - n.x) < 0.6 and math.abs(s.y - n.y) < 0.6)
        if not same then break end
        if not Done(n) and not Low(n) then group[#group + 1] = j end
    end
    return group
end

-- 5. "Level in 3 hand-ins": the hand-ins ahead that would take you to your next level
function XPToLevel()
    local need = (UnitXPMax("player") or 0) - (UnitXP("player") or 0)
    if need <= 0 or UnitLevel("player") >= (GetMaxPlayerLevel and GetMaxPlayerLevel() or 60) then return "" end
    local got, count = 0, 0
    for j = cur, math.min(#list, cur + 200) do
        local s = list[j]
        if s.t == "T" and not Done(s) and not Low(s) then
            local xp = StepXP(s)
            if xp then
                got = got + xp
                count = count + 1
                if got >= need then return format("|cff6fdc6flevel in %d hand-in%s|r", count, count == 1 and "" or "s") end
            end
        end
    end
    return ""
end

local shownStep
function Refresh()
    if arrow then UpdateArrow() end
    if shownStep ~= cur then
        shownStep = cur
        if ns.UpdatePanel and ns.db.guidePanel then ns.UpdatePanel() end
    end
    if not frame then return end
    local show = ns.db.guide and #list > 0
    frame:SetShown(show and true or false)
    if not show then return end
    local s = list[cur]
    header:SetText(s and s.section or "")
    local live = state.live and byNumber[state.live]
    local away = state.hold and live and live ~= cur
    counter:SetText(away and format("Step %d / %d  |cff33ff99(you're on %d)|r", cur, #list, live)
        or format("Step %d / %d", cur, #list))
    progress.bar:SetValue(#list > 1 and (cur - 1) / (#list - 1) or 1)
    holdText:SetText(state.hold and "" or XPToLevel())
    frame.continue:SetShown(state.hold and true or false)
    header:SetWidth(WIDTH - (state.hold and 140 or 70))
    frame.compact.text:SetText(ns.db.guideCompact and "+" or "-")

    local y = 50
    -- recent zones (not the one you're following now)
    local shownRecent, now = 0, ZoneOf(cur)
    local here = HereZone()
    for _, zone in ipairs(state.zoneHistory or {}) do
        if zone ~= now and shownRecent < #frame.recent and not ns.db.guideCompact then
            shownRecent = shownRecent + 1
            local b = frame.recent[shownRecent]
            b.zone = zone
            b.text:SetText((shownRecent == 1 and "< " or "") .. zone)
            b.text:SetTextColor(unpack((here and Matches(zone, here)) and { 0.4, 1, 0.6, 1 } or ns.color.gold))
            b:SetWidth(math.min(140, b.text:GetStringWidth() + 14))
            b:ClearAllPoints()
            if shownRecent == 1 then
                b:SetPoint("TOPLEFT", 8, -48)
            else
                b:SetPoint("LEFT", frame.recent[shownRecent - 1], "RIGHT", 4, 0)
            end
            b:Show()
        end
    end
    for i = shownRecent + 1, #frame.recent do frame.recent[i]:Hide() end
    if shownRecent > 0 then y = y + 18 end
    -- the detour lines, above the steps
    UpdateDetours()
    local function PlaceLine(b, d, prefix)
        if not d then
            b:Hide()
            return
        end
        local far = d.yards and format("  |cffffffff%s|r", Yards(d.yards))
            or (d.spot and "" or "  |cff999999(no map position)|r")
        b.text:SetText(prefix .. ns.GuideDetourText(d) .. far)
        b:SetHeight(b.text:GetStringHeight() + 10)
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", 4, -y)
        b:Show()
        y = y + b:GetHeight() + 3
    end
    PlaceLine(frame.nearby, nearbyDetour, "|cff33ff99NEARBY|r  ")
    -- falling behind the route: three levels or more below its quests here
    local behind = routeLevel[cur] and routeLevel[cur] - UnitLevel("player")
    if behind and behind >= 3 and not ns.db.guideCompact then
        frame.behind.text:SetText(format("|cffff8844BEHIND|r  You're %d levels under the route here (its quests are about %d). "
            .. "Grind a little, do a dungeon or pick up quests you skipped.", behind, routeLevel[cur]))
        frame.behind:SetHeight(frame.behind.text:GetStringHeight() + 10)
        frame.behind:ClearAllPoints()
        frame.behind:SetPoint("TOPLEFT", 4, -y)
        frame.behind:Show()
        y = y + frame.behind:GetHeight() + 3
    else
        frame.behind:Hide()
    end
    local following = classDetour and DetourKey(classDetour) == followKey
    PlaceLine(frame.classLine, classDetour, (following and "|cffc79c6eCLASS QUEST >|r  " or "|cffc79c6eCLASS QUEST|r  ")
        .. (classDetour and classDetour.kind == "pickup" and classDetour.level and ("|cff999999[" .. classDetour.level .. "]|r ") or ""))
    -- the steps to show: the one before, this one and the next few - leaving out
    -- grey ones when they're being skipped
    local shownSteps = {}
    local group = StepGroup()
    local inGroup = {}
    for _, j in ipairs(group) do inGroup[j] = true end
    local function Hidden(j) return j ~= cur and ((not Done(list[j]) and Low(list[j])) or inGroup[j]) end
    for j = cur - 1, math.max(1, cur - 40), -1 do
        if not Hidden(j) then shownSteps[1] = j break end
    end
    shownSteps[#shownSteps + 1] = cur
    for j = cur + 1, math.min(#list, cur + 300) do
        if #shownSteps >= (shownSteps[1] < cur and UPCOMING + 2 or UPCOMING + 1) then break end
        if not Hidden(j) then shownSteps[#shownSteps + 1] = j end
    end
    if ns.db.guideCompact then shownSteps = { cur } end
    local n = 0
    for _, j in ipairs(shownSteps) do
        n = n + 1
        local r = Row(n)
        local step = list[j]
        r.step, r.index = step, j
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", 4, -y)
        r:SetWidth(WIDTH - 8)
        r.number:SetText(j)
        local isCurrent = j == cur
        local done = Done(step)
        local title = Title(step)
        -- several pick-ups or hand-ins at one place: one step for them all
        if isCurrent and #group > 1 then
            local who = (step.target and step.target.name) or step.targetName
            title = Icon(step) .. format("%s %d quests%s", step.t == "A" and "Pick up" or "Hand in", #group,
                who and ((step.t == "A" and " from " or " at ") .. who) or "")
        end
        if done then title = "|T" .. HERE_TEXTURE .. ":12:12|t " .. title end
        if away and j == live then title = "|cff33ff99>> you're here|r  " .. title end
        local orphan = not done and Orphan(step, cur)
        local low = not done and not orphan and Low(step)
        if orphan then title = title .. "  |cff777777(not in your log)|r" end
        if low then title = title .. "  |cff777777(no XP)|r" end
        r.text:SetText(title)
        r.stripe:SetShown(done)
        if isCurrent then
            r.text:SetFont(ns.FONT, 12, "")
            r.text:SetTextColor(1, 1, 1)
            r.text:SetWordWrap(true)
            local details = Details(step)
            if #group > 1 then
                local items = {}
                for _, j2 in ipairs(group) do
                    local g = list[j2]
                    local xp2 = g.t == "T" and StepXP(g)
                    items[#items + 1] = (Done(g) and "|cff6fdc6f+ " or "|cffffffff- ") .. (g.name or "?") .. "|r"
                        .. (xp2 and format("  |cff6fdc6f+%s|r", ns.Short and ns.Short(xp2) or xp2) or "")
                end
                details = table.concat(items, "\n") .. "\n" .. details
            end
            r.sub:SetText(details)
            r.sub:Show()
            r:SetBackdropColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.18)
            r:SetBackdropBorderColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.7)
        else
            r.text:SetFont(ns.FONT, 11, "")
            local c = done and { 0.55, 0.85, 0.55 } or ((j < cur or orphan or low) and { 0.5, 0.5, 0.5 } or { 0.75, 0.75, 0.75 })
            r.text:SetTextColor(c[1], c[2], c[3])
            r.text:SetWordWrap(false)
            r.sub:SetText("")
            r.sub:Hide()
            if away and j == live then
                r:SetBackdropColor(0.2, 0.9, 0.5, 0.12)
                r:SetBackdropBorderColor(0.2, 0.9, 0.5, 0.6)
            elseif done then
                r:SetBackdropColor(0.3, 0.8, 0.3, 0.10)
                r:SetBackdropBorderColor(0, 0, 0, 0)
            else
                r:SetBackdropColor(0, 0, 0, 0)
                r:SetBackdropBorderColor(0, 0, 0, 0)
            end
        end
        local h = r.text:GetStringHeight() + 8
        if isCurrent and r.sub:GetText() ~= "" then h = h + r.sub:GetStringHeight() + 3 end
        r:SetHeight(h)
        r:Show()
        y = y + h + 1
    end
    for i = n + 1, #rows do rows[i]:Hide() end
    if zoneHint and sectionOf[cur] == zoneHint then zoneHint = nil end -- already following it
    local offer = zoneHint and sections[zoneHint]
    if offer then
        local done, total = SectionProgress(offer)
        frame.hint.text:SetText(format("You're in |cffffd200%s|r - follow |cff33ff99%s|r instead? (%d of %d left)",
            offer.zone or "this zone", offer.name, total - done, total))
        frame.hint:ClearAllPoints()
        frame.hint:SetPoint("TOPLEFT", 4, -(y + 2))
        frame.hint:Show()
        y = y + 34
    else
        frame.hint:Hide()
    end
    frame:SetHeight(y + 30)
end

---------------------------------------------------------------------------
-- The section list
---------------------------------------------------------------------------
local PICKER_ROWS = 16
local picker, pickerOffset, pickerHereOnly = nil, 0, false

local function PickerSections()
    if not pickerHereOnly then return sections end
    local zone, out = HereZone(), {}
    for k, sec in ipairs(sections) do
        if zone and sec.zone and Matches(sec.zone, zone) then out[#out + 1] = sec end
    end
    return out
end

-- Searching the route: every step whose quest, NPC, place, note, zone or
-- section mentions the text (lower case), in route order
local pickerSearch = ""
local SEARCH_MAX = 200

local function SearchSteps(text)
    local out = {}
    if #text < 2 then return out end
    for j, s in ipairs(list) do
        local fields = { s.name, s.text, s.note, s.zoneName, s.section, s.dungeonName,
                         s.target and s.target.name, s.targetName }
        for _, f in pairs(fields) do
            if type(f) == "string" and f:lower():find(text, 1, true) then
                out[#out + 1] = j
                break
            end
        end
        if #out >= SEARCH_MAX then break end
    end
    return out
end

-- what the list is showing: search results (step indexes) or sections
local function PickerItems()
    if #pickerSearch >= 2 then return SearchSteps(pickerSearch), true end
    return PickerSections(), false
end

local function BuildPicker()
    picker = CreateFrame("Frame", "HearthboundGuidePicker", frame, ns.BACKDROP)
    picker:SetSize(330, PICKER_ROWS * 20 + 90)
    picker:SetFrameStrata("DIALOG")
    picker:SetClampedToScreen(true)
    picker:EnableMouse(true)
    ns.Skin(picker, { 0.05, 0.05, 0.06, 0.97 }, ns.color.gold)
    local title = ns.Text(picker, 10, ns.color.gold)
    title:SetPoint("TOPLEFT", 10, -9)
    title:SetText("SECTIONS & SEARCH")
    local close = ns.CreateButton(picker, "x", 16, 16, function() picker:Hide() end)
    close:SetPoint("TOPRIGHT", -5, -5)
    close.text:SetFont(ns.FONT, 10, "")

    -- search box: type part of a quest, NPC or place to find its step
    local search = ns.CreateEditBox(picker, 314, 20, "Search quests, NPCs, places...")
    search:SetPoint("TOPLEFT", 8, -26)
    search:SetFont(ns.FONT, 11, "")
    search:HookScript("OnTextChanged", function(box)
        pickerSearch = strtrim(box:GetText() or ""):lower()
        pickerOffset = 0
        RefreshPicker()
    end)
    picker.search = search

    local here = ns.CreateButton(picker, "Where I am", 100, 18, function() ns.GuideHere() end)
    here.text:SetFont(ns.FONT, 10, "")
    here:SetPoint("TOPLEFT", 8, -52)
    local filter = ns.CreateButton(picker, "", 120, 18, function(self)
        pickerHereOnly = not pickerHereOnly
        pickerOffset = 0
        RefreshPicker()
    end)
    filter.text:SetFont(ns.FONT, 10, "")
    filter:SetPoint("LEFT", here, "RIGHT", 6, 0)
    picker.filter = filter

    picker.rows = {}
    for i = 1, PICKER_ROWS do
        local r = CreateFrame("Button", nil, picker, ns.BACKDROP)
        ns.Skin(r, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
        r:SetSize(314, 19)
        r:SetPoint("TOPLEFT", 8, -74 - (i - 1) * 20)
        r.left = ns.Text(r, 11)
        r.left:SetPoint("LEFT", 4, 0)
        r.left:SetWidth(200)
        r.left:SetJustifyH("LEFT")
        r.left:SetWordWrap(false)
        r.right = ns.Text(r, 10, ns.color.dim)
        r.right:SetPoint("RIGHT", -4, 0)
        r.right:SetWidth(106)
        r.right:SetJustifyH("RIGHT")
        r.right:SetWordWrap(false)
        local hl = r:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(0.78, 0.61, 0.43, 0.15)
        r:SetScript("OnClick", function(self)
            if self.j then
                -- go and look at that step; Continue from here makes it the guide's place
                Go(self.j, "look")
                ns.Print(format("Guide: showing step %d. Press |cffffd200Continue from here|r to carry on from it.", self.j))
                RefreshPicker()
            elseif self.k then
                ns.GuideJumpSection(self.k)
            end
        end)
        r:SetScript("OnEnter", function(self)
            if self.j then
                local s = list[self.j]
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(Title(s), 1, 1, 1, 1, true)
                GameTooltip:AddLine(Details(s), 0.8, 0.8, 0.8, true)
                GameTooltip:AddLine(format("Step %d  -  %s", self.j, s.section or ""), 0.78, 0.61, 0.43, true)
                GameTooltip:AddLine("Click: go to this step", 0.6, 0.6, 0.6)
                GameTooltip:Show()
                return
            end
            local sec = self.k and sections[self.k]
            if not sec then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(sec.name, 1, 1, 1, 1, true)
            GameTooltip:AddLine((sec.zone or "?") .. format("  -  steps %d to %d", sec.first, sec.last), 0.8, 0.8, 0.8)
            local done, total = SectionProgress(sec)
            GameTooltip:AddLine(format("%d of %d done", done, total), 0.6, 0.85, 0.6)
            GameTooltip:AddLine("Click: follow this section", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        picker.rows[i] = r
    end
    picker.empty = ns.Text(picker, 11, ns.color.dim)
    picker.empty:SetPoint("TOP", 0, -86)
    picker:EnableMouseWheel(true)
    picker:SetScript("OnMouseWheel", function(_, delta)
        local max = math.max(0, #(PickerItems()) - PICKER_ROWS)
        pickerOffset = math.max(0, math.min(max, pickerOffset - delta * 3))
        RefreshPicker()
    end)
    picker.scroll = ns.Text(picker, 9, ns.color.dim)
    picker.scroll:SetPoint("BOTTOMRIGHT", -10, 6)
    picker:Hide()
end

function RefreshPicker()
    if not (picker and picker:IsShown()) then return end
    local shown, searching = PickerItems()
    local zone = HereZone()
    local mine = sectionOf[cur]
    picker.filter.text:SetText(pickerHereOnly and "Show all zones" or ("Only " .. (zone or "this zone")))
    if searching then
        picker.empty:SetText(#shown == 0 and "No steps match." or "")
        for i, r in ipairs(picker.rows) do
            local j = shown[pickerOffset + i]
            r.k = nil
            r.j = j
            if j then
                local s = list[j]
                local done = Done(s)
                r.left:SetText(format("|cff999999%d|r  %s%s", j, done and ("|T" .. HERE_TEXTURE .. ":11:11|t ") or "", Title(s)))
                r.left:SetTextColor(unpack(done and { 0.5, 0.6, 0.5, 1 } or ns.color.text))
                local secZone = sections[sectionOf[j]] and sections[sectionOf[j]].zone
                r.right:SetText(s.zoneName or secZone or "")
                if j == cur then
                    r:SetBackdropColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.25)
                    r:SetBackdropBorderColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.7)
                else
                    r:SetBackdropColor(0, 0, 0, 0)
                    r:SetBackdropBorderColor(0, 0, 0, 0)
                end
                r:Show()
            else
                r:Hide()
            end
        end
        local max = #shown - PICKER_ROWS
        picker.scroll:SetText(max > 0 and format("%d-%d of %d%s  (scroll)", pickerOffset + 1,
            math.min(#shown, pickerOffset + PICKER_ROWS), #shown, #shown >= SEARCH_MAX and "+" or "") or "")
        return
    end
    picker.empty:SetText(#shown == 0 and ("Nothing in " .. (zone or "this zone") .. " for you.") or "")
    for i, r in ipairs(picker.rows) do
        r.j = nil
        local sec = shown[pickerOffset + i]
        if sec then
            local k
            for n, other in ipairs(sections) do if other == sec then k = n break end end
            local done, total = SectionProgress(sec)
            local finished = done >= total
            local inHere = zone and sec.zone and Matches(sec.zone, zone)
            r.k = k
            r.left:SetText((finished and "|T" .. HERE_TEXTURE .. ":11:11|t " or "") .. sec.name)
            r.left:SetTextColor(unpack(finished and { 0.5, 0.6, 0.5, 1 } or (inHere and { 0.4, 1, 0.6, 1 } or ns.color.text)))
            r.right:SetText(format("%s  %d/%d", sec.zone or "", done, total))
            if k == mine then
                r:SetBackdropColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.25)
                r:SetBackdropBorderColor(ns.color.accent[1], ns.color.accent[2], ns.color.accent[3], 0.7)
            else
                r:SetBackdropColor(0, 0, 0, 0)
                r:SetBackdropBorderColor(0, 0, 0, 0)
            end
            r:Show()
        else
            r.k = nil
            r:Hide()
        end
    end
    local max = #shown - PICKER_ROWS
    picker.scroll:SetText(max > 0 and format("%d-%d of %d  (scroll)", pickerOffset + 1,
        math.min(#shown, pickerOffset + PICKER_ROWS), #shown) or "")
end

function ns.ToggleGuidePicker()
    if not frame or #sections == 0 then return end
    if not picker then BuildPicker() end
    if picker:IsShown() then return picker:Hide() end
    -- beside the guide, on whichever side has room
    picker:ClearAllPoints()
    if (frame:GetLeft() or 0) > 340 then
        picker:SetPoint("TOPRIGHT", frame, "TOPLEFT", -4, 0)
    else
        picker:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
    end
    pickerOffset = math.max(0, math.min((sectionOf[cur] or 1) - 3, #sections - PICKER_ROWS))
    picker:Show()
    RefreshPicker()
end

---------------------------------------------------------------------------
-- The arrow
---------------------------------------------------------------------------
local function SaveArrowPosition()
    local p, _, rp, x, y = arrow:GetPoint()
    ns.db.positions.guideArrow = { p, rp, x, y }
end

local function BuildArrow()
    arrow = CreateFrame("Button", "HearthboundGuideArrow", UIParent)
    arrow:SetSize(70, 90)
    arrow:SetClampedToScreen(true)
    arrow:SetMovable(true)
    arrow:RegisterForDrag("LeftButton")
    arrow:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    arrow:SetScript("OnDragStart", arrow.StartMoving)
    arrow:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveArrowPosition()
    end)
    local pos = ns.db.positions.guideArrow
    if pos then arrow:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else arrow:SetPoint("TOP", 0, -120) end

    arrow.icon = arrow:CreateTexture(nil, "ARTWORK")
    arrow.icon:SetSize(52, 52)
    arrow.icon:SetPoint("TOP", 0, -2)
    arrow.icon:SetTexture(ARROW_TEXTURE)
    arrow.dist = ns.Text(arrow, 13, ns.color.text, "OUTLINE")
    arrow.dist:SetPoint("TOP", arrow.icon, "BOTTOM", 0, -2)
    arrow.label = ns.Text(arrow, 10, ns.color.gold, "OUTLINE")
    arrow.label:SetPoint("TOP", arrow.dist, "BOTTOM", 0, -2)
    arrow.label:SetWidth(220)
    arrow.label:SetWordWrap(false)

    arrow:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            ns.db.guideArrow = false
            ns.RefreshAll()
            ns.Print("Guide arrow hidden. |cffc79c6e/hb guide arrow|r brings it back.")
            return
        end
        local s = ArrowStep()
        local t = s and Target(s)
        if t then ns.SetWaypoint(t.mapID, t.x or s.x, t.y or s.y, s.name or s.text or "Guide") end
    end)
    arrow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Guide arrow", 1, 1, 1)
        GameTooltip:AddLine("Points at the current guide step.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Drag to move - click: map marker - right-click: hide", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local elapsed = 0
    arrow:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < 0.03 then return end
        elapsed = 0
        UpdateArrow()
    end)
end

local function Label(s)
    if s.arrowLabel then return s.arrowLabel end
    local text = s.name or s.text or ""
    if s.t == "A" then text = "Accept: " .. text elseif s.t == "T" then text = "Turn in: " .. text end
    return text
end

-- what the arrow last showed, so text is only rebuilt when it changes
local arrowStep, arrowYards, arrowState

local function ArrowText(state, yards)
    if state == arrowState and yards == arrowYards then return end
    arrowState, arrowYards = state, yards
    arrow.dist:SetText(state == "far" and Yards(yards) or state)
end

function UpdateArrow()
    local s = ArrowStep()
    if not (ns.db.guideArrow and ns.db.guide and s and ((s.x and s.y) or Target(s))) then
        arrow:Hide()
        return
    end
    -- inside the dungeon a step is in: no arrow needed
    if s.dungeonName and InDungeon(s.dungeonName) then
        arrow:Hide()
        return
    end
    arrow:Show()
    if arrowStep ~= s then
        arrowStep = s
        arrow.label:SetText(Label(s))
    end
    local d, angle = Vector(s)
    if not d then
        arrow.icon:SetTexture(ARROW_TEXTURE)
        arrow.icon:SetRotation(0)
        arrow.icon:SetVertexColor(0.5, 0.5, 0.5)
        ArrowText(angle == "continent" and "Other continent" or (angle == "none" and "no map position" or "finding you..."))
        return
    end
    if d <= ARRIVE_YARDS then
        arrow.icon:SetTexture(HERE_TEXTURE)
        arrow.icon:SetRotation(0)
        arrow.icon:SetVertexColor(1, 1, 1)
        ArrowText("Here")
        return
    end
    arrow.icon:SetTexture(ARROW_TEXTURE)
    ArrowText("far", math.floor(d + 0.5))
    local ok, facing = false, nil
    if GetPlayerFacing then ok, facing = pcall(GetPlayerFacing) end
    if not ok or type(facing) ~= "number" or ns.IsSecret(facing) then
        arrow.icon:SetRotation(0)
        arrow.icon:SetVertexColor(0.6, 0.6, 0.6)
        return
    end
    local rel = (angle - facing + (ns.db.guideArrowTurned and math.pi or 0)) % (2 * math.pi)
    arrow.icon:SetRotation(rel)
    -- green straight ahead, through yellow, to red behind you
    local off = math.abs(rel > math.pi and rel - 2 * math.pi or rel) / math.pi
    if off < 0.5 then
        arrow.icon:SetVertexColor(off * 2, 1, 0.2)
    else
        arrow.icon:SetVertexColor(1, 1 - (off - 0.5) * 2, 0.2)
    end
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Class quests in the route: QuestieDB's quests for your class (GuideDetours
-- reads them) become pick up / complete / hand in steps, placed where their
-- level fits the route - in the zone they start in if that's close by - with
-- each chain's parts in order. Quests the route data already has are left alone.
---------------------------------------------------------------------------
local CLASS_STEP_BASE = 1000000 -- step numbers for class quest steps (stable, so saved progress keeps)

local function QGet(id, field) return ns.QuestieGet and ns.QuestieGet("Quest", id, field) end

local function MapName(mapID)
    local info = mapID and Safe(C_Map.GetMapInfo, mapID)
    return info and info.name or nil
end

-- the spawn spots of the NPCs / objects in a {{npcs}, {objects}} list, and the first one's name
local function SpotsOf(list)
    local spots, who = {}, nil
    if type(list) ~= "table" or not ns.QuestieSpawnSpots then return spots end
    for _, npcId in ipairs(type(list[1]) == "table" and list[1] or {}) do
        for _, sp in ipairs(ns.QuestieSpawnSpots("Npc", npcId)) do spots[#spots + 1] = sp end
        who = who or (ns.QuestieGet and ns.QuestieGet("Npc", npcId, "name"))
    end
    for _, objectId in ipairs(type(list[2]) == "table" and list[2] or {}) do
        for _, sp in ipairs(ns.QuestieSpawnSpots("Object", objectId)) do spots[#spots + 1] = sp end
        who = who or (ns.QuestieGet and ns.QuestieGet("Object", objectId, "name"))
    end
    return spots, who
end

-- where a quest's first unfinished-looking objective is: kill targets, then item droppers
local function ObjectiveSpots(id)
    local o = QGet(id, "objectives")
    if type(o) ~= "table" then return {} end
    local spots = {}
    for _, c in ipairs(type(o[1]) == "table" and o[1] or {}) do
        local npcId = type(c) == "table" and c[1] or c
        for _, sp in ipairs(ns.QuestieSpawnSpots("Npc", npcId)) do spots[#spots + 1] = sp end
    end
    if #spots == 0 then
        for _, c in ipairs(type(o[3]) == "table" and o[3] or {}) do
            local itemId = type(c) == "table" and c[1] or c
            local drops = ns.QuestieGet and ns.QuestieGet("Item", itemId, "npcDrops")
            for _, npcId in ipairs(type(drops) == "table" and drops or {}) do
                for _, sp in ipairs(ns.QuestieSpawnSpots("Npc", npcId)) do spots[#spots + 1] = sp end
                if #spots > 40 then break end
            end
        end
    end
    return spots
end

-- the spot on the given map if there is one, else the first
local function Pick(spots, mapID)
    for _, sp in ipairs(spots) do if sp.mapID == mapID then return sp end end
    return spots[1]
end

local function ClassStep(t, id, k, name, spot, who, level)
    return { t = t, q = id, name = name, classQuest = true, i = CLASS_STEP_BASE + id * 4 + k,
             mapID = spot and spot.mapID, x = spot and spot.x, y = spot and spot.y,
             zoneName = spot and MapName(spot.mapID),
             target = nil, -- (the Target cache works it out from mapID)
             targetName = who, note = who and ((t == "T" and "To " or (t == "A" and "From " or "")) .. who) or nil,
             level = level }
end

-- route (a list of steps) -> the same with class quests merged in
local function MergeClassQuests(route)
    local ids = ns.db.guideClassQuests and ns.GuideClassQuests and ns.GuideClassQuests()
    if not (ids and #ids > 0 and ns.QuestieFitsYou) then return route end
    local inRoute = {}
    for _, s in ipairs(route) do if s.q then inRoute[s.q] = true end end
    -- the route's level at each step: the quest levels so far (ignoring the odd high one)
    local levelAt, level = {}, 1
    for j, s in ipairs(route) do
        local l = s.q and QuestLevel(s.q)
        if l and l > level and l - level <= 4 then level = l end
        levelAt[j] = level
    end
    -- your class's quests, by level, then chain order; versions of one quest (the
    -- same name - you do one of them) become one set of steps
    local quests, byName = {}, {}
    for _, id in ipairs(ids) do
        local why = ns.QuestieWhyNot and ns.QuestieWhyNot(id)
        local ruledOut = type(why) == "string" and why:find("^you did ") -- another quest instead
        if not inRoute[id] and not ruledOut and ns.QuestieFitsYou(id) then
            local name = QGet(id, "name") or ("Quest " .. id)
            local group = byName[name]
            if group then
                group.alts[#group.alts + 1] = id
                if id < group.id then group.id = id end
            else
                local req = QGet(id, "requiredLevel") or 0
                local lvl = QGet(id, "questLevel") or req
                group = { id = id, alts = { id }, at = math.max(1, req > 0 and req or (lvl or 1)), level = lvl }
                byName[name] = group
                quests[#quests + 1] = group
            end
        end
    end
    table.sort(quests, function(a, b)
        if a.at ~= b.at then return a.at < b.at end
        return a.id < b.id
    end)
    local before = {} -- route index -> class steps to go in before it
    local placed = {} -- quest -> the route index it went in at
    for _, cq in ipairs(quests) do
        -- where its level fits
        local j = #route + 1
        for k = 1, #route do
            if levelAt[k] >= cq.at then j = k break end
        end
        -- not before the quests it needs done first
        for _, field in ipairs({ "preQuestSingle", "preQuestGroup" }) do
            local pre = QGet(cq.id, field)
            for _, p in ipairs(type(pre) == "table" and pre or {}) do
                if placed[p] and placed[p] > j then j = placed[p] end
            end
        end
        local giverSpots, giver = SpotsOf(QGet(cq.id, "startedBy"))
        -- the giver's zone, if the route passes through it soon
        for k = j, math.min(#route, j + 40) do
            local m = MapFor(route[k])
            local hit = false
            for _, sp in ipairs(giverSpots) do if sp.mapID == m then hit = true break end end
            if hit then j = k break end
        end
        local anchor = route[math.min(j, #route)]
        local here = anchor and MapFor(anchor)
        local name = QGet(cq.id, "name") or ("Quest " .. cq.id)
        local finishSpots, finisher = SpotsOf(QGet(cq.id, "finishedBy"))
        local steps = {
            ClassStep("A", cq.id, 0, name, Pick(giverSpots, here), giver, cq.level),
            ClassStep("C", cq.id, 1, name, Pick(ObjectiveSpots(cq.id), here), nil, cq.level),
            ClassStep("T", cq.id, 2, name, Pick(finishSpots, here), finisher, cq.level),
        }
        -- no objective to go to (talk to someone, use an item): just pick up and hand in
        if not steps[2].x then table.remove(steps, 2) end
        for _, st in ipairs(steps) do
            st.section = anchor and anchor.section or "Class quests"
            if #cq.alts > 1 then st.alts = cq.alts end
        end
        before[j] = before[j] or {}
        for _, st in ipairs(steps) do table.insert(before[j], st) end
        for _, id in ipairs(cq.alts) do placed[id] = j end
    end
    local merged = {}
    for j = 1, #route + 1 do
        for _, st in ipairs(before[j] or {}) do merged[#merged + 1] = st end
        if route[j] then merged[#merged + 1] = route[j] end
    end
    return merged
end

local function QStepLevel(s)
    return s.level or QuestLevel(s.q)
end

local function Load()
    local guides = ns.HordeGuides or {}
    edition = guides[ns.db.guideEdition] and ns.db.guideEdition or (guides.forever and "forever" or "classic")
    local data = guides[edition] or {}
    local race, class = PlayerRace(), PlayerClass()
    list, byNumber, targets, acceptAt = {}, {}, {}, {}
    local route = {}
    for n, s in ipairs(data) do
        s.i = s.i or n
        if Applies(s, race, class) then route[#route + 1] = s end
    end
    local level = 1
    routeLevel = {}
    for _, s in ipairs(MergeClassQuests(route)) do
        list[#list + 1] = s
        byNumber[s.i] = #list
        -- the route's level here: its quest levels so far, ignoring the odd high one
        local l = s.q and QStepLevel(s)
        if l and l > level and l - level <= 4 then level = l end
        routeLevel[#list] = level
        if s.t == "A" and s.q and not acceptAt[s.q] then acceptAt[s.q] = #list end
        for _, id in ipairs(s.t == "A" and s.alts or {}) do acceptAt[id] = acceptAt[id] or #list end
    end
    -- the route's sections, each with the zone most of its steps are in
    sections, sectionOf, zoneHint = {}, {}, nil
    for j, s in ipairs(list) do
        local sec = sections[#sections]
        if not sec or sec.name ~= (s.section or "") then
            sec = { name = s.section or "", first = j, counts = {} }
            sections[#sections + 1] = sec
        end
        sec.last = j
        sectionOf[j] = #sections
        if s.zoneName then sec.counts[s.zoneName] = (sec.counts[s.zoneName] or 0) + 1 end
    end
    for _, sec in ipairs(sections) do
        local best = 0
        for zone, n in pairs(sec.counts) do
            if n > best then sec.zone, best = zone, n end
        end
        sec.counts = nil
    end
    ns.cdb.guide = ns.cdb.guide or {}
    ns.cdb.guide[edition] = ns.cdb.guide[edition] or { done = {} }
    state = ns.cdb.guide[edition]
    state.done = state.done or {}
    if state.pos and byNumber[state.pos] then
        cur = byNumber[state.pos]
        Advance()
    else
        FindPlace()
    end
end

-- 1. The next few steps that are still to do and have a place, for the map:
-- { { step, index, target = { mapID, continent, wx, wy } } }
function ns.GuideRouteAhead(count)
    local out = {}
    if not state or #list == 0 then return out end
    for j = cur, math.min(#list, cur + 200) do
        local s = list[j]
        if not Done(s) and not Low(s) and s.x and s.y then
            local t = Target(s)
            if t and t.mapID then
                out[#out + 1] = { step = s, index = j, target = t, title = Title(s) }
                if #out >= (count or 6) then break end
            end
        end
    end
    return out
end

-- 9. Key bindings (Bindings.xml) call these
function ns.GuideBindingNext() if state then ns.GuideNext() end end
function ns.GuideBindingBack() if state then ns.GuideBack() end end
function ns.GuideBindingCurrent() if state then ns.GuideResume() end end
function ns.GuideBindingFind() ns.GuideCommand("find") end
function ns.GuideBindingArrow() ns.GuideCommand("arrow") end
function ns.GuideBindingToggle() ns.ToggleGuide() end

-- the names the game's Key Bindings menu shows (under AddOns > Hearthbound)
BINDING_HEADER_HEARTHBOUND = "Hearthbound"
BINDING_NAME_HEARTHBOUNDGUIDE_NEXT = "Guide: next step"
BINDING_NAME_HEARTHBOUNDGUIDE_BACK = "Guide: previous step"
BINDING_NAME_HEARTHBOUNDGUIDE_CURRENT = "Guide: back to the current step"
BINDING_NAME_HEARTHBOUNDGUIDE_FIND = "Guide: find my place"
BINDING_NAME_HEARTHBOUNDGUIDE_ARROW = "Guide: arrow on / off"
BINDING_NAME_HEARTHBOUNDGUIDE_TOGGLE = "Guide: show / hide"
function Hearthbound_GuideKey(which)
    local fn = ns["GuideBinding" .. which]
    if fn then fn() end
end

-- the current step, for the panel and anyone else
function ns.GuideCurrent()
    return list[cur], cur, #list
end
ns.GuideStepTitle = function(s) return s and Title(s) or "" end

-- switch route quietly (the setup screen); /hb guide forever|classic says so in chat
function ns.GuideSetEdition(name)
    if not (ns.HordeGuides and ns.HordeGuides[name]) then return end
    ns.db.guideEdition = name
    if state and edition ~= name then
        Load()
        Refresh()
    end
end

function ns.ToggleGuide()
    ns.db.guide = not ns.db.guide
    ns.RefreshAll()
end

function ns.GuideCommand(arg)
    arg = (arg or ""):lower()
    if UnitFactionGroup("player") ~= "Horde" then
        return ns.Print("The levelling guide is a Horde route - it doesn't cover your faction yet.")
    end
    if not state then return ns.Print("The guide is still loading - try again in a moment.") end
    if arg == "find" then return ns.GuideFindPlace() end
    if arg == "zones" or arg == "sections" then return ns.ToggleGuidePicker() end
    if arg:find("^search") then
        local text = strtrim(arg:sub(7))
        if not (picker and picker:IsShown()) then ns.ToggleGuidePicker() end
        if picker then picker.search:SetText(text) picker.search:SetFocus() end
        return
    end
    if arg == "here" then return ns.GuideHere() end
    if arg == "back" or arg == "previous" then return ns.GuidePreviousZone() end
    if arg == "compact" then
        ns.db.guideCompact = not ns.db.guideCompact
        Refresh()
        return ns.Print("Guide: " .. (ns.db.guideCompact and "compact (current step only)" or "full list") .. ".")
    end
    if arg == "unskip" then
        ns.db.guideNever = {}
        Evaluate()
        return ns.Print("Guide: no quests are being skipped on purpose any more.")
    end
    if arg == "grey" or arg == "gray" then
        ns.db.guideSkipGrey = not ns.db.guideSkipGrey
        ns.RefreshAll()
        if not ns.db.guideSkipGrey then state.hold = false end
        Evaluate()
        return ns.Print("Guide: quests too low for XP are " .. (ns.db.guideSkipGrey and "|cff6fdc6fskipped|r" or "|cffffd200shown|r") .. ".")
    end
    if arg == "arrow debug" then
        local s = list[cur]
        local t = s and Target(s)
        local pc, px, py = ns.PlayerWorldPos()
        local d, angle = Vector(s or {})
        local facing = GetPlayerFacing and Safe(GetPlayerFacing)
        ns.Print(format("Arrow: HereBeDragons %s, flip %s", Dragons() and "yes" or "|cffff5544no|r",
            ns.db.guideArrowTurned and "on" or "off"))
        ns.Print(format("Step %d: %s %.1f, %.1f -> map %s, world %s", cur, s and s.zoneName or "?", s and s.x or 0,
            s and s.y or 0, tostring(t and t.mapID), t and t.wx and format("%.0f, %.0f (cont %s)", t.wx, t.wy, tostring(t.continent)) or "?"))
        ns.Print(format("You: world %s", px and format("%.0f, %.0f (cont %s)", px, py, tostring(pc)) or "?"))
        if type(d) == "number" and type(facing) == "number" then
            ns.Print(format("Distance %.0f yd, target bearing %.0f, facing %.0f, arrow %.0f (degrees anticlockwise from north)",
                d, math.deg(angle), math.deg(facing), math.deg((angle - facing) % (2 * math.pi))))
        end
        return
    end
    if arg == "flip" then
        ns.db.guideArrowTurned = not ns.db.guideArrowTurned
        return ns.Print("Guide arrow turned round: " .. (ns.db.guideArrowTurned and "|cff6fdc6fon|r" or "off"))
    end
    if arg == "arrow" then
        ns.db.guideArrow = not ns.db.guideArrow
        ns.RefreshAll()
        return ns.Print("Guide arrow: " .. (ns.db.guideArrow and "|cff6fdc6fon|r" or "|cffff5544off|r"))
    end
    if arg == "reset" then
        ns.cdb.guide[edition] = { done = {} }
        Load()
        Refresh()
        return ns.Print("Guide progress reset - picked up again from your completed quests.")
    end
    if arg == "classic" or arg == "forever" then
        if not (ns.HordeGuides and ns.HordeGuides[arg]) then return ns.Print("No " .. arg .. " route is loaded.") end
        ns.db.guideEdition = arg
        Load()
        Refresh()
        return ns.Print("Guide: using the " .. arg .. " route.")
    end
    if arg ~= "" and tonumber(arg) then return Go(tonumber(arg), tonumber(arg) < cur and "back" or nil) end
    ns.ToggleGuide()
end

-- a line in the panel with the current step
ns.AddSection(5, function(add)
    if not (ns.db.guidePanel and #list > 0) then return end
    local s = list[cur]
    if not s then return end
    add.header("Guide", { icon = I .. "INV_Misc_Map_01" })
    add.note(Title(s), ns.color.text, function(button)
        if button == "RightButton" then ns.GuideNext() else ns.ToggleGuide() end
    end, format("Step %d of %d - %s\nClick: show or hide the guide. Right-click: skip this step.", cur, #list, s.section or ""))
end)

table.insert(ns.inits, function()
    if UnitFactionGroup("player") ~= "Horde" and UnitFactionGroup("player") ~= nil then return end
    local function Start()
        if state then return end
        Load()
        BuildWindow()
        BuildArrow()
        Refresh()
        if ns.UpdatePanel then ns.UpdatePanel() end
    end
    ns.On("PLAYER_LOGIN", function() C_Timer.After(2, Start) end)
    -- the class quest list arrives a little after login: rebuild the route with them in
    -- (your place is kept by step number)
    local classSetting = ns.db.guideClassQuests
    local function Rebuild()
        if not state then return end
        classSetting = ns.db.guideClassQuests
        Load()
        Refresh()
    end
    if ns.OnGuideClassQuests then ns.OnGuideClassQuests(function() C_Timer.After(0, Rebuild) end) end

    for _, event in ipairs({ "QUEST_ACCEPTED", "QUEST_TURNED_IN" }) do
        ns.On(event, function()
            if not state then return end
            state.hold = false -- you've moved on: follow along again
            QueueEvaluate(0.5)
        end)
    end
    -- quests not in your log are only passed by once the log has arrived
    ns.On("QUEST_LOG_UPDATE", function()
        if questLogReady then return end
        C_Timer.After(1, function() questLogReady = true end)
    end)
    -- a new level turns more quests grey
    ns.On("PLAYER_LEVEL_UP", function() if state then QueueEvaluate(1) end end)
    for _, event in ipairs({ "QUEST_LOG_UPDATE", "QUEST_REMOVED", "UNIT_QUEST_LOG_CHANGED", "HEARTHSTONE_BOUND",
                             "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED_INDOORS", "PLAYER_CONTROL_GAINED",
                             "PLAYER_ENTERING_WORLD" }) do
        ns.On(event, function() if state then QueueEvaluate(0.5) end end)
    end
    -- a new zone: ask whether to switch to its section if the guide is somewhere else
    -- (and again once you've landed, or the fight's over, if it couldn't ask then)
    for _, event in ipairs({ "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD", "PLAYER_CONTROL_GAINED", "PLAYER_REGEN_ENABLED" }) do
        ns.On(event, function()
            if not state then return end
            C_Timer.After(2, function()
                CheckZoneHint()
                PromptZone()
                Refresh()
            end)
        end)
    end
    ns.On("TAXIMAP_OPENED", function()
        local s = state and list[cur]
        if s and s.t == "FP" then state.done[s.i] = true QueueEvaluate(0.1) end
    end)
    ns.On("TRAINER_SHOW", function()
        local s = state and list[cur]
        if s and s.t == "TR" then state.done[s.i] = true QueueEvaluate(0.1) end
    end)
    -- distances, arriving and landing: checked every second
    C_Timer.NewTicker(1, function() if state then Evaluate() end end)
    table.insert(ns.refreshers, function()
        if not state then return end
        -- class quests switched on or off in Settings: the route changes
        if ns.db.guideClassQuests ~= classSetting then return Rebuild() end
        Refresh()
    end)
end)
