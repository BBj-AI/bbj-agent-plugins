---
name: "bbj-programming"
description: "Write, debug, review, run, or compile BBj code — the general language skill for any BBj program (CUI, desktop GUI, or web/DWC/BUI). Use for .bbj files, BBj class/method syntax, BBjVector/Java collection interop, or JDBC database access. Also use whenever running, compiling, or type-checking a BBj program from a shell or script (bbj, bbjcpl) — seed, migration, batch, or test-fixture scripts, and anything whose printed output you need to capture in a pipe. Trigger on symptoms without BBj being named: a bbj command that hangs, exits silently, or prints nothing into a pipe; !ERROR=12 (Missing file); !ERROR=252 (Cannot find program X for type: Y); a syntax check that drops a large extensionless binary next to the source; a program that returns to a READY> prompt instead of exiting. For browser-specific work (DWC/BUI, HTML, CSS, web components), also use the bbj-web-programming skill."
---

# BBj Programming (general language)

Core BBj language conventions and traps, independent of client type — they apply whether the program runs as CUI, desktop GUI, or in a browser (DWC/BUI). Many of these traps fail silently (wrong output, no error), so read this before writing or debugging any BBj code.

For anything browser-specific — DWC window/DOM structure, CSS/JS injection, `BBjWebComponent`, Shoelace, HTML text in controls — use the **bbj-web-programming** skill alongside this one.

---

## Language gotchas (memorize these — they're silent failure modes)

**No ternary operator.** BBj has no `cond ? a : b`. Use `iff()`:
```bbj
result! = iff(age > 18, "adult", "minor")   ;REM correct
result! = age > 18 ? "adult" : "minor"      ;REM syntax error
```

**A trailing `rem` on a line of code needs a `;` separator.** Appending a comment to a statement without one is a syntax error — "Comments need to be separated by line breaks or ';'":
```bbj
interval = 0 ; rem Manual      ;REM correct
interval = 0 rem Manual        ;REM syntax error
```

**Hex/byte-string literals are written `$00A1$` and must NOT be quoted.** `$00108800$` is a byte-string literal; `"$00108800$"` is a 10-character text string containing dollar signs. They are different types, so quoting a flags argument silently passes the wrong thing (and control/window creation flags are the most common place this bites):
```bbj
panel! = win!.addChildWindow("", $00108800$, ctx)     ;REM correct — byte-string literal
panel! = win!.addChildWindow("", "$00108800$", ctx)   ;REM wrong — passes a text string
```

**Double quotes inside strings are escaped by doubling, not backslash:**
```bbj
msg! = "He said ""hello"" to me"   ;REM correct
msg! = "He said \"hello\" to me"   ;REM syntax error — backslash does nothing
```

**`declare` rules for Java types: the declared type must be compatible with the runtime type, and `auto` only works with classes, not interfaces.** The declare is a promise about what will be assigned — an incompatible type throws a runtime error:
```bbj
declare auto BBjVector watches!
watches! = someMethod()   ;REM runtime error if someMethod() returns ArrayList — incompatible with BBjVector
```
`declare auto` works when the declared type is the runtime object's class or one of its superclasses:
```bbj
declare auto java.util.ArrayList watches!
watches! = someMethod()          ;REM works if someMethod() actually returns an ArrayList

declare auto java.util.AbstractList fruits!
fruits! = java.util.Arrays.asList("apple", "banana", "cherry")   ;REM works — runtime type extends AbstractList
```
For an interface type (e.g. `java.util.List`), `declare auto` does not work — use plain `declare` (no `auto`) instead:
```bbj
declare java.util.List fruits!   ;REM plain declare, no auto — works for interfaces
fruits! = java.util.Arrays.asList("apple", "banana", "cherry")
? fruits!.get(1)
```
If you don't know the return type, don't declare the variable at all — `.size()`/`.get()` etc. still work on the undeclared variable via the shared collection interface, and you can `cast()` at the point of use:
```bbj
watches! = someMethod()   ;REM always safe — works for BBjVector or any Java collection
```

