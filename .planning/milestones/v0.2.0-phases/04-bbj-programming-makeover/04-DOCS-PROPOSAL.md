# Documentation improvement proposal: BBj language pages (from the bbj-programming rewrite)

To: the BASIS documentation owners
From: the bbj-agent-plugins repository, Phase 4 (bbj-programming makeover), 2026-10-11
Status: not shipped. This file is a planning document of the repository. Nothing in the BASIS
documentation, in the documentation server or in the primer was edited from this repository, and
nothing here was sent anywhere. Every change below is a suggestion for the owners to accept, reword
or reject.

Why this exists. Phase 4 rewrote the `bbj-programming` agent skill so that it states only facts that
are documented (page URL) or reproduced on a real BBj. Every rule of the old skill went into a claim
ledger (`04-LEDGER.md`). Where a rule survives only because a compile probe shows it, or because the
project owner confirmed it, the documentation is silent on a thing agents and people trip over. This
file is the list of those gaps, the STR() chapter first, each with suggested wording.

How evidence is given.

- Page evidence: the page URL under https://documentation.basis.cloud/BASISHelp/WebHelp/ and one
  sentence quoted from the official page body, read from the page file itself on 2026-10-11. Text
  that the documentation server appends to a page, or serves as a search result labelled "not a
  citable page", is never used as evidence (see the last section).
- Compile evidence: a probe file `probes/<name>.bbj` in the Phase 4 directory and the matching lines
  of `probes/OUTPUT.txt`, produced with `bbjcpl -t -N -X` and with the `bbj-ls` check on BBj 26.03.
  Probes are compiled only. Nothing was run, because this repository never runs BBj.
- Owner evidence: a behaviour that no page states and no compile can show, confirmed on a real BBj
  by the project owner. It is named as such with confirmer, date and version, and carries its OWNER
  ledger id.
- Ledger ids (L0NN) refer to rows of `04-LEDGER.md`.

## STR(): masks, sign, return type, trimming

Five gaps, S1 to S5. S1 and S2 are one finding seen from two pages. Pages involved:

- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/str_function.htm (PRO/5 page)
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/str_function_bbj.htm (BBj page)
- https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Language_Concepts/numeric_output.htm (Numeric Output)
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/cvs_function.htm (CVS())

### S1. The STR() page gives no sign guidance for numeric masks (OWNER-confirmed, L031)

Page: `commands/str_function.htm`.

Says today: "The result can be formatted using the optional string mask. See Numeric Output for more
information." Its four examples are `STR(123:"0000")`, `STR(52.3)`, `STR(3352.3:"$##,##0.00")` and
`STR("abcdefg":"XX-XXX-XX")`; none of them has a negative value.

Lacks: the one trap agents and people fall into with numeric masks. A mask with no sign character
loses the minus sign of a negative number, and the page does not say so, nor which characters carry
the sign.

Evidence: confirmed by Stephan Wald, 2026-10-11, BBj 26.03, the project owner, on a real BBj
(OWNER ledger id L031; granted in the Phase 4 context, decisions D-21 and D-22). No documentation
page states it and no compile check can show a printed result, and this repository never runs BBj,
so the observation is the owner's, not a probe's. The only probe on this subject,
`probes/t21_str_sign.bbj` (`str(rate:"-##0.00")` with `rate = -1.5`), passes `bbjcpl -t -N -X` and
`bbj-ls` and proves only that the corrected example compiles, not what it prints.

Request: please amend the STR() page and, as S2, the Numeric Output page with the sentence below and
a negative-value example.

Suggested wording for the STR() page, after the sentence that links to Numeric Output:

> A numeric mask shows the minus sign of a negative value only if it contains a sign character:
> `-`, `+`, `(`, `)`, `CR` or `DR`. A mask with none of them, such as `"##0.00"`, loses the minus
> sign, so `-1.5` and `1.5` look the same. Start the mask with `-` or `+` when the value can be
> negative.

Suggested example (the result column is for the owners to fill from a real run, as this repository
cannot produce it):

| Statement | Result |
| --- | --- |
| `PRINT STR(-1.5:"-##0.00")` | to be filled from a real run |
| `PRINT STR(-1.5:"##0.00")` | to be filled from a real run |

The same finding in the shape of the documentation server's "Notes for Agents" (Rule, Why, Edge,
Evidence, Example), which the docs server now offers:

- Rule: put a sign character in every numeric `STR()` mask that can receive a negative value.
- Why: a mask without one drops the minus sign, and the printed number is then wrong in sign.
- Edge: the floating characters `-`, `+`, `$` and `(` move to the last position where a `#` or `,`
  became the fill character (Numeric Output page), so the sign sits next to the first digit.
