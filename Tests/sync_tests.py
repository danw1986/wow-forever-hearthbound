# Party guide sync (GuideSync.lua), outside the game: two players' guides in
# the fake WoW (harness.lua), each on the real route, passing their addon
# messages to each other. The leader is offered a sync when the member is
# steps away, the member is asked and goes to the leader's step (or stays),
# "follow without asking" moves them straight away (only for the real leader),
# different route versions meet on the same quest, and turning sync off or
# leaving the party forgets each other.  Run: python Tests/sync_tests.py
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__)).replace(os.sep, "/") + "/"
ADDON = HERE + "../"
fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


class Player:
    def __init__(self, name, race, raceId, level, names, leads):
        L = LuaRuntime(unpack_returned_tuples=True)
        L.execute(open(HERE + "harness.lua", encoding="utf-8").read())
        W = L.globals().W
        W.race, W.raceFile, W.raceId, W.level = race, race, raceId, level
        ns = L.globals().HARNESS_NS
        ns.db.guideEdition = "horde"
        ns.version = "0.9.6"
        W.load(ADDON + "GuideData.lua")
        W.load(ADDON + "Guide.lua")
        for fn in ns.inits.values():
            fn()
        W.fire("PLAYER_LOGIN")
        W.runTimers()
        W.fire("QUEST_LOG_UPDATE")
        W.runTimers()
        W.tick()
        # the party: who's in it and who leads, addon messages, pop-ups
        W.names = L.table_from(names)
        W.leads = L.table_from(leads)
        W.inGroup = True
        L.execute("""
            W.sent, W.popups = {}, {}
            local G = HARNESS_G
            G.C_ChatInfo = { SendAddonMessage = function(_, m) table.insert(W.sent, m) return true end,
                             RegisterAddonMessagePrefix = function() return true end }
            G.IsInRaid = function() return false end
            G.UnitIsGroupLeader = function(u) return W.leads[u] == true end
            G.UnitName = function(u) return W.names[u] end
            G.UnitExists = function(u) return W.names[u] ~= nil end
            G.StaticPopupDialogs = {}
            G.StaticPopup_Show = function(which, text, _, data) table.insert(W.popups, { which = which, text = text, data = data }) end
        """)
        W.load(ADDON + "GuideSync.lua")
        L.execute("HARNESS_NS.inits[#HARNESS_NS.inits]()")
        self.L, self.W, self.ns, self.name = L, W, ns, name

    def sent(self):
        out = list(self.W.sent.values())
        self.L.execute("W.sent = {}")
        return out

    def popups(self, which):
        return [p for p in self.W.popups.values() if p.which == which]

    def clear_popups(self):
        self.L.execute("W.popups = {}")

    def printed(self):
        return [str(m) for m in self.ns.printed.values()]

    def step(self):
        s, j, n = self.ns.GuideCurrent()
        return j, s.i, s.t, s.q, s.section

    def index_of_section(self, name, offset=0):
        lst = self.ns._dbg.list()
        for k in range(1, len(lst) + 1):
            if lst[k].section == name:
                return k + offset
        return None

    def answer(self, yes):
        p = self.popups("HEARTHBOUND_GUIDE_SYNC")[-1]
        d = self.L.globals().HARNESS_G.StaticPopupDialogs["HEARTHBOUND_GUIDE_SYNC"]
        if yes:
            d.OnAccept(None, p.data)
        else:
            d.OnCancel(None, p.data, "clicked")


def pump(players):
    """deliver every addon message to everyone in the party (the sender too, as the game echoes it)"""
    for _ in range(12):
        for p in players:  # what's due first: the hellos and updates wait a moment
            p.W.runTimers()
        moved = False
        for p in players:
            for m in p.sent():
                moved = True
                for q in players:
                    q.W.fire("CHAT_MSG_ADDON", "Hearthbound", m, "PARTY", p.name + "-Forever")
        if not moved:
            return


lead = Player("Leadra", "Orc", 2, 14, {"player": "Leadra", "party1": "Memba"}, {"player": True})
mem = Player("Memba", "Troll", 8, 14, {"player": "Memba", "party1": "Leadra"}, {"party1": True})
party = [lead, mem]

SILVERPINE = "Silverpine Forest (12-15)"
j = lead.index_of_section(SILVERPINE, 6)
check("the leader has the Silverpine section", j is not None)
lead.ns.GuideSyncGo(j)
before = mem.step()
check("they start on different steps", lead.step()[1] != before[1], (lead.step(), before))

# 1. joining up: each says where they are; the leader is offered a sync
for p in party:
    p.W.fire("GROUP_ROSTER_UPDATE")
pump(party)
check("the leader sees the member is steps away", lead.ns.GuideSyncCan() == "apart", lead.ns.GuideSyncCan())
check("the member gets no Sync button (not leading)", mem.ns.GuideSyncCan() is None, mem.ns.GuideSyncCan())
offers = lead.popups("HEARTHBOUND_GUIDE_SYNC_OFFER")
check("the leader is offered a sync, naming the member", len(offers) == 1 and "Memba" in offers[0].text,
      [o.text for o in offers])
check("the member isn't offered one", not mem.popups("HEARTHBOUND_GUIDE_SYNC_OFFER"))
for p in party:
    p.W.fire("GROUP_ROSTER_UPDATE")
