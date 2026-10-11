---
phase: 04-bbj-programming-makeover
plan: 01
subsystem: testing
tags: [bbjcpl, bbj-ls, probes, compile-evidence, reserved-words, python-stdlib]

requires:
  - phase: 03-example-gate-and-structure-lints
    provides: "gate constants and route mechanics (CPL_ARGS, canary pair, loopback bbj-ls request) copied into the probe runner"
provides:
  - "probes/run.py: compile-only probe runner (one batched bbjcpl -t -N -X call, a -W call for *_w probes, loopback bbj-ls, canary pair, --check)"
  - "73 minimal probe files, one per COMPILE observation the ledger and the rewrite plans cite"
  - "probes/OUTPUT.txt: recorded bbjcpl and bbj-ls verdicts on BBj 26.03, reproducible with --check"
  - "probes/rw-words.txt and the re-proof of the reserved-word tiers on both routes (D-13)"
  - "probes/README.md: rerun and scratch-root dry-run recipe"
affects: [04-02, 04-03, 04-04, 04-05, 04-06]

actuals:
  tokens: 10200
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "probe file to OUTPUT.txt line to ledger row (D-03)"
    - "generated reserved-word files, recorded as six summary lines instead of 993 committed files"

key-files:
  created:
    - .planning/phases/04-bbj-programming-makeover/probes/run.py
    - .planning/phases/04-bbj-programming-makeover/probes/OUTPUT.txt
    - .planning/phases/04-bbj-programming-makeover/probes/rw-words.txt
    - .planning/phases/04-bbj-programming-makeover/probes/README.md
    - ".planning/phases/04-bbj-programming-makeover/probes/*.bbj (73 files)"
  modified: []

key-decisions:
  - "run.py records, per probe, the normalized bbjcpl records (temporary directory removed everywhere, messages inside the first [...] of a type check record sorted) so OUTPUT.txt does not depend on the temp path"
  - "Reserved-word files are generated in the temporary directory and compiled in the same batched call; only the failing words per route and form are committed"
  - "t22 and t23 added beyond the plan to separate int() of a string literal, a string variable and an object variable (see Deviations)"

patterns-established:
  - "Evidence runner shape: canary pair first, unattributed compiler line or verdict-less reply exits 1 and writes nothing, atomic OUTPUT.txt write, --check compares line by line"

requirements-completed: [PROG-01]

duration: 8min
completed: 2026-10-11
status: complete
plan_head_before: 32840c69220aff9bd7cc229e35111d23abddce73
plan_head_after: edd3b8f4bdcc04337c7d559cfa998fcf06004072
commits: 2

coverage:
  - id: D1
    description: "Compile-only probe runner that reproduces OUTPUT.txt on a rerun"
    requirement: "PROG-01"
    verification:
      - kind: other
        ref: "python3 -I .planning/phases/04-bbj-programming-makeover/probes/run.py --check (gate probes_canary ok, gate probes_reproduce ok 73 probes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "73 probe files covering every COMPILE observation of the research Probe results table, with recorded bbjcpl and bbj-ls output and the BBj version"
    requirement: "PROG-01"
    verification:
      - kind: other
        ref: "Task 2 verify command: 13 marker strings in OUTPUT.txt, at least 60 probes, e26e and e26f byte-identical to RESEARCH Pattern 1"
        status: pass
    human_judgment: false
  - id: D3
    description: "Reserved-word tiers re-proved by compile on both routes (numeric 56 words, string and object forms fnend and fnerr only)"
    requirement: "PROG-01"
    verification:
      - kind: other
        ref: "OUTPUT.txt lines 'rw bbjcpl numeric 56', 'rw bbj-ls numeric 56', 'rw bbjcpl string 2: fnend fnerr', 'rw bbj-ls object 2: fnend fnerr'"
        status: pass
    human_judgment: false
  - id: D4
    description: "Rerun and scratch-root dry-run recipe in probes/README.md"
    requirement: "PROG-01"
    verification: []
    human_judgment: true
    rationale: "A recipe is prose; its commands were checked by reading against tests/test_skill_examples.py, but no test executes the dry-run steps"
