# Phase 10: Verified matrix (plan 10-06)

The one source of the platform wording of README, the Claude Code page (plan 10-06), the Codex
page, the installer text and the CHANGELOG (plans 10-07, 10-08). A cell or a fact below is copied
into shipped text only as written here; the line in `Sources` is where the record shows it. A
configuration with no record line is under `## Not run`, never in a cell.

Source files (`file:line`; the directory is given once):

| Short name | Path |
|------------|------|
| 10-LINUX-RUN.md | `.planning/phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md` |
| 10-WINDOWS-INSTALLER-RUN.md | `.planning/phases/10-install-wording-and-release-0-2-1/10-WINDOWS-INSTALLER-RUN.md` |
| 09-WINDOWS-RUN.md | `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` |
| 09-MACOS-RUN.md | `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` |
| 08-LINUX-RUN.md | `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` |
| 06-UAT.md | `.planning/milestones/v0.2.0-phases/06-release-0-2-0/06-UAT.md` |
| evidence/codex/* | `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/codex/` |

Route names (D-01): `bbjcpl` is the hook's compiler route, seen as a `bbjcpl reported` text. `bbj-ls`
is the local language server answering. `(hook)` marks a `bbj-local reported` text of the hook's
second route (tier 2) with no compiler on the route. `(bbj-local plugin)` marks the `bbj-local` plugin
connected and `bbj_check_syntax` answering. A cell names a route only when its Sources entry shows it.

Run environments (Windows 10.0.19045.6466, Git for Windows 2.52.0.windows.1, BBj 26.03 at
`C:\bbx`; macOS 27.0.1, /bin/sh bash 3.2.57, BBj 26.03 at `<home>/bbx`; Linux 6.8.0-138-generic,
BBj 26.03 at `/opt/bbx`) are in `## Versions`.

## Cells

| Row | Platform | Routes seen | Client version | Dates | Sources |
|-----|----------|-------------|----------------|-------|---------|
| Claude Code | Linux | `bbjcpl`; `bbj-ls` (bbj-local plugin) | Claude Code 2.1.299 | 2026-10-14 | 10-LINUX-RUN.md:105-133 (install gate `install_hook_bad` exit 2 `bbjcpl reported 1 error(s)`, `install_hook_clean` silent, `claude mcp list` `plugin:bbj-local:bbj-local ... Connected`); version line 10-LINUX-RUN.md:22 and `claude --version` read on 2026-10-14 at plan 10-06 (2.1.299, equal; RQ-1 a) |
| Claude Code | Windows | `bbjcpl`; `bbj-ls` (bbj-local plugin) | Claude Code 2.1.292 | 2026-10-13, 2026-10-14 | 09-WINDOWS-RUN.md:404 (Write, Edit, path with a space, clean file silent; round 2 re-run 2026-10-14), 09-WINDOWS-RUN.md:506 (`claude mcp list` Connected, `bbj_check_syntax` one SyntaxError) |
| Claude Code | macOS | `bbjcpl`; `bbj-ls` (hook) | Claude Code 2.1.296 | 2026-10-14 (`bbjcpl`); 2026-10-12 (`bbj-ls`, 0.2.0 UAT) | 09-MACOS-RUN.md:239 (`bbjcpl reported` after Write and Edit, clean silent; `bbj_home` given), 09-MACOS-RUN.md:272-320 (hook script, tier 2 only: `bbj-local reported`, exit 2; clean exit 0; run directly, not through the client), 06-UAT.md:31-34 (owner's macOS Claude Code, 0.2.0: `bbj-local reported 1 error(s)`, no `bbjcpl` on that machine; client version not recorded there) |
| Codex plugin | Linux | `bbjcpl`; `bbj-ls` (hook) | Codex CLI 0.162.1 | 2026-10-14 | 10-LINUX-RUN.md:38-64 (real compiler `/opt/bbx`, `bbjcpl reported`, clean silent), 10-LINUX-RUN.md:68-101 (no compiler route, BBjServices answering: `bbj-local reported`, clean silent); plumbing with the fake compiler 2026-10-13 in 08-LINUX-RUN.md:112-140 (not a route reading) |
| Codex plugin | Windows | `bbjcpl`; `bbj-ls` (bbj-local plugin) | Codex CLI 0.162.1 | 2026-10-13, 2026-10-14 | 09-WINDOWS-RUN.md:469 (round 2, 2026-10-14: `bbjcpl reported` after apply_patch create and update, clean silent, trust asked again), 09-WINDOWS-RUN.md:528 (`codex mcp list` enabled at `http://127.0.0.1:5009/mcp`, `bbj_check_syntax` one SyntaxError; 2026-10-13) |
| Codex plugin | macOS | `bbjcpl`; `bbj-ls` (hook) | Codex CLI 0.162.1 | 2026-10-14 | 09-MACOS-RUN.md:269 (`BBJ_HOME` in the environment of the Codex process that runs hooks: `bbjcpl reported`, clean silent), 09-MACOS-RUN.md:369 (side-1: the first Codex runs, started without `BBJ_HOME`, gave `bbj-local reported ...` from tier 2; recorded, not counted as the PLAT-05 reading) |
| Codex installer | Linux | `bbjcpl` | Codex CLI 0.162.1 | 2026-10-12 | evidence/codex/result.txt:1-21 (`installer_exit: 0`, `hook_smoke: bad exit 2, clean silent`, `bad_feedback: yes`, `clean_silent: yes`, `hooks_approved: owner, /hooks`), evidence/codex/checks.txt:15-20 (hook smoke with `BBJ_HOME=/opt/bbx`, the real compiler), evidence/codex/events-extract.txt:12-16 (`bbjcpl reported` reached the model). The installer of release 0.2.0; the 0.2.1 installer has no Linux Codex reading (suite fakes only) |
| Codex installer | Windows | `bbjcpl` | Codex CLI 0.162.1 | 2026-10-14 (round 2) | 10-WINDOWS-INSTALLER-RUN.md:166-213 (`Reading 2026-10-14, round 2`: `r1-bad`, `r2-bad`, `r4-bad` start `bbjcpl reported`, `r1-clean` silent, both trusted), verdict 10-WINDOWS-INSTALLER-RUN.md:217 (`D-09: met`). Round 1 (verdict negative) is superseded by round 2 (D-26) and is not quoted |
| Codex installer | macOS | `bbj-ls` (hook) | Codex CLI 0.162.x | 2026-10-12 | 06-UAT.md:36-39 (owner's MacBook, 0.2.0 installer with `--with-local`: `apply_patch` of a bad file blocked with `bbj-local reported 1 error(s) ... [SyntaxError]`, no `bbjcpl` on PATH; clean file no hook output; Codex written "0.162.x" there, RQ-2 a) |

## Facts for the pages

Each fact: the target section (D-04) and the record line. Plan 10-06 writes the rows marked
`Claude Code page` and `README`; plan 10-07 writes the rows marked `Codex page`.

| Fact | Target (D-04) | Source |
|------|---------------|--------|
| Windows, Claude Code 2.1.292: the hook ran the `command` field (`sh "..."`) and ignored `commandWindows` without harm; `bbjcpl reported 1 error(s)` after the Write tool and after the Edit tool, also in a project path with a space; clean file silent | Claude Code page, `## Windows` | 09-WINDOWS-RUN.md:404, 09-WINDOWS-RUN.md:398-402 |
| Windows: the compiler under the drive-letter home `C:\bbx` is found by the `bbj_home` option (`--config bbj_home=C:\bbx`) and mapped with `cygpath -u` to `/c/bbx`; the `-P` list is Windows-form entries joined with `;`; the compiler target is the Windows form with a drive letter; a space in the project path is kept | Claude Code page, `## Windows` | 09-WINDOWS-RUN.md:259-262, 09-WINDOWS-RUN.md:383 |
| Windows: `claude plugin install bbj@basis-bbj --config bbj_home=C:\bbx` was accepted and the install still printed "1 userConfig option not yet set" (`docs_url`, which has a default) | Claude Code page, step 2 (already says two options not yet set stays) | 09-WINDOWS-RUN.md:374 |
| Windows, Claude Code 2.1.292: the `bbj-local` plugin is not listed until installed and enabled; with BBjServices running `claude mcp list` showed `plugin:bbj-local:bbj-local` at `http://127.0.0.1:5009/mcp` Connected and `bbj_check_syntax` returned one SyntaxError diagnostic | Claude Code page, `## Windows` | 09-WINDOWS-RUN.md:506 |
| Windows, hook tier 2 from Git Bash (curl to bbj-ls on 127.0.0.1:5009) printed `bbj-local reported 1 error(s)` with exit 2, clean exit 0 (run as the hook script, not through a client) | Claude Code page, `## Windows` (as the hook's tier 2 sentence) | 09-WINDOWS-RUN.md:586 |
| Windows, no compiler route and nothing listening: the no-route notice printed once, then silent in the same session | Claude Code page, `## Windows` | 09-WINDOWS-RUN.md:656 |
| Windows: Claude Code answered the exact create-file prompt with a Bash shell write twice, so the `Write|Edit` hook never saw the create; after "use the write tool" the Write hook fired | Claude Code page, `## Not covered` (Bash writes); macOS has the same reading | 09-WINDOWS-RUN.md:715 (obs-1), 09-MACOS-RUN.md:371 (side-3) |
| macOS 27.0.1, Claude Code 2.1.296: with the BBj home `<home>/bbx` given as `bbj_home`, `bbjcpl reported 1 error(s)` after Write and Edit, clean silent | Claude Code page, `## macOS` | 09-MACOS-RUN.md:239 |
| macOS: the Mac's BBj home `<home>/bbx` is not among the built-in default homes (`/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx`); the compiler was found only because the home was given (`bbj_home`, `BBJ_HOME`) | Claude Code page, `## macOS` | 09-MACOS-RUN.md:372 (side-4) |
| macOS: `bbjcpl` printed `error at line 10 (1)` for a one-line file; the hook passes the compiler's lines through unchanged, so the number is the compiler's (the Windows record shows the same text) | Claude Code page, `## macOS` | 09-MACOS-RUN.md:371 (side-3) |
| Codex daemon: Codex 0.162.1 runs hooks in its app-server daemon, which keeps the environment it was started with; `BBJ_HOME` (or `bbjcpl` on PATH) must be in the environment of the Codex process that runs hooks; after setting it, stop every Codex process and start Codex again from that shell | Codex page, "Where the hook finds BBj"; `## macOS` | 09-MACOS-RUN.md:369 (side-1) |
| Stale installer `~/.codex/hooks.json` fires next to the plugin hook until `sh codex/install-codex.sh --remove` | Codex page, "Switch from the installer script" | 09-MACOS-RUN.md:370 (side-2) |
| Windows, Codex plugin route: after the plugin's `hooks.json` gained a `commandWindows` entry (short path `C:\PROGRA~1\Git\bin\sh.exe`), Codex asked to trust the hook again; the hook then ran through PowerShell and `bbjcpl reported` for a bad file after apply_patch create and update, clean silent | Codex page, "Upgrading the plugin" and `## Windows` | 09-WINDOWS-RUN.md:461, 09-WINDOWS-RUN.md:469 |
| Windows, Codex plugin route: the shipped string names Git for Windows at its default `C:\Program Files\Git` (short path `PROGRA~1`); a machine with Git elsewhere is not covered by the reading; symptom `hook exited` / "Hook failed" | Codex page, `## Windows` (D-10) | 09-WINDOWS-RUN.md:467 (limit), 09-WINDOWS-RUN.md:432 (symptom) |
| Windows installer round 2: `commandWindows` written as the launcher `C:\Program Files\Git\bin\sh.exe` (no `usr\bin`) and `--sh-exe 'C:\PROGRA~1\Git\bin\sh.exe'` as given; hook trusted, `bbjcpl reported` for a bad file in Codex sessions started from a Start-menu PowerShell window (Git's `usr\bin` not on its PATH) and in R4 from Git Bash, clean silent; `--sh-exe 'C:\nowhere\sh.exe'` and `--sh-exe 'C:\Program Files\Git\usr\bin\sh.exe'` refused with exit 2 and no home created | Codex page, `## Windows` and the installer's closing note | 10-WINDOWS-INSTALLER-RUN.md:213, 10-WINDOWS-INSTALLER-RUN.md:217 |
| Observations only (no requirement, no page claim unless a plan asks): the agent finished R4 by writing the file with Set-Content from the shell, which the hook does not see; the installer printed "codex mcp add ... exited with an error; the table is kept" in round 1 and round 2; Codex app-server daemons held the throwaway home until stopped | none | 10-WINDOWS-INSTALLER-RUN.md:204-211 |
| Linux, Codex plugin: sign-in to `bbj-docs` completed in both clients with the plugin as it ships (2026-10-14), each stored a refresh token | README sign-in paragraph | 10-LINUX-RUN.md:186 |
| Windows and macOS: both sign-ins to the hosted docs server completed (Claude Code `/mcp`, Codex `/mcp login bbj-docs` or `codex mcp login`) | README sign-in paragraph | 09-WINDOWS-RUN.md:677-678, 09-MACOS-RUN.md:363-364 |

## Not run

One line per gap that a page or the CHANGELOG must not turn into a claim. Each names the record
that shows it was not run. Lines 1 to 4 are the D-13 candidates; lines 5 to 8 are further gaps the
records show, offered to plan 10-08.

1. macOS, the `bbj-local` plugin in either client: not run on macOS; only the hook's own tier 2 was seen there. Record: 09-MACOS-RUN.md has no `bbj-local` section (sections at lines 217, 242, 272, 322, 357); the tier 2 smoke is 09-MACOS-RUN.md:272-320; the 0.2.0 UAT is 06-UAT.md:31-39.
2. macOS, the Codex installer on the `bbjcpl` route: not run; the 0.2.0 UAT saw tier 2 only (no `bbjcpl` on that machine). Record: 06-UAT.md:36-39.
3. Every platform, a plugin upgrade through a Git marketplace and across a real release: not run until the D-22 reading (plan 10-11) replaces this line. Record: 08-LINUX-RUN.md:494 ("not run: ... an upgrade through a Git marketplace, and an upgrade across a real release"), 10-LINUX-RUN.md:191 (the before half only).
4. Windows, the Claude Code default home `/c/bbx` and the remaining discovery variables (`BBJHOME`, `PATH` for Claude Code): not run separately; Claude Code was run with `bbj_home=C:\bbx` and Codex with `BBJ_HOME`. Record: 09-CONTEXT.md:71-74 (D-04), 09-WINDOWS-RUN.md:374.
5. Windows, the Codex installer is no longer a Not run line: round 2 is `D-09: met` (10-WINDOWS-INSTALLER-RUN.md:217). What round 2 did not cover: a Git for Windows installed elsewhere than `C:\Program Files\Git` (the machine has the default location; the 8.3 fallback `C:\PROGRA~1\Git\bin\sh.exe` existed there, 10-WINDOWS-INSTALLER-RUN.md:211 note 4).
6. Windows, the Codex plugin route with Git elsewhere (WR-01): not run; the reading names the default location only. Record: 09-WINDOWS-RUN.md:467.
7. Windows and macOS, the hook's tier 2 through the Codex plugin on Windows and the `bbj-local` plugin through the hook on Windows were each seen as a different object: tier 2 as the hook script run from Git Bash (09-WINDOWS-RUN.md:586), the `bbj-local` plugin as a connected server (09-WINDOWS-RUN.md:506, 09-WINDOWS-RUN.md:528). The hook's tier 2 inside a Windows client session was not run.
8. Linux, the 0.2.1 Codex installer with a real Codex: not run; the last Linux installer reading is the 0.2.0 run of 2026-10-12 (evidence/codex/result.txt:1-21). Record: 10-LINUX-RUN.md has no installer section.

## Versions

| Item | Value | Source |
|------|-------|--------|
| Claude Code, Linux | 2.1.299 (read again at the release run; RQ-1 a) | 10-LINUX-RUN.md:22, `claude --version` 2026-10-14 |
| Claude Code, Windows | 2.1.292 | 09-WINDOWS-RUN.md:43 |
| Claude Code, macOS | 2.1.296 | 09-MACOS-RUN.md:46 |
| Codex CLI | 0.162.1 on Linux, Windows and macOS; "0.162.x" for the macOS installer cell (RQ-2 a) | 10-LINUX-RUN.md:23, 09-WINDOWS-RUN.md:44, 09-MACOS-RUN.md:47, 06-UAT.md:39 |
| BBj | 26.03: `/opt/bbx` (Linux), `C:\bbx` (Windows), `<home>/bbx` (macOS) | 10-LINUX-RUN.md:24, 09-WINDOWS-RUN.md:45-46, 09-MACOS-RUN.md:48-49 |
| Git for Windows | 2.52.0.windows.1; Git root `C:\Program Files\Git\` | 09-WINDOWS-RUN.md:40, 10-WINDOWS-INSTALLER-RUN.md:81 |
| OS | Windows 10.0.19045.6466; macOS 27.0.1 (26A434), /bin/sh GNU bash 3.2.57; Linux 6.8.0-138-generic | 09-WINDOWS-RUN.md:39, 09-MACOS-RUN.md:44-45, 10-LINUX-RUN.md:21 |
| Docs server | `https://mcp.bbj-ai.com/mcp`; sign-in completed in Claude Code and Codex on Linux (2026-10-14), Windows (2026-10-13) and macOS (2026-10-14); no server version stated (RQ-3 a) | 10-LINUX-RUN.md:186, 09-WINDOWS-RUN.md:677-678, 09-MACOS-RUN.md:363-364 |
| Run dates | Linux 2026-10-12 (0.2.0 installer), 2026-10-13 (plumbing, fake compiler), 2026-10-14; Windows 2026-10-13, 2026-10-14; macOS 2026-10-12 (0.2.0 UAT), 2026-10-14 | the Cells table |
