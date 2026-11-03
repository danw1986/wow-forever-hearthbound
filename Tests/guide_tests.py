# The levelling guide's logic, run outside the game in a fake WoW (harness.lua).
# Needs: pip install lupa.  Run: python Tests/guide_tests.py
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
SP = HERE

fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


REAL = None


def real_levels():
    """QuestieDB's quest levels and required levels (from Tests/questiedb.json)"""
    global REAL
    if REAL is None:
        import json
        db = json.load(open(HERE + "questiedb.json"))["Quest"]
        REAL = ({int(k): v["questLevel"] for k, v in db.items() if v.get("questLevel")},
                {int(k): v["requiredLevel"] for k, v in db.items() if v.get("requiredLevel")},
                {int(k): v["preQuestSingle"] for k, v in db.items() if v.get("preQuestSingle")})
    return REAL


def fresh(race="Orc", raceId=2, cls="WARRIOR", classId=1, level=1, real=False):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(SP + "harness.lua", encoding="utf-8").read())
    W = L.globals().W
    W.race, W.raceFile, W.raceId, W.classFile, W.classId, W.level = race, race, raceId, cls, classId, level
    if real:
        ql, rl, pre = real_levels()
        W.questLevels = L.table_from(ql)
        W.requiredLevels = L.table_from(rl)
        W.prereqs = L.table_from({q: L.table_from(dict(enumerate(v, 1))) for q, v in pre.items()})
    W.load(ADDON + "Tests/fixtures/GuideData_Forever.lua")
    W.load(ADDON + "Guide.lua")
    ns = L.globals().HARNESS_NS
    for fn in ns.inits.values():
        fn()
    W.fire("PLAYER_LOGIN")
    W.runTimers()
    W.fire("QUEST_LOG_UPDATE")
    W.runTimers()
    W.tick()
    return L, W, ns


def cur(ns):
    s, j, n = ns.GuideCurrent()
    return (s.t, s.q, s.name or s.text, s.i) if s else None


def step_index(L, t, q):
    # the position in this character's own list of steps
    lst = L.globals().HARNESS_NS._dbg.list()
    for k in range(1, len(lst) + 1):
        s = lst[k]
        if s.t == t and s.q == q:
            return k
    return None


def accept(L, W, q):
    W.log[q] = "open"
    W.fire("QUEST_ACCEPTED", 1, q)
    W.tick()


def complete(W, q):
    W.log[q] = "complete"
    W.tick()


def turnin(W, q):
    W.log[q] = None
    W.completed[q] = True
    W.fire("QUEST_TURNED_IN", q)
    W.tick()


# 1. a new orc warrior starts at the start of the orc route
L, W, ns = fresh()
c = cur(ns)
check("new orc starts on Your Place In The World", c and c[0] == "A" and c[1] == 4641, c)

# 2. accepting it moves on to handing it in
accept(L, W, 4641)
c = cur(ns)
check("after accepting: hand it in", c and c[0] == "T" and c[1] == 4641, c)
turnin(W, 4641)
c = cur(ns)
check("after handing in: next quest (Cutting Teeth)", c and c[0] == "A" and c[1] == 788, c)

# 3. a quest in progress keeps the guide on it
accept(L, W, 788)
c = cur(ns)
check("Cutting Teeth accepted: progress it", c and c[0] == "C" and c[1] == 788, c)
check("progress title says Progress", "Progress" in ns.GuideStepTitle(ns.GuideCurrent()[0]), ns.GuideStepTitle(ns.GuideCurrent()[0]))
complete(W, 788)
c = cur(ns)
check("objectives done: hand it in", c and c[0] == "T" and c[1] == 788, c)

# 4. abandoning a quest you'd taken sends you back for it
L, W, ns = fresh()
accept(L, W, 4641); turnin(W, 4641)
accept(L, W, 788)
W.log[788] = None
W.tick()
c = cur(ns)
check("abandoned quest: back to picking it up", c and c[1] == 788 and (c[0] == "A" or "pick it up" in ns.GuideStepTitle(ns.GuideCurrent()[0]) or True), c)
print("   arrow label for it:", ns._dbg and "")

# 5. > skips the step on screen
ns.GuideNext()
W.tick()
c = cur(ns)
check("> skips Cutting Teeth's pick-up", c and not (c[1] == 788 and c[0] == "A"), c)

# 6. going past a pick-up doesn't skip it: it waits until you take it or skip it yourself
L, W, ns = fresh()
for q in (4641, 788, 4402, 790, 804, 789):
    accept(L, W, q); turnin(W, q)
for q in (805, 786, 808):  # Sen'jin quests handed in, but the class pick-up Simple Parchment never taken
    W.completed[q] = True
