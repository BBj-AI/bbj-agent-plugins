---
phase: 08-codex-plugin-route
plan: 06
subsystem: codex-plugin-route-linux-proof
tags: [codex, plugin-route, hook-trust, upgrade, install-codex, remove, switch, throwaway-home]

requires:
  - phase: 08-codex-plugin-route
    provides: "08-05 harness (run.sh, hooks_list.py, owner.sh) and the owner-trusted home owner-H; 08-03 and 08-04 install-codex.sh --remove; 08-08 settled scope decisions (signin add-block, route d07-holds, trust yes) and the route marker"
provides:
  - "run.sh scenarios posttrust, upgrade and switch (ORDER=a or b), an in-place keep mode of safe_out, labelled exec runs with their argument line, prefixed request analysis, skill names in snap_state"
  - "08-LINUX-RUN.md sections After trust, Upgrade trust, Switch from the installer, and the 08-06 comparison under Real home untouched"
  - "CODEX-02 real half after a real /hooks trust with no bypass flag: one compiler call with -N, feedback reached the model"
  - "D-18 observation: a version-only plugin upgrade kept the hook trusted, hash unchanged, hook ran (upgrade_asks_trust_again: no), with one quotable sentence"
  - "CODEX-06 switch verified on Linux: after install-codex.sh --remove and the two plugin commands, one hook entry, one copy of each skill, one bbj-docs server; the double install shows two hooks, two compiler calls, two feedbacks"
affects: [08-07, CODEX-02, CODEX-05, CODEX-06]

actuals:
  tokens: 8507
  tasks: 2
  commits: 2
plan_head_before: d1431d464a2c9e093adaf8c48aabd48348707ced
plan_head_after: ec3d5605f662ac4a7f4b753fb34e3b3819fbae14

tech-stack:
  added: []
  patterns:
    - "A harness scenario that must keep a human-prepared home runs in keep mode: same prefix refusals, no delete, the directory must exist"
    - "A backup copy of the human-prepared home (owner-H.pre0806) is taken before an in-place run that changes it"
    - "Result keys are labelled per run (EXEC_LABEL, analyze_requests prefix) so several execs in one result.txt stay unambiguous"

key-files:
  created:
    - .planning/phases/08-codex-plugin-route/08-06-SUMMARY.md
  modified:
    - .planning/phases/08-codex-plugin-route/linux-run/run.sh
    - .planning/phases/08-codex-plugin-route/08-LINUX-RUN.md

key-decisions:
  - "The upgrade-trust sentence states only what was run: a version-only change through a local marketplace refreshed by codex plugin add; an upgrade that changes hooks/hooks.json, a Git-marketplace upgrade and a real release upgrade are recorded as not run"
  - "Which bbj-docs definition Codex used in the double install (installer table or plugin .codex-mcp.json) is recorded as not determined, because mcp list shows one line"
  - "Commit attribution line follows the harness reminder (Claude Sonnet 5.5), not the dispatch text (Claude Fable 5.1)"

patterns-established:
  - "remove_lines capture widened to every removed / left in place / nothing to remove line so the record shows skills, check script and hooks.json too"

requirements-completed: [CODEX-02, CODEX-05, CODEX-06]

