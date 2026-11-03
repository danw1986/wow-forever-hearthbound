local ADDON_NAME, ns = ...

local UnitXP, UnitXPMax, GetXPExhaustion = UnitXP, UnitXPMax, GetXPExhaustion
local floor, ceil, format = math.floor, math.ceil, string.format
local Safe = ns.Safe

local KILL_SAMPLES = 20
local MIN_RECAP_SECONDS = 120
local DIM_DASH = "|cff999999--|r"

local SPOT_WINDOW = 600     -- "this spot" looks at the last 10 minutes
local SPOT_MIN_SECONDS = 120 -- before that it's too noisy to show
local SPOT_MARGIN = 0.1      -- how far off your average counts as better/worse

local lastXP, lastMax
local killPattern
local recentGains = {} -- { time, xp } within the spot window
local spotSince = time()

-- Turn "%s dies, you gain %d experience." into a Lua pattern (works for any client language)
local function BuildKillPattern()
    local fmt = COMBATLOG_XPGAIN_FIRSTPERSON
    if not fmt then return end
    fmt = fmt:gsub("%%%d%$", "%%")
    fmt = fmt:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
    fmt = fmt:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
    killPattern = fmt
end

---------------------------------------------------------------------------
-- Session
---------------------------------------------------------------------------
local function NewSession()
    ns.cdb.session = {
        start = time(), last = time(),
        startLevel = UnitLevel("player"), startMoney = GetMoney and GetMoney() or 0,
        xp = 0, questXP = 0, killXP = 0,
        kills = 0, quests = 0,
        income = 0, spent = 0,
    }
end

function ns.Session()
    return ns.cdb.session
end

function ns.ResetXPSession()
    NewSession()
    ns.cdb.recentKills = {}
    lastXP, lastMax = UnitXP("player"), UnitXPMax("player")
    ns.UpdatePanel()
    ns.Print("XP session reset.")
end

-- Per-level XP split between quests, kills and everything else
local function LevelXP(level)
    local t = ns.cdb.levelXP[level]
    if not t then
        t = { total = 0, quest = 0, kill = 0 }
        ns.cdb.levelXP[level] = t
    end
    return t
end
ns.LevelXP = LevelXP

-- kind: "quest" or "kill"
function ns.AddXPSource(kind, amount)
    if not amount or amount <= 0 then return end
    local session = ns.cdb.session
    local lvl = LevelXP(UnitLevel("player"))
    if kind == "quest" then
        session.questXP = (session.questXP or 0) + amount
        lvl.quest = lvl.quest + amount
    elseif kind == "kill" then
        session.killXP = (session.killXP or 0) + amount
        lvl.kill = lvl.kill + amount
    end
end

