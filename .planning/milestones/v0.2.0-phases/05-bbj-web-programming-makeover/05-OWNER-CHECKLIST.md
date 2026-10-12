# Phase 5 owner checklist: DWC DOM and CSS claims

Status: recorded
Session: 2026-10-12, owner Stephan Wald; BBj 26.03 (server and client REV 26.03, build 10/06/2026 09:19); DWC ships inside BBj, so its build is the BBj build (owner statement)
Prepared: 2026-10-11 (plan 05-04) from 05-LEDGER.md ## Owner checklist

Eleven claims about the DWC page that no documentation page states. Each is a single sentence the
skill would ship only if you confirm it. The owner session of 2026-10-12 is recorded below (plan 05-05).
Before it nothing was confirmed: Claude compiled the repro programs (`bbjcpl -t -N -X` and `bbj-ls`) and
never ran one (04 D-04, 05 D-05).

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
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame.
note: DOM pasted by the owner showed p5-center on dwc-window-center and p5-frame on dwc-frame. Creating the second top-level window needed sysgui!.setContext(sysgui!.getAvailableContext()) first (D-18a, docs proposal only).

### O2. A window frame is in normal flow

claim: dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally.
ledger: L028
repro: owner-repros/o01_window_dom.bbj
look for: Computed panel of the element with class p5-frame: the program injects `top: 120px; left: 120px`. Does the window move (confirm only if it does not, and the Computed position is static or relative)? Then the window with class p5-frame2 (rule `margin: 0 auto`): is it centred horizontally?
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally.
note: Top and left had no effect and margin auto centered horizontally; the owner's 'not exactly' referred to vertical centering only, which the sentence does not claim.

### O3. Width and height of a window frame are inline styles

claim: BBj sets width and height on dwc-frame as inline styles, so a stylesheet rule for them needs !important.
ledger: L031
repro: owner-repros/o01_window_dom.bbj
look for: Elements panel: the style attribute of the element with class p5-frame. Does it hold width and height? Confirm only if both are there as inline declarations.
result: reject
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence:
note: Rejected. The console showed document.querySelector('.p5-frame').getAttribute('style') = null and the .p5-center style = 'position: relative; inset: 0px; resize: both; min-width: 95px;' (an earlier run had width: 348px; height: 187px on dwc-window-center, not on dwc-frame). Owner: sizing a BBjTopLevelWindow is done with the API, not CSS; recorded as a deferred idea only (owner chose 'leave it out', not a grant), see 05-CONTEXT.md deferred ideas.

### O4. Where the controls of a window and of a child window go

claim: The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children.
ledger: L022
repro: owner-repros/o01_window_dom.bbj
look for: Elements panel: the parent element of the button "Button on the window" (expect dwc-window-content), and the element that carries class p5-panel together with the parent element of "Button in the child window" (expect dwc-panel and the same element, no wrapper between).
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children.
note: none

### O5. Where the HTML of a list box item renders

claim: The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline style attribute does.
ledger: L038
repro: owner-repros/o05_listbox_shadow.bbj
look for: On screen: the program injects `.p5-item { color: red; }` and `em { color: blue; }`. Which items are coloured? Expected for the claim: item 1 (class) and item 2 (bare tag) keep the default colour, item 3 (inline style) is green. Elements panel: find the item HTML under `#shadow-root` of the list box element; confirm only if the three items are inside the shadow root.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline style attribute does.
note: Owner: 'O5 accept'. The second item renders italic, which is the browser's default em style inside the shadow root; the page's em color rule did not reach it. DOM showed the three items inside the dwc-listbox shadow root.

### O6. Focus ring clipped by an overflow ancestor

claim: An ancestor with overflow hidden or overflow auto clips the focus ring of a control, and padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it.
ledger: L071
repro: owner-repros/o06_focus_ring.bbj
look for: Click the page background, then press Tab until the left edit box has the focus, then the right one. Is the focus ring cut off at the edge of the left child window (overflow hidden, no padding) and whole around the right one (overflow hidden, padding calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)))? Confirm both halves only if the left ring is cut and the right is whole; if both are whole or both are cut, reject.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: An ancestor with overflow hidden or overflow auto clips the focus ring of a control, and padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it.
note: Owner: 'O6 accept'.

### O7. HTML text needs the html tag

claim: HTML text in a control must start with <html> or it shows as literal text.
ledger: L005
repro: owner-repros/o07_html_text.bbj
look for: On screen: the first static text is `<html><b>bold</b></html>`, the second `<b>bold</b>`. Confirm only if the first shows the word in bold and the second shows the characters `<b>bold</b>` as literal text.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: HTML text in a control must start with <html> or it shows as literal text.
note: Owner: 'O7 confirm'.

### O8. Geometry of an Automatic Layout window

claim: getX(), getY(), getWidth() and getHeight() return null on an Automatic Layout window.
ledger: L032
repro: owner-repros/o08_autolayout_geometry.bbj
look for: On screen: four lines, one per call. Confirm only if all four read `: null`. A number or an error text on any line means reject; write the four lines into `note:`.
result: reject
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence:
note: Rejected. The getters report position and sizes correctly as numbers on an Automatic Layout window and update on move and resize (the owner ran a variant with ON_RESIZE and ON_WINDOW_MOVE callbacks re-reading them). The owner suggests the old claim may have meant controls within a dynamic layout; revisit in the separate window sampling effort (05-CONTEXT.md deferred ideas).

### O9. Caption of a colour chooser

claim: A BBjColorChooser shows no caption for setAttribute("label", ...).
ledger: L013
repro: owner-repros/o09_colorchooser.bbj
look for: On screen: the colour chooser and the edit box below it both got the attribute label=Primary. Does the text Primary appear next to the colour chooser (the edit box shows it, for comparison)? Elements panel: does the dwc-color-chooser element carry a label attribute, and is a rendered caption inside or beside it? Confirm only if no caption is shown for the chooser.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: A BBjColorChooser shows no caption for setAttribute("label", ...).
note: Owner: 'O9 and O10 accepted'.

### O10. Scale of saturation and lightness

claim: getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0.
ledger: L097
repro: owner-repros/o09_colorchooser.bbj
look for: Open the chooser, pick a colour with clearly non-zero saturation and lightness, and read the text under the edit box: `saturation <a>, lightness <b>`. Confirm only if both numbers lie between 0 and 1.0 (for example 0.89). Numbers between 0 and 100 mean reject; write the numbers into `note:`.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0.
note: Owner: 'O9 and O10 accepted'.

### O11. Inline versus URL injection of an ES module

claim: An ES module injected inline with injectScript() cannot load its relative imports, while the same module loaded with injectScriptUrl(url, top, "type=module") can.
ledger: L061
repro: owner-repros/o11_module_inline.bbj, owner-repros/o11_module_url.bbj
look for: Run each program on its own (first copy o11/main.js and o11/dep.js to `<BBjHome>/htdocs/o11/`). Console panel and the page title of the tab: with o11_module_inline the title stays unchanged and the console reports the import of ./dep.js failing; with o11_module_url the title reads `p5-o11-loaded-dep-ok` and the console has no error. Confirm only if both programs behave so.
result: confirm
DWC build: 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12)
BBj build: 26.03, build 10/06/2026 09:19
granted sentence: An ES module injected inline with injectScript() cannot load its relative imports, while the same module loaded with injectScriptUrl(url, top, "type=module") can.
note: Owner: 'O11 passes okay'.
