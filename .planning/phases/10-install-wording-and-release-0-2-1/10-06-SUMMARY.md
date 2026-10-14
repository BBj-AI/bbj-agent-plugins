---
phase: 10-install-wording-and-release-0-2-1
plan: 06
subsystem: install-wording-readme-and-claude-code-page
tags: [docs, readme, claude-code, verified-matrix, release-text-gate, mutation-tests]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-04 Linux readings (10-LINUX-RUN.md); plan 10-17 Windows installer round 2 (D-09: met); plan 10-05/10-15/10-16 history"
provides:
  - "10-VERIFIED-MATRIX.md: nine cells, facts for the pages with D-04 targets, eight Not run lines, versions, each with a record line"
  - "README: ## Verified section with the platform table (three rows), hosted-server wording, sign-in readings by platform, install-page bullets pointing at the table, a Not run paragraph"
  - "docs/install-claude-code.md: Verified banner with per-platform versions and dates, rewritten ## Windows, new ## macOS, hosted-server wording, Bash-write observation under Not covered"
  - "tests/test_release_text.py: per-platform release_claude_version_single, release_no_unrun_hint (HINT_FILES, OLD_HINTS, PLATFORMS)"
  - "tests/test_release_text_mutation.sh: mutate takes a case name; cases claude_version_single_readme, no_unrun_hint_readme, no_unrun_hint_claude_page"
  - "tests/test_install_pages.sh: banner and version pins, check_released_wording (old_platform_hints, docs_server_stage), readme_codex_plugin_first"
affects: [10-07, 10-08, 10-09]

actuals:
  tokens: 8200
  tasks: 3
  commits: 3

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/10-VERIFIED-MATRIX.md
  modified:
    - README.md
    - docs/install-claude-code.md
    - tests/test_install_pages.sh
    - tests/test_release_text.py
    - tests/test_release_text_mutation.sh

key-decisions:
  - "D-02 as amended by RQ-1: the Linux Claude Code version is 2.1.299 (10-LINUX-RUN.md:22, equal to claude --version today), not the 2.1.296 that D-02 named; Windows 2.1.292, macOS 2.1.296"
  - "D-26: the Windows installer cell and the README note follow the round-2 reading (D-09: met, plan 10-17); the round-1 negative verdict is not quoted as current"
  - "A route is named in a cell only when its Sources entry shows it; (hook) marks the hook's tier 2, (bbj-local plugin) marks the plugin connected with bbj_check_syntax answering"
  - "RQ-2: the macOS installer cell says Codex CLI 0.162.x and the bbj-ls (hook) route only"

patterns-established:
  - "One matrix file feeds every shipped platform sentence; a fact enters a page only with its record line"
  - "Two independent hint bans (test_install_pages.sh forbids and release_no_unrun_hint) with mutation cases for both"
  - "mutate GATE FILE SED [CASE] for a gate with more than one mutation case"

requirements-completed: []
requirements-advanced: [DOCS-01, DOCS-02, DOCS-04]

completed: 2026-10-14
status: complete
plan_head_before: 3b6914cda8b3436718dc60cdd82ea92fa88c3ebe
plan_head_after: bfcfcd647ea4eee992c25ed826734d091377adf5
commits: 3
---

# Phase 10 Plan 06: README and Claude Code page state the verified platforms Summary

**README now carries a Linux/Windows/macOS table of verified routes and client versions, the Claude Code page has a per-platform banner, a record-backed Windows section and a new macOS section, and two independent gates (plus mutation cases) stop the old "not yet run" hints from coming back.**

## README table as written

Header and rows (under `## Verified`, BBj 26.03 stated once in the caption):

```
| Client | Linux | Windows | macOS |
| Claude Code | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.299 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Claude Code 2.1.292 | `bbjcpl`, `bbj-ls` (hook); Claude Code 2.1.296 |
| Codex plugin | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (bbj-local plugin); Codex CLI 0.162.1 | `bbjcpl`, `bbj-ls` (hook); Codex CLI 0.162.1 |
| Codex installer | `bbjcpl`; Codex CLI 0.162.1 | `bbjcpl`; Codex CLI 0.162.1 | `bbj-ls` (hook); Codex CLI 0.162.x |
```

Below the table a "Not run, so not claimed" paragraph names: on macOS the `bbj-local` plugin in either client and the Codex installer on the `bbjcpl` route; on Windows the Codex plugin route with Git elsewhere than the default location; on Linux the Codex installer as changed since 0.2.0 (its cell is the 2026-10-12 run). It also states the Windows installer outcome from round 2 (launcher `bin\sh.exe`, hook blocked a bad file with the `bbjcpl` report in a PowerShell-started session, 2026-10-14) and points at the Codex page for details.

## Per-platform version sets printed by the gate

`gate release_claude_version_single ok ... Linux ['2.1.299'], Windows ['2.1.292'], macOS ['2.1.296']`

## Verification

- `python3 -I tests/test_release_text.py`: 12 gates ok, including `release_claude_version_single` and `release_no_unrun_hint`.
- `sh tests/test_release_text_mutation.sh`: all ok, including `release_mut_claude_version_single`, `release_mut_claude_version_single_readme`, `release_mut_no_unrun_hint_readme`, `release_mut_no_unrun_hint_claude_page`, `release_mut_later_unpinned` (exactly two FAIL lines at 9.9.9), `release_mut_later_repinned`.
- `sh tests/test_install_pages.sh`: no FAIL; `claude_forbids_old_platform_hints`, `claude_forbids_docs_server_stage`, `readme_forbids_old_platform_hints`, `readme_forbids_docs_server_stage`, `readme_codex_plugin_first`, `readme_forbids_hook_trust_bypass`, the banner pins on both files, `## Windows` and `## macOS` ok. shellcheck -s sh clean on both shell tests.
- Full suite on the tree of the Task 3 commit: `SUMMARY: ok=959 fail=0 skip=0`.
- Tracer gate (type tracer, auto mode active, no blocking-human gate): `<verify>` re-run after the Task 1 commit passed, so expansion proceeded.

