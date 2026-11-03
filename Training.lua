local ADDON_NAME, ns = ...

-- Talent points and weapon skills: a reminder when you have talent points to
-- spend, and a warning when the skill for a weapon you're using is behind
-- (low weapon skill means misses and glancing blows - slower kills).

local format = string.format
local Safe = ns.Safe

local BEHIND_BY = 25 -- points under your level's maximum before it's worth a warning

---------------------------------------------------------------------------
-- Talent points
---------------------------------------------------------------------------
function ns.UnspentTalentPoints()
    if UnitCharacterPoints then
        local points = Safe(UnitCharacterPoints, "player")
        if type(points) == "number" then return points end
    end
    if GetUnspentTalentPoints then
        local points = Safe(GetUnspentTalentPoints)
        if type(points) == "number" then return points end
    end
    return 0
end

---------------------------------------------------------------------------
-- Weapon skills
---------------------------------------------------------------------------
-- weapon subclass -> the skill it trains
local WEAPON_SKILLS = {
    [0] = "Axes", [1] = "Two-Handed Axes", [2] = "Bows", [3] = "Guns", [4] = "Maces", [5] = "Two-Handed Maces",
    [6] = "Polearms", [7] = "Swords", [8] = "Two-Handed Swords", [10] = "Staves", [13] = "Fist Weapons",
    [15] = "Daggers", [16] = "Thrown", [18] = "Crossbows", [19] = "Wands",
}

-- skill name -> rank, max
local function SkillRanks()
    local ranks = {}
    if not (GetNumSkillLines and GetSkillLineInfo) then return ranks end
    for i = 1, Safe(GetNumSkillLines) or 0 do
        local name, isHeader, _, rank, _, _, max = Safe(GetSkillLineInfo, i)
        if name and not isHeader and rank then ranks[name] = { rank = rank, max = max } end
    end
    return ranks
end

-- the skills of the weapons you have equipped that are behind: { skill, rank, cap }
function ns.WeaponSkillsBehind()
    local ranks = SkillRanks()
    if not next(ranks) then return {} end
    local cap = UnitLevel("player") * 5
    local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    local list, seen = {}, {}
    for _, slot in ipairs({ 16, 17, 18 }) do
        local id = GetInventoryItemID and GetInventoryItemID("player", slot)
        if id and getInstant then
            local _, _, _, _, _, classID, subclassID = getInstant(id)
            local skill = classID == 2 and WEAPON_SKILLS[subclassID]
            local r = skill and ranks[skill]
            if r and not seen[skill] and r.rank < cap - BEHIND_BY then
                seen[skill] = true
                list[#list + 1] = { skill = skill, rank = r.rank, cap = cap }
            end
        end
    end
    return list
end

ns.AddSection(42, function(add)
    if not ns.db.weaponSkillTips then return end
    local behind = ns.WeaponSkillsBehind()
    if #behind == 0 then return end
    add.header("Weapon skill")
    for _, b in ipairs(behind) do
        add.row(b.skill, format("|cffff8040%d|r / %d", b.rank, b.cap))
    end
    add.note("Behind for your level: more misses and glancing blows. Train it on easier mobs.", ns.color.dim)
end)

table.insert(ns.inits, function()
    ns.On("PLAYER_LEVEL_UP", function()
        C_Timer.After(1.5, function()
            if ns.db.talentReminder and ns.UnspentTalentPoints() > 0 and ns.Toast then
                local pick, label = ns.NextTalentPick()
                ns.Toast("Talent point ready!", pick and format("Suggested for %s: %s - press N.", label, pick.t)
                    or format("You have %d to spend - press N.", ns.UnspentTalentPoints()),
                    "Interface\\Icons\\Ability_Marksmanship")
            end
        end)
    end)
end)
