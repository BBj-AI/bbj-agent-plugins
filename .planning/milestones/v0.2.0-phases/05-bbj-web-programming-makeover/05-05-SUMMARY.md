---
phase: 05-bbj-web-programming-makeover
plan: 05
subsystem: testing
tags: [bbj, dwc, owner-session, owner-grants, trace-check, ledger]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: 05-OWNER-CHECKLIST.md with items O1-O11 and the repro programs (plan 05-04), ledger_check.py and 05-LEDGER.md (plans 05-02, 05-03)
provides:
  - trace_check.py with gates trace_tokens, trace_grants, trace_rejected for the shipped skill files
  - recorded owner session of 2026-10-12 (Status recorded): nine items confirmed, two rejected
  - 05-CONTEXT.md D-19 to D-27, OWNER-confirmed bullets quoting the granted sentences
  - nine OWNER rows in 05-LEDGER.md citing their grants; L031 and L032 stay dropped; Destinations recomputed
affects: [05-06, 05-07, 05-08, 05-09, 05-10]

actuals:
  tokens: 6500
  tasks: 3
  commits: 6
plan_head_before: 52ab892b7d309a5f3ac041c8f2d8ee951293f4db
plan_head_after: 47f7a7425a48b7e3a280cf270514119489cae7b6

tech-stack:
  added: []
  patterns:
    - "A granted sentence is the checklist claim line, copied character for character; the same string sits in the checklist, the D-nn bullet and the OWNER ledger row"
    - "OWNER ledger evidence: 'OWNER: confirmed by <name>, <date>, BBj <ver> (<build>); DWC <build>; grant 05-CONTEXT.md D-<nn>; owner checklist O<n>; owner-repros/<name>.bbj. Earlier note: <the old triage text>'"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/trace_check.py
  modified:
    - .planning/phases/05-bbj-web-programming-makeover/05-OWNER-CHECKLIST.md
    - .planning/phases/05-bbj-web-programming-makeover/05-CONTEXT.md
    - .planning/phases/05-bbj-web-programming-makeover/05-LEDGER.md

key-decisions:
  - "D-19 to D-27: nine owner grants recorded, each exactly the claim sentence of its checklist item, nothing wider"
  - "DWC build recorded as the BBj build (26.03, build 10/06/2026 09:19): the owner stated that DWC always builds into BBj (correction of 2026-10-12, replaces 'not shown')"
  - "O3 and O8 rejected: no D-nn, rows L031 and L032 stay RUNTIME drop with the rejection and date in the evidence; the owner's remarks go to the deferred window sampling idea of 05-CONTEXT.md only"

requirements-completed: [WEB-01]

completed: 2026-10-12
---

# Phase 5 Plan 05: Owner session recorded Summary

**Nine of eleven DWC DOM/CSS claims are OWNER-confirmed by Stephan Wald on BBj 26.03 (D-19 to D-27), two are rejected and dropped, and trace_check.py gates the rewrite against the grants.**

## Performance

- Tasks: 3 (Task 2 was the blocking owner checkpoint, answered by the owner, not an executor commit)
- Session date: 2026-10-12
- Build data as the owner pasted it: Server BBj Version REV 26.03, Server Build 10/06/2026 09:19, Client BBj Version REV 26.03, Client Build 10/06/2026 09:19
- DWC build: the owner stated "DWC always builds into BBj, so it's that build version"; recorded everywhere as "26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)"

## Accomplishments

- trace_check.py (commit 789f675): gates trace_tokens, trace_grants, trace_rejected, reading files only.
- The owner's outcomes are recorded once, in the checklist (Status: recorded, Session line), in 05-CONTEXT.md under "### Owner confirmation (owner session, plan 05-05, 2026-10-12)" and in the ledger (commit 47f7a74).
- The ledger is consistent: ledger_check.py exits 0 (ledger_owner: 9 OWNER rows; ledger_owner_items ok), checklist_check.py --recorded exits 0, probes/run.py --check exits 0, tests/test_never_execute.sh exits 0. Confirmed results, bullets and distinct ledger grants are 9, 9 and 9.

## Owner reply and outcome per item

The owner's words, as given to the continuation (paraphrased only where the owner pasted DOM or console output):

