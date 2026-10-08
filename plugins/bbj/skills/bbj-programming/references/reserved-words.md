# BBj reserved words -- what can and cannot be a variable name

Source list: `bbj.language.properties` (BASIS, the file behind BBj editor syntax
colouring). Every word below is a BBj keyword, verb or function. **Treat all of
them as reserved: never pick one as a variable, field or loop-counter name.**

The list is not all equally dangerous, though. Tested on BBj REV 26.10BETA with
`bbjcpl` and at runtime (assign a value at the start of a line, then read it back
in an `IF`):

| Form | Fails | Result |
|---|---|---|
| numeric, no suffix (`day = 1`) | 56 words, listed below | `!ERROR=20 (Syntax error)` -- `bbjcpl` reports a plain `error at line`, not a type-check error |
| string (`day$ = "x"`) | only `fnend`, `fnerr` | everything else assigned and read back correctly |
| object (`day! = 1`) | only `fnend`, `fnerr` | everything else assigned and read back correctly |

Every other word worked even as a bare numeric name -- `print = 7`, `str = 7` and
`release = 7` all assign and read back -- because BBj decides by position whether a
word is a verb or a variable. That is not a licence to use them: the test covered
only "assign at the start of a line, then compare in an `IF`", other positions
(`FOR` counters, arguments, mid-expression) were not tested, and code full of
variables named `print` or `str` is hard to read.

## Hard failures: never a bare numeric name (56)

A syntax error on a line that looks ordinary usually means one of these is being
used as a name. `fi` is the classic trap (a natural "file index" counter, but `FI`
is a synonym for `ENDIF`).

```
all argc chn ctl day dsz fnend fnerr iol new opts pfx psz rev sqlchn sqlunt ssn sys
tim unt until begin callback case csoff cson dread else endif exitto fi for from
gosub goto if iolist let list load on process_events read_resource remove_callback
restore seterr setesc swend switch table then wend where while err tbl
```

**`fnend` and `fnerr` fail in every form**, with `$` and `!` suffixes too.

Not runtime-tested, because executing them as verbs could change system or license
state (the compiler accepted all three forms): `settime setday setdrive updatelic
reserve lcheckin lcheckout`.

## The full list

### Keywords
```
all argc auto chn class classend ctl day declare dom dsz extends fnend fnerr imp
implements iol interface interfaceend method methodend mode new opts pfx private
protected psz public rev sqlchn sqlunt ssn static step super sys this tim to unt
until void
```
(`super` and `this` are used as `#super!` and `#this!`.)

### Verbs
```
addr background begin break bye call callback case chanopt chdir cisam clear clearp
clipclear clipfromfile clipfromstr cliplock cliptofile clipunlock close continue
csoff cson data def delete dim direct disable dread drop dump edit else enable end
endif endtrace enter erase escape escoff escon except execute exit exitto extract
extractrecord fi field file fileopt find findrecord floatingpoint for from gosub
goto if import indexed initfile input inpute inputn inputrecord iolist jerase
jkeyed jopen lcheckin let limit list load lock merge methodret mkdir mkeyed on open
next precision prefix print ? printrecord process_events program read readrecord
read_resource record release remove remove_callback rename renum repeat resclose
reserve reset restore retry return rmdir run save savep scan select serial
set_case_sensitive_off set_case_sensitive_on setday setdrive seterr setesc
settrace setopts setterm settime sort sortby sqlclose sqlcommit sqlexec sqlopen
sqlprep sqlrollback sqlset start stop string swend switch table tclose tcommit then
throw trollback unlock updatelic use vkeyed wait wend where while write writerecord
xcall xfile xkeyed
```
(`?` is the short form of `PRINT`.)

### Functions
```
abs adjn and argv asc ath atn bin bsz cast cahopt chr clientenv clipisformat
clipregformat cliptostr cmd cos cpl crc crc16 ctrl cvs cvt date dec decrypt dims dir
dsk encrypt env ept err errmes fattr fbin fdec fid fileopen filesave fill fin fpt gap
get_filesystem get_sysgui hsa hsh hta iff ind info int ior jul key keyf keyl keyn
keyp kgen lcheckout len linfo log lrc lst mask max menuinfo min mod msgbox neval
nfield not notice noticepl null num pad pck pgn pos pub resfirst resget resinfo
resnext resopen rnd round scall sendmsg serverenv seval sgn sin sqlerr sqlfetch
sqllist sqltables sqltmpl sql ssort ssz stbl str swap tbl tcb tmpl topen tsk upk
winfirst wininfo winnext xfid xfin xkgen xor xssort
```

### Java type names (also avoid)
```
boolean byte char double float int long short void
```

### Special labels (only valid after `ERR=` and similar)
```
*PROCEED *NEXT *SAME *RETRY *BREAK *CONTINUE *ESCAPE *RETURN *STOP *END *EXIT *ENDIF
```

## Safe short names

For loop counters and scratch values, short non-keyword names are fine: `i`, `j`,
`k`, `q`, `n`, `wi`, `idx`, `cnt`. If a two-letter name fails, check it against the
56 above before hunting for anything else.
