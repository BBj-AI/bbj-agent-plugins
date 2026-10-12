# Phase 5: bbj-web-programming makeover - Context

**Gathered:** 2026-10-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Rewrite `plugins/bbj/skills/bbj-web-programming/` (SKILL.md, 380 lines, and 7 references, 973
lines) so that an agent using `/bbj:bbj-web-programming` gets a short skill with the triggers first.
Every DWC claim must be documented (URL) or owner-reproduced (with the DWC/BBj build recorded).
All taste is cut, the `injectStyle` `top` claim states the documented meaning (the top-level window),
and every `bbj` block passes both live routes. At the end `bbj-web-programming` is removed from
`pending` in `tests/skills_baseline.json`. Requirements WEB-01, WEB-02, WEB-03.
`bbj-programming` (Phase 4) is finished and is touched only where this phase links to it.

</domain>

<decisions>
## Implementation Decisions

### Carried forward from Phase 4 (not re-asked)
- **D-01:** Phase 4's ledger method applies unchanged. The ledger is `05-LEDGER.md`, a planning
  artifact in the phase directory. It has one row per rule with the columns of 04 D-02 and the
  classes DOC / COMPILE / RUNTIME / OWNER (04 D-21). COMPILE probes are committed under `probes/`
  and are compiled only, never run (04 D-03). A runtime claim with no doc source is rewritten to
  its compile-time observable, sent to the owner checklist (D-05), or dropped (04 D-04). Only the
  user grants OWNER.
- **D-02:** Every rule is cross-checked against `bbj://primer`. A rule the primer already states is
  cut (04 D-05).
- **D-03:** Code examples follow 04 D-06..D-10:
  - wrong code appears only in `bbj should-fail` pairs, used only for real traps;
  - every block is a minimal complete program;
  - there is no `bbj nocheck`, and the ratchet stays at 0;
  - same-line comments are written `; rem ...`.
- **D-04:** SKILL.md shape follows 04 D-11/D-20:
  - the check-order block comes first and stays byte-identical (`tests/test_check_order.py`);
  - a short list of rules follows;
  - pointers to the bbj-docs tools replace copied tables;
  - a reference index comes last;
  - the body is about 150 lines;
  - the description puts the triggers first and is 1,024 characters or fewer, and it lists symptoms
    only for topics that survived.

### Owner proof for DOM/CSS claims (WEB-01)
- **D-05:** DWC DOM/CSS claims that no page states (the `dwc-frame` vs `addOuterStyle()` structure,
  shadow-DOM reach, focus-ring clipping, `injectStyle` placement in the DOM, the HTML-text traps and
  so on) get proof in **one batch owner session**. BBj is still never run by Claude to prove a claim
  (04 D-04). The executor prepares `05-OWNER-CHECKLIST.md`. Each item gives:
  - the exact claim wording;
  - a minimal repro `bbj` program, gate-passing, which the owner runs;
  - what to look for in the browser devtools;
  - a field for confirm/reject and the DWC/BBj build.
- **D-06:** Only claims worth keeping go on the checklist, meaning claims an agent would get wrong
  without them. The executor triages first, and minor undocumented claims are dropped without
  asking. This keeps the owner session short.
- **D-07:** Order: ledger → blocking owner checkpoint (`checkpoint:human-verify`) → rewrite.
  - A claim the owner rejects or cannot confirm is dropped, never hedged.
  - A confirmed claim gets an OWNER ledger row (who, date, DWC/BBj build). It ships with the
    maintainer-confirmed wording of 04 D-24: "the rule the skill maintainer confirmed on BBj
    <version>; the documentation does not state it".
  - Nothing beyond the exact confirmed sentence is granted.
- **D-08:** The phase writes `05-DOCS-PROPOSAL.md` for the BASIS documentation owners (04
  D-18/D-23). It lists every OWNER claim and every gap where the docs are silent, for example the
  DWC window DOM structure and the wording of the `injectStyle` `top` parameter. It is not shipped,
  and no docs are edited from this repo.

