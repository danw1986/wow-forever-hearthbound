local ADDON_NAME, ns = ...

-- Achievements: every milestone plus a wider set of goals (questing,
-- dungeons, survival, gold, fun, warrior), with points, bronze/silver/gold
-- tiers and a few hidden ones. Unlocking goes through ns.Milestone, so each
-- one gets the pop-up, the Journey log and (if switched on) the guild post.
--
-- Most are worked out from what the addon already records, so your history
-- counts. The first time this runs, everything you already qualify for is
-- unlocked quietly with one summary line instead of a flood of pop-ups.

local format = string.format
local Safe = ns.Safe

local VERSION = 2            -- bump to re-run the quiet catch-up for new achievements
local CHECK_SECONDS = 10
local HEAVY_SECONDS = 60     -- zone, chain and dungeon checks are slower: at most this often
local CATCH_UP_SECONDS = 45  -- the quiet catch-up window after the first login
local POINTS = { bronze = 10, silver = 25, gold = 50 }
local TIER_RGB = { bronze = "205:127:50", silver = "192:192:192", gold = "255:215:0" }
local GREEN, GOLD, GREY = { 0.30, 0.75, 0.30 }, { 0.85, 0.68, 0.20 }, { 0.35, 0.35, 0.38 }
local MOUNT_GOLD = 100

local ICON = {
    level = "Interface\\Icons\\Spell_Holy_SurgeOfLight",
    quest = "Interface\\Icons\\INV_Misc_Book_08",
    kill = "Interface\\Icons\\Ability_Warrior_Rampage",
    xp = "Interface\\Icons\\INV_Misc_Gem_Pearl_04",
    punch = "Interface\\Icons\\Ability_Warrior_Challange",
    blitz = "Interface\\Icons\\Spell_Nature_TimeStop",
    map = "Interface\\Icons\\INV_Misc_Map_01",
    zone = "Interface\\Icons\\INV_Misc_Map02",
    chain = "Interface\\Icons\\INV_Misc_Note_02",
    party = "Interface\\Icons\\INV_Misc_GroupNeedMore",
    dungeon = "Interface\\Icons\\INV_Misc_Key_14",
    forever = "Interface\\Icons\\INV_Misc_Key_13",
    scholar = "Interface\\Icons\\INV_Misc_Book_11",
    shield = "Interface\\Icons\\Spell_Holy_DivineProtection",
    streak = "Interface\\Icons\\Spell_Holy_InnerFire",
    clock = "Interface\\Icons\\INV_Misc_PocketWatch_01",
    comeback = "Interface\\Icons\\Spell_Holy_Resurrection",
    firstDeath = "Interface\\Icons\\Ability_Rogue_FeignDeath",
    coin = "Interface\\Icons\\INV_Misc_Coin_02",
    mount = "Interface\\Icons\\Ability_Mount_RidingHorse",
    junk = "Interface\\Icons\\INV_Misc_Bag_10",
    moon = "Interface\\Icons\\Spell_Nature_Sleep",
    sun = "Interface\\Icons\\Spell_Holy_HolyBolt",
    rest = "Interface\\Icons\\Spell_Nature_Sleep",
    camera = "Interface\\Icons\\INV_Misc_Spyglass_02",
    alts = "Interface\\Icons\\INV_Misc_GroupLooking",
    skull = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
    stance = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    whirlwind = "Interface\\Icons\\Ability_Whirlwind",
    Beast = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
    Humanoid = "Interface\\Icons\\INV_Misc_Head_Human_01",
    Undead = "Interface\\Icons\\Spell_Shadow_RaiseDead",
    Demon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
    Elemental = "Interface\\Icons\\Spell_Fire_Fire",
    Dragonkin = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
    Giant = "Interface\\Icons\\Ability_Warrior_Revenge",
    Mechanical = "Interface\\Icons\\INV_Gizmo_01",
    elite = "Interface\\Icons\\Ability_Warrior_BattleShout",
    rare = "Interface\\Icons\\INV_Misc_Gem_Diamond_01",
    boss = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01",
    allDungeons = "Interface\\Icons\\INV_Misc_Key_03",
    pioneer = "Interface\\Icons\\INV_Misc_Map_06",
    repeatRun = "Interface\\Icons\\Spell_Nature_Reincarnation",
    speedRun = "Interface\\Icons\\Spell_Nature_Swiftness",
    flawless = "Interface\\Icons\\Spell_Holy_SealOfProtection",
    underdog = "Interface\\Icons\\Ability_Warrior_IntimidatingShout",
    fullHouse = "Interface\\Icons\\INV_Misc_GroupNeedMore",
    smallCrew = "Interface\\Icons\\Ability_Warrior_Sunder",
    bossHunter = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
    diver = "Interface\\Icons\\INV_Misc_Book_09",
    treasure = "Interface\\Icons\\INV_Misc_Bag_08",
    epic = "Interface\\Icons\\INV_Misc_Gem_Amethyst_02",
    jump = "Interface\\Icons\\Ability_Rogue_Sprint",
    flight = "Interface\\Icons\\Ability_Mount_Wyvern_01",
    hearth = "Interface\\Icons\\INV_Misc_Rune_01",
    explore = "Interface\\Icons\\INV_Misc_Spyglass_03",
    globe = "Interface\\Icons\\INV_Misc_Map_07",
    bestiary = "Interface\\Icons\\INV_Misc_Book_07",
    spend = "Interface\\Icons\\INV_Misc_Coin_04",
    spirit = "Interface\\Icons\\Spell_Holy_GuardianSpirit",
    dance = "Interface\\Icons\\Spell_Shadow_DeathScream",
    drunk = "Interface\\Icons\\INV_Drink_04",
    afk = "Interface\\Icons\\Spell_Nature_TimeStop",
}

---------------------------------------------------------------------------
-- What you've done: one snapshot per check, so each value is worked out once
---------------------------------------------------------------------------
local heavy = { at = 0 } -- zone, chain and dungeon results, refreshed now and then