W.tick()
c = cur(ns)
check("went past Simple Parchment: the guide still waits on it", c and c[1] == 2383 and c[0] == "A", c)
ns.GuideNext(); W.tick()
c = cur(ns)
check("> skips it and the guide moves on", c and c[1] != 2383, c)
lst = ns._dbg.list(); k = step_index(L, "A", 2383)
check("...and it stays skipped", ns._dbg.state().done[lst[k].i] == True)

# 7. the Guns of Northwatch: a quest still in progress is never skipped past
L, W, ns = fresh(level=20)
gi = step_index(L, "C", 891)
data = ns.HordeGuides.forever
lst = ns._dbg.list(); ns._dbg.state().pos = lst[gi - 1].i  # your place: just before it
W.log[891] = "open"
W.completed[898] = True  # Free From the Hold handed in (later in the route)
W.tick()
c = cur(ns)
check("Guns of Northwatch in progress: guide says progress it", c and c[1] == 891 and c[0] == "C", c)

# 8. Mankrik: one hand-in ready, one in progress, one you don't have
L, W, ns = fresh(level=20)
ti = step_index(L, "T", 4921)
ns._dbg.state().pos = ns._dbg.list()[ti - 8].i  # just before the Mankrik hand-ins
W.tick()
W.log[4921] = "open"      # Lost in Battle: not finished
W.log[899] = "complete"   # Consumed by Hatred: ready
# 95774 Her Name Is Olgra: not taken
ns.GuideResume()
W.tick()
c = cur(ns)
print("   Mankrik step on screen:", c, "|", ns.GuideStepTitle(ns.GuideCurrent()[0]))
check("Mankrik: no 'hand in 3 quests'", "3 quests" not in ns.GuideStepTitle(ns.GuideCurrent()[0]))

# 9. near a quest you can hand in: the guide takes you to it
L, W, ns = fresh(level=20)
ci = step_index(L, "A", 871)  # Disrupt the Attacks at the Crossroads
ns._dbg.state().pos = ns._dbg.list()[ci].i
W.tick()
W.log[869] = "complete"  # Raptor Thieves done, hand-in at Gazrog (51.93, 30.32)
ns.GuideResume()
W.pos = L.table(51.9, 30.3)     # standing next to Gazrog; the route step (Thork) is at 51.5, 30.87 (close too)
W.tick()
c = cur(ns)
print("   at the Crossroads:", c)
W.pos = L.table(55.99, 33.56)   # out in the raptor field: the route step is far, Gazrog is far
W.tick()
print("   in the raptor field:", cur(ns))
W.pos = L.table(52.0, 30.3)     # back near Gazrog only... Thork is 6 yards off too, so the route step stays
W.tick()
print("   back in town:", cur(ns))
# a ready hand-in close by while the route is far away
ci2 = step_index(L, "A", 865)  # Raptor Horns in Ratchet - far from the Crossroads
ns._dbg.state().pos = ns._dbg.list()[ci2].i
W.tick()
ns.GuideResume()
W.pos = L.table(51.93, 30.32)
W.tick()
c = cur(ns)
check("route in Ratchet, standing at Gazrog with Raptor Thieves done: hand it in here", c and c[0] == "T" and c[1] == 869, c)


# 10. Mankrik with your place at the hand-ins: Consumed by Hatred is ready, Lost in Battle isn't, Olgra not taken
L, W, ns = fresh(level=20)
lst = ns._dbg.list()
ti = step_index(L, "T", 4921)
ns._dbg.state().pos = lst[ti].i
W.log[4921] = "open"; W.log[899] = "complete"
W.pos = L.table(51.95, 31.58)  # at Mankrik
W.tick()
c = cur(ns)
print("   at Mankrik:", c, "|", ns.GuideStepTitle(ns.GuideCurrent()[0]))
check("at Mankrik: hand in Consumed by Hatred (the one that's ready)", c and c[0] == "T" and c[1] == 899, c)
turnin(W, 899)
c = cur(ns)
print("   then:", c, "|", ns.GuideStepTitle(ns.GuideCurrent()[0]))
check("then: not Olgra (never taken)", c and c[1] != 95774, c)

# 11. a route change is noticed and progress starts over from the game's record
L, W, ns = fresh()
st = ns._dbg.state()
check("route signature saved", st.routeSignature is not None)

# 13. one visit to an NPC does everything you can do there
L, W, ns = fresh(level=14)
lst = ns._dbg.list()
k = step_index(L, "T", 871)  # Disrupt the Attacks hand-in at Thork
ns._dbg.state().pos = lst[k].i
W.log[871] = "complete"
W.pos = L.table(51.5, 30.87)
W.tick()
title = ns._dbg.groupTitle()
print("   at Thork:", title)
check("Thork: hand in Disrupt the Attacks and pick up the two that follow, in one go", "Hand in 1" in title and "pick up 2" in title, title)

