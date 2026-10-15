# Phase 12: Docs server renamed to bbj - Context

**Gathered:** 2026-10-15
**Status:** Ready for planning

<domain>
## Phase Boundary

The hosted docs server is named `bbj` everywhere a user or agent meets it: `plugins/bbj/.mcp.json`,
`plugins/bbj/.codex-mcp.json`, both skills, the check-order block, the hook's no-route notice, README,
the install pages, `.claude/CLAUDE.md` and the tests. The sign-in commands in the docs are the ones
real Claude Code and real Codex show (owner run, Linux). A `layout_` gate keeps `bbj-docs` out.
Requirements NAME-01, NAME-02. Only the docs server is renamed: the plugins `bbj` and `bbj-local`,
the server `bbj-ls`, the marketplace `basis-bbj`, both skill names and the user-config keys
`docs_url` and `bbj_home` keep their names. URL and OAuth block (literal client id, port 47613,
`offline_access`) stay as they are.

</domain>

<decisions>
## Implementation Decisions

### The no-old-name gate (NAME-01)
- **D-01:** Scope: every git-tracked file except `.planning/` and the CHANGELOG entries for 0.2.1 and
  earlier. This is the Phase 11 D-11 scope and wider than ROADMAP SC2's "shipped files". Tests and
  `.claude/CLAUDE.md` are scanned too: `.claude/CLAUDE.md` is cleaned by hand in this phase, and a test
  that has to name the old name builds it from pieces (the `OIDC_PERMISSION` convention in
  `tests/test_ci_guards.py`).
