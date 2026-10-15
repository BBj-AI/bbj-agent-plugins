# Roadmap: bbj-agent-plugins

## Milestones

- ✅ **v0.2.0 Skills makeover and local-first check** — Phases 1-6 (shipped 2026-10-12) — [archive](milestones/v0.2.0-ROADMAP.md)
- ✅ **v0.2.1 Platform verification and release hygiene** — Phases 7-10 (shipped 2026-10-15) — [archive](milestones/v0.2.1-ROADMAP.md)
- 🚧 **v0.2.2 Plugin-only cleanup** — Phases 11-15 (in progress)

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

<details>
<summary>✅ v0.2.1 Platform verification and release hygiene (Phases 7-10) — SHIPPED 2026-10-15</summary>

- [x] Phase 7: Test hardening and release prep (6/6 plans) — completed 2026-10-13
- [x] Phase 8: Codex plugin route (8/8 plans) — completed 2026-10-13
- [x] Phase 9: Windows and macOS verification (8/8 plans) — completed 2026-10-13
- [x] Phase 10: Install wording and release 0.2.1 (17/17 plans) — completed 2026-10-15

</details>

### 🚧 v0.2.2 Plugin-only cleanup

**Milestone Goal:** Ship the plugin as the only install route for Claude Code and Codex, under
consistent names, with the open review debt cleared, as release 0.2.2.

Release 0.2.2 has five steps:

- **Phase 11** removes the Codex installer route: the script, the snippet, their tests, gates and
  fakes, the hook's installer branch, and the installer route in the README table and the install
  wording. A gate keeps `install-codex.sh` out.
- **Phase 12** renames the docs server `bbj-docs` to `bbj` in both MCP configs, the skills, the
  hook notice, the docs and the tests. An owner reading on real clients checks that the sign-in
  commands the docs give are the ones the clients show. A gate keeps `bbj-docs` out.
- **Phase 13** closes the three Phase 9 review warnings on the Windows hook: no silent no-op when
  Git is not under `C:\Program Files\Git`, one tier-2 connect timeout per hook run, and a
  backslash gate that catches a regression.
- **Phase 14** settles docs and conventions on the stable file set: one plugin-only install page
  for both clients, one written term list with a gate, the gate-prefix block checked against the
  suite, the dead-code sweep and a refreshed codebase map.
- **Phase 15** writes the `## 0.2.2` CHANGELOG entry (sign-in again
  under `bbj`), bumps the five versions, runs the full suite with live gates, then merges, tags and
  publishes 0.2.2.

**Order:** The removal comes before the rename, so the rename does not touch files that are about
to be deleted. Phase 13 needs only Phase 11 and can run alongside Phase 12. The install page waits
for Phases 11-13 because it carries the new name, no installer, and the Windows hook behaviour that
Phase 13 leaves. The term pass, the prefix gate and the map refresh run once the file set is
stable. The CHANGELOG line of NAME-03 waits for the release: `changelog_heading` in
`tests/test_release_text.py` requires the newest heading to be the current version and allows no
placeholder entry, so `## 0.2.2` can only appear in the bump commit.

**Milestone:** v0.2.2 (plugin release 0.2.2, tag `0.2.2`). **Granularity:** standard.

**Constraints (all phases):**

- POSIX `sh` and Python 3 stdlib only; no new runtime dependencies.
- BBj code is never executed: every compiler call carries `-N` (compile-only).
- The hook never calls the hosted check; tier 2 is loopback only.
- The hook exit contract is unchanged: exit 0 or 2, empty stdout.
- `bbj-local` stays opt-in in Claude Code and in Codex.
- Only the docs server is renamed. The plugins `bbj` and `bbj-local`, the server `bbj-ls`, the
  marketplace `basis-bbj` and both skill names keep their names.
- The literal OAuth client id stays in both MCP configs; it does not become a setting.
- CI never needs BBj, Codex or Windows.
- Owner-run checks (real clients, Windows, live gates) are marked in their criterion. Every push,
  merge, tag push and Release needs the owner's confirmation first.

**Phase Numbering:**

