---
phase: 02-hook-no-route-notice
plan: 02
subsystem: hook
tags: [posix-sh, claude-code-hook, codex-hook, classification, exit-contract, bbj-check]

requires:
  - phase: 02-hook-no-route-notice
    provides: plan 02-01, the no-route notice, the no_tier1_route 0/1/2 contract, note_noroute, tests/lib.sh fresh_state and notice_text
provides:
  - D-02 wiring: a compiler that runs but gives no verdict, with no tier-2 route, is noted as noresult and the notice reads "bbjcpl found but gave no result"
  - tests/test_exit_contract.sh amended narrowly (contract SHELLNAME CASE [EXPECT]) with notice cases for a crashing compiler, a no-route Write and a no-route apply_patch
  - static_notice_single_writer gate (exactly one line holds hookSpecificOutput)
  - FAKE_CURL_EXIT in tests/fake-bin/curl and the modes is-error, empty, no-verdict in tests/fake_mcp.py
  - the never-notifies matrix in tests/test_noroute_notice.sh (clean, errors, failed routes, early skips, mixed patches)
affects: [02-04, 02-05 Codex capture, 02-06, phase 6 docs and changelog]

actuals:
  tokens: 14000
  tasks: 2
  commits: 2

plan_head_before: 218d8eae12152ddb9a1e2b5fa1b14aa7c768cb2a
plan_head_after: e1502883c082c9ebdb7b3239d7344fd4ca8e0228

tech-stack:
  added: []
  patterns:
    - "contract() takes an expectation (empty by default, or notice): stdout is the notice object on the first no-route call and empty on the repeat"
    - "never-notifies matrix: one gate per outcome class, each asserting silence, exactly one request and an empty state directory (no marker)"
    - "single-writer static gate with a duplicated-line mutation copy"

key-files:
  created: []
  modified:
    - plugins/bbj/scripts/bbj-check.sh
    - tests/test_exit_contract.sh
    - tests/test_discovery.sh
    - tests/test_static_guards.sh
    - tests/test_noroute_notice.sh
    - tests/fake-bin/curl
    - tests/fake_mcp.py

key-decisions:
  - "A compiler without a verdict goes through the same tier-2 classification as no compiler: status 1 (no route) is noted noresult, status 2 (route failed) stays silent (D-02, D-03)"
  - "The exit contract is amended only for the three notice cases; every other case still asserts exit 0 or 2 with empty stdout"
  - "The single-writer gate counts comment-stripped lines holding hookSpecificOutput with awk: one in bbj-check.sh, none in any other shipped script"

patterns-established:
  - "Gate names notice_curl_exit_N_silent, notice_fake_MODE_silent for the route-failed class"

requirements-completed: [HOOK-01, HOOK-03]

coverage:
  - id: D1
    description: "A compiler that gives no verdict (output without a compiler-format line, or no output and exit status 126 or higher) with no tier-2 route yields the notice with 'bbjcpl found but gave no result' and never 'no bbjcpl found'; the second call is silent"
    requirement: "HOOK-01"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_d02_reason, notice_d02_not_no_bbjcpl, notice_d02_second_silent, notice_d02_rc126; tests/test_discovery.sh#unusable_output_notice_then_silent, crash_notice_then_silent"
        status: pass
    human_judgment: false
  - id: D2
    description: "A reached route without a verdict never notifies: curl exits 1, 6, 18, 28, 52, 56, an empty curl reply, and the fake server modes rpc-error, garbage, is-error, empty, no-verdict are silent with one request and no marker; a compiler without a verdict behind a failed route is silent too"
    requirement: "HOOK-01"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_curl_exit_1_silent..notice_curl_exit_56_silent, notice_curl_empty_reply_silent, notice_fake_*_silent, notice_d02_failed_route_silent"
        status: pass
    human_judgment: false
  - id: D3
    description: "Clean files, files with compile errors, early skips (README.md, .txt, config.bbx, symlink, missing, unreadable, glob name) never produce the notice or the marker; mixed apply_patch calls follow D-04"
    requirement: "HOOK-01"
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh#notice_clean_silent, notice_errors_no_notice, notice_early_skips_silent, notice_mixed_errors_exit2, notice_mixed_clean_names_noroute_only"
        status: pass
    human_judgment: false
  - id: D4
    description: "tests/test_exit_contract.sh asserts stdout is exactly the notice object (exit 0, empty stderr) on the first call and empty on the second for the crashing compiler, a no-route Write and a no-route apply_patch, under dash and bash; every other case keeps exit 0 or 2 with empty stdout"
    requirement: "HOOK-03"
    verification:
      - kind: integration
        ref: "tests/test_exit_contract.sh#contract_{dash,bash}_{crashing_compiler,no_route,codex_no_route}{,_repeat}"
        status: pass
    human_judgment: false
  - id: D5
    description: "A second stdout writer of the notice object fails the suite"
    requirement: "HOOK-03"
    verification:
      - kind: static
        ref: "tests/test_static_guards.sh#static_notice_single_writer_bbj-check.sh (a copy with the line duplicated turns it FAIL)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Concurrency edge of HOOK-01: classification keeps no state between hook processes and a host kill before the last statement leaves stdout empty"
    requirement: "HOOK-01"
    verification: []
    human_judgment: true
    rationale: "Backstop by the plan: no gate can time a host kill; the verifier reads the single-printf structure and the single-writer gate"

