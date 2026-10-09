<!-- refreshed: 2026-10-09 -->
# Architecture

**Analysis Date:** 2026-10-09

## System Overview

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                     Coding agent (Claude Code / Codex)                    │
└───────┬───────────────────────────┬──────────────────────────┬───────────┘
        │ MCP (HTTP)                 │ MCP (HTTP, loopback)     │ PostToolUse hook
        ▼                            ▼                          ▼
┌───────────────────┐   ┌──────────────────────────┐   ┌─────────────────────────┐
│ bbj-docs (hosted) │   │ bbj-ls (local BBjServices│   │ bbj-check.sh            │
│ docs_url option   │   │ 127.0.0.1:5009/mcp)      │   │ `plugins/bbj/scripts/`  │
│ `plugins/bbj/     │   │ `plugins/bbj-local/`     │   │  tier 1: bbjcpl -t -N -X│
│  .mcp.json`       │   │  `.mcp.json`             │   │  tier 2: bbj-ls check   │
└───────────────────┘   └──────────────────────────┘   └────────────┬────────────┘
                                                                    │ reads file
                                                                    ▼
                                                     ┌─────────────────────────┐
                                                     │ Workspace BBj files      │
                                                     │ (.bbj .src .bbx)         │
                                                     └─────────────────────────┘

Static content (no runtime code of its own):
  `plugins/bbj/skills/*/SKILL.md` + `references/*.md`   (read by agent)
  `codex/AGENTS-snippet.md`                              (instructions for Codex)

Installation and distribution:
  `.claude-plugin/marketplace.json` ──> `plugins/bbj`, `plugins/bbj-local`
  `codex/install-codex.sh` ──> `~/.agents/skills`, `<codex home>/bbj/`, `config.toml`, `hooks.json`
```

This is a plugin repository, not an application. It has no server, database or build
output of its own. Its "runtime" is the set of declarative manifests, one POSIX shell hook
script, one installer script, and static skill documents that a host agent loads.

## Pattern Overview

**Overall:** Declarative plugin bundle with a single stateless hook script and an installer.
Each plugin is a directory of manifests plus content; behaviour lives in the host agent and
in the remote or local MCP servers the manifests point at.

**Key Characteristics:**
- No compiled code and no package-managed runtime. The only executables are POSIX `sh`
  scripts (`plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`) and the test
  suite under `tests/`.
- The hook and the installer are deliberately stateless: each invocation reads its input
  from stdin or from the file system, writes feedback only to stderr, and exits with 0 or 2.
- BBj code is never executed. The check path calls the BBj compiler with `-N` (compile-only)
  or sends source text to the `bbj_check_syntax` tool of an MCP server. Tests enforce this
  (`tests/test_never_execute.sh`).
- Two MCP servers are declared, not implemented here: the hosted `bbj-docs` server (URL from
  the `docs_url` user option) and the local `bbj-ls` server of BBjServices on `127.0.0.1:5009`.
- The skills are maintained in this repository under the normal tests (`tests/test_layout.py`).

## Layers

**Distribution layer (manifests):**
- Purpose: Declare plugins, their MCP servers, hooks and user options to the host.
- Location: `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`,
  `plugins/bbj-local/.claude-plugin/plugin.json`
- Contains: JSON manifests; `userConfig` for `docs_url` and `bbj_home` in the `bbj` plugin;
  `defaultEnabled: false` for `bbj-local`.
- Depends on: The host's plugin loader (`claude plugin validate --strict` in CI).
- Used by: `claude plugin marketplace add` / `claude plugin install` (see `README.md`).

**Connection layer (MCP declarations):**
- Purpose: Tell the host where the BBj MCP servers are.
- Location: `plugins/bbj/.mcp.json` (`bbj-docs`, URL `${user_config.docs_url}`),
  `plugins/bbj-local/.mcp.json` (`bbj-ls`, `http://127.0.0.1:5009/mcp`)