**Handing an *undeclared* value to a strictly-typed destination — a class `field` assignment, or `methodret` from a method with a declared return type — can throw `!ERROR=26`, even when the same value works fine everywhere else.** This is a sharper version of the `declare` rule above: undeclared variables get fully dynamic method/comparison resolution (`if (x! = "dark") then ...` works regardless of `x!`'s actual type; so does calling further methods on it), but `#myField! = x!` and `methodret x!` (when the method's own signature declares a return type) both have stricter runtime type-checking and can reject an undeclared value outright — `Cannot assign <undeclared> ... to BBjString myField!` (or `HashMap`, `BBjListButton`, etc.) — even though `x!` holds a perfectly ordinary, correctly-typed-looking value. What produced that value is irrelevant — `new HashMap()`, `BBjAPI().makeVector()`, and a well-defined SysGui builder method all count as "undeclared" too, once the result sits in an undeclared variable, right up until something declares it. Four ways this shows up in practice:
```bbj
REM 1. A proxy getter's return value, assigned straight to a field:
dwcTheme! = #webManager!.getTheme(err=*NEXT)
#theme! = dwcTheme!              REM !ERROR=26 — even though dwcTheme! = "dark" prints fine
#theme! = str(dwcTheme!)         REM fixed — str() forces a real BBjString

REM 2. A plain undeclared local, reassigned from a literal along the way, then assigned to a field:
targetIndex! = someBBjNumberParam!
targetIndex! = 0                 REM reassigning to a bare literal
#currentIndex = targetIndex!     REM !ERROR=26 — "Cannot assign <undeclared> 0 to BBjNumber currentIndex"

REM 3. An undeclared local, methodret'd from a method with a declared return type — fails at
REM    the CALLER's use of the result (e.g. its own field assignment), not inside this method:
method private HashMap buildConfig()
    config! = new HashMap()      REM undeclared local, even though new HashMap() is well-typed
    config!.put("k", "v")
    methodret config!            REM !ERROR=26 downstream, at "#myField! = #buildConfig()"
methodend

REM 4. A method call's result, when the RECEIVER is itself undeclared — tainted regardless of
REM    that method's own declared return type:
fieldGroup! = parentWin!.addChildWindow("", flags, ctx!)   REM fieldGroup! undeclared
#myListButton! = fieldGroup!.addListButton(items!)         REM !ERROR=26 — even though
                                                            REM addListButton() always returns BBjListButton
```
Fix any of these by declaring the local that ultimately gets assigned/returned — best when it's reassigned more than once, or produced through a chain of calls, since every step then coerces correctly, not just the last one:
```bbj
declare auto BBjNumber targetIndex!
targetIndex! = someBBjNumberParam!
REM ...
targetIndex! = 0
#currentIndex = targetIndex!     REM fine — targetIndex! is a real BBjNumber throughout

method private HashMap buildConfig()
    declare auto HashMap config!
    config! = new HashMap()
    config!.put("k", "v")
    methodret config!             REM fine now

declare auto BBjChildWindow fieldGroup!
fieldGroup! = parentWin!.addChildWindow("", flags, ctx!)
#myListButton! = fieldGroup!.addListButton(items!)   REM fine — fieldGroup! is declared, so is the call result
```
For simple primitives, wrapping the value in the coercion function matching the destination's type right at the point of assignment/return also works — `str()` for `BBjString`, `num()` for `BBjNumber`:
```bbj
#theme! = str(dwcTheme!)
#currentIndex = num(targetIndex!)
```
When you *need* a variable to stay undeclared on purpose — e.g. a caller-supplied object whose class you don't know, kept undeclared specifically so its methods resolve dynamically without requiring a shared interface — route its result through a second, declared local rather than declaring the object itself:
```bbj
provider! = #providerHolder!.get(0, err=*NEXT)          REM stays undeclared — needed for dynamic dispatch
declare auto HashMap result!
result! = provider!.getRecord(index!, err=*NEXT)        REM the CALL is dynamic; the RESULT is now typed
methodret result!                                        REM fine
```
Passing an undeclared value as a plain method *argument* is unaffected either way — parameter binding coerces it fine, which is why code like `#applyThemePreset(dwcTheme!)` never trips this even though `#theme! = dwcTheme!` does. Only the strict destinations (declared field, declared method return) are at risk — and because a "type check error" from `bbjcpl -t` for exactly this ("Incompatible assignment from <undeclared> to X" / "Method expected return type X, got <undeclared>") can be either a real, reproducible runtime crash or genuinely harmless depending on what the *caller* does with the value, don't dismiss it as advisory noise — when in doubt, fix it; the cost of an unnecessary `declare auto` is zero.

