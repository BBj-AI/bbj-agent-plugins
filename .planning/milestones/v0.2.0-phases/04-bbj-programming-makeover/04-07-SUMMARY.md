---
phase: 04-bbj-programming-makeover
plan: 07
subsystem: skills
tags: [bbj, skill, provenance, ledger, gap-closure, jdbc, sysgui]
gap_closure: true

requires:
  - phase: 04-bbj-programming-makeover
    provides: plans 04-02 to 04-06 (ledger, probes, rewritten skill and references) and the 04-VERIFICATION.md gaps this plan closes
provides:
  - SKILL.md provenance intro and a section-2 heading that make no claim about the primer
  - database.md with getJDBCConnection(url), ChileCompany blocks, scoped SQL function pointer, marked placeholders
  - sysgui.md with the Dialog flag stated as the page states it, setModal by route, corrected clickable-image rule and example
  - running.md with END/STOP condition, RELEASE rollback note, honest Sources footer
  - ledger rows L076, L088, L089, L093, L117, L118, L138 aligned with the shipped text
  - docs proposal L118 bullet as a question to the docs owners
affects: [phase 5 bbj-web-programming, phase 6, verify-work for phase 4]

actuals:
  tokens: 10300
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "A shipped sentence quotes the re-fetched page or names the probe route; no exhaustive word the read does not cover"
    - "A routes-disagree probe result is stated by route, never as the absence of a method"

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - plugins/bbj/skills/bbj-programming/references/database.md
    - plugins/bbj/skills/bbj-programming/references/sysgui.md
    - plugins/bbj/skills/bbj-programming/references/running.md
    - .planning/phases/04-bbj-programming-makeover/04-LEDGER.md
    - .planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md

key-decisions:
  - "Section-2 heading renamed to 'Rules for writing BBj' (the section holds the trailing-rem and str() sign rules that the primer also states)"
  - "L117 reclassified DOC to RUNTIME with verdict rewrite naming probes/s02_dialogflag.bbj; OWNER stays exactly L031 and L072"
  - "The setModal paragraph names the probed call and both routes and does not state that the method is absent; the proposal asks the docs owners"
  - "The -tIO line stays a plain fact (D-22); only the Sources footer changes how its evidence is named"

patterns-established:
  - "Ledger Totals line is copied from gate ledger_totals, never computed by hand (tools: totals script in the session scratchpad)"

requirements-completed: [PROG-01, PROG-02, PROG-03, PROG-04, PROG-05, PROG-06]

coverage:
  - id: D1
    description: "SKILL.md intro states provenance (reproduced, page-cited, owner-confirmed str() sign rule); section-2 heading makes no claim about the primer; stderr rule carries its condition; primer pointer drops the stale str() item"
    requirement: PROG-03
    verification:
      - kind: unit
        ref: "task 3 verify (grep -qxF of the primer pointer line, heading order, hedge checks); python3 -I tests/test_check_order.py"
        status: pass
    human_judgment: false
  - id: D2
    description: "sysgui.md states the Dialog flag only as the addWindow page does, names the MDI modal flags as also listed, states setModal by route, and fixes the clickable-image rule and example"
    requirement: PROG-04
    verification:
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py (bbjcpl -t -N -X and loopback bbj-ls); task 2 verify"
        status: pass
    human_judgment: false
  - id: D3
    description: "database.md writes getJDBCConnection(url) with the documented meaning of url, both JDBC blocks pass ChileCompany and equal probes d01/d03 apart from the literal, SQL function pages scoped, placeholders marked"
    requirement: PROG-04
    verification:
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py; task 1 verify (diff against probes d01/d03)"
        status: pass
    human_judgment: false
  - id: D4
    description: "running.md carries the END/STOP condition in the page's words, the RELEASE rollback note and a footer naming what was checked and the owner-confirmed -tIO fact"
    requirement: PROG-05
    verification:
      - kind: unit
        ref: "task 3 verify (running.md phrase and footer-line checks, hedge check on -tIO)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Ledger rows L076, L088, L089, L093, L117, L118, L138 and the Totals line match what ships; docs proposal L118 bullet asks the owners instead of suggesting wording"
    requirement: PROG-01
    verification:
      - kind: unit
        ref: "python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py (17 ok gates)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Whole suite stays green on first runs"
    requirement: PROG-06
    verification:
      - kind: integration
        ref: "BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh (run 1 FAIL real_home_untouched, rerun pass); CI view (run 1 pass)"
        status: unknown
    human_judgment: true
    rationale: "The live view failed real_home_untouched on its first run (local Codex daemon writing under ~/.codex); only a diagnostic rerun passed, so it is recorded as an open deviation and not reported as clean"

duration: 8min
completed: 2026-10-11
status: complete
plan_head_before: 2e423538d51849311ba881c47f68bcbd382c8fb7
plan_head_after: 02ba8a85c6a8b29c326ef0c7280970a4bd5b220e
---

# Phase 4 Plan 07: Gap closure for the bbj-programming makeover Summary