- Contains: Transport type `http` and URL only. No tool definitions live here.
- Depends on: Remote hosted server, or a BBjServices instance on the same machine.
- Used by: The host agent, which exposes `bbj_lookup`, `bbj_search`, `bbj_examples`,
  `bbj_reserved_word`, `bbj_fetch_page`, `bbj_check_syntax`, `bbj_format`, `bbj_denum`.

**Enforcement layer (hook):**
- Purpose: Compile-check every BBj file the agent writes or edits, and return compiler
  errors to the agent as feedback.
- Location: `plugins/bbj/hooks/hooks.json` (PostToolUse, matcher `Write|Edit`, 30 s timeout)
  runs `plugins/bbj/scripts/bbj-check.sh`.
- Contains: Tool-input parsing (`jget`, `UNESC_AWK`), compiler discovery (`discover`,
  `find_cpl_in_home`, `find_cpl_on_path`), per-file check (`check_file`), tier 2 loopback
  call (`no_tier1_route`), Codex `apply_patch` branch (`codex_patch`), and `main`.
- Depends on: A BBj compiler (`bbjcpl` / `bbjcplw`) or a running `bbj-ls`; `curl` for tier 2.
- Used by: The host, after every matching tool call.

**Installation layer (Codex):**
- Purpose: Install the docs server, skills and hook for OpenAI Codex, which has no plugin
  marketplace in this repository.
- Location: `codex/install-codex.sh` (527 lines), `codex/AGENTS-snippet.md`
- Contains: Option parsing and validation (`usage`, `refuse`, `say`), pre-flight checks
  (the first comment block states "pre-flight (WR-02)"), config analysis and edit
  (`analyze`, `refresh`, `print_tools`, `print_block`, `state`), JSON string escaping
  (`json_str`).
- Depends on: `codex` CLI (optional; falls back to a managed `config.toml` block), POSIX
  utilities. Source skills are read from `plugins/bbj/skills`.
- Used by: A user running the script from a checkout. Exit codes: 0 done, 2 refusal or usage
  error, 3 manual merge needed.

**Content layer (skills and guidance):**
- Purpose: Teach the agent BBj syntax, web (DWC) development and the rules agents get wrong.
- Location: `plugins/bbj/skills/bbj-programming/` (`SKILL.md` 464 lines, 5 reference files),
  `plugins/bbj/skills/bbj-web-programming/` (`SKILL.md` 370 lines, 7 reference files),
  `codex/AGENTS-snippet.md`
- Contains: Markdown only. Skills are loaded by the host on demand; references are read on
  demand from `SKILL.md`.
- Depends on: Nothing executable. Content describes the `bbj-docs` and `bbj-ls` tools by name.
- Used by: The host agent's skill loader (`~/.agents/skills` for Codex, the plugin cache for
  Claude Code).

**Verification layer (tests and CI):**
- Purpose: Gate every change to manifests, hook, installer and skills.
- Location: `tests/run.sh` (runner), `tests/ci.sh` (entry point), `tests/test_*.sh` and
  `tests/test_*.py`, fixtures in `tests/fake-bin/` and `tests/fake_mcp.py`,
  `.github/workflows/ci.yml`, `.github/ci-tools/` (pinned `claude` CLI).
- Contains: Shell and Python tests that print `gate NAME ok|FAIL|skip` lines and a
  `SUMMARY:` line. The CI job runs `sh tests/ci.sh` with `CI=true`.
- Depends on: `python3`, `shellcheck`, `claude` CLI (mandatory in CI, skipped locally).
- Used by: GitHub Actions on push and pull request.

## Data Flow

### Primary Request Path: BBj file written by the agent

1. The agent calls `Write` or `Edit` on a `.bbj`, `.src` or `.bbx` file. Host runs the
   PostToolUse hook declared in `plugins/bbj/hooks/hooks.json`.
2. `main` in `plugins/bbj/scripts/bbj-check.sh` reads the hook JSON from stdin, takes
   `tool_name`, `tool_input.file_path` and `cwd` with `jget`, and dispatches on tool name.
