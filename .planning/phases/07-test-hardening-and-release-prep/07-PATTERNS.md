# Phase 7: Test hardening and release prep - Pattern Map

**Mapped:** 2026-10-12
**Files analyzed:** 11 (2 new, 9 modified)
**Analogs found:** 11 / 11

All analogs are git-tracked (`tests/*`, `tests/fake-bin/*` confirmed via `git ls-files`). Nothing here runs BBj. Line numbers are from this checkout. The validated helper prototypes are in 07-RESEARCH.md Patterns 1 and 3 (lines 237-348); copy them verbatim.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `tests/test_path_scrub.sh` (new) | test (mutation proof) | batch (nested runs) | `tests/test_release_text_mutation.sh` | exact |
| `tests/test_home_guard.sh` (new) | test (both-direction proof) | file-I/O (snapshot) | `tests/test_release_text_mutation.sh` + fake-home idiom `newenv` in `tests/test_install_codex.sh:52-61` | role-match |
| `tests/lib.sh` | utility | transform | itself (`fresh_state`, `notice_text`) | exact |
| `tests/test_noroute_notice.sh` | test | request-response | itself, lines 14-22, 568-578 | exact |
| `tests/test_exit_contract.sh` | test | request-response | itself, lines 90-108 | exact |
| `tests/test_install_codex.sh` | test | file-I/O | itself, lines 28-30 and 1519-1521 | exact |
| `tests/test_release_text.py` | test (gate script) | transform | itself, lines 125-200 | exact |
| `tests/test_release_text_mutation.sh` | test | batch | itself, lines 26-92 | exact |
| `.planning/codebase/CONVENTIONS.md` | doc/config | n/a | its line 126 | exact |
| `.claude/CLAUDE.md` | doc (generated copy) | n/a | its line 183, inside `GSD:conventions` block | exact |
| `.planning/PROJECT.md` | doc | n/a | existing Key Decisions table (read it for the row format) | exact |

## Pattern Assignments

### `tests/test_path_scrub.sh` (new, test, batch)

**Analog:** `tests/test_release_text_mutation.sh`

**Header and setup** (lines 1-24):
```sh
#!/bin/sh
# tests/test_release_text_mutation.sh -- ... proves that every gate of ... can fail.
# ... Nothing here runs BBj; the only program run is python3 -I on the gate script.

. "$(dirname "$0")/lib.sh"
mkwork

if ! command -v python3 > /dev/null 2>&1; then
  gate release_mut_python skip "python3 not found"
  finish
fi
```
New file: same comment shape (scope, MAINT-06, D-11..D-13, "Nothing here runs BBj"). Prefix `pathscrub_`. Needs no python3.

**Nested-run + rc + grep idiom** (lines 44-50, 85-92):
```sh
python3 -I "$GATE" "$_root" > "$WORK/out" 2> "$WORK/err"
_rc=$?
if [ "$_rc" = 1 ] && grep -q "^gate release_$1 FAIL " "$WORK/out"; then
  gate "release_mut_$1" ok "..."
else
  gate "release_mut_$1" FAIL "rc=$_rc, no FAIL line for release_$1"
fi
```
Adapt:
- Run `sh "$REPO/tests/test_noroute_notice.sh"` and `test_exit_contract.sh` with `PATH=$WORK/cplbin:$PATH`. Always redirect to files under `$WORK`. `run.sh` counts every `^gate ` line on stdout, so never echo nested output.
- Green gate: rc 0 and zero `^gate .* FAIL ` lines.
- Mutation gate: `cp -R "$REPO/tests" "$WORK/mut/tests"`, append `no_compiler_path() { printf '%s' "${1-$PATH}"; }` to the copy's `lib.sh`, export `SCRIPT="$REPO/plugins/bbj/scripts/bbj-check.sh"`, and expect rc 1 with FAIL gates (35 and 6 per research).
- Fake compiler dir: `mkdir "$WORK/cplbin"; cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/cplbin/bbjcpl"; cp ... "$WORK/cplbin/bbjcplw"; chmod 755`. Do not put `fake-bin` itself on PATH (it also holds fake curl, bbj, codex, cygpath).
- Clear `FAKE_LOG FAKE_OUT FAKE_STDOUT FAKE_EXIT FAKE_CURL_EXIT` before the nested runs.
- Unit gates on the helper: synthetic PATH with a dir holding `bbjcpl` plus another tool. Assert the tool survives through the farm and the compiler is gone.

