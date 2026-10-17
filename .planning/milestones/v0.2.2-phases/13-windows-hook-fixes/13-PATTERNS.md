# Phase 13: Windows hook fixes - Pattern Map

**Mapped:** 2026-10-15
**Files analyzed:** 11 (1 new test, 1 optional new test, 9 modified; plus 13-WINDOWS-RUN.md)
**Analogs found:** 11 / 11
All analog paths verified git-tracked (`hooks.json`, `tests/*`, `bbj-check.sh`). None are gitignored mirrors.

RESEARCH.md corrections applied over CONTEXT.md: no `$input` in `commandWindows` (use `findstr` + `cmd /c echo ... 1>&2`); control path is `sub\.\f.bbj` (not `sub\..\sub\f.bbj`, which gives 0 calls because `..` segments are skipped); NR_T2 value is `noconn` (a bare `timeout` word trips `static_timeout_command`).

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `plugins/bbj/hooks/hooks.json` (`commandWindows`) | config | request-response (stdin payload to launcher, exit code back) | itself, current line 10 | exact (replace one value) |
| `plugins/bbj/scripts/bbj-check.sh` (`no_tier1_route`, `notice`, header comments) | service (hook) | request-response | itself: `refused` arm / `NR_T2` handling | exact |
| `tests/fake-bin/curl` (`FAKE_CURL_WRITEOUT` seam) | test fixture | request-response | itself (`FAKE_CURL_EXIT` seam) | exact |
| `tests/test_tier2_fake.sh` (SC2 gates `tier2_once_*`) | test | request-response | `ctimeout` helper, same file l.274-292 | exact |
| `tests/test_discovery.sh` (bait gate + control) | test | file-I/O | `wpatch_gate` / `windows_codex_backslash_dotdot_skipped`, l.270-300 | exact |
| `tests/test_hook_mutation.sh` (NEW, prefix `hookmut_`) | test (mutation) | batch / transform | `tests/test_release_text_mutation.sh`; tree-copy shape from `tests/test_path_scrub.sh` | role-match |
| `tests/test_layout.py` (`HOOK_COMMAND_WINDOWS` re-pin + guards) | test | transform | itself, l.48-53 and l.211-215 | exact |
| `tests/test_codex_patch.sh` (`plugin_route_command_windows`, IN-02) | test | request-response | itself, l.236-252 | exact |
| `tests/test_install_pages.sh` (l.225 pin) | test | transform | itself | exact |
| `docs/install-codex.md` (l.63, l.219-223) | docs | n/a | itself | exact |
| `13-WINDOWS-RUN.md` (owner record) | doc | n/a | `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` | exact |

## Pattern Assignments

### `plugins/bbj/hooks/hooks.json` (config)

**Analog:** current file. Replace only line 10; keep `command`, `timeout`, `statusMessage`.

Current (l.9-10):
```json
"command": "sh \"${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh\"",
"commandWindows": "C:\\PROGRA~1\\Git\\bin\\sh.exe \"${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh\"; exit $LASTEXITCODE",
```
New value: `json.dumps` of the eight statements pinned in 13-02-PLAN.md `<interfaces>` (they supersede RESEARCH "Code Examples 1"; outline: lookup loop over `$env:ProgramFiles`, `${env:ProgramFiles(x86)}`, `"$env:LOCALAPPDATA\Programs"`; `Get-Command sh`; git-derived `..\bin\sh.exe`; not-found branch with `findstr /n /r "^" 2>&1` and silence only after a full read that names no BBj file, `cmd /c "echo ... 1>&2 & ..."`, `exit 2`; then `& $s "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; if ($null -eq $LASTEXITCODE) { exit 1 }; exit $LASTEXITCODE`). Generate it with `json.dumps`, never hand-escape. Forbidden in the string: `$input`, `[Console]`, `::`, `.WriteErrorLine`, `.ReadToEnd`, `.Invoke(`, `PROGRA~1`, and the self-scan words from RESEARCH Pitfall 10.

---

### `plugins/bbj/scripts/bbj-check.sh` (hook, request-response)

**Analog:** itself.

**Cache** (new first statements of `no_tier1_route`, currently l.241-242, before `_url=`). The marker comment at the end of the line is what the mutation deletes:
```sh
no_tier1_route() {
  # FIX-02 (phase 13): ... a reached route is never cached.
  case "$NR_T2" in refused|nocurl|badurl|noconn) return 1 ;; esac # t2-cache
  _url=${BBJ_LOCAL_MCP_URL:-http://127.0.0.1:5009/mcp}
```
Note: `NR_HOSTPORT` is set after the cache point; on a cached skip it already holds the first attempt's value, so the notice is unchanged (D-14). `NR_T2=` is initialized in `main` (~l.649), so no new global is needed.

