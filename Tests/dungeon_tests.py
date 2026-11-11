# Dungeons in the levelling guide and the dungeon journal, outside the game.
#  1. The guide (harness.lua, the real route): a made-up dungeon's quests from a
#     fake QuestieDB become pick-ups on the way, a run at the entrance and
#     hand-ins after; what can't be done is left out; going in and coming out
#     ticks the run; leaving the dungeon out (or all dungeons) works.
#  2. The journal (wowmock.lua, the whole addon): a dungeon's quests come from
#     QuestieDB first, with their givers and what has to come first.
# Run: python Tests/dungeon_tests.py
import json
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
fails = []
DB = json.load(open(HERE + "questiedb.json"))["Quest"]
QL = {int(k): v["questLevel"] for k, v in DB.items() if v.get("questLevel")}
RL = {int(k): v["requiredLevel"] for k, v in DB.items() if v.get("requiredLevel")}


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


# The fake dungeon: "Wailing Caverns" in the Barrens (harness maps are area IDs:
# 17 = The Barrens; one percent of a map = 60 yards). Its entrance is at 46, 36.5.
FAKE = """
local B = 17
local function at(x, y, who) return { giver = who, mapID = B, x = x, y = y, kind = "npc" } end
W.dq = {
    -- picked up near the entrance, done inside, handed in there
    [990001] = { title = "Deviate Hides", level = 17, requiredLevel = 13, start = at(46, 35.7, "Nalpak"),
                 finish = at(46, 35.7, "Nalpak") },
    -- picked up in Ratchet, on the route
    [990002] = { title = "Trouble at the Docks", level = 18, requiredLevel = 14, start = at(63.1, 37.6, "Bigglefuzz"),
                 finish = at(63.1, 37.6, "Bigglefuzz") },
    -- go and see someone, then the quest it leads to
    [990003] = { title = "A Lead-in", level = 16, requiredLevel = 12, start = at(52.2, 31.9, "Tonga"),
                 finish = at(45.5, 35.2, "Ebru"), talkOnly = true },
    [990004] = { title = "The Follow-up", level = 18, requiredLevel = 13, start = at(45.5, 35.2, "Ebru"),
                 finish = at(45.5, 35.2, "Ebru"), preSingle = { 990003 } },
    -- a giver far off the route: left out, said on the run
    [990005] = { title = "Far Away Errand", level = 18, requiredLevel = 13, start = { giver = "Zamah", mapID = 1456, x = 5, y = 95 },
                 finish = { giver = "Zamah", mapID = 1456, x = 5, y = 95 } },
    -- needs a quest you'll never have
    [990006] = { title = "Needs Something Else", level = 18, requiredLevel = 13, start = at(46, 36, "Someone"),
                 finish = at(46, 36, "Someone"), preSingle = { 12345 } },
    -- starts from an item inside
    [990007] = { title = "The Glowing Shard", level = 18, requiredLevel = 13, startItem = "Glowing Shard",
                 finish = at(48, 32.8, "Hamuul") },
    -- not for you
    [990008] = { title = "Alliance Only", level = 18, requiredLevel = 13, start = at(46, 36, "Someone"),
                 finish = at(46, 36, "Someone"), notYours = true },
}
HARNESS_NS.DUNGEONS = { { key = "wc", name = "Wailing Caverns", min = 17, max = 24, zone = "The Barrens" },
                        { key = "dm", name = "The Deadmines", min = 17, max = 26, zone = "Westfall", faction = "A" } }
HARNESS_NS.PlayerFaction = function() return "H" end
HARNESS_NS.DungeonInfo = function(key) for _, d in ipairs(HARNESS_NS.DUNGEONS) do if d.key == key then return d end end end
HARNESS_NS.QuestieEntrance = function(key) if key == "wc" then return { mapID = B, x = 46, y = 36.5 } end end
HARNESS_NS.QuestieDungeonQuestIds = function(key)
    if W.dungeonsLoading then return nil end
    if key ~= "wc" then return {} end
    local ids = {}
    for id in pairs(W.dq) do ids[#ids + 1] = id end
    table.sort(ids)
    return ids
end
HARNESS_NS.QuestieQuestInfo = function(id)
    local q = W.dq[id]
    if not q then return nil end
    local info = { id = id, preSingle = q.preSingle or {}, preGroup = {} }
    for k, v in pairs(q) do if info[k] == nil then info[k] = v end end
    return info
end
HARNESS_NS.QuestieFitsYou = function(id) local q = W.dq[id] return not (q and q.notYours) end
HARNESS_NS.QuestieQuestGivers = function(onReady) W.giversWaiter = onReady return nil end
W.instance = nil
HARNESS_G.IsInInstance = function() if W.instance then return true, "party" end return false end
HARNESS_G.GetInstanceInfo = function() return W.instance end
"""


