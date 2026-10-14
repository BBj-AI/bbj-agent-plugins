# Requirements: bbj-agent-plugins 0.2.1

**Defined:** 2026-10-12
**Core Value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).

**Milestone:** v0.2.1 Platform verification and release hygiene. The install wording may claim
only what a recorded run on that platform shows. BBj code is never executed; the runs on
Windows and macOS are human steps on the owner's machines. Codex moves to its native plugin
route (spikes 001-005, `.planning/spikes/`); `install-codex.sh` stays one release as fallback.

## v0.2.1 Requirements

### Platform verification

- [x] **PLAT-01**: On Windows with Git for Windows, a user installs the `bbj` plugin in Claude Code; after Write and after Edit, a bad `.bbj` gets `bbjcpl` feedback and a clean one gets silence
- [x] **PLAT-02**: On Windows, the hook's `cygpath` branch works on real paths: compiler path, `-P` list joined with `;`, drive-letter file paths, and a project path that contains a space
- [x] **PLAT-03**: On Windows, a user installs `bbj` through the Codex plugin route; Codex runs the plugin hook through Git for Windows' `sh` (with `commandWindows` or another fix if needed); after `apply_patch` the hook gives `bbjcpl` feedback for a bad file and nothing for a clean one
- [x] **PLAT-04**: On Windows with BBjServices running, `bbj-local` connects in Claude Code (when enabled) and in Codex (`codex plugin add bbj-local@basis-bbj`)
- [x] **PLAT-05**: On macOS with BBj installed, the Claude Code hook and the Codex plugin-route hook give `bbjcpl` (tier 1) feedback for a bad file and silence for a clean one
- [x] **PLAT-06**: Every defect a Windows or macOS run finds is fixed in the shipped hook or installer with a regression gate that runs in CI on fakes, or recorded as a known gap; each run's evidence (OS, client, BBj version, route, outcome) is recorded in the phase

### Codex plugin route

- [x] **CODEX-01**: A Codex user installs with `codex plugin marketplace add BBj-AI/bbj-agent-plugins` and `codex plugin add bbj@basis-bbj`; `bbj-docs` is registered with a working URL (a `.codex-plugin/plugin.json` overlay pointing at a literal-URL MCP file), both skills load, and Claude Code's `userConfig` and `claude plugin validate --strict` are unchanged
- [x] **CODEX-02**: After the user trusts the hook in `/hooks`, the plugin's unchanged `hooks/hooks.json` checks every BBj file an `apply_patch` writes (bbjcpl feedback for a bad file, silence for a clean one), proven in CI on fakes with a Codex plugin-route payload
- [x] **CODEX-03**: `bbj-local` is opt-in on Codex through `codex plugin add bbj-local@basis-bbj`, and the hook's no-route notice names the command that fits how the hook was installed (plugin route or `install-codex.sh --with-local`)
- [x] **CODEX-04**: Gates keep the docs URL identical in the Claude `docs_url` default and the Codex literal MCP file, keep every manifest (both plugins, marketplace, Codex overlay) at one version, and keep the hosted-host rule of `tests/test_layout.py` correct for the new file
- [x] **CODEX-05**: `docs/install-codex.md` leads with the plugin route (including the `/hooks` trust step, first-use tool prompts, the `BBJ_HOME` note and whether an upgrade asks for trust again, as observed) and keeps `install-codex.sh` as a documented fallback for this release
- [x] **CODEX-06**: A user with an existing `install-codex.sh` setup can switch to the plugin route by documented steps (or an installer option) that leave one hook entry, one copy of the skills and one `bbj-docs` server, verified once on Linux in a throwaway Codex home

### Test hardening

- [x] **MAINT-06**: `sh tests/run.sh` passes on a machine with `bbjcpl` or `bbjcplw` on `PATH`, because `tests/lib.sh` scrubs `PATH` for the no-route gates (review WR-01)
- [x] **MAINT-07**: `real_home_untouched` passes while a Codex daemon writes its runtime files (`logs_*.sqlite*`) and still fails on any change to Codex config, hooks or skills (D-2)
- [x] **MAINT-08**: The gate-prefix list in `.claude/CLAUDE.md` matches the prefixes the tests actually emit

