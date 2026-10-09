---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 04
subsystem: infra
tags: [codex-installer, posix-sh, awk, toml, managed-block, bbj-local]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: "01-03: sync_server, use_docs and the srv_* globals in codex/install-codex.sh"
provides:
  - "--with-local: one managed bbj-local block (markers, [mcp_servers.bbj-local], the fixed url, three approved tool tables) written through the bbj-docs pass"
  - "use_local, LOCAL_* constants, srv_fixed_url, analyze fields managed= and url=, the fixed-url rule in state()"
  - "section 1b of the installer: runs with the flag or when a managed bbj-local block exists (refresh in place, D-09)"
  - "fourteen local_* gates in tests/test_install_codex.sh"
affects: [01-06, 01-07]

status: complete

actuals:
  tokens: 6273
  tasks: 3
  commits: 4

tech-stack:
  added: []
  patterns:
    - "a server pass is its parameter globals plus one sync_server call; bbj-local differs from bbj-docs only in use_local (srv_fixed_url=1, srv_old_key empty, srv_codex_add=0)"
    - "a server with a fixed url is edited only at exactly that url (D-12); any other url is the foreign branch, exit 3"
    - "local-run configs go to WORK/local.list, never to written.list, because check_tools_never_named forbids the check-tool names there"
    - "golden before/after capture, rebuilt from the 01-03 spec, compared byte for byte after each task and removed at the end"

key-files:
  created: []
  modified:
    - codex/install-codex.sh
    - tests/test_install_codex.sh

key-decisions:
  - "The url rule lives in state(): srv_fixed_url=1 with main=1 and an analysed url other than srv_url sets foreign=1, so the existing foreign branch handles it and no commit ever approves a check tool on another url"
  - "analyze gets -v begin and reports managed= (exact begin-marker line, CR stripped) and url= (last url key of the main table); a lone end marker is a comment and counts as no block"
  - "Section 1b calls use_local then refresh on every run and sync_server only when with_local=1 or managed=1; without either it writes and prints nothing, which is where plan 01-06 puts the probe"
  - "bbj-local reports any default_tools_approval_mode value as left as is and never sets pending (srv_old_key empty); nothing server-wide is ever written for it"
  - "Messages for bbj-local: the tools-foreign line says the three bbj-ls tools, and a foreign bbj-local at another url gets one extra line naming its url and the fixed one"

patterns-established:
  - "Pattern: bbj-local forms matrix (flag x managed block x hand-registered) lives in section 1b plus state(); gates cover every row"

requirements-completed: [LOCAL-01, LOCAL-02, LOCAL-07]

coverage:
  - id: D1
    description: "--with-local writes exactly one managed bbj-local block at http://127.0.0.1:5009/mcp with the three tools approved, with or without codex on PATH, and never follows BBJ_LOCAL_MCP_URL"
    requirement: "LOCAL-02"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#local_block_fresh_no_codex, local_block_fresh_with_codex_on_path, local_url_fixed_ignores_seam, local_no_flag_writes_nothing"
        status: pass
    human_judgment: false
  - id: D2
    description: "Reruns are byte-identical, a managed block is refreshed in place without the flag, a lone end marker is tolerated, a user prompt value is kept"
    requirement: "LOCAL-02"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#local_rerun_idempotent, local_kept_without_flag, local_rerun_without_flag_refreshes_in_place, local_lone_end_marker, local_lone_end_marker_without_flag, local_user_value_kept"
        status: pass
    human_judgment: false
  - id: D3
    description: "A hand-registered table at the fixed url gains the approvals; every other bbj-local form is left byte-identical with exit 3; check tools are never approved under another server"
    requirement: "LOCAL-02"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#local_hand_registered_same_url, local_foreign_forms, local_check_tools_only_in_local_tables"
        status: pass
    human_judgment: false
  - id: D4
    description: "Both servers in one config.toml, in both orders, with the begin marker directly above [mcp_servers.bbj-local]; runs without the flag match the pre-plan output byte for byte"
    requirement: "LOCAL-01"
    verification:
      - kind: integration
        ref: "tests/test_install_codex.sh#local_and_docs_coexist_both_orders"
        status: pass
      - kind: other
        ref: "golden harness, six scenarios, before vs noflag, noflag2, noflag3: cmp exit 0 (throwaway, removed)"
        status: pass
    human_judgment: false
  - id: D5
    description: "ShellCheck of the new installer code (gate ci_shellcheck) on the pushed branch"
    verification: []
    human_judgment: true
    rationale: "ShellCheck is not installed on this machine; only sh -n and the static guards ran locally"

duration: 9 min
completed: 2026-10-09
---

# Phase 1 Plan 04: Installer --with-local Summary

