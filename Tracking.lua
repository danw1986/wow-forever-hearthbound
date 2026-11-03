local ADDON_NAME, ns = ...

-- Small counters for achievements: the dungeon run you're on, loot quality,
-- jumps, flights, hearthstones, discoveries, emotes, drunkenness and AFK time.
-- All counted from when this was added.

local Safe = ns.Safe

local HEARTHSTONE = 8690
local AFK_LEGEND_SECONDS = 1800
local RUN_FORGET_SECONDS = 3 * 3600 -- a run you left this long ago is over

local function Add(key, n)
    ns.cdb[key] = (ns.cdb[key] or 0) + (n or 1)
end

-- a global format string like "You receive loot: %s." -> a Lua pattern
local function Pattern(fmt)
    if type(fmt) ~= "string" then return nil end
    local p = fmt:gsub("[%%%(%)%.%+%-%*%?%[%]%^%$]", "%%%0") -- escape everything special, % included
    p = p:gsub("%%%%s", "(.+)"):gsub("%%%%d", "(%%d+)")
    return "^" .. p .. "$"
end

---------------------------------------------------------------------------
-- The dungeon run you're on: when you went in and the deaths so far
---------------------------------------------------------------------------
local function CurrentDungeon()
    local inInstance, kind = IsInInstance()
    if not inInstance or (kind ~= "party" and kind ~= "raid") then return nil end
    local ok, name = pcall(GetInstanceInfo)
    if not ok or type(name) ~= "string" or ns.IsSecret(name) then return nil end
    return ns.DungeonKeyForName(name), name
end

local function OnZone()
    local key = CurrentDungeon()
    local run = ns.cdb.dungeonRun
    if key then
        -- the same run if you're coming back in (after a death or a zone-out)
        if not (run and run.key == key and time() - (run.left or run.start) < RUN_FORGET_SECONDS) then
            ns.cdb.dungeonRun = { key = key, start = time() }
        else
            run.left = nil
        end
    elseif run and not run.left then
        run.left = time()
    end
end

-- How the run that just ended went: { seconds, deaths } (nil if not tracked)
function ns.DungeonRunResult(key)
    local run = ns.cdb.dungeonRun
    if not run or run.key ~= key then return nil end
    local deaths = 0
    for _, d in ipairs(ns.cdb.deaths or {}) do
        if d.time >= run.start then deaths = deaths + 1 end
    end
    return { seconds = time() - run.start, deaths = deaths }
end

---------------------------------------------------------------------------
-- Loot: blue and purple items you loot yourself
---------------------------------------------------------------------------
local lootPatterns
local QUALITY_BY_COLOR = { ["0070dd"] = "rare", ["a335ee"] = "epic", ["ff8000"] = "legendary" }

local function OnLoot(_, msg)
    if type(msg) ~= "string" or ns.IsSecret(msg) then return end
    if not lootPatterns then
        lootPatterns = {}
        for _, g in ipairs({ LOOT_ITEM_SELF, LOOT_ITEM_SELF_MULTIPLE }) do
            local p = Pattern(g)
            if p then lootPatterns[#lootPatterns + 1] = p end
        end
    end
    for _, p in ipairs(lootPatterns) do
        local item = msg:match(p)
        if item then
            local color = item:match("|c%x%x(%x%x%x%x%x%x)")
            local quality = color and QUALITY_BY_COLOR[color:lower()]
            if quality == "rare" then Add("lootRare") end
            if quality == "epic" or quality == "legendary" then Add("lootEpic") end
            return
        end
    end
end

---------------------------------------------------------------------------
-- Flights, hearthstones, discoveries, emotes, drink and AFK
---------------------------------------------------------------------------
local onTaxi = false
local function CheckTaxi()
    local now = Safe(UnitOnTaxi, "player") == true
    if now and not onTaxi then Add("flights") end
    onTaxi = now
end

local function OnSpell(_, unit, _, spellID)
    if unit == "player" and not ns.IsSecret(spellID) and spellID == HEARTHSTONE then Add("hearths") end
end

local discoverPatterns, drunkMessages
local function OnSystem(_, msg)
    if type(msg) ~= "string" or ns.IsSecret(msg) then return end
    if not discoverPatterns then
        discoverPatterns = {}
        for _, g in ipairs({ ERR_ZONE_EXPLORED_XP, ERR_ZONE_EXPLORED }) do
            local p = Pattern(g)
            if p then discoverPatterns[#discoverPatterns + 1] = p end
        end
        drunkMessages = {}
        for _, g in ipairs({ DRUNK_MESSAGE_SELF2, DRUNK_MESSAGE_SELF3, DRUNK_MESSAGE_SELF4 }) do
            if type(g) == "string" then drunkMessages[g] = true end
        end
    end
    for _, p in ipairs(discoverPatterns) do
        if msg:match(p) then
            Add("discoveries")
            return
        end
    end
    if drunkMessages[msg] then ns.cdb.achDrunk = true end
end

local afkSince
local function CheckAFK()
    local afk = Safe(UnitIsAFK, "player") == true
    if afk and not afkSince then afkSince = time() end
    if not afk then afkSince = nil end
    if afkSince and time() - afkSince >= AFK_LEGEND_SECONDS then ns.cdb.achAFK = true end
end

table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", OnZone)
    ns.On("ZONE_CHANGED_NEW_AREA", OnZone)
    ns.On("CHAT_MSG_LOOT", OnLoot)
    ns.On("UNIT_SPELLCAST_SUCCEEDED", OnSpell)
    ns.On("CHAT_MSG_SYSTEM", OnSystem)
    ns.On("UI_INFO_MESSAGE", function(_, _, msg) OnSystem(nil, msg) end)
    ns.On("PLAYER_FLAGS_CHANGED", CheckAFK)
    C_Timer.NewTicker(2, CheckTaxi)
    C_Timer.NewTicker(30, CheckAFK)
    -- jumps and emotes: watch the game's own functions (doesn't change them)
    if JumpOrAscendStart then hooksecurefunc("JumpOrAscendStart", function() Add("jumps") end) end
    if DoEmote then
        hooksecurefunc("DoEmote", function(token)
            if type(token) == "string" and token:upper() == "DANCE" then Add("dances") end
        end)
    end
end)
