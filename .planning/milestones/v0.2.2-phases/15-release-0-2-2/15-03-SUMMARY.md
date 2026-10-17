---
phase: 15-release-0-2-2
plan: 03
subsystem: release
tags: [changelog, version-bump, release-text-gates, manifests]

requires:
  - phase: 15-release-0-2-2 (plan 15-01)
    provides: CI pins the claude CLI at 2.1.301 (precondition of this plan)
  - phase: 12-docs-server-renamed-to-bbj
    provides: 12-LINUX-RUN.md sign-in record (labels, 2026-10-15, checkout a551d0a)
  - phase: 13-windows-hook-fixes
    provides: 13-WINDOWS-RUN.md round 3 record of the shipped commandWindows (2026-10-16, checkout 1199d82)
  - phase: 14-one-install-page-and-one-term-list
    provides: docs/install.md, the term list, the README Verified qualifiers
provides:
  - the tree at 0.2.2 in all five version places, VERSION and the README version line
  - the `## 0.2.2` CHANGELOG entry (summary, Upgrading, Tested against, Not run) drafted from the records
  - CONTENT_VERSION 0.2.2 and NOT_RUN_LINES pinned to the new Not run lines
affects: [15-04 project notes and full suite, 15-06 release run lines, PR, tag and Release body]

actuals:
  tokens: 2750
  tasks: 1
  commits: 1

tech-stack:
  added: []
  patterns:
    - "Entry written in present-state wording from the run records; every Not run bullet is one physical line so release_not_run compares it line for line"

key-files:
  created: []
  modified:
    - .claude-plugin/marketplace.json
    - plugins/bbj/.claude-plugin/plugin.json
    - plugins/bbj-local/.claude-plugin/plugin.json
    - plugins/bbj/.codex-plugin/plugin.json
    - tests/test_layout.py
    - README.md
    - CHANGELOG.md
    - tests/test_release_text.py

key-decisions:
  - "The Linux sign-in line is written as 'On Linux, from a checkout (a551d0a), 2026-10-15, with Claude Code 2.1.299 and Codex CLI 0.162.1', so claude_version_single keeps one Linux version when plan 15-06 adds the 2.1.301 release run"
  - "The upgrade Not run line reads 'an upgrade to this release through a Git marketplace in either client; the runs installed this release fresh', which stays true next to the install page's dated Codex upgrade observation"
  - "RETIRED_WORD removed from tests/test_release_text.py: no Not run line uses it any more"

requirements-completed: [REL-09]

coverage:
  - id: D1
    description: "Five manifest versions, VERSION in tests/test_layout.py and the README version line read 0.2.2 in one commit of exactly eight files"
    requirement: REL-09
    verification:
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_versions"
        status: pass
      - kind: other
        ref: "claude plugin validate --strict on ., plugins/bbj, plugins/bbj-local"
        status: pass
    human_judgment: false
  - id: D2
    description: "## 0.2.2 CHANGELOG entry with summary bullets, Upgrading, Tested against and Not run; 0.2.1 and older entries byte-identical"
    requirement: REL-09
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#changelog_heading, changelog_sections, changelog_leftovers, upgrade_addressed, claude_version_single"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py#layout_no_retired_route, layout_no_old_server_name, layout_no_removed_pages, layout_no_retired_terms"
        status: pass
      - kind: other
        ref: "plan 15-03 Task 1 automated verify (entry check, cmp of the range from ## 0.2.1)"
        status: pass
    human_judgment: false
  - id: D3
    description: "CONTENT_VERSION 0.2.2 and NOT_RUN_LINES equal the Not run lines of the entry"
    requirement: REL-09
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py#not_run"
        status: pass
      - kind: unit
        ref: "sh tests/test_release_text_mutation.sh#release_mut_not_run, release_mut_later_unpinned, release_mut_later_repinned"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every Tested against and Not run line states only what a run record or docs/install.md backs"
    requirement: REL-09
    verification: []
    human_judgment: true
    rationale: "No test can judge whether a sentence is backed by the record it cites; the source of each Not run line is listed below for the verifier"

duration: 7min
completed: 2026-10-16
plan_head_before: 1e08255171af2a33f9eb95d723a8e720910210ad
plan_head_after: 07190d033a94a78a70c96455b7dccfbe53dbbce3
commits: 1
status: complete
---

