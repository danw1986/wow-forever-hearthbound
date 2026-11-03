# Builds ClassData.lua from the upstream checkout (github.com/fitzforge/polestar, GPL-3.0):
# each class's specs and stat weights, class quest chains and talent plans.
#   python Tests/class_import.py <upstream folder> [--write]
# <upstream folder> holds addon/Polestar/Gear/Weights.lua, guides/forever/class/ and
# talents/forever/. Everything is read as text: nothing of it is run.
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
SRC = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else None
WRITE = "--write" in sys.argv
if not SRC:
    sys.exit("usage: class_import.py <upstream folder> [--write]")
CLASSES = ["WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"]
RACES = {"orc": "orc", "troll": "troll", "tauren": "tauren", "undead": "scourge", "scourge": "scourge", "skyborne": "skyborne",
         "human": "human", "dwarf": "dwarf", "gnome": "gnome", "nightelf": "nightelf"}


# ------------------------------------------------------------------ a Lua table literal, as data
def read_table(text, start):
    """the table starting at text[start] == '{': a list, a dict, or both as a dict"""
    i = start + 1
    out, n = {}, 0

    def skip(i):
        while i < len(text):
            if text[i].isspace():
                i += 1
            elif text.startswith("--", i):
                i = text.index("\n", i)
            else:
                break
        return i

    def value(i):
        c = text[i]
        if c == "{":
            return read_table(text, i)
        if c == '"':
            j = text.index('"', i + 1)
            return text[i + 1:j], j + 1
        m = re.compile(r"-?\d+(\.\d+)?|true|false").match(text, i)
        if not m:
            raise ValueError(f"not a literal at {text[i:i + 40]!r}")
        raw = m.group(0)
        v = raw == "true" if raw in ("true", "false") else (float(raw) if "." in raw else int(raw))
        return v, m.end()

    while True:
        i = skip(i)
        if text[i] == "}":
            i += 1
            break
        m = re.compile(r"([A-Za-z_]\w*)\s*=\s*").match(text, i)
        if m:
            v, i = value(m.end())
            out[m.group(1)] = v
        else:
            v, i = value(i)
            n += 1
            out[n] = v
        i = skip(i)
        if text[i] in ",;":
            i += 1
    if out and all(isinstance(k, int) for k in out):
        return [out[k] for k in sorted(out)], i
    return out, i


def table_after(text, marker):
    return read_table(text, text.index("{", text.index(marker)))[0]


weights_src = open(os.path.join(SRC, "addon", "Polestar", "Gear", "Weights.lua"), encoding="utf-8").read()
META = table_after(weights_src, "Gear.CLASSES =")
WEIGHTS = table_after(weights_src, "Gear.WEIGHTS =")


# ------------------------------------------------------------------ class quest chains
def race_list(words):
    out = []
    for w in words:
        for c in w.split(","):
            key = c.strip().lower().replace(" ", "")
            if key in RACES and RACES[key] not in out:
                out.append(RACES[key])
    return out or None


def strip_note(line):
    return re.split(r"\s--\s", line, maxsplit=1)[0].split(" # ")[0].rstrip()


def read_guide(path):
    g = {"spells": [], "turnins": [], "gear": False}
    step_races = None
    for raw in open(path, encoding="utf-8"):
        raw = raw.rstrip("\n")
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        line = strip_note(raw)
        if not raw[:1].isspace():
            key, _, rest = line.partition(" ")
            if key == "step":
                step_races = None
            elif key == "reward":
                m = re.match(r'spell (\d+) "([^"]*)"', rest)
                if m:
                    g["spells"].append(int(m.group(1)))
                elif rest.startswith("item "):
                    g["gear"] = True
            else:
                g[key] = rest.strip()
            continue
        words = line.split()
        if words[0] == "only":
            step_races = race_list(words[1:])
        elif words[0] == "turnin" and len(words) > 1 and words[1].isdigit() and "optional" not in words:
            races = race_list(words[words.index("only") + 1:]) if "only" in words else step_races
            g["turnins"].append((int(words[1]), races))
    return g


