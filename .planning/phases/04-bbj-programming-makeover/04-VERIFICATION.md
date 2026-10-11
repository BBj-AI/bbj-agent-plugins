---
phase: 04-bbj-programming-makeover
verified: 2026-10-11T12:00:00Z
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
  - "codex/AGENTS-snippet.md"
  - "plugins/bbj/skills/bbj-programming/SKILL.md"
  - "plugins/bbj/skills/bbj-programming/references/callback-performance.md"
  - "plugins/bbj/skills/bbj-programming/references/database.md"
  - "plugins/bbj/skills/bbj-programming/references/running.md"
  - "plugins/bbj/skills/bbj-programming/references/sysgui.md"
  - "tests/skills_baseline.json"
covered_digest: "v3:sha256:8eefe60205920d8d3a71c4ead8b56c552e9fa1a0bded80b091abbf3e3027806d"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 5/6
  gaps_closed:
    - "SKILL.md intro provenance statement (false 'checked with bbjcpl and bbj-ls', 'only ... the documentation do not state') replaced; STR() item removed from the primer pointer; stderr rule carries the '-t -N -X and no -W' condition"
    - "sysgui.md states the Dialog flag only as the addWindow page does; setModal stated by route; clickable-image rule and example fixed (image control added)"
    - "database.md getJDBCConnection(url) with the documented meaning of url and ChileCompany; SQL function pages scoped to a BBj database; placeholders marked; intro corrected"
    - "running.md END/STOP with the page's condition and no 'stays open' inference; RELEASE rollback note; Sources footer names what was checked and the owner-confirmed -tIO fact"
    - "Ledger rows L076, L088, L089, L093, L117, L118, L138 match the shipped text (ledger_check.py 17 ok gates, exactly two OWNER rows)"
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "Triage the seven open warnings in 04-REVIEW.md (WR-01 to WR-07) and decide fix-now or accept. Verifier recommends fixing WR-07 ('At run time' is a timing qualifier the cited !ERROR=26 page does not state) and IN-07 (the flat 'ends with RELEASE' instruction), and hardening the two JDBC examples (WR-05: 'select 1' read as column COL, connection never closed) and the clickable-image callback (WR-01: no null guard on getOriginalControl()). WR-02, WR-03, WR-04, WR-06 are accuracy-neutral omissions or already-decided items."
    expected: "Each finding has a disposition (fixed, skipped, deferred) in 04-REVIEW-DISPOSITION.md; none is a regression of the closed gap items"
    why_human: "Disposition is an owner decision; the verifier confirmed each finding against the fetched pages but found none that falsifies the roadmap success criteria, so none is a gap"
  - test: "Accept or reject the flagged judgment- and test-tier prohibitions of plan 04-07 (see 'Judgment-tier prohibitions')"
    expected: "Owner confirms: sysgui.md does not imply the Dialog flag is modal; running.md leaves the -tIO line unhedged (D-22); no changed sentence states an absence or an exhaustive claim beyond its page"
    why_human: "Prohibitions with verification 'judgment' get a non-authoritative LLM-judge verdict; the two test-tier ones (Dialog/modality, -tIO unhedged) have no wired automated test in the repository (only the OWNER-count prohibition is enforced, by ledger_check.py gate ledger_owner), so they stay flagged as unverified-prohibition even though a read of the files finds them satisfied"
  - test: "Confirm that the real_home_untouched failure seen in the live and the default view is an environmental flake and decide whether to harden the gate in a later phase"
    expected: "Owner accepts that tests/test_install_codex.sh (Phase 1 code, untouched by Phase 4) races a local Codex app-server daemon, not a defect of this phase"
    why_human: "The verifier reproduced the failure with the daemon running and showed the daemon writes under ~/.codex with no test running; whether to change the gate (hash owned files, or ignore the daemon's) is a scope decision"
---

# Phase 4: bbj-programming makeover Verification Report

**Phase Goal:** An agent using `/bbj:bbj-programming` gets only verified rules: the check workflow first, a short body, every claim documented or reproduced, and every code block passing the gate
**Verified:** 2026-10-11
**Status:** human_needed
**Re-verification:** Yes, after gap closure plan 04-07

## Goal Achievement