**Four shipped files and two planning artifacts now say only what their re-fetched pages, probes or the owner state: JDBC `getJDBCConnection(url)` with `ChileCompany`, the Dialog flag as "behave as a dialog" with setModal stated by route, an image that reports clicks without `setReportAllMouseEvents(1)`, END/STOP with the page's condition, and a SKILL.md intro that names reproduced, page-cited and owner-confirmed rules correctly.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-10-11T11:25:43Z
- **Completed:** 2026-10-11T11:33:31Z (SUMMARY write begins)
- **Tasks:** 3
- **Files modified:** 6 (plus this SUMMARY and STATE.md/ROADMAP.md/REQUIREMENTS.md bookkeeping)

## Accomplishments

- database.md: `getJDBCConnection(url)` with the page's two meanings of `url` and "including case"; both JDBC blocks pass `ChileCompany` and differ from probes d01 and d03 only in that literal (diff-checked); the SQL function pages are scoped to a BBj database ("supported by the BASIS DBMS") with a third-party database pointed to its own functions; the SQL-verb placeholders are named with the How-To `MODE=` form; the intro says a Java sample for JDBC and a BBj sample for the SQL verbs.
- sysgui.md: the Dialog bullet is unchanged; a paragraph names the MDI Desktop Modal and MDI Group Modal flags as flags the page also lists (no exhaustive word) and gives the probed `win!.setModal(1)` result on both routes (bbjcpl rejects it, bbj-ls accepts it) without stating that the method is absent; the clickable-image rule says an image reports mouse events without the call and the example adds an image control and compares `getOriginalControl().getID()` with it.
- SKILL.md: new provenance intro, `## Rules for writing BBj` heading, `-t -N -X` and no `-W` condition on the stderr rule, and a primer pointer without the stale `str()` item; body 149 lines, frontmatter, check-order block and Built in line untouched.
- running.md: "When not in a public program, `END` and `STOP` place PRO/5 in "console mode"", the `RELEASE` rollback note, and a two-line footer; the `-tIO` paragraph is byte-identical.
- Ledger and proposal: seven rows aligned, one note line naming L117, Totals line from the gate, proposal L118 bullet reduced to a topic lead, the quoted Dialog entry, the s01 and s02 evidence and a question to the owners.

## Task Commits

1. **Task 1: database.md and ledger L088, L089, L093** - `5ed9517` (fix)
2. **Task 2: sysgui.md, ledger L117, L118, L138, proposal L118 bullet** - `3375a43` (fix)
3. **Task 3: SKILL.md, running.md, ledger L076** - `02ba8a8` (fix)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Gap item and review finding map

| Finding | Changed lines |
|---------|---------------|
| WR-01 (false provenance) | SKILL.md intro (lines 18-20) |
| plan check provenance_consistency | SKILL.md section-2 heading (line 34) |
| IN-03 (stale primer item) | SKILL.md `## Look it up instead` first bullet |
| IN-04 (stderr condition) | SKILL.md first `bbjcpl output` bullet |
| WR-02 (Dialog and modality) | sysgui.md paragraph after the flag bullets |
| WR-03 (clickable image) | sysgui.md `## Clickable images` prose and block, Sources line (adds s07) |
| WR-04 (`url` parameter, example literal) | database.md `## JDBC` paragraph and both block literals |
| WR-05 (unscoped function restriction) | database.md `## SQL functions` lead sentence |
| WR-08 (intro, placeholders) | database.md intro and `## SQL verbs` placeholder note |
| WR-06 (footer) | running.md `## Sources` last two lines |
| WR-07 (END/STOP, RELEASE) | running.md END/STOP bullet and the line after the bullets |

## Ledger rows changed

| Row | Old | New |
|-----|-----|-----|
| L076 | fold (references/running.md) | unchanged class and verdict; evidence records the END condition and the RELEASE rollback |
| L088 | DOC, keep (references/database.md) | DOC, rewrite (references/database.md) |
| L089 | DOC, rewrite (references/database.md) | unchanged; evidence quotes the `url` parameter, names ChileCompany, states the d01/d03 literal-only difference |
| L093 | DOC, keep (references/database.md) | DOC, rewrite (references/database.md); two page fragments quoted on their own |
| L117 | DOC, keep (references/sysgui.md) | RUNTIME, rewrite (references/sysgui.md); route none; names MDI Desktop Modal and probes/s02_dialogflag.bbj |
| L118 | COMPILE, keep (references/sysgui.md), route bbjcpl | COMPILE, rewrite (references/sysgui.md), route bbjcpl |
| L138 | DOC, keep (references/sysgui.md) | DOC, rewrite (references/sysgui.md); names probes/s07_imgctrl_mousedown.bbj |

Final `gate ledger_totals` line: `gate ledger_totals ok 150 rows: DOC 52, COMPILE 39, RUNTIME 57, OWNER 2; keep 20, rewrite 17, drop 106, fold 7`. `ledger_check.py` prints 17 ok gates; exactly two OWNER rows remain (L031, L072); no row added, removed or moved.

## Quotes copied (pages fetched 2026-10-11 from documentation.basis.cloud, official body only)

