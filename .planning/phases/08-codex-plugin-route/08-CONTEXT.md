# Phase 8: Codex plugin route - Context

**Gathered:** 2026-10-13
**Status:** Ready for planning

<domain>
## Phase Boundary

A Codex user installs `bbj` with `codex plugin marketplace add` and `codex plugin add
bbj@basis-bbj`, and opts into `bbj-local` with `codex plugin add bbj-local@basis-bbj`. They get
`bbj-docs` at the literal docs URL through a `.codex-plugin/plugin.json` overlay, both skills,
and the unchanged `hooks/hooks.json` compile check once they trust it in `/hooks`. The hook's
no-route notice names the command that fits the route. Gates keep the docs URL and the version
consistent across every manifest. `docs/install-codex.md` leads with the plugin route and keeps
`install-codex.sh` as a documented fallback. A user with an installer setup switches to the plugin
route with an installer option. All of it is proven on Linux in throwaway Codex homes and gated
in CI on fakes (CODEX-01 to CODEX-06).

Not in this phase: the version bump, the CHANGELOG entry and the platform wording (Phase 10);
the Windows and macOS runs (Phase 9); removing `install-codex.sh`; Copilot CLI. Claude Code's
manifest, `.mcp.json`, `userConfig` and `claude plugin validate --strict` stay unchanged. BBj
code is never executed; nothing touches the real `~/.codex` or `~/.agents`.

</domain>

<decisions>
## Implementation Decisions

### Locked before this discussion (spikes 001-005, roadmap, Phase 7)
- Overlay variant A of spike 002: `.codex-plugin/plugin.json` beside `.claude-plugin/`, pointing
  at a literal-URL MCP file. A root `mcp.json` does not override `.mcp.json`.
- The plugin route ships no tool approvals; every tool prompts on first use. The installer's
  `tools/list` probe has no plugin counterpart; docs and the notice replace it.
- `install-codex.sh` stays one release as the fallback route. Removing it is a later decision.
- Real Codex checks run in throwaway homes under `~/.cache` or similar, never the real
  `~/.codex` and not under `/tmp` (Codex refuses its helper binaries there). Billed real-model
  runs only with the owner's approval for each run.
- Phase 7 D-08: the `home_snapshot` allowlist in `tests/lib.sh` gets the plugin-route paths
  added in this phase.
  - *Resolved 2026-10-13 at planning (Claude's discretion, listed below; plan 08-01 Task 1
    rewrites the `tests/lib.sh` comment to match):* no plugin-route path joins the allowlist.
    The plugin cache (`$CODEX_HOME/plugins/`) and the `[marketplaces]` and `[plugins]` tables are
    written by Codex itself, not by `install-codex.sh`, and change whenever the owner uses Codex.
    Watching them in the installer-home gate `real_home_untouched` would turn ordinary Codex use
    into false failures, as the daemon files did before Phase 7 D-08 (the MAINT-07 flake). They
    are checked only in the throwaway homes of plans 08-05 and 08-06. The allowlist stays the
    installer's write set, which this phase does not change, and `--remove` deletes only inside
    it. `config.toml` stays watched as one file, so the existing residual-risk note in
    `home_snapshot` (Codex rewriting `config.toml`) already covers the two tables.

### Switching from the installer (CODEX-06)
- **D-01:** The switch is an installer option (name is the planner's; `--remove` is the working
  name) that undoes exactly what `install-codex.sh` wrote and nothing else. After it, the user
  runs the two `codex plugin` commands by hand; the installer does not call `codex plugin`.
  — **Reversibility:** reversible — a rerun of the installer without the option puts everything
  back.
- **D-02:** The `[mcp_servers.bbj-docs]` table and its five `tools.*` tables are removed when
  they are in the forms the installer writes (step 1 of the installer header). The result is one
  `bbj-docs` server, the plugin's. The docs name the plugin-scoped key
  `plugins."bbj@basis-bbj".mcp_servers.bbj-docs` (from the Codex build page, not observed in
  the spikes) for a user who wants the docs-tool pre-approvals back, as a documented option, not
  something the installer writes.
- **D-03:** The managed `bbj-local` block between its markers is removed. A hand-written
  `bbj-local` form is left and reported (exit 3), as today. Skill directories under the skills
  directory are removed only when byte-identical to the shipped copies; a differing directory
  is left and reported (exit 3). `<codex home>/bbj/` (the copied check script) is removed.
