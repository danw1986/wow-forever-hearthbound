# Rebuild the Forever route from everything known: QuestieDB plus what the guide
# has learned from your play (GuideLearn.lua, in your saved variables).
#
#   python Tests/rebuild_route.py            build Tests/GuideData_Forever.optimized.lua and check it
#   python Tests/rebuild_route.py --install  ...and if every check passes, back up the route and
#                                            put the new one in place (your place carries over)
#
# Steps: what's been learned -> re-order (route_optimize.py) -> rate quests (route_value.py)
# -> route audit -> positions -> guide tests. Log out (or /reload) first so the saved
# variables have your latest play.
import datetime
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.normpath(os.path.join(HERE, ".."))
ROUTE = os.path.join(ADDON, "Tests", "fixtures", "GuideData_Forever.lua")
OUT = os.path.join(HERE, "GuideData_Forever.optimized.lua")
PY = sys.executable


def run(*args):
    r = subprocess.run([PY, *args], cwd=ADDON, capture_output=True, text=True, encoding="utf-8", errors="replace")
    return r.returncode, (r.stdout or "") + (r.stderr or "")


def learned_summary():
    """what the guide has learned, compared with QuestieDB"""
    src = open(os.path.join(HERE, "route_optimize.py"), encoding="utf-8").read()
    part = src.split("LEARNED = load_learned()")[0]
    ns = {"__file__": os.path.join(HERE, "route_optimize.py")}
    exec(compile("import os, re, json, math, sys\n" + part.split("# ---------------------------------------------------------------- XP and levels")[0], "x", "exec"), ns)
    exec(compile(part.split("# ---------------------------------------------------------------- XP and levels")[1], "y", "exec"), ns)
    learned = ns["load_learned"]()
    db = ns["DB"]
    new_links = []
    for q, o in learned["offers"].items():
        if o["samples"] < 1:
            continue
        pre = {p for p, n in o["after"].items() if n >= o["samples"] and p != q}
        known = set((db.get(str(q)) or {}).get("preQuestSingle") or []) | set((db.get(str(q)) or {}).get("preQuestGroup") or [])
        for p in pre - known:
            new_links.append((q, p, o["samples"]))
    return learned, new_links, db


print("1. What the guide has learned from your play")
learned, links, db = learned_summary()
print(f"   {len(learned['offers'])} quest offers, {len(learned['quests'])} quests with XP and levels"
      + (f", {learned['share'] * 100:.0f}% of your XP from quests" if learned["share"] else ""))
if links:
    print(f"   {len(links)} quest chain links QuestieDB doesn't have (quest <- the one handed in just before it, every time):")
    for q, p, n in sorted(links)[:20]:
        print(f"     {(db.get(str(q)) or {}).get('name', q)} <- {(db.get(str(p)) or {}).get('name', p)}  (seen {n}x)")
else:
    print("   no new quest chain links yet - play with \"Learn from my play\" on, then run this again")

print("2. Re-ordering")
code, out = run(os.path.join(HERE, "route_optimize.py"), ROUTE, OUT)
print("   " + "\n   ".join(out.strip().splitlines()[:6]))
if code:
    sys.exit("   the optimiser failed")

print("3. Rating quests (XP against the walk)")
code, out = run(os.path.join(HERE, "route_value.py"), OUT, "--write")
print("   " + out.strip().splitlines()[0])

checks = [("route audit", ["route_audit.py", OUT, os.path.join(HERE, "questiedb.json")]),
          ("positions", ["route_places.py", OUT])]
ok = True
print("4. Checks")
code, out = run(os.path.join(HERE, "route_audit.py"), OUT, os.path.join(HERE, "questiedb.json"))
bad = [l for l in out.splitlines() if l.startswith("== ") and not l.startswith("== prereq not handed in yet: 3")]
print("   audit: " + ("ok" if not bad else "; ".join(bad)))
ok = ok and not bad and code == 0
code, out = run(os.path.join(HERE, "route_places.py"), OUT)
print("   positions: " + out.strip().splitlines()[0])

# the guide tests against the new route: swap it in temporarily
backup = ROUTE + ".testing"
shutil.copy(ROUTE, backup)
try:
    shutil.copy(OUT, ROUTE)
    code, out = run(os.path.join(HERE, "guide_tests.py"))
    last = [l for l in out.splitlines() if "PASSED" in l or l.startswith("FAIL")]
    print("   guide tests: " + (last[-1] if last else "no result"))
    ok = ok and code == 0 and any("ALL PASSED" in l for l in last)
finally:
    shutil.copy(backup, ROUTE)
    os.remove(backup)

if "--install" in sys.argv:
    if not ok:
        sys.exit("5. Not installed: a check failed (see above). The route is unchanged.")
    stamp = datetime.datetime.now().strftime("%Y-%m-%d_%H%M")
    saved = os.path.join(ADDON, "RouteBackups", f"GuideData_Forever_before_rebuild_{stamp}.lua")
    shutil.copy(ROUTE, saved)
    shutil.copy(OUT, ROUTE)
    print(f"5. Installed. The old route is in {os.path.relpath(saved, ADDON)}. /reload in game.")
else:
    print("5. Checked" + (" - all good. Run with --install to put it in place." if ok else " - a check failed, see above."))
