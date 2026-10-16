---
last_mapped_commit: 8530cf7384421303e5895ea3625b8ca192ec9142
last_mapped_at: 2026-10-16
---
<!-- refreshed: 2026-10-16 -->

# Architecture

**Analysis Date:** 2026-10-16

## System Overview

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                     Coding agent (Claude Code / Codex)                    │
└───────┬───────────────────────────┬──────────────────────────┬───────────┘
        │ MCP (HTTP, OAuth)          │ MCP (HTTP, loopback)     │ PostToolUse hook
        ▼                            ▼                          ▼
┌───────────────────┐   ┌──────────────────────────┐   ┌─────────────────────────┐
│ docs server `bbj` │   │ bbj-ls (BBjServices,     │   │ bbj-check.sh            │
│ (hosted)          │   │ 127.0.0.1:5009/mcp)      │   │ `plugins/bbj/scripts/`  │
│ `plugins/bbj/     │   │ `plugins/bbj-local/`     │   │  tier 1: bbjcpl -t -N -X│
│  .mcp.json`       │   │  `.mcp.json`             │   │  tier 2: bbj-ls check   │
│ `.codex-mcp.json` │   └──────────────────────────┘   └────────────┬────────────┘
└───────────────────┘                                               │ reads file
                                                                    ▼
                                                     ┌─────────────────────────┐
                                                     │ Workspace BBj files      │
                                                     │ (.bbj .src .bbx)         │
                                                     └─────────────────────────┘

Static content (no runtime code of its own):
  `plugins/bbj/skills/*/SKILL.md` + `references/*.md`   (read by agent)

Distribution:
  `.claude-plugin/marketplace.json` ──> `plugins/bbj`, `plugins/bbj-local`
  `plugins/bbj/.codex-plugin/plugin.json` ──> Codex overlay of the plugin `bbj`
                                              (MCP file `plugins/bbj/.codex-mcp.json`)
```

This is a plugin repository, not an application. It has no server, database or build
output of its own. Its "runtime" is the set of declarative manifests, one POSIX shell hook
script, and static skill documents that a host agent loads. Both clients install the same plugin
`bbj` from the marketplace `basis-bbj`: Claude Code with `claude plugin install bbj@basis-bbj`,
Codex with `codex plugin add bbj@basis-bbj` (the Codex plugin route, the only Codex route).

## Pattern Overview

**Overall:** Declarative plugin bundle with a single stateless hook script. Each plugin is a
directory of manifests plus content; behaviour lives in the host agent and in the remote or
local MCP servers the manifests point at.

**Key Characteristics:**
- No compiled code and no package-managed runtime. The only executables are POSIX `sh`
  (`plugins/bbj/scripts/bbj-check.sh`, the `command` of `plugins/bbj/hooks/hooks.json`) and the
  test suite under `tests/`; on Windows a PowerShell string (`commandWindows`) finds Git for
  Windows' `sh.exe` and runs the same script.
- The hook is deliberately stateless: each invocation reads its input
  from stdin or from the file system and exits with 0 or 2. The one exception is the
  once-per-session marker of the no-route notice, a directory in `BBJ_CHECK_STATE_DIR` (default
  the temp directory).
- BBj code is never executed. The check path calls the BBj compiler with `-N` (compile-only)
  or sends source text to the `bbj_check_syntax` tool of the local `bbj-ls` over loopback. Tests
  enforce this (`tests/test_never_execute.sh`, `tests/test_static_guards.sh`).
- Two MCP servers are declared, not implemented here: the hosted docs server `bbj` (URL from
  the `docs_url` user option in Claude Code, a literal URL in `plugins/bbj/.codex-mcp.json`) and
  `bbj-ls`, the language server of BBjServices on `127.0.0.1:5009`, registered by the plugin
  `bbj-local`.
- The skills are maintained in this repository under the normal tests (`tests/test_layout.py`).
  Their fenced examples are also gated by `tests/test_skill_examples.py`.

## Layers

**Distribution layer (manifests):**
- Purpose: Declare plugins, their MCP servers, hooks and user options to the host.
- Location: `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`,
  `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`
- Contains: JSON manifests; `userConfig` for `docs_url` and `bbj_home` in the `bbj` plugin;
  the Codex overlay, whose `mcpServers` points at `./.codex-mcp.json`;
  `defaultEnabled: false` for `bbj-local`.
- Depends on: The host's plugin loader (`claude plugin validate --strict` in CI).
- Used by: `claude plugin marketplace add` / `claude plugin install` (see `README.md`).
  Codex uses `codex plugin add` (see `docs/install.md`).

**Connection layer (MCP declarations):**
- Purpose: Tell the host where the BBj MCP servers are.
- Location: `plugins/bbj/.mcp.json` (the docs server `bbj`, URL `${user_config.docs_url}`),
  `plugins/bbj/.codex-mcp.json` (the docs server `bbj` for Codex, literal URL),
  `plugins/bbj-local/.mcp.json` (`bbj-ls`, `http://127.0.0.1:5009/mcp`)
