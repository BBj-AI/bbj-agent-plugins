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
| 07-01-01 | 01 | 1 | REL-06 | T-07-01 | A version other than CONTENT_VERSION FAILs the pinned fact gates with a re-pin message; no skip | gate run + mutation | `python3 -I tests/test_release_text.py && sh tests/test_release_text_mutation.sh` | ✅ (extend) | ⬜ pending |
| 07-01-02 | 01 | 1 | REL-06 | T-07-01 | Re-pinned later version passes with skip=0; generic addressee gate FAILs on a wrong addressee or command | mutation + doc grep | `sh tests/test_release_text_mutation.sh`; PROJECT.md row grep (07-01-PLAN.md Task 2 verify) | ✅ (extend) | ⬜ pending |
| 07-02-01 | 02 | 1 | MAINT-06 | T-07-03, T-07-05 | Scrub farm stays under $WORK; nested output never reaches the runner | integration (nested) | `sh tests/test_path_scrub.sh && sh tests/test_noroute_notice.sh` | ❌ W0 (created by this task) | ⬜ pending |
| 07-02-02 | 02 | 1 | MAINT-06 | T-07-05, T-07-06 | Only fake compilers on PATH; removing the scrub is caught (mutation) | integration + mutation | `sh tests/test_path_scrub.sh && sh tests/test_exit_contract.sh` | ✅ (after 07-02-01) | ⬜ pending |
| 07-02-03 | 02 | 1 | MAINT-06 | T-07-04 | PATH split under set -f, quoted names, caller IFS/noglob restored | unit + full suite with fake compiler on PATH | `sh tests/test_path_scrub.sh`; `PATH=<fake bbjcpl+bbjcplw dir>:$PATH sh tests/run.sh` | ✅ | ⬜ pending |
| 07-03-01 | 03 | 2 | MAINT-07 | T-07-07, T-07-08 | Real home only read (find, cksum, sort), allowlist excludes credentials | unit on fake home + integration | `sh tests/test_home_guard.sh && sh tests/test_install_codex.sh` | ❌ W0 (created by this task) | ⬜ pending |
| 07-03-02 | 03 | 2 | MAINT-07 | T-07-09, T-07-10 | Every watched path detected both ways; hostile names quoted; parallel runs isolated | unit on fake home + static + concurrency | `sh tests/test_home_guard.sh`; two parallel runs both exit 0 | ✅ (after 07-03-01) | ⬜ pending |
| 07-04-01 | 04 | 3 | MAINT-08 | T-07-13 | N/A (documentation) | doc check | prefix loop + mirror diff over CONVENTIONS.md and .claude/CLAUDE.md (07-04-PLAN.md Task 1 verify) | ✅ | ⬜ pending |
| 07-04-02 | 04 | 3 | REL-05 | T-07-11, T-07-12 | No push, no network; main moved by fast-forward only | verification | `git merge-base --is-ancestor <sha> HEAD` x4; `git fetch . origin/main:main`; `sh tests/ci.sh`; fake-compiler `sh tests/run.sh` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs are `07-<plan>-<task>`. Waves: 07-01 and 07-02 run in wave 1, 07-03 in wave 2 (it shares tests/lib.sh with 07-02), and 07-04 in wave 3 (it needs the prefixes of the two new test files).*

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
| Documented gate-prefix list equals what the suite prints | MAINT-08 | No gate in the repo compares the docs to the transcript: the planner rejected the optional sync gate (07-04-PLAN.md objective). Plan 07-04 Task 1's verify loop checks the prefixes and the mirror once, at execution time | `sh tests/run.sh > out; awk '/^gate /{sub(/_.*/,"",$2); print $2}' out \| sort -u` and diff against the prefix lines in `.planning/codebase/CONVENTIONS.md` and `.claude/CLAUDE.md` |
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
