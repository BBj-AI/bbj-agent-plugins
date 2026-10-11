---
phase: 04-bbj-programming-makeover
plan: 04
subsystem: docs
tags: [docs-proposal, str-function, claim-ledger, owner-confirmed, bbjcpl, bbj-ls]

requires:
  - phase: 04-bbj-programming-makeover
    provides: "plan 04-02: 04-LEDGER.md (COMPILE keep/rewrite rows, the two OWNER rows L031 and L072, the dropped no-source rules) and plan 04-01 probes/OUTPUT.txt"
provides:
  - "04-DOCS-PROPOSAL.md: the laundry list for the BASIS documentation owners, STR() chapter first (S1-S5), then every COMPILE-only gap, both OWNER amendments, the dropped no-source rules and the primer / docs-server hand-off"
affects: [04-05, 04-06, phase-05-bbj-web-programming]

actuals:
  tokens: 9000
  tasks: 2
  commits: 2

plan_head_before: 240bb613287901d042698a39677155c369b60a33
plan_head_after: dbeed656d56de6602ec9c1b005cae5b7115da7fa

tech-stack:
  added: []
  patterns: ["proposal entry shape: page URL, quoted page sentence, what is missing, suggested wording, evidence (ledger id, probe, OUTPUT.txt line)"]

key-files:
  created:
    - .planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md
  modified: []

key-decisions:
  - "The printed result of the sign-trap example is left for the docs owners to fill from a real run: the owner confirmed the trap, this repository never ran BBj, so the proposal states the confirmed fact and no output text"
  - "The raw page files were re-read on 2026-10-11 and every quote was checked against them; the 'RETURN TYPE: String' line seen through the docs server is reported as server rendering, not as page text"
  - "L006 (DECLARE AUTO rejects an interface type, verdict drop) and L101 / L147 (USE) are listed as related entries because the plan names the DECLARE and USE gaps although their rows are not on the Kept-on-COMPILE list"

patterns-established:
  - "OWNER claims are always written 'confirmed by Stephan Wald, 2026-10-11, BBj 26.03' with the ledger id and the grant (D-21, D-22, D-23), and never as probe evidence"

requirements-completed: [PROG-01]

coverage:
  - id: D1
    description: "STR() chapter first: sign trap (OWNER L031), primitive-string return, CVS trim idiom, stale primer example, each with URL, quoted sentence, gap and suggested wording"
    requirement: PROG-01
    verification:
      - kind: other
        ref: "Task 1 automated verify (04-04-PLAN.md): STR() is the first ## heading, the page URLs, the owner confirmation line, probes/t12, probes/t13, two_string_worlds/10 and the OWNER id L031 are present"
        status: pass
    human_judgment: true
    rationale: "Whether the suggested wording is right for the documentation is for the BASIS documentation owners to judge; the automated check proves structure and evidence references only"
  - id: D2
    description: "All 18 COMPILE keep/rewrite ledger ids, both OWNER ids (L031, L072), the dropped no-source rules and the docs-server hand-off appear in the four sections after the STR() chapter, in the required order"
    requirement: PROG-01
    verification:
      - kind: other
        ref: "Task 2 automated verify (04-04-PLAN.md): every id of the ledger Totals list found in the proposal, two OWNER rows, section order, 'not a citable page', _error_26.htm, bbjcpl_bbj_compiler.htm, running_from_the_command_line.htm, -tIO"
        status: pass
    human_judgment: false

duration: 9min
completed: 2026-10-11
status: complete
---

# Phase 4 Plan 04: Documentation improvement proposal Summary

**A 540-line proposal for the BASIS documentation owners that opens with the STR() chapter (sign trap confirmed by the project owner, primitive-string return, CVS trim idiom, stale primer example) and lists every rule the ledger kept only on compile evidence, both owner-confirmed behaviours and the rules dropped for lack of a source.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-11T08:55:11Z (recorded at the first command; reading started a few minutes earlier)
- **Completed:** 2026-10-11T09:03:00Z
- **Tasks:** 2
- **Files modified:** 1 (the new proposal only)

## Accomplishments

