local ADDON_NAME, ns = ...

-- What's new: the first time you load a new version, one window of what
-- changed, with a link to each new setting. /hb new shows it again.
--
-- Each release adds an entry at the top of ns.WHATS_NEW: its version and a few
-- items, each { title, text, settings = the Settings category to open }.
-- (Tests/build_release.py won't pack a version that has no entry here.)

local format = string.format

ns.WHATS_NEW = {
    { version = "0.9.9", items = {
        { "Refreshed levelling route",
          "Tonga's seed test and the oases in the Barrens no longer cross back and forth, Seer Graytongue comes during the Mulgore cougar hunt, Ashenvale Outrunners waits for your second Ashenvale visit, and the Dalaran traitors' chain (Prison Break In, Key to the City) is now on the route. Your place, skips and bookmarks carry over." },
        { "Camping 101 for your professions",
          "In the starting zones, the guide now offers each profession's Camping 101 quest, only if you have that profession and don't know its camp recipe yet." },
        { "Skyborne Druids",
          "The route now takes Skyborne Druids through the druid class quests the other druids get: Aquatic Form and Cure Poison." },
        { "Quests handed in on the spot",
          "Cloth donations, Scourgestones, Timbermaw feathers and other quests the game hands in straight from the giver's window now show as hand-in steps, instead of being passed by." },
    } },
    { version = "0.9.8", items = {
        { "Quests for every new dungeon",
          "The dungeon journal now lists the quests for The Drowned City, Krol'dok Stronghold, Alcaz Island Prison and Blackmaw Hold, and the missing ones for Excavation Site and Dalaran: who gives each one, where, and the rewards. A few givers aren't known yet and say so." },
        { "All of Ruins of Lordaeron in the guide",
          "The guide now runs Ruins of Lordaeron at 21, when the route is back by the Undercity, with The New Plague and (for the Undead) The Wrath of Rath'mael: the route picks up the quests they need first on the way, A Recipe For Death in Silverpine and Rear Guard Patrol in Tirisfal. The dungeon journal also says where a quest's \"do first\" chain starts." },
        { "Wailing Caverns with Leaders of the Fang",
          "The guide now waits for the Crossroads hand-in that opens Hamuul Runetotem's chain, so the Wailing Caverns run takes in Nara Wildmane and Leaders of the Fang too." },
    } },
    { version = "0.9.7", items = {
        { "Achievements in party and guild chat",
          "Each achievement you unlock can go to party chat while you're grouped, and to guild chat. Turn either one on or off in Pop-ups & extras.",
          settings = "extras" },
        { "Mischief achievements",
          "A new category for \"helping\" your party and guildmates: Blessing of Protection on someone who wanted to fight, Innervate on a warrior, Levitate on a party member, fearing the pull in a dungeon, a quick Vanish, rude emotes and duels won against your own guild. The post names who it was done to." },
    } },
    { version = "0.9.6", items = {
        { "Party guide sync",
          "Party members who have Hearthbound now see which guide step each other is on. The party leader gets a Sync button on the guide to bring everyone to the leader's step. Members are asked before their guide moves, or can choose to follow the leader without asking.",
          settings = "guide" },
        { "A new Horde route from 12 to 60",
          "Every starting zone now leads on to Silverpine Forest, then The Barrens. From 30 to 40 the route runs through Hillsbrad, Thousand Needles, Stranglethorn, Dustwallow, Arathi and the Badlands. There are more quests and less grinding, and your place in the guide carries over." },
        { "Dungeons in the guide",
          "The guide picks up dungeon quests on the way, sends you in at the right level and hands the quests in afterwards. Leave out a dungeon by right-clicking its step, or all of them with Skip dungeons.",
          settings = "guide" },
        { "Steadier zone changes",
          "Walking into a zone no longer moves the guide to a part of it well above your level." },
        { "Quieter card drops",
          "The \"New card\" line in chat can now be turned off.",
          settings = "cards" },
        { "This window",
          "After each update it shows once, with what's new. /hb new opens it again.",
          settings = "extras" },
    } },
}

local WIDTH = 440
local MAX_VERSIONS = 2 -- updating past several versions at once: the latest two
local frame

-- "0.9.6" -> is a newer than b? (anything that isn't a version counts as 0)
local function Parts(v)
    local out = {}
    for n in tostring(v or ""):gmatch("%d+") do out[#out + 1] = tonumber(n) end
    return out
end
local function Newer(a, b)
    local x, y = Parts(a), Parts(b)
    for k = 1, math.max(#x, #y) do
        local p, q = x[k] or 0, y[k] or 0
        if p ~= q then return p > q end
    end
    return false
end
ns.VersionNewer = Newer

local function IsVersion(v) return type(v) == "string" and v:match("^%d+%.%d+") ~= nil end

-- the entries to show: newer than seen, up to the running version (newest first)
function ns.WhatsNewEntries(seen, current)
    local out = {}
    for _, e in ipairs(ns.WHATS_NEW) do
        if (not seen or Newer(e.version, seen)) and not Newer(e.version, current) then
            out[#out + 1] = e
        end
    end
    table.sort(out, function(a, b) return Newer(a.version, b.version) end)
    while #out > MAX_VERSIONS do table.remove(out) end
    return out
end

local function Build()
    frame = CreateFrame("Frame", "HearthboundWhatsNew", UIParent, ns.BACKDROP)
    frame:SetWidth(WIDTH)
    frame:SetPoint("CENTER", 0, 60)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.97 }, ns.color.gold)
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)
    frame.title = ns.Text(frame, 15, ns.color.gold)
    frame.title:SetPoint("TOPLEFT", 14, -14)
    frame.lines = {}
    frame.ok = ns.CreateButton(frame, "Got it", 100, 24, function() frame:Hide() end)
    frame.ok:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.hint = ns.Text(frame, 10, ns.color.dim)
    frame.hint:SetPoint("BOTTOMLEFT", 14, 19)
    frame.hint:SetText("/hb new shows this again")
    table.insert(UISpecialFrames, "HearthboundWhatsNew") -- Escape closes it
    frame:Hide()
end

-- one line of the window: a heading, or an item's title (with its Settings
-- link) and text
local function Line(k)
    local l = frame.lines[k]
    if l then return l end
    l = {}
    l.title = ns.Text(frame, 12, ns.color.gold)
    l.title:SetJustifyH("LEFT")
    l.text = ns.Text(frame, 11, ns.color.text)
    l.text:SetWidth(WIDTH - 40)
    l.text:SetJustifyH("LEFT")
    l.link = CreateFrame("Button", nil, frame)
    l.link.text = ns.Text(l.link, 10, { 0.4, 0.8, 1, 1 })
    l.link.text:SetPoint("LEFT")
    l.link.text:SetText("Settings >")
    l.link:SetSize(l.link.text:GetStringWidth() + 4, 14)
    l.link:SetScript("OnClick", function(self)
        if self.key and ns.ShellOpen then ns.ShellOpen("settings", self.key) end
    end)
    frame.lines[k] = l
    return l
end

local function Show(entries)
    if not frame then Build() end
    frame.title:SetText(format("What's new in Hearthbound %s", entries[1].version))
    local y, k = 44, 0
    for n, e in ipairs(entries) do
        if n > 1 then
            k = k + 1
            local l = Line(k)
            l.title:ClearAllPoints()
            l.title:SetPoint("TOPLEFT", 14, -y)
            l.title:SetText("|cff999999Also in " .. e.version .. "|r")
            l.title:Show()
            l.text:Hide()
            l.link:Hide()
            y = y + 20
        end
        for _, item in ipairs(e.items) do
            k = k + 1
            local l = Line(k)
            l.title:ClearAllPoints()
            l.title:SetPoint("TOPLEFT", 14, -y)
            l.title:SetText("- " .. item[1])
            l.title:Show()
            l.link.key = item.settings
            l.link:ClearAllPoints()
            l.link:SetPoint("LEFT", l.title, "RIGHT", 8, 0)
            l.link:SetShown(item.settings ~= nil)
            l.text:ClearAllPoints()
            l.text:SetPoint("TOPLEFT", l.title, "BOTTOMLEFT", 9, -3)
            l.text:SetText(item[2] or "")
            l.text:Show()
            y = y + l.title:GetStringHeight() + 3 + l.text:GetStringHeight() + 10
        end
    end
    for n = k + 1, #frame.lines do
        local l = frame.lines[n]
        l.title:Hide()
        l.text:Hide()
        l.link:Hide()
    end
    frame:SetHeight(y + 44)
    frame:Show()
end

-- always: /hb new - this version's notes, even if they've been seen
function ns.ShowWhatsNew(always)
    local current = ns.version
    local entries
    if always then
        entries = ns.WhatsNewEntries(nil, IsVersion(current) and current or "999")
        while #entries > 1 do table.remove(entries) end
        if #entries == 0 then return ns.Print("Nothing new to show for this version.") end
    else
        if not (ns.db.whatsNew and IsVersion(current)) then return end
        entries = ns.WhatsNewEntries(ns.db.whatsNewSeen, current)
        ns.db.whatsNewSeen = current
        if #entries == 0 then return end
    end
    Show(entries)
end

-- after the other login windows, out of combat and away from the first-time setup
local function WhenFree(tries)
    if (InCombatLockdown and InCombatLockdown()) or (HearthboundSetupFrame and HearthboundSetupFrame:IsShown()) then
        if tries > 0 then C_Timer.After(10, function() WhenFree(tries - 1) end) end
        return
    end
    ns.ShowWhatsNew()
end

table.insert(ns.inits, function()
    -- a new player has nothing to catch up on: start counting from this version
    if ns.db.whatsNewSeen == nil and ns.freshInstall and IsVersion(ns.version) then
        ns.db.whatsNewSeen = ns.version
    end
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin, isReload)
        if not (isInitialLogin or isReload) then return end
        C_Timer.After(7, function() WhenFree(30) end)
    end)
end)
