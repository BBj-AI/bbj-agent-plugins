---
phase: 10-install-wording-and-release-0-2-1
verified: 2026-10-15T05:00:00Z
status: passed
score: 5/5 must-haves verified
covered_files:
  - ".claude-plugin/marketplace.json"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-01-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-01-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-02-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-02-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-03-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-03-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-04-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-04-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-05-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-05-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-06-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-06-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-07-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-07-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-08-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-08-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-09-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-09-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-10-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-10-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-11-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-11-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-12-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-12-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-13-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-13-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-14-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-14-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-15-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-15-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-16-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-16-SUMMARY.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-17-PLAN.md"
  - ".planning/phases/10-install-wording-and-release-0-2-1/10-17-SUMMARY.md"
  - "CHANGELOG.md"
  - "README.md"
  - "codex/install-codex.sh"
  - "docs/install-claude-code.md"
  - "docs/install-codex.md"
  - "plugins/bbj-local/.claude-plugin/plugin.json"
  - "plugins/bbj/.claude-plugin/plugin.json"
  - "plugins/bbj/.codex-mcp.json"
  - "plugins/bbj/.codex-plugin/plugin.json"
  - "plugins/bbj/.mcp.json"
  - "tests/fake-bin/cygpath"
  - "tests/test_install_codex.sh"
  - "tests/test_install_pages.sh"
  - "tests/test_layout.py"
  - "tests/test_release_text.py"
  - "tests/test_release_text_mutation.sh"
covered_digest: "v3:sha256:8c31622691d754a89025386ab618bb004ccda18bbef2cf1e822d10d825ddcfd9"
behavior_unverified: 0
overrides_applied: 0
re_verification: false
---

# Phase 10: Install wording and release 0.2.1 Verification Report

**Phase Goal:** Users read, per client, platform and check route, exactly what was verified, and nothing more than the recorded runs show. For Codex the plugin route comes first and the installer is the fallback. Release 0.2.1 ships with that wording, the Codex plugin route, the 0.2.0 review fixes and the Phase 9 fixes.
**Verified:** 2026-10-15
**Status:** passed (with warnings, none a must-have failure)
**Re-verification:** No, initial verification

