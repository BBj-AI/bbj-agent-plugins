---
phase: 04-bbj-programming-makeover
reviewed: 2026-10-11T00:00:00Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - codex/AGENTS-snippet.md
  - plugins/bbj/skills/bbj-programming/SKILL.md
  - plugins/bbj/skills/bbj-programming/references/callback-performance.md
  - plugins/bbj/skills/bbj-programming/references/database.md
  - plugins/bbj/skills/bbj-programming/references/running.md
  - plugins/bbj/skills/bbj-programming/references/sysgui.md
  - tests/skills_baseline.json
findings:
  critical: 0
  warning: 8
  info: 7
  total: 15
status: issues_found
---

# Phase 4: Code Review Report

**Reviewed:** 2026-10-11
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

Reviewed the rewritten `bbj-programming` skill, its four references, the Codex snippet and the baseline JSON.
Checks done: every `documentation.basis.cloud` URL in the skill answers 200 (28 URLs); every quoted
sentence in `running.md`, `sysgui.md`, `callback-performance.md`, `database.md` and the numeric mask list in
`SKILL.md` was compared with the fetched page text; the live gate
(`BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`) shows no failure for `bbj-programming`; nothing
under `plugins/`, `docs/`, `codex/`, `tests/` or `README.md` still links to `java-interop.md` or
`reserved-words.md`; the `bbj-check-order` block is identical in `SKILL.md` and the snippet; `SKILL.md`
index lists only files that exist.

No blocker. The quotes are accurate and the code blocks pass both live routes. The defects are claims that
go beyond what their cited page or probe shows, one ledger "rewrite" that was not delivered, a provenance
footer that overstates what was verified, and a few examples that do not demonstrate what their heading
says.

## Warnings

### WR-01: "each rule checked with bbjcpl and bbj-ls" is false for the sign-mask rule (and contradicts the next sentence)

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:18-20`, `:130-139`
**Issue:** The intro says "this file adds what it lacks, each rule checked with `bbjcpl` and `bbj-ls` on BBj
26.03" and that the skill holds "only the rules that `bbj://primer` and the documentation do not state".
Neither holds. The `str()` sign rule (L031) is OWNER-confirmed: the ledger records that the probe
`t21_str_sign.bbj` only compiles the corrected example and "is not evidence for the trap". The `rem`, `-N -X`,
`-W` and `!ERROR=26` rules are stated by documentation pages that the file itself cites. The skill's central
promise (documented or reproduced) is therefore misdescribed to the agent, and the agent cannot tell
compile-checked rules from owner-confirmed ones.
**Fix:** Reword the intro, for example: "This skill holds rules the primer does not state. Most were
reproduced with `bbjcpl` and `bbj-ls` on BBj 26.03; the others cite the documentation page that states them."
Mark the mask rule as owner-confirmed or drop the "each rule checked" wording.

### WR-02: Dialog flag is offered as the replacement for `setModal` without any documented modality

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:9-28`
**Issue:** The text says a window has no `setModal` method and then "Pass the Dialog flag when the window is
created." The only documented effect of `$00080000$` is "Sets the window to behave as a dialog" (verified on
the addWindow page); the page does not say a Dialog window is modal. Ledger L117 reads "Modality is a
creation flag", but its evidence is only that same sentence plus a compile probe, which cannot show
modality. An agent will ship the flag as if it were `setModal`.
**Fix:** State only what is documented ("the Dialog flag makes the window behave as a dialog") and drop the
implied substitution, or add a source or owner confirmation that Dialog gives modal behavior.

### WR-03: Clickable-image rule contradicts the page it quotes, and the example has no image

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:49-74`
**Issue:** The section quotes that low-level mouse events are by default reported for "static text, image,
group box", then instructs "Call `setReportAllMouseEvents(1)`" unconditionally. By the quoted text an image
already reports its mouse events; the call is only needed for other controls. Nothing in the section says
when it is required. The example adds no image control (or any control), and `onImageClick` only assigns
`ctrl!` and does nothing with it, so it does not show a clickable image. The listing also does not show how
the clicked control is told apart.
**Fix:** Say "`setReportAllMouseEvents(1)` makes every control on the window report mouse events; an image
reports them without it (page quote)". Make the example add an image control (or rename the section to
"Mouse events from controls") and act on `ctrl!`, for example compare it with a stored field.

