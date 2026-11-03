# Loads the whole addon (in .toc order) into a fake WoW (wowmock.lua), logs
# in, then opens every panel of the shell and clicks every line of every
# menu - reporting any Lua error. Run: python Tests/shell_smoke.py
import os
import sys
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ADDON = os.path.join(HERE, "..")
L = LuaRuntime(unpack_returned_tuples=True)
L.execute(open(os.path.join(HERE, "wowmock.lua"), encoding="utf-8").read())
G = L.globals()

files = [l.strip() for l in open(os.path.join(ADDON, "Hearthbound.toc"), encoding="utf-8")
         if l.strip() and not l.startswith("#")]
ns = L.table()
load = L.eval("""function(src, name, ns)
    local fn, err = load(src, "@" .. name)
    if not fn then return false, err end
    local ok, e = pcall(fn, "Hearthbound", ns)
    return ok, e
end""")
fails = []
for f in files:
    src = open(os.path.join(ADDON, f), encoding="utf-8").read()
    ok, err = load(src, f, ns)
    if not ok:
        fails.append(f"load {f}: {err}")

# log in: every frame's OnEvent with the login events
fire = L.eval("""function(event, ...)
    local args = { ... }
    for _, f in ipairs(MOCK.frames) do
        local fn = rawget(f, "_scripts") and f._scripts.OnEvent
        local ev = rawget(f, "_events")
        if type(ev) ~= "table" then ev = nil end
        if fn and (not ev or ev[event]) then
            local ok, err = xpcall(fn, debug.traceback, f, event, table.unpack(args))
            if not ok then table.insert(MOCK.errors, event .. ": " .. tostring(err)) end
        end
    end
end""")
fire("ADDON_LOADED", "Hearthbound")
fire("PLAYER_LOGIN")
fire("PLAYER_ENTERING_WORLD", True, False)
G.MOCK.RunTimers()

# the menu lines are buttons in the shell's menu column: click each one that has an item
click_menu = L.eval("""function(ns)
    local errs, clicked = {}, 0
    local labels = {}
    for pass = 1, 2 do
        for _, f in ipairs(MOCK.frames) do
            local item = rawget(f, "item")
            if item and not item.header and item.onClick and f:IsVisible() and not labels[item.label .. pass] then
                labels[item.label .. pass] = true
                local onClick = f._scripts.OnClick
                local ok, err = pcall(onClick, f, "LeftButton")
                clicked = clicked + 1
                if not ok then errs[#errs + 1] = "menu '" .. tostring(item.label) .. "': " .. tostring(err) end
                MOCK.RunTimers()
            end
        end
    end
    return errs, clicked
end""")

# the guide window: the card layout shows the step you're on
card_lua = L.eval("""function()
    local f = HearthboundGuideFrame
    if not (f and f.cv) then return "no guide window" end
    local out = { "tab: " .. tostring(f.cv.tabText._text), "place: " .. tostring(f.cv.place._text) .. " / " .. tostring(f.cv.zone._text) }
    for i, r in ipairs(f.cv.goals) do
        if r._shown then out[#out + 1] = "goal: " .. tostring(r.text._text) .. "  [" .. tostring(r.count._text) .. "] " .. (r.tick._shown and "x" or " ") end
    end
    out[#out + 1] = "bar: " .. tostring(f.cv.count._text) .. "   skip: " .. tostring(f.cv.skip.text._text)
    out[#out + 1] = "tip: " .. tostring(f.cv.tip._shown and f.cv.tip.text._text or "-")
    out[#out + 1] = "then: " .. tostring(f.cv.thenLine._shown and f.cv.thenLine.text._text or "-")
    out[#out + 1] = "foot: " .. tostring(f.cv.foot._text) .. "  " .. tostring(f.cv.pct._text)
    out[#out + 1] = "old list buttons shown: " .. tostring(f.buttons[1] and f.buttons[1]._shown)
    return table.concat(out, string.char(10))
end""")


def card_text():
    return card_lua()


card_at_login = card_text()
# the step bar: forward, then back to your step
nav = L.eval("""function()
    local cv = HearthboundGuideFrame.cv
    local before = cv.count._text
    cv.next._scripts.OnClick(cv.next)
    local ahead, skip = cv.count._text, cv.skip.text._text
    cv.prev._scripts.OnClick(cv.prev)
    return before, ahead, skip, cv.count._text
end""")
b4, ahead, skiplabel, back = nav()
print("step bar:", b4, "-> >", ahead, "(", skiplabel, ") -> back", back)
if not (b4 != ahead and skiplabel == "Skip" and back == b4):
    fails.append(f"step bar navigation: {b4} {ahead} {skiplabel} {back}")
print('guide card at login:')
print(card_at_login)
if 'goal:' not in card_at_login:
    fails.append('guide card not drawn at login')

sections = ["guide", "quests", "dungeons", "cards", "character", "achievements", "settings"]
run = L.eval("""function(ns, key, sub)
    local ok, err = pcall(ns.ShellOpen, key, sub)
    MOCK.RunTimers()
    if not ok then return "open " .. key .. ": " .. tostring(err) end
    local ok2, err2 = pcall(ns.ShellRefresh)
    if not ok2 then return "refresh " .. key .. ": " .. tostring(err2) end
end""")
for key in sections:
    err = run(ns, key, None)
    if err:
        fails.append(err)
        continue
    title = G.HearthboundShell.title._text if G.HearthboundShell else None
    sub = G.HearthboundShell.subtitle._text if G.HearthboundShell else None
    errs, clicked = click_menu(ns)
    for e in errs.values():
        fails.append(f"[{key}] {e}")
    print(f"{key:13s} title={title!r}  menu lines clicked={clicked}")
    print(f"{'':13s} subtitle={sub!r}")

# the old ways in
for what, call in [("ToggleOptions stats", lambda: ns.ToggleOptions("stats")),
                   ("ToggleOptions alts", lambda: ns.ToggleOptions("alts")),
                   ("ToggleOptions()", lambda: ns.ToggleOptions()),
                   ("ToggleCards", lambda: ns.ToggleCards()),
                   ("ShowGuideTidy", lambda: ns.ShowGuideTidy()),
                   ("ToggleGuideRoute", lambda: ns.ToggleGuideRoute()),
                   ("ShowDungeon", lambda: ns.ShowDungeon("rfc"))]:
    try:
        call()
        G.MOCK.RunTimers()
    except Exception as e:
        fails.append(f"{what}: {e}")
G.MOCK.RunTickers()
G.MOCK.RunTimers()
for e in G.MOCK.errors.values():
    fails.append("runtime " + str(e))

print(card_text())


print()
seen = set()
for f in fails:
    if f in seen:
        continue
    seen.add(f)
    print("FAIL", f)
print("FAILED:" if fails else "ALL PASSED", len(seen))
sys.exit(1 if fails else 0)