**PATH save/restore idiom** (from `tests/test_tier2_fake.sh:21-22`, `test_exit_contract.sh:93-107`):
```sh
ORIGPATH=$PATH
...
_savepath=$PATH
PATH=$(no_compiler_path)
...
PATH=$_savepath
```

---

### `tests/test_home_guard.sh` (new, test, file-I/O)

**Analog:** `tests/test_release_text_mutation.sh` (both-direction shape: unchanged passes, each mutation fails) plus the fake-home layout from `tests/test_install_codex.sh:52-61`:
```sh
newenv() {
  E_ROOT=$WORK/$1
  E_HOME=$E_ROOT/home
  E_CODEX=$E_HOME/.codex
  E_SKILLS=$E_HOME/.agents/skills
  mkdir -p "$E_HOME"
}
```
Prefix `homeguard_`. Source `lib.sh`, `mkwork`, build a fake home under `$WORK`, then:
- Take a snapshot with `home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/before"`.
- Apply the daemon-file changes: grow `logs_2.sqlite`, create `-wal` and `-shm`, `state_5.sqlite`, `history.jsonl`, `sessions/x`, `tmp/`, and `touch` on `config.toml` and a skill file. Snapshot again and require it to be identical (`cmp -s`).
- Apply each change that must be caught, one per case, restoring after each: edit `config.toml`, create `hooks.json`, change a file in `bbj-programming/references/` (use a name with a space), create `bbj/bbj-check.sh`, and add or remove a skill dir. Each must differ.
- Use the `home_snapshot` and `home_diff` bodies from RESEARCH.md lines 321-348.

---

### `tests/lib.sh` (utility, modified)

**Analog:** existing helpers, lines 70-77 (`fresh_state`) for style: underscore temps, `exit 1` on setup failure, usage comment above each function.

Add after `fresh_state`:
- `no_compiler_path` and `no_compiler_env`. Copy the bodies from RESEARCH.md lines 248-283. Use `_ncp_` prefixes, `set -f` and `set +f` around the PATH loop, and a symlink farm under `$WORK/pathfarm.XXXXXX`.
- `home_snapshot` and `home_diff` (RESEARCH.md lines 325-348). `home_diff` is `diff "$1" "$2" | head -n 3` plus a `cmp -s` return status. Put the accepted-risk note on `config.toml` in the helper's comment: Codex rewrites it on trusting a project, so do not open Codex in a new project during the run.

Update the header "Provides:" comment (lines 6-27) with the four new names. Do not touch `mkwork` (D-12). Keep the file free of the vendoring wording that `tests/test_layout.py:157-170` forbids.

---

### `tests/test_noroute_notice.sh` (modified)

**Current** (lines 14-22):
```sh
. "$(dirname "$0")/lib.sh"
mkwork
...
SYSPATH=/usr/bin:/bin
ORIGPATH=$PATH
```
**Change:** add `PATH=$(no_compiler_path)` right after `mkwork` (line 15). `ORIGPATH=$PATH` on line 22 then captures the scrubbed value. Optional hardening: `SYSPATH=$(no_compiler_path /usr/bin:/bin)` (a compiler linked into `/usr/bin` would otherwise leak into `CURLPATH=$WORK/curlbin:$SYSPATH`, line 577). Gates that set `BBJ_HOME` on purpose are unaffected because `BBJ_HOME` is tried before PATH.

---

### `tests/test_exit_contract.sh` (modified)

