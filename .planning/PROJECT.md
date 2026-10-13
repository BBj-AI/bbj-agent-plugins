# bbj-agent-plugins

## What This Is

The `basis-bbj` plugin marketplace for coding agents (Claude Code, and OpenAI Codex through
its own plugin commands, with `install-codex.sh` kept one release as a fallback). It gives an agent the BBj documentation MCP server, two BBj skills
(`bbj-programming`, `bbj-web-programming`), and a hook that compile-checks every BBj file the
agent writes, so agents write BBj that compiles. Release 0.2.0 (shipped 2026-10-12) made this
repository the home of the two skills, rewrote them to state only verified facts, and made the
local `bbj-ls` check the preferred route over the hosted one wherever it is available.

## Current State

Shipped **v0.2.0** (plugin release 0.2.0, tag `0.2.0` on f15c257, GitHub Release published
2026-10-12). Both skills are maintained here and fully enforced by the example gate on `bbjcpl -t`
and `bbj-ls` (baseline pending `{}`, `nocheck` 0). The full suite passes at `ok=738 fail=0 skip=0`
with live gates. Milestone record: `.planning/MILESTONES.md`; archive: `.planning/milestones/`.

## Current Milestone: v0.2.1 Platform verification and release hygiene

**Goal:** Replace every "not yet run on Windows/macOS" hint with wording backed by real runs, and
ship it, with the fixes left over from 0.2.0, as release 0.2.1.

**Target features:**
- Codex native plugin route (`codex plugin add bbj@basis-bbj`, `.codex-plugin` overlay for the docs
  URL, unchanged hook after `/hooks` trust); `install-codex.sh` kept one release as fallback
- Windows verification: Claude Code plugin and hook (Git for Windows, `cygpath`) and the Codex
  plugin route, on `bbjcpl` and, where BBjServices runs, `bbj-ls`; fix what breaks
- macOS verification on `bbjcpl` for Claude Code and Codex (the 0.2.0 UAT covered `bbj-ls` only)
- Test hardening: `tests/lib.sh` scrubs PATH (WR-01); `real_home_untouched` ignores Codex runtime files (D-2)
- Per-platform, per-route install wording in README, docs, installer and CHANGELOG, pinned by gates
- Release hygiene: the four planning-branch review fixes, CONTENT_VERSION gate policy, complete
  gate-prefix list in `.claude/CLAUDE.md`; version 0.2.1, merged, tagged `0.2.1`, GitHub Release

## Requirements

### Validated

