---
phase: 07-test-hardening-and-release-prep
plan: 04
subsystem: docs
tags: [conventions, gate-prefix, release-tree, git, maint-08, rel-05]

requires:
  - phase: 07-test-hardening-and-release-prep
    provides: "07-02 pathscrub_ and 07-03 homeguard_ gate prefixes (test_path_scrub.sh, test_home_guard.sh)"
provides:
  - "gate-prefix bullet in .planning/codebase/CONVENTIONS.md rebuilt from a real sh tests/run.sh transcript (source)"
  - "byte-identical mirror in the GSD:conventions block of .claude/CLAUDE.md"
  - "REL-05 proof: the four 0.2.0 review-fix commits are ancestors of HEAD, full CI green"
  - "D-02: local main fast-forwarded to origin/main, nothing pushed"
affects: [phase 10 release PR (carries the review-fix commits to main per D-01)]

actuals:
  tokens: 2200
  tasks: 2
  commits: 1
commits: 1
plan_head_before: 1f337e07d7873bec7bd6850fc3d280fc4e2954d9
plan_head_after: 57bebd9a427f021f902d373b919bf13bc8bb89bf

tech-stack:
  added: []
  patterns:
    - "prefix list is prose regenerated from a transcript, not a gate (no sync gate)"

key-files:
  created: []
  modified:
    - .planning/codebase/CONVENTIONS.md
    - .claude/CLAUDE.md

key-decisions:
  - "No prefix-sync gate (MAINT-08 discretion): CI must not run the suite twice, .planning/ is stripped from the PR branch so a gate cannot read CONVENTIONS.md, and gate names built from variables defeat a static reverse check"
  - "Release tree is gsd/planning-setup (D-01): the review-fix commits are proven by ancestry, not moved; the Phase 10 PR carries them to main"

requirements-completed: [MAINT-08, REL-05]

coverage:
  - id: D1
    description: "Gate-prefix list in CONVENTIONS.md and CLAUDE.md matches the sh tests/run.sh transcript, mirror identical"
    requirement: "MAINT-08"
    verification:
      - kind: other
        ref: "Task 1 automated prefix-presence and mirror check (no output)"
        status: pass
    human_judgment: false
  - id: D2
    description: "b0a4c62, 3a42ebf, b600ac4, 172e6a5 are ancestors of HEAD; sh tests/ci.sh green"
    requirement: "REL-05"
    verification:
      - kind: other
        ref: "git merge-base --is-ancestor x4; sh tests/ci.sh exit 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "Local main equals origin/main, HEAD still gsd/planning-setup, nothing pushed or fetched from a remote"
    requirement: "REL-05"
    verification:
      - kind: other
        ref: "git fetch . origin/main:main; MAIN_FF_OK"
        status: pass
    human_judgment: false
duration: 6min
completed: 2026-10-12
status: complete
---

# Phase 07 Plan 04: Gate-Prefix List and Release-Tree Proof Summary

**The gate-prefix list in the project notes now lists every prefix the suite prints (including the new pathscrub_ and homeguard_), the four review-fix commits are proven in the release tree, and local main is fast-forwarded to origin/main without any push.**

## Performance
- **Duration:** 6 min (2026-10-12T21:57:08Z to about 22:03Z)
- **Tasks:** 2 (Task 2 changes a git ref only, no tracked file)
- **Files modified:** 2

