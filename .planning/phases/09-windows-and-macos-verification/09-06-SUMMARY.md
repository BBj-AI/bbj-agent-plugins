---
phase: 09-windows-and-macos-verification
plan: 06
subsystem: testing
tags: [windows, macos, run-record, codex, commandwindows, bbjcpl, owner-session, push-transfer]

requires:
  - phase: 09-windows-and-macos-verification
    provides: plan 09-05 Windows fixes W-1 to W-3 and the interim Windows verdicts, plan 09-04 transfer method (push), plan 09-03 check-records.sh, plan 09-02 smoke.sh
provides:
  - 09-WINDOWS-RUN.md final: round 2 readings for the Codex route, the Claude Code route and the No-route notice smoke, PLAT-01 to PLAT-04 and PLAT-06 met, check-records.sh windows final exits 0
  - 09-MACOS-RUN.md: Install source (transfer: push, Linux dry run, 921/0/0), Run environment filled, Owner replies Reading 2026-10-14 round 1 (mac-ready yes, scrubbed, no_home_leak ok)
  - the macOS round 1 readings that plan 09-07 turns into route sections and the PLAT-05 verdict
affects: [09-07, 09-08, 10]

actuals:
  tokens: 13700  # chars/4 over git diff 00448fe..HEAD without STATE.md, taken before this SUMMARY (two record files only)
  tasks: 3
  commits: 4  # measured: git rev-list --count 00448fe..HEAD at SUMMARY write
plan_head_before: 00448febb2c3e78e2676e1a00e2e13cb4d16ebfa
plan_head_after: d0fb68d12fed6f00063a72fef2bd096b46f6cc1f

tech-stack:
  added: []
  patterns:
    - "Owner reply recorded as a dated Reading line plus the whole reply indented by eight spaces, blank lines left empty, the same layout for Windows and macOS"
    - "Preflight order for an owner session: suite green, dry-run clone with the fake compiler plus selftest, then the transfer by the recorded method (push, never force, only the planning branch)"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/09-06-SUMMARY.md
  modified:
    - .planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md
    - .planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md

key-decisions:
  - "D-09: the owner session started only after sh tests/run.sh showed ok=921 fail=0 skip=0 and a clone of the commit ran smoke.sh claude with the fake compiler and check-records.sh selftest"
  - "D-03 amended: the Mac uses the same transfer: push method as Windows; the branch was pushed once (origin is at d598854) and was NOT pushed after that, so local HEAD is ahead of origin and the owners' clones are on d598854 as intended"
  - "PLAT-05 gets no verdict in this plan: the macOS round 1 reading is on record and the Run environment is filled, the route sections and the verdict are plan 09-07's job"
  - "The Mac's BBj home is <home>/bbx, not /Applications/bbx; the owner replaced it in every runbook command and the record says so in the Run environment"

patterns-established:
  - "A machine-specific BBj home is recorded in the Run environment and named in the smoke blocks (bbj_home), never rewritten in the readings"

requirements-completed: [PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-06]  # PLAT-05 deliberately omitted: its input is on record, the verdict is plan 09-07

