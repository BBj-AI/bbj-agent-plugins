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
| docs/install-claude-code.md:3 | all | Verified on Linux, Windows and macOS, each with BBj 26.03 | 10-LINUX-RUN.md:24; 10-LINUX-RUN.md:120-121; 09-WINDOWS-RUN.md:45; 09-WINDOWS-RUN.md:404; 09-MACOS-RUN.md:48; 09-MACOS-RUN.md:239 |
| docs/install-claude-code.md:5 | Linux | Claude Code 2.1.299 on Linux, 2026-10-14 | 10-LINUX-RUN.md:22; 10-LINUX-RUN.md:107; 10-LINUX-RUN.md:120-121 |
| docs/install-claude-code.md:6 | Windows | Claude Code 2.1.292 on Windows, 2026-10-13 and 2026-10-14 | 09-WINDOWS-RUN.md:43; 09-WINDOWS-RUN.md:363-376 (round 1, 2026-10-13); 09-WINDOWS-RUN.md:387-404 (round 2, 2026-10-14) |
| docs/install-claude-code.md:7 | macOS | Claude Code 2.1.296 on macOS, 2026-10-14 | 09-MACOS-RUN.md:46; 09-MACOS-RUN.md:217-219; 09-MACOS-RUN.md:239 |
| docs/install-claude-code.md:10 | all | Definition of the words Observed on and Not run used on the page (no run claim of its own) | 10-VERIFIED-MATRIX.md:1-10 |
| docs/install-claude-code.md:20 | all | The plugin was tested with Claude Code 2.1.299 on Linux, 2.1.292 on Windows and 2.1.296 on macOS | 10-LINUX-RUN.md:22; 09-WINDOWS-RUN.md:43; 09-MACOS-RUN.md:46 |
| docs/install-claude-code.md:160 | Windows; macOS | Asked to create a file, Claude Code wrote it with a Bash shell command and the hook did not run; after the request to use the Write tool the Write hook fired | 09-WINDOWS-RUN.md:375; 09-WINDOWS-RUN.md:392; 09-WINDOWS-RUN.md:715; 09-MACOS-RUN.md:371 |
| docs/install-claude-code.md:173 | Windows | Claude Code 2.1.292 with the bbj_home option: bbjcpl reported after Write and after Edit, also in a path with a space, silent for a clean file; the command field ran and commandWindows was ignored without harm | 09-WINDOWS-RUN.md:39-46; 09-WINDOWS-RUN.md:383; 09-WINDOWS-RUN.md:398-404 |
| docs/install-claude-code.md:180 | Windows | Hook run from Git Bash: compiler under C:\bbx found through bbj_home and mapped with cygpath, Windows-form -P list and target, space kept; Claude Code prints one option not yet set | 09-WINDOWS-RUN.md:259-262; 09-WINDOWS-RUN.md:374; 09-WINDOWS-RUN.md:383 |
| docs/install-claude-code.md:187 | Windows | bbj-local plugin not listed until installed and enabled; claude mcp list shows it connected at 127.0.0.1:5009; bbj_check_syntax returned one SyntaxError | 09-WINDOWS-RUN.md:489-508; 09-WINDOWS-RUN.md:506 |
| docs/install-claude-code.md:192 | Windows | Hook run from Git Bash: tier 2 printed bbj-local reported with exit 2, clean silent; with no route the no-route notice once, silent on the second call | 09-WINDOWS-RUN.md:586; 09-WINDOWS-RUN.md:656 |
| docs/install-claude-code.md:198 | Windows | Not run: the BBj home found from BBJ_HOME, BBJHOME, PATH or the default for Claude Code (the runs gave bbj_home), and the hook tier 2 inside a Claude Code session (run from Git Bash only) | 09-WINDOWS-RUN.md:374; 09-WINDOWS-RUN.md:586 |
| docs/install-claude-code.md:204 | macOS | bbj plugin from a local clone with bbj_home given: bbjcpl reported after Write and Edit, clean silent; the BBj home is outside the default list and found only because it was named | 09-MACOS-RUN.md:217-239; 09-MACOS-RUN.md:239; 09-MACOS-RUN.md:372 |
| docs/install-claude-code.md:213 | macOS | bbjcpl printed error at line 10 (1) for a one-line file; the hook passes the compiler lines through unchanged | 09-MACOS-RUN.md:371 |
| docs/install-claude-code.md:217 | macOS | Hook run on its own with every compiler route off: tier 2 printed bbj-local reported with exit 2, clean silent | 09-MACOS-RUN.md:272-320 |
| docs/install-claude-code.md:221 | macOS | Not run: the bbj-local plugin in Claude Code (only the hook own tier 2 was seen) | 09-MACOS-RUN.md:272-320 |
| docs/install-codex.md:3 | all | Verified on Linux, Windows and macOS, each with BBj 26.03 | 10-LINUX-RUN.md:24; 10-LINUX-RUN.md:38-64; 09-WINDOWS-RUN.md:45; 09-WINDOWS-RUN.md:469; 09-MACOS-RUN.md:48; 09-MACOS-RUN.md:269 |
| docs/install-codex.md:5 | all | Codex plugin with Codex CLI 0.162.1: Linux 2026-10-13 and 2026-10-14, Windows 2026-10-13 and 2026-10-14 (on 2026-10-13 the install, the bbj-local plugin and the sign-in worked and the hook failed, as the Windows section describes; the working hook reading is 2026-10-14), macOS 2026-10-14 | 08-LINUX-RUN.md:15; 08-LINUX-RUN.md:18; 10-LINUX-RUN.md:23; 10-LINUX-RUN.md:38-101; 09-WINDOWS-RUN.md:44; 09-WINDOWS-RUN.md:410-441 (round 1, 2026-10-13); 09-WINDOWS-RUN.md:442-470 (round 2, 2026-10-14); 09-MACOS-RUN.md:47; 09-MACOS-RUN.md:242-269 |
| docs/install-codex.md:8 | all | Definition of the words Observed on and Not run used on the page (no run claim of its own) | 10-VERIFIED-MATRIX.md:1-10 |
| docs/install-codex.md:18 | all | The plugin route was verified with Codex CLI 0.162.1 | 10-LINUX-RUN.md:23; 09-WINDOWS-RUN.md:44; 09-MACOS-RUN.md:47 |
| docs/install-codex.md:26 | Linux | Verified on Linux with Codex CLI 0.162.1 on 2026-10-13 and 2026-10-14: the plugin installs from the marketplace, bbj-docs is registered at its URL, both skills are listed, after the hook was trusted a BBj file written through apply_patch got the compiler feedback | 08-LINUX-RUN.md:18; 08-LINUX-RUN.md:84-111; 08-LINUX-RUN.md:432-454; 10-LINUX-RUN.md:38-64 |
| docs/install-codex.md:29 | Linux | 2026-10-14: the real BBj 26.03 compiler gave bbjcpl reported for a bad file and was silent for a clean one; with no compiler and BBjServices answering the hook gave bbj-local reported | 10-LINUX-RUN.md:38-64; 10-LINUX-RUN.md:68-101 |
| docs/install-codex.md:32 | Linux; Windows; macOS | The hook passed the compiler the file with -N and BBj code was never run; the plugin route was also verified on Windows (2026-10-13 and 2026-10-14; see the line 5 row for what 2026-10-13 showed) and macOS (2026-10-14) | 08-LINUX-RUN.md:130-136; 10-LINUX-RUN.md:38-64; 09-WINDOWS-RUN.md:410-441; 09-WINDOWS-RUN.md:442-470; 09-MACOS-RUN.md:242-269 |
| docs/install-codex.md:46 | Linux | codex plugin marketplace add BBj-AI/bbj-agent-plugins resolves and clones the default branch of the GitHub repository | 08-LINUX-RUN.md:184-204 |
| docs/install-codex.md:58 | Linux | Before the review Codex listed the hook as untrusted; after it trusted, and a bad BBj file written through apply_patch came back with the compiler lines once | 08-LINUX-RUN.md:220; 08-LINUX-RUN.md:310-311; 08-LINUX-RUN.md:438-454 |
| docs/install-codex.md:79 | Linux | In a scratch copy of the plugin with the pre-registered client the sign-in completed through the no-browser path; without the client dynamic client registration is refused | 08-LINUX-RUN.md:285-300; 08-LINUX-RUN.md:232-235 |
| docs/install-codex.md:82 | Linux | Sign-in to bbj-docs with the plugin as it ships completed (2026-10-14) and Codex stored a refresh token | 10-LINUX-RUN.md:186-188 |
| docs/install-codex.md:84 | Windows; macOS | The sign-in to the hosted docs server also completed on Windows (2026-10-13) and on macOS (2026-10-14) | 09-WINDOWS-RUN.md:673-678; 09-MACOS-RUN.md:359-364 |
| docs/install-codex.md:105 | macOS | Codex runs hooks in its app-server daemon, which keeps its start environment; BBJ_HOME exported before codex did not reach the hook until every Codex process was stopped | 09-MACOS-RUN.md:369 |
| docs/install-codex.md:122 | Linux | bbj-local is absent from codex mcp list until codex plugin add bbj-local@basis-bbj and listed at 127.0.0.1:5009 after it; with nothing listening Status reads enabled and Auth Unsupported | 08-LINUX-RUN.md:164-183 |
| docs/install-codex.md:130 | Linux | After a plugin upgrade that changed only the version Codex still listed the hook as trusted with an unchanged hash and the check ran without a new trust | 08-LINUX-RUN.md:469-475; 08-LINUX-RUN.md:520-537 |
| docs/install-codex.md:137 | Windows | After the plugin hooks.json gained a commandWindows entry Codex asked to trust the hook again at the start of the session | 09-WINDOWS-RUN.md:459-465 |
| docs/install-codex.md:142 | Linux | Upgrade through the Git marketplace from 0.2.0 to 0.2.1 (2026-10-15): hook hash unchanged, no new trust asked, shown Trusted, bbjcpl reported after an apply_patch of a bad file | 10-LINUX-RUN.md:191-199; 10-LINUX-RUN.md:239-321 |
| docs/install-codex.md:151 | Windows; macOS | Not run: an upgrade through a Git marketplace on Windows or macOS (only the Linux upgrade was run) | 08-LINUX-RUN.md:526-529; 10-LINUX-RUN.md:191-321 |
| docs/install-codex.md:212 | Windows | Before the plugin carried a commandWindows entry the hook failed with hook exited with code 1 on every write, a clean file included | 09-WINDOWS-RUN.md:425-435 |
| docs/install-codex.md:220 | Windows | Not run: Git for Windows installed anywhere other than its default location (the shipped path names the default one) | 09-WINDOWS-RUN.md:467 |
| docs/install-codex.md:223 | Windows | Plugin route 2026-10-14 after the commandWindows entry: the hook ran through PowerShell, bbjcpl reported for a bad file after apply_patch create and update, clean silent, trust asked again, BBJ_HOME given | 09-WINDOWS-RUN.md:459-470 |
| docs/install-codex.md:229 | Windows | Hook script run from Git Bash with the real compiler: compiler under C:\bbx found, Windows-form -P list and target, space in the path kept | 09-WINDOWS-RUN.md:259-262; 09-WINDOWS-RUN.md:383 |
| docs/install-codex.md:234 | Windows | bbj-local absent from codex mcp list until codex plugin add bbj-local@basis-bbj, then enabled at 127.0.0.1:5009 and bbj_check_syntax returned one SyntaxError (2026-10-13) | 09-WINDOWS-RUN.md:509-530; 09-WINDOWS-RUN.md:528 |
| docs/install-codex.md:244 | Windows | Not run: the hook second route (bbj-ls) inside a Codex session; it was run from Git Bash only | 09-WINDOWS-RUN.md:586 |
| docs/install-codex.md:249 | macOS | Plugin route 2026-10-14 with BBJ_HOME in the environment of the Codex process that runs hooks: trusted, bbjcpl reported after apply_patch create and update, clean silent; without it the first runs fell back to the second route | 09-MACOS-RUN.md:242-269; 09-MACOS-RUN.md:369 |
| docs/install-codex.md:259 | macOS | bbjcpl printed error at line 10 (1) for a one-line file; the hook passes the compiler lines through unchanged | 09-MACOS-RUN.md:371 |
| docs/install-codex.md:262 | macOS | Not run: the bbj-local plugin in Codex (only the hook own tier 2 was seen) | 09-MACOS-RUN.md:272-320 |

