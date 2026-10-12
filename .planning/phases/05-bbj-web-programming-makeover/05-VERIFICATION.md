---
phase: 05-bbj-web-programming-makeover
verified: 2026-10-12T13:30:00Z
status: passed
score: 5/5 must-haves verified
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
covered_digest: "v3:sha256:6aac879b49f08078c8d80512e23c1af0f9d2c67bdfec2d1d47876cfa150ccb69"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 4/5
  gaps_closed:
    - "Truth 5: each shipped DWC claim and example is stated no broader than its source and does not contradict itself (WR-01..WR-08, IN-01..IN-03 all fixed in e20800a..e1744e1)"
  gaps_remaining: []
  regressions: []
---

# Phase 5: bbj-web-programming makeover Verification Report

**Phase Goal:** An agent using `/bbj:bbj-web-programming` gets a short, trigger-first skill whose DWC claims are each documented or reproduced and whose code blocks all pass the gate
**Verified:** 2026-10-12T13:30:00Z
**Status:** passed
**Re-verification:** Yes, after the 11 code-review findings were fixed (commits e20800a..e1744e1, D-28 and D-29), refreshed after commit 9444b16

## Goal Achievement

Refresh after commit 9444b16: the only change since the last `passed` report is one reworded bullet in `form-validation.md` ("The note sits in the guide's section ..." became "The guide's section "Validation customization" lists the attributes ... and there the guide says: ..."). The quoted guide sentence ("It is also possible to set theses attributes on the closest BBjWindow ... prefixed with data-") and the closing sentence ("The guide does not say the built-in rule attributes can be set this way.") are byte-identical to the WR-06 fix. The new wording names the same section, the same example attribute (`validation-style`) and the same scope, so it adds no claim. It also resolves the earlier observation that "The note" lacked an antecedent. The ledger, trace, live-gate and check-order runs below were repeated after that commit and are green.

The previous report returned `human_needed` only because the 11 review findings were open. All 11 are now fixed, one commit each. I did not rely on the disposition file or the commit messages. For each finding I read the shipped text, then fetched the cited page and compared the changed sentence with it. Every gate was re-run and is green.

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1: Ledger covers the skill and references; DWC DOM and CSS claims remain only with a docs URL or a recorded owner reproduction | VERIFIED | `ledger_check.py` 19 gates ok, 242 rows (DOC 106, COMPILE 12, RUNTIME 115, OWNER 9). `checklist_check.py --recorded` 5 gates ok (11 items recorded). `trace_check.py` over SKILL.md and the 4 references: `trace_tokens` ok (13 dwc- names, was 12: the added `--dwc-color-primary-seed` is on the themes guide), `trace_grants` ok (9 OWNER grants verbatim), `trace_rejected` ok. I also checked D-19..D-27 independently against the shipped files: every granted sentence is present unchanged. |
| 2 | SC2: Description is 1,024 characters or fewer with triggers first; body short; references trimmed; taste cut | VERIFIED | Description unchanged at 669 characters and begins "Write, review, check, or fix BBj code that runs in a browser (DWC or BUI)". SKILL.md is 164 lines in all (+1 from the fixes). References are 386 lines in total (was 363; the plan limit was 500). Case-insensitive grep over the skill directory for GSAP, Swiper, Tabler, Playfair, googleapis, 420px, box-shadow and outline finds nothing. Four references remain. |
| 3 | SC3: The `injectStyle` `top` claim states the documented meaning (the top-level window) | VERIFIED | SKILL.md:25 still quotes "A boolean value specifying whether this CSS is to be injected into the top level window of the page." with `injectLinkUrl` kept separate. The fixes did not touch these bullets. |
| 4 | SC4: Every `bbj` block passes the live gate, structure lints pass, skill still invoked as `/bbj:bbj-web-programming` | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exit 0: `skills_total_bbjcpl` and `skills_total_bbj-ls` both "23 bbj blocks: 23 pass, 0 fail; 9 should-fail blocks". All five `skills_ratchet_bbj-web-programming_*` gates "0 violations". `skills_pending_keys` "pending: none". The two edited blocks (form-validation, shoelace) and the rewritten running-dwc-apps block are among the 23. `tests/test_check_order.py`, `tests/test_layout.py` and `tests/test_never_execute.sh` all exit 0 (never-execute: `call_count` calls=3, `sentinel_final` ok). SKILL.md `name:` unchanged. |
| 5 | Core value carried into the phase: each shipped DWC claim and example is stated no broader than its source and does not contradict itself | VERIFIED | All 11 review fixes confirmed below against the fetched pages. No fix adds a claim that is not a quote of a cited page, a ledger row's decided wording, or the owner's D-29 wording. |

**Score:** 5/5 truths verified (0 present, behavior-unverified)

### Review Findings: fix checked against the shipped file and the source page