- Contains: Transport type `http`, the URL and, for the docs server, the pre-registered OAuth
  client (client id, callback port 47613, scope `offline_access`). No tool definitions live here.
- Depends on: Remote hosted server, or a BBjServices instance on the same machine.
- Used by: The host agent, which exposes `bbj_lookup`, `bbj_search`, `bbj_examples`,
  `bbj_reserved_word`, `bbj_fetch_page`, `bbj_check_syntax`, `bbj_format`, `bbj_denum`.

**Enforcement layer (hook):**
- Purpose: Compile-check every BBj file the agent writes or edits, and return compiler
  errors to the agent as feedback.
- Location: `plugins/bbj/hooks/hooks.json` (PostToolUse, matcher `Write|Edit`, 30 s timeout)
  runs `plugins/bbj/scripts/bbj-check.sh`. `command` is `sh` on the script; `commandWindows`
  looks for Git for Windows' `sh.exe` in a fixed order (Program Files, Program Files (x86),
  `%LOCALAPPDATA%\Programs\Git`, a Git `sh` on `PATH`, the folder of a `git` on `PATH`), prints a
  loud not-found message and exits 2 when none exists and the payload names a BBj file, and passes
  the script's exit code through.
- Contains: Tool-input parsing (`jget`, `UNESC_AWK`), compiler discovery (`discover`,
  `find_cpl_in_home`, `find_cpl_on_path`, `resolve_link`), per-file check (`check_file`), tier 2
  loopback call (`no_tier1_route`), Codex `apply_patch` branch (`codex_patch`, `wpath_norm`), the
  feedback writer (`report`), the no-route notice (`note_noroute`, `notice`, `json_body`), and
  `main`.
- Depends on: A BBj compiler (`bbjcpl` / `bbjcplw`) or a running `bbj-ls`; `curl` for tier 2.
- Used by: The host, after every matching tool call.
  The calls are `Write` and `Edit`, and `apply_patch` in Codex.

**Content layer (skills and guidance):**
- Purpose: Teach the agent BBj syntax, web (DWC) development and the rules agents get wrong.
- Location: `plugins/bbj/skills/bbj-programming/` (`SKILL.md` and `references/*.md`),
  `plugins/bbj/skills/bbj-web-programming/` (`SKILL.md` and `references/*.md`, four files each)
- Contains: Markdown only. Skills are loaded by the host on demand; references are read on
  demand from `SKILL.md`. Both `SKILL.md` files carry the same check-order block.
- Depends on: Nothing executable. Content describes the tools of the docs server `bbj` and of `bbj-ls` by name.
- Used by: The host agent's skill loader (the plugin cache for
  Claude Code and for Codex).

**Verification layer (tests and CI):**
- Purpose: Gate every change to manifests, hook and skills.
  It also gates the text of the README, the install page and the CHANGELOG.
- Location: `tests/run.sh` (runner), `tests/ci.sh` (entry point), `tests/test_*.sh` and
  `tests/test_*.py`, fixtures in `tests/fake-bin/` and `tests/fake_mcp.py`,
  `.github/workflows/ci.yml`, `.github/ci-tools/` (pinned `claude` CLI).