duration: 12min
completed: 2026-10-10
status: complete
---

# Phase 2 Plan 02: Compiler without a verdict, exit contract, never-notifies matrix Summary

**bbj-check.sh now treats a compiler that runs but gives no verdict like a missing one when tier 2 has no route ("bbjcpl found but gave no result"), the exit-code contract test pins stdout to the one notice object, and 40-odd gates prove that clean files, errors, failed routes and skipped files never notify.**

## Performance

- **Duration:** about 12 min of agent time, plus several full-suite runs of about 2 min each
- **Completed:** 2026-10-10
- **Tasks:** 2 (a tracer and an auto task)
- **Files modified:** 7 (none created)

## Accomplishments

- `check_file`'s second `no_tier1_route` call site records its status: 1 becomes `note_noroute noresult`, 2 (route reached, no verdict) stays silent (D-02, D-03). A header paragraph names the path.
- `tests/test_exit_contract.sh`: `contract SHELLNAME CASE [EXPECT]`; the crashing-compiler case, a new no-route Write case and a new no-route `apply_patch` case each run twice (notice, then empty) per shell. Header rewritten: stdout is written only for the notice.
- `tests/test_discovery.sh`: `unusable_output_silent` and `crash_silent` became `unusable_output_notice_then_silent` and `crash_notice_then_silent`.
- `tests/test_static_guards.sh`: `static_notice_single_writer_<file>`; the plan's duplicated-line mutation copy turns it red.
- `tests/fake-bin/curl` exits `${FAKE_CURL_EXIT:-7}`; `tests/fake_mcp.py` serves `is-error`, `empty`, `no-verdict`.
- `tests/test_noroute_notice.sh`: D-02 gates, the never-notifies matrix (curl exits 1/6/18/28/52/56 and an empty reply; five fake-server modes; clean; errors; early skips; failed route behind a compiler without a verdict; two mixed `apply_patch` calls), `start_fake`/`stop_fake` and a cleanup trap that also kills fake servers.

## Task Commits

1. **Task 1: a compiler that gives no verdict, with no tier-2 route, gets the notice, and the exit contract says so (tracer)** - `8254f02` (feat). Gates were written first and were red (`notice_d02_reason`, `notice_d02_rc126`), then green after the hook change. Tracer gate in auto mode: the three verify commands re-ran green end to end, then Task 2 started.
2. **Task 2: clean files, errors, failed routes, skipped files and mixed patches never produce a notice (TDD)** - `e150288` (test)

**Plan metadata:** added by the final docs commit (SUMMARY, STATE, ROADMAP, REQUIREMENTS).

## Files Created/Modified

- `plugins/bbj/scripts/bbj-check.sh` - D-02 call site and header paragraph
- `tests/test_exit_contract.sh` - contract expectation argument, three notice cases, header
- `tests/test_discovery.sh` - two converted gates via a `notice_then_silent` helper
- `tests/test_static_guards.sh` - single-writer gate
- `tests/test_noroute_notice.sh` - D-02 gates, never-notifies matrix, fake-server helpers
- `tests/fake-bin/curl`, `tests/fake_mcp.py` - FAKE_CURL_EXIT and three modes

