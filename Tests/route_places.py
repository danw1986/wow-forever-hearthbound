# Is each route step where QuestieDB says its NPC, object or quest mobs are?
# Run after questiedb_export.py: python Tests/route_places.py [GuideData_Forever.lua]
# Flags steps whose zone has none of them (wrong zone), or whose point is far
# from all of them (wrong coordinates). Forever redrew a few zone maps, so a
# small offset there can be QuestieDB's Classic positions rather than the route.
import json
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "fixtures", "GuideData_Forever.lua")
DB = json.load(open(os.path.join(HERE, "questiedb.json")))
Q, N, O, I = DB["Quest"], DB["Npc"], DB["Object"], DB["Item"]


def spawns(kind, id_):
    rec = (N if kind == "npc" else O).get(str(id_)) or {}
    return rec.get("spawns") or {}


def objective_spawns(q):
    """where a quest's mobs, objects and item sources are: {zone: [[x, y], ...]}"""
    out = {}

    def add(sp):
        for z, pts in (sp or {}).items():
            out.setdefault(z, []).extend(p for p in pts if isinstance(p, list) and len(p) >= 2 and p[0] is not None)

    obj = (Q.get(str(q)) or {}).get("objectives") or []
    if isinstance(obj, dict):
        obj = [obj.get(str(k)) for k in range(1, 6)]
    for idx, group in enumerate(obj):
        if not group:
            continue
        for e in group:
            id_ = e[0] if isinstance(e, list) else e
            if idx == 0:
                add(spawns("npc", id_))           # creatures
            elif idx == 1:
                add(spawns("object", id_))        # objects
            elif idx == 2:                        # items: the mobs and objects that drop them
                it = I.get(str(id_)) or {}
                for n in it.get("npcDrops") or []:
                    add(spawns("npc", n))
                for o in it.get("objectDrops") or []:
                    add(spawns("object", o))
            elif idx == 4 and isinstance(e, list) and isinstance(e[0], list):  # kill credit groups
                for n in e[0]:
                    add(spawns("npc", n))
    return out


def nearest(pts, x, y):
    return min((math.hypot(p[0] - x, p[1] - y) for p in pts), default=None)


problems = []
for line in open(path, encoding="utf-8"):
    m = re.match(r'\s*\{t="(\w+)"', line)
    if not m:
        continue
    t = m.group(1)
    num = re.search(r'-- (\d+)\s*$', line)
    num = int(num.group(1)) if num else None
    g = lambda pat: (re.search(pat, line) or [None, None])[1]
    q, z, x, y = g(r'\bq=(\d+)'), g(r'\bz=(\d+)'), g(r'\bx=([\d.]+)'), g(r'\by=([\d.]+)')
    if not (z and x and y) or "instance=" in line:
        continue
    x, y = float(x), float(y)
    name = g(r'name="([^"]*)"') or g(r'text="([^"]*)"') or ""
    tg = re.search(r'target=\{kind="(\w+)", id=(\d+), name="([^"]*)"', line)
    if t in ("A", "T") and tg and tg.group(1) in ("npc", "object"):
        sp = spawns(tg.group(1), tg.group(2))
        if not sp:
            continue  # QuestieDB has no place for it
        if z not in sp:
            problems.append((num, t, q, name, f"{tg.group(3)} isn't in this zone ({z}); QuestieDB has it in {sorted(sp)}"))
        else:
            d = nearest(sp[z], x, y)
            if d is not None and d > 4:
                best = min(sp[z], key=lambda p: math.hypot(p[0] - x, p[1] - y))
                problems.append((num, t, q, name, f"{tg.group(3)} is {d:.1f}% away - QuestieDB: {best[0]:.1f}, {best[1]:.1f}"))
    elif t == "C" and q:
        sp = objective_spawns(q)
        if not sp:
            continue
        if z not in sp:
            problems.append((num, t, q, name, f"no objective mobs/objects in zone {z}; QuestieDB has them in {sorted(sp)[:4]}"))
        else:
            d = nearest(sp[z], x, y)
            if d is not None and d > 12:
                problems.append((num, t, q, name, f"nearest objective is {d:.1f}% away"))

print(f"{len(problems)} steps out of place:")
for p in problems:
    print(f"  step {p[0]:4} {p[1]} {p[2] or '':>6} {p[3][:34]:34} {p[4]}")