3. `check_file` skips non-BBj names, symlinks and `config*.bbx` files (exit 0, silent).
4. Tier 1: `discover` locates a compiler (plugin option, `BBJ_HOME`, `BBJHOME`, `PATH`,
   default homes). The compiler runs as `<cpl> -t -N -X -P<dirs> <file>` with stdin from
   `/dev/null`. Its verdict is read from stderr, not the exit code.
5. Tier 2 (no compiler): `no_tier1_route` posts the file text to `bbj_check_syntax` at a
   loopback URL only, via `curl --noproxy '*' --proto =http`. Only syntax errors are reported.
6. Errors go to stderr in the D-12 format (at most 40 lines). `main` prints the
   `bbj_lookup` pointer and exits 2; otherwise it exits 0 silently.

### Secondary Flow: Codex `apply_patch`

1. Codex sends a payload with `tool_name` `apply_patch` and the patch text in
   `tool_input.command`.
2. `codex_patch` extracts `*** Add File:`, `*** Update File:` and `*** Move to:` headers
   (`PATHS_AWK`), resolves each against the payload `cwd`, rejects `..` and paths outside
   `cwd`, and checks each BBj file once.

### Installation Flow: Codex

1. `codex/install-codex.sh` validates options (`--docs-url`, `--skills-dir`,
   `--codex-home`, `--force`), checks every destination before any write (pre-flight).
2. Registers `bbj-docs` via `codex mcp add` or a managed `config.toml` block, and approves
   only the five read-only docs tools by name (`analyze`, `state`, `print_block`).
3. Copies both skills to the skills directory, copies `bbj-check.sh` to
   `<codex home>/bbj/`, writes `hooks.json` only when it does not exist.
4. Prints the AGENTS.md snippet and the `/hooks` trust step.

### Testing Flow

1. `sh tests/ci.sh` runs `sh tests/run.sh`, which executes every `tests/test_*.sh` with `sh`
   and every `tests/test_*.py` with `python3 -I`.
2. `ci.sh` then runs `claude plugin validate --strict` on `.`, `plugins/bbj` and
   `plugins/bbj-local` (with an isolated `CLAUDE_CONFIG_DIR`), then `shellcheck -s sh`.

**State Management:**
- The plugin itself holds no state. The hook is one process per tool call.
- `tests/run.sh` and `tests/ci.sh` keep counters only for the duration of one run.
- Codex configuration state lives in `config.toml` and `hooks.json` under the Codex home;
  the installer writes `config.toml.bbj-backup` once before its first change to an existing
  file.

## Key Abstractions

**Plugin:**
- Purpose: The unit of distribution in the Claude Code marketplace.
- Examples: `plugins/bbj/`, `plugins/bbj-local/`
- Pattern: Directory with `.claude-plugin/plugin.json`, optional `.mcp.json`, `hooks/`,
  `skills/`, `scripts/`.

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

**Managed config block (Codex):**
- Purpose: Idempotent edit of a `config.toml` the installer does not own entirely.
- Examples: `analyze`, `print_block`, `state` in `codex/install-codex.sh`
- Pattern: Writes only the tables it manages; refuses and exits 3 for forms it does not
  edit (single-quoted keys, dotted keys, sub-tables).

## Entry Points

**Claude Code marketplace:**
- Location: `.claude-plugin/marketplace.json`
- Triggers: `claude plugin marketplace add BBj-AI/bbj-agent-plugins`, then
  `claude plugin install bbj@basis-bbj`.
- Responsibilities: Lists the two plugins and marks `bbj-local` as `defaultEnabled: false`.

**Hook entry:**
- Location: `plugins/bbj/scripts/bbj-check.sh` (last statement `main`, line 276)
- Triggers: PostToolUse for `Write|Edit` (Claude Code) and `apply_patch` (Codex, via the
  hook copy at `<codex home>/bbj/bbj-check.sh`).
- Responsibilities: Parse input, compile-check, exit 0 or 2 only.

**Codex installer:**
- Location: `codex/install-codex.sh`
- Triggers: Run by the user from a checkout, e.g. `sh codex/install-codex.sh`.
- Responsibilities: Register docs server, install skills and hook, print the next steps.

