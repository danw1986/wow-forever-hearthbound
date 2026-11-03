local ADDON_NAME, ns = ...

-- Quest giver locations for the Classic dungeons, from the table you supplied
-- (October 2026). Used as a fallback: your own markers, where you actually
-- picked a quest up and Questie's database all take priority over these.
-- Three entries were corrected where they contradicted other sources:
--   An Unholy Alliance (Varimathras) 36,26 -> 56,92; Serpentbloom 34,21 -> 23.6,21.4;
--   Leaders of the Fang 45,23 -> 75.6,31.2.
--
-- Row: { title, giver, zone, x, y, faction }. Instead of a zone, "inside" (starts
-- in the dungeon), "drop" (from an item drop), "outside" (at the entrance) or
-- "patrol" (wanders; the next field names the zone). faction: "A", "H" or nil.

local QUESTS = {
    rfc = {
        { "Slaying the Beast", "Neeru Fireblade", "Orgrimmar", 49, 50, "H" },
        { "The Power to Destroy...", "Varimathras", "Undercity", 56, 92, "H" },
        { "Testing an Enemy's Strength", "Rahauro", "Thunder Bluff", 70, 30, "H" },
        { "Searching for the Lost Satchel", "Rahauro", "Thunder Bluff", 70, 30, "H" },
        { "Hidden Enemies", "Thrall", "Orgrimmar", 31, 37, "H" },
        { "Returning the Lost Satchel", "Grimtotem Satchel", "inside" },
    },
    wc = {
        { "Serpentbloom", "Apothecary Zamah", "Thunder Bluff", 23.6, 21.4, "H" },
        { "Smart Drinks", "Mebok Mizzyrix", "The Barrens", 62, 37 },
        { "Trouble at the Docks", "Crane Operator Bigglefuzz", "The Barrens", 63, 37 },
        { "Deviate Hides", "Nalpak", "The Barrens", 46, 35 },
        { "Deviate Eradication", "Ebru", "The Barrens", 46, 35 },
        { "Leaders of the Fang", "Nara Wildmane", "Thunder Bluff", 75.6, 31.2, "H" },
        { "The Glowing Shard", "Mutanus the Devourer", "inside" },
    },
    dm = {
        { "Collecting Memories", "Wilder Thistlenettle", "Stormwind", 65, 21, "A" },
        { "Oh Brother...", "Wilder Thistlenettle", "Stormwind", 65, 21, "A" },
        { "Underground Assault", "Shoni the Shilent", "Stormwind", 55, 13, "A" },
        { "Red Silk Bandanas", "Scout Riell", "Westfall", 56, 47, "A" },
        { "The Defias Brotherhood", "Gryan Stoutmantle", "Westfall", 56, 47, "A" },
        { "The Unsent Letter", "Edwin VanCleef", "drop" },
        { "The Test of Righteousness", "Jordan Stilwell", "Ironforge", 52, 36, "A" },
    },
    sfk = {
        { "The Book of Ur", "Keeper Bel'dugur", "Undercity", 53, 54, "H" },
        { "Deathstalkers in Shadowfang", "High Executor Hadrec", "Silverpine Forest", 43, 41, "H" },
        { "Arugal Must Die", "Dalar Dawnweaver", "Silverpine Forest", 44, 39, "H" },
        { "The Orb of Soran'ruk", "Doan Karhan", "The Barrens", 49, 57, "H" },
        { "The Test of Righteousness", "Jordan Stilwell", "Ironforge", 52, 36, "A" },
    },
    bfd = {
        { "The Essence of Aku'Mai", "Je'neu Sancrea", "Ashenvale", 11, 34, "H" },
        { "Amongst the Ruins", "Je'neu Sancrea", "Ashenvale", 11, 34, "H" },
        { "The Orb of Soran'ruk", "Doan Karhan", "The Barrens", 49, 57, "H" },
        { "Researching the Corruption", "Gershala Nightwhisper", "Darkshore", 38, 43, "A" },
        { "Twilight Falls", "Argent Guard Manados", "Darnassus", 55, 24, "A" },
        { "In Search of Thaelrid", "Dawnwatcher Shaedlass", "Darnassus", 55, 24 },
        { "The Test of Righteousness", "Jordan Stilwell", "Ironforge", 52, 36, "A" },
        { "Blackfathom Villainy", "Argent Guard Thaelrid", "inside" },
        { "Baron Aquanis", "Fathom Core", "drop" },
    },
    stocks = {
        { "Quell The Uprising", "Warden Thelwater", "Stormwind", 41, 58, "A" },
        { "The Stockade Riots", "Warden Thelwater", "Stormwind", 41, 58, "A" },
        { "The Color of Blood", "Nikova Raskol", "inside" },
        { "Crime and Punishment", "Councilman Millstipe", "Duskwood", 42, 47, "A" },
        { "What Comes Around...", "Guard Berton", "Redridge", 26, 46, "A" },
        { "The Fury Runs Deep", "Motley Garmason", "Wetlands", 49, 18, "A" },
    },
    gnomer = {
        { "Rig Wars", "Nogg", "Orgrimmar", 76, 25, "H" },
        { "Chief Engineer Scooty", "Sovik", "Orgrimmar", 76, 25, "H" },
        { "Gnomer-gooooone!", "Scooty", "Booty Bay", 27, 77 },
        { "Save Techbot's Brain!", "Tinkmaster Overspark", "Ironforge", 69, 50, "A" },
        { "Gyrodrillmatic Excavationators", "Shoni the Shilent", "Stormwind", 55, 12, "A" },
        { "Essential Artificials", "Klockmort Spannerspan", "Ironforge", 47, 64, "A" },
        { "Data Rescue", "Master Mechanic Castpipe", "Ironforge", 69, 48, "A" },
        { "The Grand Betrayal", "High Tinker Mekkatorque", "Ironforge", 68, 49, "A" },
        { "Gnogaine", "Ozzie Togglevolt", "Dun Morogh", 45, 49, "A" },
        { "The Only Cure is More Green Glow", "Ozzie Togglevolt", "Dun Morogh", 45, 49, "A" },
        { "The Sparklematic 5200!", "Sparklematic 5200", "inside" },
        { "A Fine Mess", "Kernobee", "inside" },
        { "Grime-Encrusted Ring", "Grime-Encrusted Ring", "drop" },
    },
    rfk = {
        { "A Vengeful Fate", "Auld Stonespire", "Thunder Bluff", 37, 29, "H" },
        { "Going, Going, Guano!", "Master Apothecary Faranell", "Undercity", 48, 69, "H" },
        { "The Crone of the Kraul", "Falfindel Waywarder", "Feralas", 89, 46, "A" },
        { "Blueleaf Tubers", "Mebok Mizzyrix", "The Barrens", 62, 37 },
        { "An Unholy Alliance", "Small Scroll", "drop", nil, nil, "H" },
        { "Mortality Wanes", "Heralath Fallowbrook", "inside", nil, nil, "A" },
        { "Willix the Importer", "Willix the Importer", "inside" },
    },
    sm = {
        { "Into The Scarlet Monastery", "Varimathras", "Undercity", 56, 92, "H" },
        { "In the Name of the Light", "Raleigh the Devout", "Hillsbrad", 51, 58, "A" },
        { "Vorrel's Revenge", "Vorrel Sengutz", "inside", nil, nil, "H" },
        { "Hearts of Zeal", "Master Apothecary Faranell", "Undercity", 48, 69, "H" },
        { "Compendium of the Fallen", "Sage Truthseeker", "Thunder Bluff", 36, 26, "H" },
        { "Test of Lore", "Parqual Fintallas", "Undercity", 57, 65, "H" },
        { "Mythology of the Titans", "Librarian Mae Paledust", "Ironforge", 75, 12, "A" },
        { "Rituals of Power", "Magus Tirth", "Thousand Needles", 78, 75 },
    },
    rfd = {
        { "Bring the End", "Andrew Brownell", "Undercity", 74, 33, "H" },
        { "An Unholy Alliance", "Varimathras", "Undercity", 56, 92, "H" },
        { "Bring the Light", "Archbishop Benedictus", "Stormwind", 39, 27, "A" },
        { "A Host of Evil", "Myriam Moonsinger", "The Barrens", 49, 95 },
        { "Scourge of the Downs", "Belnistrasz", "inside" },
        { "Extinguishing the Idol", "Belnistrasz", "inside" },
    },
    ulda = {
        { "Reclaimed Treasures", "Patrick Garrett", "Undercity", 62, 48, "H" },
        { "Uldaman Reagent Run", "Jarkal Mossmeld", "Badlands", 3, 46, "H" },
        { "Reclaimed Treasures", "Krom Stoutarm", "Ironforge", 74, 9, "A" },
        { "The Lost Dwarves", "Prospector Stormpike", "Ironforge", 75, 12, "A" },
        { "Uldaman Reagent Run", "Ghak Healtouch", "Loch Modan", 37, 49, "A" },
        { "Agmond's Fate", "Prospector Ironband", "Loch Modan", 65, 65, "A" },
        { "The Lost Tablets of Will", "Advisor Belgrum", "Ironforge", 77, 9, "A" },
        { "Power Stones", "Rigglefuzz", "Badlands", 42, 52 },
        { "Solution to Doom", "Theldurin the Lost", "Badlands", 51, 76 },
        { "Necklace Recovery", "Shattered Necklace", "drop" },
        { "The Shattered Necklace", "Shattered Necklace", "drop" },
        { "The Hidden Chamber", "Baelog's Journal", "inside" },
    },
    zf = {
        { "The Spider God", "Master Gadrin", "Durotar", 56, 74, "H" },
        { "Nekrum's Medallion", "Thadius Grimshade", "Blasted Lands", 66, 19 },
        { "Divino-matic Rod", "Chief Engineer Bilgewhizzle", "Tanaris", 52, 28 },
        { "Scarab Shells", "Tran'rek", "Tanaris", 51, 26 },
        { "Troll Temper", "Trenton Lighthammer", "Tanaris", 51, 28 },
        { "Tiara of the Deep", "Tabetha", "Dustwallow Marsh", 46, 57 },
        { "Gahz'rilla", "Wizzle Brassbolts", "Thousand Needles", 78, 77 },
        { "The Prophecy of Mosh'aru", "Yeh'kinya", "Tanaris", 67, 22 },
    },
    mara = {
        { "Shadowshard Fragments", "Uthel'nay", "Orgrimmar", 39, 86, "H" },
        { "Vyletongue Corruption", "Vark Battlescar", "Desolace", 23, 70, "H" },
        { "Corruption of Earth and Seed", "Selendra", "Desolace", 26, 77, "H" },
        { "Shadowshard Fragments", "Archmage Tervosh", "Theramore", 66, 49, "A" },
        { "Vyletongue Corruption", "Talendria", "Desolace", 68, 8, "A" },
        { "Corruption of Earth and Seed", "Keeper Marandis", "Desolace", 63, 10, "A" },
        { "Twisted Evils", "Willow", "Desolace", 62, 39 },
        { "Legends of Maraudon", "Cavindra", "outside" },
        { "Seed of Life", "Zaetar's Spirit", "inside" },
    },
    st = {
        { "The Temple of Atal'Hakkar", "Fel'zerul", "Swamp of Sorrows", 47, 54, "H" },
        { "Zapper Fuel", "Liv Rizzlefix", "The Barrens", 62, 38 },
        { "Haze of Evil", "Gregan Brewspewer", "Feralas", 45, 25 },
        { "Into The Temple of Atal'Hakkar", "Brohann Caskbelly", "Stormwind", 64, 21, "A" },
        { "Jammal'an the Prophet", "Atal'ai Exile", "The Hinterlands", 33, 75 },
        { "The Essence of Eranikus", "Marvon Rivetseeker", "Tanaris", 52, 45 },
        { "Secret of the Circle", "Marvon Rivetseeker", "Tanaris", 52, 45 },
        { "The God Hakkar", "Yeh'kinya", "Tanaris", 67, 22 },
    },
    brd = {
        { "KILL ON SIGHT: Dark Iron Dwarves", "Wanted Poster", "Kargath", 4, 47, "H" },
        { "KILL ON SIGHT: High Ranking Dark Iron Officials", "Wanted Poster", "Kargath", 4, 47, "H" },
        { "Lost Thunderbrew Recipe", "Shadowmage Vivian Lagrave", "Kargath", 3, 48, "H" },
        { "The Rise of the Machines", "Lotwil Veriatus", "Badlands", 25, 44, "H" },
        { "Disharmony of Flame", "Thunderheart", "Kargath", 3.6, 48, "H" },
        { "Disharmony of Fire", "Thunderheart", "Kargath", 3.6, 48, "H" },
        { "Commander Gor'shak", "Galamav the Marksman", "Kargath", 6, 47, "H" },
        { "The Last Element", "Vivian Lagrave", "Kargath", 3, 48, "H" },
        { "Operation: Death to Angerforge", "Warlord Goretooth", "Kargath", 6, 47, "H" },
        { "The Royal Rescue", "Thrall", "Orgrimmar", 32, 38, "H" },
        { "Overmaster Pyron", "Jalinda Sprig", "Burning Steppes", 85, 70, "A" },
        { "Incendius!", "Jalinda Sprig", "Burning Steppes", 85, 70, "A" },
        { "The Good Stuff", "Oralius", "Burning Steppes", 84, 68, "A" },
        { "Hurley Blackbreath", "Ragnar Thunderbrew", "Dun Morogh", 46, 52, "A" },
        { "Kharan Mighthammer", "King Magni Bronzebeard", "Ironforge", 39, 56, "A" },
        { "The Fate of the Kingdom", "King Magni Bronzebeard", "Ironforge", 39, 56, "A" },
        { "Marshal Windsor", "Marshal Maxwell", "Burning Steppes", 84, 68, "A" },
        { "Jail Break!", "Marshal Windsor", "inside", nil, nil, "A" },
        { "Ribbly Screwspigot", "Yuka Screwspigot", "Burning Steppes", 66, 21 },
        { "The Heart of the Mountain", "Maxwort Uberglint", "Burning Steppes", 65, 23 },
        { "Attunement to the Core", "Lothos Riftwalker", "outside" },
        { "Dark Iron Legacy", "Franclorn Forgewright", "outside" },
        { "A Taste of Flame", "Cyrus Therepentous", "Burning Steppes", 95, 31 },
        { "The Love Potion", "Mistress Nagmara", "inside" },
    },
    diremaul = {
        { "Lethtendris's Web", "Talo Thornhoof", "Feralas", 76, 43, "H" },
        { "Lethtendris's Web", "Latronicus Moonspear", "Feralas", 30, 46, "A" },
        { "Pusillin and the Elder Azj'Tordin", "Azj'Tordin", "Feralas", 76, 37 },
        { "Shards of the Felvine", "Rabine Saturna", "Moonglade", 51, 45 },
        { "Arcane Refreshment", "Lorekeeper Lydros", "inside" },
        { "The Madness Within", "Shen'dralar Ancient", "inside" },
        { "Nostro's Compendium", "Dusty Tome", "inside" },
        { "Elven Legends", "Sage Korolusk", "Feralas", 74, 43, "H" },
        { "Elven Legends", "Scholar Runethorn", "Feralas", 31, 43, "A" },
        { "Free Knot!", "Knot Thimblejack", "inside" },
        { "The Gordok Ogre Suit", "Knot Thimblejack", "inside" },
        { "The Gordok Taste Test", "Stomper Kreeg", "inside" },
        { "Unfinished Gordok Business", "Captain Kromcrush", "inside" },
    },
    lbrs = {
        { "The Pack Mistress", "Galamav the Marksman", "Kargath", 6, 47, "H" },
        { "Operative Bijou", "Lexlort", "Kargath", 5, 47, "H" },
        { "Warlord's Command", "Warlord Goretooth", "Kargath", 5, 47, "H" },
        { "Put Her Down", "Helendis Riverhorn", "Burning Steppes", 65, 69, "A" },
        { "En-Ay-Es-Tee-Why", "Kibler", "Burning Steppes", 65, 21 },
        { "Kibler's Exotic Pets", "Kibler", "Burning Steppes", 65, 21 },
        { "Mother's Milk", "Ragged John", "Burning Steppes", 65, 23 },
        { "The Final Tablets", "Prospector Ironboot", "Tanaris", 66, 24 },
        { "General Drakkisath's Command", "General Drakkisath's Command", "drop" },
        { "Bijou's Belongings", "Bijou", "inside" },
        { "Urok Doomhowl", "Warosh", "inside" },
        { "Seal of Ascension", "Quest items", "drop" },
    },
    ubrs = {
        { "The Darkstone Tablet", "Vivian Lagrave", "Kargath", 3, 48, "H" },
        { "For The Horde!", "Thrall", "Orgrimmar", 31, 37, "H" },
        { "Blood of the Black Dragon Champion", "Rexxar", "patrol", "Desolace", nil, "H" },
        { "Doomrigger's Clasp", "Mayara Brightwing", "Burning Steppes", 84, 69, "A" },
        { "General Drakkisath's Demise", "Marshal Maxwell", "Burning Steppes", 84, 68, "A" },
        { "Drakefire Amulet", "Haleh", "Winterspring", 56, 49 },
        { "Blackhand's Command", "Scarshield Quartermaster", "drop" },
        { "The Matron Protectorate", "Awbee", "inside" },
        { "Pip Quickwit, At Your Service!", "Pip Quickwit", "inside" },
        { "Egg Collection", "Tinkee Steamboil", "Burning Steppes", 65, 23 },
        { "Eye of the Emberseer", "Duke Hydraxis", "Azshara", 79, 73 },
        { "The Demon Forge", "Lorax", "Winterspring", 63, 73 },
    },
    scholo = {
        { "Barov Family Fortune", "Alexi Barov", "Tirisfal Glades", 83, 71, "H" },
        { "Barov Family Fortune", "Weldon Barov", "Western Plaguelands", 43, 83, "A" },
        { "The Darkreaver Menace", "Sagorne Creststrider", "Orgrimmar", 38, 35, "H" },
        { "Plagued Hatchlings", "Betina Bigglezink", "Eastern Plaguelands", 81, 59 },
        { "Doctor Theolen Krastinov, the Butcher", "Eva Sarkhoff", "Western Plaguelands", 70, 73 },
        { "Krastinov's Bag of Horrors", "Eva Sarkhoff", "Western Plaguelands", 70, 73 },
        { "Dawn's Gambit", "Eva Sarkhoff", "Western Plaguelands", 70, 73 },
        { "The Lich, Ras Frostwhisper", "Magistrate Marduke", "inside" },
    },
    strat = {
        { "The Great Ezra Grimm", "Smokey LaRue", "Eastern Plaguelands", 80, 58 },
        { "The Archivist", "Duke Nicholas Zverenhoff", "Eastern Plaguelands", 81, 59 },
        { "The Restless Souls", "Egan", "Eastern Plaguelands", 14, 33 },
        { "Of Love and Family", "Artist Renfray", "Western Plaguelands", 65, 75 },
        { "The Truth Comes Crashing Down", "Head of Balnazzar", "drop" },
        { "Ramstein", "Nathanos Blightcaller", "Eastern Plaguelands", 26, 74, "H" },
        { "Houses of the Holy", "Leonid Barthalomew", "Eastern Plaguelands", 81, 57 },
        { "The Flesh Does Not Lie", "Betina Bigglezink", "Eastern Plaguelands", 81, 59 },
        { "The Active Agent", "Betina Bigglezink", "Eastern Plaguelands", 81, 59 },
        { "Above and Beyond", "Duke Nicholas Zverenhoff", "Eastern Plaguelands", 81, 59 },
        { "Menethil's Gift", "Leonid Barthalomew", "Eastern Plaguelands", 81, 57 },
        { "Dead Man's Plea", "Anthion Harmon", "Eastern Plaguelands", 30, 16 },
        { "The Medallion of Faith", "Aurius", "inside" },
        { "Aurius' Reckoning", "Aurius", "inside" },
    },
}

