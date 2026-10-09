# Testing Patterns

**Analysis Date:** 2026-10-09

## Test Framework

**Runners:**
- POSIX shell: each `tests/test_*.sh` runs under `sh` (dash on Linux; the exit-contract test also runs bash and busybox sh when installed). No test framework library is used.
- Python: each `tests/test_*.py` runs under `python3 -I` (isolated mode). Stdlib only (`json`, `os`, `subprocess`, `hashlib`, `re`, `sys`).
- Orchestrator: `tests/run.sh` runs every shell and Python test and prints a summary.
- Entry point for CI and local use: `tests/ci.sh`, which runs `tests/run.sh`, then `claude plugin validate --strict`, then `shellcheck -s sh`.

**Assertion Library:**
- None. Each check calls `gate NAME STATUS DETAIL` (shell, defined in `tests/lib.sh` and `tests/ci.sh`) or `gate(name, ok, detail)` (Python, defined per file).

**Gate protocol:**
- Output lines begin with `gate `. Status is `ok`, `FAIL` or `skip`.
- `tests/run.sh` counts gates by status and prints `SUMMARY: ok=N fail=M skip=K`.
- A test exits non-zero if any gate printed `FAIL`. A `skip` never fails a run, except that under `CI=true` a missing python3, claude CLI or shellcheck is a `FAIL`.

**Run Commands:**
```bash
sh tests/run.sh                          # every self-contained test (what most contributors run)
sh tests/test_exit_contract.sh           # one shell test
python3 -I tests/test_layout.py          # one Python test
sh tests/ci.sh                           # full CI equivalent: run.sh + claude plugin validate + shellcheck
CI=true sh tests/ci.sh                   # CI mode: missing claude or shellcheck is a failure
shellcheck -s sh plugins/bbj/scripts/bbj-check.sh   # lint a single script (config from .shellcheckrc)
```
- Watch mode: not used.
- Coverage: no tool. Coverage is by gate inventory, not by line count.

**Real-BBj tests:**
- `tests/test_real_compiler.sh` and `tests/test_tier2_live.sh` run only when a real BBj installation or a running loopback `bbj-ls` is present; otherwise they `skip`. Set `BBJ_TEST_HOME` to point at an installation.
- `BBJ_TEST_HOME` defaults to `/opt/bbx` in `tests/test_codex_patch.sh`.

## Test File Organization

**Location:**
- All tests live in the top-level `tests/` directory, separate from the code they test. There are no co-located tests.

**Naming:**
- `test_<area>.sh` or `test_<area>.py`, where `<area>` names the behavior under test: `test_exit_contract.sh`, `test_discovery.sh`, `test_never_execute.sh`, `test_static_guards.sh`, `test_tier2_fake.sh`, `test_tier2_live.sh`, `test_real_compiler.sh`, `test_codex_patch.sh`, `test_install_codex.sh`, `test_install_pages.sh`, `test_claude_plugin.sh`, `test_hook_review_fixes.sh`, `test_ci_gates.sh`, `test_layout.py`, `test_ci_guards.py`.

**Support files:**
- `tests/lib.sh`: shared helpers (`gate`, `finish`, `mkwork`, `json_escape`, `claude_payload`, `codex_payload`, `run_check`). Sourced by every shell test.
- `tests/run.sh`: runner. `tests/ci.sh`: CI entry point.
- `tests/fake-bin/`: fake executables: `bbj`, `bbjcpl`, `codex`, `curl`, `cygpath`.
- `tests/fake_mcp.py`: stdlib HTTP server that imitates the bbj-ls MCP endpoint for tier-2 tests. Started with `--port-file`, `--log`, `--mode`.

**Structure:**
```
tests/
├── lib.sh                  # shared helpers, hermetic env
├── run.sh                  # runs all tests, prints SUMMARY
├── ci.sh                   # CI entry point
├── fake-bin/               # fake bbj, bbjcpl, codex, curl, cygpath
├── fake_mcp.py             # fake loopback MCP server
├── test_*.sh               # shell tests (fake compiler, never-execute, static, installer, ...)
└── test_*.py               # python tests (layout, CI guards)
```

## Test Structure

