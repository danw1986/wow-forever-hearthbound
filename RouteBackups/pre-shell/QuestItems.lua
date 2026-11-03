local ADDON_NAME, ns = ...

-- Quest items: tooltips that say whether to keep or sell an item, and a
-- pop-up when something in your bags starts a quest.
--
-- Uses the live quest log (works for every quest, Forever's new ones too) and
-- QuestieDB's item data when it's there.

local format = string.format
local Safe = ns.Safe

local ICON_STARTS = "Interface\\GossipFrame\\AvailableQuestIcon"
local MAX_LISTED = 3

local GREEN = { 0.25, 1, 0.25 }
local YELLOW = { 1, 0.82, 0 }
local GREY = { 0.6, 0.6, 0.6 }

---------------------------------------------------------------------------
-- What the quests in your log still need, from their objectives
---------------------------------------------------------------------------
local needs = {} -- lowercase item name -> { { id, title, have, need, done, ready } }
local kills = {} -- lowercase mob name -> the same, for "slay" objectives
local needsDirty = true

-- "Linen Cloth: 3/10" or "3/10 Linen Cloth" -> name, have, need
local function ParseObjective(text)
    local name, have, need = text:match("^(.-):%s*(%d+)%s*/%s*(%d+)%s*$")
    if not name then have, need, name = text:match("^(%d+)%s*/%s*(%d+)%s+(.-)%s*$") end
    if name then return strtrim(name), tonumber(have), tonumber(need) end
    return strtrim((text:gsub("%s*%(.-%)%s*$", ""))) -- "Mysterious Letter (Complete)"
end

local function ScanNeeds()
    needsDirty = false
    wipe(needs)
    wipe(kills)
    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then return end
    for _, q in ipairs(ns.openQuests or {}) do
        local objectives = Safe(C_QuestLog.GetQuestObjectives, q.id)
        for _, o in ipairs(type(objectives) == "table" and objectives or {}) do
            local into = (o.type == "item" and needs) or (o.type == "monster" and kills)
            if into and type(o.text) == "string" and o.text ~= "" then
                local name, have, need = ParseObjective(o.text)
                have, need = o.numFulfilled or have, o.numRequired or need
                if into == kills then
                    -- "Kobold Vermin slain", "... killed", "... defeated" -> the mob's name
                    for _, word in ipairs({ "[Ss]lain", "[Kk]illed", "[Dd]efeated" }) do
                        name = name:gsub("%s+" .. word .. "$", "")
                    end
                end
                local key = name:lower()
                into[key] = into[key] or {}
                table.insert(into[key], {
                    id = q.id, title = q.title, have = have, need = need,
                    done = o.finished or (have and need and have >= need) or false,
                    ready = q.complete,
                })
            end
        end
    end
end

-- What your quest log still needs: items and kills, by lowercase name
function ns.QuestNeeds()
    if needsDirty then ScanNeeds() end
    return needs, kills
end

local function InLog(questId)
    for _, q in ipairs(ns.openQuests or {}) do
        if q.id == questId then return q end
    end
end

local function QuestTitle(questId)
    local title = ns.QuestieQuestName and ns.QuestieQuestName(questId)
    if not title and C_QuestLog and C_QuestLog.GetTitleForQuestID then title = Safe(C_QuestLog.GetTitleForQuestID, questId) end
    return title or ("quest " .. questId)
end

---------------------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------------------
local function Line(tooltip, text, color)
    tooltip:AddLine(text, color[1], color[2], color[3], true)
end

local function AddQuestLines(tooltip, itemID, itemName)
    if needsDirty then ScanNeeds() end
    local covered = {} -- quest IDs already described

    -- 1. quests in your log that need it right now
    for _, n in ipairs(itemName and needs[itemName:lower()] or {}) do
        covered[n.id] = true
        if n.ready then
            Line(tooltip, format("Keep: hand in %s", n.title), GREEN)
        elseif n.done then
            Line(tooltip, format("Keep: %s (%d/%d, done)", n.title, n.have or 0, n.need or 0), GREEN)
        elseif n.have and n.need then
            Line(tooltip, format("Needed for: %s (%d/%d)", n.title, n.have, n.need), YELLOW)
        else
            Line(tooltip, format("Needed for: %s", n.title), YELLOW)
        end
    end

    -- 2. a quest this item starts
    local starts = ns.QuestieItemStarts and ns.QuestieItemStarts(itemID)
    if starts and not covered[starts] then
        covered[starts] = true
        if InLog(starts) then
            Line(tooltip, format("Started: %s is in your log", QuestTitle(starts)), GREY)
        elseif ns.QuestDone and ns.QuestDone(starts) then
            Line(tooltip, format("Safe to sell: you've done %s", QuestTitle(starts)), GREY)
        else
            Line(tooltip, format("Starts a quest: %s - right-click it", QuestTitle(starts)), YELLOW)
        end
    end

    -- 3. other quests that use it, from QuestieDB
    local uses = ns.QuestieItemUses and ns.QuestieItemUses(itemID)
    if not uses then return end
    local inLog, waiting, finished, relevant = {}, {}, 0, 0
    for _, questId in ipairs(uses) do
        if not covered[questId] then
            local q = InLog(questId)
            if q then
                inLog[#inLog + 1] = q.title
                relevant = relevant + 1
            elseif ns.QuestDone and ns.QuestDone(questId) then
                finished = finished + 1
                relevant = relevant + 1
            elseif ns.QuestieIsDoable and ns.QuestieIsDoable(questId) then
                waiting[#waiting + 1] = QuestTitle(questId)
                relevant = relevant + 1
            end
        end
    end
    for _, title in ipairs(inLog) do Line(tooltip, format("Keep: for %s", title), GREEN) end
    if #waiting > 0 then
        local shown = {}
        for i = 1, math.min(MAX_LISTED, #waiting) do shown[i] = waiting[i] end
        local more = #waiting > MAX_LISTED and format(" +%d more", #waiting - MAX_LISTED) or ""
        Line(tooltip, format("Keep: for %s (not picked up yet)%s", table.concat(shown, ", "), more), YELLOW)
    end
    -- every quest that wants it is done, and nothing above says keep it
    if relevant > 0 and finished == relevant and next(covered) == nil then
        Line(tooltip, "Safe to sell: its quests are finished", GREY)
    end
end

-- True when nothing you're doing or could still do needs this item
function ns.QuestItemSafeToSell(itemID, itemName)
    if needsDirty then ScanNeeds() end
    if itemName and needs[itemName:lower()] then return false end
    local starts = ns.QuestieItemStarts and ns.QuestieItemStarts(itemID)
    if starts then
        return not InLog(starts) and ns.QuestDone and ns.QuestDone(starts) or false
    end
    local uses = ns.QuestieItemUses and ns.QuestieItemUses(itemID)
    if not uses or #uses == 0 or not ns.QuestDone then return false end
    for _, questId in ipairs(uses) do
        if InLog(questId) or not ns.QuestDone(questId) then return false end
    end
    return true
end

local function OnItemTooltip(tooltip)
    if not ns.db or not ns.db.questItemTips then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end
    if not tooltip.GetItem then return end
    local ok, name, link = pcall(tooltip.GetItem, tooltip)
    if not ok or type(link) ~= "string" or ns.IsSecret(link) then return end
    local itemID = tonumber(link:match("item:(%d+)"))
    if not itemID then return end
    if ns.IsSecret(name) then name = nil end
    pcall(AddQuestLines, tooltip, itemID, name)
end

local function HookTooltips()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
    else
        GameTooltip:HookScript("OnTooltipSetItem", OnItemTooltip)
        if ItemRefTooltip then ItemRefTooltip:HookScript("OnTooltipSetItem", OnItemTooltip) end
    end
end

---------------------------------------------------------------------------
-- Bags: items that start quests
---------------------------------------------------------------------------
local announced = {} -- itemID -> true, once per session
local firstScan = true

local function NumSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then return Safe(C_Container.GetContainerNumSlots, bag) or 0 end
    return GetContainerNumSlots and Safe(GetContainerNumSlots, bag) or 0
end

local function ItemAt(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = Safe(C_Container.GetContainerItemInfo, bag, slot)
        return info and info.itemID, info and info.hyperlink
    end
    local link = GetContainerItemLink and Safe(GetContainerItemLink, bag, slot)
    return link and tonumber(link:match("item:(%d+)")), link
end

-- The quest an item in your bags starts, if you haven't started it yet
local function StartsQuest(bag, slot, itemID)
    if C_Container and C_Container.GetContainerItemQuestInfo then
        local info = Safe(C_Container.GetContainerItemQuestInfo, bag, slot)
        if info and info.questID and info.questID > 0 then
            if info.isActive then return nil end
            return info.questID
        end
    end
    local questId = ns.QuestieItemStarts and ns.QuestieItemStarts(itemID)
    if questId and not InLog(questId) then return questId end
end

local function ScanBags()
    if not ns.db or not ns.db.questItemTips then return end
    local found = {}
    for bag = 0, NUM_BAG_SLOTS or 4 do
        for slot = 1, NumSlots(bag) do
            local itemID, link = ItemAt(bag, slot)
            if itemID and not announced[itemID] then
                local questId = StartsQuest(bag, slot, itemID)
                if questId and not (ns.QuestDone and ns.QuestDone(questId)) then
                    announced[itemID] = true
                    found[#found + 1] = { link = link, questId = questId }
                end
            end
        end
    end
    for _, f in ipairs(found) do
        local title = QuestTitle(f.questId)
        if firstScan then
            -- already in your bags at login: a reminder in chat, no pop-up
            ns.Print(format("%s in your bags starts |cffffd200%s|r - right-click it to begin.", f.link or "An item", title))
        else
            ns.Toast("This item starts a quest!", format("%s - right-click it in your bags.", title), ICON_STARTS)
            ns.Print(format("%s starts |cffffd200%s|r - right-click it in your bags to begin.", f.link or "That item", title))
        end
    end
    firstScan = false
end

table.insert(ns.inits, function()
    HookTooltips()
    ns.On("QUEST_LOG_UPDATE", function() needsDirty = true end)
    ns.On("BAG_UPDATE_DELAYED", ScanBags)
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReload)
        -- after the quest log and QuestieDB have had a moment
        if isInitialLogin or isReload then C_Timer.After(15, ScanBags) end
    end)
end)
