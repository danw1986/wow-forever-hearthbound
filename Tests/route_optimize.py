# Re-order the quest steps of a route so there's less walking, without breaking
# anything that has to happen in order. Writes a new route file next to the old.
#
#   python Tests/route_optimize.py [GuideData_Forever.lua] [out.lua]
#
# How it works
#   The route is cut into stretches at every step that isn't a quest step you
#   walk to (notes, training, flight paths, hearths, flights, dungeons) and at
#   every section change. Inside a stretch the quest steps are re-ordered:
#   starting where the stretch begins, it keeps taking the nearest step that's
#   allowed next, then tries moving steps elsewhere when that's shorter still.
#
#   Kept in order:
#     - a quest's own steps: pick up, then progress, then hand in
#     - a chain: a quest's pick-up after the hand-in of the quest(s) before it
#       (QuestieDB preQuestSingle / preQuestGroup), and a breadcrumb's hand-in
#       before the pick-up of the quest it leads to
#     - a pick-up never moves ahead of a hand-in that came before it (hand-ins
#       give the XP and unlocks pick-ups may need); hand-ins can move earlier
#     - steps that belong together stay together: a "go to" with the step it
#       leads to; a quest that starts from an item with the step before it (you
#       loot it there); a pick-up and its progress step at the same spot (escorts,
#       talks that start on accepting); steps with no position with the one before
#
#   Each step keeps its old number as was=N so the guide can carry your place
#   and skips over to the new order.
import json
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "fixtures", "GuideData_Forever.lua")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, "GuideData_Forever.optimized.lua")
DB = json.load(open(os.path.join(HERE, "questiedb.json")))["Quest"]

ZONE_CHANGE = 60.0    # cost of moving between zones inside a stretch (map percent)
QUEST_SHARE = 0.65    # share of your XP that comes from quests (the rest from kills), unless learned

# ---------------------------------------------------------------- XP and levels
# XP to go from each level to the next (Classic)
XP_TO_LEVEL = [0, 400, 900, 1400, 2100, 2800, 3600, 4500, 5400, 6500, 7600, 8800, 10100, 11400, 12900, 14400,
               16000, 17700, 19400, 21300, 23200, 25200, 27300, 29400, 31700, 34000, 36400, 38900, 41400, 44300,
               47400, 50800, 54500, 58600, 62800, 67100, 71600, 76100, 80800, 85700, 90700, 95800, 101000,
               106300, 111800, 117500, 123200, 129100, 135100, 141200, 147500, 153900, 160400, 167100, 173900,
               180800, 187900, 195000, 202300, 209800]


def level_for(total_xp):
    level, need = 1, 0
    while level < 60 and total_xp >= need + XP_TO_LEVEL[level]:
        need += XP_TO_LEVEL[level]
        level += 1
    return level + (total_xp - need) / max(1, XP_TO_LEVEL[min(level, 59)])


# QuestieDB's quest XP: quest -> (quest level, XP)
QXP = {}
_xp_file = os.path.join(HERE, "..", "..", "QuestieDB", "support", "Forever", "QuestXP", "xpDB-classic.lua")
if os.path.exists(_xp_file):
    for m in re.finditer(r"\[(\d+)\] = \{(\d+), (\d+)\}", open(_xp_file, encoding="utf-8").read()):
        QXP[int(m.group(1))] = (int(m.group(2)), int(m.group(3)))
# a typical quest's XP at each level (for Forever's new quests, which aren't in the table)
_by_level = {}
for lvl, xp in QXP.values():
    _by_level.setdefault(lvl, []).append(xp)
