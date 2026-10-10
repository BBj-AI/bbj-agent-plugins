---
status: testing
phase: 03-example-gate-and-structure-lints
source: [03-VERIFICATION.md]
started: 2026-10-10T16:51:53Z
updated: 2026-10-10T16:51:53Z
---

## Current Test

number: 1
name: Confirm D-08 amendment (bbj-ls-only should-fail is undecided)
expected: |
  A bbj should-fail block that no route fails, with only bbj-ls available, prints skip,
  FAILs under BBJ_SKILLS_LIVE=1, and is not counted in the baseline. Maintainer accepts this,
  or asks for it to be a violation or a pass.
awaiting: user response

## Tests

### 1. Confirm D-08 amendment (bbj-ls-only should-fail is undecided)
expected: Maintainer accepts the undecided rule (skip; FAIL under BBJ_SKILLS_LIVE=1; not counted), or asks for a violation or a pass instead
result: [pending]

### 2. Confirm D-13 CI exemption (missing live routes stay skip under CI=true)
expected: Maintainer accepts the reviewed exception to the CI=true missing-prerequisite rule (CI has no BBj, as in tests/test_real_compiler.sh); Phase 6 runs the live gate locally with BBJ_SKILLS_LIVE=1
result: [pending]

### 3. Decide IN-03 (a broken but present live route is skip unless BBJ_SKILLS_LIVE=1)
expected: Either accept as is, or make a broken route (failed canary pair) a FAIL in every run and keep the exemption for a missing route only
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
