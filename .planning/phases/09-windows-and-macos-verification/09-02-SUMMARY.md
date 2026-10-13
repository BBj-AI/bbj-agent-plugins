---
phase: 09-windows-and-macos-verification
plan: 02
subsystem: testing
tags: [posix-sh, smoke-driver, windows, macos, git-bash, xtrace, scrubber]

requires:
  - phase: 08-codex-plugin-route
    provides: Codex apply_patch branch of the hook and the plugin-route payload shapes
  - phase: 09-windows-and-macos-verification
    provides: plan 09-01 fake cygpath seam (read, not rewritten)
provides:
  - platform-run/smoke.sh with subcommands claude, codex, tier2, noroute and emit DIR
  - result-block and header key contract (case, file_as_sent, cwd_as_sent, compiler_call, compiler, p_list, target, dash_n, exit, stdout_bytes, first_feedback_line, outcome, notice_first, notice_second, claim_file, state_dir)
  - scrubber that replaces home, checkout and temp directory in POSIX, backslash and forward-slash forms
affects: [09-03, 09-04, 09-05, 09-06, 09-07, 09-08]

actuals:
  tokens: 5000
  tasks: 2
  commits: 2
plan_head_before: ec8302a7424a317d56fc37e797b312dcb813cc01
plan_head_after: 10c07104b67dbac4637c3377063931a72f67a78c

tech-stack:
  added: []
  patterns:
    - "Compiler argv read from a second run of the unmodified hook under sh -x with PS4=+TRACE (no shim, no patched hook)"
    - "Literal-substring scrubber in awk (index/substr) fed through ENVIRON, never awk -v"
    - "Source tests/lib.sh after reading the caller's BBj variables and presetting SCRIPT"

key-files:
  created:
    - .planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh
  modified: []

key-decisions:
  - "Under dash the xtrace arguments are unquoted, so compiler, p_list and target are derived only when the hook shell is bash; otherwise the block says 'derived: none (unquoted trace)' and keeps the raw compiler_call"
  - "tier2 and noroute print a bbj_home_used line saying every compiler route is off, because the header shows the caller's BBj home"
  - "emit refuses a DIR that exists and is not empty, or is not a directory, before the header is printed or anything is written"

patterns-established:
  - "Owner-run smoke driver beside the phase records, never CI, reaching a compiler only through the shipped hook"

requirements-completed: [PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-05]

coverage:
  - id: D1
    description: "claude subcommand: Write, Edit, clean, space-directory and hooks.json root-form cases, each with the traced compiler call and its derived parts, -N, exit code and first feedback line"
    requirement: PLAT-01
    verification:
      - kind: other
        ref: "plan 09-02 Task 1 automated verify (bash --posix and dash runs against tests/fake-bin/bbjcpl): counts 5/5/6/1/6/0/0, rc 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "Block scrubbing: no real home path in any block, BBj home kept as written, paths reach awk through ENVIRON only"
    requirement: PLAT-02
    verification:
      - kind: other
        ref: "grep -F \"$HOME/\" over all Linux outputs prints 0; grep -c 'awk -v' outside comments prints 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "codex, tier2, noroute and emit subcommands (Codex payload forms, loopback outcome, no-route notice with claim file, PowerShell probe payloads)"
    requirement: PLAT-03
    verification:
      - kind: other
        ref: "plan 09-02 Task 2 automated verify: rc 0/0/0/0, second emit rc 2, codex 3 cases, tier2 2 outcomes, notice_first present, notice_second absent, claim_file present, 3 JSON files valid"
        status: pass
    human_judgment: false
  - id: D4
    description: "Behaviour on a real Windows (Git Bash) and macOS machine with a real BBj install"
    requirement: PLAT-05
    verification: []
    human_judgment: true
    rationale: "Linux with the fake compiler cannot show MSYS argument conversion, cygpath forms, the Windows compiler file name or CRLF output; the owner's run (plans 09-04 to 09-08) is the evidence"

duration: 4min
completed: 2026-10-13
status: complete
---

# Phase 09 Plan 02: Smoke driver Summary

**Owner-run POSIX sh smoke driver that feeds the shipped hook Claude Code and Codex payloads, reads the exact compiler argv from an sh -x second run, and prints scrubbed key: value result blocks (claude, codex, tier2, noroute, emit)**