## Accomplishments
- Rebuilt the single stale shell-prefix bullet (it claimed every shell test used its own file's prefix and listed Python prefixes as shell ones) into one lead bullet with three sub-bullets: Shell tests, Python tests, Free-form names. Entries follow the run.sh order (shell files, then Python files, each alphabetical). `release_` (test_release_text.py) and `release_mut_` (test_release_text_mutation.sh), and `ci_` (test_ci_gates.sh) and `ci_guard_` (test_ci_guards.py), are separate entries. `skills_` stays.
- Mirrored the bullet byte-for-byte into the GSD:conventions block of `.claude/CLAUDE.md`.
- Proved REL-05 by ancestry and a green full CI run; fast-forwarded local main (D-02).

## Task Commits
1. **Task 1: rebuild gate-prefix list** - `57bebd9` (docs). Numstat: 4 added, 1 deleted in each of the two files.
2. **Task 2: REL-05 proof, D-02 fast-forward, phase gate runs** - no commit of its own (ref move and verification only); evidence below.

**Plan metadata:** the SUMMARY commit that follows this file.

## Prefix inventory (from the sh tests/run.sh transcript, gate count per file and first-level prefix)

Shared prefixes (the list entries):
- test_ci_gates.sh: ci 2, run 2
- test_discovery.sh: order 5 (rest free-form)
- test_exit_contract.sh: contract 62, argument 15, no_marker 4, glob_newline_not_passed 3, real_hostile_reached_compiler 2
- test_home_guard.sh: homeguard 13
- test_install_codex.sh: local 25, first 12, probe 8, docs 4 (docs_url_*), foreign 5, existing 4, with 5, installer 2, plus free-form
- test_install_pages.sh: claude 46, codex 45, link 9, readme 8, installer 2
- test_noroute_notice.sh: notice 57
- test_path_scrub.sh: pathscrub 14
- test_release_text_mutation.sh: release_mut 17
- test_static_guards.sh: static 32
- test_tier2_fake.sh: url 16, req 9, mode 5, plus free-form
- test_tier2_live.sh: live 7 (plus tier2_syntax 1)
- test_check_order.py: checkorder 10
- test_ci_guards.py: ci_guard 11
- test_layout.py: layout 20
- test_release_text.py: release 11
- test_skill_examples.py: skills 176

Free-form (no shared prefix): test_claude_plugin.sh, test_codex_patch.sh, test_discovery.sh (apart from order_), test_hook_review_fixes.sh, test_never_execute.sh, test_real_compiler.sh.

## Decision: no prefix-sync gate
Not added, for the three reasons in the plan objective: CONTEXT forbids CI running the suite twice; a gate cannot read `.planning/codebase/CONVENTIONS.md` because `/gsd-pr-branch` strips `.planning/` from the PR branch; and many gate names are built from variables (`"contract_$1_$2"`), so a static check that every printed prefix is documented is not possible. The list stays prose, regenerated from CONVENTIONS.md.

## REL-05 and D-02 evidence (verbatim)

```
ancestor b0a4c62
ancestor 3a42ebf
ancestor b600ac4
ancestor 172e6a5
```

- `MAIN_FF_OK`: local `main` moved from `3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b` to `f15c257f6fba6e5d4cde60e49ad06727de44f68f` via `git fetch . origin/main:main` (source is the local repository, no remote contacted). HEAD is still `gsd/planning-setup`, `git log --oneline origin/main..main` prints nothing, and `git status --porcelain` is unchanged by the step. Nothing was pushed. Rollback, only on request: `git update-ref refs/heads/main 3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b`.
- `sh tests/ci.sh`: exit 0
  - `SUMMARY: ok=787 fail=0 skip=0`
  - `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`
- Fake `bbjcpl` and `bbjcplw` first on PATH, `sh tests/run.sh`: exit 0
  - `SUMMARY: ok=787 fail=0 skip=0`

Flagged assumption (carried forward): "the release tree" means `gsd/planning-setup`. Per CONTEXT D-01 the review-fix commits stay on that branch, Phases 7-10 build on it, and the Phase 10 `/gsd-pr-branch` PR carries them to `main`; the filter drops only `.planning/`, so the commits' files are kept. Plan 07-01 deliberately reverses the skip half of `3a42ebf` (D-05); REL-05 is about the commits being present, which ancestry proves.

## Decisions Made
See key-decisions. Both follow the plan and CONTEXT D-01, D-02, D-03.

## Deviations from Plan

One small addition inside the plan's rule "the transcript wins": `installer_` is also listed under `test_install_codex.sh` (2 gates: installer_executable, installer_no_compiler_calls), and `test_discovery.sh` `order_` is listed in the Shell tests sub-bullet as well as being noted in the free-form sub-bullet. No rule triggered; no fix attempts.

**Total deviations:** 0 (documentation detail only). **Impact on plan:** none.

## Issues Encountered
None. The unrelated working-tree files `.planning/config.json`, `.planning/milestone.lock` and `.planning/state.json` were left untouched and uncommitted.

## Known Stubs
None.

## Threat Flags
None. No new network, auth or file-access surface; no push, no remote fetch.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
Phase complete, ready for verification.

## Self-Check: PASSED
- `.planning/codebase/CONVENTIONS.md` and `.claude/CLAUDE.md` FOUND; commit `57bebd9` FOUND in HEAD ancestry; `git rev-parse main` equals `origin/main`.

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-12*
