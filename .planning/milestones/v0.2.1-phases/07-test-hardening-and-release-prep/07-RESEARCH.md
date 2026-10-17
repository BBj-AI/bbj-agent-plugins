# Phase 7: Test hardening and release prep - Research

**Researched:** 2026-10-12
**Domain:** Local POSIX-sh / Python-stdlib test infrastructure of `bbj-agent-plugins` (no external libraries)
**Confidence:** HIGH (every finding below was read in, or run against, this checkout in this session)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Release tree (REL-05)
- **D-01:** The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5` stay where
  they are, on `gsd/planning-setup`. Phases 7–10 build on top of them, and the Phase 10
  `/gsd-pr-branch` PR carries them to `main` with everything else. This is one PR, like 0.2.0
  (0.2.0 D-01/D-02). There's no early hotfix PR and no separate release branch.
- **D-02:** Fast-forward the local `main` to `origin/main`. Local `main` is at `3c75f4f`, and
  `origin/main` holds the 0.2.0 merge `f15c257`. This is local only and nothing is pushed.
- **D-03:** REL-05 is proven in phase verification, not by a repo gate: `git merge-base
  --is-ancestor <sha> HEAD` for each of the four SHAs, plus a full suite run. An ancestry gate
  would be flaky on CI's shallow checkout, and the gates those fixes added
  (`test_release_text.py`, `test_release_text_mutation.sh`) already pin their content.

### CONTENT_VERSION policy (REL-06)
- **D-04:** The release-text content gates are split into two kinds:
  - **Generic gates run for every version.** `upgrade_addressed` checks the addressee
    "If you installed from `main` before {VERSION}" and the two Claude Code update commands. It
    no longer depends on CONTENT_VERSION.
  - **Fact gates stay pinned to CONTENT_VERSION.** These are `upgrade_quotes` (installer lines
    quoted byte for byte) and `not_run` (the exact Not run lines). Phase 10 re-pins them to
    0.2.1 with that release's facts.
- **D-05:** When `VERSION != CONTENT_VERSION`, the pinned fact gates FAIL with a message that
  says to re-pin the facts. They no longer print `skip`. A version bump therefore can't leave
  stale facts behind or leave a skip that blocks Phase 10's skip=0. This reverses the "skip" half
  of WR-02 (`3a42ebf`) on purpose. WR-02's real goal, letting the next release pass, still holds:
  the next release passes once it has written its own facts.
- **D-06:** Phase 7 changes the shape of the gates and records the policy. The values stay at
  0.2.0: `CONTENT_VERSION = "0.2.0"`, the current `UPGRADE_QUOTES` and `NOT_RUN_LINES`. The suite
  stays green through Phases 7–9 because VERSION is still 0.2.0. Phase 10 writes the 0.2.1 facts
  from the recorded runs. Phase 7 adds no placeholder slot.
- **D-07:** The policy and its reason go in two places:
  - the module docstring of `tests/test_release_text.py`, where a maintainer bumping the
    version will look;
  - a Key Decisions row in `.planning/PROJECT.md`.

  `tests/test_release_text_mutation.sh` gains cases proving that a version mismatch FAILs the
  pinned gates and that the generic `upgrade_addressed` still FAILs on a missing addressee or
  command at a non-CONTENT version.

### Codex home rule (MAINT-07)
- **D-08:** `real_home_untouched` uses an allowlist. It watches only the paths the installer can
  write in the real homes:
  - `~/.codex/config.toml` and `config.toml.bbj-backup`
  - `~/.codex/hooks.json`
  - `~/.codex/bbj/` (recursively)
  - `~/.agents/skills/bbj-programming/` and `~/.agents/skills/bbj-web-programming/` (recursively)

  Everything else is ignored, including daemon files (`*.sqlite*`, `history.jsonl`,
  `sessions/`, `log/`, `tmp/`, ...). A future Codex that adds runtime files can't break the gate.
  Phase 8 adds its plugin-route paths to the same list.
- **D-09:** The gate compares content, not mtime. It takes a snapshot before and after, with the
  path list, the existence of each path, and a `cksum` of each file, then compares the two. A
  watched path that appears, disappears or changes content FAILs. A touch with no content change
  does not. This uses POSIX tools only.
- **D-10:** The snapshot and compare logic becomes a helper that can be pointed at any home.
  A new mutation-style test points it at a throwaway fake home and checks both directions:
  - writing `logs_2.sqlite`/`-wal` and other daemon files → ok;
  - editing `config.toml`, creating `hooks.json`, and changing a file in a skill dir → each
    FAILs.

  It runs in CI without Codex. The cases go in a separate test, not inside the 1500+-line
  `test_install_codex.sh`, which only switches to the helper.

### PATH scrub (MAINT-06)
- **D-11:** `tests/lib.sh` gets a helper (name is up to the planner, e.g. `no_compiler_path`).
  It prints `PATH` with every directory that holds `bbjcpl` or `bbjcplw` removed. Other tools
  (`sh`, `awk`, `curl`, `python3`, `busybox`) stay where they are. The same helper or a sibling
  also clears `BBJ_HOME`, `BBJHOME` and `CLAUDE_PLUGIN_OPTION_BBJ_HOME` and sets
  `BBJ_CHECK_DEFAULT_HOMES` to empty, so none of the other discovery sources finds a compiler.
  The fixed `/usr/bin:/bin` approach was rejected because it breaks when `bbjcpl` is linked into
  `/usr/bin` and drops tools installed elsewhere.
- **D-12:** The scrub applies only where "no compiler anywhere" is required: the no-route gates
  in `tests/test_noroute_notice.sh` and `tests/test_exit_contract.sh`, plus any other no-route
  case the planner finds. Tests that put a fake on `PATH` on purpose (`test_discovery.sh`) or
  opt into a real compiler (`test_real_compiler.sh`) are left alone, and `mkwork` stays as it is.
- **D-13:** A CI gate puts `tests/fake-bin`'s `bbjcpl` (and a `bbjcplw`) at the front of `PATH`,
  runs the no-route tests, and expects them green. A mutation step stubs the helper to a no-op
  and expects them to FAIL. This proves that removing the scrub is caught without a real BBj.

### Claude's Discretion
- MAINT-08: how to rebuild the gate-prefix list. Collect the prefixes `sh tests/run.sh` actually
  prints and update `.planning/codebase/CONVENTIONS.md` first, then `.claude/CLAUDE.md`, which is
  generated from it. `skills_` stays. Whether to add a gate that keeps the list in sync is up to
  the planner. It's optional and must not make CI depend on running the whole suite twice.
- The helper names, file names of the new tests, and the gate names (keep the existing
  per-file prefix convention).
- The exact snapshot format for D-09.

### Deferred Ideas (OUT OF SCOPE)
None. The discussion stayed within the phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MAINT-06 | `sh tests/run.sh` passes on a machine with `bbjcpl` or `bbjcplw` on `PATH`, because `tests/lib.sh` scrubs `PATH` for the no-route gates | "PATH scrub" findings: exact 41 failing gates enumerated with a fake compiler on PATH; helper prototype validated under dash, bash, busybox; D-13 mutation reproduced (35 + 6 gates fail when the helper is a no-op) |
| MAINT-07 | `real_home_untouched` passes while a Codex daemon writes runtime files and still fails on any change to Codex config, hooks or skills | "Codex home rule" findings: installer write-list read from `codex/install-codex.sh`; snapshot/compare prototype validated in both directions under dash, bash, busybox |
| MAINT-08 | The gate-prefix list in `.claude/CLAUDE.md` matches the prefixes the tests actually emit | "Gate prefixes" findings: ground truth taken from a full `sh tests/run.sh` (757 gates), per-file table, the two list locations and their current text |
| REL-05 | The four planning-branch review-fix commits are in the release tree | "Release tree" findings: all four are ancestors of HEAD; `main` fast-forwards to `origin/main`; nothing to cherry-pick |
| REL-06 | The CONTENT_VERSION gate policy in `tests/test_release_text.py` is decided and recorded | "CONTENT_VERSION" findings: how each gate decides today, a concrete reshaping, the mutation-test fixtures that must change |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Source: `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md` (project) [VERIFIED: read this session]. Directives the plans must satisfy:

- **Tech stack:** POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime deps.
- **Never execute BBj:** tests use fakes only; the hook is always called with `-N`; `tests/test_never_execute.sh` enforces it.
- **Shell style:** `#!/bin/sh`; 2-space indent; `[ ... ]` never `[[ ]]`; `$(...)` never backticks; `printf` for data; `command -v x > /dev/null 2>&1` never `which`; no `set -e`; no `local` keyword; script-local temporaries prefixed with an underscore; `> /dev/null` with the space; single quotes around awk/sed/grep programs.
- **Test file shape:** name `tests/test_<area>.sh|.py`; first line after the shebang header comment is `. "$(dirname "$0")/lib.sh"` followed by `mkwork`; gates are `gate NAME ok|FAIL|skip DETAIL`; every file opens with a block comment naming scope, decision IDs and "Nothing here runs BBj"; any global a test changes is restored.
- **Gate prefix:** one prefix per file (see "Gate prefixes" below for how far reality departs from this).
- **Python style:** 4-space indent, double-quoted strings, `%`-formatting (no f-strings), module docstring stating what it locks, `global failed` in `gate()`, optional `argv[1]` root, run as `python3 -I`.
- **Self-scan convention:** a word a static scan would match against the test itself is assembled from pieces (`"unre" + "leased"`).
- **CI semantics:** under `CI=true` a missing prerequisite is a FAIL, not a skip.
- **Lint:** `shellcheck -s sh` over `tests/*.sh` (via `tests/ci.sh`), settings in `.shellcheckrc`; warnings are never disabled globally, a deliberate one carries an inline directive with a reason.
- **Commits:** conventional prefixes with phase scope, e.g. `fix(07-01): ...`, `test(07-02): ...`, `docs(07): ...`.
- **GSD workflow:** repo edits go through a GSD command (`/gsd-execute-phase`), not direct edits.
- `tests/test_layout.py` scans `tests/*.sh` and `tests/*.py` for the vendoring wording and lock-file name it forbids (`tests/test_layout.py:157-170`); new test files must not contain them (do not paste the forbidden words into comments).

