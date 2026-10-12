---
phase: "5"
slug: "bbj-web-programming-makeover"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-11"
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
> Source: `05-RESEARCH.md` § Validation Architecture.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Repository gate-line harness (`tests/run.sh`, `python3 -I tests/test_*.py`, `sh tests/test_*.sh`); no third-party framework |
| **Config file** | `tests/skills_baseline.json` (written only by `--report`) |
| **Quick run command** | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py && python3 -I tests/test_check_order.py` |
| **Full suite command** | `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` |
| **Estimated runtime** | ~12 s quick, ~80 s full |

---

## Sampling Rate

- **After every task commit:** quick run command (or the scratch-root dry run for drafts)
- **After every plan wave:** full suite command
- **Before `/gsd-verify-work`:** full suite green with `skip=0` on the live gates; `ledger_check.py` and `probes/run.py --check` green
- **Max feedback latency:** ~80 seconds

---

## Per-Task Verification Map

| Criterion | Requirement | Behavior | Automated Command | File Exists |
|-----------|-------------|----------|-------------------|-------------|
| SC1 | WEB-01 | ledger covers SKILL.md + all 7 references; DOC rows cite accepted URLs (D-16/D-16a); OWNER rows name a CONTEXT grant | `python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py` | ✅ |
| SC1 | WEB-01 | COMPILE probes and owner repros reproduce | `python3 -I .planning/phases/05-bbj-web-programming-makeover/probes/run.py --check` | ✅ |
| SC2 | WEB-02 | description ≤ 1,024, structure lints | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | ✅ |
| SC2 | WEB-02 | taste cut | `! grep -rniE 'gsap|swiper|tabler|playfair|google fonts|fonts\.googleapis|420px|\bInter\b' plugins/bbj/skills/bbj-web-programming` | ✅ |
| SC3 | WEB-03 | `top` = top-level window | `grep -rn 'top level window' plugins/bbj/skills/bbj-web-programming` and `! grep -rnE 'end of .?<body>|wins .*cascade' plugins/bbj/skills/bbj-web-programming` | ✅ |
| SC4 | WEB-03 | every `bbj` block passes both routes; skill out of `pending` | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`; `pending` is `{}` | ✅ |
| SC4 | WEB-03 | check-order block byte-identical; name unchanged | `python3 -I tests/test_check_order.py`; `sed -n 2p .../SKILL.md` = `name: "bbj-web-programming"` | ✅ |
| SC1 | WEB-01 | every shipped dwc- name, OWNER grant and rejected claim traces to the ledger | `python3 -I .planning/phases/05-bbj-web-programming-makeover/trace_check.py plugins/bbj/skills/bbj-web-programming/SKILL.md plugins/bbj/skills/bbj-web-programming/references/*.md` | ✅ |
| — | — | never execute BBj | `sh tests/test_never_execute.sh` | ✅ |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `.planning/phases/05-bbj-web-programming-makeover/probes/run.py` (+ `README.md`, `OUTPUT.txt`), adapted from Phase 4
- [x] `.planning/phases/05-bbj-web-programming-makeover/ledger_check.py`, adapted from Phase 4 (multi-prefix DOC rule, `05-CONTEXT.md` grants)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Owner confirmation of undocumented DWC DOM/CSS claims | WEB-01 | BBj is never run by Claude (04 D-04); only the owner grants OWNER (04 D-21) | Done 2026-10-12 (Stephan Wald, BBj/DWC 26.03 build 10/06/2026 09:19): 9 confirmed (D-19..D-27), O3 and O8 rejected; recording checked by `python3 -I .planning/phases/05-bbj-web-programming-makeover/checklist_check.py --recorded` and `trace_check.py` over the five skill files |
| Triggers-first description | WEB-02 | Judgment of ordering | Checked 2026-10-12: description opens "Write, review, check, or fix BBj code that runs in a browser (DWC or BUI): ..." |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 80s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-10-12

## Validation Audit 2026-10-12

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
