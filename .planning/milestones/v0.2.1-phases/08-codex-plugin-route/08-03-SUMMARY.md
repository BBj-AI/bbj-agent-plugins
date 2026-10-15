---
phase: 08-codex-plugin-route
plan: 03
subsystem: installer
tags: [codex, install-codex, remove, config-toml, hooks-json, posix-sh, awk, round-trip]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-01 kept the home_snapshot watched list and added the CLAUDE_PLUGIN_ROOT unset to tests/lib.sh; both are used unchanged"
provides:
  - "sh codex/install-codex.sh --remove: undoes the bbj-docs and bbj-local entries of config.toml, identical skill directories, the check script (and its directory) and an unmodified hooks.json; never calls codex, creates no directory"
  - "render_hooks: the single renderer of the hooks.json block, used by install step 4 and by cmp in --remove"
  - "analyze keys inblock, closed and extra, and the functions remove_server, remove_tables and remove_all"
  - "14 remove_ gates in tests/test_install_codex.sh, with the helpers rm_env, rm_user_cfg, rm_snap, rm_installed, rm_cycle, rm_equal"
affects: [08-04, 08-06, 08-07]

actuals:
  tokens: 9412
  tasks: 2
  commits: 2
plan_head_before: 5146a0ce7a7aa1e74f6e77b726676292de1572ff
plan_head_after: 21dbc7dda9cc94bad3af6e68a534e892b824c8e6

tech-stack:
  added: []
  patterns:
    - "Removal decided by the same analyze classification as the install path, plus extra=0 (nothing in the tables that the script does not write), then one awk pass with a blank-line buffer"
    - "Round trip proved by content snapshots (home_snapshot before install and after remove), not by a list of expected files"
    - "Self-mutation of the installer copy (temp tree, one change each) to show a gate can fail"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/test_install_codex.sh

key-decisions:
  - "A bbj-docs table is removed only when its url equals the --docs-url in effect (RESEARCH A11); a custom-url registration is left with exit 3 and the rerun hint, because it is also the documented Codex override of the plugin's server"
  - "A comment inside the server's tables counts as extra (the installer writes none), so a user-edited table is left whole rather than half removed"
  - "A managed-block marker of either server (generic marker regex) ends a table and is not table content, so a bbj-docs table written by codex mcp add followed by the bbj-local block is still removable"
  - "A begin marker without a later end marker is left (closed=0), so the awk pass can never delete to the end of the file"
  - "--remove writes config.toml.bbj-backup with the install side's rule and message when none exists, and never deletes it"

patterns-established:
  - "remove_ is the gate prefix of the remove tests; plan 08-07 Task 3 adds it to the prefix block in .claude/CLAUDE.md"
  - "Remove mode wraps the install pre-flight in a branch that creates nothing; remove_all contains no mkdir and no codex call outside say lines (acceptance grep)"

requirements-completed: [CODEX-06]

coverage:
  - id: D1
    description: "--remove returns the Codex home and skills dir of a fake-codex install to the pre-install content, except the user's config.toml.bbj-backup, without a codex call; a second run is a no-op that reports six nothing-to-remove lines; next steps and --help name the option"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#remove_round_trip_codex, remove_backup_kept, remove_never_calls_codex, remove_second_run_noop, remove_prints_next_steps, remove_usage"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every installer-written form round-trips: managed bbj-docs block, bbj-local blocks, markers-only, legacy default_tools_approval_mode form, custom url (left without the flag, removed with it), CRLF config.toml, and install-remove-install equals the first install"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#remove_round_trip_managed, remove_round_trip_with_local, remove_markers_only, remove_old_key_form, remove_custom_url_left, remove_custom_url_with_flag, remove_crlf_config, remove_reinstall_equals_first"
        status: pass
    human_judgment: false
  - id: D3
    description: "The install path is unchanged: the hooks.json block is byte-identical, STATUS_LINE is verbatim and all 102 earlier gates of the file stay ok"
    requirement: CODEX-06
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#first_hooks_json, command_windows_cygpath, foreign_hooks_untouched and the 99 other earlier gates"
        status: pass
    human_judgment: false
  - id: D4
    description: "A real Codex 0.162.1 install followed by --remove leaves a TOML-equivalent config.toml (layout written by the real codex mcp add)"
    requirement: CODEX-06
    verification: []
    human_judgment: true
    rationale: "Checked only with the fake codex here; the real-codex run is plan 08-06 Task 2 (RESEARCH A9, Pitfall 9)"

duration: 12min
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 03: Installer --remove Summary

**`install-codex.sh --remove` undoes exactly what the installer wrote (bbj-docs and bbj-local tables, OAuth and tool tables, managed blocks, identical skills, check script, unmodified hooks.json) with no codex call and no new directory, proved by home_snapshot round trips for every form the installer writes.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-10-13T14:19:16Z
- **Completed:** 2026-10-13T14:31:16Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `--remove` runs a no-mkdir pre-flight (refuses with exit 2 when the Codex home does not exist), then `remove_all`: config.toml first (bbj-docs, then bbj-local, each through `remove_server`), then the two skills, the check script and its directory (`rmdir`), then hooks.json (`cmp -s` against `render_hooks`). It prints the next steps (`codex plugin marketplace add BBj-AI/bbj-agent-plugins`, `codex plugin add bbj@basis-bbj`, `/hooks`) and exits 0, or 3 when something differing was left in place.
- `analyze` gained `inblock`, `closed` and `extra`; `remove_server` turns them and the existing classification into `absent`, `remove` or `left` with a reason (url mismatch names `rerun with --docs-url <url>`). `remove_tables` is one awk pass with a blank-line buffer that restores the pre-install bytes, including CRLF files, and writes in place so a symlinked config.toml keeps its link.
- `render_hooks` is the one renderer of the hooks.json block; step 4 now calls it, and the install output and written bytes are unchanged (all 102 earlier gates still ok).
- 14 `remove_` gates, each in its own temp home with the fake codex or a PATH without codex.

