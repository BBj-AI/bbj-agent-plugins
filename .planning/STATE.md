---
gsd_state_version: "1.0"
milestone: v0.2.1
milestone_name: Platform verification and release hygiene
current_phase: 08
current_phase_name: Codex plugin route
status: executing
stopped_at: Completed 08-02-PLAN.md
last_updated: "2026-10-13T14:17:11.233Z"
last_activity: 2026-10-13
last_activity_desc: Phase 08 execution started
state_head: 0a475f24cda4aa5862512478c394a66d8a10a6ab
progress:
  total_phases: 4
  completed_phases: 1
  total_plans: 14
  completed_plans: 8
  percent: 25
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-12)

**Core value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).
**Current focus:** Phase 08 — Codex plugin route

## Current Position

Phase: 08 (Codex plugin route) — EXECUTING
Plan: 3 of 8
Status: Ready to execute
Last activity: 2026-10-13 — Phase 08 execution started

Progress: [███░░░░░░░] 25%

## Performance Metrics

**Velocity:**

- Total plans completed: 49
- Average duration: -
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 7 | - | - |
| 02 | 6 | - | - |
| 03 | 4 | - | - |
| 04 | 8 | - | - |
| 5 | 10 | - | - |
| 6 | 8 | - | - |
| 07 | 6 | - | - |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 1 P01 | 4 min | 2 tasks | 10 files |
| Phase 1 P03 | 12 min | 2 tasks | 1 files |
| Phase 1 P04 | 9 min | 3 tasks | 2 files |
| Phase 1 P05 | 6 min | 2 tasks | 4 files |
| Phase 1 P02 | 6 min | 2 tasks | 8 files |
| Phase 1 P06 | 9 min | 3 tasks | 4 files |
| Phase 1 P07 | 6 min | 2 tasks | 4 files |
| Phase 2 P01 | 40 min | 3 tasks | 5 files |
| Phase 02 P03 | 15min | 2 tasks | 5 files |
| Phase 02 P02 | 12min | 2 tasks | 7 files |
| Phase 2 P04 | 15min | 3 tasks | 6 files |
| Phase 02 P05 | 130min | 3 tasks | 14 files |
| Phase 02 P06 | 7min | 3 tasks | 5 files |
| Phase 04 P01 | 8 min | 2 tasks | 77 files |
| Phase 04 P02 | 16 min | 3 tasks | 4 files |
| Phase 4 P03 | 30 min | 3 tasks | 4 files |
| Phase 04 P04 | 9 min | 2 tasks | 1 files |
| Phase 4 P05 | 25 min | 3 tasks | 6 files |
| Phase 04 P06 | 10 min | 2 tasks | 5 files |
| Phase 04 P07 | 9 min | 3 tasks | 6 files |
| Phase 04 P08 | 5 min | 2 tasks | 4 files |
| Phase 5 P01 | 6 min | 2 tasks | 24 files |
| Phase 5 P02 | 20 min | 3 tasks | 2 files |
| Phase 5 P03 | 45 min | 3 tasks | 1 files |
| Phase 5 P04 | 40 min | 2 tasks | 15 files |
| Phase 5 P05-05 | owner session | 3 tasks | 4 files |
| Phase 05 P07 | 10min | 2 tasks | 1 files |
| Phase 05 P08 | 15min | 3 tasks | 3 files |
| Phase 5 P09 | 5m | 2 tasks | 1 files |
| Phase 05 P06 | 30min | 2 tasks | 1 files |
| Phase 05 P10 | 8 min | 2 tasks | 6 files |
| Phase 06 P01 | 3 min | 3 tasks | 5 files |
| Phase 06 P02 | 9 min | 3 tasks | 11 files |
| Phase 06 P03 | 10min | 3 tasks | 6 files |
| Phase 06 P04 | 25 min | 3 tasks | 7 files |
| Phase 06 P05 | 11min | 3 tasks | 6 files |
| Phase 06 P06 | multi-session | 3 tasks | 7 files |
| Phase 06 P07 | multi-session | 3 tasks | 5 files |
| Phase 06 P08 | multi-session | 3 tasks | 3 files |
| Phase 07 P01 | 12 min | 2 tasks | 3 files |
| Phase 07 P02 | 8 min | 3 tasks | 5 files |
| Phase 07 P03 | 12 min | 2 tasks | 3 files |
| Phase 07 P04 | 6 min | 2 tasks | 2 files |
| Phase 07 P05 | 9 min | 2 tasks | 1 files |
| Phase 07 P06 | 3 min | 2 tasks | 1 files |
| Phase 08 P01 | 2 min | 2 tasks | 5 files |
| Phase 08 P02 | 9 min | 2 tasks | 2 files |

