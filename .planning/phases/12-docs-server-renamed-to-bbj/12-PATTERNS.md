# Phase 12: Docs server renamed to bbj - Pattern Map

**Mapped:** 2026-10-15
**Files analyzed:** 14 edited, 1 new record (`12-LINUX-RUN.md`), 0 new code files (the new gate is a block in `tests/test_layout.py`)
**Analogs found:** 3 / 3 for new code (the rest is rewording)

All paths are git-tracked (checked with `git grep`). Term list source: `git grep -n bbj-docs -- . ':!.planning'`.

## Where `bbj-docs` is today (tracked, outside `.planning/`)

| File | Hits | Lines | Note |
|------|------|-------|------|
| `plugins/bbj/.mcp.json` | 1 | 3 | server key |
| `plugins/bbj/.codex-mcp.json` | 1 | 3 | server key (TOML key is built from it) |
| `plugins/bbj/scripts/bbj-check.sh` | 1 | 227 | no-route notice: "bbj_check_syntax of the hosted docs server bbj-docs ..." |
| `plugins/bbj/skills/bbj-programming/SKILL.md` | 1 | 11 | check-order step 3 |
| `plugins/bbj/skills/bbj-web-programming/SKILL.md` | 1 | 11 | must stay byte-identical to the other |
| `docs/install-codex.md` | 11 | 27, 42, 73, 77, 78, 83, 95, 156, 160, 165, 187 | login command, states, TOML key, check order |
| `docs/install-claude-code.md` | 5 | 86, 87, 96, 97, 102 | tool prefix, `plugin:bbj:bbj-docs` |
| `README.md` | 2 | 5, 34 | `codex mcp login bbj-docs` |
| `.claude/CLAUDE.md` | 4 | 245, 256, 268, 310 | architecture lines |
| `tests/test_layout.py` | 9 | 4, 146, 152, 159, 190, 502, 523, 531, 536 | server-key pins, mutation cases, docstring |
| `tests/test_check_order.py` | 3 | 89, 92, 94 | order positions |
| `tests/test_claude_plugin.sh` | 3 | 7, 92, 109 | `cc mcp get plugin:bbj:bbj-docs` |
| `tests/test_install_pages.sh` | 3 | 17, 208, 227 | `codex mcp login bbj-docs`, TOML key |
| `CHANGELOG.md` | 9 | 28-178 | all in entries <= 0.2.1: leave byte-identical (D-12, Phase 11 D-03) |

## File Classification

| File | Role | Data flow | Closest analog | Match |
|------|------|-----------|----------------|-------|
| `tests/test_layout.py` (new gate `layout_no_old_server_name` + mutation cases) | test (static scan) | batch file scan | its own `no_retired_route` block (lines 60-396) and `layout_mutation_retired_route_*` (560-610) | exact |
| `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` | config | n/a | themselves; pins in `tests/test_layout.py` 146/159/190 | self |
| `plugins/bbj/scripts/bbj-check.sh` line 227 | hook notice | request-response | its own sentence; `notice_` gates in `tests/test_noroute_notice.sh` | self |
| both `SKILL.md` line 11 | skill text | n/a | each other (byte-identical block) | self |
| `tests/test_check_order.py` lines 89-94 | test | file read | itself | self |
| `tests/test_claude_plugin.sh`, `tests/test_install_pages.sh` | test | file read / CLI | themselves | self |
| `docs/*.md`, `README.md`, `.claude/CLAUDE.md` | docs | n/a | Phase 11 rewording of the same files | role |
| `12-LINUX-RUN.md` (owner run record) | record | n/a | `.planning/milestones/v0.2.1-phases/10-LINUX-RUN.md` (see CONTEXT canonical refs) | role |

## Pattern Assignments

### New gate in `tests/test_layout.py` (NAME-01; D-01, D-02, D-03)

**Analog:** the `no_retired_route` block in the same file. Copy it, do not add a term to `RETIRED_TERMS` (D-02).

**Reuse as is:**
- `tracked_files(root)` (line 323): git mode in a checkout, walk mode in a mutation copy (argv[1]); drops `.planning/`.
- `changelog_scan_text(text)` with `HISTORY_CUT = (0, 2, 1)` and `VERSION_HEADING` (lines 77-81, 366-378): integer-tuple cut, fail closed on non-version headings.
- `build_copy` (line 404) already copies every tracked file, so tests and `.claude/CLAUDE.md` are in the copy.