- **D-02:** It is its own gate in `tests/test_layout.py` (a name like `layout_no_old_server_name`; the exact
  name is the planner's call) and not a fourth term of `layout_no_retired_route`, so a failure names the
  right requirement. It reuses the existing `tracked_files()` walk/git mode and the CHANGELOG cut by
  integer-tuple heading. It has its own mutation case: a planted mention in a scanned file must make it fail
  (argv[1] root copy, as the `layout_mutation_retired_route_*` cases do).
- **D-03:** Match: literal `bbj-docs`, case-insensitive, in paths and contents. That also catches
  `plugin:bbj:bbj-docs`, `mcp__plugin_bbj_bbj-docs__` and the Codex TOML key. Variants such as `bbj_docs`
  and `bbjdocs` are not matched.

### Naming in prose: plugin and server are both `bbj`
- **D-04:** A role noun always comes with the name: "the docs server `bbj`", "the plugin `bbj`". A bare
  `bbj` never stands for the server or the plugin in prose (skills, docs, hook notice, test docstrings).
  This also fits the Phase 14 term list ("docs server").
- **D-05:** Check-order step 3 in both SKILL.md files reads "`bbj_check_syntax` of the docs server `bbj`,
  the hosted check" (otherwise unchanged; the block stays byte-identical in the two files).
  `tests/test_check_order.py` looks for the docs-server string where it now looks for `bbj-docs`, and still
  pins the order bbjcpl, bbj-local, docs server.
- **D-06:** Tool names that the clients build from the server name (Claude Code
  `mcp__plugin_bbj_<server>__<tool>`; Codex `plugins."bbj@basis-bbj".mcp_servers.<server>`) appear only on
  the install pages, with the value the owner run shows (expected `mcp__plugin_bbj_bbj__`). Skills and the
  hook notice never quote a prefix.
- **D-07:** The hook's no-route notice (`plugins/bbj/scripts/bbj-check.sh`, the hosted-check sentence) says
  "the docs server bbj" in the same pattern. The `notice_` gates pass with the new text.

### Sign-in label and the owner run (NAME-02, SC4)
- **D-08:** The docs give the exact label each client shows, not a short form. Claude Code: `/mcp`, then the
  label `/mcp` and `claude mcp list` show (expected `plugin:bbj:bbj`). Codex: the login command it accepts
  (expected `codex mcp login bbj`). ROADMAP SC3 and NAME-02 were amended to say so.
- **D-09:** Order: (1) rename the server in both MCP configs and update the `layout_` pins; (2) the owner runs
  real Claude Code and real Codex on Linux from a checkout, in throwaway homes (never the real `~/.codex`,
  not under `/tmp`), and the result is recorded in `12-LINUX-RUN.md`: the labels shown, the login command
  accepted, the built tool prefix, sign-in completed in both; (3) docs, skills and notice are written from
  the recorded labels. No label is guessed into the docs before the run.
- **D-10:** Fresh install only. No upgrade-from-0.2.1 pass.
- **D-11:** If real Codex does not accept `codex mcp login bbj` for the plugin-provided server, the docs give
  the command Codex accepts and the SC3/NAME-02 wording is amended again. The config name stays `bbj`.
  The phase does not stop for this.

### No references to earlier versions
- **D-12:** Nothing refers to the old name or to earlier versions, as Phase 11 D-01 did for the installer:
  no upgrade note on the install pages or README, no redo list (sign-in, tool approvals, permission rules),
  no cleanup step for old-name credentials or rules, in this phase or in the Phase 15 CHANGELOG. The owner's
  words: "don't reference previous versions. we simply don't care". The redo-list clause of SC4, the
  Upgrading clause of Phase 15 SC2 and the CHANGELOG half of NAME-03 were dropped from ROADMAP.md and
  REQUIREMENTS.md (moved to Out of Scope). CHANGELOG entries for 0.2.1 and earlier stay byte-identical
  (Phase 11 D-03). — **Reversibility:** reversible

### Claude's Discretion
- Exact gate name and mutation mechanics (D-02).
- Exact rewording of install pages, README, `.claude/CLAUDE.md` lines and test docstrings, within D-04 and D-12.
- Plan split, as long as each commit leaves `sh tests/run.sh` green and the docs edits follow the owner run (D-09).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and requirements
- `.planning/ROADMAP.md` § Phase 12 — goal, success criteria (SC3/SC4 amended by this discussion), notes
- `.planning/REQUIREMENTS.md` — NAME-01, NAME-02 (amended), Out of Scope (upgrade text)
- `.planning/todos/pending/2026-10-13-oauth-client-handoff-from-bbjlangmcp.md` — origin of the rename (item 4: a Codex model rewrote the hyphenated name; the server's refusal text tells users to pick `bbj`); the OAuth values that must stay unchanged

### Prior decisions and run practice
- `.planning/phases/11-installer-removal/11-CONTEXT.md` — D-01 (as if it never existed), D-03 (frozen CHANGELOG history), D-10..D-12 (retired-term gate design this phase copies)
- `.planning/phases/10-install-wording-and-release-0-2-1/10-LINUX-RUN.md` — shape of the last real-client sign-in record (Claude Code `/mcp`, Codex `codex mcp login`); model for `12-LINUX-RUN.md`

</canonical_refs>

<code_context>
## Existing Code Insights

### Where `bbj-docs` is today (outside `.planning/` and CHANGELOG ≤0.2.1)
- Configs: `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` (server key)
- Hook: `plugins/bbj/scripts/bbj-check.sh` (no-route notice, hosted-check sentence)
- Skills: line 11 of both `plugins/bbj/skills/*/SKILL.md` (check-order block)
- Docs: `docs/install-codex.md` (11 mentions: login command, `Not logged in`/`OAuth` states, plugin-scoped
  tool approval key `plugins."bbj@basis-bbj".mcp_servers.bbj-docs`, check order), `docs/install-claude-code.md`
  (5: tool prefix, `plugin:bbj:bbj-docs` in `claude mcp list` and `/mcp`), `README.md` (2)
- `.claude/CLAUDE.md` (4 architecture lines)
- Tests: `tests/test_layout.py` (server-key pins at ~146/159/190, mutation cases ~502-536, docstring),
  `tests/test_check_order.py` (order positions, lines 89-94), `tests/test_claude_plugin.sh`
  (`cc mcp get plugin:bbj:bbj-docs`, gate detail), `tests/test_install_pages.sh` (`codex mcp login bbj-docs`,
  the TOML key, header comment)

### Reusable Assets
- `tracked_files(ROOT)` and `names_retired()` plus the CHANGELOG cut in `tests/test_layout.py` (~68, ~320-396): the scan for D-02
- The `layout_mutation_retired_route_*` cases (~418): the pattern for the D-02 mutation case

### Established Patterns
- Self-scan safety: a forbidden term is assembled from pieces in test code
- Gate lines `gate layout_<name> ok|FAIL <detail>`; `tests/run.sh` counts them

### Integration Points
- `claude plugin validate --strict` (CI) must pass on the renamed `.mcp.json`
- `test_claude_plugin.sh` reads the server through `claude mcp get plugin:bbj:<server>`; its expected label changes with the run's finding

</code_context>

<specifics>
## Specific Ideas

- Prose pattern: "the docs server `bbj`" / "the plugin `bbj`"; never a bare `bbj` for either.
- Check-order step 3: "`bbj_check_syntax` of the docs server `bbj`, the hosted check".

</specifics>

<deferred>
## Deferred Ideas

- Phase 15 Notes still mention an Upgrading line for `/hooks` trust if Phase 13 changes `commandWindows`.
  That line is not about the rename and was left as it is; Phase 15 should check it against D-12's "no
  references to earlier versions".

</deferred>

---

*Phase: 12-docs-server-renamed-to-bbj*
*Context gathered: 2026-10-15*
