local ADDON_NAME, ns = ...

-- Quest item button: the item the guide's current step needs you to use
-- (a totem to plant, a rod to tame with, a sapta to drink, an item that starts
-- a quest...). Click it to use the item. It's a secure button, so it can only
-- change out of combat; a change during a fight happens as soon as it ends.
--
-- Which item: the step's own item (a quest that starts from loot), the game's
-- quest-log item for the quest where the client has one, then QuestieDB's
-- items for the quest (the item it gives you to use, and the ones it needs)
-- - whichever you're carrying.

local Safe = ns.Safe
local SIZE = 36

local button
local shownItem

local function ItemCount(id)
    local get = (C_Item and C_Item.GetItemCount) or GetItemCount
    local n = get and Safe(get, id)
    return type(n) == "number" and n or 0
end

local function ItemIcon(id)
    local icon = (C_Item and C_Item.GetItemIconByID and Safe(C_Item.GetItemIconByID, id)) or (GetItemIcon and Safe(GetItemIcon, id))
    return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- an item that can be used ("Use: ..."), by the game's item spell
local function Usable(id)
    local spell = (C_Item and C_Item.GetItemSpell and Safe(C_Item.GetItemSpell, id)) or (GetItemSpell and Safe(GetItemSpell, id))
    return spell ~= nil
end

-- the game's quest-log item for a quest (clients that have it)
local function LogItem(q)
    if not (GetQuestLogIndexByID and GetQuestLogSpecialItemInfo) then return nil end
    local index = Safe(GetQuestLogIndexByID, q)
    if not (type(index) == "number" and index > 0) then return nil end
    local link = Safe(GetQuestLogSpecialItemInfo, index)
    local id = type(link) == "string" and tonumber(link:match("item:(%d+)"))
    return id
end

-- the item to show for the step on screen, or nil
local function WantedItem()
    local s = ns.GuideCurrent and ns.GuideCurrent()
    if not (s and ns.db.guide and ns.db.guideItemButton ~= false) then return nil end
    local candidates = {}
    if s.target and s.target.kind == "item" and s.target.id then candidates[#candidates + 1] = s.target.id end
    if s.q then
        candidates[#candidates + 1] = LogItem(s.q)
        if ns.QuestieGet then
            candidates[#candidates + 1] = ns.QuestieGet("Quest", s.q, "sourceItemId")
            local req = ns.QuestieGet("Quest", s.q, "requiredSourceItems")
            for _, id in ipairs(type(req) == "table" and req or {}) do candidates[#candidates + 1] = id end
        end
    end
    for _, id in ipairs(candidates) do
        if type(id) == "number" and id > 0 and ItemCount(id) > 0 and Usable(id) then return id end
    end
    -- a quest that starts from an item: the item itself, used from your bags
    if s.t == "A" and s.target and s.target.kind == "item" and s.target.id and ItemCount(s.target.id) > 0 then
        return s.target.id
    end
    return nil
end

local function Build()
    button = CreateFrame("Button", "HearthboundGuideItemButton", UIParent, "SecureActionButtonTemplate")
    button:SetSize(SIZE, SIZE)
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type", "item")
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    button.count:SetPoint("BOTTOMRIGHT", -2, 2)
    local hl = button:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.2)
    button:SetScript("OnDragStart", function(self) if not InCombatLockdown() then self:StartMoving() end end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        ns.db.positions.guideItem = { p, rp, x, y }
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if shownItem and GameTooltip.SetItemByID then GameTooltip:SetItemByID(shownItem) end
        GameTooltip:AddLine("Click: use it for the guide's step. Drag to move.", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local pos = ns.db.positions.guideItem
    if pos then
        button:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    else
        button:SetPoint("CENTER", UIParent, "CENTER", 0, -160)
    end
    button:Hide()
end

local function Update()
    if not button or InCombatLockdown() then return end
    local id = WantedItem()
    if id ~= shownItem then
        shownItem = id
        if id then
            button:SetAttribute("item", "item:" .. id)
            button.icon:SetTexture(ItemIcon(id))
        else
            button:SetAttribute("item", nil)
        end
    end
    if id then
        local n = ItemCount(id)
        button.count:SetText(n > 1 and n or "")
        button:Show()
    else
        button:Hide()
    end
end
ns.UpdateGuideItemButton = Update
ns.GuideItemWanted = WantedItem

table.insert(ns.inits, function()
    Build()
    C_Timer.NewTicker(1, function() pcall(Update) end)
    ns.On("PLAYER_REGEN_ENABLED", function() pcall(Update) end)
    ns.On("BAG_UPDATE_DELAYED", function() pcall(Update) end)
    table.insert(ns.refreshers, function() pcall(Update) end)
end)
