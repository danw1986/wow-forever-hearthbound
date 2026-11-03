# Decode QuestieDB's Forever data (base64 + CBOR rows in the "## X-..." metadata of
# QuestieDB_Forever.toc) to JSON, for the offline route checks.
# Needs: pip install cbor2.  Run: python Tests/questiedb_export.py  -> Tests/questiedb.json
import base64
import json
import os
import re
import sys
import zlib

import cbor2

HERE = os.path.dirname(os.path.abspath(__file__))
TOC = os.path.join(HERE, "..", "..", "QuestieDB", "QuestieDB_Forever.toc")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "questiedb.json")

FIELDS = {
    "Quest": {1: "name", 2: "startedBy", 3: "finishedBy", 4: "requiredLevel", 5: "questLevel", 6: "requiredRaces",
              7: "requiredClasses", 10: "objectives", 12: "preQuestGroup", 13: "preQuestSingle", 16: "exclusiveTo",
              17: "zoneOrSort", 22: "nextQuestInChain", 27: "breadcrumbForQuestId"},
    "Npc": {1: "name", 7: "spawns", 9: "zoneID"},
    "Object": {1: "name", 4: "spawns", 5: "zoneID"},
    "Item": {1: "name", 2: "npcDrops", 3: "objectDrops", 5: "startQuest"},
}

meta = {}
for line in open(TOC, encoding="utf-8"):
    if line.startswith("## X-"):
        k, v = line[3:].split(":", 1)
        meta[k.strip()] = v.strip()


def stored(key):
    v = meta.get(key)
    if v is None:
        return None
    m = re.match(r"^~(\d+)~$", v)
    if m:
        return "".join(meta[key + "-" + str(i)] for i in range(1, int(m.group(1)) + 1))
    return v


def plain(v):
    if isinstance(v, bytes):
        return v.decode("utf-8", "replace")
    if isinstance(v, dict):
        return {str(plain(k)): plain(x) for k, x in v.items()}
    if isinstance(v, (list, tuple)):
        return [plain(x) for x in v]
    return v


out = {}
for entity, fields in FIELDS.items():
    raw = base64.b64decode(stored(f"X-{entity}-IDS"))
    ids = None
    for wbits in (15, -15, 31):
        try:
            ids = cbor2.loads(zlib.decompress(raw, wbits))
            break
        except Exception:
            pass
    table = {}
    for i in ids:
        s = stored(f"X-{entity}-{i}-S")
        if not s:
            continue
        row = cbor2.loads(base64.b64decode(s))
        if isinstance(row, list):  # a dense row: fields 1..n in order
            row = {k + 1: v for k, v in enumerate(row)}
        rec = {}
        for f, name in fields.items():
            if f in row and row[f] is not None:
                rec[name] = plain(row[f])
            else:
                t = stored(f"X-{entity}-{i}-{f}")  # table fields live in their own key
                if t:
                    rec[name] = plain(cbor2.loads(base64.b64decode(t)))
        table[str(i)] = rec
    out[entity] = table
    print(entity, len(table))
json.dump(out, open(OUT, "w"))
print("->", OUT)
