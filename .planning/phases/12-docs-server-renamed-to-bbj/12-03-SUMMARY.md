---
phase: 12-docs-server-renamed-to-bbj
plan: 03
subsystem: agent-facing-text
tags: [skills, check-order, hook-notice, docs-server, rename]

requires:
  - phase: 12-docs-server-renamed-to-bbj
    provides: plan 12-02, the Linux sign-in record with the fourteen-key Labels block (D-09 step 2)
provides:
  - "Both SKILL.md check-order blocks: step 3 names the docs server `bbj`, byte-identical"
  - "tests/test_check_order.py: DOCS_SERVER_NEEDLE; route_order pins bbjcpl, bbj-local, docs server `bbj` in that order"
  - "plugins/bbj/scripts/bbj-check.sh: no-route notice names the docs server bbj, the hosted check"
  - "tests/test_noroute_notice.sh: notice_text_claude and notice_codex_text pin the new fragment"
affects: [12-04, 12-05]

actuals:
  tokens: 2100
  tasks: 2
  commits: 2
plan_head_before: 940c0daa2ebd8278519678f341b534d900091373
plan_head_after: bee75386c6fc6071bea4a4876c6529f559bba8ad

tech-stack:
  added: []
  patterns:
    - "A server is named in prose by role noun and name (the docs server `bbj`); a bare bbj would match inside bbjcpl and bbj-local, so the gate needle carries the role noun"
    - "No client-built tool prefix in skills or the hook (D-06); checkorder_client_neutral keeps that"

key-files:
  created: []
  modified:
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - plugins/bbj/skills/bbj-web-programming/SKILL.md
    - tests/test_check_order.py
    - plugins/bbj/scripts/bbj-check.sh
    - tests/test_noroute_notice.sh

key-decisions:
  - "Needle for route_order is the whole phrase docs server `bbj`, not bbj: a bare bbj is found inside bbjcpl at position 0 and would make the order check meaningless (D-05)"
  - "The notice fragment pinned in both gates is the longer `bbj_check_syntax of the docs server bbj, the hosted check`, because the old text already held the substring `docs server bbj` through the hyphenated old name (D-07)"

requirements-completed: [NAME-02]

coverage:
  - id: D1
    description: "Check-order step 3 names the docs server `bbj` in both SKILL.md files; the two blocks stay byte-identical; no client-built tool name"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "tests/test_check_order.py -> checkorder_identical, checkorder_route_order, checkorder_client_neutral ok"
        status: pass
    human_judgment: false
  - id: D2
    description: "The docs-server needle is load-bearing: a copy of the two SKILL.md files without the phrase makes checkorder_route_order print FAIL"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "12-03-PLAN.md Task 1 verify block (temp copy, argv[1] root) -> exit 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "The no-route notice names the docs server bbj on the Claude Code and the Codex route; the disclosure (sends the code, stock BBj) stays"
    requirement: NAME-02
    verification:
      - kind: integration
        ref: "tests/test_noroute_notice.sh -> notice_text_claude, notice_codex_text ok all fragments present"
        status: pass
    human_judgment: false
  - id: D4
    description: "Exit contract and safety suites unchanged by the notice string change"
    verification:
      - kind: integration
        ref: "test_exit_contract, test_static_guards, test_codex_patch, test_never_execute, test_path_scrub exit 0 with no FAIL; shellcheck -s sh clean"
        status: pass
    human_judgment: false
  - id: D5
    description: "Full suite green"
    verification:
      - kind: other
        ref: "sh tests/run.sh -> SUMMARY: ok=751 fail=0 skip=0"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-10-15
status: complete
---

# Phase 12 Plan 03: Skills and hook notice name the docs server bbj Summary

**Step 3 of the check-order block (both SKILL.md files) and the hook's no-route notice now name the hosted check as `bbj_check_syntax` of the docs server `bbj`, with the disclosure unchanged and no client-built tool name; `checkorder_route_order` fails when the phrase is removed.**

