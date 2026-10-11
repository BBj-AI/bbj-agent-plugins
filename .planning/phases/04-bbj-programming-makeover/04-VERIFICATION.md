---
phase: 04-bbj-programming-makeover
verified: 2026-10-11T09:45:00Z
status: gaps_found
score: 5/6 must-haves verified
covered_files:
  - ".planning/phases/04-bbj-programming-makeover/04-01-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-01-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-02-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-02-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-03-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-03-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-04-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-04-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-05-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-05-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-06-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-06-SUMMARY.md"
  - "codex/AGENTS-snippet.md"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-programming/references/callback-performance.md"
  - "plugins/bbj/skills/bbj-programming/references/database.md"
  - "plugins/bbj/skills/bbj-programming/references/running.md"
  - "plugins/bbj/skills/bbj-programming/references/sysgui.md"
  - "tests/skills_baseline.json"
covered_digest: "v3:sha256:bf9c90c152f0a8b2446d84321f91f2ce9a8981bbef0819009cd3c1597b88aaeb"
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "Every claim the skill and its references hand an agent is documented (URL) or reproduced; no shipped statement goes beyond its evidence (phase goal: 'only verified rules'; PROJECT core value)"
    status: failed
    reason: "The mechanical gates are green and every code block compiles, but several shipped statements assert more than the cited page or probe shows, and two provenance statements are false. The review (04-REVIEW.md WR-01, WR-02, WR-05, WR-06, WR-07) is confirmed against the files and, for WR-02 and WR-04, against the fetched documentation pages."
    artifacts:
      - path: "plugins/bbj/skills/bbj-programming/SKILL.md"
        issue: "L18-20 says every rule was 'checked with bbjcpl and bbj-ls on BBj 26.03' and that the file holds only rules 'the documentation do not state'. False: the sign-mask rule (L130-139) is OWNER-confirmed (probe t21 only compiles the example, ledger L031), and the rem rule and the !ERROR=26 rule are stated by documentation pages the same file cites (ledger L003 and L008 are class DOC). L143 also tells the agent the primer covers 'STR() returning a plain string' although the ledger (S5, G10) records that primer paragraph as stale."
      - path: "plugins/bbj/skills/bbj-programming/references/sysgui.md"
        issue: "L12-13 replaces the non-existent setModal with 'Pass the Dialog flag'. addWindow page text (re-fetched): '$00080000$ Dialog : Sets the window to behave as a dialog.' It never says modal; the same page has separate '$02000000$ MDI Desktop Modal' and '$40000000$ MDI Group Modal' flags. Ledger L117 classes 'Modality is a creation flag' as DOC but its quoted sentence does not state modality. L49-74 'Clickable images' tells the agent to call setReportAllMouseEvents(1) although its own quote says an image already reports mouse events, and the example has no image control (WR-03)."
      - path: "plugins/bbj/skills/bbj-programming/references/database.md"
        issue: "L76-79 'Use them, and only the functions they list' is an absolute with no source (ledger L093 only records that the three pages answer 200); the same file shows JDBC URLs that may point at third-party databases (WR-05). L9, L17, L31 write getJDBCConnection(name) and 'MyDatasource'; the page parameter is `url` (a BBj database name defined in the Enterprise Manager, case exact, or a JDBC URL); ledger L089 required exactly this rewrite and it was not delivered (WR-04)."
      - path: "plugins/bbj/skills/bbj-programming/references/running.md"
        issue: "L45 'Verified on BBj 26.03 against the documentation pages listed; nothing was run' covers the bbj -tIO rule, which is OWNER-confirmed (D-22) and whose cited PRO/5 page does not mention `bbj -tIO` (WR-06). L27-30 drops the page's own condition ('When not in a public program, both END and STOP ... Place PRO/5 in console mode', re-fetched), adds the inference 'so it stays open', and advises RELEASE next to a bullet saying RELEASE rolls back uncommitted transactions without linking the two (WR-07)."
    missing:
      - "SKILL.md intro: say that most rules were reproduced with bbjcpl and bbj-ls on BBj 26.03, the others cite the page that states them, and mark the sign-mask rule as owner-confirmed; drop 'only ... the documentation do not state'"
      - "SKILL.md L143: remove the STR() item from the list of what the primer covers (or cite commands/bbj-commands/str_function_bbj.htm beside str_function.htm); L26: 'With -t -N -X and no -W, any stderr line is a finding' (IN-03, IN-04)"
      - "sysgui.md: state only 'the Dialog flag makes the window behave as a dialog' (or add a source or owner confirmation that it is modal); fix the clickable-image rule so it says when setReportAllMouseEvents(1) is needed and show an image control in the example or retitle the section (WR-02, WR-03)"
      - "database.md: getJDBCConnection(url) with the documented meaning of url and a database name or marked placeholder in the examples; replace 'only the functions they list' with 'for a BBj database ... for a third-party database use that database's functions'; mark the SQL-verb placeholders and correct the intro sentence about which examples the How-To page holds (WR-04, WR-05, WR-08)"
      - "running.md: footer names what was checked (documentation pages for RELEASE, END and the options; -tIO owner-confirmed on BBj 26.03; nothing run); END/STOP with the page's 'not in a public program' condition and no 'stays open' inference; add 'RELEASE rolls back uncommitted transactions, so commit first' (WR-06, WR-07)"
      - "Update 04-LEDGER.md rows L117 (class DOC does not hold: the page does not state modality) and L089 so the ledger matches what ships"
