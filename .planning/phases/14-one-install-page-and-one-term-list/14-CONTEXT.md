# Phase 14: One install page and one term list - Context

**Gathered:** 2026-10-16
**Status:** Ready for planning

<domain>
## Phase Boundary

A user reads one plugin-only install page for both clients (`docs/install.md`), which replaces
`docs/install-claude-code.md` and `docs/install-codex.md`. The README "Verified" cells each have one
reading backed by a run record. A maintainer finds one written term list, enforced by a gate in shipped
Markdown; a gate-prefix block that matches exactly what `sh tests/run.sh` prints, enforced by a gate;
no code left from retired features (a recorded sweep); and a refreshed `.planning/codebase/` plus the
generated sections of `.claude/CLAUDE.md`. Requirements: DOCS-05, DOCS-07, NAME-04, MAINT-09,
MAINT-10, MAINT-11. No new capability; Phase 15 does the release.

</domain>

<decisions>
## Implementation Decisions

### Carried forward (not re-asked)
- Docs read as if the installer never existed (11 D-01) and as if the docs server was always `bbj`;
  no reference to earlier versions anywhere (12 D-12). CHANGELOG entries 0.2.1 and earlier stay
  byte-identical (11 D-03).
- A role noun always comes with the name: "the docs server `bbj`", "the plugin `bbj`" (12 D-04). Tool
  prefixes built from the server name appear only on the install page (12 D-06).
- The page keeps the record-backed Windows text of 13-06 (copied from `13-WINDOWS-RUN.md`
  "## For the install page") and the record-backed wording of Phase 11 (DOCS-06).
- The `layout_no_retired_route` and `layout_no_old_server_name` gates must stay green through the
  refresh of `.claude/CLAUDE.md`; `.planning/codebase/` is exempt from them, so MAINT-11 checks it by hand.

### Install page (DOCS-05)
- **D-01:** One page, organised by step, both clients side by side: Requirements; 1. Add the
  marketplace; 2. Install; 3. Sign in to the docs server `bbj`; 4. Enable the plugin `bbj-local`;
  Options; Check routes; Not covered; Windows; macOS; Update and remove. Each step shows the Claude Code
  command and the Codex command next to each other. Client-only details (Codex `/hooks` trust, tool
  prompts on first use, pre-approving the docs tools, the Codex daemon environment for `BBJ_HOME`, the
  Claude Code `docs_url` option) sit inside the step they belong to, marked for the client. Nothing is
  said twice.
- **D-02:** File name `docs/install.md`. Both old pages are deleted (`git rm`), no redirect stub. No
  link anywhere points to a removed page.
- **D-03:** The README keeps the shortest path per client (about two commands each: marketplace add +
  install) and links to `docs/install.md` for everything else.
- **D-04:** The link gates of `tests/test_install_pages.sh`, the page pins (`claude_`, `codex_`,
  `link_`, `readme_`) and the release-text gates (`no_unrun_hint`, `claude_version_single`,
  `codex_version_single`, `HINT_FILES` in `tests/test_release_text.py` and its mutation script) read
  `docs/install.md` instead of the two old pages. Every pinned sentence keeps its run-record backing.

