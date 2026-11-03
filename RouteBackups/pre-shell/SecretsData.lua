local ADDON_NAME, ns = ...

-- WoW Forever's hidden quests, toys, pets and collections, for the Secrets view
-- of the Quests tab. Checked October 2026 against these community guides:
--   Cozy Sleeping Bag:    Warcraft Tavern guide, Kami Labs guide (Stonetalon, dam
--                         and Thoradin's Wall coordinates), forever.warcraftdb.com IDs
--   Night Watchman's Torch: search summaries of the Icy Veins / Epic Carry articles and
--                         Gamewave's guide (no published coordinates: approximate)
--   everything else:      wowf.io hidden items + library books, wowclassicforever.info
--                         secrets, wowdb.wiki secrets guide
-- Coordinates are as those guides published them for Forever's own maps.
--
-- step fields: text, zone, x, y (map marker), approx (rough position),
--   quest (title that marks the step done), reward (what handing it in gives),
--   npc / object (name looked up in QuestieDB for a position), dungeon (opens
--   it in the journal), faction, items (reward item names, "Name x5" for a stack)
-- entry fields: key, name, kind, faction ("A"/"H"), class, race, level, reward, items,
--   what, steps, doneQuests (titles), doneItems (item names), collection (steps
--   are ticked off by hand), note

ns.SECRETS = {
    {
        key = "sleepingbag", items = { "Cozy Sleeping Bag" }, name = "Cozy Sleeping Bag", kind = "Quest chain", level = 14,
        reward = "Cozy Sleeping Bag (Well-Rested: +1% XP per stack, up to 3%, 1 hour cooldown), a 12-slot bag, Student Fodder x5",
        what = "A hidden six-step chain across both continents. Works anywhere, and stacks with Camping and food buffs.",
        doneQuests = { "This Must Be the Place" }, doneItems = { "Cozy Sleeping Bag" },
        steps = {
            { faction = "A", text = "Westfall, Alexston Farmstead: click the Nailed Plank in the wrecked cart to start \"...and that note you found\".",
              zone = "Westfall", x = 37.0, y = 50.0, quest = "...and that note you found" },
            { faction = "A", text = "The Barrens, south of Camp Taurajo: hand it in at the Burned-Out Remains (starts \"Stepping Stones\").",
              zone = "The Barrens", x = 46.0, y = 74.0, quest = "Stepping Stones",
              reward = "Swiftness Potion, Lesser Troll's Blood Potion", items = { "Swiftness Potion", "Lesser Troll's Blood Potion" } },
            { faction = "H", text = "The Barrens, south of Camp Taurajo: click the Burned-Out Remains in the burnt tower to start \"...and that note you found\".",
              zone = "The Barrens", x = 46.0, y = 74.0, quest = "...and that note you found" },
            { faction = "H", text = "Westfall, Alexston Farmstead: hand it in at the Nailed Plank in the wrecked cart (starts \"Stepping Stones\").",
              zone = "Westfall", x = 37.0, y = 50.0, quest = "Stepping Stones",
              reward = "Swiftness Potion, Lesser Troll's Blood Potion", items = { "Swiftness Potion", "Lesser Troll's Blood Potion" } },
            { text = "Stonetalon Mountains: the trail starts northeast of Sun Rock Retreat.",
              zone = "Stonetalon Mountains", x = 50.9, y = 52.3 },
            { text = "Stonetalon, abandoned camp: click the Pocket Litter on a crate (finishes \"Stepping Stones\", starts \"Scramble\"). Light the campfire with your Flint and Tinder for \"Rekindle\".",
              zone = "Stonetalon Mountains", x = 40.6, y = 52.4, quest = "Scramble",
              reward = "Flint and Tinder, Simple Wood x3, a 12-slot bag (Old Toolbox / Sturdy Lunchbox), Mining Pick or Farmer's Shovel",
              items = { "Flint and Tinder", "Simple Wood x3", "Old Toolbox", "Sturdy Lunchbox", "Mining Pick", "Farmer's Shovel" } },
            { text = "Stonetalon, up the hill to the north: jump on the Mound of Dirt (finishes \"Scramble\", starts \"Wet Job\").",
              zone = "Stonetalon Mountains", x = 39.6, y = 49.8, quest = "Wet Job",
              reward = "Student Fodder x3, 200 arrows or shot, and a choice of Silver Star / Moonsight Rifle / Precision Bow",
              items = { "Student Fodder x3", "Feathered Arrow x200", "Exploding Shot x200", "Silver Star", "Moonsight Rifle", "Precision Bow" } },
            { text = "Loch Modan, Stonewrought Dam: jump onto the ledge and click the Eagle Figurine (finishes \"Wet Job\", starts \"Eagle's Fist\").",
              zone = "Loch Modan", x = 49.4, y = 12.9, quest = "Eagle's Fist",
              reward = "Hickory Pipe, Rumsey Rum Light", items = { "Hickory Pipe", "Rumsey Rum Light" } },
            { text = "Hillsbrad Foothills, Thoradin's Wall: climb the cart onto the wall, click the Messenger Bag, then the Hastily Rolled-Up Satchel below it.",
              zone = "Hillsbrad Foothills", x = 87.3, y = 49.6, quest = "This Must Be the Place",
              reward = "Cozy Sleeping Bag, Student Fodder x5", items = { "Cozy Sleeping Bag", "Student Fodder x5" } },
        },
    },
    {
        key = "torch", items = { "Night Watchman's Torch" }, name = "Night Watchman's Torch", kind = "Toy",
        reward = "Night Watchman's Torch: hold a lit torch for 5 minutes (30 second cooldown; goes out in combat or water)",
        what = "A one-step quest, \"An Unfortunate End\", from the corpse of a slain Night Watch Guard.",
        doneQuests = { "An Unfortunate End" }, doneItems = { "Night Watchman's Torch" },
        steps = {
            { text = "Duskwood, Raven Hill: behind the biggest building, next to the outhouse. The corpse doesn't always spawn there and can turn up elsewhere in western Duskwood - try /tar Night Watch Guard.",
              zone = "Duskwood", x = 18.0, y = 56.0, approx = true, quest = "An Unfortunate End",
              reward = "Night Watchman's Torch", items = { "Night Watchman's Torch" } },
        },
    },
    {
        key = "silverwaves", items = { "Repurposed Hair Band" }, name = "Silver of the Waves", kind = "Hidden quest",
        reward = "Repurposed Hair Band (cloth wrists, +2 Intellect, +2 Spirit) and XP",
        what = "Dive for a lost hair clip and return it to its owner.",
        doneQuests = { "Silver of the Waves" },
        steps = {
            { text = "Loch Modan: dive to the Discarded Fishing Toolbox and loot the Monogrammed Silver Hair Clip.",
              zone = "Loch Modan", x = 45.6, y = 43.4 },
            { text = "Give it to Khara Deepwater at the fishing supplies.", zone = "Loch Modan", x = 39.5, y = 39.2,
              quest = "Silver of the Waves", reward = "Repurposed Hair Band, XP", items = { "Repurposed Hair Band" } },
        },
    },
    {
        key = "gustjumper", items = { "Musical Gustjumper" }, name = "Musical Gustjumper", kind = "Pet",
        reward = "A singing frog companion",
        what = "Serenade a frog choir.", collection = true,
        steps = {
            { text = "Zephras Isle (south): find the five frogs on a rock, type /sing, then right-click the frog that appears on the log beside you.",
              zone = "Zephras Isle", x = 51.5, y = 72.1 },
        },
    },
    {
        key = "whimsyfin", items = { "Savory Whimsyfin Delight" }, name = "Savory Whimsyfin Delight", kind = "Fun item",
        reward = "Eat it to become an orc in a ninja or pirate outfit",
        what = "A cooking recipe with a Redridge catch.", doneItems = { "Savory Whimsyfin Delight" }, collection = true,
        steps = {
            { text = "Get the recipe: it drops from mobs - Great Goretusks in Redridge are a good farm.", zone = "Redridge Mountains",
              npc = "Great Goretusk" },
            { text = "Fish Whimsyfin in the pools east of Lake Everstill or the river south of Stonewatch Keep.", zone = "Redridge Mountains" },
            { text = "Cook it (Cooking 85) and eat it.", zone = "Redridge Mountains" },
        },
    },
    {
        key = "rockslicer", items = { "Rockslicer" }, name = "Rockslicer", kind = "Hidden item", level = 18,
        reward = "Two-handed axe that opens Copper, Tin, Silver and Iron veins without Mining - a great warrior pick",
        what = "Drops from Rhahk'Zor, the first boss of The Deadmines.", doneItems = { "Rockslicer" },
        steps = {
            { text = "The Deadmines: kill Rhahk'Zor.", dungeon = "The Deadmines" },
        },
    },
    {
        key = "firstmate", items = { "First Mate Band" }, name = "First Mate Band", kind = "Hidden item", level = 17,
        reward = "A ring from the Partners in Crime set",
        what = "From Mr. Smite in The Deadmines.", doneItems = { "First Mate Band" },
        steps = {
            { text = "The Deadmines: defeat Mr. Smite.", dungeon = "The Deadmines" },
        },
    },
    {
        key = "kalimdor", name = "Blessing of Kalimdor", kind = "Set",
        reward = "Two pieces: 5% faster movement in The Barrens and Stonetalon Mountains",
        what = "Pieces drop from three Barrens rares.", collection = true,
        steps = {
            { text = "Humar the Pridelord (rare lion)", zone = "The Barrens", npc = "Humar the Pridelord" },
            { text = "Swiftmane (rare)", zone = "The Barrens", npc = "Swiftmane" },
            { text = "Takk the Leaper (rare raptor)", zone = "The Barrens", npc = "Takk the Leaper" },
        },
    },
    {
        key = "crocolisk", items = { "Baby Crocolisk" }, name = "Baby Crocolisk", kind = "Pet", faction = "A", level = 50,
        reward = "A crocolisk companion",
        what = "Drops from Sewer Beast, the elite crocolisk patrolling the Stormwind canals - bring friends.", collection = true,
        steps = {
            { text = "Stormwind City canals: defeat Sewer Beast (level 50 elite).", zone = "Stormwind City", npc = "Sewer Beast" },
        },
    },
    {
        key = "slime", name = "Excitable Slime", kind = "Pet", faction = "H",
        reward = "A slime companion",
        what = "Win over a slime with snacks and dancing.", collection = true,
        steps = {
            { text = "Undercity: buy Nutritious Slime Sludge from Boyle.", zone = "Undercity", x = 56.2, y = 64.6 },
            { text = "Find the Excitable Slime in the canals, /dance with it a few times, then give it the sludge.", zone = "Undercity" },
        },
    },
    {
        key = "relics", items = { "Idol of Shifting Tides", "Totem of Charged Flames" }, name = "Early relics", kind = "Hidden quest", faction = "H", class = { DRUID = true, SHAMAN = true }, level = 5,
        reward = "Idol of Shifting Tides (druid) or Totem of Charged Flames (shaman)",
        what = "A hidden follow-up in Shen'dar Village.", doneQuests = { "Meddlesome Mages" },
        steps = {
            { text = "Zephras Isle, Shen'dar Village: hand in \"Welcome to Shen'dar Village\".", zone = "Zephras Isle",
              quest = "Welcome to Shen'dar Village" },
            { text = "Talk to Illaya Amberwind and Coriella Calmbreeze, then take \"Meddlesome Mages\".", zone = "Zephras Isle",
              quest = "Meddlesome Mages", reward = "Idol of Shifting Tides (druid) / Totem of Charged Flames (shaman)",
              items = { "Idol of Shifting Tides", "Totem of Charged Flames" } },
        },
    },
    {
        key = "viper", items = { "Armor of the Fang", "Leggings of the Fang", "Footpads of the Fang", "Belt of the Fang", "Gloves of the Fang" }, name = "Embrace of the Viper", kind = "Set", class = { DRUID = true }, level = 20,
        reward = "Wear all five: Cat Form becomes a snake",
        what = "Five \"of the Fang\" pieces from Wailing Caverns.", collection = true,
        steps = {
            { text = "Armor of the Fang - Lord Pythas", dungeon = "Wailing Caverns" },
            { text = "Leggings of the Fang - Lord Cobrahn", dungeon = "Wailing Caverns" },
            { text = "Footpads of the Fang - Lord Serpentis", dungeon = "Wailing Caverns" },
            { text = "Belt of the Fang - Lady Anacondra", dungeon = "Wailing Caverns" },
            { text = "Gloves of the Fang - Wailing Caverns trash", dungeon = "Wailing Caverns" },
        },
    },
    {
        key = "coldflame", items = { "Coldflame Saber" }, name = "Coldflame Saber", kind = "Hidden item", class = { MAGE = true }, level = 21,
        reward = "A sword adding 98 Fire damage against frozen targets",
        what = "The Scroll of the Saber turns the Blade of Silverlaine into the Coldflame Saber.", doneItems = { "Coldflame Saber" },
        steps = {
            { text = "Shadowfang Keep: get the Blade of Silverlaine and use the Scroll of the Saber on it.", dungeon = "Shadowfang Keep" },
        },
    },
    {
        key = "scrolls", items = { "Bundle of Scrolls" }, name = "Bundle of Scrolls", kind = "Hidden item", class = { MAGE = true },
        reward = "Mage scrolls: summons and weapon imbues (1 hour cooldown)",
        what = "Learn Study from the library books, then use a Light Feather in a library.", collection = true,
        steps = {
            { text = "Collect library books until you learn Study (see Library books).", zone = "Stormwind City" },
            { text = "Use a Light Feather inside a library.", zone = "Stormwind City" },
        },
    },
    {
        key = "wolfsbane", items = { "Wolf's Bane" }, name = "Wolf's Bane", kind = "Class quest", class = { PALADIN = true }, race = "Scourge", level = 20,
        reward = "A weapon that punishes wolves and worgen",
        what = "A Forsaken paladin quest through three dungeons, starting in Silverpine Forest.", collection = true,
        steps = {
            { text = "Starts in Silverpine Forest; takes you through three dungeons.", zone = "Silverpine Forest" },
        },
    },
}

-- About 40 books hidden around the world; hand them to the librarian. Locations are
-- areas (no published coordinates): the addon tries QuestieDB for the spot.
local BOOKS = {
    { "Archmage Theocritus' Research Journal", "Elwynn Forest", "Tower of Azora" },
    { "Archmage Antonidas: The Unabridged Autobiography", "Ironforge" },
    { "Bewitchments and Glamours", "Westfall", "Moonbrook" },
    { "Rumi of Gnomeregan: The Collected Works", "Westfall", "Sentinel Hill" },
    { "Runes of the Sorcerer-Kings", "Loch Modan", "Mo'grosh Stronghold" },
    { "Crimes Against Anatomy", "Duskwood", "The Darkened Bank" },
    { "Goaz Scrolls", "Wetlands", "Whelgar's Excavation Site" },
    { "The Dalaran Digest, Vol. 23", "Silverpine Forest", "Ambermill" },
    { "The Apothecary's Metaphysical Primer", "Tirisfal Glades", "Brill" },
    { "Nar'thalas Almanac, Vol. 74", "Darkshore", "Ruins of Mathystra" },
    { "Arcanic Systems Manual", "The Barrens", "The Sludge Fen" },
    { "Baxtan: On Destructive Magics", "The Barrens", "Ratchet" },
    { "Secrets of the Dreamers", "The Barrens", "Lushwater Oasis" },
    { "Fury of the Land", "Stonetalon Mountains", "Grimtotem Post" },
    { "The Lessons of Ta'zo", "Orgrimmar" },
    { "Basilisks: Should Petrification be Feared?", "Stranglethorn Vale", "Crystalvein Mine" },
    { "Geomancy: The Stone-Cold Truth", "Thousand Needles", "Darkcloud Pinnacle" },
    { "Defensive Magics 101", "Alterac Mountains", "Gallows' Corner" },
    { "RwlRwlRwlRwl!", "Dustwallow Marsh", "Witch Hill" },
    { "A Web of Lies: Debunking Myths and Legends", "Arathi Highlands", "Witherbark Village" },
    { "Demons and You", "Desolace", "Thunder Axe Fortress" },
    { "Mummies: A Guide to the Unsavory Undead", "Badlands" },
    { "A Luddite's Guide to Caring for Your Demonic Pet", "Swamp of Sorrows", "Fallow Sanctuary" },
    { "Sanguine Sorcery", "Swamp of Sorrows", "Pool of Tears" },
    { "Legends of the Tidesages", "Tanaris", "Lost Rigger Cove" },
    { "Everyday Etiquette", "Azshara", "Haldarr Encampment" },
    { "Stonewrought Design", "Burning Steppes", "Blackrock Mountain" },
    { "Venomous Journeys", "The Hinterlands", "Shadra'Alor" },
    { "A Mind of Metal", "Searing Gorge", "The Cauldron" },
    { "Conjurer's Codex", "Blasted Lands" },
    { "Northern Kalimdor - A Comprehensive Guide", "Felwood", "Timbermaw Hold" },
    { "Necromancy 101", "Western Plaguelands", "Caer Darrow" },
    { "A Study of the Light", "Eastern Plaguelands", "Light's Hope Chapel" },
    { "Ka-Boom!", "Winterspring", "Everlook" },
    { "Ataeric: On Arcane Curiosities" },
    { "Undead Potatoes" },
    { "Magma or Lava?" },
    { "The Knight and the Lady" },
    { "Scourge: Undead Menace or Misunderstood?" },
}

local library = {
    key = "library", name = "Library books", kind = "Collection", collection = true, books = true,
    milestones = {
        { 10, "A neck: Scholarly Pendant or Erudite's Amulet", items = { "Scholarly Pendant", "Erudite's Amulet" } },
        { 20, "A ring: Philanthropist's Ring or Field Researcher's Loop", items = { "Philanthropist's Ring", "Field Researcher's Loop" } },
        { 25, "A weapon or shield: Truthseeker's Bow, Crest of Elucidation or Researcher's Night Light",
          items = { "Truthseeker's Bow", "Crest of Elucidation", "Researcher's Night Light" } },
    },
    reward = "A neck at 10 books, a ring at 20 and a weapon or shield at 25. Mages also learn Study.",
    what = "Books hidden all over Azeroth. Pick them up and hand them to your faction's librarian. Right-click a book to tick it off.",
    steps = {
        { faction = "A", text = "Librarian: Garion Wendell, Stormwind Mage Quarter (beside a bookcase).", zone = "Stormwind City", x = 49.0, y = 86.4, header = true },
        { faction = "H", text = "Librarian: Owen Thadd, Undercity Magic Quarter (behind the counter).", zone = "Undercity", x = 74.0, y = 32.4, header = true },
    },
}
for _, b in ipairs(BOOKS) do
    local where = b[2] and (b[2] .. (b[3] and (", " .. b[3]) or "")) or "location not published yet"
    library.steps[#library.steps + 1] = { text = b[1] .. "  |cff999999- " .. where .. "|r", zone = b[2], object = b[1], book = true }
end
table.insert(ns.SECRETS, 2, library)
