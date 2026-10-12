---
phase: 03-example-gate-and-structure-lints
plan: 03
subsystem: testing
tags: [python3, stdlib, bbjcpl, canary, batch-compile, ratchet, fake-compiler]

requires:
  - phase: 03-example-gate-and-structure-lints
    provides: "plans 03-01/03-02: fence extractor, grammar and structure lints, pending list, ratchet, --report, fixture helpers"
provides:
  - "live route 1 in tests/test_skill_examples.py: one batched bbjcpl -t -N -X call over counter-named files, record attribution, canary pair, bbj / should-fail outcome rules, skip-unless-strict route gate, report refusal"
  - "tests/skills_baseline.json regenerated on this machine: bbjcpl 44 (bbj-programming) and 25 (bbj-web-programming), should-fail 0"
  - "Fixture gates that prove the bbjcpl plumbing without BBj (fake compiler), so CI covers it"
affects: [03-04, 04-bbj-programming-makeover, 05-bbj-web-programming-makeover]

actuals:
  tokens: 11800
  tasks: 2
  commits: 2
plan_head_before: 2235ab84b6dfde4c3f2cfe524cb2bf79ccc0c952
plan_head_after: b00981dde62255ade1b4fc74bb5518c87417b66a

tech-stack:
  added: []
  patterns:
    - "a live route is a dict {route, state ok|missing|broken, detail, verdicts, version}; a route that is not ok yields no verdicts and its checks are unmeasured"
    - "an unmeasured check prints no ratchet gate and D-03 judges it by its baseline count"
    - "canary pair in every batch: a compiler that cannot check is a broken route, never an all-pass"
    - "argv guard compares against the literal -t -N -X, not the CPL_ARGS constant, so it does not move with the constant it checks"

key-files:
  created: []
  modified:
    - tests/test_skill_examples.py
    - tests/skills_baseline.json

key-decisions:
  - "Record attribution uses startswith(path + ': ') over the exact paths passed (longest path first), which honours the plan wording even for a path that contains ': '"
  - "A failing block's detail comes from its first record; the file line is opener line + the last parenthesised 'at line N (n)' of that record, or just the first line when there is none, cut to 200 characters"
  - "bbj_version in the baseline stays 'unknown' (route version None); plan 03-04 sets it"
  - "skills_total_bbjcpl and skills_route_bbjcpl print before the per-skill gates; undecided should-fail gates print after a skill's should-fail violations"

patterns-established:
  - "fake_route(blocks, out_text, extra, script): runs cpl_route against a copy of tests/fake-bin/bbjcpl (or a custom script) with FAKE_LOG and FAKE_OUT, returning the route and the parsed call log"
  - "child_case takes an env dict for hermetic child runs that need one variable changed"

requirements-completed: [GATE-01, GATE-03]

coverage:
  - id: D1
    description: "All closed bbj and should-fail blocks of both skills are compiled by the real bbjcpl in one compile-only call; failures are per-block pending to-do gates with file and line, counted in the baseline"
    requirement: GATE-03
    verification:
      - kind: integration
        ref: "env -u BBJ_TEST_HOME python3 -I tests/test_skill_examples.py -> skills_route_bbjcpl ok (95 files in one call), skills_total_bbjcpl ok 93 bbj blocks: 24 pass, 69 fail; 44 + 25 pending skip gates"
        status: pass
      - kind: other
        ref: "cmp of a fresh --report JSON with tests/skills_baseline.json"
        status: pass
    human_judgment: false
  - id: D2
    description: "A dead, silent or confused compiler is a broken route (skip, FAIL under BBJ_SKILLS_LIVE=1) and the gate only ever starts bbjcpl with -t -N -X on counter-named files, no shell"
    requirement: GATE-03
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_guard_cpl_args, skills_guard_cpl_argv, skills_fx_cpl_* canary, stray, stdin, exit-status gates; AST check: no shell keyword, no os.system/popen/exec/spawn)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The should-fail rule (D-08), the skip-unless-strict route gate (D-13, CI=true stays skip), report refusal and unmeasured-check pending handling"
    requirement: GATE-01
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_fx_outcome_*, skills_fx_route_*, skills_fx_report_refus*, skills_fx_pending_unmeasured_uses_baseline)"
        status: pass
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=664 fail=0 skip=112 (real /opt/bbx); CI view ok=622 fail=0 skip=48"
        status: pass
    human_judgment: false