local function OnXPUpdate()
    local cur, max = UnitXP("player"), UnitXPMax("player")
    if lastXP then
        local gained
        if cur >= lastXP then
            gained = cur - lastXP
        else
            gained = (lastMax - lastXP) + cur -- levelled up
        end
        if gained > 0 then
            ns.cdb.session.xp = ns.cdb.session.xp + gained
            ns.cdb.totalXP = (ns.cdb.totalXP or 0) + gained
            recentGains[#recentGains + 1] = { time(), gained }
            local lvl = LevelXP(UnitLevel("player"))
            lvl.total = lvl.total + gained
        end
    end
    lastXP, lastMax = cur, max
    ns.UpdatePanel()
end

---------------------------------------------------------------------------
-- Kills
---------------------------------------------------------------------------
local function RecordMob(name, amount)
    local zone = Safe(GetRealZoneText) or "?"
    local mobs = ns.cdb.mobs[zone]
    if not mobs then
        mobs = {}
        ns.cdb.mobs[zone] = mobs
    end
    local m = mobs[name] or { kills = 0, xp = 0 }
    m.kills = m.kills + 1
    m.xp = m.xp + amount
    m.lastXP = amount
    m.lastLevel = UnitLevel("player")
    m.last = time()
    mobs[name] = m
end

local function OnXPMessage(_, msg)
    if not killPattern or not msg or ns.IsSecret(msg) then return end
    local ok, mob, amount = pcall(string.match, msg, killPattern)
    amount = ok and tonumber(amount)
    if not amount then return end
    local kills = ns.cdb.recentKills
    table.insert(kills, amount)
    while #kills > KILL_SAMPLES do table.remove(kills, 1) end
    ns.cdb.session.kills = ns.cdb.session.kills + 1
    ns.cdb.totalKills = (ns.cdb.totalKills or 0) + 1
    ns.AddXPSource("kill", amount)
    if mob then
        RecordMob(mob, amount)
        if ns.RecordKillType then pcall(ns.RecordKillType, mob) end
    end
end

-- XP per second over the last 10 minutes (or since login if shorter), or nil
local function SpotRate()
    local now = time()
    while recentGains[1] and now - recentGains[1][1] > SPOT_WINDOW do
        table.remove(recentGains, 1)
    end
    local span = math.min(SPOT_WINDOW, now - spotSince)
    if span < SPOT_MIN_SECONDS then return nil end
    local sum = 0
    for _, g in ipairs(recentGains) do sum = sum + g[2] end
    return sum / span
end

local function AverageKillXP()
    local kills = ns.cdb.recentKills
    if #kills == 0 then return nil end
    local sum = 0
    for _, v in ipairs(kills) do sum = sum + v end
    return sum / #kills
end

---------------------------------------------------------------------------
-- Session summary
---------------------------------------------------------------------------
-- Returns the summary as a list of chat lines
function ns.SessionSummary(s)
    local played = math.max(0, (s.last or time()) - s.start)
    local endLevel = s.endLevel or UnitLevel("player")
    local lines = {}
    local levels = endLevel > (s.startLevel or endLevel)
        and format("%d > %d (+%d)", s.startLevel, endLevel, endLevel - s.startLevel)
        or format("%d", endLevel)
    lines[#lines + 1] = format("Played %s  |  Level %s  |  +%s XP", ns.Duration(played), levels, ns.Short(s.xp or 0))
    lines[#lines + 1] = format("%d quests, %d kills, %d deaths  |  Gold %s", s.quests or 0, s.kills or 0,
        s.deaths or 0, ns.Money((s.income or 0) - (s.spent or 0), true))
    if (s.xp or 0) > 0 then
        local q, k = s.questXP or 0, s.killXP or 0
        lines[#lines + 1] = format("XP from quests %d%%, kills %d%%, other %d%%",
            floor(q / s.xp * 100 + 0.5), floor(k / s.xp * 100 + 0.5),
            math.max(0, 100 - floor(q / s.xp * 100 + 0.5) - floor(k / s.xp * 100 + 0.5)))
    end
    local best, bestLevel
    if ns.BestLevelSince then best, bestLevel = ns.BestLevelSince(s.start) end
    if best then
        lines[#lines + 1] = format("Fastest level this session: %d in %s", bestLevel, ns.Duration(best))
    end
    return lines
end

function ns.PrintSessionSummary(s, title)
    s = s or ns.cdb.session
    ns.Print("|cffffd200" .. (title or "This session") .. ":|r")
    for _, line in ipairs(ns.SessionSummary(s)) do
        DEFAULT_CHAT_FRAME:AddMessage("   " .. line)
    end
end

---------------------------------------------------------------------------
-- Panel section
---------------------------------------------------------------------------
ns.AddSection(10, function(add, level)
    local maxLevel = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    if level >= maxLevel then
        add.note("Maximum level reached!", ns.color.gold)
        return
    end

    local cur, max = UnitXP("player"), UnitXPMax("player")
    if not max or max == 0 then max = 1 end
    local remaining = max - cur
    local rested = GetXPExhaustion() or 0

    local session = ns.cdb.session
    local elapsed = math.max(1, time() - session.start)
    local perSecond = session.xp / elapsed

    if session.xp > 0 and elapsed >= 30 then
        add.row("XP / hour", ns.Short(perSecond * 3600))
        add.row("Time to level", ns.Duration(remaining / perSecond))
    else
        add.row("XP / hour", DIM_DASH)
        add.row("Time to level", DIM_DASH)
    end

    -- is the current spot better or worse than your average?
    local spot = SpotRate()
    if spot then
        local color = "ffffff"
        if perSecond > 0 and spot > perSecond * (1 + SPOT_MARGIN) then
            color = "6fdc6f"
        elseif perSecond > 0 and spot < perSecond * (1 - SPOT_MARGIN) then
            color = "ff8040"
        end
        add.row("Last 10 min", format("|cff%s%s/hr|r", color, ns.Short(spot * 3600)))
    end

    local avg = AverageKillXP()
    if avg and avg > 0 then
        add.row("Kills to level", format("%d  |cff999999(%s each)|r", ceil(remaining / avg), ns.Short(avg)))
    else
        add.row("Kills to level", DIM_DASH)
    end

    if rested > 0 then
        add.row("Rested", format("|cff6f9cff%s|r  |cff999999(%d%%)|r", ns.Short(rested), floor(rested / max * 100)))
        if ns.db.restedTip then
            -- rested doubles kill XP; each kill uses up its base XP from the pool,
            -- and the kill messages we average include the bonus, so halve them
            local tip = "|cff6f9cffRested: mobs give double XP - grind between quests.|r"
            if avg and avg > 0 then
                tip = tip .. format(" |cff999999(~%d kills of bonus left)|r", ceil(rested / (avg / 2)))
            end
            add.note(tip)
        end
    else
        add.row("Rested", "|cff999999none|r")
    end

    add.row("Session", format("+%s  |cff999999in %s|r", ns.Short(session.xp), ns.Duration(elapsed)))
end)

table.insert(ns.inits, function()
    BuildKillPattern()
    ns.cdb.recentKills = ns.cdb.recentKills or {}
    ns.cdb.levelXP = ns.cdb.levelXP or {}
    ns.cdb.mobs = ns.cdb.mobs or {}
    if not ns.cdb.session then NewSession() end

    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin)
        -- new session each login (with a recap of the last one); a /reload keeps it
        if isInitialLogin then
            local old = ns.cdb.session
            if old and old.start and (old.last or old.start) - old.start >= MIN_RECAP_SECONDS then
                ns.cdb.lastSession = old
                if not ns.db.welcomeBack then
                    C_Timer.After(4, function() ns.PrintSessionSummary(old, "Last session") end)
                end
            end
            NewSession()
        end
        lastXP, lastMax = UnitXP("player"), UnitXPMax("player")
    end)
    ns.On("PLAYER_XP_UPDATE", OnXPUpdate)
    ns.On("CHAT_MSG_COMBAT_XP_GAIN", OnXPMessage)

    -- keep "last seen" and the session's level current for the recap
    C_Timer.NewTicker(5, function()
        local s = ns.cdb.session
        s.last = time()
        s.endLevel = UnitLevel("player")
    end)
end)
