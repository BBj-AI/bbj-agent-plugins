---
phase: 05-bbj-web-programming-makeover
plan: 09
subsystem: docs-proposal
tags: [bbj, dwc, docs-proposal, owner-grants, injectStyle-top]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: 05-LEDGER.md (nine OWNER rows), owner grants D-19 to D-27 and D-18a (plan 05-05), probes p03 to p09
provides:
  - .planning/phases/05-bbj-web-programming-makeover/05-DOCS-PROPOSAL.md (not shipped)
affects: [05-10]

actuals:
  tokens: 9981
  tasks: 2
  commits: 2
plan_head_before: 47524c3e2f0665b718a5f4e8b95d3a93dbb39b37
plan_head_after: 1119ee809a061c64370d675ee8cef5eae7406689

tech-stack:
  added: []
  patterns:
    - "Docs proposal entries carry the fields Page, Says today, Lacks, Evidence, Request and a suggested-wording blockquote; OWNER entries quote the granted sentence verbatim with D-nn, confirmer, date and builds"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/05-DOCS-PROPOSAL.md
  modified: []

key-decisions:
  - "Suggested wording for open questions uses bracketed slots for the owners to fill; this repository states no fact it did not get from a page, a probe or an owner grant"
  - "Rejected owner items O3 and O8 appear only as dropped candidates with the owner's observation labelled as one session's note, never as a rule"

requirements-completed: [WEB-01, WEB-03]

completed: 2026-10-12
---

# Phase 5 Plan 09: Docs proposal for the BASIS documentation owners Summary

**05-DOCS-PROPOSAL.md lists the injectStyle `top` wording gap first, then the DWC window DOM names, every OWNER claim (nine, with D-19 to D-27), two page conflicts, seven dropped candidates (including the context-in-use report of D-18a) and the docs-server notes; it is a planning document, nothing was edited or sent.**

## Performance

- Tasks: 2 (Task 1 tracer, Task 2 auto)
- Commits: 9815d9a (header, evidence rules, top-argument entry), 1119ee8 (remaining sections)
- Files: 1 created (39,924 bytes); `git status --porcelain -- plugins tests codex` shows no change
- Duration: about 5 minutes of execution after the research reading

## What the proposal holds

Last line of the file: `Entries per section: top argument of the inject methods 1 (T1); DWC window structure and styling hooks 2 (W1, W2); owner-confirmed behaviour 9 (L005, L013, L021, L022, L028, L038, L061, L071, L097); conflicts between pages 2 (C1, C2); rules dropped for lack of a source 7 (R1 to R7) plus 11 smaller candidates; notes for the docs server 4.`

| Section | Entries | Content |
| --- | --- | --- |
| The top argument of the inject methods | T1 | The four "top level window of the page" sentences (injectStyle, injectStyleUrl, injectScript, injectScriptUrl) and injectLinkUrl's head/body meaning, quoted from the page files; what injectStyle lacks; ledger rows L058, L100, L208, L238, L239; probe p09 (`1` and `0` accepted, bbjcpl and bbj-ls clean) |
| DWC window structure and styling hooks | W1, W2 | Element names no page states (dwc-frame, dwc-window-center, dwc-window-content, dwc-panel) with open questions marked as such; setOuterStyle scope on BBjTopLevelWindow only (probes p03 to p05 compile errors, bbj-ls clean) |
| Owner-confirmed behaviour | nine | One entry per OWNER row with the granted sentence verbatim (checked by script against 05-CONTEXT.md), D-19 to D-27, Stephan Wald, 2026-10-12, BBj 26.03 and DWC 26.03 (build 10/06/2026 09:19), the owner repro |
| Conflicts between pages | C1, C2 | dwc.style attributes guide ("no-ops") versus BBjControl_setAttribute.htm; BBjColorChooser saturation "0 to 100" versus the granted fraction from 0 to 1.0 (O10), without claiming the page is wrong |
| Rules dropped for lack of a source | R1 to R7 + table | O3 (L031) and O8 (L032) as rejected; stable id replacement (L065); `bbj` launch and ThinClient (L139, L140); the "--" config sentinel (L155); duplicate createApplication (L146); the context-in-use report (L045, D-18a, not an OWNER grant, nothing shipped in the skill); 11 smaller ledger rows |
| Notes for the docs server | 4 | Old skill text served as documentation, results labelled "not a citable page", primer paragraph gotchas/20 citing a page that lacks the `&&` rule (L006), install static files used for triage only (D-16b) |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan named ledger row L001 as the top-wording evidence**
- **Found during:** Task 1
- **Issue:** L001 of 05-LEDGER.md is the row of the old frontmatter description (the symptom list). The `top` claim itself sits in L058 (SKILL.md:234-235), L100 (color-chooser.md:37), L208 (themes.md:29), and the new rules L238 and L239. The plan's verify requires the string `L001` in the file.
- **Fix:** T1 cites the real rows first and cites L001 for what it is (the old description advertising "a window's CSS not applying or only half-applying"), without claiming it carries the `top` claim.
- **Files modified:** 05-DOCS-PROPOSAL.md
- **Commit:** 9815d9a

### Judgment calls inside the plan

- Entry ids: the plan fixes sections, not ids. Dropped-rule entries are R1 to R7 so they do not collide with decision ids D-nn.
- Suggested-wording blockquotes for open questions use bracketed owner-fill slots. They are requests, not claims; no placeholder is in a shipped file.
- Task 1 verify was re-run after the tracer commit (auto mode active): it passed, tracer verified end to end, expansion continued.

## Auth gates

None.

## Known Stubs

None in shipped files. The bracketed `<...>` slots in the suggested wording of 05-DOCS-PROPOSAL.md are intentional: they are the questions to the documentation owners. The file is not shipped.

## Threat Flags

None. Only a planning document was added; T-05-29 is mitigated (every OWNER entry quotes the granted sentence, names D-nn, confirmer, date and builds; the verify ties every OWNER row and grant to an entry; rejected items O3 and O8 are presented only as rejected), T-05-30 accepted (Status line says not shipped and nothing was sent).

## Self-Check: PASSED

- 05-DOCS-PROPOSAL.md exists; both task verifies exit 0; all nine granted sentences occur verbatim; the last line starts with `Entries per section: `
- commits 9815d9a and 1119ee8 are ancestors of HEAD
- `git status --porcelain -- plugins tests codex` is empty
