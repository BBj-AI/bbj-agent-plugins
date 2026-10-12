---
phase: 02-hook-no-route-notice
plan: 01
subsystem: hook
tags: [posix-sh, claude-code-hook, codex-hook, additionalContext, mkdir-marker, bbj-check]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: hosted check allowed with disclosure (D-01), hosted address never named (D-02)
provides:
  - no_tier1_route return contract 0 verdict / 1 no route / 2 route failed, with the curl exit table in the hook header
  - the no-route notice, one hookSpecificOutput.additionalContext object, once per session id via a mkdir marker
  - Write/Edit and apply_patch enable-step texts, a capped path list (5 paths, 200 bytes each), JSON-safe file names
  - tests/lib.sh seams BBJ_CHECK_STATE_DIR, fresh_state, notice_text, SESSION_ID
  - tests/test_noroute_notice.sh (29 notice_* gates) and the 14 converted silent-path gates
affects: [02-02 compiler-without-verdict entry and exit-contract amendment, 02-04, 02-05 Codex capture, 02-06, phase 6 docs and changelog]

actuals:
  tokens: 11000
  tasks: 3
  commits: 5

plan_head_before: 49c4c24f080974bcc840b0dd4989f38adcab4ad3
plan_head_after: 632e2c382e623770b98cae75db80ce909ef13bf8

tech-stack:
  added: []
  patterns:
    - "verdict class as return value: 0 verdict, 1 no route, 2 route failed, collected in globals and decided once in main"
    - "mkdir as atomic once-per-session test-and-set, fail toward telling"
    - "one printf writes the only stdout object; user data only in printf arguments, bytes outside printable ASCII mapped to ?"

key-files:
  created:
    - tests/test_noroute_notice.sh
  modified:
    - plugins/bbj/scripts/bbj-check.sh
    - tests/lib.sh
    - tests/test_discovery.sh
    - tests/test_tier2_fake.sh

key-decisions:
  - "Only curl exit 7 is no route; every other nonzero curl exit, an empty reply, a JSON-RPC error, an isError result and text with neither verdict is route failed and silent (D-01, D-03)"
  - "The 'not repeated' clause is printed only when this call created the marker, so tell-anyway failures (D-17) and a missing session id (D-16) never claim a silence that will not follow"
  - "json_body maps every byte outside printable ASCII to ? so a Latin-1 or control byte in a file name can never make the object invalid JSON or invalid UTF-8"
  - "The notice is decided in main after every file and only when FAILED=0, so an exit-2 call never uses up the session's slot (D-04)"

patterns-established:
  - "Gate prefix notice_ for tests of the no-route notice"
  - "Hermetic once-per-session state: mkwork exports BBJ_CHECK_STATE_DIR=$WORK/state, fresh_state gives a clean slot per case"

requirements-completed: [HOOK-01, HOOK-02, HOOK-03]

coverage:
  - id: D1
    description: "With no compiler and no tier-2 route, the first BBj Write/Edit/apply_patch of a session exits 0 with one valid additionalContext object (files, reasons, enable steps, hosted-check disclosure, tell-the-user); later calls of the session are silent"
    requirement: "HOOK-02"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_shape_dash, notice_shape_bash, notice_text_claude, notice_second_call_silent, notice_other_session, notice_marker_in_state_dir"
        status: pass
    human_judgment: false
  - id: D2
    description: "no_tier1_route separates no route (curl exit 7, no curl, refused URL) from a route that was reached without a verdict, and only no route notifies"
    requirement: "HOOK-01"
    verification:
      - kind: integration
        ref: "tests/test_tier2_fake.sh#url_refused_*, no_curl_notice_then_silent, mode_rpc_error_silent, mode_garbage_silent; tests/test_discovery.sh#no_route_notice_then_silent"
        status: pass
    human_judgment: false
  - id: D3
    description: "Codex gets BBJ_HOME / bbjcpl on PATH / install-codex.sh --with-local; Write and Edit get bbj_home / bbj-local@basis-bbj; several and hostile file names stay valid JSON within the 5-path, 200-byte caps"
    requirement: "HOOK-02"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_codex_text, notice_edit_text, notice_two_files, notice_path_cap, notice_long_names_bounded, notice_hostile_names_json, notice_no_pwned"
        status: pass
    human_judgment: false
  - id: D4
    description: "Once per session holds for a missing or empty id, key sanitising and 64-byte cap, symlink and file squatting, unwritable and missing state dir, TMPDIR fallback, six concurrent hooks, and an exit-2 call that keeps the slot"
    requirement: "HOOK-02"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_no_session_every_call, notice_empty_key_every_call, notice_key_sanitised, notice_key_max_64, notice_uuid_key_intact, notice_symlink_squat, notice_file_squat, notice_unwritable_state, notice_missing_state, notice_tmpdir_fallback, notice_concurrent_once, notice_exit2_keeps_slot"
        status: pass
    human_judgment: false
  - id: D5
    description: "The 14 former silent-path gates read first call notice, second call silent; the suite ends fail=0"
    requirement: "HOOK-03"
    verification:
      - kind: integration
        ref: "sh tests/run.sh (SUMMARY: ok=478 fail=0 skip=2)"
        status: pass
    human_judgment: false
  - id: D6
    description: "That the notice text reaches the model and reads well to the user on a real Claude Code and a real Codex"
    verification: []
    human_judgment: true
    rationale: "Delivery on real clients is HOOK-04, proven by the scripted captures of plans 02-05 and 02-06; no test in this plan can show what a model does with the text"

