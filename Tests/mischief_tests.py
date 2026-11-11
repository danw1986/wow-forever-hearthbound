# Mischief achievements (Mischief.lua) and posting achievements to party and
# guild chat (Milestones.lua), in the fake WoW (wowmock.lua) with the whole
# addon loaded: a paladin's Blessing of Protection on a party member unlocks
# "Hands off!" and posts it to party chat naming them, casts on yourself or
# strangers don't count, rude emotes and duel wins against guildmates do, each
# switch turns its chat off, and posts wait for the end of a fight.
# Run: python Tests/mischief_tests.py
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


def login(cls="PALADIN"):
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
    L.execute("""
    W = { group = false, guild = false, combat = false, instance = false, chat = {},
          units = { player = { name = "Testchar", class = "%s" } }, guildmates = {}, fighting = {} }
    -- caught up already: unlocks pop up (and post) instead of being taken in quietly
    HearthboundCharDB = { achVersion = 99, milestonesMarked = true }
    DUEL_WINNER_KNOCKOUT = "%%1$s has defeated %%2$s in a duel"
    DUEL_WINNER_RETREAT = "%%2$s has fled from %%1$s in a duel"
    LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = 1, 2
    local SPELLS = { [1022] = "Blessing of Protection", [29166] = "Innervate", [1459] = "Arcane Intellect",
                     [1706] = "Levitate", [5246] = "Intimidating Shout", [1856] = "Vanish", [1243] = "Power Word: Fortitude" }
    GetSpellInfo = function(id) return SPELLS[id] end
    C_Spell = { GetSpellName = function(id) return SPELLS[id] end }
    C_ChatInfo = { SendChatMessage = function(msg, channel) table.insert(W.chat, channel .. ": " .. msg) end }
    IsInGroup = function(cat) return W.group and (cat == nil or cat == 1) end
    IsInRaid = function() return false end
    IsInGuild = function() return W.guild end
    InCombatLockdown = function() return W.combat end
    UnitAffectingCombat = function(u) return (u == "player" and W.combat) or W.fighting[u] == true end
    IsInInstance = function() if W.instance then return true, "party" end return false, "none" end
    UnitExists = function(u) return W.units[u] ~= nil end
    UnitName = function(u) local x = W.units[u] return x and x.name end
    UnitClass = function(u) local x = W.units[u] or W.units.player return x.class, x.class, 1 end
    UnitIsUnit = function(a, b) return a == b or (W.units[a] and W.units[a] == W.units[b]) end
    UnitIsPlayer = function(u) return W.units[u] ~= nil end
    UnitInParty = function(u) local x = W.units[u] return x and x.party == true end
    UnitInRaid = function() return nil end
    UnitIsInMyGuild = function(u) local x = W.units[u] return x and x.guild == true end
    GetNumGuildMembers = function() return #W.guildmates end
    GetGuildRosterInfo = function(i) return W.guildmates[i] end
    function DoEmote() end
    """ % cls)
    G = L.globals()
    ns = L.table()
    load = L.eval("""function(src, name, ns)
        local fn, err = load(src, "@" .. name)
        if not fn then return false, err end
        local ok, e = pcall(fn, "Hearthbound", ns)
        return ok, e
    end""")
    for f in FILES:
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
    # what this character already qualifies for unlocks now, out of a group, with guild posts off
    L.execute("MOCK.RunTimers() MOCK.RunTickers() MOCK.RunTimers() W.chat = {}")
    return L, G, ns, fire


def run(L):
    L.execute("MOCK.RunTimers()")


def chat(G):
    return [str(m) for m in G.W.chat.values()]


def clear(L):
    L.execute("W.chat = {}")


def cast(L, fire, spell, target, guid="g1"):
    fire("UNIT_SPELLCAST_SENT", "player", target or "", guid, spell)
    fire("UNIT_SPELLCAST_SUCCEEDED", "player", guid, spell)
    run(L)


def mischief(ns, kind):
    m = ns.cdb.mischief
    return (m and m[kind]) or 0