coverage:
  - id: D1
    description: "Windows record final: every W-N fixed and re-run met (W-1 in 2197273, W-2 in 950d8bf, W-3 in 16c863b); verdict lines PLAT-01 to PLAT-04 and PLAT-06 read met; unknown-commandWindows honoured; re-trust after upgrade observed"
    requirement: PLAT-06
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh windows final (exit 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "macOS record holds the round 1 reading with every key and the four smoke blocks, scrubbed, and the Run environment table filled"
    requirement: PLAT-05
    verification:
      - kind: other
        ref: "sh .planning/phases/09-windows-and-macos-verification/platform-run/check-records.sh macos filled (check no_home_leak ok, check environment_filled ok; the route-section checks still FAIL by design until plan 09-07)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Whether each macOS route reading supports a PLAT-05 met verdict, and how the three owner notes are classified"
    requirement: PLAT-05
    verification: []
    human_judgment: true
    rationale: "The verdict and the classification of the owner notes are plan 09-07's decision; this plan only records the input"

duration: owner-paced, 2026-10-13 to 2026-10-14
completed: 2026-10-14
status: complete
---

# Phase 9 Plan 06: Owner session 2 Summary

**Windows closed on the shipped hook (PLAT-01 to 04 and 06 met, all three fixes confirmed by a second reading) and the macOS round 1 pass on record from a Mac with BBj 26.03: every bbjcpl route gave the expected reading on Claude Code 2.1.296 and Codex 0.162.1.**

## Performance

- **Duration:** owner-paced across 2026-10-13 and 2026-10-14 (three executor sessions around two checkpoints)
- **Tasks:** 3 of 3
- **Files modified:** 2 record files plus this SUMMARY; no shipped code changed in this plan

## Accomplishments

- Round 2 preflight (Task 1): `sh tests/run.sh` gave `SUMMARY: ok=921 fail=0 skip=0`; a clone from a bundle ran `smoke.sh claude` with the fake compiler (exit 2, `-N` present) and `check-records.sh selftest` printed ok; the Mac's `## Install source` states `transfer: push` and the clone, HTTPS and update commands; the branch was pushed once so origin sits at d598854.
- Windows closure (Tasks 2 Part A and 3): the owner re-ran Codex, Claude Code and the No-route notice smoke on d598854. W-1 fixed in 2197273, W-2 in 950d8bf, W-3 in 16c863b, each with its re-run met. `unknown-commandWindows:` reads `honoured (re-run met with C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE)`. Codex honoured the `commandWindows` string; Claude Code on Windows ignored it without harm (the command it prints in the feedback is unchanged from round 1 and the Write, Edit and clean readings are the same). Codex asked for hook trust again after the upgrade (`re-trust after upgrade: yes`, observed because `commandWindows` changed the hook definition). `check-records.sh windows final` exits 0; verdicts: PLAT-01 met, PLAT-02 met, PLAT-03 met, PLAT-04 met, PLAT-06 met.
- macOS round 1 (Task 2 Part B): the owner replied `mac-ready: yes`, checkout-commit d598854. All keys and all four smoke blocks are present, the reply was scrubbed (`<home>`, `<checkout>`, `<work>`), appended as `Reading 2026-10-14, round 1`, and the Run environment table is filled (macOS 27.0.1 (26A434), Darwin 27.0.0, `/bin/sh` GNU bash 3.2.57(1)-release arm64-apple-darwin26, Claude Code 2.1.296, codex-cli 0.162.1, BBj 26.03 owner-reported, compiler file `bbjcpl`, BBjServices running). `check-records.sh macos filled` prints `check no_home_leak ok` and `check environment_filled ok`.

## Facts for plan 09-07 (macOS round 1 readings)

Every macOS route gave the expected reading:

| Route | Write or add bad | Edit or update bad | Clean |
|-------|------------------|--------------------|-------|
| Claude Code (cc-*) | feedback | feedback | silent |
| Codex plugin (cx-*) | feedback | feedback | silent |
| Tier 2 smoke | feedback (`bbj-local reported 1 error(s)`) | n/a | silent |
| No-route notice smoke | notice present on the first call, absent on the second, claim file present | n/a | n/a |

- Smoke blocks: `smoke claude` has claude_write_bad, claude_edit_bad, claude_write_clean, claude_space_write_bad, claude_space_write_clean (the space cases ran too) and root_form_forward; all with `dash_n: yes` and `stdout_bytes: 0`, exit 2 for bad and 0 for clean. `smoke codex` has codex_abs and codex_rel (both resolve to `<work>/cx/sub/bad.bbj`, exit 2) and codex_clean (exit 0). Hook script cksum 2633573576, identical to the checkout, `hooks_json_identical_to_checkout: yes`, `cygpath: no`, discovery source SMOKE_BBJ_HOME for the compiler routes and BBJ_HOME for tier 2 and noroute.
- Codex plugin route: `cx-marketplace-add: ok`, `cx-plugin-add: ok`, `cx-trusted: yes`, `cx-mcp-list: bbj-docs ... enabled Not logged in`, `cx-hook-command: sh "<home>/.codex/plugins/cache/basis-bbj/bbj/0.2.0/scripts/bbj-check.sh"`. Sign-in: `oauth-cc: signed in`, `oauth-cx: signed in; auth: OAuth`.
- Claude Code plugin list: `bbj` enabled (0.2.0, read from `<checkout>/plugins/bbj`, scope user); `bbj-local` not installed (the marketplace has it with `defaultEnabled: false`).
- The BBj home on this Mac is `<home>/bbx`, not `/Applications/bbx`. It was used for `SMOKE_BBJ_HOME`, `bbj_home` and `BBJ_HOME`. Cloned over HTTPS (no SSH key).
- Three owner notes that are candidate findings for plan 09-07:
  1. Codex 0.162.1 runs hooks in its app-server daemon. The daemon had been started days earlier without `BBJ_HOME`, so exporting `BBJ_HOME` in the shell before `codex` did not reach the hook (the first Codex runs fell back to tier 2, `bbj-local reported ...`) until every Codex process was stopped and Codex was restarted from the terminal with `BBJ_HOME` set. This is a D-04 observation (hook environment on Codex). The cx-* readings are from the clean restart.
  2. A stale user-level `<home>/.codex/hooks.json` left by an earlier `install-codex.sh` fired alongside the plugin hook on the first run until the owner moved it aside.
  3. `bbjcpl` reports `error at line 10 (1)` for a one-line file (its automatic line numbering, apparently), and the Claude Code model told the user that number was wrong. Also, P1 first went through a Bash write (no hook ran) and only fired after "use the write tool"; this repeats the Windows obs-1.
- The owner's Q prompt after X3 returned `{}` (no hook text), consistent with silent.

## Task Commits

1. **Task 1: Round 2 preflight, Mac install source, dry run, transfer by push** - `d598854` (docs)
2. **Task 2, Part A: Windows round 2 owner reply recorded, scrubbed** - `6524307` (docs)
3. **Task 3: Windows round 2 readings, final verdicts, commandWindows and re-trust answers** - `bb5edea` (docs)
4. **Task 2, Part B: macOS round 1 reading and Run environment** - `d0fb68d` (docs)

**Plan metadata:** the commit that carries this SUMMARY, STATE.md and ROADMAP.md (docs: complete plan)

## Files Created/Modified

- `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` - round 2 readings, final verdicts, `unknown-commandWindows`, re-trust line
- `.planning/phases/09-windows-and-macos-verification/09-MACOS-RUN.md` - Install source, Run environment, Owner replies round 1
- `.planning/phases/09-windows-and-macos-verification/09-06-SUMMARY.md` - this file

## Decisions Made

- The owner session started only after the suite was green and a dry-run clone passed (D-09).
- The Mac uses the Windows transfer method (push, D-03 amended). The branch is pushed only up to d598854; the commits after it (record work) are not pushed, which is intended because the owners' clones are on d598854.
- No PLAT-05 verdict and no macOS route verdicts here: plan 09-07 owns them.
- `requirements-completed` lists PLAT-01 to PLAT-04 and PLAT-06 only; PLAT-05 is left out on purpose (see Deviations).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical] requirements-completed omits PLAT-05**
- **Found during:** SUMMARY write
- **Issue:** the template says to copy the plan's `requirements` verbatim, but the plan's own prohibition says PLAT-05 is never marked met without the Mac's route verdicts, and those are written in plan 09-07. Marking PLAT-05 complete here would flip it in REQUIREMENTS.md on input alone.
- **Fix:** the frontmatter lists the five requirements this plan completed and leaves PLAT-05 out; `requirements.mark-complete` is not called for it.
- **Files modified:** this SUMMARY only
- **Committed in:** the plan metadata commit

