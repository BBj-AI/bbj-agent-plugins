# Phase 1: Repo-owned skills and local-first check route - Pattern Map

**Mapped:** 2026-10-09
**Files analyzed:** 22 (4 new, 2 deleted, 16 modified)
**Analogs found:** 19 / 22 (the 3 docs/text files use their own prior content as analog)

All analog paths below were confirmed git-tracked (`git ls-files`). Line numbers are from the files as read on 2026-10-09 and shift after edits. The RESEARCH.md installer prototypes and candidate block text are the primary pattern source for the new code. This file points at the real code to copy from.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `skills.lock.json` (delete) | config | n/a | - | deletion |
| `tests/test_skills_hash.py` (delete) | test | batch | - | deletion |
| `tests/test_layout.py` (modify) | test | batch | itself, lines 130-147 and gate() | exact |
| `tests/test_check_order.py` (NEW) | test | transform | `tests/test_layout.py` (Python gate style, argv[1] root) | exact |
| `tests/fake_mcp.py` (modify) | test fixture | request-response | itself (`body_for`, `do_POST`) | exact |
| `tests/test_install_codex.sh` (modify) | test | request-response / file-I/O | itself (`tsum`, `real_parse`, `newenv`, `run_inst`) + `tests/test_tier2_fake.sh` (`start_fake`) | exact |
| `tests/test_static_guards.sh` (modify) | test | batch | itself, lines 71-83 (curl scan) and 106-134 (codex scan) | exact |
| `tests/test_install_pages.sh` (modify) | test | batch | itself (`need`, `forbid`) | exact |
| `tests/run.sh`, `tests/ci.sh` (comments only) | config | batch | themselves | exact |
| `codex/install-codex.sh` (modify: `sync_server` refactor, `--with-local`, `probe_local`) | installer | file-I/O + request-response (probe) | itself, lines 178-442; probe from `plugins/bbj/scripts/bbj-check.sh` lines 85-107 | exact |
| `codex/AGENTS-snippet.md` (modify) | doc/config text | n/a | itself, lines 23-25 | exact |
| `plugins/bbj/skills/bbj-programming/SKILL.md` (modify) | doc | n/a | itself (frontmatter lines 1-4, H1 line 6) | exact |
| `plugins/bbj/skills/bbj-web-programming/SKILL.md` (modify) | doc | n/a | same | exact |
| `README.md`, `docs/install-claude-code.md`, `docs/install-codex.md` (modify) | doc | n/a | themselves | exact |
| `NOTICE`, `plugins/bbj/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` (wording) | config | n/a | themselves | exact |
| `.claude/CLAUDE.md`, `.planning/codebase/*.md` (wording) | doc | n/a | themselves | exact |

## Pattern Assignments

### `tests/test_layout.py` (test, batch) - VEND-01..03

**Analog:** itself.

**Gate helper to reuse for any new gate** (lines 26-30):
```python
def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate layout_%s %s %s" % (name, "ok" if ok else "FAIL", detail))
```

**Exemption to remove** (lines 130-147). Delete `skills_dir`, the `if os.path.abspath(dirpath) == skills_dir:` block with `dirnames[:] = []` and `continue`. Reword the comment to "the hosted host name occurs once under plugins/". Keep the gate name and the expected list:
```python
for dirpath, dirnames, filenames in os.walk(plugins_dir):
    if os.path.abspath(dirpath) == skills_dir:   # remove these 3 lines
        dirnames[:] = []
        continue
...
gate("docs_host_single_source", hits == ["plugins/bbj/.claude-plugin/plugin.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))
```

**Optional new gates** (`layout_no_skills_lock`, `layout_no_vendoring_wording`, `layout_skills_not_executable`) follow the same `gate(...)` call shape; use `os.access(path, os.X_OK)` and `os.path.exists`. Assemble forbidden words from pieces (`"vend" + "or"`, `"BBj" + "Skills"`) per the CLAUDE.md self-scan convention. Add them before `sys.exit(1 if failed else 0)` (line 149).

---

### `tests/test_check_order.py` (NEW test, transform) - LOCAL-05