**Current** (lines 93-107):
```sh
  _savehome=$BBJ_HOME
  unset BBJ_HOME
  fresh_state
  run_check ...
  ...
  BBJ_HOME=$_savehome
  export BBJ_HOME
```
**Change:** add `_savepath=$PATH` and `PATH=$(no_compiler_path)` next to `_savehome=` and `unset BBJ_HOME`, and `PATH=$_savepath` before `BBJ_HOME=$_savehome`. Optionally call `no_compiler_env` directly, not through `$(...)`. This fixes the 6 `contract_{dash,bash,busybox}_{no_route,codex_no_route}` gates. Note this block runs under each shell in turn, so confirm the call sits inside the per-shell code path.

---

### `tests/test_install_codex.sh` (modified)

**Current** (lines 28-30 and 1519-1521):
```sh
REALHOME=${HOME:-/nonexistent}
: > "$WORK/marker"
sleep 1
...
touched=$(find "$REALHOME/.codex" "$REALHOME/.agents" -newer "$WORK/marker" 2> /dev/null | head -n 3)
[ -z "$touched" ] && gate real_home_untouched ok "..." || gate real_home_untouched FAIL "changed: $touched"
```
**Change:** keep `REALHOME`. Replace the marker and sleep lines with `home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.before"`. Replace the final check with a second snapshot to `$WORK/home.after`, then `home_diff` and the same two-way `gate real_home_untouched ok|FAIL` format. Add no new cases to this file (D-10).

---

### `tests/test_release_text.py` (modified)

**Analog:** itself. Current wrappers are at lines 130-194: `pinned = VERSION == CONTENT_VERSION`, with `if pinned: gate(...) else: skip(...)` on `upgrade_addressed`, `upgrade_quotes` and `not_run`.

**Change:**
- Delete the `pinned` wrapper around `upgrade_addressed`. It becomes a plain `gate(...)` call.
- Add `pinned_gate(name, ok, detail, constants)` as in RESEARCH.md lines 464-470. At a mismatch it calls `gate(name, False, "version %s is not CONTENT_VERSION %s: write the facts of %s and re-pin %s" % ...)`.
- Route `upgrade_quotes` and `not_run` through `pinned_gate`.
- Remove the now-dead `skip()` function.
- Rewrite the module docstring (lines 1-26) to the D-04..D-07 policy plus a bump checklist: `VERSION` in `tests/test_layout.py`, manifests, README, CHANGELOG heading, then `CONTENT_VERSION`, `UPGRADE_QUOTES`, `NOT_RUN_LINES`.
- Keep values at 0.2.0 (D-06).
- Style: 4-space indent, double quotes, `%`-formatting, no f-strings.

**Hazard:** `upgrade_quotes` requires three strings on non-comment lines of `codex/install-codex.sh` (about lines 727, 739, 780). Phases 8 and 9 must keep them or edit `UPGRADE_QUOTES` and the CHANGELOG together.

---

### `tests/test_release_text_mutation.sh` (modified)

**Analog:** itself, `fresh_root` (lines 27-33), `mutate` (lines 36-51), and the `release_mut_later_version` case (lines 74-92), which asserts the old skip behavior (exactly 3 `skip` lines) and must be rewritten. The header comment lines 10-11 also describe it.

**Replace with the four cases** (RESEARCH.md lines 485-488), using the same `fresh_root` and `sed` mutation steps as lines 76-84:
1. `release_mut_later_unpinned`: later version with addressee `before 9.9.9`, CONTENT_VERSION untouched. Expect rc 1, `release_upgrade_addressed ok`, `release_upgrade_quotes FAIL` and `release_not_run FAIL` with the re-pin text, and zero skip lines.
2. `release_mut_later_repinned`: `sed 's/^CONTENT_VERSION = ".*"$/CONTENT_VERSION = "9.9.9"/' "$GATE" > "$WORK/gate-repinned.py"` and run it on the later root. Expect rc 0, no FAIL, zero skips.
3. `release_mut_later_addressee`: addressee left at `before 9.9.8`, expect `release_upgrade_addressed FAIL`.
4. `release_mut_later_command`: later root plus the marketplace-command `sed` from line 101, expect `release_upgrade_addressed FAIL`.

