---
phase: 06-release-0-2-0
plan: 08
subsystem: release-tag
tags: [tag, github-release, d-03, d-04, d-05, rel-04]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-07 (merge commit f15c257 on main, CI green, install gate from main passed)
provides:
  - annotated tag 0.2.0 on origin, peeling to the merge commit f15c257
  - GitHub Release 0.2.0 whose body is the CHANGELOG 0.2.0 entry
  - gsd/planning-setup (local) contains the tagged history
affects: [milestone completion, any later release]

status: complete
actuals:
  tokens: 9000
  tasks: 3
  commits: 3
plan_head_before: 8b76190e3b86bc8ee59248fffeaa4cdc8e187294
plan_head_after: ba837aba89ec66f71efe6f7e66fc248856b000aa

tech-stack:
  added: []
  patterns:
    - "Tag and notes prepared and verified locally (tracer), published only after a blocking-human owner reply"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/release-notes.md
    - .planning/phases/06-release-0-2-0/evidence/release-plan.txt
    - .planning/phases/06-release-0-2-0/evidence/release.txt
  modified: []

key-decisions:
  - "Tag 0.2.0 (no v), annotated, unsigned, on the merge commit M, created by hand (no GSD tool tagged)"
  - "Release body is the CHANGELOG 0.2.0 entry extracted from M, title 0.2.0, not draft, not prerelease"
  - "The planning branch gets the released main by a local merge commit; gsd/planning-setup was not pushed"

requirements-completed: [REL-04]

duration: multi-session (Task 3 continuation about 5 min)
completed: 2026-10-12
---

# Phase 6 Plan 08: Tag 0.2.0 and GitHub Release Summary

**Annotated tag `0.2.0` on the merge commit f15c257 is on origin, GitHub Release 0.2.0 carries the CHANGELOG entry verbatim, and the planning branch has merged the released main locally.**

## Accomplishments

- Task 1 (commit 3b65889, tracer): extracted the Release body from M's CHANGELOG.md (identical to the planning branch's extraction; has Upgrading, Tested against, Not run), created the annotated tag locally, verified it peels to M, nothing published.
- Task 2: blocking-human checkpoint. The owner replied "publish".
- Task 3: re-verified the preconditions (origin/main still f15c257, no tag on origin, no Release, notes cksum `1374688604 5267`), then ran `git push origin refs/tags/0.2.0` (no force, no --tags) and `gh release create 0.2.0 --verify-tag --title 0.2.0 --notes-file .../release-notes.md` (no draft, no prerelease).

## Release facts (evidence/release.txt)

| Fact | Value |
| ---- | ----- |
| tag | 0.2.0 (annotated, unsigned) |
| tag object | 1df55522a9f2e4dd96119377214a6cd1621c0bc7 |
| peeled commit M | f15c257f6fba6e5d4cde60e49ad06727de44f68f |
| Release URL | https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.0 |
| published | 2026-10-12 (17:41:15Z) |
| merge-back commit | 9f178d2c43c31c68028d0700f2173248bdd434d8 |
| main moved past M | no; origin/main is still f15c257 |

## Verification

- `git ls-remote --tags origin` lists exactly `refs/tags/0.2.0` (the local tag object) and `refs/tags/0.2.0^{}` equal to M; no v-prefixed tag locally or on origin.
- `gh release view 0.2.0`: tagName 0.2.0, name 0.2.0, isDraft false, isPrerelease false; body equals release-notes.md after trailing-whitespace normalisation.
- Merge-back was clean (ort, no conflict). `0.2.0` is an ancestor of HEAD; the HEAD tree without `.planning` is 77b1c7a7b49401ba7ee033f0c992c5bac7072e07, equal to M's tree (D-21 option (a): `.claude` ships). `tests/test_layout.py` and `tests/test_release_text.py` exit 0.
- Scratch root `${TMPDIR:-/tmp}/bbj-release-06` removed.

## Deviations from Plan

None - plan executed as written. One note on the commit count: `commits: 3` is the first-parent count from `plan_head_before` (the three plan commits 3b65889, 9f178d2, ba837ab). A plain `git rev-list --count` gives 109 because the merge-back brought the history of main into the planning branch.

## Notes

- The ledger file `gsd-plan-head-before-06-08` was not on disk in this continuation, so `plan_head_before` is the parent of the first plan commit (8b76190).
- The remote branches `gsd/planning-setup` (3d21b45) and `gsd/planning-setup-pr` were not touched; deleting the PR branch is left to the owner. The local planning branch is ahead of origin and unpushed by design.
- The tag is one-way: it must not be moved, deleted or force-pushed.

## Known Stubs

None.

## Self-Check: PASSED

- release-notes.md, release-plan.txt, release.txt exist; commits 3b65889, 9f178d2, ba837ab are ancestors of HEAD; tag and Release verified remotely as above.
