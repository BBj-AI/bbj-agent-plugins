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
