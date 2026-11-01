# Routes (local fixes + WoW Forever build)

Fork of [Routes](https://github.com/Nevcairiel/Routes) by Nevcairiel (originally Grum and Xinhuan). The `fixes` branch carries bug fixes, performance work and WoW Forever support on top of upstream `master`. None of it is upstream yet.

## Changes (branch `fixes`)

Based on upstream `master` at `upstream/master` as of 2026-11-01 (latest tag `v1.8.7`).

| Commit | Change |
| --- | --- |
| `9e494a1` | AutoShow: only map spell names that exist on the client. A missing spell (e.g. TBC Anniversary) made a nil table key and errored on load (#45). Uses the generic Find Timber spell `1256697` so "Only while tracking" works for logging outside the garrison (#49). Falls back to known spells to detect professions on Classic/SoD (#22). |
| `7d59852` | Route creation: rebuild the node list every time instead of caching it per zone (#50). Refreshing one source no longer drops the others' selections. Selections are cleared after a route is created (#28). A GatherMate2 node missing from the English locale table no longer errors. |
| `e174b51` | Clustering uses a spatial grid and cached nearest neighbours instead of an O(n³) scan, and yields throughout (#38, #30). Routes over 724 nodes are optimized with nearest neighbour + 2-opt instead of the ant colony solver, which needs N×N tables (#41). Fixes the background error handlers. |
| `e717713` | ruRU locale update (upstream PR #40 by Hubbotu). |
| `a3ddbfe` | TOC for 12.1. |
| `6dbfecb` | New routes start with a nearest neighbour + 2-opt order instead of an angle sort, so they don't zigzag across the zone before optimization. |
| `5bcca57` | Option descriptions word wrap instead of being cut to one line. |
| `b88c18a` | Help text rewritten to match the current options. |
| `5aa0f90` | TOC: add WoW Forever (`16001`). |

## WoW Forever

WoW Forever (product `wowf`, interface `16001`) runs on the mainline client. Comparing the API documentation of the `live` and `forever` branches of wow-ui-source shows only 7 functions/events missing on Forever, and Routes uses none of them. The two `WOW_PROJECT_ID` checks behave correctly there:

- `Routes.lua` taboo editing: Forever isn't `WOW_PROJECT_MAINLINE`, so it opens the map with `ShowUIPanel(WorldMapFrame)` + `SetMapID`, which also works on Forever.
- `Modules/AutoShow.lua`: Forever isn't `WOW_PROJECT_CLASSIC`, so it reads tracking from `C_Minimap.GetTrackingInfo`, which Forever has. Classic's `GetTrackingTexture` doesn't exist there.

So the only code change is the TOC line. Routes also needs **HereBeDragons-2.0 minor 35 or newer**, which adds the Forever world map data. The retail package carries minor 33.

The copy in `_forever_\Interface\AddOns\Routes` is built locally, together with GatherMate2:

```powershell
E:\VScode\_tools\build-forever.ps1 -Deploy
```

It exports the committed HEAD with `git archive`, adds `Libs/` from the retail copy, and replaces `Libs/HereBeDragons` with upstream master from `_tools\HereBeDragons`. Then it sets the TOC version to `<git describe>-forever` and installs the result. Any previous Forever copy goes to `%TEMP%\forever-backup\`. Without `-Deploy` it only builds into `%TEMP%\forever-build`. The GatherMate2 README has the details. The build is English (and Russian) only, because the other locale files are `@localization@` placeholders.

## Workflow (retail)

The retail game folder (`_retail_\Interface\AddOns\Routes`) is a copy of this branch, not a CurseForge package. `@project-version@` in `Routes.toc` and `Routes.lua` is replaced with `fork-fixes-<commit>`. `Libs/` and the translated locales come from an earlier CurseForge package. The repo has no `Libs/`, and its `Locale-deDE/esES/frFR/koKR/ptBR/zhCN/zhTW.lua` hold only a `@localization@` placeholder, so copying them over would leave those clients untranslated. `Locale-enUS.lua` and `Locale-ruRU.lua` are complete in the repo.

To update it:

1. Dry run, to catch edits made in the game folder: `robocopy E:\VScode\Routes "<AddOns>\Routes" /E /XD .git .github .vscode /XF .gitignore .editorconfig .pkgmeta README.md CLAUDE.md Locale-deDE.lua Locale-esES.lua Locale-frFR.lua Locale-koKR.lua Locale-ptBR.lua Locale-zhCN.lua Locale-zhTW.lua /L`.
2. Run the same command without `/L`. `Libs/` and the translated locales in the game folder are left alone.
3. Replace `@project-version@` in `Routes.toc` and `Routes.lua` with `fork-fixes-<short hash>`.

New locale keys only reach the translated locales through a CurseForge package. Until then those clients fall back to the English text.

After an upstream release, rebase or merge `fixes` onto the new tag and update this README.
