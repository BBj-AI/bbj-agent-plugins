---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 06
subsystem: infra
tags: [codex-installer, posix-sh, curl, mcp, tools-list, probe, fake-server]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: "01-04: section 1b, LOCAL_URL, use_local, analyze fields main= mention= managed=; 01-03: sync_server"
provides:
  - "probe_local, PROBE_BODY and the probe outcomes found, none, nocurl, refused in codex/install-codex.sh"
  - "without --with-local and with no bbj-local in config.toml: one tools/list request, one line per outcome, nothing written"
  - "with --with-local: probe first, bbj-local registered on every outcome, a 'bbj-local: warning:' line on every outcome but found (LOCAL-04)"
  - "tests/fake_mcp.py modes tools-list and tools-list-other (the -32020 Mcp-Method check of the live server)"
  - "curl_gate in tests/test_static_guards.sh, applied to codex/*.sh as well as the hook scripts"
  - "sixteen probe gates and the start_fake, stop_fake and cleanup helpers in tests/test_install_codex.sh"
affects: [01-07]

status: complete

actuals:
  tokens: 6900
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "the probe outcome selects only the line printed; sync_server runs on every outcome of the flagged branch and the probe never sets pending or the exit code"
    - "the seam variable BBJ_LOCAL_MCP_URL moves only the probe (loopback-validated before curl); the registered url stays the fixed LOCAL_URL"
    - "test fake servers: start_fake waits for the port file, stop_fake kills the server and puts the seam back on the closed port 127.0.0.1:9"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/fake_mcp.py
    - tests/test_install_codex.sh
    - tests/test_static_guards.sh

key-decisions:
  - "curl_gate ignores lines that only print a message (say \"...\") besides command -v lines: the installer's no-curl message holds the word curl surrounded by spaces and is not a call"
  - "The flagged branch probes on every run with --with-local, also when a managed block already exists, so a rerun with the flag can warn; a run without the flag and with a managed block sends no probe (D-09)"
  - "The refused and none lines name the seam variable and, when the seam differs from the fixed url, the url the registration always uses (D-17); the warning appends 'at LOCAL_URL' to 'registering it anyway' in that case"
  - "Reply match is the tool name bbj_check_syntax in the body, never curl's exit code, so a different server on the port and a refused connection give the same 'no bbj-ls answered' line"

patterns-established:
  - "Pattern: probe_local is one function with four outcomes; messages are printed by section 1b, never by the function"
  - "Pattern: one gate per probe outcome for the LOCAL-04 predicate (found, closed port, other server, no curl, refused seam)"

requirements-completed: [LOCAL-03, LOCAL-04, LOCAL-07]

coverage:
  - id: D1
    description: "Without --with-local and with no bbj-local in config.toml the installer sends one static tools/list request and, when a bbj-ls answers, prints one suggestion line; nothing is written"
    requirement: "LOCAL-03"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#probe_found_suggests, probe_request_shape"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every other no-flag outcome (closed port, another server, no curl, refused non-loopback seam) is one line, exit 0, nothing written; the curl call carries -q, --noproxy, --proto =http, timeouts and no redirect flag"
    requirement: "LOCAL-03"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#probe_no_answer_no_flag, probe_no_curl, probe_other_server_no_suggestion, probe_refuses_non_loopback_seam, probe_curl_flags"
        status: pass
      - kind: unit
        ref: "tests/test_static_guards.sh#static_curl_call_install-codex.sh (and a mutation run with --noproxy removed, which fails)"
        status: pass
    human_judgment: false
  - id: D3
    description: "--with-local registers the managed bbj-local block on every probe outcome and warns on every outcome except found; exit code never changes"
    requirement: "LOCAL-04"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#with_local_probe_found_registers, with_local_probe_fail_registers_and_warns, with_local_probe_other_server_registers_and_warns, with_local_probe_nocurl_registers_and_warns, with_local_probe_refused_registers_and_warns"
        status: pass
    human_judgment: false
  - id: D4
    description: "A managed block is refreshed without a probe, a hand-registered bbj-local is never probed or mentioned, a lone end marker only gets the suggestion, a probe never changes the exit code"
    requirement: "LOCAL-03"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#local_rerun_without_flag_skips_probe, local_hand_registered_no_probe, local_lone_end_marker_without_flag_only_suggests, probe_never_changes_exit"
        status: pass
    human_judgment: false
  - id: D5
    description: "The fake MCP server answers tools/list in tools-list and tools-list-other modes, rejects a wrong Mcp-Method with -32020, and every earlier mode is unchanged"
    requirement: "LOCAL-07"
    verification:
      - kind: integration
        ref: "tests/test_tier2_fake.sh (all gates ok), tests/test_install_codex.sh#probe_request_shape"
        status: pass
    human_judgment: false
  - id: D6
    description: "ShellCheck of codex/install-codex.sh and the tests"
    verification: []
    human_judgment: true
    rationale: "ShellCheck is not installed locally; gate ci_shellcheck runs on the pushed branch in CI"

