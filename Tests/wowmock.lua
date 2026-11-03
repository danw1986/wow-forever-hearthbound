-- A small fake of the WoW UI API: enough frames, textures and font strings
-- (with sizes, text, scripts and visibility) to load the whole addon and
-- drive its windows outside the game. Unknown globals are harmless stubs.
MOCK = { frames = {}, timers = {}, tickers = {}, errors = {}, printed = {} }

local stubMT = {}
local function stub() return setmetatable({}, stubMT) end
stubMT.__index = function(t, k)
    if type(k) == "number" then return nil end
    local s = stub()
    rawset(t, k, s)
    return s
end
stubMT.__call = function() return nil end

local Obj = {}
local ObjMT = {
    __index = function(self, k)
        local m = Obj[k]
        if m then return m end
        -- any other method (WoW's are capitalised) does nothing; an unset field is nil
        if type(k) == "string" and k:match("^%u") then return function() return nil end end
        return nil
    end,
}

local function New(kind, parent, name)
    local o = setmetatable({ _kind = kind, _parent = parent, _shown = true, _w = 0, _h = 0, _scripts = {}, _children = {},
                             _name = name, _alpha = 1, _level = 1 }, ObjMT)
    if parent and rawget(parent, "_children") then table.insert(parent._children, o) end
    table.insert(MOCK.frames, o)
    return o
end
MOCK.New = New

function Obj:SetSize(w, h) self._w, self._h = w or 0, h or 0 end
function Obj:SetWidth(w) self._w = w or 0 end
function Obj:SetHeight(h) self._h = h or 0 end
function Obj:GetWidth() return self._w or 0 end
function Obj:GetHeight() return self._h or 0 end
function Obj:GetSize() return self._w or 0, self._h or 0 end
function Obj:Show()
    local was = self:IsVisible()
    self._shown = true
    if not was and self:IsVisible() then MOCK.FireShow(self) end
end
function Obj:Hide() self._shown = false end
function Obj:SetShown(v) if v then self:Show() else self:Hide() end end
function Obj:IsShown() return self._shown end
function Obj:IsVisible()
    if not self._shown then return false end
    if self._parent and self._parent ~= UIParent then return self._parent:IsVisible() end
    return true
end
function Obj:SetParent(p) self._parent = p end
function Obj:GetParent() return self._parent end
function Obj:SetScript(k, fn) self._scripts[k] = fn end
function Obj:GetScript(k) return self._scripts[k] end
function Obj:HookScript(k, fn)
    local old = self._scripts[k]
    self._scripts[k] = function(...) if old then old(...) end fn(...) end
end
function Obj:CreateTexture() return New("Texture", self) end
function Obj:CreateAnimationGroup() return New("AnimationGroup", self) end
function Obj:CreateAnimation() return New("Animation", self) end
function Obj:CreateMaskTexture() return New("MaskTexture", self) end
function Obj:CreateFontString() return New("FontString", self) end
function Obj:SetText(t) self._text = t end
function Obj:GetText()
    if self._kind == "EditBox" then return self._text or "" end
    return self._text
end
function Obj:GetStringWidth() return #(tostring(self._text or "")) * 6 end
function Obj:GetStringHeight() return 12 end
function Obj:GetPoint() return "CENTER", UIParent, "CENTER", 0, 0 end
function Obj:GetFrameLevel() return self._level end
function Obj:SetFrameLevel(l) self._level = l end
function Obj:GetScale() return self._scale or 1 end
function Obj:SetScale(s) self._scale = s end
function Obj:GetEffectiveScale() return 1 end
function Obj:IsMouseOver() return false end
function Obj:GetVerticalScroll() return self._vs or 0 end
function Obj:SetVerticalScroll(v) self._vs = v end
function Obj:GetMinMaxValues() return self._min or 0, self._max or 0 end
function Obj:SetMinMaxValues(a, b) self._min, self._max = a, b end
function Obj:GetValue() return self._value or 0 end
function Obj:SetValue(v)
    self._value = v
    if self._scripts.OnValueChanged then self._scripts.OnValueChanged(self, v, true) end
end
function Obj:GetName() return self._name end
function Obj:GetAlpha() return self._alpha end
function Obj:SetAlpha(a) self._alpha = a end
function Obj:GetChecked() return self._checked end
function Obj:SetChecked(v) self._checked = v end
function Obj:GetNumPoints() return 1 end
function Obj:GetTexture() return self._texture end
function Obj:SetTexture(t) self._texture = t end
function Obj:SetStatusBarTexture(t) self._texture = t end
function Obj:GetStatusBarTexture()
    local owner = self
    return setmetatable({}, { __index = function(_, k)
        if k == "GetTexture" then return function() return owner._texture end end
        return function() end
    end })
end
function Obj:GetFont() return "font", 12, "" end
function Obj:GetObjectType() return self._kind end
function Obj:IsObjectType(t) return self._kind == t end
function Obj:GetAttribute(k) return self._attrs and self._attrs[k] end
function Obj:SetAttribute(k, v) self._attrs = self._attrs or {} self._attrs[k] = v end
function Obj:RegisterEvent(e) self._events = self._events or {} self._events[e] = true end
function Obj:GetTextColor() return 1, 1, 1, 1 end
function Obj:GetNumRegions() return 0 end
function Obj:GetCursorPosition() return 0 end
function Obj:GetLeft() return 0 end
function Obj:GetTop() return 0 end
function Obj:GetRight() return 0 end
function Obj:GetBottom() return 0 end
function Obj:GetCenter() return 0, 0 end
function Obj:SetStatusBarColor(r, g, b) self._color = { r, g, b } end
function Obj:GetStatusBarColor() local c = self._color or { 1, 1, 1 } return c[1], c[2], c[3] end
function Obj:SetVertexColor(r, g, b, a) self._color = { r, g, b, a } end
function Obj:SetTextColor(r, g, b) self._color = { r, g, b } end
function Obj:Play() self._playing = true end
function Obj:Stop() self._playing = false end
function Obj:IsPlaying() return self._playing == true end
function Obj:GetNumLetters() return #(self._text or "") end

-- each OnShow, down the tree, the way the game fires it
function MOCK.FireShow(o)
    if not o:IsVisible() then return end
    if o._scripts.OnShow then
        local ok, err = xpcall(o._scripts.OnShow, debug.traceback, o)
        if not ok then table.insert(MOCK.errors, "OnShow: " .. tostring(err)) end
    end
    for _, c in ipairs(o._children) do if c._shown then MOCK.FireShow(c) end end
end

UIParent = New("Frame")
Minimap = New("Frame", UIParent)
WorldFrame = New("Frame")
GameTooltip = New("GameTooltip", UIParent)
ItemRefTooltip = New("GameTooltip", UIParent)
WorldMapFrame = New("Frame", UIParent)
QuestFrame = New("Frame", UIParent)
GossipFrame = New("Frame", UIParent)
MerchantFrame = New("Frame", UIParent)
DEFAULT_CHAT_FRAME = New("Frame", UIParent)
function DEFAULT_CHAT_FRAME:AddMessage(m) table.insert(MOCK.printed, m) end
UISpecialFrames = {}
StaticPopupDialogs = {}
SlashCmdList = {}
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
SOUNDKIT = {}
RAID_CLASS_COLORS = { WARRIOR = { r = 0.78, g = 0.61, b = 0.43 } }
MAX_QUESTLOG_QUESTS = 20

function CreateFrame(kind, name, parent)
    local f = New(kind or "Frame", parent or UIParent, name)
    if name then _G[name] = f end
    return f
end

C_Timer = {
    After = function(_, fn) table.insert(MOCK.timers, fn) end,
    NewTicker = function(_, fn) table.insert(MOCK.tickers, fn) return { Cancel = function() end } end,
    NewTimer = function(_, fn) table.insert(MOCK.timers, fn) return { Cancel = function() end } end,
}
function MOCK.RunTimers()
    for _ = 1, 5 do
        local t = MOCK.timers
        MOCK.timers = {}
        for _, fn in ipairs(t) do
            local ok, err = pcall(fn)
            if not ok then table.insert(MOCK.errors, "timer: " .. tostring(err)) end
        end
    end
end
function MOCK.RunTickers()
    for _, fn in ipairs(MOCK.tickers) do
        local ok, err = pcall(fn)
        if not ok then table.insert(MOCK.errors, "ticker: " .. tostring(err)) end
    end
end

MOCK.time = 1000
function GetTime() return MOCK.time end
function GetServerTime() return os.time() end
time = os.time
date = os.date
function UnitLevel() return 12 end
function UnitName() return "Testchar", nil end
function UnitClass() return "Warrior", "WARRIOR", 1 end
function UnitRace() return "Orc", "Orc", 2 end
function UnitFactionGroup() return "Horde", "Horde" end
function UnitSex() return 2 end
function UnitXP() return 100 end
function UnitXPMax() return 1000 end
function GetXPExhaustion() return nil end
function UnitHealth() return 100 end
function UnitHealthMax() return 100 end
function UnitExists() return false end
function UnitIsDead() return false end
function UnitGUID() return "Player-1-1" end
function GetMoney() return 12345 end
function GetRealmName() return "Forever" end
function GetRealZoneText() return "Durotar" end
function GetZoneText() return "Durotar" end
function GetSubZoneText() return "" end
function GetMinimapZoneText() return "" end
function GetBindLocation() return "Razor Hill" end
function GetMaxPlayerLevel() return 60 end
function IsInInstance() return false end
function IsInGroup() return false end
function IsInGuild() return false end
function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function IsAltKeyDown() return false end
function InCombatLockdown() return false end
function UnitOnTaxi() return false end
function UnitAffectingCombat() return false end
function GetNumQuestLogEntries() return 0, 0 end
function GetCursorPosition() return 0, 0 end
function GetLocale() return "enUS" end
function GetBuildInfo() return "1.15.0", "1", "", 11500 end
function GetCVar() return "0" end
function GetCVarBool() return false end
function PlaySound() end
function PlaySoundFile() end
-- hooksecurefunc(name, fn) or hooksecurefunc(table, name, fn): run fn after the original
function hooksecurefunc(a, b, c)
    local t, key, fn = _G, a, b
    if type(a) == "table" then t, key, fn = a, b, c end
    local orig = t[key]
    if type(orig) ~= "function" then return end
    t[key] = function(...)
        local r = table.pack(orig(...))
        fn(...)
        return table.unpack(r, 1, r.n)
    end
end
function StaticPopup_Show() end
function GetAddOnMetadata() return nil end
function IsAddOnLoaded() return false end
function GetTalentInfo() return nil end
function GetUnspentTalentPoints() return 0 end
function UnitCharacterPoints() return 0 end
function GetNumSkillLines() return 0 end
function GetInventoryItemLink() return nil end
function GetContainerNumSlots() return 0 end
function GetItemCount() return 0 end
function GetItemInfo() return nil end
function GetSpellInfo() return nil end
function GetSpellTexture() return nil end
function GetQuestLogTitle() return nil end
function GetNumGroupMembers() return 0 end
function RequestTimePlayed() end
function issecretvalue() return false end
function ChatFrame_AddMessageEventFilter() end
function SetRaidTarget() end
function UnitIsPlayer() return false end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
tinsert, tremove = table.insert, table.remove
-- WoW's Lua 5.1 lets %d take a number with a fraction (it truncates); 5.5 doesn't
local realFormat = string.format
string.format = function(fmt, ...)
    local ok, out = pcall(realFormat, fmt, ...)
    if ok then return out end
    local args = table.pack(...)
    for i = 1, args.n do if math.type(args[i]) == "float" then args[i] = math.floor(args[i]) end end
    return realFormat(fmt, table.unpack(args, 1, args.n))
end
format = string.format
strsplit = function(sep, s)
    local out = {}
    for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%p", "%%%0")) do out[#out + 1] = part end
    return table.unpack(out)
end
strlower, strupper, strfind, strsub = string.lower, string.upper, string.find, string.sub
bit = { band = function(a, b) return a & b end, bor = function(a, b) return a | b end, lshift = function(a, b) return a << b end }
unpack = table.unpack
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
C_QuestLog = { GetNumQuestLogEntries = function() return 0 end, GetInfo = function() return nil end,
               IsQuestFlaggedCompleted = function() return false end, IsOnQuest = function() return false end,
               GetMaxNumQuestsCanAccept = function() return 20 end }
C_Map = { GetBestMapForUnit = function() return 1411 end, GetPlayerMapPosition = function() return nil end,
          GetMapInfo = function() return { name = "Durotar" } end }
C_AddOns = { GetAddOnMetadata = function() return "test" end, IsAddOnLoaded = function() return false end }
C_NamePlate = { GetNamePlates = function() return {} end }

-- anything else: a harmless stub - except game constants (ALL_CAPS) and the
-- addon's saved variables, which start out nil as they do in the game
setmetatable(_G, { __index = function(_, k)
    if type(k) ~= "string" or k:match("^[%u%d_]+$") or k:match("^Hearthbound") then return nil end
    return stub()
end })
