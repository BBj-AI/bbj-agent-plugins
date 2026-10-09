# Codebase Concerns

**Analysis Date:** 2026-10-09

## Tech Debt

**BBj skill examples violate the skills' own statement rule:**
- Issue: About 50 example lines put `REM` after code without a separating `;` (for example `#theme! = dwcTheme!  REM !ERROR=26`), and at least one bare call `doSomething(v!.get(i))` is not a valid statement. A grep for the pattern finds 85 candidate lines. The skills teach the rule that the check hook enforces, so the examples contradict the rule the agent is told to follow.
- Files: `plugins/bbj/skills/bbj-programming/SKILL.md`, `plugins/bbj/skills/bbj-programming/references/*.md`, `plugins/bbj/skills/bbj-web-programming/SKILL.md`, `plugins/bbj/skills/bbj-web-programming/references/*.md`
- Impact: Agents copy invalid syntax from the examples; the compile check then rejects the agent's own output. The MCP primer states that a `REM` after a statement needs a semicolon, so the examples are the outlier.
- Fix approach: Run every example through `bbj_check_syntax` (local `bbj-ls` first, per `plugins/bbj-local/.claude-plugin/plugin.json`) and rewrite failing lines, e.g. `stmt; REM note`. Add a test under `tests/` that extracts fenced BBj blocks and checks them with the local route when BBj is present.

**Hook and installer duplicate the same logic in two shells:**
- Issue: BBj discovery, the loopback URL validation, and the JSON escaping are implemented in `plugins/bbj/scripts/bbj-check.sh` (POSIX sh with awk) and again in `codex/install-codex.sh`.
- Files: `plugins/bbj/scripts/bbj-check.sh`, `codex/install-codex.sh`
- Impact: A fix in one (for example the loopback allow-list) can miss the other.
- Fix approach: Keep one implementation and have the Codex installer copy it (it already copies the check script to a stable path), and add a gate that the two copies stay byte-identical.

## Known Bugs

**Compile check can miss errors on non-UTF-8 or control-character content:**
- Symptoms: For tier 2, the script drops ASCII control characters other than tab, LF and CR before sending a file to `bbj_check_syntax`, so the server sees different text than the file. A file that contains such characters can pass the check while the compiler would reject it.
- Files: `plugins/bbj/scripts/bbj-check.sh` (the `_code=$(LC_ALL=C tr -d ...)` pipeline in `no_tier1_route`)
- Trigger: A `.bbj` file with a stray control character (e.g. `\013`) written by an agent.
- Workaround: Tier 1 (`bbjcpl`) reads the file directly and is not affected; install BBj or set `BBJ_HOME`.

**Hook gives up silently when no route is available:**
- Symptoms: With no compiler and no reachable loopback server, `bbj-check.sh` exits 0 with no output. The agent gets no feedback and no warning.
- Files: `plugins/bbj/scripts/bbj-check.sh` (the final `exit 0` paths and the `no_tier1_route` early returns)
- Trigger: BBj not installed or `bbj-local` not enabled (it is off by default, `plugins/bbj-local/.claude-plugin/plugin.json`).
- Workaround: Enable `bbj-local` or set `bbj_home`.

## Security Considerations

**Hosted syntax, format and denum tools send source code off the machine:**
- Risk: `bbj_check_syntax`, `bbj_format` and `bbj_denum` on the hosted server transmit the user's BBj source to `https://mcp.bbj-ai.com/mcp`. Proprietary code can leave the organization without the user noticing.
- Files: `plugins/bbj/.mcp.json`, `plugins/bbj/.claude-plugin/plugin.json`, `codex/install-codex.sh`, `docs/install-codex.md`
- Current mitigation: Codex keeps the approval prompt for the three code-sending tools (`CHANGELOG.md`). The hook never calls the hosted check (`plugins/bbj/scripts/bbj-check.sh` header). The data-handling page is linked from `docs/install-claude-code.md`.
- Recommendations: Document in the install pages which tools send code and to where. Make the local `bbj-ls` route the first choice in the Claude Code docs too, and state that the hosted tools are a fallback.

**Default docs URL is a pre-production host:**
- Risk: Every install points at `https://mcp.bbj-ai.com/mcp`, which the docs describe as the pre-production instance. Behaviour, data handling and availability may change at go-live without a plugin release.
- Files: `plugins/bbj/.claude-plugin/plugin.json` (`docs_url` default), `codex/install-codex.sh`, `tests/test_install_codex.sh` (hard-codes the URL in asserts), `tests/test_layout.py` (`DOCS_HOST`), `docs/install-claude-code.md`, `docs/install-codex.md`
- Current mitigation: The install pages say the default changes at go-live. `CHANGELOG.md` records the instance as pre-production.
- Recommendations: Make the go-live change a single constant that the tests read, not a literal in four places.

**Codex installer deletes and replaces user skill directories with `--force`:**
- Risk: `rm -rf "$dst" && cp -R ...` in `codex/install-codex.sh` (around line 456) removes the whole installed skill directory, including any local edits the user made.
- Files: `codex/install-codex.sh`
- Current mitigation: Without `--force` the installer reports the difference and leaves the directory alone.
- Recommendations: Move the existing directory to a timestamped backup before replacing it, and print the backup path.

