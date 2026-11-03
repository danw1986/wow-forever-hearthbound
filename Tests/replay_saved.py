# Replay a character's real saved guide state in the fake WoW, to see exactly what
# the guide decides and why: your place, skips, picked step, quests taken and
# handed in, from the saved variables.
#
#   python Tests/replay_saved.py <Character-Realm> [level] [x y]
#
# The quest log itself isn't saved, so quests you took (state.taken) and haven't
# handed in count as in your log, not finished. Pass x y (map percent in the
# step's zone) to stand somewhere.
import glob
import os
import sys

from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
WTF = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "WTF", "Account"))

who = sys.argv[1] if len(sys.argv) > 1 else "Falling-Death"
char_file = glob.glob(os.path.join(WTF, "*", "*", who, "SavedVariables", "Hearthbound.lua"))[0]
acct_file = glob.glob(os.path.join(WTF, "*", "SavedVariables", "Hearthbound.lua"))[0]

src = open(HERE + "guide_tests.py", encoding="utf-8").read().split("# 1. a new orc")[0]
src = src.replace("os.path.abspath(__file__)", "os.path.abspath(r'" + HERE + "guide_tests.py')")
g = {}
exec(compile(src, "guide_tests", "exec"), g)

RACES = {"orc": 2, "undead": 5, "scourge": 5, "tauren": 6, "troll": 8, "skyborne": 96}
CLASSES = {"warrior": 1, "paladin": 2, "hunter": 3, "rogue": 4, "priest": 5, "shaman": 7, "mage": 8, "warlock": 9, "druid": 11}

# who the character is, from what the guide learned
S = LuaRuntime()
S.execute(open(acct_file, encoding="utf-8").read())
S.execute(open(char_file, encoding="utf-8").read())
acct, char = S.globals().HearthboundDB, S.globals().HearthboundCharDB
path = acct["learn"] and acct["learn"]["path"] and acct["learn"]["path"][who]
race = (path and path["race"] or "orc").lower()
cls = (path and path["class"] or "warrior").lower()
level = int(sys.argv[2]) if len(sys.argv) > 2 else (path and path[len(path)] and path[len(path)]["level"] or 20)
print(f"{who}: {race} {cls}, level {level}")

L, W, ns = g["fresh"](race=race.title(), raceId=RACES.get(race, 2), cls=cls.upper(), classId=CLASSES.get(cls, 1), level=level, real=True)
saved = char["guide"]["forever"]
st = ns._dbg.state()
# copy the saved state across
for key in ("pos", "live", "force", "hold", "routeSignature", "skipCleanup"):
    st[key] = saved[key]
st.done = L.table_from({int(k): bool(v) for k, v in saved["done"].items()} if saved["done"] else {})
st.taken = L.table_from({int(k): True for k in saved["taken"].keys()} if saved["taken"] else {})
st.later = L.table_from({int(k): int(v) for k, v in saved["later"].items()} if saved["later"] else {})
handed = {int(k) for k in char["quests"].keys()} if char["quests"] else set()
W.completed = L.table_from({q: True for q in handed})
in_log = [q for q in (int(k) for k in (saved["taken"] or {}).keys()) if q not in handed]
for q in in_log:
    W.log[q] = "open"
if len(sys.argv) > 4:
    W.pos = L.table(float(sys.argv[3]), float(sys.argv[4]))
W.tick()

lst = ns._dbg.list()
s, j, n = ns.GuideCurrent()
rc = ns._dbg.routeCur()
print(f"in your log (taken, not handed in): {in_log}")
print(f"your place (routeCur): {rc} = step {lst[rc].i} {lst[rc].t} {lst[rc].name or lst[rc].text}")
print(f"on screen: {j} = step {s.i} {s.t} {s.name or s.text}  [{s.section}]")
print("details: " + " / ".join(ns._dbg.details(s).splitlines()))
print("to-do line:", [lst[k].name for k in L.eval("function(f) local t = {} for _, k in ipairs(f()) do t[#t+1] = k end return t end")(ns._dbg.todo and (lambda: None) or None).values()] if False else list(ns._dbg.todo().values()))
print("\nthe steps around your place (S = skipped, D = done, > = shown):")
for k in range(max(1, rc - 8), min(len(lst), rc + 25) + 1):
    o = lst[k]
    flag = "S" if st.done[o.i] else " "
    mark = ">" if k == j else " "
    passed = ns._dbg.passed(k)
    print(f" {mark}{flag} {k:5} step {o.i:5} {o.t:2} {str(o.q or ''):>6} {(o.name or o.text or '')[:40]:40} passed={passed}  [{o.section[:30]}]")
