---
phase: 07-test-hardening-and-release-prep
plan: 02
subsystem: testing
tags: [sh, path-scrub, symlink-farm, mutation-proof, maint-06]

requires:
  - phase: 02-no-route-notice
    provides: the no-route notice gates in test_noroute_notice.sh and test_exit_contract.sh
provides:
  - no_compiler_path and no_compiler_env helpers in tests/lib.sh
  - scrubbed PATH for the no-route gates (test_noroute_notice.sh, test_exit_contract.sh, test_tier2_fake.sh)
  - tests/test_path_scrub.sh, 14 CI-run gates (prefix pathscrub_) proving the scrub is load-bearing with a fake compiler
affects: [07-04 conventions gate-prefix list, phase 9 Windows and macOS runs]

actuals:
  tokens: 3500
  tasks: 3
  commits: 3
commits: 3
plan_head_before: 84cd62d3c24ce50d722953767c51b272ce5894d8
plan_head_after: 4a268e7b54eabf7ca9f9109ef3faa4fe77f7aa62

tech-stack:
  added: []
  patterns:
    - "per-call symlink farm under $WORK replaces a PATH directory holding a compiler, keeping the other tools reachable"
    - "mutation proof: copy tests/, redefine the helper as a no-op, expect rc 1 and the named FAIL gate"

key-files:
  created: [tests/test_path_scrub.sh]
  modified: [tests/lib.sh, tests/test_noroute_notice.sh, tests/test_exit_contract.sh, tests/test_tier2_fake.sh]

key-decisions:
  - "Farm instead of dropping a compiler-holding PATH directory (research open question 2): a shared directory such as /usr/local/bin keeps sh, awk, curl and python3 reachable; plain removal only when WORK is unset"
  - "Scrub runs only in three files, never in mkwork or at lib.sh source time (D-12), so test_discovery.sh, test_never_execute.sh, test_real_compiler.sh and test_tier2_live.sh keep their compilers"

requirements-completed: [MAINT-06]

coverage:
  - id: D1
    description: "no_compiler_path and no_compiler_env helpers in tests/lib.sh"
    requirement: MAINT-06
    verification:
      - kind: unit
        ref: "sh tests/test_path_scrub.sh (pathscrub_compiler_only_dir, _shared_dir_keeps_tools, _exe_names, _clean_unchanged, _empty_entries_dropped, _order_kept, _no_work_drops_dir, _shell_state_restored, _env_cleared)"
        status: pass
    human_judgment: false
  - id: D2
    description: "sh tests/run.sh passes with a fake bbjcpl and bbjcplw first on PATH"
    requirement: MAINT-06
    verification:
      - kind: integration
        ref: "PATH=<fake dir>:$PATH sh tests/run.sh -> SUMMARY: ok=774 fail=0 skip=0"
        status: pass
    human_judgment: false
  - id: D3
    description: "Removing the scrub is caught in CI without BBj (D-13)"
    requirement: MAINT-06
    verification:
      - kind: integration
        ref: "tests/test_path_scrub.sh#pathscrub_mutation_noroute_notice, pathscrub_mutation_exit_contract"
        status: pass
    human_judgment: false

duration: 8min
completed: 2026-10-12
status: complete
---

# Phase 07 Plan 02: PATH scrub for the no-route gates Summary

**`sh tests/run.sh` now passes on a machine with `bbjcpl` or `bbjcplw` on PATH: a symlink-farm `no_compiler_path` helper scrubs PATH for the no-route gates only, and a new CI-run `test_path_scrub.sh` (14 gates) goes red if the scrub is removed.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-10-12 (plan clock via PLAN_START_EPOCH)
- **Completed:** 2026-10-12
- **Tasks:** 3
- **Files modified:** 5 (1 created, 4 modified)

## Accomplishments

