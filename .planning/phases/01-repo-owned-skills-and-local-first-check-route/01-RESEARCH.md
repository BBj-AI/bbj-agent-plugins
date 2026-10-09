# Phase 1: Repo-owned skills and local-first check route - Research

**Researched:** 2026-10-09
**Domain:** POSIX `sh` + Python 3 stdlib plugin repository: stop vendoring, parameterise the Codex installer, add the `bbj-local` block and a `tools/list` probe, one pinned check-order text, local-first docs
**Confidence:** HIGH (repo-derived, plus live checks run this session against Codex 0.156.1, a running `bbj-ls`, `bbjcpl` 26.03 and `claude plugin validate --strict`)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Check-order block: content**
- **D-01:** Order is `bbjcpl`, then local `bbj-ls`, then the hosted check only when neither exists (already locked by LOCAL-05). When neither local route exists, the agent may use the hosted check **without asking**, but must tell the user the code was sent to the server and checked against a stock BBj.
- **D-02:** The block never names the hosted server's address; it says "the hosted check" / "the hosted docs server". `docs_host_single_source` in `tests/test_layout.py` stays strict (plugin.json is the only file naming `mcp.bbj-ai.com`) and now covers the skills too.
- **D-03:** The block carries one line on the hook: files the agent writes or edits are checked by the hook; the order applies to code the agent hands back without writing it (answers, earlier turns). Wording must be client-neutral (no `Write|Edit` vs `apply_patch`, no client-qualified tool names), since it is byte-identical across Claude Code and Codex.
- **D-04:** The `bbjcpl` step names the exact command `bbjcpl -t -N -X <file>`, noting that `-N` writes no output files and that errors arrive on stderr.

**Check-order block: placement and pinning**
- **D-05:** Delimited by HTML comment markers `<!-- bbj-check-order:begin -->` and `<!-- bbj-check-order:end -->`. The pin test extracts the text between them, requires exactly one pair per file, and requires the three copies to be byte-identical. Markers travel into users' AGENTS.md; that is accepted.
- **D-06:** In both SKILL.md files the block goes directly after the frontmatter, as the first thing in the body (interim spot until Phases 4-5 rewrite the skills; fixes the "check workflow lost after compaction" problem now).
- **D-07:** In `codex/AGENTS-snippet.md` the block replaces the current `Check:` paragraph. The Codex-only fact "files written through shell commands are not checked" stays as one sentence outside the block.
- **D-08:** The existing `bbjcpl` section in `bbj-programming/SKILL.md` (~line 353, includes the wrong "parse stdout" claim) is **left untouched** in Phase 1; Phase 4 rewrites it. Phase 1 only adds the block to the skills.

**Codex installer: --with-local and probe**
- **D-09:** A rerun **without** `--with-local` that finds a managed `bbj-local` block keeps it and refreshes it in place to the current shape; the probe is skipped. Leaving out the flag never removes something the user opted into.
- **D-10:** No removal flag. `docs/install-codex.md` documents removal as a manual step (delete the marked block, or `codex mcp remove bbj-local`; the lone-end-marker tolerance covers what that command leaves).
- **D-11:** Probe: one `tools/list` POST to `http://127.0.0.1:5009/mcp`, no user code, matching `"bbj_check_syntax"`; with `curl` flags as in the hook (`--noproxy '*'`, `--proto =http`, no redirects), short timeout (~2 s connect / ~3 s total). Without `curl`, or with no answer, print one line (e.g. "bbj-ls not probed: curl not found" / not answering) and continue. The probe never makes the installer fail or changes its exit code. `curl` stays optional.
- **D-12:** If `config.toml` names `bbj-local` in a form the installer did not write (e.g. a hand-run `codex mcp add bbj-local`), behave as for `bbj-docs` today: leave it, print the block to merge by hand, exit 3. No adopting of foreign tables.