- Evidence: confirmed by Stephan Wald, 2026-10-11, BBj 26.03 (L031); the Numeric Output page lists
  the sign characters; `probes/t21_str_sign.bbj` compiles on both routes.
- Example, which passes `bbjcpl -t -N -X` and `bbj-ls`:

```bbj
rate = -1.5
shown$ = str(rate:"-##0.00")
print shown$
```

### S2. The Numeric Output page never says what a mask without a sign character does (OWNER-confirmed, L031)

Page: `usr/Language_Concepts/numeric_output.htm`.

Says today: it lists the special mask characters and, for the sign, "The minus sign creates a "-" in
the result if the number is negative; otherwise, it is replaced by the fill character." and "The plus
sign becomes a "+" in the result if the number is positive, or a "-" if the number is negative."

Lacks: a sentence on a mask that contains none of `-`, `+`, `(`, `)`, `CR`, `DR`, and a negative
example anywhere on the page. The reader has to infer the consequence from the absence of a
character.

Evidence: the same owner confirmation as S1: confirmed by Stephan Wald, 2026-10-11, BBj 26.03
(L031, D-21, D-22). Again no compile check can show it; nothing was run here.

Suggested wording, after the table of mask characters:

> If the mask contains none of the characters `-`, `+`, `(`, `)`, `CR` or `DR`, nothing in the result
> can show that the number is negative: the minus sign is lost. For example, `STR(-1.5:"##0.00")`
> has no sign position; use `STR(-1.5:"-##0.00")` to keep the sign.

(Owners: please add the real printed results of both statements from a run. The statement that
matters is the first sentence, which is the owner-confirmed fact; the printed digits were never
observed by this repository.)

### S3. The return type of STR() is ambiguous: it is a string primitive

Pages: `commands/str_function.htm` and `commands/bbj-commands/str_function_bbj.htm`.

Says today: the PRO/5 page, "The first STR() function above returns an ASCII string representing the
value of its numeric argument." The BBj page, "In BBj, the STR() function accepts arguments of any
type. If the argument evaluates to a number, STR(num) is used, otherwise STR(str) is used." (The
documentation server's rendering of the BBj page shows a "RETURN TYPE: String" summary line, RESEARCH
S3; the page file itself does not carry it, so it is not relied on here.)

Lacks: whether the result is a primitive string or a BBjString object. Agents and people infer "a
string object" and write `str(n:mask).trim()`.

Evidence: `probes/t12_str_trim.bbj` (`? str(n:"-##0.00").trim()`): `bbjcpl -t -N -X` reports
`error at line 20 (2): ? str(n:"-##0.00").trim()` and `bbj-ls` reports
`line 2, column 1: [SyntaxError] syntax error` (`probes/OUTPUT.txt`, section `== t12_str_trim.bbj`),
so a method call chained on the result is a syntax error on both routes. `probes/t14_cast.bbj`
(`s! = cast(BBjString, str(n:"-##0.00"))`, then `s!.trim()`) is clean on both routes. Ledger id L039.

Suggested wording, for the Description of both pages:

> STR() returns a string primitive, not a BBjString object, so a method cannot be chained on the
> result: `STR(n:mask).trim()` is a syntax error. Assign the result to a variable first, or use
> CVS() (see the example below).

### S4. No trim idiom for the fixed-width result: CVS(STR(n:mask),3)

Pages: `usr/Language_Concepts/numeric_output.htm` and `commands/cvs_function.htm`.

Says today: Numeric Output, "The resulting string is always the same size as the mask." CVS(), in
the table of values for `int`, `1` is "Strip leading spaces." and `2` is "Strip trailing spaces.",
and "A combination of operations may be specified by adding functional values."

Lacks: a pointer from the STR() and Numeric Output pages to the way to remove the padding that a
mask leaves, and an example. Flag 3 is 1 + 2 (strip leading and trailing spaces), which the CVS()
page implies and never shows for this case.

Evidence: `probes/t13_cvs.bbj` (`x$ = cvs(str(n:"-##0.00"), 3)`): clean on `bbjcpl -t -N -X` and
`bbj-ls` (`probes/OUTPUT.txt`, section `== t13_cvs.bbj`). The padding itself is the page's own
sentence above. Ledger id L039 (the same row as S3).

Suggested wording, after the sentence about the fixed width on the Numeric Output page and on the
STR() page:

> The result is always as long as the mask, padded with the fill character. To remove leading and
> trailing spaces use `CVS(STR(n:mask),3)`; the flag 3 is 1 + 2 (see CVS()).

### S5. The primer paragraph two_string_worlds/10 still describes the old Integer example

Pages: `commands/bbj-commands/str_function_bbj.htm` and the BBj primer (`bbj://primer`, docs build
2026-09-29, hash 3d63c5e4).

