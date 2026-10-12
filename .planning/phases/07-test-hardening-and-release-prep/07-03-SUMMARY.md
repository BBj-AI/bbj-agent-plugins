---
phase: 07-test-hardening-and-release-prep
plan: 03
subsystem: testing
tags: [sh, home-guard, cksum, snapshot, codex, maint-07]

requires:
  - phase: 07-test-hardening-and-release-prep
    provides: "07-02 helpers no_compiler_path and no_compiler_env in tests/lib.sh (kept in place)"
provides:
  - "home_snapshot and home_diff in tests/lib.sh (content snapshot of the six installer-written paths)"
  - "real_home_untouched in tests/test_install_codex.sh now content-based, daemon files ignored"
  - "tests/test_home_guard.sh, 13 CI-run gates (prefix homeguard_) proving both directions on fake homes"
affects: [07-04 conventions gate-prefix list (add homeguard_), phase 8 plugin-route paths (extend the home_snapshot list)]

actuals:
  tokens: 2600
  tasks: 2
  commits: 2
commits: 2
plan_head_before: 4108e7c0e5a4a4a432a3a0ab06ea6959bef28341
plan_head_after: 8354f016006648d98e29c3b7d3977e1ef7d7c10b

tech-stack:
  added: []
  patterns:
    - "snapshot-and-compare of an allowlist: kind + cksum + path lines, LC_ALL=C sorted, never a time"
    - "fake home per case under $WORK, expect NAME same|differ"

key-files:
  created: [tests/test_home_guard.sh]
  modified: [tests/lib.sh, tests/test_install_codex.sh]

key-decisions:
  - "Snapshot format F <crc> <size> <path>, D, L, U, - <path>, sorted with LC_ALL=C (Claude's discretion under D-09)"
  - "Six watched paths in one for-list in home_snapshot: config.toml, config.toml.bbj-backup, hooks.json, bbj/, bbj-programming/, bbj-web-programming/; Phase 8 extends this list"
  - "Accepted residual risk: Codex rewriting config.toml when a session trusts a new project fails real_home_untouched by design; recorded in the home_snapshot comment"

requirements-completed: [MAINT-07]

coverage:
  - id: D1
    description: "real_home_untouched passes while a Codex daemon writes runtime files (logs_*.sqlite*, state, history, sessions, log, tmp, auth.json) and compares content, not mtime"
    requirement: "MAINT-07"
    verification:
      - kind: unit
        ref: "sh tests/test_home_guard.sh#homeguard_daemon_files_ignored, homeguard_touch_ignored, homeguard_restore_same"
        status: pass
      - kind: integration
        ref: "sh tests/test_install_codex.sh#real_home_untouched"
        status: pass
    human_judgment: false
  - id: D2
    description: "A change to config.toml, config.toml.bbj-backup, hooks.json, bbj/ or either installed bbj skill still fails the gate"
    requirement: "MAINT-07"
    verification:
      - kind: unit
        ref: "sh tests/test_home_guard.sh#homeguard_config_edit_detected, backup_created_detected, hooks_created_detected, bbj_dir_created_detected, skill_file_changed_detected, skill_dir_added_detected, skill_dir_removed_detected"
        status: pass
    human_judgment: false
  - id: D3
    description: "test_install_codex.sh uses the helper on the real homes and keeps no mtime comparison"
    requirement: "MAINT-07"
    verification:
      - kind: unit
        ref: "sh tests/test_home_guard.sh#homeguard_install_codex_uses_helper"
        status: pass
    human_judgment: false
  - id: D4
    description: "Gate stays green while a real Codex daemon runs"
    verification: []
    human_judgment: true
    rationale: "Needs a live Codex daemon on the maintainer's machine; the optional end-of-phase human check was not done. Daemon writes are covered on fakes."
duration: 12min
completed: 2026-10-12
status: complete
---

# Phase 07 Plan 03: Home guard Summary

**real_home_untouched now compares cksum snapshots of the six paths the Codex installer can write, so a running Codex daemon no longer breaks the suite, and 13 fake-home gates prove it catches every real change.**

## Performance
- **Duration:** about 12 min / **Tasks:** 2 / **Files modified:** 3 (1 created)

## Accomplishments
- `home_snapshot CODEXHOME SKILLSDIR` and `home_diff BEFORE AFTER` in `tests/lib.sh`, after the 07-02 helpers, with Provides entries. Only `find`, `cksum`, `sort` and `printf` run; file content is never printed and `auth.json` is never opened.
- `tests/test_install_codex.sh`: the marker file, the one-second sleep and the `find -newer` check are gone; snapshots go to `$WORK/home.before` and `$WORK/home.after`. No case was added.
- `tests/test_home_guard.sh`: 13 `homeguard_` gates on throwaway homes under `$WORK` (daemon files, touch, restore, config, backup, hooks, `bbj/`, skill file changed/added/removed, diff output shape, static guard on `test_install_codex.sh`).
- Snapshot format: `F <crc> <size> <path>`, `D <path>`, `L <path>`, `U <path>`, `- <path>` (absent), sorted with `LC_ALL=C`.
- Watched paths (Phase 8 extends the list): `config.toml`, `config.toml.bbj-backup`, `hooks.json`, `bbj/`, `bbj-programming/`, `bbj-web-programming/`.
- Parallel check: two simultaneous `sh tests/test_home_guard.sh` runs both exit 0 with 13 ok gates each; no `bbjplug.*` directory is left in `/tmp`.
- Full suite: `SUMMARY: ok=787 fail=0 skip=0`. `shellcheck -s sh` is clean on the three files.

## Task Commits
1. **Task 1: tracer slice (helpers, switched gate, first two fake-home cases)** - `81dff99` (test)
2. **Task 2: all remaining fake-home cases and static guard** - `8354f01` (test)

## Files Created/Modified
- `tests/lib.sh` - `home_snapshot`, `home_diff`, Provides header entries
- `tests/test_install_codex.sh` - `real_home_untouched` uses the helper; header sentence updated
- `tests/test_home_guard.sh` - new, prefix `homeguard_`

## Decisions Made
- Snapshot format and the six-path list as above. Accepted residual risk (T-07-09): Codex rewrites `~/.codex/config.toml` when a session trusts a new project or changes a TUI option; that content change fails `real_home_untouched` by design. Do not open Codex in a new project during a suite run. Recorded in the `home_snapshot` comment.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Header comment added a third `gate real_home_untouched` match**
- **Found during:** Task 1 acceptance check (`grep -c 'gate real_home_untouched'` printed 3, wanted 2)
- **Fix:** reworded the header parenthesis to "the real_home_untouched gate compares content ..."; folded into the Task 1 commit by amend (not pushed)
- **Files modified:** tests/test_install_codex.sh
- **Commit:** `81dff99`

**Total deviations:** 1 (wording only). **Impact on plan:** none.

## Issues Encountered
None.

## Known Stubs
None.

## Threat Flags
None. The helper reads only the allowlist and writes only to `$WORK`.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
Ready for 07-04. The conventions gate-prefix list there needs `homeguard_` (and `pathscrub_` from 07-02). The optional human check with a live Codex daemon (start Codex, run `sh tests/test_install_codex.sh`, expect `gate real_home_untouched ok`) was not done.

## Self-Check: PASSED
- `tests/test_home_guard.sh` exists; `home_snapshot() {` and `home_diff() {` present once each in `tests/lib.sh`
- Commits `81dff99` and `8354f01` are ancestors of HEAD

---
*Phase: 07-test-hardening-and-release-prep*
*Completed: 2026-10-12*
