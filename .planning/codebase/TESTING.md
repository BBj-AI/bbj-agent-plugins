---
last_mapped_commit: 8530cf7384421303e5895ea3625b8ca192ec9142
last_mapped_at: 2026-10-16
---
# Testing Patterns

**Analysis Date:** 2026-10-16

## Test Framework

**Runners:**
- POSIX shell: each `tests/test_*.sh` runs under `sh` (dash on Linux; the exit-contract test also runs bash and busybox sh when installed). No test framework library is used.
- Python: each `tests/test_*.py` runs under `python3 -I` (isolated mode). Stdlib only (`json`, `os`, `subprocess`, `hashlib`, `re`, `sys`).
- Orchestrator: `tests/run.sh` runs every shell and Python test, prints a summary, and prints the `run_prefix_block` gate after the last file.
- Entry point for CI and local use: `tests/ci.sh`, which runs `tests/run.sh`, then `claude plugin validate --strict`, then `shellcheck -s sh`.

**Assertion Library:**
- None. Each check calls `gate NAME STATUS DETAIL` (shell, defined in `tests/lib.sh` and `tests/ci.sh`) or `gate(name, ok, detail)` (Python, defined per file).

**Gate protocol:**
- Output lines begin with `gate `. Status is `ok`, `FAIL` or `skip`.
- `tests/run.sh` counts gates by status and prints `SUMMARY: ok=N fail=M skip=K` (855 ok, 0 fail, 0 skip at the Phase 14 refresh).
- A test exits non-zero if any gate printed `FAIL`. A `skip` never fails a run, except that under `CI=true` a missing python3, claude CLI or shellcheck is a `FAIL`.
- `run_prefix_block` (MAINT-09, D-14, D-15): after all files `tests/run.sh` checks every gate name against the flat prefix block of `.claude/CLAUDE.md`. It fails on a listed prefix its file did not print, on a gate name under no listed prefix of its own file (the longest prefix wins), on a test file missing from the block or listed twice, on a block file not in `tests/`, and on a `.planning/codebase/CONVENTIONS.md` whose block lines differ from `.claude/CLAUDE.md`. The block itself is not copied here; read it in `.planning/codebase/CONVENTIONS.md` (the source is `.claude/CLAUDE.md`). A file that did not run is not judged.

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
- `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh` and the live routes of `tests/test_skill_examples.py` run only when a real BBj installation or a running loopback `bbj-ls` is present; otherwise they `skip`. Set `BBJ_TEST_HOME` to point at an installation (default `/opt/bbx`). `BBJ_LS_LIVE=1` and `BBJ_SKILLS_LIVE=1` turn a missing route into a `FAIL`.

## Test File Organization

**Location:**
- All tests live in the top-level `tests/` directory, separate from the code they test. There are no co-located tests.

**Naming:**
- `test_<area>.sh` or `test_<area>.py`, where `<area>` names the behavior under test. Every `tests/test_*` file is listed below with what it locks.

