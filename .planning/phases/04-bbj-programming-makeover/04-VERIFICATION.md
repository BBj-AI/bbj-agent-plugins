---
phase: 04-bbj-programming-makeover
verified: 2026-10-11T16:10:00Z
status: human_needed
score: 6/6 must-haves verified
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
  - ".planning/phases/04-bbj-programming-makeover/04-07-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-07-SUMMARY.md"
  - ".planning/phases/04-bbj-programming-makeover/04-08-PLAN.md"
  - ".planning/phases/04-bbj-programming-makeover/04-08-SUMMARY.md"
  - "codex/AGENTS-snippet.md"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-programming/references/callback-performance.md"
  - "plugins/bbj/skills/bbj-programming/references/database.md"
  - "plugins/bbj/skills/bbj-programming/references/running.md"
  - "plugins/bbj/skills/bbj-programming/references/sysgui.md"
  - "tests/skills_baseline.json"
covered_digest: "v3:sha256:970260ea5f1565ba6b7cbc55178817f328e3b7e3ee6a13b21fea4ccd1813a4ac"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 6/6
  gaps_closed:
    - "G-04-2 (UAT test 2): sysgui.md now states that the Dialog flag creates a modal window, cites the WINDOW mnemonic page with the isModal and getActiveContext examples as support, no longer disclaims modality, and ships the owner's front rule (D-24, as the owner rescoped it) marked as maintainer-confirmed; ledger L117 is DOC, L119 DOC (drop), L151 OWNER; the SKILL.md intro excepts every maintainer-confirmed rule"
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "Re-run UAT test 2 (04-UAT.md) against the shipped sysgui.md lines 12-26 and mark it passed or reopen G-04-2"
    expected: "The owner reads that the Dialog flag makes the window modal (WINDOW mnemonic page), that the front rule is worded as he scoped it in the plan-revision session (a window without the Dialog flag that already existed cannot be brought in front of an open Dialog-flag window; nothing about windows created later), and that it is marked as the skill maintainer's confirmed rule"
    why_human: "04-UAT.md still records test 2 as `issue` / G-04-2 `failed` (status `diagnosed`); only the owner can close a UAT item, and the front rule is an owner fact that no page or probe can show. The code state matches the plan and the owner-scoped D-24 exactly, but the owner has not yet seen the result."
  - test: "Dispose of open review warning WR-01 (SKILL.md:133-138, `@` and `&` next to the sign characters) and the two open info items IN-01, IN-02 (sysgui.md)"
    expected: "Each gets fixed, skipped or deferred in 04-REVIEW-DISPOSITION.md. Verifier recommendation: fix WR-01 before 0.2.0 (one sentence: `@` and `&` are currency characters, not sign characters), and take IN-02 (`modal top-level window`) and IN-01 (`which sets the Dialog bit`) in the same edit; each is a wording change to existing text."
    why_human: "Disposition is the owner's call. I confirmed WR-01 against the re-fetched numeric_output_bbj.htm page: it defines `@` as the international currency code and `&` as the local currency symbol and says nothing about signs, so `Put one in every mask` after a list that ends in `@ and &` can be read as treating them as sign characters. The sign rule itself is owner-confirmed and the sentence is not false; I judge this a warning, not a gap, because the page quotes are accurate and the sign-character list in the previous sentence is correct. It is the closest call in this report."
  - test: "Accept or reject the flagged prohibitions of plan 04-08 (see 'Judgment-tier prohibitions')"
    expected: "Owner confirms: no shipped sentence says anything about windows created after the Dialog-flag window, or about focus or the active window, or widens the owner rule; no shipped sentence claims a fact beyond its page or D-24"
    why_human: "The test-tier prohibition on the forms of the front rule is enforced only by the plan's own task verify (a grep run by the executor), not by any test in the repository, so under the fail-closed rule it stays flagged although my read and grep of the shipped files find it satisfied. The judgment-tier verdicts are non-authoritative."
---

# Phase 4: bbj-programming makeover Verification Report

