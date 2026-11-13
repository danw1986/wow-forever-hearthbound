# Turns the upstream Horde levelling guides (github.com/fitzforge/polestar,
# guides/forever, GPL-3.0) into Hearthbound's route: GuideData.lua.
#   python Tests/route_import.py <path to the upstream guides/forever> [--write]
# Whatever QuestieDB doesn't know comes from the upstream's open database, when
# its forever-db/data sits beside guides/ as in the upstream repository (GPL-3.0).
# The .guide files are read as data only. Quest IDs are QuestieDB's, and the
# NPCs, objects and coordinates the guides leave out are filled in from
# QuestieDB (Tests/questiedb.json, from questiedb_export.py) - the way
# The upstream compiler fills them from its data.
import json
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
SRC = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else None
WRITE = "--write" in sys.argv
if not SRC:
    sys.exit("usage: route_import.py <upstream guides/forever folder> [--write]")
DB = json.load(open(os.path.join(HERE, "questiedb.json")))
Q, N, O, I = DB["Quest"], DB["Npc"], DB["Object"], DB["Item"]
warnings = []

# ------------------------------------------------------------------ zones: name <-> AreaTable ID
ZONE_ID = {}
for f in ("Tests/fixtures/GuideData_Forever.lua", "Tests/fixtures/GuideData_Classic.lua"):
    for m in re.finditer(r'z=(\d+),[^\n]*?zoneName="([^"]+)"', open(os.path.join(ADDON, f), encoding="utf-8").read()):
        ZONE_ID.setdefault(m.group(2), int(m.group(1)))
ZONE_ID.update({  # the ones the old routes never named
    "Alterac Mountains": 36, "Arathi Highlands": 45, "Badlands": 3, "Blasted Lands": 4, "Burning Steppes": 46,
    "Deadwind Pass": 41, "Dun Morogh": 1, "Duskwood": 10, "Eastern Plaguelands": 139, "Elwynn Forest": 12,
    "Hillsbrad Foothills": 267, "Loch Modan": 38, "Redridge Mountains": 44, "Searing Gorge": 51,
    "Silverpine Forest": 130, "Stranglethorn Vale": 33, "Swamp of Sorrows": 8, "The Hinterlands": 47,
    "Tirisfal Glades": 85, "Undercity": 1497, "Western Plaguelands": 28, "Westfall": 40, "Wetlands": 11,
    "Ashenvale": 331, "Azshara": 16, "Darkshore": 148, "Desolace": 405, "Durotar": 14, "Dustwallow Marsh": 15,
    "Felwood": 361, "Feralas": 357, "Moonglade": 493, "Mulgore": 215, "Orgrimmar": 1637, "Silithus": 1377,
    "Stonetalon Mountains": 406, "Tanaris": 440, "Teldrassil": 141, "The Barrens": 17, "Thousand Needles": 400,
    "Thunder Bluff": 1638, "Un'Goro Crater": 490, "Winterspring": 618, "Zephras Isle": 16593,
})
ZONE_NAME = {v: k for k, v in ZONE_ID.items()}
# uiMap IDs (for "zone map <id>" / "map <id>") -> AreaTable, from Guide.lua's ZONE_MAPS
UIMAP = {}
gl = open(os.path.join(ADDON, "Guide.lua"), encoding="utf-8").read()
block = gl[gl.index("local ZONE_MAPS = {"):]
block = block[:block.index("}")]
for a, u in re.findall(r"\[(\d+)\] = (\d+)", block):
    UIMAP[int(u)] = int(a)

AREA_UIMAP = {a: u for u, a in UIMAP.items()}

# The maps Forever redrew: typed coordinates are in Era's frame unless they're
# marked live, and the guide works in Forever's. (left, right, top, bottom)
ERA_FRAME = {1412: (2047.917, -3089.583, -272.917, -3697.917), 1423: (-2185.417, -6056.25, 3800, 1218.75),
             1433: (-1570.833, -3741.667, -8575, -10022.916), 1453: (1380.971, 36.701, -8278.851, -9175.205)}
LIVE_FRAME = {1412: (2479.167, -3675, 266.666, -3835.416), 1423: (-2256.25, -6558.334, 3691.667, 825),
              1433: (-1681.25, -3852.084, -8575, -10022.916), 1453: (1722.92, -14.584, -7995.83, -9154.17)}


def era_to_live(area, x, y):
    ui = AREA_UIMAP.get(area)
    if ui not in ERA_FRAME:
        return x, y
    el, er, et, eb = ERA_FRAME[ui]
    ll, lr, lt, lb = LIVE_FRAME[ui]
    wy, wx = el - x / 100 * (el - er), et - y / 100 * (et - eb)
    return round((ll - wy) / (ll - lr) * 100, 2), round((lt - wx) / (lt - lb) * 100, 2)


