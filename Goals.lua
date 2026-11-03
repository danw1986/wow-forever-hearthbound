local ADDON_NAME, ns = ...

-- Session goals: set "/hb goal 30" (reach level 30) or "/hb goal
-- Redridge Mountains" (finish that zone's quests) and the panel shows a
-- progress bar, with a pop-up when you get there. "/hb goal" clears it.

local format = string.format

local function LevelValue()
    local max = UnitXPMax("player") or 0
    return UnitLevel("player") + ((max > 0) and (UnitXP("player") / max) or 0)
end

local function ZoneProgress(name)
    for _, z in ipairs(ns.QuestieZoneProgress and ns.QuestieZoneProgress() or {}) do
        if z.name and z.name:lower() == name:lower() then return z end
    end
end

function ns.SetGoal(text)
    text = strtrim(text or "")
    if text == "" then
        ns.cdb.goal = nil
        ns.Print("Session goal cleared.")
    elseif tonumber(text) then
        local level = math.floor(tonumber(text))
        if level <= UnitLevel("player") then return ns.Print("Pick a level above your current one.") end
        ns.cdb.goal = { level = level, from = LevelValue(), set = time() }
        ns.Print(format("Goal set: reach level %d.", level))
    else
        local zone = ZoneProgress(text)
        if not zone then return ns.Print("No zone called \"" .. text .. "\" with quests for you (QuestieDB) - check the spelling.") end
        ns.cdb.goal = { zone = zone.name, set = time() }
        ns.Print(format("Goal set: finish %s (%d of %d quests done).", zone.name, zone.done, zone.total))
    end
    if ns.UpdatePanel then ns.UpdatePanel() end
end

local function Reached(title)
    ns.cdb.goal = nil
    if ns.Toast then ns.Toast("Goal reached!", title, "Interface\\Icons\\INV_Misc_Note_02") end
    ns.Print("|cff6fdc6fGoal reached:|r " .. title)
end

ns.AddSection(11, function(add)
    local goal = ns.cdb.goal
    if not goal then return end
    add.header("Session goal")
    if goal.level then
        local now = LevelValue()
        if now >= goal.level then return Reached("Level " .. goal.level) end
        local span = math.max(0.01, goal.level - (goal.from or now))
        local f = math.max(0, math.min(1, (now - (goal.from or now)) / span))
        local eta = ns.TimeToLevel and ns.TimeToLevel(goal.level)
        add.bar(f, "Level " .. goal.level, format("%d%%%s", math.floor(f * 100), eta and ("  ~" .. ns.Duration(eta)) or ""))
    elseif goal.zone then
        local z = ZoneProgress(goal.zone)
        if not z then return add.note("Reading " .. goal.zone .. "'s quests...", ns.color.dim) end
        if z.done >= z.total then return Reached("All of " .. goal.zone .. "'s quests") end
        add.bar(z.done / z.total, goal.zone, format("%d / %d quests", z.done, z.total))
    end
end)