**`for` loops execute at least once even when the upper bound is below the lower bound** — `for i = 0 to -1` still runs with `i=0`. This is a silent trap when iterating a vector that might be empty:
```bbj
if (myVector!.size() > 0) then
    for i = 0 to myVector!.size() - 1
        doSomething(myVector!.get(i))
    next
endif
```
Always guard `for i = 0 to v!.size() - 1` with a size check.

**BBj keywords, verbs and functions are reserved words -- never use one as a variable name.** The full list, with test results, is in [references/reserved-words.md](references/reserved-words.md). They fail in two tiers:
- **56 words can never be a bare numeric name**, among them `fi`, `day`, `err`, `list`, `if`, `for`, `on`, `new`, `table` and `case`. The line is a syntax error: `bbjcpl` reports a plain `error at line`, not a type-check error, and at runtime it is `!ERROR=20 (Syntax error)` with no hint that the name is the problem.
- **`fnend` and `fnerr` fail in every form**, even with a `$` or `!` suffix.

Most other words -- even `print`, `str` or `release` -- happen to compile and run as names, because BBj decides by position whether a word is a verb. Avoid them anyway; see the reference for what was and was not tested. The classic trap is `fi`, a natural "file index" counter, but `FI` is a synonym for `ENDIF`:
```bbj
if x = 1 then
    print "inside"
fi                          REM valid -- FI closes the IF block, same as ENDIF
fi = 3                      REM !ERROR=20 (Syntax error) -- FI is not an identifier
for fi = 0 to cnt - 1       REM !ERROR=20 as well
```
When a syntax error points at a line that looks perfectly ordinary, suspect a reserved word used as a name. Pick another short name (`q`, `k`, `wi`).

**`continue` and `break` are supported in both `for`/`next` and `while`/`wend` loops** — skip to the next iteration or exit the loop directly, no need to restructure with inverted conditionals:
```bbj
it! = map!.keySet().iterator()
while (it!.hasNext())
    firstName! = it!.next()
    if (!firstName!.contains("e")) then continue   ;REM skip to next iteration
    ? "First Name Contains an 'e': ", firstName!
    if (firstName! = "James") then break            ;REM exit the loop entirely
wend
```

**Converting a string to a number is `num()`, not `int()`.** `int()` truncates a *decimal number* down to an integer (`int(3.7)` → `3`) — it does not parse a string. Handing it a numeric-looking string is a common trap, most often when pulling a value back out of a `DataRow`/JDBC result via `str(rs!.getFieldValue(...))` and then trying to do arithmetic or comparisons on it:
```bbj
countStr! = str(rs!.get(0).getFieldValue("TOTALCOUNT"))
total! = int(countStr!)      REM wrong — int() doesn't convert a string to a number
total! = num(countStr!)      REM correct — num() parses a string into a BBjNumber
```
If you need to both parse a numeric string *and* drop its decimal portion, compose the two: `int(num(countStr!))`.

**`str()` masking covers two independent systems selected by the argument's runtime type — numeric masking (mask applied to a number) and string masking (mask applied to a string/object).** BBj picks which one based on the argument's runtime type, not the mask. Know which one you're writing before reading a mask character's meaning below, since a couple of characters (e.g. `0`) mean roughly the same thing in both but most don't overlap at all.

**Numeric masking** (`str(num:mask)`) — every character below is a *sign/formatting* character, and this is where the minus-sign trap lives:

