local ADDON_NAME, ns = ...

local GetMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
ns.version = GetMeta and GetMeta(ADDON_NAME, "Version") or "dev"

ns.defaults = {
    xp = true,
    xpScale = 1,
    showTrainer = true,
    showUpcoming = true,
    upcomingLevels = 3,
    showQuests = true,
    showGear = true,
    showHistory = true,
    showGold = true,
    bagGoldTooltip = true,
    questItemTips = true,
    mobQuestTips = true,
    questLinkLabels = true,
    questPins = true,
    showTargets = true,
    targetSkull = true,
    targetsYards = 350, -- the quest targets window only lists mobs this close (or in sight)
    targetsNpcs = true, -- ...and NPCs you can pick a quest up from or hand one in to
    showObjectives = true,
    showGrind = true,
    autoSell = true,
    showRoad = true,
    showQuestLog = true,
    showZones = true,
    compactPanel = false,
    theme = "warrior",
    panelOpacity = 0.92,
    questXPPreview = true,
    blizzQuestXP = true, -- the same gold on the game's own XP bar
    cards = true,      -- collect a card for every different enemy you defeat
    cardPopups = true, -- show each new card as it's collected
    cardSounds = true,     -- a sound when a card drops and when you take it
    cardTooltips = true,   -- enemy tooltips say whether you have its card
    cardsAutoClaim = false, -- cards go straight to the collection, without looting
    minimapRing = true,
    welcomeBack = true,
    rewardPicker = true,
    rewardAutoPick = false,
    talentReminder = true,
    weaponSkillTips = true,
    leaveTownAlert = true,
    showLeftBehind = false, -- the Left behind section in the panel (the alert and /hb left don't need it)
    showTravel = true,
    mobXPTips = true,
    showSupplies = true,
    quickButtons = true, -- buttons along the bottom of the panel
    combatHide = false, -- step aside in combat (the Cooldown Manager covers fights)
    combatFade = true,  -- fade rather than hide
    collapsedSections = {}, -- lowercase heading -> true
    expandedSections = {},  -- lowercase heading -> true: show past the line limit
    sectionMaxLines = 6,    -- lines per panel section before "+N more" (0: no limit)
    panelMaxHeight = 600,   -- the panel scrolls past this
    showDungeons = true,
    showQuestXP = true,
    restedTip = true,
    autoQuest = true,  -- hand in finished quests
    autoAccept = true, -- pick up new quests
    autoQuestSkipGrey = true,
    autoRepair = true,
    announceParty = true,
    announceXP = true,
    toasts = true,
    announceGuild = false, -- post milestones to guild chat
    screenshots = true,
    showMinimap = true,
    minimapAngle = 220,
    guide = true,      -- the levelling guide window
    guideArrow = true, -- its arrow
    guideHearthHint = true, -- "Hearth to Ratchet: saves about 6 min" when hearthing is quicker
    guidePanel = true, -- the current step in the panel
    guideEdition = "horde",
    guideSkipGrey = true, -- the guide passes quests too low to give you real XP
    guideAdaptive = true,    -- the guide sends you to quests in your log you can get on with nearby
    guideClassQuests = true, -- and shows your class quests
    guideAdaptYards = 300,   -- how near "nearby" is
    guideNearYards = 80,     -- route steps you can do this close by become the step to do
    guideLearn = true,       -- write down quest offers, XP and levels as you play (GuideLearn.lua)
    guideSkipLowValue = false, -- pass by quests marked optional (a long walk for their XP)
    guideItemButton = true,    -- a button for the item the current step needs you to use
    guideZonePrompt = true,  -- ask to switch sections when you arrive in a new zone
    guideAutoZone = true,    -- ...or just switch, following the zone you're in
    guideStepPopup = true,   -- a short note on screen when the guide moves on
    guideCompact = false,    -- the guide window shows only the current step
    hbPlates = true,          -- nameplates drawn in the addon's style (NamePlates.lua)
    threatPlates = true,         -- a threat bar under enemy nameplates in combat
    threatHealth = true,         -- ...and the health bar in its colour, so aggro shows at a glance
    hideFrameThreat = true,      -- hide the game's red threat glow on your own unit frames
    threatPlatesText = true,     -- ...your threat % beside it, in a group
    threatPlatesDebuffs = false, -- your own debuffs above the name, instead of the game's
    guideListLayout = false, -- the old guide window (a list of steps) instead of just the current step
    guideScale = 1,          -- the guide window's size
    guideCardBelow = false,  -- the current step's panel under the window (not on top)
    guideStepFont = 12,      -- the current step's text size
    guideUpcoming = 4,       -- steps listed after the current one
    guideTypeColours = true, -- the step panel coloured by the kind of step
    guideStepNumbers = true, -- step numbers on the steps
    guideMapPins = true,     -- the next steps on the world map and minimap, joined by a trail
    guideSkipGroup = false,  -- leave out group (elite) quests
    guideSkipDungeons = false, -- leave out dungeon steps
    guideNever = {},         -- quest ID -> true: quests you've chosen never to do
    positions = {},
    trainer = {}, -- class -> skill list read from the class trainer
    xpTable = {}, -- level -> XP needed, as reported by the client
    alts = {},    -- "Name-Realm" -> snapshot of each character
}

-- settings from earlier versions that no longer exist
local OBSOLETE = {
    "greet", "sound", "overpower", "execute", "swing", "swingOffhand", "swingQueue",
    "watchShout", "watchRend", "watchHamstring", "watchCombatOnly", "hudScale",
    "guideArrowFlip", -- the arrow image itself was turned round instead
}

ns.inits = {}      -- run once saved variables are ready
ns.refreshers = {} -- run whenever a setting changes
ns.unlocked = false

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local handlers = {}
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    for _, fn in ipairs(handlers[event]) do
        fn(event, ...)
    end
end)

