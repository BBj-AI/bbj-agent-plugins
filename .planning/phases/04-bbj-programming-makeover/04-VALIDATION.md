---
phase: "4"
slug: "bbj-programming-makeover"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-11"
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Repo gate-line harness (`tests/run.sh`, `python3 -I tests/test_*.py`, `sh tests/test_*.sh`); no third-party framework |
| **Config file** | `tests/skills_baseline.json` (pending list and ratchet counts, written only by `--report`) |
| **Quick run command** | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py && python3 -I tests/test_check_order.py` |
| **Full suite command** | `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` |
| **Estimated runtime** | ~12 seconds (quick), ~80 seconds (full) |

---

## Sampling Rate

- **After every task commit:** Run the quick run command (or the scratch-root dry run `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py <scratch-root>` for drafts)
- **After every plan wave:** Run the full suite command
- **Before `/gsd-verify-work`:** Full suite must be green with `fail=0`
- **Max feedback latency:** 80 seconds

---

## Per-Task Verification Map

Filled by the planner from the PLAN.md `<verify>` blocks. Requirement-level map (from 04-RESEARCH.md, Validation Architecture):

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| PROG-01 | Ledger one row per rule; no RUNTIME row kept; COMPILE rows reproduce | artifact check | `python3 -I .planning/phases/04-bbj-programming-makeover/probes/run.py --check` | ❌ W0 | ⬜ pending |
| PROG-02 | Check-order first and byte-identical; body ~150 lines; docs-tool pointers | test + shell | `python3 -I tests/test_check_order.py`; `wc -l` on SKILL.md | ✅ | ⬜ pending |
| PROG-03 | Primer-gap rules present as passing blocks / should-fail pairs | live gate + grep | quick run command | ✅ | ⬜ pending |
| PROG-04 | Wrong claims corrected; taste and leftovers gone | live gate + grep | quick run command; forbidden-string grep | ✅ | ⬜ pending |
| PROG-05 | Launcher facts docs-cited, framed for "when the user asks" | grep | `grep -n 'documentation.basis.cloud' references/running.md` | ❌ W0 | ⬜ pending |
| PROG-06 | Every block passes both routes; bbj-programming not pending | live gate | quick run command; `grep -c bbj-programming tests/skills_baseline.json` prints 0 | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.planning/phases/04-bbj-programming-makeover/probes/run.py` and `probes/OUTPUT.txt`: probe runner (compile only) and recorded output for the COMPILE rows
- [ ] `04-LEDGER.md` skeleton with the D-02 columns
- [ ] Scratch-root dry-run recipe kept in the phase directory (not under `tests/`)
- [ ] `COVERAGE.md` opt-out for the api-coverage gate

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Each DOC ledger row's URL supports the claim (official body text, not appended skill text) | PROG-01 | Judging a quoted sentence needs a reader | Spot-check the DOC rows against the cited pages |
| 04-DOCS-PROPOSAL.md reads as a usable proposal for the BASIS docs owners | D-18 | Editorial quality | Read the STR() section first |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 80s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