def class_quests(class_key):
    folder = os.path.join(SRC, "guides", "forever", "class", class_key.lower())
    out = []
    for name in sorted(os.listdir(folder)):
        if not name.endswith(".guide"):
            continue
        g = read_guide(os.path.join(folder, name))
        low, _, high = g.get("levels", "1-60").partition("-")
        entry = {"id": name[:-6].replace("-alliance", "").replace("-horde", ""),
                 "title": re.sub(r"\s*\((Horde|Alliance)\)$", "", g.get("title", name)),
                 "min": int(low), "max": int(high or low), "why": g.get("why", "")}
        faction = g.get("faction")
        if faction in ("Horde", "Alliance"):
            entry["faction"] = faction
        races = race_list(g.get("race", "").split(","))
        if races:
            entry["races"] = races
        if g["spells"]:
            entry["spells"] = g["spells"]
            if g["gear"]:
                entry["gear"] = True  # still worth finishing once you know its spells
        # the chain's last hand-in, for each race it has its own ending for: the last first
        seen, ends = set(), []
        for q, r in reversed(g["turnins"]):
            key = tuple(r or ())
            if key not in seen:
                seen.add(key)
                ends.append({"q": q, "races": r} if r else {"q": q})
        entry["ends"] = ends
        if not ends and not g["spells"]:
            print("warn: nothing shows when this is done:", class_key, name)
        out.append(entry)
    out.sort(key=lambda e: (e["min"], e["max"], e["title"]))
    return out


# ------------------------------------------------------------------ talent plans
def talents(class_key):
    d = json.load(open(os.path.join(SRC, "talents", "forever", class_key.lower() + ".json"), encoding="utf-8"))
    builds = {}
    for b in d["builds"]:
        picks = []
        for p in b["picks"]:
            row = {"t": p["talent"], "tree": p["tree"]}
            if p.get("rank", 1) > 1:
                row["r"] = p["rank"]
            if p.get("note"):
                row["n"] = p["note"]
            picks.append(row)
        builds[b["key"]] = {"split": b.get("split"), "picks": picks}
    return d.get("summary", ""), builds


# ------------------------------------------------------------------ Lua
def lua(v):
    if v is None:
        return "nil"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return '"' + v.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'
    if isinstance(v, (list, tuple)):
        return "{" + ", ".join(lua(x) for x in v) + "}"
    return "{" + ", ".join(f"{k}={lua(x)}" for k, x in v.items() if x is not None) + "}"


lines = ["-- Each class's specs and stat weights, class quest chains and talent plans.",
         "-- Rebuilt by Tests/class_import.py.",
         None,
         "-- weights: per spec, one point of the main stat is about 1 (dps = melee weapon DPS, rdps = ranged).",
         "-- quests: min/max = levels; ends = the hand-ins that finish it (the first that fits your race);",
         "-- spells = what it teaches, also a sign it's done; gear = it pays gear too, so finish it anyway.",
         "-- builds: per spec, an ordered list of talent picks: t = talent, tree, r = rank, n = why.",
         "local _, ns = ...",
         "ns.CLASS_DATA = {"]
total = {"quests": 0, "picks": 0}
for c in CLASSES:
    meta = META[c]
    summary, builds = talents(c)
    quests = class_quests(c)
    total["quests"] += len(quests)
    total["picks"] += sum(len(b["picks"]) for b in builds.values())
    missing = [s["key"] for s in meta["specs"] if s["key"] not in WEIGHTS[c] or s["key"] not in builds]
    if missing:
        print("warn: no weights or build for", c, missing)
    lines.append(f"  {c} = {{")
    lines.append(f"    default = {lua(meta['default'])}, summary = {lua(summary)},")
    lines.append("    specs = " + lua([{"key": s["key"], "label": s["label"], "names": s["names"]} for s in meta["specs"]]) + ",")
    lines.append("    weights = {")
    for spec, w in WEIGHTS[c].items():
        lines.append(f"      {spec} = {lua(w)},")
    lines.append("    },")
    lines.append("    quests = {")
    for q in quests:
        lines.append("      " + lua(q) + ",")
    lines.append("    },")
    lines.append("    builds = {")
    for key, b in builds.items():
        lines.append(f"      {key} = {{ split = {lua(b['split'])}, picks = {{")
        for p in b["picks"]:
            lines.append("        " + lua(p) + ",")
        lines.append("      } },")
    lines.append("    },")
    lines.append("  },")
lines.append("}")
print(f"{len(CLASSES)} classes, {total['quests']} class quest chains, {total['picks']} talent picks")
for c in CLASSES:
    print(f"  {c:8s} {len(class_quests(c)):3d} chains")

if WRITE:
    pack = os.path.join(SRC, "guides", "pack.json")
    version = "v" + json.load(open(pack))["version"] if os.path.exists(pack) else "(version not known)"
    lines[2] = f"-- Adapted from github.com/fitzforge/polestar {version}, GPL-3.0-only."
    path = os.path.join(ADDON, "ClassData.lua")
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines) + "\n")
    print("wrote", path, os.path.getsize(path), "bytes")
