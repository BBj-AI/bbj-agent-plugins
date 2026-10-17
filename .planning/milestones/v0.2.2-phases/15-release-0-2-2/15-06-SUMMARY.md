---
phase: 15-release-0-2-2
plan: 06
subsystem: release
tags: [release, changelog, pull-request, ci, install-gate, claude-code, codex]

requires:
  - phase: 15-release-0-2-2
    provides: "15-05 release candidate, the Linux release run (15-LINUX-RUN.md) and the release-tree worktree"
provides:
  - "0.2.2 Tested against with the release-run facts (Claude Code 2.1.301 and Codex CLI 0.162.1 on Linux, suite line)"
  - "Linux Claude Code re-pinned to 2.1.301 in README, docs/install.md, the page gate and the release-text cells"
  - "branch gsd/release-0.2.2 on origin at d7e5a53 and the ready PR #4 'Release 0.2.2' into main"
  - "CI success and install gate (seven gates) on the exact pushed head"
affects: [15-07 merge decision]

commits: 3
plan_head_before: ad8584db439611ebe2130a50aa7ad99e7b9a99fd
plan_head_after: 3f3bdb7af96023324e58cd8d3af3abf657916f9e

actuals:
  tokens: 40000
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns: ["run facts enter the entry only after the run; final tree differs from the run tree by five text files, proven by git diff of plugins/.claude-plugin/.github"]

key-files:
  created:
    - .planning/phases/15-release-0-2-2/evidence/pr.txt
    - .planning/phases/15-release-0-2-2/evidence/install-gate-pr.txt
    - .planning/phases/15-release-0-2-2/evidence/rc-suite-final.txt
  modified:
    - CHANGELOG.md
    - README.md
    - docs/install.md
    - tests/test_install_pages.sh
    - tests/test_release_text.py
    - .planning/phases/15-release-0-2-2/evidence/pr-branch.txt

key-decisions:
  - "Owner typed 'push' for Task 2; the push named exactly gsd/release-0.2.2 at d7e5a53, plain, no force, no tag, main untouched"
  - "PR body is the 0.2.2 entry without its heading plus the Claude Code pull-request attribution line, which is what the plan and the session instructions both prescribe (no conflict)"

requirements-completed: [REL-09, REL-10, NAME-03]

coverage:
  - id: D1
    description: "0.2.2 Tested against carries the release-run facts and the D-16 re-pin in one five-file commit"
    requirement: REL-09
    verification:
      - kind: unit
        ref: "python3 -I tests/test_release_text.py (release_claude_version_single, release_cell_claude_code_linux, release_not_run ok)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Final release tree ships the files the clients installed in the run and passes the same suite count (ok=864 fail=0 skip=0; CI SUMMARY ok=6)"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/rc-suite-final.txt"
        status: pass
    human_judgment: false
  - id: D3
    description: "Release PR #4 open, not draft, based on main; CI success on the pushed head; install gate green on the pushed ref"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/pr.txt and install-gate-pr.txt"
        status: pass
    human_judgment: false
  - id: D4
    description: "Sign-in labels in the entry equal the ones the release run recorded"
    requirement: NAME-03
    verification:
      - kind: manual_procedural
        ref: "Task 1 verify (entry holds plugin:bbj:bbj and codex mcp login bbj, taken from 15-LINUX-RUN.md)"
        status: pass
    human_judgment: false

duration: not measured (continuation run covered Task 3 only)
completed: 2026-10-16
status: complete
---

# Phase 15 Plan 06: Release run facts, final tree and release PR Summary

**The 0.2.2 entry now carries the Linux release-run facts (Claude Code 2.1.301, Codex CLI 0.162.1), the final tree ships the same plugin files as the run tree with the same suite count (ok=864), and PR #4 "Release 0.2.2" is open and ready with CI and the install gate green on the pushed head d7e5a53.**

## Performance

- **Tasks:** 3 (Task 1 auto/tracer, Task 2 owner decision, Task 3 push and PR)
- **Files modified:** 5 release files plus 5 evidence files

## Accomplishments

- One five-file commit (607eae5 on the planning branch, cherry-picked as d7e5a53 on gsd/release-0.2.2) writes the run lines into Tested against and re-pins Linux Claude Code to 2.1.301.
- The final tree differs from the run tree (0d619fb) only in CHANGELOG.md, README.md, docs/install.md, tests/test_install_pages.sh and tests/test_release_text.py; `plugins/`, `.claude-plugin/` and `.github/` are identical (`shipped_equal: yes`). The release command on the final head gave `SUMMARY: ok=864 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`, equal to the run.
- After the owner's "push", gsd/release-0.2.2 was pushed (plain, one ref) and the draft PR opened, then marked ready.
- CI on the pushed head: success on both the pull_request run (https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38952416570) and the push run (https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38952399886). This was the first CI run on the 2.1.301 pin (research A3); it passed.
- Install gate against `BBj-AI/bbj-agent-plugins#gsd/release-0.2.2` at 0.2.2 with Claude Code 2.1.301: all seven `install_*` gates ok.

## Task Commits

1. **Task 1: release-run lines and D-16 re-pin** - `607eae5` (cherry-picked `d7e5a53` on gsd/release-0.2.2); final-tree evidence `431ebf5`
2. **Task 2: owner confirmation (checkpoint:decision, blocking-human)** - no commit; the owner replied "push" on 2026-10-16
3. **Task 3: push, PR #4, CI, install gate, ready** - `3f3bdb7`

**Plan metadata:** the commit holding this SUMMARY, STATE.md, ROADMAP.md and REQUIREMENTS.md.

## Files Created/Modified

- `CHANGELOG.md`, `README.md`, `docs/install.md`, `tests/test_install_pages.sh`, `tests/test_release_text.py` - run facts and the 2.1.301 re-pin
- `.planning/phases/15-release-0-2-2/evidence/pr-branch.txt` - run_head, changed_since_run, shipped_equal; `pushed_to_origin` updated to yes in Task 3
- `.planning/phases/15-release-0-2-2/evidence/rc-suite-final.txt` - release command on the final head
- `.planning/phases/15-release-0-2-2/evidence/pr.txt`, `install-gate-pr.txt` - PR, CI and install-gate record

## Decisions Made

- The push was limited to the one authorized ref at the recorded head; head on origin equals the tested head, origin/main is still 4234e76 and no 0.2.2 or v0.2.2 tag exists.
- No `.planning/` path is in `origin/main..origin/gsd/release-0.2.2` (0 paths).

## Deviations from Plan

None - plan executed exactly as written. One small addition: Task 3 also changed the `pushed_to_origin` line of `evidence/pr-branch.txt` from `no` to `yes`, so the record stays true after the push.

## Issues Encountered

None. The install-gate evidence file also holds a final `exit=0` line after the gate lines (the gate's exit status).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

PR #4 is ready for review and is not merged. The merge and any tag are the separate decision of plan 15-07.

## Self-Check: PASSED

- origin head of gsd/release-0.2.2 = d7e5a53ef31690a49834d760b3eee3c63e95501a (equals pr-branch.txt head)
- PR #4: OPEN, not draft, base main; CI success; seven install gates ok; main unmoved; no tag; planning paths on origin 0; no real home path in the evidence
- Commits 607eae5, 431ebf5, 3f3bdb7 are on the planning branch
