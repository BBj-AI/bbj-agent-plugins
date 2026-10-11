---
phase: 04-bbj-programming-makeover
reviewed: 2026-10-11T00:00:00Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-programming/references/database.md
  - plugins/bbj/skills/bbj-programming/references/running.md
  - plugins/bbj/skills/bbj-programming/references/sysgui.md
findings:
  critical: 0
  warning: 7
  info: 7
  total: 14
status: issues_found
---

# Phase 4: Code Review Report (post-gap-closure re-review)

**Reviewed:** 2026-10-11
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues_found

This is the post-gap-closure re-review (plan 04-07). It overwrites the report from the earlier review round.

## Summary

I reviewed `git diff bda781c HEAD` for the four files and re-read each file in full. I fetched the official
`documentation.basis.cloud` bodies for the pages the changed sentences cite and compared the quoted fragments.
Pages fetched: getJDBCConnection, EM JDBC How-To, SQLOPEN, SQLFETCH, LIMIT, string functions, addWindow,
setReportAllMouseEvents, getOriginalControl, END, RELEASE and RELEASE (BBj), the command line page, the
terminals-under-UNIX page, numeric output, `!ERROR=26`, bbjcpl and REM. I read the probe output and the diff of the
JDBC blocks against probes d01 and d03. No BBj was run.

What the gap closure fixed holds up:

- Every quotation added in 04-07 matches its page: the `url` parameter text, "including case", the
  `setReportAllMouseEvents` and `getOriginalControl` sentences, END's "When not in a public program" and "console
  mode", the RELEASE rollback, and the MDI flag entries.
- The `setModal` paragraph now states the probe by route and no longer claims the method is absent.
- The new image example uses only documented calls.
- The JDBC blocks equal probes d01 and d03 apart from the connection literal (diffed).
- The `addWindow` body has no `setModal` hit.

No blocker. The remaining defects are claims that go beyond their page, a platform-specific example presented as
universal, examples that would fail or leak at run time, and one absence claim made with the same evidence the plan
rejected for `setModal`.

## Warnings

### WR-01: Clickable-image example dereferences `getOriginalControl()` without a guard, and the cited pages do not say what it returns for a click on the window itself

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:74-80`
**Issue:** The callback is registered on the window. The `setReportAllMouseEvents` page says low-level events are
reported "when the user clicks directly on the window" as well as on selected controls. The `getOriginalControl`
page only states the result for a click on a control ("If the user clicks on a BBjStaticText control (or any other
control that can pass on mouse events to the window), getOriginalControl() returns that control"). It says nothing
about a click on the bare window. The example calls `ctrl!.getID()` on the result unconditionally. If a window click
returns null (or the window), the handler either fails at run time or compares the wrong thing. The block is only
compiled, so the gate cannot show this. The new prose ("returns the control that originated the event") is also
broader than the page's remark.
**Fix:** Guard the call, in the null-test form the gate accepts, and add one sentence naming the window-click case as
not documented. Example shape:
```bbj
ctrl! = event!.getOriginalControl()
if ctrl! <> null() then
    if ctrl!.getID() = #img!.getID() then
        #win!.setTitle("Image clicked")
    endif
