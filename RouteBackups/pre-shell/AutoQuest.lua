local ADDON_NAME, ns = ...

-- Auto quest: accepts quests and hands in completed ones (each can be turned
-- off on its own), skipping quest NPCs' gossip screens. Stops at reward
-- choices so you pick. Hold Shift when talking to an NPC to do it by hand.
-- Also auto-repairs at vendors.

local Safe = ns.Safe
local format = string.format
local C_GossipInfo = C_GossipInfo

-- "accept" picks up new quests, "turnin" hands in finished ones
local function Enabled(kind)
    if IsShiftKeyDown() then return false end
    if kind == "accept" then return ns.db.autoAccept end
    return ns.db.autoQuest
end

local function SkipTrivial()
    return ns.db.autoQuestSkipGrey
end

---------------------------------------------------------------------------
-- NPC dialogs
---------------------------------------------------------------------------
-- Gossip window (most NPCs): hand in finished quests first, then pick up new ones
local function OnGossipShow()
    if not C_GossipInfo then return end
    if Enabled("turnin") then
        local active = Safe(C_GossipInfo.GetActiveQuests) or {}
        for _, q in ipairs(active) do
            if q.isComplete and q.questID then
                pcall(C_GossipInfo.SelectActiveQuest, q.questID)
                return
            end
        end
    end
    if not Enabled("accept") then return end
    local available = Safe(C_GossipInfo.GetAvailableQuests) or {}
    for _, q in ipairs(available) do
        if q.questID and not (SkipTrivial() and q.isTrivial) then
            pcall(C_GossipInfo.SelectAvailableQuest, q.questID)
            return
        end
    end
end

-- Older quest greeting window (NPCs with several quests and no gossip)
local function OnQuestGreeting()
    if Enabled("turnin") then
        for i = 1, Safe(GetNumActiveQuests) or 0 do
            local _, isComplete = Safe(GetActiveTitle, i)
            if isComplete then
                pcall(SelectActiveQuest, i)
                return
            end
        end
    end
    if not Enabled("accept") then return end
    for i = 1, Safe(GetNumAvailableQuests) or 0 do
        local isTrivial = GetAvailableQuestInfo and Safe(GetAvailableQuestInfo, i)
        if not (SkipTrivial() and isTrivial) then
            pcall(SelectAvailableQuest, i)
            return
        end
    end
end

local function OnQuestDetail()
    if not Enabled("accept") then return end
    if QuestGetAutoAccept and Safe(QuestGetAutoAccept) then return end -- the game already took it
    pcall(AcceptQuest)
end

local function OnQuestProgress()
    if not Enabled("turnin") then return end
    if Safe(IsQuestCompletable) then pcall(CompleteQuest) end
end

-- Best vendor value among the reward choices, to help you pick
local function BestSellChoice(count)
    local best, bestValue
    for i = 1, count do
        local link = Safe(GetQuestItemLink, "choice", i)
        local price = link and C_Item and C_Item.GetItemInfo and select(11, Safe(C_Item.GetItemInfo, link))
        if price and price > (bestValue or 0) then best, bestValue = link, price end
    end
    return best, bestValue
end

local function OnQuestComplete()
    if not Enabled("turnin") then return end
    local choices = Safe(GetNumQuestChoices) or 0
    if choices > 1 then
        local pick = ns.AutoRewardChoice and ns.AutoRewardChoice()
        if pick and GetQuestReward then
            pcall(GetQuestReward, pick)
            return
        end
        if ns.db.rewardPicker then return end -- the reward picker has said which to take
        local link, value = BestSellChoice(choices)
        local hint = link and format(" Best vendor value: %s (%s).", link, ns.Money(value)) or ""
        ns.Print("|cffffd200Pick your reward.|r" .. hint)
        return
    end
    if GetQuestReward then
        pcall(GetQuestReward, choices)
    end
end

---------------------------------------------------------------------------
-- Auto repair
---------------------------------------------------------------------------
local function OnMerchantShow()
    if not ns.db.autoRepair or IsShiftKeyDown() then return end
    if not Safe(CanMerchantRepair) then return end
    local cost, canRepair = Safe(GetRepairAllCost)
    if not canRepair or not cost or cost <= 0 then return end
    if GetMoney() < cost then
        ns.Print("|cffff5544Not enough gold to repair|r (" .. ns.Money(cost) .. ").")
        return
    end
    if pcall(RepairAllItems) then
        ns.Print("Repaired your gear for " .. ns.Money(cost) .. ".")
    end
end

table.insert(ns.inits, function()
    ns.On("GOSSIP_SHOW", OnGossipShow)
    ns.On("QUEST_GREETING", OnQuestGreeting)
    ns.On("QUEST_DETAIL", OnQuestDetail)
    ns.On("QUEST_PROGRESS", OnQuestProgress)
    ns.On("QUEST_COMPLETE", OnQuestComplete)
    ns.On("MERCHANT_SHOW", OnMerchantShow)
end)
