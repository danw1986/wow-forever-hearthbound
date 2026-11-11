local ADDON_NAME, ns = ...

-- Mischief: the "help" you give your party and guildmates, counted for the
-- Mischief achievements (Achievements.lua). From your own casts (the game says
-- who each one is aimed at as you cast it), rude emotes and duels you win.
--   ns.cdb.mischief         kind -> how many times
--   ns.cdb.mischiefVictims  kind -> who it was done to last (named in the post)

local Safe = ns.Safe

-- spell name (any rank) -> what it counts as
local TRICKS = {
    ["Blessing of Protection"] = "bop",
    ["Innervate"] = "innervate",
    ["Arcane Intellect"] = "brains",
    ["Levitate"] = "levitate",
    ["Intimidating Shout"] = "fear",
    ["Psychic Scream"] = "fear",
    ["Howl of Terror"] = "fear",
    ["Feign Death"] = "bail",
    ["Vanish"] = "bail",
}
local NO_MANA = { WARRIOR = true, ROGUE = true }
local RUDE = { SLAP = true, RUDE = true, SPIT = true, CHICKEN = true, FART = true }
local PENDING_SECONDS = 10 -- a cast's target, kept from when you start it until it goes off

local function Count(kind, victim)
    ns.cdb.mischief = ns.cdb.mischief or {}
    ns.cdb.mischief[kind] = (ns.cdb.mischief[kind] or 0) + 1
    if victim then
        ns.cdb.mischiefVictims = ns.cdb.mischiefVictims or {}
        ns.cdb.mischiefVictims[kind] = victim
    end
    if ns.AchievementsCheckSoon then ns.AchievementsCheckSoon() end
end

---------------------------------------------------------------------------
-- Who's who
---------------------------------------------------------------------------
local function Plain(s) return type(s) == "string" and not ns.IsSecret(s) and s ~= "" and s or nil end
-- "Name-Realm" -> "name"; Forever characters have two names, so the first word counts too
local function Key(name)
    name = Plain(name)
    return name and (name:match("^([^%-]+)") or name):lower() or nil
end
local function SameName(a, b)
    a, b = Key(a), Key(b)
    return a ~= nil and b ~= nil and (a == b or a:match("^%S+") == b:match("^%S+"))
end

local function Name(unit) return Plain((Safe(UnitName, unit))) end