-- Merge into ns.DUNGEONS: fill in existing quests, add the rest
local SPECIAL = { inside = true, drop = true, outside = true, patrol = true }
local PLACE = {
    inside = "Starts inside the dungeon",
    drop = "From an item that drops",
    outside = "At the dungeon entrance",
}

local function Merge()
    local byKey = {}
    for _, d in ipairs(ns.DUNGEONS) do byKey[d.key] = d end
    local norm = ns.NormalTitle or function(s) return s:lower():gsub("[^%w]", "") end
    for key, rows in pairs(QUESTS) do
        local d = byKey[key]
        if d then
            d.quests = d.quests or {}
            for _, row in ipairs(rows) do
                local title, giver, zone, x, y, faction = row[1], row[2], row[3], row[4], row[5], row[6]
                local q = {
                    title = title, giver = giver, faction = faction,
                    inside = (zone == "inside" or zone == "drop") or nil,
                    atEntrance = zone == "outside" or nil,
                }
                if zone == "patrol" then
                    q.place = "Patrols " .. tostring(x)
                elseif SPECIAL[zone] then
                    q.place = PLACE[zone]
                else
                    q.place, q.zone, q.x, q.y = zone, zone, x, y
                end
                -- the same quest can have one giver per faction, so match title and faction
                local existing
                for _, old in ipairs(d.quests) do
                    if norm(old.title) == norm(title) and (not old.faction or not faction or old.faction == faction) then
                        existing = old
                        break
                    end
                end
                if existing then
                    existing.giver = giver
                    existing.place = q.place
                    existing.faction = existing.faction or faction
                    existing.inside = q.inside
                    existing.atEntrance = q.atEntrance
                    if q.x then existing.zone, existing.x, existing.y = q.zone, q.x, q.y end
                else
                    table.insert(d.quests, q)
                end
            end
        end
    end
end

Merge()
