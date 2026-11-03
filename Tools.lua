local ADDON_NAME, ns = ...

-- Tools: a text window (copy/paste), settings profiles (export / import as
-- text) and a debug report that gathers everything useful for fixing a
-- problem into one copyable block.

local format = string.format
local Safe = ns.Safe

---------------------------------------------------------------------------
-- Text window
---------------------------------------------------------------------------
local window

local function BuildWindow()
    window = CreateFrame("Frame", "HearthboundTextWindow", UIParent, ns.BACKDROP)
    window:SetSize(520, 380)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetToplevel(true)
    ns.Skin(window, { 0.05, 0.05, 0.06, 0.97 }, ns.color.gold)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)

    window.title = ns.Text(window, 14, ns.color.gold)
    window.title:SetPoint("TOPLEFT", 14, -12)
    window.hint = ns.Text(window, 10, ns.color.dim)
    window.hint:SetPoint("TOPLEFT", window.title, "BOTTOMLEFT", 0, -4)
    window.hint:SetWidth(490)
    window.hint:SetJustifyH("LEFT")

    local close = ns.CreateButton(window, "X", 22, 22, function() window:Hide() end)
    close:SetPoint("TOPRIGHT", -10, -10)

    local box = CreateFrame("Frame", nil, window, ns.BACKDROP)
    box:SetPoint("TOPLEFT", 12, -54)
    box:SetPoint("BOTTOMRIGHT", -12, 44)
    ns.Skin(box, ns.color.panel, ns.color.border)
    local scroll = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFont(ns.FONT, 11, "")
    edit:SetTextColor(unpack(ns.color.text))
    edit:SetWidth(450)
    edit:SetScript("OnEscapePressed", function() window:Hide() end)
    scroll:SetScrollChild(edit)
    box:EnableMouse(true)
    box:SetScript("OnMouseUp", function() edit:SetFocus() end)
    window.edit = edit

    window.apply = ns.CreateButton(window, "Apply", 110, 24, function()
        if window.onApply then window.onApply(window.edit:GetText()) end
    end)
    window.apply:SetPoint("BOTTOMRIGHT", -12, 12)
    window.selectAll = ns.CreateButton(window, "Select all", 110, 24, function()
        window.edit:SetFocus()
        window.edit:HighlightText()
    end)
    window.selectAll:SetPoint("BOTTOMLEFT", 12, 12)
    window:Hide()
end

-- onApply (optional): shows an Apply button that gets the text
function ns.ShowTextWindow(title, hint, text, onApply)
    if not window then BuildWindow() end
    window.title:SetText(title)
    window.hint:SetText(hint or "")
    window.edit:SetText(text or "")
    window.onApply = onApply
    window.apply:SetShown(onApply ~= nil)
    window:Show()
    window.edit:SetFocus()
    if text and text ~= "" then window.edit:HighlightText() end
end

---------------------------------------------------------------------------
-- Settings profiles
---------------------------------------------------------------------------
-- saved data that isn't a setting: left out of profiles
local NOT_SETTINGS = { trainer = true, xpTable = true, alts = true, journal = true, creatureInfo = true,
                       altQuests = true, collapsedSections = false }
local PREFIX = "HB1:"