**Shell suite layout (typical file):**
```sh
#!/bin/sh
# tests/test_exit_contract.sh -- plan 19-01 Task 3: the exit-code contract (D-12). ...
. "$(dirname "$0")/lib.sh"
mkwork

mkdir -p "$WORK/home/bin" "$WORK/proj"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
export BBJ_HOME FAKE_LOG

# contract SHELLNAME CASE: exit 0 or 2, empty stdout, no marker file
contract() {
  if { [ "$RC" = 0 ] || [ "$RC" = 2 ]; } && [ ! -s "$WORK/stdout" ]; then
    gate "contract_$1_$2" ok "exit $RC, stdout empty"
  else
    gate "contract_$1_$2" FAIL "exit $RC, stdout $(wc -c < "$WORK/stdout") bytes"
  fi
}
```
Then the test drives the script with `run_check`, asserts through `contract` or inline `if`, and emits gates. Gate names are built from the case name so a failure names the exact input.

**Patterns:**
- Setup: `mkwork` creates `$WORK` with a `trap` cleanup; create fixtures inside `$WORK`; copy fake binaries from `$REPO/tests/fake-bin/` into a temporary home.
- Drive the hook: build a JSON payload with `claude_payload TOOL FILE CWD` or `codex_payload CWD PATCH`, then `run_check "$payload"`. `run_check` sets `RC` and writes `$WORK/stdout` and `$WORK/stderr`.
- Teardown: `mkwork` installs `trap 'rm -rf "$WORK"' EXIT`. Tests that start background processes (`test_tier2_fake.sh`) add their own cleanup function that kills the PIDs before removing `$WORK`.
- Restore globals changed mid-test: `PATH=$_save`, `unset FAKE_EXIT`.

**Python suite layout (typical file):**
```python
"""tests/test_layout.py -- plan 19-03: pins every manifest value the requirements fix. ..."""
import json
import os
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))

failed = False

def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate layout_%s %s %s" % (name, "ok" if ok else "FAIL", detail))

market = load(".claude-plugin/marketplace.json")
gate("marketplace_entries", market.get("name") == "basis-bbj" and ..., "name=%r ..." % (...))
```
- One module docstring per file names the plan, the locks, the run command, and the output format.
- Assertions are grouped by manifest or artifact; each group has one gate with a `%r`-formatted detail that shows the actual value.
- Exit with `sys.exit(1 if failed else 0)`.

**Setup and teardown in Python:**
- Read-only: tests load repository files with `json.load` or `open(..., encoding="utf-8")` and never write into the repo.
- Mutation checks: the optional `argv[1]` lets a harness point the test at a copied tree with one file changed, to prove the gate fails.

## Mocking

**Approach:** Replace the real external program with a fake that logs its arguments. Never run BBj.

**Fake compiler (`tests/fake-bin/bbjcpl`):**
- Appends `CALL`, one line per argument, and `ARG0 <$0>` to `$FAKE_LOG`.
- Prints `$FAKE_OUT` on stderr and `$FAKE_STDOUT` on stdout when set.
- Exits with `${FAKE_EXIT:-0}` so tests can simulate a crash (`FAKE_EXIT=139`).
- Copy it into a temporary home for each case (`mkhome` in `tests/test_discovery.sh`), so the logged `ARG0` shows which install ran.

**Example from `tests/test_discovery.sh`:**
```sh
mkhome() {
  mkdir -p "$WORK/$1/bin"
  cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/$1/bin/${2:-bbjcpl}"
  chmod 755 "$WORK/$1/bin/${2:-bbjcpl}"
}
PATH=$WORK/D/bin:$BASEPATH
```
Control the search order by setting `PATH`, `BBJ_HOME`, `BBJHOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME` and `BBJ_CHECK_DEFAULT_HOMES` explicitly.

**Fake curl (`tests/fake-bin/curl`) and fake codex (`tests/fake-bin/codex`):**
- Used by `tests/test_tier2_fake.sh` and `tests/test_install_codex.sh`. Fake curl is placed first on `PATH` to observe the exact arguments the hook passes (`--noproxy`, `--proto =http`, no redirect flag).

**Fake MCP server (`tests/fake_mcp.py`):**
- Started in the background per mode: `python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &`.
- The test waits for the port file, then points `BBJ_LOCAL_MCP_URL` at it. The server logs each request so the test can check headers and the JSON body.

