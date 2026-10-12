# Phase 5: bbj-web-programming makeover - Research

**Researched:** 2026-10-11
**Domain:** Rewriting a Markdown agent skill (BBj DWC/BUI browser work) from a claim ledger; BASIS documentation, DWC/webforJ documentation, compile-only probes, the repository example gate
**Confidence:** HIGH on gate state, doc evidence and compile facts; MEDIUM on the DWC build pin (D-16) and on which claims the owner will confirm

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Carried forward from Phase 4 (not re-asked)
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

#### Owner proof for DOM/CSS claims (WEB-01)
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

#### Which references survive (WEB-02)
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

#### Where taste ends (WEB-02)
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
- **D-15:** The focus-ring rule (WEB-01) is stated as an observable fact only:
  - DWC draws focus as an outline outside the border box;
  - an `overflow: hidden/auto` ancestor clips it;
  - padding of `calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap))` avoids the clipping.

  The token names come from DWC docs (D-16) and the clipping from the owner checklist. The
  "accessibility bug, not cosmetic" framing and the color-token listing are dropped.

#### Evidence for CSS/JS (WEB-01)
- **D-16:** These sources count as DOC evidence for DWC CSS facts (`--dwc-*` token names, `::part`
  names, component attributes):
  - documentation.basis.cloud first;
  - the DWC component and token documentation of webforJ (docs.webforj.com, or the webforj MCP
    `styles_list_tokens` / `styles_get_component` catalog), with the URL and the DWC version that
    matches BBj 26.03 recorded in the ledger.
- **D-17:** Non-`bbj` blocks (css, js, html) are kept to a minimum. A block stays only where it
  carries a surviving fact, and every token, selector and attribute in it traces to a ledger row.
  No new lint is added, so the gate scope stays as Phase 3 set it.

#### Fixed by the requirements
- **D-18:** The `injectStyle` `top` claim is rewritten to the documented meaning of the parameter
  (the top-level window), with the docs URL (WEB-03). This covers `references/color-chooser.md:37`
  ("use `0` to win the cascade … confirmed empirically"), `references/themes.md:29` and the
  `shadow-dom-styling.md` probe. A placement/cascade claim beyond the docs goes to the owner
  checklist (D-05) or is dropped.

### Claude's Discretion
- The plan split and order, within the ledger → owner checkpoint → rewrite constraint (D-07).
- The checklist and probe layout and naming under the phase directory.
- Merging or renaming references, and the new file names.
- The exact wording of rules, as long as each traces to a ledger row.

### Deferred Ideas (OUT OF SCOPE)
- A lint for `--dwc-*` token names against a pinned token list. It was considered and not added
  this phase (D-17); it could go to v2 maintenance.
- Matching expected error text for `should-fail` blocks (Phase 3 deferred item).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WEB-01 | The same claim ledger covers the skill and its references; DWC DOM/CSS claims (DOM structure, `addOuterStyle`, focus-ring padding rule) survive only with a docs URL or an owner reproduction recorded with the DWC/BBj build | Doc-evidence table (section "Doc evidence found"): focus-ring tokens and padding rule have a DOC source; DOM tag names have none anywhere; owner-checklist candidates O1-O11; ledger sizing; ledger_check.py adaptation list |
| WEB-02 | Description is at most 1,024 characters with the triggers first; body short, references trimmed; all taste cut (GSAP, Swiper, Tabler Icons, Google Fonts/Inter/Playfair Display, the 420px card grid, etc.) | Inventory (1,575-character description today, 380-line body, 973 lines of references); which rules are primer overlap, DOC, or taste; Phase 4 SKILL.md shape; taste-word scan command |
| WEB-03 | The `injectStyle` `top` claim is corrected to the documented meaning; every `bbj` block passes the gate; skill name `/bbj:bbj-web-programming` unchanged | Verbatim `top` text of four inject pages; the old claim is the `injectLinkUrl` semantics misapplied; gate failures by cause; compile-clean program skeletons; name-unchanged check |
</phase_requirements>

## Summary

The skill is 380 lines plus 973 lines of references (1,353 lines in 8 files, 37 `bbj` fences, 22 `css` fences, 3 `bash` fences and 1 untagged fence). The gate today reports grammar 5, structure 8, bbjcpl 25, bbj-ls 15 for it (matching `tests/skills_baseline.json`). I estimate **200 to 260 ledger rows** (Phase 4 had 151 rows for a 464-line SKILL.md plus five references); the share of DOC rows will be much higher than in Phase 4 because most of `themes.md`, `form-validation.md` and the attribute/property section of SKILL.md are near-verbatim copies of BASIS's own DWC guides at `dwc.style/docs`, which this research found and fetched.

The decisive findings for planning are these. (1) **WEB-03 is fully documented**: `injectStyle`'s `top` is "A boolean value specifying whether this CSS is to be injected into the top level window of the page." The old "0 = end of body, 1 = head" text is the documented meaning of `injectLinkUrl`'s `top`, misapplied to `injectStyle`. (2) **No page anywhere documents the DWC window DOM tag names** (`dwc-frame`, `dwc-window-container`, `dwc-window-center`, `dwc-window-content`); the BBj docs speak only of the "outer component" and the "content panel" (`setPanelStyle`). Those claims need the owner session or must go. (3) **The focus-ring padding rule has a DOC source** (the webforJ v26 upgrade guide), but **CONTEXT D-15's "outline" wording conflicts with the docs and with the shipped CSS**: DWC 26 draws the ring as a `box-shadow` pair, not an `outline`. (4) Compile probes found three wrong claims in the current skill: `setSlot(child!, "footer")` has its arguments reversed (fails `bbjcpl -t`), `setOuterStyle`/`addOuterStyle` do not exist on `BBjChildWindow`, and `setOuterStyle` on a `BBjButton` is a type-check error, not a syntax error. (5) The `&&` rule is already in the primer (gotchas/20) and is cut by D-02; the `BBjControlValidation` plugin section has no doc and the plugin is not in the 26.03 install, so it is dropped.

**Primary recommendation:** Run the plan chain probes -> ledger (with an adapted `ledger_check.py`) -> owner checklist -> blocking owner session -> SKILL.md and references rewrite -> docs proposal -> finish plan that regenerates the baseline and removes the skill from `pending`. Treat `dwc.style/docs` and `docs.webforj.com` as D-16 DOC sources only after the user confirms (A1), and replace D-15's "outline" with the docs' own words.

## Architectural Responsibility Map

This phase changes Markdown and planning artifacts, not an application. The "tiers" are the places a fact can live.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Claim evidence (DOC/COMPILE/RUNTIME/OWNER) | `05-LEDGER.md` + `probes/` (planning, not shipped) | `05-OWNER-CHECKLIST.md` | Every shipped sentence must trace to a ledger row (D-01) |
| Owner proof of DOM/CSS facts | Human owner session on a real BBj/DWC | `owner-repros/*.bbj` (compile-checked, never run by Claude) | Only the user grants OWNER; BBj is never run by Claude (D-05) |
| What an agent reads | `plugins/bbj/skills/bbj-web-programming/SKILL.md` | `references/*.md` loaded on demand | Short trigger-first skill; references hold only ledger survivors (D-04, D-09) |
| Example correctness | `tests/test_skill_examples.py` gate (live `bbjcpl -t -N -X`, then `bbj-ls`) | scratch-root dry run | Existing Phase 3 gate; no new lint (D-17) |
| Structure | `tests/test_skill_examples.py` structure lints, `tests/test_check_order.py` | `tests/test_layout.py` | Description <= 1,024, `## Sources` + `Verified on BBj` line, check-order block byte-identical |
| Pending/ratchet state | `tests/skills_baseline.json` (written only by `--report`) | - | Removal from `pending` is the last step |
| Docs gaps for BASIS | `05-DOCS-PROPOSAL.md` (planning, not shipped) | - | D-08; no docs are edited from this repo |

## Standard Stack

No external package is installed by this phase. The "stack" is the repository's own tooling, all of which exists.

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| `tests/test_skill_examples.py` | repo (Phase 3) | Gate: fence grammar, structure lints, `bbjcpl -t -N -X`, `bbj-ls`; `--report JSON MD [ROOT]` | The success-criterion-4 oracle; `python3 -I`, stdlib only |
| `/opt/bbx/bin/bbjcpl` | BBj 26.03 (build 10-01-2026_1321) | Compile-only probes, always `-t -N -X` | Never-execute rule; `-N` is mandatory |
| `bbj-ls` at `http://127.0.0.1:5009/mcp` | BBj 26.03 | Second route (syntax only) | Gate route 2; loopback only |
| `.planning/phases/04-.../probes/run.py` + `ledger_check.py` | repo (Phase 4) | Probe runner with canary pair, `--check` reproduce; ledger consistency checker | Copy and adapt for Phase 5 (adaptation list below) |
| `tests/test_check_order.py` | repo | Pins the check-order block byte-identical | SKILL.md rewrite must keep it |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| `curl` / `python3 -I` fetch of official page files | Raw page text for DOC quotes | Always for quotes; the docs-server search splices old skill text (pitfall P2) |
| `claude plugin validate --strict` (`claude` 2.1.296 present locally) | Manifest validation | Final suite; unchanged by this phase |
| ShellCheck | Lint of shell | Not present locally; no shell is edited here |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Raw page fetch for DOC quotes | `bbj_lookup`/`bbj_search` results | Search results can carry old skill text labelled "not a citable page"; use only as a pointer to a URL |
| webforj MCP (`get_versions`, `styles_list_tokens`) | `docs.webforj.com` pages + the shipped `dwc-ui.css` | The MCP was not reachable in this session (see D-16 section); the docs pages gave the same token facts |

