---
phase: 04-bbj-programming-makeover
plan: 02
subsystem: testing
tags: [claim-ledger, evidence, bbjcpl, bbj-ls, owner-grant, python-stdlib]

requires:
  - phase: 04-bbj-programming-makeover
    provides: "plan 04-01: 73 compile probes and probes/OUTPUT.txt on BBj 26.03 (the COMPILE evidence every ledger row cites)"
provides:
  - "04-LEDGER.md: 150 rows, one per rule of the current bbj-programming skill and its five references plus the new rules, each with class, evidence, primer status, verdict and failing route"
  - "ledger_check.py: 17 gates (ledger_header ... ledger_totals) that keep the ledger honest; mutation-proven"
  - "probes/e26i.bbj: the num() fix of the !ERROR=26 rule, so that D-12's str()/num() pair has compile evidence"
  - "Totals: surviving rules per destination (the D-14 counts), the COMPILE-evidence list and the OWNER list for plan 04-04"
affects: [04-03, 04-04, 04-05, 04-06]

actuals:
  tokens: 23600
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "ledger row to probe line to OUTPUT.txt section (D-03), checked by ledger_compile_probe"
    - "OWNER class granted only by a recorded user decision; ledger_owner reads the cited decision line of 04-CONTEXT.md"

key-files:
  created:
    - .planning/phases/04-bbj-programming-makeover/ledger_check.py
    - .planning/phases/04-bbj-programming-makeover/04-LEDGER.md
    - .planning/phases/04-bbj-programming-makeover/probes/e26i.bbj
  modified:
    - .planning/phases/04-bbj-programming-makeover/probes/OUTPUT.txt

key-decisions:
  - "Base commit d61265c: every file:line cell refers to the skill files at that commit; no shipped file changed in this plan"
  - "Exactly two OWNER rows, the D-22 grants: L031 (str() sign trap, keep (SKILL.md)) and L072 (bbj -tIO sends print output to stdout, fold (references/running.md)); the executor granted nothing"
  - "callback-performance.md keeps three rules (L084 accept(1) fires the button push, L085 accept unlocks the window, L086 no reject method), so D-14 keeps the file; java-interop.md and reserved-words.md keep none"
  - "RUNTIME rows with no source at all (round-trip cost L079, TOP L095, context-reuse error L114) are dropped and named for the docs owners (Open question 5)"

patterns-established:
  - "One generator-free ledger: the table is plain Markdown; ledger_check.py is the only tool, run with python3 -I, with a mutation copy as optional argv[1]"

requirements-completed: [PROG-01]

duration: 16min
completed: 2026-10-11
status: complete
plan_head_before: d61265c1b11fe1ba9c906ff6d9d18679a4b399cf
plan_head_after: 7826a85f860635fc772484a06f4f3717d4dc3776
commits: 3

coverage:
  - id: D1
    description: "Ledger checker with 17 gates that fails a RUNTIME keep row, a class cell with extra words and an OWNER row without confirmer, date, version or an OWNER-confirmed decision"
    requirement: "PROG-01"
    verification:
      - kind: other
        ref: "python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py (exit 0, 17 ok gates) and four mutation copies in the scratchpad: ledger_runtime FAIL, ledger_class FAIL, ledger_owner FAIL (no date), ledger_owner FAIL (D-05 not OWNER-confirmed), each exit 1"
        status: pass
    human_judgment: false
  - id: D2
    description: "Claim ledger covering every rule of SKILL.md (78 rows), the five references (64 rows) and the new rules (7 rows), 150 in all, every location checked against the base commit"
    requirement: "PROG-01"
    verification:
      - kind: other
        ref: "gate ledger_totals ok 150 rows: DOC 53, COMPILE 39, RUNTIME 56, OWNER 2; keep 25, rewrite 12, drop 106, fold 7; gate ledger_files_covered ok; no RUNTIME row with verdict keep or fold (gate ledger_runtime ok)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Each DOC row quotes the official page body; whether each quoted sentence supports its claim is a reading, not a test"
    requirement: "PROG-01"
    verification: []
    human_judgment: true
    rationale: "ledger_doc_url proves a documentation URL is present; no test checks that the quoted sentence says what the claim says (pages were fetched and read row by row this session)"
---

# Phase 4 Plan 02: Claim ledger and checker Summary

**A 150-row claim ledger (DOC 53, COMPILE 39, RUNTIME 56, OWNER 2) classifies every rule of the bbj-programming skill with a quoted official page or a probe line, a primer cross-check and a verdict, guarded by a 17-gate checker that rejects any RUNTIME keep, any self-granted OWNER and any location outside the base commit.**

## Performance

