local ADDON_NAME, ns = ...

-- Repair warning: tracks the most worn piece of equipped gear

local Safe = ns.Safe

-- head, shoulder, chest, waist, legs, feet, wrist, hands, main hand, off hand, ranged
local SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }
local WARN_AT, RESET_AT = 0.2, 0.5
local SOUND_WARN = SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 3081

local warned = false

-- Lowest durability fraction across equipped items, or nil if nothing has durability
local function LowestDurability()
    local lowest
    for _, slot in ipairs(SLOTS) do
        local cur, max = Safe(GetInventoryItemDurability, slot)
        if cur and max and max > 0 then
            local pct = cur / max
            if not lowest or pct < lowest then lowest = pct end
        end
    end
    return lowest
end

local function DurabilityColor(pct)
    if pct <= 0.2 then return "ff5544" end
    if pct <= 0.5 then return "ffd200" end
    return "6fdc6f"
end

local function CheckWarning()
    local pct = LowestDurability()
    if not pct then return end
    if pct <= WARN_AT and not warned then
        warned = true
        ns.Print(string.format("|cffff5544Your gear is at %d%% - repair soon!|r", math.floor(pct * 100)))
        ns.PlaySound(SOUND_WARN)
    elseif pct > RESET_AT then
        warned = false
    end
    ns.UpdatePanel()
end

ns.AddSection(40, function(add)
    if not ns.db.showGear then return end
    local pct = LowestDurability()
    if not pct then return end
    add.header("Gear")
    add.row("Lowest durability", string.format("|cff%s%d%%|r", DurabilityColor(pct), math.floor(pct * 100)))
    if pct <= WARN_AT then
        add.note("Repair at the next vendor - broken gear stops working.", { 1, 0.35, 0.3, 1 })
    end
end)

table.insert(ns.inits, function()
    ns.On("UPDATE_INVENTORY_DURABILITY", CheckWarning)
end)