| Char | Result |
|---|---|
| `0` | Digit, always shown (leading/trailing zero included) |
| `#` | Digit, but suppresses leading zeros — replaced by the fill character to the left of the decimal when no significant digit has been placed yet; right of the decimal, trailing `#`s become space or `0` per `SETOPTS` |
| `,` | Comma, but only once a digit has been placed to its left; otherwise it's the fill character |
| `.` | Decimal point, if any digit appears in the mask; otherwise the fill character |
| `-` | `"-"` if negative, fill character if positive — **never shows `+`, and with no other sign char in the mask this is the only thing that preserves negativity** |
| `+` | `"+"` if positive, `"-"` if negative |
| `(` | `"("` if negative, fill character if positive |
| `)` | `")"` if negative, fill character if positive |
| `CR` | literal `"CR"` if negative, two spaces if positive |
| `DR` | literal `"CR"` if negative, literal `"DR"` if positive |
| `$` | always a literal `$` |
| `@` *(BBj)* | 3-letter ISO currency code (e.g. `"USD"`) from `STBL("!LOCALE")` |
| `&` *(BBj)* | local currency symbol from `STBL("!LOCALE")` |
| `*` | literal `"*"` inserted into the number |
| `B` | always a literal space |
| *(none of the above)* | literal — copied through as-is |

A mask with **only `#` and `0`** has no sign character at all, so negative numbers render as if positive. Always include an explicit sign prefix:

| Prefix | Positive | Negative | Use for |
|---|---|---|---|
| `+` | `"+2.82"` | `"-1.50"` | UI display (always show sign) |
| `-` | `"2.82"` | `"-1.50"` | Machine-readable output (sign only when negative) |
| *(none)* | `"2.82"` ❌ | `"2.82"` ❌ | Never — loses the sign |

```bbj
str(rate:"+##0.0#")                            REM UI: "+2.82" or "-1.50"
valStr! = cvs(str(offsetSec:"-######0.00"), 3) REM JSON-safe + trimmed: "1.16" or "-7.00"
str(rate:"######0.00")                         REM WRONG — -7.0 silently becomes "7.00"
```

Two more numeric-masking behaviors worth knowing:
- **Floating characters:** `-`, `+`, `$`, and `(` "float" — the first one present in the mask jumps to sit immediately left of the number, at the last position where a `#` or `,` was replaced by the fill character (e.g. `"$#,##0.00"` against `5` prints `"$5.00"`, not `"$    5.00"`). If no such position exists, it's left where written.
- **Rounding differs by context:** a mask applied via `str()` **rounds** the value to the mask's precision (`str(12.34567:"###0.00")` → `"12.35"`), but the same mask applied to a bound control (e.g. an `INPUTN` mask) does **not** round — it truncates/displays `"12.34"`. Don't assume a control's displayed value and `str()`'s formatted value agree at the last digit.
- Fill character defaults to space; if the mask's *first* character is `*`, `*` becomes the fill character for the whole mask instead.

**String masking** (`str(str:mask)` or any non-numeric `objexpr`) — a completely different character set, positional character-class placeholders, no sign concept at all:

| Char | Accepts |
|---|---|
| `X` | Any printable character |
| `a` | Any alphabetic character |
| `A` | Any alphabetic character; lower-cased input is upper-cased |
| `0` | Any digit |
| `z` | Any digit or alphabetic character |
| `Z` | Any digit or alphabetic character; lower-cased input is upper-cased |
| `U` *(BBj only)* | Any digit, alphabetic, space, or punctuation character; lower-cased input is upper-cased |
| *(anything else)* | Literal — copied through as-is |

Output length always equals the mask length: a too-short source string is space-padded; a too-long source string, or a character that doesn't match its position's class (e.g. a letter landing on a `0`), raises `!ERROR=43`.

```bbj
str(123:"0000")                REM numeric masking → "0123"
str(3352.3:"$##,##0.00")       REM numeric masking → "$3,352.30"
str("abcdefg":"XX-XXX-XX")     REM string masking  → "ab-cde-fg"
str(new java.lang.Integer(123):"00-00") REM non-native object → string masking → "12-3"
```

**`str()` returns a primitive string, not a BBjString object** — chaining a method directly on its result is a syntax error (ERROR=20):
```bbj
? str(offsetSec:"-######0.00").trim()               REM !ERROR=20 (Syntax Error)
```
Three correct alternatives:
```bbj
REM 1. To trim str() output, use cvs() (3 = strip leading and trailing whitespace):
valStr! = cvs(str(offsetSec:"-######0.00"), 3)

REM 2. To call BBjString methods, cast the result to BBjString first:
offsetSecStr! = cast(BBjString, str(offsetSec:"-######0.00"))
? offsetSecStr!.trim()

REM 3. Or assign to an undeclared object variable, then call methods on the variable.
REM    This works because BBj sees str() returns a string and makes the undeclared
REM    object variable a BBjString object — which does have trim()/toLowerCase()/etc.
term! = str(someObj!)
term! = term!.toLowerCase()
```

