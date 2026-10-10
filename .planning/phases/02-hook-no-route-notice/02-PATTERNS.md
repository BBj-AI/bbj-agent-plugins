# Phase 2: Hook no-route notice - Pattern Map

**Mapped:** 2026-10-10
**Files analyzed:** 14 (1 new test, 1 new evidence dir/script, 12 modified)
**Analogs found:** 14 / 14 (all analogs git-tracked; verified with `git ls-files`)

Line numbers below are for the files as of this mapping (pre-change).

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `plugins/bbj/scripts/bbj-check.sh` | hook script | request-response (stdin JSON -> exit code / JSON stdout) | itself (`no_tier1_route`, `check_file`, `report`, `main`) | exact (self-edit) |
| `tests/lib.sh` | test helper | config / env seam | itself (`mkwork`, payload builders) | exact (self-edit) |
| `tests/fake-bin/curl` | test fake | request-response | itself (hardcoded `exit 7`) | exact (self-edit) |
| `tests/fake_mcp.py` | test fake server | request-response | itself (`body_for` modes) | exact (self-edit) |
| `tests/test_noroute_notice.sh` (NEW) | test | request-response | `tests/test_tier2_fake.sh` (fake curl + fake server) and `tests/test_discovery.sh` (fake compiler homes) | role-match |
| `tests/test_exit_contract.sh` | test | request-response | itself (`contract()`, `run_shell`) | exact (self-edit) |
| `tests/test_discovery.sh` | test | request-response | itself (`go`, gates at L90-112) | exact (self-edit) |
| `tests/test_tier2_fake.sh` | test | request-response | itself (`refused()` L195, `no_curl_silent`) | exact (self-edit) |
| `tests/test_static_guards.sh` | test (static scan) | transform | itself | exact; probably needs no change (research: all static gates passed on prototype) |
| `README.md` (L41) | docs | n/a | adjacent sentence | n/a |
| `docs/install-claude-code.md` (L105-106, L113) | docs | n/a | adjacent text | n/a |
| `docs/install-codex.md` (L199) | docs | n/a | adjacent text | n/a |
| `codex/install-codex.sh` (L787 `say` line) | installer message | n/a | the neighbouring `say` lines | exact |
| `.planning/phases/02-hook-no-route-notice/evidence/` (capture script + transcripts) | evidence script | batch / file-I/O | `tests/test_install_codex.sh` (fake `codex` on PATH, scratch `CODEX_HOME`) and `tests/test_claude_plugin.sh` (throwaway config dir) | partial |

## Pattern Assignments

### `plugins/bbj/scripts/bbj-check.sh` (hook, request-response)

**Analog:** itself. Sites to change, with the code that exists today.

**Return-code split in `no_tier1_route`** (lines 85-122). Today every failure path is `return 0`:
```sh
  case "$_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) return 0 ;;
  esac
  _ok=$(printf '%s' "$_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_ok" = ok ] || return 0
  command -v curl > /dev/null 2>&1 || return 0
  ...
  _reply=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 -X POST ... --url "$_url" 2> /dev/null)
  [ "$?" = 0 ] && [ -n "$_reply" ] || return 0        # L107: split this into rc 7 vs other
  ...
  if printf '%s' "$_reply" | grep -E '"error"[[:space:]]*:|"isError"[[:space:]]*:[[:space:]]*true' > /dev/null; then return 0; fi
  case "$_text" in "No errors found."*) return 0 ;; esac
  _errs=$(printf '%s\n' "$_text" | grep -E '^line [0-9]+, column [0-9]+:')
  [ -n "$_errs" ] || return 0
  report bbj-local "$_errs"
```
Target (RESEARCH §Code Examples): return 0 = verdict, 1 = no route (set `NR_T2` to `badurl|nocurl|refused`, `NR_HOSTPORT`), 2 = route failed. Capture `_rc=$?` straight after `curl`; `[ "$_rc" = 7 ] && { NR_T2=refused; return 1; }`; every other nonzero rc, empty reply, rpc error, no-verdict text -> `return 2`. Document the curl-code table in the header comment (D-03). Keep the comment "Every failure path ends in an explicit return".