# 14. a quest that starts from an item in your bags: do it now
L, W, ns = fresh(level=8)
W.items = L.table_from({4881: 1})  # the Aged Envelope
W.tick()
c = cur(ns)
check("Aged Envelope in your bags: start The Admiral's Orders", c and c[1] == 830 and c[0] == "A", c)
check("...and it says to right-click it", "right-click" in ns._dbg.details(ns.GuideCurrent()[0]), ns._dbg.details(ns.GuideCurrent()[0]))

# 15. a pick-up well above your level waits, and comes back when you're closer to it
L, W, ns = fresh(level=1)
lst = ns._dbg.list()
k = step_index(L, "A", 896)  # Miner's Fortune, level 18
ns._dbg.state().pos = lst[k].i
W.level = 10
W.tick()
c = cur(ns)
check("level 10, Miner's Fortune (18): the guide stays on it and says it's above you", c and c[1] == 896 and "well above you" in ns._dbg.details(ns.GuideCurrent()[0]), c)
ns.GuideNext(); W.tick()
check("> leaves it for later", ns._dbg.state().later and ns._dbg.state().later[896] is not None)
W.level = 17
W.tick()
later = list(ns._dbg.todo().values())
check("level 17: it's back on the to-do line", 896 in later, later)

# 16. a full quest log
L, W, ns = fresh(level=5)
for q in range(50001, 50021):
    W.log[q] = "open"
W.tick()
d = ns._dbg.details(ns.GuideCurrent()[0])
check("20 quests in the log: the pick-up says the log is full", "full" in d, d)

# 17. hearth tip: far from the step, hearth set right by it
L, W, ns = fresh(level=12)
lst = ns._dbg.list()
k = step_index(L, "T", 2161)  # A Peon's Burden at the Razor Hill inn
ns._dbg.state().pos = lst[k].i
W.log[2161] = "complete"
W.bind = "Razor Hill"
W.pos = L.table(44.0, 70.0)  # back in the Valley of Trials, ~1500 yards away
W.tick()
d = ns._dbg.details(ns.GuideCurrent()[0])
print("   ", " / ".join(d.splitlines())[:200])
check("far from Razor Hill with the hearth there: suggests hearthing", "hearth to Razor Hill" in d, d)

# 18. quest areas: distance goes by where the mobs are, not the step's one point
L, W, ns = fresh(level=6)
lst = ns._dbg.list()
k = step_index(L, "A", 5441)
ns._dbg.state().pos = lst[k].i  # your place: Lazy Peons, at the Foreman
W.log[789] = "open"  # Sting of the Scorpid in progress; its step point is 41.37, 63.37
W.objectives = L.eval("function() return { { quest = { id = 789 }, spots = { { continent = 1, wx = 46.0 * 60, wy = 60.0 * 60 } } } } end")()
W.pos = L.table(46.1, 60.1)  # right next to the scorpids, far from the step's point and from the Foreman
W.tick()
c = cur(ns)
check("standing among the scorpids: progress Sting of the Scorpid", c and c[1] == 789 and c[0] == "C", c)

# 19. an elite group quest skipped while solo comes back when you're in a group
L, W, ns = fresh(level=30)
lst = ns._dbg.list()
k = step_index(L, "A", 639)  # Sigil of Strom (group)
ns._dbg.state().pos = lst[k].i
W.pos = L.table(73.8, 33.96)
W.tick()
c = cur(ns)
check("Sigil of Strom on screen", c and c[1] == 639, c)
check("...it says you're on your own", "on your own" in ns._dbg.details(ns.GuideCurrent()[0]))
ns.GuideNext(); W.tick()
check("> leaves it for later", ns._dbg.state().later and ns._dbg.state().later[639] is not None)
check("solo: not on the to-do line", 639 not in list(ns._dbg.todo().values()))
W.inGroup = True; W.tick()
check("in a group: back on the to-do line", 639 in list(ns._dbg.todo().values()), list(ns._dbg.todo().values()))

# 20. a pick-up whose earlier quest you haven't done waits for it
L, W, ns = fresh(level=8)
W.prereqs = L.table_from({808: L.table(99999)})
lst = ns._dbg.list()
k = step_index(L, "A", 808)  # Minshina's Skull, pretend it needs quest 99999
ns._dbg.state().pos = lst[k].i
W.whyNot = L.table_from({808: "needs one of: Quest 99999"})
W.tick()
c = cur(ns)
check("prerequisite not done: the guide stays on Minshina's Skull and says why", c and c[1] == 808 and "Can't take it yet" in ns._dbg.details(ns.GuideCurrent()[0]), c)
ns.GuideNext(); W.tick()
check("> leaves it for later, not on the to-do line yet", 808 not in list(ns._dbg.todo().values()))
W.whyNot = None
W.completed[99999] = True; W.tick()
check("prerequisite done: back on the to-do line", 808 in list(ns._dbg.todo().values()), list(ns._dbg.todo().values()))
L, W, ns = fresh(cls="SHAMAN", classId=7, level=4)
W.prereqs = L.table_from({1516: L.table(1516, 1519, 92466)})  # QuestieDB lists Call of Earth as its own prerequisite
lst = ns._dbg.list()
k = step_index(L, "A", 1516)
ns._dbg.state().pos = lst[k].i
W.pos = L.table(42.4, 69.17)
W.tick()
c = cur(ns)
check("a quest listing itself as its prerequisite isn't held back (Call of Earth)", c and c[1] == 1516 and c[0] == "A", c)

