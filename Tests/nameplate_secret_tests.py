# Nameplates on a client that hides figures from addons ("secret" values: an enemy's
# health, its name...). Like the game, a hidden value here errors on any sum,
# comparison or join - it can only go straight into a bar or a text.
# Run: python Tests/nameplate_secret_tests.py
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
local function no() error("attempt to use a secret value") end
local SecretMT = { __lt = no, __le = no, __add = no, __sub = no, __mul = no, __div = no, __mod = no,
                   __pow = no, __unm = no, __concat = no, __len = no }
function MakeSecret(v) return setmetatable({ v = v }, SecretMT) end
issecretvalue = function(v) return type(v) == "table" and getmetatable(v) == SecretMT end
MOCK.errors = {}
MOCK.hp = 40
MOCK.plates = {}
local p = MOCK.New("Frame", UIParent)
p.UnitFrame = MOCK.New("Button", p)
p.UnitFrame.healthBar = MOCK.New("StatusBar", p.UnitFrame)
p.UnitFrame.healthBar:SetMinMaxValues(0, MakeSecret(100))
p.UnitFrame.healthBar:SetValue(MakeSecret(40))
p.UnitFrame.name = MOCK.New("FontString", p.UnitFrame)
MOCK.plates.nameplate1 = p
C_NamePlate = {
    GetNamePlateForUnit = function(u) return MOCK.plates[u] end,
    GetNamePlates = function() return { p } end,
}
UnitCanAttack = function() return true end
UnitExists = function() return false end
UnitIsUnit = function() return false end
local function Plate(u) return type(u) == "string" and u:find("^nameplate") ~= nil end
UnitName = function(u) if Plate(u) then return MakeSecret("Ornery Galestrider") end return "Testchar" end
UnitLevel = function(u) return u == "player" and 12 or 9 end
UnitClassification = function() return "normal" end
UnitHealth = function(u) if Plate(u) then return MakeSecret(MOCK.hp) end return 100 end
UnitHealthMax = function(u) if Plate(u) then return MakeSecret(100) end return 100 end
UnitHealthPercent = function() return MakeSecret(MOCK.hp) end
CurveConstants = { ScaleTo100 = 1 }
Enum = { StatusBarInterpolation = { ExponentialEaseOut = 1 } }
UnitReaction = function() return 2 end
UnitIsPlayer = function() return false end
UnitIsTapDenied = function() return false end
UnitDetailedThreatSituation = function() return nil end
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
        if fn and (not ev or ev[event]) then
            local ok, err = pcall(fn, f, event, table.unpack(args))
            if not ok then table.insert(MOCK.errors, event .. ": " .. tostring(err)) end
        end
    end
end""")
fire("ADDON_LOADED", "Hearthbound")
fire("PLAYER_LOGIN")
for e in list(G.MOCK.errors.values())[:3]:
    print("   login error:", str(e)[:300])
ns.db.debugPlates = True  # (any part of an update that fails says so)
fire("NAME_PLATE_UNIT_ADDED", "nameplate1")
p = G.MOCK.plates["nameplate1"]
d = p.hb
is_secret = G.issecretvalue
plate_errors = [m for m in G.MOCK.printed.values() if "plates" in str(m)]
check("hidden figures: the plate is drawn with no errors", d is not None and d._shown and not plate_errors and not list(G.MOCK.errors.values()),
      (plate_errors, list(G.MOCK.errors.values())))
c = d.hp._color
check("the health bar is coloured (hostile red), not left white", c is not None and c[1] > 0.6 and c[2] < 0.4, c and tuple(c.values()))
check("the hidden health goes straight into the bar", is_secret(d.hp._value) and d.hp._value.v == 40 and d.secret, d.hp._value)
check("the hidden name goes straight into its text", is_secret(d.name._text) and d.name._text.v == "Ornery Galestrider", d.name._text)
check("the level still shows", d.level._text is not None and "9" in d.level._text, d.level._text)
# a hit: the hidden health drops
G.MOCK.hp = 15
fire("UNIT_HEALTH", "nameplate1")
check("hit: the bar takes the new hidden health", is_secret(d.hp._value) and d.hp._value.v == 15, d.hp._value)
d._scripts.OnUpdate(d, 0.05)  # (our own slide stays out of it - the game smooths the bar)
check("...our own slide leaves it alone (no error)", is_secret(d.hp._value) and d.hp._value.v == 15)
ok = L.eval("function(ns) return pcall(ns.ThreatPlatesDebug) end")(ns)
check("/hb plates debug copes with hidden figures", ok is True or (isinstance(ok, tuple) and ok[0]), ok)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
