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

Read `bbj://primer` before you write BBj; this file adds to it. Most rules here were reproduced with
`bbjcpl` and `bbj-ls` on BBj 26.03. The others cite the documentation page that states them, except the
`str()` sign rule, which the skill maintainer confirmed on BBj 26.03.

## Reading bbjcpl output (BBj 26.03)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm

- Every message goes to stderr and stdout stays empty. A clean file prints nothing; with `-t -N -X` and no `-W`, any stderr line is a finding.
- The exit status is 0 with or without errors. Never branch on it.
- A syntax error is `<file>: error at line N (M): <line>`; a type error is `<file>: type check error [<message>] at line N (M): <line>`. N is the BBj line number (an unnumbered file is numbered by 10); the number in parentheses is the line in the file, so go to M.
- `-W` adds `type check warning [Undeclared variable: ...]` lines. They are information, not failures.
- Always pass `-N -X` when you only check: `-N` writes no output file, `-X` keeps the source extension. `-t -N -X` is the documented check-only combination.
- An unresolved `USE ::file.bbj::Class` is `Cannot find program file.bbj for type: Class`; pass `-P<dir1:dir2>` (directories separated by colons on UNIX-like systems, by semicolons on Windows) or `-c<config.bbx>` (not both) so the file is found.
- Neither `bbjcpl` nor `bbj-ls` validates an event constant: `BBjListBox.ON_LIST_SELECT` passes both. Read the control's Events table in the documentation.

## Rules for writing BBj

A comment on the same line as a statement is its own `rem` statement and needs a `;` before it. The REM page
(https://documentation.basis.cloud/BASISHelp/WebHelp/commands/rem_verb.htm) says "In compound statements, REM may
only be the last verb"; the `;` and the label exception below were reproduced with `bbjcpl` on BBj 26.03. The hook
rejects the other form.

```bbj should-fail
interval = 0 rem Manual
```

```bbj
interval = 0 ; rem Manual
```

A label is the exception: it takes `rem` with no `;`, as in `start: rem label`.

A function-style call is not a statement. An object method call is: `v!.get(0)`, `#foo()` and
`BBjAPI().makeVector()` stand alone. A class method called as `foo()` (write `#foo()`), `str(x:"##0")`,
`cvs(a$,3)` or a `def fn` call alone on a line is a syntax error on both routes; assign the result.

```bbj should-fail
class public Demo
    method public void foo()
    methodend

    method public void run()
        foo()
    methodend
classend
```

```bbj
class public Demo
    method public void foo()
    methodend

    method public void run()
        declare auto BBjVector v!
        v! = BBjAPI().makeVector()
        v!.addItem("a")
        v!.get(0)
        #foo()
    methodend
classend
```

Built in: no USE needed. That holds for BBj classes (`BBjWindow`, `BBjVector`) and the `java.lang` classes (`String`, `Integer`); any other Java class needs `USE java.util.HashMap` or its full name `java.util.HashMap`, and a class from a BBj source file needs `USE ::file.bbj::ClassName`.
Only `bbjcpl` catches a missing USE (`No type named HashMap visible in this scope`); `bbj-ls` passes it.

```bbj should-fail
declare HashMap h!
h! = new HashMap()
```

```bbj
use java.util.HashMap

declare HashMap h!
h! = new HashMap()
```

A value held in an undeclared variable fails the type check when it is assigned to a declared field,
returned from a method with a declared return type, or passed to a method of a declared object. The
messages are `Incompatible assignment from <undeclared> to X`, `Cannot assign <undeclared> to BBjNumber`,
`Method expected return type X, got <undeclared>` (reported at the `methodret` line) and
`No match for method ...(<undeclared>)`. They are errors to fix, never noise. The `!ERROR=26` page lists the
same defect (a dynamically resolved object assigned to a statically resolved variable) as a cause of that error
(https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Errors/_error_26.htm).
Declare the variable with `declare auto <Type> x!` before the assignment; for a string or a number
convert with `str()` or `num()` at the assignment.

```bbj should-fail
use java.util.HashMap

class public Demo
    field private HashMap cfg!

    method private HashMap build()
        config! = new HashMap()
        methodret config!
    methodend
classend
```

```bbj
use java.util.HashMap

class public Demo
    field private HashMap cfg!

    method private HashMap build()
        declare auto HashMap config!
        config! = new HashMap()
        methodret config!
    methodend
classend
```

A numeric mask with no sign character loses the minus sign of a negative value. The sign characters
are `-`, `+`, `(` and `)`, `CR` and `DR` (https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Language_Concepts/numeric_output.htm).
Put one in every mask that can format a negative value. For every other mask character use
`bbj_lookup` on STR() or https://documentation.basis.cloud/BASISHelp/WebHelp/commands/str_function.htm.

```bbj
rate = -1.5
shown$ = str(rate:"-##0.00")
print shown$
```

## Look it up instead

- Read `bbj://primer` before writing BBj. It covers the ternary and IFF, a FOR loop running once, NUM versus INT, DECLARE AUTO with classes only, reserved words, and the default precision and the verbs that reset it.
- `bbj_lookup` for exact syntax: STR() mask characters, MSGBOX constants, bbjcpl options.
- `bbj_reserved_word` before you name a variable; `bbj_examples` for verified code (collections, JDBC, SysGui).
- `bbj_search` for everything else, `bbj_fetch_page` for a whole page. Cite the URL of every page you rely on.

## References

- `references/sysgui.md`: window flags and the Dialog flag, insertItems, clickable images, MSGBOX pointers.
- `references/database.md`: JDBC, SQL verbs, LIMIT (first, count).
- `references/callback-performance.md`: form validation. accept unlocks the window, accept(1) fires the button push, accept(0) rejects; `reject(0)` fails `bbjcpl -t`.
- `references/running.md`: command-line options and RELEASE versus END. Read it only when the user asks to run a program.
