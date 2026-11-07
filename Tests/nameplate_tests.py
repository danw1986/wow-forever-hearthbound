# Nameplates (NamePlates.lua) in the fake WoW (wowmock.lua): Hearthbound's own plate
# (name line, health, threat, cast bar, raid marker, target, debuffs) in place of
# the game's art, the game's plate kept with the style off, your unit frames left
# alone, and the preview and debug commands.  Run: python Tests/nameplate_tests.py
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
MOCK.plates, MOCK.threat, MOCK.auras, MOCK.casts = {}, {}, {}, {}
MOCK.group, MOCK.target = false, nil
local function Plate(unit, boxed)
    local p = MOCK.New("Frame", UIParent)
    p.UnitFrame = MOCK.New("Button", p)
    local holder = p.UnitFrame
    if boxed then
        p.UnitFrame.HealthBarsContainer = MOCK.New("Frame", p.UnitFrame)
        holder = p.UnitFrame.HealthBarsContainer
    end
    holder.healthBar = MOCK.New("StatusBar", holder)
    holder.healthBar:SetStatusBarColor(0.9, 0.1, 0.1)
    p.UnitFrame.name = MOCK.New("FontString", p.UnitFrame)
    p.UnitFrame.BuffFrame = MOCK.New("Frame", p.UnitFrame)
    -- (no p.namePlateUnitToken: like the user's client, the plate doesn't say which unit it shows)
    MOCK.plates[unit] = p
    return p
