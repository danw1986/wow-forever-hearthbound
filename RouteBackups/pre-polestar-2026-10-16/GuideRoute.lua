local ADDON_NAME, ns = ...

-- The Guide panel of the shell (Shell.lua): every zone and section of your
-- levelling route, under level headings, with the one you pick shown in
-- full on the right - its levels, progress, quests and what comes next - to
-- follow in the guide window, or skip. Its menu also picks the route
-- (Forever or Classic) and holds the quest log tidy-up (GuideLogTidy.lua).

local format = string.format

local LIST_W = 400    -- the zone list; the detail column takes the rest
local ROW_H, HEAD_H = 24, 30
local PAD = 18

local panel, zonesView, tidyView
local view = "zones"           -- "zones" or "tidy"
local chosen                   -- the zone (section name) shown on the right
local showOnly = "all"         -- "all" or "mylevel"
local hideDone, hideClass = false, false
local all, lines = {}, {}      -- the route's zones; what the list shows
local listLines = {}           -- the list's frames

-- quest-level colours, from your level
local function LevelColour(level)
    if not level then return "999999" end
    local d = ns.QuestDifficulty and ns.QuestDifficulty(level, UnitLevel("player")) or "normal"
    return ({ impossible = "ff4040", hard = "ff8040", normal = "ffd200", easy = "40c040", trivial = "808080" })[d] or "ffd200"
end

local function Levels(g)
    if not g.levelLo then return "" end
    return g.levelLo == g.levelHi and tostring(g.levelLo) or format("%d-%d", g.levelLo, g.levelHi)
end

local function AtMyLevel(g)
    local me = UnitLevel("player")
    return g.levelLo and me >= g.levelLo - 2 and me <= g.levelHi + 1 and g.left > 0 and not g.skipped
end

local function ByRoute() return ns.db.guideRouteSort == "route" end

---------------------------------------------------------------------------
-- What the list shows: the zones (filtered), under headings
---------------------------------------------------------------------------
local function Reload(fresh)
    all = ns.GuideSectionGroups and ns.GuideSectionGroups(fresh) or {}
    -- a section with no quests (class training, travel) takes the level of
    -- the zone before it, so it sorts next to it
    local carry = 1
    for n, g in ipairs(all) do
        g.order = n
        carry = g.levelLo or carry
        g.sortLevel, g.sortHigh = carry, g.levelHi or carry
        g.nextName = all[n + 1] and all[n + 1].name
    end
end

