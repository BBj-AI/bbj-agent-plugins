# Phase 11: Installer removal - Context

**Gathered:** 2026-10-15
**Status:** Ready for planning

<domain>
## Phase Boundary

The plugin is the only install route for Codex, and the repository reads as if the Codex installer
never existed. Removed: `codex/install-codex.sh`, `codex/AGENTS-snippet.md` (and the `codex/`
directory), `tests/test_install_codex.sh`, the installer gates and wording in every test, the hook's
installer-route branch, and the installer route in the README and both install pages. A new gate
keeps the installer out. Released CHANGELOG history (0.2.1 and earlier) and `.planning/` records stay.

Requirements: INST-01, INST-02, INST-03, DOCS-06. INST-04 is dropped (D-02).

</domain>

<decisions>
## Implementation Decisions

### Docs read as if the installer never existed
- **D-01:** No installer trace in the docs, README, skills, hook or tests: no migration text, no
  "switch from the installer" section, no double-install troubleshooting note, no pointer to the
  CHANGELOG for installer users. The owner's reason: no outside user ever used the installer, so any
  instruction would be moot. `docs/install-codex.md` "Switch from the installer script", "Fallback:
  the installer script" and every installer sentence go; the page describes only the plugin route.
- **D-02:** INST-04 is dropped. Phase 15 writes no migration line, the `## 0.2.2` CHANGELOG entry does
  not mention the installer, and Phase 15 SC2 is removed. REQUIREMENTS.md and ROADMAP.md are updated
  with this context (INST-04 moved to Out of Scope with this reason). — **Reversibility:** reversible
- **D-03:** CHANGELOG entries `## 0.2.1` and earlier stay byte-identical to what was published,
  installer content included. They are history; the gate exempts them.
- **D-04:** For Codex users without plugin support, the docs name the verified Codex CLI version
  (0.162.1, from the run records) as what the plugin route was verified with; nothing beyond what a
  run record backs.
- **D-05:** Custom docs-server URL on Codex: the docs state the limit. On Codex the plugin uses the
  hosted docs server (`plugins/bbj/.codex-mcp.json` holds the literal URL); only Claude Code has the
  `docs_url` option. No manual-override recipe.
- **D-06:** README "Verified" table loses the "Codex installer" row; the "Not run" sentence below it
  loses every installer clause. What is left must still trace to `08-LINUX-RUN.md`,
  `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md` or `10-LINUX-RUN.md` (DOCS-06); nothing that only
  `10-WINDOWS-INSTALLER-RUN.md` backed may remain. README lines that offered the installer as an
  alternative (`--with-local`, `--docs-url`, "fallback") go.

### Release-text gates (tests/test_release_text.py and its mutation script)
- **D-07:** Remove `upgrade_quotes`, the `UPGRADE_QUOTES` constant and its mutation case. The quoted
  file no longer exists and the 0.2.1 entry is frozen history. `not_run`, `changelog_sections` and the
  other pinned gates keep pinning 0.2.1 until Phase 15 re-pins them.
- **D-08:** Remove `status_line_in_page` and its mutation case (DOCS-03 subject is gone).
- **D-09:** Drop the installer from `HINT_FILES`, from the `codex_version_single` sources and from
  the `claude_version_single` sources; drop the `no_unrun_hint_installer` mutation case. The
  mutation script stops creating `codex/` and copying the installer into its scratch tree.

### The no-installer gate (INST-02)
- **D-10:** It rejects three terms: `install-codex.sh`, `AGENTS-snippet`, and the word `installer`
  (case-insensitive). This applies to comments too: the hook header's D-07/D-08 route notes,
  `tests/lib.sh` comments and test docstrings must be reworded. A test that has to name a term
  assembles it from pieces (existing self-scan convention, e.g. `OIDC_PERMISSION` in
  `tests/test_ci_guards.py`). This includes the pinned 0.2.1 `NOT_RUN_LINES` in
  `tests/test_release_text.py`, which quote "Codex installer" history.
- **D-11:** Scope: every git-tracked file except `.planning/` and the CHANGELOG entries for 0.2.1 and
  earlier (by version heading; anything under `## 0.2.1` or an older `## ` heading is exempt, while a
  newer entry is scanned). `.claude/CLAUDE.md` has no exemption: its installer lines are cleaned by
  hand in this phase. Phase 14's map refresh regenerates it later and must keep it clean.
- **D-12:** It lives in `tests/test_layout.py` as a `layout_` gate, next to the existing file scan
  ("hosted host named only in plugin.json"). No new gate prefix. A planted mention in a scanned file
  must make it fail. Prove this with a mutation case (argv[1] root copy, as the existing mutation tests do).

### Leftover test scaffolding: all installer-only code goes now
- **D-13:** Remove `home_snapshot` (tests/lib.sh), `tests/test_home_guard.sh` (`homeguard_` prefix)
  and the `real_home_untouched` check. No remaining test writes a Codex home. Deferred v0.2.0 item D-2
  (real_home_untouched vs a Codex daemon writing ~/.codex) becomes moot.
- **D-14:** Remove `layout_oauth_codex_matches_plugin`. It is redundant: `tests/test_layout.py` lines
  ~114-137 already pin the same OAuth client (id, port, scopes, callback URL) in both
  `plugins/bbj/.mcp.json` and `plugins/bbj/.codex-mcp.json`.
- **D-15:** Remove `tests/fake-bin/codex`, the fake-codex exit seam in `tests/run.sh` (IN-06 comment),
  the `static_codex_files` / `CODEX_GLOB` block in `tests/test_static_guards.sh`, the `installer_`
  gates in `tests/test_install_pages.sh`, and the AGENTS-snippet copy in
  `tests/test_check_order.py` (the block stays pinned byte-identical in the two SKILL.md files).
  Phase 11 sweeps every installer-only helper, so the Phase 14 sweep (MAINT-10) finds nothing
  installer-related.

