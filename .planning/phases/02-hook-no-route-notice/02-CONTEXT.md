# Phase 2: Hook no-route notice - Context

**Gathered:** 2026-10-10
**Status:** Ready for planning

<domain>
## Phase Boundary

`plugins/bbj/scripts/bbj-check.sh` stops exiting silently when it cannot check a BBj file the
agent wrote. It sorts every checked file into clean / errors / no route / route failed, and on
"no route" it tells the agent once per session (exit 0, one JSON
`hookSpecificOutput.additionalContext` object on stdout) that the file was written but not
checked and how to enable a check. Tests are amended to the new contract, and delivery is
proven on a real Codex (`apply_patch`) and a real Claude Code (`Write`). Out of scope: any
change to the check routes themselves, the hosted check from the hook (still forbidden), the
CHANGELOG / release notes (Phase 6).

Locked by REQUIREMENTS.md and not re-asked: HOOK-01..04 (exit 0 + `additionalContext`, not
exit 2; `mkdir`-atomic marker keyed by `session_id`; `BBJ_CHECK_STATE_DIR` test seam; notice
content items; narrow amendment of `tests/test_exit_contract.sh`; Codex-only exit-2 fallback if
`additionalContext` does not reach the model).

</domain>

<decisions>
## Implementation Decisions

### Route classification (HOOK-01)
- **D-01:** **No route → notice.** Each of these counts as "no route" when no other route
  gives a verdict: no compiler found; nothing listening on the `bbj-ls` URL (connection
  refused); `curl` not installed; `BBJ_LOCAL_MCP_URL` refused by the loopback validation.
- **D-02:** **A compiler that gives no verdict counts as no route.** If `bbjcpl` is found but
  gives no verdict (launcher/Java failure, output without a compiler-format line, rc ≥ 126) and
  tier 2 also has no route, the file went unchecked and the notice fires. The reason text says
  a compiler was found but gave no result (see D-09).
- **D-03:** **Route failed → silent (exit 0, nothing printed).** `bbj-ls` reached but no verdict:
  timeout, JSON-RPC `error` / `isError: true`, empty reply, or text that is neither
  "No errors found." nor `line N, column M:` error lines. Not a notice and no second message
  class. Distinguishing refused from timed-out uses curl's exit status (planner/researcher:
  connection refused = 7 → no route; operation timeout = 28 → failed; classify the other codes
  conservatively and document them in the header comment).
- **D-04:** **Mixed results within one call (Codex `apply_patch` with several files):** any
  compiler errors → exit 2 with the D-12 error feedback exactly as today, and no notice in that
  call. Otherwise, if any file was "no route" → the notice (still subject to once-per-session).
  Clean and route-failed files contribute nothing.
- **D-05:** Early skips (non-BBj extension, symlink, `config*.bbx`, missing/unreadable file,
  hostile names) happen before any route is tried and never count as "no route". Writing a
  README never triggers the notice.

### Notice text (HOOK-02)
- **D-06:** **Two texts, chosen by `tool_name`.** `Write|Edit` (Claude Code): enable `bbjcpl`
  by setting the `bbj` plugin's `bbj_home` option, or enable the `bbj-local@basis-bbj` plugin
  (BBjServices 26.03+). `apply_patch` (Codex): set `BBJ_HOME` or put `bbjcpl` on `PATH`, or rerun
  `install-codex.sh --with-local` (BBjServices 26.03+). Same structure in both, only the
  enable instructions differ.
- **D-07:** **Addressed to the agent, which tells the user.** The text ends by asking the agent to
  tell the user that the file was not compile-checked and how to enable a check.
- **D-08:** **Hosted check: allowed, with disclosure (mirrors Phase 1 D-01/D-02).** One clause:
  the agent may check with `bbj_check_syntax` of the hosted docs server; that sends the code to
  the server and checks against a stock BBj, so the user must be told. The server address is
  never named (`docs_host_single_source` in `tests/test_layout.py` stays strict). The hook itself
  never calls it.
- **D-09:** **Short reason included.** One of "no bbjcpl found" / "bbjcpl found but gave no
  result", plus one of "no bbj-ls answering on 127.0.0.1:5009" (use the actual URL host:port) /
  "curl not found" / "bbj-ls URL refused (not loopback)".