**Installation:** none. **Package legitimacy:** no package is added, so no legitimacy audit applies.

## Package Legitimacy Audit

No external package is installed in this phase (the skill names Shoelace, a JavaScript library, only as a subject; nothing is installed or added to a manifest). Audit not applicable.

## Inventory of the current skill

[VERIFIED: wc -l on the skill files this session]

| File | Lines | `bbj` fences | `css` fences | Notes |
|------|------:|-------------:|-------------:|-------|
| `SKILL.md` | 380 | 16 | 7 | description 1,575 characters; 1 untagged fence (the DOM tree, line 114); 12 bullets, 3 tables |
| `references/themes.md` | 139 | 5 | 3 | near-copy of DWC themes guide plus habits and a Tabler/Shoelace toggle |
| `references/shadow-dom-styling.md` | 221 | 4 | 3 | empirical workarounds (`<style>` in item 0, `adoptedStyleSheets`) |
| `references/responsive-layout.md` | 227 | 3 | 8 | generic grid/flex/media-query advice plus `pgm(-2)` stylesheet loading |
| `references/form-validation.md` | 101 | 2 | 0 | copy of the DWC form-validation guide; `BBjControlValidation` section |
| `references/running-dwc-apps.md` | 112 | 2 | 0 (2 `bash`) | registration through BBjAdminAPI; launcher flags; helper advice |
| `references/shoelace.md` | 134 | 3 | 1 (1 `bash`) | loading recipe, component table, theming map |
| `references/color-chooser.md` | 39 | 2 | 0 | no `##` section at all |

**Ledger sizing estimate** (rows = one stated fact an agent would act on; homogeneous table rows with one URL count as one row): SKILL.md about 100, themes about 35, shadow-dom-styling about 30, responsive-layout about 25, form-validation about 25, running-dwc-apps about 18, shoelace about 20, color-chooser about 12; total **about 200 to 260** [ASSUMED: estimate from reading every file this session]. Phase 4 for comparison: 151 rows, DOC 54, COMPILE 39, RUNTIME 55, OWNER 3 [VERIFIED: `python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py` printed `gate ledger_totals ok 151 rows: DOC 54, COMPILE 39, RUNTIME 55, OWNER 3; keep 21, rewrite 17, drop 106, fold 7`].

## Gate state today (priority 2)

[VERIFIED: `python3 -I tests/test_skill_examples.py --report <json> <md>` run this session, BBj 26.03, both routes live]
Output lines: `counts bbj-web-programming grammar=5 structure=8 bbjcpl=25 bbj-ls=15 should-fail=0` and `nocheck 0`. `tests/skills_baseline.json:4-15` holds exactly these counts under `pending` with `"phase": 5`.

| Cause | Blocks | Fix |
|-------|--------|-----|
| Same-line `REM` without `;` | SKILL.md:149, 172, 193, 319; responsive-layout:112, 126; themes:62; shoelace:72; shadow-dom:95 (also a `...`) | write `; rem ...`; the failing line is `error at line N (M): <statement> REM <text>` |
| `...` placeholder in a `bbj` block (grammar) | SKILL.md:51, responsive-layout:112, running-dwc-apps:33, themes:129 | replace by real code |
| Untagged fence (grammar) | SKILL.md:114 (the DOM tree) | tag it `text` (non-BBj tags are not checked) |
| Fragment is not a program: undeclared variable (`myWindow`, `window!`), `css! = css! + ...` on an undeclared variable, `File` not imported | SKILL.md:29, 86; color-chooser:31; shadow-dom:45, 112; shoelace:21; responsive-layout:208 | `declare auto <Type> name!`, `use` the class, build a complete minimal program |
| `method ... methodend` at top level (no class) | SKILL.md:328; color-chooser:7; shoelace:90 (bbj-ls: `[ClassError]`) | wrap in `class public ... classend` |
| `#this!` / `#field` outside a class | shadow-dom:126; themes:129 | class wrapper |
| `err=LABEL` with the label undefined | SKILL.md:224 (`ERR_READ_ERROR`); running-dwc-apps:33 (`login_failed`) | define the label or omit `err=` |
| Missing program for `USE ::file::` | form-validation:88 (`BBjControlValidation/ValidationBuilder.bbj`) | section is dropped (F7) |
| Structure: description 1,575 > 1,024 | SKILL.md:3 | rewrite |
| Structure: reference does not end in `## Sources` with `Verified on BBj <version>` | all 7 references | every surviving reference ends so |

The last `bbj-ls` column (15) is a subset of the same blocks (`SyntaxError`, `UndefinedLabelError`, `ClassError`); bbj-ls sees no type errors, so the 10 extra `bbjcpl` failures are all type-check errors.

## Doc evidence found (priority 3)

Tools used: the `bbj-docs` MCP tools were **not exposed in this session**; I used `curl`/`python3` fetches of `documentation.basis.cloud` page files (raw page text, not search results) and the hosted server's JSON-RPC endpoint (`resources/read` for `bbj://primer`, `tools/call` for `bbj_search`/`bbj_lookup`, read-only, no code sent). The server footer seen was `bbj-docs · hosted · docs 2026-10-09 · e43802fa`; record it in the ledger header as Phase 4 did. The webforj MCP was not reachable (`curl` to `mcp.webforj.com` gave no response); `docs.webforj.com` pages fetched fine.

URL base for BASIS pages: `https://documentation.basis.cloud/BASISHelp/WebHelp/`.

### WEB-03: the `top` parameter

| Method (page under `bui/BBjBuiManager/`) | Documented `top` text, verbatim | Source |
|---|---|---|
| `injectStyle` (`BBjBuiManager_injectStyle.htm`) | "A boolean value specifying whether this CSS is to be injected into the top level window of the page." | [CITED: documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm] |
| `injectStyleUrl` | "A boolean value specifying whether this style is to be injected into the top level window of the page." | [CITED: .../BBjBuiManager_injectStyleUrl.htm] |
| `injectScript` | "A boolean value specifying whether this script is to be injected into the top level window of the page." | [CITED: .../BBjBuiManager_injectScript.htm] |
| `injectScriptUrl` | "A boolean value specifying whether this script is to be injected into the top level window of the page." | [CITED: .../BBjBuiManager_injectScriptUrl.htm] |
| `injectLinkUrl` (**different**) | "Specifies which element the link URL will be injected into. By default, the link URL is injected into the head element. true (1) = Injects the link URL into the head element. false (0) = Injects the link URL into the body element." | [CITED: .../BBjBuiManager_injectLinkUrl.htm] |

Consequences for the rewrite: the old "`0` appends to the end of `<body>`, `1` injects into `<head>`, so use `0` to win ties" is the `injectLinkUrl` rule; for `injectStyle` the docs say nothing about head, body, default value, or cascade order [VERIFIED: the `injectStyle` page read in full this session]. Ship only the quoted meaning with the URL. The `attributes` parameter is documented ("attr=value,attr=value" or a HashMap, added to the style element), so `id=` is a documented attribute pass-through; "a stable id replaces rather than accumulates" is not documented (owner or drop). `1`/`0` are accepted where the parameter is boolean [VERIFIED: probe p09, `bbjcpl -t -N -X` clean, bbj-ls clean].

### Other DOC findings (each is a candidate DOC ledger row)