**Call sites in `check_file`** (lines 319-322 and 358-362):
```sh
  if ! discover; then
    no_tier1_route
    return 0
  fi
  ...
    if [ -n "$out" ] || [ "$rc" -ge 126 ]; then no_tier1_route; fi
    return 0
```
Replace with `no_tier1_route; [ "$?" = 1 ] && note_noroute none` and `... note_noroute noresult` (D-02). The early skips at L285-318 (extension, newline/glob names, non-absolute, unreadable, symlink, `config*.bbx`) stay untouched and never reach the collector (D-05).

**Error-path grammar to leave alone** (`report`, lines 75-80): `printf '%s reported %s error(s) in %s:\n' ... >&2` then `FAILED=1`. The notice must not reuse this header (D-12).

**JSON escaping, existing approach** (lines 99-103; reuse the sed idiom for the new `json_body`):
```sh
  _code=$(LC_ALL=C tr -d '\000-\010\013\014\016-\037' < "$file" \
    | LC_ALL=C sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$_tab/\\\\t/g" -e "s/$_cr/\\\\r/g" \
    | LC_ALL=C awk '{ printf "%s%s", $0, "\\n" }')
```
RESEARCH recommends a stricter `json_body` (`LC_ALL=C sed -e 's/[^ -~]/?/g' -e 's/\\/\\\\/g' -e 's/"/\\"/g'`) because Latin-1 bytes made invalid JSON in the prototype.

**New functions** (collector, marker, single stdout write): copy the prototype bodies in 02-RESEARCH.md §Code Examples (`note_noroute`, `json_body`, `notice`). Key constraints: plain `mkdir` (never `-p`); after a failed `mkdir`, `[ -d "$_m" ] && [ ! -L "$_m" ]` means already told; any other failure still notifies; empty sanitised key notifies every call (D-16); `_state=${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}`; underscore-prefixed temporaries; no `local`; text must avoid the bare words guarded by `tests/test_static_guards.sh` (eval, timeout, node, python, jq, bare `bbj `) and never name the hosted host (`docs_host_single_source`).

**`main` tail** (lines 446-472). Existing:
```sh
  tool=$(printf '%s' "$hd" | jget pre tool_name)
  if [ -z "$tool" ]; then
    tool=$(printf '%s' "$input" | jget all tool_name)
    [ "$tool" = apply_patch ] || tool=
  fi
  ...
  if [ "$FAILED" = 1 ]; then
    printf 'bbj_lookup gives exact syntax for a named symbol.\n' >&2
    exit 2
  fi
  exit 0
```
Copy the `jget pre` then `jget all` fallback for `session_id`; initialise `NR_N=0 NR_LIST= NR_COMPILER=` next to `FAILED=0` (L449); add after the `FAILED` block: `if [ "$NR_N" -gt 0 ]; then sid=...; notice "$tool" "$sid"; fi` then `exit 0`.

**Header block** (lines 9-10, 27, 46-47): "exit 0, no output at all" and "stdout stays empty and the exit code is only ever 0 or 2" must become "stdout is written in exactly one case, the notice JSON". Keep the "There is deliberately no set -e" sentence, add plan/decision IDs (HOOK-01..04, D-01..D-19).

**Codex fallback (D-15):** only if the capture shows non-delivery; three-line switch in `main` for `apply_patch` (same body to stderr, first sentence "The patch was applied and the file was written; it was not compile-checked.", `exit 2`).

---

### `tests/lib.sh` (test helper, config)

**Analog:** itself.

**Hermetic env block to extend** (lines 27-31):
```sh
BBJ_CHECK_DEFAULT_HOMES=
export BBJ_CHECK_DEFAULT_HOMES
unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR
BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp
export BBJ_LOCAL_MCP_URL
```
**`mkwork`** (lines 49-53): add `BBJ_CHECK_STATE_DIR=$WORK/state; mkdir "$WORK/state"; export BBJ_CHECK_STATE_DIR` after the `mktemp` line. Add a `fresh_state` helper (new `$WORK/state.$N` dir, export) with a usage comment in the style `# fresh_state: ...`.

**Payload builders** (lines 78 and 85) hardcode `"session_id":"s1"`; change to `"session_id":"'"${SESSION_ID:-s1}"'"` in both. Update the header "Provides:" list for the new helpers. Shell style: underscore temporaries (`_tool`, `_file`), no `local`, shellcheck clean.

---

### `tests/fake-bin/curl` (test fake)

