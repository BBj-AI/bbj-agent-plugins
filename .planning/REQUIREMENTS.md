# Requirements: bbj-agent-plugins

**Defined:** 2026-10-15
**Core Value:** Every BBj claim and every code example the plugin hands an agent is correct: documented (URL cited) or reproduced on a real BBj, and every code block passes the local checks (`bbjcpl -t` and `bbj-ls`).

## v0.2.2 Requirements

Milestone v0.2.2 Plugin-only cleanup. Each maps to one roadmap phase.

### Installer removal

- [x] **INST-01**: `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, `tests/test_install_codex.sh`, the installer gates in `tests/test_install_pages.sh`, the AGENTS-snippet byte-identity gate in `tests/test_check_order.py` and any fake used only by them are removed
- [x] **INST-02**: No tracked file outside `.planning/` and the CHANGELOG entries of 0.2.1 and earlier names `install-codex.sh`, `AGENTS-snippet` or the word "installer"; a gate keeps them out (11-CONTEXT D-10, D-11)
- [x] **INST-03**: The hook has no installer-route branch: on Codex the no-route notice names only the plugin commands, and the hook still checks `apply_patch` writes on the plugin route

### Naming

- [x] **NAME-01**: The docs server is named `bbj` in `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`; no `bbj-docs` remains in shipped files outside CHANGELOG history; a gate keeps it out
- [x] **NAME-02**: Skills, the check-order block, the hook notice and the docs name `bbj` and give the sign-in with the labels the real clients show (expected `/mcp` → `plugin:bbj:bbj` and `codex mcp login bbj`)
- [ ] **NAME-03**: Sign-in under the new name is confirmed on real Claude Code and real Codex (Linux at least) on the release tree
- [x] **NAME-04**: One term list is written down in the conventions (plugin `bbj-local` vs server `bbj-ls`, "docs server", "hosted check", "tier 1"/"tier 2"); docs, skills and test names follow it; a gate rejects the retired variants in shipped Markdown

### Docs

- [x] **DOCS-05**: One plugin-only install page covers Claude Code and Codex and replaces `docs/install-claude-code.md` and `docs/install-codex.md`; README and the link gates point to it
- [x] **DOCS-06**: The README "Verified" table and the install wording drop the installer route; every remaining per-platform claim is still backed by a run record
- [x] **DOCS-07**: The README "Claude Code on macOS" cell has one reading (date or "run directly" qualifier added)

### Fixes

- [x] **FIX-01**: A Codex user on Windows with Git outside `C:\Program Files\Git` gets a working hook or a visible message, never a silent no-op (Phase 9 review WR-01)
- [x] **FIX-02**: A many-file `apply_patch` with no route stays within the 30 s hook timeout: the tier-2 connect timeout is paid once per hook run, not per file (Phase 9 review WR-02)
- [x] **FIX-03**: `windows_codex_backslash_dotdot_skipped` fails when the backslash conversion is removed, shown by a mutation run (Phase 9 review WR-03)

### Maintenance

- [x] **MAINT-09**: The gate-prefix block in `.claude/CLAUDE.md` and `CONVENTIONS.md` lists exactly the prefixes `sh tests/run.sh` prints; a gate checks it
- [x] **MAINT-10**: No function, fake, fixture or gate remains whose only user was the installer or a retired feature
- [ ] **MAINT-11**: `.planning/codebase/` is refreshed after the removal and the rename

### Release

- [ ] **REL-09**: Five versions at 0.2.2; CHANGELOG `## 0.2.2` with Upgrading and Tested against sections; release-text gates re-pinned to 0.2.2
- [ ] **REL-10**: Full suite with live gates passes `fail=0 skip=0`; PR merged; annotated tag `0.2.2` on the merge commit; GitHub Release published

## Future Requirements

- Pin or record the CI ShellCheck version (0.9.0 in CI, 0.11.0 locally)
- Copilot CLI support (spike 004)

## Out of Scope

| Feature | Reason |
|---------|--------|
| OAuth client id as a setting | One public client per tenant, pre-production and production share it, and Codex cannot expand `${user_config.*}`; the literal id stays in both configs until a second tenant exists |
| Renaming the plugins or the marketplace | Users and docs refer to `bbj`, `bbj-local` and `basis-bbj` |
| Migration text for installer users (was INST-04) | No outside user ever used the installer; docs and the 0.2.2 CHANGELOG read as if it never existed (Phase 11 CONTEXT D-01, D-02) |
| Upgrade text for users of earlier versions (sign in again, redo approvals, clean up old-name entries) | The owner does not want earlier versions referenced; docs and the 0.2.2 CHANGELOG read as if the server was always `bbj` (Phase 12 CONTEXT D-12) |
| Installer review warnings 10-REVIEW WR-01..WR-03 | Closed by removing the installer |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| INST-01 | Phase 11 | Complete |
| INST-02 | Phase 11 | Complete |
| INST-03 | Phase 11 | Complete |
| NAME-01 | Phase 12 | Complete |
| NAME-02 | Phase 12 | Complete |
| NAME-03 | Phase 15 | Pending |
| NAME-04 | Phase 14 | Complete |
| DOCS-05 | Phase 14 | Complete |
| DOCS-06 | Phase 11 | Complete |
| DOCS-07 | Phase 14 | Complete |
| FIX-01 | Phase 13 | Complete |
| FIX-02 | Phase 13 | Complete |
| FIX-03 | Phase 13 | Complete |
| MAINT-09 | Phase 14 | Complete |
| MAINT-10 | Phase 14 | Complete |
| MAINT-11 | Phase 14 | Pending |
| REL-09 | Phase 15 | Pending |
| REL-10 | Phase 15 | Pending |

**Coverage:**
- v0.2.2 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0

Per phase: Phase 11 (4), Phase 12 (2), Phase 13 (3), Phase 14 (6), Phase 15 (3).

---
*Requirements defined: 2026-10-15*
*Last updated: 2026-10-15 after Phase 12 discussion (no upgrade text; NAME-02/NAME-03 amended)*