**`--with-local` registers the local bbj-ls as one managed bbj-local block (fixed url http://127.0.0.1:5009/mcp, three tools approved by name) through the same `sync_server` pass as bbj-docs, with reruns, a lone end marker, a fixed-url rule and every foreign form covered by fourteen new gates.**

## Performance

- **Duration:** about 9 min
- **Started:** 2026-10-09T17:26Z (approximate)
- **Completed:** 2026-10-09T17:35Z
- **Tasks:** 3 (tracer, auto tdd, auto tdd)
- **Files modified:** 2

## Accomplishments

- Task 1 (`ee447e0`, tracer): golden baseline first, then four failing gates, then `LOCAL_URL`/`LOCAL_MARK_BEGIN`/`LOCAL_MARK_END`/`LOCAL_TOOLS`, `use_local`, `srv_fixed_url`, `--with-local` in the option parser, usage and header, `managed=` and `url=` in `analyze`, the D-12 url rule in `state()` and section 1b. Verified with the real codex 0.156.1: `codex mcp get bbj-local` loads every local-run config.
- Task 2 (`0faaf3b` red, `31eb353` green): five gates; the in-place refresh gate failed first (an older managed block was not refreshed without the flag), then section 1b was changed to run the pass when `managed=1`.
- Task 3 (`bcf698a`): five gates for a hand-registered table at the fixed url, four foreign forms (other url, single-quoted key, dotted key, sub-table without the table), both block orders (docs first, local first), a user `prompt` value and an aggregate that the check tools appear only under bbj-local. No installer defect surfaced, as the plan predicted. A mutation check (the url rule disabled) made `local_foreign_forms` fail, then the file was restored.
- Runs without `--with-local` are byte-identical to the pre-plan installer on six golden scenarios, after each task (stdout, exit, config.toml, backup).

## Task Commits

1. **Task 1: --with-local writes the managed bbj-local block (LOCAL-02, D-12 url rule, D-17)** - `ee447e0` (feat)
2. **Task 2 RED: failing gate for the in-place refresh** - `0faaf3b` (test)
3. **Task 2 GREEN: refresh a managed block on every run** - `31eb353` (feat)
4. **Task 3: every bbj-local form, both orders, user values** - `bcf698a` (test)

**Plan metadata:** the docs commit that carries this file (docs(01-04)).

## Files Created/Modified

- `codex/install-codex.sh` - `use_local`, `LOCAL_*` constants, `--with-local`, `managed=`/`url=` analysis fields, fixed-url rule, section 1b, header and usage text.
- `tests/test_install_codex.sh` - fourteen `local_*` gates, helpers `LMB`, `LME`, `lsum`, `three_expected`, `docs_done`, `note_local`, `local_parse`, `local_shape`, and a `SERVER` argument for `real_parse`.

## Decisions Made

See `key-decisions`. In short: the url rule is one condition in `state()` feeding the existing foreign branch; the managed-block decision reads `managed=` from the analysis; nothing server-wide is ever written for bbj-local.

## Deviations from Plan

None - plan executed exactly as written, with these judgement calls inside the plan's discretion:

- The foreign branch prints one extra line when bbj-local is at another url ("its url is X, not Y; its tools are approved by name only at Y"); the plan's required strings are unchanged.
- `local_no_flag_writes_nothing` checks config.toml only, not stdout, so plan 01-06's probe lines (which may name bbj-local in the no-flag branch) cannot break it.
- The real codex refuses a whole config that holds `[mcp_servers.bbj-local.env]` without a transport, so that one foreign-form config is not passed to `real_parse`; it still passes the tomllib parse.

**Total deviations:** 0 auto-fixed. **Impact:** none.

## Issues Encountered

- A first draft of the Task 1 test block carried a stray sed pipe in `docs_done` and a stdout check in the no-flag gate; both were removed before the first commit.
- ShellCheck is not installed here (`gate ci_shellcheck` runs on the pushed branch). `sh -n` and `tests/test_static_guards.sh` pass.

## Verification

- `sh tests/test_install_codex.sh`: all gates ok, including the fourteen `local_*` gates; `real_codex_parses_configs` ok with 39 configs (the bbj-local configs included); `check_tools_never_named` and `tools_list_single_source` ok.
- `sh tests/test_static_guards.sh`: no FAIL.
- `sh tests/run.sh`: `SUMMARY: ok=380 fail=0 skip=2`.
- Golden before vs noflag, noflag2, noflag3: byte-identical; golden directory removed.
- Acceptance greps: `LOCAL_TOOLS`, `LOCAL_URL`, `--with-local) with_local=1; shift ;;`, docs `MARK_BEGIN` each 1; `srv_fixed_url` 6 occurrences; `--help` lists `--with-local`.

## User Setup Required

None - no external service configuration required.

## Known Stubs

None.

## Threat Flags

None. T-01-07 (check tools approved only at the fixed url), T-01-09, T-01-10, T-01-11 are mitigated as planned and gated; T-01-12 (concurrent runs) is accepted.

## Next Phase Readiness

Ready for 01-06 (probe goes into the no-flag branch of section 1b and before the flagged `sync_server`) and 01-07 (docs). The installer prints "bbj-local: appended a managed block ..." and "bbj-local: approved by name ..." lines that the docs plan may quote.

## Self-Check: PASSED

- `codex/install-codex.sh` and `tests/test_install_codex.sh` exist; `use_local()` present in the installer.
- Commits `ee447e0`, `0faaf3b`, `31eb353`, `bcf698a` exist; subjects carry the `(01-04)` scope.
