---
phase: 05-bbj-web-programming-makeover
plan: 02
subsystem: testing
tags: [bbj, dwc, claim-ledger, ledger-check, owner-checklist]

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: probes/OUTPUT.txt compile evidence (plan 05-01)
  - phase: 04-bbj-programming-makeover
    provides: the ledger method and ledger_check.py
provides:
  - ledger_check.py, the Phase 5 checker (19 gates, three DOC hosts, owner checklist and triage rules)
  - 05-LEDGER.md with header, Legend and 88 rows for every rule of the current SKILL.md
  - owner checklist items O1-O9 and O11 marked as RUNTIME drop rows with their "if confirmed" destination
affects: [05-03, 05-04, 05-05, 05-06, 05-07, 05-08]

actuals:
  tokens: 16623
  tasks: 3
  commits: 3
plan_head_before: 82d454d66d2ae2f45b52d63b55201aa4db083eab
plan_head_after: 2e74cf7092b845e018c41ce51bb5884dd16fba7f

tech-stack:
  added: []
  patterns:
    - "Ledger row = one stated fact; DOC quotes are checked against the fetched page file; a rule that overreaches its page is rewritten to the page's words"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/ledger_check.py
    - .planning/phases/05-bbj-web-programming-makeover/05-LEDGER.md
  modified: []

key-decisions:
  - "The ledger header pins DWC 26 (v26 design system), shipped with BBj 26.03 build 10-01-2026_1321, and the primer footer bbj-docs . hosted . docs 2026-10-09 . e43802fa"
  - "No row is OWNER: ten undocumented DOM/CSS claims an agent would get wrong are RUNTIME drop rows with owner checklist items for plans 05-04 and 05-05"
  - "The outline mechanism of the focus ring is dropped as contradicted by the docs; the padding rule is rewritten into references/styling.md in the docs' words"

patterns-established:
  - "Rows whose claim cell names taste (GSAP, Swiper, Tabler, Google Fonts, Playfair, 420px, Utils, naming pattern) are all verdict drop; the Task 3 verify scans for it"

requirements-completed: [WEB-01, WEB-03]

duration: 20 min
completed: 2026-10-11
status: complete
---

# Phase 5 Plan 02: Claim ledger for SKILL.md Summary

**An adapted `ledger_check.py` (19 gates, three DOC hosts, owner-checklist and static-file triage rules) and `05-LEDGER.md` with 88 sourced rows covering every rule of the current `bbj-web-programming` SKILL.md.**

## Performance

- **Duration:** about 20 min
- **Tasks:** 3 (one tracer, two auto)
- **Files created:** 2

## Accomplishments

