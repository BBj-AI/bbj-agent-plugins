---
gsd_state_version: "1.0"
milestone: v0.2.0
current_phase: 3
current_phase_name: Example gate and structure lints
status: executing
stopped_at: Phase 3 context gathered
last_updated: "2026-10-10T15:39:58.924Z"
last_activity: 2026-10-10
last_activity_desc: Phase 02 complete, transitioned to Phase 3
state_head: b2d5cbc6b6bc83540b828475befb4fc0c6bbefc4
progress:
  total_phases: 6
  completed_phases: 2
  total_plans: 17
  completed_plans: 13
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-10)

**Core value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).
**Current focus:** Phase 3 — Example gate and structure lints

## Current Position

Phase: 3 (Example gate and structure lints) — READY TO EXECUTE
Plan: Not started
Status: Ready to execute
Last activity: 2026-10-10 — Phase 02 complete, transitioned to Phase 3

Progress: [███░░░░░░░] 33% (2 of 6 phases; Phase 1 7/7, Phase 2 6/6 plans)

## Performance Metrics

**Velocity:**

- Total plans completed: 13
- Average duration: -
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 7 | - | - |
| 02 | 6 | - | - |

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

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: Stop-vendoring folded into Phase 1 with the Codex local route; LOCAL-05 edits both SKILL.md files, which the hash test blocks until vendoring is gone, and VEND-02/LOCAL-06 edit the same docs
- [Roadmap]: Phase 3 (gate) runs after Phase 1 so the baseline is taken on repo-owned skills that already carry the shared check-order block
- [Roadmap]: Phase 2 (hook) is independent and can run in parallel with Phase 1 or 3
- [Roadmap]: Gate runs `bbjcpl -t -N -X` then `bbj-ls`; a `bbj` block must pass every available route
- [Phase 1]: [01-01] Gate name no_vendoring_wording is assembled from VEND_WORD so test_layout.py never spells the banned word — Keeps the scoped grep-zero over tests/ empty while the printed gate name stays as planned
- [Phase 1]: [01-03] sync_server reads only srv_* globals set by use_docs; helpers stay top-level; awk gets the server name only via -v srv with regexes built in BEGIN
- [Phase 1]: [01-04] bbj-local url rule lives in state(): srv_fixed_url=1 and a url other than the fixed one is foreign (exit 3); section 1b runs sync_server only with --with-local or a managed block (D-09)
- [Phase 1]: [01-05] Check-order block is pinned as exact decoded bytes between bbj-check-order markers in the snippet and both SKILL.md files; client_neutral runs on all three copies — Drift of any copy, or a client name in any copy, fails the suite
- [Phase 1]: [01-02] Skills described as repository-owned in .claude/CLAUDE.md and all seven codebase maps with identical wording, so regenerated GSD sections keep it — Avoids reintroducing vendoring text on regeneration
- [Phase 1]: [01-06] Probe verdict is the bbj_check_syntax name in the tools/list reply; with --with-local the probe only selects the printed line and bbj-local is registered on every outcome — LOCAL-04 predicate: registered anyway, warning on every outcome but found; the seam moves only the probe, never the registered url (D-17)
- [Phase 1]: [01-06] curl_gate skips message-only say lines; the curl rules of the hook now hold for codex/*.sh — The installer's no-curl message holds the word curl but is not a call; a mutation run without --noproxy still fails the gate
- [Phase 1]: [01-07] Install docs describe the no-flag found line as printed (same url twice by default) and keep bbjcpl first: preferred means over the hosted check — Quoted installer fragments are held by codex_quoted_messages_in_installer; local_not_above_bbjcpl forbids ranking bbj-local over bbjcpl on all three files
- [Phase 2]: Plan 02-01: only curl exit 7 is no route; every other curl exit, an empty reply, a JSON-RPC error, an isError result and text with neither verdict is route failed and silent (D-01, D-03)
- [Phase 2]: Plan 02-01: the 'not repeated' clause is printed only when this call created the marker, so tell-anyway failures and a missing session id never claim a silence that will not follow (D-11 with D-16, D-17)
- [Phase 2]: Plan 02-01: json_body maps every byte outside printable ASCII to ? so a file name can never make the notice object invalid JSON or invalid UTF-8
- [Phase 02]: 02-03: install docs and installer wording state the no-route notice without naming the delivery channel, so it stays true if Codex uses the exit-2 fallback (D-15)
- [Phase 02]: A compiler without a verdict goes through tier 2 like no compiler: status 1 is noted noresult, status 2 (route failed) stays silent (02-02, D-02, D-03)
- [Phase 02]: Exit contract amended only for the three notice cases; single-writer static gate counts hookSpecificOutput lines (02-02, HOOK-03)
- [Phase 2]: 02-04: Claude Code delivers a PostToolUse hook's additionalContext to the model (real capture, local-marketplace install, mode marketplace); no Claude Code fallback needed
- [Phase 02]: 02-05: Codex delivers PostToolUse additionalContext to the model after apply_patch (codex_delivered yes, codex-cli 0.162.1); D-15 exit-2 fallback not needed
- [Phase 02]: 02-05: run 2 used hooks-approval with -s danger-full-access in the scratch project (user decision; bwrap cannot create user namespaces here)
- [Phase 02]: 02-05: the model paraphrased the notice (refuses to quote hidden developer context verbatim); accepted as delivery because PATCH 1 carries the Codex-only BBJ_HOME/bbjcpl enable step
- [Phase 02]: 02-06: D-15 not applied, codex_delivered yes; OUTCOME.md records d15_fallback not-needed (paraphrase caveat) and rerun not-needed; no billed re-run
- [Phase 02]: 02-06: codex_payload fixture follows the captured Codex key order (codex-cli 0.162.1, plan 02-05)

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 3]: Decide how CI stays meaningful while the current skills are red against the gate (pending-skill list vs report-only); regenerate baseline counts (bbjcpl failures 50 vs 69; untagged fences 7 vs 135 differed between researchers)
- [Phase 4]: Needs phase research: claim ledger, RUNTIME-claim policy (rewrite to compile-time observable or drop), primer cross-check; no `!ERROR=26` entry found in BASIS docs
- [Phase 5]: Needs phase research: DWC DOM/CSS claims with no doc source; owner reproduction on a named DWC/BBj build is a human step
- [Phase 6]: Tag form `0.2.0`; Codex upgrade traps (`--force`, `/hooks` re-approval) must reach CHANGELOG and installer output

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-10T12:48:03.159Z
Stopped at: Phase 3 context gathered
Resume file: .planning/phases/03-example-gate-and-structure-lints/03-CONTEXT.md
