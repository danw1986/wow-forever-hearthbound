# The intro (setup) panel for a brand new character, in the fake WoW (wowmock.lua):
# it waits for the opening cinematic, survives an Escape meant for the cinematic,
# and only counts as seen once you really close it.  Run: python Tests/setup_tests.py
import os
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
UnitLevel = function() return 1 end
MOCK.cinematic = true
InCinematic = function() return MOCK.cinematic end
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
# one second of game time: the timers that are due run
step = L.eval("""function()
    MOCK.time = MOCK.time + 1
    local t = MOCK.timers
    MOCK.timers = {}
    for _, fn in ipairs(t) do pcall(fn) end
end""")
fire("ADDON_LOADED", "Hearthbound")
fire("PLAYER_LOGIN")


def setup_shown():
    f = G.HearthboundSetupFrame
    return bool(f and f._shown)


for _ in range(10):
    step()
check("during the opening cinematic: the intro waits", not setup_shown())
G.MOCK.cinematic = False
for _ in range(6):
    step()
    if setup_shown():
        break
check("cinematic over: the intro shows", setup_shown())
check("...and isn't marked seen yet", not ns.cdb.setupDone)
# an Escape the moment it appears (meant for the cinematic)
G.HearthboundSetupFrame.Hide(G.HearthboundSetupFrame)
G.HearthboundSetupFrame._scripts.OnHide(G.HearthboundSetupFrame)
check("an Escape right away doesn't count as seen", not ns.cdb.setupDone)
for _ in range(2):
    step()
check("...and the intro comes back", setup_shown())
# closing it properly, a while later
G.MOCK.time = G.MOCK.time + 10
G.HearthboundSetupFrame.Hide(G.HearthboundSetupFrame)
G.HearthboundSetupFrame._scripts.OnHide(G.HearthboundSetupFrame)
check("closing it later counts as seen", ns.cdb.setupDone is True)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