**Phase Goal:** An agent using `/bbj:bbj-programming` gets only verified rules: the check workflow first, a short body, every claim documented or reproduced, and every code block passing the gate
**Verified:** 2026-10-11
**Status:** human_needed
**Re-verification:** Yes, after gap closure plan 04-08 (UAT gap G-04-2)

## Goal Achievement

G-04-2 is closed in the shipped files, not only in the SUMMARY. I read `sysgui.md`, `SKILL.md`, ledger rows L117, L119 and L151, the docs-proposal L151 entry and `04-CONTEXT.md` D-24. I re-fetched the four pages that the new `sysgui.md` text quotes from documentation.basis.cloud and confirmed each quote. I re-ran every gate that guards the skill. Nothing that passed in the previous report regressed, and no automated check fails.

The status stays `human_needed`, not `passed`, for three reasons that only the owner can settle: UAT test 2 still reads `issue` until the owner re-tests it, one open review warning (WR-01) concerns shipped text, and the plan's test-tier prohibitions have no wired test in the repository.

### Closure of G-04-2 (each `gaps[].missing` item checked in the shipped file)

| `missing` item in 04-UAT.md | Shipped state | Evidence |
| --- | --- | --- |
| 1. State that the Dialog flag creates a modal window, citing the WINDOW mnemonic page, with isModal / getActiveContext as support | CLOSED | `sysgui.md:12-19`: "For a modal window, pass the Dialog flag." followed by the WINDOW mnemonic quote "the dialog behavior flag ($00080000$), that creates a modal dialog" (qualifier "for top level windows in BBj" kept), the `isModal()` example `addWindow(X,Y,WIDTH,HEIGHT,"Modal",$00080083$)` and the `getActiveContext()` example (`$80002$`, "Should print 2 (the modal window)"). The three URLs are also under `## Sources` (L111-113). I re-fetched the pages: "creates a modal dialog", "top level windows in BBj", "dialog behavior flag" (1 hit each), "Create a modal window", `00080083`, "1 = Modal", `80002`, "modal window" all present; the addWindow page has "behave as a dialog", "Desktop Modal", "Group Modal" and 0 hits for `setModal`. |
| 2. Remove the IN-02 "makes no claim about modality" disclaimer | CLOSED | The lead-in at `sysgui.md:36` reads "A modal dialog that starts invisible, with the Dialog and Invisible flags:". `grep -i` over sysgui.md for a no-claim disclaimer finds none. |
| 3. Ledger L117 back to DOC, L119 re-verdicted, totals recounted; proposal L118 bullet rewritten | CLOSED | `04-LEDGER.md` L117 class DOC with the WINDOW mnemonic page first; L119 class DOC, verdict drop, cites isModal and dialogbehavior pages; `ledger_check.py` prints `ledger_totals ok 151 rows: DOC 54, COMPILE 39, RUNTIME 55, OWNER 3; keep 21, rewrite 17, drop 106, fold 7`, equal to the Totals line (all 17 gates ok). Proposal: `### L151 ...` entry present (L428-440), granted "in decision D-24". |
| 4. The owner's finer front-ordering rule ships only as an owner-confirmed decision, or is left out | CLOSED | `sysgui.md:21-22`: "While a Dialog-flag window is open, a window without the Dialog flag that already existed cannot be brought in front of it. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it." plus a Sources line "Verified on BBj 26.03 by the skill maintainer: ..." (L119-120). The wording equals D-24 as the owner rescoped it (`04-CONTEXT.md:117-119`, exactly one `D-24` first line, last changed in commit 46f2036 before the executor ran). Ledger L151 is OWNER and cites `grant 04-CONTEXT.md D-24`; `ledger_owner ok 3 OWNER rows`. |
| artifact: SKILL.md intro named only `str()` | CLOSED | `SKILL.md:18-20`: "The others cite the documentation page that states them, except rules that say the skill maintainer confirmed them on BBj 26.03, such as the `str()` sign rule." Every maintainer-confirmed rule carries that wording: SKILL.md:133 (`str()`), `running.md:55` (`bbj -tIO`), `sysgui.md:22` and `sysgui.md:119`. Index line `SKILL.md:155` reads "window flags and the modal Dialog flag". |