## Performance

- **Duration:** about 6 min
- **Completed:** 2026-10-15
- **Tasks:** 2 (Task 1 was the tracer)
- **Files modified:** 5

## Accomplishments

- Tracer (Task 1, `a134daa`): line 11 of both SKILL.md files reads "3. Only when neither exists: `bbj_check_syntax` of the docs server `bbj`, the hosted check. You may use it without asking, ..." and the two blocks are still byte-identical. `tests/test_check_order.py` gained `DOCS_SERVER_NEEDLE = "docs server `bbj`"`; `route_order` now finds `bbjcpl`, then `bbj-local`, then the docs-server phrase. A temp copy of the two SKILL.md files with the phrase removed makes `checkorder_route_order` print FAIL (an absent needle is caught, which is the second half of the NAME-02 empty edge). `tests/test_skill_examples.py` stays green.
- Expansion (Task 2, `bee7538`): the notice sentence in `plugins/bbj/scripts/bbj-check.sh` reads "Otherwise bbj_check_syntax of the docs server bbj, the hosted check, can check the code; it sends the code to that server and checks it against a stock BBj, so the user must be told." One string literal plus a comment changed. `notice_text_claude` and `notice_codex_text` in `tests/test_noroute_notice.sh` pin the fragment, so both routes are covered.
- Safety: `test_exit_contract`, `test_static_guards`, `test_codex_patch`, `test_never_execute`, `test_path_scrub` exit 0 with no FAIL; `shellcheck -s sh` is clean on the two shell files; `sh tests/run.sh` prints `SUMMARY: ok=751 fail=0 skip=0`.

## Task Commits

1. **Task 1: check-order step 3 names the docs server bbj in both skills (tracer)** - `a134daa` (feat)
2. **Task 2: the no-route notice names the docs server bbj; notice gates pin it** - `bee7538` (feat)

## Decisions Made

- **Needle is the whole phrase (D-05).** `block.find("bbj")` would hit inside `bbjcpl` at position 0, so the order check would prove nothing. `docs server `bbj`` is unique in the block.
- **Longer notice fragment (D-07).** The old notice already contained `docs server bbj` inside the hyphenated old name, so a shorter pin would have passed before the change. The pinned fragment is `bbj_check_syntax of the docs server bbj, the hosted check`.
- **No tool prefix (D-06).** The Claude Code label `mcp__plugin_bbj_bbj__bbj_search` from the owner run is not quoted in the skills or the hook; both name the server only. `checkorder_client_neutral` stays ok and the hook holds no `mcp__` on an executable line.

## Deviations from Plan

None - plan executed exactly as written.

## Authentication Gates

None.

## Issues Encountered

None. The tool shell wraps `grep` with ugrep; the plan's verify blocks were run through `sh <file>` as the dispatch notes advised, and they passed. In the full-suite output the word FAIL appears on eight `ok` lines (gates that assert an expected failure); `grep -c '^gate [^ ]* FAIL '` over the output prints 0.

## Known Stubs

None.

## Threat Flags

None. The change adds no endpoint, path or trust boundary; T-12-06 (disclosure stays pinned: "sent to the server", "stock BBj", "the hosted check", "without asking" in route_order; "sends the code", "stock BBj" in the notice gates) and T-12-07 (exit contract and stdout) are mitigated by the gates listed above.

## Next Phase Readiness

Ready for 12-04 (install pages and README follow the Labels block) and 12-05 (scan for the old name over tests/ and the rest of the repository). The skills, `tests/test_check_order.py`, `plugins/bbj/scripts/bbj-check.sh` and `tests/test_noroute_notice.sh` hold no old server name.

## Self-Check: PASSED

- Files modified exist: the five paths above (FOUND).
- Commits `a134daa` and `bee7538` are ancestors of HEAD (FOUND).
- `git grep -n -i bbj-docs` over the five files prints nothing.
