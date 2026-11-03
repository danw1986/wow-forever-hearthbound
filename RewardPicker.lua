local ADDON_NAME, ns = ...

-- Quest reward picker: when a quest offers a choice, score each reward for
-- your class and spec against what you're wearing in that
-- slot, highlight the best upgrade and say why. With "Pick rewards for me" on
-- (and auto hand-in), it takes that reward; with no upgrade it takes the one
-- worth most at a vendor.

local format = string.format
local Safe = ns.Safe
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemStats = (C_Item and C_Item.GetItemStats) or GetItemStats

-- what the game calls each stat -> the name in your spec's weights (ClassData.lua)
local STAT_KEYS = {
    ITEM_MOD_STRENGTH_SHORT = "str", ITEM_MOD_AGILITY_SHORT = "agi", ITEM_MOD_STAMINA_SHORT = "sta",
    ITEM_MOD_INTELLECT_SHORT = "int", ITEM_MOD_SPIRIT_SHORT = "spi", RESISTANCE0_NAME = "armor",
    ITEM_MOD_HEALTH_SHORT = "health", ITEM_MOD_MANA_SHORT = "mana",
    ITEM_MOD_ATTACK_POWER_SHORT = "ap", ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "rap",
    ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "sp", ITEM_MOD_SPELL_POWER_SHORT = "sp",
    ITEM_MOD_SPELL_HEALING_DONE_SHORT = "heal",
    ITEM_MOD_MANA_REGENERATION_SHORT = "mp5", ITEM_MOD_POWER_REGEN0_SHORT = "mp5",
    ITEM_MOD_HEALTH_REGEN_SHORT = "hp5", ITEM_MOD_HEALTH_REGENERATION_SHORT = "hp5",
    ITEM_MOD_CRIT_RATING_SHORT = "crit", ITEM_MOD_CRIT_MELEE_RATING_SHORT = "crit",
    ITEM_MOD_HIT_RATING_SHORT = "hit", ITEM_MOD_HIT_MELEE_RATING_SHORT = "hit",
    ITEM_MOD_CRIT_SPELL_RATING_SHORT = "spellCrit", ITEM_MOD_HIT_SPELL_RATING_SHORT = "spellHit",
    ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "defense", ITEM_MOD_DODGE_RATING_SHORT = "dodge",
    ITEM_MOD_PARRY_RATING_SHORT = "parry", ITEM_MOD_BLOCK_RATING_SHORT = "block",
    ITEM_MOD_BLOCK_VALUE_SHORT = "blockValue",
}
-- equip slot -> the inventory slots it competes with
local SLOTS = {
    INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 }, INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 }, INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 }, INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16, 17 }, INVTYPE_2HWEAPON = { 16 }, INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_WEAPONOFFHAND = { 17 }, INVTYPE_SHIELD = { 17 }, INVTYPE_HOLDABLE = { 17 },
    INVTYPE_RANGED = { 18 }, INVTYPE_RANGEDRIGHT = { 18 }, INVTYPE_THROWN = { 18 },
}
local RANGED = { INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true, INVTYPE_THROWN = true }

-- a number for how good an item is for your spec, or nil if its details aren't loaded
local function Score(link)
    if not link then return 0 end
    local stats = GetItemStats and Safe(GetItemStats, link)
    if not stats then return nil end
    local w = ns.SpecWeights()
    if not w then return 0 end
    local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link)
    local score = 0
    for key, value in pairs(stats) do
        local stat = STAT_KEYS[key]
        if stat and w[stat] then score = score + value * w[stat] end
        if key == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
            score = score + value * ((RANGED[equipLoc] and w.rdps or w.dps) or 0)
        end
    end
    return score
end

-- can you use it now? (level, and the armour and weapons your class can use)
local function Wearable(link)
    local _, _, _, _, minLevel, _, _, _, equipLoc = GetItemInfo(link)
    if not equipLoc or equipLoc == "" or not SLOTS[equipLoc] then return false end
    if minLevel and minLevel > UnitLevel("player") then return false end
    if ns.ItemUsableByMe and not ns.ItemUsableByMe(link) then return false end
    return true, equipLoc
end

