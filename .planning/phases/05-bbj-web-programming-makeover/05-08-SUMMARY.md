---
phase: 05-bbj-web-programming-makeover
plan: 08
subsystem: skills
tags: [bbj, dwc, registration, form-validation, web-components, owner-grants]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: 05-LEDGER.md rows for the three references, owner grant D-27 (O11), trace_check.py (plan 05-05)
provides:
  - plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md (70 lines)
  - plugins/bbj/skills/bbj-web-programming/references/form-validation.md (59 lines)
  - plugins/bbj/skills/bbj-web-programming/references/shoelace.md (86 lines)
affects: [05-06, 05-10]

actuals:
  tokens: 3202
  tasks: 3
  commits: 3
plan_head_before: 93c4925c87c29363e039dcd7f68fbc653200782d
plan_head_after: 574b7a83b633b54ae0dd9723797157e739e2aa21

tech-stack:
  added: []
  patterns:
    - "Rules quoted from their cited pages; docs URL instead of copied tables; an owner sentence on one line, verbatim, followed by the maintainer wording (D-07)"

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md
    - plugins/bbj/skills/bbj-web-programming/references/form-validation.md
    - plugins/bbj/skills/bbj-web-programming/references/shoelace.md

key-decisions:
  - "No ThinClient sentence in running-dwc-apps.md: L139 and L140 are dropped in the ledger"
  - "The registration block uses empty user$ and password$ variables instead of the probe's literal strings"
  - "setSlot and the /files/ path are pointers to SKILL.md sections (Web components; Injecting CSS and JavaScript), because L062, L079 and L080 are routed to SKILL.md"

requirements-completed: [WEB-01, WEB-02, WEB-03]

completed: 2026-10-12
---

# Phase 5 Plan 08: Application references Summary

**Three application references rewritten from the ledger: DWC registration and URLs with one passing q04 program, the documented form-validation traps with docs URLs instead of tables, and the BBj part of web component loading with the O11 grant and the class-wrapped callback.**

## Performance

- Tasks: 3 (Task 1 tracer, Tasks 2 and 3 auto)
- Commits: ed4d528 (running-dwc-apps.md), 49ac59c (form-validation.md), 574b7a8 (shoelace.md)
- Files: 3 modified, nothing else touched; the Phase 4 skill is unchanged
- Checks per file: `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exits 0 with no line for the file (`skills_pending_bbj-web-programming` stays ok); `trace_check.py` exits 0; each bbj block compiles with `bbjcpl -t -N -X`; `sh tests/run.sh` shows no new FAIL

## Rule to ledger id map

| File | Lines | Ledger ids |
| --- | --- | --- |
| running-dwc-apps.md | 70 | L137 (register first), L141 (browser), L156 (URL format, contexts, example), L145 (getRemoteConfiguration), L148 (getBBjAdmin forms), L150 (setString/setBoolean/commit), L152 (getDwcUrl/getBuiUrl), L153 (browse), L154 (fields by Javadoc pointer), L147 (q04 block) |
| form-validation.md | 59 | L102 (accept, pointer), L103 (22.10), L107 (built-in wins), L105 (never trust), L110 (function or validator attribute, boolean), L111 and L112 (return rule), L113 (value, text, control), L116 (data- prefix), L108 (implementing classes by URL), L115 (p12 block) |
| shoelace.md | 86 | L188 (injectScriptUrl with type=module), L061 (O11 grant), L195 (addWebComponent, setAttribute), L197 (setHtml), L081 (callback, q01 block); L062, L076, L079, L080 appear only as pointers or as code in the p16 block |

## Deviations from Plan

**1. [Rule 2 - Ledger fidelity] "DWC only" not stated in form-validation.md**
- **Found during:** Task 2
- **Issue:** The plan truth for D-12 lists "client validation is BBj 22.10+ and DWC only", but row L103 drops "DWC only": it is on none of the cited pages, and the setClientValidationFunction page says the GUI client uses a Swing JComponent. WEB-02 forbids a rule without a ledger row naming the file.
- **Fix:** Only the 22.10 sentence is written, in the guide's words.
- **Files modified:** form-validation.md

**2. [Rule 2 - Ledger fidelity] setSlot and /files/ stated as pointers**
- **Found during:** Task 3
- **Issue:** The plan asks shoelace.md to state "setSlot with the slot name first" and the /files/ path, but L062, L079 and L080 name SKILL.md as destination.
- **Fix:** shoelace.md points to the SKILL.md sections "Web components" and "Injecting CSS and JavaScript" (headings fixed by plan 05-06) and shows setSlot only inside the p16 block. Plan 05-06 states the rules.
- **Files modified:** shoelace.md

**3. [Task 3 wrap] The O11 granted sentence is on one line**
- **Found during:** Task 3 trace run
- **Issue:** `trace_check.py` failed the grant check because the wrapped sentence was not verbatim.
- **Fix:** The sentence and the maintainer wording sit on one line.

## Known Stubs

None. `user$ = ""` and `password$ = ""` in running-dwc-apps.md are intentional placeholders for the caller's login (T-05-26), not data stubs.

## Threat Flags

None.

## Self-Check: PASSED

- running-dwc-apps.md, form-validation.md, shoelace.md exist; commits ed4d528, 49ac59c, 574b7a8 are ancestors of HEAD.
