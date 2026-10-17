---
phase: 13-windows-hook-fixes
plan: 01
subsystem: hook
tags: [posix-sh, curl, tier-2, bbj-ls, codex-apply-patch, windows]

requires:
  - phase: 09
    provides: the Windows branch (cygpath on PATH, 5 s connect timeout) and the WR-02 review finding
provides:
  - one tier-2 attempt per hook run when nothing is reached (refused, nocurl, badurl, noconn)
  - noconn no-route state from curl -w write-out, with its own notice wording
  - FAKE_CURL_WRITEOUT seam in the fake curl
  - four SC2 gates in tests/test_tier2_fake.sh
affects: [13-03 (mutation case for the t2-cache line), 13-04, 13-06 (Codex install page states the limit)]

actuals:
  tokens: 3143
  tasks: 2
  commits: 3
plan_head_before: be28efb170f85001bfb76a6481272a515fdedf8e
plan_head_after: f4db02f245375038738dd94b08693a53d6ca936d

tech-stack:
  added: []
  patterns:
    - "per-run cache in an existing global (NR_T2), checked on the first line of no_tier1_route and marked '# t2-cache' so a mutation can delete it"
    - "curl -w write-out split at the last newline to classify a timeout"

key-files:
  created: []
  modified:
    - plugins/bbj/scripts/bbj-check.sh
    - tests/fake-bin/curl
    - tests/test_tier2_fake.sh
    - tests/test_noroute_notice.sh

key-decisions:
  - "New NR_T2 value is noconn, not the word in D-12, because a bare timeout word on a code line fails static_timeout_command"
  - "A bbj-ls that accepts the connection and never answers is a reached route: not cached (D-11), no total time cap (D-13), costs up to -m 12 per file; stated in the hook header"
  - "No new global: NR_T2 is already reset in main, one hook call is one process"

requirements-completed: [FIX-02]

coverage:
  - id: D1
    description: "A many-file Codex apply_patch with no route on the Windows branch tries tier 2 once and the notice still counts and lists every file"
    requirement: FIX-02
    verification:
      - kind: unit
        ref: "tests/test_tier2_fake.sh#tier2_once_windows_refused"
        status: pass
    human_judgment: false
  - id: D2
    description: "A connect timeout with no connection made (curl 28, time_connect 0, no remote_ip) is cached and noticed as 'connect timed out'"
    requirement: FIX-02
    verification:
      - kind: unit
        ref: "tests/test_tier2_fake.sh#tier2_once_windows_connect_timeout"
        status: pass
    human_judgment: false
  - id: D3
    description: "A reached route is never cached: a transfer timeout and an answering bbj-ls are asked once per file"
    requirement: FIX-02
    verification:
      - kind: unit
        ref: "tests/test_tier2_fake.sh#tier2_transfer_timeout_not_cached"
        status: pass
      - kind: integration
        ref: "tests/test_tier2_fake.sh#tier2_every_file_when_answering"
        status: pass
    human_judgment: false
  - id: D4
    description: "Deleting the t2-cache line is caught by the once gate (12 curl calls)"
    requirement: FIX-02
    verification:
      - kind: other
        ref: "13-01-PLAN.md Task 1 verify (sed-deleted copy run through SCRIPT=)"
        status: pass
    human_judgment: false

duration: 13min
completed: 2026-10-15
status: complete
---

# Phase 13 Plan 01: Tier-2 Connect Paid Once Per Hook Run Summary

**The first "nothing reached" tier-2 outcome of a hook run (refused, no curl, URL refused, or a connect timeout with no TCP connection, read from curl's write-out) is remembered in NR_T2, so a 12-file Codex apply_patch on the Windows branch makes one curl call and still lists all 12 files in the no-route notice.**

## Performance

- **Duration:** 13 min
- **Started:** 2026-10-15T17:57:47Z
- **Completed:** 2026-10-15T18:10:23Z
- **Tasks:** 2 (tracer + TDD)
- **Files modified:** 4

## Accomplishments

- Tracer: `case "$NR_T2" in refused|nocurl|badurl|noconn) return 1 ;; esac # t2-cache` is the first code line of `no_tier1_route`; `note_noroute` still counts and lists the skipped files (D-14). Gate `tier2_once_windows_refused` asserts 1 curl call for 12 files at `--connect-timeout 5` and 'and 7 more' in the notice; the copy without the cache line fails it with "12 curl call(s) want 1".
- Expansion: the curl line gained `-w '\n%{time_connect} %{remote_ip}'` (still one line, `--noproxy '*'`, `--proto =http`, no redirect flag). Exit 28 with an all-zero time_connect and an empty remote_ip becomes `NR_T2=noconn` with the notice reason "no bbj-ls answering on <host:port> (connect timed out)". Exit 28 with a connection, or with no write-out at all, stays silent (`notice_curl_exit_28_silent` unchanged).
- Reached routes are never cached: `tier2_transfer_timeout_not_cached` (12 calls, silent) and `tier2_every_file_when_answering` (real curl, fake bbj-ls, 12 requests, silent).
- Full suite: `sh tests/run.sh` SUMMARY ok=771 fail=0 skip=0; `sh tests/ci.sh` ok=6 fail=0 (validate --strict and shellcheck included).

## Task Commits

1. **Task 1 (tracer): cache slice** - `1e6f05b` (fix)
2. **Task 2 RED: failing connect-timeout gate and write-out seam** - `15423a8` (test)
3. **Task 2 GREEN: noconn classification and notice** - `f4db02f` (fix)

## TDD Gate Compliance

Task 2 is `tdd="true"` inside an `execute` plan. RED `15423a8` added `tier2_once_windows_connect_timeout` (and two pin gates) plus the `FAKE_CURL_WRITEOUT` seam; the target gate failed on its planned assertion ("12 curl call(s) want 1", no notice), the other new gates passed by design (D-11 cases hold before the change). GREEN `f4db02f` made it pass. No refactor commit.

## Deviations from Plan

None - plan executed exactly as written. The one wording point is not a deviation: the plan already records `noconn` over the D-12 example word.

The RED/GREEN split produced two commits for Task 2 (the plan named one); the tracer commit and the GREEN commit carry the plan's messages.

## Known Limit (stated, not a gap)

A bbj-ls that accepts the connection and never answers is a reached route: it is not remembered (D-11) and no total time cap exists (D-13), so it costs up to `-m 12` for each file of a many-file patch (RESEARCH Open Question 2, Pitfall 9). The SC2 30 s bound covers "no check route" only (refused, nocurl, badurl, noconn). Stated in the hook header comment; plan 13-06 carries it onto the Codex install page and plan 13-04 into the 13-WINDOWS-RUN.md intro.

## Known Stubs

None.

## Threat Flags

None. The edited curl line keeps loopback-only, `--noproxy '*'`, `--proto =http` and no redirect flag; `static_curl_call`, `static_url_hosts`, `static_timeout_command` and `contract_` gates pass.

## Issues Encountered

None.

## Self-Check: PASSED

- plugins/bbj/scripts/bbj-check.sh, tests/fake-bin/curl, tests/test_tier2_fake.sh, tests/test_noroute_notice.sh: found, modified
- commits 1e6f05b, 15423a8, f4db02f: ancestors of HEAD
- both task `<verify>` commands exit 0; run.sh `fail=0`