---

## Class / method boilerplate
```bbj
class public MyApp
    field private BBjTopLevelWindow winMain!

    method public MyApp()
        REM constructor — acquire APIs, build UI
    methodend

    method public void run()
        #winMain!.setVisible(1)
        process_events   REM last call in the entry point — everything after is callback-driven
    methodend
classend

app! = new MyApp()
app!.run()
```
Null-safe call pattern: `if (obj! = null()) then methodret` and `val! = someCall(err=*NEXT)`.

Event callbacks:
```bbj
btn!.setCallback(BBjButton.ON_BUTTON_PUSH, #this!, "onBrowseClick")
method public void onBrowseClick(BBjButtonPushEvent event!)
    #showBrowseWindow()
methodend
```
Cross-component custom events:
```bbj
BBjAPI().setCustomEventCallback("cart-updated", "onCartUpdated")
BBjAPI().postCustomEvent("cart-updated", watchId!)
```

Useful paths:
```bbj
cwd! = dsk("") + dir("")                        REM working directory — always ends with a trailing "/"
bbjHome! = System.getProperty("basis.BBjHome")  REM BBj install directory — NO trailing "/"
```
Watch the trailing-slash difference when concatenating filenames onto these.

---

## Numeric precision — the default is 2 decimal places

**Every store into a numeric variable is rounded to the current precision, and the default is
`PRECISION 2`.** Arithmetic *inside* one expression keeps full precision; the rounding happens the
moment the result is assigned. So this prints two different things:

```bbj
print 1084.45 / 17          REM 63.79117647 -- never stored, full precision
a = 1084.45 / 17
print a                     REM 63.79       -- rounded on the way into a
```

That is harmless for money and destructive for anything that accumulates. The classic victim is a
variance computed the textbook one-pass way:

```bbj
v = sumSq / cnt - mean * mean    REM two ~equal numbers, each rounded to 2dp, then subtracted
```
Both terms round to 2dp, they agree to three significant figures, and the subtraction throws away
what is left. Measured on real data: this returned a standard deviation of **0.33 where the true
value is 0.41** — 19% low, with no error and no warning. Regression accumulators (`Sxx`, `Syy`,
`Sxy`), sums of squares, and any value derived from a division are all exposed. Watch for
quantisation too: `days = ms / 86400000.0` stored at 2dp is a 0.01-day (14-minute) grid.

**Fixes, in order of preference:**

1. **Raise the precision once, early:** `PRECISION 16` (range 0–16; `-1` selects floating point).
   Prefer 16 over `-1` when the program also handles money or counted units — exact decimal is
   easier to reason about than binary floating point.
2. **Compute variance in two passes** (mean first, then sum the squared deviations). Numerically
   stable at any precision, and correct regardless of what the caller set.
3. **Use the sample divisor** `(n-1)`, not `n`, whenever the figure is an estimate of an underlying
   spread rather than a description of the rows in hand.

**`BEGIN`, `CLEAR`, `END`, `LOAD`, `RUN`, `START` and `STOP` all reset precision to the default.**
A `PRECISION` set at startup does not survive any of them, so grep for those verbs before trusting
it — and give every standalone program (migrations, seeds, batch jobs) its own `PRECISION` line
rather than assuming it inherits one.

**Symptom to recognise:** a computed statistic that is plausible but consistently wrong in one
direction, a correlation or R² that comes back as exactly `1.0`, or a difference of two large
similar numbers landing on a suspiciously round value like `0.11`. None of these raise an error.

---

## Verify with the compiler before handing back code

BBj ships a standalone compiler, **`<BBjHome>/bin/bbjcpl`** (`bbjcplw` on Windows). Run it on every
file you write or edit — it catches syntax errors and a useful class of type errors without needing
BBj Services, a SysGui, or a browser, so run it before handing back any file.