---

**Total deviations:** 1 (Rule 2, a transparency guard). **Impact on plan:** none on the records; PLAT-05 stays open for plan 09-07.

## Issues Encountered

- Task 2 ran in two owner sessions (Windows round 2, then the Mac); each was a blocking-human checkpoint with its own continuation, so the plan spans three executor runs.
- `check-records.sh macos filled` still reports FAIL for `no_skeleton_status`, `verdict_lines`, `readings_dated` and `optional_reading_lines`. This is expected: the macOS route sections are plan 09-07's work. The checks this plan owns (`no_home_leak`, `environment_filled`) are ok.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 09-07 has everything for the macOS record: the round 1 keys and four smoke blocks in `## Owner replies`, the Run environment, the Install source, and the three owner notes above to classify (D-04 for the Codex daemon environment).
- Plan 09-08 and Phase 10 can use the Windows closure facts: `commandWindows` is honoured by Codex and ignored by Claude Code on Windows, and existing Codex plugin installs are asked to trust the hook again after the upgrade.
- Branch state: origin/gsd/planning-setup is at d598854; local HEAD is ahead with record commits only. Push again before any further owner round.

## Known Stubs

None. The record files have `awaiting the owner's run` status lines in the macOS route sections by design; plan 09-07 replaces them.

## Self-Check: PASSED

- Commits d598854, 6524307, bb5edea, d0fb68d exist on the branch.
- `sh check-records.sh windows final` exits 0; `sh check-records.sh macos filled` prints `check no_home_leak ok`.
- Round 1 reading count 1, smoke claude/codex block count 2.

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-14*