**Analog:** `tests/test_layout.py`.

**Header and root pattern** (lines 1-15 of the analog):
```python
"""tests/test_layout.py -- plan 19-03: pins every manifest value ...

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate layout_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root ...
Nothing here runs BBj code ...
"""
import json
import os
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))
failed = False
```
Use prefix `checkorder_`, `%`-formatting, no f-strings, `sys.exit(1 if failed else 0)`. The `extract()` function, the six gates, the `FORBIDDEN` list built from pieces, and the 3-file list are in RESEARCH.md "Pin test design" (lines 439-463); copy them. `tests/run.sh` discovers `tests/test_*.py` by glob, so no runner edit is needed.

---

### `tests/fake_mcp.py` (test fixture, request-response) - LOCAL-07

**Analog:** itself.

**Mode dispatch to extend** (`body_for`, lines 35-53). `body_for` must also accept the new mode names, because `main()` calls `body_for(args.mode)` at line 104 to validate and an unknown mode raises `SystemExit`:
```python
    if mode == "sse":
        ...
    raise SystemExit("unknown mode " + mode)
```
Add `tools-list` and `tools-list-other` (and optionally `tools-list-spaced`) returning a clean `clean`-style reply here.

**Dispatch point** (`do_POST`, lines 85-93). Parse the already-read `body` with try/except and, when `method == "tools/list"` and the mode starts with `tools-list`, reply with a tools result before the final `self._reply(*body_for(mode))`. Keep the `MCP-Protocol-Version` 400 check and `self._log(body)` first:
```python
            self._log(body)
            if not self.headers.get("MCP-Protocol-Version"):
                err = {...}
                self._reply(400, "application/json", json.dumps(err))
                return
            self._reply(*body_for(mode))
```
Use `json.dumps(obj)` default spacing for `tools-list-other` and compact `separators=(",", ":")` for `tools-list` (the real server is compact). Update the docstring mode list (lines 6-13).

---

### `codex/install-codex.sh` (installer, file-I/O + request-response) - LOCAL-01..04

**Analog:** itself (section 1, lines 178-442). Stage per RESEARCH "Staging": refactor with `srv=bbj-docs` only and byte-identical output first, then add `bbj-local`.

**Globals-not-locals parameterisation.** POSIX sh has no `local`; wrap lines 178-442 in `sync_server()` driven by `srv`, `srv_tools`, `srv_begin`, `srv_end`, `srv_url`, `srv_legacy`, `srv_codex_add`, `srv_fixed_url`. Constants block to extend (lines 54-64):
```sh
MARK_BEGIN='# >>> bbj-agent-plugins (managed) >>>'
MARK_END='# <<< bbj-agent-plugins (managed) <<<'
DOCS_TOOLS='bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples'
TOOL_KEY='approval_mode = "approve"'
OLD_KEY_LINE='default_tools_approval_mode = "approve"'
```
Add `LOCAL_MARK_BEGIN='# >>> bbj-agent-plugins bbj-local (managed) >>>'`, `LOCAL_MARK_END='# <<< bbj-agent-plugins bbj-local (managed) <<<'`, `LOCAL_TOOLS='bbj_check_syntax bbj_format bbj_denum'`, `LOCAL_URL=http://127.0.0.1:5009/mcp`. Leave the docs markers byte-identical (8+ gates pin them).

**awk parameterisation in `analyze`** (lines 192-262). Replace the literal `bbj-docs` regexes at 215, 218, 221, 228, 233 with `-v srv=...` and regexes built in `BEGIN` by string concatenation (RESEARCH prototype lines 179-197). Guard the legacy key with `old_key != ""`. Add output fields `managed=` (exact begin-marker line present) and `url=` (value of `url` in the main table, via the existing `val()` at lines 196-202). Existing line shape being generalised:
```sh
        if (line ~ /^\[mcp_servers\.("bbj-docs"|bbj-docs)\][ \t]*(#.*)?$/) {
          sect = "main"
          main = 1
        } else if (line ~ /^\[mcp_servers\.("bbj-docs"|bbj-docs)\.tools\.[A-Za-z0-9_-]+\][ \t]*(#.*)?$/) {
```

