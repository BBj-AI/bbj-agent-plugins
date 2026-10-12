---
phase: 06-release-0-2-0
plan: 01
subsystem: release-prerequisites
tags: [bbj-skills, claim-ledger, review-disposition, shellcheck, busybox]

requires:
  - phase: 04-bbj-programming-makeover
    provides: the open review findings WR-01, IN-01, IN-02, WR-08 and the claim ledger
provides:
  - Phase 4 review record at open 0 (WR-01, IN-01, IN-02 fixed; WR-08 skipped with its reason)
  - Three narrowed sentences in the bbj-programming skill, no new claim
  - A shellcheck-clean tests/ tree, so the ci_shellcheck gate can pass
  - shellcheck 0.11.0 and busybox 1.37.0 on the release machine, so no tool-dependent gate skips
affects: [06-02 version bump, 06-03 skip=0 run, 06-06 release run]

actuals:
  tokens: 5300
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Post-review note appended to the evidence cell of a ledger row, claim and verdict unchanged"
    - "ShellCheck directive: comment line directly above the flagged line, code plus two spaces, reason"

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - plugins/bbj/skills/bbj-programming/references/sysgui.md
    - .planning/phases/04-bbj-programming-makeover/04-LEDGER.md
    - .planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md
    - tests/test_noroute_notice.sh

key-decisions:
  - "IN-01 written in the long form: the fetched getActiveContext page shows a window with flag $02$ before and one after the $80002$ window"
  - "WR-08 skipped, not fixed: plan 04-07 already names the URL, table t and column col as placeholders in references/database.md"
  - "No global shellcheck disable: two inline directives with reasons instead"

requirements-completed: [REL-03]

duration: 3min
completed: 2026-10-12
status: complete
plan_head_before: 01cd4f4ec0d19db2746ac2413fd3fbd15c07bc00
plan_head_after: d08878f4896654f7ae47270ddd37c893de5cb5f3
commits: 3

coverage:
  - id: D1
    description: "WR-01: SKILL.md lists the sign characters alone, says to put one of these in every mask that can format a negative value, and names @ and & as currency mask characters that are not sign characters"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py (skills_route_bbjcpl ok, skills_route_bbj-ls ok)"
        status: pass
      - kind: unit
        ref: "python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py"
        status: pass
    human_judgment: false
  - id: D2
    description: "IN-02 and IN-01: sysgui.md scopes the modal sentence to top-level windows and describes $80002$ as setting the Dialog bit"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py"
        status: pass
      - kind: unit
        ref: "python3 -I tests/test_layout.py"
        status: pass
    human_judgment: false
  - id: D3
    description: "Phase 4 review record reads open: 0, total: 15, with WR-08 skipped and its reason in the Source cell"
    requirement: REL-03
    verification:
      - kind: other
        ref: "grep -x 'open: 0' 04-REVIEW-DISPOSITION.md plus the Task 2 verify block"
        status: pass
    human_judgment: false
  - id: D4
    description: "ci_shellcheck can pass and the busybox and shellcheck gates run instead of skipping"
    requirement: REL-03
    verification:
      - kind: other
        ref: "shellcheck -s sh $(ls plugins/bbj/scripts/*.sh codex/*.sh tests/*.sh) exits 0"
        status: pass
      - kind: unit
        ref: "sh tests/test_exit_contract.sh (gate contract_busybox_ lines, no skip) and sh tests/test_static_guards.sh (gate static_shellcheck_ lines, no skip)"
        status: pass
    human_judgment: false
---

# Phase 6 Plan 01: Pre-release loose ends Summary

**The four open Phase 4 review findings are settled (three fixed by narrowing claims, one skipped as already resolved), the review record reads open 0, and shellcheck plus busybox are installed with a clean ci_shellcheck.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-10-12T12:51:47Z
- **Completed:** 2026-10-12T12:54:37Z (task commits; metadata after)
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- WR-01: `@` and `&` are now named as the currency mask characters of the BBj-specific Numeric Output page and are no longer listed with the sign characters. The maintainer-confirmed sentence (ledger L031, grant D-22) is word for word unchanged. I fetched numeric_output_bbj.htm: `@` is "replaced by the three-character international currency code" and `&` "by the local currency symbol".
- IN-02: sysgui.md reads "For a modal top-level window, pass the Dialog flag."; the MDI sentence is unchanged.
- IN-01: sysgui.md says `$80002$` "sets the Dialog bit (two windows with flag `$02$` surround it)". The long form was written because the fetched getActiveContext page shows `win1! = sg!.addWindow(100,100,300,300,"Win1",$02$)` before `win2! = ...,"Win2",$80002$)` and `win3! = ...,"Win3",$02$)` after it, then "Should print 2 (the modal window)". The D-24 front rule (L151) is untouched.
- WR-08: set to skipped. The SQL-verb block's URL, table `t` and column `col` are already named placeholders in references/database.md (plan 04-07, commits 5ed9517 and 36d1fca).
- 04-REVIEW-DISPOSITION.md ends at `open: 0`, `total: 15`. Ledger rows L031 and L117 carry dated post-review notes.
- ci_shellcheck blocker removed: two inline directives with reasons in tests/test_noroute_notice.sh (SC2209, SC2034); `.shellcheckrc` unchanged.
- Tools installed with `sudo apt-get install -y shellcheck busybox`: ShellCheck 0.11.0, BusyBox v1.37.0 (Ubuntu 1:1.37.0-7ubuntu1). `busybox sh -c :` works, so `busybox-static` was not needed.

