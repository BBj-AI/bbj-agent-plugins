---
phase: 01-repo-owned-skills-and-local-first-check-route
plan: 05
subsystem: testing
tags: [check-order, skills, codex-snippet, pin-test, python-stdlib]

requires:
  - phase: 01-repo-owned-skills-and-local-first-check-route
    provides: "01-01 removed the skills hash test, so SKILL.md files can change"
provides:
  - "One check-order block (bbjcpl, then bbj-local, then hosted check with disclosure) byte-identical in codex/AGENTS-snippet.md and both SKILL.md files"
  - "tests/test_check_order.py with ten checkorder_* gates, each shown to fail on a mutated copy"
affects: [01-06 installer test run with the snippet in place, 01-07 final-wave snippet gates, phase 3 gate, phase 4 skill rewrite]

actuals:
  tokens: 2700
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Marker-delimited shared text extracted and compared as exact decoded bytes (no strip, no newline translation)"
    - "Forbidden strings assembled from pieces so the test never spells them"

key-files:
  created:
    - tests/test_check_order.py
  modified:
    - codex/AGENTS-snippet.md
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - plugins/bbj/skills/bbj-web-programming/SKILL.md

key-decisions:
  - "The Built in line is matched by prefix, not as a whole line, because the snippet line continues past the pinned sentence"
  - "client_neutral is checked on all three copies, not only the snippet copy, so a client name added to the skills alone is also caught"

patterns-established:
  - "Check-order block: one pinned text, three copies, drift fails the suite"

requirements-completed: [LOCAL-05]

coverage:
  - id: D1
    description: "Check-order block present and byte-identical in the snippet and both skills; drift fails"
    requirement: LOCAL-05
    verification:
      - kind: unit
        ref: "tests/test_check_order.py#checkorder_markers_* and checkorder_identical (space mutation fails identical)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Route order bbjcpl, bbj-local, hosted last with the disclosure sentence; client-neutral; first after frontmatter; snippet Check paragraph replaced"
    requirement: LOCAL-05
    verification:
      - kind: unit
        ref: "tests/test_check_order.py#checkorder_route_order, client_neutral, skill_placement_*, snippet_check_paragraph_replaced, no_tool_bullets (mutations fail)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Codex's skill loader tolerates the HTML comment block before the H1 (research assumption A2)"
    verification: []
    human_judgment: true
    rationale: "Only Claude Code strict validation was run; no Codex CLI is available here, the plan assigns this to the end-of-phase human check"

duration: 6min
completed: 2026-10-09
status: complete
---

# Phase 1 Plan 05: Check-order block Summary

**One marker-delimited check-order block (bbjcpl, then local bbj-ls, then the hosted check only with a disclosure to the user) placed byte-identically in the Codex snippet and both skills, pinned by a ten-gate Python test**

## Performance

- **Duration:** about 6 min
- **Completed:** 2026-10-09T17:38:09Z
- **Tasks:** 2
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments
- The canonical block from the plan sits in `codex/AGENTS-snippet.md` in place of the old `Check:` paragraph; the Codex-only sentence about shell-written files stays outside the block (D-07).
- Both `SKILL.md` files carry the block directly after the frontmatter, before the H1 (D-06); the diff of the skills is additions only and the bbjcpl section of `bbj-programming` is untouched (D-08).
- `tests/test_check_order.py` gates: `checkorder_markers_snippet`, `_bbj_programming`, `_bbj_web_programming`, `identical`, `route_order`, `client_neutral`, `skill_placement_bbj_programming`, `skill_placement_bbj_web_programming`, `snippet_check_paragraph_replaced`, `no_tool_bullets`. Mutation checks confirmed: one added space in one copy fails `identical`; a client name added to all three fails `client_neutral` with `identical` still ok; text before the block fails `skill_placement`; swapped route order, a returned old `Check:` line, a removed shell sentence and an added tool bullet each fail their gate.
- Tracer gate: the tracer verify re-ran end to end after the first commit, then expansion followed.

## Task Commits

1. **Task 1: block in all three files and the byte-identity pin (tracer)** - `18d60a1` (feat)
2. **Task 2: content, placement and client-neutral pins with mutation proof** - `2d2bdc5` (test)

**Plan metadata:** committed with this SUMMARY (docs: complete plan)

## Files Created/Modified
- `tests/test_check_order.py` - pin test, ten `checkorder_*` gates, optional argv[1] root for mutation checks
- `codex/AGENTS-snippet.md` - block replaces the `Check:` paragraph; Codex-only sentence follows it
- `plugins/bbj/skills/bbj-programming/SKILL.md` - block after the frontmatter
- `plugins/bbj/skills/bbj-web-programming/SKILL.md` - block after the frontmatter

## Decisions Made
- Matched the `Built in: no USE needed.` line by prefix: the snippet line continues after that sentence, so an exact-line test failed on the first run (see Deviations).
- Ran the client-neutral check over all three copies rather than the snippet copy alone; identical already forces equality, and this also reports the offending file by name.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Built-in line compared as an exact line**
- **Found during:** Task 2 (first run of `checkorder_snippet_check_paragraph_replaced`)
- **Issue:** The gate compared `"Built in: no USE needed."` to whole lines, but the snippet line continues with the USE sentence, so the gate failed on correct content.
- **Fix:** Match with `startswith` on the lines outside the block.
- **Files modified:** `tests/test_check_order.py`
- **Verification:** all ten gates ok; the removed-shell-sentence and returned-old-line mutations still fail the gate.
- **Committed in:** `2d2bdc5` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug in my own new test)
**Impact on plan:** None on scope; the plan's acceptance wording ("line Built in: no USE needed. is still present") is met.

## Issues Encountered
None. Plan-level run: `sh tests/run.sh` ends `SUMMARY: ok=390 fail=0 skip=2`; `claude plugin validate --strict plugins/bbj` passed; `snippet_shape`, `first_prints_snippet_and_trust` and `tools_list_single_source` print ok in this tree. Plans 01-06 and 01-07 re-run them after the merge as planned.

## Known Stubs
None.

## Threat Flags
None. The block adds no new endpoint or trust boundary; T-01-13 to T-01-15 are mitigated by `route_order`, `client_neutral` and `identical`.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Plan 01-06 can run the whole `tests/test_install_codex.sh` with the snippet in place.
- Human check at end of phase (A2): start Codex with the skills installed by `install-codex.sh` and confirm both BBj skills still list with the comment block before the H1.

## Self-Check: PASSED

- FOUND: tests/test_check_order.py, codex/AGENTS-snippet.md, both SKILL.md files
- FOUND commits: 18d60a1, 2d2bdc5
- Acceptance greps re-run: begin marker count 1 per file, old `Check: after each` count 0, `Built in` present, `parse stdout` count 1, skills diff has 0 removed lines, forbidden literals in the test count 0.

---
*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Completed: 2026-10-09*