L, G, ns, fire = login("PALADIN")
L.execute("""
W.group = true
W.units.party1 = { name = "Grok", class = "WARRIOR", party = true }
W.units.party2 = { name = "Lumi", class = "PRIEST", party = true }
W.units.stranger = { name = "Nobody", class = "MAGE" }
W.combat = false
""")

# 1. Blessing of Protection on a warrior in the party, in a fight
L.execute("W.fighting.party1 = true")
cast(L, fire, 1022, "Grok")
check("BoP on a party member counts", mischief(ns, "bop") == 1, mischief(ns, "bop"))
check("...on a warrior mid-fight counts as tank-proofing", mischief(ns, "bopTank") == 1, mischief(ns, "bopTank"))
lines = chat(G)
hands = [l for l in lines if "Hands off!" in l]
check("Hands off! is posted to party chat", hands and hands[0].startswith("PARTY: [Hearthbound] Achievement: Hands off! (+"),
      lines)
check("...naming who got it", hands and "Blessing of Protection on Grok" in hands[0], hands)
check("the hidden one is posted too", any("Tank-proofed" in l and "Grok" in l for l in lines), lines)
check("nothing goes to guild chat (off by default)", not any(l.startswith("GUILD") for l in lines), lines)
L.execute("W.fighting.party1 = false")
clear(L)

# 2. what doesn't count
cast(L, fire, 1022, "Testchar", "g2")
check("BoP on yourself doesn't count", mischief(ns, "bop") == 1, mischief(ns, "bop"))
cast(L, fire, 1022, "Nobody", "g3")
check("BoP on someone outside the party doesn't count", mischief(ns, "bop") == 1, mischief(ns, "bop"))
cast(L, fire, 1243, "Grok", "g4")
check("an ordinary buff on a party member doesn't count", not ns.cdb.mischief.fortitude)
# no name to go on (cast on your target): the target is used
L.execute("W.units.target = W.units.party2")
cast(L, fire, 1022, "", "g5")
check("BoP on your party-member target counts", mischief(ns, "bop") == 2, mischief(ns, "bop"))
check("...and isn't a tank-proofing (a priest, out of a fight)", mischief(ns, "bopTank") == 1)
L.execute("W.units.target = nil")
check("an achievement already earned isn't posted again", not any("Hands off" in l for l in chat(G)), chat(G))
clear(L)

# 3. rude emotes: at a guildmate or party member, not a stranger
L.execute("W.units.target = { name = 'Brakka', class = 'ROGUE', guild = true }")
G.DoEmote("DANCE")
run(L)
check("dancing isn't rude", mischief(ns, "rude") == 0)
G.DoEmote("SLAP")
run(L)
check("/slap at a guildmate counts", mischief(ns, "rude") == 1, mischief(ns, "rude"))
check("...and Bad manners names them", any("Bad manners" in l and "Brakka" in l for l in chat(G)), chat(G))
L.execute("W.units.target = W.units.stranger")
L.execute("MOCK.time = MOCK.time + 5")
G.DoEmote("SLAP")
run(L)
check("/slap at a stranger doesn't count", mischief(ns, "rude") == 1, mischief(ns, "rude"))
L.execute("MOCK.time = MOCK.time + 5")
G.DoEmote("RUDE", "Grok")
run(L)
check("/rude Grok (a party member, by name) counts", mischief(ns, "rude") == 2, mischief(ns, "rude"))
L.execute("W.units.target = nil")
clear(L)

# 4. duels won at home
fire("CHAT_MSG_SYSTEM", "Testchar has defeated Grok in a duel")
run(L)
check("beating a party member in a duel counts", mischief(ns, "duel") == 1, mischief(ns, "duel"))
check("...and Family feud names them", any("Family feud" in l and "Grok" in l for l in chat(G)), chat(G))
L.execute("W.guild = true; W.guildmates = { 'Brakka-Forever' }")
fire("CHAT_MSG_SYSTEM", "Brakka has fled from Testchar in a duel")
run(L)
check("a guildmate fleeing a duel with you counts", mischief(ns, "duel") == 2, mischief(ns, "duel"))
fire("CHAT_MSG_SYSTEM", "Nobody has defeated Testchar in a duel")
fire("CHAT_MSG_SYSTEM", "Testchar has defeated Nobody in a duel")
run(L)
check("losing, or beating a stranger, doesn't", mischief(ns, "duel") == 2, mischief(ns, "duel"))
L.execute("W.guild = false")
clear(L)