deferred: []
---

# Phase 4: bbj-programming makeover Verification Report

**Phase Goal:** An agent using `/bbj:bbj-programming` gets only verified rules: the check workflow first, a short body, every claim documented or reproduced, and every code block passing the gate
**Verified:** 2026-10-11
**Status:** gaps_found
**Re-verification:** No, initial verification

## Goal Achievement

The structural and mechanical work is done and real: the ledger exists and checks, the probes reproduce, the skill was rewritten to a 153-line file with the check block first, every `bbj` block passes both live routes, `bbj-programming` is off the pending list, and all taste and project leftovers are gone. What falls short is the goal's word "only verified": a handful of agent-facing statements assert more than their cited source or probe supports, and two provenance lines are false. These are wording-level defects in four files, confirmed independently (not taken from the review alone).

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1 / PROG-01: a claim ledger classifies every claim as DOC, COMPILE or RUNTIME (plus OWNER); no RUNTIME claim survives unless rewritten | VERIFIED | `04-LEDGER.md` has 150 rows (DOC 53, COMPILE 39, RUNTIME 56, OWNER 2; keep 25, rewrite 12, drop 106, fold 7). I re-ran `ledger_check.py`: all 17 gates ok, including `ledger_runtime` (no RUNTIME row keep/fold) and `ledger_owner` (exactly the two D-22 rows). `probes/run.py --check`: `probes_canary ok`, `probes_reproduce ok 74 probes`. Caveat carried to truth 6: row L117 is classed DOC but its quoted sentence does not state the claim. |
| 2 | SC2 / PROG-02: SKILL.md opens with the check workflow, body about 150 lines or fewer, points to docs tools and `bbj://primer` instead of copying tables | VERIFIED | SKILL.md is 153 lines in total (frontmatter 4 lines, body 149). The `bbj-check-order` block sits directly after the frontmatter, before the H1. `grep -c '^|'` is 0 (no tables). L141-146 "Look it up instead" points to `bbj://primer`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`, `bbj_search`, `bbj_fetch_page`. `tests/test_check_order.py` all `checkorder_*` gates ok. |
| 3 | SC3 / PROG-03: the skill states the primer-gap rules correctly: bare method calls are statements and `name(args)` is not; "Built in: no USE needed" is scoped to BBj classes and `java.lang`; the `bbjcpl -t -N -X` quirks on 26.03; the REM/`;` rule | VERIFIED | Each rule traced to probes in `probes/OUTPUT.txt` (reproduced by `--check`): `t03_rem_bad` (error both routes) vs `t04_rem_ok`, `t05_label_rem` (label exception); `b01/b02/b07/b08/t06` (bare function-style call: syntax error on both routes) vs `t07/t08/b04/b06` (`v!.get(0)`, `#foo()`, `BBjAPI().makeVector()` clean); `u01/u02` (BBj classes, `String`, `Integer`, `Math`, `System` clean without USE), `u03/u04` (`HashMap`/`ArrayList` fail only on bbjcpl, bbj-ls clean), `u05/u08`; quirks: header `exit status 0, stdout 0 bytes`, `q01/q02` (N is BBj line number, parenthesised number is file line), `q03` (`Cannot find program ... for type`), `q04` (`-W` warnings), `ev01` (event constant unchecked). The Built-in paragraph is byte-identical in `SKILL.md:79` and `codex/AGENTS-snippet.md:21`. Caveats (not rule errors): IN-03 (primer pointer for STR() is stale) and IN-07 (no test keeps the two Built-in paragraphs equal). The primer cross-check (D-05) rests on the ledger's primer column; I could not call `bbj://primer` from this agent. |
| 4 | SC4 / PROG-04, PROG-05: known wrong claims corrected; all taste and leftovers gone; launcher facts only where verified, framed as applying when the user asks to run | VERIFIED | `LIMIT (first, count)` with the SQL_LIMIT.htm quote in `database.md:67-74`; `str()` example now `str(rate:"-##0.00")` with the sign trap (probe t21, OWNER row L031); `bbjcpl` errors on stderr, stdout empty, exit 0 (`SKILL.md:26-27`, header of OUTPUT.txt); `HashMap`/`ArrayList` need `USE` (`SKILL.md:79-92`, probes u03/u04/u05). `grep` for `PRECISION 16`, `Utils`, `wi`, size-guard, `DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin`, `nocheck`, `vendored` over the skill: no hits. `running.md:3-4` is framed "only when the user asks to run a BBj program" and "Do not run a program on your own initiative"; every launcher line cites a documentation.basis.cloud page except `-tIO`, which is the OWNER grant (D-22). The wording defects in `running.md` are recorded under truth 6. |
| 5 | SC5 / PROG-06: every `bbj` block passes the live gate on both routes, structure lints pass, the skill is still `/bbj:bbj-programming` | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py`: all five `skills_ratchet_bbj-programming_*` gates `ok 0 violations`; no FAIL line outside fixtures; only `bbj-web-programming` lines are `skip pending (Phase 5)`. `tests/skills_baseline.json` pending holds only `bbj-web-programming`; `nocheck` 0. `name: "bbj-programming"` unchanged, description 716 characters (limit 1,024). `git diff d61265c HEAD -- plugins/bbj/.claude-plugin` is empty. No file under `plugins/`, `docs/`, `codex/`, `README.md` or `tests/` names the deleted `java-interop.md` or `reserved-words.md`. Orchestrator evidence (`tests/run.sh` ok=702 fail=0 skip=55) is consistent with these re-runs. |
| 6 | Goal / core value: every claim and rule the skill and its references hand an agent is documented (URL) or reproduced; nothing is stated beyond its evidence | FAILED | See gaps. Confirmed independently: SKILL.md:18-20 provenance sentence is false (WR-01); sysgui.md Dialog-as-setModal rests on a page that says only "behave as a dialog" and the page lists separate MDI modal flags (WR-02, re-fetched); `database.md` "only the functions they list" has no source (WR-05) and `getJDBCConnection(name)` contradicts the page's `url` parameter and ledger L089's own rewrite note (WR-04); `running.md` footer overstates verification for the OWNER `-tIO` rule and END/STOP drops the page's "not in a public program" condition (WR-06, WR-07, END page re-fetched). |

**Score:** 5/6 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `.planning/phases/04-.../probes/run.py`, `OUTPUT.txt`, `rw-words.txt`, `README.md` | compile-only probe runner and recorded evidence | VERIFIED | `--check` reproduces 74 probes; canary pair ok |
| `.planning/phases/04-.../04-LEDGER.md`, `ledger_check.py` | 150-row ledger and checker | VERIFIED (see truth 6 caveat L117, L089) | 17 gates ok |
| `plugins/bbj/skills/bbj-programming/SKILL.md` | rewritten skill | VERIFIED, with wording gaps | 153 lines, check block first |
| `plugins/bbj/skills/bbj-programming/references/running.md` | launcher facts with URLs | VERIFIED, with wording gaps | exists, `## Sources`, `Verified on BBj 26.03` line |
| `.../references/sysgui.md`, `callback-performance.md`, `database.md` | survivors with checked blocks | VERIFIED, with wording gaps | all blocks pass the live gate |
| `.../references/java-interop.md`, `reserved-words.md` | deleted | VERIFIED | absent, not referenced anywhere |
| `codex/AGENTS-snippet.md` | scoped Built-in line | VERIFIED | line 21 equals `SKILL.md:79` |
| `tests/skills_baseline.json` | `bbj-programming` off pending | VERIFIED | only `bbj-web-programming` pending |
| `04-DOCS-PROPOSAL.md`, `04-BASELINE.md` | proposal and report | VERIFIED (exist; not audited line by line) | present in phase directory |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| `SKILL.md` Built-in line | `codex/AGENTS-snippet.md:21` | byte-identical paragraph | WIRED | identical text at both lines; no test pins it (IN-07, warning) |
| `SKILL.md` check block | `tests/test_check_order.py` | markers `bbj-check-order` | WIRED | all `checkorder_*` gates ok |
| `SKILL.md` index | `references/*.md` | index lines 150-153 | WIRED | all four listed files exist |
| ledger COMPILE rows | `probes/OUTPUT.txt` | `probes/<name>.bbj` sections | WIRED | `ledger_compile_probe ok 150 rows` |
| `bbj-web-programming/references/form-validation.md:3` | `callback-performance.md` | existing prose link | WIRED | file name kept |
| ledger verdicts | shipped text | rows named `(SKILL.md)`/`(references/...)` | PARTIAL | L089 rewrite and L117 evidence not matched by the shipped text (gap) |

