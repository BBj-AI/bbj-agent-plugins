# Roadmap: bbj-agent-plugins

## Milestones

- ✅ **v0.2.0 Skills makeover and local-first check** — Phases 1-6 (shipped 2026-10-12) — [archive](milestones/v0.2.0-ROADMAP.md)
- 🚧 **v0.2.1 Platform verification and release hygiene** — Phases 7-10 (in progress)

## Phases

<details>
<summary>✅ v0.2.0 Skills makeover and local-first check (Phases 1-6) — SHIPPED 2026-10-12</summary>

- [x] Phase 1: Repo-owned skills and local-first check route (7/7 plans) — completed 2026-10-10
- [x] Phase 2: Hook no-route notice (6/6 plans) — completed 2026-10-10
- [x] Phase 3: Example gate and structure lints (4/4 plans) — completed 2026-10-10
- [x] Phase 4: bbj-programming makeover (8/8 plans) — completed 2026-10-11
- [x] Phase 5: bbj-web-programming makeover (10/10 plans) — completed 2026-10-12
- [x] Phase 6: Release 0.2.0 (8/8 plans) — completed 2026-10-12

</details>

### 🚧 v0.2.1 Platform verification and release hygiene

**Milestone Goal:** Replace every "not yet run on Windows/macOS" hint with wording backed by real
runs, move Codex to its native plugin route, and ship both, with the fixes left over from 0.2.0,
as release 0.2.1.

Release 0.2.1 has four steps:

- **Phase 7** makes the suite pass on a maintainer machine that has `bbjcpl` on `PATH` or a
  running Codex daemon. It also brings the four 0.2.0 review-fix commits into the release tree
  and decides the release-text gate policy.
- **Phase 8** gives Codex users the native plugin route (`codex plugin add bbj@basis-bbj`): a
  `.codex-plugin` overlay with a literal docs URL, and the unchanged hook once the user trusts it
  in `/hooks`. It is proven on Linux and gated in CI on fakes. `install-codex.sh` stays as the
  documented fallback.
- **Phase 9** is the owner's runs of the Claude Code plugin and the Codex plugin route on Windows
  and macOS. Every defect a run finds gets a fix with a CI gate on fakes, or is recorded as a
  known gap.
- **Phase 10** states per client, platform and route only what the recorded runs show, then
  versions, merges, tags and publishes 0.2.1.

The design of the Codex route comes from spikes 001, 002, 003 and 005 (`.planning/spikes/`).
Spike 004 (Copilot CLI) belongs to the next milestone.

**Milestone:** v0.2.1 (plugin release 0.2.1, tag `0.2.1`). **Granularity:** standard.

**Constraints (all phases):**

- POSIX `sh` and Python 3 stdlib only; no new runtime dependencies.
- BBj code is never executed: every compiler call carries `-N` (compile-only).
- The hook never calls the hosted check.
- `bbj-local` stays opt-in in Claude Code and in Codex.
- Claude Code behaviour and `claude plugin validate --strict` stay unchanged.
- Skill and plugin names stay unchanged; no new skill content.
- CI never needs BBj or Codex.

**Phase Numbering:**

