# How much the route makes you walk, and where it doubles back.
# Run: python Tests/route_travel.py [GuideData_Forever.lua] [race]
# Map percent is used as distance (zones differ in size, so compare within a zone).
import collections
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "fixtures", "GuideData_Forever.lua")
races = sys.argv[2:] or ["orc", "troll", "tauren", "undead", "skyborne"]

steps = []
for line in open(path, encoding="utf-8"):
    m = re.match(r'\s*\{t="(\w+)"', line)
    if not m:
        continue
    d = {"t": m.group(1), "n": len(steps) + 1}
    for key, pat in (("q", r'\bq=(\d+)'), ("z", r'\bz=(\d+)'), ("x", r'\bx=([\d.]+)'), ("y", r'\by=([\d.]+)')):
        v = re.search(pat, line)
        d[key] = float(v.group(1)) if v else None
    n = re.search(r'name="([^"]*)"', line) or re.search(r'text="([^"]*)"', line)
    d["name"] = n.group(1) if n else ""
    r = re.search(r'races=\{([^}]*)\}', line)
    d["races"] = re.findall(r'"([^"]+)"', r.group(1)) if r else None
    d["classes"] = "classes=" in line
    d["section"] = (re.search(r'section="([^"]*)"', line) or [None, ""])[1]
    tg = re.search(r'target=\{kind="(\w+)", id=(\d+), name="([^"]*)"', line)
    d["who"] = (tg.group(1) + tg.group(2), tg.group(3)) if tg else None
    steps.append(d)


def dist(a, b):
    return math.hypot(a["x"] - b["x"], a["y"] - b["y"])


for race in races:
    path_steps = [s for s in steps if (not s["races"] or race in s["races"]) and not s["classes"]
                  and s["z"] and s["x"] is not None]
    print(f"\n=================== {race}: {len(path_steps)} steps with a place (class quests left out)")
    bounces, legs = [], []
    for i in range(1, len(path_steps) - 1):
        a, b, c = path_steps[i - 1], path_steps[i], path_steps[i + 1]
        if a["z"] == b["z"] == c["z"]:
            out, back = dist(a, b), dist(a, c)
            if out > 12 and back < 3:
                bounces.append((out, a, b, c))
        if a["z"] == b["z"]:
            legs.append((dist(a, b), a, b))
    # the same NPC visited 3+ separate times within a section
    revisits = []
    by_section = collections.OrderedDict()
    for s in path_steps:
        by_section.setdefault(s["section"], []).append(s)
    for sec, ss in by_section.items():
        visits = collections.defaultdict(list)
        last = None
        for s in ss:
            if s["who"] and s["t"] in ("A", "T"):
                if s["who"] != last:
                    visits[s["who"]].append(s["n"])
                last = s["who"]
            elif s["t"] in ("C", "G"):
                last = None
        for who, ns_ in visits.items():
            if len(ns_) >= 3:
                revisits.append((sec, who[1], ns_))
    # zone ping-pong: A -> B -> A within 6 steps
    pingpong = []
    for i in range(len(path_steps) - 2):
        z0 = path_steps[i]["z"]
        for j in range(i + 1, min(len(path_steps), i + 6)):
            if path_steps[j]["z"] != z0:
                for k in range(j + 1, min(len(path_steps), j + 4)):
                    if path_steps[k]["z"] == z0 and path_steps[j]["section"] == path_steps[i]["section"]:
                        pingpong.append((path_steps[i], path_steps[j], path_steps[k]))
                        break
                break
    print(f"-- out and straight back ({len(bounces)}): you walk somewhere and the next step is where you started")
    for out, a, b, c in sorted(bounces, key=lambda x: -x[0])[:12]:
        print(f"   step {b['n']:4} {b['t']} {b['name'][:34]:34} {out:5.1f}% out, then back to step {c['n']} ({c['name'][:30]})  [{b['section'][:40]}]")
    print(f"-- NPCs visited 3+ times in one section ({len(revisits)})")
    for sec, who, ns_ in revisits[:15]:
        print(f"   {who[:28]:28} steps {ns_}  [{sec[:45]}]")
    print(f"-- zone ping-pong ({len(pingpong)}): leave a zone and come back a few steps later")
    seen = set()
    for a, b, c in pingpong[:10]:
        key = (a["n"], c["n"])
        if key in seen:
            continue
        seen.add(key)
        print(f"   step {a['n']} -> {b['n']} ({b['name'][:30]}) -> {c['n']}  [{a['section'][:40]}]")
    print("-- longest single walks in a zone")
    for d, a, b in sorted(legs, key=lambda x: -x[0])[:6]:
        print(f"   {d:5.1f}%  step {a['n']} {a['name'][:28]} -> {b['n']} {b['name'][:28]}  [{a['section'][:35]}]")