### Verified table (DOCS-07)
- **D-05:** The Claude Code / macOS cell reads `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code
  2.1.296 ``. Reason: `09-MACOS-RUN.md` backs `bbj-ls` there only with `smoke.sh tier2`, where the
  hook was run by hand and not through Claude Code; `bbjcpl` was seen through Claude Code.
- **D-06:** All six cells are audited against their run records (`08-LINUX-RUN.md`,
  `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-LINUX-RUN.md`, `13-WINDOWS-RUN.md`; `12-LINUX-RUN.md`
  where relevant). Any route seen only with the hook run directly gets the same "(hook run directly)"
  qualifier. The intro sentence above the table defines the qualifier. The audit is recorded (which
  record and which reading backs each cell); a gate pins every cell, not only macOS.

### Term list (NAME-04)
- **D-07:** User-facing text names the check routes by tool: "the `bbjcpl` check", "`bbj-ls`", "the
  hosted check" (`bbj_check_syntax` of the docs server `bbj`). "Tier 1" and "tier 2" are maintainer
  terms: the hook, the tests, the conventions and the planning records use them; user docs may
  mention them only where they define them.
- **D-08:** The plugin is "the plugin `bbj-local`"; the server is "`bbj-ls`". "Language server" is
  allowed only in the one definition line ("`bbj-ls`, the BBj language server in BBjServices").
  Headings such as "Enable the local check" become "Enable the plugin `bbj-local`".
- **D-09:** Retired variants: "first route", "second route", "docs MCP", "compiler check",
  "local check". The term list, with the allowed term, the retired variants and a one-line meaning
  for each, is written in `.claude/CLAUDE.md` (Conventions) and `.planning/codebase/CONVENTIONS.md`.
- **D-10:** The gate scans shipped Markdown and the hook's notice text: `README.md`, `docs/`, both
  skills (`SKILL.md` and `references/*.md`) and the user-visible strings of
  `plugins/bbj/scripts/bbj-check.sh`. It rejects the retired variants case-insensitively, allows
  "language server" only in the definition line, and exempts CHANGELOG entries 0.2.1 and earlier. It
  has a mutation case (a planted variant makes it fail), like `layout_no_old_server_name`. Exact gate
  name and home (likely `tests/test_layout.py`) are the planner's call.
- **D-11:** Test and gate names follow the term list: rename only those that use a retired variant.
  Tier names in tests are fine. The term pass and these renames come before the prefix gate (ROADMAP order).
- **D-12:** Skill edits are prose only: no `bbj` code block changes, the check-order block stays
  byte-identical in both SKILL.md files (`checkorder_` gates), the skill-example gate stays green, and
  `bbj-programming` SKILL.md stays near 150 lines.

### Gate-prefix block (MAINT-09)
- **D-13:** Every gate name starts with a prefix listed for its own file. All free-form gate names
  (for example in `test_claude_plugin.sh`, `test_hook_review_fixes.sh`, `test_never_execute.sh`,
  `test_real_compiler.sh`, and the free-form names in `test_codex_patch.sh`, `test_discovery.sh`,
  `test_exit_contract.sh`, `test_tier2_fake.sh`, `test_tier2_live.sh`) are renamed once. The
  "plus free-form names" wording leaves the block. `.planning/` records that cite old gate names stay
  as history. — **Reversibility:** costly — every gate name cited by later docs or mutation scripts
  changes; mutation scripts that look for a named gate (`test_hook_mutation.sh`,
  `test_release_text_mutation.sh`, the layout mutation cases) must be updated in the same commit.
- **D-14:** The check runs in `tests/run.sh` after all files. `run.sh` already sees every gate line
  under its `== file` header. It compares the prefixes it saw per file with the block and prints one
  gate (for example `run_prefix_block`). It fails when a listed prefix is not printed by its file, when
  a gate name matches no listed prefix of its file, or when a file is missing from the block. A
  mutation case plants a missing prefix and an extra one. Note the existing caveat: a prefix can be a
  string prefix of another file's prefix (`ci_` vs `ci_guard_`, `release_` vs `release_mut_`), so the
  match is per file, longest prefix first.
- **D-15:** Source of truth is the block in `.claude/CLAUDE.md`, because `.planning/` is not tracked
  on `main` (verified: 0 files) and CI runs there. When `.planning/codebase/CONVENTIONS.md` is present,
  its block must be identical, and the gate checks that too; when it is absent, that part is skipped
  without failing, also under `CI=true`.
- **D-16:** The block includes the prefixes added in this milestone (`hookmut_` from Phase 13) and
  drops the ones removed (`installer_`, `homeguard_`), so it matches the suite after the renames.

### Claude's Discretion
- Sweep (MAINT-10): what counts as "retired" beyond the installer (Phase 11 already swept that), how to
  find dead functions, fakes, fixtures and gates, and the record: a `14-SWEEP.md` in the phase directory
  listing each item removed and why, or "nothing found".
- Map refresh (MAINT-11): run `/gsd-map-codebase` or edit by hand. The refreshed `.planning/codebase/`
  and the generated sections of `.claude/CLAUDE.md` name neither the installer nor `bbj-docs`, carry the
  term list and the prefix block, and keep the hand-written parts of `.claude/CLAUDE.md`.
- Exact wording of the page within D-01 and the term list, and the gate names, mechanics and plan split,
  as long as each commit leaves `sh tests/run.sh` green. Order inside the phase: page + term pass first,
  then the prefix gate, then sweep and map refresh last.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` §Phase 14 — goal, success criteria 1-5, notes on order and gates
- `.planning/REQUIREMENTS.md` — DOCS-05, DOCS-07, NAME-04, MAINT-09, MAINT-10, MAINT-11; Out of Scope table

### Prior decisions
- `.planning/phases/11-installer-removal/11-CONTEXT.md` — D-01 (never existed), D-03, D-10..D-12 (gate scope, CHANGELOG cut, piece-assembly convention)
- `.planning/phases/12-docs-server-renamed-to-bbj/12-CONTEXT.md` — D-04 (role noun with name), D-06 (tool prefixes only on install page), D-12 (no earlier versions)
- `.planning/phases/13-windows-hook-fixes/13-CONTEXT.md` — D-18 (`hookmut_` prefix for the block)
- `.planning/phases/12-docs-server-renamed-to-bbj/12-LINUX-RUN.md` — sign-in labels the page must use

### Run records backing the Verified table and page claims
- `.planning/milestones/v0.2.1-phases/08-codex-plugin-route/08-LINUX-RUN.md`
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md`
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-MACOS-RUN.md` — Tier 2 smoke section (hook run directly) backs D-05
- `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md`
- `.planning/phases/13-windows-hook-fixes/13-WINDOWS-RUN.md` — "## For the install page"
- `.planning/phases/11-installer-removal/11-CLAIM-TRACE.md` — per-platform claim trace

### Files changed
- `docs/install-claude-code.md`, `docs/install-codex.md` — merged and removed
- `README.md` — Install, Verified, check-hook sections
- `.claude/CLAUDE.md` — conventions (term list, prefix block) and generated sections
- `.planning/codebase/*.md` — refresh; `CONVENTIONS.md` prefix block
- `tests/run.sh`, `tests/test_install_pages.sh`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `tests/test_layout.py`, `tests/test_hook_mutation.sh`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tracked_files()` and the CHANGELOG integer-tuple cut in `tests/test_layout.py`: reuse for the term gate scope.
- `layout_mutation_*` cases (argv[1] root copy): the pattern for the term-gate mutation proof.
- `tests/run.sh` prints `== <file>` before each file's gate lines: the prefix check can group by it.
- `tests/test_hook_mutation.sh` / `tests/test_release_text_mutation.sh`: scratch-tree mutation pattern for the run.sh prefix check.

### Established Patterns
- Forbidden words that a test must name are assembled from pieces (`OIDC_PERMISSION`, `RETIRED_WORD`).
- Gate lines `gate NAME ok|FAIL|skip DETAIL`; under `CI=true` a missing prerequisite is FAIL, except D-15's absent CONVENTIONS.md copy.

### Integration Points
- Current suite: 797 gates, 21 test files; term counts in shipped Markdown today: "first route" 4 files, "second route" 3, "docs MCP" 3, "local check" 6, "compiler check" 2, "language server" 3.
- `.planning/` is filtered out of `main` (gsd-pr-branch), and `.claude/CLAUDE.md` is tracked there.

</code_context>

<specifics>
## Specific Ideas

- macOS Claude Code cell, exact form: `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 ``.
- `bbj-ls` definition line: "`bbj-ls`, the BBj language server in BBjServices".

</specifics>

<deferred>
## Deferred Ideas

None. The discussion stayed within the phase scope.

</deferred>

---

*Phase: 14-one-install-page-and-one-term-list*
*Context gathered: 2026-10-16*