- bbjapi_getjdbcconnection.htm: "The name of a BBj database on the server, or the JDBC connection URL used to connect to a remote or third party database"; "the name defined in the Enterprise Manager, including case"; example `getJDBCConnection("ChileCompany", "")`.
- EM_DB_JDBC_How-To.htm: "Sample Java Code" (DriverManager) and "Sample BBj Code" (`SQLOPEN(chan, MODE="USER=youruser,PWD=yourpwd") url$`).
- bbjds_string_functions.htm, bbjds_numeric_functions.htm, bbjds_time_and_date_functions.htm: "specified in the ODBC 3.51 and JDBC 2.0 specifications" and "supported by the BASIS DBMS" (both fragments present in all three bodies).
- bbjsysgui_addwindow.htm: "$00080000$ Dialog : Sets the window to behave as a dialog."; the MDI Desktop Modal and MDI Group Modal entries; the body has no `setModal` hit.
- BBjWindow_setReportAllMouseEvents.htm: "report low-level mouse events (mouse down, mouse up, etc.) to the window"; "low-level mouse events are only reported when the user clicks directly on the window, or on certain selected controls (static text, image, group box)".
- BBjMouseEvent_getOriginalControl.htm: "As always, getControl returns the window."
- end_verb.htm: "When not in a public program, both END and STOP", "Place PRO/5 in console mode". release_verb.htm and release_verb_bbj.htm: "and returns control to the host operating system", "rolls back all uncommitted transactions". running_from_the_command_line.htm option lines and terminals_under_unix.htm IO-device sentence: present in the official bodies as quoted by running.md.

## Test runs (Task 3 verify)

- live view run 1: `SUMMARY: ok=701 fail=1 skip=55`
- live view rerun (diagnosis only): `SUMMARY: ok=702 fail=0 skip=55`
- CI view run 1: `SUMMARY: ok=656 fail=0 skip=21`
- Verify last line: `task 3 verify: passed with an open deviation, not clean (first-run real_home_untouched FAIL in: live)`

Not reported as clean: the live view, and therefore the suite. The CI view alone passed on its first run. A fresh `--report` is byte-identical to `tests/skills_baseline.json`; probes still reproduce; `tests/test_check_order.py` passes.

## Decisions Made

- Renamed the section-2 heading to `## Rules for writing BBj` (Claude's discretion on wording; D-11 fixes place and content).
- L117 became RUNTIME with a rewrite verdict, so the base-commit claim cell is kept and the evidence records the rewrite; no OWNER was granted (D-21).
- The proposal asks the docs owners whether a top-level window has `setModal()` and whether the Dialog flag makes a window modal; nothing in the repository states either.

## Deviations from Plan

### Open deviation: live view first run failed real_home_untouched (D-1, not an auto-fix)

- **View:** `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh`
- **Run 1 SUMMARY line:** `SUMMARY: ok=701 fail=1 skip=55`
- **FAIL gate line:** `gate real_home_untouched FAIL changed: <home>/.codex/logs_2.sqlite-wal`
- **Changed under the real home (all printed paths):** `<home>/.codex/logs_2.sqlite-wal`, `<home>/.codex/models_cache.json`, `<home>/.codex/logs_2.sqlite-shm`
- **Rerun SUMMARY line (diagnosis only):** `SUMMARY: ok=702 fail=0 skip=55`
- **Status:** open. The paths are files the local Codex daemon writes (same cause as 04-05 and 04-06); no test of this plan writes there. The live view is not reported as clean and the suite is not reported as clean. The verify was not run again.

Other than this, none: plan executed as written. Total auto-fixed deviations: 0.

## Issues Encountered

None besides the open deviation above.

## Known Stubs

None. The placeholders in the database.md SQL-verb block (URL, table `t`, column `col`) are marked as placeholders in the text beside the block.

## User Setup Required

None - no external service configuration required.

## Deferred review findings (INFO, from the plan)

- IN-01 (rename callback-performance.md): would edit a Phase 5 file (`bbj-web-programming/references/form-validation.md:3`).
- IN-02 (`ON_FORM_VALIDATION` heading unsourced): needs a new source page and a changed block.
- IN-05 (Invisible window shown with `setVisible(1)`): adds a new fact needing a new page.
- IN-06 (running.md synopsis fence tag, `-c` wording): lines this plan does not edit.
- IN-07 (no test pins the duplicated Built in paragraph): needs a new test and a snippet edit.
- WR-06 second half (configuration-file condition on the `-tIO` line): not applied; D-22 locks the line as a plain fact. The owner may add it or record the override the verification report offers.

## Next Phase Readiness

- The six `gaps[0].missing` items of 04-VERIFICATION.md map to changed lines and passing task verifies; re-running `/gsd-verify-work` or the phase verifier should find truth 6 closed.
- The `real_home_untouched` live-view deviation stays open for the verifier to see.

## Self-Check: PASSED

- Files: SKILL.md, database.md, sysgui.md, running.md, 04-LEDGER.md and 04-DOCS-PROPOSAL.md exist and carry the changes.
- Commits `5ed9517`, `3375a43`, `02ba8a8` are ancestors of HEAD; `git rev-list --count` from the plan base `2e42353` gives 3.

---
*Phase: 04-bbj-programming-makeover*
*Completed: 2026-10-11*