| Claim area | Documented text / fact | Source |
|---|---|---|
| `addOuterStyle` | "In BBj 22 and higher, adds a CSS class name to the outer component of a BBjTopLevelWindow." (`boolean addOuterStyle(string cssClassName)`) | [CITED: bbjobjects/Window/bbjtoplevelwindow/BBjTopLevelWindow_addOuterStyle.htm] |
| `setOuterStyle` | "In BBj 21 and higher, this method sets a CSS property on the outer component of a BBjTopLevelWindow." Also `removeOuterStyle`, `clearOuterStyles`, `getOuterStyle`, `getOuterStyles`, `getComputedOuterStyle` pages exist (HTTP 200) | [CITED: .../BBjTopLevelWindow_setOuterStyle.htm]; [VERIFIED: curl HTTP 200 on the other five pages] |
| Which classes have `setOuterStyle` | `bbj_lookup BBjChildWindow::setOuterStyle` answered: "No such method on `BBjChildWindow` ... `setOuterStyle` exists on: BBjTopLevelWindowBase." | [CITED: hosted bbj-docs server, docs 2026-10-09 · e43802fa]; compile proof in probes p03, p04 below |
| `setPanelStyle` | "In BBj 21.00 and higher, this method sets a CSS property on the content panel of a BBjWindow." and, in the GUI-to-DWC tutorial: "BBjWindow::setPanelStyle applies CSS properties to the window's content panel, which contains the window's controls." "In comparison, BBjControl::setStyle applies a CSS property directly to an individual control" | [CITED: bbjobjects/Window/bbjwindow/BBjWindow_setPanelStyle.htm; dwc/DWC_Taking_GUI_App_to_DWC.htm]. **The current skill never mentions `setPanelStyle`**; it is the documented way to style the controls' parent without naming `dwc-window-content`, but sets inline style, so it cannot carry `@media` |
| `addClass` / `setStyle` | `addClass`: "In BBj 23.00 and higher, this method adds a CSS class name to the BBjControl." "CSS settings have no effect on the GUI client." `setStyle`: "In BBj 18.00 and higher, this method sets a CSS property on the BBjControl." | [CITED: bbjobjects/SysGui/bbjcontrol/BBjControl_addClass.htm, BBjControl_setStyle.htm] |
| `setAttribute` | "This functionality is primarily intended for setting low-level BUI element attributes or DWC component attributes. When running in GUI, the attributes do not affect the control itself" | [CITED: bbjobjects/SysGui/bbjcontrol/BBjControl_setAttribute.htm] |
| `setProperty` | "In BBj 24.00 and higher, this method sets a property on the control." "The value is sent to the control in JSON string format." | [CITED: .../BBjControl_setProperty.htm] |
| Attribute vs property, Reflects, channel order | Whole guide (table, `Reflects: Yes/No`, the order dedicated method / `setAttribute` / `setProperty`) is BASIS's DWC guide; the skill section is a near-verbatim copy | [CITED: dwc.style/docs/dwc/guide/attributes-and-properties.md, raw file fetched; site URL `https://dwc.style/docs/#/dwc/guide/attributes-and-properties`] |
| `label` attribute | "In the DWC, you can create label elements by setting the "label" attribute on a BBjControl with the setAttribute method." Advantages (accessibility, clarity, maintenance, layout). "Use CSS to control label styles by targeting the part::label of the Shadow DOM on the control." | [CITED: dwc/DWC_Labels.htm] |
| Automatic Layout | "`$00100000$` Automatic Layout : Automatically arranges all controls and child windows placed in the window to fit. In the DWC client, this flag causes the window to use dynamic flow layout, ignoring all absolute control sizes and positions." Child window: same flag; "corresponds to the "GRAVITY" flag ... add a line with the keyword GRAVITY to the ARC source file". Child flags: `$00000800$` Borderless, `$00008000$` Simple ("only meaningful in the DWC client"), `$00001000$` Fieldset Element (with `$00008000$`, "emulate groupbox functionality"). No-coordinate overloads: "If the x, y, width, and height parameters are not specified, they are all initialized to 0. This is typically for use with DWC windows that dynamically arrange their contents (window creation flag $00100000$)." | [CITED: bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm; bbjobjects/Window/bbjwindow/bbjwindow_addchildwindow.htm]. The composites in SKILL.md (`$00108800$` = 0x100000 + 0x8000 + 0x800, `$00109000$` = 0x100000 + 0x8000 + 0x1000) match these bits [VERIFIED: arithmetic against the flag lines above]; the window composites `$00101093$`, `$00180013$` need decoding row by row |
| `getAvailableContext` | "Returns the next available context ID." | [CITED: bbjobjects/SysGui/bbjsysgui/bbjsysgui_getavailablecontext.htm]. SKILL.md:194 points to `bbj-programming/references/sysgui.md` for "FRESH context per window"; that file does not mention `getAvailableContext` [VERIFIED: grep this session] - dangling pointer |
| `BBjWebComponent` | "In BBj 24.00 and higher, the BBjWebComponent is a BBjControl that encapsulates a WebComponent or native HTML element in the BUI and DWC browser clients." `setCallback(String eventType, Object object, String methodName, BBjWebEventOptions options)`; "The method must take a single BBjWebEvent parameter" | [CITED: bbjobjects/Window/BBjWebComponent/BBjWebComponent.htm, BBjWebComponent_setCallback.htm] |
| `setSlot` | `BBjControl::setSlot`: "In BBj 24.11 and higher ... Syntax `setSlot( BBjControl control )`, `setSlot(String slot , BBjControl control )`" - **slot first**. Example: `button!.setSlot("prefix",icon!)`. "This method is only meaningful in the DWC client; it's ignored in all other environments." Also cleared CSS properties on an absolutely positioned child (`position`, `top`, `left`, `width`, `height`, `font`, `display`) | [CITED: bbjobjects/SysGui/bbjcontrol/BBjControl_setSlot.htm; BBjWebComponent_setSlot.htm]. The official `BBjWebComponent_setSlot` page contains a Shoelace example that loads `shoelace.js` with `injectScriptUrl(url$, top, "type=module")` |
| `setTheme` family | `setTheme`: "Specifies a DWC theme name ("light", "dark", "dark-pure"), or "system"". `setDarkTheme`/`setLightTheme`: used "when a DWC application has specified the system theme option with setTheme("system")". "Themes are only meaningful in the DWC client." | [CITED: bui/BBjBuiManager/BBjWebManager_setTheme.htm, BBjWebManager_setDarkTheme.htm, BBjWebManager_setLightTheme.htm] |
| `data-app-theme`, `--dwc-dark-mode` + `color-scheme: dark` for a custom dark theme, `:root` for light overrides, `"system"` resolution | documented in the DWC themes guide and the webforJ themes page ("Once resolved, the actual data-app-theme attribute on the page is light or dark") | [CITED: dwc.style/docs/dwc/guide/themes.md (raw); docs.webforj.com/docs/styling/themes] |
| `accept()` | "When BBj fires a BBjFormValidationEvent, it also locks the top level window from user changes. This method must be called to unlock the window." Event page: "the application program must respond to the event by calling accept(0) or accept(1) on the BBjFormValidationEvent object or the BBjButton control." "BBj 22.10+ supports client validation." | [CITED: bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm; bbjformvalidationevent.htm] |
| Client validation | `ClientValidation` implementing classes list equals the skill's list (BBjCEdit ... BBjRadioButton, 14 classes); "If the function does not contain the word "return", BBj will insert "return " at the start. If the function contains multiple lines ... it must explicitly specify a return statement." Value/text table (no `BBjInputT` row on this page) | [CITED: bbjinterfaces/IF_ClientValidation/Interface_ClientValidation.htm, ..._setClientValidationFunction.htm] |
| Built-in wins; never trust; attribute tables; `validator` attribute; `data-` prefix on the window | "Built-in validation has a higher priority than Javascript validation. In other words if a control is using both built-in and javascript validation the built-in validation will always be used." "Never trust data passed to your server from the client. Even if your form is validating correctly ... a malicious user can still alter the network request." Plus the per-control and customization attribute tables (`BBjInputT` rows live here) | [CITED: dwc.style/docs/dwc/guide/form-validation.md (raw)] |
| Registration, URL shape, `/files/` | "To run a BBj Application in the DWC client, you must register it as a web app and enable DWC deployment." "server:port/context/appname"; "The default context for DWC apps is webapp, and the default context for BUI apps is apps"; "localhost:8888/webapp/MyApp". htdocs: "saved to the htdocs directory under the basis home directory; it can be accessed with a URL in the format http://localhost:8888/files/myhtml.html" | [CITED: dwc/DWC_Registration_Launching.htm] |
| Admin API objects | `BBjAdminAppDeploymentConfiguration.createApplication()`, `getApplications()`; constants `NAME`, `PROGRAM`, `CONFIG_FILE`, `WORKING_DIRECTORY`, `BUI_ENABLED`, `DWC_ENABLED`, `WEBUI_ENABLED`, `APPLICATION_USER`, `CLASSPATH`, `DEVELOPMENT_MODE`, `DISALLOW_CONSOLE`, `OMIT_BASIS_CSS`, `SECURE`, `TERMINAL`; methods `getDwcUrl(boolean ssl)`, `getBuiUrl(boolean ssl)`, `commit()`; `BBjAdminFactory.getBBjAdmin(user, password)` and `getBBjAdmin(String p_authorizationToken)`, `getAuthToken(...)`. Not documented anywhere I found: the `"--"` config sentinel, "strip `-` from the name", `getThinClient().browse()` from a headless run | [CITED: documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentApplication.html, ...AppDeploymentConfiguration.html, ...BBjAdminFactory.html]. A second documented path exists (BBjAppConfig `setDwcEnabled`, `BBjAppServer.publish`) |
| Focus ring | Tokens: `--dwc-focus-ring-a` 0.75, `--dwc-focus-ring-width` 2px, `--dwc-focus-ring-gap` 2px; "`--dwc-focus-ring-{name}` Focus ring shadow tinted with the palette color", name one of primary, success, warning, danger, info, gray, default; "The focus ring uses a gap-ring pattern with a surface-colored inner gap and a colored outer ring." | [CITED: docs.webforj.com/docs/styling/state; dwc.style/docs/theme-engine/style.md] |
| Focus-ring padding rule | "Reserves padding around focusable elements with --dwc-focus-ring-width | The ring now has a gap. Add --dwc-focus-ring-gap to that padding, or the ring will overflow." and checklist: "If you reserve space around focusable elements with --dwc-focus-ring-width, add --dwc-focus-ring-gap to the padding." | [CITED: docs.webforj.com/docs/upgrading/webforj-26.00/design-system] - this is the DOC source for D-15's padding line |
| Shadow parts | "Inner elements of a Shadow DOM cannot be targeted directly with CSS." Parts are the way in; "All DWC components automatically expose their own parts"; `BBjListBox` parts documented: `control`, `item`, `item-active`, `item-disabled`, `item-label`, `item-prefix`, `item-selected`, `item-suffix`, `label`, `list`, `container`, `input` ... | [CITED: dwc.style/docs/theme-engine/css-shadow-parts.md; dwc.style/docs/dwc/BBjListBox.md (raw)] |
| `BBjColorChooser` | attribute list in the DWC doc has `popup`, `components`, `default-color-format`, `theme`, `value`, `hue`, `saturation`, `lightness` and **no `label`**; `saturation`: "The saturation value, which ranges 0 to 100." | [CITED: dwc.style/docs/dwc/BBjColorChooser.md (raw)]. "No `label`" is absence evidence (see P9) |
| Component attributes of the form `expanse`, `theme` | `BBjButton` `expanse`: "l" \| "m" \| "s" \| "xl" \| "xs"; `theme`: default, primary, success, warning, danger, info, gray and `outlined-*`; `label` Reflects No; `autofocus` Reflects No | [CITED: dwc.style/docs/dwc/BBjButton.md (raw)] |
| Reduced motion | "DWC respects the user's "reduce motion" accessibility preference. When enabled at the OS level, DWC disables non-essential animations across all components automatically." | [CITED: dwc.style/docs/dwc/guide/themes.md (raw)] |