- Integer phases (11, 12, 13, 14, 15): Planned milestone work
- Decimal phases (11.1, 11.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 11: Installer removal** - The plugin is the only install route: installer, snippet, their tests, gates and fakes, the hook's installer branch and the installer wording are gone; a gate keeps `install-codex.sh` out
- [ ] **Phase 12: Docs server renamed to bbj** - `bbj-docs` becomes `bbj` in both MCP configs, the skills, the hook notice, the docs and the tests; sign-in commands read on real clients; a gate keeps the old name out
- [ ] **Phase 13: Windows hook fixes** - Phase 9 review WR-01..WR-03 closed: no silent no-op for a non-default Git location, one tier-2 connect timeout per hook run, a backslash gate that catches a regression
- [ ] **Phase 14: One install page and one term list** - One plugin-only install page for both clients, one written term list with a gate, the gate-prefix block checked against the suite, dead code swept, codebase map refreshed
- [ ] **Phase 15: Release 0.2.2** - `## 0.2.2` entry with the sign-in under `bbj`, five versions bumped, full suite with live gates, merged, tagged `0.2.2`, published

## Phase Details

### Phase 11: Installer removal

**Goal**: A Codex user has exactly one install route, the plugin, and nothing in the repository still offers, tests or describes the installer. The hook treats every Codex run as the plugin route.
**Depends on**: Nothing (first phase of v0.2.2; builds on the shipped 0.2.1, Phase 10)
**Requirements**: INST-01, INST-02, INST-03, DOCS-06
**Success Criteria** (what must be TRUE):
  1. `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, `tests/test_install_codex.sh`, the `installer_` gates of `tests/test_install_pages.sh`, the snippet copy in `tests/test_check_order.py` and every fake only they used are gone. `sh tests/run.sh` passes, and `tests/test_check_order.py` still pins the check-order block byte-identical in the two SKILL.md files (INST-01)
  2. A gate fails when `install-codex.sh`, `AGENTS-snippet` or the word "installer" appears in a tracked file outside `.planning/` and the CHANGELOG entries of 0.2.1 and earlier; a planted mention makes it fail. `tests/test_release_text.py` and `tests/test_release_text_mutation.sh` pass at 0.2.1 without reading the installer (INST-02)
  3. On a Codex `apply_patch` payload with no check route, the no-route notice names only the plugin commands (`codex plugin add bbj-local@basis-bbj`), with or without `CLAUDE_PLUGIN_ROOT` set, and the hook has no code path for the installer route. The `plugin_route_` gates still give `bbjcpl` feedback for a bad file and silence for a clean one (INST-03)
  4. The README "Verified" table, the README install text and both install pages no longer describe the installer route. Every per-platform claim left traces to a run record (`08-LINUX-RUN.md`, `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-LINUX-RUN.md` in `.planning/milestones/v0.2.1-phases/`); no claim remains that only the installer record `10-WINDOWS-INSTALLER-RUN.md` backed (DOCS-06)

**Plans**: 5/5 plans executed

Plans:
**Wave 1**
- [x] 11-01-PLAN.md — Hook gives one Codex no-route text (plugin commands) whether CLAUDE_PLUGIN_ROOT is set, empty or unset; notice gates prove it (INST-03; wave 1)
- [x] 11-02-PLAN.md — Release-text, check-order, layout and static gates stop reading the installer and snippet while they still exist (INST-01, INST-02; wave 1)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 11-03-PLAN.md — README and both install pages drop the installer route; page pins follow; every per-platform claim traced to a run record in 11-CLAIM-TRACE.md (DOCS-06; wave 2)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 11-04-PLAN.md — Delete the installer, snippet, their test, the home guard, fake codex and the snapshot helpers; `sh tests/ci.sh` green (INST-01; wave 3)

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 11-05-PLAN.md — `layout_no_retired_route` gate with mutation proof of every scope and exemption; `.claude/CLAUDE.md` cleaned (INST-02; wave 4)

**Notes**:
- `upgrade_quotes` pins three installer lines byte for byte against `codex/install-codex.sh`, and `tests/test_release_text_mutation.sh` copies the installer into its scratch tree. Both must stop depending on it in this phase, or the deletion turns the suite red.
- `tests/lib.sh` and the hook's header comments carry installer wording too (route detection D-07, D-08 of Phase 8); the `codex_payload` helper stays, the installer route does not.
- The two install pages stay in this phase, stripped of the installer; Phase 14 merges them into one.
- The installer mentions in `.claude/CLAUDE.md` and `.planning/codebase/` are generated from the codebase map and go with its refresh in Phase 14 (MAINT-11).
- No migration text for installer users anywhere: INST-04 was dropped in the Phase 11 discussion (11-CONTEXT D-01, D-02); no outside user ever used the installer.
- Tests use fakes only; nothing runs BBj.

### Phase 12: Docs server renamed to bbj

**Goal**: Users and agents meet the docs server under one name, `bbj`, in both clients: in the MCP configs, the skills, the hook notice, the docs and the sign-in commands. The commands the docs give are the ones the real clients show.
**Depends on**: Phase 11
**Requirements**: NAME-01, NAME-02
**Success Criteria** (what must be TRUE):
  1. `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json` declare the server as `bbj`, with the URL and the OAuth block otherwise unchanged; `layout_` gates pin the name in both files, and `claude plugin validate --strict` passes (NAME-01)
  2. A gate fails when `bbj-docs` appears in a shipped file (manifests, MCP configs, hook, skills, README, docs) outside the CHANGELOG entries of 0.2.1 and earlier; a planted mention makes it fail (NAME-01)
  3. Both skills, the check-order block (still byte-identical in the two SKILL.md files), the hook's no-route notice and the docs name the server `bbj` and give the sign-in as `/mcp` → `bbj` in Claude Code and `codex mcp login bbj` in Codex. The `notice_`, `checkorder_` and `skills_` gates pass with the new text (NAME-02)
  4. Owner-run, Linux: with the plugin installed from a checkout of this phase, real Claude Code lists the renamed server in `/mcp`, real Codex accepts `codex mcp login bbj`, and the sign-in completes in both. The docs use the label the clients show, and the reading lists what a 0.2.1 user has to redo (sign-in, tool approvals or permission rules kept under the old name) for the Phase 15 Upgrading text (NAME-02)

**Plans**: TBD

**Notes**:
- NAME-03 (sign-in confirmed on real clients and stated in the CHANGELOG) is mapped to Phase 15, because its CHANGELOG half can only land in the bump commit. Criterion 4 is the early reading that keeps the docs from naming the wrong label; Phase 15 repeats the sign-in on the release tree.
- Tool names that the clients build from the server name change with it; skills and notice must not quote the old prefix.
- The user-config keys `docs_url` and `bbj_home` keep their names.
- Real-client runs use throwaway homes, never the real `~/.codex`, and not under `/tmp` (Phase 8 practice).
- The skill example gate stays green: the rename touches prose, not `bbj` blocks.

### Phase 13: Windows hook fixes

**Goal**: The hook on Windows never fails silently because of where Git for Windows is installed, never runs past the 30 s hook timeout on a large patch with no check route, and the backslash path gate guards what it claims to.
**Depends on**: Phase 11 (works on the hook without the installer branch); independent of Phase 12 and can run alongside it
**Requirements**: FIX-01, FIX-02, FIX-03
**Success Criteria** (what must be TRUE):
  1. A Codex user on Windows whose Git for Windows is not at `C:\Program Files\Git` gets a hook that checks the file, or a visible message that names the missing `sh.exe`, never a silent no-op. Owner-run: confirmed on a real Windows machine. If the owner decides against a run, the limit is recorded as a known gap with its reason, and the Phase 14 install page and the Phase 15 CHANGELOG state it. `layout_hook_command_windows` pins the new `commandWindows`, and `claude plugin validate --strict` passes (FIX-01)
  2. A gate on fakes runs one hook call over a Codex `apply_patch` that writes many BBj files, with no route, on the Windows path (5 s connect timeout): tier 2 is tried once, the other files skip it, and the run ends well under 30 s. When `bbj-ls` answers, every file is still checked. Restoring the per-file connect makes the gate fail (FIX-02)
  3. A mutation run that removes the backslash conversion makes `windows_codex_backslash_dotdot_skipped` fail, and the unmutated tree passes it; the mutation case is kept in the suite (FIX-03)
  4. The exit contract and the safety gates hold after the fixes: exit 0 or 2 with empty stdout, `-N` on every compiler call, loopback-only `curl` with `--noproxy '*'` and `--proto =http`, never the hosted check; `sh tests/ci.sh` passes (FIX-01, FIX-02, FIX-03)

**Plans**: TBD

**Notes**:
- Source of the three warnings: `09-REVIEW.md` and `09-REVIEW-DISPOSITION.md` in `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/`.
- A new `commandWindows` changes the hook hash, so Codex asks for `/hooks` trust again after the upgrade; the Phase 15 Upgrading text says so.
- CI has no Windows runner. The fake `cygpath` seams (`FAKE_CYGDRIVE_ROOT`) and the `windows_` and `tier2_connect_timeout_` gates are the CI proof; real Windows is an owner run. Fix or known gap per defect is the owner's call (D-10 precedent from Phase 9).

### Phase 14: One install page and one term list

**Goal**: A user reads one install page for both clients. A maintainer finds one set of terms, a gate-prefix list that matches the suite, no code left over from retired features, and a codebase map that describes the repository as it now is.
**Depends on**: Phase 11, Phase 12, Phase 13
**Requirements**: DOCS-05, DOCS-07, NAME-04, MAINT-09, MAINT-10, MAINT-11
**Success Criteria** (what must be TRUE):
  1. One plugin-only install page covers Claude Code and Codex and replaces `docs/install-claude-code.md` and `docs/install-codex.md`, which are gone. The README and the link gates of `tests/test_install_pages.sh` point to it, and no link in the repository points to a removed page (DOCS-05)
  2. The README "Claude Code on macOS" cell has one reading, with the run date or the "hook run directly" qualifier as `09-MACOS-RUN.md` records it, and a gate pins it (DOCS-07)
  3. One term list is written down in the conventions (`.planning/codebase/CONVENTIONS.md` and `.claude/CLAUDE.md`): plugin `bbj-local` vs server `bbj-ls`, "docs server", "hosted check", "tier 1" and "tier 2". The README, the install page, both skills and the test and gate names follow it, and a gate rejects the retired variants in shipped Markdown; a planted variant makes it fail (NAME-04)
  4. The gate-prefix block in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` lists exactly the prefixes `sh tests/run.sh` prints after this milestone's removals and renames, and a gate fails on a missing or an extra prefix (MAINT-09)
  5. No function, fake, fixture or gate remains whose only user was the installer or another retired feature, and a recorded sweep lists what went. `.planning/codebase/` and the generated sections of `.claude/CLAUDE.md` are refreshed and name neither the installer nor `bbj-docs` (MAINT-10, MAINT-11)

**Plans**: TBD

**Notes**:
- Order inside the phase: the install page and the term pass first, because the term pass may rename tests and gates; then the prefix gate (MAINT-09); the sweep and the map refresh last.
- The new page keeps the record-backed wording of Phase 11 (DOCS-06), and the release-text gates (`no_unrun_hint`, the per-platform version gates) read the new page instead of the two old ones.
- The page states the Windows hook behaviour Phase 13 leaves (fixed, or the recorded known gap).
- The skill example gate stays green; prose edits touch no `bbj` block, and `bbj-programming` SKILL.md stays near 150 lines.

### Phase 15: Release 0.2.2

**Goal**: Release 0.2.2 ships the plugin-only route under the new server name with the Windows fixes, and its CHANGELOG tells upgrading users exactly what to do: sign in again under `bbj`.
**Depends on**: Phase 14
**Requirements**: NAME-03, REL-09, REL-10
**Success Criteria** (what must be TRUE):
  1. Both plugin manifests, both marketplace entries and the Codex overlay read 0.2.2, as do `tests/test_layout.py` and the README version line. The release-text gates are re-pinned to the facts of 0.2.2 and pass, and `claude plugin validate --strict` passes. CHANGELOG `## 0.2.2` has Upgrading, Tested against and Not run, with Tested against taken from the release run (REL-09)
  2. Owner-run, Linux at least: on the release tree, real Claude Code and real Codex sign in to the docs server under `bbj`. The Upgrading section states that users sign in again and names each per-server setting they redo, as the Phase 12 reading and this run show (NAME-03)
  3. Owner-run: the full suite with live gates (`BBJ_LS_LIVE=1`, `BBJ_SKILLS_LIVE=1`) passes `fail=0 skip=0` on the release tree, and the suite line is recorded (REL-10)
  4. With the owner's confirmation before each push, merge, tag push and Release: the PR is merged, the annotated tag `0.2.2` (no `v`) is on the merge commit, and the GitHub Release is published (REL-10)

**Plans**: TBD

**Notes**:
- If Phase 13 changed `commandWindows`, the Upgrading section also says that Codex asks for `/hooks` trust again after the upgrade.
- The Not run section lists only configurations absent from the run records, as in 0.2.1.
- The release follows the Phase 6 and Phase 10 pattern: the tag goes on the final merge commit that carries the released text.

## Progress

**Execution Order:**
Phases execute in numeric order: 11 → 12 → 13 → 14 → 15 (Phase 13 may run alongside Phase 12)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 11. Installer removal | v0.2.2 | 5/5 | In Progress | - |
| 12. Docs server renamed to bbj | v0.2.2 | 0/TBD | Not started | - |
| 13. Windows hook fixes | v0.2.2 | 0/TBD | Not started | - |
| 14. One install page and one term list | v0.2.2 | 0/TBD | Not started | - |
| 15. Release 0.2.2 | v0.2.2 | 0/TBD | Not started | - |