- **Duration:** about 16 min (2026-10-11 08:25Z to 08:41Z)
- **Tasks:** 3 (one tracer, two auto)
- **Files created:** 3 (ledger_check.py, 04-LEDGER.md, probes/e26i.bbj); 1 modified (probes/OUTPUT.txt, one section added)
- **Base commit:** `d61265c`. Totals line of the checker: `gate ledger_totals ok 150 rows: DOC 53, COMPILE 39, RUNTIME 56, OWNER 2; keep 25, rewrite 12, drop 106, fold 7`.

## Accomplishments

- `ledger_check.py` (stdlib, `python3 -I`, read-only `git` only): the 17 gates of the interface block. Mutation proofs on scratchpad copies: RUNTIME with keep fails `ledger_runtime`; the class cell `DOC plus note` fails `ledger_class`; an OWNER row without a date fails `ledger_owner`; a complete OWNER row granted by D-05 (a decision without OWNER-confirmed) fails `ledger_owner`; a complete row granted by D-22 passes. Each failing copy exits 1; the committed ledger was never changed by them.
- Tracer (task 1): the trailing-rem rule went through the whole path first (header, Legend, one row, the checker, the probe lines) and `gate ledger_files_covered FAIL` proved that gate has teeth before the expansion.
- SKILL.md: 78 rows. DOC rows carry an official URL and a quoted sentence of the page body (fetched and read this session, not taken from the hosted server's appended text); COMPILE rows cite `probes/<name>.bbj` and the recorded bbjcpl or bbj-ls line.
- References and new rules: callback-performance.md 9 rows, database.md 10, java-interop.md 5, reserved-words.md 9, sysgui.md 31, New rules 8 (the setModal fact sits in the sysgui section, see Deviations).
- Totals (the D-14 counts): SKILL.md 25 surviving rows, callback-performance.md 3, database.md 5, sysgui.md 6, running.md 5 (new file), java-interop.md 0, reserved-words.md 0. **callback-performance.md keeps three rules**, so plan 04-05 does not take its fold branch.
- OWNER rows: **L031** (`SKILL.md:198-210`, the str() sign trap, `keep (SKILL.md)`, route none, numeric_output.htm and probes/t21_str_sign.bbj as support only) and **L072** (`SKILL.md:427-431`, `bbj -tIO` sends print output to stdout, `fold (references/running.md)`, route `-`, the two PRO/5 IO pages as supporting citations only). Both read `OWNER: confirmed by Stephan Wald, 2026-10-11, BBj 26.03 ... grant 04-CONTEXT.md D-22`.
- The `num()` versus `int()` row (L028) cites t17, t18, t22 and t23 and states the observed result: `int("42")` and `int(a$)` fail to compile on both routes (`error at line 10 (1)` and `[SyntaxError] Invalid function parameters`), `int(a!)` of an object variable compiles clean, so the old example `int(countStr!)` compiles; verdict drop (primer gotchas/4).

## Verdicts that differ from the defaults of the plan

| Row | Default in the plan | Ledger | Evidence |
|-----|---------------------|--------|----------|
| L034 `SKILL.md:214` (str() rounds, a bound control mask does not) | RUNTIME, drop | DOC, drop | numeric_output.htm "A mask within a control does NOT round, but a mask within the STR() DOES round." |
| L089 `database.md:5-15` (JDBC) | keep | rewrite | probes/d03_jdbc_undecl.bbj: the old block with undeclared types fails bbjcpl; the argument is a URL or a BBj database name (bbjapi_getjdbcconnection.htm), not "registered datasource" |
| L118 `sysgui.md:33` (no setModal) | New rules row | row in the sysgui section | the fact is stated at that location of the old file; the adjacency rule makes it one row (L117 Dialog flag, L119 `isModal()` and `DIALOGBEHAVIOR` as RUNTIME drop) |
| New rule "label takes rem with no ;" | part of the trailing-rem row | its own New rules row | the old SKILL.md never states it; t05 is its evidence |
| COMPILE rows with route `-` (exit status, record shapes, `Cannot find program`) | route `-` | `none` or the failing route | the checker rule "a COMPILE row is never `-`" (see Deviations) |
| Rows split beyond the default lists | one row per listed item | more rows (150 against a floor of 80) | adjacency rule; listed items were never merged, only split where one line stated several facts |

## Task Commits

1. **Task 1 (tracer): ledger checker and the trailing-rem row** - `297f7c1` (docs)
2. **Task 2: every rule of SKILL.md classified** - `3cd04de` (docs)
3. **Task 3: the five references and the new rules, totals** - `7826a85` (docs)

**Plan metadata:** this SUMMARY, STATE, ROADMAP and REQUIREMENTS commit follows.

## Files Created/Modified

- `.planning/phases/04-bbj-programming-makeover/ledger_check.py` - the checker (gates `ledger_header` to `ledger_totals`)
- `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md` - the ledger (Legend, SKILL.md, five reference sections, New rules, Totals)
- `.planning/phases/04-bbj-programming-makeover/probes/e26i.bbj` - `#total = num(t!)`, bbjcpl clean, bbj-ls clean
- `.planning/phases/04-bbj-programming-makeover/probes/OUTPUT.txt` - one added section (`== e26i.bbj`); `run.py --check` reproduces it (`gate probes_reproduce ok 74 probes`)

## Decisions Made

- The ledger is plain Markdown written once; ids are consecutive in document order, so renumbering after a late insertion is a rewrite of the whole table (the table was assembled by a scratchpad script that is not committed).
- DOC evidence is quoted only from pages fetched from documentation.basis.cloud this session; the primer was read through the hosted server (`bbj-docs 1.1.1`, footer `bbj-docs · hosted · docs 2026-09-29 · 3d63c5e4`) and only fills the primer cell.
- The two PRO/5 IO pages and numeric_output.htm are cited in the OWNER rows as supporting text and are named as not being the evidence for the claim.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical functionality] Probe e26i for the num() fix**
- **Found during:** Task 2
- **Issue:** D-12 and the plan default keep "str()/num()" as the fix, but no probe showed the `num()` form; the COMPILE row would have claimed it with no evidence.
- **Fix:** added `probes/e26i.bbj` (`#total = num(t!)`) and regenerated OUTPUT.txt with `probes/run.py`; the diff is the added section only; `--check` reproduces 74 probes.
- **Files modified:** probes/e26i.bbj, probes/OUTPUT.txt
- **Commit:** 3cd04de