- `no_compiler_path [PATHVALUE]` replaces every directory holding `bbjcpl`, `bbjcpl.exe`, `bbjcplw` or `bbjcplw.exe` with a `$WORK/pathfarm.XXXXXX` farm of symlinks to the directory's other entries; clean directories keep place and text, empty entries are dropped, IFS and noglob are restored.
- `no_compiler_env` clears `BBJ_HOME`, `BBJHOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME` and empties `BBJ_CHECK_DEFAULT_HOMES` in the calling shell.
- Call sites: `test_noroute_notice.sh` (after `mkwork`, and on `SYSPATH`), `test_exit_contract.sh` (no-route block of `run_shell` only, PATH restored after), `test_tier2_fake.sh` (`SYSPATH`).
- `test_path_scrub.sh` runs the two no-route files nested with a fake compiler first on PATH (green) and from a copy of `tests/` whose helper is a no-op (red, rc 1 plus `notice_text_claude` / `contract_*_no_route` FAIL). Every stdout line of the file is a `pathscrub_` gate line.

## Task Commits

1. **Task 1: end-to-end scrub slice (tracer)** - `e115779` (fix)
2. **Task 2: no_compiler_env, exit-contract block, mutation proof** - `a1a703e` (test)
3. **Task 3: unit gates and tier-2 fake SYSPATH** - `4a268e7` (test)

**Plan metadata:** recorded in the docs commit that follows this file.

## Decision: farm instead of dropping the directory (research open question 2)

D-11's intent is that other tools (`sh`, `awk`, `curl`, `python3`, `busybox`) stay reachable. Dropping a shared directory such as `/usr/local/bin` or a Homebrew prefix would remove them, so a compiler-holding directory becomes a per-call symlink farm without the four compiler names. Plain removal remains only as the fallback when `WORK` is unset.

## No-route sweep (D-12, re-run 2026-10-12)

Command: `grep -lE 'bbjcplw?|bbj-check\.sh|run_check' tests/test_*`. The Task 1 check (every printed file has a row below) printed no `unclassified:` line.

| File | Class | Evidence |
|------|-------|----------|
| `test_noroute_notice.sh` | scrubbed (D-12; Tasks 1 and 2) | 35 of 57 gates FAIL with a compiler first on PATH; PATH scrubbed after mkwork, and SYSPATH |
| `test_exit_contract.sh` | scrubbed (D-12; Task 2) | 6 gates FAIL: `contract_{dash,bash,busybox}_no_route` and `_codex_no_route`; scrub sits in run_shell's no-route block only |
| `test_tier2_fake.sh` | scrubbed (D-12 "any other no-route case"; Task 3) | `url_refused_*` (12) and `no_curl_notice_then_silent` expect the notice; SYSPATH scrubbed; 35 ok before and after |
| `test_discovery.sh` | deliberate route (named in D-12; left alone) | Fake homes and PATH fakes on purpose; residual on a BASEPATH=/usr/bin:/bin that holds a compiler (see exposure below) |
| `test_real_compiler.sh` | deliberate route (named in D-12) | BBJ_HOME=$BBJ_TEST_HOME, real compiler; skip without one |
| `test_never_execute.sh` | deliberate route | BBJ_HOME holds the fake compiler; the fake first on PATH is the never-execute sentinel |
| `test_codex_patch.sh` | deliberate route | BBJ_HOME exported with the fake compiler |
| `test_hook_review_fixes.sh` | deliberate route | BBJ_HOME exported with the fake compiler for every run_check |
| `test_claude_plugin.sh` | deliberate route | Hook runs only in hook_command with BBJ_HOME=$BBJ_TEST_HOME; skip without a real compiler |
| `test_install_codex.sh` | deliberate route | Installed hook copy runs once with BBJ_HOME=$WORK/hookhome |
| `test_tier2_live.sh` | deliberate route (opt-in tier 2) | Not a no-route case; `live_no_compiler` FAILs with a named reason |
| `test_path_scrub.sh` | deliberate route (new) | Puts fake compiler copies first on PATH on purpose |
| `test_install_pages.sh` | does not run the hook | Text gates |
| `test_static_guards.sh` | does not run the hook | Static scan |
| `test_check_order.py` | does not run the hook | Text gate |
| `test_layout.py` | does not run the hook | File-mode and hook-command gates |
| `test_skill_examples.py` | does not run the hook | Real compiler by absolute path under BBJ_TEST_HOME, opt-in |
| `test_home_guard.sh` | does not run the hook (created by 07-03, wave 2) | Not present yet; row kept for when it lands |

