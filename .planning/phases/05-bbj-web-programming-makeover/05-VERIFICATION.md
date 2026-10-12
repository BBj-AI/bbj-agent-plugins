---
phase: 05-bbj-web-programming-makeover
verified: 2026-10-12T12:00:00Z
status: human_needed
score: 4/5 must-haves verified
covered_files:
  - .planning/phases/05-bbj-web-programming-makeover/05-01-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-01-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-02-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-02-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-03-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-03-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-04-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-04-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-05-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-05-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-06-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-06-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-07-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-07-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-08-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-08-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-09-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-09-SUMMARY.md
  - .planning/phases/05-bbj-web-programming-makeover/05-10-PLAN.md
  - .planning/phases/05-bbj-web-programming-makeover/05-10-SUMMARY.md
  - plugins/bbj/skills/bbj-web-programming/SKILL.md
  - plugins/bbj/skills/bbj-web-programming/references/form-validation.md
  - plugins/bbj/skills/bbj-web-programming/references/running-dwc-apps.md
  - plugins/bbj/skills/bbj-web-programming/references/shoelace.md
  - plugins/bbj/skills/bbj-web-programming/references/styling.md
  - tests/skills_baseline.json
covered_digest: "v3:sha256:83c68895518e492960447760f20d8849c7d3d791fdfc3385d4e7f6c21bc42783"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Decide fix-or-accept for WR-01 and WR-03 (examples that compile but contradict the rule or the API next to them)"
    expected: "form-validation.md no longer shows a JavaScript validator and `required` on one control under a file that says built-in wins; shoelace.md no longer moves one `icon!` into two parents and then calls setHtml on the card. Re-run BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py afterwards."
    why_human: "The code gate cannot see semantic contradiction; the core value says every code example handed to an agent is correct. Whether to fix before Phase 6 (0.2.0 release) or accept is a maintainer decision."
  - test: "Decide fix-or-accept for WR-04 and WR-08 (shipped wording broader than, or hiding a conflict with, the cited page)"
    expected: "SKILL.md /files/ bullet quotes DWC_Registration_Launching.htm as written (it says 'This html file ...'); the /files/lib/shoelace/*.js and *.css block is marked as an example path the page does not state, or the owner grants it. The BBjColorChooser rule (D-26) keeps its granted sentence and gains a note that dwc.style/docs/#/dwc/BBjColorChooser lists the saturation attribute as 0 to 100."
    why_human: "Ledger row L062 already decided 'rewrite (SKILL.md) to the page sentence'; the shipped text drifts from that decision. D-26 is an owner-granted sentence, so adding a note next to it needs the owner."
  - test: "Decide fix-or-accept for WR-02, WR-05, WR-06, WR-07 (omitted conditions or scope in cited rules)"
    expected: "running-dwc-apps.md explains the boolean ssl argument of getDwcUrl/getBuiUrl; styling.md quotes 'The method accepts the name of any built-in or custom theme' and shows activating a new theme; form-validation.md scopes the window-level data- note to the validation customization attributes; SKILL.md states that setProperty is for Reflects: No properties and non-string values."
    why_human: "Each is a completeness/accuracy judgment against the source page. I confirmed WR-05, WR-06 and WR-07 against the fetched dwc.style markdown; WR-02 rests on the review's reading of the Javadoc signature."
  - test: "Disposition the three info findings (IN-01 raw <html> in Markdown, IN-02 empty credential placeholders and the running.md pointer, IN-03 part::label spelling)"
    expected: "Each marked fixed, accepted or rejected in 05-REVIEW-DISPOSITION.md (all 11 findings are still `open`)."
    why_human: "Disposition is a maintainer decision; none blocks the gate."
---

# Phase 5: bbj-web-programming makeover Verification Report

**Phase Goal:** An agent using `/bbj:bbj-web-programming` gets a short, trigger-first skill whose DWC claims are each documented or reproduced and whose code blocks all pass the gate
**Verified:** 2026-10-12T12:00:00Z
**Status:** human_needed
**Re-verification:** No, initial verification

## Goal Achievement

