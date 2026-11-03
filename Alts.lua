local ADDON_NAME, ns = ...

-- Alts: a snapshot of every character (kept account-wide) and the Alts tab.

local format = string.format
local Safe = ns.Safe

local ROW_H = 22
local PAD = 22
local PAGE_W = ns.UI.width
-- Classic rested XP: 5% of a level per 8 hours in an inn or city, a quarter
-- of that elsewhere, capped at 1.5 levels
local RESTED_PER_HOUR = 0.05 / 8
local OUTSIDE_FACTOR = 0.25
local RESTED_CAP = 1.5

local page, rows, totalText, emptyText = nil, {}, nil, nil
local offset = 0

-- This character's key in ns.db.alts: its full name and realm, and - in case
-- two characters still share that (no surname from the client) - made unique
-- with its character ID, so one never overwrites the other
local myKey
local function Me()
    if myKey then return myKey end
    local key = ns.CharKey()
    local guid = Safe(UnitGUID, "player")
    local alts = ns.db and ns.db.alts
    if not alts or not guid then return key end
    local alt = alts[key]
    if alt and alt.guid and alt.guid ~= guid then
        key = key .. " #" .. (guid:match("(%x+)$") or guid)
    end
    myKey = key
    return key
end
ns.AltKey = Me

-- Earlier versions filed characters by first name only, so two characters
-- called Falling shared one entry. The old entry goes once it looks like this
-- character's (same first name and class); a different character's is left
-- until that one logs in.
local function DropOldEntry()
    local old, new = ns.OldCharKey(), Me()
    if old == new then return end
    local alt = ns.db.alts[old]
    local _, class = UnitClass("player")
    local guid = Safe(UnitGUID, "player")
    local mine = alt and (alt.guid and alt.guid == guid or (not alt.guid and (alt.class == nil or alt.class == class)))
    if mine then
        ns.db.alts[old] = nil
        if ns.db.altQuests then ns.db.altQuests[old] = nil end
    end
end

-- While logging out (and very early in a login) the game reports 0 gold and
-- 0 XP; saving then wiped out the real values, so skip those moments
local function CharacterDataReady()
    local maxLevel = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
    local xpMax = UnitXPMax("player")
    return UnitLevel("player") >= maxLevel or (type(xpMax) == "number" and xpMax > 0)
end

-- Each character's completed quests (account-wide), so quest tooltips can say
-- "Done on Falling". Only rewritten when the count changes.
local lastQuestCount
local function SnapshotQuests()
    local quests = ns.cdb and ns.cdb.quests
    if type(quests) ~= "table" then return end
    local count = 0
    for _ in pairs(quests) do count = count + 1 end
    if count == lastQuestCount or count == 0 then return end
    lastQuestCount = count
    local set = {}
    for id in pairs(quests) do
        if type(id) == "number" then set[id] = true end
    end
    ns.db.altQuests = ns.db.altQuests or {}
    ns.db.altQuests[Me()] = set
end

