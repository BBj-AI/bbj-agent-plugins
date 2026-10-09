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

- [ ] **Phase 1: Repo-owned skills and local-first check route** - Stop vendoring; Codex `--with-local`; one check-order text and local-first docs
- [ ] **Phase 2: Hook no-route notice** - The hook tells the agent once per session when a written file could not be checked
- [ ] **Phase 3: Example gate and structure lints** - Every fenced BBj block and skill structure rule is measured; the baseline is the makeover to-do list
- [ ] **Phase 4: bbj-programming makeover** - Check workflow first, short body, every claim sourced or reproduced, every block passes the gate
- [ ] **Phase 5: bbj-web-programming makeover** - Short trigger-first description, DWC claims kept only with proof, taste cut, every block passes the gate
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

**Plans**: 7 plans

Plans:
**Wave 1**

- [ ] 01-01-PLAN.md — Stop vendoring: delete the lock and hash test, skills under the layout rules, maintained-here wording (wave 1)
- [ ] 01-03-PLAN.md — Installer refactor: parameterised sync_server, bbj-docs output byte-identical on six golden scenarios (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 01-02-PLAN.md — Drop vendoring statements from .claude/CLAUDE.md and the codebase maps, D-16; runs the phase-wide grep-zero (wave 2, after 01-01)
- [ ] 01-04-PLAN.md — Installer --with-local: managed bbj-local block, reruns, lone end marker, D-12 forms (wave 2, after 01-03)
- [ ] 01-05-PLAN.md — Check-order block in the snippet and both skills, pinned by tests/test_check_order.py (wave 2, after 01-01)

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 01-06-PLAN.md — Installer tools/list probe, LOCAL-04 outcome matrix (registers on every outcome, warns unless found), fake server tools/list mode (wave 3, after 01-04)

**Wave 4** *(blocked on Wave 3 completion)*

- [ ] 01-07-PLAN.md — Docs: bbj-local preferred over the hosted check in README and both install pages; quoted installer messages gated (wave 4, after 01-01, 01-04, 01-05, 01-06)

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

**Plans**: TBD

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

**Plans**: TBD

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

**Plans**: TBD

### Phase 5: bbj-web-programming makeover

**Goal**: An agent using `/bbj:bbj-web-programming` gets a short, trigger-first skill whose DWC claims are each documented or reproduced and whose code blocks all pass the gate
**Depends on**: Phase 4 (sets the ledger and rewrite conventions)
**Requirements**: WEB-01, WEB-02, WEB-03
**Success Criteria** (what must be TRUE):

  1. The claim ledger covers the skill and its references; DWC DOM and CSS claims (DOM structure, `addOuterStyle`, the focus-ring padding rule) remain only with a docs URL or an owner reproduction recorded with the DWC/BBj build, and every other such claim is removed
  2. The description is 1,024 characters or fewer with the triggers first, the body is short and the references are trimmed, and all taste is cut (GSAP, Swiper, Tabler Icons, Google Fonts/Inter/Playfair Display, the 420px card grid)
  3. The `injectStyle` `top` claim states the documented meaning (the top-level window)
  4. Every `bbj` block in the skill and its references passes the live gate, the structure lints pass, and the skill is still invoked as `/bbj:bbj-web-programming`

**Plans**: TBD

### Phase 6: Release 0.2.0

**Goal**: 0.2.0 is shipped: versions, changelog with upgrade notes, a green full suite on a real BBj, and the tag
**Depends on**: Phases 1, 2, 3, 4, 5
**Requirements**: REL-01, REL-02, REL-03, REL-04
**Success Criteria** (what must be TRUE):

  1. `plugins/bbj`, `plugins/bbj-local`, both marketplace entries and `tests/test_layout.py` `VERSION` read 0.2.0, changed in one commit, and `claude plugin validate --strict` passes
  2. CHANGELOG has a 0.2.0 entry with the Codex upgrade notes (`--force` to replace the skills, `/hooks` re-approval of the changed hook) and a "Tested against" section rewritten from the actual run
  3. The full suite passes with `skip=0` on the live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`), and an install from the git marketplace source passes
  4. The release is tagged `0.2.0`

**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6. Phase 2 has no dependencies and can run in parallel with Phase 1 or Phase 3.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Repo-owned skills and local-first check route | 0/6 | Planned | - |
| 2. Hook no-route notice | 0/TBD | Not started | - |
| 3. Example gate and structure lints | 0/TBD | Not started | - |
| 4. bbj-programming makeover | 0/TBD | Not started | - |
| 5. bbj-web-programming makeover | 0/TBD | Not started | - |
| 6. Release 0.2.0 | 0/TBD | Not started | - |
