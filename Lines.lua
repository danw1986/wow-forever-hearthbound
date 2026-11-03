local ADDON_NAME, ns = ...

-- A simple stacked-lines renderer, used by the levelling panel and the Stats
-- tab. Callers add lines through view.add, then call view:Render(top).

local LIST_LABEL_W = 40

-- x: left offset inside parent, width: usable width
function ns.CreateLineView(parent, x, width)
    local view = { lines = {}, pool = {} }
    local lines = view.lines
    local add = {}
    view.add = add

    -- the line tables, reused: the panel rebuilds its lines every second
    local spare, used = {}, 0
    local function NewLine(kind)
        used = used + 1
        local line = spare[used]
        if line then wipe(line) else line = {} spare[used] = line end
        line.kind = kind
        lines[#lines + 1] = line
        return line
    end

    -- opts (optional): { onClick = fn, collapsed = bool } makes the heading a fold toggle
    -- opts.icon (optional): a texture for the heading; otherwise one is picked by its text
    function add.header(text, opts)
        local line = NewLine("header")
        line.text, line.onClick = text, opts and opts.onClick
        line.collapsed, line.icon = opts and opts.collapsed, opts and opts.icon
    end

    -- label on the left, value on the right
    function add.row(left, right)
        local line = NewLine("row")
        line.left, line.right = left, right
    end

    -- full-width wrapped text; onClick (optional) makes it clickable, tooltip
    -- (optional) is shown on hover
    function add.note(text, color, onClick, tooltip)
        local line = NewLine("note")
        line.text, line.color, line.onClick, line.tooltip = text, color, onClick, tooltip
    end

    -- short label on the left, wrapped text beside it
    function add.list(left, right)
        local line = NewLine("list")
        line.left, line.right = left, right
    end

    -- progress bar with text inside; value 0..1
    -- a row of items with icons, flowing onto more rows as needed:
    -- list of { name, id, icon, count, quality }; hover for the tooltip
    function add.items(list, indent)
        lines[#lines + 1] = { kind = "items", items = list, indent = indent or 0 }
    end

    function add.bar(value, left, right, color)
        lines[#lines + 1] = { kind = "bar", value = value, left = left, right = right, color = color }
    end

    function view:Begin()
        wipe(lines)
        used = 0
    end

    local function GetLine(i)
        local l = view.pool[i]
        if not l then
            l = { a = ns.Text(parent, 11), b = ns.Text(parent, 11), rule = parent:CreateTexture(nil, "ARTWORK") }
            l.a:SetJustifyV("TOP")
            l.b:SetJustifyV("TOP")
            l.rule:SetColorTexture(0.78, 0.61, 0.43, 0.25)
            l.rule:SetHeight(1)
            view.pool[i] = l
        end
        return l
    end

    -- a click area over one line, so the rest of the frame still lets clicks
    -- through to the game world
    local function ClickArea(l, line, y, height)
        if not l.click then
            l.click = CreateFrame("Button", nil, parent)
            local hl = l.click:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(0.78, 0.61, 0.43, 0.12)
            l.click:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            -- onClick gets the mouse button, for lines that do something on right-click too
            l.click:SetScript("OnClick", function(self, button) if self.onClick then self.onClick(button) end end)
            l.click:SetScript("OnEnter", function(self)
                if not self.tooltip then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            l.click:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        l.click:ClearAllPoints()
        l.click:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 2, y + 3)
        l.click:SetSize(width + 4, height)
        l.click:SetFrameLevel(parent:GetFrameLevel() + 5)
        l.click.onClick, l.click.tooltip = line.onClick, line.tooltip
        l.click:Show()
    end

    -- one item: icon + name; tooltip on hover, shift-click links it, ctrl-click tries it on
    local ITEM_H = 20
    local function ItemButton(l, i)
        l.itemButtons = l.itemButtons or {}
        local b = l.itemButtons[i]
        if b then return b end
        b = CreateFrame("Button", nil, parent)
        b:SetHeight(ITEM_H)
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetSize(ITEM_H - 2, ITEM_H - 2)
        b.icon:SetPoint("LEFT", 1, 0)
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        b.label = ns.Text(b, 11, ns.color.text)
        b.label:SetPoint("LEFT", b.icon, "RIGHT", 4, 0)
        local hl = b:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(0.78, 0.61, 0.43, 0.15)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.item.id then
                GameTooltip:SetItemByID(self.item.id)
            else
                GameTooltip:SetText(self.item.name, 1, 1, 1)
                GameTooltip:AddLine("Not in the game's item cache yet - details show once you've seen it.", 0.7, 0.7, 0.7, true)
            end
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        b:SetScript("OnClick", function(self)
            local id = self.item.id
            if not id then return end
            local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
            local _, link = getInfo(id)
            if not link then return end
            if IsShiftKeyDown() and ChatEdit_InsertLink then
                ChatEdit_InsertLink(link)
            elseif IsControlKeyDown() and DressUpItemLink then
                DressUpItemLink(link)
            end
        end)
        l.itemButtons[i] = b
        return b
    end

    local function HideItems(l)
        for _, b in ipairs(l.itemButtons or {}) do b:Hide() end
    end

    local function Style(fs, size, color)
        fs:SetFont(ns.FONT, size, "")
        fs:SetTextColor(unpack(color))
    end

    -- Lays out the lines starting at y = top; returns the y below the last line
    function view:Render(top)
        local y = top
        for i, line in ipairs(lines) do
            local l = GetLine(i)
            local a, b = l.a, l.b
            a:ClearAllPoints()
            b:ClearAllPoints()
            a:SetWidth(0)
            b:SetWidth(0)
            a:Show()
            b:Show()
            l.rule:Hide()
            if l.bar then l.bar:Hide() end
            if l.click then l.click:Hide() end
            HideItems(l)

            if line.kind == "header" then
                y = y - 7
                Style(a, 10, ns.color.gold)
                a:SetJustifyH("LEFT")
                a:SetPoint("TOPLEFT", x, y)
                -- the icon goes on after the capitals: its |t code must stay lower case
                local label = ns.HeadingIcon(line.text, line.icon) .. line.text:upper()
                if line.onClick then
                    label = (line.collapsed and "|cff999999+|r " or "|cff999999-|r ") .. label
                end
                a:SetText(label)
                b:Hide()
                l.rule:ClearAllPoints()
                l.rule:SetPoint("LEFT", a, "RIGHT", 6, 0)
                l.rule:SetWidth(math.max(4, width - a:GetStringWidth() - 6))
                l.rule:Show()
                if line.onClick then ClickArea(l, line, y, 16) end
                y = y - 15
            elseif line.kind == "row" then
                Style(a, 11, ns.color.dim)
                Style(b, 11, ns.color.text)
                a:SetJustifyH("LEFT")
                b:SetJustifyH("RIGHT")
                a:SetPoint("TOPLEFT", x, y)
                b:SetPoint("TOPRIGHT", parent, "TOPLEFT", x + width, y)
                a:SetText(line.left)
                b:SetText(line.right)
                y = y - 15
            elseif line.kind == "note" then
                Style(a, 11, line.color or ns.color.text)
                a:SetJustifyH("LEFT")
                a:SetWidth(width)
                a:SetPoint("TOPLEFT", x, y)
                a:SetText(line.text)
                b:Hide()
                if line.onClick then ClickArea(l, line, y, a:GetStringHeight() + 4) end
                y = y - a:GetStringHeight() - 3
            elseif line.kind == "list" then
                Style(a, 11, ns.color.gold)
                Style(b, 11, ns.color.text)
                a:SetJustifyH("LEFT")
                b:SetJustifyH("LEFT")
                a:SetWidth(LIST_LABEL_W)
                b:SetWidth(width - LIST_LABEL_W - 4)
                a:SetPoint("TOPLEFT", x, y)
                b:SetPoint("TOPLEFT", x + LIST_LABEL_W + 4, y)
                a:SetText(line.left)
                b:SetText(line.right)
                y = y - math.max(a:GetStringHeight(), b:GetStringHeight()) - 4
            elseif line.kind == "items" then
                a:Hide()
                b:Hide()
                local left = x + line.indent
                local cx, rowTop = left, y
                for i, item in ipairs(line.items) do
                    local button = ItemButton(l, i)
                    button.item = item
                    button.icon:SetTexture(item.icon or 134400) -- question mark when unknown
                    local qc = item.quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.quality]
                    button.label:SetText((item.name or "?") .. ((item.count and item.count > 1) and (" x" .. item.count) or ""))
                    if qc then button.label:SetTextColor(qc.r, qc.g, qc.b) else button.label:SetTextColor(unpack(ns.color.text)) end
                    local w = ITEM_H + 6 + button.label:GetStringWidth() + 6
                    if cx > left and cx + w > x + width then
                        cx, rowTop = left, rowTop - ITEM_H - 2
                    end
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", parent, "TOPLEFT", cx, rowTop)
                    button:SetWidth(w)
                    button:SetFrameLevel(parent:GetFrameLevel() + 6)
                    button:Show()
                    cx = cx + w + 6
                end
                y = rowTop - ITEM_H - 4
            elseif line.kind == "bar" then
                a:Hide()
                b:Hide()
                if not l.bar then l.bar = ns.CreateBar(parent, width, 14) end
                local bar = l.bar
                bar:ClearAllPoints()
                bar:SetPoint("TOPLEFT", x, y - 1)
                bar:Show()
                bar.bar:SetValue(math.max(0, math.min(1, line.value or 0)))
                bar.bar:SetStatusBarColor(unpack(line.color or ns.color.gold))
                bar.left:SetText(line.left or "")
                bar.right:SetText(line.right or "")
                y = y - 18
            end
        end
        for i = #lines + 1, #view.pool do
            local l = view.pool[i]
            l.a:Hide()
            l.b:Hide()
            l.rule:Hide()
            if l.bar then l.bar:Hide() end
            if l.click then l.click:Hide() end
            HideItems(l)
        end
        return y
    end

    return view
end