### Which references survive (WEB-02)
- **D-09:** The ledger decides, by the 04 D-13/D-14 rule:
  - all 7 references are candidates;
  - each keeps only claims that pass the ledger;
  - a reference left with fewer than about 3 surviving rules is folded into SKILL.md or a sibling
    reference and deleted (`color-chooser.md`, 39 lines, will probably fold);
  - merging references (e.g. `themes.md` + `shadow-dom-styling.md`) is at the executor's discretion.
- **D-10:** `shoelace.md` keeps only the part that is about BBj, if it passes the ledger: a web
  component's ES module must be loaded by URL rather than through `injectScript()` inline, because
  inline injection breaks relative imports; BBjWebComponent usage; Jetty `/files/` paths. Cut as
  taste: the Shoelace component reference, Shoelace theming, and the local-first/CDN fallback recipe.
- **D-11:** `running-dwc-apps.md` keeps only the facts specific to DWC, if documented:
  - registration through the BBjAdminAPI;
  - the DWC/BUI URL shape;
  - a DWC app is exercised only in a browser, and `bbj` launches the ThinClient.

  The launcher flags (`-WD`, `-q`) are removed and replaced with a pointer to
  `plugins/bbj/skills/bbj-programming/references/running.md`. The advice that "a registration helper
  is worth writing" is cut as taste. The finished Phase 4 skill is not edited.
- **D-12:** In `form-validation.md`, the copied per-control attribute tables are replaced by a docs
  URL. Only the traps agents fall into are kept, if documented:
  - `accept()` must unlock the window after `BBjFormValidationEvent`;
  - built-in validation wins over JS;
  - never trust client-validated data on the server;
  - BBj 22.10+ / DWC only.

### Where taste ends (WEB-02)
- **D-13:** Generic web/CSS know-how is cut unless it is specific to BBj/DWC. Examples: the
  grid-vs-flex rule, "declare the grid on the parent", "let CSS switch views, not `setVisible()`",
  media-query advice. A rule stays only where DWC/BBj changes the outcome (e.g. Automatic Layout
  attributes, or an `addClass` target that differs from what plain CSS expects), with evidence.
- **D-14:** All recommended patterns are cut, with no labelled suggestions (PROJECT.md):
  - the CSS class naming pattern;
  - the utility helper pattern;
  - "load the stylesheet from beside the program";
  - local-first/CDN loading;
  - the "Optional libraries" section.

  A fact inside a pattern survives only as a stated fact with evidence. The named taste (GSAP,
  Swiper, Tabler Icons, Google Fonts/Inter/Playfair Display, the 420px card grid) is cut, as
  required.
- **D-15:** The focus-ring rule (WEB-01) is stated as an observable fact in the docs' wording
  (amended 2026-10-11 after research):
  - DWC draws a "focus ring", as the docs name it. The skill makes no claim about whether it is
    built from `outline` or `box-shadow`;
  - an `overflow: hidden/auto` ancestor clips it (owner checklist);
  - padding of `calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap))` avoids the clipping.

  The token names come from DWC docs (D-16). The "accessibility bug, not cosmetic" framing and the
  color-token listing are dropped.

### Evidence for CSS/JS (WEB-01)
- **D-16:** These sources count as DOC evidence for DWC CSS facts (`--dwc-*` token names, `::part`
  names, component attributes):
  - documentation.basis.cloud first;
  - the DWC component and token documentation of webforJ (docs.webforj.com, or the webforj MCP
    `styles_list_tokens` / `styles_get_component` catalog), with the URL and the DWC version that
    matches BBj 26.03 recorded in the ledger.
- **D-16a:** (added 2026-10-11 after research) BASIS's DWC guides at `dwc.style/docs` count as DOC
  evidence under D-16, with the URL and the DWC version recorded.
- **D-16b:** (added 2026-10-11 after research) Reading the shipped `dwc-ui.css` and client JS
  statically is triage only. It is used to choose and word checklist items and never ships a claim
  by itself. The evidence classes stay DOC / COMPILE / OWNER.
- **D-17:** Non-`bbj` blocks (css, js, html) are kept to a minimum. A block stays only where it
  carries a surviving fact, and every token, selector and attribute in it traces to a ledger row.
  No new lint is added, so the gate scope stays as Phase 3 set it.