coverage:
  - id: D1
    description: "After the owner's real /hooks trust and with no bypass flag, one apply_patch of a bad .bbj on owner-H ran the fake compiler once with -N and the feedback reached the model once"
    requirement: "CODEX-02"
    verification:
      - kind: other
        ref: "sh .planning/phases/08-codex-plugin-route/linux-run/run.sh posttrust ~/.cache/bbj-phase8/owner-H (result.txt: compiler_calls 1, dash_n yes, feedback_reached_model yes, bypass_flag_in_cmd 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Upgrade of the scratch copy to 0.2.0-test: refresh command, trustStatus and currentHash before and after, hook run without a new trust, upgrade_asks_trust_again no, one sentence for the docs"
    requirement: "CODEX-05"
    verification:
      - kind: other
        ref: "sh .planning/phases/08-codex-plugin-route/linux-run/run.sh upgrade ~/.cache/bbj-phase8/owner-H (result.txt: upgrade_refresh_command codex plugin add bbj@basis-bbj, trust_after_upgrade trusted, hash_changed no, hook_runs_after_upgrade yes, upgrade_asks_trust_again no)"
        status: pass
    human_judgment: true
    rationale: "The reading comes from the app server's hooks/list; the one look at the /hooks TUI after the upgrade (D-18) is the end-of-phase human check and has not been made"
  - id: D3
    description: "Switch from the installer: order a ends with one hook, one copy of each skill and one bbj-docs after --remove (rc 0) and the two plugin commands; order b records the double install (2 hooks, 2 compiler calls, 2 feedbacks) and one hook after --remove"
    requirement: "CODEX-06"
    verification:
      - kind: other
        ref: "sh run.sh switch with ORDER=a and ORDER=b (switch-a result.txt: remove_rc 0, hooks_count_plugin 1, skills_programming_plugin 1, skills_web_plugin 1, docs_servers_plugin 1, docs_url_plugin https://mcp.bbj-ai.com/mcp; switch-b: hooks_count_double 2, double_compiler_calls 2, hooks_count_after_remove 1)"
        status: pass
    human_judgment: false
  - id: D4
    description: "The real ~/.codex and ~/.agents/skills are identical before and after every run of this plan; no version or plugin file in the repository changed"
    requirement: "CODEX-05"
    verification:
      - kind: other
        ref: "home_diff realhome.before-0806 realhome.after-0806 returned 0; git diff --quiet d1431d4 HEAD -- plugins .claude-plugin tests codex docs exits 0"
        status: pass
    human_judgment: false

duration: 10min
completed: 2026-10-13
status: complete
---

# Phase 8 Plan 06: Hook After Trust, Upgrade Trust and the Installer Switch Summary

**On real Codex 0.162.1 in throwaway homes: the trusted plugin hook checks a bad `.bbj` with no bypass flag, a version-only plugin upgrade kept the hook trusted with an unchanged hash and the hook still ran, and the switch from `install-codex.sh` ends with one hook, one copy of each skill and one `bbj-docs` after `--remove` and the two plugin commands, while the double install runs the check twice.**

## Performance

- **Duration:** about 10 min
- **Started:** about 2026-10-13T15:30:32Z (after the 08-08 close-out commit; the start was not recorded by a clock call)
- **Completed:** 2026-10-13T15:40Z
- **Tasks:** 2
- **Files modified:** 2 (plus this summary)

## Accomplishments

- **CODEX-02, real half, after a real trust.** `run.sh posttrust` on owner-H, argument line saved in `exec-posttrust.cmd` without `--dangerously-bypass-hook-trust` (`bypass_flag_in_cmd: 0`): `trustStatus=trusted` before and after, the fake compiler ran once with `-t -N -X -P<proj> <file>`, and `bbjcpl reported 1 error(s) in ...` reached the model once.
- **D-18, upgrade trust, observed.** The scratch copy `owner-H/src` went to `0.2.0-test` in the five places (`versions_set: 5`); `codex plugin marketplace upgrade basis-bbj` exited 1 (`not configured as a Git marketplace`, a local marketplace), `codex plugin add bbj@basis-bbj` created `.../bbj/0.2.0-test` and removed `0.2.0`. After it: `trust_after_upgrade: trusted`, `hash_changed: no`, the `[hooks.state]` block unchanged, the expanded command now pointing at the `0.2.0-test` cache, `hook_runs_after_upgrade: yes`, `upgrade_asks_trust_again: no`. This does not match spike 001's expectation (assumption A8) for a version-only change. Recorded as one sentence beginning `Observed on Linux with Codex CLI 0.162.1:`.
- **CODEX-06, switch verified twice.** Order a (D-05): install (rc 0; 1 hook of source `user`, skills 1 each, 1 `bbj-docs`), `--remove` (rc 0; 0 hooks, 0 skills, no servers; `config.toml` left as an empty file, `config.toml.bbj-backup` kept), then `codex plugin marketplace add` and `codex plugin add bbj@basis-bbj`: `hooks_count_plugin: 1`, `skills_programming_plugin: 1`, `skills_web_plugin: 1`, `docs_servers_plugin: 1`, `docs_url_plugin: https://mcp.bbj-ai.com/mcp`. Order b (D-06): double install shows 2 hook entries (different keys and hashes), each skill twice, one `bbj-docs` line, and one bad-file `apply_patch` runs the compiler twice (both with `-N`) and delivers the feedback twice; `--remove` then leaves 1 hook, one copy of each skill and one `bbj-docs`, and a `config.toml` with only Codex's own tables.
- **Real home untouched.** `home_diff realhome.before-0806 realhome.after-0806` returned 0; no repository file other than the harness script and the record changed.
- **Harness.** `run.sh` gained `posttrust`, `upgrade`, `switch`, a keep mode for `safe_out`, labelled exec runs that save their argument line, a request-analysis prefix, `hooks_read`, `snap_state` (with skill names), `config_residue`; `shellcheck -s sh` is clean and `selftest` still refuses `/tmp`, `~/.codex`, outside paths and `..`.