duration: 40min
completed: 2026-10-10
status: complete
---

# Phase 2 Plan 01: No-route notice on the no-compiler branch Summary

**bbj-check.sh now tells the agent once per session, with one hookSpecificOutput.additionalContext object and exit 0, that a BBj file was written but not compile-checked when neither bbjcpl nor a loopback bbj-ls is available, using a mkdir marker keyed by session_id.**

## Performance

- **Duration:** about 40 min (the start time was not captured, so this is an estimate)
- **Completed:** 2026-10-10
- **Tasks:** 3
- **Files modified:** 5 (1 created)

## Accomplishments

- `no_tier1_route` now returns the verdict class: 0 verdict reached, 1 no route (`NR_T2` = refused, nocurl or badurl, plus `NR_HOSTPORT`), 2 route reached but no verdict. Only curl exit 7 is no route; the full curl table sits in the hook header.
- `note_noroute`, `json_body` and `notice` are new. The notice is decided in `main` after all files and only when `FAILED=0`; it is the one place the script writes to stdout, through a single `printf` whose format string holds no user data.
- Two enable-step texts by `tool_name` (Write/Edit: `bbj_home`, `bbj-local@basis-bbj`; apply_patch: `BBJ_HOME`, `bbjcpl` on PATH, `install-codex.sh --with-local`), with the hosted check named once as a disclosed fallback and no address in the text.
- File names: every byte outside printable ASCII becomes `?`, backslash and quote are escaped, each path is cut to 200 bytes, at most 5 are named and the rest counted ("and M more", was/were).
- Once per session: marker `${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}/bbj-check-noroute-<key>` by plain `mkdir`; fails toward telling; the "not repeated" clause appears only when this call created the marker. The header records this reading of D-11 with D-17.
- Tests: `tests/lib.sh` gains `BBJ_CHECK_STATE_DIR` (hermetic in `mkwork`), `fresh_state`, `notice_text`, `SESSION_ID`. New `tests/test_noroute_notice.sh` has 29 gates. `no_route_silent`, the 12 `url_refused_*` gates and `no_curl_silent` are converted to first call notice, second call silent. Full suite: `ok=478 fail=0 skip=2`, and no `bbj-check-noroute-*` entry is left in the real temp directory.

## Task Commits

1. **Task 1: a BBj file written with no compiler and no tier-2 route gets one notice per session (tracer)** - `daef2b8` (feat)
2. **Task 2: Codex enable steps, several or hostile file names within caps (TDD)** - RED `fe6122f` (test), GREEN `f44dbe3` (feat)
3. **Task 3: once per session under missing ids, squatted or unwritable state, concurrency, a failing call (TDD)** - RED `0e3e067` (test), GREEN `632e2c3` (docs: the header marker rules)

**Plan metadata:** added by the final docs commit (SUMMARY, STATE, ROADMAP, REQUIREMENTS).

## Files Created/Modified

- `plugins/bbj/scripts/bbj-check.sh` - return contract of `no_tier1_route`, `note_noroute`, `json_body`, `notice`, notice step in `main`, header (stdout contract, curl table, marker rules)
- `tests/lib.sh` - `BBJ_CHECK_STATE_DIR` in `mkwork`, `fresh_state`, `notice_text`, `SESSION_ID` in both payload builders
- `tests/test_noroute_notice.sh` - new, the `notice_*` gates
- `tests/test_discovery.sh` - `no_route_notice_then_silent`
- `tests/test_tier2_fake.sh` - `url_refused_<tag>` x12 and `no_curl_notice_then_silent`; `mkdir` added to the no-curl tool farm

