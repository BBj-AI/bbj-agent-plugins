---
phase: 12-docs-server-renamed-to-bbj
plan: 05
subsystem: test-gates
tags: [layout-gate, rename, mutation-cases, conventions, docs-server]
status: complete

requires:
  - phase: 12-docs-server-renamed-to-bbj
    provides: plan 12-01, the docs server key bbj in both MCP files and DOCS_SERVER in tests/test_layout.py
  - phase: 12-docs-server-renamed-to-bbj
    provides: plans 12-03 and 12-04, skills, hook notice, README and install pages free of the old name
provides:
  - "tests/test_layout.py: OLD_SERVER_NAME (assembled from pieces), gate layout_no_old_server_name, twelve layout_mutation_old_server_name_* cases"
  - ".claude/CLAUDE.md: four architecture lines naming the docs server `bbj`, GSD markers untouched"
affects: [phase-14-maintenance, phase-12-verification]

actuals:
  tokens: 2400
  tasks: 2
  commits: 2
plan_head_before: 04c072cad0a24c457d22c56879a25f8f8f26689a
plan_head_after: ca21c7a2a04398d1cab8c526932bc71cc906ffdd

tech-stack:
  added: []
  patterns:
    - "A forbidden name is assembled from pieces in the test file, and the same gate scans that file (self-scan, D-01)"
    - "A second gate reuses the (mode, rels) pair and the CHANGELOG cut of no_retired_route instead of running git again"

key-files:
  created: []
  modified:
    - tests/test_layout.py
    - .claude/CLAUDE.md

key-decisions:
  - "The gate is its own gate (layout_no_old_server_name), not a term of layout_no_retired_route (D-02)"
  - "Only the literal hyphenated name is matched, case-insensitively, in paths and text; the underscore and joined spellings are not matched (D-03)"
  - "tests/ and .claude/CLAUDE.md are scanned with no exemption; only .planning/ and CHANGELOG entries headed 0.2.1 or older are exempt (D-01)"

requirements-completed: [NAME-01]

coverage:
  - id: D1
    description: "layout_no_old_server_name scans every git-tracked file outside .planning/ (62 files, git mode) with the CHANGELOG cut at 0.2.1 and passes on the cleaned tree"
    requirement: NAME-01
    verification:
      - kind: integration
        ref: "python3 -I tests/test_layout.py -> gate layout_no_old_server_name ok 62 tracked files scanned (git mode); git grep -n -i for the old name outside .planning/ and CHANGELOG.md prints nothing"
        status: pass
    human_judgment: false
  - id: D2
    description: "Twelve mutation cases prove each scope, the case-insensitive match and each exemption on a temp copy; the checkout is never written"
    requirement: NAME-01
    verification:
      - kind: integration
        ref: "12-05-PLAN.md Task 2 verify block (sh file) -> exit 0; git status --porcelain identical before and after the run"
        status: pass
    human_judgment: false
  - id: D3
    description: ".claude/CLAUDE.md names the docs server bbj on its four architecture lines; 14 GSD markers remain"
    requirement: NAME-01
    verification:
      - kind: integration
        ref: "12-05-PLAN.md Task 1 verify block (sh file) -> exit 0; grep -c '<!-- GSD:' .claude/CLAUDE.md prints 14"
        status: pass
    human_judgment: false
  - id: D4
    description: "Released CHANGELOG entries untouched and the CI entry point green"
    requirement: NAME-01
    verification:
      - kind: integration
        ref: "git diff --quiet 0.2.1 -- CHANGELOG.md exits 0; sh tests/ci.sh -> CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0; sh tests/run.sh -> ok=767 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 8 min
completed: 2026-10-15
---

# Phase 12 Plan 05: No-old-name gate Summary

**Gate `layout_no_old_server_name` keeps the docs server's old name out of every tracked file outside `.planning/` and released CHANGELOG history, with twelve mutation cases proving each scope and exemption, and `.claude/CLAUDE.md` cleaned to name the docs server `bbj`.**

## Accomplishments

- Cleaned the four architecture lines of `.claude/CLAUDE.md` by hand (D-01, D-04 wording); the 14 GSD markers and every other line are byte-identical.
- Added `OLD_SERVER_NAME = "bbj" + "-docs"` and the gate to `tests/test_layout.py`. It reuses `retired_mode, retired_rels` and `changelog_scan_text`, checks paths and text case-insensitively, and FAILs on 0 files scanned or on the nogit mode, with details naming the cause.
- Tracer: one planted README mention proved the gate fails end to end before the expansion started.
- Expansion: eleven more cases. Fail: the config key renamed back (also fails `bbj_mcp`), a capitalised form on the Claude Code page, a client-built tool name in a skill, a line in `.claude/CLAUDE.md`, a comment in `tests/lib.sh`, a file whose path holds the name, text above the first CHANGELOG heading, a new `## 0.2.2` entry. Pass: a line under `## 0.2.1`, a note in `.planning/`, and the underscore and joined spellings (D-03).
- Every case works in its own `tempfile.mkdtemp` copy removed in a `finally`; `git status --porcelain` is the same before and after the run.

## Task Commits

1. Task 1 (tracer): `441e543` test(12-05): layout_no_old_server_name keeps the docs server's old name out; conventions cleaned
2. Task 2: `ca21c7a` test(12-05): mutation cases prove every scope and exemption of the no-old-name gate

## Verification

- `python3 -I tests/test_layout.py`: all gates ok, 62 tracked files scanned in git mode.
- `git grep -n -i` for the old name outside `.planning/` and `CHANGELOG.md`: no output.
- `git diff --quiet 0.2.1 -- CHANGELOG.md`: exit 0.
- `sh tests/ci.sh`: `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`. `sh tests/run.sh`: `SUMMARY: ok=767 fail=0 skip=0`.

## Deviations from Plan

None - plan executed exactly as written.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. The gate reads tracked files only and adds no network, auth or file-write surface; T-12-10 and T-12-11 are mitigated as planned (scan count and mode in the detail, cases per scope, CHANGELOG exemption by version heading).

## Notes for later phases

- A1: regenerating the generated sections of `.claude/CLAUDE.md` from `.planning/codebase/` (which still names the old server) would bring the name back; `layout_no_old_server_name` fails if that happens. Phase 14 (MAINT-11) refreshes the map.
- A6: Phase 14 (NAME-04) adds a gate against retired term variants in shipped Markdown; the variants control here plants into `tests/lib.sh`, so the two do not contradict.

## Self-Check: PASSED

- FOUND: tests/test_layout.py, .claude/CLAUDE.md
- FOUND: 441e543, ca21c7a (ancestors of HEAD)
