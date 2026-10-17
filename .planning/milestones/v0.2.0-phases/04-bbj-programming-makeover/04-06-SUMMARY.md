---
phase: 04-bbj-programming-makeover
plan: 06
subsystem: skills
tags: [bbj-programming, database, jdbc, sql-limit, baseline, ratchet, bbjcpl, bbj-ls]
status: complete

requires:
  - phase: 04-bbj-programming-makeover
    provides: "04-LEDGER.md verdicts (database.md 5 rules incl. L094 LIMIT rewrite; java-interop.md and reserved-words.md 0 survivors), probes d01 d02 d03, plan 04-05 baseline"
provides:
  - "references/database.md: JDBC with a should-fail undeclared-ResultSet block before the declared block, SQL verbs block, LIMIT (first, count) quoted from SQL_LIMIT.htm, function-page pointers, Sources"
  - "java-interop.md and reserved-words.md deleted (D-14)"
  - "tests/skills_baseline.json without bbj-programming in pending (written by --report); 04-BASELINE.md reads '## bbj-programming (not pending)' / 'no violations'"
affects: [phase-05-bbj-web-programming, phase-06-release]

actuals:
  tokens: 5000
  tasks: 2
  commits: 2

plan_head_before: e4ab4c2db0296e429a61036e9054bd3464c8fe5a
plan_head_after: 6d0d8ada323750d8a4639bb8cce0866bf86e9834

tech-stack:
  added: []
  patterns: ["a documented clause is quoted from its page and the exact grammar position is left to the linked SQL Grammar page rather than asserted"]

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-programming/references/database.md
    - tests/skills_baseline.json
    - .planning/phases/04-bbj-programming-makeover/04-BASELINE.md
  deleted:
    - plugins/bbj/skills/bbj-programming/references/java-interop.md
    - plugins/bbj/skills/bbj-programming/references/reserved-words.md

key-decisions:
  - "database.md states LIMIT only as the page does (first = offset of the first row, count = maximum rows, first based in 1, count a positive integer) and does not assert where the clause sits in a query, because SQL_LIMIT.htm does not say; it points to the SQL Grammar page"
  - "KNOWN_PENDING in tests/test_skill_examples.py untouched; bbj-programming left pending only through --report"

requirements-completed: [PROG-04, PROG-06]

coverage:
  - id: R1
    description: "database.md: documented LIMIT (first, count), checked JDBC pair and SQL-verb block, function-page pointers; TOP, lower-case function and error-252 claims gone"
    requirement: PROG-04
    verification:
      - kind: other
        ref: "Task 1 automated verify (04-06-PLAN.md): live gate clean for database.md, required strings present, one should-fail block, dropped claims absent"
        status: pass
    human_judgment: false
  - id: R2
    description: "Two references deleted and bbj-programming off the pending list in one commit; all five bbj-programming ratchet checks at 0 violations"
    requirement: PROG-06
    verification:
      - kind: other
        ref: "Task 2 automated verify (04-06-PLAN.md): skills_ratchet_bbj-programming_<check> ok 0 violations x5, skills_pending_keys 'pending: bbj-web-programming', fresh --report cmp-identical, probes/run.py --check and ledger_check.py exit 0, both tests/run.sh views exit 0"
        status: pass
    human_judgment: false
---

# Phase 4 Plan 06: database.md, deleted references and the final baseline Summary

database.md rewritten with the documented `LIMIT (first, count)` form and a checked JDBC pair, java-interop.md and reserved-words.md deleted, and bbj-programming taken off the pending list so every block in the skill passes both live routes.

## Accomplishments