**Core scan to copy** (lines 380-396):
```python
retired_mode, retired_rels = tracked_files(ROOT)
retired_hits = []
retired_scanned = 0
for rel in retired_rels:
    low_rel = rel.lower()
    for term in RETIRED_TERMS:
        if names_retired(term, low_rel):
            retired_hits.append("%s:path:%s" % (rel, term))
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            text = f.read().decode("utf-8", errors="replace")
    except OSError:
        continue
    retired_scanned += 1
    if rel == "CHANGELOG.md":
        text = changelog_scan_text(text)
    low = text.lower()
    ...
gate("no_retired_route", retired_scanned > 0 and not retired_hits, retired_detail)
```
For the new gate: one term `OLD_SERVER_NAME = "bbj" + "-docs"` (assembled from pieces, same convention as `RETIRED_WORD = "install" + "er"` line 60 and `OIDC_PERMISSION = "id" + "-token"` at `tests/test_ci_guards.py:27`), plain substring match on lower-cased text and path (D-03: no `bbj_docs`/`bbjdocs`). No word-boundary regex needed. Keep the `nogit` and `scanned == 0` failure details. Reuse the `tracked_files` result instead of calling it twice if desired.

**Important:** the gate scans `tests/test_layout.py` itself, so the pins at 146/159/190/502-536 must change to `"bbj"` and the docstring on line 4 must drop the old name or build it from pieces. Wording rule D-04: "the docs server `bbj`", never a bare `bbj`.

**Mutation cases** (analog lines 560-610; `mutation_case(name, rels, change, expect)` at 460, `plant(dst, rel, text)` helper used there):
```python
mutation_case("retired_route_readme", ["README.md"],
              lambda dst: plant(dst, "README.md", "Or run sh codex/" + RETIRED_SCRIPT + "."),
              ["no_retired_route"])
mutation_case("retired_route_history_exempt", [CHANGELOG], ..., [])   # control: empty expect
mutation_case("retired_route_planning_exempt", [".planning/notes.md"], ..., [])
```
Add: planted mention in README (fails), in a test file such as `tests/lib.sh` (fails), in `.claude/CLAUDE.md` via the `CLAUDE_MD` constant (fails), capitalised `Bbj-Docs` (fails, case-insensitive), CHANGELOG newer-entry (fails) and 0.2.1-entry (exempt control), `.planning/` (exempt control), a path named with the old name (fails). Expect list uses the new gate name without the `layout_` prefix.

### MCP configs and layout pins

`plugins/bbj/.mcp.json` / `plugins/bbj/.codex-mcp.json`: rename only the server key; URL and OAuth block (client id, port 47613, `offline_access`) unchanged. Pins to update in `tests/test_layout.py`:
```python
servers == {"bbj-docs": {"type": "http", "url": "${user_config.docs_url}", ...   # line 146
codex_servers == {"bbj-docs": {"type": "http", "url": DOCS_DEFAULT, ...         # line 159
codex_servers.get("bbj-docs", {}).get("url") ...                                # line 190
d["mcpServers"]["bbj-docs"]["url"] += "/"                                       # 502; also 523, 531, 536
```
Existing gates touching these: `layout_bbj_mcp`, `layout_codex_mcp` and their `mutation_mcp_scopes_missing`, `mutation_codex_scopes_array` cases (line 560-563). `claude plugin validate --strict` must still pass.

### `plugins/bbj/scripts/bbj-check.sh` line 227 (D-07)

Current: `... bbj_check_syntax of the hosted docs server bbj-docs can check the code; it sends ...`
Change the name only, in the pattern "the hosted docs server bbj". Gates: `notice_*` in `tests/test_noroute_notice.sh` pass with the new text (verify by running it; they match substrings of the notice). The exit contract (`contract_`), `static_` gates and `tests/test_never_execute.sh` are unaffected.

### Both `SKILL.md`, line 11 (D-05)

Current (bbj-programming):
`3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, ...`
New: "`bbj_check_syntax` of the docs server `bbj`, the hosted check" (rest unchanged). Edit both files identically.

### `tests/test_check_order.py` lines 89-94 (D-05)

```python
pos = [block.find(s) for s in ("bbjcpl", "bbj-local", "bbj-docs")]
...
"bbjcpl, bbj-local, bbj-docs in that order, disclosure phrases present"
"missing %s; positions bbjcpl/bbj-local/bbj-docs %s" % (missing, pos))
```
Replace the third needle with the docs-server string (for example "docs server `bbj`"). The needle must not also occur earlier in the block than `bbj-local` (a bare "bbj" would match inside `bbjcpl` and `bbj-local`, so do not use it). Gates: `checkorder_*`; the byte-identical block check between the two SKILL.md files stays.

