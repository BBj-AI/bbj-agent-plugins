# bbj-agent-plugins

## What This Is

The `basis-bbj` plugin marketplace for coding agents (Claude Code, and OpenAI Codex through
its own plugin commands, with `install-codex.sh` kept one release as a fallback). It gives an agent the BBj documentation MCP server, two BBj skills
(`bbj-programming`, `bbj-web-programming`), and a hook that compile-checks every BBj file the
agent writes, so agents write BBj that compiles. Release 0.2.0 (shipped 2026-10-12) made this
repository the home of the two skills, rewrote them to state only verified facts, and made the
local `bbj-ls` check the preferred route over the hosted one wherever it is available. Release
0.2.1 (shipped 2026-10-15) added the Codex plugin route and states, per platform and per route,
what was verified on real machines.

## Current State

Shipped **v0.2.1** (plugin release 0.2.1, annotated tag `0.2.1` on merge commit 4234e76, GitHub
Release published 2026-10-15: https://github.com/BBj-AI/bbj-agent-plugins/releases/tag/0.2.1).
The full suite passes at `ok=979 fail=0 skip=0` with live gates. Both skills stay fully enforced
by the example gate on `bbjcpl -t` and `bbj-ls` (baseline pending `{}`, `nocheck` 0). Previous:
**v0.2.0** (tag `0.2.0` on f15c257, Release 2026-10-12). Milestone record:
`.planning/MILESTONES.md`; archive: `.planning/milestones/` (v0.2.1 phases in
`milestones/v0.2.1-phases/`). No milestone is open; the next one starts with `/gsd-new-milestone`.

## Current Milestone: v0.2.2 Plugin-only cleanup

**Goal:** Ship the plugin as the only install route for Claude Code and Codex, under
consistent names, with the open review debt cleared, as release 0.2.2.

**Target features:**
- Installer route removed: `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, their tests,
  gates and fakes, and every installer mention in the hook, `tests/lib.sh`, release-text gates,
  README and `.claude/CLAUDE.md`; one CHANGELOG line points 0.2.1 installer users to
  `install-codex.sh --remove` at tag `0.2.1` (a stale `~/.codex/hooks.json` fires alongside the
  plugin hook)
- One plugin-only install page for both clients replaces `docs/install-claude-code.md` and
  `docs/install-codex.md`
- Docs server renamed `bbj-docs` → `bbj` in both MCP configs, skills, docs, hook notice and tests;
  the CHANGELOG states that users sign in again under the new name
- One set of terms (route, tier, hosted check, ...) across docs, test names and gate names
- Open Phase 9 review warnings: WR-01 plugin `commandWindows` hardcoded sh.exe, WR-02 5 s tier-2
  connect timeout per file, WR-03 weak `windows_codex_backslash_dotdot_skipped` gate
- Drift: gate-prefix list in `.claude/CLAUDE.md` and `CONVENTIONS.md`, README macOS cell
  qualifier, refreshed codebase map; dead-code sweep of anything that only served the installer
- Release 0.2.2: five versions bumped, CHANGELOG, full suite with live gates, tag `0.2.2`,
  GitHub Release

<details>
<summary>v0.2.1 milestone goal and target features (shipped 2026-10-15)</summary>

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

</details>

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
- ✓ Windows verified on a real machine (Windows 10, Git for Windows 2.52, Claude Code 2.1.292, Codex CLI 0.162.1, BBj 26.03): Claude Code hook and Codex plugin route on `bbjcpl`, `bbj-local` connected in both clients with BBjServices running; three defects found and fixed with CI gates on fakes (`commandWindows` for the Codex hook, 5 s tier-2 connect timeout, verbatim and backslash path forms), each confirmed by a dated round-2 re-run; records in `09-WINDOWS-RUN.md` (PLAT-01..04, PLAT-06) — Phase 9
- ✓ macOS verified on the `bbjcpl` route (macOS 27.0.1, bash 3.2, Claude Code 2.1.296, Codex CLI 0.162.1, BBj 26.03 at `<home>/bbx`): Claude Code and Codex plugin route both give tier-1 `bbjcpl` feedback, tier 2 and the no-route notice read as expected, no defect; record in `09-MACOS-RUN.md` (PLAT-05, PLAT-06) — Phase 9

- ✓ Install wording per platform and route: README "Verified" table, both install pages, the installer `STATUS_LINE` and closing notes and the CHANGELOG state only what the run records show, with client and BBj versions; every "not run" line names a configuration absent from the records; `release_no_unrun_hint` and the mutation test keep the old hints from returning (DOCS-01..04) — Phase 10
- ✓ Release 0.2.1: both plugins, both marketplace entries and the Codex overlay at 0.2.1, CHANGELOG `## 0.2.1` with a Tested against section for Linux, Windows and macOS, full suite `ok=979 fail=0 skip=0` with live gates, PR #2 and PR #3 merged, annotated tag `0.2.1` (no `v`) on 4234e76 and GitHub Release published 2026-10-15 (REL-07, REL-08) — Phase 10
- ✓ Docs server renamed `bbj-docs` → `bbj` in both MCP configs, both skills' check-order block, the hook's no-route notice, README and both install pages; the sign-in labels in the docs (`plugin:bbj:bbj`, `mcp__plugin_bbj_bbj__`, `codex mcp login bbj`) are the ones real Claude Code 2.1.299 and Codex CLI 0.162.1 showed on Linux in an owner run (`12-LINUX-RUN.md`); `layout_no_old_server_name` keeps the old name out of every tracked file outside `.planning/` and released CHANGELOG history (NAME-01, NAME-02) — Phase 12

### Active

- [ ] Remove the Codex installer route (`install-codex.sh`, `AGENTS-snippet.md`, tests, gates, fakes, mentions); the plugin is the only route for both clients
- [ ] One plugin-only install page for Claude Code and Codex
- [ ] CHANGELOG line that users sign in again under the docs server's new name `bbj`, plus the Windows and macOS sign-in re-confirmation (NAME-03, Phase 15); the rename itself shipped in Phase 12
- [ ] Consistent terminology across docs, test names and gate names
- [ ] Phase 9 review WR-01..WR-03: plugin `commandWindows` hardcodes `C:\PROGRA~1\Git\bin\sh.exe`; 5 s tier-2 connect timeout paid per file can exceed the 30 s hook timeout; `windows_codex_backslash_dotdot_skipped` does not catch a regression
- [ ] README cell "Claude Code on macOS" carries two readings; add the date or the "run directly" qualifier (10-VERIFICATION.md)
- [ ] Gate-prefix block in `.claude/CLAUDE.md` and `CONVENTIONS.md` matches the gates `sh tests/run.sh` prints (MAINT-08 drift); codebase map refreshed
- [ ] Release 0.2.2

### Out of Scope

- What happens to the BBjSkills repository (retire or mirror) — handled outside this repo
- Docs-server drift check and primer pin on BBjSkills — tracked in the docs-server repo
- Configurable URL for `bbj-local` — stays fixed at `127.0.0.1:5009`; revisit only on demand
- Opinionated choices as labelled suggestions — cut entirely instead (GSAP, Swiper, Tabler Icons, fonts, card grid, `Utils` class, `PRECISION 16`, variable naming, etc.)
- Running the skill-example check against the hosted server in CI — public content, but the gate is local-only by decision
- Installer review warnings WR-01..WR-03 from 10-REVIEW.md — closed by removing `install-codex.sh` in v0.2.2
- OAuth client id as a setting — one public client per tenant, pre-production and production share the tenant, and Codex cannot expand `${user_config.*}`, so the setting would be Claude Code only; the literal id stays in both configs. Revisit when a second tenant exists (decided at v0.2.2 start)
- Renaming the plugins (`bbj`, `bbj-local`) or the marketplace (`basis-bbj`) — users and docs refer to them
- Pinning or recording the CI ShellCheck version — not chosen for v0.2.2
- Single go-live constant for the docs URL, installer backups on `--force`, deduplicating hook/installer logic — known concerns, not in 0.2.0

## Context

- Brownfield; codebase map in `.planning/codebase/` (2026-10-09, predates the Codex plugin route
  and the Windows changes; refresh before relying on it). Seed:
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
- After v0.2.1: suite at `ok=979 fail=0 skip=0` with live gates (738 at 0.2.0). Codex has two
  routes: the native plugin (first) and `install-codex.sh` (fallback). Verified platforms per
  client and route are in the README table and the `## 0.2.1` CHANGELOG entry; the run records
  are archived in `.planning/milestones/v0.2.1-phases/` (`09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`,
  `10-LINUX-RUN.md`, Windows installer rounds) and are the only source for that wording.
- Facts the records show: `BBJ_HOME` must be in the Codex app-server daemon's environment (a shell
  export does not reach a daemon started earlier); a stale installer `~/.codex/hooks.json` fires
  alongside the plugin hook until `install-codex.sh --remove`; a Git-marketplace Codex upgrade
  0.2.0 → 0.2.1 on Linux kept the hook hash and trust.