## Per-finding disposition

| Finding | Disposition | Commit |
|---------|-------------|--------|
| WR-01 | fixed | `7becc1c` |
| IN-02 | fixed | `0210c5b` |
| IN-01 | fixed (long form) | `0210c5b` |
| WR-08 | skipped (resolved by 04-07) | `0210c5b` |

## Task Commits

1. **Task 1: WR-01 end-to-end slice (tracer)** - `7becc1c` (fix)
2. **Task 2: IN-02, IN-01, WR-08, review record at open 0** - `0210c5b` (fix)
3. **Task 3: shellcheck directives and tools** - `d08878f` (test)

**Plan metadata:** the docs commit that carries this file.

## Files Created/Modified

- `plugins/bbj/skills/bbj-programming/SKILL.md` - str() mask paragraph separates sign characters from currency characters; body is 155 lines
- `plugins/bbj/skills/bbj-programming/references/sysgui.md` - modal sentence scoped to top-level windows; `$80002$` described as setting the Dialog bit
- `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md` - post-review notes on L031 and L117
- `.planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md` - four findings settled, `open: 0`
- `tests/test_noroute_notice.sh` - two shellcheck directives with reasons

## Gate lines that prove no skip remains

- `sh tests/test_exit_contract.sh`: 27 `gate contract_busybox_*`, `argument_busybox`, `glob_newline_not_passed_busybox` and `no_marker_busybox` lines, all `ok`; no `skip` and no `FAIL` line.
- `sh tests/test_static_guards.sh`: `gate static_shellcheck_bbj-check.sh ok shellcheck -s sh passes` and `gate static_shellcheck_install-codex.sh ok shellcheck -s sh passes`; no `skip` line.
- `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`: exit 0, `gate skills_route_bbjcpl ok /opt/bbx/bin/bbjcpl: 34 file(s) in one call`, `gate skills_route_bbj-ls ok http://127.0.0.1:5009/mcp: 32 call(s)`.
- `sh tests/test_never_execute.sh`: exit 0, `gate sentinel_final ok still never ran`.

## Decisions Made

- IN-01 long form, because the fetched page shows both surrounding `$02$` windows.
- WR-08 skipped rather than fixed; the reason names the resolving commits.
- Inline shellcheck directives instead of a `.shellcheckrc` change, as the plan requires.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Task 1 verify pattern matched passing gate lines**
- **Found during:** Task 1 (verify block)
- **Issue:** The plan's check `grep -q '^gate .* FAIL'` also matches `ok` lines whose detail text contains the word FAIL. `skills_fx_structure_linked_skill_dir ok ... 'gate skills_structure_linked FAIL' ...` and the `skills_fx_ratchet_*` lines made the block print "example gate not green" although the script exited 0 with both routes `ok`.
- **Fix:** Ran the same verify with the stricter pattern `^gate [^ ]+ FAIL` (a FAIL status in the second field). All other checks ran exactly as written. Task 2 used the same stricter pattern.
- **Files modified:** none (verification command only)
- **Verification:** exit 0, no gate line with status FAIL, both route gates `ok`
- **Committed in:** not applicable

---

**Total deviations:** 1 auto-fixed (1 blocking, verification command only)
**Impact on plan:** None on the shipped files. Later plans that reuse this verify block should use the `^gate [^ ]+ FAIL` pattern.

## Authentication Gates

None. `sudo apt-get` ran without a password prompt.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. No new endpoint, auth path or file access; the edits only narrow existing claims.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for 06-02 (version bump): the Phase 4 review record is at `open: 0` before the bump, as D-16 requires.
- The EDGE REL-03 flag in the plan stands: the skip=0 run itself and the git-marketplace install check belong to plans 06-03 and 06-06. This plan covers only their prerequisites.

## Self-Check: PASSED

- FOUND: plugins/bbj/skills/bbj-programming/SKILL.md, plugins/bbj/skills/bbj-programming/references/sysgui.md, tests/test_noroute_notice.sh, 04-LEDGER.md, 04-REVIEW-DISPOSITION.md
- FOUND commits: 7becc1c, 0210c5b, d08878f (all ancestors of HEAD)

---
*Phase: 06-release-0-2-0*
*Completed: 2026-10-12*
