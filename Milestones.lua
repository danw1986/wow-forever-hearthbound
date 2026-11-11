local ADDON_NAME, ns = ...

-- Milestone pop-ups (logged for the Journey tab) and level-up screenshots.

local format = string.format

local TOAST_SECONDS = 5
local LOG_SIZE = 60
local SOUND_TOAST = SOUNDKIT and (SOUNDKIT.UI_EPICLOOT_TOAST or SOUNDKIT.RAID_WARNING) or 8959
local SOUND_ACHIEVEMENT = SOUNDKIT and (SOUNDKIT.IG_QUEST_LIST_COMPLETE or SOUNDKIT.LEVELUPSOUND) or 878
local TIER_COLORS = { bronze = { 0.80, 0.50, 0.20, 1 }, silver = { 0.75, 0.75, 0.80, 1 }, gold = { 1, 0.84, 0, 1 } }

local QUEST_STEPS = { 25, 50, 100, 250, 500, 750, 1000, 1500, 2000 }
local KILL_STEPS = { 100, 500, 1000, 2500, 5000, 10000, 25000 }
local XP_STEPS = { 100000, 250000, 500000, 1000000, 2000000, 4000000 }
local ICON_LEVEL = "Interface\\Icons\\Spell_Holy_SurgeOfLight"
local ICON_MOUNT = "Interface\\Icons\\Ability_Mount_RidingHorse"
local ICON_QUEST = "Interface\\Icons\\INV_Misc_Book_08"
local ICON_KILL = "Interface\\Icons\\Ability_Warrior_Rampage"
local ICON_XP = "Interface\\Icons\\INV_Misc_Gem_Pearl_04"

local toast, queue = nil, {}

---------------------------------------------------------------------------
-- Toast frame
---------------------------------------------------------------------------
local function BuildToast()
    toast = CreateFrame("Frame", "HearthboundToast", UIParent, ns.BACKDROP)
    toast:SetSize(340, 64)
    toast:SetPoint("TOP", UIParent, "TOP", 0, -150)
    toast:SetFrameStrata("HIGH")
    ns.Skin(toast, { 0.05, 0.05, 0.06, 0.95 }, ns.color.gold)

    local accent = toast:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("BOTTOMLEFT", 1, 1)
    accent:SetWidth(3)
    toast.accent = accent

    toast.icon = ns.CreateIcon(toast, 44)
    toast.icon:SetPoint("LEFT", 12, 0)
    toast.icon:SetBackdropBorderColor(unpack(ns.color.gold))

    toast.title = ns.Text(toast, 15, ns.color.gold)
    toast.title:SetPoint("TOPLEFT", toast.icon, "TOPRIGHT", 12, -3)
    -- achievements: a "+25" badge in the tier's colour
    toast.badge = ns.Text(toast, 13, ns.color.gold, "OUTLINE")
    toast.badge:SetPoint("TOPRIGHT", -10, -8)
    toast.kicker = ns.Text(toast, 9, ns.color.dim)
    toast.kicker:SetPoint("BOTTOMRIGHT", -10, 7)

    toast.text = ns.Text(toast, 12)
    toast.text:SetPoint("TOPLEFT", toast.title, "BOTTOMLEFT", 0, -5)
    toast.text:SetPoint("RIGHT", -12, 0)
    toast.text:SetJustifyH("LEFT")

    local fadeIn = toast:CreateAnimationGroup()
    local a = fadeIn:CreateAnimation("Alpha")
    a:SetFromAlpha(0)
    a:SetToAlpha(1)
    a:SetDuration(0.3)
    toast.fadeIn = fadeIn

    local fadeOut = toast:CreateAnimationGroup()
    local b = fadeOut:CreateAnimation("Alpha")
    b:SetFromAlpha(1)
    b:SetToAlpha(0)
    b:SetDuration(0.6)
    fadeOut:SetScript("OnFinished", function()
        toast:Hide()
        toast.busy = false
        ns.ShowNextToast()
    end)
    toast.fadeOut = fadeOut

    toast:EnableMouse(true)
    toast:SetScript("OnMouseUp", function() toast.fadeOut:Play() end) -- click to dismiss
    toast:Hide()
end