## Summary

Phase 7 is four independent pieces of local test-infrastructure work plus one verification-only requirement. I ran the real suite and reproduced the failures the phase exists to prevent. With a fake `bbjcpl` and `bbjcplw` first on `PATH`, exactly two test files go red: `tests/test_noroute_notice.sh` (35 of its 57 gates) and `tests/test_exit_contract.sh` (6 gates: `contract_{dash,bash,busybox}_{no_route,codex_no_route}`). Every other test file stays green. A prototype `no_compiler_path` helper applied in those two files turns both green (57 ok / 86 ok), and stubbing the helper to a no-op makes both red again, so D-11/D-12/D-13 are sound as written.

One refinement to D-11 is needed. Removing a whole PATH directory that holds `bbjcpl` also removes every other tool in that directory. That is harmless for a dedicated `/c/bbx/bin` but breaks the run when the compiler is linked into a shared directory such as `/usr/local/bin` or a Homebrew prefix (which can also hold `python3`, `curl`, `dash`). The repo already has the idiom for this (`$WORK/farm` symlink farms in `tests/test_install_codex.sh` and `tests/test_ci_gates.sh`). The recommended helper replaces an offending directory with a per-call symlink farm of everything in it except the four compiler names. It matches D-11's own intent ("other tools stay where they are") and was validated under dash, bash and busybox sh.

The `real_home_untouched` snapshot/compare (D-09) works with POSIX `find` + `cksum` + `sort` + `cmp`; the prototype ran identically under dash, bash and busybox sh on this host's non-GNU `find` (bfs 4.1.1) and `cksum` (uutils 0.8.0). REL-05 needs no code: all four commits are already ancestors of HEAD and the full suite passes at HEAD (`SUMMARY: ok=757 fail=0 skip=0`, 84 s). REL-06 is a small reshaping of `tests/test_release_text.py` plus changed fixtures in `tests/test_release_text_mutation.sh`: its existing `release_mut_later_version` case asserts the old skip behavior and must be rewritten, and its fixture deliberately breaks the addressee, which the now-generic `upgrade_addressed` gate would catch.

**Primary recommendation:** Land in this order: (1) REL-06 gate reshaping + mutation cases + docs rows; (2) `no_compiler_path` helper + call sites + new `tests/test_path_scrub.sh`; (3) snapshot helper in `tests/lib.sh` + switch in `test_install_codex.sh` + new `tests/test_home_guard.sh`; (4) MAINT-08 prefix list last, so it includes the prefixes of the two new test files; (5) REL-05 verification commands and the local `main` fast-forward as the closing steps.

## Architectural Responsibility Map

This phase has no web tiers; the "tiers" are the layers of the test harness.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| PATH / env scrub for no-route gates | Shared test helpers (`tests/lib.sh`) | Individual no-route test files (call sites) | One definition, many callers; `mkwork` stays untouched (D-12) |
| Proof that the scrub is load-bearing | New CI-run test (`tests/test_path_scrub.sh`) | `tests/fake-bin/bbjcpl` | Nested runs of the two no-route tests with a fake compiler first on PATH; mutation by redefining the helper |
| Real-home change detection | Shared test helpers (`tests/lib.sh`: snapshot + compare) | `tests/test_install_codex.sh` (consumer) | Helper must point at any home so a second test can drive it on a fake home |
| Both-direction proof of the home gate | New test (`tests/test_home_guard.sh`) on a throwaway fake home | — | Runs without Codex in CI (D-10) |
| Release-text gate policy | `tests/test_release_text.py` (gate logic + docstring) | `tests/test_release_text_mutation.sh` (proof), `.planning/PROJECT.md` (decision row) | D-07 puts the policy where the bumping maintainer looks, and in the decision log |
| Gate-prefix documentation | `.planning/codebase/CONVENTIONS.md` (source) | `.claude/CLAUDE.md` (generated copy) | CLAUDE.md block `GSD:conventions` is generated from CONVENTIONS.md |
| REL-05 proof | Phase verification (git commands) | — | D-03: no repo gate |

## Standard Stack

No external libraries. Everything is already in the repo's allowed stack.

### Core
| Tool | Version here | Purpose | Why Standard |
|------|--------------|---------|--------------|
| POSIX `sh` (dash) | dash on Ubuntu; bash 5.3.9; BusyBox 1.37.0 | Test scripts run under `sh`; exit-contract test also runs bash and `busybox sh` | Project convention [VERIFIED: tests/run.sh, tests/test_exit_contract.sh read] |
| `find`, `cksum`, `sort`, `cmp`, `diff`, `ln`, `rm`, `mktemp` | `find` = bfs 4.1.1, `cksum` = uutils 0.8.0 on this host | Snapshot/compare (D-09), symlink farm (D-11) | All POSIX; prototype ran under both non-GNU variants [VERIFIED: ran in scratch] |
| Python 3 stdlib | 3.14.4 | `tests/test_release_text.py` and any new Python test, run as `python3 -I` | Project convention |
| ShellCheck | 0.11.0 | Lint of every `tests/*.sh` via `tests/ci.sh` | Project convention; both prototypes are clean under `shellcheck -s sh` |

### Supporting
| Item | Purpose | When to Use |
|------|---------|-------------|
| `tests/fake-bin/bbjcpl` | Fake compiler: logs to `$FAKE_LOG`, exits `${FAKE_EXIT:-0}`, prints nothing by default | D-13 gate: copy it to a scratch dir twice, once as `bbjcpl` and once as `bbjcplw` (`tests/fake-bin/` has no `bbjcplw`) |
| `tests/test_release_text_mutation.sh` | Copy-the-tree-then-mutate pattern | Model for D-07, D-10 and D-13 cases |
| `$WORK/farm` idiom (`tests/test_install_codex.sh:57-61`, `tests/test_ci_gates.sh:9-14`) | Symlink farm of selected tools | Precedent for the shared-directory case of the PATH scrub |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Per-dir symlink farm (recommended) | Plain removal of the offending directory (D-11 as written) | Plain removal is simpler but drops every other tool in a shared dir (see Pitfall 1); acceptable only if the helper also fails loudly when `sh`/`awk`/`python3` vanish |
| `find ... -print \| while read` + `cksum < file` | `find -exec cksum {} +` | `-exec ... +` is POSIX but busybox support varies by build; the `read` loop avoids it and keeps file names out of cksum's output |

**Installation:** none (no packages).

**Version verification:** not applicable (no registry packages). Tool versions above were read from the host in this session.

## Package Legitimacy Audit