### Hook (INST-03)
- **D-16:** On Codex `apply_patch` the no-route notice has one text, the current plugin-route text
  (`codex plugin add bbj-local@basis-bbj ...`), whether `CLAUDE_PLUGIN_ROOT` is set, empty or unset.
  The `CLAUDE_PLUGIN_ROOT` branch in `notice()` goes. `tests/test_noroute_notice.sh` loses
  `notice_codex_installer_route` and `notice_codex_empty_root`'s installer expectation, and gains or
  keeps gates showing that unset or empty root gives the plugin text. The `plugin_route_` gates keep
  giving `bbjcpl` feedback for a bad file and silence for a clean one. The `codex_payload` helper stays.

### Claude's Discretion
- Exact wording of the rewritten hook header comments, test docstrings and install-page text,
  within the term list and the "never existed" rule (D-01, D-10).
- Mutation mechanics for the new gate (D-12) and whether to reuse `tests/test_release_text_mutation.sh`
  or a case inside an existing mutation script.
- Plan split and order, as long as each commit leaves `sh tests/run.sh` green. The deletion and the
  release-text gate edits must land together, because `upgrade_quotes` and the mutation script read
  the installer.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` §Phase 11 — goal, success criteria, notes (SC2 migration-line exception is
  void per D-02)
- `.planning/REQUIREMENTS.md` — INST-01..INST-03, DOCS-06 (INST-04 out of scope per D-02)
- `.planning/PROJECT.md` — Key Decisions table, core value

### Run records that back per-platform claims (DOCS-06)
- `.planning/milestones/v0.2.1-phases/08-codex-plugin-route/08-LINUX-RUN.md`
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md`
- `.planning/milestones/v0.2.1-phases/09-windows-and-macos-verification/09-MACOS-RUN.md`
- `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md`
- `10-WINDOWS-INSTALLER-RUN.md` (same Phase 10 directory): claims backed only by this record must go

### Prior decisions touched
- `.planning/milestones/v0.2.1-phases/08-codex-plugin-route/08-CONTEXT.md` — D-07, D-08 (route
  detection via CLAUDE_PLUGIN_ROOT; the installer half is retired by D-16)
- `.planning/milestones/v0.2.1-phases/10-install-wording-and-release-0-2-1/10-CONTEXT.md` — release-text
  gates and DOCS-03/DOCS-04 origins (STATUS_LINE, hint files)

### Conventions
- `.claude/CLAUDE.md` — gate grammar, prefix list, self-scan "assemble from pieces" rule, POSIX sh rules

</canonical_refs>

<code_context>
## Existing Code Insights

### Files to delete
- `codex/install-codex.sh`, `codex/AGENTS-snippet.md` (directory `codex/` then empty)
- `tests/test_install_codex.sh`, `tests/test_home_guard.sh`, `tests/fake-bin/codex`

### Files to edit (installer mentions found by scan)
- `plugins/bbj/scripts/bbj-check.sh` — `notice()` apply_patch branch (~line 220-231), header lines ~49,
  ~130
- `tests/lib.sh` — `home_snapshot` (~226-260) and header/route comments (~32-44)
- `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` — D-07..D-09
- `tests/test_layout.py` — docstring, `oauth_codex_matches_plugin` (~149-167), new gate (D-12)
- `tests/test_noroute_notice.sh` — installer-route gates (~21-31, 179-256)
- `tests/test_install_pages.sh` — `installer_` gates and their text checks
- `tests/test_check_order.py` — snippet copy and docstring
- `tests/test_static_guards.sh` — `CODEX_GLOB` block (~135-169)
- `tests/ci.sh` (header comment), `tests/run.sh` (fake-codex seam)
- `README.md`, `docs/install-codex.md` (~38 mentions), `docs/install-claude-code.md` (1 mention + link
  text), `.claude/CLAUDE.md` (~12 mentions, including the gate-prefix block: drop `homeguard_`,
  `installer_` and the installer-only prefixes of `test_install_codex.sh`)

### Established Patterns
- File scan with exemptions already exists in `tests/test_layout.py` (hosted host named only in
  `plugins/bbj/.claude-plugin/plugin.json`); the new gate follows it.
- Python tests take an optional argv[1] root so mutation runs point them at a copy.
- Self-scan convention: forbidden strings assembled from pieces in test sources.

### Integration Points
- `tests/run.sh` discovers `test_*` files by glob, so deleted test files drop out automatically.
- `skills` for Codex now arrive only through the plugin. Any doc text about `~/.agents/skills` as an
  install target was installer-only and goes.

</code_context>

<specifics>
## Specific Ideas

- Owner's words: "no traces of the installer whatsoever. It has never been in use by outside people.
  Wipe it all and don't publish any instructions, they'd be moot. We should have as an outcome docs
  that read as if we never had the installer."

</specifics>

<deferred>
## Deferred Ideas

- Phase 14 map refresh must regenerate `.claude/CLAUDE.md` and `.planning/codebase/` without
  reintroducing installer text (the D-12 gate will catch `.claude/CLAUDE.md`; `.planning/` is exempt,
  so MAINT-11 must check `.planning/codebase/` itself).

### Reviewed Todos (not folded)
- `2026-10-13-oauth-client-handoff-from-bbjlangmcp.md`: the rename `bbj-docs` → `bbj` belongs to Phase 12
  (NAME-01, NAME-02); the client id as a setting stays out of scope for v0.2.2.

</deferred>

---

*Phase: 11-installer-removal*
*Context gathered: 2026-10-15*
