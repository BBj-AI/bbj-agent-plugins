---
phase: 10-install-wording-and-release-0-2-1
plan: 07
subsystem: install-wording-codex-page-and-installer
tags: [docs, codex, installer, status-line, verified-matrix, release-text-gate, mutation-tests]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-06 verified matrix, README and Claude Code page, check_released_wording, mutate with case name; plan 10-15 installer launcher and --sh-exe; plan 10-17 Windows installer round 2 (D-09: met)"
provides:
  - "codex/install-codex.sh: STATUS_LINE and header naming Linux, Windows and macOS with route, date and Codex version; Known-gaps Windows line from the round-2 outcome; closing line naming the plugin route as the recommended install"
  - "docs/install-codex.md: Verified banner, plugin-route banner with the real-compiler reading, hosted-server wording, Phase 9 facts under their route headings, --sh-exe row and refusals, rewritten Windows section, new macOS section, the quoted STATUS_LINE"
  - "tests: first_status_banner read from the installer, first_known_gaps_windows, first_no_unrun_hint, first_names_plugin_route, codex_plugin_route_first, release_status_line_in_page, release_no_unrun_hint over four files, three new mutation cases"
affects: [10-08, 10-09, 10-11]

actuals:
  tokens: 9400
  tasks: 3
  commits: 3

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - docs/install-codex.md
    - tests/test_install_codex.sh
    - tests/test_install_pages.sh
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh

key-decisions:
  - "D-12 / D-26: the Windows clause of STATUS_LINE and of the Codex Windows section follow round 2 of 10-WINDOWS-INSTALLER-RUN.md (D-09: met); round 1 is not quoted as current"
  - "RQ-2: the macOS clause says Codex CLI 0.162.x and the bbj-local route; 0.162.1 is attached to Linux and Windows only"
  - "The STATUS_LINE says 'compiler route', not the compiler name: tests/test_static_guards.sh forbids that name on executable lines of the installer"

patterns-established:
  - "One STATUS_LINE value: read from the installer by sed in the installer test and by regex in the release-text gate, quoted verbatim on the page"
  - "A page sentence that quotes an installer message stays on one line, because the quoted-message loop greps line by line"

requirements-completed: [DOCS-02, DOCS-03, DOCS-04]

completed: 2026-10-14
status: complete
plan_head_before: 9cc7f2b301f5ed4e4e730e23f0baca02dc9490c1
plan_head_after: 9204b8d5abd6d083a7638422fb41e5c96a411297
commits: 3
---

# Phase 10 Plan 07: Codex page and installer state the verified platforms Summary

**The installer prints one STATUS_LINE naming Linux, Windows and macOS with route, date and Codex version; the Codex page quotes it byte for byte, gains a record-backed Windows section and a new macOS section, and gates plus mutation cases stop the old "not yet run" hints from returning to any of the four shipped texts.**

## Final STATUS_LINE

```
Verified with Codex CLI 0.162.1 on Linux (2026-10-12, compiler route) and on Windows (2026-10-14, compiler route, Git for Windows 2.52.0), and with Codex CLI 0.162.x on macOS (2026-10-12, bbj-local route).
```

It is printed first, and again as the line before the exit. The header comment of the installer says the same facts with the run details.

## New Known-gaps and closing lines (installer stdout)

```
- On Windows the hook command (commandWindows) names the launcher bin\sh.exe of the Git for Windows this script ran under; give --sh-exe PATH (a Windows path with a drive letter, written as given) when your Git for Windows is installed elsewhere. Run so far with Git for Windows 2.52.0 at C:\Program Files\Git only.

Recommended install: the Codex plugin (codex plugin add bbj@basis-bbj, see docs/install-codex.md); this script is the fallback for this release.
```

The old line ("commandWindows in hooks.json is not yet tried on Windows; ... command_windows in config.toml") is gone; no `command_windows` hint remains on the page or in the installer (D-10).

## Verification

- `sh tests/run.sh` on the final tree: `SUMMARY: ok=979 fail=0 skip=0` (959 at the end of plan 10-06).
- shellcheck -s sh clean on the installer and every `tests/*.sh`.
- `python3 -I tests/test_release_text.py`: no FAIL; `release_status_line_in_page`, `release_codex_version_single`, `release_no_unrun_hint` (four files), `release_upgrade_quotes` ok.
- `sh tests/test_release_text_mutation.sh`: no FAIL; new cases `release_mut_status_line_in_page`, `release_mut_no_unrun_hint_codex_page`, `release_mut_no_unrun_hint_installer` ok.
- `sh tests/test_install_pages.sh`: no FAIL; `codex_forbids_old_platform_hints`, `codex_forbids_docs_server_stage`, `installer_forbids_old_platform_hints`, `installer_forbids_docs_server_stage`, `codex_plugin_route_first`, `codex_quoted_messages_in_installer` (14 fragments, count now computed) ok.
- `sh tests/test_install_codex.sh`: no FAIL; `first_status_banner`, `first_known_gaps_windows`, `first_no_unrun_hint`, `first_names_plugin_route`, `first_prints_gaps` ok.
- Tracer gate (type tracer, auto mode active, no blocking-human gate): the Task 1 `<verify>` checks were re-run after the commit and passed before expansion.

## Accomplishments