The four gap items from the previous report are closed in the shipped files, not only in the SUMMARY. I re-read all five skill files, re-fetched the cited pages from documentation.basis.cloud, diffed the JDBC blocks against the probes, and re-ran the ledger, probe, check-order and live example gates. Nothing that passed before has regressed. No automated check fails. What remains are seven open review warnings that I confirmed against the pages but judge to be hardening items, plus three flagged prohibitions and one environmental test flake that need an owner's word, so the status is `human_needed`, not `gaps_found`.

### Closure of the previous gap items (each checked in the shipped file)

| Previous `gaps[0].missing` item | Shipped state | Evidence |
| --- | --- | --- |
| SKILL.md intro: "most rules reproduced, others cite the page, sign-mask owner-confirmed; drop 'only ... do not state'" | CLOSED | `SKILL.md:18-20`: "Most rules here were reproduced with `bbjcpl` and `bbj-ls` on BBj 26.03. The others cite the documentation page that states them, except the `str()` sign rule, which the project owner confirmed on BBj 26.03." Section 2 heading is now `## Rules for writing BBj`. |
| SKILL.md L143 STR() item; L26 stderr condition | CLOSED | "Look it up instead" first bullet lists ternary/IFF, FOR loop, NUM vs INT, DECLARE AUTO, reserved words, precision; no STR(). L26: "with `-t -N -X` and no `-W`, any stderr line is a finding". |
| sysgui.md: state only "behave as a dialog"; fix clickable-image rule and example | CLOSED | `sysgui.md:10` quotes the page's Dialog sentence only (re-fetched: "$00080000$ Dialog : Sets the window to behave as a dialog."; `setModal` has 0 hits on the page). L12-14 names MDI Desktop Modal and MDI Group Modal as flags the page also lists (both present on the page) and states the `setModal(1)` result by route (matches `probes/OUTPUT.txt` s01: bbjcpl type-check error, bbj-ls clean) without saying the method is absent. L52-60 rule says an image reports clicks without `setReportAllMouseEvents(1)`; the example now creates `addImageCtrl` and compares `getOriginalControl().getID()` with it. |
| database.md: `getJDBCConnection(url)` with documented meaning; scope the SQL function pages; mark placeholders; fix intro | CLOSED | L107-111 quote the page's `url` text and "including case" (verbatim against the fetched page); both blocks use `ChileCompany`, the page's own example; I diffed the fenced blocks against `probes/d03_jdbc_undecl.bbj` and `d01_jdbc.bbj`: equal after the one literal. L182-183 "For a BBj database ... 'supported by the BASIS DBMS'; for a third-party database ..." replaces "only the functions they list". L154 names URL, table and column as placeholders. Intro L101-103 says Java sample for JDBC, BBj sample for the SQL verbs (matches the How-To page: Java `DriverManager` and BBj `SQLOPEN` samples). |
| running.md: footer, END/STOP condition, no inference, RELEASE rollback | CLOSED | L230 "When not in a public program, `END` and `STOP` place PRO/5 in 'console mode'" (END page re-fetched: same condition, same words; no "stays open"). L228-229 and L233-234 carry the RELEASE rollback and "so commit first" (BBj RELEASE page: "also rolls back all uncommitted transactions"). Footer L249-251 names the pages checked, "nothing was run", and "Verified on BBj 26.03 by the project owner: `bbj -tIO` ...". |
| Ledger rows L117 and L089 match what ships | CLOSED | L117 is now class RUNTIME, rewrite; L089 quotes the `url` parameter and the d01/d03 literal-only claim (true, diffed). `ledger_check.py`: 17 gates ok, `ledger_owner ok 2 OWNER rows`, totals line `DOC 52, COMPILE 39, RUNTIME 57, OWNER 2; keep 20, rewrite 17, drop 106, fold 7`. |

### Observable Truths