## Task Commits

1. **Task 1: End-to-end removal slice (tracer)** - `6a52a99` (feat)
2. **Task 2: Every installer-written form (TDD)** - `21dbc7d` (test)

**Plan metadata:** recorded in the docs(08-03) commit that adds this file.

_TDD note: the eight Task 2 gates passed on their first run, so there is no RED commit. Task 1's action already specified the whole design (analyze keys, blank buffering, CR handling, markers-only, url rule), and it was implemented there. Because an unexpected green can mean a blind test, each gate was shown to fail: six mutated copies of the installer (blank-line drop removed, CR strip removed, oauth table not removed, url rule off, markers-only branch off, legacy key not accepted) each failed exactly the intended gates (m1 managed, with_local, markers_only, crlf; m2 crlf; m3 round_trip_codex, second_run_noop, reinstall; m4 custom_url_left; m5 markers_only; m6 old_key_form)._

## Files Created/Modified

- `codex/install-codex.sh` - `--remove` option, remove-mode pre-flight, `render_hooks`, `analyze` keys, `remove_server`, `remove_tables`, `remove_all`, header (paragraph R), exit-code text and `usage()`
- `tests/test_install_codex.sh` - the `remove_` section with six helpers and 14 gates; `rmdir` added to the PATH farm used by the no-codex cases

## Decisions Made

- Custom-url registrations are removed only with the same `--docs-url` (A11); the rule lives in `remove_server`, so the owner can change it in one place.
- Comments and unknown keys inside the server's tables make the whole server `left`; nothing is half removed.
- Either server's managed-block marker ends a table (generic marker regex in `analyze` and `remove_tables`), which keeps `codex mcp add` tables followed by the bbj-local block removable.
- An unterminated begin marker is left (`closed=0`), so the removal can never run to the end of the file.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added `rmdir` to the test PATH farm**
- **Found during:** Task 2 (no-codex cases)
- **Issue:** the farm of tools used by `NO_CODEX` had no `rmdir`, which `--remove` needs for the check-script directory; without it the run would report the directory as holding other files and exit 3.
- **Fix:** added `rmdir` to the tool list of the farm in `tests/test_install_codex.sh` (one word).
- **Files modified:** tests/test_install_codex.sh
- **Verification:** `remove_round_trip_managed` and the other no-codex gates pass
- **Committed in:** 21dbc7d

**2. [Rule 1 - Bug, caught before commit] Apostrophe inside the awk program broke the single-quoted shell string**
- **Found during:** Task 1 (first `sh -n`)
- **Issue:** a comment in the new `analyze` awk code contained `server's`, ending the shell quote.
- **Fix:** reworded the comment.
- **Verification:** `sh -n` and shellcheck clean before the first commit
- **Committed in:** 6a52a99

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug caught pre-commit)
**Impact on plan:** none on scope. One commit-trailer difference: the commits carry `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` as the harness attribution instruction states, not the Fable 5.1 name in the dispatch note.

## Issues Encountered

None. Verification commands run: `sh tests/test_install_codex.sh` (exit 0, 116 ok gates, 0 FAIL, 14 `remove_` ok), `shellcheck -s sh` on both files, the `static_*_install-codex.sh` gates (12 ok, none FAIL), `python3 -I tests/test_release_text.py` (all ok), and the plan's grep acceptance criteria (one `render_hooks()`, `STATUS_LINE` verbatim, zero `mkdir`/`codex <word>` in `remove_all` outside `say` lines). `tests/run.sh` was not run (wave-1 isolation); plan 08-04 Task 2 runs it on the merged wave.

## Known Stubs

None.

## Threat Flags

None. The new delete surface (`rm -rf` of two fixed skill directories, `rm -f` of the check script, `rmdir`, `rm -f` of hooks.json, in-place config.toml rewrite) is the one in the plan's threat model (T-08-08 to T-08-11) and carries the planned guards: identical-by-`diff -r`, non-symlink, fixed child names, `cmp -s` for hooks.json, extra=0 and url equality for config.toml, backup before the first change.

## Next Phase Readiness

- Ready for 08-04, which adds the refusals (`--remove` with `--with-local` or `--force`) and the left-in-place matrix on top of this option; the `remove_server` `left` reasons and `anytool` rule (not covered by a 08-03 gate; mutation m7 showed it) are its subject.
- 08-06 Task 2 must check the layout written by the real `codex mcp add` for TOML equivalence after `--remove` (flagged assumption, coverage D4).
- 08-07 owns docs/install-codex.md and the `remove_` entry in the gate-prefix block of `.claude/CLAUDE.md`.

## Self-Check: PASSED

- FOUND: codex/install-codex.sh, tests/test_install_codex.sh
- FOUND commits: 6a52a99, 21dbc7d (ancestors of HEAD)

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
