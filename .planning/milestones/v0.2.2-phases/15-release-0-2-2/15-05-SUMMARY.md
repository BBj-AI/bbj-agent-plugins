---
phase: 15-release-0-2-2
plan: 05
subsystem: release
tags: [release-candidate, strict-pr-branch, claude-code, codex, oauth-signin, live-suite, d-17]

requires:
  - phase: 15-release-0-2-2
    provides: "plan 15-02 release-run scripts (run.sh, owner.sh, install-gate.sh, codex-hook.sh); plan 15-01 CI pin 2.1.301; plans 15-03/15-04 version 0.2.2 and project notes"
provides:
  - "local branch gsd/release-0.2.2 (89 commits on origin/main, planning-free, tree-equal to the planning branch outside .planning/) and its worktree, not pushed"
  - "15-LINUX-RUN.md: the Linux release-tree record, with the `## For the CHANGELOG` block of 27 keys plan 15-06 copies from"
  - "evidence/pr-branch.txt, install-gate-run.txt, codex-hook-run.txt, rc-suite-run.txt"
affects: [15-06, 15-07, 15-08, 15-09]

actuals:
  tokens: 25600
  tasks: 3
  commits: 2
plan_head_before: cd64a2d713816f785c2a6341d40458ce9ffab957
plan_head_after: fabef573777f0ea26b20719086b106734284068b

tech-stack:
  added: []
  patterns:
    - "strict PR branch built by per-commit cherry-pick with .planning/ filtered, in a worktree"
    - "throwaway client homes under <home>/.cache/bbj-phase15/, removed after the record"

key-files:
  created:
    - .planning/phases/15-release-0-2-2/15-LINUX-RUN.md
    - .planning/phases/15-release-0-2-2/evidence/pr-branch.txt
    - .planning/phases/15-release-0-2-2/evidence/install-gate-run.txt
    - .planning/phases/15-release-0-2-2/evidence/codex-hook-run.txt
    - .planning/phases/15-release-0-2-2/evidence/rc-suite-run.txt
  modified: []

key-decisions:
  - "D-17 blackhole address http://192.0.2.1:5009/mcp used as is: the probe showed it drops packets (curl exit 28), the owner replied `blackhole: D-17`; no other address was tried"
  - "cc_tool_name recorded as `not shown`: the owner listed the 5 tools but did not open the detail view of bbj_search"
  - "cx_login_command recorded as `codex mcp login bbj` with cx_login_option `--no-browser` (the owner typed `codex mcp login --no-browser bbj`)"
  - "NAME-03 observation recorded: the owner's Claude Code /mcp also listed the claude.ai connector `claude.ai BBj` above the plugin's docs server `plugin:bbj:bbj`"

patterns-established:
  - "Owner reply lines are copied into the record verbatim; any authorization URL in a paste is dropped"

requirements-completed: [NAME-03, REL-10]

duration: 35min (this continuation, Task 3 only; Task 1 and the owner wait not included)
completed: 2026-10-16
status: complete
---

# Phase 15 Plan 05: Release candidate and Linux release-tree run Summary

**Release candidate gsd/release-0.2.2 (head 0d619fb, 89 planning-free commits on origin/main) installed fresh into real Claude Code 2.1.301 and Codex 0.162.1, owner sign-in under `bbj` completed in both, and the full live suite on the release tree at `SUMMARY: ok=864 fail=0 skip=0`.**

## Performance

- **Duration:** 35 min for the continuation (Task 3); Task 1 start time was not recorded and the owner's Task 2 wait is not counted
- **Started (continuation):** 2026-10-16T18:13:51Z (plan ledger written at the Task 1 commit)
- **Completed:** 2026-10-16T18:48Z
- **Tasks:** 3 (Task 1 tracer, Task 2 human-action checkpoint, Task 3 auto)
- **Files modified:** 5 (all created, planning-side)

## Accomplishments