| ID | Commit | Shipped fix | Source check | Result |
| -- | ------ | ----------- | ------------ | ------ |
| WR-01 | e20800a | `form-validation.md`: the `required` line is removed from the example; the caption now says the expression is the validation that runs on a control without a built-in attribute, "a control with both uses only the built-in one, as above". | The guide (dwc.style form-validation, Note under "Different types of client-side validation") says built-in validation always wins. The example no longer contradicts the rule at lines 15-17. The `"true"` value that no page gave is gone. | FIXED |
| WR-02 | 647e4c0 | `running-dwc-apps.md`: names the boolean `ssl` argument of `getDwcUrl(ssl)` and `getBuiUrl(ssl)`, says the page "does not describe the argument further", cites the class sample `getBuiUrl(false)`. The example uses `sslFlag = 0` and checks `url! = null()`. | Javadoc BBjAdminAppDeploymentApplication: `String getDwcUrl (boolean ssl)`, `String getBuiUrl (boolean ssl)`, sample `app.getBuiUrl(false)`, "returns null if the DWC_ENABLED property is set to false". The fix does not assert what 0 and 1 mean, which keeps it inside the page. | FIXED |
| WR-03 | e5326a7 | `shoelace.md`: one `sl-icon` per parent (`icon!` to the card, `copyIcon!` to the button prefix); `setHtml` moved to a separate `sl-badge`. Prose: `setSlot` "moves" the child. | BBjControl_setSlot: "this method moves a child BBjControl into a parent BBjControl". The block compiles on both routes. | FIXED |
| WR-04 | d8957ec | `SKILL.md:86`: the D-26 sentence is verbatim; the sentence "the documentation does not state it" is replaced by "the BBjColorChooser page (...) gives 0 to 100 for saturation, a conflict reported to the documentation owners". | The dwc.style BBjColorChooser page lists "The saturation value, which ranges 0 to 100." The wording is the one D-29 prescribes. `05-DOCS-PROPOSAL.md` carries the conflict under "Conflicts between pages" (L097). | FIXED |
| WR-05 | bf97b75 | `styling.md`: adds "The method accepts the name of any built-in or custom theme." and "Activate a new theme by name:" with `web!.setTheme("brand")`, then `web!.setTheme("brand-dark")` for the block shown; the `brand-dark` block gains `--dwc-color-primary-seed: #a855f7;`. | The dwc.style themes guide contains both sentences, the `setTheme("brand")` example and the identical `brand-dark` block with that token line. The `brand-dark` call applies the page's rule that the theme name is the `data-app-theme` value. | FIXED |
| WR-06 | 16ed9da | `form-validation.md`: the note is scoped to the "Validation customization" section and its attributes (for example `validation-style`), and says "The guide does not say the built-in rule attributes can be set this way." | The guide's section "Validation customization" opens "a list of attributes which allows the developer to customize the validation behaviour, location, style and message"; the data- note sits in that section; its table holds only customization attributes. | FIXED |
| WR-07 | 89a2a7b | `SKILL.md:79-81`: the order now carries the guide's conditions (setAttribute for documented Properties without a BBj method and with a string or boolean value; setProperty "as a last resort" for `Reflects: No` or non-string values; the reading order). A new bullet says `label` is Reflects: No. | Matches the "Choosing the right channel" list in the attributes-and-properties guide, and "setProperty is the right channel when ... the property is documented as Reflects: No". | FIXED |
| WR-08 | 180ad94 | `SKILL.md:28` quotes the page: "This html file should be saved to the htdocs directory under the basis home directory; it can be accessed with a URL in the format http://localhost:8888/files/myhtml.html", names the section (embedding a DWC app in a custom page), says the page does not state that script, stylesheet or subdirectory files are served at host-relative `/files/...`, so the block paths are examples to confirm. `shoelace.md` repeats the narrower statement. | DWC_Registration_Launching.htm: the sentence is verbatim, in the "DWC Embedded Deployment" section; its only mention of htdocs is that sentence. This is the L062 decision. | FIXED |
| IN-01 | 65dfe61 | `SKILL.md:84`: the D-24 sentence is unchanged; "(The opening tag, written `<html>`.)" follows it. | The granted sentence is byte-identical (`trace_grants` ok). | FIXED |
| IN-02 | 2dcaa33 | `running-dwc-apps.md`: `adminUser$` and `adminPassword$` with a `rem` saying the caller sets them; a note that the block creates a new application on each run and that `getApplications()` lists the existing ones; `browse` has a stated purpose; the closing line now says a DWC app is launched by navigating to its URL in a browser and that running.md covers the `bbj` command line for other programs. | `createApplication()` is "Create a new application definition"; `getApplications()` exists on BBjAdminAppDeploymentConfiguration; DWC_Registration_Launching: "navigate to the corresponding URL". `bbj-programming/references/running.md` exists. | FIXED |
| IN-03 | e1744e1 | `SKILL.md:83`: states that the BASIS page writes `part::label`, that the selector syntax is `::part(label)`, and gives the themes guide example `dwc-button[theme='primary']::part(label)`. | DWC_Labels.htm line: "targeting the part::label of the Shadow DOM"; css-shadow-parts shows `dwc-button::part(label)`; the themes guide shows the quoted selector. | FIXED |

### Deferred Items

