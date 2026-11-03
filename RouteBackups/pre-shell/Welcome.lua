local ADDON_NAME, ns = ...

-- Welcome back: on login, one small window with how long you've been away,
-- the rested XP you've gained, how your last session went and your alts.
-- Click it or wait to dismiss.

local format = string.format

local SHOW_SECONDS = 20
local RESTED_PER_HOUR, OUTSIDE = 0.05 / 8, 0.25 -- 5% of a level per 8 hours in an inn

local frame

local function Me() return ns.AltKey and ns.AltKey() or ns.CharKey() end

local function Build()
    frame = CreateFrame("Frame", "HearthboundWelcome", UIParent, ns.BACKDROP)
    frame:SetSize(330, 60)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -110)
    frame:SetFrameStrata("HIGH")
    ns.Skin(frame, { 0.05, 0.05, 0.06, 0.95 }, ns.color.gold)
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetColorTexture(unpack(ns.color.accent))
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(2)
    frame.title = ns.Text(frame, 14, ns.color.gold)
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.body = ns.Text(frame, 11)
    frame.body:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
    frame.body:SetWidth(306)
    frame.body:SetJustifyH("LEFT")
    frame.hint = ns.Text(frame, 9, ns.color.dim)
    frame.hint:SetPoint("BOTTOMRIGHT", -8, 5)
    frame.hint:SetText("click to close")
    frame:EnableMouse(true)
    frame:SetScript("OnMouseUp", function(self) self:Hide() end)
    frame:Hide()
end

local function Show(lines)
    if not frame then Build() end
    frame.title:SetText("Welcome back, " .. (UnitName("player") or "adventurer"))
    frame.body:SetText(table.concat(lines, "\n"))
    frame:SetHeight(frame.body:GetStringHeight() + 44)
    frame:Show()
    C_Timer.After(SHOW_SECONDS, function() if frame:IsShown() then frame:Hide() end end)
end

local function Summarise(before)
    local lines = {}
    local xpMax = UnitXPMax("player") or 0
    -- time away and rested gained
    if before and before.seen then
        local away = time() - before.seen
        if away >= 600 then
            local rested = GetXPExhaustion() or 0
            local gained = rested - (before.rested or 0)
            local line = "Away " .. ns.Duration(away)
            if xpMax > 0 and gained > 0 then
                line = line .. format("  -  |cff6f9cffrested +%d%%|r of a level (now %d%%)",
                    math.floor(gained / xpMax * 100 + 0.5), math.floor(rested / xpMax * 100 + 0.5))
            end
            lines[#lines + 1] = line
        end
    end
    -- last session
    local s = ns.cdb.lastSession
    if s and s.start then
        local played = (s.last or s.start) - s.start
        local levels = (s.endLevel or 0) - (s.startLevel or 0)
        local parts = { ns.Duration(played) }
        if levels > 0 then parts[#parts + 1] = format("+%d level%s", levels, levels == 1 and "" or "s") end
        if (s.quests or 0) > 0 then parts[#parts + 1] = s.quests .. " quests" end
        if (s.kills or 0) > 0 then parts[#parts + 1] = s.kills .. " kills" end
        if (s.xp or 0) > 0 then parts[#parts + 1] = ns.Short(s.xp) .. " XP" end
        lines[#lines + 1] = "Last session: " .. table.concat(parts, ", ")
    end
    -- the alt with the most rested XP waiting
    local best, bestPct
    for key, alt in pairs(ns.db.alts or {}) do
        if key ~= Me() and alt.xpMax and alt.xpMax > 0 then
            local hours = math.max(0, time() - (alt.seen or time())) / 3600
            local rested = math.min((alt.rested or 0) + hours * RESTED_PER_HOUR * (alt.resting and 1 or OUTSIDE) * alt.xpMax,
                1.5 * alt.xpMax)
            local pct = math.floor(rested / alt.xpMax * 100)
            if not bestPct or pct > bestPct then best, bestPct = alt, pct end
        end
    end
    if best and bestPct >= 50 then
        lines[#lines + 1] = format("%s (level %d) has %d%% rested waiting", best.name or "An alt", best.level or 0, bestPct)
    end
    -- talent points and goals
    if ns.UnspentTalentPoints and ns.UnspentTalentPoints() > 0 then
        lines[#lines + 1] = format("|cffffd200%d talent point%s to spend|r", ns.UnspentTalentPoints(), ns.UnspentTalentPoints() == 1 and "" or "s")
    end
    return lines
end

table.insert(ns.inits, function()
    ns.On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin)
        if not isInitialLogin or not ns.db.welcomeBack then return end
        -- what this character's snapshot said before this login updates it
        local saved = (ns.db.alts or {})[Me()]
        local before = saved and { seen = saved.seen, rested = saved.rested } or nil
        C_Timer.After(5, function()
            local lines = Summarise(before)
            if #lines > 0 then Show(lines) end
        end)
    end)
end)
