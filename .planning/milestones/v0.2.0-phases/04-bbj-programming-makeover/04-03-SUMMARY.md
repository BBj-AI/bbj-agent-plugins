---
phase: 04-bbj-programming-makeover
plan: 03
subsystem: skills
tags: [bbj-programming, skill-rewrite, bbjcpl, example-gate, ratchet, codex-snippet]

requires:
  - phase: 04-bbj-programming-makeover
    provides: "plan 04-01 probes and plan 04-02 claim ledger (150 rows; the verdicts that decide what ships)"
provides:
  - "plugins/bbj/skills/bbj-programming/SKILL.md rewritten: triggers-first description (716 characters), unchanged check-order block, bbjcpl output section, six primer-gap rules with four should-fail/bbj pairs and the OWNER sign-trap block, pointers, reference index; body 148 lines, no table row"
  - "codex/AGENTS-snippet.md line 21 and SKILL.md carry the byte-identical scoped Built in line"
  - "tests/skills_baseline.json lowered by --report (bbj-programming 15 / 20 / 10 / 0 / 5 for bbj-ls / bbjcpl / grammar / should-fail / structure); 04-BASELINE.md"
affects: [04-04, 04-05, 04-06, 05-bbj-web-programming-makeover]

actuals:
  tokens: 14200
  tasks: 3
  commits: 3

tech-stack:
  added: []
  patterns:
    - "scratch-root dry run of a skill draft (probes/README.md recipe), then copy into the repository"
    - "each should-fail block directly followed by its correct bbj block, built from a committed probe"

key-files:
  created:
    - .planning/phases/04-bbj-programming-makeover/04-BASELINE.md
  modified:
    - plugins/bbj/skills/bbj-programming/SKILL.md
    - codex/AGENTS-snippet.md
    - tests/skills_baseline.json

key-decisions:
  - "The Built in line keeps the pinned prefix 'Built in: no USE needed.' and appends the scope; it is one line, identical in SKILL.md and the snippet (grep -xF)"
  - "The str() sign trap ships unhedged as the OWNER row L031 (D-22) with one passing bbj block (t21_str_sign) and no should-fail block"
  - "The !ERROR=26 rule is stated as the four compile messages, with the _error_26.htm URL for the runtime wording (ledger L008)"
  - "SKILL.md body stops at 148 lines so plan 04-05's running.md pointer fits within 150"

requirements-completed: [PROG-02, PROG-03, PROG-04, PROG-06]

duration: 30min
completed: 2026-10-11
status: complete
plan_head_before: ae52cabe079d9c0f39218d68be146999df4d8187
plan_head_after: a7015b37559343901ffc9ec9b2d73755fb6e603a
commits: 3

coverage:
  - id: D1
    description: "SKILL.md in D-11 order (check block, bbjcpl output on 26.03, primer-gap rules, pointers, index); every bbj block passes and every should-fail block fails its route on the live gate; no violation names bbj-programming SKILL.md"
    requirement: "PROG-02, PROG-03, PROG-06"
    verification:
      - kind: other
        ref: "BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py (exit 0, no gate line for bbj-programming SKILL.md, five skills_ratchet_bbj-programming_* gates ok); python3 -I tests/test_check_order.py (checkorder_identical ok, skill_placement ok)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Scoped Built in line identical in SKILL.md and codex/AGENTS-snippet.md; Codex installer gates unchanged"
    requirement: "PROG-03, PROG-04"
    verification:
      - kind: other
        ref: "grep -xF of the snippet line in SKILL.md; sh tests/test_install_codex.sh: first_prints_snippet_and_trust ok, snippet_shape ok, real_home_untouched ok"
        status: pass
    human_judgment: false
  - id: D3
    description: "Ratchet lowered by --report and reproduced byte for byte; web counts unchanged; nocheck 0; full suite and CI view green"
    requirement: "PROG-04, PROG-06"
    verification:
      - kind: other
        ref: "fresh --report cmp tests/skills_baseline.json = identical; BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh: SUMMARY ok=703 fail=0 skip=105; CI view: SUMMARY ok=657 fail=0 skip=36"
        status: pass
    human_judgment: false
  - id: D4
    description: "Whether the bbjcpl and rule wording reads well to an agent (taste of the prose)"
    requirement: "PROG-02"
    human_judgment: true
    rationale: "Wording quality is not asserted by any test"
