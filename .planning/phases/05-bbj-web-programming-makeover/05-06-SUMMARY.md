---
phase: 05-bbj-web-programming-makeover
plan: 06
subsystem: skills
tags: [bbj, dwc, skill, description, injectStyle-top, should-fail, owner-grants]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: 05-LEDGER.md, owner grants D-19 to D-27 (plan 05-05), references styling.md, form-validation.md, running-dwc-apps.md, shoelace.md (plans 05-07, 05-08), trace_check.py
provides:
  - plugins/bbj/skills/bbj-web-programming/SKILL.md (rewritten; 159 lines after the frontmatter, description 669 characters)
affects: [05-10]

actuals:
  tokens: 3532
  tasks: 2
  commits: 2
plan_head_before: c4ddc8f2fb39fd711f3cc45edeb26621d387dede
plan_head_after: fc273f41be96f4d65ad40957a572502f9c1ec14b

tech-stack:
  added: []
  patterns:
    - "Rules quoted from their cited pages; docs URLs instead of tables; each owner sentence on one line, verbatim, followed by the maintainer wording (D-07); two bbj should-fail blocks each directly followed by their passing block"

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-web-programming/SKILL.md

key-decisions:
  - "The injectStyle top argument is stated as the page sentence only; injectLinkUrl's head (1) or body (0) meaning is named as its own, with its own URL (D-18, WEB-03); no head, body, default, DOM position or cascade claim for injectStyle"
  - "Owner sentences O1, O2, O4, O7, O9 and O10 ship verbatim with 'That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.'; O3 and O8 (rejected) do not appear in any form"
  - "The body is exactly at the line budget (159 of 160): the Page: lines are replaced by inline page URLs inside the first bullet that needs them"

requirements-completed: [WEB-02, WEB-03]

completed: 2026-10-12
---

# Phase 5 Plan 06: SKILL.md Summary

**A 159-line trigger-first bbj-web-programming skill: the check-order block unchanged, the injectStyle `top` meaning quoted from its page, six owner-confirmed rules with the maintainer wording, two real traps (setOuterStyle on a child window, setSlot with the control first) as should-fail pairs, and an index of the four surviving references.**

## Performance

- Tasks: 2 (Task 1 tracer, Task 2 auto)
- Commits: 3723d15 (skeleton, injection section, owner sentences, References index), fc273f4 (rule sections, should-fail pairs, pointers, line budget)
- Files: 1 modified (SKILL.md); no reference file touched; tests/skills_baseline.json untouched (plan 05-10)
- Description: 669 characters (limit 1,024), starts "Write, review, check, or fix", BBj and DWC in the first 200 characters, "Trigger on symptoms" before the bbj-programming pointer
- Body: 159 lines after the closing frontmatter line (limit 160), no Markdown table row

## Checks (all green at fc273f4)