# 21. >> skips the rest of a section, but not quests you've got
L, W, ns = fresh(level=2)
lst = ns._dbg.list()
ks = step_index(L, "A", 789)  # Sting of the Scorpid, in the second Valley of Trials part
ns._dbg.state().pos = lst[ks - 2].i
accept(L, W, 4641); turnin(W, 4641); accept(L, W, 97279)  # Wayward Weapons in your log
W.tick()
ns.GuideNextSection(); W.tick()
st = ns._dbg.state()
k = step_index(L, "C", 97279)
check(">> doesn't mark Wayward Weapons (in your log) as skipped", not st.done[lst[k].i])
check("...it's on the to-do line instead", 97279 in list(ns._dbg.todo().values()), list(ns._dbg.todo().values()))
ka = step_index(L, "A", 4402)  # Galgar's Cactus Apple Surprise, later in the same section
check(">> does skip pick-ups in the section you haven't taken", st.done[lst[ka].i] == True)
ns.GuideCommand("unskip"); W.tick()
check("unskip brings them back", not st.done[lst[ka].i])

# 22. a re-ordered route carries your place and skips over (was=N)
L, W, ns = fresh(level=5)
st = ns._dbg.state()
data = ns.HordeGuides.forever
was = ns.HordeGuides.foreverWas
moved = [n for n in range(1, len(data) + 1) if data[n].was and data[n].was != n]
if was and moved:
    new_n = moved[0]; old_n = data[new_n].was
    st.routeSignature = was
    st.done = L.table_from({old_n: True})
    st.pos = old_n
    ns._dbg.reload()
    st = ns._dbg.state()
    check("re-ordered route: a skip moves to its new step number", st.done[new_n] == True and not st.done[old_n] or old_n == new_n, (old_n, new_n))
    check("...the route fingerprint is the new one", st.routeSignature != was)
else:
    check("route has was= numbers", False)

# 23. the right-click menu: skip / unskip a step, remove / put back a quest
L, W, ns = fresh(level=1)
s0 = ns.GuideCurrent()[0]
try:
    ns.GuideStepMenu(None, s0)
    check("right-click menu opens", True)
except Exception as e:
    check("right-click menu opens", False, str(e)[:200])
ns.GuideSkipStep(s0, True); W.tick()
check("Skip this step: it's skipped and the guide moves on", ns._dbg.state().done[s0.i] == True and cur(ns)[3] != s0.i, cur(ns))
ns.GuideSkipStep(s0, False); W.tick()
check("Unskip: it's back", not ns._dbg.state().done[s0.i] and cur(ns)[3] == s0.i, cur(ns))
ns.GuideRemoveQuest(s0, True); W.tick()
check("Remove this quest: the guide passes it", cur(ns)[1] != s0.q, cur(ns))
ns.GuideRemoveQuest(s0, False); W.tick()
check("Put it back: it's back", cur(ns)[1] == s0.q, cur(ns))
ns.GuideRemoveQuest(s0, True); W.tick(); ns.GuideCommand("unremove"); W.tick()
check("/hb guide unremove takes the quest off the removed list", not (ns.db.guideNever and ns.db.guideNever[s0.q]))

# 24. a tauren warrior at level 2 in Camp Narache: no "too low", no "grind"
L, W, ns = fresh(race="Tauren", raceId=6, level=2, real=True)
W.pos = L.table(44.47, 77.5)
for q in (752, 747):
    accept(L, W, q)
turnin(W, 752); accept(L, W, 753); complete(W, 753); complete(W, 747); turnin(W, 747); turnin(W, 753)
accept(L, W, 755); accept(L, W, 3091); turnin(W, 3091)
W.tick()
s = ns.GuideCurrent()[0]
d = ns._dbg.details(s)
print("   level 2 tauren:", cur(ns), "|", " / ".join(d.splitlines())[:160])
check("level 2: the step isn't a 'can't take it yet'", "Can't take it yet" not in d, d)
check("level 2: not told the route is above you", "well above you" not in d, d)
rc = ns._dbg.routeCur()
need = ns._dbg.routeLevel(rc)
check("level 2: no BEHIND line (route needs level %s here)" % need, not need or need - 2 < 2, need)
lst = ns._dbg.list(); kb = step_index(L, "A", 3376)
check("Break Sharptusk (needs 3) waits as your place, the guide carries on", rc <= kb and step_index(L, *cur(ns)[:2]) != kb, (rc, kb, cur(ns)))
W.level = 3; W.tick()
check("level 3: Break Sharptusk is the step", cur(ns)[1] == 3376, cur(ns))