---

# Phase 4 Plan 01: Compile-only probe runner and COMPILE evidence Summary

**A compile-only runner (`bbjcpl -t -N -X` plus loopback `bbj-ls`, canary-guarded) with 73 minimal probes and a recorded OUTPUT.txt on BBj 26.03 that `--check` reproduces; the 331 reserved words are re-proved by compile on both routes.**

## Performance

- **Duration:** about 8 min
- **Started:** 2026-10-11T08:17Z (execution start recorded in STATE.md)
- **Completed:** 2026-10-11T08:25Z
- **Tasks:** 2 (one tracer, one auto)
- **Files created:** 77 (73 probes, run.py, OUTPUT.txt, rw-words.txt, README.md); none shipped

## Accomplishments

- `probes/run.py` (stdlib only, `python3 -I`): copies the probes into a fresh temp directory, compiles them in one batched `bbjcpl -t -N -X` call (a second batched call adds `-W` for `*_w.bbj`), posts each to the loopback `bbj-ls` with the hook's body and headers, guards the run with the canary pair, and writes or compares `OUTPUT.txt`. Gate lines: `probes_canary`, `probes_written`, `probes_reproduce`.
- Tracer (task 1): the trailing-rem pair t03/t04 went through the whole path first; `--check` reproduced it before any expansion (`Tracer verified end-to-end`).
- 73 probes named by the research ids (t, b, u, e26, a, q, s, ev, i, d). Every expected outcome of the research table was reproduced except t17 (see below). e26e and e26f are byte-identical to RESEARCH Pattern 1 (checked by script) and become the SKILL.md pair in plan 04-03.
- Reserved words (D-13): `rw-words.txt` holds the 331 words; fresh result on BBj 26.03, identical on both routes: 56 words fail as a bare numeric name (`all argc begin callback case chn csoff cson ctl day dread dsz else endif err exitto fi fnend fnerr for from gosub goto if iol iolist let list load new on opts pfx process_events psz read_resource remove_callback restore rev seterr setesc sqlchn sqlunt ssn swend switch sys table tbl then tim unt until wend where while`); `fnend` and `fnerr` are the only failures in the string and object forms.
- Safety checks held: `CPL_ARGS = ["-t", "-N", "-X"]` is the only argument set, the only URL in run.py is `http://127.0.0.1:5009/mcp`, `OPENER` has an empty `ProxyHandler` and a refusing redirect handler, and nothing under `plugins`, `tests` or `codex` changed. `sh tests/run.sh` with `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1`: `ok=703 fail=0 skip=163`, the same as before the plan.

## Probes whose fresh result differs from the RESEARCH table

| Probe | RESEARCH says | Fresh on BBj 26.03 |
|-------|---------------|--------------------|
| t17_int_str (`n = int("42")`) | clean on both routes ("not compile-observable") | **fails both routes**: bbjcpl `error at line 10 (1): n = int("42")`, bbj-ls `line 1, column 1: [SyntaxError] Invalid function parameters` |

Notes for the ledger (not differences, but wording to keep exact):

- `int()` of a **string primitive** fails to compile (t17 literal, t22 `a$ = "42"` then `int(a$)`: same two lines at the call); `int()` of an **object variable** (t23 `a! = "42"`, `int(a!)`) compiles clean on both routes. So "int() does not parse a string" is partly compile-observable (string primitives), and the old skill's `int(countStr!)` example compiles. The row for the `num()` versus `int()` rule in plan 04-02 should cite t17, t18, t22, t23.
- e26e fails at `methodret config!` on file line 8 (`at line 80 (8)`) for the exact RESEARCH Pattern 1 program; the research W8 text `at line 90 (9)` came from a different program of that session.
- The type check error of d03 repeats its message twice inside one record (`[Cannot assign <undeclared> to BBjNumber; Cannot assign <undeclared> to BBjNumber]`); the runner sorts, it does not deduplicate.
- q04 prints no record from the `-t -N -X` call and two `type check warning` records from the `-W` call (line 1 `Undeclared variable: raw!`, line 2 both `raw!` and `raw2!`).

