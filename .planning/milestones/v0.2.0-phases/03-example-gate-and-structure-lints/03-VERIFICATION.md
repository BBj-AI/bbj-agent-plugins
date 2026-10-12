---
phase: 03-example-gate-and-structure-lints
verified: 2026-10-10T00:00:00Z
status: passed
score: 5/5 must-haves verified
covered_files:
  - ".planning/phases/03-example-gate-and-structure-lints/03-01-PLAN.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-01-SUMMARY.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-02-PLAN.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-02-SUMMARY.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-03-PLAN.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-03-SUMMARY.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-04-PLAN.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-04-SUMMARY.md"
  - ".planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md"
  - "tests/ci.sh"
  - "tests/skills_baseline.json"
  - "tests/test_skill_examples.py"
covered_digest: "v3:sha256:34f32d94f23e382caff78e7e0b03044e5240c450a07116e4f651d4b9b19778fc"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Confirm D-08 amendment: a bbj should-fail block with only bbj-ls available is undecided (skip, FAIL under BBJ_SKILLS_LIVE=1, not counted in the baseline)"
    expected: "Maintainer accepts this, or asks for bbj-ls-only should-fail to be a violation or a pass"
    why_human: "Recorded in auto mode, not by the user. Implemented and fixture-pinned (ls_only_should_fail_undecided, ..._strict). Whether the semantics are the right ones is a judgment call."
  - test: "Confirm D-13 CI exemption: missing live routes stay skip under CI=true without BBJ_SKILLS_LIVE=1, although the repo rule makes a missing prerequisite a FAIL under CI=true"
    expected: "Maintainer accepts the reviewed exception (CI has no BBj), as tests/test_real_compiler.sh already does"
    why_human: "Recorded in auto mode, not by the user. It is a deliberate deviation from CLAUDE.md and tests/run.sh convention. Phase 6 must run the live gate with BBJ_SKILLS_LIVE=1 locally to compensate."
  - test: "Decide review item IN-03: a live route that exists but is broken (canary pair fails, e.g. compiler output format changed) is only a skip unless BBJ_SKILLS_LIVE=1"
    expected: "Either accept (a skip line is printed, FAIL under BBJ_SKILLS_LIVE=1), or make broken a FAIL in every run and keep the exemption for a missing route only"
    why_human: "Left open in 03-REVIEW-DISPOSITION.md as 'for user review'. Roadmap SC2 names only a missing route. Verified: strict mode fails a broken route (route_broken_strict_fail, route_ls_broken_strict_fail)."
---

# Phase 3: Example gate and structure lints Verification Report

**Phase Goal:** A repeatable gate measures every fenced BBj example and the structure rules of the skills, and the current skills' failures are recorded as the makeover to-do list
**Verified:** 2026-10-10
**Status:** human_needed (all five success criteria verified in code and by running the gate; three recorded decisions or open review items are listed for maintainer confirmation, none is a gap)
**Re-verification:** No, initial verification

## Goal Achievement

