# The What's new window (WhatsNew.lua), in the fake WoW (wowmock.lua) with the
# whole addon loaded: it shows once after an update, not for a new player, not
# when turned off, and /hb new brings it back. Every version the .toc can be
# at has notes.  Run: python Tests/whatsnew_tests.py
import os
import re
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
fails = []
FILES = [l.strip() for l in open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8") if l.strip() and not l.startswith("#")]
TOC_VERSION = re.search(r"^## Version: (\S+)", open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8").read(), re.M).group(1)


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "   " + str(info)))
    if not cond:
        fails.append(name)


def login(version, saved=None):
    """a login with this version of the addon and these saved settings (None: a new player)"""
    L = LuaRuntime(unpack_returned_tuples=True)
    L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
    L.execute('C_AddOns.GetAddOnMetadata = function() return "%s" end' % version)
    G = L.globals()
    if saved is not None:
        G.HearthboundDB = L.table_from(saved)
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
    fire("PLAYER_ENTERING_WORLD", True, False)
    L.execute("MOCK.RunTimers()")
    return L, G, ns


def shown(G):
    f = G.HearthboundWhatsNew
    return bool(f and f._shown)


def saved(G):
    return {k: v for k, v in G.HearthboundDB.items() if isinstance(v, (str, bool, int, float))}


# a new player: nothing to catch up on
L, G, ns = login("0.9.6")
check("a new player isn't shown it", not shown(G))
check("...and starts counting from this version", G.HearthboundDB.whatsNewSeen == "0.9.6", G.HearthboundDB.whatsNewSeen)

# someone updating from before the window existed
L, G, ns = login("0.9.6", {"theme": "warrior"})
check("after updating, it shows", shown(G))
check("...titled with the version", "0.9.6" in str(G.HearthboundWhatsNew.title._text), G.HearthboundWhatsNew.title._text)
items = [str(l.title._text) for l in G.HearthboundWhatsNew.lines.values() if l.title._shown]
check("...listing this version's items", any("Party guide sync" in t for t in items), items)
links = [l.link.key for l in G.HearthboundWhatsNew.lines.values() if l.title._shown and l.link._shown]
check("...with a Settings link for the new settings", "guide" in links, links)
check("...and remembers it's been seen", G.HearthboundDB.whatsNewSeen == "0.9.6")
before = saved(G)

# the next login: not again
L, G, ns = login("0.9.6", before)
check("the next login doesn't show it again", not shown(G))

# seen the previous version: shows; seen this one: doesn't
L, G, ns = login("0.9.6", {"whatsNewSeen": "0.9.5"})
check("seen 0.9.5, now on 0.9.6: shows", shown(G))
L, G, ns = login("0.9.6", {"whatsNewSeen": "0.9.6"})
check("seen 0.9.6 already: doesn't", not shown(G))

# turned off
L, G, ns = login("0.9.6", {"whatsNewSeen": "0.9.5", "whatsNew": False})
check("turned off: doesn't show", not shown(G))

# /hb new: always
G.SlashCmdList.HEARTHBOUND("new")
check("/hb new shows it anyway", shown(G))

# a development copy (no version number) never pops up
L, G, ns = login("dev", {"theme": "warrior"})
check("a copy without a version number doesn't pop up", not shown(G))

# the version maths and the list
check("0.9.10 is newer than 0.9.9", ns.VersionNewer("0.9.10", "0.9.9") and not ns.VersionNewer("0.9.9", "0.9.10"))
check("1.0 is newer than 0.9.6", ns.VersionNewer("1.0", "0.9.6"))
check("a version isn't newer than itself", not ns.VersionNewer("0.9.6", "0.9.6"))
newest = max((e.version for e in ns.WHATS_NEW.values()), key=lambda v: [int(n) for n in re.findall(r"\d+", v)])
check(f"there are notes for the .toc's version or a later one (.toc {TOC_VERSION}, newest notes {newest})",
      not ns.VersionNewer(TOC_VERSION, newest))
check("updating past many versions shows at most two", len(list(ns.WhatsNewEntries(None, "99.0").values())) <= 2)
errors = list(L.globals().MOCK.errors.values())
check("no errors", not errors, errors[:3])

print()
print("ALL PASS" if not fails else f"{len(fails)} FAILED: {fails}")
sys.exit(1 if fails else 0)
