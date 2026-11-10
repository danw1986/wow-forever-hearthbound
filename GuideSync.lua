local ADDON_NAME, ns = ...

-- Party guide sync. Party members who have Hearthbound tell each other which
-- guide step they're on. The party leader can bring everyone to the leader's
-- step: the Sync button on the guide, its ... menu, or /hb guide sync, and an
-- offer when someone joins on a different step. Each member is asked first,
-- unless they've chosen to follow the leader without asking. After that each
-- guide goes on by itself, from that player's own quests.
--
-- Addon messages (prefix "Hearthbound"), fields joined by "^", the second
-- always the sender's id for this session (so we can ignore our own):
--   HI^id^version^sig^after^ask   I have the guide, and this is where I am
--                                 (ask = 1: tell me where you are too)
--   AT^id^sig^after               my step has changed
--   SYNC^id^sig^i^after^t^q       (the leader) come to this step
--   ACK^id^to^result              to the leader who asked: ok, no or missing
--   BYE^id                        I've stopped sharing
-- sig is the route's signature (the same GuideData), i the step's number in
-- the route and after the next plain route step from it (see ns.GuideSyncPoint).

local format = string.format
local PREFIX = "Hearthbound"
local SEP = "^"
local APART = 3        -- route steps apart before the leader is offered a sync
local ASK_SECONDS = 60 -- how long a member's question stays up

local myId = tostring(math.random(100000, 999999)) .. (tostring({}):match("(%x+)$") or "")
local peers = {}   -- sender -> { id, name, version, sig, after, seen }
local offered = {} -- sender -> true: the leader has had a sync offer for them, this group
local sharing = false

local function Safe(fn, ...) return ns.Safe(fn, ...) end
local function On() return ns.db and ns.db.guideSync ~= false end
local function Refresh() if ns.GuideRefresh then ns.GuideRefresh() end end

local function InGroup() return IsInGroup and Safe(IsInGroup) and true or false end

local function Channel()
    local home, instance = LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE
    if IsInRaid and Safe(IsInRaid, home) then return "RAID" end
    if IsInGroup and Safe(IsInGroup, home) then return "PARTY" end
    if instance and IsInGroup and Safe(IsInGroup, instance) then return "INSTANCE_CHAT" end
end