local function Visible()
    local out = {}
    for _, g in ipairs(all) do
        local finished = g.left == 0 and not g.skipped
        local keep = not ((hideDone and finished) or (hideClass and g.class)) or g.current
        if keep and showOnly == "mylevel" then keep = AtMyLevel(g) or g.current end
        if keep then out[#out + 1] = g end
    end
    if not ByRoute() then
        table.sort(out, function(a, b)
            if a.sortLevel ~= b.sortLevel then return a.sortLevel < b.sortLevel end
            if a.sortHigh ~= b.sortHigh then return a.sortHigh < b.sortHigh end
            return a.order < b.order
        end)
    end
    return out
end

-- the list's lines: a heading per ten levels (or per zone of the route, in route order)
local function BuildLines()
    lines = {}
    local band, head
    for _, g in ipairs(Visible()) do
        local b = ByRoute() and (g.zone or g.name) or math.floor(((g.sortLevel or 1) - 1) / 10)
        if b ~= band then
            band = b
            local label = ByRoute() and (g.zone or g.name) or format("Levels %d-%d", b * 10 + 1, b * 10 + 10)
            head = { header = true, label = label, count = 0 }
            lines[#lines + 1] = head
        end
        head.count = head.count + 1
        lines[#lines + 1] = { group = g }
    end
end

local function Find(name)
    for _, g in ipairs(all) do if g.name == name then return g end end
end

---------------------------------------------------------------------------
-- The zone list (left)
---------------------------------------------------------------------------
local DrawDetail

local function ListLine(i)
    if listLines[i] then return listLines[i] end
    local l = CreateFrame("Button", nil, zonesView.child)
    l:SetWidth(LIST_W - PAD - 10)
    l.sel = l:CreateTexture(nil, "BACKGROUND")
    l.sel:SetAllPoints()
    l.sel:SetColorTexture(1, 1, 1, 0.07)
    l.bar = l:CreateTexture(nil, "ARTWORK")
    l.bar:SetPoint("TOPLEFT")
    l.bar:SetPoint("BOTTOMLEFT")
    l.bar:SetWidth(3)
    l.bar:SetColorTexture(unpack(ns.color.gold))
    l.text = ns.Text(l, 12)
    l.text:SetPoint("LEFT", 10, 0)
    l.text:SetJustifyH("LEFT")
    l.text:SetWordWrap(false)
    l.tag = ns.Text(l, 10, ns.color.dim)
    l.tag:SetPoint("RIGHT", -8, 0)
    l.tag:SetJustifyH("RIGHT")
    l.text:SetPoint("RIGHT", l.tag, "LEFT", -8, 0)
    l.rule = l:CreateTexture(nil, "ARTWORK")
    l.rule:SetColorTexture(1, 1, 1, 0.08)
    l.rule:SetHeight(1)
    l.rule:SetPoint("BOTTOMLEFT", 0, 4)
    l.rule:SetPoint("BOTTOMRIGHT", 0, 4)
    l.hl = l:CreateTexture(nil, "HIGHLIGHT")
    l.hl:SetAllPoints()
    l.hl:SetColorTexture(1, 1, 1, 0.04)
    l:SetScript("OnClick", function(self)
        if self.group then
            chosen = self.group.name
            panel.Draw()
        end
    end)
    l:SetScript("OnDoubleClick", function(self)
        if self.group and ns.GuideFollowSection then
            ns.GuideFollowSection(self.group.name)
            Reload(true)
            panel.Draw()
        end
    end)
    listLines[i] = l
    return l
end

local function DrawList()
    local y = 0
    for i, line in ipairs(lines) do
        local l = ListLine(i)
        l:ClearAllPoints()
        l:SetPoint("TOPLEFT", 0, -y)
        if line.header then
            l.group = nil
            l:SetHeight(HEAD_H)
            l.text:SetFont(ns.FONT, 10, "")
            l.text:SetTextColor(unpack(ns.color.gold))
            l.text:SetText(line.label:upper())
            l.tag:SetText(line.count)
            l.tag:SetTextColor(unpack(ns.color.dim))
            l.sel:Hide()
            l.bar:Hide()
            l.rule:Show()
            l.hl:Hide()
            l:EnableMouse(false)
            y = y + HEAD_H
        else
            local g = line.group
            l.group = g
            l:SetHeight(ROW_H)
            l.text:SetFont(ns.FONT, 12, "")
            local finished = g.left == 0
            local colour = g.skipped and "777777" or (finished and "8fbf8f" or "ffffff")
            l.text:SetText(format("|cff%s%s|r  |cff%s(%s)|r", colour, g.name, LevelColour(g.levelLo), Levels(g)))
            local tag, tagColour
            if g.current then tag, tagColour = "you're here", { 0.4, 1, 0.6, 1 }
            elseif g.skipped then tag, tagColour = "skipped", { 1, 0.5, 0.25, 1 }
            elseif finished then tag, tagColour = "done", { 0.45, 0.75, 0.45, 1 }
            elseif AtMyLevel(g) then tag, tagColour = format("%d left", g.left), { 0.9, 0.85, 0.5, 1 }
            else tag, tagColour = format("%d left", g.left), ns.color.dim end
            l.tag:SetText(tag)
            l.tag:SetTextColor(unpack(tagColour))
            local on = g.name == chosen
            l.sel:SetShown(on)
            l.bar:SetShown(on)
            l.rule:Hide()
            l.hl:Show()
            l:EnableMouse(true)
            y = y + ROW_H
        end
        l:Show()
    end
    for i = #lines + 1, #listLines do listLines[i]:Hide() end
    zonesView.child:SetHeight(math.max(10, y + 8))
    zonesView.empty:SetShown(#lines == 0)
end

-- bring the chosen zone into view
local function ScrollToChosen()
    local y = 0
    for _, line in ipairs(lines) do
        if line.group and line.group.name == chosen then
            local max = math.max(0, zonesView.child:GetHeight() - zonesView.scroll:GetHeight())
            zonesView.scroll:SetVerticalScroll(math.max(0, math.min(max, y - 90)))
            return
        end
        y = y + (line.header and HEAD_H or ROW_H)
    end
end

---------------------------------------------------------------------------
-- The chosen zone (right)
---------------------------------------------------------------------------
local function Chip(parent)
    local c = CreateFrame("Frame", nil, parent, ns.BACKDROP)
    c:SetHeight(20)
    ns.Skin(c, { 1, 1, 1, 0.05 }, { 1, 1, 1, 0.12 })
    c.text = ns.Text(c, 10)
    c.text:SetPoint("CENTER")
    function c.Set(_, text, colour)
        c.text:SetText(text)
        c.text:SetTextColor(unpack(colour or ns.color.text))
        c:SetWidth(c.text:GetStringWidth() + 18)
        c:SetShown(text ~= "")
    end
    return c
end

local function BuildDetail(parent)
    local d = CreateFrame("Frame", nil, parent)
    d:SetPoint("TOPLEFT", LIST_W + 1, 0)
    d:SetPoint("BOTTOMRIGHT")
    local bg = d:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.02)
    local w = ns.UI.width - LIST_W - PAD * 2
    d.name = ns.Text(d, 17, ns.color.text)
    d.name:SetPoint("TOPLEFT", PAD, -16)
    d.name:SetWidth(w)
    d.name:SetJustifyH("LEFT")
    d.levels = Chip(d)
    d.levels:SetPoint("TOPLEFT", d.name, "BOTTOMLEFT", 0, -10)
    d.kind = Chip(d)
    d.kind:SetPoint("LEFT", d.levels, "RIGHT", 6, 0)

    d.progressHead = ns.CreateHeader(d, "Progress", w)
    d.progressHead:SetPoint("TOPLEFT", d.levels, "BOTTOMLEFT", 0, -18)
    d.progress = ns.Text(d, 11, ns.color.text)
    d.progress:SetPoint("TOPLEFT", d.progressHead, "BOTTOMLEFT", 0, -10)
    d.bar = ns.CreateBar(d, w, 6, { 0.9, 0.72, 0.35, 1 })
    d.bar:SetPoint("TOPLEFT", d.progress, "BOTTOMLEFT", 0, -6)
    d.percent = ns.Text(d, 11, ns.color.dim)
    d.percent:SetPoint("BOTTOMRIGHT", d.bar, "TOPRIGHT", 0, 6)

    d.detailHead = ns.CreateHeader(d, "Details", w)
    d.detailHead:SetPoint("TOPLEFT", d.bar, "BOTTOMLEFT", 0, -20)
    d.rows = {}
    local labels = { "Steps", "Quests", "Left to do", "Zones", "Next" }
    local prev = d.detailHead
    for i, label in ipairs(labels) do
        local k = ns.Text(d, 11, ns.color.dim)
        -- under the heading, then under the value above (which can wrap)
        if i == 1 then k:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10) else k:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -82, -8) end
        k:SetText(label)
        local v = ns.Text(d, 11, ns.color.text)
        v:SetPoint("TOPLEFT", k, "TOPLEFT", 82, 0)
        v:SetWidth(w - 82)
        v:SetJustifyH("LEFT")
        d.rows[i] = v
        prev = v
        v.key = k
    end
    d.status = ns.Text(d, 11, ns.color.dim)
    d.status:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -82, -14)
    d.status:SetWidth(w)
    d.status:SetJustifyH("LEFT")

    d.follow = ns.CreateButton(d, "Follow in the guide", w, 28, function()
        if chosen and ns.GuideFollowSection then
            if not ns.db.guide then
                ns.db.guide = true
                ns.RefreshAll()
            end
            ns.GuideFollowSection(chosen)
            Reload(true)
            panel.Draw()
        end
    end)
    d.follow:SetPoint("BOTTOMLEFT", PAD, 52)
    ns.Skin(d.follow, { ns.color.gold[1] * 0.85, ns.color.gold[2] * 0.85, ns.color.gold[3] * 0.85, 1 }, ns.color.border)
    d.follow.text:SetTextColor(0.08, 0.06, 0.04)
    d.follow:HookScript("OnLeave", function(self) self.text:SetTextColor(0.08, 0.06, 0.04) end)
    d.skip = ns.CreateButton(d, "Skip this zone", w, 24, function()
        local g = chosen and Find(chosen)
        if g and ns.GuideSkipSection then
            ns.GuideSkipSection(g.name, not g.skipped)
            Reload(true)
            panel.Draw()
        end
    end)
    d.skip:SetPoint("BOTTOMLEFT", PAD, 20)
    d.empty = ns.Text(d, 11, ns.color.dim)
    d.empty:SetPoint("TOPLEFT", PAD, -18)
    d.empty:SetWidth(w)
    d.empty:SetJustifyH("LEFT")
    d.empty:SetText("Pick a zone on the left to see it here.")
    return d
