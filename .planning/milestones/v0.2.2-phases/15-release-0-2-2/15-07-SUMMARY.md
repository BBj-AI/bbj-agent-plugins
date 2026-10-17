---
phase: 15-release-0-2-2
plan: 07
subsystem: release
tags: [release, merge, ci, install-gate, claude-code, codex]

requires:
  - phase: 15-release-0-2-2
    provides: "15-06 ready PR #4 'Release 0.2.2' at head d7e5a53, CI and install gate green on that head"
provides:
  - "merge commit 0e9b3c0d on origin/main: two parents (4234e76, d7e5a53), tested tree e141f79b, no .planning/ path"
  - "CI success on main for the merge commit"
  - "fresh installs of 0.2.2 from main in Claude Code and Codex, recorded in planning only"
affects: [15-08 tag and Release]

commits: 2
plan_head_before: 48159b0b30049d2ff3a2bfaf661ff5f43eb5e657
plan_head_after: 0785ca4d4605e0dcc019aa82959947c7f06bf5af

actuals:
  tokens: 30000
  tasks: 3
  commits: 2

tech-stack:
  added: []
  patterns: ["merge with --merge --match-head-commit; parents and tree compared after the merge", "post-merge installs gate the tag"]

key-files:
  created:
    - .planning/phases/15-release-0-2-2/evidence/premerge.txt
    - .planning/phases/15-release-0-2-2/evidence/merge.txt
    - .planning/phases/15-release-0-2-2/evidence/install-gate-main.txt
    - .planning/phases/15-release-0-2-2/evidence/codex-hook-main.txt
  modified:
    - .planning/phases/15-release-0-2-2/15-LINUX-RUN.md

key-decisions:
  - "Owner replied 'merge' for Task 2; the only remote action was gh pr merge 4 --merge --match-head-commit d7e5a53 (no squash, no rebase, branch kept)"
  - "No tag, no Release, no other push: the tag is plan 15-08 and needs its own owner decision"

requirements-completed: [REL-10]

coverage:
  - id: D1
    description: "Merge preconditions read before the merge (head, base, mergeable, checks, tag absence, no protection)"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/premerge.txt; re-checked immediately before the merge (head, state, origin/main, no tag)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Main is a two-parent merge of the old main and the tested head with the tested tree; CI success on main"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/merge.txt; plan Task 3 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D3
    description: "Claude Code and Codex install 0.2.2 fresh from main (D-10); Codex hook trust bypassed in the throwaway home and claimed nowhere"
    requirement: REL-10
    verification:
      - kind: integration
        ref: ".planning/phases/15-release-0-2-2/evidence/install-gate-main.txt and codex-hook-main.txt"
        status: pass
    human_judgment: false

duration: not measured (continuation run covered the merge and Task 3)
completed: 2026-10-17
status: complete
---

# Phase 15 Plan 07: Merge the release PR and prove main installs Summary

**PR #4 "Release 0.2.2" is merged into main as merge commit 0e9b3c0d368573047c71e8530ac0b19f89343a3c, which carries exactly the tested tree e141f79b, passed CI, and installs 0.2.2 fresh in Claude Code 2.1.301 and Codex 0.162.1.**

## Performance

- **Tasks:** 3 (Task 1 tracer, Task 2 owner decision, Task 3 merge and post-merge proof)
- **Files:** 4 evidence files created, `15-LINUX-RUN.md` extended

## Accomplishments

- Immediately before the merge: PR #4 open, not draft, head d7e5a53ef31690a49834d760b3eee3c63e95501a, origin/main 4234e76ccb369d0fe984ac36825e06b3b8fbf3f1, no 0.2.2 or v0.2.2 tag on origin.
- Merge: `gh pr merge 4 --merge --match-head-commit d7e5a53...` after the owner's "merge". M = 0e9b3c0d368573047c71e8530ac0b19f89343a3c has exactly two parents (4234e76 and d7e5a53), tree e141f79b082f139bab8c0e061497ffe95bfa4bc5 (equal to the tested tree), and 0 `.planning/` paths.
- CI on main for M: success, https://github.com/BBj-AI/bbj-agent-plugins/actions/runs/39007523223.
- Claude Code (2.1.301): `install-gate.sh BBj-AI/bbj-agent-plugins` printed all seven `install_*` gates ok at 0.2.2 (`install_gate_main: pass`).
- Codex (codex-cli 0.162.1): served 0.2.2 from a clone at M, listed the docs server `bbj` (`https://mcp.bbj-ai.com/mcp`), `bbjcpl reported 1 error(s)` for a bad file, silence for a clean one, `hk_trust: bypassed` (`codex_main: pass`). The throwaway Codex home was removed.
- `15-LINUX-RUN.md` has the new section `## After the merge (D-10)`; the CHANGELOG is unchanged (D-10), no upgrade reading was taken (D-20).

## Task Commits

1. **Task 1: pre-merge preconditions (read only)** - `282cee1`
2. **Task 2: owner confirmation (checkpoint:decision, blocking-human)** - no commit; the owner replied "merge" on 2026-10-17
3. **Task 3: merge, proof, CI on main, post-merge installs** - `0785ca4`

**Plan metadata:** the commit holding this SUMMARY, STATE.md and ROADMAP.md.

## Files Created/Modified

- `evidence/premerge.txt` - read-only preconditions
- `evidence/merge.txt` - M, parents, tree, `main_ci`, `install_gate_main: pass`, `codex_main: pass`
- `evidence/install-gate-main.txt`, `evidence/codex-hook-main.txt` - the two post-merge installs (home path replaced by `<home>`, run directory by `<out>`)
- `15-LINUX-RUN.md` - section `## After the merge (D-10)` before `## For the CHANGELOG`

## Decisions Made

- The only remote change was the one authorized merge; the branch `gsd/release-0.2.2` was kept.
- Plan 15-08 may tag M: both post-merge installs read `pass` in merge.txt and no tag exists.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. `evidence/install-gate-main.txt` ends with a `exit=0` line (the gate's exit status), as in `install-gate-pr.txt`. The uncommitted mode change on `release-run/owner.sh` was left untouched, as instructed.

## User Setup Required

None. No sign-in was needed: the post-merge readings use the hook and the docs-server listing only.

## Next Phase Readiness

Main carries the tested 0.2.2 tree and installs. The tag 0.2.2 and the GitHub Release are plan 15-08 and need a separate owner decision. Nothing was tagged or published here.

## Self-Check: PASSED

- origin/main = 0e9b3c0d368573047c71e8530ac0b19f89343a3c, two parents (4234e76, d7e5a53), tree e141f79b; plan Task 3 verify printed `ok`
- CI run 39007523223 conclusion success for headSha M
- evidence files exist: premerge.txt, merge.txt, install-gate-main.txt, codex-hook-main.txt; no real home path in them
- Commits 282cee1 and 0785ca4 are on the planning branch
- No tag 0.2.2 or v0.2.2 on origin
