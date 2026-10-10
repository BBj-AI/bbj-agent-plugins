---
phase: 02-hook-no-route-notice
plan: 03
subsystem: docs
tags: [readme, install-pages, installer-output, no-route-notice, doc-gates]

requires:
  - phase: 02-hook-no-route-notice
    provides: plan 02-01 no-route notice (once per session, enable steps per client)
provides:
  - README, Claude Code page, Codex page and the installer Known gaps line describe the no-route notice instead of silence
  - need and forbid gates in tests/test_install_pages.sh (NOROUTE_SILENCE)
affects: [02-06 Codex delivery wording stays true, phase 6 changelog and Codex /hooks note]

actuals:
  tokens: 4000
  tasks: 2
  commits: 2

plan_head_before: 1a97e7f8fda60591d2b61932c9c8cbf4b6f3e9db
plan_head_after: 26aa567e2ce0bbc89c6b3e8119d1557a0e5a1648

tech-stack:
  added: []
  patterns:
    - "NOROUTE_SILENCE forbid ERE shared by README, both pages and the installer"

key-files:
  created: []
  modified:
    - README.md
    - docs/install-claude-code.md
    - docs/install-codex.md
    - codex/install-codex.sh
    - tests/test_install_pages.sh

key-decisions:
  - "Docs wording does not name the delivery channel, so it stays true if Codex later uses the exit-2 fallback (D-15)"
  - "Phrases the gates need ('once per session', 'not compile-checked') are kept on one source line, because need() greps line by line"

requirements-completed: [HOOK-02]

coverage:
  - id: D1
    description: "No shipped text says the hook stays silent when no check route exists; README, both install pages and the installer Known gaps say it tells the agent once per session that the file was not compile-checked, with client-specific enable steps"
    requirement: "HOOK-02"
    verification:
      - kind: integration
        ref: "tests/test_install_pages.sh#readme_has_once_per_session, readme_forbids_noroute_silence, claude_has_once_per_session, claude_has_not_compile_checked, claude_forbids_noroute_silence, codex_has_once_per_session, codex_has_not_compile_checked, codex_forbids_noroute_silence, installer_has_once_per_session, installer_forbids_noroute_silence"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-10-10
status: complete
---

# Phase 2 Plan 03: Docs and installer output for the no-route notice Summary

**README, both install pages and the Codex installer's Known gaps now say the hook tells the agent once per session that a BBj file was written but not compile-checked when no check route exists, and ten gates keep the old silence claim from returning.**

## Accomplishments

- README hook paragraph: a clean or non-BBj file is silent; with no compiler and no running `bbj-ls` the agent is told once per session, with how to enable a check.
- `docs/install-claude-code.md` step 3: `bbj_home` option or `bbj-local` plugin as the enable steps; later files of the session are not checked either. The line "A clean file is silent in every route" is unchanged and still true.
- `docs/install-codex.md` step 3: `BBJ_HOME`, `bbjcpl` on `PATH`, or `--with-local`.
- `codex/install-codex.sh` Known gaps stays one plain `say` message, no compiler file name, no command substitution.
- `tests/test_install_pages.sh`: header line, `NOROUTE_SILENCE`, need lines on README and both pages, forbid on all four, a new `installer` block.

## Task Commits

1. **Task 1: README and Claude Code page (tracer)** - `7166531` (docs)
2. **Task 2: Codex page and installer output** - `26aa567` (docs)

## Deviations from Plan

None - plan executed exactly as written.

Notes: the Task 2 gates and edits were written in one step, so no separate RED run was made for Task 2; the gates were observed to fail once on a line-wrapped phrase (`not` / `compile-checked`) and passed after reflowing. CHANGELOG is untouched (Phase 6, REL-02).

## Verification

- `sh tests/test_install_pages.sh`, `sh tests/test_install_codex.sh`, `sh tests/test_static_guards.sh` (compiler-name, curl and syntax gates of install-codex.sh ok), `python3 -I tests/test_layout.py`, `sh codex/install-codex.sh --help` all exit 0.
- `sh tests/run.sh`: `ok=488 fail=0 skip=2`.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- Files modified are present; commits `7166531` and `26aa567` are ancestors of HEAD (2 commits measured from `1a97e7f`).
