# Codebase Concerns

**Analysis Date:** 2026-10-16

Open concerns only, as of the end of Phase 14. Each names its source. What Phases 11 to 14 closed
is gone from this file: the retired Codex route and its review warnings (Phase 11), the Phase 9
Windows warnings WR-01 to WR-03 (fixed in Phase 13, proven in 13-WINDOWS-RUN.md), the stale
prefix block and the free-form gate names (plans 14-04 and 14-05), the dead fake seams and modes
(plan 14-06, 14-SWEEP.md), the two former install pages (plan 14-01), the skill examples that
violated the statement rule (v0.2.0 rewrite, now gated by `tests/test_skill_examples.py`), and
the Codex payload shape (captured with Codex CLI 0.162.1, plan 02-05).

## Review Dispositions

**12-REVIEW (docs server renamed to `bbj`):**
- Source: `.planning/phases/12-docs-server-renamed-to-bbj/12-REVIEW-DISPOSITION.md`, `12-REVIEW-FIX.md`.
- WR-01 (install-page needles were prefixes of the old names): fixed in `c1951cb`. It is listed
  here only because the Blockers/Concerns list of `.planning/STATE.md` still words it as open;
  drop that line.
- WR-02 (`mcp_docs_answers` in `tests/test_claude_plugin.sh` depends on the `<label>: <url>` list
  format of `claude mcp list`, recorded on Claude Code 2.1.299 while CI pins 2.1.293): the gate was
  loosened in `a15d383` and passes on 2.1.299, but it has not been run against the pinned CLI
  (`npm ci` in `.github/ci-tools`), and the same layout assumption sits behind
  `claude mcp get "$CC_LABEL"`, which the fix did not change. Open until a run on 2.1.293 is
  recorded; due before the Phase 15 live run.
- IN-01 (the hook notice and the skills name the docs server only as bare `bbj`): skipped on
  purpose. A qualified tool name is Claude Code specific and the Codex-side name is not verified
  here; a Claude-only variant needs a host branch in the hook and new text gates. Accepted.

**09-REVIEW (Windows and macOS verification):**
- Source: `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-REVIEW-DISPOSITION.md`.
- IN-01: `wpath_norm` in `plugins/bbj/scripts/bbj-check.sh` strips a leading verbatim prefix but
  leaves `\\?\UNC\server\share` as a relative-looking path, which `codex_patch` then skips.
  Open, cosmetic.
- IN-03: the `FAKE_CYGDRIVE_ROOT` seam of `tests/fake-bin/cygpath` models drive-letter-first input
  only. Open, test-quality.

**13-REVIEW IN-07 (accepted limits, no code change):**
- Source: `.planning/phases/13-windows-hook-fixes/13-REVIEW.md`, `13-REVIEW-FIX.md`.
- (a) A `bbj-ls` that accepts the connection and never answers is a reached route and is not
  cached: up to 12 s per file, so three or more BBj files in one Codex patch can reach the 30 s
  hook timeout. Caching it needs an owner decision (a reached route is never cached). Stated in
  the `bbj-check.sh` header and on `docs/install.md`.
- (b) `commandWindows` was exercised under PowerShell 7 (`pwsh`) only on Linux with fakes; a real
  Windows `pwsh` run is not done (stated as "Not run" on the install page).
- (c) The Windows launcher cases offer one Git location each, except the two PATH precedence
  cases; the other layouts do not test lookup precedence.

## Tech Debt

**CI ShellCheck version is neither pinned nor recorded:**
- Issue: CI runs ShellCheck 0.9.0, local runs use 0.11.0. The
  `SC2317`/`SC2329` directive in `tests/test_path_scrub.sh` covers both, but nothing pins or records
  the CI version.
