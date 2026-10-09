---
status: testing
phase: 01-repo-owned-skills-and-local-first-check-route
source: [01-VERIFICATION.md]
started: 2026-10-09T00:00:00Z
updated: 2026-10-09T00:00:00Z
---

## Current Test

number: 5
name: Judgment-tier prohibitions
expected: |
  README and both install pages never present bbj-local as better or earlier than bbjcpl,
  never imply it type-checks, and say the hosted check sends code off the machine
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
result: pass
note: 2026-10-09, Codex CLI 0.156.1: both shipped skills copied into a scratch repo's .agents/skills; `codex debug prompt-input` lists bbj-programming and bbj-web-programming with their full frontmatter descriptions; the string bbj-check-order does not appear in the skill list. Real ~/.codex untouched.

### 4. ShellCheck in CI
expected: Push the branch; the CI run's ShellCheck gate prints ok on codex/install-codex.sh and the changed test scripts
result: pass
note: GitHub Actions run 37993749758 on gsd/planning-setup (commit 390aa3d): static_shellcheck_install-codex.sh ok, ci_shellcheck ok over plugins/bbj/scripts, codex and tests; tests/run.sh SUMMARY ok=425 fail=0 skip=6; CI SUMMARY ok=6 fail=0 skip=0.

### 5. Judgment-tier prohibitions
expected: (a) 01-05 check-order text discloses hosted use (timing covered by test 2); (b) README and both install pages never present bbj-local as better or earlier than bbjcpl, never imply it type-checks, and say the hosted check sends code off the machine
result: [pending]

## Summary

total: 5
passed: 4
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
