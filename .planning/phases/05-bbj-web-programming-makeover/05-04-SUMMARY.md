---
phase: 05-bbj-web-programming-makeover
plan: 04
subsystem: testing
tags: [bbj, dwc, owner-checklist, owner-repros, checklist-check, compile-only]

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: the Owner checklist triage O1-O11 with row ids (plan 05-03), probes/run.py and OUTPUT.txt (plan 05-01)
provides:
  - 05-OWNER-CHECKLIST.md with the eleven items O1-O11, status ready, every result field empty
  - eight owner repro programs plus two JavaScript files for O11, all clean on bbjcpl and bbj-ls in probes/OUTPUT.txt
  - probes/run.py compiling ../owner-repros/*.bbj in the same batch
  - checklist_check.py with gates checklist_items, fields, repro, ledger and (with --recorded) recorded
affects: [05-05]

actuals:
  tokens: 10570
  tasks: 2
  commits: 2
plan_head_before: d84bd314ebfa36d75ebbf860fe451dc9c589101c
plan_head_after: 4f36c74f90507d0efa7f908ff0c8a5c91d8c569c

tech-stack:
  added: []
  patterns:
    - "Owner repros are minimal complete programs: declared objects, same-line rem comments, constant CSS or script text only, ending in process_events and release"
    - "A checklist item and its '- O<n>: ' ledger line carry the identical claim sentence; checklist_check.py compares them"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/05-OWNER-CHECKLIST.md
    - .planning/phases/05-bbj-web-programming-makeover/checklist_check.py
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o01_window_dom.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o05_listbox_shadow.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o06_focus_ring.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o07_html_text.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o08_autolayout_geometry.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o09_colorchooser.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o11_module_inline.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o11_module_url.bbj
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o11/main.js
    - .planning/phases/05-bbj-web-programming-makeover/owner-repros/o11/dep.js
  modified:
    - .planning/phases/05-bbj-web-programming-makeover/probes/run.py
    - .planning/phases/05-bbj-web-programming-makeover/probes/OUTPUT.txt
    - .planning/phases/05-bbj-web-programming-makeover/05-LEDGER.md

key-decisions:
  - "O6 asks two things in the docs' term focus ring: clipping by an overflow hidden or auto ancestor, and whether padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) avoids it; neither the claim nor the look-for step names outline or box-shadow (D-15)"
  - "O5 to O11 and O1 to O4 keep the ledger claim sentences unchanged; only O6 was widened, and its ledger line was changed in step"
  - "checklist_check.py gates checklist_recorded only with --recorded; the granted sentence is required for a confirm, not forbidden for reject (plan 05-05 may refine)"

patterns-established:
  - "run.py sections for owner repros are headed '== owner-repros/<name>.bbj' and come after all probe sections; a name collision with a probe or canary is exit 2"

requirements-completed: [WEB-01]

duration: about 40 min
completed: 2026-10-11
status: complete
---

# Phase 5 Plan 04: Owner checklist and repro programs Summary

**Eleven DWC DOM and CSS claims now have a one-sitting owner checklist: each item has the exact claim sentence, ledger row ids, a repro program clean on bbjcpl and bbj-ls, a devtools step and empty result fields, and checklist_check.py keeps claims and ledger lines identical.**

## Performance

- **Duration:** about 40 min
- **Tasks:** 2 (one tracer, one auto)
- **Files:** 12 created, 3 modified; no shipped file changed (`git status --porcelain -- plugins tests codex` prints nothing); `sh tests/test_never_execute.sh` exits 0

## Task Commits

1. **Task 1 (tracer): run.py compiles owner-repros, o01 repro, checklist header and O1-O4, checklist_check.py** - `b563a45` (feat). Tracer verify re-run end to end: probes reproduce, o01 clean on both routes, `checklist_fields`, `checklist_repro`, `checklist_ledger` ok, `checklist_items` FAIL naming O5-O11 (the expected open state), `ledger_check.py` ok. Logged: tracer verified end to end, expanding.
2. **Task 2: items O5-O11, repro programs O5-O9 and O11, O6 ledger line** - `4f36c74` (feat)

## Final state

- `python3 -I probes/run.py --check`: `gate probes_reproduce ok 29 probes` (21 probes, 8 owner repros)
- `python3 -I checklist_check.py`: `checklist_items` ok (11 items O1 to O11 in order), `checklist_fields` ok, `checklist_repro` ok (12 repro paths), `checklist_ledger` ok
- `python3 -I checklist_check.py --recorded` correctly FAILs now (every result empty); mutation checks: a changed claim fails `checklist_ledger`; a confirm without builds or granted sentence fails `checklist_recorded`
- `python3 -I ledger_check.py`: every gate ok

## The eleven claim sentences as they stand in the checklist

| Item | Claim | Rows | Repro |
|------|-------|------|-------|
| O1 | addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame. | L021 | o01_window_dom |
| O2 | dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally. | L028 | o01_window_dom |
| O3 | BBj sets width and height on dwc-frame as inline styles, so a stylesheet rule for them needs !important. | L031 | o01_window_dom |
| O4 | The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children. | L022 | o01_window_dom |
| O5 | The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline style attribute does. | L038 | o05_listbox_shadow |
| O6 | An ancestor with overflow hidden or overflow auto clips the focus ring of a control, and padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it. | L071 | o06_focus_ring |
| O7 | HTML text in a control must start with <html> or it shows as literal text. | L005 | o07_html_text |
| O8 | getX(), getY(), getWidth() and getHeight() return null on an Automatic Layout window. | L032 | o08_autolayout_geometry |
| O9 | A BBjColorChooser shows no caption for setAttribute("label", ...). | L013 | o09_colorchooser |
| O10 | getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0. | L097 | o09_colorchooser |
| O11 | An ES module injected inline with injectScript() cannot load its relative imports, while the same module loaded with injectScriptUrl(url, top, "type=module") can. | L061 | o11_module_inline, o11_module_url |

**Wording changed from the ledger draft:** only O6. The ledger draft stated the clipping only; D-15 has the owner check both the clipping and that the documented padding avoids it, so the second half was added to the claim and to the `- O6: ` line of 05-LEDGER.md together (the row L071 is unchanged; the padding rule itself is the DOC row L072). The other ten sentences are identical to the ledger.

## Repro design notes

- All programs open windows, inject constant CSS or script text and show values in their own controls. None writes a file, contacts another host or holds a credential (grep of the Task 2 verify). Compile only: `-t -N -X` and loopback bbj-ls; no program was started.
- o08 uses `err=` branches with labels: a `try`/`catch` block does not compile in main-program code (bbjcpl: "error at line 7: try"), so the error text of each call is shown through `str(err)` and `errmes(-1)`.
- o05 uses `addListBox("")`: the coordinate-less `addListBox()` does not exist (bbjcpl type check: no match); the javadoc JSON of the install lists `addListBox(String)`.
- o09 holds the main code before the class, which compiles clean on both routes.
- O11 loads from `/files/o11/main.js`; the owner copies `owner-repros/o11/*.js` to `<BBjHome>/htdocs/o11/` (stated in the session section and in the O11 look-for step).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 2 automated verify cannot pass as written**
- **Found during:** Task 2
- **Issue:** the chain contains `! awk '/^### O6\. /...{...} END{exit e}'`. The awk exits 0 when it finds no outline or box-shadow in the O6 claim or look-for lines (the intended good case) and 1 when it finds one, so the `!` makes the chain fail exactly when O6 is correct.
- **Fix:** ran the verify with the `!` removed from that one guard and checked it with a mutation (an O6 claim containing "an outline" makes the awk exit 1). Every other clause ran unchanged and passes. No plan file was edited.
- **Verification:** the fixed chain exits 0; the mutation exits 1.

**2. [Rule 3 - Blocking] BBj API shapes in the plan's program descriptions**
- **Found during:** Task 2
- **Issue:** `addListBox()` without arguments and `try`/`catch` in main-program code do not compile (see Repro design notes).
- **Fix:** `addListBox("")` and `err=` branches; both programs now clean on both routes.
- **Commit:** 4f36c74

**Total deviations:** 2 auto-fixed. **Impact:** none on scope; no shipped file changed.

## Issues Encountered

None blocking. The bbj-docs MCP tools are not exposed to this agent (as in plans 05-02 and 05-03); the API shapes were taken from the install's javadoc JSON under `/opt/bbx/documentation/javadoc`, the fetched pages in the session scratchpad and the compiler itself.

## Known Stubs

None (planning artifacts and repro programs only).

## Threat Flags

None. T-05-12: nothing was run; run.py starts only `bbjcpl -t -N -X`. T-05-13: no repro writes, deletes or calls system; the o01 grep for those verbs and the all-repro grep are empty. T-05-14: no credential-looking string in a repro, no absolute URL in the two JavaScript files. T-05-15: claim and ledger line are identical for all eleven items (`checklist_ledger`), and no result, build or granted-sentence field is filled; nothing is marked confirmed by Claude (D-16b).

## Next Phase Readiness

Ready for 05-05: the blocking owner checkpoint can present `05-OWNER-CHECKLIST.md` (Status: ready). After the owner replies, 05-05 fills `result:`, `DWC build:`, `BBj build:`, `granted sentence:` and `note:`, sets `Status: recorded`, runs `checklist_check.py --recorded` and recomputes the ledger Destinations and Deleted lines.

## Self-Check: PASSED

Files exist: the checklist, `checklist_check.py`, the eight repro programs and both JavaScript files. Commits `b563a45` and `4f36c74` are ancestors of HEAD. The Task 1 verify passed as written; the Task 2 verify passed with the one corrected guard (Deviation 1); `ledger_check.py`, `run.py --check` and `checklist_check.py` exit 0.