### Data-Flow Trace (Level 4)

Not applicable: the deliverable is Markdown, a JSON baseline and planning artifacts; nothing renders dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Skill blocks pass both routes, ratchet 0 | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | 5 bbj-programming ratchet gates `ok 0 violations`; no FAIL | PASS |
| Probes reproduce | `python3 -I probes/run.py --check` | `probes_canary ok`, `probes_reproduce ok 74 probes` | PASS |
| Ledger structure and evidence | `python3 -I ledger_check.py` | 17 gates ok | PASS |
| Check-order block pinned | `python3 -I tests/test_check_order.py` | all gates ok | PASS |

All commands compile or read only; `bbj` was never run.

### Probe Execution

Phase-declared probe: `.planning/phases/04-bbj-programming-makeover/probes/run.py --check` (compile only, via `bbjcpl -t -N -X` and loopback `bbj-ls`). Result: PASS (see above). No `scripts/*/tests/probe-*.sh` probes are declared by this phase.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ----------- | ----------- | ------ | -------- |
| PROG-01 | 04-01, 04-02 | Claim ledger classifies every claim | SATISFIED (with L117/L089 caveat) | truth 1 |
| PROG-02 | 04-03 | Check workflow first, about 150 lines, pointers | SATISFIED | truth 2 |
| PROG-03 | 04-03 | Primer-gap rules incl. bare calls, Built-in scope, quirks, REM rule | SATISFIED for the rules; intro sentence false (gap) | truth 3, truth 6 |
| PROG-04 | 04-03, 04-06 | Wrong claims corrected, taste and leftovers cut | SATISFIED | truth 4 |
| PROG-05 | 04-05 | Launcher facts only where verified, framed for "user asks to run" | SATISFIED in framing; two wording defects (gap) | truth 4, truth 6 |
| PROG-06 | 04-03, 04-05, 04-06 | Every `bbj` block passes the gate; name unchanged | SATISFIED | truth 5 |