### Install wording

- [ ] **DOCS-01**: README states per client (Claude Code, Codex) which platforms and check routes were verified, with versions; no "not yet run" remains for a configuration that was run
- [x] **DOCS-02**: The Windows and macOS sections of `docs/install-claude-code.md` and `docs/install-codex.md` describe the verified steps; a "not run" line stays only for a configuration that was not run
- [x] **DOCS-03**: The installer's `STATUS_LINE` and closing notes say the same as the docs
- [x] **DOCS-04**: Gates pin the new wording (`tests/test_install_codex.sh`, `tests/test_release_text.py`) so the old hints cannot return for a verified configuration

### Release

- [x] **REL-05**: The four planning-branch review-fix commits (`b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5`) are in the release tree
- [x] **REL-06**: The CONTENT_VERSION gate policy in `tests/test_release_text.py` is decided and recorded
- [ ] **REL-07**: Both plugins and both marketplace entries at 0.2.1; a `## 0.2.1` CHANGELOG entry whose Tested-against section covers Linux, Windows and macOS from the recorded runs
- [ ] **REL-08**: Full suite passes with live gates at skip=0 on the release tree; PR merged, annotated tag `0.2.1` pushed, GitHub Release published

## Future Requirements

- Windows or macOS CI runner
- Running the full test suite under Git Bash on Windows
- GitHub Copilot CLI plugin route (spike 004: marketplace and skills work as-is; `.github/plugin/plugin.json` overlay for the docs URL; hook input and output changes)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Native Windows hook without Git for Windows (PowerShell) | Git for Windows stays the supported route; a second hook implementation doubles the feedback paths |
| Docs-URL go-live constant | Waits for the hosted docs server to leave pre-production |
| Sending the 04/05 docs proposals | Done outside the repository |
| New skill content | Patch release; no feature work |
| GitHub Copilot CLI support | Next milestone: spike 004 showed the hook needs a Copilot input path and a second feedback format (`additionalContext` JSON), an anti-pattern in `.claude/CLAUDE.md` that needs its own decision |
| Removing `install-codex.sh` | Kept one release as the fallback route; removal is a later decision |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLAT-01 | Phase 9 | Complete |
| PLAT-02 | Phase 9 | Complete |
| PLAT-03 | Phase 9 | Complete |
| PLAT-04 | Phase 9 | Complete |
| PLAT-05 | Phase 9 | Complete |
| PLAT-06 | Phase 9 | Complete |
| CODEX-01 | Phase 8 | Complete |
| CODEX-02 | Phase 8 | Complete |
| CODEX-03 | Phase 8 | Complete |
| CODEX-04 | Phase 8 | Complete |
| CODEX-05 | Phase 8 | Complete |
| CODEX-06 | Phase 8 | Complete |
| MAINT-06 | Phase 7 | Complete |
| MAINT-07 | Phase 7 | Complete |
| MAINT-08 | Phase 7 | Complete |
| DOCS-01 | Phase 10 | Pending |
| DOCS-02 | Phase 10 | Complete |
| DOCS-03 | Phase 10 | Complete |
| DOCS-04 | Phase 10 | Complete |
| REL-05 | Phase 7 | Complete |
| REL-06 | Phase 7 | Complete |
| REL-07 | Phase 10 | Pending |
| REL-08 | Phase 10 | Pending |

**Coverage:**
- v0.2.1 requirements: 23 total (PLAT 6, CODEX 6, MAINT 3, DOCS 4, REL 4)
- Mapped to phases: 23 (Phase 7: 5, Phase 8: 6, Phase 9: 6, Phase 10: 6)
- Unmapped: 0

---
*Requirements defined: 2026-10-12*
*Last updated: 2026-10-12 after the roadmap revision for the Codex plugin route (Phases 7-10)*
