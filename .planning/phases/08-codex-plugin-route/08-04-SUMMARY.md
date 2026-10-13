---
phase: 08-codex-plugin-route
plan: 04
subsystem: installer
tags: [codex, install-codex, remove, refusals, left-in-place, posix-sh, wave-1-closing-gate]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-03 --remove, remove_server/remove_all and the rm_env, rm_user_cfg, rm_snap helpers; 08-01 and 08-02 merged unchanged (closing gate)"
provides:
  - "--remove with --with-local and --remove with --force refused with exit 2 before any filesystem access"
  - "exit-2 and exit-3 text for remove mode in the header and usage() of codex/install-codex.sh"
  - "13 new remove_ gates (27 in total): 5 refusals and space-path round trip, 8 left-in-place gates covering 6 bbj-docs forms, 2 bbj-local forms, differing and symlinked skill, extra file in the script directory, edited and symlinked hooks.json, and per-object removal"
  - "wave-1 closing gate: sh tests/run.sh on the merged plans 08-01, 08-02, 08-03 plus this plan ends ok=881 fail=0 skip=0"
affects: [08-06, 08-07]

actuals:
  tokens: 4350
  tasks: 2
  commits: 3
plan_head_before: 9e8de98ef5f86e472940352d343fac00396d3893
plan_head_after: a6e2b6197586bd030f0ec5197e7e1beb598ebb65

tech-stack:
  added: []
  patterns:
    - "Sub-case gates: one gate per object class, one temp home per sub-case, failing sub-case names collected in a list and printed in the FAIL detail"
    - "User forms are built with awk or printf into a new file and compared with cmp, diff -r and readlink after --remove; never sed -i"
    - "Each new gate shown able to fail by nine one-line mutants of a copied installer (scratch tree outside the repo)"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/test_install_codex.sh

key-decisions:
  - "D-03 over RESEARCH A10: --remove --force is refused with exit 2, not allowed to delete a differing skill directory; the message tells the user to copy out what they want and delete the directory by hand"
  - "The two refusals sit right after the option loop, before the docs-url check and every filesystem access, so exit 2 always means nothing was written"
  - "No installer logic changed for the left-in-place matrix: remove_server and remove_all from 08-03 already keep every form, so Task 2 is a test-only commit"

patterns-established:
  - "rm_refused ENV: install, edit a skill file, snapshot, so a refusal that wrongly went on to remove shows up as a snapshot change"
  - "rm_docs_case NAME AWKPROGRAM and rm_local_case NAME (stdin): one sub-case helper per server"

requirements-completed: [CODEX-06]

coverage:
  - id: D1
    description: "--remove --with-local and --remove --force exit 2 with their message and an unchanged home snapshot; a missing Codex home and a newline in --skills-dir exit 2 and create nothing; a Codex home and skills dir with a space round-trip to the pre-install snapshot"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#remove_refuses_with_local, remove_refuses_force, remove_refuses_missing_home, remove_refuses_newline, remove_codex_home_with_space"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every form the installer does not write is left byte for byte with exit 3 and a 'left in place' line: six bbj-docs forms, a hand-registered bbj-local and an edited managed bbj-local block, a differing skill directory, a symlinked skill directory, a user file in the check-script directory, an edited hooks.json and a symlinked hooks.json"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#remove_left_docs_forms, remove_left_local_forms, remove_left_skill_differs, remove_left_skill_symlink, remove_left_script_dir_extra_file, remove_left_hooks_edited, remove_left_hooks_symlink"
        status: pass
    human_judgment: false
  - id: D3
    description: "Per object, not all or nothing: with a differing skill directory left, the installer's config.toml tables, the check script and its directory, hooks.json and the identical skill are still removed"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#remove_left_others_removed"
        status: pass
    human_judgment: false
  - id: D4
    description: "Wave-1 closing gate: the full suite and the static guards pass on the merged plans 08-01, 08-02, 08-03 and this plan"
    verification:
      - kind: integration
        ref: "sh tests/run.sh (SUMMARY: ok=881 fail=0 skip=0); sh tests/test_static_guards.sh (no FAIL); shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh"
        status: pass
    human_judgment: false

duration: 16min
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 04: Remove Refusals and the Left-in-Place Matrix Summary

**`install-codex.sh --remove` now refuses `--with-local` and `--force` with exit 2 before any write, and 13 new gates prove that every bbj-docs, bbj-local, skill, check-script and hooks.json form the installer did not write is kept byte for byte with exit 3 while the installer's own objects are still removed; the merged wave 1 passes the full suite at ok=881 fail=0.**

## Performance

