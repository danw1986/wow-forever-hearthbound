local ADDON_NAME, ns = ...

-- Quest log tidy-up: the quests in your log the guide's route never uses, and
-- grey ones (no real XP any more), each with an Abandon button - every
-- abandon asks first. /hb guide tidy, or click the guide window's
-- "log nearly full" line.

local format = string.format
local Safe = ns.Safe

local ROWS = 12
local frame
local rows = {}

-- the quests worth dropping: { id, title, level, why }, not-in-route first
function ns.GuideTidyList()
    local out = {}
    local me = UnitLevel("player")
    for _, q in ipairs(ns.openQuests or {}) do
        local grey = q.level and ns.QuestDifficulty and ns.QuestDifficulty(q.level, me) == "trivial"
        local used = ns.GuideUsesQuest and ns.GuideUsesQuest(q.id)
        if not used or grey then
            out[#out + 1] = { id = q.id, title = q.title or ("Quest " .. q.id), level = q.level,
                              why = (not used) and "not in the route" or "grey - little XP",
                              complete = q.complete }
        end
    end
    table.sort(out, function(a, b)
        if (a.why == "not in the route") ~= (b.why == "not in the route") then return a.why == "not in the route" end
        return (a.level or 0) < (b.level or 0)
    end)
    return out
end

-- abandon a quest by ID (after you've said yes)
local function Abandon(id)
    local index = GetQuestLogIndexByID and Safe(GetQuestLogIndexByID, id)
    if C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.SetAbandonQuest and C_QuestLog.AbandonQuest then
        Safe(C_QuestLog.SetSelectedQuest, id)
        Safe(C_QuestLog.SetAbandonQuest)
        Safe(C_QuestLog.AbandonQuest)
        return true
    end
    if index and index > 0 and SelectQuestLogEntry and SetAbandonQuest and AbandonQuest then
        Safe(SelectQuestLogEntry, index)
        Safe(SetAbandonQuest)
        Safe(AbandonQuest)
        return true
    end
    return false
end

-- (add our popup to Blizzard's table; never reassign the table itself - that taints it)
StaticPopupDialogs["HEARTHBOUND_ABANDON_QUEST"] = {
    text = "Abandon |cffffd200%s|r?\n(You can't undo this - you'd have to pick it up again.)",
    button1 = "Abandon",
    button2 = "Keep it",
    OnAccept = function(_, data)
        if data and Abandon(data.id) then
            ns.Print(format("Abandoned |cffffd200%s|r.", data.title))
        else
            ns.Print("Couldn't abandon that quest from here - open your quest log and abandon it there.")
        end
        C_Timer.After(0.5, function() if frame and frame:IsShown() then ns.ShowGuideTidy() end end)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function Build()
    frame = CreateFrame("Frame", "HearthboundGuideTidy", UIParent, ns.BACKDROP)
    frame:SetSize(330, 60)
    frame:SetPoint("CENTER", 0, 80)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.96 }, ns.color.border)
    table.insert(UISpecialFrames, "HearthboundGuideTidy")
    frame.title = ns.Text(frame, 12, ns.color.gold)
    frame.title:SetPoint("TOPLEFT", 10, -9)
    frame.empty = ns.Text(frame, 11, ns.color.dim)
    frame.empty:SetPoint("TOPLEFT", 10, -30)
    frame.empty:SetText("Nothing to tidy: every quest in your log is one the route uses.")
    local close = ns.CreateButton(frame, "x", 16, 16, function() frame:Hide() end)
    close:SetPoint("TOPRIGHT", -5, -5)
    for i = 1, ROWS do
        local r = CreateFrame("Frame", nil, frame)
        r:SetSize(310, 20)
        r:SetPoint("TOPLEFT", 10, -28 - (i - 1) * 22)
        r.text = ns.Text(r, 11)
        r.text:SetPoint("LEFT", 0, 0)
        r.text:SetWidth(220)
        r.text:SetJustifyH("LEFT")
        r.text:SetWordWrap(false)
        r.drop = ns.CreateButton(r, "Abandon", 80, 18, function(self)
            local d = self:GetParent().data
            if d then StaticPopup_Show("HEARTHBOUND_ABANDON_QUEST", d.title, nil, d) end
        end)
        r.drop.text:SetFont(ns.FONT, 10, "")
        r.drop:SetPoint("RIGHT", 0, 0)
        rows[i] = r
    end
    frame:Hide()
end

function ns.ShowGuideTidy()
    if not frame then Build() end
    local list = ns.GuideTidyList()
    local max = ns.MaxQuests and ns.MaxQuests() or 20
    frame.title:SetText(format("Tidy your quest log (%d/%d)", #(ns.openQuests or {}), max))
    for i, r in ipairs(rows) do
        local d = list[i]
        r.data = d
        if d then
            r.text:SetText(format("%s%s |cff999999(%s)|r", d.level and ("[" .. d.level .. "] ") or "", d.title, d.why))
            r:Show()
        else
            r:Hide()
        end
    end
    frame.empty:SetShown(#list == 0)
    frame:SetHeight(40 + math.max(1, math.min(#list, ROWS)) * 22)
    frame:Show()
end