| File | What it locks |
|------|---------------|
| `tests/test_check_order.py` | the check-order block that both `SKILL.md` files carry byte for byte, and that step 3 names the docs server `bbj` |
| `tests/test_ci_gates.sh` | under `CI=true` a missing shellcheck or python3 is a failure, outside CI a skip; the `run_prefix_` cases that prove each rule and edge of `run_prefix_block` in scratch repos |
| `tests/test_ci_guards.py` | `.github/workflows/ci.yml` and `.github/dependabot.yml`: SHA pins, read-only token, no secret, no privileged trigger, the claude CLI lockfile install |
| `tests/test_claude_plugin.sh` | the Claude Code plugin end to end: strict validate, install into a throwaway config dir, the OAuth client of the docs server `bbj`, the `hooks.json` command with a space in the plugin path (skips without the claude CLI) |
| `tests/test_codex_patch.sh` | the `apply_patch` branch of the hook and the plugin-route gates (the `hooks.json` command run with a fake Codex plugin cache path) |
| `tests/test_discovery.sh` | where the hook finds BBj and which `-P` list it builds, including Windows drive-letter, backslash and space paths through the fake `cygpath` |
| `tests/test_exit_contract.sh` | the exit contract: only 0 or 2, stdout empty except for the no-route notice, hostile file names reach the compiler as one argument, under each installed shell |
| `tests/test_hook_mutation.sh` | proves that gates of the discovery and tier-2 tests can fail, by mutating a copy of the hook (backslash conversion, `..` check, the tier-2 cache, both halves of the connect-timeout test) |
| `tests/test_hook_review_fixes.sh` | regression gates for review findings on the hook (symlinks, large patches, compiler name) |
| `tests/test_install_pages.sh` | the one install page `docs/install.md` and the README: required phrases per client, the eleven headings, forbidden claims, the plugin `bbj-local` wording, relative links (and the history cut of old CHANGELOG entries), `claude plugin` subcommands, the verified platforms |
| `tests/test_layout.py` | manifests, versions (`0.2.2` in five places), licence, `.mcp.json` and Codex overlay shape, the pinned `commandWindows`, the scans of tracked files (retired route, old server name, removed pages, retired terms, the term list and its definition), and their mutation cases |
| `tests/test_never_execute.sh` | the never-execute proof: no BBj interpreter sentinel appears, every logged compiler call carries `-t -N -X` |
| `tests/test_noroute_notice.sh` | the no-route notice: shape under dash and bash, text, once-per-session marker, when it stays silent, the cases where the route was reached without a verdict |
| `tests/test_path_scrub.sh` | proves that the `PATH` scrub of the no-route tests is load-bearing, by running them with a fake compiler first on `PATH` and from a copy with the scrub disabled |
| `tests/test_real_compiler.sh` | the hook against the real `bbjcpl -t -N -X` (skips without BBj) |
| `tests/test_release_text.py` | the release text: README version, newest CHANGELOG entry sections, the Upgrading addressee, the README cells of the verified platforms (`release_cell_*`), one version per platform |
| `tests/test_release_text_mutation.sh` | proves every gate of `tests/test_release_text.py` can fail, one mutation per gate on a copy of the four files it reads |
| `tests/test_skill_examples.py` | the fenced BBj examples of both skills: fence grammar, structure lints, the `nocheck` ratchet against `tests/skills_baseline.json`, and the live `bbjcpl` and `bbj-ls` routes |
| `tests/test_static_guards.sh` | static scan of `plugins/bbj/scripts/*.sh` with comments removed: `-N` on every compiler call, loopback-only URLs, `curl` flags, no `eval`, no `[[` |
| `tests/test_tier2_fake.sh` | the tier-2 loopback route against `tests/fake_mcp.py` and the fake `curl`: request shape, every fake-server mode, URL rules, the once-per-run no-route cache |
| `tests/test_tier2_live.sh` | tier 2 against a live `bbj-ls` on `127.0.0.1:5009` (skips when unreachable) |

**Support files:**
- `tests/lib.sh`: shared helpers (`gate`, `finish`, `mkwork`, `json_escape`, `claude_payload`, `codex_payload`, `run_check`, `fresh_state`, `notice_text`, `no_compiler_path`, `no_compiler_env`). Sourced by every shell test.
- `tests/run.sh`: runner and `run_prefix_block`. `tests/ci.sh`: CI entry point.
- `tests/fake-bin/`: fake executables: `bbj`, `bbjcpl`, `curl`, `cygpath`.
- `tests/fake_mcp.py`: stdlib HTTP server that imitates the `bbj-ls` MCP endpoint for the tier-2 tests, `tests/test_noroute_notice.sh` and `tests/test_skill_examples.py`. Started with `--port-file`, `--log`, `--mode`.
- `tests/skills_baseline.json`: the baseline (`bbj_version`, `nocheck`, `pending`) of the skill example gate.

**Structure:**

```
tests/
├── lib.sh                  # shared helpers, hermetic env
├── run.sh                  # runs all tests, prints SUMMARY and run_prefix_block
├── ci.sh                   # CI entry point
├── fake-bin/               # fake bbj, bbjcpl, curl, cygpath
├── fake_mcp.py             # fake loopback MCP server
├── skills_baseline.json    # ratchet baseline of test_skill_examples.py
├── test_*.sh               # shell tests (hook, notice, tier 2, static, mutation, CI wiring, install page)
└── test_*.py               # python tests (layout, release text, CI guards, skill examples, check order)
```

## Test Structure