end
MOCK.Plate = Plate
Plate("nameplate1")
Plate("nameplate2")
PlayerFrameFlash = MOCK.New("Texture", UIParent)
TargetFrameFlash = MOCK.New("Texture", UIParent)
C_NamePlate = {
    GetNamePlateForUnit = function(u)
        if u == "target" then return MOCK.target and MOCK.plates[MOCK.target] end
        return MOCK.plates[u]
    end,
    GetNamePlates = function() local t = {} for k, p in pairs(MOCK.plates) do t[#t + 1] = p end return t end,
}
C_UnitAuras = { GetAuraDataByIndex = function(u, i) return (MOCK.auras[u] or {})[i] end }
IsInGroup = function() return MOCK.group end
UnitCanAttack = function() return true end
UnitExists = function(u) return u == "target" and MOCK.target ~= nil end
UnitIsUnit = function(a, b) return b == "target" and MOCK.target == a end
UnitName = function(u) return u == "nameplate1" and "Ornery Galestrider" or "Dustwind Harpy" end
UnitLevel = function(u) return u == "player" and 12 or 9 end
UnitClassification = function(u) return u == "nameplate2" and "elite" or "normal" end
UnitHealth = function(u) return u == "nameplate1" and 35 or 100 end
UnitHealthMax = function() return 100 end
UnitReaction = function() return 2 end
UnitIsPlayer = function() return false end
UnitIsTapDenied = function() return false end
UnitCastingInfo = function(u) local c = MOCK.casts[u] if c then return c[1], "", c[2], 1000000, 1003000, false, 1, c[3] end end
GetRaidTargetIndex = function(u) return u == "nameplate1" and 8 or nil end
SetRaidTargetIconTexture = function(t, i) t._raid = i end
UnitDetailedThreatSituation = function(_, u)
    local t = MOCK.threat[u]
    if not t then return nil end
    return t[1], t[2], t[3], t[3], 100
end
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
            if not ok then print("event error", event, err) end
        end
    end
end""")
fire("ADDON_LOADED", "Hearthbound")
fire("PLAYER_LOGIN")
fire("PLAYER_ENTERING_WORLD", True, False)
for u in ("nameplate1", "nameplate2"):
    fire("NAME_PLATE_UNIT_ADDED", u)
p1, p2 = G.MOCK.plates["nameplate1"], G.MOCK.plates["nameplate2"]
d1, d2 = p1.hb, p2.hb


def rgb(c):
    return tuple(round(v, 2) for v in list(c.values())[:3])


# Hearthbound's own plate
check("Hearthbound plate drawn, the game's plate art hidden", d1 is not None and d1._shown and p1.UnitFrame._alpha == 0,
      (d1 and d1._shown, p1.UnitFrame._alpha))
print("   name line:", d1.level._text, d1.name._text, "| elite:", d2.level._text, d2.name._text)
check("name line: the level (coloured), then the name", "9" in d1.level._text and d1.name._text == "Ornery Galestrider", (d1.level._text, d1.name._text))
check("...an elite gets a +", "9+" in d2.level._text, d2.level._text)
check("health bar at 35%, hostile red, 35% shown", round(d1.hp._value, 2) == 0.35 and rgb(d1.hp._color)[0] > 0.6 and d1.hpText._text == "35%",
      (d1.hp._value, rgb(d1.hp._color), d1.hpText._text))
check("...a full one shows no %", d2.hpText._text == "", d2.hpText._text)
p1.UnitFrame.SetAlpha(p1.UnitFrame, 1)
check("the game's art stays hidden when it resets its alpha", p1.UnitFrame._alpha == 0, p1.UnitFrame._alpha)
check("raid marker shown (skull)", d1.raid._shown and d1.raid._raid == 8)
check("no threat outside a fight", not d1.threat._shown)
# threat
G.MOCK.threat["nameplate1"] = L.table_from({1: True, 2: 3, 3: 100})
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check("you have aggro: the threat line in the bar, full and red", d1.threat._shown and d1.threat._value == 1 and rgb(d1.threat._color)[0] > 0.8,
      (d1.threat._shown, d1.threat._value))
e = rgb(d1.edges[1]._color)
check("...and the plate's border goes red too", e[0] > 0.8 and e[1] < 0.3, e)
G.MOCK.threat["nameplate1"] = L.table_from({1: True, 2: 2, 3: 100})
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check("losing it: yellow line and border, breathing", rgb(d1.threat._color)[1] > 0.6 and rgb(d1.edges[1]._color)[1] > 0.6 and d1.threat.pulse._playing)
G.MOCK.group = True
G.MOCK.threat["nameplate1"] = L.table_from({1: False, 2: 0, 3: 40})
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check("on someone else: green, 40% filled, 40% beside it in a group", rgb(d1.threat._color)[1] > 0.7 and d1.threat._value == 0.4
      and d1.threat.text._text == "40%")
G.MOCK.group = False
# the health bar takes the threat colour too, so aggro shows at a glance
HOSTILE = (0.9, 0.22, 0.18)
for status, word in ((3, "aggro: red"), (2, "losing it: yellow"), (0, "on someone else: green")):
    G.MOCK.threat["nameplate1"] = L.table_from({1: status == 3, 2: status, 3: 100 if status else 40})
    fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
    check(f"health bar in the threat colour - {word}", rgb(d1.hp._color) == rgb(d1.threat._color),
          (rgb(d1.hp._color), rgb(d1.threat._color)))
G.MOCK.threat["nameplate1"] = None
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check("out of the fight: back to the enemy's own colour", rgb(d1.hp._color) == HOSTILE, rgb(d1.hp._color))
ns.db.threatHealth = False
G.MOCK.threat["nameplate1"] = L.table_from({1: True, 2: 3, 3: 100})
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check("setting off: the health bar keeps the enemy's colour, the threat line still shows", rgb(d1.hp._color) == HOSTILE
      and d1.threat._shown, rgb(d1.hp._color))
ns.db.threatHealth = True
G.MOCK.threat["nameplate1"] = L.table_from({1: False, 2: 0, 3: 40})
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
# casting
G.MOCK.casts["nameplate2"] = L.table_from({1: "Lightning Bolt", 2: 136048, 3: False})
fire("UNIT_SPELLCAST_START", "nameplate2")
check("casting: the cast bar shows the spell, in gold (interruptible)", d2.cast._shown and d2.cast.text._text == "Lightning Bolt"
      and rgb(d2.cast._color)[0] > 0.6, (d2.cast._shown, d2.cast.text._text))
G.MOCK.casts["nameplate2"] = None
fire("UNIT_SPELLCAST_STOP", "nameplate2")
check("...gone when it stops", not d2.cast._shown)
# the health going down: the bar slides, the lost chunk waits, then drains
L.execute("UnitHealth = function(u) return u == 'nameplate1' and 20 or 100 end")
fire("UNIT_HEALTH", "nameplate1")
step = d1._scripts.OnUpdate
step(d1, 0.05)
mid = d1.hp._value
check("hit for 15%: the bar slides down (not a jump)", 0.2 < mid < 0.35, mid)
for _ in range(20):
    step(d1, 0.05)
check("...and settles at 20%", abs(d1.hp._value - 0.2) < 0.01 and d1.hpText._text == "20%", (d1.hp._value, d1.hpText._text))
check("...the lost 15% still shows as a pale chunk for a moment", d1.trail._value > 0.3, d1.trail._value)
G.MOCK.time = G.MOCK.time + 1
for _ in range(10):
    step(d1, 0.05)
check("...then drains away", abs(d1.trail._value - 0.2) < 0.01, d1.trail._value)
# your target (out of a fight: the gold border)
G.MOCK.threat["nameplate1"] = None
fire("UNIT_THREAT_LIST_UPDATE", "nameplate1")
G.MOCK.target = "nameplate1"
fire("PLAYER_TARGET_CHANGED")
L.execute("for _, fn in ipairs(MOCK.timers) do fn() end MOCK.timers = {}")
e = d1.edges[1]._color
check("your target: gold border and glow", rgb(e)[0] > 0.6 and rgb(e)[2] < 0.6 and d1.glow._shown, rgb(e))
check("...the other plates dim", d2._alpha < 1 and d1._alpha == 1, (d1._alpha, d2._alpha))
# your debuffs above the name
G.MOCK.auras["nameplate1"] = L.table_from({1: L.table_from({"icon": 136207, "applications": 3, "duration": 15, "expirationTime": 1010})})
fire("UNIT_AURA", "nameplate1")
same = L.eval("function(a, b) return a == b end")  # (two Python wrappers of one Lua table aren't ==)
bf = p1.UnitFrame.BuffFrame
check("the game's own debuffs are moved onto our plate, and showing", same(bf._parent, d1) and bf._alpha == 1 and bf._shown,
      (same(bf._parent, d1), bf._alpha))
check("...so our own row stays out of the way", not d1.debuffs._shown)
# a client with no debuff frame on its plates: our own row instead
L.execute("MOCK.Plate('nameplate5') MOCK.plates.nameplate5.UnitFrame.BuffFrame = nil")
G.MOCK.auras["nameplate5"] = L.table_from({1: L.table_from({"icon": 136207, "applications": 3, "duration": 15, "expirationTime": 1010})})
fire("NAME_PLATE_UNIT_ADDED", "nameplate5")
d5 = G.MOCK.plates["nameplate5"].hb
icons = [b for b in d5.debuffs.icons.values() if b._shown]
check("no game debuff frame: your debuff in our own row above the name, with its stacks", d5.debuffs._shown and len(icons) == 1 and icons[0].count._text == 3)
# your unit frames
check("the game's threat glow on your player and target frames is hidden", G.PlayerFrameFlash._alpha == 0 and G.TargetFrameFlash._alpha == 0)
# the preview and debug
L.execute("MOCK.timers = {}")
ns.ThreatPlatesTest()
L.execute("local first = table.remove(MOCK.timers, 1) first()")
check("/hb plates test: the target's threat bar shows red", d1.threat._shown and rgb(d1.threat._color)[0] > 0.8)
L.execute("for _, fn in ipairs(MOCK.timers) do fn() end MOCK.timers = {}")
ok = L.eval("function(ns) return pcall(ns.ThreatPlatesDebug) end")(ns)
check("/hb plates debug runs", ok is True or (isinstance(ok, tuple) and ok[0]), ok)
# the style off: the game's plate back, with just the threat bar under it
ns.db.hbPlates = False
G.MOCK.threat["nameplate1"] = L.table_from({1: True, 2: 3, 3: 100})
for fn in ns.refreshers.values():
    fn()
check("style off: our plate hidden, the game's art back", not d1._shown and p1.UnitFrame._alpha == 1)
check("...and the game's debuffs handed back to its plate", same(p1.UnitFrame.BuffFrame._parent, p1.UnitFrame))
u = p1.hbThreat
check("...with the threat bar under the game's health bar", u is not None and u._shown and rgb(u._color)[0] > 0.8)
check("...and the game's health bar never recoloured", rgb(p1.UnitFrame.healthBar._color) == (0.9, 0.1, 0.1))
ns.db.hbPlates = True
for fn in ns.refreshers.values():
    fn()
check("style on again: our plate back", d1._shown and p1.UnitFrame._alpha == 0 and not p1.hbThreat._shown)

# a plate already on screen after a /reload (the game never says it was added): the sweep finds it
L.execute("MOCK.Plate('nameplate3') MOCK.timers = {}")
fire("PLAYER_ENTERING_WORLD", False, True)
L.execute("for _, fn in ipairs(MOCK.timers) do fn() end MOCK.timers = {}")
p3 = G.MOCK.plates["nameplate3"]
check("a plate already showing after a reload: picked up and drawn", p3.hb is not None and p3.hb._shown and p3.UnitFrame._alpha == 0)

# your client: the unit's health says full, but the game's own bar on the plate has the real figure
L.execute("""
MOCK.Plate('nameplate4')
local gb = MOCK.plates.nameplate4.UnitFrame.healthBar
gb:SetMinMaxValues(0, 100)
gb:SetValue(60)
UnitHealth = function() return 100 end
""")
fire("NAME_PLATE_UNIT_ADDED", "nameplate4")
p4 = G.MOCK.plates["nameplate4"]
d4 = p4.hb
check("health copied from the game's own bar (60%), not the unit's wrong figure", d4 and round(d4.hp._value, 2) == 0.6 and d4.hpText._text == "60%",
      d4 and (d4.hp._value, d4.hpText._text))
p4.UnitFrame.healthBar.SetValue(p4.UnitFrame.healthBar, 30)
check("the game's bar drops to 30%: ours heads there straight away", round(d4.goal, 2) == 0.3 and d4.hpText._text == "30%", (d4.goal, d4.hpText._text))
for _ in range(25):
    d4._scripts.OnUpdate(d4, 0.05)
check("...and slides down to it", abs(d4.hp._value - 0.3) < 0.01, d4.hp._value)
check("the game's bar itself is hidden (not just its plate frame)", p4.UnitFrame.healthBar._alpha == 0 and p4.UnitFrame._alpha == 0)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
