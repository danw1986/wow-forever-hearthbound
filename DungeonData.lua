local ADDON_NAME, ns = ...

-- Dungeon journal data.
--
-- Since the full release the journal (and the levelling guide's dungeon runs)
-- take each dungeon's quests from QuestieDB first: who gives them, where, and
-- what comes first. The quest lists below are the beta-era lists; they only
-- add rewards and fill in for quests QuestieDB doesn't have yet.
--
-- Only what a source confirms is here; everything else is learned in game
-- (see Journal.lua). Sources, checked October 2026 against beta 1.60.1:
--   new dungeons:  wow-forever.top dungeon + loot pages, Warcraft Tavern's
--                  Hall of Thanes guide (entrance and Earthseer Farsen coords)
--   classic quests: Warcraft Tavern's Classic dungeon quest list (Classic data,
--                  may differ in Forever); Wailing Caverns coords from Zockify
--   entrances marked `approx` are Classic positions, not checked in Forever
--
-- Entry fields: key, name, min, max, zone (where it is), faction ("A"/"H"/nil),
-- new, entrance { zone, x, y, approx, note }, bosses { names },
-- quests { { title, giver, place, faction, level, zone, x, y, inside, reward } },
-- loot { { boss, items = { itemID, ... } } }, classicQuests (true = Classic data)