**Rewrite awk** (lines 381-425): pass `-v mark_end="$srv_end"` and `-v srv="$srv"`; print the header as `"[mcp_servers." srv ".tools." names[i] "]"` (line 390) and change regexes at 416-417 the same way as in `analyze`. Keep the buffering and flush logic; add a test with both servers in both orders (RESEARCH Pitfall 8).

**Managed append** (lines 342-353), reuse with `$srv_begin`, `$srv`, `$srv_url`, `$srv_end`. This writes the table only and the rewrite awk then adds tool tables (two-step block):
```sh
  {
    if [ -s "$config" ]; then
      [ -z "$(tail -c 1 "$config")" ] || printf '\n'
      printf '\n'
    fi
    printf '%s\n' "$MARK_BEGIN" '[mcp_servers.bbj-docs]' "url = \"$docs_url\"" "$MARK_END"
  } >> "$config" || refuse "cannot write $config"
```

**Messages and exit codes.** Keep every `bbj-docs` string byte-identical and prefix new ones with `"$srv: "`. Use `say`, `refuse`, `pending=1` (lines 66-75, 335, 341). Foreign form: print block via `print_block`, `pending=1` (exit 3):
```sh
  say "bbj-docs: $config already names bbj-docs in a form this script does not edit; config.toml was not modified."
  say "Check that it holds these tables (url and per-tool approval), or add them by hand:"
  print_block "$docs_url"
  pending=1
```
For `bbj-local` add `foreign=1` when `srv_fixed_url=1` and the analysed `url` differs from `$LOCAL_URL` (D-12 refined: plain table with exactly the fixed URL is editable, anything else foreign; never auto-approve on a non-loopback URL).

**Option parsing** (lines 101-110): add one arm in the same shape as `--force`:
```sh
    --force) force=1; shift ;;
```
-> `--with-local) with_local=1; shift ;;`. Update `usage()` (lines 77-93, an unquoted heredoc: escape `$` and backticks) and the header exit-code comment (documented exit codes convention).

**Probe (`probe_local`).** Copy the loopback guard and curl flag set from `plugins/bbj/scripts/bbj-check.sh` lines 86-95 and 106, with the probe's timeouts (`--connect-timeout 2 -m 3`), `Accept` and `Mcp-Method: tools/list` headers, a static body, and the reply match `grep -Eq '"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"'`. Source excerpt:
```sh
  case "$_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) return 0 ;;
  esac
  _ok=$(printf '%s' "$_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_ok" = ok ] || return 0
  command -v curl > /dev/null 2>&1 || return 0
  ...
  curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' --data-binary @- --url "$_url" 2> /dev/null)
```
The skeleton in RESEARCH.md lines 363-378 is ready to paste. Constraints:
- Keep the curl call on ONE line (the static curl guard is line-based).
- The probe URL is `${BBJ_LOCAL_MCP_URL:-$LOCAL_URL}`; the registered URL stays `$LOCAL_URL`.
- Printed text and code lines must not contain `bbjcpl`, or standalone `node`/`python`/`bbj` words (`test_static_guards.sh` lines 112-119).
- Use only tools in the no-codex PATH farm (`test_install_codex.sh` line 33); `curl` is deliberately absent there, which exercises "not probed: curl not found".
- The probe never changes the exit code.
- Do not use `codex mcp add bbj-local`; use the managed block even when `codex` is on PATH.

---

### `tests/test_install_codex.sh` (test, file-I/O) - LOCAL-02..04, 07

**Analog:** itself, plus `tests/test_tier2_fake.sh` for the fake server.

**Per-case environment and runner** (lines 41-60):
```sh
newenv() { E_ROOT=$WORK/$1; E_HOME=$E_ROOT/home; E_CODEX=$E_HOME/.codex; ... : > "$E_LOG"; }
run_inst() {
  _pv=$1
  shift
  env HOME="$E_HOME" CODEX_HOME="$E_CODEX" PATH="$_pv" FAKE_CODEX_LOG="$E_LOG" sh "$INSTALLER" "$@" > "$WORK/out" 2> "$WORK/err"
  RC=$?
}
```
Use `run_inst "$WITH_CODEX" --with-local` and `run_inst "$NO_CODEX" ...`.