local function Send(cmd, ...)
    local channel = Channel()
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    if not (channel and send) then return false end
    local parts = { cmd, myId }
    for k = 1, select("#", ...) do
        local v = select(k, ...)
        parts[#parts + 1] = (tostring(v == nil and "" or v):gsub("[%^|\n]", ""))
    end
    return pcall(send, PREFIX, table.concat(parts, SEP):sub(1, 250), channel)
end

local function Split(text)
    local f = {}
    for part in (text .. SEP):gmatch("(.-)%^") do f[#f + 1] = part end
    return f
end

---------------------------------------------------------------------------
-- Who's who
---------------------------------------------------------------------------
-- "Name-Realm" -> "Name"
local function Short(sender) return tostring(sender or "?"):match("^([^%-]+)") or "?" end
local function Lower(s) return type(s) == "string" and not ns.IsSecret(s) and s:lower() or nil end
local function FirstWord(s) return s and s:match("^(%S+)") end

-- is this unit the player who sent a message? (Forever characters have a
-- first and a last name, so compare the first names too)
local function UnitIs(unit, sender)
    local want = Lower(Short(sender))
    if not want then return false end
    local names = { (Safe(UnitName, unit)) }
    if GetUnitName then names[#names + 1] = (Safe(GetUnitName, unit, true)) end
    if UnitNameUnmodified then
        local first, surname = Safe(UnitNameUnmodified, unit)
        if type(first) == "string" and type(surname) == "string" then names[#names + 1] = first .. " " .. surname end
    end
    for _, n in ipairs(names) do
        local have = Lower(Short(n))
        if have and (have == want or FirstWord(have) == FirstWord(want)) then return true end
    end
    return false
end

local function GroupUnits()
    local out = {}
    if IsInRaid and Safe(IsInRaid) then
        for k = 1, (Safe(GetNumGroupMembers) or 0) do out[#out + 1] = "raid" .. k end
    else
        for k = 1, 4 do out[#out + 1] = "party" .. k end
    end
    return out
end

local function SenderLeads(sender)
    for _, unit in ipairs(GroupUnits()) do
        if Safe(UnitExists, unit) and Safe(UnitIsGroupLeader, unit) and UnitIs(unit, sender) then return true end
    end
    return false
end

local function ILead() return InGroup() and Safe(UnitIsGroupLeader, "player") and true or false end

local function Here() return ns.GuideSyncPoint and ns.GuideSyncPoint() end

-- how many route steps p is ahead of me (negative: behind); nil when that
-- can't be told (a different version of the route, or not heard yet)
local function Apart(p, me)
    if not (p and me and p.sig and p.sig == me.sig and p.after and me.after) then return nil end
    return p.after - me.after
end

local function Where(p, me)
    if p.sig and me and p.sig ~= me.sig then
        return format("%s: a different version of the route (Hearthbound %s)", p.name, p.version or "?"), 1, 0.5, 0.3
    end
    local d = Apart(p, me)
    if not d then return p.name .. ": step not known yet", 0.7, 0.7, 0.7 end
    if math.abs(d) < APART then return p.name .. ": with you", 0.4, 0.9, 0.4 end
    return format("%s: about %d steps %s", p.name, math.abs(d), d < 0 and "behind" or "ahead"), 1, 0.82, 0
end

local function SortedPeers()
    local out = {}
    for _, p in pairs(peers) do out[#out + 1] = p end
    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end
-- party members with the guide: { name, version, sig, after }, by name
ns.GuideSyncPeers = SortedPeers

---------------------------------------------------------------------------
-- The leader's side
---------------------------------------------------------------------------
-- nil: no Sync button (sync off, not leading, nobody else with the guide);
-- "apart": someone is a few steps away; "together": everyone's with you
function ns.GuideSyncCan()
    if not (On() and ILead() and next(peers)) then return nil end
    local me = Here()
    if not me then return nil end
    for _, p in pairs(peers) do
        local d = Apart(p, me)
        if d and math.abs(d) >= APART then return "apart" end
    end
    return "together"
end

function ns.GuideSyncTooltip(owner)
    GameTooltip:SetOwner(owner, "ANCHOR_TOP")
    GameTooltip:SetText("Sync the party", 1, 1, 1)
    GameTooltip:AddLine("Bring everyone in the party who has the guide to the step you're on. They're asked first.", 0.8, 0.8, 0.8, true)
    local me = Here()
    for _, p in ipairs(SortedPeers()) do GameTooltip:AddLine(Where(p, me)) end
    GameTooltip:Show()
end

function ns.GuideSyncParty()
    if not On() then return ns.Print("Party guide sync is off (Settings > Levelling guide > Party).") end
    if not InGroup() then return ns.Print("Guide sync: you're not in a party.") end
    if not ILead() then return ns.Print("Guide sync: only the party leader can bring the party to their step.") end
    local p = ns.GuideSyncPoint and ns.GuideSyncPoint(true)
    if not p then return ns.Print("Guide sync: the guide isn't ready yet.") end
    local n = 0
    for k in pairs(peers) do
        n = n + 1
        offered[k] = true -- asked now: no offer about them later
    end
    if n == 0 then
        return ns.Print("Guide sync: nobody else in the party has the Hearthbound guide (or they haven't answered yet).")
    end
    Send("SYNC", p.sig, p.i, p.after, p.t, p.q)
    ns.Print(format("Guide sync: asking %d party member%s to come to your step - |cffffd200%s|r",
        n, n == 1 and "" or "s", p.title or ""))
end

-- someone has joined (or drifted) a few steps away: offer the leader a sync,
-- once for each of them while you're in this group
local offerQueued
local function QueueOffer()
    if offerQueued then return end
    offerQueued = true
    C_Timer.After(3, function()
        offerQueued = nil
        if not (On() and ILead()) then return end
        local me = Here()
        if not me then return end
        local names = {}
        for k, p in pairs(peers) do
            local d = Apart(p, me)
            if not offered[k] and d and math.abs(d) >= APART then
                offered[k] = true
                names[#names + 1] = p.name
            end
        end
        if #names == 0 then return end
        table.sort(names)
        StaticPopup_Show("HEARTHBOUND_GUIDE_SYNC_OFFER", format(
            "%s %s the Hearthbound guide, on a different step from yours.\n\nBring the party to your step?\n|cffffd200%s|r",
            table.concat(names, ", "), #names == 1 and "has" or "have", me.title or ""))
    end)
end

local function OnAnswer(sender, f)
    if f[3] ~= myId then return end -- someone else's sync
    local name, result = Short(sender), f[4]
    local p = peers[sender]
    if result == "ok" then
        local me = Here()
        if p and me then p.sig, p.after = me.sig, me.after end
        ns.Print(format("Guide sync: %s is on your step.", name))
    elseif result == "no" then
        ns.Print(format("Guide sync: %s is staying where they are.", name))
    elseif result == "missing" then
        ns.Print(format("Guide sync: %s's guide doesn't have this step. One of you may need to update Hearthbound (theirs is %s).",
            name, p and p.version or "?"))
    end
    Refresh()
end

---------------------------------------------------------------------------
-- A member's side
---------------------------------------------------------------------------
local function Answer(to, result) Send("ACK", to, result) end

local function Apply(a)
    ns.GuideSyncGo(a.j)
    Answer(a.id, "ok")
    ns.Print(format("Guide: on %s's step now - |cffffd200%s|r", a.name, ns.GuideSyncTitle(a.j) or ""))
end

-- the popup's answer (a: the sync it asked about)
function ns.GuideSyncReply(a, yes)
    if type(a) ~= "table" then return end
    if yes then Apply(a) else Answer(a.id, "no") end
end

local function OnSync(sender, f)
    local point = { sig = f[3], i = tonumber(f[4]), after = tonumber(f[5]), t = f[6] ~= "" and f[6] or nil, q = tonumber(f[7]) }
    local name = Short(sender)
    local j = ns.GuideSyncFind and ns.GuideSyncFind(point)
    if not j then
        Answer(f[2], "missing")
        return ns.Print(format("Guide: %s wanted to sync guides, but your guide doesn't have their step. One of you may need to update Hearthbound.", name))
    end
    local _, at = ns.GuideCurrent()
    if at == j then return Answer(f[2], "ok") end
    local a = { id = f[2], name = name, j = j }
    if ns.db.guideSyncAuto and SenderLeads(sender) then return Apply(a) end
    StaticPopup_Show("HEARTHBOUND_GUIDE_SYNC", format("%s wants to bring your guide to their step:\n\n|cffffd200%s|r",
        name .. (SenderLeads(sender) and " (party leader)" or ""), ns.GuideSyncTitle(j) or ""), nil, a)
end

---------------------------------------------------------------------------
-- Keeping track of each other
---------------------------------------------------------------------------
local function Hello(ask)
    local p = Here()
    if not (p and On()) then return end
    sharing = true
    Send("HI", ns.version, p.sig, p.after, ask and 1 or 0)
end

local function OnMessage(_, prefix, text, _, sender)
    if prefix ~= PREFIX or type(text) ~= "string" or type(sender) ~= "string" or not On() then return end
    if ns.IsSecret(text) or ns.IsSecret(sender) then return end
    local f = Split(text)
    local cmd, id = f[1], f[2]
    if not id or id == "" or id == myId then return end -- our own, echoed back
    if cmd == "HI" then
        local p = peers[sender] or {}
        peers[sender] = p
        p.id, p.name, p.version, p.sig, p.after, p.seen = id, Short(sender), f[3], f[4], tonumber(f[5]), GetTime()
        if f[6] == "1" then Hello(false) end
        QueueOffer()
        Refresh()
    elseif cmd == "AT" then
        local p = peers[sender]
        if not p then return Hello(true) end -- we've missed their hello: ask again
        p.sig, p.after, p.seen = f[3], tonumber(f[4]), GetTime()
        QueueOffer()
        Refresh()
    elseif cmd == "SYNC" then
        OnSync(sender, f)
    elseif cmd == "ACK" then
        OnAnswer(sender, f)
    elseif cmd == "BYE" then
        peers[sender] = nil
        Refresh()
    end
end

-- your step changed: tell the others (a few seconds later, once it's settled)
local movedQueued
function ns.GuideSyncMoved()
    if movedQueued or not (On() and next(peers)) then return end
    movedQueued = true
    C_Timer.After(3, function()
        movedQueued = nil
        local p = Here()
        if p and next(peers) then Send("AT", p.sig, p.after) end
        Refresh()
    end)
end

-- the group changed: everyone says where they are again, and whoever doesn't
-- answer has gone
local rosterQueued
local function Roster()
    if not InGroup() then
        wipe(peers)
        wipe(offered)
        Refresh()
        return
    end
    if rosterQueued then return end
    rosterQueued = true
    C_Timer.After(2, function()
        rosterQueued = nil
        if not (On() and InGroup()) then return end
        local asked = GetTime()
        Hello(true)
        C_Timer.After(5, function()
            for k, p in pairs(peers) do
                if (p.seen or 0) < asked then peers[k] = nil end
            end
            Refresh()
        end)
    end)
end

table.insert(ns.inits, function()
    local register = (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) or RegisterAddonMessagePrefix
    if register then pcall(register, PREFIX) end

    StaticPopupDialogs["HEARTHBOUND_GUIDE_SYNC"] = {
        text = "%s",
        button1 = "Go there",
        button2 = "Stay",
        OnAccept = function(_, data) ns.GuideSyncReply(data, true) end,
        OnCancel = function(_, data, reason)
            if reason ~= "override" then ns.GuideSyncReply(data, false) end
        end,
        timeout = ASK_SECONDS,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs["HEARTHBOUND_GUIDE_SYNC_OFFER"] = {
        text = "%s",
        button1 = "Sync",
        button2 = "Not now",
        OnAccept = function() ns.GuideSyncParty() end,
        timeout = ASK_SECONDS,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    ns.On("CHAT_MSG_ADDON", OnMessage)
    ns.On("GROUP_ROSTER_UPDATE", Roster)
    ns.On("PARTY_LEADER_CHANGED", function() QueueOffer() Refresh() end)
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReload)
        if not (isInitialLogin or isReload) then return end
        -- once the guide has loaded its route
        C_Timer.After(8, function() if InGroup() then Hello(true) end end)
    end)

    -- sync switched off: tell the party, and forget them; back on: say hello
    table.insert(ns.refreshers, function()
        if sharing and not On() then
            Send("BYE")
            sharing = false
            wipe(peers)
            wipe(offered)
        elseif not sharing and On() and InGroup() then
            Hello(true)
        end
    end)
end)