**Environment isolation:**
- `tests/lib.sh` clears BBJ env vars, sets `BBJ_CHECK_DEFAULT_HOMES=` (empty), and points `BBJ_LOCAL_MCP_URL` at `http://127.0.0.1:9/mcp` (closed port). A test must opt in to a real endpoint.
- Installer tests run in a temporary `HOME` and `CODEX_HOME` so the developer's real `~/.codex` and `~/.agents` are never touched.

**What to Mock:**
- The BBj compiler (`bbjcpl`, `bbjcplw`) and BBj installation directories.
- The `bbj-ls` loopback MCP server (use `fake_mcp.py`).
- `curl` when a test must check the arguments, not the network.
- The `codex` CLI for installer tests.
- The `claude` CLI is not mocked; `tests/ci.sh` calls the real one when present.

**What NOT to Mock:**
- The file system: tests create real files and directories under `$WORK`, including unreadable files (`chmod 000`), symlinks, and hostile file names with `$()`, backticks, `;`, quotes, globs, and newlines.
- The shell under test: tests execute the real script under each available shell (`dash`, `bash`, `busybox sh`).
- The manifests and lockfile: Python tests read the real JSON files.

## Fixtures and Factories

**Payload builders (in `tests/lib.sh`):**
```sh
claude_payload() {
  # claude_payload TOOL FILE CWD  (key order as captured from Claude Code 2.1.294)
  ...
}
codex_payload() {
  # codex_payload CWD PATCH_TEXT
  ...
}
```
- Payloads are captured from real tool output and key order is kept as captured. Do not reorder keys in fixtures.
- `json_escape` escapes backslash, quote, tab, CR and newline for embedding values in JSON strings.

**Hostile fixtures:**
- Defined once in `tests/test_exit_contract.sh` as `HOSTILE_ONE`, a newline-separated list of names containing `$(...)`, backticks, `;`, quotes and apostrophes. Create each with `: > "$WORK/proj/$n"` under `IFS=$NL` and restore `IFS=$OLDIFS` afterwards.

**Location:**
- Fixtures are generated inside `$WORK` at run time. No fixture files are committed under `tests/`.
- Static fixtures for installers (for example the Codex snippet) live in the repo and are read by path from `$REPO`.

## Coverage

**Requirements:** None enforced by tooling. Coverage is judged by gate inventory: each requirement ID (`PLUG-01`, `PLUG-03`, `PLUG-04`, `D-11`, `D-12`, `D-14`, `D-15`) should map to at least one gate.

**View coverage:** There is no coverage command. To audit gate coverage for a requirement, grep the test files:
```bash
grep -rn "D-12" tests/
```

## Test Types

**Unit-style shell tests (most of the suite):**
- Exercise one script in isolation with fakes: `test_exit_contract.sh`, `test_discovery.sh`, `test_codex_patch.sh`, `test_tier2_fake.sh`, `test_hook_review_fixes.sh`.
- Check exit codes, stdout emptiness, stderr grammar, and argv passed to the fake compiler.

**Static analysis tests:**
- `tests/test_static_guards.sh` scans `plugins/bbj/scripts/*.sh` with comment lines removed. Forbidden patterns live in the test file, never in the script under test, so the script's own comments may describe them.
- Checks: every compiler call has `-N`; every URL literal is loopback; every `curl` has `--noproxy` and `--proto =http` and no redirect flag; no `eval` and no `[[` bashisms in shipped code (`tests/test_static_guards.sh` scans for both). `set -e` is avoided by convention, not by a gate.
- `tests/test_never_execute.sh` checks that the hook never runs file content.
- `tests/test_ci_guards.py` reads `.github/workflows/ci.yml` and `.github/dependabot.yml` by line scan and enforces SHA pinning, read-only `contents`, `persist-credentials: false`, no secret reference, no privileged trigger, and the claude CLI lockfile install.

**Manifest and integrity tests (Python):**
- `tests/test_layout.py`: marketplace entries, plugin versions (`0.1.0` everywhere), license, `.mcp.json` shape, `userConfig` keys, the `PostToolUse` matcher `Write|Edit` and the exact hook command.

