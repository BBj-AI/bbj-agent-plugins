# Coding Conventions

**Analysis Date:** 2026-10-09

## Scope of the Code

This repository ships no application runtime. Its code is:

- POSIX shell scripts (shipped hooks and installers): `plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`
- Shell and Python test suites: `tests/*.sh`, `tests/*.py`, plus fakes in `tests/fake-bin/` and `tests/fake_mcp.py`
- JSON manifests and hook config: `.claude-plugin/marketplace.json`, `plugins/*/.claude-plugin/plugin.json`, `plugins/*/.mcp.json`, `plugins/bbj/hooks/hooks.json`, `skills.lock.json`
- Markdown skills and docs: `plugins/bbj/skills/**/SKILL.md`, `plugins/bbj/skills/**/references/*.md`, `docs/*.md`, `codex/AGENTS-snippet.md`, `README.md`, `CHANGELOG.md`
- GitHub Actions workflow and CI tooling: `.github/workflows/ci.yml`, `.github/ci-tools/package.json`

Conventions below are grouped by language. The shell rules are the most strictly enforced.

## Naming Patterns

**Files:**
- Shell scripts and tests are lowercase with hyphens for shipped scripts (`bbj-check.sh`, `install-codex.sh`) and underscores for tests (`test_exit_contract.sh`, `test_skills_hash.py`, `test_ci_guards.py`). Every test file starts with `test_`; `tests/run.sh` discovers them by that glob.
- Helper and fixture files: `tests/lib.sh`, `tests/ci.sh`, `tests/run.sh`, `tests/fake_mcp.py`, `tests/fake-bin/<tool>` (fake binaries use hyphens for the directory, no extension).
- Vendored skill docs use lowercase hyphenated names: `plugins/bbj/skills/bbj-programming/references/callback-performance.md`.
- Skill entry points are always named `SKILL.md` inside a directory named after the skill.
- Planning and seed docs are UPPERCASE for generated analysis (`.planning/codebase/CONVENTIONS.md`) and `SEED-NNN-kebab-name.md` for seeds (`.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`).

**Shell functions:**
- Lowercase with underscores: `run_check`, `claude_payload`, `json_escape`, `no_tier1_route`, `report`, `start_fake`, `mkwork`.
- Test helpers that build fixtures are verb-first: `mkhome`, `mkwork`, `mkdir`-style names.

**Shell variables:**
- Script-local temporaries are prefixed with an underscore to avoid clashing with sourced helpers: `_tab`, `_cr`, `_url`, `_reply`, `_text`, `_n`, `_code`, `_sn`, `_payload`, `_save`.
- Shared/exported state is uppercase: `REPO`, `SCRIPT`, `WORK`, `RC`, `FAKE_LOG`, `FAKE_EXIT`, `BBJ_HOME`, `BBJ_LOCAL_MCP_URL`, `SHELL_UNDER_TEST`.
- Constants at file top are uppercase: `DEFAULT_DOCS_URL`, `MARK_BEGIN`, `MARK_END`, `DOCS_TOOLS`, `TOOL_KEY`, `NL`, `HOSTILE_ONE`.
- The `NL` newline idiom is a literal newline assigned inside single quotes: `NL='` + newline + `'`.

**Python:**
- Module constants are uppercase (`ROOT`, `VERSION`, `DOCS_HOST`, `HOOK_COMMAND`, `LOCK_KEYS`, `PINNED`, `USES`).
- Helper functions are lowercase with underscores (`gate`, `load`, `read_lines`, `code_lines`, `done`).
- Regexes are compiled once into uppercase module names: `USES = re.compile(...)`, `VERSION_COMMENT = re.compile(...)`.
- Strings that a static scan would otherwise match against itself are assembled from pieces: `OIDC_PERMISSION = "id" + "-token"` in `tests/test_ci_guards.py`. Keep this pattern for any forbidden word that a test file must mention.

**JSON:**
- Keys follow the upstream schema exactly (`userConfig`, `mcpServers`, `PostToolUse`, `matcher`); do not rename them to match local style.
- The user-config keys are snake_case: `docs_url`, `bbj_home`.

## Code Style

**Shell formatting:**
- Shebang `#!/bin/sh` for every shipped script and every test; the target shell is POSIX `sh`, verified under dash, bash and busybox sh (see `tests/test_exit_contract.sh`).
- Two-space indentation inside `case`, `if`, `for` and function bodies; `case` arms indent by two more spaces with patterns followed by `)`.
- Continuation lines of long commands end with a backslash and align under the previous argument (see `_ok=$(... | sed ...)` and the `curl` invocation in `plugins/bbj/scripts/bbj-check.sh`).
- Redirections are written with a space before the operator and a space after the descriptor for stdin/stdout: `> "$WORK/stdout" 2> "$WORK/stderr"`, `< "$WORK/payload"`. Use `> /dev/null` with the space.
- Single quotes wrap all awk, sed and grep programs; `# shellcheck disable=SC2016` is not needed because `.shellcheckrc` already disables SC2016 for this reason.
- Use `$(...)` for command substitution, never backticks.
- Use `[ ... ]` for tests, never `[[ ... ]]`. The only `[[` occurrences in shipped code are inside `case` glob patterns and POSIX character classes such as `[[:space:]]`.
- Use `printf` instead of `echo` when the output contains user data, backslashes, or a leading dash. Plain `echo` is used only for fixed text.
- Use `command -v name > /dev/null 2>&1` to test for a tool; never `which`.