None. Phase 6 is the release (versions, changelog, tag) and does not cover content fixes.

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/skills/bbj-web-programming/SKILL.md` | Trigger-first, short, check-order block intact | VERIFIED | 164 lines, 669-character description, `test_check_order.py` ok, `## References` last. |
| `references/styling.md` | Themes, attributes, shadow parts, focus ring | VERIFIED | 154 lines; `## Sources` present; no outline or box-shadow word. |
| `references/form-validation.md` | Accept rule, precedence, never trust client | VERIFIED | 61 lines; example agrees with the precedence rule. |
| `references/running-dwc-apps.md` | Registration, URL shape, browser-only | VERIFIED | 78 lines; example checks the null URL. |
| `references/shoelace.md` | Module by URL, BBjWebComponent usage | VERIFIED | 93 lines; one icon per parent. |
| `05-LEDGER.md`, `05-OWNER-CHECKLIST.md`, `probes/`, `owner-repros/`, `05-DOCS-PROPOSAL.md` | Planning evidence | VERIFIED | Present; the four checkers pass. |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| SKILL.md `## References` | the four reference files | index bullets | WIRED | All four exist. |
| running-dwc-apps.md, form-validation.md | bbj-programming `running.md`, `callback-performance.md` | path pointers | WIRED | Both targets exist. |
| OWNER ledger rows (9) | shipped sentences | `trace_grants` | WIRED | 9 of 9 verbatim. |
| `tests/skills_baseline.json` | live gate | `--report` | WIRED | `pending` empty; ratchet gates "0 violations". |

### Data-Flow Trace (Level 4)

Not applicable: Markdown content and a baseline file, no rendered dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Live gate on every bbj block | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | exit 0; 23 pass, 0 fail, 9 should-fail | PASS |
| Probes reproduce | `python3 -I .../probes/run.py --check` | `probes_reproduce ok 29 probes`, canary ok | PASS |
| Ledger | `python3 -I .../ledger_check.py` | 19 gates ok, 242 rows | PASS |
| Owner checklist recorded | `python3 -I .../checklist_check.py --recorded` | 5 gates ok | PASS |
| Trace tokens, grants, rejected claims | `python3 -I .../trace_check.py SKILL.md references/*.md` | 3 gates ok | PASS |
| Check-order block | `python3 -I tests/test_check_order.py` | exit 0, no FAIL line | PASS |
| Layout | `python3 -I tests/test_layout.py` | exit 0 | PASS |
| Never execute | `sh tests/test_never_execute.sh` | exit 0, `sentinel_final` ok | PASS |

The `FAIL` strings in the live gate output come from `skills_fx_*` fixture gates that assert a failing status; those gates themselves are `ok`. BBj programs were not run. I did not run the whole `tests/run.sh` suite.

### Probe Execution

The phase's own probes (`probes/run.py --check`) pass: 29 probes reproduce. No `scripts/*/tests/probe-*.sh` applies.

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
| ----------- | ------------ | ----------- | ------ | -------- |
| WEB-01 | 05-01, 02, 03, 04, 05, 07, 08, 09, 10 | Ledger covers skill and references; DWC DOM/CSS claims survive only with a docs URL or owner reproduction | SATISFIED | Truth 1 and the review table; the WR-06 and WR-08 drift is closed. |
| WEB-02 | 05-02, 03, 06, 07, 08, 10 | Description ≤ 1,024 with triggers first; body short; references trimmed; taste cut | SATISFIED | Truth 2. |
| WEB-03 | 05-02, 06, 08, 09, 10 | `injectStyle` top corrected; every `bbj` block passes the gate; name unchanged | SATISFIED | Truths 3 and 4. |

Every ID declared in the PLAN frontmatter (WEB-01, WEB-02, WEB-03) appears in REQUIREMENTS.md, marked `[x]` and "Complete" in the traceability table. REQUIREMENTS.md maps no other ID to Phase 5, so there are no orphans.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| (all shipped skill files) | - | TBD / FIXME / XXX / TODO / HACK / placeholder / taste-word scan | none | Debt-marker gate clear. |

Observations, none blocking and none a claim defect:

- `shoelace.md` uses the tag `sl-badge` in the `setHtml` demonstration. It is a tag name in a compiling example, not a DWC DOM or CSS claim; no fetched BASIS page names it (it came from the research probe).
- WR-04 says the conflict was "reported to the documentation owners", the wording D-29 prescribes. `05-DOCS-PROPOSAL.md` records that nothing in it has been sent yet. Sending the proposal is a maintainer action to do around the 0.2.0 release.
- ROADMAP.md still shows the Phase 5 line as `- [ ]`; the orchestrator updates it when it closes the phase.

### Human Verification Required

None. The four human items of the previous report were fix-or-accept decisions on the review findings. D-28 and D-29 decided them (fix all), and the fixes are verified above.

### Gaps Summary

No gaps. The four ROADMAP success criteria hold, the review findings are fixed in the shipped files, and each changed sentence quotes a cited page, a ledger row's decided wording, or the owner-prescribed D-29 wording. OWNER sentences D-19..D-27 are unchanged, and the live gate on bbjcpl and bbj-ls passes for all 23 blocks.

---

_Verified: 2026-10-12T13:30:00Z_
_Verifier: Claude (gsd-verifier)_
