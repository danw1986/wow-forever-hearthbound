# Every class gets its own help, in the fake WoW (wowmock.lua): the spec is recognised,
# rewards are scored for it, class quests, talents, supplies and the trainer section
# all fit the character, and the whole addon runs clean as each class.
# Run: python Tests/class_tests.py
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
fails = []
FILES = [l.strip() for l in open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8") if l.strip() and not l.startswith("#")]
SOURCES = {f: open(os.path.join(ADDON, f), encoding="utf-8").read() for f in FILES}
# class -> a race and class ID that go together
CLASSES = {"WARRIOR": ("Orc", 1), "PALADIN": ("Scourge", 2), "HUNTER": ("Tauren", 3), "ROGUE": ("Scourge", 4), "PRIEST": ("Troll", 5),
           "SHAMAN": ("Tauren", 7), "MAGE": ("Troll", 8), "WARLOCK": ("Scourge", 9), "DRUID": ("Tauren", 11)}


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


def play(cls, level=20, race=None, faction="Horde", setup=""):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
    race = race or CLASSES[cls][0]
    L.execute(f"""
    UnitClass = function() return "{cls}", "{cls}", {CLASSES[cls][1]} end
    UnitRace = function() return "{race}", "{race}", 1 end
    UnitFactionGroup = function() return "{faction}", "{faction}" end
    W = {{ level = {level}, spells = {{}}, done = {{}}, points = nil, unspent = 0 }}
    UnitLevel = function() return W.level end
    IsPlayerSpell = function(id) return W.spells[id] == true end
    UnitCharacterPoints = function() return W.unspent end
    C_QuestLog.IsQuestFlaggedCompleted = function(q) return W.done[q] == true end
    C_SpecializationInfo = {{
        GetSpecializationInfo = function(i)
            if not W.points then return nil end
            return i, W.trees[i], "", 0, "", "", W.points[i] or 0
        end,
    }}
    C_Spell = {{ GetSpellTexture = function() return 132341 end, GetSpellName = function(id) return id == 433 and "Food" or (id == 430 and "Drink") or nil end }}
    {setup}
    """)
    ns = L.table()
    load = L.eval("""function(src, name, ns)
        local fn, err = load(src, "@" .. name)
        if not fn then return false, err end
        local ok, e = pcall(fn, "Hearthbound", ns)
        return ok, e
    end""")
    errors = []
    for f in FILES:
        ok, err = load(SOURCES[f], f, ns)
        if not ok:
            errors.append(f"{f}: {err}")
    fire = L.eval("""function(event, ...)
        local args = { ... }
        for _, f in ipairs(MOCK.frames) do
            local fn = rawget(f, "_scripts") and f._scripts.OnEvent
            local ev = rawget(f, "_events")
            if type(ev) ~= "table" then ev = nil end
            if fn and (not ev or ev[event]) then
                local ok, err = xpcall(fn, debug.traceback, f, event, table.unpack(args))
                if not ok then table.insert(MOCK.errors, event .. ": " .. tostring(err)) end
            end
        end
    end""")
    fire("ADDON_LOADED", "Hearthbound")
    fire("PLAYER_LOGIN")
    fire("PLAYER_ENTERING_WORLD", True, False)
    L.globals().MOCK.RunTimers()
    return L, ns, fire, errors


def section(L, ns, order, level):
    """what a panel section writes, as text"""
    out = L.eval("""function(ns, order, level)
        local out = {}
        local function Text(t) out[#out + 1] = tostring(t) end
        local add = { header = function(t) Text("H:" .. t) end, note = function(t) Text(t) end,
                      row = function(a, b) Text(tostring(a) .. " " .. tostring(b)) end,
                      list = function(a, b) Text(tostring(a) .. " " .. tostring(b)) end, bar = function() end }
        for _, s in ipairs(ns.sections) do
            if s.order == order then s.build(add, level) end
        end
        return out
    end""")(ns, order, level)
    return list(out.values())


def trees(L, cls, points):
    """spends talent points: the names are the class's own, in tab order"""
    L.globals().W.points = L.table_from(dict(enumerate(points, 1)))
    L.execute(f"""
    W.trees = {{}}
    for i, spec in ipairs(HB_NS_DATA.{cls}.specs) do W.trees[i] = spec.names[1] end
    """)


def share_data(L, ns):
    L.globals().HB_NS_DATA = ns.CLASS_DATA


# 1. every class: everything loads, and every window and panel section runs clean
for cls in CLASSES:
    L, ns, fire, errors = play(cls, level=30)
    run = L.eval("""function(ns)
        local errs = {}
        for _, s in ipairs(ns.sections) do
            local add = setmetatable({}, { __index = function() return function() end end })
            local ok, err = pcall(s.build, add, 30)
            if not ok then errs[#errs + 1] = tostring(err) end
        end
        for _, cmd in ipairs({ "spec", "achievements", "quests", "stats", "journey", "dungeons", "alts", "debug" }) do
            local ok, err = pcall(SlashCmdList.HEARTHBOUND, cmd)
            if not ok then errs[#errs + 1] = cmd .. ": " .. tostring(err) end
        end
        pcall(ns.UpdatePanel)
        MOCK.RunTimers()
        return errs
    end""")(ns)
    problems = errors + list(run.values()) + list(L.globals().MOCK.errors.values())
    check(f"{cls}: the whole addon runs clean", not problems, problems[:3])
    data = ns.CLASS_DATA[cls]
    key, label, source, spent = ns.PlayerSpec()
    check(f"{cls}: starts on the usual levelling spec", key == data.default and source == "default" and label, (key, source))
    check(f"{cls}: has stat weights, chains and a talent plan for every spec",
          all(data.weights[s.key] and data.builds[s.key] and len(list(data.builds[s.key].picks.values())) > 40
              for s in data.specs.values()) and len(list(data.quests.values())) >= 4)

# 2. the spec follows your talents; /hb spec overrides them
L, ns, fire, _ = play("PRIEST", level=30)
share_data(L, ns)
trees(L, "PRIEST", [2, 0, 9])
ns.ForgetSpec()
key, label, source, spent = ns.PlayerSpec()
check("the tree with the most points is your spec", key == "shadow" and source == "talents", key)
check("...and the points spent are counted", spent == 11, spent)
trees(L, "PRIEST", [12, 0, 3])
ns.ForgetSpec()
check("put more into another tree: the spec follows", ns.PlayerSpec()[0] == "discipline")
L.globals().SlashCmdList.HEARTHBOUND("spec holy")
key, label, source, _ = ns.PlayerSpec()
check("/hb spec holy: treated as holy", key == "holy" and source == "chosen", key)
L.globals().SlashCmdList.HEARTHBOUND("spec auto")
check("/hb spec auto: back to your talents", ns.PlayerSpec()[0] == "discipline")
L.globals().SlashCmdList.HEARTHBOUND("spec nonsense")
check("/hb spec nonsense: nothing changes", ns.PlayerSpec()[0] == "discipline")

# 3. the next talent comes from your spec's plan
L, ns, fire, _ = play("MAGE", level=12)
share_data(L, ns)
trees(L, "MAGE", [0, 0, 2])
ns.ForgetSpec()
pick = ns.NextTalentPick()[0]
want = ns.CLASS_DATA.MAGE.builds.frost.picks[3]
check("two points in Frost: the plan's third pick is next", pick.t == want.t and pick.tree == want.tree, pick.t)
L.globals().W.unspent = 1
lines = section(L, ns, 20, 12)
check("the trainer section suggests it, with your spec", any(want.t in l and "Frost" in l for l in lines), lines)
L, ns, fire, _ = play("MAGE", level=12)
L.globals().W.unspent = 1
check("a client that can't count talents: no made-up advice", not any("Suggested" in l for l in section(L, ns, 20, 12)))

# 4. class quests: the right chains for class, race and level, and they clear
for cls, race, level, want, not_want in (
        ("DRUID", "Tauren", 20, "Cat Form", "Teleports"),
        ("HUNTER", "Tauren", 10, "Taming the Beast", "Felhunter"),
        ("WARLOCK", "Scourge", 10, "Voidwalker", "Cat Form"),
        ("SHAMAN", "Tauren", 10, "Call of Fire", "Poisons"),
        ("ROGUE", "Scourge", 20, "Poisons", "Totem"),
        ("MAGE", "Troll", 20, "Teleports", "Voidwalker"),
        ("PRIEST", "Troll", 10, "Hex of Weakness", "Touch of Weakness"),
        ("PALADIN", "Scourge", 5, "Tyr's Watch", "Verigan"),
        ("WARRIOR", "Orc", 10, "Defensive Stance", "Whirlwind")):
    L, ns, fire, _ = play(cls, level=level, race=race)
    open_now = [q.title for q in ns.ClassQuestReminders(level).values()]
    check(f"{cls} at {level}: told about {want}", any(want in t for t in open_now), open_now)
    check(f"{cls} at {level}: not about {not_want}", not any(not_want in t for t in open_now), open_now)
    lines = section(L, ns, 25, level)
    check(f"{cls} at {level}: the panel shows it", lines[0] == "H:Class quests" and len(lines) <= 5, lines)

L, ns, fire, _ = play("DRUID", level=20, race="Tauren")
W = L.globals().W
titles = lambda: [q.title for q in ns.ClassQuestReminders(W.level).values()]
check("a druid's forms come before anything else", titles()[0] in ("Bear Form and Moonglade", "Cure Poison", "Aquatic Form", "Cat Form"), titles())
W.spells[768] = True
check("once you know Cat Form the reminder goes", "Cat Form" not in titles(), titles())
W.level = 45
check("a spell you never learned is still mentioned at 45", "Aquatic Form" in titles(), titles())
L, ns, fire, _ = play("PRIEST", level=15, race="Scourge")
check("another race's chain isn't offered", "Hex of Weakness and Shadowguard" not in [q.title for q in ns.ClassQuestReminders(15).values()])
L, ns, fire, _ = play("WARRIOR", level=35)
titles = [q.title for q in ns.ClassQuestReminders(35).values()]
L.globals().W.spells[2458] = True
titles2 = [q.title for q in ns.ClassQuestReminders(35).values()]
check("Berserker Stance learned, the Whirlwind weapon's still ahead: it stays", "Whirlwind Weapon" in titles and "Whirlwind Weapon" in titles2, titles2)
L, ns, fire, _ = play("SHAMAN", level=52, race="Dwarf", faction="Alliance")
check("another faction's chain isn't offered", "Spirit Totem and Da Voodoo" not in [q.title for q in ns.ClassQuestReminders(52).values()])

L, ns, fire, _ = play("MAGE", level=20, race="Troll")
W = L.globals().W
tele = next(q for q in ns.ClassQuestsForMe().values() if q.title == "Teleports and Portals")
W.spells[3567] = True
check("one teleport of a ladder of six isn't the whole chain done", not ns.ClassQuestDone(tele))
for s in tele.spells.values():
    W.spells[s] = True
check("all six are", ns.ClassQuestDone(tele))

L, ns, fire, _ = play("ROGUE", level=30, race="Scourge")
W = L.globals().W
blade = next(q for q in ns.ClassQuestsForMe().values() if q.title == "The Eye of Bhossca")
check("a chain with no spell is open in its level range", "The Eye of Bhossca" in [q.title for q in ns.ClassQuestReminders(30).values()])
W.done[blade.ends[1].q] = True
check("hand in its last quest: done", ns.ClassQuestDone(blade) and "The Eye of Bhossca" not in [q.title for q in ns.ClassQuestReminders(30).values()])
W.done[blade.ends[1].q] = False
check("...and past its level range it drops off without nagging", "The Eye of Bhossca" not in [q.title for q in ns.ClassQuestReminders(45).values()])

L, ns, fire, _ = play("WARLOCK", level=20, race="Scourge")
before = [q.title for q in ns.ClassQuestReminders(20).values()]
L.eval("""function(ns)
    local add = setmetatable({ note = function(_, _, click) FIRST_CLICK = FIRST_CLICK or click end, header = function() end },
                             { __index = function() return function() end end })
    for _, s in ipairs(ns.sections) do if s.order == 25 then s.build(add, 20) end end
    FIRST_CLICK()
end""")(ns)
after = [q.title for q in ns.ClassQuestReminders(20).values()]
check("clicking a reminder hides that one", len(after) == len(before) - 1 and before[0] not in after, (before, after))

# 5. rewards are scored for your class and spec
ITEMS = """
ITEMS = {
    ["robe"] = { loc = "INVTYPE_CHEST", class = 4, sub = 1, stats = { ITEM_MOD_INTELLECT_SHORT = 8, ITEM_MOD_SPIRIT_SHORT = 5, RESISTANCE0_NAME = 20 } },
    ["sp-robe"] = { loc = "INVTYPE_CHEST", class = 4, sub = 1, stats = { ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = 12, RESISTANCE0_NAME = 20 } },
    ["heal-robe"] = { loc = "INVTYPE_CHEST", class = 4, sub = 1, stats = { ITEM_MOD_SPELL_HEALING_DONE_SHORT = 12, RESISTANCE0_NAME = 20 } },
    ["leather"] = { loc = "INVTYPE_CHEST", class = 4, sub = 2, stats = { ITEM_MOD_AGILITY_SHORT = 40, RESISTANCE0_NAME = 90 } },
    ["mail"] = { loc = "INVTYPE_CHEST", class = 4, sub = 3, stats = { ITEM_MOD_STRENGTH_SHORT = 8, ITEM_MOD_AGILITY_SHORT = 4, RESISTANCE0_NAME = 200 } },
    ["plate"] = { loc = "INVTYPE_CHEST", class = 4, sub = 4, stats = { ITEM_MOD_STRENGTH_SHORT = 12, ITEM_MOD_STAMINA_SHORT = 8, RESISTANCE0_NAME = 400 } },
    ["tank-plate"] = { loc = "INVTYPE_CHEST", class = 4, sub = 4, stats = { ITEM_MOD_STAMINA_SHORT = 18, RESISTANCE0_NAME = 450 } },
    ["dps-plate"] = { loc = "INVTYPE_CHEST", class = 4, sub = 4, stats = { ITEM_MOD_STRENGTH_SHORT = 16, RESISTANCE0_NAME = 300 } },
    ["bow"] = { loc = "INVTYPE_RANGED", class = 2, sub = 2, stats = { ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 12 } },
    ["axe"] = { loc = "INVTYPE_2HWEAPON", class = 2, sub = 1, stats = { ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 12, ITEM_MOD_STRENGTH_SHORT = 3 } },
    ["staff"] = { loc = "INVTYPE_2HWEAPON", class = 2, sub = 10, stats = { ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 10 } },
}
local function Item(link) return ITEMS[link] end
GetItemInfo = function(link)
    local i = Item(link)
    if not i then return nil end
    return link, link, 2, 20, 1, "", "", 1, i.loc, "", 500, i.class, i.sub
end
C_Item = { GetItemInfo = GetItemInfo, GetItemStats = function(link) return Item(link) and Item(link).stats end,
           GetItemInfoInstant = function(link)
               local i = Item(link)
               if i then return 1, "", "", i.loc, "", i.class, i.sub end
           end }
GetItemStats = C_Item.GetItemStats
GetItemInfoInstant = C_Item.GetItemInfoInstant
CHOICES = {}
GetNumQuestChoices = function() return #CHOICES end
GetQuestItemLink = function(_, i) return CHOICES[i] end
GetInventoryItemLink = function() return nil end
"""


def reward(cls, choices, level=45, spec=None, race=None):
    L, ns, fire, _ = play(cls, level=level, race=race, setup=ITEMS)
    L.globals().CHOICES = L.table_from(dict(enumerate(choices, 1)))
    if spec:
        L.globals().SlashCmdList.HEARTHBOUND("spec " + spec)
    index, why = ns.BestQuestReward()[:2]
    return choices[index - 1] if index else None, why


pick, why = reward("MAGE", ["plate", "leather", "robe"])
check("a mage is never offered leather or plate, whatever its stats", pick == "robe" and why == "upgrade", (pick, why))
pick, why = reward("PRIEST", ["sp-robe", "heal-robe"], spec="shadow")
check("a shadow priest takes spell damage", pick == "sp-robe", pick)
pick, why = reward("PRIEST", ["sp-robe", "heal-robe"], spec="holy")
check("a holy priest takes healing", pick == "heal-robe", pick)
pick, why = reward("WARRIOR", ["tank-plate", "dps-plate"], spec="arms")
check("an arms warrior takes strength", pick == "dps-plate", pick)
pick, why = reward("WARRIOR", ["tank-plate", "dps-plate"], spec="protection")
check("a protection warrior takes stamina and armour", pick == "tank-plate", pick)
pick, why = reward("HUNTER", ["bow", "axe"])
check("a hunter takes the bow over an axe of the same DPS", pick == "bow", pick)
pick, why = reward("ROGUE", ["mail", "leather"])
check("a rogue can't take mail", pick == "leather", pick)
pick, why = reward("WARRIOR", ["plate", "leather"], level=30)
check("plate waits for 40", pick == "leather", pick)
pick, why = reward("DRUID", ["staff", "robe"], spec="feral")
check("a feral druid values the staff's DPS", pick == "staff", pick)
pick, why = reward("DRUID", ["staff", "robe"], spec="balance")
check("a balance druid values intellect over it", pick == "robe", pick)
pick, why = reward("MAGE", ["plate", "axe"])
check("nothing a mage can use: it picks what sells best", why == "sell", (pick, why))

# 6. supplies: what your class runs on
BAGS = """
BAG = {}
C_Container = {
    GetContainerNumSlots = function(bag) return bag == 0 and #BAG or 0 end,
    GetContainerNumFreeSlots = function() return 10, 0 end,
    GetContainerItemInfo = function(bag, slot) local b = BAG[slot] return b and { itemID = b[1], stackCount = b[2] } end,
}
local SPELLS = { [100] = "Food", [101] = "Drink" }
C_Item = { GetItemSpell = function(id) return SPELLS[id] end,
           GetItemInfo = function(id) return "thing", "", 1, 20, 20 end,
           GetItemInfoInstant = function(id)
               if id == 500 then return 1, "", "", "", "", 2, 2 end -- a bow
               if id == 501 then return 1, "", "", "", "", 6, 2 end -- arrows
           end }
GetItemSpell = C_Item.GetItemSpell
GetItemInfoInstant = C_Item.GetItemInfoInstant
GetInventoryItemID = function(_, slot) if slot == 18 then return RANGED end end
"""


def supplies(cls, bag, level=20, ranged=None, spells=(), happiness=None):
    L, ns, fire, _ = play(cls, level=level, setup=BAGS)
    G = L.globals()
    G.RANGED = ranged
    G.BAG = L.table_from({i: L.table_from({1: a, 2: b}) for i, (a, b) in enumerate(bag, 1)})
    for s in spells:
        G.W.spells[s] = True
    if happiness:
        L.execute(f"GetPetHappiness = function() return {happiness} end")
    fire("BAG_UPDATE_DELAYED")
    return section(L, ns, 41, level)


FED = [(100, 20), (101, 20)]
check("a warrior isn't told about drink", not any("drink" in l for l in supplies("WARRIOR", [(100, 20)])))
check("a rogue isn't either", not any("drink" in l for l in supplies("ROGUE", [(100, 20)])))
check("a priest with no drink is told", any("No drink" in l for l in supplies("PRIEST", [(100, 20)])))
check("well stocked: nothing to say", supplies("PRIEST", FED) == [], supplies("PRIEST", FED))
check("a mage is told to conjure, not to find an innkeeper", any("conjure" in l for l in supplies("MAGE", [])))
check("a hunter low on arrows is told", any("arrows" in l for l in supplies("HUNTER", FED + [(501, 50)], ranged=500)))
check("...with plenty, isn't", not any("arrows" in l for l in supplies("HUNTER", FED + [(501, 400)], ranged=500)))
check("...nor with no bow to feed", not any("arrows" in l for l in supplies("HUNTER", FED)))
check("a warrior with a bow isn't nagged about arrows", not any("arrows" in l for l in supplies("WARRIOR", [(100, 20)], ranged=500)))
check("a hungry pet is mentioned", any("pet" in l for l in supplies("HUNTER", FED, happiness=1)))
check("a happy one isn't", not any("pet" in l for l in supplies("HUNTER", FED, happiness=3)))
check("a warlock with a voidwalker needs shards", any("Soul Shards" in l for l in supplies("WARLOCK", FED, spells=[697])))
check("a warlock without one doesn't yet", not any("Soul Shards" in l for l in supplies("WARLOCK", FED)))
check("shards in the bags: fine", not any("Soul Shards" in l for l in supplies("WARLOCK", FED + [(6265, 5)], spells=[697])))
check("a rogue with Vanish needs powder", any("Flash Powder" in l for l in supplies("ROGUE", [(100, 20)], spells=[1856])))
check("a shaman with Reincarnation needs an ankh", any("Ankh" in l for l in supplies("SHAMAN", FED, spells=[20608])))
check("a mage's teleports need runes", any("Runes" in l for l in supplies("MAGE", FED, spells=[3567])))

# 7. the trainer section doesn't claim what it can't know
L, ns, fire, _ = play("MAGE", level=20)
lines = section(L, ns, 20, 20)
check("a mage who hasn't visited a trainer is asked to", any("Visit your class trainer" in l for l in lines), lines)
check("...not told they're up to date", not any("Up to date" in l for l in lines), lines)
L, ns, fire, _ = play("WARRIOR", level=20)
lines = section(L, ns, 20, 20)
check("a warrior still has the built-in list", not any("Visit your class trainer" in l for l in lines), lines)

# 8. the words fit the character
L, ns, fire, _ = play("WARLOCK")
check("a warlock's mount isn't a riding trainer", "Felsteed" in ns.MountReminderText())
L, ns, fire, _ = play("PALADIN")
check("a paladin's isn't either", "Warhorse" in ns.MountReminderText())
L, ns, fire, _ = play("ROGUE")
check("everyone else's is", "riding trainer" in ns.MountReminderText())

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
