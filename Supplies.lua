local ADDON_NAME, ns = ...

-- Supplies: warns when food is running low or there's better food for your
-- level (less time sitting between pulls), when your bags are nearly full
-- mid-quest, and about what your class runs on: drink for those with mana, ammo,
-- soul shards, reagents and a hungry pet. The section only shows when there's
-- something to say.

local format = string.format
local Safe = ns.Safe
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemSpell = (C_Item and C_Item.GetItemSpell) or GetItemSpell

local LOW_FOOD = 5
local FEW_SLOTS = 4
local OLD_FOOD_LEVELS = 15 -- your best food's level this far under yours is worth an upgrade

local LOW_AMMO = 200
local ITEM_PROJECTILE = 6
local AMMO_FOR = { [2] = 2, [18] = 2, [3] = 3 } -- bow and crossbow: arrows; gun: bullets

local USES_MANA = { HUNTER = true, PALADIN = true, PRIEST = true, SHAMAN = true, MAGE = true, WARLOCK = true, DRUID = true }
-- what a class carries: only once it knows a spell that needs it
local REAGENTS = {
    WARLOCK = { { item = 6265, name = "Soul Shards", low = 3, spell = { 697 }, tip = "Drain Soul a mob as it dies." } },
    ROGUE = { { item = 5140, name = "Flash Powder", low = 3, spell = { 1856 }, tip = "Vanish needs it." } },
    SHAMAN = { { item = 17030, name = "Ankhs", low = 1, spell = { 20608 }, tip = "Reincarnation needs one." } },
    MAGE = { { item = 17031, name = "Runes of Teleportation", low = 3, spell = { 3561, 3562, 3565, 3563, 3566, 3567 },
               tip = "Your teleports need them." } },
}

local state = { food = 0, drink = 0, ammo = 0, reagents = {}, bestFoodLevel = nil, bestFoodName = nil, bandages = 0, free = nil }
local fullWarned = false

-- the game's own names, so these work in any language
local function SpellNames()
    local get = C_Spell and C_Spell.GetSpellName
    return get and Safe(get, 433) or "Food", get and Safe(get, 430) or "Drink"
end

-- arrows or bullets, whichever your bow or gun shoots; nil with neither
local function AmmoKind()
    local id = GetInventoryItemID and GetInventoryItemID("player", 18)
    local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not (id and getInstant) then return nil end
    local _, _, _, _, _, classID, subclassID = getInstant(id)
    return classID == 2 and AMMO_FOR[subclassID] or nil
end

local function Scan()
    local food, best, bestName, bandages, free = 0, nil, nil, 0, 0
    local drink, ammo = 0, 0
    local foodSpell, drinkSpell = SpellNames()
    local ammoKind = AmmoKind()
    local getInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    wipe(state.reagents)
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
            if id then state.reagents[id] = (state.reagents[id] or 0) + count end
            if id and ammoKind and getInstant then
                local _, _, _, _, _, classID, subclassID = getInstant(id)
                if classID == ITEM_PROJECTILE and subclassID == ammoKind then ammo = ammo + count end
            end
            if id and GetItemSpell then
                local spell = Safe(GetItemSpell, id)
                if spell == drinkSpell or spell == "Refreshment" then drink = drink + count end
                if spell == foodSpell or spell == "Refreshment" then
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
    state.drink, state.ammo, state.ammoKind = drink, ammo, ammoKind
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
    local class = ns.PlayerClassFile()
    local restock = class == "MAGE" and "conjure some." or "restock at an innkeeper."
    if level >= 5 and state.food < LOW_FOOD then
        notes[#notes + 1] = state.food == 0 and ("|cffffd200No food in your bags|r - " .. restock)
            or format("|cffffd200Only %d food left|r - %s", state.food, restock)
    end
    if level >= 5 and USES_MANA[class] and state.drink < LOW_FOOD then
        notes[#notes + 1] = state.drink == 0 and ("|cffffd200No drink in your bags|r - " .. restock)
            or format("|cffffd200Only %d drink left|r - %s", state.drink, restock)
    end
    if class == "HUNTER" then
        if state.ammoKind and state.ammo < LOW_AMMO then
            notes[#notes + 1] = format("|cffffd200Only %d %s left|r - buy more before you pull.", state.ammo,
                state.ammoKind == 2 and "arrows" or "bullets")
        end
        local happiness = GetPetHappiness and Safe(GetPetHappiness)
        if type(happiness) == "number" and happiness < 3 then
            notes[#notes + 1] = "|cffffd200Your pet is hungry|r - feed it: it fights worse when unhappy."
        end
    end
    for _, r in ipairs(REAGENTS[class] or {}) do
        local have = state.reagents[r.item] or 0
        if have < r.low then
            for _, spell in ipairs(r.spell) do
                if Safe(IsPlayerSpell, spell) == true then
                    notes[#notes + 1] = format("|cffffd200%s: %d|r - %s", r.name, have, r.tip)
                    break
                end
            end
        end
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