def load_open_db(root):
    """fill in the quests, NPCs, objects and items QuestieDB doesn't have"""
    folder = os.path.join(root, "forever-db", "data")
    if not os.path.isdir(folder):
        warnings.append("no forever-db beside the guides: quests QuestieDB doesn't know keep a placeholder name")
        return

    def rows(table):
        with open(os.path.join(folder, table + ".jsonl"), encoding="utf-8") as fh:
            for line in fh:
                yield json.loads(line)

    new_items = set()
    for table, into in (("npc", N), ("object", O), ("item", I)):
        for r in rows(table):
            if str(r["id"]) not in into:
                into[str(r["id"])] = {"name": r.get("name")}
                if table == "item":
                    new_items.add(str(r["id"]))
    # world yards -> map percent, in every zone map the spawn lies inside
    frames = {}
    for r in rows("ui_map"):
        if r["ui_map"] in UIMAP:
            frames.setdefault(r["map"], []).append(r)
    found = {}
    for r in rows("spawn"):
        rec = {"npc": N, "object": O}.get(r["kind"], {}).get(str(r["id"]))
        if rec is None or rec.get("spawns"):
            continue
        for f in frames.get(r["map"], []):
            x = (f["left"] - r["y"]) / (f["left"] - f["right"]) * 100
            y = (f["top"] - r["x"]) / (f["top"] - f["bottom"]) * 100
            if 0 <= x <= 100 and 0 <= y <= 100:
                found.setdefault((r["kind"], str(r["id"])), {}).setdefault(str(UIMAP[f["ui_map"]]), []).append([round(x, 2), round(y, 2)])
    for (kind, id_), by_zone in found.items():
        {"npc": N, "object": O}[kind][id_]["spawns"] = by_zone
    for r in rows("item_source"):
        key = {"npc": "npcDrops", "object": "objectDrops"}.get(r["kind"])
        if key and str(r["item"]) in new_items:
            I[str(r["item"])].setdefault(key, []).append(r["id"])
    missing = {}
    for r in rows("quest"):
        if str(r["id"]) not in Q:
            missing[str(r["id"])] = {"name": r.get("title"), "questLevel": r.get("level"), "requiredLevel": r.get("min_level"),
                                     "startedBy": [[], [], []], "finishedBy": [[], []], "objectives": [[], [], []]}
    slot = {"npc": 0, "object": 1, "item": 2}
    for table, key in (("quest_start", "startedBy"), ("quest_end", "finishedBy")):
        for r in rows(table):
            rec = missing.get(str(r["quest"]))
            if rec and slot[r["kind"]] < len(rec[key]):
                rec[key][slot[r["kind"]]].append(r["id"])
    kinds = {"kill": 0, "talk": 0, "object": 1, "item": 2}
    for r in rows("quest_objective"):
        rec = missing.get(str(r["quest"]))
        if rec and r["kind"] in kinds and "target" in r:
            rec["objectives"][kinds[r["kind"]]].append([r["target"]])
    Q.update(missing)


RACES = {"orc": "orc", "troll": "troll", "tauren": "tauren", "undead": "undead", "scourge": "undead", "skyborne": "skyborne"}
CLASSES = {c.lower(): c for c in ("Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid")}

# ------------------------------------------------------------------ parsing a .guide


def tokens(line):
    out, i = [], 0
    while i < len(line):
        c = line[i]
        if c.isspace():
            i += 1
        elif c == '"':
            j, buf = i + 1, ""
            while j < len(line) and line[j] != '"':
                if line[j] == "\\" and j + 1 < len(line):
                    j += 1
                buf += line[j]
                j += 1
            out.append(("str", buf))
            i = j + 1
        else:
            j = i
            while j < len(line) and not line[j].isspace():
                j += 1
            out.append(("tok", line[i:j]))
            i = j
    return out


def strip_comment(line):
    # "#" after whitespace (outside quotes) starts an author comment; " -- " a player note
    note, inq, out = None, False, ""
    i = 0
    while i < len(line):
        c = line[i]
        if c == '"':
            inq = not inq
        if not inq and c == "#" and (i == 0 or line[i - 1].isspace()):
            break
        if not inq and line[i:i + 4] == " -- ":
            note = line[i + 4:].strip()
            break
        out += c
        i += 1
    return out.rstrip(), note


def parse(path):
    g = {"steps": [], "file": path}
    step = None
    for raw in open(path, encoding="utf-8"):
        raw = raw.rstrip("\n")
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        body, note = strip_comment(raw)
        if not body.strip():
            continue
        indented = raw[:1].isspace()
        if not indented:
            key, _, rest = body.partition(" ")
            if key == "step":
                step = {"title": rest.strip(), "items": []}
                g["steps"].append(step)
            else:
                g[key] = rest.strip()
            continue
        toks = tokens(body.strip())
        verb = toks[0][1].lower()
        step["items"].append({"verb": verb, "args": toks[1:], "note": note, "text": body.strip()})
    return g


# ------------------------------------------------------------------ QuestieDB lookups


def arr(v):
    """a QuestieDB array as a Python list: exported as a list, or (with gaps) as a 1-based dict"""
    if isinstance(v, dict):
        n = max((int(k) for k in v), default=0)
        return [v.get(str(i)) for i in range(1, n + 1)]
    return v or []


def spawns(kind, id_):
    rec = {"npc": N, "object": O}[kind].get(str(id_)) or {}
    out = {}
    all_spawns = rec.get("spawns")
    for z, pts in (all_spawns if isinstance(all_spawns, dict) else {}).items():
        good = [p for p in pts if isinstance(p, list) and len(p) >= 2 and p[0] is not None and p[0] >= 0]
        if good:
            out[int(z)] = good
    return out


