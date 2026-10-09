# Project Research Summary

**Project:** bbj-agent-plugins, release 0.2.0
**Domain:** Coding-agent plugin (Claude Code marketplace + Codex installer) for BBj: skills makeover, local check route, stop vendoring, hook notice
**Researched:** 2026-10-09
**Confidence:** HIGH for the build plan; MEDIUM for runtime-only and DWC claims

## Executive Summary

0.2.0 is brownfield work on a POSIX `sh` + Python 3 stdlib codebase; no new runtime is needed.
The order that matters is to build the gate first and rewrite the content second. The decisive finding is that
`bbj-ls` is parse-only: `bbjcpl -t` flags 18+ blocks that `bbj-ls` passes (invented methods,
`#field` outside a class, missing `use java.util.HashMap`, the `<undeclared>`-to-typed
assignment that the skills themselves teach). Today 51 of 93 fenced `bbj` blocks fail `bbj-ls`;
roughly 50–69 fail `bbjcpl` (researchers differ — regenerate in the gate phase).

Main risks: runtime-only claims that cannot be checked without executing BBj (never-execute rule),
the changed hook contract, the installer refactor (`bbj-docs` hard-coded in ~250 lines of awk),
and silent upgrade traps for 0.1.0 Codex users (skills not replaced without `--force`; changed
hook skipped until re-approved in `/hooks`).

## Key Findings

### Recommended Stack

- POSIX `sh` + Python 3 stdlib only; tests run as `python3 -I`, so one self-contained test file
  per gate (no sibling imports).
- `bbj-ls` over `http.client` using the hook's wire shape (protocol `2026-07-28`, `Mcp-Method` /
  `Mcp-Name` headers), reading `structuredContent.diagnostics`.
- `bbjcpl -t -N -X` batched over all extracted blocks (~1.5 s vs ~74 s per block); `-W` in the
  harness only.
- Codex `config.toml`: one atomic managed block — `[mcp_servers.bbj-local]` url table, then three
  `[mcp_servers.bbj-local.tools.<tool>] approval_mode = "approve"` tables, own markers. Invalid
  values or orphan tool tables stop Codex loading the whole config. Tolerate a lone end marker
  (left by `codex mcp remove`).
- Probe: one `tools/list` POST matching `"bbj_check_syntax"`, no user code; suggests only.
- Skill frontmatter: `name` + `description` only, description ≤ 1,024 chars with triggers first
  (`bbj-web-programming` is ~1,575 today; Codex truncates). `claude plugin validate --strict` does
  not check length — add a repo test.

### Expected Features

**Table stakes:** check workflow at the top of each skill; every `bbj` block passes the gate;
every claim cited (doc URL with a quoted sentence where the page is vague) or reproduced
(BBj version noted); pointers to docs tools / `bbj://primer` instead of copied tables; neutral
names; SKILL.md body short (~100–200 lines) because Claude Code keeps only the first ~5,000 tokens
after compaction (the check workflow at line 338/464 is lost today).

**Differentiators:** rules the primer lacks; `!ERROR=26` explanation (compile-time proxy);
`bbjcpl` output quirks (26.03: errors on stderr, stdout empty, exit 0); DWC DOM / `addOuterStyle` /
focus-ring rule if reproduced.

**Anti-features:** taste as rules (GSAP, Swiper, Tabler, fonts, grid, `Utils`, `PRECISION 16`,
naming); project leftovers; fixed install paths; duplicating the primer.

**Claims to correct:** `LIMIT` is documented (`SQL_LIMIT.htm`); `injectStyle` `top` means the
top-level window; `str(Integer:"00-00")` example conflicts with the primer; "parse stdout" of
`bbjcpl` is wrong; "Built in: no USE needed" holds for BBj classes and `java.lang`, not
`HashMap`/`ArrayList`.

### Architecture Approach