## Performance

- **Duration:** 4 min
- **Started:** 2026-10-13T18:56:46Z
- **Completed:** 2026-10-13T19:01:00Z
- **Tasks:** 2
- **Files modified:** 1 (created)

## Accomplishments
- `smoke.sh claude` runs Write, Edit, clean, and space-in-path cases plus the hooks.json command string with the plugin root in forward-slash (and, on Windows, backslash) form; each block shows `compiler_call`, `compiler`, `p_list`, `target`, `dash_n`, `exit`, `stdout_bytes`, `first_feedback_line`.
- Header on every subcommand names shell and hook shell version, cygpath, checkout commit, hook script cksum, whether script and hooks.json equal the checkout's (for a run against the Codex plugin cache via SMOKE_ROOT), the hooks.json command, and the discovery source (D-04).
- `codex` covers the apply_patch path forms (absolute, relative, and on Windows backslash, forward slash and verbatim `\\?\`), `tier2` prints outcome feedback, silent, notice or other, `noroute` prints notice_first, notice_second, claim_file and the state directory, `emit DIR` writes three payload files for the PowerShell probes and refuses a non-empty DIR.
- Proven on Linux under dash and `bash --posix` with the fake compiler; also ran once against the machine's real bbjcpl (bad file exit 2, clean exit 0, `-N` in every call) and a live loopback bbj-ls (bad file feedback, clean file silent).

## Task Commits

1. **Task 1: Tracer slice (header, scrubber, case runner, claude subcommand)** - `2b89efc` (test)
2. **Task 2: codex, tier2, noroute and emit subcommands** - `10c0710` (test)

**Plan metadata:** recorded in the docs(09-02) commit that carries this file.

## Files Created/Modified
- `.planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh` - the owner-run driver, mode 100755, about 480 lines

## Decisions Made
- Dash prints xtrace arguments unquoted, so derived keys are cut only when the hook shell reports a bash version; otherwise the raw line is kept (as the plan's flagged assumptions state).
- tier2 and noroute add a `bbj_home_used: none` line because the shared header prints the caller's BBj home even though those subcommands switch every compiler route off.
- A regular file given to `emit` is refused like a non-empty directory.

## Deviations from Plan

None - plan executed exactly as written. Minor additions inside the plan's intent: the `note:` and `outcome:` lines are produced through two globals of `case_run` (CASE_NOTE, WANT_OUTCOME), and `root_form` prints `none` for an empty first feedback line to match the case blocks.

## Issues Encountered
- A real bbj-ls (java) is listening on 127.0.0.1:5009 on this machine and `BBJ_HOME=/opt/bbx` is set in the shell, so the plan's acceptance wording "with no bbj-ls listening both tier-2 blocks print outcome: notice" was proved with `SMOKE_LOCAL_URL=http://127.0.0.1:9/mcp` (closed port, notice in both blocks, under sh and bash --posix). Against the live server the blocks print `feedback` for the bad file and `silent` for the clean one. No script change was needed.

## User Setup Required

None - no external service configuration required.

## Known Stubs

None.

## Threat Flags

None. The script adds no network endpoint of its own (the loopback call is the hook's), writes only under its mkwork directory and the refused-if-non-empty `emit DIR`.

## Next Phase Readiness
- Plan 09-03 can reference the five subcommands, `SMOKE_BBJ_HOME`, `SMOKE_ROOT` and `SMOKE_LOCAL_URL` in the runbooks and record skeletons.
- Windows-only behaviour (cygpath forms, MSYS argument conversion, Windows compiler name, CRLF) is untested until the owner's run; the Windows cases are written but have not executed on a real Git Bash.

## Self-Check: PASSED

- FOUND: .planning/phases/09-windows-and-macos-verification/platform-run/smoke.sh (mode 100755)
- FOUND commits: 2b89efc, 10c0710
- shellcheck -s sh clean; no compiler, bbj or curl command of its own outside comments; no `awk -v` outside comments
- Acceptance criteria of both tasks re-run and passing

---
*Phase: 09-windows-and-macos-verification*
*Completed: 2026-10-13*