- Integer phases (7, 8, 9, 10): Planned milestone work
- Decimal phases (7.1, 7.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 7: Test hardening and release prep** - Suite green with `bbjcpl` on `PATH` and a running Codex daemon; 0.2.0 review fixes in the release tree; CONTENT_VERSION policy decided
- [ ] **Phase 8: Codex plugin route** - Codex installs `bbj` and the opt-in `bbj-local` from the `basis-bbj` marketplace with a working docs URL and the unchanged hook; installer kept as fallback; gated in CI on fakes
- [ ] **Phase 9: Windows and macOS verification** - Owner runs of the Claude Code plugin and the Codex plugin route on Windows and macOS; every defect fixed with a CI gate on fakes or recorded as a known gap
- [ ] **Phase 10: Install wording and release 0.2.1** - Per-client, per-platform, per-route wording backed by the recorded runs and pinned by gates; 0.2.1 merged, tagged and published

## Phase Details

### Phase 7: Test hardening and release prep

**Goal**: A maintainer gets a green suite on a machine that has `bbjcpl` on `PATH` or a running Codex daemon, and the release tree already carries the 0.2.0 review fixes and a decided release-text gate policy. The Codex and platform work then starts from a clean baseline.
**Depends on**: Nothing (first phase of v0.2.1; builds on the shipped 0.2.0, Phase 6)
**Requirements**: MAINT-06, MAINT-07, MAINT-08, REL-05, REL-06
**Success Criteria** (what must be TRUE):
  1. A maintainer with `bbjcpl` or `bbjcplw` on `PATH` runs `sh tests/run.sh` and it passes, because `tests/lib.sh` scrubs `PATH` for the no-route gates in `tests/test_noroute_notice.sh` and `tests/test_exit_contract.sh`; a CI gate that puts a fake compiler on `PATH` fails if the scrub is removed (MAINT-06)
  2. `real_home_untouched` passes while a Codex daemon writes `logs_*.sqlite*` files under the real Codex home, and still fails when Codex `config.toml`, `hooks.json` or the installed skills change; both directions are shown on fakes (MAINT-07)
  3. The gate-prefix list in `.claude/CLAUDE.md`, and in `.planning/codebase/CONVENTIONS.md` it is generated from, matches the prefixes `sh tests/run.sh` prints. `skills_` stays (`tests/test_skill_examples.py` still emits it), and the missing prefixes such as `notice_`, `local_`, `checkorder_` and `release_` are added (MAINT-08)
  4. The four review-fix commits `b0a4c62`, `3a42ebf`, `b600ac4` and `172e6a5` are in the branch that becomes the 0.2.1 release tree, and the full suite passes with them (REL-05)
  5. The owner has decided the CONTENT_VERSION policy of `tests/test_release_text.py` and it is recorded with its reason. The policy says how the content gates (`upgrade_addressed`, `upgrade_quotes`, `not_run`) behave at version 0.2.1 so that the Phase 10 release run can reach skip=0. Today they print `skip` for any version other than 0.2.0 (REL-06)

**Plans**: 4 plans

Plans:
**Wave 1**
- [ ] 07-01-PLAN.md — REL-06: generic `upgrade_addressed`, pinned fact gates FAIL with a re-pin message, mutation cases, policy docstring and PROJECT.md row (wave 1)
- [ ] 07-02-PLAN.md — MAINT-06: `no_compiler_path` / `no_compiler_env` PATH scrub in `tests/lib.sh`, no-route call sites, `tests/test_path_scrub.sh` fake-compiler and mutation proof (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*
- [ ] 07-03-PLAN.md — MAINT-07: `home_snapshot` / `home_diff` allowlist content snapshot, `real_home_untouched` switched to it, `tests/test_home_guard.sh` both-direction proof (wave 2)

**Wave 3** *(blocked on Wave 2 completion)*
- [ ] 07-04-PLAN.md — MAINT-08 gate-prefix list rebuilt from the suite transcript; REL-05 ancestry proof; D-02 local `main` fast-forward; phase gate (wave 3)

**Notes**: This phase lands first. The Windows and macOS machines of Phase 9 have `bbjcpl` on `PATH`, so without the scrub (review WR-01) the no-route gates fail there. A Codex daemon runs wherever Phase 8 works with real Codex. The review-fix commits change the install docs, the CHANGELOG and the release-text gates that Phases 8 and 10 rewrite, so they come in first. Tests use fakes only; nothing runs BBj.

### Phase 8: Codex plugin route

**Goal**: A Codex user installs `bbj`, and opts into `bbj-local`, from the `basis-bbj` marketplace with Codex's own plugin commands. They get a working `bbj-docs` server, both skills, and the unchanged compile-check hook once they trust it. Claude Code is unchanged, the route is proven on Linux and gated in CI on fakes, and `install-codex.sh` remains a documented fallback.
**Depends on**: Phase 7
**Requirements**: CODEX-01, CODEX-02, CODEX-03, CODEX-04, CODEX-05, CODEX-06
**Success Criteria** (what must be TRUE):
  1. On Linux, `codex plugin marketplace add` (from a local checkout before release, `BBj-AI/bbj-agent-plugins` after) and `codex plugin add bbj@basis-bbj` register `bbj-docs` at the literal docs URL, not `${user_config.docs_url}`, through a `.codex-plugin/plugin.json` overlay that points at a literal-URL MCP file. Both skills load. Claude Code keeps its `docs_url` option, and `claude plugin validate --strict` passes unchanged (CODEX-01)
  2. After the user trusts the hook in `/hooks`, the plugin's unchanged `hooks/hooks.json` (`Write|Edit`, which Codex matches against `apply_patch`, with `${CLAUDE_PLUGIN_ROOT}` set by Codex) checks every BBj file an `apply_patch` writes: `bbjcpl` feedback for a bad file, silence for a clean one. A CI gate feeds `bbj-check.sh` a Codex plugin-route payload on fakes and proves both outcomes without Codex (CODEX-02)
  3. `bbj-local` stays off on Codex until the user runs `codex plugin add bbj-local@basis-bbj`. The hook's no-route notice names that command on a plugin-route install, `install-codex.sh --with-local` on an installer install, and keeps its Claude Code wording. Gates on fakes cover all three (CODEX-03)
  4. A gate fails if any of the following happens: the docs URL in Claude's `docs_url` default and the one in the Codex literal MCP file differ; a manifest (both plugins, both marketplace entries, the Codex overlay) carries a different version; or the hosted host appears in a file other than these two (CODEX-04)
  5. `docs/install-codex.md` leads with the plugin route and keeps `install-codex.sh` as a documented fallback for this release. It covers the two install commands, the `/hooks` trust step, the first-use tool prompts, the `BBJ_HOME` note, and whether a plugin upgrade asks for hook trust again, as observed on Linux (CODEX-05)
  6. A user who installed with `install-codex.sh` (0.1.0 or 0.2.0) switches to the plugin route by documented steps or an installer option and ends with exactly one hook entry, one copy of the skills and one `bbj-docs` server: no double check, no double feedback, and the installer's `[mcp_servers.bbj-docs]` table no longer overriding the plugin's server. Verified once on Linux in a throwaway Codex home (CODEX-06)

**Plans**: TBD
**Notes**:
- This phase must land before Phase 9: Phase 9 verifies the plugin route on Windows and macOS by following the steps documented here.
- Spike facts:
  - The overlay is variant A of spike 002; a root `mcp.json` does not override `.mcp.json`.
  - Plugin hooks are skipped until trusted.
  - The trusted hash covers the versioned cache path, so an upgrade probably asks for trust again. Observe it on Linux.
  - The plugin route ships no tool approvals: all tools prompt on first use, an accepted trade-off against the installer's pre-approvals.
  - The installer's `tools/list` probe has no plugin counterpart; the docs and the notice replace it.
- Real-Codex checks run in throwaway homes, never the real `~/.codex` and not under `/tmp`. Spike 001's fake Responses server may be reused for a local check, but not in CI.
- Billed real-model runs only with the user's approval for each run.

### Phase 9: Windows and macOS verification

**Goal**: The Claude Code plugin and the Codex plugin route work on real Windows and macOS machines on the compile-only `bbjcpl` route, and `bbj-local` connects on Windows where BBjServices runs. Every defect a run finds is fixed with a CI gate on fakes or recorded as a known gap, and every run is on record.
**Depends on**: Phase 8
**Requirements**: PLAT-01, PLAT-02, PLAT-03, PLAT-04, PLAT-05, PLAT-06
**Success Criteria** (what must be TRUE):
  1. On Windows with Git for Windows, Claude Code with the `bbj` plugin gives `bbjcpl` feedback after Write and after Edit of a bad `.bbj` file and stays silent for a clean one. The `cygpath` branch is shown working on real paths: the compiler path, the `-P` list joined with `;`, drive-letter file paths, and a project path that contains a space (PLAT-01, PLAT-02)
  2. On Windows, a user installs `bbj` through the Codex plugin route. Codex runs the plugin hook through Git for Windows' `sh`, with `commandWindows` or another fix if needed. After `apply_patch` the hook gives `bbjcpl` feedback for a bad file and nothing for a clean one. The run settles spike 005's three Windows unknowns: whether Codex runs `sh "..."` through Git for Windows, whether `commandWindows` in a plugin `hooks.json` is honoured, and whether `CLAUDE_PLUGIN_ROOT` expands to a path `sh` accepts (PLAT-03)
  3. On Windows with BBjServices running, `bbj-local` connects in Claude Code once the user enables it and in Codex after `codex plugin add bbj-local@basis-bbj`; it stays off unless the user opts in (PLAT-04)
  4. On macOS with BBj installed, the Claude Code hook and the Codex plugin-route hook each give tier-1 `bbjcpl` feedback for a bad file and silence for a clean one (PLAT-05)
  5. The phase records each run (OS, client and version, BBj version, route, outcome). Every defect found is either fixed in the shipped hook (script or `hooks.json`), plugin files or installer with a regression gate that runs in CI on fakes, or recorded as a known gap. The Linux suite stays green (PLAT-06)

**Plans**: TBD
**Notes**:
- The owner runs these steps by hand on their own machines: Windows (Git for Windows, BBj with `bbjcpl`, Claude Code, Codex CLI) and Mac (BBj with `bbjcpl` must be installed first).
- Evidence is recorded in the same way as the v0.2.0 Phase 6 UAT.
- Any hook fix keeps the exit contract (exit 0 or 2, empty stdout) and the static safety gates: `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, and never the hosted check.
- Out of scope: a native Windows hook without Git for Windows, a Windows or macOS CI runner, and running the full suite under Git Bash.

### Phase 10: Install wording and release 0.2.1

**Goal**: Users read, per client, platform and check route, exactly what was verified, and nothing more than the recorded runs show. For Codex the plugin route comes first and the installer is the fallback. Release 0.2.1 ships with that wording, the Codex plugin route, the 0.2.0 review fixes and the Phase 9 fixes.
**Depends on**: Phase 9
**Requirements**: DOCS-01, DOCS-02, DOCS-03, DOCS-04, REL-07, REL-08
**Success Criteria** (what must be TRUE):
  1. README states, for Claude Code and for Codex, which platforms (Linux, Windows, macOS) and check routes (`bbjcpl`, `bbj-ls`) were verified, with client and BBj versions. For Codex it leads with the plugin route and names `install-codex.sh` as the fallback. No "not yet run" remains for a configuration that was run (DOCS-01)
  2. The Windows and macOS sections of `docs/install-claude-code.md` and `docs/install-codex.md` describe the steps that were run, the plugin route first for Codex. A "not run" line remains only for a configuration that was not run, and the installer's `STATUS_LINE` and closing notes say the same as the docs (DOCS-02, DOCS-03)
  3. `tests/test_install_codex.sh` and `tests/test_release_text.py` fail if an old "not yet run" hint comes back for a verified configuration, or if the installer text and the docs drift apart (DOCS-04)
  4. Both plugins, both marketplace entries, the Codex overlay and `tests/test_layout.py` read 0.2.1, and `claude plugin validate --strict` passes. The `## 0.2.1` CHANGELOG entry's Tested against section covers Linux, Windows and macOS from the recorded runs (REL-07)
  5. The full suite passes on the release tree with live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`) at skip=0. With the owner's confirmation before each push, merge, tag push and Release: the PR is merged, the annotated tag `0.2.1` (no `v` prefix) is pushed, and the GitHub Release is published (REL-08)

**Plans**: TBD
**Notes**:
- The release follows the v0.2.0 Phase 6 pattern, with a blocking owner confirmation before every push, merge, tag push and Release.
- The CHANGELOG entry keeps the sections that `tests/test_release_text.py` requires for every version (Upgrading, Tested against, Not run, in that order) and follows the CONTENT_VERSION policy decided in Phase 7.
- After release, `codex plugin marketplace add BBj-AI/bbj-agent-plugins` installs from the git source; Phase 8 tested from a local checkout.

## Progress

**Execution Order:**
Phases execute in numeric order: 7 → 8 → 9 → 10

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 7. Test hardening and release prep | v0.2.1 | 0/4 | Planned | - |
| 8. Codex plugin route | v0.2.1 | 0/TBD | Not started | - |
| 9. Windows and macOS verification | v0.2.1 | 0/TBD | Not started | - |
| 10. Install wording and release 0.2.1 | v0.2.1 | 0/TBD | Not started | - |