All six IDs appear in ROADMAP Phase 4 and REQUIREMENTS.md (checked off, traceability "Complete"). No orphaned requirement: REQUIREMENTS.md maps no other ID to Phase 4. REQUIREMENTS.md marks PROG-03, PROG-05 as Complete; the gaps below mean they should be treated as complete pending the wording fixes.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| `SKILL.md` | 18-20 | False provenance statement | BLOCKER | agent cannot tell compile-checked rules from owner-confirmed or doc-stated ones |
| `references/sysgui.md` | 12-13 | Implied modality, unsourced | BLOCKER | agent ships the Dialog flag as `setModal` |
| `references/database.md` | 76-79 | Unsourced absolute ("only the functions they list") | BLOCKER | RUNTIME-style claim with no doc or probe evidence |
| `references/running.md` | 27-30, 45 | Dropped condition, inference, overstated footer | BLOCKER | statement not equal to the page it cites |
| `references/sysgui.md` | 49-74 | Rule contradicts its own quote; example has no image | WARNING | misleading example (WR-03) |
| `references/database.md` | 9, 17, 31, 53-65 | Parameter named `name`, `MyDatasource`, unmarked placeholders | WARNING | WR-04, WR-08 |
| `callback-performance.md`, `running.md`, `SKILL.md` | various | IN-01, IN-02, IN-05, IN-06, IN-07 | INFO | name mismatch, unsourced constant, missing `setVisible(1)` line, `bash` fence on a non-command, duplicated paragraph with no pinning test |

