---
status: complete
phase: 06-release-0-2-0
source: [06-01-SUMMARY.md, 06-02-SUMMARY.md, 06-03-SUMMARY.md, 06-04-SUMMARY.md, 06-05-SUMMARY.md, 06-06-SUMMARY.md, 06-07-SUMMARY.md, 06-08-SUMMARY.md]
started: 2026-10-12T18:00:00Z
updated: 2026-10-12T18:46:15.009Z
---

## Current Test

[testing complete]

## Tests

### 1. CHANGELOG 0.2.0 wording matches the shipped docs
expected: Every bullet of the CHANGELOG 0.2.0 entry agrees with README, the two install docs, the manifests and the installer; the Upgrading commands match the install docs.
result: pass

### 2. Owner decisions D-20 to D-23 recorded as answered
expected: In 06-CONTEXT.md, D-20, D-21, D-22 and D-23 each record option (a) as the owner chose it, in wording that says what the owner decided and adds nothing the owner did not say.
result: pass

### 3. Tested against section states only what the release run produced
expected: CHANGELOG `### Tested against` has six lines (docs server 1.2.0, Claude Code 2.1.296, BBj 26.03, Codex CLI 0.162.1 on Linux, the two skills, the test suite ok=738 fail=0 skip=0), each dated 2026-10-12 where a run happened, and the install docs and installer header name Codex CLI 0.162.1 with "Tested on Linux only" kept.
result: pass

### 4. PR #1 merged into main with CI green
expected: https://github.com/BBj-AI/bbj-agent-plugins/pull/1 shows Merged (merge commit, not squash); main's head is f15c257 and the `plugins` CI check on it is green; the merged tree contains no `.planning/` path.
result: pass

### 5. Install from the main branch in Claude Code
expected: In a Claude Code config, `claude plugin marketplace add BBj-AI/bbj-agent-plugins` then `claude plugin install bbj@basis-bbj` installs bbj 0.2.0 enabled; bbj-local is listed and disabled; writing a .bbj with an error gives "bbjcpl reported N error(s) in ..." feedback and a clean file is silent.
result: pass
note: "Owner's macOS Claude Code: bbj 0.2.0 latest, 1 hook loaded; Write of bad.bbj gave 'bbj-local reported 1 error(s) in .../bad.bbj: line 1, column 1: [SyntaxError]' (tier-2 route, no bbjcpl on that machine). Clean-file silence and bbj-local disabled state not re-shown; covered by evidence/install-gate-main.txt."

### 6. Fresh Codex install gives hook feedback after apply_patch
expected: `sh codex/install-codex.sh --with-local` on a Codex 0.162.x home registers bbj-docs, installs both skills in ~/.agents/skills and the hook; after approving it in /hooks, an apply_patch of a bad .bbj returns the bbjcpl error text and a clean one returns nothing.
result: pass
note: "First macOS run (owner's MacBook). install-codex.sh registered bbj-docs, installed both skills to ~/.agents/skills, wrote hooks.json; rerun with --with-local registered bbj-local. In Codex the bbj-programming skill loaded; apply_patch of bad.bbj was blocked with 'bbj-local reported 1 error(s) ... [SyntaxError]' (no bbjcpl on PATH, tier-2 route); good.bbj produced no hook output."

### 7. Tag 0.2.0 and GitHub Release published
expected: https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.0 exists, titled 0.2.0, not draft or prerelease, body equal to the CHANGELOG 0.2.0 entry; the tag is annotated, has no "v" prefix, and points at f15c257.
result: pass

### 8. WR-01: SKILL.md lists the sign characters alone and names @ and & as currency mask characters
expected: WR-01: SKILL.md lists the sign characters alone, says to put one of these in every mask that can format a negative value, and names @ and & as currency mask characters that are not sign characters
result: pass
source: automated
coverage_id: 06-01-D1

### 9. IN-02 and IN-01: sysgui.md modal sentence and $80002$ Dialog bit
expected: IN-02 and IN-01: sysgui.md scopes the modal sentence to top-level windows and describes $80002$ as setting the Dialog bit
result: pass
source: automated
coverage_id: 06-01-D2

### 10. Phase 4 review record reads open 0, total 15
expected: Phase 4 review record reads open: 0, total: 15, with WR-08 skipped and its reason in the Source cell
result: pass
source: automated
coverage_id: 06-01-D3

### 11. ci_shellcheck passes; busybox and shellcheck gates run
expected: ci_shellcheck can pass and the busybox and shellcheck gates run instead of skipping
result: pass
source: automated
coverage_id: 06-01-D4

### 12. Version 0.2.0 everywhere, changed in one commit
expected: REL-01: all four manifest version fields, VERSION and README line 3 read 0.2.0 and were changed in exactly one commit
result: pass
source: automated
coverage_id: 06-02-D1

### 13. claude plugin validate --strict passes
expected: REL-01: claude plugin validate --strict passes on the marketplace and both plugins
result: pass
source: automated
coverage_id: 06-02-D2

### 14. CHANGELOG has one 0.2.0 entry with Upgrading and Not run lines
expected: REL-02: CHANGELOG has one 0.2.0 entry with Upgrading (installer quotes, Claude Code commands), empty Tested against and the two Not run lines
result: pass
source: automated
coverage_id: 06-02-D3

### 15. No shipped file names the earlier version
expected: No file outside .planning and .github/ci-tools names the earlier version; project notes state 0.2.0
result: pass
source: automated
coverage_id: 06-02-D5

### 16. Whole suite at skip=0 fail=0 with live gates
expected: REL-03: whole suite at skip=0 and fail=0 on the planning branch with live gates, busybox and the real Codex
result: pass
source: automated
coverage_id: 06-03-D1

### 17. PR branch has no .planning path
expected: D-01: strict PR branch has no .planning path in any commit and the expected eight deletions only
result: pass
source: automated
coverage_id: 06-03-D2

### 18. Published tree is the tested tree
expected: The published tree is the tested tree: PR root tree equals the planning branch tree without .planning, and the suite on the PR checkout gives the same lines
result: pass
source: automated
coverage_id: 06-03-D3

### 19. Git-source install works over HTTPS by ref
expected: The git-source install path works over HTTPS by ref into a throwaway config before anything is pushed
result: pass
source: automated
coverage_id: 06-04-D1

### 20. Release candidate pushed and draft PR #1 opened
expected: Release candidate pushed (no force) and draft PR #1 against main opened after the owner's approval
result: pass
source: automated
coverage_id: 06-04-D2

### 21. D-13 on a real Claude Code
expected: D-13 on a real Claude Code: bbj 0.2.0 from the pushed ref; feedback after Write and Edit of a bad .bbj; silence for a clean one; no MCP tool call
result: pass
source: automated
coverage_id: 06-04-D3

### 22. bbj-local installs disabled and connects once enabled
expected: bbj-local installs disabled, enable works, claude mcp list shows it connected at http://127.0.0.1:5009/mcp
result: pass
source: automated
coverage_id: 06-04-D4

### 23. Real Claude Code configuration unchanged
expected: Real Claude Code configuration unchanged; throwaway config and its login deleted; CI result of the pushed head recorded
result: pass
source: automated
coverage_id: 06-04-D5

## Summary

total: 23
passed: 23
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