**Analog:** itself (whole file, 9 lines). Change only the last line:
```sh
exit 7
```
to `exit "${FAKE_CURL_EXIT:-7}"` and update the header comment ("exits 7 ... by default; FAKE_CURL_EXIT overrides"). Used to test curl 28/52/56 as route-failed.

---

### `tests/fake_mcp.py` (test fake server)

**Analog:** itself, `body_for` (lines 45-65):
```python
    if mode == "rpc-error":
        err = {"jsonrpc": "2.0", "id": None, "error": {"code": -32020, "message": "unsupported protocol version"}}
        return 400, "application/json", json.dumps(err)
    if mode == "garbage":
        return 200, "text/html", "<html>not json at all</html>"
    ...
    raise SystemExit("unknown mode " + mode)
```
Add modes `is-error` (a result with `"isError": true`, built via `gson_style(...)`), `empty` (200, empty body) and `no-verdict` (text with neither "No errors found." nor `line N, column M:`) as further `if mode == ...` blocks returning `(status, content_type, body)`; update the module docstring that lists modes (around L21). Stdlib only, 4-space indent, double quotes, `%`-formatting.

---

### `tests/test_noroute_notice.sh` (NEW; test, request-response)

**Analogs:** `tests/test_tier2_fake.sh` (structure, fake curl, fake server) and `tests/test_discovery.sh` (fake compiler homes).

**Header + setup pattern** (test_tier2_fake.sh lines 1-60): block comment naming plan and decision IDs, "Nothing here runs BBj", then:
```sh
. "$(dirname "$0")/lib.sh"
mkwork

FAKE_PIDS=
cleanup() {
  for _p in $FAKE_PIDS; do kill "$_p" 2> /dev/null; done
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP
SYSPATH=/usr/bin:/bin
ORIGPATH=$PATH
```
`start_fake MODE` / `stop_fake` / `run_t2 PAYLOAD [PATH]` (lines 25-52) can be copied verbatim (they set `BBJ_LOCAL_MCP_URL` from a port file). Fake curl wiring (lines 187-194):
```sh
mkdir "$WORK/curlbin"
cp "$REPO/tests/fake-bin/curl" "$WORK/curlbin/curl"
chmod 755 "$WORK/curlbin/curl"
FAKE_CURL_LOG=$WORK/curl.log
export FAKE_CURL_LOG
CURLPATH=$WORK/curlbin:$SYSPATH
```
**Gate shape** (lines 195-205 style): one `if [ conditions ]; then gate "notice_<name>" ok "..." else gate "notice_<name>" FAIL "..."; fi`; end with `finish`. Use prefix `notice_`. Validate the JSON with `python3 -I -c 'import json,sys; ...'` (stdlib only). Gates to cover: grammar and key order of the JSON; first call notice, second silent; other session id notifies again; empty/missing `session_id` notifies every call; unwritable state dir notifies; symlink-squatted marker notifies; exit-2 call then no-route call still notifies (marker not burned); route-failed cases (`FAKE_CURL_EXIT=28/52/56`, fake modes `rpc-error`, `garbage`, `is-error`, `empty`, `no-verdict`) silent; clean silent; README/early skips silent; mixed `apply_patch` (errors -> exit 2 and no notice); hostile names (quote, backslash, tab, Latin-1 byte) give valid JSON; 5-path cap plus "and M more", length < 10,000; Claude vs Codex text differences; reason strings exactly per D-09.
**Compiler fixture for the "found but no result" reason:** copy `mkhome` from test_discovery.sh (it copies `tests/fake-bin/bbjcpl` into a temp home; `FAKE_OUT`, `FAKE_EXIT=139` drive it).

---

### `tests/test_exit_contract.sh` (test, request-response)

**Analog:** itself.

**`contract()`** (lines 38-46) is the function to extend:
```sh
contract() {
  if { [ "$RC" = 0 ] || [ "$RC" = 2 ]; } && [ ! -s "$WORK/stdout" ]; then
    gate "contract_$1_$2" ok "exit $RC, stdout empty"
  else
    gate "contract_$1_$2" FAIL "exit $RC, stdout $(wc -c < "$WORK/stdout") bytes"
  fi
}
```
Add an optional third argument `empty` (default) or `notice`; for `notice`, require exit 0, empty stderr and stdout parsing (python3 -I) as one object `hookSpecificOutput` -> (`hookEventName`, `additionalContext`). Narrow amendment only.

