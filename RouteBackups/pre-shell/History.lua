local ADDON_NAME, ns = ...

-- Level history: how long each level took (logged-in time)

local format = string.format
local MAX_TICK = 60 -- ignore gaps longer than this (e.g. the client froze)

local lastTick

local function Times()
    return ns.cdb.levelTimes
end

local function Tick()
    local now = time()
    if lastTick then
        local delta = now - lastTick
        if delta > 0 and delta <= MAX_TICK then
            local level = UnitLevel("player")
            Times()[level] = (Times()[level] or 0) + delta
        end
    end
    lastTick = now
end

-- /played reports the exact time on this level, so use it when the player types it
local function OnTimePlayed(_, _, thisLevel)
    if ns.IsSecret(thisLevel) or type(thisLevel) ~= "number" then return end
    local level = UnitLevel("player")
    Times()[level] = thisLevel
    ns.cdb.levelExact[level] = true -- covers the whole level, not just tracked time
    ns.UpdatePanel()
end

local function OnLevelUp(_, newLevel)
    if ns.IsSecret(newLevel) or type(newLevel) ~= "number" then return end
    Tick()
    local finished = newLevel - 1
    ns.cdb.levelsDone[finished] = time() -- when it was finished
    ns.cdb.levelReachedAt[newLevel] = time()
    ns.cdb.levelExact[newLevel] = true -- tracked from its very start
    local took = Times()[finished]
    if took then
        ns.Print(format("|cffffd200Level %d reached!|r Level %d took %s.", newLevel, finished, ns.Duration(took)))
    end
end

-- Fastest level finished since `since`: returns seconds, level
function ns.BestLevelSince(since)
    local best, bestLevel
    for lvl, finishedAt in pairs(ns.cdb.levelsDone) do
        local t = Times()[lvl]
        if t and type(finishedAt) == "number" and finishedAt >= since and (not best or t < best) then
            best, bestLevel = t, lvl
        end
    end
    return best, bestLevel
end

ns.AddSection(50, function(add, level)
    if not ns.db.showHistory then return end
    local times, done = Times(), ns.cdb.levelsDone
    add.header("Level history")
    add.row("This level", ns.Duration(times[level] or 0))

    local fastestLevel, fastest, total, count = nil, nil, 0, 0
    for lvl in pairs(done) do
        local t = times[lvl]
        if t then
            total, count = total + t, count + 1
            if not fastest or t < fastest then fastestLevel, fastest = lvl, t end
        end
    end

    if done[level - 1] and times[level - 1] then
        add.row("Last level", ns.Duration(times[level - 1]))
    end
    if count >= 2 then
        add.row("Average", ns.Duration(total / count))
        add.row("Fastest", format("%s  |cff999999(level %d)|r", ns.Duration(fastest), fastestLevel))
    elseif count == 0 then
        add.note("Finish a level to start your history. Type /played for exact time on this level.", ns.color.dim)
    end
end)

table.insert(ns.inits, function()
    ns.cdb.levelTimes = ns.cdb.levelTimes or {}
    ns.cdb.levelsDone = ns.cdb.levelsDone or {}
    ns.cdb.levelReachedAt = ns.cdb.levelReachedAt or {}
    ns.cdb.levelExact = ns.cdb.levelExact or {}
    C_Timer.NewTicker(1, Tick)
    ns.On("TIME_PLAYED_MSG", OnTimePlayed)
    ns.On("PLAYER_LEVEL_UP", OnLevelUp)
end)
