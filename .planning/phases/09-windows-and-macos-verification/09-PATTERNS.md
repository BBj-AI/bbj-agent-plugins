# Phase 9: Windows and macOS verification - Pattern Map

**Mapped:** 2026-10-13
**Files analyzed:** 9 (new or modified)
**Analogs found:** 9 / 9 (all analog paths are git-tracked; checked `tests/lib.sh`, `tests/fake-bin/cygpath`, phase 08 files)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh` | utility (owner-run driver, not CI) | request-response (payload in, `key: value` block out) | `.planning/phases/08-codex-plugin-route/linux-run/run.sh` + `tests/lib.sh` builders | role-match |
| `.../platform-run/` runbook steps (in PLAN.md or the records) | doc / runbook | batch (numbered owner steps) | `.planning/phases/08-codex-plugin-route/linux-run/owner.sh` header + `08-05-PLAN.md` Task 3 | role-match |
| `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` | doc (evidence record) | file-I/O | `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` | exact |
| `tests/fake-bin/cygpath` (add `FAKE_CYGDRIVE_ROOT` seam) | test fake | transform | itself (7 lines) | exact |
| `tests/test_discovery.sh` (new `windows_*` gates) | test | request-response | its own Windows-branch block, lines ~158-175, and `mkhome` (14-18) | exact |
| `plugins/bbj/hooks/hooks.json` (`commandWindows`, only if D-11 decision table says so) | config | n/a | same file; pinned by `tests/test_layout.py` 166-179 | exact |
| `tests/test_layout.py` (`hook_command_windows` gate, only if shipped) | test | request-response | `hook_command` / `hook_timeout` gates, lines 166-179 | exact |
| `plugins/bbj/scripts/bbj-check.sh` `codex_patch` (backslash and `\\?\` handling, only if smoke shows Pitfall 2) | utility | transform | `codex_patch` lines ~590-615 | exact (self) |
| `tests/test_codex_patch.sh` (gate for the above) | test | request-response | its existing payload cases, `codex_payload` in `tests/lib.sh` 141 | exact |

## Pattern Assignments

### `platform-run/smoke.sh` (utility, request-response)

**Analog:** `.planning/phases/08-codex-plugin-route/linux-run/run.sh` (header and idiom), `tests/lib.sh` (builders). RESEARCH.md Pattern 2 and 3 hold a prototyped skeleton; copy it, do not re-derive it.

**Header comment** (run.sh 1-24): file path, one-line purpose, plan ID, safety rules ("never runs BBj", "never CI"), `Usage: sh smoke.sh SUBCOMMAND`, exit codes. Mirror this shape.

**Sourcing lib.sh** (`tests/lib.sh` 44-53): sourcing clears `BBJ_HOME`, `BBJHOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, empties `BBJ_CHECK_DEFAULT_HOMES`, and sets `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`. So:
```sh
KEEP_HOME=${CLAUDE_PLUGIN_OPTION_BBJ_HOME:-${BBJ_HOME:-}}   # read BEFORE sourcing
SCRIPT=${SMOKE_ROOT:-$CHECKOUT/plugins/bbj}/scripts/bbj-check.sh   # lib.sh keeps a preset SCRIPT
. "$CHECKOUT/tests/lib.sh"
mkwork
```
Set every variable per case afterwards; `tier2` must set `BBJ_LOCAL_MCP_URL=http://127.0.0.1:5009/mcp` explicitly.

**Payload and run helpers** (`tests/lib.sh` 123-155): `claude_payload TOOL FILE CWD`, `codex_payload CWD PATCH_TEXT`, `run_check PAYLOAD` (sets `RC`, `$WORK/stdout`, `$WORK/stderr`, `$WORK/payload`). Paths go through `json_escape` already (backslashes safe).

**Output idiom:** `kv() { printf '%s: %s\n' "$1" "$2"; }`, scrub through an awk that reads paths from `ENVIRON` (never `awk -v`, which interprets `\U`). Fixtures: bad `print "a"   rem same line`, clean `print "a"; rem ok` (`tests/test_real_compiler.sh` 17-18).

**Rules:** POSIX only, no `local`, underscore temps, `printf`, `command -v`. Not shellchecked (`tests/ci.sh` 81-83 scans `plugins/bbj/scripts`, `codex/`, `tests/*.sh` only), not in `tests/`. No `set -e`. Writes only under `mkwork`.