**TOML assertion helper to mirror as `lsum`** (`tsum`, lines 73-83; template in RESEARCH lines 590-600): same `python3 -I -c 'import tomllib ...'` shape, reading `d["mcp_servers"]["bbj-local"]`. Guard with `HAVE_TOML` like existing gates.

**Real-codex parse** (`real_parse`, lines 95-115). Parameterise by server name (`mcp get bbj-docs` -> `mcp get "$srv"`), add `real_codex_parses_bbj_local`.

**Fake server start** (copy from `tests/test_tier2_fake.sh` lines 12-42, `start_fake`/`stop_fake` with the `cleanup` trap, because `lib.sh` has none):
```sh
start_fake() {
  PORTF=$WORK/port.$1
  LOGF=$WORK/req.$1.log
  : > "$LOGF"
  rm -f "$PORTF"
  python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &
  FAKE_PID=$!
  ...
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:$(cat "$PORTF")/mcp
  export BBJ_LOCAL_MCP_URL
}
```
Request-shape assertions: reuse the Python log-checker style at `test_tier2_fake.sh` lines 71-98 (template at RESEARCH lines 603-610).

**Gotchas for existing aggregates:** do not `note_cfg` local-run configs (`check_tools_never_named` forbids the three check-tool names in every config in `written.list`); add a separate gate asserting they appear only under `[mcp_servers.bbj-local.tools.*]`. `lib.sh:30` already exports a dead `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`, so existing cases stay hermetic. The full 20-gate inventory is in RESEARCH lines 691.

**Fake binaries:** `tests/fake-bin/curl` logs args to `$FAKE_CURL_LOG` and exits 7 (use for the flag-set assertion and for "no answer"); `tests/fake-bin/codex` logs `mcp add NAME --url URL` calls to `$FAKE_CODEX_LOG` (assert no `mcp add bbj-local` line).

---

### `tests/test_static_guards.sh` (test, batch)

**Analog:** itself. Extract the curl scan (lines 71-83) into a function and also call it in the `codex/*.sh` loop (lines 108-133), so the probe's one-line curl is covered. Do NOT add the URL-literal scan to the installer (the default docs URL is https). The scan body to reuse:
```sh
  curls=$(printf '%s\n' "$body" | grep -E '(^|[;&|(`[:space:]])curl([[:space:]]|$)' | grep -v 'command -v')
  ...
    nosafe=$(printf '%s\n' "$curls" | grep -v -e '--noproxy' | head -n 1)
    noproto=$(printf '%s\n' "$curls" | grep -v -e '--proto =http' | head -n 1)
    redirect=$(printf '%s\n' "$curls" | grep -E -e '[[:space:]](-L|--location[a-z-]*|-[A-Za-z]*L[A-Za-z]*)([[:space:]]|$)' | head -n 1)
```
Gate names follow `static_curl_call_$(basename "$f")`.

---

### `tests/test_install_pages.sh` (test, batch) - LOCAL-06

**Analog:** itself. New phrase assertions use the existing helpers (lines 27-47):
```sh
need() {
  if grep -qF -e "$3" "$2"; then gate "$1_has_$(slug "$3")" ok "$3"
  else gate "$1_has_$(slug "$3")" FAIL "$2 lacks: $3"; fi
}
```
Add `need` lines for `recommended where BBjServices 26.03` and `PREFIX, classpath and config` on both pages, plus `--with-local` and the three `[mcp_servers.bbj-local.tools.<tool>]` headers on the Codex page, plus a small README block (`## Skills`, `PREFIX, classpath and config`). Existing phrases listed in RESEARCH lines 483-484 must survive (for example Codex page must not say "was tested with Codex").

---

### `codex/AGENTS-snippet.md` (doc) - D-07