local function Records()
    local list = {}
    for _, r in pairs(ns.cdb.quests or {}) do
        if type(r) == "table" and r.time and not r.imported then list[#list + 1] = r end
    end
    return list
end

-- most quests handed in within any one hour
local function BestHour(records)
    local times = {}
    for _, r in ipairs(records) do times[#times + 1] = r.time end
    table.sort(times)
    local best, first = 0, 1
    for last = 1, #times do
        while times[last] - times[first] > 3600 do first = first + 1 end
        best = math.max(best, last - first + 1)
    end
    return best
end

-- levels you played from start to finish (so the numbers mean something)
local function TrackedLevels()
    local list = {}
    for level in pairs(ns.cdb.levelsDone or {}) do
        if (ns.cdb.levelReachedAt or {})[level] or (ns.cdb.levelExact or {})[level] then list[#list + 1] = level end
    end
    table.sort(list)
    return list
end

local function DeathsByLevel()
    local by = {}
    for _, d in ipairs(ns.cdb.deaths or {}) do by[d.level] = (by[d.level] or 0) + 1 end
    return by
end

local function RefreshHeavy()
    heavy.at = GetTime()
    local zones = ns.QuestieZoneProgress and ns.QuestieZoneProgress()
    if zones then
        local complete, best = 0, nil
        for _, z in ipairs(zones) do
            if z.done >= z.total then
                complete = complete + 1
            elseif not best or z.done / z.total > best.done / best.total then
                best = z
            end
        end
        heavy.zonesComplete, heavy.closestZone = complete, best
    end
    heavy.chains = ns.QuestieChainsCompleted and ns.QuestieChainsCompleted(5) or heavy.chains
    heavy.scholar = ns.DungeonScholarCount and ns.DungeonScholarCount() or heavy.scholar
    heavy.dungeonQuests = ns.DungeonQuestsHandedIn and ns.DungeonQuestsHandedIn() or heavy.dungeonQuests
end

local function Snapshot()
    if GetTime() - heavy.at > HEAVY_SECONDS then pcall(RefreshHeavy) end
    local c = {}
    local level = UnitLevel("player")
    local xpMax = UnitXPMax("player") or 0
    c.level = level
    c.levelValue = level + ((xpMax > 0) and (UnitXP("player") / xpMax) or 0)
    c.quests = ns.QuestStats and ns.QuestStats().count or 0
    c.kills = ns.cdb.totalKills or 0
    c.xp = ns.cdb.totalXP or 0

    local records = Records()
    c.punch, c.party, c.zones = 0, 0, 0
    local zoneSet = {}
    for _, r in ipairs(records) do
        if r.questLevel and r.level and r.questLevel - r.level >= 3 then c.punch = c.punch + 1 end
        if r.party then c.party = c.party + 1 end
        if r.zone and r.zone ~= "" and not zoneSet[r.zone] then
            zoneSet[r.zone] = true
            c.zones = c.zones + 1
        end
    end
    c.party = math.max(c.party, ns.cdb.partyQuests or 0)
    c.bestHour = BestHour(records)
    c.zonesComplete = heavy.zonesComplete or 0
    c.closestZone = heavy.closestZone
    c.chains = heavy.chains or 0
    c.scholar = heavy.scholar or 0

    local clears, newClears = 0, 0
    for key in pairs(ns.cdb.dungeonClears or {}) do
        clears = clears + 1
        local d = ns.DungeonInfo and ns.DungeonInfo(key)
        if d and d.new then newClears = newClears + 1 end
    end
    c.clears, c.newClears = clears, newClears
    c.newTotal = ns.NewDungeonCount and ns.NewDungeonCount() or 9

    -- survival, from level history and deaths
    local deaths = DeathsByLevel()
    local deathless, streak, bestStreak, previous = 0, 0, 0, nil
    for _, l in ipairs(TrackedLevels()) do
        if not deaths[l] then
            deathless = deathless + 1
            streak = (previous and l == previous + 1) and streak + 1 or 1
            bestStreak = math.max(bestStreak, streak)
        else
            streak = 0
        end
        previous = l
    end
    c.deathless, c.bestStreak = deathless, bestStreak

    local session = ns.Session and ns.Session()
    local current = session and session.start and (time() - session.start) or 0
    ns.cdb.longestSession = math.max(ns.cdb.longestSession or 0, current)
    c.longest = ns.cdb.longestSession

    c.comeback = false
    for _, d in ipairs(ns.cdb.deaths or {}) do
        local finished = (ns.cdb.levelsDone or {})[d.level]
        if finished and finished >= d.time and finished - d.time <= 600 then c.comeback = true break end
    end
    c.nightOwl, c.earlyBird = false, false
    for _, t in pairs(ns.cdb.levelReachedAt or {}) do
        local hour = tonumber(date("%H", t))
        if hour and hour < 5 then c.nightOwl = true elseif hour and hour < 8 then c.earlyBird = true end
    end

    -- gold
    c.goldEarned = ns.cdb.goldEarned or 0
    c.money = GetMoney()
    if level < 40 and c.money >= MOUNT_GOLD * 10000 then ns.cdb.achMountMoney = true end
    c.mountMoney = ns.cdb.achMountMoney or false
    c.junk = ns.cdb.junkSold or 0

    -- fun
    local rested = GetXPExhaustion() or 0
    if xpMax > 0 and rested >= xpMax * 1.5 * 0.98 then ns.cdb.achWellRested = true end
    c.wellRested = ns.cdb.achWellRested or false
    c.screenshots = ns.cdb.screenshots or 0
    c.alts = 0
    for _ in pairs(ns.db.alts or {}) do c.alts = c.alts + 1 end
    c.nemesis, c.nemesisName = 0, nil
    local byKiller = {}
    for _, d in ipairs(ns.cdb.deaths or {}) do
        if d.killer then
            byKiller[d.killer] = (byKiller[d.killer] or 0) + 1
            if byKiller[d.killer] > c.nemesis then c.nemesis, c.nemesisName = byKiller[d.killer], d.killer end
        end
    end

    -- more dungeons
    local stats = ns.cdb.dungeonStats or {}
    local mostRuns = 0
    for _, n in pairs(stats.counts or {}) do mostRuns = math.max(mostRuns, n) end
    c.mostRuns = mostRuns
    c.fastestRun = stats.fastest
    c.flawless = stats.flawless or 0
    c.underdog = stats.underdog or 0
    c.fullHouse = stats.fullHouse or 0
    c.smallCrew = stats.smallCrew or 0
    c.dungeonTotal = #(ns.DUNGEONS or {})
    c.uniqueBosses = 0
    for _ in pairs(ns.cdb.bossesKilled or {}) do c.uniqueBosses = c.uniqueBosses + 1 end
    c.dungeonQuests = heavy.dungeonQuests or 0
    c.lootRare = ns.cdb.lootRare or 0
    c.lootEpic = ns.cdb.lootEpic or 0

    -- more fun
    c.jumps = ns.cdb.jumps or 0
    c.flights = ns.cdb.flights or 0
    c.hearths = ns.cdb.hearths or 0
    c.discoveries = ns.cdb.discoveries or 0
    c.zonesVisited = 0
    for _ in pairs(ns.cdb.zoneTime or {}) do c.zonesVisited = c.zonesVisited + 1 end
    c.creaturesSeen = 0
    for _ in pairs(ns.db.creatureInfo or {}) do c.creaturesSeen = c.creaturesSeen + 1 end
    c.goldSpent = ns.cdb.goldSpent or 0
    c.deaths = #(ns.cdb.deaths or {})
    c.cards = ns.CardCount and ns.CardCount() or 0
    c.dances = ns.cdb.dances or 0
    c.drunk = ns.cdb.achDrunk or false
    c.afk = ns.cdb.achAFK or false

    -- slayer
    c.byType = ns.cdb.killsByType or {}
    local byRank = ns.cdb.killsByRank or {}
    c.elites = (byRank.elite or 0) + (byRank.rareelite or 0)
    c.rares = (byRank.rare or 0) + (byRank.rareelite or 0)
    c.bosses = ns.cdb.bossKills or 0

    -- warrior
    c.stances = Safe(IsPlayerSpell, 71) == true and Safe(IsPlayerSpell, 2458) == true
    local whirlwind = false
    for _, r in pairs(ns.cdb.quests or {}) do
        if type(r) == "table" and r.title == "Whirlwind Weapon" then whirlwind = true break end
    end
    local weapon = GetInventoryItemLink and Safe(GetInventoryItemLink, "player", 16)
    local weaponName = weapon and weapon:match("%[(.-)%]")
    if weaponName and (weaponName:find("Whirlwind") or weaponName == "Bonebiter") then whirlwind = true end
    if whirlwind then ns.cdb.achWhirlwind = true end
    c.whirlwind = ns.cdb.achWhirlwind or false
    return c
end

---------------------------------------------------------------------------
-- The list
---------------------------------------------------------------------------
-- category -> { { title, desc, icon, hidden, items = { item } } }
-- item: key, label, target, value(c), points, tier, lowerBetter, fmt(v, target), missed(c)
local CATEGORIES = {
    { key = "overview", label = "Overview" },
    { key = "progress", label = "Levels & XP" },
    { key = "slayer", label = "Slayer" },
    { key = "questing", label = "Questing" },
    { key = "dungeons", label = "Dungeons" },
    { key = "survival", label = "Survival" },
    { key = "gold", label = "Gold" },
    { key = "fun", label = "Fun" },
    { key = "warrior", label = "Warrior", class = "WARRIOR" },
    { key = "paladin", label = "Paladin", class = "PALADIN" },
    { key = "hunter", label = "Hunter", class = "HUNTER" },
    { key = "rogue", label = "Rogue", class = "ROGUE" },
    { key = "priest", label = "Priest", class = "PRIEST" },
    { key = "shaman", label = "Shaman", class = "SHAMAN" },
    { key = "mage", label = "Mage", class = "MAGE" },
    { key = "warlock", label = "Warlock", class = "WARLOCK" },
    { key = "druid", label = "Druid", class = "DRUID" },
}
local groups = {} -- category key -> groups
local allItems = {}

local function TierFor(i, n)
    if n == 1 then return "gold" end
    if i <= math.ceil(n / 3) then return "bronze" end
    if i <= math.ceil(n * 2 / 3) then return "silver" end
    return "gold"
end

local function Count(v, target) return format("%s / %s", ns.Comma(math.floor(v)), ns.Comma(target)) end
local function Yes() return "" end

-- one of these is picked for the first death pop-up
local FIRST_DEATH_BANTER = {
    "Good thing this isn't hardcore - that would have been the whole character.",
    "On a hardcore realm you'd be rolling a new character right now. Run back.",
    "Hardcore players felt that one. You just get a corpse run.",
    "That's why we don't play hardcore. Spirit healer's this way.",
    "One life? Not here. Dust yourself off.",
    "In hardcore this is where the stream ends. Here it's a 30-second jog.",
}

-- A group of steps: Group("questing", { title, desc, icon, prefix, steps, value, label, fmt, hidden })
local function Group(cat, g)
    g.items = {}
    for i, step in ipairs(g.steps) do
        local tier = g.tiers and g.tiers[i] or TierFor(i, #g.steps)
        local item = {
            key = g.prefix .. step, target = step, value = g.value, tier = tier,
            points = g.points and g.points[i] or POINTS[tier],
            label = g.label and g.label(step, i) or g.title, fmt = g.fmt or Count,
            lowerBetter = g.lowerBetter, missed = g.missed, hidden = g.hidden and g.hidden[i],
            group = g, icon = g.icon,
        }
        g.items[#g.items + 1] = item
        allItems[#allItems + 1] = item
    end
    groups[cat] = groups[cat] or {}
    table.insert(groups[cat], g)
end

local function Minutes(seconds) return format("%dm", math.floor(seconds / 60 + 0.5)) end

local function Define()
    local S = ns.MILESTONE_STEPS
    local max = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    -- Levels & XP: the original milestones (same keys, so earlier unlocks count)
    Group("progress", { title = "Levels", icon = ICON.level, prefix = "level:", steps = S.levels,
        value = function(c) return c.levelValue end,
        label = function(n)
            if n == 40 then return "Level 40 - mount time" end
            if n == max then return format("Level %d - the top", n) end
            return "Level " .. n
        end,
        fmt = function(v, t) return format("level %d / %d", math.floor(v), t) end })
    Group("progress", { title = "Quests completed", icon = ICON.quest, prefix = "quests:", steps = S.quests,
        value = function(c) return c.quests end, label = function(n) return ns.Comma(n) .. " quests" end })
    Group("progress", { title = "Kills", icon = ICON.kill, prefix = "kills:", steps = S.kills,
        value = function(c) return c.kills end, label = function(n) return ns.Comma(n) .. " kills" end })
    Group("progress", { title = "Experience", icon = ICON.xp, prefix = "xp:", steps = S.xp,
        value = function(c) return c.xp end, label = function(n) return ns.Short(n) .. " XP earned" end,
        fmt = function(v, t) return format("%s / %s", ns.Short(v), ns.Short(t)) end })

    -- Slayer: kills by creature type and rank (counted from now), shown one bar per group
    local TYPES = {
        { "Beast", "Beasts", { 100, 500, 1000, 2500 } }, { "Humanoid", "Humanoids", { 100, 500, 1000, 2500 } },
        { "Undead", "Undead", { 50, 250, 1000 } }, { "Demon", "Demons", { 50, 250, 500 } },
        { "Elemental", "Elementals", { 50, 250, 500 } }, { "Dragonkin", "Dragonkin", { 25, 100, 250 } },
        { "Giant", "Giants", { 25, 100, 250 } }, { "Mechanical", "Mechanicals", { 25, 100, 250 } },
    }
    for _, t in ipairs(TYPES) do
        local creatureType, plural = t[1], t[2]
        Group("slayer", { title = plural .. " slain", icon = ICON[creatureType], compact = true, short = plural,
            prefix = "ach:type:" .. creatureType:lower() .. ":", steps = t[3],
            value = function(c) return c.byType[creatureType] or 0 end,
            label = function(n) return format("%s %s slain", ns.Comma(n), plural:lower()) end })
    end
    Group("slayer", { title = "Elites slain", icon = ICON.elite, compact = true, short = "Elites",
        prefix = "ach:elites:", steps = { 25, 100, 250 }, value = function(c) return c.elites end,
        label = function(n) return n .. " elites slain" end })
    Group("slayer", { title = "Rares slain", icon = ICON.rare, compact = true, short = "Rares",
        prefix = "ach:rares:", steps = { 1, 10, 25 }, value = function(c) return c.rares end,
        label = function(n) return n == 1 and "Your first rare" or (n .. " rares slain") end })
    Group("slayer", { title = "Bosses slain", icon = ICON.boss, compact = true, short = "Bosses",
        prefix = "ach:bosses:", steps = { 1, 10, 25, 50 }, value = function(c) return c.bosses end,
        label = function(n) return n == 1 and "Your first boss" or (n .. " bosses slain") end })

    -- Questing
    Group("questing", { title = "Punching up", desc = "Hand in quests 3 or more levels above you.", icon = ICON.punch,
        prefix = "ach:punch:", steps = { 5, 25, 50 }, value = function(c) return c.punch end,
        label = function(n) return n .. " tough quests" end })
    Group("questing", { title = "Quest blitz", desc = "Hand in lots of quests within a single hour.", icon = ICON.blitz,
        prefix = "ach:blitz:", steps = { 10, 20 }, hidden = { false, true }, tiers = { "silver", "gold" },
        value = function(c) return c.bestHour end,
        label = function(n) return n == 20 and "Blitzkrieg: 20 in an hour" or "10 quests in an hour" end })
    Group("questing", { title = "Zone tourist", desc = "Complete quests in many different zones.", icon = ICON.map,
        prefix = "ach:zones:", steps = { 5, 10, 20 }, value = function(c) return c.zones end,
        label = function(n) return n .. " zones" end })
    Group("questing", { title = "Zone completionist", desc = "Finish every quest for you in a zone (per QuestieDB).",
        icon = ICON.zone, prefix = "ach:zonedone:", steps = { 1, 3, 5 }, value = function(c) return c.zonesComplete end,
        label = function(n) return n == 1 and "1 zone at 100%" or (n .. " zones at 100%") end, closestZone = true })
    Group("questing", { title = "Chain master", desc = "Finish whole quest chains of 5 or more steps.", icon = ICON.chain,
        prefix = "ach:chains:", steps = { 1, 5, 10 }, value = function(c) return c.chains end,
        label = function(n) return n == 1 and "1 long chain" or (n .. " long chains") end })
    Group("questing", { title = "Team player", desc = "Hand in quests while in a party (counted from now).",
        icon = ICON.party, prefix = "ach:party:", steps = { 25, 100 }, tiers = { "bronze", "silver" },
        value = function(c) return c.party end, label = function(n) return n .. " party quests" end })

    -- Dungeons
    Group("dungeons", { title = "Dungeon delver", desc = "Clear dungeons by killing their last boss (counted from now).",
        icon = ICON.dungeon, prefix = "ach:clears:", steps = { 1, 5, 10 }, value = function(c) return c.clears end,
        label = function(n) return n == 1 and "1 dungeon cleared" or (n .. " dungeons cleared") end })
    Group("dungeons", { title = "Forever explorer", desc = "Clear every one of WoW Forever's new dungeons.",
        icon = ICON.forever, prefix = "ach:forever:", steps = { 1 }, points = { 50 },
        value = function(c) return c.newTotal > 0 and c.newClears / c.newTotal or 0 end,
        label = function() return "All new dungeons cleared" end,
        fmt = function(v) return format("%d%%", math.floor(v * 100)) end })
    Group("dungeons", { title = "Dungeon scholar", desc = "Complete every quest of a dungeon.", icon = ICON.scholar,
        prefix = "ach:scholar:", steps = { 1, 3, 5 }, value = function(c) return c.scholar end,
        label = function(n) return n == 1 and "1 dungeon's quests" or (n .. " dungeons' quests") end })

    Group("dungeons", { title = "Completionist", desc = "Clear every dungeon in the journal.", icon = ICON.allDungeons,
        prefix = "ach:alldungeons:", steps = { 1 }, points = { 50 },
        value = function(c) return c.dungeonTotal > 0 and c.clears / c.dungeonTotal or 0 end,
        label = function() return "Every dungeon cleared" end,
        fmt = function(_, _, c) return c and format("%d / %d", c.clears, c.dungeonTotal) or "" end })
    Group("dungeons", { title = "Forever pioneer", desc = "Clear one of WoW Forever's new dungeons.", icon = ICON.pioneer,
        prefix = "ach:pioneer:", steps = { 1 }, tiers = { "silver" }, value = function(c) return c.newClears end,
        label = function() return "Your first new dungeon" end })
    Group("dungeons", { title = "Repeat customer", desc = "Clear the same dungeon again and again.", icon = ICON.repeatRun,
        prefix = "ach:repeat:", steps = { 3, 5 }, tiers = { "bronze", "silver" }, value = function(c) return c.mostRuns end,
        label = function(n) return n .. " clears of one dungeon" end })
    Group("dungeons", { title = "Speed runner", desc = "Clear a dungeon soon after walking in.", icon = ICON.speedRun,
        prefix = "ach:speedrun:", steps = { 2700, 1800 }, tiers = { "silver", "gold" }, lowerBetter = true,
        value = function(c) return c.fastestRun end,
        label = function(n) return "Clear in under " .. Minutes(n) end,
        fmt = function(v, t) return v and format("best %s / %s", Minutes(v), Minutes(t)) or ("goal " .. Minutes(t)) end })
    Group("dungeons", { title = "Flawless", desc = "Clear a dungeon without dying once.", icon = ICON.flawless,
        prefix = "ach:flawless:", steps = { 1 }, tiers = { "silver" }, value = function(c) return c.flawless end,
        label = function() return "A deathless clear" end })
    Group("dungeons", { title = "Underdog", desc = "Clear a dungeon while below its level range.", icon = ICON.underdog,
        prefix = "ach:underdog:", steps = { 1 }, tiers = { "gold" }, value = function(c) return c.underdog end,
        label = function() return "Under-levelled clear" end })
    Group("dungeons", { title = "Full house", desc = "Clear a dungeon with a full party of five.", icon = ICON.fullHouse,
        prefix = "ach:fullhouse:", steps = { 1 }, tiers = { "bronze" }, value = function(c) return c.fullHouse end,
        label = function() return "Five-player clear" end })
    Group("dungeons", { title = "Small crew", desc = "Clear a dungeon with three players or fewer.", icon = ICON.smallCrew,
        prefix = "ach:smallcrew:", steps = { 1 }, hidden = { true }, tiers = { "gold" },
        value = function(c) return c.smallCrew end, label = function() return "Small crew" end })
    Group("dungeons", { title = "Boss hunter", desc = "Kill many different dungeon bosses.", icon = ICON.bossHunter,
        prefix = "ach:bosshunter:", steps = { 10, 25, 50 }, value = function(c) return c.uniqueBosses end,
        label = function(n) return n .. " different bosses" end })
    Group("dungeons", { title = "Dungeon diver", desc = "Hand in dungeon quests.", icon = ICON.diver,
        prefix = "ach:dquests:", steps = { 10, 25, 50 }, value = function(c) return c.dungeonQuests end,
        label = function(n) return n .. " dungeon quests" end })
    Group("dungeons", { title = "Treasure hunter", desc = "Loot blue (rare) items.", icon = ICON.treasure,
        prefix = "ach:blues:", steps = { 1, 10, 25 }, value = function(c) return c.lootRare end,
        label = function(n) return n == 1 and "Your first blue" or (n .. " blues looted") end })
    Group("dungeons", { title = "Epic!", desc = "Loot a purple (epic) item.", icon = ICON.epic,
        prefix = "ach:epic:", steps = { 1 }, tiers = { "gold" }, value = function(c) return c.lootEpic end,
        label = function() return "Your first epic" end })

    -- Survival
    Group("survival", { title = "Untouchable", desc = "Reach a new level without dying on the way.", icon = ICON.shield,
        prefix = "ach:deathless:", steps = { 1, 5, 10 }, value = function(c) return c.deathless end,
        label = function(n) return n == 1 and "1 deathless level" or (n .. " deathless levels") end })
    Group("survival", { title = "Unbroken", desc = "Deathless levels in a row.", icon = ICON.streak,
        prefix = "ach:streak:", steps = { 5 }, value = function(c) return c.bestStreak end,
        label = function() return "5 levels in a row" end })
    Group("survival", { title = "Marathon", desc = "One long play session.", icon = ICON.clock,
        prefix = "ach:marathon:", steps = { 7200, 14400, 21600 }, value = function(c) return c.longest end,
        label = function(n) return format("%d hour session", n / 3600) end,
        fmt = function(v, t) return format("%s / %s", ns.Duration(v), ns.Duration(t)) end })
    Group("survival", { title = "Comeback", desc = "Level up within 10 minutes of dying.", icon = ICON.comeback,
        prefix = "ach:comeback:", steps = { 1 }, hidden = { true }, tiers = { "silver" },
        value = function(c) return c.comeback and 1 or 0 end, label = function() return "Comeback" end, fmt = Yes })

    -- Gold
    Group("gold", { title = "Coin collector", desc = "Gold earned in total (counted from now).", icon = ICON.coin,
        prefix = "ach:gold:", steps = { 100000, 500000, 1000000, 5000000 },
        value = function(c) return c.goldEarned end,
        label = function(n) return format("%dg earned", n / 10000) end,
        fmt = function(v, t) return format("%dg / %dg", math.floor(v / 10000), t / 10000) end })
    Group("gold", { title = "Mount money", desc = format("Hold %dg before you reach level 40.", MOUNT_GOLD), icon = ICON.mount,
        prefix = "ach:mountgold:", steps = { 1 }, tiers = { "gold" },
        value = function(c) return c.mountMoney and 1 or math.min(0.99, c.money / (MOUNT_GOLD * 10000)) end,
        missed = function(c) return c.level >= 40 end,
        label = function() return format("%dg before level 40", MOUNT_GOLD) end,
        fmt = function(_, _, c) return format("%dg / %dg", math.floor((c and c.money or 0) / 10000), MOUNT_GOLD) end })
    Group("gold", { title = "Junk dealer", desc = "Items sold by the vendor helper (counted from now).", icon = ICON.junk,
        prefix = "ach:junk:", steps = { 100, 500, 1000 }, value = function(c) return c.junk end,
        label = function(n) return ns.Comma(n) .. " items sold" end })

    -- Fun
    Group("fun", { title = "Night owl", desc = "Level up between midnight and 5am.", icon = ICON.moon,
        prefix = "ach:owl:", steps = { 1 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.nightOwl and 1 or 0 end, label = function() return "Night owl" end, fmt = Yes })
    Group("fun", { title = "Early bird", desc = "Level up between 5am and 8am.", icon = ICON.sun,
        prefix = "ach:bird:", steps = { 1 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.earlyBird and 1 or 0 end, label = function() return "Early bird" end, fmt = Yes })
    Group("fun", { title = "Well rested", desc = "Have the full 150% of a level in rested XP.", icon = ICON.rest,
        prefix = "ach:rested:", steps = { 1 }, tiers = { "bronze" },
        value = function(c) return c.wellRested and 1 or 0 end, label = function() return "Fully rested" end, fmt = Yes })
    Group("fun", { title = "Photographer", desc = "Level-up screenshots taken.", icon = ICON.camera,
        prefix = "ach:photos:", steps = { 10, 25, 50 }, value = function(c) return c.screenshots end,
        label = function(n) return n .. " screenshots" end })
    Group("fun", { title = "Alt army", desc = "Characters on your Alts tab.", icon = ICON.alts,
        prefix = "ach:alts:", steps = { 3, 5 }, tiers = { "bronze", "silver" }, value = function(c) return c.alts end,
        label = function(n) return n .. " characters" end })
    Group("fun", { title = "Unlucky", desc = "Get killed by the same mob 3 times.", icon = ICON.skull,
        prefix = "ach:nemesis:", steps = { 3 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.nemesis end, label = function() return "A nemesis" end })

    Group("fun", { title = "Jumping jack", desc = "Jump. A lot.", icon = ICON.jump,
        prefix = "ach:jumps:", steps = { 100, 1000, 5000 }, value = function(c) return c.jumps end,
        label = function(n) return ns.Comma(n) .. " jumps" end })
    Group("fun", { title = "Frequent flyer", desc = "Take flights.", icon = ICON.flight,
        prefix = "ach:flights:", steps = { 10, 50 }, tiers = { "bronze", "silver" }, value = function(c) return c.flights end,
        label = function(n) return n .. " flights" end })
    Group("fun", { title = "Homeward bound", desc = "Use your hearthstone.", icon = ICON.hearth,
        prefix = "ach:hearths:", steps = { 10, 50 }, tiers = { "bronze", "silver" }, value = function(c) return c.hearths end,
        label = function(n) return n .. " hearthstones" end })
    Group("fun", { title = "Explorer", desc = "Discover new places on the map.", icon = ICON.explore,
        prefix = "ach:discover:", steps = { 25, 100, 200 }, value = function(c) return c.discoveries end,
        label = function(n) return n .. " places discovered" end })
    Group("fun", { title = "Globetrotter", desc = "Spend time in many zones.", icon = ICON.globe,
        prefix = "ach:globe:", steps = { 10, 20, 30 }, value = function(c) return c.zonesVisited end,
        label = function(n) return n .. " zones visited" end })
    Group("fun", { title = "Bestiary", desc = "See many different creatures (all your characters).", icon = ICON.bestiary,
        prefix = "ach:bestiary:", steps = { 100, 250, 500 }, value = function(c) return c.creaturesSeen end,
        label = function(n) return n .. " creatures seen" end })
    Group("fun", { title = "Big spender", desc = "Gold spent on anything (counted from now).", icon = ICON.spend,
        prefix = "ach:spent:", steps = { 100000, 500000, 1000000 }, value = function(c) return c.goldSpent end,
        label = function(n) return format("%dg spent", n / 10000) end,
        fmt = function(v, t) return format("%dg / %dg", math.floor(v / 10000), t / 10000) end })
    Group("fun", { title = "Card collector", desc = "Collect enemy cards: defeat different kinds of enemy.",
        icon = "Interface\\Icons\\INV_Misc_Ticket_Tarot_Stack_01", prefix = "ach:cards:", steps = { 25, 100, 250, 500 },
        value = function(c) return c.cards end, label = function(n) return n .. " cards" end })
    Group("fun", { title = "Not hardcore, then", desc = "Die for the first time. Lucky this isn't a hardcore realm.",
        icon = ICON.firstDeath, prefix = "ach:firstdeath:", steps = { 1 }, tiers = { "bronze" },
        value = function(c) return math.min(c.deaths, 1) end, label = function() return "First death" end, fmt = Yes })
    Group("fun", { title = "Spirit healer's friend", desc = "Die... quite a bit.", icon = ICON.spirit,
        prefix = "ach:deaths:", steps = { 10, 50 }, tiers = { "bronze", "silver" }, value = function(c) return c.deaths end,
        label = function(n) return n .. " deaths" end })
    Group("fun", { title = "Dance party", desc = "Dance (/dance) ten times.", icon = ICON.dance,
        prefix = "ach:dance:", steps = { 10 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.dances end, label = function() return "Dance party" end })
    Group("fun", { title = "Party animal", desc = "Have a few too many drinks.", icon = ICON.drunk,
        prefix = "ach:drunk:", steps = { 1 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.drunk and 1 or 0 end, label = function() return "Party animal" end, fmt = Yes })
    Group("fun", { title = "AFK legend", desc = "Stay away from keyboard for 30 minutes.", icon = ICON.afk,
        prefix = "ach:afk:", steps = { 1 }, hidden = { true }, tiers = { "bronze" },
        value = function(c) return c.afk and 1 or 0 end, label = function() return "AFK legend" end, fmt = Yes })

    -- Warrior
    Group("warrior", { title = "Stance master", desc = "Learn Defensive and Berserker Stance.", icon = ICON.stance,
        prefix = "ach:stances:", steps = { 1 }, tiers = { "silver" },
        value = function(c) return c.stances and 1 or 0 end, label = function() return "All three stances" end, fmt = Yes })
    Group("warrior", { title = "Whirlwind", desc = "Earn a weapon from the Whirlwind Weapon quest.", icon = ICON.whirlwind,
        prefix = "ach:whirlwind:", steps = { 1 }, tiers = { "gold" },
        value = function(c) return c.whirlwind and 1 or 0 end, label = function() return "Whirlwind weapon" end, fmt = Yes })

    -- your class's quest chains (the warrior's stances and Whirlwind weapon are above)
    local cat = (ns.PlayerClassFile() or ""):lower()
    for _, q in ipairs(ns.ClassQuestsForMe()) do
        if q.max < 60 and not q.title:find("Stance") and not q.title:find("Whirlwind") then
            Group(cat, { title = q.title, desc = q.why, icon = ICON.quest,
                prefix = "ach:class:" .. q.id .. ":", steps = { 1 }, tiers = { q.spells and "gold" or "silver" },
                value = function() return ns.ClassQuestDone(q) and 1 or 0 end, label = function() return q.title end, fmt = Yes })
        end
    end
end

---------------------------------------------------------------------------
-- State of each achievement
---------------------------------------------------------------------------
local function Applies(cat)
    local _, class = UnitClass("player")
    for _, def in ipairs(CATEGORIES) do
        if def.key == cat then return not def.class or def.class == class end
    end
    return true
end

local function Met(item, c)
    local v = item.value(c)
    if item.lowerBetter then return v ~= nil and v <= item.target end
    return (v or 0) >= item.target
end

local function Done(item)
    return (ns.cdb.milestonesDone or {})[item.key] ~= nil
end

local function Fraction(item, c)
    if Done(item) then return 1 end
    local v = item.value(c)
    if item.lowerBetter then return v and math.min(1, item.target / v) or 0 end
    return math.max(0, math.min(1, (v or 0) / item.target))
end

local function CategoryOf(item)
    for cat, list in pairs(groups) do
        for _, g in ipairs(list) do if g == item.group then return cat end end
    end
end

---------------------------------------------------------------------------
-- Unlocking
---------------------------------------------------------------------------
local loginAt = GetTime()

local function Check()
    if not ns.cdb or not ns.cdb.milestonesDone or not ns.MILESTONE_STEPS then return end
    local c = Snapshot()
    -- first run: quietly catch up on everything your history already earned
    local catchUp = (ns.cdb.achVersion or 0) < VERSION
    local quietly = 0
    for _, item in ipairs(allItems) do
        local cat = CategoryOf(item)
        if not Done(item) and Applies(cat) and not (item.missed and item.missed(c)) and Met(item, c) then
            local title = item.hidden and item.group.title or item.label
            local text = item.group.desc or item.group.title
            if item.key:find("^ach:nemesis") and c.nemesisName then text = format("%s has killed you %d times.", c.nemesisName, c.nemesis) end
            if item.key:find("^ach:firstdeath") then text = FIRST_DEATH_BANTER[math.random(#FIRST_DEATH_BANTER)] end
            ns.Milestone(item.key, title, text, item.icon, catchUp, { tier = item.tier, points = item.points })
            if catchUp then quietly = quietly + 1 end
        end
    end
    if catchUp and GetTime() - loginAt >= CATCH_UP_SECONDS then
        ns.cdb.achVersion = VERSION
        if quietly > 0 or (ns.cdb.achCaughtUp or 0) > 0 then
            ns.Print(format("Achievements: %d unlocked from your history. See them with |cffc79c6e/hb achievements|r.",
                quietly + (ns.cdb.achCaughtUp or 0)))
        end
        ns.cdb.achCaughtUp = nil
    elseif catchUp then
        ns.cdb.achCaughtUp = (ns.cdb.achCaughtUp or 0) + quietly
    end
end

-- Dungeon clears: the dungeon's last boss dies while you're inside
local function Normal(name)
    return name and name:lower():gsub("^the ", ""):gsub("[^%w]", "") or ""
end

local function OnBossKill(bossName)
    if type(bossName) ~= "string" or ns.IsSecret(bossName) then return end
    local inInstance = IsInInstance()
    if not inInstance then return end
    local ok, instanceName = pcall(GetInstanceInfo)
    if not ok or type(instanceName) ~= "string" or ns.IsSecret(instanceName) then return end
    local key = instanceName and ns.DungeonKeyForName(instanceName)
    local final = key and ns.DungeonFinalBoss and ns.DungeonFinalBoss(key)
    if not final then return end
    local a, b = Normal(final), Normal(bossName)
    if a == b or (a ~= "" and b ~= "" and (a:find(b, 1, true) or b:find(a, 1, true))) then
        ns.cdb.dungeonClears = ns.cdb.dungeonClears or {}
        local first = not ns.cdb.dungeonClears[key]
        if first then ns.cdb.dungeonClears[key] = time() end
        -- how this run went: count, time, deaths, level and party size
        local stats = ns.cdb.dungeonStats or { counts = {} }
        ns.cdb.dungeonStats = stats
        stats.counts[key] = (stats.counts[key] or 0) + 1
        local run = ns.DungeonRunResult and ns.DungeonRunResult(key)
        local summary = ""
        if run then
            if not stats.fastest or run.seconds < stats.fastest then stats.fastest = run.seconds end
            if run.deaths == 0 then stats.flawless = (stats.flawless or 0) + 1 end
            summary = format(" in %s%s", ns.Duration(run.seconds), run.deaths == 0 and ", without dying" or "")
        end
        local d = ns.DungeonInfo and ns.DungeonInfo(key)
        if d and d.min and UnitLevel("player") < d.min then stats.underdog = (stats.underdog or 0) + 1 end
        local size = math.max(1, GetNumGroupMembers and GetNumGroupMembers() or 1)
        if size >= 5 then stats.fullHouse = (stats.fullHouse or 0) + 1 end
        if size <= 3 then stats.smallCrew = (stats.smallCrew or 0) + 1 end
        ns.Print(format("Cleared |cffffd200%s|r%s!%s", instanceName, summary,
            first and "" or format(" |cff999999(clear #%d)|r", stats.counts[key])))
        C_Timer.After(1, Check)
    end
end

---------------------------------------------------------------------------
-- The tab
---------------------------------------------------------------------------
local page, leftView, rightView, catButtons = nil, nil, nil, {}
local selected = "overview"
local VIEW_TOP = 0
local SCROLL_STEP = 40
local scroll, content, scrollBar

local function TierMark(tier)
    local rgb = TIER_RGB[tier]
    if not rgb then return "" end
    return "|TInterface\\Buttons\\WHITE8X8:8:8:0:0:8:8:0:8:0:8:" .. rgb .. "|t "
end

local function ItemRow(add, item, c)
    local done = Done(item)
    if item.hidden and not done then
        add.bar(0, "???", "hidden", GREY)
        return
    end
    local right
    if done then
        local when = ns.cdb.milestonesDone[item.key]
        right = format("|cff6fdc6f%s%d pts|r", type(when) == "number" and (date("%d %b", when) .. "  ") or "", item.points)
    elseif item.missed and item.missed(c) then
        right = "|cff999999missed|r"
    else
        local text = item.fmt(item.value(c), item.target, c)
        right = (text ~= "" and (text .. "  ") or "") .. format("|cff999999%d pts|r", item.points)
    end
    add.bar(Fraction(item, c), TierMark(item.tier) .. item.label, right, done and GREEN or GOLD)
end

local function GroupUnlocked(g)
    local n = 0
    for _, item in ipairs(g.items) do if Done(item) then n = n + 1 end end
    return n
end

local function AddGroup(add, g, c)
    local allHidden = true
    for _, item in ipairs(g.items) do if not item.hidden or Done(item) then allHidden = false end end
    add.header(format("%s  %d/%d", allHidden and "???" or g.title, GroupUnlocked(g), #g.items),
        { icon = allHidden and "Interface\\Icons\\INV_Misc_QuestionMark" or g.icon })
    if g.desc and not allHidden then add.note(g.desc, ns.color.dim) end
    for _, item in ipairs(g.items) do ItemRow(add, item, c) end
    if g.closestZone and c.closestZone then
        local z = c.closestZone
        add.note(format("Closest: %s %d%% (%d/%d)", z.name, math.floor(z.done / z.total * 100), z.done, z.total), ns.color.dim)
    end
end

-- one bar for a whole group: the next step to reach (or the last, when all are done)
local function CompactRow(add, g, c)
    local nextItem, marks = nil, ""
    for _, item in ipairs(g.items) do
        if Done(item) then marks = marks .. TierMark(item.tier) elseif not nextItem then nextItem = item end
    end
    local item = nextItem or g.items[#g.items]
    local value = item.value(c) or 0
    local right
    if nextItem then
        right = format("%s / %s  |cff999999%d pts|r", ns.Comma(value), ns.Comma(item.target), item.points)
    else
        right = format("|cff6fdc6f%s - all done|r", ns.Comma(value))
    end
    add.bar(Fraction(item, c), ns.IconText(g.icon) .. g.short .. (marks ~= "" and ("  " .. marks) or ""), right,
        nextItem and GOLD or GREEN)
end

local function Totals(c)
    local points, maxPoints, unlocked, total = 0, 0, 0, 0
    local byCat = {}
    for _, item in ipairs(allItems) do
        local cat = CategoryOf(item)
        if Applies(cat) then
            total = total + 1
            maxPoints = maxPoints + item.points
            byCat[cat] = byCat[cat] or { done = 0, total = 0 }
            byCat[cat].total = byCat[cat].total + 1
            if Done(item) then
                unlocked = unlocked + 1
                points = points + item.points
                byCat[cat].done = byCat[cat].done + 1
            end
        end
    end
    return points, maxPoints, unlocked, total, byCat
end

local function BuildOverview(c)
    local points, maxPoints, unlocked, total, byCat = Totals(c)
    local add = leftView.add
    add.header("Your achievements")
    add.bar(points / math.max(1, maxPoints), "Points", format("%d / %d", points, maxPoints), GOLD)
    add.row("Unlocked", format("%d of %d", unlocked, total))
    for _, def in ipairs(CATEGORIES) do
        local stats = byCat[def.key]
        if stats then add.bar(stats.done / stats.total, def.label, format("%d / %d", stats.done, stats.total), GREEN) end
    end

    add = rightView.add
    add.header("Closest to unlocking")
    local list = {}
    for _, item in ipairs(allItems) do
        local cat = CategoryOf(item)
        if Applies(cat) and not Done(item) and not item.hidden and not (item.missed and item.missed(c)) then
            list[#list + 1] = { item = item, f = Fraction(item, c) }
        end
    end
    table.sort(list, function(a, b) return a.f > b.f end)
    for i = 1, math.min(5, #list) do
        local e = list[i]
        add.bar(e.f, TierMark(e.item.tier) .. e.item.label, format("%d%%", math.floor(e.f * 100)), GOLD)
    end
    add.header("Recently unlocked")
    local log = ns.cdb.milestoneLog or {}
    if #log == 0 then add.note("Nothing yet - keep going!", ns.color.dim) end
    for i = 1, math.min(5, #log) do
        add.list(date("%d %b", log[i].time), ns.IconText(log[i].icon) .. (log[i].title or ""))
    end
end

local function BuildSlayer(c)
    local add = leftView.add
    local unlocked, total = 0, 0
    for _, g in ipairs(groups.slayer or {}) do
        for _, item in ipairs(g.items) do
            total = total + 1
            if Done(item) then unlocked = unlocked + 1 end
        end
    end
    add.header(format("Slayer  %d/%d", unlocked, total))
    add.note("Kills of each kind, counted from now. Squares are the tiers you've reached.", ns.color.dim)
    for _, g in ipairs(groups.slayer or {}) do CompactRow(add, g, c) end

    local r = ns.KillRecord and ns.KillRecord()
    if not r then return end
    add.header("Most killed")
    if #r.mostKilled == 0 then add.note("Nothing yet.", ns.color.dim) end
    for i = 1, math.min(5, #r.mostKilled) do add.row(r.mostKilled[i].name, "x" .. ns.Comma(r.mostKilled[i].n)) end

    add = rightView.add
    add.header("Kill record")
    add.row("All kills", ns.Comma(r.total))
    local types = {}
    for name, n in pairs(r.byType) do types[#types + 1] = { name = name, n = n } end
    table.sort(types, function(a, b) return a.n > b.n end)
    for _, t in ipairs(types) do
        local label = t.name == "Unknown" and "Not seen up close" or t.name
        add.row(label, ns.Comma(t.n))
    end
    if #types == 0 then add.note("Kill something to start the record.", ns.color.dim) end

    add.header("By rank")
    local RANK_LABELS = { { "normal", "Normal" }, { "elite", "Elite" }, { "rare", "Rare" }, { "rareelite", "Rare elite" }, { "boss", "World boss" } }
    for _, rank in ipairs(RANK_LABELS) do
        local n = r.byRank[rank[1]]
        if n and n > 0 then add.row(rank[2], ns.Comma(n)) end
    end

    add.header("Bosses")
    add.row("Bosses slain", format("%s  |cff999999(%d different)|r", ns.Comma(r.bosses), r.uniqueBosses))
    for i = 1, math.min(3, #r.bossLog) do
        local b = r.bossLog[i]
        add.list(date("%d %b", b.time), b.name .. (b.dungeon and (" |cff999999- " .. b.dungeon .. "|r") or ""))
    end
end

local function BuildCategory(cat, c)
    if cat == "slayer" then return BuildSlayer(c) end
    local list = groups[cat] or {}
    -- share the groups between the columns by size
    local leftSize, rightSize = 0, 0
    for _, g in ipairs(list) do
        local size = #g.items + (g.desc and 2 or 1)
        if leftSize <= rightSize then
            AddGroup(leftView.add, g, c)
            leftSize = leftSize + size
        else
            AddGroup(rightView.add, g, c)
            rightSize = rightSize + size
        end
    end
end

function ns.RefreshAchievements()
    if not page or not page:IsVisible() or #allItems == 0 then return end
    for _, b in ipairs(catButtons) do b:SetSelected(b.key == selected) end
    local c = Snapshot()
    leftView:Begin()
    rightView:Begin()
    if selected == "overview" then BuildOverview(c) else BuildCategory(selected, c) end
    local bottom = math.min(leftView:Render(VIEW_TOP), rightView:Render(VIEW_TOP))
    -- the page scrolls when a category is taller than the window
    content:SetHeight(-bottom + 10)
    local range = math.max(0, content:GetHeight() - scroll:GetHeight())
    scrollBar:SetMinMaxValues(0, range)
    scrollBar:SetShown(range > 0)
    if scrollBar:GetValue() > range then scrollBar:SetValue(range) end
end

function ns.BuildAchievementsTab(parent)
    page = parent
    scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -14, 0)
    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(ns.UI.width - 14, 10)
    scroll:SetScrollChild(content)
    scrollBar = CreateFrame("Slider", nil, page, ns.BACKDROP)
    scrollBar:SetPoint("TOPRIGHT", -4, -6)
    scrollBar:SetPoint("BOTTOMRIGHT", -4, 2)
    scrollBar:SetWidth(8)
    ns.Skin(scrollBar, ns.color.panel, ns.color.border)
    scrollBar:SetOrientation("VERTICAL")
    local thumb = scrollBar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(unpack(ns.color.gold))
    thumb:SetSize(6, 30)
    scrollBar:SetThumbTexture(thumb)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValue(0)
    scrollBar:SetScript("OnValueChanged", function(_, v) scroll:SetVerticalScroll(v) end)
    scrollBar:Hide()
    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", function(_, delta)
        local _, maxV = scrollBar:GetMinMaxValues()
        scrollBar:SetValue(math.max(0, math.min(maxV, scrollBar:GetValue() - delta * SCROLL_STEP)))
    end)
    leftView = ns.CreateLineView(content, ns.UI.pad, ns.UI.colW)
    rightView = ns.CreateLineView(content, ns.UI.col2X, ns.UI.colW)
    local shown = {}
    for _, def in ipairs(CATEGORIES) do
        if Applies(def.key) then shown[#shown + 1] = def end
    end
    local inner = ns.UI.width - ns.UI.pad * 2
    local w = math.floor((inner - (#shown - 1) * 3) / #shown)
    for i, def in ipairs(shown) do
        local b = ns.CreateButton(page, def.label, w, 20, function()
            selected = def.key
            scrollBar:SetValue(0) -- start each category at the top
            ns.RefreshAchievements()
        end)
        b.text:SetFont(ns.FONT, 10, "")
        b.key = def.key
        b:SetPoint("TOPLEFT", ns.UI.pad + (i - 1) * (w + 3), -4)
        catButtons[#catButtons + 1] = b
    end
    -- the categories are chosen in the shell's menu column (ns.AchievementsMenu)
    for _, b in ipairs(catButtons) do b:Hide() end
    page:SetScript("OnShow", ns.RefreshAchievements)
end

---------------------------------------------------------------------------
-- In the shell: the categories (earned / total in each), and the header
---------------------------------------------------------------------------
local function Earned(cat)
    local got, total = 0, 0
    for _, g in ipairs(cat and groups[cat] or {}) do
        for _, item in ipairs(g.items) do
            total = total + 1
            if Done(item) then got = got + 1 end
        end
    end
    return got, total
end

function ns.AchievementsMenu()
    local items = { { header = true, label = "Categories" } }
    for _, def in ipairs(CATEGORIES) do
        if Applies(def.key) then
            local got, total = Earned(def.key)
            items[#items + 1] = { label = def.label, selected = def.key == selected,
                                  count = total > 0 and format("%d/%d", got, total) or nil,
                                  onClick = function()
                                      selected = def.key
                                      if scrollBar then scrollBar:SetValue(0) end
                                      ns.RefreshAchievements()
                                  end }
        end
    end
    return items
end

function ns.AchievementsTitle()
    for _, def in ipairs(CATEGORIES) do
        if def.key == selected then return def.key == "overview" and "Achievements" or def.label end
    end
    return "Achievements"
end

function ns.AchievementsSummary()
    local got, total = 0, 0
    for _, item in ipairs(allItems) do
        total = total + 1
        if Done(item) then got = got + 1 end
    end
    return format("%d of %d earned  |cff777777-|r  milestones for levelling, questing, dungeons and more", got, total)
end

table.insert(ns.inits, function()
    Define()
    loginAt = GetTime()
    C_Timer.NewTicker(CHECK_SECONDS, function() pcall(Check) end)
    C_Timer.NewTicker(5, ns.RefreshAchievements)
    ns.On("PLAYER_XP_UPDATE", function() ns.RefreshAchievements() end)
    for _, event in ipairs({ "QUEST_TURNED_IN", "PLAYER_LEVEL_UP", "PLAYER_DEAD" }) do
        ns.On(event, function()
            heavy.at = 0 -- the slower checks are due too
            C_Timer.After(2, function() pcall(Check) end)
        end)
    end
    ns.On("ENCOUNTER_END", function(_, _, name, _, _, success)
        if success == 1 or success == true then OnBossKill(name) end
    end)
    ns.On("BOSS_KILL", function(_, _, name) OnBossKill(name) end)
end)