**Compiler argv capture:** second run `PS4='+TRACE ' $SHELL_UNDER_TEST -x "$SCRIPT" < "$WORK/payload"` then `grep -e ' -t -N -X'`; print the raw line.

**Tier 2 / no-route:** `no_compiler_path` and `no_compiler_env` (`tests/lib.sh` 156-222); check its return code (uses `ln -s`, Pitfall 8). Use `fresh_state` (lib.sh 83) for the notice claim.

---

### `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` (evidence record, file-I/O)

**Analog:** `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md`. Section skeleton to copy:
- Title `# Phase 9: Windows run record` and an intro stating what was run, where raw outputs stay, and what `<home>` / `<checkout>` mean (lines 1-8).
- `## Run environment` table, `| Item | Value |` rows (lines 10-20): OS, Git for Windows, Claude Code, Codex CLI, BBj, checkout commit, date.
- One `##` per route (as `## Plugin route: hook after apply_patch`, `## bbj-local opt-in`, `## Plugin route: no-route notice`): result block, client feedback lines, `Sentence for the docs`, and a verdict line `PLAT-0N: met | not run (reason) | defect, fixed in <commit>, re-run met | known gap (reason)` (D-08).
- Windows only: a section answering the three spike 005 unknowns, one line each.
- A re-run adds a second dated reading under the same section (D-09).

---

### `tests/fake-bin/cygpath` (test fake, transform)

**Analog:** itself (current content: `-u` echoes, `-w` prefixes `W:`). Replace with the verified prototype in RESEARCH.md Pattern 1 (lines 293-307): `-u` maps `[A-Za-z]:[\\/]*` below `$FAKE_CYGDRIVE_ROOT` only when set, otherwise unchanged. Backward compatible; `tests/test_install_codex.sh` copies the fake (line 47) and only asserts `-w` output (546). Add `-d` only if an installer fix needs it.

---

### `tests/test_discovery.sh` (test, request-response)

**Analog:** its own Windows block (ends the file, before `finish`).

**Helper to reuse** (lines 14-18, 27-30):
```sh
mkhome() {
  mkdir -p "$WORK/$1/bin"
  cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/$1/bin/${2:-bbjcpl}"
  chmod 755 "$WORK/$1/bin/${2:-bbjcpl}"
}
go() { : > "$FAKE_LOG"; run_check "$(claude_payload Write "$WORK/proj/sub/f.bbj" "$WORK/proj")"; }
```

**Existing gate shape to copy** (windows block):
```sh
mkdir -p "$WORK/winbin"
cp "$REPO/tests/fake-bin/cygpath" "$WORK/winbin/cygpath"; chmod 755 "$WORK/winbin/cygpath"
PATH=$WORK/winbin:$BASEPATH
...
_p=$(grep '^-P' "$FAKE_LOG" | tail -n 1)
_t=$(awk '/^CALL$/ { na = 0; next } /^ARG0 / { print a[na]; next } { a[++na] = $0 }' "$FAKE_LOG" | tail -n 1)
case "$_p" in
  "-PW:$WORK/proj/sub;W:$WORK/proj") gate windows_p_list ok "$_p" ;;
  *) gate windows_p_list FAIL "$_p" ;;
esac
```
New gates extend the `windows_` family (names suggested in RESEARCH: `windows_drive_home`, `windows_drive_file`, `windows_space_p_list`, `windows_forward_slash_file`). Set `FAKE_CYGDRIVE_ROOT=$WORK/drive`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME='C:\bbx'`, copy the fake compiler to `$WORK/drive/bbx/bin/bbjcpl.exe` via `mkhome`-style `cp`, then `claude_payload Write 'C:\Users\x\bbj test\sub\f.bbj' 'C:\Users\x\bbj test'`. Unset `FAKE_CYGDRIVE_ROOT` and restore `PATH` afterwards (lib convention). A fake compiler line must contain `: error` to count as a verdict.

---

### `plugins/bbj/hooks/hooks.json` + `tests/test_layout.py` (config / test; conditional on D-11)

**Analog gate** (`tests/test_layout.py` 166-179): `hook_matcher`, `hook_command` compares `hook_list[0].get("command") == HOOK_COMMAND`, `hook_timeout`, `hook_events_only_post_tool_use`. A `commandWindows` gate follows the same `gate("hook_command_windows", len(hook_list) == 1 and hook_list[0].get("commandWindows") == EXPECTED, "hooks=%r" % (hook_list,))` form. Python style: 4-space, `%`-formatting, no f-strings. The Phase 8 D-14 plugin-route gate parses this file and must keep passing. Costly: changes the Codex hook hash (re-trust); pinned text in `tests/test_install_pages.sh:193` and `tests/test_release_text.py:55` must stay untouched.

---

### `plugins/bbj/scripts/bbj-check.sh` `codex_patch` + `tests/test_codex_patch.sh` (conditional on Pitfall 2)

**Existing code** (`bbj-check.sh` ~590-615):
```sh
case "$_p" in
  [A-Za-z]:*) if [ "$WIN" = 1 ]; then _p=$(cygpath -u "$_p"); fi ;;
