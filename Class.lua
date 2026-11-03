local ADDON_NAME, ns = ...

-- Who you're playing: your class and spec (the talent tree with the most points,
-- or your chosen one with /hb spec), and what follows from them: what gear is worth
-- to you (RewardPicker.lua), your class quests, and your next talent.
-- The data is in ClassData.lua.

local format = string.format
local Safe = ns.Safe

local WINDOW_AFTER = 5    -- levels past a quest chain's own range it's still worth a reminder
local MAX_REMINDERS = 3
local SPEC_SECONDS = 5    -- how long the answer's kept: it's asked for all the time, and rarely changes

function ns.PlayerClassFile()
    local _, class = UnitClass("player")
    return class
end

local function Data()
    return ns.CLASS_DATA and ns.CLASS_DATA[ns.PlayerClassFile()]
end
ns.ClassData = Data

---------------------------------------------------------------------------
-- Spec
---------------------------------------------------------------------------
-- points in talent tree i: tree name, points
local function TreeInfo(i)
    local S = C_SpecializationInfo
    if S and S.GetSpecializationInfo then
        local _, name, _, _, _, _, points = Safe(S.GetSpecializationInfo, i)
        if name or points then return name, points end
    end
    if GetTalentTabInfo then
        -- some clients start with the tree's ID
        local a, b, c, _, e = Safe(GetTalentTabInfo, i)
        if type(a) == "number" then return b, e end
        return a, c
    end
end

local function SpecOfTree(data, name, index)
    local key = type(name) == "string" and name:lower():gsub("[^%a]", "")
    if key then
        for _, spec in ipairs(data.specs) do
            for _, alias in ipairs(spec.names) do
                if alias == key then return spec end
            end
        end
    end
    return data.specs[index]
end

local function SpecByKey(data, key)
    for _, spec in ipairs(data.specs) do
        if spec.key == key then return spec end
    end
end

-- The chosen tree on clients that let you pick one
local function PrimaryTree()
    local S = C_SpecializationInfo
    if not (S and S.GetSpecialization) then return nil end
    local index = Safe(S.GetSpecialization)
    return type(index) == "number" and index > 0 and index or nil
end

local specAt, specKey, specLabel, specSource, specSpent

local function WorkOutSpec()
    local data = Data()
    specKey, specLabel, specSource, specSpent = nil, nil, "default", nil
    if not data then return end
    local best, bestPoints, spent, known = nil, 0, 0, false
    for i = 1, #data.specs do
        local name, points = TreeInfo(i)
        if type(points) == "number" then
            known = true
            spent = spent + points
            if points > bestPoints then best, bestPoints = SpecOfTree(data, name, i), points end
        end
    end
    specSpent = known and spent or nil
    if not best then
        local primary = PrimaryTree()
        if primary then best = SpecOfTree(data, (TreeInfo(primary)), primary) end
    end
    if best then specSource = "talents" end
    local chosen = ns.cdb and ns.cdb.spec and SpecByKey(data, ns.cdb.spec)
    if chosen then best, specSource = chosen, "chosen" end
    best = best or SpecByKey(data, data.default) or data.specs[1]
    specKey, specLabel = best.key, best.label
end

-- your spec's key and name, how we know ("chosen", "talents" or "default": the
-- usual levelling spec, before your first point), and the talent points you've spent
function ns.PlayerSpec()
    local now = GetTime()
    if not specAt or now - specAt > SPEC_SECONDS then
        specAt = now
        WorkOutSpec()
    end
    return specKey, specLabel, specSource, specSpent
end

function ns.ForgetSpec() specAt = nil end

-- what stats are worth to your spec. Casters and druids have no weight for weapon
-- DPS, but still swing the weapon early on; feral forms hit with the weapon's DPS
local weightsFor = {}
function ns.SpecWeights()
    local key = ns.PlayerSpec()
    local data = Data()
    local w = data and key and data.weights[key]
    if not w then return nil end
    local cached = weightsFor[key]
    if cached then return cached end
    cached = {}
    for k, v in pairs(w) do cached[k] = v end
    if not cached.dps then
        cached.dps = (key == "feral" and w.ap) and 14 * w.ap or 0.01
    end
    weightsFor[key] = cached
    return cached
end

