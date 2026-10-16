<!-- GSD:project-start source:PROJECT.md -->

## Project

**bbj-agent-plugins**

The `basis-bbj` plugin marketplace for coding agents (Claude Code and
OpenAI Codex). It gives an agent the BBj documentation MCP server, two BBj skills
(`bbj-programming`, `bbj-web-programming`), and a hook that compile-checks every BBj file the
agent writes, so agents write BBj that compiles. Release 0.2.0 makes this repository the home of
the two skills, rewrites them to state only verified facts, and makes the local `bbj-ls` check
the first choice wherever it is available.

**Core Value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL
cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t`
and `bbj-ls`).

### Constraints

- **Tech stack**: POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime deps — matches the existing hook and tests
- **Safety**: BBj code is never executed; hook never calls the hosted check — enforced by `tests/test_never_execute.sh`
- **Compatibility**: `bbj-local` stays opt-in in both Claude Code and Codex — a registered but stopped server shows as failed on every start
- **Verification**: Skill code checks need a real BBj 26.03+ (`bbj-ls` or `bbjcpl`) locally; CI has none
- **Naming**: Skill names and plugin names unchanged — users and docs refer to them

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Languages

- POSIX shell (`sh`) - Claude Code and Codex hook script, test harness: `plugins/bbj/scripts/bbj-check.sh`, `tests/ci.sh`, `tests/run.sh`, `tests/lib.sh`, `tests/test_*.sh`
- Python 3 (standard library only) - Repository and layout tests, a fake MCP server: `tests/test_layout.py`, `tests/test_ci_guards.py`, `tests/test_codex_patch.sh` (helpers), `tests/fake_mcp.py`
- Markdown - Skills, references, install docs, changelog: `plugins/bbj/skills/**/*.md`, `docs/*.md`, `README.md`, `CHANGELOG.md`
- JSON - Plugin and marketplace manifests, hooks, MCP config: `.claude-plugin/marketplace.json`, `plugins/*/.claude-plugin/plugin.json`, `plugins/bbj/hooks/hooks.json`, `plugins/*/.mcp.json`
- YAML - GitHub Actions workflow and Dependabot config: `.github/workflows/ci.yml`, `.github/dependabot.yml`
- BBj (subject matter only) - The plugin checks BBj source files (`.bbj`, `.src`, `.bbx`) but never runs them. BBj code appears only in the skill references under `plugins/bbj/skills/`.

## Runtime

- No application runtime. The repository ships configuration, Markdown skills, and shell hooks that run inside Claude Code or Codex.
- Node.js is required only in CI, to run the pinned Claude CLI: `.github/ci-tools/package.json` (`tests/ci.sh` prints the node version when present).
- Hook runtime: `sh` with `awk`, `sed`, `grep`, `head`, `cat`, `dirname`, `tr`, `cp`, `mv`, `cmp`, `diff`, `mktemp`, and `curl` (optional, for the loopback tier-2 check).
- Target platforms for the hook: Linux, macOS, and Windows through Git for Windows (`cygpath` on `PATH` triggers path conversion).
- npm, used only for the CI tool: `.github/ci-tools/package.json`
- Lockfile: present - `.github/ci-tools/package-lock.json` (9 `node_modules/*` entries, lockfileVersion with integrity hashes)
- No package manager for the plugins themselves; there is no root `package.json`.

## Frameworks

- Claude Code plugin system - Marketplace and plugin layout: `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj-local/.claude-plugin/plugin.json`
- Model Context Protocol (MCP) - Two MCP server registrations, both `type: "http"`: `plugins/bbj/.mcp.json`, `plugins/bbj-local/.mcp.json`
- Codex plugin overlay - Plugin manifest and MCP registration for the Codex plugin route: `plugins/bbj/.codex-plugin/plugin.json`, `plugins/bbj/.codex-mcp.json`; docs in `docs/install.md`
- Custom shell and Python test harness, no third-party framework: `tests/run.sh` (runs every self-contained test), entry point `tests/ci.sh`
- Shell test helpers: `tests/lib.sh`; fake binaries in `tests/fake-bin/` (`bbj`, `bbjcpl`, `curl`, `cygpath`)
- Python test scripts run as `python3 -I` (isolated mode)
- ShellCheck - Lint of all shipped and test shell scripts, `sh` dialect: `.shellcheckrc`, invoked from `tests/ci.sh`
- `claude plugin validate --strict` - Manifest validation, invoked from `tests/ci.sh` via the CI-installed CLI
- No build step. Nothing is compiled or bundled.

## Key Dependencies

- `@anthropic-ai/claude-code` 2.1.293 (exact pin) - Provides the `claude` CLI used by CI for plugin validation: `.github/ci-tools/package.json`. Installed with `npm ci --ignore-scripts`, then its install script is run explicitly; `npm audit signatures` verifies registry signatures. The Tested against section of `CHANGELOG.md` names the Claude Code version of the release run.
- BBj compiler (`bbjcpl` / `bbjcplw`, BBj 26.03 for tier 2) - External, not shipped here. Used by `plugins/bbj/scripts/bbj-check.sh` with `-t -N -X -P<dirs>`. Optional at runtime; the hook exits silently when no compiler is found.
- `curl` - Used by `plugins/bbj/scripts/bbj-check.sh` for the loopback tier-2 request (`--noproxy '*'`, `--proto =http`). Optional.
- GitHub Actions - Workflow `.github/workflows/ci.yml`, runner `ubuntu-24.04`, 15-minute timeout. Actions pinned by full commit SHA, for example `actions/checkout` at `v7.0.1`.
- Dependabot - Weekly updates for `github-actions` only: `.github/dependabot.yml`. The Claude CLI version is deliberately not watched.
- Skills - `plugins/bbj/skills/bbj-programming/` and `plugins/bbj/skills/bbj-web-programming/`, maintained in this repository; `tests/test_layout.py` applies the normal rules to them (hosted host named only in `plugins/bbj/.claude-plugin/plugin.json`, no executable files).

## Configuration

- No application environment file. `.env` files are not used by the repository (only `.gitignore` entries for `*.swp` and `*.swo` exist; see `.gitignore`).
- Plugin user options (Claude Code `userConfig`), defined in `plugins/bbj/.claude-plugin/plugin.json`:
- Environment variables read by the hook: `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `CLAUDE_PROJECT_DIR`, `BBJ_HOME`, `BBJHOME`, `BBJ_LOCAL_MCP_URL` (default `http://127.0.0.1:5009/mcp`), `BBJ_CHECK_DEFAULT_HOMES` (test seam)
- CI: `CI=true` makes missing `claude` or `shellcheck` a failure instead of a skip
- `.shellcheckrc` - ShellCheck configuration
- `.gitattributes` - `* text=auto eol=lf` (LF line endings enforced)
- `.gitignore` - `*.swp`, `*.swo`
- `.github/workflows/ci.yml` - CI definition
- `.github/ci-tools/package.json` and `package-lock.json` - Pinned CLI
- `.claude-plugin/marketplace.json` - Marketplace definition (`basis-bbj`)
- `plugins/bbj/hooks/hooks.json` - `PostToolUse` hook on `Write|Edit`, timeout 30 seconds, command `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`

## Platform Requirements

- POSIX `sh`, `awk`, `sed`, `grep`, and coreutils
- Python 3 for the test suite
- Node.js and npm only to run the CI CLI install locally (optional; the gate is skipped outside CI)
- Optional: ShellCheck, a BBj installation (`bbjcpl`), or a running BBjServices with `bbj-ls` on `127.0.0.1:5009`. The real-compiler and live tests skip without BBj: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh` (enabled with `BBJ_LS_LIVE=1`)
- Installed as a Claude Code marketplace from a Git repository (`BBj-AI/bbj-agent-plugins`, per `homepage` in plugin manifests) or from a local directory (`docs/install.md`)
- Installed for Codex through the Codex plugin (`codex plugin add bbj@basis-bbj`, `docs/install.md`)
- Licensed Apache-2.0 (`LICENSE`, `NOTICE`)
- Current version: 0.2.1 for both plugins (`CHANGELOG.md`)

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## Scope of the Code

- POSIX shell scripts (the shipped hook): `plugins/bbj/scripts/bbj-check.sh`
- Shell and Python test suites: `tests/*.sh`, `tests/*.py`, plus fakes in `tests/fake-bin/` and `tests/fake_mcp.py`
- JSON manifests and hook config: `.claude-plugin/marketplace.json`, `plugins/*/.claude-plugin/plugin.json`, `plugins/*/.mcp.json`, `plugins/bbj/hooks/hooks.json`
- Markdown skills and docs: `plugins/bbj/skills/**/SKILL.md`, `plugins/bbj/skills/**/references/*.md`, `docs/*.md`, `README.md`, `CHANGELOG.md`
- GitHub Actions workflow and CI tooling: `.github/workflows/ci.yml`, `.github/ci-tools/package.json`

## Naming Patterns

- Shell scripts and tests are lowercase with hyphens for shipped scripts (`bbj-check.sh`) and underscores for tests (`test_exit_contract.sh`, `test_layout.py`, `test_ci_guards.py`). Every test file starts with `test_`; `tests/run.sh` discovers them by that glob.
- Helper and fixture files: `tests/lib.sh`, `tests/ci.sh`, `tests/run.sh`, `tests/fake_mcp.py`, `tests/fake-bin/<tool>` (fake binaries use hyphens for the directory, no extension).
- Skill reference docs use lowercase hyphenated names: `plugins/bbj/skills/bbj-programming/references/callback-performance.md`.
- Skill entry points are always named `SKILL.md` inside a directory named after the skill.
- Planning and seed docs are UPPERCASE for generated analysis (`.planning/codebase/CONVENTIONS.md`) and `SEED-NNN-kebab-name.md` for seeds (`.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`).
- Lowercase with underscores: `run_check`, `claude_payload`, `json_escape`, `no_tier1_route`, `report`, `start_fake`, `mkwork`.
- Test helpers that build fixtures are verb-first: `mkhome`, `mkwork`, `mkdir`-style names.
- Script-local temporaries are prefixed with an underscore to avoid clashing with sourced helpers: `_tab`, `_cr`, `_url`, `_reply`, `_text`, `_n`, `_code`, `_sn`, `_payload`, `_save`.
- Shared/exported state is uppercase: `REPO`, `SCRIPT`, `WORK`, `RC`, `FAKE_LOG`, `FAKE_EXIT`, `BBJ_HOME`, `BBJ_LOCAL_MCP_URL`, `SHELL_UNDER_TEST`.
- Constants at file top are uppercase: `DEFAULT_DOCS_URL`, `MARK_BEGIN`, `MARK_END`, `DOCS_TOOLS`, `TOOL_KEY`, `NL`, `HOSTILE_ONE`.
- The `NL` newline idiom is a literal newline assigned inside single quotes: `NL='` + newline + `'`.
- Module constants are uppercase (`ROOT`, `VERSION`, `DOCS_HOST`, `HOOK_COMMAND`, `LOCK_KEYS`, `PINNED`, `USES`).
- Helper functions are lowercase with underscores (`gate`, `load`, `read_lines`, `code_lines`, `done`).
- Regexes are compiled once into uppercase module names: `USES = re.compile(...)`, `VERSION_COMMENT = re.compile(...)`.
- Strings that a static scan would otherwise match against itself are assembled from pieces: `OIDC_PERMISSION = "id" + "-token"` in `tests/test_ci_guards.py`. Keep this pattern for any forbidden word that a test file must mention.
- Keys follow the upstream schema exactly (`userConfig`, `mcpServers`, `PostToolUse`, `matcher`); do not rename them to match local style.
- The user-config keys are snake_case: `docs_url`, `bbj_home`.

## Code Style

- Shebang `#!/bin/sh` for every shipped script and every test; the target shell is POSIX `sh`, verified under dash, bash and busybox sh (see `tests/test_exit_contract.sh`).
- Two-space indentation inside `case`, `if`, `for` and function bodies; `case` arms indent by two more spaces with patterns followed by `)`.
- Continuation lines of long commands end with a backslash and align under the previous argument (see `_ok=$(... | sed ...)` and the `curl` invocation in `plugins/bbj/scripts/bbj-check.sh`).
- Redirections are written with a space before the operator and a space after the descriptor for stdin/stdout: `> "$WORK/stdout" 2> "$WORK/stderr"`, `< "$WORK/payload"`. Use `> /dev/null` with the space.
- Single quotes wrap all awk, sed and grep programs; `# shellcheck disable=SC2016` is not needed because `.shellcheckrc` already disables SC2016 for this reason.
- Use `$(...)` for command substitution, never backticks.
- Use `[ ... ]` for tests, never `[[ ... ]]`. The only `[[` occurrences in shipped code are inside `case` glob patterns and POSIX character classes such as `[[:space:]]`.
- Use `printf` instead of `echo` when the output contains user data, backslashes, or a leading dash. Plain `echo` is used only for fixed text.
- Use `command -v name > /dev/null 2>&1` to test for a tool; never `which`.
- No `set -e` in shipped scripts. `plugins/bbj/scripts/bbj-check.sh` states this explicitly: "There is deliberately no set -e; every failure path ends in an explicit exit 0." Each failure path checks its own status and returns or exits.
- Pattern for a fallible step: capture the value, test it, return on failure:
- The hook's exit contract is fixed: exit `0` with empty stdout for "nothing to say", exit `2` with feedback on stderr for compiler errors. Stdout is never written by hook scripts (enforced by `tests/test_exit_contract.sh`).
- Test helpers use `mktemp -d` with a `trap 'rm -rf "$WORK"' EXIT` cleanup (see `mkwork` in `tests/lib.sh`).
- Never evaluate, source or interpolate file content into a command. File names reach external tools as one quoted absolute argument.
- Every compiler call carries `-N` (compile-only). Calls without it fail the static gate.
- Every URL literal in a shipped script must be loopback `http://127.0.0.1`, `localhost` or `[::1]`.
- Every `curl` call carries `--noproxy '*'` and `--proto =http` and must not use a redirect flag (`-L`, `--location`).
- Symlinks named by a patch or a path are skipped, not followed.
- Shipped code must not call the hosted check service; only the loopback route is contacted.
- No `set -e` in shipped scripts (convention; stated in the `bbj-check.sh` header, not gated by a test).
- Stdlib only; no third-party imports. Scripts run as `python3 -I` (isolated mode), so no local module can shadow the stdlib.
- Standard 4-space indentation, double-quoted strings, `%`-formatting in gate messages (`"gate layout_%s %s %s" % (...)`). f-strings are not used in the existing tests.
- Each file has a module docstring that states what it locks, how it is run, and the output format.
- Module-level `failed = False` with a `global failed` declaration inside `gate()`.
- Exit via `sys.exit(1 if failed else 0)` or a `done()` helper.
- JSON uses 2-space indentation (see `.github/ci-tools/package.json`).
- YAML is hand-written; `tests/test_ci_guards.py` reads it by line scanning, not with a YAML library, so keep each `uses:` and `run:` on its own line in the expected form (`- uses: owner/repo@<40-hex-sha> # vX.Y.Z`).
- ShellCheck is the linter. Settings live in `.shellcheckrc` (`shell=sh`, with a list of disabled codes and a comment explaining each one: SC1091, SC2015, SC2016, SC1003, SC2012, SC2181).
- Warnings are never disabled globally. A deliberate single warning carries an inline directive with a reason, for example:
- `tests/ci.sh` runs `shellcheck -s sh` over shipped and test scripts. Under `CI=true` a missing `shellcheck` is a failure.
- Python has no configured linter; keep to the stdlib style above.
- No Prettier, ESLint or Biome config exists in this repository.

## Import Organization

- Tests source the shared library with the same first line: `. "$(dirname "$0")/lib.sh"`, followed by `mkwork`.
- Shellcheck directive `SC1091` is disabled repo-wide because sourced paths are computed at run time.
- Stdlib imports only, grouped as `json`, `os`, `subprocess`, `sys` (or `hashlib`, `re`), one per line, alphabetical.
- Scripts resolve the repository root from their own location: `REPO=$(cd "$(dirname "$0")/.." && pwd)` in `tests/lib.sh`; `ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))` in Python tests.
- Python tests accept an optional `argv[1]` root so mutation checks can point them at a copy.

## Terms

- Term list (NAME-04, D-07 to D-09): user text names each thing one way. The gate `layout_no_retired_terms` rejects the retired variants in `README.md`, `docs/`, both skills, the non-comment lines of `plugins/bbj/scripts/bbj-check.sh`, the description strings of the four manifests and CHANGELOG entries newer than 0.2.1; this list must name the variants, so `.claude/CLAUDE.md`, `.planning/` and `tests/` are outside that scan.
- The `bbjcpl` check: the hook's compile-only check, `bbjcpl -t -N -X` (syntax and types). Retired: "compiler check", "first route".
- `bbj-ls`: `bbj-ls`, the BBj language server in BBjServices, on `127.0.0.1:5009` (syntax only). "Language server" appears in user text only in this definition. Retired: "second route", "local check".
- The plugin `bbj-local`: the opt-in plugin that registers `bbj-ls` with the client so the agent can call `bbj_check_syntax`; its install step is headed "Enable the plugin `bbj-local`". Retired: "local check", "the `bbj-local` server".
- The docs server `bbj`: the hosted BBj docs server, always named with its role noun. Retired: "docs MCP", "docs MCP server".
- The hosted check: `bbj_check_syntax` of the docs server `bbj`; it sends the code to the server and checks it against a stock BBj.
- Tier 1 and tier 2: maintainer terms for the hook's `bbjcpl` check and its `bbj-ls` check; the hook, the tests, these conventions and the planning records use them, user docs only where they define them.
- Gate and test names follow the list too (D-11): a name that held a retired variant was renamed; tier names in tests are fine.

## Error Handling

- Report to the user through stderr with a fixed grammar. Example header from `report()` in `plugins/bbj/scripts/bbj-check.sh`: `bbj-local reported N error(s) in <file>:`.
- Cap feedback at 40 lines and print `(M more line(s) not shown)` for the rest.
- A check reports one line through `gate NAME STATUS DETAIL`, where STATUS is `ok`, `FAIL` or `skip`. `tests/lib.sh` sets `LIB_FAILED=1` on any FAIL and `finish()` exits accordingly.
- Gate names start with a prefix listed for their own test file in the block below (MAINT-09, D-13 to D-16). `tests/run.sh` checks the block against the gate lines it saw under each `== <file>` header and prints `gate run_prefix_block`; it fails on a listed prefix its file did not print, on a gate name under no listed prefix of its file (the longest prefix wins), on a test file missing from the block or listed twice, and on a block file not in `tests/`. Files that did not run are not judged. A prefix can be a string prefix of another file's prefix (`ci_` and `ci_guard_`, `release_` and `release_mut_`), so the match is per file. A new prefix is one no existing gate name starts with, and a skip branch prints a name under its file's prefix. This block is the source; `.planning/codebase/CONVENTIONS.md` holds the same lines in the same order when present. The prefixes `sh tests/run.sh` prints, in run order:
- `test_ci_gates.sh`: `ci_`, `run_`
- `test_claude_plugin.sh`: `claudeplugin_`
- `test_codex_patch.sh`: `codexpatch_`, `plugin_route_`
- `test_discovery.sh`: `discovery_`, `order_`
- `test_exit_contract.sh`: `argument_`, `contract_`, `glob_newline_not_passed_`, `no_marker_`
- `test_hook_mutation.sh`: `hookmut_`
- `test_hook_review_fixes.sh`: `reviewfix_`
- `test_install_pages.sh`: `claude_`, `codex_`, `link_`, `readme_`
- `test_never_execute.sh`: `neverexec_`
- `test_noroute_notice.sh`: `notice_`
- `test_path_scrub.sh`: `pathscrub_`
- `test_real_compiler.sh`: `realcpl_`
- `test_release_text_mutation.sh`: `release_mut_`
- `test_static_guards.sh`: `static_`
- `test_tier2_fake.sh`: `mode_`, `req_`, `tier2_`, `url_`
- `test_tier2_live.sh`: `live_`
- `test_check_order.py`: `checkorder_`
- `test_ci_guards.py`: `ci_guard_`
- `test_layout.py`: `layout_`
- `test_release_text.py`: `release_`
- `test_skill_examples.py`: `skills_`
- Python tests print `gate <prefix>_<name> ok|FAIL <detail>` and exit 1 if any gate failed.
- A test that cannot run because a prerequisite is missing reports `skip`, except under `CI=true`, where the missing prerequisite must be a `FAIL` (`tests/run.sh`, `tests/ci.sh`).

## Logging

- Do not write to stdout from hook scripts; Claude Code treats hook stdout as a protocol channel and `tests/test_exit_contract.sh` enforces empty stdout.
- Test diagnostics go to stdout as `gate` lines so `tests/run.sh` can count them; anything else is shown verbatim.

## Comments

- Every script opens with a block comment: file name and path, a one-line purpose, the plan and decision IDs it implements (for example `plan 19-01, PLUG-01; decisions D-11 and D-12`), the exit-code contract, and what it never does (`never runs BBj`).
- Test files open with the same shape: `tests/test_exit_contract.sh -- plan 19-01 Task 3: ...`, then the scope, then "Nothing here runs BBj" or the equivalent.
- Explain why, not what. Examples from the code: `# the compiler prints its errors on stderr and exits 0 on every outcome`, `# loopback only: ... A refused URL is never handed to curl.`
- Put a reason next to every shellcheck directive.
- Comments may describe forbidden patterns in words; the static scanners ignore full-line comments, so keep forbidden tokens out of executable lines only.
- Reference them by ID (`PLUG-01`, `D-12`, `D-14`) in both code comments and tests so a reviewer can trace behavior back to the decision record. Keep the ID prefix format as used in existing files.

## Function Design

- Functions are short and take positional parameters with a usage comment above them: `# contract SHELLNAME CASE: exit 0 or 2, empty stdout, no marker file`, `# claude_payload TOOL FILE CWD`.
- Local-style variables inside a function use underscore names, since POSIX `sh` has no `local` keyword in all shells; never rely on `local`.
- Return values are printed on stdout and captured with `$(...)`, or set into an uppercase global (`RC`, `FAILED`).
- Restore any global that a test changes (`PATH=$_save`, `unset FAKE_EXIT`).
- Helper functions are small and return nothing; results go through `gate()`.

## Module Design

- Shared helpers live in `tests/lib.sh` (gate, mkwork, json_escape, claude_payload, codex_payload, run_check). New test files source it instead of re-defining these.
- Compiler fakes are copied into each temporary home (`mkhome` in `tests/test_discovery.sh`); tests never call a real compiler unless they opt in.
- One manifest per plugin under `.claude-plugin/plugin.json`; the marketplace is `.claude-plugin/marketplace.json` at the root.
- Versions are identical across both plugin manifests, the Codex overlay `plugins/bbj/.codex-plugin/plugin.json` and both marketplace entries (`0.2.1`), and `tests/test_layout.py` enforces this. Bump all five together.
- Licence is `Apache-2.0` in every manifest.

## Git and Commit Conventions

- Conventional commit prefixes are used: `fix(19): ...`, `feat(codex): ...`, `test(19-05): ...`, `docs(19-07): ...`, `chore: ...`. Use a scope when the change belongs to a plan or to one area (`codex`).
- Plan-tagged commits carry the phase and plan number in the scope (`19-05`).
- Pinned third-party GitHub Actions are referenced by full commit SHA with a trailing `# vX.Y.Z` comment; Dependabot maintains the pins (`.github/dependabot.yml`).

## Documentation Conventions

- Markdown skill references use the `references/` subdirectory under each skill, one topic per file, lowercase hyphenated names.
- `README.md` and `docs/install.md` describe installation; keep install steps there, not in the scripts' code comments.
- `CHANGELOG.md` records user-visible changes under a version heading (currently `## 0.2.1`).

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## System Overview

```text

```

## Pattern Overview

- No compiled code and no package-managed runtime. The only executables are POSIX `sh`
- The hook is deliberately stateless: each invocation reads its input
- BBj code is never executed. The check path calls the BBj compiler with `-N` (compile-only)
- Two MCP servers are declared, not implemented here: the hosted docs server `bbj` (URL from
- The skills are maintained in this repository under the normal tests (`tests/test_layout.py`).

## Layers

- Purpose: Declare plugins, their MCP servers, hooks and user options to the host.
- Location: `.claude-plugin/marketplace.json`, `plugins/bbj/.claude-plugin/plugin.json`,
- Contains: JSON manifests; `userConfig` for `docs_url` and `bbj_home` in the `bbj` plugin;
- Depends on: The host's plugin loader (`claude plugin validate --strict` in CI).
- Used by: `claude plugin marketplace add` / `claude plugin install` (see `README.md`).
- Purpose: Tell the host where the BBj MCP servers are.
- Location: `plugins/bbj/.mcp.json` (the docs server `bbj`, URL `${user_config.docs_url}`),
- Contains: Transport type `http` and URL only. No tool definitions live here.
- Depends on: Remote hosted server, or a BBjServices instance on the same machine.
- Used by: The host agent, which exposes `bbj_lookup`, `bbj_search`, `bbj_examples`,
- Purpose: Compile-check every BBj file the agent writes or edits, and return compiler
- Location: `plugins/bbj/hooks/hooks.json` (PostToolUse, matcher `Write|Edit`, 30 s timeout)
- Contains: Tool-input parsing (`jget`, `UNESC_AWK`), compiler discovery (`discover`,
- Depends on: A BBj compiler (`bbjcpl` / `bbjcplw`) or a running `bbj-ls`; `curl` for tier 2.
- Used by: The host, after every matching tool call.
- Purpose: Teach the agent BBj syntax, web (DWC) development and the rules agents get wrong.
- Location: `plugins/bbj/skills/bbj-programming/` (`SKILL.md` and `references/*.md`),
- Contains: Markdown only. Skills are loaded by the host on demand; references are read on
- Depends on: Nothing executable. Content describes the tools of the docs server `bbj` and of `bbj-ls` by name.
- Used by: The host agent's skill loader (the plugin cache for
- Purpose: Gate every change to manifests, hook and skills.
- Location: `tests/run.sh` (runner), `tests/ci.sh` (entry point), `tests/test_*.sh` and
- Contains: Shell and Python tests that print `gate NAME ok|FAIL|skip` lines and a
- Depends on: `python3`, `shellcheck`, `claude` CLI (mandatory in CI, skipped locally).
- Used by: GitHub Actions on push and pull request.

## Data Flow

### Primary Request Path: BBj file written by the agent

### Secondary Flow: Codex `apply_patch`

### Testing Flow

- The plugin itself holds no state. The hook is one process per tool call.
- `tests/run.sh` and `tests/ci.sh` keep counters only for the duration of one run.

## Key Abstractions

- Purpose: The unit of distribution in the Claude Code marketplace.
- Examples: `plugins/bbj/`, `plugins/bbj-local/`
- Pattern: Directory with `.claude-plugin/plugin.json`, optional `.mcp.json`, `hooks/`,
- Purpose: A self-contained body of guidance the agent loads for BBj tasks.
- Examples: `plugins/bbj/skills/bbj-programming/SKILL.md`,
- Pattern: `SKILL.md` index plus `references/*.md` loaded on demand.
- Purpose: One way to decide whether a BBj file is syntactically and type-correct.
- Examples: Tier 1 `check_file` with the compiler; tier 2 `no_tier1_route` with `bbj_check_syntax`.
- Pattern: Ordered fallback. Tier 2 never reports type errors; the hook header says so.
- Purpose: The text the agent sees after a failed check.
- Examples: `report` in `plugins/bbj/scripts/bbj-check.sh`
- Pattern: Header `<route> reported N error(s) in <file>:`, compiler lines verbatim (at most

## Entry Points

- Location: `.claude-plugin/marketplace.json`
- Triggers: `claude plugin marketplace add BBj-AI/bbj-agent-plugins`, then
- Responsibilities: Lists the two plugins and marks `bbj-local` as `defaultEnabled: false`.
- Location: `plugins/bbj/scripts/bbj-check.sh` (its last statement is `main`)
- Triggers: PostToolUse for `Write|Edit` (Claude Code) and `apply_patch` (Codex, via the
- Responsibilities: Parse input, compile-check, exit 0 or 2 only.
- Location: `plugins/bbj/.mcp.json` (the docs server `bbj`), `plugins/bbj-local/.mcp.json` (`bbj-ls`)
- Triggers: The host connects when the plugin is enabled.
- Responsibilities: Serve documentation tools and the hosted or local syntax check.
- Location: `tests/ci.sh`, `.github/workflows/ci.yml`
- Triggers: Local `sh tests/run.sh` or `sh tests/ci.sh`; GitHub `push` and `pull_request`.
- Responsibilities: All self-contained tests, strict manifest validation, shellcheck.

## Architectural Constraints

- **Threading:** Not applicable. The hook is a single synchronous process; `curl` has a
- **Global state:** None in the plugin. The hook uses shell variables local to one process
- **Circular imports:** Not applicable (no module graph). Inside `bbj-check.sh` the awk
- **Never execute BBj:** The compiler is always invoked with `-N`; source text is never
- **Exit contract:** The hook exits only 0 or 2 and prints nothing to stdout. Enforced by
- **Loopback only for tier 2:** Only `http` to `127.0.0.1`, `localhost` or `[::1]`; the
- **Portability:** POSIX `sh`, `awk`, `sed`, `grep`; Git for Windows paths are handled through
- **Codex payload shape:** Documentation-derived; the header of `bbj-check.sh` marks it as

## Anti-Patterns

### Calling the hosted check from the hook

### Adding a second feedback format

## Error Handling

- Every failure path in `bbj-check.sh` ends in an explicit `return 0` or `exit 0`, and there is
- `no_tier1_route` discards a reply that is a JSON-RPC `error` or `isError: true`.

## Cross-Cutting Concerns

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:

- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
