# Phase 2: Hook no-route notice - Research

**Researched:** 2026-10-10
**Domain:** POSIX-sh hook (`plugins/bbj/scripts/bbj-check.sh`) emitting a PostToolUse `additionalContext` notice on Claude Code and Codex; shell test-suite conversion; real-client delivery capture
**Confidence:** HIGH for contract shapes, curl classification, test inventory, JSON building (all reproduced on a prototype in a scratch copy); MEDIUM for the Codex delivery-capture recipe (flags confirmed in `--help`, end-to-end run not made: it is a paid model call)

## User Constraints (from CONTEXT.md)

<user_constraints>

### Locked Decisions

**Route classification (HOOK-01)**
- **D-01:** **No route → notice.** Each of these counts as "no route" when no other route gives a verdict: no compiler found; nothing listening on the `bbj-ls` URL (connection refused); `curl` not installed; `BBJ_LOCAL_MCP_URL` refused by the loopback validation.
- **D-02:** **A compiler that gives no verdict counts as no route.** If `bbjcpl` is found but gives no verdict (launcher/Java failure, output without a compiler-format line, rc ≥ 126) and tier 2 also has no route, the file went unchecked and the notice fires. The reason text says a compiler was found but gave no result (see D-09).
- **D-03:** **Route failed → silent (exit 0, nothing printed).** `bbj-ls` reached but no verdict: timeout, JSON-RPC `error` / `isError: true`, empty reply, or text that is neither "No errors found." nor `line N, column M:` error lines. Not a notice and no second message class. Distinguishing refused from timed-out uses curl's exit status (planner/researcher: connection refused = 7 → no route; operation timeout = 28 → failed; classify the other codes conservatively and document them in the header comment).
- **D-04:** **Mixed results within one call (Codex `apply_patch` with several files):** any compiler errors → exit 2 with the D-12 error feedback exactly as today, and no notice in that call. Otherwise, if any file was "no route" → the notice (still subject to once-per-session). Clean and route-failed files contribute nothing.
- **D-05:** Early skips (non-BBj extension, symlink, `config*.bbx`, missing/unreadable file, hostile names) happen before any route is tried and never count as "no route". Writing a README never triggers the notice.

**Notice text (HOOK-02)**
- **D-06:** **Two texts, chosen by `tool_name`.** `Write|Edit` (Claude Code): enable `bbjcpl` by setting the `bbj` plugin's `bbj_home` option, or enable the `bbj-local@basis-bbj` plugin (BBjServices 26.03+). `apply_patch` (Codex): set `BBJ_HOME` or put `bbjcpl` on `PATH`, or rerun `install-codex.sh --with-local` (BBjServices 26.03+). Same structure in both, only the enable instructions differ.
- **D-07:** **Addressed to the agent, which tells the user.** The text ends by asking the agent to tell the user that the file was not compile-checked and how to enable a check.
- **D-08:** **Hosted check: allowed, with disclosure (mirrors Phase 1 D-01/D-02).** One clause: the agent may check with `bbj_check_syntax` of the hosted docs server; that sends the code to the server and checks against a stock BBj, so the user must be told. The server address is never named (`docs_host_single_source` in `tests/test_layout.py` stays strict). The hook itself never calls it.
- **D-09:** **Short reason included.** One of "no bbjcpl found" / "bbjcpl found but gave no result", plus one of "no bbj-ls answering on 127.0.0.1:5009" (use the actual URL host:port) / "curl not found" / "bbj-ls URL refused (not loopback)".
- **D-10:** **Names the unchecked file path(s).** JSON-escaped (backslash, quote, control characters) with the hook's existing escaping approach; capped (follow the 40-line feedback cap idea, e.g. first N paths then "and M more").
- **D-11:** **Says the silence that follows is not "clean".** It states that later BBj files in this session are not checked either and the notice is not repeated.
- **D-12:** Notice is its own message class, never the D-12 error header (`<route> reported N error(s) in <file>:`); it gets its own grammar gate.

**Delivery verification (HOOK-04)**
- **D-13:** **Codex: scripted `codex exec` plus transcript.** A planned task installs the hook into a scratch `CODEX_HOME` / project with no BBj and nothing on 5009. It runs `codex exec` asking the model to write a `.bbj` via `apply_patch` and then quote verbatim any hook message it received, and saves the session log/output under the phase directory as evidence. The user approves `/hooks` once (trust step). A Codex CLI is installed and logged in on this machine, so the run happens during execution rather than as a deferred human step.
- **D-14:** **Claude Code verified the same way.** `claude -p` with the plugin loaded from the local marketplace (a scratch project, no BBj on PATH, `bbj_home` unset). The model writes a `.bbj` and quotes the hook context, and the evidence is saved. This is the first capture of `additionalContext` delivery in this repo.
- **D-15:** **Codex fallback text, if needed.** If `additionalContext` does not reach the model on Codex, Codex alone switches to exit 2 + stderr. The first sentence then says the patch was applied and the file was written, only not checked, so the agent does not retry the patch. The rest is the same body as the JSON notice. Record the outcome either way.

**Once-per-session marker (HOOK-02)**
- **D-16:** **No `session_id` (missing or sanitised to empty) → notify on every no-route call.** No shared `nosession` key, because it would survive across sessions and silence later ones.
- **D-17:** **Fail toward telling.** Test-and-set with `mkdir "$STATE/bbj-check-noroute-<key>"`. Success → notify. Failure where the name already exists **as a real directory (not a symlink)** → already notified, silent. Any other failure (unwritable or missing state dir, something else at that name) → notify anyway.
- **D-18:** **Location `${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}`.** One code path for both hosts, with no `CLAUDE_PLUGIN_DATA`. Markers are empty dirs left for the OS to clean. `tests/lib.sh` exports `BBJ_CHECK_STATE_DIR` into `$WORK` so tests are hermetic. The key is `session_id` sanitised to `[A-Za-z0-9_-]`, max 64 chars.
- **D-19:** Subagents carry the parent's `session_id`, so one notice per session tree is accepted. A resumed session keeps its id and is not re-notified. `/compact` may drop the notice from context, which is also accepted.

### Claude's Discretion
- Exact prose of both notice texts and the Codex fallback text, within D-06..D-12 and D-15.
- How `no_tier1_route` and `check_file` signal the verdict (return codes and/or globals such as `NOROUTE` plus a reason variable), keeping "every failure path ends in an explicit exit/return".
- JSON building in POSIX `sh` (static template plus escaped path list and reason), the path cap N.
- Which existing silent-path tests convert to "first call notice, then silent", and the new gate names (follow the `contract_` / file-prefix conventions).
- Static-guard updates: `tests/test_static_guards.sh` and any gate that asserts "stdout never written" must allow exactly the one `printf` of the notice JSON, narrowly.
- The scratch setup for the two delivery captures and where evidence files live.

### Deferred Ideas (OUT OF SCOPE)
- CHANGELOG entry and Codex `/hooks` re-approval note for the changed hook: Phase 6 (REL-02).
- Docs/README mention of the notice: not discussed. Planner may add one line to the install pages if a gate requires it; otherwise leave it for Phase 6.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| HOOK-01 | `bbj-check.sh` distinguishes clean / errors / no route / route failed; a clean file never produces the notice | Return-code split of `no_tier1_route` (0 verdict / 1 no route / 2 route failed); curl exit-code table (§Curl classification); prototype passes with all 429 untouched gates |
| HOOK-02 | No route: exit 0 + one JSON `hookSpecificOutput.additionalContext` once per session (`mkdir` marker keyed by `session_id`, `BBJ_CHECK_STATE_DIR` seam); text content | Exact JSON shape on both clients (§Contract); marker algorithm + prototype (§Code Examples); size caps; text guidance |
| HOOK-03 | `tests/test_exit_contract.sh` amended narrowly; silent-path tests converted to "first call notice, then silent" | Exact inventory: 18 gates in 3 files break (§Test inventory); conversion recipe; new `tests/test_noroute_notice.sh` |
| HOOK-04 | Delivery verified on a real Codex after `apply_patch`; Codex-only exit-2 fallback if not delivered | Codex docs + schema; scripted-capture recipe with confirmed flags (`--dangerously-bypass-hook-trust`, `--ignore-user-config`, `-c`); fallback semantics (§Delivery capture) |
</phase_requirements>