# Phase 15 Plan 03: Release 0.2.2 bump and CHANGELOG entry Summary

**All five version places, VERSION and the README line at 0.2.2, with a `## 0.2.2` entry drafted from the 12 and 13 run records and the release-text gates re-pinned to its Not run lines, in one eight-file commit.**

## Performance

- **Duration:** about 7 min
- **Started:** about 2026-10-16T17:57:00Z (start time was not captured; estimated)
- **Completed:** 2026-10-16T18:03:00Z
- **Tasks:** 1 (tracer)
- **Files modified:** 8

## Accomplishments

- Versions: `"version": "0.2.2"` in both marketplace entries, both plugin manifests and the Codex overlay; `VERSION = "0.2.2"`; README line `version 0.2.2`. All by targeted `sed`, no JSON re-dump.
- Entry: summary sentence and nine bullets (docs server `bbj` labels, the plugin as install route for both clients, one install page, check order of both skills by tool, manifest and `docs_url` descriptions, README Verified qualifiers, the `sh.exe` lookup order, the exit-2 not-found message, the one `bbj-ls` try and the 12 second wait), then `### Upgrading`, `### Tested against` (eight bullets), `### Not run` (eight lines).
- Gates re-pinned: `CONTENT_VERSION = "0.2.2"`, `NOT_RUN_LINES` generated from the entry's Not run lines (backslashes doubled by `json.dumps`), docstring `(0.2.2)`, `RETIRED_WORD` removed.
- The entry names no earlier version, no old server name, no removed page, no retired term, no redo step and holds no `Claude Code <version> on Linux` line.

## Task Commits

1. **Task 1: End-to-end release 0.2.2 slice** - `07190d0` (chore) -- exactly the eight files of the plan

**Plan metadata:** the docs commit that carries this SUMMARY, STATE.md and ROADMAP.md follows.

## Files Created/Modified

- `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`, `plugins/bbj/.codex-plugin/plugin.json` - version 0.2.2
- `tests/test_layout.py` - `VERSION = "0.2.2"`, the single version source
- `README.md` - version line
- `CHANGELOG.md` - the `## 0.2.2` entry above `## 0.2.1`
- `tests/test_release_text.py` - CONTENT_VERSION and NOT_RUN_LINES re-pinned

## Source of each Not run line

| # | Line (start) | Backed by |
|---|--------------|-----------|
| 1 | Windows: the Claude Code default home `/c/bbx`, `BBJHOME`, `PATH` | docs/install.md "Not run on Windows: Claude Code with the BBj home found from ..." (reworded 0.2.1 line, still true) |
| 2 | Windows: Claude Code with the shipped `commandWindows` entry | D-08; docs/install.md Windows section (Claude Code ran the `command` field of a 0.2.1-era `hooks.json`); 13-WINDOWS-RUN.md ran the shipped entry through Codex and Windows PowerShell only |
| 3 | Windows: the Codex plugin route with Git for Windows on another drive ... | 13-WINDOWS-RUN.md l.479 and docs/install.md "Not run: Git for Windows on another drive ..." (same five configurations) |
| 4 | Windows: the hook's `bbj-ls` check inside a Claude Code or Codex session | docs/install.md "Not run on Windows: the hook asking `bbj-ls` inside a session; it was run from Git Bash only" (0.2.1 line reworded to the term list) |
| 5 | macOS: the plugin `bbj-local` in either client | docs/install.md "Not run on macOS: the plugin `bbj-local` ..."; README "Not run, so not claimed" |
| 6 | Windows and macOS: the sign-in to the docs server `bbj` | D-08; 12-LINUX-RUN.md is Linux only, 12-04 removed the Windows and macOS sentences |
| 7 | Linux, Windows and macOS: a Codex patch of several BBj files with no check route / silent `bbj-ls` | docs/install.md "follows from the hook's timeouts and its tests on fakes and was not observed in a run" |
| 8 | Linux, Windows and macOS: an upgrade to this release through a Git marketplace | D-10, D-20; 12 D-10 and 13 runs were fresh installs only |

