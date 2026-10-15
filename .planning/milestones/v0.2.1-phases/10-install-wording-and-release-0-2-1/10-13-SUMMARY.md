---
phase: 10-install-wording-and-release-0-2-1
plan: 13
subsystem: release-0-2-1-amendment-merge
tags: [release, merge, ci, d-23, rq-5]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-12: PR #3 (gsd/release-0.2.1-amend, head 38c690c) open, ready, CI green; M1 dad18f5 on main"
provides:
  - "M2 4234e76 on origin/main: merge commit of M1 and the checked head 38c690c, tree equal to the checked tree"
  - "CI success on main for M2 (push run 38679158077)"
  - "D-23 evidence on M2 (RQ-5 a): the full release run of plan 10-12 ran on a tree equal to M2's"
affects: [10-14]

requirements-completed: []
requirements-partial: [REL-08]

actuals:
  tokens: 9000
  tasks: 3
  commits: 2

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/premerge-b.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/merge-b.txt

key-decisions:
  - "Merged only after the owner's explicit reply 'merge' to the Task 2 checkpoint (T-10-30); --merge --match-head-commit, no --delete-branch, --squash, --rebase or --admin"
  - "D-23 evidence is RQ-5 (a): the 10-12 full release run was on tree f3d3e0b, which is M2's tree, so no re-run on M2 was needed"

completed: 2026-10-15
status: complete
plan_head_before: 3e4af0d
plan_head_after: aa073cd
commits: 2
---

# Phase 10 Plan 13: Amendment merge Summary

**PR #3 is merged into main as M2 `4234e76ccb369d0fe984ac36825e06b3b8fbf3f1`, a two-parent merge of M1 and the checked head with the checked tree; CI on main succeeded for M2 and no tag exists yet.**

## Result

| Item | Value |
|------|-------|
| M2 (origin/main) | `4234e76ccb369d0fe984ac36825e06b3b8fbf3f1` |
| parent1 (M1) | `dad18f5ef9caca3c50b0c25fff09b6487c29705e` |
| parent2 (checked head) | `38c690cd92eef3cf96fc0a87c09d98d29a060275` |
| Tree | `f3d3e0bbe67fd976fd5b9571c2b42b18a42472d2` (equals the checked head's tree) |
| Files M1..M2 | `CHANGELOG.md`, `docs/install-codex.md`, `tests/test_release_text.py`; `planning_paths: 0` |
| CI on main for M2 | success, https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38679158077 (push) |
| D-23 | RQ-5 (a): full release run on a tree equal to M2 (`pr-b-checks.txt`, `SUMMARY: ok=979 fail=0 skip=0`, `CI SUMMARY: ok=6 fail=0 skip=0`) |
| Tag 0.2.1 on origin | none |

## Tasks

1. Task 1 (tracer, earlier agent): read-only preconditions, `evidence/premerge-b.txt`. Commit `3017ceb`.
2. Task 2: checkpoint:decision, blocking-human. The owner replied `merge`.
3. Task 3: re-checked PR #3 OPEN, not a draft, head `38c690c`, `origin/main` = `dad18f5`, no 0.2.1 tag. Ran `gh pr merge 3 --merge --match-head-commit 38c690cd92eef3cf96fc0a87c09d98d29a060275`. Proved the parents, tree and file set, watched the push CI run to success, wrote `evidence/merge-b.txt`. The Task 3 verify printed `VERIFY_OK`. Commit `aa073cd`.

## Commits (planning branch gsd/planning-setup, none pushed)

- `3017ceb` docs(10-13): amendment merge preconditions recorded
- `aa073cd` docs(10-13): amendment merged; M2 is the release commit

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Next

10-14: the annotated tag `0.2.1` (no `v` prefix) goes on M2 `4234e76`, then the GitHub Release, each after the owner's confirmation. REL-08 stays open until then. The amendment branch `gsd/release-0.2.1-amend` was kept (not deleted). `origin/main` has moved ahead of the local planning branch's knowledge of it: the planning branch needs the merge-back planned in 10-14.

## Self-Check: PASSED

- `evidence/merge-b.txt` found; commits `3017ceb` and `aa073cd` found; `origin/main` = `4234e76`; no 0.2.1 tag on origin.
