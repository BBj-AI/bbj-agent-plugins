# Phase 1: Repo-owned skills and local-first check route - Context

**Gathered:** 2026-10-09
**Status:** Ready for planning

<domain>
## Phase Boundary

The two skills (`bbj-programming`, `bbj-web-programming`) become maintained in this repository:
`skills.lock.json` and `tests/test_skills_hash.py` are removed, nothing references vendoring,
and the skills fall under the normal `tests/test_layout.py` rules. The Codex installer gains
`--with-local` (one managed `bbj-local` block) and a suggest-only `tools/list` probe, after a
refactor that parameterises the server-block logic by server name and tool list. One shared
check-order block appears byte-identical in `codex/AGENTS-snippet.md` and both SKILL.md files,
pinned by a test, and README plus both install pages present `bbj-local` as preferred over the
hosted check.

Requirements: VEND-01..03, LOCAL-01..07. Not in this phase: rewriting skill content (Phases 4-5),
the hook no-route notice (Phase 2), the example gate (Phase 3).

</domain>

<decisions>
## Implementation Decisions

### Check-order block: content
- **D-01:** Order is `bbjcpl`, then local `bbj-ls`, then the hosted check only when neither
  exists (already locked by LOCAL-05). When neither local route exists, the agent may use the
  hosted check **without asking**, but must tell the user the code was sent to the server and
  checked against a stock BBj.
- **D-02:** The block never names the hosted server's address; it says "the hosted check" /
  "the hosted docs server". `docs_host_single_source` in `tests/test_layout.py` stays strict
  (plugin.json is the only file naming `mcp.bbj-ai.com`) and now covers the skills too.
- **D-03:** The block carries one line on the hook: files the agent writes or edits are checked
  by the hook; the order applies to code the agent hands back without writing it (answers,
  earlier turns). Wording must be client-neutral (no `Write|Edit` vs `apply_patch`, no
  client-qualified tool names), since it is byte-identical across Claude Code and Codex.
- **D-04:** The `bbjcpl` step names the exact command `bbjcpl -t -N -X <file>`, noting that `-N`
  writes no output files and that errors arrive on stderr.

### Check-order block: placement and pinning
- **D-05:** Delimited by HTML comment markers `<!-- bbj-check-order:begin -->` and
  `<!-- bbj-check-order:end -->`. The pin test extracts the text between them, requires exactly
  one pair per file, and requires the three copies to be byte-identical. Markers travel into
  users' AGENTS.md; that is accepted.