**Curl call and classification** (replace l.275-280; current form):
```sh
  _reply=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout "$_ct" -m 12 -X POST -H 'Content-Type: application/json' ... --url "$_url" 2> /dev/null)
  _rc=$?
  if [ "$_rc" = 7 ]; then NR_T2=refused; return 1; fi
  { [ "$_rc" = 0 ] && [ -n "$_reply" ]; } || return 2
```
New form (RESEARCH Code Examples 2): add `-w '\n%{time_connect} %{remote_ip}'` on the same single `curl` line (static guard `curl_check` reads one line, so `--noproxy` and `--proto =http` must stay on it), split `_out` into `_reply` and `_wo` at the last newline, then:
```sh
  if [ "$_rc" = 28 ] && [ -n "$_wo" ] && [ -z "${_wo#* }" ] && [ -z "$(printf '%s' "${_wo%% *}" | tr -d '0.,')" ]; then
    NR_T2=noconn
    return 1
  fi
```
Anything else (exit 28 with a connection, no write-out) falls to `return 2`, so `notice_curl_exit_28_silent` stays green.

**notice arm** (add after l.198 `refused)`):
```sh
    refused) _why2="no bbj-ls answering on $NR_HOSTPORT" ;;
    noconn) _why2="no bbj-ls answering on $NR_HOSTPORT (connect timed out)" ;;
```
Also update the stale comments (header "Only exit 7 is no route", l.236-240 block comment, l.173 `NR_T2` mention) citing FIX-02, D-11, D-12. Comments may say "timeout"; code lines may not use it bare.

**Backslash conversion (do not change)**, l.564, the mutation target: `  printf '%s' "$1" | tr '\\' '/'`. The `..` skip is at l.631-633:
```sh
    case "$_p" in
      */..|*/../*) continue ;;
    esac
```

---

### `tests/fake-bin/curl` (fixture)

**Analog:** itself (whole file, 9 lines). Append before the final `exit`, keeping the log block and `FAKE_CURL_EXIT` default 7:
```sh
if [ -n "${FAKE_CURL_WRITEOUT+x}" ]; then printf '\n%s' "$FAKE_CURL_WRITEOUT"; fi
exit "${FAKE_CURL_EXIT:-7}"
```
Update the header comment to name the seam (phase 13, FIX-02). Values: `'0.000000 '` (connect never completed), `'0.000129 127.0.0.1'` (connection made).

---

### `tests/test_tier2_fake.sh` (test, request-response)

**Analog:** `ctimeout` (l.274-292) and `run_t2` (l.51-55), `fresh_state`, `notice_text`.

**Pattern to copy** (l.274-292): `: > "$FAKE_CURL_LOG"`, export `BBJ_LOCAL_MCP_URL`, `run_t2 "$PAYLOAD" "$3"`, read `--connect-timeout` with `awk '/^--connect-timeout$/ { getline; print; exit }'`, count calls with `grep -cx CALL "$FAKE_CURL_LOG"`, single `if ... gate ok / else gate FAIL "exit $RC, $_calls ..."`.

```sh
run_t2() {
  PATH=${2:-$SYSPATH}
  run_check "$1"
  PATH=$ORIGPATH
}
```
Add (RESEARCH Code Examples 3, before `finish`): build `MANYPAYLOAD` (`NMANY=12` `*** Add File: fN.bbj` headers via `codex_payload`), then `oncegate NAME EXIT WRITEOUT WANTCALLS TEXT` run with `"$WORK/cygbin:$CURLPATH"` (Windows branch, `--connect-timeout 5`). Gates: `tier2_once_windows_refused` (exit 7, 1 call, notice has `and 7 more`), `tier2_once_windows_connect_timeout` (exit 28, `'0.000000 '`, 1 call, `(connect timed out)`), `tier2_transfer_timeout_not_cached` (exit 28, `'0.000129 127.0.0.1'`, 12 calls, silent), `tier2_every_file_when_answering` (`start_fake clean`, 12 server requests). Prefixes `tier2_once_` and `tier2_every_` do not collide with existing `tier2_connect_timeout_*`, `url_`, `req_`, `mode_`.

---

### `tests/test_discovery.sh` (test, file-I/O)

**Analog:** l.270-300 (`wpatch`, `wpatch_gate`, existing `windows_codex_backslash_dotdot_skipped`).

