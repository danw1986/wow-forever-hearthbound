# Hearthbound

A levelling companion addon for WoW Forever (Interface 16001). Hearthbound
brings a step-by-step Horde 1-60 guide, an XP panel and a set of quality-of-life
tools into one window, and keeps a record of each character's journey to 60.

## Screenshots

| Levelling panel | Guide step |
| --- | --- |
| ![Levelling panel](screenshots/levelling-panel.png) | ![Guide step](screenshots/guide-step.png) |

| Guide arrow and next step | Quest targets |
| --- | --- |
| ![Guide arrow](screenshots/guide-arrow.png) | ![Quest targets](screenshots/quest-targets.png) |

| Milestone pop-up | Quest item tooltip |
| --- | --- |
| ![Milestone pop-up](screenshots/level-milestone.png) | ![Quest item tooltip](screenshots/quest-item-tooltip.png) |

## Features

**Levelling guide**
- Walks the Horde 1-60 route one step at a time. Steps tick off as you accept,
  finish and hand in quests, reach a spot, fly, hearth, train or enter a dungeon
- Movable arrow with distance to the next step, numbered map pins, and a quest
  item button for steps that need an item used
- Detours, "on the way" quests near your route, quest log tidy-up, and a guide
  that learns from your play
- Guide panel with every zone and section of the route

**Levelling panel**
- XP bar, XP/hour and time-to-level, plus a restyled game XP bar
- Road to 60: forecasts play time needed for each milestone level
- Objectives nearby, quests ready to hand in, best XP quests, grind spots and
  "where next" zone suggestions
- Trainer reminders, talent points, weapon skills and class quests
- Gold tracker, repair warning, food supplies and session goals (`/hb goal 30`)

**Quests**
- Auto accept / auto hand-in (toggleable per type) and a quest reward picker
- Quest pins on the world map and minimap, mob tooltips showing quest progress,
  a quest targets window, and "(Completed)" tags on chat quest links
- Quest item keep/sell tooltips and a vendor helper that sells greys
- "Don't leave yet" alert when you walk away from quests you could finish
- Completed quest history and a Secrets view of hidden quests, toys, pets and
  collections

**Dungeons**
- Dungeon journal with quests (and map markers), bosses, per-boss loot and a
  banner picture for each dungeon

**Journey and stats**
- Journey tab: road to 60, milestones reached, deaths and level history
- Stats tab: session summary, XP sources, best mobs, kills by creature type
- Achievements, milestone pop-ups and level-up screenshots
- Enemy card collection: each different enemy you kill adds its card
- Alts tab with an account-wide snapshot of every character and total gold

**Interface**
- One shell window with a tab rail, menu column and content panel
- Optional Hearthbound-styled nameplates with threat colours
- Minimap button, welcome-back summary on login, first-time setup wizard
- Settings profiles (export / import as text) and a debug report

## Installation

1. Open the [latest release](https://github.com/danw1986/wow-forever-hearthbound/releases/latest)
   and download `Hearthbound-<version>.zip` (not "Source code").
2. Unzip it into:

   ```
   World of Warcraft\_forever_\Interface\AddOns\
   ```

   You should end up with `AddOns\Hearthbound\Hearthbound.toc`.
3. Restart the game, or `/reload` if you're updating.

## Commands

| Command | Does |
| --- | --- |
| `/hb` | Open settings |
| `/hb help` | List all commands |
| `/hb setup` | Run first-time setup again |
| `/hb guide ...` | Levelling guide commands |
| `/hb quests` / `stats` / `journey` / `alts` / `dungeons` / `achievements` | Open that tab |
| `/hb cards` | Enemy card collection |
| `/hb targets` | Quest targets window |
| `/hb goal <level>` | Set a session goal |
| `/hb left` / `left <n>` / `left clear` | Quests you walked away from |
| `/hb accept` | Toggle auto accept |
| `/hb summary` / `last` | This session's / last session's summary |
| `/hb lock` / `unlock` / `reset` | Lock, unlock or reset frame positions |
| `/hb xpreset` | Reset the XP session |
| `/hb export` / `import` | Settings profiles as text |
| `/hb plates test` | Cycle threat colours on your target's nameplate |
| `/hb debug` / `mem` | Debug report / memory usage |

Key bindings for the guide (Next, Back, Current, Find, Arrow, Toggle) are under
Key Bindings > AddOns > Hearthbound.

## Saved data backup

The WoW Forever beta client saves addon data on exit but doesn't always read it
back. To work around this:

1. Close the game.
2. Double-click `Backup Hearthbound.bat`.

The script copies the saved variables into a timestamped `Backups` folder
(keeping the latest 15) and writes them into `Seed.lua`, which the addon loads
on the next login. It also picks up any dungeon pictures dropped into
`Images\Incoming` (see the readme there for file names).

## Repository layout

| Path | Contents |
| --- | --- |
| `*.lua`, `Hearthbound.toc`, `Bindings.xml` | The addon |
| `GuideData.lua` | The levelling route |
| `Images/`, `Media/` | Dungeon pictures, card art and textures |
| `screenshots/` | README screenshots |
| `Tests/` | Offline test harness (Lua mocks + Python test and route tools) |
| `Tests/build_release.py` | Builds the zip attached to a release |
| `RouteBackups/` | Earlier snapshots of files from past reworks |

## Licence

GPL-3.0: see [LICENSE](LICENSE). The dungeon pictures in `Images/` are third-party
images and aren't covered by this licence.

## Version

0.8.0
