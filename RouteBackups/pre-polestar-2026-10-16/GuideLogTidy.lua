local ADDON_NAME, ns = ...

-- Quest log tidy-up: the quests in your log the guide's route never uses, and
-- grey ones (no real XP any more), each with an Abandon button - every
-- abandon asks first. In the shell's Guide panel (Tidy quest log), or
-- /hb guide tidy, or click the guide window's "log nearly full" line.

local format = string.format
local Safe = ns.Safe

local ROW_H, HEAD_H, PAD = 26, 32, 22
local view
local lines = {}

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
        C_Timer.After(0.5, function() if view and view:IsVisible() then view:Refresh() end end)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function Line(i)
    if lines[i] then return lines[i] end
    local r = CreateFrame("Frame", nil, view)
    function r.Place(_, y)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", PAD, -y)
        r:SetPoint("TOPRIGHT", -PAD, -y)
    end
    r.text = ns.Text(r, 12)
    r.text:SetPoint("LEFT", 0, 0)
    r.text:SetJustifyH("LEFT")
    r.text:SetWordWrap(false)
    r.count = ns.Text(r, 10, ns.color.dim)
    r.count:SetPoint("RIGHT", 0, 0)
    r.rule = r:CreateTexture(nil, "ARTWORK")
    r.rule:SetColorTexture(1, 1, 1, 0.08)
    r.rule:SetHeight(1)
    r.rule:SetPoint("BOTTOMLEFT", 0, 4)
    r.rule:SetPoint("BOTTOMRIGHT", 0, 4)
    r.drop = ns.CreateButton(r, "Abandon", 80, 20, function(self)
        local d = self:GetParent().data
        if d then StaticPopup_Show("HEARTHBOUND_ABANDON_QUEST", d.title, nil, d) end
    end)
    r.drop.text:SetFont(ns.FONT, 10, "")
    r.drop:SetPoint("RIGHT", 0, 0)
    r.text:SetPoint("RIGHT", r.drop, "LEFT", -10, 0)
    lines[i] = r
    return r
end

-- the tidy-up, as a view in parent (the Guide panel): a heading per reason, a row per quest
function ns.BuildGuideTidy(parent)
    view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints()
    view.empty = ns.Text(view, 12, ns.color.dim)
    view.empty:SetPoint("TOPLEFT", PAD, -24)
    view.empty:SetText("Nothing to tidy: every quest in your log is one the route uses.")
    function view.Refresh()
        local list = ns.GuideTidyList()
        local groups = { { why = "not in the route", label = "Not in the route" }, { why = "grey - little XP", label = "Grey - little XP left" } }
        local n, y = 0, 10
        for _, g in ipairs(groups) do
            local items = {}
            for _, d in ipairs(list) do if d.why == g.why then items[#items + 1] = d end end
            if #items > 0 then
                n = n + 1
                local h = Line(n)
                h.data = nil
                h:SetHeight(HEAD_H)
                h:Place(y)
                h.text:SetFont(ns.FONT, 10, "")
                h.text:SetTextColor(unpack(ns.color.gold))
                h.text:SetText(g.label:upper())
                h.count:SetText(#items)
                h.count:Show()
                h.rule:Show()
                h.drop:Hide()
                h:Show()
                y = y + HEAD_H
                for _, d in ipairs(items) do
                    n = n + 1
                    local r = Line(n)
                    r.data = d
                    r:SetHeight(ROW_H)
                    r:Place(y)
                    r.text:SetFont(ns.FONT, 12, "")
                    r.text:SetTextColor(unpack(ns.color.text))
                    r.text:SetText(format("%s%s%s", d.level and format("|cff999999[%d]|r ", d.level) or "", d.title,
                        d.complete and "  |cff6fdc6f(ready to hand in)|r" or ""))
                    r.count:Hide()
                    r.rule:Hide()
                    r.drop:Show()
                    r:Show()
                    y = y + ROW_H
                end
            end
        end
        for i = n + 1, #lines do lines[i]:Hide() end
        view.empty:SetShown(#list == 0)
        if ns.ShellRefresh then ns.ShellRefresh() end
    end
    view:SetScript("OnShow", view.Refresh)
    return view
end

function ns.ShowGuideTidy()
    if ns.ShellOpen then ns.ShellOpen("guide", "tidy") end
end