### WR-04: `getJDBCConnection` argument is named and exemplified wrongly; ledger rewrite L089 not delivered

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:9-10`, `:17`, `:31`
**Issue:** Ledger L089 says the rewrite must "say the argument is a JDBC URL or a BBj database name (the old
comment said 'registered BBj datasource name')". The shipped text writes `getJDBCConnection(name)` and uses
`"MyDatasource"` in both blocks and never states what the argument is. The cited page says the parameter is
`url`: the name of a BBj database defined in the Enterprise Manager (case must match exactly), or a JDBC
connection URL. "Datasource" is the wording the rewrite was meant to remove.
**Fix:** Write `getJDBCConnection(url)` and add: "`url` is the name of a BBj database as defined in the
Enterprise Manager (the case must match), or a JDBC connection URL." Use a database name in the examples,
for example `"ChileCompany"`, or mark `MyDatasource` as a placeholder.

### WR-05: "only the functions they list" is broader than the evidence

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:76-83`
**Issue:** "Use them, and only the functions they list" is a new restriction. The cited pages are the BBj
data-source driver pages (`b3odbc/SQL/bbjds_*`). The same file shows `getJDBCConnection` and `SQLOPEN` with a
JDBC URL, which per the getJDBCConnection page may point at "a remote or third party database", whose SQL
functions are that database's own. Ledger L093 only records that the pages exist ("answers 200"); no page or
probe says the driver rejects other functions. The earlier "lower-case function" claim was dropped as wrong;
this sentence reintroduces a similar absolute.
**Fix:** "For a BBj database the string, numeric and time-and-date functions are listed on these pages; for a
third-party database use that database's functions."

### WR-06: running.md footer claims verification against the listed pages that two rules do not have

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:34-36`, `:45`
**Issue:** The last line says "Verified on BBj 26.03 against the documentation pages listed; nothing was run".
The `bbj -tIO` rule (L072) is OWNER-confirmed and its cited page is the PRO/5 Unix terminals page, which says
the IO device is the fallback when no alias line fits and that opening it "is a direct attachment to your
stdin and stdout handles". It does not say `bbj -tIO` selects it, and that page is explicitly a PRO/5
configuration page. The `-t` page text says only that the alias must be one "specified in the configuration
file", so `-tIO` works only if the installation's config defines it (the ledger says alias numbers are
site-configurable), yet the file states it as a plain fact with no condition. This is a statement of
provenance that the evidence does not support.
**Fix:** Change the last line to name what was checked ("RELEASE, END and the option descriptions were
checked against the pages listed; `bbj -tIO` was confirmed by the project owner on BBj 26.03; nothing was
run"), and state the condition ("when the configuration file defines the `IO` alias").

### WR-07: END/STOP behavior stated without the page's own condition

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:27-30`
**Issue:** The page says "When not in a public program, both END and STOP: ... Place PRO/5 in console mode",
and that "In a public program, END and STOP are identical to EXIT". The file drops the condition and adds "so
it stays open", which is an inference (the page is PRO/5 text). It then advises "A program that is run from a
shell for the user ends with `RELEASE`" directly under a bullet saying RELEASE rolls back all uncommitted
transactions, with no link between the two: a program that relied on END and then has RELEASE added loses
uncommitted work.
**Fix:** "`END` and `STOP`, outside a public program, place the interpreter in console mode (page quote)."
Add: "`RELEASE` rolls back uncommitted transactions, so commit first."

### WR-08: SQL-verb example uses unmarked placeholders that read as a working program

**File:** `plugins/bbj/skills/bbj-programming/references/database.md:53-65`
**Issue:** `DATABASE=Demo`, `select * from t` and `rec.col$` are invented names, and the block carries no
credentials or `MODE=` option while the cited How-To sample uses `MODE="USER=...,PWD=..."`. The block passes
the compiler (placeholders compile), so the gate cannot flag it, but an agent copies it as if it were the
documented sample. The intro sentence of the file also says the How-To page has BBj examples "for both"
JDBC and SQL verbs; the page's BBj sample is the SQL-verb form only and its JDBC sample is Java.
**Fix:** Add a line "Replace the URL, table and column with your own" and mention `MODE=` for credentials.
Correct the intro to "Java code for JDBC and BBj code for the SQL verbs".

## Info

### IN-01: `callback-performance.md` name does not match its content

