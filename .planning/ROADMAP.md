# Roadmap: bbj-agent-plugins 0.2.0

## Overview

Release 0.2.0 makes this repository the home of the two BBj skills and makes the local `bbj-ls`
check the first choice wherever it exists. The journey: first stop vendoring (so the skills can be
edited at all) and give Codex the `bbj-local` route with local-first docs and one shared
check-order text (Phase 1); make the hook tell the agent when no check route exists (Phase 2);
build the example gate and structure lints and run them against the current skills so the red
baseline becomes the makeover to-do list (Phase 3); rewrite `bbj-programming` and then
`bbj-web-programming` so every claim is documented or reproduced and every code block passes the
gate (Phases 4-5); cut and tag 0.2.0 with the live gates green (Phase 6).

**Milestone:** v0.2.0 (plugin release 0.2.0). **Granularity:** standard.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Repo-owned skills and local-first check route** - Stop vendoring; Codex `--with-local`; one check-order text and local-first docs (completed 2026-10-10)
- [x] **Phase 2: Hook no-route notice** - The hook tells the agent once per session when a written file could not be checked (completed 2026-10-10)
- [x] **Phase 3: Example gate and structure lints** - Every fenced BBj block and skill structure rule is measured; the baseline is the makeover to-do list (completed 2026-10-10)
- [x] **Phase 4: bbj-programming makeover** - Check workflow first, short body, every claim sourced or reproduced, every block passes the gate (completed 2026-10-11)
- [x] **Phase 5: bbj-web-programming makeover** - Short trigger-first description, DWC claims kept only with proof, taste cut, every block passes the gate (completed 2026-10-12)
- [ ] **Phase 6: Release 0.2.0** - Versions, changelog with upgrade notes, live gates green, tag

## Phase Details

### Phase 1: Repo-owned skills and local-first check route

**Goal**: The skills are maintained in this repository rather than vendored, and Codex users can register the local `bbj-ls` check with one flag, with docs and shared text presenting the local check as the preferred route
**Depends on**: Nothing (first phase)
**Requirements**: VEND-01, VEND-02, VEND-03, LOCAL-01, LOCAL-02, LOCAL-03, LOCAL-04, LOCAL-05, LOCAL-06, LOCAL-07
**Success Criteria** (what must be TRUE):

  1. A maintainer can edit any file under `plugins/bbj/skills/` and the full test suite still passes: `skills.lock.json` and `tests/test_skills_hash.py` are gone, nothing references them, and the skills fall under the normal layout and URL rules in `tests/test_layout.py`
  2. README, NOTICE, both manifests and `docs/install-claude-code.md` describe the skills as maintained in this repository; no "vendored" or "the BBjSkills" wording and no NOTICE provenance line remain
  3. `install-codex.sh --with-local` writes exactly one managed `bbj-local` block (`http://127.0.0.1:5009/mcp`, the three tools auto-approved), a rerun updates it in place, a lone end marker is tolerated, and the existing `bbj-docs` installer tests stay green after the refactor
  4. Without the flag, the installer sends one `tools/list` probe (no user code) and only suggests `--with-local` when `bbj-ls` answers; with the flag and no answer it registers the server anyway and prints a warning; `tests/test_install_codex.sh` covers the flag, probe, probe failure, reruns and a lone marker
  5. One check-order block (`bbjcpl`, then local `bbj-ls`, then the hosted check only when neither exists) is byte-identical in `codex/AGENTS-snippet.md` and both SKILL.md files, a test fails if they drift, and README plus both install pages present `bbj-local` as the preferred route with its two reasons

