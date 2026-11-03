# Things that keep a long session light, in the fake WoW (wowmock.lua): a quest scan
# that can't run or hits a bad quest doesn't pile up work for the rest of the session,
# and what the panel now reuses each second behaves like new.
# Run: python Tests/performance_tests.py
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


def addon(setup=""):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
    L.execute(setup)
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
    return L, ns


QUESTIE = """
debugprofilestop = function() return os.clock() * 1000 end
FAKE = { allIdsCalls = 0, broken = true, names = { [1] = "First Quest", [2] = "Second Quest", [3] = "Third Quest" } }
local function Type(data)
    return { Get = function(id, field) local r = data[id] return r and r[field] end }
end
LibQuestieDB = {
    RequireContract = function() return true end,
    Quest = {
        Get = function(id, field)
            if field == "name" then return FAKE.names[id] end
            if field == "startedBy" then return { { 100 } } end
        end,
        GetAllIds = function()
            FAKE.allIdsCalls = FAKE.allIdsCalls + 1
            if FAKE.broken then error("no quests yet") end
            return { 1, 2, 3 }
        end,
    },
    Npc = Type({ [100] = { name = "Giver", spawns = { [14] = { { 50, 50 } } } } }),
    Object = Type({}), Item = Type({}),
}
-- how many are waiting on the scan (a local of QuestieLink.lua)
function FAKE.Waiters(ns)
    local function Up(fn, want)
        local i = 1
        while true do
            local name, v = debug.getupvalue(fn, i)
            if not name then return nil end
            if name == want then return v end
            i = i + 1
        end
    end
    return #Up(Up(ns.QuestieQuestGivers, "ScanQuests"), "scanWaiters")
end
"""

# 1. a scan that can't start: no pile of work, and not asked for every time
L, ns = addon(QUESTIE)
fake = L.globals().FAKE
L.eval("""function(ns)
    for i = 1, 5000 do ns.QuestieQuestGivers(function() end) end
end""")(ns)
check("5000 requests for a scan that can't run: the waiting list stays small", fake.Waiters(ns) <= 32, fake.Waiters(ns))
check("...and the scan is only tried once in that moment", fake.allIdsCalls == 1, fake.allIdsCalls)

# 2. it comes right later: the scan runs, and everyone waiting hears, once each
L, ns = addon(QUESTIE)
fake = L.globals().FAKE
heard = L.eval("""function(ns)
    FAKE.heard = 0
    FAKE.once = function() FAKE.heard = FAKE.heard + 1 end
    for i = 1, 100 do ns.QuestieQuestGivers(FAKE.once) end
    FAKE.broken = false
    for round = 1, 8 do
        MOCK.time = MOCK.time + 11
        ns.QuestieQuestGivers(FAKE.once)
        MOCK.RunTimers()
    end
    return FAKE.heard
end""")(ns)
check("once the database works, the scan finishes", fake.Waiters(ns) == 0, fake.Waiters(ns))
check("the same callback asked 100 times runs once, not 100 times (plus any after the scan)", 1 <= heard <= 9, heard)

# 3. one bad quest doesn't stop the scan for the rest of the session
L, ns = addon(QUESTIE)
fake = L.globals().FAKE
L.eval("""function(ns)
    FAKE.broken = false
    FAKE.names[2] = 12345 -- not a title: errors inside the scan
    for round = 1, 8 do
        MOCK.time = MOCK.time + 11
        ns.QuestieQuestGivers(function() end)
        MOCK.RunTimers()
    end
end""")(ns)
check("a quest that breaks the scan: it still finishes", ns.QuestieQuestGivers() is not None, "still scanning")
check("...nothing left waiting", fake.Waiters(ns) == 0, fake.Waiters(ns))
check("...and the bad quest is counted", ns.questieScanStats.failed == 1 if ns.questieScanStats else False)

# 4. the panel's one writer: each heading still folds its own section
L, ns = addon()
L.globals().MOCK.RunTimers()
ns.db.compactPanel = False
toggles = L.eval("""function(ns)
    ns.UpdatePanel()
    local seen, out = {}, {}
    for _, f in ipairs(MOCK.frames) do
        local fn = rawget(f, "onClick")
        if type(fn) == "function" and not seen[fn] then
            seen[fn] = true
            local before = {}
            for k in pairs(ns.db.collapsedSections) do before[k] = true end
            pcall(fn, "LeftButton")
            for k, v in pairs(ns.db.collapsedSections) do
                if v and not before[k] then
                    out[#out + 1] = { fn = fn, key = k }
                    ns.db.collapsedSections[k] = nil
                end
            end
        end
    end
    ns.UpdatePanel()
    return out
end""")(ns)
heads = [toggles[i] for i in range(1, len(toggles) + 1)]
check("the panel has headings to fold", len(heads) >= 3, len(heads))
keys = [h.key for h in heads]
check("each heading folds a section of its own", len(set(keys)) == len(keys), keys)
ok = True
for h in heads:
    h.fn("LeftButton")
    ok = ok and ns.db.collapsedSections[h.key] is True
    h.fn("LeftButton")
    ok = ok and ns.db.collapsedSections[h.key] is None
check("after later redraws, each still folds and unfolds its own section", ok)

# 5. the line tables are reused: nothing carries over from a line's last use
view = L.eval("""function(ns)
    local v = ns.CreateLineView(UIParent, 0, 200)
    v.add.note("clickable", nil, function() end, "a tooltip")
    v.add.header("Heading", { collapsed = true, onClick = function() end, icon = "x" })
    local first = v.lines[1]
    v:Begin()
    v.add.row("left", "right")
    v.add.note("plain")
    return v, v.lines[1] == first
end""")(ns)
v, same = view
check("a reused line takes the new kind", v.lines[1].kind == "row" and v.lines[1].left == "left")
check("...and the old one's text, click and tooltip are gone", v.lines[1].text is None and v.lines[1].onClick is None and v.lines[1].tooltip is None)
check("the next one's old click and icon are gone too", v.lines[2].onClick is None and v.lines[2].icon is None and v.lines[2].collapsed is None)
check("the table really is reused", same)
check("lines from before the redraw don't linger", v.lines[3] is None)

print()
print("FAILED:" if fails else "ALL PASSED", fails)
sys.exit(1 if fails else 0)
