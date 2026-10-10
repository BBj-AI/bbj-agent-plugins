---
status: testing
phase: 02-hook-no-route-notice
source: [02-VERIFICATION.md]
started: 2026-10-10T12:26:43Z
updated: 2026-10-10T12:26:43Z
---

## Current Test

number: 1
name: Codex delivers the no-route notice to the model (HOOK-04, success criterion 4)
expected: |
  The model names `install-codex.sh --with-local` (present only in the notice's Codex branch) after
  PATCH 1 and nothing of the kind after PATCH 2. Alternatively, accept the run-2 paraphrase recorded in
  evidence/codex/README.md "Delivery judgement" as proof. If the model cannot do this, D-15 applies.
awaiting: user response

## Tests

### 1. Codex delivers the no-route notice to the model (HOOK-04, success criterion 4)
expected: The model names `install-codex.sh --with-local` after PATCH 1 and nothing after PATCH 2 (a check a guess or a refusal to quote cannot satisfy), or the user accepts the run-2 paraphrase as proof.
result: [pending]

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