duration: 30min
completed: 2026-10-10
status: complete
---

# Phase 3 Plan 03: bbjcpl route Summary

**The example gate now compiles every bbj block of both skills in one `bbjcpl -t -N -X` call with a canary pair, turns the 69 real failures into counted pending gates (44 and 25, as research measured), and proves the plumbing in CI with a fake compiler.**

## Performance

- **Duration:** about 30 min
- **Completed:** 2026-10-10
- **Tasks:** 2 of 2
- **Files:** 2 modified (tests/test_skill_examples.py, tests/skills_baseline.json); nothing under plugins/bbj/skills/

## Accomplishments

- Route 1: `bbjcpl_path`, `live_blocks`, `write_block_files`, `cpl_records`, `record_detail`, `cpl_route`, `block_outcome`, `run_live`, `report_refusal`. Blocks go to `b<NNNN>.bbj` in a `bbj-skills-*` temp directory (removed in a `finally`), with `canary_good.bbj` and `canary_bad.bbj`, and are compiled in one argv-list call with stdin from /dev/null and a 120 s timeout. The exit status is never read.
- Real result on this machine: `skills_route_bbjcpl ok /opt/bbx/bin/bbjcpl: 95 file(s) in one call`, `skills_total_bbjcpl ok 93 bbj blocks: 24 pass, 69 fail; 0 should-fail blocks`. Baseline bbjcpl 44 (bbj-programming) and 25 (bbj-web-programming), equal to the research numbers; should-fail 0. Baseline equals a fresh `--report` byte for byte; the Markdown lists failures as ``- `SKILL.md:27` line 29: error at line 20 (2): ...``.
- Gates: `skills_guard_cpl_args`, `skills_route_bbjcpl` (skip with "set BBJ_SKILLS_LIVE=1 to make this a failure", FAIL under strict, `CI=true` unchanged), `skills_total_bbjcpl`, per-block `skills_bbjcpl_<skill>_<file>_<line>` and `skills_should-fail_...`, undecided should-fail gates, ratchet gates printed only for measured checks.
- Unmeasured checks: with no route, `all_zero` and the `skills_pending_<skill>` detail use the baseline count, so a pending skill is not told to leave pending because a check was not run.
- `--report` refuses with exit 2 and writes nothing unless the bbjcpl route is ok; `meta["routes"]` lists the ok routes.
- Fixture gates (every case the plan lists, plus `skills_fx_cpl_records_lookalike_unattributed`, `skills_fx_cpl_stdin_eof_exit_ignored` and `skills_fx_outcome_no_route`): argv guard, attribution (three-line "Ambiguous signatures" record gives `line <opener+2>: type check error [...`), exact-path prefix, continuation, no-line record, silent / good-record / stray canaries, zero blocks, live block selection, the block_outcome table, route gate in four environments, report refusal, unmeasured pending.

## Task Commits

1. **Task 1: bbjcpl route, gates, report refusal and regenerated baseline (tracer)** - `f469f39` (feat)
2. **Task 2: fake-compiler fixtures** - `b00981d` (test)

## TDD Gate Compliance

Task 2 carries `tdd="true"`, but as in plans 03-01 and 03-02 the implementation lives in the Task 1 tracer, so the fixtures were green when first run (one wrong expectation of my own in `cpl_records_prefix_exact` was fixed in the fixture: a look-alike line after an open record is a continuation by design). RED evidence came from mutation checks, each reverted from a backup before commit:

- `-N` removed from `CPL_ARGS`: `skills_guard_cpl_args` and `skills_guard_cpl_argv` FAIL (the argv guard first survived because it compared against the constant; it now compares against the literal `-t -N -X`).
- path prefix match loosened (no `': '`): `cpl_records_lookalike_unattributed` FAIL.
- canary_bad check, canary_good check, stray check each disabled: `cpl_canary_silent` (and both broken-route child cases), `cpl_canary_good_record`, `cpl_stray` FAIL.
- should-fail `cpl_ok` condition flipped: `outcome_sf_unfailed`, `outcome_sf_undecided` FAIL.
- strict mode ignored in the route gate: both strict child cases FAIL.
- unmeasured ratchet gate printed anyway / unmeasured check not judged by baseline: `pending_unmeasured_uses_baseline`, `pending_all_zero_unit` FAIL.
- `report_refusal` made to return None: `report_refusal_unit`, `report_refused_no_route` FAIL.
- opener line offset dropped from the detail: `cpl_attribution` FAIL.
- exit status used as a verdict: `cpl_stdin_eof_exit_ignored` FAIL.
- `stdin=DEVNULL` removed (run with a never-closing stdin pipe and a 5 s timeout): `cpl_stdin_eof_exit_ignored` FAIL. This one survived until the stdin/exit-status fixture was added.

## Verification

- Both Task 1 automated blocks, the three Task 2 blocks and the acceptance criteria pass: the CI-view child run prints `gate skills_route_bbjcpl skip no executable /nonexistent/bin/bbjcpl; set BBJ_SKILLS_LIVE=1 to make this a failure` and exits 0.
- `sh tests/run.sh` on this machine: `SUMMARY: ok=664 fail=0 skip=112`. CI view (`BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true sh tests/run.sh`): `ok=622 fail=0 skip=48` on the second run.
- AST check: no `shell` keyword and no `os.system`/`os.popen`/`os.exec*`/`os.spawn*`; file is pure ASCII with no f-strings.
- `git diff --quiet -- plugins/bbj/skills` exits 0; no `bbj-skills-*` or `skillfx-*` directory is left in /tmp after a run.

## Deviations from Plan

None - plan executed exactly as written. Additions beyond the plan's case list, all found by mutation checks: `skills_fx_cpl_records_lookalike_unattributed`, `skills_fx_cpl_stdin_eof_exit_ignored`, `skills_fx_outcome_no_route`, and the argv guard comparing against a literal instead of `CPL_ARGS`.

## Issues Encountered

The known unrelated flake `tests/test_install_codex.sh` gate `real_home_untouched` (a live Codex process writes `~/.codex/logs_2.sqlite-wal` and `-shm`) FAILed on the first `sh tests/run.sh` of Task 1 and of the CI view; it was the only FAIL each time and passed on the re-run, as instructed. Not touched.

## Known Stubs

None.

## Threat Flags

None. T-03-09 (only `bbjcpl -t -N -X` is started, pinned by `skills_guard_cpl_args` and `skills_guard_cpl_argv`), T-03-10 (block text only in counter-named files, no shell, AST check), T-03-11 (stdin from /dev/null, 120 s timeout), T-03-12 (canary pair, stray output breaks the route) and T-03-13 (temp directory outside the repository, removed in `finally`) are mitigated and pinned by fixtures; no new network surface.

## Next Phase Readiness

Ready for 03-04 (bbj-ls route). `LIVE_CHECKS` and `ROUTE_ORDER` already name `bbj-ls`; `block_outcome` already handles a second route and the undecided should-fail case; `report_refusal(routes)` checks every route in the list, and `run_live` returns a list of routes plus a `measured` dict keyed by `LIVE_CHECKS`. `bbj_version` is still `"unknown"` (route `version` is None). CHECKS would gain `bbj-ls` and `fixture_baseline` defaults every key of CHECKS to 0, so `route_files()` fixtures stay valid.

## Self-Check: PASSED

- tests/test_skill_examples.py, tests/skills_baseline.json and this file exist.
- Commits f469f39 and b00981d are ancestors of HEAD.
- `commits: 2` measured with `git rev-list --count 2235ab8..HEAD`.
