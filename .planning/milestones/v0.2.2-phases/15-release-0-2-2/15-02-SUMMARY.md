---
phase: 15-release-0-2-2
plan: 02
subsystem: testing
tags: [release-run, sh, claude-code, codex, harness, install-gate, hook]

requires:
  - phase: 12-docs-server-renamed-to-bbj
    provides: signin-run/run.sh and owner.sh (the sign-in harness that is re-based here)
  - phase: 10-install-wording-and-release-0-2-1
    provides: install-gate.sh and codex-run/run.sh (the install gate and the Codex hook scenario)
provides:
  - release-run/run.sh (scenarios selftest, realhome, codex, claude, status, after; RELEASE_TREE install source)
  - release-run/owner.sh (owner modes claude, login, list, codex in the throwaway homes)
  - release-run/install-gate.sh (seven install_ gates, WANT_VERSION default 0.2.2)
  - release-run/codex-hook.sh (scenarios selftest and hook from a tree or the GitHub source)
affects: [15-05, 15-06, 15-07]

actuals:
  tokens: 11100
  tasks: 2
  commits: 2
plan_head_before: 383e178df27e4fc3e25c2c965ca1bd332cccbe4f
plan_head_after: 60945fe6f1ee2e773630f305930d62a030e5e791
commits: 2

tech-stack:
  added: []
  patterns:
    - "RELEASE_TREE as the only install source of a real-client reading, refused (exit 2) when unset, relative, under /tmp, not a git work tree or without .claude-plugin/marketplace.json"
    - "every result records the head and the tree id it installed"
    - "throwaway homes only below $HOME/.cache/bbj-phase15/, never /tmp"

key-files:
  created:
    - .planning/phases/15-release-0-2-2/release-run/run.sh
    - .planning/phases/15-release-0-2-2/release-run/owner.sh
    - .planning/phases/15-release-0-2-2/release-run/install-gate.sh
    - .planning/phases/15-release-0-2-2/release-run/codex-hook.sh
  modified: []

key-decisions:
  - "The Codex hook readings keep the trust bypass of the 0.2.1 harness and every result records hk_trust: bypassed (codex exec --dangerously-bypass-hook-trust, throwaway home); no reading claims the /hooks trust step"
  - "One script directory, release-run/, for all four scripts; they are planning records, never part of the PR or of CI"
  - "The Codex hook scenario uses the real compiler at /opt/bbx for the release tree and the GitHub source alike, so pre-merge and post-merge readings compare like with like"

patterns-established:
  - "need_tree guard before any install: a reading on the planning checkout can no longer be recorded as a reading on the release tree"
  - "scrub order OUT, RELEASE_TREE, checkout, home, as fixed strings through awk index/substr"

requirements-completed: [NAME-03, REL-10]

coverage:
  - id: D1
    description: "Sign-in harness re-based: base bbj-phase15, RELEASE_TREE install source, tree head and id recorded, bbj-local installed disabled and enabled in the after reading, DISABLE_AUTOUPDATER=1 on every claude call"
    requirement: NAME-03
    verification:
      - kind: other
        ref: "sh .planning/phases/15-release-0-2-2/release-run/run.sh selftest; shellcheck -s sh run.sh owner.sh; Task 1 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "Install gate at the phase-directory depth: seven install_ gates ok in a dry run at the checkout's own VERSION, configuration below $HOME/.cache/bbj-phase15/"
    requirement: REL-10
    verification:
      - kind: other
        ref: "WANT_VERSION=0.2.1 sh release-run/install-gate.sh $PWD; Task 2 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D3
    description: "Codex hook scenario: bbjcpl feedback for a bad file and silence for a clean one through the spike 001 fake model and the real compiler, hk_trust: bypassed recorded"
    requirement: REL-10
    verification:
      - kind: other
        ref: "sh release-run/codex-hook.sh hook $PWD $HOME/.cache/bbj-phase15/dryrun-hook; Task 2 automated verify printed ok"
        status: pass
    human_judgment: false
  - id: D4
    description: "Whether the scripts are the right instrument for the 0.2.2 release run (sign-in and hook readings by the owner) is only settled by plans 15-05 and 15-07"
    verification: []
    human_judgment: true
    rationale: "The release-run readings are owner-interactive (browser sign-in) and happen in later plans; a dry run proves the scripts work, not that the release run succeeds"