**Installer edits user config files in place:**
- Risk: The Codex installer rewrites `config.toml` and `hooks.json` under the user's Codex home, using temp files and `mv`. A bad rewrite can drop unrelated user settings.
- Files: `codex/install-codex.sh` (temp file creation near lines 379 and 489, `refuse` paths)
- Current mitigation: Temp files are created with `mktemp` in the same directory; refusals are explicit; `tests/test_install_codex.sh` covers the rewrite paths.
- Recommendations: Keep a `.bak` copy of each file before the first rewrite in a run.

## Performance Bottlenecks

**Every write or edit of a BBj file runs a compiler:**
- Problem: The `PostToolUse` hook in `plugins/bbj/hooks/hooks.json` runs `bbj-check.sh` on every `Write|Edit` call with a 30 s timeout.
- Files: `plugins/bbj/hooks/hooks.json`, `plugins/bbj/scripts/bbj-check.sh`
- Cause: `bbjcpl -t -N -X` starts a full JVM-based compiler process per file; tier 2 adds a network call of up to 12 s (`-m 12` in `no_tier1_route`).
- Improvement path: Batch the checks for multi-file patches (the Codex path already handles several files per call), and lower the tier-2 timeout so tier 1 plus tier 2 cannot exceed the 30 s hook timeout.

## Fragile Areas

**Hand-written JSON and TOML parsing in shell and awk:**
- Files: `plugins/bbj/scripts/bbj-check.sh` (`UNESC_AWK`, `JGET_AWK`, the `jget` helper), `codex/install-codex.sh` (TOML and JSON edits)
- Why fragile: The JSON reply of the MCP server is parsed by an awk state machine that handles `\uXXXX` only with `uni=1` and only under `LC_ALL=C`. Other JSON shapes (escaped quotes at chunk boundaries, SSE `data:` lines with multiple events) take a narrow path.
- Safe modification: Change one function at a time and run `sh tests/test_hook_review_fixes.sh` and `sh tests/test_discovery.sh`. Add a case for each new escape form.
- Test coverage: The unit tests cover the reply shapes that are known; no fuzzing exists.

**Hook output contract is tied to exit codes 0 and 2:**
- Files: `plugins/bbj/scripts/bbj-check.sh`, `tests/test_exit_contract.sh`
- Why fragile: Claude Code treats exit 2 as "feed stderr back to the model". Any stray stdout, or a non-zero exit from an unhandled error, changes agent behaviour. The script has deliberately no `set -e`.
- Safe modification: Keep every path ending in an explicit `exit 0` or `exit 2`; run `tests/test_exit_contract.sh` after each edit.

**Live and real-compiler tests skip silently without BBj:**
- Files: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh`, `tests/ci.sh`
- Why fragile: CI runs without BBj (`.github/workflows/ci.yml`), so the code paths that call `bbjcpl` and `bbj-ls` are never exercised there. A regression in them passes CI.
- Safe modification: Run `BBJ_LS_LIVE=1 sh tests/test_tier2_live.sh` and the real-compiler test on a machine with BBjServices before release.

## Scaling Limits

**Single-file, single-request syntax checks:**
- Current capacity: One `bbj_check_syntax` call per file, with the file text sent in full; the hosted server response is not cached.
- Limit: Large generated BBj files and long multi-file patches will hit the 12 s curl limit and the 30 s hook limit, which then return no verdict.
- Scaling path: Chunking is not designed. Raise the hook timeout in `hooks.json` only after measuring, and report a timeout as a distinct message instead of silence.

## Dependencies at Risk

**Claude CLI pinned for CI validation:**
- Risk: `.github/ci-tools/package.json` pins `@anthropic-ai/claude-code` at an exact version. `.github/dependabot.yml` deliberately does not watch it, so it will not update itself.
- Impact: `claude plugin validate --strict` in `tests/ci.sh` tests against a fixed CLI; new plugin manifest features may be rejected or unchecked until a human bumps the version.
- Migration plan: Bump it as a deliberate edit of both `package.json` and `package-lock.json`, re-run `tests/test_ci_guards.py`, and record the version in `CHANGELOG.md`.

## Missing Critical Features

**No tests that the skills' examples compile:**
- Problem: Skill examples are not checked by any gate.
- Blocks: Reliable skill edits; the `REM` problem above persisted because nothing runs the examples through a checker.

**Codex hook payload not verified end to end:**
- Problem: `plugins/bbj/scripts/bbj-check.sh` documents the Codex `apply_patch` payload as "documentation-derived (MEDIUM) and stays unverified until captured on a machine with Codex".
- Blocks: Trusting the Codex compile check for multi-file patches.

## Test Coverage Gaps

**Installer rollback and `--force` path:**
- What's not tested: Replacing an existing skill directory with `--force` and the loss of local edits (`codex/install-codex.sh`, `tests/test_install_codex.sh`).
- Files: `codex/install-codex.sh`, `tests/test_install_codex.sh`
- Risk: Silent deletion of a user's modified skill files.
- Priority: High

**Hook behaviour on non-UTF-8 and control-character input:**
- What's not tested: The tier-2 control-character stripping path with a file that contains `\013` or invalid UTF-8.
- Files: `plugins/bbj/scripts/bbj-check.sh`, `tests/test_tier2_fake.sh`
- Risk: False clean results (see Known Bugs).
- Priority: Medium

**Real BBj behaviour in CI:**
- What's not tested: Any call to `bbjcpl` or to a live `bbj-ls` (both skip without BBj).
- Files: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh`, `.github/workflows/ci.yml`
- Risk: Breaking changes in BBj 26.03+ output format go unnoticed until a manual run.
- Priority: Medium

---

*Concerns audit: 2026-10-09*