- **D-10:** **Names the unchecked file path(s).** JSON-escaped (backslash, quote, control
  characters) with the hook's existing escaping approach; capped (follow the 40-line feedback
  cap idea, e.g. first N paths then "and M more").
- **D-11:** **Says the silence that follows is not "clean".** It states that later BBj files in
  this session are not checked either and the notice is not repeated.
- **D-12:** Notice is its own message class, never the D-12 error header
  (`<route> reported N error(s) in <file>:`); it gets its own grammar gate.

### Delivery verification (HOOK-04)
- **D-13:** **Codex: scripted `codex exec` plus transcript.** A planned task installs the hook
  into a scratch `CODEX_HOME` / project with no BBj and nothing on 5009. It runs `codex exec`
  asking the model to write a `.bbj` via `apply_patch` and then quote verbatim any hook message
  it received, and saves the session log/output under the phase directory as evidence. The
  user approves `/hooks` once (trust step). A Codex CLI is installed and logged in on this
  machine, so the run happens during execution rather than as a deferred human step.
- **D-14:** **Claude Code verified the same way.** `claude -p` with the plugin loaded from the
  local marketplace (a scratch project, no BBj on PATH, `bbj_home` unset). The model writes a
  `.bbj` and quotes the hook context, and the evidence is saved. This is the first capture of
  `additionalContext` delivery in this repo.
- **D-15:** **Codex fallback text, if needed.** If `additionalContext` does not reach the model on
  Codex, Codex alone switches to exit 2 + stderr. The first sentence then says the patch was
  applied and the file was written, only not checked, so the agent does not retry the patch.
  The rest is the same body as the JSON notice. Record the outcome either way.

### Once-per-session marker (HOOK-02)
- **D-16:** **No `session_id` (missing or sanitised to empty) → notify on every no-route call.**
  No shared `nosession` key, because it would survive across sessions and silence later ones.
- **D-17:** **Fail toward telling.** Test-and-set with `mkdir "$STATE/bbj-check-noroute-<key>"`.
  Success → notify. Failure where the name already exists **as a real directory (not a
  symlink)** → already notified, silent. Any other failure (unwritable or missing state dir,
  something else at that name) → notify anyway.
- **D-18:** **Location `${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}`.** One code path for both hosts,
  with no `CLAUDE_PLUGIN_DATA`. Markers are empty dirs left for the OS to clean. `tests/lib.sh`
  exports `BBJ_CHECK_STATE_DIR` into `$WORK` so tests are hermetic. The key is `session_id`
  sanitised to `[A-Za-z0-9_-]`, max 64 chars.
- **D-19:** Subagents carry the parent's `session_id`, so one notice per session tree is
  accepted. A resumed session keeps its id and is not re-notified. `/compact` may drop the notice
  from context, which is also accepted.

### Claude's Discretion
- Exact prose of both notice texts and the Codex fallback text, within D-06..D-12 and D-15.
- How `no_tier1_route` and `check_file` signal the verdict (return codes and/or globals such as
  `NOROUTE` plus a reason variable), keeping "every failure path ends in an explicit exit/return".
- JSON building in POSIX `sh` (static template plus escaped path list and reason), the path cap N.
- Which existing silent-path tests convert to "first call notice, then silent", and the new gate
  names (follow the `contract_` / file-prefix conventions).
- Static-guard updates: `tests/test_static_guards.sh` and any gate that asserts "stdout never
  written" must allow exactly the one `printf` of the notice JSON, narrowly.
- The scratch setup for the two delivery captures and where evidence files live.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements and roadmap
- `.planning/REQUIREMENTS.md` §Hook — HOOK-01..HOOK-04, the locked contract
- `.planning/ROADMAP.md` §Phase 2 — goal and the four success criteria
- `.planning/PROJECT.md` §Key Decisions — "Hook notice: exit 0 + `additionalContext`, once per
  session"; "Hosted check used without asking … but the user is told (D-01)"

### Prior research (hook design)
- `.planning/research/ARCHITECTURE.md` §"D. Hook: notify once when no check route exists" —
  the `no_tier1_route` split, marker design, rejected alternatives. **Note:** its "exit 2 with
  stderr, no JSON" decision is **superseded** by `.planning/research/SUMMARY.md`
  §Reconciliations 1 and HOOK-02 (exit 0 + `additionalContext`). The no-session and
  unwritable-dir rules there are superseded by D-16/D-17 here.