### Claims with **no** doc source found (these decide the owner checklist)

- All DOM tag names and nesting: `dwc-frame`, `dwc-window-container`, `dwc-window-center`, `dwc-window-content`, `dwc-panel` as the child-window element. Searched: BASIS CSS API page (`bui/css_api.htm`, BUI-only, no `dwc-` words), BASIS DWC pages, all 57 component pages of `dwc.style/docs`, the theme-engine pages, `docs.webforj.com` [VERIFIED: grep of the fetched files for `dwc-frame|dwc-window-center|dwc-window-content|outer` found nothing relevant]. The only DWC window page (`theme-engine/dwc.md`) lists `--dwc-window-*` tokens.
- `dwc-frame` is in normal flow, `top`/`left` are no-ops on it, `transform` applies, `margin: auto` centers, BBj writes `width`/`height` inline.
- `getX()/getY()/getWidth()/getHeight()` return null on an auto-layout window and `!ERROR=252` follows.
- "HTML content in a control must start with `<html>` or it renders as literal text." The pages for `BBjControl::setText`, `addStaticText`, `BBjStaticText`, `BBjButton` contain no such sentence [VERIFIED: grep this session].
- Page CSS cannot reach a `BBjListBox` item's HTML; a `<style>` inside item 0 styles all items and dies with `removeAllItems()`; the `adoptedStyleSheets` route.
- Inline `injectScript()` of an ES module breaks relative imports (documented example uses `injectScriptUrl` with `type=module`, without the reason).
- `getClientProperty("saturation")` returns a 0-1.0 fraction (the DWC doc says "ranges 0 to 100": a conflict, not a confirmation).
- "`bbj -q app.bbj` launches the ThinClient" (searches return only the old skill text, labelled not citable).

### Conflicts between sources (do not ship either side without the owner)

1. `dwc.style` attributes guide: "GUI, BUI, and WebUI have no concept of attribute or property customization - the calls are no-ops there." vs the BASIS `setAttribute` page: "primarily intended for setting low-level BUI element attributes or DWC component attributes." The skill copies the first sentence. Ship the BASIS page's wording only.
2. D-15 / SKILL.md say the ring is an `outline` with `outline-offset`; the docs and the shipped CSS say a shadow pair (see "DWC version" section).
3. `BBjColorChooser` saturation range: skill 0-1.0 (empirical) vs DWC doc 0-100.

## Primer overlap (priority 5)

`bbj://primer` was read in full this session via the hosted server's `resources/read` (40,981 characters, 8 chapters) [VERIFIED: read]. It contains almost nothing about browser work. The overlaps:

- **gotchas/20**: "In control text a single `&` marks the keyboard hot key ... A literal `&` is written `&&`, including the `&` of an HTML entity: `"Price &&mdash; $199"`." Source `events/keyboard_focus_navigation_and_default_button.htm`. This is exactly the skill's `&&` trap with the same example: **cut by D-02**.
- **modern_bbj/5**: "For new client-facing UI work, target DWC (Dynamic Web Client) ... supports responsive CSS layouts and theming" (source `dwc/DWC_Overview.htm`). Overlaps the skill's one-line framing only; no rule to cut beyond that framing.
- Paragraph 323 (`#this!` and `#field` inside a class) and 383 (`setCallback` on the object, with `#this!`) cover the class-callback mechanics used by the web-component event example; they are not web rules.
- No primer paragraph on `setAttribute`, `getWebManager`, `injectStyle`, themes, Automatic Layout, `setSlot`, validation, `accept` [VERIFIED: grep of the primer text].

## DWC version for BBj 26.03 (D-16, priority 4)

- BBj 26.03's release notes (`/opt/bbx/relnotes.htm`, read this session) say: "BBj 26.00 introduces a refreshed design system for DWC. To see what specifically changed, go to Upgrading to the v26 Design System." [VERIFIED: the sentence in the install's relnotes]. The linked guide (`dwc.style/docs/#/theme-engine/upgrading-to-v26`) has the same content as `docs.webforj.com/docs/upgrading/webforj-26.00/design-system` ("DWC 26 introduces a refreshed design system") [CITED]. The DWC Design Kit page says "Use it with webforJ 26 or later and BBj 26 or later." [CITED: dwc.style/docs/theme-engine/design-kit.md].
- **Pin to record in the ledger: "DWC 26 (v26 design system), shipped with BBj 26.03 build 10-01-2026_1321".** There is no finer DWC version string in the install: the bundle `/opt/bbx/htdocs/basis/components/dwc-ui.esm.js` has no version text, files dated Sep 22 [VERIFIED: ls and grep this session]. The webforj MCP `get_versions` could not be called; if the user wants a patch-level pin, the owner can read it in the browser during the owner session [ASSUMED: that devtools shows a DWC build string].
- Static cross-check (triage aid, not an evidence class): the 26.03 `dwc-ui.css` defines `--dwc-focus-ring-a`, `--dwc-focus-ring-width`, `--dwc-focus-ring-gap` and the seven `--dwc-focus-ring-{primary,success,warning,danger,info,gray,default}` and builds them as `0 0 0 var(--dwc-focus-ring-gap) var(--dwc-surface-1), 0 0 0 calc(var(--dwc-focus-ring-gap) + var(--dwc-focus-ring-width)) oklch(...)` - a shadow pair; the file has no `outline-offset` rule near them [VERIFIED: regex over `/opt/bbx/htdocs/basis/components/dwc-ui.css`]. Of the 41 `--dwc-*` names in the current skill, three are **absent** from that CSS: `--dwc-shadow-2` (the shadow tokens are `-xs -s -m -l -xl -2xl`), `--dwc-color-on-surface`, `--dwc-font-family-serif` [VERIFIED: same scan]. All three live in taste/shoelace text that is cut anyway, but a token-trace step in the rewrite (each `--dwc-*` in a kept block traces to a ledger row, D-17) will catch this class of error.
- The BBj client JavaScript in the install mentions `dwc-window-center,dwc-mdi-center` (`/opt/bbx/htdocs/basis/messages/SetMenuBarMessage.js:251`) and `dwc-window-center,dwc-child-center,dwc-panel,fieldset[is="dwc-fieldset-panel"]` (`BuildTabPanelMessage.js:454`) [VERIFIED: grep -n]; `dwc-frame`, `dwc-window-content` and `dwc-window-container` appear in no static file under `/opt/bbx/htdocs`. This corroborates `dwc-window-center` and `dwc-panel` exist and suggests a child-window fieldset form; it proves nothing about nesting and **is not evidence** under the four classes. Whether such static reading may count for anything is Open Question 1.

## Owner-checklist candidates (priority 3, D-05/D-06)

Triage rule from D-06: keep a claim only if an agent would get it wrong without it. "Static" = what I found in the install without running anything. The executor still decides; none of this is granted OWNER.

| # | Claim (to quote exactly in the checklist) | Worth keeping? | Static / doc hint | Repro for the owner (gate-passing program, devtools step) |
|---|---|---|---|---|
| O1 | `addClass()` on a `BBjTopLevelWindow` puts the class on `dwc-window-center`; `addOuterStyle()` puts it on `dwc-frame` | yes (the "my window CSS half-applies" cause) | `dwc-window-center` string found in client JS; `dwc-frame` not found; docs say only "outer component" | window with both calls; Elements panel: which element carries each class |
| O2 | `dwc-frame` is in normal flow: `top`/`left` do nothing, `transform` applies, `margin: auto` centers, BBj sets `width`/`height` inline (so `!important` is needed) | yes (reflex centering idiom is wrong) | none | window with `addOuterStyle("c")` plus a stylesheet; Computed panel for `position`, inline style |
| O3 | The controls of a top-level window sit in `dwc-window-content`; a `BBjChildWindow` is a `dwc-panel` with no content wrapper | yes (it decides where a class-based grid goes) | `dwc-panel` found in client JS; `setPanelStyle` is the documented inline-style route to the "content panel" | one top-level + one child window with a visible class; Elements panel |
| O4 | `setOuterStyle` takes a property and value and sets an inline style on the outer component; `addOuterStyle` takes a class | no - DOC already: the pages say so | pages | drop from the checklist |
| O5 | A list box item's HTML sits in a shadow root: a page selector (class, tag, attribute) does not reach it; inline `style=` does | maybe (agents try class selectors) | DOC says shadow DOM blocks selectors and lists `item` / `item-selected` parts | list box with three styled items; Elements panel, `#shadow-root` |
| O6 | A `<style>` inside item 0 styles all items and is lost on `removeAllItems()`; `adoptedStyleSheets` survives it | no - workaround/taste (D-14); cut unless the owner volunteers it | none | - |
| O7 | The focus ring is clipped by an `overflow: hidden` or `overflow: auto` ancestor, and padding of `calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap))` avoids it (D-15) | yes (the explicit WEB-01 item) | padding line is DOC (upgrade guide); clipping not documented; ring is a shadow in 26 | edit box inside a scrolling child window, Tab to it, with and without the padding; devtools shows the `box-shadow` on `:focus-visible` |
| O8 | HTML text in a control must start with `<html>` or it shows as literal text | yes (no doc found; agents hit it) | none | static text with and without the prefix |
| O9 | `getX()/getY()/getWidth()/getHeight()` return null on an Automatic Layout window | yes only as a compile-free fact; `!ERROR=252` wording is RUNTIME - owner can confirm the null, the error number is dropped unless confirmed | none | one print of `getWidth()` result |
| O10 | `BBjColorChooser` ignores `setAttribute("label", ...)` | maybe (color-chooser.md is a fold candidate; 1 line) | DWC attribute list has no `label` | colour chooser plus a label attribute; whether a caption appears |
| O11 | `getClientProperty("saturation")` is a 0-1.0 fraction | maybe (conflicts with the DWC doc "0 to 100") | doc says 0-100 | `print` the value after a change event |
| O12 | `injectStyle(css, 0)` vs `(css, 1)` places the `<style>` element at a different DOM position | optional - D-18 says beyond-docs placement goes to the checklist or is dropped; the corrected claim needs none of it | none | style element location in the Elements panel (one check, same program) |
| O13 | Inline `injectScript()` of an ES module that imports relative chunks fails; loading by `injectScriptUrl` works | optional - the shipped sentence can instead state the documented Shoelace example | docs example uses `injectScriptUrl(..., "type=module")` | console error |

