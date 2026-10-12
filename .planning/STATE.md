---
gsd_state_version: "1.0"
milestone: v0.2.0
current_phase: 6
current_phase_name: Release 0.2.0
status: executing
stopped_at: Completed 06-06-PLAN.md
last_updated: "2026-10-12T15:43:37.435Z"
last_activity: 2026-10-12
last_activity_desc: Phase 6 execution started
state_head: 75bf8050b5525da965b6ecab82a0e5e47c79caa9
progress:
  total_phases: 6
  completed_phases: 5
  total_plans: 43
  completed_plans: 41
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-11)

**Core value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).
**Current focus:** Phase 6 — Release 0.2.0

## Current Position

Phase: 6 (Release 0.2.0) — EXECUTING
Plan: 7 of 8
Status: Ready to execute
Last activity: 2026-10-12 — Phase 6 execution started

Progress: [████████░░] 83% (4 of 6 phases; Phase 1 7/7, Phase 2 6/6, Phase 3 4/4, Phase 4 8/8 plans)

## Performance Metrics

**Velocity:**

- Total plans completed: 35
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

- [Phase 3]: Skills listed as pending with ratcheted per-check counts (D-01..D-04); baseline on BBj 26.03: bbj-programming bbjcpl 44 / bbj-ls 36 / grammar 11 / structure 17, bbj-web-programming 25 / 15 / 5 / 8; nocheck 0
- [Phase 3]: UAT accepted D-08 amendment (bbj-ls-only should-fail is undecided), D-13 CI exemption (missing live routes skip under CI=true) and IN-03 (broken route skip unless BBJ_SKILLS_LIVE=1)
- [Phase 04]: [04-01] Probe records are normalized (temp dir removed everywhere, type check messages sorted) and reserved-word files are generated, only the failing words per route and form are committed
- [Phase 04]: [04-01] int() of a string primitive fails to compile on both routes (t17, t22) while int() of an object variable compiles (t23); RESEARCH t17 'clean' was not reproduced
- [Phase 04]: 04-02: exactly two OWNER ledger rows (L031 str() sign trap, L072 bbj -tIO stdout), both granted by D-22; callback-performance.md keeps three rules, java-interop.md and reserved-words.md none (ledger totals 150 rows)
- [Phase 4]: 04-03: Built in line keeps the pinned prefix and appends the scope; one line identical in SKILL.md and codex/AGENTS-snippet.md
- [Phase 4]: 04-03: str() sign trap ships unhedged as OWNER row L031 with one passing block and no should-fail block
- [Phase 4]: 04-03: SKILL.md body stops at 148 lines so the 04-05 running.md pointer fits within 150
- [Phase 04]: 04-04: sign-trap printed output left for the docs owners to fill from a real run; the proposal states only the owner-confirmed fact (L031)
- [Phase 04]: 04-04: proposal quotes checked against the raw page files fetched 2026-10-11; the docs-server 'RETURN TYPE: String' line is reported as server rendering, not page text
- [Phase 4]: 04-05: ledger count C=3 selects the D-14 default branch; callback-performance.md keeps its name and the web skill link is untouched
- [Phase 4]: 04-05: running.md states the OWNER-confirmed bbj -tIO stdout fact plainly; the PRO/5 IO page is a supporting citation only
- [Phase 04]: 04-06: database.md states LIMIT (first, count) only as SQL_LIMIT.htm does and leaves clause position to the SQL Grammar page
- [Phase 04]: 04-07: section-2 heading of SKILL.md renamed to 'Rules for writing BBj'; L117 reclassified RUNTIME (rewrite); no OWNER granted; setModal stated by route, not as absent
- [Phase 04]: Plan 04-08: D-24 shipped word for word (an existing window without the Dialog flag cannot be brought in front of an open Dialog-flag window), marked as skill-maintainer-confirmed; nothing about windows created later
- [Phase 04]: Plan 04-08: L119 is DOC with verdict drop; both pages exist but the claim goes beyond the isModal return-value sentence
- [Phase 5]: 05-01: p08 assigns getProperty to an object variable; the string assignment is kept as probe p17 because bbjcpl -t rejects it
- [Phase 5]: 05-02: ledger header pins DWC 26 (v26 design system) with BBj 26.03 build 10-01-2026_1321; SKILL.md ledgered in 88 rows, no OWNER row; owner checklist O1-O9 and O11 marked as RUNTIME drop
- [Phase 5]: 05-02: focus-ring outline mechanism dropped (docs say gap-ring shadow); padding rule rewritten in the docs' words into references/styling.md
- [Phase 5]: 05-03: ledger covers all eight skill files in 242 rows; Destinations SKILL.md, references/styling.md, form-validation.md, running-dwc-apps.md, shoelace.md; Deleted in plan 05-10: color-chooser.md, responsive-layout.md, shadow-dom-styling.md, themes.md
- [Phase 5]: 05-03: ThinClient sentence dropped (the Thin Client command-line page does not state it); client-validation 'DWC only' dropped (GUI client documented); owner checklist O1-O11 triaged, no OWNER row
- [Phase 5]: 05-04: O6 owner item asks both the overflow clipping and the documented padding, in the docs' term focus ring (no outline or box-shadow); ledger O6 line aligned
- [Phase 5]: 05-04: owner repros are compiled only (run.py covers ../owner-repros); o08 uses err= branches because try/catch does not compile in main code
- [Phase 5]: D-19 to D-27: nine owner grants (O1, O2, O4, O5, O6, O7, O9, O10, O11) recorded as OWNER-confirmed by Stephan Wald, 2026-10-12, BBj 26.03
- [Phase 5]: DWC build recorded as the BBj build 26.03 (build 10/06/2026 09:19), owner statement that DWC ships inside BBj
- [Phase 5]: O3 and O8 rejected by the owner: dropped, no grant
- [Phase 05]: 05-08: setSlot and /files/ stay pointers to SKILL.md sections in shoelace.md; DWC-only dropped from form-validation.md (ledger L103, L062, L079, L080)
- [Phase 5]: 05-09: docs proposal uses bracketed owner-fill slots for open questions; rejected owner items O3 and O8 appear only as dropped candidates
- [Phase 05]: 05-06: injectStyle top stated as the page sentence only; injectLinkUrl's head/body meaning named separately with its own URL
- [Phase 05]: 05-10: bbj-web-programming left pending via --report in the same commit as the four ledger-listed deletions; KNOWN_PENDING left unedited
- [Phase 06]: 06-01: IN-01 written in long form (getActiveContext page shows $02$ windows before and after $80002$); WR-08 skipped as resolved by 04-07; inline shellcheck directives, no .shellcheckrc change
- [Phase 06]: 06-02: each CHANGELOG installer quote sits on one line so single-line mutation checks bite; Claude Code upgrade line lists marketplace update and plugin update
- [Phase 06]: D-20: PR-branch ref install supplies the Claude Code Tested-against line; main install is the D-05 gate
- [Phase 06]: D-21: .claude/CLAUDE.md ships on main
- [Phase 06]: D-22: Codex fresh install in the real home then restored; Claude Code in a throwaway config with one owner login
- [Phase 06]: D-23: update a pin only where the release run re-exercised the fact
- [Phase 06]: 06-04: release candidate pushed (plain) and draft PR #1 opened after owner approval; Claude Code 2.1.296 git-source run passed D-13 (verdict pass), CI green on 7ec798d; hook feedback text is the model's quote, stated in result.txt
- [Phase 06]: 06-05: billed codex exec retried once with --skip-git-repo-check after the non-git scratch project was refused before any model call; no hook-trust or sandbox bypass

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 5]: Needs phase research: DWC DOM/CSS claims with no doc source; owner reproduction on a named DWC/BBj build is a human step
- [Phase 6]: Tag form `0.2.0`; Codex upgrade traps (`--force`, `/hooks` re-approval) must reach CHANGELOG and installer output
- [Phase 4]: real_home_untouched in tests/test_install_codex.sh races a local Codex daemon writing under ~/.codex; owner accepted it as an environmental flake at UAT (test 3); hardening the gate is open for a later phase
- [Phase 4]: 04-REVIEW-DISPOSITION.md still lists WR-01 (SKILL.md `@`/`&` next to the sign characters), IN-01, IN-02 as open and WR-08 as stale; owner passed UAT test 5 without recording dispositions — settle before the Phase 6 release

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-12T15:43:37.288Z
Stopped at: Completed 06-06-PLAN.md
Resume file: None
