# Stack Research

**Domain:** Coding-agent plugin repository (Claude Code marketplace plus OpenAI Codex installer) shipping BBj skills, MCP registrations and a compile-check hook. Milestone 0.2.0, POSIX `sh` + Python 3 stdlib only.
**Researched:** 2026-10-09
**Confidence:** HIGH for everything marked "observed" (reproduced on this machine against the running `bbj-ls`, Codex CLI 0.156.1, Claude Code 2.1.295, `/opt/bbx/bin/bbjcpl`, BBj 26.03). MEDIUM for official-docs-only claims. The repo's `classify-confidence` seam rates `WebFetch` as LOW even when verified, so a claim is upgraded here only where it was also reproduced locally.

Nothing new is added to the runtime. Every recommendation below is a format, a wire shape, a convention or a stdlib module.

## Verdicts

1. **Codex `--with-local`**: write one atomic managed block (url table, then three per-tool `approval_mode = "approve"` tables). Probe with one `tools/list` POST over `curl`. Write nothing unless the flag is given.
2. **Block gate**: a single self-contained `tests/test_skill_blocks.py` using `http.client` (not `curl`, not `urllib`), one batched `bbjcpl -t -N -X` call, and a rustdoc-style info-string vocabulary: `bbj`, `bbj should-fail`, `bbj nocheck (reason)`.
3. **Skills format**: portable frontmatter subset (`name`, `description` only). **Description at most 1,024 characters**: both skills break this today, and Codex silently truncates the second one.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| MCP Streamable HTTP, stateless revision | spec `2026-07-28` (current per modelcontextprotocol.io/specification/versioning) | Wire protocol to `bbj-ls` for the gate and the installer probe | `bbj-ls` speaks it (observed: no `Mcp-Session-Id`, `server/discover` lists `2026-07-28, 2025-11-25, 2025-06-18, 2025-03-26`). The hook already uses this exact shape, so the repo keeps one verified wire shape. One POST per call, no handshake, no session state. |
| `bbjcpl -t -N -X` | BBj 26.03 | Strict local check (syntax plus static type check) | Documented at documentation.basis.cloud `util/bbjcpl_bbj_compiler.htm`: `-N` writes no output files, `-X` keeps the input extension, `-t` type-checks, and the three combined are the documented type-check-only form. Stricter than `bbj-ls` (see Check routes). |
| `bbj-ls` `bbj_check_syntax` | BBj 26.03, server `bbj-ls` v1 | Primary check named in the core value; parse-level | Observed: returns `structuredContent.diagnostics[]` (`line, column, endLine, endColumn, severity, category, message`), about 8 ms per call. |
| Codex `config.toml` MCP tables | Codex CLI 0.156.1 | Register `bbj-local` and approve its three tools | `[mcp_servers.<name>]` plus `[mcp_servers.<name>.tools.<tool>]` with `approval_mode`. Observed: Codex accepts `auto`, `prompt`, `writes`, `approve` and refuses to start on anything else. |
| Agent Skills format (agentskills.io) | spec as fetched 2026-10-09 | Skill layout shared by Claude Code and Codex | Both clients read `SKILL.md` with `name` and `description`; `references/`, `scripts/`, `assets/` are conventions. |
| CommonMark fenced code blocks | 0.31.2 | Extraction grammar for skill examples | The info string after the fence is free-form past the first word, so attributes after `bbj` are spec-legal and GitHub still highlights by first word. |
| Python 3 stdlib | 3.12 on CI (`ubuntu-24.04`), 3.14.4 here | Extractor, gate, TOML assertions | `http.client`, `json`, `re`, `subprocess`, `tempfile`, `os`, `tomllib` (3.11+). No `pip`, no YAML parser. |