function ns.ShowNextToast()
    if toast.busy or #queue == 0 then return end
    local item = table.remove(queue, 1)
    toast.busy = true
    toast.icon.icon:SetTexture(item.icon or ICON_LEVEL)
    toast.title:SetText(item.title)
    toast.text:SetText(item.text or "")
    -- achievements get a border, badge and sound of their tier
    local style = item.style
    local tier = style and TIER_COLORS[style.tier]
    local border = tier or ns.color.gold
    toast:SetBackdropBorderColor(border[1], border[2], border[3], 1)
    toast.icon:SetBackdropBorderColor(border[1], border[2], border[3], 1)
    toast.accent:SetColorTexture(unpack(tier or ns.color.accent))
    toast.badge:SetText(style and style.points and ("+" .. style.points) or "")
    if tier then toast.badge:SetTextColor(tier[1], tier[2], tier[3]) end
    toast.kicker:SetText(style and "ACHIEVEMENT UNLOCKED" or "")
    toast:SetAlpha(1)
    toast:Show()
    toast.fadeIn:Play()
    ns.PlaySound(style and SOUND_ACHIEVEMENT or SOUND_TOAST)
    C_Timer.After(TOAST_SECONDS, function()
        if toast:IsShown() and not toast.fadeOut:IsPlaying() then toast.fadeOut:Play() end
    end)
end

---------------------------------------------------------------------------
-- Milestones
---------------------------------------------------------------------------
-- key makes each milestone happen once; silent records it without a pop-up
---------------------------------------------------------------------------
-- Posting to party and guild chat (each optional):
-- "[Hearthbound] Level 30! 30 levels to go."
-- "[Hearthbound] Achievement: Hands off! (+10) - Blessing of Protection on Grok..."
---------------------------------------------------------------------------
local chatQueue = {} -- { msg, channel }, sent one at a time
local CHAT_GAP = 1.5 -- seconds between posts, so a burst of unlocks doesn't flood chat
local chatBusy = false

local function SendNext()
    local entry = chatQueue[1]
    if not entry then
        chatBusy = false
        return
    end
    -- addon chat is touchier in combat on this client, so wait it out (PLAYER_REGEN_ENABLED)
    if InCombatLockdown() then
        chatBusy = false
        return
    end
    table.remove(chatQueue, 1)
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if send then pcall(send, entry[1], entry[2]) end
    chatBusy = true
    C_Timer.After(CHAT_GAP, SendNext)
end