No external packages are installed or recommended by this phase. Nothing to audit.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
                        sh tests/run.sh   (discovers tests/test_*.sh then tests/test_*.py; counts "gate " lines)
                               |
        +----------------------+-------------------------------+---------------------------+
        v                      v                               v                           v
 test_noroute_notice.sh  test_exit_contract.sh        test_install_codex.sh       test_release_text.py
 test_exit_contract.sh   (no-route cases)             (real_home_untouched)       test_release_text_mutation.sh
        |                      |                               |                           |
        |  PATH=$(no_compiler_path)  [NEW, tests/lib.sh]       |  home_snapshot [NEW]      |  VERSION (test_layout.py)
        |   - drop/farm every PATH dir holding bbjcpl*         |   before ... after        |  vs CONTENT_VERSION
        |   - env: unset BBJ_HOME BBJHOME                      |   home_diff [NEW]         |   generic: upgrade_addressed
        |          CLAUDE_PLUGIN_OPTION_BBJ_HOME               v                           |   pinned:  upgrade_quotes, not_run
        |          BBJ_CHECK_DEFAULT_HOMES=                 allowlist only:                 |   mismatch => FAIL "re-pin"
        v                                                   ~/.codex/{config.toml,           v
 plugins/bbj/scripts/bbj-check.sh  discover():               config.toml.bbj-backup,   mutation copies of the
   1 CLAUDE_PLUGIN_OPTION_BBJ_HOME                           hooks.json, bbj/}          six files the gate reads
   2 BBJ_HOME   3 BBJHOME                                   ~/.agents/skills/
   4 PATH (command -v bbjcpl, bbjcplw)                        {bbj-programming,
   5 BBJ_CHECK_DEFAULT_HOMES (set=list, unset=4 homes)         bbj-web-programming}
   -> none: tier 2 (loopback curl) -> none: no-route notice

 NEW tests (run by run.sh like any other):
   tests/test_path_scrub.sh  nested `PATH=$WORK/cplbin:$PATH sh tests/test_noroute_notice.sh` (+ exit_contract)  => green
                             same on a copy of tests/ whose lib.sh redefines the helper as a no-op           => FAIL (proof)
   tests/test_home_guard.sh  fake home: daemon files => same snapshot; config/hooks/skill/bbj changes => differ