---

# Phase 4 Plan 03: SKILL.md rewrite Summary

**bbj-programming SKILL.md rewritten from the claim ledger: the unchanged check order first, then how to read bbjcpl output on BBj 26.03, then six rules the primer lacks (trailing rem, bare calls, USE scope, undeclared values into typed destinations, the str() sign trap) with four gate-checked should-fail/bbj pairs, the docs-tool pointers and the reference index, in 148 lines with the Codex snippet's Built in line aligned and the ratchet lowered.**

## Accomplishments

- New description: 716 characters, one double-quoted JSON-valid line; the first 200 characters name BBj and `.bbj`; it names bbjcpl output and `bbj-web-programming`; symptoms only for topics the ledger keeps (a trailing rem, `No type named HashMap visible in this scope`, `Incompatible assignment from <undeclared>`, `Cannot find program` for a `USE ::file::` line, bbjcpl exiting 0 with errors). The dropped launcher errors and the output file size are gone.
- Body of 148 lines (after the closing frontmatter `---`), no line starts with `|`. Headings in D-11 order: H1, `## Reading bbjcpl output (BBj 26.03)`, `## Rules the primer does not state`, `## Look it up instead`, `## References`. The check-order block (lines 6-14 of the base file) was not retyped; `checkorder_identical` stays ok.
- Four `bbj should-fail` blocks (trailing rem, bare call, missing USE, undeclared methodret), each directly before its `bbj` block, plus the sign-trap `bbj` block (t21_str_sign) with no should-fail block. Every block is a minimal complete program, ASCII, no `bbj nocheck`.
- `codex/AGENTS-snippet.md` line 21 replaced by the scoped Built in line, byte-identical to SKILL.md.
- `tests/skills_baseline.json` and `04-BASELINE.md` written by `--report`; a fresh `--report` is byte-identical to the committed file.

## Rule-to-ledger map (PROG-04: no rule without a ledger row)