**2. [Rule 1 - Plan inconsistency] COMPILE rows with route `-`**
- **Found during:** Task 2 and Task 3
- **Issue:** the default lists name route `-` for the exit-status row and for the bbjcpl record-shape and `Cannot find program` rows (COMPILE), while `ledger_route` requires that a COMPILE row is never `-`.
- **Fix:** followed the checker (the verifiable rule): `none` for facts that are not a failing program, `bbjcpl` for the q03 row; D-07 asks the ledger to record the failing route, which these rows now do.
- **Files modified:** 04-LEDGER.md
- **Commit:** 3cd04de, 7826a85

**3. [Rule 1 - Bug] `ledger_files_covered` could not fail**
- **Found during:** Task 1 (the planned `FAIL` of that gate was missing)
- **Issue:** `git ls-tree` ran from the phase directory, so the skill path matched nothing and the empty listing counted as covered.
- **Fix:** `--full-tree`, and an empty listing is itself a problem.
- **Files modified:** ledger_check.py
- **Commit:** 297f7c1

**4. [Rule 3 - Blocking] Repository root for `git`**
- **Found during:** Task 1
- **Issue:** the plan says the repository root is two directories above the phase directory; it is three (`.planning/phases/<phase>`).
- **Fix:** the checker runs `git -C <its own directory>` and uses root-relative object names, so no root arithmetic remains.
- **Files modified:** ledger_check.py
- **Commit:** 297f7c1

**Total deviations:** 4 (1 added evidence, 2 plan-versus-checker corrections, 1 own bug). **Impact:** none on scope; the only file beyond the plan list is `probes/e26i.bbj` and the one-section change of OUTPUT.txt.

## Authentication Gates

None.

## Issues Encountered

- The plan's Task 1 acceptance "Row L001 names SKILL.md:32-36" holds only while the ledger has one row: after Task 2 the description row sorts first, so the trailing-rem row is **L003** (plan 04-03 and later plans should cite ids from the Totals section, not from the tracer).
- The hosted `bbj-docs` MCP tools were not available as tools in this session; documentation pages and the primer were read with `curl` from documentation.basis.cloud and the hosted server's `resources/read` (documentation only, no code sent anywhere).

## Known Stubs

None. The ledger is a planning document; nothing shipped changed (`git status --porcelain -- plugins tests codex` prints nothing).

## Threat Flags

None. No network endpoint, auth path or shipped file was added; ledger_check.py starts only read-only `git` commands.

## Next Phase Readiness

Ready for plan 04-03 (SKILL.md rewrite from the verdicts), 04-04 (docs proposal from the "Kept on COMPILE evidence" and "OWNER-confirmed" lists of the Totals), 04-05 and 04-06. Plan 04-05: callback-performance.md keeps three rules (L084, L085, L086), so the keep branch applies; plan 04-06: java-interop.md and reserved-words.md have zero surviving rules and are deleted; a new `references/running.md` takes the five fold rows (L068, L072, L074, L075, L076).

## Self-Check: PASSED

- FOUND: ledger_check.py, 04-LEDGER.md, probes/e26i.bbj
- FOUND commits: 297f7c1, 3cd04de, 7826a85
- `python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py` exits 0 with 17 ok gates; `python3 -I .planning/phases/04-bbj-programming-makeover/probes/run.py --check` exits 0; `git status --porcelain -- plugins tests codex` prints nothing