The four ROADMAP success criteria hold in the codebase and every automated gate I re-ran is green. The phase does not reach `passed` because the 05-REVIEW findings (8 warnings, 3 info, all still `open` in 05-REVIEW-DISPOSITION.md) describe shipped text that is broader than its cited page, or examples that compile but contradict the rule beside them. I checked six of them against the live pages and each is real. They do not fail a roadmap criterion as worded, but they cut against the project's core value ("every BBj claim and code example is correct"), so a maintainer must fix or accept them before Phase 6 ships 0.2.0.

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1: The claim ledger covers the skill and its references; DWC DOM and CSS claims remain only with a docs URL or a recorded owner reproduction; every other such claim is removed | VERIFIED | `ledger_check.py`: 19 gates ok, 242 rows (DOC 106, COMPILE 12, RUNTIME 115, OWNER 9), `ledger_files_covered` ok. `checklist_check.py --recorded`: 11 items, all results recorded. `trace_check.py` over SKILL.md and the 4 references: `trace_tokens` ok (12 dwc- names), `trace_grants` ok (9 OWNER grants, verbatim), `trace_rejected` ok (2 rejected claims, none shipped). 05-CONTEXT.md D-19..D-27 are nine OWNER-confirmed bullets with BBj 26.03 build and DWC build. The O3 and O8 content (`!important` on dwc-frame, null geometry getters) is absent from the shipped files. |
| 2 | SC2: Description is 1,024 characters or fewer with triggers first; body is short; references trimmed; all taste cut | VERIFIED | Description decodes to 669 characters, starts "Write, review, check, or fix BBj code that runs in a browser (DWC or BUI)", lists "Trigger on symptoms" after the topics and points to bbj-programming last. SKILL.md body is 159 lines after the frontmatter, no table row. References are 363 lines (973 before; the plan limit was 500). Case-insensitive grep over the skill directory for GSAP, Swiper, Tabler, Playfair, Google Fonts, fonts.googleapis, 420px, Inter, PT Serif, Roboto Mono, outline, box-shadow, "end of <body>" returns nothing. Four references remain: styling, form-validation, running-dwc-apps, shoelace; the four deleted ones are named nowhere under plugins/, docs/, codex/ or README.md. |
| 3 | SC3: The `injectStyle` `top` claim states the documented meaning (the top-level window) | VERIFIED | SKILL.md:25 quotes "A boolean value specifying whether this CSS is to be injected into the top level window of the page." and cites BBjBuiManager_injectStyle.htm. I fetched that page: the `top` parameter row says exactly this. `injectLinkUrl` is separated out with its own head (1) / body (0) meaning, matching the fetched page. No head, body, placement or cascade claim is made for injectStyle. |
| 4 | SC4: Every `bbj` block passes the live gate, the structure lints pass, and the skill is still invoked as `/bbj:bbj-web-programming` | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exit 0 on this machine with `/opt/bbx/bin/bbjcpl` and bbj-ls at 127.0.0.1:5009: 23 bbj blocks pass on both routes, 9 should-fail blocks fail as intended, `skills_ratchet_bbj-web-programming_{grammar,structure,bbjcpl,bbj-ls,should-fail}` all "0 violations", `skills_pending_keys` "pending: none". `tests/skills_baseline.json` is `pending: {}`, `nocheck: 0`, `bbj_version: 26.03`. `probes/run.py --check`: 29 probes reproduce, canary ok. `tests/test_check_order.py` exit 0 (block identical in 3 places). SKILL.md line 2 is `name: "bbj-web-programming"`; `plugins/bbj/.claude-plugin/plugin.json` has not changed in this phase (last commit 97b146a, Phase 1). |
| 5 | Core value carried into the phase: each shipped DWC claim and example is stated no broader than its source and does not contradict itself | UNCERTAIN | Six review findings confirmed against fetched pages (see Review Findings below). Examples compile but mislead (WR-01, WR-03); claims exceed their page (WR-06, WR-08); an owner-granted sentence says "the documentation does not state it" where the page states a different range (WR-04). Not a failure of a stated roadmap criterion, so routed to a human decision rather than gaps_found. |

**Score:** 4/5 truths verified (0 present, behavior-unverified)

### Deferred Items