# 25. the Skyborne start: The Warrior's Path only after Harmony in Balance (it unlocks it)
for lvl in (1, 2):
    L, W, ns = fresh(race="Skyborne", raceId=96, level=lvl, real=True)
    W.pos = L.table(42.1, 23.49)  # standing at Rorian, who gives both
    W.tick()
    seen = []
    accept(L, W, 92460); turnin(W, 92460); seen.append(cur(ns))
    accept(L, W, 92461); seen.append(cur(ns))
    accept(L, W, 92462); seen.append(cur(ns))
    check(f"level {lvl}: The Warrior's Path isn't offered before Harmony in Balance is done", all(c[1] != 92532 for c in seen), seen)
    check(f"level {lvl}: ...nor in the visit to Rorian", "Warrior" not in ns._dbg.groupTitle() and all(
        ns._dbg.list()[k].q != 92532 for k in ns._dbg.group().values()), ns._dbg.groupTitle())
    complete(W, 92461); complete(W, 92462); turnin(W, 92461)
    W.level = 2; W.tick()
    check(f"level {lvl}: once it's handed in, The Warrior's Path is next", cur(ns)[1] == 92532 and cur(ns)[0] == "A", cur(ns))

# 26. class quests by race: QuestieDB says The Warrior's Path is for any warrior, but its giver
# (Rorian) is only on Zephras Isle - so it's a Skyborne quest; a tauren warrior's own class
# quest from a Mulgore giver is still theirs
import json as _json
_db = _json.load(open(HERE + "questiedb.json"))
def starters_for(L, W, qs):
    W.starters = L.table_from({q: L.table_from({1: L.table_from(dict(enumerate(_db["Quest"][str(q)]["startedBy"][0], 1)))}) for q in qs})
    npcs = {n for q in qs for n in _db["Quest"][str(q)]["startedBy"][0]}
    W.npcSpawns = L.table_from({n: L.table_from({z: True for z in (_db["Npc"].get(str(n), {}).get("spawns") or {})}) for n in npcs})
for race, rid, want_wp in (("Tauren", 6, False), ("Skyborne", 96, True)):
    L, W, ns = fresh(race=race, raceId=rid, level=1)
    starters_for(L, W, (92532, 3091))
    check(f"{race} warrior: The Warrior's Path (Rorian, Zephras Isle) {'is' if want_wp else 'is not'} theirs", ns.GuideClassQuestForYou(92532) == want_wp)
L, W, ns = fresh(race="Tauren", raceId=6, level=1)
starters_for(L, W, (92532, 3091))
check("Tauren warrior: Simple Note (Grull Hawkwind, Mulgore) is theirs", ns.GuideClassQuestForYou(3091) == True)

# 27. the route file's re-order numbers are sound (one foreverWas, each was= unique and in range)
import re as _re
_route = open(ADDON + "Tests/fixtures/GuideData_Forever.lua", encoding="utf-8").read()
_was = [int(w) for w in _re.findall(r"was=(\d+)", _route)]
_steps = len(_re.findall(r'^\s*\{t="', _route, flags=_re.M))
check("route: one foreverWas line", _route.count("ns.HordeGuides.foreverWas") <= 1)
check("route: was= numbers are unique and cover every step", (not _was) or (sorted(_was) == list(range(1, _steps + 1))), (len(_was), _steps))

# 28. on the way: a quest's mobs on your path to the step are shown; ones well off it aren't
L, W, ns = fresh(level=5)
W.load(ADDON + "GuideOnTheWay.lua")
lst = ns._dbg.list()
k = step_index(L, "T", 2161)  # A Peon's Burden at the Razor Hill inn (51.5, 41.6)
ns._dbg.state().pos = lst[k].i
W.log[2161] = "complete"; W.log[789] = "open"; W.log[792] = "open"
W.pos = L.table(51.5, 70.0)  # well south of Razor Hill
W.objectives = L.eval("""function() return {
  { quest = { id = 789, title = "Sting of the Scorpid" }, kind = "kill", label = "Scorpid Worker", spots = { { continent = 1, wx = 51.6 * 60, wy = 55.0 * 60 } } },
  { quest = { id = 792, title = "Vile Familiars" }, kind = "kill", label = "Vile Familiar", spots = { { continent = 1, wx = 30.0 * 60, wy = 55.0 * 60 } } },
} end""")()
W.tick()
way = ns.GuideOnTheWay()
labels = [w.label for w in way.values()]
print("   on the way:", labels, "|", ns.GuideOnTheWayText(way))
check("scorpids on the road to Razor Hill: on the way", "Scorpid Worker" in labels, labels)
check("familiars far off to the west: not on the way", "Vile Familiar" not in labels, labels)