- Files: `.github/workflows/ci.yml`, `tests/ci.sh`, `.shellcheckrc`
- Impact: A finding that only one version reports passes or fails depending on where the suite runs.
- Source: `.planning/REQUIREMENTS.md`, Future Requirements ("Pin or record the CI ShellCheck
  version"); not in v0.2.2.
- Fix approach: Install a pinned ShellCheck in the workflow, or print its version in `tests/ci.sh`
  and name it in the CHANGELOG "Tested against" section.

**The `## 0.2.0` CHANGELOG entry on `main` differs from tag `0.2.0`:**
- Issue: Commits from phases 06, 07, 08 and a quick task edited the entry after the tag, and PR #2
  published them; Phase 10's own commits left it byte-identical.
- Files: `CHANGELOG.md`
- Source: `.planning/STATE.md` Blockers/Concerns; `10-SECURITY.md` observation 1.
- Fix approach: Leave the entry (history), or state the difference in the release notes of 0.2.2.

**Phase 8 SC3 wording:**
- Issue: ROADMAP Phase 8 success criterion 3 says the no-route notice "keeps its Claude Code
  wording", but review fix WR-05 reworded the Claude Code text too (it still names `bbj_home` and
  `bbj-local@basis-bbj`, pinned by `notice_claude_route_command`). The re-verification passed with
  this as an advisory.
- Source: `.planning/STATE.md` Blockers/Concerns.
- Fix approach: Amend SC3 or record it as an accepted override.

**Planning evidence and the planning branch:**
- Issue: A local developer home-directory path appears in the Phase 10 planning evidence
  (`evidence/` text files, local and unpushed, and in `10-RESEARCH.md` and `10-VALIDATION.md`,
  already pushed). The planning branch `gsd/planning-setup` is ahead of `origin/gsd/planning-setup`
  and not pushed.
- Source: `.planning/STATE.md` Blockers/Concerns.
- Fix approach: Scrub the path before the next push of the planning branch.

## Known Limitations

**Tier 2 drops control characters before the check:**
- Symptoms: For tier 2, the hook removes ASCII control characters other than tab, LF and CR before it
  sends the file text to `bbj_check_syntax`, so the server sees different text than the file. A
  file with such a character can pass tier 2 while the compiler would reject it.
- Files: `plugins/bbj/scripts/bbj-check.sh` (the `LC_ALL=C tr -d ...` pipeline in `no_tier1_route`)
- Workaround: Tier 1 (`bbjcpl`) reads the file directly and is not affected; install BBj or set
  `BBJ_HOME`. `tests/test_tier2_fake.sh` covers the request body, so the behavior is pinned.

**Tier 2 reports syntax errors only:**
- Symptoms: `bbj-ls` parses and does not type-check; a method that does not exist or a `use`
  target that does not resolve is not seen. The feedback header says `bbj-local reported`.
- Files: `plugins/bbj/scripts/bbj-check.sh`, `docs/install.md` ("Check routes")

## Security Considerations

**Hosted syntax, format and denum tools send source code off the machine:**
- Risk: `bbj_check_syntax`, `bbj_format` and `bbj_denum` on the hosted docs server `bbj` transmit the
  user's BBj source to `https://mcp.bbj-ai.com/mcp`. Proprietary code can leave the organization
  without the user noticing.
- Files: `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json`, `docs/install.md`
- Current mitigation: The hook never calls the hosted check (`plugins/bbj/scripts/bbj-check.sh`
  header, `tests/test_static_guards.sh`). The no-route notice tells the agent that the hosted check
  sends the code and that the user must be told. The install page states what is sent where and
  links the data-handling page. The Codex plugin-scoped approval is for the five docs tools only.
- Recommendations: Keep `bbj-ls` (the plugin `bbj-local`) the first choice in every client text.

## Performance Bottlenecks

**Every write or edit of a BBj file runs a compiler:**
- Problem: The `PostToolUse` hook in `plugins/bbj/hooks/hooks.json` runs `bbj-check.sh` on every
  `Write|Edit` call with a 30 s timeout.
- Files: `plugins/bbj/hooks/hooks.json`, `plugins/bbj/scripts/bbj-check.sh`
- Cause: `bbjcpl -t -N -X` starts a full JVM-based compiler process per file; tier 2 adds a network
  call of up to 12 s (`-m 12` in `no_tier1_route`) for a reached `bbj-ls` (see 13-REVIEW IN-07 (a)).
- Improvement path: Measure first; a "no route" outcome is already cached per hook run
  (`NR_T2`), a reached-but-slow route is not.

## Fragile Areas

**Hand-written JSON parsing in shell and awk:**
- Files: `plugins/bbj/scripts/bbj-check.sh` (`UNESC_AWK`, `JGET_AWK`, the `jget` helper)
- Why fragile: The JSON reply of the MCP server is parsed by an awk state machine that handles
  `\uXXXX` only with `uni=1` and only under `LC_ALL=C`. Other JSON shapes (escaped quotes at chunk
  boundaries, SSE `data:` lines with multiple events) take a narrow path.