- **Stop vendoring** touches README, NOTICE, both manifests, `docs/install-claude-code.md`,
  `tests/test_layout.py` (incl. the `docs_host_single_source` skills exemption), `tests/ci.sh`,
  `tests/run.sh`, `.planning/codebase/*`.
- **Installer:** parameterise the server-block logic by server name + tool list, tests green,
  then add `bbj-local`. Claude key is `bbj-ls`, Codex key is `bbj-local` — shared text must not
  use qualified tool names.
- **Check-order text:** one canonical block pasted into both SKILL.md files and the AGENTS
  snippet, pinned byte-identical by a test (a shared linked file would break per-directory Codex
  install).
- **Skills:** SKILL.md as a router; `references/` one level deep, each ending with Sources and a
  "Verified on BBj <ver>" line.
- **Gate:** `tests/test_skill_blocks.py` (lint mode in CI, extract mode) + live runner skipped
  without BBj, `BBJ_SKILLS_LIVE=1` turns missing routes into failures. `tests/run.sh` / `ci.sh`
  find tests by glob.

### Critical Pitfalls

1. **Parse-only check passes wrong code** — run `bbjcpl` first and `bbj-ls` second, and require a pass on every available route.
2. **Runtime claims vs never-execute** — `!ERROR=26`, `!ERROR=20`, `str()` mask outputs are runtime; decide policy before the makeover.
3. **Bare calls** — `v!.get(0)` and `#foo()` are valid statements; only a bare function-style call `name(args)` is an error. Skills and checked examples must say exactly that.
4. **REM/USE rules (reproduced)** — `lbl: rem x` valid, `lbl: ; rem x` error; `use ...; print` error, `use ...; rem` allowed; `!` is not a comment. `rem_verb.htm` does not state the `;` rule explicitly.
5. **Hook no-route detection** — `no_tier1_route` returns 0 for clean, timeout and no route alike; split it into clean / errors / no-route / route-failed or the notice fires on clean files.
6. **Codex upgrade traps** — skills not replaced without `--force`; hook skipped until `/hooks` re-approval. Both go in the CHANGELOG and installer output.
7. **Release** — `plugin.json` version wins over the marketplace; strict validate flags mismatches; `tests/test_layout.py` hard-codes `VERSION`; local-path marketplace tests hide cache issues; CHANGELOG still "0.1.0 (unreleased)", no tags exist.

## Reconciliations

1. **Hook notice delivery:** exit 0 + one static JSON `hookSpecificOutput.additionalContext`
   object (not exit 2). On Codex exit 2 replaces the tool result and makes an unchecked file look
   like an error. Amend `tests/test_exit_contract.sh` narrowly: stdout may hold exactly that JSON
   object in the no-route case, empty otherwise. Once per session via an `mkdir`-atomic marker
   keyed by `session_id`, `BBJ_CHECK_STATE_DIR` test seam. **Verify on a real Codex** that
   `additionalContext` from an `apply_patch` PostToolUse reaches the model; fall back to exit 2 on
   Codex only if not.
2. **Gate routes:** both, `bbjcpl -t -N -X` first then `bbj-ls`, pass required on every available
   route. **User decision** (PROJECT.md names only `bbj-ls`).
3. **Fence grammar:** `bbj` (must pass), `bbj should-fail` (must fail on ≥1 route),
   `bbj nocheck (reason)` (skipped, reason mandatory, counted). Other languages ignored (`css`,
   `html`, `js`, `json`, `bash`, `sh`, `text`, `xml`). Every fence needs a language; unknown
   attributes, unclosed fences, `...` placeholders are errors.
4. **Bare calls:** see pitfall 3.
5. `--with-local` writes one atomic managed block, not `codex mcp add` + appended tables. Probe is a
   `tools/list` POST, suggest-only.

## Implications for Roadmap

### Phase 1: Stop vendoring
Unblocks every skill edit. Grep-zero list in PITFALLS. Keep a one-line provenance line in NOTICE.