### Supporting Libraries (all stdlib)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `http.client.HTTPConnection("127.0.0.1", 5009)` | stdlib | JSON-RPC POST to `bbj-ls` | The gate. It never reads proxy environment variables and never follows redirects, so loopback-only and no-redirect hold by construction. |
| `json` | stdlib | Request body, reply parsing | Replaces the hook's sed/awk JSON escaper for every case where Python is available (tests). |
| `re` | stdlib | Fence scanner, `bbjcpl` output parser, frontmatter lint | Fence scanner is about 25 lines (prototype ran on all 14 files). |
| `subprocess` | stdlib | One batched `bbjcpl` call | Always a list argv, `stdin=subprocess.DEVNULL`, `timeout=`, never `shell=True`. |
| `tempfile.TemporaryDirectory` | stdlib | Private dir for block files | Block files never go next to sources. After the run, assert the directory holds only the inputs (guards the "drops an extensionless binary" quirk). |
| `tomllib` | stdlib 3.11+ | Assert the installer's `config.toml` output structurally | New in `tests/test_install_codex.sh` via a small `python3 -I` helper. Skip the gate on Python < 3.11. Parsing beats grep for "three tool tables, each `approve`, nothing else approved". |
| `curl` | system (8.18.0 here) | Installer probe and hook | Only in `sh`. Flags are fixed by the static guard: `-q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 3`, never `-L`. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `claude plugin validate --strict` (2.1.293 pinned in CI, 2.1.295 local) | Manifest validation | Observed: does NOT check skill description length (a 1,575-character description passes). The repo test must. |
| `codex mcp get/list/remove` (0.156.1) | Optional real-Codex gate for the new block | Extend the existing `real_codex_parses_configs` gate to `bbj-local`. `codex debug prompt-input "x"` (HOME and CODEX_HOME in a temp dir) renders the model-visible skill list without calling a model: use it to prove both skills are listed and see truncation. |
| ShellCheck (`.shellcheckrc`, `sh` dialect) | Lint installer changes | Existing. The probe code must pass it. |

## Workstream A: Codex `--with-local`

### Config shape to write (observed to parse on Codex 0.156.1)

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

Prescriptions, with reasons:

- **One atomic append, not `codex mcp add` plus edits.** `codex mcp add bbj-local --url ...` writes only `[mcp_servers.bbj-local]` and `url` (observed). It cannot set `approval_mode`, so the two-step flow leaves a window where the server is registered without approvals. A single block is also easier to make idempotent. Confidence MEDIUM: this is a design call, the existing `bbj-docs` path uses `codex mcp add` first.
- **Distinct markers from the `bbj-docs` block.** The existing awk treats `MARK_END` as the end of the `bbj-docs` table body. Reusing the same marker text for a second block invites the editor to cut at the wrong place.
- **Per-tool tables, not `default_tools_approval_mode`.** `bbj-ls` publishes no tool annotations (observed: `annotations` absent on all three tools), so `writes` would not auto-approve them. The server-wide `approve` is the line (398aac5) the installer already removes from `bbj-docs`; do not reintroduce it.
- **Tool tables must never exist without the parent table.** Observed: `[mcp_servers.bbj-local.tools.x]` alone makes Codex abort with `failed to load bootstrap configuration ... invalid transport in mcp_servers.bbj-local`. A bad `approval_mode` value fails the same way. A config error does not disable one server, it stops Codex. Hence: write the whole block in one append, validate the spelling of the values in a test, never write a partial block.
- **Do not set** `required = true` (a stopped server would abort startup), `enabled = false` (defeats the opt-in) or `startup_timeout_sec` (a refused loopback connection fails fast; the default 10 s is irrelevant).
- **Uninstall is `codex mcp remove bbj-local`** (observed: removes the table and its tool subtables) but it leaves the end-marker comment behind. The installer must treat a lone marker as "no block" and not loop or duplicate. Document the command in `docs/install-codex.md`.
- **Existing `bbj-local` content in a form the installer does not edit** (single-quoted key, dotted keys, sub-table elsewhere): same policy as `bbj-docs`. Do not modify, print the block to merge by hand, exit 3. The `analyze` awk is hard-wired to `bbj-docs`; parameterise it by server name and tool list, or write a smaller "mentioned anywhere outside our markers" check for `bbj-local`. Do not copy the 150-line function.

