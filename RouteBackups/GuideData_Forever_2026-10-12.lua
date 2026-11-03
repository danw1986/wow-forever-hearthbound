-- Horde 1-60 quest route, forever edition. IDs and coordinates from WoW Forever (QuestieDB merged Forever export).
-- t: A=accept C=complete T=turn in D=dungeon G=go to N=note SH=set hearth H=hearth
--    FP=get flight path F=fly TR=train
-- q = quest ID, z = zone (AreaTable) ID, x/y = map percent coords, instance = dungeon area ID
-- (the arrow points at that dungeon's entrance), target = NPC/object/item to interact with,
-- races/classes = only show for these ('!' = everyone except).
-- foreverOnly = true marks a quest that is new in WoW Forever (not in Classic Era).
-- group = true marks an elite group quest outside a dungeon.
local _, ns = ...
ns.HordeGuides = ns.HordeGuides or {}
ns.HordeGuides.forever = {
  {t="A", q=92460, name="Coming of Age", foreverOnly=true, z=16593, x=42.82, y=23.37, target={kind="npc", id=251362, name="Ailee Farheart"}, note="Ailee Farheart, where you start", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 1
  {t="T", q=92460, name="Coming of Age", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 2
  {t="A", q=92461, name="Harmony in Balance", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 3
  {t="A", q=92462, name="Infestation Investigation", foreverOnly=true, z=16593, x=43.4, y=24.79, target={kind="npc", id=251368, name="Elatrell Featherlight"}, note="Elatrell Featherlight", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 4
  {t="C", q=92461, name="Harmony in Balance", foreverOnly=true, z=16593, x=44.71, y=26.43, note="Vuldren Juveniles", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 5
  {t="C", q=92462, name="Infestation Investigation", foreverOnly=true, z=16593, x=46.01, y=27.05, note="Pesky Cirrusflies", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 6
  {t="T", q=92461, name="Harmony in Balance", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, note="Rorian the Dayseeker", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 7
  {t="T", q=92462, name="Infestation Investigation", foreverOnly=true, z=16593, x=43.4, y=24.79, target={kind="npc", id=251368, name="Elatrell Featherlight"}, note="Elatrell Featherlight", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 8
  {t="A", q=92463, name="The Cirrusfly Queen", foreverOnly=true, z=16593, x=43.4, y=24.79, target={kind="npc", id=251368, name="Elatrell Featherlight"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 9
  {t="A", q=92474, name="Falling With Style", foreverOnly=true, z=16593, x=43.68, y=24.09, target={kind="npc", id=263113, name="Myriaal Mistwake"}, note="Myriaal Mistwake", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 10
  {t="A", q=94414, name="The Anchors of Zephras", foreverOnly=true, z=16593, x=43.77, y=24.08, target={kind="npc", id=257554, name="Halaan Hawk-Eye"}, note="Halaan Hawk-Eye", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 11
  {t="A", q=92598, name="The Gift of Skysight", foreverOnly=true, z=16593, x=42.65, y=24.36, target={kind="npc", id=251487, name="Ventaari Brightwish"}, note="Ventaari Brightwish", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 12
  {t="G", z=16593, x=43.34, y=23.98, text="Dalia the Collector", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 13
  {t="A", q=93552, name="Harvesting Windstones", foreverOnly=true, z=16593, x=43.34, y=23.98, target={kind="npc", id=251363, name="Dalia the Collector"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 14
  {t="G", z=16593, x=42.1, y=23.49, text="Rorian the Dayseeker", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 15
  {t="A", q=92464, name="Elemental Unrest", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 16
  {t="C", q=94414, name="The Anchors of Zephras", foreverOnly=true, z=16593, x=43.77, y=24.08, note="Borrow Halaan's gift and look at the anchor pylon", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 17
  {t="C", q=92474, name="Falling With Style", foreverOnly=true, z=16593, x=43.67, y=24.14, note="Jump from the watchtower and use Walk on Air", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 18
  {t="C", q=92598, name="The Gift of Skysight", foreverOnly=true, z=16593, x=48.28, y=20.62, note="Use Skysight at the Elemental Convergence", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 19
  {t="T", q=94414, name="The Anchors of Zephras", foreverOnly=true, z=16593, x=43.77, y=24.08, target={kind="npc", id=257554, name="Halaan Hawk-Eye"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 20
  {t="T", q=92598, name="The Gift of Skysight", foreverOnly=true, z=16593, x=42.65, y=24.36, target={kind="npc", id=251487, name="Ventaari Brightwish"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 21
  {t="T", q=92474, name="Falling With Style", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, note="Rorian the Dayseeker", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 22
  {t="T", q=92464, name="Elemental Unrest", foreverOnly=true, z=16593, x=47.26, y=21.88, target={kind="npc", id=249363, name="Yala Windwatcher"}, note="Yala Windwatcher, east side of the grove", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 23
  {t="A", q=92465, name="Agitators", foreverOnly=true, z=16593, x=47.26, y=21.88, target={kind="npc", id=249363, name="Yala Windwatcher"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 24
  {t="C", q=92465, name="Agitators", foreverOnly=true, z=16593, x=47.02, y=19.95, note="Roiling Winds and Al'Aketh Converts", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 25
  {t="C", q=92463, name="The Cirrusfly Queen", foreverOnly=true, z=16593, x=48.41, y=28.53, note="The Cirrusfly Queen", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 26
  {t="C", q=93552, name="Harvesting Windstones", foreverOnly=true, z=16593, x=43.82, y=25.43, note="Windstone Clusters from the Raw Windstones", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 27
  {t="T", q=92465, name="Agitators", foreverOnly=true, z=16593, x=47.26, y=21.88, target={kind="npc", id=249363, name="Yala Windwatcher"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 28
  {t="A", q=92469, name="Return to Rorian", foreverOnly=true, z=16593, x=47.26, y=21.88, target={kind="npc", id=249363, name="Yala Windwatcher"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 29
  {t="T", q=92469, name="Return to Rorian", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, note="Rorian the Dayseeker", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 30
  {t="T", q=92463, name="The Cirrusfly Queen", foreverOnly=true, z=16593, x=43.4, y=24.79, target={kind="npc", id=251368, name="Elatrell Featherlight"}, note="Elatrell Featherlight", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 31
  {t="T", q=93552, name="Harvesting Windstones", foreverOnly=true, z=16593, x=43.34, y=23.98, target={kind="npc", id=251363, name="Dalia the Collector"}, note="Dalia the Collector", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 32
  {t="A", q=92466, name="Call of Earth", foreverOnly=true, z=16593, x=42.76, y=23.58, target={kind="npc", id=251374, name="Windshaper Boro"}, note="Windshaper Boro", races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 33
  {t="C", q=92466, name="Call of Earth", foreverOnly=true, z=16593, x=37.56, y=31.93, note="Signet of Akir from the Al'Aketh", races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 34
  {t="T", q=92466, name="Call of Earth", foreverOnly=true, z=16593, x=42.76, y=23.58, target={kind="npc", id=251374, name="Windshaper Boro"}, races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 35
  {t="A", q=92467, name="Call of Earth", foreverOnly=true, z=16593, x=42.76, y=23.58, target={kind="npc", id=251374, name="Windshaper Boro"}, races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 36
  {t="C", q=92467, name="Call of Earth", foreverOnly=true, z=16593, x=42.76, y=23.58, note="Drink the Earth Sapta at the Rise of Spirits", races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 37
  {t="T", q=92467, name="Call of Earth", foreverOnly=true, z=16593, x=49.67, y=23.8, target={kind="npc", id=251166, name="Minor Manifestation of Earth"}, races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 38
  {t="A", q=92468, name="Call of Earth", foreverOnly=true, z=16593, x=49.67, y=23.8, target={kind="npc", id=251166, name="Minor Manifestation of Earth"}, races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 39
  {t="T", q=92468, name="Call of Earth", foreverOnly=true, z=16593, x=42.76, y=23.58, target={kind="npc", id=251374, name="Windshaper Boro"}, races={"skyborne"}, classes={"Shaman"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 40
  {t="G", z=16593, x=42.1, y=23.49, text="Rorian the Dayseeker", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 41
  {t="A", q=92471, name="Aetheen of the Gales", foreverOnly=true, z=16593, x=42.1, y=23.49, target={kind="npc", id=251361, name="Rorian the Dayseeker"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 42
  {t="T", q=92471, name="Aetheen of the Gales", foreverOnly=true, z=16593, x=42.74, y=23.66, target={kind="npc", id=251366, name="Aetheen of the Gales"}, note="Aetheen of the Gales", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 43
  {t="A", q=92470, name="Foul Matriarch", foreverOnly=true, z=16593, x=42.74, y=23.66, target={kind="npc", id=251366, name="Aetheen of the Gales"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 44
  {t="A", q=92473, name="Aggressive Encroachment", foreverOnly=true, z=16593, x=42.43, y=25.12, target={kind="npc", id=257551, name="Valreaa Valewind"}, note="Valreaa Valewind", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 45
  {t="G", z=16593, x=38.23, y=30.18, text="Hanaa Nightwind, south-west of the grove", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 46
  {t="A", q=92544, name="Al'Aketh Thugs", foreverOnly=true, z=16593, x=38.32, y=30.19, target={kind="npc", id=252095, name="Hanaa Nightwind"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 47
  {t="C", q=92473, name="Aggressive Encroachment", foreverOnly=true, z=16593, x=40.02, y=26.86, note="Scrawny Ursera Claws", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 48
  {t="C", q=92470, name="Foul Matriarch", foreverOnly=true, z=16593, x=37.31, y=25.06, note="Ursera Scavengers and the den mother Urs'anah", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 49
  {t="C", q=92544, name="Al'Aketh Thugs", foreverOnly=true, z=16593, x=37.05, y=32.56, note="Al'Aketh Brutes, Neophytes and Malduko Cloudcrush", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 50
  {t="T", q=92544, name="Al'Aketh Thugs", foreverOnly=true, z=16593, x=38.32, y=30.19, target={kind="npc", id=252095, name="Hanaa Nightwind"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 51
  {t="G", z=16593, x=42.74, y=23.66, text="Back to Thendal Grove", races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 52
  {t="T", q=92473, name="Aggressive Encroachment", foreverOnly=true, z=16593, x=42.43, y=25.12, target={kind="npc", id=257551, name="Valreaa Valewind"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 53
  {t="T", q=92470, name="Foul Matriarch", foreverOnly=true, z=16593, x=42.74, y=23.66, target={kind="npc", id=251366, name="Aetheen of the Gales"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 54
  {t="A", q=92472, name="The Next Step", foreverOnly=true, z=16593, x=42.74, y=23.66, target={kind="npc", id=251366, name="Aetheen of the Gales"}, races={"skyborne"}, section="Zephras Isle: Thendal Grove (Skyborne)", zoneName="Zephras Isle"}, -- 55
  {t="T", q=92472, name="The Next Step", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, note="Constable Aonda", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 56
  {t="A", q=92514, name="Welcome to Shen'dar Village", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 57
  {t="C", q=92514, name="Welcome to Shen'dar Village", foreverOnly=true, z=16593, x=43.16, y=43.58, note="Speak with Illaya Amberwind and Coriella Calmbreeze", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 58
  {t="T", q=92514, name="Welcome to Shen'dar Village", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 59
  {t="A", q=92595, name="The Windshapers", foreverOnly=true, z=16593, x=43.53, y=44.78, target={kind="npc", id=251902, name="Illaya Amberwind"}, note="Illaya Amberwind", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 60
  {t="C", q=92595, name="The Windshapers", foreverOnly=true, z=16593, x=43.53, y=44.78, note="Listen to Illaya", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 61
  {t="T", q=92595, name="The Windshapers", foreverOnly=true, z=16593, x=43.53, y=44.78, target={kind="npc", id=251902, name="Illaya Amberwind"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 62
  {t="A", q=94411, name="Meddlesome Mages", foreverOnly=true, z=16593, x=43.53, y=44.78, target={kind="npc", id=251902, name="Illaya Amberwind"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 63
  {t="A", q=92515, name="The Problem With Prideclaws", foreverOnly=true, z=16593, x=44.67, y=44.52, target={kind="npc", id=251993, name="Indari Sunseam"}, note="Indari Sunseam", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 64
  {t="A", q=92553, name="Restocking the Larders", foreverOnly=true, z=16593, x=43.85, y=43.9, target={kind="npc", id=251905, name="Zerril Softbreeze"}, note="Zerril Softbreeze", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 65
  {t="A", q=92516, name="Hippogryph Harrassment", foreverOnly=true, z=16593, x=44.44, y=44.82, target={kind="npc", id=251906, name="Teeri Wellwind"}, note="Teeri Wellwind", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 66
  {t="A", q=93319, name="Pilfered Windstones", foreverOnly=true, z=16593, x=44.44, y=44.82, target={kind="npc", id=251906, name="Teeri Wellwind"}, note="Teeri Wellwind", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 67
  {t="A", q=92517, name="The Criminal Element", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, note="Constable Aonda", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 68
  {t="A", q=93951, name="A Little Beauty", foreverOnly=true, z=16593, x=44.83, y=44.25, target={kind="npc", id=251991, name="Taleen Shimmerthread"}, note="Taleen Shimmerthread", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 69
  {t="A", q=93318, name="WANTED: Vulgara the Insatiable", foreverOnly=true, z=16593, x=43.37, y=45.82, target={kind="object", id=610954, name="Bounty Available: Vulgara the Insatiable!"}, note="Bounty board", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 70
  {t="C", q=94411, name="Meddlesome Mages", foreverOnly=true, z=16593, x=46.16, y=39.21, note="High Order Apprentices", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 71
  {t="C", q=92515, name="The Problem With Prideclaws", foreverOnly=true, z=16593, x=41.38, y=44.79, note="Prideclaw Pelts", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 72
  {t="C", q=92553, name="Restocking the Larders", foreverOnly=true, z=16593, x=39.99, y=45.47, note="Small Eggs and Strider Meat", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 73
  {t="C", q=92516, name="Hippogryph Harrassment", foreverOnly=true, z=16593, x=36.94, y=53.37, note="Hippogryph Youths, Protectors and the Matriarch", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 74
  {t="C", q=93951, name="A Little Beauty", foreverOnly=true, z=16593, x=36.02, y=54.29, note="Hippogryph Down feathers", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 75
  {t="C", q=92517, name="The Criminal Element", foreverOnly=true, z=16593, x=48.65, y=37.42, note="Highlands Bandits and \"Badwind\" Bennic", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 76
  {t="C", q=93319, name="Pilfered Windstones", foreverOnly=true, z=16593, x=48.65, y=37.42, note="Pilfered Windstones from the bandits", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 77
  {t="C", q=93318, name="WANTED: Vulgara the Insatiable", foreverOnly=true, z=16593, x=42.66, y=52.8, note="Vulgara the Insatiable", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 78
  {t="G", z=16593, x=45.63, y=45.49, text="Shen'dar Village", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 79
  {t="T", q=94411, name="Meddlesome Mages", foreverOnly=true, z=16593, x=43.53, y=44.78, target={kind="npc", id=251902, name="Illaya Amberwind"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 80
  {t="T", q=92515, name="The Problem With Prideclaws", foreverOnly=true, z=16593, x=44.67, y=44.52, target={kind="npc", id=251993, name="Indari Sunseam"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 81
  {t="T", q=92553, name="Restocking the Larders", foreverOnly=true, z=16593, x=43.85, y=43.9, target={kind="npc", id=251905, name="Zerril Softbreeze"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 82
  {t="T", q=92516, name="Hippogryph Harrassment", foreverOnly=true, z=16593, x=44.44, y=44.82, target={kind="npc", id=251906, name="Teeri Wellwind"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 83
  {t="T", q=93319, name="Pilfered Windstones", foreverOnly=true, z=16593, x=44.44, y=44.82, target={kind="npc", id=251906, name="Teeri Wellwind"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 84
  {t="T", q=93951, name="A Little Beauty", foreverOnly=true, z=16593, x=44.83, y=44.25, target={kind="npc", id=251991, name="Taleen Shimmerthread"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 85
  {t="T", q=92517, name="The Criminal Element", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 86
  {t="T", q=93318, name="WANTED: Vulgara the Insatiable", foreverOnly=true, z=16593, x=45.2, y=45.21, target={kind="npc", id=252172, name="Danarii Bellowveil"}, note="Danarii Bellowveil", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 87
  {t="A", q=93036, name="Infiltrating the Cult", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 88
  {t="T", q=93036, name="Infiltrating the Cult", foreverOnly=true, z=16593, x=44.86, y=45.47, target={kind="npc", id=251904, name="Sania Silverstream"}, note="Sania Silverstream", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 89
  {t="A", q=92529, name="Falaath Village", foreverOnly=true, z=16593, x=44.86, y=45.47, target={kind="npc", id=251904, name="Sania Silverstream"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 90
  {t="T", q=92529, name="Falaath Village", foreverOnly=true, z=16593, x=46.85, y=56.21, target={kind="npc", id=257065, name="Missionary Jasaan"}, note="Missionary Jasaan, at the Falaath Village entrance", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 91
  {t="A", q=92528, name="Among the Faithful", foreverOnly=true, z=16593, x=46.85, y=56.21, target={kind="npc", id=257065, name="Missionary Jasaan"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 92
  {t="C", q=92528, name="Among the Faithful", foreverOnly=true, z=16593, x=48.84, y=53.93, note="Search Falaath Village for the cult's plans", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 93
  {t="T", q=92528, name="Among the Faithful", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, note="Constable Aonda", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 94
  {t="A", q=92550, name="Havoc in the Highlands", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 95
  {t="A", q=92551, name="Stolen Supplies", foreverOnly=true, z=16593, x=45.2, y=45.21, target={kind="npc", id=252172, name="Danarii Bellowveil"}, note="Danarii Bellowveil", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 96
  {t="A", q=93926, name="The Western Watch", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 97
  {t="C", q=92550, name="Havoc in the Highlands", foreverOnly=true, z=16593, x=48.32, y=55.68, note="Al'Aketh Stormcallers, Living Lightning and Commander Cyclas", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 98
  {t="C", q=92551, name="Stolen Supplies", foreverOnly=true, z=16593, x=49.28, y=57.26, note="Stolen Shen'dar Supplies", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 99
  {t="C", q=93926, name="The Western Watch", foreverOnly=true, z=16593, x=42.34, y=62.1, note="Find Peacekeeper Vaaniel at the western watchtower", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 100
  {t="T", q=93926, name="The Western Watch", foreverOnly=true, z=16593, x=42.34, y=62.1, target={kind="npc", id=252155, name="Peacekeeper Vaaniel"}, note="Peacekeeper Vaaniel at the western watchtower", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 101
  {t="A", q=93927, name="A Last Request", foreverOnly=true, z=16593, x=42.34, y=62.1, target={kind="npc", id=252155, name="Peacekeeper Vaaniel"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 102
  {t="C", q=93927, name="A Last Request", foreverOnly=true, z=16593, x=41.02, y=64.09, note="Read the note found on the peacekeeper", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 103
  {t="G", z=16593, x=45.63, y=45.49, text="Shen'dar Village", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 104
  {t="T", q=92550, name="Havoc in the Highlands", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 105
  {t="T", q=92551, name="Stolen Supplies", foreverOnly=true, z=16593, x=45.2, y=45.21, target={kind="npc", id=252172, name="Danarii Bellowveil"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 106
  {t="T", q=93927, name="A Last Request", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 107
  {t="A", q=92579, name="To Valanaar", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 108
  {t="A", q=93948, name="Deliver the Signet", foreverOnly=true, z=16593, x=45.63, y=45.49, target={kind="npc", id=251523, name="Constable Aonda"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 109
  {t="G", z=16593, x=56.82, y=61.05, text="Fendaal Windstone, on the road to Valanaar", races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 110
  {t="A", q=98512, name="Al'Aketh Assassins", foreverOnly=true, z=16593, x=56.82, y=61.05, target={kind="npc", id=273017, name="Fendaal Windstone"}, races={"skyborne"}, section="Zephras Isle: Shen'dar Village", zoneName="Zephras Isle"}, -- 111
  {t="G", z=16593, x=66.22, y=76.63, text="Valanaar", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 112
  {t="T", q=92579, name="To Valanaar", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, note="Valennia Stormfist", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 113
  {t="A", q=92700, name="The Grand Skyseer", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 114
  {t="T", q=93948, name="Deliver the Signet", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, note="Talaanis Shadowsong", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 115
  {t="A", q=93949, name="Bugged", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, note="Valennia Stormfist", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 116
  {t="T", q=92700, name="The Grand Skyseer", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, note="Ayessa Dawnsinger", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 117
  {t="A", q=93735, name="The Broken Construct", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 118
  {t="A", q=92708, name="A Grand Adventure", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 119
  {t="C", q=92708, name="A Grand Adventure", foreverOnly=true, z=16593, x=59.15, y=79.73, note="Listen to Ayessa", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 120
  {t="T", q=92708, name="A Grand Adventure", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 121
  {t="A", q=93736, name="Unwelcome Spirits", foreverOnly=true, z=16593, x=58.17, y=78.3, target={kind="npc", id=254344, name="Endaria Mistgaze"}, note="Endaria Mistgaze", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 122
  {t="A", q=93317, name="Crab Season", foreverOnly=true, z=16593, x=60.66, y=72.72, target={kind="npc", id=257006, name="Nyalah Brightfire"}, note="Nyalah Brightfire", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 123
  {t="A", q=92679, name="Blood Tithe", foreverOnly=true, z=16593, x=62.14, y=73.3, target={kind="npc", id=252448, name="Alvarion Windfield"}, note="Alvarion Windfield", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 124
  {t="G", z=16593, x=63.99, y=75.0, text="Lotheluum Starbreeze", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 125
  {t="A", q=94484, name="Unnerving Silence", foreverOnly=true, z=16593, x=64.02, y=75.11, target={kind="npc", id=252359, name="Lotheluum Starbreeze"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 126
  {t="G", z=16593, x=65.93, y=74.37, text="Ealaane Nimbuswalker", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 127
  {t="A", q=94896, name="Aid For The Refugees", foreverOnly=true, z=16593, x=65.93, y=74.37, target={kind="npc", id=259012, name="Ealaane Nimbuswalker"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 128
  {t="A", q=94897, name="The Fate of a Loved One", foreverOnly=true, z=16593, x=65.93, y=74.37, target={kind="npc", id=259012, name="Ealaane Nimbuswalker"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 129
  {t="T", q=93735, name="The Broken Construct", foreverOnly=true, z=16593, x=59.09, y=73, target={kind="npc", id=256083, name="Riaani Nightwind"}, note="Riaani Nightwind", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 130
  {t="A", q=93737, name="The Broken Construct", foreverOnly=true, z=16593, x=59.09, y=73, target={kind="npc", id=256083, name="Riaani Nightwind"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 131
  {t="C", q=93737, name="The Broken Construct", foreverOnly=true, z=16593, x=51.9, y=65.6, note="Listen to Riaani, then collect the construct parts", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 132
  {t="T", q=93737, name="The Broken Construct", foreverOnly=true, z=16593, x=59.09, y=73, target={kind="npc", id=256083, name="Riaani Nightwind"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 133
  {t="A", q=93738, name="The Broken Construct", foreverOnly=true, z=16593, x=59.09, y=73, target={kind="npc", id=256083, name="Riaani Nightwind"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 134
  {t="C", q=93949, name="Bugged", foreverOnly=true, z=16593, x=62.6, y=75.94, note="Enchanted Skyhoppers", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 135
  {t="C", q=93317, name="Crab Season", foreverOnly=true, z=16593, x=50.91, y=60.4, note="Windsong Crawler Meat", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 136
  {t="C", q=98512, name="Al'Aketh Assassins", foreverOnly=true, z=16593, x=55.79, y=60.46, note="Al'Aketh Assassins", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 137
  {t="C", q=94896, name="Aid For The Refugees", foreverOnly=true, z=16593, x=57.6, y=32.1, note="Abandoned Belongings in the ruins of Ban'aethal", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 138
  {t="C", q=94897, name="The Fate of a Loved One", foreverOnly=true, z=16593, x=57.05, y=29.35, note="Resaan's Heirloom in the ruins of Ban'aethal", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 139
  {t="G", z=16593, x=56.82, y=61.05, text="Fendaal Windstone", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 140
  {t="T", q=98512, name="Al'Aketh Assassins", foreverOnly=true, z=16593, x=56.82, y=61.05, target={kind="npc", id=273017, name="Fendaal Windstone"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 141
  {t="G", z=16593, x=66.22, y=76.63, text="Valanaar", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 142
  {t="T", q=93738, name="The Broken Construct", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, note="Ayessa Dawnsinger", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 143
  {t="T", q=93949, name="Bugged", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 144
  {t="T", q=93317, name="Crab Season", foreverOnly=true, z=16593, x=60.66, y=72.72, target={kind="npc", id=257006, name="Nyalah Brightfire"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 145
  {t="T", q=94896, name="Aid For The Refugees", foreverOnly=true, z=16593, x=65.93, y=74.37, target={kind="npc", id=259012, name="Ealaane Nimbuswalker"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 146
  {t="T", q=94897, name="The Fate of a Loved One", foreverOnly=true, z=16593, x=65.93, y=74.37, target={kind="npc", id=259012, name="Ealaane Nimbuswalker"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 147
  {t="A", q=93746, name="A Firm Response", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 148
  {t="C", q=93746, name="A Firm Response", foreverOnly=true, z=16593, x=59.84, y=57.19, note="Confront Belathaan Brightwish on the road to the Shrine of Akir", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 149
  {t="T", q=93746, name="A Firm Response", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 150
  {t="A", q=92871, name="In Service of Zephras", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 151
  {t="A", q=93740, name="Blood for Blood", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 152
  {t="T", q=92871, name="In Service of Zephras", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, note="Valennia Stormfist", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 153
  {t="A", q=93320, name="Tower Defense", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 154
  {t="T", q=93320, name="Tower Defense", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, note="Yorana Windyreed at the eastern watchtower", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 155
  {t="A", q=92642, name="Disrupting Logistics", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 156
  {t="A", q=92645, name="Breaking the Breaker", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 157
  {t="C", q=93736, name="Unwelcome Spirits", foreverOnly=true, z=16593, x=58.14, y=31.91, note="Wind Hollow Essences", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 158
  {t="C", q=93740, name="Blood for Blood", foreverOnly=true, z=16593, x=63.55, y=50.46, note="Al'Aketh Windstone Charms", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 159
  {t="C", q=92642, name="Disrupting Logistics", foreverOnly=true, z=16593, x=65.5, y=67.12, note="Al'Aketh Healers and Brawlers", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 160
  {t="C", q=92645, name="Breaking the Breaker", foreverOnly=true, z=16593, x=65.58, y=65.62, note="Commander Belguilos", races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 161
  {t="T", q=92642, name="Disrupting Logistics", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 162
  {t="T", q=92645, name="Breaking the Breaker", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 163
  {t="A", q=92880, name="Return to Valanaar", foreverOnly=true, z=16593, x=69.61, y=67.11, target={kind="npc", id=252378, name="Yorana Windyreed"}, races={"skyborne"}, section="Zephras Isle: Valanaar and the Gustberry Lowlands", zoneName="Zephras Isle"}, -- 164
  {t="C", q=92679, name="Blood Tithe", foreverOnly=true, z=16593, x=46.7, y=81.95, note="Listen to Alvarion, then find Aamelia", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 165
  {t="T", q=92679, name="Blood Tithe", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, note="Aamelia Windfield at the Windfield Orchard", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 166
  {t="A", q=92682, name="Make Yourself Useful", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 167
  {t="A", q=92683, name="Flutterfly Dust", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 168
  {t="A", q=92684, name="Ornery Ornery Galestriders", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 169
  {t="G", z=16593, x=48.54, y=78.04, text="Malfunctioning Cyclone Construct", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 170
  {t="A", q=92698, name="What Is My Purpose?", foreverOnly=true, z=16593, x=48.82, y=78.38, target={kind="npc", id=250929, name="Malfunctioning Cyclone Construct"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 171
  {t="T", q=92698, name="What Is My Purpose?", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, note="Aamelia Windfield", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 172
  {t="C", q=92682, name="Make Yourself Useful", foreverOnly=true, z=16593, x=46.85, y=80.41, note="Ripe Stormapples and Hungry Bandits", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 173
  {t="C", q=92683, name="Flutterfly Dust", foreverOnly=true, z=16593, x=50.5, y=79.6, note="Flutterfly Dust", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 174
  {t="C", q=92684, name="Ornery Ornery Galestriders", foreverOnly=true, z=16593, x=50.86, y=77.44, note="Lowlands Galestrider Tenderloins", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 175
  {t="T", q=92682, name="Make Yourself Useful", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 176
  {t="T", q=92683, name="Flutterfly Dust", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 177
  {t="T", q=92684, name="Ornery Ornery Galestriders", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 178
  {t="A", q=92685, name="The Hills Have Eyes", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 179
  {t="C", q=92685, name="The Hills Have Eyes", foreverOnly=true, z=16593, x=44.85, y=74.63, note="Blood-Stained Bandit Masks from Highwayman Bandits", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 180
  {t="T", q=92685, name="The Hills Have Eyes", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 181
  {t="A", q=92693, name="Standing Our Ground", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 182
  {t="C", q=92693, name="Standing Our Ground", foreverOnly=true, z=16593, x=47.51, y=78.39, note="Tell Aamelia when you are ready, then defeat Ferauu the Bludgeon", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 183
  {t="T", q=92693, name="Standing Our Ground", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 184
  {t="A", q=92703, name="Deliver the News", foreverOnly=true, z=16593, x=46.7, y=81.95, target={kind="npc", id=252800, name="Aamelia Windfield"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 185
  {t="G", z=16593, x=66.22, y=76.63, text="Valanaar", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 186
  {t="T", q=92703, name="Deliver the News", foreverOnly=true, z=16593, x=62.14, y=73.3, target={kind="npc", id=252448, name="Alvarion Windfield"}, note="Alvarion Windfield", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 187
  {t="T", q=92880, name="Return to Valanaar", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, note="Valennia Stormfist", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 188
  {t="T", q=93736, name="Unwelcome Spirits", foreverOnly=true, z=16593, x=58.17, y=78.3, target={kind="npc", id=254344, name="Endaria Mistgaze"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 189
  {t="T", q=93740, name="Blood for Blood", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, note="Ayessa Dawnsinger", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 190
  {t="A", q=92881, name="The High Elder's Request", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 191
  {t="T", q=92881, name="The High Elder's Request", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, note="Talaanis Shadowsong", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 192
  {t="A", q=92643, name="The Turncoat", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 193
  {t="C", q=92643, name="The Turncoat", foreverOnly=true, z=16593, x=56.01, y=58.81, note="The cultist turncoat's house north-west of Valanaar", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 194
  {t="T", q=92643, name="The Turncoat", foreverOnly=true, z=16593, x=56.01, y=58.81, target={kind="npc", id=253372, name="Dead Cultist"}, note="The Dead Cultist", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 195
  {t="A", q=92644, name="Unfortunate News", foreverOnly=true, z=16593, x=56.01, y=58.81, target={kind="npc", id=253372, name="Dead Cultist"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 196
  {t="T", q=92644, name="Unfortunate News", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, note="Talaanis Shadowsong", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 197
  {t="A", q=94568, name="The Cult's True Plans", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 198
  {t="C", q=94568, name="The Cult's True Plans", foreverOnly=true, z=16593, x=66.17, y=76.51, note="Watch the conversation", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 199
  {t="T", q=94568, name="The Cult's True Plans", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 200
  {t="A", q=92640, name="Desperate Times", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 201
  {t="C", q=92640, name="Desperate Times", foreverOnly=true, z=16593, x=66.59, y=79.92, note="Speak with Valennia and follow her instructions", races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 202
  {t="T", q=92640, name="Desperate Times", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: the Windfield Orchard", zoneName="Zephras Isle"}, -- 203
  {t="T", q=94484, name="Unnerving Silence", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, note="Elegael Thornpaw, north-east Shadowgale Forest", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 204
  {t="A", q=94485, name="Tears of the Lady", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 205
  {t="A", q=94486, name="Feathers for Binding", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 206
  {t="A", q=94487, name="Unwanted and Unworthy", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 207
  {t="G", z=16593, x=63.77, y=35.87, text="Vayn Moongaze", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 208
  {t="A", q=93165, name="Mercy Falls on Deaf Ears", foreverOnly=true, z=16593, x=63.77, y=35.87, target={kind="npc", id=254151, name="Vayn Moongaze"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 209
  {t="G", z=16593, x=53.96, y=38.9, text="The Strange Hermit", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 210
  {t="A", q=93159, name="The Strange Hermit", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 211
  {t="C", q=93159, name="The Strange Hermit", foreverOnly=true, z=16593, x=53.96, y=38.9, note="Speak with the Strange Hermit", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 212
  {t="T", q=93159, name="The Strange Hermit", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 213
  {t="A", q=93160, name="The Forest's Bounty", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 214
  {t="A", q=93172, name="Free the Hollows", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 215
  {t="C", q=94485, name="Tears of the Lady", foreverOnly=true, z=16593, x=60.8, y=38.7, note="Lady's Tear Moss", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 216
  {t="C", q=94486, name="Feathers for Binding", foreverOnly=true, z=16593, x=59.21, y=38.64, note="Pristine Shriekling Feathers", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 217
  {t="C", q=94487, name="Unwanted and Unworthy", foreverOnly=true, z=16593, x=63.69, y=37.39, note="Bloodied Heirlooms from Al'Aketh Footsoldiers and Stormchasers", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 218
  {t="C", q=93165, name="Mercy Falls on Deaf Ears", foreverOnly=true, z=16593, x=63.55, y=50.46, note="Al'Aketh Cultist's Ears", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 219
  {t="C", q=93160, name="The Forest's Bounty", foreverOnly=true, z=16593, x=58.8, y=38.7, note="Shadowgale Acorns", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 220
  {t="C", q=93172, name="Free the Hollows", foreverOnly=true, z=16593, x=58.14, y=31.91, note="Wind Hollows", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 221
  {t="T", q=93160, name="The Forest's Bounty", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 222
  {t="T", q=93172, name="Free the Hollows", foreverOnly=true, z=16593, x=53.96, y=38.9, target={kind="npc", id=251684, name="Strange Hermit"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 223
  {t="G", z=16593, x=63.77, y=35.87, text="Vayn Moongaze", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 224
  {t="T", q=93165, name="Mercy Falls on Deaf Ears", foreverOnly=true, z=16593, x=63.77, y=35.87, target={kind="npc", id=254151, name="Vayn Moongaze"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 225
  {t="A", q=93459, name="More Al'Aketh Ears", foreverOnly=true, z=16593, x=63.77, y=35.87, target={kind="npc", id=254151, name="Vayn Moongaze"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 226
  {t="G", z=16593, x=61.69, y=39.25, text="Elegael Thornpaw", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 227
  {t="T", q=94485, name="Tears of the Lady", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 228
  {t="T", q=94486, name="Feathers for Binding", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 229
  {t="T", q=94487, name="Unwanted and Unworthy", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 230
  {t="A", q=94488, name="The Ties That Bind", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 231
  {t="A", q=94489, name="The Wounds of Betrayal", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 232
  {t="A", q=94490, name="Ripped Missive", foreverOnly=true, z=16593, x=65.53, y=36.32, target={kind="item", id=265476, name="Ripped Missive"}, note="The Ripped Missive", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 233
  {t="C", q=94488, name="The Ties That Bind", foreverOnly=true, z=16593, x=65.53, y=36.32, note="Commander Haalien", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 234
  {t="C", q=94489, name="The Wounds of Betrayal", foreverOnly=true, z=16593, x=64.48, y=34.74, note="Heal the druids in the Nightfang Den and find Jorel Windsinger", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 235
  {t="C", q=93459, name="More Al'Aketh Ears", foreverOnly=true, z=16593, x=63.55, y=50.46, note="More Al'Aketh Cultist's Ears", races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 236
  {t="T", q=94488, name="The Ties That Bind", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 237
  {t="T", q=94489, name="The Wounds of Betrayal", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 238
  {t="T", q=94490, name="Ripped Missive", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 239
  {t="A", q=94491, name="The Fate of the Den", foreverOnly=true, z=16593, x=61.69, y=39.25, target={kind="npc", id=257944, name="Elegael Thornpaw"}, races={"skyborne"}, section="Zephras Isle: Shadowgale Forest", zoneName="Zephras Isle"}, -- 240
  {t="G", z=16593, x=66.22, y=76.63, text="Valanaar", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 241
  {t="T", q=94491, name="The Fate of the Den", foreverOnly=true, z=16593, x=64.02, y=75.11, target={kind="npc", id=252359, name="Lotheluum Starbreeze"}, note="Lotheluum Starbreeze", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 242
  {t="G", z=16593, x=63.77, y=35.87, text="Vayn Moongaze", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 243
  {t="T", q=93459, name="More Al'Aketh Ears", foreverOnly=true, z=16593, x=63.77, y=35.87, target={kind="npc", id=254151, name="Vayn Moongaze"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 244
  {t="G", z=16593, x=66.22, y=76.63, text="Valennia Stormfist", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 245
  {t="A", q=93065, name="Prepare for Battle", foreverOnly=true, z=16593, x=66.22, y=76.63, target={kind="npc", id=252383, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 246
  {t="C", q=93065, name="Prepare for Battle", foreverOnly=true, z=16593, x=61.19, y=70.8, note="Speak with Valennia in the Gustberry Lowlands", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 247
  {t="T", q=93065, name="Prepare for Battle", foreverOnly=true, z=16593, x=61.19, y=70.8, target={kind="npc", id=253844, name="Valennia Stormfist"}, note="Valennia Stormfist in the Gustberry Lowlands", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 248
  {t="A", q=92947, name="Making Our Move", foreverOnly=true, z=16593, x=61.19, y=70.8, target={kind="npc", id=253844, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 249
  {t="C", q=92947, name="Making Our Move", foreverOnly=true, z=16593, x=61.46, y=51.24, note="Al'Aketh Guardians, Spiritcallers and Blademasters at the Shrine of Akir", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 250
  {t="T", q=92947, name="Making Our Move", foreverOnly=true, z=16593, x=63.77, y=50.51, target={kind="npc", id=253576, name="Hyusaa Quickbreeze"}, note="Hyusaa Quickbreeze", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 251
  {t="A", q=93958, name="The Inner Sanctum", foreverOnly=true, z=16593, x=63.77, y=50.51, target={kind="npc", id=253576, name="Hyusaa Quickbreeze"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 252
  {t="T", q=93958, name="The Inner Sanctum", foreverOnly=true, z=16593, x=65.22, y=50.37, target={kind="npc", id=253590, name="Valennia Stormfist"}, note="Valennia Stormfist in the inner sanctum", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 253
  {t="A", q=92646, name="Confront Lorthuna", foreverOnly=true, z=16593, x=65.22, y=50.37, target={kind="npc", id=253590, name="Valennia Stormfist"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 254
  {t="C", q=92646, name="Confront Lorthuna", foreverOnly=true, z=16593, x=74.87, y=53.02, note="Take the portal to the Rohashi Spires and confront Lorthuna", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 255
  {t="T", q=92646, name="Confront Lorthuna", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, note="Ayessa Dawnsinger", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 256
  {t="A", q=93836, name="The Fate of Zephras", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 257
  {t="C", q=93836, name="The Fate of Zephras", foreverOnly=true, z=16593, x=66.17, y=76.51, note="Speak with Talaanis", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 258
  {t="T", q=93836, name="The Fate of Zephras", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, note="Talaanis Shadowsong", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 259
  {t="A", q=93090, name="What Comes Next", foreverOnly=true, z=16593, x=66.17, y=76.51, target={kind="npc", id=252476, name="Talaanis Shadowsong"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 260
  {t="T", q=93090, name="What Comes Next", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, note="Ayessa Dawnsinger", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 261
  {t="A", q=95349, name="The Earthen Ring", foreverOnly=true, z=16593, x=59.15, y=79.73, target={kind="npc", id=251968, name="Ayessa Dawnsinger"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Zephras Isle"}, -- 262
  {t="N", text="Take the skycutter ship from Zephras Isle to Mulgore", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir"}, -- 263
  {t="T", q=95349, name="The Earthen Ring", foreverOnly=true, z=215, x=33.4, y=22.5, target={kind="npc", id=259119, name="Alaana Stormwalker"}, note="Alaana Stormwalker, north Mulgore", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Mulgore"}, -- 264
  {t="A", q=95350, name="Welcome to Azeroth", foreverOnly=true, z=215, x=33.4, y=22.5, target={kind="npc", id=259119, name="Alaana Stormwalker"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Mulgore"}, -- 265
  {t="N", text="Travel to Orgrimmar: east out of Mulgore into the Barrens, then north along the road", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir"}, -- 266
  {t="T", q=95350, name="Welcome to Azeroth", foreverOnly=true, z=1637, x=31.73, y=37.82, target={kind="npc", id=4949, name="Thrall"}, note="Thrall, Orgrimmar", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Orgrimmar"}, -- 267
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Orgrimmar"}, -- 268
  {t="A", q=98024, name="Journey to the Crossroads", foreverOnly=true, z=1637, x=31.73, y=37.82, target={kind="npc", id=4949, name="Thrall"}, races={"skyborne"}, section="Zephras Isle: the Shrine of Akir", zoneName="Orgrimmar"}, -- 269
  {t="TR", text="Visit your class trainer in Orgrimmar", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir"}, -- 270
  {t="N", text="Leave Orgrimmar by the west gate and follow the road into the Barrens to the Crossroads", races={"skyborne"}, section="Zephras Isle: the Shrine of Akir"}, -- 271
  {t="A", q=4641, name="Your Place In The World", z=14, x=43.29, y=68.53, target={kind="npc", id=10176, name="Kaltunk"}, note="Talk to Kaltunk right where you spawn", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 272
  {t="T", q=4641, name="Your Place In The World", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 273
  {t="A", q=788, name="Cutting Teeth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 274
  {t="C", q=788, name="Cutting Teeth", z=14, x=44.49, y=65.1, note="Mottled Boars just north of the Den", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 275
  {t="T", q=788, name="Cutting Teeth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 276
  {t="A", q=97279, name="Wayward Weapons", foreverOnly=true, z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, note="Gornek", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 277
  {t="C", q=97279, name="Wayward Weapons", foreverOnly=true, z=14, x=44.4, y=64.6, note="Abandoned Training Weapons around the valley", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 278
  {t="T", q=97279, name="Wayward Weapons", foreverOnly=true, z=14, x=40.47, y=68, target={kind="npc", id=3159, name="Kzan Thornslash"}, note="Kzan Thornslash in the Den", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 279
  {t="A", q=789, name="Sting of the Scorpid", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 280
  {t="TR", text="Visit your class trainer in the Den for level 2 spells", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)"}, -- 281
  {t="A", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=42.73, y=67.23, target={kind="npc", id=9796, name="Galgar"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 282
  {t="A", q=792, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 283
  {t="A", q=1485, name="Vile Familiars", z=14, x=42.59, y=69, target={kind="npc", id=5765, name="Ruzan"}, note="Warlocks get their own Vile Familiars from Ruzan", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 284
  {t="C", q=789, name="Sting of the Scorpid", z=14, x=41.37, y=63.37, note="Scorpid Workers, west side of the valley", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 285
  {t="C", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=43.81, y=62.83, note="Cactus Apples sit at the base of cacti", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 286
  {t="A", q=790, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 287
  {t="C", q=790, name="Sarkoth", z=14, x=40.5, y=66.83, note="Sarkoth wanders the hill southwest of Hana'zua", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 288
  {t="T", q=790, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 289
  {t="A", q=804, name="Sarkoth", z=14, x=40.6, y=62.58, target={kind="npc", id=3287, name="Hana'zua"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 290
  {t="G", z=14, x=44.6, y=68.7, text="Foreman Thazz'ril", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 291
  {t="A", q=5441, name="Lazy Peons", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 292
  {t="C", q=5441, name="Lazy Peons", z=14, x=45.65, y=65.7, note="Click sleeping peons with the Foreman's Blackjack around the lumber piles", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 293
  {t="T", q=789, name="Sting of the Scorpid", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 294
  {t="T", q=804, name="Sarkoth", z=14, x=42.06, y=68.33, target={kind="npc", id=3143, name="Gornek"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 295
  {t="T", q=4402, name="Galgar's Cactus Apple Surprise", z=14, x=42.73, y=67.23, target={kind="npc", id=9796, name="Galgar"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 296
  {t="T", q=5441, name="Lazy Peons", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 297
  {t="A", q=6394, name="Thazz'ril's Pick", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 298
  {t="C", q=792, name="Vile Familiars", z=14, x=44.24, y=55.26, note="Vile Familiars outside Burning Blade Coven (north cave)", races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 299
  {t="C", q=1485, name="Vile Familiars", z=14, x=44.24, y=55.26, note="Vile Familiars outside Burning Blade Coven (north cave)", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 300
  {t="C", q=6394, name="Thazz'ril's Pick", z=14, x=43.73, y=53.79, note="The pick lies in the cave", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 301
  {t="T", q=792, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, classes={"!Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 302
  {t="T", q=1485, name="Vile Familiars", z=14, x=42.59, y=69, target={kind="npc", id=5765, name="Ruzan"}, races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 303
  {t="A", q=1499, name="Vile Familiars", z=14, x=42.59, y=69, target={kind="npc", id=5765, name="Ruzan"}, races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 304
  {t="T", q=1499, name="Vile Familiars", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, note="Hand the Vile Familiar's head chain on to Zureetha", races={"orc", "troll"}, classes={"Warlock"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 305
  {t="A", q=794, name="Burning Blade Medallion", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 306
  {t="C", q=794, name="Burning Blade Medallion", z=14, x=42.71, y=52.95, note="Yarrog Baneshadow, back of the cave", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 307
  {t="T", q=794, name="Burning Blade Medallion", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 308
  {t="T", q=6394, name="Thazz'ril's Pick", z=14, x=44.63, y=68.65, target={kind="npc", id=11378, name="Foreman Thazz'ril"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 309
  {t="A", q=805, name="Report to Sen'jin Village", z=14, x=42.85, y=69.15, target={kind="npc", id=3145, name="Zureetha Fargaze"}, races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)", zoneName="Durotar"}, -- 310
  {t="TR", text="Train level 4 spells before leaving", races={"orc", "troll"}, section="Valley of Trials (Orc / Troll)"}, -- 311
  {t="A", q=2161, name="A Peon's Burden", z=14, x=52.06, y=68.31, target={kind="npc", id=6786, name="Ukor"}, note="Ukor, at the exit of the valley", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 312
  {t="G", z=14, x=54.2, y=73.3, text="Lar Prowltusk outside Sen'jin Village", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 313
  {t="A", q=786, name="Thwarting Kolkar Aggression", z=14, x=54.44, y=74.35, target={kind="npc", id=3140, name="Lar Prowltusk"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 314
  {t="T", q=805, name="Report to Sen'jin Village", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 315
  {t="A", q=808, name="Minshina's Skull", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 316
  {t="A", q=823, name="Report to Orgnil", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 317
  {t="A", q=818, name="A Solvent Spirit", z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 318
  {t="A", q=817, name="Practical Prey", z=14, x=55.96, y=73.93, target={kind="npc", id=3194, name="Vel'rin Fang"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 319
  {t="A", q=96821, name="Legging It", foreverOnly=true, z=14, x=55.96, y=73.93, target={kind="npc", id=3194, name="Vel'rin Fang"}, note="Vel'rin Fang", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 320
  {t="A", q=97223, name="Bloodtalon Matriarch", foreverOnly=true, z=14, x=55.28, y=75.49, target={kind="npc", id=7953, name="Xar'Ti"}, note="Xar'Ti", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 321
  {t="A", q=97225, name="Forgotten Loa Idols", foreverOnly=true, z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, note="Master Vornal", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 322
  {t="C", q=786, name="Thwarting Kolkar Aggression", z=14, x=46.23, y=78.94, note="Burn the 3 attack plans at Kolkar Crag (west)", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 323
  {t="G", z=14, x=46.29, y=78.71, text="Pal'juh, held at Kolkar Crag", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 324
  {t="A", q=99123, name="Lost in the Shadows", foreverOnly=true, z=14, x=46.29, y=78.71, target={kind="npc", id=275811, name="Pal'juh"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 325
  {t="C", q=99123, name="Lost in the Shadows", foreverOnly=true, z=14, x=46.29, y=78.71, note="Help Pal'juh escape", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 326
  {t="C", q=818, name="A Solvent Spirit", z=14, x=61.06, y=72.51, note="Makrura and crawlers along the coast east of Sen'jin", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 327
  {t="C", q=817, name="Practical Prey", z=14, x=64.64, y=84.97, note="Durotar Tigers south of Sen'jin", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 328
  {t="C", q=96821, name="Legging It", foreverOnly=true, z=14, x=51.32, y=55.99, note="Ridgeshade Creepers and Lurkers in southern Durotar", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 329
  {t="C", q=97223, name="Bloodtalon Matriarch", foreverOnly=true, z=14, x=68.39, y=71.78, note="The Bloodtalon Matriarch's eggs", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 330
  {t="T", q=818, name="A Solvent Spirit", z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 331
  {t="T", q=817, name="Practical Prey", z=14, x=55.96, y=73.93, target={kind="npc", id=3194, name="Vel'rin Fang"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 332
  {t="T", q=786, name="Thwarting Kolkar Aggression", z=14, x=54.44, y=74.35, target={kind="npc", id=3140, name="Lar Prowltusk"}, races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 333
  {t="T", q=99123, name="Lost in the Shadows", foreverOnly=true, z=14, x=55.94, y=74.39, target={kind="npc", id=3304, name="Master Vornal"}, note="Master Vornal", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 334
  {t="T", q=97223, name="Bloodtalon Matriarch", foreverOnly=true, z=14, x=55.28, y=75.49, target={kind="npc", id=7953, name="Xar'Ti"}, note="Xar'Ti", races={"orc", "troll"}, section="Sen'jin Village", zoneName="Durotar"}, -- 335
  {t="G", z=14, x=51.5, y=41.6, text="Razor Hill inn", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 336
  {t="T", q=2161, name="A Peon's Burden", z=14, x=51.51, y=41.64, target={kind="npc", id=6928, name="Innkeeper Grosk"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 337
  {t="SH", z=14, x=51.5, y=41.6, text="Razor Hill", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 338
  {t="T", q=823, name="Report to Orgnil", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 339
  {t="A", q=806, name="Dark Storms", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 340
  {t="A", q=784, name="Vanquish the Betrayers", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 341
  {t="A", q=815, name="Break a Few Eggs", z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 342
  {t="A", q=791, name="Carry Your Weight", z=14, x=49.88, y=40.39, target={kind="npc", id=3147, name="Furl Scornbrow"}, races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 343
  {t="T", q=96821, name="Legging It", foreverOnly=true, z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, note="Gar'Thok", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 344
  {t="A", q=96822, name="For Honor", foreverOnly=true, z=14, x=53.97, y=42.55, target={kind="npc", id=266940, name="Turroc"}, note="Turroc", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 345
  {t="A", q=96825, name="This Fruit Could Bite Back", foreverOnly=true, z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, note="Cook Torka", races={"orc", "troll"}, section="Razor Hill", zoneName="Durotar"}, -- 346
  {t="TR", text="Train level 6 spells", races={"orc", "troll"}, section="Razor Hill"}, -- 347
  {t="C", q=784, name="Vanquish the Betrayers", z=14, x=58.19, y=56.79, note="Kill sailors/marines on the way in, Lieutenant Benedict upstairs", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 348
  {t="A", q=830, name="The Admiral's Orders", z=14, x=59.26, y=57.65, target={kind="item", id=4881, name="Aged Envelope"}, note="The Aged Envelope can drop or sits in Benedict's chest", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 349
  {t="C", q=791, name="Carry Your Weight", z=14, x=57.38, y=58.22, note="Canvas Scraps from the Kul Tiras sailors", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 350
  {t="C", q=96822, name="For Honor", foreverOnly=true, z=14, x=57.4, y=56.4, note="The Raider's Battleaxe, Bow and Shield around the Tiragarde Keep outskirts", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 351
  {t="C", q=815, name="Break a Few Eggs", z=14, x=68.01, y=80.41, note="Taillasher Eggs on the shore south of Tiragarde", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 352
  {t="G", z=14, x=56.0, y=74.7, text="Back to Sen'jin for the Echo Isles quests", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 353
  {t="A", q=826, name="Zalazane", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 354
  {t="C", q=808, name="Minshina's Skull", z=14, x=67.45, y=87.81, note="Minshina's Skull, on the Echo Isles", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 355
  {t="C", q=826, name="Zalazane", z=14, x=67.14, y=84.99, note="Zalazane, Echo Isles (group up if you can)", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 356
  {t="C", q=97225, name="Forgotten Loa Idols", foreverOnly=true, z=14, x=67.1, y=83.5, note="Forgotten Loa Idols on the Echo Isles", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 357
  {t="T", q=808, name="Minshina's Skull", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 358
  {t="T", q=826, name="Zalazane", z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 359
  {t="T", q=97225, name="Forgotten Loa Idols", foreverOnly=true, z=14, x=55.95, y=74.72, target={kind="npc", id=3188, name="Master Gadrin"}, note="Master Gadrin", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 360
  {t="H", text="Razor Hill", races={"orc", "troll"}, section="Tiragarde Keep and the coast"}, -- 361
  {t="T", q=784, name="Vanquish the Betrayers", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 362
  {t="T", q=830, name="The Admiral's Orders", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 363
  {t="A", q=825, name="From The Wreckage....", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 364
  {t="T", q=791, name="Carry Your Weight", z=14, x=49.88, y=40.39, target={kind="npc", id=3147, name="Furl Scornbrow"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 365
  {t="T", q=815, name="Break a Few Eggs", z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 366
  {t="T", q=96822, name="For Honor", foreverOnly=true, z=14, x=53.97, y=42.55, target={kind="npc", id=266940, name="Turroc"}, note="Turroc", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 367
  {t="C", q=825, name="From The Wreckage....", z=14, x=63.81, y=53.01, note="Gnomish Tools in the wreckage on the coast east of Razor Hill", races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 368
  {t="T", q=825, name="From The Wreckage....", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Tiragarde Keep and the coast", zoneName="Durotar"}, -- 369
  {t="A", q=837, name="Encroachment", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 370
  {t="C", q=837, name="Encroachment", z=14, x=44.4, y=48.8, note="Razormane quilboar west of Razor Hill", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 371
  {t="C", q=96825, name="This Fruit Could Bite Back", foreverOnly=true, z=14, x=47.1, y=49.9, note="Prickly Pear Fruit in the Razormane Grounds", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 372
  {t="T", q=837, name="Encroachment", z=14, x=51.95, y=43.5, target={kind="npc", id=3139, name="Gar'Thok"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 373
  {t="T", q=96825, name="This Fruit Could Bite Back", foreverOnly=true, z=14, x=51.11, y=42.45, target={kind="npc", id=3191, name="Cook Torka"}, note="Cook Torka", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 374
  {t="G", z=14, x=43.1, y=30.2, text="Misha Tor'kren's farmstead", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 375
  {t="A", q=816, name="Lost But Not Forgotten", z=14, x=43.1, y=30.24, target={kind="npc", id=3193, name="Misha Tor'kren"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 376
  {t="C", q=806, name="Dark Storms", z=14, x=42.12, y=26.66, note="Fizzle Darkstorm at Thunder Ridge", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 377
  {t="G", z=14, x=46.4, y=22.9, text="Rezlak, near the Orgrimmar gate", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 378
  {t="A", q=834, name="Winds in the Desert", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 379
  {t="C", q=834, name="Winds in the Desert", z=14, x=50.53, y=27.32, note="Sacks of Supplies at Drygulch Ravine", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 380
  {t="T", q=834, name="Winds in the Desert", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 381
  {t="A", q=835, name="Securing the Lines", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 382
  {t="C", q=835, name="Securing the Lines", z=14, x=51.87, y=23.53, note="Dustwind harpies in Drygulch Ravine", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 383
  {t="T", q=835, name="Securing the Lines", z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 384
  {t="A", q=97282, name="Stormy Potential", foreverOnly=true, z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 385
  {t="C", q=97282, name="Stormy Potential", foreverOnly=true, z=14, x=39.24, y=26.6, note="Charged Thunder Lizard Organs from the thunder lizards", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 386
  {t="T", q=97282, name="Stormy Potential", foreverOnly=true, z=14, x=46.37, y=22.94, target={kind="npc", id=3293, name="Rezlak"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 387
  {t="C", q=816, name="Lost But Not Forgotten", z=14, x=34.33, y=48.13, note="Kron's fate: look for the sign at the waypoint", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 388
  {t="T", q=816, name="Lost But Not Forgotten", z=14, x=43.1, y=30.24, target={kind="npc", id=3193, name="Misha Tor'kren"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 389
  {t="G", z=14, x=52.2, y=43.1, text="Back to Razor Hill (hearth if it is off cooldown)", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 390
  {t="T", q=806, name="Dark Storms", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 391
  {t="A", q=99048, name="A Missing Hand", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, note="Orgnil Soulscar", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 392
  {t="T", q=99048, name="A Missing Hand", foreverOnly=true, z=14, x=58.61, y=45.67, target={kind="npc", id=275657, name="Heglan Shadeeye"}, note="Heglan Shadeeye, north of Tiragarde Keep", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 393
  {t="A", q=99049, name="Threat from Below", foreverOnly=true, z=14, x=58.61, y=45.67, target={kind="npc", id=275657, name="Heglan Shadeeye"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 394
  {t="C", q=99049, name="Threat from Below", foreverOnly=true, z=14, x=60.1, y=44.8, note="Search around Heglan for signs of the attackers", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 395
  {t="T", q=99049, name="Threat from Below", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, note="Orgnil Soulscar", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 396
  {t="A", q=99051, name="Threat from Below", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 397
  {t="C", q=99051, name="Threat from Below", foreverOnly=true, z=14, x=58.94, y=27.53, note="Naga Spinefins from the naga on the coast", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 398
  {t="T", q=99051, name="Threat from Below", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 399
  {t="A", q=99052, name="Threat from Below", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 400
  {t="C", q=99052, name="Threat from Below", foreverOnly=true, z=14, x=58.6, y=16.34, note="The sea giant on Durotar's north coast", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 401
  {t="T", q=99052, name="Threat from Below", foreverOnly=true, z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 402
  {t="A", q=828, name="Margoz", z=14, x=52.24, y=43.15, target={kind="npc", id=3142, name="Orgnil Soulscar"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 403
  {t="A", q=840, name="Conscript of the Horde", z=14, x=50.84, y=43.59, target={kind="npc", id=3336, name="Takrin Pathseeker"}, note="Takrin Pathseeker at the Razor Hill flight tower", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 404
  {t="G", z=14, x=56.4, y=20.0, text="Margoz's hut, north", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 405
  {t="T", q=828, name="Margoz", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 406
  {t="A", q=827, name="Skull Rock", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 407
  {t="C", q=827, name="Skull Rock", z=14, x=52.7, y=11.04, note="Searing Collars from Burning Blade cultists in Skull Rock", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 408
  {t="A", q=832, name="Burning Shadows", z=14, x=52.61, y=8.82, target={kind="item", id=4903, name="Eye of Burning Shadow"}, note="Eye of Burning Shadow drops in Skull Rock", races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 409
  {t="T", q=827, name="Skull Rock", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 410
  {t="A", q=829, name="Neeru Fireblade", z=14, x=56.41, y=20.04, target={kind="npc", id=3208, name="Margoz"}, races={"orc", "troll"}, section="Northern Durotar", zoneName="Durotar"}, -- 411
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 412
  {t="T", q=829, name="Neeru Fireblade", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 413
  {t="T", q=832, name="Burning Shadows", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 414
  {t="A", q=809, name="Ak'Zeloth", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 415
  {t="G", z=1637, x=55.59, y=72.1, text="Thatog in the Valley of Strength", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 416
  {t="A", q=97246, name="Meal Appeal", foreverOnly=true, z=1637, x=55.69, y=72.08, target={kind="npc", id=268701, name="Thatog"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 417
  {t="T", q=97246, name="Meal Appeal", foreverOnly=true, z=1637, x=57.2, y=53.32, target={kind="npc", id=3368, name="Borstan"}, note="Borstan", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 418
  {t="A", q=97249, name="Favorite Food", foreverOnly=true, z=1637, x=57.2, y=53.32, target={kind="npc", id=3368, name="Borstan"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 419
  {t="T", q=97249, name="Favorite Food", foreverOnly=true, z=1637, x=36.77, y=29.08, target={kind="npc", id=268682, name="Migi"}, note="Migi, behind Grommash Hold", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 420
  {t="G", z=1637, x=34.87, y=29.0, text="Thra, behind Grommash Hold", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 421
  {t="A", q=97326, name="Rocks to Rests", foreverOnly=true, z=1637, x=37, y=28.81, target={kind="npc", id=268684, name="Thra"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 422
  {t="C", q=97326, name="Rocks to Rests", foreverOnly=true, z=1637, x=43.7, y=32.7, note="Smooth Boulders behind Grommash Hold", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 423
  {t="T", q=97326, name="Rocks to Rests", foreverOnly=true, z=1637, x=37, y=28.81, target={kind="npc", id=268684, name="Thra"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 424
  {t="G", z=1637, x=56.84, y=33.03, text="Yelmak in the Valley of Spirits", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 425
  {t="A", q=97275, name="Whuut's the Rush", foreverOnly=true, z=1637, x=56.84, y=33.03, target={kind="npc", id=3347, name="Yelmak"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 426
  {t="T", q=97275, name="Whuut's the Rush", foreverOnly=true, z=1637, x=55.79, y=32.9, target={kind="npc", id=11046, name="Whuut"}, note="Whuut", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 427
  {t="A", q=97242, name="Yelmak's Medley", foreverOnly=true, z=1637, x=56.05, y=34.12, target={kind="npc", id=3348, name="Kor'geld"}, note="Kor'geld", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 428
  {t="C", q=97242, name="Yelmak's Medley", foreverOnly=true, z=1637, x=70.4, y=29.9, note="Cattails and Speargrass in the Valley of Honor", races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 429
  {t="T", q=97242, name="Yelmak's Medley", foreverOnly=true, z=1637, x=56.05, y=34.12, target={kind="npc", id=3348, name="Kor'geld"}, races={"orc", "troll"}, section="Orgrimmar", zoneName="Orgrimmar"}, -- 430
  {t="TR", text="Train level 10/12 spells; Hunters: start the pet quests at level 10", races={"orc", "troll"}, section="Orgrimmar"}, -- 431
  {t="A", q=747, name="The Hunt Begins", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 432
  {t="A", q=752, name="A Humble Task", z=215, x=43.89, y=76.66, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 433
  {t="C", q=747, name="The Hunt Begins", z=215, x=47.2, y=81.46, note="Plainstriders around the camp", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 434
  {t="T", q=752, name="A Humble Task", z=215, x=48.77, y=80.92, target={kind="npc", id=2991, name="Greatmother Hawkwind"}, note="Greatmother Hawkwind by the well", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 435
  {t="A", q=753, name="A Humble Task", z=215, x=48.77, y=80.92, target={kind="npc", id=2991, name="Greatmother Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 436
  {t="C", q=753, name="A Humble Task", z=215, x=48.93, y=81.1, note="Fill the pitcher at the well next to her", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 437
  {t="T", q=753, name="A Humble Task", z=215, x=43.89, y=76.66, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 438
  {t="A", q=755, name="Rites of the Earthmother", z=215, x=43.89, y=76.66, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 439
  {t="T", q=747, name="The Hunt Begins", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 440
  {t="A", q=750, name="The Hunt Continues", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 441
  {t="A", q=3376, name="Break Sharptusk!", z=215, x=44.18, y=77.03, target={kind="npc", id=3209, name="Brave Windfeather"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 442
  {t="C", q=750, name="The Hunt Continues", z=215, x=47.51, y=88.11, note="Mountain Cougars in the hills", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 443
  {t="T", q=755, name="Rites of the Earthmother", z=215, x=42.54, y=90.13, target={kind="npc", id=2982, name="Seer Graytongue"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 444
  {t="A", q=95805, name="Grace of An'she and Mu'sha", foreverOnly=true, z=215, x=42.54, y=90.13, target={kind="npc", id=2982, name="Seer Graytongue"}, note="Seer Graytongue", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 445
  {t="T", q=95805, name="Grace of An'she and Mu'sha", foreverOnly=true, z=215, x=56.57, y=88.69, target={kind="object", id=660739, name="Ritual Fire"}, note="Carry the incense to the shrine in the south-eastern hills before it burns out", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 446
  {t="A", q=757, name="Rite of Strength", z=215, x=42.54, y=90.13, target={kind="npc", id=2982, name="Seer Graytongue"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 447
  {t="C", q=757, name="Rite of Strength", z=215, x=58.41, y=78.63, note="Bristleback quilboar in Brambleblade Ravine", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 448
  {t="C", q=3376, name="Break Sharptusk!", z=215, x=61.02, y=78, note="Chief Sharptusk Thornmantle, back of the ravine", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 449
  {t="T", q=750, name="The Hunt Continues", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 450
  {t="A", q=780, name="The Battleboars", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 451
  {t="C", q=780, name="The Battleboars", z=215, x=54.21, y=81.59, note="Battleboars", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 452
  {t="T", q=780, name="The Battleboars", z=215, x=44.47, y=77.5, target={kind="npc", id=2980, name="Grull Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 453
  {t="T", q=757, name="Rite of Strength", z=215, x=43.89, y=76.66, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 454
  {t="T", q=3376, name="Break Sharptusk!", z=215, x=44.18, y=77.03, target={kind="npc", id=3209, name="Brave Windfeather"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 455
  {t="A", q=763, name="Rites of the Earthmother", z=215, x=43.89, y=76.66, target={kind="npc", id=2981, name="Chief Hawkwind"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 456
  {t="TR", text="Train your level 4 spells", races={"tauren"}, section="Camp Narache (Tauren)"}, -- 457
  {t="G", z=215, x=39.15, y=81.2, text="Antur Fallow, on the way out of camp", races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 458
  {t="A", q=1656, name="A Task Unfinished", z=215, x=39.16, y=81.24, target={kind="npc", id=6775, name="Antur Fallow"}, races={"tauren"}, section="Camp Narache (Tauren)", zoneName="Mulgore"}, -- 459
  {t="G", z=215, x=46.66, y=63.42, text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 460
  {t="T", q=763, name="Rites of the Earthmother", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 461
  {t="A", q=767, name="Rite of Vision", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 462
  {t="T", q=1656, name="A Task Unfinished", z=215, x=45.93, y=64.16, target={kind="npc", id=6747, name="Innkeeper Kauth"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 463
  {t="SH", z=215, x=45.91, y=64.17, text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 464
  {t="A", q=745, name="Sharing the Land", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 465
  {t="A", q=761, name="Swoop Hunting", z=215, x=47.67, y=62.68, target={kind="npc", id=2947, name="Harken Windtotem"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 466
  {t="A", q=748, name="Poison Water", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 467
  {t="T", q=767, name="Rite of Vision", z=215, x=46.88, y=61.19, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 468
  {t="A", q=771, name="Rite of Vision", z=215, x=46.88, y=61.19, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 469
  {t="C", q=771, name="Rite of Vision", z=215, x=48.15, y=60.07, note="Well Stones and Ambercorn around the village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 470
  {t="T", q=771, name="Rite of Vision", z=215, x=46.88, y=61.19, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 471
  {t="A", q=772, name="Rite of Vision", z=215, x=46.88, y=61.19, target={kind="npc", id=3054, name="Zarlman Two-Moons"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 472
  {t="C", q=748, name="Poison Water", z=215, x=42.87, y=59.08, note="Prairie Wolf Paws and Plainstrider Talons", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 473
  {t="T", q=748, name="Poison Water", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 474
  {t="A", q=754, name="Winterhoof Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 475
  {t="G", z=215, x=51.84, y=68.51, text="Winterhoof Water Well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 476
  {t="C", q=754, name="Winterhoof Cleansing", z=215, x=51.76, y=68.43, note="Use the Winterhoof Cleansing Totem at the well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 477
  {t="T", q=754, name="Winterhoof Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 478
  {t="A", q=756, name="Thunderhorn Totem", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 479
  {t="A", q=743, name="Dangers of the Windfury", z=215, x=46.54, y=64.94, target={kind="npc", id=2985, name="Ruul Eagletalon"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 480
  {t="A", q=766, name="Mazzranache", z=215, x=46.23, y=60.8, target={kind="npc", id=3055, name="Maur Raincaller"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 481
  {t="A", q=746, name="Dwarven Digging", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 482
  {t="A", q=99080, name="Drive Them Out", foreverOnly=true, z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, note="Baine Bloodhoof", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 483
  {t="A", q=99079, name="Longwalker Malah", foreverOnly=true, z=215, x=46.68, y=63.83, target={kind="npc", id=3222, name="Brave Wildrunner"}, note="Brave Wildrunner", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 484
  {t="A", q=96130, name="Chakuyak", foreverOnly=true, z=215, x=46.93, y=59.65, target={kind="npc", id=3065, name="Yaw Sharpmane"}, note="Yaw Sharpmane", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 485
  {t="A", q=98435, name="Thunderhorn's Report", foreverOnly=true, z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, note="Mull Thunderhorn", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 486
  {t="G", z=215, x=54.76, y=64.25, text="Morin Cloudstalker, east of the village", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 487
  {t="A", q=749, name="The Ravaged Caravan", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 488
  {t="T", q=99079, name="Longwalker Malah", foreverOnly=true, z=215, x=57.57, y=63.18, target={kind="npc", id=275789, name="Malah Longwind"}, note="Longwalker Malah Longwind, east edge of Mulgore", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 489
  {t="A", q=99081, name="Grim Tidings", foreverOnly=true, z=215, x=57.57, y=63.18, target={kind="npc", id=275789, name="Malah Longwind"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 490
  {t="C", q=743, name="Dangers of the Windfury", z=215, x=59.55, y=72.03, note="Windfury harpies at Windfury Ridge", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 491
  {t="C", q=745, name="Sharing the Land", z=215, x=36.69, y=65.29, note="Palemane gnolls", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 492
  {t="G", z=215, x=33.1, y=65.93, text="Perith Stormhoof at Palemane Rock", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 493
  {t="A", q=98430, name="The Longwalkers", foreverOnly=true, z=215, x=33.1, y=65.93, target={kind="npc", id=272203, name="Perith Stormhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 494
  {t="C", q=98430, name="The Longwalkers", foreverOnly=true, z=215, x=37.19, y=64.62, note="Help Perith escape Palemane Rock", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 495
  {t="C", q=99080, name="Drive Them Out", foreverOnly=true, z=215, x=62.81, y=60.75, note="Galak Centaurs, Outrunners and Herak the Pillager", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 496
  {t="C", q=96130, name="Chakuyak", foreverOnly=true, z=215, x=39.06, y=66.17, note="Chakuyak", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 497
  {t="C", q=746, name="Dwarven Digging", z=215, x=33.44, y=53.97, note="Prospector's Picks from Bael'dun dwarves at the dig site", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 498
  {t="T", q=745, name="Sharing the Land", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 499
  {t="T", q=746, name="Dwarven Digging", z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 500
  {t="T", q=743, name="Dangers of the Windfury", z=215, x=46.54, y=64.94, target={kind="npc", id=2985, name="Ruul Eagletalon"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 501
  {t="T", q=99080, name="Drive Them Out", foreverOnly=true, z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 502
  {t="T", q=96130, name="Chakuyak", foreverOnly=true, z=215, x=46.93, y=59.65, target={kind="npc", id=3065, name="Yaw Sharpmane"}, note="Yaw Sharpmane", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 503
  {t="T", q=99081, name="Grim Tidings", foreverOnly=true, z=215, x=46.68, y=63.83, target={kind="npc", id=3222, name="Brave Wildrunner"}, note="Brave Wildrunner", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 504
  {t="A", q=99101, name="Our Ancient Enemy", foreverOnly=true, z=215, x=46.68, y=63.83, target={kind="npc", id=3222, name="Brave Wildrunner"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 505
  {t="T", q=99101, name="Our Ancient Enemy", foreverOnly=true, z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, note="Baine Bloodhoof", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 506
  {t="A", q=99082, name="The High Chieftain", foreverOnly=true, z=215, x=46.67, y=63.38, target={kind="npc", id=2993, name="Baine Bloodhoof"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 507
  {t="C", q=756, name="Thunderhorn Totem", z=215, x=48.68, y=49.24, note="Stalker and Cougar Claws", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 508
  {t="T", q=756, name="Thunderhorn Totem", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 509
  {t="A", q=758, name="Thunderhorn Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 510
  {t="G", z=215, x=44.16, y=50.98, text="Thunderhorn water well, north of Bloodhoof", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 511
  {t="C", q=758, name="Thunderhorn Cleansing", z=215, x=44.17, y=51.11, note="Use the Thunderhorn Cleansing Totem at the well", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 512
  {t="T", q=758, name="Thunderhorn Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 513
  {t="A", q=759, name="Wildmane Totem", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 514
  {t="C", q=749, name="The Ravaged Caravan", z=215, x=47.52, y=63.58, note="The sealed crate at the ravaged caravan", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 515
  {t="T", q=749, name="The Ravaged Caravan", z=215, x=51.87, y=53.37, target={kind="object", id=2908, name="Sealed Supply Crate"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 516
  {t="A", q=751, name="The Ravaged Caravan", z=215, x=51.87, y=53.37, target={kind="object", id=2908, name="Sealed Supply Crate"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 517
  {t="C", q=761, name="Swoop Hunting", z=215, x=47.59, y=49.98, note="Swoops for Trophy Swoop Quills", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 518
  {t="C", q=766, name="Mazzranache", z=215, x=46.88, y=52.33, note="Mazzranache drops the last part; others drop from wolves, cougars, plainstriders, swoops", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 519
  {t="T", q=761, name="Swoop Hunting", z=215, x=47.67, y=62.68, target={kind="npc", id=2947, name="Harken Windtotem"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 520
  {t="T", q=766, name="Mazzranache", z=215, x=46.23, y=60.8, target={kind="npc", id=3055, name="Maur Raincaller"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 521
  {t="T", q=751, name="The Ravaged Caravan", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 522
  {t="A", q=764, name="The Venture Co.", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 523
  {t="A", q=765, name="Supervisor Fizsprocket", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 524
  {t="A", q=98427, name="Ceasing Operations", foreverOnly=true, z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 525
  {t="C", q=764, name="The Venture Co.", z=215, x=59.02, y=47.26, note="Venture Co. at the Venture Co. mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 526
  {t="C", q=765, name="Supervisor Fizsprocket", z=215, x=61.19, y=49.32, note="Supervisor Fizsprocket, deep in the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 527
  {t="C", q=98427, name="Ceasing Operations", foreverOnly=true, z=215, x=56.79, y=43.23, note="The Clearcutter Key", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 528
  {t="A", q=98424, name="Fizsprocket's Notes", foreverOnly=true, z=215, x=61.19, y=49.32, target={kind="item", id=281031, name="Mulgore Expansion Plans"}, note="Mulgore Expansion Plans drop in the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 529
  {t="C", q=98424, name="Fizsprocket's Notes", foreverOnly=true, z=215, x=61.19, y=49.32, note="The rest of Fizsprocket's pages in the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 530
  {t="C", q=759, name="Wildmane Totem", z=215, x=54.41, y=36.89, note="Prairie Alpha Teeth from prairie wolf alphas north of the mine", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 531
  {t="G", z=215, x=54.76, y=64.25, text="Morin Cloudstalker", races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 532
  {t="T", q=764, name="The Venture Co.", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 533
  {t="T", q=765, name="Supervisor Fizsprocket", z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 534
  {t="T", q=98427, name="Ceasing Operations", foreverOnly=true, z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 535
  {t="T", q=98424, name="Fizsprocket's Notes", foreverOnly=true, z=215, x=54.76, y=64.27, target={kind="npc", id=2988, name="Morin Cloudstalker"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 536
  {t="H", text="Bloodhoof Village", races={"tauren"}, section="Bloodhoof Village"}, -- 537
  {t="T", q=759, name="Wildmane Totem", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 538
  {t="A", q=760, name="Wildmane Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 539
  {t="A", q=861, name="The Hunter's Way", z=215, x=46.03, y=63.44, target={kind="npc", id=3052, name="Skorn Whitecloud"}, races={"tauren"}, section="Bloodhoof Village", zoneName="Mulgore"}, -- 540
  {t="N", text="Drink the Water of the Seers by the tribal fire in Bloodhoof, then follow the spirit wolf", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 541
  {t="T", q=772, name="Rite of Vision", z=215, x=34.31, y=43.29, target={kind="npc", id=2984, name="Seer Wiserunner"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 542
  {t="A", q=773, name="Rite of Wisdom", z=215, x=34.31, y=43.29, target={kind="npc", id=2984, name="Seer Wiserunner"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 543
  {t="G", z=215, x=42.74, y=24.84, text="Wildmane water pump", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 544
  {t="C", q=760, name="Wildmane Cleansing", z=215, x=42.7, y=24.98, note="Use the Wildmane Cleansing Totem at the pump", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 545
  {t="C", q=861, name="The Hunter's Way", z=215, x=48.56, y=28.22, note="Flatland Prowlers for claws", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 546
  {t="G", z=215, x=57.01, y=34.53, text="Lorekeeper Raintotem at Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 547
  {t="A", q=833, name="A Sacred Burial", z=215, x=56.98, y=34.55, target={kind="npc", id=3233, name="Lorekeeper Raintotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 548
  {t="C", q=833, name="A Sacred Burial", z=215, x=57.96, y=30.92, note="Bristleback Interlopers at Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 549
  {t="T", q=833, name="A Sacred Burial", z=215, x=56.98, y=34.55, target={kind="npc", id=3233, name="Lorekeeper Raintotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 550
  {t="T", q=773, name="Rite of Wisdom", z=215, x=58.31, y=30.7, target={kind="npc", id=2994, name="Ancestral Spirit"}, note="The Ancestral Spirit at the top of Red Rocks", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 551
  {t="A", q=775, name="Journey into Thunder Bluff", z=215, x=58.31, y=30.7, target={kind="npc", id=2994, name="Ancestral Spirit"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 552
  {t="G", z=1638, x=60.3, y=51.7, text="Thunder Bluff, Cairne on the high rise", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 553
  {t="T", q=775, name="Journey into Thunder Bluff", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 554
  {t="A", q=776, name="Rites of the Earthmother", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 555
  {t="T", q=99082, name="The High Chieftain", foreverOnly=true, z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, note="Cairne Bloodhoof", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 556
  {t="T", q=98430, name="The Longwalkers", foreverOnly=true, z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, note="Cairne Bloodhoof", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 557
  {t="G", z=1638, x=78.62, y=28.56, text="Arch Druid Hamuul Runetotem on Elder Rise", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 558
  {t="T", q=98435, name="Thunderhorn's Report", foreverOnly=true, z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 559
  {t="FP", z=1638, x=47.0, y=49.8, text="Thunder Bluff flight path", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 560
  {t="T", q=861, name="The Hunter's Way", z=1638, x=61.54, y=80.92, target={kind="npc", id=3441, name="Melor Stonehoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 561
  {t="A", q=860, name="Sergra Darkthorn", z=1638, x=61.54, y=80.92, target={kind="npc", id=3441, name="Melor Stonehoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 562
  {t="A", q=886, name="The Barrens Oases", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 563
  {t="G", z=1638, x=70.1, y=29.5, text="Rahauro on Elder Rise (Ragefire Chasm quests for later)", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 564
  {t="A", q=5723, name="Testing an Enemy's Strength", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 565
  {t="A", q=5722, name="Searching for the Lost Satchel", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 566
  {t="TR", text="Train level 10 spells in Thunder Bluff", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 567
  {t="C", q=776, name="Rites of the Earthmother", z=215, x=51.25, y=24.82, note="Arra'chea, the big kodo in northern Mulgore", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 568
  {t="T", q=776, name="Rites of the Earthmother", z=1638, x=60.3, y=51.68, target={kind="npc", id=3057, name="Cairne Bloodhoof"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Thunder Bluff"}, -- 569
  {t="G", z=215, x=47.5, y=63.58, text="Back to Mull Thunderhorn in Bloodhoof (hearth may still be on cooldown)", races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 570
  {t="T", q=760, name="Wildmane Cleansing", z=215, x=47.52, y=63.58, target={kind="npc", id=2948, name="Mull Thunderhorn"}, races={"tauren"}, section="Northern Mulgore and Thunder Bluff", zoneName="Mulgore"}, -- 571
  {t="N", text="Run east out of Mulgore into The Barrens", races={"tauren"}, section="Northern Mulgore and Thunder Bluff"}, -- 572
  {t="A", q=363, name="Rude Awakening", z=85, x=30.22, y=71.65, target={kind="npc", id=1568, name="Undertaker Mordo"}, note="Undertaker Mordo, right in front of you", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 573
  {t="T", q=363, name="Rude Awakening", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 574
  {t="A", q=364, name="The Mindless Ones", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 575
  {t="C", q=364, name="The Mindless Ones", z=85, x=32.87, y=63.55, note="Mindless Zombies and Wretched Zombies", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 576
  {t="T", q=364, name="The Mindless Ones", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 577
  {t="A", q=3901, name="Rattling the Rattlecages", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 578
  {t="A", q=376, name="The Damned", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 579
  {t="C", q=376, name="The Damned", z=85, x=34.56, y=62.55, note="Scavenger Paws from young scavengers, Duskbat Wings from duskbats", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 580
  {t="T", q=376, name="The Damned", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 581
  {t="A", q=380, name="Night Web's Hollow", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 582
  {t="A", q=98389, name="A Light in the Darkness", foreverOnly=true, z=85, x=31.09, y=66.32, target={kind="npc", id=244808, name="Aramis Hammerhand"}, note="Aramis Hammerhand", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 583
  {t="A", q=3902, name="Scavenging Deathknell", z=85, x=31.61, y=65.6, target={kind="npc", id=1740, name="Deathguard Saltain"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 584
  {t="A", q=6395, name="Marla's Last Wish", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 585
  {t="TR", text="Train your level 2 spells", races={"undead"}, section="Deathknell (Undead)"}, -- 586
  {t="C", q=3901, name="Rattling the Rattlecages", z=85, x=32.91, y=61.62, note="Rattlecage Skeletons", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 587
  {t="C", q=3902, name="Scavenging Deathknell", z=85, x=32.87, y=64.6, note="Scavenged Goods are small piles around Deathknell", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 588
  {t="C", q=6395, name="Marla's Last Wish", z=85, x=31.17, y=65.08, note="Samuel Fipps drops his remains; then use them at Marla's Grave", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 589
  {t="T", q=3901, name="Rattling the Rattlecages", z=85, x=30.84, y=66.2, target={kind="npc", id=1569, name="Shadow Priest Sarvis"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 590
  {t="T", q=3902, name="Scavenging Deathknell", z=85, x=31.61, y=65.6, target={kind="npc", id=1740, name="Deathguard Saltain"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 591
  {t="T", q=6395, name="Marla's Last Wish", z=85, x=30.86, y=66.05, target={kind="npc", id=1661, name="Novice Elreth"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 592
  {t="C", q=380, name="Night Web's Hollow", z=85, x=27.1, y=59.18, note="Night Web's Hollow, the spider cave", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 593
  {t="C", q=98389, name="A Light in the Darkness", foreverOnly=true, z=85, x=27.1, y=59.18, note="Free the webbed victims in Night Web's Hollow", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 594
  {t="T", q=98389, name="A Light in the Darkness", foreverOnly=true, z=85, x=31.09, y=66.32, target={kind="npc", id=244808, name="Aramis Hammerhand"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 595
  {t="T", q=380, name="Night Web's Hollow", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 596
  {t="A", q=381, name="The Scarlet Crusade", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 597
  {t="C", q=381, name="The Scarlet Crusade", z=85, x=37.58, y=67.98, note="Scarlet Converts and Initiates at Solliden Farmstead's edge", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 598
  {t="T", q=381, name="The Scarlet Crusade", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 599
  {t="A", q=382, name="The Red Messenger", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 600
  {t="C", q=382, name="The Red Messenger", z=85, x=36.57, y=68.54, note="Meven Korgal at the Scarlet camp", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 601
  {t="T", q=382, name="The Red Messenger", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 602
  {t="A", q=383, name="Vital Intelligence", z=85, x=32.15, y=66.01, target={kind="npc", id=1570, name="Executor Arren"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 603
  {t="TR", text="Train your level 4 spells", races={"undead"}, section="Deathknell (Undead)"}, -- 604
  {t="G", z=85, x=38.2, y=56.8, text="Calvin Montague, outside Deathknell", races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 605
  {t="A", q=8, name="A Rogue's Deal", z=85, x=38.23, y=56.79, target={kind="npc", id=6784, name="Calvin Montague"}, races={"undead"}, section="Deathknell (Undead)", zoneName="Tirisfal Glades"}, -- 606
  {t="G", z=85, x=40.9, y=54.2, text="Deathguard Simmer on the road to Brill", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 607
  {t="A", q=365, name="Fields of Grief", z=85, x=40.91, y=54.17, target={kind="npc", id=1519, name="Deathguard Simmer"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 608
  {t="G", z=85, x=43.1, y=54.7, text="Gordo, wandering the road", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 609
  {t="A", q=5481, name="Gordo's Task", z=85, x=43.06, y=54.69, target={kind="npc", id=10666, name="Gordo"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 610
  {t="C", q=365, name="Fields of Grief", z=85, x=35.86, y=50.49, note="Pumpkins in the farm field", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 611
  {t="C", q=5481, name="Gordo's Task", z=85, x=48.7, y=54.9, note="Gloom Weed grows along the road", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 612
  {t="G", z=85, x=61.7, y=52.0, text="Brill inn", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 613
  {t="T", q=8, name="A Rogue's Deal", z=85, x=61.72, y=52.05, target={kind="npc", id=5688, name="Innkeeper Renee"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 614
  {t="SH", z=85, x=61.7, y=52.0, text="Brill", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 615
  {t="T", q=383, name="Vital Intelligence", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 616
  {t="A", q=427, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 617
  {t="T", q=365, name="Fields of Grief", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 618
  {t="A", q=407, name="Fields of Grief", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 619
  {t="T", q=407, name="Fields of Grief", z=85, x=61.97, y=51.29, target={kind="npc", id=1931, name="Captured Scarlet Zealot"}, note="The Captured Scarlet Zealot in the town hall", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 620
  {t="A", q=404, name="A Putrid Task", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 621
  {t="A", q=358, name="Graverobbers", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 622
  {t="T", q=5481, name="Gordo's Task", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 623
  {t="A", q=5482, name="Doom Weed", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 624
  {t="A", q=99142, name="Tomb Weed", foreverOnly=true, z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, note="Junior Apothecary Holland", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 625
  {t="A", q=99141, name="Patience", foreverOnly=true, z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, note="Executor Zygand", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 626
  {t="A", q=86784, name="Sticks and Bones", foreverOnly=true, z=85, x=58.47, y=51.39, target={kind="npc", id=1742, name="Deathguard Bartholomew"}, note="Deathguard Bartholomew", races={"undead"}, section="Brill", zoneName="Tirisfal Glades"}, -- 627
  {t="TR", text="Train your level 6 spells", races={"undead"}, section="Brill"}, -- 628
  {t="C", q=404, name="A Putrid Task", z=85, x=53.32, y=54.14, note="Rotting Dead / ghouls for Putrid Claws", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 629
  {t="C", q=358, name="Graverobbers", z=85, x=57.59, y=39.38, note="Rot Hide Graverobbers and Mongrels", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 630
  {t="G", z=85, x=61.7, y=52.0, text="Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 631
  {t="T", q=404, name="A Putrid Task", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 632
  {t="A", q=426, name="The Mills Overrun", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 633
  {t="A", q=367, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 634
  {t="A", q=398, name="Wanted: Maggot Eye", z=85, x=60.74, y=51.5, target={kind="object", id=711, name="Wanted!"}, note="Wanted poster outside the town hall", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 635
  {t="A", q=362, name="The Haunted Mills", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 636
  {t="A", q=354, name="Deaths in the Family", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 637
  {t="C", q=367, name="A New Plague", z=85, x=63.33, y=50.83, note="Vials of Darkhound Blood from darkhounds", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 638
  {t="C", q=427, name="At War With The Scarlet Crusade", z=85, x=32.08, y=47.4, note="Scarlet Warriors at Solliden Farmstead", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 639
  {t="G", z=85, x=31.96, y=46.34, text="Bareth Dawnstone at the Crusader's Outpost", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 640
  {t="A", q=99144, name="Seeking Refuge", foreverOnly=true, z=85, x=31.96, y=46.34, target={kind="npc", id=275954, name="Bareth Dawnstone"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 641
  {t="C", q=99144, name="Seeking Refuge", foreverOnly=true, z=85, x=31.96, y=46.34, note="Help Bareth escape", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 642
  {t="C", q=5482, name="Doom Weed", z=85, x=57.14, y=39.77, note="Doom Weed at the graveyard north of Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 643
  {t="C", q=99142, name="Tomb Weed", foreverOnly=true, z=85, x=76.3, y=60.8, note="Tomb Weed near the graveyard", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 644
  {t="C", q=86784, name="Sticks and Bones", foreverOnly=true, z=85, x=56.1, y=53.4, note="Dry Branches", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 645
  {t="C", q=99141, name="Patience", foreverOnly=true, z=85, x=56.1, y=53.4, note="Get reports from Deathguard Dillinger, Deathguard Kristof and Gordo", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 646
  {t="C", q=398, name="Wanted: Maggot Eye", z=85, x=58.66, y=30.77, note="Maggot Eye in the cottage north of the graveyard", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 647
  {t="C", q=426, name="The Mills Overrun", z=85, x=45.36, y=39.61, note="Agamand Mills: Notched Ribs and Blackened Skulls from skeletons", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 648
  {t="C", q=362, name="The Haunted Mills", z=85, x=47.34, y=40.78, note="Devlin Agamand", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 649
  {t="C", q=354, name="Deaths in the Family", z=85, x=44, y=33.64, note="Gregor, Nissa and Thurman Agamand's remains", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 650
  {t="A", q=361, name="A Letter Undelivered", z=85, x=45.36, y=39.61, target={kind="item", id=2839, name="A Letter to Yvette"}, note="The letter for Yvette drops at the Mills", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 651
  {t="G", z=85, x=61.7, y=52.0, text="Back to Brill", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 652
  {t="T", q=358, name="Graverobbers", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 653
  {t="T", q=5482, name="Doom Weed", z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 654
  {t="T", q=427, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 655
  {t="T", q=99142, name="Tomb Weed", foreverOnly=true, z=85, x=57.44, y=48.85, target={kind="npc", id=10665, name="Junior Apothecary Holland"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 656
  {t="T", q=99141, name="Patience", foreverOnly=true, z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 657
  {t="T", q=86784, name="Sticks and Bones", foreverOnly=true, z=85, x=57.23, y=55.47, target={kind="npc", id=265812, name="Eleanor Shackleton"}, note="Eleanor Shackleton", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 658
  {t="T", q=99144, name="Seeking Refuge", foreverOnly=true, z=85, x=60.25, y=52.63, target={kind="npc", id=246152, name="Shari Stilwell"}, note="Shari Stilwell", races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 659
  {t="A", q=374, name="Proof of Demise", z=85, x=60.93, y=52.01, target={kind="npc", id=1652, name="Deathguard Burgess"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 660
  {t="A", q=375, name="The Chill of Death", z=85, x=61.89, y=52.73, target={kind="npc", id=1521, name="Gretchen Dedmar"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 661
  {t="N", text="Buy 1 Coarse Thread from the trade goods vendor for The Chill of Death", races={"undead"}, section="Around Brill"}, -- 662
  {t="T", q=367, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 663
  {t="T", q=398, name="Wanted: Maggot Eye", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 664
  {t="T", q=426, name="The Mills Overrun", z=85, x=58.2, y=51.45, target={kind="npc", id=1496, name="Deathguard Dillinger"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 665
  {t="T", q=362, name="The Haunted Mills", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 666
  {t="T", q=354, name="Deaths in the Family", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 667
  {t="T", q=361, name="A Letter Undelivered", z=85, x=61.58, y=52.6, target={kind="npc", id=1560, name="Yvette Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 668
  {t="A", q=359, name="Forsaken Duties", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 669
  {t="A", q=405, name="The Prodigal Lich", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 670
  {t="A", q=368, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 671
  {t="A", q=370, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 672
  {t="A", q=355, name="Speak with Sevren", z=85, x=61.72, y=52.29, target={kind="npc", id=1500, name="Coleman Farthing"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 673
  {t="T", q=355, name="Speak with Sevren", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 674
  {t="A", q=408, name="The Family Crypt", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Around Brill", zoneName="Tirisfal Glades"}, -- 675
  {t="TR", text="Train your level 8 spells", races={"undead"}, section="Around Brill"}, -- 676
  {t="T", q=359, name="Forsaken Duties", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, note="Deathguard Linnea at the eastern bulwark road", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 677
  {t="A", q=360, name="Return to the Magistrate", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 678
  {t="A", q=356, name="Rear Guard Patrol", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 679
  {t="A", q=99156, name="Rear Guard Patrol", foreverOnly=true, z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, note="Deathguard Linnea", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 680
  {t="A", q=97558, name="Hides for the Forsaken", foreverOnly=true, z=85, x=65.43, y=60.12, target={kind="npc", id=3549, name="Shelene Rhobart"}, note="Shelene Rhobart", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 681
  {t="C", q=356, name="Rear Guard Patrol", z=85, x=76.48, y=60.74, note="Bleeding Horrors and Wandering Spirits", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 682
  {t="C", q=370, name="At War With The Scarlet Crusade", z=85, x=53.66, y=66, note="Captain Perrine and Scarlet Zealots/Missionaries", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 683
  {t="C", q=368, name="A New Plague", z=85, x=16.62, y=52.88, note="Vile Fin murlocs for scales", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 684
  {t="C", q=374, name="Proof of Demise", z=85, x=43.23, y=65.17, note="Scarlet Insignia Rings from Scarlet humans", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 685
  {t="C", q=375, name="The Chill of Death", z=85, x=65.07, y=54.57, note="Duskbats for pelts", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 686
  {t="C", q=97558, name="Hides for the Forsaken", foreverOnly=true, z=85, x=62.91, y=47.94, note="Duskbat Wing Membranes, Darkhound Hides and Vile Fin Murloc Skins", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 687
  {t="C", q=99156, name="Rear Guard Patrol", foreverOnly=true, z=85, x=84.28, y=45.38, note="Riptear's Heart", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 688
  {t="T", q=356, name="Rear Guard Patrol", z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 689
  {t="T", q=99156, name="Rear Guard Patrol", foreverOnly=true, z=85, x=65.49, y=60.25, target={kind="npc", id=1495, name="Deathguard Linnea"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 690
  {t="T", q=97558, name="Hides for the Forsaken", foreverOnly=true, z=85, x=65.43, y=60.12, target={kind="npc", id=3549, name="Shelene Rhobart"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 691
  {t="T", q=360, name="Return to the Magistrate", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 692
  {t="T", q=368, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 693
  {t="A", q=369, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 694
  {t="T", q=370, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 695
  {t="A", q=371, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 696
  {t="G", z=1497, x=84.1, y=17.4, text="Undercity, Bethor Iceshard in the Magic Quarter", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 697
  {t="T", q=405, name="The Prodigal Lich", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 698
  {t="A", q=357, name="The Lich's Identity", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 699
  {t="FP", z=1497, x=63.2, y=48.6, text="Undercity flight path (Michael Garrett)", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 700
  {t="TR", text="Train your level 10 spells in Undercity", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 701
  {t="C", q=357, name="The Lich's Identity", z=85, x=67.96, y=42.09, note="The Lich's Spellbook on Gunther's Retreat island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 702
  {t="G", z=1497, x=84.1, y=17.4, text="Back to Bethor Iceshard in Undercity", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 703
  {t="T", q=357, name="The Lich's Identity", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 704
  {t="A", q=366, name="Return the Book", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Undercity"}, -- 705
  {t="G", z=85, x=68.2, y=41.9, text="Gunther's Retreat island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 706
  {t="T", q=366, name="Return the Book", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 707
  {t="A", q=409, name="Proving Allegiance", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 708
  {t="G", z=85, x=68.2, y=42.0, text="Crate of Candles on the island", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 709
  {t="N", text="Take a Candle of Beckoning, then use it at Lillith's Dinner Table to summon Lillith Nefara", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 710
  {t="G", z=85, x=66.6, y=44.9, text="Lillith's Dinner Table", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 711
  {t="C", q=409, name="Proving Allegiance", z=85, x=66.67, y=44.97, note="Kill Lillith Nefara", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 712
  {t="T", q=409, name="Proving Allegiance", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 713
  {t="A", q=411, name="The Prodigal Lich Returns", z=85, x=68.2, y=41.92, target={kind="npc", id=1497, name="Gunther Arcanus"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 714
  {t="C", q=371, name="At War With The Scarlet Crusade", z=85, x=79.45, y=55.51, note="Captain Vachon at the Scarlet Watch post", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 715
  {t="C", q=369, name="A New Plague", z=85, x=86.74, y=53.2, note="Venom samples from Vicious Night Web spiders", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 716
  {t="C", q=408, name="The Family Crypt", z=85, x=51.87, y=28.76, note="Wailing and Rotting Ancestors in the Agamand Family Crypt", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 717
  {t="H", text="Brill", races={"undead"}, section="Eastern Tirisfal and Undercity"}, -- 718
  {t="T", q=369, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 719
  {t="A", q=492, name="A New Plague", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 720
  {t="T", q=492, name="A New Plague", z=85, x=61.94, y=51.4, target={kind="npc", id=2211, name="Captured Mountaineer"}, note="Give Johaan's Special Drink to the Captured Mountaineer", races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 721
  {t="T", q=374, name="Proof of Demise", z=85, x=60.93, y=52.01, target={kind="npc", id=1652, name="Deathguard Burgess"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 722
  {t="T", q=375, name="The Chill of Death", z=85, x=61.89, y=52.73, target={kind="npc", id=1521, name="Gretchen Dedmar"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 723
  {t="T", q=371, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 724
  {t="A", q=372, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 725
  {t="T", q=408, name="The Family Crypt", z=85, x=61.26, y=50.84, target={kind="npc", id=1499, name="Magistrate Sevren"}, races={"undead"}, section="Eastern Tirisfal and Undercity", zoneName="Tirisfal Glades"}, -- 726
  {t="G", z=85, x=59.43, y=52.19, text="Carolai Anise, Brill", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 727
  {t="A", q=95314, name="That Shadowvale Green Elixir", foreverOnly=true, z=85, x=59.43, y=52.19, target={kind="npc", id=2132, name="Carolai Anise"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 728
  {t="G", z=85, x=63.47, y=56.55, text="Deathguard Terrence, on the road to Undercity", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 729
  {t="A", q=96895, name="The Argent Emissary", foreverOnly=true, z=85, x=63.47, y=56.55, target={kind="npc", id=1738, name="Deathguard Terrence"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 730
  {t="T", q=96895, name="The Argent Emissary", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, note="Hadric Harlson", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 731
  {t="A", q=96897, name="The Cult of the Damned", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 732
  {t="A", q=96898, name="Remnants of War", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 733
  {t="A", q=96899, name="Bandarion Keep", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 734
  {t="C", q=96897, name="The Cult of the Damned", foreverOnly=true, z=85, x=67.8, y=64.46, note="Dark Neophytes and Dark Enforcers", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 735
  {t="C", q=96898, name="Remnants of War", foreverOnly=true, z=85, x=68, y=64.57, note="Necrotic Crystal Fragments from the same cultists", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 736
  {t="T", q=96897, name="The Cult of the Damned", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 737
  {t="T", q=96898, name="Remnants of War", foreverOnly=true, z=85, x=65.88, y=61.13, target={kind="npc", id=267009, name="Hadric Harlson"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 738
  {t="T", q=96899, name="Bandarion Keep", foreverOnly=true, z=85, x=22.01, y=44.77, target={kind="npc", id=267008, name="Leonid Barthalomew the Revered"}, note="Leonid Barthalomew at Bandarion Keep, west Tirisfal", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 739
  {t="A", q=96896, name="A Righteous Cause", foreverOnly=true, z=85, x=22.01, y=44.77, target={kind="npc", id=267008, name="Leonid Barthalomew the Revered"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 740
  {t="C", q=96896, name="A Righteous Cause", foreverOnly=true, z=85, x=22.01, y=44.77, note="Watch Danitha Morr and Leonid talk", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 741
  {t="T", q=96896, name="A Righteous Cause", foreverOnly=true, z=85, x=22.01, y=44.77, target={kind="npc", id=267008, name="Leonid Barthalomew the Revered"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 742
  {t="A", q=98545, name="Leonid's Letter", foreverOnly=true, z=85, x=22.01, y=44.77, target={kind="npc", id=267008, name="Leonid Barthalomew the Revered"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 743
  {t="G", z=85, x=21.92, y=47.19, text="Hilda the Breaker, Shadowvale", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 744
  {t="A", q=99152, name="As Above, So Below", foreverOnly=true, z=85, x=21.92, y=47.19, target={kind="npc", id=246389, name="Hilda the Breaker"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 745
  {t="A", q=99153, name="The One That Got Away", foreverOnly=true, z=85, x=20.15, y=46.59, target={kind="npc", id=259190, name="Ephram Barbaro"}, note="Ephram Barbaro", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 746
  {t="C", q=99152, name="As Above, So Below", foreverOnly=true, z=85, x=10.09, y=66.18, note="Faintly Glowing Bones", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 747
  {t="C", q=99153, name="The One That Got Away", foreverOnly=true, z=85, x=9.8, y=69.3, note="The Hidden Crystal Fragment beneath Shadowvale", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 748
  {t="C", q=95314, name="That Shadowvale Green Elixir", foreverOnly=true, z=85, x=10.3, y=65.2, note="Bottles of Whispering Elixir in Shadowvale", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 749
  {t="T", q=99152, name="As Above, So Below", foreverOnly=true, z=85, x=21.92, y=47.19, target={kind="npc", id=246389, name="Hilda the Breaker"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 750
  {t="T", q=99153, name="The One That Got Away", foreverOnly=true, z=85, x=20.15, y=46.59, target={kind="npc", id=259190, name="Ephram Barbaro"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 751
  {t="G", z=85, x=59.43, y=52.19, text="Carolai Anise, Brill", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 752
  {t="T", q=95314, name="That Shadowvale Green Elixir", foreverOnly=true, z=85, x=59.43, y=52.19, target={kind="npc", id=2132, name="Carolai Anise"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 753
  {t="A", q=445, name="Delivery to Silverpine Forest", z=85, x=59.45, y=52.4, target={kind="npc", id=1518, name="Apothecary Johaan"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 754
  {t="C", q=372, name="At War With The Scarlet Crusade", z=85, x=79.44, y=25.12, note="Captain Melrache at the Scarlet camp north of Brill", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 755
  {t="T", q=372, name="At War With The Scarlet Crusade", z=85, x=60.59, y=51.76, target={kind="npc", id=1515, name="Executor Zygand"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Tirisfal Glades"}, -- 756
  {t="G", z=1497, x=84.1, y=17.4, text="Undercity, Bethor Iceshard", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 757
  {t="T", q=411, name="The Prodigal Lich Returns", z=1497, x=84.07, y=17.45, target={kind="npc", id=1498, name="Bethor Iceshard"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 758
  {t="G", z=1497, x=69.5, y=47.31, text="Glix Xizzix", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 759
  {t="T", q=98545, name="Leonid's Letter", foreverOnly=true, z=1497, x=69.84, y=47.13, target={kind="npc", id=272526, name="Glix Xizzix"}, races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)", zoneName="Undercity"}, -- 760
  {t="N", text="Leave Undercity west and head into Silverpine Forest", races={"undead"}, section="Shadowvale and the Argent Dawn (Forever)"}, -- 761
  {t="G", z=130, x=43.4, y=41.7, text="The Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 762
  {t="T", q=445, name="Delivery to Silverpine Forest", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 763
  {t="A", q=421, name="Prove Your Worth", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 764
  {t="A", q=428, name="Lost Deathstalkers", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 765
  {t="A", q=437, name="The Dead Fields", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 766
  {t="A", q=477, name="Border Crossings", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 767
  {t="A", q=447, name="A Recipe For Death", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 768
  {t="A", q=98298, name="Arugal's Folly", foreverOnly=true, z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 769
  {t="A", q=98299, name="Stop the Spread", foreverOnly=true, z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 770
  {t="FP", z=130, x=45.6, y=42.6, text="Sepulcher flight path (Karos Razok)", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 771
  {t="SH", z=130, x=43.2, y=41.3, text="The Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 772
  {t="C", q=421, name="Prove Your Worth", z=130, x=53, y=26.69, note="Moonrage Whitescalps", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 773
  {t="C", q=98298, name="Arugal's Folly", foreverOnly=true, z=130, x=51.74, y=78.86, note="Worgen Bits from the Moonrage worgen", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 774
  {t="C", q=98299, name="Stop the Spread", foreverOnly=true, z=130, x=46.08, y=85.63, note="Sickly and Haggard Refugees", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 775
  {t="C", q=447, name="A Recipe For Death", z=130, x=45.97, y=18.26, note="Grizzled Bear Hearts and Skittering Blood from bears and spiders", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 776
  {t="T", q=428, name="Lost Deathstalkers", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, note="Rane Yorick at the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 777
  {t="A", q=429, name="Wild Hearts", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 778
  {t="C", q=429, name="Wild Hearts", z=130, x=54.88, y=13.61, note="Discolored worg hearts from worgs", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 779
  {t="G", z=130, x=56.2, y=9.2, text="Deathstalker Erland, north of the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 780
  {t="A", q=435, name="Escorting Erland", z=130, x=56.18, y=9.18, target={kind="npc", id=1978, name="Deathstalker Erland"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 781
  {t="C", q=435, name="Escorting Erland", z=130, x=54.37, y=13.38, note="Escort Erland back to Rane", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 782
  {t="T", q=435, name="Escorting Erland", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 783
  {t="A", q=449, name="The Deathstalkers' Report", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 784
  {t="G", z=130, x=44.7, y=22.6, text="The Dead Fields", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 785
  {t="C", q=437, name="The Dead Fields", z=130, x=45, y=21, note="Kill Rot Hide gnolls until Nightlash appears, then kill her", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 786
  {t="G", z=130, x=43.4, y=41.7, text="Back to the Sepulcher (hearth if it is off cooldown)", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 787
  {t="T", q=421, name="Prove Your Worth", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 788
  {t="A", q=422, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 789
  {t="T", q=98298, name="Arugal's Folly", foreverOnly=true, z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 790
  {t="T", q=98299, name="Stop the Spread", foreverOnly=true, z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 791
  {t="A", q=95981, name="Watching the Roads", foreverOnly=true, z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, note="Shadow Priest Allister", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 792
  {t="T", q=429, name="Wild Hearts", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 793
  {t="A", q=430, name="Return to Quinn", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 794
  {t="T", q=437, name="The Dead Fields", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 795
  {t="T", q=449, name="The Deathstalkers' Report", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 796
  {t="A", q=3221, name="Speak with Renferrel", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 797
  {t="T", q=3221, name="Speak with Renferrel", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 798
  {t="A", q=1359, name="Zinge's Delivery", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 799
  {t="C", q=422, name="Arugal's Folly", z=130, x=52.83, y=28.58, note="Remedy of Arugal", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 800
  {t="T", q=430, name="Return to Quinn", z=130, x=53.43, y=12.59, target={kind="npc", id=1951, name="Quinn Yorick"}, note="Quinn Yorick at the Ivar Patch", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 801
  {t="A", q=91920, name="Wild Eyes", foreverOnly=true, z=130, x=53.43, y=12.59, target={kind="npc", id=1951, name="Quinn Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 802
  {t="C", q=91920, name="Wild Eyes", foreverOnly=true, z=130, x=57.85, y=24.64, note="Murloc eyes from the coastal murlocs", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 803
  {t="A", q=425, name="Ivar the Foul", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 804
  {t="C", q=425, name="Ivar the Foul", z=130, x=51.52, y=13.9, note="Ivar the Foul in the barn", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 805
  {t="T", q=425, name="Ivar the Foul", z=130, x=53.46, y=13.43, target={kind="npc", id=1950, name="Rane Yorick"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 806
  {t="G", z=130, x=44.2, y=39.8, text="Back to Dalar Dawnweaver", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 807
  {t="T", q=91920, name="Wild Eyes", foreverOnly=true, z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, note="Apothecary Renferrel", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 808
  {t="T", q=422, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 809
  {t="A", q=423, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 810
  {t="C", q=423, name="Arugal's Folly", z=130, x=45.52, y=29.17, note="Glutton and Darksoul Shackles from the Moonrage gluttons and darksouls", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 811
  {t="T", q=423, name="Arugal's Folly", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 812
  {t="G", z=130, x=49.9, y=60.3, text="Dalaran crate south of the Sepulcher", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 813
  {t="T", q=477, name="Border Crossings", z=130, x=49.89, y=60.33, target={kind="object", id=1627, name="Dalaran Crate"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 814
  {t="A", q=478, name="Maps and Runes", z=130, x=49.89, y=60.33, target={kind="object", id=1627, name="Dalaran Crate"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 815
  {t="C", q=95981, name="Watching the Roads", foreverOnly=true, z=130, x=63, y=72.74, note="Dalaran Wizards and Watchers around the crates", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 816
  {t="G", z=130, x=44.0, y=40.9, text="Shadow Priest Allister", races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 817
  {t="T", q=478, name="Maps and Runes", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 818
  {t="T", q=95981, name="Watching the Roads", foreverOnly=true, z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 819
  {t="A", q=481, name="Dalar's Analysis", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 820
  {t="T", q=481, name="Dalar's Analysis", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 821
  {t="A", q=482, name="Dalaran's Intentions", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 822
  {t="T", q=482, name="Dalaran's Intentions", z=130, x=43.98, y=40.93, target={kind="npc", id=2121, name="Shadow Priest Allister"}, races={"undead"}, section="Silverpine Forest (Undead)", zoneName="Silverpine Forest"}, -- 823
  {t="F", text="Undercity", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 824
  {t="G", z=1497, x=48.8, y=69.3, text="Master Apothecary Faranell, Apothecarium", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 825
  {t="T", q=447, name="A Recipe For Death", z=1497, x=48.82, y=69.28, target={kind="npc", id=2055, name="Master Apothecary Faranell"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 826
  {t="G", z=1497, x=50.1, y=68.0, text="Apothecary Zinge", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 827
  {t="T", q=1359, name="Zinge's Delivery", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 828
  {t="A", q=1358, name="Sample for Helbrim", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 829
  {t="G", z=1497, x=84.1, y=17.4, text="Bethor Iceshard", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Undercity"}, -- 830
  {t="TR", text="Train your level 14 spells", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 831
  {t="N", text="Take the zeppelin to Orgrimmar from the tower just outside Undercity", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar"}, -- 832
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path", races={"undead"}, section="Undercity, then the zeppelin to Orgrimmar", zoneName="Orgrimmar"}, -- 833
  {t="G", z=17, x=62.3, y=19.4, text="Far Watch Post, follow the road west from Durotar", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 834
  {t="T", q=840, name="Conscript of the Horde", z=17, x=62.26, y=19.38, target={kind="npc", id=3337, name="Kargal Battlescar"}, races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 835
  {t="A", q=842, name="Crossroads Conscription", z=17, x=62.26, y=19.38, target={kind="npc", id=3337, name="Kargal Battlescar"}, races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 836
  {t="T", q=809, name="Ak'Zeloth", z=17, x=62.34, y=20.07, target={kind="npc", id=3521, name="Ak'Zeloth"}, note="Ak'Zeloth, next to the tower", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)", zoneName="The Barrens"}, -- 837
  {t="N", text="Skip The Demon Seed unless you want the extra run to the altar", races={"orc", "troll"}, section="Into The Barrens (Orc / Troll)"}, -- 838
  {t="G", z=17, x=44.9, y=59.1, text="Camp Taurajo, east of Mulgore", races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 839
  {t="FP", z=17, x=44.4, y=59.2, text="Camp Taurajo flight path", races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 840
  {t="A", q=854, name="Journey to the Crossroads", z=17, x=44.88, y=58.61, target={kind="npc", id=3418, name="Kirge Sternhorn"}, races={"tauren"}, section="Into The Barrens (Tauren)", zoneName="The Barrens"}, -- 841
  {t="N", text="Run north along the road to the Crossroads", races={"tauren"}, section="Into The Barrens (Tauren)"}, -- 842
  {t="N", text="From Orgrimmar, leave by the west gate and follow the road south-west into the Barrens", races={"undead"}, section="Into The Barrens (Undead)"}, -- 843
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="The Crossroads", zoneName="The Barrens"}, -- 844
  {t="T", q=842, name="Crossroads Conscription", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, races={"orc", "troll"}, section="The Crossroads", zoneName="The Barrens"}, -- 845
  {t="T", q=854, name="Journey to the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 846
  {t="T", q=860, name="Sergra Darkthorn", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 847
  {t="T", q=886, name="The Barrens Oases", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, races={"tauren"}, section="The Crossroads", zoneName="The Barrens"}, -- 848
  {t="T", q=1358, name="Sample for Helbrim", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, races={"undead"}, section="The Crossroads", zoneName="The Barrens"}, -- 849
  {t="T", q=98024, name="Journey to the Crossroads", foreverOnly=true, z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, note="Thork", races={"skyborne"}, section="The Crossroads", zoneName="The Barrens"}, -- 850
  {t="SH", z=17, x=52.0, y=29.9, text="The Crossroads", section="The Crossroads", zoneName="The Barrens"}, -- 851
  {t="FP", z=17, x=51.5, y=30.3, text="Crossroads flight path (Devrak)", section="The Crossroads", zoneName="The Barrens"}, -- 852
  {t="A", q=844, name="Plainstrider Menace", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="The Crossroads", zoneName="The Barrens"}, -- 853
  {t="A", q=869, name="Raptor Thieves", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="The Crossroads", zoneName="The Barrens"}, -- 854
  {t="A", q=870, name="The Forgotten Pools", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="The Crossroads", zoneName="The Barrens"}, -- 855
  {t="A", q=848, name="Fungal Spores", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="The Crossroads", zoneName="The Barrens"}, -- 856
  {t="A", q=871, name="Disrupt the Attacks", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="The Crossroads", zoneName="The Barrens"}, -- 857
  {t="A", q=1492, name="Wharfmaster Dizzywig", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="The Crossroads", zoneName="The Barrens"}, -- 858
  {t="TR", text="Train at Orgrimmar / Thunder Bluff when you next pass; most classes get new ranks every even level", section="The Crossroads"}, -- 859
  {t="C", q=844, name="Plainstrider Menace", z=17, x=51.38, y=28.01, note="Plainstriders around the Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 860
  {t="C", q=871, name="Disrupt the Attacks", z=17, x=55.1, y=25.59, note="Razormane quilboar east of the Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 861
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="East of the Crossroads", zoneName="The Barrens"}, -- 862
  {t="T", q=844, name="Plainstrider Menace", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 863
  {t="T", q=871, name="Disrupt the Attacks", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 864
  {t="A", q=845, name="The Zhevra", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 865
  {t="A", q=872, name="The Disruption Ends", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 866
  {t="A", q=5041, name="Supplies for the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="East of the Crossroads", zoneName="The Barrens"}, -- 867
  {t="C", q=872, name="The Disruption Ends", z=17, x=58.9, y=25, note="Razormane Geomancers, Defenders and Kreenig Snarlsnout", section="East of the Crossroads", zoneName="The Barrens"}, -- 868
  {t="C", q=5041, name="Supplies for the Crossroads", z=17, x=59.35, y=24.9, note="Supply crates in the Razormane camp", section="East of the Crossroads", zoneName="The Barrens"}, -- 869
  {t="C", q=845, name="The Zhevra", z=17, x=50.79, y=34.14, note="Zhevra Runners on the way south", section="East of the Crossroads", zoneName="The Barrens"}, -- 870
  {t="C", q=869, name="Raptor Thieves", z=17, x=55.99, y=33.56, note="Raptor heads from Sunscale raptors", section="East of the Crossroads", zoneName="The Barrens"}, -- 871
  {t="G", z=17, x=63.4, y=38.5, text="Ratchet docks", section="Ratchet", zoneName="The Barrens"}, -- 872
  {t="T", q=1492, name="Wharfmaster Dizzywig", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 873
  {t="A", q=887, name="Southsea Freebooters", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 874
  {t="A", q=895, name="WANTED: Baron Longshore", z=17, x=62.59, y=37.47, target={kind="object", id=3972, name="WANTED"}, section="Ratchet", zoneName="The Barrens"}, -- 875
  {t="A", q=894, name="Samophlange", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet", zoneName="The Barrens"}, -- 876
  {t="A", q=865, name="Raptor Horns", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet", zoneName="The Barrens"}, -- 877
  {t="A", q=866, name="Root Samples", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet", zoneName="The Barrens"}, -- 878
  {t="FP", z=17, x=63.1, y=37.2, text="Ratchet flight path (Bragok)", section="Ratchet", zoneName="The Barrens"}, -- 879
  {t="A", q=97253, name="Parts and Pieces", foreverOnly=true, z=17, x=63.07, y=36.32, target={kind="npc", id=7161, name="Wrenix the Wretched"}, note="Wrenix the Wretched", section="Ratchet", zoneName="The Barrens"}, -- 880
  {t="C", q=887, name="Southsea Freebooters", z=17, x=63.82, y=46.9, note="Southsea Brigands and Cannoneers on the coast south of Ratchet", section="Ratchet", zoneName="The Barrens"}, -- 881
  {t="C", q=895, name="WANTED: Baron Longshore", z=17, x=63.3, y=49, note="Baron Longshore at the pirate camp", section="Ratchet", zoneName="The Barrens"}, -- 882
  {t="C", q=97253, name="Parts and Pieces", foreverOnly=true, z=17, x=62, y=45.9, note="Handfuls of Complicated Parts at the upper pirate camp", section="Ratchet", zoneName="The Barrens"}, -- 883
  {t="G", z=17, x=62.7, y=36.2, text="Back to Gazlowe", section="Ratchet", zoneName="The Barrens"}, -- 884
  {t="T", q=887, name="Southsea Freebooters", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 885
  {t="T", q=895, name="WANTED: Baron Longshore", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 886
  {t="T", q=97253, name="Parts and Pieces", foreverOnly=true, z=17, x=63.07, y=36.32, target={kind="npc", id=7161, name="Wrenix the Wretched"}, note="Wrenix the Wretched", section="Ratchet", zoneName="The Barrens"}, -- 887
  {t="A", q=890, name="The Missing Shipment", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 888
  {t="T", q=890, name="The Missing Shipment", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, note="Wharfmaster Dizzywig on the docks", section="Ratchet", zoneName="The Barrens"}, -- 889
  {t="A", q=892, name="The Missing Shipment", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 890
  {t="T", q=892, name="The Missing Shipment", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Ratchet", zoneName="The Barrens"}, -- 891
  {t="A", q=896, name="Miner's Fortune", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet", zoneName="The Barrens"}, -- 892
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="Ratchet", zoneName="The Barrens"}, -- 893
  {t="T", q=869, name="Raptor Thieves", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Ratchet", zoneName="The Barrens"}, -- 894
  {t="T", q=845, name="The Zhevra", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Ratchet", zoneName="The Barrens"}, -- 895
  {t="T", q=872, name="The Disruption Ends", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="Ratchet", zoneName="The Barrens"}, -- 896
  {t="T", q=5041, name="Supplies for the Crossroads", z=17, x=51.5, y=30.87, target={kind="npc", id=3429, name="Thork"}, section="Ratchet", zoneName="The Barrens"}, -- 897
  {t="A", q=903, name="Prowlers of the Barrens", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Ratchet", zoneName="The Barrens"}, -- 898
  {t="A", q=867, name="Harpy Raiders", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="Ratchet", zoneName="The Barrens"}, -- 899
  {t="F", text="Orgrimmar", section="Ragefire Chasm (dungeon, group of 5)"}, -- 900
  {t="FP", z=1637, x=45.1, y=63.9, text="Orgrimmar flight path (if you don't have it yet)", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 901
  {t="G", z=1637, x=49.5, y=50.6, text="Neeru Fireblade in the Cleft of Shadow", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 902
  {t="A", q=5761, name="Slaying the Beast", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 903
  {t="D", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", text="Ragefire Chasm, in the Cleft of Shadow", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 904
  {t="C", q=5761, name="Slaying the Beast", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Taragaman the Hungerer, last boss", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 905
  {t="C", q=5723, name="Testing an Enemy's Strength", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Ragefire Troggs and Shamans", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 906
  {t="C", q=5722, name="Searching for the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", note="Maur Grimtotem's corpse", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 907
  {t="T", q=5722, name="Searching for the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", target={kind="npc", id=11834, name="Maur Grimtotem"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 908
  {t="A", q=5724, name="Returning the Lost Satchel", z=1637, x=52.6, y=49.0, instance=2437, dungeonName="Ragefire Chasm", target={kind="npc", id=11834, name="Maur Grimtotem"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 909
  {t="G", z=1637, x=49.5, y=50.6, text="Neeru Fireblade", section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 910
  {t="T", q=5761, name="Slaying the Beast", z=1637, x=49.47, y=50.59, target={kind="npc", id=3216, name="Neeru Fireblade"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Orgrimmar"}, -- 911
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)"}, -- 912
  {t="T", q=5723, name="Testing an Enemy's Strength", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Thunder Bluff"}, -- 913
  {t="T", q=5724, name="Returning the Lost Satchel", z=1638, x=70.14, y=29.52, target={kind="npc", id=11833, name="Rahauro"}, races={"tauren"}, section="Ragefire Chasm (dungeon, group of 5)", zoneName="Thunder Bluff"}, -- 914
  {t="F", text="The Crossroads", section="Ragefire Chasm (dungeon, group of 5)"}, -- 915
  {t="C", q=870, name="The Forgotten Pools", z=17, x=45.06, y=22.53, note="Explore the Forgotten Pools", section="North Barrens", zoneName="The Barrens"}, -- 916
  {t="C", q=903, name="Prowlers of the Barrens", z=17, x=42, y=23.51, note="Savannah Prowlers", section="North Barrens", zoneName="The Barrens"}, -- 917
  {t="C", q=867, name="Harpy Raiders", z=17, x=39.75, y=15.6, note="Witchwing harpies for talons", section="North Barrens", zoneName="The Barrens"}, -- 918
  {t="G", z=17, x=43.8, y=12.21, text="Vrang Wildgore, north-west Barrens", section="North Barrens", zoneName="The Barrens"}, -- 919
  {t="A", q=95494, name="Bruised Pride and Lion Hides", foreverOnly=true, z=17, x=43.8, y=12.21, target={kind="npc", id=3682, name="Vrang Wildgore"}, section="North Barrens", zoneName="The Barrens"}, -- 920
  {t="A", q=95507, name="Vrang's Game", foreverOnly=true, z=17, x=43.8, y=12.21, target={kind="npc", id=3682, name="Vrang Wildgore"}, section="North Barrens", zoneName="The Barrens"}, -- 921
  {t="A", q=95495, name="The Hermit Tanner", foreverOnly=true, z=17, x=43.8, y=12.21, target={kind="npc", id=3682, name="Vrang Wildgore"}, section="North Barrens", zoneName="The Barrens"}, -- 922
  {t="T", q=95495, name="The Hermit Tanner", foreverOnly=true, z=17, x=42.01, y=11.44, target={kind="npc", id=261366, name="Walton"}, note="Walton, on the ridge overlooking the Dry Hills", section="North Barrens", zoneName="The Barrens"}, -- 923
  {t="A", q=95508, name="Unwelcome Guests", foreverOnly=true, z=17, x=42.01, y=11.44, target={kind="npc", id=261366, name="Walton"}, section="North Barrens", zoneName="The Barrens"}, -- 924
  {t="C", q=95508, name="Unwelcome Guests", foreverOnly=true, z=17, x=42.01, y=11.44, note="Help Walton survive Terry Longdrink and the Kul Tiras marines", section="North Barrens", zoneName="The Barrens"}, -- 925
  {t="T", q=95508, name="Unwelcome Guests", foreverOnly=true, z=17, x=42.01, y=11.44, target={kind="npc", id=261366, name="Walton"}, section="North Barrens", zoneName="The Barrens"}, -- 926
  {t="A", q=95621, name="Trouble in the Valley", foreverOnly=true, z=17, x=42.01, y=11.44, target={kind="npc", id=261366, name="Walton"}, section="North Barrens", zoneName="The Barrens"}, -- 927
  {t="C", q=95621, name="Trouble in the Valley", foreverOnly=true, z=17, x=41.44, y=15.45, note="Benedict's Orders at the wrecked caravan", section="North Barrens", zoneName="The Barrens"}, -- 928
  {t="T", q=95621, name="Trouble in the Valley", foreverOnly=true, z=17, x=42.01, y=11.44, target={kind="npc", id=261366, name="Walton"}, section="North Barrens", zoneName="The Barrens"}, -- 929
  {t="C", q=95494, name="Bruised Pride and Lion Hides", foreverOnly=true, z=17, x=61.71, y=32.42, note="Savannah Lion Hides from Savannah Matriarchs and Patriarchs", section="North Barrens", zoneName="The Barrens"}, -- 930
  {t="C", q=95507, name="Vrang's Game", foreverOnly=true, z=17, x=45.3, y=14, note="Trapped Game from the sprung traps", section="North Barrens", zoneName="The Barrens"}, -- 931
  {t="G", z=17, x=43.8, y=12.21, text="Vrang Wildgore", section="North Barrens", zoneName="The Barrens"}, -- 932
  {t="T", q=95494, name="Bruised Pride and Lion Hides", foreverOnly=true, z=17, x=43.8, y=12.21, target={kind="npc", id=3682, name="Vrang Wildgore"}, section="North Barrens", zoneName="The Barrens"}, -- 933
  {t="T", q=95507, name="Vrang's Game", foreverOnly=true, z=17, x=43.8, y=12.21, target={kind="npc", id=3682, name="Vrang Wildgore"}, section="North Barrens", zoneName="The Barrens"}, -- 934
  {t="C", q=894, name="Samophlange", z=17, x=43.8, y=12.21, note="Go to the control console at the Sludge Fen", section="North Barrens", zoneName="The Barrens"}, -- 935
  {t="T", q=894, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 936
  {t="A", q=900, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 937
  {t="C", q=900, name="Samophlange", z=17, x=52.3, y=11.42, note="Close the three valves", section="North Barrens", zoneName="The Barrens"}, -- 938
  {t="T", q=900, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 939
  {t="A", q=901, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 940
  {t="C", q=901, name="Samophlange", z=17, x=52.84, y=10.39, note="Tinkerer Sniggles has the console key", section="North Barrens", zoneName="The Barrens"}, -- 941
  {t="T", q=901, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 942
  {t="A", q=902, name="Samophlange", z=17, x=52.4, y=11.65, target={kind="object", id=4141, name="Control Console"}, section="North Barrens", zoneName="The Barrens"}, -- 943
  {t="G", z=17, x=56.5, y=7.5, text="Wizzlecrank's Shredder at the Venture Co. tower", section="North Barrens", zoneName="The Barrens"}, -- 944
  {t="A", q=858, name="Ignition", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 945
  {t="C", q=858, name="Ignition", z=17, x=56.27, y=8.58, note="Ignition Key from Supervisor Lugwizzle on top of the tower", section="North Barrens", zoneName="The Barrens"}, -- 946
  {t="T", q=858, name="Ignition", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 947
  {t="A", q=863, name="The Escape", z=17, x=56.52, y=7.45, target={kind="npc", id=3439, name="Wizzlecrank's Shredder"}, section="North Barrens", zoneName="The Barrens"}, -- 948
  {t="C", q=863, name="The Escape", z=17, x=55.36, y=7.68, note="Escort Wizzlecrank (he ends the escort near the Crossroads road)", section="North Barrens", zoneName="The Barrens"}, -- 949
  {t="C", q=896, name="Miner's Fortune", z=17, x=60.66, y=3.79, note="Cats Eye Emerald from Boulder Lode Mine overseers", section="North Barrens", zoneName="The Barrens"}, -- 950
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="North Barrens", zoneName="The Barrens"}, -- 951
  {t="T", q=870, name="The Forgotten Pools", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="North Barrens", zoneName="The Barrens"}, -- 952
  {t="A", q=877, name="The Stagnant Oasis", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="North Barrens", zoneName="The Barrens"}, -- 953
  {t="T", q=903, name="Prowlers of the Barrens", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="North Barrens", zoneName="The Barrens"}, -- 954
  {t="A", q=881, name="Echeyakee", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="North Barrens", zoneName="The Barrens"}, -- 955
  {t="T", q=867, name="Harpy Raiders", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="North Barrens", zoneName="The Barrens"}, -- 956
  {t="A", q=875, name="Harpy Lieutenants", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="North Barrens", zoneName="The Barrens"}, -- 957
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate, west of the Crossroads", section="North Barrens", zoneName="The Barrens"}, -- 958
  {t="A", q=855, name="Centaur Bracers", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="North Barrens", zoneName="The Barrens"}, -- 959
  {t="A", q=850, name="Kolkar Leaders", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="North Barrens", zoneName="The Barrens"}, -- 960
  {t="C", q=875, name="Harpy Lieutenants", z=17, x=38.79, y=15.11, note="Witchwing Slayers for rings", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 961
  {t="C", q=850, name="Kolkar Leaders", z=17, x=42.8, y=23.52, note="Barak Kodobane at the Kolkar camp", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 962
  {t="G", z=17, x=55.8, y=17.1, text="Echeyakee's Lair", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 963
  {t="C", q=881, name="Echeyakee", z=17, x=55.86, y=17.19, note="Use the Horn of Echeyakee here to summon him", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 964
  {t="C", q=877, name="The Stagnant Oasis", z=17, x=55.61, y=42.75, note="Investigate the Stagnant Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 965
  {t="C", q=865, name="Raptor Horns", z=17, x=52.58, y=45.99, note="Intact Raptor Horns from Sunscale Scytheclaws", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 966
  {t="C", q=848, name="Fungal Spores", z=17, x=46.68, y=38.76, note="Fungal Spores at Lushwater Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 967
  {t="C", q=866, name="Root Samples", z=17, x=48.61, y=37.47, note="Root Samples around Lushwater Oasis", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 968
  {t="C", q=855, name="Centaur Bracers", z=17, x=46.71, y=37.9, note="Centaur Bracers from Kolkar centaurs", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 969
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 970
  {t="T", q=850, name="Kolkar Leaders", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 971
  {t="T", q=855, name="Centaur Bracers", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 972
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 973
  {t="T", q=875, name="Harpy Lieutenants", z=17, x=51.62, y=30.9, target={kind="npc", id=3449, name="Darsok Swiftdagger"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 974
  {t="T", q=877, name="The Stagnant Oasis", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 975
  {t="A", q=880, name="Altered Beings", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 976
  {t="T", q=881, name="Echeyakee", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 977
  {t="A", q=905, name="The Angry Scytheclaws", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 978
  {t="T", q=848, name="Fungal Spores", z=17, x=51.44, y=30.15, target={kind="npc", id=3390, name="Apothecary Helbrim"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 979
  {t="A", q=4921, name="Lost in Battle", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 980
  {t="A", q=899, name="Consumed by Hatred", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 981
  {t="A", q=95774, name="Her Name Is Olgra", foreverOnly=true, z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, note="Mankrik", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 982
  {t="G", z=17, x=52.63, y=29.06, text="Gur'ak at the Crossroads", section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 983
  {t="A", q=97003, name="Chol'aruk the Ravener", foreverOnly=true, z=17, x=52.67, y=28.99, target={kind="npc", id=267310, name="Gur'ak"}, section="West and Lushwater Oasis", zoneName="The Barrens"}, -- 984
  {t="TR", text="Train in Orgrimmar or Thunder Bluff if you are behind on spells", section="West and Lushwater Oasis"}, -- 985
  {t="F", text="Ratchet", section="Ratchet turn-ins"}, -- 986
  {t="T", q=902, name="Samophlange", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 987
  {t="A", q=92706, name="WANTED: Bruuz", foreverOnly=true, z=17, x=62.59, y=37.47, target={kind="object", id=3972, name="WANTED"}, note="WANTED poster in Ratchet", section="Ratchet turn-ins", zoneName="The Barrens"}, -- 988
  {t="T", q=865, name="Raptor Horns", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 989
  {t="T", q=866, name="Root Samples", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 990
  {t="T", q=896, name="Miner's Fortune", z=17, x=63.35, y=38.45, target={kind="npc", id=3453, name="Wharfmaster Dizzywig"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 991
  {t="T", q=863, name="The Escape", z=17, x=62.98, y=37.22, target={kind="npc", id=3442, name="Sputtervalve"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 992
  {t="A", q=1491, name="Smart Drinks", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 993
  {t="A", q=959, name="Trouble at the Docks", z=17, x=63.09, y=37.61, target={kind="npc", id=3665, name="Crane Operator Bigglefuzz"}, section="Ratchet turn-ins", zoneName="The Barrens"}, -- 994
  {t="F", text="The Crossroads", section="Ratchet turn-ins"}, -- 995
  {t="C", q=905, name="The Angry Scytheclaws", z=17, x=55.99, y=33.56, note="Sunscale raptors east of the Crossroads; use the feathers on the nests", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 996
  {t="C", q=880, name="Altered Beings", z=17, x=47.74, y=40.22, note="Altered Snapjaws at Lushwater Oasis", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 997
  {t="C", q=1491, name="Smart Drinks", z=17, x=46.0, y=36.5, note="Wailing Essence from the ectoplasm mobs at the Wailing Caverns mound", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 998
  {t="C", q=959, name="Trouble at the Docks", z=17, x=46.0, y=36.5, note="Find the stolen bottle near the Wailing Caverns oasis", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 999
  {t="G", z=17, x=52.2, y=31.0, text="The Crossroads", section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 1000
  {t="T", q=905, name="The Angry Scytheclaws", z=17, x=52.23, y=31.01, target={kind="npc", id=3338, name="Sergra Darkthorn"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 1001
  {t="T", q=880, name="Altered Beings", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 1002
  {t="A", q=3281, name="Stolen Silver", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 1003
  {t="A", q=1489, name="Hamuul Runetotem", z=17, x=52.26, y=31.93, target={kind="npc", id=3448, name="Tonga Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="The Barrens"}, -- 1004
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound"}, -- 1005
  {t="T", q=1489, name="Hamuul Runetotem", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 1006
  {t="A", q=1490, name="Nara Wildmane", z=1638, x=78.62, y=28.56, target={kind="npc", id=5769, name="Arch Druid Hamuul Runetotem"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 1007
  {t="T", q=1490, name="Nara Wildmane", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 1008
  {t="A", q=914, name="Leaders of the Fang", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound", zoneName="Thunder Bluff"}, -- 1009
  {t="F", text="The Crossroads", races={"tauren"}, section="Lushwater Oasis and the Wailing Caverns mound"}, -- 1010
  {t="G", z=17, x=46.0, y=35.7, text="Nalpak and Ebru, in the cave on top of the Wailing Caverns mound", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1011
  {t="A", q=1486, name="Deviate Hides", z=17, x=45.99, y=35.66, target={kind="npc", id=5767, name="Nalpak"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1012
  {t="A", q=1487, name="Deviate Eradication", z=17, x=46.01, y=35.74, target={kind="npc", id=5768, name="Ebru"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1013
  {t="D", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", text="Wailing Caverns", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1014
  {t="C", q=1486, name="Deviate Hides", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="Deviate Hides from the deviate beasts inside", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1015
  {t="C", q=1487, name="Deviate Eradication", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="Deviate Ravagers, Vipers, Shamblers and Dreadfangs", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1016
  {t="C", q=914, name="Leaders of the Fang", z=17, x=46.0, y=36.5, instance=718, dungeonName="Wailing Caverns", note="The gems from Lady Anacondra and Lords Cobrahn, Pythas and Serpentis", races={"tauren"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1017
  {t="G", z=17, x=46.0, y=35.7, text="Nalpak and Ebru", section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1018
  {t="T", q=1486, name="Deviate Hides", z=17, x=45.99, y=35.66, target={kind="npc", id=5767, name="Nalpak"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1019
  {t="T", q=1487, name="Deviate Eradication", z=17, x=46.01, y=35.74, target={kind="npc", id=5768, name="Ebru"}, section="Wailing Caverns (dungeon, group of 5)", zoneName="The Barrens"}, -- 1020
  {t="G", z=17, x=44.9, y=59.1, text="Camp Taurajo", section="South of the Crossroads", zoneName="The Barrens"}, -- 1021
  {t="FP", z=17, x=44.4, y=59.2, text="Camp Taurajo flight path", races={"orc", "troll", "undead", "skyborne"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1022
  {t="A", q=878, name="Tribes at War", z=17, x=44.55, y=59.26, target={kind="npc", id=3430, name="Mangletooth"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1023
  {t="A", q=97250, name="Wrongly Blamed, Justly Corrected", foreverOnly=true, z=17, x=44.62, y=59.27, target={kind="npc", id=5911, name="Grunt Logmar"}, note="Grunt Logmar", section="South of the Crossroads", zoneName="The Barrens"}, -- 1024
  {t="C", q=4921, name="Lost in Battle", z=17, x=49.33, y=50.32, note="Mankrik's wife lies dead at the Bristleback camp south of the Crossroads road", section="South of the Crossroads", zoneName="The Barrens"}, -- 1025
  {t="C", q=878, name="Tribes at War", z=17, x=51.32, y=54.16, note="Bristleback quilboar", section="South of the Crossroads", zoneName="The Barrens"}, -- 1026
  {t="C", q=899, name="Consumed by Hatred", z=17, x=45.51, y=53.76, note="Bristleback tusks; keep killing quilboar until you have 60", section="South of the Crossroads", zoneName="The Barrens"}, -- 1027
  {t="C", q=95774, name="Her Name Is Olgra", foreverOnly=true, z=17, x=49.48, y=50.97, note="Olgra's Adornments from the quilboar", section="South of the Crossroads", zoneName="The Barrens"}, -- 1028
  {t="C", q=97003, name="Chol'aruk the Ravener", foreverOnly=true, z=17, x=57.65, y=27.43, note="Chol'aruk the Ravener", section="South of the Crossroads", zoneName="The Barrens"}, -- 1029
  {t="C", q=97250, name="Wrongly Blamed, Justly Corrected", foreverOnly=true, z=17, x=48.7, y=77.49, note="Alliance soldiers at the Dustwallow Marsh border", section="South of the Crossroads", zoneName="The Barrens"}, -- 1030
  {t="G", z=17, x=44.62, y=59.27, text="Grunt Logmar, Camp Taurajo", section="South of the Crossroads", zoneName="The Barrens"}, -- 1031
  {t="T", q=97250, name="Wrongly Blamed, Justly Corrected", foreverOnly=true, z=17, x=44.62, y=59.27, target={kind="npc", id=5911, name="Grunt Logmar"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1032
  {t="G", z=17, x=44.5, y=59.3, text="Mangletooth, Camp Taurajo", section="South of the Crossroads", zoneName="The Barrens"}, -- 1033
  {t="T", q=878, name="Tribes at War", z=17, x=44.55, y=59.26, target={kind="npc", id=3430, name="Mangletooth"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1034
  {t="F", text="The Crossroads", section="South of the Crossroads"}, -- 1035
  {t="T", q=4921, name="Lost in Battle", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1036
  {t="T", q=899, name="Consumed by Hatred", z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1037
  {t="T", q=95774, name="Her Name Is Olgra", foreverOnly=true, z=17, x=51.95, y=31.58, target={kind="npc", id=3432, name="Mankrik"}, section="South of the Crossroads", zoneName="The Barrens"}, -- 1038
  {t="T", q=97003, name="Chol'aruk the Ravener", foreverOnly=true, z=17, x=52.67, y=28.99, target={kind="npc", id=267310, name="Gur'ak"}, note="Gur'ak", section="South of the Crossroads", zoneName="The Barrens"}, -- 1039
  {t="F", text="Ratchet", section="Northwatch Hold"}, -- 1040
  {t="T", q=1491, name="Smart Drinks", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1041
  {t="T", q=959, name="Trouble at the Docks", z=17, x=63.09, y=37.61, target={kind="npc", id=3665, name="Crane Operator Bigglefuzz"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1042
  {t="A", q=891, name="The Guns of Northwatch", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1043
  {t="A", q=888, name="Stolen Booty", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1044
  {t="C", q=888, name="Stolen Booty", z=17, x=63.58, y=49.25, note="Shipment of Boots and Telescopic Lens at the pirate camp", section="Northwatch Hold", zoneName="The Barrens"}, -- 1045
  {t="C", q=891, name="The Guns of Northwatch", z=17, x=61.8, y=54.84, note="Theramore Medals from the Northwatch soldiers", section="Northwatch Hold", zoneName="The Barrens"}, -- 1046
  {t="C", q=3281, name="Stolen Silver", z=17, x=58.04, y=53.87, note="Stolen Silver in Northwatch Hold", section="Northwatch Hold", zoneName="The Barrens"}, -- 1047
  {t="C", q=92706, name="WANTED: Bruuz", foreverOnly=true, z=17, x=63.67, y=38.66, note="Bruuz, in the waters off the coast", section="Northwatch Hold", zoneName="The Barrens"}, -- 1048
  {t="G", z=17, x=62.0, y=55.0, text="Gilthares Firebough, in the Northwatch keep", section="Northwatch Hold", zoneName="The Barrens"}, -- 1049
  {t="A", q=898, name="Free From the Hold", z=17, x=61.96, y=54.96, target={kind="npc", id=3465, name="Gilthares Firebough"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1050
  {t="C", q=898, name="Free From the Hold", z=17, x=62.27, y=39.09, note="Escort Gilthares to Ratchet", section="Northwatch Hold", zoneName="The Barrens"}, -- 1051
  {t="T", q=898, name="Free From the Hold", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1052
  {t="T", q=891, name="The Guns of Northwatch", z=17, x=62.29, y=39.03, target={kind="npc", id=3339, name="Captain Thalo'thas Brightsun"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1053
  {t="T", q=888, name="Stolen Booty", z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1054
  {t="T", q=92706, name="WANTED: Bruuz", foreverOnly=true, z=17, x=62.68, y=36.23, target={kind="npc", id=3391, name="Gazlowe"}, note="Gazlowe", section="Northwatch Hold", zoneName="The Barrens"}, -- 1055
  {t="F", text="The Crossroads", section="Northwatch Hold"}, -- 1056
  {t="T", q=3281, name="Stolen Silver", z=17, x=51.93, y=30.32, target={kind="npc", id=3464, name="Gazrog"}, section="Northwatch Hold", zoneName="The Barrens"}, -- 1057
  {t="TR", text="Train level 20 spells (Orgrimmar / Thunder Bluff / Undercity)", section="Northwatch Hold"}, -- 1058
  {t="F", text="Thunder Bluff", races={"tauren"}, section="Northwatch Hold"}, -- 1059
  {t="T", q=914, name="Leaders of the Fang", z=1638, x=75.65, y=31.61, target={kind="npc", id=5770, name="Nara Wildmane"}, note="Nara Wildmane on Elder Rise", races={"tauren"}, section="Northwatch Hold", zoneName="Thunder Bluff"}, -- 1060
  {t="F", text="The Crossroads", races={"tauren"}, section="Northwatch Hold"}, -- 1061
  {t="G", z=17, x=35.3, y=27.9, text="Seereth Stonebreak and Makaba Flathoof, at the Stonetalon road in the western Barrens", section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1062
  {t="A", q=1062, name="Goblin Invaders", z=17, x=35.26, y=27.88, target={kind="npc", id=4049, name="Seereth Stonebreak"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1063
  {t="A", q=6548, name="Avenge My Village", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1064
  {t="N", text="Follow the road west into Stonetalon to Windshear Crag", section="Stonetalon Mountains"}, -- 1065
  {t="G", z=406, x=59.0, y=62.6, text="Ziz Fizziks at Windshear Crag", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1066
  {t="A", q=1093, name="Super Reaper 6000", z=406, x=58.99, y=62.6, target={kind="npc", id=4201, name="Ziz Fizziks"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1067
  {t="C", q=1093, name="Super Reaper 6000", z=406, x=67.09, y=52.41, note="Super Reaper 6000 Blueprints from the Venture Co. operators", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1068
  {t="C", q=1062, name="Goblin Invaders", z=406, x=66.4, y=52.49, note="Venture Co. Loggers at Windshear Crag", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1069
  {t="T", q=1093, name="Super Reaper 6000", z=406, x=58.99, y=62.6, target={kind="npc", id=4201, name="Ziz Fizziks"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1070
  {t="C", q=6548, name="Avenge My Village", z=406, x=82.28, y=86.92, note="Grimtotem Ruffians and Mercenaries, south toward Malaka'jin", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1071
  {t="G", z=406, x=73.5, y=85.6, text="Kaya Flathoof, in the Grimtotem camp", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1072
  {t="A", q=6523, name="Protect Kaya", z=406, x=73.48, y=85.59, target={kind="npc", id=11856, name="Kaya Flathoof"}, section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1073
  {t="C", q=6523, name="Protect Kaya", z=406, x=77.1, y=90.85, note="Escort Kaya to Camp Aparaje", section="Stonetalon Mountains", zoneName="Stonetalon Mountains"}, -- 1074
  {t="G", z=17, x=35.3, y=27.9, text="Back to Seereth and Makaba at the Barrens edge", section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1075
  {t="T", q=1062, name="Goblin Invaders", z=17, x=35.26, y=27.88, target={kind="npc", id=4049, name="Seereth Stonebreak"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1076
  {t="T", q=6548, name="Avenge My Village", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1077
  {t="T", q=6523, name="Protect Kaya", z=17, x=35.19, y=27.76, target={kind="npc", id=11857, name="Makaba Flathoof"}, section="Stonetalon Mountains", zoneName="The Barrens"}, -- 1078
  {t="N", text="Ride back west through Windshear Crag to Sun Rock Retreat", section="Stonetalon Mountains"}, -- 1079
  {t="G", z=406, x=47.4, y=61.0, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1080
  {t="FP", z=406, x=45.1, y=59.8, text="Sun Rock Retreat flight path (Tharm)", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1081
  {t="SH", z=406, x=47.5, y=62.1, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1082
  {t="A", q=6421, name="Boulderslide Ravine", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1083
  {t="A", q=6301, name="Cycle of Rebirth", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1084
  {t="A", q=6562, name="Trouble in the Deeps", z=406, x=47.36, y=64.25, target={kind="npc", id=11862, name="Tsunaman"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1085
  {t="G", z=406, x=59.1, y=75.7, text="Wanted poster for Besseleth on the road", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1086
  {t="A", q=6284, name="Arachnophobia", z=406, x=59.06, y=75.71, target={kind="object", id=177904, name="Wanted Poster: Besseleth"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1087
  {t="C", q=6421, name="Boulderslide Ravine", z=406, x=59.63, y=91.49, note="Resonite crystals deep in the Boulderslide Ravine cave", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1088
  {t="C", q=6284, name="Arachnophobia", z=406, x=52.8, y=72.6, note="Besseleth, the spider at the Charred Vale road", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1089
  {t="C", q=6301, name="Cycle of Rebirth", z=406, x=48.05, y=39.76, note="Gaea Seeds in the Charred Vale", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1090
  {t="G", z=406, x=47.5, y=58.4, text="Back to Sun Rock", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1091
  {t="T", q=6421, name="Boulderslide Ravine", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1092
  {t="A", q=6481, name="Earthen Arise", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1093
  {t="T", q=6284, name="Arachnophobia", z=406, x=47.2, y=61.16, target={kind="npc", id=11860, name="Maggran Earthbinder"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1094
  {t="T", q=6301, name="Cycle of Rebirth", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1095
  {t="A", q=6381, name="New Life", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1096
  {t="C", q=6381, name="New Life", z=406, x=32.24, y=68.15, note="Plant the seeds in Gaea Dirt Mounds", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1097
  {t="G", z=406, x=57.6, y=89.5, text="Resonite Cask, Boulderslide Ravine", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1098
  {t="C", q=6481, name="Earthen Arise", z=406, x=57.4, y=89.4, note="Open the cask with the crystal and kill what comes out", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1099
  {t="G", z=406, x=47.5, y=58.4, text="Sun Rock Retreat", section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1100
  {t="T", q=6381, name="New Life", z=406, x=47.46, y=58.38, target={kind="npc", id=11864, name="Tammra Windfield"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1101
  {t="T", q=6481, name="Earthen Arise", z=406, x=47.22, y=64.04, target={kind="npc", id=11861, name="Mor'rogal"}, section="Sun Rock Retreat", zoneName="Stonetalon Mountains"}, -- 1102
  {t="N", text="Take the road north out of Sun Rock into Ashenvale and follow the coast to Zoram'gar", section="Zoram'gar Outpost (west Ashenvale)"}, -- 1103
  {t="G", z=331, x=11.6, y=34.3, text="Zoram'gar Outpost", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1104
  {t="FP", z=331, x=12.2, y=33.8, text="Zoram'gar flight path (Andruk)", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1105
  {t="T", q=6562, name="Trouble in the Deeps", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1106
  {t="A", q=6442, name="Naga at the Zoram Strand", z=331, x=11.69, y=34.91, target={kind="npc", id=12719, name="Marukai"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1107
  {t="A", q=216, name="Between a Rock and a Thistlefur", z=331, x=11.9, y=34.54, target={kind="npc", id=12757, name="Karang Amakkar"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1108
  {t="A", q=6462, name="Troll Charm", z=331, x=11.65, y=34.85, target={kind="npc", id=12721, name="Mitsuwa"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1109
  {t="A", q=6641, name="Vorsha the Lasher", z=331, x=12.06, y=34.63, target={kind="npc", id=12717, name="Muglash"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1110
  {t="C", q=6641, name="Vorsha the Lasher", z=331, x=9.59, y=27.58, note="Escort Muglash to the brazier and defend him", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1111
  {t="T", q=6641, name="Vorsha the Lasher", z=331, x=12.22, y=34.22, target={kind="npc", id=12863, name="Warsong Runner"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1112
  {t="C", q=6442, name="Naga at the Zoram Strand", z=331, x=14.08, y=20.86, note="Wrathtail naga along the Zoram Strand", section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1113
  {t="T", q=6442, name="Naga at the Zoram Strand", z=331, x=11.69, y=34.91, target={kind="npc", id=12719, name="Marukai"}, section="Zoram'gar Outpost (west Ashenvale)", zoneName="Ashenvale"}, -- 1114
  {t="A", q=6563, name="The Essence of Aku'Mai", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1115
  {t="A", q=6921, name="Amongst the Ruins", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1116
  {t="D", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", text="Blackfathom Deeps, at the north end of the Zoram Strand", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1117
  {t="A", q=6564, name="Allegiance to the Old Gods", z=331, x=13.55, y=12.06, target={kind="item", id=16790, name="Damp Note"}, note="The Damp Note drops inside", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1118
  {t="C", q=6563, name="The Essence of Aku'Mai", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", note="Sapphires of Aku'Mai from the crystal clusters", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1119
  {t="C", q=6921, name="Amongst the Ruins", z=331, x=14.5, y=14.2, instance=719, dungeonName="Blackfathom Deeps", note="The Fathom Core, in the first big chamber", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1120
  {t="G", z=331, x=11.6, y=34.3, text="Zoram'gar Outpost", section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1121
  {t="T", q=6563, name="The Essence of Aku'Mai", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1122
  {t="T", q=6921, name="Amongst the Ruins", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1123
  {t="T", q=6564, name="Allegiance to the Old Gods", z=331, x=11.56, y=34.29, target={kind="npc", id=12736, name="Je'neu Sancrea"}, section="Blackfathom Deeps (dungeon, group of 5)", zoneName="Ashenvale"}, -- 1124
  {t="C", q=216, name="Between a Rock and a Thistlefur", z=331, x=35.7, y=36.94, note="Thistlefur Avengers and Shaman at Thistlefur Village", section="Thistlefur Village", zoneName="Ashenvale"}, -- 1125
  {t="C", q=6462, name="Troll Charm", z=331, x=40.86, y=33.64, note="Troll Charms from Thistlefur furbolgs", section="Thistlefur Village", zoneName="Ashenvale"}, -- 1126
  {t="G", z=331, x=41.5, y=34.5, text="Ruul Snowhoof, in a cage at Thistlefur Village", section="Thistlefur Village", zoneName="Ashenvale"}, -- 1127
  {t="A", q=6482, name="Freedom to Ruul", z=331, x=41.53, y=34.49, target={kind="npc", id=12818, name="Ruul Snowhoof"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 1128
  {t="C", q=6482, name="Freedom to Ruul", z=331, x=38.53, y=37.32, note="Escort Ruul out of the furbolg camp", section="Thistlefur Village", zoneName="Ashenvale"}, -- 1129
  {t="G", z=331, x=11.9, y=34.5, text="Back to Zoram'gar", section="Thistlefur Village", zoneName="Ashenvale"}, -- 1130
  {t="T", q=216, name="Between a Rock and a Thistlefur", z=331, x=11.9, y=34.54, target={kind="npc", id=12757, name="Karang Amakkar"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 1131
  {t="T", q=6462, name="Troll Charm", z=331, x=11.65, y=34.85, target={kind="npc", id=12721, name="Mitsuwa"}, section="Thistlefur Village", zoneName="Ashenvale"}, -- 1132
  {t="F", text="The Crossroads", section="Thistlefur Village"}, -- 1133
  {t="TR", text="Train level 24 spells in Orgrimmar if you have not", section="Thistlefur Village"}, -- 1134
  {t="N", text="Run north from the Crossroads past Mor'shan Rampart into Ashenvale; Splintertree Post is just inside", section="Thistlefur Village"}, -- 1135
  {t="G", z=331, x=73.8, y=61.5, text="Splintertree Post", section="Splintertree Post", zoneName="Ashenvale"}, -- 1136
  {t="FP", z=331, x=73.2, y=61.6, text="Splintertree flight path (Vhulgra)", section="Splintertree Post", zoneName="Ashenvale"}, -- 1137
  {t="SH", z=331, x=74.0, y=60.7, text="Splintertree Post", section="Splintertree Post", zoneName="Ashenvale"}, -- 1138
  {t="T", q=6482, name="Freedom to Ruul", z=331, x=74.11, y=60.92, target={kind="npc", id=12837, name="Yama Snowhoof"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1139
  {t="A", q=6503, name="Ashenvale Outrunners", z=331, x=71.11, y=68.12, target={kind="npc", id=12867, name="Kuray'bin"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1140
  {t="A", q=6441, name="Satyr Horns", z=331, x=73.06, y=61.48, target={kind="npc", id=12724, name="Pixel"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1141
  {t="A", q=25, name="Stonetalon Standstill", z=331, x=73.67, y=60, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1142
  {t="C", q=6503, name="Ashenvale Outrunners", z=331, x=72.52, y=72.46, note="Ashenvale Outrunners in the woods south of the post", section="Splintertree Post", zoneName="Ashenvale"}, -- 1143
  {t="G", z=331, x=68.3, y=75.3, text="Torek, east of Silverwing Outpost", section="Splintertree Post", zoneName="Ashenvale"}, -- 1144
  {t="A", q=6544, name="Torek's Assault", z=331, x=68.34, y=75.3, target={kind="npc", id=12858, name="Torek"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1145
  {t="C", q=6544, name="Torek's Assault", z=331, x=64.65, y=75.35, note="Escort Torek's assault on Silverwing Outpost", section="Splintertree Post", zoneName="Ashenvale"}, -- 1146
  {t="T", q=6503, name="Ashenvale Outrunners", z=331, x=71.11, y=68.12, target={kind="npc", id=12867, name="Kuray'bin"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1147
  {t="T", q=6544, name="Torek's Assault", z=331, x=73.03, y=62.47, target={kind="npc", id=12877, name="Ertog Ragetusk"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1148
  {t="C", q=6441, name="Satyr Horns", z=331, x=79.54, y=50.12, note="Satyr Horns from the satyrs at Satyrnaar", section="Splintertree Post", zoneName="Ashenvale"}, -- 1149
  {t="C", q=25, name="Stonetalon Standstill", z=331, x=49.36, y=69.85, note="Befouled Water Elementals at Mystral Lake", section="Splintertree Post", zoneName="Ashenvale"}, -- 1150
  {t="A", q=1918, name="The Befouled Element", z=331, x=46, y=70, target={kind="item", id=16408, name="Befouled Water Globe"}, note="Befouled Water Globe drops from the elementals", section="Splintertree Post", zoneName="Ashenvale"}, -- 1151
  {t="G", z=331, x=73.7, y=60.0, text="Mastok Wrilehiss", section="Splintertree Post", zoneName="Ashenvale"}, -- 1152
  {t="T", q=25, name="Stonetalon Standstill", z=331, x=73.67, y=60, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1153
  {t="T", q=1918, name="The Befouled Element", z=331, x=73.67, y=60, target={kind="npc", id=12737, name="Mastok Wrilehiss"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1154
  {t="T", q=6441, name="Satyr Horns", z=331, x=73.06, y=61.48, target={kind="npc", id=12724, name="Pixel"}, section="Splintertree Post", zoneName="Ashenvale"}, -- 1155
  {t="F", text="Orgrimmar", section="To Hillsbrad Foothills"}, -- 1156
  {t="TR", text="Train level 24/26 spells", section="To Hillsbrad Foothills"}, -- 1157
  {t="N", text="Take the zeppelin from the tower outside Orgrimmar to Tirisfal Glades", section="To Hillsbrad Foothills"}, -- 1158
  {t="F", text="The Sepulcher", races={"undead"}, section="To Hillsbrad Foothills"}, -- 1159
  {t="G", z=130, x=42.8, y=40.9, text="Apothecary Renferrel at the Sepulcher", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 1160
  {t="FP", z=130, x=45.6, y=42.6, text="Sepulcher flight path (Karos Razok)", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 1161
  {t="A", q=493, name="Journey to Hillsbrad Foothills", z=130, x=42.8, y=40.86, target={kind="npc", id=1937, name="Apothecary Renferrel"}, section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 1162
  {t="A", q=1098, name="Deathstalkers in Shadowfang", z=130, x=43.42, y=40.86, target={kind="npc", id=1952, name="High Executor Hadrec"}, note="High Executor Hadrec", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 1163
  {t="A", q=1014, name="Arugal Must Die", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", section="To Hillsbrad Foothills", zoneName="Silverpine Forest"}, -- 1164
  {t="D", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", text="Shadowfang Keep, south Silverpine", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 1165
  {t="T", q=1098, name="Deathstalkers in Shadowfang", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", target={kind="npc", id=4444, name="Deathstalker Vincent"}, note="Deathstalker Vincent, just inside the courtyard", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 1166
  {t="C", q=1014, name="Arugal Must Die", z=130, x=44.8, y=67.8, instance=209, dungeonName="Shadowfang Keep", note="Archmage Arugal, final boss", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Silverpine Forest"}, -- 1167
  {t="G", z=267, x=20.8, y=47.4, text="Deathstalker Lesh on the Silverpine–Hillsbrad border road", section="Shadowfang Keep (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 1168
  {t="A", q=494, name="Time To Strike", z=267, x=20.79, y=47.4, target={kind="npc", id=2214, name="Deathstalker Lesh"}, section="Shadowfang Keep (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 1169
  {t="G", z=267, x=62.3, y=20.4, text="Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1170
  {t="FP", z=267, x=60.1, y=18.6, text="Tarren Mill flight path (Zarise)", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1171
  {t="SH", z=267, x=62.8, y=19.0, text="Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1172
  {t="T", q=493, name="Journey to Hillsbrad Foothills", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1173
  {t="T", q=494, name="Time To Strike", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1174
  {t="A", q=496, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1175
  {t="A", q=501, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1176
  {t="A", q=527, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1177
  {t="A", q=498, name="The Rescue", z=267, x=63.24, y=20.66, target={kind="npc", id=2229, name="Krusk"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1178
  {t="A", q=549, name="WANTED: Syndicate Personnel", z=267, x=62.63, y=20.75, target={kind="object", id=1763, name="WANTED"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1179
  {t="A", q=509, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1180
  {t="C", q=496, name="Elixir of Suffering", z=267, x=60.87, y=47.84, note="Gray Bear Tongues from bears and Creeper Ichor from the creeping vines", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1181
  {t="C", q=501, name="Elixir of Pain", z=267, x=54.31, y=42.94, note="Mountain Lion Blood from mountain lions", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1182
  {t="C", q=527, name="Battle of Hillsbrad", z=267, x=34.79, y=38.52, note="Hillsbrad farmers and farmhands, Farmer Ray and Farmer Getz at the western farms", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1183
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1184
  {t="T", q=496, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1185
  {t="A", q=499, name="Elixir of Suffering", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1186
  {t="T", q=499, name="Elixir of Suffering", z=267, x=61.55, y=19.14, target={kind="npc", id=2230, name="Umpi"}, note="Give the elixir to Umpi right next to Lydon", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1187
  {t="T", q=501, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1188
  {t="A", q=502, name="Elixir of Pain", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1189
  {t="T", q=527, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1190
  {t="A", q=528, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1191
  {t="A", q=546, name="Souvenirs of Death", z=267, x=62.11, y=19.7, target={kind="npc", id=2418, name="Deathguard Samsa"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1192
  {t="T", q=502, name="Elixir of Pain", z=267, x=32.66, y=35.32, target={kind="npc", id=2274, name="Stanley"}, note="Feed the Elixir of Pain to Stanley the dog at the farm", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1193
  {t="C", q=528, name="Battle of Hillsbrad", z=267, x=34.06, y=45.69, note="Hillsbrad Peasants in the fields", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1194
  {t="C", q=546, name="Souvenirs of Death", z=267, x=34.69, y=44.58, note="Hillsbrad Human Skulls from the humans around Hillsbrad", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1195
  {t="C", q=509, name="Elixir of Agony", z=267, x=64.56, y=61.25, note="Mudsnout Blossoms near the river south of Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1196
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1197
  {t="T", q=528, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1198
  {t="A", q=529, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1199
  {t="A", q=567, name="Dangerous!", z=267, x=62.56, y=19.66, target={kind="object", id=2008, name="Dangerous!"}, note="Dangerous! poster in Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1200
  {t="T", q=509, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1201
  {t="A", q=513, name="Elixir of Agony", z=267, x=61.44, y=19.06, target={kind="npc", id=2216, name="Apothecary Lydon"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1202
  {t="C", q=529, name="Battle of Hillsbrad", z=267, x=32.01, y=45.45, note="Blacksmith Verringtan and apprentices in Hillsbrad", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1203
  {t="C", q=546, name="Souvenirs of Death", z=267, x=34.69, y=44.58, note="Finish the skulls", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1204
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1205
  {t="T", q=529, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1206
  {t="T", q=546, name="Souvenirs of Death", z=267, x=62.11, y=19.7, target={kind="npc", id=2418, name="Deathguard Samsa"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1207
  {t="A", q=532, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1208
  {t="C", q=532, name="Battle of Hillsbrad", z=267, x=29.73, y=41.75, note="Magistrate Burnside and councilmen in the Hillsbrad town hall", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1209
  {t="C", q=567, name="Dangerous!", z=267, x=29.51, y=42.41, note="The four bounty targets: Clerk Horrace Whitesteed (town hall), Citizen Wilkes, Miner Hackett and Farmer Kalaba", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1210
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1211
  {t="T", q=532, name="Battle of Hillsbrad", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1212
  {t="T", q=567, name="Dangerous!", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Tarren Mill", zoneName="Hillsbrad Foothills"}, -- 1213
  {t="C", q=549, name="WANTED: Syndicate Personnel", z=267, x=78.19, y=44.45, note="Syndicate Rogues and Watchmen around Durnholde Keep", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 1214
  {t="C", q=498, name="The Rescue", z=267, x=79.49, y=40.57, note="Free Drull and Tog'thar inside Durnholde Keep", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 1215
  {t="G", z=267, x=62.3, y=20.4, text="Back to Tarren Mill", section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 1216
  {t="T", q=549, name="WANTED: Syndicate Personnel", z=267, x=62.33, y=20.45, target={kind="npc", id=2215, name="High Executor Darthalia"}, section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 1217
  {t="T", q=498, name="The Rescue", z=267, x=63.24, y=20.66, target={kind="npc", id=2229, name="Krusk"}, section="Durnholde Keep", zoneName="Hillsbrad Foothills"}, -- 1218
  {t="F", text="The Sepulcher", section="Durnholde Keep"}, -- 1219
  {t="T", q=1014, name="Arugal Must Die", z=130, x=44.2, y=39.81, target={kind="npc", id=1938, name="Dalar Dawnweaver"}, note="Dalar Dawnweaver", section="Durnholde Keep", zoneName="Silverpine Forest"}, -- 1220
  {t="F", text="Undercity", section="Durnholde Keep"}, -- 1221
  {t="T", q=513, name="Elixir of Agony", z=1497, x=48.82, y=69.28, target={kind="npc", id=2055, name="Master Apothecary Faranell"}, note="Master Apothecary Faranell in the Apothecarium", section="Durnholde Keep", zoneName="Undercity"}, -- 1222
  {t="TR", text="Train level 28 spells", section="Durnholde Keep"}, -- 1223
  {t="N", text="Take the zeppelin back to Orgrimmar", section="Durnholde Keep"}, -- 1224
  {t="F", text="Camp Taurajo", section="Thousand Needles"}, -- 1225
  {t="D", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", text="Razorfen Kraul, far south Barrens", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 1226
  {t="A", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", target={kind="npc", id=4508, name="Willix the Importer"}, note="Willix the Importer, held captive inside", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 1227
  {t="C", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", note="Escort Willix out", section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 1228
  {t="T", q=1144, name="Willix the Importer", z=17, x=42.9, y=90.2, instance=491, dungeonName="Razorfen Kraul", target={kind="npc", id=4508, name="Willix the Importer"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="The Barrens"}, -- 1229
  {t="N", text="Ride south-east through the Great Gate into Thousand Needles", section="Razorfen Kraul (dungeon, group of 5)"}, -- 1230
  {t="G", z=400, x=32.2, y=22.2, text="Brave Moonhorn at the bottom of the Great Lift", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1231
  {t="A", q=4542, name="Message to Freewind Post", z=400, x=32.24, y=22.17, target={kind="npc", id=10079, name="Brave Moonhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1232
  {t="G", z=400, x=45.7, y=50.7, text="Freewind Post (up the lift)", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1233
  {t="FP", z=400, x=45.1, y=49.1, text="Freewind Post flight path (Nyse)", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1234
  {t="SH", z=400, x=46.1, y=51.5, text="Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1235
  {t="T", q=4542, name="Message to Freewind Post", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1236
  {t="A", q=4841, name="Pacify the Centaur", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1237
  {t="A", q=4821, name="Alien Egg", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1238
  {t="A", q=4767, name="Wind Rider", z=400, x=44.93, y=48.92, target={kind="npc", id=10377, name="Elu"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1239
  {t="A", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=46, y=50.86, target={kind="object", id=176115, name="Wanted Poster - Arnak Grimtotem"}, note="Wanted poster for Arnak Grimtotem", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1240
  {t="C", q=4841, name="Pacify the Centaur", z=400, x=43.65, y=39.34, note="Galak Scouts, Wranglers and Windchasers", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1241
  {t="C", q=4821, name="Alien Egg", z=400, x=52.34, y=55.25, note="The Alien Egg in the Roguefeather Den area", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1242
  {t="G", z=400, x=45.7, y=50.7, text="Back to Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1243
  {t="T", q=4841, name="Pacify the Centaur", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1244
  {t="T", q=4821, name="Alien Egg", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1245
  {t="A", q=5064, name="Grimtotem Spying", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1246
  {t="A", q=4865, name="Serpent Wild", z=400, x=44.64, y=50.29, target={kind="npc", id=10539, name="Hagar Lightninghoof"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1247
  {t="C", q=5064, name="Grimtotem Spying", z=400, x=33.76, y=39.99, note="Three Secret Notes in Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1248
  {t="C", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=38.11, y=26.87, note="Arnak Grimtotem at Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1249
  {t="A", q=4881, name="Assassination Plot", z=400, x=39.43, y=33.1, target={kind="item", id=12564, name="Assassination Note"}, note="Assassination Note in Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1250
  {t="G", z=400, x=38.0, y=26.4, text="Lakota Windsong, at the top of Darkcloud Pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1251
  {t="A", q=4904, name="Free at Last", z=400, x=37.95, y=26.45, target={kind="npc", id=10646, name="Lakota Windsong"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1252
  {t="C", q=4904, name="Free at Last", z=400, x=30.93, y=37.12, note="Escort Lakota out of the pinnacle", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1253
  {t="G", z=400, x=21.5, y=32.4, text="Whitereach Post, west", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1254
  {t="T", q=4865, name="Serpent Wild", z=400, x=21.54, y=32.35, target={kind="npc", id=10428, name="Motega Firemane"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1255
  {t="T", q=4881, name="Assassination Plot", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1256
  {t="A", q=4966, name="Protect Kanati Greycloud", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1257
  {t="C", q=4966, name="Protect Kanati Greycloud", z=400, x=21.26, y=31.81, note="Defend Kanati Greycloud from the centaur attack", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1258
  {t="T", q=4966, name="Protect Kanati Greycloud", z=400, x=21.25, y=32.06, target={kind="npc", id=10638, name="Kanati Greycloud"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1259
  {t="A", q=5151, name="Hypercapacitor Gizmo", z=400, x=21.43, y=32.55, target={kind="npc", id=10941, name="Wizlo Bearingshiner"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1260
  {t="C", q=5151, name="Hypercapacitor Gizmo", z=400, x=22.76, y=24.62, note="The panther cage and the Hypercapacitor Gizmo north of Whitereach", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1261
  {t="T", q=5151, name="Hypercapacitor Gizmo", z=400, x=21.43, y=32.55, target={kind="npc", id=10941, name="Wizlo Bearingshiner"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1262
  {t="C", q=4767, name="Wind Rider", z=400, x=11.56, y=37.11, note="Highperch Wyvern Eggs at Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1263
  {t="G", z=400, x=17.9, y=40.6, text="Pao'ka Swiftmountain at Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1264
  {t="A", q=4770, name="Homeward Bound", z=400, x=17.89, y=40.57, target={kind="npc", id=10427, name="Pao'ka Swiftmountain"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1265
  {t="C", q=4770, name="Homeward Bound", z=400, x=15.15, y=32.65, note="Escort Pao'ka out of Highperch", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1266
  {t="T", q=4770, name="Homeward Bound", z=400, x=21.54, y=32.35, target={kind="npc", id=10428, name="Motega Firemane"}, note="Motega Firemane at Whitereach Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1267
  {t="G", z=400, x=45.7, y=50.7, text="Freewind Post", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1268
  {t="T", q=5064, name="Grimtotem Spying", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1269
  {t="T", q=5147, name="Wanted - Arnak Grimtotem", z=400, x=45.67, y=50.74, target={kind="npc", id=10537, name="Cliffwatcher Longhorn"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1270
  {t="T", q=4904, name="Free at Last", z=400, x=45.97, y=51.61, target={kind="npc", id=10645, name="Thalia Amberhide"}, note="Thalia Amberhide", section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1271
  {t="T", q=4767, name="Wind Rider", z=400, x=44.93, y=48.92, target={kind="npc", id=10377, name="Elu"}, section="Razorfen Kraul (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1272
  {t="G", z=400, x=78.1, y=77.1, text="Mirage Raceway, Shimmering Flats", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1273
  {t="A", q=1104, name="Salt Flat Venom", z=400, x=78.06, y=77.13, target={kind="npc", id=4454, name="Fizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1274
  {t="A", q=1105, name="Hardened Shells", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1275
  {t="A", q=1110, name="Rocket Car Parts", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1276
  {t="A", q=1176, name="Load Lightening", z=400, x=80.18, y=75.88, target={kind="npc", id=4630, name="Pozzik"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1277
  {t="A", q=1175, name="A Bump in the Road", z=400, x=81.63, y=77.95, target={kind="npc", id=4629, name="Trackmaster Zherin"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1278
  {t="A", q=5762, name="Hemet Nesingwary", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1279
  {t="C", q=1104, name="Salt Flat Venom", z=400, x=75.47, y=67.77, note="Salty Scorpid Venoms from scorpids", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1280
  {t="C", q=1105, name="Hardened Shells", z=400, x=83.77, y=60.74, note="Hardened Tortoise Shells from tortoises", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1281
  {t="C", q=1110, name="Rocket Car Parts", z=400, x=73.21, y=68.65, note="Rocket Car Parts lie all over the salt flats", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1282
  {t="C", q=1176, name="Load Lightening", z=400, x=82.99, y=70.69, note="Hollow Vulture Bones from vultures", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1283
  {t="C", q=1175, name="A Bump in the Road", z=400, x=73.81, y=76.19, note="Saltstone basilisks", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1284
  {t="G", z=400, x=78.1, y=77.1, text="Back to the Mirage Raceway", section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1285
  {t="T", q=1104, name="Salt Flat Venom", z=400, x=78.06, y=77.13, target={kind="npc", id=4454, name="Fizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1286
  {t="T", q=1105, name="Hardened Shells", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1287
  {t="T", q=1110, name="Rocket Car Parts", z=400, x=77.79, y=77.27, target={kind="npc", id=4452, name="Kravel Koalbeard"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1288
  {t="T", q=1176, name="Load Lightening", z=400, x=80.18, y=75.88, target={kind="npc", id=4630, name="Pozzik"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1289
  {t="T", q=1175, name="A Bump in the Road", z=400, x=81.63, y=77.95, target={kind="npc", id=4629, name="Trackmaster Zherin"}, section="The Shimmering Flats", zoneName="Thousand Needles"}, -- 1290
  {t="F", text="Orgrimmar", section="The Shimmering Flats"}, -- 1291
  {t="TR", text="Train level 30 spells", section="The Shimmering Flats"}, -- 1292
  {t="N", text="Take the zeppelin from the tower outside Orgrimmar to Grom'gol Base Camp", section="Northern Stranglethorn Vale"}, -- 1293
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1294
  {t="FP", z=33, x=32.5, y=29.4, text="Grom'gol flight path (Thysta)", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1295
  {t="SH", z=33, x=31.5, y=29.8, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1296
  {t="G", z=33, x=35.7, y=10.5, text="Nesingwary's Expedition, north along the road", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1297
  {t="T", q=5762, name="Hemet Nesingwary", z=33, x=35.66, y=10.81, target={kind="npc", id=715, name="Hemet Nesingwary"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1298
  {t="A", q=583, name="Welcome to the Jungle", z=33, x=35.66, y=10.53, target={kind="npc", id=716, name="Barnil Stonepot"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1299
  {t="T", q=583, name="Welcome to the Jungle", z=33, x=35.66, y=10.81, target={kind="npc", id=715, name="Hemet Nesingwary"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1300
  {t="A", q=185, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1301
  {t="A", q=190, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1302
  {t="C", q=185, name="Tiger Mastery", z=33, x=35.65, y=12.14, note="Young Stranglethorn Tigers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1303
  {t="C", q=190, name="Panther Mastery", z=33, x=41.35, y=12.82, note="Young Panthers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1304
  {t="G", z=33, x=35.6, y=10.6, text="Back to Nesingwary's camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1305
  {t="T", q=185, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1306
  {t="T", q=190, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1307
  {t="A", q=186, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1308
  {t="A", q=191, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1309
  {t="C", q=191, name="Panther Mastery", z=33, x=30.4, y=12.4, note="Panthers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1310
  {t="C", q=186, name="Tiger Mastery", z=33, x=37.4, y=12.8, note="Stranglethorn Tigers", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1311
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1312
  {t="T", q=186, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1313
  {t="T", q=191, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1314
  {t="G", z=33, x=32.2, y=27.7, text="Grom'gol Base Camp", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1315
  {t="A", q=638, name="Trollbane", z=33, x=32.16, y=27.72, target={kind="npc", id=2497, name="Nimboya"}, note="Nimboya: Trollbane, a breadcrumb to Hammerfall", section="Northern Stranglethorn Vale", zoneName="Stranglethorn Vale"}, -- 1316
  {t="N", text="Take the zeppelin from Grom'gol to Undercity", section="Northern Stranglethorn Vale"}, -- 1317
  {t="F", text="Tarren Mill", section="Hillsbrad and on to Arathi"}, -- 1318
  {t="A", q=676, name="The Hammer May Fall", z=267, x=61.87, y=19.57, target={kind="npc", id=2770, name="Tallow"}, note="Tallow, by the Tarren Mill stables", section="Hillsbrad and on to Arathi", zoneName="Hillsbrad Foothills"}, -- 1319
  {t="N", text="Ride east out of Hillsbrad through Thoradin's Wall into Arathi Highlands", section="Hillsbrad and on to Arathi"}, -- 1320
  {t="C", q=676, name="The Hammer May Fall", z=45, x=33.58, y=44.59, note="Boulderfist ogres in western Arathi on the way", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1321
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1322
  {t="FP", z=45, x=73.0, y=32.7, text="Hammerfall flight path (Urda)", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1323
  {t="SH", z=45, x=73.8, y=32.6, text="Hammerfall", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1324
  {t="T", q=676, name="The Hammer May Fall", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1325
  {t="A", q=677, name="Call to Arms", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1326
  {t="T", q=638, name="Trollbane", z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, note="Zengu", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1327
  {t="A", q=639, name="Sigil of Strom", group=true, z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, note="Group quest: Stromgarde elites", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1328
  {t="G", z=45, x=72.6, y=33.9, text="Gor'mul", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1329
  {t="A", q=655, name="Hammerfall", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1330
  {t="T", q=655, name="Hammerfall", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1331
  {t="A", q=672, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1332
  {t="A", q=671, name="Foul Magics", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1333
  {t="C", q=672, name="Raising Spirits", z=45, x=41.03, y=44.8, note="Highland Raptor Eyes from Highland Striders and Thrashers", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1334
  {t="C", q=671, name="Foul Magics", z=45, x=32.27, y=28.3, note="Bloodstone Amulets from the Syndicate at Northfold Manor", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1335
  {t="G", z=45, x=74.7, y=36.3, text="Back to Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1336
  {t="T", q=672, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1337
  {t="A", q=674, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1338
  {t="T", q=674, name="Raising Spirits", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, note="Gor'mul", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1339
  {t="A", q=675, name="Raising Spirits", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1340
  {t="T", q=675, name="Raising Spirits", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1341
  {t="A", q=701, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1342
  {t="T", q=671, name="Foul Magics", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Hillsbrad and on to Arathi", zoneName="Arathi Highlands"}, -- 1343
  {t="C", q=677, name="Call to Arms", z=45, x=69.03, y=71.98, note="Witherbark trolls in the southeast", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1344
  {t="C", q=701, name="Guile of the Raptor", z=45, x=49.61, y=69.12, note="Raptor Hearts from Highland Fleshstalkers", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1345
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1346
  {t="T", q=677, name="Call to Arms", z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1347
  {t="A", q=678, name="Call to Arms", group=true, z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, note="Group quest: Boulderfist Hall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1348
  {t="T", q=701, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1349
  {t="A", q=702, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1350
  {t="T", q=702, name="Guile of the Raptor", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, note="Gor'mul", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1351
  {t="A", q=847, name="Guile of the Raptor", z=45, x=72.64, y=33.93, target={kind="npc", id=2792, name="Gor'mul"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1352
  {t="T", q=847, name="Guile of the Raptor", z=45, x=74.72, y=36.29, target={kind="npc", id=2706, name="Tor'gan"}, note="Tor'gan", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1353
  {t="C", q=678, name="Call to Arms", group=true, z=45, x=53.1, y=75.93, note="Boulderfist Brutes and Magi in Boulderfist Hall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1354
  {t="C", q=639, name="Sigil of Strom", group=true, z=45, x=28.33, y=63.36, note="The Sigil of Strom from the Stromgarde defenders", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1355
  {t="G", z=45, x=74.2, y=33.9, text="Hammerfall", section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1356
  {t="T", q=678, name="Call to Arms", group=true, z=45, x=74.24, y=33.92, target={kind="npc", id=2771, name="Drum Fel"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1357
  {t="T", q=639, name="Sigil of Strom", group=true, z=45, x=73.8, y=33.96, target={kind="npc", id=2703, name="Zengu"}, section="Southern Arathi", zoneName="Arathi Highlands"}, -- 1358
  {t="F", text="Undercity", section="Desolace"}, -- 1359
  {t="N", text="Zeppelin to Orgrimmar, then fly to the Crossroads", section="Desolace"}, -- 1360
  {t="F", text="The Crossroads", section="Desolace"}, -- 1361
  {t="TR", text="Train level 34/36 spells in Orgrimmar or Thunder Bluff on the way", section="Desolace"}, -- 1362
  {t="G", z=17, x=45.3, y=28.4, text="Regthar Deathgate, west of the Crossroads", section="Desolace", zoneName="The Barrens"}, -- 1363
  {t="A", q=1362, name="The Kolkar of Desolace", z=17, x=45.34, y=28.41, target={kind="npc", id=3389, name="Regthar Deathgate"}, section="Desolace", zoneName="The Barrens"}, -- 1364
  {t="F", text="Sun Rock Retreat", section="Desolace"}, -- 1365
  {t="N", text="Ride south out of Stonetalon on the road into Desolace", section="Desolace"}, -- 1366
  {t="G", z=405, x=56.2, y=59.6, text="Ghost Walker Post", section="Desolace", zoneName="Desolace"}, -- 1367
  {t="T", q=1362, name="The Kolkar of Desolace", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 1368
  {t="A", q=1365, name="Khan Dez'hepah", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 1369
  {t="A", q=5386, name="Catch of the Day", z=405, x=55.41, y=55.81, target={kind="npc", id=11259, name="Nataka Longhorn"}, section="Desolace", zoneName="Desolace"}, -- 1370
  {t="G", z=405, x=60.9, y=61.9, text="Smeed Scrabblescrew at the Kodo Graveyard", section="Desolace", zoneName="Desolace"}, -- 1371
  {t="A", q=5561, name="Kodo Roundup", z=405, x=60.86, y=61.86, target={kind="npc", id=11596, name="Smeed Scrabblescrew"}, section="Desolace", zoneName="Desolace"}, -- 1372
  {t="G", z=405, x=52.0, y=56.1, text="Aged Kodos wander the Kodo Graveyard", section="Desolace", zoneName="Desolace"}, -- 1373
  {t="C", q=5561, name="Kodo Roundup", z=405, x=51.41, y=58.29, note="Use the Kodo Kombobulator on Aged Kodos and lead 5 back to Smeed", section="Desolace", zoneName="Desolace"}, -- 1374
  {t="T", q=5561, name="Kodo Roundup", z=405, x=60.86, y=61.86, target={kind="npc", id=11596, name="Smeed Scrabblescrew"}, section="Desolace", zoneName="Desolace"}, -- 1375
  {t="C", q=1365, name="Khan Dez'hepah", z=405, x=74.4, y=44.8, note="Khan Dez'hepah at the Magram village", section="Desolace", zoneName="Desolace"}, -- 1376
  {t="A", q=1480, name="The Corrupter", z=405, x=55.14, y=28.62, target={kind="item", id=20310, name="Flayed Demon Skin"}, note="The Flayed Demon Skin drops from the satyrs", section="Desolace", zoneName="Desolace"}, -- 1377
  {t="G", z=405, x=56.2, y=59.6, text="Back to Ghost Walker Post", section="Desolace", zoneName="Desolace"}, -- 1378
  {t="T", q=1365, name="Khan Dez'hepah", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 1379
  {t="A", q=1366, name="Centaur Bounty", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Desolace", zoneName="Desolace"}, -- 1380
  {t="T", q=1480, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Desolace", zoneName="Desolace"}, -- 1381
  {t="A", q=1481, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Desolace", zoneName="Desolace"}, -- 1382
  {t="G", z=405, x=21.6, y=74.1, text="Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1383
  {t="FP", z=405, x=21.6, y=74.1, text="Shadowprey flight path (Thalon)", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1384
  {t="SH", z=405, x=24.1, y=68.2, text="Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1385
  {t="A", q=6142, name="Clam Bait", z=405, x=22.64, y=71.97, target={kind="npc", id=12031, name="Mai'Lahii"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1386
  {t="A", q=6143, name="Other Fish to Fry", z=405, x=23.32, y=72.87, target={kind="npc", id=12340, name="Drulzegar Skraghook"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1387
  {t="G", z=405, x=22.4, y=73.1, text="Jinar'Zillen", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1388
  {t="C", q=5386, name="Catch of the Day", z=405, x=22.45, y=73.12, note="Talk to Jinar'Zillen by the water; he gives you the fish to bring back", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1389
  {t="C", q=6143, name="Other Fish to Fry", z=405, x=33.75, y=22.38, note="Slitherblade naga on the northwest coast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1390
  {t="C", q=6142, name="Clam Bait", z=405, x=33.22, y=30.39, note="Soft-shelled Clam Meat from clams on the same coast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1391
  {t="G", z=405, x=23.3, y=72.9, text="Back to Shadowprey Village", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1392
  {t="T", q=6142, name="Clam Bait", z=405, x=22.64, y=71.97, target={kind="npc", id=12031, name="Mai'Lahii"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1393
  {t="T", q=6143, name="Other Fish to Fry", z=405, x=23.32, y=72.87, target={kind="npc", id=12340, name="Drulzegar Skraghook"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1394
  {t="C", q=1366, name="Centaur Bounty", z=405, x=36.66, y=79.2, note="Centaur Ears from any Kolkar, Gelkis or Magram centaurs", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1395
  {t="C", q=1481, name="The Corrupter", z=405, x=75.33, y=21.26, note="Shadowstalker Scalp from the satyr Shadowstalkers in the northeast", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1396
  {t="G", z=405, x=56.2, y=59.6, text="Ghost Walker Post", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1397
  {t="T", q=1366, name="Centaur Bounty", z=405, x=56.19, y=59.57, target={kind="npc", id=5395, name="Felgur Twocuts"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1398
  {t="T", q=1481, name="The Corrupter", z=405, x=52.25, y=53.44, target={kind="npc", id=4498, name="Maurin Bonesplitter"}, section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1399
  {t="T", q=5386, name="Catch of the Day", z=405, x=55.41, y=55.81, target={kind="npc", id=11259, name="Nataka Longhorn"}, note="Nataka Longhorn", section="Western Desolace and Shadowprey Village", zoneName="Desolace"}, -- 1400
  {t="H", text="Shadowprey Village", section="Western Desolace and Shadowprey Village"}, -- 1401
  {t="F", text="The Crossroads", section="Western Desolace and Shadowprey Village"}, -- 1402
  {t="N", text="Ride south from the Crossroads through the southern Barrens border into Dustwallow, or fly to Ratchet and follow the road south", section="Dustwallow Marsh"}, -- 1403
  {t="G", z=15, x=36.4, y=31.9, text="Brackenwall Village", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1404
  {t="FP", z=15, x=35.6, y=31.9, text="Brackenwall flight path (Shardi)", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1405
  {t="N", text="Brackenwall has no inn; keep your hearthstone where it is", section="Dustwallow Marsh"}, -- 1406
  {t="A", q=1201, name="Theramore Spies", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1407
  {t="A", q=1177, name="Hungry!", z=15, x=35.15, y=38.26, target={kind="npc", id=4503, name="Mudcrush Durtfeet"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1408
  {t="C", q=1201, name="Theramore Spies", z=15, x=38.95, y=26.4, note="Theramore Infiltrators around Brackenwall (they are stealthed)", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1409
  {t="G", z=15, x=29.7, y=47.6, text="The burned Shady Rest Inn", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1410
  {t="A", q=1268, name="Suspicious Hoofprints", z=15, x=29.7, y=47.64, target={kind="object", id=21015, name="Hoofprints"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1411
  {t="A", q=1251, name="The Black Shield", z=15, x=29.63, y=48.62, target={kind="object", id=20992, name="Black Shield"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1412
  {t="A", q=1269, name="Lieutenant Paval Reethe", z=15, x=29.83, y=48.24, target={kind="object", id=21042, name="Theramore Guard Badge"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1413
  {t="G", z=15, x=55.4, y=25.9, text="Loose Dirt, at the burned Horde camp in the north", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1414
  {t="A", q=1238, name="The Lost Report", z=15, x=55.44, y=25.92, target={kind="object", id=20985, name="Loose Dirt"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1415
  {t="C", q=1177, name="Hungry!", z=15, x=58.36, y=15.33, note="Mirefin murlocs for heads", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1416
  {t="G", z=15, x=46.9, y=17.5, text="Stinky Ignatz, near the north road", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1417
  {t="A", q=1270, name="Stinky's Escape", z=15, x=46.88, y=17.52, target={kind="npc", id=4880, name="\"Stinky\" Ignatz"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1418
  {t="C", q=1270, name="Stinky's Escape", z=15, x=48.87, y=24.58, note="Escort Stinky", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1419
  {t="G", z=15, x=36.4, y=31.9, text="Brackenwall Village", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1420
  {t="T", q=1201, name="Theramore Spies", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1421
  {t="T", q=1177, name="Hungry!", z=15, x=35.15, y=38.26, target={kind="npc", id=4503, name="Mudcrush Durtfeet"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1422
  {t="T", q=1238, name="The Lost Report", z=15, x=35.21, y=30.66, target={kind="npc", id=4791, name="Nazeer Bloodpike"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1423
  {t="T", q=1268, name="Suspicious Hoofprints", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1424
  {t="T", q=1251, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1425
  {t="A", q=1321, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1426
  {t="T", q=1321, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, note="Do'gol", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1427
  {t="A", q=1322, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1428
  {t="T", q=1269, name="Lieutenant Paval Reethe", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1429
  {t="A", q=1273, name="Questioning Reethe", z=15, x=40.96, y=36.69, target={kind="npc", id=4983, name="Ogron"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1430
  {t="C", q=1273, name="Questioning Reethe", z=15, x=42.47, y=38.07, note="Follow Ogron and speak with Reethe", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1431
  {t="T", q=1273, name="Questioning Reethe", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1432
  {t="C", q=1322, name="The Black Shield", z=15, x=46.92, y=45.49, note="Acidic Venom Sacs from the spiders", section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1433
  {t="T", q=1322, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1434
  {t="A", q=1323, name="The Black Shield", z=15, x=36.53, y=30.79, target={kind="npc", id=5087, name="Do'gol"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1435
  {t="T", q=1323, name="The Black Shield", z=15, x=36.42, y=31.88, target={kind="npc", id=4926, name="Krog"}, section="Dustwallow Marsh", zoneName="Dustwallow Marsh"}, -- 1436
  {t="F", text="Ratchet", section="Dustwallow Marsh"}, -- 1437
  {t="T", q=1270, name="Stinky's Escape", z=17, x=62.37, y=37.62, target={kind="npc", id=3446, name="Mebok Mizzyrix"}, section="Dustwallow Marsh", zoneName="The Barrens"}, -- 1438
  {t="F", text="Camp Taurajo", section="Razorfen Downs (dungeon, group of 5)"}, -- 1439
  {t="N", text="Ride south to the bramble mound just north of Thousand Needles", section="Razorfen Downs (dungeon, group of 5)"}, -- 1440
  {t="G", z=17, x=49.0, y=94.9, text="Myriam Moonsinger outside Razorfen Downs", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1441
  {t="A", q=6626, name="A Host of Evil", z=17, x=49.01, y=94.94, target={kind="npc", id=12866, name="Myriam Moonsinger"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1442
  {t="C", q=6626, name="A Host of Evil", z=17, x=49.0, y=93.9, note="Razorfen Battleguards, Thornweavers and Death's Head Cultists around the entrance", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1443
  {t="T", q=6626, name="A Host of Evil", z=17, x=49.01, y=94.94, target={kind="npc", id=12866, name="Myriam Moonsinger"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1444
  {t="D", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", text="Razorfen Downs", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1445
  {t="A", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, note="Belnistrasz, just inside", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1446
  {t="C", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", note="Agree to help, then hand him the Oathstone", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1447
  {t="T", q=3523, name="Scourge of the Downs", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1448
  {t="A", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="npc", id=8516, name="Belnistrasz"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1449
  {t="C", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", note="Defend Belnistrasz at the quilboar idol", section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1450
  {t="T", q=3525, name="Extinguishing the Idol", z=17, x=49.0, y=93.9, instance=722, dungeonName="Razorfen Downs", target={kind="object", id=152097, name="Belnistrasz's Brazier"}, section="Razorfen Downs (dungeon, group of 5)", zoneName="The Barrens"}, -- 1451
  {t="F", text="Orgrimmar", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1452
  {t="TR", text="Train level 38 spells", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1453
  {t="N", text="Take the zeppelin to Tirisfal Glades and walk into Undercity", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1454
  {t="G", z=1497, x=56.2, y=92.2, text="Varimathras in the Royal Quarter", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1455
  {t="A", q=1048, name="Into The Scarlet Monastery", z=1497, x=56.25, y=92.2, target={kind="npc", id=2425, name="Varimathras"}, section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1456
  {t="D", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", text="Scarlet Monastery, north-east Tirisfal Glades (Graveyard, Library, Armory, Cathedral)", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1457
  {t="A", q=1051, name="Vorrel's Revenge", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", target={kind="npc", id=3981, name="Vorrel Sengutz"}, note="Vorrel Sengutz, in the Graveyard wing", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1458
  {t="C", q=1051, name="Vorrel's Revenge", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", note="Vorrel's wedding ring", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1459
  {t="C", q=1048, name="Into The Scarlet Monastery", z=85, x=82.6, y=33.8, instance=796, dungeonName="Scarlet Monastery", note="Whitemane, Mograine, Herod and Houndmaster Loksey", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Tirisfal Glades"}, -- 1460
  {t="G", z=1497, x=56.2, y=92.2, text="Varimathras", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1461
  {t="T", q=1048, name="Into The Scarlet Monastery", z=1497, x=56.25, y=92.2, target={kind="npc", id=2425, name="Varimathras"}, section="Scarlet Monastery (dungeon, group of 5)", zoneName="Undercity"}, -- 1462
  {t="F", text="Tarren Mill", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1463
  {t="T", q=1051, name="Vorrel's Revenge", z=267, x=62.67, y=18.88, target={kind="npc", id=3982, name="Monika Sengutz"}, note="Monika Sengutz", section="Scarlet Monastery (dungeon, group of 5)", zoneName="Hillsbrad Foothills"}, -- 1464
  {t="N", text="Fly to Undercity and take the zeppelin to Grom'gol", section="Scarlet Monastery (dungeon, group of 5)"}, -- 1465
  {t="N", text="From Grom'gol ride south along the road to Booty Bay", section="Booty Bay"}, -- 1466
  {t="G", z=33, x=27.2, y=77.0, text="Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1467
  {t="FP", z=33, x=26.9, y=77.1, text="Booty Bay flight path (Gringer)", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1468
  {t="SH", z=33, x=27.0, y=77.3, text="Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1469
  {t="A", q=595, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1470
  {t="A", q=605, name="Singing Blue Shards", z=33, x=27.12, y=77.21, target={kind="npc", id=2498, name="Crank Fizzlebub"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1471
  {t="A", q=575, name="Supply and Demand", z=33, x=28.29, y=77.59, target={kind="npc", id=2495, name="Drizzlik"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1472
  {t="A", q=213, name="Hostile Takeover", z=33, x=27, y=77.13, target={kind="npc", id=737, name="Kebok"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1473
  {t="A", q=617, name="Akiris by the Bundle", z=33, x=26.76, y=76.38, target={kind="npc", id=2494, name="Privateer Bloads"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1474
  {t="G", z=33, x=27.3, y=69.5, text="The Bloodsail cove north of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1475
  {t="T", q=595, name="The Bloodsail Buccaneers", z=33, x=27.28, y=69.52, target={kind="object", id=2083, name="Bloodsail Correspondence"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1476
  {t="A", q=597, name="The Bloodsail Buccaneers", z=33, x=27.28, y=69.52, target={kind="object", id=2083, name="Bloodsail Correspondence"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1477
  {t="C", q=617, name="Akiris by the Bundle", z=33, x=24.69, y=61.46, note="Akiris Reed along the coast north of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1478
  {t="G", z=33, x=28.1, y=76.2, text="First Mate Crazz in Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1479
  {t="T", q=597, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1480
  {t="A", q=599, name="The Bloodsail Buccaneers", z=33, x=28.1, y=76.22, target={kind="npc", id=2490, name="First Mate Crazz"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1481
  {t="T", q=599, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, note="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1482
  {t="A", q=604, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1483
  {t="C", q=604, name="The Bloodsail Buccaneers", z=33, x=26.96, y=82.5, note="Bloodsail Swashbucklers on the coast south of Booty Bay", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1484
  {t="G", z=33, x=27.2, y=77.0, text="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1485
  {t="T", q=604, name="The Bloodsail Buccaneers", z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1486
  {t="T", q=617, name="Akiris by the Bundle", z=33, x=26.76, y=76.38, target={kind="npc", id=2494, name="Privateer Bloads"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1487
  {t="A", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, note="Group quest", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1488
  {t="C", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=29.32, y=88.29, note="Captain Stillwater, Fleet Master Firallon and Captain Keelhaul on the Bloodsail ships", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1489
  {t="G", z=33, x=27.2, y=77.0, text="Fleet Master Seahorn", section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1490
  {t="T", q=608, name="The Bloodsail Buccaneers", group=true, z=33, x=27.17, y=77.01, target={kind="npc", id=2487, name="Fleet Master Seahorn"}, section="Booty Bay", zoneName="Stranglethorn Vale"}, -- 1491
  {t="C", q=605, name="Singing Blue Shards", z=33, x=36.99, y=41.74, note="Singing Crystal Shards from the basilisks near the Crystalvein Mine", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1492
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1493
  {t="A", q=568, name="The Defense of Grom'gol", z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1494
  {t="A", q=570, name="Mok'thardin's Enchantment", z=33, x=32.12, y=29.24, target={kind="npc", id=2465, name="Far Seer Mok'thardin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1495
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's Expedition", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1496
  {t="A", q=187, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1497
  {t="A", q=192, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1498
  {t="C", q=187, name="Tiger Mastery", z=33, x=33.53, y=18.31, note="Elder Stranglethorn Tigers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1499
  {t="C", q=575, name="Supply and Demand", z=33, x=36.85, y=10.51, note="Large River Crocolisks along the river", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1500
  {t="C", q=213, name="Hostile Takeover", z=33, x=44.23, y=20.09, note="Tumbled Crystals from the Venture Co. at the northern mine", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1501
  {t="C", q=568, name="The Defense of Grom'gol", z=33, x=33.4, y=24.55, note="Lashtail Raptors and Jungle Stalkers around Grom'gol", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1502
  {t="C", q=192, name="Panther Mastery", z=33, x=41.3, y=34.76, note="Shadowmaw Panthers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1503
  {t="C", q=570, name="Mok'thardin's Enchantment", z=33, x=39.59, y=35.55, note="Shadowmaw Claws from the same panthers", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1504
  {t="G", z=33, x=35.6, y=10.6, text="Nesingwary's Expedition", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1505
  {t="T", q=187, name="Tiger Mastery", z=33, x=35.62, y=10.62, target={kind="npc", id=717, name="Ajeck Rouack"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1506
  {t="T", q=192, name="Panther Mastery", z=33, x=35.55, y=10.55, target={kind="npc", id=718, name="Sir S. J. Erlgadin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1507
  {t="G", z=33, x=32.2, y=28.9, text="Grom'gol Base Camp", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1508
  {t="T", q=568, name="The Defense of Grom'gol", z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1509
  {t="A", q=569, name="The Defense of Grom'gol", group=true, z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, note="Group quest", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1510
  {t="T", q=570, name="Mok'thardin's Enchantment", z=33, x=32.12, y=29.24, target={kind="npc", id=2465, name="Far Seer Mok'thardin"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1511
  {t="C", q=569, name="The Defense of Grom'gol", group=true, z=33, x=37.17, y=30.81, note="Mosh'Ogg ogres east of Grom'gol (elites)", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1512
  {t="G", z=33, x=32.2, y=28.9, text="Commander Aggro'gosh", section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1513
  {t="T", q=569, name="The Defense of Grom'gol", group=true, z=33, x=32.17, y=28.9, target={kind="npc", id=2464, name="Commander Aggro'gosh"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1514
  {t="F", text="Booty Bay", section="Northern loop"}, -- 1515
  {t="T", q=605, name="Singing Blue Shards", z=33, x=27.12, y=77.21, target={kind="npc", id=2498, name="Crank Fizzlebub"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1516
  {t="T", q=575, name="Supply and Demand", z=33, x=28.29, y=77.59, target={kind="npc", id=2495, name="Drizzlik"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1517
  {t="T", q=213, name="Hostile Takeover", z=33, x=27, y=77.13, target={kind="npc", id=737, name="Kebok"}, section="Northern loop", zoneName="Stranglethorn Vale"}, -- 1518
  {t="F", text="Grom'gol Base Camp", section="Swamp of Sorrows"}, -- 1519
  {t="N", text="Ride north from Grom'gol through Duskwood and Deadwind Pass into the Swamp of Sorrows (watch for Alliance in Duskwood)", section="Swamp of Sorrows"}, -- 1520
  {t="G", z=8, x=45.2, y=56.7, text="Stonard", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1521
  {t="FP", z=8, x=46.1, y=54.8, text="Stonard flight path (Breyk)", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1522
  {t="SH", z=8, x=45.2, y=56.7, text="Stonard", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1523
  {t="A", q=698, name="Lack of Surplus", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1524
  {t="A", q=1424, name="Pool of Tears", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1525
  {t="A", q=1430, name="Fresh Meat", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1526
  {t="TR", text="Train level 40/42 spells; buy your level 40 mount in Orgrimmar, Thunder Bluff or Undercity if you have the gold", section="Swamp of Sorrows"}, -- 1527
  {t="G", z=8, x=65.5, y=18.2, text="Galen Goodward, caged in the northeast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1528
  {t="A", q=1393, name="Galen's Escape", z=8, x=65.47, y=18.16, target={kind="npc", id=5391, name="Galen Goodward"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1529
  {t="C", q=1393, name="Galen's Escape", z=8, x=53.08, y=29.55, note="Escort Galen out of the camp", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1530
  {t="T", q=1393, name="Galen's Escape", z=8, x=47.81, y=39.76, target={kind="object", id=32569, name="Galen's Strongbox"}, note="Galen's Strongbox", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1531
  {t="C", q=698, name="Lack of Surplus", z=8, x=79.74, y=30.56, note="Unprepared Sawtooth Flanks from Sawtooth Crocolisks", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1532
  {t="C", q=1424, name="Pool of Tears", z=8, x=72.53, y=53.11, note="Atal'ai Artifacts around the Pool of Tears", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1533
  {t="G", z=8, x=81.3, y=81.0, text="Tok'Kar on the southeast coast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1534
  {t="T", q=698, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1535
  {t="A", q=699, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1536
  {t="C", q=699, name="Lack of Surplus", z=8, x=79.44, y=26.73, note="Sawtooth Snapper Claws from the snappers", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1537
  {t="C", q=1430, name="Fresh Meat", z=8, x=94.2, y=57.8, note="Monstrous Crawler Legs from the crawlers on the beach", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1538
  {t="G", z=8, x=81.3, y=81.0, text="Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1539
  {t="T", q=699, name="Lack of Surplus", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1540
  {t="A", q=1422, name="Threat From the Sea", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1541
  {t="T", q=1422, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, note="Katar, next to Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1542
  {t="A", q=1426, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1543
  {t="C", q=1426, name="Threat From the Sea", z=8, x=85.33, y=82.92, note="Marsh murlocs along the coast", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1544
  {t="G", z=8, x=83.8, y=80.4, text="Katar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1545
  {t="T", q=1426, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1546
  {t="A", q=1427, name="Threat From the Sea", z=8, x=83.76, y=80.41, target={kind="npc", id=5593, name="Katar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1547
  {t="T", q=1427, name="Threat From the Sea", z=8, x=81.32, y=80.97, target={kind="npc", id=5592, name="Tok'Kar"}, note="Tok'Kar", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1548
  {t="H", text="Stonard", section="Swamp of Sorrows"}, -- 1549
  {t="T", q=1424, name="Pool of Tears", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1550
  {t="T", q=1430, name="Fresh Meat", z=8, x=44.7, y=57.21, target={kind="npc", id=5591, name="Dar"}, section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1551
  {t="A", q=1429, name="The Atal'ai Exile", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, note="Take this to the Atal'ai Exile when you reach the Hinterlands", section="Swamp of Sorrows", zoneName="Swamp of Sorrows"}, -- 1552
  {t="F", text="Grom'gol Base Camp", section="Tanaris"}, -- 1553
  {t="N", text="Take the zeppelin to Orgrimmar, then fly to Freewind Post and ride south through the Shimmering Flats into Tanaris", section="Tanaris"}, -- 1554
  {t="F", text="Freewind Post", section="Tanaris"}, -- 1555
  {t="G", z=400, x=78.1, y=77.1, text="Wizzle Brassbolts at the Mirage Raceway, on the way through the Shimmering Flats", section="Tanaris", zoneName="Thousand Needles"}, -- 1556
  {t="A", q=2770, name="Gahz'rilla", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, note="Gahz'rilla, for Zul'Farrak", section="Tanaris", zoneName="Thousand Needles"}, -- 1557
  {t="G", z=440, x=52.5, y=28.5, text="Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1558
  {t="FP", z=440, x=51.6, y=25.4, text="Gadgetzan flight path (Bulkrek Ragefist)", section="Tanaris", zoneName="Tanaris"}, -- 1559
  {t="SH", z=440, x=52.5, y=27.9, text="Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1560
  {t="A", q=1690, name="Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1561
  {t="A", q=1707, name="Water Pouch Bounty", z=440, x=52.49, y=28.45, target={kind="npc", id=7408, name="Spigot Operator Luglunket"}, section="Tanaris", zoneName="Tanaris"}, -- 1562
  {t="A", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=66.82, y=22.29, target={kind="object", id=142122, name="Wanted Poster"}, note="Wanted poster", section="Tanaris", zoneName="Tanaris"}, -- 1563
  {t="A", q=2768, name="Divino-matic Rod", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, note="Divino-matic Rod, for Zul'Farrak", section="Tanaris", zoneName="Tanaris"}, -- 1564
  {t="A", q=3042, name="Troll Temper", z=440, x=51.41, y=28.75, target={kind="npc", id=7804, name="Trenton Lighthammer"}, note="Troll Temper, for Zul'Farrak", section="Tanaris", zoneName="Tanaris"}, -- 1565
  {t="C", q=1690, name="Wastewander Justice", z=440, x=63.61, y=30.96, note="Wastewander Bandits and Thieves east of Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1566
  {t="C", q=1707, name="Water Pouch Bounty", z=440, x=62.25, y=35, note="Wastewander Water Pouches drop from the Wastewander humans", section="Tanaris", zoneName="Tanaris"}, -- 1567
  {t="G", z=440, x=52.5, y=28.5, text="Back to Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1568
  {t="T", q=1690, name="Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1569
  {t="T", q=1707, name="Water Pouch Bounty", z=440, x=52.49, y=28.45, target={kind="npc", id=7408, name="Spigot Operator Luglunket"}, section="Tanaris", zoneName="Tanaris"}, -- 1570
  {t="A", q=1691, name="More Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1571
  {t="C", q=1691, name="More Wastewander Justice", z=440, x=61.71, y=38.21, note="Wastewander Shadow Mages, Rogues and Assassins in the camps further southeast", section="Tanaris", zoneName="Tanaris"}, -- 1572
  {t="C", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=61.77, y=38.17, note="Caliph Scorpidsting in the same camps", section="Tanaris", zoneName="Tanaris"}, -- 1573
  {t="G", z=440, x=67.1, y=23.9, text="Steamwheedle Port", section="Tanaris", zoneName="Tanaris"}, -- 1574
  {t="A", q=2875, name="WANTED: Andre Firebeard", z=440, x=66.82, y=22.29, target={kind="object", id=142122, name="Wanted Poster"}, note="Wanted poster", section="Tanaris", zoneName="Tanaris"}, -- 1575
  {t="A", q=8366, name="Southsea Shakedown", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1576
  {t="C", q=8366, name="Southsea Shakedown", z=440, x=73.96, y=46.57, note="Southsea pirates at Lost Rigger Cove", section="Tanaris", zoneName="Tanaris"}, -- 1577
  {t="C", q=2875, name="WANTED: Andre Firebeard", z=440, x=73.37, y=47.14, note="Andre Firebeard at Lost Rigger Cove", section="Tanaris", zoneName="Tanaris"}, -- 1578
  {t="A", q=2876, name="Ship Schedules", z=440, x=73.37, y=47.14, note="Ship Schedules drop from the pirates", section="Tanaris", zoneName="Tanaris"}, -- 1579
  {t="G", z=440, x=67.1, y=23.9, text="Steamwheedle Port", section="Tanaris", zoneName="Tanaris"}, -- 1580
  {t="T", q=2875, name="WANTED: Andre Firebeard", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1581
  {t="T", q=8366, name="Southsea Shakedown", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1582
  {t="T", q=2876, name="Ship Schedules", z=440, x=67.06, y=23.89, target={kind="npc", id=7882, name="Security Chief Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1583
  {t="H", text="Gadgetzan", section="Tanaris"}, -- 1584
  {t="T", q=1691, name="More Wastewander Justice", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1585
  {t="T", q=2781, name="WANTED: Caliph Scorpidsting", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Tanaris", zoneName="Tanaris"}, -- 1586
  {t="A", q=5863, name="The Dunemaul Compound", group=true, z=440, x=52.82, y=27.4, target={kind="npc", id=11758, name="Andi Lynn"}, note="Group quest", section="Tanaris", zoneName="Tanaris"}, -- 1587
  {t="C", q=5863, name="The Dunemaul Compound", group=true, z=440, x=40.73, y=56.87, note="Dunemaul ogres at the Dunemaul Compound, south of Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1588
  {t="G", z=440, x=52.8, y=27.4, text="Andi Lynn, Gadgetzan", section="Tanaris", zoneName="Tanaris"}, -- 1589
  {t="T", q=5863, name="The Dunemaul Compound", group=true, z=440, x=52.82, y=27.4, target={kind="npc", id=11758, name="Andi Lynn"}, section="Tanaris", zoneName="Tanaris"}, -- 1590
  {t="D", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", text="Zul'Farrak, north-west Tanaris", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1591
  {t="C", q=3042, name="Troll Temper", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Vials of Troll Temper from the Zul'Farrak trolls", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1592
  {t="C", q=2768, name="Divino-matic Rod", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Divino-matic Rod from Sergeant Bly's group on the stairs", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1593
  {t="C", q=2770, name="Gahz'rilla", z=440, x=38.7, y=20.1, instance=1176, dungeonName="Zul'Farrak", note="Gahz'rilla's Electrified Scale (summon Gahz'rilla at the pool with the mallet)", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1594
  {t="G", z=440, x=52.5, y=28.5, text="Gadgetzan", section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1595
  {t="T", q=2768, name="Divino-matic Rod", z=440, x=52.46, y=28.51, target={kind="npc", id=7407, name="Chief Engineer Bilgewhizzle"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1596
  {t="T", q=3042, name="Troll Temper", z=440, x=51.41, y=28.75, target={kind="npc", id=7804, name="Trenton Lighthammer"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Tanaris"}, -- 1597
  {t="G", z=400, x=78.1, y=77.1, text="Wizzle Brassbolts at the Mirage Raceway", section="Zul'Farrak (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1598
  {t="T", q=2770, name="Gahz'rilla", z=400, x=78.14, y=77.12, target={kind="npc", id=4453, name="Wizzle Brassbolts"}, section="Zul'Farrak (dungeon, group of 5)", zoneName="Thousand Needles"}, -- 1599
  {t="N", text="Ride north-west to Freewind Post", section="Feralas"}, -- 1600
  {t="N", text="Ride west from Freewind through the Highperch gap into Feralas and follow the road to Camp Mojache", section="Feralas"}, -- 1601
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1602
  {t="FP", z=357, x=75.5, y=44.4, text="Camp Mojache flight path (Shyn)", section="Feralas", zoneName="Feralas"}, -- 1603
  {t="SH", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1604
  {t="A", q=2862, name="War on the Woodpaw", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1605
  {t="A", q=2975, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1606
  {t="A", q=2973, name="A New Cloak's Sheen", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1607
  {t="C", q=2975, name="The Ogres of Feralas", z=357, x=75.36, y=33.85, note="Gordunni ogres at the ogre outpost north of camp", section="Feralas", zoneName="Feralas"}, -- 1608
  {t="A", q=2978, name="The Gordunni Scroll", z=357, x=75.13, y=29.73, target={kind="item", id=9370, name="Gordunni Scroll"}, note="The Gordunni Scroll on the ground in the outpost", section="Feralas", zoneName="Feralas"}, -- 1609
  {t="C", q=2973, name="A New Cloak's Sheen", z=357, x=66.62, y=46.94, note="Iridescent Sprite Darter Wings from the sprite darters", section="Feralas", zoneName="Feralas"}, -- 1610
  {t="C", q=2862, name="War on the Woodpaw", z=357, x=71.6, y=54.15, note="Woodpaw Gnoll Manes from the gnolls south of camp", section="Feralas", zoneName="Feralas"}, -- 1611
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1612
  {t="T", q=2975, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1613
  {t="T", q=2978, name="The Gordunni Scroll", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1614
  {t="T", q=2973, name="A New Cloak's Sheen", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1615
  {t="A", q=2974, name="A Grim Discovery", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1616
  {t="T", q=2862, name="War on the Woodpaw", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1617
  {t="A", q=2863, name="Alpha Strike", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1618
  {t="A", q=2980, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1619
  {t="A", q=2979, name="Dark Ceremony", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1620
  {t="C", q=2863, name="Alpha Strike", z=357, x=69.07, y=55.63, note="Kill 5 Woodpaw Alphas within an hour", section="Feralas", zoneName="Feralas"}, -- 1621
  {t="G", z=357, x=74.9, y=42.5, text="Hadoken Swiftstrider", section="Feralas", zoneName="Feralas"}, -- 1622
  {t="T", q=2863, name="Alpha Strike", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1623
  {t="A", q=2902, name="Woodpaw Investigation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1624
  {t="G", z=357, x=71.6, y=55.9, text="Woodpaw Battle Map in the southern gnoll camp", section="Feralas", zoneName="Feralas"}, -- 1625
  {t="T", q=2902, name="Woodpaw Investigation", z=357, x=71.63, y=55.92, target={kind="object", id=142195, name="Woodpaw Battle Map"}, section="Feralas", zoneName="Feralas"}, -- 1626
  {t="A", q=2903, name="The Battle Plans", z=357, x=71.63, y=55.92, target={kind="object", id=142195, name="Woodpaw Battle Map"}, section="Feralas", zoneName="Feralas"}, -- 1627
  {t="G", z=357, x=74.9, y=42.5, text="Hadoken Swiftstrider", section="Feralas", zoneName="Feralas"}, -- 1628
  {t="T", q=2903, name="The Battle Plans", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1629
  {t="A", q=7730, name="Zukk'ash Infestation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1630
  {t="A", q=7731, name="Stinglasher", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1631
  {t="C", q=7730, name="Zukk'ash Infestation", z=357, x=74.77, y=63.12, note="Zukk'ash Carapaces from the silithid in the Writhing Deep", section="Feralas", zoneName="Feralas"}, -- 1632
  {t="C", q=7731, name="Stinglasher", z=357, x=75.58, y=60.85, note="Stinglasher, deep in the Writhing Deep", section="Feralas", zoneName="Feralas"}, -- 1633
  {t="C", q=2980, name="The Ogres of Feralas", z=357, x=60.44, y=64.8, note="Gordunni Shaman, Brutes and Mages at the southern ogre camp", section="Feralas", zoneName="Feralas"}, -- 1634
  {t="C", q=2979, name="Dark Ceremony", z=357, x=60.77, y=69.54, note="The Gordunni Orb from the ogres at the same camp", section="Feralas", zoneName="Feralas"}, -- 1635
  {t="C", q=2974, name="A Grim Discovery", z=357, x=67.31, y=39.36, note="Grimtotem Horns from the Grimtotem camp west of Mojache", section="Feralas", zoneName="Feralas"}, -- 1636
  {t="G", z=357, x=74.8, y=45.2, text="Camp Mojache", section="Feralas", zoneName="Feralas"}, -- 1637
  {t="T", q=7730, name="Zukk'ash Infestation", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1638
  {t="T", q=7731, name="Stinglasher", z=357, x=74.91, y=42.46, target={kind="npc", id=7875, name="Hadoken Swiftstrider"}, section="Feralas", zoneName="Feralas"}, -- 1639
  {t="T", q=2980, name="The Ogres of Feralas", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1640
  {t="T", q=2979, name="Dark Ceremony", z=357, x=75.8, y=43.58, target={kind="npc", id=7777, name="Rok Orhan"}, section="Feralas", zoneName="Feralas"}, -- 1641
  {t="T", q=2974, name="A Grim Discovery", z=357, x=75.94, y=42.74, target={kind="npc", id=4544, name="Krueg Skullsplitter"}, section="Feralas", zoneName="Feralas"}, -- 1642
  {t="F", text="Shadowprey Village", section="Maraudon (dungeon, group of 5)"}, -- 1643
  {t="G", z=405, x=23.2, y=70.3, text="Vark Battlescar, Shadowprey Village", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1644
  {t="A", q=7029, name="Vyletongue Corruption", z=405, x=23.22, y=70.33, target={kind="npc", id=11823, name="Vark Battlescar"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1645
  {t="G", z=405, x=26.9, y=77.7, text="Selendra, south of Shadowprey", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1646
  {t="A", q=7064, name="Corruption of Earth and Seed", z=405, x=26.87, y=77.67, target={kind="npc", id=13699, name="Selendra"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1647
  {t="D", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", text="Maraudon, west Desolace", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1648
  {t="C", q=7029, name="Vyletongue Corruption", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", note="Fill the vial at the orange crystal pool", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1649
  {t="C", q=7064, name="Corruption of Earth and Seed", z=405, x=29.1, y=62.5, instance=2100, dungeonName="Maraudon", note="Princess Theradras, final boss", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1650
  {t="G", z=405, x=26.9, y=77.7, text="Selendra", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1651
  {t="T", q=7064, name="Corruption of Earth and Seed", z=405, x=26.87, y=77.67, target={kind="npc", id=13699, name="Selendra"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1652
  {t="G", z=405, x=23.2, y=70.3, text="Vark Battlescar", section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1653
  {t="T", q=7029, name="Vyletongue Corruption", z=405, x=23.22, y=70.33, target={kind="npc", id=11823, name="Vark Battlescar"}, section="Maraudon (dungeon, group of 5)", zoneName="Desolace"}, -- 1654
  {t="F", text="Orgrimmar", section="The Hinterlands"}, -- 1655
  {t="TR", text="Train level 48 spells", section="The Hinterlands"}, -- 1656
  {t="N", text="Take the zeppelin to Tirisfal Glades, then fly to Tarren Mill", section="The Hinterlands"}, -- 1657
  {t="F", text="Tarren Mill", section="The Hinterlands"}, -- 1658
  {t="N", text="Ride east past Durnholde Keep into the Hinterlands and follow the road to Revantusk Village on the east coast", section="The Hinterlands"}, -- 1659
  {t="G", z=47, x=33.8, y=75.2, text="The Atal'ai Exile, south-west Hinterlands", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1660
  {t="T", q=1429, name="The Atal'ai Exile", z=47, x=33.75, y=75.21, target={kind="npc", id=5598, name="Atal'ai Exile"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1661
  {t="A", q=1444, name="Return to Fel'Zerul", z=47, x=33.75, y=75.21, target={kind="npc", id=5598, name="Atal'ai Exile"}, note="Return to Fel'Zerul, for the Sunken Temple later", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1662
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1663
  {t="FP", z=47, x=81.7, y=81.8, text="Revantusk flight path (Gorkas)", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1664
  {t="SH", z=47, x=78.1, y=81.4, text="Revantusk Village (Lard is the innkeeper)", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1665
  {t="A", q=7839, name="Vilebranch Hooligans", z=47, x=77.23, y=80.13, target={kind="npc", id=14737, name="Smith Slagtree"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1666
  {t="A", q=7844, name="Cannibalistic Cousins", z=47, x=78.8, y=78.25, target={kind="npc", id=14739, name="Mystic Yayo'jin"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1667
  {t="A", q=7828, name="Stalking the Stalkers", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1668
  {t="A", q=7829, name="Hunt the Savages", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1669
  {t="A", q=7830, name="Avenging the Fallen", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1670
  {t="A", q=7815, name="Snapjaws, Mon!", z=47, x=80.33, y=81.54, target={kind="npc", id=14740, name="Katoom the Angler"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1671
  {t="A", q=7841, name="Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1672
  {t="C", q=7815, name="Snapjaws, Mon!", z=47, x=81.48, y=60.46, note="Snapjaws along the eastern coast", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1673
  {t="C", q=7828, name="Stalking the Stalkers", z=47, x=60.74, y=54.01, note="Silvermane Stalkers", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1674
  {t="C", q=7829, name="Hunt the Savages", z=47, x=58.4, y=50.6, note="Savage Owlbeasts", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1675
  {t="C", q=7830, name="Avenging the Fallen", z=47, x=60.4, y=49.8, note="Witherbark Broodguards and Axe Throwers", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1676
  {t="C", q=7839, name="Vilebranch Hooligans", z=47, x=66.4, y=44.8, note="Vilebranch trolls", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1677
  {t="C", q=7844, name="Cannibalistic Cousins", z=47, x=50.27, y=63.22, note="Witherbark trolls", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1678
  {t="C", q=7841, name="Message to the Wildhammer", z=47, x=31.27, y=48.33, note="Wildhammer dwarves", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1679
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1680
  {t="T", q=7815, name="Snapjaws, Mon!", z=47, x=80.33, y=81.54, target={kind="npc", id=14740, name="Katoom the Angler"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1681
  {t="T", q=7828, name="Stalking the Stalkers", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1682
  {t="T", q=7829, name="Hunt the Savages", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1683
  {t="T", q=7830, name="Avenging the Fallen", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1684
  {t="T", q=7839, name="Vilebranch Hooligans", z=47, x=77.23, y=80.13, target={kind="npc", id=14737, name="Smith Slagtree"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1685
  {t="T", q=7844, name="Cannibalistic Cousins", z=47, x=78.8, y=78.25, target={kind="npc", id=14739, name="Mystic Yayo'jin"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1686
  {t="T", q=7841, name="Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1687
  {t="A", q=7842, name="Another Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1688
  {t="A", q=7849, name="Separation Anxiety", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1689
  {t="A", q=7850, name="Dark Vessels", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1690
  {t="C", q=7849, name="Separation Anxiety", z=47, x=62.11, y=75.35, note="Find the missing wolf cubs", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1691
  {t="C", q=7850, name="Dark Vessels", z=47, x=64.17, y=72.21, note="Recover the Dark Vessels", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1692
  {t="C", q=7842, name="Another Message to the Wildhammer", z=47, x=52.6, y=51.6, note="Wildhammer mail sacks", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1693
  {t="G", z=47, x=79.1, y=79.0, text="Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1694
  {t="T", q=7849, name="Separation Anxiety", z=47, x=79.16, y=79.53, target={kind="npc", id=14741, name="Huntsman Markhor"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1695
  {t="T", q=7850, name="Dark Vessels", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1696
  {t="T", q=7842, name="Another Message to the Wildhammer", z=47, x=79.38, y=79.08, target={kind="npc", id=14738, name="Otho Moji'ko"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1697
  {t="A", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=79.08, y=78.99, target={kind="object", id=179913, name="Call to Arms!"}, note="Group quest: Call to Arms! board", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1698
  {t="A", q=7845, name="Kidnapped Elder Torntusk!", group=true, z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, note="Group quest", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1699
  {t="C", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=57.66, y=81.51, note="Vile Priestess Hexx and Vilebranch Aman'zasi Guards in Jintha'Alor", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1700
  {t="T", q=7845, name="Kidnapped Elder Torntusk!", group=true, z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, note="Elder Torntusk, held in Jintha'Alor", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1701
  {t="A", q=7846, name="Recover the Key!", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1702
  {t="C", q=7846, name="Recover the Key!", z=47, x=57.32, y=86.64, note="Hitah'ya the Keeper drops the key", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1703
  {t="T", q=7846, name="Recover the Key!", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1704
  {t="A", q=7847, name="Return to Primal Torntusk", z=47, x=59.69, y=77.84, target={kind="npc", id=14757, name="Elder Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1705
  {t="G", z=47, x=78.2, y=81.2, text="Primal Torntusk, Revantusk Village", section="The Hinterlands", zoneName="The Hinterlands"}, -- 1706
  {t="T", q=7847, name="Return to Primal Torntusk", z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1707
  {t="T", q=7861, name="Wanted: Vile Priestess Hexx and Her Minions", group=true, z=47, x=78.2, y=81.18, target={kind="npc", id=14736, name="Primal Torntusk"}, section="The Hinterlands", zoneName="The Hinterlands"}, -- 1708
  {t="F", text="Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)"}, -- 1709
  {t="T", q=1444, name="Return to Fel'Zerul", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, note="Fel'Zerul", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1710
  {t="A", q=1445, name="The Temple of Atal'Hakkar", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1711
  {t="D", z=8, x=69.9, y=53.5, instance=1477, dungeonName="The Temple of Atal'Hakkar", text="Sunken Temple, in the lake east of Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1712
  {t="C", q=1445, name="The Temple of Atal'Hakkar", z=8, x=69.9, y=53.5, instance=1477, dungeonName="The Temple of Atal'Hakkar", note="Fetishes of Hakkar from the trolls inside", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1713
  {t="G", z=8, x=47.9, y=54.8, text="Fel'Zerul, Stonard", section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1714
  {t="T", q=1445, name="The Temple of Atal'Hakkar", z=8, x=47.93, y=54.78, target={kind="npc", id=1443, name="Fel'zerul"}, section="The Temple of Atal'Hakkar (Sunken Temple, dungeon, group of 5)", zoneName="Swamp of Sorrows"}, -- 1715
  {t="F", text="Grom'gol Base Camp", section="Un'Goro Crater"}, -- 1716
  {t="N", text="Zeppelin to Orgrimmar, then fly to Gadgetzan", section="Un'Goro Crater"}, -- 1717
  {t="TR", text="Train level 50 spells in Orgrimmar on the way through", section="Un'Goro Crater"}, -- 1718
  {t="F", text="Gadgetzan", section="Un'Goro Crater"}, -- 1719
  {t="N", text="Ride south-west from Gadgetzan to the ramp down into Un'Goro Crater", section="Un'Goro Crater"}, -- 1720
  {t="G", z=490, x=71.6, y=76.0, text="Torwa Pathfinder at the Un'Goro ramp", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1721
  {t="A", q=4290, name="The Fare of Lar'korwi", z=490, x=71.64, y=75.96, target={kind="npc", id=9619, name="Torwa Pathfinder"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1722
  {t="C", q=4290, name="The Fare of Lar'korwi", z=490, x=68.74, y=56.71, note="Lar'korwi's freshest kill: take the Piece of Threshadon Carcass", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1723
  {t="T", q=4290, name="The Fare of Lar'korwi", z=490, x=71.64, y=75.96, target={kind="npc", id=9619, name="Torwa Pathfinder"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1724
  {t="G", z=490, x=43.5, y=7.4, text="Marshal's Refuge, north side of the crater", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1725
  {t="FP", z=490, x=45.2, y=5.8, text="Marshal's Refuge flight path (Gryfe)", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1726
  {t="A", q=3882, name="Roll the Bones", z=490, x=43.5, y=7.42, target={kind="npc", id=9272, name="Spark Nilminer"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1727
  {t="A", q=4503, name="Shizzle's Flyer", z=490, x=44.23, y=11.59, target={kind="npc", id=9998, name="Shizzle"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1728
  {t="A", q=4145, name="Larion and Muigin", z=490, x=45.54, y=8.72, target={kind="npc", id=9118, name="Larion"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1729
  {t="A", q=3881, name="Expedition Salvation", z=490, x=43.95, y=7.14, target={kind="npc", id=9270, name="Williden Marshal"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1730
  {t="A", q=4243, name="Chasing A-Me 01", z=490, x=46.38, y=13.44, target={kind="npc", id=9618, name="Karna Remtravel"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1731
  {t="A", q=4284, name="Crystals of Power", z=490, x=41.92, y=2.7, target={kind="npc", id=9117, name="J.D. Collie"}, note="J.D. Collie in the cave: pick up crystals as you quest", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1732
  {t="C", q=4243, name="Chasing A-Me 01", z=490, x=41.92, y=2.7, note="Find A-Me 01 in the north-east", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1733
  {t="T", q=4243, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1734
  {t="A", q=4244, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1735
  {t="G", z=490, x=67.7, y=16.6, text="Gorilla caves around A-Me 01", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1736
  {t="C", q=4244, name="Chasing A-Me 01", z=490, x=67.7, y=16.6, note="Mithril Casing drops from the Un'Goro gorillas here", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1737
  {t="T", q=4244, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1738
  {t="A", q=4245, name="Chasing A-Me 01", z=490, x=67.66, y=16.76, target={kind="npc", id=9623, name="A-Me 01"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1739
  {t="C", q=4245, name="Chasing A-Me 01", z=490, x=46.43, y=13.78, note="Escort A-Me 01 back to Marshal's Refuge", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1740
  {t="T", q=4245, name="Chasing A-Me 01", z=490, x=46.38, y=13.44, target={kind="npc", id=9618, name="Karna Remtravel"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1741
  {t="C", q=3881, name="Expedition Salvation", z=490, x=68.54, y=36.54, note="Crate of Foodstuffs and Research Equipment at the wrecked caravan", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1742
  {t="C", q=4145, name="Larion and Muigin", z=490, x=56.39, y=37.33, note="Bloodpetal plants", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1743
  {t="C", q=4503, name="Shizzle's Flyer", z=490, x=39, y=49.4, note="Webbed Diemetradon and Pterrordax Scales", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1744
  {t="C", q=3882, name="Roll the Bones", z=490, x=38.98, y=63.95, note="Dinosaur Bones from the diemetradons and pterrordax", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1745
  {t="C", q=4284, name="Crystals of Power", z=490, x=58.1, y=49.8, note="Power Crystals (red, blue, yellow, green) around the crater", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1746
  {t="G", z=490, x=43.5, y=7.4, text="Marshal's Refuge", section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1747
  {t="T", q=3881, name="Expedition Salvation", z=490, x=43.95, y=7.14, target={kind="npc", id=9270, name="Williden Marshal"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1748
  {t="T", q=4145, name="Larion and Muigin", z=490, x=45.54, y=8.72, target={kind="npc", id=9118, name="Larion"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1749
  {t="T", q=4503, name="Shizzle's Flyer", z=490, x=44.23, y=11.59, target={kind="npc", id=9998, name="Shizzle"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1750
  {t="T", q=3882, name="Roll the Bones", z=490, x=43.5, y=7.42, target={kind="npc", id=9272, name="Spark Nilminer"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1751
  {t="T", q=4284, name="Crystals of Power", z=490, x=41.92, y=2.7, target={kind="npc", id=9117, name="J.D. Collie"}, section="Un'Goro Crater", zoneName="Un'Goro Crater"}, -- 1752
  {t="F", text="Splintertree Post", section="Felwood"}, -- 1753
  {t="N", text="Ride north from Splintertree into Felwood; the Emerald Sanctuary is on the road", section="Felwood"}, -- 1754
  {t="G", z=361, x=51.2, y=82.1, text="Emerald Sanctuary", section="Felwood", zoneName="Felwood"}, -- 1755
  {t="A", q=5155, name="Forces of Jaedenar", z=361, x=51.21, y=82.11, target={kind="npc", id=10922, name="Greta Mosshoof"}, section="Felwood", zoneName="Felwood"}, -- 1756
  {t="A", q=5156, name="Verifying the Corruption", z=361, x=50.89, y=81.62, target={kind="npc", id=10921, name="Taronn Redfeather"}, section="Felwood", zoneName="Felwood"}, -- 1757
  {t="A", q=4102, name="Cleansing Felwood", z=361, x=46.75, y=83.13, target={kind="npc", id=9529, name="Maybess Riverbreeze"}, section="Felwood", zoneName="Felwood"}, -- 1758
  {t="A", q=8460, name="Timbermaw Ally", z=361, x=50.93, y=85.01, target={kind="npc", id=11554, name="Grazle"}, section="Felwood", zoneName="Felwood"}, -- 1759
  {t="C", q=8460, name="Timbermaw Ally", z=361, x=48.34, y=90.89, note="Deadwood furbolgs south of the sanctuary", section="Felwood", zoneName="Felwood"}, -- 1760
  {t="T", q=8460, name="Timbermaw Ally", z=361, x=50.93, y=85.01, target={kind="npc", id=11554, name="Grazle"}, section="Felwood", zoneName="Felwood"}, -- 1761
  {t="C", q=5155, name="Forces of Jaedenar", z=361, x=38.15, y=61.13, note="Jaedenar hounds, guardsmen and Shadow Council", section="Felwood", zoneName="Felwood"}, -- 1762
  {t="G", z=361, x=34.4, y=54.0, text="Bloodvenom Post", section="Felwood", zoneName="Felwood"}, -- 1763
  {t="FP", z=361, x=34.4, y=54.0, text="Bloodvenom flight path (Brakkar)", section="Felwood", zoneName="Felwood"}, -- 1764
  {t="A", q=6162, name="A Husband's Last Battle", z=361, x=34.8, y=52.73, target={kind="npc", id=9620, name="Dreka'Sur"}, section="Felwood", zoneName="Felwood"}, -- 1765
  {t="C", q=5156, name="Verifying the Corruption", z=361, x=41.73, y=40.15, note="Entropic Beasts and Entropic Horrors", section="Felwood", zoneName="Felwood"}, -- 1766
  {t="C", q=4102, name="Cleansing Felwood", z=361, x=57.28, y=19.67, note="Blood Amber (follow the waypoint)", section="Felwood", zoneName="Felwood"}, -- 1767
  {t="G", z=361, x=51.2, y=82.1, text="Emerald Sanctuary", section="Felwood", zoneName="Felwood"}, -- 1768
  {t="T", q=5155, name="Forces of Jaedenar", z=361, x=51.21, y=82.11, target={kind="npc", id=10922, name="Greta Mosshoof"}, section="Felwood", zoneName="Felwood"}, -- 1769
  {t="T", q=5156, name="Verifying the Corruption", z=361, x=50.89, y=81.62, target={kind="npc", id=10921, name="Taronn Redfeather"}, section="Felwood", zoneName="Felwood"}, -- 1770
  {t="T", q=4102, name="Cleansing Felwood", z=361, x=46.75, y=83.13, target={kind="npc", id=9529, name="Maybess Riverbreeze"}, section="Felwood", zoneName="Felwood"}, -- 1771
  {t="C", q=6162, name="A Husband's Last Battle", z=361, x=48.23, y=94.28, note="Overlord Ror", section="Felwood", zoneName="Felwood"}, -- 1772
  {t="G", z=361, x=34.8, y=52.7, text="Bloodvenom Post", section="Felwood", zoneName="Felwood"}, -- 1773
  {t="T", q=6162, name="A Husband's Last Battle", z=361, x=34.8, y=52.73, target={kind="npc", id=9620, name="Dreka'Sur"}, section="Felwood", zoneName="Felwood"}, -- 1774
  {t="N", text="Ride north through Felwood and the Timbermaw Hold tunnel into Winterspring", section="Winterspring"}, -- 1775
  {t="G", z=618, x=61.4, y=38.8, text="Everlook", section="Winterspring", zoneName="Winterspring"}, -- 1776
  {t="FP", z=618, x=60.5, y=36.3, text="Everlook flight path (Yugrek)", section="Winterspring", zoneName="Winterspring"}, -- 1777
  {t="SH", z=618, x=61.4, y=38.8, text="Everlook", section="Winterspring", zoneName="Winterspring"}, -- 1778
  {t="A", q=3783, name="Are We There, Yeti?", z=618, x=60.88, y=37.62, target={kind="npc", id=10305, name="Umi Rumplesnicker"}, section="Winterspring", zoneName="Winterspring"}, -- 1779
  {t="A", q=5054, name="Ursius of the Shardtooth", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1780
  {t="A", q=6603, name="Trouble in Winterspring!", z=618, x=60.66, y=38.17, target={kind="npc", id=11754, name="Meggi Peppinrocker"}, section="Winterspring", zoneName="Winterspring"}, -- 1781
  {t="A", q=5601, name="Sister Pamela", z=618, x=61.28, y=38.98, target={kind="npc", id=11629, name="Jessica Redpath"}, section="Winterspring", zoneName="Winterspring"}, -- 1782
  {t="C", q=3783, name="Are We There, Yeti?", z=618, x=54.43, y=36.3, note="Thick Yeti Furs from the Ice Thistle yetis", section="Winterspring", zoneName="Winterspring"}, -- 1783
  {t="C", q=5054, name="Ursius of the Shardtooth", z=618, x=60.92, y=32.9, note="Ursius of the Shardtooth", section="Winterspring", zoneName="Winterspring"}, -- 1784
  {t="G", z=618, x=31.3, y=45.2, text="Donova Snowden by the hot springs", section="Winterspring", zoneName="Winterspring"}, -- 1785
  {t="T", q=6603, name="Trouble in Winterspring!", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1786
  {t="A", q=5082, name="Threat of the Winterfall", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1787
  {t="A", q=5083, name="Winterfall Firewater", z=618, x=40.85, y=42.52, target={kind="item", id=12771, name="Empty Firewater Flask"}, note="The Empty Firewater Flask drops from the Winterfall furbolgs", section="Winterspring", zoneName="Winterspring"}, -- 1788
  {t="C", q=5082, name="Threat of the Winterfall", z=618, x=34.72, y=36.96, note="Winterfall Pathfinders, Den Watchers and Totemics", section="Winterspring", zoneName="Winterspring"}, -- 1789
  {t="T", q=5082, name="Threat of the Winterfall", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1790
  {t="T", q=5083, name="Winterfall Firewater", z=618, x=31.27, y=45.16, target={kind="npc", id=9298, name="Donova Snowden"}, section="Winterspring", zoneName="Winterspring"}, -- 1791
  {t="H", text="Everlook", section="Winterspring"}, -- 1792
  {t="T", q=3783, name="Are We There, Yeti?", z=618, x=60.88, y=37.62, target={kind="npc", id=10305, name="Umi Rumplesnicker"}, section="Winterspring", zoneName="Winterspring"}, -- 1793
  {t="T", q=5054, name="Ursius of the Shardtooth", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1794
  {t="A", q=5055, name="Brumeran of the Chillwind", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1795
  {t="C", q=5055, name="Brumeran of the Chillwind", z=618, x=62.54, y=57.9, note="Brumeran of the Chillwind", section="Winterspring", zoneName="Winterspring"}, -- 1796
  {t="T", q=5055, name="Brumeran of the Chillwind", z=618, x=61.93, y=38.38, target={kind="npc", id=10303, name="Storm Shadowhoof"}, section="Winterspring", zoneName="Winterspring"}, -- 1797
  {t="F", text="Orgrimmar", section="Badlands and Blackrock Mountain"}, -- 1798
  {t="TR", text="Train level 56 spells", section="Badlands and Blackrock Mountain"}, -- 1799
  {t="N", text="Take the zeppelin to Tirisfal Glades and walk into Undercity", section="Badlands and Blackrock Mountain"}, -- 1800
  {t="G", z=1497, x=50.1, y=68.0, text="Apothecary Zinge in the Apothecarium", section="Badlands and Blackrock Mountain", zoneName="Undercity"}, -- 1801
  {t="A", q=4133, name="Vivian Lagrave", z=1497, x=50.14, y=67.97, target={kind="npc", id=5204, name="Apothecary Zinge"}, section="Badlands and Blackrock Mountain", zoneName="Undercity"}, -- 1802
  {t="F", text="Hammerfall", section="Badlands and Blackrock Mountain"}, -- 1803
  {t="N", text="Ride south over Thandol Span, through the Wetlands and Loch Modan, then south into the Badlands; Kargath is at the far west", section="Badlands and Blackrock Mountain"}, -- 1804
  {t="G", z=3, x=2.9, y=47.8, text="Kargath", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1805
  {t="FP", z=3, x=4.0, y=44.8, text="Kargath flight path (Gorrik)", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1806
  {t="SH", z=3, x=2.8, y=45.9, text="Kargath", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1807
  {t="T", q=4133, name="Vivian Lagrave", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, note="Shadowmage Vivian Lagrave", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1808
  {t="A", q=4134, name="Lost Thunderbrew Recipe", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1809
  {t="A", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=3, x=3.74, y=47.43, target={kind="object", id=164867, name="WANTED"}, note="KILL ON SIGHT poster", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1810
  {t="A", q=3906, name="Disharmony of Flame", z=3, x=3.33, y=48.26, target={kind="npc", id=9084, name="Thunderheart"}, note="Thunderheart", section="Badlands and Blackrock Mountain", zoneName="Badlands"}, -- 1811
  {t="N", text="Ride south-west from Kargath into Searing Gorge and on to Blackrock Mountain", section="Badlands and Blackrock Mountain"}, -- 1812
  {t="C", q=3906, name="Disharmony of Flame", z=10074, x=46.82, y=67.7, note="Overmaster Pyron, in the quarry just before the Blackrock Depths portal", section="Blackrock Depths (dungeon, group of 5)", zoneName="10074"}, -- 1813
  {t="D", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", text="Blackrock Depths", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1814
  {t="C", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", note="Anvilrage Guardsmen, Wardens and Footmen", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1815
  {t="C", q=4134, name="Lost Thunderbrew Recipe", z=51, x=34.8, y=85.3, instance=1584, dungeonName="Blackrock Depths", note="The Lost Thunderbrew Recipe from the brewers in the Grim Guzzler area", section="Blackrock Depths (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1816
  {t="H", text="Kargath", section="Blackrock Depths (dungeon, group of 5)"}, -- 1817
  {t="T", q=3906, name="Disharmony of Flame", z=3, x=3.33, y=48.26, target={kind="npc", id=9084, name="Thunderheart"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1818
  {t="T", q=4081, name="KILL ON SIGHT: Dark Iron Dwarves", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1819
  {t="T", q=4134, name="Lost Thunderbrew Recipe", z=3, x=2.9, y=47.76, target={kind="npc", id=9078, name="Shadowmage Vivian Lagrave"}, section="Blackrock Depths (dungeon, group of 5)", zoneName="Badlands"}, -- 1820
  {t="A", q=4903, name="Warlord's Command", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, note="Warlord Goretooth", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1821
  {t="A", q=4724, name="The Pack Mistress", z=3, x=5.96, y=47.73, target={kind="npc", id=9081, name="Galamav the Marksman"}, note="Galamav the Marksman", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1822
  {t="A", q=4981, name="Operative Bijou", z=3, x=5.88, y=47.63, target={kind="npc", id=9080, name="Lexlort"}, note="Grandmaster Lexlort", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1823
  {t="D", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", text="Lower Blackrock Spire, upper part of Blackrock Mountain", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1824
  {t="T", q=4981, name="Operative Bijou", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, note="Bijou, near the start of the Spire", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1825
  {t="A", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1826
  {t="C", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Bijou's Belongings", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1827
  {t="T", q=4982, name="Bijou's Belongings", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1828
  {t="A", q=4983, name="Bijou's Reconnaissance Report", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", target={kind="npc", id=10257, name="Bijou"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1829
  {t="C", q=4903, name="Warlord's Command", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Highlord Omokk, War Master Voone and Overlord Wyrmthalak, plus the Important Blackrock Documents", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1830
  {t="C", q=4724, name="The Pack Mistress", z=51, x=34.8, y=85.3, instance=1583, dungeonName="Blackrock Spire", note="Halycon, the worg pack mistress", section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Searing Gorge"}, -- 1831
  {t="F", text="Kargath", section="Lower Blackrock Spire (dungeon, group of 5)"}, -- 1832
  {t="T", q=4903, name="Warlord's Command", z=3, x=5.81, y=47.52, target={kind="npc", id=9077, name="Warlord Goretooth"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1833
  {t="T", q=4724, name="The Pack Mistress", z=3, x=5.96, y=47.73, target={kind="npc", id=9081, name="Galamav the Marksman"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1834
  {t="T", q=4983, name="Bijou's Reconnaissance Report", z=3, x=5.88, y=47.63, target={kind="npc", id=9080, name="Lexlort"}, section="Lower Blackrock Spire (dungeon, group of 5)", zoneName="Badlands"}, -- 1835
  {t="F", text="Undercity", section="Western Plaguelands"}, -- 1836
  {t="TR", text="Train level 58 spells", section="Western Plaguelands"}, -- 1837
  {t="G", z=1497, x=63.9, y=44.1, text="Harbinger Balthazad, Undercity", section="Western Plaguelands", zoneName="Undercity"}, -- 1838
  {t="A", q=5094, name="A Call to Arms: The Plaguelands!", z=1497, x=63.9, y=44.08, target={kind="npc", id=10879, name="Harbinger Balthazad"}, section="Western Plaguelands", zoneName="Undercity"}, -- 1839
  {t="N", text="Ride east out of Undercity to the Bulwark", section="Western Plaguelands"}, -- 1840
  {t="G", z=85, x=83.1, y=68.9, text="The Bulwark, eastern Tirisfal", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1841
  {t="T", q=5094, name="A Call to Arms: The Plaguelands!", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1842
  {t="A", q=5096, name="Scarlet Diversions", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1843
  {t="C", q=5096, name="Scarlet Diversions", z=85, x=83.17, y=69.09, note="Burn the Scarlet tents and supplies at the Scarlet base camp", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1844
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1845
  {t="T", q=5096, name="Scarlet Diversions", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1846
  {t="A", q=5098, name="All Along the Watchtowers", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1847
  {t="A", q=5228, name="The Scourge Cauldrons", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1848
  {t="T", q=5228, name="The Scourge Cauldrons", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, note="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1849
  {t="A", q=5229, name="Target: Felstone Field", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1850
  {t="G", z=28, x=37.2, y=56.8, text="Felstone Field cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1851
  {t="C", q=5229, name="Target: Felstone Field", z=28, x=36.93, y=57.41, note="Kill the Cauldron Lord to get the key, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1852
  {t="T", q=5229, name="Target: Felstone Field", z=28, x=37.25, y=56.78, target={kind="object", id=176361, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1853
  {t="A", q=5230, name="Return to the Bulwark", z=28, x=37.25, y=56.78, target={kind="object", id=176361, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1854
  {t="G", z=28, x=53.7, y=64.7, text="Mulgris Deepriver at the Writhing Haunt", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1855
  {t="A", q=4984, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1856
  {t="C", q=4984, name="The Wildlife Suffers Too", z=28, x=46.52, y=44.91, note="Diseased Wolves", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1857
  {t="C", q=5098, name="All Along the Watchtowers", z=28, x=42.33, y=66.24, note="Mark the four towers in Andorhal with the Beacon Torch", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1858
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1859
  {t="T", q=5098, name="All Along the Watchtowers", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1860
  {t="A", q=105, name="Alas, Andorhal", group=true, z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, note="Group quest: Araj the Summoner in Andorhal", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1861
  {t="A", q=838, name="Scholomance", z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1862
  {t="T", q=838, name="Scholomance", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, note="Apothecary Dithers", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1863
  {t="A", q=964, name="Skeletal Fragments", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1864
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis, the Bulwark", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1865
  {t="T", q=5230, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1866
  {t="A", q=5231, name="Target: Dalson's Tears", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1867
  {t="G", z=28, x=46.2, y=51.9, text="Dalson's Tears cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1868
  {t="C", q=5231, name="Target: Dalson's Tears", z=28, x=46.11, y=52.61, note="Kill the Cauldron Lord, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1869
  {t="T", q=5231, name="Target: Dalson's Tears", z=28, x=46.18, y=51.9, target={kind="object", id=177289, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1870
  {t="A", q=5232, name="Return to the Bulwark", z=28, x=46.18, y=51.9, target={kind="object", id=177289, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1871
  {t="A", q=5058, name="Mrs. Dalson's Diary", z=28, x=47.8, y=50.67, target={kind="object", id=175926, name="Mrs. Dalson's Diary"}, note="Mrs. Dalson's Diary in the farmhouse", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1872
  {t="T", q=5058, name="Mrs. Dalson's Diary", z=28, x=47.8, y=50.67, target={kind="object", id=175926, name="Mrs. Dalson's Diary"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1873
  {t="C", q=964, name="Skeletal Fragments", z=28, x=44.99, y=66.93, note="Skeletal Fragments from the undead in Andorhal", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1874
  {t="G", z=28, x=45.3, y=69.2, text="Araj the Summoner, Andorhal", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1875
  {t="C", q=105, name="Alas, Andorhal", group=true, z=28, x=45.27, y=69.21, note="Kill Araj (elite) for the Phylactery Shard", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1876
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1877
  {t="T", q=5232, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1878
  {t="A", q=5233, name="Target: Writhing Haunt", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1879
  {t="T", q=964, name="Skeletal Fragments", z=85, x=83.28, y=69.23, target={kind="npc", id=11057, name="Apothecary Dithers"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1880
  {t="G", z=85, x=83.1, y=68.9, text="High Executor Derrington", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1881
  {t="T", q=105, name="Alas, Andorhal", group=true, z=85, x=83.13, y=68.94, target={kind="npc", id=10837, name="High Executor Derrington"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1882
  {t="G", z=28, x=53.0, y=65.6, text="Writhing Haunt cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1883
  {t="C", q=5233, name="Target: Writhing Haunt", z=28, x=52.88, y=66.08, note="Kill the Cauldron Lord, then use the cauldron", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1884
  {t="T", q=5233, name="Target: Writhing Haunt", z=28, x=53.02, y=65.61, target={kind="object", id=176393, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1885
  {t="A", q=5234, name="Return to the Bulwark", z=28, x=53.02, y=65.61, target={kind="object", id=176393, name="Scourge Cauldron"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1886
  {t="T", q=4984, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, note="Mulgris Deepriver", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1887
  {t="A", q=4985, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1888
  {t="C", q=4985, name="The Wildlife Suffers Too", z=28, x=59.01, y=51.61, note="Diseased Grizzlies", section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1889
  {t="T", q=4985, name="The Wildlife Suffers Too", z=28, x=53.73, y=64.66, target={kind="npc", id=10739, name="Mulgris Deepriver"}, section="Western Plaguelands", zoneName="Western Plaguelands"}, -- 1890
  {t="G", z=85, x=83.0, y=71.9, text="Shadow Priestess Vandis", section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1891
  {t="T", q=5234, name="Return to the Bulwark", z=85, x=83.04, y=71.91, target={kind="npc", id=11055, name="Shadow Priestess Vandis"}, section="Western Plaguelands", zoneName="Tirisfal Glades"}, -- 1892
  {t="N", text="Ride east through Western Plaguelands into Eastern Plaguelands; Tirion Fordring's cabin is at the west edge", section="Eastern Plaguelands"}, -- 1893
  {t="G", z=139, x=5.19, y=35.57, text="Tirion Fordring", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1894
  {t="A", q=5542, name="Demon Dogs", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1895
  {t="A", q=5543, name="Blood Tinged Skies", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1896
  {t="A", q=5544, name="Carrion Grubbage", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1897
  {t="G", z=139, x=22.2, y=63.48, text="Nathanos Blightcaller", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1898
  {t="A", q=6022, name="To Kill With Purpose", z=139, x=22.23, y=63.51, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1899
  {t="A", q=6042, name="Un-Life's Little Annoyances", z=139, x=22.23, y=63.51, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1900
  {t="C", q=5543, name="Blood Tinged Skies", z=139, x=28.22, y=64.82, note="Plaguebats", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1901
  {t="C", q=6042, name="Un-Life's Little Annoyances", z=139, x=48.25, y=42.13, note="Noxious and Monstrous Plaguebats", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1902
  {t="C", q=5542, name="Demon Dogs", z=139, x=47.78, y=45.53, note="Plaguehounds", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1903
  {t="C", q=5544, name="Carrion Grubbage", z=139, x=48.02, y=49.66, note="Carrion Grubs and Devourers", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1904
  {t="C", q=6022, name="To Kill With Purpose", z=139, x=34.98, y=31.28, note="Scourge at Corin's Crossing", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1905
  {t="G", z=139, x=31.19, y=77.98, text="Pamela Redpath in Darrowshire", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1906
  {t="T", q=5601, name="Sister Pamela", z=139, x=31.15, y=77.98, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1907
  {t="A", q=5149, name="Pamela's Doll", z=139, x=31.15, y=77.98, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1908
  {t="C", q=5149, name="Pamela's Doll", z=139, x=33.1, y=79.67, note="Pamela's doll pieces in the ruined houses", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1909
  {t="T", q=5149, name="Pamela's Doll", z=139, x=31.15, y=77.98, target={kind="npc", id=10926, name="Pamela Redpath"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1910
  {t="G", z=139, x=71.68, y=50.07, text="Light's Hope Chapel", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1911
  {t="FP", z=139, x=70.51, y=47.55, text="Light's Hope flight path (Georgia)", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1912
  {t="A", q=6021, name="Zaeldarr the Outcast", z=139, x=69.93, y=53.72, target={kind="npc", id=11038, name="Caretaker Alen"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1913
  {t="C", q=6021, name="Zaeldarr the Outcast", z=139, x=23.07, y=72.63, note="Zaeldarr the Outcast", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1914
  {t="G", z=139, x=22.2, y=63.48, text="Nathanos Blightcaller", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1915
  {t="T", q=6022, name="To Kill With Purpose", z=139, x=22.23, y=63.51, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1916
  {t="T", q=6042, name="Un-Life's Little Annoyances", z=139, x=22.23, y=63.51, target={kind="npc", id=11878, name="Nathanos Blightcaller"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1917
  {t="G", z=139, x=5.19, y=35.57, text="Tirion Fordring", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1918
  {t="T", q=5542, name="Demon Dogs", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1919
  {t="T", q=5543, name="Blood Tinged Skies", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1920
  {t="T", q=5544, name="Carrion Grubbage", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1921
  {t="A", q=5742, name="Redemption", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1922
  {t="C", q=5742, name="Redemption", z=139, x=5.16, y=35.57, note="Listen to Tirion's story", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1923
  {t="T", q=5742, name="Redemption", z=139, x=5.16, y=35.57, target={kind="npc", id=1855, name="Tirion Fordring"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1924
  {t="G", z=139, x=69.88, y=53.76, text="Caretaker Alen, Light's Hope", section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1925
  {t="T", q=6021, name="Zaeldarr the Outcast", z=139, x=69.93, y=53.72, target={kind="npc", id=11038, name="Caretaker Alen"}, section="Eastern Plaguelands", zoneName="Eastern Plaguelands"}, -- 1926
  {t="G", z=139, x=71.68, y=49.98, text="Betina Bigglezink, Light's Hope Chapel", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1927
  {t="A", q=5212, name="The Flesh Does Not Lie", z=139, x=71.66, y=49.94, target={kind="npc", id=11035, name="Betina Bigglezink"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1928
  {t="G", z=139, x=70.87, y=48.45, text="Smokey LaRue", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1929
  {t="A", q=5214, name="The Great Ezra Grimm", z=139, x=70.88, y=48.43, target={kind="npc", id=11033, name="Smokey LaRue"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1930
  {t="G", z=139, x=71.59, y=50.07, text="Duke Nicholas Zverenhoff", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1931
  {t="A", q=5251, name="The Archivist", z=139, x=71.63, y=50.09, target={kind="npc", id=11039, name="Duke Nicholas Zverenhoff"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1932
  {t="G", z=139, x=71.86, y=48.27, text="Leonid Barthalomew the Revered", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1933
  {t="A", q=5243, name="Houses of the Holy", z=139, x=71.89, y=48.29, target={kind="npc", id=11036, name="Leonid Barthalomew the Revered"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1934
  {t="D", z=139, x=26.52, y=10.36, instance=2017, dungeonName="Stratholme", text="Stratholme, north Eastern Plaguelands", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1935
  {t="C", q=5212, name="The Flesh Does Not Lie", z=139, x=26.52, y=10.36, instance=2017, dungeonName="Stratholme", note="Plagued Flesh Samples from the undead", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1936
  {t="C", q=5214, name="The Great Ezra Grimm", z=139, x=26.52, y=10.36, instance=2017, dungeonName="Stratholme", note="Fras Siabi's smoke shop (Live side)", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1937
  {t="C", q=5251, name="The Archivist", z=139, x=26.52, y=10.36, instance=2017, dungeonName="Stratholme", note="Archivist Galford (Live side)", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1938
  {t="C", q=5243, name="Houses of the Holy", z=139, x=26.52, y=10.36, instance=2017, dungeonName="Stratholme", note="Search the supply crates for holy water", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1939
  {t="G", z=139, x=71.68, y=50.07, text="Light's Hope Chapel", section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1940
  {t="T", q=5212, name="The Flesh Does Not Lie", z=139, x=71.66, y=49.94, target={kind="npc", id=11035, name="Betina Bigglezink"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1941
  {t="T", q=5214, name="The Great Ezra Grimm", z=139, x=70.88, y=48.43, target={kind="npc", id=11033, name="Smokey LaRue"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1942
  {t="T", q=5251, name="The Archivist", z=139, x=71.63, y=50.09, target={kind="npc", id=11039, name="Duke Nicholas Zverenhoff"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1943
  {t="T", q=5243, name="Houses of the Holy", z=139, x=71.89, y=48.29, target={kind="npc", id=11036, name="Leonid Barthalomew the Revered"}, section="Stratholme (dungeon, group of 5)", zoneName="Eastern Plaguelands"}, -- 1944
  {t="N", text="Level 60. Train your last spells; Scholomance needs the key chain from the Bulwark, and Dire Maul, Upper Blackrock Spire and raids open up from here.", section="Stratholme (dungeon, group of 5)"}, -- 1945
}
