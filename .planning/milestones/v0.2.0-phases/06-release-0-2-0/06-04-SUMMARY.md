---
phase: 06-release-0-2-0
plan: 04
subsystem: release-candidate
tags: [git-source-install, claude-code, draft-pr, d-13, throwaway-config, ci]

requires:
  - phase: 06-release-0-2-0
    provides: plan 06-03, strict PR branch gsd/planning-setup-pr (head 7ec798d) and the owner decisions D-20 to D-23
provides:
  - Release candidate published on origin (branch gsd/planning-setup-pr, plain push) and draft PR #1 "Release 0.2.0" against main
  - D-13 evidence on a real Claude Code 2.1.296 for the Tested against line (evidence/claude/result.txt, verdict pass)
  - bbj@basis-bbj 0.2.0 installed from the pushed git ref over HTTPS into a throwaway config
  - First CI result on the pushed head (success)
affects: [06-05 Codex run, 06-06 Tested against line, 06-07 merge and main install gate, 06-08 tag]

actuals:
  tokens: 2500
  tasks: 3
  commits: 2
plan_head_before: b1a815437d218a0b585e7cc9a29b96b3b1b3d395
plan_head_after: c165bf03c395ddcc546b32f56ade7b4780fb69ac

tech-stack:
  added: []
  patterns:
    - "Billed claude -p run in a scratch project, tools limited to Write/Edit/Read, raw stream kept outside the repository and deleted; only a field-filtered extract is committed"
    - "Real-config fingerprint (cksum of installed_plugins.json and known_marketplaces.json) taken before, after the probe and after the run"

key-files:
  created:
    - .planning/phases/06-release-0-2-0/evidence/claude/git-source-probe.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/real-config.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/pr.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/plugins.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/stream-extract.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/result.txt
    - .planning/phases/06-release-0-2-0/evidence/claude/ci-rc.txt
  modified: []

key-decisions:
  - "The hook feedback text in the evidence is the model's verbatim quote of what it received: stream-json carries no separate hook event, so result.txt says so in an evidence_note line"
  - "The push and the draft PR followed the owner's written approval ('push approved') at the Task 2 checkpoint, exactly the list the checkpoint named"

requirements-completed: [REL-03]

