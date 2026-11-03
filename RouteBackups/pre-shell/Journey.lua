local ADDON_NAME, ns = ...

-- The Journey tab: the full road to 60, milestones reached, deaths and
-- level-up screenshots.

local format = string.format

local MILESTONES_SHOWN = 8
local TOP_DEATH_ROWS = 3

local page, leftView, rightView

local function TopEntries(map, count)
    local list = {}
    for name, n in pairs(map) do list[#list + 1] = { name = name, n = n } end
    table.sort(list, function(a, b) return a.n > b.n end)
    local result = {}
    for i = 1, math.min(count, #list) do result[i] = list[i] end
    return result
end

local function BuildLeft(add)
    local level = UnitLevel("player")
    local max = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60

    add.header("Road to " .. max)
    if level >= max then
        add.note("You've reached the top. Well done!", ns.color.gold)
    else
        local pace, source = ns.LevelingPace()
        if pace then
            add.row("Pace", format("%s XP/hour  |cff999999(%s)|r", ns.Short(pace * 3600), source))
            for _, target in ipairs(ns.RoadTargets(level, true)) do
                add.row(ns.RoadLabel(target), "~" .. ns.Duration(ns.TimeToLevel(target.level)) .. " played")
            end
        else
            add.note("Play a little longer to measure your pace.", ns.color.dim)
        end
    end

    add.header("Milestones")
    local log = ns.cdb.milestoneLog
    if #log == 0 then
        add.note("Your first milestone is on its way - level 10s, 40, quest and kill counts, new fastest levels.", ns.color.dim)
    else
        for i = 1, math.min(MILESTONES_SHOWN, #log) do
            local m = log[i]
            add.list(date("%d %b", m.time), ns.IconText(m.icon) .. m.title)
        end
    end
end

local function BuildRight(add)
    local d = ns.DeathStats()
    add.header("Deaths")
    add.row("Total", tostring(d.total))
    add.row("This level", tostring(d.thisLevel))
    add.row("This session", tostring(d.session))
    if d.total > 0 then
        for _, e in ipairs(TopEntries(d.zones, TOP_DEATH_ROWS)) do
            add.row(e.name, format("%d death%s", e.n, e.n == 1 and "" or "s"))
        end
        local killers = TopEntries(d.killers, TOP_DEATH_ROWS)
        if #killers > 0 then
            add.header("Most deadly")
            for _, e in ipairs(killers) do add.row(e.name, format("x%d", e.n)) end
        end
    else
        add.note("No deaths recorded - keep it that way!", ns.color.dim)
    end

    add.header("Screenshots")
    local shots = ns.cdb.screenshots or 0
    if ns.db.screenshots then
        add.row("Level-up pictures", tostring(shots))
        add.note("Saved in the game's Screenshots folder.", ns.color.dim)
    else
        add.note("Level-up screenshots are off (Settings tab).", ns.color.dim)
    end
end

function ns.RefreshJourney()
    if not page or not page:IsVisible() then return end
    leftView:Begin()
    BuildLeft(leftView.add)
    leftView:Render(0)
    rightView:Begin()
    BuildRight(rightView.add)
    rightView:Render(0)
end

function ns.BuildJourneyTab(parent)
    page = parent
    leftView = ns.CreateLineView(page, ns.UI.pad, ns.UI.colW)
    rightView = ns.CreateLineView(page, ns.UI.col2X, ns.UI.colW)
    page:SetScript("OnShow", ns.RefreshJourney)
end

table.insert(ns.inits, function()
    C_Timer.NewTicker(5, ns.RefreshJourney)
end)