- STR() chapter (5 entries, S1-S5): the sign trap in two entries (S1 on the STR() page, S2 on the Numeric Output page) stated as "confirmed by Stephan Wald, 2026-10-11, BBj 26.03" with its OWNER id L031 and a request to amend, plus a "Notes for Agents" version with an example that passes `bbjcpl -t -N -X`; the primitive-string return (probe t12 fails on both routes, t14 cast is clean); the `CVS(STR(n:mask),3)` trim idiom (probe t13); the stale `two_string_worlds/10` example against the BBj page's `01 23`.
- Rules kept on compile evidence (21 entries in 7 page groups): the 18 ids of the ledger list (L010 L011 L012 L014 L015 L016 L018 L060 L064 L086 L118 L143 L144 L145 L146 L148 L149 L150) plus related L006, L101, L147, each with page URL, probe, OUTPUT.txt line and suggested wording, grouped under the bbjcpl, !ERROR=26, USE, statements/REM, DECLARE, SysGui and BBjFormValidationEvent pages.
- Owner-confirmed behaviour (2 entries): L031 (pointing to S1/S2) and L072 `bbj -tIO` sends print output to stdout, with the missing command-line page row, the PRO/5 IO pages as supporting citations only, and one suggested sentence.
- Rules dropped for lack of a source (5 groups plus 6 smaller rows): context reuse per window (L114), TOP and the LIMIT page (L095, L096), the lower-case SQL function (L092), the round-trip cost (L079 and its dependants), launcher behaviours with no page.
- Notes for the primer and the docs server (3 entries): the eight skill-derived primer paragraphs with the probe that now supports each, the stale S5 example, and the old skill text served as results labelled "not a citable page" and appended to official pages.

## Task Commits

1. **Task 1: header, evidence rules and the STR() chapter (tracer)** - `49e2b52` (docs)
2. **Task 2: compile-evidence gaps, owner-confirmed items, dropped rules, docs-server notes** - `dbeed65` (docs)

The Task 1 tracer's `<verify>` carries only an automated command; it passed before expansion (tracer verified end to end, then expanded).

**Plan metadata:** committed with this SUMMARY (docs: complete plan).

## Files Created/Modified

- `.planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md` - the proposal; the only file the plan's commits change (`git show --stat` of 49e2b52 and dbeed65 lists nothing else)

## Decisions Made

- The sign-trap printed output is left blank for the owners (two-row table "to be filled from a real run"). The owner confirmed the behaviour, not a result string, and this repository never runs BBj.
- Quotes were taken from the raw page files fetched on 2026-10-11 and checked by a script against the normalised page text; one candidate quote (accept() "fires a BBjButtonPushEvent") did not match the raw page and was left out.
- The "RETURN TYPE: String" line is reported only as what the docs server renders, because the page file does not contain it.
- Ids L006, L101, L147 are included as related entries (see key-decisions).

## Deviations from Plan

None - plan executed exactly as written.

Two small notes that are not deviations: the proposal quotes the pages directly (re-fetched, HTTP 200 for every page fetched) rather than relying on the ledger's copies, and it adds a short "smaller candidates" table of dropped runtime rows (L004, L056, L065/L137, L009, L119, L135) beyond the five groups the plan names.

**Total deviations:** 0.
**Impact on plan:** none.

## Issues Encountered

- A first run of the Task 2 verify command printed no pass line: the required phrase `not a citable page` was wrapped across two lines. Re-wrapped the sentence; the verify then passed. No effect on content.

## Known Stubs

None. The two "to be filled from a real run" cells in S1 are intentional and explained: the owners are asked to supply the printed results.

## Threat Flags

None. The plan writes one planning document; no network endpoint, auth path or file access was added.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for plans 04-05 and 04-06 (the remaining Phase 4 plans). The proposal is independent of them.
- The proposal is a repository planning file only; handing it to the BASIS documentation owners is the user's step.

## Self-Check: PASSED

- FOUND: .planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md
- FOUND: commit 49e2b52
- FOUND: commit dbeed65
- Both task verify commands re-run after the last edit: pass; `sh tests/run.sh`: ok=703 fail=0 skip=105

---
*Phase: 04-bbj-programming-makeover*
*Completed: 2026-10-11*