The starting hypothesis was that the goal was missed. I tried to falsify it against the shipped tree (the working tree outside `.planning/` is identical to `origin/main` at `4234e76`: `git diff origin/main -- . ':!.planning'` is empty), the git and GitHub state, and the recorded runs. Nothing falsified a roadmap success criterion. Six warnings are listed below.

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | README states, for Claude Code and Codex, the verified platforms and check routes with client and BBj versions; Codex leads with the plugin route and names `install-codex.sh` as the fallback; no "not yet run" for a run configuration (DOCS-01) | VERIFIED | `README.md` "Verified" section: a 3x3 table (Claude Code / Codex plugin / Codex installer by Linux / Windows / macOS), each cell naming routes and client version, BBj 26.03 stated once. Install section shows `codex plugin add bbj@basis-bbj` first; the Codex bullet calls the installer script "the fallback". Old-hint grep over README, both pages, installer and manifests finds none (only `CHANGELOG.md` 0.2.0 history lines keep "pre-production", as D-05 allows). Cells traced to `10-VERIFIED-MATRIX.md` and the underlying records (`10-LINUX-RUN.md`, `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-WINDOWS-INSTALLER-RUN.md`, `06-UAT.md`). The Windows installer cell rests on a round-2 reading with verdict `D-09: met`; the round-1 negative reading is retained as superseded history. |
| 2 | Windows and macOS sections of both pages describe the steps run, plugin route first for Codex; "not run" only for configurations not run; installer `STATUS_LINE` and closing notes say the same as the docs (DOCS-02, DOCS-03) | VERIFIED | `docs/install-codex.md` has "Install with the Codex plugin (recommended)" before "Fallback: the installer script", `## Windows` and `## macOS`. `docs/install-claude-code.md` has `## Windows` and `## macOS`. Every "Not run" sentence names a configuration absent from the records (macOS `bbj-local` plugin; macOS installer on `bbjcpl`; Windows Git elsewhere; Windows Claude Code discovery variables). `STATUS_LINE` (`codex/install-codex.sh:175`) is quoted byte for byte on the Codex page and in the CHANGELOG; gates `release_status_line_in_page`, `first_status_banner` pass. Closing "Known gaps" (`install-codex.sh:1418-1424`) names the launcher `bin\sh.exe` and `--sh-exe PATH`, as the page does. |
| 3 | `tests/test_install_codex.sh` and `tests/test_release_text.py` fail if an old "not yet run" hint returns or installer text and docs drift (DOCS-04) | VERIFIED | `tests/test_release_text.py` defines `OLD_HINTS` (line 252) and gate `no_unrun_hint`; `tests/test_install_pages.sh:83` forbids the same phrases independently; `tests/test_release_text_mutation.sh` injects each old hint into README and both pages and requires the gate to fail (lines 193-198). I ran `python3 -I tests/test_release_text.py`, `tests/test_layout.py`, `sh tests/test_install_pages.sh` and `sh tests/test_release_text_mutation.sh`: no non-ok line. The pinned `UPGRADE_QUOTES` and `NOT_RUN_LINES` match the CHANGELOG 0.2.1 entry. |
| 4 | Both plugins, both marketplace entries, the Codex overlay and `tests/test_layout.py` read 0.2.1; `claude plugin validate --strict` passes; the `## 0.2.1` CHANGELOG "Tested against" covers Linux, Windows and macOS from recorded runs (REL-07) | VERIFIED | `origin/main`: `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`, `plugins/bbj/.codex-plugin/plugin.json` and both entries in `.claude-plugin/marketplace.json` are `"version": "0.2.1"`; `tests/test_layout.py` has `VERSION = "0.2.1"`; README line states version 0.2.1. `ci_validate_root`, `ci_validate_plugins_bbj` and `ci_validate_plugins_bbj_local` are ok in `evidence/pr-b-checks.txt`. CHANGELOG 0.2.1 "Tested against" has dated lines per client for Linux, Windows and macOS, each of which has a matching record entry. |
| 5 | Full suite passes on the release tree with live gates at skip=0; owner confirmation before each push, merge, tag push and Release; PR merged, annotated tag `0.2.1` (no `v`) pushed, GitHub Release published (REL-08) | VERIFIED | Independent rerun this session: `sh tests/run.sh` printed `SUMMARY: ok=979 fail=0 skip=0`, exit 0. Release run recorded in `evidence/pr-b-checks.txt` (`CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=<codex> sh tests/ci.sh`): `SUMMARY: ok=979 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; no `skip` or `FAIL` gate lines. PR #2 and PR #3 are `MERGED` (`gh pr view`), as merge commits with two parents (`dad18f5`, `4234e76`; `evidence/merge.txt`, `merge-b.txt`). `git ls-remote --tags origin` lists `refs/tags/0.2.1` (object `9e0d1848`) and its peel `4234e76`, which equals `origin/main`; `git cat-file -t 0.2.1` is `tag`; tagger message `basis-bbj 0.2.1`; no `v0.2.1` or any `v*` tag locally or on origin. `gh release view 0.2.1`: `isDraft:false`, `isPrerelease:false`, published 2026-10-15T04:15:57Z. Release body equals the 0.2.1 CHANGELOG entry on `origin/main` (diff is one trailing blank line). Owner replies are recorded: "merge" (PR #2, PR #3) and "publish" (tag push and Release, `10-14-SUMMARY.md`). |

**Score:** 5/5 truths verified (0 behavior-unverified).

### Behavior-dependent truths

The installer behaviours (`commandWindows` call form, `--sh-exe`, early refusals) are state transitions on a Windows host that CI cannot see. They are covered two ways: gates on the fake `cygpath` in `tests/test_install_codex.sh` (green in the rerun), and the owner's round-2 Windows reading (`10-WINDOWS-INSTALLER-RUN.md`, `D-09: met`: launcher written, override written as given, hook trusted, `bbjcpl reported` in PowerShell-started sessions, both refusals exit 2 with no home created). I reproduced the refusal and write path on the fake `cygpath` in a scratch directory (see WR-01 below). No truth is left as present-only.

### Context decisions honored

| Decision | Result |
|----------|--------|
| D-02 per-platform Claude Code versions (2.1.292 Windows, 2.1.296 macOS, Linux re-read as 2.1.299 under amendment RQ-1) | Honored; pages, README and CHANGELOG use the same version per platform. |
| D-03 banner "Verified on Linux, Windows and macOS" on both pages | Honored (first lines of both pages). |
| D-05 no pre-production wording in shipped texts | Honored; `plugin.json` `docs_url` description reads "the hosted BBj docs server". Released 0.2.0 entry untouched. |
| D-06/D-07/D-08, D-27 to D-29 installer `commandWindows` form, early refusal, `--sh-exe`, launcher `bin\sh.exe` | Honored in `codex/install-codex.sh` (see WR-01 for one bypass). |
| D-16 `oauth.scopes` | `"scopes": "offline_access"` is in `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`; sign-in readings recorded in `10-LINUX-RUN.md`. |
| D-22/D-23 Git-marketplace upgrade reading, amendment PR, tag on the second merge | Honored; tag peels to M2 `4234e76`, not the first merge `dad18f5`. |
| D-25 owner confirmation before every push, merge, tag push, Release | Recorded in evidence and summaries. |

### Requirements Coverage

All six phase IDs are claimed by at least one PLAN `requirements:` field and exist in `REQUIREMENTS.md`. No orphaned requirement maps to Phase 10.

| Requirement | Source Plans | Status | Evidence |
|-------------|--------------|--------|----------|
| DOCS-01 | 10-02, 10-04, 10-06 | SATISFIED (see WR-05) | README table, plugin route first, fallback named (truth 1) |
| DOCS-02 | 10-01, 10-03, 10-05, 10-06, 10-07, 10-11, 10-15, 10-16, 10-17 | SATISFIED | Truth 2 |
| DOCS-03 | 10-01, 10-03, 10-05, 10-07, 10-15, 10-16, 10-17 | SATISFIED | Truth 2 |
| DOCS-04 | 10-06, 10-07 | SATISFIED | Truth 3 |
| REL-07 | 10-02, 10-04, 10-08, 10-09, 10-11, 10-12 | SATISFIED | Truth 4 |
| REL-08 | 10-03, 10-04, 10-09 to 10-14, 10-16 | SATISFIED | Truth 5 |

### Anti-Patterns Found

None blocking. No `TBD`, `FIXME` or `XXX` markers were introduced in the files above. The only "pre-production" hits are in released 0.2.0 CHANGELOG lines, which are history by D-05.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Whole suite, release tree | `sh tests/run.sh` | `SUMMARY: ok=979 fail=0 skip=0`, exit 0 | PASS |
| Release-text and layout gates | `python3 -I tests/test_release_text.py; python3 -I tests/test_layout.py` | 51 ok lines, no non-ok line | PASS |
| Page and mutation gates | `sh tests/test_install_pages.sh; sh tests/test_release_text_mutation.sh` | no non-ok line | PASS |
| Tag is annotated, no `v`, peels to `origin/main` | `git cat-file -t 0.2.1; git rev-parse 0.2.1^{} origin/main` | `tag`; both `4234e76` | PASS |
| Release not draft or prerelease | `gh release view 0.2.1` | both false | PASS |
| Installer `--sh-exe` guard | fake `cygpath`, scratch HOME, 3 spellings | canonical `usr\bin` refused (exit 2); two non-canonical spellings accepted (exit 0) | WARNING (WR-01) |

### Probe Execution

SKIPPED: the phase declares no `probe-*.sh`; the Windows and Linux runs are recorded readings, not probes.

## Warnings (not must-have failures)

These are the findings I could not turn into a failed roadmap truth, but a maintainer should see them.

1. **WR-01 (confirmed, code review WR-01): the `usr\bin` guard is bypassable.** `--sh-exe 'C:\Git\usr\\bin\sh.exe'` and `'C:\Git\usr\bin\.\sh.exe'` exit 0 and write a `usr\bin` launcher into `commandWindows`. This is the configuration the refusal exists to stop. The page and CHANGELOG say the installer "refuses ... an `sh.exe` in `usr\bin`"; that holds for the plain spellings that the Windows run used, not for these. Narrow (a user-typed odd path), so it does not contradict SC2, but fix it in a follow-up.
2. **WR-02 (code review WR-02, not reproduced by me, reviewer reproduced it): `--remove` keeps `hooks.json` when the recorded `sh.exe` no longer exists.** The switch-to-plugin guidance on the Codex page promises `--remove` removes `hooks.json` "when it holds only the installer's hook"; on a machine where Git moved, it is left and both hooks run. The page covers only the 0.2.0 `commandWindows` form as a hand step, not this case.
3. **WR-03 (code review): weak assertions.** `command_windows_remove_unaffected` and `command_windows_sh_exe_chars_refused` check exit code or the generic suffix only, so WR-01 and WR-02 are not pinned.
4. **README cell for Claude Code on macOS carries more than one reading.** `bbj-ls (hook); Claude Code 2.1.296` rests on (a) the hook script run directly, 2026-10-14 (`09-MACOS-RUN.md` tier 2 smoke), and (b) the owner's 0.2.0 Claude Code run of 2026-10-12, where the Claude Code version is not recorded (`06-UAT.md` test 5). The README gives no date and no "run directly" qualifier; the Claude Code page ("the hook run on its own") and the CHANGELOG do. It is not false, but it is the loosest cell of the "nothing more than the records show" goal. Suggest adding "(0.2.0, 2026-10-12)" or the qualifier to the cell.
5. **Tracking not updated:** `.planning/REQUIREMENTS.md` still shows DOCS-01 as `[ ]` and "Pending" in the traceability table (DOCS-02, DOCS-03, DOCS-04, REL-07, REL-08 are ticked). `10-06-SUMMARY.md` records no completed requirements. `ROADMAP.md` still shows Phase 10 as `[ ]`. The orchestrator should tick DOCS-01 and the phase when it closes the phase; the codebase state satisfies DOCS-01.
6. **Info items IN-01 to IN-04 (code review, all open):** a late `refuse` after pre-flight writes; the page and CHANGELOG list the `--sh-exe` refusals incompletely (no character-class or "cygpath cannot convert" reason); typographic quotes not filtered; the installer's OAuth table deliberately or accidentally omits `scopes` with no gate. None contradicts a must-have. `10-REVIEW-DISPOSITION.md` has all seven findings at `open`; they are follow-up items.

## Human Verification Required

None. The Windows installer route that CI cannot reach was already read by the owner on a real machine (round 2, `D-09: met`), and since the commit the owner ran (`51fc5c2`) the installer's non-comment lines changed only in `STATUS_LINE` and two closing-note lines (`git diff 51fc5c2 origin/main -- codex/install-codex.sh`); the install logic is the one that was read.

## Gaps Summary

No gaps. The phase goal is met: the per-client, per-platform, per-route wording is traceable to recorded runs, the Codex plugin route comes first with the installer as fallback, gates pin both the wording and the installer-to-page quotes, and 0.2.1 is merged, tagged (annotated, no `v`, on the final merge commit) and published with a body equal to the CHANGELOG entry. The open code-review warnings and the README macOS cell nuance are follow-ups for the next milestone, not blockers.

---

_Verified: 2026-10-15T05:00:00Z_
_Verifier: Claude (gsd-verifier)_