### Install-time probe

One request that proves the identity and the capability being registered, and sends no user code:

```sh
body='{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
reply=$(curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 3 -X POST \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/list' --data "$body" --url "$url" 2>/dev/null)
```

Found when `$reply` matches `"name"` `:` `"bbj_check_syntax"` (allow whitespace around the colon). Observed on the live server: rc 0 and all three tool names present; closed port gives curl rc 7 and an empty reply; a non-MCP HTTP server on the port gives rc 0 and a reply without the tool name, so the name match, not the exit code, is the verdict.

- Reuse the hook's loopback URL validator and the `BBJ_LOCAL_MCP_URL` seam **for the probe only**; the block always writes the fixed `http://127.0.0.1:5009/mcp` (project decision). Tests point the probe at `tests/fake_mcp.py`, which needs a `tools/list` mode (it has none today).
- Without `--with-local`: probe, and when found print one suggestion line, write nothing. With `--with-local`: register even when the probe fails, and say so (BBjServices may start later); the exit code stays 0. Flag this for the planner, it is a decision, not a fact.
- The static guard greps shipped `.sh` files for `curl` calls without `--noproxy`/`--proto =http` and for `-L`. Write the probe to satisfy it even though `codex/install-codex.sh` is checked only for syntax and ShellCheck.
- Observed: `bbj-ls` binds `127.0.0.1:5009` only, rejects a foreign `Origin` with 403, answers GET with 405 (the existing live gate already relies on the 405).

### AGENTS snippet

Name the server and the tool, not a mangled client name: Claude Code shows plugin tools as `mcp__plugin_bbj_bbj-docs__<tool>` (observed), and the Codex form is not verified. Write "`bbj_check_syntax` on the `bbj-local` server when it is registered, on `bbj-docs` otherwise". The Anthropic best-practices guide asks for the `ServerName:tool_name` form for MCP references. Keep the tool bullet list in step with the installer: the test suite already cross-checks `DOCS_TOOLS` against the snippet; add the same check for the three local tools.

## Workstream B: Extracting and checking fenced BBj blocks

### Marking grammar (info string, rustdoc style)

| Fence | Meaning | Gate behaviour |
|-------|---------|----------------|
| ```` ```bbj ```` | Complete, valid example | Must pass every available route. |
| ```` ```bbj should-fail ```` | Deliberately wrong example (the "wrong" half of a right/wrong pair) | Must produce at least one error on at least one available route. This turns "X is a syntax error" into a claim reproduced on a real BBj. A should-fail block that passes is a FAIL. |
| ```` ```bbj nocheck (reason) ```` | Fragment that cannot stand alone | Skipped; the parenthesised reason is mandatory; the gate prints the count. |
| any other whitelisted language | `css`, `html`, `js`, `json`, `bash`, `sh`, `text`, `xml` | Ignored. |

Rules that make it fail closed:

- **Every fence must carry a language**; use `text` for word lists and diagrams (7 of 128 fenced blocks have none today, all word lists or DOM diagrams).
- **Unknown language or attribute is an error**, so `BBj`, `bbx`, `basic`, `bbj-fragment` or a typo cannot silently escape the gate.
- **Unclosed fences, and fences inside blockquotes, are errors** (CommonMark runs an unclosed fence to end of file; a naive scanner would swallow prose).
- Prefer making a fragment complete (wrap it in a minimal class or program) over `nocheck`. Both `bbj-ls` (`ClassError`) and `bbjcpl` reject a `method`/`methodend` outside a class (observed).
- Why not an HTML comment marker (`<!-- bbj-check: skip -->`): it detaches from the block, drifts when blocks move, and the agent reads the raw text anyway. The info string travels with the block and tells the agent what the block is. Prior art: rustdoc `ignore (reason)`, `compile_fail`, `no_run`; mdBook and pytest-markdown-docs use the same shape.

### Extractor

CommonMark fence rules in about 25 lines of `re`: opening fence up to 3 spaces indent, 3+ backticks or tildes, backtick info strings may not contain a backtick; closing fence same character, at least as long, up to 3 spaces, nothing after; strip up to the opening indent from content lines; unclosed runs to end of file. Normalise CRLF (`.gitattributes` already forces LF). Record `fence_line` so diagnostics map to `file:fence_line + N`.

Constraint that bites: `tests/run.sh` runs Python as `python3 -I`, which removes the script directory from `sys.path`. A helper module next to the test will not import. Keep extractor and gate in **one file** (`tests/test_skill_blocks.py`), or load helpers via `importlib.util.spec_from_file_location`.

### Check routes (observed)

**`bbj-ls` via `http.client`**

```
POST /mcp  Host 127.0.0.1:5009
Content-Type: application/json
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: bbj_check_syntax
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"bbj_check_syntax",
 "arguments":{"code":"<block>"},
 "_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}
