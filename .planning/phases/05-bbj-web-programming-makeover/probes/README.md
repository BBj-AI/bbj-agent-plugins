# probes/ -- compile evidence for the claim ledger (plan 05-01, D-01)

Every COMPILE row of `05-LEDGER.md` (plans 05-02 and 05-03) and every `bbj should-fail` block of the
rewritten `bbj-web-programming` skill rests on a file in this directory. One probe is one minimal BBj
program (`<id>_<name>.bbj`, lowercase letters, digits and `_`, LF line endings, a trailing newline).
`OUTPUT.txt` records, per probe, the exact `bbjcpl -t -N -X` records and the `bbj-ls` verdict lines,
with the BBj version in its header. The ids are those of the research table (`05-RESEARCH.md`, "Code
Examples" and the cause table): `p` the compile facts and skeletons, `q` the class, panel and
registration programs. `p17` was added during execution (see "Findings" below).

**Nothing here runs BBj.** The only program `run.py` starts is `bbjcpl` with `-t -N -X` (compile
only; the probe files are copied into a temporary directory outside the repository), and the only
network peer is the loopback `bbj-ls` at `http://127.0.0.1:5009/mcp`. The hosted check and the
hosted docs server are never contacted. A probe is data: it is read as text and never becomes part
of a command. Plan 05-04 adds an `owner-repros/` directory next to this one: those programs are
compiled here (by the same two routes) and run only by the project owner, never by Claude.

## Rerun

```text
python3 -I .planning/phases/05-bbj-web-programming-makeover/probes/run.py
python3 -I .planning/phases/05-bbj-web-programming-makeover/probes/run.py --check
```

- No argument: compile every probe and write `OUTPUT.txt` (atomically). Prints
  `gate probes_canary ok ...` and `gate probes_written ok <n> probes`.
- `--check`: compute everything again and compare it line by line with `OUTPUT.txt`. Prints
  `gate probes_reproduce ok <n> probes`, or `gate probes_reproduce FAIL line <k>: expected <a> got <b>`.
- Exit codes: 0 written or reproduced; 1 a canary failed, a compiler line could not be attributed,
  a `bbj-ls` reply gave no verdict, or `--check` found a difference; 2 usage, or `bbjcpl` or `bbj-ls`
  is missing (nothing written). `bbjcpl` is looked up under `BBJ_TEST_HOME` (default `/opt/bbx`),
  `bin/bbjcpl`; `bbj-ls` must answer a GET on its URL with 405.
- The canary pair (`print "a"; rem ok` and `print "a"   rem same line`) makes a dead compiler
  visible: the second must own an error record and the first none.
- Re-run the probes when the BBj version or the docs build changes; `OUTPUT.txt` names the version.

## Findings that differ from the plan-time expectation

- `p08_attributes_declared.bbj` assigns `getProperty` to an object variable (`themeValue!`). The
  first draft assigned it to `themeName$`; `bbjcpl -t` rejects that (`Cannot assign java.lang.Object
  to BBjString`), recorded as `p17_getproperty_to_string.bbj`. `getAttribute` into a string variable is
  clean on a declared `BBjButton` (`p08`).

## Dry-run a skill draft in a scratch root

The example gate (`tests/test_skill_examples.py`) accepts a root directory, so a draft can be checked
without touching the real skill or the baseline (about 3 seconds). Put ROOT in the session
scratchpad, never in the repository:

```text
ROOT=<scratchpad>/skill-root
mkdir -p "$ROOT/plugins/bbj" "$ROOT/tests"
cp -R plugins/bbj/skills "$ROOT/plugins/bbj/skills"
printf '%s\n' '{"bbj_version":"26.03","nocheck":0,"pending":{}}' > "$ROOT/tests/skills_baseline.json"
BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py "$ROOT"
```

With the empty `"pending":{}` baseline every violation is a plain `FAIL` (nothing is skipped as
pending), so the output lists every problem of the draft. Read the `bbj-web-programming` lines: each
`bbj` block must pass both routes, each `bbj should-fail` block must fail at least one (a block that
only `bbjcpl` fails is fine), and the structure lints (description length, denylist, `## Sources`
with a `Verified on BBj` line) must hold. Edit the draft inside `$ROOT`, repeat, and copy it into
`plugins/bbj/skills/` when the run is clean.

BBj code is never executed in any of these steps.