The owner program set should be generated as files under the phase directory (for example `owner-repros/o01_*.bbj`), each compiled with the probe runner so "gate-passing" is true on both routes before the session. The checklist needs one field per item for confirm/reject, the DWC build (as read in the browser) and the BBj build.

## Cross-skill and repository integration (priority 6)

- **README/docs/CHANGELOG** mention only the skill name (`README.md:6`, `README.md:47`, `CHANGELOG.md:9`, `CHANGELOG.md:41`); no file in the repository outside the skill names a web reference file by name [VERIFIED: `grep -rn` for the seven reference names, excluding `.planning` and the skill directory, printed only those lines]. Deleting or merging references needs no doc edit. The Codex installer copies the skills directory wholesale (`tests/test_install_codex.sh:391-445` checks only `bbj-programming/SKILL.md`).
- **Links out of the web skill**: `SKILL.md:20` names the bbj-programming skill; `SKILL.md:194` points to `bbj-programming/references/sysgui.md` (dangling for `getAvailableContext`, see above); `references/form-validation.md:3` points to `bbj-programming` `references/callback-performance.md`, which exists (40 lines) and **already states the `accept()` rules with the same page**: callback must call `accept()`, `accept(1)` fires the button push, `accept(0)` rejects, `reject(0)` fails `bbjcpl -t`. So D-12's first trap should be a pointer (or one sentence) rather than a second copy.
- **Links into the web skill**: none from `bbj-programming` except its description ("For browser work (DWC/BUI, HTML, CSS) also use the bbj-web-programming skill.") [VERIFIED: grep]. The finished Phase 4 skill is not edited (D-11).
- **`running.md` target** (`plugins/bbj/skills/bbj-programming/references/running.md`, 55 lines) documents `-q`, `-WD<working directory>`, `-t`, `-c` with quotes; D-11's pointer is correct. Its first lines say to read it "only when the user asks to run a BBj program".
- **Tests that touch skill files**: `tests/test_skill_examples.py` (gate; `KNOWN_PENDING = {"bbj-programming": 4, "bbj-web-programming": 5}` at line 129 is a constant and is **not** edited to remove pending; only `tests/skills_baseline.json` changes, as in commit `6d0d8ad`), `tests/test_check_order.py` (check-order block in `SKILL.md` placement directly after the frontmatter before the H1), `tests/test_layout.py` (`DOCS_HOST = "mcp.bbj-ai.com"` at line 21; the host may occur only in `plugins/bbj/.claude-plugin/plugin.json` - cite other hosts freely; no skill file is executable). Denylist strings never to appear in skill files: `DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin/` (CONTEXT code_context).
- **Non-BBj fences are not checked**: `NON_BBJ = ("css", "html", "js", "json", "bash", "sh", "text", "xml")` at `tests/test_skill_examples.py:130`. The current untagged DOM-tree fence must become `text`.
- **`human_verify_mode`** is `"end-of-phase"` at `.planning/config.json:32`, but D-07 requires a *blocking* `checkpoint:human-verify` before the rewrite. The plan must say blocking explicitly so an auto-advance run does not defer it.
- **Ratchet**: a lower count than the baseline is `ok` (message "lower the baseline with --report"), not a FAIL [VERIFIED: `tests/test_skill_examples.py:530`]. So interim plans need not touch `tests/skills_baseline.json`; only the finishing plan runs `--report`, and the skill leaves `pending` when all counts reach 0 (Phase 4 did the same in `6d0d8ad`).

## Architecture Patterns

### System Architecture Diagram

```text
   BASIS docs pages          dwc.style / docs.webforj.com        /opt/bbx install (static files)
   (curl, raw page text)     (raw .md / pages)                   dwc-ui.css, client JS  [triage only]
          |                          |                                     |
          +------------+-------------+-------------------------------------+
                       v
  probes/ (compile only: bbjcpl -t -N -X + loopback bbj-ls)  ---->  probes/OUTPUT.txt
                       |                                              |
                       v                                              v
        05-LEDGER.md  (one row per rule: DOC | COMPILE | RUNTIME | OWNER, verdict, route)
                       |                         ^ ledger_check.py (adapted)
          undocumented, worth keeping
                       v
        05-OWNER-CHECKLIST.md + owner-repros/*.bbj   --->   BLOCKING human-verify (owner, real BBj/DWC)
                       |                                              |
                       |        confirmed -> OWNER rows + 05-CONTEXT.md D-nn "OWNER-confirmed" bullets
                       v                                              v
   rewrite SKILL.md (check-order block first, description <= 1,024)   rewrite/merge/delete references
                       |                                              |
                       +-----------------+----------------------------+
                                         v
        gate: BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py  + test_check_order.py
                                         v
        --report regenerates tests/skills_baseline.json -> skill leaves `pending`
        05-DOCS-PROPOSAL.md (not shipped)  <- OWNER rows + docs-silent gaps
```

### Recommended file layout (planning side)

```text
.planning/phases/05-bbj-web-programming-makeover/
├── 05-LEDGER.md              # base commit, BBj 26.03, docs server footer, DWC pin; sections SKILL.md, references/<name>.md (alphabetical), New rules
├── ledger_check.py           # adapted copy of the Phase 4 checker
├── probes/                   # run.py (copy), OUTPUT.txt, README.md, <id>_<name>.bbj
├── owner-repros/             # o01_*.bbj ... gate-passing programs for the owner session
├── 05-OWNER-CHECKLIST.md
└── 05-DOCS-PROPOSAL.md       # not shipped
```

### Adapting `ledger_check.py` (Phase 4 version, 319 lines)

[VERIFIED: read `.planning/phases/04-bbj-programming-makeover/ledger_check.py`]
- `SKILL_DIR` (line 32) -> `plugins/bbj/skills/bbj-web-programming`; ledger and context file names `04-*` -> `05-*` (lines 28-30, the `grant 04-CONTEXT\.md D-nn` regex at line 48, the OWNER message strings, and the `OWNER_RE`/evidence text).
- `DOC_PREFIX` (line 33, a single prefix tested with `in` at line 246): DOC rows must now also accept the D-16 hosts. Make it a tuple of allowed prefixes: `https://documentation.basis.cloud/`, and (only after A1 is confirmed) `https://dwc.style/docs/` and `https://docs.webforj.com/docs/`. Note `documentation.basis.cloud/Javadoc/...` is outside `.../BASISHelp/WebHelp/`; the old prefix would reject it.
- OWNER rows: the checker requires a `- **D-nn:**` line in the phase CONTEXT file that contains `OWNER-confirmed` (lines 270-281). The current 05-CONTEXT.md D-01..D-18 has none; the owner checkpoint plan must append such bullets (one per confirmed claim or batch, with name, date, DWC and BBj build) before any OWNER row validates. Reserve D-19 onward.
- Files covered: `git ls-tree` at the base commit over the new skill directory; the base commit is the current HEAD at ledger time (the skill dir last changed in `18d60a1`).
- Section titles: `SKILL.md`, `references/<name>.md` alphabetical, `New rules`. With 7 references the order is: color-chooser, form-validation, responsive-layout, running-dwc-apps, shadow-dom-styling, shoelace, themes.

### Rewrite shape (from the finished Phase 4 skill)

[VERIFIED: read `plugins/bbj/skills/bbj-programming/SKILL.md` head and tail this session; 158 lines]
Frontmatter (`name` unchanged) -> check-order block directly after it and before the H1 -> a two-sentence intro ("Read `bbj://primer`; this file adds to it ...") -> `##` rule sections, each opening with `Page: <URL>` or an inline URL -> `## Look it up instead` (docs-tool pointers) -> `## References` index. Each reference: `Page:` line(s), bullet rules, minimal blocks, ending `## Sources` with URLs and a `Verified on BBj 26.03` line. The description there is trigger-first: "Write, review, check, or fix BBj code ... Use for ... Trigger on symptoms without BBj being named: ...", and its last sentence points to the sibling skill. For the web skill the surviving topic set (by this research) is: inject* and the `top` meaning, `addClass`/`addOuterStyle`/`setPanelStyle`, `setAttribute`/`getAttribute`/`setProperty`/`getProperty`, the `label` attribute, Automatic Layout `$00100000$` and the child-window composites, themes, form validation (`accept`, client validation), `BBjWebComponent`/`setSlot`, DWC registration and URL shape, focus-ring padding, shadow parts. Symptom triggers are allowed only for surviving topics (D-04).