def fresh(level=18, setup=""):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(HERE + "harness.lua", encoding="utf-8").read())
    W = L.globals().W
    W.race, W.raceFile, W.raceId, W.classFile, W.classId, W.level = "Orc", "Orc", 2, "WARRIOR", 1, level
    W.questLevels = L.table_from(QL)
    W.requiredLevels = L.table_from(RL)
    ns = L.globals().HARNESS_NS
    ns.db.guideEdition = "horde"
    L.execute(FAKE)
    if setup:
        L.execute(setup)
    W.load(ADDON + "GuideData.lua")
    W.load(ADDON + "Guide.lua")
    for fn in ns.inits.values():
        fn()
    W.fire("PLAYER_LOGIN")
    W.runTimers()
    W.fire("QUEST_LOG_UPDATE")
    W.runTimers()
    W.tick()
    return L, W, ns


def steps(ns):
    lst = ns._dbg.list()
    return lst, [k for k in range(1, len(lst) + 1) if lst[k].dungeon]


def find(lst, **want):
    return next((k for k in range(1, len(lst) + 1) if all(getattr(lst[k], f) == v for f, v in want.items())), None)


# ---------------------------------------------------------------- 1. the guide
L, W, ns = fresh()
lst, dun = steps(ns)
run = find(lst, t="D", dungeon="wc")
check("the dungeon is in the route with a run step", run is not None, len(dun))
r = lst[run] if run else None
check("...named, at the entrance", r is not None and r.dungeonName == "Wailing Caverns" and r.x == 46 and r.y == 36.5)
K = ns._dbg.k()
check("...with a step number that keeps across rebuilds", r is not None and r.i == 3000000 + K.KeyNumber("wc"))
lvl = ns._dbg.routeLevel(run) if run else None
check("...run when the route is about the dungeon's level", lvl is not None and 15 <= lvl <= 22, lvl)
check("the other faction's dungeon isn't", find(lst, dungeon="dm") is None)


def a(q): return find(lst, t="A", q=q, dungeon="wc")
def t(q): return find(lst, t="T", q=q, dungeon="wc")


check("pick-ups come before the run", all(a(q) and a(q) < run for q in (990001, 990002, 990004)),
      [(q, a(q)) for q in (990001, 990002, 990004)])
check("hand-ins come after it", all(t(q) and t(q) > run for q in (990001, 990002, 990004, 990007)),
      [(q, t(q)) for q in (990001, 990002, 990004, 990007)])
check("a pick-up step says who and which dungeon", "for Wailing Caverns" in (lst[a(990001)].note or ""), lst[a(990001)].note)
check("pick-up steps keep their numbers", lst[a(990001)].i == 2000000 + 990001 * 4 and lst[t(990001)].i == 2000000 + 990001 * 4 + 2)
lead_a, lead_t, follow_a = a(990003), t(990003), a(990004)
check("a lead-in quest: picked up, handed in, then the quest it leads to",
      lead_a and lead_t and follow_a and lead_a < lead_t < follow_a < run, (lead_a, lead_t, follow_a, run))
