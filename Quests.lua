local ADDON_NAME, ns = ...

-- Completed quest history.
--
-- Every quest turned in is recorded with its title, zone, levels, rewards and
-- date. If the client can report the account's earlier completions (as Questie
-- uses), those are imported too and their titles looked up in the background.

local Safe = ns.Safe
local C_QuestLog = C_QuestLog

local RESOLVE_PER_TICK = 8
local CHANNEL = "PARTY"

local logInfo = {}      -- questID -> { title, level, zone } from the quest log
local turnInInfo = {}   -- questID -> { title, link } from the turn-in window
local resolveQueue = {} -- imported quest IDs still waiting for a title
local announceQueue = {}

local function Quests()
    return ns.cdb.quests
end

local function TitleFor(id)
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local title = Safe(C_QuestLog.GetTitleForQuestID, id)
        if title and title ~= "" then return title end
    end
end

---------------------------------------------------------------------------
-- Quest log: remember titles, levels and zone headers before quests leave it
---------------------------------------------------------------------------
ns.openQuests = {} -- the current quest log: { id, title, level, zone, complete }

-- a quest in your log with nothing to do but talk to someone ("Further
-- Instructions" and the like): the game never flags those complete
function ns.QuestHasNoObjectives(questID)
    if C_QuestLog and C_QuestLog.ReadyForTurnIn and Safe(C_QuestLog.ReadyForTurnIn, questID) == true then return true end
    local objectives = C_QuestLog and C_QuestLog.GetQuestObjectives and Safe(C_QuestLog.GetQuestObjectives, questID)
    if type(objectives) == "table" and #objectives > 0 then return false end
    local index = GetQuestLogIndexByID and Safe(GetQuestLogIndexByID, questID)
    if not (type(index) == "number" and index > 0 and GetNumQuestLeaderBoards) then return false end
    return (Safe(GetNumQuestLeaderBoards, index) or 0) == 0
end

local function IsQuestComplete(questID)
    if C_QuestLog and C_QuestLog.IsComplete and Safe(C_QuestLog.IsComplete, questID) == true then
        return true
    end
    return ns.QuestHasNoObjectives(questID)
end

-- Most quests the log can hold
function ns.MaxQuests()
    if C_QuestLog and C_QuestLog.GetMaxNumQuestsCanAccept then
        local max = Safe(C_QuestLog.GetMaxNumQuestsCanAccept)
        if type(max) == "number" and max > 0 then return max end
    end
    return MAX_QUESTLOG_QUESTS or 20
end

-- XP reward of a quest in the log (the retail-style API takes a quest ID)
local function QuestXP(questID)
    if not GetQuestLogRewardXP then return nil end
    local xp = Safe(GetQuestLogRewardXP, questID)
    if type(xp) == "number" and xp > 0 then return xp end
end

local CheckObjectives -- defined with the party announcements below

local function ScanQuestLog()
    local zone
    local open = {}
    local function Remember(questID, title, level, complete, xp)
        logInfo[questID] = { title = title, level = level, zone = zone }
        open[#open + 1] = { id = questID, title = title, level = level, zone = zone, complete = complete, xp = xp }
    end
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        local count = Safe(C_QuestLog.GetNumQuestLogEntries) or 0
        for i = 1, count do
            local info = Safe(C_QuestLog.GetInfo, i)
            if info then
                if info.isHeader then
                    zone = info.title
                elseif info.questID and info.questID > 0 and not info.isHidden then
                    Remember(info.questID, info.title, info.level, IsQuestComplete(info.questID), QuestXP(info.questID))
                end
            end
        end
    elseif GetNumQuestLogEntries and GetQuestLogTitle then
        local count = Safe(GetNumQuestLogEntries) or 0
        for i = 1, count do
            local title, level, _, isHeader, _, isComplete, _, questID = Safe(GetQuestLogTitle, i)
            if title then
                if isHeader then
                    zone = title
                elseif questID and questID > 0 then
                    Remember(questID, title, level, isComplete == 1 or isComplete == true or ns.QuestHasNoObjectives(questID))
                end
            end
        end
    end
    ns.openQuests = open
    pcall(CheckObjectives, open)
end

---------------------------------------------------------------------------
-- Party announcement
---------------------------------------------------------------------------
local function SendToParty(msg)
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if send then pcall(send, msg, CHANNEL) end
end

-- Posts to party chat when the setting is on and you're in a party (not a raid)
local function PostToParty(msg)
    if not ns.db.announceParty then return end
    if not IsInGroup() or IsInRaid() then return end
    -- chat from addons is touchier in combat on this client, so wait it out
    if InCombatLockdown() then
        table.insert(announceQueue, msg)
    else
        SendToParty(msg)
    end
end

local function Announce(id, record)
    local link = turnInInfo[id] and turnInInfo[id].link
    local msg = "[Hearthbound] Quest completed: " .. (link or ("[" .. record.title .. "]"))
    if ns.db.announceXP and record.xp and record.xp > 0 then
        msg = msg .. " (+" .. ns.Comma(record.xp) .. " XP)"
    end
    PostToParty(msg)
end

-- Objectives finishing: "Objective complete: Kobold Vermin slain: 10/10 - [Quest]",
-- or "Ready to hand in: [Quest]" when it was the last one
local objectiveState = {}  -- questID -> { [index] = finished }
local objectivePosted = {} -- "questID:index" -> true, once a session each

local function QuestLinkText(q)
    local link = GetQuestLink and Safe(GetQuestLink, q.id)
    return link or ("[" .. (q.title or "?") .. "]")
end

function CheckObjectives(open)
    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then return end
    local inLog = {}
    for _, q in ipairs(open) do
        inLog[q.id] = true
        local objectives = Safe(C_QuestLog.GetQuestObjectives, q.id)
        if type(objectives) == "table" and #objectives > 0 then
            local before = objectiveState[q.id]
            local now, newlyDone, allDone = {}, {}, true
            for i, o in ipairs(objectives) do
                now[i] = o.finished and true or false
                if not now[i] then allDone = false end
                -- only a change we watched happen: not quests just accepted or seen at login
                if now[i] and before and before[i] == false and not objectivePosted[q.id .. ":" .. i] then
                    objectivePosted[q.id .. ":" .. i] = true
                    newlyDone[#newlyDone + 1] = o
                end
            end
            objectiveState[q.id] = now
            if #newlyDone > 0 then
                if allDone then
                    PostToParty("[Hearthbound] Ready to hand in: " .. QuestLinkText(q))
                else
                    for _, o in ipairs(newlyDone) do
                        if type(o.text) == "string" and o.text ~= "" then
                            PostToParty("[Hearthbound] Objective complete: " .. o.text .. " - " .. QuestLinkText(q))
                        end
                    end
                end
            end
        end
    end
    for id in pairs(objectiveState) do
        if not inLog[id] then objectiveState[id] = nil end
    end
end

local function FlushAnnouncements()
    for _, msg in ipairs(announceQueue) do SendToParty(msg) end
    wipe(announceQueue)
end

---------------------------------------------------------------------------
-- Recording
---------------------------------------------------------------------------
local function OnQuestComplete()
    local id = Safe(GetQuestID)
    if not id or id == 0 then return end
    turnInInfo[id] = { title = Safe(GetTitleText), link = Safe(GetQuestLink, id) }
end

local function Number(v)
    if ns.IsSecret(v) then return nil end
    return tonumber(v)
end

local MarkDuplicates -- defined with the importing code below

local function OnTurnedIn(_, questID, xp, money)
    questID = Number(questID)
    if not questID then return end
    local info = logInfo[questID] or {}
    local fromWindow = turnInInfo[questID] or {}
    local record = {
        title = fromWindow.title or info.title or TitleFor(questID) or ("Quest #" .. questID),
        zone = info.zone or Safe(GetRealZoneText) or "",
        questLevel = info.level,
        level = UnitLevel("player"),
        xp = Number(xp) or 0,
        money = Number(money) or 0,
        time = time(),
    }
    if IsInGroup() and not IsInRaid() then
        record.party = true
        ns.cdb.partyQuests = (ns.cdb.partyQuests or 0) + 1
    end
    Quests()[questID] = record
    local session = ns.Session()
    session.quests = (session.quests or 0) + 1
    ns.AddXPSource("quest", record.xp)
    Announce(questID, record)
    turnInInfo[questID] = nil
    MarkDuplicates()
    if ns.RefreshQuestList then ns.RefreshQuestList() end
end

---------------------------------------------------------------------------
-- Importing earlier completions
---------------------------------------------------------------------------
local function ImportIDs(ids)
    local added = 0
    for _, id in ipairs(ids) do
        if type(id) == "number" and not Quests()[id] then
            Quests()[id] = { imported = true }
            resolveQueue[#resolveQueue + 1] = id
            added = added + 1
        end
    end
    if added > 0 then
        ns.Print(string.format("Imported %d earlier completed quests - looking up their names.", added))
    end
end

local function ImportFromServer()
    if C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs then
        local ids = Safe(C_QuestLog.GetAllCompletedQuestIDs)
        if ids then ImportIDs(ids) end
        return
    end
    if GetQuestsCompleted then
        local done = Safe(GetQuestsCompleted)
        if done and next(done) then
            local ids = {}
            for id in pairs(done) do ids[#ids + 1] = id end
            ImportIDs(ids)
        elseif QueryQuestsCompleted then
            pcall(QueryQuestsCompleted) -- older clients answer with QUEST_QUERY_COMPLETE
        end
    end
end

-- Imported quests only have IDs; fetch titles a few at a time. IDs that never
-- get a title are hidden tracking flags rather than real quests.
-- The server's completed list holds every version of some quests (one per
-- race or class, hidden copies), all with the same name. An imported quest
-- named like one you handed in - or like another imported one - is marked a
-- duplicate and left out of the list and the counts. Quests you handed in
-- while the addon watched are never marked.
local function NormalTitle(title) return (title or ""):lower():gsub("[^%w]", "") end

function MarkDuplicates()
    local keep = {} -- normalised title -> true when a quest by that name is already listed
    -- first the ones you handed in...
    for _, r in pairs(Quests()) do
        if r.title and not r.hidden and not r.imported then keep[NormalTitle(r.title)] = true end
    end
    -- ...then imported ones, lowest quest ID first so the choice is always the same
    local imported = {}
    for id, r in pairs(Quests()) do
        if r.imported and r.title and not r.hidden then imported[#imported + 1] = id end
    end
    table.sort(imported)
    local marked = 0
    for _, id in ipairs(imported) do
        local r = Quests()[id]
        local key = NormalTitle(r.title)
        if keep[key] then
            if not r.duplicate then marked = marked + 1 end
            r.duplicate = true
        else
            r.duplicate = nil
            keep[key] = true
        end
    end
    return marked
end

local function ResolveTitles()
    local done = 0
    while #resolveQueue > 0 and done < RESOLVE_PER_TICK do
        local id = table.remove(resolveQueue, 1)
        local record = Quests()[id]
        if record and not record.title then
            local title = TitleFor(id)
            if title then
                record.title = title
            elseif not record.requested and C_QuestLog and C_QuestLog.RequestLoadQuestByID then
                record.requested = true
                pcall(C_QuestLog.RequestLoadQuestByID, id) -- answered by QUEST_DATA_LOAD_RESULT
            else
                record.hidden = true
            end
        end
        done = done + 1
    end
    if done > 0 and #resolveQueue == 0 then
        MarkDuplicates() -- every name is known now
        if ns.RefreshQuestList then ns.RefreshQuestList() end
    end
end

local function OnQuestDataLoaded(_, questID, success)
    questID = Number(questID)
    local record = questID and Quests()[questID]
    if not record or record.title then return end
    local title = success and TitleFor(questID)
    if title then
        record.title = title
        if ns.RefreshQuestList then ns.RefreshQuestList() end
    else
        record.hidden = true
    end
end

---------------------------------------------------------------------------
-- Queries for the Quests tab
---------------------------------------------------------------------------
local SORTS = {
    recent = function(a, b)
        local ta, tb = a.r.time or 0, b.r.time or 0
        if ta ~= tb then return ta > tb end
        return a.r.title < b.r.title
    end,
    name = function(a, b) return a.r.title < b.r.title end,
    level = function(a, b)
        local la, lb = a.r.questLevel or 0, b.r.questLevel or 0
        if la ~= lb then return la > lb end
        return a.r.title < b.r.title
    end,
    zone = function(a, b)
        local za, zb = a.r.zone or "~", b.r.zone or "~"
        if za ~= zb then return za < zb end
        return a.r.title < b.r.title
    end,
}

-- filter: "all", "zone" or "session"; sort: a key of SORTS;
-- minLevel/maxLevel (optional) filter on the quest's level
function ns.QueryQuests(search, filter, sort, minLevel, maxLevel)
    local list, total = {}, 0
    local zone = Safe(GetRealZoneText)
    local sessionStart = ns.cdb.session and ns.cdb.session.start or 0
    search = strtrim(search or ""):lower()
    for id, r in pairs(Quests()) do
        if r.title and not r.hidden and not r.duplicate then
            total = total + 1
            local keep = true
            if filter == "zone" then
                keep = r.zone ~= nil and r.zone == zone
            elseif filter == "session" then
                keep = (r.time or 0) >= sessionStart
            end
            if keep and (minLevel or maxLevel) then
                local ql = r.questLevel
                keep = ql ~= nil and ql >= (minLevel or 0) and ql <= (maxLevel or 999)
            end
            if keep and search ~= "" then
                local haystack = (r.title .. " " .. (r.zone or "")):lower()
                keep = haystack:find(search, 1, true) ~= nil or tostring(id) == search
            end
            if keep then list[#list + 1] = { id = id, r = r } end
        end
    end
    table.sort(list, SORTS[sort] or SORTS.recent)
    return list, total
end

-- Totals for the Stats tab: count, xp, money, imported count and a zone -> count map
function ns.QuestStats()
    local stats = { count = 0, xp = 0, money = 0, imported = 0, zones = {} }
    for _, r in pairs(Quests()) do
        if r.title and not r.hidden and not r.duplicate then
            stats.count = stats.count + 1
            if r.imported then
                stats.imported = stats.imported + 1
            else
                stats.xp = stats.xp + (r.xp or 0)
                stats.money = stats.money + (r.money or 0)
                if r.zone and r.zone ~= "" then
                    stats.zones[r.zone] = (stats.zones[r.zone] or 0) + 1
                end
            end
        end
    end
    return stats
end

table.insert(ns.inits, function()
    ns.cdb.quests = ns.cdb.quests or {}
    local removed = MarkDuplicates()
    if removed > 0 then
        ns.Print(string.format("Tidied your completed quests: %d duplicate copies from the server's list are hidden.", removed))
    end
    -- carry on resolving any imported titles left over from last time
    for id, r in pairs(Quests()) do
        if r.imported and not r.title and not r.hidden then resolveQueue[#resolveQueue + 1] = id end
    end

    ns.On("QUEST_LOG_UPDATE", ScanQuestLog)
    ns.On("QUEST_COMPLETE", OnQuestComplete)
    ns.On("QUEST_TURNED_IN", OnTurnedIn)
    ns.On("QUEST_DATA_LOAD_RESULT", OnQuestDataLoaded)
    ns.On("QUEST_QUERY_COMPLETE", ImportFromServer)
    ns.On("PLAYER_REGEN_ENABLED", FlushAnnouncements)
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReload)
        if isInitialLogin or isReload then
            C_Timer.After(3, function()
                ScanQuestLog()
                ImportFromServer()
            end)
        end
    end)
    C_Timer.NewTicker(0.25, ResolveTitles)
end)
