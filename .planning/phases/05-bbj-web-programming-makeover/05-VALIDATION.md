---
phase: "5"
slug: "bbj-web-programming-makeover"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| SC1 | WEB-01 | ledger covers SKILL.md + all 7 references; DOC rows cite accepted URLs (D-16/D-16a); OWNER rows name a CONTEXT grant | `python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py` | ❌ W0 |
| SC1 | WEB-01 | COMPILE probes reproduce | `python3 -I .planning/phases/05-bbj-web-programming-makeover/probes/run.py --check` | ❌ W0 |
| SC2 | WEB-02 | description ≤ 1,024, structure lints | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | ✅ |
| SC2 | WEB-02 | taste cut | `! grep -rniE 'gsap|swiper|tabler|playfair|google fonts|fonts\.googleapis|420px|\bInter\b' plugins/bbj/skills/bbj-web-programming` | ✅ |
| SC3 | WEB-03 | `top` = top-level window | `grep -rn 'top level window' plugins/bbj/skills/bbj-web-programming` and `! grep -rnE 'end of .?<body>|wins .*cascade' plugins/bbj/skills/bbj-web-programming` | ✅ |
| SC4 | WEB-03 | every `bbj` block passes both routes; skill out of `pending` | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`; `pending` is `{}` | ✅ |
| SC4 | WEB-03 | check-order block byte-identical; name unchanged | `python3 -I tests/test_check_order.py`; `sed -n 2p .../SKILL.md` = `name: "bbj-web-programming"` | ✅ |
| — | — | never execute BBj | `sh tests/test_never_execute.sh` | ✅ |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.planning/phases/05-bbj-web-programming-makeover/probes/run.py` (+ `README.md`, `OUTPUT.txt`), adapted from Phase 4
- [ ] `.planning/phases/05-bbj-web-programming-makeover/ledger_check.py`, adapted from Phase 4 (multi-prefix DOC rule, `05-CONTEXT.md` grants)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Owner confirmation of undocumented DWC DOM/CSS claims | WEB-01 | BBj is never run by Claude (04 D-04); only the owner grants OWNER (04 D-21) | Owner runs each `owner-repros/*.bbj` in a browser per `05-OWNER-CHECKLIST.md`, records confirm/reject + DWC/BBj build |
| Triggers-first description | WEB-02 | Judgment of ordering | Read the description: triggers precede symptoms |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 80s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
