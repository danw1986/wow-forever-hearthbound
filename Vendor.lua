local ADDON_NAME, ns = ...

-- Vendor helper: when you open a vendor, sell grey items and quest items whose
-- quests are all finished, then say how much it made. Hold Shift to skip.

local format = string.format
local Safe = ns.Safe

local QUEST_CLASS = (Enum and Enum.ItemClass and Enum.ItemClass.Questitem) or 12
local POOR = (Enum and Enum.ItemQuality and Enum.ItemQuality.Poor) or 0
local PER_TICK = 3      -- items sold each step; the vendor drops sales sent too fast
local TICK = 0.2

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

local selling -- ticker while a sale is running
local sold, earned = 0, 0

local function NumSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then return Safe(C_Container.GetContainerNumSlots, bag) or 0 end
    return GetContainerNumSlots and Safe(GetContainerNumSlots, bag) or 0
end

local function SlotInfo(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = Safe(C_Container.GetContainerItemInfo, bag, slot)
        if info then return info.itemID, info.stackCount or 1, info.quality, info.hasNoValue, info.isLocked, info.hyperlink end
        return nil
    end
    if not GetContainerItemInfo then return nil end
    local _, count, locked, quality, _, _, link, _, noValue, itemID = Safe(GetContainerItemInfo, bag, slot)
    return itemID, count or 1, quality, noValue, locked, link
end

local function UseItem(bag, slot)
    if C_Container and C_Container.UseContainerItem then return pcall(C_Container.UseContainerItem, bag, slot) end
    if UseContainerItem then return pcall(UseContainerItem, bag, slot) end
end

local function SellPrice(itemID)
    local price = select(11, Safe(GetItemInfo, itemID))
    return type(price) == "number" and price or 0
end

local function ItemClass(itemID)
    local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    return getInstant and select(6, Safe(getInstant, itemID))
end

-- Why this item should go: "junk", "quest" or nil to keep it
local function Verdict(itemID, quality, noValue)
    if noValue then return nil end
    if SellPrice(itemID) <= 0 then return nil end
    if quality == POOR then return "junk" end
    -- only real quest items: trade goods like cloth stay, even if no quest wants them now
    if ns.db.questItemTips and ItemClass(itemID) == QUEST_CLASS and ns.QuestItemSafeToSell then
        local name = Safe(GetItemInfo, itemID)
        if ns.QuestItemSafeToSell(itemID, name) then return "quest" end
    end
end

local function Queue()
    local list = {}
    for bag = 0, NUM_BAG_SLOTS or 4 do
        for slot = 1, NumSlots(bag) do
            local itemID, count, quality, noValue, locked = SlotInfo(bag, slot)
            if itemID and not locked then
                local why = Verdict(itemID, quality, noValue)
                if why then list[#list + 1] = { bag = bag, slot = slot, itemID = itemID, value = SellPrice(itemID) * count, why = why } end
            end
        end
    end
    return list
end

local function Finish()
    if selling then selling:Cancel() end
    selling = nil
    if sold > 0 then
        ns.cdb.junkSold = (ns.cdb.junkSold or 0) + sold -- all time, for achievements
        ns.Print(format("Sold %d junk item%s for %s.", sold, sold == 1 and "" or "s", ns.Money(earned)))
    end
    sold, earned = 0, 0
end

local function OnMerchantShow()
    if not ns.db.autoSell or IsShiftKeyDown() or selling then return end
    local list = Queue()
    if #list == 0 then return end
    local i = 1
    selling = C_Timer.NewTicker(TICK, function()
        if not MerchantFrame or not MerchantFrame:IsShown() then return Finish() end
        for _ = 1, PER_TICK do
            local item = list[i]
            if not item then return Finish() end
            i = i + 1
            -- only if the same item is still in that slot
            local itemID = SlotInfo(item.bag, item.slot)
            if itemID == item.itemID and UseItem(item.bag, item.slot) then
                sold = sold + 1
                earned = earned + item.value
            end
        end
    end)
end

table.insert(ns.inits, function()
    ns.On("MERCHANT_SHOW", OnMerchantShow)
    ns.On("MERCHANT_CLOSED", function() if selling then Finish() end end)
end)
