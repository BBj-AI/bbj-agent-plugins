# Requirements: bbj-agent-plugins 0.2.1

**Defined:** 2026-10-12
**Core Value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).

**Milestone:** v0.2.1 Platform verification and release hygiene. The install wording may claim
only what a recorded run on that platform shows. BBj code is never executed; the runs on
Windows and macOS are human steps on the owner's machines.

## v0.2.1 Requirements

### Platform verification

- [ ] **PLAT-01**: On Windows with Git for Windows, a user installs the `bbj` plugin in Claude Code; after Write and after Edit, a bad `.bbj` gets `bbjcpl` feedback and a clean one gets silence
- [ ] **PLAT-02**: On Windows, the hook's `cygpath` branch works on real paths: compiler path, `-P` list joined with `;`, drive-letter file paths, and a project path that contains a space
- [ ] **PLAT-03**: On Windows, a user runs `install-codex.sh` from Git Bash; Codex accepts the hook entry it writes (`commandWindows`, or the form Codex accepts, with the installer fixed to match); after `apply_patch` the hook gives `bbjcpl` feedback for a bad file and nothing for a clean one
- [ ] **PLAT-04**: On Windows with BBjServices running, `bbj-local` connects in Claude Code (when enabled) and in Codex (`--with-local`)
- [ ] **PLAT-05**: On macOS with BBj installed, the Claude Code hook and the Codex hook give `bbjcpl` (tier 1) feedback for a bad file and silence for a clean one
- [ ] **PLAT-06**: Every defect a Windows or macOS run finds is fixed in the shipped hook or installer with a regression gate that runs in CI on fakes, or recorded as a known gap; each run's evidence (OS, client, BBj version, route, outcome) is recorded in the phase

### Test hardening

- [ ] **MAINT-06**: `sh tests/run.sh` passes on a machine with `bbjcpl` or `bbjcplw` on `PATH`, because `tests/lib.sh` scrubs `PATH` for the no-route gates (review WR-01)
- [ ] **MAINT-07**: `real_home_untouched` passes while a Codex daemon writes its runtime files (`logs_*.sqlite*`) and still fails on any change to Codex config, hooks or skills (D-2)
- [ ] **MAINT-08**: The gate-prefix list in `.claude/CLAUDE.md` matches the prefixes the tests actually emit

### Install wording

- [ ] **DOCS-01**: README states per client (Claude Code, Codex) which platforms and check routes were verified, with versions; no "not yet run" remains for a configuration that was run
- [ ] **DOCS-02**: The Windows and macOS sections of `docs/install-claude-code.md` and `docs/install-codex.md` describe the verified steps; a "not run" line stays only for a configuration that was not run
- [ ] **DOCS-03**: The installer's `STATUS_LINE` and closing notes say the same as the docs
- [ ] **DOCS-04**: Gates pin the new wording (`tests/test_install_codex.sh`, `tests/test_release_text.py`) so the old hints cannot return for a verified configuration

### Release

- [ ] **REL-05**: The four planning-branch review-fix commits (`b0a4c62`, `3a42ebf`, `b600ac4`, `172e6a5`) are in the release tree
- [ ] **REL-06**: The CONTENT_VERSION gate policy in `tests/test_release_text.py` is decided and recorded
- [ ] **REL-07**: Both plugins and both marketplace entries at 0.2.1; a `## 0.2.1` CHANGELOG entry whose Tested-against section covers Linux, Windows and macOS from the recorded runs
- [ ] **REL-08**: Full suite passes with live gates at skip=0 on the release tree; PR merged, annotated tag `0.2.1` pushed, GitHub Release published

## Future Requirements

- Windows or macOS CI runner
- Running the full test suite under Git Bash on Windows

## Out of Scope

| Feature | Reason |
|---------|--------|
| Native Windows hook without Git for Windows (PowerShell) | Git for Windows stays the supported route; a second hook implementation doubles the feedback paths |
| Docs-URL go-live constant | Waits for the hosted docs server to leave pre-production |
| Sending the 04/05 docs proposals | Done outside the repository |
| New skill content | Patch release; no feature work |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|

**Coverage:**
- v0.2.1 requirements: 18 total
- Mapped to phases: 0 (filled by the roadmap)

---
*Requirements defined: 2026-10-12*
*Last updated: 2026-10-12 after initial definition*