### Observable Truths (ROADMAP success criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | CI without BBj: lint extracts every fenced block and enforces the grammar (`bbj` / `bbj should-fail` / `bbj nocheck (reason)` accepted; non-BBj ignored; untagged, unknown attribute, unclosed, missing nocheck reason, `...` in bbj blocks fail) | VERIFIED | CI view (`CI=true BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp python3 -I tests/test_skill_examples.py`): rc 0, 168 ok, 43 skip, 0 FAIL. My own mutation on a scratch copy with a new, non-pending skill produced FAIL gates for: untagged fence, tag `BBj`, `bbj nocheck` with no reason, `...` in a bbj block, `bbj foo`, unclosed fence (rc 1). About 27 grammar fixtures (tilde, indented, four-backtick, tab, closer rules, allowlist) pass. |
| 2 | Live run: `bbjcpl -t -N -X` batched, then `bbj-ls`; bbj must pass every available route; should-fail must fail on at least one; skips without BBj; `BBJ_SKILLS_LIVE=1` turns a missing route into a FAIL | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`: rc 0; `route_bbjcpl ok /opt/bbx/bin/bbjcpl: 95 file(s) in one call` (93 blocks plus 2 canaries); `route_bbj-ls ok ... 93 call(s)`; totals bbjcpl 24 pass/69 fail, bbj-ls 42 pass/51 fail. Without BBj: both routes `skip`. With `BBJ_SKILLS_LIVE=1` and a nonexistent home/dead URL: both routes `FAIL`; a non-loopback URL is refused (`FAIL ... not loopback`). `CPL_ARGS = ["-t","-N","-X"]` at test_skill_examples.py:138. Should-fail rules pinned by `outcome_sf_*` and `ls_only_should_fail_undecided*` fixtures; mutation adding a passing `bbj should-fail` block was counted in the `should-fail` ratchet (FAIL, 1 > baseline 0). |
| 3 | Count of `bbj nocheck` blocks is recorded; gate fails if it grows | VERIFIED | `tests/skills_baseline.json` has `"nocheck": 0`; gate `skills_nocheck_count ok 0 ... (baseline 0)`. Mutation adding one `bbj nocheck (reason)` block: `skills_nocheck_count FAIL 1 bbj nocheck block(s) > baseline 0`. |
| 4 | Structure lints: description > 1,024, any of six denylisted strings, reference file missing Sources section or "Verified on BBj <version>" line | VERIFIED | Mutation on a new skill: `description is 1100 characters (limit 1024)`, `last ## section is 'Intro', not '## Sources'`, `denylisted 'DailyDrift'`; separate mutation: `## Sources has no 'Verified on BBj <version>' line`. Real tree: `bbj-web-programming` description 1575 characters is reported; denylist hits (`watches!`, `cart-updated`, `/opt/basis/bin/`, `migrateSortPrefs`, `DailyDrift`, `DriftDB`) are reported in `bbj-programming/SKILL.md`. Fixtures `structure_denylist_all_six`, `structure_sources_*`, `structure_desc_*` pass. |
| 5 | Baseline report of current skills committed; unreworked skills listed as pending, not silently exempt, so pass/fail stays meaningful | VERIFIED | `03-BASELINE.md` (213 lines, BBj 26.03, routes bbjcpl and bbj-ls) lists per skill every failing block per route with file:line and first error line, plus lint violations. Its counts equal `tests/skills_baseline.json` (bbj-programming: grammar 11, structure 17, bbjcpl 44, bbj-ls 36; bbj-web-programming: 5, 8, 25, 15) and the live run (44+25 = 69 and 36+15 = 51 matches the route totals). Pending skills show per-violation `skip ... pending (Phase N)` gates; ratchet gates FAIL on a rise (mutation: `grammar 12 > baseline 11`, `should-fail 1 > baseline 0`); a new non-pending skill is fully enforced (mutation). Full suite: `CI=true ... sh tests/run.sh` gives `SUMMARY: ok=657 fail=0 skip=49`. |