Says today: the BBj page, in its examples, `X!=new java.lang.Integer(123)` then
`PRINT STR(X!:"00-00"); REM ' numeric masking` and the result `01 23`.

Lacks: agreement. The primer paragraph `two_string_worlds/10` still describes the example from the old
skill text (the `Integer` example returning `12-3`), which the BBj page no longer shows (RESEARCH S5,
ledger id L038). A reader who trusts the primer gets a result the page contradicts.

Evidence: the page text above, read on 2026-10-11; the old skill claim is ledger row L038 (verdict
drop: nothing of the example is kept in the rewritten skill).

Suggested action for the primer owners: replace the example with the page's, or remove the sentence.
Suggested page-level change: none; the page is right.

## Rules kept on compile evidence (the documentation is silent)

Every rule below survives in the rewritten skill because a probe shows it on BBj 26.03 and the page
named under it does not state it. Each entry has the ledger id, the probe and the lines of
`probes/OUTPUT.txt` (section `== <probe>`), and suggested wording. "bbj-ls clean" means the `bbj-ls`
route accepts the program; where only `bbjcpl -t` reports the problem the entry says so.

### The bbjcpl page (gap G1)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm

Says today: "All error messages are written to stderr." and "All error messages contain both the BBj
line number and the ASCII file line number." and, for the options, "Perform just a type check by
combining the options -t-N-X". It does not state the exit status, the shape of a message, what a
clean file prints, or what an unresolved `USE ::file::` looks like.

- L060, exit status. Probe: the header lines of `probes/OUTPUT.txt`, `bbjcpl -t -N -X, one batched
  call: exit status 0, stdout 0 bytes`; the batch holds the failing probes `probes/t03_rem_bad.bbj`,
  `probes/t10_quote_bad.bbj` and the `e26` probes, so bbjcpl exits 0 while it reports errors.
  Suggested wording: "bbjcpl exits with status 0 whether or not it reports errors. The errors are on
  stderr; standard output stays empty. Check the messages, not the exit status." (Observed on BBj
  26.03; the owners should confirm that this is intended and stable.)
- L148, message shapes and the clean file. Probes: `probes/q01_numbered.bbj`
  (`bbjcpl: ... error at line 20 (2): y = 2 rem bad`), `probes/e26a.bbj`
  (`type check error [Incompatible assignment from <undeclared> to BBjString] at line 50 (5):
  #theme! = dwcTheme!`), `probes/t04_rem_ok.bbj` (`bbjcpl: clean`, nothing printed) and
  `probes/q04_undeclared_w.bbj` (with `-W`: `type check warning [Undeclared variable: raw!] at line 10
  (1): raw! = null()`). Suggested wording: "bbjcpl prints one record per problem. A syntax error reads
  `error at line N (M): <source line>`, a type error `type check error [<message>] at line N (M):
  <source line>`, and with `-W` a warning `type check warning [<message>] at line N (M): <source
  line>`. N is the BBj line number and M the line of the file. A file without problems prints
  nothing." (The related ledger rows L062, line numbers, and L058, the `-W` warnings, are
  documented in part; the page does not show the record shapes.)
- L149, unresolved USE. Probe: `probes/q03_use_missing.bbj` (`use ::missing.bbj::Foo`):
  `type check error [Cannot find program missing.bbj for type: Foo] at line 10 (1): use
  ::missing.bbj::Foo` and the same at line 30 (3), `f! = new Foo()`; bbj-ls clean, so only
  `bbjcpl -t` reports it. Suggested wording: "With `-t`, a `USE ::file::Class` that cannot be
  resolved is a type check error, reported on the `USE` line and on each `NEW Class()`."

### The !ERROR=26 page (gap G2)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Errors/_error_26.htm

Says today: "In BBj, this error can also indicate the following errors: Incompatible types in an
assignment involving object expressions Attempting to assign a dynamically resolved object expression
to a statically resolved variable Attempting to pass a dynamically resolved object expression to a
method call on a statically resolved object expression." (The page lists the BBj causes; ledger row
L008 keeps them as the documented basis of the skill's rule.) It has no example, none of the messages
the type checker prints for these causes, and no fix.

Lacks, and suggested wording: a short table of the compile-time messages with the fix, after the
bulleted list. The seven entries below are the evidence for it. In each, `bbjcpl -t` reports the
message and bbj-ls is clean, so the type checker of `bbjcpl` is the route that shows them.

- L010, a proxy getter assigned to a typed field. `probes/e26a.bbj`: `type check error [Incompatible
  assignment from <undeclared> to BBjString] at line 50 (5): #theme! = dwcTheme!`; the fix
  `#theme! = str(dwcTheme!)` in `probes/e26b.bbj` is clean on both routes.