### Fixed by the requirements
- **D-18:** The `injectStyle` `top` claim is rewritten to the documented meaning of the parameter
  (the top-level window), with the docs URL (WEB-03). This covers `references/color-chooser.md:37`
  ("use `0` to win the cascade … confirmed empirically"), `references/themes.md:29` and the
  `shadow-dom-styling.md` probe. A placement/cascade claim beyond the docs goes to the owner
  checklist (D-05) or is dropped.

### Owner request during the owner session (2026-10-12)
- **D-18a:** `05-DOCS-PROPOSAL.md` gets an entry for the context issue the owner (Stephan Wald) hit while
  running `owner-repros/o01_window_dom.bbj`: creating a second top-level window failed with "context
  already in use" until `sysgui!.setContext(sysgui!.getAvailableContext())` ran first. The owner asked
  for it to go into the docs proposal only. It is not an OWNER grant, and the skill ships nothing about it
  (ledger row L045 stays drop). Plan 05-09 carries it.

### Owner confirmation (owner session, plan 05-05, 2026-10-12)
- **D-19:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O1, ledger L021; granted sentence: "addClass() on a BBjTopLevelWindow puts the class on dwc-window-center and addOuterStyle() puts it on dwc-frame."
- **D-20:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O2, ledger L028; granted sentence: "dwc-frame is in normal flow, so top and left have no effect on it and margin auto centers it horizontally."
- **D-21:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O4, ledger L022; granted sentence: "The controls of a top-level window are children of dwc-window-content, and a BBjChildWindow renders as dwc-panel whose controls are its direct children."
- **D-22:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O5, ledger L038; granted sentence: "The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline style attribute does."
- **D-23:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O6, ledger L071; granted sentence: "An ancestor with overflow hidden or overflow auto clips the focus ring of a control, and padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it."
- **D-24:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O7, ledger L005; granted sentence: "HTML text in a control must start with <html> or it shows as literal text."
- **D-25:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O9, ledger L013; granted sentence: "A BBjColorChooser shows no caption for setAttribute("label", ...)."
- **D-26:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O10, ledger L097; granted sentence: "getClientProperty("saturation") and getClientProperty("lightness") of a BBjColorChooser return a fraction from 0 to 1.0."
- **D-27:** OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03 (build 10/06/2026 09:19), DWC 26.03, build 10/06/2026 09:19 (DWC ships inside BBj; owner statement 2026-10-12): checklist O11, ledger L061; granted sentence: "An ES module injected inline with injectScript() cannot load its relative imports, while the same module loaded with injectScriptUrl(url, top, "type=module") can."

Not confirmed: O3 (ledger L031) and O8 (ledger L032) were rejected by the owner and are dropped (D-07); no D-nn is written for them.