**Shell error handling:**
- No `set -e` in shipped scripts. `plugins/bbj/scripts/bbj-check.sh` states this explicitly: "There is deliberately no set -e; every failure path ends in an explicit exit 0." Each failure path checks its own status and returns or exits.
- Pattern for a fallible step: capture the value, test it, return on failure:
  ```sh
  _reply=$(printf '%s' "$_body" | curl -q -sS ... --url "$_url" 2> /dev/null)
  [ "$?" = 0 ] && [ -n "$_reply" ] || return 0
  ```
- The hook's exit contract is fixed: exit `0` with empty stdout for "nothing to say", exit `2` with feedback on stderr for compiler errors. Stdout is never written by hook scripts (enforced by `tests/test_exit_contract.sh`).
- Test helpers use `mktemp -d` with a `trap 'rm -rf "$WORK"' EXIT` cleanup (see `mkwork` in `tests/lib.sh`).

**Shell security rules (enforced by `tests/test_static_guards.sh`):**
- Never evaluate, source or interpolate file content into a command. File names reach external tools as one quoted absolute argument.
- Every compiler call carries `-N` (compile-only). Calls without it fail the static gate.
- Every URL literal in a shipped script must be loopback `http://127.0.0.1`, `localhost` or `[::1]`.
- Every `curl` call carries `--noproxy '*'` and `--proto =http` and must not use a redirect flag (`-L`, `--location`).
- Symlinks named by a patch or a path are skipped, not followed.
- Shipped code must not call the hosted check service; only the loopback route is contacted.
- No `set -e` in shipped scripts (convention; stated in the `bbj-check.sh` header, not gated by a test).

**Python formatting:**
- Stdlib only; no third-party imports. Scripts run as `python3 -I` (isolated mode), so no local module can shadow the stdlib.
- Standard 4-space indentation, double-quoted strings, `%`-formatting in gate messages (`"gate layout_%s %s %s" % (...)`). f-strings are not used in the existing tests.
- Each file has a module docstring that states what it locks, how it is run, and the output format.
- Module-level `failed = False` with a `global failed` declaration inside `gate()`.
- Exit via `sys.exit(1 if failed else 0)` or a `done()` helper.

**JSON and YAML formatting:**
- JSON uses 2-space indentation (see `.github/ci-tools/package.json`).
- YAML is hand-written; `tests/test_ci_guards.py` reads it by line scanning, not with a YAML library, so keep each `uses:` and `run:` on its own line in the expected form (`- uses: owner/repo@<40-hex-sha> # vX.Y.Z`).

**Linting:**
- ShellCheck is the linter. Settings live in `.shellcheckrc` (`shell=sh`, with a list of disabled codes and a comment explaining each one: SC1091, SC2015, SC2016, SC1003, SC2012, SC2181).
- Warnings are never disabled globally. A deliberate single warning carries an inline directive with a reason, for example:
  ```sh
  # shellcheck disable=SC2143  # the find output is filtered, not just tested for a match
  ```
  ```sh
  # shellcheck disable=SC2123  # an empty PATH is the case under test
  ```
- `tests/ci.sh` runs `shellcheck -s sh` over shipped and test scripts. Under `CI=true` a missing `shellcheck` is a failure.
- Python has no configured linter; keep to the stdlib style above.
- No Prettier, ESLint or Biome config exists in this repository.

## Import Organization

**Shell:**
- Tests source the shared library with the same first line: `. "$(dirname "$0")/lib.sh"`, followed by `mkwork`.
- Shellcheck directive `SC1091` is disabled repo-wide because sourced paths are computed at run time.

**Python:**
- Stdlib imports only, grouped as `json`, `os`, `subprocess`, `sys` (or `hashlib`, `re`), one per line, alphabetical.

**Path handling:**
- Scripts resolve the repository root from their own location: `REPO=$(cd "$(dirname "$0")/.." && pwd)` in `tests/lib.sh`; `ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))` in Python tests.
- Python tests accept an optional `argv[1]` root so mutation checks can point them at a copy.

## Error Handling

**Hook and installer scripts:**
- Report to the user through stderr with a fixed grammar. Example header from `report()` in `plugins/bbj/scripts/bbj-check.sh`: `bbj-local reported N error(s) in <file>:`.
- Cap feedback at 40 lines and print `(M more line(s) not shown)` for the rest.
- Installers use documented exit codes: 0 done, 2 usage error or refusal (nothing written), 3 something left to merge by hand. Document any new exit code in the header comment of the script, as `codex/install-codex.sh` does.
- Validate every option and destination before the first write; a failure before the first write exits 2 with nothing changed.
- Before changing an existing user file, write a one-time backup (`config.toml.bbj-backup`) and never overwrite a file the user owns (`hooks.json` is only written when absent).

