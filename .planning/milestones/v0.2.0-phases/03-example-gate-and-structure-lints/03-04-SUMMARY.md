---
phase: 03-example-gate-and-structure-lints
plan: 04
subsystem: testing
tags: [python3, stdlib, bbj-ls, loopback, urllib, baseline, fake-server]

requires:
  - phase: 03-example-gate-and-structure-lints
    provides: "plans 03-01..03-03: fence extractor, grammar and structure lints, pending list and ratchet, --report, the bbjcpl route and its fixtures"
provides:
  - "live route 2 in tests/test_skill_examples.py: bbj-ls bbj_check_syntax over loopback with the hook's URL rule, request and verdict rules; one opener with no proxy and no redirects"
  - "network guard gates and fake-server fixtures that prove route 2 in CI without BBj"
  - "tests/skills_baseline.json from a two-route run on BBj 26.03 (bbj-ls 36 and 15)"
  - ".planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md, the makeover to-do list for Phases 4-5"
affects: [04-bbj-programming-makeover, 05-bbj-web-programming-makeover, 06-release]

actuals:
  tokens: 12000
  tasks: 3
  commits: 3
plan_head_before: 3f060d93619b07b678e3aed1ac59dfc975163788
plan_head_after: 558959fa54a1fb826d449a737e6f870c5d81691b

tech-stack:
  added: []
  patterns:
    - "one OPENER (empty ProxyHandler, refusing redirect handler) is the only way this file opens a connection; an AST gate enforces it"
    - "a URL is checked with url_ok before any request is built; a refused URL never reaches the network (fixture: the fake's log stays empty)"
    - "a no-verdict reply breaks the whole route, which then gives no verdicts and is skip (FAIL under BBJ_SKILLS_LIVE=1)"
    - "fixture servers are started in a try/finally with stop_fake or stop_local; nothing survives the run"

key-files:
  created:
    - .planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md
  modified:
    - tests/test_skill_examples.py
    - tests/skills_baseline.json
    - tests/ci.sh

key-decisions:
  - "ls_route takes (url, blocks, reason=''): a refused URL (also one handed straight to ls_route) is missing with 'not loopback', so the fixtures can prove the refusal on the route itself"
  - "bbj_version in the baseline and the report header is the first valid structuredContent.bbjVersion of a bbj-ls reply, else 'unknown'"
  - "guard_no_proxy also runs a child process with the proxy variables set before import: a default opener reads them at construction, so an in-process env change alone could not catch a regression"

patterns-established:
  - "start_fake(mode) / with_fake(mode, fn) / log_entries(log): run tests/fake_mcp.py on a free loopback port and read its request log"
  - "local_server(get_code, post_code) / stop_local: an in-process loopback server for status-code cases (probe, redirect)"
  - "fake_child_case(name, files, mode, want_rc, wants, env): a child run of this file against a fake bbj-ls"

requirements-completed: [GATE-03, GATE-06]

coverage:
  - id: D1
    description: "Every closed bbj and bbj should-fail block is checked on bbj-ls over loopback; failures are per-block pending to-do gates with file, line and column; a bbj block must pass every available route"
    requirement: GATE-03
    verification:
      - kind: integration
        ref: "env -u BBJ_TEST_HOME python3 -I tests/test_skill_examples.py -> skills_route_bbj-ls ok http://127.0.0.1:5009/mcp: 93 call(s); skills_total_bbj-ls ok 93 bbj blocks: 42 pass, 51 fail; 36 + 15 pending skip gates"
        status: pass
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py -> exit 0, both route gates ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Skill code never leaves the machine: loopback-only URL rule, no proxy, no followed redirect, a refused URL sends nothing, every connection goes through one opener"
    requirement: GATE-03
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_guard_request_shape, skills_guard_loopback, skills_guard_refused_no_request, skills_guard_no_redirect, skills_guard_no_proxy, skills_guard_opener_only)"
        status: pass
    human_judgment: false
  - id: D3
    description: "A reply without a clear verdict is never a pass: nine fake-server modes, a verdict table and the skip-unless-strict rule for route 2 (CI=true does not change it)"
    requirement: GATE-03
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_fx_ls_mode_*, skills_fx_ls_verdict_table, skills_fx_ls_version, skills_fx_route_ls_*, skills_fx_ls_only_*)"
        status: pass
      - kind: other
        ref: "BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true sh tests/run.sh -> SUMMARY: ok=651 fail=0 skip=49"
        status: pass
    human_judgment: false
  - id: D4
    description: "The committed baseline JSON and the makeover to-do list were written by --report from two live routes on BBj 26.03; a fresh --report reproduces the JSON byte for byte"
    requirement: GATE-06
    verification:
      - kind: other
        ref: "cmp of a fresh --report JSON with tests/skills_baseline.json (identical); grep checks of 03-BASELINE.md headings, version, routes, reserved-words.md:30"
        status: pass
    human_judgment: false

