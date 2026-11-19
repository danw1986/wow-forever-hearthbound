# Rares near you in the quest targets window (Rares.lua, QuestTargets.lua), in the
# fake WoW (wowmock.lua) with the whole addon loaded: a rare the game shows on the
# minimap, or by its nameplate, goes to the top of the window with the first
# marker; rares on your side and faction leaders don't; one that dies or isn't
# seen for a while drops off; the setting turns it off.
# Run: python Tests/rares_tests.py
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
FILES = [l.strip() for l in open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8") if l.strip() and not l.startswith("#")]
fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


L = LuaRuntime(unpack_returned_tuples=True)
L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
L.execute("""
W = { vig = {}, vinfo = {}, vpos = {}, units = {} }
C_VignetteInfo = {
    GetVignettes = function() return W.vig end,
    GetVignetteInfo = function(g) return W.vinfo[g] end,
    GetVignettePosition = function(g) local p = W.vpos[g] if p then return { x = p[1], y = p[2] } end end,
}
UnitExists = function(u) return W.units[u] ~= nil end
UnitGUID = function(u) local x = W.units[u] return x and x.guid or (u == "player" and "Player-1-1") or nil end
UnitName = function(u) local x = W.units[u] return x and x.name or (u == "player" and "Testchar") or nil end
UnitClassification = function(u) local x = W.units[u] return x and x.class or "normal" end
UnitIsDead = function(u) local x = W.units[u] return x and x.dead or false end
UnitCanAttack = function(_, u) local x = W.units[u] return x and x.hostile or false end
UnitLevel = function(u) local x = W.units[u] return x and x.level or 12 end
""")
G = L.globals()
ns = L.table()
load = L.eval("""function(src, name, ns)
    local fn, err = load(src, "@" .. name)
    if not fn then return false, err end
    local ok, e = pcall(fn, "Hearthbound", ns)
    return ok, e
end""")
for f in FILES:
    ok, err = load(open(os.path.join(ADDON, f), encoding="utf-8").read(), f, ns)
    if not ok:
        print("load", f, err)
fire = L.eval("""function(event, ...)
    local args = { ... }
    for _, f in ipairs(MOCK.frames) do
        local fn = rawget(f, "_scripts") and f._scripts.OnEvent
        local ev = rawget(f, "_events")
        if type(ev) ~= "table" then ev = nil end
        if fn and (not ev or ev[event]) then pcall(fn, f, event, table.unpack(args)) end
    end
end""")
fire("ADDON_LOADED", "Hearthbound")
fire("PLAYER_LOGIN")
L.execute("MOCK.RunTimers()")
# where you are and what QuestieDB knows (1 map percent = 10 yards here)
L.eval("""function(ns)
    ns.PlayerWorldPos = function() return 1, 500, 500 end
    ns.WorldPos = function(_, x, y) return 1, x * 10, y * 10 end
    local NPC = {
        [1001] = { name = "Gruff the Rare", rank = 4, maxLevel = 14 },
        [1002] = { name = "Thrall", rank = 3, friendlyToFaction = "H" },
        [1003] = { name = "Old Scar", rank = 2, maxLevel = 15 },
    }
    ns.QuestieGet = function(t, id, f) local n = t == "Npc" and NPC[id] return n and n[f] end
end""")(ns)


def vignette(guid, npc, name, x=52, y=50, dead=False):
    L.execute(f"""
        table.insert(W.vig, "{guid}")
        W.vinfo["{guid}"] = {{ objectGUID = "Creature-0-1-0-1-{npc}-0000000001", name = "{name}", isDead = {str(dead).lower()} }}
        W.vpos["{guid}"] = {{ {x / 100}, {y / 100} }}
    """)


def rows():
    """the window's rows as shown: (name text, info text, macro)"""
    out = []
    for f in G.MOCK.frames.values():
        attrs = f._attrs
        if attrs and attrs["macrotext1"] and f._shown and f.target:
            out.append((str(f.name._text), str(f.info._text), str(attrs["macrotext1"])))
    return out


def update():
    ns.RaresScan()
    ns.UpdateQuestTargets()


vignette("v1", 1001, "Gruff the Rare", 52, 50)  # 20 yards away
update()
r = rows()
check("a rare on the minimap is in the quest targets window", any("Gruff the Rare" in n for n, _, _ in r), r)
first = r[0] if r else ("", "", "")
check("...at the top, with the first marker (skull)", "Gruff the Rare" in first[0] and "/tm [exists,harm,nodead] 8" in first[2], first)
check("...says it's a rare, and how far", "rare" in first[1] and "yd" in first[1], first[1])
check("...and the row targets it", "/targetexact Gruff the Rare" in first[2], first[2])
check("the window shows for it, with no quest wanting a mob", bool(G.HearthboundQuestTargets._shown))

vignette("v2", 1002, "Thrall")
vignette("v3", 1003, "Old Scar", 60, 50)  # 100 yards
update()
names = [n for n, _, _ in rows()]
check("one on your side (or a faction leader) isn't listed", not any("Thrall" in n for n in names), names)
check("a rare elite is, and says so", any("Old Scar" in n for n in names) and any("rare elite" in i for _, i, _ in rows()), rows())
check("nearest first", names and "Gruff the Rare" in names[0], names)

L.execute('W.vinfo["v1"].isDead = true')
update()
check("one that dies drops off", not any("Gruff the Rare" in n for n, _, _ in rows()), rows())

L.execute("W.vig = {} MOCK.time = MOCK.time + 31")
update()
check("one not seen for half a minute drops off", not any("Old Scar" in n for n, _, _ in rows()), rows())

# a nameplate (or your target / mouseover) that says rare
L.execute('W.units.nameplate1 = { guid = "Creature-0-1-0-1-2001-0000000002", name = "Plate Prowler", class = "rare", hostile = true, level = 15 }')
ns.RaresLookAt("nameplate1")
update()
r = rows()
check("a rare by its nameplate is listed, in sight", any("Plate Prowler" in n and "in sight" in i for n, i, _ in r), r)
L.execute('W.units.nameplate2 = { guid = "Creature-0-1-0-1-2002-0000000003", name = "Friendly Fellow", class = "rare", hostile = false }')
ns.RaresLookAt("nameplate2")
update()
check("...but not one you can't attack", not any("Friendly Fellow" in n for n, _, _ in rows()), rows())
L.execute('W.units.nameplate3 = { guid = "Creature-0-1-0-1-2003-0000000004", name = "Plain Wolf", class = "normal", hostile = true }')
ns.RaresLookAt("nameplate3")
update()
check("...nor an ordinary mob", not any("Plain Wolf" in n for n, _, _ in rows()), rows())

ns.db.targetsRares = False
L.execute("MOCK.time = MOCK.time + 1")
update()
check("turned off: no rares listed", not any("Plate Prowler" in n for n, _, _ in rows()), rows())
errors = list(G.MOCK.errors.values())
check("no errors", not errors, errors[:3])

print()
print("ALL PASS" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
