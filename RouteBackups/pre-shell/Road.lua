local ADDON_NAME, ns = ...

-- Road to 60: forecasts how much more play time each milestone level needs,
-- from your recent levelling pace.

local format = string.format

-- XP needed to go from each level to the next in Classic. Whenever the client
-- reports a level's real value it's stored in db.xpTable and used instead, in
-- case Forever changed the curve.
local CLASSIC_XP = {
    400, 900, 1400, 2100, 2800, 3600, 4500, 5400, 6500, 7600,
    8800, 10100, 11400, 12900, 14400, 16000, 17700, 19400, 21300, 23200,
    25200, 27300, 29400, 31700, 34000, 36400, 38900, 41400, 44300, 47400,
    50800, 54500, 58600, 62800, 67100, 71600, 76100, 80800, 85700, 90700,
    95800, 101000, 106300, 111800, 117500, 123200, 129100, 135100, 141200, 147500,
    153900, 160400, 167100, 173900, 180800, 187900, 195000, 202300, 209800,
}

local RECENT_LEVELS = 3      -- how many finished levels set the pace
local MIN_PACE_SECONDS = 300 -- need this much measured play before forecasting
local MOUNT_LEVEL = 40

local function MaxLevel()
    return GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
end

function ns.XPForLevel(level)
    return ns.db.xpTable[level] or CLASSIC_XP[level]
end

local function RecordXPMax()
    local max = UnitXPMax("player")
    if max and max > 0 then ns.db.xpTable[UnitLevel("player")] = max end
end

-- Returns XP per second and a description of where it came from, or nil
function ns.LevelingPace()
    local level = UnitLevel("player")
    local xp, secs, levels = 0, 0, 0
    for l = level - 1, math.max(1, level - RECENT_LEVELS), -1 do
        local t = ns.cdb.levelTimes[l]
        -- only levels timed from start to finish give a fair pace
        if t and t > 0 and ns.cdb.levelsDone[l] and ns.cdb.levelExact[l] then
            xp = xp + (ns.XPForLevel(l) or 0)
            secs = secs + t
            levels = levels + 1
        end
    end
    -- the current level so far, if it's been timed from its start
    if ns.cdb.levelExact[level] then
        local t = ns.cdb.levelTimes[level] or 0
        if t > 0 then
            xp = xp + UnitXP("player")
            secs = secs + t
        end
    end
    if secs >= MIN_PACE_SECONDS and xp > 0 then
        local source = levels > 0 and format("last %d level%s", levels, levels == 1 and "" or "s") or "this level"
        return xp / secs, source
    end
    -- fall back to this session's rate
    local s = ns.Session()
    local elapsed = time() - s.start
    if elapsed >= MIN_PACE_SECONDS and (s.xp or 0) > 0 then
        return s.xp / elapsed, "this session"
    end
end

-- Seconds of play to reach `target`, or nil if the pace is unknown
function ns.TimeToLevel(target)
    local level = UnitLevel("player")
    if target <= level then return 0 end
    local pace = ns.LevelingPace()
    if not pace then return nil end
    local remaining = (UnitXPMax("player") or 0) - (UnitXP("player") or 0)
    for l = level + 1, target - 1 do
        remaining = remaining + (ns.XPForLevel(l) or 0)
    end
    return remaining / pace
end

-- Milestones worth forecasting: next multiple of 10, the mount level and max level
function ns.RoadTargets(level, all)
    local max = MaxLevel()
    local targets, seen = {}, {}
    local function Add(l, label)
        if l > level and l <= max and not seen[l] then
            seen[l] = true
            targets[#targets + 1] = { level = l, label = label }
        end
    end
    if all then
        for l = 10, max, 10 do Add(l) end
    else
        Add(math.floor(level / 10) * 10 + 10)
    end
    Add(MOUNT_LEVEL, "mount")
    Add(max, max == 60 and nil or "max")
    table.sort(targets, function(a, b) return a.level < b.level end)
    for _, t in ipairs(targets) do
        if t.level == MOUNT_LEVEL then t.label = "mount" end
    end
    return targets
end

function ns.RoadLabel(target)
    local text = "Level " .. target.level
    if target.label then text = text .. "  |cff999999(" .. target.label .. ")|r" end
    return text
end

ns.AddSection(12, function(add, level)
    if not ns.db.showRoad or level >= MaxLevel() then return end
    add.header("Road to " .. MaxLevel())
    local pace = ns.LevelingPace()
    if not pace then
        add.note("Play a little longer to measure your pace.", ns.color.dim)
        return
    end
    for _, target in ipairs(ns.RoadTargets(level)) do
        add.row(ns.RoadLabel(target), "~" .. ns.Duration(ns.TimeToLevel(target.level)))
    end
end)

table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", RecordXPMax)
    ns.On("PLAYER_XP_UPDATE", RecordXPMax)
    ns.On("PLAYER_LEVEL_UP", function() C_Timer.After(1, RecordXPMax) end)
end)