local function Serialize(v)
    local t = type(v)
    if t == "string" then return format("%q", v) end
    if t == "number" or t == "boolean" then return tostring(v) end
    if t ~= "table" then return "nil" end
    local parts = {}
    for k, val in pairs(v) do
        local key = type(k) == "number" and ("[" .. k .. "]") or ("[" .. format("%q", tostring(k)) .. "]")
        parts[#parts + 1] = key .. "=" .. Serialize(val)
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

function ns.ExportSettings()
    local out = {}
    for key in pairs(ns.defaults) do
        if not NOT_SETTINGS[key] and ns.db[key] ~= nil then out[key] = ns.db[key] end
    end
    out.sectionOrder = ns.db.sectionOrder
    ns.ShowTextWindow("Export settings",
        "Copy this text (Ctrl+C) and keep it, or paste it into Import on another character.",
        PREFIX .. Serialize(out))
end

local function ImportSettings(text)
    text = strtrim(text or "")
    if text:sub(1, #PREFIX) ~= PREFIX then return ns.Print("That doesn't look like Hearthbound settings (it should start with " .. PREFIX .. ").") end
    local chunk = loadstring and loadstring("return " .. text:sub(#PREFIX + 1))
    if not chunk then return ns.Print("Couldn't read those settings - was the whole text pasted?") end
    if setfenv then setfenv(chunk, {}) end -- data only: no access to anything else
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= "table" then return ns.Print("Couldn't read those settings.") end
    local applied = 0
    for key, value in pairs(data) do
        local default = ns.defaults[key]
        if (default ~= nil and not NOT_SETTINGS[key] and type(value) == type(default)) or key == "sectionOrder" then
            ns.db[key] = value
            applied = applied + 1
        end
    end
    ns.RefreshAll()
    ns.Print(format("Imported %d settings. |cffc79c6e/reload|r to apply a new theme.", applied))
    if window then window:Hide() end
end

function ns.ImportSettingsWindow()
    ns.ShowTextWindow("Import settings", "Paste exported settings (Ctrl+V) and press Apply.", "", ImportSettings)
end

---------------------------------------------------------------------------
-- Debug report
---------------------------------------------------------------------------
local errors = {} -- recent Hearthbound errors, newest last
local MAX_ERRORS = 10

local function RecordError(msg)
    if type(msg) ~= "string" or not msg:find("Hearthbound") then return end
    errors[#errors + 1] = date("%H:%M:%S ") .. msg
    while #errors > MAX_ERRORS do table.remove(errors, 1) end
end
ns.RecordError = RecordError

function ns.DebugReport()
    local L = {}
    local function Add(fmt, ...) L[#L + 1] = format(fmt, ...) end
    local version, build, _, toc = GetBuildInfo()
    Add("Hearthbound %s - client %s (%s, interface %s) - %s", ns.version or "?", tostring(version), tostring(build), tostring(toc), date("%Y-%m-%d %H:%M"))
    local _, race = UnitRace("player")
    local _, class = UnitClass("player")
    if ns.PlayerSpec then
        local _, specLabel, specSource, specSpent = ns.PlayerSpec()
        Add("Spec: %s (%s), %s talent points spent", tostring(specLabel), tostring(specSource), tostring(specSpent))
    end
    Add("Character: level %d %s %s, %s, realm %s", UnitLevel("player"), tostring(race), tostring(class),
        tostring(UnitFactionGroup("player")), tostring(GetRealmName()))
    local mapID = Safe(C_Map.GetBestMapForUnit, "player")
    local continent = ns.PlayerWorldPos and ns.PlayerWorldPos()
    Add("Where: %s (map %s), in instance: %s, position known: %s", tostring(Safe(GetRealZoneText)), tostring(mapID),
        tostring(IsInInstance()), tostring(continent ~= nil))
    Add("Questie: %s", ns.QuestieStatus and ns.QuestieStatus() or "?")
    Add("Questie started: %s, QuestieDB loaded: %s", tostring(ns.QuestieReady and ns.QuestieReady()),
        tostring(rawget(_G, "LibQuestieDB") ~= nil))
    local st = ns.questieScanStats or {}
    Add("Quest scan: %s quests, %s named, %s with a giver, %s on a map", tostring(st.quests), tostring(st.named),
        tostring(st.withStarter), tostring(st.located))
    Add("Quest log: %d quests; QuestieDB objectives for them: %d", #(ns.openQuests or {}),
        #(ns.QuestObjectives and ns.QuestObjectives() or {}))
    local stats = ns.QuestStats and ns.QuestStats() or {}
    Add("Completed quests: %s (%s imported)", tostring(stats.count), tostring(stats.imported))
    local pins = rawget(_G, "LibStub") and LibStub("HereBeDragonsQuestie-Pins-2.0", true)
    Add("Map pins library: %s", pins and "found" or "missing")
    Add("Settings: theme %s, compact %s, pins %s, targets %s, auto accept %s, auto hand in %s",
        tostring(ns.db.theme), tostring(ns.db.compactPanel), tostring(ns.db.questPins), tostring(ns.db.showTargets),
        tostring(ns.db.autoAccept), tostring(ns.db.autoQuest))
    Add("")
    Add("Recent Hearthbound errors (%d):", #errors)
    if #errors == 0 then Add("  none this session") end
    for _, e in ipairs(errors) do Add("  %s", e:gsub("\n", " | ")) end
    ns.ShowTextWindow("Debug report", "Select all, copy (Ctrl+C) and paste it to whoever is helping you.", table.concat(L, "\n"))
end

table.insert(ns.inits, function()
    -- note our own errors as they happen (then pass them on as usual)
    if geterrorhandler and seterrorhandler then
        local previous = geterrorhandler()
        seterrorhandler(function(msg, ...)
            pcall(RecordError, msg)
            if previous then return previous(msg, ...) end
        end)
    end
end)
