local ADDON_NAME, ns = ...

-- /hb artprobe: which dungeons have a picture, and where it comes from

local format = string.format

function ns.ArtProbe()
    ns.Print("Dungeon pictures:")
    local missing = {}
    for _, d in ipairs(ns.DUNGEONS) do
        local source = ns.DungeonArtSource and ns.DungeonArtSource(d.key)
        if source then
            DEFAULT_CHAT_FRAME:AddMessage(format("   |cff6fdc6f%s|r - %s", d.name, source))
        else
            missing[#missing + 1] = d.name
        end
    end
    if #missing > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("   |cffffd200No picture yet:|r " .. table.concat(missing, ", "))
        DEFAULT_CHAT_FRAME:AddMessage("   Save one into Hearthbound\\Images\\Incoming and run Backup Hearthbound.bat.")
    end
end