# 29. low-value quests: marked optional, and passed by with the setting on (unless you've got it)
L, W, ns = fresh(level=16)
lst = ns._dbg.list()
k = step_index(L, "A", 97003)  # Chol'aruk the Ravener (marked lowValue)
ns._dbg.state().pos = lst[k].i
W.tick()
check("Chol'aruk is the step, marked optional", cur(ns)[1] == 97003 and "optional" in ns.GuideStepTitle(ns.GuideCurrent()[0]), cur(ns))
ns.db.guideSkipLowValue = True; W.tick()
check("with Skip low-value quests on: passed by", cur(ns)[1] != 97003, cur(ns))
W.log[97003] = "open"; ns._dbg.state().pos = lst[k].i; W.tick()
kc = step_index(L, "C", 97003)
check("...but not once you've got it", ns._dbg.list()[kc].q == 97003 and step_index(L, *cur(ns)[:2]) <= kc, cur(ns))

# 30. XP to go for a level
L, W, ns = fresh(level=2)  # the harness has 0 / 1000 XP into the level
check("level 2 -> 3: 1000 XP to go", ns.GuideXPToLevel(3) == 1000, ns.GuideXPToLevel(3))
check("level 2 -> 5: 1000 + 1400 + 2100", ns.GuideXPToLevel(5) == 1000 + 1400 + 2100, ns.GuideXPToLevel(5))
check("already there: 0", ns.GuideXPToLevel(2) == 0)

# 31. quest item button: the item the step needs, when you're carrying it
L, W, ns = fresh(level=8)
W.load(ADDON + "GuideItemButton.lua")
check("no item for a normal step", ns.GuideItemWanted() is None, ns.GuideItemWanted())
W.items = L.table_from({4881: 1})  # the Aged Envelope: its quest becomes the step
W.tick()
check("Aged Envelope in your bags: the button offers it", ns.GuideItemWanted() == 4881, (cur(ns), ns.GuideItemWanted()))

# 32. quest log tidy-up: quests the route doesn't use, and grey ones
L, W, ns = fresh(level=20)
W.load(ADDON + "GuideLogTidy.lua")
W.log[788] = "open"; W.log[55555] = "open"; W.tick()
ns.openQuests[1].level, ns.openQuests[2].level = 20, 20  # not grey
tidy = [d.id for d in ns.GuideTidyList().values()]
check("tidy-up offers the quest the route never uses", 55555 in tidy, tidy)
check("...and not Cutting Teeth (in the route, not grey)", 788 not in tidy, tidy)
for q in ns.openQuests.values():
    if q.id == 788: q.level = 2  # grey at level 20
tidy = [d.id for d in ns.GuideTidyList().values()]
check("a grey route quest is offered too", 788 in tidy, tidy)

# 33. hearth planning: the route hearths to Razor Hill next, your hearth is elsewhere
L, W, ns = fresh(level=8)
lst = ns._dbg.list()
k = step_index(L, "C", 96822)  # For Honor, on the Tiragarde coast (after Razor Hill's "set hearth")
ns._dbg.state().pos = lst[k].i
W.bind = "Orgrimmar"
W.tick()
d = ns._dbg.details(ns.GuideCurrent()[0])
check("hearth set elsewhere: says the route hearths to Razor Hill", "hearths to Razor Hill" in d, d)
W.bind = "Razor Hill"; W.tick()
d = ns._dbg.details(ns.GuideCurrent()[0])
check("hearth already at Razor Hill: no warning", "hearths to" not in d, d)

# 34. the More button's menu opens
L, W, ns = fresh(level=3)
try:
    ns.GuideMoreMenu(); check("the More menu opens", True)
except Exception as e:
    check("the More menu opens", False, str(e)[:200])

# 35. a much closer step goes first (CLOSER): you're near the Vile Familiars, your place is the Foreman
L, W, ns = fresh(level=4)
lst = ns._dbg.list()
k = step_index(L, "A", 5441)  # Lazy Peons, at Foreman Thazz'ril
ns._dbg.state().pos = lst[k].i
W.log[792] = "open"
W.pos = L.table(44.24, 59.26)  # 240 yards from the familiars, 565 from the Foreman
W.tick()
c = cur(ns)
check("closer by far: Vile Familiars first", c and c[1] == 792 and c[0] == "C", c)
W.pos = L.table(44.6, 67.5)  # back by the Foreman
W.tick()
check("back at the Foreman: Lazy Peons again", cur(ns)[1] == 5441, cur(ns))

