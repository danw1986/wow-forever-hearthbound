local ADDON_NAME, ns = ...

-- Hover the gold in your bags to see every character's gold and the total.
-- Works with Blizzard's combined bag and the separate backpack. The gold of
-- other characters is what they had when you last played them (see Alts.lua).

local format = string.format

-- Blizzard money frames that show your gold in the bags
local MONEY_FRAMES = {
    function() return ContainerFrameCombinedBags and ContainerFrameCombinedBags.MoneyFrame end,
    function() return _G.ContainerFrame1MoneyFrame end,
    function() return ContainerFrame1 and ContainerFrame1.MoneyFrame end,
}
local COIN_BUTTONS = { "GoldButton", "SilverButton", "CopperButton" }

local hooked = {}

local function ClassColor(class)
    local c = RAID_CLASS_COLORS and class and RAID_CLASS_COLORS[class]
    return c and format("%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255) or "ffffff"
end

local function ShowGoldTooltip(owner)
    if not ns.db or not ns.db.bagGoldTooltip then return end
    local me = ns.AltKey and ns.AltKey() or ns.CharKey()
    local myRealm = GetRealmName()
    local list, total = {}, 0
    for key, alt in pairs(ns.db.alts or {}) do
        local money = key == me and GetMoney() or (alt.money or 0)
        total = total + money
        list[#list + 1] = { key = key, alt = alt, money = money, me = key == me }
    end
    if not ns.db.alts or not ns.db.alts[me] then
        -- your character before its first snapshot
        total = total + GetMoney()
        local _, class = UnitClass("player")
        list[#list + 1] = { key = me, alt = { name = ns.FullName(), realm = myRealm, class = class }, money = GetMoney(), me = true }
    end
    table.sort(list, function(a, b) return a.money > b.money end)

    GameTooltip:SetOwner(owner, "ANCHOR_TOPLEFT")
    GameTooltip:SetText("Gold on all characters", 1, 0.82, 0)
    for _, e in ipairs(list) do
        local name = format("|cff%s%s|r", ClassColor(e.alt.class), e.alt.name or e.key)
        if e.alt.realm and e.alt.realm ~= myRealm then name = name .. " |cff999999- " .. e.alt.realm .. "|r" end
        if e.me then name = name .. " |cff999999(you)|r" end
        GameTooltip:AddDoubleLine(name, ns.Money(e.money), 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total", ns.Money(total), 1, 0.82, 0, 1, 1, 1)
    if #list <= 1 then
        GameTooltip:AddLine("Log in on your other characters once to add them.", 0.6, 0.6, 0.6, true)
    end
    GameTooltip:Show()
end

local function Hook(frame)
    if not frame or hooked[frame] or not frame.HookScript then return end
    hooked[frame] = true
    frame:HookScript("OnEnter", ShowGoldTooltip)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
    -- the coin buttons sit on top of the money frame and take the mouse
    for _, name in ipairs(COIN_BUTTONS) do
        local button = frame[name] or (frame.GetName and frame:GetName() and _G[frame:GetName() .. name])
        if button and not hooked[button] and button.HookScript then
            hooked[button] = true
            button:HookScript("OnEnter", function() ShowGoldTooltip(button) end)
            button:HookScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end
end

local function HookMoneyFrames()
    for _, find in ipairs(MONEY_FRAMES) do
        local ok, frame = pcall(find)
        if ok then Hook(frame) end
    end
end

table.insert(ns.inits, function()
    ns.On("PLAYER_LOGIN", HookMoneyFrames)
    -- bag frames can be created when first opened
    ns.On("BAG_OPEN", HookMoneyFrames)
    if hooksecurefunc then
        for _, fn in ipairs({ "OpenAllBags", "ToggleAllBags", "OpenBackpack", "ToggleBackpack" }) do
            if _G[fn] then hooksecurefunc(fn, HookMoneyFrames) end
        end
    end
end)