- **D-06:** In both SKILL.md files the block goes directly after the frontmatter, as the first
  thing in the body (interim spot until Phases 4-5 rewrite the skills; fixes the "check workflow
  lost after compaction" problem now).
- **D-07:** In `codex/AGENTS-snippet.md` the block replaces the current `Check:` paragraph. The
  Codex-only fact "files written through shell commands are not checked" stays as one sentence
  outside the block.
- **D-08:** The existing `bbjcpl` section in `bbj-programming/SKILL.md` (~line 353, includes the
  wrong "parse stdout" claim) is **left untouched** in Phase 1; Phase 4 rewrites it. Phase 1 only
  adds the block to the skills.

### Codex installer: --with-local and probe
- **D-09:** A rerun **without** `--with-local` that finds a managed `bbj-local` block keeps it and
  refreshes it in place to the current shape; the probe is skipped. Leaving out the flag never
  removes something the user opted into.
- **D-10:** No removal flag. `docs/install-codex.md` documents removal as a manual step (delete the
  marked block, or `codex mcp remove bbj-local`; the lone-end-marker tolerance covers what that
  command leaves).
- **D-11:** Probe: one `tools/list` POST to `http://127.0.0.1:5009/mcp`, no user code, matching
  `"bbj_check_syntax"`; with `curl` flags as in the hook (`--noproxy '*'`, `--proto =http`, no
  redirects), short timeout (~2 s connect / ~3 s total). Without `curl`, or with no answer, print
  one line (e.g. "bbj-ls not probed: curl not found" / not answering) and continue. The probe
  never makes the installer fail or changes its exit code. `curl` stays optional.
- **D-12:** If `config.toml` names `bbj-local` in a form the installer did not write (e.g. a
  hand-run `codex mcp add bbj-local`), behave as for `bbj-docs` today: leave it, print the block
  to merge by hand, exit 3. No adopting of foreign tables.

### Docs framing
- **D-13:** "Preferred" means **preferred over the hosted check** ("local before hosted"), for the
  agent's own check-tool calls, with the two reasons (code stays on the machine; checked against
  the installation's own PREFIX, classpath and config). `bbjcpl` stays first for the hook; the
  docs must not read as if `bbj-ls` beats `bbjcpl` (it is parse-only).
- **D-14:** Enabling the local check becomes its own numbered step in both install pages, marked
  "recommended where BBjServices 26.03+ runs": Claude Code shows `claude plugin install` /
  `enable bbj-local@basis-bbj`; Codex shows `--with-local`. Still opt-in. README's Install block
  is not extended.
- **D-15:** README's "Vendored skills" section is replaced by a short "Skills" section: the skills
  live in `plugins/bbj/skills`, are maintained here, and changes go through this repo's tests.
  No mention of BBjSkills or history.
- **D-16:** `.claude/CLAUDE.md` and `.planning/codebase/*` are updated in this phase to drop the
  vendoring / `skills.lock.json` / "never edit the skills" statements (part of VEND-01's "no doc
  references them").

### Claude's Discretion
- Exact prose of the check-order block (within D-01..D-04) and of installer messages.
- Name of the pin test file and its gate prefix (follow existing conventions, e.g. a Python
  `test_*.py` with `gate <prefix>_<name>` lines).
- How the installer refactor is staged (LOCAL-01 first, tests green, then `bbj-local`).
- Wording of the "Skills" README section and the NOTICE text after the provenance paragraph is
  removed (copyright line stays).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Scope and decisions
- `.planning/ROADMAP.md` §Phase 1 — goal and the five success criteria
- `.planning/REQUIREMENTS.md` — VEND-01..03, LOCAL-01..07
- `.planning/PROJECT.md` — Key Decisions table, constraints (opt-in `bbj-local`, never execute, sh + Python stdlib)
- `.planning/seeds/SEED-001-skills-home-and-local-bbj-ls.md` — origin of the work, verified state on 2026-10-09

### Research
- `.planning/research/SUMMARY.md` — reconciliations (managed block, probe, shared block pinned byte-identical, Claude key `bbj-ls` vs Codex key `bbj-local`)
- `.planning/research/STACK.md` — Codex `config.toml` shape for the `bbj-local` block (url table + three tool tables, approval values; invalid values or orphan tool tables stop Codex loading the config)
- `.planning/research/ARCHITECTURE.md` — stop-vendoring touch list, installer parameterisation
- `.planning/research/PITFALLS.md` — grep-zero list for vendoring wording; installer pitfalls

### Codebase maps (to be updated per D-16)
- `.planning/codebase/CONVENTIONS.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/TESTING.md`, `.planning/codebase/CONCERNS.md`, `.planning/codebase/STACK.md`, `.planning/codebase/INTEGRATIONS.md`
- `.claude/CLAUDE.md` — project instructions; vendoring statements to remove

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `codex/install-codex.sh` `analyze` / `state` / `print_block` / `print_tools` (lines ~192-300): awk-based config.toml analysis hard-coded to `bbj-docs`; the parameterisation target for LOCAL-01.
- `codex/install-codex.sh` `say` / `refuse` / `pending` + exit codes 0/2/3: reuse for probe messages and the foreign-`bbj-local` case (D-12).
- `plugins/bbj/scripts/bbj-check.sh` tier-2 `curl` call: the flag set and loopback guard to copy for the probe (D-11).
- `tests/fake_mcp.py`: fake MCP server; gains a `tools/list` mode (LOCAL-07).
- `tests/fake-bin/curl`, `tests/lib.sh` (`gate`, `mkwork`): test seams for probe success/failure and no-curl.
- `tests/test_install_codex.sh`, `tests/test_codex_patch.sh`: existing installer tests that must stay green through the refactor.

### Established Patterns
- Managed blocks with begin/end markers and a one-time `config.toml.bbj-backup`; never edit tables the installer does not own; exit 3 for "merge by hand".
- Installer validates every option and destination before the first write (exit 2 with nothing changed).
- Install section 5 prints `AGENTS-snippet.md` verbatim between `----8<----` lines; the markers of D-05 will be printed too. A test reads the snippet's tool bullets (comment at install-codex.sh:58).
- Python tests: stdlib only, `python3 -I`, `gate` lines, optional `argv[1]` root; strings a scanner would match against itself are assembled from pieces.

### Integration Points
- `tests/test_layout.py` lines 130-147: `docs_host_single_source` skips `plugins/bbj/skills`; remove the exemption (VEND-03). Skills currently do not name the host, so the gate stays green.
- `tests/run.sh` / `tests/ci.sh`: discover tests by glob; check for explicit references to `test_skills_hash.py`.
- Vendoring wording today: `README.md` (lines 5, 37-40), `NOTICE`, `.claude-plugin/marketplace.json` (lines 3, 12), `plugins/bbj/.claude-plugin/plugin.json` (line 4), `docs/install-claude-code.md` (line 70).
- `docs/install-claude-code.md` §2 (bbj-local as a note under Install) and §"Check routes"; `docs/install-codex.md` §1-3 and §"Check routes": where D-13/D-14 land.

</code_context>

<specifics>
## Specific Ideas

- Marker names: `<!-- bbj-check-order:begin -->` / `<!-- bbj-check-order:end -->`.
- Install-page step title, roughly: "Enable the local check (recommended where BBjServices 26.03+ runs)".
- Probe messages are one line each; the suggestion names `--with-local` and writes nothing.

</specifics>

<deferred>
## Deferred Ideas

- `--without-local` installer flag to remove the managed `bbj-local` block: not needed in 0.2.0 (D-10 documents the manual step).
- Fixing the contradictory `bbjcpl` section of `bbj-programming` ("parse stdout"): Phase 4.

</deferred>

---

*Phase: 01-repo-owned-skills-and-local-first-check-route*
*Context gathered: 2026-10-09*