## Decisions Made

See `key-decisions`. In addition, the plan's sequencing was followed: Task 1 builds the notice with Write/Edit text, single-file wording and an uncapped list; Task 2 adds the Codex text, plural and caps.

## TDD Notes

The plan is `type: execute` with `tdd="true"` on Tasks 2 and 3, so no plan-level gate section applies. The project's gates print `gate NAME FAIL`, a format `gsd_run check tdd-red-evidence` does not parse, so RED was assessed by inspection of the real run.

- **Task 2 RED (`fe6122f`):** `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_two_files`, `notice_path_cap`, `notice_path_cap_rest` and `notice_long_names_bounded` failed on the planned assertions (the hook ran and produced a valid object; it lacked the Codex steps, wrote "was" for two files, named all 8 paths, and left 268-byte paths). `notice_edit_text` and the hostile-name gates were already green because Task 1's `json_body` and Write/Edit text cover them.
- **Task 3 RED (`0e3e067`):** only `notice_header_marker_rules` failed. All 11 behavior gates were already green, because the plan's Task 1 step 4 puts the marker logic (the fresh flag, the symlink check, fail toward telling) in Task 1. This is an unexpected green that was investigated, not a wrong test: each gate was run against six mutated copies of the hook (clause always printed, symlink check removed, `mkdir -p`, no 64-byte cut, no character filter, marker burned before the exit-2 decision) and each mutation turned the expected gates red.

## Deviations from Plan

None - plan executed exactly as written.

Notes that are not deviations:

- The plan's verify command names one gate `notice_hostile_names_json`; the gate aggregates the five hostile names (quote, backslash, tab, Latin-1 byte, command substitution).
- At the Task 1 commit the header already described the final contract (two texts, 5-path cap); Task 2 completed the code. The gap lives only between two commits of the same plan.
- ShellCheck is not installed on this machine, so `static_shellcheck_bbj-check.sh` and the test-file lint skipped locally. CI (`tests/ci.sh`, `CI=true`) runs them. `sh -n` and every static guard pass.
- busybox is not installed here; the dash and bash shapes were run.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The marker directory in a shared temp dir, the file-name JSON and the hosted-check clause are the surfaces of T-02-01 to T-02-07, each covered by a gate (`notice_hostile_names_json`, `notice_key_sanitised`, `notice_symlink_squat`, `notice_file_squat`, `notice_not_error_grammar`).

## Follow-ups

- **Phase 6:** `.planning/codebase/CONVENTIONS.md` lines 66 and 135 (the source of the conventions in `.claude/CLAUDE.md`) still say hook scripts never write stdout, and its gate-prefix list lacks `notice_`. Refresh both with the codebase map. This plan does not edit them.
- **Plan 02-02:** the second call site (`check_file`, a compiler that gives no verdict) still calls `no_tier1_route` without recording the result, so `unusable_output_silent` and `crash_silent` are unchanged and `tests/test_exit_contract.sh` has not been amended yet. The full suite is green as it stands.
- Docs that become false with the notice (`README.md:41`, `docs/install-claude-code.md:105-106`, `docs/install-codex.md:199`, `codex/install-codex.sh:787`) are outside this plan's files; they remain for a later plan or Phase 6.

## Next Phase Readiness

Ready for plan 02-02: the notice, `NR_COMPILER=noresult` text and the `note_noroute` collector are in place and waiting for the second call site.

## Self-Check: PASSED

- Files: `plugins/bbj/scripts/bbj-check.sh`, `tests/lib.sh`, `tests/test_noroute_notice.sh`, `tests/test_discovery.sh`, `tests/test_tier2_fake.sh` all present.
- Commits `daef2b8`, `fe6122f`, `f44dbe3`, `0e3e067`, `632e2c3` are ancestors of HEAD; 5 commits measured from the plan ledger (`49c4c24..632e2c3`).
- Acceptance criteria and plan-level verification re-run: `sh tests/test_noroute_notice.sh` all gates ok (`notice_unwritable_state` ok), `sh tests/test_tier2_fake.sh` 12 `url_refused_*` ok plus `no_curl_notice_then_silent`, `sh tests/test_discovery.sh` ok, `sh tests/test_static_guards.sh` ok, `sh tests/run.sh` `fail=0`, no marker left in the real temp directory.