esac
case "$_p" in
  /*) case "$_p" in "$base"/*) ;; *) continue ;; esac ;;
  *) _p=$base/$_p ;;
esac
```
Fix shape: convert `\` to `/` (via `tr`) and strip a leading `\\?\` BEFORE the `..` containment check. Constraints: static guard (`tests/test_static_guards.sh` 59-70) forbids `eval`, `[[ `, `sed -i`, `grep -P`, `readlink -f`, `jq`, `python`, `node`, `timeout`; no `set -e`; exit contract stays 0 or 2, empty stdout. Gate it with `codex_payload` plus the extended fake in `tests/test_codex_patch.sh` (gate names free-form there, prefix `plugin_route_` is taken for other cases).

---

### Human checkpoints in PLAN.md

**Analog:** `08-05-PLAN.md` Task 3 (one blocking checkpoint gathering what only a person can do, fixed reply format) and `08-08-PLAN.md` Task 1 (`<task type="checkpoint:decision" gate="blocking-human">`, no `auto_select`, `<cons>Consequence: ...</cons>` per option, text quoting the owner's reply verbatim in the record). Use per platform: one `checkpoint:human-action` (runbook W0-W9 / macOS subset, reply format) then one `checkpoint:decision` (fix versus known gap, D-10), with the decision table of RESEARCH Pitfall 1 encoded as options.

## Shared Patterns

### Gate output and test library
**Source:** `tests/lib.sh` (`gate`, `finish`, `mkwork`, `run_check`). Every shell test begins `. "$(dirname "$0")/lib.sh"` then `mkwork`; ends with `finish`. Gate lines `gate NAME ok|FAIL|skip DETAIL`.

### Placeholders in records
**Source:** `08-LINUX-RUN.md` lines 1-8 and D-07: `<home>`, `<checkout>`, BBj home kept as written, no transcripts (D-06).

### Untouchable contracts (every shipped-file change)
Exit 0 or 2, stdout only for the notice JSON (`tests/test_exit_contract.sh`); `-N` on every compiler call; loopback-only `curl` with `--noproxy '*'` and `--proto =http` (`tests/test_static_guards.sh`, `tests/test_never_execute.sh`). Linux suite `sh tests/run.sh` must be green before any re-run is requested (baseline `ok=904 fail=0 skip=0`).

### Commit style
`test(09-01): ...`, `fix(09-03): ...`, `docs(09-02): ...`.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| PowerShell probes of the runbook (W5: `Get-Command sh`, `pwsh -Command ... $LASTEXITCODE`) | runbook step | request-response | Nothing in the repo runs PowerShell; use RESEARCH Pitfall 1 readings |
| `hooks_list.py` on Windows | utility | pub-sub | The analog uses `select` on pipes, which fails on Windows; use the `/hooks` TUI pasted by the owner |

## Metadata

**Analog search scope:** `tests/`, `tests/fake-bin/`, `plugins/bbj/scripts/`, `plugins/bbj/hooks/`, `.planning/phases/08-codex-plugin-route/`
**Files scanned:** about 12 read (partly by excerpt); RESEARCH.md read to line 449 of 718 (later sections, Open Questions and Validation Architecture, not consumed here)
**Pattern extraction date:** 2026-10-13