- `ledger_check.py` adapts the Phase 4 checker: `DOC_PREFIXES` accepts `documentation.basis.cloud`, `dwc.style/docs` and `docs.webforj.com/docs`; `ledger_owner_items` (O1 to O11, RUNTIME drop or OWNER) and `ledger_triage` (D-16b) are new; `argv[2]` takes a context copy; owner repros are accepted as `owner-repros/<name>.bbj` sections of OUTPUT.txt. It prints the 19 gates of the interfaces block. Mutation proofs on scratch copies all exit 1 with the expected gate (RUNTIME keep: `ledger_runtime`; `DOC plus note`: `ledger_class`; example.org evidence: `ledger_doc_url`; dwc-ui.css without "triage": `ledger_triage`; OWNER citing D-16: `ledger_owner`); positive proofs pass (dwc.style evidence; an OWNER copy citing a rehearsal D-99 in a context copy).
- `05-LEDGER.md` header: base commit `82d454d`, BBj 26.03, primer footer, DWC pin. Legend states the four classes, the three DOC hosts, the owner-checklist marking, and that the install's static files are triage only.
- SKILL.md section: 88 rows, DOC 34, COMPILE 9, RUNTIME 45, OWNER 0; keep 9, rewrite 30, drop 47, fold 2. Final gate state: every gate ok except `ledger_files_covered` (the seven references are ledgered by plan 05-03).
- WEB-03: the `injectStyle` top row (L058, SKILL.md:234-235) is DOC with `BBjBuiManager_injectStyle.htm`, the quoted sentence and p09, verdict rewrite (SKILL.md). The head/body/cascade reading is the `injectLinkUrl` wording misapplied.
- Owner checklist items marked: O1, O2, O3, O4, O5, O6, O7, O8, O9, O11 (O10, the colour chooser fraction, belongs to plan 05-03's reference rows).
- The setSlot argument order is a COMPILE row (p01 clean, p02 `No match for method`, route bbjcpl); the `setOuterStyle` row is COMPILE with p03 and p05 (a type check error, not a syntax error; BBjChildWindow has no `setOuterStyle`); the `getProperty` string assignment is its own COMPILE row (p17).

## Task Commits

1. **Task 1 (tracer): ledger checker and the injectStyle top row** - `3b67a53` (feat)
2. **Task 2: SKILL.md lines 1-218** - `ec41f2e` (feat)
3. **Task 3: SKILL.md lines 219-380** - `2e74cf7` (feat)

The tracer gate passed: the Task 1 verify re-ran end to end (every gate except `ledger_files_covered` ok, which FAILs as designed) before the expansion rows were written.

## Changes to the default verdicts of Tasks 2 and 3

- **SKILL.md:217 (GRAVITY), keep -> rewrite.** The page says the flag "is not currently exposed in the UI, and corresponds to the "GRAVITY" flag"; the skill says it is exposed in WindowBuilder's UI as GRAVITY. Only the add-a-GRAVITY-line half matches.
- **SKILL.md:232 (inline injection), keep -> rewrite.** The injectStyle and injectScript pages say only that the method injects the CSS or JavaScript into the web page; "for self-contained files" is not on either page.
- **SKILL.md:243 (`/files/`), keep -> rewrite.** The registration page speaks of an html file saved to the htdocs directory and does not name Jetty.
- **SKILL.md:148 (outer-style family), wording only.** "all BBj 22+" is wrong for three methods: `setOuterStyle`, `getOuterStyle` and `getComputedOuterStyle` say BBj 21; the other four say 22. Verdict stays rewrite.
- **SKILL.md:208-211 (composites), "keep or rewrite" -> rewrite for all four.** "fills the viewport", "modal", "plain flex/grid container" and "bordered and titled" are not on the pages; the decoded flag names are.
- **SKILL.md:169 setOuterStyle, class COMPILE (plan: DOC plus COMPILE).** One class per row; the page is cited as well, and the compile result is what corrects the claim.
- **SKILL.md:302-307 (selector list).** Not kept: `dwc-field` occurs only in the DWC_Labels.htm example, `dwc-choicebox` and `dwc-radio` only inside `--dwc-*` token names, `dwc-textfield` on no fetched page. The rewrite uses `dwc-button` (the tag of the upgrade guide's example) or a class the program adds.
- **Added rows beyond the plan list** (all within the default verdict logic): getWebManager "once, in the constructor" (drop); getProperty string assignment (p17, rewrite); the three reasons for the label attribute (rewrite to the page's statements); `dwc-icon` pools (the page says pools are configured and icons load from a CDN, not "a built-in pool"; rewrite).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The gap-ring sentence is on docs.webforj.com, not on the dwc.style style page**
- **Found during:** Task 3
- **Issue:** the plan attributes "The focus ring uses a gap-ring pattern ..." to `https://dwc.style/docs/#/theme-engine/style`; the fetched dwc.style page does not contain it. It is on `https://docs.webforj.com/docs/styling/state`.
- **Fix:** the outline row cites docs.webforj.com for that sentence and dwc.style only for "a focus ring is shown around the element to indicate the current focus position."
- **Files modified:** 05-LEDGER.md
- **Commit:** 2e74cf7

**2. [Rule 3 - Blocking] bbj://primer read through raw JSON-RPC**
- **Found during:** Task 1
- **Issue:** the bbj-docs MCP tools are not exposed to this agent, and `resources/read` carries no footer line.
- **Fix:** the primer was read with `curl` against the hosted server (read-only, no code sent); the footer was taken from a tool-call reply and equals the RESEARCH value. Primer cells were filled from the 40,981-character text: `yes gotchas/20` for `&&`, `yes modern_bbj/5` for the DWC framing, `no` elsewhere.

**3. [Rule 2 - Missing critical functionality] Two extra header/evidence checks in ledger_check.py**
- **Issue:** the plan names no check for the `BBj:` header line or for the DWC build in OWNER evidence; D-07 and D-16 require both.
- **Fix:** `ledger_header` also requires a `BBj: 26.03` line; `ledger_owner` requires "DWC " in OWNER evidence (matching the interfaces block's OWNER evidence format).

**Total deviations:** 3 auto-fixed. **Impact:** none on scope; no shipped file changed (`git status --porcelain -- plugins tests codex` prints nothing).

## Issues Encountered

None blocking. Every DOC quote was checked against the fetched page file (whitespace-insensitive); a scan of all quoted strings of 25 characters or more in the DOC rows found only the ledger's own rewrite wording as not-on-page, as intended.

## Known Stubs

None (planning artifacts only).

## Next Phase Readiness

Ready for 05-03: it adds `## references/<name>.md` sections for the seven references (making `ledger_files_covered` ok), `## New rules`, `## Owner checklist` and `## Totals`. Note for 05-03: SKILL.md rows already cover `references/shoelace.md:9`, `:11-18`, `:84`, `:90-98`, `references/shadow-dom-styling.md:76-88`, `:205-207`, `:209-213`, `references/responsive-layout.md:195-199`, `references/running-dwc-apps.md:93-94` and `references/themes.md:50` as additional locations; those facts are not repeated there.

## Self-Check: PASSED

Files exist: `ledger_check.py`, `05-LEDGER.md`. Commits `3b67a53`, `ec41f2e` and `2e74cf7` are ancestors of HEAD. The Task 1, 2 and 3 verify commands passed.