## Summary

The change is small and well-bounded. `no_tier1_route` already separates every path that matters; it only needs to stop returning 0 for all of them. A prototype in a scratch copy of the repo (return codes 0/1/2 from `no_tier1_route`, a `note_noroute` collector, a `notice` function called from `main` after the error check, a `mkdir` marker) passes `sh -n` and `shellcheck -s sh` (0.11.0), and the whole suite except the 18 gates listed in §Test inventory. The JSON validates with `python3 json.loads` under both dash and bash. [VERIFIED: prototype run, this session]

Both clients take the same JSON object: `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"..."}}`. `hookEventName` is required by both. Codex's schema sets `additionalProperties: false` at the top level and inside `hookSpecificOutput`, so emit no other key; plain-text stdout is ignored for PostToolUse on Codex, so JSON is the only way. On Codex exit 2 would replace the tool result with the stderr text (this is why exit 2 stays the fallback only). Size caps are far above the notice: Claude Code 10,000 characters, Codex about 2,500 tokens per hook by default. [CITED: code.claude.com/docs/en/hooks; learn.chatgpt.com/docs/hooks; raw.githubusercontent.com/openai/codex/main/codex-rs/hooks/schema/generated/post-tool-use.command.output.schema.json]

Two environment facts change the delivery-capture plan. (1) **This machine has a real BBj at `/opt/bbx` (with `bin/bbjcpl`, and `/opt/bbx` is in the hook's default homes) and a live `bbj-ls` answering on `127.0.0.1:5009`.** A "no BBj" capture therefore needs the existing seams in the hook command's environment: `BBJ_CHECK_DEFAULT_HOMES=` (empty) and `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`. (2) Codex 0.156.1 has `codex exec --dangerously-bypass-hook-trust` (one invocation, no persisted trust) and `--ignore-user-config`, so the "user approves /hooks once" step of D-13 can be replaced by a flag, with the user's real `~/.codex` config untouched. Choosing the flag over the `/hooks` approval is a user-visible deviation from D-13's wording and should be a checkpoint.

**Primary recommendation:** Implement exactly the prototype shape in §Code Examples (return-code split, globals for files and reasons, one `notice` function that does marker test-and-set then one `printf`), convert the 18 breaking gates by giving each case a fresh `BBJ_CHECK_STATE_DIR` and asserting "first call notice, second call silent", put all new behaviour gates in a new `tests/test_noroute_notice.sh`, and run the two real-client captures scripted with the seams above.

## Project Constraints (from CLAUDE.md)

Source: `<home>/repos/bbj-agent-plugins/.claude/CLAUDE.md`. Treated as locked.

- POSIX `sh` + Python 3 stdlib only; no new runtime dependency. `#!/bin/sh`; verified under dash, bash and busybox sh (`tests/test_exit_contract.sh`).
- No `[[ ]]`, no backticks, no `local`, no `which`, no `eval`, no `readlink -f`, no `grep -P`, no `sed -i`, no `timeout` command, no `jq`/`python`/`node` words on executable lines of shipped scripts (all enforced by `tests/test_static_guards.sh`). Use `printf` for user data, `command -v x > /dev/null 2>&1`.
- No `set -e` in shipped scripts: "every failure path ends in an explicit exit 0". Script-local temporaries start with an underscore.
- Exit contract is fixed: exit 0 or 2; hook stdout was always empty. **This phase amends it in exactly one place (the notice JSON); update the hook header and `tests/test_exit_contract.sh` in the same change.**
- Never execute BBj; every compiler call carries `-N`; only loopback `http://127.0.0.1` / `localhost` / `[::1]` URL literals; every `curl` carries `--noproxy '*'` and `--proto =http`, no `-L`. The hook never calls the hosted check.
- The hosted host name may appear only in `plugins/bbj/.claude-plugin/plugin.json` (`docs_host_single_source`): the notice names the server `bbj-docs`, never its address.
- Comments: explain why; every script/test opens with a block comment naming plan and decision IDs (`HOOK-0N`, `D-NN`), the exit contract, and "never runs BBj". Static scanners ignore full-line comments.
- Tests: gate lines `gate NAME ok|FAIL|skip DETAIL`; files named `test_*.sh`; source `tests/lib.sh`, `mkwork`; ShellCheck clean (`shellcheck -s sh`, CI runs it over `plugins/bbj/scripts`, `codex`, `tests/*.sh`); two-space indent; `$(...)`; redirection `> /dev/null` with the space.
- Commits: conventional prefixes with plan scope (`feat(02-01): ...`, `test(02-02): ...`). Versions are not touched (Phase 6).
- GSD enforcement: edits go through a GSD workflow.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Classify the check result (clean / errors / no route / route failed) | Hook script (`bbj-check.sh`) | — | Only the hook sees compiler output and curl exit status |
| Once-per-session memory | Local filesystem (state dir, one empty dir per session) | Hook script | No daemon; `mkdir` is the atomic test-and-set; keyed by the host's `session_id` |
| Notice delivery to the model | Host (Claude Code / Codex hook runtime) | Hook stdout JSON | Host wraps `additionalContext` as a system reminder (Claude Code) or developer context (Codex) |
| Telling the user | The model, on request of the notice text | — | The hook cannot talk to the user; D-07 asks the agent to do it |
| Enabling a check route | User (plugin option / env / installer) | Docs | The notice only names the steps |
| Delivery proof | Scripted real-client run + saved transcript | Test suite (static + fake) | The fake suite proves the bytes; only a real client proves the model sees them |

## Standard Stack

No external packages are installed by this phase. Everything is POSIX `sh`, `awk`, `sed`, `tr`, `head`, `mkdir`, `curl` (already used) and the Python 3 stdlib in tests.

| Tool | Version here | Purpose | Note |
|------|-------------|---------|------|
| dash / bash | present | shells under test | `busybox` is NOT installed on this host: its gates skip (`shell_busybox skip`) [VERIFIED: baseline run] |
| curl | 8.18.0 | tier-2 request; exit codes classified below | [VERIFIED: `curl --version`] |
| python3 | 3.14 | `json.loads` validation of the notice in tests | stdlib only |
| ShellCheck | not installed on host | CI gate `ci_shellcheck` | I ran 0.11.0 from a scratch pip target to check the prototype; CI installs its own [VERIFIED: `shellcheck --version`] |

### Package Legitimacy Audit

No external package is added to the repository. (`shellcheck-py` was fetched once into the research scratchpad only to lint the prototype; it is not recommended for the repo, which already gets ShellCheck from CI.)

**Packages removed due to [SLOP] verdict:** none. **Packages flagged [SUS]:** none.

## Contract: exact output shapes

### Claude Code PostToolUse (`Write|Edit`)

```json
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"<text>"}}
```

- `hookSpecificOutput` "requires a `hookEventName` field set to the event name". [CITED: code.claude.com/docs/en/hooks]
- Exit 0 "is the intended exit code when you print JSON for structured control"; "Your hook's stdout must contain only the JSON object"; stdout is treated as JSON when it starts with `{` and ends with `}`. For exit 2 on PostToolUse the table says "Shows stderr to Claude; the tool already ran". [CITED: same page]
- Delivery: "Claude Code wraps the string in a system reminder and inserts it into the conversation at the point where the hook fired ... next to the tool result". Cap: "If a value exceeds 10,000 characters, Claude Code writes the text to a file ... and passes Claude the file path with a preview of up to the first 2,000 characters". [CITED: same page]
- Style advice from the same page: "Write the text as factual statements rather than imperative system instructions ... Text framed as out-of-band system commands can trigger Claude's prompt-injection defenses, which causes Claude to surface the text to you instead of treating it as context." For this notice, surfacing to the user is the intended end result, but phrase the body as facts ("The file was written but not compile-checked ...") and keep the "tell the user" request as one final plain sentence. D-14 captures whether this works. [CITED]
- `--bare` skips hooks and system reminders: do not use it for the capture. [CITED: code.claude.com/docs/en/headless]

### Codex PostToolUse (`apply_patch`)

- Same object. Schema `post-tool-use.command.output.schema.json`: `PostToolUseHookSpecificOutputWire` has `additionalProperties: false`, properties `additionalContext` (string), `hookEventName` (`const: "PostToolUse"`), `updatedMCPToolOutput`; `required: ["hookEventName"]`. The top-level schema is also `additionalProperties: false`. [CITED: raw.githubusercontent.com/openai/codex/main/codex-rs/hooks/schema/generated/post-tool-use.command.output.schema.json]
- Docs: "That `additionalContext` text is added as extra developer context." Plain text on stdout is ignored for PostToolUse. `decision: "block"` and exit 2 both make "Codex replace the tool result with the feedback". `updatedMCPToolOutput` and `suppressOutput` are unsupported and mark the hook run failed. [CITED: learn.chatgpt.com/docs/hooks]
- Limit: per-hook `additionalContextLimit`, default about 2,500 tokens; above it Codex saves the text under `<temp_dir>/hook_outputs/<session_id>/<uuid>.txt` and sends a preview. [CITED: learn.chatgpt.com/docs/hooks]
- The Codex 0.156.1 binary contains the strings `hook returned invalid post-tool-use JSON output` and `PostToolUse hook exited with code 2 but did not write feedback to stderr`. [VERIFIED: `strings` on the installed binary]
- The docs state: "Codex records trust against the hook's current hash, so new or changed hooks are marked for review and skipped until trusted" and "`--dangerously-bypass-hook-trust` runs enabled hooks without persisted trust for one invocation". The binary holds the config path `hooks.state."<key>".trusted_hash` (strings output: `hooks.state."` ... `".trusted_hash`), so persisted trust lives in the user layer `config.toml` of the active `CODEX_HOME`. The key derivation is not documented. [CITED + VERIFIED: strings]

### Payload fields

- Claude Code key order, from the repo's own capture-derived fixture, `tests/lib.sh:78`: `{"session_id":"s1","transcript_path":"/tmp/t.jsonl","cwd":"...","prompt_id":"p1","permission_mode":"acceptEdits","effort":"low","hook_event_name":"PostToolUse","tool_name":"...","tool_input":...,"tool_response":...}`. `session_id` is before `tool_input`, so `jget pre session_id` works. [VERIFIED: tests/lib.sh:78, comment "key order as captured from Claude Code 2.1.294"; docs example also lists `session_id` first]
- Codex: `session_id` is a required string ("Current Codex session id. Subagent hooks use the parent session id."), along with `cwd`, `hook_event_name`, `model`, `permission_mode`, `tool_input`, `tool_name`, `tool_response`, `tool_use_id`, `transcript_path`, `turn_id`. [CITED: post-tool-use.command.input.schema.json; learn.chatgpt.com/docs/hooks] **Key order on the wire is not documented and no real Codex payload exists in this repo** (the fixture `codex_payload` at `tests/lib.sh:85` is synthetic and says so). Read the id as `jget pre session_id`, falling back to `jget all session_id` (same pattern the hook already uses for `tool_name`); JSON-escaped nested strings cannot contain the bare tag `"session_id"`, so the fallback cannot be forged from patch text. The delivery capture records the real payload (tee in the hook command) and settles this.

## Curl classification (D-01 / D-03)

Reproduced here with the hook's exact flags (`-q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m N -X POST --data-binary @-`) against a local Python server in each failure mode. [VERIFIED: runs this session, curl 8.18.0]

| curl exit | What happened (reproduced) | Class | Reason text |
|-----------|---------------------------|-------|-------------|
| 7 | refused: `127.0.0.1:9`, `[::1]:9`, `localhost:9` all `curl: (7) Failed to connect ... Could not connect to server` | **no route** | `no bbj-ls answering on HOST:PORT` |
| 28 | server accepts and never answers: `Operation timed out after 3002 milliseconds with 0 bytes received` (with the hook's `-m 12` this takes 12 s) | route failed, silent | — |
| 52 | server accepts, reads, closes: `Empty reply from server` | route failed, silent | — |
| 56 | server resets after the request: `Recv failure: Connection reset by peer` | route failed, silent | — |
| 18 | short body vs Content-Length: `end of response with 97 bytes missing` | route failed, silent | — |
| 1 | non-HTTP service answers `hello`: `Received HTTP/0.9 when not allowed` | route failed, silent | — |
| 0, empty body | HTTP 200 with empty body | route failed, silent | — |
| 0, body | parse: JSON-RPC `error` / `isError:true` / text with neither verdict → failed; `No errors found.` → clean; `line N, column M:` lines → errors | per existing logic | — |
| anything else (6 unresolvable host, 2/3/4/5 misuse, ...) | not reproduced here | route failed, silent (conservative) `[ASSUMED]` | — |

Rule to document in the header: **only exit 7 is "no route"; every other nonzero exit, and an empty or unparseable reply, is "route failed" and silent.** Reason for conservatism: mistaking a reachable-but-slow server for an absent one would make the notice say "no bbj-ls answering", which would be false; mistaking the other way keeps today's silent behaviour. A test cannot wait 12 s for a real timeout: extend `tests/fake-bin/curl` with `FAKE_CURL_EXIT` (default 7, today it hardcodes `exit 7`) and test 28/52/56 through it; use `tests/fake_mcp.py` modes for the reachable-no-verdict cases.

## Architecture Patterns

### System Architecture Diagram

```
stdin JSON ─► main ─► tool = Write|Edit | apply_patch | other(exit 0)
                          │
                          ▼
              check_file(path) per file (apply_patch: each header path, once)
                          │
     early skips (D-05) ──┴─► not BBj / symlink / config*.bbx / unreadable / hostile name: return, never "no route"
                          │
                  discover compiler?
                 ┌── yes ─┴────── no ───┐
                 ▼                      ▼
       run bbjcpl -t -N -X        no_tier1_route (tier 2)
          │                              │ returns 0 = verdict given (clean or report())
   errs? ─┤                              │ returns 1 = NO ROUTE   (url refused | no curl | curl exit 7)
   yes: report() FAILED=1                │ returns 2 = ROUTE FAILED (any other curl exit, empty reply,
   no verdict (junk output / rc>=126) ──►│            rpc error, isError, text w/o verdict)
   no output, rc<126: clean, return      ▼
                                 rc 1 ─► note_noroute(none|noresult): NR_N++, NR_LIST+=file
                          │
                          ▼
   main, after all files:
     FAILED=1 ───────────────────────────────► stderr feedback + bbj_lookup line, exit 2   (unchanged; no notice, D-04)
     else NR_N>0 ─► sid = jget pre session_id (fallback jget all)
                    key = sid with [^A-Za-z0-9_-] removed, first 64 chars
                    key empty ─────────────────► print notice            (D-16)
                    mkdir $STATE/bbj-check-noroute-$key
                       ok ─────────────────────► print notice
                       fail, real dir, not symlink ► silent             (already told)
                       fail, anything else ────► print notice           (D-17)
     else ───────────────────────────────────► exit 0, empty stdout
   notice = ONE printf of {"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"..."}}
```

### Recommended structure (no new files in shipped code)

```
plugins/bbj/scripts/bbj-check.sh   # edit: return codes, note_noroute, json_body, notice, main tail, header
tests/lib.sh                       # edit: BBJ_CHECK_STATE_DIR in mkwork, fresh_state helper, SESSION_ID
tests/fake-bin/curl                # edit: exit ${FAKE_CURL_EXIT:-7}
tests/fake_mcp.py                  # edit: modes is-error, empty, no-verdict (and docstring)
tests/test_noroute_notice.sh       # NEW: all notice behaviour gates (prefix notice_)
tests/test_exit_contract.sh        # edit: narrow amendment
tests/test_discovery.sh, tests/test_tier2_fake.sh   # edit: conversions
.planning/phases/02-hook-no-route-notice/evidence/  # NEW: delivery transcripts
```

### Pattern 1: split the return meaning, not the structure

**What:** `no_tier1_route` returns 0 = a verdict was reached (clean, or `report` ran), 1 = no route (sets `NR_T2` to `refused|nocurl|badurl`, and `NR_HOSTPORT`), 2 = route failed. `check_file` calls it from exactly two places and records a no-route result with `note_noroute none` (no compiler discovered) or `note_noroute noresult` (compiler gave no verdict). Failure paths still end in an explicit `return`.
**D-02 corner:** compiler gave no verdict and tier 2 returns 2 (reached, no verdict) → silent; tier 2 returns 1 → notice with "a compiler was found but gave no result". The reason is whatever `NR_COMPILER` first recorded in the call.

### Pattern 2: decide the notice in `main`, after all files, only when `FAILED=0`

The marker is consumed only when a notice is about to print, so a call that exits 2 (D-04), a clean call, a route-failed call and an early skip never burn the once-per-session slot.

### Anti-Patterns to Avoid

- **Testing/creating the marker before knowing a notice is due.** A clean or failing file would silence the later real notice.
- **`mkdir -p` for the marker.** `-p` succeeds when the directory exists, destroying the test-and-set. Use plain `mkdir`.
- **`[ -d "$m" ]` alone after a failed `mkdir`.** It follows symlinks; use `[ -d "$m" ] && [ ! -L "$m" ]` (D-17). Reproduced: a symlink planted at the marker name makes the hook notify on every call instead of staying silent. [VERIFIED: prototype]
- **A shared `nosession` key** (D-16).
- **Extra JSON keys or `systemMessage`/`suppressOutput` in the object.** Codex's schema rejects unknown keys and marks `suppressOutput` hook runs failed.
- **Prose containing the words `bbj ` (bare), `eval`, `timeout`, `node`, `python`, `jq` on an executable line** of the hook: `tests/test_static_guards.sh` scans executable lines (comments excluded). Use `the plugin option bbj_home`, not "the bbj plugin". The prototype text passes all static gates.
- **Naming the hosted server address** in the text (`docs_host_single_source`); name it `bbj-docs`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Atomic once-per-session flag | lock files, pid files, `test -e && touch` | `mkdir` of one directory | `mkdir` is the POSIX atomic create-or-fail; Claude Code runs hooks of parallel tool calls concurrently |
| JSON string escaping | a new escaper | the existing `sed` approach (`s/\\/\\\\/`, `s/"/\\"/`), one `json_body` helper | same code path as tier 2, already shellcheck-clean |
| JSON validity check in tests | grep on the output | `python3 -I -c 'json.loads(...)'` | the suite already runs Python 3 stdlib; proves the bytes parse |
| Session identity | hashing, pid, tty | the host's `session_id` | present on every PostToolUse payload on both hosts |
| Real-client delivery proof | a mock of the host | the real CLIs, scripted | the only thing that proves the model sees the text |

## Test inventory: what breaks and how to convert (Question 4)

Method: prototype in a scratch copy of the repo; ran the full suite with `BBJ_CHECK_STATE_DIR=/nonexistent/state` so that every no-route call notifies (worst case, order-independent). Baseline before the change: `SUMMARY: ok=447 fail=0 skip=2`. After the prototype, worst case: `ok=429 fail=18 skip=2`. [VERIFIED: runs this session] The static gates (`tests/test_static_guards.sh`, `tests/test_never_execute.sh`, `tests/test_layout.py`) all passed on the prototype: none forbids `mkdir`, `/tmp` or one stdout `printf`; only the content-word scans above matter.

| File | Gate(s) that break | Why | Conversion |
|------|-------------------|-----|------------|
| `tests/test_discovery.sh` | `no_route_silent` (L90-92) | no compiler, closed port | first call: exit 0, stderr empty, compiler not called, stdout is the notice JSON (reason "no compiler found" + "no bbj-ls answering on 127.0.0.1:9"); second call same session: silent. Rename to `no_route_notice_then_silent` |
| | `unusable_output_silent` (L103) | `FAKE_OUT` = Java failure text, tier 2 refused | first call notice with reason "a compiler was found but gave no result"; second call silent |
| | `crash_silent` (L112) | `FAKE_EXIT=139` | same as above |
| `tests/test_exit_contract.sh` | `contract_dash_crashing_compiler`, `contract_bash_crashing_compiler` (and `contract_busybox_crashing_compiler` where busybox exists) (L73) | crash = no verdict, tier 2 refused → notice on stdout (741 bytes in the prototype) | extend `contract()` (L39) with an expectation argument: `empty` (default) or `notice`; for the crash case run twice, `notice` then `empty`. The notice check = stdout parses as exactly one JSON object with keys `hookSpecificOutput` → (`hookEventName`, `additionalContext`) in that order, exit 0, stderr empty. Update the file header comment ("never writes to stdout" → "writes stdout only for the notice") |
| `tests/test_tier2_fake.sh` | `url_refused_*` ×12 (remote_http, hosted_https, lookalike_host, userinfo, query, fragment, https_loopback, ftp, lookalike_localhost, whitespace, upper_scheme, newline) (`refused()` L195) | refused URL = no route, silent was asserted | give each case a fresh state dir; first call: exit 0, curl log empty, notice JSON with "bbj-ls URL refused (not loopback)"; second call silent. Gate names `url_refused_<tag>` can stay |
| | `no_curl_silent` | no curl = no route | first call notice with "curl not found", no request logged; second call silent |

Untouched and still correct (verified passing in the worst-case run): `clean_reply_silent`, `mode_rpc_error_silent`, `mode_garbage_silent` (route failed → silent), `config_skipped_no_request`, `tier1_wins_no_request`, `unusable_compiler_falls_to_tier2`, `url_accepted_*` (they assert curl flags, exit 0 and one call; with the fake curl exiting 7 each also now prints a notice, which they do not check), the whole of `test_codex_patch.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`, `test_real_compiler.sh`, `test_tier2_live.sh`, `test_claude_plugin.sh` (a compiler is present or the file is skipped before any route).

**Hermetic state (required, otherwise results depend on order and on `/tmp`):** `tests/lib.sh` already sets `BBJ_CHECK_DEFAULT_HOMES=` and `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp` (lines 27-30). Add inside `mkwork`: `BBJ_CHECK_STATE_DIR=$WORK/state; mkdir "$WORK/state"; export BBJ_CHECK_STATE_DIR`, plus a helper `fresh_state` that points it at a new empty directory (`$WORK/state.$N`) so each "first call" case starts clean. Make the payload builders take the session id from a variable: `"session_id":"${SESSION_ID:-s1}"` (both fixtures hardcode `s1`, `tests/lib.sh:78,85`). Without this, the first no-route call in a test file notifies and every later one is silent, and the prototype run without the seam left a real marker `/tmp/bbj-check-noroute-s1` behind (I removed it). [VERIFIED: prototype]

**Docs/installer lines that become false** (no gate pins them: I changed them in the prototype and the install-page and installer tests stayed green): `README.md:41` ("a missing compiler is silent"), `docs/install-claude-code.md:105-106` ("Neither route ... does nothing and says nothing"), `docs/install-codex.md:199` (same), `codex/install-codex.sh:787` (Known gaps: "with neither it does nothing and says nothing"). CONTEXT defers docs to Phase 6 unless a gate needs them. Recommendation: correct these four sentences in this phase (one line each); leaving shipped text that contradicts the shipped behaviour is the larger risk. Planner decides; no gate forces it.

## Code Examples

Prototype, verified by `sh -n`, `shellcheck -s sh` 0.11.0, the suite, and the scenario script (dash and bash; first call notice, second silent, other session notifies, no session id notifies every call, unwritable state dir notifies every call, symlink squat notifies every call, quote/backslash/tab/Latin-1 file names give valid JSON, 8 files cap to 5 plus "and 3 more"). [VERIFIED: prototype runs]

```sh
# no_tier1_route: return 0 verdict reached, 1 no route (NR_T2 says why), 2 route failed
  case "$_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) NR_T2=badurl; return 1 ;;
  esac
  _ok=$(printf '%s' "$_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_ok" = ok ] || { NR_T2=badurl; return 1; }
  command -v curl > /dev/null 2>&1 || { NR_T2=nocurl; return 1; }
  NR_HOSTPORT=$(printf '%s' "$_url" | sed -E 's#^http://([^/]*).*$#\1#')
  ...
  _reply=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 ... --url "$_url" 2> /dev/null)
  _rc=$?
  # exit 7 (connection refused) is the only "nothing listens" answer; every other failure
  # reached something: route failed
  [ "$_rc" = 7 ] && { NR_T2=refused; return 1; }
  [ "$_rc" = 0 ] && [ -n "$_reply" ] || return 2
  ... # JSON-RPC error / isError / text with neither verdict: return 2
  ... # "No errors found." : return 0 ;  errors: report bbj-local "$_errs"; return 0

# check_file: the two call sites
  if ! discover; then
    no_tier1_route
    [ "$?" = 1 ] && note_noroute none
    return 0
  fi
  ...
    if [ -n "$out" ] || [ "$rc" -ge 126 ]; then
      no_tier1_route
      [ "$?" = 1 ] && note_noroute noresult
    fi

# collector and escaper
note_noroute() {
  NR_N=$((NR_N + 1))
  NR_LIST=$NR_LIST$file$nl
  [ -n "$NR_COMPILER" ] || NR_COMPILER=$1
}
json_body() {   # stdin -> inside of a JSON string; ASCII-safe, always valid JSON
  LC_ALL=C sed -e 's/[^ -~]/?/g' -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# notice TOOL SID: marker test-and-set, then ONE printf
notice() {
  _key=$(printf '%s' "$2" | LC_ALL=C tr -cd 'A-Za-z0-9_-' | head -c 64)
  if [ -n "$_key" ]; then
    _state=${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}
    _m=$_state/bbj-check-noroute-$_key
    if ! mkdir "$_m" 2> /dev/null; then
      if [ -d "$_m" ] && [ ! -L "$_m" ]; then return 0; fi
    fi
  fi
  ...build _why1/_why2/_files/_how/_txt...
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' \
    "$(printf '%s written but %s' "$_files" "$_txt" | json_body)"
  return 0
}

# main, after the case on $tool and after the FAILED=1 / exit 2 block:
  if [ "$NR_N" -gt 0 ]; then
    sid=$(printf '%s' "$hd" | jget pre session_id)
    [ -n "$sid" ] || sid=$(printf '%s' "$input" | jget all session_id)
    notice "$tool" "$sid"
  fi
  exit 0
```

Notes the planner should carry into tasks:
- The prototype's prose is a draft. Final text must use D-09's reason strings exactly (`bbj-ls URL refused (not loopback)`, `curl not found`, `no bbj-ls answering on <host:port>`, `no bbjcpl found` / `bbjcpl found but gave no result`; the draft used shorter wordings) and read grammatically for several files ("Not compile-checked: a.bbj, b.bbj"). Draft length 637-766 characters; 5 paths cap; add `cut -c1-200` per path to bound it (about 2.2k characters worst case, far under both caps). A gate should assert length < 10,000 for a 5-path worst case.
- `json_body` replaces every byte outside printable ASCII with `?` (so `café.bbj` shows as `caf??.bbj`) and escapes backslash and quote. Reason: with the existing tier-2 pass-through approach, a Latin-1 file name produced **invalid UTF-8 and `json.loads` failed** in the prototype (`UnicodeDecodeError: invalid continuation byte`); an invalid object would be dropped or ignored by the host and the model would never be told. This still satisfies D-10 (backslash, quote and control characters escaped); the cost is cosmetic. [VERIFIED: prototype both ways]
- Static prose lines: the `_how` strings contain `bbj_home`, `bbj-local@basis-bbj`, `BBJ_HOME`, `bbjcpl`, `install-codex.sh`; none matches a static-guard regex. The hook script is not subject to the `compiler_name` (`bbjcpl`) scan, which applies only to `codex/*.sh`.
- Header block of `bbj-check.sh` (lines 9-10, 27, 46-47) must be rewritten: the "no output at all" and "stdout stays empty and the exit code is only ever 0 or 2" sentences become "stdout is written in exactly one case, the notice". Add the curl classification table there (D-03 asks for it).
- Codex fallback (D-15) is a three-line switch in `main`: for `apply_patch` and a won marker, print the same body to stderr with the first sentence "The patch was applied and the file was written; it was not compile-checked." and `exit 2`. Implement it only if the Codex capture shows non-delivery; the contract test then asserts exit 2 + empty stdout for Codex no-route.

## Delivery capture (HOOK-04, D-13, D-14) (Questions 2 and 6)

### Facts about this machine [VERIFIED: probes this session]

| Item | State |
|------|-------|
| Codex | `codex-cli 0.156.1`, `codex login status`: logged in with an API key (a model call is billed) |
| Claude Code | `2.1.296`, `claude auth status`: logged in (claude.ai); the `bbj` plugin is NOT installed in the real config (`claude plugin list` shows only figma and synthesia-video), so no double hook |
| BBj | `/opt/bbx` exists with `bin/bbjcpl`; default homes include `/opt/bbx`; `bbjcpl` not on PATH |
| bbj-ls | `GET http://127.0.0.1:5009/mcp` → HTTP 405 (live) |
| `~/.codex/hooks.json` | absent; `~/.agents` absent |

Consequence: to simulate "no route" the hook command must run with `BBJ_CHECK_DEFAULT_HOMES=` (empty, documented test seam in the hook header lines 59-61) and `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`, and a scratch `BBJ_CHECK_STATE_DIR`. These env vars are exported to the client process (Claude Code) or set with `env` in the hook command (Codex).

### Codex (scripted `codex exec`)

Confirmed in `codex exec --help` (0.156.1): `--dangerously-bypass-hook-trust` ("Run enabled hooks without requiring persisted hook trust for this invocation. DANGEROUS. Intended only for automation that already vets hook sources"), `--ignore-user-config` ("Do not load `$CODEX_HOME/config.toml`; auth still uses `CODEX_HOME`"), `-C/--cd`, `-c key=value` (TOML override), `--json` (JSONL events), `-o/--output-last-message FILE`, `--skip-git-repo-check`, `--ephemeral`, `-s read-only|workspace-write|danger-full-access`. The docs list hook locations `~/.codex/hooks.json`, `<repo>/.codex/hooks.json` and say project-local hooks load only when the project `.codex/` layer is trusted. [VERIFIED: codex exec --help; CITED: learn.chatgpt.com/docs/hooks]

Recommended recipe (the end-to-end run itself was not made here, it is a billed model call; flags above are confirmed, the combination is `[ASSUMED]` until the first run):

1. Scratch project `S=$(mktemp -d)`; `git init`; project-local `S/.codex/hooks.json` with the same entry the installer writes (`PostToolUse`, matcher `apply_patch|Edit|Write`, `timeout` 30) whose `command` is `env BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp BBJ_CHECK_STATE_DIR=$S/state sh <path to the script under test>`. To record the real payload (key order, `session_id`) wrap the script: `sh -c 'tee -a "$S/payload.jsonl" | env ... sh script'`. Installer fidelity: `sh codex/install-codex.sh --codex-home "$S/codexhome" --skills-dir "$S/skills"` produces the generated hooks.json and script copy; reuse its `command` string. Caution: step 1 of the installer runs `codex mcp add` when `codex` is on PATH, which can write the real Codex config, so run it with `CODEX_HOME="$S/codexhome"` exported and `tests/fake-bin/codex` first on PATH (the way `tests/test_install_codex.sh` does), or just read the `printf` template at `codex/install-codex.sh:757` instead of running it.
2. Run: `codex exec --ignore-user-config --dangerously-bypass-hook-trust -C "$S" -c 'projects."'"$S"'".trust_level="trusted"' --json -o "$EVID/codex-last.txt" "<prompt>" > "$EVID/codex-events.jsonl"`. Prompt: create `hello.bbj` containing one `print "hi"` line with `apply_patch`; then create a second `.bbj` with `apply_patch`; finally quote verbatim every hook message or developer context received after each patch, or write `NONE`. Expected evidence: first patch quote contains the notice, second says `NONE` (once-per-session).
3. Save under the phase directory: events JSONL, last message, `payload.jsonl`, the exact command line, `codex --version`. Do not commit anything from `~/.codex`.
4. Trust alternatives: (A) `--dangerously-bypass-hook-trust` as above (one invocation, nothing persisted); (B) D-13's original wording: run interactive `codex` once in the scratch project, approve in `/hooks`; the approval is stored as `hooks.state."<key>".trusted_hash` in the active `CODEX_HOME` config.toml, then use plain `codex exec`. (B) with a scratch `CODEX_HOME` needs credentials there (copying `auth.json` or `CODEX_API_KEY`); avoid copying the user's credentials. Because (A) deviates from D-13's "user approves /hooks once" and the flag is labelled dangerous, make the choice a `checkpoint:decision` for the user. A changed script or command is a changed hook: re-run the trust step after any edit.
5. Decision rule (HOOK-04): the model quoting the notice after `apply_patch` = delivered, keep exit 0 + JSON for Codex. If the model reports no hook message while the payload log proves the hook ran and printed the JSON, implement the D-15 fallback for `apply_patch` and re-run the capture. Record the outcome either way. If the hook did not run at all, that is a trust/config problem, not a delivery result: fix and re-run.

Known unknowns for the first run, none verifiable without the call: whether `codex exec` honours project-local hooks via the `-c projects...trust_level` override; whether the JSONL events or the session rollout under `~/.codex/sessions` show hook output (the model quote is the proof, the JSONL is supporting). A scan of the existing 2026 rollouts found no `hook_event_name` or `PostToolUse` record, so the rollout may not log hook inputs. If the real `~/.codex/sessions` gets a new rollout from the run, `codex delete <id>` removes it afterwards (subcommand listed in `codex --help`).

### Claude Code (`claude -p`)

`claude -p "<prompt>" --plugin-dir <home>/repos/bbj-agent-plugins/plugins/bbj --permission-mode acceptEdits --allowedTools Write --strict-mcp-config --output-format stream-json --verbose --include-hook-events --no-session-persistence` run with cwd = a scratch directory and the environment `BBJ_CHECK_DEFAULT_HOMES= BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp BBJ_CHECK_STATE_DIR=<scratch>/state` (unset `BBJ_HOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`). Flags confirmed in `claude --help`: `--plugin-dir` ("for this session only"), `--include-hook-events`, `--strict-mcp-config`, `--no-session-persistence`, `--permission-mode`, `--allowedTools`. `--plugin-dir` avoids installing into any config and the real config needs no change, so the scratch `CLAUDE_CONFIG_DIR` (which would have no login) is not needed; `tests/test_claude_plugin.sh` already proves the local-marketplace install path in a throwaway config dir, so D-14's "plugin loaded from the local marketplace" is satisfied by that gate plus this run. [VERIFIED: claude --help; CITED: code.claude.com/docs/en/headless]
Prompt: write `hello.bbj` with one `print "hi"` line using the Write tool, then write a second `.bbj`, then quote verbatim any hook context seen after each write or say `NONE`. Expected: first write quotes the notice, second `NONE`. Do not use `--bare` (skips hooks and system reminders). If `--include-hook-events` does not emit PostToolUse hook events, the model's quote plus the `stream-json` transcript is the evidence `[ASSUMED]`. Claude Code runs inside Claude Code here (`CLAUDECODE` set); if the nested run misbehaves, unset the `CLAUDE_CODE_*` session variables for the child process.

Cost control: each capture is one short two-write conversation; add `--max-budget-usd` for Claude Code. Do not run more than these two captures plus one re-run each.

## Common Pitfalls

### Pitfall 1: The notice is dropped silently because the JSON is invalid
**What goes wrong:** a file name with a non-UTF-8 byte, a stray control character, or an unescaped quote produces output the host cannot parse; Codex marks the hook run invalid, Claude Code treats non-JSON stdout as plain text. The model is never told.
**How to avoid:** `json_body` as above (printable ASCII only, backslash and quote escaped); gate with `python3 -I json.loads` on hostile names, including a Latin-1 byte, a tab, a quote and a backslash.
**Warning signs:** `UnicodeDecodeError` or `JSONDecodeError` in the notice gate.

### Pitfall 2: Marker consumed by a call that did not notify
**What goes wrong:** creating the marker early (at the first route miss, or in a call that then exits 2) means the later real notice is swallowed.
**How to avoid:** only `notice`, called after the `FAILED=1` branch, touches the marker; gate: an exit-2 call followed by a no-route call in the same session still notifies.

### Pitfall 3: Existing silent-path tests pass for the wrong reason
**What goes wrong:** with a shared state dir and the fixed `session_id` `s1`, only the first no-route call per file notifies; converted tests then pass or fail depending on order, and a marker in `/tmp` leaks between runs.
**How to avoid:** `fresh_state` per case, `SESSION_ID` variable, `BBJ_CHECK_STATE_DIR` always exported by `mkwork`; one gate asserting that a second session id notifies again.

### Pitfall 4: Route failed reported as no route
**What goes wrong:** classifying exit 28/52/56 or an empty reply as no route makes the notice claim "no bbj-ls answering" while one is up but slow. Real `bbj-ls` is live on this machine, so this is observable.
**How to avoid:** only exit 7 → no route; gate each other code through `FAKE_CURL_EXIT` and the new fake modes.

### Pitfall 5: The Codex hook is skipped after the script changes
**What goes wrong:** Codex records trust against the hook's hash; the edited script or command makes the hook "skipped until trusted", the capture shows no hook output and looks like a delivery failure.
**How to avoid:** the capture task re-establishes trust (flag or `/hooks`) after the last edit; check the payload log to tell "hook did not run" from "ran, not delivered". The installer already tells users to re-approve (line 739); CHANGELOG wording is Phase 6.

### Pitfall 6: The model surfaces or ignores the text instead of treating it as context
**What goes wrong:** Claude Code's docs warn imperative out-of-band phrasing can trigger prompt-injection defenses ("surface the text to you instead of treating it as context").
**How to avoid:** factual first sentences, one plain closing request to tell the user (D-07); judge by the D-14 transcript. A model that tells the user directly is the desired outcome.

### Pitfall 7: Real BBj on the developer machine hides the no-route path
**What goes wrong:** `/opt/bbx` is a default home and bbj-ls answers on 5009 here, so any manual or captured run finds a route.
**How to avoid:** the seams `BBJ_CHECK_DEFAULT_HOMES=` and `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp` in every capture; tests already set both in `tests/lib.sh`.

### Pitfall 8: Marker squatting and `TMPDIR`
**What goes wrong:** a pre-created non-directory or symlink at `<state>/bbj-check-noroute-<id>` could suppress notices if tested with `-e` or `-d` alone.
**How to avoid:** `[ -d ] && [ ! -L ]` (D-17); the session id is a UUID from the host, sanitised to `[A-Za-z0-9_-]` (hyphens kept so UUIDs survive intact, `tr -cd`, `head -c 64`).

## State of the Art

| Old approach | Current approach | Impact |
|--------------|------------------|--------|
| Hook exits 0 silently when nothing can check | exit 0 + one JSON `additionalContext` once per session | the agent can tell the user a file was not checked |
| exit 2 + stderr as a notice (ARCHITECTURE.md §D) | superseded by SUMMARY.md Reconciliation 1 | on Codex exit 2 replaces the tool result, making an unchecked file look like an error |

**Superseded in this phase:** the no-session shared key and the unwritable-dir rules of ARCHITECTURE.md §D (D-16, D-17).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | curl exit codes other than 1, 7, 18, 28, 52, 56 (e.g. 6) behave as "reached or failed to try, not refused" and map to "route failed" | Curl classification | Low: only changes whether a rare setup is told or silent; conservative direction |
| A2 | `codex exec` honours a project-local `.codex/hooks.json` once the project is marked trusted via `-c projects."<path>".trust_level="trusted"`, together with `--ignore-user-config` and `--dangerously-bypass-hook-trust` | Delivery capture | Medium: capture recipe needs adjusting; fallback is interactive `/hooks` approval in a scratch project |
| A3 | `claude -p --include-hook-events` emits PostToolUse hook events (docs only name SessionStart/Setup examples) | Delivery capture | Low: the model's quote is the primary evidence |
| A4 | Codex's real PostToolUse payload orders `session_id` before `tool_input` (unknown; the fallback `jget all` covers both) | Contract | Low with fallback; without it D-16 would notify on every call |
| A5 | busybox `sh`, `tr -cd`, `head -c` and `sed [^ -~]` behave like GNU here (busybox not installed on this host, CI may have it) | Code Examples | Low: gated by `test_exit_contract.sh` where busybox exists |
| A6 | `/clear` starts a new Claude Code `session_id` (so a new notice) | D-19 | Very low: only affects how often the notice repeats |
| A7 | The Codex hook-trust key under `hooks.state` is derived by Codex and cannot be pre-seeded by hand reliably | Delivery capture | Low: the flag avoids the need |

## Open Questions

1. **Flag vs `/hooks` approval for the Codex capture**
   - Known: `--dangerously-bypass-hook-trust` exists in 0.156.1 and is per invocation; D-13 says the user approves `/hooks` once.
   - Unclear: user preference (the flag is labelled dangerous; the hook source is this repo's own script).
   - Recommendation: `checkpoint:decision` in the plan; default to the flag in a scratch project.
2. **Non-ASCII file names in the notice** show as `?` per byte. Acceptable (names only identify the file); the alternative (pass UTF-8 through) risks an invalid object on Latin-1 names. Recommendation: keep `?`.
3. **Fix the four stale doc/installer sentences now or leave to Phase 6?** (README:41, docs/install-claude-code.md:105, docs/install-codex.md:199, install-codex.sh:787). Recommendation: fix now, one line each, no gate depends on them.
4. **Real Codex payload key order** unknown until the first capture; handled by fallback.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| dash, bash | tests | ✓ | system | — |
| busybox sh | `test_exit_contract.sh` extra shell | ✗ | — | gate skips (as today) |
| python3 | tests, JSON validation | ✓ | 3.14 | — |
| curl | hook, tests | ✓ | 8.18.0 | — |
| ShellCheck | CI `ci_shellcheck` | ✗ on host | — | lint locally via a pip target (`shellcheck-py` 0.11.0 worked in the scratchpad); CI installs it |
| Codex CLI | HOOK-04 capture | ✓ | 0.156.1, API-key login (billed) | — |
| Claude Code CLI | D-14 capture | ✓ | 2.1.296, claude.ai login | — |
| Real BBj | seams needed in captures | ✓ present (`/opt/bbx`) | — | — |
| bbj-ls on 5009 | seams needed in captures | ✓ live (405 to GET) | — | — |

**Missing with no fallback:** none. **Note:** no model call was made in this research; `codex exec` and `claude -p` were only probed through `--help`.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | custom POSIX sh + Python 3 gate harness (`tests/lib.sh`, `tests/run.sh`) |
| Config file | none (`.shellcheckrc` for lint) |
| Quick run command | `sh tests/test_noroute_notice.sh && sh tests/test_exit_contract.sh && sh tests/test_discovery.sh && sh tests/test_tier2_fake.sh && sh tests/test_static_guards.sh` (about 9 s) |
| Full suite command | `sh tests/run.sh` (about 63 s; ends `SUMMARY: ok=N fail=M skip=K`) and `sh tests/ci.sh` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| HOOK-01 | clean / errors / route failed / early skips never notify; no route notifies | integration (fake compiler, fake curl, fake server) | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-01 | curl 7 → no route; 28, 52, 56, 0+empty → silent; fake modes `is-error`, `empty`, `no-verdict`, existing `rpc-error`, `garbage` → silent | integration | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 (needs `FAKE_CURL_EXIT`, new fake modes) |
| HOOK-01 | D-02: compiler with junk output + tier 2 refused → notice "gave no result"; + tier 2 rpc-error → silent | integration | `sh tests/test_noroute_notice.sh` and converted `unusable_output_*` in `tests/test_discovery.sh` | partial ✅ |
| HOOK-01 | D-04: one error file + one no-route file → exit 2, stdout empty; clean file + no-route file → notice naming only the no-route file | integration (per-file fake compiler as in `tests/test_codex_patch.sh` `home2`) | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-02 | stdout is exactly one JSON object `{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":<string>}}`, exit 0, stderr empty; parses with `json.loads`; length < 10,000 | unit/integration | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-02 | text content: names file path(s), reason (D-09 strings), "not compile-checked", later files not checked and not repeated, Claude text has `bbj_home` and `bbj-local@basis-bbj`, Codex text has `BBJ_HOME` and `--with-local`, hosted clause has `bbj_check_syntax`, "sends the code", "stock BBj", no hosted address; own grammar (never the `reported N error(s)` header) | integration | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-02 | once per session: first call notice, second silent; a different `session_id` notifies; missing `session_id` notifies every call; symlink at marker, unwritable or missing state dir → notifies every call; exit-2 call does not consume the marker; dash and bash | integration | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-02 | path escaping: quote, backslash, tab, Latin-1 byte, 8 files → "and 3 more", JSON stays valid | integration | `sh tests/test_noroute_notice.sh` | ❌ Wave 0 |
| HOOK-02 | `BBJ_CHECK_STATE_DIR` seam exported hermetically; no `/tmp` leak | harness | `sh tests/test_noroute_notice.sh` (asserts `$WORK/state` holds the marker, `/tmp` has none new) | ❌ Wave 0 |
| HOOK-03 | contract amended narrowly: stdout empty except the notice case; exit only 0 or 2; crash case = notice then empty | integration, dash/bash/busybox | `sh tests/test_exit_contract.sh` | ✅ edit |
| HOOK-03 | silent-path conversions (18 gates) | integration | `sh tests/test_discovery.sh`, `sh tests/test_tier2_fake.sh`, `sh tests/test_exit_contract.sh` | ✅ edit |
| HOOK-03 | static guards still pass with the new script text | static | `sh tests/test_static_guards.sh` and `shellcheck -s sh plugins/bbj/scripts/bbj-check.sh tests/*.sh` (CI) | ✅ |
| HOOK-04 | real Codex: after `apply_patch` the model quotes the notice, second patch `NONE`; payload logged | manual-scripted, billed; evidence committed | scripted `codex exec` recipe above | ❌ Wave N (task with evidence files) |
| HOOK-04 | real Claude Code: same with `Write` | manual-scripted, billed | scripted `claude -p` recipe above | ❌ Wave N |
| HOOK-04 | outcome recorded; if Codex not delivered: Codex no-route = exit 2, stderr body, stdout empty, first sentence "patch was applied" | integration (only if fallback is implemented) | `sh tests/test_noroute_notice.sh` | conditional |

### Sampling Rate
- **Per task commit:** the quick run command above (about 9 s), plus `sh -n` on touched scripts.
- **Per wave merge:** `sh tests/run.sh` (about 63 s) with expected `fail=0`.
- **Phase gate:** `sh tests/ci.sh` green (shellcheck needs CI or a local install) and both evidence transcripts committed before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `tests/test_noroute_notice.sh` — HOOK-01/02/03 behaviour gates (prefix `notice_`)
- [ ] `tests/lib.sh` — export `BBJ_CHECK_STATE_DIR=$WORK/state` in `mkwork`, `fresh_state`, `SESSION_ID` in both payload builders
- [ ] `tests/fake-bin/curl` — `exit "${FAKE_CURL_EXIT:-7}"`; optional `FAKE_CURL_OUT` file to print
- [ ] `tests/fake_mcp.py` — modes `is-error` (result with `"isError": true`), `empty` (HTTP 200, empty body), `no-verdict` (JSON result whose text is neither verdict); docstring updated. (CONTEXT lists "error, isError, junk, slow" but `slow` and `isError` do not exist today; `slow` is not worth building because the hook's `-m 12` makes it a 12 s test: use `FAKE_CURL_EXIT=28`.)
- [ ] `.planning/phases/02-hook-no-route-notice/evidence/` — captured transcripts

## Security Domain

`security_enforcement` is enabled (config: `security_asvs_level: 1`, `security_block_on: high`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | partly | `session_id` is used only as a sanitised file-name key; never as a secret |
| V4 Access Control | partly | marker directory in a user-controlled temp dir; symlink and non-directory squatting handled by `[ -d ] && [ ! -L ]`, fail toward telling |
| V5 Input Validation | yes | `session_id` reduced to `[A-Za-z0-9_-]`, 64 chars; file paths escaped to printable ASCII; loopback URL validation unchanged; no file content reaches a command |
| V6 Cryptography | no | — |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Hostile file name breaks the JSON or injects keys | Tampering | `json_body` (printable ASCII only, backslash and quote escaped), `json.loads` gate on hostile names |
| File name carries instruction text that lands in the agent's context | Tampering / Elevation | path comes from a file the agent itself wrote or named; names capped at 5 paths and 200 chars; the notice states facts; residual risk accepted (the agent already sees the name in its own tool call) |
| Planted symlink or file at the marker path silences or redirects | Spoofing / DoS | `mkdir` without `-p`; only a real non-symlink directory counts as "already told"; no write through the path |
| Marker path escape via `session_id` (`../`) | Tampering | `tr -cd 'A-Za-z0-9_-'` removes `/` and `.` |
| Hook calls the hosted check or any non-loopback URL | Information disclosure | unchanged: loopback-only URL literal gate, `curl` flags gate, `test_never_execute.sh` |
| Notice text reveals the hosted server address | Information disclosure | text names `bbj-docs` only; `docs_host_single_source` gate |
| Using `--dangerously-bypass-hook-trust` as habit | Elevation | scratch project only, our own script, single invocation, user checkpoint |

## Sources

### Primary (HIGH confidence)
- https://code.claude.com/docs/en/hooks — PostToolUse input example, `additionalContext` shape and delivery, exit-code table, 10,000 character cap, style advice
- https://code.claude.com/docs/en/headless — `claude -p`, `--bare` skips hooks and system reminders, `--plugin-dir`, permission modes, stream-json events
- https://learn.chatgpt.com/docs/hooks (redirect of developers.openai.com/codex/hooks) — Codex PostToolUse fields and output, trust, `additionalContextLimit`, hook locations, `--dangerously-bypass-hook-trust`
- https://raw.githubusercontent.com/openai/codex/main/codex-rs/hooks/schema/generated/post-tool-use.command.output.schema.json and `...input.schema.json` — wire schemas
- Local: `codex exec --help`, `claude --help`, `codex-cli 0.156.1` binary strings (`hooks.state`, `trusted_hash`, error messages)
- Repository files read this session: `plugins/bbj/scripts/bbj-check.sh`, `tests/lib.sh`, `tests/test_exit_contract.sh`, `tests/test_static_guards.sh`, `tests/test_never_execute.sh`, `tests/test_tier2_fake.sh`, `tests/test_discovery.sh`, `tests/test_hook_review_fixes.sh`, `tests/test_codex_patch.sh`, `tests/test_claude_plugin.sh`, `tests/test_tier2_live.sh`, `tests/fake_mcp.py`, `tests/fake-bin/{bbjcpl,curl}`, `codex/install-codex.sh`, `plugins/bbj/hooks/hooks.json`
- Reproduced runs: curl exit codes against local servers; prototype in a scratch copy (suite, shellcheck 0.11.0, scenario script under dash and bash)

### Secondary (MEDIUM confidence)
- WebSearch result on third-party blogs for `hooks.state` trust storage (consistent with the binary strings; key derivation not confirmed)

### Tertiary (LOW confidence)
- none relied on

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new dependencies; all tools present and exercised
- Architecture: HIGH — prototype passes the existing suite apart from the predicted 18 gates
- Pitfalls: HIGH for items reproduced (invalid UTF-8, symlink squat, marker order); MEDIUM for Codex trust behaviour (docs + binary strings, no run)
- Delivery capture recipe: MEDIUM — flags confirmed, combination untried (billed)

**Research date:** 2026-10-10
**Valid until:** 2026-11-09 for the Claude Code and Codex contracts (both CLIs ship weekly; re-check `codex exec --help` flags and the output schema if the Codex version moves past 0.156.1)