- **Duration:** 16 min
- **Started:** 2026-10-13T14:33:50Z
- **Completed:** 2026-10-13T14:50:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Two refusals right after the option loop, ahead of every filesystem access: `--remove and --with-local cannot be combined` and `--remove does not take --force: a skill directory that differs is yours; copy out what you want to keep and delete it by hand` (D-01, D-03; T-08-13). The header paragraph on exit 2 and `usage()` list the remove-mode exit-2 cases.
- Five Task 1 gates: both refusals compare `home_snapshot` before and after (with an edited skill in place, so a refusal that went on to remove would show), a missing Codex home creates no directory (T-08-16), a newline in `--skills-dir` changes nothing, and a Codex home plus skills dir with a space round-trip to the pre-install snapshot.
- Eight Task 2 gates, with one temp home per sub-case: `remove_left_docs_forms` (extra key, comment, own OAuth table, `approval_mode = "prompt"`, single-quoted header, extra `bbj_check_syntax` tool table), `remove_left_local_forms` (hand-registered table, managed block with an extra key), `remove_left_skill_differs`, `remove_left_skill_symlink`, `remove_left_script_dir_extra_file`, `remove_left_hooks_edited`, `remove_left_hooks_symlink` and `remove_left_others_removed`. The extra-tool-table case that 08-03 left uncovered is now covered.
- Wave-1 closing gate: the first full-suite run on the merged plans 08-01 to 08-04 ends `ok=881 fail=0 skip=0` (the orchestrator's earlier run on the wave was 868; 13 new gates). The static guards and shellcheck are clean. No file outside this plan's two failed, so there is no integration failure to record.

## Task Commits

1. **Task 1 RED: failing refusal gates** - `e379744` (test) - `remove_refuses_with_local` and `remove_refuses_force` failed with exit 3 (remove mode ignored both options); the other three gates passed at once because 08-03 already had that behavior and they only pin it
2. **Task 1 GREEN: the two refusals** - `51ec535` (feat)
3. **Task 2: the left-in-place matrix** - `a6e2b61` (test)

**Plan metadata:** recorded in the docs(08-04) commit that adds this file.

## Files Created/Modified

- `codex/install-codex.sh` - two refusals after the option loop; exit-2 paragraph in the header; exit text of `usage()`
- `tests/test_install_codex.sh` - `rm_refused`, `rm_docs_case`, `rm_local_case` and the 13 gates

## TDD Gate Compliance

- Task 1: RED commit `e379744` (test), GREEN commit `51ec535` (feat), no REFACTOR. Semantic assessment of the RED evidence: the two target gates executed and failed on the planned assertion (exit code 2 expected, 3 observed, because remove mode ran past the unrecognised combination). The project's `gate` line format is not one of the report formats the `check tdd-red-evidence` classifier reads, so the verdict was inspected by hand from the gate output; no classifier record was produced.
- Task 2: no RED commit. The eight gates passed on their first run because the 08-03 code already keeps every form; the plan allows fixing `remove_server` or `analyze` "only where a form is not yet recognised as foreign", and none needed it. To show the gates are not blind, each was run against nine one-line mutants of a copied installer in a scratch tree outside the repo; every mutant failed exactly the intended gate: extra-key check removed (docs_forms, local_forms), anytool check removed (docs_forms f), skill diff always true (skill_differs), skill symlink check off (skill_symlink), hooks cmp always true (hooks_edited), hooks symlink check off (hooks_symlink), script directory removed with `rm -rf` (script_dir_extra_file), by-hand bbj-local allowed (local_forms a), pending not set for a differing skill (skill_differs).

## Decisions Made

- `--remove --force` is refused rather than allowed to delete a differing skill directory (D-03 over RESEARCH A10), so a 0.1.0 install whose skills differ from 0.2.0 follows the documented step: copy out edits, delete the directory, run `--remove` again (plan 08-07 writes it into the switch section).
- The refusals come before the docs-url validation so that exit 2 never follows a filesystem access.

## Deviations from Plan

None - plan executed exactly as written. (Commit trailer: the commits carry `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` per the harness attribution instruction, as in 08-03, not the Fable 5.1 name in the dispatch note.)

**Total deviations:** 0
**Impact on plan:** none.

## Issues Encountered

None. The first full-suite run on the merged wave 1 passed.

## Known Stubs

None.

## Threat Flags

None. No new network endpoint, auth path or trust boundary; the change adds refusals and tests only.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `--remove` is complete for installer behavior (CODEX-06 code side). Plan 08-05 (the other wave-2 plan) does not touch `tests/`. Plan 08-06 still owes the real Codex 0.162.1 run of install, `--remove` and the plugin route; plan 08-07 owns `docs/install-codex.md`, the switch section (including the by-hand step for a differing skill directory) and the `remove_` prefix entry in `.claude/CLAUDE.md`.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*

## Self-Check: PASSED

- `codex/install-codex.sh`, `tests/test_install_codex.sh`: found
- Commits `e379744`, `51ec535`, `a6e2b61`: found on HEAD's history
- `sh tests/test_install_codex.sh`: no FAIL line, 27 `remove_` gates ok (8 `remove_left_`)
- `sh tests/test_static_guards.sh`: no FAIL line; shellcheck clean; `sh tests/run.sh`: `SUMMARY: ok=881 fail=0 skip=0`