- Release candidate: branch `gsd/release-0.2.2` at head `0d619fb5f8de5043a3eb8771ce3006b537584653`, tree `9146b54d5f962b7bf377abfe16e8a4df1caa323b`, base `4234e76` (origin/main, tag 0.2.1); `planning_paths: 0`, `tree_equal: yes`, `version: 0.2.2`; not on origin.
- NAME-03 on Linux: real Claude Code lists the docs server as `plugin:bbj:bbj`, `! Needs authentication` before the owner's sign-in and `✔ Connected` after (the owner's `/mcp` printed `Authentication successful. Connected to plugin:bbj:bbj.`); real Codex lists `bbj`, `Not logged in` then `OAuth` after `codex mcp login --no-browser bbj` ("Successfully logged in to MCP server 'bbj'.").
- Hook readings on the same tree: installed Claude Code hook run directly gives exit 2 and `bbjcpl reported 1 error(s)` for a bad file, exit 0 and silence for a clean one (all seven `install_*` gates ok at 0.2.2); Codex `apply_patch` of a bad file gets `bbjcpl reported 1 error(s)`, a clean file is silent, hook trust bypassed in the throwaway home (stated, never claimed as taken). `bbj-local` shows `✔ Connected` on `127.0.0.1:5009` once enabled.
- REL-10 run half: `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_LS_BLACKHOLE_URL=http://192.0.2.1:5009/mcp sh tests/ci.sh` in the release-tree worktree ends `SUMMARY: ok=864 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`; `live_blackhole_connect_timeout`, `claudeplugin_mcp_docs_answers` and `claudeplugin_mcp_docs_oauth` all ok. The run's claude (2.1.301) equals the CI pin of the release tree (D-19).
- Real homes untouched: the three cksum lines (Codex `config.toml`, two Claude Code plugin files) are identical before and after. Token-holding throwaway homes (`claude`, `codex`, `codexhook`, `dryrun-*`) were removed; the release-tree worktree stays for plan 15-06.

## Task Commits

1. **Task 1: release candidate built, both clients installed from it, scripted readings, record started** - `0b532e2` (docs)
2. **Task 2: owner sign-in in both clients and the D-17 answer** - no commit (checkpoint:human-action; replies recorded in the Task 3 commit)
3. **Task 3: after readings, live suite, record completed, token homes removed** - `fabef57` (docs)

**Plan metadata:** the final `docs(15-05)` commit that carries this SUMMARY, STATE.md, ROADMAP.md and REQUIREMENTS.md.

## Files Created/Modified

- `.planning/phases/15-release-0-2-2/15-LINUX-RUN.md` - Linux release-tree record, rounds 1 and 2 for both clients, suite, CI pin, and the `## For the CHANGELOG` block (27 keys, none empty)
- `.planning/phases/15-release-0-2-2/evidence/pr-branch.txt` - branch, base, head, tree, commits, planning_paths, tree_equal, version
- `.planning/phases/15-release-0-2-2/evidence/install-gate-run.txt` - Claude Code install gate on the release tree
- `.planning/phases/15-release-0-2-2/evidence/codex-hook-run.txt` - Codex hook readings (`hk_*`)
- `.planning/phases/15-release-0-2-2/evidence/rc-suite-run.txt` - full output of the release command (home replaced by `<home>`)

## Decisions Made