The shipped rule is narrower than the sentence the owner first typed in UAT ("no other windows can come to front ... unless created later"). That is deliberate: the plan records that the owner rescoped it to windows without the flag that already existed, and nothing is said about windows created later. The text, the ledger row and the docs-proposal entry all carry the scoped form. This is why the owner should re-run UAT test 2 (human item 1) rather than the verifier closing it.

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1 / PROG-01: a claim ledger classifies every claim as DOC, COMPILE or RUNTIME (plus OWNER); no RUNTIME claim survives unless rewritten | VERIFIED | `ledger_check.py`: 17 gates ok, 151 rows, `ledger_owner ok 3 OWNER rows` (L031, L072, L151), `ledger_runtime ok`, `ledger_doc_url ok`, `ledger_totals ok`. `probes/run.py --check`: `probes_canary ok`, `probes_reproduce ok 74 probes`. L117 is DOC again, which is what the WINDOW mnemonic page supports. |
| 2 | SC2 / PROG-02: SKILL.md opens with the check workflow, body about 150 lines or fewer, points to docs tools and `bbj://primer` | VERIFIED (with note) | Check-order block directly after the frontmatter; `tests/test_check_order.py`: all 10 gates ok, three copies identical. "Look it up instead" (L146-151) names `bbj://primer`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`, `bbj_search`, `bbj_fetch_page`. The file is 158 lines, 154 below the 4-line frontmatter. That is above the 149 verified in the previous report; the growth came from review fixes, not from plan 04-08 (which changed two lines and added none). 154 is "about 150"; I note the drift so Phase 6 does not add more. |
| 3 | SC3 / PROG-03: primer-gap rules stated correctly (bare calls, Built-in scope, `bbjcpl -t -N -X` quirks, REM/`;`) | VERIFIED | Unchanged by 04-08. All five should-fail/pass pairs in SKILL.md pass both live routes; 74 probes reproduce. |
| 4 | SC4 / PROG-04, PROG-05: wrong claims corrected, taste and leftovers gone, launcher facts only where verified and framed for "user asks to run" | VERIFIED | `running.md` unchanged by 04-08. Debt-marker scan (`TBD`, `FIXME`, `XXX`, `TODO`, `HACK`, `PLACEHOLDER`) over `plugins/bbj/skills/bbj-programming`: the only hits are two lowercase prose uses of "placeholders" in `database.md:16,63` that tell the reader which literals to replace; no marker. `grep -i "project owner"` over the skills: none. |
| 5 | SC5 / PROG-06: every `bbj` block passes the live gate on both routes; skill name unchanged | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exit 0, zero `gate ... FAIL` lines: `skills_route_bbjcpl ok /opt/bbx/bin/bbjcpl: 57 file(s) in one call`, `skills_route_bbj-ls ok http://127.0.0.1:5009/mcp: 55 call(s)`, all five `skills_ratchet_bbj-programming_*` gates `ok 0 violations`; `bbj-web-programming` lines only `skip pending (Phase 5)`. The two sysgui blocks equal probes s01 (should-fail) and s02 byte for byte (my diff); probe output records s01 as a bbjcpl type-check error, as the text says. `name: "bbj-programming"` unchanged. |
| 6 | Goal / core value: every claim and rule is documented (URL) or reproduced; nothing is stated beyond its evidence | VERIFIED (with warnings) | Every changed sentence of 04-08 read against its re-fetched page: the modal quote, the isModal and getActiveContext examples, the MDI flag names, and the "behave as a dialog" entry match. The one phrase that is arithmetic and not a page statement ("`$80002$` ... includes the Dialog flag", IN-01) is correct (`$80002$` = `$80000$` + `$02$`) and is disclosed as an info item. One pre-existing sentence goes beyond its page by implication (WR-01); see Anti-Patterns. It does not change a rule the agent follows if the sentence is read as intended, so it does not fail this truth, but it needs the owner's disposition (human item 2). |