- The hosted docs server requires sign-in since 2026-10-13 (OAuth, `offline_access`); both
  clients signed in on Linux with the shipped config.

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
| Phase 9 transfer is `git push origin gsd/planning-setup` (D-03 amended by the owner), never main, never a tag, never forced | A clone from GitHub cannot see local-only commits; the same method serves every round and both machines | ✓ Good — Phase 9 (977135c and d598854 pushed, both fast-forward) |
| Every platform defect is the owner's call: fix, alternative fix, known gap or capture first, at a blocking-human gate with no auto_select (D-10) | A fix or gap changes what Phase 10 may claim per platform | ✓ Good — Phase 9 (W-1, W-2, W-3 all `fix`; no macOS defect) |
| `hooks.json` ships a `commandWindows` entry (`C:\PROGRA~1\Git\bin\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE`) pinned by `layout_hook_command_windows` | Codex on Windows runs hooks through PowerShell, where `sh` is not on PATH; the entry made the Codex hook run and changes the hook hash, so Codex asks for trust again after upgrade | ✓ Good — Phase 9 (honoured by Codex, ignored without harm by Claude Code; limit: a default Git install on C: with 8.3 names, review WR-01) |
| PLAT-05 is tier 1 only: a `bbj-local reported` header for a bad file is a defect, not a pass | The 0.2.0 UAT on the Mac saw tier 2 only because BBj was not installed; the requirement asks for `bbjcpl` feedback | ✓ Good — Phase 9 (both macOS clients read `bbjcpl reported`) |
| D-09 (Windows installer route) met in round 2 after the launcher fix: `commandWindows` names `<Git root>\bin\sh.exe` from `cygpath -w /`, `--sh-exe` is written as given, `usr\bin` and paths without a drive letter are refused (D-27..D-29) | Round 1 was a tested negative: `Git\usr\bin\sh.exe` is silent from PowerShell because Git `usr\bin` is not on PATH | ✓ Good — Phase 10 (round-1 verdict superseded; WR-01 leaves one bypass of the `usr\bin` refusal, open) |
| The 0.2.1 tag targets the D-23 amendment merge M2 `4234e76`, not the first merge M1 `dad18f5` | The Git-marketplace upgrade reading (D-22) changed the 0.2.1 entry after M1; the tag must carry the final text | ✓ Good — Phase 10 (tag peels to `4234e76` = `origin/main`) |
| CI ShellCheck 0.9.0 reports SC2317 where local 0.11.0 reports SC2329; the directive in `tests/test_path_scrub.sh` names both codes | The same line must pass on both versions; recording or pinning the CI ShellCheck version is a follow-up | ✓ Good — Phase 10 (10-09; follow-up not implemented) |
| Codex plugin upgrade from a Git marketplace on Linux (Codex 0.162.1) keeps the hook hash and the trust; CHANGELOG states only that reading, the installer-route re-trust sentence stays | Observed 0.2.0 to 0.2.1, no re-trust asked; other upgrade cases stay under "Not run" | ✓ Good — Phase 10 (D-22, plan 10-11) |

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
*Last updated: 2026-10-15 after Phase 12*