**Tests:**
- A check reports one line through `gate NAME STATUS DETAIL`, where STATUS is `ok`, `FAIL` or `skip`. `tests/lib.sh` sets `LIB_FAILED=1` on any FAIL and `finish()` exits accordingly.
- Shell test gates use the prefix that matches the file: `contract_`, `argument_`, `no_marker_`, `static_`, `ci_guard_`, `layout_`, `skills_`.
- Python tests print `gate <prefix>_<name> ok|FAIL <detail>` and exit 1 if any gate failed.
- A test that cannot run because a prerequisite is missing reports `skip`, except under `CI=true`, where the missing prerequisite must be a `FAIL` (`tests/run.sh`, `tests/ci.sh`).

## Logging

**Framework:** None. Shipped hooks write only to stderr when reporting a compiler verdict, and nothing otherwise. Test output is the `gate` line protocol.

**Patterns:**
- Do not write to stdout from hook scripts; Claude Code treats hook stdout as a protocol channel and `tests/test_exit_contract.sh` enforces empty stdout.
- Test diagnostics go to stdout as `gate` lines so `tests/run.sh` can count them; anything else is shown verbatim.

## Comments

**Header comments:**
- Every script opens with a block comment: file name and path, a one-line purpose, the plan and decision IDs it implements (for example `plan 19-01, PLUG-01; decisions D-11 and D-12`), the exit-code contract, and what it never does (`never runs BBj`).
- Test files open with the same shape: `tests/test_exit_contract.sh -- plan 19-01 Task 3: ...`, then the scope, then "Nothing here runs BBj" or the equivalent.

**Inline comments:**
- Explain why, not what. Examples from the code: `# the compiler prints its errors on stderr and exits 0 on every outcome`, `# loopback only: ... A refused URL is never handed to curl.`
- Put a reason next to every shellcheck directive.
- Comments may describe forbidden patterns in words; the static scanners ignore full-line comments, so keep forbidden tokens out of executable lines only.

**Requirement and decision IDs:**
- Reference them by ID (`PLUG-01`, `D-12`, `D-14`) in both code comments and tests so a reviewer can trace behavior back to the decision record. Keep the ID prefix format as used in existing files.

## Function Design

**Shell:**
- Functions are short and take positional parameters with a usage comment above them: `# contract SHELLNAME CASE: exit 0 or 2, empty stdout, no marker file`, `# claude_payload TOOL FILE CWD`.
- Local-style variables inside a function use underscore names, since POSIX `sh` has no `local` keyword in all shells; never rely on `local`.
- Return values are printed on stdout and captured with `$(...)`, or set into an uppercase global (`RC`, `FAILED`).
- Restore any global that a test changes (`PATH=$_save`, `unset FAKE_EXIT`).

**Python:**
- Helper functions are small and return nothing; results go through `gate()`.

## Module Design

**Shell:**
- Shared helpers live in `tests/lib.sh` (gate, mkwork, json_escape, claude_payload, codex_payload, run_check). New test files source it instead of re-defining these.
- Compiler fakes are copied into each temporary home (`mkhome` in `tests/test_discovery.sh`); tests never call a real compiler unless they opt in.

**Hermetic environment:** `tests/lib.sh` clears `BBJ_HOME`, `BBJHOME`, `CLAUDE_PLUGIN_OPTION_BBJ_HOME`, `CLAUDE_PROJECT_DIR`, sets `BBJ_CHECK_DEFAULT_HOMES` to empty and points `BBJ_LOCAL_MCP_URL` at a closed port. Any new test must start from the same hermetic state by sourcing `lib.sh`.

**Plugin manifests:**
- One manifest per plugin under `.claude-plugin/plugin.json`; the marketplace is `.claude-plugin/marketplace.json` at the root.
- Versions are identical across both plugin manifests and both marketplace entries (`0.1.0`), and `tests/test_layout.py` enforces this. Bump all four together.
- Licence is `Apache-2.0` in every manifest.

## Git and Commit Conventions

- Conventional commit prefixes are used: `fix(19): ...`, `feat(codex): ...`, `test(19-05): ...`, `docs(19-07): ...`, `chore: ...`. Use a scope when the change belongs to a plan or to one area (`codex`).
- Plan-tagged commits carry the phase and plan number in the scope (`19-05`).
- Pinned third-party GitHub Actions are referenced by full commit SHA with a trailing `# vX.Y.Z` comment; Dependabot maintains the pins (`.github/dependabot.yml`).

## Documentation Conventions

- Markdown skill references use the `references/` subdirectory under each skill, one topic per file, lowercase hyphenated names.
- `README.md`, `docs/install-claude-code.md`, `docs/install-codex.md` describe installation; keep install steps there, not in the scripts' code comments.
- `CHANGELOG.md` records user-visible changes under a version heading (currently `## 0.1.0 (unreleased)`).

---

*Convention analysis: 2026-10-09*