### Anti-Patterns to Avoid
- **Citing the docs server's search hits as DOC.** It splices the old skill text into pages labelled "not a citable page" and even under an official URL (the `BBjControl_setAttribute.htm` search hit returned the skill's own "Web components" section). Quote raw page files only (P2).
- **Hedging a rejected owner claim.** D-07: dropped, never hedged.
- **Copying doc tables.** D-12 and D-04: a docs URL replaces the tables.
- **Two plans lowering `tests/skills_baseline.json` in parallel** (same file; see plan split).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Ledger consistency | a new checker | adapt Phase 4's `ledger_check.py` | 17 gates already encode ids, classes, DOC URL, probe existence, OWNER grants, totals |
| Compile evidence | ad hoc `bbjcpl` calls | adapt `probes/run.py` (batched `-t -N -X`, canary pair, `--check`) | the canary pair detects a dead compiler; `--check` reproduces OUTPUT.txt |
| Draft verification | editing the shipped skill while iterating | scratch-root dry run (recipe in the Phase 4 `probes/README.md`) | copy `plugins/bbj/skills` and an empty-`pending` baseline; run `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py ROOT` |
| Baseline | hand-edited counts | `python3 -I tests/test_skill_examples.py --report JSON MD` | "written only by --report, never by hand" (module docstring) |
| Token existence | a new `--dwc-*` lint | grep each token against the cited docs page during the ledger (and optionally the install's `dwc-ui.css` as triage) | the lint was explicitly deferred (D-17, Deferred Ideas) |
| Check-order block | retyping it | copy the block byte for byte from the current SKILL.md (lines 6-14); `tests/test_check_order.py` pins it | any drift fails |

## Common Pitfalls

### P1: D-15 says "outline"; the docs say shadow
**What goes wrong:** the rewrite repeats the old "outline ... outline-offset" mechanism. **Why:** the old text and CONTEXT D-15 predate the v26 design system; DWC 26 builds the ring from `box-shadow` values and the docs call it a "Focus ring shadow". **Avoid:** state only "a focus ring is drawn around the focused control; padding of `calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap))` is documented" and quote the docs' words; keep clipping by `overflow` ancestors as the owner item O7. Raise the wording change with the user in the plan (Open Question 3). **Warning sign:** the words `outline` or `outline-offset` in the shipped file.

### P2: The docs server serves the old skill as if it were a page
**What goes wrong:** a "DOC" row cites a search hit that is the skill's own text. **Avoid:** fetch the page file and quote its body (`curl` + tag stripping, or `WebFetch`); check the quote occurs in the raw page. Phase 4 verification had to re-fetch pages for the same reason (04-07 closed four files that "say more than their sources").

### P3: A kept sentence says more than its source
The 04-VERIFICATION gap (`WR-01`, `IN-01`..) came from wording that went beyond the page. For each DOC row, the shipped sentence must be the quoted sentence or a strict restatement; "silently", "always", "never" and numbers (`!ERROR=252`) need their own source.

### P4: Fragments are not programs
25 of the gate failures are fragments (undeclared `window!`, `css!`, top-level `method`, `#this!`). Every kept block must be a minimal complete program: `declare auto <Type> name!` for each object variable (type-check needs the type to resolve `getAttribute` and friends: `themeName$ = button!.getAttribute("theme")` fails when `button!` is undeclared, passes when typed), `use` for imports, classes for callbacks.

### P5: Same-line comments and placeholders
`REM` at the end of a statement line is a syntax error; use `; rem`. The grammar lint also rejects `...` in a `bbj` block, including in a comment (`REM ...on navigation:`).

### P6: The `setSlot` argument order
Docs: `setSlot(String slot, BBjControl control)` (slot first). The skill has `el!.setSlot(child!, "footer")` and `card!.setSlot(badge!, "footer")`. With typed variables `bbjcpl -t` rejects the reversed order (probe p02) and accepts the documented order (p01). bbj-ls passes both, so a `should-fail` pair for this trap fails on `bbjcpl` only, which the gate accepts (Phase 3 D-08).

### P7: `setOuterStyle` is not on `BBjChildWindow`
The skill says "only valid on BBjTopLevelWindow/BBjChildWindow ... on a BBjButton it is a syntax error". Compile: `BBjChildWindow.setOuterStyle` and `.addOuterStyle` fail with `No match for method`; `BBjButton.setOuterStyle` fails with a **type check error**, not a syntax error (probes p03-p05, bbj-ls passes all three). The docs name only `BBjTopLevelWindow` (and the lookup says `BBjTopLevelWindowBase`).

### P8: `top` has a different meaning per method
Do not generalise from `injectLinkUrl` to `injectStyle` or back; list the four methods that share the "top level window" wording and `injectLinkUrl` separately.

### P9: Absence is not evidence
"BBjColorChooser has no `label` attribute" rests on an attribute list that omits it, and "no page says `<html>` is needed" rests on pages that are silent. Neither earns DOC or `[VERIFIED]`; the first can only be stated as "the attribute list at <URL> does not list `label`" or go to the owner. Same for the `ThinClient` claim.

### P10: A docs claim can be wrong for BBj even when the DWC guide states it
The `dwc.style` guide is BASIS's text, but it conflicts with BASIS's `setAttribute` page on BUI behaviour. Prefer the BBj object page for BBj API facts, the DWC guide for component facts.

### P11: Ratchet order
Only the finishing plan writes `tests/skills_baseline.json`; if it is written earlier, a later plan that raises a count (e.g. adds a reference without `## Sources`) is silently allowed to fall back. Run the gate after every task; run `--report` once at the end.

### P12: Never run BBj
Compile with `-t -N -X` only; never call `bbjcpl` without arguments (it waits on stdin: an accidental no-argument call during this research hung and had to be killed); never run a program. The owner repro programs are compiled only; the owner runs them.

## Code Examples

All compiled this session with `/opt/bbx/bin/bbjcpl -t -N -X` in a scratch directory outside the repository; no program was run.

### Slot order: the documented form, and the should-fail pair for the trap
```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
declare auto BBjWebComponent card!
declare auto BBjWebComponent badge!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("t", $00100083$)
card! = win!.addWebComponent("sl-card")
badge! = win!.addWebComponent("sl-badge")
card!.setSlot("footer", badge!)
```
[VERIFIED: probe p01 clean on bbjcpl and bbj-ls]. The reversed line `card!.setSlot(badge!, "footer")` gives `type check error [No match for method com.basis.bbj.proxies.sysgui.BBjWebComponent.setSlot(com.basis.bbj.proxies.sysgui.BBjWebComponent, BBjString)]` on bbjcpl, clean on bbj-ls [VERIFIED: probe p02].

### Outer-style placement: what exists where
`win!.addClass("login")`, `win!.addOuterStyle("login-frame")`, `win!.setOuterStyle("opacity", "0")`, `win!.setPanelStyle("display", "grid")` on a `BBjTopLevelWindow` compile clean [VERIFIED: probe p06]; `panel!.setOuterStyle(...)` and `panel!.addOuterStyle(...)` on a `BBjChildWindow`, and `b!.setOuterStyle(...)` on a `BBjButton`, each fail `No match for method` [VERIFIED: probes p03, p04, p05].

### A web-component event callback that passes (class wrapper, typed options)
```bbj
class public Demo
    field private BBjWebComponent el!

    method public Demo(BBjTopLevelWindow win!)
        #el! = win!.addWebComponent("sl-rating")
        declare auto BBjWebEventOptions options!
        options! = #el!.newEventOptions()
        options!.addItem("value", "event.target.value")
        #el!.setCallback("sl-change", #this!, "onChange", options!)
    methodend

    method public void onChange(BBjWebEvent event!)
        val! = str(event!.getEventMap().get("value"))
    methodend
classend
```
[VERIFIED: probe q01 clean on both routes]

### DWC registration that passes (`use` plus `declare auto`, no dangling label)
```bbj
use com.basis.api.admin.BBjAdminFactory
use com.basis.api.admin.BBjAdminBase
use com.basis.api.admin.BBjAdminAppDeploymentConfiguration
use com.basis.api.admin.BBjAdminAppDeploymentApplication

declare auto BBjAdminBase admin!
declare auto BBjAdminAppDeploymentConfiguration config!
declare auto BBjAdminAppDeploymentApplication app!

admin! = BBjAdminFactory.getBBjAdmin("admin", "admin123")
config! = admin!.getRemoteConfiguration()
app! = config!.createApplication()
app!.setString(app!.NAME, "MyApp")
app!.setString(app!.PROGRAM, "/abs/path/MyApp.bbj")
app!.setBoolean(app!.DWC_ENABLED, 1)
app!.commit()
url$ = app!.getDwcUrl(0)
release
```
[VERIFIED: probe q04 clean on both routes]. The literals `admin`/`admin123` are the Javadoc sample's; in the shipped file use obviously fake placeholders and do not copy credential-looking strings (Security Domain).

### Frontmatter and check for the description limit
`description` must be at most 1,024 characters after YAML unfolding (the lint measures characters). Count with `python3 -I -c` against the parsed value, or simply run the gate. The current value is 1,575 characters [VERIFIED: gate report `SKILL.md:3 description is 1575 characters (limit 1024)`].

## Proposed plan split (priority 7)

Constraint chain (D-07): ledger -> **blocking owner checkpoint** -> rewrite -> baseline removal last. Phase 4 used 8 plans in 7 waves; Phase 5 needs fewer rows of compile evidence but a human step.

| Plan | Wave | Autonomous | Content | Depends on |
|------|-----:|:----------:|---------|-----------|
| 05-01 | 1 | yes | `probes/` : adapt `run.py`, write probes for every COMPILE fact (setSlot order p01/p02, outer-style placement p03-p06, getAttribute typing p07/p08 with and without declared types, injectStyle int `top` p09, getAvailableContext p10, class-wrapped callbacks q01, panel style q02, registration q03/q04), `OUTPUT.txt`, `README.md`; requirement WEB-01 (COMPILE half) | - |
| 05-02 | 2 | yes | `05-LEDGER.md` for SKILL.md and 7 references plus New rules, adapted `ledger_check.py`; DOC quotes taken from raw pages; D-16 pin recorded in the header; triage output: the O-list with keep/drop decisions (D-06) | 05-01 |
| 05-03 | 3 | yes | `05-OWNER-CHECKLIST.md` and `owner-repros/*.bbj` (compile-checked on both routes before the session, never run by Claude); each item: exact claim, program, devtools step, confirm/reject, DWC build, BBj build | 05-02 |
| 05-04 | 4 | **no** (`checkpoint:human-verify`, blocking) | the owner session; the executor records outcomes: OWNER rows, rejected claims dropped, `05-CONTEXT.md` D-19+ "OWNER-confirmed" bullets, `ledger_check.py` green | 05-03 |
| 05-05 | 5 | yes | SKILL.md rewrite (check-order block untouched, description, body about 150 lines, `top` meaning, reference index) | 05-04 |
| 05-06 | 5 | yes | references: rewrite survivors, merge/fold/delete per D-09 (the `color-chooser` fold, a possible `themes` + `shadow-dom-styling` merge), `## Sources` + `Verified on BBj 26.03` on each | 05-04 |
| 05-07 | 5 | yes | `05-DOCS-PROPOSAL.md` (every OWNER claim and every docs-silent gap: DOM structure, `top` wording, `getX` null, `<html>` prefix, ColorChooser saturation, BUI no-op sentence conflict) | 05-04 |
| 05-08 | 6 | yes | finish: re-run all ledger/gate checks, link-resolution and taste-word scans, `--report` regenerating the baseline so the skill leaves `pending` in the same commit as the last deletion, full suite | 05-05, 05-06, 05-07 |

Notes: 05-05 and 05-06 touch disjoint files and neither writes `tests/skills_baseline.json` (P11), so they can share a wave; the SKILL.md reference index needs the survivor list, which is fixed by 05-04. If the ledger leaves many references alive, split 05-06 in two (themes/shadow/responsive; form-validation/running/shoelace/color-chooser). A Phase 4-style gap-closure plan (04-07/04-08) should be expected after verification; leave wave room.

## Runtime State Inventory

This is a rewrite with deletions, not a rename, so the inventory is short. Answers are explicit.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None - the skill is Markdown; no database or datastore holds a reference name [VERIFIED: grep for the reference file names outside the skill directory found no hit] | none |
| Live service config | None - no external service names the references | none |
| OS-registered state | None | none |
| Secrets/env vars | None; the `BBJ_SKILLS_LIVE`, `BBJ_TEST_HOME`, `BBJ_LOCAL_MCP_URL` variables are read by the gate and unchanged | none |
| Build artifacts / installed copies | Users with the Codex installer have an installed copy of the old skill under `~/.agents/skills`; the installer does not overwrite without `--force`. Claude Code users get the plugin cache on update | covered by REL-02 (Phase 6 upgrade notes); no action in this phase |

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| v25 DWC: focus ring reserved padding = ring width; ripple feedback | v26: ring with a gap (`--dwc-focus-ring-gap`), press = scale-down | DWC 26, in BBj 26.00 | padding must add the gap; token set above is the 26 set |
| `-c` contrast tokens, HSL palette flip in dark mode | `--dwc-color-{name}-seed`, OKLCH, `--dwc-dark-mode` | DWC 26 | `themes.md` statements about palette steps (e.g. `--dwc-color-primary-80` as a light primary) are v25 behaviour: the v26 guide says step 5 is always darkest and steps are no longer mode-flipped; do not ship step semantics without a v26 source |
| Named font-size tokens | scale shifted down one bucket (`m` is 14px) | DWC 26 | `--dwc-font-size-l`-style advice changes meaning |

**Deprecated/outdated:** the skill's claim "`--dwc-color-primary-80` is a light primary, `--dwc-color-primary-20` a much darker one" is still true as lightness ordering under v26 (step 5 darkest, 95 lightest) [CITED: the v26 upgrade guide], but "the palette flips in dark mode" is not. Check any step-number sentence against the v26 guide before it survives.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `dwc.style/docs` (BASIS's own DWC docs, "Built by BASIS International Ltd", linked from documentation.basis.cloud pages) and `docs.webforj.com` count as D-16 DOC sources | Doc evidence; ledger_check adaptation | If the user does not accept `dwc.style`, the attribute/property, themes and form-validation rows (most of three files) lose their DOC source and become OWNER or drop; this is the biggest swing in the phase |
| A2 | "DWC 26 (v26 design system)" is a sufficient D-16 build pin for BBj 26.03 | DWC version | The user may want a patch-level DWC build; the owner session would have to read it from the browser |
| A3 | Ledger will have about 200 to 260 rows | Inventory | Plan 05-02 could be undersized; split by file group if it runs over |
| A4 | Static reading of the install's `dwc-ui.css` and client JS is only a triage aid and not evidence | DWC version; owner candidates | If the user accepts it as a fifth class, O1/O3 partly resolve without a session; do not assume |
| A5 | The owner is reachable for one blocking session mid-phase and will run the repro programs on a real BBj with a browser | Plan split | If not, 05-05..05-08 cannot start; the DOM/CSS rules would all be dropped |
| A6 | Devtools shows a DWC build string the owner can record | DWC version | The owner would record only the BBj build |
| A7 | The estimate "about 200-260 rows" and the per-file counts | Inventory | sizing only |
| A8 | `docs.webforj.com` v26 pages describe the same token set as the shipped 26.03 bundle | Doc evidence | Partly mitigated: the focus-ring and size/shadow tokens were checked against the shipped CSS; other tokens in kept blocks need the same trace |

