local ADDON_NAME, ns = ...

-- Quest links: in chat, links to quests you've done get "(Completed)" after
-- them; click (or hover) one and the tooltip says whether you've done it, have
-- it, or can take it, and where it starts.

local format = string.format
local Safe = ns.Safe

local GREEN = { 0.25, 1, 0.25 }
local YELLOW = { 1, 0.82, 0 }
local GREY = { 0.6, 0.6, 0.6 }
local RED = { 1, 0.4, 0.3 }

local function Line(tooltip, text, color)
    tooltip:AddLine(text, color[1], color[2], color[3], true)
end

local function InLog(questID)
    for _, q in ipairs(ns.openQuests or {}) do
        if q.id == questID then return q end
    end
end

---------------------------------------------------------------------------
-- Extras for any quest tooltip: where the chain leads, and alts who did it
---------------------------------------------------------------------------
local BLUE = { 0.55, 0.72, 1 }

-- Group, dungeon and raid quests (the game's own quest tags), cached:
-- "group" / "dungeon" / "raid" or nil
local TAGS = { [1] = "group", [81] = "dungeon", [62] = "raid" }
local tagCache = {}
function ns.QuestGroupTag(questID)
    if not questID then return nil end
    if tagCache[questID] ~= nil then return tagCache[questID] or nil end
    local tag
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local info = Safe(C_QuestLog.GetQuestTagInfo, questID)
        tag = type(info) == "table" and TAGS[info.tagID] or nil
    elseif GetQuestTagInfo then
        tag = TAGS[Safe(GetQuestTagInfo, questID) or 0]
    end
    -- the game sometimes answers late: only remember an answer
    if tag or (C_QuestLog and C_QuestLog.GetQuestTagInfo) then tagCache[questID] = tag or false end
    return tag
end

-- "+3" style marker for list rows, or "" when the quest doesn't lead anywhere
function ns.ChainMarker(questID)
    local ahead = ns.QuestieChainAhead and ns.QuestieChainAhead(questID)
    return ahead and format(" |cff8cb8ff>%d|r", ahead.count) or ""
end

function ns.AddQuestExtras(tooltip, questID)
    local ahead = ns.QuestieChainAhead and ns.QuestieChainAhead(questID)
    if ahead then
        local path = table.concat(ahead.titles, " > ")
        local more = ahead.count - #ahead.titles
        if more > 0 then path = path .. format(" (+%d more)", more) end
        Line(tooltip, "Leads to: " .. path, BLUE)
        if ahead.xp > 0 then
            Line(tooltip, format("Chain after this: %d quest%s, about %s XP", ahead.count, ahead.count == 1 and "" or "s",
                ns.Comma(ahead.xp)), GREY)
        end
    end
    local alts = ns.AltsWhoDid and ns.AltsWhoDid(questID) or {}
    if #alts > 0 then Line(tooltip, "Done on: " .. table.concat(alts, ", "), GREY) end
end

---------------------------------------------------------------------------
-- "Mark chain start": on a clicked link to a quest you can't take yet
---------------------------------------------------------------------------
local chainButton

local function ChainButton()
    if chainButton then return chainButton end
    chainButton = ns.CreateButton(ItemRefTooltip, "Mark chain start", 130, 20, function(self)
        local g = self.giver
        if g and g.mapID then ns.SetWaypoint(g.mapID, g.x, g.y, (g.giver or "?") .. " - " .. g.title) end
    end)
    chainButton:SetPoint("BOTTOM", ItemRefTooltip, "BOTTOM", 0, 8)
    chainButton:SetFrameLevel(ItemRefTooltip:GetFrameLevel() + 5)
    chainButton:Hide()
    ItemRefTooltip:HookScript("OnHide", function() chainButton:Hide() end)
    return chainButton
end

local function WhereText(g)
    local info = g.mapID and Safe(C_Map.GetMapInfo, g.mapID)
    return format("%s - %s %.1f, %.1f", g.giver or "?", info and info.name or "?", g.x or 0, g.y or 0)
end

-- the first quest you can take on the way to this one, as lines (and the button
-- on a clicked link)
local function AddChainStart(tooltip, questID)
    local startId = ns.QuestieChainStart and ns.QuestieChainStart(questID)
    if not startId then return end
    local title = (ns.QuestieQuestName and ns.QuestieQuestName(startId)) or ("quest " .. startId)
    local giver = ns.QuestieGiverById and ns.QuestieGiverById(startId)
    Line(tooltip, "Chain starts with: " .. title, YELLOW)
    if giver and giver.mapID then
        Line(tooltip, "   " .. WhereText(giver), GREY)
    else
        Line(tooltip, "   (where it starts isn't known)", GREY)
    end
    if tooltip == ItemRefTooltip and giver and giver.mapID then
        local button = ChainButton()
        button.giver = { mapID = giver.mapID, x = giver.x, y = giver.y, giver = giver.giver, title = title }
        -- room for the button under the text
        tooltip:AddLine(" ")
        tooltip:AddLine(" ")
        button:Show()
    elseif tooltip == GameTooltip then
        Line(tooltip, "Click the link to mark it on your map.", GREY)
    end
end

local function AddQuestLines(tooltip, questID)
    tooltip:AddLine(" ")
    local logged = InLog(questID)
    local record = ns.cdb and ns.cdb.quests and ns.cdb.quests[questID]
    if logged then
        Line(tooltip, logged.complete and "In your quest log - ready to hand in" or "In your quest log", YELLOW)
    elseif ns.QuestDone and ns.QuestDone(questID) then
        local when = record and record.time and (" on " .. date("%d %b %Y", record.time)) or ""
        Line(tooltip, "You've completed this quest" .. when, GREEN)
    else
        Line(tooltip, "You haven't completed this quest", RED)
        -- can you take it now? (QuestieDB knows the requirements)
        local doable = ns.QuestieIsDoable and ns.QuestieIsDoable(questID)
        if doable == true then
            Line(tooltip, "You can pick it up now", GREEN)
        elseif doable == false then
            local why = ns.QuestieWhyNot and ns.QuestieWhyNot(questID)
            Line(tooltip, "Can't take it yet" .. (why and (": " .. why) or ""), GREY)
            AddChainStart(tooltip, questID)
        end
        -- where it starts
        local giver = ns.QuestieGiverById and ns.QuestieGiverById(questID)
        if giver and giver.mapID then
            local info = Safe(C_Map.GetMapInfo, giver.mapID)
            Line(tooltip, format("Starts at: %s - %s %.1f, %.1f", giver.giver or "?", info and info.name or "?", giver.x, giver.y), GREY)
        end
    end
    ns.AddQuestExtras(tooltip, questID)
    tooltip:Show()
end

local function OnHyperlink(tooltip, link)
    if tooltip == ItemRefTooltip and chainButton then chainButton:Hide() end -- a new link replaces the old one
    if type(link) ~= "string" or ns.IsSecret(link) then return end
    local questID = tonumber(link:match("quest:(%d+)"))
    if questID then pcall(AddQuestLines, tooltip, questID) end
end

---------------------------------------------------------------------------
-- Chat: "[Quest name] (Completed)" after links to quests you've done
---------------------------------------------------------------------------
local LABEL = " |cff40ff40(Completed)|r"

local CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_CHANNEL",
}