duration: 9min
completed: 2026-10-16
status: complete
---

# Phase 15 Plan 02: Release-run scripts Summary

**Four shellcheck-clean release-run scripts (sign-in harness, owner wrapper, Claude Code install gate, Codex hook scenario) that install both clients from an explicit RELEASE_TREE or the GitHub source into throwaway homes below $HOME/.cache/bbj-phase15/ and were dry-run end to end against this checkout.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-16T17:05:00Z
- **Completed:** 2026-10-16T17:14:00Z
- **Tasks:** 2
- **Files modified:** 4 (all new)

## Accomplishments

- `release-run/run.sh` is the Phase 12 sign-in harness re-based: `BASE=$REALHOME/.cache/bbj-phase15`, a `need_tree` guard, `marketplace add "$RELEASE_TREE"` in both client scenarios, `cx_tree_head`/`cx_tree`/`cc_tree_head`/`cc_tree` recorded, `DISABLE_AUTOUPDATER=1` in `cc`, bbj-local installed (expected disabled) in the claude scenario, and an `after` reading that enables bbj-local and records `cc_enable_local_rc`, `cc_after_line` and `cc_local_line`. `selftest` also proves `need_tree` refuses an unset, a `/tmp/x` and a relative tree.
- `release-run/owner.sh` is the re-based owner wrapper (base bbj-phase15, `DISABLE_AUTOUPDATER=1` in the claude mode).
- `release-run/install-gate.sh` is the plan 10-04 gate at the phase depth (ROOT four levels up): `WANT_VERSION=${WANT_VERSION:-0.2.2}`, its work directory made with `mktemp -d "$HOME/.cache/bbj-phase15/gate-XXXXXX"` and removed on exit, `DISABLE_AUTOUPDATER=1`; the seven gate names and order are unchanged.
- `release-run/codex-hook.sh` is a new scenario (`selftest`, `hook SOURCE OUTDIR`) built from the Phase 10 helpers, without the removed-route print line and without any scenario that reads a file Phase 11 deleted; it uses the real compiler (`BBJ_HOME=${REAL_BBJ_HOME:-/opt/bbx}`) and records `hk_trust: bypassed (...)`.

## Dry-run readings (this checkout, nothing signed in, nothing committed from them)

Taken at checkout HEAD `2d2e107` (tree `6097182e1cb6703561fdaa2061933a4496f8103f` for the hook run).

`dryrun-codex/result.txt` (Task 1, HEAD `383e178`, tree `dc3e507440335f96f9bcb36e71b6cea5ed5b8831`):

        cx_version: codex-cli 0.162.1
        cx_list_line: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        cx_server_name: bbj
        cx_login_rc: 124
        cx_login_started: yes
        cx_login_redirect_uri: http://localhost:47613/callback

`dryrun-claude/result.txt`:

        cc_version: 2.1.301 (Claude Code)
        cc_bbj_local_state: disabled
        cc_list_line: plugin:bbj:bbj: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication
        cc_list_label: plugin:bbj:bbj
        cc_get_oauth: yes

An extra manual check on the dry-run configuration: `claude plugin enable bbj-local@basis-bbj` succeeded and `claude mcp list` then showed `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - Connected` next to the docs server line, which is the pair of lines the `after` scenario records.

