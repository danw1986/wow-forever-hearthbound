# The dungeon pick-up guide (DungeonPickup.lua), in the fake WoW (wowmock.lua) with the
# whole addon loaded and a made-up QuestieDB: a dungeon's quests become a guide of their
# own - each quest's chain in order (picked up, done, handed in), nearest first, then the
# quest itself, then the entrance; quests above your level or that need a dungeon's quest
# first wait, ones given inside are listed. The arrow follows it while its window is open
# and goes back to the route when it closes; your place in the levelling guide never moves.
# Run: python Tests/pickup_tests.py
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
UnitFactionGroup = function() return "Horde", "Horde" end
UnitRace = function() return "Orc", "Orc", 2 end
UnitLevel = function() return W.level end
W = { level = 18 }
""")
G = L.globals()
ns = L.table()
load = L.eval("""function(src, name, ns)
    local fn, err = load(src, "@" .. name)
    if not fn then return false, err end
    local ok, e = pcall(fn, "Hearthbound", ns)
    return ok, tostring(e)
end""")
errors = []
for f in FILES:
    ok, err = load(open(os.path.join(ADDON, f), encoding="utf-8").read(), f, ns)
    if not ok:
        errors.append(f"{f}: {err}")
check("the addon loads", not errors, errors)
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
G.MOCK.RunTimers()

# Wailing Caverns' quests (made up). One map, 1413; a map percent is 10 yards; you stand at 50, 50.
L.eval("""function(ns)
    local M = 1413
    local function at(x, y, who) return { giver = who, mapID = M, x = x, y = y, kind = "npc" } end
    W.done, W.log = {}, {}
    local Q = {
        -- a chain of three before it: a talk-only errand, then one with mobs to kill
        [101] = { title = "Errand", level = 15, requiredLevel = 10, start = at(60, 50, "Ana"), finish = at(70, 50, "Bo"),
                  talkOnly = true },
        [102] = { title = "Kill Some Raptors", level = 16, requiredLevel = 11, start = at(70, 50, "Bo"),
                  finish = at(70, 50, "Bo"), preSingle = { 101 } },
        [110] = { title = "Deep Trouble", level = 18, requiredLevel = 13, start = at(70, 51, "Bo"),
                  finish = at(70, 51, "Bo"), preSingle = { 102 } },
        -- nothing first, given close by
        [120] = { title = "Close By", level = 17, requiredLevel = 12, start = at(51, 50, "Cid"), finish = at(51, 50, "Cid") },
        -- above your level
        [130] = { title = "Too High", level = 25, requiredLevel = 21, start = at(52, 50, "Dee"), finish = at(52, 50, "Dee") },
        -- given inside
        [140] = { title = "Inside Job", level = 18, requiredLevel = 13, start = { giver = "Ghost" }, finish = at(52, 50, "Dee") },
        -- already in your log
        [150] = { title = "Carried", level = 18, requiredLevel = 13, start = at(53, 50, "Eve"), finish = at(53, 50, "Eve") },
        -- done
        [160] = { title = "Old News", level = 18, requiredLevel = 13, start = at(54, 50, "Fay"), finish = at(54, 50, "Fay") },
        -- not yours
        [170] = { title = "Alliance Only", level = 18, requiredLevel = 13, start = at(55, 50, "Gus"), finish = at(55, 50, "Gus") },
    }
    W.Q = Q
    W.done[160] = true -- Old News: handed in already
    for id, q in pairs(Q) do q.id = id q.preSingle = q.preSingle or {} q.preGroup = {} end
    ns.QuestieAvailable = function() return true end
    ns.QuestieDungeonQuestIds = function(key) if key == "wc" then return { 110, 120, 130, 140, 150, 160, 170 } end return {} end
    ns.QuestieQuestInfo = function(id) return Q[id] end
    ns.QuestieFitsYou = function(id) return id ~= 170 end
    ns.QuestieWhyNot = function() return nil end
    ns.QuestDone = function(id) return W.done[id] == true end
    ns.QuestieChain = function(id)
        local out = {}
        local function Add(q)
            for _, p in ipairs(Q[q].preSingle) do Add(p) end
            if q ~= id then out[#out + 1] = { id = q, title = Q[q].title, level = Q[q].level, start = Q[q].start, done = W.done[q] == true } end
        end
        Add(id)
        return out
    end
    -- the raptors for Kill Some Raptors, east of Bo
    ns.QuestieGet = function(kind, id, field)
        if kind == "Quest" and id == 102 and field == "objectives" then return { { { 900 } } } end
    end
    ns.QuestieSpawnSpots = function(kind, id)
        if kind == "Npc" and id == 900 then
            return { { mapID = M, x = 80, y = 50, continent = 1, wx = 800, wy = 500 },
                     { mapID = M, x = 90, y = 60, continent = 1, wx = 900, wy = 600 } }
        end
        return {}
    end
    ns.QuestieEntrance = function(key) return { mapID = M, x = 46, y = 36.5 } end
    ns.WorldPos = function(_, x, y) return 1, x * 10, y * 10 end
    ns.PlayerWorldPos = function() return 1, W.px or 500, W.py or 500 end
    ns.openQuests = { { id = 150, title = "Carried", complete = false } }
end""")(ns)

# 1. the plan
plan = ns.DungeonPickupPlan("wc")
steps = [(plan.steps[k].t, plan.steps[k].name) for k in range(1, len(plan.steps) + 1)]
check("a plan for the dungeon", plan is not None and len(steps) > 0, steps)
check("the nearest quest first", steps[0] == ("A", "Close By"), steps)
chain = [s for s in steps if s[1] in ("Errand", "Kill Some Raptors", "Deep Trouble")]
check("a quest's chain in order: pick up, (do,) hand in, each part, then the quest",
      chain == [("A", "Errand"), ("T", "Errand"), ("A", "Kill Some Raptors"), ("C", "Kill Some Raptors"),
                ("T", "Kill Some Raptors"), ("A", "Deep Trouble")], chain)
check("...a talk-only quest has nothing to do in between", ("C", "Errand") not in steps)
check("the entrance last", steps[-1] == ("G", "Wailing Caverns"), steps)
check("one in your log isn't picked up again, and is counted", ("A", "Carried") not in steps and plan.carried == 1)
check("done ones and ones not for you are left out", not any(s[1] in ("Old News", "Alliance Only") for s in steps), steps)
later = [plan.later[k].title for k in range(1, len(plan.later) + 1)]
check("one above your level waits, with its level", later == ["Too High"] and plan.later[1].level == 21, later)
inside = [plan.inside[k] for k in range(1, len(plan.inside) + 1)]
check("one given inside is listed as inside", len(inside) == 1 and "Inside Job" in inside[0], inside)
c = next(plan.steps[k] for k in range(1, len(plan.steps) + 1) if plan.steps[k].t == "C")
check("the raptors: the nearest of their spots", c.spot and c.spot.x == 80, c.spot and (c.spot.x, c.spot.y))
why = next(plan.steps[k] for k in range(1, len(plan.steps) + 1) if plan.steps[k].name == "Errand").why
check("a quest that comes first says which it's for", why == "Deep Trouble", why)
# two quests needing the same one first: the second isn't picked up before that's done
L.eval("""function(ns)
    W.Q[111] = { id = 111, title = "Also After Raptors", level = 18, requiredLevel = 13, preSingle = { 102 }, preGroup = {},
                 start = { giver = "Ike", mapID = 1413, x = 50, y = 51 }, finish = { giver = "Ike", mapID = 1413, x = 50, y = 51 } }
    local was = ns.QuestieDungeonQuestIds
    ns.QuestieDungeonQuestIds = function(key) local ids = was(key) table.insert(ids, 111) return ids end
    W.restoreIds = function() ns.QuestieDungeonQuestIds = was end
end""")(ns)
plan3 = ns.DungeonPickupPlan("wc")
s3 = [(plan3.steps[k].t, plan3.steps[k].name) for k in range(1, len(plan3.steps) + 1)]
check("two quests needing the same one first: the second waits for it, though its giver is nearest",
      ("A", "Also After Raptors") in s3 and s3.index(("A", "Also After Raptors")) > s3.index(("T", "Kill Some Raptors")), s3)
L.execute("W.restoreIds()")
# a quest QuestieDB files elsewhere (Forever's new dungeons): the dungeon's own list of IDs counts
L.eval("""function(ns)
    W.Q[180] = { id = 180, title = "Filed Elsewhere", level = 18, requiredLevel = 13, preSingle = {}, preGroup = {},
                 start = { giver = "Hal", mapID = 1413, x = 56, y = 50 }, finish = { giver = "Hal", mapID = 1413, x = 56, y = 50 } }
    ns.DungeonInfo("wc").questIds = { 180 }
end""")(ns)
plan2 = ns.DungeonPickupPlan("wc")
names2 = [plan2.steps[k].name for k in range(1, len(plan2.steps) + 1)]
check("...and the dungeon's own list of quest IDs", "Filed Elsewhere" in names2, names2)
L.eval("function(ns) ns.DungeonInfo('wc').questIds = nil end")(ns)

# 2. the window and the arrow; the levelling guide's place stays
saved_before = L.eval("function(ns) local g = ns.cdb.guide and ns.cdb.guide.horde return g and g.pos end")(ns)
check("no arrow step while the window's closed", ns.DungeonPickupArrowStep() is None)
ns.OpenDungeonPickup("wc")
G.MOCK.RunTimers()
win = G.HearthboundDungeonPickup
check("it opens in its own window", win is not None and bool(win._shown))
st = ns.DungeonPickupArrowStep()
check("the arrow follows its first step", st is not None and "Close By" in str(st.arrowLabel) and st.spot.x == 51,
      st and st.arrowLabel)
rows = [f for f in win._children.values() if f.step is not None and f._shown]
check("its steps are listed", len(rows) >= 5, len(rows))
first = next((f for f in rows if f.step.name == "Close By"), None)
check("...the current one marked", first is not None and first.sel._shown, first and first.sel._shown)
# take it: on to the next
L.eval("function(ns) table.insert(ns.openQuests, { id = 120, title = 'Close By', complete = false }) end")(ns)
st = ns.DungeonPickupArrowStep()
check("picking it up moves it on", st is not None and "Close By" not in str(st.arrowLabel), st and st.arrowLabel)
# right-click a step: skipped
nxt = next(f for f in rows if f.step.name == "Errand" and f.step.t == "A")
nxt._scripts.OnClick(nxt, "RightButton")
st = ns.DungeonPickupArrowStep()
check("right-click skips a step", st is not None and not ("Accept: Errand" in str(st.arrowLabel)), st and st.arrowLabel)
nxt._scripts.OnClick(nxt, "RightButton")
st = ns.DungeonPickupArrowStep()
check("...and again brings it back", st is not None and "Errand" in str(st.arrowLabel), st and st.arrowLabel)
# click one further on: the arrow goes there until it's done
deep = next(f for f in rows if f.step.name == "Deep Trouble")
deep._scripts.OnClick(deep, "LeftButton")
st = ns.DungeonPickupArrowStep()
check("clicking a step sends the arrow there", st is not None and "Deep Trouble" in str(st.arrowLabel), st and st.arrowLabel)
ns.CloseDungeonPickup()
check("closed: the arrow goes back to the route", ns.DungeonPickupArrowStep() is None)
saved_after = L.eval("function(ns) local g = ns.cdb.guide and ns.cdb.guide.horde return g and g.pos end")(ns)
check("your place in the levelling guide didn't move", saved_before == saved_after, (saved_before, saved_after))

# 3. everything picked up: only the entrance left, then there
L.eval("""function(ns)
    for _, id in ipairs({ 101, 102 }) do W.done[id] = true end
    for _, id in ipairs({ 110, 120 }) do table.insert(ns.openQuests, { id = id, complete = false }) end
end""")(ns)
ns.OpenDungeonPickup("wc")
st = ns.DungeonPickupArrowStep()
check("all picked up: the arrow goes to the entrance", st is not None and st.spot.x == 46 and st.dungeonName == "Wailing Caverns",
      st and (st.arrowLabel, st.spot.x))
L.execute("W.px, W.py = 461, 366")
check("at the entrance: done, the arrow's the route's again", ns.DungeonPickupArrowStep() is None)

# 4. /hb pickup, and opening after a /reload
ns.CloseDungeonPickup()
ns.DungeonPickupCommand("wail")
check("/hb pickup wail opens Wailing Caverns", bool(win._shown) and ns.cdb.pickup.key == "wc")
check("...and it's remembered as open, for after a /reload", ns.cdb.pickup.open is True)
ns.CloseDungeonPickup()
check("closing forgets that", ns.cdb.pickup.open is None)
errs = [str(e)[:200] for e in list(G.MOCK.errors.values())]
check("no errors", not errs, errs[:3])

print()
print("ALL PASS" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