-- /hb spec: what we think you are; /hb spec <name>: treat you as that; /hb spec auto: go by your talents
function ns.SpecCommand(arg)
    local data = Data()
    if not data then return end
    arg = (arg or ""):lower():gsub("[^%a]", "")
    local names = {}
    for _, spec in ipairs(data.specs) do names[#names + 1] = spec.key end
    if arg == "auto" then
        ns.cdb.spec = nil
    elseif arg ~= "" then
        local match
        for _, spec in ipairs(data.specs) do
            if spec.key:find(arg, 1, true) == 1 then match = spec end
        end
        if not match then
            return ns.Print(format("No spec called \"%s\": try %s, or auto.", arg, table.concat(names, ", ")))
        end
        ns.cdb.spec = match.key
    end
    ns.ForgetSpec()
    wipe(weightsFor)
    local _, label, source = ns.PlayerSpec()
    local why = source == "chosen" and "you chose it (/hb spec auto to go by your talents)"
        or (source == "talents" and "from your talents") or "the usual levelling spec, until you spend a point"
    ns.Print(format("Spec: |cffffd200%s|r - %s. Rewards and talent advice follow it.", label or "?", why))
    if arg == "" then ns.Print(format("/hb spec %s or auto to change it.", table.concat(names, " | "))) end
    if ns.UpdatePanel then ns.UpdatePanel() end
end

---------------------------------------------------------------------------
-- Talents
---------------------------------------------------------------------------
-- the next talent on your spec's plan, if your points are the client's to tell:
-- pick { t = talent, tree, r = rank, n = why }, your spec's name
function ns.NextTalentPick()
    local data = Data()
    local key, label, _, spent = ns.PlayerSpec()
    local build = data and key and data.builds[key]
    if not (build and spent) then return nil, label end
    return build.picks[spent + 1], label, spent
end

function ns.NextTalentText()
    local pick, label = ns.NextTalentPick()
    if not pick then return nil end
    local rank = pick.r and format(" |cff999999(rank %d)|r", pick.r) or ""
    return format("|cffffd200Suggested for %s:|r %s%s", label or "your spec", pick.t, rank), pick.n
end

---------------------------------------------------------------------------
-- Class quests
---------------------------------------------------------------------------
local function HandedIn(q)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and Safe(C_QuestLog.IsQuestFlaggedCompleted, q) == true then return true end
    if IsQuestFlaggedCompleted and Safe(IsQuestFlaggedCompleted, q) == true then return true end
    return ns.cdb and ns.cdb.quests and ns.cdb.quests[q] and true or false
end

local function MyRace()
    local _, race = UnitRace("player")
    return race and race:lower() or nil
end

local function ForRace(races, mine)
    if not races then return true end
    for _, r in ipairs(races) do
        if r == mine then return true end
    end
    return false
end

-- the chains your faction and race can do, in level order
local mine
function ns.ClassQuestsForMe()
    if mine then return mine end
    local data = Data()
    local list, race, faction = {}, MyRace(), UnitFactionGroup("player")
    for _, q in ipairs(data and data.quests or {}) do
        if (not q.faction or q.faction == faction) and ForRace(q.races, race) then list[#list + 1] = q end
    end
    mine = list
    return list
end

local function KnowsAll(q)
    if not q.spells then return false end
    for _, spell in ipairs(q.spells) do
        if Safe(IsPlayerSpell, spell) ~= true then return false end
    end
    return true
end

local function LastHandedIn(q)
    local race = MyRace()
    for _, e in ipairs(q.ends or {}) do
        if ForRace(e.races, race) then return HandedIn(e.q) end
    end
    return false
end

-- done: you've handed in its last quest, or you know everything it teaches
function ns.ClassQuestDone(q)
    return LastHandedIn(q) or KnowsAll(q)
end

-- worth mentioning now? From its first level until you've finished it. Something
-- it teaches stays worth it at any level; once you know it all, only gear's left
local function Open(q, level)
    if level < q.min or LastHandedIn(q) then return false end
    if q.spells then
        if not KnowsAll(q) then return true end
        if not q.gear then return false end
    end
    return level <= q.max + WINDOW_AFTER
end

-- its icon: the first thing it teaches that you don't know yet
local function Icon(q)
    for _, spell in ipairs(q.spells or {}) do
        if Safe(IsPlayerSpell, spell) ~= true then return ns.IconText(Safe(ns.SpellIcon, spell)) end
    end
    return ""
end

local function Hidden(q)
    return ns.cdb and ns.cdb.classQuestsHidden and ns.cdb.classQuestsHidden[q.id]
end

-- chains open at your level and not done: the ones that teach you something first
function ns.ClassQuestReminders(level)
    local teach, other = {}, {}
    for _, q in ipairs(ns.ClassQuestsForMe()) do
        if Open(q, level) and not Hidden(q) then
            local into = q.spells and teach or other
            into[#into + 1] = q
        end
    end
    for _, q in ipairs(other) do teach[#teach + 1] = q end
    return teach
end

ns.AddSection(25, function(add, level)
    if not ns.db.showQuests then return end
    local list = ns.ClassQuestReminders(level)
    if #list == 0 then return end
    add.header("Class quests")
    for i = 1, math.min(MAX_REMINDERS, #list) do
        local q = list[i]
        add.note(format("%s|cffff9933%s|r  %s", Icon(q), q.title, q.why), nil, function()
            ns.cdb.classQuestsHidden = ns.cdb.classQuestsHidden or {}
            ns.cdb.classQuestsHidden[q.id] = true
            ns.UpdatePanel()
        end, "Click to stop reminding me about this one")
    end
    if #list > MAX_REMINDERS then
        add.note(format("|cff999999+%d more for your level - see the guide's class quests|r", #list - MAX_REMINDERS))
    end
end)

---------------------------------------------------------------------------
-- The level 40 mount
---------------------------------------------------------------------------
local CLASS_MOUNT = {
    WARLOCK = "Level 40 - time for your Felsteed, a warlock's own mount: no riding training needed.",
    PALADIN = "Level 40 - time for your Warhorse, a paladin's own mount: no horse to buy.",
}

function ns.MountReminderText()
    return CLASS_MOUNT[ns.PlayerClassFile()] or "Level 40 - visit your riding trainer."
end

table.insert(ns.inits, function()
    -- talents changed: say so straight away, not a few seconds later
    ns.On("PLAYER_TALENT_UPDATE", ns.ForgetSpec)
    ns.On("CHARACTER_POINTS_CHANGED", ns.ForgetSpec)
    ns.On("TRAIT_CONFIG_UPDATED", ns.ForgetSpec)
end)