- Contains: Shell and Python tests that print `gate NAME ok|FAIL|skip` lines and a
  `SUMMARY:` line, then the `run_prefix_block` gate. The CI job runs `sh tests/ci.sh` with `CI=true`.
- Depends on: `python3`, `shellcheck`, `claude` CLI (mandatory in CI, skipped locally).
- Used by: GitHub Actions on push and pull request.

## Data Flow

### Primary Request Path: BBj file written by the agent

1. The agent calls `Write` or `Edit` on a `.bbj`, `.src` or `.bbx` file. The host runs the
   PostToolUse hook declared in `plugins/bbj/hooks/hooks.json` (`command`, or `commandWindows`
   on Windows).
2. `main` in `plugins/bbj/scripts/bbj-check.sh` reads the hook JSON from stdin, takes
   `tool_name`, `tool_input.file_path` and `cwd` with `jget`, and dispatches on tool name.
3. `check_file` skips non-BBj names, symlinks and `config*.bbx` files (exit 0, silent).
4. Tier 1: `discover` locates a compiler (plugin option, `BBJ_HOME`, `BBJHOME`, `PATH`,
   default homes). The compiler runs as `<cpl> -t -N -X -P<dirs> <file>` with stdin from
   `/dev/null`. Its verdict is read from stderr, not the exit code.
5. Tier 2 (no usable compiler): `no_tier1_route` posts the file text to `bbj_check_syntax` of
   `bbj-ls` at a loopback URL only, via `curl --noproxy '*' --proto =http`. Only syntax errors are
   reported. The outcome "nothing reached" (`NR_T2` = `refused`, `nocurl`, `badurl` or `noconn`)
   is remembered for the rest of the hook run, so the other files of one `apply_patch` skip curl
   and are still listed in the notice. `noconn` is a curl connect timeout (exit 28) whose
   write-out shows no connection; a reached but slow `bbj-ls` is not cached and costs up to 12 s
   per file.
6. Errors go to stderr in the fixed format (at most 40 lines per block). `main` prints the
   `bbj_lookup` pointer and exits 2; otherwise it exits 0 silently.
7. No route at all (no compiler, tier 2 is no route) and no failing file: `notice` writes the
   one-line JSON no-route notice on stdout, once per session (marker directory with an exclusive
   claim file). The text names the files, the reasons, how to enable a check (one text for
   `apply_patch`, one for the other tools) and the hosted check as the agent's fallback, with its
   disclosure that it sends the code to a server.

### Secondary Flow: Codex `apply_patch`

1. Codex sends a payload with `tool_name` `apply_patch` and the patch text in
   `tool_input.command`.
2. `codex_patch` extracts `*** Add File:`, `*** Update File:` and `*** Move to:` headers
   (`PATHS_AWK`), resolves each against the payload `cwd`, rejects `..` and paths outside
   `cwd`, and checks each BBj file once. On the Windows branch (`cygpath` on `PATH`) `cwd` and each
   path first lose a verbatim prefix and have backslashes turned into slashes (`wpath_norm`).
3. This is the only Codex flow: the Codex plugin `bbj` (overlay
   `plugins/bbj/.codex-plugin/plugin.json`) carries the docs server registration and the skills,
   and the hook runs from the plugin's `hooks.json`. Nothing is copied into a Codex home.

### Testing Flow

1. `sh tests/ci.sh` runs `sh tests/run.sh`, which executes every `tests/test_*.sh` with `sh`
   and every `tests/test_*.py` with `python3 -I`, then checks all gate names against the prefix
   block (`run_prefix_block`).
2. `ci.sh` then runs `claude plugin validate --strict` on `.`, `plugins/bbj` and
   `plugins/bbj-local` (with an isolated `CLAUDE_CONFIG_DIR`), then `shellcheck -s sh`.

**State Management:**
- The plugin itself holds no state. The hook is one process per tool call.
- `tests/run.sh` and `tests/ci.sh` keep counters only for the duration of one run.
- The only state the hook leaves behind is the no-route notice marker (a directory with one empty
  claim file) in `BBJ_CHECK_STATE_DIR` or the temp directory, left for the OS to clean.

## Key Abstractions

**Plugin:**
- Purpose: The unit of distribution in the Claude Code marketplace.
  Codex installs the same plugin directory.