### Phase 2: Codex local route
Refactor installer by server name first (tests green), then `bbj-local`, snippet, docs, probe,
upgrade fixture tests; `tests/fake_mcp.py` gets a `tools/list` mode.

### Phase 3: Hook no-route notice
`lib.sh` seam first, then convert ~6 silent-path test files; `/hooks` re-approval message.

### Phase 4: Example gate + structure lints
Built against the existing skills so the red baseline becomes the makeover to-do list. Canaries;
description-length, reference and denylist (leftovers, fixed paths) lints.

### Phase 5: `bbj-programming` makeover
Claim ledger first (DOC / COMPILE / RUNTIME). Check workflow at top, body ~100–150 lines. Fix REM
lines by hand only in `bbj` fences.

### Phase 6: `bbj-web-programming` makeover
Description cut ~40%. DWC claims kept only with a docs URL or a maintainer reproduction on a named
build.

### Phase 7: Release
All version fields + `tests/test_layout.py` in one commit; upgrade notes (`--force`, `/hooks`);
"Tested against" rewritten from the real run; `skip=0` on live gates; install from a git source;
tag.

### Phase Ordering Rationale
1, 2, 3 are independent (parallelizable). 4 precedes 5 and 6; 5 precedes 6 (sets conventions);
7 last.

### Research Flags
- Needs research: Phase 6 (DWC claims without doc source), Phase 5 (claim ledger, RUNTIME policy),
  Phase 3 (real-Codex payload capture).
- Standard patterns: Phases 1, 2, 4, 7.

## Open Questions for the User

1. Runtime-only claims vs never-execute: owner runs by hand / rewrite to compile-time observable
   (recommended) / drop. Same for DWC DOM claims. Blocks Phases 5–6.
2. Gate on both routes (changes Core Value wording).
3. Tag form (`0.2.0` recommended vs `bbj--v0.2.0`); bump `bbj-local` without content change?
4. NOTICE provenance: keep a one-line attribution (recommended).
5. Probe failure with `--with-local`: register and warn (recommended) or refuse.
6. `nocheck` budget: report only, or ratchet with a fail threshold (recommended).
7. Keep verified launcher facts ("if the user asks") or cut.
8. Hook notice mentions the hosted check in one clause (recommended).
9. Per-block staleness stamp (recommended out).

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Shapes exercised with Codex 0.156.1 and running `bbj-ls` |
| Features | MEDIUM-HIGH | All 14 skill files read; 20 claims spot-checked |
| Architecture | HIGH | Repo-derived |
| Pitfalls | HIGH | Reproduced on local BBj 26.03 |

**Overall confidence:** HIGH (plan), MEDIUM (runtime/DWC claims)

### Gaps to Address

- Codex hook delivery (`additionalContext` after `apply_patch`) and trust-hash scope.
- Primer cross-check of rules in Phase 5 (PITFALLS could not read the primer).
- No `!ERROR=26` entry found in BASIS docs.
- Baseline counts differ (bbjcpl failures 50 vs 69; untagged fences 7 vs 135) — regenerate in Phase 4.
- `docs_host_single_source` skills exemption in `tests/test_layout.py` needs a decision.

## Sources

### Primary (HIGH confidence)
- Local BBj 26.03: `bbjcpl -t -N -X`, `bbj-ls` on 127.0.0.1:5009 (reproductions in PITFALLS.md, STACK.md)
- Codex CLI 0.156.1 config loading (STACK.md)
- Repository files (ARCHITECTURE.md)

### Secondary (MEDIUM confidence)
- Claude Code and Codex official docs on hooks, skills, MCP config
- documentation.basis.cloud pages (`SQL_LIMIT.htm`, `rem_verb.htm`, `use_verb.htm`), `bbj://primer`

### Tertiary (LOW confidence)
- Third-party descriptions of a Codex native plugin format; DWC DOM claims without a doc source

---
*Research completed: 2026-10-09*
*Ready for roadmap: yes*