**Crashing-compiler case** (lines 69-75): `FAKE_EXIT=139` ... `contract "$_sn" crashing_compiler`. Convert to two runs with a `fresh_state`: first `notice`, second `empty`. This affects `contract_dash_`, `contract_bash_` and (where installed) `contract_busybox_crashing_compiler`. Update the header comment ("never writes to stdout" -> "writes stdout only for the notice").

---

### `tests/test_discovery.sh` (test, request-response)

**Analog:** itself. Three gates convert (research §Test inventory):
- `no_route_silent` (lines 87-93):
```sh
go
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$FAKE_LOG" ]; then
  gate no_route_silent ok "exit 0, no output"
else
  gate no_route_silent FAIL "exit $RC"
fi
```
  Rename `no_route_notice_then_silent`: `fresh_state`; `go` -> exit 0, stderr empty, `$FAKE_LOG` empty, stdout contains "no bbjcpl found" and "no bbj-ls answering on 127.0.0.1:9"; `go` again -> stdout empty.
- `unusable_output_silent` (L97-105) and `crash_silent` (L106-114): same, first call must name "bbjcpl found but gave no result".

---

### `tests/test_tier2_fake.sh` (test, request-response)

**Analog:** itself.
- `refused()` (lines 195-205, 12 callers at L206-217): add `fresh_state`, assert first call exit 0, `$FAKE_CURL_LOG` empty, stdout notice JSON with "bbj-ls URL refused (not loopback)"; second call silent. Gate names `url_refused_<tag>` stay.
- `no_curl_silent` (lines 249-256): convert to first-call notice with "curl not found" and `$LOGF` empty, then silent.
- Leave `silent()`-based gates (clean, `rpc-error`, `garbage`), `tier1_wins_no_request`, `url_accepted_*` as they are (they remain correct; research verified).

---

### `tests/test_static_guards.sh` (static scan)

**Analog:** itself. Research found no gate fails on the prototype (no pattern forbids `mkdir`, `/tmp` or a single `printf` to stdout). Keep as is unless a gate asserting "stdout never written" exists; if so, narrow the allowance to the one notice `printf`. The `curl_check` helper (L22-31) already requires `--noproxy` and `--proto =http`; do not break it when editing the `curl` line.

---

### Docs and installer text (4 one-line corrections; recommended in this phase)

Stale sentences, each now false:
- `README.md:41`: "a clean file, a non-BBj file or a missing compiler is silent."
- `docs/install-claude-code.md:105-106`: "Neither route ... does nothing and says nothing." (and check L113 "A clean file is silent in every route")
- `docs/install-codex.md:199`: "3. **Neither:** the hook does nothing and says nothing."
- `codex/install-codex.sh:787`:
```sh
say "- With no compiler found, the hook asks a running bbj-ls on 127.0.0.1:5009 (syntax only); with neither it does nothing and says nothing."
```
Keep the same `say "..."` form (the static `curl_check` tolerates a plain `say "..."` line; avoid `$(` or backticks in it). No gate pins these (tests/test_install_pages.sh, test_install_codex.sh stayed green in the prototype). CHANGELOG stays out (Phase 6).

---

### Evidence capture script and `evidence/` dir (batch, file-I/O)

**Analogs:** `tests/test_install_codex.sh` (scratch `CODEX_HOME` with `tests/fake-bin/codex` first on PATH so the real config is not touched) and `tests/test_claude_plugin.sh` (throwaway Claude config dir; local-marketplace install path). Read both before writing the script.
**Recipe:** 02-RESEARCH.md §Delivery capture (flags confirmed in `--help`):
- Codex: scratch project, project-local `.codex/hooks.json` whose command is `env BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp BBJ_CHECK_STATE_DIR=$S/state sh <script>`, wrapped with `tee -a payload.jsonl`; `codex exec --ignore-user-config --dangerously-bypass-hook-trust -C "$S" --json -o ...`. The flag-vs-`/hooks` approval choice deviates from D-13 wording: make it a `checkpoint:decision`.
- Claude Code: `claude -p ... --plugin-dir plugins/bbj --permission-mode acceptEdits --allowedTools Write --strict-mcp-config --output-format stream-json --verbose --include-hook-events --no-session-persistence --max-budget-usd N`, never `--bare`.
- Machine has a real `/opt/bbx` and live bbj-ls on 5009, so the seams above are mandatory in every capture.
- Script conventions: `#!/bin/sh`, header comment with plan/decision IDs, "never runs BBj", `mktemp -d` + `trap` cleanup; if placed under `tests/` it must be named `test_*.sh` or it will be picked up by `tests/run.sh` (a billed model call must NOT be in the run glob), so keep it under the phase directory. Scripts under the phase dir are not shellchecked by `tests/ci.sh` (it covers `plugins/bbj/scripts`, `codex`, `tests/*.sh`) but keep them clean anyway.
- Commit only evidence (events JSONL, last message, payload log, command line, `codex --version`); nothing from `~/.codex`.

