---
phase: 15-release-0-2-2
plan: 09
subsystem: release
tags: [release, planning-close, scrub, push]

requires:
  - phase: 15-release-0-2-2
    provides: "15-08 tag 0.2.2 and GitHub Release on M 0e9b3c0d"
provides:
  - "released main merged back into gsd/planning-setup (two-parent merge, nothing changed outside .planning/)"
  - "one scrub commit: the dev home path removed from every tracked .planning/ file"
  - "origin/gsd/planning-setup fast-forwarded to 035e8a2d, owner-confirmed"
affects: [next release PR range starts at the merge-back commit bd7a86e]

commits: 2
plan_head_before: 9397dc624f6024bb7e5cd3f2561a77da4269f9ca
plan_head_after: 035e8a2d184a228cc42602d9be34ec68ca12ec44

actuals:
  tokens: 45000
  tasks: 3
  commits: 2

tech-stack:
  added: []
  patterns: ["merge-back first, then one scrub commit; plain fast-forward push of one ref after an ancestor check"]

key-files:
  created: []
  modified:
    - .planning/STATE.md
    - .planning/codebase/CONCERNS.md
    - .planning/spikes/004-copilot-plugin-parity/run.sh
    - .planning/spikes/004-copilot-plugin-parity/session.sh

key-decisions:
  - "Owner replied 'push' for Task 2 after being told the 233 pushed commits carry older blobs with the dev home path, which become public (D-18 accepts this, D-15 forbids a forced push)"
  - "The only remote action was git push origin gsd/planning-setup: no force, no --tags, no other ref"

requirements-completed: [REL-10]

coverage:
  - id: D1
    description: "Released main merged back into gsd/planning-setup with a two-parent commit that changes no file outside .planning/"
    requirement: REL-10
    verification:
      - kind: integration
        ref: "Task 1 automated verify (no_merge_back, merge_back_changed_code, main_not_merged checks) passed before the checkpoint"
        status: pass
    human_judgment: false
  - id: D2
    description: "Dev home path scrubbed from every tracked .planning/ file in one commit (D-15, D-18); zero hits on origin's tip"
    requirement: REL-10
    verification:
      - kind: integration
        ref: "git grep -lF over origin/gsd/planning-setup -- .planning printed nothing after the push; Task 3 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D3
    description: "Planning branch pushed as a plain fast-forward of one ref; origin main and the tags unchanged"
    requirement: REL-10
    verification:
      - kind: integration
        ref: "Task 3 automated verify printed ok; ls-remote after the push, facts below"
        status: pass
    human_judgment: false

duration: not measured (continuation run covered the push and this summary)
completed: 2026-10-17
status: complete
---

# Phase 15 Plan 09: Planning-side close Summary

The released main is merged into the planning branch, the dev home path is scrubbed from the tracked planning records in one commit, and `gsd/planning-setup` is on origin as a plain fast-forward with `main` and the tags untouched.

## Commits

- bd7a86e `chore(15-09): merge the released main (0.2.2) into the planning branch` (two parents; no file outside `.planning/` changed). It brings in 91 commits of main, so `git rev-list --count` over the plan range reads 93; the plan's own commits are 2 (first-parent count).
- 035e8a2 `docs(15-09): scrub the dev home path from the planning records (D-15, D-18)`: 36 files changed, 53 insertions, 59 deletions, all under `.planning/`. It includes the two spike scripts (`$HOME` form, `sh -n` clean), the sentences naming the path as the thing to scrub (now `the dev home path`), the dropped STATE.md Phase 12 WR-01/WR-02 and Phase 10 lines (IN-10 kept), and the CONCERNS.md WR-01 bullet. The remaining files got the fixed-string replacement `<home>`.

## Push facts (Task 3, owner reply "push")

- before_origin: 9e7362f56058e4473ca31208114e7ac08948a9ce, an ancestor of the local head (checked before pushing)
- command: `git push origin gsd/planning-setup`, result `9e7362f..035e8a2`
- pushed head: 035e8a2d184a228cc42602d9be34ec68ca12ec44, equal to the local head at push time
- commits pushed: 233
- origin main after: 0e9b3c0d368573047c71e8530ac0b19f89343a3c (equals M, unchanged)
- origin tags after: 0.2.0, 0.2.1, 0.2.2 (same list and same objects as before the push)
- dev home path in origin's `.planning/` tip: 0 files
- Older blobs among the 233 pushed commits still hold the dev home path (T-15-25, accepted; stated to the owner before the decision).

## Deviations from Plan

None. The plan executed as written. The summary and STATE/ROADMAP commits that follow stay local until the next planning push, as the plan states.

## Deferred / working-tree notes

`.planning/phases/15-release-0-2-2/release-run/owner.sh` shows a mode-only change and `.planning/milestone.lock` and `.planning/state.json` are untracked; none was staged, per the run's hard limits.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- origin/gsd/planning-setup = 035e8a2d (matches local at push time)
- bd7a86e and 035e8a2 are ancestors of HEAD
- 15-09-PLAN Task 3 automated verify printed `ok`
