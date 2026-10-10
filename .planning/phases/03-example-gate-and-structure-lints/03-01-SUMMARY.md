---
phase: 03-example-gate-and-structure-lints
plan: 01
subsystem: testing
tags: [python3, stdlib, markdown-fences, baseline, ratchet, gate]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: the two skills under plugins/bbj/skills/ that the gate reads
provides:
  - tests/test_skill_examples.py: fence extractor, info-string grammar, grammar lint, fail-closed baseline loader, pending and ratchet gates, --report writer, 55 fixture gates
  - tests/skills_baseline.json: pending skills with per-check counts, written by --report (bbj-programming phase 4 grammar 11, bbj-web-programming phase 5 grammar 5)
affects: [03-02, 03-03, 03-04, 04-bbj-programming-makeover, 05-bbj-web-programming-makeover]

actuals:
  tokens: 9750
  tasks: 3
  commits: 3
plan_head_before: e3f136c2f0b8e6add666e67cebbfe3180f863f14
plan_head_after: 084fbe6262441ea213fe41301048105a54f2cece

tech-stack:
  added: []
  patterns:
    - "single-file python3 -I test: lint, fixtures and report mode in one file because -I drops the script directory from sys.path"
    - "fixtures run only on the default root; child runs and mutation checks pass a ROOT, so they never recurse"
    - "pending skill violations are per-violation skip gates plus one ratchet gate per (skill, check)"

key-files:
  created:
    - tests/test_skill_examples.py
    - tests/skills_baseline.json
  modified: []

key-decisions:
  - "Every violation gets its own gate (skip for a pending skill, FAIL otherwise) plus a ratchet gate per (skill, check); the research alternative of one skip gate per check was not taken because it would weaken D-01 and D-14"
  - "Counting unit: one violation per offending fence, one per unclosed fence, one per bbj or should-fail block containing '...' (not per occurrence)"
  - "decide() takes the check key as well: decide(check, current, entry), since the baseline count is per check"
  - "D-03 when a check is not measured judges that check by its baseline count (all_zero), generic over CHECKS"

patterns-established:
  - "gate details and report lines pass through safe(): printable ASCII only, so skill text cannot forge a gate line"
  - "report mode reads only the pending skill names from the old baseline, so a baseline that lacks a newly added check can always be regenerated"

requirements-completed: [GATE-01, GATE-02, GATE-06]

coverage:
  - id: D1
    description: "Fence grammar lint (D-05..D-07) over every skill Markdown file, run in CI by tests/run.sh with python3 stdlib only"
    requirement: GATE-01
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (27 skills_fx_grammar_* gates)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Pending list and ratchet (D-01..D-04) with a fail-closed baseline loader; the two current skills are listed as pending with counts that may only fall"
    requirement: GATE-02
    verification:
      - kind: integration
        ref: "python3 -I tests/test_skill_examples.py (skills_fx_ratchet_*, skills_fx_pending_*, skills_fx_baseline_*, skills_fx_cli_*)"
        status: pass
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=586 fail=0 skip=18"
        status: pass
    human_judgment: false
  - id: D3
    description: "--report mode writes the machine baseline (deterministic JSON) and the Markdown to-do list through temp files renamed into place"
    requirement: GATE-06
    verification:
      - kind: unit
        ref: "python3 -I tests/test_skill_examples.py (skills_fx_report_* gates); cmp of a fresh --report JSON with tests/skills_baseline.json"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-10-10
status: complete
---

# Phase 3 Plan 01: Example gate, grammar lint and pending ratchet Summary

**Stdlib-only skill example gate: fence grammar lint over both skills, a --report-written baseline listing bbj-programming (11) and bbj-web-programming (5) as pending, and 55 fixture gates, green under `tests/run.sh`.**

## Performance

- **Duration:** about 25 min
- **Completed:** 2026-10-10
- **Tasks:** 3 of 3
- **Files:** 2 created (tests/test_skill_examples.py, tests/skills_baseline.json), none modified

## Accomplishments

