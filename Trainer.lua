local ADDON_NAME, ns = ...

-- Trainer reminders, upcoming skills and class quests.
--
-- Skill data comes from the class trainer itself: whenever the trainer window
-- opens, every skill it lists (learned, available and future) is recorded with
-- its level. Until the first visit a warrior has a built-in list of Classic's
-- skills; other classes have none, because Forever has moved too much (quests
-- teach druid forms, rogue poisons and shaman totems), so they get asked to visit.

local Safe = ns.Safe
local format = string.format

local DEFENSIVE_STANCE, BERSERKER_STANCE = 71, 2458
local KNOWN_SKILLS_NONE = "|cffffd200Visit your class trainer once|r  |cff999999- then this lists what's waiting and what's next|r"
local MAX_PENDING_SHOWN = 6

-- First rank of each warrior skill in Classic: level, spell ID (for name/icon), English name
local BUILTIN_WARRIOR = {
    { 4, 100, "Charge" }, { 4, 772, "Rend" },
    { 6, 6343, "Thunder Clap" }, { 6, 3127, "Parry" },
    { 8, 1715, "Hamstring" },
    { 10, 2687, "Bloodrage" }, { 10, 7386, "Sunder Armor" }, { 10, 355, "Taunt" },
    { 10, DEFENSIVE_STANCE, "Defensive Stance", quest = true },
    { 12, 7384, "Overpower" }, { 12, 72, "Shield Bash" },
    { 14, 6572, "Revenge" }, { 14, 1160, "Demoralizing Shout" },
    { 16, 2565, "Shield Block" }, { 16, 694, "Mocking Blow" },
    { 18, 676, "Disarm" },
    { 20, 20230, "Retaliation" }, { 20, 845, "Cleave" }, { 20, 674, "Dual Wield" },
    { 22, 5246, "Intimidating Shout" },
    { 24, 5308, "Execute" },
    { 26, 1161, "Challenging Shout" },
    { 28, 871, "Shield Wall" },
    { 30, BERSERKER_STANCE, "Berserker Stance", quest = true }, { 30, 20252, "Intercept" },
    { 32, 18499, "Berserker Rage" },
    { 36, 1680, "Whirlwind" },
    { 38, 6552, "Pummel" },
    { 40, 750, "Plate Mail" },
    { 50, 1719, "Recklessness" },
}

local playerClass
local builtin = {}
local scanning, lastScanEnd, scanQueued = false, 0, false

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------
local function BuildBuiltin()
    if playerClass ~= "WARRIOR" then return end
    for _, row in ipairs(BUILTIN_WARRIOR) do
        local level, spellID, english = row[1], row[2], row[3]
        local name = (C_Spell and C_Spell.GetSpellName and Safe(C_Spell.GetSpellName, spellID)) or english
        table.insert(builtin, {
            level = level,
            name = name,
            icon = Safe(ns.SpellIcon, spellID),
            quest = row.quest,
        })
    end
end