## Outside the four records

- README.md:63, macOS cell, `bbj-ls (hook)`: the 0.2.0 UAT of the owner's macOS Claude Code
  (`.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-UAT.md:31-34`) shows the hook's second route
  (`bbj-local reported 1 error(s)`) in a Claude Code session; the client version is not recorded there.
  The version in the cell is the one of 09-MACOS-RUN.md:46, and 09-MACOS-RUN.md:272-320 shows the
  same hook route run directly, not through the client.
- docs/install-claude-code.md:20, "Claude Code 2.1.281 or later": a minimum version, not a run
  claim. It is kept by the phase 10 decision
  (`.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-CONTEXT.md:81`); the
  versions the plugin was tested with in the same sentence are traced in the table.
- docs/install-codex.md:5 and :32, Windows 2026-10-13: the record of that day shows the install, the
  bbj-local plugin and the sign-in working and the hook failing before the `commandWindows` entry
  (09-WINDOWS-RUN.md:425-435, described in the page's Windows section); the reading with a working
  hook is 2026-10-14 (09-WINDOWS-RUN.md:459-470). The dates are those of the phase 10 matrix
  (`10-VERIFIED-MATRIX.md`, Cells table, row Codex plugin / Windows) and are kept as written.

## Removed

README claims deleted because only a retired-route record backed them (D-06):

- README.md table row `Codex installer` (all three platform cells). Linux rested on
  `evidence/codex/result.txt` of the 0.2.0 run of 2026-10-12, Windows on
  10-WINDOWS-INSTALLER-RUN.md:166-217, macOS on 06-UAT.md:36-39.
- README "Not run" clauses about the retired route on macOS, on Linux (as changed since 0.2.0) and
  on Windows (the Git launcher and `hooks.json` observation of 2026-10-14, 10-WINDOWS-INSTALLER-RUN.md).
- README sign-in sentence naming the Codex installer as a third route that configures the client.

Page claims deleted because only a retired-route record backed them, or no record at all:

- docs/install-codex.md banner bullet for the retired route (Linux 2026-10-12, Windows 2026-10-14,
  macOS 2026-10-12), its status line, and the sections that described it (the switch-over, the
  `AGENTS.md` snippet, the fallback) with their Linux, macOS and Windows observations; the Windows
  observation of 2026-10-14 rested on 10-WINDOWS-INSTALLER-RUN.md:166-217 alone, the macOS
  observation of 0.2.0 on 06-UAT.md:36-39 alone.
- docs/install-claude-code.md, in the Not covered section (before the Bash-write paragraph):
  "Edits made by subagents are checked as well; this was verified with Claude Code 2.1.294 and not
  repeated on later versions." It is a client-version claim and no run record in the tree shows it
  (the only trace of it is the 0.1.0 page text, commit b8a56f5). It was removed rather than reworded
  upward, and the page pin for the word "subagent" went with it; the forbid on "subagent edits are not
  covered" stays. Restore it only with a run record.

No row rests on 10-WINDOWS-INSTALLER-RUN.md alone.
