# The Horde route (GuideData.lua) in the guide, outside the game
# (harness.lua): each race starts in its own zone, objective steps and optional
# steps behave, and a character who does what the guide shows gets from level
# 1 to the end of the route without the guide getting stuck.
# Run: python Tests/route_tests.py
import json
import os
import sys
import time
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
fails = []
DB = json.load(open(HERE + "questiedb.json"))["Quest"]
QL = {int(k): v["questLevel"] for k, v in DB.items() if v.get("questLevel")}
RL = {int(k): v["requiredLevel"] for k, v in DB.items() if v.get("requiredLevel")}
PRE = {int(k): v["preQuestSingle"] for k, v in DB.items() if v.get("preQuestSingle")}


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


def fresh(race="Tauren", raceId=6, cls="WARRIOR", classId=1, level=1):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(HERE + "harness.lua", encoding="utf-8").read())
    W = L.globals().W
    W.race, W.raceFile, W.raceId, W.classFile, W.classId, W.level = race, race, raceId, cls, classId, level
    W.questLevels = L.table_from(QL)
    W.requiredLevels = L.table_from(RL)
    W.prereqs = L.table_from({q: L.table_from(dict(enumerate(v, 1))) for q, v in PRE.items()})
    W.objs = L.table()
    L.execute("""HARNESS_G.C_QuestLog.GetQuestObjectives = function(q)
        local o = W.objs[q]
        if not o then return nil end
        local out = {}
        for i = 1, 6 do out[i] = { finished = o[i] == true } end
        return out
    end""")
    ns = L.globals().HARNESS_NS
    ns.db.guideEdition = "horde"
    W.load(ADDON + "GuideData.lua")
    W.load(ADDON + "Guide.lua")
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
    return (s.t, s.q, s.name or s.text, s.section) if s else None


def accept(W, q):
    W.log[q] = "open"
    W.fire("QUEST_ACCEPTED", 1, q)


def turnin(W, q):
    W.log[q] = None
    W.completed[q] = True
    W.fire("QUEST_TURNED_IN", q)


# 1. each race starts in its own zone
for race, rid, want in (("Tauren", 6, "Mulgore"), ("Orc", 2, "Durotar"), ("Troll", 8, "Durotar"),
                        ("Scourge", 5, "Tirisfal"), ("Skyborne", 96, "Zephras")):
    L, W, ns = fresh(race=race, raceId=rid)
    c = cur(ns)
    check(f"{race} starts in {want}", c and want in (c[3] or ""), c)

# 2. a step for one objective is done when that objective is, not the whole quest
L, W, ns = fresh(race="Skyborne", raceId=96)
accept(W, 92460); W.tick(); turnin(W, 92460); W.tick()
accept(W, 92461); W.tick(); accept(W, 92462); W.tick()
c = cur(ns)
check("Skyborne: on the Harmony in Balance objective", c and c[0] == "C" and c[1] == 92461, c)
W.objs[92461] = L.table_from({1: True})
W.tick()
c = cur(ns)
check("its objective done (quest not complete yet): on to Infestation Investigation's", c and c[1] == 92462, c)

# 3. an optional pick-up never holds you up
lst = ns._dbg.list()
opt = None
for k in range(1, len(lst) + 1):
    s = lst[k]
    if s.optional and s.t == "A":
        opt = k
        break
check("the route has optional pick-ups", opt is not None)

# 4. standing by a hand-in the route had moved past: the guide does it there and then
L, W, ns = fresh(race="Tauren", raceId=6, level=8)
lst = ns._dbg.list()
k_yaw = next(k for k in range(1, len(lst) + 1) if lst[k].t == "T" and lst[k].q == 96130)
yaw = lst[k_yaw]
for q in (96130, 756):
    W.log[q] = "complete"