duration: 9min
completed: 2026-10-09
---

# Phase 1 Plan 06: Suggest-only tools/list probe and the registered-anyway warning Summary

**The Codex installer asks a running bbj-ls for its tool list with one static, loopback-only tools/list request: without --with-local it only suggests the flag, with it bbj-local is registered on every outcome and a warning names the reason unless a bbj-ls answered.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-09T17:41:30Z
- **Completed:** 2026-10-09T17:50:50Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- `probe_local` (found, none, nocurl, refused) with a static `PROBE_BODY`, one-line curl call (`-q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 3`, no redirect flag), loopback validation copied from the hook before curl is reached, and the verdict taken from the tool name in the reply.
- Section 1b: three branches. With the flag: probe, one line, then `sync_server` on every outcome (LOCAL-04). Managed block, no flag: `sync_server`, no probe (D-09). No bbj-local at all (no table, no mention, no managed block; a lone end marker counts as none): probe and one line, nothing written.
- `tests/fake_mcp.py` modes `tools-list` (compact JSON like the live server) and `tools-list-other`; a wrong or missing `Mcp-Method` header gets 400 and JSON-RPC -32020, as the live bbj-ls does.
- `curl_gate` in `tests/test_static_guards.sh` now covers `codex/*.sh`; a mutation run (installer copy without `--noproxy`) makes it fail.
- Sixteen new gates in `tests/test_install_codex.sh`; one per probe outcome for the LOCAL-04 predicate. `sh tests/run.sh` ends `ok=407 fail=0 skip=2`.

## Live probe (127.0.0.1:5009)

A real bbj-ls was listening on this machine. One manual request with the static body (no user code), the same headers as `probe_local`:

- `POST /mcp` with `Content-Type`, `Accept: application/json, text/event-stream`, `MCP-Protocol-Version: 2026-07-28`, `Mcp-Method: tools/list` returned **HTTP 200**, `Content-type: application/json`, compact JSON `{"jsonrpc":"2.0","id":1,"result":{"resultType":"complete","tools":[{"name":"bbj_check_syntax",...` (4035 bytes). The reply regex `"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"` matches it.
- The same request without the `Mcp-Method` header returned **HTTP 400** with `{"jsonrpc":"2.0","id":1,"error":{"code":-32020,"message":"Mcp-Method header mismatch"}}`; the fake reproduces that.
- The installer itself, run without the flag and with the seam unset against throwaway `--codex-home` and `--skills-dir` directories, printed `bbj-local: a bbj-ls answers at http://127.0.0.1:5009/mcp; it is not registered with Codex. Rerun with --with-local ...`, exit 0, and `config.toml` held no `bbj-local` line.
- All automated tests stayed on the fake server or the closed port 127.0.0.1:9 through `BBJ_LOCAL_MCP_URL`; none of them reached the real server.

## Task Commits

1. **Task 1: tools/list probe and --with-local suggestion** - `3528c47` (feat; tracer, verified end to end by probe_found_suggests and probe_request_shape before Task 2)
2. **Task 2: every other no-flag outcome, curl rules cover the installer** - `f19498e` (feat)
3. **Task 3: --with-local probes first, registers on every outcome** - `c652657` (feat)

**Plan metadata:** committed with this summary (docs: complete plan)