| #   | Truth | Status | Evidence |
| --- | ----- | ------ | -------- |
| 1 | SC1 / PROG-01: a claim ledger classifies every claim as DOC, COMPILE or RUNTIME (plus OWNER); no RUNTIME claim survives unless rewritten | VERIFIED | `ledger_check.py` re-run: 17 gates ok including `ledger_runtime`, `ledger_owner` (exactly L031, L072), `ledger_compile_probe`, `ledger_doc_url`. `probes/run.py --check`: `probes_canary ok`, `probes_reproduce ok 74 probes`. L117 reclassified DOC to RUNTIME so the ledger no longer claims a page states modality. |
| 2 | SC2 / PROG-02: SKILL.md opens with the check workflow, body about 150 lines or fewer, points to docs tools and `bbj://primer` | VERIFIED | `SKILL.md` is 153 lines (4 frontmatter + 149 body); `bbj-check-order` block directly after frontmatter; 0 table rows; "Look it up instead" names `bbj://primer`, `bbj_lookup`, `bbj_reserved_word`, `bbj_examples`, `bbj_search`, `bbj_fetch_page`. `tests/test_check_order.py`: all `checkorder_*` gates ok, copies identical. |
| 3 | SC3 / PROG-03: primer-gap rules stated correctly (bare calls, Built-in scope, `bbjcpl -t -N -X` quirks, REM/`;`) | VERIFIED | Rules and probes unchanged from the first verification (74 probes reproduce). Built-in paragraph `SKILL.md:79` equals `codex/AGENTS-snippet.md:21` (diffed). The stale STR() primer item (IN-03 of the first review) is gone. Residual: IN-04 (the REM page states only "In compound statements, REM may only be the last verb"; the `;` and label rules rest on probes t03-t05, which the intro's "most rules were reproduced" covers). |
| 4 | SC4 / PROG-04, PROG-05: known wrong claims corrected, taste and leftovers gone, launcher facts only where verified and framed for "user asks to run" | VERIFIED | grep over skill, snippet, docs and README for `PRECISION 16`, `DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin`, `nocheck`, `vendored`, `java-interop`, `reserved-words.md`: no hits. `running.md:3-4`: "Read this file only when the user asks to run a BBj program ... Do not run a program on your own initiative." `LIMIT (first, count)`, `str(rate:"-##0.00")`, bbjcpl stderr/exit 0, `use java.util.HashMap` all present. |
| 5 | SC5 / PROG-06: every `bbj` block passes the live gate on both routes; skill name unchanged | VERIFIED | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` exit 0: `skills_route_bbjcpl ok /opt/bbx/bin/bbjcpl: 57 file(s)`, `skills_route_bbj-ls ok http://127.0.0.1:5009/mcp: 55 call(s)`, all five `skills_ratchet_bbj-programming_*` gates `ok 0 violations`; no gate FAIL line; only `bbj-web-programming` lines are `skip pending (Phase 5)`. `tests/skills_baseline.json` unchanged by 04-07 (`git diff HEAD` empty): pending only `bbj-web-programming`, `nocheck` 0. `name: "bbj-programming"`, description 732 characters including the key (limit 1,024). `git diff d61265c HEAD -- plugins/bbj/.claude-plugin` empty. |
| 6 | Goal / core value: every claim and rule the skill and its references hand an agent is documented (URL) or reproduced; nothing is stated beyond its evidence | VERIFIED (with warnings) | The four overreaches that failed this truth in the first round are corrected and checked against the fetched pages (see closure table). I read every other changed sentence of 04-07 against its page: Dialog/MDI flag entries, `setReportAllMouseEvents` and `getOriginalControl` quotes, `getJDBCConnection` quote, END, RELEASE, bbjcpl `-P`/`-c` "not both" ("The -c option must not be used with the -P option"), the sign characters (`CR`, `DR`, minus) on the numeric output page: all match. Residual statements that go slightly beyond a page are listed under Anti-Patterns as warnings; none changes a rule the agent follows and none is covered by a deterministic failing check, so they do not fail this truth. They need an owner disposition (human item 1). |

**Score:** 6/6 truths verified (0 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `plugins/bbj/skills/bbj-programming/SKILL.md` | rewritten skill, provenance correct | VERIFIED | 153 lines; intro corrected; contains "reproduced with" |
| `.../references/sysgui.md` | Dialog flag as documented; image example with image control | VERIFIED | contains `addImageCtrl`; blocks pass both routes |
| `.../references/database.md` | `getJDBCConnection(url)`, scoped function pointer, marked placeholders | VERIFIED | contains `getJDBCConnection(url)`; blocks equal probes |
| `.../references/running.md` | END/STOP condition, RELEASE rollback, honest footer | VERIFIED | contains "by the project owner"; footer line starts `- Verified on BBj 26.03` |
| `.../references/callback-performance.md` | form validation rules | VERIFIED | unchanged since round 1 |
| `04-LEDGER.md`, `ledger_check.py`, `probes/` | 150 rows, 17 gates, 74 probes | VERIFIED | re-run green |
| `04-DOCS-PROPOSAL.md` | L118 bullet as a question to the docs owners | VERIFIED (not audited line by line) | modified in 04-07 |
| `codex/AGENTS-snippet.md`, `tests/skills_baseline.json` | scoped Built-in line; `bbj-programming` off pending | VERIFIED | |
| `java-interop.md`, `reserved-words.md` | deleted | VERIFIED | absent, not referenced |

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | -- | --- | ------ | ------- |
| SKILL.md intro | ledger L031 (OWNER) | "the project owner confirmed on BBj 26.03" | WIRED | pattern present at L20 |
| running.md footer | ledger L072 (OWNER) | "Verified on BBj 26.03 by the project owner" | WIRED | L251 |
| database.md JDBC blocks | probes d01, d03 | literal-only difference | WIRED | diffed, both True |
| ledger Totals | `ledger_check.py` gate `ledger_totals` | same line | WIRED | gate detail equals the Totals text |
| SKILL.md Built-in line | `codex/AGENTS-snippet.md:21` | byte-identical | WIRED | `diff` empty; no test pins it (IN-07 of the first review, still open as a suggestion) |
| SKILL.md check block | `tests/test_check_order.py` | markers | WIRED | all gates ok |

### Data-Flow Trace (Level 4)

Not applicable: Markdown, a JSON baseline and planning artifacts; nothing renders dynamic data.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| Skill blocks pass both routes, ratchet 0 | `BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py` | rc 0; 5 ratchet gates `ok 0 violations`; no FAIL | PASS |
| Probes reproduce | `python3 -I probes/run.py --check` | `probes_canary ok`, `probes_reproduce ok 74 probes` | PASS |
| Ledger | `python3 -I ledger_check.py` | 17 ok gates | PASS |
| Check-order block | `python3 -I tests/test_check_order.py` | all ok | PASS |
| JDBC blocks equal probes | python diff of fences vs `d01`, `d03` after the literal | True, True | PASS |
| Whole suite | `sh tests/run.sh` (default view, run once) | `SUMMARY: ok=701 fail=1 skip=55`; sole FAIL `real_home_untouched` | See next section |

No BBj was executed; only `bbjcpl -t -N -X` and the loopback `bbj-ls` ran, through the existing gates.

### The `real_home_untouched` failure: environmental, not a defect of this phase

Judgment: environmental flake. Evidence I produced myself:

- The gate (`tests/test_install_codex.sh:1520-1521`) runs `find ~/.codex ~/.agents -newer "$WORK/marker"` and fails on any file newer than the marker. It does not compare content and does not know who wrote the file.
- A Codex app-server daemon runs on this machine (`codex app-server --listen unix://`, `daemon pid-update-loop`, pids from Oct 10). With no test running, I created a marker and waited 45 seconds: `find` listed `.codex/logs_2.sqlite-shm` as changed. Earlier, `.codex/models_cache.json`, `.codex/app-server-daemon/daemon-updater.stderr.log`, `.codex/packages/app-server-daemon/auto-update-version` and a new `.codex/tmp/arg0/codex-arg0*` directory were all written at 11:42:50, before my test re-run began.
- My own full-suite run failed with a different path (`.codex/packages/app-server-daemon`) than the executor's (`logs_2.sqlite-wal`, `models_cache.json`, `logs_2.sqlite-shm`), and the executor's rerun passed. Different file each time is the signature of a race with an external writer. The test's own invocations of the real `codex` set `HOME` and `CODEX_HOME` to temporary directories (`test_install_codex.sh:69,115`).
- Phase 4 changed no test, installer or hook file (`git diff bda781c HEAD --stat -- plugins codex tests` shows only the four skill Markdown files).

So it does not block Phase 4. It does mean `sh tests/run.sh` is not reliably green on a machine with a running Codex daemon; the orchestrator's `ok=702 fail=0` and my `ok=701 fail=1` differ only by that gate. CI runners have no such daemon. The executor correctly refused to report the live view as clean. Hardening the gate (compare content hashes of files the installer owns, or exclude the daemon's paths) belongs in a later phase or a quick task; I did not touch it. Human item 3 asks for that acceptance.

### Probe Execution

Phase-declared probe `.planning/phases/04-bbj-programming-makeover/probes/run.py --check`: PASS (above). No `scripts/*/tests/probe-*.sh` is declared by this phase.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ----------- | ----------- | ------ | -------- |
| PROG-01 | 04-01, 04-02, 04-07 | Claim ledger classifies every claim | SATISFIED | truth 1; L117 and L089 now match what ships |
| PROG-02 | 04-03 | Check workflow first, about 150 lines, pointers | SATISFIED | truth 2 |
| PROG-03 | 04-03, 04-07 | Primer-gap rules incl. bare calls, Built-in scope, quirks, REM rule | SATISFIED | truth 3; intro sentence now true |
| PROG-04 | 04-03, 04-06, 04-07 | Wrong claims corrected, taste and leftovers cut | SATISFIED | truth 4 |
| PROG-05 | 04-05, 04-07 | Launcher facts only where verified, framed for "user asks to run" | SATISFIED | truth 4; END/STOP condition, footer fixed |
| PROG-06 | 04-03, 04-05, 04-06, 04-07 | Every `bbj` block passes the gate; name unchanged | SATISFIED | truth 5 |

All six IDs appear in the plans' `requirements` frontmatter (04-07 lists all six) and in REQUIREMENTS.md, where all six are checked off with traceability "Phase 4 / Complete". REQUIREMENTS.md maps no other ID to Phase 4: no orphans.

### Anti-Patterns Found

Debt-marker scan (`TBD`, `FIXME`, `XXX`, `TODO`, `HACK`, `PLACEHOLDER`) over the skill directory: no hits. No blockers.

Post-gap review (0 critical, 7 warning, 7 info, all `open`), each weighed against the fetched pages:

| File | Line | Finding | Severity here | Reasoning |
| ---- | ---- | ------- | ------------- | --------- |
| `SKILL.md` | 98-99 | WR-07: "At run time the same defect is !ERROR=26" | WARNING | Confirmed: the `_error_26.htm` page lists the BBj cases after both an "Execution Errors" and a "Compiler Errors" list and never says when they occur. Decision D-12 allowed the `!ERROR=26` wording when a docs source turned up, and the page does list this defect as a cause; "At run time" is the unsupported qualifier. One-phrase fix. |
| `references/running.md` | 30-31 (233) | IN-07: "A program that is run from a shell for the user ends with `RELEASE`" | WARNING | Instruction derived from RELEASE returning control to the OS; no page says it. Now linked to the rollback note, which the first gap asked for. Label as advice or hedge with "usually". |
| `references/sysgui.md` | 74-80 (76-77) | WR-01: `getOriginalControl()` result dereferenced unguarded | WARNING | Page defines the result for a click on a control only. Example is compile-checked and makes no claim about the window-click case; it could fail at run time. |
| `references/database.md` | 17-42 | WR-05: `select 1` read as column `COL`; `conn!` never closed | WARNING | Both blocks equal the probes; page notes the connection is a collapsing license connection. Example hygiene, not a claim. |
| `references/running.md` | 35-37 (238-240) | WR-06: `-tIO` body quotes the PRO/5 IO-device sentence and omits the page's "not a terminal ... will not translate mnemonics" caveat | WARNING | The body labels the quote as the PRO/5 page and the fact is owner-confirmed (D-22, unhedged by decision). Page caveat re-fetched and present. |
| `references/callback-performance.md`, `SKILL.md` | 9-11 / 152 | WR-02: "there is no reject method" | WARNING (weak) | Cited evidence is the `accept` page plus bbjcpl's rejection, as the review says. But the `BBjFormValidationEvent` page I fetched lists every method of the event (`accept`, `getButton`, ..., no `reject`) and its Remarks say the window is unlocked by "calling accept(0) or accept(1)". So the claim is document-backed; cite the methods page to close it. |
| `SKILL.md` | 31 | WR-03: `-P<dir1:dir2>` colon only | WARNING | Page: "separated by semicolons on Windows environments or by colons on UNIX-like environments". Omission, not a false statement. |
| `references/database.md` | 56-57 (154-155) | WR-04: `MODE="USER=..."` (How-To) vs `UID=` (SQLOPEN) | WARNING | Shipped text accurately says "The How-To sample passes ..."; the two pages differ and the file does not say which to use. |
| `references/sysgui.md` | 10 | "The flags add up" | INFO | The page combines flags with `ior()`; `$00080010$` is the same value, and probe s02 compiles it. |
| `sysgui.md`, `database.md`, `SKILL.md` | various | IN-01, IN-02, IN-03, IN-04, IN-05, IN-06 of the review | INFO | `bash` fence on a non-command, missing lead-in before the Dialog block, JDBC overloads, REM page does not state `;`, "project owner" wording, PRO/5 numeric page. |

I did not find a statement of the kind that failed in round one (an implied modality, an unsourced absolute, a dropped condition, a false provenance line). None of the seven warnings makes an agent follow a wrong rule.

### Judgment-tier prohibitions

Verdicts are non-authoritative; each carries `unverified-prohibition - human review recommended`.

- 04-07 (test tier) "sysgui.md MUST NOT state or imply that the Dialog flag makes a window modal ... nor call the MDI flags the only modal flags": satisfied by reading (`sysgui.md:10-14`, IN-02 is a presentational adjacency risk). No wired test enforces it. Flagged.
- 04-07 (test tier) "The executor MUST NOT grant OWNER": enforced by `ledger_check.py` gate `ledger_owner` (exactly L031 and L072). Verified, not flagged.
- 04-07 (test tier) "running.md MUST NOT hedge the `bbj -tIO` line": satisfied by reading (L238, plain fact; only the footer names the evidence). No wired test. Flagged.
- 04-07 (judgment) "No step runs BBj or sends skill code to the hosted check": satisfied; only `bbjcpl -t -N -X` and loopback `bbj-ls` ran in the gate; the 04-07 summary shows none other. Flagged as judgment.
- 04-07 (judgment) "No changed sentence may state a BBj fact or exhaustive claim that its cited page or probe does not establish": satisfied for the sentences 04-07 changed, except the warnings in the table above, all of which predate 04-07 or sit in text 04-07 left alone (WR-02, WR-07, IN-07 lines are not 04-07 changes). Flagged as judgment.
- Earlier plans: 04-03 "SKILL.md MUST NOT state a rule with no ledger row" and 04-05 "skill MUST NOT tell the agent to run a BBj program on its own initiative": satisfied (`running.md:3-4`); flagged as judgment.

### Human Verification Required

### 1. Disposition of the open review warnings

**Test:** Open `04-REVIEW-DISPOSITION.md` and set a disposition for WR-01 to WR-07 and IN-01 to IN-07 (WR-08 already fixed in 04-07).
**Expected:** Each is `fixed`, `skipped` or `deferred` with a reason. The verifier's recommendation: fix WR-07, IN-07, WR-05 and WR-01 (small wording or example edits, then re-run the live gate), cite the methods page for WR-02, accept the rest.
**Why human:** Whether "complete with warnings" is acceptable for the 0.2.0 core value is the owner's call; the verifier found no warning that falsifies a roadmap success criterion.

### 2. Flagged prohibitions

**Test:** Read `sysgui.md:10-29` and `running.md:36-40`.
**Expected:** The Dialog flag is never presented as modal or as the replacement for `setModal`; the `-tIO` line is plain.
**Why human:** No wired test enforces either; the LLM-judge verdict above is non-authoritative.

### 3. `real_home_untouched` flake

**Test:** Decide whether to harden `tests/test_install_codex.sh:1520` against the Codex app-server daemon.
**Expected:** Accept as environmental for Phase 4; schedule the hardening (content hashes or daemon-path exclusion) as a separate task.
**Why human:** Scope decision outside this phase's files.

### Gaps Summary

No gaps. All six requirement IDs are satisfied, every gap item from the first verification is closed in the shipped files and in the ledger, and no previously passing truth regressed. The phase goal holds for the claims that matter: the rules an agent follows are each documented or reproduced, and every `bbj` block passes both live routes. The status is `human_needed` because of flagged prohibitions, seven undispositioned warnings (one of which, WR-07, I confirmed overreaches its page by a timing qualifier) and a suite flake caused by an external daemon.

---

_Verified: 2026-10-11_
_Verifier: Claude (gsd-verifier)_
