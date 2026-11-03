-- Horde 1-60 quest route, classic edition. IDs and coordinates from Classic Era (QuestieDB data/Classic).
-- t: A=accept C=complete T=turn in D=dungeon G=go to N=note SH=set hearth H=hearth
--    FP=get flight path F=fly TR=train
-- q = quest ID, z = zone (AreaTable) ID, x/y = map percent coords, instance = dungeon area ID
-- (the arrow points at that dungeon's entrance), target = NPC/object/item to interact with,
-- races/classes = only show for these ('!' = everyone except).
-- foreverOnly = true marks a quest that is new in WoW Forever (not in Classic Era).
-- group = true marks an elite group quest outside a dungeon.
local _, ns = ...
ns.HordeGuides = ns.HordeGuides or {}
ns.HordeGuides.classic = {
  {t="A", q=4641, name="Your Place In The World", z=14, x=43.29, y=68.53, target={kind="npc", id=10176, name="Kaltunk"}, note="Talk to Kaltunk right where you spawn", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 1
  {t="T", q=4641, name="Your Place In The World", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 2
  {t="A", q=788, name="Cutting Teeth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 3
  {t="C", q=788, name="Cutting Teeth", z=14, x=44.49, y=65.1, note="Mottled Boars just north of the Den", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 4
  {t="T", q=788, name="Cutting Teeth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 5
  {t="A", q=789, name="Sting of the Scorpid", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 6
  {t="TR", text="Visit your class trainer in the Den for level 2 spells", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)"}, -- 7
  {t="A", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=42.73, y=67.23, target={kind="npc", id=9796, name="Galgar"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 8
  {t="A", q=792, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 9
  {t="A", q=1485, name="Vile Familiars", z=14, x=42.59, y=69.0, target={kind="npc", id=5765, name="Ruzan"}, note="Warlocks get their own Vile Familiars from Ruzan", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 10
  {t="C", q=789, name="Sting of the Scorpid", z=14, x=41.37, y=63.37, note="Scorpid Workers, west side of the valley", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 11
  {t="C", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=43.81, y=62.83, note="Cactus Apples sit at the base of cacti", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 12
  {t="A", q=790, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 13
  {t="C", q=790, name="Sarkoth", z=14, x=40.5, y=66.83, note="Sarkoth wanders the hill southwest of Hana'zua", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 14
  {t="T", q=790, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 15
  {t="A", q=804, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 16
  {t="G", z=14, x=44.6, y=68.7, text="Foreman Thazz'ril", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 17
  {t="A", q=5441, name="Lazy Peons", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 18
  {t="C", q=5441, name="Lazy Peons", z=14, x=45.65, y=65.7, note="Click sleeping peons with the Foreman's Blackjack around the lumber piles", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 19
  {t="T", q=789, name="Sting of the Scorpid", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 20
  {t="T", q=804, name="Sarkoth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 21
  {t="T", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=42.73, y=67.23, target={kind="npc", id=9796, name="Galgar"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 22
  {t="T", q=5441, name="Lazy Peons", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 23
  {t="A", q=6394, name="Thazz'ril's Pick", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 24
  {t="C", q=792, name="Vile Familiars", z=14, x=44.24, y=55.26, note="Vile Familiars outside Burning Blade Coven (north cave)", races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 25
  {t="C", q=1485, name="Vile Familiars", z=14, x=44.24, y=55.26, note="Vile Familiars outside Burning Blade Coven (north cave)", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 26
  {t="C", q=6394, name="Thazz'ril's Pick", z=14, x=43.73, y=53.79, note="The pick lies in the cave", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 27
  {t="T", q=792, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 28
  {t="T", q=1485, name="Vile Familiars", z=14, x=42.59, y=69.0, target={kind="npc", id=5765, name="Ruzan"}, races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 29
  {t="A", q=1499, name="Vile Familiars", z=14, x=42.59, y=69.0, target={kind="npc", id=5765, name="Ruzan"}, races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 30
  {t="T", q=1499, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, note="Hand the Vile Familiar's head chain on to Zureetha", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 31
  {t="A", q=794, name="Burning Blade Medallion", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 32
  {t="C", q=794, name="Burning Blade Medallion", z=14, x=42.71, y=52.95, note="Yarrog Baneshadow, back of the cave", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 33
  {t="T", q=794, name="Burning Blade Medallion", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 34
  {t="T", q=6394, name="Thazz'ril's Pick", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 35
  {t="A", q=805, name="Report to Sen'jin Village", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 36
  {t="TR", text="Train level 4 spells before leaving", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)"}, -- 37
  {t="A", q=2161, name="A Peon's Burden", z=14, x=52.06, y=68.31, target={kind="npc", id=6786, name="Ukor"}, note="Ukor, at the exit of the valley", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 38
  {t="G", z=14, x=54.2, y=73.3, text="Lar Prowltusk outside Sen'jin Village", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 39
  {t="A", q=786, name="Thwarting Kolkar Aggression", z=14, x=54.24, y=73.28, target={kind="npc", id=3140, name="Lar Prowltusk"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 40
  {t="T", q=805, name="Report to Sen'jin Village", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 41
  {t="A", q=808, name="Minshina's Skull", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 42
  {t="A", q=823, name="Report to Orgnil", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 43
  {t="A", q=818, name="A Solvent Spirit", z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 44
  {t="A", q=817, name="Practical Prey", z=14, x=55.96, y=73.93, target={kind="npc", id=3194, name="Vel'rin Fang"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 45
  {t="C", q=786, name="Thwarting Kolkar Aggression", z=14, x=46.23, y=78.94, note="Burn the 3 attack plans at Kolkar Crag (west)", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 46
  {t="C", q=818, name="A Solvent Spirit", z=14, x=61.06, y=72.51, note="Makrura and crawlers along the coast east of Sen'jin", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 47
  {t="C", q=817, name="Practical Prey", z=14, x=64.64, y=84.97, note="Durotar Tigers south of Sen'jin", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 48
  {t="T", q=818, name="A Solvent Spirit", z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 49
  {t="T", q=817, name="Practical Prey", z=14, x=55.96, y=73.93, target={kind="npc", id=3194, name="Vel'rin Fang"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 50
  {t="T", q=786, name="Thwarting Kolkar Aggression", z=14, x=54.24, y=73.28, target={kind="npc", id=3140, name="Lar Prowltusk"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 51
  {t="G", z=14, x=51.5, y=41.6, text="Razor Hill inn", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 52
  {t="T", q=2161, name="A Peon's Burden", z=14, x=51.51, y=41.64, target={kind="npc", id=6928, name="Innkeeper Grosk"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 53
  {t="SH", z=14, x=51.5, y=41.6, text="Razor Hill", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 54
  {t="T", q=823, name="Report to Orgnil", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 55
  {t="A", q=806, name="Dark Storms", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 56
  {t="A", q=784, name="Vanquish the Betrayers", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 57
  {t="A", q=815, name="Break a Few Eggs", z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 58
  {t="A", q=791, name="Carry Your Weight", z=14, x=49.88, y=40.39, target={kind="npc", id=3147, name="Furl Scornbrow"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 59
  {t="TR", text="Train level 6 spells", races={"orc", "troll"}, section="Razor Hill"}, -- 60
  {t="C", q=784, name="Vanquish the Betrayers", z=14, x=58.19, y=56.79, note="Kill sailors/marines on the way in, Lieutenant Benedict upstairs", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 61
  {t="A", q=830, name="The Admiral's Orders", z=14, x=59.26, y=57.65, target={kind="item", id=4881, name="Aged Envelope"}, note="The Aged Envelope can drop or sits in Benedict's chest", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 62
  {t="C", q=791, name="Carry Your Weight", z=14, x=57.38, y=58.22, note="Canvas Scraps from the Kul Tiras sailors", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 63
  {t="C", q=815, name="Break a Few Eggs", z=14, x=68.01, y=80.41, note="Taillasher Eggs on the shore south of Tiragarde", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 64
  {t="G", z=14, x=56.0, y=74.7, text="Back to Sen'jin for the Echo Isles quests", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 65
  {t="A", q=826, name="Zalazane", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 66
  {t="C", q=808, name="Minshina's Skull", z=14, x=67.45, y=87.81, note="Minshina's Skull, on the Echo Isles", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 67
  {t="C", q=826, name="Zalazane", z=14, x=67.14, y=84.99, note="Zalazane, Echo Isles (group up if you can)", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 68
  {t="T", q=808, name="Minshina's Skull", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 69
  {t="T", q=826, name="Zalazane", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 70
  {t="H", text="Razor Hill", races={"orc", "troll"}, section="Tiragarde Keep and the coast"}, -- 71
  {t="T", q=784, name="Vanquish the Betrayers", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 72
  {t="T", q=830, name="The Admiral's Orders", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 73
  {t="A", q=825, name="From The Wreckage....", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 74
  {t="T", q=791, name="Carry Your Weight", z=14, x=49.88, y=40.39, target={kind="npc", id=3147, name="Furl Scornbrow"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 75
  {t="T", q=815, name="Break a Few Eggs", z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 76
  {t="C", q=825, name="From The Wreckage....", z=14, x=63.81, y=53.01, note="Gnomish Tools in the wreckage on the coast east of Razor Hill", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 77
  {t="T", q=825, name="From The Wreckage....", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 78
  {t="A", q=837, name="Encroachment", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 79
  {t="C", q=837, name="Encroachment", z=14, x=44.18, y=49.6, note="Razormane quilboar west of Razor Hill", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 80
  {t="T", q=837, name="Encroachment", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 81
  {t="G", z=14, x=43.1, y=30.2, text="Misha Tor'kren's farmstead", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 82
  {t="A", q=816, name="Lost But Not Forgotten", z=14, x=43.1, y=30.24, target={kind="npc", id=3193, name="Misha Tor'kren"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 83
  {t="C", q=806, name="Dark Storms", z=14, x=42.12, y=26.66, note="Fizzle Darkstorm at Thunder Ridge", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 84
  {t="G", z=14, x=46.4, y=22.9, text="Rezlak, near the Orgrimmar gate", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 85
  {t="A", q=834, name="Winds in the Desert", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 86
  {t="C", q=834, name="Winds in the Desert", z=14, x=50.53, y=27.32, note="Sacks of Supplies at Drygulch Ravine", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 87
  {t="T", q=834, name="Winds in the Desert", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 88
  {t="A", q=835, name="Securing the Lines", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 89
  {t="C", q=835, name="Securing the Lines", z=14, x=51.87, y=23.53, note="Dustwind harpies in Drygulch Ravine", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 90
  {t="T", q=835, name="Securing the Lines", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 91
  {t="C", q=816, name="Lost But Not Forgotten", z=14, x=34.33, y=48.13, note="Kron's fate: look for the sign at the waypoint", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 92
  {t="T", q=816, name="Lost But Not Forgotten", z=14, x=43.1, y=30.24, target={kind="npc", id=3193, name="Misha Tor'kren"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 93
  {t="G", z=14, x=52.2, y=43.1, text="Back to Razor Hill (hearth if it is off cooldown)", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 94
  {t="T", q=806, name="Dark Storms", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 95
  {t="A", q=828, name="Margoz", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 96
  {t="A", q=840, name="Conscript of the Horde", z=14, x=50.84, y=43.59, target={kind="npc", id=3336, name="Takrin Pathseeker"}, note="Takrin Pathseeker at the Razor Hill flight tower", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 97
  {t="G", z=14, x=56.4, y=20.0, text="Margoz's hut, north", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 98
  {t="T", q=828, name="Margoz", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 99
  {t="A", q=827, name="Skull Rock", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 100
  {t="C", q=827, name="Skull Rock", z=14, x=52.7, y=11.04, note="Searing Collars from Burning Blade cultists in Skull Rock", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 101
  {t="A", q=832, name="Burning Shadows", z=14, x=51.89, y=9.58, target={kind="item", id=4903, name="Eye of Burning Shadow"}, note="Eye of Burning Shadow drops in Skull Rock", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 102
  {t="T", q=827, name="Skull Rock", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 103
  {t="A", q=829, name="Neeru Fireblade", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 104
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 105
  {t="T", q=829, name="Neeru Fireblade", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 106
  {t="T", q=832, name="Burning Shadows", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 107
  {t="A", q=809, name="Ak'Zeloth", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 108
  {t="TR", text="Train level 10/12 spells; Hunters: start the pet quests at level 10", races={"orc", "troll"}, section="Orgrimmar"}, -- 109
  {t="A", q=747, name="The Hunt Begins", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 110
  {t="A", q=752, name="A Humble Task", z=215, x=44.18, y=76.06, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 111
  {t="C", q=747, name="The Hunt Begins", z=215, x=48.15, y=81.81, note="Plainstriders around the camp", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 112
  {t="T", q=752, name="A Humble Task", z=215, x=50.03, y=81.16, target={kind="npc", id=2991, name="Greatmother Hawkwind"}, note="Greatmother Hawkwind by the well", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 113
  {t="A", q=753, name="A Humble Task", z=215, x=50.03, y=81.16, target={kind="npc", id=2991, name="Greatmother Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 114
  {t="C", q=753, name="A Humble Task", z=215, x=50.22, y=81.38, note="Fill the pitcher at the well next to her", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 115
  {t="T", q=753, name="A Humble Task", z=215, x=44.18, y=76.06, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 116
  {t="A", q=755, name="Rites of the Earthmother", z=215, x=44.18, y=76.06, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 117
  {t="T", q=747, name="The Hunt Begins", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 118
  {t="A", q=750, name="The Hunt Continues", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 119
  {t="A", q=3376, name="Break Sharptusk!", z=215, x=44.53, y=76.5, target={kind="npc", id=3209, name="Brave Windfeather"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 120
  {t="C", q=750, name="The Hunt Continues", z=215, x=48.52, y=89.78, note="Mountain Cougars in the hills", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 121
  {t="T", q=755, name="Rites of the Earthmother", z=215, x=42.57, y=92.19, target={kind="npc", id=2982, name="Seer Graytongue"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 122
  {t="A", q=757, name="Rite of Strength", z=215, x=42.57, y=92.19, target={kind="npc", id=2982, name="Seer Graytongue"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 123
  {t="C", q=757, name="Rite of Strength", z=215, x=61.58, y=78.42, note="Bristleback quilboar in Brambleblade Ravine", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 124
  {t="C", q=3376, name="Break Sharptusk!", z=215, x=64.7, y=77.66, note="Chief Sharptusk Thornmantle, back of the ravine", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 125
  {t="T", q=750, name="The Hunt Continues", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 126
  {t="A", q=780, name="The Battleboars", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 127
  {t="C", q=780, name="The Battleboars", z=215, x=56.54, y=81.96, note="Battleboars", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 128
  {t="T", q=780, name="The Battleboars", z=215, x=44.88, y=77.07, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 129
  {t="T", q=757, name="Rite of Strength", z=215, x=44.18, y=76.06, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 130
  {t="T", q=3376, name="Break Sharptusk!", z=215, x=44.53, y=76.5, target={kind="npc", id=3209, name="Brave Windfeather"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 131
  {t="A", q=763, name="Rites of the Earthmother", z=215, x=44.18, y=76.06, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 132
  {t="TR", text="Train your level 4 spells", races={"tauren"}, section="Camp Narache (Tauren)"}, -- 133
  {t="G", z=215, x=38.5, y=81.5, text="Antur Fallow, on the way out of camp", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 134
  {t="A", q=1656, name="A Task Unfinished", z=215, x=38.52, y=81.55, target={kind="npc", id=6775, name="Antur Fallow"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 135
  {t="G", z=215, x=47.5, y=60.2, text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 136
  {t="T", q=763, name="Rites of the Earthmother", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 137
  {t="A", q=767, name="Rite of Vision", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 138
  {t="T", q=1656, name="A Task Unfinished", z=215, x=46.62, y=61.09, target={kind="npc", id=6747, name="Innkeeper Kauth"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 139
  {t="SH", z=215, x=46.6, y=61.1, text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 140
  {t="A", q=745, name="Sharing the Land", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 141
  {t="A", q=761, name="Swoop Hunting", z=215, x=48.71, y=59.32, target={kind="npc", id=2947, name="Harken Windtotem"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 142
  {t="A", q=748, name="Poison Water", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 143
  {t="T", q=767, name="Rite of Vision", z=215, x=47.76, y=57.53, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 144
  {t="A", q=771, name="Rite of Vision", z=215, x=47.76, y=57.53, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 145
  {t="C", q=771, name="Rite of Vision", z=215, x=49.29, y=56.19, note="Well Stones and Ambercorn around the village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 146
  {t="T", q=771, name="Rite of Vision", z=215, x=47.76, y=57.53, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 147
  {t="A", q=772, name="Rite of Vision", z=215, x=47.76, y=57.53, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 148
  {t="C", q=748, name="Poison Water", z=215, x=42.96, y=55.01, note="Prairie Wolf Paws and Plainstrider Talons", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 149
  {t="T", q=748, name="Poison Water", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 150
  {t="A", q=754, name="Winterhoof Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 151
  {t="G", z=215, x=53.7, y=66.3, text="Winterhoof Water Well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 152
  {t="C", q=754, name="Winterhoof Cleansing", z=215, x=53.7, y=66.3, note="Use the Winterhoof Cleansing Totem at the well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 153
  {t="T", q=754, name="Winterhoof Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 154
  {t="A", q=756, name="Thunderhorn Totem", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 155
  {t="A", q=743, name="Dangers of the Windfury", z=215, x=47.35, y=62.02, target={kind="npc", id=2985, name="Ruul Eagletalon"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 156
  {t="A", q=766, name="Mazzranache", z=215, x=46.98, y=57.07, target={kind="npc", id=3055, name="Maur Raincaller"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 157
  {t="A", q=746, name="Dwarven Digging", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 158
  {t="G", z=215, x=57.2, y=61.2, text="Morin Cloudstalker, east of the village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 159
  {t="A", q=749, name="The Ravaged Caravan", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 160
  {t="C", q=743, name="Dangers of the Windfury", z=215, x=62.94, y=70.51, note="Windfury harpies at Windfury Ridge", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 161
  {t="C", q=745, name="Sharing the Land", z=215, x=35.56, y=62.44, note="Palemane gnolls", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 162
  {t="C", q=746, name="Dwarven Digging", z=215, x=31.66, y=48.89, note="Prospector's Picks from Bael'dun dwarves at the dig site", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 163
  {t="T", q=745, name="Sharing the Land", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 164
  {t="T", q=746, name="Dwarven Digging", z=215, x=47.51, y=60.16, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 165
  {t="T", q=743, name="Dangers of the Windfury", z=215, x=47.35, y=62.02, target={kind="npc", id=2985, name="Ruul Eagletalon"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 166
  {t="C", q=756, name="Thunderhorn Totem", z=215, x=49.92, y=43.22, note="Stalker and Cougar Claws", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 167
  {t="T", q=756, name="Thunderhorn Totem", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 168
  {t="A", q=758, name="Thunderhorn Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 169
  {t="G", z=215, x=44.5, y=45.3, text="Thunderhorn water well, north of Bloodhoof", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 170
  {t="C", q=758, name="Thunderhorn Cleansing", z=215, x=44.5, y=45.3, note="Use the Thunderhorn Cleansing Totem at the well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 171
  {t="T", q=758, name="Thunderhorn Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 172
  {t="A", q=759, name="Wildmane Totem", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 173
  {t="C", q=749, name="The Ravaged Caravan", z=215, x=48.53, y=60.39, note="The sealed crate at the ravaged caravan", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 174
  {t="T", q=749, name="The Ravaged Caravan", z=215, x=53.74, y=48.17, target={kind="object", id=2908, name="Sealed Supply Crate"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 175
  {t="A", q=751, name="The Ravaged Caravan", z=215, x=53.74, y=48.17, target={kind="object", id=2908, name="Sealed Supply Crate"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 176
  {t="C", q=761, name="Swoop Hunting", z=215, x=48.61, y=44.11, note="Swoops for Trophy Swoop Quills", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 177
  {t="C", q=766, name="Mazzranache", z=215, x=47.36, y=49.97, note="Mazzranache drops the last part; others drop from wolves, cougars, plainstriders, swoops", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 178
  {t="T", q=761, name="Swoop Hunting", z=215, x=48.71, y=59.32, target={kind="npc", id=2947, name="Harken Windtotem"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 179
  {t="T", q=766, name="Mazzranache", z=215, x=46.98, y=57.07, target={kind="npc", id=3055, name="Maur Raincaller"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 180
  {t="T", q=751, name="The Ravaged Caravan", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 181
  {t="A", q=764, name="The Venture Co.", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 182
  {t="A", q=765, name="Supervisor Fizsprocket", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 183
  {t="C", q=764, name="The Venture Co.", z=215, x=62.3, y=40.85, note="Venture Co. at the Venture Co. mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 184
  {t="C", q=765, name="Supervisor Fizsprocket", z=215, x=64.9, y=43.31, note="Supervisor Fizsprocket, deep in the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 185
  {t="C", q=759, name="Wildmane Totem", z=215, x=56.78, y=28.43, note="Prairie Alpha Teeth from prairie wolf alphas north of the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 186
  {t="G", z=215, x=57.2, y=61.2, text="Morin Cloudstalker", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 187
  {t="T", q=764, name="The Venture Co.", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 188
  {t="T", q=765, name="Supervisor Fizsprocket", z=215, x=57.2, y=61.22, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 189
  {t="H", text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village"}, -- 190
  {t="T", q=759, name="Wildmane Totem", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 191
  {t="A", q=760, name="Wildmane Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 192
  {t="A", q=861, name="The Hunter's Way", z=215, x=46.75, y=60.23, target={kind="npc", id=3052, name="Skorn Whitecloud"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 193
  {t="N", text="Drink the Water of the Seers by the tribal fire in Bloodhoof, then follow the spirit wolf", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 194
  {t="T", q=772, name="Rite of Vision", z=215, x=32.71, y=36.09, target={kind="npc", id=2984, name="Seer Wiserunner"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 195
  {t="A", q=773, name="Rite of Wisdom", z=215, x=32.71, y=36.09, target={kind="npc", id=2984, name="Seer Wiserunner"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 196
  {t="G", z=215, x=42.8, y=14.0, text="Wildmane water pump", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 197
  {t="C", q=760, name="Wildmane Cleansing", z=215, x=42.8, y=14.0, note="Use the Wildmane Cleansing Totem at the pump", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 198
  {t="C", q=861, name="The Hunter's Way", z=215, x=49.77, y=18.05, note="Flatland Prowlers for claws", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 199
  {t="G", z=215, x=59.9, y=25.6, text="Lorekeeper Raintotem at Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 200
  {t="A", q=833, name="A Sacred Burial", z=215, x=59.86, y=25.62, target={kind="npc", id=3233, name="Lorekeeper Raintotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 201
  {t="C", q=833, name="A Sacred Burial", z=215, x=61.03, y=21.28, note="Bristleback Interlopers at Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 202
  {t="T", q=833, name="A Sacred Burial", z=215, x=59.86, y=25.62, target={kind="npc", id=3233, name="Lorekeeper Raintotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 203
  {t="T", q=773, name="Rite of Wisdom", z=215, x=61.45, y=21.02, target={kind="npc", id=2994, name="Ancestral Spirit"}, note="The Ancestral Spirit at the top of Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 204
  {t="A", q=775, name="Journey into Thunder Bluff", z=215, x=61.45, y=21.02, target={kind="npc", id=2994, name="Ancestral Spirit"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 205
  {t="G", z=1638, x=60.3, y=51.7, text="Thunder Bluff, Cairne on the high rise", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 206
  {t="T", q=775, name="Journey into Thunder Bluff", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 207
  {t="A", q=776, name="Rites of the Earthmother", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 208
  {t="FP", z=1638, x=47.0, y=49.8, text="Thunder Bluff flight path", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 209
  {t="T", q=861, name="The Hunter's Way", z=1638, x=61.54, y=80.92, target={kind="npc", id=3441, name="Melor Stonehoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 210
  {t="A", q=860, name="Sergra Darkthorn", z=1638, x=61.54, y=80.92, target={kind="npc", id=3441, name="Melor Stonehoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 211
  {t="A", q=886, name="The Barrens Oases", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 212
  {t="G", z=1638, x=70.1, y=29.5, text="Rahauro on Elder Rise (Ragefire Chasm quests for later)", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 213
  {t="A", q=5723, name="Testing an Enemy's Strength", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 214
  {t="A", q=5722, name="Searching for the Lost Satchel", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 215
  {t="TR", text="Train level 10 spells in Thunder Bluff", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 216
  {t="C", q=776, name="Rites of the Earthmother", z=215, x=53.0, y=13.97, note="Arra'chea, the big kodo in northern Mulgore", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 217
  {t="T", q=776, name="Rites of the Earthmother", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 218
  {t="G", z=215, x=48.5, y=60.4, text="Back to Mull Thunderhorn in Bloodhoof (hearth may still be on cooldown)", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 219
  {t="T", q=760, name="Wildmane Cleansing", z=215, x=48.53, y=60.39, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 220
  {t="N", text="Run east out of Mulgore into The Barrens", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 221
  {t="A", q=363, name="Rude Awakening", z=85, x=30.22, y=71.65, target={kind="npc", id=1568, name="Undertaker Mordo"}, note="Undertaker Mordo, right in front of you", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 222
  {t="T", q=363, name="Rude Awakening", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 223
  {t="A", q=364, name="The Mindless Ones", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 224
  {t="C", q=364, name="The Mindless Ones", z=85, x=32.87, y=63.55, note="Mindless Zombies and Wretched Zombies", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 225
  {t="T", q=364, name="The Mindless Ones", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 226
  {t="A", q=3901, name="Rattling the Rattlecages", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 227
  {t="A", q=376, name="The Damned", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 228
  {t="C", q=376, name="The Damned", z=85, x=34.56, y=62.55, note="Scavenger Paws from young scavengers, Duskbat Wings from duskbats", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 229
  {t="T", q=376, name="The Damned", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 230
  {t="A", q=380, name="Night Web's Hollow", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 231
  {t="A", q=3902, name="Scavenging Deathknell", z=85, x=31.61, y=65.6, target={kind="npc", id=1740, name="Deathguard Saltain"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 232
  {t="A", q=6395, name="Marla's Last Wish", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 233
  {t="TR", text="Train your level 2 spells", races={"undead"}, section="Deathknell (Undead)"}, -- 234
  {t="C", q=3901, name="Rattling the Rattlecages", z=85, x=32.91, y=61.62, note="Rattlecage Skeletons", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 235
  {t="C", q=3902, name="Scavenging Deathknell", z=85, x=32.87, y=64.6, note="Scavenged Goods are small piles around Deathknell", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 236
  {t="C", q=6395, name="Marla's Last Wish", z=85, x=31.17, y=65.08, note="Samuel Fipps drops his remains; then use them at Marla's Grave", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 237
  {t="T", q=3901, name="Rattling the Rattlecages", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 238
  {t="T", q=3902, name="Scavenging Deathknell", z=85, x=31.61, y=65.6, target={kind="npc", id=1740, name="Deathguard Saltain"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 239
  {t="T", q=6395, name="Marla's Last Wish", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 240
  {t="C", q=380, name="Night Web's Hollow", z=85, x=27.1, y=59.18, note="Night Web's Hollow, the spider cave", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 241
  {t="T", q=380, name="Night Web's Hollow", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 242
  {t="A", q=381, name="The Scarlet Crusade", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 243
  {t="C", q=381, name="The Scarlet Crusade", z=85, x=37.58, y=67.98, note="Scarlet Converts and Initiates at Solliden Farmstead's edge", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 244
  {t="T", q=381, name="The Scarlet Crusade", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 245
  {t="A", q=382, name="The Red Messenger", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 246
  {t="C", q=382, name="The Red Messenger", z=85, x=36.57, y=68.54, note="Meven Korgal at the Scarlet camp", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 247
  {t="T", q=382, name="The Red Messenger", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 248
  {t="A", q=383, name="Vital Intelligence", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 249
  {t="TR", text="Train your level 4 spells", races={"undead"}, section="Deathknell (Undead)"}, -- 250
  {t="G", z=85, x=38.2, y=56.8, text="Calvin Montague, outside Deathknell", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 251
  {t="A", q=8, name="A Rogue's Deal", z=85, x=38.23, y=56.79, target={kind="npc", id=6784, name="Calvin Montague"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 252
  {t="G", z=85, x=40.9, y=54.2, text="Deathguard Simmer on the road to Brill", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 253
  {t="A", q=365, name="Fields of Grief", z=85, x=40.91, y=54.17, target={kind="npc", id=1519, name="Deathguard Simmer"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 254
  {t="G", z=85, x=43.1, y=54.7, text="Gordo, wandering the road", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 255
  {t="A", q=5481, name="Gordo's Task", z=85, x=43.06, y=54.69, target={kind="npc", id=10666, name="Gordo"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 256
  {t="C", q=365, name="Fields of Grief", z=85, x=35.86, y=50.49, note="Pumpkins in the farm field", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 257
  {t="C", q=5481, name="Gordo's Task", z=85, x=48.7, y=54.9, note="Gloom Weed grows along the road", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 258
  {t="G", z=85, x=61.7, y=52.0, text="Brill inn", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 259
  {t="T", q=8, name="A Rogue's Deal", z=85, x=61.71, y=52.05, target={kind="npc", id=5688, name="Innkeeper Renee"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 260
  {t="SH", z=85, x=61.7, y=52.0, text="Brill", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 261
  {t="T", q=383, name="Vital Intelligence", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 262
  {t="A", q=427, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 263
  {t="T", q=365, name="Fields of Grief", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 264
  {t="A", q=407, name="Fields of Grief", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 265
  {t="T", q=407, name="Fields of Grief", z=85, x=61.97, y=51.29, target={kind="npc", id=1931, name="Captured Scarlet Zealot"}, note="The Captured Scarlet Zealot in the town hall", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 266
  {t="A", q=404, name="A Putrid Task", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 267
  {t="A", q=358, name="Graverobbers", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 268
  {t="T", q=5481, name="Gordo's Task", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 269
  {t="A", q=5482, name="Doom Weed", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 270
  {t="TR", text="Train your level 6 spells", races={"undead"}, section="Brill"}, -- 271
  {t="C", q=404, name="A Putrid Task", z=85, x=53.32, y=54.14, note="Rotting Dead / ghouls for Putrid Claws", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 272
  {t="C", q=358, name="Graverobbers", z=85, x=57.59, y=39.38, note="Rot Hide Graverobbers and Mongrels", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 273
  {t="G", z=85, x=61.7, y=52.0, text="Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 274
  {t="T", q=404, name="A Putrid Task", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 275
  {t="A", q=426, name="The Mills Overrun", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 276
  {t="A", q=367, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 277
  {t="A", q=398, name="Wanted: Maggot Eye", z=85, x=60.74, y=51.5, target={kind="object", id=711, name="Wanted!"}, note="Wanted poster outside the town hall", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 278
  {t="A", q=362, name="The Haunted Mills", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 279
  {t="A", q=354, name="Deaths in the Family", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 280
  {t="C", q=367, name="A New Plague", z=85, x=63.33, y=50.83, note="Vials of Darkhound Blood from darkhounds", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 281
  {t="C", q=427, name="At War With The Scarlet Crusade", z=85, x=32.08, y=47.4, note="Scarlet Warriors at Solliden Farmstead", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 282
  {t="C", q=5482, name="Doom Weed", z=85, x=57.14, y=39.77, note="Doom Weed at the graveyard north of Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 283
  {t="C", q=398, name="Wanted: Maggot Eye", z=85, x=58.66, y=30.77, note="Maggot Eye in the cottage north of the graveyard", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 284
  {t="C", q=426, name="The Mills Overrun", z=85, x=46.91, y=34.88, note="Agamand Mills: Notched Ribs and Blackened Skulls from skeletons", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 285
  {t="C", q=362, name="The Haunted Mills", z=85, x=47.34, y=40.78, note="Devlin Agamand", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 286
  {t="C", q=354, name="Deaths in the Family", z=85, x=44.0, y=33.64, note="Gregor, Nissa and Thurman Agamand's remains", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 287
  {t="A", q=361, name="A Letter Undelivered", z=85, x=46.91, y=34.88, target={kind="item", id=2839, name="A Letter to Yvette"}, note="The letter for Yvette drops at the Mills", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 288
  {t="G", z=85, x=61.7, y=52.0, text="Back to Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 289
  {t="T", q=358, name="Graverobbers", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 290
  {t="T", q=5482, name="Doom Weed", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 291
  {t="T", q=427, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 292
  {t="A", q=374, name="Proof of Demise", z=85, x=60.93, y=52.01, target={kind="npc", id=1652, name="Deathguard Burgess"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 293
  {t="A", q=375, name="The Chill of Death", z=85, x=61.89, y=52.73, target={kind="npc", id=1521, name="Gretchen Dedmar"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 294
  {t="N", text="Buy 1 Coarse Thread from the trade goods vendor for The Chill of Death", races={"undead"}, section="Around Brill"}, -- 295
  {t="T", q=367, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 296
  {t="T", q=398, name="Wanted: Maggot Eye", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 297
  {t="T", q=426, name="The Mills Overrun", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 298
  {t="T", q=362, name="The Haunted Mills", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 299
  {t="T", q=354, name="Deaths in the Family", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 300
  {t="T", q=361, name="A Letter Undelivered", z=85, x=61.58, y=52.6, target={kind="npc", id=1560, name="Yvette Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 301
  {t="A", q=359, name="Forsaken Duties", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 302
  {t="A", q=405, name="The Prodigal Lich", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 303
  {t="A", q=368, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 304
  {t="A", q=370, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 305
  {t="A", q=355, name="Speak with Sevren", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 306
  {t="T", q=355, name="Speak with Sevren", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 307
  {t="A", q=408, name="The Family Crypt", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 308
  {t="TR", text="Train your level 8 spells", races={"undead"}, section="Around Brill"}, -- 309
  {t="T", q=359, name="Forsaken Duties", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, note="Deathguard Linnea at the eastern bulwark road", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 310
  {t="A", q=360, name="Return to the Magistrate", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 311
  {t="A", q=356, name="Rear Guard Patrol", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 312
  {t="C", q=356, name="Rear Guard Patrol", z=85, x=76.48, y=60.74, note="Bleeding Horrors and Wandering Spirits", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 313
  {t="C", q=370, name="At War With The Scarlet Crusade", z=85, x=53.66, y=66.0, note="Captain Perrine and Scarlet Zealots/Missionaries", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 314
  {t="C", q=368, name="A New Plague", z=85, x=59.43, y=29.07, note="Vile Fin murlocs for scales", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 315
  {t="C", q=374, name="Proof of Demise", z=85, x=76.62, y=54.76, note="Scarlet Insignia Rings from Scarlet humans", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 316
  {t="C", q=375, name="The Chill of Death", z=85, x=65.07, y=54.57, note="Duskbats for pelts", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 317
  {t="T", q=356, name="Rear Guard Patrol", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 318
  {t="T", q=360, name="Return to the Magistrate", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 319
  {t="T", q=368, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 320
  {t="A", q=369, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 321
  {t="T", q=370, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 322
  {t="A", q=371, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 323
  {t="G", z=1497, x=84.1, y=17.4, text="Undercity, Bethor Iceshard in the Magic Quarter", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 324
  {t="T", q=405, name="The Prodigal Lich", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 325
  {t="A", q=357, name="The Lich's Identity", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 326
  {t="FP", z=1497, x=63.2, y=48.6, text="Undercity flight path (Michael Garrett)", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 327
  {t="TR", text="Train your level 10 spells in Undercity", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 328
  {t="C", q=357, name="The Lich's Identity", z=85, x=67.96, y=42.09, note="The Lich's Spellbook on Gunther's Retreat island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 329
  {t="G", z=1497, x=84.1, y=17.4, text="Back to Bethor Iceshard in Undercity", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 330
  {t="T", q=357, name="The Lich's Identity", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 331
  {t="A", q=366, name="Return the Book", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 332
  {t="G", z=85, x=68.2, y=41.9, text="Gunther's Retreat island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 333
  {t="T", q=366, name="Return the Book", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 334
  {t="A", q=409, name="Proving Allegiance", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 335
  {t="G", z=85, x=68.2, y=42.0, text="Crate of Candles on the island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 336
  {t="N", text="Take a Candle of Beckoning, then use it at Lillith's Dinner Table to summon Lillith Nefara", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 337
  {t="G", z=85, x=66.6, y=44.9, text="Lillith's Dinner Table", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 338
  {t="C", q=409, name="Proving Allegiance", z=85, x=66.6, y=44.9, note="Kill Lillith Nefara", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 339
  {t="T", q=409, name="Proving Allegiance", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 340
  {t="A", q=411, name="The Prodigal Lich Returns", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 341
  {t="C", q=371, name="At War With The Scarlet Crusade", z=85, x=79.45, y=55.51, note="Captain Vachon at the Scarlet Watch post", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 342
  {t="C", q=369, name="A New Plague", z=85, x=86.74, y=53.2, note="Venom samples from Vicious Night Web spiders", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 343
  {t="C", q=408, name="The Family Crypt", z=85, x=51.87, y=28.76, note="Wailing and Rotting Ancestors in the Agamand Family Crypt", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 344
  {t="H", text="Brill", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 345
  {t="T", q=369, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 346
  {t="A", q=492, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 347
  {t="T", q=492, name="A New Plague", z=85, x=61.94, y=51.4, target={kind="npc", id=2211, name="Captured Mountaineer"}, note="Give Johaan's Special Drink to the Captured Mountaineer", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 348
  {t="T", q=374, name="Proof of Demise", z=85, x=60.93, y=52.01, target={kind="npc", id=1652, name="Deathguard Burgess"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 349
  {t="T", q=375, name="The Chill of Death", z=85, x=61.89, y=52.73, target={kind="npc", id=1521, name="Gretchen Dedmar"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 350
  {t="T", q=371, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 351
  {t="A", q=372, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 352
  {t="T", q=408, name="The Family Crypt", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 353
  {t="A", q=445, name="Delivery to Silverpine Forest", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 354
  {t="C", q=372, name="At War With The Scarlet Crusade", z=85, x=79.44, y=25.12, note="Captain Melrache at the Scarlet camp north of Brill", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 355
  {t="T", q=372, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 356
  {t="G", z=1497, x=84.1, y=17.4, text="Undercity, Bethor Iceshard", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 357
  {t="T", q=411, name="The Prodigal Lich Returns", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 358
  {t="N", text="Leave Undercity west and head into Silverpine Forest", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)"}, -- 359
  {t="G", z=130, x=43.4, y=41.7, text="The Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 360
  {t="T", q=445, name="Delivery to Silverpine Forest", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 361
  {t="A", q=421, name="Prove Your Worth", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 362
  {t="A", q=428, name="Lost Deathstalkers", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 363
  {t="A", q=437, name="The Dead Fields", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 364
  {t="A", q=477, name="Border Crossings", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 365
  {t="A", q=447, name="A Recipe For Death", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 366
  {t="FP", z=130, x=45.6, y=42.6, text="Sepulcher flight path (Karos Razok)", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 367
  {t="SH", z=130, x=43.2, y=41.3, text="The Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 368
  {t="C", q=421, name="Prove Your Worth", z=130, x=53.0, y=26.69, note="Moonrage Whitescalps", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 369
  {t="C", q=447, name="A Recipe For Death", z=130, x=45.97, y=18.26, note="Grizzled Bear Hearts and Skittering Blood from bears and spiders", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 370
  {t="T", q=428, name="Lost Deathstalkers", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, note="Rane Yorick at the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 371
  {t="A", q=429, name="Wild Hearts", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 372
  {t="C", q=429, name="Wild Hearts", z=130, x=54.88, y=13.61, note="Discolored worg hearts from worgs", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 373
  {t="G", z=130, x=56.2, y=9.2, text="Deathstalker Erland, north of the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 374
  {t="A", q=435, name="Escorting Erland", z=130, x=56.18, y=9.18, target={kind="npc", id=1978, name="Deathstalker Erland"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 375
  {t="C", q=435, name="Escorting Erland", z=130, x=56.18, y=9.18, note="Escort Erland back to Rane", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 376
  {t="T", q=435, name="Escorting Erland", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 377
  {t="A", q=449, name="The Deathstalkers' Report", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 378
  {t="G", z=130, x=44.7, y=22.6, text="The Dead Fields", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 379
  {t="C", q=437, name="The Dead Fields", z=130, x=44.7, y=22.6, note="Kill Rot Hide gnolls until Nightlash appears, then kill her", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 380
  {t="G", z=130, x=43.4, y=41.7, text="Back to the Sepulcher (hearth if it is off cooldown)", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 381
  {t="T", q=421, name="Prove Your Worth", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 382
  {t="A", q=422, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 383
  {t="T", q=429, name="Wild Hearts", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 384
  {t="A", q=430, name="Return to Quinn", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 385
  {t="T", q=437, name="The Dead Fields", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 386
  {t="T", q=449, name="The Deathstalkers' Report", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 387
  {t="A", q=3221, name="Speak with Renferrel", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 388
  {t="T", q=3221, name="Speak with Renferrel", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 389
  {t="A", q=1359, name="Zinge's Delivery", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 390
  {t="C", q=422, name="Arugal's Folly", z=130, x=52.83, y=28.58, note="Remedy of Arugal", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 391
  {t="T", q=430, name="Return to Quinn", z=130, x=53.43, y=12.59, target={kind="npc", id=1951, name="Quinn Yorick"}, note="Quinn Yorick at the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 392
  {t="A", q=425, name="Ivar the Foul", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 393
  {t="C", q=425, name="Ivar the Foul", z=130, x=51.52, y=13.9, note="Ivar the Foul in the barn", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 394
  {t="T", q=425, name="Ivar the Foul", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 395
  {t="G", z=130, x=44.2, y=39.8, text="Back to Dalar Dawnweaver", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 396
  {t="T", q=422, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 397
  {t="A", q=423, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 398
  {t="C", q=423, name="Arugal's Folly", z=130, x=45.52, y=29.17, note="Glutton and Darksoul Shackles from the Moonrage gluttons and darksouls", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 399
  {t="T", q=423, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 400
  {t="G", z=130, x=49.9, y=60.3, text="Dalaran crate south of the Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 401
  {t="T", q=477, name="Border Crossings", z=130, x=49.89, y=60.33, target={kind="object", id=1627, name="Dalaran Crate"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 402
  {t="A", q=478, name="Maps and Runes", z=130, x=49.89, y=60.33, target={kind="object", id=1627, name="Dalaran Crate"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 403
  {t="G", z=130, x=44.0, y=40.9, text="Shadow Priest Allister", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 404
  {t="T", q=478, name="Maps and Runes", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 405
  {t="A", q=481, name="Dalar's Analysis", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 406
  {t="T", q=481, name="Dalar's Analysis", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 407
  {t="A", q=482, name="Dalaran's Intentions", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 408
  {t="T", q=482, name="Dalaran's Intentions", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 409
  {t="F", text="Undercity", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 410
  {t="G", z=1497, x=48.8, y=69.3, text="Master Apothecary Faranell, Apothecarium", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 411
  {t="T", q=447, name="A Recipe For Death", z=1497, x=48.82, y=69.28, target={kind="npc", id=2055, name="Master Apothecary Faranell"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 412
  {t="G", z=1497, x=50.1, y=68.0, text="Apothecary Zinge", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 413
  {t="T", q=1359, name="Zinge's Delivery", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 414
  {t="A", q=1358, name="Sample for Helbrim", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 415
  {t="G", z=1497, x=84.1, y=17.4, text="Bethor Iceshard", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 416
  {t="TR", text="Train your level 14 spells", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 417
  {t="N", text="Take the zeppelin to Orgrimmar from the tower just outside Undercity", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 418
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Orgrimmar"}, -- 419
  {t="G", z=17, x=62.3, y=19.4, text="Far Watch Post, follow the road west from Durotar", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 420
  {t="T", q=840, name="Conscript of the Horde", z=17, x=62.26, y=19.38, target={kind="npc", id=3337, name="Kargal Battlescar"}, races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 421
  {t="A", q=842, name="Crossroads Conscription", z=17, x=62.26, y=19.38, target={kind="npc", id=3337, name="Kargal Battlescar"}, races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 422
  {t="T", q=809, name="Ak'Zeloth", z=17, x=62.34, y=20.07, target={kind="npc", id=3521, name="Ak'Zeloth"}, note="Ak'Zeloth, next to the tower", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 423
  {t="N", text="Skip The Demon Seed unless you want the extra run to the altar", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)"}, -- 424
  {t="G", z=17, x=44.9, y=59.1, text="Camp Taurajo, east of Mulgore", races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 425
  {t="FP", z=17, x=44.4, y=59.2, text="Camp Taurajo flight path", races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 426
  {t="A", q=854, name="Journey to the Crossroads", z=17, x=44.88, y=58.61, target={kind="npc", id=3418, name="Kirge Sternhorn"}, races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 427
  {t="N", text="Run north along the road to the Crossroads", races={"tauren"}, section="Into The Barrens (Tauren)"}, -- 428
  {t="N", text="From Orgrimmar, leave by the west gate and follow the road south-west into the Barrens", races={"undead"}, section="Into The Barrens (Undead)"}, -- 429
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="The Crossroads", zoneName="The Barrens"}, -- 430
  {t="T", q=842, name="Crossroads Conscription", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, races={"orc", "troll"}, section="The Crossroads", zoneName="The Barrens"}, -- 431
  {t="T", q=854, name="Journey to the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 432
  {t="T", q=860, name="Sergra Darkthorn", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 433
  {t="T", q=886, name="The Barrens Oases", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 434
  {t="T", q=1358, name="Sample for Helbrim", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, races={"undead"}, section="The Crossroads", zoneName="The Barrens"}, -- 435
  {t="SH", z=17, x=52.0, y=29.9, text="The Crossroads", section="The Crossroads", zoneName="The Barrens"}, -- 436
  {t="FP", z=17, x=51.5, y=30.3, text="Crossroads flight path (Devrak)", section="The Crossroads", zoneName="The Barrens"}, -- 437
  {t="A", q=844, name="Plainstrider Menace", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="The Crossroads", zoneName="The Barrens"}, -- 438
  {t="A", q=869, name="Raptor Thieves", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="The Crossroads", zoneName="The Barrens"}, -- 439
  {t="A", q=870, name="The Forgotten Pools", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="The Crossroads", zoneName="The Barrens"}, -- 440
  {t="A", q=848, name="Fungal Spores", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="The Crossroads", zoneName="The Barrens"}, -- 441
  {t="A", q=871, name="Disrupt the Attacks", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="The Crossroads", zoneName="The Barrens"}, -- 442
  {t="A", q=1492, name="Wharfmaster Dizzywig", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="The Crossroads", zoneName="The Barrens"}, -- 443
  {t="TR", text="Train at Orgrimmar / Thunder Bluff when you next pass; most classes get new ranks every even level", section="The Crossroads"}, -- 444
  {t="C", q=844, name="Plainstrider Menace", z=17, x=51.38, y=28.01, note="Plainstriders around the Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 445
  {t="C", q=871, name="Disrupt the Attacks", z=17, x=55.1, y=25.59, note="Razormane quilboar east of the Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 446
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 447
  {t="T", q=844, name="Plainstrider Menace", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 448
  {t="T", q=871, name="Disrupt the Attacks", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 449
  {t="A", q=845, name="The Zhevra", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 450
  {t="A", q=872, name="The Disruption Ends", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 451
  {t="A", q=5041, name="Supplies for the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 452
  {t="C", q=872, name="The Disruption Ends", z=17, x=58.9, y=25.0, note="Razormane Geomancers, Defenders and Kreenig Snarlsnout", section="East of the Crossroads", zoneName="The Barrens"}, -- 453
  {t="C", q=5041, name="Supplies for the Crossroads", z=17, x=59.35, y=24.9, note="Supply crates in the Razormane camp", section="East of the Crossroads", zoneName="The Barrens"}, -- 454
  {t="C", q=845, name="The Zhevra", z=17, x=50.79, y=34.14, note="Zhevra Runners on the way south", section="East of the Crossroads", zoneName="The Barrens"}, -- 455
  {t="C", q=869, name="Raptor Thieves", z=17, x=55.99, y=33.56, note="Raptor heads from Sunscale raptors", section="East of the Crossroads", zoneName="The Barrens"}, -- 456
  {t="G", z=17, x=63.4, y=38.5, text="Ratchet docks", section="Ratchet", zoneName="The Barrens"}, -- 457
  {t="T", q=1492, name="Wharfmaster Dizzywig", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 458
  {t="A", q=887, name="Southsea Freebooters", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 459
  {t="A", q=895, name="WANTED: Baron Longshore", z=17, x=62.59, y=37.47, target={kind="object", id=3972, name="WANTED"}, section="Ratchet", zoneName="The Barrens"}, -- 460
  {t="A", q=894, name="Samophlange", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet", zoneName="The Barrens"}, -- 461
  {t="A", q=865, name="Raptor Horns", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet", zoneName="The Barrens"}, -- 462
  {t="A", q=866, name="Root Samples", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet", zoneName="The Barrens"}, -- 463
  {t="FP", z=17, x=63.1, y=37.2, text="Ratchet flight path (Bragok)", section="Ratchet", zoneName="The Barrens"}, -- 464
  {t="C", q=887, name="Southsea Freebooters", z=17, x=63.82, y=46.9, note="Southsea Brigands and Cannoneers on the coast south of Ratchet", section="Ratchet", zoneName="The Barrens"}, -- 465
  {t="C", q=895, name="WANTED: Baron Longshore", z=17, x=63.56, y=49.14, note="Baron Longshore at the pirate camp", section="Ratchet", zoneName="The Barrens"}, -- 466
  {t="G", z=17, x=62.7, y=36.2, text="Back to Gazlowe", section="Ratchet", zoneName="The Barrens"}, -- 467
  {t="T", q=887, name="Southsea Freebooters", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 468
  {t="T", q=895, name="WANTED: Baron Longshore", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 469
  {t="A", q=890, name="The Missing Shipment", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 470
  {t="T", q=890, name="The Missing Shipment", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, note="Wharfmaster Dizzywig on the docks", section="Ratchet", zoneName="The Barrens"}, -- 471
  {t="A", q=892, name="The Missing Shipment", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 472
  {t="T", q=892, name="The Missing Shipment", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 473
  {t="A", q=896, name="Miner's Fortune", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 474
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="Ratchet", zoneName="The Barrens"}, -- 475
  {t="T", q=869, name="Raptor Thieves", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Ratchet", zoneName="The Barrens"}, -- 476
  {t="T", q=845, name="The Zhevra", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Ratchet", zoneName="The Barrens"}, -- 477
  {t="T", q=872, name="The Disruption Ends", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="Ratchet", zoneName="The Barrens"}, -- 478
  {t="T", q=5041, name="Supplies for the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="Ratchet", zoneName="The Barrens"}, -- 479
  {t="A", q=903, name="Prowlers of the Barrens", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Ratchet", zoneName="The Barrens"}, -- 480
  {t="A", q=867, name="Harpy Raiders", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="Ratchet", zoneName="The Barrens"}, -- 481
  {t="F", text="Orgrimmar", section="Ragefire Chasm (dungeon, group of 5)"}, -- 482
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path (if you don't have it yet)", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 483
  {t="G", z=1637, x=49.5, y=50.6, text="Neeru Fireblade in the Cleft of Shadow", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 484
  {t="A", q=5761, name="Slaying the Beast", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 485
  {t="D", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", text="Ragefire Chasm, in the Cleft of Shadow", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 486
  {t="C", q=5761, name="Slaying the Beast", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Taragaman the Hungerer, last boss", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 487
  {t="C", q=5723, name="Testing an Enemy's Strength", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Ragefire Troggs and Shamans", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 488
  {t="C", q=5722, name="Searching for the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Maur Grimtotem's corpse", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 489
  {t="T", q=5722, name="Searching for the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", target={kind="npc", id=11834, name="Maur Grimtotem"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 490
  {t="A", q=5724, name="Returning the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", target={kind="npc", id=11834, name="Maur Grimtotem"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 491
  {t="G", z=1637, x=49.5, y=50.6, text="Neeru Fireblade", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 492
  {t="T", q=5761, name="Slaying the Beast", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 493
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)"}, -- 494
  {t="T", q=5723, name="Testing an Enemy's Strength", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Thunder Bluff"}, -- 495
  {t="T", q=5724, name="Returning the Lost Satchel", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Thunder Bluff"}, -- 496
  {t="F", text="The Crossroads", section="Ragefire Chasm (dungeon, group of 5)"}, -- 497
  {t="C", q=870, name="The Forgotten Pools", z=17, x=45.06, y=22.53, note="Explore the Forgotten Pools", section="North Barrens", zoneName="The Barrens"}, -- 498
  {t="C", q=903, name="Prowlers of the Barrens", z=17, x=42.0, y=23.51, note="Savannah Prowlers", section="North Barrens", zoneName="The Barrens"}, -- 499
  {t="C", q=867, name="Harpy Raiders", z=17, x=39.75, y=15.6, note="Witchwing harpies for talons", section="North Barrens", zoneName="The Barrens"}, -- 500
  {t="C", q=894, name="Samophlange", z=17, x=39.75, y=15.6, note="Go to the control console at the Sludge Fen", section="North Barrens", zoneName="The Barrens"}, -- 501
  {t="T", q=894, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 502
  {t="A", q=900, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 503
  {t="C", q=900, name="Samophlange", z=17, x=52.3, y=11.42, note="Close the three valves", section="North Barrens", zoneName="The Barrens"}, -- 504
  {t="T", q=900, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 505
  {t="A", q=901, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 506
  {t="C", q=901, name="Samophlange", z=17, x=52.84, y=10.39, note="Tinkerer Sniggles has the console key", section="North Barrens", zoneName="The Barrens"}, -- 507
  {t="T", q=901, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 508
  {t="A", q=902, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 509
  {t="G", z=17, x=56.5, y=7.5, text="Wizzlecrank's Shredder at the Venture Co. tower", section="North Barrens", zoneName="The Barrens"}, -- 510
  {t="A", q=858, name="Ignition", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 511
  {t="C", q=858, name="Ignition", z=17, x=56.27, y=8.58, note="Ignition Key from Supervisor Lugwizzle on top of the tower", section="North Barrens", zoneName="The Barrens"}, -- 512
  {t="T", q=858, name="Ignition", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 513
  {t="A", q=863, name="The Escape", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 514
  {t="C", q=863, name="The Escape", z=17, x=56.52, y=7.45, note="Escort Wizzlecrank (he ends the escort near the Crossroads road)", section="North Barrens", zoneName="The Barrens"}, -- 515
  {t="C", q=896, name="Miner's Fortune", z=17, x=60.66, y=3.79, note="Cats Eye Emerald from Boulder Lode Mine overseers", section="North Barrens", zoneName="The Barrens"}, -- 516
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="North Barrens", zoneName="The Barrens"}, -- 517
  {t="T", q=870, name="The Forgotten Pools", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="North Barrens", zoneName="The Barrens"}, -- 518
  {t="A", q=877, name="The Stagnant Oasis", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="North Barrens", zoneName="The Barrens"}, -- 519
  {t="T", q=903, name="Prowlers of the Barrens", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="North Barrens", zoneName="The Barrens"}, -- 520
  {t="A", q=881, name="Echeyakee", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="North Barrens", zoneName="The Barrens"}, -- 521
  {t="T", q=867, name="Harpy Raiders", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="North Barrens", zoneName="The Barrens"}, -- 522
  {t="A", q=875, name="Harpy Lieutenants", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="North Barrens", zoneName="The Barrens"}, -- 523
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate, west of the Crossroads", section="North Barrens", zoneName="The Barrens"}, -- 524
  {t="A", q=855, name="Centaur Bracers", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="North Barrens", zoneName="The Barrens"}, -- 525
  {t="A", q=850, name="Kolkar Leaders", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="North Barrens", zoneName="The Barrens"}, -- 526
  {t="C", q=875, name="Harpy Lieutenants", z=17, x=38.79, y=15.11, note="Witchwing Slayers for rings", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 527
  {t="C", q=850, name="Kolkar Leaders", z=17, x=42.8, y=23.52, note="Barak Kodobane at the Kolkar camp", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 528
  {t="G", z=17, x=55.8, y=17.1, text="Echeyakee's Lair", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 529
  {t="C", q=881, name="Echeyakee", z=17, x=55.8, y=17.1, note="Use the Horn of Echeyakee here to summon him", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 530
  {t="C", q=877, name="The Stagnant Oasis", z=17, x=55.61, y=42.75, note="Investigate the Stagnant Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 531
  {t="C", q=865, name="Raptor Horns", z=17, x=52.58, y=45.99, note="Intact Raptor Horns from Sunscale Scytheclaws", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 532
  {t="C", q=848, name="Fungal Spores", z=17, x=46.68, y=38.76, note="Fungal Spores at Lushwater Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 533
  {t="C", q=866, name="Root Samples", z=17, x=48.66, y=36.55, note="Root Samples around Lushwater Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 534
  {t="C", q=855, name="Centaur Bracers", z=17, x=46.71, y=37.9, note="Centaur Bracers from Kolkar centaurs", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 535
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 536
  {t="T", q=850, name="Kolkar Leaders", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 537
  {t="T", q=855, name="Centaur Bracers", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 538
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 539
  {t="T", q=875, name="Harpy Lieutenants", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 540
  {t="T", q=877, name="The Stagnant Oasis", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 541
  {t="A", q=880, name="Altered Beings", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 542
  {t="T", q=881, name="Echeyakee", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 543
  {t="A", q=905, name="The Angry Scytheclaws", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 544
  {t="T", q=848, name="Fungal Spores", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 545
  {t="A", q=4921, name="Lost in Battle", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 546
  {t="A", q=899, name="Consumed by Hatred", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 547
  {t="TR", text="Train in Orgrimmar or Thunder Bluff if you are behind on spells", section="West and Lushwater Oasis"}, -- 548
  {t="F", text="Ratchet", section="Ratchet turn-ins"}, -- 549
  {t="T", q=902, name="Samophlange", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 550
  {t="T", q=865, name="Raptor Horns", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 551
  {t="T", q=866, name="Root Samples", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 552
  {t="T", q=896, name="Miner's Fortune", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 553
  {t="T", q=863, name="The Escape", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 554
  {t="A", q=1491, name="Smart Drinks", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 555
  {t="A", q=959, name="Trouble at the Docks", z=17, x=63.09, y=37.61, target={kind="npc", id=3665, name="Crane Operator Bigglefuzz"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 556
  {t="F", text="The Crossroads", section="Ratchet turn-ins"}, -- 557
  {t="C", q=905, name="The Angry Scytheclaws", z=17, x=55.99, y=33.56, note="Sunscale raptors east of the Crossroads; use the feathers on the nests", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 558
  {t="C", q=880, name="Altered Beings", z=17, x=47.74, y=40.22, note="Altered Snapjaws at Lushwater Oasis", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 559
  {t="C", q=1491, name="Smart Drinks", z=17, x=46.0, y=36.5, note="Wailing Essence from the ectoplasm mobs at the Wailing Caverns mound", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 560
  {t="C", q=959, name="Trouble at the Docks", z=17, x=46.0, y=36.5, note="Find the stolen bottle near the Wailing Caverns oasis", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 561
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 562
  {t="T", q=905, name="The Angry Scytheclaws", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 563
  {t="T", q=880, name="Altered Beings", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 564
  {t="A", q=3281, name="Stolen Silver", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 565
  {t="A", q=1489, name="Hamuul Runetotem", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 566
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound"}, -- 567
  {t="T", q=1489, name="Hamuul Runetotem", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 568
  {t="A", q=1490, name="Nara Wildmane", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 569
  {t="T", q=1490, name="Nara Wildmane", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 570
  {t="A", q=914, name="Leaders of the Fang", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 571
  {t="F", text="The Crossroads", races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound"}, -- 572
  {t="G", z=17, x=46.0, y=35.7, text="Nalpak and Ebru, in the cave on top of the Wailing Caverns mound", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 573
  {t="A", q=1486, name="Deviate Hides", z=17, x=45.99, y=35.66, target={kind="npc", id=5767, name="Nalpak"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 574
  {t="A", q=1487, name="Deviate Eradication", z=17, x=46.01, y=35.74, target={kind="npc", id=5768, name="Ebru"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 575
  {t="D", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", text="Wailing Caverns", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 576
  {t="C", q=1486, name="Deviate Hides", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="Deviate Hides from the deviate beasts inside", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 577
  {t="C", q=1487, name="Deviate Eradication", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="Deviate Ravagers, Vipers, Shamblers and Dreadfangs", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 578
  {t="C", q=914, name="Leaders of the Fang", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="The gems from Lady Anacondra and Lords Cobrahn, Pythas and Serpentis", races={"tauren"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 579
  {t="G", z=17, x=46.0, y=35.7, text="Nalpak and Ebru", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 580
  {t="T", q=1486, name="Deviate Hides", z=17, x=45.99, y=35.66, target={kind="npc", id=5767, name="Nalpak"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 581
  {t="T", q=1487, name="Deviate Eradication", z=17, x=46.01, y=35.74, target={kind="npc", id=5768, name="Ebru"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 582
  {t="G", z=17, x=44.9, y=59.1, text="Camp Taurajo", section="South of the Crossroads", zoneName="The Barrens"}, -- 583
  {t="FP", z=17, x=44.4, y=59.2, text="Camp Taurajo flight path", races={"orc", "troll", "undead"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 584
  {t="A", q=878, name="Tribes at War", z=17, x=44.55, y=59.26, target={kind="npc", id=3430, name="Mangletooth"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 585
  {t="C", q=4921, name="Lost in Battle", z=17, x=49.33, y=50.32, note="Mankrik's wife lies dead at the Bristleback camp south of the Crossroads road", section="South of the Crossroads", zoneName="The Barrens"}, -- 586
  {t="C", q=878, name="Tribes at War", z=17, x=51.32, y=54.16, note="Bristleback quilboar", section="South of the Crossroads", zoneName="The Barrens"}, -- 587
  {t="C", q=899, name="Consumed by Hatred", z=17, x=45.51, y=53.76, note="Bristleback tusks; keep killing quilboar until you have 60", section="South of the Crossroads", zoneName="The Barrens"}, -- 588
  {t="G", z=17, x=44.5, y=59.3, text="Mangletooth, Camp Taurajo", section="South of the Crossroads", zoneName="The Barrens"}, -- 589
  {t="T", q=878, name="Tribes at War", z=17, x=44.55, y=59.26, target={kind="npc", id=3430, name="Mangletooth"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 590
  {t="F", text="The Crossroads", section="South of the Crossroads"}, -- 591
  {t="T", q=4921, name="Lost in Battle", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 592
  {t="T", q=899, name="Consumed by Hatred", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 593
  {t="F", text="Ratchet", section="Northwatch Hold"}, -- 594
  {t="T", q=1491, name="Smart Drinks", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 595
  {t="T", q=959, name="Trouble at the Docks", z=17, x=63.09, y=37.61, target={kind="npc", id=3665, name="Crane Operator Bigglefuzz"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 596
  {t="A", q=891, name="The Guns of Northwatch", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 597
  {t="A", q=888, name="Stolen Booty", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 598
  {t="C", q=888, name="Stolen Booty", z=17, x=63.58, y=49.25, note="Shipment of Boots and Telescopic Lens at the pirate camp", section="Northwatch Hold", zoneName="The Barrens"}, -- 599
  {t="C", q=891, name="The Guns of Northwatch", z=17, x=61.8, y=54.84, note="Theramore Medals from the Northwatch soldiers", section="Northwatch Hold", zoneName="The Barrens"}, -- 600
  {t="C", q=3281, name="Stolen Silver", z=17, x=58.04, y=53.87, note="Stolen Silver in Northwatch Hold", section="Northwatch Hold", zoneName="The Barrens"}, -- 601
  {t="G", z=17, x=62.0, y=55.0, text="Gilthares Firebough, in the Northwatch keep", section="Northwatch Hold", zoneName="The Barrens"}, -- 602
  {t="A", q=898, name="Free From the Hold", z=17, x=61.96, y=54.96, target={kind="npc", id=3465, name="Gilthares Firebough"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 603
  {t="C", q=898, name="Free From the Hold", z=17, x=61.96, y=54.96, note="Escort Gilthares to Ratchet", section="Northwatch Hold", zoneName="The Barrens"}, -- 604
  {t="T", q=898, name="Free From the Hold", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 605
  {t="T", q=891, name="The Guns of Northwatch", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 606
  {t="T", q=888, name="Stolen Booty", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 607
  {t="F", text="The Crossroads", section="Northwatch Hold"}, -- 608
  {t="T", q=3281, name="Stolen Silver", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 609
  {t="TR", text="Train level 20 spells (Orgrimmar / Thunder Bluff / Undercity)", section="Northwatch Hold"}, -- 610
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Northwatch Hold"}, -- 611
  {t="T", q=914, name="Leaders of the Fang", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, note="Nara Wildmane on Elder Rise", races={"tauren"}, section="Northwatch Hold", zoneName="Thunder Bluff"}, -- 612
  {t="F", text="The Crossroads", races={"tauren"}, section="Northwatch Hold"}, -- 613
  {t="G", z=17, x=35.3, y=27.9, text="Seereth Stonebreak and Makaba Flathoof, at the Stonetalon road in the western Barrens", section="Stonetalon Mountains", zoneName="The Barrens"}, -- 614
  {t="A", q=1062, name="Goblin Invaders", z=17, x=35.26, y=27.88, target={kind="npc", id=4049, name="Seereth Stonebreak"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 615
  {t="A", q=6548, name="Avenge My Village", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 616
  {t="N", text="Follow the road west into Stonetalon to Windshear Crag", section="Stonetalon Mountains"}, -- 617
  {t="G", z=406, x=59.0, y=62.6, text="Ziz Fizziks at Windshear Crag", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 618
  {t="A", q=1093, name="Super Reaper 6000", z=406, x=58.99, y=62.6, target={kind="npc", id=4201, name="Ziz Fizziks"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 619
  {t="C", q=1093, name="Super Reaper 6000", z=406, x=67.09, y=52.41, note="Super Reaper 6000 Blueprints from the Venture Co. operators", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 620
  {t="C", q=1062, name="Goblin Invaders", z=406, x=66.4, y=52.49, note="Venture Co. Loggers at Windshear Crag", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 621
  {t="T", q=1093, name="Super Reaper 6000", z=406, x=58.99, y=62.6, target={kind="npc", id=4201, name="Ziz Fizziks"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 622
  {t="C", q=6548, name="Avenge My Village", z=406, x=82.28, y=86.92, note="Grimtotem Ruffians and Mercenaries, south toward Malaka'jin", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 623
  {t="G", z=406, x=73.5, y=85.6, text="Kaya Flathoof, in the Grimtotem camp", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 624
  {t="A", q=6523, name="Protect Kaya", z=406, x=73.48, y=85.59, target={kind="npc", id=11856, name="Kaya Flathoof"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 625
  {t="C", q=6523, name="Protect Kaya", z=406, x=73.48, y=85.59, note="Escort Kaya to Camp Aparaje", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 626
  {t="G", z=17, x=35.3, y=27.9, text="Back to Seereth and Makaba at the Barrens edge", section="Stonetalon Mountains", zoneName="The Barrens"}, -- 627
  {t="T", q=1062, name="Goblin Invaders", z=17, x=35.26, y=27.88, target={kind="npc", id=4049, name="Seereth Stonebreak"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 628
  {t="T", q=6548, name="Avenge My Village", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 629
  {t="T", q=6523, name="Protect Kaya", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 630
  {t="N", text="Ride back west through Windshear Crag to Sun Rock Retreat", section="Stonetalon Mountains"}, -- 631
  {t="G", z=406, x=47.4, y=61.0, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 632
  {t="FP", z=406, x=45.1, y=59.8, text="Sun Rock Retreat flight path (Tharm)", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 633
  {t="SH", z=406, x=47.5, y=62.1, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 634
  {t="A", q=6421, name="Boulderslide Ravine", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 635
  {t="A", q=6301, name="Cycle of Rebirth", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 636
  {t="A", q=6562, name="Trouble in the Deeps", z=406, x=47.36, y=64.25, target={kind="npc", id=11862, name="Tsunaman"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 637
  {t="G", z=406, x=59.1, y=75.7, text="Wanted poster for Besseleth on the road", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 638
  {t="A", q=6284, name="Arachnophobia", z=406, x=59.06, y=75.71, target={kind="object", id=177904, name="Wanted Poster: Besseleth"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 639
  {t="C", q=6421, name="Boulderslide Ravine", z=406, x=59.63, y=91.49, note="Resonite crystals deep in the Boulderslide Ravine cave", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 640
  {t="C", q=6284, name="Arachnophobia", z=406, x=52.5, y=71.69, note="Besseleth, the spider at the Charred Vale road", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 641
  {t="C", q=6301, name="Cycle of Rebirth", z=406, x=48.05, y=39.76, note="Gaea Seeds in the Charred Vale", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 642
  {t="G", z=406, x=47.5, y=58.4, text="Back to Sun Rock", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 643
  {t="T", q=6421, name="Boulderslide Ravine", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 644
  {t="A", q=6481, name="Earthen Arise", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 645
  {t="T", q=6284, name="Arachnophobia", z=406, x=47.2, y=61.16, target={kind="npc", id=11860, name="Maggran Earthbinder"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 646
  {t="T", q=6301, name="Cycle of Rebirth", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 647
  {t="A", q=6381, name="New Life", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 648
  {t="C", q=6381, name="New Life", z=406, x=32.24, y=68.15, note="Plant the seeds in Gaea Dirt Mounds", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 649
  {t="G", z=406, x=57.6, y=89.5, text="Resonite Cask, Boulderslide Ravine", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 650
  {t="C", q=6481, name="Earthen Arise", z=406, x=57.6, y=89.5, note="Open the cask with the crystal and kill what comes out", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 651
  {t="G", z=406, x=47.5, y=58.4, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 652
  {t="T", q=6381, name="New Life", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 653
  {t="T", q=6481, name="Earthen Arise", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 654
  {t="N", text="Take the road north out of Sun Rock into Ashenvale and follow the coast to Zoram'gar", section="Zoram'gar Outpost (west Ashenvale)"}, -- 655
  {t="G", z=331, x=11.6, y=34.3, text="Zoram'gar Outpost", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 656
  {t="FP", z=331, x=12.2, y=33.8, text="Zoram'gar flight path (Andruk)", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 657
  {t="T", q=6562, name="Trouble in the Deeps", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 658
  {t="A", q=6442, name="Naga at the Zoram Strand", z=331, x=11.69, y=34.91, target={kind="npc", id=12719, name="Marukai"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 659
  {t="A", q=216, name="Between a Rock and a Thistlefur", z=331, x=11.9, y=34.54, target={kind="npc", id=12757, name="Karang Amakkar"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 660
  {t="A", q=6462, name="Troll Charm", z=331, x=11.65, y=34.85, target={kind="npc", id=12721, name="Mitsuwa"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 661
  {t="A", q=6641, name="Vorsha the Lasher", z=331, x=12.06, y=34.63, target={kind="npc", id=12717, name="Muglash"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 662
  {t="C", q=6641, name="Vorsha the Lasher", z=331, x=12.06, y=34.63, note="Escort Muglash to the brazier and defend him", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 663
  {t="T", q=6641, name="Vorsha the Lasher", z=331, x=12.22, y=34.22, target={kind="npc", id=12863, name="Warsong Runner"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 664
  {t="C", q=6442, name="Naga at the Zoram Strand", z=331, x=14.08, y=20.86, note="Wrathtail naga along the Zoram Strand", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 665
  {t="T", q=6442, name="Naga at the Zoram Strand", z=331, x=11.69, y=34.91, target={kind="npc", id=12719, name="Marukai"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 666
  {t="A", q=6563, name="The Essence of Aku'Mai", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 667
  {t="A", q=6921, name="Amongst the Ruins", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 668
  {t="D", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", text="Blackfathom Deeps, at the north end of the Zoram Strand", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 669
  {t="A", q=6564, name="Allegiance to the Old Gods", z=331, x=13.37, y=12.07, target={kind="item", id=16790, name="Damp Note"}, note="The Damp Note drops inside", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 670
  {t="C", q=6563, name="The Essence of Aku'Mai", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", note="Sapphires of Aku'Mai from the crystal clusters", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 671
  {t="C", q=6921, name="Amongst the Ruins", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", note="The Fathom Core, in the first big chamber", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 672
  {t="G", z=331, x=11.6, y=34.3, text="Zoram'gar Outpost", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 673
  {t="T", q=6563, name="The Essence of Aku'Mai", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 674
  {t="T", q=6921, name="Amongst the Ruins", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 675
  {t="T", q=6564, name="Allegiance to the Old Gods", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 676
  {t="C", q=216, name="Between a Rock and a Thistlefur", z=331, x=35.7, y=36.94, note="Thistlefur Avengers and Shaman at Thistlefur Village", section="Thistlefur Village", zoneName="Ashenvale"}, -- 677
  {t="C", q=6462, name="Troll Charm", z=331, x=40.86, y=33.64, note="Troll Charms from Thistlefur furbolgs", section="Thistlefur Village", zoneName="Ashenvale"}, -- 678
  {t="G", z=331, x=41.5, y=34.5, text="Ruul Snowhoof, in a cage at Thistlefur Village", section="Thistlefur Village", zoneName="Ashenvale"}, -- 679
  {t="A", q=6482, name="Freedom to Ruul", z=331, x=41.53, y=34.49, target={kind="npc", id=12818, name="Ruul Snowhoof"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 680
  {t="C", q=6482, name="Freedom to Ruul", z=331, x=41.53, y=34.49, note="Escort Ruul out of the furbolg camp", section="Thistlefur Village", zoneName="Ashenvale"}, -- 681
  {t="G", z=331, x=11.9, y=34.5, text="Back to Zoram'gar", section="Thistlefur Village", zoneName="Ashenvale"}, -- 682
  {t="T", q=216, name="Between a Rock and a Thistlefur", z=331, x=11.9, y=34.54, target={kind="npc", id=12757, name="Karang Amakkar"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 683
  {t="T", q=6462, name="Troll Charm", z=331, x=11.65, y=34.85, target={kind="npc", id=12721, name="Mitsuwa"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 684
  {t="F", text="The Crossroads", section="Thistlefur Village"}, -- 685
  {t="TR", text="Train level 24 spells in Orgrimmar if you have not", section="Thistlefur Village"}, -- 686
  {t="N", text="Run north from the Crossroads past Mor'shan Rampart into Ashenvale; Splintertree Post is just inside", section="Thistlefur Village"}, -- 687
  {t="G", z=331, x=73.8, y=61.5, text="Splintertree Post", section="Splintertree Post", zoneName="Ashenvale"}, -- 688
  {t="FP", z=331, x=73.2, y=61.6, text="Splintertree flight path (Vhulgra)", section="Splintertree Post", zoneName="Ashenvale"}, -- 689
  {t="SH", z=331, x=74.0, y=60.7, text="Splintertree Post", section="Splintertree Post", zoneName="Ashenvale"}, -- 690
  {t="T", q=6482, name="Freedom to Ruul", z=331, x=74.11, y=60.92, target={kind="npc", id=12837, name="Yama Snowhoof"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 691
  {t="A", q=6503, name="Ashenvale Outrunners", z=331, x=71.11, y=68.12, target={kind="npc", id=12867, name="Kuray'bin"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 692
  {t="A", q=6441, name="Satyr Horns", z=331, x=73.06, y=61.48, target={kind="npc", id=12724, name="Pixel"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 693
  {t="A", q=25, name="Stonetalon Standstill", z=331, x=73.67, y=60.0, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 694
  {t="C", q=6503, name="Ashenvale Outrunners", z=331, x=72.52, y=72.46, note="Ashenvale Outrunners in the woods south of the post", section="Splintertree Post", zoneName="Ashenvale"}, -- 695
  {t="G", z=331, x=68.3, y=75.3, text="Torek, east of Silverwing Outpost", section="Splintertree Post", zoneName="Ashenvale"}, -- 696
  {t="A", q=6544, name="Torek's Assault", z=331, x=68.34, y=75.3, target={kind="npc", id=12858, name="Torek"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 697
  {t="C", q=6544, name="Torek's Assault", z=331, x=68.34, y=75.3, note="Escort Torek's assault on Silverwing Outpost", section="Splintertree Post", zoneName="Ashenvale"}, -- 698
  {t="T", q=6503, name="Ashenvale Outrunners", z=331, x=71.11, y=68.12, target={kind="npc", id=12867, name="Kuray'bin"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 699
  {t="T", q=6544, name="Torek's Assault", z=331, x=73.03, y=62.47, target={kind="npc", id=12877, name="Ertog Ragetusk"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 700
  {t="C", q=6441, name="Satyr Horns", z=331, x=79.54, y=50.12, note="Satyr Horns from the satyrs at Satyrnaar", section="Splintertree Post", zoneName="Ashenvale"}, -- 701
  {t="C", q=25, name="Stonetalon Standstill", z=331, x=49.36, y=69.85, note="Befouled Water Elementals at Mystral Lake", section="Splintertree Post", zoneName="Ashenvale"}, -- 702
  {t="A", q=1918, name="The Befouled Element", z=331, x=45.88, y=70.62, target={kind="item", id=16408, name="Befouled Water Globe"}, note="Befouled Water Globe drops from the elementals", section="Splintertree Post", zoneName="Ashenvale"}, -- 703
  {t="G", z=331, x=73.7, y=60.0, text="Mastok Wrilehiss", section="Splintertree Post", zoneName="Ashenvale"}, -- 704
  {t="T", q=25, name="Stonetalon Standstill", z=331, x=73.67, y=60.0, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 705
  {t="T", q=1918, name="The Befouled Element", z=331, x=73.67, y=60.0, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 706
  {t="T", q=6441, name="Satyr Horns", z=331, x=73.06, y=61.48, target={kind="npc", id=12724, name="Pixel"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 707
  {t="F", text="Orgrimmar", section="To Hillsbrad Foothills"}, -- 708
  {t="TR", text="Train level 24/26 spells", section="To Hillsbrad Foothills"}, -- 709
  {t="N", text="Take the zeppelin from the tower outside Orgrimmar to Tirisfal Glades", section="To Hillsbrad Foothills"}, -- 710
  {t="F", text="The Sepulcher", races={"undead"}, section="To Hillsbrad Foothills"}, -- 711
  {t="G", z=130, x=42.8, y=40.9, text="Apothecary Renferrel at the Sepulcher", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 712
  {t="FP", z=130, x=45.6, y=42.6, text="Sepulcher flight path (Karos Razok)", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 713
  {t="A", q=493, name="Journey to Hillsbrad Foothills", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 714
  {t="A", q=1098, name="Deathstalkers in Shadowfang", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, note="High Executor Hadrec", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 715
  {t="A", q=1014, name="Arugal Must Die", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 716
  {t="D", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", text="Shadowfang Keep, south Silverpine", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 717
  {t="T", q=1098, name="Deathstalkers in Shadowfang", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", target={kind="npc", id=4444, name="Deathstalker Vincent"}, note="Deathstalker Vincent, just inside the courtyard", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 718
  {t="C", q=1014, name="Arugal Must Die", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", note="Archmage Arugal, final boss", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 719
  {t="G", z=267, x=20.8, y=47.4, text="Deathstalker Lesh on the Silverpine–Hillsbrad border road", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 720
  {t="A", q=494, name="Time To Strike", z=267, x=20.79, y=47.4, target={kind="npc", id=2214, name="Deathstalker Lesh"}, section="Shadowfang Keep (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 721
  {t="G", z=267, x=62.3, y=20.4, text="Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 722
  {t="FP", z=267, x=60.1, y=18.6, text="Tarren Mill flight path (Zarise)", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 723
  {t="SH", z=267, x=62.8, y=19.0, text="Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 724
  {t="T", q=493, name="Journey to Hillsbrad Foothills", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 725
  {t="T", q=494, name="Time To Strike", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 726
  {t="A", q=496, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 727
  {t="A", q=501, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 728
  {t="A", q=527, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 729
  {t="A", q=498, name="The Rescue", z=267, x=63.24, y=20.66, target={kind="npc", id=2229, name="Krusk"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 730
  {t="A", q=549, name="WANTED: Syndicate Personnel", z=267, x=62.63, y=20.75, target={kind="object", id=1763, name="WANTED"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 731
  {t="A", q=509, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 732
  {t="C", q=496, name="Elixir of Suffering", z=267, x=60.87, y=47.84, note="Gray Bear Tongues from bears and Creeper Ichor from the creeping vines", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 733
  {t="C", q=501, name="Elixir of Pain", z=267, x=54.31, y=42.94, note="Mountain Lion Blood from mountain lions", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 734
  {t="C", q=527, name="Battle of Hillsbrad", z=267, x=34.79, y=38.52, note="Hillsbrad farmers and farmhands, Farmer Ray and Farmer Getz at the western farms", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 735
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 736
  {t="T", q=496, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 737
  {t="A", q=499, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 738
  {t="T", q=499, name="Elixir of Suffering", z=267, x=61.55, y=19.14, target={kind="npc", id=2230, name="Umpi"}, note="Give the elixir to Umpi right next to Lydon", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 739
  {t="T", q=501, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 740
  {t="A", q=502, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 741
  {t="T", q=527, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 742
  {t="A", q=528, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 743
  {t="A", q=546, name="Souvenirs of Death", z=267, x=62.11, y=19.7, target={kind="npc", id=2418, name="Deathguard Samsa"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 744
  {t="T", q=502, name="Elixir of Pain", z=267, x=32.66, y=35.32, target={kind="npc", id=2274, name="Stanley"}, note="Feed the Elixir of Pain to Stanley the dog at the farm", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 745
  {t="C", q=528, name="Battle of Hillsbrad", z=267, x=34.06, y=45.69, note="Hillsbrad Peasants in the fields", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 746
  {t="C", q=546, name="Souvenirs of Death", z=267, x=33.07, y=45.72, note="Hillsbrad Human Skulls from the humans around Hillsbrad", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 747
  {t="C", q=509, name="Elixir of Agony", z=267, x=64.56, y=61.25, note="Mudsnout Blossoms near the river south of Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 748
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 749
  {t="T", q=528, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 750
  {t="A", q=529, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 751
  {t="A", q=567, name="Dangerous!", z=267, x=62.56, y=19.66, target={kind="object", id=2008, name="Dangerous!"}, note="Dangerous! poster in Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 752
  {t="T", q=509, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 753
  {t="A", q=513, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 754
  {t="C", q=529, name="Battle of Hillsbrad", z=267, x=32.01, y=45.45, note="Blacksmith Verringtan and apprentices in Hillsbrad", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 755
  {t="C", q=546, name="Souvenirs of Death", z=267, x=33.07, y=45.72, note="Finish the skulls", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 756
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 757
  {t="T", q=529, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 758
  {t="T", q=546, name="Souvenirs of Death", z=267, x=62.11, y=19.7, target={kind="npc", id=2418, name="Deathguard Samsa"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 759
  {t="A", q=532, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 760
  {t="C", q=532, name="Battle of Hillsbrad", z=267, x=29.73, y=41.75, note="Magistrate Burnside and councilmen in the Hillsbrad town hall", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 761
  {t="C", q=567, name="Dangerous!", z=267, x=29.51, y=42.41, note="The four bounty targets: Clerk Horrace Whitesteed (town hall), Citizen Wilkes, Miner Hackett and Farmer Kalaba", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 762
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 763
  {t="T", q=532, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 764
  {t="T", q=567, name="Dangerous!", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 765
  {t="C", q=549, name="WANTED: Syndicate Personnel", z=267, x=78.19, y=44.45, note="Syndicate Rogues and Watchmen around Durnholde Keep", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 766
  {t="C", q=498, name="The Rescue", z=267, x=79.49, y=40.57, note="Free Drull and Tog'thar inside Durnholde Keep", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 767
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 768
  {t="T", q=549, name="WANTED: Syndicate Personnel", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 769
  {t="T", q=498, name="The Rescue", z=267, x=63.24, y=20.66, target={kind="npc", id=2229, name="Krusk"}, section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 770
  {t="F", text="The Sepulcher", section="Durnholde Keep"}, -- 771
  {t="T", q=1014, name="Arugal Must Die", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", section="Durnholde Keep", zoneName="Silverpine Forest"}, -- 772
  {t="F", text="Undercity", section="Durnholde Keep"}, -- 773
  {t="T", q=513, name="Elixir of Agony", z=1497, x=48.82, y=69.28, target={kind="npc", id=2055, name="Master Apothecary Faranell"}, note="Master Apothecary Faranell in the Apothecarium", section="Durnholde Keep", zoneName="Undercity"}, -- 774
  {t="TR", text="Train level 28 spells", section="Durnholde Keep"}, -- 775
  {t="N", text="Take the zeppelin back to Orgrimmar", section="Durnholde Keep"}, -- 776
  {t="F", text="Camp Taurajo", section="Thousand Needles"}, -- 777
  {t="D", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", text="Razorfen Kraul, far south Barrens", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 778
  {t="A", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", target={kind="npc", id=4508, name="Willix the Importer"}, note="Willix the Importer, held captive inside", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 779
  {t="C", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", note="Escort Willix out", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 780
  {t="T", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", target={kind="npc", id=4508, name="Willix the Importer"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 781
  {t="N", text="Ride south-east through the Great Gate into Thousand Needles", section="Razorfen Kraul (dungeon, group of 5)"}, -- 782
  {t="G", z=400, x=32.2, y=22.2, text="Brave Moonhorn at the bottom of the Great Lift", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 783
  {t="A", q=4542, name="Message to Freewind Post", z=400, x=32.24, y=22.17, target={kind="npc", id=10079, name="Brave Moonhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 784
  {t="G", z=400, x=45.7, y=50.7, text="Freewind Post (up the lift)", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 785
  {t="FP", z=400, x=45.1, y=49.1, text="Freewind Post flight path (Nyse)", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 786
  {t="SH", z=400, x=46.1, y=51.5, text="Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 787
  {t="T", q=4542, name="Message to Freewind Post", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 788
  {t="A", q=4841, name="Pacify the Centaur", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 789
  {t="A", q=4821, name="Alien Egg", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 790
  {t="A", q=4767, name="Wind Rider", z=400, x=44.93, y=48.92, target={kind="npc", id=10377, name="Elu"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 791
  {t="A", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=46.0, y=50.86, target={kind="object", id=176115, name="Wanted Poster - Arnak Grimtotem"}, note="Wanted poster for Arnak Grimtotem", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 792
  {t="C", q=4841, name="Pacify the Centaur", z=400, x=43.65, y=39.34, note="Galak Scouts, Wranglers and Windchasers", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 793
  {t="C", q=4821, name="Alien Egg", z=400, x=52.34, y=55.25, note="The Alien Egg in the Roguefeather Den area", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 794
  {t="G", z=400, x=45.7, y=50.7, text="Back to Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 795
  {t="T", q=4841, name="Pacify the Centaur", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 796
  {t="T", q=4821, name="Alien Egg", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 797
  {t="A", q=5064, name="Grimtotem Spying", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 798
  {t="A", q=4865, name="Serpent Wild", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 799
  {t="C", q=5064, name="Grimtotem Spying", z=400, x=33.76, y=39.99, note="Three Secret Notes in Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 800
  {t="C", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=38.11, y=26.87, note="Arnak Grimtotem at Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 801
  {t="A", q=4881, name="Assassination Plot", z=400, x=39.43, y=33.1, target={kind="item", id=12564, name="Assassination Note"}, note="Assassination Note in Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 802
  {t="G", z=400, x=38.0, y=26.4, text="Lakota Windsong, at the top of Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 803
  {t="A", q=4904, name="Free at Last", z=400, x=37.95, y=26.45, target={kind="npc", id=10646, name="Lakota Windsong"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 804
  {t="C", q=4904, name="Free at Last", z=400, x=37.95, y=26.45, note="Escort Lakota out of the pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 805
  {t="G", z=400, x=21.5, y=32.4, text="Whitereach Post, west", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 806
  {t="T", q=4865, name="Serpent Wild", z=400, x=21.54, y=32.35, target={kind="npc", id=10428, name="Motega Firemane"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 807
  {t="T", q=4881, name="Assassination Plot", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 808
  {t="A", q=4966, name="Protect Kanati Greycloud", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 809
  {t="C", q=4966, name="Protect Kanati Greycloud", z=400, x=21.25, y=32.06, note="Defend Kanati Greycloud from the centaur attack", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 810
  {t="T", q=4966, name="Protect Kanati Greycloud", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 811
  {t="A", q=5151, name="Hypercapacitor Gizmo", z=400, x=21.43, y=32.55, target={kind="npc", id=10941, name="Wizlo Bearingshiner"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 812
  {t="C", q=5151, name="Hypercapacitor Gizmo", z=400, x=22.76, y=24.62, note="The panther cage and the Hypercapacitor Gizmo north of Whitereach", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 813
  {t="T", q=5151, name="Hypercapacitor Gizmo", z=400, x=21.43, y=32.55, target={kind="npc", id=10941, name="Wizlo Bearingshiner"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 814
  {t="C", q=4767, name="Wind Rider", z=400, x=11.56, y=37.11, note="Highperch Wyvern Eggs at Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 815
  {t="G", z=400, x=17.9, y=40.6, text="Pao'ka Swiftmountain at Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 816
  {t="A", q=4770, name="Homeward Bound", z=400, x=17.89, y=40.57, target={kind="npc", id=10427, name="Pao'ka Swiftmountain"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 817
  {t="C", q=4770, name="Homeward Bound", z=400, x=17.89, y=40.57, note="Escort Pao'ka out of Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 818
  {t="T", q=4770, name="Homeward Bound", z=400, x=21.54, y=32.35, target={kind="npc", id=10428, name="Motega Firemane"}, note="Motega Firemane at Whitereach Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 819
  {t="G", z=400, x=45.7, y=50.7, text="Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 820
  {t="T", q=5064, name="Grimtotem Spying", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 821
  {t="T", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 822
  {t="T", q=4904, name="Free at Last", z=400, x=45.97, y=51.61, target={kind="npc", id=10645, name="Thalia Amberhide"}, note="Thalia Amberhide", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 823
  {t="T", q=4767, name="Wind Rider", z=400, x=44.93, y=48.92, target={kind="npc", id=10377, name="Elu"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 824
  {t="G", z=400, x=78.1, y=77.1, text="Mirage Raceway, Shimmering Flats", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 825
  {t="A", q=1104, name="Salt Flat Venom", z=400, x=78.06, y=77.13, target={kind="npc", id=4454, name="Fizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 826
  {t="A", q=1105, name="Hardened Shells", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 827
  {t="A", q=1110, name="Rocket Car Parts", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 828
  {t="A", q=1176, name="Load Lightening", z=400, x=80.18, y=75.88, target={kind="npc", id=4630, name="Pozzik"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 829
  {t="A", q=1175, name="A Bump in the Road", z=400, x=81.63, y=77.95, target={kind="npc", id=4629, name="Trackmaster Zherin"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 830
  {t="A", q=5762, name="Hemet Nesingwary", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 831
  {t="C", q=1104, name="Salt Flat Venom", z=400, x=75.47, y=67.77, note="Salty Scorpid Venoms from scorpids", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 832
  {t="C", q=1105, name="Hardened Shells", z=400, x=83.77, y=60.74, note="Hardened Tortoise Shells from tortoises", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 833
  {t="C", q=1110, name="Rocket Car Parts", z=400, x=72.52, y=72.34, note="Rocket Car Parts lie all over the salt flats", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 834
  {t="C", q=1176, name="Load Lightening", z=400, x=82.99, y=70.69, note="Hollow Vulture Bones from vultures", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 835
  {t="C", q=1175, name="A Bump in the Road", z=400, x=73.81, y=76.19, note="Saltstone basilisks", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 836
  {t="G", z=400, x=78.1, y=77.1, text="Back to the Mirage Raceway", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 837
  {t="T", q=1104, name="Salt Flat Venom", z=400, x=78.06, y=77.13, target={kind="npc", id=4454, name="Fizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 838
  {t="T", q=1105, name="Hardened Shells", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 839
  {t="T", q=1110, name="Rocket Car Parts", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 840
  {t="T", q=1176, name="Load Lightening", z=400, x=80.18, y=75.88, target={kind="npc", id=4630, name="Pozzik"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 841
  {t="T", q=1175, name="A Bump in the Road", z=400, x=81.63, y=77.95, target={kind="npc", id=4629, name="Trackmaster Zherin"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 842
  {t="F", text="Orgrimmar", section="The Shimmering Flats"}, -- 843
  {t="TR", text="Train level 30 spells", section="The Shimmering Flats"}, -- 844
  {t="N", text="Take the zeppelin from the tower outside Orgrimmar to Grom'gol Base Camp", section="Northern Stranglethorn Vale"}, -- 845
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 846
  {t="FP", z=33, x=32.5, y=29.4, text="Grom'gol flight path (Thysta)", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 847
  {t="SH", z=33, x=31.5, y=29.8, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 848
  {t="G", z=33, x=35.7, y=10.5, text="Nesingwary's Expedition, north along the road", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 849
  {t="T", q=5762, name="Hemet Nesingwary", z=33, x=35.66, y=10.81, target={kind="npc", id=715, name="Hemet Nesingwary"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 850
  {t="A", q=583, name="Welcome to the Jungle", z=33, x=35.66, y=10.53, target={kind="npc", id=716, name="Barnil Stonepot"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 851
  {t="T", q=583, name="Welcome to the Jungle", z=33, x=35.66, y=10.81, target={kind="npc", id=715, name="Hemet Nesingwary"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 852
  {t="A", q=185, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 853
  {t="A", q=190, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 854
  {t="C", q=185, name="Tiger Mastery", z=33, x=35.07, y=12.11, note="Young Stranglethorn Tigers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 855
  {t="C", q=190, name="Panther Mastery", z=33, x=41.35, y=12.82, note="Young Panthers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 856
  {t="G", z=33, x=35.6, y=10.6, text="Back to Nesingwary's camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 857
  {t="T", q=185, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 858
  {t="T", q=190, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 859
  {t="A", q=186, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 860
  {t="A", q=191, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 861
  {t="C", q=191, name="Panther Mastery", z=33, x=28.39, y=12.3, note="Panthers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 862
  {t="C", q=186, name="Tiger Mastery", z=33, x=46.58, y=14.4, note="Stranglethorn Tigers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 863
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 864
  {t="T", q=186, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 865
  {t="T", q=191, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 866
  {t="G", z=33, x=32.2, y=27.7, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 867
  {t="A", q=638, name="Trollbane", z=33, x=32.16, y=27.72, target={kind="npc", id=2497, name="Nimboya"}, note="Nimboya: Trollbane, a breadcrumb to Hammerfall", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 868
  {t="N", text="Take the zeppelin from Grom'gol to Undercity", section="Northern Stranglethorn Vale"}, -- 869
  {t="F", text="Tarren Mill", section="Hillsbrad and on to Arathi"}, -- 870
  {t="A", q=676, name="The Hammer May Fall", z=267, x=61.87, y=19.57, target={kind="npc", id=2770, name="Tallow"}, note="Tallow, by the Tarren Mill stables", section="Hillsbrad and on to Arathi", zoneName="Hillsbrad Foothills"}, -- 871
  {t="N", text="Ride east out of Hillsbrad through Thoradin's Wall into Arathi Highlands", section="Hillsbrad and on to Arathi"}, -- 872
  {t="C", q=676, name="The Hammer May Fall", z=45, x=33.58, y=44.59, note="Boulderfist ogres in western Arathi on the way", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 873
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 874
  {t="FP", z=45, x=73.0, y=32.7, text="Hammerfall flight path (Urda)", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 875
  {t="SH", z=45, x=73.8, y=32.6, text="Hammerfall", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 876
  {t="T", q=676, name="The Hammer May Fall", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 877
  {t="A", q=677, name="Call to Arms", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 878
  {t="T", q=638, name="Trollbane", z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, note="Zengu", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 879
  {t="A", q=639, name="Sigil of Strom", group=true, z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, note="Group quest: Stromgarde elites", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 880
  {t="G", z=45, x=72.6, y=33.9, text="Gor'mul", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 881
  {t="A", q=655, name="Hammerfall", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 882
  {t="T", q=655, name="Hammerfall", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 883
  {t="A", q=672, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 884
  {t="A", q=671, name="Foul Magics", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 885
  {t="C", q=672, name="Raising Spirits", z=45, x=41.03, y=44.8, note="Highland Raptor Eyes from Highland Striders and Thrashers", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 886
  {t="C", q=671, name="Foul Magics", z=45, x=32.27, y=28.3, note="Bloodstone Amulets from the Syndicate at Northfold Manor", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 887
  {t="G", z=45, x=74.7, y=36.3, text="Back to Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 888
  {t="T", q=672, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 889
  {t="A", q=674, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 890
  {t="T", q=674, name="Raising Spirits", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, note="Gor'mul", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 891
  {t="A", q=675, name="Raising Spirits", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 892
  {t="T", q=675, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 893
  {t="A", q=701, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 894
  {t="T", q=671, name="Foul Magics", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 895
  {t="C", q=677, name="Call to Arms", z=45, x=69.03, y=71.98, note="Witherbark trolls in the southeast", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 896
  {t="C", q=701, name="Guile of the Raptor", z=45, x=49.61, y=69.12, note="Raptor Hearts from Highland Fleshstalkers", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 897
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 898
  {t="T", q=677, name="Call to Arms", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 899
  {t="A", q=678, name="Call to Arms", group=true, z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, note="Group quest: Boulderfist Hall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 900
  {t="T", q=701, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 901
  {t="A", q=702, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 902
  {t="T", q=702, name="Guile of the Raptor", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, note="Gor'mul", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 903
  {t="A", q=847, name="Guile of the Raptor", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 904
  {t="T", q=847, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 905
  {t="C", q=678, name="Call to Arms", group=true, z=45, x=53.1, y=75.93, note="Boulderfist Brutes and Magi in Boulderfist Hall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 906
  {t="C", q=639, name="Sigil of Strom", group=true, z=45, x=28.33, y=63.36, note="The Sigil of Strom from the Stromgarde defenders", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 907
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 908
  {t="T", q=678, name="Call to Arms", group=true, z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 909
  {t="T", q=639, name="Sigil of Strom", group=true, z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 910
  {t="F", text="Undercity", section="Desolace"}, -- 911
  {t="N", text="Zeppelin to Orgrimmar, then fly to the Crossroads", section="Desolace"}, -- 912
  {t="F", text="The Crossroads", section="Desolace"}, -- 913
  {t="TR", text="Train level 34/36 spells in Orgrimmar or Thunder Bluff on the way", section="Desolace"}, -- 914
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate, west of the Crossroads", section="Desolace", zoneName="The Barrens"}, -- 915
  {t="A", q=1362, name="The Kolkar of Desolace", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="Desolace", zoneName="The Barrens"}, -- 916
  {t="F", text="Sun Rock Retreat", section="Desolace"}, -- 917
  {t="N", text="Ride south out of Stonetalon on the road into Desolace", section="Desolace"}, -- 918
  {t="G", z=405, x=56.2, y=59.6, text="Ghost Walker Post", section="Desolace", zoneName="Desolace"}, -- 919
  {t="T", q=1362, name="The Kolkar of Desolace", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 920
  {t="A", q=1365, name="Khan Dez'hepah", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 921
  {t="A", q=1434, name="Befouled by Satyr", z=405, x=52.57, y=54.39, target={kind="npc", id=5641, name="Takata Steelblade"}, note="In Forever this needs the Alliance Relations chain first, so it is left out there", section="Desolace", zoneName="Desolace"}, -- 922
  {t="A", q=5386, name="Catch of the Day", z=405, x=55.41, y=55.81, target={kind="npc", id=11259, name="Nataka Longhorn"}, section="Desolace", zoneName="Desolace"}, -- 923
  {t="G", z=405, x=60.9, y=61.9, text="Smeed Scrabblescrew at the Kodo Graveyard", section="Desolace", zoneName="Desolace"}, -- 924
  {t="A", q=5561, name="Kodo Roundup", z=405, x=60.86, y=61.86, target={kind="npc", id=11596, name="Smeed Scrabblescrew"}, section="Desolace", zoneName="Desolace"}, -- 925
  {t="G", z=405, x=52.0, y=56.1, text="Aged Kodos wander the Kodo Graveyard", section="Desolace", zoneName="Desolace"}, -- 926
  {t="C", q=5561, name="Kodo Roundup", z=405, x=52.0, y=56.1, note="Use the Kodo Kombobulator on Aged Kodos and lead 5 back to Smeed", section="Desolace", zoneName="Desolace"}, -- 927
  {t="T", q=5561, name="Kodo Roundup", z=405, x=60.86, y=61.86, target={kind="npc", id=11596, name="Smeed Scrabblescrew"}, section="Desolace", zoneName="Desolace"}, -- 928
  {t="C", q=1365, name="Khan Dez'hepah", z=405, x=73.38, y=41.62, note="Khan Dez'hepah at the Magram village", section="Desolace", zoneName="Desolace"}, -- 929
  {t="C", q=1434, name="Befouled by Satyr", z=405, x=75.29, y=19.28, note="Hatefury satyrs at Sargeron in the northeast", section="Desolace", zoneName="Desolace"}, -- 930
  {t="A", q=1480, name="The Corrupter", z=405, x=55.14, y=28.62, target={kind="item", id=20310, name="Flayed Demon Skin"}, note="The Flayed Demon Skin drops from the satyrs", section="Desolace", zoneName="Desolace"}, -- 931
  {t="G", z=405, x=56.2, y=59.6, text="Back to Ghost Walker Post", section="Desolace", zoneName="Desolace"}, -- 932
  {t="T", q=1365, name="Khan Dez'hepah", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 933
  {t="A", q=1366, name="Centaur Bounty", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 934
  {t="T", q=1434, name="Befouled by Satyr", z=405, x=52.57, y=54.39, target={kind="npc", id=5641, name="Takata Steelblade"}, section="Desolace", zoneName="Desolace"}, -- 935
  {t="T", q=1480, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Desolace", zoneName="Desolace"}, -- 936
  {t="A", q=1481, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Desolace", zoneName="Desolace"}, -- 937
  {t="G", z=405, x=21.6, y=74.1, text="Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 938
  {t="FP", z=405, x=21.6, y=74.1, text="Shadowprey flight path (Thalon)", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 939
  {t="SH", z=405, x=24.1, y=68.2, text="Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 940
  {t="A", q=6142, name="Clam Bait", z=405, x=22.64, y=71.97, target={kind="npc", id=12031, name="Mai'Lahii"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 941
  {t="A", q=6143, name="Other Fish to Fry", z=405, x=23.32, y=72.87, target={kind="npc", id=12340, name="Drulzegar Skraghook"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 942
  {t="G", z=405, x=22.4, y=73.1, text="Jinar'Zillen", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 943
  {t="C", q=5386, name="Catch of the Day", z=405, x=22.4, y=73.1, note="Talk to Jinar'Zillen by the water; he gives you the fish to bring back", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 944
  {t="C", q=6143, name="Other Fish to Fry", z=405, x=33.75, y=22.38, note="Slitherblade naga on the northwest coast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 945
  {t="C", q=6142, name="Clam Bait", z=405, x=32.78, y=26.64, note="Soft-shelled Clam Meat from clams on the same coast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 946
  {t="G", z=405, x=23.3, y=72.9, text="Back to Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 947
  {t="T", q=6142, name="Clam Bait", z=405, x=22.64, y=71.97, target={kind="npc", id=12031, name="Mai'Lahii"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 948
  {t="T", q=6143, name="Other Fish to Fry", z=405, x=23.32, y=72.87, target={kind="npc", id=12340, name="Drulzegar Skraghook"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 949
  {t="C", q=1366, name="Centaur Bounty", z=405, x=36.66, y=79.2, note="Centaur Ears from any Kolkar, Gelkis or Magram centaurs", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 950
  {t="C", q=1481, name="The Corrupter", z=405, x=75.33, y=21.26, note="Shadowstalker Scalp from the satyr Shadowstalkers in the northeast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 951
  {t="G", z=405, x=56.2, y=59.6, text="Ghost Walker Post", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 952
  {t="T", q=1366, name="Centaur Bounty", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 953
  {t="T", q=1481, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 954
  {t="T", q=5386, name="Catch of the Day", z=405, x=55.41, y=55.81, target={kind="npc", id=11259, name="Nataka Longhorn"}, note="Nataka Longhorn", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 955
  {t="H", text="Shadowprey Village", section="Western Desolace and Shadowprey Village"}, -- 956
  {t="F", text="The Crossroads", section="Western Desolace and Shadowprey Village"}, -- 957
  {t="N", text="Ride south from the Crossroads through the southern Barrens border into Dustwallow, or fly to Ratchet and follow the road south", section="Dustwallow Marsh"}, -- 958
  {t="G", z=15, x=36.4, y=31.9, text="Brackenwall Village", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 959
  {t="FP", z=15, x=35.6, y=31.9, text="Brackenwall flight path (Shardi)", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 960
  {t="N", text="Brackenwall has no inn; keep your hearthstone where it is", section="Dustwallow Marsh"}, -- 961
  {t="A", q=1201, name="Theramore Spies", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 962
  {t="A", q=1177, name="Hungry!", z=15, x=35.15, y=38.26, target={kind="npc", id=4503, name="Mudcrush Durtfeet"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 963
  {t="C", q=1201, name="Theramore Spies", z=15, x=38.95, y=26.4, note="Theramore Infiltrators around Brackenwall (they are stealthed)", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 964
  {t="G", z=15, x=29.7, y=47.6, text="The burned Shady Rest Inn", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 965
  {t="A", q=1268, name="Suspicious Hoofprints", z=15, x=29.7, y=47.64, target={kind="object", id=187273, name="Suspicious Hoofprint"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 966
  {t="A", q=1251, name="The Black Shield", z=15, x=29.63, y=48.62, target={kind="object", id=20992, name="Black Shield"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 967
  {t="A", q=1269, name="Lieutenant Paval Reethe", z=15, x=29.83, y=48.24, target={kind="object", id=21042, name="Theramore Guard Badge"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 968
  {t="G", z=15, x=55.4, y=25.9, text="Loose Dirt, at the burned Horde camp in the north", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 969
  {t="A", q=1238, name="The Lost Report", z=15, x=55.44, y=25.92, target={kind="object", id=20985, name="Loose Dirt"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 970
  {t="C", q=1177, name="Hungry!", z=15, x=58.36, y=15.33, note="Mirefin murlocs for heads", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 971
  {t="G", z=15, x=46.9, y=17.5, text="Stinky Ignatz, near the north road", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 972
  {t="A", q=1270, name="Stinky's Escape", z=15, x=46.88, y=17.52, target={kind="npc", id=4880, name="\"Stinky\" Ignatz"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 973
  {t="C", q=1270, name="Stinky's Escape", z=15, x=46.88, y=17.52, note="Escort Stinky", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 974
  {t="G", z=15, x=36.4, y=31.9, text="Brackenwall Village", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 975
  {t="T", q=1201, name="Theramore Spies", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 976
  {t="T", q=1177, name="Hungry!", z=15, x=35.15, y=38.26, target={kind="npc", id=4503, name="Mudcrush Durtfeet"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 977
  {t="T", q=1238, name="The Lost Report", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 978
  {t="T", q=1268, name="Suspicious Hoofprints", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 979
  {t="T", q=1251, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 980
  {t="A", q=1321, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 981
  {t="T", q=1321, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, note="Do'gol", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 982
  {t="A", q=1322, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 983
  {t="T", q=1269, name="Lieutenant Paval Reethe", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 984
  {t="A", q=1273, name="Questioning Reethe", z=15, x=40.96, y=36.69, target={kind="npc", id=4983, name="Ogron"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 985
  {t="C", q=1273, name="Questioning Reethe", z=15, x=40.96, y=36.69, note="Follow Ogron and speak with Reethe", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 986
  {t="T", q=1273, name="Questioning Reethe", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 987
  {t="C", q=1322, name="The Black Shield", z=15, x=39.14, y=39.68, note="Acidic Venom Sacs from the spiders", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 988
  {t="T", q=1322, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 989
  {t="A", q=1323, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 990
  {t="T", q=1323, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 991
  {t="F", text="Ratchet", section="Dustwallow Marsh"}, -- 992
  {t="T", q=1270, name="Stinky's Escape", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Dustwallow Marsh", zoneName="The Barrens"}, -- 993
  {t="F", text="Camp Taurajo", section="Razorfen Downs (dungeon, group of 5)"}, -- 994
  {t="N", text="Ride south to the bramble mound just north of Thousand Needles", section="Razorfen Downs (dungeon, group of 5)"}, -- 995
  {t="G", z=17, x=49.0, y=94.9, text="Myriam Moonsinger outside Razorfen Downs", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 996
  {t="A", q=6626, name="A Host of Evil", z=17, x=49.01, y=94.94, target={kind="npc", id=12866, name="Myriam Moonsinger"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 997
  {t="C", q=6626, name="A Host of Evil", z=17, x=49.0, y=93.9, note="Razorfen Battleguards, Thornweavers and Death's Head Cultists around the entrance", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 998
  {t="T", q=6626, name="A Host of Evil", z=17, x=49.01, y=94.94, target={kind="npc", id=12866, name="Myriam Moonsinger"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 999
  {t="D", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", text="Razorfen Downs", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1000
  {t="A", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, note="Belnistrasz, just inside", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1001
  {t="C", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", note="Agree to help, then hand him the Oathstone", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1002
  {t="T", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1003
  {t="A", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1004
  {t="C", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", note="Defend Belnistrasz at the quilboar idol", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1005
  {t="T", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1006
  {t="F", text="Orgrimmar", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1007
  {t="TR", text="Train level 38 spells", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1008
  {t="N", text="Take the zeppelin to Tirisfal Glades and walk into Undercity", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1009
  {t="G", z=1497, x=56.2, y=92.2, text="Varimathras in the Royal Quarter", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1010
  {t="A", q=1048, name="Into The Scarlet Monastery", z=1497, x=56.25, y=92.2, target={kind="npc", id=2425, name="Varimathras"}, section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1011
  {t="D", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", text="Scarlet Monastery, north-east Tirisfal Glades (Graveyard, Library, Armory, Cathedral)", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1012
  {t="A", q=1051, name="Vorrel's Revenge", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", target={kind="npc", id=3981, name="Vorrel Sengutz"}, note="Vorrel Sengutz, in the Graveyard wing", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1013
  {t="C", q=1051, name="Vorrel's Revenge", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", note="Vorrel's wedding ring", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1014
  {t="C", q=1048, name="Into The Scarlet Monastery", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", note="Whitemane, Mograine, Herod and Houndmaster Loksey", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1015
  {t="G", z=1497, x=56.2, y=92.2, text="Varimathras", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1016
  {t="T", q=1048, name="Into The Scarlet Monastery", z=1497, x=56.25, y=92.2, target={kind="npc", id=2425, name="Varimathras"}, section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1017
  {t="F", text="Tarren Mill", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1018
  {t="T", q=1051, name="Vorrel's Revenge", z=267, x=62.67, y=18.88, target={kind="npc", id=3982, name="Monika Sengutz"}, note="Monika Sengutz", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 1019
  {t="N", text="Fly to Undercity and take the zeppelin to Grom'gol", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1020
  {t="N", text="From Grom'gol ride south along the road to Booty Bay", section="Booty Bay"}, -- 1021
  {t="G", z=33, x=27.2, y=77.0, text="Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1022
  {t="FP", z=33, x=26.9, y=77.1, text="Booty Bay flight path (Gringer)", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1023
  {t="SH", z=33, x=27.0, y=77.3, text="Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1024
  {t="A", q=595, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1025
  {t="A", q=605, name="Singing Blue Shards", z=33, x=27.12, y=77.21, target={kind="npc", id=2498, name="Crank Fizzlebub"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1026
  {t="A", q=575, name="Supply and Demand", z=33, x=28.29, y=77.59, target={kind="npc", id=2495, name="Drizzlik"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1027
  {t="A", q=213, name="Hostile Takeover", z=33, x=27.0, y=77.13, target={kind="npc", id=737, name="Kebok"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1028
  {t="A", q=617, name="Akiris by the Bundle", z=33, x=26.76, y=76.38, target={kind="npc", id=2494, name="Privateer Bloads"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1029
  {t="G", z=33, x=27.3, y=69.5, text="The Bloodsail cove north of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1030
  {t="T", q=595, name="The Bloodsail Buccaneers", z=33, x=27.28, y=69.52, target={kind="object", id=2083, name="Bloodsail Correspondence"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1031
  {t="A", q=597, name="The Bloodsail Buccaneers", z=33, x=27.28, y=69.52, target={kind="object", id=2083, name="Bloodsail Correspondence"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1032
  {t="C", q=617, name="Akiris by the Bundle", z=33, x=26.2, y=62.42, note="Akiris Reed along the coast north of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1033
  {t="G", z=33, x=28.1, y=76.2, text="First Mate Crazz in Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1034
  {t="T", q=597, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1035
  {t="A", q=599, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1036
  {t="T", q=599, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, note="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1037
  {t="A", q=604, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1038
  {t="C", q=604, name="The Bloodsail Buccaneers", z=33, x=27.15, y=82.68, note="Bloodsail Swashbucklers on the coast south of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1039
  {t="G", z=33, x=27.2, y=77.0, text="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1040
  {t="T", q=604, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1041
  {t="T", q=617, name="Akiris by the Bundle", z=33, x=26.76, y=76.38, target={kind="npc", id=2494, name="Privateer Bloads"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1042
  {t="A", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, note="Group quest", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1043
  {t="C", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=29.32, y=88.29, note="Captain Stillwater, Fleet Master Firallon and Captain Keelhaul on the Bloodsail ships", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1044
  {t="G", z=33, x=27.2, y=77.0, text="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1045
  {t="T", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1046
  {t="C", q=605, name="Singing Blue Shards", z=33, x=36.99, y=41.74, note="Singing Crystal Shards from the basilisks near the Crystalvein Mine", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1047
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1048
  {t="A", q=568, name="The Defense of Grom'gol", z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1049
  {t="A", q=570, name="Mok'thardin's Enchantment", z=33, x=32.12, y=29.24, target={kind="npc", id=2465, name="Far Seer Mok'thardin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1050
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's Expedition", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1051
  {t="A", q=187, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1052
  {t="A", q=192, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1053
  {t="C", q=187, name="Tiger Mastery", z=33, x=33.53, y=18.31, note="Elder Stranglethorn Tigers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1054
  {t="C", q=575, name="Supply and Demand", z=33, x=36.85, y=10.51, note="Large River Crocolisks along the river", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1055
  {t="C", q=213, name="Hostile Takeover", z=33, x=44.23, y=20.09, note="Tumbled Crystals from the Venture Co. at the northern mine", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1056
  {t="C", q=568, name="The Defense of Grom'gol", z=33, x=33.4, y=24.55, note="Lashtail Raptors and Jungle Stalkers around Grom'gol", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1057
  {t="C", q=192, name="Panther Mastery", z=33, x=41.3, y=34.76, note="Shadowmaw Panthers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1058
  {t="C", q=570, name="Mok'thardin's Enchantment", z=33, x=39.59, y=35.55, note="Shadowmaw Claws from the same panthers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1059
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's Expedition", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1060
  {t="T", q=187, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1061
  {t="T", q=192, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1062
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1063
  {t="T", q=568, name="The Defense of Grom'gol", z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1064
  {t="A", q=569, name="The Defense of Grom'gol", group=true, z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, note="Group quest", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1065
  {t="T", q=570, name="Mok'thardin's Enchantment", z=33, x=32.12, y=29.24, target={kind="npc", id=2465, name="Far Seer Mok'thardin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1066
  {t="C", q=569, name="The Defense of Grom'gol", group=true, z=33, x=37.17, y=30.81, note="Mosh'Ogg ogres east of Grom'gol (elites)", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1067
  {t="G", z=33, x=32.2, y=28.9, text="Commander Aggro'gosh", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1068
  {t="T", q=569, name="The Defense of Grom'gol", group=true, z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1069
  {t="F", text="Booty Bay", section="Northern loop"}, -- 1070
  {t="T", q=605, name="Singing Blue Shards", z=33, x=27.12, y=77.21, target={kind="npc", id=2498, name="Crank Fizzlebub"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1071
  {t="T", q=575, name="Supply and Demand", z=33, x=28.29, y=77.59, target={kind="npc", id=2495, name="Drizzlik"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1072
  {t="T", q=213, name="Hostile Takeover", z=33, x=27.0, y=77.13, target={kind="npc", id=737, name="Kebok"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1073
  {t="F", text="Grom'gol Base Camp", section="Swamp of Sorrows"}, -- 1074
  {t="N", text="Ride north from Grom'gol through Duskwood and Deadwind Pass into the Swamp of Sorrows (watch for Alliance in Duskwood)", section="Swamp of Sorrows"}, -- 1075
  {t="G", z=8, x=45.2, y=56.7, text="Stonard", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1076
  {t="FP", z=8, x=46.1, y=54.8, text="Stonard flight path (Breyk)", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1077
  {t="SH", z=8, x=45.2, y=56.7, text="Stonard", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1078
  {t="A", q=698, name="Lack of Surplus", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1079
  {t="A", q=1424, name="Pool of Tears", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1080
  {t="A", q=1430, name="Fresh Meat", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1081
  {t="TR", text="Train level 40/42 spells; buy your level 40 mount in Orgrimmar, Thunder Bluff or Undercity if you have the gold", section="Swamp of Sorrows"}, -- 1082
  {t="G", z=8, x=65.5, y=18.2, text="Galen Goodward, caged in the northeast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1083
  {t="A", q=1393, name="Galen's Escape", z=8, x=65.47, y=18.16, target={kind="npc", id=5391, name="Galen Goodward"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1084
  {t="C", q=1393, name="Galen's Escape", z=8, x=65.47, y=18.16, note="Escort Galen out of the camp", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1085
  {t="T", q=1393, name="Galen's Escape", z=8, x=47.81, y=39.76, target={kind="object", id=32569, name="Galen's Strongbox"}, note="Galen's Strongbox", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1086
  {t="C", q=698, name="Lack of Surplus", z=8, x=79.74, y=30.56, note="Unprepared Sawtooth Flanks from Sawtooth Crocolisks", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1087
  {t="C", q=1424, name="Pool of Tears", z=8, x=72.53, y=53.11, note="Atal'ai Artifacts around the Pool of Tears", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1088
  {t="G", z=8, x=81.3, y=81.0, text="Tok'Kar on the southeast coast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1089
  {t="T", q=698, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1090
  {t="A", q=699, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1091
  {t="C", q=699, name="Lack of Surplus", z=8, x=79.44, y=26.73, note="Sawtooth Snapper Claws from the snappers", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1092
  {t="C", q=1430, name="Fresh Meat", z=8, x=95.96, y=46.26, note="Monstrous Crawler Legs from the crawlers on the beach", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1093
  {t="G", z=8, x=81.3, y=81.0, text="Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1094
  {t="T", q=699, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1095
  {t="A", q=1422, name="Threat From the Sea", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1096
  {t="T", q=1422, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, note="Katar, next to Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1097
  {t="A", q=1426, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1098
  {t="C", q=1426, name="Threat From the Sea", z=8, x=85.33, y=82.92, note="Marsh murlocs along the coast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1099
  {t="G", z=8, x=83.8, y=80.4, text="Katar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1100
  {t="T", q=1426, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1101
  {t="A", q=1427, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1102
  {t="T", q=1427, name="Threat From the Sea", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, note="Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1103
  {t="H", text="Stonard", section="Swamp of Sorrows"}, -- 1104
  {t="T", q=1424, name="Pool of Tears", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1105
  {t="T", q=1430, name="Fresh Meat", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1106
  {t="A", q=1429, name="The Atal'ai Exile", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, note="Take this to the Atal'ai Exile when you reach the Hinterlands", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1107
  {t="F", text="Grom'gol Base Camp", section="Tanaris"}, -- 1108
  {t="N", text="Take the zeppelin to Orgrimmar, then fly to Freewind Post and ride south through the Shimmering Flats into Tanaris", section="Tanaris"}, -- 1109
  {t="F", text="Freewind Post", section="Tanaris"}, -- 1110
  {t="G", z=400, x=78.1, y=77.1, text="Wizzle Brassbolts at the Mirage Raceway, on the way through the Shimmering Flats", section="Tanaris", zoneName="Thousand Needles"}, -- 1111
  {t="A", q=2770, name="Gahz'rilla", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, note="Gahz'rilla, for Zul'Farrak", section="Tanaris", zoneName="Thousand Needles"}, -- 1112
  {t="G", z=440, x=52.5, y=28.5, text="Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1113
  {t="FP", z=440, x=51.6, y=25.4, text="Gadgetzan flight path (Bulkrek Ragefist)", section="Tanaris", zoneName="Tanaris"}, -- 1114
  {t="SH", z=440, x=52.5, y=27.9, text="Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1115
  {t="A", q=1690, name="Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1116
  {t="A", q=1707, name="Water Pouch Bounty", z=440, x=52.49, y=28.45, target={kind="npc", id=7408, name="Spigot Operator Luglunket"}, section="Tanaris", zoneName="Tanaris"}, -- 1117
  {t="A", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=51.83, y=27.04, target={kind="object", id=150075, name="Wanted Poster"}, note="Wanted poster", section="Tanaris", zoneName="Tanaris"}, -- 1118
  {t="A", q=2768, name="Divino-matic Rod", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, note="Divino-matic Rod, for Zul'Farrak", section="Tanaris", zoneName="Tanaris"}, -- 1119
  {t="A", q=3042, name="Troll Temper", z=440, x=51.41, y=28.75, target={kind="npc", id=7804, name="Trenton Lighthammer"}, note="Troll Temper, for Zul'Farrak", section="Tanaris", zoneName="Tanaris"}, -- 1120
  {t="C", q=1690, name="Wastewander Justice", z=440, x=63.61, y=30.96, note="Wastewander Bandits and Thieves east of Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1121
  {t="C", q=1707, name="Water Pouch Bounty", z=440, x=62.25, y=35.0, note="Wastewander Water Pouches drop from the Wastewander humans", section="Tanaris", zoneName="Tanaris"}, -- 1122
  {t="G", z=440, x=52.5, y=28.5, text="Back to Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1123
  {t="T", q=1690, name="Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1124
  {t="T", q=1707, name="Water Pouch Bounty", z=440, x=52.49, y=28.45, target={kind="npc", id=7408, name="Spigot Operator Luglunket"}, section="Tanaris", zoneName="Tanaris"}, -- 1125
  {t="A", q=1691, name="More Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1126
  {t="C", q=1691, name="More Wastewander Justice", z=440, x=61.71, y=38.21, note="Wastewander Shadow Mages, Rogues and Assassins in the camps further southeast", section="Tanaris", zoneName="Tanaris"}, -- 1127
  {t="C", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=61.77, y=38.17, note="Caliph Scorpidsting in the same camps", section="Tanaris", zoneName="Tanaris"}, -- 1128
  {t="G", z=440, x=67.1, y=23.9, text="Steamwheedle Port", section="Tanaris", zoneName="Tanaris"}, -- 1129
  {t="A", q=2875, name="WANTED: Andre Firebeard", z=440, x=66.82, y=22.29, target={kind="object", id=142122, name="Wanted Poster"}, note="Wanted poster", section="Tanaris", zoneName="Tanaris"}, -- 1130
  {t="A", q=8366, name="Southsea Shakedown", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1131
  {t="C", q=8366, name="Southsea Shakedown", z=440, x=73.96, y=46.57, note="Southsea pirates at Lost Rigger Cove", section="Tanaris", zoneName="Tanaris"}, -- 1132
  {t="C", q=2875, name="WANTED: Andre Firebeard", z=440, x=73.37, y=47.14, note="Andre Firebeard at Lost Rigger Cove", section="Tanaris", zoneName="Tanaris"}, -- 1133
  {t="A", q=2876, name="Ship Schedules", z=440, x=73.37, y=47.14, note="Ship Schedules drop from the pirates", section="Tanaris", zoneName="Tanaris"}, -- 1134
  {t="G", z=440, x=67.1, y=23.9, text="Steamwheedle Port", section="Tanaris", zoneName="Tanaris"}, -- 1135
  {t="T", q=2875, name="WANTED: Andre Firebeard", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1136
  {t="T", q=8366, name="Southsea Shakedown", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1137
  {t="T", q=2876, name="Ship Schedules", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1138
  {t="H", text="Gadgetzan", section="Tanaris"}, -- 1139
  {t="T", q=1691, name="More Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1140
  {t="T", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1141
  {t="A", q=5863, name="The Dunemaul Compound", group=true, z=440, x=52.82, y=27.4, target={kind="npc", id=11758, name="Andi Lynn"}, note="Group quest", section="Tanaris", zoneName="Tanaris"}, -- 1142
  {t="C", q=5863, name="The Dunemaul Compound", group=true, z=440, x=40.73, y=56.87, note="Dunemaul ogres at the Dunemaul Compound, south of Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1143
  {t="G", z=440, x=52.8, y=27.4, text="Andi Lynn, Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1144
  {t="T", q=5863, name="The Dunemaul Compound", group=true, z=440, x=52.82, y=27.4, target={kind="npc", id=11758, name="Andi Lynn"}, section="Tanaris", zoneName="Tanaris"}, -- 1145
  {t="D", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", text="Zul'Farrak, north-west Tanaris", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1146
  {t="C", q=3042, name="Troll Temper", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Vials of Troll Temper from the Zul'Farrak trolls", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1147
  {t="C", q=2768, name="Divino-matic Rod", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Divino-matic Rod from Sergeant Bly's group on the stairs", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1148
  {t="C", q=2770, name="Gahz'rilla", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Gahz'rilla's Electrified Scale (summon Gahz'rilla at the pool with the mallet)", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1149
  {t="G", z=440, x=52.5, y=28.5, text="Gadgetzan", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1150
  {t="T", q=2768, name="Divino-matic Rod", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1151
  {t="T", q=3042, name="Troll Temper", z=440, x=51.41, y=28.75, target={kind="npc", id=7804, name="Trenton Lighthammer"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1152
  {t="G", z=400, x=78.1, y=77.1, text="Wizzle Brassbolts at the Mirage Raceway", section="Zul'Farrak (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1153
  {t="T", q=2770, name="Gahz'rilla", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1154
  {t="N", text="Ride north-west to Freewind Post", section="Feralas"}, -- 1155
  {t="N", text="Ride west from Freewind through the Highperch gap into Feralas and follow the road to Camp Mojache", section="Feralas"}, -- 1156
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1157
  {t="FP", z=357, x=75.5, y=44.4, text="Camp Mojache flight path (Shyn)", section="Feralas", zoneName="Feralas"}, -- 1158
  {t="SH", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1159
  {t="A", q=2862, name="War on the Woodpaw", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1160
  {t="A", q=2975, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1161
  {t="A", q=2973, name="A New Cloak's Sheen", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1162
  {t="C", q=2975, name="The Ogres of Feralas", z=357, x=75.36, y=33.85, note="Gordunni ogres at the ogre outpost north of camp", section="Feralas", zoneName="Feralas"}, -- 1163
  {t="A", q=2978, name="The Gordunni Scroll", z=357, x=75.13, y=29.73, target={kind="item", id=9370, name="Gordunni Scroll"}, note="The Gordunni Scroll on the ground in the outpost", section="Feralas", zoneName="Feralas"}, -- 1164
  {t="C", q=2973, name="A New Cloak's Sheen", z=357, x=66.62, y=46.94, note="Iridescent Sprite Darter Wings from the sprite darters", section="Feralas", zoneName="Feralas"}, -- 1165
  {t="C", q=2862, name="War on the Woodpaw", z=357, x=71.6, y=54.15, note="Woodpaw Gnoll Manes from the gnolls south of camp", section="Feralas", zoneName="Feralas"}, -- 1166
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1167
  {t="T", q=2975, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1168
  {t="T", q=2978, name="The Gordunni Scroll", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1169
  {t="T", q=2973, name="A New Cloak's Sheen", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1170
  {t="A", q=2974, name="A Grim Discovery", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1171
  {t="T", q=2862, name="War on the Woodpaw", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1172
  {t="A", q=2863, name="Alpha Strike", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1173
  {t="A", q=2980, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1174
  {t="A", q=2979, name="Dark Ceremony", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1175
  {t="C", q=2863, name="Alpha Strike", z=357, x=69.07, y=55.63, note="Kill 5 Woodpaw Alphas within an hour", section="Feralas", zoneName="Feralas"}, -- 1176
  {t="G", z=357, x=74.9, y=42.5, text="Hadoken Swiftstrider", section="Feralas", zoneName="Feralas"}, -- 1177
  {t="T", q=2863, name="Alpha Strike", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1178
  {t="A", q=2902, name="Woodpaw Investigation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1179
  {t="G", z=357, x=71.6, y=55.9, text="Woodpaw Battle Map in the southern gnoll camp", section="Feralas", zoneName="Feralas"}, -- 1180
  {t="T", q=2902, name="Woodpaw Investigation", z=357, x=71.63, y=55.92, target={kind="object", id=142195, name="Woodpaw Battle Map"}, section="Feralas", zoneName="Feralas"}, -- 1181
  {t="A", q=2903, name="The Battle Plans", z=357, x=71.63, y=55.92, target={kind="object", id=142195, name="Woodpaw Battle Map"}, section="Feralas", zoneName="Feralas"}, -- 1182
  {t="G", z=357, x=74.9, y=42.5, text="Hadoken Swiftstrider", section="Feralas", zoneName="Feralas"}, -- 1183
  {t="T", q=2903, name="The Battle Plans", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1184
  {t="A", q=7730, name="Zukk'ash Infestation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1185
  {t="A", q=7731, name="Stinglasher", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1186
  {t="C", q=7730, name="Zukk'ash Infestation", z=357, x=74.77, y=63.12, note="Zukk'ash Carapaces from the silithid in the Writhing Deep", section="Feralas", zoneName="Feralas"}, -- 1187
  {t="C", q=7731, name="Stinglasher", z=357, x=76.99, y=61.56, note="Stinglasher, deep in the Writhing Deep", section="Feralas", zoneName="Feralas"}, -- 1188
  {t="C", q=2980, name="The Ogres of Feralas", z=357, x=60.44, y=64.8, note="Gordunni Shaman, Brutes and Mages at the southern ogre camp", section="Feralas", zoneName="Feralas"}, -- 1189
  {t="C", q=2979, name="Dark Ceremony", z=357, x=60.77, y=69.54, note="The Gordunni Orb from the ogres at the same camp", section="Feralas", zoneName="Feralas"}, -- 1190
  {t="C", q=2974, name="A Grim Discovery", z=357, x=67.31, y=39.36, note="Grimtotem Horns from the Grimtotem camp west of Mojache", section="Feralas", zoneName="Feralas"}, -- 1191
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1192
  {t="T", q=7730, name="Zukk'ash Infestation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1193
  {t="T", q=7731, name="Stinglasher", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1194
  {t="T", q=2980, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1195
  {t="T", q=2979, name="Dark Ceremony", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1196
  {t="T", q=2974, name="A Grim Discovery", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1197
  {t="F", text="Shadowprey Village", section="Maraudon (dungeon, group of 5)"}, -- 1198
  {t="G", z=405, x=23.2, y=70.3, text="Vark Battlescar, Shadowprey Village", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1199
  {t="A", q=7029, name="Vyletongue Corruption", z=405, x=23.22, y=70.33, target={kind="npc", id=11823, name="Vark Battlescar"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1200
  {t="G", z=405, x=26.9, y=77.7, text="Selendra, south of Shadowprey", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1201
  {t="A", q=7064, name="Corruption of Earth and Seed", z=405, x=26.87, y=77.67, target={kind="npc", id=13699, name="Selendra"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1202
  {t="D", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", text="Maraudon, west Desolace", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1203
  {t="C", q=7029, name="Vyletongue Corruption", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", note="Fill the vial at the orange crystal pool", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1204
  {t="C", q=7064, name="Corruption of Earth and Seed", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", note="Princess Theradras, final boss", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1205
  {t="G", z=405, x=26.9, y=77.7, text="Selendra", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1206
  {t="T", q=7064, name="Corruption of Earth and Seed", z=405, x=26.87, y=77.67, target={kind="npc", id=13699, name="Selendra"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1207
  {t="G", z=405, x=23.2, y=70.3, text="Vark Battlescar", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1208
  {t="T", q=7029, name="Vyletongue Corruption", z=405, x=23.22, y=70.33, target={kind="npc", id=11823, name="Vark Battlescar"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1209
  {t="F", text="Orgrimmar", section="The Hinterlands"}, -- 1210
  {t="TR", text="Train level 48 spells", section="The Hinterlands"}, -- 1211
  {t="N", text="Take the zeppelin to Tirisfal Glades, then fly to Tarren Mill", section="The Hinterlands"}, -- 1212
  {t="F", text="Tarren Mill", section="The Hinterlands"}, -- 1213
  {t="N", text="Ride east past Durnholde Keep into the Hinterlands and follow the road to Revantusk Village on the east coast", section="The Hinterlands"}, -- 1214
  {t="G", z=47, x=33.8, y=75.2, text="The Atal'ai Exile, south-west Hinterlands", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1215
  {t="T", q=1429, name="The Atal'ai Exile", z=47, x=33.75, y=75.21, target={kind="npc", id=5598, name="Atal'ai Exile"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1216
  {t="A", q=1444, name="Return to Fel'Zerul", z=47, x=33.75, y=75.21, target={kind="npc", id=5598, name="Atal'ai Exile"}, note="Return to Fel'Zerul, for the Sunken Temple later", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1217
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1218
  {t="FP", z=47, x=81.7, y=81.8, text="Revantusk flight path (Gorkas)", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1219
  {t="SH", z=47, x=78.1, y=81.4, text="Revantusk Village (Lard is the innkeeper)", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1220
  {t="A", q=7839, name="Vilebranch Hooligans", z=47, x=77.23, y=80.13, target={kind="npc", id=14737, name="Smith Slagtree"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1221
  {t="A", q=7844, name="Cannibalistic Cousins", z=47, x=78.8, y=78.25, target={kind="npc", id=14739, name="Mystic Yayo'jin"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1222
  {t="A", q=7828, name="Stalking the Stalkers", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1223
  {t="A", q=7829, name="Hunt the Savages", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1224
  {t="A", q=7830, name="Avenging the Fallen", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1225
  {t="A", q=7815, name="Snapjaws, Mon!", z=47, x=80.33, y=81.54, target={kind="npc", id=14740, name="Katoom the Angler"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1226
  {t="A", q=7841, name="Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1227
  {t="C", q=7815, name="Snapjaws, Mon!", z=47, x=81.48, y=60.46, note="Snapjaws along the eastern coast", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1228
  {t="C", q=7828, name="Stalking the Stalkers", z=47, x=60.74, y=54.01, note="Silvermane Stalkers", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1229
  {t="C", q=7829, name="Hunt the Savages", z=47, x=60.91, y=46.54, note="Savage Owlbeasts", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1230
  {t="C", q=7830, name="Avenging the Fallen", z=47, x=63.83, y=51.95, note="Witherbark Broodguards and Axe Throwers", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1231
  {t="C", q=7839, name="Vilebranch Hooligans", z=47, x=66.44, y=44.82, note="Vilebranch trolls", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1232
  {t="C", q=7844, name="Cannibalistic Cousins", z=47, x=50.27, y=63.22, note="Witherbark trolls", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1233
  {t="C", q=7841, name="Message to the Wildhammer", z=47, x=31.27, y=48.33, note="Wildhammer dwarves", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1234
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1235
  {t="T", q=7815, name="Snapjaws, Mon!", z=47, x=80.33, y=81.54, target={kind="npc", id=14740, name="Katoom the Angler"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1236
  {t="T", q=7828, name="Stalking the Stalkers", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1237
  {t="T", q=7829, name="Hunt the Savages", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1238
  {t="T", q=7830, name="Avenging the Fallen", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1239
  {t="T", q=7839, name="Vilebranch Hooligans", z=47, x=77.23, y=80.13, target={kind="npc", id=14737, name="Smith Slagtree"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1240
  {t="T", q=7844, name="Cannibalistic Cousins", z=47, x=78.8, y=78.25, target={kind="npc", id=14739, name="Mystic Yayo'jin"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1241
  {t="T", q=7841, name="Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1242
  {t="A", q=7842, name="Another Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1243
  {t="A", q=7849, name="Separation Anxiety", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1244
  {t="A", q=7850, name="Dark Vessels", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1245
  {t="C", q=7849, name="Separation Anxiety", z=47, x=62.11, y=75.35, note="Find the missing wolf cubs", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1246
  {t="C", q=7850, name="Dark Vessels", z=47, x=64.17, y=72.21, note="Recover the Dark Vessels", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1247
  {t="C", q=7842, name="Another Message to the Wildhammer", z=47, x=30.59, y=57.69, note="Wildhammer mail sacks", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1248
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1249
  {t="T", q=7849, name="Separation Anxiety", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1250
  {t="T", q=7850, name="Dark Vessels", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1251
  {t="T", q=7842, name="Another Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1252
  {t="A", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=79.08, y=78.99, target={kind="object", id=179913, name="Call to Arms!"}, note="Group quest: Call to Arms! board", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1253
  {t="A", q=7845, name="Kidnapped Elder Torntusk!", group=true, z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, note="Group quest", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1254
  {t="C", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=57.66, y=81.51, note="Vile Priestess Hexx and Vilebranch Aman'zasi Guards in Jintha'Alor", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1255
  {t="T", q=7845, name="Kidnapped Elder Torntusk!", group=true, z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, note="Elder Torntusk, held in Jintha'Alor", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1256
  {t="A", q=7846, name="Recover the Key!", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1257
  {t="C", q=7846, name="Recover the Key!", z=47, x=57.32, y=86.64, note="Hitah'ya the Keeper drops the key", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1258
  {t="T", q=7846, name="Recover the Key!", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1259
  {t="A", q=7847, name="Return to Primal Torntusk", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1260
  {t="G", z=47, x=78.2, y=81.2, text="Primal Torntusk, Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1261
  {t="T", q=7847, name="Return to Primal Torntusk", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1262
  {t="T", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1263
  {t="F", text="Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)"}, -- 1264
  {t="T", q=1444, name="Return to Fel'Zerul", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, note="Fel'Zerul", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1265
  {t="A", q=1445, name="The Temple of Atal'Hakkar", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1266
  {t="D", z=8, x=69.9, y=53.5, instance=1477, dungeonName="The Temple of Atal'Hakkar", text="Sunken Temple, in the lake east of Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1267
  {t="C", q=1445, name="The Temple of Atal'Hakkar", z=8, x=69.9, y=53.5, instance=1477, dungeonName="The Temple of Atal'Hakkar", note="Fetishes of Hakkar from the trolls inside", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1268
  {t="G", z=8, x=47.9, y=54.8, text="Fel'Zerul, Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1269
  {t="T", q=1445, name="The Temple of Atal'Hakkar", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1270
  {t="F", text="Grom'gol Base Camp", section="Un'Goro Crater"}, -- 1271
  {t="N", text="Zeppelin to Orgrimmar, then fly to Gadgetzan", section="Un'Goro Crater"}, -- 1272
  {t="TR", text="Train level 50 spells in Orgrimmar on the way through", section="Un'Goro Crater"}, -- 1273
  {t="F", text="Gadgetzan", section="Un'Goro Crater"}, -- 1274
  {t="N", text="Ride south-west from Gadgetzan to the ramp down into Un'Goro Crater", section="Un'Goro Crater"}, -- 1275
  {t="G", z=490, x=71.6, y=76.0, text="Torwa Pathfinder at the Un'Goro ramp", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1276
  {t="A", q=4290, name="The Fare of Lar'korwi", z=490, x=71.64, y=75.96, target={kind="npc", id=9619, name="Torwa Pathfinder"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1277
  {t="C", q=4290, name="The Fare of Lar'korwi", z=490, x=68.74, y=56.71, note="Lar'korwi's freshest kill: take the Piece of Threshadon Carcass", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1278
  {t="T", q=4290, name="The Fare of Lar'korwi", z=490, x=71.64, y=75.96, target={kind="npc", id=9619, name="Torwa Pathfinder"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1279
  {t="G", z=490, x=43.5, y=7.4, text="Marshal's Refuge, north side of the crater", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1280
  {t="FP", z=490, x=45.2, y=5.8, text="Marshal's Refuge flight path (Gryfe)", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1281
  {t="A", q=3882, name="Roll the Bones", z=490, x=43.5, y=7.42, target={kind="npc", id=9272, name="Spark Nilminer"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1282
  {t="A", q=4503, name="Shizzle's Flyer", z=490, x=44.23, y=11.59, target={kind="npc", id=9998, name="Shizzle"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1283
  {t="A", q=4145, name="Larion and Muigin", z=490, x=45.54, y=8.72, target={kind="npc", id=9118, name="Larion"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1284
  {t="A", q=3881, name="Expedition Salvation", z=490, x=43.95, y=7.14, target={kind="npc", id=9270, name="Williden Marshal"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1285
  {t="A", q=4243, name="Chasing A-Me 01", z=490, x=46.38, y=13.44, target={kind="npc", id=9618, name="Karna Remtravel"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1286
  {t="A", q=4284, name="Crystals of Power", z=490, x=41.92, y=2.7, target={kind="npc", id=9117, name="J.D. Collie"}, note="J.D. Collie in the cave: pick up crystals as you quest", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1287
  {t="C", q=4243, name="Chasing A-Me 01", z=490, x=41.92, y=2.7, note="Find A-Me 01 in the north-east", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1288
  {t="T", q=4243, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1289
  {t="A", q=4244, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1290
  {t="G", z=490, x=67.7, y=16.6, text="Gorilla caves around A-Me 01", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1291
  {t="C", q=4244, name="Chasing A-Me 01", z=490, x=67.7, y=16.6, note="Mithril Casing drops from the Un'Goro gorillas here", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1292
  {t="T", q=4244, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1293
  {t="A", q=4245, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1294
  {t="C", q=4245, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, note="Escort A-Me 01 back to Marshal's Refuge", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1295
  {t="T", q=4245, name="Chasing A-Me 01", z=490, x=46.38, y=13.44, target={kind="npc", id=9618, name="Karna Remtravel"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1296
  {t="C", q=3881, name="Expedition Salvation", z=490, x=68.54, y=36.54, note="Crate of Foodstuffs and Research Equipment at the wrecked caravan", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1297
  {t="C", q=4145, name="Larion and Muigin", z=490, x=56.39, y=37.33, note="Bloodpetal plants", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1298
  {t="C", q=4503, name="Shizzle's Flyer", z=490, x=41.99, y=58.7, note="Webbed Diemetradon and Pterrordax Scales", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1299
  {t="C", q=3882, name="Roll the Bones", z=490, x=38.98, y=63.95, note="Dinosaur Bones from the diemetradons and pterrordax", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1300
  {t="C", q=4284, name="Crystals of Power", z=490, x=51.7, y=49.13, note="Power Crystals (red, blue, yellow, green) around the crater", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1301
  {t="G", z=490, x=43.5, y=7.4, text="Marshal's Refuge", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1302
  {t="T", q=3881, name="Expedition Salvation", z=490, x=43.95, y=7.14, target={kind="npc", id=9270, name="Williden Marshal"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1303
  {t="T", q=4145, name="Larion and Muigin", z=490, x=45.54, y=8.72, target={kind="npc", id=9118, name="Larion"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1304
  {t="T", q=4503, name="Shizzle's Flyer", z=490, x=44.23, y=11.59, target={kind="npc", id=9998, name="Shizzle"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1305
  {t="T", q=3882, name="Roll the Bones", z=490, x=43.5, y=7.42, target={kind="npc", id=9272, name="Spark Nilminer"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1306
  {t="T", q=4284, name="Crystals of Power", z=490, x=41.92, y=2.7, target={kind="npc", id=9117, name="J.D. Collie"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1307
  {t="F", text="Splintertree Post", section="Felwood"}, -- 1308
  {t="N", text="Ride north from Splintertree into Felwood; the Emerald Sanctuary is on the road", section="Felwood"}, -- 1309
  {t="G", z=361, x=51.2, y=82.1, text="Emerald Sanctuary", section="Felwood", zoneName="Felwood"}, -- 1310
  {t="A", q=5155, name="Forces of Jaedenar", z=361, x=51.21, y=82.11, target={kind="npc", id=10922, name="Greta Mosshoof"}, section="Felwood", zoneName="Felwood"}, -- 1311
  {t="A", q=5156, name="Verifying the Corruption", z=361, x=50.89, y=81.62, target={kind="npc", id=10921, name="Taronn Redfeather"}, section="Felwood", zoneName="Felwood"}, -- 1312
  {t="A", q=4102, name="Cleansing Felwood", z=361, x=46.75, y=83.13, target={kind="npc", id=9529, name="Maybess Riverbreeze"}, section="Felwood", zoneName="Felwood"}, -- 1313
  {t="A", q=8460, name="Timbermaw Ally", z=361, x=50.93, y=85.01, target={kind="npc", id=11554, name="Grazle"}, section="Felwood", zoneName="Felwood"}, -- 1314
  {t="C", q=8460, name="Timbermaw Ally", z=361, x=48.34, y=90.89, note="Deadwood furbolgs south of the sanctuary", section="Felwood", zoneName="Felwood"}, -- 1315
  {t="T", q=8460, name="Timbermaw Ally", z=361, x=50.93, y=85.01, target={kind="npc", id=11554, name="Grazle"}, section="Felwood", zoneName="Felwood"}, -- 1316
  {t="C", q=5155, name="Forces of Jaedenar", z=361, x=38.15, y=61.13, note="Jaedenar hounds, guardsmen and Shadow Council", section="Felwood", zoneName="Felwood"}, -- 1317
  {t="G", z=361, x=34.4, y=54.0, text="Bloodvenom Post", section="Felwood", zoneName="Felwood"}, -- 1318
  {t="FP", z=361, x=34.4, y=54.0, text="Bloodvenom flight path (Brakkar)", section="Felwood", zoneName="Felwood"}, -- 1319
  {t="A", q=6162, name="A Husband's Last Battle", z=361, x=34.8, y=52.73, target={kind="npc", id=9620, name="Dreka'Sur"}, section="Felwood", zoneName="Felwood"}, -- 1320
  {t="C", q=5156, name="Verifying the Corruption", z=361, x=41.73, y=40.15, note="Entropic Beasts and Entropic Horrors", section="Felwood", zoneName="Felwood"}, -- 1321
  {t="C", q=4102, name="Cleansing Felwood", z=361, x=57.28, y=19.67, note="Blood Amber (follow the waypoint)", section="Felwood", zoneName="Felwood"}, -- 1322
  {t="G", z=361, x=51.2, y=82.1, text="Emerald Sanctuary", section="Felwood", zoneName="Felwood"}, -- 1323
  {t="T", q=5155, name="Forces of Jaedenar", z=361, x=51.21, y=82.11, target={kind="npc", id=10922, name="Greta Mosshoof"}, section="Felwood", zoneName="Felwood"}, -- 1324
  {t="T", q=5156, name="Verifying the Corruption", z=361, x=50.89, y=81.62, target={kind="npc", id=10921, name="Taronn Redfeather"}, section="Felwood", zoneName="Felwood"}, -- 1325
  {t="T", q=4102, name="Cleansing Felwood", z=361, x=46.75, y=83.13, target={kind="npc", id=9529, name="Maybess Riverbreeze"}, section="Felwood", zoneName="Felwood"}, -- 1326
  {t="C", q=6162, name="A Husband's Last Battle", z=361, x=48.23, y=94.28, note="Overlord Ror", section="Felwood", zoneName="Felwood"}, -- 1327
  {t="G", z=361, x=34.8, y=52.7, text="Bloodvenom Post", section="Felwood", zoneName="Felwood"}, -- 1328
  {t="T", q=6162, name="A Husband's Last Battle", z=361, x=34.8, y=52.73, target={kind="npc", id=9620, name="Dreka'Sur"}, section="Felwood", zoneName="Felwood"}, -- 1329
  {t="N", text="Ride north through Felwood and the Timbermaw Hold tunnel into Winterspring", section="Winterspring"}, -- 1330
  {t="G", z=618, x=61.4, y=38.8, text="Everlook", section="Winterspring", zoneName="Winterspring"}, -- 1331
  {t="FP", z=618, x=60.5, y=36.3, text="Everlook flight path (Yugrek)", section="Winterspring", zoneName="Winterspring"}, -- 1332
  {t="SH", z=618, x=61.4, y=38.8, text="Everlook", section="Winterspring", zoneName="Winterspring"}, -- 1333
  {t="A", q=3783, name="Are We There, Yeti?", z=618, x=60.88, y=37.62, target={kind="npc", id=10305, name="Umi Rumplesnicker"}, section="Winterspring", zoneName="Winterspring"}, -- 1334
  {t="A", q=5054, name="Ursius of the Shardtooth", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1335
  {t="A", q=6603, name="Trouble in Winterspring!", z=618, x=60.66, y=38.17, target={kind="npc", id=11754, name="Meggi Peppinrocker"}, section="Winterspring", zoneName="Winterspring"}, -- 1336
  {t="A", q=5601, name="Sister Pamela", z=618, x=61.28, y=38.98, target={kind="npc", id=11629, name="Jessica Redpath"}, section="Winterspring", zoneName="Winterspring"}, -- 1337
  {t="C", q=3783, name="Are We There, Yeti?", z=618, x=54.43, y=36.3, note="Thick Yeti Furs from the Ice Thistle yetis", section="Winterspring", zoneName="Winterspring"}, -- 1338
  {t="C", q=5054, name="Ursius of the Shardtooth", z=618, x=64.01, y=24.14, note="Ursius of the Shardtooth", section="Winterspring", zoneName="Winterspring"}, -- 1339
  {t="G", z=618, x=31.3, y=45.2, text="Donova Snowden by the hot springs", section="Winterspring", zoneName="Winterspring"}, -- 1340
  {t="T", q=6603, name="Trouble in Winterspring!", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1341
  {t="A", q=5082, name="Threat of the Winterfall", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1342
  {t="A", q=5083, name="Winterfall Firewater", z=618, x=40.85, y=42.52, target={kind="item", id=12771, name="Empty Firewater Flask"}, note="The Empty Firewater Flask drops from the Winterfall furbolgs", section="Winterspring", zoneName="Winterspring"}, -- 1343
  {t="C", q=5082, name="Threat of the Winterfall", z=618, x=34.72, y=36.96, note="Winterfall Pathfinders, Den Watchers and Totemics", section="Winterspring", zoneName="Winterspring"}, -- 1344
  {t="T", q=5082, name="Threat of the Winterfall", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1345
  {t="T", q=5083, name="Winterfall Firewater", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1346
  {t="H", text="Everlook", section="Winterspring"}, -- 1347
  {t="T", q=3783, name="Are We There, Yeti?", z=618, x=60.88, y=37.62, target={kind="npc", id=10305, name="Umi Rumplesnicker"}, section="Winterspring", zoneName="Winterspring"}, -- 1348
  {t="T", q=5054, name="Ursius of the Shardtooth", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1349
  {t="A", q=5055, name="Brumeran of the Chillwind", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1350
  {t="C", q=5055, name="Brumeran of the Chillwind", z=618, x=62.54, y=57.9, note="Brumeran of the Chillwind", section="Winterspring", zoneName="Winterspring"}, -- 1351
  {t="T", q=5055, name="Brumeran of the Chillwind", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1352
  {t="F", text="Orgrimmar", section="Badlands and Blackrock Mountain"}, -- 1353
  {t="TR", text="Train level 56 spells", section="Badlands and Blackrock Mountain"}, -- 1354
  {t="N", text="Take the zeppelin to Tirisfal Glades and walk into Undercity", section="Badlands and Blackrock Mountain"}, -- 1355
  {t="G", z=1497, x=50.1, y=68.0, text="Apothecary Zinge in the Apothecarium", section="Badlands and Blackrock Mountain", zoneName="Undercity"}, -- 1356
  {t="A", q=4133, name="Vivian Lagrave", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, section="Badlands and Blackrock Mountain", zoneName="Undercity"}, -- 1357
  {t="F", text="Hammerfall", section="Badlands and Blackrock Mountain"}, -- 1358
  {t="N", text="Ride south over Thandol Span, through the Wetlands and Loch Modan, then south into the Badlands; Kargath is at the far west", section="Badlands and Blackrock Mountain"}, -- 1359
  {t="G", z=3, x=2.9, y=47.8, text="Kargath", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1360
  {t="FP", z=3, x=4.0, y=44.8, text="Kargath flight path (Gorrik)", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1361
  {t="SH", z=3, x=2.8, y=45.9, text="Kargath", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1362
  {t="T", q=4133, name="Vivian Lagrave", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, note="Shadowmage Vivian Lagrave", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1363
  {t="A", q=4134, name="Lost Thunderbrew Recipe", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1364
  {t="A", q=7201, name="The Last Element", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, note="In Forever this needs Disharmony of Flame first, so it is left out there", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1365
  {t="A", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=3, x=3.74, y=47.43, target={kind="object", id=164867, name="WANTED"}, note="KILL ON SIGHT poster", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1366
  {t="A", q=3906, name="Disharmony of Flame", z=3, x=3.33, y=48.26, target={kind="npc", id=9084, name="Thunderheart"}, note="Thunderheart", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1367
  {t="N", text="Ride south-west from Kargath into Searing Gorge and on to Blackrock Mountain", section="Badlands and Blackrock Mountain"}, -- 1368
  {t="C", q=3906, name="Disharmony of Flame", z=3, x=3.33, y=48.26, note="Overmaster Pyron, in the quarry just before the Blackrock Depths portal", section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1369
  {t="D", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", text="Blackrock Depths", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1370
  {t="C", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", note="Anvilrage Guardsmen, Wardens and Footmen", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1371
  {t="C", q=7201, name="The Last Element", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", note="Essence of the Elements from the fire elementals inside", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1372
  {t="C", q=4134, name="Lost Thunderbrew Recipe", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", note="The Lost Thunderbrew Recipe from the brewers in the Grim Guzzler area", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1373
  {t="H", text="Kargath", section="Blackrock Depths (dungeon, group of 5)"}, -- 1374
  {t="T", q=3906, name="Disharmony of Flame", z=3, x=3.33, y=48.26, target={kind="npc", id=9084, name="Thunderheart"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1375
  {t="T", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1376
  {t="T", q=7201, name="The Last Element", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1377
  {t="T", q=4134, name="Lost Thunderbrew Recipe", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1378
  {t="A", q=4903, name="Warlord's Command", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, note="Warlord Goretooth", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1379
  {t="A", q=4724, name="The Pack Mistress", z=3, x=5.96, y=47.73, target={kind="npc", id=9081, name="Galamav the Marksman"}, note="Galamav the Marksman", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1380
  {t="A", q=4981, name="Operative Bijou", z=3, x=5.88, y=47.63, target={kind="npc", id=9080, name="Lexlort"}, note="Grandmaster Lexlort", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1381
  {t="D", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", text="Lower Blackrock Spire, upper part of Blackrock Mountain", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1382
  {t="T", q=4981, name="Operative Bijou", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, note="Bijou, near the start of the Spire", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1383
  {t="A", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1384
  {t="C", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Bijou's Belongings", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1385
  {t="T", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1386
  {t="A", q=4983, name="Bijou's Reconnaissance Report", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1387
  {t="C", q=4903, name="Warlord's Command", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Highlord Omokk, War Master Voone and Overlord Wyrmthalak, plus the Important Blackrock Documents", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1388
  {t="C", q=4724, name="The Pack Mistress", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Halycon, the worg pack mistress", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1389
  {t="F", text="Kargath", section="Lower Blackrock Spire (dungeon, group of 5)"}, -- 1390
  {t="T", q=4903, name="Warlord's Command", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1391
  {t="T", q=4724, name="The Pack Mistress", z=3, x=5.96, y=47.73, target={kind="npc", id=9081, name="Galamav the Marksman"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1392
  {t="T", q=4983, name="Bijou's Reconnaissance Report", z=3, x=5.88, y=47.63, target={kind="npc", id=9080, name="Lexlort"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1393
  {t="F", text="Undercity", section="Western Plaguelands"}, -- 1394
  {t="TR", text="Train level 58 spells", section="Western Plaguelands"}, -- 1395
  {t="G", z=1497, x=63.9, y=44.1, text="Harbinger Balthazad, Undercity", section="Western Plaguelands", zoneName="Undercity"}, -- 1396
  {t="A", q=5094, name="A Call to Arms: The Plaguelands!", z=1497, x=63.9, y=44.08, target={kind="npc", id=10879, name="Harbinger Balthazad"}, section="Western Plaguelands", zoneName="Undercity"}, -- 1397
  {t="N", text="Ride east out of Undercity to the Bulwark", section="Western Plaguelands"}, -- 1398
  {t="G", z=85, x=83.1, y=68.9, text="The Bulwark, eastern Tirisfal", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1399
  {t="T", q=5094, name="A Call to Arms: The Plaguelands!", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1400
  {t="A", q=5096, name="Scarlet Diversions", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1401
  {t="C", q=5096, name="Scarlet Diversions", z=85, x=83.17, y=69.09, note="Burn the Scarlet tents and supplies at the Scarlet base camp", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1402
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1403
  {t="T", q=5096, name="Scarlet Diversions", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1404
  {t="A", q=5098, name="All Along the Watchtowers", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1405
  {t="A", q=5228, name="The Scourge Cauldrons", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1406
  {t="T", q=5228, name="The Scourge Cauldrons", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, note="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1407
  {t="A", q=5229, name="Target: Felstone Field", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1408
  {t="G", z=28, x=37.2, y=56.8, text="Felstone Field cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1409
  {t="C", q=5229, name="Target: Felstone Field", z=28, x=37.2, y=56.8, note="Kill the Cauldron Lord to get the key, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1410
  {t="T", q=5229, name="Target: Felstone Field", z=28, x=37.25, y=56.78, target={kind="object", id=176361, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1411
  {t="A", q=5230, name="Return to the Bulwark", z=28, x=37.25, y=56.78, target={kind="object", id=176361, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1412
  {t="G", z=28, x=53.7, y=64.7, text="Mulgris Deepriver at the Writhing Haunt", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1413
  {t="A", q=4984, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1414
  {t="C", q=4984, name="The Wildlife Suffers Too", z=28, x=46.52, y=44.91, note="Diseased Wolves", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1415
  {t="C", q=5098, name="All Along the Watchtowers", z=28, x=42.33, y=66.24, note="Mark the four towers in Andorhal with the Beacon Torch", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1416
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1417
  {t="T", q=5098, name="All Along the Watchtowers", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1418
  {t="A", q=105, name="Alas, Andorhal", group=true, z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, note="Group quest: Araj the Summoner in Andorhal", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1419
  {t="A", q=838, name="Scholomance", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1420
  {t="T", q=838, name="Scholomance", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, note="Apothecary Dithers", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1421
  {t="A", q=964, name="Skeletal Fragments", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1422
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis, the Bulwark", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1423
  {t="T", q=5230, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1424
  {t="A", q=5231, name="Target: Dalson's Tears", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1425
  {t="G", z=28, x=46.2, y=51.9, text="Dalson's Tears cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1426
  {t="C", q=5231, name="Target: Dalson's Tears", z=28, x=46.2, y=51.9, note="Kill the Cauldron Lord, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1427
  {t="T", q=5231, name="Target: Dalson's Tears", z=28, x=46.18, y=51.9, target={kind="object", id=177289, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1428
  {t="A", q=5232, name="Return to the Bulwark", z=28, x=46.18, y=51.9, target={kind="object", id=177289, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1429
  {t="A", q=5058, name="Mrs. Dalson's Diary", z=28, x=47.8, y=50.67, target={kind="object", id=175926, name="Mrs. Dalson's Diary"}, note="Mrs. Dalson's Diary in the farmhouse", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1430
  {t="T", q=5058, name="Mrs. Dalson's Diary", z=28, x=47.8, y=50.67, target={kind="object", id=175926, name="Mrs. Dalson's Diary"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1431
  {t="C", q=964, name="Skeletal Fragments", z=28, x=44.99, y=66.93, note="Skeletal Fragments from the undead in Andorhal", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1432
  {t="G", z=28, x=45.3, y=69.2, text="Araj the Summoner, Andorhal", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1433
  {t="C", q=105, name="Alas, Andorhal", group=true, z=28, x=45.3, y=69.2, note="Kill Araj (elite) for the Phylactery Shard", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1434
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1435
  {t="T", q=5232, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1436
  {t="A", q=5233, name="Target: Writhing Haunt", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1437
  {t="T", q=964, name="Skeletal Fragments", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1438
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1439
  {t="T", q=105, name="Alas, Andorhal", group=true, z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1440
  {t="G", z=28, x=53.0, y=65.6, text="Writhing Haunt cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1441
  {t="C", q=5233, name="Target: Writhing Haunt", z=28, x=53.0, y=65.6, note="Kill the Cauldron Lord, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1442
  {t="T", q=5233, name="Target: Writhing Haunt", z=28, x=53.02, y=65.61, target={kind="object", id=176393, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1443
  {t="A", q=5234, name="Return to the Bulwark", z=28, x=53.02, y=65.61, target={kind="object", id=176393, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1444
  {t="T", q=4984, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, note="Mulgris Deepriver", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1445
  {t="A", q=4985, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1446
  {t="C", q=4985, name="The Wildlife Suffers Too", z=28, x=59.01, y=51.61, note="Diseased Grizzlies", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1447
  {t="T", q=4985, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1448
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1449
  {t="T", q=5234, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1450
  {t="N", text="Ride east through Western Plaguelands into Eastern Plaguelands; Tirion Fordring's cabin is at the west edge", section="Eastern Plaguelands"}, -- 1451
  {t="G", z=139, x=7.6, y=43.7, text="Tirion Fordring", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1452
  {t="A", q=5542, name="Demon Dogs", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1453
  {t="A", q=5543, name="Blood Tinged Skies", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1454
  {t="A", q=5544, name="Carrion Grubbage", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1455
  {t="G", z=139, x=26.5, y=74.7, text="Nathanos Blightcaller", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1456
  {t="A", q=6022, name="To Kill With Purpose", z=139, x=26.54, y=74.73, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1457
  {t="A", q=6042, name="Un-Life's Little Annoyances", z=139, x=26.54, y=74.73, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1458
  {t="C", q=5543, name="Blood Tinged Skies", z=139, x=33.19, y=76.18, note="Plaguebats", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1459
  {t="C", q=6042, name="Un-Life's Little Annoyances", z=139, x=55.46, y=50.98, note="Noxious and Monstrous Plaguebats", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1460
  {t="C", q=5542, name="Demon Dogs", z=139, x=54.93, y=54.76, note="Plaguehounds", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1461
  {t="C", q=5544, name="Carrion Grubbage", z=139, x=55.2, y=59.35, note="Carrion Grubs and Devourers", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1462
  {t="C", q=6022, name="To Kill With Purpose", z=139, x=40.71, y=38.94, note="Scourge at Corin's Crossing", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1463
  {t="G", z=139, x=36.5, y=90.8, text="Pamela Redpath in Darrowshire", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1464
  {t="T", q=5601, name="Sister Pamela", z=139, x=36.45, y=90.8, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1465
  {t="A", q=5149, name="Pamela's Doll", z=139, x=36.45, y=90.8, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1466
  {t="C", q=5149, name="Pamela's Doll", z=139, x=38.62, y=92.68, note="Pamela's doll pieces in the ruined houses", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1467
  {t="T", q=5149, name="Pamela's Doll", z=139, x=36.45, y=90.8, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1468
  {t="G", z=139, x=81.5, y=59.8, text="Light's Hope Chapel", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1469
  {t="FP", z=139, x=80.2, y=57.0, text="Light's Hope flight path (Georgia)", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1470
  {t="A", q=6021, name="Zaeldarr the Outcast", z=139, x=79.55, y=63.86, target={kind="npc", id=11038, name="Caretaker Alen"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1471
  {t="C", q=6021, name="Zaeldarr the Outcast", z=139, x=27.47, y=84.86, note="Zaeldarr the Outcast", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1472
  {t="G", z=139, x=26.5, y=74.7, text="Nathanos Blightcaller", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1473
  {t="T", q=6022, name="To Kill With Purpose", z=139, x=26.54, y=74.73, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1474
  {t="T", q=6042, name="Un-Life's Little Annoyances", z=139, x=26.54, y=74.73, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1475
  {t="G", z=139, x=7.6, y=43.7, text="Tirion Fordring", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1476
  {t="T", q=5542, name="Demon Dogs", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1477
  {t="T", q=5543, name="Blood Tinged Skies", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1478
  {t="T", q=5544, name="Carrion Grubbage", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1479
  {t="A", q=5742, name="Redemption", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1480
  {t="C", q=5742, name="Redemption", z=139, x=7.57, y=43.7, note="Listen to Tirion's story", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1481
  {t="T", q=5742, name="Redemption", z=139, x=7.57, y=43.7, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1482
  {t="G", z=139, x=79.5, y=63.9, text="Caretaker Alen, Light's Hope", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1483
  {t="T", q=6021, name="Zaeldarr the Outcast", z=139, x=79.55, y=63.86, target={kind="npc", id=11038, name="Caretaker Alen"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1484
  {t="G", z=139, x=81.5, y=59.7, text="Betina Bigglezink, Light's Hope Chapel", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1485
  {t="A", q=5212, name="The Flesh Does Not Lie", z=139, x=81.47, y=59.66, target={kind="npc", id=11035, name="Betina Bigglezink"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1486
  {t="G", z=139, x=80.6, y=58.0, text="Smokey LaRue", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1487
  {t="A", q=5214, name="The Great Fras Siabi", z=139, x=80.61, y=57.98, target={kind="npc", id=11033, name="Smokey LaRue"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1488
  {t="G", z=139, x=81.4, y=59.8, text="Duke Nicholas Zverenhoff", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1489
  {t="A", q=5251, name="The Archivist", z=139, x=81.44, y=59.82, target={kind="npc", id=11039, name="Duke Nicholas Zverenhoff"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1490
  {t="G", z=139, x=81.7, y=57.8, text="Leonid Barthalomew the Revered", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1491
  {t="A", q=5243, name="Houses of the Holy", z=139, x=81.73, y=57.83, target={kind="npc", id=11036, name="Leonid Barthalomew the Revered"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1492
  {t="D", z=139, x=31.3, y=15.7, instance=2017, dungeonName="Stratholme", text="Stratholme, north Eastern Plaguelands", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1493
  {t="C", q=5212, name="The Flesh Does Not Lie", z=139, x=31.3, y=15.7, instance=2017, dungeonName="Stratholme", note="Plagued Flesh Samples from the undead", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1494
  {t="C", q=5214, name="The Great Fras Siabi", z=139, x=31.3, y=15.7, instance=2017, dungeonName="Stratholme", note="Fras Siabi's smoke shop (Live side)", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1495
  {t="C", q=5251, name="The Archivist", z=139, x=31.3, y=15.7, instance=2017, dungeonName="Stratholme", note="Archivist Galford (Live side)", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1496
  {t="C", q=5243, name="Houses of the Holy", z=139, x=31.3, y=15.7, instance=2017, dungeonName="Stratholme", note="Search the supply crates for holy water", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1497
  {t="G", z=139, x=81.5, y=59.8, text="Light's Hope Chapel", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1498
  {t="T", q=5212, name="The Flesh Does Not Lie", z=139, x=81.47, y=59.66, target={kind="npc", id=11035, name="Betina Bigglezink"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1499
  {t="T", q=5214, name="The Great Fras Siabi", z=139, x=80.61, y=57.98, target={kind="npc", id=11033, name="Smokey LaRue"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1500
  {t="T", q=5251, name="The Archivist", z=139, x=81.44, y=59.82, target={kind="npc", id=11039, name="Duke Nicholas Zverenhoff"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1501
  {t="T", q=5243, name="Houses of the Holy", z=139, x=81.73, y=57.83, target={kind="npc", id=11036, name="Leonid Barthalomew the Revered"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1502
  {t="N", text="Level 60. Train your last spells; Scholomance needs the key chain from the Bulwark, and Dire Maul, Upper Blackrock Spire and raids open up from here.", section="Stratholme (dungeon, group of 5)"}, -- 1503
}
