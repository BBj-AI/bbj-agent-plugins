# Phase 3: Example gate and structure lints - Pattern Map

**Mapped:** 2026-10-10
**Files analyzed:** 5 (3 new, 1 possibly modified, 1 reused unchanged)
**Analogs found:** 5 / 5 (all analog paths verified git-tracked with `git ls-files`)

Core design fact: `python3 -I` drops the script directory from `sys.path`, so the lint, live
runner and report mode live in ONE file (`tests/test_skill_examples.py`). No helper module can be
imported. `tests/run.sh` discovers `tests/test_*.py` (loop at line 25, run as `python3 -I`, lines
~25-33) and counts lines starting `gate ` by field 3 (`ok|FAIL|skip`), so no runner edit is needed.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `tests/test_skill_examples.py` (lint half) | test | transform (Markdown text -> violations -> gate lines) | `tests/test_check_order.py` (Python shape, ROOT arg, gate lines) + `tests/test_layout.py` | role-match |
| `tests/test_skill_examples.py` (live half) | test | request-response (subprocess `bbjcpl`; loopback JSON-RPC) | `tests/test_real_compiler.sh` + `tests/test_tier2_live.sh` (skip/strict pattern) and `plugins/bbj/scripts/bbj-check.sh` (request shape) | role-match (different language) |
| `tests/test_skill_examples.py` (CI-side fixtures for live plumbing) | test | request-response with fakes | `tests/fake-bin/bbjcpl`, `tests/fake_mcp.py`, `tests/test_install_codex.sh` `start_fake` | exact (reuse) |
| `tests/skills_baseline.json` | config/data | batch (written by `--report`, read by gates) | none in repo (shape in 03-RESEARCH.md "Proposed baseline JSON"); JSON style per `tests/test_layout.py` `load()` | no analog |
| `.planning/phases/03-.../03-BASELINE.md` | doc/report | batch (generated) | none | no analog |
| `tests/ci.sh` (header comment only, optional) | config | n/a | its own header, lines 7-12 | exact |

## Pattern Assignments

### `tests/test_skill_examples.py` (test, transform + request-response)

**Analog:** `tests/test_check_order.py` (primary), `tests/test_layout.py` (secondary)

**Docstring and header** (test_check_order.py lines 1-13): module docstring names plan and
decision IDs, what is locked, "stdlib only, run by tests/run.sh with python3 -I", the exact
output grammar, the optional `argv[1]` root, and ends "Nothing here runs BBj code." Copy that
shape, naming GATE-01..06 and D-01..D-20.

**Imports and ROOT** (test_check_order.py lines 14-19; test_layout.py lines 11-18). Stdlib,
one per line, alphabetical:
```python
import os
import re
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))
```
Add `json`, `subprocess`, `tempfile`, `urllib.error`, `urllib.request`. Careful: this file also
needs a `--report` flag, so parse `sys.argv` for `--report` before taking `argv[1]` as the root
(root stays optional positional so mutation checks can point at a repo copy). Use nothing newer
than Python 3.12, no f-strings, `%`-formatting.

**Gate helper and failure flag** (test_check_order.py lines 40-47). The module-level `failed`
and `global failed` convention; this file needs a 3-state status (`ok|FAIL|skip`), so use the
research variant, prefix `skills_`:
```python
failed = False

def gate(name, status, detail=""):
    global failed
    if status == "FAIL":
        failed = True
    detail = re.sub(r"[^\x20-\x7e]", "?", detail)   # skills contain U+2014; C-locale safety
    print("gate skills_%s %s %s" % (name, status, detail))
```
Gate names must contain no spaces (run.sh counts `$3`). Per-block detail lines that are NOT
gates must not start with `gate ` (run.sh echoes them uncounted: use for the pending to-do list).

**Forbidden-string assembly** (test_check_order.py lines 30-38; test_layout.py lines 25-29).
The six GATE-05 denylist strings are required in the test only. Several are plain words, but keep
to the convention where a scan could match this file; ALSO this file must not contain the two
spellings `tests/test_layout.py` scans `tests/*.py` for (lines 26-27: `"skills" + ".lock.json"`,
`"test_sk" + "ills_hash"`). Do not write those two names literally.
```python
QUALIFIED = "mcp" + "__"
HOST = "mcp.bbj" + "-ai.com"
```

**File reading** (test_check_order.py lines 50-56): exact bytes, explicit utf-8, `None` when
unreadable:
```python
def read_lines(rel):
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            return f.read().decode("utf-8").split("\n")
    except (OSError, ValueError):
        return None
```
Skip symlinks when walking skill dirs (project convention).