Removed from the 0.2.1 set: the three lines that name the removed route, the "Windows: Codex plugin route with Git anywhere but `C:\Program Files\Git`" line (replaced by line 3, narrower and record-backed), and the two upgrade lines (replaced by line 8).

## Gate lines of the four test files run in Task 1

- `python3 -I tests/test_layout.py`: exit 0, ok=110 fail=0 skip=0. `gate layout_versions ok versions=['0.2.2', '0.2.2', '0.2.2', '0.2.2', '0.2.2'] want all 0.2.2`; `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages` and `layout_no_retired_terms` ok.
- `python3 -I tests/test_release_text.py`: exit 0, 18 gates ok. `release_readme_version`, `release_changelog_heading`, `release_changelog_sections`, `release_changelog_leftovers`, `release_upgrade_addressed`, `release_claude_version_single` (Linux ['2.1.299'], Windows ['2.1.292'], macOS ['2.1.296']), all six `release_cell_*` (Codex plugin / macOS unchanged), `release_cell_qualifiers_defined`, `release_no_unrun_hint` and `release_not_run` (`exactly the NOT_RUN_LINES`) ok.
- `sh tests/test_release_text_mutation.sh`: exit 0, 27 gates ok, including `release_mut_not_run`, `release_mut_later_unpinned`, `release_mut_later_repinned` and `release_mut_later_addressee`.
- `sh tests/test_install_pages.sh`: exit 0, 134 gates ok, no FAIL, no skip.
- `claude plugin validate --strict` (throwaway `CLAUDE_CONFIG_DIR=$HOME/.cache/bbj-phase15/validate-cfg`): passed on `.`, `plugins/bbj` and `plugins/bbj-local`.
- The plan's automated verify (older-entry `cmp`, eight-file list, entry fact check, `CONTENT_VERSION`, `RETIRED_WORD`) printed `ok`.

## Decisions Made

- Kept the Linux sign-in line free of the pattern `Claude Code <version> on Linux` so plan 15-06 can add the 2.1.301 release-run line without a second Linux version.
- Not run line 8 says "an upgrade to this release", not "an upgrade", because docs/install.md carries a dated Codex upgrade observation on Linux; the new wording is true next to it.
- Carried Tested against lines name the tree as their record gives it: a checkout sha for the Linux sign-in (`a551d0a`) and Windows round 3 (`1199d82`), "from a local clone" or "from a checkout" where docs/install.md says so, and no tree where no record names one.
- The skills line says only "as shipped"; no test result is attributed to it before the release run.

## Deviations from Plan

### Wording adjustments inside the plan's discretion (Flagged assumption: Not run wording is the planner's draft)

**1. [Discretion] Not run line 8 reworded**
- **Found during:** Task 1, step 2d
- **Issue:** the drafted line "an upgrade of the plugins through a Git marketplace in either client; this release was installed fresh" sits next to docs/install.md's dated Codex upgrade observation on Linux.
- **Fix:** "an upgrade to this release through a Git marketplace in either client; the runs installed this release fresh." NOT_RUN_LINES follows.
- **Files modified:** CHANGELOG.md, tests/test_release_text.py
- **Committed in:** 07190d0

Otherwise none: plan executed as written.

**Total deviations:** 0 auto-fixed, 1 discretionary wording change. **Impact:** none on gates or scope.

## Issues Encountered

None. The start time was not captured at the beginning of execution, so the duration is an estimate.

## Known Stubs

None.

## Threat Flags

None. No file adds a network endpoint, auth path or trust boundary.

## Next Phase Readiness

- Ready for 15-04: project notes at 0.2.2 and the whole suite (`sh tests/run.sh`) on the bumped tree.
- Plan 15-06 adds the release-run Tested against lines (Claude Code 2.1.301 on Linux, suite line) and must re-check README l.51, docs/install.md l.5/l.24, `tests/test_install_pages.sh` and `CELLS` if the Linux Claude Code version changes, so `claude_version_single` keeps one version per platform.

## Self-Check: PASSED

- All eight files found on disk; commit `07190d0` is an ancestor of HEAD; `git rev-list --count 1e08255..HEAD` is 1 before this docs commit.

---
*Phase: 15-release-0-2-2*
*Completed: 2026-10-16*
