---
status: complete
phase: 07-test-hardening-and-release-prep
source: [07-01-SUMMARY.md, 07-02-SUMMARY.md, 07-03-SUMMARY.md, 07-04-SUMMARY.md, 07-05-SUMMARY.md, 07-06-SUMMARY.md]
started: 2026-10-13T06:46:26Z
updated: 2026-10-13T11:26:06.477Z
---

## Current Test

[testing complete]

## Tests

### 1. Release-text gate policy is recorded with its reason
expected: Open the module docstring at the top of tests/test_release_text.py and the Key Decisions table in .planning/PROJECT.md (the "Release-text gates" row). Both state the same policy in readable prose: upgrade_addressed runs at every version; upgrade_quotes and not_run are pinned to CONTENT_VERSION (0.2.0) and FAIL with a re-pin message at any other version, never skip. Both give the reason (a version bump must not pass on an older release's facts, and a skip would block the skip=0 release run; reverses the skip half of review fix WR-02 on purpose). The docstring also carries a version-bump checklist. A reader who has not seen the plan can tell what to do at the next release from this text alone.
result: pass
coverage_id: 07-01 D3
rationale: Wording of the policy and its reason is prose; a reader must judge that it is clear (REL-06).

### 2. real_home_untouched stays green while a live Codex daemon runs
expected: With Codex running on this machine (a live daemon writing logs_*.sqlite*, state, history, sessions under ~/.codex), run `sh tests/test_install_codex.sh`. The transcript shows `gate real_home_untouched ok` and the script exits 0. Nothing under ~/.codex (config.toml, hooks.json, bbj/) or ~/.agents/skills changes as a result of the run.
result: pass
evidence: "live run 2026-10-13: gate real_home_untouched ok, no watched path under the real ~/.codex or ~/.agents/skills changed"
coverage_id: 07-03 D4
rationale: Needs a live Codex daemon on the maintainer's machine; the optional end-of-phase human check was not done. Daemon writes are covered on fakes (MAINT-07).

### 3. Gate-prefix bullet in CONVENTIONS.md and its mirror in CLAUDE.md are byte-identical
expected: The four-line gate-prefix bullet block in .planning/codebase/CONVENTIONS.md (the "Gate names start with a prefix" bullet and its three sub-bullets) is byte-identical to the same block inside the GSD:conventions section of .claude/CLAUDE.md. Note: 07-VERIFICATION.md already reports this as FAILED (minor): fix commit e39b4bc (IN-04) rewrote the lead sentence and free-form entries in .claude/CLAUDE.md only, so CONVENTIONS.md still says "a new test file takes one new prefix of its own" and lacks the "plus free-form names" entries. Confirm whether you want this closed in this phase or deferred.
result: pass
note: "User passed this checkpoint knowing the two blocks currently differ (07-VERIFICATION.md gap, fix commit e39b4bc touched .claude/CLAUDE.md only); the drift remains tracked by the verification report, not as a UAT gap"
coverage_id: 07-04 D1
rationale: The SUMMARY's automated mirror check ran before fix commit e39b4bc; a fresh compare of the two blocks returns not equal, so this cannot be treated as auto-covered (MAINT-08).

### 4. upgrade_addressed runs at every version (addressee and the two Claude Code commands)
expected: upgrade_addressed runs at every version (addressee and the two Claude Code commands)
result: pass
source: automated
coverage_id: 07-01 D1

### 5. upgrade_quotes and not_run FAIL with the re-pin text at a foreign version and never skip; a re-pinned copy passes
expected: upgrade_quotes and not_run FAIL with the re-pin text at a foreign version and never skip; a re-pinned copy passes
result: pass
source: automated
coverage_id: 07-01 D2

### 6. 0.2.0 facts unchanged; suite green at 0.2.0
expected: 0.2.0 facts unchanged; suite green at 0.2.0
result: pass
source: automated
coverage_id: 07-01 D4

### 7. no_compiler_path and no_compiler_env helpers in tests/lib.sh
expected: no_compiler_path and no_compiler_env helpers in tests/lib.sh
result: pass
source: automated
coverage_id: 07-02 D1

### 8. sh tests/run.sh passes with a fake bbjcpl and bbjcplw first on PATH
expected: sh tests/run.sh passes with a fake bbjcpl and bbjcplw first on PATH
result: pass
source: automated
coverage_id: 07-02 D2

### 9. Removing the scrub is caught in CI without BBj (D-13)
expected: Removing the scrub is caught in CI without BBj (D-13)
result: pass
source: automated
coverage_id: 07-02 D3

### 10. real_home_untouched passes while a Codex daemon writes runtime files and compares content, not mtime
expected: real_home_untouched passes while a Codex daemon writes runtime files (logs_*.sqlite*, state, history, sessions, log, tmp, auth.json) and compares content, not mtime
result: pass
source: automated
coverage_id: 07-03 D1

### 11. A change to config.toml, config.toml.bbj-backup, hooks.json, bbj/ or either installed bbj skill still fails the gate
expected: A change to config.toml, config.toml.bbj-backup, hooks.json, bbj/ or either installed bbj skill still fails the gate
result: pass
source: automated
coverage_id: 07-03 D2

### 12. test_install_codex.sh uses the helper on the real homes and keeps no mtime comparison
expected: test_install_codex.sh uses the helper on the real homes and keeps no mtime comparison
result: pass
source: automated
coverage_id: 07-03 D3

### 13. The four 0.2.0 review-fix commits are ancestors of HEAD; sh tests/ci.sh green
expected: b0a4c62, 3a42ebf, b600ac4, 172e6a5 are ancestors of HEAD; sh tests/ci.sh green
result: pass
source: automated
coverage_id: 07-04 D2

### 14. Local main equals origin/main, HEAD still gsd/planning-setup, nothing pushed or fetched from a remote
expected: Local main equals origin/main, HEAD still gsd/planning-setup, nothing pushed or fetched from a remote
result: pass
source: automated
coverage_id: 07-04 D3

### 15. Gate-prefix block in CONVENTIONS.md is a byte copy of the IN-04 block in .claude/CLAUDE.md; neighbours and all other lines unchanged
expected: Gate-prefix block in CONVENTIONS.md is a byte copy of the IN-04 block in .claude/CLAUDE.md; neighbours and all other lines unchanged
result: pass
source: automated
coverage_id: 07-05 D1

### 16. Synced block matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD
expected: Synced block matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD
result: pass
source: automated
coverage_id: 07-05 D2

### 17. Gate-prefix block in CONVENTIONS.md lists oauth_ for test_install_codex.sh and is a byte copy of the .claude/CLAUDE.md block; exactly one line changed
expected: Gate-prefix block in CONVENTIONS.md lists oauth_ for test_install_codex.sh and is a byte copy of the .claude/CLAUDE.md block; exactly one line changed
result: pass
source: automated
coverage_id: 07-06 D1

### 18. Synced block, oauth_ included, matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD
expected: Synced block, oauth_ included, matches the prefixes and file sections of a fresh sh tests/run.sh transcript at HEAD
result: pass
source: automated
coverage_id: 07-06 D2

## Summary

total: 18
passed: 18
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