**Plans**: 7/7 plans executed

Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Stop vendoring: delete the lock and hash test, skills under the layout rules, maintained-here wording (wave 1)
- [x] 01-03-PLAN.md — Installer refactor: parameterised sync_server, bbj-docs output byte-identical on six golden scenarios (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-02-PLAN.md — Drop vendoring statements from .claude/CLAUDE.md and the codebase maps, D-16; runs the phase-wide grep-zero (wave 2, after 01-01)
- [x] 01-04-PLAN.md — Installer --with-local: managed bbj-local block, reruns, lone end marker, D-12 forms (wave 2, after 01-03)
- [x] 01-05-PLAN.md — Check-order block in the snippet and both skills, pinned by tests/test_check_order.py (wave 2, after 01-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-06-PLAN.md — Installer tools/list probe, LOCAL-04 outcome matrix (registers on every outcome, warns unless found), fake server tools/list mode (wave 3, after 01-04)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 01-07-PLAN.md — Docs: bbj-local preferred over the hosted check in README and both install pages; quoted installer messages gated (wave 4, after 01-01, 01-04, 01-05, 01-06)

**Cross-cutting constraints:**

- New installer code uses only the tools of the no-codex PATH farm (sh cat cp mv mkdir rm diff cmp mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd)

### Phase 2: Hook no-route notice

**Goal**: When no check route is available, the agent is told once per session that the file it wrote was not checked, instead of the hook exiting silently
**Depends on**: Nothing (independent of Phase 1; can run in parallel with it)
**Requirements**: HOOK-01, HOOK-02, HOOK-03, HOOK-04
**Success Criteria** (what must be TRUE):

  1. With neither `bbjcpl` nor `bbj-ls` available, the first BBj file written in a session produces one notice (hook exits 0, one JSON `additionalContext` object) saying the file was written but not checked, how to enable `bbjcpl` (`bbj_home`) or `bbj-local`, and naming the hosted check in one clause as a fallback that sends code to the server; the next write in that session is silent
  2. A clean file, a file with compile errors, and a route that failed or timed out never produce the notice; the hook distinguishes clean / errors / no route / route failed
  3. `tests/test_exit_contract.sh` asserts stdout holds exactly that JSON object in the no-route case and is empty otherwise, and the former silent-path tests read "first call notice, then silent"
  4. On a real Codex after `apply_patch`, the notice is confirmed to reach the model; if it does not, Codex alone falls back to exit 2 with stderr and the result is recorded

**Plans**: 6/6 plans complete

Plans:
**Wave 1**

- [x] 02-01-PLAN.md — Hook notice on the no-compiler branch: tier-2 no route vs route failed, exact JSON object, both client texts, path caps, once-per-session marker and its edge cases; BBJ_CHECK_STATE_DIR seam; 14 silent-path gates converted (wave 1)
- [x] 02-03-PLAN.md — README, both install pages and the installer's Known gaps describe the notice instead of silence; need/forbid gates (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 02-02-PLAN.md — D-02 compiler-without-verdict path, exit contract amended narrowly, single-writer static gate, never-notifies matrix (failed routes, clean, errors, early skips, mixed patches) (wave 2, after 02-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 02-04-PLAN.md — Real Claude Code capture from the local marketplace (D-14): dry run, billed run approval, evidence (wave 3, after 02-02)
- [x] 02-05-PLAN.md — Real Codex capture (D-13): installer-made hook in a scratch project, trust-mode decision, evidence and OUTCOME.md (wave 3, after 02-02, 02-03)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 02-06-PLAN.md — Apply the Codex outcome: D-15 exit-2 fallback only if not delivered (with re-run), captured payload facts in hook and tests (wave 4, after 02-05)

**Cross-cutting constraints:**

- Every hook run in a capture uses the seams BBJ_CHECK_DEFAULT_HOMES= and BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp (this machine has /opt/bbx and a live bbj-ls on 5009); capture scripts live under the phase directory, never in tests/
- notice() uses only awk, sed, tr, head, printf and mkdir (the no-curl PATH farm of tests/test_tier2_fake.sh)

### Phase 3: Example gate and structure lints

**Goal**: A repeatable gate measures every fenced BBj example and the structure rules of the skills, and the current skills' failures are recorded as the makeover to-do list
**Depends on**: Phase 1 (the baseline is taken on repo-owned skills that already carry the shared check-order block)
**Requirements**: GATE-01, GATE-02, GATE-03, GATE-04, GATE-05, GATE-06
**Success Criteria** (what must be TRUE):

  1. In CI without BBj, the lint extracts every fenced block and enforces the fence grammar: `bbj` / `bbj should-fail` / `bbj nocheck (reason)` accepted, non-BBj languages ignored, and untagged fences, unknown attributes, unclosed fences, missing nocheck reasons and `...` placeholders in `bbj` blocks fail it
  2. On a machine with BBj, the live run checks all blocks with `bbjcpl -t -N -X` (batched) and then `bbj-ls`: a `bbj` block must pass every available route, a `bbj should-fail` block must fail on at least one, the run skips without BBj, and `BBJ_SKILLS_LIVE=1` turns a missing route into a failure
  3. The count of `bbj nocheck` blocks is recorded and the gate fails if it grows above that number
  4. Structure lints fail on a skill description over 1,024 characters, on any denylisted project leftover or fixed install path (`DailyDrift`, `DriftDB`, `migrateSortPrefs`, `watches!`, `cart-updated`, `/opt/basis/bin/`), and on a reference file that lacks a Sources section or a "Verified on BBj <version>" line
  5. A baseline report of the current skills against the gate (failing blocks per route, lint violations) is committed, and skills not yet reworked are listed as pending rather than silently exempt, so the suite's pass/fail stays meaningful until Phases 4-5 finish

**Plans**: 4/4 plans complete

Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Grammar lint vertical slice: fence extractor, D-05..D-07 grammar, pending list and ratchet (D-01..D-04), --report baseline writer, grammar/ratchet/report fixtures (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 03-02-PLAN.md — Structure lints (description length, denylist, Sources + Verified line) and the repository-wide nocheck ratchet, with fixtures (wave 2, after 03-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 03-03-PLAN.md — Live route 1: one batched bbjcpl -t -N -X call with canaries and record attribution, bbj / should-fail outcome rules, skip-unless-BBJ_SKILLS_LIVE route gate, fake-compiler guards (wave 3, after 03-02)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 03-04-PLAN.md — Live route 2: bbj-ls over loopback with the hook's rules (no proxy, no redirect), network guard fixtures; committed baseline and 03-BASELINE.md from a two-route run on BBj 26.03; ci.sh header line (wave 4, after 03-03)

**Cross-cutting constraints:**

- All four plans edit tests/test_skill_examples.py and regenerate tests/skills_baseline.json, so they run strictly in sequence; the baseline is only ever written by --report, never by hand
- No file under plugins/bbj/skills/ changes in this phase

### Phase 4: bbj-programming makeover

**Goal**: An agent using `/bbj:bbj-programming` gets only verified rules: the check workflow first, a short body, every claim documented or reproduced, and every code block passing the gate
**Depends on**: Phase 3 (and Phase 1)
**Requirements**: PROG-01, PROG-02, PROG-03, PROG-04, PROG-05, PROG-06
**Success Criteria** (what must be TRUE):

  1. A claim ledger classifies every claim in the skill and its references as DOC (URL, with a quoted sentence where the page is not explicit), COMPILE (`bbjcpl`/`bbj-ls` output with BBj version) or RUNTIME; no RUNTIME claim survives unless rewritten to its compile-time observable
  2. SKILL.md opens with the check workflow, has a body of about 150 lines or fewer, and points to the docs tools and `bbj://primer` instead of copying reference tables
  3. The skill states only rules the primer lacks, and states them correctly: bare method calls (`v!.get(0)`, `#foo()`) are valid statements while a bare function-style call `name(args)` is not; "Built in: no USE needed" holds for BBj classes and `java.lang` only; the `bbjcpl -t -N -X` output quirks on 26.03; the REM/`;` rule the hook enforces
  4. Known wrong claims are corrected (`LIMIT` is documented, the `str()` mask example, "parse stdout" of `bbjcpl`, `HashMap`/`ArrayList` need `USE`); all taste (`PRECISION 16`, `Utils` class, `q`/`k`/`wi` naming, size-guard rule) and project leftovers are gone; launcher facts remain only where verified and framed as applying when the user asks to run a program
  5. Every `bbj` block in the skill and its references passes the live gate on both routes, the structure lints pass, and the skill is still invoked as `/bbj:bbj-programming`

**Plans**: 8/8 plans complete

Plans:
**Wave 1**

- [x] 04-01-PLAN.md — Compile evidence: probes/run.py (batched bbjcpl -t -N -X, loopback bbj-ls, canaries, --check), about 70 probes, reserved-word re-proof, OUTPUT.txt, dry-run recipe (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 04-02-PLAN.md — Claim ledger 04-LEDGER.md (one row per rule: class, evidence, primer, verdict, route) and ledger_check.py (wave 2, after 04-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 04-03-PLAN.md — SKILL.md rewrite: check block first, bbjcpl output, primer-gap rules with should-fail pairs, pointers, index; scoped Built in line shared with the Codex snippet; ratchet lowered (wave 3, after 04-02)
- [x] 04-04-PLAN.md — 04-DOCS-PROPOSAL.md for the BASIS docs owners, STR() chapter first, then every COMPILE-only gap and the dropped rules (wave 3, after 04-02)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 04-05-PLAN.md — references/running.md (launcher facts with URLs, when the user asks), sysgui.md and callback-performance.md reduced to ledger survivors; ratchet lowered (wave 4, after 04-03)

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 04-06-PLAN.md — database.md (LIMIT documented), java-interop.md and reserved-words.md deleted, bbj-programming off the pending list via --report in the same commit, full suite green (wave 5, after 04-05)

**Wave 6** *(gap closure, blocked on Wave 5 completion)*

- [x] 04-07-PLAN.md — Gap closure from 04-VERIFICATION.md: SKILL.md provenance intro and two lines, sysgui.md Dialog flag as documented and the clickable-image rule, database.md getJDBCConnection(url) and scoped SQL functions, running.md END/STOP condition and honest footer; ledger rows L117 and L089 (plus L076, L088, L093, L138) aligned (wave 6, gap_closure)

**Wave 7** *(gap closure, blocked on Wave 6 completion)*

- [x] 04-08-PLAN.md — UAT gap G-04-2: sysgui.md states the Dialog flag as modal (WINDOW mnemonic page) and the owner-confirmed front rule (D-24), IN-02 disclaimer removed; ledger L117 DOC, L119 DOC (drop), new OWNER row L151; docs proposal L118 bullet, L119 row and L151 entry; SKILL.md sysgui.md index line (wave 7, gap_closure)

**Cross-cutting constraints:**

- Probes and gate runs are compile-only (bbjcpl -t -N -X, bbj-ls on 127.0.0.1:5009); nothing runs BBj and no skill code goes to the hosted check
- Every intermediate commit keeps the full suite green: bbj-programming counts only fall, bbj-web-programming counts stay 15 / 25 / 5 / 0 / 8; tests/skills_baseline.json is written only by --report
- The check-order block bytes in SKILL.md never change (tests/test_check_order.py)

### Phase 5: bbj-web-programming makeover

**Goal**: An agent using `/bbj:bbj-web-programming` gets a short, trigger-first skill whose DWC claims are each documented or reproduced and whose code blocks all pass the gate
**Depends on**: Phase 4 (sets the ledger and rewrite conventions)
**Requirements**: WEB-01, WEB-02, WEB-03
**Success Criteria** (what must be TRUE):

  1. The claim ledger covers the skill and its references; DWC DOM and CSS claims (DOM structure, `addOuterStyle`, the focus-ring padding rule) remain only with a docs URL or an owner reproduction recorded with the DWC/BBj build, and every other such claim is removed
  2. The description is 1,024 characters or fewer with the triggers first, the body is short and the references are trimmed, and all taste is cut (GSAP, Swiper, Tabler Icons, Google Fonts/Inter/Playfair Display, the 420px card grid)
  3. The `injectStyle` `top` claim states the documented meaning (the top-level window)
  4. Every `bbj` block in the skill and its references passes the live gate, the structure lints pass, and the skill is still invoked as `/bbj:bbj-web-programming`

**Plans**: 10/10 plans complete

Plans:
**Wave 1**

- [x] 05-01-PLAN.md — Compile evidence: probes/run.py adapted from Phase 4 (no reserved-word tier), about 20 probes (setSlot order, outer styles on BBjChildWindow/BBjButton, attributes, inject top, Automatic Layout, themes, validation, web components, registration), OUTPUT.txt, README (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 05-02-PLAN.md — Ledger part 1: ledger_check.py (three DOC hosts D-16/D-16a, owner checklist marking, static-triage gate D-16b), 05-LEDGER.md header with the DWC pin, every rule of SKILL.md classified; injectStyle top row first (wave 2, after 05-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 05-03-PLAN.md — Ledger part 2: the seven references, New rules, owner checklist triage O1-O11 (D-06), Totals with Destinations and Deleted lines (D-09) (wave 3, after 05-02)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 05-04-PLAN.md — 05-OWNER-CHECKLIST.md, owner-repros/*.bbj compiled on both routes (never run by Claude), checklist_check.py (wave 4, after 05-03)

**Wave 5** *(blocked on Wave 4 completion; not autonomous)*

- [x] 05-05-PLAN.md — Owner session: trace_check.py and a recording rehearsal, the blocking-human checkpoint (D-07), outcomes recorded as D-19+ OWNER-confirmed bullets, OWNER rows and recomputed destinations (wave 5, after 05-04)

**Wave 6** *(blocked on Wave 5 completion)*

- [x] 05-07-PLAN.md — references/styling.md: themes, overrides, component attributes, shadow parts, focus ring in the docs' words (wave 6, after 05-05)
- [x] 05-08-PLAN.md — running-dwc-apps.md, form-validation.md, shoelace.md rewritten to their documented BBj facts (wave 6, after 05-05)
- [x] 05-09-PLAN.md — 05-DOCS-PROPOSAL.md for the BASIS docs owners: top wording, DOM structure, OWNER claims, conflicts, dropped candidates (wave 6, after 05-05)

**Wave 7** *(blocked on Wave 6 completion)*

- [x] 05-06-PLAN.md — SKILL.md rewrite: trigger-first description, check-order block, documented injectStyle top meaning, two should-fail traps, pointers, index of the references 05-07 and 05-08 wrote (wave 7, after 05-05, 05-07, 05-08)

**Wave 8** *(blocked on Wave 7 completion)*

- [x] 05-10-PLAN.md — Finish: delete the folded references and regenerate the baseline in one commit (skill leaves pending), phase-wide scans, full suite live and CI views (wave 8, after 05-06, 05-07, 05-08, 05-09)

**Cross-cutting constraints:**

- D-07 order: ledger (05-02, 05-03) then the blocking owner checkpoint (05-05, gate blocking-human) then the rewrite (05-06 to 05-08); no shipped file changes before 05-05 is recorded
- Probes and owner repros are compile-only (bbjcpl -t -N -X, loopback bbj-ls); Claude never runs BBj; no skill code goes to the hosted check
- tests/skills_baseline.json is written only by --report in 05-10, in the same commit as the reference deletions; earlier plans only lower counts (ratchet ok) and never bring them all to 0
- The check-order block bytes in SKILL.md never change (tests/test_check_order.py); the Phase 4 skill is not edited

### Phase 6: Release 0.2.0

**Goal**: 0.2.0 is shipped: versions, changelog with upgrade notes, a green full suite on a real BBj, and the tag
**Depends on**: Phases 1, 2, 3, 4, 5
**Requirements**: REL-01, REL-02, REL-03, REL-04
**Success Criteria** (what must be TRUE):

  1. `plugins/bbj`, `plugins/bbj-local`, both marketplace entries and `tests/test_layout.py` `VERSION` read 0.2.0, changed in one commit, and `claude plugin validate --strict` passes
  2. CHANGELOG has a 0.2.0 entry with the Codex upgrade notes (`--force` to replace the skills, `/hooks` re-approval of the changed hook) and a "Tested against" section rewritten from the actual run
  3. The full suite passes with `skip=0` on the live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`), and an install from the git marketplace source passes
  4. The release is tagged `0.2.0`

**Plans**: 3/8 plans executed

Plans:
**Wave 1**

- [x] 06-01-PLAN.md — Pre-release loose ends: Phase 4 findings WR-01, IN-01, IN-02 fixed and WR-08 skipped (open: 0, D-16); shellcheck directives in test_noroute_notice.sh; busybox and shellcheck installed (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 06-02-PLAN.md — Version 0.2.0 in one commit with strict validation (REL-01); CHANGELOG 0.2.0 entry with upgrade notes quoting the installer; tests/test_release_text.py; project notes at 0.2.0 (wave 2, after 06-01)

**Wave 3** *(blocked on Wave 2 completion; not autonomous)*

- [x] 06-03-PLAN.md — Release-candidate suite at skip=0 (daemon stopped); owner decisions D-20 to D-23 (blocking); strict /gsd-pr-branch, planning-free history, tree equality, suite on the PR tree (wave 3, after 06-02)

**Wave 4** *(blocked on Wave 3 completion; not autonomous)*

- [ ] 06-04-PLAN.md — Git-source path probed over HTTPS; owner approves the push and logs in a throwaway config; push, draft PR, D-13 run from the pushed ref, bbj-local enabled, first CI (wave 4, after 06-03)

**Wave 5** *(blocked on Wave 4 completion; not autonomous)*

- [ ] 06-05-PLAN.md — Real Codex D-11: fresh install with --with-local checked without a model, owner /hooks approval, billed apply_patch run, home restored per D-22, daemon stopped (wave 5, after 06-04)

**Wave 6** *(blocked on Wave 5 completion; not autonomous)*

- [ ] 06-06-PLAN.md — Tested against from the run evidence and D-23 pins; final suite on the PR tree equals the CHANGELOG; owner-approved fast-forward push; CI green; PR ready (wave 6, after 06-05)

**Wave 7** *(blocked on Wave 6 completion; not autonomous)*

- [ ] 06-07-PLAN.md — D-05 install gate script passes on the PR ref; owner-approved merge commit; main carries the tested tree; CI on main and the install gate from main pass (wave 7, after 06-06)

**Wave 8** *(blocked on Wave 7 completion; not autonomous)*

- [ ] 06-08-PLAN.md — Annotated tag 0.2.0 prepared locally on the merge commit; owner confirms; tag pushed, GitHub Release from the CHANGELOG entry; main merged back into the planning branch (wave 8, after 06-07)

**Cross-cutting constraints:**

- Every push, the merge, the tag push and the Release wait for a blocking-human owner confirmation immediately before them; nothing is ever force-pushed
- Nothing runs BBj: the hook and the gates compile only (bbjcpl -t -N -X, loopback bbj-ls); no test code reaches the hosted check
- Real-client runs use throwaway configs or a recorded-and-restored home; credentials never enter the repository; raw streams stay outside it

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6. Phase 2 has no dependencies and can run in parallel with Phase 1 or Phase 3.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Repo-owned skills and local-first check route | 7/7 | Complete    | 2026-10-10 |
| 2. Hook no-route notice | 6/6 | Complete    | 2026-10-10 |
| 3. Example gate and structure lints | 4/4 | Complete    | 2026-10-10 |
| 4. bbj-programming makeover | 8/8 | Complete    | 2026-10-11 |
| 5. bbj-web-programming makeover | 10/10 | Complete    | 2026-10-12 |
| 6. Release 0.2.0 | 3/8 | In Progress | - |