**Shell suite layout (typical file):**

```sh
#!/bin/sh

# tests/test_exit_contract.sh -- plan 19-01 Task 3, amended by plan 02-02 (HOOK-03): the exit-code

# contract (D-12). ...

. "$(dirname "$0")/lib.sh"
mkwork

# ... a project directory and a copy of tests/fake-bin/bbjcpl in a temporary BBj home under $WORK ...

BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
export BBJ_HOME FAKE_LOG
```

Then the test drives the script with `run_check`, asserts through a small helper or an inline `if`, and emits gates. Gate names are built from the case name so a failure names the exact input.

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
- Copy it into a temporary home for each case (`mkhome` in `tests/test_discovery.sh`), so the logged `ARG0` shows which install ran. `tests/fake-bin/bbj` is the fake interpreter that `tests/test_never_execute.sh` puts on `PATH` to prove it is never run.

**Fake curl (`tests/fake-bin/curl`):**
- Used by `tests/test_tier2_fake.sh`, `tests/test_noroute_notice.sh`, `tests/test_path_scrub.sh` and `tests/test_hook_mutation.sh`. Placed first on `PATH` to observe the exact arguments the hook passes (`--noproxy`, `--proto =http`, no redirect flag).
- Seams: `FAKE_CURL_LOG` (argument log), `FAKE_CURL_EXIT` (exit status; default 7, connection refused), `FAKE_CURL_WRITEOUT` (models the `-w` write-out `<time_connect> <remote_ip>` for the `noconn` classification).

**Fake cygpath (`tests/fake-bin/cygpath`):**
- Turns the hook's Windows branch on (`WIN=1`) on a Linux host. `-u` prints its argument unchanged, `-w` prefixes `W:`. The seam `FAKE_CYGDRIVE_ROOT` maps drive-letter paths to a root (used by `tests/test_discovery.sh`).

**Fake MCP server (`tests/fake_mcp.py`):**
- Started in the background per mode: `python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &`.
- Nine modes: `one-error`, `many`, `clean`, `rpc-error`, `garbage`, `is-error`, `empty`, `no-verdict`, `sse`. The `tools/list` request and its modes were removed in Phase 14 (MAINT-10); no test sends it.
- The test waits for the port file, then points `BBJ_LOCAL_MCP_URL` at it. The server logs each request so the test can check headers and the JSON body.