check("a giver far off the route: no pick-up step", a(990005) is None)
check("...but the run says it's there", "Far Away Errand" in (r.note or ""), r.note)
check("a quest needing one you'll never have: left out", a(990006) is None and t(990006) is None)
check("a quest for the other side: left out", a(990008) is None)
check("one that starts from an item inside: no pick-up, said on the run",
      a(990007) is None and "The Glowing Shard" in (r.note or "") and "Glowing Shard" in (r.note or ""))
check("the run counts the quests you'd do", "4 quests" in (r.text or "") or "5 quests" in (r.text or ""), r.text)
check("the journal can say where it's run", K.dungeonRuns.wc is not None and K.dungeonRuns.wc.level == r.level)

# its card: the quests you have for it, and what's left
W.log[990001] = "open"
W.objs = L.table()
L.execute("""HARNESS_G.C_QuestLog.GetQuestObjectives = function(q)
    if q == 990001 then return { { text = "Deviate Hide: 3/20", finished = false } } end
end""")
W.tick()
d = ns._dbg.details(r) or ""
check("the run's card lists its quests in your log, with what's left", "Q990001" in d and "Deviate Hide: 3/20" in d, d)

# going in and coming out
ns._dbg.state().pos = r.i
W.instance = "Wailing Caverns"
W.tick()
ns._dbg.evaluate()
st = ns._dbg.state()
check("going in counts it as run", st.ran is not None and st.ran[r.i] is True)
check("...and its pick-ups are too late now", ns._dbg.passed(a(990002)))
check("...but the run stays up while you're inside", not st.done[r.i])
W.instance = None
ns._dbg.evaluate()
check("coming out ticks it off", st.done[r.i] is True)
check("...and its hand-ins are next for the quests you have", not ns._dbg.passed(t(990001)))

# passing the run by without going in
L, W, ns = fresh()
lst, dun = steps(ns)
run = find(lst, t="D", dungeon="wc")
r = lst[run]
W.log[990001] = "open"
W.tick()
check("with a quest for it in your log, the run waits for you", not ns._dbg.passed(run))
ns.GuideSkipStep(r, True)
check("skip the run: its unfinished hand-ins don't hold you up", ns._dbg.passed(t(990001)))
W.log[990002] = "complete"
W.tick()
check("...but a finished one still gets handed in", not ns._dbg.passed(t(990002)))

# none of its quests picked up: the run passes by itself
L, W, ns = fresh()
lst, dun = steps(ns)
run = find(lst, t="D", dungeon="wc")
check("none of its quests taken: no need to run it", ns._dbg.passed(run))

# leaving it out, and putting it back
L, W, ns = fresh()
lst, dun = steps(ns)
run = find(lst, t="D", dungeon="wc")
W.log[990002] = "open"
W.tick()
ns.GuideSetDungeon("wc", False)
lst = ns._dbg.list()
check("left out: its run passes", ns._dbg.passed(find(lst, t="D", dungeon="wc")))
check("...and its pick-ups", ns._dbg.passed(find(lst, t="A", q=990001)))
check("...but a quest of it in your log still gets handed in", not ns._dbg.passed(find(lst, t="T", q=990002)))
check("...on this character", ns.cdb.guideDungeonsOff.wc is True)
ns.GuideSetDungeon("wc", True)
lst = ns._dbg.list()
check("put back: its pick-ups are back", not ns._dbg.passed(find(lst, t="A", q=990001)))

# a dungeon left out at login isn't built in at all
L, W, ns = fresh(setup="HARNESS_NS.cdb.guideDungeonsOff = { wc = true }")
lst, dun = steps(ns)
check("left out before login: no steps for it", len(dun) == 0, len(dun))

# all dungeons off in Settings
L, W, ns = fresh()
ns.db.guideSkipDungeons = True
for fn in ns.refreshers.values():
    fn()
lst, dun = steps(ns)
check("Skip dungeons: the route is built without them", len(dun) == 0, len(dun))
ns.db.guideSkipDungeons = False
for fn in ns.refreshers.values():
    fn()
