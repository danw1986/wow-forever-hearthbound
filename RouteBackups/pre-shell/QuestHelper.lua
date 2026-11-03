local ADDON_NAME, ns = ...

-- Quest log helper: what's ready to hand in (grouped by zone), the best XP
-- quests, what's about to turn grey or too hard, and log space warnings.

local format = string.format
local Safe = ns.Safe

local MAX_NAMES = 3
local BEST_QUESTS = 5
local FULL_MARGIN = 2 -- warn when this close to a full quest log
local SOUND_WARN = SOUNDKIT and SOUNDKIT.TELL_MESSAGE or 3081

local COLORS = {
    impossible = "ff2020", hard = "ff8040", normal = "ffff00", easy = "40c040", trivial = "808080",
}

-- Classic's "grey level": quests (and mobs) at or below this give little XP
function ns.GrayLevel(level)
    if level <= 5 then return 0 end
    if level <= 39 then return level - math.floor(level / 10) - 5 end
    if level <= 59 then return level - math.floor(level / 5) - 1 end
    return level - 9
end

-- impossible / hard / normal / easy / trivial, like the quest log colours
function ns.QuestDifficulty(questLevel, playerLevel)
    local diff = questLevel - playerLevel
    if diff >= 5 then return "impossible" end
    if diff >= 3 then return "hard" end
    if diff >= -2 then return "normal" end
    if questLevel > ns.GrayLevel(playerLevel) then return "easy" end
    return "trivial"
end

local function Colored(q, playerLevel)
    -- ">3": this quest leads on to three more
    local chain = (q.id and ns.ChainMarker) and ns.ChainMarker(q.id) or ""
    if not q.level or q.level <= 0 then return q.title .. chain end
    local color = COLORS[ns.QuestDifficulty(q.level, playerLevel)]
    return format("|cff%s[%d] %s|r%s", color, q.level, q.title, chain)
end

local function Names(list, playerLevel)
    local parts = {}
    for i, q in ipairs(list) do
        if i > MAX_NAMES then
            parts[#parts + 1] = format("|cff999999+%d more|r", #list - MAX_NAMES)
            break
        end
        parts[#parts + 1] = Colored(q, playerLevel)
    end
    return table.concat(parts, "\n")
end

-- Ready quests grouped by quest log zone, biggest batch first
local function ReadyByZone(open)
    local byZone, zones = {}, {}
    for _, q in ipairs(open) do
        if q.complete then
            local zone = q.zone or "?"
            if not byZone[zone] then
                byZone[zone] = {}
                zones[#zones + 1] = zone
            end
            table.insert(byZone[zone], q)
        end
    end
    table.sort(zones, function(a, b) return #byZone[a] > #byZone[b] end)
    return zones, byZone
end

-- Quests to drop when the log is full: grey ones first, then the lowest XP
local function DropCandidates(open, level)
    local list = {}
    for _, q in ipairs(open) do
        if not q.complete and q.level and q.level > 0 then list[#list + 1] = q end
    end
    table.sort(list, function(a, b)
        local ga = ns.QuestDifficulty(a.level, level) == "trivial"
        local gb = ns.QuestDifficulty(b.level, level) == "trivial"
        if ga ~= gb then return ga end
        local xa, xb = a.xp or math.huge, b.xp or math.huge
        if xa ~= xb then return xa < xb end
        return a.level < b.level
    end)
    return list
end

ns.AddSection(22, function(add, level)
    if not ns.db.showQuestLog then return end
    local open = ns.openQuests or {}
    if #open == 0 then return end

    local zone = Safe(GetRealZoneText)
    local max = ns.MaxQuests()
    local here, soonGrey, grey, tooHard, best = 0, {}, {}, {}, {}
    local nextGray = ns.GrayLevel(level + 1)
    for _, q in ipairs(open) do
        if q.zone and q.zone == zone then here = here + 1 end
        if not q.complete and q.level and q.level > 0 then
            local difficulty = ns.QuestDifficulty(q.level, level)
            if difficulty == "trivial" then
                grey[#grey + 1] = q
            else
                if difficulty == "impossible" then
                    tooHard[#tooHard + 1] = q
                elseif q.level <= nextGray then
                    soonGrey[#soonGrey + 1] = q
                end
                if q.xp then best[#best + 1] = q end
            end
        end
    end

    add.header("Quest log")
    local full = #open >= max - FULL_MARGIN
    local countColor = full and "ff5544" or "ffffff"
    add.row("Open quests", format("|cff%s%d/%d|r  |cff999999(%d in this zone)|r", countColor, #open, max, here))
    if full then
        local drop = DropCandidates(open, level)
        add.note("|cffff5544Log almost full - consider dropping:|r")
        if #drop > 0 then add.note(Names(drop, level)) end
    end

    local zones, byZone = ReadyByZone(open)
    for _, z in ipairs(zones) do
        local marker = z == zone and " |cff999999(here)|r" or ""
        add.row("Hand in: " .. z .. marker, format("|cff6fdc6f%d ready|r", #byZone[z]))
    end

    if ns.db.showQuestXP and #best > 0 then
        table.sort(best, function(a, b) return a.xp > b.xp end)
        add.header("Best XP quests")
        for i = 1, math.min(BEST_QUESTS, #best) do
            add.row(Colored(best[i], level), format("%s xp", ns.Comma(best[i].xp)))
        end
    end

    if #soonGrey > 0 then
        add.note("|cffffd200Going grey at level " .. (level + 1) .. " - do these first:|r")
        add.note(Names(soonGrey, level))
    end
    if #grey > 0 then
        add.note("|cff999999Grey now, little XP:|r")
        add.note(Names(grey, level))
    end
    if #tooHard > 0 then
        add.note("|cffff5544Too hard to solo for now:|r")
        add.note(Names(tooHard, level))
    end
end)

---------------------------------------------------------------------------
-- Leaving a zone with quests still to hand in there
---------------------------------------------------------------------------
local lastZone

local function OnZoneChanged()
    local zone = Safe(GetRealZoneText)
    if lastZone and zone ~= lastZone and ns.db.showQuestLog then
        local left = {}
        for _, q in ipairs(ns.openQuests or {}) do
            if q.complete and q.zone == lastZone then left[#left + 1] = q.title end
        end
        if #left > 0 then
            ns.Print(format("|cffffd200You left %s with %d quest%s to hand in:|r %s",
                lastZone, #left, #left == 1 and "" or "s", table.concat(left, ", ")))
            ns.PlaySound(SOUND_WARN)
        end
    end
    lastZone = zone
end

table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", function() lastZone = Safe(GetRealZoneText) end)
    ns.On("ZONE_CHANGED_NEW_AREA", OnZoneChanged)
end)
