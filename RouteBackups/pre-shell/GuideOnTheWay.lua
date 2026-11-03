local ADDON_NAME, ns = ...

-- On the way: quests in your log whose mobs, items or objects are near your
-- path to the guide's current step, so you do them in passing instead of
-- coming back for them later (RestedXP's "kill these en route").
--
-- ns.GuideOnTheWay() -> { { title, label, have, need, yards, quest } }, best first

local format = string.format

local OFF_PATH_YARDS = 120 -- how far off the straight line to the step still counts
local NEAR_YARDS = 60      -- right where you are counts too, whatever the path
local MAX_SHOWN = 2
local RECALC = 2

local cache, cachedAt = {}, 0

-- distance from point p to the segment a-b, and how far along it (0..1)
local function ToSegment(px, py, ax, ay, bx, by)
    local dx, dy = bx - ax, by - ay
    local len2 = dx * dx + dy * dy
    local t = len2 > 0 and ((px - ax) * dx + (py - ay) * dy) / len2 or 0
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    local cx, cy = ax + t * dx, ay + t * dy
    return math.sqrt((px - cx) ^ 2 + (py - cy) ^ 2), t
end

local function Compute()
    local out = {}
    if not (ns.QuestObjectives and ns.PlayerWorldPos and ns.GuideArrowTarget) then return out end
    local pc, px, py = ns.PlayerWorldPos()
    if not pc then return out end
    local target, step = ns.GuideArrowTarget()
    local tx, ty
    if target and target.continent == pc then tx, ty = target.wx, target.wy else tx, ty = px, py end
    local skipQuest = step and step.q
    local best = {} -- one entry per quest objective: the closest place on your way
    for _, e in ipairs(ns.QuestObjectives() or {}) do
        local q = e.quest and e.quest.id
        if q and q ~= skipQuest and e.spots and #e.spots > 0 and e.kind ~= "explore" then
            local progress = ns.ObjectiveProgress and ns.ObjectiveProgress(e)
            local finished = progress and (progress.done or progress.ready)
            local complete = false
            for _, oq in ipairs(ns.openQuests or {}) do
                if oq.id == q and oq.complete then complete = true break end
            end
            if not finished and not complete then
                for _, sp in ipairs(e.spots) do
                    if sp.continent == pc and sp.wx then
                        local off, along = ToSegment(sp.wx, sp.wy, px, py, tx, ty)
                        local here = math.sqrt((sp.wx - px) ^ 2 + (sp.wy - py) ^ 2)
                        if off <= OFF_PATH_YARDS or here <= NEAR_YARDS then
                            local key = q .. ":" .. (e.label or "")
                            local cur = best[key]
                            if not cur or off < cur.off then
                                best[key] = { quest = q, title = e.quest.title, label = e.label, kind = e.kind,
                                              have = progress and progress.have, need = progress and progress.need,
                                              off = math.min(off, here), along = along, yards = here }
                            end
                        end
                    end
                end
            end
        end
    end
    for _, v in pairs(best) do out[#out + 1] = v end
    -- the ones closest to your path first, then the nearest
    table.sort(out, function(a, b)
        if math.floor(a.off / 40) ~= math.floor(b.off / 40) then return a.off < b.off end
        return a.yards < b.yards
    end)
    while #out > MAX_SHOWN do table.remove(out) end
    return out
end

function ns.GuideOnTheWay()
    if GetTime() - cachedAt >= RECALC then
        cachedAt = GetTime()
        local ok, result = pcall(Compute)
        cache = ok and result or {}
    end
    return cache
end

-- one line of text for the guide window
function ns.GuideOnTheWayText(list)
    local parts = {}
    for _, w in ipairs(list) do
        local verb = ({ kill = "kill", loot = "loot", object = "use" })[w.kind] or "do"
        local count = (w.have and w.need) and format(" %d/%d", w.have, w.need) or ""
        parts[#parts + 1] = format("%s |cffffd200%s|r%s |cff999999(%s)|r", verb, w.label or "?", count, w.title or "?")
    end
    return table.concat(parts, ",  ")
end