lst, dun = steps(ns)
check("...and back with them when it's turned off", len(dun) > 0)

# Questie still reading its dungeon lists at login: built in when it's done
L, W, ns = fresh(setup="W.dungeonsLoading = true")
lst, dun = steps(ns)
check("Questie not ready: no dungeon steps yet", len(dun) == 0)
check("...and the guide waits for it", W.giversWaiter is not None)
W.dungeonsLoading = False
W.giversWaiter()
W.runTimers()
lst, dun = steps(ns)
check("...then builds them in", find(lst, t="D", dungeon="wc") is not None)

# your place on a dungeon step that's gone at the next rebuild (you did the
# quest, say): the place stays where it was - not back at the start, or at
# some quest you can hand in at any level far down the route
L, W, ns = fresh()
lst, dun = steps(ns)
k = find(lst, t="A", q=990001)
st = ns._dbg.state()
st.pos, st.hold, st.force = lst[k].i, False, None
W.tick()
check("your place on a dungeon pick-up", ns._dbg.state().pos == lst[k].i, (ns._dbg.state().pos, lst[k].i))
W.dq[990001].notYours = True
ns._dbg.k().Rebuild()
W.tick()
lst2 = ns._dbg.list()
by2 = {lst2[n].i: n for n in range(1, len(lst2) + 1)}
now = by2.get(ns._dbg.state().pos)
check("...gone at the next rebuild: your place is the step after it", now is not None and k - 2 <= now <= k + 3,
      (now, k, ns._dbg.state().pos))

# logging in with your place on a dungeon step, before Questie has its dungeon
# lists: the guide waits at the route step after it, then goes back to it
L, W, ns = fresh()
lst, dun = steps(ns)
k = find(lst, t="A", q=990001)
st = ns._dbg.state()
st.pos, st.hold, st.force = lst[k].i, False, None
W.tick()
saved = {f: st[f] for f in ("pos", "after", "routeSignature")}
check("...the route step after your place is kept with it", saved["after"] is not None and saved["after"] < 1000000, saved)
L, W, ns = fresh(setup=f"""W.dungeonsLoading = true
HARNESS_NS.cdb.guide = {{ horde = {{ done = {{}}, pos = {saved['pos']}, after = {saved['after']}, routeSignature = "{saved['routeSignature']}" }} }}""")
lst, dun = steps(ns)
by = {lst[n].i: n for n in range(1, len(lst) + 1)}
check("logged in before the dungeon lists: waiting at the route step after your place",
      ns._dbg.state().pos == saved["after"] or (by.get(ns._dbg.state().pos) or 0) >= by.get(saved["after"], 10 ** 9),
      (ns._dbg.state().pos, saved))
check("...not sent back to the start", (by.get(ns._dbg.state().pos) or 0) > 100, by.get(ns._dbg.state().pos))
W.dungeonsLoading = False
W.giversWaiter()
W.runTimers()
W.tick()
check("...and back on the dungeon pick-up once they're in", ns._dbg.state().pos == saved["pos"], (ns._dbg.state().pos, saved))

# the menu on a dungeon step
L, W, ns = fresh()
lst, dun = steps(ns)
L.execute("HARNESS_NS.GuideMenu = function(title, items) MENU = items end")
ns.GuideStepMenu(None, lst[find(lst, t="D", dungeon="wc")])
labels = [L.globals().MENU[k][1] for k in range(1, len(L.globals().MENU) + 1)]
check("right-click a dungeon step: leave the dungeon out", "Leave Wailing Caverns out of the guide" in labels, labels)