**Mutation-friendly structure** (test_check_order.py lines 98-123): per-file loops produce one
gate per item with an `"... ok"` detail when fine and the offending value when not. The research
document (03-RESEARCH.md Patterns 1-5, Code Examples "Frontmatter description", "Live route
detection") already contains the fence extractor, `kind_of`, `cpl_records`, `ls_call`,
`ls_verdict`, `decide` and `description_of`; use them as the implementation of the pure
functions. Do not re-derive them.

**Core live-route patterns to take from the real analogs:**

1. `bbjcpl` home discovery and skip (`tests/test_real_compiler.sh` lines 7-11):
```sh
BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}
if [ ! -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then
  gate real_compiler skip "no executable $BBJ_TEST_HOME/bin/bbjcpl on this host"
  exit 0
fi
```
Python equivalent: `os.environ.get("BBJ_TEST_HOME", "/opt/bbx")` + `os.access(path, os.X_OK)`.

2. Real compiler argv and record format (test_real_compiler.sh line 157): the control call is
`"$BBJ_TEST_HOME/bin/bbjcpl" -t -N -X "$FIX/config.bbx" < /dev/null 2>&1`. Records: `error at
line 10 (1)` and `type check error [No match for method ...]` (lines 27, 74). Python: argv list,
`CPL_ARGS = ["-t", "-N", "-X"]`, `stdin=subprocess.DEVNULL`, `stderr=subprocess.STDOUT`, a
`timeout=`, `shell=False`, cwd an empty temp dir. Exit code is always 0 (do not use it).

3. Strictness env var pattern (`tests/test_tier2_live.sh` lines 8-25): probe GET, expect 405;
unreachable is `skip`, but with the opt-in env var it is FAIL. Replace `BBJ_LS_LIVE` with
`BBJ_SKILLS_LIVE` and apply it to EITHER missing route (D-13); under `CI=true` without
`BBJ_SKILLS_LIVE=1` it stays skip.
```sh
code=$(... curl -s -o /dev/null -w '%{http_code}' --connect-timeout 1 "$LIVE_URL" ...)
if [ "$code" != 405 ]; then
  if [ "${BBJ_LS_LIVE:-}" = 1 ]; then
    gate live_server FAIL "BBJ_LS_LIVE=1 but $LIVE_URL answered '$code' (want 405)"
```
Default URL `http://127.0.0.1:5009/mcp` (line 15; env `BBJ_LOCAL_MCP_URL`).

4. `bbj_check_syntax` request, byte-identical to the hook
(`plugins/bbj/scripts/bbj-check.sh` lines 261 and 263):
```sh
_body='{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"bbj_check_syntax","arguments":{"code":"'"$_code"'"},"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
... curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' ...
```
Python rules to mirror `--noproxy '*'`, `--proto =http`, no `-L`: `ProxyHandler({})`, a
`HTTPRedirectHandler` whose `redirect_request` returns `None`, a loopback URL regex, 12 s timeout.
Verdict is read from reply TEXT (`No errors found.` = pass; `^line N, column M:` = fail; anything
else, `isError` true, HTTP error, JSON-RPC error = route failure, never a block verdict) so the
same parser reads the real server and `tests/fake_mcp.py`.

**Self-guard gates required** (no static guard covers `tests/*.py`; `test_static_guards.sh` scans
only `plugins/bbj/scripts/*.sh` and `codex/*.sh`): assert `CPL_ARGS` equals `-t -N -X`; assert
every call logged by the fake compiler carries `-t`, `-N`, `-X` as separate args then only
absolute `.bbj` paths; assert a non-loopback URL is refused with no connection; assert a 302 is
not followed.

**CI-side fakes to reuse (no edits):**

- `tests/fake-bin/bbjcpl` (whole file, 13 lines): logs `CALL`, one arg per line, `ARG0 <$0>` to
  `$FAKE_LOG`; prints file `$FAKE_OUT` on stderr; exits `${FAKE_EXIT:-0}`. Copy it into a temp
  `home/bin/bbjcpl`, `chmod 755`, point `BBJ_TEST_HOME` at that home. Pattern (test_real_compiler.sh
  lines 163-170):
```sh
mkdir -p "$WORK/fakehome/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/fakehome/bin/bbjcpl"
chmod 755 "$WORK/fakehome/bin/bbjcpl"
FAKE_LOG=$WORK/skip.log
```
  Use `FAKE_OUT` for canned multi-line records (Pitfall 1) and a stray-line case. The real batch
  has no per-record exit code, so a fake with `FAKE_OUT` empty models "all clean" and exercises the
  canary (bad canary without a record = route broken).
- `tests/fake_mcp.py` (lines 1-40 docstring, 152-160 main): `python3 -I tests/fake_mcp.py
  --port-file F --log L --mode MODE`, binds 127.0.0.1 on a free port, writes the port to
  `--port-file`. Modes: `clean`, `one-error`, `rpc-error`, `garbage`, `is-error`, `empty`,
  `no-verdict`, `sse`. Launch from the Python test with `subprocess.Popen([sys.executable, "-I",
  <abs path>, ...])`, poll the port file, then pass `http://127.0.0.1:<port>/mcp`. See
  `tests/test_install_codex.sh` `start_fake` (line 1102, sets `FAKE_PID`, `LOGF`,
  `BBJ_LOCAL_MCP_URL`) for the shell version of launch and cleanup. Its replies carry no
  `structuredContent`, confirming the verdict must come from `content[0].text`.
- Hermetic CI view of the lint: run with `BBJ_TEST_HOME=/nonexistent
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp` (tests/lib.sh exports the same hermeticity only to sh
  tests; the Python test inherits the invoker's environment, so honour these env vars explicitly).

**Error handling pattern:** every route failure and every unreadable file is a gate line, never
a traceback; wrap I/O in `except (OSError, ValueError)` like `read_lines`; end with
`sys.exit(1 if failed else 0)` (test_check_order.py line 145).

---

### `tests/skills_baseline.json` (data, batch)

**Analog:** none for content. Format conventions: 2-space JSON indent (CLAUDE.md); read via a
loader that tolerates absence the way `tests/test_layout.py` `load()` does (lines 41-46: returns
`{"__error__": ...}` on failure, so a missing or broken baseline becomes a gate FAIL, not a
crash). Layout is proposed in 03-RESEARCH.md ("Proposed baseline JSON"): `bbj_version`,
`recorded`, `nocheck`, `pending.<skill>.{phase, counts{grammar,structure,bbjcpl,bbj-ls}}`.
Written only by `--report`; never hand-edit counts. `nocheck` records 0 (research Open Question 1).

---

### `.planning/phases/03-example-gate-and-structure-lints/03-BASELINE.md` (report, batch)

**Analog:** none. Generated by the same `--report` code path. One section per skill; one line per
failing block `file:line` plus first error line; every lint violation; header records BBj
version (from `bbj-ls` `bbjVersion`, else "unknown") and date, and states error text may vary
between runs (Pitfall 2). Gates never compare this text.

---

### `tests/ci.sh` (optional, header comment only)

**Analog:** itself, lines 7-12. If touched, add the new test to the step 1 list in the comment
(the list reads "every self-contained test (fake compiler, ..., layout, install pages, CI
guards)"). Do not change code lines. Step 3 (shellcheck) covers only `tests/*.sh`, so a
Python-only implementation adds no shellcheck surface.

## Shared Patterns

### Gate output grammar
**Source:** `tests/lib.sh` lines 47-54 (shell), `tests/test_check_order.py` lines 43-47 (Python)
**Apply to:** every gate in the new file
`gate <prefix>_<name> ok|FAIL|skip <detail>`; prefix `skills_`; no spaces in the name; detail
printable ASCII only.

### Skip-unless-strict
**Source:** `tests/test_tier2_live.sh` lines 8-25; `tests/test_real_compiler.sh` lines 8-11
**Apply to:** the two live routes. Missing route = `skip`; `BBJ_SKILLS_LIVE=1` makes it FAIL.

### Compile-only, loopback-only safety
**Source:** `plugins/bbj/scripts/bbj-check.sh` lines 261-263 (request), CLAUDE.md Conventions
**Apply to:** every compiler and network call. `-N` always; argv list, no shell; block text only
into a file or a JSON body; temp names from a counter (`b0000.bbj`); never `bbj-check.sh`, never
the hosted check.

### Optional `argv[1]` root for mutation checks
**Source:** `tests/test_check_order.py` lines 18-19, `tests/test_layout.py` lines 17-18
**Apply to:** all repo reads (skills dir, baseline). Report writes go only to the two fixed
repo paths (or a given temp root).

### Self-scan avoidance
**Source:** `tests/test_check_order.py` lines 30-35; `tests/test_layout.py` lines 25-29
**Apply to:** any literal another test scans `tests/*.py` for (the lock-file and hash-test names).

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `tests/skills_baseline.json` | data | batch | No committed machine baseline exists; shape from 03-RESEARCH.md |
| `03-BASELINE.md` | report | batch | Generated artifact; no prior generated report |
| Fence extractor / frontmatter parser | utility | transform | Nothing in `tests/` parses Markdown fences; use 03-RESEARCH.md Patterns 1-2 and "Frontmatter description" (closest repo flavor: marker extraction in `test_check_order.py` `markers()`, lines 59-62) |
| Python HTTP client to `bbj-ls` | utility | request-response | Existing callers are `curl` in sh; use research Pattern 4 mirroring the hook's flags |

## Metadata

**Analog search scope:** `tests/`, `plugins/bbj/scripts/`, `.planning/phases/03-*/`
**Files scanned:** about 10 (read: test_check_order.py, test_layout.py (lines 1-80), test_real_compiler.sh, test_tier2_live.sh, fake-bin/bbjcpl, fake_mcp.py (docstring, main), lib.sh (gate/finish/mkwork), run.sh, ci.sh header, bbj-check.sh lines 250-270)
**Tracked-source check:** `git ls-files` confirmed all 8 named analog files are tracked; no gitignored mirror paths appear.
**Pattern extraction date:** 2026-10-10
