# Which quests are worth the walk? For each quest: the XP it gives against the
# extra walking it adds to the route (the route's path with its steps, minus the
# path without them). The worst trade-offs get lowValue=true in the route file;
# the guide marks them "optional" and can skip them (Settings).
#
#   python Tests/route_value.py [GuideData_Forever.lua] [--write]
#
# Uses route_optimize.py's XP data (QuestieDB's table, Forever estimates, and
# what the guide has learned from your play).
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.argv = [sys.argv[0]] + [a for a in sys.argv[1:]]
WRITE = "--write" in sys.argv
args = [a for a in sys.argv[1:] if a != "--write"]
SRC = args[0] if args else os.path.join(HERE, "fixtures", "GuideData_Forever.lua")

# borrow the optimiser's parsing and XP model without running it
_opt = open(os.path.join(HERE, "route_optimize.py"), encoding="utf-8").read()
_opt = _opt.split("# ---------------------------------------------------------------- run")[0]
_ns = {"__file__": os.path.join(HERE, "route_optimize.py")}
sys_argv, sys.argv = sys.argv, [sys.argv[0], SRC, os.devnull]
exec(compile(_opt, "route_optimize.py", "exec"), _ns)
sys.argv = sys_argv
S, cost, quest_xp, stretches = _ns["S"], _ns["cost"], _ns["quest_xp"], _ns["stretches"]

LOW_SHARE = 0.10        # the worst 10% (by XP per map-percent of extra walking)...
MIN_EXTRA = 12.0        # ...that add at least this much walking (map percent)


def path_len(steps):
    pts = [s for s in steps if s["placed"]]
    return sum(cost(a, b) for a, b in zip(pts, pts[1:]))


# quests something else in the route needs: never "optional" (skipping one loses its chain)
prereqs, DB = _ns["prereqs"], _ns["DB"]
needed = set()
names = {}
for s in S:
    if s["q"]:
        names.setdefault(s["name"], set()).add(s["q"])
        needed |= prereqs(s["q"])
        rec = DB.get(str(s["q"])) or {}
        if rec.get("nextQuestInChain"):
            needed.add(s["q"])
        if rec.get("breadcrumbForQuestId"):
            needed.add(s["q"])
for name, qs in names.items():
    if len(qs) > 1:
        needed |= qs  # the parts of a same-name chain
group_quests = {s["q"] for s in S if "group=true" in s["line"]}

values = []
for kind, seq in stretches:
    if kind != "move":
        continue
    common = [s for s in seq if not s["races"] and not s["classes"]]
    quests = {s["q"] for s in common if s["q"]}
    whole = path_len(common)
    for q in quests:
        if q in needed or q in group_quests:
            continue
        without = [s for s in common if s["q"] != q]
        extra = whole - path_len(without)
        if extra <= 0:
            continue
        xp = quest_xp(q)
        name = next(s["name"] for s in common if s["q"] == q)
        values.append((xp / extra if extra else math.inf, q, name, xp, extra, seq[0]["section"]))

values.sort()
cut = [v for v in values[: int(len(values) * LOW_SHARE)] if v[4] >= MIN_EXTRA]
print(f"{len(values)} quests rated; {len(cut)} low value (bottom {int(LOW_SHARE * 100)}%, adding {MIN_EXTRA:.0f}%+ walking):")
for ratio, q, name, xp, extra, sec in cut:
    print(f"  {name[:36]:36} {xp:5.0f} XP for {extra:5.1f}% extra walking  ({ratio:5.1f} XP per %)  [{sec[:40]}]")

if WRITE:
    low = {v[1] for v in cut}
    text = open(SRC, encoding="utf-8").read()
    lines = text.split("\n")
    out = []
    for line in lines:
        line = line.replace(" lowValue=true,", "")
        m = re.search(r'\bq=(\d+)', line)
        if m and int(m.group(1)) in low and re.match(r'\s*\{t="', line):
            line = re.sub(r'(\bq=\d+,)', r'\1 lowValue=true,', line, count=1)
        out.append(line)
    open(SRC, "w", encoding="utf-8", newline="").write("\n".join(out))
    print(f"marked in {SRC}")