```sh
wpatch_gate windows_codex_backslash_relative 'C:\Users\x\bbj test' 'sub\f.bbj'
: > "$WORK/drive/Users/x/x.bbj"
wpatch 'C:\Users\x\bbj test' 'sub\..\..\x.bbj'
_n=$(grep -c '^CALL$' "$FAKE_LOG")
if [ "$_n" = 0 ] && [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
  gate windows_codex_backslash_dotdot_skipped ok "..."
else
  gate windows_codex_backslash_dotdot_skipped FAIL "calls $_n, exit $RC, ..."
fi
unset BBJ_HOME
```
Keep this existing gate. Insert the new block (RESEARCH Code Examples 4) before `unset BBJ_HOME` (BBJ_HOME must still be set): bait file `BAIT=$WORK'/drive/Users/x/bbj test/sub\..\..\x.bbj'` created with `( : > "$BAIT" ) 2> /dev/null && [ -f "$BAIT" ]` (else `skip`); gate `windows_codex_backslash_bait_skipped` (0 calls, exit 0, silent); control `wpatch_gate windows_codex_backslash_dot_control 'C:\Users\x\bbj test' 'sub\.\f.bbj'` (exactly one call).

---

### `tests/test_hook_mutation.sh` (NEW; test, batch)

**Analogs:** `tests/test_release_text_mutation.sh` (header comment shape, `fresh_root`/`mutate`, `cmp -s` "changed nothing" guard, `gate ... ok|FAIL` with `rc=` details, ends `finish`) and `tests/test_path_scrub.sh` (copies `tests/` so the copied `lib.sh` makes `REPO` point at the tree).

Copy these shapes from `test_release_text_mutation.sh`:
```sh
. "$(dirname "$0")/lib.sh"
mkwork
...
sed "$3" "$_root/$2" > "$_root/$2.new" && mv "$_root/$2.new" "$_root/$2"
if cmp -s "$_root/$2" "$REPO/$2"; then
  gate "release_mut_$_case" FAIL "the mutation changed nothing in $2"
  return
fi
```
Use RESEARCH Code Examples 5 verbatim: `fresh_tree`, `nested`, `control`, `mutant`; prefix `hookmut_`; header comment with plan/decision IDs (FIX-02, FIX-03, D-18) and "Nothing here runs BBj". Cases:
- `control backslash_conversion test_discovery.sh windows_codex_backslash_bait_skipped` then `mutant ...` with a sed that strips `| tr '\\' '/'` from l.564.
- `control t2_cache test_tier2_fake.sh tier2_once_windows_refused` then `mutant t2_cache ... '/# t2-cache$/d'`.
Unset `FAKE_*` and `TIER2_TEST_SYSPATH` before nesting. `hookmut_` is not a prefix of any existing gate name. Phase 14 (MAINT-09) adds it to the CLAUDE.md prefix block; do not edit that here.

---

### `tests/test_layout.py` (test, transform)

**Analog:** itself.

Pin (l.53, replace, and rewrite the comment on l.48-52 about the 8.3 path):
```python
HOOK_COMMAND_WINDOWS = 'C:\\PROGRA~1\\Git\\bin\\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE'
```
Build the new constant as `"; ".join((...raw-string statements...))` so it diffs against RESEARCH Code Examples 1. Gate pattern (l.211-215) stays:
```python
gate("hook_command_windows",
     len(hook_list) == 1 and hook_list[0].get("commandWindows") == HOOK_COMMAND_WINDOWS
     and hook_list[0].get("command") == HOOK_COMMAND,
     "commandWindows=%r" % (...,))
```
Add always-running guards beside it using the same `gate(name, cond, detail)` form with `%`-formatting (no f-strings): decoded string has no `$input` (case-insensitive), `[Console]`, `::`, `.WriteErrorLine`, `.ReadToEnd`, `.Invoke(`, `PROGRA~1`; contains each lookup location, `exit 2`, and ends with `exit $LASTEXITCODE`. Assemble any forbidden token the file itself must name from pieces (self-scan convention, e.g. `"$" + "input"`).

---

### `tests/test_codex_patch.sh` (test, IN-02)

