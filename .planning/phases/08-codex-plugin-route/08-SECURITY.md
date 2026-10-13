---
phase: "08"
slug: "codex-plugin-route"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-13"
---

# Phase 08 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| repository files → Codex plugin cache | Codex copies `plugins/bbj` (with both new files) into `$CODEX_HOME/plugins/cache/basis-bbj/bbj/<version>/` and connects to the URL it reads there | see description |
| Codex → hook process | Codex expands `${CLAUDE_PLUGIN_ROOT}` into the hook command; the path holds a version and may hold spaces | see description |
| host environment → hook process | Codex (plugin route) and Claude Code set CLAUDE_PLUGIN_ROOT; its value is a path outside the hook's control | see description |
| hook stdout → model context | the notice text reaches the agent as additionalContext | see description |
| user options → filesystem deletes | `--codex-home`, `--skills-dir` and `--docs-url` decide which paths and tables are removed | see description |
| user-owned files → installer | config.toml, hooks.json and the skill directories may hold the user's own edits next to what the installer wrote | see description |
| user options → refusal logic | option combinations that would contradict D-01 or D-03 | see description |
| user-edited files → remove_all | the user's own content inside or next to what the installer wrote | see description |
| run scripts → the owner's real home | the scripts run real Codex on the owner's machine, where ~/.codex and ~/.agents hold real configuration and credentials | see description |
| hook process → files | the env probe writes what the hook process sees | see description |
| throwaway Codex → network | marketplace shorthand (GitHub), OAuth discovery and login (hosted docs server); the model provider stays loopback | see description |
| owner's trust decision → hook execution | after /hooks trust the hook runs on every apply_patch; an upgrade may or may not keep that trust | see description |
| docs → user actions | users copy commands and config from the page into their Codex setup | see description |
| run record → docs | statements on the page must come from recorded runs | see description |
| owner's decision → planning record | an answer to Task 1 can weaken a requirement, the phase goal or a locked decision | see description |
| record → shipped files | the recorded decisions select two conditional code changes | see description |
| hook script location → route decision | with the amended rule, the presence of a file next to the script picks the notice wording | see description |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-08-01 | Spoofing | plugins/bbj/.codex-mcp.json url | medium | mitigate | layout_codex_url_equals_default ties the Codex url to the Claude `docs_url` default as an exact string; layout_mutation_codex_url and layout_mutation_default_url prove both drift directions fail | closed |
| T-08-02 | Information Disclosure | plugins/bbj/.codex-mcp.json | high | mitigate | layout_codex_mcp pins the exact dict, so a client secret, header or token is an extra key and fails; layout_mutation_codex_secret proves it | closed |
| T-08-03 | Elevation of Privilege | hooks.json command under a Codex cache path | medium | mitigate | the command string stays `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"` (layout_hook_command); plugin_route_bad runs it through a cache path that contains a space | closed |
| T-08-04 | Tampering | plugins/bbj/.codex-plugin/plugin.json | low | mitigate | layout_codex_overlay_fields pins the exact key set, so a `skills` or `hooks` key that would replace Codex's default discovery fails (layout_mutation_overlay_extra_key) | closed |
| T-08-05 | Information Disclosure | notice() and CLAUDE_PLUGIN_ROOT | medium | mitigate | the value is only tested with `[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]` and never printed; notice_codex_plugin_root_not_printed uses a root with a quote, a backslash and non-ASCII bytes and requires one valid object without the path | closed |
| T-08-06 | Tampering | user setup through the notice's advice | low | mitigate | three exact-command gates, one per route, so the plugin route never sends the user to install a second hook (notice_codex_plugin_route_no_other_steps) | closed |
| T-08-07 | Repudiation | exit contract | low | accept | no new exit path and no new stdout write; test_exit_contract.sh and the static single-writer gate already pin both and stay green | closed |
| T-08-08 | Tampering | `rm -rf` of a skill directory in remove_all | high | mitigate | only `$skills_dir/bbj-programming` and `$skills_dir/bbj-web-programming` (fixed child names), only when `$skills_dir` is non-empty, the path is a real directory (not a symlink) and `diff -r` finds it identical to the shipped copy; the script dir goes through `rmdir`, never `rm -rf` | closed |
| T-08-09 | Tampering | config.toml edits by remove_tables | high | mitigate | a server is removed only in the exact forms the installer writes (analyze extra=0, url equal to the --docs-url in effect, tools approve or missing, oauth ours or missing), all or nothing per server; one-time backup before the first change; written in place so a symlinked file keeps its link (remove_round_trip_*, remove_crlf_config) | closed |
| T-08-10 | Tampering | hooks.json | medium | mitigate | deleted only when `cmp -s` with the block from the same render_hooks the install uses; a symlinked or merged hooks.json is left in place and its entry printed | closed |
| T-08-11 | Elevation of Privilege | side effects of removal | low | mitigate | no codex call and no mkdir in remove mode (remove_never_calls_codex; the acceptance criterion greps remove_all) | closed |
| T-08-12 | Repudiation | what --remove did | low | accept | every object gets one output line (removed, left in place, nothing to remove) and config.toml.bbj-backup keeps the pre-install state; no separate log is written | closed |
| T-08-13 | Tampering | `--remove --force` on a differing skill directory | high | mitigate | refused with exit 2 before any write (remove_refuses_force); remove_left_skill_differs proves a differing directory survives plain --remove | closed |
| T-08-14 | Tampering | user forms in config.toml | high | mitigate | remove_left_docs_forms (six forms) and remove_left_local_forms (two forms) require byte-identical config.toml and exit 3 | closed |
| T-08-15 | Tampering | symlinked skill dir or hooks.json | medium | mitigate | links are never followed for deletion; remove_left_skill_symlink and remove_left_hooks_symlink check link and target | closed |
| T-08-16 | Denial of Service | a missing Codex home or a newline path | low | mitigate | refused with exit 2 and no directory created (remove_refuses_missing_home, remove_refuses_newline) | closed |
| T-08-17 | Tampering | run.sh against the real ~/.codex or ~/.agents | high | mitigate | safe_out refuses any OUTDIR outside $HOME/.cache/bbj-phase8/ and anything under /tmp, ~/.codex or ~/.agents (selftest proves the refusals); HOME and CODEX_HOME point into OUTDIR; realhome before and after, compared with home_diff and recorded | closed |
| T-08-18 | Information Disclosure | env probe | high | mitigate | env-probe.sh writes only three named variables, never the environment; result files stay under ~/.cache and only shortened excerpts reach the record | closed |
| T-08-19 | Elevation of Privilege | the trust bypass of codex exec | medium | mitigate | used only in scripted throwaway runs; the owner pass trusts in /hooks; plan 08-07 adds a forbid gate so no doc recommends it | closed |
| T-08-20 | Denial of Service | a billed model call | medium | mitigate | every exec passes the loopback fake provider with requires_openai_auth=false; owner-H's config.toml sets the same provider so the TUI cannot reach a real model | closed |
| T-08-21 | Spoofing | OAuth callback | low | accept | only the hosted server's registered callbacks are used (port 47613); the owner completes the browser step and can read the redirect_uri recorded beforehand | closed |
| T-08-22 | Elevation of Privilege | plugin upgrade keeping trust silently | medium | mitigate | observed and recorded (upgrade_asks_trust_again, hook_runs_after_upgrade); plan 08-07 writes the observed behaviour into the docs so the user knows to re-trust or knows the hook keeps running | closed |
| T-08-23 | Information Disclosure | OAuth block in a shipped file | high | mitigate | only the public client id and the registered loopback callback, equal to owner-B's variant; layout_codex_mcp pins the exact dict and layout_mutation_codex_secret proves a secret fails | closed |
| T-08-24 | Tampering | location rule (only if the owner amends D-07) | low | mitigate | `[ -f ... ]` test only, never reads or sources the file; the path is computed from $0 and never reaches a command; two gates pin both routes | closed |
| T-08-25 | Tampering | switch runs against the real home | high | mitigate | HOME and CODEX_HOME throwaway under ~/.cache/bbj-phase8 (safe_out); realhome before and after this plan compared and recorded | closed |
| T-08-26 | Elevation of Privilege | docs recommending the hook-trust bypass | medium | mitigate | codex_forbids_hook_trust_bypass and readme_forbids_hook_trust_bypass; the page tells users to trust the hook in /hooks | closed |
| T-08-27 | Tampering | pre-approval example widening tool approvals | medium | mitigate | the example names only read-only docs tools and is labelled untried; the three code-sending tools keep their prompt, as the page already explains | closed |
| T-08-28 | Repudiation | unbacked claims on the page | low | mitigate | upgrade, sign-in and double-install wording copied from 08-LINUX-RUN.md (verify checks the upgrade sentence verbatim); codex_verified_claim and codex_version_single stay green | closed |
| T-08-29 | Tampering | --remove instructions deleting user data | low | mitigate | the page states exit 3 and the left-in-place cases, and tells 0.1.0 users to copy out edits before deleting by hand; --force is refused with --remove | closed |
| T-08-30 | Repudiation | a scope change no owner made (re-scope of CODEX-01, D-07 amendment, hold) | high | mitigate | Task 1 is checkpoint:decision with gate blocking-human and no auto_select; Task 2 checks the answer against the evidence rules, quotes the reply verbatim with its date, and writes the change into REQUIREMENTS.md, ROADMAP.md or 08-CONTEXT.md with a dated marker that plan 08-07's phase gate reads | closed |
| T-08-31 | Tampering | ROADMAP.md and REQUIREMENTS.md edits | medium | mitigate | scoped edits of the named lines only; Task 2's verify requires 4 phase headings in ROADMAP.md and 23 requirement lines in REQUIREMENTS.md after the edit | closed |
| T-08-32 | Spoofing | hook trust recorded without a real /hooks trust | medium | mitigate | `trust: yes` only from the owner's `trusted: yes`; `trust: retried` only from the owner's retry reply and only when hooks_list.py on owner-H then reads trustStatus trusted for the plugin hook key (Task 2 step 1 and its verify read it live); the trust-bypass flag of codex exec is never used in owner-H; a failed retry goes back to the owner, whose other option is a recorded hold | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-08-01 | T-08-07 | no new exit path and no new stdout write; test_exit_contract.sh and the static single-writer gate already pin both and stay green | owner (plan threat model, verified by /gsd-secure-phase) | 2026-10-13 |
| AR-08-02 | T-08-12 | every object gets one output line (removed, left in place, nothing to remove) and config.toml.bbj-backup keeps the pre-install state; no separate log is written | owner (plan threat model, verified by /gsd-secure-phase) | 2026-10-13 |
| AR-08-03 | T-08-21 | only the hosted server's registered callbacks are used (port 47613); the owner completes the browser step and can read the redirect_uri recorded beforehand | owner (plan threat model, verified by /gsd-secure-phase) | 2026-10-13 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-13 | 32 | 32 | 0 | gsd-security-auditor (opus) via /gsd-secure-phase |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-13 (gsd-security-auditor, ASVS L1, block_on high: 32/32 closed, 0 open)

---

## Residual Notes (non-blocking, from the 2026-10-13 audit)

1. **T-08-02 / T-08-23 — top-level keys of `plugins/bbj/.codex-mcp.json` are not checked.** `layout_codex_mcp` compares only the `mcpServers` value, so a key such as `clientSecret` placed beside `mcpServers` passes `tests/test_layout.py` (probe: rc 0 on a scratch copy). Codex reads only `mcpServers`, so such a value could not function as a credential, but it would still ship. Fix: compare the whole parsed file in `layout_codex_mcp`. Both rows stay closed at L1; treating this as a blocker would make `threats_open` 2.
2. **T-08-19 / T-08-26 — the hook-trust-bypass forbids scan only `docs/install-codex.md` and `README.md`.** No other user-facing file carries the flag stem today.
3. **T-08-30 / T-08-32 — owner provenance is procedural**: a blocking checkpoint plus a dated verbatim quote in `08-LINUX-RUN.md`; code cannot prove who answered.

## Security Audit 2026-10-13

| Metric | Count |
|---|---|
| Threats found | 32 |
| Closed | 32 |
| Open | 0 |