Find `<BBjHome>` rather than hardcoding it — it is the directory holding `bin/`, `cfg/`, `htdocs/`,
`jars/`. From inside a running program it is `System.getProperty("basis.BBjHome")`; from a shell,
resolve it from the `bbj` launcher if it is on the PATH, or locate the install directory once and
reuse it:
```bash
BBJHOME="$(cd "$(dirname "$(command -v bbj)")/.." && pwd)"   # when bbj is on the PATH
"$BBJHOME/bin/bbjcpl" -t -N -X -W myprogram.bbj
```

**Always pass `-N -X` for a check-only run.** `bbjcpl` is a *compiler* first: by default it writes a
tokenized output file next to the source, and for an input file *with* an extension the output file
is the same name **with the extension stripped** — so a bare `bbjcpl -t MyApp.bbj` silently drops a
large binary `MyApp` into the working directory. `-N` suppresses all output files; `-X` keeps the
input extension, so even if `-N` is ever dropped the source is not the overwrite target.

| Option | Effect |
|---|---|
| `-t` | Static type checking (the part you actually want) |
| `-N` | Write no output files — **always use for a check** |
| `-X` | Keep the input file's extension (guards against clobbering the source) |
| `-W` | Also warn about lines skipped because they contain undeclared variables; only valid with `-t` |
| `-c<configFile>` | Resolve `use ::file.bbj::Class` prefixes and `USE` directives from a config.bbx; only with `-t`, mutually exclusive with `-P` |
| `-P<dir1:dir2>` | Resolve custom-class `use ::file::` paths from a directory list; only with `-t`, mutually exclusive with `-c` |
| `-CP<name>` | Type-check against a named session-specific classpath (for Java classes in extra jars) |
| `-e<errorlog>` | Write the error output to a file |
| `-R`, `-d<dir>` | Recurse a directory / choose an output directory (compiling, not checking) |

Two things about reading its output:

- **The exit code is 0 even when there are errors.** Never branch on `$?` — parse stdout instead, and
  treat *any* line containing `error` as a failure.
- **The first line number is multiplied by ten; the parenthesized one is the real source line.**
  `error at line 12600 (1260)` means source line **1260**. Jump to the number in parentheses.

`-W` warnings are informational, not failures. A deliberately undeclared variable — the standard way
to null-check a Java value that may be null before passing it through `str()` — warns every time:
```bbj
raw! = null()
raw! = someJavaObject!.getString(KEY, err=*next)   REM warns: Undeclared variable: raw!
if (raw! <> null()) then value$ = str(raw!)
```
Type check **errors** are a different matter: see the `!ERROR=26` discussion above before dismissing
"Incompatible assignment from &lt;undeclared&gt;" as noise.

**`bbjcpl` will not catch a bad event constant.** `setCallback(BBjListBox.ON_LIST_SELECT, ...)`
compiles and type-checks cleanly, then throws `!ERROR=17 (Callback ON_LIST_SELECT is not valid for
BBjListBoxFacade)` at runtime — every control exposes its own event set and the constants are not
interchangeable (e.g. `BBjListBox` has `ON_LIST_CLICK` but no `ON_LIST_SELECT`, while `BBjListButton`
has both). Check the control's own Events table in the docs before using a callback constant you have
not used on that exact control type before.

---

## Running a program from a shell

**`bbj` always starts in `<BBjHome>/bin`, not your shell's cwd.** `cd`-ing to the project directory
first changes nothing — the program file is resolved relative to `/opt/basis/bin/`, so a plain
`bbj MyApp.bbj` fails with `!ERROR=12 (Missing file MyApp.bbj)` even though the file is right there.
Confirm it from inside a session: `? dir("")` prints `/opt/basis/bin/`.

**Always pass `-WD<dir>` with a trailing slash.** It sets the working directory for both program
resolution and every `dsk("")+dir("")` path the program builds at runtime — a program that loads
CSS, icons, or a database from a relative path needs it for far more than just being found:
```bash
bbj -q -tIO -WD"$PWD/" migrateSortPrefs.bbj < /dev/null
```

**`use ::file.bbj::Class` resolves against the working directory too — and fails with a different
error.** A missing `-WD` stops the `use` line rather than the program file, throwing
`!ERROR=252 (Cannot find program DailyDrift.bbj for type: DriftDB)`. Same root cause as the
`!ERROR=12` above, but the wording names the *class* being imported rather than the working
directory, so the fix is `-WD`, not a change to the `use ::` path.