end

function DrawDetail()
    local d = zonesView.detail
    local g = chosen and Find(chosen)
    local parts = { d.name, d.levels, d.kind, d.progressHead, d.progress, d.percent, d.bar, d.detailHead, d.status, d.follow, d.skip }
    for _, v in ipairs(d.rows) do parts[#parts + 1] = v parts[#parts + 1] = v.key end
    for _, p in ipairs(parts) do p:SetShown(g ~= nil) end
    d.empty:SetShown(g == nil)
    if not g then return end
    d.name:SetText(g.name)
    d.levels:Set(g.levelLo and ("Levels " .. Levels(g)) or "", { 1, 0.86, 0.5, 1 })
    d.kind:Set(g.class and "Class training" or (g.zone or ""), ns.color.dim)
    d.progress:SetText(format("%d of %d steps done", g.done, g.steps))
    d.percent:SetText(format("%d%%", g.steps > 0 and math.floor(g.done / g.steps * 100) or 0))
    d.bar.bar:SetValue(g.steps > 0 and g.done / g.steps or 0)
    d.rows[1]:SetText(g.steps)
    d.rows[2]:SetText(g.quests or 0)
    d.rows[3]:SetText(g.skipped and "skipped" or (g.left == 0 and "nothing - done" or format("%d step%s", g.left, g.left == 1 and "" or "s")))
    d.rows[4]:SetText(table.concat(g.zones or {}, "  |cff777777>|r  "))
    local nextG = g.nextName and Find(g.nextName)
    d.rows[5]:SetText(nextG and format("%s |cff999999(%s)|r", nextG.name, Levels(nextG)) or "the end of the route")
    if g.current then
        d.status:SetText("|cff66ff99You're following this zone now.|r")
    elseif g.skipped then
        d.status:SetText("|cffff8040Skipped:|r the guide leaves it out. Quests from it already in your log still count.")
    elseif AtMyLevel(g) then
        d.status:SetText("|cffffd200Right for your level.|r")
    else
        d.status:SetText("")
    end
    d.follow.text:SetText(g.current and "Following it" or (g.left == 0 and "Show it in the guide" or "Follow in the guide"))
    d.skip.text:SetText(g.skipped and "Do this zone again" or "Skip this zone")
end

---------------------------------------------------------------------------
-- The panel
---------------------------------------------------------------------------
local function ShowView(which)
    view = which
    zonesView:SetShown(view == "zones")
    if tidyView then tidyView:SetShown(view == "tidy") end
    if view == "tidy" and tidyView and tidyView.Refresh then tidyView:Refresh() end
    if view == "zones" then panel.Draw() end
end

local function Build(parent)
    panel = parent
    zonesView = CreateFrame("Frame", nil, parent)
    zonesView:SetAllPoints()
    zonesView.scroll = CreateFrame("ScrollFrame", nil, zonesView)
    zonesView.scroll:SetPoint("TOPLEFT", PAD, -8)
    zonesView.scroll:SetPoint("BOTTOMLEFT", PAD, 8)
    zonesView.scroll:SetWidth(LIST_W - PAD - 10)
    zonesView.child = CreateFrame("Frame", nil, zonesView.scroll)
    zonesView.child:SetSize(LIST_W - PAD - 10, 10)
    zonesView.scroll:SetScrollChild(zonesView.child)
    zonesView.scroll:EnableMouseWheel(true)
    zonesView.scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = math.max(0, zonesView.child:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(max, self:GetVerticalScroll() - delta * ROW_H * 3)))
    end)
    zonesView.empty = ns.Text(zonesView, 11, ns.color.dim)
    zonesView.empty:SetPoint("TOPLEFT", PAD + 10, -20)
    zonesView.empty:SetText("No zones to show - try All zones in the menu.")
    local divider = zonesView:CreateTexture(nil, "BORDER")
    divider:SetColorTexture(1, 1, 1, 0.07)
    divider:SetPoint("TOPLEFT", LIST_W, 0)
    divider:SetPoint("BOTTOMLEFT", LIST_W, 0)
    divider:SetWidth(1)
    zonesView.detail = BuildDetail(zonesView)
    if ns.BuildGuideTidy then
        tidyView = ns.BuildGuideTidy(parent)
        tidyView:Hide()
    end

    function parent.Draw()
        BuildLines()
        if not chosen or not Find(chosen) then
            for _, g in ipairs(all) do if g.current then chosen = g.name end end
        end
        DrawList()
        DrawDetail()
        if ns.ShellRefresh then ns.ShellRefresh() end
    end

    -- kept current while open (steps get done) - not while you're clicking about in it
    local elapsed = 0
    parent:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= 5 and view == "zones" and not parent:IsMouseOver() then
            elapsed = 0
            Reload()
            parent.Draw()
        end
    end)