- ✓ Marketplace `basis-bbj` with plugins `bbj` and `bbj-local`, passing `claude plugin validate --strict` — 0.1.0
- ✓ `bbj` plugin registers the hosted `bbj-docs` MCP server (`docs_url` option) — 0.1.0
- ✓ `bbj-local` plugin registers `bbj-ls` at `http://127.0.0.1:5009/mcp`, disabled by default — 0.1.0
- ✓ `PostToolUse` hook on `Write|Edit` compile-checks BBj files: `bbjcpl -t -N -X`, then loopback `bbj-ls`, never the hosted check, never runs BBj code — 0.1.0
- ✓ Codex installer (`codex/install-codex.sh`) registers `bbj-docs`, installs skills and the hook; the five docs tools auto-approved, the three code-sending tools keep the prompt — 0.1.0
- ✓ Shell/Python test suite (`tests/run.sh`, `tests/ci.sh`) with ShellCheck and plugin validation in CI — 0.1.0
- ✓ Codex installer `--with-local`: registers `bbj-local` at `http://127.0.0.1:5009/mcp` with its three tools auto-approved; opt-in, suggested by an install-time probe; registers and warns when the probe does not find it — Phase 1
- ✓ `codex/AGENTS-snippet.md` and both SKILL.md files carry one shared check-order block (`bbjcpl`, then `bbj-local`, then hosted only when neither exists, disclosing that hosted sends code away), pinned byte-identical by `tests/test_check_order.py` — Phase 1
- ✓ Docs and README present `bbj-local` as preferred over the hosted check (never over `bbjcpl`), with the two reasons — Phase 1
- ✓ Installer tests cover `--with-local` and the probe in `tests/test_install_codex.sh` — Phase 1
- ✓ Vendoring retired: `skills.lock.json`, `tests/test_skills_hash.py`, the README section and NOTICE provenance removed; "the BBjSkills" wording replaced; skills under the normal layout tests — Phase 1
- ✓ Hook no-route notice: with no check route the hook exits 0 and emits one `additionalContext` object once per session (clean / errors / no route / route failed kept apart); delivery to the model confirmed on real Claude Code and real Codex (codex-cli 0.162.1) after `apply_patch` — Phase 2
- ✓ Skill example gate `tests/test_skill_examples.py`: fence grammar (`bbj`, `bbj should-fail`, `bbj nocheck (reason)`), structure lints (description ≤ 1,024, denylist, Sources + Verified line), `nocheck` ratchet at 0; the lint runs in CI without BBj, the live check runs `bbjcpl -t -N -X` then loopback `bbj-ls` and skips without BBj (`BBJ_SKILLS_LIVE=1` makes a missing or broken route a FAIL) — Phase 3
- ✓ Baseline committed (`tests/skills_baseline.json`, `03-BASELINE.md`, BBj 26.03): both skills listed as pending (Phase 4, Phase 5) with per-check counts, so the suite stays green and any rise fails — Phase 3
- ✓ `bbj-programming` makeover: claim ledger (151 rows: DOC, COMPILE, RUNTIME, OWNER) with every claim cited, compile-reproduced on BBj 26.03 or dropped; SKILL.md check workflow first and short; known wrong claims, taste and project leftovers cut; every `bbj` block passes `bbjcpl -t` and `bbj-ls`; skill name unchanged (PROG-01..06) — Phase 4
- ✓ `bbj-web-programming` makeover: claim ledger over the skill and its references; DWC DOM/CSS claims kept only with a docs URL or an owner reproduction on BBj 26.03; description ≤ 1,024 characters with triggers first; taste cut; `injectStyle` `top` corrected; every `bbj` block passes the gate; skill name unchanged (WEB-01..03) — Phase 5
- ✓ Skills makeover complete for both skills: every claim cited or reproduced, every `bbj` block passes `bbjcpl -t` and `bbj-ls`, neutral names, docs tools instead of copied tables, "Built in: no USE needed" in `bbj-programming`, skill names unchanged — Phases 4 and 5
- ✓ Release 0.2.0: both plugins and the marketplace at 0.2.0, CHANGELOG with Upgrading notes and a Tested against section from the release run, full suite `ok=738 fail=0 skip=0` with live gates, PR #1 merged (f15c257), annotated tag `0.2.0` and GitHub Release published; UAT installs confirmed on Claude Code and on Codex under macOS (REL-01..04) — Phase 6

- ✓ Codex plugin route: `codex plugin marketplace add` and `codex plugin add bbj@basis-bbj` register `bbj-docs` at the literal docs URL through the `.codex-plugin/plugin.json` overlay and `.codex-mcp.json` (shipping the public OAuth client), both skills load, the unchanged hook checks `apply_patch` writes after `/hooks` trust and stays trusted across a version-only upgrade; `bbj-local` stays opt-in; `install-codex.sh --remove` is the documented switch; proven on Linux with Codex CLI 0.162.1, gated in CI on fakes (CODEX-01..06) — Phase 8

### Active

- [ ] Windows: Claude Code and Codex installs and hook verified on a real machine (bbjcpl; bbj-ls where available)
- [ ] macOS: Claude Code and Codex hook verified on the bbjcpl route
- [ ] Test suite passes on a maintainer machine that has bbjcpl on PATH or a running Codex daemon
- [ ] Install docs, installer and CHANGELOG state per platform and per route what was verified
- [ ] Release 0.2.1 carries the 0.2.0 review fixes and is tagged and published