-- Your other characters who've completed a quest, as class-coloured names
function ns.AltsWhoDid(questId)
    local names = {}
    if not (ns.db and ns.db.altQuests and questId) then return names end
    local me = Me()
    for key, set in pairs(ns.db.altQuests) do
        if key ~= me and set[questId] then
            local alt = ns.db.alts[key]
            local name = alt and alt.name or key:match("^[^-]+") or key
            local c = RAID_CLASS_COLORS and alt and alt.class and RAID_CLASS_COLORS[alt.class]
            names[#names + 1] = c and format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name) or name
        end
    end
    table.sort(names)
    return names
end

local function Snapshot()
    if not ns.db then return end
    SnapshotQuests()
    if not CharacterDataReady() then return end
    local _, class = UnitClass("player")
    DropOldEntry()
    ns.db.alts[Me()] = {
        guid = Safe(UnitGUID, "player"),
        name = ns.FullName(),
        realm = GetRealmName(),
        class = class,
        level = UnitLevel("player"),
        xp = UnitXP("player"),
        xpMax = UnitXPMax("player"),
        rested = GetXPExhaustion() or 0,
        resting = IsResting() and true or false,
        money = GetMoney(),
        zone = Safe(GetRealZoneText) or "?",
        seen = time(),
    }
end

-- Rested XP now, estimated from the snapshot and how long they've been away
local function RestedNow(alt)
    if not alt.xpMax or alt.xpMax == 0 then return 0 end
    local isMe = (alt.guid and alt.guid == Safe(UnitGUID, "player"))
        or (not alt.guid and alt.name and Me() == (alt.name .. "-" .. (alt.realm or "?")))
    if isMe then return GetXPExhaustion() or 0 end
    local hours = math.max(0, time() - (alt.seen or time())) / 3600
    local rate = RESTED_PER_HOUR * (alt.resting and 1 or OUTSIDE_FACTOR)
    local gained = hours * rate * alt.xpMax
    return math.min((alt.rested or 0) + gained, RESTED_CAP * alt.xpMax)
end

local function Ago(t)
    local age = time() - (t or time())
    if age < 300 then return "now" end
    if age < 3600 then return format("%dm ago", math.floor(age / 60)) end
    if age < 86400 then return format("%dh ago", math.floor(age / 3600)) end
    return format("%dd ago", math.floor(age / 86400))
end

local function ClassColor(class)
    local c = RAID_CLASS_COLORS and class and RAID_CLASS_COLORS[class]
    if c then return format("%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255) end
    return "ffffff"
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------
local COLUMNS = {
    { key = "name", title = "Character", width = 140, justify = "LEFT" },
    { key = "level", title = "Level", width = 62, justify = "LEFT" },
    { key = "rested", title = "Rested", width = 80, justify = "LEFT" },
    { key = "money", title = "Gold", width = 100, justify = "RIGHT" },
    { key = "zone", title = "Zone", width = 0, justify = "LEFT" }, -- fills the rest
    { key = "seen", title = "Played", width = 60, justify = "RIGHT" },
}

local function SortedAlts()
    local list = {}
    for key, alt in pairs(ns.db.alts) do list[#list + 1] = { key = key, alt = alt } end
    table.sort(list, function(a, b)
        if (a.alt.level or 0) ~= (b.alt.level or 0) then return (a.alt.level or 0) > (b.alt.level or 0) end
        return (a.alt.name or "") < (b.alt.name or "")
    end)
    return list
end

local function LayoutCells(parent, cells, y)
    local x = PAD + 6
    local fixed = 0
    for _, col in ipairs(COLUMNS) do fixed = fixed + col.width end
    local flexible = (PAGE_W - PAD * 2 - 12) - fixed
    for i, col in ipairs(COLUMNS) do
        local w = col.width > 0 and col.width or flexible
        local fs = cells[i]
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        fs:SetWidth(w - 6)
        fs:SetJustifyH(col.justify)
        fs:SetWordWrap(false)
        x = x + w
    end
end

local function CreateRow(i)
    local row = CreateFrame("Button", nil, page)
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", PAD, -24 - (i - 1) * ROW_H)
    row:SetPoint("TOPRIGHT", -PAD, -24 - (i - 1) * ROW_H)
    row:RegisterForClicks("RightButtonUp")
    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints()
    stripe:SetColorTexture(1, 1, 1, (i % 2 == 0) and 0.03 or 0)
    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(0.78, 0.61, 0.43, 0.12)
    row.cells = {}
    for c = 1, #COLUMNS do
        row.cells[c] = ns.Text(page, c == 1 and 12 or 11, c == 1 and ns.color.text or ns.color.dim)
    end
    LayoutCells(page, row.cells, -24 - (i - 1) * ROW_H - 5)
    row:SetScript("OnClick", function(self)
        -- right-click forgets a character (e.g. one you've deleted)
        if self.key and self.key ~= Me() then
            ns.db.alts[self.key] = nil
            if ns.db.altQuests then ns.db.altQuests[self.key] = nil end
            ns.Print("Removed " .. self.key .. " from your alts. It comes back if you log in on it.")
            ns.RefreshAlts()
        end
    end)
    row:SetScript("OnEnter", function(self)
        if not self.key or self.key == Me() then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.key, 1, 1, 1)
        GameTooltip:AddLine("Right-click to remove from this list.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rows[i] = row
    return row
end

local function VisibleRows()
    return math.max(1, math.floor((page:GetHeight() - 24 - 26) / ROW_H))
end

function ns.RefreshAlts()
    if not page or not page:IsVisible() then return end
    Snapshot()
    local list = SortedAlts()
    local visible = VisibleRows()
    offset = math.max(0, math.min(offset, #list - visible))
    local totalMoney = 0
    for _, e in ipairs(list) do totalMoney = totalMoney + (e.alt.money or 0) end

    for i = 1, visible do
        local row = rows[i] or CreateRow(i)
        local e = list[offset + i]
        if e then
            local alt = e.alt
            row.key = e.key
            local isMe = e.key == Me()
            local name = format("|cff%s%s|r", ClassColor(alt.class), alt.name or e.key)
            if isMe then name = name .. " |cff999999(you)|r" end
            local pct = alt.xpMax and alt.xpMax > 0 and math.floor(alt.xp / alt.xpMax * 100) or 0
            local rested = RestedNow(alt)
            local restedPct = alt.xpMax and alt.xpMax > 0 and math.floor(rested / alt.xpMax * 100) or 0
            local restedColor = restedPct >= 100 and "6fdc6f" or (restedPct > 0 and "6f9cff" or "999999")
            local values = {
                name,
                format("%d  |cff999999%d%%|r", alt.level or 0, pct),
                format("|cff%s%d%%|r%s", restedColor, restedPct, (not isMe and alt.resting) and " |cff999999inn|r" or ""),
                ns.Money(alt.money or 0),
                alt.zone or "",
                isMe and "now" or Ago(alt.seen),
            }
            for c, fs in ipairs(row.cells) do
                fs:SetText(values[c])
                fs:Show()
            end
            row:Show()
        else
            row.key = nil
            row:Hide()
            for _, fs in ipairs(row.cells) do fs:Hide() end
        end
    end
    for i = visible + 1, #rows do
        rows[i]:Hide()
        for _, fs in ipairs(rows[i].cells) do fs:Hide() end
    end
    totalText:SetText(format("%d character%s  |  Total gold: %s", #list, #list == 1 and "" or "s", ns.Money(totalMoney)))
    emptyText:SetShown(#list <= 1)
end

function ns.BuildAltsTab(parent)
    page = parent
    local headers = {}
    for i, col in ipairs(COLUMNS) do
        headers[i] = ns.Text(page, 10, ns.color.gold)
        headers[i]:SetText(col.title:upper())
    end
    LayoutCells(page, headers, -6)
    local line = page:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.78, 0.61, 0.43, 0.3)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", PAD, -21)
    line:SetPoint("TOPRIGHT", -PAD, -21)

    totalText = ns.Text(page, 11, ns.color.text)
    totalText:SetPoint("BOTTOMLEFT", PAD, 6)
    emptyText = ns.Text(page, 11, ns.color.dim)
    emptyText:SetPoint("BOTTOMRIGHT", -PAD, 6)
    emptyText:SetText("Log in on your other characters once to add them.")

    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", function(_, delta)
        offset = offset - delta
        ns.RefreshAlts()
    end)
    page:SetScript("OnShow", ns.RefreshAlts)
end

table.insert(ns.inits, function()
    -- give the game a moment after login to report gold and XP
    ns.On("PLAYER_ENTERING_WORLD", function() C_Timer.After(2, Snapshot) end)
    -- keep the snapshot current as things change (not at logout: values read as 0 then)
    ns.On("PLAYER_MONEY", Snapshot)
    ns.On("PLAYER_XP_UPDATE", Snapshot)
    ns.On("PLAYER_LEVEL_UP", function() C_Timer.After(1, Snapshot) end)
    ns.On("PLAYER_UPDATE_RESTING", Snapshot)
    ns.On("ZONE_CHANGED_NEW_AREA", Snapshot)
    C_Timer.NewTicker(60, Snapshot)
    C_Timer.NewTicker(5, ns.RefreshAlts)
end)