local function GroupUnits()
    local out = {}
    if IsInRaid and Safe(IsInRaid) then
        for k = 1, (Safe(GetNumGroupMembers) or 0) do out[#out + 1] = "raid" .. k end
    else
        for k = 1, 4 do out[#out + 1] = "party" .. k end
    end
    return out
end

local function IsMe(unit) return Safe(UnitIsUnit, unit, "player") == true end

-- a party (or raid) member other than you, by name
local function GroupUnitNamed(name)
    if not Plain(name) then return nil end
    for _, u in ipairs(GroupUnits()) do
        if Safe(UnitExists, u) and not IsMe(u) and SameName(Name(u), name) then return u end
    end
end

local function InMyGroup(unit)
    return not IsMe(unit) and (Safe(UnitInParty, unit) or Safe(UnitInRaid, unit)) and true or false
end

local function InMyGuild(unit) return UnitIsInMyGuild and Safe(UnitIsInMyGuild, unit) and true or false end

-- someone in your guild, by name: your target (a duel opponent usually is), else the roster
local function GuildmateNamed(name)
    if not (IsInGuild and Safe(IsInGuild)) then return false end
    if Safe(UnitExists, "target") and SameName(Name("target"), name) then return InMyGuild("target") end
    for i = 1, (Safe(GetNumGuildMembers) or 0) do
        if SameName((Safe(GetGuildRosterInfo, i)), name) then return true end
    end
    return false
end

local function Class(unit)
    local _, class = Safe(UnitClass, unit)
    return class
end

local function PartyFighting()
    for _, u in ipairs(GroupUnits()) do
        if Safe(UnitExists, u) and not IsMe(u) and Safe(UnitAffectingCombat, u) then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- Your casts
---------------------------------------------------------------------------
local pending -- the cast you've just started: { target name, guid, at, fighting }

local function SpellName(id)
    local name = C_Spell and C_Spell.GetSpellName and Plain((Safe(C_Spell.GetSpellName, id)))
    return name or (GetSpellInfo and Plain((Safe(GetSpellInfo, id)))) or nil
end

local function OnSent(_, unit, target, castGUID)
    if unit ~= "player" then return end
    pending = { target = Plain(target), guid = not ns.IsSecret(castGUID) and castGUID or nil, at = GetTime(),
                fighting = Safe(UnitAffectingCombat, "player") and true or false }
end

-- who the cast you've just finished was aimed at: a party member's unit
local function Victim(castGUID)
    local p = pending
    if p and GetTime() - p.at <= PENDING_SECONDS and (not p.guid or ns.IsSecret(castGUID) or p.guid == castGUID) then
        local u = p.target and GroupUnitNamed(p.target)
        if u then return u, p end
    end
    -- cast on your target or the unit under the mouse, without a name to go on
    for _, u in ipairs({ "target", "mouseover" }) do
        if Safe(UnitExists, u) and InMyGroup(u) then return u, p end
    end
    return nil, p
end

local function OnSucceeded(_, unit, castGUID, spellID)
    if unit ~= "player" or ns.IsSecret(spellID) then return end
    local kind = TRICKS[SpellName(spellID) or ""]
    if not (kind and IsInGroup and Safe(IsInGroup)) then return end
    if kind == "fear" then
        local inInstance, where = IsInInstance()
        if inInstance and (where == "party" or where == "raid") and Safe(UnitAffectingCombat, "player") then Count("fear") end
        return
    end
    if kind == "bail" then
        -- off you go, with the others still fighting
        if (pending and pending.fighting or Safe(UnitAffectingCombat, "player")) and PartyFighting() then Count("bail") end
        return
    end
    local victim, p = Victim(castGUID)
    if not victim then return end
    local name = Name(victim)
    if kind == "bop" then
        Count("bop", name)
        if Class(victim) == "WARRIOR" and (Safe(UnitAffectingCombat, victim) or (p and p.fighting)) then Count("bopTank", name) end
    elseif kind == "innervate" or kind == "brains" then
        if NO_MANA[Class(victim) or ""] then Count(kind, name) end
    elseif kind == "levitate" then
        Count("levitate", name)
    end
end

---------------------------------------------------------------------------
-- Rude emotes at a guildmate or party member
---------------------------------------------------------------------------
local lastEmote = { at = 0 }
local function OnEmote(token, who)
    if type(token) ~= "string" or not RUDE[token:upper()] then return end
    -- the game's emote functions can call each other: count each emote once
    if lastEmote.token == token and GetTime() - lastEmote.at < 0.5 then return end
    lastEmote.token, lastEmote.at = token, GetTime()
    local u = "target"
    who = Plain(who)
    if who then
        if Safe(UnitExists, who) then
            u = who
        else
            u = GroupUnitNamed(who) or (SameName(Name("target"), who) and "target") or nil
        end
    end
    if not (u and Safe(UnitExists, u) and Safe(UnitIsPlayer, u) and not IsMe(u)) then return end
    if InMyGuild(u) or InMyGroup(u) then Count("rude", Name(u)) end
end

---------------------------------------------------------------------------
-- Duels you win against a guildmate or party member
---------------------------------------------------------------------------
-- "%1$s has defeated %2$s in a duel" -> a pattern, and which name each capture is
local function DuelPattern(fmt)
    if type(fmt) ~= "string" then return nil end
    local order = {}
    local s = fmt:gsub("%%(%d)%$s", function(n) order[#order + 1] = tonumber(n) return "\1" end)
    s = s:gsub("%%s", function() order[#order + 1] = #order + 1 return "\1" end)
    s = s:gsub("[%%%(%)%.%+%-%*%?%[%]%^%$]", "%%%0"):gsub("\1", "(.+)")
    return "^" .. s .. "$", order
end

local duelPatterns
local function OnSystem(_, msg)
    msg = Plain(msg)
    if not msg then return end
    if not duelPatterns then
        duelPatterns = {}
        for _, g in ipairs({ DUEL_WINNER_KNOCKOUT, DUEL_WINNER_RETREAT }) do
            local p, order = DuelPattern(g)
            if p then duelPatterns[#duelPatterns + 1] = { p, order } end
        end
    end
    for _, d in ipairs(duelPatterns) do
        local caps = { msg:match(d[1]) }
        if #caps >= 2 then
            local names = {}
            for i, n in ipairs(d[2]) do names[n] = caps[i] end
            local winner, loser = names[1], names[2]
            local _, myName = ns.FullName()
            if SameName(winner, myName) and (GroupUnitNamed(loser) or GuildmateNamed(loser)) then
                Count("duel", (Plain(loser) or "?"):match("^([^%-]+)"))
            end
            return
        end
    end
end

table.insert(ns.inits, function()
    ns.On("UNIT_SPELLCAST_SENT", OnSent)
    ns.On("UNIT_SPELLCAST_SUCCEEDED", OnSucceeded)
    ns.On("CHAT_MSG_SYSTEM", OnSystem)
    -- watch the game's emote functions (doesn't change them)
    if DoEmote then hooksecurefunc("DoEmote", OnEmote) end
    if C_ChatInfo and C_ChatInfo.PerformEmote then hooksecurefunc(C_ChatInfo, "PerformEmote", OnEmote) end
end)
