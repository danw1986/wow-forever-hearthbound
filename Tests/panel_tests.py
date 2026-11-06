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

# the Left behind section: off unless you ask for it, and the alert doesn't depend on it
left = L.eval("""function(ns)
    local function Section(order)
        local out = {}
        local add = setmetatable({ note = function(t) out[#out + 1] = t end, header = function(t) out[#out + 1] = "H:" .. t end },
                                 { __index = function() return function() end end })
        for _, s in ipairs(ns.sections) do if s.order == order then s.build(add, 12) end end
        return table.concat(out, "; ")
    end
    ns.cdb.leftBehind = { { n = 1, title = "Camping 101", kind = "pickup", who = "Raan", place = "Valanaar", time = 1 } }
    local off = Section(28)
    local list = #ns.cdb.leftBehind
    ns.db.showLeftBehind = true
    local on = Section(28)
    ns.db.showLeftBehind = false
    return off, on, list, ns.db.leaveTownAlert
end""")(ns)
check("the panel has no Left behind section by default", left[0] == "", left[0])
check("...and the quests are still remembered for /hb left", left[2] == 1)
check("turned on in Settings, it comes back", "Camping 101" in left[1], left[1])
check("the don't-leave-yet alert stays on", left[3] is True)

# spacing: the panel's sections stand apart; other windows' lines are as they were
results = L.eval("""function(ns)
    local out = {}
    local plain = ns.CreateLineView(UIParent, 0, 200)
    plain.add.row("a", "b")
    plain.add.note("n")
    plain.add.list("l", "x")
    plain.add.header("H")
    out.plain = plain:Render(0)

    local look = { row = 16, noteGap = 4, listGap = 5, headerAbove = 8, header = 16, sectionGap = 8 }
    local roomy = ns.CreateLineView(UIParent, 0, 200, look)
    roomy.add.row("a", "b")
    roomy.add.row("c", "d")
    out.oneSection = roomy:Render(0)
    roomy:Begin()
    roomy.add.row("a", "b")
    roomy.add.row("c", "d")
    roomy.lines[2].sectionStart = true
    out.twoSections = roomy:Render(0)
    roomy:Begin()
    roomy.add.row("a", "b")
    roomy.lines[1].sectionStart = true
    out.firstLine = roomy:Render(0)
    return out
end""")(ns)
check("other windows keep their spacing", results.plain == -(15 + (12 + 3) + (12 + 4) + (7 + 15)), results.plain)
check("the panel's lines have more room", results.oneSection == -32, results.oneSection)
check("a new section adds a gap", results.twoSections == -40, results.twoSections)
check("...but not above the first line", results.firstLine == -16, results.firstLine)

# a label too long for its row is cut short, and the next use of that line isn't
long_row = L.eval("""function(ns)
    local v = ns.CreateLineView(UIParent, 0, 230)
    v.add.row("Zephras Isle 1-12 new here", "Getting low for you")
    v:Render(0)
    local l = v.pool[1]
    local cut = l.a._w
    local wrap = l.a._wrapOff
    v:Begin()
    v.add.note("a note that goes back to wrapping")
    v:Render(0)
    return cut, wrap, l.a._wrapOff, l.clipped
end""")
L.execute("""
local Mt = getmetatable(CreateFrame("Frame"))
local base = Mt.__index
Mt.__index = function(self, k)
    if k == "SetWordWrap" then return function(s, on) s._wrapOff = not on end end
    return base(self, k)
end
""")
cut, wrap, after, clipped = long_row(ns)
check("a long label stops short of the value beside it", cut == 230 - 19 * 6 - 8, cut)
check("...on one line", wrap is True, wrap)
check("the same line used for a note wraps again", after is False and clipped is None, (after, clipped))

# the real panel marks each section, in compact and in full
marks = L.eval("""function(ns)
    local function Up(fn, want)
        local i = 1
        while true do
            local name, v = debug.getupvalue(fn, i)
            if not name then return nil end
            if name == want then return v end
            i = i + 1
        end
    end
    local out = {}
    for _, compact in ipairs({ true, false }) do
        ns.db.compactPanel = compact
        ns.UpdatePanel()
        local view = Up(ns.UpdatePanel, "view")
        local n = 0
        for _, line in ipairs(view and view.lines or {}) do if line.sectionStart then n = n + 1 end end
        out[compact and "compact" or "full"] = n
        out[compact and "compactLines" or "fullLines"] = view and #view.lines or 0
    end
    return out
end""")(ns)
check("compact: sections are marked, so they stand apart", marks.compact >= 3 and marks.compact < marks.compactLines, (marks.compact, marks.compactLines))
check("full: so are they", marks.full >= 3 and marks.full < marks.fullLines, (marks.full, marks.fullLines))

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