## Open Questions

1. **Does a static look into the install's shipped DWC files count as anything?**
   - What we know: `dwc-ui.css` confirms token names and shows the ring as a shadow; the client JS names `dwc-window-center` and `dwc-panel`.
   - What's unclear: the four evidence classes (DOC, COMPILE, RUNTIME, OWNER) have no slot for it.
   - Recommendation: keep it as triage only (A4) unless the user adds a class; it can shrink the owner checklist but must not replace it.
2. **Is `dwc.style/docs` DOC for D-16?** (A1) Recommendation: yes, and cite the site URL form `https://dwc.style/docs/#/dwc/guide/form-validation` plus the guide name; the raw `.md` URL is how it was read.
3. **D-15 wording.** D-15 says "DWC draws focus as an outline outside the border box". The 26 docs and CSS say a gap-ring shadow. Recommendation: reword D-15 to the documented text in the plan, keep the clipping item as the owner check, and tell the user in the plan summary.
4. **Where does the `accept()` trap live?** It is already in `bbj-programming/references/callback-performance.md`. Recommendation: one sentence plus pointer in the web skill (cheaper than a copy; D-12 allowed).
5. **`bbj` launches the ThinClient** (D-11): no citable page. Recommendation: keep only "register the app and open its URL in a browser" (DOC) and drop the ThinClient sentence unless the owner confirms; D-06 allows dropping it without asking.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `bbjcpl` | probes, gate | yes | BBj 26.03 build 10-01-2026_1321 (`/opt/bbx/documentation/build.info`) | none (gate skips without it; `BBJ_SKILLS_LIVE=1` makes it fail) |
| `bbj-ls` loopback | probes, gate | yes (answered all probe posts: `No errors found. Checked against the local installation's PREFIX, classpath and config (BBj 26.03).`) | 26.03 | gate route 2 |
| `python3` | tests, scripts | yes | 3.14.4 | - |
| `curl` / `node` | page fetch; CI CLI | yes / yes | - | - |
| `claude` CLI | `claude plugin validate --strict` | yes | 2.1.296 (CI pins 2.1.293) | CI only |
| ShellCheck | `tests/ci.sh` | no | - | not needed for this phase (no shell edited) |
| Hosted docs server `https://mcp.bbj-ai.com/mcp` | primer, `bbj_lookup` | yes (raw JSON-RPC worked; MCP tool binding was not exposed) | `bbj-docs` 1.2.0, docs 2026-10-09 · e43802fa | `curl` on `documentation.basis.cloud` |
| webforj MCP (`get_versions`, `styles_*`) | D-16 | no (no response) | - | `docs.webforj.com` pages and `dwc.style` raw files |
| A real BBj + browser for the owner session | O1-O13 | owner's machine | - | none; claims not confirmed are dropped (D-07) |