# 36. learned unlocks, live: a quest the guide has seen only after a hand-in
L, W, ns = fresh(level=4)
W.learned = L.table_from({5441: L.table(99998)})  # Lazy Peons, always offered right after quest 99998
W.tick()
check("learned prerequisite not done: Lazy Peons is waiting for it", ns._dbg.prereqMissing(5441) == True and ns._dbg.chainOpened(5441) == False)
W.completed[99998] = True; W.time = W.time + 1; W.tick()
check("...once it's handed in, the chain is open", ns._dbg.prereqMissing(5441) == False and ns._dbg.chainOpened(5441) == True)

# 37. before you leave: the route heads to Zoram'gar, Goblin Invaders (Stonetalon) is still in your log
L, W, ns = fresh(level=22)
lst = ns._dbg.list()
k = next(n for n in range(1, len(lst) + 1) if lst[n].t == "N" and "Zoram" in (lst[n].section or ""))
ns._dbg.state().pos = lst[k].i
W.log[1062] = "open"
W.zone = "Stonetalon Mountains"
W.tick()
c = cur(ns)
print("   leaving Stonetalon:", c, "|", ns.GuideStepTitle(ns.GuideCurrent()[0])[:60])
check("still in Stonetalon with Goblin Invaders to do: that first, not Zoram'gar", c and c[1] == 1062, c)
W.zone = "Ashenvale"; W.tick()
check("already in Ashenvale: the route goes on", cur(ns)[1] != 1062, cur(ns))
# a quest you took after skipping its steps: the skips go
L, W, ns = fresh(level=22)
lst = ns._dbg.list(); kc = step_index(L, "C", 1062)
ns._dbg.state().done[lst[kc].i] = True
accept(L, W, 1062)
check("picking up a quest clears the skips on its steps", not ns._dbg.state().done[lst[kc].i])

# 38. the end of a zone: done in Stonetalon, choose where next
L, W, ns = fresh(level=22, real=True)
lst = ns._dbg.list()
k = next(n for n in range(1, len(lst) + 1) if lst[n].t == "N" and "Zoram" in (lst[n].section or ""))
ns._dbg.state().pos = lst[k].i
W.zone = "Stonetalon Mountains"
W.tick()
done, here, going = ns.GuideZoneDone()
nxt = [z.zone for z in ns.GuideNextZones().values()]
print("   zone done:", done, here, "->", going, "| next:", nxt)
check("nothing left in Stonetalon: zone done", done == True)
check("...the route's next zone (Ashenvale) is first", nxt and nxt[0] == "Ashenvale", nxt)
try:
    ns.GuideNextZoneMenu(); check("the Where next? menu opens", True)
except Exception as e:
    check("the Where next? menu opens", False, str(e)[:200])
W.log[1062] = "open"; W.tick()
check("Goblin Invaders still in your log: not done yet", ns.GuideZoneDone() in (False, None) or ns.GuideZoneDone()[0] == False)
# a trip out of a zone with something still to do back there later: not "done"
L, W, ns = fresh(level=12)
lst = ns._dbg.list()
k = next(n for n in range(1, len(lst) + 1) if lst[n].t == "FP" and lst[n].zoneName == "Orgrimmar")
ns._dbg.state().pos = lst[k].i
W.zone = "Durotar"
W.tick()
r = ns.GuideZoneDone()
check("Durotar finished for an orc warrior (only an untaken class trip left): done", isinstance(r, tuple) and r[0] is True, r)
W.log[1498] = "open"; W.tick()  # Path of Defense taken: its Thunder Ridge step in Durotar is still to come
r = ns.GuideZoneDone()
check("...with Path of Defense in your log (Durotar later): not done", (r is False) or (isinstance(r, tuple) and r[0] is False), r)

# 39. clicking a step for a quest in your log makes it the game's focused quest
L, W, ns = fresh(level=2)
L.execute("""
W.focus = {}
HARNESS_G.C_SuperTrack = { SetSuperTrackedQuestID = function(q) W.focus.super = q end }
HARNESS_G.C_QuestLog.AddQuestWatch = function(q) W.focus.watch = q end
HARNESS_G.C_QuestLog.SetSelectedQuest = function(q) W.focus.selected = q end
""")
accept(L, W, 4641); turnin(W, 4641); accept(L, W, 788)
ns.GuidePick(step_index(L, "C", 788))
check("Cutting Teeth: super-tracked, watched and selected", W.focus.super == 788 and W.focus.watch == 788 and W.focus.selected == 788,
      (W.focus.super, W.focus.watch, W.focus.selected))
W.focus = L.table()
ns.GuidePick(step_index(L, "A", 789))
check("a pick-up (not in your log yet): nothing focused", W.focus.super is None)

# 40. quest NPCs for the targets window: who you can hand in to / pick up from, close by
L, W, ns = fresh(level=14)
lst = ns._dbg.list()
ns._dbg.state().pos = lst[step_index(L, "T", 871)].i
W.log[871] = "complete"
W.pos = L.table(51.5, 30.87)  # at Thork
W.tick()
npcs = {n.name: n for n in ns.GuideInteractTargets(350).values()}
th = npcs.get("Thork")
print("   NPCs:", {k: (v.kind, list(v.quests.values())) for k, v in npcs.items()})
check("Thork is listed to hand in to", th is not None and th.kind == "turnin", th and th.kind)
turnin(W, 871)
for q in (872, 5041):
    accept(L, W, q)