## Accomplishments

- Task 1 (f367e35): 10-VERIFIED-MATRIX.md from the records (every Sources entry a file:line, line numbers re-checked against the files); README `## Verified` with header and Claude Code row; Claude Code page Requirements sentence names one version per platform; `claude_version_single` replaced by the per-platform form that also parses the README table row by the header's columns; `mutate` takes a case name; two version cases.
- Task 2 (5234760): README Codex rows, hosted-server wording (no stage or go-live clause), sign-in observed per platform, install-page bullets point at the table; Claude Code page banner, `## Windows` rewritten from the records with "Observed on ... with ..." lines and two "Not run" sentences, new `## macOS` (BBj home outside the default list and `bbj_home`/`BBJ_HOME`, the compiler's `line 10`, tier 2 smoke, Not run for the `bbj-local` plugin); page pins and forbids in `tests/test_install_pages.sh`.
- Task 3 (bfcfcd6): `release_no_unrun_hint` over README and the Claude Code page, two mutation cases, full suite.

## Deviations from Plan

**1. [Rule 3 - Blocking] Plan verify names two page gates that do not exist.** The Task 2 automated check expects `claude_has___macOS` and `claude_has___Windows`; the `slug` helper turns `## macOS` into `___macOS`, so the gates are `claude_has____macOS` and `claude_has____Windows` (both ok). The plan's literal command line would report them missing; the check was run with the real names, all other named gates as written.

**2. [Records over plan] Linux Claude Code version.** D-02 text says 2.1.296 on Linux and macOS; RQ-1 (owner, plan 10-03) replaced the Linux half with "the version that runs the 0.2.1 Linux checks, read when the wording is written". 10-LINUX-RUN.md:22 and `claude --version` on 2026-10-14 both read 2.1.299, so Linux is 2.1.299.

**3. [Records over plan] Windows installer and Linux installer cells.** The plan's interface text allows "met, tested negative, not run"; the latest round (round 2, plan 10-17) is `D-09: met`, so the cell is `bbjcpl; Codex CLI 0.162.1` with the README note above. The Linux installer cell follows evidence/codex/checks.txt (real compiler, `BBJ_HOME=/opt/bbx`, 2026-10-12), not the "(fake)" of the CONTEXT example; because that run is the 0.2.0 installer, the README says so in its Not run paragraph.

**4. [Rule 2 - transparency] Removed an unobserved sentence.** The old Windows section said that without Git for Windows the hook fails on every edit with a non-blocking notice; no record shows this (the Windows machine had Git), so it is not in the rewritten section. Added the README "Not run, so not claimed" paragraph because the plan's prohibition requires a configuration not run to be said so.

**5. [Scope] Requirements not marked complete.** DOCS-01, DOCS-02 and DOCS-04 span the Codex page and the installer text (plan 10-07), so they are recorded as advanced here and `requirements.mark-complete` was not run; plan 10-07 closes them.

## Known Stubs

None.

## Threat Flags

None. No new endpoint, auth path or file access; shipped text only, and the hook-trust bypass flag stem stays forbidden on README (`readme_forbids_hook_trust_bypass` ok).

## For plan 10-07 and later

- Windows installer wording: use the round-2 Sentence for the docs and `D-09: met`; round 1 is superseded. Scope is one Windows machine (Windows 10 19045, Git 2.52.0, Codex 0.162.1, BBj 26.03); Codex was started from Start-menu PowerShell (R1, R2) and Git Bash (R4); Git `usr\bin` was not on PATH on that machine anyway.
- The README says "the details are on the Codex page" for the Windows installer: plan 10-07 must carry them (matrix `## Facts for the pages`, rows marked Codex page).
- `release_claude_version_single` reads `Claude Code N on <platform>` in README, both pages, the installer and the whole newest CHANGELOG entry (plan 10-08 must use that form with the same three versions), and the README table row. At the release run (plan 10-09) re-read `claude --version`; if it changed, re-pin the one Linux token in the README row, the page banner and Requirements sentence, the `Claude Code 2.1.299 on Linux` pin in `tests/test_install_pages.sh`, the matrix and the CHANGELOG in one commit (RQ-1).
- Plan 10-07 should add `docs/install-codex.md` and `codex/install-codex.sh` to `HINT_FILES` in `tests/test_release_text.py` and call `check_released_wording` for the Codex page in `tests/test_install_pages.sh`; `OLD_HINTS` and the shell ERE list must stay the same phrases. Today the installer still holds `not yet run on Windows or macOS` (STATUS_LINE) and `not yet tried` (closing note).
- Matrix `## Not run` lines 1 to 4 are the D-13 candidates (line 4 and the Windows installer line adjusted: the Windows installer is no longer a Not run line); lines 5 to 8 are further gaps offered to plan 10-08.
- Observations only, no requirement or docs claim: the agent bypassed the hook with Set-Content in R4; the installer's "codex mcp add ... exited with an error; the table is kept" message recurs; Codex daemons held the throwaway home.
- Git marketplace upgrade (D-22) is still "before half" only in 10-LINUX-RUN.md:191; Not run line 3 stays until plan 10-11.

## Self-Check: PASSED

- 10-VERIFIED-MATRIX.md, README.md, docs/install-claude-code.md, tests/test_install_pages.sh, tests/test_release_text.py, tests/test_release_text_mutation.sh exist; f367e35, 5234760 and bfcfcd6 are ancestors of HEAD.