**Score:** 6/6 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/skills/bbj-programming/references/sysgui.md` | Dialog flag as modal (DOC), D-24 rule marked maintainer-confirmed, three new Sources | VERIFIED | 120 lines; contains "For a modal window, pass the Dialog flag."; blocks equal probes s01, s02; Sources has 8 URLs plus two verified lines |
| `plugins/bbj/skills/bbj-programming/SKILL.md` | index line and intro sentence | VERIFIED | contains "window flags and the modal Dialog flag"; intro L18-20 as planned |
| `.planning/phases/04-bbj-programming-makeover/04-LEDGER.md` | L117 DOC, L119 DOC drop, L151 OWNER, Totals | VERIFIED | contains "grant 04-CONTEXT.md D-24"; gates green |
| `.planning/phases/04-bbj-programming-makeover/04-DOCS-PROPOSAL.md` | L118 bullet, L151 entry, counts | VERIFIED | `### L151, a window without the Dialog flag that already existed cannot be brought in front of a Dialog-flag window` present at L428; not audited line by line beyond the L151 entry |
| `04-CONTEXT.md` D-24 | owner decision, untouched by the executor | VERIFIED | first line occurs once; last commit touching the file is 46f2036 (plan revision), before the 04-08 execution commits |
| Previous round's artifacts (`database.md`, `running.md`, `callback-performance.md`, `codex/AGENTS-snippet.md`, `tests/skills_baseline.json`) | unchanged by 04-08 | VERIFIED | `git diff 2077ea3 HEAD --stat` lists for the skill only `SKILL.md` and `sysgui.md`; live gate green |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| sysgui.md front-rule sentence | ledger L151 (OWNER) | "the skill maintainer confirmed on BBj 26.03" | WIRED | sentence at L21-22; Sources line L119-120 |
| SKILL.md intro, last sentence | the three maintainer-confirmed rules | "except rules that say the skill maintainer confirmed them" | WIRED | SKILL.md:133, running.md:55, sysgui.md:22 and 119 each say it |
| ledger L151 | 04-CONTEXT.md D-24 | `grant 04-CONTEXT.md D-24` | WIRED | gate `ledger_owner` reads the decision line |
| sysgui.md modal sentence | ledger L117 (DOC) | WINDOW mnemonic URL in both | WIRED | |
| ledger Totals | gate `ledger_totals` | same line | WIRED | gate detail equals the Totals text |
| proposal L151 entry | ledger L151 | D-23 | WIRED | "ledger id L151; granted in decision D-24" |
| SKILL.md check block | `tests/test_check_order.py` | markers | WIRED | all gates ok |

### Data-Flow Trace (Level 4)

Not applicable: Markdown, a JSON baseline and planning artifacts; nothing renders dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Skill blocks pass both routes; ratchet 0 | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | rc 0, 0 FAIL gate lines, 5 ratchet gates `ok 0 violations` | PASS |
| Probes reproduce | `python3 -I probes/run.py --check` | `probes_canary ok`, `probes_reproduce ok 74 probes` | PASS |
| Ledger | `python3 -I ledger_check.py` | 17 ok gates, 3 OWNER rows | PASS |
| Check-order block | `python3 -I tests/test_check_order.py` | all ok | PASS |
| Layout | `python3 -I tests/test_layout.py` | no FAIL | PASS |
| sysgui blocks equal probes | python compare of fences vs `s01_setmodal.bbj`, `s02_dialogflag.bbj` | equal, equal | PASS |
| Quoted pages | fetched WINDOW mnemonic, isModal, getActiveContext, addWindow; searched for each quoted phrase | all present, `setModal` 0 hits on addWindow | PASS |
| Whole suite (run once) | `sh tests/run.sh` | `SUMMARY: ok=702 fail=0 skip=55`, rc 0 | PASS |