None. Later phase 6 is the release (versions, changelog, tag) and does not cover these content fixes.

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/skills/bbj-web-programming/SKILL.md` | Trigger-first, short, check-order block intact | VERIFIED | 163 lines in all, 669-character description, check-order block byte-identical, `## References` last. |
| `references/styling.md` | Themes, attributes, shadow parts, focus ring | VERIFIED | 148 lines, `## Sources` and "Verified on BBj 26.03" line present; no outline or box-shadow word. See WR-05. |
| `references/form-validation.md` | Accept rule, precedence, never trust client | VERIFIED | 59 lines, p12 program. See WR-01, WR-06. |
| `references/running-dwc-apps.md` | Registration, URL shape, browser-only | VERIFIED | 70 lines, q04 program. See WR-02, IN-02. |
| `references/shoelace.md` | Module by URL, BBjWebComponent usage | VERIFIED | 86 lines, p13/p16/q01. See WR-03, WR-08. |
| `05-LEDGER.md`, `05-OWNER-CHECKLIST.md`, `probes/`, `owner-repros/`, `05-DOCS-PROPOSAL.md` | Planning evidence | VERIFIED | All present; the four checkers pass. |
| Deleted: color-chooser, responsive-layout, shadow-dom-styling, themes | Removed per Totals "Deleted" line | VERIFIED | Directory holds exactly the four destinations. |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| SKILL.md `## References` | the four reference files | index bullets | WIRED | All four names exist. |
| form-validation.md / running-dwc-apps.md | bbj-programming/references/callback-performance.md, running.md | path pointers | WIRED | Both targets exist. |
| OWNER ledger rows | shipped sentences | trace_check `trace_grants` | WIRED | 9 of 9 verbatim with the maintainer wording. |
| tests/skills_baseline.json | live gate | `--report` | WIRED | `pending` empty; ratchet gates all "0 violations". |

### Data-Flow Trace (Level 4)

Not applicable: Markdown content and a baseline file, no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Live gate on every bbj block | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | exit 0; 23 pass, 0 fail, 9 should-fail | PASS |
| Probes reproduce | `python3 -I .../probes/run.py --check` | `probes_reproduce ok 29 probes` | PASS |
| Ledger | `python3 -I .../ledger_check.py` | 19 gates ok | PASS |
| Owner checklist recorded | `python3 -I .../checklist_check.py --recorded` | 5 gates ok | PASS |
| Trace of tokens, grants, rejected claims | `python3 -I .../trace_check.py SKILL.md references/*.md` | 3 gates ok | PASS |
| Check-order block | `python3 -I tests/test_check_order.py` | exit 0, 10 gates ok | PASS |

I did not re-run the whole `tests/run.sh` suite; the orchestrator reports ok=700 with one known flake (`real_home_untouched`, a concurrent Codex process).

### Probe Execution

The phase's own probes (`probes/run.py --check`) are listed above and pass. No `scripts/*/tests/probe-*.sh` applies to this phase.

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
| ----------- | ------------ | ----------- | ------ | -------- |
| WEB-01 | 05-01, 02, 03, 04, 05, 07, 08, 09, 10 | Ledger covers skill and references; DWC DOM/CSS claims survive only with a docs URL or owner reproduction recorded with the build | SATISFIED | Truth 1. Caveat: WR-06/WR-08 wording drift (truth 5). |
| WEB-02 | 05-02, 03, 06, 07, 08, 10 | Description ≤ 1,024 with triggers first; body short; references trimmed; taste cut | SATISFIED | Truth 2. |
| WEB-03 | 05-02, 06, 08, 09, 10 | `injectStyle` top corrected; every `bbj` block passes the gate; name unchanged | SATISFIED | Truths 3 and 4. |

No orphaned requirements: REQUIREMENTS.md maps only WEB-01, WEB-02, WEB-03 to Phase 5, and every plan declares a subset of these.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| (all shipped skill files) | - | TBD / FIXME / XXX / TODO / HACK / placeholder scan | none | Debt-marker gate clear; the grep over the skill directory for taste words and markers found no match. |
| references/form-validation.md | 39-51 | Example contradicts the file's own precedence rule (WR-01) | Warning | Compiles; teaches a dead validator. |
| references/shoelace.md | 36-51 | One `icon!` moved to two parents, then `setHtml` on a card with slotted children (WR-03) | Warning | Compiles; sequence cannot all take effect. |

