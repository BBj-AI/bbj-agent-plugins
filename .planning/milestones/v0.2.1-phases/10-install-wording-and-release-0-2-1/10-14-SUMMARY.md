---
phase: 10-install-wording-and-release-0-2-1
plan: 14
subsystem: release-0-2-1-tag-and-release
tags: [release, tag, github-release, merge-back, d-21, d-23, d-25]

requires:
  - phase: 10-install-wording-and-release-0-2-1
    provides: "plan 10-13: M2 4234e76 on origin/main (merge of M1 and the amendment head 38c690c)"
provides:
  - "annotated tag 0.2.1 (no v prefix, message basis-bbj 0.2.1) on origin: object 9e0d1848ff4533b548b63775376318aaa1ba0d05, peels to M2 4234e76ccb369d0fe984ac36825e06b3b8fbf3f1"
  - "GitHub Release 0.2.1 (published, not draft, not prerelease), body equal to the 0.2.1 CHANGELOG entry of M2"
  - "released main merged back into gsd/planning-setup locally (not pushed), nothing outside .planning changed"
  - "folded pre-production wording todo moved to .planning/todos/completed/ with a dated closing note"
affects: []

requirements-completed: [REL-08]

actuals:
  tokens: 9000
  tasks: 3
  commits: 3

key-files:
  created:
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/release-notes.md
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/tag.txt
    - .planning/phases/10-install-wording-and-release-0-2-1/evidence/release.txt
    - .planning/todos/completed/2026-10-13-no-pre-production-wording-from-bbjlangmcp.md
  modified: []

key-decisions:
  - "Published only after the owner's explicit reply 'publish' to the Task 2 checkpoint (T-10-33); the tag was pushed by its own ref, no --tags, no force"
  - "The Release body was created from evidence/release-notes.md (extracted from M2) with no attribution line, so it equals the CHANGELOG entry (D-21)"

completed: 2026-10-15
status: complete
plan_head_before: 228002a
plan_head_after: 7fcaeac
commits: 3
---

# Phase 10 Plan 14: Tag 0.2.1 and publish the Release Summary

**The annotated tag `0.2.1` (object `9e0d1848`) is on origin and peels to M2 `4234e76`; the GitHub Release 0.2.1 is published with the CHANGELOG entry as its body; the released main is merged back into the planning branch locally.**

## Result

| Item | Value |
|------|-------|
| Tag object | `9e0d1848ff4533b548b63775376318aaa1ba0d05` (type `tag`, message `basis-bbj 0.2.1`) |
| Tag peels to (M2, origin/main) | `4234e76ccb369d0fe984ac36825e06b3b8fbf3f1` |
| `v0.2.1` on origin | absent |
| Release | https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.1 |
| Release state | draft: false, prerelease: false, body_equal: yes |
| Merge-back commit (local, not pushed) | `bd711f2` on gsd/planning-setup; `git diff --stat HEAD^1 HEAD -- . ':!.planning'` is empty |
| Closing commit | `7fcaeac` |

## Tasks

1. Task 1 (tracer, earlier agent): release notes extracted from M2, local annotated tag `0.2.1` created on M2, `evidence/release-notes.md`, `evidence/tag.txt`. Commit `93626ec`.
2. Task 2: checkpoint:decision, blocking-human. The owner replied `publish`.
3. Task 3: re-checked that origin/main was `4234e76`, the local tag was annotated with the expected object and peeled commit, no `0.2.1` or `v0.2.1` was on origin and no Release existed. Ran `git push origin refs/tags/0.2.1` and `gh release create 0.2.1 --verify-tag --title 0.2.1 --notes-file evidence/release-notes.md`. Wrote `evidence/release.txt` from `git ls-remote --tags origin` and `gh release view`. Merged `origin/main` into gsd/planning-setup with `--no-ff`. Moved the pre-production todo to completed with a closing note naming plans 10-02, 10-06, 10-07 and the 0.2.1 release (the OAuth todo stays pending). The Task 3 verify printed `VERIFY_OK`. Commits `bd711f2` (merge) and `7fcaeac`.

## Commits (planning branch gsd/planning-setup, none pushed)

- `93626ec` docs(10-14): release notes from M2 and the local annotated tag 0.2.1
- `bd711f2` chore(10-14): merge the released main (0.2.1) into the planning branch
- `7fcaeac` docs(10-14): 0.2.1 tagged and released; folded wording todo closed

`commits: 3` counts first-parent commits from `plan_head_before`; the merge brings main's history into the branch, so a plain `rev-list` count (107) would measure main, not this plan.

## Deviations from Plan

None - plan executed exactly as written. The per-plan commit ledger file for 10-14 was not present (earlier agent), so `plan_head_before` is the parent of the plan's first commit, `228002a`.

## Known Stubs

None.

## Threat Flags

None. The only outward actions were the one tag push and the one Release creation, both confirmed by the owner (T-10-32, T-10-33, T-10-34 mitigated).

## Next

Phase 10 has 17 of 17 plans done. REL-08 is complete. The amendment branch `gsd/release-0.2.1-amend` was kept (not deleted). The planning branch is local only and was not pushed. No post-release reading on Windows or macOS is planned (D-24).

## Self-Check: PASSED

- `evidence/release.txt`, `evidence/tag.txt`, `evidence/release-notes.md` and the completed todo found; pending todo absent.
- Commits `93626ec`, `bd711f2`, `7fcaeac` found; origin tag `0.2.1` object `9e0d1848` peels to `4234e76`; Release 0.2.1 published, not draft, not prerelease.
