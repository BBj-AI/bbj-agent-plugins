---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 03
subsystem: infra
tags: [codex-installer, posix-sh, awk, refactor, golden-diff]

requires:
  - phase: none
    provides: independent of 01-01 and 01-02
provides:
  - sync_server in codex/install-codex.sh, fed only by the srv_* globals
  - use_docs, the one place that sets every global for bbj-docs
  - analyze and the rewrite awk take the server name only as awk -v srv and build their regexes in BEGIN
affects: [01-04, 01-06]

status: complete

actuals:
  tokens: 5040
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "one global group per server (srv, srv_tools, srv_begin, srv_end, srv_url, srv_old_key, srv_codex_add, srv_label, srv_untouched, srv_approved_note) read by a single sync_server function; POSIX sh has no local"
    - "server name reaches awk only as -v srv; the main-table, tool-table and tool-prefix regexes are built in BEGIN"
    - "refactor proven by a throwaway golden harness: six scenarios compared byte for byte (stdout+stderr+exit, config.toml, backup) after each task"

key-files:
  created: []
  modified:
    - codex/install-codex.sh

key-decisions:
  - "Helpers (analyze, refresh, an, tools_in_state, print_tools, print_block, state) stay top-level functions that read the srv globals; only the decision and rewrite logic is wrapped in sync_server, so no function is defined inside another"
  - "The two OLD_KEY_LINE messages and the default_tools_approval_mode message keep the literal hosted-tool names (bbj_check_syntax, bbj_format, bbj_denum); they are guarded by the legacy-key state, which only the docs server can reach"
  - "srv_begin is not passed to analyze: nothing in the analysis uses it until plan 01-04 adds the managed= field"

patterns-established:
  - "Golden before/after capture in a directory outside the repository, deleted at the end"

requirements-completed: [LOCAL-01]

duration: 12 min
completed: 2026-10-09
---

# Phase 1 Plan 03: Installer server-block refactor Summary

**Codex installer's bbj-docs logic is now one `sync_server` driven by `srv_*` globals (set by `use_docs`) with the server name reaching awk only as `-v srv`, byte-identical on six golden scenarios and all 55 existing install gates.**

## Performance

- **Duration:** about 12 min
- **Tasks:** 2 (tracer, auto)
- **Files modified:** 1

## Accomplishments

- Task 1 (`bc03528`): golden capture first (six scenarios: fresh with fake codex, fresh without codex, 0-byte config.toml, existing table, foreign form, CRLF table, plus the gate list), then section 1 became `sync_server`, called through `use_docs`; the managed append and the `codex mcp add` branch read `srv`, `srv_url`, `srv_begin`, `srv_end`, `srv_codex_add`.
- Task 2 (`3439433`): `analyze` and the rewrite awk build `main_re`, `tool_re`, `tool_pre` in `BEGIN` from `-v srv`; mention tests became `index(line, srv) > 0`; the legacy-key comparison is guarded by `old_key != ""`; `tools_in_state`, `print_tools`, `print_block` and every message read `srv`, `srv_tools`, `srv_old_key`, `srv_label`, `srv_untouched`, `srv_approved_note`.
- Both CR strips (`sub(/\r$/, "", line)`) survive; the crlf-table scenario is byte-identical.

## Verification

- `sh tests/test_install_codex.sh`: same 55 gates, same statuses (all ok) as before the edit, after each task.
- Golden diff before/after1 and before/after2: stdout+stderr+exit, config.toml and backup byte-identical for all six scenarios (a repeat of the "before" run was also identical, so the harness is deterministic).
- `sh tests/test_static_guards.sh`: no FAIL for install-codex.sh.
- Region grep: `analyze()` holds 0 occurrences of the server name; `-v srv=` on 2 lines; 2 CR strips; 1 `DOCS_TOOLS=` line.
- `sh tests/run.sh`: `SUMMARY: ok=366 fail=0 skip=2`.
- Golden directory removed after the comparison.
- ShellCheck is not installed here; `gate ci_shellcheck` on the pushed branch is the remaining check (plan's human-check). `sh -n` passes.

## Task Commits

1. Task 1: golden capture, section 1 into `sync_server` via `use_docs` - `bc03528` (refactor)
2. Task 2: awk programs, printers and messages read the globals - `3439433` (refactor)

## Deviations from Plan

None - plan executed exactly as written, with two judgement calls inside the plan's discretion:

- `-v begin` is not passed to `analyze` (unused until 01-04 adds `managed=`); no analysis field was added.
- One message stays literal: "Check that it approves these five tools by name, or add the tables by hand:" (tools-foreign branch). The plan's `srv_label` ("the five docs tools") would have changed its bytes, so it was kept byte-identical. Plan 01-04 needs a word of its own for bbj-local here (three tools, not five).

**Total deviations:** 0 auto-fixed. **Impact:** none.

## Handoff to plan 01-04

- Add `use_local` setting all ten globals; call it then `sync_server`. `srv_old_key=""` disables the legacy-key path; `srv_codex_add=0` forces the managed block.
- Rebuild the golden harness from Task 1 step 1 (the spec in the plan is exact); `golden.sh` here read `G`, `REPO` and a SUFFIX argument.
- The literal "these five tools" line in the tools-foreign branch and the literal hosted-tool names in the legacy-key and `default_tools_approval_mode` messages still name docs-server specifics.
- `state()`, `an()` and friends read globals, so a second `sync_server` call must run `refresh` first (it does, at its top).

## Known Stubs

None.

## Threat Flags

None. T-01-08 (existing configs) and T-01-27 (awk program text) are mitigated as planned: golden diff after each task, server name only via `-v`.

## Self-Check: PASSED

- `codex/install-codex.sh` exists; `sync_server` (4 occurrences), `use_docs()` (1) present.
- Commits `bc03528` and `3439433` exist; both subjects start with `refactor(01-03)`.
