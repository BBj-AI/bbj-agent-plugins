---
phase: 06-release-0-2-0
plan: 07
subsystem: release-merge
tags: [merge, install-gate, d-01, d-02, d-05, rel-03, ci]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-06 (PR #1 ready, head d6e5d56, CI green)
provides:
  - evidence/install-gate.sh, the D-05 install gate over a git marketplace source (seven gates)
  - PR #1 merged into main with a merge commit f15c257 (parents 3c75f4f and d6e5d56, tree 77b1c7a equals the tested head)
  - GitHub CI green on main for the merge commit
  - Install gate passed against BBj-AI/bbj-agent-plugins (default branch main)
affects: [06-08 tag and Release (REL-04)]

status: complete
actuals:
  tokens: 14000
  tasks: 3
  commits: 2
plan_head_before: 5e502e04631bec5b62f022f929eab5ab933bd56f
plan_head_after: da6b1c485183b95997435eac9fc52730910bfae7

tech-stack:
  added: []
  patterns:
    - "Same install gate script run twice, on the PR ref before the merge and on main after it; the tag depends on the second run"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/install-gate.sh
    - .planning/phases/06-release-0-2-0/evidence/install-gate-pr.txt
    - .planning/phases/06-release-0-2-0/evidence/premerge.txt
    - .planning/phases/06-release-0-2-0/evidence/merge.txt
    - .planning/phases/06-release-0-2-0/evidence/install-gate-main.txt
  modified: []

key-decisions:
  - "Merged only after the owner's explicit 'merge' at the blocking-human checkpoint; every precondition re-verified immediately before the command"
  - "Merge commit, no squash, no rebase, branch kept (D-02); --match-head-commit pinned to the tested head (D-01)"
  - "No tag and no Release in this plan; the tag is plan 06-08"

requirements-completed: [REL-03]

duration: multi-session (Task 3 continuation about 6 min)
completed: 2026-10-12
---

# Phase 6 Plan 07: Merge and install gate from main Summary

**PR #1 is merged into main as merge commit f15c257 carrying exactly the tested tree 77b1c7a, GitHub CI is green on it, and the D-05 install gate passes all seven gates against `BBj-AI/bbj-agent-plugins` (main), so the tag can now be considered.**

## Accomplishments

- Task 1 (commit ead494a): wrote the install gate script (shellcheck clean, refuses with exit 2 without SOURCE) and passed it against `BBj-AI/bbj-agent-plugins#gsd/planning-setup-pr`; wrote the read-only merge preconditions to `premerge.txt`.
- Task 2: blocking-human checkpoint. The owner replied "merge".
- Task 3 (commit da6b1c4): re-verified before merging that the PR was OPEN, head d6e5d56, not draft, MERGEABLE, both `plugins` checks SUCCESS, origin/main still 3c75f4f and no tag on origin. Ran `gh pr merge 1 --merge --match-head-commit d6e5d56035302483fd73abb79fee4af7c0a35aaf` (no `--delete-branch`).

## Merge proof (evidence/merge.txt)

| Fact | Value |
| ---- | ----- |
| PR | https://github.com/BBj-AI/bbj-agent-plugins/pull/1 (state MERGED) |
| merge commit M | f15c257f6fba6e5d4cde60e49ad06727de44f68f |
| parent1 | 3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b (previous main) |
| parent2 | d6e5d56035302483fd73abb79fee4af7c0a35aaf (tested head) |
| tree | 77b1c7a7b49401ba7ee033f0c992c5bac7072e07 (equals the tested head tree) |
| parents | 2 |
| `.planning/` paths on M | 0 |
| main CI | success, https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/38279355272 |
| tags on origin | 0 |

## Install gate output

On the PR ref (`evidence/install-gate-pr.txt`) and on main with no ref (`evidence/install-gate-main.txt`), identical result:

```
gate install_marketplace_add ok
gate install_bbj ok bbj@basis-bbj installed
gate install_bbj_version ok bbj 0.2.0 enabled
gate install_bbj_local_disabled ok bbj-local installed and disabled
gate install_hook_bad ok exit 2, bbjcpl reported 1 error(s)
gate install_hook_clean ok exit 0, silent
gate install_real_config_untouched ok plugin files of the real configuration unchanged
```

REL-03: the suite passed with `skip=0` on the live gates in plans 06-03 and 06-06 (`ok=738 fail=0 skip=0`), and the install from the git marketplace source passes from main. Both parts hold.

## Deviations from Plan

None - plan executed exactly as written.

## Auth gates

None.

## Known Stubs

None.

## Threat Flags

None. The only new surface is the published merge commit, which the plan's threat model covers (T-06-22 to T-06-24: head pinned with `--match-head-commit`, owner approval before the merge, merge commit with two parents).

## Next

Plan 06-08: tag `v0.2.0` and the GitHub Release (REL-04), only with the owner's approval. Nothing is tagged yet; `git ls-remote --tags origin` prints nothing. The branch `gsd/planning-setup-pr` still exists on origin.

## Self-Check: PASSED

- FOUND: evidence/install-gate.sh, install-gate-pr.txt, premerge.txt, merge.txt, install-gate-main.txt
- FOUND commits: ead494a, da6b1c4 (ancestors of HEAD)
- FOUND on origin: merge commit f15c257 as origin/main with parents 3c75f4f and d6e5d56
