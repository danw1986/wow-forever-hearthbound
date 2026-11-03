# Levelling panel sections in the fake WoW (wowmock.lua).
# Class quests: on a client whose spell-icon lookup returns two numbers (the icon and
# its original icon), the reminders show a proper icon, not a run of numbers.
# Run: python Tests/panel_tests.py
import os
import re
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


L = LuaRuntime(unpack_returned_tuples=True)
L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
L.execute("""
C_Spell = { GetSpellTexture = function(id) return 132341, 132342 end }
IsPlayerSpell = function() return false end
UnitLevel = function() return 32 end
""")
G = L.globals()
ns = L.table()
load = L.eval("""function(src, name, ns)
    local fn, err = load(src, "@" .. name)
    if not fn then return false, err end
    local ok, e = pcall(fn, "Hearthbound", ns)
    return ok, e
end""")
for f in [l.strip() for l in open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8") if l.strip() and not l.startswith("#")]:
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

# build the class quests section (order 25) with a recording "add"
notes = L.eval("""function(ns)
    local out = {}
    local add = {
        header = function(t) out[#out + 1] = "H:" .. t end,
        note = function(t) out[#out + 1] = t end,
        row = function() end, list = function() end, bar = function() end,
    }
    for _, s in ipairs(ns.sections) do
        if s.order == 25 then s.build(add, 32) end
    end
    return out
end""")(ns)
lines = list(notes.values())
for l in lines:
    print("  ", l)
check("the class quests section shows for a level 32 warrior", lines and lines[0] == "H:Class quests", lines)
icons = [re.search(r"\|T([^|]*)\|t", l) for l in lines[1:3]]
check("each stance reminder starts with a proper icon (size 12, not 132342)",
      all(m and m.group(1).startswith("132341:12:12:") for m in icons), [m and m.group(1) for m in icons])
check("...and no stray run of numbers", not any("132342" in l for l in lines), lines)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