local function Post(msg, channel)
    if #chatQueue >= 10 then return end -- something's gone wrong: don't pile up
    chatQueue[#chatQueue + 1] = { msg, channel }
    if not chatBusy then SendNext() end
end

-- the party's channel: your party (or raid group), else a dungeon finder group
local function PartyChannel()
    if not IsInGroup then return nil end
    if IsInGroup(LE_PARTY_CATEGORY_HOME) then return "PARTY" end
    if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then return "INSTANCE_CHAT" end
end

-- the line posted for a milestone or achievement (style: an achievement's tier and points)
function ns.MilestoneChatLine(title, text, style)
    local msg
    if style then
        msg = "[Hearthbound] Achievement: " .. title .. (style.points and format(" (+%d)", style.points) or "")
        if text and text ~= "" then msg = msg .. " - " .. text end
    else
        msg = "[Hearthbound] " .. title .. (text and text ~= "" and (" " .. text) or "")
    end
    return (msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):sub(1, 250))
end

local function Broadcast(title, text, style)
    if not title then return end
    local msg = ns.MilestoneChatLine(title, text, style)
    local party = ns.db.achParty and PartyChannel()
    if party then Post(msg, party) end
    if ns.db.announceGuild and IsInGuild() then Post(msg, "GUILD") end
end

-- style (optional, achievements): { tier = "bronze"|"silver"|"gold", points = n }
function ns.Milestone(key, title, text, icon, silent, style)
    local done = ns.cdb.milestonesDone
    if done[key] then return end
    done[key] = time()
    if silent then return end
    local log = ns.cdb.milestoneLog
    table.insert(log, 1, { time = time(), title = title, text = text, icon = icon, level = UnitLevel("player"),
                           points = style and style.points })
    while #log > LOG_SIZE do table.remove(log) end
    if ns.db.toasts then
        queue[#queue + 1] = { title = title, text = text, icon = icon, style = style }
        ns.ShowNextToast()
    end
    ns.Print("|cffffd200" .. title .. "|r " .. (text or ""))
    Broadcast(title, text, style)
end

-- Fires the highest step reached; lower ones are recorded silently
local function CheckSteps(prefix, steps, value, describe, icon)
    local highest
    for _, step in ipairs(steps) do
        if value >= step and not ns.cdb.milestonesDone[prefix .. step] then highest = step end
    end
    if not highest then return end
    for _, step in ipairs(steps) do
        if step < highest then ns.Milestone(prefix .. step, nil, nil, nil, true) end
    end
    local title, text = describe(highest)
    ns.Milestone(prefix .. highest, title, text, icon)
end

local function QuestCount()
    return ns.QuestStats().count
end

local function CheckQuests()
    CheckSteps("quests:", QUEST_STEPS, QuestCount(), function(n)
        return format("%d quests completed!", n), "Your quest log keeps growing."
    end, ICON_QUEST)
end

local function CheckKills()
    CheckSteps("kills:", KILL_STEPS, ns.cdb.totalKills or 0, function(n)
        return format("%s kills!", ns.Comma(n)), "That's a lot of loot to sell."
    end, ICON_KILL)
end

local function CheckXP()
    CheckSteps("xp:", XP_STEPS, ns.cdb.totalXP or 0, function(n)
        return format("%s XP earned!", ns.Short(n)), "Experience tracked by Hearthbound since you installed it."
    end, ICON_XP)
end

local function OnLevelUp(_, newLevel)
    if ns.IsSecret(newLevel) or type(newLevel) ~= "number" then return end
    local max = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    if newLevel == max then
        ns.Milestone("level:" .. newLevel, format("Level %d!", newLevel), "You made it to the top. Congratulations!", ICON_LEVEL)
    elseif newLevel == 40 then
        ns.Milestone("level:40", "Mount time!", ns.MountReminderText(), ICON_MOUNT)
    elseif newLevel % 10 == 0 then
        ns.Milestone("level:" .. newLevel, format("Level %d!", newLevel), format("%d levels to go.", max - newLevel), ICON_LEVEL)
    end

    if ns.db.screenshots and Screenshot then
        -- after the level-up glow has started, so it's in the picture
        C_Timer.After(1.2, function()
            if pcall(Screenshot) then
                ns.cdb.screenshots = (ns.cdb.screenshots or 0) + 1
            end
        end)
    end
end

-- Record everything already achieved, so installing doesn't trigger a flood
local function MarkExisting()
    local level = UnitLevel("player")
    for l = 10, level, 10 do ns.Milestone("level:" .. l, nil, nil, nil, true) end
    if level >= 40 then ns.Milestone("level:40", nil, nil, nil, true) end
    for _, step in ipairs(QUEST_STEPS) do
        if QuestCount() >= step then ns.Milestone("quests:" .. step, nil, nil, nil, true) end
    end
    for _, step in ipairs(KILL_STEPS) do
        if (ns.cdb.totalKills or 0) >= step then ns.Milestone("kills:" .. step, nil, nil, nil, true) end
    end
    for _, step in ipairs(XP_STEPS) do
        if (ns.cdb.totalXP or 0) >= step then ns.Milestone("xp:" .. step, nil, nil, nil, true) end
    end
end

-- A one-off pop-up that isn't a milestone (not logged, not once-only)
function ns.Toast(title, text, icon)
    if not ns.db.toasts or not toast then return end
    queue[#queue + 1] = { title = title, text = text, icon = icon }
    ns.ShowNextToast()
end

-- The milestone steps, for the Achievements tab
local LEVEL_STEPS = { 10, 20, 30, 40, 50, 60 }
ns.MILESTONE_STEPS = { levels = LEVEL_STEPS, quests = QUEST_STEPS, kills = KILL_STEPS, xp = XP_STEPS }
ns.MILESTONE_ICONS = { levels = ICON_LEVEL, mount = ICON_MOUNT, quests = ICON_QUEST, kills = ICON_KILL, xp = ICON_XP }

function ns.TestToast()
    queue[#queue + 1] = { title = "Mount time!", text = ns.MountReminderText(), icon = ICON_MOUNT }
    ns.ShowNextToast()
end

table.insert(ns.inits, function()
    ns.On("PLAYER_REGEN_ENABLED", function()
        if not chatBusy and #chatQueue > 0 then
            chatBusy = true
            C_Timer.After(1, SendNext)
        end
    end)
    ns.cdb.milestonesDone = ns.cdb.milestonesDone or {}
    ns.cdb.milestoneLog = ns.cdb.milestoneLog or {}
    -- the speed levelling achievements are gone: forget the ones already earned
    for key in pairs(ns.cdb.milestonesDone) do
        if type(key) == "string" and (key:find("^ach:speed:") or key:find("^fastest:")) then
            ns.cdb.milestonesDone[key] = nil
        end
    end
    for i = #ns.cdb.milestoneLog, 1, -1 do
        local title = ns.cdb.milestoneLog[i].title
        if title == "New fastest level!" or (type(title) == "string" and title:find("^A level in under ")) then
            table.remove(ns.cdb.milestoneLog, i)
        end
    end
    BuildToast()
    if not ns.cdb.milestonesMarked then
        -- after the quest import has had a chance to run
        C_Timer.After(8, function()
            MarkExisting()
            ns.cdb.milestonesMarked = true
        end)
    end

    ns.On("PLAYER_LEVEL_UP", OnLevelUp)
    ns.On("QUEST_TURNED_IN", function() C_Timer.After(0.5, CheckQuests) end)
    ns.On("CHAT_MSG_COMBAT_XP_GAIN", CheckKills)
    ns.On("PLAYER_XP_UPDATE", CheckXP)
end)