`dryrun-gate.txt` (`WANT_VERSION=0.2.1`, the checkout's own VERSION):

        gate install_marketplace_add ok marketplace added from <home>/repos/bbj-agent-plugins
        gate install_bbj ok bbj@basis-bbj installed
        gate install_bbj_version ok bbj 0.2.1 enabled
        gate install_bbj_local_disabled ok bbj-local installed and disabled
        gate install_hook_bad ok exit 2, bbjcpl reported 1 error(s)
        gate install_hook_clean ok exit 0, silent
        gate install_real_config_untouched ok plugin files of <home>/.claude-shared/dot-claude unchanged

`dryrun-hook/result.txt`:

        hk_codex_version: codex-cli 0.162.1
        hk_plugin_version: 0.2.1
        hk_mcp_docs: bbj https://mcp.bbj-ai.com/mcp - enabled Not logged in
        hk_skills: bbj:bbj-programming bbj:bbj-web-programming
        hk_trust: bypassed (codex exec --dangerously-bypass-hook-trust, throwaway home)
        hk_feedback_reached_model: yes
        hk_bad_feedback: yes
        hk_header: bbjcpl reported 1 error(s) in <out>/proj/bad.bbj:
        hk_bad_file_written: yes
        hk_clean: exit 0, silent

The spike 001 fake Responses server still drives Codex CLI 0.162.1 (flagged assumption confirmed). The dry-run directories stay in `$HOME/.cache/bbj-phase15/` and are not committed; plan 15-05 recreates them on the release tree.

## Task Commits

1. **Task 1: sign-in harness re-based end to end (run.sh, owner.sh)** - `2d2e107` (docs)
2. **Task 2: install gate and Codex hook scenario** - `60945fe` (docs)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified

- `.planning/phases/15-release-0-2-2/release-run/run.sh` - sign-in harness, RELEASE_TREE install source
- `.planning/phases/15-release-0-2-2/release-run/owner.sh` - owner modes claude, login, list, codex
- `.planning/phases/15-release-0-2-2/release-run/install-gate.sh` - seven install_ gates, 0.2.2 default
- `.planning/phases/15-release-0-2-2/release-run/codex-hook.sh` - Codex hook readings from a tree or the GitHub source

## Decisions Made

- Trust bypass kept in the Codex hook scenario, always recorded as `hk_trust: bypassed`; no owner trust step in the throwaway homes (as in the plan).
- `check_source` in `codex-hook.sh` accepts exactly an absolute tree path (not under /tmp, a git work tree with the marketplace file) or `BBj-AI/bbj-agent-plugins`; anything else is refused with exit 2.

## Deviations from Plan

None - plan executed exactly as written. Two small points inside the plan's own bounds:

- `install-gate.sh` writes the work directory path as the literal `$HOME/.cache/bbj-phase15/gate-XXXXXX` (as the plan text says) instead of through a helper variable, because the Task 2 verify greps for that literal; behavior is the same.
- `codex-hook.sh` also records `hk_exec_rc`, `hk_requests_posted`, `hk_notice_plugin_command` and `hk_done` beside the keys the plan lists; extra keys, nothing removed.

**Total deviations:** 0 auto-fixed.

## Issues Encountered

- The interactive shell of this environment replaces `grep` with a `ugrep` function (it reads `$` in a basic regex as an anchor and honors ignore files), so the first run of the Task 1 verify line reported three false misses (`base_line`, `owner_base`, `tree_source`). Running the identical verify line with the system `grep` (`unset -f grep`) printed `ok`. The scripts themselves use only `grep` calls that are valid under both.
- Both verify lines compare the recorded tree head with the current `git rev-parse HEAD`, so they hold only before the task commit; they were run before each commit. After the commits the dry-run results record the earlier heads, as expected.

## Known Stubs

None.

## Threat Flags

None - the scripts add no network endpoint or auth path; the one new surface (a GitHub source for `marketplace add`) is restricted to `BBj-AI/bbj-agent-plugins` by `check_source`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plans 15-05, 15-06 and 15-07 can run `RELEASE_TREE=<worktree> sh release-run/run.sh codex|claude <dir>`, `sh release-run/install-gate.sh <source>` and `sh release-run/codex-hook.sh hook <source> <dir>`. The release-tree worktree of plan 15-05 is the only input still missing. The owner sign-in steps (browser) remain for plan 15-05 Task 2.

---
*Phase: 15-release-0-2-2*
*Completed: 2026-10-16*

## Self-Check: PASSED
