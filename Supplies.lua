local ADDON_NAME, ns = ...

-- Supplies: warns when food is running low or there's better food for your
-- level (less time sitting between pulls), and when your bags are nearly full
-- mid-quest. The section only shows when there's something to say.

local format = string.format
local Safe = ns.Safe
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemSpell = (C_Item and C_Item.GetItemSpell) or GetItemSpell

local LOW_FOOD = 5
local FEW_SLOTS = 4
local OLD_FOOD_LEVELS = 15 -- your best food's level this far under yours is worth an upgrade

local state = { food = 0, bestFoodLevel = nil, bestFoodName = nil, bandages = 0, free = nil }
local fullWarned = false

local function Scan()
    local food, best, bestName, bandages, free = 0, nil, nil, 0, 0
    for bag = 0, NUM_BAG_SLOTS or 4 do
        local slots = (C_Container and C_Container.GetContainerNumSlots and Safe(C_Container.GetContainerNumSlots, bag))
            or (GetContainerNumSlots and Safe(GetContainerNumSlots, bag)) or 0
        local freeSlots = (C_Container and C_Container.GetContainerNumFreeSlots and Safe(C_Container.GetContainerNumFreeSlots, bag))
            or (GetContainerNumFreeSlots and Safe(GetContainerNumFreeSlots, bag))
        -- only normal bags count (not quivers and ammo pouches)
        local _, bagType = (C_Container and C_Container.GetContainerNumFreeSlots and Safe(C_Container.GetContainerNumFreeSlots, bag))
        if freeSlots and (bagType == nil or bagType == 0) then free = free + freeSlots end
        for slot = 1, slots do
            local info = C_Container and C_Container.GetContainerItemInfo and Safe(C_Container.GetContainerItemInfo, bag, slot)
            local id, count = info and info.itemID, info and info.stackCount or 1
            if id and GetItemSpell then
                local spell = Safe(GetItemSpell, id)
                if spell == "Food" or spell == "Refreshment" then
                    food = food + count
                    local _, _, _, _, minLevel = GetItemInfo(id)
                    if minLevel and (not best or minLevel > best) then best, bestName = minLevel, (GetItemInfo(id)) end
                elseif spell == "First Aid" then
                    bandages = bandages + count
                end
            end
        end
    end
    state.food, state.bestFoodLevel, state.bestFoodName, state.bandages, state.free = food, best, bestName, bandages, free
    if free == 0 and not fullWarned and ns.db.showSupplies then
        fullWarned = true
        if ns.Toast then ns.Toast("Bags full!", "New loot will be left behind - sell or destroy something.", "Interface\\Icons\\INV_Misc_Bag_10") end
    elseif free > 0 then
        fullWarned = false
    end
end

ns.AddSection(41, function(add, level)
    if not ns.db.showSupplies then return end
    local notes = {}
    if state.free and state.free <= FEW_SLOTS then
        notes[#notes + 1] = format("|cffff5544Bags: %d free slot%s|r - sell junk before you pull more.", state.free, state.free == 1 and "" or "s")
    end
    if level >= 5 and state.food < LOW_FOOD then
        notes[#notes + 1] = state.food == 0 and "|cffffd200No food in your bags|r - restock at an innkeeper."
            or format("|cffffd200Only %d food left|r - restock at an innkeeper.", state.food)
    end
    if state.bestFoodLevel and level - state.bestFoodLevel >= OLD_FOOD_LEVELS then
        notes[#notes + 1] = format("Your best food (%s) is low level - better food heals much faster.", state.bestFoodName or "?")
    end
    if #notes == 0 then return end
    add.header("Supplies")
    for _, text in ipairs(notes) do add.note(text) end
end)

table.insert(ns.inits, function()
    ns.On("BAG_UPDATE_DELAYED", function() pcall(Scan) end)
    ns.On("PLAYER_ENTERING_WORLD", function() C_Timer.After(3, function() pcall(Scan) end) end)
end)