- L011, an undeclared local assigned to a numeric field. `probes/e26c.bbj`: `type check error [Cannot
  assign <undeclared> to BBjNumber] at line 50 (5): #total = t!`; `probes/e26d.bbj`
  (`declare auto BBjNumber t!`) is clean on both routes.
- L012, an undeclared local returned from a method with a declared type. `probes/e26e.bbj`: `type
  check error [Method expected return type java.util.HashMap, got <undeclared>] at line 80 (8):
  methodret config!`; `probes/e26f.bbj` (`declare auto HashMap config!`) is clean on both routes.
- L014, a method call on an undeclared receiver assigned to a typed field. `probes/e26g.bbj`: `type
  check error [Incompatible assignment from <undeclared> to
  com.basis.bbj.proxies.sysgui.BBjListButton] at line 50 (5): #lb! = fg!.addListButton(101, 10, 10,
  100, 20, "")`; `probes/e26h.bbj` (`declare auto BBjChildWindow fg!`) is clean on both routes.
- L018, an undeclared value passed as a method argument. `probes/a01_undecl_arg_user.bbj`: `type
  check error [No match for method ::a01_undecl_arg_user.bbj::Demo.show(<undeclared>)] at line 60
  (6): #show(x!)`; `probes/a02_undecl_arg_api.bbj`: `No match for method
  com.basis.bbj.proxies.BBjAPI.postCustomEvent(BBjString, <undeclared>)`; `probes/a03_declared_arg_api.bbj`
  (declared `x!`) is clean on both routes. This is the third bullet of the page.
- L015, the fix by declaration. `probes/e26d.bbj`, `probes/e26f.bbj` and `probes/e26h.bbj` above:
  declare the local that is assigned or returned, `declare auto <type> x!`. The DECLARE page says
  "the TypeChecker will generate an error when the code is type checked", and never connects that to
  this error.
- L016, the fix for a simple primitive. `probes/e26b.bbj` (`#theme! = str(dwcTheme!)`) and
  `probes/e26i.bbj` (`#total = num(t!)`, `t!` undeclared, field `BBjNumber total`): clean on both
  routes. Suggested wording: "Wrap the value in `STR()` for a string destination or in `NUM()` for a
  numeric one."

A suggested table for the page:

| Message printed by `bbjcpl -t` | Cause | Fix |
| --- | --- | --- |
| `Incompatible assignment from <undeclared> to <type>` | an undeclared value stored in a typed variable or field | `DECLARE AUTO <type> x!`, or `STR()` / `NUM()` around a primitive |
| `Cannot assign <undeclared> to BBjNumber` | an undeclared local stored in a numeric field | the same |
| `Method expected return type <type>, got <undeclared>` | an undeclared local returned with `METHODRET` | the same |
| `No match for method <name>(<undeclared>)` | an undeclared value passed as an argument | declare the variable that is passed |

### The USE page (gap G3)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/commands/use_verb.htm

Says today: "BBj locates this file using its normal file resolution procedures, checking the current
working directory and prefix." and "The USE verb must be the only statement on the line (with one
exception: it can end with a ; REM comment)." It does not say which classes need no `USE`.

- L145, scope of USE. Probes: `probes/u01_bbjclass_nouse.bbj` (BBj classes such as `BBjWindow`,
  `BBjVector`, `BBjTopLevelWindow`) and `probes/u02_string_nouse.bbj` (`String`, `Integer`, `Math`,
  `System`): clean on both routes with no `USE`. `probes/u03_hashmap_nouse.bbj`: `type check error [No
  type named HashMap visible in this scope] at line 10 (1): declare HashMap h!` and at line 20 (2):
  `h! = new HashMap()`; `probes/u04_arraylist_nouse.bbj`: the same for `ArrayList`; bbj-ls clean for
  both. `probes/u05_hashmap_use.bbj` (`use java.util.HashMap`) and `probes/u08_fullname_hashmap.bbj`
  (the full name `java.util.HashMap`): clean on both routes. Suggested wording: "BBj classes and
  `java.lang` classes need no `USE`. Any other Java class needs `USE java.util.HashMap` or its full
  name; without either, `bbjcpl -t` reports `No type named HashMap visible in this scope`. Classes
  defined in BBj source files use `USE ::file.bbj::ClassName`."
- L101 (related), the old reference file named `LinkedHashMap` and `Map` in method signatures with no
  `USE`; the same probes `u03` and `u04` show that this does not type check. The wording above covers
  it.
