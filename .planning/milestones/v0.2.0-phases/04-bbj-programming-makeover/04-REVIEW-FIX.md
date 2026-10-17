---
phase: 04-bbj-programming-makeover
fixed_at: 2026-10-11T00:00:00Z
review_path: .planning/phases/04-bbj-programming-makeover/04-REVIEW.md
iteration: 1
findings_in_scope: 14
fixed: 14
skipped: 0
status: all_fixed
---

# Phase 4: Code Review Fix Report

**Fixed at:** 2026-10-11
**Source review:** .planning/phases/04-bbj-programming-makeover/04-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 14 (7 Warning, 7 Info; fix_scope all)
- Fixed: 14
- Skipped: 0

All fixes were made in an isolated worktree and fast-forwarded onto `gsd/planning-setup`; the worktree, the temporary
branch and the recovery sentinel are removed. Each fix is its own `fix(04): ...` commit. The doc claims were checked
against the local copy of the official documentation (`<home>/repos/bbjdocs/Content`, the source of
documentation.basis.cloud), because the BBj documentation MCP tools were not available to this agent.

**Verification (where it ran):** `sh tests/run.sh` ran in the isolated worktree, which has the same files as the
main checkout after the fast-forward. Result after the last fix: `SUMMARY: ok=702 fail=0 skip=55`. One earlier run
reported `real_home_untouched FAIL changed: <home>/.codex/logs_2.sqlite-shm`; that is a log file of a Codex
process outside the repository, it did not recur on the next two runs, and it is unrelated to the edits. A second
failure in that run (`skills_structure_bbj-programming_references_running.md_46`) was caused by IN-05 and is fixed
in the last commit (see IN-05). `python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py` reports no
failing gate.

**BBj code checks:** a local `bbjcpl` exists (`/opt/bbx/bin/bbjcpl`); the check was `bbjcpl -t -N -X` on the changed
blocks (WR-01 image example: clean; WR-05 JDBC blocks: the `should-fail` block reports the expected
`Cannot assign <undeclared> to BBjNumber` error, the other block is clean). The test suite additionally runs every
block of the skill through `bbjcpl` and `bbj-ls`; all pass. No BBj was run.

## Fixed Issues

### WR-01: Clickable-image example dereferences `getOriginalControl()` without a guard, and the cited pages do not say what it returns for a click on the window itself

**Files modified:** `plugins/bbj/skills/bbj-programming/references/sysgui.md`
**Commit:** 9ced0c4
**Applied fix:** The callback tests `ctrl! <> null()` before `ctrl!.getID()`. The prose now says
`getOriginalControl()` "returns that control" for a click on a control that passes mouse events on, and that the page
does not say what it returns for a click on the window itself. Status: fixed (the null test is the form used in the
web skill; it compiles with `bbjcpl -t`; the run-time behaviour is not tested, BBj is never run).

### WR-02: SKILL.md states "there is no reject method" flatly, on the evidence the plan rejected for `setModal`

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`, `plugins/bbj/skills/bbj-programming/references/callback-performance.md`
**Commit:** d73f18c
**Applied fix:** The absence claim is replaced by what was shown: the documented way to reject is `accept(0)`, and
`bbjcpl -t` rejects `event!.reject(0)` (one call, one route). The SKILL.md index entry reads "accept(0) rejects;
`reject(0)` fails `bbjcpl -t`".

### WR-03: `-P<dir1:dir2>` is given with a colon separator only; the bbjcpl page says semicolons on Windows

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`
**Commit:** 2666673
**Applied fix:** The line states colons on UNIX-like systems and semicolons on Windows, as the bbjcpl page does.

### WR-04: The SQL-verb credential form `MODE="USER=..."` contradicts the SQLOPEN page the same section cites

**Files modified:** `plugins/bbj/skills/bbj-programming/references/database.md`
**Commit:** 34483c8
**Applied fix:** The sentence gives both forms with their sources (How-To: `USER=`/`PWD=` for a JDBC URL; SQLOPEN
page: `UID=`/`PWD=`, example `mode="UID=me,PWD=you"`) and says the pages give no rule for choosing between them.

### WR-05: Both JDBC examples pair `select 1` with `getString("COL")` and never close the connection