- Safe modification: Change one function at a time and run `sh tests/test_hook_review_fixes.sh` and
  `sh tests/test_discovery.sh`. Add a case for each new escape form.
- Test coverage: The unit tests cover the reply shapes that are known; no fuzzing exists.

**Hook output contract is tied to exit codes 0 and 2:**
- Files: `plugins/bbj/scripts/bbj-check.sh`, `tests/test_exit_contract.sh`
- Why fragile: Claude Code treats exit 2 as "feed stderr back to the model". Any stray stdout
  (only the no-route notice is allowed), or a non-zero exit from an unhandled error, changes agent
  behaviour. The script has deliberately no `set -e`.
- Safe modification: Keep every path ending in an explicit `exit 0` or `exit 2`; run
  `tests/test_exit_contract.sh` after each edit.

**`commandWindows` is a long PowerShell string pinned by text:**
- Files: `plugins/bbj/hooks/hooks.json`, `tests/test_layout.py` (`layout_hook_command_windows`)
- Why fragile: The pin proves the text, not the behavior; the behavior was observed in hand runs
  (13-WINDOWS-RUN.md). Any edit needs a re-pin and a new run on Windows.
- Safe modification: Change the string only with the run harness of Phase 13 and update the pin.

**Live and real-compiler tests skip silently without BBj:**
- Files: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh`, `tests/test_skill_examples.py`
  (live routes), `tests/ci.sh`
- Why fragile: CI runs without BBj (`.github/workflows/ci.yml`), so the code paths that call `bbjcpl`
  and `bbj-ls` for real are never exercised there. A regression in them passes CI.
- Safe modification: Run `BBJ_LS_LIVE=1 sh tests/test_tier2_live.sh`, the real-compiler test and
  `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` on a machine with BBjServices before
  a release.

## Scaling Limits

**Single-file, single-request syntax checks:**
- Current capacity: One `bbj_check_syntax` call per file, with the file text sent in full.
- Limit: Large generated BBj files and long multi-file patches will hit the 12 s curl limit and the
  30 s hook limit, which then return no verdict.
- Scaling path: Chunking is not designed. Raise the hook timeout in `hooks.json` only after
  measuring, and report a timeout as a distinct message instead of silence.

## Dependencies at Risk

**Claude CLI pinned for CI validation:**
- Risk: `.github/ci-tools/package.json` pins `@anthropic-ai/claude-code` at an exact version.
  `.github/dependabot.yml` deliberately does not watch it, so it will not update itself.
- Impact: `claude plugin validate --strict` in `tests/ci.sh` tests against a fixed CLI; new plugin
  manifest features may be rejected or unchecked until a human bumps the version. Tests that read
  the CLI's output format (see 12-REVIEW WR-02 above) can drift between the pin and a newer local CLI.
- Migration plan: Bump it as a deliberate edit of both `package.json` and `package-lock.json`,
  re-run `tests/test_ci_guards.py`, and record the version in `CHANGELOG.md`.

## Test Coverage Gaps

**Real BBj behaviour in CI:**
- What's not tested: Any call to `bbjcpl` or to a live `bbj-ls` (both skip without BBj).
- Files: `tests/test_real_compiler.sh`, `tests/test_tier2_live.sh`, `.github/workflows/ci.yml`
- Risk: Breaking changes in BBj 26.03+ output format go unnoticed until a manual run.
- Priority: Medium

**Windows and macOS hosts:**
- What's not tested: The suite runs on Linux only; the Windows branch runs through the fake
  `cygpath`. The `noconn` write-out shape of the Git for Windows `curl` is unmeasured (RESEARCH A7
  of Phase 13); the classification fails safe. Not run on a real host: `pwsh`, a real per-user Git
  for Windows install, Git on another drive, the plugin `bbj-local` in a client on macOS.
- Files: `tests/fake-bin/cygpath`, `tests/test_discovery.sh`, `docs/install.md` ("Not run" lines)
- Risk: A Windows-only regression passes CI.
- Priority: Medium

---

*Concerns audit: 2026-10-16*
