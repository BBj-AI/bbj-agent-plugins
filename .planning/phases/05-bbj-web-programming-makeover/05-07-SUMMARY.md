---
phase: 05-bbj-web-programming-makeover
plan: 07
subsystem: skills
tags: [bbj, dwc, styling, themes, shadow-parts, focus-ring, owner-grants]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: 05-LEDGER.md rows for references/styling.md, owner grants D-22 and D-23, trace_check.py (plan 05-05)
provides:
  - plugins/bbj/skills/bbj-web-programming/references/styling.md (148 lines)
affects: [05-06, 05-10]

actuals:
  tokens: 1855
  tasks: 2
  commits: 2
plan_head_before: bb48cdb654f12d4834b2d0ebb8922f5441ae1a21
plan_head_after: 7d9323eddee31b692b211225a8fc4a752ae0817f

tech-stack:
  added: []
  patterns:
    - "Ledger rows quoted from their cited v26 pages; an owner sentence on one line, verbatim, followed by the maintainer wording (D-07)"

key-files:
  created:
    - plugins/bbj/skills/bbj-web-programming/references/styling.md
  modified: []

key-decisions:
  - "Destination name kept as the ledger default: references/styling.md (the Destinations line names no other file for this group)"
  - "The injectStyle and injectStyleUrl facts of L229 are stated with the object pages' words only; no top, head, body or cascade claim (D-18)"
  - "No ::part(label) rule here: L011 belongs to SKILL.md, so it is stated once, there (WEB-02 adjacency)"

requirements-completed: [WEB-01, WEB-02]

completed: 2026-10-12
---

# Phase 5 Plan 07: styling.md Summary

**One 148-line DWC styling reference: themes, overrides, component theme and expanse, shadow parts and the focus-ring padding rule, each fact quoted from its page or granted by the owner (D-22, D-23).**

## Performance

- Duration: about 10 minutes
- Tasks: 2 (Task 1 tracer, Task 2 auto)
- Commits: c271d09 (themes section), 7d9323e (remaining sections)
- Files: 1 created, nothing else touched (the old themes.md, shadow-dom-styling.md and color-chooser.md stay for plan 05-10)

## Accomplishments