coverage:
  - id: D1
    description: "The git-source install path works over HTTPS by ref into a throwaway config before anything is pushed"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/claude/git-source-probe.txt (marketplace add #main, install bbj@basis-bbj exit 0, enabled; push dry run exit 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Release candidate pushed (no force) and draft PR #1 against main opened after the owner's approval"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/claude/pr.txt; gh pr view 1 shows isDraft true, base main, head gsd/planning-setup-pr; git ls-remote equals local 7ec798d"
        status: pass
    human_judgment: false
  - id: D3
    description: "D-13 on a real Claude Code: bbj 0.2.0 from the pushed ref; feedback after Write and Edit of a bad .bbj; silence for a clean one; no MCP tool call"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/claude/result.txt (verdict: pass), stream-extract.txt, plugins.txt"
        status: pass
    human_judgment: false
  - id: D4
    description: "bbj-local installs disabled, enable works, claude mcp list shows it connected at http://127.0.0.1:5009/mcp"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/claude/plugins.txt"
        status: pass
    human_judgment: false
  - id: D5
    description: "Real Claude Code configuration unchanged; throwaway config and its login deleted; CI result of the pushed head recorded"
    requirement: REL-03
    verification:
      - kind: other
        ref: "evidence/claude/real-config.txt (before = after-probe = after-run), ci-rc.txt (conclusion: success)"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-10-12
status: complete
---

# Phase 6 Plan 04: Release candidate push and Claude Code run Summary

**Release candidate published as draft PR #1 and installed from its git ref into a throwaway Claude Code 2.1.296 config, where the hook gave bbjcpl feedback for the bad .bbj (Write and Edit), stayed silent for the clean one, and bbj-local went from disabled to connected; CI is green on the pushed head.**

## Performance

- **Duration:** about 25 min for this continuation (Task 3); Task 1 was a previous agent
- **Completed:** 2026-10-12
- **Tasks:** 3 (Task 1 tracer, Task 2 owner checkpoint, Task 3 push and run)
- **Files modified:** 7 evidence files created or changed under `evidence/claude/`

## Accomplishments

- **Publication.** `git push origin gsd/planning-setup-pr` (plain, no force) put head `7ec798d73192831f3fb712d13a8e02573fa17c7e` on origin; `git ls-remote` equals the local ref. Draft PR: number 1, https://github.com/BBj-AI/bbj-agent-plugins/pull/1, base `main`, head `gsd/planning-setup-pr`. Body: the line "Release 0.2.0 of the basis-bbj marketplace. Draft until the release run is recorded in CHANGELOG.md (Tested against).", the CHANGELOG 0.2.0 entry, and the line "🤖 Generated with [Claude Code](https://claude.com/claude-code)". Nothing merged, nothing tagged.
- **Install from the pushed ref (HTTPS).** `claude plugin marketplace add BBj-AI/bbj-agent-plugins#gsd/planning-setup-pr` cloned `https://github.com/BBj-AI/bbj-agent-plugins.git (ref: gsd/planning-setup-pr)`; `claude plugin install bbj@basis-bbj` then `claude plugin list` shows `Version: 0.2.0`, enabled. (From `#main` in the Task 1 probe the same list showed 0.1.0.)
- **Billed run, Claude Code 2.1.296**, scratch project, `BBJ_HOME=/opt/bbx`, `--permission-mode acceptEdits --allowedTools Write Edit Read --max-budget-usd 2`; reported cost 0.1594 USD, 5 turns, no permission denials. Four tool calls in order: Write bad.bbj, Edit bad.bbj, Write clean.bbj, Edit clean.bbj. Hook feedback, as the model quoted it:
  - after Write of bad.bbj: `bbjcpl reported 1 error(s) in .../bad.bbj:` then `.../bad.bbj: error at line 10 (1): print "a"   rem same line`, then `bbj_lookup gives exact syntax for a named symbol.`
  - after Edit of bad.bbj: the same header with `print "b"   rem same line`
  - after Write and Edit of clean.bbj: `no hook feedback`
  - No `bbj_check_syntax` or other MCP tool call happened (four tool_use entries, all Write or Edit); the hosted check was not contacted.
- **bbj-local.** `claude plugin install bbj-local@basis-bbj` said "disabled by default", `plugin list` showed `✘ disabled`; after `claude plugin enable bbj-local@basis-bbj` the list showed enabled and `claude mcp list` showed `plugin:bbj-local:bbj-local: http://127.0.0.1:5009/mcp (HTTP) - ✔ Connected` (also `plugin:bbj:bbj-docs: https://mcp.bbj-ai.com/mcp` connected).
- **Safety.** Real configuration fingerprint `installed_plugins.json 1911936145:1623 known_marketplaces.json 2784929980:553` equal before, after the probe and after the run. `/tmp/bbj-release-06/claude-config` (with the login), `claude-proj`, the raw stream, its stderr, the prompt and the PR body file were deleted. Secret and identity grep over `evidence/claude/` (including the account e-mail, organisation and session fields) found nothing.
- **CI.** Both runs on head `7ec798d` finished `success`: push run 38268023025 and pull_request run 38268038620 (job `plugins`, about one minute each). No fix needed.

## Task Commits

1. **Task 1: Git-source path probed over HTTPS without pushing (tracer)** - `0993775` (docs)
2. **Task 2: Owner approval and login** - checkpoint, no commit; owner reply "push approved"; login observed by the orchestrator as loggedIn, authMethod claude.ai
3. **Task 3: Push, draft PR, install from the pushed ref, D-13 run, bbj-local, cleanup, CI** - `c165bf0` (docs)

**Plan metadata:** the commit that adds this SUMMARY (docs: complete plan)

## Files Created/Modified

- `evidence/claude/git-source-probe.txt`, `real-config.txt` - Task 1; `real-config.txt` gained the `after-run:` line
- `evidence/claude/pr.txt` - number, url, head
- `evidence/claude/plugins.txt` - install, list, enable and `mcp list` outputs
- `evidence/claude/stream-extract.txt` - tool_use calls, tool results, the final result text, version and cost; no session id, account or token fields
- `evidence/claude/result.txt` - D-13 verdict lines, `claude_version: 2.1.296`, `date: 2026-10-12`
- `evidence/claude/ci-rc.txt` - head, conclusion, run URL

## Decisions Made

- The hook text in the evidence is the model's own verbatim quote: stream-json has no separate hook event and the tool results show only "created/updated successfully". `result.txt` carries an `evidence_note:` line saying so, so 06-06 can word the Tested against line honestly.
- No other decisions; the plan was followed as written.

## Deviations from Plan

None - plan executed exactly as written. Two additions inside the plan's freedom: `result.txt` has two extra lines (`run_cost_usd`, `evidence_note`) beyond the interfaces keys, and `ci-rc.txt` has a `checks:` and a `run:` line.

## Issues Encountered

- `claude -p` printed "no stdin data received in 3s, proceeding without it" on stderr; harmless, the run completed.
- The compiler's message says `error at line 10 (1)` for a one-line file. The model guessed the hook adds an offset; I did not investigate (the run was the D-13 check, not a line-number audit). bbjcpl numbers unnumbered source lines itself, so this is probably the compiler's own numbering, but that is unverified. Noted for the owner, not a plan failure.

## Authentication Gates

Task 2 (owner login in the throwaway config) was the planned human-action gate; completed by the owner. The throwaway config was deleted locally; the server-side session of that login may remain listed in the claude.ai account until the owner signs it out there.

## Known Stubs

None.

## Threat Flags

None. The push and the draft PR were the planned publication (T-06-14 mitigated by the Task 2 approval); T-06-11 to T-06-13 mitigations verified by the verify block (no secret text, real config unchanged, no MCP tool call).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-05 (Codex run) can proceed. 06-06 has what it needs for Tested against: Claude Code 2.1.296 (the same version rc-facts.md records), date 2026-10-12, source ref `BBj-AI/bbj-agent-plugins#gsd/planning-setup-pr`, head 7ec798d. CI is already green on the head, so 06-06 has nothing to fix from this plan; any further change to the release tree must be re-pushed and re-checked.
- Draft PR #1 stays draft and unmerged until 06-07.

## Self-Check: PASSED

- All seven files under `evidence/claude/` exist; commits `0993775` and `c165bf0` are ancestors of HEAD; origin `gsd/planning-setup-pr` equals `7ec798d`; plan-level verification (draft PR against main, `verdict: pass`, real config fingerprint equal) passed.

---
*Phase: 06-release-0-2-0*
*Completed: 2026-10-12*