### `tests/test_claude_plugin.sh` and `tests/test_install_pages.sh`

- `test_claude_plugin.sh:92` `cc mcp get plugin:bbj:bbj-docs`; the label comes from the owner run (D-08/D-09, expected `plugin:bbj:bbj`). Update header comment line 7 and gate detail line 109. Gate `mcp_docs_answers`.
- `test_install_pages.sh:208` `'codex mcp login bbj-docs'` and `:227` `'plugins."bbj@basis-bbj".mcp_servers.bbj-docs'` are required-text lists checked against the install pages (gate prefixes `claude_`, `codex_`, `readme_`); change them in the same commit as the pages. Header line 17.

### Docs (`docs/install-codex.md`, `docs/install-claude-code.md`, `README.md`, `.claude/CLAUDE.md`)

Write only after `12-LINUX-RUN.md` exists (D-09). Pattern: prose "the docs server `bbj`" (D-04), exact labels from the run (D-08): Claude Code `plugin:bbj:bbj` in `/mcp` and `claude mcp list`, prefix `mcp__plugin_bbj_bbj__<tool>` (install page only, D-06), Codex `codex mcp login bbj`, TOML key `plugins."bbj@basis-bbj".mcp_servers.bbj`. No upgrade note, no redo list, no mention of the old name (D-12; the new gate enforces it on all of these files). Release-text gates that read these pages: `tests/test_release_text.py` (`release_`, lines 166-229: required phrases, Codex versions, hint files) and `tests/test_release_text_mutation.sh` (`release_mut_`); re-run them, since their phrase lists may quote sign-in text. `.claude/CLAUDE.md` lines 245/256/268/310 are edited by hand; line 310 currently reads `(`bbj-docs`), `plugins/bbj-local/.mcp.json` (`bbj-ls`)`.

### `12-LINUX-RUN.md`

Model: the 0.2.1 Linux record `10-LINUX-RUN.md` (under `.planning/milestones/v0.2.1-phases/`; it sits in `.planning/` so it is outside the gate). Record: labels shown, login command accepted, built tool prefix, sign-in completed in both clients; throwaway homes, not the real `~/.codex`, not under `/tmp`.

## Gates that touch the old name

| Gate prefix | File | Touch |
|-------------|------|-------|
| `layout_` | `tests/test_layout.py` | pins server key (146/159/190), `bbj_mcp`, `codex_mcp`, mutation cases 502-536; new `layout_no_old_server_name` + `layout_mutation_*` |
| `notice_` | `tests/test_noroute_notice.sh` | hook notice text; no old name in file today, must pass with new sentence |
| `checkorder_` | `tests/test_check_order.py` | needle at 89-94; block byte-identical in both SKILL.md |
| `skills_` | `tests/test_skill_examples.py` | no `bbj-docs` hit; scans skill code blocks only (SKILL.md line 11 is prose); run to confirm |
| `release_`, `release_mut_` | `tests/test_release_text.py`, `tests/test_release_text_mutation.sh` | read README and both install pages; no old name today, phrase lists may need a check |
| `claude_`, `codex_`, `readme_` | `tests/test_install_pages.sh` | required text with the old name (208, 227) |
| free-form `mcp_docs_answers` | `tests/test_claude_plugin.sh` | `claude mcp get plugin:bbj:<server>` |

Pick the new gate prefix so it is not a string prefix of an existing one: `layout_no_old_server_name` is fine (`layout_` is the file prefix, name is unique).

## Shared Patterns

- Self-scan safety: forbidden term assembled from pieces in test code (`tests/test_layout.py:60`, `tests/test_ci_guards.py:27`).
- Gate line grammar: `gate layout_<name> ok|FAIL <detail>`; detail lists offending `rel:term` pairs, sorted.
- Mutation copy: `build_copy` + `mutation_case` run `python3 -I tests/test_layout.py <copy>`; walk mode skips `.planning`, `.git`, `node_modules`.
- Commit order (D-09): configs + pins + gate first, each commit green under `sh tests/run.sh`; docs/skills/notice after the owner run. Commit style `feat(12-NN): ...`, `docs(12-NN): ...`, `test(12-NN): ...`.

## No Analog Found

None for code. `12-LINUX-RUN.md` content depends on the owner run (no label may be guessed before it).

## Metadata

**Analog search scope:** `tests/`, `plugins/`, `docs/`, `README.md`, `.claude/CLAUDE.md`, `.planning/phases/11-installer-removal/11-PATTERNS.md`
**Pattern extraction date:** 2026-10-15