**Test seams of the hook (set by tests, read by `bbj-check.sh`):**
- `BBJ_CHECK_DEFAULT_HOMES` (replaces the built-in default homes), `BBJ_CHECK_STATE_DIR` (directory of the once-per-session marker), `TIER2_TEST_SYSPATH` (read in `tests/test_tier2_fake.sh`; `tests/run.sh` unsets it so a caller's value cannot leak in; only `tests/test_path_scrub.sh` sets it for its nested runs).

**Environment isolation:**
- `tests/lib.sh` clears BBJ env vars, sets `BBJ_CHECK_DEFAULT_HOMES=` (empty), unsets `CLAUDE_PLUGIN_ROOT`, and points `BBJ_LOCAL_MCP_URL` at `http://127.0.0.1:9/mcp` (closed port). A test must opt in to a real endpoint. `mkwork` also points `BBJ_CHECK_STATE_DIR` at `$WORK/state`.
- No-route tests scrub any BBj compiler directory from `PATH` with `no_compiler_path`; `tests/test_path_scrub.sh` proves the scrub is load-bearing.

**What to Mock:**
- The BBj compiler (`bbjcpl`, `bbjcplw`) and BBj installation directories.
- The `bbj-ls` loopback MCP server (use `fake_mcp.py`).
- `curl` when a test must check the arguments, not the network.
- `cygpath` for the Windows branch.
- The `claude` CLI is not mocked; `tests/ci.sh` calls the real one when present.

**What NOT to Mock:**
- The file system: tests create real files and directories under `$WORK`, including unreadable files (`chmod 000`), symlinks, and hostile file names with `$()`, backticks, `;`, quotes, globs, and newlines.
- The shell under test: tests execute the real script under each available shell (`dash`, `bash`, `busybox sh`).
- The manifests and lockfile: Python tests read the real JSON files.

## Fixtures and Factories

**Payload builders (in `tests/lib.sh`):**
- `claude_payload TOOL FILE CWD` (key order as captured from Claude Code) and `codex_payload CWD PATCH_TEXT` (top-level key order captured from Codex CLI 0.162.1, plan 02-05; `turn_id`, `model`, `permission_mode` and `tool_use_id` carry synthetic values).
- Payloads are captured from real tool output and key order is kept as captured. Do not reorder keys in fixtures.
- `json_escape` escapes backslash, quote, tab, CR and newline for embedding values in JSON strings.

**Hostile fixtures:**
- Defined once in `tests/test_exit_contract.sh` as `HOSTILE_ONE`, a newline-separated list of names containing `$(...)`, backticks, `;`, quotes and apostrophes. Create each with `: > "$WORK/proj/$n"` under `IFS=$NL` and restore `IFS=$OLDIFS` afterwards.

**Location:**
- Fixtures are generated inside `$WORK` at run time. The only committed fixture files under `tests/` are the fakes in `tests/fake-bin/`, `tests/fake_mcp.py` and `tests/skills_baseline.json`.

## Coverage

**Requirements:** None enforced by tooling. Coverage is judged by gate inventory: each requirement ID (`PLUG-01`, `PLUG-03`, `PLUG-04`, `D-11`, `D-12`, `D-14`, `D-15`) should map to at least one gate.

**View coverage:** There is no coverage command. To audit gate coverage for a requirement, grep the test files:

```bash
grep -rn "D-12" tests/
```

## Test Types

**Unit-style shell tests (most of the suite):**
- Exercise one script in isolation with fakes: `test_exit_contract.sh`, `test_discovery.sh`, `test_codex_patch.sh`, `test_tier2_fake.sh`, `test_noroute_notice.sh`, `test_hook_review_fixes.sh`.
- Check exit codes, stdout emptiness, stderr grammar, and argv passed to the fake compiler.

**Static analysis tests:**
- `tests/test_static_guards.sh` scans `plugins/bbj/scripts/*.sh` with comment lines removed. Forbidden patterns live in the test file, never in the script under test, so the script's own comments may describe them.
- Checks: every compiler call has `-N`; every URL literal is loopback; every `curl` has `--noproxy` and `--proto =http` and no redirect flag; no `eval` and no `[[` bashisms in shipped code. `set -e` is avoided by convention, not by a gate.
- `tests/test_never_execute.sh` checks that the hook never runs file content.
- `tests/test_ci_guards.py` reads `.github/workflows/ci.yml` and `.github/dependabot.yml` by line scan and enforces SHA pinning, read-only `contents`, `persist-credentials: false`, no secret reference, no privileged trigger, and the claude CLI lockfile install.

**Manifest, text and term tests (Python):**
- `tests/test_layout.py`: marketplace entries, plugin versions (`0.2.2` everywhere), license, `.mcp.json` and Codex overlay shape, the `PostToolUse` matcher `Write|Edit`, the exact `command` and `commandWindows`.
- Scans of the tracked files (git mode, or a walk of a mutation copy; `.planning/` exempt): `layout_no_retired_route`, `layout_no_old_server_name`, `layout_no_removed_pages` (the two former install pages), `layout_no_retired_terms` (the five retired variants of the term list), `layout_term_list` (the term list in `.claude/CLAUDE.md` names all variants and terms) and `layout_term_definition` (`docs/install.md` holds the definition).
- `tests/test_release_text.py`: the release text gates, including the per-cell README gates `release_cell_*` for the verified platforms (Phase 14, DOCS-07) and the version, addressee and section gates of the newest CHANGELOG entry.
- `tests/test_install_pages.sh`: the install page and README; includes `link_history_cut_newer_entry` and `link_history_cut_old_entry` (a link to a missing page fails in a newer CHANGELOG entry and is not checked in a 0.2.1 entry).
- `tests/test_skill_examples.py` and `tests/test_check_order.py` lock the skills.

**CI-gate tests:**
- `tests/test_ci_gates.sh` and `tests/test_claude_plugin.sh` check that the CI wiring is right (for example `claude plugin validate --strict` runs on the marketplace root and both plugins).

**Real-compiler tests:**
- `tests/test_real_compiler.sh` runs the real `bbjcpl -t -N -X` against a fixture file when BBj is present; otherwise a `skip` gate. With `tests/test_skill_examples.py` (its `bbjcpl` route) these are the tests that can execute a BBj tool, always compile-only.

**E2E Tests:** Not used. Claude Code and Codex integration was verified by hand, and the results are recorded in `docs/install.md` and in the run records of the phase directories under `.planning/`.

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

Feed garbage stdin, an empty `PATH`, a crashing compiler (`FAKE_EXIT=139`), an unreadable file, and a truncated payload. Every error path must exit 0 or 2 with stdout empty or holding only the no-route notice.

**Static-scan self-exclusion:**
- Forbidden words are assembled from pieces inside the test file (`"id" + "-token"`, `"pull_request" + "_target"`, `"secrets" + "."` in `tests/test_ci_guards.py`; the removed page names in `REMOVED_PAGES` and the retired variants in `TERM_VARIANTS` of `tests/test_layout.py`) so that the scanner does not match its own source.

**Mutation checks (every gate that locks a value gets one):**
- `tests/test_layout.py`: `mutation_case(name, rels, change, expect)` copies the tree, changes the named files in the copy, runs the layout checks on the copy and requires the named gates to fail; a change that changes nothing is itself a failure. The `layout_mutation_*` cases plant a retired word, old name, removed page or term variant in each scope and each exemption.
- `tests/test_release_text_mutation.sh`: `mutate GATE FILE SEDPROGRAM [CASE]` changes one thing in a copy of the four files the release gate reads and requires that gate to print `FAIL`; includes one case per README cell.
- `tests/test_hook_mutation.sh`: applies one `sed` mutation to a copy of `bbj-check.sh`, runs a nested test from the copy and requires the named gates to fail; the unchanged copy is the control.
- `tests/test_ci_gates.sh`: builds a scratch repo (`scratch`) with a stub test and a fixture `.claude/CLAUDE.md`, and runs `tests/run.sh` there to prove each `run_prefix_*` rule; also proves the CI-mode failure of a missing shellcheck or python3.
- `tests/test_path_scrub.sh`: runs the no-route tests from a copy of `tests/` whose `no_compiler_path` is a no-op and requires them to go red.

## Adding a New Test

1. Pick the matching area and file name (`test_<area>.sh` or `.py`); `tests/run.sh` discovers it automatically.
2. For shell: start with `#!/bin/sh`, add a header comment with the plan/requirement ID and "Nothing here runs BBj", source `lib.sh`, call `mkwork`.
3. Put fakes in `$WORK`; never call a real `bbj` or `bbjcpl` outside a `skip`-guarded opt-in test.
4. Emit one `gate` line per assertion under a prefix no existing gate name starts with, with a detail that shows the actual value. Add the file's block line to `.claude/CLAUDE.md` and the same line, in the same place, to `.planning/codebase/CONVENTIONS.md`; `run_prefix_block` fails otherwise.
5. End with `finish` (shell via `lib.sh`) or `sys.exit(1 if failed else 0)` (Python).
6. Run `sh tests/run.sh` and then `sh tests/ci.sh`; both must print no `FAIL` gate.
7. Run `shellcheck -s sh` on the new file. Add an inline `# shellcheck disable=SCxxxx  # reason` only for a deliberate case.

## Gaps

- No tests run on Windows or macOS hosts; the `cygpath` path conversion in `bbj-check.sh` is exercised only with the fake `tests/fake-bin/cygpath` (used by `tests/test_discovery.sh` and `tests/test_tier2_fake.sh`), and `commandWindows` is pinned as text by `tests/test_layout.py`. The Windows behaviour was observed in hand runs recorded under `.planning/` (13-WINDOWS-RUN.md); PowerShell 7 (`pwsh`) and a real per-user Git for Windows install were not run (also stated in `docs/install.md`).
- CI has no BBj: the real-compiler, live `bbj-ls` and skill-example live routes skip there, so a regression in them passes CI until a run on a host with BBjServices.
- The `noconn` write-out shape of the Git for Windows `curl` is unmeasured; the classification fails safe.
- No test checks the semantic accuracy of skill prose; the examples are checked by `tests/test_skill_examples.py` where BBj is present.

---

*Testing analysis: 2026-10-16*
