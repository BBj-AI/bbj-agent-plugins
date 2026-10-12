---
phase: 05-bbj-web-programming-makeover
plan: 10
subsystem: skill-finish
tags: [bbj, dwc, baseline, ratchet, phase-gate]
status: complete

requires:
  - phase: 05-bbj-web-programming-makeover
    provides: rewritten SKILL.md and trimmed references (plans 05-06 to 05-08), docs proposal (05-09), 05-LEDGER.md Deleted and Destinations lines
provides:
  - four folded references deleted (color-chooser, responsive-layout, shadow-dom-styling, themes)
  - tests/skills_baseline.json with an empty pending object (written by --report)
  - 05-BASELINE.md: bbj-web-programming (not pending), no violations
affects: [06-release]

actuals:
  tokens: 9300
  tasks: 2
  commits: 1
plan_head_before: 9f209189c0fbe73f00e2f266805064029c13fc67
plan_head_after: 379ce6bf095cf2379575cf8ad1154a81cb671017

tech-stack:
  added: []
  patterns:
    - "A skill leaves pending only through --report, in the same commit as its last shipped change"

key-files:
  created:
    - .planning/phases/05-bbj-web-programming-makeover/05-BASELINE.md
  modified:
    - tests/skills_baseline.json
  deleted:
    - plugins/bbj/skills/bbj-web-programming/references/color-chooser.md
    - plugins/bbj/skills/bbj-web-programming/references/responsive-layout.md
    - plugins/bbj/skills/bbj-web-programming/references/shadow-dom-styling.md
    - plugins/bbj/skills/bbj-web-programming/references/themes.md

key-decisions:
  - "Deleted exactly the files on the ledger line 'Deleted in plan 05-10: ' (line 381 of 05-LEDGER.md); it equals the plan default, so nothing differs from the plan"
  - "KNOWN_PENDING in tests/test_skill_examples.py not edited; build_report never re-adds a dropped skill"

requirements-completed: [WEB-01, WEB-02, WEB-03]

duration: about 8 minutes (2m25s of it the full suite, both views)
completed: 2026-10-12
---

# Phase 5 Plan 10: Delete the folded references and take bbj-web-programming out of pending Summary

**The four references the ledger folds are deleted and, in the same commit, `--report` regenerated the baseline: pending is `{}`, nocheck 0, so bbj-web-programming is fully enforced on bbjcpl and bbj-ls, and the full suite passes in the live and the CI view.**

## Performance

- Tasks: 2 (Task 1 tracer, Task 2 auto)
- Commits: 379ce6b (deletions, tests/skills_baseline.json, 05-BASELINE.md, one commit). Task 2 changes no shipped file and has no code commit.
- Files: 4 deleted (627 lines), 1 modified, 1 created
- Ledger line followed (T-05-32): `Deleted in plan 05-10: references/color-chooser.md, references/responsive-layout.md, references/shadow-dom-styling.md, references/themes.md`. No text from the deleted files was copied anywhere.

## Task 1: result

Before the commit, `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` showed exactly one non-ok gate: `gate skills_pending_bbj-web-programming FAIL remove from pending: every count is 0; regenerate the baseline with --report`. Then `--report` wrote:

```
counts bbj-programming grammar=0 structure=0 bbjcpl=0 bbj-ls=0 should-fail=0
counts bbj-web-programming grammar=0 structure=0 bbjcpl=0 bbj-ls=0 should-fail=0
nocheck 0
```

tests/skills_baseline.json is now `{"bbj_version": "26.03", "nocheck": 0, "pending": {}}`. 05-BASELINE.md reads `## bbj-web-programming (not pending)` then `no violations`. A fresh `--report` is byte-identical to the committed JSON. No commit has `gate skills_pending_bbj-web-programming FAIL`.

## Task 2: phase-wide proof, every result line