duration: 45min
completed: 2026-10-10
status: complete
---

# Phase 3 Plan 04: bbj-ls route and committed baseline Summary

**The example gate now checks every bbj block on bbjcpl and on a loopback-only bbj-ls (hook URL rule, no proxy, no redirects, no-verdict replies break the route), and the BBj 26.03 baseline plus the 03-BASELINE.md makeover list are committed from a real two-route run.**

## Performance

- **Duration:** about 45 min
- **Completed:** 2026-10-10
- **Tasks:** 3 of 3
- **Files:** 3 modified (tests/test_skill_examples.py, tests/skills_baseline.json, tests/ci.sh), 1 created (03-BASELINE.md); nothing under plugins/bbj/skills/

## Accomplishments

- Route 2: `url_ok`, `ls_url`, `ls_up` (GET must answer 405 within 2 s), `ls_call` (the hook's body and four headers, 12 s timeout, 1 MiB cap, last `data:` line of an event stream), `ls_verdict`, `ls_route`, and the opener (`_NoRedirect`, empty `ProxyHandler`). `run_live` joins bbj-ls verdicts to the bbjcpl verdicts per block; `--report` now refuses unless both routes are ok; the report header carries the bbj-ls BBj version.
- Gates: `skills_route_bbj-ls`, `skills_total_bbj-ls`, `skills_bbj-ls_<skill>_<file>_<line>`, `skills_ratchet_<skill>_bbj-ls`.
- Fixtures (all run in CI, Python only): nine fake-server modes, verdict and version tables, a 405-only probe, request shape, the loopback table (19 refused and 5 accepted forms, the hosted URL assembled from pieces), refused-URL-sends-nothing, redirect not followed, no proxy (in process and in a child run), an AST gate that every connection goes through `OPENER`, and child runs for missing, strict, not-loopback, broken, pass, fail and should-fail-undecided cases.
- Committed deliverables: `tests/skills_baseline.json` (bbj_version 26.03, nocheck 0) and `03-BASELINE.md` (213 lines, a section per skill with a count table and every failing block per route, with the first error line), both written by `--report`; `tests/ci.sh` header comment names the skill example gate (comment lines only).

## Measured starting point for Phases 4-5 (BBj 26.03, this machine)

| check | bbj-programming (Phase 4) | bbj-web-programming (Phase 5) |
|-------|---------------------------|-------------------------------|
| grammar | 11 | 5 |
| structure | 17 | 8 |
| bbjcpl | 44 | 25 |
| bbj-ls | 36 | 15 |
| should-fail | 0 | 0 |

- Totals: 93 bbj blocks; bbjcpl 24 pass / 69 fail; bbj-ls 42 pass / 51 fail; 0 should-fail blocks; nocheck 0.
- Research figures replaced: 69 (bbjcpl) and 51 (bbj-ls) failing blocks match; the per-skill bbj-ls split 36 / 15 matches research. The 7 untagged fences are the 7 untagged-fence lines of the grammar section (6 in `bbj-programming` `references/reserved-words.md`, 1 more in the other skill); the remaining grammar violations are 9 `...` placeholders.
- Skip totals of the local run (`sh tests/run.sh`, `SUMMARY: ok=697 fail=0 skip=163`): the skill example gate prints 161 pending skips: 69 bbjcpl, 51 bbj-ls, 16 grammar, 25 structure. CI view: `ok=651 fail=0 skip=49` (route gates skip, pending lint gates stay).

## Task Commits

1. **Task 1: bbj-ls route, gates, report refusal and baseline with the version (tracer)** - `b0d1a93` (feat)
2. **Task 2: fake-server fixtures and network guards** - `9ff9f80` (test)
3. **Task 3: 03-BASELINE.md and the ci.sh header line** - `558959f` (docs)

## TDD Gate Compliance

Task 2 carries `tdd="true"`, but as in plans 03-01..03-03 the implementation lives in the Task 1 tracer, so the fixtures were green when first run (one fixture defect of my own, below). RED evidence is from mutation checks, each reverted from memory before the next run; the file was restored every time:

- default proxy handler: `skills_guard_no_proxy` FAIL. redirects followed: `skills_guard_no_redirect` FAIL. `ls_call` without the URL refusal: `skills_guard_refused_no_request` FAIL.
- `isError` check loosened: `skills_fx_ls_verdict_table` FAIL. no-verdict replies no longer break the route: five `ls_mode_*` gates and both `route_ls_broken_*` child cases FAIL. event-stream payload not read: `ls_mode_sse` FAIL. detail line offset dropped: `ls_mode_one_error`, `ls_mode_many`, `ls_mode_sse`, `ls_only_bbj_fail` FAIL.
- version regex relaxed: `ls_version` FAIL. `Mcp-Name` header dropped: `guard_request_shape` FAIL. strict mode ignored in the route gate: four strict child cases FAIL. localhost made case-sensitive: `guard_loopback` FAIL.
- Two mutants survived the first round and led to new fixtures: the probe accepting any HTTP status (now `skills_fx_ls_up_only_405`) and `@` or a backslash after the path (now in the `guard_loopback` table; the regex alone refused `@` in the host part only). A `match` instead of `fullmatch` mutant is caught by `guard_loopback`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Empty ProxyHandler is not kept in the opener**
- **Found during:** Task 2 (first run of `skills_guard_no_proxy`)
- **Issue:** my fixture asserted that `OPENER.handlers` holds a `ProxyHandler` with `proxies == {}`. `OpenerDirector.add_handler` drops a handler with no `*_open` methods, so an empty `ProxyHandler` is never listed; the opener behaves correctly (the default proxy handler is skipped because an instance was supplied), only the assertion was wrong.
- **Fix:** the assertion now requires that no handler with proxies is present; the real proof is the child run that sets the proxy variables before import (a default opener would read them at construction, and the mutation check confirms it fails).
- **Files modified:** tests/test_skill_examples.py
- **Commit:** 9ff9f80

**2. [Rule 2 - Missing critical] Transport errors outside OSError**
- **Found during:** Task 1
- **Issue:** `http.client.HTTPException` (a bad status line or a short read) is not an `OSError`, so it would have crashed the run instead of breaking the route.
- **Fix:** `ls_up` and `ls_call` catch it as well and map it to a route failure.
- **Files modified:** tests/test_skill_examples.py
- **Commit:** b0d1a93

### Additions beyond the plan's case list

`skills_guard_opener_only` (AST gate: no `urlopen`, no raw connection or socket, every `.open()` on `OPENER`), `skills_fx_ls_verdict_table`, `skills_fx_ls_up_only_405`, `skills_fx_route_ls_broken_skip` and `_strict_fail`; the no-proxy guard also runs a child process (see key-decisions).

**Total deviations:** 2 auto-fixed (1 bug in my fixture, 1 missing error mapping). **Impact:** none on the plan's contract; the gate list of the plan is complete.

## Issues Encountered

The known unrelated flake `tests/test_install_codex.sh` gate `real_home_untouched` (a live Codex process writes `~/.codex/logs_2.sqlite-wal`) FAILed once in the CI-view run of Task 2 as the only FAIL and passed on the re-run, as instructed. Not touched. A stray `tests/__pycache__/` created by a debug import was removed before committing.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. T-03-14 (loopback rule, refused URL sends nothing), T-03-15 (no proxy, no redirect), T-03-16 (no verdict breaks the route), T-03-17 (2 s probe, 12 s call, 1 MiB cap) and T-03-18 (version string pattern, `safe()`) are mitigated and pinned by fixtures. T-03-19 (stale committed baseline) is accepted as planned: only `--report` writes it, and Phase 6 reruns with `BBJ_SKILLS_LIVE=1`.

## Verification

- Task 1, Task 2 and Task 3 automated blocks pass; acceptance criteria: `gate skills_route_bbj-ls ok http://127.0.0.1:5009/mcp: 93 call(s)`, `gate skills_total_bbj-ls ok 93 bbj blocks: ...`, 36 and 15 bbj-ls skip lines equal the baseline counts, `BBJ_LOCAL_MCP_URL=http://example.com/mcp` prints a route skip with "not loopback", `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exits 0 with both route gates ok.
- A fresh `--report` JSON is byte-identical to `tests/skills_baseline.json`.
- `sh tests/run.sh`: `SUMMARY: ok=697 fail=0 skip=163`. CI view: `SUMMARY: ok=651 fail=0 skip=49`. `git diff --quiet b2d5cbc HEAD -- plugins/bbj/skills` and `git diff --quiet -- plugins/bbj/skills` both exit 0. `git diff tests/ci.sh` shows comment lines only. No `fake_mcp.py` process is left after a run.
- File is pure ASCII with no f-strings.

## Next Phase Readiness

Phase 3 is complete. Phases 4-5 start from `03-BASELINE.md` and the counts above; each makeover lowers its skill's counts with `--report`, and a skill whose counts reach 0 is removed from pending (the gate asks for that). Phase 6 reruns the gate with `BBJ_SKILLS_LIVE=1`.

## Self-Check: PASSED

- Files: tests/test_skill_examples.py, tests/skills_baseline.json, tests/ci.sh, 03-BASELINE.md all exist.
- Commits b0d1a93, 9ff9f80, 558959f are ancestors of HEAD; `git rev-list --count` from the recorded base gives 3.
