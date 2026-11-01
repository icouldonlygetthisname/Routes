# Routes (forked third-party addon)

Upstream addon by Nevcairiel. This repo is a real GitHub fork: `origin` = github.com/icouldonlygetthisname/Routes, `upstream` = github.com/Nevcairiel/Routes. Local work lives on the `fixes` branch. See README.md for the list of changes, the retail workflow and the Forever build.

## How this differs from the other patched addons

- Upstream's own git history is the baseline. There are no `Baseline: ... (upstream, unmodified)` commits. Rebase or merge onto upstream tags.
- Fixes aren't marked with a `--Local fix`-style comment. Each is its own commit on `fixes`, and the README table lists them.
- The repo has no `Libs/` (they come from `.pkgmeta`). Never delete `Libs/` in a game folder when copying the repo in.
- Retail game folder: a copy of `fixes` with `@project-version@` replaced by `fork-fixes-<hash>`. Dry-run robocopy (`/L`) first. Exclude the placeholder locales (`Locale-deDE/esES/frFR/koKR/ptBR/zhCN/zhTW.lua`, which hold only `@localization@`): the game folder has the CurseForge translations. README.md has the exact command.

## WoW Forever

- Forever (product `wowf`, interface `16001`, `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`) runs on the mainline client. Code that branches on `WOW_PROJECT_MAINLINE` or `WOW_PROJECT_CLASSIC` takes the "other" path there. Check that path works when adding such checks.
- Verify APIs against the `forever` branch of wow-ui-source (`git -C E:/VScode/_tools/wow-ui-source fetch --depth 1 origin forever:refs/remotes/origin/forever`), not just `live`.
- Spells differ per client. Look spells up with `MapSpellName` in `Modules/AutoShow.lua`, which skips IDs the client doesn't know, never `GetSpellName(id)` as a table key.
- `_forever_\Interface\AddOns\Routes` is built by `E:\VScode\_tools\build-forever.ps1 -Deploy` from the committed HEAD, with HereBeDragons-2.0 minor 35+ from `_tools\HereBeDragons`. Commit first.

## Rules

- Match upstream style: tabs, no `;`, `Routes:` methods, `L[...]` for user-facing strings (add new keys to `Locales/Locale-enUS.lua`).
- Run `luac -p` on changed files. There is no `.luacheckrc` here.
- The fork is public. Pushing branches to `origin` is fine. Opening PRs against `upstream` is outward-facing, so ask first.