### Out of Scope

- What happens to the BBjSkills repository (retire or mirror) — handled outside this repo
- Docs-server drift check and primer pin on BBjSkills — tracked in the docs-server repo
- Configurable URL for `bbj-local` — stays fixed at `127.0.0.1:5009`; revisit only on demand
- Opinionated choices as labelled suggestions — cut entirely instead (GSAP, Swiper, Tabler Icons, fonts, card grid, `Utils` class, `PRECISION 16`, variable naming, etc.)
- Running the skill-example check against the hosted server in CI — public content, but the gate is local-only by decision
- Single go-live constant for the docs URL, installer backups on `--force`, deduplicating hook/installer logic — known concerns, not in 0.2.0

## Context

- Brownfield; codebase map in `.planning/codebase/` (2026-10-09). Seed:
  `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md`.
- BBjServices 26.03+ runs `bbj-ls` on `127.0.0.1:5009` with `bbj_check_syntax`, `bbj_denum`,
  `bbj_format`; verified 2026-10-09 (`BBJ_LS_LIVE=1 sh tests/test_tier2_live.sh` passes).
- Skills after the v0.2.0 makeover: `bbj-programming` (SKILL.md 159 lines + 4 references:
  callback-performance, database, running, sysgui) and `bbj-web-programming` (SKILL.md 164 lines
  + 4 references: form-validation, running-dwc-apps, shoelace, styling). Before the makeover they
  had 464 and 370 lines with 5 and 7 references. Claim ledgers, probes and docs proposals are
  archived in `.planning/milestones/v0.2.0-phases/`.
- Keep `bbj-programming` SKILL.md near 150 lines; it is already at 159.
- Rules no page states ship only as owner-confirmed (OWNER ledger class), worded as such.
- Hosted `bbj_check_syntax`, `bbj_format`, `bbj_denum` send code to `https://mcp.bbj-ai.com/mcp`
  (pre-production); that is the reason the local route is preferred.
- Vendoring retired in Phase 1: the skills are edited here under `tests/test_layout.py`; the
  hash test is gone.

## Constraints