ns._dbg.state().pos = lst[k_yaw + 12].i  # the route is a dozen steps on
W.pos = L.table_from({1: yaw.x, 2: yaw.y})
W.tick()
c = cur(ns)
check("at Bloodhoof with two ready hand-ins the route passed: hand them in now", c and c[0] == "T" and c[1] in (96130, 756), c)
turnin(W, c[1] if c else 0)
W.tick()
# then whatever else is right there (a pick-up beside you counts), and the other hand-in - all in the village
other = 756 if c and c[1] == 96130 else 96130
handed, far, trail = False, [], []
for _ in range(5):
    s, j, _ = ns.GuideCurrent()
    trail.append((s.t, s.q, s.name))
    if s.x and ((s.x - yaw.x) ** 2 + (s.y - yaw.y) ** 2) ** 0.5 > 10:  # 10% of the map: ~100 yards
        far.append((s.t, s.q, s.name, s.x, s.y))
    if s.t == "T" and s.q == other:
        handed = True
        break
    if s.t == "A":
        accept(W, s.q)
    elif s.t == "T":
        turnin(W, s.q)
    W.pos = L.table_from({1: s.x or yaw.x, 2: s.y or yaw.y})
    W.tick()
check("...then the other one within a few steps", handed, trail)
check("...without being sent out of the village first", not far, far)

# 5. following a zone starts at its first step left to do - not at an old bookmark at its end
L, W, ns = fresh(race="Orc", raceId=2, level=24)
lst = ns._dbg.list()
sec = "Hillsbrad Foothills & The Barrens (25-27)"
ks = [k for k in range(1, len(lst) + 1) if lst[k].section == sec]
st = ns._dbg.state()
st.zoneMarks = L.table_from({"Hillsbrad Foothills": lst[ks[-1]].i})
ns.GuideFollowSection(sec)
W.tick()
s_, j, _ = ns.GuideCurrent()
at, of = ns._dbg.places()
check("following Hillsbrad with a bookmark at its end: starts at its first place", j == ks[0] or at == 1, (j, ks[0], at, of, s_.name or s_.text))

# 6. a note held as your picked step (from an old save) lets go - it never pulls the guide back
L, W, ns = fresh(race="Tauren", raceId=6, level=1)
lst = ns._dbg.list()
note = next(k for k in range(200, len(lst) + 1) if lst[k].t == "N")
st = ns._dbg.state()
st.force = lst[note].i
st.pos = lst[1].i
W.tick()
s_, j, _ = ns.GuideCurrent()
check("a stuck picked note is let go: back on your place", j < note and st.force != lst[note].i, (j, note, st.force))

# 7. steps that apply only sometimes: checked as you play, kept in the route
STATE = """
HARNESS_G.UnitXP = function() return W.xp or 0 end
HARNESS_G.GetNumSkillLines = function() return #(W.skills or {}) end
HARNESS_G.GetSkillLineInfo = function(i) return W.skills[i], false end
"""


def playing(race="Tauren", raceId=6, cls="WARRIOR", classId=1, level=1):
    L, W, ns = fresh(race=race, raceId=raceId, cls=cls, classId=classId, level=level)
    L.execute(STATE)
    return L, W, ns, ns._dbg.list()


def find(lst, **want):
    return next((k for k in range(1, len(lst) + 1) if all(getattr(lst[k], f) == v for f, v in want.items())), None)


# a top-up to a part-way level
L, W, ns, lst = playing(level=16)
k = find(lst, t="N", lvlBelow=16.51)
check("the route has a top-up to level 16.51", k is not None)
W.xp = 400
check("at level 16.4 the top-up applies", ns._dbg.whenHolds(lst[k]))
W.xp = 600
check("at level 16.6 it doesn't, and passes by itself", not ns._dbg.whenHolds(lst[k]) and ns._dbg.passed(k))

# the way past a group quest: only if you skipped the quest
L, W, ns, lst = playing(level=42)
k = find(lst, t="N", solo=208)
check("the route has a way past the group quest 208", k is not None)
check("you skipped it, short of the level: grind", ns._dbg.whenHolds(lst[k]))
turnin(W, 208)
W.tick()
check("you did it: no need", not ns._dbg.whenHolds(lst[k]) and ns._dbg.passed(k))

# hearth if it's bound there, walk if it isn't
L, W, ns, lst = playing(level=30)
h, g = find(lst, t="H", bound="Freewind Post"), find(lst, t="G", notBound="Freewind Post")
check("the route has both ways to Freewind Post", h is not None and g is not None)
W.bind = "Freewind Post"
check("bound there: the hearth step stays, the walk passes", not ns._dbg.passed(h) and ns._dbg.passed(g))
W.bind = "Orgrimmar"
check("bound elsewhere: the walk stays, the hearth passes", ns._dbg.passed(h) and not ns._dbg.passed(g))

