# GuideLearn.lua in the fake WoW: offers, prerequisites, XP and levels get written down.
# Run: python Tests/learn_tests.py
import os
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "  " + str(info)))
    if not cond:
        fails.append(name)


L = LuaRuntime(unpack_returned_tuples=True)
L.execute(open(HERE + "harness.lua", encoding="utf-8").read())
W = L.globals().W
L.execute('''
local G = HARNESS_G
W.xp, W.xpMax, W.gossip, W.npc = 0, 400, {}, "Creature-0-3110-0-8-2981-000044AB2C"
G.UnitXP = function() return W.xp end
G.UnitXPMax = function() return W.xpMax end
G.UnitName = function() return "Tester" end
G.GetRealmName = function() return "Realm" end
G.UnitGUID = function() return W.npc end
G.C_GossipInfo = { GetAvailableQuests = function() return W.gossip end }
G.GetQuestID = function() return W.detail end
G.C_Map = { GetBestMapForUnit = function() return 1412 end, GetPlayerMapPosition = function() return nil end }
''')
ns = L.globals().HARNESS_NS
ns.db.guideLearn = True
W.load(ADDON + "GuideLearn.lua")
for fn in ns.inits.values():
    fn()
W.fire("PLAYER_ENTERING_WORLD")

# Chief Hawkwind offers A Humble Task (752); you take it, hand it in, then 753 appears
W.gossip = L.eval("{ { questID = 752 } }")
W.fire("GOSSIP_SHOW")
W.fire("QUEST_ACCEPTED", 752)
W.time = W.time + 30
W.xp = 110
W.fire("QUEST_TURNED_IN", 752, 110, 0)
W.fire("PLAYER_XP_UPDATE")
W.npc = "Creature-0-3110-0-8-2991-000044AB2D"
W.gossip = L.eval("{ { questID = 753 } }")
W.fire("GOSSIP_SHOW")
W.xp = 150  # a kill
W.fire("PLAYER_XP_UPDATE")

learn = ns.db.learn
o752, o753 = learn.offers[752], learn.offers[753]
check("an offer is written down, with its giver", o752 is not None and o752.givers["npc:2981"] == True)
check("the next quest's offer remembers the hand-in just before it", o753 is not None and o753.after[752] == 1)
pre = list(ns.LearnedPrereqs(753).values())
check("so 752 is learned as 753's prerequisite", pre == [752], pre)
q = learn.quests[752]
check("the quest's XP and levels are kept", q is not None and q.xp == 110 and q.takenAt == 10 and q.seconds == 30, dict(q) if q else None)
lv = learn.levels["Tester-Realm"][10]
check("level 10: 110 XP from quests, 40 from the rest", lv.questXP == 110 and lv.otherXP == 40, (lv.questXP, lv.otherXP))
path = learn.path["Tester-Realm"]
check("the path has the pick-up then the hand-in", path[1].t == "A" and path[2].t == "T" and path[2].q == 752)

# a second character who never did 752 first: 752 stops being "always before"
L.execute('HARNESS_G.UnitName = function() return "Other" end')
ns.db.learn.offers[753].firstBy = L.table()  # pretend a new character sees it fresh
W.fire("GOSSIP_SHOW")
pre2 = list(ns.LearnedPrereqs(753).values())
check("seen by another character too: still 752 (it was just before both times)", pre2 == [752], pre2)

# pace: 10 minutes on the level, 150 XP so far -> 900 XP an hour
L.execute('HARNESS_G.UnitName = function() return "Tester" end')
learn.levels["Tester-Realm"][10].seconds = 600
mins, per_hour, eta = ns.LevelPace()
check("pace: 10m so far, 900 XP an hour", mins == 10 and per_hour == 900, (mins, per_hour, eta))
check("...250 XP left at 900/h is about 17 minutes", eta == 17, eta)

# the optimiser reads what was learned from the saved variables
import tempfile, subprocess, sys, json as _json
sv = os.path.join(tempfile.mkdtemp(), "Hearthbound.lua")
open(sv, "w", encoding="utf-8").write("""HearthboundDB = { learn = {
  offers = { [92532] = { afterSamples = 2, after = { [92461] = 2, [92460] = 1 }, minLevel = 2 } },
  quests = { [92461] = { xp = 170, takenAt = 1 } },
  levels = {},
} }""")
probe = "\n".join([
    "import os, sys",
    "sys.argv = [sys.argv[0], os.path.join(r'" + ADDON + "', 'Tests', 'fixtures', 'GuideData_Forever.lua'), os.devnull]",
    "src = open(r'" + HERE + "route_optimize.py', encoding='utf-8').read().split('# ---------------------------------------------------------------- run')[0]",
    "g = {'__file__': r'" + HERE + "route_optimize.py'}",
    "exec(compile(src, 'r', 'exec'), g)",
    "print(sorted(g['learned_prereqs'](92532)), g['quest_xp'](92461))",
])
env = dict(os.environ, HEARTHBOUND_SAVEDVARS=sv)
r = subprocess.run([sys.executable, "-c", probe], capture_output=True, text=True, env=env)
print("   optimiser read:", r.stdout.strip() or r.stderr.strip()[-300:])
check("the optimiser learns 92532 needs 92461 (seen before it both times; 92460 only once)", r.stdout.strip().startswith("[92461] 170"), r.stdout)

ns.LearnStatus()
print("\n".join(list(ns.printed.values())[-3:]))
print()
print("FAILED:" if fails else "ALL PASSED", fails)
