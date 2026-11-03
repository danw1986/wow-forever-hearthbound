local ADDON_NAME, ns = ...

-- The Stats tab: session summary, where your XP comes from, the best mobs in
-- your current zone and totals from your quest log.

local floor, format = math.floor, string.format
local Safe = ns.Safe

local TOP_MOBS, TOP_ZONES = 6, 4
local COLOR_QUEST = { 0.30, 0.55, 0.95 }
local COLOR_KILL = { 0.80, 0.25, 0.18 }
local COLOR_OTHER = { 0.50, 0.50, 0.52 }

local page, leftView, rightView

---------------------------------------------------------------------------
-- Zone time, for kill XP per hour
---------------------------------------------------------------------------
local function TickZone()
    local zone = Safe(GetRealZoneText)
    if zone then ns.cdb.zoneTime[zone] = (ns.cdb.zoneTime[zone] or 0) + 1 end
end

---------------------------------------------------------------------------
-- Sections
---------------------------------------------------------------------------
local function Pct(part, whole)
    if whole <= 0 then return 0 end
    return part / whole
end

local function SourceBars(add, quest, kill, total)
    total = math.max(total, quest + kill)
    if total <= 0 then
        add.note("No XP yet.", ns.color.dim)
        return
    end
    local other = total - quest - kill
    add.bar(Pct(quest, total), "Quests", format("%s  %d%%", ns.Short(quest), floor(Pct(quest, total) * 100 + 0.5)), COLOR_QUEST)
    add.bar(Pct(kill, total), "Kills", format("%s  %d%%", ns.Short(kill), floor(Pct(kill, total) * 100 + 0.5)), COLOR_KILL)
    add.bar(Pct(other, total), "Other", format("%s  %d%%", ns.Short(other), floor(Pct(other, total) * 100 + 0.5)), COLOR_OTHER)
end

local function BuildLeft(add)
    local s = ns.Session()
    local level = UnitLevel("player")
    add.header("This session")
    add.row("Played", ns.Duration(time() - s.start))
    if s.startLevel and level > s.startLevel then
        add.row("Levels", format("%d > %d  |cff6fdc6f(+%d)|r", s.startLevel, level, level - s.startLevel))
    else
        add.row("Level", tostring(level))
    end
    add.row("XP gained", ns.Comma(s.xp or 0))
    add.row("Quests / kills", format("%d / %d", s.quests or 0, s.kills or 0))
    add.row("Gold", ns.Money((s.income or 0) - (s.spent or 0), true))
    local best, bestLevel = ns.BestLevelSince(s.start)
    if best then add.row("Fastest level", format("%d in %s", bestLevel, ns.Duration(best))) end

    add.header("XP sources - session")
    SourceBars(add, s.questXP or 0, s.killXP or 0, s.xp or 0)

    local lvl = ns.LevelXP(level)
    add.header("XP sources - level " .. level)
    SourceBars(add, lvl.quest, lvl.kill, lvl.total)

    add.note("|cff999999Type|r /hb summary |cff999999to print the session in chat.|r")
end

local function BuildRight(add)
    local zone = Safe(GetRealZoneText) or "?"
    local mobs = ns.cdb.mobs[zone] or {}
    local level = UnitLevel("player")

    add.header("Grinding in " .. zone)
    local zoneXP, list = 0, {}
    for name, m in pairs(mobs) do
        zoneXP = zoneXP + m.xp
        -- XP per kill drops as you out-level a mob, so only rank recent ones
        if m.lastLevel and m.lastLevel >= level - 1 then
            list[#list + 1] = { name = name, m = m }
        end
    end
    local zoneTime = ns.cdb.zoneTime[zone] or 0
    if zoneXP > 0 and zoneTime >= 60 then
        add.row("Kill XP / hour here", ns.Short(zoneXP / zoneTime * 3600))
    end
    if #list == 0 then
        add.note("Kill something here to see which mobs give the most XP.", ns.color.dim)
    else
        table.sort(list, function(a, b) return a.m.lastXP > b.m.lastXP end)
        for i = 1, math.min(TOP_MOBS, #list) do
            local e = list[i]
            add.row(e.name, format("%d xp  |cff999999x%d|r", e.m.lastXP, e.m.kills))
        end
    end

    local q = ns.QuestStats()
    add.header("Quest log")
    local count = tostring(q.count)
    if q.imported > 0 then count = count .. format("  |cff999999(%d earlier)|r", q.imported) end
    add.row("Completed", count)
    add.row("XP from quests", ns.Comma(q.xp))
    add.row("Gold from quests", ns.Money(q.money))

    local zones = {}
    for name, n in pairs(q.zones) do zones[#zones + 1] = { name = name, n = n } end
    table.sort(zones, function(a, b) return a.n > b.n end)
    for i = 1, math.min(TOP_ZONES, #zones) do
        add.row(zones[i].name, format("%d quest%s", zones[i].n, zones[i].n == 1 and "" or "s"))
    end
end

function ns.RefreshStats()
    if not page or not page:IsVisible() then return end
    leftView:Begin()
    BuildLeft(leftView.add)
    leftView:Render(0)
    rightView:Begin()
    BuildRight(rightView.add)
    rightView:Render(0)
end

function ns.BuildStatsTab(parent)
    page = parent
    leftView = ns.CreateLineView(page, ns.UI.pad, ns.UI.colW)
    rightView = ns.CreateLineView(page, ns.UI.col2X, ns.UI.colW)
    page:SetScript("OnShow", ns.RefreshStats)
end

table.insert(ns.inits, function()
    ns.cdb.zoneTime = ns.cdb.zoneTime or {}
    C_Timer.NewTicker(1, TickZone)
    C_Timer.NewTicker(2, ns.RefreshStats)
end)
