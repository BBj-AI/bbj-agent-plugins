---
phase: 05-bbj-web-programming-makeover
plan: 03
subsystem: testing
tags: [bbj, dwc, claim-ledger, ledger-check, owner-checklist, destinations]

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: ledger_check.py and the SKILL.md section of 05-LEDGER.md (plan 05-02), probes/OUTPUT.txt (plan 05-01)
provides:
  - 05-LEDGER.md covering all eight files of the skill (242 rows), ledger_check.py green with every gate ok, files_covered included
  - the owner checklist triage O1-O11 with row ids and destinations, and the D-06 dropped line
  - the destination set (SKILL.md plus four references) and the four deletions, read by plans 05-06 to 05-10
affects: [05-04, 05-05, 05-06, 05-07, 05-08, 05-10]

actuals:
  tokens: 20311
  tasks: 3
  commits: 3
plan_head_before: cbb11dbfd8e5f4fe8675b68e1cf4ea1ee85eb60d
plan_head_after: 9fc64eb3d20b373b43de7670a062bf0392f5bece

tech-stack:
  added: []
  patterns:
    - "One fact, several places: a restatement in a reference appends its file:line to the existing row instead of adding a row"
    - "DOC quotes are checked against the fetched page file (whitespace, backticks and markdown links ignored); a rule that overreaches its page is rewritten to the page's words or dropped"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/05-03-SUMMARY.md
  modified:
    - .planning/phases/05-bbj-web-programming-makeover/05-LEDGER.md

key-decisions:
  - "Destinations: SKILL.md, references/styling.md, references/form-validation.md, references/running-dwc-apps.md, references/shoelace.md; Deleted in plan 05-10: color-chooser.md, responsive-layout.md, shadow-dom-styling.md, themes.md"
  - "The ThinClient sentence is dropped: the Thin Client command-line page does not state that the bbj command starts the thin client"
  - "No row is OWNER; owner checklist O1-O11 stay RUNTIME drop rows with their 'if confirmed' destination"

patterns-established:
  - "Rows whose claim cell names taste (CDN, component reference, --sl-*, Tabler, Seiko, watch-card, local-first, GSAP, Swiper, Google Fonts) are all verdict drop; the Task 3 verify scans for it"

requirements-completed: [WEB-01, WEB-02]

duration: about 45 min
completed: 2026-10-11
status: complete
---

# Phase 5 Plan 03: Claim ledger for the references Summary

**The ledger now covers SKILL.md and all seven references in 242 rows, fixes the destination set (SKILL.md plus styling, form-validation, running-dwc-apps and shoelace references) and the four deletions, and queues eleven undocumented DOM/CSS claims for the owner.**

## Performance

- **Duration:** about 45 min
- **Tasks:** 3 (one tracer, two auto)
- **Files modified:** 1 (`05-LEDGER.md`); no shipped file changed (`git status --porcelain -- plugins tests codex` prints nothing)

## Ledger totals

`python3 -I .planning/phases/05-bbj-web-programming-makeover/ledger_check.py` exits 0, all 19 gates ok, `ledger_files_covered` included.