-- the message with the label added after each completed quest's link, or nil
local function LabelLinks(msg)
    local out, pos, changed = {}, 1, false
    while true do
        local s, e, id = msg:find("|Hquest:(%d+)[^|]*|h%[[^%]]*%]|h", pos)
        if not s then break end
        if msg:sub(e + 1, e + 2) == "|r" then e = e + 2 end -- keep the link's colour closed first
        out[#out + 1] = msg:sub(pos, e)
        if ns.QuestDone and ns.QuestDone(tonumber(id)) then
            out[#out + 1] = LABEL
            changed = true
        end
        pos = e + 1
    end
    if not changed then return nil end
    out[#out + 1] = msg:sub(pos)
    return table.concat(out)
end

local function ChatFilter(_, _, msg, ...)
    if not ns.db or not ns.db.questLinkLabels then return false end
    if type(msg) ~= "string" or ns.IsSecret(msg) or not msg:find("|Hquest:", 1, true) then return false end
    local ok, labelled = pcall(LabelLinks, msg)
    if ok and labelled then return false, labelled, ... end
    return false
end

table.insert(ns.inits, function()
    local addFilter = ChatFrame_AddMessageEventFilter
        or (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
    if addFilter then
        for _, event in ipairs(CHAT_EVENTS) do pcall(addFilter, event, ChatFilter) end
    end
    -- clicked links open in ItemRefTooltip; hovering one in chat uses GameTooltip
    if ItemRefTooltip then hooksecurefunc(ItemRefTooltip, "SetHyperlink", OnHyperlink) end
    hooksecurefunc(GameTooltip, "SetHyperlink", OnHyperlink)
end)