-- Returns false if this client doesn't know the event (registering an unknown
-- event throws on the Forever client)
function ns.On(event, fn)
    if not handlers[event] then
        if not pcall(eventFrame.RegisterEvent, eventFrame, event) then
            return false
        end
        handlers[event] = {}
    end
    table.insert(handlers[event], fn)
    return true
end

function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffc79c6eHearthbound|r: " .. tostring(msg))
end

function ns.RefreshAll()
    for _, fn in ipairs(ns.refreshers) do
        fn()
    end
end

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

-- a spell's icon - just the icon (newer clients also return the original icon,
-- which mustn't end up as a size somewhere)
function ns.SpellIcon(spell)
    if C_Spell and C_Spell.GetSpellTexture then return (C_Spell.GetSpellTexture(spell)) end
    return GetSpellTexture and (GetSpellTexture(spell)) or nil
end

function ns.PlaySound(id)
    if id then pcall(PlaySound, id, "Master") end
end

---------------------------------------------------------------------------
-- Secret values: Warcraft Forever uses the retail addon rules, where some
-- data is hidden from addons and touching it raises an error.
---------------------------------------------------------------------------
local issecretvalue = issecretvalue

function ns.IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) == true
end

-- checks the results where they are, so nothing is left behind for the
-- garbage collector (Safe runs many times a second)
local function Collect(ok, ...)
    if not ok then return end
    for i = 1, select("#", ...) do
        if ns.IsSecret((select(i, ...))) then return end
    end
    return ...
end

-- Calls fn; returns its results only if it succeeded and none of them are secret
function ns.Safe(fn, ...)
    if not fn then return end
    return Collect(pcall(fn, ...))
end

---------------------------------------------------------------------------
-- Movable frames
---------------------------------------------------------------------------
ns.movers = {}

function ns.RestorePosition(f)
    local pos = ns.db.positions[f.moverKey] or f.moverDefault
    f:ClearAllPoints()
    f:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
end

function ns.RegisterMover(f, key, label, point, relPoint, x, y)
    f.moverKey = key
    f.moverDefault = { point, relPoint, x, y }
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:EnableMouse(false)
    f:SetScript("OnDragStart", function(self)
        if ns.unlocked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, px, py = self:GetPoint()
        ns.db.positions[key] = { p, rp, px, py }
    end)

    local ov = CreateFrame("Frame", nil, f, ns.BACKDROP)
    ov:SetAllPoints()
    ov:SetFrameLevel(f:GetFrameLevel() + 20)
    ns.Skin(ov, { 0.78, 0.16, 0.12, 0.18 }, { 0.78, 0.16, 0.12, 0.9 })
    local text = ns.Text(ov, 11, ns.color.gold, "OUTLINE")
    text:SetPoint("BOTTOM", ov, "TOP", 0, 3)
    text:SetText(label .. "  |cff999999(drag to move)|r")
    ov:Hide()
    f.moverOverlay = ov

    table.insert(ns.movers, f)
    ns.RestorePosition(f)