- Examples: `plugins/bbj/`, `plugins/bbj-local/`
- Pattern: Directory with `.claude-plugin/plugin.json`, optional `.mcp.json`, `hooks/`,
  `skills/`, `scripts/`, and for Codex `.codex-plugin/plugin.json`.

**Skill:**
- Purpose: A self-contained body of guidance the agent loads for BBj tasks.
- Examples: `plugins/bbj/skills/bbj-programming/SKILL.md`,
  `plugins/bbj/skills/bbj-web-programming/SKILL.md`
- Pattern: `SKILL.md` index plus `references/*.md` loaded on demand.

**Compile-check route:**
- Purpose: One way to decide whether a BBj file is syntactically and type-correct.
- Examples: Tier 1 `check_file` with the compiler; tier 2 `no_tier1_route` with `bbj_check_syntax`.
- Pattern: Ordered fallback. Tier 2 never reports type errors; the hook header says so.

**Feedback block:**
- Purpose: The text the agent sees after a failed check.
- Examples: `report` in `plugins/bbj/scripts/bbj-check.sh`
- Pattern: Header `<route> reported N error(s) in <file>:`, compiler lines verbatim (at most
  40), overflow and "Not counted" notes, then the `bbj_lookup` pointer.

**No-route notice:**
- Purpose: Tell the agent, once per session, that a BBj file was written but not compile-checked.
- Examples: `note_noroute`, `notice` in `plugins/bbj/scripts/bbj-check.sh`
- Pattern: The only stdout write of the hook: one JSON object `hookSpecificOutput.additionalContext`;
  decided in `main` after every file of the call, so a call that exits 2 never uses up the slot.

## Entry Points

**Claude Code marketplace:**
- Location: `.claude-plugin/marketplace.json`
- Triggers: `claude plugin marketplace add BBj-AI/bbj-agent-plugins`, then
  `claude plugin install bbj@basis-bbj`.
- Responsibilities: Lists the two plugins and marks `bbj-local` as `defaultEnabled: false`.

**Codex plugin:**
- Location: `plugins/bbj/.codex-plugin/plugin.json` and `plugins/bbj/.codex-mcp.json`
- Triggers: `codex plugin add bbj@basis-bbj` from the same marketplace.
- Responsibilities: Register the docs server `bbj` for Codex; the skills and the hook come from the
  same plugin directory.

**Hook entry:**
- Location: `plugins/bbj/scripts/bbj-check.sh` (its last statement is `main`)
- Triggers: PostToolUse for `Write|Edit` (Claude Code) and `apply_patch` (Codex, via the
  same `hooks.json`).
- Responsibilities: Parse input, compile-check, exit 0 or 2 only.

**MCP servers (external to this repo):**
- Location: `plugins/bbj/.mcp.json` (the docs server `bbj`), `plugins/bbj-local/.mcp.json` (`bbj-ls`)
- Triggers: The host connects when the plugin is enabled.
- Responsibilities: Serve documentation tools and the hosted or local syntax check.

**Test and CI entry:**
- Location: `tests/ci.sh`, `.github/workflows/ci.yml`
- Triggers: Local `sh tests/run.sh` or `sh tests/ci.sh`; GitHub `push` and `pull_request`.
- Responsibilities: All self-contained tests, strict manifest validation, shellcheck.

## Architectural Constraints

- **Threading:** Not applicable. The hook is a single synchronous process; `curl` has a
  1 s connect timeout (5 s on the Windows branch) and 12 s total in `no_tier1_route`.
- **Global state:** None in the plugin. The hook uses shell variables local to one process
  (`file`, `cwd`, `FAILED`, `WIN`, `CPL`, and the no-route state `NR_N`, `NR_LIST`, `NR_COMPILER`,
  `NR_T2`, `NR_HOSTPORT`).
- **Circular imports:** Not applicable (no module graph). Inside `bbj-check.sh` the awk
  programs are shared by string composition (`JGET_AWK` and `PATHS_AWK` both begin with
  `UNESC_AWK`).
- **Never execute BBj:** The compiler is always invoked with `-N`; source text is never
  evaluated, sourced or interpolated into a command. Enforced by `tests/test_never_execute.sh`.