TYPICAL_XP = {lvl: sorted(v)[len(v) // 2] for lvl, v in _by_level.items()}


# what the guide learned from your play (GuideLearn.lua), from the saved variables
def load_learned():
    import glob
    paths = glob.glob(os.path.join(HERE, "..", "..", "..", "..", "WTF", "Account", "*", "SavedVariables", "Hearthbound.lua"))
    if os.environ.get("HEARTHBOUND_SAVEDVARS"):  # tests: a saved variables file of their own
        paths = [os.environ["HEARTHBOUND_SAVEDVARS"]]
    learned = {"offers": {}, "quests": {}, "share": None}
    try:
        from lupa import LuaRuntime
    except ImportError:
        return learned
    for path in paths:
        L = LuaRuntime()
        try:
            L.execute(open(path, encoding="utf-8").read())
        except Exception:
            continue
        db = L.globals().HearthboundDB
        learn = db and db["learn"]
        if not learn:
            continue
        for q, o in (learn["offers"] or {}).items():
            after = {int(k): int(v) for k, v in (o["after"] or {}).items()}
            learned["offers"][int(q)] = {"samples": int(o["afterSamples"] or 0), "after": after,
                                         "minLevel": o["minLevel"]}
        for q, rec in (learn["quests"] or {}).items():
            learned["quests"][int(q)] = {"xp": rec["xp"], "takenAt": rec["takenAt"]}
        qx = ox = 0
        for _, levels in (learn["levels"] or {}).items():
            for _, r in levels.items():
                qx += r["questXP"] or 0
                ox += r["otherXP"] or 0
        if qx + ox > 20000:
            learned["share"] = qx / (qx + ox)
    return learned


LEARNED = load_learned()
if LEARNED["share"]:
    QUEST_SHARE = LEARNED["share"]


def learned_prereqs(q):
    o = LEARNED["offers"].get(q)
    if not o or o["samples"] < 1:
        return set()
    return {p for p, n in o["after"].items() if n >= o["samples"] and p != q}


def quest_xp(q):
    rec = LEARNED["quests"].get(q)
    if rec and rec.get("xp"):
        return rec["xp"]
    if q in QXP:
        return QXP[q][1]
    lvl = (DB.get(str(q)) or {}).get("questLevel")
    return TYPICAL_XP.get(lvl, 0) if lvl else 0


def required_level(q):
    rec = DB.get(str(q)) or {}
    need = rec.get("requiredLevel") or 1
    o = LEARNED["offers"].get(q)
    if o and o.get("minLevel"):
        need = max(need, o["minLevel"]) if False else need  # an offer at level N shows N is enough
    return need


def well_known(q):
    """do we know this quest's prerequisites? (Classic quests: QuestieDB does; Forever's
    new ones only once they've been learned, or QuestieDB lists some)"""
    rec = DB.get(str(q)) or {}
    if rec.get("preQuestSingle") or rec.get("preQuestGroup"):
        return True
    o = LEARNED["offers"].get(q)
    if o and o["samples"] >= 1:
        return True
    return q not in FOREVER_ONLY
BARRIERS = {"N", "TR", "FP", "SH", "H", "F", "D"}

lines = open(SRC, encoding="utf-8").read().split("\n")
head, steps, tail = [], [], []
for line in lines:
    m = re.match(r'\s*\{t="(\w+)"', line)
    if m:
        steps.append(line)
    elif not steps:
        head.append(line)
    else:
        tail.append(line)


def field(line, pat, conv=str):
    m = re.search(pat, line)
    return conv(m.group(1)) if m else None


def parse(n, line):
    s = {"n": n, "line": line, "t": field(line, r'\{t="(\w+)"'), "q": field(line, r'\bq=(\d+)', int),
         "z": field(line, r'\bz=(\d+)', int), "x": field(line, r'\bx=([\d.]+)', float),
         "y": field(line, r'\by=([\d.]+)', float), "section": field(line, r'section="([^"]*)"') or "",
         "item": 'target={kind="item"' in line, "instance": "instance=" in line,
         "races": field(line, r'races=\{([^}]*)\}') or "", "classes": field(line, r'classes=\{([^}]*)\}') or "",
         "name": field(line, r'name="([^"]*)"') or "",
         "who": field(line, r'target=\{kind="(\w+", id=\d+)'),
         "forever": "foreverOnly=true" in line}
    s["placed"] = s["z"] is not None and s["x"] is not None and s["y"] is not None
    return s


S = [parse(n, l) for n, l in enumerate(steps, 1)]
FOREVER_ONLY = {s["q"] for s in S if s["forever"] and s["q"]}

# your XP at each step of the route as it stands (the steps everyone plays), and so the
# level you'd be: a pick-up is never moved somewhere you'd be lower than where it was
XP_BEFORE = {}  # step number -> XP from all quests handed in before it
_xp = 0.0
for _s in S:
    XP_BEFORE[_s["n"]] = _xp
    if _s["t"] == "T" and _s["q"] and not _s["classes"] and not _s["races"]:
        _xp += quest_xp(_s["q"]) / QUEST_SHARE


def signature(seq):
    total = 0
    for n, s in enumerate(seq, 1):
        total = (total + n * ((s["q"] or 0) % 9973 + len(s["t"]))) % 2147483647
    first, last = seq[0]["q"], seq[-1]["q"]
    return f"{len(seq)}:{first if first is not None else 'nil'}:{last if last is not None else 'nil'}:{total}"


def cost(a, b):
    if a is None or b is None:
        return 0.0
    if a["z"] != b["z"]:
        return ZONE_CHANGE
    return math.hypot(a["x"] - b["x"], a["y"] - b["y"])


def prereqs(q):
    rec = DB.get(str(q)) or {}
    out = set(learned_prereqs(q))
    for key in ("preQuestSingle", "preQuestGroup"):
        for p in rec.get(key) or []:
            if isinstance(p, int) and p > 0 and p != q:
                out.add(p)
    return out


def breadcrumb_target(q):
    return (DB.get(str(q)) or {}).get("breadcrumbForQuestId")


# ---------------------------------------------------------------- stretches
stretches, cur = [], []
for s in S:
    barrier = s["t"] in BARRIERS or s["instance"]
    if barrier or (cur and cur[-1]["section"] != s["section"]):
        if cur:
            stretches.append(("move", cur))
            cur = []
        if barrier:
            stretches.append(("fixed", [s]))
            continue
    cur.append(s)
if cur:
    stretches.append(("move", cur))


# ---------------------------------------------------------------- units: steps that move together
def units_of(seq):
    units = []
    pending_go = []  # "go to" steps waiting for the step they lead to
    for s in seq:
        if s["t"] == "G":
            pending_go.append(s)
            continue
        attach_back = units and (
            s["item"]                                   # starts from loot: where the last step was
            or not s["placed"]                          # no position: with the step before
            or (s["t"] == "C" and units[-1]["steps"][-1]["t"] == "A" and units[-1]["steps"][-1]["q"] == s["q"]
                and s["placed"] and units[-1]["steps"][-1]["placed"]
                and cost(units[-1]["steps"][-1], s) < 1.5)  # starts on accepting (escort, talk)
        )
        if attach_back and not pending_go:
            units[-1]["steps"].append(s)
        else:
            units.append({"steps": pending_go + [s]})
            pending_go = []
    if pending_go:
        if units:
            units[-1]["steps"].extend(pending_go)
        else:
            units.append({"steps": pending_go})
    for u in units:
        placed = [s for s in u["steps"] if s["placed"] and s["t"] != "G"] or [s for s in u["steps"] if s["placed"]]
        u["first"] = placed[0] if placed else None
        u["last"] = placed[-1] if placed else None
    return units


def constraints(units):
    """before[i] = set of unit indexes that must come before unit i"""
    before = [set() for _ in units]
    where = {}  # (t, q) -> unit index (all occurrences)
    for i, u in enumerate(units):
        for s in u["steps"]:
            if s["q"]:
                where.setdefault((s["t"], s["q"]), []).append(i)
    order = {"A": 0, "C": 1, "T": 2}
    for i, u in enumerate(units):
        for s in u["steps"]:
            q = s["q"]
            if not q:
                continue
            # a quest's own steps, in their order (several progress steps keep theirs)
            for j, v in enumerate(units):
                if j == i:
                    continue
                for o in v["steps"]:
                    if o["q"] == q and o["t"] in order and s["t"] in order:
                        if order[o["t"]] < order[s["t"]] or (o["t"] == s["t"] and o["n"] < s["n"]):
                            before[i].add(j)
            if s["t"] == "A":
                # Forever's own chains often aren't in QuestieDB: be careful instead -
                for j, v in enumerate(units):
                    if j == i:
                        continue
                    for o in v["steps"]:
                        if not o["q"] or o["n"] >= s["n"]:
                            continue
                        # a quest we know nothing about (a Forever one QuestieDB doesn't
                        # cover, not learned yet): every hand-in the route had before it
                        # stays before it - one of them may unlock it
                        if o["t"] == "T" and not well_known(q):
                            before[i].add(j)
                        # a hand-in at the NPC you then pick this up from (it probably unlocks it)
                        if o["t"] == "T" and o["who"] and o["who"] == s["who"]:
                            before[i].add(j)
                        # an earlier quest of the same name (the parts of a chain)
                        if o["name"] and o["name"] == s["name"] and o["q"] != q:
                            before[i].add(j)
                        # QuestieDB's "next quest in the chain"
                        if o["t"] == "T" and (DB.get(str(o["q"])) or {}).get("nextQuestInChain") == q:
                            before[i].add(j)
                for p in prereqs(q):
                    for j in where.get(("T", p), []):
                        if j != i:
                            before[i].add(j)
                # a breadcrumb leading here is handed in first
                for j, v in enumerate(units):
                    for o in v["steps"]:
                        if o["t"] == "T" and o["q"] and breadcrumb_target(o["q"]) == q and j != i:
                            before[i].add(j)
    return before


# who plays which steps: every Horde race with its classes
COMBOS = {"orc": ["warrior", "hunter", "rogue", "shaman", "warlock", "mage"],
          "troll": ["warrior", "hunter", "rogue", "priest", "shaman", "mage", "warlock"],
          "tauren": ["warrior", "hunter", "shaman", "druid"],
          "undead": ["warrior", "rogue", "priest", "mage", "warlock", "paladin"],
          "skyborne": ["warrior", "hunter", "rogue", "shaman", "druid"]}


def applies(s, race, cls):
    races = re.findall(r'"([^"]+)"', s["races"])
    if races and race not in races:
        return False
    classes = re.findall(r'"([^"]+)"', s["classes"])
    if classes:
        neg = [c[1:].lower() for c in classes if c.startswith("!")]
        pos = [c.lower() for c in classes if not c.startswith("!")]
        if cls in neg or (pos and cls not in pos):
            return False
    return True


def audiences(units):
    """the race/class combinations that play any of these steps, with which steps they see"""
    out = []
    for race, classes in COMBOS.items():
        for cls in classes:
            seen = {id(s) for u in units for s in u["steps"] if applies(s, race, cls)}
            if seen:
                out.append(seen)
    # combinations seeing exactly the same steps walk the same path: count each path once
    unique = []
    for a in out:
        if a not in unique:
            unique.append(a)
    return unique


def length(order, units, start, who=None):
    """walking for everyone who plays this stretch: each one's own path, added up,
    including the walk on to wherever the route goes next"""
    if who is None:
        who = units_audience.get(id(units)) or [None]
    after = units_next.get(id(units))
    total = 0.0
    for seen in who:
        pos = start
        for i in order:
            for s in units[i]["steps"]:
                if not s["placed"] or (seen is not None and id(s) not in seen):
                    continue
                total += cost(pos, s)
                pos = s
        if after is not None:
            total += cost(pos, after)
    return total


units_next = {}


units_audience = {}


def unit_xp(u):
    return sum(quest_xp(s["q"]) / QUEST_SHARE for s in u["steps"]
               if s["t"] == "T" and s["q"] and not s["classes"] and not s["races"])


def level_ok(u, xp_now):
    """every pick-up in the unit: you'd be at least as high as the route had you (or high
    enough for the quest)"""
    for s in u["steps"]:
        if s["t"] == "A" and s["q"]:
            here = level_for(xp_now)
            was = level_for(XP_BEFORE[s["n"]])
            if here < min(required_level(s["q"]), was) - 1e-9:
                return False
    return True


def valid(order, before, units=None, start_xp=0.0):
    seen = set()
    xp = start_xp
    for i in order:
        if not before[i] <= seen:
            return False
        if units is not None:
            if not level_ok(units[i], xp):
                return False
            xp += unit_xp(units[i])
        seen.add(i)
    return True


def optimise(units, start):
    before = constraints(units)
    n = len(units)
    original = list(range(n))
    first = units[0]["steps"][0]["n"] if units else 1
    start_xp = XP_BEFORE.get(first, 0.0)
    if not valid(original, before, units, start_xp):
        return original, 0, 0  # the data says something odd: leave it alone
    # nearest allowed step first
    order, placed, pos, xp = [], set(), start, start_xp
    while len(order) < n:
        ready = [i for i in range(n) if i not in placed and before[i] <= placed and level_ok(units[i], xp)]
        if not ready:  # nothing fits the level yet: take the route's next one
            ready = [min(i for i in range(n) if i not in placed and before[i] <= placed)]
        best = min(ready, key=lambda i: (cost(pos, units[i]["first"]) if units[i]["first"] else 0, i))
        order.append(best)
        placed.add(best)
        xp += unit_xp(units[best])
        if units[best]["last"] is not None:
            pos = units[best]["last"]
    # move single units where it's shorter (or-opt), keeping the rules
    improved = True
    while improved:
        improved = False
        base = length(order, units, start)
        for a in range(n):
            for b in range(n):
                if a == b:
                    continue
                trial = order[:]
                u = trial.pop(a)
                trial.insert(b, u)
                if valid(trial, before, units, start_xp):
                    L = length(trial, units, start)
                    if L < base - 0.5:
                        order, base, improved = trial, L, True
    # only keep it if it really is shorter than the route's own order (and keeps the rules)
    if not valid(order, before, units, start_xp) or length(order, units, start) >= length(original, units, start) - 1.0:
        return original, length(original, units, start), length(original, units, start)
    return order, length(original, units, start), length(order, units, start)


# ---------------------------------------------------------------- run
new_steps, report, last_placed = [], [], None
saved_total = 0.0


def next_place(k):
    """the first step with a place after stretch k (where you head next)"""
    for kind, seq in stretches[k + 1:]:
        for s in seq:
            if s["placed"]:
                return s
    return None


for k, (kind, seq) in enumerate(stretches):
    if kind == "fixed":
        new_steps.extend(seq)
        if seq[0]["placed"]:
            last_placed = seq[0]
        continue
    units = units_of(seq)
    units_audience[id(units)] = audiences(units)
    units_next[id(units)] = next_place(k)
    order, before_len, after_len = optimise(units, last_placed)
    for i in order:
        new_steps.extend(units[i]["steps"])
    if after_len < before_len:
        saved_total += before_len - after_len
        report.append((before_len - after_len, before_len, seq[0]["section"], seq[0]["n"], seq[-1]["n"]))
    for s in reversed(new_steps):
        if s["placed"]:
            last_placed = s
            break

assert len(new_steps) == len(S) and sorted(s["n"] for s in new_steps) == list(range(1, len(S) + 1))

old_sig = signature(S)
out = []
for line in head:
    if line.startswith("ns.HordeGuides.foreverWas"):
        continue  # the one from an earlier re-order: replaced below
    out.append(line)
    if line.startswith("ns.HordeGuides = "):
        out.append(f'ns.HordeGuides.foreverWas = "{old_sig}" -- the route this one was re-ordered from (for carrying your place over)')
for n, s in enumerate(new_steps, 1):
    line = s["line"]
    line = re.sub(r' was=\d+,', '', line)  # numbers from an earlier re-order: these are the ones read now
    line = re.sub(r'^(\s*\{t="\w+",)', lambda m: m.group(1) + f" was={s['n']},", line)
    line = re.sub(r'-- \d+\s*$', f"-- {n}", line)
    out.append(line)
out.extend(tail)
open(OUT, "w", encoding="utf-8", newline="").write("\n".join(out))

report.sort(reverse=True)
print(f"{len(report)} stretches shorter, {saved_total:.0f} map-percent less walking in all")
for saved, before_len, sec, a, b in report[:25]:
    print(f"  -{saved:5.1f}% ({before_len:5.1f} -> {before_len - saved:5.1f})  steps {a}-{b}  {sec}")
moved = sum(1 for n, s in enumerate(new_steps, 1) if s["n"] != n)
print(f"{moved} steps moved; old route {old_sig}; written to {OUT}")
