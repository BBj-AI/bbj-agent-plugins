# Documentation improvement proposal: DWC web development pages (from the bbj-web-programming rewrite)

To: the BASIS documentation owners
From: the bbj-agent-plugins repository, Phase 5 (bbj-web-programming makeover), 2026-10-12
Status: not shipped. This file is a planning document of the repository. Nothing in the BASIS
documentation, in the documentation server or in the primer was edited from this repository, and
nothing here was sent anywhere. Every change below is a suggestion for the owners to accept, reword
or reject.

Why this exists. Phase 5 rewrote the `bbj-web-programming` agent skill so that it states only facts
that are documented (page URL) or reproduced on a real BBj and DWC. Every rule of the old skill went
into a claim ledger (`05-LEDGER.md`). Where a rule survives only because the project owner confirmed
it, or where the old skill said something the pages contradict or do not say, the documentation is
silent on a thing agents and people trip over. This file is the list of those gaps, the meaning of the
`top` argument of the inject methods first, each with suggested wording.

How evidence is given.

- Page evidence: the page URL and one sentence quoted from the official page body, read from the page
  file itself on 2026-10-12. Three hosts count: https://documentation.basis.cloud/BASISHelp/WebHelp/,
  BASIS's own DWC guides at https://dwc.style/docs/ and the webforJ DWC documentation at
  https://docs.webforj.com/docs/. Text that the documentation server appends to a page, or serves as a
  search result labelled "not a citable page", is never used as evidence (see the last section).
- Compile evidence: a probe file `probes/<name>.bbj` in the Phase 5 directory and the matching lines
  of `probes/OUTPUT.txt`, produced with `bbjcpl -t -N -X` and with the `bbj-ls` check on BBj 26.03.
  Probes are compiled only. Nothing was run by this repository, because it never runs BBj.
- Owner evidence: a behaviour that no page states and no compile can show, confirmed on a real BBj and
  DWC by the project owner. It is named as such with the confirmer, the date, the BBj version and DWC
  build and the decision D-nn of `05-CONTEXT.md` that records the granted sentence, and it carries its
  OWNER ledger id. An entry never says more than the granted sentence.
- Ledger ids (L0NN) refer to rows of `05-LEDGER.md`. Probes and owner programs are under
  `.planning/phases/05-bbj-web-programming-makeover/` (`probes/`, `owner-repros/`).

## The top argument of the inject methods

One gap, T1. It touches five pages, and it is the one wrong claim of the old skill that the
requirements name (WEB-03).

### T1. injectStyle and injectStyleUrl do not say what "top level window" means, and what the old skill said about head and body is the injectLinkUrl wording

Page: the five pages under `bui/BBjBuiManager/`:

- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm
  (`BBjBuiManager_injectStyle.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyleUrl.htm
  (`BBjBuiManager_injectStyleUrl.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectScript.htm
  (`BBjBuiManager_injectScript.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectScriptUrl.htm
  (`BBjBuiManager_injectScriptUrl.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectLinkUrl.htm
  (`BBjBuiManager_injectLinkUrl.htm`)

Says today: four of the five pages give the same meaning to `top`. The parameter tables read:

- injectStyle: "A boolean value specifying whether this CSS is to be injected into the top level window
  of the page."
- injectStyleUrl: "A boolean value specifying whether this style is to be injected into the top level
  window of the page."
- injectScript: "A boolean value specifying whether this script is to be injected into the top level
  window of the page."
- injectScriptUrl: "A boolean value specifying whether this script is to be injected into the top level
  window of the page."

The fifth page, injectLinkUrl, means something else by the same argument name: "Specifies which element
the link URL will be injected into. By default, the link URL is injected into the head element. true (1)
= Injects the link URL into the head element. false (0) = Injects the link URL into the body element."
All five pages are marked "In BBj 22.03 and higher". The examples of the four "top level window" pages
set `top = 1` and show a "Top" check box, and say nothing about what the box changes.

Lacks: for injectStyle and injectStyleUrl (and, with the same sentence, injectScript and
injectScriptUrl):

- what "top level window of the page" means for a DWC app (the page of the browser, or a window of the
  application);
- where in the document the element ends up, head or body, and so whether the order of two injections
  can change which of two CSS rules wins a tie;
- the value used when `top` is left out, which the injectLinkUrl page states ("By default ... the head
  element") and the other four do not;
- whether a later injection replaces an earlier one with the same `id` attribute or adds to it.

Evidence: ledger rows L058 (SKILL.md:234-235 of the old skill), L100 (color-chooser.md:37) and L208
(themes.md:29) hold the claim and the corrected wording; L238 holds the shared "top level window"
sentence of the four pages and L239 the injectLinkUrl meaning (D-18, WEB-03). The old skill said that
`top` `0` "appends the style tag at the end of body and wins the cascade" and `1` "injects into head",
and added "Confirmed empirically" in one place. That is the injectLinkUrl description applied to
injectStyle; the injectStyle page says none of it, and this repository could not confirm it (no
checklist item covers it, the owner session did not test it, and the shipped skill states only the page
sentence). Compile evidence: `probes/p09_injectstyle_int_top.bbj` calls `injectStyle(css$, 1, "id=app-vars")`
and `injectStyle(css$, 0, "id=app-vars-2")` on a declared BBjWebManager; `probes/OUTPUT.txt` lists it as
`bbjcpl: clean` and `bbj-ls: clean`. This shows only that `1` and `0` are accepted for a boolean
parameter; it says nothing about where the element lands. The old skill's description (ledger row L001)
advertised "a window's CSS not applying or only half-applying" among its symptoms, which is why the
placement reading mattered to agents. No claim about placement is made here from this repository.

Request: please state for injectStyle and injectStyleUrl, and for injectScript and injectScriptUrl,
the facts in the four bullets above, as the owners know them, or confirm that "top level window of the
page" is the whole intended meaning. Suggested wording for the `top` row of the injectStyle parameter
table (the bracketed parts are for the owners to fill, this repository does not know them):

> top: A boolean value specifying whether this CSS is to be injected into the top level window of the
> page. [In a DWC app, the top level window of the page is <what it is>.] [The style element is added to
> the <head or body> element.] [If top is omitted, <true or false> is used.] [Two injections are applied
> in the order <in the order of the calls, or another order>; a later injection <does or does not>
> replace an earlier one with the same id attribute.] Do not confuse this with the top parameter of
> injectLinkUrl, which chooses between the head and the body element.

## DWC window structure and styling hooks

Two gaps, W1 and W2. Only the facts the owner granted are stated as facts; everything else is an open
question for the owners.

### W1. No page names the elements of a DWC window or says which method reaches which

Page: the pages that already talk about the outer component and the content panel:

- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjtoplevelwindow/BBjTopLevelWindow_addOuterStyle.htm
  (`BBjTopLevelWindow_addOuterStyle.htm`) and `BBjTopLevelWindow_setOuterStyle.htm` in the same directory
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_addClass.htm
  (`BBjControl_addClass.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjwindow/BBjWindow_setPanelStyle.htm
  (`BBjWindow_setPanelStyle.htm`)
- https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Taking_GUI_App_to_DWC.htm

Says today: addOuterStyle: "In BBj 22 and higher, adds a CSS class name to the outer component of a
BBjTopLevelWindow." setOuterStyle: "In BBj 21 and higher, this method sets a CSS property on the outer
component of a BBjTopLevelWindow." addClass: "In BBj 23.00 and higher, this method adds a CSS class name
to the BBjControl." setPanelStyle: "In BBj 21.00 and higher, this method sets a CSS property on the
content panel of a BBjWindow." The DWC tutorial adds: "BBjWindow::setPanelStyle applies CSS properties to
the window's content panel, which contains the window's controls." No page says what "outer component" or
"content panel" is in the DOM of the browser.

Lacks: the names of the elements a DWC window renders (`dwc-frame`, `dwc-window-center`,
`dwc-window-content`, `dwc-panel`) and which of addClass, addOuterStyle, setOuterStyle and setPanelStyle
reaches which element. A reader who writes a stylesheet needs those names. Searches of the BASIS pages,
of the 57 component pages of https://dwc.style/docs/ and of https://docs.webforj.com/docs/ found no
dwc-frame and no dwc-window-center (ledger L021); dwc-window-content and dwc-panel are on no page either
(L022). The only DWC window page of the theme engine lists `--dwc-window-*` tokens.

Evidence: what the owner confirmed on a real DWC is in the next section: the element that carries the
class of addClass and of addOuterStyle (L021, D-19), the children of dwc-window-content and dwc-panel
(L022, D-21) and the layout of dwc-frame (L028, D-20). What nobody confirmed, and what is therefore an
open question and not a claim: which element setOuterStyle reaches (no checklist item covered it), which
element the "content panel" of setPanelStyle is, and whether a fourth element `dwc-window-container`
sits between dwc-frame and dwc-window-center. The old skill drew that four-element picture
(L023) and was dropped without asking because no page or probe states it (D-06). Reading the install's
shipped client files showed some of the names; that was triage for wording the checklist and is not
evidence (D-16b).

Request: please add a short section to the DWC pages, for example next to the setPanelStyle tutorial
above, that names the elements of a window and the method that reaches each one. Suggested wording (the
first two sentences are the owner's granted facts, the rest is for the owners to fill):

> A BBjTopLevelWindow renders as <the nested elements, outermost first>. addClass() puts the class on
> dwc-window-center and addOuterStyle() puts it on dwc-frame. The controls of the window are children of
> dwc-window-content. setOuterStyle() sets its CSS property on <element>, and setPanelStyle() on
> <element>.

### W2. setOuterStyle exists on BBjTopLevelWindow only, and the pages do not say so

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjtoplevelwindow/BBjTopLevelWindow_setOuterStyle.htm
(`BBjTopLevelWindow_setOuterStyle.htm`).

Says today: the page sits under BBjTopLevelWindow and reads "In BBj 21 and higher, this method sets a CSS
property on the outer component of a BBjTopLevelWindow." The page sits under BBjTopLevelWindow; it has no
sentence about other classes.

Lacks: a statement of the scope, that the method is absent from BBjChildWindow and BBjButton. The old skill said that setOuterStyle "is only valid on BBjTopLevelWindow
and BBjChildWindow" and that calling it on a BBjButton "is a syntax error". Both halves are wrong.

Evidence: ledger rows L035 and L025. `probes/p03_childwin_setouterstyle.bbj` fails `bbjcpl -t -N -X` with
`type check error [No match for method com.basis.bbj.proxies.sysgui.BBjChildWindow.setOuterStyle(BBjString, BBjString)]`
and `probes/p05_button_setouterstyle.bbj` with `type check error [No match for method
com.basis.bbj.proxies.sysgui.BBjButton.setOuterStyle(BBjString, BBjString)]`; `probes/p04_childwin_addouterstyle.bbj`
fails the same way for addOuterStyle on a BBjChildWindow. `bbj-ls` reports all three programs clean, so
only the compiler shows the error. `probes/p06_toplevel_outer.bbj` (addOuterStyle and setOuterStyle on a
declared BBjTopLevelWindow) is clean on both routes. These are compile results; nothing was run.

Request: please state on the outer-style pages, or on a DWC page, that the outer-style methods belong to
BBjTopLevelWindow. Suggested wording:

> The outer-style methods (addOuterStyle, removeOuterStyle, clearOuterStyles, getOuterStyle,
> getOuterStyles, getComputedOuterStyle and setOuterStyle) are methods of BBjTopLevelWindow. They are not
> available on BBjChildWindow or on BBjButton.

## Owner-confirmed behaviour the documentation does not state

Nine claims, one entry each. Each is a single sentence the project owner confirmed on a real BBj and DWC
in the owner session of 2026-10-12 and granted by a decision of `05-CONTEXT.md`. Confirmer for all nine:
Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03 (build 10/06/2026 09:19; DWC ships
inside BBj, owner statement 2026-10-12). Each entry gives the granted sentence in quotes and nothing
wider. The documentation owners may reword it or find that it is wrong on another build.

### L021. addClass() and addOuterStyle() on a top-level window reach different elements (OWNER-confirmed, D-19)

Page: `BBjTopLevelWindow_addOuterStyle.htm` and `BBjControl_addClass.htm` (URLs in W1).

Says today: "adds a CSS class name to the outer component of a BBjTopLevelWindow" and "adds a CSS class name
to the BBjControl".

Lacks: which element of the window each call reaches.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-19; checklist O1; owner-repros/o01_window_dom.bbj. Granted sentence: "addClass() on a
BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame." The
owner pasted the DOM: the class of addClass on dwc-window-center, the class of addOuterStyle on dwc-frame.

Request: state the granted sentence on the addClass and addOuterStyle pages.

> On a BBjTopLevelWindow, addClass() puts the class on dwc-window-center and addOuterStyle() puts it on
> dwc-frame.

### L022. The controls of a window and of a child window (OWNER-confirmed, D-21)

Page: the DWC window section proposed in W1, and `BBjWindow_setPanelStyle.htm`.

Says today: "this method sets a CSS property on the content panel of a BBjWindow."

Lacks: the element names of the content panel and of a child window.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-21; checklist O4; owner-repros/o01_window_dom.bbj. Granted sentence: "The controls of a
top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose
controls are its direct children." Ledger L022.

Request: state it where the content panel is explained.

> The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as
> dwc-panel whose controls are its direct children.

### L028. dwc-frame is in normal flow (OWNER-confirmed, D-20)

Page: `BBjTopLevelWindow_addOuterStyle.htm` and `BBjTopLevelWindow_setOuterStyle.htm`.

Says today: "outer component of a BBjTopLevelWindow", with no statement about its layout.

Lacks: that top and left do not move the outer element and that margin auto centres it.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-20; checklist O2; owner-repros/o01_window_dom.bbj. Granted sentence: "dwc-frame is in normal
flow, so top and left have no effect on it and margin auto centers it horizontally." The owner remarked
"not exactly" about vertical centring; the sentence claims horizontal centring only, and nothing about
vertical centring is granted. Ledger L028.

Request: state the sentence, and the owners may add what holds for vertical placement.

> dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it
> horizontally.

### L038. The HTML of a list box item is inside the shadow root (OWNER-confirmed, D-22)

Page: https://dwc.style/docs/#/dwc/BBjListBox and https://dwc.style/docs/#/theme-engine/css-shadow-parts

Says today: "Inner elements of a Shadow DOM cannot be targeted directly with CSS." (shadow parts page) and
the part list of BBjListBox (`item`, `item-label`, ...). Neither says where the HTML of an item lands.

Lacks: that an item's own HTML is inside the shadow root, so a selector of the page does not reach it.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-22; checklist O5; owner-repros/o05_listbox_shadow.bbj. Granted sentence: "The HTML of a
BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline
style attribute does." The owner saw the three items inside the dwc-listbox shadow root; the item with an
`em` tag showed the browser's default italic and not the colour of the page's `em` rule. Ledger L038.

Request: state the sentence on the BBjListBox page.

> The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it
> while an inline style attribute does.

### L071. An overflow ancestor clips the focus ring (OWNER-confirmed, D-23)

Page: https://docs.webforj.com/docs/styling/state and
https://docs.webforj.com/docs/upgrading/webforj-26.00/design-system

Says today: "When a component receives focus, a focus ring is shown around it to indicate its active
state. The focus ring uses a gap-ring pattern with a surface-colored inner gap and a colored outer ring."
The upgrade guide: "If you reserve space around focusable elements with --dwc-focus-ring-width, add
--dwc-focus-ring-gap to the padding."

Lacks: that an ancestor with overflow hidden or auto clips the ring, and that padding on that ancestor is
the way out. The upgrade guide implies a ring that can overflow its reserved space, nothing more.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-23; checklist O6; owner-repros/o06_focus_ring.bbj. Granted sentence: "An ancestor with
overflow hidden or overflow auto clips the focus ring of a control, and padding of
calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it." The owner's
run: the ring was cut at the edge of the child window without padding and whole where the padding was set.
The old skill said the ring is an `outline`; the docs call it a focus ring and say nothing about the
mechanism, so the mechanism is not claimed. Ledger L071.

Request: add the sentence to the focus ring section.

> An ancestor with overflow hidden or overflow auto clips the focus ring of a control. Padding of
> calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it.

### L005. HTML text needs the html tag (OWNER-confirmed, D-24)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/bbjcontrol_settext.htm
(`bbjcontrol_settext.htm`), and the pages of addStaticText, BBjStaticText and BBjButton.

Says today: setText: "Sets the text in the BBjControl." and "This method only works on BBjControls that
contain text." The setText page has no sentence about HTML, and the research grep of the addStaticText,
BBjStaticText and BBjButton pages found no sentence that HTML text must start with `<html>`.

Lacks: that HTML in a control text must start with `<html>`.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-24; checklist O7; owner-repros/o07_html_text.bbj. Granted sentence: "HTML text in a control
must start with <html> or it shows as literal text." That those pages are silent is a fact about those
pages; whether another page states it was not searched. Ledger L005.

Request: state the sentence where control text is described, or point to the page that already does.

> HTML text in a control must start with <html> or it shows as literal text.

### L013. A colour chooser shows no label caption (OWNER-confirmed, D-25)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Labels.htm and
https://dwc.style/docs/#/dwc/BBjColorChooser

Says today: DWC_Labels: "In the DWC, you can create label elements by setting the "label" attribute on a
BBjControl with the setAttribute method." The attribute list of the BBjColorChooser page has no attribute
named label (read 2026-10-12; a page that is silent is not evidence of behaviour).

Lacks: that the label attribute shows no caption on a BBjColorChooser, although the Labels page speaks of
"a BBjControl" in general.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-25; checklist O9; owner-repros/o09_colorchooser.bbj. Granted sentence: "A BBjColorChooser
shows no caption for setAttribute("label", ...)." Ledger L013.

Request: list the controls that do not show the label attribute, or state the exception.

> A BBjColorChooser shows no caption for setAttribute("label", ...).

### L097. The scale of saturation and lightness (OWNER-confirmed, D-26)

Page: https://dwc.style/docs/#/dwc/BBjColorChooser. This is also the conflict C2 below.

Says today: "The saturation value, which ranges 0 to 100." and "The color lightness value." (hue: "The hue
value, which ranges from 0 to 360.").

Lacks: what getClientProperty returns for saturation and lightness.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-26; checklist O10; owner-repros/o09_colorchooser.bbj. Granted sentence:
"getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction
from 0 to 1.0." `probes/p14_colorchooser.bbj` shows only that the call compiles. Ledger L097.

Request: see C2.

> getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a
> fraction from 0 to 1.0.

### L061. An inline ES module cannot load its relative imports (OWNER-confirmed, D-27)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectScript.htm
and `BBjBuiManager_injectScriptUrl.htm` (URL in T1).

Says today: injectScript: "In BBj 22.03 and higher, this method injects the specified JavaScript into the
web page." The `BBjWebComponent_setSlot.htm` example loads a Shoelace module with injectScriptUrl and
"type=module"; no page gives a reason.

Lacks: that an ES module injected as text cannot resolve relative imports.

Evidence: OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03, DWC 26.03 (build 10/06/2026 09:19);
05-CONTEXT.md D-27; checklist O11; owner-repros/o11_module_inline.bbj and owner-repros/o11_module_url.bbj.
Granted sentence: "An ES module injected inline with injectScript() cannot load its relative imports,
while the same module loaded with injectScriptUrl(url, top, "type=module") can." Ledger L061.

Request: add it to the injectScript and injectScriptUrl pages.

> An ES module injected inline with injectScript() cannot load its relative imports, while the same module
> loaded with injectScriptUrl(url, top, "type=module") can.

## Conflicts between pages

Two conflicts. In both, the shipped skill states neither side beyond what is granted or documented in
BASIS's object pages (RESEARCH P10: the BBj object page wins for BBj API facts).

### C1. The attributes guide says "no-ops"; the setAttribute page says something else

Page: https://dwc.style/docs/#/dwc/guide/attributes-and-properties and
https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/BBjControl_setAttribute.htm
(`BBjControl_setAttribute.htm`)

Says today: the guide: "GUI, BUI, and WebUI have no concept of attribute or property customization - the
calls are no-ops there." The object page: "This functionality is primarily intended for setting low-level
BUI element attributes or DWC component attributes. When running in GUI, the attributes do not affect the
control itself, but may be used by the developer."

Lacks: one statement. The guide says no-ops in GUI, BUI and WebUI; the object page says the attributes are
meant for BUI element attributes too, and that in GUI they may be used by the developer.

Evidence: ledger row L014 (conflict 1 of RESEARCH). Page quotes read from the page files on 2026-10-12
(the guide from its raw file). The old skill copied the guide's sentence; the shipped skill uses the
object page's wording only.

Request: please bring the two pages in line and say what the calls do in BUI and WebUI.

> setAttribute and getAttribute <do or do not> have an effect in GUI, BUI and WebUI: <what they do>.

### C2. BBjColorChooser saturation: "0 to 100" on the component page, a fraction in getClientProperty

Page: https://dwc.style/docs/#/dwc/BBjColorChooser

Says today: "The saturation value, which ranges 0 to 100."

Lacks: whether that range describes the attribute and getClientProperty returns the fraction, or whether
the page is out of date for BBj.

Evidence: the old skill said 0 to 1.0 and called it empirical (ledger L097, RESEARCH conflict 3). The
owner confirmed on 2026-10-12 (BBj 26.03, DWC 26.03; D-26, checklist O10) that getClientProperty returns a
fraction from 0 to 1.0 for saturation and lightness. The owner confirmed that return value only; what the
attribute holds was not tested, so this entry does not say the page is wrong.

Request: state the scale for both channels.

> saturation: The saturation value. getClientProperty("saturation") returns a fraction from 0 to 1.0;
> <the attribute holds a value from 0 to 100, if that is so>.

## Rules dropped for lack of a source (candidates to confirm)

Owner checklist items that were rejected: two. Not confirmed (cannot confirm): none. The other nine items
were confirmed and are in the previous sections. A rejected claim is dropped and is not presented as fact;
what the owner saw is attached as an observation of one session, not as a rule. The remaining entries are
the D-06 drops that would be worth a page.

### R1. Width and height of a window (checklist O3 rejected; L031)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm
(`bbjsysgui_addwindow.htm`)

Says today: the x, y, w and h parameters of addWindow, e.g. "Horizontal position of the upper-left corner of
the window in current units.", and the flag "$00100000$ Automatic Layout : Automatically arranges all
controls and child windows placed in the window to fit."

Lacks: how the size and position of a BBjTopLevelWindow reach the page in the DWC (which element carries
them), and whether CSS or the API is the way to size and place it.

Evidence: the old skill claimed that BBj writes width and height on dwc-frame as inline styles (L031). The
owner rejected it on 2026-10-12 (BBj 26.03, DWC 26.03; O3): the console showed no style attribute on the
dwc-frame element, and the style of dwc-window-center was `position: relative; inset: 0px; resize: both;
min-width: 95px;`; an earlier run had width and height on dwc-window-center. The owner's view, recorded in
05-CONTEXT.md under deferred ideas and not granted as a rule, is that a BBjTopLevelWindow is sized and
positioned with the API, and that CSS lays out only the controls inside a window created with the
Automatic Layout flag.

Request: please describe where the size and position of a top-level window are applied in the DWC.

> In the DWC the x, y, w and h of a BBjTopLevelWindow are applied to <element>. <CSS or API> is the way to
> size and place the window.

### R2. getX, getY, getWidth and getHeight on an Automatic Layout window (checklist O8 rejected; L032)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjcontrol/bbjcontrol_getx.htm
(`bbjcontrol_getx.htm`) and `bbjcontrol_getwidth.htm` in the same directory.

Says today: getX: "Returns the X coordinate of the BBjControl." getWidth: "Returns the width of the
BBjControl." Neither page mentions an Automatic Layout window.

Lacks: whether the four getters are valid on a window created with the Automatic Layout flag, and whether
the values follow a move or resize.

Evidence: the old skill claimed that all four return null on such a window (L032). The owner rejected it on
2026-10-12 (BBj 26.03, DWC 26.03; O8, owner-repros/o08_autolayout_geometry.bbj): the getters returned
numbers and, in a variant with ON_RESIZE and ON_WINDOW_MOVE callbacks, followed a move and a resize. That
is one session's observation, not a granted sentence. The owner suggested that the old claim may have meant
controls inside a dynamic layout.

Request: state what the getters return for a window and for a control under Automatic Layout.

> On a window or child window created with the Automatic Layout flag ($00100000$), getX(), getY(),
> getWidth() and getHeight() <return ... / are not meaningful for the controls it arranges>.

### R3. Whether a stable id replaces an earlier injection (L065)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm
and the other inject pages (URLs in T1).

Says today: the `attributes` parameter: "A set of attributes to be added to the style element. Attributes can
be specified either as a string in the format "attr=value,attr=value" or as a HashMap containing key/value
pairs."

Lacks: what happens when two injections carry the same `id` attribute.

Evidence: the old skill said that an injection with a stable name or id replaces its earlier injection
instead of accumulating duplicate :root blocks (L065, and the theme-swap recipes L099 and L237). No page and
no probe states it; the `id=` attribute itself compiles (`probes/p09_injectstyle_int_top.bbj`). Dropped
without asking (D-06).

Request: state it, or state that duplicate ids are the caller's problem.

> If an element with the same id attribute already exists, the injection <replaces it / adds another element>.

### R4. What `bbj` does with a DWC program (L139, L140)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm

Says today: the options table: "TC Runs the interpreter in Thin Client mode" and "FC Runs in Fat Client mode
(non-Thin Client). This option has been obsolete since BBj 5.00." The registration page
(https://documentation.basis.cloud/BASISHelp/WebHelp/dwc/DWC_Registration_Launching.htm) says a DWC app is
launched by its URL in a browser.

Lacks: what a program that uses getWebManager(), injectStyle() or a DWC control does when it is started
from the command line (`bbj -q app.bbj`) and not through its URL. The old skill said it launches the
ThinClient desktop GUI, not the DWC, that injectStyle goes nowhere and that dwc-icon components never
render (L139, L140). None of that is on a page. The documented neighbours are "CSS settings have no effect
on the GUI client." (`BBjControl_addClass.htm`) and, in the example code of the injectStyle page, the
message "This functionality is only supported in browser environments."

Evidence: ledger rows L139 and L140; the ThinClient claim was not checked on the owner checklist (D-06).
The documentation server returned only the old skill text for it, labelled not citable (see the notes at
the end).

Request: state in the launching topic what happens when a DWC program is started outside the browser.

> A program started with <command> runs in <client>. DWC-only calls such as injectStyle() <are ignored /
> raise an error> there.

### R5. The "--" configuration file name (L155)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjconfig/bbjconfig_getconfigfilename.htm
(`bbjconfig_getconfigfilename.htm`)

Says today: "In BBj 2.02 and higher, this method returns the name of the configuration file used by the
current Interpreter session." and "Returns the name of the configuration file being used by the current
Interpreter session."

Lacks: what the method returns when the session was started without a configuration file.

Evidence: the old skill said it returns the literal "--" then, and that "--" must never be written into the
CONFIG_FILE property of an application definition (L155). No page and no probe states the value or the
failed launch. Dropped (D-06).

Request: state the return value for a session without a configuration file.

> If the session was started without a configuration file, getConfigFileName() returns <value>.

### R6. A second createApplication with the same name (L146)

Page: https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentConfiguration.html

Says today: createApplication: "Create a new application definition." and "The new application definition."

Lacks: what happens when an application with that name exists already.

Evidence: the old skill said to look for an existing application with the same name first, "or every run
adds a duplicate" (L146). Neither Javadoc page states what a second createApplication does. Dropped (D-06).

Request: state the behaviour for an existing name.

> If an application with the name already exists, createApplication() <adds a second definition / replaces
> it / throws BBjAdminException>.

### R7. A second top-level window needs a free context (L045; owner request, D-18a)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_getavailablecontext.htm
(`bbjsysgui_getavailablecontext.htm`) and `bbjsysgui_addwindow.htm` (URL in R1).

Says today: getAvailableContext: "Returns the next available context of the SysGui device." and "Returns
the next available context ID." addWindow, parameter context: "Specifies a new SYSGUI device context in
which to create the window." Neither page says that a second top-level window needs a free context.

Lacks: that creating a second top-level window fails with "context already in use" unless a free context
is set first.

Evidence: owner report of 2026-10-12 by Stephan Wald, while running owner-repros/o01_window_dom.bbj in the
owner session (plan 05-05, BBj 26.03): `sysgui!.addWindow(...)` for the second window (the program calls
`addWindow(title, flags)` with no context argument for both windows) failed with "context already in use"
until `sysgui!.setContext(sysgui!.getAvailableContext())` ran first; the program was fixed in commit 61d2c06
and compiles clean on `bbjcpl -t -N -X` and `bbj-ls`. The owner asked for this to go into the documentation
proposal only (05-CONTEXT.md D-18a). It is not an OWNER grant, the skill ships nothing about it, and
ledger row L045 ("Pass a FRESH getAvailableContext() per window", with a pointer to a file that does not
mention getAvailableContext) stays dropped. The cause was not investigated here; the entry records the
report and the fix only.

Request: please say on the getAvailableContext and addWindow pages what a program must do to create a second
top-level window. Suggested wording, the bracketed part for the owners:

> To create a second top-level window, first call setContext() with a free context, for example
> `sysgui!.setContext(sysgui!.getAvailableContext())`; [otherwise addWindow() fails with "context already in
> use" / <what the owners say is the exact rule>].

### Smaller candidates

| Id | Dropped rule | Why it was dropped |
| --- | --- | --- |
| L024 | when querying the DOM from injected JS, match `dwc-panel.my-class` for child windows, not `dwc-window` | no page or probe; the dwc-panel element for a child window is the granted L022 sentence |
| L026 | positioned on dwc-window-center, offsets resolve against dwc-window-container | no page or probe; part of the unconfirmed four-element picture (W1) |
| L029 | transform applies to dwc-frame, so the reflex centring idiom half-applies | no page or probe; only the horizontal margin auto sentence (L028) was granted |
| L033 | BBWindowUtils.centerWindow() throws !ERROR=252 against an auto-layout window | no page or probe; an error number needs its own source |
| L040 | a BBjImageCtrl renders as `<dwc-image><img src="..."></dwc-image>` | no page or probe |
| L094 | the value string of the colour chooser carries a percent sign on saturation and lightness | no page or probe states the value format |
| L096 | getClientProperty("hue") returns a plain 0 to 360 number | the attribute list says "The hue value, which ranges from 0 to 360."; what getClientProperty returns is on no page |
| L138 | registration is a one-time step and a source edit is picked up on the next run | the launching page describes registering and launching, not what a source edit does |
| L149 | strip "-" from the application name because the name becomes a URL path segment | the launching page says only "The name is used to create a unique URL for your app" |
| L151 | nothing is persisted until commit() runs | the Javadoc page lists commit only as inherited |
| L160 | getThinClient().browse(url!) does not work from a headless run | the browse page names what each client does and says nothing about headless runs |

## Notes for the docs server

Four hand-offs for the owners of the documentation server and of the primer (`bbj://primer`, docs build
2026-10-09, hash e43802fa, as read by the Phase 5 research). None is a request to edit a BASIS
documentation page.

1. The docs server serves the old skill text as documentation (RESEARCH P2). A search for
   BBjControl_setAttribute.htm returned the old skill's own "Web components" section under that official
   URL, while the raw page file read on 2026-10-12 contains none of it. Quoting the page file and not the
   search result was therefore the rule for every quote in this file.
2. Results labelled "not a citable page" look like documentation. Searches for the ThinClient claim (R4)
   returned only the old skill text with that label. They were not used as evidence anywhere (D-16b keeps the
   evidence classes DOC, COMPILE and OWNER). Suggested action: remove the old skill text
   from search results and pages, or label it unmistakably.
3. The primer paragraph gotchas/20 states that a literal `&` in control text is written `&&`, including
   the `&` of an HTML entity, and cites https://documentation.basis.cloud/BASISHelp/WebHelp/events/keyboard_focus_navigation_and_default_button.htm.
   That page says, about the hot key, "specify an ampersand, "&", before the letter or symbol in the title
   text which is to be the hot key" and "Ampersands in subsequent titles merely appear in the displayed
   title."; the doubling and the entity are not on it (ledger L006). Suggested action: give the paragraph a
   page that states it, or a compile or run reference.
4. The install's shipped static files (the stylesheet and the client JavaScript) were read only to choose
   and word owner checklist items (D-16b), never as evidence; every DOM claim above rests on the owner's
   run on a real DWC or is marked as an open question.

Entries per section: top argument of the inject methods 1 (T1); DWC window structure and styling hooks 2 (W1, W2); owner-confirmed behaviour 9 (L005, L013, L021, L022, L028, L038, L061, L071, L097); conflicts between pages 2 (C1, C2); rules dropped for lack of a source 7 (R1 to R7) plus 11 smaller candidates; notes for the docs server 4.