**Files modified:** `plugins/bbj/skills/bbj-programming/references/database.md`, `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md`
**Commit:** 36d1fca
**Applied fix:** The prose marks the query and the column as placeholders (`select 1` has one unnamed column). Both
blocks end with `conn!.close()`, matching the How-To Java sample, which closes result set, statement and connection.
The ledger row L089 now states that the shipped blocks differ from probes d01 and d03 in the string literal and in the
final `conn!.close()` line. I chose placeholders over the page's `select * from customer` because no source names a
column of the ChileCompany `customer` table. Both blocks re-checked with `bbjcpl -t -N -X`.

### WR-06: The `bbj -tIO` line rests on a PRO/5 paragraph and omits the same page's caveats

**Files modified:** `plugins/bbj/skills/bbj-programming/references/running.md`
**Commit:** 3eb43f3
**Applied fix:** The line is kept (D-22). The text now says the quoted sentence is from the PRO/5-specific section,
quotes the BBj-specific sentence, and says that `-tIO` working in BBj is the Sources-footer result, not a page
statement. A new paragraph adds the page's caveat: the IO device "is not a terminal and will not translate
mnemonics", with the "garbage on the screen" and `!ERROR=41` symptoms. The configuration-file condition was not added
(it applies only if the owner overrides D-22).

### WR-07: "At run time the same defect is !ERROR=26" goes beyond the cited page

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`
**Commit:** c19f0b8
**Applied fix:** Reworded to "The `!ERROR=26` page lists the same defect ... as a cause of that error", without a
run-time claim.

### IN-01: Command-line synopsis is tagged `bash` but is not valid shell

**Files modified:** `plugins/bbj/skills/bbj-programming/references/running.md`
**Commit:** 0479c48
**Applied fix:** The fence is tagged `text`.

### IN-02: The Dialog-flag block follows the `setModal` should-fail block with no lead-in

**Files modified:** `plugins/bbj/skills/bbj-programming/references/sysgui.md`
**Commit:** 70de816
**Applied fix:** One sentence precedes the block: "The Dialog and Invisible flags together (this example makes no
claim about modality)."

### IN-03: Remote-database use of `getJDBCConnection(url)` is advertised, but the user/password/mode overloads are not mentioned

**Files modified:** `plugins/bbj/skills/bbj-programming/references/database.md`, `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md`
**Commit:** 718b6e0
**Applied fix:** Added the overloads taking `mode`, `props`, or `user` and `password` (the last two from BBj 16.00,
per the page). The third-party function advice now says these pages do not apply to a third-party database and labels
the advice to use its own documentation as general, not stated on the pages. Ledger row L093 updated to match.

### IN-04: The REM page cited for the semicolon rule does not state it

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`
**Commit:** 647ed29
**Applied fix:** The text quotes what the page says ("In compound statements, REM may only be the last verb") and
says the `;` and the label exception were reproduced with `bbjcpl` on BBj 26.03.

### IN-05: "The project owner" is a planning term inside text shipped to end users

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`, `plugins/bbj/skills/bbj-programming/references/running.md`
**Commit:** 310185d, follow-up e525ff8
**Applied fix:** "project owner" became "skill maintainer" in both places. The first commit also changed the Sources
line from "Verified on BBj" to "Confirmed on BBj", which broke the structure gate
(`skills_structure_bbj-programming_references_running.md_46`); e525ff8 restores "Verified on BBj 26.03 by the skill
maintainer".

### IN-06: The sign-character list cites the PRO/5 numeric output page

**Files modified:** `plugins/bbj/skills/bbj-programming/SKILL.md`
**Commit:** ea9bf42
**Applied fix:** The text says the "no sign character drops the minus sign" rule is the maintainer-confirmed rule and
that the documentation does not state it; the Numeric Output page lists the sign characters; its BBj-specific page
(`numeric_output_bbj.htm`) adds only `@` and `&`. Both pages were read in the local documentation copy.

### IN-07: "A program that is run from a shell for the user ends with `RELEASE`" is an instruction no cited page states

**Files modified:** `plugins/bbj/skills/bbj-programming/references/running.md`
**Commit:** e82475c
**Applied fix:** The sentence says the pages do not state how such a program must end, and gives the `RELEASE`
instruction as advice with the quoted RELEASE sentence and the END/STOP console-mode contrast.

---

_Fixed: 2026-10-11_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