- L147 (related), `use BBjWindow` is a syntax error. `probes/u06_use_bbjwindow.bbj`: `error at line
  10 (1): use BBjWindow`, bbj-ls `line 1, column 1: [SyntaxError] syntax error`;
  `probes/u07_use_bbjwindow_full.bbj` (`use com.basis.bbj.proxies.sysgui.BBjWindow`): clean on both
  routes. Suggested wording: one sentence on the USE page that the BBj classes need no `USE` and
  that a short BBj class name after `USE` is a syntax error.

### Statements, REM and the label exception (gap G4)

Pages: https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Language_Concepts/commands_and_statements.htm
and https://documentation.basis.cloud/BASISHelp/WebHelp/commands/rem_verb.htm

Says today: "The statements within a compound statement must be separated by semicolons"
(Commands and Statements) and "In compound statements, REM may only be the last verb" (REM). No page
says that a function call is not a statement, and the REM page has no same-line example (the USE
page does, `; REM`).

- L143, a function-style call is not a statement. `probes/t06_bare_fn_call.bbj`: `error at line 30
  (3): doSomething(v!.get(0))`; `probes/b01_bare_str.bbj` (`str(rate:"+##0.0#")`) and
  `probes/b02_bare_cvs.bbj` (`cvs(a$, 3)`): `error at line 20 (2)`; `probes/b07_bare_user_fn.bbj`
  (`fnTwice(3)`): `error at line 20 (2)`; `probes/b08_class_bare_nohash.bbj` (`foo()` inside a class,
  no `#`): `error at line 60 (6)`. bbj-ls reports `line N, column 1: [SyntaxError] syntax error` for
  each. Suggested wording: "A call written as `name(args)` is not a statement: a built-in
  function, a user function or a bare method name inside a class cannot stand alone on a line.
  Assign the value or use it in an expression."
- L144, an object method call is a statement. `probes/t07_bare_method.bbj` (`v!.get(0)`),
  `probes/t08_bare_hash_method.bbj` (`#foo()` in a class), `probes/b04_bare_api_chain.bbj`
  (`BBjAPI().makeVector()`) and `probes/b06_bare_static.bbj` (`java.lang.System.gc()`): clean on
  both routes. Suggested wording: the counterpart of the sentence above.
- L146, a label takes `REM` with no `;`. `probes/t05_label_rem.bbj` (`start: rem label ok`): clean
  on both routes. In contrast `probes/t03_rem_bad.bbj` (`interval = 0 rem Manual`): `error at line
  10 (1): interval = 0 rem Manual`, bbj-ls `line 1, column 1: [SyntaxError] syntax error`, and
  `probes/t04_rem_ok.bbj` (`interval = 0 ; rem Manual`): clean (ledger row L003, documented by the
  REM page in part). Suggested wording for the REM page: "A comment after code on the same line is
  written `; REM text`. A label may be followed by `REM` directly: `start: REM text`."

### The DECLARE page (gap G5)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/commands/declare_verb.htm

Says today: "Any attempt to assign an expression that is not of the correct type will result in a
runtime error." It does not say which types `DECLARE AUTO` accepts.

- L006. `probes/t15_declare_auto_iface.bbj` (`declare auto java.util.List l!`): `error at line 10
  (1): declare auto java.util.List l!`, bbj-ls `line 1, column 1: [SyntaxError] syntax error`;
  `probes/t16_declare_iface.bbj` (plain `declare java.util.List l!`): clean on both routes. The row's
  verdict is drop (the shipped skill no longer carries the rule), the gap on the page stays.
  Suggested wording: "`DECLARE AUTO` does not accept an interface type such as `java.util.List`;
  use `DECLARE`."

### SysGui: modality, MSGBOX constants and event constants