- **D-04:** `hooks.json` is deleted only when byte-identical to the block the installer writes;
  otherwise it is left, the entry to remove is printed, exit 3. `config.toml.bbj-backup` is left
  (it is the user's backup). Codex's own `hooks.state.*` trust entries in `config.toml` are left;
  the docs say a stale trust entry is harmless.
- **D-05:** Proof: a test in `tests/test_install_codex.sh` (prefix `installer_`/`existing_` as
  fits) installs with the fake `codex` into a throwaway home, runs the removal, and asserts with
  `home_snapshot`/`home_diff` that the home is back to its pre-install state; plus the foreign
  forms (exit 3, nothing touched). One real Linux run in a throwaway Codex home: installer
  install, removal, then the two plugin commands; recorded in the phase.
- **D-06:** A double install (installer and plugin at once) is handled by the docs only: the
  switch section says what it looks like (two checks, two feedbacks) and points at the removal
  option. The hook does not look for a sibling hook.

### No-route notice on Codex (CODEX-03)
- **D-07:** Route detection in `bbj-check.sh`: `tool_name` `apply_patch` with `CLAUDE_PLUGIN_ROOT`
  non-empty is the plugin route (Codex sets it to the cache path
  `.../plugins/cache/basis-bbj/bbj/<version>`); `apply_patch` with it unset is the installer route
  (its `hooks.json` runs `sh "<codex home>/bbj/bbj-check.sh"` and sets no variable). No new
  marker; the installer's `hooks.json` block stays byte-identical.
- **D-08:** One command per route. Plugin route: the enable step names
  `codex plugin add bbj-local@basis-bbj`. Installer route: the current text
  (`rerun install-codex.sh --with-local`) stays. The `BBJ_HOME` / `bbjcpl` on `PATH` advice stays
  on both. The Claude Code wording (`enable the bbj-local@basis-bbj plugin`) is unchanged.
- **D-09:** `tests/test_noroute_notice.sh` gains gates (prefix `notice_`) for `apply_patch` with
  and without `CLAUDE_PLUGIN_ROOT`, next to the existing Claude Code gate, each asserting the
  exact command string inside `additionalContext`. Three variants, three gates.

### Codex manifest files and gates (CODEX-01, CODEX-04)
- **D-10:** `plugins/bbj/.codex-plugin/plugin.json` mirrors `plugins/bbj/.claude-plugin/plugin.json`:
  `name`, `version`, `description`, `author`, `homepage`, `license`, `keywords` identical,
  `userConfig` omitted, plus `"mcpServers": "./.codex-mcp.json"`. A gate keeps the shared fields
  identical.
- **D-11:** The literal-URL file is `plugins/bbj/.codex-mcp.json` (the layout spike 002
  validated: Codex copies it into its cache, Claude ignores it). `bbj-local` gets no overlay; its
  `.mcp.json` has no `userConfig` and spike 003 showed it works as is.
- **D-12:** The marketplace stays the single `.claude-plugin/marketplace.json`, which Codex reads
  as the legacy-compatible path. No `.agents/plugins/marketplace.json`.
- **D-13:** The gates extend `tests/test_layout.py` (prefix `layout_`): the overlay joins the
  version set (both plugins, both marketplace entries, the overlay: one version);
  `.codex-mcp.json` joins the files allowed to name the hosted host (today only
  `plugins/bbj/.claude-plugin/plugin.json`); a new gate requires the URL in `.codex-mcp.json` to
  equal the `docs_url` default. No new test file.
- **D-14:** The CODEX-02 CI gate runs the hook through the exact command string of
  `plugins/bbj/hooks/hooks.json` (parsed from the file, so a change to it is caught) with
  `CLAUDE_PLUGIN_ROOT` set to a fake cache path `.../plugins/cache/basis-bbj/bbj/<version>/` holding
  a copy of the plugin, and the captured `apply_patch` payload: a bad file gives exit 2 with
  `bbjcpl` feedback, a clean file exit 0 with empty stdout. Fakes only, no Codex.

### Docs layout and the Linux proof (CODEX-05)
- **D-15:** `docs/install-codex.md` stays one page. The plugin route comes first: the two install
  commands, the `/hooks` trust step, first-use tool prompts, the `BBJ_HOME` note, the
  `bbj-local` opt-in command, the upgrade-trust observation, and the switch section (D-01 to
  D-06). The installer keeps a shortened "Fallback: the installer script" section with its
  options table and exit codes.
- **D-16:** The pinned 0.2.0 lines stay verbatim: the "Tested on Linux only" banner, the
  "not yet been run on Windows or macOS" lines, the installer's `STATUS_LINE`, and the quoted
  strings in `tests/test_release_text.py` and `tests/test_install_pages.sh`. Phase 7 D-06 holds.
  The plugin-route section carries its own line saying it was verified on Linux with the Codex
  version and date of this phase's run. Phase 10 rewrites and re-pins all platform wording once.
- **D-17:** The Linux runs reuse spike 001's fake Responses server and `run.sh` pattern
  (`.planning/spikes/001-codex-plugin-hooks/`) in a throwaway home: marketplace add from the
  local checkout, `codex plugin add bbj@basis-bbj`, `--dangerously-bypass-hook-trust` for the
  scripted runs, a bad and a clean `.bbj` through `apply_patch`, and a no-route run for the
  notice text. One manual pass trusts the hook for real in the `/hooks` TUI, recorded by the
  owner. No billed runs. The spike scripts are not CI.
- **D-18:** Upgrade-trust observation: install 0.2.0 from the checkout and trust the hook in
  `/hooks`; point the marketplace at a scratch copy of the checkout with the version set to a
  test value (for example `0.2.0-test`) in every manifest; upgrade; record whether `/hooks`
  lists the hook as untrusted again. The result goes into the docs as observed on Linux. No
  version in the repository changes.

### Claude's Discretion
- The name of the removal option and its output lines; keep the installer's exit-code contract
  (0 done, 2 refusal before any write, 3 something left by hand) and document the option in
  the script header and the docs options table.
- The exact `home_snapshot` paths for the plugin route (D-08 of Phase 7): the Codex plugin cache
  and `[marketplaces]`/`[plugins]` tables are Codex-written, not installer-written, so the
  planner decides whether they belong in the installer-home allowlist or only in the
  throwaway-home checks.
- How the no-route notice text is assembled in `bbj-check.sh` (D-07, D-08) within the one
  stdout JSON object; the hook's exit contract and its never-execute rule are unchanged.
- Gate names, within the per-file prefix convention; which `test_install_codex.sh` prefix the
  removal cases take.
- How the real Linux runs are recorded (a `08-LINUX-RUN.md` or the SUMMARY) with Codex version,
  date, route and outcome, as PLAT-06 asks for the Phase 9 runs.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` §Phase 8 — goal, success criteria 1-6, spike facts in the notes
- `.planning/REQUIREMENTS.md` — CODEX-01 to CODEX-06; PLAT-03/PLAT-06 (Phase 9 follows this
  phase's docs); Out of Scope table
- `.planning/PROJECT.md` — Key Decisions table; Constraints (never execute, opt-in `bbj-local`,
  names unchanged)
- `.planning/STATE.md` — Blockers/Concerns: the CODEX-06 gap, the upgrade-trust unknown, the
  three Windows unknowns for Phase 9

### Spikes (the evidence for every Codex fact above)
- `.planning/spikes/001-codex-plugin-hooks/README.md` — hook fires after `apply_patch` on the
  plugin route; trust required; hashed key covers the versioned cache path; `fake_responses.py`
  and `run.sh` to reuse (D-17)
- `.planning/spikes/002-codex-plugin-manifest/README.md` — overlay variant A; the user override
  `[mcp_servers.bbj-docs] url = ...` replaces the plugin's server (why D-02 removes the table)
- `.planning/spikes/003-codex-bbj-local-optin/README.md` — `bbj-local` opt-in; `tool_search`
  deferral; `plugins.<plugin>.mcp_servers.<server>` approval keys from the build page
- `.planning/spikes/005-codex-installer-residue/README.md` — duty-by-duty map of the installer to
  the plugin route; the recommended command sequence; the Windows unknowns
- `.planning/spikes/CONVENTIONS.md` — throwaway-home and never-execute rules for spike runs

### Prior decisions
- `.planning/phases/07-test-hardening-and-release-prep/07-CONTEXT.md` — D-04 to D-07
  (CONTENT_VERSION policy; D-16 keeps it), D-08 to D-10 (`home_snapshot` allowlist, extended
  here), D-11 to D-13 (PATH scrub, the no-route gates this phase extends)

### Code under change
- `plugins/bbj/.claude-plugin/plugin.json`, `plugins/bbj/.mcp.json` — unchanged; the overlay
  mirrors the manifest (D-10)
- `plugins/bbj/hooks/hooks.json` — unchanged; its command string drives the D-14 gate
- `plugins/bbj/scripts/bbj-check.sh` (≈line 215, the `_how` case on `$1`) — notice wording per
  route (D-07, D-08)
- `codex/install-codex.sh` — header steps 1 to 5 list every path the removal option undoes
  (D-01 to D-04); `STATUS_LINE` (line 102) stays
- `docs/install-codex.md` — rewritten per D-15, D-16; `README.md` Codex lines (14-15, 31) follow
- `codex/AGENTS-snippet.md` — still a manual step on both routes; printed by the installer,
  linked from the docs
- `tests/test_layout.py` — version set, hosted-host rule, new URL-equality gate (D-13)
- `tests/test_noroute_notice.sh` — the three notice gates (D-09)
- `tests/test_codex_patch.sh`, `tests/lib.sh` (`codex_payload`, `run_check`, `home_snapshot`,
  `home_diff`) — building blocks for D-14 and D-05
- `tests/test_install_codex.sh` — removal cases (D-05); `tests/test_install_pages.sh` and
  `tests/test_release_text.py` — pinned quotes that must survive the docs rewrite (D-16)
- `tests/test_check_order.py` — the shared check-order block stays byte-identical in the skills
  and the snippet

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/lib.sh`: `gate`, `mkwork`, `run_check`, `codex_payload`, `claude_payload`,
  `notice_text`, `home_snapshot`, `home_diff`, `no_compiler_path`. The removal proof (D-05) and
  the plugin-route gate (D-14) are built from these.
- `tests/fake-bin/`: fake `codex`, `bbjcpl`, `curl`, `cygpath`; `tests/fake_mcp.py` for a fake
  `bbj-ls`.
- `tests/test_codex_patch.sh`: the captured codex-cli 0.162.1 `apply_patch` payload shape and the
  patch-parsing cases; the D-14 gate feeds the same payload with the cache-path environment.
- `.planning/spikes/001-codex-plugin-hooks/run.sh` and `fake_responses.py`: the scripted real-Codex
  run in a throwaway home (D-17). Needs model slug `gpt-5.5` for the freeform `apply_patch` tool
  and `< /dev/null` on `codex exec`.
- `codex/install-codex.sh`: `analyze`, `print_block`, `state` already classify every
  `config.toml` form the installer owns versus refuses; the removal option reuses that
  classification (D-02, D-03).

### Established Patterns
- POSIX `sh` and Python 3 stdlib only; `python3 -I`; no `local`; underscore-prefixed temps;
  every global a test changes is restored.
- The installer validates everything before the first write, writes a one-time backup, never
  edits a file it does not own in a form it does not know, exit 3 for anything left by hand.
- The hook writes stdout in exactly one case (the no-route notice JSON) and exits 0 or 2 only;
  `tests/test_exit_contract.sh` enforces it.
- Gates print `gate <prefix>_<name> ok|FAIL|skip`; new gates keep their file's prefix.
- The hosted host may be named in shipped files only where `tests/test_layout.py` allows it.
- Strings a static scan would match against itself are assembled from pieces.

### Integration Points
- Codex discovers `.codex-plugin/plugin.json`, `skills/` and `hooks/hooks.json` by default from
  the plugin directory the marketplace entry names (`./plugins/bbj`); Codex sets
  `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA` for the hook.
- `tests/run.sh` discovers `test_*` files by glob; `tests/ci.sh` runs shellcheck over every shell
  test and `claude plugin validate --strict` over the marketplace and both plugins (the overlay
  and `.codex-mcp.json` must not break it; spike 002 showed they do not).

</code_context>

<specifics>
## Specific Ideas

- Recommended Codex route, from spike 005 (the docs lead with exactly this):
  `codex plugin marketplace add BBj-AI/bbj-agent-plugins`, `codex plugin add bbj@basis-bbj`,
  then `/hooks` to trust the check, and optionally `codex plugin add bbj-local@basis-bbj`.
  Before the release the marketplace add uses the local checkout path.
- The app server's `hooks/list` names the plugin hook
  `bbj@basis-bbj:hooks/hooks.json:post_tool_use:0:0` with the command already expanded to the
  cache path; that is the shape the D-14 fake cache path imitates.
- The owner's real Codex home holds daemon files (`logs_*.sqlite*`, `history.jsonl`,
  `sessions/`); the Phase 7 allowlist already ignores them, and the plugin route must not make
  the installer-home gate watch Codex-written tables.

</specifics>

<deferred>
## Deferred Ideas

- Writing docs-tool pre-approvals for the plugin route (`plugins."bbj@basis-bbj".mcp_servers.
  bbj-docs`) from the installer or a helper: documented as a manual option only (D-02). Revisit
  if users ask.
- A Codex-native `.agents/plugins/marketplace.json`: only if Codex drops the legacy path (D-12).
- Editing a merged `hooks.json` in place during removal: out; the installer never edits JSON it
  did not write (D-04).

</deferred>

---

*Phase: 08-codex-plugin-route*
*Context gathered: 2026-10-13*