### Review Findings Checked Against the Sources

I fetched the cited pages and compared:

- **WR-01** confirmed from the shipped file itself: line 15-17 states "built-in validation will always be used", while the example sets both on one `BBjEditBox`.
- **WR-03** confirmed: BBjControl_setSlot.htm says the method "moves a child BBjControl into a parent BBjControl", so the second `setSlot` undoes the first.
- **WR-04** confirmed: dwc.style BBjColorChooser lists `saturation` as "The saturation value, which ranges 0 to 100." The shipped D-26 sentence says 0 to 1.0 and "the documentation does not state it". The conflict is recorded in 05-LEDGER.md L097 and in 05-DOCS-PROPOSAL.md, but a reader of the skill does not see it.
- **WR-05** confirmed: the themes guide says "The method accepts the name of any built-in or custom theme" and has an "Activate a new theme by name" step; styling.md has neither.
- **WR-06** confirmed: the "closest `BBjWindow`" note sits under "Validation customization" and refers to "these attributes"; the shipped bullet states it as a general rule. Ledger L116 had the narrower "Validation attributes" wording.
- **WR-07** confirmed: the attributes-and-properties guide gives conditions (`setProperty` for `Reflects: No` or non-string values); SKILL.md:80 reduces this to an unconditional order.
- **WR-08** confirmed: DWC_Registration_Launching.htm says "This html file should be saved to the htdocs directory ... accessed with a URL in the format http://localhost:8888/files/myhtml.html". Ledger L062 decided to "rewrite (SKILL.md) to the page sentence"; the shipped bullet drops "html" and the block extends it to `/files/lib/shoelace/shoelace.js` and `/files/app.css`.
- **WR-02** (the `ssl` boolean) not independently re-fetched; it follows the review's reading of the Javadoc signature.

None of these makes the phase goal false: the quoted sentences are present verbatim, and the OWNER sentences carry the maintainer wording. The gap is that the surrounding framing or the example is wider than the source, which the ledger had already ruled narrower in two cases (L062, L116).

### Human Verification Required

#### 1. Fix or accept WR-01 and WR-03 (misleading examples)

**Test:** Edit the two examples so each demonstrates one coherent thing, then re-run the live gate.
**Expected:** No example shows a combination that the same file or the cited page says cannot work.
**Why human:** The gate checks syntax and types, not meaning; deciding to fix now or in a later release is a maintainer call.

#### 2. Fix or accept WR-04 and WR-08 (wording broader than or hiding a conflict with the page)

**Test:** Restate the `/files/` bullet as the page does and mark the nested script/style paths as an example; decide with the owner whether D-26 gets a conflict note.
**Expected:** The skill's claim set equals what ledger L062 and L097 decided.
**Why human:** D-26 is an owner-granted sentence; changes next to it need the owner.

#### 3. Fix or accept WR-02, WR-05, WR-06, WR-07

**Test:** Add the missing condition or sentence in each file as listed in the frontmatter.
**Expected:** Each rule carries the conditions its source gives.
**Why human:** Completeness judgments against the source pages.

#### 4. Disposition all 11 review findings

**Test:** Update 05-REVIEW-DISPOSITION.md (every row is `open`).
**Expected:** Each finding is fixed, accepted or rejected with a reason.
**Why human:** Dispositions are a maintainer decision.

### Gaps Summary

No roadmap success criterion fails. The skill is short and trigger-first (669-character description, 159-line body, 363 lines of references), every taste item is gone, the injectStyle `top` claim matches the fetched page, the 23 bbj blocks pass bbjcpl and bbj-ls live with 9 should-fail blocks failing as designed, and each DOM/CSS claim that remains is an owner-confirmed grant (D-19..D-27) or carries a docs quote. Status is `human_needed` rather than `passed` because the review's eight warnings are all still open and six I re-checked are accurate; two of them (WR-06, WR-08) show shipped text drifting from what the claim ledger itself decided. If the maintainer prefers to treat them as release blockers, the fixes are small and local to four reference files plus SKILL.md lines 28, 79-80 and 86.

---

_Verified: 2026-10-12T12:00:00Z_
_Verifier: Claude (gsd-verifier)_