# 5. fears in a dungeon, and running off mid-fight (counted for any class)
L.execute("W.combat = true")
cast(L, fire, 5246, "", "g6")
check("a fear outside a dungeon doesn't count", mischief(ns, "fear") == 0)
L.execute("W.instance = true")
cast(L, fire, 5246, "", "g7")
check("a fear in a dungeon fight with the party counts", mischief(ns, "fear") == 1, mischief(ns, "fear"))
cast(L, fire, 1856, "", "g8")
check("Vanish while the party isn't fighting doesn't count", mischief(ns, "bail") == 0)
L.execute("W.fighting.party2 = true")
cast(L, fire, 1856, "", "g9")
check("Vanish with the party still fighting counts", mischief(ns, "bail") == 1, mischief(ns, "bail"))
L.execute("W.combat = false; W.instance = false; W.fighting = {}")
clear(L)

# 6. the switches, and waiting out a fight
ns.db.achParty = False
ns.db.announceGuild = True
L.execute("W.guild = true")
for n in range(9):
    cast(L, fire, 1022, "Grok", "s%d" % n)
lines = chat(G)
check("party posts off: none in party chat", not any(l.startswith("PARTY") for l in lines), lines)
check("guild posts on: the 10-blessings one goes to guild chat",
      any(l.startswith("GUILD: [Hearthbound] Achievement: 10 unwanted blessings") for l in lines), lines)
clear(L)
ns.db.achParty = True
L.execute("W.combat = true")
for n in range(15):
    cast(L, fire, 1022, "Grok", "c%d" % n)
check("in a fight: nothing posted yet", not chat(G), chat(G))
L.execute("W.combat = false")
fire("PLAYER_REGEN_ENABLED")
run(L)
lines = chat(G)
check("after the fight it's posted, to party and guild", any(l.startswith("PARTY") and "25 unwanted" in l for l in lines)
      and any(l.startswith("GUILD") and "25 unwanted" in l for l in lines), lines)
clear(L)
ns.db.announceGuild = False
L.execute("W.group = false")
cast(L, fire, 1022, "Grok", "x1")
check("out of a group: no party post", not chat(G))

# 7. a paladin's Mischief page has the paladin's and everyone's, not the other classes'
menu = {str(i.label): str(i.count) for i in ns.AchievementsMenu().values() if i.label}
check("a paladin's Mischief: 4 paladin + 5 for everyone", menu.get("Mischief", "").endswith("/9"), menu.get("Mischief"))

# 8. a druid's Innervate: on a warrior yes, on a priest no
L, G, ns, fire = login("DRUID")
L.execute("""
W.group = true
W.units.party1 = { name = "Grok", class = "WARRIOR", party = true }
W.units.party2 = { name = "Lumi", class = "PRIEST", party = true }
""")
cast(L, fire, 29166, "Lumi")
check("Innervate on a priest doesn't count", mischief(ns, "innervate") == 0)
cast(L, fire, 29166, "Grok", "g2")
check("Innervate on a warrior counts", mischief(ns, "innervate") == 1)
check("...and Wasted on you is posted", any("Wasted on you" in l and "Grok" in l for l in chat(G)), chat(G))
menu = {str(i.label): str(i.count) for i in ns.AchievementsMenu().values() if i.label}
check("a druid's Mischief: 1 druid + 5 for everyone", menu.get("Mischief", "").endswith("/6"), menu.get("Mischief"))
errors = list(G.MOCK.errors.values())
check("no errors", not errors, errors[:3])

print()
print("ALL PASS" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