Debt-marker scan (`TBD`, `FIXME`, `XXX`, `TODO`, `HACK`, `PLACEHOLDER`) over the six shipped files: no hits.

### Judgment-tier prohibitions

The PLAN prohibitions marked `verification: judgment` were weighed (non-authoritative LLM-judge verdicts, flagged for human review):

- 04-03 "SKILL.md MUST NOT state a rule that has no ledger row with verdict keep/rewrite/fold naming SKILL.md": no unledgered rule found, but the SKILL.md intro makes a claim about every rule that is not itself true (gap above). `unverified-prohibition - human review recommended`.
- 04-02 "ledger MUST NOT use a primer paragraph or non-citable page as DOC evidence": no instance found in the rows read; ledger L117 uses a real page that does not state the claim (different defect). `unverified-prohibition - human review recommended`.
- 04-05 "skill MUST NOT tell the agent to run a BBj program on its own initiative": satisfied, `running.md:3-4` says the opposite and the SKILL.md pointer applies only "when the user asks to run a program".

### Human Verification Required

None required for the status. The sign-mask and `bbj -tIO` rules are OWNER-granted (04-CONTEXT D-22) and ship as verified by the owner's decision; the owner may still choose to accept the footer wording as is by adding overrides (see below).

### Gaps Summary

One root cause: the rewrite proved the code and the rules it wanted to keep, but the prose around them was not held to the same standard, so several sentences say more than their sources do. All of it is wording-level and fixable in one small plan (SKILL.md intro and two lines, `sysgui.md`, `database.md`, `running.md`, ledger rows L117 and L089), then `ledger_check.py`, `probes/run.py --check` and the live gate re-run (no new probes needed unless the owner wants to prove modality of the Dialog flag by a compile observable, which a compiler cannot show; sourcing or owner confirmation is the route).

Not gaps (confirmed fine): block compile status, structure lints, baseline, check-order pinning, taste and leftover removal, requirement coverage, skill name, deleted references.

**Decision requested from the owner for two items** (both are plausible intentional deviations; add an override to accept, otherwise fix):

```yaml
overrides:
  - must_have: "running.md states bbj -tIO sends print output to stdout as a plain fact"
    reason: "Owner-confirmed on BBj 26.03 (04-CONTEXT D-22), stated plain by decision; only the footer wording should name the owner confirmation"
    accepted_by: "Stephan Wald"
    accepted_at: "<ISO timestamp>"
```

The footer wording itself (WR-06) is not covered by that override and should still be corrected.

---

_Verified: 2026-10-11_
_Verifier: Claude (gsd-verifier)_