**Score:** 5/5 truths verified (0 present-but-behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tests/test_skill_examples.py` | Grammar lint, structure lints, ratchets, bbjcpl and bbj-ls routes, report mode, fixtures | VERIFIED | 2,399 lines, substantive, discovered by the `tests/test_*` glob in `tests/run.sh`; no stubs. |
| `tests/skills_baseline.json` | Pending list with per-check counts, nocheck, bbj_version | VERIFIED | 26 lines; read by the gate (fail-closed loader fixtures `baseline_missing/malformed/...` pass). |
| `03-BASELINE.md` | Makeover to-do list | VERIFIED | Counts agree with the JSON and the live run. |
| `tests/ci.sh` | Header names the skill example gate | VERIFIED | Comment-only change; CI runs `tests/ci.sh` which runs `run.sh`. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `tests/run.sh` | `test_skill_examples.py` | `test_*` glob | WIRED | Gates appear in the run.sh output (706 gate lines). |
| gate | `skills_baseline.json` | loader and ratchet | WIRED | Counts compared in `skills_ratchet_*` gates. |
| gate | `/opt/bbx/bin/bbjcpl` | subprocess argument list, `-t -N -X`, one call | WIRED | Live run confirmed. |
| gate | loopback `bbj-ls` | opener with empty ProxyHandler and refusing redirect handler | WIRED | Live run: 93 calls; guards `skills_guard_*` pass (19 refused forms, no redirect, no proxy). |
| `--report` | JSON and Markdown baseline | atomic write | WIRED | `report_*` fixtures pass; refuses unless both routes are ok. |

### Data-Flow Trace (Level 4)

The gate renders no dynamic UI data. Verdicts flow from real compiler and server output; the canary pair (`canary_good.bbj` and `canary_bad.bbj`) rejects a dead or changed-format compiler. Status: FLOWING.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| CI view runs green | `CI=true BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp python3 -I tests/test_skill_examples.py` | rc 0, 0 FAIL | PASS |
| Live run runs green | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | rc 0, 178 ok, 161 skip, 0 FAIL | PASS |
| Strict mode with no route | `BBJ_SKILLS_LIVE=1 BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp ...` | both route gates FAIL | PASS |
| Non-loopback URL refused | `BBJ_SKILLS_LIVE=1 BBJ_LOCAL_MCP_URL=https://docs.example.com/mcp ...` | `FAIL ... refused: not loopback http` | PASS |
| Mutations (new skill, pending rise, nocheck, should-fail) | scratch copies | all FAIL as expected, rc 1 | PASS |
| Full suite | `CI=true ... sh tests/run.sh` | ok=657 fail=0 skip=49 | PASS |

### Probe Execution

No probe scripts are declared by the phase. SKIPPED.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| GATE-01 | 03-01, 03-03 | Fence grammar enforced | SATISFIED | Truth 1; should-fail and bbj rules in truth 2 |
| GATE-02 | 03-01 | Lint runs in CI without BBj | SATISFIED | CI view run green, no BBj needed; CI step is `tests/ci.sh` calling `run.sh` |
| GATE-03 | 03-03, 03-04 | Live check, bbjcpl batched then bbj-ls, skip, strict | SATISFIED | Truth 2 |
| GATE-04 | 03-02 | nocheck ratchet | SATISFIED | Truth 3 |
| GATE-05 | 03-02 | Structure lints | SATISFIED | Truth 4 |
| GATE-06 | 03-01, 03-04 | Baseline report committed | SATISFIED | Truth 5 |

All six IDs from the PLAN frontmatter (GATE-01 to GATE-06) are accounted for and match the ROADMAP phase requirements; none is orphaned. Housekeeping: REQUIREMENTS.md checkboxes and the traceability table still show GATE-01..06 as Pending, and ROADMAP plan checkboxes for Phase 3 are unchecked; the orchestrator should update them on phase completion.

### Anti-Patterns Found

No TBD/FIXME/XXX debt markers or stubs found in the files this phase changed that matter for the goal; the suite and mutations show real behavior. No skill content under `plugins/` was changed by this phase (`git diff e3f136c HEAD -- plugins` is empty), as scoped. Open review items from 03-REVIEW-DISPOSITION.md are informational: IN-01 (constant compared to a copy of itself; the fake-compiler argv guard is the real check), IN-03 (see human item 3), IN-04 and IN-05 (advisory).

### Human Verification Required

#### 1. D-08 amendment (auto mode): bbj-ls-only should-fail is undecided

**Test:** Review the rule: with only bbj-ls available, a `bbj should-fail` block that nothing fails is `skip`, becomes FAIL under `BBJ_SKILLS_LIVE=1`, and is not baselined.
**Expected:** Maintainer accepts or adjusts.
**Why human:** Decision recorded in auto mode, not by the user.

#### 2. D-13 CI exemption (auto mode): live routes stay skip under CI=true

**Test:** Confirm the deliberate deviation from the repo rule that a missing prerequisite fails under `CI=true`.
**Expected:** Accepted because CI has no BBj; Phase 6 runs the live gate locally with `BBJ_SKILLS_LIVE=1`.
**Why human:** Decision recorded in auto mode; deviates from CLAUDE.md convention.

#### 3. IN-03: broken (not missing) route is only a skip outside strict mode

**Test:** Decide whether a canary-detected broken route should FAIL in every run.
**Expected:** Accept or tighten.
**Why human:** Open in the review disposition as "for user review".

### Gaps Summary

No gaps. All five roadmap success criteria are achieved and verified by running the gate in the CI and live views, by reading the code paths, and by independent mutation checks. The baseline and the pending list are committed and consistent with a fresh live run. Status is `human_needed` only because the three items above are auto-mode decisions or open review items that the maintainer should confirm.

---

_Verified: 2026-10-10_
_Verifier: Claude (gsd-verifier)_