No BBj was executed; only `bbjcpl -t -N -X` and the loopback `bbj-ls` ran, through the existing gates. The `real_home_untouched` gate did not fail in this run (the environmental flake recorded and accepted by the owner in UAT test 3 did not recur).

### Probe Execution

Phase-declared probe `.planning/phases/04-bbj-programming-makeover/probes/run.py --check`: PASS (above). No `scripts/*/tests/probe-*.sh` is declared.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ----------- | ----------- | ------ | -------- |
| PROG-01 | 04-01, 04-02, 04-07, 04-08 | Claim ledger classifies every claim | SATISFIED | truth 1; L117/L119/L151 aligned with the shipped text |
| PROG-02 | 04-03, 04-08 | Check workflow first, about 150 lines, pointers | SATISFIED | truth 2 (154-line body noted) |
| PROG-03 | 04-03, 04-07 | Primer-gap rules | SATISFIED | truth 3 |
| PROG-04 | 04-03, 04-06, 04-07, 04-08 | Wrong claims corrected, taste and leftovers cut | SATISFIED | truths 4 and 6; the Dialog-flag omission is corrected |
| PROG-05 | 04-05, 04-07 | Launcher facts only where verified, framed for "user asks to run" | SATISFIED | truth 4 |
| PROG-06 | 04-03, 04-05, 04-06, 04-07, 04-08 | Every `bbj` block passes the gate; name unchanged | SATISFIED | truth 5 |

All six IDs appear in the plans' `requirements` frontmatter (04-08 lists PROG-01, 02, 04, 06) and in REQUIREMENTS.md, where all six are checked off with "Phase 4 / Complete". REQUIREMENTS.md maps no other ID to Phase 4: no orphans.

### Anti-Patterns Found

No blockers. Current review (`04-REVIEW.md`: 0 critical, 1 warning, 2 info), each weighed against the fetched pages:

| File | Line | Finding | Severity here | Reasoning |
| ---- | ---- | ------- | ------------- | --------- |
| `SKILL.md` | 133-138 | WR-01: "Put one in every mask" after a list that ends with `@` and `&` | WARNING | Confirmed. The Numeric Output page defines `-`, `+`, `(`, `)`, `CR`, `DR` as sign-producing characters. The BBj page defines `@` as "the three-character international currency code" and `&` as "the local currency symbol" and says nothing about signs. The text is pre-existing (04-08 did not touch it). The sentence is not false, but an agent can read `@##0.00` as keeping the minus. One-sentence fix in the review. |
| `references/sysgui.md` | 12-14, 24-26 | IN-02: "For a modal window, pass the Dialog flag" drops the page's "for top level windows in BBj" scope | INFO | The source sentence is scoped; the imperative is not. MDI desktop windows have their own modal flags listed in the next paragraph. Wording fix: "modal top-level window". |
| `references/sysgui.md` | 17-19 | IN-01: the getActiveContext citation omits that the example also creates `$02$` windows before and after; "includes the Dialog flag" is arithmetic | INFO | The example is cited only as support for modality, as planned; the front rule does not extend to later windows by design (D-24), so the omission is consistent. Optional wording. |
| `04-REVIEW-DISPOSITION.md` | WR-08 row | Stale `open` row: "SQL-verb example uses unmarked placeholders" | INFO | `database.md:63` now says "The URL, the table `t` and the column `col` in the block are placeholders; replace them with your own" (commit 36d1fca and the 04-07 fix). Bookkeeping only; set the row to `fixed` when dispositioning. |

I did not find a statement of the kind that failed in earlier rounds (an implied modality, an unsourced absolute, a dropped condition, a false provenance line). In particular, the omission that G-04-2 recorded is gone, and `sysgui.md` now agrees with `bbj-web-programming`, which already called the Dialog flag modal (its Phase 5 text is untouched).

### Judgment-tier prohibitions

Verdicts are non-authoritative; each carries `unverified-prohibition - human review recommended` unless a test enforces it.