**Analog:** itself. Replace lines 23-25 (the `Check:` paragraph) with the marker-delimited block (RESEARCH lines 426-434), then one outside-block sentence. Keep line 21 (`Built in: no USE needed.`) because `snippet_shape` and `first_prints_snippet_and_trust` read it. The block must contain no line of the form `- \`bbj_...\`:`, because `tools_list_single_source` reads `- \`bbj_x\`:` bullets (lines 8-13 are the form to avoid). Use numbered items. Keep the file under 60 lines.

### Both `SKILL.md` files (doc) - D-06

**Analog:** the files' own head. Insert after the closing `---` (line 4): blank line, the identical block, blank line, then the existing H1 (line 6, `# BBj Programming (general language)`). Do not touch the existing `bbjcpl` section (~line 353, D-08).

---

### Docs, manifests, notices (wording)

Edit lines listed in RESEARCH "Stop-vendoring touch list" (lines 240-264); grep-zero command at RESEARCH lines 271-275. Landing spots for D-13/D-14 are in RESEARCH lines 473-476 (Claude page: new `## 3. Enable the local check (recommended where BBjServices 26.03+ runs)`, moved from the paragraph at lines 37-44; Codex page: new step 2 with `--with-local`, block, probe, manual removal). Sequence the docs plan after the stop-vendoring and installer plans (shared files).

## Shared Patterns

### Loopback-only HTTP with curl
**Source:** `plugins/bbj/scripts/bbj-check.sh` lines 86-95, 106
**Apply to:** the installer probe; enforced by `tests/test_static_guards.sh` curl scan
Flag set: `-q -sS -g --noproxy '*' --proto =http`, no `-L`, one line, refused URLs never reach curl.

### Exit codes and messages in the installer
**Source:** `codex/install-codex.sh` lines 66-75 (`say`, `refuse`), 335/341 (`pending=1`)
**Apply to:** every new installer path. Exit 0 done, 2 refusal before the first write, 3 merge by hand. Probe results are `say` lines and never alter the exit code.

### Test gate protocol
**Source:** `tests/lib.sh` (`gate NAME ok|FAIL|skip DETAIL`, `mkwork`, `finish`); Python mirror in `tests/test_layout.py` lines 26-30
**Apply to:** all new and changed tests. Header comment names plan and decision IDs and states "Nothing here runs BBj".

### Forbidden words assembled from pieces
**Source:** CLAUDE.md convention (`OIDC_PERMISSION = "id" + "-token"` in `tests/test_ci_guards.py`)
**Apply to:** `tests/test_check_order.py` and the new layout gates.

### In-place config rewrite
**Source:** `codex/install-codex.sh` lines 379-441 (`mktemp` + awk + `cat "$tmp" > "$config"`, no `sed -i`, one-time `config.toml.bbj-backup` at 310-314)
**Apply to:** the `bbj-local` pass; the backup is one shared file written once.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| Check-order block text | doc | n/a | No existing shared pinned text; use RESEARCH candidate (lines 426-434) |
| `tools/list` handling in `tests/fake_mcp.py` | fixture | request-response | Fake only answers `tools/call` today; extend in the shape of `body_for` |
| Probe message wording | installer output | n/a | No prior probe; follow RESEARCH lines 381-385 and the `say "<server>: ..."` style |

## Metadata

**Analog search scope:** `codex/`, `tests/`, `plugins/bbj/scripts/`, `plugins/bbj/skills/*/SKILL.md` heads, `tests/fake-bin/`
**Files read:** CONTEXT.md, RESEARCH.md (full), `tests/test_layout.py`, `tests/fake_mcp.py`, `codex/install-codex.sh` lines 50-449, `plugins/bbj/scripts/bbj-check.sh` lines 80-119, `tests/test_tier2_fake.sh` lines 1-110, `tests/test_static_guards.sh` lines 60-137, `codex/AGENTS-snippet.md`, `tests/test_install_codex.sh` lines 1-110, `tests/test_install_pages.sh` lines 1-60, `tests/fake-bin/{curl,codex}`
**Not re-read:** `install-codex.sh` lines 450-527 (skills copy, hooks, snippet printing; unchanged by this phase except the hint line)
**Pattern extraction date:** 2026-10-09