| SKILL.md content | Ledger ids (verdict naming SKILL.md) |
| --- | --- |
| Description (triggers first, kept topics only) | L001 (the description row, rewritten per D-20; the dropped symptoms stay out) |
| bbjcpl: messages on stderr, stdout empty, clean file prints nothing | L061 (rewrite), L148 |
| bbjcpl: exit status 0 with or without errors | L060 |
| bbjcpl: the two record shapes, parenthesized number is the file line, unnumbered file numbered by 10 | L148, L062 (rewrite) |
| bbjcpl: `-W` warnings are not failures | L058 |
| bbjcpl: always `-N -X`, `-t -N -X` is the documented check | L055 |
| bbjcpl: unresolved `USE ::file::`, `-P` or `-c`, not both | L149, L059 (rewrite) |
| bbjcpl: neither route validates an event constant | L064 |
| Trailing `rem` needs `;`, pair of blocks (t03 / t04) | L003 |
| Label takes `rem` with no `;` | L146 |
| Bare calls: function-style call is not a statement, object method call is; pair (b08 / t07 plus t08) | L143, L144 |
| Built in line and USE scope, pair (u03 / u05); only bbjcpl catches the missing USE | L145, L101 (fold) |
| Undeclared values into typed destinations: four messages, `!ERROR=26` with the `_error_26.htm` URL, `declare auto`, `str()` / `num()`; pair (e26e / e26f) | L008 (rewrite), L010, L011, L012, L014, L018 (rewrite), L015, L016, L112 (fold) |
| str() sign trap, sign characters, `numeric_output.htm`, one passing block (t21) | L031 (OWNER, D-22) |
| `## Look it up instead` (primer, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`, `bbj_search`, `bbj_fetch_page`) | D-11 part 3 pointers; no rule of its own |
| `## References` index lines | pointers to the files that hold L084-L086 (callback-performance), L088-L094 (database), L116-L150 (sysgui) |

Ledger rows with verdict drop for SKILL.md are absent (the cut-list grep of Task 3 finds no match): the launcher errors, the READY prompt, the large binary, the multiplied-by-ten claim, the precision advice, taste.

## Task Commits

1. Task 1 (tracer): rewritten SKILL.md through the live gate - `0ee4660`
2. Task 2: four more primer-gap rules and the scoped Built in line - `a30a4ea`
3. Task 3: ratchet lowered by `--report`, suites green - `a7015b3`

## Verification results

- `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`: exit 0, no gate line for bbj-programming SKILL.md; ratchet: grammar 10 < 11, structure 5 < 17, bbjcpl 20 < 44, bbj-ls 15 < 36, should-fail 0. The remaining counts are all in the references (plan 04-04) and in bbj-web-programming (unchanged: 15 / 25 / 5 / 0 / 8, nocheck 0).
- `python3 -I tests/test_check_order.py`: all gates ok.
- `sh tests/test_install_codex.sh`: `first_prints_snippet_and_trust ok`, `snippet_shape ok`, no FAIL.
- tests/run.sh SUMMARY lines:
  - `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh`: `SUMMARY: ok=703 fail=0 skip=105`
  - `BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true sh tests/run.sh`: `SUMMARY: ok=657 fail=0 skip=36`
- Description length 716 (limit 1,024). Body 148 lines (limit 148 for this plan, 150 overall).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Verify regex matched a fixture gate**
- **Found during:** Task 2 verify (also applies to the Task 1 verify)
- **Issue:** the plan's check `! grep -q '^gate .* FAIL'` matches `gate skills_fx_structure_linked_skill_dir ok status=ok: ... 'gate skills_structure_linked FAIL' ...`, an `ok` fixture gate whose detail text contains the word FAIL, so the verify fails on a clean run.
- **Fix:** the same check was run with `'^gate [^ ]* FAIL'` (status field only). Nothing in the repository changed.
- **Files modified:** none

**2. [Environment, not a code issue] One transient `real_home_untouched` FAIL**
- **Found during:** Task 3, first live full run (`ok=702 fail=1`)
- **Issue:** the live Codex daemon of this machine wrote `/home/coder/.codex/logs_2.sqlite-wal` while `test_install_codex.sh` took its before/after snapshot of the real home.
- **Fix:** none needed; `sh tests/test_install_codex.sh` alone passes, and the full live run repeated passes (`ok=703 fail=0`). The CI view passed first time.

**Total deviations:** 1 auto-fixed (Rule 3, check regex only), 1 environmental flake. **Impact:** none on the shipped files.

## Notes for later plans

- L112 (a local `BBjChildWindow` must be declared when a control created from it is assigned to a typed variable) is stated in SKILL.md in its general form (declare the receiver, `declare auto <Type> x!`) without a BBjChildWindow-specific example; plan 04-04's sysgui.md can carry the concrete case (probes e26g / e26h).
- Plan 04-05 adds the `references/running.md` pointer to the index; the body is at 148 lines, so the pointer fits within 150.
- The two dropped references (`java-interop.md`, `reserved-words.md`) are not listed in the index; plan 04-06 deletes them.

## Known Stubs

None.

## Threat Flags

None. No network endpoint, auth path or file access was added; the only shipped changes are Markdown.

## Issues Encountered

None beyond the two deviations above.

## Self-Check: PASSED

- SKILL.md, codex/AGENTS-snippet.md, tests/skills_baseline.json and 04-BASELINE.md exist; commits `0ee4660`, `a30a4ea` and `a7015b3` are on the branch (`commits:` measured from the ledger: 3).
