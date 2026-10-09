---
status: testing
phase: 01-repo-owned-skills-and-local-first-check-route
source: [01-VERIFICATION.md]
started: 2026-10-09T00:00:00Z
updated: 2026-10-09T00:00:00Z
---

## Current Test

number: 3
name: Codex skill loader accepts the check-order markers
expected: |
  With the skills in ~/.agents/skills, a real Codex lists both skills; the markers between
  frontmatter and H1 do not break parsing or leak into the description
awaiting: user response

## Tests

### 1. CHANGELOG ruling (VEND-01 / SC1)
expected: Accept the 0.1.0 entry as historical (override) or reword CHANGELOG.md lines 9 and 41
result: pass
note: User ruled "reword". Lines 9 and 41 reworded; layout gates no_skills_lock and no_vendoring_wording now scan CHANGELOG.md (commit 718c77c).

### 2. WR-03 / D-01: hosted check without asking
expected: Keep D-01 ("use the hosted check without asking, but tell the user") or change it to require asking first; if changed, update the block in codex/AGENTS-snippet.md and both SKILL.md files plus tests/test_check_order.py together
result: pass
note: User ruled "keep D-01". WR-03 closed as accepted; block and pin test unchanged.

### 3. Codex skill loader accepts the check-order markers
expected: With the skills in ~/.agents/skills, a real Codex lists both skills; the `<!-- bbj-check-order:begin/end -->` markers between frontmatter and H1 do not break parsing or leak into the description
result: [pending]

### 4. ShellCheck in CI
expected: Push the branch; the CI run's ShellCheck gate prints ok on codex/install-codex.sh and the changed test scripts
result: [pending]

### 5. Judgment-tier prohibitions
expected: (a) 01-05 check-order text discloses hosted use (timing covered by test 2); (b) README and both install pages never present bbj-local as better or earlier than bbjcpl, never imply it type-checks, and say the hosted check sends code off the machine
result: [pending]

## Summary

total: 5
passed: 2
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
