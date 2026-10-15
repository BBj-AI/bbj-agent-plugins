# Phase 11: Claim trace for the install docs (DOCS-06)

This file lists every per-platform claim of `README.md`, `docs/install-claude-code.md` and
`docs/install-codex.md` after the retired install route was removed, with the run record behind it.
A row is one line of a doc that holds `Observed on`, `Verified on`, `verified on` or a README table
data row, plus the other per-platform sentences (client versions, sign-in dates, date lists). The
Record column names a record file and line (`file:line`); the cited lines were opened and show the
claim. The line numbers of the docs are those after plan 11-03.

Run records (directory `.planning/milestones/v0.2.1-phases/`):

- `08-codex-plugin-route/08-LINUX-RUN.md`
- `09-windows-and-macos-verification/09-WINDOWS-RUN.md`
- `09-windows-and-macos-verification/09-MACOS-RUN.md`
- `10-install-wording-and-release-0-2-1/10-LINUX-RUN.md`
- `10-install-wording-and-release-0-2-1/10-WINDOWS-INSTALLER-RUN.md` (the retired route only: a claim
  it alone backed was removed)
- `10-install-wording-and-release-0-2-1/10-VERIFIED-MATRIX.md` (the matrix the rows started from)

| Doc line | Platform | Claim | Record |
|----------|----------|-------|--------|
| README.md:32 | all | The docs server asks for a one-time OAuth sign-in; the Claude Code plugin and the Codex plugin configure the pre-registered client (callback port 47613); the per-platform sign-in dates follow at line 34 | 10-LINUX-RUN.md:176-187; 09-WINDOWS-RUN.md:677-678; 09-MACOS-RUN.md:363-364 |
| README.md:34 | all | The sign-in completed in both clients on Linux with the plugin as it ships (2026-10-14), and in both clients on Windows (2026-10-13) and on macOS (2026-10-14) with the plugin installed from a checkout; without the pre-registered client Codex's dynamic client registration is refused | 10-LINUX-RUN.md:186-187; 09-WINDOWS-RUN.md:677-678; 09-MACOS-RUN.md:363-364; 08-LINUX-RUN.md:232-235 |
| README.md:55 | all | Verified on Linux, Windows and macOS with BBj 26.03: the compiler check reported on a bad file and stayed silent on a clean one on each platform | 10-LINUX-RUN.md:24; 10-LINUX-RUN.md:120-121; 09-WINDOWS-RUN.md:45; 09-WINDOWS-RUN.md:404; 09-MACOS-RUN.md:48; 09-MACOS-RUN.md:239 |
| README.md:63 | all | Claude Code: Linux bbjcpl and bbj-ls (bbj-local plugin) with Claude Code 2.1.299; Windows bbjcpl and bbj-ls (bbj-local plugin) with 2.1.292; macOS bbjcpl and bbj-ls (hook) with 2.1.296 | 10-LINUX-RUN.md:22; 10-LINUX-RUN.md:120-121; 10-LINUX-RUN.md:127-128; 09-WINDOWS-RUN.md:43; 09-WINDOWS-RUN.md:404; 09-WINDOWS-RUN.md:506; 09-MACOS-RUN.md:46; 09-MACOS-RUN.md:239; 09-MACOS-RUN.md:272-320; 06-UAT.md:31-34 |
| README.md:64 | all | Codex plugin: Linux bbjcpl and bbj-ls (hook), Windows bbjcpl and bbj-ls (bbj-local plugin), macOS bbjcpl and bbj-ls (hook), all with Codex CLI 0.162.1 | 10-LINUX-RUN.md:23; 10-LINUX-RUN.md:38-64; 10-LINUX-RUN.md:68-101; 09-WINDOWS-RUN.md:44; 09-WINDOWS-RUN.md:469; 09-WINDOWS-RUN.md:528; 09-MACOS-RUN.md:47; 09-MACOS-RUN.md:269; 09-MACOS-RUN.md:369 |

## Outside the four records

- README.md:63, macOS cell, `bbj-ls (hook)`: the 0.2.0 UAT of the owner's macOS Claude Code
  (`.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-UAT.md:31-34`) shows the hook's second route
  (`bbj-local reported 1 error(s)`) in a Claude Code session; the client version is not recorded there.
  The version in the cell is the one of 09-MACOS-RUN.md:46, and 09-MACOS-RUN.md:272-320 shows the
  same hook route run directly, not through the client.

## Removed

README claims deleted because only a retired-route record backed them (D-06):

- README.md table row `Codex installer` (all three platform cells). Linux rested on
  `evidence/codex/result.txt` of the 0.2.0 run of 2026-10-12, Windows on
  10-WINDOWS-INSTALLER-RUN.md:166-217, macOS on 06-UAT.md:36-39.
- README "Not run" clauses about the retired route on macOS, on Linux (as changed since 0.2.0) and
  on Windows (the Git launcher and `hooks.json` observation of 2026-10-14, 10-WINDOWS-INSTALLER-RUN.md).
- README sign-in sentence naming the Codex installer as a third route that configures the client.