## Task Commits

1. **Task 1: hook after real trust and the upgrade-trust reading** - `98ce466` (docs)
2. **Task 2: the real switch from the installer to the plugin route** - `ec3d560` (docs)

**Plan metadata:** the docs(08-06) close-out commit that adds this file (see git log).

## Files Created/Modified

- `.planning/phases/08-codex-plugin-route/linux-run/run.sh` - the three new scenarios and their helpers
- `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` - `## After trust`, `## Upgrade trust`, `## Switch from the installer`, and the 08-06 comparison under `## Real home untouched`

## Decisions Made

- The upgrade-trust sentence is limited to what was run. Not run, and said so in the record: an upgrade that changes `hooks/hooks.json`, a Git-marketplace upgrade (only the GitHub default branch is Git, and it has no Codex overlay yet), an upgrade across a real release, the `/hooks` TUI look after the upgrade (end-of-phase human check), trust of only one of two hooks in the double install, and the switch on macOS or Windows.
- Which `bbj-docs` definition Codex used in the double install is recorded as not determined (`mcp list` shows one line).
- Plan 08-07 can quote the three observed sentences directly: the upgrade sentence in `## Upgrade trust` and the two sentences at the end of `## Switch from the installer`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `remove_lines` capture too narrow**
- **Found during:** Task 2 (first switch-a run)
- **Issue:** the grep pattern `removed from|left in place|nothing to remove` missed the `removed <path>` lines for skills, check script and hooks.json
- **Fix:** pattern widened to `removed|left in place|nothing to remove`; both orders rerun
- **Files modified:** `linux-run/run.sh`
- **Committed in:** `ec3d560`

**2. [Rule 2 - Missing critical] Skill names recorded in `snap_state`**
- **Found during:** Task 2 (reading the double-install count of 2)
- **Issue:** the count alone does not show which entries make it (installer copy vs plugin copy)
- **Fix:** `skill_names` added to `snap_state`; both orders rerun
- **Files modified:** `linux-run/run.sh`
- **Committed in:** `ec3d560`

**3. Task 1 bookkeeping: backup of owner-H**
- A copy `owner-H.pre0806` was taken before the in-place runs so a refused test version could be redone. It was not needed and stays under `~/.cache/bbj-phase8/` (not committed).

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical)
**Impact on plan:** both only make the record more exact. No scope creep.

## Issues Encountered

- The exec's stderr in owner-H shows `rmcp ... AuthRequired` for `bbj-docs` (owner-H has no sign-in). It does not affect the hook and is noted in the record.
- Commit attribution: the dispatch text named `Claude Fable 5.1`; the commits carry the harness reminder's line `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`, the model that ran this plan.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. T-08-22 (silent trust across an upgrade) is answered by the observation recorded for plan 08-07; T-08-25 (runs against the real home) is answered by the `home_diff` result.

## User Setup Required

None - no external service configuration required. The end-of-phase human check is unchanged: `sh .planning/phases/08-codex-plugin-route/linux-run/owner.sh trust`, open `/hooks`, confirm the bbj hook shows `trusted` (as `## Upgrade trust` records), quit without sending a prompt. owner-H now holds the `0.2.0-test` cache.

## Next Phase Readiness

- Plan 08-07 (docs) has every observed sentence it may quote, and the list of what was not run.
- No hold, no blocker. No `codex`, `app-server` or `fake_responses` process of these runs remains.

## Self-Check: PASSED

- FOUND: `.planning/phases/08-codex-plugin-route/linux-run/run.sh`, `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md`
- FOUND commits: `98ce466`, `ec3d560`
- FOUND sections: `## After trust`, `## Upgrade trust`, `## Switch from the installer`
- No repository file under `plugins`, `.claude-plugin`, `tests`, `codex` or `docs` changed since `d1431d4`.

---
*Phase: 08-codex-plugin-route*
*Completed: 2026-10-13*