end

---------------------------------------------------------------------------
-- The menu column, the header
---------------------------------------------------------------------------
local function Toggle(label, on, onClick)
    return { label = label, count = on and "|cff6fdc6fon|r" or "|cff777777off|r", onClick = onClick }
end

local function Menu()
    local items = { { header = true, label = "Guide" } }
    local mine = 0
    for _, g in ipairs(all) do if AtMyLevel(g) then mine = mine + 1 end end
    items[#items + 1] = { label = "Zones", count = #all, selected = view == "zones",
                          onClick = function() ShowView("zones") end }
    local tidy = ns.GuideTidyList and #ns.GuideTidyList() or 0
    items[#items + 1] = { label = "Tidy quest log", count = tidy > 0 and tidy or nil, selected = view == "tidy",
                          tip = "Quests in your log the route never uses, and grey ones, each with an Abandon button.",
                          onClick = function() ShowView("tidy") end }
    if view == "zones" then
        items[#items + 1] = { header = true, label = "Show" }
        items[#items + 1] = { label = "All zones", selected = showOnly == "all", onClick = function() showOnly = "all" panel.Draw() end }
        items[#items + 1] = { label = "At my level", count = mine, selected = showOnly == "mylevel",
                              onClick = function() showOnly = "mylevel" panel.Draw() end }
        items[#items + 1] = Toggle("Hide finished", hideDone, function() hideDone = not hideDone panel.Draw() end)
        items[#items + 1] = Toggle("Hide class training", hideClass, function() hideClass = not hideClass panel.Draw() end)
        items[#items + 1] = { label = ByRoute() and "Order: the route's" or "Order: by level", count = "|cff777777change|r",
                              tip = "By level: lowest quests first, under level headings. The route's: the order the guide takes you, under each zone.",
                              onClick = function()
                                  ns.db.guideRouteSort = ByRoute() and "level" or "route"
                                  panel.Draw()
                                  ScrollToChosen()
                              end }
    end
    items[#items + 1] = { header = true, label = "Which guide" }
    local on = ns.GuideEdition and ns.GuideEdition() or ns.db.guideEdition
    for _, g in ipairs(ns.GuideList and ns.GuideList() or {}) do
        items[#items + 1] = { label = g.name, count = g.steps, selected = g.key == on, tip = g.desc,
                              onClick = function()
                                  if g.key ~= on and ns.GuideSetEdition then
                                      ns.GuideSetEdition(g.key)
                                      ns.Print(format("Guide: following the |cffffd200%s|r route.", g.name))
                                      chosen = nil
                                      Reload(true)
                                      panel.Draw()
                                  end
                              end }
    end
    items[#items + 1] = { header = true, label = "Guide window" }
    items[#items + 1] = { label = ns.db.guide and "Hide the guide window" or "Show the guide window", onClick = function()
        ns.db.guide = not ns.db.guide
        ns.RefreshAll()
    end }
    items[#items + 1] = { label = "Find my place", tip = "Puts the guide on the first step you haven't done in the zone you're in.",
                          onClick = function() if ns.GuideCommand then ns.GuideCommand("find") end Reload(true) panel.Draw() end }
    items[#items + 1] = { label = "Guide settings", onClick = function() ns.ShellOpen("settings", "guide") end }
    return items
end

local function Title()
    return view == "tidy" and "Tidy your quest log" or "Levelling guide"
end

local function Subtitle()
    if view == "tidy" then
        local max = ns.MaxQuests and ns.MaxQuests() or 20
        local n = ns.GuideTidyList and #ns.GuideTidyList() or 0
        return format("%d / %d quests in your log  |cff777777-|r  %d you could drop", #(ns.openQuests or {}), max, n)
    end
    local _, cur, total = nil, nil, nil
    if ns.GuideCurrent then _, cur, total = ns.GuideCurrent() end
    local edition = ns.GuideEdition and ns.GuideEdition() or ""
    local skipped = 0
    for _, g in ipairs(all) do if g.skipped then skipped = skipped + 1 end end
    return format("%s route  |cff777777-|r  %d zones%s%s", edition:sub(1, 1):upper() .. edition:sub(2), #all,
        cur and format("  |cff777777-|r  step %d of %d", cur, total) or "",
        skipped > 0 and format("  |cff777777-|r  %d skipped", skipped) or "")
end

ns.ShellSection({
    key = "guide", label = "Guide", order = 1, icon = "Interface\\GossipFrame\\TaxiGossipIcon",
    build = Build, menu = Menu, title = Title, subtitle = Subtitle,
    onShow = function(sub)
        Reload(true)
        if sub == "tidy" or sub == "zones" then view = sub end
        if view == "zones" then chosen = nil end -- open on the zone you're in
        ShowView(view)
        if view == "zones" then ScrollToChosen() end
    end,
})

function ns.ToggleGuideRoute()
    ns.ShellToggle("guide", "zones")
end