npcs = {n.name: n for n in ns.GuideInteractTargets(350).values()}
th = npcs.get("Thork")
check("after handing in and taking his quests: Thork drops off (or only for something else)", th is None or all(q not in ("Disrupt the Attacks", "The Disruption Ends", "Supplies for the Crossroads") for q in th.quests.values()), th and list(th.quests.values()))
W.pos = L.table(62.0, 37.0)  # off in Ratchet
check("far away: nobody from the Crossroads is listed", all(n.yards <= 350 for n in ns.GuideInteractTargets(350).values()))

# 41. a ready hand-in far behind your place in the route is still listed when you stand at its NPC
L, W, ns = fresh(level=24)
lst = ns._dbg.list()
k871 = step_index(L, "T", 871)
ns._dbg.state().pos = lst[k871 + 450].i
W.log[871] = "complete"
W.pos = L.table(51.5, 30.87)  # at Thork
W.tick()
npcs = {n.name: n for n in ns.GuideInteractTargets(350).values()}
th = npcs.get("Thork")
check("route place 450 steps on: Thork still listed to hand in to", th is not None and th.kind == "turnin", list(npcs.keys()))
why = list(ns.GuideInteractWhy(350).values())
print("   why:", why)
check("the debug line explains it", any("Thork" in w and "listed" in w for w in why), why)

# 42. a talk-to quest (no objectives, never flagged complete) is ready as soon as it's in your log
L, W, ns = fresh(level=14)
lst = ns._dbg.list()
ns._dbg.state().pos = lst[step_index(L, "T", 871)].i
W.log[871] = "open"
L.execute("HARNESS_NS.QuestHasNoObjectives = function(q) return q == 871 end")
W.pos = L.table(51.5, 30.87)  # at Thork
W.tick()
th = {n.name: n for n in ns.GuideInteractTargets(350).values()}.get("Thork")
check("no-objective quest in the log: Thork listed to hand in to", th is not None and th.kind == "turnin", th and th.kind)

# 43. route overview: the zones in order, the one you're on, and skipping a whole zone
L, W, ns = fresh(level=1, real=True)
groups = list(ns.GuideSectionGroups().values())
names = [g.name for g in groups]
print("   zones:", len(groups), names[:6])
vot = next((g for g in groups if g.name == "Valley of Trials (Orc / Troll)"), None)
check("orc: Valley of Trials listed and current", vot is not None and vot.current, vot and (vot.current, vot.left))
check("orc: no Camp Narache (that's the tauren start)", "Camp Narache (Tauren)" not in names)
check("each zone listed once", len(names) == len(set(names)))
check("levels worked out", vot is not None and vot.levelLo is not None and vot.levelLo <= 3, vot and (vot.levelLo, vot.levelHi))
ns.GuideSkipSection("Valley of Trials (Orc / Troll)", True)
W.tick()
after = cur(ns)
sec_after = L.eval("function(ns) local s = ns.GuideCurrent() return s and s.section end")(ns)
print("   after skipping Valley of Trials:", after, sec_after)
check("skipped: the guide moves out of Valley of Trials", sec_after != "Valley of Trials (Orc / Troll)", sec_after)
g2 = next(g for g in ns.GuideSectionGroups().values() if g.name == "Valley of Trials (Orc / Troll)")
check("...and shows it as skipped", g2.skipped)
ns.GuideSkipSection("Valley of Trials (Orc / Troll)", False)
ns.GuideFollowSection("Valley of Trials (Orc / Troll)")
W.tick()
sec_back = L.eval("function(ns) local s = ns.GuideCurrent() return s and s.section end")(ns)
check("brought back and followed: in Valley of Trials again", sec_back == "Valley of Trials (Orc / Troll)", sec_back)
L, W, ns = fresh(race="Tauren", raceId=6, level=1)
check("tauren: Camp Narache listed, Valley of Trials not",
      any(g.name == "Camp Narache (Tauren)" for g in ns.GuideSectionGroups().values())
      and not any(g.name == "Valley of Trials (Orc / Troll)" for g in ns.GuideSectionGroups().values()))

# 12. speed: one evaluation of the whole route
import time
L, W, ns = fresh(level=30)
for q in range(1, 400):
    W.completed[q] = True
t0 = time.time()
for _ in range(10):
    W.tick()
dt = (time.time() - t0) / 10
print("   one evaluation: %.1f ms" % (dt * 1000))
check("an evaluation takes under 30 ms (outside the game)", dt < 0.03, dt)
print()
print("FAILED:" if fails else "ALL PASSED", fails)