- `references/database.md` (`# Database access: JDBC and SQL verbs`): `getJDBCConnection` with declared `java.sql` types; a `bbj should-fail` block (undeclared `rs!` in the `while` condition, fails `bbjcpl -t`, passes `bbj-ls`) directly before the declared program; the SQL verbs `SQLOPEN`, `SQLPREP`, `SQLEXEC`, `SQLFETCH()` with `err=`, `SQLTMPL()`, `SQLCLOSE` with a passing block; `LIMIT (first, count)` quoted from `SQL_LIMIT.htm` ("The first parameter is based in 1. The number of rows must be a positive integer."); pointers to the official string, numeric and time-and-date function pages; `## Sources` with the Verified on BBj 26.03 line. The old `TOP` advice, the lower-case function claim, the ANSI table, error 252 and the shared-database advice are gone (ledger L091, L092, L095, L096, L097).
- `references/java-interop.md` and `references/reserved-words.md` removed with `git rm` (D-14). No file under plugins/, docs/, codex/, tests/ or README.md named either one, and SKILL.md's index lists only existing files.
- `python3 -I tests/test_skill_examples.py --report ...` run once with both live routes up, in the same commit as the deletions: pending holds only bbj-web-programming (bbj-ls 15, bbjcpl 25, grammar 5, should-fail 0, structure 8), nocheck 0, bbj_version 26.03. A fresh `--report` is byte-identical to the committed JSON. 04-BASELINE.md shows `## bbj-programming (not pending)` and `no violations`.
- `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exits 0; the five `skills_ratchet_bbj-programming_<check>` gates read `ok 0 violations`; no `skills_pending_bbj-programming` gate remains; `skills_pending_keys` reads `pending: bbj-web-programming`. Every bbj and bbj should-fail block in the skill is printable ASCII; the skill name and `plugin.json` are unchanged since base commit d61265c; `tests/test_skill_examples.py` is unchanged.

## Both tests/run.sh views

- Live view (`BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh`): `SUMMARY: ok=702 fail=0 skip=55`
- CI view (`BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true sh tests/run.sh`): `SUMMARY: ok=656 fail=0 skip=21` on the rerun. The first run failed `real_home_untouched` (`changed: <home>/.codex/logs_2.sqlite-shm`): the local Codex daemon writing under `~/.codex`, unrelated to this plan, as noted in 04-05.
- `probes/run.py --check` and `ledger_check.py` exit 0.

## Hand-offs

**Phase 6 (REL-02, CHANGELOG 0.2.0)**
- References removed from `plugins/bbj/skills/bbj-programming/references/`: `java-interop.md`, `reserved-words.md`.
- Added: `running.md`.
- Rewritten: `sysgui.md`, `callback-performance.md` (form-validation rules only), `database.md`.
- Codex users who installed the skills earlier keep copies of the two deleted references and their wrong claims until they rerun `codex/install-codex.sh` with `--force` (installed skill copies are replaced only with `--force`). The CHANGELOG should say so.

**Phase 5**
- `plugins/bbj/skills/bbj-web-programming/SKILL.md:194` still names `bbj-programming/references/sysgui.md` for a per-window `getAvailableContext()` rule that sysgui.md no longer states (ledger L114, L115 dropped it as RUNTIME). Phase 5 must reword or drop that comment (first recorded in 04-05-SUMMARY).
- bbj-web-programming counts are unchanged at 15 / 25 / 5 / 0 / 8 and remain the only pending skill.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Unverified placement claim in the LIMIT section**
- **Found during:** Task 1
- **Issue:** My first draft said to put the LIMIT clause at the end of the query "as the page shows". The page (fetched from documentation.basis.cloud) states only the syntax, the offset/count meaning, and the two Remarks sentences; it does not show a position, and "returns the first 20 rows" for `LIMIT (1, 20)` was an example of my own.
- **Fix:** Rewrote the section to quote only what the page states and to point to the SQL Grammar page for position; removed the example. Also reflowed the quote so the verify's literal `based in 1` string matches on one line.
- **Files modified:** plugins/bbj/skills/bbj-programming/references/database.md
- **Commit:** 0d55aa0 (fixed before the commit)

**2. [Rule 3 - Blocking] The plan's `'^gate .* FAIL'` check false-matches a fixture detail**
- **Found during:** Tasks 1 and 2
- **Issue:** Known from 04-03 and 04-05: fixture gates print `status=FAIL` inside a detail. Used `'^gate [^ ]* FAIL'` instead, as directed by the orchestrator.

**Total deviations:** 2 (1 Rule 1, 1 Rule 3). **Impact:** none on scope; documentation claims stay within what the pages state.

## Commits

- 0d55aa0 `feat(04-06): rewrite database.md with documented LIMIT and checked JDBC blocks`
- 6d0d8ad `refactor(04-06): delete java-interop and reserved-words references, take bbj-programming off pending` (two deletions, tests/skills_baseline.json, 04-BASELINE.md in one commit)

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- database.md, baseline JSON and 04-BASELINE.md exist; java-interop.md and reserved-words.md are absent.
- Commits 0d55aa0 and 6d0d8ad are ancestors of HEAD.