# ---------------------------------------------------------------- 2. the journal
FILES = [l.strip() for l in open(ADDON + "Hearthbound.toc", encoding="utf-8") if l.strip() and not l.startswith("#")]
J = LuaRuntime(unpack_returned_tuples=True)
J.execute(open(HERE + "wowmock.lua", encoding="utf-8").read())
J.execute("""UnitFactionGroup = function() return "Horde", "Horde" end
UnitRace = function() return "Orc", "Orc", 2 end""")
jns = J.table()
load = J.eval("""function(src, name, ns)
    local fn, err = load(src, "@" .. name)
    if not fn then return false, err end
    local ok, e = pcall(fn, "Hearthbound", ns)
    return ok, tostring(e)
end""")
errors = []
for f in FILES:
    ok, err = load(open(ADDON + f, encoding="utf-8").read(), f, jns)
    if not ok:
        errors.append(f"{f}: {err}")
check("the addon loads", not errors, errors)
fire = J.eval("""function(event, ...)
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
J.globals().MOCK.RunTimers()
J.eval("""function(ns)
    local function at(x, y, who) return { giver = who, mapID = 1413, x = x, y = y, kind = "npc" } end
    local Q = {
        [1486] = { title = "Deviate Hides", level = 17, start = at(46, 35.7, "Nalpak"), preSingle = {}, preGroup = {} },
        [1490] = { title = "Nara Wildmane", level = 16, start = { giver = "Arch Druid Hamuul", mapID = 1456, x = 78.6, y = 28.6 },
                   preSingle = { 1489 }, preGroup = {} },
        [6981] = { title = "The Glowing Shard", level = 26, startItem = "Glowing Shard", preSingle = {}, preGroup = {} },
        [7000] = { title = "Wrong Side", level = 18, start = at(1, 1, "Nobody"), preSingle = {}, preGroup = {} },
    }
    ns.QuestieDungeonQuestIds = function(key) if key == "wc" then return { 1486, 1490, 6981, 7000 } end return {} end
    ns.QuestieQuestInfo = function(id) local q = Q[id] if q then q.id = id end return q end
    ns.QuestieFitsYou = function(id) return id ~= 7000 end
    ns.QuestieQuestName = function(id)
        return (id == 1489 and "Hamuul Runetotem") or (id == 1488 and "Hamuul's Errand") or nil
    end
    -- the quest before is the end of a chain: its first part, and who gives it
    ns.QuestieChainStart = function(id) return id == 1490 and 1488 or nil end
    ns.QuestieGiverById = function(id)
        if id == 1488 then return { giver = "Arch Druid Hamuul", mapID = 1456, x = 78.6, y = 28.6 } end
    end
    ns.QuestDone = function() return false end
    ns.ClearJournalQuestCache()
end""")(jns)
quests = jns.DungeonQuestList("wc")[0]
titles = [quests[k].title for k in range(1, len(quests) + 1)]
check("the journal lists the dungeon's quests from QuestieDB", "Deviate Hides" in titles and "Nara Wildmane" in titles, titles)
check("...not ones that aren't for you", "Wrong Side" not in titles, titles)
check("...and no title twice (the published list fills gaps only)", len(titles) == len(set(t.lower() for t in titles)), titles)
by = {quests[k].title: quests[k] for k in range(1, len(quests) + 1)}
hides = by.get("Deviate Hides")
check("...with the giver and where", hides is not None and hides.giver == "Nalpak" and hides.mapID == 1413 and hides.x == 46)
shard = by.get("The Glowing Shard")
check("...and that one starts from an item inside", shard is not None and shard.inside and "Glowing Shard" in shard.giver)
nara = by.get("Nara Wildmane")
check("...and what has to come first", nara is not None and nara.pre is not None and nara.pre[1] == 1489)
# a new dungeon whose quests QuestieDB doesn't file under it (no zone): the
# dungeon lists their IDs, and the published list fills in who and where
J.eval("""function(ns)
    local Q = {
        [94968] = { title = "Eye of Mugg", level = 45, start = { giver = "Krom'rosh", mapID = 2000, x = 59.4, y = 45.5 },
                    preSingle = {}, preGroup = {} },
        [94982] = { title = "Eye of Mugg", level = 45, preSingle = {}, preGroup = {} },             -- the Alliance's
        [94975] = { title = "A Token of Vengeance", level = 42, start = { giver = "Da'grosh" },     -- no spawn known
                    preSingle = {}, preGroup = {} },
        [94983] = { title = "Twilight Mementos", level = 42, preSingle = {}, preGroup = {} },       -- Alliance only
    }
    local old = ns.QuestieQuestInfo
    ns.QuestieQuestInfo = function(id) local q = Q[id] if q then q.id = id return q end return old(id) end
    ns.QuestieFitsYou = function(id) return id ~= 7000 and id ~= 94982 and id ~= 94983 end
    ns.ClearJournalQuestCache()
end""")(jns)
kq = jns.DungeonQuestList("kroldok")[0]
kby = {}
for k in range(1, len(kq) + 1):
    kby.setdefault(kq[k].title, []).append(kq[k])
mugg = kby.get("Eye of Mugg", [])
check("a new dungeon's quests with no zone are listed (from its quest IDs)", len(mugg) == 1 and mugg[0].questieId == 94968,
      list(kby))
check("...with QuestieDB's giver, not the other side's", mugg and mugg[0].giver == "Krom'rosh" and mugg[0].mapID == 2000,
      mugg and (mugg[0].giver, mugg[0].mapID))
check("...and the published reward", mugg and "Rock on Stick" in (mugg[0].reward or ""), mugg and mugg[0].reward)
token = kby.get("A Token of Vengeance", [None])[0]
check("a giver QuestieDB can't place gets the published place, not 'inside'",
      token is not None and token.giver == "Da'grosh" and not token.inside and token.zone == "Riverglades" and token.x == 33.4,
      token and (token.giver, token.inside, token.zone, token.x))
check("the other side's quests aren't listed", "Twilight Mementos" not in kby and "Ashe Amberhall" not in
      [q.giver for qs in kby.values() for q in qs], list(kby))
check("...and published ones QuestieDB hasn't got are", "Krol'dok Moulding" in kby and "Key Ingredients" in kby, list(kby))
keys = kby.get("Key Ingredients", [])
check("...for your side only", len(keys) == 1 and keys[0].giver == "Kreza Darkthorn", [(q.giver) for q in keys])

# the dungeon's page draws, with the guide line and the quests to pick up
J.globals().UnitLevel = J.eval("function() return 18 end")
page = J.eval("""function(ns)
    local ok, err = pcall(ns.ShowDungeon, "wc")
    MOCK.RunTimers()
    local texts = {}
    for _, o in ipairs(MOCK.frames) do
        if o:IsVisible() ~= false and type(o._text) == "string" then texts[#texts + 1] = o._text end
    end
    return ok, tostring(err), table.concat(texts, " | ")
end""")
ok, err, text = page(jns)
check("the dungeon page opens", ok, err)
check("...saying whether the levelling guide runs it", "Levelling guide:" in text, text[:400])
check("...and listing what to pick up, with its giver", "Deviate Hides" in text and "Nalpak" in text)
# its Quests tab: each quest in full
qtext = J.eval("""function(ns)
    for _, item in ipairs(ns.JournalMenu()) do
        if item.label == "Quests" and item.onClick then item.onClick() end
    end
    MOCK.RunTimers()
    local texts = {}
    for _, o in ipairs(MOCK.frames) do
        if o:IsVisible() ~= false and type(o._text) == "string" then texts[#texts + 1] = o._text end
    end
    return table.concat(texts, " | ")
end""")(jns)
text = qtext
check("...a quest with something to do first says so", "Do first: Hamuul Runetotem" in text, text[:600])
check("...and where the chain starts, when it's longer", "Start with Hamuul's Errand, from Arch Druid Hamuul" in text and "78.6, 28.6" in text,
      text[text.find("Do first"):text.find("Do first") + 200])
errs = [str(e)[:200] for e in list(J.globals().MOCK.errors.values())]
check("...with no errors", not errs, errs[:3])

print("ALL PASSED" if not fails else "FAILED: " + str(fails))
sys.exit(1 if fails else 0)