end

function ns.SetUnlocked(unlocked)
    ns.unlocked = unlocked
    for _, f in ipairs(ns.movers) do
        f:EnableMouse(unlocked)
        f.moverOverlay:SetShown(unlocked)
    end
    if unlocked then
        ns.Print("Frames unlocked. Drag them where you like, then lock them again (/hb lock).")
    end
    ns.RefreshAll()
end

function ns.ResetPositions()
    wipe(ns.db.positions)
    for _, f in ipairs(ns.movers) do
        ns.RestorePosition(f)
    end
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------
-- WoW Forever gives characters a first and a last name ("Falling Moon"), and
-- two characters can share a first name, so everything per character is
-- filed under the full name. UnitNameUnmodified returns the surname second
-- (Forever's AceDB does the same).
function ns.FullName()
    local ok, name, surname = pcall(UnitNameUnmodified, "player")
    if not ok or type(name) ~= "string" or ns.IsSecret(name) then name, surname = UnitName("player"), nil end
    name = name or "?"
    if type(surname) == "string" and surname ~= "" and not ns.IsSecret(surname) then
        return name .. " " .. surname, name, surname
    end
    return name, name, nil
end

-- "Falling Moon-Realm": this character's key in account-wide tables
function ns.CharKey()
    return ns.FullName() .. "-" .. (GetRealmName() or "?")
end

-- the key earlier versions used ("Falling-Realm"), which two Fallings shared
function ns.OldCharKey()
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

local function Owner()
    return ns.CharKey()
end

-- The Forever beta writes saved variables on exit but never loads them back.
-- The backup script copies them into Seed.lua, so restore from there when the
-- client gave us nothing.
local function RestoreFromSeed()
    local restored = false
    if HearthboundDB == nil and type(HearthboundSeedDB) == "table" then
        HearthboundDB = HearthboundSeedDB
        restored = true
    end
    if HearthboundCharDB == nil and type(HearthboundSeedChars) == "table" then
        -- each entry is { folder = "<WTF character folder>", data = <saved table> }
        local me, old = Owner(), ns.OldCharKey()
        local _, myName, surname = ns.FullName()
        -- the game's folder for a Forever character is "Falling-Moon"
        local myFolder = surname and (myName .. "-" .. surname) or myName
        for _, entry in ipairs(HearthboundSeedChars) do
            local data = type(entry) == "table" and entry.data
            if type(data) == "table" then
                local folder = entry.folder or ""
                local folderMatch = folder == myFolder
                    or (not surname and folder:sub(1, #myName + 1) == myName .. "-")
                -- saved under the full name, or (older saves, shared first name) in this character's own folder
                local mine = data.owner == me or ((data.owner == nil or data.owner == old) and folderMatch)
                if mine then
                    HearthboundCharDB = data
                    restored = true
                end
            end
        end
    end
    HearthboundSeedDB, HearthboundSeedChars = nil, nil
    return restored
end

ns.On("ADDON_LOADED", function(_, name)
    if name ~= ADDON_NAME then return end
    ns.restoredFromBackup = RestoreFromSeed()
    HearthboundDB = HearthboundDB or {}
    for _, key in ipairs(OBSOLETE) do HearthboundDB[key] = nil end
    if HearthboundDB.positions then HearthboundDB.positions.hud = nil end
    -- auto accept used to share one setting with hand-ins: start it the same way
    if HearthboundDB.autoAccept == nil and HearthboundDB.autoQuest ~= nil then
        HearthboundDB.autoAccept = HearthboundDB.autoQuest
    end
    CopyDefaults(ns.defaults, HearthboundDB)
    -- the panel used to fade in combat by default; switch that off once for existing settings
    if not HearthboundDB.combatFadeOffApplied then
        HearthboundDB.combatHide = false
        HearthboundDB.combatFadeOffApplied = true
    end
    HearthboundCharDB = HearthboundCharDB or {}
    HearthboundCharDB.owner = Owner() -- lets the backup find this character's data
    ns.db, ns.cdb = HearthboundDB, HearthboundCharDB
    if ns.ApplyTheme then ns.ApplyTheme(ns.db.theme) end -- before any frame is built

    for _, fn in ipairs(ns.inits) do
        fn()
    end
end)

ns.On("PLAYER_LOGIN", function()
    ns.Print("v" .. ns.version .. " loaded. Type |cffc79c6e/hb|r for settings.")
    if ns.restoredFromBackup then
        ns.Print("Restored your data from the backup. Run |cffc79c6eBackup Hearthbound.bat|r after each session to keep it.")
    end
end)

-- /hb mem: this addon's memory, before and after a full clean-up, then
-- how fast it grows over ten seconds. Memory that climbs and then drops back
-- is normal (Lua tidies up in batches); a leak keeps climbing after a clean-up.
local function AddonMemory()
    local update = (C_AddOns and C_AddOns.UpdateAddOnMemoryUsage) or UpdateAddOnMemoryUsage
    local get = (C_AddOns and C_AddOns.GetAddOnMemoryUsage) or GetAddOnMemoryUsage
    if not (update and get) then return nil end
    update()
    return get(ADDON_NAME)
end

function ns.MemoryReport()
    local before = AddonMemory()
    if not before then return ns.Print("This client doesn't report addon memory.") end
    collectgarbage("collect")
    local after = AddonMemory()
    ns.Print(format("Memory: %.0f KB, %.0f KB after a clean-up. Measuring for 10 seconds...", before, after))
    C_Timer.After(10, function()
        local now = AddonMemory()
        collectgarbage("collect")
        local kept = AddonMemory()
        ns.Print(format("Grew %.1f KB/s while running (normal working churn). After a clean-up: %.0f KB (%+.0f KB kept).",
            (now - after) / 10, kept, kept - after))
        ns.Print("If the kept figure keeps rising each time you run this, that's a leak - tell me which windows were open.")
    end)
end

SLASH_HEARTHBOUND1 = "/hb"
SlashCmdList.HEARTHBOUND = function(input)
    local raw = strtrim(input or "")
    local cmd = raw:lower()
    if cmd == "goal" or cmd:find("^goal ") then
        return ns.SetGoal(raw:sub(6))
    end
    if cmd == "lock" then
        ns.SetUnlocked(false)
    elseif cmd == "unlock" then
        ns.SetUnlocked(true)
    elseif cmd == "reset" then
        ns.ResetPositions()
        ns.Print("Frame position reset.")
    elseif cmd == "xpreset" then
        ns.ResetXPSession()
    elseif cmd == "quests" then
        ns.ToggleOptions("quests")
    elseif cmd == "achievements" then
        ns.ToggleOptions("achievements")
    elseif cmd == "stats" or cmd == "journey" or cmd == "alts" or cmd == "dungeons" then
        ns.ToggleOptions(cmd)
    elseif cmd == "toast" then
        ns.TestToast()
    elseif cmd == "mapprobe" then
        ns.MapProbe()
    elseif cmd == "artprobe" then
        ns.ArtProbe()
    elseif cmd == "left clear" then
        ns.ClearLeftBehind()
    elseif cmd == "left" or cmd:find("^left %d+$") then
        ns.MarkLeftBehind(tonumber(cmd:match("%d+")))
    elseif cmd == "cards debug" then
        ns.CardsDebug()
    elseif cmd == "plates debug" then
        if ns.ThreatPlatesDebug then ns.ThreatPlatesDebug() end
    elseif cmd == "plates test" or cmd == "plates" then
        if ns.ThreatPlatesTest then ns.ThreatPlatesTest() end
    elseif cmd == "cards" then
        ns.ToggleCards()
    elseif cmd == "learn" then
        if ns.LearnStatus then ns.LearnStatus() end
    elseif cmd == "mark clear" or cmd == "unmark" then
        if ns.ClearGuideMarker then ns.ClearGuideMarker() end
    elseif cmd == "setup" then
        ns.ShowSetup()
    elseif cmd == "mem" or cmd == "memory" then
        ns.MemoryReport()
    elseif cmd == "debug" then
        ns.DebugReport()
    elseif cmd == "export" then
        ns.ExportSettings()
    elseif cmd == "import" then
        ns.ImportSettingsWindow()
    elseif cmd == "accept" then
        ns.db.autoAccept = not ns.db.autoAccept
        ns.Print("Auto accept quests: " .. (ns.db.autoAccept and "|cff6fdc6fon|r" or "|cffff5544off|r"))
        ns.RefreshAll()
    elseif cmd == "targets debug" then
        ns.QuestTargetsProbe()
    elseif cmd == "targets" then
        ns.ToggleQuestTargets()
    elseif cmd == "nearby" then
        ns.NearbyProbe()
    elseif cmd == "questie" then
        ns.Print(ns.QuestieStatus())
    elseif cmd == "summary" then
        ns.PrintSessionSummary()
    elseif cmd == "last" then
        if ns.cdb.lastSession then
            ns.PrintSessionSummary(ns.cdb.lastSession, "Last session")
        else
            ns.Print("No previous session recorded yet.")
        end
    elseif cmd == "guide" or cmd:find("^guide ") then
        ns.GuideCommand(cmd:sub(7))
    elseif cmd == "spec" or cmd:find("^spec ") then
        ns.SpecCommand(cmd:sub(6))
    elseif cmd == "help" then
        ns.Print("/hb spec | spec <name> | spec auto - the spec rewards and talent advice follow")
        ns.Print("/hb - open settings")
        ns.Print("/hb setup - run the first-time setup again")
        ns.Print("/hb cards - your enemy card collection, zone by zone")
        ns.Print("/hb plates test - your target's nameplate shows each threat colour in turn")
        ns.Print("/hb left | left 2 | left clear - quests you walked away from: list, mark one, empty")
        ns.Print("/hb quests - open your completed quest log")
        ns.Print("/hb stats - session, XP sources and best mobs")
        ns.Print("/hb journey | alts - road to 60, milestones, deaths | your characters")
        ns.Print("/hb achievements - every milestone and how close you are")
        ns.Print("/hb dungeons - dungeon journal: quests, map markers and loot")
        ns.Print("/hb goal 30 | goal Redridge Mountains | goal - set or clear a session goal")
        ns.Print("/hb accept - turn auto accepting quests on or off")
        ns.Print("/hb guide - show or hide the levelling guide")
        ns.Print("/hb guide find | arrow | reset | 120 - find your place, arrow on/off, start over, go to step 120")
        ns.Print("/hb guide zones | here - pick a section to follow | jump to the zone you're in")
        ns.Print("/hb guide route - the route overview: every zone with its levels and progress, to follow or skip")
        ns.Print("/hb guide search wolf - find the steps for a quest, NPC or place")
        ns.Print("/hb guide back - back to the zone you were following before, where you left off")
        ns.Print("/hb guide unskip - bring back every quest step you've skipped")
        ns.Print("/hb guide unremove - put back every quest you removed from the route")
        ns.Print("/hb guide tidy - quests in your log the route doesn't use (and grey ones), to abandon")
        ns.Print("/hb learn - what the guide has learned from your play (quest chains, XP, time per level)")
        ns.Print("/hb mark clear - remove Hearthbound's map marker")
        ns.Print("/hb guide grey - skip or show quests too low to give you XP")
        ns.Print("/hb guide compact | unskip - current step only | stop skipping right-clicked quests")
        ns.Print("/hb guide arrow debug | flip - what the arrow sees | turn it round if it points backwards")
        ns.Print("/hb debug | export | import - debug report, settings profiles")
        ns.Print("/hb mem - this addon's memory and whether it's really growing")
        ns.Print("/hb targets - show or hide the quest targets window")
        ns.Print("/hb targets debug - list what the quest targets window can see")
        ns.Print("/hb nearby - check why the Nearby quest list is empty (target a quest giver first)")
        ns.Print("/hb toast - preview a milestone pop-up")
        ns.Print("/hb summary | last - this or the previous session in chat")
        ns.Print("/hb unlock | lock - move the XP tracker")
        ns.Print("/hb reset - reset its position")
        ns.Print("/hb xpreset - restart the XP session")
    else
        ns.ToggleOptions()
    end
end