- **Tech stack**: POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime deps — matches existing hook/installer/tests
- **Safety**: BBj code is never executed; hook never calls the hosted check — enforced by `tests/test_never_execute.sh`
- **Compatibility**: `bbj-local` stays opt-in in both Claude Code and Codex — a registered but stopped server shows as failed on every start
- **Verification**: Skill code checks need a real BBj 26.03+ (`bbj-ls` or `bbjcpl`) locally; CI has none
- **Naming**: Skill names and plugin names unchanged — users and docs refer to them

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| This repo hosts the skills; BBjSkills no longer upstream | Skills need a makeover, not a re-sync | ✓ Good — Phase 1 |
| Local `bbj-ls` preferred over hosted check | Code stays local; checked against the installation's own config | ✓ Good — Phase 1 |
| Cut all taste from skills (no labelled suggestions) | Skills should state verified facts only | ✓ Good — Phase 4 (`bbj-programming`), Phase 5 (`bbj-web-programming`) |
| `bbj-local` URL stays fixed at 5009 | Simplest; BBjServices default | — Pending |
| Skill-example syntax gate is local-only | CI has no BBj; keeps the check route consistent with the local-first decision | ✓ Good — Phase 3 (D-13: missing live routes stay skip under CI=true; Phase 6 runs BBJ_SKILLS_LIVE=1 locally) |
| Hook notifies when no check route exists | Silent exit leaves the agent unaware it is unchecked | ✓ Good — Phase 2 |
| 0.2.0 includes release cut and tag | Done means shipped | ✓ Good — Phase 6 (merged, tagged, Release published 2026-10-12) |
| Example gate runs `bbjcpl -t` then `bbj-ls`; must pass both | `bbj-ls` is parse-only; `bbjcpl -t` catches 18+ wrong blocks it passes | ✓ Good — Phase 3 (baseline: bbjcpl 44/25, bbj-ls 36/15 failing blocks) |
| Runtime-only claims rewritten to compile-time proxy or dropped | Never-execute rule | ✓ Good — Phase 4 (ledger RUNTIME rows rewritten or dropped) |
| DWC DOM/CSS claims need a docs URL or owner reproduction | No doc source found for several | ✓ Good — Phase 5 (nine owner grants, O3/O8 dropped) |
| Hook notice: exit 0 + `additionalContext`, once per session | Exit 2 replaces the tool result on Codex | ✓ Good — Phase 2 (delivered on both clients; D-15 exit-2 fallback not needed) |
| `--with-local` registers and warns when probe fails | User asked explicitly; server may be stopped | ✓ Good — Phase 1 |
| Tag `0.2.0`; both plugins bumped; no NOTICE provenance line | Release decision | ✓ Good — Phase 6 (annotated tag 0.2.0 on f15c257, no v prefix) |
| Hosted check used without asking when no local route exists, but the user is told (D-01) | Keeps agents checking code; disclosure instead of a prompt | ✓ Kept at Phase 1 UAT |
| Pending skills with ratcheted counts instead of report-only CI (D-01..D-04) | Suite pass/fail stays meaningful while the skills are red | ✓ Good — Phase 3 |
| A `bbj should-fail` block no route fails, with only `bbj-ls` present, is undecided: skip, FAIL under BBJ_SKILLS_LIVE=1, not counted (D-08 amendment) | `bbj-ls` is parse-only and cannot show a type error | ✓ Accepted at Phase 3 UAT |
| A present but broken live route (failed canary pair) is skip unless BBJ_SKILLS_LIVE=1 (IN-03) | Same rule as a missing route; the release gate runs live | ✓ Accepted at Phase 3 UAT |
| A rule no page states ships only when the skill maintainer confirmed it on BBj 26.03, worded as such (OWNER ledger class; `str()` sign rule, `bbj -tIO`, Dialog-flag front rule D-24) | Owner knowledge is real but must be marked, never passed off as documented | ✓ Accepted at Phase 4 UAT |
| Release-text gates: `upgrade_addressed` runs at every version; `upgrade_quotes` and `not_run` are pinned to CONTENT_VERSION and FAIL with a re-pin message at any other version (REL-06, D-04 to D-07) | A version bump must not pass on the facts of an older release, and a skip would block the skip=0 release run; reverses the skip half of review fix WR-02 on purpose | ✓ Decided — Phase 7 (facts stay 0.2.0; Phase 10 re-pins them to 0.2.1) |
| Codex route is the native plugin: `.codex-plugin/plugin.json` overlay plus literal-URL `.codex-mcp.json`; Claude Code keeps its `docs_url` option | Codex cannot expand `${user_config.docs_url}`; one plugin tree serves both hosts and the layout gates pin version and URL drift | ✓ Good — Phase 8 (CODEX-01, CODEX-04) |
| `.codex-mcp.json` ships the public OAuth client (clientId, callbackUrl, callbackPort 47613) | Dynamic client registration is disabled on the docs server: sign-in failed without the block and completed with it | ✓ Good — Phase 8 (owner decision, plan 08-08) |
| Route detection by `CLAUDE_PLUGIN_ROOT` (D-07): non-empty on `apply_patch` means plugin route; the variable is tested, never printed | The env probe showed Codex exports it into the hook process | ✓ Good — Phase 8 (CODEX-03) |
| `install-codex.sh --remove` is the switch to the plugin route: removes only what the installer wrote, exit 3 for anything else, `--force` refused | A plugin on top of an installer install gives two hooks and double feedback; the installer must never delete a user's edits | ✓ Good — Phase 8 (CODEX-06, verified on real Codex, Linux) |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-10-13 after Phase 8*