| Item | Outcome | Granted | Ledger | Owner's remarks recorded in `note:` |
| ---- | ------- | ------- | ------ | ----------------------------------- |
| O1 | confirm, "as written" | D-19 | L021 | DOM showed p5-center on dwc-window-center and p5-frame on dwc-frame |
| O2 | confirm, "as written" | D-20 | L028 | top/left had no effect, margin auto centered horizontally; "not exactly" referred to vertical only |
| O3 | reject | none | L031 stays drop | console: `.p5-frame` style attribute null; `.p5-center` style `position: relative; inset: 0px; resize: both; min-width: 95px;`; an earlier run had width/height on dwc-window-center; sizing a BBjTopLevelWindow belongs to the API, not CSS (deferred idea only, owner chose "leave it out") |
| O4 | confirm, "as written" | D-21 | L022 | none |
| O5 | confirm, "as written" ("O5 accept") | D-22 | L038 | second item renders italic (browser default em inside the shadow root; the page's em color rule did not reach it); DOM showed the three items in the dwc-listbox shadow root |
| O6 | confirm, "as written" ("O6 accept") | D-23 | L071 | none |
| O7 | confirm, "as written" ("O7 confirm") | D-24 | L005 | none |
| O8 | reject | none | L032 stays drop | getters return correct numbers on an Automatic Layout window and update on move/resize (variant with ON_RESIZE and ON_WINDOW_MOVE); the old claim may have meant controls within a dynamic layout; revisit in the separate sampling effort |
| O9 | confirm, "as written" ("O9 and O10 accepted") | D-25 | L013 | none |
| O10 | confirm, "as written" | D-26 | L097 | none |
| O11 | confirm, "as written" ("O11 passes okay") | D-27 | L061 | none |

Each granted sentence is the item's `claim:` line from 05-OWNER-CHECKLIST.md, copied by script (not retyped); a check after the commit confirmed that the quoted sentence of every D-nn bullet occurs verbatim as the `granted sentence:` line of its checklist item. Destinations if shipped: O1, O2, O4, O7, O9, O10 to SKILL.md; O5, O6 to references/styling.md; O11 to references/shoelace.md.

## Final Totals (05-LEDGER.md)

```
Rows: 242 rows: DOC 106, COMPILE 12, RUNTIME 115, OWNER 9; keep 46, rewrite 44, drop 150, fold 2
Destinations: SKILL.md (49), references/styling.md (17), references/form-validation.md (11), references/running-dwc-apps.md (10), references/shoelace.md (5)
Deleted in plan 05-10: references/color-chooser.md, references/responsive-layout.md, references/shadow-dom-styling.md, references/themes.md
```

Owner items do not count toward the three-rule floor of a destination reference (D-09), so no destination was folded and the Deleted line is unchanged. The commentary under Totals was updated to say the owner confirmed O5 and O6 and rejected O3 and O8.

## Task 1 rehearsal (tracer)

The Task 1 commit (789f675) was made before this continuation and its rehearsal numbers were not handed over. The four outcomes were therefore reproduced in the session scratchpad against the recorded state, with scratch skill files only (nothing in the repository was touched):

1. ledger_owner and ledger_owner_items: ok on the real recorded ledger and context (9 OWNER rows).
2. trace_grants with a scratch SKILL.md that holds the O7 sentence and the maintainer wording: no failure for L005; it still fails for the other eight grants whose sentences that scratch file does not hold (expected).
3. trace_grants without the sentence: FAIL for L005 (sentence, "the skill maintainer confirmed", "the documentation does not state it" missing).
4. trace_tokens FAIL on an untraced `dwc-not-in-ledger`; trace_rejected FAIL when the O3 claim sentence is in the file; plain text passes trace_tokens and trace_rejected.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Stale text in the recorded files**
- **Found during:** Task 3
- **Issue:** the checklist intro still said "Nothing is confirmed yet", and the 05-LEDGER.md Totals commentary still said "If the owner rejects O5 or O6 ...".
- **Fix:** both sentences reworded to the recorded state.
- **Files modified:** 05-OWNER-CHECKLIST.md, 05-LEDGER.md
- **Commit:** 47f7a74

**2. Correction from the coordinator (owner statement)**: the DWC build was first handed over as "not shown"; the owner corrected it to the BBj build before anything was written, so "not shown" appears nowhere in the recorded fields.

### Notes

- The new subsection is placed directly before "### Claude's Discretion", after the existing "### Owner request during the owner session (2026-10-12)" (D-18a). D-18a was not renumbered and is not an OWNER bullet.
- The earlier ledger triage text of each confirmed row is kept after "Earlier note:" in its OWNER evidence cell (including the documentation conflict of L097 for the docs proposal, D-08).
- The `commits: 6` count is measured from the ledger: two plan commits (789f675 trace_check.py; 47f7a74 recording) plus four orchestrator commits during the session (61d2c06 O1 repro fix, 1fed523 D-18a, 85f75dd and d8afaa8 deferred window sampling idea).

## Issues Encountered

None blocking. The O1 repro needed the context fix (61d2c06) the owner's run exposed; the program compiles clean on both routes and OUTPUT.txt reproduces.

## Known Stubs

None.

## Threat Flags

None. Only planning files and one Python checker changed; nothing under plugins/, tests/ or codex/ changed.

## Next Phase Readiness

Plans 05-06 to 05-08 can start: the grant set is fixed (D-19 to D-27). Each shipped OWNER sentence must appear verbatim with "the skill maintainer confirmed" and "the documentation does not state it" (trace_grants). The nine OWNER claims also belong in 05-DOCS-PROPOSAL.md as documentation gaps (D-08), plus the context-in-use entry (D-18a), via plan 05-09.

## Self-Check: PASSED

- trace_check.py, 05-OWNER-CHECKLIST.md (Status: recorded), 05-CONTEXT.md D-19 to D-27 and 05-LEDGER.md present
- commits 789f675 and 47f7a74 are ancestors of HEAD