- Rows line: `242 rows: DOC 106, COMPILE 12, RUNTIME 124, OWNER 0; keep 37, rewrite 44, drop 159, fold 2`
- Destinations line: `SKILL.md (43), references/styling.md (15), references/form-validation.md (11), references/running-dwc-apps.md (10), references/shoelace.md (4)`
- Deleted line: `Deleted in plan 05-10: references/color-chooser.md, references/responsive-layout.md, references/shadow-dom-styling.md, references/themes.md`
- Owner checklist line: `O1-O11 (11 items)`; `Dropped without asking (D-06)` names 28 minor rows.
- Rows per section added here: color-chooser 13, form-validation 17, responsive-layout 18, running-dwc-apps 24, shadow-dom-styling 26, shoelace 15, themes 36 (the plan's floors were 7, 10, 6, 12), New rules 5.
- Every destination reference has at least 3 DOC or COMPILE rows with a keep, rewrite or fold verdict naming it (styling 15, form-validation 11, running-dwc-apps 10, shoelace 4); owner items are not counted.

## Task Commits

1. **Task 1 (tracer): references/color-chooser.md** - `937722b` (feat). The tracer gate passed (auto mode): the Task 1 verify re-ran end to end, every gate except `ledger_files_covered` ok, before the expansion rows were written.
2. **Task 2: form-validation, responsive-layout, running-dwc-apps** - `225fe6b` (feat)
3. **Task 3: shadow-dom-styling, shoelace, themes, New rules, Owner checklist, Totals** - `9fc64eb` (feat)

## ThinClient page finding (RESEARCH Q5, D-11)

The raw page `usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm` says "TC Runs the interpreter in Thin Client mode", "FC Runs in Fat Client mode (non-Thin Client). This option has been obsolete since BBj 5.00." and "The executable connects to the ThinClientProxyServer (TCPS) on the local machine". None of these states that the bbj command starts the thin client, or that a program run that way is not the DWC. The row for running-dwc-apps.md:12-14 is therefore RUNTIME drop (default applied), and the ThinClient consequences (getWebManager, injectStyle, dwc-icon) are RUNTIME drop. `-WD` and `-q` are DOC rows (the same page: "WD<working directory> Specifies the server directory in which BBj will start", "q Suppresses the start-up message and splash window.") with verdict drop and the pointer to `plugins/bbj/skills/bbj-programming/references/running.md`.

## Default verdicts that were changed

- **references/color-chooser.md:37, "citing L001".** The plan names L001 as the correction row; L001 is the frontmatter description row. The injectStyle `top` correction is L058, so the row cites L058 (same for shadow-dom-styling.md:4-6, :62-67 and themes.md:29).
- **form-validation.md:5, "DWC only".** The default kept "DWC only and BBj 22.10+". `Interface_ClientValidation_setClientValidationFunction.htm` says that in the GUI client `control` is "the underlying Java Swing JComponent", and the guide only says "supported in BBj 22.10 and higher through the ClientValidation interface". Verdict rewrite to the guide sentence; "DWC only" is dropped.
- **form-validation.md:85-100, BBjControlValidation plugin.** Default class RUNTIME. The dwc.style form-validation guide has a section "BBjControlValidation Plugin" naming it, so the class is DOC; the verdict stays drop (D-12; the `use ::BBjControlValidation/...` program is not in the 26.03 install).
- **responsive-layout.md:3-9 premise.** The plan says to append it to the SKILL.md:190 Automatic Layout row. Two rows start at that line: L041 (rewrite, the page words) and L042 (drop, "the flag that makes a DWC app responsive"). The premise ("the stylesheet is the only thing deciding where anything goes") overreaches the page like L042, so it was appended there.
- **running-dwc-apps.md:63 (browse).** DOC after all: `bbjthinclient_browse.htm` says "opens the specified URL in the default browser (GUI) or the current browser (BUI and DWC)"; verdict rewrite to those words.
- **running-dwc-apps.md:85-90 (URL shape).** keep -> rewrite: the registration page gives `server:port/context/appname`, the default contexts webapp and apps and the example `localhost:8888/webapp/MyApp`; it does not name Jetty or call 8888 the default port.
- **running-dwc-apps.md:92 (prefer getDwcUrl).** No row; appended as a location to the getDwcUrl row, whose documented sentence ("It uses the name in combination with the host and port information from the Jetty server") carries the fact.
- **themes.md:116-119, "no expanse by default".** Default RUNTIME drop. The dwc.style themes guide states it ("By default a BBj control is created with no expanse." and "Without expanse and without explicit BBj sizing, controls can render at inconsistent dimensions across the page."), and flow layout is BBj-specific (D-13), so DOC keep (references/styling.md).
- **themes.md habits (31-53), sizing, colours, hue/saturation tokens, "retune built-ins", reduced motion.** Default RUNTIME drop. The dwc.style themes guide and docs.webforj.com colour and sizing pages state them, so they are DOC rows; the verdict is still drop (D-13, D-14, D-04 pointer).
- **themes.md:59 (setTheme DWC only).** Rewritten to the BASIS object-page wording ("Themes are only meaningful in the DWC client."); the "no-ops on BUI/WebUI" sentence is on the guide, not on the object pages.
- **shoelace.md:9 (module by URL).** The default says the example loads shoelace.js. In the `BBjWebComponent_setSlot.htm` example `url$` is set to `.../cdn/shoelace.js` and then to `.../cdn/shoelace-autoloader.js`, and the `injectScriptUrl(url$, top, attributes$)` call with `attributes$ = "type=module"` follows the second assignment. The row states the call form, not a file name.
- **shoelace.md:83 (setHtml).** DOC keep: `BBjWebComponent_setHtml.htm` exists ("sets the HTML content of this BBjWebComponent") and p16 compiles `card!.setHtml("Automatic")`.
- **shoelace.md:99 (checked option).** DOC (the setCallback page example uses `addItem("checked","event.target.checked")`) but verdict drop: a variation of the value form the q01 program carries.
- **shadow-dom-styling.md custom-properties claim (26-28, 174-176).** RUNTIME drop: the css-shadow-parts, CSS variables and themes pages (dwc.style and docs.webforj.com) were read and none says custom properties cross the boundary.
- **Appended locations (no new row):** L005 (`shoelace.md:86`), L013 (`color-chooser.md:5`), L021 (`responsive-layout.md:123-124`), L022 (`responsive-layout.md:60-62`, `:64-97`), L038 (`shadow-dom-styling.md:3-9`, `:22-23`, `:69-70`, `:160`), L042 (`responsive-layout.md:3-9`), L065 (`color-chooser.md:30`, `themes.md:135-136`), L070 (`shadow-dom-styling.md:205-207`), L076 (`shoelace.md:73`, `:77`, `:81`), L079 (`shoelace.md:79`), L082 (`shadow-dom-styling.md:21`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Wrong correction-row id in the plan text**
- **Found during:** Task 1
- **Issue:** the plan says the `top` copies are "corrected by L001"; L001 is the frontmatter description row.
- **Fix:** the rows cite L058, the row that carries the correction.
- **Files modified:** 05-LEDGER.md
- **Commit:** 937722b

**2. [Rule 1 - Bug] Evidence worded more strongly than its page**
- **Found during:** Task 3
- **Issue:** the plan's default for the BBjControlValidation plugin (no page), the "DWC only" client validation sentence and the shoelace.js example (see the list above) did not match the fetched pages.
- **Fix:** class, verdict or wording changed to what the page body says; each change is listed above with its quote.
- **Files modified:** 05-LEDGER.md
- **Commit:** 225fe6b, 9fc64eb

**3. [Rule 3 - Blocking] bbj-docs MCP tools not exposed**
- **Issue:** same as plan 05-02; the bbj-docs tools are not available to this agent.
- **Fix:** pages were fetched with `curl` (read-only) into the session scratchpad; `bbj_lookup` was called through the hosted server's JSON-RPC endpoint only to find the `PGM()` and `BBjThinClient::browse` page URLs. No code was sent anywhere.

**Total deviations:** 3 auto-fixed. **Impact:** none on scope; no shipped file changed.

## Issues Encountered

None blocking. A scan of every quoted string of 20 or more characters in rows L089 onwards against the fetched page files (backticks, asterisks and curly quotes ignored) reported only quote-pairing artefacts of rows that nest quotation marks, no wrong quote. The `ledger_owner_items` gate caught two DOC rows that named "owner checklist O11" and "O5" in running text; they were reworded to "the checklist item O<n>" so that only RUNTIME drop rows carry the marker and plan 05-04's `checklist_ledger` finds exactly one row per item.

## Known Stubs

None (planning artifacts only).

## Threat Flags

None. T-05-09: no credential-looking sample value was copied (`admin123` occurs nowhere in the ledger; the registration row names the q04 placeholders "user" and "password"). T-05-10: `ledger_files_covered` is ok and every restated location was appended to an existing row. T-05-11: every `--dwc-*` token in a kept row (`--dwc-color-primary-seed`, `-h`, `-s`, `--dwc-dark-mode`, `--dwc-font-size`) appears on its cited v26 page; the three tokens absent from the 26.03 `dwc-ui.css` (triage) sit only in dropped Shoelace rows.

## Next Phase Readiness

Ready for 05-04 (owner checklist): the `## Owner checklist` lines give claim, row ids and destination for O1-O11. Plan 05-05 recomputes the Destinations and Deleted lines after the owner session (`references/styling.md` keeps 15 DOC or COMPILE rows even if O5 and O6 are rejected).

## Self-Check: PASSED

Files exist: `05-LEDGER.md`. Commits `937722b`, `225fe6b` and `9fc64eb` are ancestors of HEAD. The Task 1, 2 and 3 verify commands passed; `ledger_check.py` prints every gate ok.
