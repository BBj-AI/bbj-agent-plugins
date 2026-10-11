---
name: "bbj-programming"
description: "Write, review, check, or fix BBj code (.bbj, .src and .bbx files) and read bbjcpl output. Use for BBj class and method syntax, statement rules (a trailing rem, bare calls), which classes need USE, type-check errors on undeclared values, str() sign characters, SysGui window flags and list buttons, form validation, JDBC and SQL verbs, and running a program when the user asks. Trigger on symptoms without BBj being named: a syntax error on a line with a trailing rem, No type named HashMap visible in this scope, Incompatible assignment from <undeclared>, Cannot find program for a USE ::file:: line, or a bbjcpl that exits 0 with errors. For browser work (DWC/BUI, HTML, CSS) also use the bbj-web-programming skill."
---

<!-- bbj-check-order:begin -->
**Check BBj code before you hand it back.** Use the first route that exists:

1. `bbjcpl -t -N -X <file>`, when BBj is installed on this machine. It checks syntax and types. `-N` writes no output files; the errors arrive on stderr.
2. `bbj_check_syntax` of the `bbj-local` server (the `bbj-ls` of a running BBjServices, BBj 26.03 or later), when that server is registered. It runs on this machine, against the installation's own PREFIX, classpath and config. It checks syntax only, not types.
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, but tell the user that the code was sent to the server and checked against a stock BBj, not against their installation.

A hook checks the BBj files you write or edit. This order is for code you hand back without writing it to a file: answers, and code from earlier turns.
<!-- bbj-check-order:end -->


# BBj programming

This skill holds only the rules that `bbj://primer` and the documentation do not state. Read the
primer before you write BBj; this file adds what it lacks, each rule checked with `bbjcpl` and `bbj-ls`
on BBj 26.03.

## Reading bbjcpl output (BBj 26.03)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm

- Every message goes to stderr and stdout stays empty. A clean file prints nothing, so any stderr line is a finding.
- The exit status is 0 with or without errors. Never branch on it.
- A syntax error is `<file>: error at line N (M): <line>`; a type error is `<file>: type check error [<message>] at line N (M): <line>`. N is the BBj line number (an unnumbered file is numbered by 10); the number in parentheses is the line in the file, so go to M.
- `-W` adds `type check warning [Undeclared variable: ...]` lines. They are information, not failures.
- Always pass `-N -X` when you only check: `-N` writes no output file, `-X` keeps the source extension. `-t -N -X` is the documented check-only combination.
- An unresolved `USE ::file.bbj::Class` is `Cannot find program file.bbj for type: Class`; pass `-P<dir1:dir2>` or `-c<config.bbx>` (not both) so the file is found.
- Neither `bbjcpl` nor `bbj-ls` validates an event constant: `BBjListBox.ON_LIST_SELECT` passes both. Read the control's Events table in the documentation.

## Rules the primer does not state

A comment on the same line as a statement is its own `rem` statement and needs a `;` before it
(https://documentation.basis.cloud/BASISHelp/WebHelp/commands/rem_verb.htm). The hook rejects the other form.

```bbj should-fail
interval = 0 rem Manual
```

```bbj
interval = 0 ; rem Manual
```

A label is the exception: it takes `rem` with no `;`, as in `start: rem label`.

## Look it up instead

- Read `bbj://primer` before writing BBj. It covers the ternary and IFF, a FOR loop running once, NUM versus INT, DECLARE AUTO with classes only, reserved words, the default precision and the verbs that reset it, and STR() returning a plain string.
- `bbj_lookup` for exact syntax: STR() mask characters, MSGBOX constants, bbjcpl options.
- `bbj_reserved_word` before you name a variable.
- `bbj_examples` for verified code: collections, JDBC, SysGui.
- `bbj_search` for everything else, `bbj_fetch_page` for a whole page.
- Cite the URL of every page you rely on.

## References

- `references/sysgui.md`: window flags and the Dialog flag, insertItems, clickable images, MSGBOX pointers.
- `references/database.md`: JDBC, SQL verbs, LIMIT (first, count).
- `references/callback-performance.md`: form validation. accept unlocks the window, accept(1) fires the button push, there is no reject method.