## Shared Patterns

### Gate line and file prologue
**Source:** `tests/lib.sh` lines 35-42, and every test's first lines
**Apply to:** all test files
```sh
gate() {
  case "$2" in
    ok) echo "gate $1 ok $3" ;;
    skip) echo "gate $1 skip $3" ;;
    *) echo "gate $1 FAIL $3"; LIB_FAILED=1 ;;
  esac
}
```
Each test: `#!/bin/sh`, header block naming plan, decision IDs, "Nothing here runs BBj", `. "$(dirname "$0")/lib.sh"`, `mkwork`, ..., `finish`.

### Hermetic state per case
**Source:** `tests/lib.sh` (new `fresh_state`, `SESSION_ID`, `BBJ_CHECK_STATE_DIR` in `mkwork`)
**Apply to:** every converted or new gate that calls the hook with no route; otherwise results depend on order and leak markers into `/tmp`.

### Exit contract and stdout
**Source:** `plugins/bbj/scripts/bbj-check.sh` header (L9-10, L46-47), `tests/test_exit_contract.sh`
**Apply to:** hook edits and every test asserting empty stdout. Exit only 0 or 2; stdout written only by the one notice `printf`; stderr only by `report` and the `bbj_lookup` line.

### Shell style (shipped and test scripts)
**Source:** `.claude/CLAUDE.md` Conventions
`[ ]` not `[[ ]]`, `$(...)`, `printf` for user data, `command -v x > /dev/null 2>&1`, underscore temporaries, no `local`, no `set -e`, two-space indent, redirections as `> /dev/null`, single quotes around awk/sed/grep programs, a reason beside every shellcheck directive.

### Safety invariants (static gates)
**Source:** `tests/test_static_guards.sh`, `tests/test_never_execute.sh`, `tests/test_layout.py`
Every compiler call carries `-N`; every curl carries `--noproxy '*'` and `--proto =http` and no `-L`; no hosted host name outside `plugins/bbj/.claude-plugin/plugin.json` (name the server `bbj-docs`); the hook never calls the hosted check; keep forbidden words off executable lines (comments are not scanned).

### Commit style
`feat(02-0N): ...`, `test(02-0N): ...`, `docs(02-0N): ...`; no version bumps (Phase 6).

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| hook stdout JSON writer (`notice` in `bbj-check.sh`) | hook output | request-response | The hook has never written stdout; use the prototype in 02-RESEARCH.md §Code Examples and the contract in §Contract |
| `mkdir` marker (once-per-session) | state | CRUD | No existing marker or state-dir pattern in the repo (the exit-contract test even asserts no marker files are created by the old hook); use the algorithm in RESEARCH and decisions D-16..D-18 |
| Real-client capture (`codex exec`, `claude -p`) | evidence | batch | No test calls a billed real client; only fakes exist (`tests/fake-bin/codex`). Follow RESEARCH §Delivery capture |

## Metadata

**Analog search scope:** `plugins/bbj/scripts/`, `tests/`, `tests/fake-bin/`, `codex/`, `README.md`, `docs/`
**Files scanned:** about 12 read or grepped (hook script in segments, lib.sh, fake curl, fake_mcp.py, 3 test files, static guards header)
**Tracked-source gate:** all named analogs are plain tracked paths under `plugins/bbj/`, `tests/`, `codex/` (confirmed via `git ls-files`); no `.gsd/capabilities` mirror paths are used.
**Pattern extraction date:** 2026-10-10