def item_sources(item):
    it = I.get(str(item)) or {}
    out = {}
    for n in (it.get("npcDrops") or [])[:12]:
        for z, pts in spawns("npc", n).items():
            out.setdefault(z, []).extend(pts)
    for o in (it.get("objectDrops") or [])[:12]:
        for z, pts in spawns("object", o).items():
            out.setdefault(z, []).extend(pts)
    return out


def name_of(kind, id_):
    rec = {"npc": N, "object": O, "item": I}[kind].get(str(id_)) or {}
    return rec.get("name")


def merge(*maps):
    out = {}
    for m in maps:
        for z, pts in m.items():
            out.setdefault(z, []).extend(pts)
    return out


class Place:
    def __init__(self):
        self.zone = None     # the guide's current zone (AreaTable ID)
        self.prev = None     # (zone, x, y) of the last placed step
        self.used = []       # zones used so far, most recent first

    def pick(self, by_zone):
        """the spawn to send you to: in the current zone (nearest the last step),
        then a zone the guide used lately, then wherever there are most"""
        if not by_zone:
            return None
        order = [self.zone] + self.used
        zone = next((z for z in order if z in by_zone), None)
        if zone is None:
            zone = max(by_zone, key=lambda z: len(by_zone[z]))
        pts = by_zone[zone]
        if self.prev and self.prev[0] == zone:
            p = min(pts, key=lambda p: math.hypot(p[0] - self.prev[1], p[1] - self.prev[2]))
        else:
            # the middle of where they are
            cx = sum(p[0] for p in pts) / len(pts)
            cy = sum(p[1] for p in pts) / len(pts)
            p = min(pts, key=lambda p: math.hypot(p[0] - cx, p[1] - cy))
        return zone, round(p[0], 2), round(p[1], 2)

    def placed(self, zone, x, y):
        self.prev = (zone, x, y)
        if zone in self.used:
            self.used.remove(zone)
        self.used.insert(0, zone)


# ------------------------------------------------------------------ goals -> route steps

def conditions(words, base_races):
    """'only' lists -> (races or None, classes or None, ok-for-Horde)"""
    races, classes, factions = [], [], []
    for w in words:
        for c in w.split(","):
            c = c.strip()
            if not c:
                continue
            neg = c.startswith("!")
            key = c.lstrip("!").lower().replace(" ", "")
            if key in CLASSES:
                classes.append(("!" if neg else "") + CLASSES[key])
            elif key in RACES:
                races.append(RACES[key])
            elif key in ("horde", "alliance"):
                factions.append(key)
            else:
                warnings.append(f"unknown condition {c}")
    ok = not factions or "horde" in factions
    if races and base_races:
        races = [r for r in races if r in base_races]
        if not races:
            ok = False
    elif base_races:
        races = list(base_races)
    return (races or None), (classes or None), ok


def money(text):
    m = re.fullmatch(r"(?:(\d+)g)?(?:(\d+)s)?(?:(\d+)c)?", text)
    if not m or not text:
        return None
    return int(m.group(1) or 0) * 10000 + int(m.group(2) or 0) * 100 + int(m.group(3) or 0)


def when_fields(lines, guide_id):
    """a step's "when" lines -> the fields Guide.lua checks as you play (K.WhenHolds)"""
    out = {}
    for line in lines:
        toks = tokens(line)
        word = toks[0][1] if toks else ""
        arg = toks[1][1] if len(toks) > 1 else ""
        level = re.fullmatch(r"level(<|>=)(\d+(?:\.\d+)?)", word)
        cash = re.fullmatch(r"money>=(\S+)", word)
        if level:
            out["lvlBelow" if level.group(1) == "<" else "lvlMin"] = float(level.group(2))
        elif cash and money(cash.group(1)) is not None:
            out["moneyMin"] = money(cash.group(1))
        elif word == "group":
            out["group"] = True
        elif word == "!group":
            out["solo"] = int(arg)
        elif word == "onquest":
            out["onQuest"] = [int(q) for q in "".join(t[1] for t in toks[1:]).split(",") if q]
        elif word == "bound":
            out["bound"] = arg
        elif word == "!bound":
            out["notBound"] = arg
        elif word == "!skill" and len(toks) > 2 and toks[2][1] == "1":
            out["noSkill"] = arg
        elif word == "skill" and len(toks) > 2 and toks[2][1] == "1":
            out["skill"] = arg  # only with this profession (Camping 101's profession quests)
        elif word == "!knows" and arg.isdigit():
            out["notKnown"] = int(arg)  # only while you don't know this spell or recipe
        elif word in ("turnedin", "!turnedin", "!onquest", "available") and arg.isdigit():
            key = {"turnedin": "turnedIn", "!turnedin": "notTurnedIn", "!onquest": "notOnQuest",
                   "available": "available"}[word]
            out.setdefault(key, []).append(int(arg))  # every one of them
        elif word == "!complete" and arg.isdigit():
            out["notReady"] = int(arg)  # the quest isn't ready to hand in (not in your log, or not done)
        elif word == "has" and arg.isdigit():
            count = re.fullmatch(r"x(\d+)", toks[2][1]) if len(toks) > 2 else None
            out["hasAtLeast"] = [int(arg), int(count.group(1)) if count else 1]
        elif word == "zone" and arg:
            out["inZone"] = arg  # only while you're in that zone
        elif word == "complete" and arg.isdigit():
            out["ready"] = int(arg)  # the quest is in your log, ready to hand in
        elif word == "!has" and arg.isdigit():
            count = re.fullmatch(r"x(\d+)", toks[2][1]) if len(toks) > 2 else None
            out["hasBelow"] = [int(arg), int(count.group(1)) if count else 1]
        elif word == "dungeon":
            out["_skip"] = True  # a dungeon run you opt into upstream: the guide adds its own runs
        elif word == "!dungeon":
            pass  # the way for those not running it: everyone here
        else:
            warnings.append(f"{guide_id}: unknown condition: when {line}")
    return out