# a weapon skill: only if you can pay for it and haven't got it
L, W, ns, lst = playing(level=20)
k = find(lst, t="TR", noSkill="Two-Handed Axes")
check("a Warrior's route offers Two-Handed Axes", k is not None and lst[k].moneyMin == 1000)
W.money = 999
check("short of the fee: passed", ns._dbg.passed(k))
W.money = 1000
check("can pay: stays", not ns._dbg.passed(k))
L, W, ns, lst = playing(level=20)
W.money = 1000
W.skills = L.table_from({1: "Two-Handed Axes"})
check("already learned: passed", ns._dbg.passed(find(lst, t="TR", noSkill="Two-Handed Axes")))

# only with the quest in your log
L, W, ns, lst = playing(level=12)
fake = L.table_from({"onQuest": L.table_from({1: 871, 2: 872})})
check("neither quest in the log: doesn't apply", not ns._dbg.whenHolds(fake))
W.log[872] = "open"
W.fire("QUEST_LOG_UPDATE")
W.tick()
check("one of them in the log: applies", ns._dbg.whenHolds(fake))
check("a quest done on the way never stops the route", lst[find(lst, t="C", q=871, optional=True) or 1].optional)

# handed in under another ID (Forever does this): noticed, though the list of names is kept between checks
L, W, ns, lst = playing(level=12)
k = find(lst, t="T", q=lst[find(lst, t="A")].q)
s_ = lst[k]
check("a hand-in not done yet", not ns._dbg.why(k)[3])
ns.cdb.quests = ns.cdb.quests or L.table()
ns.cdb.quests[999999] = L.table_from({"title": s_.name})
W.time = W.time + 1
check("a quest of the same name handed in under another ID counts", ns._dbg.why(k)[3])

# > on the step card through a section never sends you back: a place whose only step doesn't
# apply to you (Chen's Empty Keg, unless it's in your log), then a note, used to snap back to
# the last step you'd landed on
L, W, ns = fresh(race="Orc", raceId=2, level=19)
ns.db.guideListLayout = False
ns.GuideFollowSection("The Barrens (19-23)")
W.tick()
places, back = [ns._dbg.places()[0]], None
for press in range(30):
    ns._dbg.stepPlace(1)
    W.tick()
    s_, j, _ = ns.GuideCurrent()
    if s_.section != "The Barrens (19-23)":
        break
    at = ns._dbg.places()[0]
    if at < places[-1] and back is None:
        back = (places[-1], at, s_.name or s_.text)
    places.append(at)
check("pressing > on the card goes forward through the Barrens, never back", back is None and len(places) > 12, (back, places[:16]))

# Forever's new quests are marked NEW wherever the guide names them; Classic's aren't
L, W, ns = fresh(race="Skyborne", raceId=96, level=1)
lst = ns._dbg.list()
fresh_q = next(lst[k] for k in range(1, len(lst) + 1) if lst[k].t == "A" and lst[k].foreverOnly)
old_q = None
L2, W2, ns2 = fresh(race="Orc", raceId=2, level=1)
lst2 = ns2._dbg.list()
old_q = next(lst2[k] for k in range(1, len(lst2) + 1) if lst2[k].t == "A" and not lst2[k].foreverOnly)
check("a new Forever quest: NEW in the step title", "NEW" in ns.GuideStepTitle(fresh_q), ns.GuideStepTitle(fresh_q))
check("...and on the card's goal line", "NEW" in ns._dbg.goalLine(fresh_q), ns._dbg.goalLine(fresh_q))
check("a Classic quest: no NEW in either", "NEW" not in ns2.GuideStepTitle(old_q) and "NEW" not in ns2._dbg.goalLine(old_q),
      (ns2.GuideStepTitle(old_q), ns2._dbg.goalLine(old_q)))