- L118, `setModal()` on a top-level window. Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm
  says "$00080000$ Dialog : Sets the window to behave as a dialog."
  `probes/s01_setmodal.bbj` (`win!.setModal(1)`): `type check error [No match for method
  com.basis.bbj.proxies.sysgui.BBjTopLevelWindow.setModal(BBjInt)] at line 50 (5): win!.setModal(1)`,
  bbj-ls clean; `probes/s02_dialogflag.bbj` (`addWindow(10, 10, 300, 200, "Demo", $00080010$)`,
  Dialog plus Invisible): clean on both routes.
  Question for the owners of the `addWindow` page: please confirm whether a top-level window has a `setModal()` method
  and, if it has none, whether the page should say so; the evidence above is that `bbjcpl -t` rejects
  `setModal(BBjInt)` and `bbj-ls` accepts it.
  The WINDOW mnemonic page (https://documentation.basis.cloud/BASISHelp/WebHelp/mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm)
  names "the dialog behavior flag ($00080000$), that creates a modal dialog", and the `isModal()` example creates its
  modal window with `$00080083$`. Suggested wording for the Dialog entry of the `addWindow` page:
  "$00080000$ Dialog : Sets the window to behave as a modal dialog." (ledger L117, restored to DOC in plan 04-08;
  the owner-confirmed rule for windows without the Dialog flag that already existed is L151, in the owner-confirmed section).
- L150, a misspelled `MSGBOX` constant. Page:
  https://documentation.basis.cloud/BASISHelp/WebHelp/commands/bbj-commands/msgbox_function_bbj.htm
  lists the constants (for example `MSGBOX_BUTTONS_YES_NO`) and does not say that the compiler
  checks them. `probes/s09_bad_const.bbj`: `type check error [No such field:
  com.basis.bbj.proxies.BBjSysGui.MSGBOX_NOSUCH_CONSTANT] at line 10 (1): flags =
  BBjSysGui.MSGBOX_NOSUCH_CONSTANT`, bbj-ls clean; `probes/s08_msgbox.bbj` (the real constants):
  clean on both routes. Suggested wording: "`bbjcpl -t` reports a misspelled `BBjSysGui.MSGBOX_...`
  constant as `No such field`."
- L064, the compiler does not validate event constants. Page:
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistbox/BBjListBox.htm
  has an Events table with `ON_LIST_CLICK` and `ON_LIST_DOUBLE_CLICK` and no `ON_LIST_SELECT`;
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/Window/bbjlistbutton/bbjlistbutton.htm
  lists `ON_LIST_SELECT` (`BBjListSelectEvent`). `probes/ev01_list_select.bbj`
  (`#lb!.setCallback(BBjListBox.ON_LIST_SELECT, #this!, "onSelect")` on a `BBjListBox`): clean on
  both routes. Suggested wording for the callback pages: "The compiler does not check that a control
  supports a callback constant; read the control's own Events table."

### BBjFormValidationEvent (gap G6)

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bbjevents/BBjFormValidationEvent/bbjformvalidationevent_accept.htm

Says today: "valid Indicates whether the form is accepted (1) or rejected (0)." The page has
`accept(boolean valid)` and no other method; it never says that no `reject()` exists.

- L086. `probes/s04_formval_reject.bbj` (`event!.reject(0)`): `type check error [No match for method
  com.basis.bbj.proxies.event.BBjFormValidationEvent.reject(BBjInt)] at line 30 (3):
  event!.reject(0)`, bbj-ls clean; `probes/s03_formval.bbj` (`event!.accept(1)`): clean on both
  routes. Suggested wording: "There is no `reject()` method. To reject the form call `accept(0)`."
  (The confusion is an agent habit, so this is a one-sentence addition, not a defect.)

## Owner-confirmed behaviour the documentation does not state (D-23)

Three behaviours were confirmed by the project owner on a real BBj, because no page read states them and
no compile check can show them. All three ship in the rewritten skill as verified rules (D-21). All three
are listed here as amendments for the documentation owners. Confirmer, date and version for all three:
confirmed by Stephan Wald, 2026-10-11, BBj 26.03 (the version as stated in the owner context). This
repository never ran any of them.

### L031, the numeric-mask sign trap

A numeric `STR()` mask with no sign character loses the minus sign of a negative value. Pages to
amend: `commands/str_function.htm` and `usr/Language_Concepts/numeric_output.htm`. Says today: only
the list of sign characters. Suggested wording and example: see S1 and S2 in the STR() chapter above.

### L072, bbj -tIO sends print output to stdout

Confirmed by Stephan Wald, 2026-10-11, BBj 26.03: `bbj -tIO <program>` sends the output of `print`
to stdout, the IO device (ledger id L072; granted in decision D-22).

Page to amend:
https://documentation.basis.cloud/BASISHelp/WebHelp/usr/BBj_Components/BBjServices/Thin_Client/running_from_the_command_line.htm

Says today: only "t<terminal alias> The alias of a terminal specified in the configuration file."
The page does not describe the `IO` alias.

The pages that do describe the IO device speak of PRO/5 and are supporting citations only, not the
evidence for the `bbj` claim (the evidence is the owner's observation):

- https://documentation.basis.cloud/BASISHelp/WebHelp/sysadmin/config/unix/terminals_under_unix.htm:
  "Opening and reading the "IO" device is a direct attachment to your stdin and stdout handles."
- https://documentation.basis.cloud/BASISHelp/WebHelp/usr/Character_Devices/General/peripheral_device_file_names.htm:
  "if PRO/5 is running in background or with redirected standard I/O, the file name associated with
  channel 0 will be IO"

Suggested wording (one sentence, gap G7), in the `t<terminal alias>` row:

> The alias `IO` attaches the session to standard input and output; with `-tIO` the output of
> `PRINT` goes to stdout.

### L151, a window without the Dialog flag that already existed cannot be brought in front of a Dialog-flag window

Confirmed by Stephan Wald, 2026-10-11, BBj 26.03: while a window created with the Dialog flag
(`$00080000$`) is open, a window without the Dialog flag that already existed cannot be brought in front
of it (ledger id L151; granted in decision D-24).

Pages to amend:
https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_addwindow.htm (the Dialog entry) and
https://documentation.basis.cloud/BASISHelp/WebHelp/mnemonic/sysgui/window_mnemonic_create_sysgui_window_bbj.htm (the notes for top level windows).

Says today: the `addWindow` page "$00080000$ Dialog : Sets the window to behave as a dialog."; the WINDOW
mnemonic page "Windows created with the dialog behavior flag ($00080000$), that creates a modal dialog, will
not have an icon in the Start Bar in Windows."

Suggested wording, after the WINDOW mnemonic sentence:

> While a window created with this flag is open, a window without this flag that already existed cannot be
> brought in front of it.

## Rules dropped for lack of a source (candidates to confirm)

The old skill stated these rules. None has a documentation page and none can be shown by a compile,
so none is in the rewritten skill. If a rule is true, the owners can confirm it and document it; the
plugin can then take it back with a URL. The `-tIO` fact is not in this list: it is owner-confirmed
(previous section). All of them are listed as candidates, none as established fact.

### Context reuse per window (gap G9, assumption A5)

- L114: "every `addWindow()` and `addChildWindow()` call consumes its context; call
  `getAvailableContext()` fresh each time, or the second call throws ERROR 17 'Context already in
  use'". The page
  https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/SysGui/bbjsysgui/bbjsysgui_getavailablecontext.htm
  says only "Returns the next available context ID." Related rows: L115 (a second top-level window
  needs the `addWindow(int context, string title, string flags)` overload; the overload exists on
  the `addWindow` page, the consequence for the other overloads is not stated) and L140 (the same
  remark in a class example). Ask: is the rule true, and if so, state on the `getAvailableContext`
  and `addWindow` pages that each window needs its own context and what happens otherwise.

### TOP n and the LIMIT page (gap G8, assumption A6)

- L095: "limit the rows with `TOP n` right after `SELECT`". No page documents `TOP` in the SQL
  grammar, the SELECT verb or the search; it may well work in the BBj JDBC driver. Ask: is `TOP`
  supported, and where is it documented.
- L096: "`LIMIT` causes `ERROR 252`". Contradicted by
  https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/SQL_LIMIT.htm, which documents
  `LIMIT (int first, int count)` with "The first parameter is based in 1."; the rewritten skill
  states LIMIT as documented. Suggested addition to the LIMIT page: one JDBC example (the page has
  none).

### The lower-case SQL function (gap G8)

- L092 (with L091): "ANSI `LOWER()` and `UPPER()` are not recognized by the BBj JDBC driver and
  throw a runtime error". https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm
  lists `LCASE(string_exp)` ("Converts all upper case characters in string_exp to lower case.") and
  `UCASE(string_exp)` and never says that `LOWER` and `UPPER` are not supported. Ask: state it, or
  document the ANSI names.

### The round-trip cost of reading a control in a callback

- L079, with L080, L081, L082, L083, L087 and L122: "every read of a control value is a synchronous
  server-to-client round trip, so read the value from the event, and use `insertItems()` rather than
  `addItem()` per item". No page states a cost model for control reads, and a compile cannot show
  one. Ask: is the cost real (DWC and BUI in particular), and if so, document it on the event and
  control pages.

### Launcher behaviours with no page (gap G7)

- L067: `bbj` starts in `<BBjHome>/bin`, not in the shell's directory, so `bbj MyApp.bbj` fails with
  `!ERROR=12`. L069: `-WD` needs a trailing slash and sets program resolution. L071: a missing
  `-WD` stops a `use ::file::` line with `!ERROR=252`. The command-line page says only "WD<working
  directory> Specifies the server directory in which BBj will start" and the `_error_12` page lists
  generic causes.
- L073: the default terminal `T0` is a SysWindow whose output is invisible to a pipe, and the stock
  alias table (`-tT0`, `-tIO`, `-tT3`). No page states the default device or the stock aliases.
- L077: redirect stdin from `/dev/null` when driving `bbj` non-interactively. L078: SysWindow
  mnemonics such as `print(0)'SHOW'` print literally under `-tIO`. The IO-device page says the
  device "will not translate mnemonics sent to it" for PRO/5 and does not cover `bbj`; the owner's
  grant covers only the stdout fact. L054 and L045: how to find `<BBjHome>` and the value of
  `System.getProperty("basis.BBjHome")` (no page).
- What `end` does under a redirected terminal is not documented for `bbj`. The END and RELEASE pages
  do say that END in console mode places PRO/5 in console mode ("Place PRO/5 in console mode") and
  that RELEASE "exits the user from PRO/5" (ledger row L076, kept in the skill as the documented
  difference).

### Smaller candidates

| Id | Dropped rule | Why it was dropped |
| --- | --- | --- |
| L004 | a quoted hex literal `"$00A1$"` is a text string, so a quoted flags argument passes the wrong value | both forms compile (`probes/t19_hex_quoted.bbj`, `probes/t20_hex_ok.bbj`); the Strings page names the forms and states no consequence |
| L056 | without `-N`, bbjcpl writes a large binary into the working directory | the page documents `-N` and the output files, not their size; the one observation (193 bytes) was in a scratch directory and is not a committed probe |
| L065, L137 | the runtime error text for an event constant a control does not support (`!ERROR=17`, "Callback ... is not valid for ...Facade") | the programs compile clean on both routes (`probes/ev01_list_select.bbj`, `probes/s07_imgctrl_mousedown.bbj`); no page states the text |
| L009 | the runtime wording "Cannot assign <undeclared> ... to BBjString myField!" | the `_error_26` page does not contain it; only the compile wording is observable |
| L135 | the CSS property `--dwc-color-primary-h` re-tunes the message box theme hue | no page was cited; CSS tokens belong to the web skill |

## Notes for the primer and the docs server

Three hand-offs for the owners of the primer (`bbj://primer`, docs build 2026-09-29, hash 3d63c5e4)
and of the documentation server. None is a request to edit a BASIS documentation page.

1. Primer paragraphs derived from the old skills (gaps F4, G10). The paragraphs `gotchas/9`,
   `gotchas/10`, `gotchas/11`, `gotchas/12`, `gotchas/14`, `gotchas/15`, `java_object_model/11` and
   `java_object_model/12` end with "Source: from the BBj programming skills curated by BASIS". Phase
   4 rewrote those skills, so the paragraphs now lack an independent source, except where a probe
   gives one:
   - `gotchas/9` (undeclared values and `!ERROR=26`): supported by the probes of the !ERROR=26 section
     above (L010, L011, L012, L014, L018).
   - `gotchas/11` (a double quote inside a string): supported by `probes/t09_quote_ok.bbj` and
     `probes/t10_quote_bad.bbj` (L005).
   - `gotchas/12` (reserved words): supported by the generated `rw` lines of `probes/OUTPUT.txt`
     (56 words fail as a bare numeric name, `fnend` and `fnerr` in every form; L022, L105) and
     `probes/t11_fi_name.bbj` (`fi = 3`, L024).
   - `gotchas/15` (`.trim()` on the result of `STR()`): supported by `probes/t12_str_trim.bbj` (L039).
   - `gotchas/10` (a quoted hex literal, L004): no independent source; both forms compile.
   - `gotchas/14` (`continue` and `break`, L027): partial; `probes/a05_continue_break.bbj` shows the
     `while` form compiles, the `for` form was not probed.
   - `java_object_model/11` (entry class ends with `process_events`, L040) and
     `java_object_model/12` (custom events, L043): only that the code compiles
     (`probes/b09_minimal_entry.bbj`, `probes/a03_declared_arg_api.bbj`); no page.
   Suggested action: give each paragraph a page URL or a compile reference, or remove it.
2. The stale example in `two_string_worlds/10` (S5 above, L038): the BBj `STR()` page shows `01 23`.
3. The docs server serves the old skill text as documentation (gaps F3, G11). A search returned
   "SysGui Information ... Source: from the BBj programming skills curated by BASIS
   (not a citable page; do not cite it as a URL)" as a result, a fetch of
   https://documentation.basis.cloud/BASISHelp/WebHelp/gridctrl/bbjvector_bbj.htm returned the old
   skill's HashMap and TreeMap text although a direct request of that URL answers 404, and
   https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm ends,
   when fetched through the server, with a section "BBj JDBC SQL string functions" copied from the
   old `database.md` that the page file itself does not contain. Results labelled "not a citable
   page" and text appended to official pages look like documentation, so a reader cannot tell the
   official body from the appended text. Suggested action: remove the old skill text from search
   results and from the pages, or label it unmistakably, and stop the primer paragraphs above from
   citing it. Until then the plugin cites only the body of the page file and never a labelled
   result.

Entries per section: STR() chapter 5 (S1 to S5); rules kept on compile evidence 21 (the 18 ledger ids
L010 L011 L012 L014 L015 L016 L018 L060 L064 L086 L118 L143 L144 L145 L146 L148 L149 L150, plus the
related L006, L101 and L147, in 7 page groups); owner-confirmed behaviour 3 (L031, L072, L151); dropped
rules 5 groups and 5 smaller rows; notes for the primer and the docs server 3.
