# Phase 5 owner checklist: DWC DOM and CSS claims

Status: ready
Prepared: 2026-10-11 (plan 05-04) from 05-LEDGER.md ## Owner checklist

Eleven claims about the DWC page that no documentation page states. Each is a single sentence the
skill would ship only if you confirm it. Nothing is confirmed yet: Claude compiled the repro programs
(`bbjcpl -t -N -X` and `bbj-ls`) and never ran one (04 D-04, 05 D-05).

The rule (D-07): A claim you reject or cannot confirm is dropped, never hedged. A confirmed claim ships only as the exact granted sentence, followed by: the rule the skill maintainer confirmed on BBj <version>; the documentation does not state it.

Nothing beyond the exact sentence is granted. If a claim is nearly right, write the sentence you can
confirm in `granted sentence:` and say why in `note:`; a reworded sentence ships instead of the claim.
Where an item mentions a name that the install's static files contain, that is only the reason the
claim is worded as it is (D-16b), never evidence; the evidence is what you see in the browser.

## How to run the session

One sitting, about 30 minutes, desktop browser with developer tools.

1. Register each program below as a DWC web app with its absolute path, as
   https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm describes
   (the programs are in `.planning/phases/05-bbj-web-programming-makeover/owner-repros/`).
2. Open `http://localhost:8888/webapp/<AppName>` in the browser and open the developer tools
   (Elements, Computed and Console panels).
3. Record the BBj build from BBjServices or the Enterprise Manager, and the DWC build if the browser
   shows one (otherwise write `not shown`), in the `BBj build:` and `DWC build:` lines of every item.
4. Before item O11, copy `owner-repros/o11/main.js` and `owner-repros/o11/dep.js` to
   `<BBjHome>/htdocs/o11/`.
5. Items share programs: O1 to O4 use `o01_window_dom.bbj`, O9 and O10 use `o09_colorchooser.bbj`, so
   there are eight programs for eleven items.
6. Fill `result:` with `confirm`, `reject` or `cannot confirm`. For a confirm, copy the claim (or your
   corrected sentence) into `granted sentence:`. Use `note:` for anything you saw that the sentence does
   not cover. Then reply per item (plan 05-05 records the replies in this file and in the ledger).

## Items

### O1. Which element carries addClass() and addOuterStyle() of a top-level window

claim: addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame.
ledger: L021
repro: owner-repros/o01_window_dom.bbj
look for: Elements panel: find the element that carries the class p5-center and the element that carries p5-frame. Confirm only if the tag of the first is dwc-window-center and the tag of the second is dwc-frame.
result: 
DWC build: 
BBj build: 
granted sentence: 
note: 

### O2. A window frame is in normal flow

claim: dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally.
ledger: L028
repro: owner-repros/o01_window_dom.bbj
look for: Computed panel of the element with class p5-frame: the program injects `top: 120px; left: 120px`. Does the window move (confirm only if it does not, and the Computed position is static or relative)? Then the window with class p5-frame2 (rule `margin: 0 auto`): is it centred horizontally?
result: 
DWC build: 
BBj build: 
granted sentence: 
note: 

### O3. Width and height of a window frame are inline styles

claim: BBj sets width and height on dwc-frame as inline styles, so a stylesheet rule for them needs !important.
ledger: L031
repro: owner-repros/o01_window_dom.bbj
look for: Elements panel: the style attribute of the element with class p5-frame. Does it hold width and height? Confirm only if both are there as inline declarations.
result: 
DWC build: 
BBj build: 
granted sentence: 
note: 

### O4. Where the controls of a window and of a child window go

claim: The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children.
ledger: L022
repro: owner-repros/o01_window_dom.bbj
look for: Elements panel: the parent element of the button "Button on the window" (expect dwc-window-content), and the element that carries class p5-panel together with the parent element of "Button in the child window" (expect dwc-panel and the same element, no wrapper between).
result: 
DWC build: 
BBj build: 
granted sentence: 
note: 