Arbiter: the full-suite run below with the fake compiler first on PATH gave fail=0, so no case was misclassed.

## Suite runs

- Plain: `sh tests/run.sh` -> `SUMMARY: ok=774 fail=0 skip=0`
- Fake `bbjcpl` and `bbjcplw` (copies of `tests/fake-bin/bbjcpl`) first on PATH: `SUMMARY: ok=774 fail=0 skip=0` (it was 41 FAIL before this plan)

## The 14 gates of tests/test_path_scrub.sh

`pathscrub_fake_on_path`, `pathscrub_green_noroute_notice`, `pathscrub_green_exit_contract`, `pathscrub_mutation_noroute_notice`, `pathscrub_mutation_exit_contract`, `pathscrub_env_cleared`, `pathscrub_compiler_only_dir`, `pathscrub_shared_dir_keeps_tools`, `pathscrub_exe_names`, `pathscrub_clean_unchanged`, `pathscrub_empty_entries_dropped`, `pathscrub_order_kept`, `pathscrub_no_work_drops_dir`, `pathscrub_shell_state_restored`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Synthetic-PATH unit gates could not find `sh`**
- **Found during:** Task 3
- **Issue:** The first run of `pathscrub_shared_dir_keeps_tools` and `pathscrub_compiler_only_dir` set PATH to the scrubbed synthetic value, which holds no `sh`, so `sh -c` failed (the compiler-only gate passed vacuously).
- **Fix:** `_sh=$(command -v sh)` is resolved first and the gates call `"$_sh" -c` by absolute path.
- **Files modified:** tests/test_path_scrub.sh
- **Verification:** all 14 gates ok, no non-gate stdout line
- **Committed in:** 4a268e7

**2. [Rule 1 - Bug] ShellCheck SC2030/SC2031 on the `fake_on_path` gate**
- **Found during:** Task 1
- **Issue:** `$(PATH=...; command -v ...)` modifies PATH in a subshell, which ShellCheck flags against the later nested-run line.
- **Fix:** `PATH=... sh -c 'command -v ...'` (per-command prefix assignment).
- **Files modified:** tests/test_path_scrub.sh
- **Committed in:** e115779

**Total deviations:** 2 auto-fixed (2 bugs, both in new test code). **Impact:** none on scope.

## Known exposure (flagged assumption, MAINT-06)

`test_discovery.sh` (BASEPATH) and `test_tier2_live.sh` still build a PATH from `/usr/bin:/bin` without the scrub (D-12 leaves them alone by name). A compiler linked directly into `/usr/bin` or `/bin` would cost `test_discovery.sh` 2 gates (`order_defaults_last`, `no_route_notice_then_silent`); `test_tier2_live.sh` already fails loudly with `live_no_compiler`. Not reproduced on this machine (no compiler in `/usr/bin` or `/bin`). The Git for Windows colon-separated PATH assumption (research A1) is for Phase 9 to check.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The only compilers placed on PATH are copies of `tests/fake-bin/bbjcpl`, which compile and run nothing; farms hold symlinks only, under `$WORK`.

## Next Phase Readiness

Ready for 07-03. 07-04 owns the CONVENTIONS.md gate-prefix list and should add `pathscrub_` (not edited here).

## Self-Check: PASSED

- tests/test_path_scrub.sh, tests/lib.sh, tests/test_noroute_notice.sh, tests/test_exit_contract.sh, tests/test_tier2_fake.sh present
- Commits e115779, a1a703e, 4a268e7 are ancestors of HEAD

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-12*