**Pass `-tIO`, or `print` output never reaches your pipe.** `-t<alias>` picks the terminal device,
and the aliases are defined in `<BBjHome>/cfg/config.bbx` (swap the file with `-c<config>`). The
default `T0` is a **SysWindow — a Swing window** — so a shell waiting on piped stdout appears to hang
while the output goes to that window instead of stdout. `IO` is the built-in standard-I/O device: plain
stdin/stdout, no colors or graphics characters, which is what you want for a pipe.

| Alias | Device | Use |
|---|---|---|
| `-tT0` | `SYSWINDOW` (the **default**) | Interactive Swing console; output invisible to a pipe |
| `-tIO` | Standard I/O | **Use this from a shell** — `print` lands on stdout |
| `-tT3` | `/dev/tty term` in the stock config.bbx | A real Unix terminal with basic capabilities |

The alias numbers are site-configurable — check the actual table before relying on one:
```bash
grep -i '^ALIAS' "$BBJHOME/cfg/config.bbx"
```

| Option | Effect |
|---|---|
| `-q` | Quiet — suppress the startup banner |
| `-WD<dir>` | Working directory; **required** from a shell. Trailing slash. |
| `-t<alias>` | Terminal device from config.bbx; **use `-tIO`** to capture `print` output |
| `-c<config>` | Use a different config.bbx (changes what the `-t` aliases mean) |

Two more things about driving `bbj` non-interactively:

- **`end` returns to the interactive `READY>` prompt — it does not exit.** A script run from a shell
  then hangs waiting on console input that never comes. End batch/migration programs with
  **`release`**, which terminates the session. Redirect stdin from `/dev/null` too.
- **SysWindow mnemonics print literally under `-tIO`.** `print(0)'SHOW'` — common boilerplate at the
  top of a batch program to raise the console window — emits a bare `SHOW` line into your captured
  output. Drop it from anything meant to be shell-run.

---

## Deeper references (load on demand)

The material below is off-loaded to keep this file focused on always-relevant silent traps. Read the referenced file when the task hits its topic:

- **[references/sysgui.md](references/sysgui.md)** — SysGui gotchas (GUI + web): `BBjChildWindow` declares, ERROR 17 "Context already in use", known-value fields via `BBjListButton`/`BBjListEdit` + a backing `BBjVector` (`insertItems()`, `indexOf()` syncing), message boxes via `MSGBOX()`/`BBjMsgBox` (constants, MODE= options, DWC theming), and the `BBjImageCtrl` click workaround (`getOriginalControl()`). Read this on any GUI/web control code, or if a callback throws "not valid for BBjImageCtrlFacade" or ERROR 17. For icon buttons via `dwc-icon`/`setSlot()`, see **bbj-web-programming**.

- **[references/callback-performance.md](references/callback-performance.md)** — Eliminating client–server round trips: read from the event instead of the control, track values in class fields, use `ON_FORM_VALIDATION` for Save buttons (including the critical `event!.accept(1)` gotcha that freezes the UI). Read this whenever a callback needs to read control values, especially in DWC/BUI.

- **[references/java-interop.md](references/java-interop.md)** — Collection recipes: loading `BBjListButton` / `BBjListEdit` from a `BBjVector` or `HashMap`, `BBjVector` ⇄ strings and Java collections, `LinkedHashMap` / `TreeMap` patterns. Read this whenever you're moving data between BBj and `java.util.*` types.

- **[references/database.md](references/database.md)** — Database access: JDBC API vs. `SQLOPEN`/`SQLPREP`/`SQLEXEC`/`SQLFETCH` verbs, the BBj-specific SQL string functions (`LCASE` not `LOWER`, etc.), and row-limiting with `TOP` not `LIMIT`. Read this on any DB query — several of the BBj JDBC differences are silent failures at ANSI-SQL habits.

- **[references/reserved-words.md](references/reserved-words.md)** -- Every BBj keyword, verb and function, and which ones break as variable names: the 56 that can never be a bare numeric name (`fi`, `day`, `err`, `list`...), and `fnend`/`fnerr`, which fail even with a `$` or `!` suffix. Read this when picking a name, or when a syntax error lands on a line that looks ordinary.