### Claude's Discretion
- The plan split and order, within the ledger → owner checkpoint → rewrite constraint (D-07).
- The checklist and probe layout and naming under the phase directory.
- Merging or renaming references, and the new file names.
- The exact wording of rules, as long as each traces to a ledger row.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` (Phase 5 section): goal and four success criteria
- `.planning/REQUIREMENTS.md`: WEB-01, WEB-02, WEB-03
- `.planning/PROJECT.md`: core value; Key Decisions (cut all taste, runtime claims rewritten or dropped, OWNER class, DWC DOM/CSS needs docs URL or owner reproduction)
- `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`: origin list of taste and leftovers

### Method set by Phase 4 (reuse it)
- `.planning/phases/04-bbj-programming-makeover/04-CONTEXT.md`: D-01..D-24, the ledger method, examples, OWNER class and wording
- `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md`: ledger format to copy
- `.planning/phases/04-bbj-programming-makeover/ledger_check.py`: ledger consistency check, adapt for 05
- `.planning/phases/04-bbj-programming-makeover/probes/`: probe layout
- `.planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md`: proposal format
- `.planning/phases/04-bbj-programming-makeover/04-UAT.md`: G-04-2 shows why owner claims are confirmed before the rewrite

### Gate and baseline (Phase 3)
- `.planning/phases/03-example-gate-and-structure-lints/03-CONTEXT.md`: fence grammar, should-fail rule, no harness, Sources/Verified rule
- `.planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md`: per-block to-do list for `bbj-web-programming`
- `tests/test_skill_examples.py`: the gate (`--report`)
- `tests/skills_baseline.json`: `bbj-web-programming` pending (grammar 5, structure 8, bbjcpl 25, bbj-ls 15); remove it when all reach 0
- `tests/test_check_order.py`: pins the check-order block

### Content being rewritten
- `plugins/bbj/skills/bbj-web-programming/SKILL.md`
- `plugins/bbj/skills/bbj-web-programming/references/` (`themes.md`, `shadow-dom-styling.md`, `responsive-layout.md`, `form-validation.md`, `running-dwc-apps.md`, `shoelace.md`, `color-chooser.md`)
- `plugins/bbj/skills/bbj-programming/references/running.md`: link target for launcher facts (do not edit)
- `plugins/bbj/skills/bbj-programming/references/callback-performance.md`: currently linked from form-validation.md; check the link still resolves

### External
- `bbj://primer` (bbj-docs MCP resource)
- BASIS docs, https://documentation.basis.cloud/BASISHelp/WebHelp/: `BBjWebManager::injectStyle`, `addOuterStyle`, `setOuterStyle`, `BBjWebComponent`, client validation, BBjAdminAPI pages
- DWC/webforJ docs (docs.webforj.com; webforj MCP styles tools): `--dwc-*` tokens, `::part` names (D-16)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/test_skill_examples.py --report`: per-block status for both routes
- Local routes: `/opt/bbx/bin/bbjcpl` (BBj 26.03) and `bbj-ls` at `http://127.0.0.1:5009/mcp`
- `04-*/ledger_check.py` and the probe layout from Phase 4
- bbj-docs MCP tools for DOC URLs (disconnected during this discussion; research must reconnect or note it)
- webforj MCP `styles_list_tokens` / `styles_get_component` (need `webforjVersion`; pick the DWC version that matches BBj 26.03)

### Established Patterns
- References end with `## Sources` and `Verified on BBj <version>` (Phase 3 D-18)
- Denylist strings must never appear in skill files (`DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin/`)
- A pending skill whose counts all reach 0 FAILs until it is removed from pending, so removal is the last step

### Integration Points
- The check-order block is shared byte-identical with `bbj-programming/SKILL.md` and `codex/AGENTS-snippet.md`
- Codex installer copies the skills directory; deleted references need no installer change, but grep README/docs for references to them
- Cross-skill links (`bbj-programming` → `references/running.md`, `callback-performance.md`) must resolve after the rewrite

</code_context>

<specifics>
## Specific Ideas

- Known wrong claim: `color-chooser.md:37`, "use `0` to win the cascade, not `1`. Confirmed
  empirically". It is replaced with the documented `top` meaning (D-18).
- Candidate owner-checklist items, triaged per D-06:
  - `dwc-frame` reachable only via `addOuterStyle()`, while `addClass()` targets `dwc-window-center`;
  - `setStyle` vs `setOuterStyle` targets;
  - focus-ring clipping;
  - page CSS not reaching shadow roots;
  - the HTML-text traps;
  - the label attribute vs a separate static text.
- The user wants the owner session as one sitting, with the minimal repro program and the devtools
  step ready for each item.

</specifics>

<deferred>
## Deferred Ideas

- A lint for `--dwc-*` token names against a pinned token list. It was considered and not added
  this phase (D-17); it could go to v2 maintenance.
- Matching expected error text for `should-fail` blocks (Phase 3 deferred item).
- A better, verified sample for sizing and positioning a top-level window in DWC (owner request,
  2026-10-12, owner session). The old sample (SKILL.md:146, from the BBjSkills import) sized and placed
  windows with CSS; the owner's view is that a BBjTopLevelWindow is sized and positioned with the API, and
  CSS lays out only the controls inside a window created with the Automatic Layout flag. Not granted as a
  rule for this phase (owner chose to leave it out); a future skill item.
  The same separate sampling effort revisits two rejected owner items (owner, 2026-10-12): O3 (where BBj
  puts inline width/height: not on dwc-frame; seen once on dwc-window-center, not reproducible) and O8
  (getX/getY/getWidth/getHeight on an Automatic Layout window return correct numbers and update on move
  and resize, not null; the owner suggests the old claim may have meant controls inside a dynamic layout).

</deferred>

---

*Phase: 05-bbj-web-programming-makeover*
*Context gathered: 2026-10-11*