- Used D-17's blackhole address unchanged; the probe (`curl` exit 28, empty `remote_ip`) showed it drops packets, and the owner answered `blackhole: D-17`. `blackhole_approval: D-17`.
- Recorded `cc_tool_name: not shown` rather than guess a full tool name; the owner's `/mcp` listed 5 tools (`bbj_examples`, `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word`, `bbj_search`) but the `bbj_search` detail was not opened.
- `cx_login_command` is `codex mcp login bbj` and `cx_login_option` is `--no-browser` (owner's typed command: `codex mcp login --no-browser bbj`).
- Recorded the claude.ai connector observation (NAME-03) in the Claude Code round 2 of the record: the owner's `/mcp` also listed `claude.ai BBj` (5 tools), `claude.ai Claude Docs` and `claude.ai Google Drive` under a "claude.ai" heading, above the plugin's docs server.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] 15 .planning/-only modify/delete cherry-pick conflicts resolved by the strict filter**
- **Found during:** Task 1 (building the release candidate)
- **Issue:** 15 commits of `bd711f2..gsd/planning-setup` that touch paths outside `.planning/` also touch `.planning/` files that do not exist in the base (origin/main) by construction, so `git cherry-pick --no-commit` stopped with a modify/delete conflict on a `.planning/` path only. The plan says a conflict stops the plan.
- **Fix:** The Task 1 executor resolved each conflict by the strict filter itself (`git rm --cached` of the `.planning/` path, no choice about content outside `.planning/`). No conflict touched a path outside `.planning/`; no commit became empty. The owner saw the deviation in the Task 1 hand-over and did not object.
- **Files modified:** none beyond the strict filter (recorded in `evidence/pr-branch.txt`, line `conflicts:`)
- **Verification:** `planning_paths: 0` and `tree_equal: yes` in `evidence/pr-branch.txt`; the Task 1 verify passed.
- **Committed in:** `0b532e2`
- **The 15 commits** (from `$HOME/.cache/bbj-phase15/conflicts.txt`): 6940a470a713015bdb155ceec6a946c4d72e903d, 4f1d31ca9e10b800b42dfae43744a8212a863227, d0c7e7fa8df59b3e96d1b493b2652f590ee5130b, 42ae362d470bb843bdd618789ff573fa096ff067, 66c253d3446b97a65bb5c23f414ebb5a967eb04e, 55a0a51d7ad633a4b37951e0f0386e3671c861b8, a02ff308793fbf5d516b134ecb0182e622a85aa2, 46a80de2781d542be6122e7af53f9f1965a4aee0, 2affe32a53e608219b38b7a2b85acfa4d601657f, 3f6d5595afb3e32f982e29e85f0977b95484e879, 30da00194cd3eed509cefe6bfa3f0b0975f084c7, cbe6c5bdb21d3c9f05ad9bddb8cdb3d085346b4c, d40d1da3e1e92f2910614b52a90febccd1a84664, 6aa73e5f7834b4cff6f0cd38a5e28b9cd70d9128, dcee30413e9e2906ecdef59826e6991ab618e9d7

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** None on the release candidate: the strict filter is what the plan wanted; the deviation only records that the conflict stop-rule was applied to .planning/-only conflicts.

## Authentication Gates

Task 2 was the planned human-action checkpoint: the owner signed in to the docs server `bbj` in the throwaway Claude Code configuration (`/mcp`) and the throwaway Codex home (`codex mcp login --no-browser bbj`). No agent signed in, trusted or approved anything. The owner's paste contained a used authorization URL; it is recorded nowhere (record, evidence, commits).

## Issues Encountered

- Local file mode: the owner made `release-run/owner.sh` executable (100644 to 100755) to run it directly. That mode change is left uncommitted on purpose, as are `.planning/milestone.lock` and `.planning/state.json`.
- The interactive shell shadows `grep` with a `ugrep` function; the plan's verify lines were run from `bash` scripts where the system `grep` applies.

## User Setup Required

None - no external service configuration required.

## Known Stubs

None. (The record's `cc_tool_name: not shown` is an honest "not shown" value, not a stub.)

## Threat Flags

None - no new network endpoint, auth path, file access pattern or schema at a trust boundary; the run is scripted evidence only.

## Next Phase Readiness

- Plan 15-06 can copy from the `## For the CHANGELOG` block of `15-LINUX-RUN.md` (27 keys, `cc_signin: completed`, `cx_signin: completed`) and from the worktree `$HOME/.cache/bbj-phase15/release-tree` (head 0d619fb). Nothing is pushed; `gsd/release-0.2.2` is local only.
- Note for 15-06: `cc_tool_name` is `not shown`, so the CHANGELOG must not name a full tool name.

## Self-Check: PASSED

- FOUND: `15-LINUX-RUN.md`, `evidence/pr-branch.txt`, `evidence/install-gate-run.txt`, `evidence/codex-hook-run.txt`, `evidence/rc-suite-run.txt`
- FOUND commits: `0b532e2`, `fabef57` (ancestors of HEAD)
- Task 3 verify printed `ok`; `gsd/release-0.2.2` head equals `head:` in pr-branch.txt; branch not on origin; real-home cksums identical.

---
*Phase: 15-release-0-2-2*
*Completed: 2026-10-16*
