local ADDON_NAME, ns = ...

-- Rares near you: rare and rare elite enemies the game tells us about, for the
-- quest targets window (QuestTargets.lua), which lists them at the top.
--
-- What the client says, as it says it:
--   * minimap vignettes (the star the game puts on the minimap for a rare in
--     range): C_VignetteInfo.GetVignettes / GetVignetteInfo (a creature behind
--     one is a rare) and GetVignettePosition (where it is on your map);
--   * nameplates, your target and the unit under the mouse: UnitClassification
--     "rare" or "rareelite".
-- Only rares you can fight: a unit the game says you can't attack is passed
-- over, and for a vignette (no unit to ask) an NPC QuestieDB has as friendly to
-- your side (faction leaders too). A secret value reads as unknown and the unit
-- is passed over. A rare that dies, or isn't seen for a while, drops off.

local Safe = ns.Safe

local FORGET = 30   -- seconds without a sighting before a rare drops off the list
local SCAN_EVERY = 2
local CLASS = { rare = "rare", rareelite = "rareelite" }

local nearby = {} -- npc ID (or "name:<name>") -> { id, name, level, class, spot, inSight, seen }

local function On() return ns.db and ns.db.targetsRares ~= false end

local function Plain(v)
    if v == nil or ns.IsSecret(v) then return nil end
    return v
end

-- "Creature-0-4372-0-17-61-0000123456" -> "Creature", 61
local function GuidId(guid)
    guid = Plain(guid)
    if type(guid) ~= "string" then return nil end
    local kind, _, _, _, _, id = strsplit("-", guid)
    return kind, tonumber(id)
end

local function MySide()
    local f = Safe(UnitFactionGroup, "player")
    return (f == "Horde" and "H") or (f == "Alliance" and "A") or nil
end

-- QuestieDB says this NPC is on your side
local function FriendlyNpc(id)
    local friendly = id and ns.QuestieGet and ns.QuestieGet("Npc", id, "friendlyToFaction")
    local side = MySide()
    if type(friendly) ~= "string" or not side then return false end
    return friendly == "AH" or friendly:find(side, 1, true) ~= nil
end

local function Key(id, name) return id or ("name:" .. tostring(name):lower()) end

local function Seen(e)
    local key = Key(e.id, e.name)
    local was = nearby[key]
    if was then
        was.name = e.name or was.name
        was.level = e.level or was.level
        was.class = e.class or was.class
        was.spot = e.spot or was.spot
        was.inSight = e.inSight or false
        was.seen = GetTime()
    else
        e.seen = GetTime()
        nearby[key] = e
    end
end

local function Gone(id, name) nearby[Key(id, name)] = nil end

---------------------------------------------------------------------------
-- Units: nameplates, target, mouseover
---------------------------------------------------------------------------
local function LookAt(unit)
    if not On() or not Plain(Safe(UnitExists, unit)) then return end
    local kind, id = GuidId(Safe(UnitGUID, unit))
    if kind ~= "Creature" and kind ~= "Vehicle" then return end
    local class = CLASS[Plain(Safe(UnitClassification, unit)) or ""]
    if not class then return end
    local name = Plain(Safe(UnitName, unit))
    if Plain(Safe(UnitIsDead, unit)) then return Gone(id, name) end
    local can = Plain(Safe(UnitCanAttack, "player", unit))
    if can == false then return end -- on your side
    local level = Plain(Safe(UnitLevel, unit))
    Seen({ id = id, name = name, level = type(level) == "number" and level > 0 and level or nil, class = class,
           inSight = true })
end

---------------------------------------------------------------------------
-- Vignettes
---------------------------------------------------------------------------
-- a vignette's place on your map (or the maps it sits in)
local function VignetteSpot(vguid)
    if not (C_VignetteInfo and C_VignetteInfo.GetVignettePosition) then return nil end
    local map = Safe(C_Map.GetBestMapForUnit, "player")
    for _ = 1, 3 do
        if not map then return nil end
        local pos = Safe(C_VignetteInfo.GetVignettePosition, vguid, map)
        if pos then
            local x, y
            if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
            if Plain(x) and Plain(y) and not (x == 0 and y == 0) then return { mapID = map, x = x * 100, y = y * 100 } end
        end
        local info = Safe(C_Map.GetMapInfo, map)
        map = info and info.parentMapID
    end
end

local function Scan()
    if not On() or not (C_VignetteInfo and C_VignetteInfo.GetVignettes) then return end
    if InCombatLockdown() then return end
    for _, vguid in ipairs(Safe(C_VignetteInfo.GetVignettes) or {}) do
        local info = Safe(C_VignetteInfo.GetVignetteInfo, vguid)
        local kind, id = GuidId(info and info.objectGUID)
        if kind == "Creature" and not FriendlyNpc(id) then
            local name = Plain(info.name)
            if Plain(info.isDead) then
                Gone(id, name)
            else
                local rank = ns.QuestieGet and ns.QuestieGet("Npc", id, "rank")
                local level = ns.QuestieGet and ns.QuestieGet("Npc", id, "maxLevel")
                Seen({ id = id, name = name or (ns.QuestieGet and ns.QuestieGet("Npc", id, "name")),
                       class = rank == 2 and "rareelite" or "rare", level = type(level) == "number" and level or nil,
                       spot = VignetteSpot(vguid) })
            end
        end
    end
end

---------------------------------------------------------------------------
-- For the quest targets window
---------------------------------------------------------------------------
-- { name, level, class, spot, yards, inSight } for each rare near you, nearest first
function ns.RaresNearby()
    local out = {}
    if not On() then return out end
    local now = GetTime()
    local continent, wx, wy
    if ns.PlayerWorldPos then continent, wx, wy = ns.PlayerWorldPos() end
    for key, r in pairs(nearby) do
        if now - r.seen > FORGET then
            nearby[key] = nil
        elseif r.name then
            local yards
            if r.spot and continent and ns.WorldPos then
                local c, x, y = ns.WorldPos(r.spot.mapID, r.spot.x, r.spot.y)
                if c == continent and x then yards = math.sqrt((x - wx) ^ 2 + (y - wy) ^ 2) end
            end
            -- a nameplate seen a moment ago: it's right here
            out[#out + 1] = { name = r.name, level = r.level, class = r.class, spot = r.spot, yards = yards,
                              inSight = r.inSight and now - r.seen < SCAN_EVERY * 3 }
        end
    end
    table.sort(out, function(a, b) return (a.yards or 0) < (b.yards or 0) end)
    return out
end

ns.RaresScan = Scan -- (and for the tests)
ns.RaresLookAt = LookAt

table.insert(ns.inits, function()
    ns.On("NAME_PLATE_UNIT_ADDED", function(_, unit) LookAt(unit) end)
    ns.On("PLAYER_TARGET_CHANGED", function() LookAt("target") end)
    ns.On("UPDATE_MOUSEOVER_UNIT", function() LookAt("mouseover") end)
    ns.On("VIGNETTES_UPDATED", Scan)
    ns.On("VIGNETTE_MINIMAP_UPDATED", Scan)
    ns.On("PLAYER_REGEN_ENABLED", Scan)
    C_Timer.NewTicker(SCAN_EVERY, Scan)
end)
