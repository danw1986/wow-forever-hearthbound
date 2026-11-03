# QuestieLink's race/class checks against QuestieDB's real masks (Forever's
# Skyborne bit is past 32 bits, which the game's bit library can't handle).
# Run: python Tests/race_tests.py
import json
import os
import re
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(HERE, "..", "QuestieLink.lua"), encoding="utf-8").read()
code = src[src.index("local function HasBit"):src.index("local function OwnDoable")]
code = re.sub(r"\nlocal function (Done|QuestName)\(.*?\nend\n", "\n", code, flags=re.S)
DB = json.load(open(os.path.join(HERE, "questiedb.json")))["Quest"]
fails = []


def check(name, cond, info=""):
    print(("PASS " if cond else "FAIL ") + name + ("" if cond else "  " + str(info)))
    if not cond:
        fails.append(name)


def checker(race_id, faction):
    L = LuaRuntime()
    L.execute(f'UnitRace = function() return "x", "x", {race_id} end UnitFactionGroup = function() return "{faction}" end')
    L.execute(code + "\nFITS_RACE = FitsRace\nFITS_MASK = FitsMask")
    return L.globals().FITS_RACE, L.globals().FITS_MASK


tauren, mask_t = checker(6, "Horde")
sky, _ = checker(96, "Horde")
orc, _ = checker(2, "Horde")

sky_horde = 2 ** 33  # QuestieDB's Horde Skyborne bit
check("a Horde-Skyborne-only quest is not for a tauren", not tauren(sky_horde))
check("...it is for a Skyborne", sky(sky_horde))
check("a Horde-wide quest (with the Skyborne bit) is for a tauren", tauren(8589934770))
check("...and for a Skyborne", sky(8589934770))
check("a tauren-only quest isn't for an orc", not orc(32) and tauren(32))
both = DB["92474"]["requiredRaces"]  # Falling With Style: both factions' Skyborne
check("a both-factions Skyborne quest is for a Horde Skyborne", sky(both), both)
check("...but not for a tauren", not tauren(both), both)
check("an Alliance-only Skyborne quest isn't for a Horde Skyborne", not sky(2 ** 34))
check("warrior class bit", mask_t(1, 1) and not mask_t(1, 3))

print()
print("FAILED:" if fails else "ALL PASSED", fails)