- **Exit contract:** The hook exits only 0 or 2. Stdout is written only for the no-route notice;
  every other path leaves it empty. Enforced by `tests/test_exit_contract.sh`.
- **Loopback only for tier 2:** Only `http` to `127.0.0.1`, `localhost` or `[::1]`; the
  hosted check is never called from the hook.
- **Windows launcher:** `commandWindows` is pinned as text by `tests/test_layout.py`; a change to
  it is a re-pin and a new run on Windows. It must not rely on automatic input variables, method
  calls or short-name paths (`layout_hook_windows_safe`).
- **Portability:** POSIX `sh`, `awk`, `sed`, `grep`; Git for Windows paths are handled through
  `cygpath` when present. Avoids `readlink -f` for older macOS.
- **Codex payload shape:** Top-level key order captured with Codex CLI 0.162.1 (plan 02-05);
  `tests/lib.sh` `codex_payload` follows it. Whether Codex sets `CLAUDE_PLUGIN_ROOT` on Windows
  was not observed (stated on `docs/install.md`).

## Anti-Patterns

### Calling the hosted check from the hook

**What happens:** A new check path sends source text to `bbj_check_syntax` on the hosted
server (`https://mcp.bbj-ai.com/mcp`).
**Why it's wrong:** The hook promises that code never leaves the machine (`README.md`, "The
check hook"). Tier 2 is limited to loopback.
**Do this instead:** Extend `no_tier1_route` in `plugins/bbj/scripts/bbj-check.sh` only with
loopback URLs, keeping the `case` guard that rejects userinfo, query, fragment and whitespace.

### Adding a second feedback format

**What happens:** A new code path prints errors in its own layout.
**Why it's wrong:** The agent learns one format; the fixed grammar, the 40-line cap and the
exit code 2 are asserted by `tests/test_exit_contract.sh`.
**Do this instead:** Call `report ROUTE ERRS [K]` in `plugins/bbj/scripts/bbj-check.sh`.

### Copying the gate-prefix block into a map document

**What happens:** A map document lists a test file with its gate prefixes in the block grammar.
**Why it's wrong:** The architecture section of `.claude/CLAUDE.md` is generated from this file. A
block line that reaches it is ignored by `run_prefix_block` in `tests/run.sh`, which reads block lines
only outside the GSD-generated regions, so it is a third copy that nothing compares and that drifts.
The block is edited by hand in one place, the section "Gate prefixes" at the end of
`.claude/CLAUDE.md`, and its one checked copy is in `.planning/codebase/CONVENTIONS.md`.
**Do this instead:** Point to the block; name a test file in prose or in a table.

## Error Handling

**Strategy:** Fail silent for environment problems, fail loud only for BBj errors. The hook
exits 0 whenever no compiler or server is reachable (after the one-time no-route notice), and
exits 2 only when the compiler or `bbj-ls` reported errors. The one loud environment failure is on
Windows: when no Git for Windows `sh.exe` is found and the payload names a BBj file,
`commandWindows` prints a not-found message and exits 2.

**Patterns:**
- Every failure path in `bbj-check.sh` ends in an explicit `return 0` or `exit 0`, and there is
  no `set -e` (stated in the script header).
- `no_tier1_route` discards a reply that is a JSON-RPC `error` or `isError: true`.
  A reply with no verdict is a route that was reached without one, and stays silent.

## Cross-Cutting Concerns

**Logging:** None. Diagnostic output goes to stderr only when the hook reports an error; the
no-route notice is the one stdout write.

**Validation:** Input is validated at each boundary: hook JSON via `jget`, patch headers via
`PATHS_AWK`, the loopback URL via a `case` guard and a `sed -nE` match in `no_tier1_route`.

**Authentication:** None in this repository's code. The docs server `bbj` signs the user in with
OAuth in the host, through the pre-registered client named in `plugins/bbj/.mcp.json` and
`plugins/bbj/.codex-mcp.json`; `bbj-ls` is unauthenticated loopback HTTP. The `docs_url` user
option is the only configurable endpoint, and only in Claude Code.

---

*Architecture analysis: 2026-10-16*