## Accumulated Context

### Decisions

The v0.2.0 decision log is archived with the milestone (`.planning/milestones/v0.2.0-phases/`); the lasting decisions are in the Key Decisions table of PROJECT.md.

- [Roadmap v0.2.1]: Four phases, run in order 7 → 8 → 9 → 10. The PATH scrub (WR-01) and the four review-fix commits land first (Phase 7), because the Windows and macOS machines have `bbjcpl` on `PATH` and the review fixes touch the same docs and gates that Phases 8 and 10 rewrite. The Codex plugin route (Phase 8) comes before the platform runs (Phase 9), because Phase 9 verifies that route on Windows and macOS. The install wording (Phase 10) comes last, because it may claim only what a recorded run shows.
- [Roadmap v0.2.1, user decisions after spikes 001-005]: The Codex native plugin route ships in v0.2.1. The version stays 0.2.1 (tag `0.2.1`). Copilot CLI support goes to the next milestone (spike 004). `install-codex.sh` stays for one release as a documented fallback.
- [Spikes 003/005]: On the plugin route all Codex tools prompt on first use; the installer's per-tool pre-approvals are not carried. This is an accepted trade-off: it is safer, and the code-sending tools prompted anyway. The install probe is replaced by docs and notice wording.
- [Phase 07]: Release-text gates: upgrade_addressed runs at every version; upgrade_quotes and not_run pinned to CONTENT_VERSION and FAIL with a re-pin message elsewhere (REL-06 D-04..D-07) — A version bump must not pass on older facts; a skip would block the skip=0 release run
- [Phase 07]: 07-02: no_compiler_path replaces a compiler-holding PATH directory with a symlink farm under WORK instead of dropping it — Shared directories such as /usr/local/bin keep sh, awk, curl and python3 reachable (D-11 intent); removal only when WORK is unset
- [Phase 07]: 07-03: home_snapshot lists six installer-written paths as F/D/L/U/- lines with cksum, LC_ALL=C sorted; Phase 8 extends the list — content not mtime (D-08, D-09); daemon files never read
- [Phase 07]: No gate-prefix sync gate (MAINT-08) — CI must not run the suite twice, .planning/ is stripped from the PR branch, and variable-built gate names defeat a static check
- [Phase 07]: Release tree is gsd/planning-setup; review-fix commits proven by ancestry (REL-05, D-01); local main fast-forwarded to origin/main with no push (D-02) — Phase 10 PR carries the commits to main
- [Phase 07]: 07-05: close the CONVENTIONS.md gate-prefix gap by copying the IN-04 block from .claude/CLAUDE.md (no overrides entry, no repository sync gate)
- [Phase 07]: 07-06: close the oauth_ gap by copying the CLAUDE.md line into CONVENTIONS.md (no overrides entry, no repository sync gate)
- [Phase 08]: 08-01: .codex-mcp.json ships without an oauth object; layout_codex_mcp pins the exact dict and plan 08-08 re-pins it if the owner chooses a block
- [Phase 08]: 08-01: no plugin-route path joins the home_snapshot allowlist; Codex writes the plugin cache and [marketplaces]/[plugins] itself
- [Phase 08]: 08-02: D-07 route detection kept as locked: apply_patch with non-empty CLAUDE_PLUGIN_ROOT is the plugin route; the variable is only tested, never printed (plugin-route notice wording provisional until plan 08-08, A3)

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 4]: real_home_untouched in tests/test_install_codex.sh races a local Codex daemon writing under ~/.codex; owner accepted it as an environmental flake at UAT (test 3); hardening the gate is open for a later phase (planned: Phase 7, MAINT-07)
- [Phase 6]: Review-fix commits b0a4c62, 3a42ebf, b600ac4, 172e6a5 (CHANGELOG/docs wording refinements, release-text gates) are on the planning branch only, not in tag 0.2.0; they ship with the next release (planned: Phase 7, REL-05)
- [Phase 6]: install-codex.sh and docs still say "not yet run on macOS"; the owner ran it on macOS at UAT (2026-10-12, Codex hook feedback confirmed) — update the wording in a later release (planned: Phase 10, DOCS-01..03, from the Phase 9 runs)
- [Roadmap v0.2.1]: `tests/test_release_text.py` prints `skip` for its three content gates at any version other than CONTENT_VERSION (0.2.0). At 0.2.1 that would break the skip=0 release run (REL-08), so the Phase 7 policy decision (REL-06) has to settle it
- [Roadmap v0.2.1]: The macOS run (PLAT-05) needs BBj with `bbjcpl` installed on the owner's Mac before Phase 9 can verify that route
- [Roadmap v0.2.1]: PLAT-04 needs BBjServices running on the owner's Windows machine. If it cannot run there, the gap is recorded under PLAT-06 and the docs keep a "not run" line for that route
- [Roadmap v0.2.1]: Gap with no requirement: moving an existing `install-codex.sh` install to the plugin route. Adding the plugin on top of an installer install likely leaves two hook entries (double check and double feedback), skills in both `~/.agents/skills` and the plugin cache, and a `[mcp_servers.bbj-docs]` table that overrides the plugin's server. Decided: new requirement CODEX-06 in Phase 8 (documented switch, verified on Linux)
- [Spike 001]: Whether a plugin upgrade asks for hook trust again is unknown; the trusted hash covers the versioned cache path. If trust is not asked again, the hook stops silently. Observe it on Linux in Phase 8 and document it (CODEX-05)
- [Spike 005]: Three Windows unknowns for Phase 9 (PLAT-03): does Codex run the plugin hook's `sh "..."` through Git for Windows; is `commandWindows` in a plugin `hooks.json` honoured (Codex `hooks/list` showed `commandWindows: None` on Linux); does `CLAUDE_PLUGIN_ROOT` expand to a path `sh` accepts

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| debug_sessions | dialog-flag-modality (fixed in sysgui.md by 0210c5b; session never closed) | diagnosed | 2026-10-12 | v0.2.0 |
| seeds | SEED-001 (skills home and local bbj-ls; delivered by v0.2.0) | dormant | 2026-10-12 | v0.2.0 |
| deferred_items | 02/deferred-items.md: D-1 uutils mkdir race in notice_concurrent_once (resolved by 38dfd83) | acknowledged | 2026-10-12 | v0.2.0 |
| deferred_items | 02/deferred-items.md: D-2 real_home_untouched fails while a Codex app-server daemon writes ~/.codex | acknowledged | 2026-10-12 | v0.2.0 |

## Session Continuity

Last session: 2026-10-13T14:17:11.167Z
Stopped at: Completed 08-02-PLAN.md
Resume file: None

## Operator Next Steps

- After roadmap approval, start Phase 7 with /gsd-discuss-phase 7 (then /gsd-plan-phase 7)

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 261013-cpn | Point bbj-docs at mcp.bbj-ai.com with OAuth client settings in Claude Code and Codex | 2026-10-13 | 4409b7e | [261013-cpn-point-bbj-docs-at-mcp-bbj-ai-com-with-oa](./quick/261013-cpn-point-bbj-docs-at-mcp-bbj-ai-com-with-oa/) |