```

- Verdict from `result.structuredContent.diagnostics` (empty list = clean). Observed categories: `SyntaxError`, `ClassError`, `UndefinedLabelError`. Fall back to parsing `content[0].text` lines `line N, column M: [Category] message` (what the hook does) only if `structuredContent` is absent.
- **Fail closed on infrastructure**: HTTP status other than 200, a JSON-RPC `error`, `isError: true`, a reply that is not JSON. These are gate failures (or a skip when the server is simply not there), never "clean".
- Missing `MCP-Protocol-Version` gives HTTP 400 with `-32020` (observed). Also handle an SSE reply (take the last `data:` line) because the spec requires clients to support both; this server answers `application/json`.
- The same server accepts `MCP-Protocol-Version: 2025-06-18` with no `_meta` (observed). Do not build a fallback ladder; use `server/discover` only if a future server answers `UnsupportedProtocolVersionError`.
- Send LF-normalised text. Observed: CRLF, non-ASCII text and empty input are fine.

**`bbjcpl -t -N -X`, one batched call**

- Write each block to `b000.bbj, b001.bbj, ...` in a private temp dir and call `bbjcpl -t -N -X <all files>` once. Observed: 93 blocks take **1.5 s batched versus 74 s one process per block** (JVM start dominates). Output lines are prefixed by file name, so attribution is exact.
- Exit code is always 0 (hook comment, confirmed); the verdict is the output. Errors may arrive on stderr; capture both.
- Line forms observed: `X.bbj: error at line 20 (2): <src>`, `X.bbj: error: label NAME used but not defined at line 40 (4): <src>`, `X.bbj: type check error [<msg>] at line 50 (5): <src>`. The number in parentheses is the source line; the first number is internal (x10). Parse with one regex anchored on `at line \d+ \((\d+)\):`.
- **Fail closed on unparsed output**: any non-empty line that does not match is a failure, not a skip.
- **Demote `Cannot find program` lines exactly as the hook does (D-11)**: a `use ::file.bbj::Class` for a file that is not on disk is not an error of the example. Observed: 10 such lines in `form-validation.md`, which `bbj-ls` passes.
- Locate the compiler in the hook's order: `BBJ_HOME`, `BBJHOME`, `PATH`, then `/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx`; `os.path.realpath` it (the launcher finds its home from its own path, so a symlink breaks). Reuse the existing test seam `BBJ_TEST_HOME`.
- Never-execute invariant: build the argument list from one constant `("-t", "-N", "-X")`, and add a static test that no `tests/*.py` calls `bbjcpl` without `-N`, matching what the shell static guard does for `.sh` files.

**Run both routes when both are present.** `bbj-ls` is the gate named in the core value; `bbjcpl` is the route the skills tell agents to use first, so an example that `bbjcpl -t` rejects teaches the agent something its own tool rejects. The routes disagree in one direction only (observed, 93 blocks): `bbjcpl -t` flagged 18 blocks that `bbj-ls` passed; `bbj-ls` flagged nothing `bbjcpl` passed. The extra findings are real, for example `No type named HashMap visible in this scope` (missing `use java.util.HashMap`), `#THIS! reference does not have an enclosing class`, `Could not find class: java.util.NoSuchThing`. Both routes pass an unclosed `if` and calls to undeclared methods on untyped values (observed), so a green check never proves an API claim: the "URL cited or reproduced" rule still carries that weight.

### Gate structure

| Gate | Runs | Result when absent |
|------|------|--------------------|
| `fences_wellformed` (language present, vocabulary valid, reasons present, no unclosed fence), `blocks_extracted` (counts per file and per kind) | everywhere, including CI | never skipped |
| `route_bbj_ls` | when `127.0.0.1:5009` answers | `skip`; `FAIL` under `BBJ_LS_LIVE=1` (same convention as `tests/test_tier2_live.sh`) |
| `route_bbjcpl` | when `bbjcpl` is found | `skip` |

Print every failure as `relative/path.md:LINE: message`, where LINE is `fence_line + N`. One gate line per skill file keeps output readable. Detection is automatic; `CI=true` must not turn a missing BBj into a failure.

### Baseline for the makeover (observed 2026-10-09)

93 `bbj` blocks across 14 files. 51 fail on `bbj-ls` (72 `SyntaxError`, 35 `ClassError`, 2 `UndefinedLabelError` diagnostics), 50 fail on `bbjcpl`. Most are trailing `REM` without `;`, a bare call, or a `method` outside a class. Every one of the 51 failing blocks needs a decision: rewrite into a complete valid unit, `should-fail` (the block is the wrong half of a pair), or `nocheck (reason)`. Blocks that use `err=label` without defining the label fail on both routes (`UndefinedLabelError`): define the label in the example. Total cost of the live gate: under 3 s.

## Workstream C: Skill and plugin format (as fetched 2026-10-09)

### Portable rules (apply to both Claude Code and Codex)

| Rule | Value | Source and status |
|------|-------|-------------------|
| Frontmatter | `name` and `description` only; no `when_to_use`, `argument-hint`, `paths`, `allowed-tools`, `agents/openai.yaml` | Claude Code ignores unknown fields; the agentskills spec and Codex read only `name`/`description` (+ optional). Fewer client-specific keys, fewer surprises. HIGH. |
| `name` | equals directory name, `[a-z0-9-]`, at most 64, no `--`, no leading or trailing `-`, no `anthropic`/`claude` | agentskills spec; Anthropic best practices. Names stay `bbj-programming`, `bbj-web-programming`: observed `/bbj:bbj-programming` and `/bbj:bbj-web-programming` on 2.1.295. HIGH. |
| `description` | **at most 1,024 characters, no XML tags, third person, what plus when, key use case and trigger words first** | agentskills spec, Anthropic best practices. Codex's loader has `MAX_DESCRIPTION_LEN = 1024`. Claude Code caps `description` plus `when_to_use` at 1,536 in the listing. Observed on Codex 0.156.1: `bbj-web-programming` (about 1,575 characters) is listed but cut to about 1,000 characters with an ellipsis, losing "Also trigger on symptoms without BBj being named...". `bbj-programming` (about 906) is intact. HIGH. |
| SKILL.md body | under 500 lines, instructions that must survive compaction near the top | Claude Code docs: after compaction only the start of an invoked skill is kept. Put the check order and "Built in: no USE needed" in the first screen. Current sizes 464 and 370 lines are inside the limit. |
| References | one level deep from `SKILL.md`, descriptive file names, forward slashes, table of contents on files over 100 lines | Anthropic best practices. Today 7 of 12 reference files exceed 100 lines and none has a contents list; all links are already one level. |
| Frontmatter syntax | one-line `key: "double-quoted"` scalars, no `"` or `\` inside | A malformed frontmatter makes Claude Code load the body with empty metadata (skill still invocable, never auto-matched). With no YAML parser in stdlib the repo test must parse this restricted form itself. |
| Terminology, time-sensitivity | one term per concept; version-dependent facts carry "reproduced on BBj 26.03" | Anthropic best practices ("avoid time-sensitive information"). Fits the makeover rule of verified-only claims. |

### Where each client looks

- **Claude Code**: `<plugin>/skills/<name>/SKILL.md`, namespaced `/plugin:skill` (observed). `${CLAUDE_SKILL_DIR}` is substituted in the skill body if a skill ever needs to point at a bundled script; `references/` is only a convention.
- **Codex 0.156.1**: user `~/.agents/skills`, repository `.agents/skills` from the working directory up to the repo root, admin `/etc/codex/skills`; symlinked skill folders are followed. Loader limits (source): name 64, description 1,024, scan depth 6, 2,000 directories per root. The initial list is capped at 2% of the context window (8,000 characters when unknown), shortening descriptions first. The installer's `~/.agents/skills` target is correct; the Codex docs do not mention `$CODEX_HOME`.

### Repo tests to add (stdlib)

- Frontmatter lint for every `SKILL.md`: restricted-syntax parse, `name` equals directory, `len(description) <= 1024` counting characters (Codex counts `chars().count()`), no `<tag>`, body lines under 500.
- Reference-file lint: every `references/*.md` is linked from its `SKILL.md`, none links to another reference, files over 100 lines contain a contents heading.
- Keep these as gates in the same file family as the block gate; `claude plugin validate --strict` stays in CI for manifests but cannot replace them.

## Installation

```bash
# No packages to install. The runtime and test stack stays POSIX sh + Python 3 stdlib.

# Gate, extraction and lint only (what CI can do):
python3 -I tests/test_skill_blocks.py

# Gate with live routes (local machine with BBjServices and/or bbjcpl):
BBJ_LS_LIVE=1 python3 -I tests/test_skill_blocks.py

# Whole suite (existing):
sh tests/run.sh

# Optional real-Codex check of the new block (temp homes only, never a session):
BBJ_TEST_CODEX=$(command -v codex) sh tests/test_install_codex.sh
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `http.client` in Python for the gate | `curl` from `sh` | The hook and the installer probe, where Python is not guaranteed. The hook's sed/awk JSON escaper exists only because `sh` has no JSON encoder; it is fragile with unicode and long blocks. |
| `http.client` | `urllib.request` | Only with `ProxyHandler({})`; otherwise it honours `http_proxy` and can route loopback traffic away. `http.client` has no such failure mode. |
| Info-string attributes (`bbj should-fail`) | HTML comment before the fence | A renderer that rejects unknown info strings. None of the targets does (GitHub, Claude Code, Codex all treat the first word as the language). |
| Info-string attributes | Separate language tags (`bbj-fragment`) | Never: GitHub loses highlighting and the lint cannot tell a typo from a tag. |
| Batched `bbjcpl` call | One process per block | Debugging a single block. 74 s versus 1.5 s on the current corpus. |
| One atomic managed block for `bbj-local` | `codex mcp add` plus appended tool tables (what `bbj-docs` does) | If the team wants one code path for both servers; costs a window with the server registered but not approved. |
| Per-tool `approve` tables | `default_tools_approval_mode = "writes"` | If `bbj-ls` ever publishes `readOnlyHint` annotations; it does not today (observed), so `writes` would still prompt. |
| `tools/list` probe | GET returning 405 (the live-test convention) | Test code, where "something answers on the port" is enough. For the installer, 405 does not identify `bbj-ls`. |
| Fixed loopback URL | `user_config` URL option | Revisit only on demand (project decision, out of scope for 0.2.0). |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `default_tools_approval_mode = "approve"` on `bbj-local` | Server-wide approval; it is the line the installer already removes from `bbj-docs`, and it would also approve any tool a later `bbj-ls` adds | Three explicit tool tables |
| `required = true`, `enabled = false` on the Codex block | `required` aborts Codex start when BBjServices is down; `enabled = false` makes the opt-in a no-op | Defaults |
| Writing tool tables before or without `[mcp_servers.bbj-local]` | Codex fails to load its whole configuration (observed) | One block, parent table first |
| Any `approval_mode` other than `auto`, `prompt`, `writes`, `approve` | Same hard failure (observed); the public docs do not list the values, the binary does | `approve` |
| `urllib.request` without `ProxyHandler({})`, `requests`, `httpx`, `pytest`, `PyYAML`, `markdown-it-py`, `mistune` | New runtime or test dependencies; the project constraint is stdlib only | `http.client`, `re`, a 25-line fence scanner |
| `bbjcpl` without `-N`, or a block file written next to a source file | Drops a compiled binary; `-N` is the repo's never-execute proof | `-t -N -X` in a `TemporaryDirectory` |
| Running BBj (`bbj`) to "verify" a block | Executes code; forbidden by `tests/test_never_execute.sh` | The two check routes only |
| `paths:` frontmatter on the skills | Claude-only, and it would stop auto-activation on the symptom triggers (a `bbj` command that hangs) that have no `.bbj` file open | Description triggers |
| Skill descriptions over 1,024 characters, or `when_to_use` to carry overflow | Codex truncates; `when_to_use` is Claude-only and counts toward the 1,536 cap | Shorter `description`, triggers first |
| Mangled MCP tool names in skill text (`mcp__plugin_bbj_...`) | Differ per client and per registration | `bbj_check_syntax` plus the server name |
| Treating `bbj-ls` as a type checker | It parses only (observed: passes unknown Java classes, undeclared methods) | `bbjcpl -t` for type checks; docs tools for API facts |

## Stack Patterns by Variant

**If only `bbj-ls` is reachable (no `bbjcpl`):**
- Run the `bbj-ls` route; report "type check not run" in the gate summary.
- Because the hook's tier 2 is also parse-only and says so in its header (`bbj-local reported N error(s)`).

**If only `bbjcpl` is present:**
- Run the batched call; skip the live route.
- Because the strict route already covers everything `bbj-ls` flags (observed).

**If neither is present (CI, most contributor machines):**
- Run extraction and lint only; both route gates print `skip`.
- Because the project decision is a local-only syntax gate.

**If the installer runs without `codex` on PATH:**
- The managed block needs no `codex` call at all. That is the strongest argument for the atomic block.

**If `config.toml` already names `bbj-local` outside the markers:**
- Leave it, print the block, exit 3. Never emit a second table with the same key (invalid TOML).

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `bbj-ls` (BBjServices 26.03+) | MCP `2026-07-28`, `2025-11-25`, `2025-06-18`, `2025-03-26` | Observed via `server/discover`. Stateless: no initialize needed before `tools/call`. |
| Codex CLI 0.156.1 | `[mcp_servers.<id>]`, `...tools.<tool>.approval_mode` in `auto/prompt/writes/approve` | `codex mcp add --url` writes the parent table only. Old versions are untested; the installer header says "Verified on Linux with Codex CLI 0.156.1". |
| Claude Code 2.1.295 (CI pin 2.1.293) | Skills with `name` and `description`; `bbj-local` `defaultEnabled: false`; `claude plugin validate --strict` checks `.mcp.json` entries from v2.1.281 | The validator warns on `http://` to a non-loopback host; `127.0.0.1` is clean. |
| Python 3.11+ | `tomllib` | CI's Python 3.12 qualifies; skip, do not fail, on older interpreters. |
| `python3 -I` | Single-file tests only | Isolated mode drops the script directory from `sys.path`. |
| `bbjcpl` 26.03 | `-t -N -X` plus many files in one call | Observed. Exit status is always 0; the output is the verdict. |

## Open Decisions for the Roadmap

- **Probe failure with `--with-local`**: register and warn (recommended) or refuse. Decision, not fact.
- **Run both routes or `bbj-ls` only** in the gate: recommended both, because the skills tell agents to use `bbjcpl` first.
- **Budget for `nocheck`**: report the count in the gate; consider failing above a fixed number once the makeover is done.
- **Codex native plugin format**: `codex plugin add` and `codex plugin marketplace` exist in 0.156.1 (observed in `--help`). Third-party sources describe `.codex-plugin/plugin.json` and `.agents/plugins/marketplace.json`, and disagree on whether hooks install; no official page was found. LOW confidence, out of scope for 0.2.0, worth a research spike before the next Codex-facing milestone because it could replace `install-codex.sh`.
- **`tests/test_layout.py` `docs_host_single_source`** exempts the skills directory because it was vendored. After the makeover, decide whether the hosted URL may appear in skills (the "check order" text names the hosted route) and update the exemption deliberately.
- **`tests/fake_mcp.py`** needs a `tools/list` mode for the installer-probe tests.

## Sources

- Observed on this machine, 2026-10-09 (HIGH): `bbj-ls` on `127.0.0.1:5009` (initialize, `server/discover`, `tools/list`, `tools/call bbj_check_syntax`, error and header behaviour, Origin 403, GET 405); `/opt/bbx/bin/bbjcpl -t -N -X` single and batched; Codex 0.156.1 (`mcp add/get/list/remove`, config validation errors, `debug prompt-input` skill listing); Claude Code 2.1.295 (`plugin validate --strict`, stream-json init listing of skills and MCP tool names).
- https://modelcontextprotocol.io/specification/versioning and https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http - current revision, required headers, `-32020`, stateless shape (MEDIUM; matches observed behaviour).
- https://code.claude.com/docs/en/skills and https://code.claude.com/docs/en/plugins-reference - SKILL.md fields, 1,536 cap, 500-line guidance, namespacing, `${CLAUDE_SKILL_DIR}`, plugin manifest and `claude plugin validate` (MEDIUM).
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices - description voice, one-level references, contents lists over 100 lines, MCP `ServerName:tool_name` (MEDIUM).
- https://agentskills.io/specification - `name`/`description` constraints, directory conventions, `skills-ref validate` (MEDIUM).
- https://learn.chatgpt.com/docs/extend/mcp?surface=cli and https://learn.chatgpt.com/docs/build-skills (reached through 308 redirects from developers.openai.com/codex/mcp and /codex/skills) - Codex MCP keys, `default_tools_approval_mode`, discovery paths, 2% listing budget (MEDIUM; the docs omit the per-tool `approval_mode` values, which Codex's own error message supplies).
- https://github.com/openai/codex, `codex-rs/ext/skills/src/loader/mod.rs` and `metadata.rs` - `MAX_NAME_LEN = 64`, `MAX_DESCRIPTION_LEN = 1024`, `MAX_SCAN_DEPTH = 6`, `validate_len` (HIGH for the constants; observed behaviour is truncation, not rejection).
- https://documentation.basis.cloud/BASISHelp/WebHelp/util/bbjcpl_bbj_compiler.htm - `-N`, `-X`, `-t`, `-P`, `-c` (MEDIUM, via search summary; flags also exercised locally).
- https://spec.commonmark.org/0.31.2/#info-string - fenced block info string and closing-fence rules (MEDIUM).
- https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html - `ignore (reason)`, `no_run`, `should_panic`, `compile_fail` attribute precedent (MEDIUM).
- Third-party Codex plugin format descriptions (codex.danielvaughan.com and others, via search) - LOW, used only to flag the open decision above.

---
*Stack research for: BBj agent plugins 0.2.0 (local check route, skill block gate, skill format)*
*Researched: 2026-10-09*