- 04-08 (test tier) "The executor MUST NOT grant OWNER or widen D-24": enforced by `ledger_check.py` gate `ledger_owner` (exactly L031, L072, L151; L151 cites D-24) and by git history (04-CONTEXT.md untouched since the plan revision). Verified, not flagged.
- 04-08 (test tier) "sysgui.md, ledger L151 and the L151 proposal entry MUST NOT say anything about windows created after the Dialog-flag window, say or suggest that another window gets focus or becomes the active window, or widen the rule": satisfied by reading. `grep -i "later\|after the dialog\|focus\|created after\|active window"` over `sysgui.md` has no hits; the only occurrence of "active" is the page title `getActiveContext()`, which is a cited method name and a context number, not a claim about focus. The ledger and proposal L151 text restate D-24 and add the statement that nothing beyond it is granted. No test in the repository enforces this (the plan's own task verify did, once). Flagged.
- 04-08 (judgment) "No changed sentence may state a fact its page or D-24 does not establish": satisfied for every sentence 04-08 changed, with the arithmetic caveat of IN-01. Flagged as judgment.
- 04-08 (judgment) "No step runs BBj or sends skill code to the hosted check": satisfied; no block was added or changed, and the gate uses `bbjcpl -t -N -X` and the loopback `bbj-ls` only. Flagged as judgment.
- Earlier plans: 04-07 and 04-03 / 04-05 prohibitions are unchanged by 04-08; the 04-07 `-tIO` and Dialog/modality prohibitions are in fact superseded by 04-08 (the Dialog flag is now stated as modal on the page's own authority), and `running.md:55` still states the `-tIO` line plainly.

### Human Verification Required

### 1. Re-run UAT test 2

**Test:** Read `plugins/bbj/skills/bbj-programming/references/sysgui.md` lines 12-26 and mark UAT test 2 in `04-UAT.md` as passed, or reopen G-04-2.
**Expected:** The Dialog flag is stated as modal with the WINDOW mnemonic page; the front rule is worded as scoped in the plan-revision session and marked as the skill maintainer's confirmed rule; no sentence disclaims modality.
**Why human:** Only the owner closes a UAT item. The rule is an owner fact that no page or probe shows, and the shipped form is narrower than the sentence he first reported.

### 2. Disposition of WR-01, IN-01, IN-02

**Test:** Set a disposition for each in `04-REVIEW-DISPOSITION.md`; also set the stale WR-08 row to `fixed`.
**Expected:** Each is `fixed`, `skipped` or `deferred` with a reason. Recommendation: fix WR-01 (say `@` and `&` are currency characters, not sign characters) and IN-02 (say "modal top-level window") in one small edit, then re-run the live gate; IN-01 optional.
**Why human:** Whether "complete with one open wording warning" is acceptable for the 0.2.0 core value is the owner's call. I found no warning that falsifies a roadmap success criterion.

### 3. Flagged prohibitions

**Test:** Confirm that `sysgui.md` says nothing about windows created after the Dialog-flag window and nothing about focus, and that no changed sentence goes beyond its page or D-24.
**Expected:** Owner agrees with the reading above.
**Why human:** No repository test enforces the form restrictions; the judgment verdicts are non-authoritative.

### Gaps Summary

No gaps. G-04-2 is closed in the shipped files and in the ledger, the SKILL.md intro, and the docs proposal; every gate is green (`sh tests/run.sh`: ok=702 fail=0 skip=55; live skill gate rc 0 with five ratchet gates at 0 violations; ledger 17 gates ok; 74 probes reproduce). All six requirement IDs are satisfied and nothing that passed before regressed. The phase goal holds for the claims that matter. `human_needed` reflects three owner decisions: the UAT test 2 re-test, the disposition of one open wording warning in SKILL.md (WR-01, the closest call here), and the prohibitions that no repository test enforces.

---

_Verified: 2026-10-11_
_Verifier: Claude (gsd-verifier)_