**MCP servers (external to this repo):**
- Location: `plugins/bbj/.mcp.json` (`bbj-docs`), `plugins/bbj-local/.mcp.json` (`bbj-ls`)
- Triggers: The host connects when the plugin is enabled.
- Responsibilities: Serve documentation tools and the hosted or local syntax check.

**Test and CI entry:**
- Location: `tests/ci.sh`, `.github/workflows/ci.yml`
- Triggers: Local `sh tests/run.sh` or `sh tests/ci.sh`; GitHub `push` and `pull_request`.
- Responsibilities: All self-contained tests, strict manifest validation, shellcheck.

## Architectural Constraints

- **Threading:** Not applicable. The hook is a single synchronous process; `curl` has a
  1 s connect timeout and 12 s total in `no_tier1_route`.
- **Global state:** None in the plugin. The hook uses shell variables local to one process
  (`file`, `cwd`, `FAILED`, `WIN`, `CPL`). The installer uses its own globals for option
  values and pre-flight results.
- **Circular imports:** Not applicable (no module graph). Inside `bbj-check.sh` the awk
  programs are shared by string composition (`JGET_AWK` and `PATHS_AWK` both begin with
  `UNESC_AWK`).
- **Never execute BBj:** The compiler is always invoked with `-N`; source text is never
  evaluated, sourced or interpolated into a command. Enforced by `tests/test_never_execute.sh`.
- **Exit contract:** The hook exits only 0 or 2 and prints nothing to stdout. Enforced by
  `tests/test_exit_contract.sh`.
- **Loopback only for tier 2:** Only `http` to `127.0.0.1`, `localhost` or `[::1]`; the
  hosted check is never called from the hook.
- **Portability:** POSIX `sh`, `awk`, `sed`, `grep`; Git for Windows paths are handled through
  `cygpath` when present. Avoids `readlink -f` for older macOS.
- **Codex payload shape:** Documentation-derived; the header of `bbj-check.sh` marks it as
  unverified until captured on a real Codex install.

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
**Why it's wrong:** The agent learns one format; the D-12 grammar, the 40-line cap and the
exit code 2 are asserted by `tests/test_exit_contract.sh`.
**Do this instead:** Call `report ROUTE ERRS [K]` in `plugins/bbj/scripts/bbj-check.sh`.

### Writing config tables Codex's installer does not own

**What happens:** The installer appends tables to a `config.toml` that already has a
differently spelled `bbj-docs` entry.
**Why it's wrong:** Duplicate tables break Codex's config load. The installer's exit code 3
exists for this case.
**Do this instead:** Keep the refusal path in `analyze` in `codex/install-codex.sh`; report
the block and let the user merge it.

## Error Handling

**Strategy:** Fail silent for environment problems, fail loud only for BBj errors. The hook
exits 0 whenever no compiler or server is reachable, and exits 2 only when the compiler or
`bbj-ls` reported errors. The installer uses exit codes 0, 2 (refusal before any write) and
3 (finished, manual merge needed).

**Patterns:**
- Every failure path in `bbj-check.sh` ends in an explicit `return 0` or `exit 0`, and there is
  no `set -e` (stated in the script header).
- `no_tier1_route` discards a reply that is a JSON-RPC `error` or `isError: true`.
- The installer pre-flights every destination (skills directory, `<codex home>/bbj`,
  `config.toml`) so that a refusal changes nothing.

## Cross-Cutting Concerns

**Logging:** None. Diagnostic output goes to stderr only when the hook reports an error.
Installer output is printed by `say` (`codex/install-codex.sh`).

**Validation:** Input is validated at each boundary: hook JSON via `jget`, patch headers via
`PATHS_AWK`, the docs URL via a `case` guard in the installer (no whitespace, quote,
backslash, apostrophe, userinfo or control character), the loopback URL via a `sed -nE`
match in `no_tier1_route`.

**Authentication:** None in this repository. The docs server and local check accept
unauthenticated HTTP. The `docs_url` user option is the only configurable endpoint.

---

*Architecture analysis: 2026-10-09*