## Task Commits

1. **Task 1: tracer, trailing-rem probe pair through run.py into OUTPUT.txt and back through --check** - `26a7c35` (docs)
2. **Task 2: every COMPILE observation as a committed probe, reserved-word tiers, README** - `edd3b8f` (docs)

**Plan metadata:** the SUMMARY, STATE and ROADMAP commit follows this file.

## Files Created/Modified

- `.planning/phases/04-bbj-programming-makeover/probes/run.py` - runner (functions: `cpl_path`, `ls_up`, `probe_names`, `attribute`, `compile_batch`, `normalize`, `ls_call`, `ls_verdict`, `ls_check`, `rw_words`, `collect`, `render`, `write_output`, `main`; constants as planned plus `RW_PATH`, `RW_WORD_RE`, `RW_FORMS`, `HEADER`; class `_NoRedirect`)
- `.planning/phases/04-bbj-programming-makeover/probes/OUTPUT.txt` - recorded evidence, BBj 26.03
- `.planning/phases/04-bbj-programming-makeover/probes/rw-words.txt` - 331 words
- `.planning/phases/04-bbj-programming-makeover/probes/README.md` - rerun and dry-run recipe
- `.planning/phases/04-bbj-programming-makeover/probes/*.bbj` - 73 probes

## Decisions Made

- Record normalization removes the temporary directory everywhere in a record (not only as a prefix), because `No match for method ::<file>::Demo.show(<undeclared>)` names the file; the recorded line reads `::a01_undecl_arg_user.bbj::Demo.show(...)`.
- Reserved-word probes are generated, not committed (993 one-line files); the committed record is the six `rw <route> <form> <count>: <words>` lines.
- The `-W` batched call header line reads `bbjcpl -t -N -X -W, one batched call: ...` and is present because q04 is named `*_w.bbj`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical functionality] Two extra probes to make the int() observation complete**
- **Found during:** Task 2 (fresh t17 result differed from RESEARCH)
- **Issue:** the literal-argument probe t17 fails, which contradicts the RESEARCH note that `int("42")` compiles; the old skill's claim is about a string held in a variable, which the planned probes did not isolate.
- **Fix:** kept t17 as planned (fresh result recorded, not edited) and added t22_int_strvar and t23_int_objvar so the ledger can cite the exact form each rule talks about.
- **Files modified:** probes/t22_int_strvar.bbj, probes/t23_int_objvar.bbj, probes/OUTPUT.txt
- **Commit:** edd3b8f

**Total deviations:** 1 auto-fixed (1 added evidence). **Impact:** none on scope; two files beyond the "about 70" estimate (73 probes).

## Issues Encountered

None blocking. The session's bbj hook may report compile errors after a should-fail probe is written; that is expected and was not acted on.

## Known Stubs

None. Probe programs are intentionally minimal, not stubs.

## Threat Flags

None. No network endpoint, auth path or file access outside `.planning/` was added; run.py contacts only the loopback bbj-ls and starts only `bbjcpl -t -N -X`.

## Next Phase Readiness

Ready for plan 04-02 (ledger): every COMPILE row can cite `probes/<name>.bbj` and the matching `== <name>.bbj` block of OUTPUT.txt. Plans 04-03, 04-05 and 04-06 can use the dry-run recipe in `probes/README.md`.

## Self-Check: PASSED

- FOUND: probes/run.py, probes/OUTPUT.txt, probes/rw-words.txt, probes/README.md, 73 probe files
- FOUND commits: 26a7c35, edd3b8f
- `python3 -I probes/run.py --check` exits 0 (`gate probes_reproduce ok 73 probes`); `git status --porcelain -- plugins tests codex` prints nothing