**Missing dependencies with no fallback:** the owner session itself (a human step).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Repository gate-line harness: `tests/run.sh`, `python3 -I tests/test_*.py`, `sh tests/test_*.sh`; no third-party framework |
| Config file | `tests/skills_baseline.json` (pending list, ratchet counts, written only by `--report`) |
| Quick run command | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py && python3 -I tests/test_check_order.py` (about 12 s) |
| Full suite command | `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` (about 80 s; Phase 4 validation file) |

### Phase Requirements -> Test Map
| Req ID / criterion | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SC1 / WEB-01 | ledger covers the skill and all 7 references; each DOC row cites an accepted docs URL; COMPILE rows name existing probes; OWNER rows name a CONTEXT grant; every file at the base commit has a row | unit | `python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py` | no, Wave 0 (adapt from 04) |
| SC1 / WEB-01 | probes reproduce | unit | `python3 -I .planning/phases/05-bbj-web-programming-makeover/probes/run.py --check` | no, Wave 0 |
| SC1 / WEB-01 | no DOM tag name or CSS token ships without a ledger row | scan | `grep -rnoE 'dwc-[a-z-]+\|--dwc-[a-z0-9-]+' plugins/bbj/skills/bbj-web-programming` then compare the names to ledger rows (task verify, executor-run) | n/a (no new lint, D-17) |
| SC2 / WEB-02 | description <= 1,024, body short | gate | `python3 -I tests/test_skill_examples.py` (structure lint `description is N characters`) and `wc -l plugins/bbj/skills/bbj-web-programming/SKILL.md` (about 150 body lines, the Phase 4 file is 158 total) | yes |
| SC2 / WEB-02 | triggers first in the description | review | description starts with "Write, ..." / "Use for ..." then symptoms; check by reading | manual (one line) |
| SC2 / WEB-02 | taste cut | scan | `! grep -rniE 'gsap\|swiper\|tabler\|playfair\|google fonts\|fonts\.googleapis\|420px\|\bInter\b\|PT Serif\|Roboto Mono' plugins/bbj/skills/bbj-web-programming` | yes (command only) |
| SC3 / WEB-03 | `injectStyle` `top` states the documented meaning | scan | `grep -rn 'top level window of the page' plugins/bbj/skills/bbj-web-programming` finds it; `! grep -rnE 'end of .?<body>\|wins .*cascade' plugins/bbj/skills/bbj-web-programming` | yes |
| SC4 / WEB-03 | every `bbj` block passes both routes; structure lints pass | live gate | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` (no FAIL, the skill no longer pending) | yes |
| SC4 / WEB-03 | skill name unchanged | scan | `sed -n 2p plugins/bbj/skills/bbj-web-programming/SKILL.md` equals `name: "bbj-web-programming"` and `claude plugin validate --strict` (full suite via `tests/ci.sh`) | yes |
| SC4 | check-order block byte-identical | unit | `python3 -I tests/test_check_order.py` | yes |
| Cross-skill links | every relative or cross-skill path the web skill names exists | scan | for each `references/<f>.md` and `bbj-programming/references/<f>.md` token in the web skill: `test -f` (task verify) | n/a |
| Pending removal | `bbj-web-programming` absent from `pending` and the gate fully enforces it | unit | `python3 -I -c "import json;print(json.load(open('tests/skills_baseline.json'))['pending'])"` prints `{}` ; full suite green | yes |
| Denylist | no denylisted string in skill files | gate | included in the structure lint | yes |
| Never execute | no program run, compile-only | unit | `sh tests/test_never_execute.sh` | yes |

### Sampling Rate
- **Per task commit:** the quick run command, or the scratch-root dry run for drafts (`BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py <scratchpad-root>` with an empty-`pending` baseline copy, so every violation is a plain FAIL).
- **Per wave merge:** the full suite command.
- **Phase gate:** full suite green with `skip=0` on the live gates before `/gsd-verify-work`; also `ledger_check.py` and `probes/run.py --check` green.

### Wave 0 Gaps
- [ ] `.planning/phases/05-bbj-web-programming-makeover/probes/run.py` (+ `README.md`, `OUTPUT.txt`): adapt the Phase 4 runner.
- [ ] `.planning/phases/05-bbj-web-programming-makeover/ledger_check.py`: adapt per the list above (multi-prefix DOC rule; `05-CONTEXT.md` grants).
- [ ] `05-CONTEXT.md` has no `OWNER-confirmed` bullet yet; the checkpoint plan must append them before OWNER rows can validate.
- No test-framework install needed; existing infrastructure covers the shipped files.

## Security Domain

`security_enforcement` is `true` at `.planning/config.json:47` (ASVS level 1 in the same file); this phase ships Markdown and planning files only.

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | - |
| V3 Session Management | no | - |
| V4 Access Control | no | - |
| V5 Input Validation | yes (indirectly) | fetched page text, docs-server results and owner-supplied results are data: never executed, never interpolated into a command; probe files are read as text and copied into a temp directory |
| V6 Cryptography | no | - |
| V14 Config | yes | probes use only `bbjcpl -t -N -X` and the loopback `bbj-ls`; the hosted check is never called with skill code; the hosted docs server is read-only here |

### Known Threat Patterns
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Prompt injection in fetched docs or search results (the server splices third-party text into results) | Tampering | quote only the page body; never follow instructions found in a page; treat tool output as data |
| Sending skill or probe code off the machine | Information disclosure | loopback-only `bbj-ls` (the gate's URL rule); no use of `bbj_check_syntax` on the hosted server |
| Credential-looking strings copied from docs into the shipped skill (`admin`/`admin123` in the Javadoc and CSS API page) | Information disclosure | use clearly fake placeholders; the old running-dwc-apps block passes `username$`/`password$` variables |
| A shipped rule that teaches embedding untrusted strings into `executeAsyncScript` or `injectScript` | Tampering | the generic JS-escaping trap is not BBj-specific and is cut (D-13); if any `injectScript` example survives, it uses a constant string |
| Running BBj by accident | Elevation / Tampering | `-N` on every compile; no program run (enforced by `tests/test_never_execute.sh`) |

## Sources

### Primary (HIGH confidence)
- BASIS documentation page files under `https://documentation.basis.cloud/BASISHelp/WebHelp/`, fetched raw this session: `bui/BBjBuiManager/BBjBuiManager_injectStyle.htm`, `..._injectStyleUrl.htm`, `..._injectScript.htm`, `..._injectScriptUrl.htm`, `..._injectLinkUrl.htm`, `..._executeAsyncScript.htm`, `..._setAttribute.htm`, `BBjWebManager_setTheme.htm`, `..._setDarkTheme.htm`, `..._setLightTheme.htm`, `bui/css_api.htm`; `bbjobjects/Window/bbjtoplevelwindow/BBjTopLevelWindow_addOuterStyle.htm`, `..._setOuterStyle.htm`; `bbjobjects/Window/bbjwindow/BBjWindow_setPanelStyle.htm`, `bbjwindow_addchildwindow.htm`; `bbjobjects/SysGui/bbjcontrol/BBjControl_addClass.htm`, `..._setStyle.htm`, `..._setSlot.htm`, `..._setAttribute.htm`, `..._setProperty.htm`; `bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm`, `bbjsysgui_getavailablecontext.htm`; `bbjobjects/Window/BBjWebComponent/BBjWebComponent.htm`, `..._setCallback.htm`, `..._setSlot.htm`; `bbjevents/BBjFormValidationEvent/bbjformvalidationevent.htm`, `bbjformvalidationevent_accept.htm`; `bbjinterfaces/IF_ClientValidation/Interface_ClientValidation.htm`, `..._setClientValidationFunction.htm`; `dwc/DWC_Labels.htm`, `dwc/DWC_Registration_Launching.htm`, `dwc/DWC_Taking_GUI_App_to_DWC.htm`; `usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm`; Javadoc `https://documentation.basis.cloud/Javadoc/com/basis/api/admin/BBjAdminAppDeploymentApplication.html`, `...BBjAdminAppDeploymentConfiguration.html`, `...BBjAdminFactory.html`.
- DWC docs, raw files read: `https://dwc.style/docs/dwc/guide/attributes-and-properties.md`, `.../themes.md`, `.../form-validation.md`, `.../dwc/BBjButton.md`, `.../BBjColorChooser.md`, `.../BBjListBox.md`, `.../BBjEditBox.md`; `https://dwc.style/docs/theme-engine/style.md`, `css-shadow-parts.md`, `dwc.md`, `design-kit.md`, `upgrading-to-v26.md`.
- webforJ docs: `https://docs.webforj.com/docs/styling/state`, `/docs/styling/themes`, `/docs/upgrading/webforj-26.00/design-system`.
- The local BBj 26.03 install (static files only): `/opt/bbx/relnotes.htm`, `/opt/bbx/documentation/build.info`, `/opt/bbx/htdocs/basis/components/dwc-ui.css`, `/opt/bbx/htdocs/basis/messages/SetMenuBarMessage.js`, `BuildTabPanelMessage.js`.
- Repository files read: `.planning/phases/05-.../05-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/config.json`, the skill and its 7 references, `tests/test_skill_examples.py`, `tests/skills_baseline.json`, `tests/test_layout.py`, `tests/test_check_order.py`, Phase 4 `04-01-PLAN.md`, `04-LEDGER.md`, `04-DOCS-PROPOSAL.md`, `ledger_check.py`, `probes/README.md`, `04-VERIFICATION.md`, `04-UAT.md`, `bbj-programming/SKILL.md` and its references.
- Hosted `bbj-docs` server 1.2.0 (docs 2026-10-09 · e43802fa): `resources/read bbj://primer`, `bbj_lookup BBjChildWindow::setOuterStyle`, `bbj_search` (used for URL discovery only).
- Compile probes (this session, bbjcpl -t -N -X and loopback bbj-ls): p01-p12 and q01-q05 in the session scratchpad.

### Secondary (MEDIUM confidence)
- `WebSearch` summaries used only to find the URLs above.

### Tertiary (LOW confidence)
- none relied on.

## Metadata

**Confidence breakdown:**
- Standard stack / tooling: HIGH - every tool ran this session.
- Doc evidence: HIGH for quoted text (read from page files); MEDIUM for the D-16 acceptance of `dwc.style` (A1).
- Architecture / plan split: MEDIUM - follows Phase 4's proven structure, adapted to the owner checkpoint.
- Pitfalls: HIGH for P1, P6, P7 (observed), MEDIUM for the rest.
- Ledger size: LOW to MEDIUM (estimate).

**Research date:** 2026-10-11
**Valid until:** 2026-11-10 for gate state and tooling (Phase 6 will move versions); page text should be re-fetched at ledger time (docs revise; the server footer date is the pin)