groups = {g.name: g for g in ns.GuideSectionGroups(True).values()}
zeph = groups.get("Zephras Isle (1-14)")
check("the zone overview counts Zephras Isle's new quests", zeph and 0 < zeph.newQuests <= zeph.quests, zeph and (zeph.newQuests, zeph.quests))
groups2 = {g.name: g for g in ns2.GuideSectionGroups(True).values()}
dur = groups2.get("Durotar (1-12)")
check("...and Durotar's, fewer of them", dur and dur.newQuests < dur.quests, dur and (dur.newQuests, dur.quests))

# 8. what the import has to get right
data = open(ADDON + "GuideData.lua", encoding="utf-8").read()
check("every quest has its real name", 'name="Quest ' not in data)
check("no deathskips: they're opt-in upstream, and never on Hardcore", "Deathskip" not in data)
check("the route says which upstream it's adapted from, and its licence", "polestar v0.3.2 (guides/forever), GPL-3.0-only" in data)
# Mulgore is one of the maps Forever redrew: typed in Era's frame, converted to Forever's
check("a typed Mulgore point lands where it is on Forever's map", 'text="The Venture Co. Mine", z=215, x=61.19, y=49.31' in data)
for race, rid, want in (("Orc", 2, "The Barrens (12-16)"), ("Troll", 8, "The Barrens (12-16)"), ("Tauren", 6, "The Barrens (12-16)")):
    L, W, ns, lst = playing(race=race, raceId=rid)
    secs = [lst[k].section for k in range(1, len(lst) + 1)]
    check(f"{race} goes from the start zone to {want}", want in secs and secs[0].split(" (")[0] in ("Durotar", "Mulgore"), secs[0])

# 9. walk the route: do whatever the guide shows, see that it never gets stuck


def walk(race, rid, cls="WARRIOR", cid=1, limit=12000):
    L, W, ns = fresh(race=race, raceId=rid, cls=cls, classId=cid)
    lst = ns._dbg.list()
    total = len(lst)
    last, stuck, did, worst = None, 0, {"A": 0, "T": 0, "C": 0, "other": 0}, None
    seen_sections = []
    t0 = time.time()
    for n in range(limit):
        s, j, _ = ns.GuideCurrent()
        if not s:
            break
        if not seen_sections or seen_sections[-1] != s.section:
            seen_sections.append(s.section)
        if j == last:
            stuck += 1
            if stuck > 4:
                return False, f"stuck at {j}/{total}: {(s.t, s.q, s.name or s.text, s.section)}", did, seen_sections, n
        else:
            stuck = 0
        last = j
        q = s.q
        if s.t == "A":
            W.level = max(W.level, RL.get(q, 1))
            accept(W, q)
            did["A"] += 1
        elif s.t == "C":
            if s.obj:
                o = W.objs[q] or L.table()
                o[s.obj] = True
                W.objs[q] = o
            else:
                W.log[q] = "complete"
            did["C"] += 1
        elif s.t == "T":
            if W.log[q] is None and not W.completed[q]:
                accept(W, q)  # (a pick-up the guide let you pass by - you'd have it from earlier)
            turnin(W, q)
            W.level = min(60, max(W.level, QL.get(q, 1)))
            did["T"] += 1
        else:
            ns.GuideSkipStep(s, True)  # arrived, flew, trained...
            did["other"] += 1
        W.time = W.time + 1
        W.tick()
        # the guide's place at the end of the route: done
        s2, j2, _ = ns.GuideCurrent()
        if j2 == total and (s2.t not in ("A", "C", "T")):
            break
    return True, f"{time.time() - t0:.1f}s", did, seen_sections, n


for race, rid, cls, cid in (("Tauren", 6, "WARRIOR", 1), ("Orc", 2, "HUNTER", 3), ("Troll", 8, "SHAMAN", 7),
                            ("Scourge", 5, "MAGE", 8), ("Skyborne", 96, "DRUID", 11)):
    ok, info, did, secs, n = walk(race, rid, cls, cid)
    print(f"   {race} {cls}: {info}, {n} actions, did {did}")
    print(f"   zones: {' > '.join(s.split(' (')[0] for s in secs[:12])} ...")
    check(f"{race} {cls}: the route plays through without the guide getting stuck", ok, info)
    check(f"{race} {cls}: most of the route's hand-ins get done", did["T"] > 600, did)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