-- Returns the skill list and whether it's exactly what the trainer teaches.
-- A scan that only saw what you could train that day (the trainer's filters
-- didn't open up) is topped up with the built-in list for everything it missed.
local function Skills()
    local scanned = ns.db.trainer[playerClass]
    if not (scanned and scanned.skills and #scanned.skills > 0) then return builtin, false end
    if scanned.complete then return scanned.skills, true end
    local list, names = {}, {}
    for _, skill in ipairs(scanned.skills) do
        list[#list + 1] = skill
        names[skill.name] = true
    end
    for _, skill in ipairs(builtin) do
        if not names[skill.name] then list[#list + 1] = skill end
    end
    table.sort(list, function(a, b)
        if a.level ~= b.level then return a.level < b.level end
        return a.name < b.name
    end)
    return list, false
end

local function Label(skill, withIcon)
    local text = skill.name
    if skill.rank then text = text .. " |cff999999(" .. skill.rank .. ")|r" end
    if skill.quest then text = text .. " |cffff9933(quest)|r" end
    if withIcon then text = ns.IconText(skill.icon) .. text end
    return text
end

-- Forever's trainer doesn't name ranks, so the level tells ranks apart
local function Key(skill)
    return skill.name .. "|" .. (skill.rank or "") .. "|" .. (skill.level or 0)
end

-- Skills you can train right now but probably haven't yet
local function Pending(level)
    local visit = ns.cdb.trainerVisit
    local fromLevel = visit and visit.level or ns.cdb.baselineLevel or level
    local list, seen = {}, {}
    local function Add(skill)
        local key = Key(skill)
        if not seen[key] then
            seen[key] = true
            list[#list + 1] = skill
        end
    end
    if visit then
        for _, skill in ipairs(visit.available) do Add(skill) end
    end
    for _, skill in ipairs(Skills()) do
        if not skill.quest and skill.level > fromLevel and skill.level <= level then Add(skill) end
    end
    return list
end

-- Skills grouped by level for the next `count` levels that have any
local function Upcoming(level, count)
    local byLevel, levels = {}, {}
    for _, skill in ipairs(Skills()) do
        if skill.level > level then
            if not byLevel[skill.level] then
                byLevel[skill.level] = {}
                levels[#levels + 1] = skill.level
            end
            table.insert(byLevel[skill.level], skill)
        end
    end
    table.sort(levels)
    local result = {}
    for i = 1, math.min(count, #levels) do
        result[i] = { level = levels[i], skills = byLevel[levels[i]] }
    end
    return result
end

-- What a set of skills costs: copper, and whether every cost is known (costs
-- are read from the trainer, so the built-in list has none)
local function TotalCost(skills)
    local sum, known = 0, true
    for _, skill in ipairs(skills) do
        if type(skill.cost) == "number" then sum = sum + skill.cost else known = false end
    end
    return sum, known
end

-- "1s 80c" or "at least 1s 80c" when some costs are missing; nil when none are known
local function CostText(skills)
    local sum, known = TotalCost(skills)
    if sum == 0 and not known then return nil end
    return (known and "" or "at least ") .. ns.Money(sum), sum
end

local function JoinLabels(skills, withIcon, limit)
    local parts = {}
    for i, skill in ipairs(skills) do
        if limit and i > limit then
            parts[#parts + 1] = format("|cff999999+%d more|r", #skills - limit)
            break
        end
        parts[#parts + 1] = Label(skill, withIcon)
    end
    return table.concat(parts, withIcon and "\n" or ", ")
end

---------------------------------------------------------------------------
-- Reading the trainer window
---------------------------------------------------------------------------
local FILTERS = { "available", "unavailable", "used" }

local function FilterOn(name)
    local v = Safe(GetTrainerServiceTypeFilter, name)
    return v == true or v == 1
end

-- This client wants true/false; Classic took 1/0
local function SetFilter(name, on)
    if not pcall(SetTrainerServiceTypeFilter, name, on) then
        pcall(SetTrainerServiceTypeFilter, name, on and 1 or 0)
    end
end

local CATEGORIES = { available = true, unavailable = true, used = true, header = true }

-- name, rank, category: Classic returns (name, rank, category); Forever
-- returns (name, category, ...) with no rank, so find the category by value
local function ServiceInfo(i)
    local name, second, third, fourth = Safe(GetTrainerServiceInfo, i)
    if CATEGORIES[second] then return name, nil, second end
    local rank = (type(second) == "string" and second ~= "") and second or nil
    if CATEGORIES[third] then return name, rank, third end
    if CATEGORIES[fourth] then return name, rank, fourth end
    return name, rank, nil
end

local function ScanTrainer()
    if scanning or not GetNumTrainerServices then return end
    if Safe(IsTradeskillTrainer) then return end -- a profession trainer
    scanning = true

    -- show every skill, including learned and future ones, then put the filters back
    local saved = {}
    for _, f in ipairs(FILTERS) do
        saved[f] = FilterOn(f)
        SetFilter(f, true)
    end
    if ExpandTrainerSkillLine then pcall(ExpandTrainerSkillLine, 0) end

    local skills, available = {}, {}
    local sawOthers = false -- learned or future skills listed: the filters worked
    local count = Safe(GetNumTrainerServices) or 0
    for i = 1, count do
        local name, rank, category = ServiceInfo(i)
        if category == "unavailable" or category == "used" then sawOthers = true end
        if name and category ~= "header" then
            local skill = {
                name = name,
                rank = (rank and rank ~= "") and rank or nil,
                level = Safe(GetTrainerServiceLevelReq, i) or 0,
                icon = Safe(GetTrainerServiceIcon, i),
                cost = GetTrainerServiceCost and Safe(GetTrainerServiceCost, i) or nil,
            }
            skills[#skills + 1] = skill
            if category == "available" then available[#available + 1] = skill end
        end
    end

    for _, f in ipairs(FILTERS) do
        SetFilter(f, saved[f])
    end
    scanning = false
    lastScanEnd = GetTime()

    if #skills == 0 then return end -- not our class trainer
    table.sort(skills, function(a, b)
        if a.level ~= b.level then return a.level < b.level end
        return a.name < b.name
    end)
    local previous = ns.db.trainer[playerClass]
    local firstScan = not previous
    -- a partial scan adds to what we knew rather than replacing it
    if not sawOthers and previous and previous.skills then
        local have = {}
        for _, skill in ipairs(skills) do have[Key(skill)] = true end
        for _, skill in ipairs(previous.skills) do
            if not have[Key(skill)] then skills[#skills + 1] = skill end
        end
        table.sort(skills, function(a, b)
            if a.level ~= b.level then return a.level < b.level end
            return a.name < b.name
        end)
    end
    ns.db.trainer[playerClass] = { skills = skills, scanned = time(), complete = sawOthers }
    ns.cdb.trainerVisit = { level = UnitLevel("player"), available = available }
    if firstScan then
        ns.Print(format("Read %d skills from your trainer - upcoming skills are now exact.", #skills))
    end
    ns.UpdatePanel()
end

local function QueueScan(delay)
    if scanQueued then return end
    scanQueued = true
    C_Timer.After(delay, function()
        scanQueued = false
        ScanTrainer()
    end)
end

---------------------------------------------------------------------------
-- Panel sections
---------------------------------------------------------------------------
ns.AddSection(20, function(add, level)
    if not ns.db.showTrainer then return end
    local pending = Pending(level)
    add.header("Trainer")
    local points = ns.db.talentReminder and ns.UnspentTalentPoints and ns.UnspentTalentPoints() or 0
    if points > 0 then
        add.note(format("|cffffd200%d talent point%s to spend|r  |cff999999- press N|r", points, points == 1 and "" or "s"))
        local suggestion, why = ns.NextTalentText()
        if suggestion then add.note(suggestion, nil, nil, why) end
    end
    if #Skills() == 0 then
        add.note(KNOWN_SKILLS_NONE)
    elseif #pending == 0 then
        add.note("|cff6fdc6fUp to date|r  |cff999999- nothing new to train|r")
    else
        add.note(format("|cffffd200%d skill%s waiting at your trainer:|r", #pending, #pending == 1 and "" or "s"))
        add.note(JoinLabels(pending, true, MAX_PENDING_SHOWN))
        local cost, sum = CostText(pending)
        if cost then
            local money = GetMoney()
            if money >= sum then
                add.note("Cost: " .. cost, ns.color.dim)
            else
                add.note(format("|cffff5544Cost: %s - you're %s short|r", cost, ns.Money(sum - money)))
            end
        end
    end
end)

ns.AddSection(30, function(add, level)
    if not ns.db.showUpcoming then return end
    local groups = Upcoming(level, ns.db.upcomingLevels)
    if #groups == 0 then return end
    local _, exact = Skills()
    add.header("Coming up")
    local all = {}
    for _, group in ipairs(groups) do
        local labels = JoinLabels(group.skills, true)
        local cost = CostText(group.skills)
        if cost then labels = labels .. "\n|cff999999Cost: " .. cost .. "|r" end
        add.list("Lv " .. group.level, labels)
        for _, skill in ipairs(group.skills) do all[#all + 1] = skill end
    end
    -- what to put aside for these visits, on top of anything already waiting
    local _, upcoming = CostText(all)
    if upcoming and upcoming > 0 then
        local _, waiting = CostText(Pending(level))
        local needed = upcoming + (waiting or 0)
        local money = GetMoney()
        local text = format("Training for the next %d level%s: %s", #groups, #groups == 1 and "" or "s", ns.Money(needed))
        if money < needed then
            add.note(text .. format("  |cffff8040(%s to save)|r", ns.Money(needed - money)))
        else
            add.note(text .. "  |cff6fdc6f(covered)|r", ns.color.dim)
        end
    end
    if not exact then
        add.note("Estimated from Classic. Open your class trainer once for the exact list and costs.", ns.color.dim)
    end
end)

---------------------------------------------------------------------------
-- Level-up announcement
---------------------------------------------------------------------------
local function OnLevelUp(_, newLevel)
    if ns.IsSecret(newLevel) or type(newLevel) ~= "number" then return end
    local fresh = {}
    for _, skill in ipairs(Skills()) do
        if skill.level == newLevel then fresh[#fresh + 1] = skill end
    end
    if #fresh > 0 then
        local cost, sum = CostText(fresh)
        local costText = ""
        if cost then
            costText = " |cff999999(" .. cost .. ")|r"
            if GetMoney() < sum then costText = costText .. format(" |cffff5544- you're %s short|r", ns.Money(sum - GetMoney())) end
        end
        ns.Print("|cffffd200New at your trainer:|r " .. JoinLabels(fresh, false) .. costText)
    end
    local nextUp = Upcoming(newLevel, 1)[1]
    if nextUp then
        ns.Print(format("Next up at level %d: %s", nextUp.level, JoinLabels(nextUp.skills, false)))
    end
end

table.insert(ns.inits, function()
    playerClass = select(2, UnitClass("player"))
    BuildBuiltin()
    -- the old reader stored the category ("available") as the rank: drop it
    for _, data in pairs(ns.db.trainer) do
        for _, skill in ipairs(type(data) == "table" and data.skills or {}) do
            if CATEGORIES[skill.rank] then skill.rank = nil end
        end
    end
    -- first time we see this character, assume they're trained up to their level
    if not ns.cdb.baselineLevel then ns.cdb.baselineLevel = UnitLevel("player") end

    ns.On("TRAINER_SHOW", function() QueueScan(0.3) end)
    ns.On("TRAINER_UPDATE", function()
        -- also fires after buying a skill; ignore the updates our own scan causes
        if not scanning and GetTime() - lastScanEnd > 1 then QueueScan(0.3) end
    end)
    ns.On("PLAYER_LEVEL_UP", OnLevelUp)
end)