- `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exits 0; no violation line for SKILL.md; `gate skills_pending_bbj-web-programming ok` (the remaining violations belong to the four old references that plan 05-10 deletes)
- `python3 -I tests/test_check_order.py` exits 0 (lines 5-15 are byte-identical to the base commit)
- `trace_check.py` on SKILL.md: tokens ok (5 dwc- names), grants ok (6 grants), rejected ok
- Task 2 verify: eight headings in order, exactly two `bbj should-fail` blocks each directly followed by a `bbj` block, no table, no outline or box-shadow word, no taste word, every named reference path exists, the index equals the Destinations line
- `sh tests/run.sh`: no FAIL line except the intentional fixture lines

## Deviations from Plan

**1. [Rule 3 - Blocking] Plan verify greps fixture output as a failure**
- **Found during:** Task 1 verify
- **Issue:** `grep -q '^gate .* FAIL'` also matches the fixture line `gate skills_fx_structure_linked_skill_dir ok ... wanted a failing line starting 'gate skills_structure_linked FAIL' ...`, which is an `ok` line of an intentional fixture, not a failure.
- **Fix:** The check was run as `grep -E '^gate [^ ]+ FAIL'` (a gate whose status is FAIL). Nothing in the repository changed.

**2. [Ordering] Owner sentences written in Task 1, not Task 2**
- **Found during:** Task 1 verify
- **Issue:** The Task 1 verify ends with `trace_check.py` exiting 0, and `trace_grants` needs every OWNER row of SKILL.md (L005, L013, L021, L022, L028, L097) present verbatim with the maintainer wording.
- **Fix:** The six owner sentences went into the Task 1 commit under the headings "Classes and styles on windows and controls" and "Attributes and properties"; Task 2 added the rest around them.

**3. [Placement] O10 (L097) is in "Attributes and properties", not "Automatic Layout"**
- **Issue:** The plan lists O10 under Automatic Layout "if its destination is SKILL.md". The sentence is about BBjColorChooser client properties, which has no relation to Automatic Layout.
- **Fix:** It sits next to the other BBjColorChooser rule (O9) in "Attributes and properties".

**4. [Block shape] addWindow and chain forms in the blocks**
- To keep the body within 160 lines the blocks without a child window use `win! = BBjAPI().openSysGui("X0").addWindow("My App", $00101093$)`; the blocks with a child window keep a declared BBjSysGui for `getAvailableContext()`. The p02 pair and the p03 pair use `border-radius` instead of the probes' `opacity` (a transparent window is a poor example); both pass bbjcpl -t and bbj-ls, and the two should-fail blocks fail bbjcpl.

## Rule to ledger id map

| Rule in SKILL.md | Ledger ids |
| ---------------- | ---------- |
| getWebManager returns the BBjWebManager (22.03, runtime settings); injectStyle and injectScript sentences | L003, L057 |
| injectStyle top: the page sentence; injectStyleUrl, injectScript, injectScriptUrl share it | L058, L238 |
| injectLinkUrl top: head (1), body (0), head default | L239 |
| Attributes argument of the inject methods | L059 |
| Files under the htdocs directory reached at /files/ | L062 |
| Injection block (injectStyle, injectScriptUrl with type=module, injectLinkUrl) | L064, L058 (probes p09, p13) |
| addClass (BBj 23.00, no effect on GUI), setStyle (BBj 18.00) | L241, L034 |
| addOuterStyle (22) against setOuterStyle (21); the outer-style family | L036, L025 |
| setPanelStyle on the content panel | L240 |
| addClass and addOuterStyle DOM targets (O1, D-19) | L021 |
| dwc-frame in normal flow (O2, D-20) | L028 |
| dwc-window-content and dwc-panel children (O4, D-21) | L022 |
| setOuterStyle on a BBjChildWindow or BBjButton: No match for method (should-fail, p03/p05) with the passing window and child window block (p06, q02) | L035, L027 |
| setAttribute page wording; two channels; setProperty sends JSON | L014, L015 |
| Reflects Yes and Reflects No | L018, L019 |
| Channel order, reading order | L020 |
| Declared control; getProperty to an object variable | L016, L017 (probes p07, p08, p17) |
| label attribute and its three advantages; DWC only, no BUI claim | L007, L008, L012 |
| ::part(label) | L011 |
| HTML text starts with <html> (O7, D-24) | L005 |
| BBjColorChooser label caption (O9, D-25) | L013 |
| BBjColorChooser saturation and lightness (O10, D-26) | L097 |
| Automatic Layout flag, x/y/width/height initialised to 0 | L041, L053 |
| Window composites $00101093$ and $00180013$; child composites $00108800$ and $00109000$ | L048, L049, L050, L051 |
| getAvailableContext | L044 |
| Coordinate-less overloads | L052 |
| GRAVITY in the ARC source | L055 |
| Automatic Layout block (addWindow, two child windows, label attribute) | L046 (probe p10) |
| BBjWebComponent is a BBjControl; setCallback pointer | L075 |
| Declare the variable, no cast on addWebComponent | L076 |
| setSlot(control) default slot | L079 |
| setSlot(slot, control) slot first; control first fails (should-fail, p02) with the passing block (p01) | L080 |
| setSlot only meaningful in the DWC | L242 |
| dwc-icon in the prefix slot; icon pools and CDN | L083, L084 (probe p16) |

Not shipped, by ledger verdict: L001 to L002, L004, L006, L009 to L010, L023 to L024, L026, L029 to L033 (L031 and L032 are the rejected O3 and O8), L037, L042 to L043, L045, L047, L054, L056, L060, L063, L065 to L074, L077 to L078, L085 to L088. No SKILL.md rule is without a ledger row.

## Symptom to ledger id map (description)

| Symptom in the description | Ledger ids |
| -------------------------- | ---------- |
| No match for method ... setSlot | L080 |
| No match for method ... setOuterStyle on a child window | L035 |
| HTML shown as literal text in a control | L005 (O7, D-24) |
| A DWC app opened with bbj instead of a browser URL | L137, L141 (references/running-dwc-apps.md) |

Topic names in the description (not symptoms): injection and top (L058, L238, L239), addClass family (L241, L036, L240), setAttribute versus setProperty and label (L014, L015, L007), Automatic Layout and window flags (L041, L048 to L051), BBjWebComponent and setSlot (L075, L080), DWC themes (references/styling.md), client form validation (references/form-validation.md), registering a DWC app (references/running-dwc-apps.md). The old symptoms about a window's CSS half-applying, an off-centre window, entities, Shoelace icons and a submit button not unlocking the window have no surviving SKILL.md row or are not backed by a confirmed claim, so they are gone (L001).

## Known Stubs

None.

## Threat Flags

None. The blocks inject constant strings only; no admin API, credential or hosted host name appears in SKILL.md (T-05-20 to T-05-22 mitigated).

## Self-Check: PASSED

- plugins/bbj/skills/bbj-web-programming/SKILL.md exists; commits 3723d15 and fc273f4 are ancestors of HEAD
- The plan's `git diff --stat` touches only plugins/bbj/skills/bbj-web-programming/SKILL.md