-- how much better than what you wear: the gain and the item it replaces
local function Gain(link)
    local wearable, equipLoc = Wearable(link)
    if not wearable then return nil end
    local new = Score(link)
    if not new then return nil end
    local worst, worstLink
    for _, slot in ipairs(SLOTS[equipLoc]) do
        local equipped = GetInventoryItemLink("player", slot)
        local s = equipped and Score(equipped) or 0
        if s and (not worst or s < worst) then worst, worstLink = s, equipped end
    end
    -- a two-hander replaces both hands
    if equipLoc == "INVTYPE_2HWEAPON" then
        local off = GetInventoryItemLink("player", 17)
        worst = (worst or 0) + (off and Score(off) or 0)
    end
    return new - (worst or 0), worstLink, new
end

local function SellChoice(count)
    local best, bestValue
    for i = 1, count do
        local link = Safe(GetQuestItemLink, "choice", i)
        local price = link and select(11, GetItemInfo(link))
        if price and price > (bestValue or 0) then best, bestValue = i, price end
    end
    return best, bestValue
end

-- The best choice: index, why ("upgrade" / "sell"), the gain and what it replaces
function ns.BestQuestReward()
    local count = Safe(GetNumQuestChoices) or 0
    if count < 2 then return nil end
    local best, bestGain, replaces, waiting
    for i = 1, count do
        local link = Safe(GetQuestItemLink, "choice", i)
        local gain, old = nil, nil
        if link then gain, old = Gain(link) end
        if link and gain == nil and Wearable(link) then waiting = true end
        if gain and gain > 0 and (not bestGain or gain > bestGain) then best, bestGain, replaces = i, gain, old end
    end
    if best then return best, "upgrade", bestGain, replaces end
    if waiting then return nil, "loading" end
    local sell, value = SellChoice(count)
    return sell, "sell", value
end

---------------------------------------------------------------------------
-- Highlighting the pick in the reward window
---------------------------------------------------------------------------
local glow

local function RewardButton(i)
    local frame = QuestInfoRewardsFrame
    return (frame and frame.RewardButtons and frame.RewardButtons[i])
        or _G["QuestInfoRewardsFrameQuestInfoItem" .. i] or _G["QuestInfoItem" .. i]
end

local function Highlight(i, label)
    local button = i and RewardButton(i)
    if not glow then
        glow = CreateFrame("Frame", nil, UIParent, ns.BACKDROP)
        glow:SetBackdrop({ edgeFile = ns.WHITE, edgeSize = 2 })
        glow:SetBackdropBorderColor(0.3, 1, 0.3, 1)
        glow.label = ns.Text(glow, 10, { 0.3, 1, 0.3, 1 }, "OUTLINE")
        glow.label:SetPoint("BOTTOMRIGHT", -3, 3)
    end
    if not button then glow:Hide() return end
    glow:SetParent(button)
    glow:ClearAllPoints()
    glow:SetPoint("TOPLEFT", -2, 2)
    glow:SetPoint("BOTTOMRIGHT", 2, -2)
    glow:SetFrameLevel(button:GetFrameLevel() + 5)
    glow.label:SetText(label)
    glow:Show()
end

local tries = 0
local function OnQuestComplete()
    if not ns.db.rewardPicker then return end
    local index, why, amount, replaces = ns.BestQuestReward()
    if why == "loading" and tries < 4 then
        tries = tries + 1
        C_Timer.After(0.4, OnQuestComplete) -- item details still arriving
        return
    end
    tries = 0
    if not index then return end
    local link = Safe(GetQuestItemLink, "choice", index)
    if why == "upgrade" then
        Highlight(index, "UPGRADE")
        local _, spec = ns.PlayerSpec()
        ns.Print(format("Best reward for %s: %s%s", spec or "you", link or "?",
            replaces and (" - better than your " .. replaces) or " - fills an empty slot"))
    else
        Highlight(index, "SELL")
        ns.Print(format("No upgrade here - %s sells for the most (%s).", link or "?", ns.Money(amount or 0)))
    end
end

-- for auto hand-in: the reward to take, when "Pick rewards for me" is on
function ns.AutoRewardChoice()
    if not (ns.db.rewardPicker and ns.db.rewardAutoPick) then return nil end
    local index, why = ns.BestQuestReward()
    if why == "loading" then return nil end
    return index
end

table.insert(ns.inits, function()
    ns.On("QUEST_COMPLETE", function() C_Timer.After(0.1, OnQuestComplete) end)
    ns.On("QUEST_FINISHED", function() if glow then glow:Hide() end end)
end)