**Docs framing**
- **D-13:** "Preferred" means **preferred over the hosted check** ("local before hosted"), for the agent's own check-tool calls, with the two reasons (code stays on the machine; checked against the installation's own PREFIX, classpath and config). `bbjcpl` stays first for the hook; the docs must not read as if `bbj-ls` beats `bbjcpl` (it is parse-only).
- **D-14:** Enabling the local check becomes its own numbered step in both install pages, marked "recommended where BBjServices 26.03+ runs": Claude Code shows `claude plugin install` / `enable bbj-local@basis-bbj`; Codex shows `--with-local`. Still opt-in. README's Install block is not extended.
- **D-15:** README's "Vendored skills" section is replaced by a short "Skills" section: the skills live in `plugins/bbj/skills`, are maintained here, and changes go through this repo's tests. No mention of BBjSkills or history.
- **D-16:** `.claude/CLAUDE.md` and `.planning/codebase/*` are updated in this phase to drop the vendoring / `skills.lock.json` / "never edit the skills" statements (part of VEND-01's "no doc references them").

### Claude's Discretion
- Exact prose of the check-order block (within D-01..D-04) and of installer messages.
- Name of the pin test file and its gate prefix (follow existing conventions, e.g. a Python `test_*.py` with `gate <prefix>_<name>` lines).
- How the installer refactor is staged (LOCAL-01 first, tests green, then `bbj-local`).
- Wording of the "Skills" README section and the NOTICE text after the provenance paragraph is removed (copyright line stays).

### Deferred Ideas (OUT OF SCOPE)
- `--without-local` installer flag to remove the managed `bbj-local` block: not needed in 0.2.0 (D-10 documents the manual step).
- Fixing the contradictory `bbjcpl` section of `bbj-programming` ("parse stdout"): Phase 4.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VEND-01 | `skills.lock.json` and `tests/test_skills_hash.py` removed; no test, script or doc references them | Touch list (section "Stop-vendoring touch list"): 2 deletions, 2 comment edits, `.claude/CLAUDE.md`, 7 codebase maps; grep-zero command |
| VEND-02 | README, NOTICE, both manifests, `docs/install-claude-code.md` say the skills are maintained here; no vendored / BBjSkills wording; NOTICE has no provenance line | Same table, with exact lines and replacement wording; a permanent wording gate is proposed for `tests/test_layout.py` |
| VEND-03 | Skills exemptions in `tests/test_layout.py` updated so skills fall under normal layout/URL rules | One exemption only (lines 130-147); what removing it needs; verified no host name in the skills today |
| LOCAL-01 | Installer server-block logic parameterised by server name and tool list; `bbj-docs` tests stay green | Installer map with line numbers, parameterisation shape, prototype that ran under mawk, staged refactor with a golden gate comparison |
| LOCAL-02 | `--with-local` writes one managed `bbj-local` block, own markers, rerun in place, lone end marker tolerated | Block shape (verified to parse on Codex 0.156.1), marker names, decision table, lone-end-marker behaviour verified with `codex mcp remove` |
| LOCAL-03 | Without the flag, one `tools/list` probe; suggests `--with-local` only, writes nothing | Probe request verified against the live `bbj-ls`; flags, regex, messages, seam, static-guard rules |
| LOCAL-04 | With flag and no answer: register anyway and warn | Decision table + warning wording; exit code unchanged |
| LOCAL-05 | One check-order block byte-identical in snippet and both SKILL.md files, pinned by a test, no client-qualified tool names | Candidate block text, placement, pin-test design and gate list; strict-validate checked with the block before the H1 |
| LOCAL-06 | README and both install pages present `bbj-local` as the preferred route with the two reasons | Current page structure, where the numbered step lands, assertions in `tests/test_install_pages.sh` that must survive |
| LOCAL-07 | `tests/test_install_codex.sh` covers flag, probe (suggest only), probe failure with flag, reruns, lone marker; `tests/fake_mcp.py` gains a `tools/list` mode | Test inventory (20 gates), fake_mcp modes, existing gates that break if left alone |
</phase_requirements>

## Summary

Phase 1 is brownfield work on shell, Python and Markdown only; no new package or runtime. It has three independent strands. (1) Stop vendoring is a deletion of two files plus wording edits in 5 shipped files, 2 test comments, `.claude/CLAUDE.md` and 7 `.planning/codebase` maps; the only code change is removing one exemption block in `tests/test_layout.py` (lines 130-147), which is safe today because no file under `plugins/bbj/skills` names the hosted host. (2) The installer refactor: `codex/install-codex.sh` hard-codes `bbj-docs` in about 250 lines (`analyze`, `print_tools`, `print_block`, the rewrite awk, the registration branch and the messages). A parameterised `analyze` (server name, tool list, legacy key, begin marker passed as awk `-v` values, regexes built by string concatenation) was prototyped in this session and produces correct output for both servers under mawk. `bbj-local` then reuses the same two-step flow as `bbj-docs`: append a table-only managed block, then let the existing "add missing tool tables at the end of the table body" awk fill in the three approvals before the end marker. That yields exactly the block shape verified on Codex 0.156.1. (3) The check-order block and docs are text plus one new Python pin test.

The traps are specific to this repo's tests. `test_static_guards.sh` scans `codex/*.sh` for the word `bbjcpl`, for `python`/`node` words, and for interpreter words, so the installer's new messages must not contain them; its curl guard is line-based and currently covers only `plugins/bbj/scripts`, so the probe's `curl` call must sit on one line and the guard should be extended to the installer. `test_install_codex.sh` farms a PATH without `curl`, `cut` or `tee` for the "no codex" cases, so new installer code may use only the tools in that list. Two existing gates break silently if the snippet or the written configs gain `bbj_check_syntax` text in the wrong shape (`tools_list_single_source` reads every `- \`bbj_...\`:` bullet of the snippet; `check_tools_never_named` forbids the three check-tool names in every config the installer wrote).

One decision in CONTEXT.md is internally ambiguous and needs a ruling before implementation (D-12: a hand-run `codex mcp add bbj-local` writes the same plain table the installer edits for `bbj-docs`). Recommendation: treat a plain table whose `url` equals the fixed loopback URL as editable, and anything else (other URL, quoted key, dotted keys, sub-tables) as foreign, exit 3. That also closes the security gap that auto-approving three tools on a non-loopback `bbj-local` table would send code off the machine without a prompt.

**Primary recommendation:** Land in three waves: (1) stop vendoring, behaviour-preserving installer parameterisation and the codebase-map edits in parallel; (2) the check-order block with its pin test, and `--with-local` plus probe plus tests; (3) the docs for README and both install pages, last, because both VEND-02 and LOCAL-06 edit the same files.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Skills ownership (no lock, normal layout rules) | Repository content + test layer (`tests/test_layout.py`) | Docs | Nothing executable; the guard is a Python test |
| `bbj-local` registration for Codex | Installer script (`codex/install-codex.sh`) writing user `config.toml` | Docs (`docs/install-codex.md`) | Codex has no plugin system here; the installer is the only writer |
| `bbj-local` registration for Claude Code | `plugins/bbj-local/.mcp.json` (unchanged, server key `bbj-local`) | `docs/install-claude-code.md` | Already exists; Phase 1 only changes the docs framing |
| Probe of a running `bbj-ls` | Installer (curl, one POST) | Test fake server (`tests/fake_mcp.py`) | Loopback only; suggest-only; never writes config |
| Check order text | Markdown copies in two SKILL.md and the snippet | Pin test (`tests/test_check_order.py`, new) | Per-directory skill install forbids a shared linked file |
| Agent's own check calls (code handed back without a file write) | Agent behaviour, steered only by the text | Hook covers written files | The hook cannot see chat-only code |
| Local-first framing | README + two install pages | Check-order block | Same two reasons everywhere, enforced by phrase gates |

## Standard Stack

No package is installed in this phase. The stack is what the repo already uses.

### Core
| Tool | Version (this machine) | Purpose | Why standard here |
|------|------------------------|---------|-------------------|
| POSIX `sh`, `awk`, `sed`, `grep` | dash; mawk 1.3.4 | Installer and sh tests | Repo constraint; prototype of the parameterised awk ran under mawk [VERIFIED: ran in scratchpad this session] |
| Python 3 stdlib | 3.14.4 (CI 3.12) | Pin test, layout test, `fake_mcp.py`, `tomllib` assertions | Repo constraint; tests run as `python3 -I` [VERIFIED: tests/run.sh:28 `python3 -I "$t"`] |
| `curl` | 8.18.0 | The probe | Already used by the hook; optional at runtime [VERIFIED: `curl --version`] |
| `codex` CLI | 0.156.1 | Real-Codex parse gate | `real_parse` already uses it when on PATH; it is on PATH here [VERIFIED: `codex --version`] |
| `claude` CLI | present | `claude plugin validate --strict` | CI gate [VERIFIED: command -v] |

### Supporting
| Tool | Purpose | When to use |
|------|---------|-------------|
| `tests/fake_mcp.py` (extend) | Fake `bbj-ls` with a `tools/list` mode | Probe tests |
| `tests/fake-bin/curl` (unchanged: exits 7) | Observe curl arguments; simulate "no answer" | Probe-flag gate |
| `tests/fake-bin/codex` (unchanged) | Logs `mcp add` calls | Assert `mcp add bbj-local` is never called |

### Alternatives Considered
| Instead of | Could use | Tradeoff |
|------------|-----------|----------|
| Two-step block (table-only append, then awk adds tool tables) | One atomic append of the full block | Atomic is cleaner but needs a second code path for "orphan tool tables without the table" (duplicate tool tables are invalid TOML). The two-step path reuses tested code and its intermediate state (table with url, no approvals) is valid TOML. |
| Reuse `BBJ_LOCAL_MCP_URL` as the probe seam | A new installer-only variable | Reuse needs no new seam and `tests/lib.sh` already makes it hermetic (`BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp`, lib.sh:30). Cost: a user with a custom hook port gets a probe against that port while the block always writes the fixed URL, so messages must print both when they differ. |

**Installation:** none.

**Version verification:** no external packages; tools above were probed with `--version` this session.

## Package Legitimacy Audit

No external package is recommended or installed in this phase, so no legitimacy check was run.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 Codex user                                        Claude Code user
     |                                                   |
     | sh codex/install-codex.sh [--with-local]          | claude plugin install bbj-local@basis-bbj
     v                                                   | claude plugin enable  bbj-local@basis-bbj
+--------------------------------------------+           v
| parse + validate options (before 1st write)|   plugins/bbj-local/.mcp.json  (server key bbj-local, unchanged)
+--------------------+-----------------------+
                     v
        sync_server bbj-docs  (codex mcp add -> managed block; 5 approvals; legacy key removal)
                     |
                     v
   +-----------------+------------------------------------------+
   | --with-local given?                                        |
   |   yes -> probe (warn if silent) -> sync_server bbj-local   |
   |   no  -> managed local block already in config?            |
   |            yes -> sync_server bbj-local (refresh), no probe|
   |            no  -> bbj-local named by hand? -> say nothing  |
   |                   else probe -> suggest / "not answering"  |
   +-----------------+------------------------------------------+
                     v
   skills copy (diff -r; --force) -> hook script copy -> hooks.json -> print snippet (carries
   the check-order block between its markers) -> trust step -> gaps -> exit 0 | 3

 probe:  curl POST tools/list --> 127.0.0.1:5009/mcp (bbj-ls)  --> reply matches "bbj_check_syntax"?
         (loopback validated, --noproxy '*', --proto =http, no -L, 2 s connect / 3 s total, no user code)

 check-order block (canonical text) --pasted byte-identical--> AGENTS-snippet.md
                                                           --> bbj-programming/SKILL.md (after frontmatter)
                                                           --> bbj-web-programming/SKILL.md (after frontmatter)
 tests/test_check_order.py extracts the text between the markers and compares the three copies
```

### Recommended Project Structure
```
codex/install-codex.sh        # sync_server (parameterised), probe_local, --with-local
codex/AGENTS-snippet.md       # block replaces the Check: paragraph (D-07)
plugins/bbj/skills/*/SKILL.md # block after the frontmatter (D-06)
tests/test_check_order.py      # NEW pin test (Python, stdlib, argv[1] root)
tests/test_install_codex.sh    # extended: local_* and probe_* gates
tests/fake_mcp.py              # extended: tools-list modes
tests/test_layout.py           # exemption removed; optional wording + exec-bit gates
tests/test_static_guards.sh    # curl guard also applied to codex/*.sh
tests/test_install_pages.sh    # new required phrases (docs, README)
```

### Pattern 1: Parameterise by globals, not by copy (installer)
**What:** In POSIX sh there is no `local` and no arrays. Set one group of globals per server and let every function read them: `srv`, `srv_tools`, `srv_begin`, `srv_end`, `srv_url`, `srv_legacy` (docs only), `srv_codex_add` (docs only), `srv_fixed_url` (local only). Wrap the whole current section 1 (lines 304-442) in `sync_server()` and call it once per server. Pass the same values into awk with `-v`.
**When to use:** all of section 1.
**Prototype that ran under mawk (analyze with dynamic regexes):**
```sh
# Source: written and run in the scratchpad this session [VERIFIED: output below]
analyze() {   # analyze SRV "TOOLS" OLD_KEY BEGIN_MARKER FILE
  awk -v srv="$1" -v tools="$2" -v old_key="$3" -v begin="$4" -v sq="'" '
    BEGIN {
      key = "(\"" srv "\"|" srv ")"
      main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
      tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
      tool_pre = "^\\[mcp_servers\\." key "\\.tools\\."
      ...
    }
    { if ($0 == begin) managed = 1
      if (line ~ main_re) { sect = "main"; main = 1 }
      else if (line ~ tool_re) { name = line; sub(tool_pre, "", name); sub(/\].*$/, "", name) ... }
      else if (index(line, srv)) { mention = 1 ... }          # was: line ~ /bbj-docs/
      ... if (sect == "main" && line ~ /^[ \t]*url[ \t]*=/) url = val(line)
      ... if (old_key != "" && line == old_key) dstate = "ours"  # docs only; "" never matches
    }
    END { print "main=" ...; print "managed=" ...; print "url=" url ... }' "$5"
}
```
Run result for a config holding both managed blocks (docs with one approved tool; local with one approved, one table without key, one missing): docs reported `main=1 managed=1 anytool=1 tool.bbj_search=approve`, local reported `main=1 managed=1 url=http://127.0.0.1:5009/mcp anytool=2 tool.bbj_check_syntax=approve tool.bbj_format=nokey tool.bbj_denum=missing`. The two analyses do not interfere. Two new analysis fields are needed: `managed` (exact begin-marker line present) and `url` (value of the `url` key of the main table).

**Messages:** keep every `bbj-docs` string byte-identical (tests grep several of them: `was not modified`, `in a form this script does not edit`, `remove the line by hand`, `removed the line default_tools_approval_mode = "approve"`, `default_tools_approval_mode to prompt; left as is`, `tool bbj_lookup has approval_mode prompt (yours); left as is`) by prefixing with `"$srv: "`. Only the parenthetical about hosted check tools differs: for `bbj-local` say nothing leaves this machine.

### Pattern 2: Decision table for the `bbj-local` pass
| `--with-local` | managed block present (begin marker) | `bbj-local` named elsewhere | Action |
|---|---|---|---|
| yes | any | any | Probe once (warn when silent), then `sync_server bbj-local`; foreign form or non-fixed url: print block, `pending=1` (exit 3) |
| no | yes | - | Skip probe; `sync_server bbj-local` to refresh in place (D-09); same foreign handling |
| no | no | yes (hand-registered) | Do nothing, say nothing (the user already did it); no suggestion |
| no | no (lone end marker counts as no block) | no | Probe: found -> one suggestion line, nothing written; silent -> one "not answering" line; no curl -> one "not probed: curl not found" line |

### Pattern 3: Marker handling and the lone end marker
Markers for the new block (the shape of STACK.md, and the repo's `MARK_*` style): begin `# >>> bbj-agent-plugins bbj-local (managed) >>>`, end `# <<< bbj-agent-plugins bbj-local (managed) <<<`. The `bbj-docs` markers stay byte-identical because 8+ gates pin them (test_install_codex.sh:228, 230-231, 534, 538, 620). Exact-line comparison keeps them from colliding (`line == mark_end` in the rewrite awk).
Verified this session on Codex 0.156.1: with the block in `config.toml`, `codex mcp get bbj-local` exits 0 and prints `transport: streamable_http`, `url: http://127.0.0.1:5009/mcp`; `codex mcp remove bbj-local` removes the table and its tool tables **and the begin marker**, leaving only the line `# <<< bbj-agent-plugins bbj-local (managed) <<<`. So the tolerated case is a lone END marker. Rule: `managed` is true only when the begin marker is present; a stray end marker is a comment line that the analysis ignores, a fresh block is appended after it, and a rerun finds `main=1 managed=1` and changes nothing. The file then carries two end-marker lines; a test must therefore count `[mcp_servers.bbj-local]` (once), not end markers.

### Pattern 4: Order of operations and the docs flush
The docs rewrite awk buffers blank and comment lines after a table body and flushes at the next `[` header or at its own end marker. If a non-managed `[mcp_servers.bbj-docs]` table is directly followed by the local block, the local begin-marker comment is buffered, the docs tool tables are inserted before it, and the comment is re-emitted before `[mcp_servers.bbj-local]`. Traced by hand from install-codex.sh:381-425; add a test with both servers in both orders.

### Anti-Patterns to Avoid
- **Copying the 150-line `analyze` for `bbj-local`:** two parsers drift; parameterise instead (PITFALLS 16, STACK).
- **`default_tools_approval_mode` on `bbj-local`:** server-wide approval; the installer already removes it for `bbj-docs` (install-codex.sh:61-63 `OLD_KEY_LINE='default_tools_approval_mode = "approve"'`).
- **`codex mcp add bbj-local`:** cannot set `approval_mode`; also makes the fake-codex log assertion `mcp add bbj-local` impossible to honour. Use the managed block even when `codex` is on PATH.
- **`required = true`, `enabled = false`, `startup_timeout_sec` in the block** (STACK.md "What NOT to Use").
- **Editing the existing `bbjcpl` section of `bbj-programming/SKILL.md`** (D-08).

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---------|-------------|-------------|-----|
| TOML assertions in tests | grep for `approval_mode` counts only | `python3 -I -c 'import tomllib'` summaries as `tsum` already does (test_install_codex.sh:73-83), skip when no `tomllib` | Parses structure; catches a tool table without a parent |
| Loopback URL validation in the probe | A new regex | Copy the hook's `case` + `sed -nE` pair (bbj-check.sh:90-94) | One verified rule; the hook and the installer must agree |
| curl flags | A new flag set | The hook's set, with the probe's timeouts and the extra headers below | `test_static_guards.sh` pins `--noproxy`, `--proto =http` and no `-L` |
| Fake server | A new fake | Extend `tests/fake_mcp.py` (modes), start it as `test_tier2_fake.sh` does (`python3 -I ... --port-file --log --mode`) | Request log already records method, path, headers, body |
| Rewriting `config.toml` | `sed -i` or `mv` over it | The existing in-place `cat "$tmp" > "$config"` rewrite | Keeps symlinked configs and file modes (WR-01); `scan sed_in_place` forbids `sed -i` |

**Key insight:** every hard part here (foreign-form detection, symlink and mode preservation, backup-once, idempotent reruns) is already solved and tested for `bbj-docs`. The phase is a parameterisation, not a second implementation.

## Stop-vendoring touch list

Searched with `grep -rniE 'vendor|BBjSkills|skills\.lock|skills_hash|skills-hash|test_skills'` over the whole repo (`.git`, `node_modules` excluded), plus a second pass for `byte-for-byte|hash-lock|frozen|re-sync|upstream`. `tests/ci.sh:10` says "skills hash" with a space, which the first regex misses; add `|skills hash` to the command.

### Must change (shipped files and tests)
| File | Lines | Current text (verbatim) | Action |
|------|-------|-------------------------|--------|
| `skills.lock.json` | whole file | `"source": "BBjSkills"` (line 29) | Delete |
| `tests/test_skills_hash.py` | whole file | `"""tests/test_skills_hash.py -- plan 19-03: the vendored skills are byte-identical to the lock.` | Delete (removes 3 gates: `skills_lock_shape`, `skills_files_match_lock`, `skills_no_executable_bit`) |
| `tests/run.sh` | 35 | `# the layout, skills-hash, install-page and CI-guard tests are python: they must not vanish in CI` | Comment only: drop "skills-hash" |
| `tests/ci.sh` | 10 | `#                        layout, skills hash, install pages, CI guards)` | Comment only: replace with `layout, check-order pin, install pages, CI guards)` |
| `tests/test_layout.py` | 130-147 | `# the hosted host name occurs once outside the vendored skills` and the `skills_dir` skip | See next section |
| `NOTICE` | 3-6 | `bbj-web-programming from BBjSkills by BASIS International Ltd., vendored verbatim` / `at the commit recorded in skills.lock.json and published under the Apache License 2.0` | Delete the paragraph (VEND-02: no provenance line). Keep `bbj-agent-plugins` and `Copyright 2026 BASIS International Ltd.` |
| `plugins/bbj/.claude-plugin/plugin.json` | 4 | `"description": "The hosted BBj docs MCP server, the BBjSkills, and a compile-only check ...` | `the two BBj skills (bbj-programming, bbj-web-programming)` |
| `.claude-plugin/marketplace.json` | 3 and 12 | `the BBj docs server, the BBjSkills and a compile-only check` | `two BBj skills` |
| `README.md` | 5, 37-41 | `the two BBjSkills`; `## Vendored skills` ... `Never edit it here` | Line 5 to `the two BBj skills`; section replaced per D-15 (candidate below) |
| `docs/install-claude-code.md` | 70-71 | `(the BBjSkills, shipped` / `unchanged).` | `(maintained in this repository)` |

### Must change (D-16 maps and project instructions)
| File | Lines (as of today) | Content to change |
|------|--------------------|-------------------|
| `.claude/CLAUDE.md` | 35, 37, 66, 70, 108, 114, 116, 247, 277, 304, 314-316, 344, 350 | `test_skills_hash.py` in file lists; `lock file`/`skills.lock.json` in JSON list; `External, not vendored` (line 66 describes the compiler; reword to "not shipped here" so the grep stays at zero); the "Vendored skills" bullet; the Architecture lines ("Content is vendored and frozen", "hash-locked", "Byte-identical copy of upstream skills", "Vendored skills are read-only here", anti-pattern "Editing the vendored skills in place") |
| `.planning/codebase/STRUCTURE.md` | 30, 47, 86, 104-105, 116, 135, 145, 159, 200-201, 221-223 | tree comments, lock entry, "Do not add to skills while the lock applies" |
| `.planning/codebase/ARCHITECTURE.md` | 28, 57-61, 119, 189-190, 209-212, 259-260, 268-273 | pattern bullet, "Vendored content" abstraction, anti-pattern block |
| `.planning/codebase/TESTING.md` | 43, 167, 215, 284 | `test_skills_hash` listings and "Skill content is checked only for byte identity" |
| `.planning/codebase/CONVENTIONS.md` | 11, 20, 22 | `skills.lock.json`, `test_skills_hash.py` example, "Vendored skill docs" |
| `.planning/codebase/CONCERNS.md` | 13-17, 105-106 | the two vendoring concern sections (delete) |
| `.planning/codebase/STACK.md` | 9, 13, 51, 57 | same strings as CLAUDE.md |
| `.planning/codebase/INTEGRATIONS.md` | 32-34 | "BBjSkills upstream (historical source)" |

### Historical or out of scope (recommendation)
- `CHANGELOG.md` lines 9 (`the two BBjSkills`) and 41 (`vendored byte for byte (see skills.lock.json)`): these describe what the never-tagged 0.1.0 entry shipped. VEND-02 does not list CHANGELOG; VEND-01 says "no doc references them", and line 41 points at a file that no longer exists. **Recommendation:** leave the 0.1.0 entry untouched in Phase 1 and allow `CHANGELOG.md` as the single exception in the grep-zero check; Phase 6 (REL-02) rewrites "Tested against" and adds the 0.2.0 entry anyway, and is the right place to remove the dangling pointer. Flagged as Open Question 4.
- `.planning/{PROJECT,ROADMAP,REQUIREMENTS,STATE}.md`, `research/`, `seeds/`, `phases/`: planning records, excluded from the check (PROJECT.md "Validated" line is updated by the GSD phase transition, not by hand here).

### Grep-zero verification command
```sh
grep -rniE 'vendor|BBjSkills|skills\.lock|skills_hash|skills-hash|skills hash|test_skills' \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=phases --exclude-dir=research --exclude-dir=seeds . \
  | grep -vE '^\./(CHANGELOG\.md|\.planning/(PROJECT|ROADMAP|REQUIREMENTS|STATE)\.md)'
```
Must print nothing. Today it hits 14 files. Verified this session that the pre-change run lists `skills.lock.json`, `tests/*`, `NOTICE`, both manifests, README, one docs page, CLAUDE.md and the 7 maps.

### Replacement wording (candidates, discretion area)
- README section (D-15): `## Skills` / `The two skills, bbj-programming and bbj-web-programming, live in plugins/bbj/skills and are maintained in this repository. Changes go through this repository's tests (sh tests/run.sh).`
- NOTICE: two lines only.
- What the deleted hash test also guarded: "no vendored file is executable" (`tests/test_skills_hash.py:81`). After deletion nothing stops an exec bit on a skill file. Cheap replacement for `tests/test_layout.py`: walk `plugins/bbj/skills`, FAIL on `os.access(path, os.X_OK)`. Optional (discretion).

## `tests/test_layout.py` `docs_host_single_source`

[VERIFIED: tests/test_layout.py:130-147] The current code, verbatim:
```python
# the hosted host name occurs once outside the vendored skills
hits = []
plugins_dir = os.path.join(ROOT, "plugins")
skills_dir = os.path.join(plugins_dir, "bbj", "skills")
for dirpath, dirnames, filenames in os.walk(plugins_dir):
    if os.path.abspath(dirpath) == skills_dir:
        dirnames[:] = []
        continue
    ...
gate("docs_host_single_source", hits == ["plugins/bbj/.claude-plugin/plugin.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))
```
Removal requires: delete `skills_dir`, the `if os.path.abspath(dirpath) == skills_dir:` block and its `dirnames[:] = []`/`continue`, and reword the comment to `the hosted host name occurs once under plugins/`. The gate name, the expected value and the detail format stay. It stays green: `grep -rn 'bbj-ai\.com' plugins/bbj/skills` returns nothing [VERIFIED this session]. It also now guards the new check-order block (D-02), which must not name the host. This is the only skills exemption: a grep for `skills` across `tests/*.sh` and `tests/*.py` finds only this block, comments in `run.sh`/`ci.sh`, the installer test's `diff -r` of the skills against the install, and the install-pages phrases `~/.agents/skills` / `~/.codex/skills` [VERIFIED: grep this session]. Nothing else treats the skills specially, and no test depends on the lock.

Proposed additions to the same file (small, discretionary, all stdlib):
- `layout_no_skills_lock`: `skills.lock.json` and `tests/test_skills_hash.py` do not exist (VEND-01 as a permanent gate).
- `layout_no_vendoring_wording`: README, NOTICE, both manifests and `docs/*.md` contain none of the forbidden words. Assemble the words from pieces as `tests/test_ci_guards.py` does (`"vend" + "or"`, `"BBj" + "Skills"`), so the file does not trip its own scan.
- `layout_skills_not_executable`: replaces the one property the hash test guarded.

Mutation check for the acceptance step: copy the repo to a temp dir, add the host name to a skills file in the copy, run `python3 -I tests/test_layout.py "$COPY"`, expect exit 1 and a FAIL on `docs_host_single_source`. (The test already accepts `argv[1]`.)

## Installer map: where `bbj-docs` is hard-coded

[VERIFIED: codex/install-codex.sh, read in full this session; values quoted verbatim]

| Symbol | Lines | Hard-coding | Parameterisation |
|--------|-------|-------------|------------------|
| `MARK_BEGIN` / `MARK_END` | 55-56 | `'# >>> bbj-agent-plugins (managed) >>>'` / `'# <<< bbj-agent-plugins (managed) <<<'` | keep as the docs markers; add `LOCAL_MARK_BEGIN` / `LOCAL_MARK_END` (names above) |
| `DOCS_TOOLS` | 59 | `'bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples'` | keep; add `LOCAL_TOOLS='bbj_check_syntax bbj_format bbj_denum'` (also test-cross-checked, see below); `srv_tools` selects |
| `TOOL_KEY` | 60 | `'approval_mode = "approve"'` | shared |
| `OLD_KEY_LINE` | 63 | `'default_tools_approval_mode = "approve"'` | docs only: pass `""` for local; in `analyze` guard with `old_key != ""` |
| `analyze` | 192-262 | literal `bbj-docs` in regexes at 215, 218, 221, and in `/bbj-docs/` at 228 and 233 | `-v srv=...`, regexes built in `BEGIN` (prototype above) |
| `refresh` / `an` | 264-270 | uses `analyze` with no arguments | `refresh` passes `$srv $srv_tools ...` |
| `tools_in_state` | 272-278 | `$DOCS_TOOLS` | `$srv_tools` |
| `print_tools` / `print_block` | 280-289 | `$DOCS_TOOLS`; `[mcp_servers.bbj-docs.tools.%s]`; `[mcp_servers.bbj-docs]` | `$srv_tools`, `$srv` |
| `state` | 292-303 | reads `an` fields | add `foreign=1` when `srv_fixed_url=1` and `an url` differs from `srv_url`; `dstate` only meaningful for docs |
| backup + need_change | 306-314 | uses `dstate = ours`, `miss`, `nokey` | unchanged logic; backup is one shared file, written once |
| registration | 316-327 | `codex mcp add bbj-docs --url "$docs_url"`; message texts | `srv_codex_add=1` for docs only |
| managed append | 342-354 | `$MARK_BEGIN`, `[mcp_servers.bbj-docs]`, `url = "$docs_url"`, `$MARK_END` | `$srv_begin`, `$srv`, `$srv_url`, `$srv_end` |
| user-values report | 359-373 | `$DOCS_TOOLS`, text about default_tools_approval_mode | gate the `dstate` part with `srv_legacy` |
| rewrite awk | 375-442 | `-v mark_end="$MARK_END"`; literal `bbj-docs` regexes at 416 and 417-420; table header print at 390 | `-v mark_end="$srv_end"` and `-v srv=...`; header printed as `"[mcp_servers." srv ".tools." names[i] "]"` |
| skills, script, hooks.json, snippet, gaps | 445-524 | not server specific | unchanged except the snippet now carries the block and a `--with-local` hint |

### What `--with-local` adds to the CLI surface
Option parse (line 101-110 `case`): `--with-local) with_local=1; shift ;;`. `usage()` (77-93) and the header comment (2-52) gain the flag, the new exit-3 cases (foreign `bbj-local`, non-fixed URL) and the probe. `usage()` is an unquoted heredoc: escape any `$` or backtick in new text.

### Staging that keeps tests green (recommended)
1. Capture a golden before touching anything: `sh tests/test_install_codex.sh | grep '^gate '` (55 gates, all `ok` today [VERIFIED: baseline run, 55 gate lines in that file; full suite `SUMMARY: ok=365 fail=0 skip=2`]) and the stdout of 4 scenarios (fresh with fake codex, fresh without codex, existing table, foreign form).
2. Refactor with `srv=bbj-docs` only, no flag, no probe: gate lines and stdout must be byte-identical.
3. Add `bbj-local`, the flag and the probe, with new gates.
Commit 2 and 3 separately so a regression bisects to the refactor.

## Probe (D-11)

### Request, verified against the live `bbj-ls`
[VERIFIED: ran this session against `127.0.0.1:5009`] This command returned rc 0 and a `tools/list` result listing `bbj_check_syntax`, `bbj_denum`, `bbj_format` as compact JSON (`"name":"bbj_check_syntax"` with no spaces):
```sh
curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 3 -X POST \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/list' \
  --data '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}' \
  --url http://127.0.0.1:5009/mcp
```
(The real call must be on ONE line; see the static-guard rule below.) Facts found by trying variants:
- Without the `Mcp-Method` header the server answers `{"jsonrpc":"2.0","id":1,"error":{"code":-32020,"message":"Mcp-Method header mismatch"}}`. The header is required for `tools/list` too, not only for `tools/call`. [VERIFIED]
- Closed port (`127.0.0.1:9`): curl rc 7, empty reply. A plain HTTP server on the port (python `http.server`): rc 0, an HTML body with no tool name, so the verdict is the name match, not the exit code. [VERIFIED]
- Reply match: `grep -Eq '"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"'` matched the live reply (count 1). Whitespace-tolerant because `tests/fake_mcp.py` serialises with `json.dumps` spacing. An SSE reply (`data:` line) matches the same regex without extra parsing.
- The hook's wire shape differs only in `Mcp-Method: tools/call`, `Mcp-Name`, no `Accept`, `--connect-timeout 1 -m 12` and `--data-binary @-` [VERIFIED: bbj-check.sh:106, quoted below].

Hook line, verbatim, for the flag set to copy:
```
curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' --data-binary @- --url "$_url" 2> /dev/null)
```

### Skeleton (POSIX, ShellCheck-clean intent)
```sh
LOCAL_URL=http://127.0.0.1:5009/mcp
PROBE_BODY='{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
# probe_local: sets probe=found|none|nocurl|refused; one POST, no user code, never fails the install
probe_local() {
  probe=none
  probe_url=${BBJ_LOCAL_MCP_URL:-$LOCAL_URL}
  case "$probe_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) probe=refused; return 0 ;;
  esac
  _pok=$(printf '%s' "$probe_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_pok" = ok ] || { probe=refused; return 0; }
  command -v curl > /dev/null 2>&1 || { probe=nocurl; return 0; }
  _preply=$(curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 3 -X POST -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/list' --data "$PROBE_BODY" --url "$probe_url" 2> /dev/null)
  if printf '%s' "$_preply" | grep -Eq '"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"'; then probe=found; fi
  return 0
}
```
Message lines (one each; wording is discretion; none may contain the word `bbjcpl`):
- no flag, found: `bbj-local: a bbj-ls answers at <probe url>; it is not registered with Codex. Rerun with --with-local to register it as bbj-local (<LOCAL_URL>); nothing was written for it.`
- no flag, no answer: `bbj-local: no bbj-ls answered at <probe url>; not registered (rerun with --with-local once BBjServices 26.03+ runs).`
- no flag, no curl: `bbj-local: not probed: curl not found.`
- flag, no answer: `bbj-local: no bbj-ls answered at <probe url>; registering it anyway. Codex shows the server as failed until BBjServices runs.`
- refused URL (non-loopback seam value): treat like "not probed" and say why. A refused URL is never handed to curl.

### Static guards and the installer
[VERIFIED: tests/test_static_guards.sh:106-134] The `codex/*.sh` section runs these scans on non-comment lines: `interpreter_word`, `interpreter_path`, `interpreter_bin`, `terminal_io_flag`, `eval`, `json_cli` (`jq`), `python_node` (words `python*`, `node`, `nodejs`), `compiler_name` (the string `bbjcpl`), `sed_in_place`, plus `sh -n` and ShellCheck. Its own comment says `Its URL literals are not scanned: the default docs URL is the hosted https instance.` What must hold for the new installer code:
- No executable line may contain `bbjcpl`, a standalone `node`/`python` word, a standalone `bbj` word or `/bbj` followed by a quote or space. Messages about `bbj-ls` and `bbj_check_syntax` are fine.
- The curl guard (lines 71-83) is line-based and applies only to `plugins/bbj/scripts/*.sh` today. Recommendation (STACK.md says the same): extract it into a function and also run it on `codex/*.sh`. Then the probe's curl command must be a single line containing `--noproxy`, `--proto =http` and no `-L`. The scan keeps only lines that contain `curl` and then requires `--noproxy` and `--proto =http` on those same lines, so a backslash-continued command (flags on continuation lines) fails it. Keep the whole command on one line like the hook. `command -v curl` lines are excluded from that scan by `grep -v 'command -v'`.
- Do not apply the URL-literal scan to the installer: it holds the https default docs URL.
- `test_never_execute.sh` does not scan the installer; the installer test's `installer_no_compiler_calls` (test_install_codex.sh:464-472) still holds because the probe calls no compiler.

### How tests fake the pieces
- `tests/fake-bin/curl` [VERIFIED, 9 lines]: appends each argument and a `CALL` separator to `$FAKE_CURL_LOG`, `exit 7`. Use it to assert the argument set and to simulate "no answer".
- `tests/lib.sh:30` [VERIFIED] sets `BBJ_LOCAL_MCP_URL=http://127.0.0.1:9/mcp` and exports it, so every installer test is hermetic when the installer honours that variable for the probe. A dev machine with a live `bbj-ls` (this one) would otherwise print the suggestion in every existing test.
- `tests/fake_mcp.py` [VERIFIED: read in full]: `body_for(mode)` returns `(status, content_type, text)` for the existing `tools/call` modes; `do_POST` logs method, path, lowercased headers and body, answers 400/-32020 when `MCP-Protocol-Version` is missing, and calls `body_for(args.mode)` once at start to validate the mode (an unknown mode raises `SystemExit`). It has no `tools/list` handling.
- Needed for `tools/list`: in `do_POST`, parse the JSON body (try/except); when `method == "tools/list"` and the mode starts with `tools-list`, reply with a tools result. Modes: `tools-list` (the three tools, compact separators like the real server) and `tools-list-other` (a tools list without `bbj_check_syntax`, like a foreign MCP server). `body_for` must accept both names (return the clean `tools/call` reply) or the start-up validation exits. Optional: `tools-list-spaced`, and a `hang` mode that sleeps to exercise the 3 s cap (costs 3 s of test time). Update the module docstring (it lists the modes).
- Start the fake the way `tests/test_tier2_fake.sh:24-37` does (port file, poll up to 10 s). `lib.sh` has no `start_fake`; copy it into `test_install_codex.sh` with its own cleanup trap (test_tier2_fake.sh overrides the `mkwork` trap the same way). Moving it into `lib.sh` is possible but touches an unrelated test.

## Check-order block (D-01..D-07, LOCAL-05)

### Where it lands
- Both SKILL.md: frontmatter is lines 1-4 (`---`, `name: "..."`, `description: "..."`, `---`), line 5 blank, line 6 the H1 [VERIFIED: head of both files]. Insert after the closing `---`: blank line, block, blank line, then the H1. A strict validation of the plugin with the block before the H1 passed on a scratch copy [VERIFIED: `claude plugin validate --strict plugins/bbj` printed `Validation passed`].
- `codex/AGENTS-snippet.md`: replace lines 23-25, verbatim today:
  `Check: after each \`apply_patch\`, a hook compile-checks the changed \`.bbj\`, \`.src\` and \`.bbx\``
  `files with the BBj compiler (\`bbjcpl -N\`) on this machine and never runs them. Files written`
  `through shell commands are not checked.`
  with the block, followed by one Codex-only sentence outside the block, for example: `In Codex only \`apply_patch\` calls reach the hook; files written through shell commands are not checked.` The line `Built in: no USE needed. ...` (line 21) stays (Phase 4 owns that claim).
- Printing: `install-codex.sh:506-512` prints `Add the following to AGENTS.md ...`, `----8<----`, `cat "$snippet"`, `----8<----`. The markers are printed with it (accepted by D-05).

### Existing tests that read the snippet (must stay green)
| Test | Lines | What it needs |
|------|-------|----------------|
| `snippet_shape` | test_install_codex.sh:491-493 | fewer than 60 lines (25 today; a ~11-line block leaves room) and the line `Built in: no USE needed.` |
| `first_prints_snippet_and_trust` | 179-183 | the `Built in: no USE needed.` line printed in stdout |
| `tools_list_single_source` | 668-676 | `snip_tools=$(sed -n 's/^- \`\(bbj_[a-z_]*\)\`:.*/\1/p' "$SNIPPET" \| sort)` must equal `DOCS_TOOLS` and the `bbj-docs` tool tables of `docs/install-codex.md`. **The block must not contain any line of the form `- \`bbj_...\`: ...`.** Use numbered items (`1.`, `2.`, `3.`). The `bbj_check_syntax` mention in a numbered item is safe. |
| install-codex.sh:57-58 comment | - | `# the five read-only docs tools of bbj-docs, approved by name; one list, also checked against the tool bullets of AGENTS-snippet.md by the test suite` |
Adding the three local tools as bullets in the snippet (ARCHITECTURE.md suggests it) is NOT in D-07 and would break this gate unless the gate is reworked; do not do it in Phase 1.

### Naming fact that corrects earlier research
SUMMARY.md and ARCHITECTURE.md say the Claude Code server key is `bbj-ls` and the Codex key is `bbj-local`. The repository says otherwise: `plugins/bbj-local/.mcp.json` declares `"bbj-local": {"type": "http", "url": "http://127.0.0.1:5009/mcp"}` and `tests/test_layout.py:124` asserts `{"bbj-local": {"type": "http", "url": LOCAL_URL}}` [VERIFIED: both read this session]. The server key is `bbj-local` in both clients, so the block can say "the `bbj-local` server" without a client qualifier. Only the fully qualified tool name differs per client (`mcp__plugin_...` on Claude Code), which the block never writes.

### Candidate block text (satisfies D-01..D-04, LOCAL-05; discretion on prose)
```
<!-- bbj-check-order:begin -->
**Check BBj code before you hand it back.** Use the first route that exists:

1. `bbjcpl -t -N -X <file>`, when BBj is installed. It checks syntax and types. `-N` writes no output files; the errors arrive on stderr.
2. `bbj_check_syntax` of the `bbj-local` server, when that server is registered (a running BBjServices, BBj 26.03 or later). It runs on this machine, against the installation's own PREFIX, classpath and config, and it parses only: it does not type-check.
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, but tell the user that the code was sent to the server and checked against a stock BBj, not their installation.

A hook checks the BBj files you write or edit. This order is for code you hand back without writing it to a file: answers, and code from earlier turns.
<!-- bbj-check-order:end -->
```
Facts behind the wording: `bbjcpl -t -N -X` writes errors to stderr, leaves stdout empty and writes no output file (a bad file printed `error at line 10 (1): print "a"   rem x` on stderr; a clean file printed nothing; the directory held only the inputs) [VERIFIED: ran this session on BBj 26.03, scratchpad]. `bbj-ls` describes itself as checking `against that installation's own PREFIX, classpath and config` [VERIFIED: live `tools/list` description]. The `-t` type check and `bbj-ls` being parse-only come from project research (PITFALLS.md reproduction table; `bbjcpl_bbj_compiler.htm`) [CITED: .planning/research/PITFALLS.md]. Use a bold lead line, not a heading: the same text sits before the H1 in a skill and inside the `## BBj (BASIS)` section of the snippet, and a heading level cannot be right in both. Do not add the "exit status is always 0" claim: D-04 asks for stderr only, and every added claim needs its own provenance.
Note for the planner: in Codex the installer leaves the hosted check tools on Codex's own approval prompt, so "without asking" is about the agent's behaviour in chat, not about that UI prompt. Do not change either.

### Pin test design (`tests/test_check_order.py`, name and prefix are discretion)
Python stdlib, `python3 -I`, one file, `ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else ...` exactly like `tests/test_layout.py:14-15`, `gate checkorder_<name> ok|FAIL <detail>`, `sys.exit(1 if failed else 0)`.
```python
BEGIN = "<!-- bbj-check-order:begin -->"
END = "<!-- bbj-check-order:end -->"
FILES = ["codex/AGENTS-snippet.md",
         "plugins/bbj/skills/bbj-programming/SKILL.md",
         "plugins/bbj/skills/bbj-web-programming/SKILL.md"]
FORBIDDEN = ["mcp" + "__", "Write" + "|Edit", "apply" + "_patch", "mcp.bbj" + "-ai.com"]  # pieces: no self-match
def extract(rel):
    lines = open(os.path.join(ROOT, rel), encoding="utf-8").read().split("\n")
    b = [i for i, l in enumerate(lines) if l == BEGIN]
    e = [i for i, l in enumerate(lines) if l == END]
    if len(b) != 1 or len(e) != 1 or b[0] >= e[0]:
        return None
    return "\n".join(lines[b[0] + 1:e[0]])
```
Gates:
1. `markers_<file>`: exactly one begin and one end per file, each alone on its line, begin before end.
2. `identical`: the three extracted texts are equal (compare bytes of the text between the markers; print the first differing file on FAIL).
3. `route_order`: `bbjcpl -t -N -X <file>` occurs, and `index("bbjcpl") < index("bbj-local") < index("bbj-docs")`; the text contains `bbj_check_syntax`, `stock BBj` and `sent to the server` (LOCAL-05 content pins).
4. `client_neutral`: none of `FORBIDDEN`, no `Claude`, no `Codex` (case-insensitive) in the block (D-03).
5. `skill_placement_<skill>`: the text between the closing frontmatter `---` line and the begin marker is whitespace only, and the begin marker precedes the first line starting `# ` (D-06).
6. `snippet_check_paragraph_replaced`: the snippet no longer contains the line starting `Check: after each`, and still contains `files written through shell commands are not checked` (case-insensitive) outside the markers (D-07).
Mutation check in the plan: copy the repo, change one character inside one SKILL.md block, run with the copy as `argv[1]`, expect exit 1.
`tests/run.sh` finds `tests/test_*.py` by glob; no runner edit is needed [VERIFIED: tests/run.sh:25].

## Docs (D-13..D-15, LOCAL-06)

### Current structure
- `README.md` (about 50 lines): intro bullets for `bbj` and `bbj-local` (lines 3-9), `## Install` block (lines 11-15, not to be extended), install-page links, `## The check hook`, `## Vendored skills` (37-41), `## Development`, `## Licence`.
- `docs/install-claude-code.md`: `## Requirements`, `## 1. Add the marketplace`, `## 2. Install` (the `bbj-local` note with the install/enable commands is lines 37-44, a paragraph under Install), `## 3. Options`, `## What you get` (skills bullet at 70-71), `## Check routes` (hook tiers 1-3, line 79-80 says `The code never leaves your machine; the hosted docs server is not used for the check.`), `## Not covered`, `## Windows`, `## Update and remove`.
- `docs/install-codex.md`: `## Requirements`, `## 1. Run the installer` (options table lines 31-37, exit-code paragraph 39-44), `## What it does` (numbered 1-5), `## 2. Trust the hook in /hooks`, `## 3. Add the AGENTS.md snippet`, `## Check routes`, `## Not covered`, `## Windows`.

### Where the edits go
- Claude page: move the `bbj-local` paragraph and its fenced `claude plugin install bbj-local@basis-bbj` / `claude plugin enable bbj-local@basis-bbj` lines into a new `## 3. Enable the local check (recommended where BBjServices 26.03+ runs)`; `Options` becomes 4. In `## Check routes` add a short paragraph about the agent's own check calls: the order `bbjcpl`, then `bbj-local`, then hosted only when neither exists, and the two reasons; scope the sentence at line 79-80 to "the hook" so it does not contradict the block. Skills bullet at 70-71: `(maintained in this repository)`.
- Codex page: options table gains `--with-local`; exit-code paragraph names the foreign-`bbj-local` case; `## What it does` gains a step; new `## 2. Enable the local check (recommended where BBjServices 26.03+ runs)` with `sh codex/install-codex.sh --with-local`, the TOML block (three `[mcp_servers.bbj-local.tools.<tool>]` tables), rerun behaviour (D-09), the probe, and removal as a manual step (D-10): delete the marked block, or `codex mcp remove bbj-local`; that command leaves a stray `# <<< bbj-agent-plugins bbj-local (managed) <<<` comment that the installer tolerates [VERIFIED live]. Trust becomes 3, snippet 4. Say that the block is fixed at `http://127.0.0.1:5009/mcp` and that `BBJ_LOCAL_MCP_URL` moves only the hook (and the installer's probe), never the registration (PITFALLS 28).
- README: the `bbj-local` bullet states it is recommended where BBjServices 26.03+ runs and preferred over the hosted check, with the two reasons; `## Skills` per D-15 replaces `## Vendored skills`; the Install block is untouched.

### The two reasons and the framing (candidate)
"Preferred over the hosted check: your code stays on your machine, and it is checked against your installation's own PREFIX, classpath and config. Check order: `bbjcpl` first (it also type-checks), then `bbj-local` (syntax only), the hosted check only when neither exists." Never say `bbj-local` beats `bbjcpl` (D-13).

### What the tests assert about docs text (must survive)
[VERIFIED: tests/test_install_pages.sh read in full]
- Claude page required phrases (grep -F): `claude plugin install bbj@basis-bbj`, `claude plugin marketplace add BBj-AI/bbj-agent-plugins`, `docs_url`, `bbj_home`, `https://mcp.bbj-ai.com/mcp`, `bbj-local`, `## Check routes`, `bbjcpl -t -N -X`, `127.0.0.1:5009`, `syntax only`, `## Not covered`, `Bash`, `NotebookEdit`, `subagent`, `## Windows`, `Git for Windows`, `data-handling`, `config*.bbx`, `not yet been run on Windows`, `` `bbj-local reported ``, `` `bbjcpl reported ``. At least 5 `## ` sections. Every `claude plugin <words>` line in a fenced block is run as `claude plugin <words> --help` (the existing `install` and `enable` lines pass).
- Codex page required phrases: `Tested on Linux only`, `install-codex.sh`, `--docs-url`, `--skills-dir`, `--codex-home`, `default_tools_approval_mode`, the five `[mcp_servers.bbj-docs.tools.<tool>]` headers, `approval_mode = "approve"`, `bbj_check_syntax`, `~/.agents/skills`, `~/.codex/skills`, `/hooks`, `apply_patch`, `## Check routes`, `## Not covered`, `## Windows`, `Git for Windows`, `commandWindows`, `guardrail`. Forbidden on both pages: `bbj-mcp.basis.cloud`, a sentence matching `subagent[^.]*not (covered|checked)`; on the Codex page also `(was|has been|is) (verified|tested) (on|with) (a )?Codex` (so write "Codex CLI 0.156.1 loads the block", not "was tested with Codex").
- Every relative Markdown link in README, CHANGELOG and `docs/*.md` must resolve.
- `tools_list_single_source` reads only `bbj-docs` tool headers from the Codex page with `s/^ *\[mcp_servers\.bbj-docs\.tools\.\([a-z_]*\)\]$/\1/p`, so an added `bbj-local` TOML block does not disturb it.
README text is not phrase-checked today. Add gates to `test_install_pages.sh` (new `need` lines) for: both install pages carry `recommended where BBjServices 26.03`, `PREFIX, classpath and config` and (Codex) `--with-local` plus the three local tool-table headers; and a small README check for `PREFIX, classpath and config`, `## Skills`, and the absence of the forbidden vendoring words (assembled from pieces).

## Runtime State Inventory

Phase 1 removes a vendoring mechanism and edits skill text; it does not rename a runtime identifier. Explicit answers:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None. The repository holds no database, cache or user data. | none |
| Live service config | None for this repo. A user's `config.toml` may carry a `bbj-docs` block from 0.1.0; the installer already upgrades it, and `--with-local` adds a separate block. | none (covered by existing upgrade gates) |
| OS-registered state | None. Codex hook registration (`hooks.json`) is unchanged in this phase; the check script is not edited, so no new `/hooks` re-approval is triggered by Phase 1. | none |
| Secrets/env vars | `BBJ_LOCAL_MCP_URL` already exists (hook). The installer's probe reads it as a test/loopback seam; no new variable if the recommendation is accepted. | document in install-codex.md (PITFALLS 28) |
| Build artifacts / installed copies | Users who installed 0.1.0 with `install-codex.sh` hold copies of both skills in `~/.agents/skills`. After Phase 1 the repo skills differ from those copies (the block is added), so a plain rerun exits 3 and leaves them untouched until `--force`. Claude Code users keep a cached plugin copy until the version string changes (Phase 6). | Carry the `--force` upgrade note to Phase 6 (REL-02); no Phase 1 action |

## Common Pitfalls

### Pitfall 1: The installer's own static guard rejects its new messages
**What goes wrong:** `static_compiler_name_install-codex.sh` fails because a probe or hint line contains `bbjcpl`; `python_node` fails on a standalone `node`/`python`.
**Why:** the codex scan list at tests/test_static_guards.sh:112-120 covers executable lines, not comments.
**How to avoid:** keep `bbjcpl` and those words out of printed text and code in `codex/install-codex.sh`; comments may use them.
**Warning signs:** `gate static_compiler_name_install-codex.sh FAIL` right after the first probe edit.

### Pitfall 2: Multi-line curl defeats the line-based curl guard
**What goes wrong:** once the guard is extended to `codex/*.sh`, a curl command split with backslashes fails `--noproxy`/`--proto` checks line by line.
**How to avoid:** one line, as the hook does (bbj-check.sh:106).

### Pitfall 3: New installer code uses a utility the "no codex" test PATH lacks
**What goes wrong:** the no-codex cases run with a PATH of symlinks to `sh cat cp mv mkdir rm diff cmp mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd` (test_install_codex.sh:33). `cut`, `tee`, `curl`, `env` are not in it, so code that needs them fails only in those cases.
**How to avoid:** use only listed tools in the installer; `curl` is deliberately absent, which gives the "not probed: curl not found" path for free.

### Pitfall 4: Existing aggregate gates trip on the new feature
**What goes wrong:** `check_tools_never_named` (test_install_codex.sh:703-709) fails if any config in `written.list` names `bbj_check_syntax|bbj_format|bbj_denum`; a `--with-local` config does. `tools_list_single_source` fails if the snippet gains `- \`bbj_...\`:` bullets.
**How to avoid:** do not `note_cfg` local-run configs into `written.list`; add a separate gate that, in a local-run config, the three names appear only under `[mcp_servers.bbj-local.tools.*]` and never under `bbj-docs`. Keep local tools out of the snippet bullets.

### Pitfall 5: Auto-approving a non-local `bbj-local`
**What goes wrong:** a pre-existing plain `[mcp_servers.bbj-local]` with another URL would gain three auto-approved tools, so code would leave the machine without a prompt (PITFALLS 16, Security Mistakes).
**How to avoid:** treat the table as editable only when its `url` equals the fixed URL; otherwise foreign, exit 3, config untouched. Needs the `url` field in `analyze`.

### Pitfall 6: Hand-run `codex mcp add bbj-local` vs D-12
**What goes wrong:** D-12 lists a hand-run `codex mcp add bbj-local` as a "form the installer did not write" that exits 3, but the fake and real `mcp add` write the plain table `[mcp_servers.bbj-local]` + `url = "..."` (tests/fake-bin/codex:9), which for `bbj-docs` is the editable form (test `existing_table_gains_tools`).
**How to avoid:** rule on it before implementation (Open Question 1). Recommended: same URL = editable (gains approvals, exit 0); different URL or any non-plain form = foreign, exit 3.

### Pitfall 7: Probe hermeticity and a custom hook port
**What goes wrong:** if the probe ignores `BBJ_LOCAL_MCP_URL`, every existing installer test probes the real 5009 on a dev machine with `bbj-ls` and prints the suggestion; if it honours it, a user with the hook on another port is probed there while the block still writes 5009.
**How to avoid:** honour the seam (validated loopback), and when the probe URL differs from the fixed URL, print both in the message. Validate with the hook's `case`/`sed` pair; a refused URL never reaches curl.

### Pitfall 8: Docs flush swallows the next block's marker
**What goes wrong:** with a non-managed docs table directly before the local block, the rewrite awk buffers the local begin-marker comment (traced from install-codex.sh:381-425) and could mis-order it.
**How to avoid:** test both orders (docs first, local first) and assert the begin marker still directly precedes `[mcp_servers.bbj-local]`.

### Pitfall 9: SKILL.md edits fail until the hash test is gone
**What goes wrong:** the pin work edits both SKILL.md files; `skills_files_match_lock` fails on any edit (STATE.md roadmap note).
**How to avoid:** the stop-vendoring plan lands first (wave order below).

### Pitfall 10: Backup semantics change meaning
**What goes wrong:** `config.toml.bbj-backup` is written once before the first change (install-codex.sh:310-314). If the docs pass writes it, a later `--with-local` run does not refresh it, so the backup lacks the local block's pre-state.
**How to avoid:** accept (it is the file as it was before the installer's first change); say so in docs, and test that a first run with `--with-local` on an existing config backs up the original.

### Pitfall 11: ShellCheck is not installed here
**What goes wrong:** `shellcheck` is missing on this machine (baseline `skip=2`: shellcheck, busybox), so a ShellCheck finding in the new installer code appears only in CI.
**How to avoid:** keep to constructs the file already uses (`[ ... ] || ...`, quoted expansions, `case`), add reasoned `# shellcheck disable=` lines only where the file already does, and run `sh -n` plus `dash -n` locally. `.shellcheckrc` disables SC1091, SC2015, SC2016, SC1003, SC2012, SC2181 only.

### Pitfall 12: Touching the contradictory `bbjcpl` section
**What goes wrong:** an executor "fixes" `bbj-programming/SKILL.md` line ~353 while adding the block, and the pin test is blamed for unrelated diffs.
**How to avoid:** D-08; the pin test reads only the marker range and the placement.

## Code Examples

### Block insertion in a SKILL.md (placement)
```
---
name: "bbj-programming"
description: "..."
---

<!-- bbj-check-order:begin -->
...block...
<!-- bbj-check-order:end -->

# BBj Programming (general language)
```
[VERIFIED: validates under `claude plugin validate --strict` on a scratch copy]

### Local block as written by the installer (shape verified on Codex 0.156.1)
```toml
# >>> bbj-agent-plugins bbj-local (managed) >>>
[mcp_servers.bbj-local]
url = "http://127.0.0.1:5009/mcp"

[mcp_servers.bbj-local.tools.bbj_check_syntax]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_format]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_denum]
approval_mode = "approve"
# <<< bbj-agent-plugins bbj-local (managed) <<<
```
[VERIFIED: this exact text in a temp `CODEX_HOME`: `codex mcp get bbj-local` exited 0 with `transport: streamable_http` and the url; `codex mcp remove bbj-local` then left only the end-marker line.]

### Installer test: both servers parsed by `tomllib`
```sh
# lsum FILE: the bbj-local server of a config.toml; analogue of tsum (test_install_codex.sh:73-83)
python3 -I -c '
import sys, tomllib
d = tomllib.load(open(sys.argv[1], "rb"))
s = d["mcp_servers"]["bbj-local"]
print("url", s["url"])
print("default", s.get("default_tools_approval_mode", "-"))
for k in sorted(s.get("tools", {})):
    print(k, s["tools"][k].get("approval_mode", "-"))
' "$1"
# expected: url http://127.0.0.1:5009/mcp / default - / bbj_check_syntax approve / bbj_denum approve / bbj_format approve
```

### Probe request assertions against the fake server log (Python helper, like test_tier2_fake.sh:71-98)
```python
r = entries[0]; h = r["headers"]; b = json.loads(r["body"])
assert r["method"] == "POST" and r["path"] == "/mcp"
assert h["mcp-method"] == "tools/list" and h["mcp-protocol-version"] == "2026-07-28"
assert b["method"] == "tools/list" and "arguments" not in b.get("params", {})   # no user code
assert "code" not in r["body"]
```

## State of the Art

| Old approach | Current approach | When changed | Impact |
|--------------|------------------|--------------|--------|
| Skills vendored byte-for-byte, hash-locked | Skills maintained here under the normal layout rules | This phase | Unblocks Phases 3-5 edits |
| Server-wide `default_tools_approval_mode = "approve"` | Per-tool `approval_mode` tables | Earlier installers up to 398aac5 (already removed for `bbj-docs`) | Never reintroduce for `bbj-local` |
| GET-405 probe (ARCHITECTURE.md draft) | `tools/list` POST matching `"bbj_check_syntax"` | CONTEXT D-11 | 405 does not identify `bbj-ls`; the name match does |
| Claude server key `bbj-ls` (earlier research) | Key is `bbj-local` in `.mcp.json` | Read this session | The block can name one server in both clients |

**Deprecated/outdated:** the ARCHITECTURE.md draft block with a GET probe and `codex mcp add bbj-local`; the STACK.md idea of adding the local tools as snippet bullets in this phase.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Reusing `BBJ_LOCAL_MCP_URL` as the installer's probe seam is acceptable (no new variable) | Probe, Pitfall 7 | A separate seam variable is needed; small test change |
| A2 | Codex's skill loader tolerates an HTML comment block before the H1 (only Claude Code strict validation was run) | Check-order block | Codex ignores or mis-lists the skill; low risk because the frontmatter is unchanged and the loader reads `name`/`description` |
| A3 | A plain `bbj-local` table with the fixed URL should be editable (exit 0), not foreign | Pitfall 6, Open Question 1 | If the owner wants literal D-12, a hand-registered same-URL table must exit 3 |
| A4 | A registered but stopped `bbj-local` shows as failed in Codex on every start | Probe messages | Warning text overstates; it is a stated project constraint, not observed on Codex in this session |
| A5 | Leaving `CHANGELOG.md` 0.1.0 history untouched in Phase 1 satisfies VEND-01/02 | Touch list | Owner may want the dangling `skills.lock.json` pointer removed now |
| A6 | Uniform two-step block write (table, then tools) is acceptable instead of one atomic append | Standard Stack, Pattern 1 | If strict atomicity is required, a second code path for the fresh case is needed |

## Open Questions

1. **D-12 vs a hand-run `codex mcp add bbj-local`**
   - What we know: D-12 says leave a non-installer form, print, exit 3, "as for `bbj-docs` today". Today a hand-registered plain `bbj-docs` table gains tool tables and exits 0. `codex mcp add` writes the plain table.
   - What's unclear: whether a plain same-URL `bbj-local` table is "foreign".
   - Recommendation: plain table with url equal to `http://127.0.0.1:5009/mcp` is editable (exit 0, approvals added, only when `--with-local` or a managed block exists); anything else is foreign, exit 3. Security: never approve tools on another URL.
2. **Probe seam variable**
   - Recommendation: reuse `BBJ_LOCAL_MCP_URL`, validated loopback, print both URLs when they differ.
3. **Local tool bullets in the snippet**
   - Recommendation: not in Phase 1 (D-07 does not ask, and the existing bullet gate would break).
4. **CHANGELOG 0.1.0 wording**
   - Recommendation: leave; Phase 6 owns it; the grep-zero command excludes it.
5. **Exec-bit and wording gates in `tests/test_layout.py`**
   - Recommendation: add `layout_no_skills_lock`, `layout_no_vendoring_wording`, `layout_skills_not_executable` (small, stdlib, mutation-testable).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `sh` (dash), `awk` (mawk), `sed`, `grep` | installer, tests | yes | dash, mawk 1.3.4 | none needed |
| Python 3 with `tomllib` | pin test, layout test, TOML assertions | yes | 3.14.4 | gates skip without `tomllib` (existing pattern) |
| `curl` | probe | yes | 8.18.0 | probe prints "not probed: curl not found" |
| `codex` CLI | real-parse gate, `codex mcp get/remove` | yes (on PATH) | 0.156.1 | gate skips |
| `claude` CLI | `claude plugin validate --strict`, install-page command gate | yes | present | CI installs it |
| Running `bbj-ls` on 127.0.0.1:5009 | live probe check, `test_tier2_live.sh` | yes (running here) | BBj 26.03 | live tests skip; unit tests use `fake_mcp.py` |
| `bbjcpl` | `test_real_compiler.sh`, command verification | yes | `/opt/bbx/bin/bbjcpl` (26.03) | gates skip |
| `shellcheck` | `tests/ci.sh`, static guard | **no** | - | skips locally; CI fails if missing (`CI=true`); keep code ShellCheck-conservative |
| `busybox` | exit-contract gate on busybox sh | no | - | gate `shell_busybox` skips |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** `shellcheck`, `busybox` (both already skipped in the baseline).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Custom `gate NAME ok|FAIL|skip` protocol: POSIX sh tests + Python 3 stdlib tests run by `tests/run.sh` |
| Config file | none; `.shellcheckrc` for lint |
| Quick run command | `python3 -I tests/test_layout.py && python3 -I tests/test_check_order.py && sh tests/test_install_pages.sh` |
| Full suite command | `sh tests/run.sh` (about 45 s here; baseline `SUMMARY: ok=365 fail=0 skip=2`) and `sh tests/ci.sh` for strict validation and ShellCheck |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VEND-01 | lock and hash test gone; no doc references | static grep + gate | grep-zero command above; `python3 -I tests/test_layout.py` (`layout_no_skills_lock`) | gate Wave 0 |
| VEND-02 | wording replaced; NOTICE has no provenance line | gate | `python3 -I tests/test_layout.py` (`layout_no_vendoring_wording`) | Wave 0 |
| VEND-03 | skills under host-single-source rule | unit + mutation | `python3 -I tests/test_layout.py`; mutation: host name in a skills file of a copy => FAIL | exists (edit) |
| LOCAL-01 | `bbj-docs` behaviour unchanged after refactor | regression | `sh tests/test_install_codex.sh` (55 pre-existing gates all ok) + golden stdout diff | exists |
| LOCAL-02 | one managed block, own markers, rerun, lone end marker | integration | `sh tests/test_install_codex.sh` new gates `local_*` (tomllib summary; `real_parse ... bbj-local`) | Wave 0 |
| LOCAL-03 | probe suggests only; writes nothing | integration with fake server | `sh tests/test_install_codex.sh` `probe_found_suggests`, `probe_no_answer_no_flag`, `probe_no_curl`, `probe_other_server_no_suggestion`, `probe_request_shape` | Wave 0 |
| LOCAL-04 | flag + silent probe: registers and warns | integration | `with_local_probe_fail_registers_and_warns` | Wave 0 |
| LOCAL-05 | block byte-identical, content pins, placement | unit + mutation | `python3 -I tests/test_check_order.py` | Wave 0 |
| LOCAL-06 | docs present local-first with the two reasons | gate | `sh tests/test_install_pages.sh` (new `need` phrases + README check) | exists (edit) |
| LOCAL-07 | tests cover flag, probe, failure, reruns, lone marker; fake has `tools/list` | meta | the gates above plus `sh tests/test_tier2_fake.sh` unchanged-green after `fake_mcp.py` edit | exists (edit) |
| (guard) | curl flags and loopback in the installer | static | `sh tests/test_static_guards.sh` with the curl scan extended to `codex/*.sh` | exists (edit) |

New installer gates to write (20, names are suggestions): `local_block_fresh_with_codex_on_path` (no `mcp add bbj-local` in the codex log), `local_block_fresh_no_codex`, `local_url_fixed_ignores_seam`, `local_rerun_idempotent`, `local_rerun_without_flag_refreshes_in_place` (older shape: table without one tool), `local_rerun_without_flag_skips_probe` (fake log empty), `local_lone_end_marker`, `local_lone_end_marker_without_flag_only_suggests`, `local_foreign_forms` (single-quoted key, other url, dotted key, sub-table: exit 3, config byte-identical, no backup, block printed), `local_hand_registered_same_url`, `local_and_docs_coexist_both_orders`, `local_user_value_kept` (a tool set to `prompt`), `local_check_tools_only_in_local_tables`, `probe_found_suggests`, `probe_no_answer_no_flag`, `probe_no_curl`, `probe_other_server_no_suggestion`, `probe_request_shape`, `probe_refuses_non_loopback_seam`, `with_local_probe_fail_registers_and_warns`, plus `real_codex_parses_bbj_local` (parameterise `real_parse` with a server name) and an extension of `tools_list_single_source` for `LOCAL_TOOLS` vs the Codex page. The probe never changes the exit code (assert `exit 0` with probe silent; `exit 3` unchanged by a foreign docs form).

### Sampling Rate
- **Per task commit:** the quick run command plus the one test file the task touched.
- **Per wave merge:** `sh tests/run.sh`.
- **Phase gate:** `sh tests/run.sh` green with `fail=0`, `sh tests/ci.sh` run where `claude` is installed, the grep-zero command empty, and both mutation checks (layout, pin test) shown to fail.

### Wave 0 Gaps
- [ ] `tests/test_check_order.py` (LOCAL-05)
- [ ] `tests/fake_mcp.py`: `tools-list` and `tools-list-other` modes and `tools/list` dispatch (LOCAL-07)
- [ ] `tests/test_install_codex.sh`: new gates, `start_fake`/`stop_fake`, `lsum`, parameterised `real_parse` (LOCAL-02..04, 07)
- [ ] `tests/test_layout.py`: three small gates (VEND-01..03)
- [ ] `tests/test_install_pages.sh`: phrases for both pages and README (LOCAL-06)
- [ ] `tests/test_static_guards.sh`: curl scan applied to `codex/*.sh`

## Security Domain

`security_enforcement` is enabled (absent = on; config sets ASVS level 1, block on high).

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | none (no accounts; loopback server) |
| V3 Session Management | no | stateless HTTP calls |
| V4 Access Control | yes | Auto-approve only three named tools on the fixed loopback URL; never server-wide approval |
| V5 Input Validation | yes | Validate the probe URL (loopback allow-list, no whitespace, userinfo, query, fragment, backslash) with the hook's `case`/`sed`; validate options before the first write; keep file content out of commands |
| V6 Cryptography | no | none; http to loopback only, nothing to encrypt |
| V9 Communications | yes | `--proto =http`, `--noproxy '*'`, no redirects, timeouts 2 s/3 s, loopback only |
| V14 Configuration | yes | One-time backup, in-place rewrite preserving symlinks and modes, refuse to touch forms the installer did not write |

### Known Threat Patterns for POSIX sh installer + local MCP registration
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Auto-approval of tools on a non-local `bbj-local` URL sends code off the machine without a prompt | Information disclosure | Edit only a table whose `url` equals the fixed loopback URL; otherwise foreign, exit 3 |
| Seam variable pointing the probe at a remote host | Information disclosure / SSRF | Loopback-only validation; refused URLs never reach curl |
| Proxy environment variables route loopback traffic away | Information disclosure | `--noproxy '*'`, `-q` (ignore `.curlrc`), `--proto =http` |
| Probe sends user code | Information disclosure | Static request body; test asserts no `code`/`arguments` field |
| Hostile or pre-existing `config.toml` (quoted keys, sub-tables, dotted keys) | Tampering | Foreign-form detection, byte-identical config, exit 3 |
| Partial block leaves tool tables without a parent (Codex then refuses to load the whole config) | Denial of service | Table always written first; same awk path that already guards `bbj-docs` |
| Probe or installer hangs | Denial of service | `--connect-timeout 2 -m 3`; probe result never changes control flow beyond a message |

## Plan decomposition (waves and file ownership)

| Plan | Wave | Requirements | Owns (no other plan edits these) | Depends on |
|------|------|--------------|----------------------------------|-----------|
| 01-01 Stop vendoring: code, manifests, wording | 1 | VEND-01, VEND-02, VEND-03 | delete `skills.lock.json`, `tests/test_skills_hash.py`; edit `tests/test_layout.py`, `tests/run.sh` (comment), `tests/ci.sh` (comment), `NOTICE`, `plugins/bbj/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`; README line 5 + Skills section and `docs/install-claude-code.md` line 70 (only these lines; the docs plan edits the rest later) | none |
| 01-02 Installer refactor (no behaviour change) | 1 | LOCAL-01 | `codex/install-codex.sh` | none |
| 01-03 Instruction and map cleanup | 1 | VEND-01 (D-16) | `.claude/CLAUDE.md`, `.planning/codebase/*.md` | none |
| 01-04 Check-order block and pin test | 2 | LOCAL-05 | `codex/AGENTS-snippet.md`, both `SKILL.md`, new `tests/test_check_order.py` | 01-01 (hash test must be gone) |
| 01-05 `--with-local`, probe, fake server, installer tests | 2 | LOCAL-02, 03, 04, 07 | `codex/install-codex.sh`, `tests/fake_mcp.py`, `tests/test_install_codex.sh`, `tests/test_static_guards.sh` | 01-02 |
| 01-06 Docs: local-first framing | 3 | LOCAL-06 (and the rest of VEND-02 wording) | `README.md`, `docs/install-claude-code.md`, `docs/install-codex.md`, `tests/test_install_pages.sh` | 01-01, 01-04, 01-05 |

Conflict notes: `README.md` and `docs/install-claude-code.md` are touched by both VEND-02 (wave 1, one line each plus the README section) and LOCAL-06 (wave 3); the sequential dependency avoids parallel edits. `codex/install-codex.sh` is touched by 01-02 then 01-05 (sequential). `tests/test_install_codex.sh` is touched only by 01-05; `tests/test_install_pages.sh` only by 01-06, which can also extend the `LOCAL_TOOLS` cross-check by asking 01-05 to export the constant name. 01-04 and 01-05 are independent (snippet versus installer): the installer prints the snippet but no test asserts snippet content beyond `snippet_shape`, `first_prints_snippet_and_trust` and `tools_list_single_source`, which hold for the block as drafted. Merge 01-03 into 01-01 if the planner prefers fewer plans; they are separate here because the files are disjoint and the maps are documentation.

## Project Constraints (from CLAUDE.md)

Extracted from `.claude/CLAUDE.md` (project instructions) that bind this phase:
- POSIX `sh` + Python 3 stdlib only for scripts and tests; no new runtime dependency.
- BBj code is never executed (`tests/test_never_execute.sh`); the hook never calls the hosted check; every compiler call carries `-N`.
- `bbj-local` stays opt-in in both Claude Code and Codex (a registered but stopped server shows as failed on every start).
- Skill and plugin names unchanged (`bbj-programming`, `bbj-web-programming`, `bbj`, `bbj-local`).
- Shell conventions: shebang `#!/bin/sh`, two-space indent, `[ ... ]` not `[[ ]]`, `$(...)`, `printf` for user data, `command -v x > /dev/null 2>&1`, no `set -e` in shipped scripts, redirection spacing `> "$f" 2> "$g"`, underscore-prefixed function-local names, no `local`.
- Installer conventions: documented exit codes 0/2/3 in the script header; validate every option and destination before the first write; one-time `config.toml.bbj-backup`; never overwrite a file the user owns.
- Python tests: stdlib only, `python3 -I`, `gate <prefix>_<name> ok|FAIL <detail>`, 4-space indent, double-quoted strings, `%`-formatting (no f-strings), module docstring that states what it locks, optional `argv[1]` root, forbidden words assembled from pieces.
- Every script and test opens with a block comment naming plan and decision IDs (for example `plan 01-05, LOCAL-02; decisions D-09 and D-11`) and what it never does.
- Conventional commits with scope, for example `feat(01-05): ...`, `test(01-04): ...`, `docs(01-06): ...`.
- `README.md`, install pages hold install steps; scripts' comments do not.
- GSD enforcement: file edits happen through a GSD workflow command (executor plans), not ad hoc.

## Sources

### Primary (HIGH confidence)
- Repository files read in full this session: `codex/install-codex.sh`, `codex/AGENTS-snippet.md`, `plugins/bbj/scripts/bbj-check.sh` (lines 1-140), `tests/test_layout.py`, `tests/lib.sh`, `tests/fake_mcp.py`, `tests/fake-bin/{curl,codex}`, `tests/test_install_codex.sh`, `tests/test_install_pages.sh`, `tests/test_static_guards.sh`, `tests/test_never_execute.sh`, `tests/test_tier2_fake.sh`, `tests/test_tier2_live.sh`, `tests/test_skills_hash.py`, `tests/run.sh`, `tests/ci.sh`, `tests/test_ci_gates.sh` (head), `docs/install-claude-code.md`, `docs/install-codex.md`, `README.md`, `NOTICE`, `CHANGELOG.md`, both manifests, `plugins/bbj-local/.mcp.json`, `.shellcheckrc`, both SKILL.md heads.
- Live checks this session: `tools/list` POST to the running `bbj-ls` (full reply, header requirement, closed port, non-MCP server); `codex mcp get/remove bbj-local` in a temp `CODEX_HOME` (Codex 0.156.1); `bbjcpl -t -N -X` stderr/stdout/exit behaviour on BBj 26.03; `claude plugin validate --strict` on a scratch copy with the block before the H1; the baseline suite `SUMMARY: ok=365 fail=0 skip=2`; the parameterised `analyze` prototype under mawk.

### Secondary (MEDIUM confidence)
- `.planning/research/STACK.md`, `ARCHITECTURE.md`, `PITFALLS.md`, `SUMMARY.md` (project-level research; its Claude-server-key statement is corrected above). No external documentation was fetched in this session; claims about `bbjcpl -t` type checking and `bbj-ls` being parse-only rest on those files' reproductions.

### Tertiary (LOW confidence)
- None used for recommendations.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new dependency; every tool probed this session.
- Architecture (installer parameterisation, decision table): HIGH for the shape (prototype ran, existing flows traced); MEDIUM for the exact message wording and the D-12 reading, flagged as Open Question 1.
- Pitfalls: HIGH - each cites the test or guard line it comes from, or a live observation.

**Research date:** 2026-10-09
**Valid until:** 2026-11-08 (stable; re-check the `bbj-ls` request shape if BBjServices is upgraded past 26.03)