**Installer tests:**
- `tests/test_install_codex.sh` (about 700 lines, the largest test) and `tests/test_install_pages.sh` run `codex/install-codex.sh` in a temp home with a fake codex. They check each exit code (0, 2, 3), backups, managed-block markers, idempotent reruns, and the refusal paths.

**CI-gate tests:**
- `tests/test_ci_gates.sh` and `tests/test_claude_plugin.sh` check that the CI wiring is right (for example `claude plugin validate --strict` runs on the marketplace root and both plugins).

**Real-compiler tests:**
- `tests/test_real_compiler.sh` runs the real `bbjcpl -t -N -X` against a fixture file when BBj is present; otherwise a `skip` gate. This is the only test that can execute a BBj tool.

**E2E Tests:** Not used. Claude Code and Codex integration was verified by hand, and the results are recorded in the header comments of `codex/install-codex.sh` and the docs.

## Common Patterns

**Gate-per-case loop:**
```sh
for n in $HOSTILE_ONE; do
  run_check "$(claude_payload Write "$WORK/proj/$n" "$WORK/proj")"
  contract "$_sn" "hostile_$(printf '%s' "$n" | tr -c 'A-Za-z0-9\n' '_' | cut -c 1-12)"
done
```
Build the gate name from the case so each row reports separately. Use `tr -c` to sanitize names.

**Asserting a value exactly once in a log:**
```sh
if [ "$(grep -cFx -- "$WORK/proj/$n" "$FAKE_LOG")" = 1 ]; then
  gate "argument_$_sn" ok "one absolute argument for $n"
else
  gate "argument_$_sn" FAIL "target $n not passed exactly once"
fi
```
Use `grep -F` (fixed string) and `-x` (whole line) when the expected value contains regex metacharacters.

**Async / background process testing:**
```sh
python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &
FAKE_PID=$!
FAKE_PIDS="$FAKE_PIDS $FAKE_PID"
```
Wait for the port file to appear before using the URL; kill every recorded PID in the cleanup trap.

**Error-path testing:**
```sh
run_check 'not json'
contract "$_sn" not_json
```
Feed garbage stdin, an empty `PATH`, a crashing compiler (`FAKE_EXIT=139`), an unreadable file, and a truncated payload. Every error path must exit 0 or 2 with empty stdout.

**Static-scan self-exclusion:**
- Forbidden words are assembled from pieces inside the test file (`"id" + "-token"`, `"pull_request" + "_target"`, `"secrets" + "."` in `tests/test_ci_guards.py`) so that the scanner does not match its own source.

**Mutation checks:**
- Point a Python test at a copy of the repository with one field changed (optional `argv[1]`) and confirm it fails. Use this when adding a new locked value.

## Adding a New Test

1. Pick the matching area and file name (`test_<area>.sh` or `.py`); `tests/run.sh` discovers it automatically.
2. For shell: start with `#!/bin/sh`, add a header comment with the plan/requirement ID and "Nothing here runs BBj", source `lib.sh`, call `mkwork`.
3. Put fakes in `$WORK`; never call a real `bbj`, `bbjcpl`, or `codex` outside a `skip`-guarded opt-in test.
4. Emit one `gate` line per assertion with a unique name prefix and a detail that shows the actual value.
5. End with `finish` (shell via `lib.sh`) or `sys.exit(1 if failed else 0)` (Python).
6. Run `sh tests/run.sh` and then `sh tests/ci.sh`; both must print no `FAIL` gate.
7. Run `shellcheck -s sh` on the new file. Add an inline `# shellcheck disable=SCxxxx  # reason` only for a deliberate case.

## Gaps

- No tests run on Windows or macOS hosts; the cygpath path conversion in `bbj-check.sh` is exercised only with the fake `tests/fake-bin/cygpath` (used by `tests/test_discovery.sh` and `tests/test_install_codex.sh`).
- The Codex payload shape is documentation-derived and has no captured fixture yet; tests use synthetic payloads (`codex_payload`).
- Skill content is covered by `tests/test_layout.py` (hosted host named only in `plugins/bbj/.claude-plugin/plugin.json`, no executable files); the check-order block is pinned by `tests/test_check_order.py` (plan 01-05). No test checks the semantic accuracy of skill references.

---

*Testing analysis: 2026-10-09*