**Analog:** itself, l.236-252. Keep the `python3 -I -c` reader that sets `ROUTE_CMD_WIN`; replace the final `[ "$ROUTE_CMD_WIN" != "$ROUTE_CMD" ]` test with three `case` checks on `$ROUTE_CMD_WIN`: names `'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'`; ends with `*'exit $LASTEXITCODE'`; contains the not-found text (`*'sh.exe not found'*`). Retain the `ROUTE_CMD` check and the `gate plugin_route_command_windows ok|FAIL` line shape:
```sh
case "$ROUTE_CMD_WIN" in
  *'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'*)
    case "$ROUTE_CMD" in
      *'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'*)
        [ "$ROUTE_CMD_WIN" != "$ROUTE_CMD" ] \
          && gate plugin_route_command_windows ok "..." \
          || gate plugin_route_command_windows FAIL "commandWindows equals command"
```
Update the comment above it (D-11 of phase 9) to cite D-09 of phase 13.

---

### `tests/test_install_pages.sh` and `docs/install-codex.md`

**Analog:** itself. Pin at `tests/test_install_pages.sh:225` is `'C:\PROGRA~1\Git\bin\sh.exe' \` inside a `need` list (gate name `codex_has_C__PROGRA_1_Git_bin_sh_exe`). Docs at `docs/install-codex.md:63` and `:219-223` state the 8.3 path. Change test pin and docs in the same commit, or leave both for Phase 14 (suite stays green either way). Per RESEARCH, new behaviour claims in docs need `13-WINDOWS-RUN.md` first, so docs go in the last plan, after the owner run. The word `commandWindows` must stay on both pages (`test_install_pages.sh:114, 200`). Do not touch `CHANGELOG.md` or `tests/test_release_text.py` (Phase 15). Do not reference the earlier string (Phase 12 D-12).

---

### `.planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md`

**Analog:** `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` plus `platform-run/windows-runbook.md`, checked with `platform-run/check-records.sh`. Cases (D-20): default install, `sh.exe` missing, per-user `%LOCALAPPDATA%\Programs\Git`, launcher-only `powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`. Throwaway Codex home only; each step waits for the owner's go.

## Shared Patterns

### Gate grammar and test skeleton
**Source:** `tests/lib.sh`, any `tests/test_*.sh`.
**Apply to:** all new/modified shell tests.
```sh
. "$(dirname "$0")/lib.sh"
mkwork
...
gate NAME ok|FAIL|skip "detail"
finish
```
Header comment names plan, decision IDs (FIX-0x, D-xx) and "Nothing here runs BBj". Underscore-prefixed temporaries, no `local`, `[ ]` only, `printf` for data, `> /dev/null` with a space.

### Hook safety invariants (do not weaken)
**Source:** `plugins/bbj/scripts/bbj-check.sh`, enforced by `tests/test_static_guards.sh`, `test_exit_contract.sh`, `test_never_execute.sh`.
**Apply to:** every `bbj-check.sh` edit. Exit only 0 or 2; stdout only for the single no-route notice; `-N` on every compiler call; every `curl` carries `--noproxy '*'` and `--proto =http` on its own single line with no redirect flag; loopback URLs only; no `set -e`; every failure path ends in an explicit `return`/`exit 0`; no bare `timeout` word on a non-comment line (use `noconn`).

### Mutation proof
**Source:** `tests/test_release_text_mutation.sh` l.46-60 (`mutate`) and clean-copy control.
**Apply to:** `tests/test_hook_mutation.sh`. A mutated copy must print `FAIL` for the named gate and exit 1; an unmutated copy must pass; a mutation that changes nothing is itself a FAIL.

### Self-scan convention
**Source:** `.claude/CLAUDE.md` (`OIDC_PERMISSION = "id" + "-token"` in `tests/test_ci_guards.py`).
**Apply to:** tests and comments that must mention a word a scanner forbids; also keep the retired-word list out of the new `commandWindows` message.

## No Analog Found

| File / part | Role | Data Flow | Reason |
|---|---|---|---|
| PowerShell lookup + not-found branch inside `commandWindows` | config (inline script) | request-response | No PowerShell exists in the repo; use RESEARCH Code Examples 1 (run on pwsh 7.6.7, Windows PowerShell 5.1 unproven until the owner run) |
| Optional `tests/test_windows_command.sh` (`wincmd_`, runs the string under `pwsh`) | test | request-response | No pwsh gate exists; RESEARCH Open Question 3, optional, must `skip` without pwsh |
| Optional real-curl connect-timeout gate | test | request-response | Only fake curl is used today; RESEARCH Code Examples 3 note, skip on surprise |

## Metadata

**Analog search scope:** `plugins/bbj/hooks`, `plugins/bbj/scripts`, `tests/`, `docs/`, `.planning/milestones/v0.2.1-phases/09-*`
**Files scanned:** about 14 read or grepped
**Pattern extraction date:** 2026-10-15
