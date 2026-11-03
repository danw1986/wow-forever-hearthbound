local ADDON_NAME, ns = ...

-- Gold tracker: money earned and spent this session, earnings per hour and a
-- savings goal (per character, set in /hb).

local floor, format = math.floor, string.format
local DIM_DASH = "|cff999999--|r"
local COPPER_PER_GOLD = 10000

local lastMoney

local function OnMoney()
    local cur = GetMoney()
    if lastMoney then
        local delta = cur - lastMoney
        local s = ns.Session()
        if delta > 0 then
            s.income = (s.income or 0) + delta
            ns.cdb.goldEarned = (ns.cdb.goldEarned or 0) + delta -- all time, for achievements
        elseif delta < 0 then
            s.spent = (s.spent or 0) - delta
            ns.cdb.goldSpent = (ns.cdb.goldSpent or 0) - delta -- all time, for achievements
        end
    end
    lastMoney = cur
    ns.UpdatePanel()
end

ns.AddSection(35, function(add)
    if not ns.db.showGold then return end
    local s = ns.Session()
    local income, spent = s.income or 0, s.spent or 0
    local elapsed = math.max(1, time() - s.start)

    add.header("Gold")
    if income > 0 and elapsed >= 60 then
        add.row("Earned / hour", ns.Money(income / elapsed * 3600))
    else
        add.row("Earned / hour", DIM_DASH)
    end
    local session = ns.Money(income - spent, true)
    if spent > 0 then session = session .. "  |cff999999(spent " .. ns.Money(spent) .. ")|r" end
    add.row("This session", session)

    local goal = ns.cdb.goldGoal
    if goal and goal > 0 then
        local have = GetMoney()
        local goalCopper = goal * COPPER_PER_GOLD
        local right = have >= goalCopper and "|cff6fdc6fReached!|r"
            or format("%dg / %dg", floor(have / COPPER_PER_GOLD), goal)
        add.bar(have / goalCopper, "Savings goal", right, { 0.85, 0.68, 0.2 })
    end
end)

table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", function() lastMoney = GetMoney() end)
    ns.On("PLAYER_MONEY", OnMoney)
end)
