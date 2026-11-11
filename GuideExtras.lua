local ADDON_NAME, ns = ...

-- Steps Hearthbound adds to the imported route. GuideData.lua is rebuilt from
-- the upstream guides (Tests/route_import.py); these are kept apart so they
-- survive that.
--
-- Each group goes straight after the first route step matching `after`
-- ({ t, q [, obj] }: obj must match too, and none means a step without one), in order, and takes that step's section and zone unless
-- it says otherwise. Their step numbers sit between that step's and the next
-- one's (412 + 1/64, 412 + 2/64...), so the numbers your progress is saved under don't
-- move, and the route's signature (Guide.lua) leaves them out: adding or
-- changing these never resets anyone's place.
--
-- Why each is here:
--   Rear Guard Patrol, part 2 (Undead): Ruins of Lordaeron's The Wrath of
--     Rath'mael needs it. The route already does part 1 at Deathguard Linnea's camp.
--   A Recipe For Death (all races): the three-part chain The New Plague (also
--     Ruins of Lordaeron) needs. Part 1 on the first visit to Silverpine, parts 2
--     and 3 on the second, handed in at the Undercity on the way to the dungeon.

local LINNEA = { kind = "npc", id = 1495, name = "Deathguard Linnea" }
local RENFERREL = { kind = "npc", id = 1937, name = "Apothecary Renferrel" }
local FARANELL = { kind = "npc", id = 2055, name = "Master Apothecary Faranell" }

ns.HordeGuideExtras = {
    horde = {
        -- Tirisfal Glades: part 2 straight after part 1
        { after = { t = "T", q = 356 }, steps = {
            { t = "A", q = 99156, name = "Rear Guard Patrol", z = 85, x = 65.49, y = 60.25, target = LINNEA,
              note = "Deathguard Linnea", races = { "undead" }, place = "Deathguard Linnea's camp" },
            { t = "C", q = 99156, obj = 1, name = "Rear Guard Patrol", gv = "Collect", gw = "Riptear's Heart", z = 85,
              x = 83.1, y = 45.8, note = "Kill Riptear for its heart",
              tip = "Riptear roams the hills north-east of the camp, between the camp and the Scarlet watch posts.",
              races = { "undead" }, place = "Riptear" },
            { t = "T", q = 99156, name = "Rear Guard Patrol", z = 85, x = 65.49, y = 60.25, target = LINNEA,
              note = "Deathguard Linnea", races = { "undead" }, place = "Deathguard Linnea's camp" },
        } },

        -- Silverpine Forest (12-15): part 1
        { after = { t = "A", q = 437 }, steps = {
            { t = "A", q = 447, name = "A Recipe For Death", z = 130, x = 42.8, y = 40.86, target = RENFERREL,
              note = "Apothecary Renferrel", place = "The Sepulcher" },
        } },
        { after = { t = "C", q = 437 }, steps = { -- (no obj: the walk across the Dead Field, after Nightlash)
            { t = "C", q = 447, obj = 2, name = "A Recipe For Death", gv = "Collect", gw = "Skittering Blood", z = 130,
              x = 35.4, y = 12.0, note = "Collect Skittering Blood",
              tip = "From the Moss Stalkers and Mist Creepers in the hills west of the Dead Field.",
              place = "The north-west hills" },
        } },
        { after = { t = "C", q = 421, obj = 1 }, steps = {
            { t = "C", q = 447, obj = 1, name = "A Recipe For Death", gv = "Collect", gw = "Grizzled Bear Heart", z = 130,
              x = 49.2, y = 32.9, note = "Collect Grizzled Bear Heart",
              tip = "The grizzled bears roam the forest all along the road; kill them as you go.",
              place = "Silverpine Forest: kill these as you meet them" },
        } },
        { after = { t = "T", q = 1359 }, steps = {
            { t = "T", q = 447, name = "A Recipe For Death", z = 1497, x = 48.82, y = 69.28, target = FARANELL,
              note = "Master Apothecary Faranell, in the Apothecarium", zoneName = "Undercity", place = "The Undercity" },
            { t = "A", q = 450, name = "A Recipe For Death", z = 1497, x = 48.82, y = 69.28, target = FARANELL,
              note = "Master Apothecary Faranell", zoneName = "Undercity", place = "The Undercity" },
        } },

        -- Silverpine Forest (21-22): parts 2 and 3, then the Undercity
        { after = { t = "T", q = 95885 }, steps = {
            { t = "C", q = 450, obj = 1, name = "A Recipe For Death", gv = "Collect", gw = "Berard's Journal", z = 130,
              x = 43.0, y = 73.2, note = "Collect Berard's Journal from Berard's Bookshelf",
              tip = "West along the southern road from the Offering Stone.", place = "Berard's Bookshelf" },
            { t = "T", q = 450, name = "A Recipe For Death", z = 130, x = 42.8, y = 40.86, target = RENFERREL,
              note = "Apothecary Renferrel", place = "The Sepulcher" },
            { t = "A", q = 451, name = "A Recipe For Death", z = 130, x = 42.8, y = 40.86, target = RENFERREL,
              note = "Apothecary Renferrel", place = "The Sepulcher" },
            { t = "C", q = 451, obj = 3, name = "A Recipe For Death", gv = "Collect", gw = "Hardened Tumor", z = 130,
              x = 69.6, y = 26.6, note = "Collect Hardened Tumor",
              tip = "From the Vile Fin murlocs along the shore of Lordamere Lake.", place = "Lordamere Lake shore" },
            { t = "C", q = 451, obj = 1, name = "A Recipe For Death", gv = "Collect", gw = "Lake Skulker Moss", z = 130,
              x = 71.3, y = 36.1, note = "Collect Lake Skulker Moss", place = "Lordamere Lake shore" },
            { t = "C", q = 451, obj = 2, name = "A Recipe For Death", gv = "Collect", gw = "Lake Creeper Moss", z = 130,
              x = 76.3, y = 24.0, note = "Collect Lake Creeper Moss", place = "Lordamere Lake shore" },
            { t = "T", q = 451, name = "A Recipe For Death", z = 1497, x = 48.82, y = 69.28, target = FARANELL,
              note = "Master Apothecary Faranell, in the Apothecarium", zoneName = "Undercity", place = "The Undercity" },
        } },
    },
}