def lua(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return '"' + v.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'
    if isinstance(v, list):
        return "{" + ", ".join(lua(x) for x in v) + "}"
    if isinstance(v, dict):
        return "{" + ", ".join(f"{k}={lua(x)}" for k, x in v.items()) + "}"
    raise TypeError(v)


FIELD_ORDER = ["t", "q", "obj", "name", "text", "gv", "gw", "optional", "group", "foreverOnly", "z", "x", "y", "target",
               "note", "tip", "races", "classes", "lvlBelow", "lvlMin", "moneyMin", "noSkill", "skill", "notKnown", "turnedIn", "notTurnedIn", "notOnQuest", "notReady", "available", "hasAtLeast", "inZone", "direct", "bound", "notBound", "onQuest", "solo",
               "ready", "hasBelow", "section", "zoneName", "p", "place", "was"]
PLACE_ID = [0]  # each upstream step: one place, its goals shown together


def step_line(s):
    parts = [f"{k}={lua(s[k])}" for k in FIELD_ORDER if k in s and s[k] is not None]
    return "  {" + ", ".join(parts) + "},"


def convert(guide, place, out):
    section = f"{guide.get('title', '?')} ({guide.get('levels', '?')})"
    base_races = [RACES[r.strip().lower()] for r in guide.get("race", "").split(",") if r.strip()] or None
    zone_name = guide.get("zone", "")
    place.zone = ZONE_ID.get(zone_name)
    if place.zone is None:
        warnings.append(f"{guide['guide']}: unknown zone {zone_name}")
    accepted = set()
    frame = guide.get("coords", "era")
    for st in guide["steps"]:
        step_only, step_when, along, tip, emitted = [], [], False, None, []
        # directives first (they apply to the whole step)
        for it in st["items"]:
            if it["verb"] == "only":
                step_only.append(" ".join(a[1] for a in it["args"]))
            elif it["verb"] == "when":
                step_when.append(it["text"][5:].strip())
            elif it["verb"] == "along":
                along = True
            elif it["verb"] == "tip":
                tip = it["text"][4:].strip()
            elif it["verb"] == "zone":
                rest = it["text"][5:].strip()
                if rest.startswith("map "):
                    z = UIMAP.get(int(rest[4:].split()[0]))
                else:
                    z = ZONE_ID.get(rest)
                if z is None:
                    warnings.append(f"{guide['guide']}: unknown zone {rest}")
                else:
                    place.zone = z
        sr, sc, sok = conditions(step_only, base_races)
        if not sok:
            continue
        step_fields = when_fields(step_when, guide["guide"])
        if step_fields.pop("_skip", False):
            continue
        if along:
            step_fields["optional"] = True  # done on the way: it never stops the route
        PLACE_ID[0] += 1
        objective_steps = {}  # (quest, objective) -> its C step, merged within one upstream step
        for it in st["items"]:
            verb, args, note = it["verb"], it["args"], it["note"]
            # die: a deathskip, for those who opt in upstream (never on Hardcore): the next
            # step's arrow gets you there on foot. label, loop: only the upstream engine uses them
            # background: an along step's goals worked over the whole stay (optional here already)
            if verb in ("only", "tip", "zone", "coords", "when", "along", "background", "label", "loop", "die"):
                continue
            # positional and modifiers
            pos = args[0][1] if args else None
            mods = {"only": [], "quoted": []}
            i = len(args) if verb == "note" and args and args[0][0] == "tok" else 1
            while i < len(args):
                kind, a = args[i]
                if kind == "str":
                    mods["quoted"].append(a)
                elif a.startswith("@"):
                    xy = a[1:] or (args[i + 1][1] if i + 1 < len(args) else "")
                    if not a[1:]:
                        i += 1
                    try:
                        mods["xy"] = tuple(float(v) for v in xy.split(","))
                    except ValueError:
                        warnings.append(f"bad coords {it['text']}")
                elif a in ("npc", "object", "item", "quest", "map", "r", "lvl", "xp", "money"):
                    mods[a] = args[i + 1][1] if i + 1 < len(args) else None
                    i += 1
                elif a == "only":
                    mods["only"].append(args[i + 1][1] if i + 1 < len(args) else "")
                    i += 1
                elif a in ("optional", "live", "era", "nearest", "group", "until", "direct"):
                    mods[a] = True
                elif re.fullmatch(r"x\d+", a):
                    mods["count"] = int(a[1:])
                elif a in ("choose", "reward"):
                    break
                i += 1
            if pos and pos.startswith('"'):
                pos = pos.strip('"')
            if args and args[0][0] == "str":
                mods["quoted"].insert(0, args[0][1])
                pos = None
            gr, gc, gok = conditions(mods["only"], sr)
            if not gok:
                continue
            classes = gc or sc
            if gc and sc:
                classes = [c for c in gc if c in sc] or gc
            base = dict(step_fields, races=gr, classes=classes, section=section, p=PLACE_ID[0])
            if mods.get("optional"):
                base["optional"] = True
            if mods.get("group"):
                base["group"] = True
            goal_zone = UIMAP.get(int(mods["map"])) if mods.get("map") else place.zone
            if goal_zone is None and mods.get("map"):
                warnings.append(f"{guide['guide']}: unknown map {mods['map']}: {it['text']}")
            goal_frame = "live" if mods.get("live") else "era" if mods.get("era") else frame

            def at(s, by_zone=None):
                """place step s: typed coordinates, else the QuestieDB spawn"""
                if "xy" in mods and goal_zone:
                    x, y = mods["xy"]
                    if goal_frame != "live":
                        x, y = era_to_live(goal_zone, x, y)
                    s["z"], s["x"], s["y"] = goal_zone, x, y
                elif by_zone:
                    picked = place.pick(by_zone)
                    if picked:
                        s["z"], s["x"], s["y"] = picked
                if "z" in s:
                    s["zoneName"] = ZONE_NAME.get(s["z"])
                    place.placed(s["z"], s["x"], s["y"])
                return s

            def quest_step(t, q):
                rec = Q.get(str(q))
                if not rec:
                    warnings.append(f"{guide['guide']}: quest {q} not in QuestieDB")
                s = dict(base, t=t, q=q, name=(mods["quoted"][0] if mods["quoted"] else (rec or {}).get("name") or f"Quest {q}"))
                if q >= 90000:
                    s["foreverOnly"] = True
                return s, rec or {}

            if verb in ("accept", "turnin", "complete"):
                q = int(pos)
                t = {"accept": "A", "turnin": "T", "complete": "C"}[verb]
                s, rec = quest_step(t, q)
                if verb == "accept":
                    accepted.add(q)
                if t == "T" and mods.get("direct"):
                    s["direct"] = True  # handed in straight from the giver's window: never in your log
                who = arr(rec.get("startedBy" if t == "A" else "finishedBy"))
                npcs = [int(mods["npc"])] if mods.get("npc") else (who[0] if len(who) > 0 and who[0] else [])
                objs = [int(mods["object"])] if mods.get("object") else (who[1] if len(who) > 1 and who[1] else [])
                items = who[2] if t == "A" and len(who) > 2 and who[2] else []
                if t == "C":
                    by_zone = {}
                    for idx, group in enumerate(arr(rec.get("objectives"))):
                        for e in group or []:
                            id_ = e[0] if isinstance(e, list) else e
                            if idx == 0:
                                by_zone = merge(by_zone, spawns("npc", id_))
                            elif idx == 1:
                                by_zone = merge(by_zone, spawns("object", id_))
                            elif idx == 2:
                                by_zone = merge(by_zone, item_sources(id_))
                    at(s, by_zone)
                elif npcs or objs:
                    by_zone, target = {}, None
                    for n in npcs:
                        sp = spawns("npc", n)
                        if sp and not target:
                            target = {"kind": "npc", "id": n, "name": name_of("npc", n)}
                            by_zone = sp
                    for o in objs:
                        sp = spawns("object", o)
                        if sp and not target:
                            target = {"kind": "object", "id": o, "name": name_of("object", o)}
                            by_zone = sp
                    if not target and npcs:
                        target = {"kind": "npc", "id": npcs[0], "name": name_of("npc", npcs[0])}
                    if target and target["name"]:
                        s["target"] = target
                    at(s, by_zone)
                elif items:
                    s["target"] = {"kind": "item", "id": items[0], "name": name_of("item", items[0])}
                    if place.prev:
                        s["z"], s["x"], s["y"] = place.prev
                        s["zoneName"] = ZONE_NAME.get(s["z"])
                    at(s)
                else:
                    at(s)
                if note:
                    s["note"] = note
                out.append(s)
                emitted.append(s)
            elif verb in ("kill", "collect", "interact", "use", "talk") and mods.get("quest"):
                qs, _, ob = mods["quest"].partition(".")
                q = int(qs)
                obj = int(ob) if ob else None
                key = (q, obj)
                if pos and pos.isdigit():
                    id_ = int(pos)
                    kind = {"kill": "npc", "talk": "npc", "interact": "object", "collect": "item", "use": "item"}[verb]
                    who = name_of(kind, id_)
                    by_zone = item_sources(id_) if kind == "item" else spawns(kind, id_)
                else:
                    who, by_zone = (mods["quoted"][0] if mods["quoted"] else None), {}
                label = note or {
                    "kill": f"Kill {who}" if who else None,
                    "talk": f"Talk to {who}" if who else None,
                    "interact": f"Click the {who}" if who else None,
                    "collect": (f"Collect {mods['count']} {who}" if mods.get("count") else f"Collect {who}") if who else None,
                    "use": f"Use the {who}" if who else None,
                }[verb]
                if mods["quoted"] and not note:
                    label = mods["quoted"][-1] if verb in ("use", "kill") else label
                if key in objective_steps:
                    s = objective_steps[key]
                    if label and label not in (s.get("note") or ""):
                        s["note"] = (s["note"] + "; " if s.get("note") else "") + label
                    continue
                s, _ = quest_step("C", q)
                if obj:
                    s["obj"] = obj
                if label:
                    s["note"] = label
                # the goal as the window shows it: "Kill" + the mob's name (unless the author wrote it)
                if who and not note:
                    s["gv"] = {"kill": "Kill", "talk": "Talk to", "interact": "Click", "collect": "Collect", "use": "Use"}[verb]
                    s["gw"] = f"{mods['count']} {who}" if verb == "collect" and mods.get("count") else who
                at(s, by_zone)
                objective_steps[key] = s
                out.append(s)
                emitted.append(s)
            else:
                # travel, training, notes
                label = mods["quoted"][0] if mods["quoted"] else None
                s = dict(base)
                if verb == "goto":
                    s.update(t="G", text=label or note or st["title"])
                    if pos and "," in pos:
                        x, y = pos.split(",")
                        mods["xy"] = (float(x), float(y))
                    at(s)
                elif verb == "fly":
                    s.update(t="F", text=label or pos)
                elif verb == "getfp":
                    s.update(t="FP", text=f"{label or pos} flight path")
                    if mods.get("npc"):
                        at(s, spawns("npc", int(mods["npc"])))
                elif verb == "hearth":
                    s.update(t="H", text=label or pos)
                elif verb == "sethome":
                    if mods.get("nearest") or pos == "nearest":
                        s.update(t="N", text="Set your hearthstone at the nearest inn")
                    else:
                        s.update(t="SH", text=label or pos)
                        if mods.get("npc"):
                            at(s, spawns("npc", int(mods["npc"])))
                elif verb == "train":
                    if pos == "class":
                        s.update(t="TR", text="Train at your class trainer")
                    elif pos and pos.isdigit():
                        who = name_of("npc", int(pos))
                        s.update(t="TR", text=f"Train with {who}" if who else "Visit the trainer")
                        at(s, spawns("npc", int(pos)))
                    else:
                        s.update(t="N", text="Train " + " ".join(a[1] for a in args))
                elif verb == "level":
                    s.update(t="N", text=f"Reach level {pos}")
                    if pos and re.fullmatch(r"\d+(\.\d+)?", pos):
                        s["lvlBelow"] = float(pos)  # passes by itself once you're there
                elif verb in ("vendor", "buy", "note", "collect", "kill", "use", "interact", "talk"):
                    if verb == "note":
                        text = it["text"][5:].strip().strip('"')
                        text = re.sub(r'"\s+only\s+\S+$', "", text).strip('"')
                    elif verb == "vendor":
                        text = "Sell junk and repair"
                    elif verb == "buy":
                        who = name_of("item", int(pos)) if pos and pos.isdigit() else label
                        text = f"Buy {mods.get('count', '')} {who}".replace("  ", " ") if who else "Buy supplies"
                    elif verb == "collect" and pos and pos.isdigit():
                        # an item that starts a quest is the next step's pick-up: no step of its own
                        it_id = int(pos)
                        who = name_of("item", it_id) or label
                        text = f"Collect {who}" if who else "Collect the item"
                    else:
                        who = None
                        if pos and pos.isdigit():
                            who = name_of({"kill": "npc", "talk": "npc", "interact": "object", "use": "item"}.get(verb, "npc"), int(pos))
                        text = label or (f"{verb.capitalize()} {who}" if who else it["text"])
                    s.update(t="N", text=text)
                    if "xy" in mods:
                        at(s)
                else:
                    warnings.append(f"{guide['guide']}: skipped {verb}")
                    continue
                if note and s.get("text") != note:
                    s["note"] = note
                out.append(s)
                emitted.append(s)
        # a goal QuestieDB can't place (an explore, a talk, a Forever item): where
        # the rest of its upstream step is
        anchor = next((e for e in emitted if "x" in e), None)
        for e in emitted:
            if "x" not in e and anchor and e["t"] in ("C", "A", "T"):
                e["z"], e["x"], e["y"], e["zoneName"] = anchor["z"], anchor["x"], anchor["y"], anchor.get("zoneName")
        # the step's own name on each of its goals, and its tip on the first
        for e in emitted:
            e["place"] = st["title"]
        if emitted and tip:
            emitted[0]["tip"] = tip
    return out


# ------------------------------------------------------------------ the chain: each race's start, then the rest
load_open_db(os.path.join(SRC, "..", ".."))
guides = {}
for root, _, files in os.walk(os.path.join(SRC, "horde")):
    for f in files:
        if f.endswith(".guide"):
            g = parse(os.path.join(root, f))
            guides[g["guide"]] = g
starts = ["forever/horde/skyborne/01-zephras-isle", "forever/horde/orc/01-durotar", "forever/horde/troll/01-durotar",
          "forever/horde/tauren/01-mulgore", "forever/horde/undead/01-tirisfal-glades"]
def follow(gid):
    """a guide and the ones its "next" lines lead to, in order"""
    out = []
    while gid and gid in guides and gid not in out:
        out.append(gid)
        gid = (guides[gid].get("next") or "").split(",")[0].strip() or None
    return out


# each start's own guides, then the shared chain from where every start's path meets
# (The Barrens up to 0.3.4, Silverpine Forest since 0.3.5)
chains = [follow(s) for s in starts]
shared = next(g for g in chains[0] if all(g in c for c in chains))
order = []
for c in chains:
    order += [g for g in c[:c.index(shared)] if g not in order]
order += chains[0][chains[0].index(shared):]
seen = set(order)
missing = [g for g in guides if g not in seen]
if missing:
    warnings.append(f"guides not in the chain: {missing}")

steps = []
for gid in order:
    place = Place()
    convert(guides[gid], place, steps)

# ------------------------------------------------------------------ inns: where each "set your hearth" is
# A sethome the guide gives no innkeeper for: the innkeeper it names for the same
# town elsewhere, else the innkeeper nearest the stop's other steps. The hearth
# hint on the guide card needs to know where every inn is.
INN_KEEPERS_UNPREFIXED = (16256, 15174)  # Jessica Chambers (Light's Hope), Calandrath (Cenarion Hold)
inn_of = {s["text"]: s for s in steps if s["t"] == "SH" and "x" in s}
innkeepers = [k for k, v in N.items() if (v.get("name") or "").startswith("Innkeeper")] + [str(k) for k in INN_KEEPERS_UNPREFIXED]
for n, s in enumerate(steps):
    if s["t"] != "SH" or "x" in s:
        continue
    known = inn_of.get(s["text"])
    if known:
        s["z"], s["x"], s["y"], s["zoneName"] = known["z"], known["x"], known["y"], known.get("zoneName")
        continue
    near = [e for e in steps[max(0, n - 8):n + 9] if "x" in e and e.get("place") == s.get("place")]         or [e for e in steps[max(0, n - 4):n + 5] if "x" in e]
    best, z = None, ZONE_ID.get(s["text"])
    if z:  # a city: its own innkeeper
        for k in innkeepers:
            for p in spawns("npc", int(k)).get(z, [])[:1]:
                best = best or (0, k, p)
    elif near:
        z = max({e["z"] for e in near}, key=lambda zz: sum(e["z"] == zz for e in near))
        cx = sum(e["x"] for e in near if e["z"] == z) / sum(e["z"] == z for e in near)
        cy = sum(e["y"] for e in near if e["z"] == z) / sum(e["z"] == z for e in near)
        for k in innkeepers:
            for p in spawns("npc", int(k)).get(z, []):
                d = math.hypot(p[0] - cx, p[1] - cy)
                if d < 8 and (not best or d < best[0]):
                    best = (d, k, p)
    if not best:
        warnings.append(f"set hearth at {s['text']}: no innkeeper near the stop")
        continue
    s["z"], s["x"], s["y"], s["zoneName"] = z, round(best[2][0], 2), round(best[2][1], 2), ZONE_NAME.get(z)
    s.setdefault("note", name_of("npc", int(best[1])))
    inn_of[s["text"]] = s
    print(f"inn: {s['text']} -> {name_of('npc', int(best[1]))} ({z} {s['x']}, {s['y']}) {best[0]:.1f} from the stop")

# ------------------------------------------------------------------ a pick-up just before the hand-in it needs
# QuestieDB can know a prerequisite the upstream data doesn't (Rocks to Rests needs
# Favorite Food, handed in a step later beside it): the pick-up moves to just after
# that hand-in, when it's a few steps on at the same spot.
def prerequisites(q):
    r = Q.get(str(q)) or {}
    return set((r.get("preQuestSingle") or []) + (r.get("preQuestGroup") or []))


n = 0
while n < len(steps):
    s = steps[n]
    if s["t"] == "A" and s.get("q") and "x" in s:
        need = prerequisites(s["q"])
        for m in range(n + 1, min(len(steps), n + 5)):
            e = steps[m]
            if (e["t"] == "T" and e.get("q") in need and "x" in e and e.get("z") == s.get("z")
                    and math.hypot(e["x"] - s["x"], e["y"] - s["y"]) < 1.5 and e.get("races") in (None, s.get("races"))):
                steps.insert(m, steps.pop(n))  # (e is at m - 1 now: s goes just after it)
                print(f"order: {s['name']} ({s['q']}) after {e['name']} ({e['q']}), which it needs")
                n -= 1
                break
    n += 1

# ------------------------------------------------------------------ checks and output
placed = sum(1 for s in steps if "x" in s)
quest = [s for s in steps if s.get("q")]
unknown = sorted({s["q"] for s in quest if str(s["q"]) not in Q})
print(f"{len(order)} guides, {len(steps)} steps ({len(quest)} quest steps, {placed} with coordinates)")
print("chain:", " > ".join(g.split("/")[-1] for g in order))
by_t = {}
for s in steps:
    by_t[s["t"]] = by_t.get(s["t"], 0) + 1
print("by type:", by_t)
print("unknown quests:", unknown[:20], len(unknown))
noxy = [s for s in quest if "x" not in s]
print("quest steps without coordinates:", len(noxy), [(s["t"], s["q"], s["name"]) for s in noxy[:12]])
for w in sorted(set(warnings)):
    print("warn:", w)

def carry_over(path):
    """Your place, skips and bookmarks carried over from the route being replaced:
    each new quest step is matched to the same quest step of the old one (same
    objective, races and classes, in order) and says its old number as was=N.
    Travel steps aren't matched - "Tarren Mill flight master" comes up on several
    visits - so a place on one moves on to the next quest step (Guide.lua).
    Returns the old route's signature, worked out as Guide.lua does."""
    if not os.path.exists(path):
        return None
    old = []
    for line in open(path, encoding="utf-8"):
        if not re.match(r'\s*\{t="', line):
            continue
        get = lambda p: (re.search(p, line) or [None, None])[1]
        old.append({"t": get(r'\{t="(\w+)"'), "q": get(r'\bq=(\d+)'), "obj": get(r'\bobj=(\d+)'),
                    "races": get(r'races=\{([^}]*)\}'), "classes": get(r'classes=\{([^}]*)\}'),
                    "text": get(r'\btext="([^"]*)"'), "zone": get(r'zoneName="([^"]*)"')})
    if not old:
        return None
    total = 0
    for n, s in enumerate(old, 1):
        total = (total + n * ((int(s["q"] or 0)) % 9973 + len(s["t"]))) % 2147483647
    signature = f"{len(old)}:{old[0]['q'] or 'nil'}:{old[-1]['q'] or 'nil'}:{total}"

    def key(t, q, obj, races, classes, text, zone):
        if q:
            return ("q", t, str(q), str(obj or ""), races or "", classes or "")
        return None
    free = {}
    for n, s in enumerate(old, 1):
        free.setdefault(key(s["t"], s["q"], s["obj"], s["races"], s["classes"], s["text"], s["zone"]), []).append(n)
    matched = 0
    for s in steps:
        races = ", ".join(lua(r) for r in s["races"]) if s.get("races") else None
        classes = ", ".join(lua(c) for c in s["classes"]) if s.get("classes") else None
        k = key(s["t"], s.get("q"), s.get("obj"), races, classes, s.get("text"), s.get("zoneName"))
        if k and free.get(k):
            s["was"] = free[k].pop(0)
            matched += 1
    print(f"carried over: {matched} of {len(steps)} steps match a step of the old route ({len(old)} steps)")
    return signature


if WRITE:
    pack = os.path.join(SRC, "..", "pack.json")
    UPSTREAM = "v" + json.load(open(pack))["version"] if os.path.exists(pack) else "(version not known)"
    path = os.path.join(ADDON, "GuideData.lua")
    was_signature = carry_over(path)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("-- Horde 1-60 levelling route for WoW Forever. Quest IDs are QuestieDB's; NPCs, objects and\n")
        fh.write("-- coordinates are filled in from QuestieDB. Rebuilt by Tests/route_import.py.\n")
        fh.write(f"-- Route adapted from github.com/fitzforge/polestar {UPSTREAM} (guides/forever), GPL-3.0-only.\n")
        fh.write("-- t: A=accept C=complete T=turn in D=dungeon G=go to N=note SH=set hearth H=hearth\n")
        fh.write("--    FP=get flight path F=fly TR=train\n")
        fh.write("-- q = quest ID, z = zone (AreaTable) ID, x/y = map percent coords, instance = dungeon area ID\n")
        fh.write("-- (the arrow points at that dungeon's entrance), target = NPC/object/item to interact with,\n")
        fh.write("-- races/classes = only show for these ('!' = everyone except).\n")
        fh.write("-- foreverOnly = true marks a quest that is new in WoW Forever (not in Classic Era).\n")
        fh.write("-- obj = N: the step is objective N of its quest; optional = true: never holds you up;\n")
        fh.write("-- place = the stop on the route the step belongs to.\n")
        fh.write("-- Only while it holds (checked as you play): lvlBelow/lvlMin = level, part-way levels too (16.51);\n")
        fh.write("-- moneyMin = copper; noSkill = skill not learned; skill = skill learned; notKnown = spell or\n")
        fh.write("-- recipe not known; bound/notBound = hearthstone; onQuest = any in\n")
        fh.write("-- your log; solo = N: you've neither done nor got quest N (the way past a group quest);\n")
        fh.write("-- ready = Q: Q is in your log ready to hand in; hasBelow = {item, N}: fewer than N in your bags;\n")
        fh.write("-- hasAtLeast = {item, N}: N or more; turnedIn/notTurnedIn = {Q...}: all handed in / none;\n")
        fh.write("-- notOnQuest = {Q...}: none in your log; notReady = Q: Q isn't ready to hand in;\n")
        fh.write("-- available = {Q...}: each can be taken now; inZone = the zone you're in.\n")
        fh.write("-- direct = true: a hand-in straight from the giver's window (the quest is never in your log).\n")
        fh.write("-- was = N: the step's number in the route this one replaced (your place moves over).\n")
        fh.write("local _, ns = ...\nns.HordeGuides = ns.HordeGuides or {}\nns.HordeGuides.horde = {\n")
        for n, s in enumerate(steps, 1):
            fh.write(step_line(s) + f" -- {n}\n")
        fh.write("}\n")
        if was_signature:
            fh.write(f'ns.HordeGuides.hordeWas = "{was_signature}" -- the route this one replaced\n')
    print("wrote", path)
