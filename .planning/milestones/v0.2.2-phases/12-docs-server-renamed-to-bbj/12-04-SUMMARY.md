---
phase: 12-docs-server-renamed-to-bbj
plan: 04
subsystem: user-docs
tags: [readme, install-pages, sign-in, docs-server, rename, page-pins]

requires:
  - phase: 12-docs-server-renamed-to-bbj
    provides: plan 12-02, the Linux sign-in record with the fourteen-key Labels block (D-09 step 2)
  - phase: 12-docs-server-renamed-to-bbj
    provides: plan 12-01, the docs server key bbj in both MCP files and CC_LABEL in tests/test_claude_plugin.sh
provides:
  - "docs/install-codex.md: login command `codex mcp login bbj`, Auth states, Linux 2026-10-15 observation, plugin-scoped key and TOML header built from the server name bbj"
  - "docs/install-claude-code.md: `plugin:bbj:bbj` in `claude mcp list` and `/mcp`, the docs server `bbj`, tool prefix `mcp__plugin_bbj_bbj__` as recorded"
  - "README.md: plugin list with role nouns; sign-in commands as recorded; Linux 2026-10-15 observation"
  - "tests/test_install_pages.sh: pins for the login command (codex, readme), the label and the tool prefix (claude), the plugin-scoped key"
affects: [12-05]

actuals:
  tokens: 1900
  tasks: 2
  commits: 2
plan_head_before: 99831513307c0879f5dae0cc3baf87e281c8b95a
plan_head_after: 64934e8a7a6b11f8e3e933c2ab4cd7a788af8882

tech-stack:
  added: []
  patterns:
    - "Docs give a label, command or tool prefix only as 12-LINUX-RUN.md records it; every one is compared with grep -F in the plan verify and pinned as a fixed string in tests/test_install_pages.sh"
    - "A server is named in prose by role noun and name (the docs server `bbj`, the plugin `bbj`); observations made before this phase stay name-free"

key-files:
  created: []
  modified:
    - README.md
    - docs/install-codex.md
    - docs/install-claude-code.md
    - tests/test_install_pages.sh

key-decisions:
  - "CC_LABEL in tests/test_claude_plugin.sh already held plugin:bbj:bbj, the recorded cc_list_label, so the file stays unchanged (Task 1 step 6)"
  - "The Windows (2026-10-13) and macOS (2026-10-14) sign-in sentences are removed, not reworded; their confirmation under bbj is NAME-03 in Phase 15"
  - "No rename-history wording anywhere (D-12): no upgrade note, no sign-in-again list, no cleanup step"

requirements-completed: [NAME-02]

coverage:
  - id: D1
    description: "The Codex page, the Claude Code page and README give the sign-in with the exact command and labels of 12-LINUX-RUN.md; Windows and macOS sign-in sentences removed"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "12-04-PLAN.md Task 1 verify block (sh file) -> exit 0; gates codex_has_codex_mcp_login_bbj, readme_has_codex_mcp_login_bbj, claude_has_plugin_bbj_bbj ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "CC_LABEL equals the recorded cc_list_label; mcp_docs_oauth ok and mcp_docs_answers ok or skip with that label"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "sh tests/test_claude_plugin.sh -> exit 0, no FAIL; grep -xF \"CC_LABEL='plugin:bbj:bbj'\" tests/test_claude_plugin.sh -> one line"
        status: pass
    human_judgment: false
  - id: D3
    description: "Release-text gates keep one client version per platform (Claude Code 2.1.299 on Linux, Codex CLI 0.162.1)"
    verification:
      - kind: integration
        ref: "tests/test_release_text.py release_claude_version_single, release_codex_version_single; tests/test_release_text_mutation.sh -> ok"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every other mention names the docs server bbj; plugin-scoped key and TOML header built from the recorded server name; tool prefix only on the Claude Code page; no old name and no rename-history wording"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "12-04-PLAN.md Task 2 verify block (sh file) -> exit 0; git grep -n -i bbj-docs -- README.md docs/ tests/test_install_pages.sh -> exit 1, no output"
        status: pass
    human_judgment: false
  - id: D5
    description: "Full suite green"
    verification:
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=754 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 12min
completed: 2026-10-15
status: complete
---

# Phase 12 Plan 04: README and install pages name the docs server bbj Summary

**README and both install pages name the docs server `bbj` and give the sign-in with exactly the command and labels the Linux run recorded (`codex mcp login bbj`, `plugin:bbj:bbj`, tool prefix `mcp__plugin_bbj_bbj__`); the page pins hold the same fixed strings, and the Windows and macOS sign-in claims are gone until Phase 15.**

## Performance

- **Duration:** about 12 min
- **Completed:** 2026-10-15
- **Tasks:** 2 (Task 1 was the tracer)
- **Files modified:** 4 (`tests/test_claude_plugin.sh` needed no change)

## Accomplishments