## Decisions Made

See `key-decisions`. The `mkhome` helper was copied into the notice test, as the plan said.

## TDD Notes

Task 1 RED: `notice_d02_reason`, `notice_d02_not_no_bbjcpl`, `notice_d02_second_silent` and `notice_d02_rc126` failed (`notice_text` returned 1, no object on stdout) before the hook change, and passed after it. Task 2 is `tdd="true"` but its gates were green on first run: plan 02-01 already returns 2 for every failed-route path, as the plan predicted ("a red gate here is a real classification bug"). This is an expected green, not a wrong test. Proof that the gates bite: a mutation copy of the hook where every non-zero curl exit or empty reply counts as no route turned eight gates red (`notice_curl_exit_1/6/18/28/52/56_silent`, `notice_curl_empty_reply_silent`, `notice_fake_empty_silent`).

## Deviations from Plan

None - plan executed exactly as written.

Notes that are not deviations:

- Two gates beyond the plan's list were added for readability: `notice_d02_not_no_bbjcpl`, `notice_d02_second_silent` (D-02 detail of the plan's truth) and `notice_mixed_clean_not_named` (the "not naming clean.bbj" half of the plan's behavior).
- `notice_early_skips_silent` skips the unreadable file when run as root, as the plan allows.
- ShellCheck is not installed here, so `static_shellcheck_*` and the test-file lint skip locally; CI runs them. `sh -n` and every static guard pass. busybox is not installed; the dash and bash cases ran.

## Issues Encountered

- **Pre-existing flaky gate, not fixed (see `deferred-items.md`, D-1):** `notice_concurrent_once` (plan 02-01) fails in about 15 to 20 percent of runs on this machine, also on the tree before this plan (7 failures in 40 runs). Cause measured: `mkdir` is uutils coreutils 0.8.0, which lets several of six parallel `mkdir` calls on the same path exit 0; GNU `mkdir` showed no double winner in 200 rounds. Full-suite runs of this plan: `ok=522 fail=0 skip=2` twice and one run with exactly this one gate failing (`ok=521 fail=1`). The plan's last verification ("`sh tests/run.sh` ends with fail=0") therefore passes on a rerun but not on every run here. A decision on the marker primitive is needed (plan 02-01 chose plain `mkdir`); it is outside this plan's files.

## Known Stubs

None.

## Threat Flags

None. T-02-08 to T-02-12 are covered by `notice_curl_exit_*_silent`, `notice_fake_*_silent`, `notice_early_skips_silent`, `static_notice_single_writer_*` and the contract notice cases; the 02-01 gates `url_refused_*` still pass.

## Follow-ups

- Decide the once-per-session primitive given D-1 (deferred-items.md), before the phase verifier runs on a uutils machine.
- Plan 02-06: flip `contract_<shell>_codex_no_route` to a fallback expectation only if Codex does not deliver `additionalContext` (D-15).
- Phase 6: `.planning/codebase/CONVENTIONS.md` still says hook scripts never write stdout (carried over from plan 02-01).

## Next Phase Readiness

Ready for plans 02-04 and 02-05: all four classes (clean, errors, no route, route failed) are pinned by gates and the exit contract is amended.

## Self-Check: PASSED

- Files: `plugins/bbj/scripts/bbj-check.sh`, `tests/test_exit_contract.sh`, `tests/test_discovery.sh`, `tests/test_static_guards.sh`, `tests/test_noroute_notice.sh`, `tests/fake-bin/curl`, `tests/fake_mcp.py`, `.planning/phases/02-hook-no-route-notice/deferred-items.md` present.
- Commits `8254f02` and `e150288` are ancestors of HEAD; 2 commits measured from the plan ledger (`218d8ea..e150288`).
- Plan verify commands re-run: 12 contract gates (dash, bash) ok; `unusable_output_notice_then_silent`, `crash_notice_then_silent`, `notice_d02_reason`, `notice_d02_rc126` ok; static mutation check exits 0; the 18 Task 2 gates ok; `tests/test_tier2_fake.sh` and `tests/test_install_codex.sh` exit 0; `fake_mcp.py` rejects mode bogus; `sh tests/run.sh` `fail=0` on two of three runs, the third failing only on the pre-existing `notice_concurrent_once` flake.
