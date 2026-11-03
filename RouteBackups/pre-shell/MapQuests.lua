local ADDON_NAME, ns = ...

-- Quest giver positions from Blizzard's own map data.
--
-- The retail map API can list the quests available in a zone (the "!" markers)
-- with their givers' positions. Forever runs on that client, so when you enter
-- a zone we ask for that zone's list and remember every quest it returns.
-- Whether Forever fills this in is unconfirmed: /hb mapprobe reports it.

local Safe = ns.Safe
local format = string.format

local C_QuestLine = C_QuestLine

local function Supported()
    return C_QuestLine and C_QuestLine.RequestQuestLinesForMap and C_QuestLine.GetAvailableQuestLines and true or false
end

local function CurrentMap()
    return Safe(C_Map.GetBestMapForUnit, "player")
end

-- Reads the available quests for a map into db.journal.mapQuests; returns how many
local function ReadMap(mapID)
    if not mapID or not Supported() then return 0 end
    local lines = Safe(C_QuestLine.GetAvailableQuestLines, mapID)
    if type(lines) ~= "table" then return 0 end
    local store = ns.db.journal.mapQuests
    local count = 0
    for _, info in ipairs(lines) do
        local title = info.questName
        if title and title ~= "" and info.x and info.y and not ns.IsSecret(info.x) then
            store[title:lower()] = {
                id = info.questID, title = title, mapID = mapID,
                x = info.x * 100, y = info.y * 100, time = time(),
            }
            count = count + 1
        end
    end
    return count
end

local function RequestCurrentMap()
    local mapID = CurrentMap()
    if mapID and Supported() then pcall(C_QuestLine.RequestQuestLinesForMap, mapID) end
end

function ns.MapQuest(title)
    return title and ns.db.journal.mapQuests[title:lower()]
end

function ns.MapProbe()
    local mapID = CurrentMap()
    local info = mapID and Safe(C_Map.GetMapInfo, mapID)
    ns.Print("Map quest probe:")
    ns.Print("  map API present: " .. tostring(Supported()) .. ", current map: "
        .. tostring(info and info.name or "?") .. " (" .. tostring(mapID) .. ")")
    if not Supported() then
        ns.Print("  |cffff5544This client has no quest-giver map data for addons.|r")
        return
    end
    RequestCurrentMap()
    -- the answer arrives asynchronously, so check again shortly
    C_Timer.After(2, function()
        local found = ReadMap(mapID)
        local known = 0
        for _ in pairs(ns.db.journal.mapQuests) do known = known + 1 end
        if found > 0 then
            ns.Print(format("  |cff6fdc6fWorks!|r %d available quests with giver positions in this zone (%d known in total).",
                found, known))
        else
            ns.Print("  |cffffd200No quests returned here.|r Try it in a zone where you can see quests to pick up. "
                .. "If it's always 0, this client doesn't fill in the data.")
        end
    end)
end

table.insert(ns.inits, function()
    ns.db.journal = ns.db.journal or {}
    ns.db.journal.mapQuests = ns.db.journal.mapQuests or {}
    ns.On("PLAYER_ENTERING_WORLD", function() C_Timer.After(3, RequestCurrentMap) end)
    ns.On("ZONE_CHANGED_NEW_AREA", RequestCurrentMap)
    ns.On("QUESTLINE_UPDATE", function() ReadMap(CurrentMap()) end)
end)
