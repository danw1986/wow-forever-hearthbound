# Replay a character's saved route state in the fake WoW, follow a
# zone, and show where the guide goes and why it passes each step.
#   python Tests/replay_route.py <Character-Realm> ["section name start"] [level]
import glob
import os
import sys

from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
WTF = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "WTF", "Account"))
who = sys.argv[1] if len(sys.argv) > 1 else "Falling-Death"
want = sys.argv[2] if len(sys.argv) > 2 else None
char_file = glob.glob(os.path.join(WTF, "*", "*", who, "SavedVariables", "Hearthbound.lua"))[0]
acct_file = glob.glob(os.path.join(WTF, "*", "SavedVariables", "Hearthbound.lua"))[0]

src = open(HERE + "route_tests.py", encoding="utf-8").read().split("# 1. each race starts")[0]
src = src.replace("os.path.abspath(__file__)", "os.path.abspath(r'" + HERE + "route_tests.py')")
g = {}
exec(compile(src, "route_tests", "exec"), g)
RACES = {"orc": 2, "undead": 5, "scourge": 5, "tauren": 6, "troll": 8, "skyborne": 96}
CLASSES = {"warrior": 1, "paladin": 2, "hunter": 3, "rogue": 4, "priest": 5, "shaman": 7, "mage": 8, "warlock": 9, "druid": 11}

S = LuaRuntime()
S.execute(open(acct_file, encoding="utf-8").read())
S.execute(open(char_file, encoding="utf-8").read())
acct, char = S.globals().HearthboundDB, S.globals().HearthboundCharDB
path = acct["learn"] and acct["learn"]["path"] and acct["learn"]["path"][who]
race = (os.environ.get("RACE") or (path and path["race"]) or "orc").lower()
cls = (os.environ.get("CLASS") or (path and path["class"]) or "warrior").lower()
level = int(sys.argv[3]) if len(sys.argv) > 3 else (path and path[len(path)] and path[len(path)]["level"] or 20)
print(f"{who}: {race} {cls}, level {level}")

L, W, ns = g["fresh"](race=race.title(), raceId=RACES.get(race, 2), cls=cls.upper(), classId=CLASSES.get(cls, 1), level=level)
saved = char["guide"]["horde"]
# your settings
for k in acct.keys():
    if str(k).startswith("guide") and not hasattr(acct[k], "keys"):
        ns.db[k] = acct[k]
if acct["guideNever"]:
    ns.db.guideNever = L.table_from({int(q): True for q in acct["guideNever"].keys()})
if os.environ.get("ZONE"):
    W.zone = os.environ["ZONE"]
st = ns._dbg.state()
for key in ("pos", "live", "force", "hold"):
    st[key] = saved[key]
if os.environ.get("HOLD") == "0":
    st.hold = False
st.zoneMarks = L.table_from({k: int(v) for k, v in saved["zoneMarks"].items()} if saved["zoneMarks"] else {})
st.zoneHistory = L.table_from(dict(saved["zoneHistory"].items()) if saved["zoneHistory"] else {})
st.done = L.table_from({int(k): bool(v) for k, v in saved["done"].items()} if saved["done"] else {})
st.taken = L.table_from({int(k): True for k in saved["taken"].keys()} if saved["taken"] else {})
handed = {int(k) for k in char["quests"].keys()} if char["quests"] else set()
W.completed = L.table_from({q: True for q in handed})
for q in (int(k) for k in (saved["taken"] or {}).keys()):
    if q not in handed:
        W.log[q] = "open"
W.tick()
lst = ns._dbg.list()


def show(label):
    s, j, n = ns.GuideCurrent()
    print(f"{label}: step {j}/{n} {s.t} {s.q} {s.name or s.text} | {s.section} | place {s.place}")


show("now")
if want:
    names = [g.name for g in ns.GuideSectionGroups(True).values()]
    name = next((x for x in names if x.startswith(want)), None)
    print("follow:", name)
    if os.environ.get("READY"):
        for q in os.environ["READY"].split(","):
            W.log[int(q)] = "complete"
    if os.environ.get("AT"):
        x, y = os.environ["AT"].split(",")
        W.pos = L.table_from({1: float(x), 2: float(y)})
    ns.GuideFollowSection(name)
    W.tick()
    show("after following")
    for t in range(6):
        W.time = W.time + 2
        W.fire("ZONE_CHANGED")
        W.fire("ZONE_CHANGED_NEW_AREA")
        W.runTimers()
        W.tick()
    show("a few seconds later")
    print("route place:", ns._dbg.routeCur())
    print("window step bar:", ns._dbg.places())
    # why each step of that section is passed
    why = L.eval("""function(ns, j) return ns.GuideWhy and ns.GuideWhy(j) end""")
    first = next(k for k in range(1, len(lst) + 1) if lst[k].section == name)
    for k in range(first, len(lst) + 1):
        s = lst[k]
        if s.section != name:
            break
        passed = ns._dbg.passed(k) if ns._dbg.passed else None
        req = g["RL"].get(s.q) if s.q else None
        blocked, low, orphan, gamedone = ns._dbg.why(k)
        print(f"  {k:5d} {s.t:2s} {str(s.q or ''):6s} {(s.name or s.text or '')[:30]:30s} passed={passed} done={bool(st.done[s.i])} game={gamedone} blocked={blocked} low={low} orphan={orphan} req={req}")

if os.environ.get("BACK"):
    for _ in range(int(os.environ["BACK"])):
        ns._dbg.stepPlace(-1)
    W.tick()
    show("after pressing < " + os.environ["BACK"] + " times")
    print("window step bar:", ns._dbg.places(), " your place:", ns._dbg.routeCur(), " looking:", st.hold)
    for t in range(8):
        W.time = W.time + 2
        W.runTimers()
        W.tick()
    show("16 seconds later")
    print("window step bar:", ns._dbg.places(), " your place:", ns._dbg.routeCur(), " looking:", st.hold)