Existing `mutate` cases stay unchanged. Keep nested output in `$WORK/out`.

---

### `.planning/codebase/CONVENTIONS.md` then `.claude/CLAUDE.md` (docs)

**Current line** (CONVENTIONS.md:126, mirrored at CLAUDE.md:183 inside `<!-- GSD:conventions-start source:CONVENTIONS.md -->`):
```
- Shell test gates use the prefix that matches the file: `contract_`, `argument_`, `no_marker_`, `static_`, `ci_guard_`, `layout_`, `skills_`.
```
**Change:** edit CONVENTIONS.md first, then mirror the identical text into CLAUDE.md. Do this last, so the new `pathscrub_` and `homeguard_` prefixes are included. Reword away the false claim "matches the file". Use the ground truth in RESEARCH.md lines 505-519 (`notice_`, `release_`, `release_mut_`, `checkorder_`, `ci_`, `claude_`/`codex_`/`link_`/`readme_`, `local_`, ...). Move the Python prefixes (`ci_guard_`, `layout_`, `skills_`, `checkorder_`, `release_`) out of "Shell test gates". Keep `skills_`. Say that the remaining files use free-form names. Skip the optional sync gate (RESEARCH recommends it, because `.planning/` is stripped from the PR branch).

### `.planning/PROJECT.md` (docs)

Add one row to the Key Decisions table in the table's existing column format (read the table first). Content: the CONTENT_VERSION policy (generic gates run for every version; fact gates fail at a mismatch with a re-pin message; reverses the skip half of WR-02), per D-07.

## Shared Patterns

### Test file skeleton
**Source:** `tests/test_release_text_mutation.sh:14-15`. Apply to both new tests.
```sh
. "$(dirname "$0")/lib.sh"
mkwork
...
finish
```
Header comment: file name, scope, decision IDs (MAINT-06, D-11..D-13 or MAINT-07, D-08..D-10), "Nothing here runs BBj". POSIX `sh`, no `local`, underscore temps, `[ ]` tests, `> /dev/null` with the space. Must pass `shellcheck -s sh`.

### Gate output and nested runs
**Source:** `tests/lib.sh:47-54`. `gate NAME ok|FAIL|skip DETAIL`. `run.sh` counts `^gate ` lines, so nested runs write only to `$WORK/*` files. Under `CI=true` a missing prerequisite is FAIL, not skip.

### Global restore
**Source:** `tests/test_exit_contract.sh:93-107`. Save `_savepath` and `_savehome`, restore after the block. Do not call `no_compiler_env` through `$(...)`, because a subshell loses the change.

### Self-scan avoidance
**Source:** `tests/test_release_text_mutation.sh:65` (`'unre%s' "leased"`). Assemble forbidden words from pieces. New files must not contain the vendoring wording that `tests/test_layout.py:157-170` scans for.

## No Analog Found

None. The symlink-farm helper has precedent in `$WORK/farm` (`tests/test_install_codex.sh:57-61`, `tests/test_ci_gates.sh:9-14`) but the per-directory farm is new logic. Use the validated prototype from RESEARCH.md.

## Metadata

**Analog search scope:** `/home/coder/repos/bbj-agent-plugins/tests/`, `tests/fake-bin/`
**Files read:** `lib.sh`, `test_release_text_mutation.sh`, slices of `test_install_codex.sh`, `test_tier2_fake.sh`, `test_exit_contract.sh`, `test_noroute_notice.sh`, `test_release_text.py`, plus CONTEXT.md and RESEARCH.md lines 1-546 (the rest of RESEARCH.md was not needed for pattern mapping)
**Pattern extraction date:** 2026-10-12