pump(party)
check("the offer comes once per member", len(lead.popups("HEARTHBOUND_GUIDE_SYNC_OFFER")) == 1)

# 2. the leader syncs: the member is asked, and nothing moves until they answer
lead.ns.GuideSyncParty()
pump(party)
asks = mem.popups("HEARTHBOUND_GUIDE_SYNC")
check("the member is asked", len(asks) == 1, len(asks))
check("...saying who asks and that they lead", asks and "Leadra (party leader)" in asks[0].text, asks and asks[0].text)
check("...naming the step", asks and lead.ns.GuideStepTitle(lead.ns.GuideCurrent()[0]) in asks[0].text,
      (asks and asks[0].text, lead.ns.GuideStepTitle(lead.ns.GuideCurrent()[0])))
check("the member hasn't moved yet", mem.step() == before, (mem.step(), before))
check("the leader isn't asked by their own sync", not lead.popups("HEARTHBOUND_GUIDE_SYNC"))

# 3. yes: the member is on the leader's step, and the leader hears so
mem.answer(True)
pump(party)
check("the member is on the leader's step", mem.step()[1] == lead.step()[1] and mem.step()[4] == SILVERPINE,
      (mem.step(), lead.step()))
check("the leader is told", any("Memba is on your step" in m for m in lead.printed()), lead.printed()[-3:])
check("the leader's button goes quiet: everyone's together", lead.ns.GuideSyncCan() == "together", lead.ns.GuideSyncCan())
for _ in range(5):
    mem.W.tick()
pump(party)
check("the member stays there as the guide ticks on", mem.step()[4] == SILVERPINE, mem.step())

# 4. no: the member stays put, and the leader hears so
mem.clear_popups()
lead.ns.GuideSyncGo(lead.step()[0] + 12)
pump(party)
was = mem.step()
lead.ns.GuideSyncParty()
pump(party)
mem.answer(False)
pump(party)
check("saying no leaves the member where they were", mem.step() == was, (mem.step(), was))
check("the leader hears they're staying", any("Memba is staying" in m for m in lead.printed()), lead.printed()[-3:])

# 5. follow without asking: straight there, no question
mem.ns.db.guideSyncAuto = True
mem.clear_popups()
lead.ns.GuideSyncParty()
pump(party)
check("following without asking: moved", mem.step()[1] == lead.step()[1], (mem.step(), lead.step()))
check("...and not asked", not mem.popups("HEARTHBOUND_GUIDE_SYNC"))

# 6. ...but only for the party leader: anyone else still has to ask
mem.W.leads = mem.L.table_from({})
lead.ns.GuideSyncGo(lead.step()[0] + 5)
was = mem.step()
lead.ns.GuideSyncParty()
pump(party)
check("a sync from someone who isn't leading is asked about", len(mem.popups("HEARTHBOUND_GUIDE_SYNC")) == 1
      and "party leader" not in mem.popups("HEARTHBOUND_GUIDE_SYNC")[0].text)
check("...and doesn't move the member by itself", mem.step() == was, (mem.step(), was))
mem.W.leads = mem.L.table_from({"party1": True})
mem.ns.db.guideSyncAuto = False
mem.clear_popups()

# 7. a different version of the route: the same quest step, or "missing"
st = mem.ns._dbg.state()
real_sig = st.routeSignature
st.routeSignature = "older"
lst = lead.ns._dbg.list()
k = next(k for k in range(lead.step()[0], len(lst) + 1) if lst[k].q and lst[k].t in ("A", "T", "C"))
lead.ns.GuideSyncGo(k)
pump(party)
lead.ns.GuideSyncParty()
pump(party)
mem.answer(True)
pump(party)
ls, ms = lead.step(), mem.step()
check("another route version: the member goes to the same quest step", (ms[2], ms[3]) == (ls[2], ls[3]), (ms, ls))
lst = lead.ns._dbg.list()
k = next((k for k in range(lead.step()[0], len(lst) + 1) if not lst[k].q and lst[k].t not in ("A", "T", "C")), None)
if k:
    lead.ns.GuideSyncGo(k)
    if not lead.step()[3]:
        mem.clear_popups()
        lead.ns.GuideSyncParty()
        pump(party)
        check("a step the other version can't find: not asked", not mem.popups("HEARTHBOUND_GUIDE_SYNC"))
        check("...and the leader is told to update", any("doesn't have this step" in m for m in lead.printed()),
              lead.printed()[-3:])
st.routeSignature = real_sig

# 8. turning sync off: the party forgets you
mem.ns.db.guideSync = False
for fn in mem.ns.refreshers.values():
    fn()
pump(party)
check("sync off: the leader has nobody to sync", lead.ns.GuideSyncCan() is None, lead.ns.GuideSyncCan())
mem.ns.db.guideSync = True
for fn in mem.ns.refreshers.values():
    fn()
pump(party)
check("back on: the leader sees them again", lead.ns.GuideSyncCan() is not None, lead.ns.GuideSyncCan())

# 9. leaving the party
lead.W.inGroup = False
lead.W.fire("GROUP_ROSTER_UPDATE")
pump(party)
check("out of the party: no Sync button", lead.ns.GuideSyncCan() is None)
lead.ns.GuideSyncParty()
check("...and syncing says why not", "not in a party" in lead.printed()[-1], lead.printed()[-1])

print()
print("ALL PASS" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