**File:** `plugins/bbj/skills/bbj-programming/references/callback-performance.md:1`
**Issue:** The file holds form-validation rules only; "performance" is a leftover from the old file. The
sibling skill has `form-validation.md`, so two files with similar subjects have unrelated names. Renaming was
presumably avoided to keep the old path, but nothing links to it from outside the skill.
**Fix:** Rename to `form-validation-callback.md` and update the index line in `SKILL.md`.

### IN-02: `ON_FORM_VALIDATION` in the heading is unsourced and no registration is shown

**File:** `plugins/bbj/skills/bbj-programming/references/callback-performance.md:1-34`
**Issue:** The cited page never mentions `ON_FORM_VALIDATION`, and `SKILL.md:32` says neither compiler
validates event constants, so the heading's constant is unverified. The example declares the handler but not
how it is registered, and `failed = 0 / if failed = 0` is a constant condition with an unreachable `else`.
**Fix:** Cite the page that names the constant, add the `setCallback(...)` line, and replace the constant
condition with a real check (for example an empty-field test).

### IN-03: `SKILL.md` "Look it up" points at primer content known to be stale

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:143`
**Issue:** It says the primer covers "STR() returning a plain string". The phase ledger (S5, G10) records that
primer paragraph `two_string_worlds/10` is stale against the BBj STR() page. The skill also cites the PRO/5
pages `commands/str_function.htm` and `usr/Language_Concepts/numeric_output.htm`; the BBj-specific page is
`commands/bbj-commands/str_function_bbj.htm` (it carries the BBj-only `U` mask and the `01 23` Integer
example), and the PRO/5 page itself says "For BBj-specific information, see STR() Function - BBj".
**Fix:** Cite `str_function_bbj.htm` next to `str_function.htm`, and drop the STR() item from the list of what
the primer covers until the primer is fixed.

### IN-04: "any stderr line is a finding" vs "warnings are not failures"

**File:** `plugins/bbj/skills/bbj-programming/SKILL.md:26`, `:29`
**Issue:** Line 26 says any stderr line is a finding; line 29 says `-W` lines "are information, not failures".
Both are right under different options but a reader following line 26 will treat a `-W` warning as an error.
Line 26 is also unconditional although the page says `bbjcpl` writes to stdout when run as a pipe, which is
why `-N` matters.
**Fix:** "With `-t -N -X` and no `-W`, any stderr line is a finding."

### IN-05: `references/sysgui.md` dropped the documented "call `setVisible(1)`" half of ledger L116

**File:** `plugins/bbj/skills/bbj-programming/references/sysgui.md:7-10`
**Issue:** L116 (verdict keep) says `addWindow()` creates the window visible unless Invisible is passed and
`setVisible(1)` shows it. The shipped text states only the flag, so an agent who creates an invisible window
has no stated way to show it.
**Fix:** Add one line: "A window created with the Invisible flag is shown with `setVisible(1)`", with a source.

### IN-06: `running.md` synopsis is tagged `bash` but is not a command

**File:** `plugins/bbj/skills/bbj-programming/references/running.md:17-19`
**Issue:** The block has `<working directory>` with a space and angle brackets; pasted into a shell it is a
redirection and a syntax error. It also shows every option as required while the page marks all of them
optional (`{...}`). The gate accepts `bash`, but `text` matches the purpose. The `-c` description on the page
says "on the remote machine" (Thin Client page); the file quotes it but presents the option as local.
**Fix:** Use a `text` fence and write the optional options in braces, as the page does:
`bbj {-q} {-WD<dir>} {-t<alias>} {-c<file>} {<program> {- <arglist>}}`.

### IN-07: Duplicated "Built in" sentence in two places and a vague phrase in `SKILL.md`

**File:** `codex/AGENTS-snippet.md:21`, `plugins/bbj/skills/bbj-programming/SKILL.md:79`, `:37-38`
**Issue:** The "Built in: no USE needed..." paragraph is copied word for word into the snippet and the skill;
unlike the check-order block there is no test that keeps them equal, so the two can drift (this phase had to
edit both). `SKILL.md:37-38` says "The hook rejects the other form", where "the other form" has no clear
referent. The snippet's tool list omits `bbj_check_syntax` although its check-order block tells the agent to
use it.
**Fix:** Add a test (or markers) that compares the two paragraphs, write "The hook rejects a `rem` without the
`;`", and add `bbj_check_syntax` to the tool list of the snippet.

---

_Reviewed: 2026-10-11_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
