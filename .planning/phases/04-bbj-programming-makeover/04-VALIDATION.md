---
phase: "4"
slug: "bbj-programming-makeover"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
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
| PROG-01 | Ledger one row per rule; classes exactly DOC / COMPILE / RUNTIME / OWNER; no RUNTIME row kept; OWNER rows name confirmer, date, version (D-21); COMPILE rows reproduce | artifact check | `python3 -I .planning/phases/04-bbj-programming-makeover/probes/run.py --check` | ❌ W0 | ✅ green |
| PROG-02 | Check-order first and byte-identical; body ~150 lines; docs-tool pointers | test + shell | `python3 -I tests/test_check_order.py`; `wc -l` on SKILL.md | ✅ | ✅ green |
| PROG-03 | Primer-gap rules present as passing blocks / should-fail pairs | live gate + grep | quick run command | ✅ | ✅ green |
| PROG-04 | Wrong claims corrected; taste and leftovers gone | live gate + grep | quick run command; forbidden-string grep | ✅ | ✅ green |
| PROG-05 | Launcher facts docs-cited or OWNER-confirmed (-tIO, D-22), framed for "when the user asks" | grep | `grep -n 'documentation.basis.cloud' references/running.md` | ❌ W0 | ✅ green |
| PROG-06 | Every block passes both routes; bbj-programming not pending | live gate | quick run command; `grep -c bbj-programming tests/skills_baseline.json` prints 0 | ✅ | ✅ green |

Per-task map (from the PLAN.md `<verify>` blocks; P = .planning/phases/04-bbj-programming-makeover):

| Task | Plan | Wave | Requirement | Threat Ref | Automated command (core) | File Exists | Status |
|------|------|------|-------------|------------|--------------------------|-------------|--------|
| 04-01-T1 | 01 | 1 | PROG-01 | T-04-01, T-04-02, T-04-03 | `python3 -I P/probes/run.py --check` + OUTPUT.txt greps + interpreter/URL negative greps on run.py | ❌ W0 (created here) | ✅ green |
| 04-01-T2 | 01 | 1 | PROG-01 | T-04-04 | `python3 -I P/probes/run.py --check` + 13 OUTPUT.txt markers + rw lines | ❌ W0 (created here) | ✅ green |
| 04-02-T1 | 02 | 2 | PROG-01 | T-04-06, T-04-08 | `python3 -I P/ledger_check.py` (16 gates ok incl. ledger_owner, files_covered FAIL until T3) + OWNER in Legend | ❌ W0 (created here) | ✅ green |
| 04-02-T2 | 02 | 2 | PROG-01 | T-04-06, T-04-26 | `python3 -I P/ledger_check.py` + SKILL.md rows >= 45 (measured: Task 2 default-verdict items) + exactly 2 OWNER rows (D-22) + no class outside D-04/D-21 + URL greps | ✅ | ✅ green |
| 04-02-T3 | 02 | 2 | PROG-01 | T-04-06, T-04-08, T-04-26 | `python3 -I P/ledger_check.py` exit 0, totals >= 80 rows (measured: 45 + 35 default-verdict items) + OWNER-confirmed Totals list | ✅ | ✅ green |
| 04-03-T1 | 03 | 3 | PROG-02, PROG-03 | T-04-10, T-04-11 | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` (no SKILL.md gate) + `python3 -I tests/test_check_order.py` + description check | ✅ | ✅ green |
| 04-03-T2 | 03 | 3 | PROG-03, PROG-04 | T-04-12 | live gate + Built in `grep -xF` + sign-trap phrases, unhedged (D-22) + `sh tests/test_install_codex.sh` + body <= 148 | ✅ | ✅ green |
| 04-03-T3 | 03 | 3 | PROG-04, PROG-06 | T-04-14 | cut-list negative grep + `--report` cmp + `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` + CI view | ✅ | ✅ green |
| 04-04-T1 | 04 | 3 | PROG-01 | T-04-15 | STR() chapter first + URL greps on 04-DOCS-PROPOSAL.md + owner confirmation line and the sign OWNER id in the STR() chapter (D-23) | ❌ (created here) | ✅ green |
| 04-04-T2 | 04 | 3 | PROG-01 | T-04-15 | every COMPILE keep/rewrite and every OWNER ledger id present in the proposal + section order | ✅ | ✅ green |
| 04-05-T1 | 05 | 4 | PROG-05 | T-04-17, T-04-18, T-04-19 | live gate (no running.md gate) + URL and framing greps + -tIO stdout line, unhedged (D-22) + body <= 150 | ❌ (created here) | ✅ green |
| 04-05-T2 | 05 | 4 | PROG-04, PROG-06 | T-04-10 | live gate (no sysgui.md gate) + setModal should-fail + Sources | ✅ | ✅ green |
| 04-05-T3 | 05 | 4 | PROG-04, PROG-06 | T-04-20, T-04-21 | live gate + branch matches ledger count C (>= 3 keep, < 3 fold) + reject should-fail + web link resolves + `--report` cmp + full suite + CI view | ✅ | ✅ green |
| 04-06-T1 | 06 | 5 | PROG-04 | T-04-23 | live gate (no database.md gate) + LIMIT URL + dropped claims absent | ✅ | ✅ green |
| 04-06-T2 | 06 | 5 | PROG-06 | T-04-22, T-04-25 | deleted files unnamed + 0 violations on all five ratchets + baseline pending only web + `--report` cmp + ASCII blocks + full suite + CI view + run.py --check + ledger_check | ✅ | ✅ green |

*Status: ✅ green · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `.planning/phases/04-bbj-programming-makeover/probes/run.py` and `probes/OUTPUT.txt`: probe runner (compile only) and recorded output for the COMPILE rows (plan 04-01)
- [x] `04-LEDGER.md` skeleton with the D-02 columns and `ledger_check.py` (plan 04-02 Task 1)
- [x] Scratch-root dry-run recipe kept in the phase directory (not under `tests/`): `probes/README.md` (plan 04-01 Task 2)
- [x] `COVERAGE.md` opt-out for the api-coverage gate (written at plan time; `check api-coverage.verify-pre` passes)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Each DOC ledger row's URL supports the claim (official body text, not appended skill text) | PROG-01 | Judging a quoted sentence needs a reader | Spot-check the DOC rows against the cited pages |
| 04-DOCS-PROPOSAL.md reads as a usable proposal for the BASIS docs owners | D-18 | Editorial quality | Read the STR() section first |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 80s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-10-11

## Validation Audit 2026-10-11

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