ns.DUNGEONS = {
    ---------------------------------------------------------------------------
    -- New in WoW Forever
    ---------------------------------------------------------------------------
    {
        key = "thanes", name = "Hall of Thanes", min = 13, max = 18, zone = "Ironforge", faction = "A", new = true,
        entrance = { zone = "Ironforge", x = 43.5, y = 52.0, note = "Left of the throne room, down the cobwebbed corridor" },
        bosses = { "Faldrim Anvilmar", "Magmatus", "Plunder", "Durgen Dirgehammer" },
        quests = {
            { title = "The Restless Dead", giver = "Afadra Dunwall", place = "Outside the instance portal", faction = "A",
              level = 15, zone = "Ironforge", x = 43.5, y = 52.0, reward = "Dusty Belt or Cryptwalker Bracers" },
            { title = "Important Heirlooms", giver = "Thom Filch", place = "By the bridge at the entrance", level = 15,
              zone = "Ironforge", x = 43.5, y = 52.0, reward = "Dwarven Tome or Tomb Robber's Gloves" },
            { title = "Old Ironforge Incursion", giver = "Earthseer Farsen", place = "Dun Morogh", level = 16,
              zone = "Dun Morogh", x = 64.8, y = 58.5,
              reward = "Calibrated Blunderbuss, Ironforge Greathammer or Deepblaze" },
            { title = "An Ancient Grudge", giver = "Ghostly Attendant", place = "First room inside", level = 15, inside = true,
              reward = "Catacomb Cloak or Deepgrave Trousers" },
            { title = "The Treaty of Understanding", giver = "Tablet", place = "Final boss room", inside = true,
              reward = "Experience and gold" },
        },
        loot = {
            { boss = "Faldrim Anvilmar", items = { 270227, 271096, 271097 } },
            { boss = "Magmatus", items = { 270230, 270231, 271095 } },
            { boss = "Plunder", items = { 270228, 270229, 271098 } },
            { boss = "Durgen Dirgehammer", items = { 270256, 270260, 270261 } },
        },
    },
    {
        key = "lordaeron", name = "Ruins of Lordaeron", min = 15, max = 20, zone = "Tirisfal Glades", new = true,
        entrance = { zone = "Tirisfal Glades", x = 71.6, y = 11.4, approx = true, note = "Player-reported position" },
        bosses = { "Witherfang", "The Abandoned", "The Butcher", "Rath'mael", "Lordaeron Captain", "Viktor the Vile",
                   "Bjork", "The Baron" },
        quests = {
            { title = "The Wrath of Rath'mael", giver = "Deathguard Kristof", place = "Tirisfal Glades, south-east of Brill",
              faction = "H", level = 22, reward = "Forsaken Greataxe or Gnarled Necromancer's Staff" },
            { title = "Light's Justice", giver = "Morbin Lightbane", place = "Undercity", faction = "H", level = 22,
              reward = "The Stitcher or Spare Part Bindings" },
            { title = "A Frightened Request", giver = "Tabitha Heartweaver", place = "Silverpine Forest", faction = "H",
              level = 22, reward = "Edwards' Knife or Tabitha's Cuffs" },
            { title = "The New Plague", giver = "Theodore Griffs", place = "Undercity", faction = "H", level = 22,
              reward = "Plaguefang or Blight Gloves" },
            { title = "Unending Torment", giver = "Item drop", place = "Inside", faction = "H", level = 21, inside = true,
              reward = "Monstrous Cleaver, Grave Shroud or Slain Baron's Signet" },
            { title = "Abominable Creatures", giver = "Unconfirmed", place = "Inside", faction = "A", level = 21, inside = true,
              reward = "Monstrous Cleaver, Grave Shroud or Slain Baron's Signet" },
            { title = "Bloodied Insignia", giver = "Item drop", place = "Inside", faction = "A", level = 22, inside = true,
              reward = "Duty Bound Leggings or Remembrance Armor" },
            { title = "Remember That I Love You", giver = "Item drop", place = "Inside", faction = "A", level = 22,
              inside = true },
            { title = "Crest of Lordaeron", giver = "Item drop", place = "Inside", level = 22, inside = true,
              reward = "Small Sack of Gems" },
        },
        loot = {
            { boss = "Witherfang", items = { 271201, 271202, 271203 } },
            { boss = "The Abandoned", items = { 271207, 271208, 271216 } },
            { boss = "Bjork", items = { 271209, 271210, 271217 } },
            { boss = "Viktor the Vile", items = { 271211, 271212, 271218 } },
            { boss = "Rath'mael", items = { 271213, 271214, 271215 } },
            { boss = "The Baron", items = { 271204, 271205, 271206 } },
        },
    },
    {
        key = "excavation", name = "Excavation Site", min = 26, max = 31, zone = "Wetlands", new = true,
        entrance = { zone = "Wetlands", note = "Top of the hill above Whelgar's Excavation Site" },
        bosses = { "Saltspine", "Shadetooth", "Highland Horror", "Relic Guardian" },
        loot = { { boss = "Highland Horror", items = { 270180 } } }, -- Horrible Rootcore (quest item)
    },
    {
        key = "dalaran", name = "City of Dalaran", min = 28, max = 33, zone = "Alterac Mountains", new = true,
        entrance = { zone = "Alterac Mountains", note = "Dalaran, where the old barrier has fallen" },
        bosses = { "Arcane Anomaly", "Fel Ancient", "Mana Devourer", "Mana Elemental", "Unstable Sentinel",
                   "Shade of the Archmage", "Lyn the Ignored", "Atrexis the Grave Knight", "Mana Wraith" },
    },
    { key = "drowned", name = "The Drowned City", min = 35, max = 40, zone = "Stranglethorn Vale", new = true,
      entrance = { zone = "Stranglethorn Vale", note = "Sunken troll ruins off the coast" } },
    { key = "kroldok", name = "Krol'dok Stronghold", min = 40, max = 45, zone = "Riverglades", new = true },
    { key = "alcaz", name = "Alcaz Island Prison", min = 48, max = 53, zone = "Dustwallow Marsh", new = true },
    { key = "blackmaw", name = "Blackmaw Hold", min = 55, max = 60, zone = "Azshara", new = true },
    { key = "shapers", name = "Shaper's Terrace", min = 58, max = 60, zone = "Un'Goro Crater", new = true },

    ---------------------------------------------------------------------------
    -- Classic
    ---------------------------------------------------------------------------
    {
        key = "rfc", name = "Ragefire Chasm", min = 13, max = 18, zone = "Orgrimmar", faction = "H", classicQuests = true,
        quests = {
            { title = "Testing an Enemy's Strength", giver = "Rauharo", place = "Thunder Bluff, Elder Rise", faction = "H" },
            { title = "Searching for the Lost Satchel", giver = "Rauharo", place = "Thunder Bluff, Elder Rise", faction = "H" },
            { title = "Returning the Lost Satchel", giver = "Maur Grimtotem's corpse", place = "Inside", faction = "H", inside = true },
            { title = "Slaying the Beast", giver = "Neeru Fireblade", place = "Orgrimmar, Cleft of Shadow", faction = "H" },
            { title = "The Power to Destroy...", giver = "Varimathras", place = "Undercity, Royal Quarter", faction = "H" },
            { title = "Hidden Enemies", giver = "Thrall", place = "Orgrimmar, Valley of Wisdom", faction = "H" },
        },
    },
    {
        key = "wc", name = "Wailing Caverns", min = 17, max = 24, zone = "The Barrens", classicQuests = true,
        entrance = { zone = "The Barrens", x = 46.0, y = 36.4, approx = true },
        quests = {
            { title = "Serpentbloom", giver = "Apothecary Zamah", place = "Thunder Bluff, Spirit Rise", faction = "H",
              zone = "Thunder Bluff", x = 23.6, y = 21.4 },
            { title = "Leaders of the Fang", giver = "Nara Wildmane", place = "Thunder Bluff, Elder Rise", faction = "H",
              zone = "Thunder Bluff", x = 75.6, y = 31.2 },
            { title = "Smart Drinks", giver = "Mebok Mizzyrix", place = "Ratchet", zone = "The Barrens", x = 62.4, y = 37.6 },
            { title = "Trouble at the Docks", giver = "Crane Operator Bigglefuzz", place = "Ratchet" },
            { title = "Deviate Hides", giver = "Nalpak", place = "Above the cave entrance", zone = "The Barrens", x = 46.0, y = 35.0 },
            { title = "Deviate Eradication", giver = "Ebru", place = "Above the cave entrance" },
            { title = "The Glowing Shard", giver = "Mutanus the Devourer (drop)", place = "Inside", inside = true },
        },
    },
    {
        key = "dm", name = "The Deadmines", min = 17, max = 26, zone = "Westfall", faction = "A", classicQuests = true,
        entrance = { zone = "Westfall", x = 42.6, y = 71.8, approx = true, note = "Inside Moonbrook" },
        quests = {
            { title = "Collecting Memories", giver = "Wilder Thistlenettle", place = "Stormwind, Dwarven District", faction = "A" },
            { title = "Oh Brother...", giver = "Wilder Thistlenettle", place = "Stormwind, Dwarven District", faction = "A" },
            { title = "Underground Assault", giver = "Shoni the Shilent", place = "Stormwind, Dwarven District", faction = "A" },
            { title = "Red Silk Bandanas", giver = "Scout Riell", place = "Westfall, Sentinel Hill", faction = "A" },
            { title = "The Defias Brotherhood", giver = "Gryan Stoutmantle", place = "Westfall, Sentinel Hill", faction = "A" },
            { title = "The Unsent Letter", giver = "Edwin VanCleef (drop)", place = "Inside", faction = "A", inside = true },
        },
    },
    {
        key = "sfk", name = "Shadowfang Keep", min = 22, max = 30, zone = "Silverpine Forest", classicQuests = true,
        entrance = { zone = "Silverpine Forest", x = 44.9, y = 67.7, approx = true },
        quests = {
            { title = "Deathstalkers in Shadowfang", giver = "High Executor Hadrec", place = "Silverpine Forest, The Sepulcher", faction = "H" },
            { title = "The Book of Ur", giver = "Keeper Bel'dugur", place = "Undercity, Apothecarium", faction = "H" },
            { title = "Arugal Must Die", giver = "Dalar Dawnweaver", place = "The Sepulcher", faction = "H" },
        },
    },
    {
        key = "bfd", name = "Blackfathom Deeps", min = 24, max = 32, zone = "Ashenvale", classicQuests = true,
        entrance = { zone = "Ashenvale", x = 14.1, y = 13.9, approx = true, note = "Zoram Strand" },
        quests = {
            { title = "The Essence of Aku'Mai", giver = "Je'neu Sancrea", place = "Zoram Strand", faction = "H" },
            { title = "Amongst the Ruins", giver = "Je'neu Sancrea", place = "Zoram Strand", faction = "H" },
            { title = "Allegiance to the Old Gods", giver = "Je'neu Sancrea", place = "Zoram Strand", faction = "H" },
            { title = "Baron Aquanis", giver = "Baron Aquanis (drop)", place = "Inside", faction = "H", inside = true },
            { title = "Knowledge in the Deeps", giver = "Gerrig Bonegrip", place = "Ironforge, Forlorn Cavern", faction = "A" },
            { title = "Twilight Falls", giver = "Argent Guard Manados", place = "Darnassus, Craftsmen's Terrace", faction = "A" },
            { title = "Researching the Corruption", giver = "Gershala Nightwhisper", place = "Auberdine", faction = "A" },
            { title = "The Zoram Strand", giver = "Shindrell Swiftfire", place = "Ashenvale, Astranaar", faction = "A" },
            { title = "In Search of Thaelrid", giver = "Dawnwatcher Shaedlass", place = "Darnassus, Craftsmen's Terrace" },
            { title = "Blackfathom Villainy", giver = "Argent Guard Thaelrid", place = "Inside", inside = true },
        },
    },
    {
        key = "stocks", name = "The Stockade", min = 24, max = 32, zone = "Stormwind", faction = "A", classicQuests = true,
        quests = {
            { title = "The Stockade Riots", giver = "Warden Thelwater", place = "Stormwind, outside the Stockade", faction = "A" },
            { title = "Quell The Uprising", giver = "Warden Thelwater", place = "Stormwind, outside the Stockade", faction = "A" },
            { title = "What Comes Around...", giver = "Guard Berton", place = "Lakeshire", faction = "A" },
            { title = "Crime and Punishment", giver = "Councilman Millstipe", place = "Darkshire", faction = "A" },
            { title = "The Color of Blood", giver = "Nikova Raskol", place = "Stormwind, Old Town", faction = "A" },
            { title = "The Fury Runs Deep", giver = "Motley Garmason", place = "Wetlands, Dun Modr", faction = "A" },
        },
    },
    {
        key = "gnomer", name = "Gnomeregan", min = 29, max = 38, zone = "Dun Morogh", classicQuests = true,
        entrance = { zone = "Dun Morogh", x = 24.3, y = 39.8, approx = true },
        quests = {
            { title = "Rig Wars", giver = "Nogg", place = "Orgrimmar, Valley of Honor", faction = "H" },
            { title = "Chief Engineer Scooty", giver = "Sovik", place = "Orgrimmar, Valley of Honor", faction = "H" },
            { title = "Save Techbot's Brain!", giver = "Tinkmaster Overspark", place = "Ironforge, Tinker Town", faction = "A" },
            { title = "Gnogaine", giver = "Ozzie Togglevolt", place = "Dun Morogh, Kharanos", faction = "A" },
            { title = "The Only Cure is More Green Glow", giver = "Ozzie Togglevolt", place = "Dun Morogh, Kharanos", faction = "A" },
            { title = "Data Rescue", giver = "Master Mechanic Castpipe", place = "Ironforge, Tinker Town", faction = "A" },
            { title = "Essential Artificials", giver = "Klockmort Spannerspan", place = "Ironforge, Tinker Town", faction = "A" },
            { title = "Gyrodrillmatic Excavationators", giver = "Shoni the Shilent", place = "Stormwind, Dwarven District", faction = "A" },
            { title = "The Grand Betrayal", giver = "High Tinker Mekkatorque", place = "Ironforge, Tinker Town", faction = "A" },
            { title = "A Fine Mess", giver = "Kernobee", place = "Inside", inside = true },
        },
    },
    {
        key = "rfk", name = "Razorfen Kraul", min = 29, max = 38, zone = "The Barrens", classicQuests = true,
        entrance = { zone = "The Barrens", x = 42.3, y = 89.9, approx = true },
        quests = {
            { title = "Going, Going, Guano!", giver = "Master Apothecary Faranell", place = "Undercity, Apothecarium", faction = "H" },
            { title = "A Vengeful Fate", giver = "Auld Stonespire", place = "Thunder Bluff", faction = "H" },
            { title = "Mortality Wanes", giver = "Heralath Fallowbrook", place = "Inside", faction = "A", inside = true },
            { title = "The Crone of the Kraul", giver = "Falfindel Waywarder", place = "Thalanaar (Feralas)", faction = "A" },
            { title = "Blueleaf Tubers", giver = "Mebok Mizzyrix", place = "Ratchet", zone = "The Barrens", x = 62.4, y = 37.6 },
            { title = "Willix the Importer", giver = "Willix the Importer", place = "Inside", inside = true },
        },
    },
    {
        key = "sm", name = "Scarlet Monastery", min = 30, max = 45, zone = "Tirisfal Glades", classicQuests = true,
        entrance = { zone = "Tirisfal Glades", x = 82.6, y = 33.8, approx = true },
        quests = {
            { title = "Hearts of Zeal", giver = "Master Apothecary Faranell", place = "Undercity, Apothecarium", faction = "H" },
            { title = "Compendium of the Fallen", giver = "Sage Truthseeker", place = "Thunder Bluff", faction = "H" },
            { title = "Into The Scarlet Monastery", giver = "Varimathras", place = "Undercity, Royal Quarter", faction = "H" },
            { title = "Vorrel's Revenge", giver = "Vorrel Sengutz", place = "Inside (Graveyard)", faction = "H", inside = true },
            { title = "Test of Lore", giver = "Parqual Fintallas", place = "Undercity, Apothecarium", faction = "H" },
            { title = "Mythology of the Titans", giver = "Librarian Mae Paledust", place = "Ironforge, Hall of Explorers", faction = "A" },
            { title = "In the Name of the Light", giver = "Raleigh the Devout", place = "Southshore inn", faction = "A" },
        },
    },
    {
        key = "rfd", name = "Razorfen Downs", min = 37, max = 46, zone = "The Barrens", classicQuests = true,
        entrance = { zone = "The Barrens", x = 50.8, y = 92.8, approx = true },
        quests = {
            { title = "Bring the End", giver = "Andrew Brownell", place = "Undercity, Magic Quarter", faction = "H" },
            { title = "Bring the Light", giver = "Archbishop Benedictus", place = "Stormwind, Cathedral", faction = "A" },
            { title = "A Host of Evil", giver = "Myriam Moonsinger", place = "On the hill outside" },
            { title = "Scourge of the Downs", giver = "Belnistrasz", place = "Inside, prison cell", inside = true },
            { title = "Extinguishing the Idol", giver = "Belnistrasz", place = "Inside, prison cell", inside = true },
        },
    },
    {
        key = "ulda", name = "Uldaman", min = 41, max = 51, zone = "Badlands", classicQuests = true,
        quests = {
            { title = "Uldaman Reagent Run", giver = "Jarkal Mossmeld", place = "Badlands, Kargath", faction = "H" },
            { title = "Reclaimed Treasures", giver = "Patrick Garrett", place = "Undercity", faction = "H" },
        },
    },
    { key = "zf", name = "Zul'Farrak", min = 44, max = 54, zone = "Tanaris",
      entrance = { zone = "Tanaris", x = 38.7, y = 20.0, approx = true } },
    { key = "mara", name = "Maraudon", min = 46, max = 55, zone = "Desolace",
      entrance = { zone = "Desolace", x = 29.1, y = 62.5, approx = true } },
    { key = "st", name = "Sunken Temple", min = 50, max = 56, zone = "Swamp of Sorrows",
      entrance = { zone = "Swamp of Sorrows", x = 69.9, y = 53.6, approx = true } },
    { key = "brd", name = "Blackrock Depths", min = 52, max = 60, zone = "Blackrock Mountain" },
    { key = "lbrs", name = "Lower Blackrock Spire", min = 55, max = 60, zone = "Blackrock Mountain" },
    { key = "ubrs", name = "Upper Blackrock Spire", min = 58, max = 60, zone = "Blackrock Mountain" },
    { key = "diremaul", name = "Dire Maul", min = 55, max = 60, zone = "Feralas",
      entrance = { zone = "Feralas", x = 58.9, y = 44.9, approx = true } },
    { key = "scholo", name = "Scholomance", min = 58, max = 60, zone = "Western Plaguelands",
      entrance = { zone = "Western Plaguelands", x = 69.4, y = 72.8, approx = true } },
    { key = "strat", name = "Stratholme", min = 58, max = 60, zone = "Eastern Plaguelands",
      entrance = { zone = "Eastern Plaguelands", x = 26.8, y = 11.6, approx = true, note = "Main gate" } },
}

-- Other names the game may use for a dungeon (quest log headers, instance names)
ns.DUNGEON_ALIASES = {
    ["The Hall of Thanes"] = "thanes", ["Halls of Thanes"] = "thanes",
    ["Excavation Site: Wetlands"] = "excavation", ["Dalaran"] = "dalaran",
    ["Drowned City"] = "drowned", ["Alcaz Prison"] = "alcaz",
    ["Deadmines"] = "dm", ["Stormwind Stockade"] = "stocks", ["The Temple of Atal'Hakkar"] = "st",
    ["Temple of Atal'Hakkar"] = "st", ["Blackrock Spire"] = "lbrs",
}