- `## Themes`: setTheme family, DWC only, setDarkTheme and setLightTheme with `setTheme("system")`, `data-app-theme`, and the p11 program.
- `## Overriding a theme`: `:root`, `html[data-app-theme="dark"]`, a custom dark theme with `--dwc-dark-mode: 1` and `color-scheme: dark`, the stylesheet loaded with injectStyle or injectStyleUrl, a pointer to https://docs.webforj.com/docs/styling/ for the token list.
- `## Component theme and expanse`, `## Shadow parts` (with the O5 sentence), `## Focus ring` (the 26.00 upgrade-guide padding with the O6 sentence), `## Sources` last with the Verified line.
- Checks: `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exits 0 with no line for styling.md (gate skills_pending_bbj-web-programming stays ok); `trace_check.py` exits 0 (7 dwc- names traced, 2 grants, 2 rejected claims absent); `sh tests/run.sh` shows no non-fixture FAIL.

## Rule to ledger id map

| Rule in styling.md | Ledger ids | Page |
| ------------------ | ---------- | ---- |
| Themes are DWC only (the object pages' words) | L218 | BBjWebManager_setTheme.htm, setDarkTheme.htm, setLightTheme.htm; dwc.style themes guide |
| Theme names light, dark, dark-pure, system; dark-pure tint "None (pure neutral grays)" | L219 | BBjWebManager_setTheme.htm; dwc.style themes guide |
| Calling setTheme again switches without a rebuild | L220 | dwc.style themes guide |
| p11 program (declared BBjWebManager, setDarkTheme, setLightTheme, setTheme("system")) | L221 (COMPILE) | probes/p11_themes.bbj |
| setDarkTheme and setLightTheme name the theme for each appearance state | L222 | BBjWebManager_setDarkTheme.htm, setLightTheme.htm |
| "system" resolves at runtime and re-resolves with the OS preference | L223 | dwc.style themes guide |
| data-app-theme is light or dark, overrides target those names | L224 | docs.webforj.com themes page; dwc.style themes guide |
| Light overrides in :root, dark in html[data-app-theme="dark"], a new theme under its own data-app-theme block | L225 | dwc.style themes guide; docs.webforj.com themes page |
| Custom dark theme: --dwc-dark-mode: 1 and color-scheme: dark | L228 | dwc.style themes guide; docs.webforj.com themes page |
| Theme stylesheet loaded with injectStyle or injectStyleUrl | L229 | BBjBuiManager_injectStyle.htm, injectStyleUrl.htm; dwc.style themes guide |
| theme attribute values (default, primary, success, warning, danger, info, gray) | L230 | dwc.style themes guide; BBjButton page; probes/p08 |
| expanse scale xs, s, m, l, xl and the icon button range | L231 | dwc.style themes guide; BBjButton page |
| A control has no expanse by default | L232 | dwc.style themes guide; BBjButton page |
| Shadow DOM inner elements are reached with parts; parts are listed per component | L082 | dwc.style css-shadow-parts page; BBjListBox page |
| BBjListBox item HTML is in the shadow root (OWNER, D-22) | L038 | owner checklist O5, owner-repros/o05_listbox_shadow.bbj |
| Focus ring in the docs' words; the padding calc(...) | L072 (and L070 for the term) | docs.webforj.com upgrade guide 26.00 design-system; docs.webforj.com state page |
| Overflow hidden or auto clips the focus ring (OWNER, D-23) | L071 | owner checklist O6, owner-repros/o06_focus_ring.bbj |
| Pointer to the BBjColorChooser component page for its attributes (no rule) | L089, L090, L093 (verdict drop, pointer only) | dwc.style BBjColorChooser page |

## Tokens in the css blocks

| Token or name | Ledger row | Page |
| ------------- | ---------- | ---- |
| --dwc-color-primary-h, --dwc-color-primary-s | L225 (also L207) | https://docs.webforj.com/docs/styling/themes |
| --dwc-color-primary-seed | L225 | https://dwc.style/docs/#/dwc/guide/themes |
| --dwc-dark-mode | L228 | https://dwc.style/docs/#/dwc/guide/themes, https://docs.webforj.com/docs/styling/themes |
| --dwc-focus-ring-width, --dwc-focus-ring-gap | L072, L071 | https://docs.webforj.com/docs/upgrading/webforj-26.00/design-system, https://docs.webforj.com/docs/styling/state |
| dwc-button (selector) | L072 | https://docs.webforj.com/docs/upgrading/webforj-26.00/design-system |

The values in the first css block (215, 100%, #a855f7) are those the docs.webforj.com themes page shows, read on 2026-10-12.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Task 1 verify cannot reach trace_check exit 0 before Task 2**
- **Found during:** Task 1
- **Issue:** Task 1's automated verify requires `trace_check.py` to exit 0, but trace_grants requires the O5 and O6 sentences (rows L038, L071, destination references/styling.md), which the plan places in Task 2 (shadow parts, focus ring).
- **Fix:** none to the content; Task 1 was accepted with trace_tokens and trace_rejected ok and trace_grants failing only for L038 and L071. Task 2's run is the exit-0 check, and it passed.
- **Files modified:** none
- **Commit:** c271d09 (Task 1 as planned)

No other deviations. The ledger named no other destination for this group, so the file is styling.md.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. The file links documentation pages only (no CDN), contains no outline or box-shadow wording, and ships only the two granted owner sentences (T-05-23 to T-05-25 mitigated by trace_tokens, trace_grants and the Task 2 grep).

## Next Phase Readiness

SKILL.md (plan 05-06, wave 7) can index `references/styling.md` and keeps its "Attributes and properties" heading, which styling.md points to. Plan 05-10 deletes themes.md, shadow-dom-styling.md and color-chooser.md and regenerates the baseline.

## Self-Check: PASSED

- plugins/bbj/skills/bbj-web-programming/references/styling.md present (148 lines)
- commits c271d09 and 7d9323e are ancestors of HEAD
