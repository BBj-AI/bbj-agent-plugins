---
phase: "07"
slug: "test-hardening-and-release-prep"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-12"
---

# Phase 07 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Custom gate protocol: `gate NAME ok|FAIL|skip DETAIL` (shell via `tests/lib.sh`, Python per file), runner `tests/run.sh` |
| **Config file** | none (`.shellcheckrc` for lint) |
| **Quick run command** | `sh tests/test_<area>.sh` or `python3 -I tests/test_<area>.py` (single file) |
| **Full suite command** | `sh tests/run.sh` (`sh tests/ci.sh` adds `claude plugin validate --strict` and `shellcheck -s sh`) |
| **Estimated runtime** | ~84 seconds today; expect ~110 seconds after this phase |

---

## Sampling Rate

- **After every task commit:** Run the single test file touched (`sh tests/test_<area>.sh`, 1–31 s) and `shellcheck -s sh tests/<file>.sh`
- **After every plan wave:** Run `sh tests/run.sh`
- **Before `/gsd-verify-work`:** Full suite must be green with `skip=0` (baseline `ok=757 fail=0 skip=0`), plus one run with a fake `bbjcpl`/`bbjcplw` first on `PATH`, plus the four `git merge-base --is-ancestor <sha> HEAD` checks
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 07-XX-XX | XX | X | MAINT-06 | — | N/A | unit + mutation | `sh tests/test_path_scrub.sh` | ❌ W0 | ⬜ pending |
| 07-XX-XX | XX | X | MAINT-07 | — | N/A | unit on fake home + static | `sh tests/test_home_guard.sh` | ❌ W0 | ⬜ pending |
| 07-XX-XX | XX | X | MAINT-07 | — | N/A | integration | `sh tests/test_install_codex.sh` | ✅ | ⬜ pending |
| 07-XX-XX | XX | X | MAINT-08 | — | N/A | doc check | `sh tests/run.sh` transcript prefixes vs CONVENTIONS.md / .claude/CLAUDE.md | ✅ | ⬜ pending |
| 07-XX-XX | XX | X | REL-05 | — | N/A | verification | `git merge-base --is-ancestor <sha> HEAD` x4; `sh tests/run.sh` | ✅ | ⬜ pending |
| 07-XX-XX | XX | X | REL-06 | — | N/A | mutation | `sh tests/test_release_text_mutation.sh` | ✅ (extend) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*The planner replaces the `XX` placeholders with real task IDs, plan numbers and waves when PLAN.md files exist.*

---

## Wave 0 Requirements

- [ ] `tests/test_path_scrub.sh` — covers MAINT-06 (D-13)
- [ ] `tests/test_home_guard.sh` — covers MAINT-07 (D-10)
- [ ] helpers in `tests/lib.sh` (PATH scrub, compiler-env clear, home snapshot, snapshot compare) and their entries in its header comment
- [ ] extended cases in `tests/test_release_text_mutation.sh` — covers REL-06

No framework install is needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Documented gate-prefix list equals what the suite prints | MAINT-08 | No gate in the repo compares the docs to the transcript (optional sync gate is at the planner's discretion) | `sh tests/run.sh > out; awk '/^gate /{sub(/_.*/,"",$2); print $2}' out \| sort -u` and diff against the prefix lines in `.planning/codebase/CONVENTIONS.md` and `.claude/CLAUDE.md` |
| Real `real_home_untouched` gate passes while a Codex daemon is running | MAINT-07 | Needs a real Codex daemon writing `logs_*.sqlite*`; CI has none | Start Codex, run `sh tests/test_install_codex.sh`, confirm `real_home_untouched ok` |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