```

### Recommended Project Structure
```
tests/
├── lib.sh                    # + no_compiler_path, no_compiler_env, home_snapshot, home_diff; header comment lists them
├── test_path_scrub.sh        # NEW (MAINT-06, D-13); gate prefix e.g. pathscrub_
├── test_home_guard.sh        # NEW (MAINT-07, D-10); gate prefix e.g. homeguard_
├── test_noroute_notice.sh    # call site: PATH scrub after mkwork (+ SYSPATH/CURLPATH)
├── test_exit_contract.sh     # call site: scrub around the two no-route blocks
├── test_install_codex.sh     # real_home_untouched switches to the helper; drop `: > marker` and `sleep 1`
├── test_release_text.py      # D-04..D-07 reshaping + docstring
└── test_release_text_mutation.sh   # rewritten later-version cases + new cases
```
The two new file names do not collide with the glob-discovered existing set, and `tests/run.sh` picks them up automatically.

### Pattern 1: Scrubbed PATH helper (D-11), validated prototype

**What:** `no_compiler_path [PATHVALUE]` prints PATHVALUE (default `$PATH`) with each directory that holds a compiler replaced by a symlink farm of its other entries. Called as `PATH=$(no_compiler_path)`. The env half is a separate function called directly (not in `$(...)`, which cannot change the caller's environment).

**When to use:** only where "no compiler anywhere" is required (D-12): all of `tests/test_noroute_notice.sh` apart from the cases that set a fake `BBJ_HOME` on purpose (those are unaffected, `BBJ_HOME` is tried before PATH), and the `_savehome` block of `tests/test_exit_contract.sh`.

**Example:** (prototype ran under dash, bash and `busybox sh`; `shellcheck -s sh` clean)
```sh
# no_compiler_path [PATHVALUE]: prints PATHVALUE (default: PATH) without any directory that holds
# a BBj compiler (bbjcpl, bbjcpl.exe, bbjcplw, bbjcplw.exe: the names discover() tries). A shared
# directory keeps its other tools through a symlink farm under $WORK; with no $WORK it is dropped.
no_compiler_path() {
  _ncp_in=${1-$PATH}
  _ncp_out=
  _ncp_oifs=$IFS
  IFS=:
  set -f
  for _ncp_d in $_ncp_in; do
    [ -n "$_ncp_d" ] || continue
    _ncp_hit=0
    for _ncp_n in bbjcpl bbjcpl.exe bbjcplw bbjcplw.exe; do
      if [ -e "$_ncp_d/$_ncp_n" ] || [ -L "$_ncp_d/$_ncp_n" ]; then _ncp_hit=1; break; fi
    done
    if [ "$_ncp_hit" = 1 ]; then
      if [ -n "${WORK:-}" ] && _ncp_farm=$(mktemp -d "$WORK/pathfarm.XXXXXX"); then
        set +f   # the farm needs the glob that set -f switched off
        ln -s "$_ncp_d"/* "$_ncp_farm"/ 2> /dev/null
        set -f
        rm -f "$_ncp_farm/bbjcpl" "$_ncp_farm/bbjcpl.exe" "$_ncp_farm/bbjcplw" "$_ncp_farm/bbjcplw.exe"
        _ncp_d=$_ncp_farm
      else
        continue
      fi
    fi
    _ncp_out=${_ncp_out:+$_ncp_out:}$_ncp_d
  done
  set +f
  IFS=$_ncp_oifs
  printf '%s' "$_ncp_out"
}

# no_compiler_env: neutralise the other discovery sources of bbj-check.sh in the calling shell
no_compiler_env() {
  unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME
  BBJ_CHECK_DEFAULT_HOMES=
  export BBJ_CHECK_DEFAULT_HOMES
}
```
Call sites (validated by patching a scratch copy):
```sh
# tests/test_noroute_notice.sh, right after mkwork (the farm lives under $WORK and goes with it)
mkwork
PATH=$(no_compiler_path)

# tests/test_exit_contract.sh, inside the existing "_savehome" block
  _savehome=$BBJ_HOME
  _savepath=$PATH
  PATH=$(no_compiler_path)
  unset BBJ_HOME
  ... (the four no-route run_check calls) ...
  PATH=$_savepath
  BBJ_HOME=$_savehome
  export BBJ_HOME
```
The scratch run with a fake `bbjcpl`+`bbjcplw` first on `PATH` and these two edits: `test_noroute_notice.sh` rc=0, 0 FAIL, 57 ok; `test_exit_contract.sh` rc=0, 0 FAIL, 86 ok [VERIFIED: ran in scratch copy]. The same copy with the helper redefined as `no_compiler_path() { printf "%s" "${1-$PATH}"; }` appended to `lib.sh`: noroute rc=1 with 35 FAIL, exit contract rc=1 with 6 FAIL [VERIFIED: ran].

### Pattern 2: D-13 gate (`tests/test_path_scrub.sh`)

**What:** (a) unit gates on the helper with a synthetic PATH; (b) green gate: nested run of the two no-route tests with the fake compiler first on `PATH`; (c) mutation gate: nested run on a copy of `tests/` whose `lib.sh` has the helper redefined as a no-op, expecting rc 1 and FAIL gates.

**Pitfalls inside this pattern:**
- Redirect every nested run's output to a file under `$WORK`. `tests/run.sh` counts every line starting `gate ` in a test's stdout; echoing the nested run (especially the mutated one, full of `FAIL`) would turn the suite red. `tests/test_release_text_mutation.sh` already does this (`> "$WORK/out" 2> "$WORK/err"`).
- Build the fake-compiler directory as a scratch copy, not by putting `tests/fake-bin` itself on PATH: `fake-bin` also holds a fake `curl`, `bbj`, `codex` and `cygpath`, which would contaminate the nested run. Copy `tests/fake-bin/bbjcpl` to `$WORK/cplbin/bbjcpl` and `$WORK/cplbin/bbjcplw`, `chmod 755`.
- For the mutation copy: `cp -R "$REPO/tests" "$WORK/mut/tests"`, append the no-op redefinition to the copy's `lib.sh` (a later function definition wins in POSIX sh), and `SCRIPT="$REPO/plugins/bbj/scripts/bbj-check.sh"` in the environment so the copy does not need `plugins/` (`lib.sh:` `SCRIPT=${SCRIPT:-$REPO/plugins/bbj/scripts/bbj-check.sh}` [VERIFIED: tests/lib.sh]). The copy's `REPO` resolves to `$WORK/mut`, so `$REPO/tests/fake-bin` and `$REPO/tests/fake_mcp.py` are found inside the copy.
- Clear `FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT` before the nested runs (they are test-local in the files that set them, but a leaking value from an earlier gate would be confusing).
- Cost: `test_noroute_notice.sh` takes about 8 s and `test_exit_contract.sh` about 4 s [VERIFIED: timed]. Green plus mutation nested runs add about 24 s to the 84 s suite; CI's job timeout is 15 minutes (`.github/workflows/ci.yml`), so there is ample room.

A second assertion in the green gate is cheap and worth having: after the nested run, grep its output for zero `^gate .* FAIL ` lines and require rc 0, not just rc 0 (the runner treats rc 1 as red either way, but the count makes the failure message useful).

### Pattern 3: Snapshot + compare of watched home paths (D-08, D-09, D-10), validated prototype

**What:** `home_snapshot CODEXHOME SKILLSDIR` prints a sorted, line-per-entry listing of exactly the allowlisted paths; `home_diff BEFORE AFTER` compares two snapshot files and prints the first differing lines. The real-home gate passes `"$REALHOME/.codex"` and `"$REALHOME/.agents/skills"`; the new test passes fake directories.

**Example:** (prototype ran under dash, bash and `busybox sh` on bfs `find` and uutils `cksum`; `shellcheck -s sh` clean)
```sh
# home_snapshot CODEXHOME SKILLSDIR: one line per entry under the paths the installer can write:
#   F <crc> <size> <path>   regular file (content checksum, never a time)
#   D <path>   directory     L <path>   symlink     U <path>   unreadable     - <path>   absent
home_snapshot() {
  _hs_c=$1
  _hs_s=$2
  for _hs_p in "$_hs_c/config.toml" "$_hs_c/config.toml.bbj-backup" "$_hs_c/hooks.json" \
    "$_hs_c/bbj" "$_hs_s/bbj-programming" "$_hs_s/bbj-web-programming"; do
    if [ -L "$_hs_p" ]; then
      printf 'L %s\n' "$_hs_p"
    elif [ -e "$_hs_p" ]; then
      find "$_hs_p" -print | while IFS= read -r _hs_f; do
        if [ -L "$_hs_f" ]; then printf 'L %s\n' "$_hs_f"
        elif [ -d "$_hs_f" ]; then printf 'D %s\n' "$_hs_f"
        elif [ -r "$_hs_f" ]; then printf 'F %s %s\n' "$(cksum < "$_hs_f")" "$_hs_f"
        else printf 'U %s\n' "$_hs_f"
        fi
      done
    else
      printf -- '- %s\n' "$_hs_p"
    fi
  done | LC_ALL=C sort
}
```
Cases run against a fake home with this helper, all as expected under the three shells [VERIFIED: ran]: logs_2.sqlite grown, `-wal` and `-shm` created, a new `sessions/` file, a `tmp/` directory, and `touch` on `config.toml` and a skill file leave the snapshot identical; editing `config.toml`, creating `hooks.json`, changing a file inside `bbj-programming/references/` (name with a space), a skill directory appearing, a skill directory disappearing, creating `<codex home>/bbj/bbj-check.sh` each change it; restoring the content makes it identical again.

`home_diff` can be `diff "$1" "$2" | head -n 3` (POSIX `diff`) with the gate returning non-zero when the files differ (`cmp -s`). In `test_install_codex.sh` replace lines 28-30 (`REALHOME=...`, `: > "$WORK/marker"`, `sleep 1`) with `home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.before"` (keep `REALHOME`), and replace the `find -newer` gate (lines 1519-1521) with the compare; the `sleep 1` (needed only for mtime resolution) goes away.

### Pattern 4: Release-text gate reshaping (D-04 .. D-07)

See "CONTENT_VERSION policy: how the gates decide today" below for the current code and the proposed code.

### Anti-Patterns to Avoid
- **Scrubbing inside `mkwork` or globally in `lib.sh`:** D-12 forbids it; `tests/test_discovery.sh` and `tests/test_never_execute.sh` put a fake on PATH on purpose, `tests/test_real_compiler.sh` opts into a real one.
- **Echoing a nested test's output:** doubles gate counts and leaks `FAIL` lines into the outer run (see Pattern 2).
- **Watching mtimes or `find -newer`:** the thing being replaced; content checksums are insensitive to daemon `touch` and to clock resolution.
- **Putting the new cases inside `test_install_codex.sh`:** D-10 says separate test; that file already takes 31 s.
- **Calling the env scrub through `$(...)`:** a command substitution runs in a subshell; the unset/export would be lost.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Content comparison of a directory tree | A custom recursive walker or hashing in Python | `find` + `cksum` + `LC_ALL=C sort` + `cmp` | POSIX, already proven on three shells; `tests/` is sh-only for infra |
| "Run this test against a broken copy" | A new harness | The copy-tree-then-mutate shape of `tests/test_release_text_mutation.sh` (`fresh_root`, `mutate`) | Established pattern, reviewers know it |
| Fake compiler | A new stub | `tests/fake-bin/bbjcpl` copied under both compiler names | Already logs, exit-code controllable, never runs BBj |
| Tool subset on a restricted PATH | Hard-coded `/usr/bin:/bin` | Symlink farm (existing `$WORK/farm` idiom) | Rejected approach in D-11; farm keeps tools wherever they live |
| Gate-prefix inventory | A hand-typed list | `awk` over a real `sh tests/run.sh` transcript (command in "Gate prefixes") | Hand lists drifted: that is MAINT-08 |

**Key insight:** every piece here already has an in-repo precedent; the risk is in details (nested output counting, directory sharing, glob toggling under `set -f`), not in missing capabilities.

## Findings by requirement

### PATH scrub (MAINT-06): discovery sources and affected gates

**Every discovery source in `plugins/bbj/scripts/bbj-check.sh`** [VERIFIED: read `discover()` lines 413-440 and `find_cpl_on_path` lines 397-411]:

```sh
discover() {
  CPL=
  for _h in "$CLAUDE_PLUGIN_OPTION_BBJ_HOME" "$BBJ_HOME" "$BBJHOME"; do
    if [ -n "$_h" ] && find_cpl_in_home "$_h"; then return 0; fi
  done
  if find_cpl_on_path; then return 0; fi
  if [ "${BBJ_CHECK_DEFAULT_HOMES+set}" = set ]; then
    _list=$BBJ_CHECK_DEFAULT_HOMES
    _sep=:
  else
    _list='/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx'
    _sep=' '
  fi
```
and `find_cpl_on_path` is `for _n in bbjcpl bbjcplw; do _c=$(command -v "$_n" ...)` accepting only an absolute, regular, executable result; `find_cpl_in_home` tries `"$_hd/bin"` then `"$_hd"` with names `bbjcpl bbjcpl.exe bbjcplw.exe bbjcplw`.

| # | Source | Neutralised by | State today |
|---|--------|----------------|-------------|
| 1 | `CLAUDE_PLUGIN_OPTION_BBJ_HOME` | `unset` | `tests/lib.sh:41` unsets it at source time (`unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR`) |
| 2 | `BBJ_HOME` | `unset` | same; `test_exit_contract.sh` sets it on purpose at the top and unsets it around its no-route block |
| 3 | `BBJHOME` | `unset` | same |
| 4 | `PATH` (`bbjcpl`, `bbjcplw`) | **not neutralised anywhere: this is MAINT-06** | the new helper |
| 5 | `BBJ_CHECK_DEFAULT_HOMES` | set to empty (`set` and empty = no homes) | `tests/lib.sh:39-40` (`BBJ_CHECK_DEFAULT_HOMES=` then `export`); if unset the four built-in homes apply |

Sources 1, 2, 3 and 5 are already neutral after `. lib.sh`, so the new env function is belt-and-braces for call sites that follow a test's own `export BBJ_HOME`. Tier 2 is separate and already hermetic: `lib.sh` sets `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp` (a closed port).

**Gates that need the scrub** (measured: fake `bbjcpl` + `bbjcplw` first on `PATH`, every test file run on its own) [VERIFIED: ran]:

- `tests/test_exit_contract.sh`: 6 FAIL: `contract_dash_no_route`, `contract_dash_codex_no_route`, `contract_bash_no_route`, `contract_bash_codex_no_route`, `contract_busybox_no_route`, `contract_busybox_codex_no_route`. The `_repeat` gates and all `BBJ_HOME`-driven gates stay green. Call site: the `_savehome=$BBJ_HOME ... BBJ_HOME=$_savehome` block (lines 93-107).
- `tests/test_noroute_notice.sh`: 35 of 57 gates FAIL: `notice_shape_{dash,bash}`, `notice_text_claude`, `notice_last_sentence`, `notice_not_error_grammar`, `notice_marker_in_state_dir`, `notice_other_session`, `notice_codex_text`, `notice_codex_text_no_claude_steps`, `notice_edit_text`, `notice_two_files`, `notice_path_cap`, `notice_path_cap_rest`, `notice_long_names_bounded`, `notice_hostile_names_json`, `notice_no_session_every_call`, `notice_empty_key_every_call`, `notice_key_sanitised`, `notice_key_max_64`, `notice_uuid_key_intact`, `notice_symlink_squat`, `notice_file_squat`, `notice_unwritable_state`, `notice_missing_state`, `notice_tmpdir_fallback`, `notice_concurrent_once`, `notice_marker_without_claim`, `notice_claim_symlink_squat`, `notice_exit2_keeps_slot`, `notice_fake_{rpc_error,garbage,is_error,empty,no_verdict}_silent`, `notice_errors_no_notice`. All run with `BBJ_HOME` unset and the inherited PATH. A single `PATH=$(no_compiler_path)` right after `mkwork` (line 19) covers all of them; the gates that set `BBJ_HOME=$WORK/home`, `d02`, `home3` on purpose are unaffected because `BBJ_HOME` is tried before PATH.
- No other test file has a failing gate with a fake compiler on PATH: `test_discovery.sh`, `test_tier2_fake.sh`, `test_tier2_live.sh`, `test_never_execute.sh`, `test_real_compiler.sh`, `test_codex_patch.sh`, `test_hook_review_fixes.sh`, `test_install_codex.sh`, `test_install_pages.sh`, `test_claude_plugin.sh`, `test_skill_examples.py`, the layout/CI-guard/release-text tests are green. (A first awk pass reported `test_ci_gates.sh` and `test_skill_examples.py` gates only because their gate names and `ok` detail text contain the word FAIL; checked by status column: they are `ok`.)
- **Residual exposure (outside D-12, optional hardening):** `test_noroute_notice.sh:570-577` (`SYSPATH=/usr/bin:/bin`, `CURLPATH=$WORK/curlbin:$SYSPATH`), `test_tier2_fake.sh:21,194`, `test_discovery.sh:8` (`BASEPATH`), `test_tier2_live.sh:13` build their own PATH from `/usr/bin:/bin`, so they are immune to a compiler in a dedicated directory but would see one linked into `/usr/bin` or `/bin`. `test_tier2_live.sh:41-42` already fails loudly in that case (`live_no_compiler FAIL "a bbjcpl is on $SYSPATH; tier 1 would win"`). Cheap fix inside the file that is already being edited: `SYSPATH=$(no_compiler_path /usr/bin:/bin)` in `test_noroute_notice.sh`. Leave the others, per D-12.

### Codex home rule (MAINT-07): the installer's write-list

Read from `codex/install-codex.sh` this session (header lines 1-97 and the step code) [VERIFIED]. With `CODEX_HOME` default `~/.codex` and skills dir default `~/.agents/skills`:

| Path | Written by | Evidence |
|------|-----------|----------|
| `<codex home>/config.toml` | direct block write, or by `codex mcp add` | lines 448-525, 561-628 |
| `<codex home>/config.toml.bbj-backup` | `cp "$config" "$config.bbj-backup"` before the first change | line 438 |
| transient `<codex home>/config.toml.XXXXXX`, `hooks.json.XXXXXX` | `mktemp`, removed or moved | lines 486, 561, 756 |
| `<codex home>/hooks.json` | only when absent | lines 755-769 |
| `<codex home>/bbj/bbj-check.sh` | `cp "$src_script" "$script_dst"` (`script_dst=$codex_home/bbj/bbj-check.sh`) | lines 215, 733-737 |
| `<skills dir>/bbj-programming`, `<skills dir>/bbj-web-programming` | `cp -R "$src" "$dst"`, replaced with `rm -rf` under `--force` | lines 715-724 |

This is exactly the D-08 allowlist; the transient temp files are inside `~/.codex` but are renamed or removed before the installer exits, so they are not part of any snapshot (and the tests run the installer only against temp homes, never the real one).

**State of the real home on this host** [VERIFIED: ls, key names only]: `~/.codex` holds `logs_2.sqlite`, `state_5.sqlite`, `goals_1.sqlite`, `memories_1.sqlite`, `history.jsonl`, `sessions/`, `log/`, `skills/`, `.tmp/`, `tmp/` and more; `~/.codex/config.toml` has `[projects."..."] trust_level` and `[tui]` keys and an mtime of 17:50 today (written by Codex itself); `~/.codex/hooks.json`, `~/.codex/bbj` and `~/.agents` do not exist. None of those daemon files fall inside the allowlist.

**Current gate** (`tests/test_install_codex.sh:28-30` and `1519-1521`): `: > "$WORK/marker"; sleep 1` early, and at the end `touched=$(find "$REALHOME/.codex" "$REALHOME/.agents" -newer "$WORK/marker" 2> /dev/null | head -n 3)` with `[ -z "$touched" ] && gate real_home_untouched ok ... || gate real_home_untouched FAIL "changed: $touched"`. It watches the whole of both homes by mtime, which is why a daemon writing `logs_*.sqlite*` fails it.

**Accepted residual risk:** because `config.toml` is on the allowlist (the roadmap requires it) and Codex rewrites it itself when a project is trusted or a TUI option is set, a Codex session that starts and trusts a new project during the roughly 90-second run would change its content and fail the gate. That is a real change to the watched file and indistinguishable from an installer write, so the gate cannot and should not hide it. Record it in the helper's comment (the 0.2.0 D-18 advice to run the release suite with no Codex session being started still applies, with the narrower scope "do not open Codex in a new project during the run").

### CONTENT_VERSION policy: how the gates decide today

`tests/test_release_text.py` [VERIFIED: read in full]. `VERSION` comes from the single `VERSION = "x.y.z"` line of `tests/test_layout.py`; `CONTENT_VERSION = "0.2.0"` is at line 44; `pinned = VERSION == CONTENT_VERSION` at line 133. Constants at the top, verbatim:

```python
UPGRADE_QUOTES = [
    "rerun with --force to replace it",
    "every update of it makes Codex ask for the /hooks review again",
    "open /hooks, and approve the BBj check hook",
]
CONTENT_VERSION = "0.2.0"
NOT_RUN_LINES = [
    "- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.",
    "- macOS: not run on macOS.",
]
```

| Gate | Computation today | Pinned? | Result at VERSION == CONTENT_VERSION | At any other VERSION |
|------|-------------------|---------|--------------------------------------|----------------------|
| `upgrade_addressed` (line 138) | `need = ["If you installed from \`main\` before %s" % VERSION, "claude plugin marketplace update basis-bbj", "claude plugin update bbj@basis-bbj"]`; `missing = [n for n in need if n not in upgrading]` (squashed Upgrading section) | wrapper only: `if pinned: gate(...) else: skip(...)` | ok / FAIL | `skip` (line 142) |
| `upgrade_quotes` (line 162) | for each of `UPGRADE_QUOTES`: must be in the squashed Upgrading section AND on a non-comment line of `codex/install-codex.sh` | `if pinned` | ok / FAIL | `skip` (line 166) |
| `not_run` (line 190) | `[ln.rstrip() for ln in sections.get("Not run", []) if ln.strip()] == NOT_RUN_LINES` | `if pinned` | ok / FAIL | `skip` (line 194) |
| `upgrade_install_page`, `changelog_*`, `readme_version`, `version_source`, `codex_version_single`, `claude_version_single` | structural, version-independent | no | ok / FAIL | ok / FAIL (unchanged) |

Note `upgrade_addressed` already interpolates `VERSION`, so making it generic (D-04) is only deleting the `if pinned`/`else skip` wrapper; no new logic is needed.

**Proposed shape** (stdlib, project style, `%`-formatting):
```python
pinned = VERSION == CONTENT_VERSION

def pinned_gate(name, ok, detail, constants):
    """A gate on the facts of CONTENT_VERSION: at any other version it FAILs and says what to re-pin."""
    if pinned:
        gate(name, ok, detail)
    else:
        gate(name, False, "version %s is not CONTENT_VERSION %s: write the facts of %s and re-pin %s"
             % (VERSION, CONTENT_VERSION, VERSION, constants))

# generic: every version
gate("upgrade_addressed", not missing,
     "Upgrading lacks %r" % (missing,) if missing else "addressee and both Claude Code commands present")
# pinned
pinned_gate("upgrade_quotes", not bad, "; ".join(bad) if bad else "%d quotes in Upgrading and on installer code lines" % len(UPGRADE_QUOTES),
            "CONTENT_VERSION and UPGRADE_QUOTES")
pinned_gate("not_run", not_run == NOT_RUN_LINES, ..., "CONTENT_VERSION and NOT_RUN_LINES")
```
`skip()` and the `skip(` calls disappear (remove the now-dead function). The module docstring (lines 1-26) currently ends its second paragraph with "…for any other version these three gates print skip instead of failing it" and must be rewritten to the D-04..D-07 policy plus a short "bumping the version" checklist: change `VERSION` in `tests/test_layout.py` (and the manifests, README, CHANGELOG heading), then set `CONTENT_VERSION`, `UPGRADE_QUOTES` and `NOT_RUN_LINES` to that release's facts. Keep the module docstring's shape: what it locks, how it is run, the output format.

**Mutation test impact** (`tests/test_release_text_mutation.sh`) [VERIFIED: read in full]:
- `release_mut_later_version` (lines 73-92) builds `root-later` at version 9.9.9 with the CHANGELOG addressee rewritten to `before 9.9.8` and the macOS Not-run line changed, and asserts `rc == 0`, no FAIL, and exactly three `^gate release_[a-z_]* skip ` lines (`[ "$(grep -c ... skip ")" = 3 ]`, gate message "three content gates skip"). Under the new policy this case is wrong on two counts: the generic `upgrade_addressed` now runs at 9.9.9 and the `9.9.8` addressee makes it FAIL; and the pinned gates FAIL instead of skipping. Rewrite it.
- Suggested cases (names keep the `release_mut_` prefix; they use the existing `fresh_root`):
  1. `release_mut_later_unpinned`: later version with its own correct addressee (`before 9.9.9`) but CONTENT_VERSION untouched: rc 1; `release_upgrade_addressed ok`; `release_upgrade_quotes FAIL` and `release_not_run FAIL` with the re-pin text in the detail; zero `skip` lines.
  2. `release_mut_later_repinned`: copy the gate script (`sed 's/^CONTENT_VERSION = ".*"$/CONTENT_VERSION = "9.9.9"/' "$GATE" > "$WORK/gate-repinned.py"`) and run it on the same later-version root: rc 0, no FAIL, zero skip lines (this is the Phase 10 situation; the gate takes its root from `argv[1]`, so a copy elsewhere works).
  3. `release_mut_later_addressee`: later version with the addressee left at `before 9.9.8`: `release_upgrade_addressed FAIL`.
  4. `release_mut_later_command`: later version with one of the two Claude Code commands altered in the Upgrading section only (the existing `mutate upgrade_addressed` sed on the CHANGELOG replaces every occurrence of the marketplace command, including the one in Upgrading, which is what is needed; run it on a later-version root): `release_upgrade_addressed FAIL`.
- The existing `mutate upgrade_addressed`, `upgrade_quotes` and `not_run` cases run at the current version and stay valid unchanged.
- `fresh_root` copies exactly the six files the gate reads (`README.md`, `CHANGELOG.md`, `docs/install-claude-code.md`, `docs/install-codex.md`, `tests/test_layout.py`, `codex/install-codex.sh`); no change needed.

**Phase 8/9 hazard to flag:** at `VERSION == CONTENT_VERSION` (0.2.0, through Phases 7-9), `upgrade_quotes` still requires the three quotes on non-comment lines of `codex/install-codex.sh`. They are at `codex/install-codex.sh:727` (`...left untouched; rerun with --force to replace it`), `:739` (`... (every update of it makes Codex ask for the /hooks review again)`) and `:780` (`... open /hooks, and approve the BBj check hook.`). Phase 8 (CODEX-06 may add installer wording) must keep those three strings or edit `UPGRADE_QUOTES` and the CHANGELOG entry together, otherwise the suite goes red before Phase 10. State this in the plan's notes.

**Phase 10 pre-note (Open Question 1 below):** the generic addressee for 0.2.1 is "If you installed from `main` before 0.2.1" per D-04; the CHANGELOG 0.2.1 Upgrading text must contain that sentence.

### Gate prefixes (MAINT-08): ground truth

Method (re-runnable, no second suite run needed if the transcript from the verification run is kept):
```sh
sh tests/run.sh > run.out
awk '/^== /{f=$2} /^gate /{n=$2; sub(/_.*/,"",n); c[f" "n]++} END{for(k in c) print k, c[k]}' run.out | sort
```
`sh tests/run.sh` at HEAD: `SUMMARY: ok=757 fail=0 skip=0`, 84 s, 757 gate lines [VERIFIED: ran]. Text before the first underscore, by file:

| File | Prefixes printed (count) |
|------|--------------------------|
| `test_check_order.py` | `checkorder_` (10) |
| `test_ci_gates.sh` | `ci_` (2), `run_` (2) |
| `test_ci_guards.py` | `ci_guard_` (11) |
| `test_exit_contract.sh` | `contract_` (62), `argument_` (15), `glob_newline_not_passed_` (3), `no_marker_` (4), `real_hostile_reached_compiler`/`contract_real_` (2) |
| `test_install_pages.sh` | `claude_` (46), `codex_` (45), `link_` (9), `readme_` (8), `installer_` (2) |
| `test_layout.py` | `layout_` (20) |
| `test_noroute_notice.sh` | `notice_` (57) |
| `test_release_text.py` | `release_` (11) |
| `test_release_text_mutation.sh` | `release_mut_` (14) |
| `test_skill_examples.py` | `skills_` (176) |
| `test_static_guards.sh` | `static_` (32) |
| `test_install_codex.sh` | free-form; largest families `local_` (25), `first_` (12), `probe_` (8), `with_`, `docs_`, `foreign_`, `existing_`, `managed_` |
| `test_claude_plugin.sh`, `test_codex_patch.sh`, `test_discovery.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`, `test_real_compiler.sh`, `test_tier2_fake.sh`, `test_tier2_live.sh` | free-form names (no shared prefix; `test_tier2_fake.sh` has `url_`, `req_`, `mode_`; `test_tier2_live.sh` has `live_`; `test_discovery.sh` has `order_`) |

**Where the list lives today** [VERIFIED: read]:
- `.planning/codebase/CONVENTIONS.md:126`: ``- Shell test gates use the prefix that matches the file: `contract_`, `argument_`, `no_marker_`, `static_`, `ci_guard_`, `layout_`, `skills_`.``
- `.claude/CLAUDE.md:183`: the identical line, inside the generated block `<!-- GSD:conventions-start source:CONVENTIONS.md -->` … `<!-- GSD:conventions-end -->` (lines 100 and 229). Edit CONVENTIONS.md first and mirror the identical text into CLAUDE.md; a later `/gsd-map-codebase` regeneration would overwrite the block from CONVENTIONS.md.
- Line 184/127 in the same sections says Python tests print `gate <prefix>_<name>`; keep.

What is wrong with the line: the claim "the prefix that matches the file" is false for eight test files, and the prefixes `notice_`, `local_`, `checkorder_`, `release_` (and `claude_`/`codex_`/`link_`/`readme_` of the install-page test, `ci_`) are missing. Also `ci_guard_`, `layout_`, `skills_` are Python-test prefixes listed under "Shell test gates". `skills_` stays (success criterion 3). Recommended wording: say that most files own one prefix and list them per file or per family, name the two new Phase 7 prefixes, and say that the remaining files use free-form names. Do this step after the two new tests exist so their prefixes are included.

**Optional sync gate (planner's discretion):** a Python test could statically read the documented prefixes from `.claude/CLAUDE.md` and check that each is the literal start of some `gate`/`gate(` name in `tests/*.sh|*.py` (one-direction typo guard, no suite rerun). Two cautions: (a) `.claude/CLAUDE.md` is tracked and ships with the branch, but `.planning/` is stripped from the PR branch by `/gsd-pr-branch`, so a gate must not read `.planning/codebase/CONVENTIONS.md`; (b) many gate names are built from variables (`"contract_$1_$2"`), so a reverse check (every printed prefix is documented) cannot be done statically. Recommendation: skip the gate; it is optional, the list is prose, and the file it would read is regenerated.

### Release tree (REL-05) and local `main` (D-02)

All run on this checkout [VERIFIED]:
```
git merge-base --is-ancestor b0a4c62 HEAD  -> yes     (WR-01 install page)
git merge-base --is-ancestor 3a42ebf HEAD  -> yes     (WR-02 content gates)
git merge-base --is-ancestor b600ac4 HEAD  -> yes     (IN-01 tested-with gate)
git merge-base --is-ancestor 172e6a5 HEAD  -> yes     (IN-02 --force wording)
git rev-parse main origin/main HEAD
  3c75f4f8a6c6bfb638fce2b327a5ea9cdc58c23b
  f15c257f6fba6e5d4cde60e49ad06727de44f68f
  993d8d08d709d1659de57598c3c030bcf686228d
git merge-base --is-ancestor origin/main HEAD -> yes  (HEAD contains the 0.2.0 merge f15c257)
git merge-base --is-ancestor main origin/main -> yes  (fast-forward possible)
git merge-base --is-ancestor <each of the four> origin/main -> no (they are on gsd/planning-setup only)
git fetch --dry-run . origin/main:main -> "3c75f4f..f15c257  origin/main -> main"  (nothing changed)
```
So D-01 and D-02's premises hold. REL-05's repo-side work is empty; the plan's task is the verification (the four ancestry checks plus the full suite, which passed at HEAD with `skip=0`). For D-02 use `git fetch . origin/main:main` (updates a branch that is not checked out, and git refuses a non-fast-forward there by default) rather than `git merge`/checkout, which would change the current branch; `git branch -f main origin/main` is the blunt equivalent. Do not run `git fetch origin` or push. [ASSUMED: that `git fetch . a:b` refuses a non-fast-forward; the dry-run above only shows the fast-forward case]. The branch `main` is not checked out in any worktree (`git worktree list` shows one worktree).

## Runtime State Inventory

Not a rename/refactor/migration phase. Omitted.

## Common Pitfalls

### Pitfall 1: Removing a shared PATH directory drops the tools the test needs
**What goes wrong:** `bbjcpl` symlinked into `/usr/local/bin` (or a Homebrew prefix on the owner's Mac) sits beside `python3`, `curl`, maybe `dash`/`bash`. A helper that deletes that directory from PATH leaves `notice_text` (needs `python3`) and `python3 -I tests/fake_mcp.py` unable to run, so the gates fail for a different reason.
**Why it happens:** D-11 as worded removes the directory; its own rationale ("other tools stay where they are") is only true for dedicated compiler directories.
**How to avoid:** per-directory symlink farm excluding the four compiler names (Pattern 1); unit-test the helper on a synthetic PATH holding one compiler-only directory, one shared directory and one clean one.
**Warning signs:** `command -v python3` empty after the scrub; `notice_text` returns 2.

### Pitfall 2: Glob switched off inside the helper
**What goes wrong:** the helper uses `set -f` so `for d in $PATH` cannot glob; the farm's `ln -s "$dir"/* ...` then links the literal string `*`.
**How to avoid:** `set +f` around the `ln` and `set -f` after, and restore `set +f` plus `IFS` at the end (done in the prototype; it was a real bug caught during prototyping).

### Pitfall 3: Empty and relative PATH entries
**What goes wrong:** an empty PATH entry (`::`, leading or trailing `:`) means the current directory. `for d in $PATH` with `IFS=:` drops trailing empties but not interior ones.
**How to avoid:** `[ -n "$d" ] || continue` (dropping the cwd entry is the safe choice for a "no compiler" PATH); the tests `cd` into temp directories only in a few places.

### Pitfall 4: Nested test output is counted by the runner
**What goes wrong:** `tests/run.sh` greps every line starting `gate ` in a test's output; a nested run (and especially the deliberately failing mutated one) echoed to stdout would turn the outer run red or double-count.
**How to avoid:** redirect nested runs to files under `$WORK`; report only the outer gates.

### Pitfall 5: The fake compiler gives "no result", not "clean"
**What goes wrong:** `tests/fake-bin/bbjcpl` prints nothing and exits 0, so the hook sees "compiler gave no verdict" and the wording becomes "bbjcpl found but gave no result" rather than "no bbjcpl found". A scrub that only half works shows up as FAILs in `notice_*` text gates, which is what the green gate needs; do not mistake those for unrelated breakage.
**How to avoid:** none needed; keep this in mind when reading nested-run failure output.

### Pitfall 6: `find`/`cksum`/`sort` variants and file names
**What goes wrong:** file names with newlines break line-based snapshots; locale-dependent `sort` reorders lines between the before and after runs; `find` output order is directory order.
**How to avoid:** `LC_ALL=C sort` on the whole snapshot (done), `IFS= read -r` for names (done). Skill directories hold plain names (with spaces handled in the prototype); a newline in a watched name is not a case worth handling, it would only produce a garbled but still self-consistent line. Missing watched directories are handled by the `[ -e ]` / `[ -L ]` test before `find` (a missing path makes `find` print an error and exit non-zero). Use `cksum < file` (stdin form) so the file name is not in cksum's output; GNU, uutils and busybox cksum all print `crc size` for stdin [VERIFIED for uutils]; BSD/macOS cksum has the same POSIX output [ASSUMED].

### Pitfall 7: Gate-count drift in `release_mut_later_version`
**What goes wrong:** leaving the old case in place keeps asserting `skip` count 3 and the `before 9.9.8` addressee, so the suite is red the moment the gates change.
**How to avoid:** rewrite as listed under Pattern 4 in the same commit as the gate change.

### Pitfall 8: Phase 8 rewording the installer quotes
See the hazard under "CONTENT_VERSION policy". The pinned `upgrade_quotes` gate ties three `codex/install-codex.sh` lines to the 0.2.0 CHANGELOG entry until Phase 10.

### Pitfall 9: A running Codex session rewrites `config.toml`
Accepted risk, see MAINT-07 above.

## Code Examples

The three validated helpers (Patterns 1 and 3) and the Python reshaping (Pattern 4 section) are the code examples. Two small ones for the new tests:

```sh
# tests/test_home_guard.sh sketch (prefix homeguard_): a fake home, a snapshot, one change, one verdict
. "$(dirname "$0")/lib.sh"
mkwork
C=$WORK/h/.codex
K=$WORK/h/.agents/skills
mkdir -p "$C/sessions" "$C/log" "$K/bbj-programming/references"
printf 'a = 1\n' > "$C/config.toml"
printf x > "$C/logs_2.sqlite"
printf s > "$K/bbj-programming/SKILL.md"
home_snapshot "$C" "$K" > "$WORK/before"

# expect_same NAME: the daemon-style changes already made leave the snapshot identical
# expect_diff NAME: a watched change makes it differ (the real gate would FAIL)
check() {   # check NAME same|differ
  home_snapshot "$C" "$K" > "$WORK/after"
  if cmp -s "$WORK/before" "$WORK/after"; then _res=same; else _res=differ; fi
  if [ "$_res" = "$2" ]; then gate "homeguard_$1" ok "$2"; else gate "homeguard_$1" FAIL "wanted $2, got $_res"; fi
}
printf zz >> "$C/logs_2.sqlite"; : > "$C/logs_2.sqlite-wal"; : > "$C/logs_2.sqlite-shm"
printf q > "$C/sessions/new.jsonl"; touch "$C/config.toml"
check daemon_files_ignored same
printf 'a = 2\n' > "$C/config.toml"
check config_edit_detected differ
```

```sh
# tests/test_path_scrub.sh sketch (prefix pathscrub_): the green run, output kept out of this test's stdout
mkdir "$WORK/cplbin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcpl"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcplw"
chmod 755 "$WORK/cplbin/bbjcpl" "$WORK/cplbin/bbjcplw"
for _t in test_noroute_notice.sh test_exit_contract.sh; do
  PATH=$WORK/cplbin:$PATH sh "$REPO/tests/$_t" > "$WORK/green.out" 2>&1
  _rc=$?
  _bad=$(grep -c '^gate [^ ]* FAIL ' "$WORK/green.out")
  if [ "$_rc" = 0 ] && [ "$_bad" = 0 ]; then gate "pathscrub_green_$_t" ok "..."; else gate "pathscrub_green_$_t" FAIL "rc $_rc, $_bad FAIL gates"; fi
done
```
(Gate names for the per-file loop should avoid the `.sh` dot; derive a short tag as `tests/test_install_pages.sh` does.)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `find -newer marker` over all of `~/.codex` and `~/.agents` | Allowlist snapshot of content checksums | this phase (MAINT-07) | Daemon files no longer fail the gate; mtime resolution and `sleep 1` no longer matter |
| Content gates `skip` at a non-CONTENT version | Generic gate always; pinned gates FAIL with a re-pin message | this phase (REL-06) | A version bump can't pass on stale facts, and `skip=0` stays reachable |

**Deprecated/outdated:** `: > "$WORK/marker"` + `sleep 1` in `tests/test_install_codex.sh`; `skip()` in `tests/test_release_text.py`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Under Git for Windows `sh`, `PATH` is colon-separated POSIX-style, so `IFS=:` splitting in `no_compiler_path` works on the Phase 9 Windows machine | Pattern 1 | The helper would mis-split drive-letter entries; Phase 9 would see no-route FAILs. Windows `tests/` runs are not part of Phase 7 verification; flag for the Phase 9 run |
| A2 | macOS (BSD) `cksum < file`, `find ... -print`, `ln -s dir/* dir2/` behave as on this host | Pitfall 6, Pattern 3 | The snapshot helper misbehaves on the owner's Mac; caught at Phase 9 |
| A3 | A compiler linked into a shared directory (`/usr/local/bin`, Homebrew prefix) next to `python3`/`curl` is a realistic install on the owner's machines | Summary, Pitfall 1 | If wrong, the farm is unneeded complexity, but harmless |
| A4 | `git fetch . origin/main:main` refuses a non-fast-forward update by default | Release tree | Wrong only if local `main` is not an ancestor, which was verified; low risk |
| A5 | A Codex session trusting a new project rewrites `~/.codex/config.toml` mid-run (inferred from the `[projects."..."] trust_level` entries and the file's mtime, not observed during a run) | MAINT-07 | The residual-risk note would be unnecessary |

## Open Questions

1. **Is "If you installed from `main` before 0.2.1" the right generic addressee for the 0.2.1 CHANGELOG?**
   - What we know: D-04 fixes the generic gate on that sentence; 0.2.0 users installed from a tag.
   - What's unclear: whether Phase 10's Upgrading text wants a different addressee for users of the 0.2.0 release.
   - Recommendation: keep D-04; Phase 10 writes a sentence containing the exact text (it can add a second sentence for 0.2.0 users).

2. **Should the shared-directory farm be implemented, or plain removal per the letter of D-11?**
   - What we know: plain removal fails for shared directories; the farm costs about 20 lines and is validated.
   - Recommendation: implement the farm (it satisfies D-11's stated intent); the planner can fall back to plain removal plus a loud failure if the farm proves awkward.

3. **Does the optional prefix-sync gate earn its place?**
   - Recommendation: no (see "Gate prefixes").

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `sh`/dash, bash, `busybox sh` | all shell tests, exit-contract per-shell runs | yes | bash 5.3.9, BusyBox 1.37.0 | gate `shell_*` skip |
| `python3` | Python tests, `notice_text`, fake MCP | yes | 3.14.4 | `python_tests` FAIL under `CI=true`, skip otherwise |
| `shellcheck` | `tests/ci.sh` lint of new `tests/*.sh` | yes | 0.11.0 | skip outside CI, FAIL in CI |
| `find`, `cksum`, `sort`, `cmp`, `diff`, `ln`, `mktemp` | snapshot, farm, mutation | yes | bfs 4.1.1 / uutils cksum 0.8.0 | none needed |
| `git` | REL-05 verification | yes | 2.55.0 | — |
| `claude` CLI | `tests/ci.sh` strict validation | yes (`<home>/.local/bin/claude`) | 2.1.296 | skip outside CI |
| `codex` | optional `real_codex_*` gates in `test_install_codex.sh` | yes (`<home>/.npm-global/bin/codex`) | codex-cli 0.162.1 | gate skip |
| `bbjcpl` / `bbjcplw` on PATH | none (tests use fakes) | no | — | fake in a scratch dir |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** a real `bbjcpl` (not needed). `bc` is not installed on this host (irrelevant to the tests; use `date +%s` arithmetic for timing).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Custom gate protocol: `gate NAME ok|FAIL|skip DETAIL` (shell via `tests/lib.sh`, Python per file), runner `tests/run.sh` |
| Config file | none (`.shellcheckrc` for lint) |
| Quick run command | `sh tests/test_<area>.sh` or `python3 -I tests/test_<area>.py` (single file) |
| Full suite command | `sh tests/run.sh` (about 84 s here; expect about 110 s after this phase), `sh tests/ci.sh` adds `claude plugin validate --strict` and `shellcheck -s sh` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MAINT-06 | Helper output on a synthetic PATH: compiler-only dir dropped/emptied, shared dir keeps its tools, empty entries dropped, clean dir unchanged | unit | `sh tests/test_path_scrub.sh` | Wave 0 (new) |
| MAINT-06 | Both no-route test files green with fake `bbjcpl`+`bbjcplw` first on PATH | integration (nested) | `sh tests/test_path_scrub.sh` | Wave 0 (new) |
| MAINT-06 | Same files FAIL when the helper is a no-op (scrub removal is caught) | mutation | `sh tests/test_path_scrub.sh` | Wave 0 (new) |
| MAINT-07 | Daemon-style files (`logs_2.sqlite`, `-wal`, `-shm`, `state_5.sqlite`, `history.jsonl`, `sessions/`, `log/`, `tmp/`) and a `touch` leave the snapshot identical | unit on fake home | `sh tests/test_home_guard.sh` | Wave 0 (new) |
| MAINT-07 | `config.toml` edit, `config.toml.bbj-backup`/`hooks.json` created, `~/.codex/bbj/` created, skill file changed, skill dir appeared/removed each change the snapshot | unit on fake home | `sh tests/test_home_guard.sh` | Wave 0 (new) |
| MAINT-07 | `test_install_codex.sh` uses the helper, has no `find -newer` against the real homes | static grep gate | `sh tests/test_home_guard.sh` | Wave 0 (new) |
| MAINT-07 | The real gate still passes on a quiet real home | integration | `sh tests/test_install_codex.sh` (31 s) | exists |
| MAINT-08 | Documented prefixes equal what the suite prints | manual diff of the awk transcript against CONVENTIONS.md and CLAUDE.md lines | `sh tests/run.sh > out; awk ... out` | doc check (no file) |
| REL-05 | Four commits are ancestors; full suite green | verification commands | `git merge-base --is-ancestor <sha> HEAD` x4; `sh tests/run.sh` | n/a (D-03) |
| REL-06 | Generic gate runs at any version; pinned gates FAIL at a mismatch; re-pinned later version passes with skip=0 | mutation | `sh tests/test_release_text_mutation.sh` | exists, to be extended |
| REL-06 | Docstring and PROJECT.md row record the policy | grep check | `grep -n 'CONTENT_VERSION' tests/test_release_text.py .planning/PROJECT.md` | n/a |

### Sampling Rate
- **Per task commit:** the single test file touched (`sh tests/test_<area>.sh`, 1-31 s) and `shellcheck -s sh tests/<file>.sh`.
- **Per wave merge:** `sh tests/run.sh`.
- **Phase gate:** `sh tests/run.sh` green with `skip=0` (the baseline was `ok=757 fail=0 skip=0`), plus the same run with a fake `bbjcpl`/`bbjcplw` first on PATH (`PATH=<scratch>:$PATH sh tests/run.sh`) as a one-off confirmation of success criterion 1, and the four `merge-base` checks.

### Wave 0 Gaps
- [ ] `tests/test_path_scrub.sh` — covers MAINT-06 (D-13)
- [ ] `tests/test_home_guard.sh` — covers MAINT-07 (D-10)
- [ ] helpers in `tests/lib.sh` (`no_compiler_path`, `no_compiler_env`, `home_snapshot`, a compare helper) and their entries in its header comment
- [ ] extended cases in `tests/test_release_text_mutation.sh` — covers REL-06
No framework install is needed.

## Security Domain

`security_enforcement` is enabled in `.planning/config.json` (level 1, block on high). This phase changes test code and docs only; nothing is shipped to users and no network is touched.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — (the real-home gate is read-only: `find`, `cksum`, `sort`) |
| V5 Input Validation | yes (shell hygiene) | quote every expansion; file names reach tools as single arguments; never `eval`/source test data; `IFS= read -r`; `set -f` while splitting `PATH` |
| V6 Cryptography | no | `cksum` is change detection, not integrity protection; no secret material is read (the real `~/.codex/auth.json` and `.credentials.json` are outside the allowlist and never opened) |

### Known Threat Patterns for POSIX-sh test code

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Test writes into the user's real home | Tampering | Snapshot reads only; installer runs against `$WORK` homes (existing `newenv`); the new helpers never write outside `$WORK` |
| Symlink farm or temp dir escapes `$WORK` | Tampering | `mktemp -d "$WORK/pathfarm.XXXXXX"`; farm contains symlinks only; removed with `$WORK` by the `mkwork` trap |
| Hostile file name in a watched skill directory executed | Elevation | Names only ever appear as quoted arguments and `printf '%s'` arguments, never in a format string or `eval` |
| Test reads a real credential file | Information disclosure | Allowlist contains no credential path; `home_snapshot` opens only files under the six allowlisted paths |
| Nested run leaks fake-compiler env into later gates | Tampering (test integrity) | Per-command `PATH=... sh test` assignment, not an exported change of the outer shell |

## Sources

### Primary (HIGH confidence): files read or run in this checkout
- `tests/lib.sh`, `tests/run.sh`, `tests/ci.sh`, `tests/fake-bin/bbjcpl`
- `tests/test_noroute_notice.sh`, `tests/test_exit_contract.sh`, `tests/test_install_codex.sh` (header, lines 1-110, 1480-1521), `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `tests/test_ci_gates.sh`, `tests/test_discovery.sh` (header), `tests/test_never_execute.sh` (header), `tests/test_layout.py` (scan rules)
- `plugins/bbj/scripts/bbj-check.sh` (header and `discover`, `find_cpl_in_home`, `find_cpl_on_path`)
- `codex/install-codex.sh` (header and write steps)
- `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/TESTING.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/PROJECT.md`, `.planning/STATE.md`, `.github/workflows/ci.yml`, `.shellcheckrc`
- Runs: `sh tests/run.sh` (757 ok, 0 fail, 0 skip, 84 s); every test file run on its own with a fake `bbjcpl`+`bbjcplw` first on PATH; scratch-copy patch with the scrub helper and the stubbed-helper mutation; snapshot/compare prototype under dash, bash and busybox sh; `git merge-base --is-ancestor`, `git rev-parse`, `git fetch --dry-run . origin/main:main`
- Scratch artifacts (not in the repo): `/tmp/claude-1000/-home-coder-repos-bbj-agent-plugins/7fb6f75c-7b06-4e92-8d6d-b1c1f394746d/scratchpad/` (`proto/h_lib.sh`, `proto/snap_lib.sh`, `repocopy/`, run transcripts)

### Secondary / Tertiary
- None. No web sources were needed; the research-plan / provider seam was not used because every question is answered by the local code.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, the stack is the repo's fixed POSIX sh + Python stdlib; tool behavior verified by running.
- Architecture: HIGH, helpers were prototyped and the D-13 behavior reproduced.
- Pitfalls: HIGH for 1, 2, 4, 7, 8 (hit or measured); MEDIUM for 6 (non-Linux `cksum`/`find`) and 9 (inferred, not observed).

**Research date:** 2026-10-12
**Valid until:** 2026-11-11 (stable; invalidated early only by edits to `tests/lib.sh`, `tests/test_release_text.py`, `codex/install-codex.sh` or `bbj-check.sh discover()` in Phases 8-9)