- `python3 -I tests/test_skill_examples.py` reads every regular non-symlink `*.md` file under each skill directory, extracts every fenced block (backtick or tilde, any indentation, same-character closer at least as long) and prints `gate skills_<name> ok|FAIL|skip <detail>` lines that `tests/run.sh` already counts. No runner edit was needed.
- Grammar (D-05..D-07): `bbj`, `bbj should-fail` and `bbj nocheck (reason)` accepted; the eight allowlisted tags ignored; untagged, unknown attribute, other tags, unclosed fences and `...` inside bbj/should-fail blocks are violations.
- Pending and ratchet (D-01..D-04): pending skills print each violation as `skip ... pending (Phase N): ...`; `skills_ratchet_<skill>_<check>` FAILs when a count rises above the baseline (a baseline of 0 is fully enforced); `skills_pending_<skill>` FAILs with "remove from pending" when every count is 0; `skills_pending_keys` rejects unknown keys, missing directories and wrong phases. A missing or malformed baseline is `skills_baseline FAIL` and nothing is pending (fail closed).
- Report mode: `--report JSON MD [ROOT]` writes sorted-key ASCII JSON and a Markdown to-do list atomically, refuses with exit 2 (nothing written) on a root without `plugins/bbj/skills`, a missing output directory or an unreadable existing baseline. Baseline on this repository: bbj-programming phase 4 grammar 11, bbj-web-programming phase 5 grammar 5, `bbj_version` "unknown" until plan 03-04.
- Real tree result: 16 pending skip gates (11 + 5), all ratchet and pending gates ok, exit 0. Full suite: `SUMMARY: ok=586 fail=0 skip=18`.

## Task Commits

1. **Task 1: end-to-end grammar gate and baseline (tracer)** - `0d54919` (feat)
2. **Task 2: 27 grammar fixtures** - `76b950c` (test)
3. **Task 3: 28 ratchet, baseline, cli and report fixtures** - `084fbe6` (test)

## TDD Gate Compliance

Tasks 2 and 3 carry `tdd="true"`, but the plan builds the implementation in Task 1 (tracer) and uses Tasks 2-3 to pin it with fixtures. There is therefore no separate `feat` commit for them and the fixtures were green when first run (an unexpected-green RED by construction, not a wrong test). RED evidence was produced by mutation checks instead, each reverted before commit:

- `untagged fence` reason text changed: `skills_fx_grammar_untagged` FAIL.
- `...` detection disabled: `skills_fx_grammar_dots_in_bbj` and `..._dots_in_should_fail` FAIL.
- tag allowlist branch changed to `other`: `skills_fx_grammar_tag_case` and `..._tag_bbx` FAIL.
- ratchet `>` changed to `>=`: both real-tree ratchet gates FAIL.
- boolean accepted as a count: `skills_fx_baseline_bool_count` FAIL.
- D-03 all-zero check disabled: `skills_fx_pending_all_zero_fails` FAIL.
- missing-directory check disabled: `skills_fx_pending_missing_dir` FAIL.

The git log therefore shows one `feat(03-01)` and two `test(03-01)` commits rather than a RED-then-GREEN pair per task.

## Verification

- All three automated verify blocks of Task 1, the Task 2 case loop and both Task 3 blocks pass.
- `BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true python3 -I tests/test_skill_examples.py` exits 0.
- A run with a ROOT argument prints no `skills_fx_` line; `--bogus` exits 2 with a usage line.
- `git diff --quiet -- plugins/bbj/skills` exits 0; `python3 -I tests/test_layout.py` exits 0; AST check: stdlib imports only, no f-strings.
- No `skillfx-*` temp directory is left under /tmp after a run (listing counted 0 before and after).
- Baseline is byte-identical to a fresh `--report` run (`cmp`); it ends with a newline.

## Deviations from Plan

None - plan executed exactly as written, apart from one signature detail: the plan's `decide(current, entry)` needs the check key to read the per-check baseline count, so the function is `decide(check, current, entry)`. Behaviour and detail strings are as specified. Later plans should call it with the check first.

Also, fixture details avoid the word FAIL after a space (they print `status=FAIL`), because the plan's own verify regex `^gate .* FAIL` would otherwise match an `ok` fixture gate that merely quotes a FAIL status.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The plan's threat register (T-03-01 forged gate lines through `safe()`, T-03-02 fail-closed baseline loader, T-03-03 atomic report writes) is implemented and pinned by fixtures; no network or new trust boundary was added.

## Next Phase Readiness

Ready for 03-02. Contracts kept for later plans: `CHECKS` (extend it, the loader, `fixture_baseline`, `all_zero`, `build_report` and the report table are generic over it), `make_root`, `fixture_baseline`, `clean_skill_md`, `child_run`, `fx`. New checks must keep fixture skills structure-clean (a `## Sources` section with `Verified on BBj 26.03` in fixture reference files).

## Self-Check: PASSED

- tests/test_skill_examples.py and tests/skills_baseline.json exist.
- Commits 0d54919, 76b950c and 084fbe6 are ancestors of HEAD.
- `commits: 3` measured with `git rev-list --count e3f136c..HEAD`.