- Tracer (Task 1, `f132ec2`): the Codex page's "Sign in to the docs server" block holds `codex mcp login bbj`, says `codex mcp list` shows `Not logged in` for the docs server `bbj` and `OAuth` afterwards, and carries the record's Linux observation (Codex CLI 0.162.1, 2026-10-15, fresh install from a checkout, `Successfully logged in to MCP server 'bbj'.`, `--no-browser` with the callback URL pasted back where the browser ran elsewhere). The Claude Code page says `claude mcp list` shows `plugin:bbj:bbj` with `Needs authentication`, `/mcp` lists `plugin:bbj:bbj`, and carries the record's Linux observation. README's sign-in paragraph gives `/mcp` (choose `plugin:bbj:bbj`) and `codex mcp login bbj`, with the Linux 2026-10-15 observation. The Windows (2026-10-13) and macOS (2026-10-14) sign-in sentences were removed from README and the Codex page. `tests/test_install_pages.sh` pins `codex mcp login bbj` on the Codex page and README, and `plugin:bbj:bbj` on the Claude Code page; its header line names the docs server `bbj`.
- Expansion (Task 2, `64934e8`): the Codex page's verified banner, "what the plugin brings", tool-prompt, hosted-check and check-routes sentences name the docs server (`bbj` where a name is given); the plugin-scoped key is `plugins."bbj@basis-bbj".mcp_servers.bbj` with TOML header `[plugins."bbj@basis-bbj".mcp_servers.bbj.tools.bbj_search]`, still marked "from the Codex documentation, not tried here". The Claude Code bullet starts "The docs server `bbj` (an MCP server)" and shows the tools as `mcp__plugin_bbj_bbj__<tool>`; the override sentence names the docs server `bbj`. README's plugin list reads "The plugin `bbj`: the docs server `bbj` ..." and "The plugin `bbj-local`: ...". The prefix pin `mcp__plugin_bbj_bbj__` is in the Claude Code need list; the plugin-scoped key pin follows the server name.
- `CC_LABEL` in `tests/test_claude_plugin.sh` was already `plugin:bbj:bbj` (plan 12-01 read it from real Claude Code), equal to the recorded `cc_list_label`; the file is unchanged. `mcp_docs_oauth` is ok and `mcp_docs_answers` is ok with that label (or skip when the host is unreachable) in the plan verify.
- `sh tests/run.sh` prints `SUMMARY: ok=754 fail=0 skip=0`.

## Task Commits

1. **Task 1: sign-in text with the recorded labels on both pages and README, page pins (tracer)** - `f132ec2` (docs)
2. **Task 2: every other mention names the docs server bbj; key, prefix and pins follow the record** - `64934e8` (docs)

## Decisions Made

- **CC_LABEL left alone.** It already equals the recorded `cc_list_label` byte for byte (`grep -xF` finds exactly one line), so no old/new value pair exists to report.
- **Windows and macOS sign-in claims removed, not reworded (NAME-03).** Those runs used the old server key; the sign-in under `bbj` is confirmed on Windows and macOS only in Phase 15. README names a sign-in on Linux only.
- **Client versions named.** The record's versions (Claude Code 2.1.299, Codex CLI 0.162.1) equal the ones the pages already name for Linux, so the new observations name them and the release-text gates still count one version each.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Record fidelity] `--no-browser` written in the recorded position**
- **Found during:** Task 1
- **Issue:** The plan wrote the option as `CMD --no-browser` (`codex mcp login bbj --no-browser`). The record's verbatim owner reply, the command that actually completed the sign-in, is `codex mcp login --no-browser bbj` (the CLI form is `codex mcp login [OPTIONS] <NAME>`). D-09 allows a command only as the record backs it.
- **Fix:** The Codex page writes `codex mcp login --no-browser bbj` in both places. The recorded `cx_login_command` (`codex mcp login bbj`) is still in the code block, README and the pins.
- **Files modified:** docs/install-codex.md
- **Commit:** f132ec2

**2. [Rule 2 - D-04] Role noun on the README sign-in paragraph**
- **Found during:** Task 1
- **Issue:** The edited README paragraph began "The docs server asks ...", without the name.
- **Fix:** "The docs server `bbj` asks for a one-time OAuth sign-in."
- **Files modified:** README.md
- **Commit:** f132ec2

**Total deviations:** 2 auto-fixed (both wording, no behavior or gate change). **Impact:** none on scope.

## Authentication Gates

None. The sign-in itself was done in plan 12-02 and is only recorded here.

## Issues Encountered

None. The tool shell wraps `grep` with ugrep; the plan's verify blocks were extracted to files and run with `sh <file>` as the dispatch notes advised, and both exit 0. The Linux observation text for the Claude Code page uses the record's whole "Sentence for the docs:" including the tool name, so the page and the record agree.

## Known Stubs

None.

## Threat Flags

None. Text and fixed-string pins only; no endpoint, path or trust boundary added. T-12-08 (labels copied from the record, compared with grep -F, pinned; CC_LABEL checked with grep -xF) and T-12-09 (only record-backed sentences name a label or command; one client version per platform) are mitigated by the two verify blocks and the page gates.

## Next Phase Readiness

Ready for 12-05 (scan for the old name over tests/ and the rest of the repository). README, `docs/` and `tests/test_install_pages.sh` hold no old server name; the Windows and macOS sign-in confirmation under `bbj` stays open for Phase 15 (NAME-03).

## Self-Check: PASSED

- Files modified exist: README.md, docs/install-codex.md, docs/install-claude-code.md, tests/test_install_pages.sh (FOUND).
- Commits `f132ec2` and `64934e8` are ancestors of HEAD (FOUND).
- `git grep -n -i bbj-docs -- README.md docs/ tests/test_install_pages.sh` prints nothing.