endif
```
Check the exact null test with `bbj_lookup` and the live gate before shipping.

### WR-02: SKILL.md states "there is no reject method" flatly, on the evidence the plan rejected for `setModal`

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:152` (source: `references/callback-performance.md:9-11`)
**Issue:** 04-07 removed the claim that `setModal` is absent because the evidence (a `bbjcpl` "No match for method
...(BBjInt)" error with a clean `bbj-ls`) shows only that one signature is rejected by one route. The `reject` claim
rests on the identical shape of evidence (`No match for method ...BBjFormValidationEvent.reject(BBjInt)`, `bbj-ls`
passes) plus the `accept` page, which does not say that no other method exists. The same standard (D-04, the plan's
last prohibition) is not applied here, and the SKILL.md index line repeats the absolute form.
**Fix:** Say what is shown: "`bbjcpl -t` rejects `event!.reject(0)`; the documented way to reject is `accept(0)`."
Change the SKILL.md index entry to match, for example "accept(0) rejects; `reject(0)` fails `bbjcpl -t`".

### WR-03: `-P<dir1:dir2>` is given with a colon separator only; the bbjcpl page says semicolons on Windows

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:31`
**Issue:** The bbjcpl page says the `-P` directory names are "separated by semicolons on Windows environments or by
colons on UNIX-like environments". The skill shows only the colon form. The project targets Windows through Git for
Windows, so an agent on Windows following this line passes a path list that does not split.
**Fix:** `pass -P<dir1:dir2> (colons; semicolons on Windows)` or `-c<config.bbx>` (not both).

### WR-04: The SQL-verb credential form `MODE="USER=..."` contradicts the SQLOPEN page the same section cites

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:56-57`
**Issue:** The new sentence copies the How-To sample `SQLOPEN(chan, MODE="USER=youruser,PWD=yourpwd") url$`. The
SQLOPEN page, listed in this section's Pages, documents the MODE options `UID=string` and `PWD=string` and its
examples use `mode="UID=me,PWD=you"`. The file never says that `USER=` is the keyword for a JDBC-URL data source
(the How-To's case) and `UID=` the documented option for a data source name. An agent that reads both pages gets two
keywords with no rule for choosing.
**Fix:** State both with their source: "For a JDBC URL the How-To passes `MODE="USER=youruser,PWD=yourpwd"`; the
SQLOPEN page documents `UID=` and `PWD=` for a data source name." Or drop the sentence and point to the How-To.

### WR-05: Both JDBC examples pair `select 1` with `getString("COL")` and never close the connection

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:17-42`
**Issue:** `select 1` returns one unnamed column, so `rs!.getString("COL")` raises a SQLException at run time. The
SQL-verb block is marked as placeholders; these two blocks are not, and the new text tells the reader the blocks use
the real `ChileCompany` database. The blocks also close `rs!` and `stmt!` but not `conn!`. The page's remark on
`getJDBCConnection` warns that the object is a license-collapsing connection, and the How-To sample closes `con`.
Copied as written, the example leaks the connection. The blocks match probes d01 and d03, so this was never a
compile defect.
**Fix:** Either mark the query and column as placeholders in the prose, or use the page's own query (`select * from
customer`) with a column of ChileCompany's `customer` table, and add `conn!.close()` as the last line of both blocks
(re-run the gate, and update the probe-equality claim in ledger L089 if the probes change).

### WR-06: The `bbj -tIO` line rests on a PRO/5 paragraph and omits the same page's caveats

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:35-37`
**Issue:** The line is a plain fact (D-22 locked) whose only support in the body is the quoted sentence "Opening and
reading the "IO" device is a direct attachment to your stdin and stdout handles." That sentence sits in the page's
PRO/5-specific section and describes what PRO/5 does when it finds no alias. The page's BBj-specific section says
"In BBj, realname is ignored, and the terminal on which BBj is invoked is used as the device to which the terminal
alias is opened." The command line page says `-t` takes "The alias of a terminal specified in the configuration
file", so whether `-tIO` works without an `IO` alias is not established by either page. The same page warns that the
IO device "is not a terminal and will not translate mnemonics" and causes "garbage on the screen" or `!ERROR=41`; an
agent that prints mnemonics to it gets that. The body says none of this. The only support for `-tIO` in BBj is the
owner's confirmation, which only the Sources footer names.
**Fix:** Keep the line (D-22), but add the page's caveat as its own sentence ("The IO device is not a terminal and
does not translate mnemonics") and say in the sentence that the page quoted is the PRO/5 one. If the project owner
chooses to override D-22, add the configuration-file condition.

### WR-07: "At run time the same defect is !ERROR=26" goes beyond the cited page

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:98-99`
**Issue:** The `!ERROR=26` page lists "Execution Errors" and "Compiler Errors" and then, after both, the BBj cases
("Incompatible types in an assignment involving object expressions", "Attempting to assign a dynamically resolved
object expression to a statically resolved variable"). It does not say whether those occur at run time or at compile
time. Nothing in the probes reproduces a run, and no BBj is run. "At run time" is a claim the page does not make.
**Fix:** "The `!ERROR=26` page lists the same defect (a dynamically resolved object assigned to a statically resolved
variable) as a cause of that error (URL)."

## Info

### IN-01: Command-line synopsis is tagged `bash` but is not valid shell

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:17-19`
**Issue:** `-WD<working directory>` contains `<`, `>` and a space; pasted into a shell it is a redirect with a
syntax error. The block is a template, and the fence tag says it is runnable shell. (Deferred as IN-06 in the plan;
still open.)
**Fix:** Tag it `text`, or show a concrete example such as `bbj -q -WD/path/to/dir -tIO prog.bbj - arg1`.

### IN-02: The Dialog-flag block follows the `setModal` should-fail block with no lead-in

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:16-29`
**Issue:** The paragraph before the blocks now ends on the `setModal` result, so the second block (a dialog that
starts invisible) appears directly under a failing `setModal` example. An agent can read it as the replacement for
`setModal`, the reading the plan forbids. The adjacency is required by D-06 and cannot change.
**Fix:** Put one sentence before the second block: "Example of the Dialog and Invisible flags together (no claim
about modality)."

### IN-03: Remote-database use of `getJDBCConnection(url)` is advertised, but the user/password/mode overloads are not mentioned

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:9-13`
**Issue:** The new text says `url` may be a JDBC URL for a remote or third-party database. The page also documents
`getJDBCConnection(url, mode)`, `(url, props)` and `(url, user, password)`; its own example passes a second argument.
A remote URL usually needs credentials, and the same file gives the credential form for the SQL verbs. The SQL
functions line ("use that database's own functions") is likewise advice the three function pages do not state.
**Fix:** Add "the page also lists overloads taking `mode`, `props`, or `user` and `password`" with the URL. Mark the
third-party function advice as general, not documented there, or delete it.

### IN-04: The REM page cited for the semicolon rule does not state it

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:36-37, 47`
**Issue:** The `rem_verb.htm` body says only "In compound statements, REM may only be the last verb". It states
neither that `;` separates statements nor the label exception. The rules are correct (probes t03, t04), but the
provenance sentence implies the page states them.
**Fix:** "(see https://.../rem_verb.htm: in compound statements REM may only be the last verb; the `;` and the label
exception were reproduced with `bbjcpl` on BBj 26.03)".

### IN-05: "The project owner" is a planning term inside text shipped to end users

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:20`, `plugins/bbj/skills/bbj-programming/references/running.md:48`
**Issue:** An agent reading the shipped skill cannot tell who "the project owner" is or how much weight the
statement carries. It is an honest provenance note for the maintainers, but opaque to the reader.
**Fix:** "confirmed by the skill maintainer on BBj 26.03" (or name the repository owner), consistently in both places.

### IN-06: The sign-character list cites the PRO/5 numeric output page

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:130-133`
**Issue:** The cited page begins "For BBj-Specific Information, see Numeric Output – BBj" and describes PRO/5. It
lists the mask characters but does not say a mask without a sign character drops the minus sign; that sentence rests
on the owner confirmation named in the intro. The BBj-specific page was not checked.
**Fix:** Also cite the BBj Numeric Output page, or say the sentence is the owner-confirmed rule and the page only
lists the characters.

### IN-07: "A program that is run from a shell for the user ends with `RELEASE`" is an instruction no cited page states

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:30-31`
**Issue:** The pages say RELEASE returns control to the host operating system and END/STOP (outside a public program)
place PRO/5 in console mode. The sentence draws the conclusion that a program run from a shell must end with
`RELEASE`; the pages do not say that, and the owner confirmation covers only `-tIO` output.
**Fix:** "`RELEASE` 'returns control to the host operating system'; `END` and `STOP` put PRO/5 in console mode, so a
program run from a shell is usually ended with `RELEASE`." Or label it as advice.

---

_Reviewed: 2026-10-11_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
