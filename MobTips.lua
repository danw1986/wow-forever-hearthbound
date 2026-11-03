local ADDON_NAME, ns = ...

-- Mob tooltips: "Quest: Title - Kobold Vermin 3/10" on the mobs your quests
-- want, for kills and for the quest items they drop.
--
-- The quest log's own objectives work for every quest (Forever's new ones
-- too); QuestieDB adds which mobs drop each quest item and kill-credit groups.

local format = string.format
local Safe = ns.Safe

local YELLOW = { 1, 0.82, 0 }

---------------------------------------------------------------------------
-- NPC ID -> what your quests want from it, from QuestieDB (log quests only)
---------------------------------------------------------------------------
local byNpc
local dirty = true

local function Add(npcId, entry)
    if type(npcId) ~= "number" then return end
    byNpc[npcId] = byNpc[npcId] or {}
    table.insert(byNpc[npcId], entry)
end

local function Build()
    dirty = false
    byNpc = {}
    if not ns.QuestieGet then return end
    for _, q in ipairs(ns.openQuests or {}) do
        if not q.complete then
            local objectives = ns.QuestieGet("Quest", q.id, "objectives")
            if type(objectives) == "table" then
                -- creatures to kill: { npcId, text }
                for _, o in ipairs(type(objectives[1]) == "table" and objectives[1] or {}) do
                    local npcId = type(o) == "table" and o[1] or o
                    Add(npcId, { quest = q, kind = "kill", name = ns.QuestieGet("Npc", npcId, "name") })
                end
                -- kill credit: { { npcIds }, baseNpcId, text } - any of them counts as the base mob
                for _, o in ipairs(type(objectives[5]) == "table" and objectives[5] or {}) do
                    if type(o) == "table" and type(o[1]) == "table" then
                        local base = o[2] and ns.QuestieGet("Npc", o[2], "name")
                        for _, npcId in ipairs(o[1]) do
                            Add(npcId, { quest = q, kind = "kill", name = base or o[3] })
                        end
                    end
                end
                -- items: every mob that drops one
                for _, o in ipairs(type(objectives[3]) == "table" and objectives[3] or {}) do
                    local itemId = type(o) == "table" and o[1] or o
                    local drops = ns.QuestieGet("Item", itemId, "npcDrops")
                    local itemName = ns.QuestieGet("Item", itemId, "name")
                    for _, npcId in ipairs(type(drops) == "table" and drops or {}) do
                        Add(npcId, { quest = q, kind = "loot", name = itemName })
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------------------
-- the live count for an objective, matched by name within the same quest
local function Progress(list, name, questId)
    for _, n in ipairs(name and list[name:lower()] or {}) do
        if n.id == questId then return n end
    end
end

local function Count(n)
    if n and n.have and n.need then return format(" %d/%d", n.have, n.need) end
    return ""
end

local function AddMobLines(tooltip, unit)
    local name = Safe(UnitName, unit)
    local guid = Safe(UnitGUID, unit)
    local npcId = type(guid) == "string" and tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)"))
    if not name and not npcId then return end
    local needs, kills = ns.QuestNeeds()
    if dirty then Build() end

    local shown = {} -- "questId:kind:name" already listed
    local function Show(q, kind, label, progress)
        local key = q.id .. ":" .. kind .. ":" .. (label or "")
        if shown[key] or (progress and progress.done) then return end
        shown[key] = true
        local text = kind == "loot" and format("%s: drops %s%s", q.title, label or "a quest item", Count(progress))
            or format("%s: %s%s", q.title, label or name, Count(progress))
        tooltip:AddLine(text, YELLOW[1], YELLOW[2], YELLOW[3], true)
    end

    -- QuestieDB: kills, kill credit and drops for this exact NPC
    for _, e in ipairs(npcId and byNpc[npcId] or {}) do
        local list = e.kind == "loot" and needs or kills
        Show(e.quest, e.kind, e.name, Progress(list, e.name, e.quest.id) or (e.kind == "kill" and Progress(kills, name, e.quest.id)))
    end
    -- the quest log: kill objectives named after this mob (covers quests QuestieDB doesn't know)
    for _, n in ipairs(name and kills[name:lower()] or {}) do
        if not n.ready then
            Show({ id = n.id, title = n.title }, "kill", name, n)
        end
    end
end

-- XP per kill and kills to level, and how often it has killed you
local function AddMobExtras(tooltip, unit)
    if Safe(UnitCanAttack, "player", unit) ~= true then return end
    local name = Safe(UnitName, unit)
    local level, mine = Safe(UnitLevel, unit), UnitLevel("player")
    if type(level) == "number" and level > 0 and ns.MobXP then
        local xp = ns.MobXP(mine, level)
        local rank = Safe(UnitClassification, unit)
        if rank == "elite" or rank == "rareelite" then xp = xp * 2 end
        if xp <= 0 then
            tooltip:AddLine("No XP (too low for you)", 0.6, 0.6, 0.6)
        else
            local toLevel = (UnitXPMax("player") or 0) - (UnitXP("player") or 0)
            tooltip:AddLine(format("~%d XP  -  %d kills to level", math.floor(xp + 0.5), math.ceil(toLevel / xp)), 0.6, 0.75, 1)
        end
    end
    if name then
        local n = 0
        for _, d in ipairs(ns.cdb.deaths or {}) do if d.killer == name then n = n + 1 end end
        if n > 0 then tooltip:AddLine(format("Has killed you %d time%s", n, n == 1 and "" or "s"), 1, 0.35, 0.3) end
        local card, r, g, b = ns.CardTooltipLine and ns.CardTooltipLine(name)
        if card then tooltip:AddLine(card, r, g, b) end
    end
end

local function OnUnitTooltip(tooltip)
    if not ns.db or tooltip ~= GameTooltip then return end
    local ok, _, unit = pcall(tooltip.GetUnit, tooltip)
    if not ok or not unit or ns.IsSecret(unit) then return end
    if Safe(UnitIsPlayer, unit) ~= false then return end -- players, or can't tell
    if ns.db.mobQuestTips then pcall(AddMobLines, tooltip, unit) end
    if ns.db.mobXPTips then pcall(AddMobExtras, tooltip, unit) end
end

table.insert(ns.inits, function()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnitTooltip)
    else
        GameTooltip:HookScript("OnTooltipSetUnit", OnUnitTooltip)
    end
    ns.On("QUEST_LOG_UPDATE", function() dirty = true end)
end)