_Note: Tasks 2 and 3 are tdd="true"; their gates were written and seen failing (Task 3: five matrix gates RED) before the installer change, but each task has one commit holding gates and code._

## Files Created/Modified

- `codex/install-codex.sh` - `PROBE_BODY`, `probe_local`, the three-branch section 1b, header and usage sentences on the probe
- `tests/fake_mcp.py` - tools-list and tools-list-other modes, `tools_list_reply`, the -32020 Mcp-Method check, docstring
- `tests/test_install_codex.sh` - cleanup trap, `start_fake`, `stop_fake`, `nlines`, `matrix_registered`, `one_warning`, sixteen probe gates
- `tests/test_static_guards.sh` - `curl_gate` (hook loop and codex loop)

## Decisions Made

See `key-decisions` above. In short: the probe verdict is the tool name in the reply; the flagged branch probes on every run with the flag; messages print both the probe url and the fixed registration url when the seam differs (D-17); `curl_gate` skips message-only `say` lines.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] curl_gate would have flagged the installer's own message line**
- **Found during:** Task 2 (extending the curl scan to codex/*.sh)
- **Issue:** The required line `bbj-local: not probed: curl not found.` is printed by `say "..."` and contains the word curl between spaces, which the hook's call regex treats as a curl call without `--noproxy`.
- **Fix:** `curl_gate` also drops lines holding `say "` (next to the existing `command -v` exclusion). The mutation check still fails when `--noproxy` is removed from the real call.
- **Files modified:** tests/test_static_guards.sh
- **Verification:** `static_curl_call_install-codex.sh` ok; `static_curl_call_bbj-check.sh` unchanged; mutation run reports FAIL.
- **Committed in:** f19498e

**2. [Rule 1 - Bug in own test] Redundant negated pipeline removed**
- **Found during:** Task 2 (probe_other_server_no_suggestion)
- **Issue:** A convoluted `! grep ... | grep ...` clause repeated what `nlines 'bbj-local: a bbj-ls answers' = 0` already asserts.
- **Fix:** Dropped the clause before the first green run.
- **Files modified:** tests/test_install_codex.sh
- **Committed in:** f19498e

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 own-test cleanup)
**Impact on plan:** Both inside the plan's files; no scope change.

## Issues Encountered

- ShellCheck is not installed locally, so `ci_shellcheck` over `codex/*.sh` and `tests/*.sh` is verified only by CI (plan human-check). `sh -n` and the static scans pass.
- When the seam is not set, the found line in the no-flag case names `http://127.0.0.1:5009/mcp` twice (probe url and registration url); the wording follows the plan and is harmless.

## Known Stubs

None.

## Threat Flags

None. The only new network surface is the probe request covered by T-01-17 to T-01-22 (static body asserted by `probe_request_shape`, loopback validation asserted with an empty fake-curl log, curl flags asserted by `probe_curl_flags` and `static_curl_call_install-codex.sh`, no write asserted by the byte-identical gates).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 01-07 (docs) can quote the printed fragments: `bbj-local: a bbj-ls answers at`, `bbj-local: no bbj-ls answered at`, `bbj-local: not probed:`, `bbj-local: warning:` and `registering it anyway`.
- Research assumption A4 stays flagged: "Codex shows bbj-local as failed until BBjServices runs" is a project constraint, not observed on Codex here.

## Self-Check: PASSED

- Files modified exist: codex/install-codex.sh, tests/fake_mcp.py, tests/test_install_codex.sh, tests/test_static_guards.sh (all found).
- Commits 3528c47, f19498e, c652657 exist (`git log --grep="01-06"`).
- Acceptance criteria re-run: all sixteen new gates ok; `sh tests/test_tier2_fake.sh` exits 0; `grep -c 'Mcp-Method: tools/list'` prints 1 and the same line holds `--noproxy`; `grep -c tools-list-other tests/fake_mcp.py` prints 3; an unknown fake mode exits 1; `curl_gate` appears 5 times; the mutation check exits 0; `--help` mentions the probe; `sh tests/run.sh` ends `fail=0`.

---
*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Completed: 2026-10-09*