- `.planning/research/SUMMARY.md` §Reconciliations 1, pitfall 5 — delivery decision and the
  "returns 0 for clean, timeout and no route alike" pitfall
- `.planning/research/PITFALLS.md` — hook pitfalls (read the hook sections)

### Prior phase decisions
- `.planning/phases/01-repo-owned-skills-and-local-first-check-route/01-CONTEXT.md` — D-01 (hosted
  allowed with disclosure), D-02 (never name the hosted address), D-03 (client-neutral shared text)

### Code and tests touched
- `plugins/bbj/scripts/bbj-check.sh` — header contract (lines 1-71), `no_tier1_route` (~84-122),
  `check_file` (~283-371), `codex_patch`, `main` (~446-472)
- `plugins/bbj/hooks/hooks.json` — PostToolUse `Write|Edit`, 30 s timeout
- `tests/test_exit_contract.sh` — the stdout-empty contract to amend narrowly
- `tests/lib.sh` — hermetic env seams (`BBJ_CHECK_DEFAULT_HOMES`, `BBJ_LOCAL_MCP_URL`); add
  `BBJ_CHECK_STATE_DIR`
- `tests/test_tier2_fake.sh`, `tests/test_discovery.sh`, `tests/test_codex_patch.sh`,
  `tests/test_hook_review_fixes.sh`, `tests/test_claude_plugin.sh`, `tests/test_never_execute.sh`,
  `tests/test_static_guards.sh` — silent-path and static gates that may need conversion
- `tests/fake_mcp.py` — fake server modes for route-failed cases (error, isError, junk, slow)
- `codex/install-codex.sh` — installs the hook. A changed script needs `/hooks` re-approval,
  which the installer already says at line ~739

### External contract docs
- https://code.claude.com/docs/en/hooks — Claude Code PostToolUse JSON output, `additionalContext`
- https://learn.chatgpt.com/docs/hooks — Codex hooks: `session_id`, exit 2 replaces the tool result,
  `additionalContext`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `no_tier1_route`: already separates the paths that matter (URL refused, no curl, curl failure,
  empty reply, JSON-RPC error, clean, errors), but every one ends in `return 0`. Split the
  return meaning rather than restructure it.
- JSON escaping of file text inside `no_tier1_route` (`tr` + `sed` + `awk`): the same approach
  escapes paths and reasons for the notice JSON.
- `jget pre session_id`: `session_id` sits before `tool_input` in both payload shapes.
- `report()` and `FAILED`: the error path stays untouched. The notice is decided in `main` after
  all files, and only when `FAILED=0`.

### Established Patterns
- Exit contract: only 0 or 2. Stdout is now written in exactly one case (the notice JSON); the
  header comment and `test_exit_contract.sh` must say so.
- No `set -e`; each failure path ends in explicit `return`/`exit`. Underscore-prefixed temporaries.
  `printf` for user data.
- Test seams are env vars exported by `tests/lib.sh` (`BBJ_CHECK_DEFAULT_HOMES`,
  `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`, so tests default to "nothing on the port" =
  no route and will now see the notice on the first call).
- Gate lines `gate NAME ok|FAIL|skip`; dash/bash/busybox coverage in `test_exit_contract.sh`.

### Integration Points
- `main` end: errors → exit 2 (unchanged); else no-route and marker won → print notice JSON,
  exit 0; else exit 0 silent.
- The Codex install path copies the script, and users re-approve via `/hooks`. Upgrade notes go
  to Phase 6.

</code_context>

<specifics>
## Specific Ideas

- Shape of the notice (prose is Claude's discretion): "<path(s)> was/were written but not
  compile-checked: <reason>. Later BBj files in this session are not checked either; this notice
  is not repeated. To enable a check: <client-specific>. Otherwise you may use bbj_check_syntax of
  the hosted docs server; it sends the code to that server and checks against a stock BBj, so
  tell the user. Tell the user this file was not checked and how to enable a check."
- Evidence from both real-client runs is committed in the phase directory.

</specifics>

<deferred>
## Deferred Ideas

- CHANGELOG entry and Codex `/hooks` re-approval note for the changed hook: Phase 6 (REL-02).
- Docs/README mention of the notice: not discussed. Planner may add one line to the install pages
  if a gate requires it; otherwise leave it for Phase 6.

</deferred>

---

*Phase: 02-hook-no-route-notice*
*Context gathered: 2026-10-10*