- Task 1 (6ee30e9): D-12 STATUS_LINE and header; `first_status_banner` compares the first stdout line with the value read from the installer; the Codex page quotes the line in the Fallback section; gate `release_status_line_in_page` with a mutation case.
- Task 2 (96bab5f): Codex page rewritten from the matrix: top banner per route and platform, plugin-route banner (Linux real-compiler reading of plan 10-04 replaces the stand-in sentence), hosted BBj docs server wording, `commandWindows` note under "Trust the hook in /hooks", sign-in observations per platform, daemon environment under "Where the hook finds BBj" ("stop every Codex process"), Windows re-trust under "Upgrading the plugin", macOS stale hooks.json and the 0.2.0 Windows `--remove` hand step under "Switch from the installer script", the "trial" wording removed, `--sh-exe PATH` row and the exit-2 refusals, `## Windows` (symptom `hook exited`, the 8.3 path and its limit, the installer alternative with the round-2 outcome, plugin route and `bbj-local` observations, cygpath facts, WR-02), new `## macOS`. Page pins, `check_released_wording codex`, `codex_plugin_route_first`.
- Task 3 (9204b8d): installer Known-gaps Windows line and the closing line; `first_known_gaps_windows`, `first_no_unrun_hint`, `first_names_plugin_route`; `HINT_FILES` over four files; `check_released_wording installer`; two mutation cases; full suite.

## Deviations from Plan

**1. [Rule 1 - static guard] STATUS_LINE cannot name the compiler.** The first STATUS_LINE said "bbjcpl route"; `static_compiler_name_install-codex.sh` (tests/test_static_guards.sh) fails on that name on any non-comment installer line. The line says "compiler route" instead, in the installer and in the quote on the page. Found by the full suite after Task 3 and fixed before the Task 3 commit, so no committed state is red.

**2. [Rule 3 - gate names] Plan verify names two page gates that do not exist.** The Task 2 check expects `codex_has___macOS` and `codex_has___Windows`; the slug helper makes them `codex_has____macOS` and `codex_has____Windows` (both ok), as plan 10-06 noted for the Claude Code page. The banner pin is `codex_has_Verified_on_Linux__Windows_and_macOS`.

**3. [Order] The Windows quoted fragment sits in Task 3, its page text in Task 2.** The page's installer step 6 quotes the Known-gaps fragment `names the launcher bin\sh.exe of the Git for Windows this script ran under`; the installer line and the loop entry arrive with Task 3, so the Task 2 commit alone quotes a line the installer prints from the next commit on. The loop entry was added in the same commit as the installer line, so no committed state fails a gate.

**4. [Records over plan] Round 2 verdict.** The plan allows a negative or not-run Windows clause; the latest round is `D-09: met`, so the clause is positive and scoped to the one machine (Windows 10 build 19045, Git for Windows 2.52.0 at its default location, Codex 0.162.1, BBj 26.03; Codex started from Start-menu PowerShell, and in an optional run from Git Bash).

**5. [Records over plan] Observations kept out.** The Set-Content bypass in the optional Git Bash run, the recurring "codex mcp add ... exited with an error; the table is kept" message and the Codex daemons holding the throwaway home are not on the page or in the installer (matrix "observations only").

**6. [Plan wording] "elsewhere the hook does not start".** D-10 says it; the records say only that Git elsewhere is not covered (09-WINDOWS-RUN.md:467). The page says "Not run: Git for Windows installed anywhere else", gives the inference (the path would not exist there) and says to expect the same `hook exited` symptom. WR-02 (the 30 s timeout against 5 s connect timeout per file) is stated as following from the two timeouts and not observed in a run.

**7. [Scope] Requirements.** DOCS-02, DOCS-03 and DOCS-04 are marked complete by this plan, as plan 10-06 left them advanced.

## Known Stubs

None.

## Threat Flags

None. No new endpoint, auth path or file access; shipped text and tests only. `codex_forbids_hook_trust_bypass` still ok on the Codex page. T-10-16 is mitigated by `release_status_line_in_page`, `first_status_banner`, the quoted-message loop and the mutation cases; T-10-17 by writing the Windows clause from the round-2 record and omitting any `config.toml` `command_windows` hint.

## For plan 10-08 and later

- `UPGRADE_QUOTES` (the three 0.2.0 quotes) are still on non-comment installer lines and in `NOT_RUN_LINES`/`CONTENT_VERSION` pins; plan 10-08 re-pins them. The CHANGELOG may quote the STATUS_LINE or the Known-gaps Windows line byte for byte (D-14); the STATUS_LINE is the one in this summary and `release_status_line_in_page` ties it to the Codex page, not to the CHANGELOG.
- `release_claude_version_single` also reads the Codex page and the installer for `Claude Code N on <platform>`; neither holds such a string today. The newest CHANGELOG entry must use that form with 2.1.299 (Linux), 2.1.292 (Windows), 2.1.296 (macOS).
- The Codex page "Upgrading the plugin" ends with "Not run: an upgrade through a Git marketplace, and an upgrade across a real release." Plan 10-11 updates it after the D-22 reading (RQ-5 a).
- Matrix `## Not run` lines 5 to 8 are on the Codex page where they concern it: Git elsewhere for the plugin route (Windows section), the `bbj-local` plugin in Codex on macOS and the installer on the `bbjcpl` route (macOS section), the hook's second route inside a Codex session on Windows. The Linux 0.2.1 installer with a real Codex (line 8) is not stated on the page; the README Not run paragraph has it.
- Gate prefixes used: `first_`, `codex_`, `installer_`, `release_`, `release_mut_` only, all existing.
- The installer's STATUS_LINE moved from line 169 to line 175 (header comment grew); nothing pins the line number.

## Self-Check: PASSED

- codex/install-codex.sh, docs/install-codex.md, tests/test_install_codex.sh, tests/test_install_pages.sh, tests/test_release_text.py, tests/test_release_text_mutation.sh exist; 6ee30e9, 96bab5f and 9204b8d are ancestors of HEAD.