| Check | Result |
| --- | --- |
| `probes/run.py --check` | `gate probes_canary ok bbjcpl and canaries agree`; `gate probes_reproduce ok 29 probes` |
| `ledger_check.py` | `gate ledger_files_covered ok 242 rows`; `gate ledger_totals ok 242 rows: DOC 106, COMPILE 12, RUNTIME 115, OWNER 9; keep 46, rewrite 44, drop 150, fold 2` |
| `checklist_check.py --recorded` | `gate checklist_ledger ok claims and row ids of 11 items match 05-LEDGER.md`; `gate checklist_recorded ok all 11 results recorded` |
| `trace_check.py` over SKILL.md and 4 references | `trace_tokens ok 12 dwc- names in 5 files trace to DOC, COMPILE or OWNER rows`; `trace_grants ok 9 OWNER rows, 9 grants checked in the given files`; `trace_rejected ok 2 rejected or unconfirmed claims, none in the given files` |
| Taste scan (GSAP, Swiper, Tabler, Playfair, Google Fonts, 420px, Inter, PT Serif, Roboto Mono) | none found |
| WEB-03 scan | `top level window of the page` present; no `end of <body>` and no `wins ... cascade` |
| D-15 scan | `focus ring` present; no outline, outline-offset, box-shadow |
| Table rows (`^|`) in the skill | none |
| Skill name | line 2 is `name: "bbj-web-programming"`; plugin.json untouched |
| Reference size | 363 lines in references/ (limit 500; 973 before) |
| Links | every `references/<name>.md` and `bbj-programming/references/<name>.md` path exists; nothing under plugins/, docs/, codex/ or README.md names a deleted reference |
| References vs ledger Destinations | `have` equals `destinations`: form-validation, running-dwc-apps, shoelace, styling |
| `tests/test_never_execute.sh` | `gate canned_error ok`, `gate canned_clean ok`, `gate sentinel_final ok still never ran` |
| Live gate | `skills_ratchet_bbj-web-programming_{grammar,structure,bbjcpl,bbj-ls,should-fail} ok 0 violations`; `skills_pending_keys ok pending: none`; `skills_baseline ok 0 pending skill(s)`; no `skills_pending_bbj-web-programming` line |
| `BBJ_SKILLS_LIVE=1 BBJ_LS_LIVE=1 sh tests/run.sh` | `SUMMARY: ok=701 fail=0 skip=2` |
| CI view (`BBJ_TEST_HOME=/nonexistent BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp CI=true sh tests/run.sh`) | `SUMMARY: ok=655 fail=0 skip=8` |

The accepted `real_home_untouched` flake did not occur; no rerun was needed.

## Final line counts

| File | Lines |
| --- | --- |
| SKILL.md | 163 |
| references/form-validation.md | 59 |
| references/running-dwc-apps.md | 70 |
| references/shoelace.md | 86 |
| references/styling.md | 148 |
| references total | 363 |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 1 verify greps `^gate .* FAIL`, which matches an intentional fixture line**
- **Found during:** Task 1 verify
- **Issue:** `gate skills_fx_structure_linked_skill_dir ok status=ok: rc 1, wanted a failing line starting 'gate skills_structure_linked FAIL' ...` is an ok gate whose detail contains the words `gate ... FAIL`. The plan's regex reports it as a failing gate (the same trap 05-06 recorded).
- **Fix:** Ran the same verify with `^gate [^ ]+ FAIL` (a gate named FAIL only when the status field is FAIL); everything else in the command unchanged. It exits 0. The plan file was not edited.
- **Files modified:** none (the verify copy lived in the scratchpad)
- **Commit:** none

**Total deviations:** 1 auto-fixed (verify regex). **Impact:** none on shipped files or the baseline.

## Hand-off to Phase 6 (REL-02, T-05-33)

Codex users keep the four deleted reference files (color-chooser.md, responsive-layout.md, shadow-dom-styling.md, themes.md) in their installed skill copy until they reinstall with `--force`. The old copies still carry the removed advice, so the 0.2.0 upgrade note in CHANGELOG and the installer output must say: reinstall with `--force`. Claude Code users get the new tree through the plugin update.

## Auth gates

None.

## Known Stubs

None. Only deletions, a generated baseline and a generated report were committed.

## Threat Flags

None. T-05-31 mitigated (baseline written by `--report`, fresh `--report` equals the committed file, pending `{}`, every ratchet 0), T-05-32 mitigated (only the ledger's Deleted line, one commit with the baseline), T-05-33 transferred to Phase 6 REL-02 (above), T-05-34 mitigated (`test_never_execute.sh` passes; gate and probes use `-t -N -X`).

## Self-Check: PASSED

- 05-BASELINE.md exists; the four deleted files are gone; tests/skills_baseline.json has `"pending": {}`
- commit 379ce6b is an ancestor of HEAD; `git rev-list --count` from the ledger base is 1
- Task 1 verify (with the stricter FAIL regex) and Task 2 verify both exit 0; `KNOWN_PENDING = {"bbj-programming": 4, "bbj-web-programming": 5}` unchanged
