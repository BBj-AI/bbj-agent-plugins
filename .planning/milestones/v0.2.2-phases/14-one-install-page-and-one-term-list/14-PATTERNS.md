# Phase 14: One install page and one term list - Pattern Map

**Mapped:** 2026-10-16
**Files analyzed:** 14 new/modified (plus about 8 renamed-gate test files)
**Analogs found:** 14 / 14 (all tracked; verified with `git ls-files` for README.md, docs/*, tests/run.sh, tests/test_layout.py)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `docs/install.md` (new; `git rm` both old pages) | docs page | static | `docs/install-claude-code.md` + `docs/install-codex.md` (merged) | exact (source content) |
| `README.md` (short path, Verified cells, term pass) | docs | static | itself (lines 55-64 table) | exact |
| `tests/test_install_pages.sh` (PAGE=docs/install.md) | test | request-response (phrase pins, link resolve) | itself, lines 39-54, 265-292 | exact |
| `tests/test_release_text.py` (HINT_FILES, page reads, new per-cell gate) | test | transform (parse README table) | itself, lines 185-235 (`table_cells`, `PLATFORMS`) | exact |
| `tests/test_release_text_mutation.sh` | test | batch (copy tree, mutate, expect FAIL) | itself, `fresh_root`/`mutate` | exact |
| `tests/test_layout.py` (new term gate + mutation cases; repoint 2 cases at docs/install.md) | test | transform | `layout_no_old_server_name` (lines 520-540) and `old_server_name_*` cases (860-920) | exact |
| `tests/run.sh` (prefix-block gate) | test runner | batch/transform | itself (lines 17-55) | role-match |
| `tests/test_ci_gates.sh` (prefix mutation cases, new SUMMARY counts) | test | batch (fixture tree) | itself, lines 9-52 | exact |
| `tests/test_hook_mutation.sh` (renamed gate names) | test | batch | itself, `control`/`mutant` lines 113-138 | exact |
| 8 test files with free-form gate names (rename to file prefix) | test | n/a | `test_noroute_notice.sh` (`notice_`), `test_path_scrub.sh` (`pathscrub_`) | exact |
| `plugins/bbj/skills/*/SKILL.md` check-order block (prose only) | skill | static | itself, line 7 and 10 | exact |
| `plugins/bbj/.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` (descriptions) | config | static | itself (lines 4, 15) | exact |
| `.claude/CLAUDE.md`, `.planning/codebase/CONVENTIONS.md` (term list, flat prefix block) | docs/config | static | `.claude/CLAUDE.md` lines 175-185 | role-match |
| `tests/fake-bin/cygpath`, `tests/fake_mcp.py`, `.shellcheckrc` (sweep S1-S5), `14-SWEEP.md` | fake/record | n/a | Phase 11 commit `0002b72` removal | role-match |

## Pattern Assignments

### `tests/test_layout.py` new term gate (test, transform)

**Analog:** `layout_no_old_server_name` block, lines 520-540; reuse `tracked_files()` (437-465), `changelog_scan_text()` (467-478), `HISTORY_CUT = (0, 2, 1)` (174).

**Self-scan convention** (lines 150-165): forbidden words assembled from pieces, boundary is "not a letter":
```python
RETIRED_WORD = "install" + "er"
RETIRED_WORD_RE = re.compile(r"(?<![a-z])" + RETIRED_WORD + r"s?(?![a-z])")
OLD_SERVER_NAME = "bbj" + "-docs"
```
New: `TERM_VARIANTS = ("first " + "route", "second " + "route", "docs " + "MCP", "compiler " + "check", "local " + "check")`, `LANGUAGE_SERVER = "language " + "server"`.

**Core scan loop to copy** (lines 520-540):
```python
old_hits = []
old_scanned = 0
for rel in retired_rels:
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            text = f.read().decode("utf-8", errors="replace")
    except OSError:
        continue
    old_scanned += 1
    if rel == "CHANGELOG.md":
        text = changelog_scan_text(text)
    if OLD_SERVER_NAME in text.lower():
        old_hits.append(rel)
if retired_mode == "nogit":
    old_detail = "git ls-files listed nothing in the checkout ..."
elif old_scanned == 0: ...
gate("no_old_server_name", old_scanned > 0 and not old_hits, old_detail)
```
Differences for the term gate: narrow `retired_rels` to `README.md`, `docs/*.md`, `plugins/bbj/skills/**/*.md`, non-comment lines of `plugins/bbj/scripts/bbj-check.sh`, and the manifest `description` strings (D-21); squash whitespace before matching (hard-wrapped Markdown); case-insensitive; allow "language server" only in the one definition line; exempt CHANGELOG <= 0.2.1 via `changelog_scan_text`. Do NOT scan `.claude/CLAUDE.md` (term list names the variants). Keep the definition line on one source line.

**Mutation cases** (lines 863-865, 899-913; harness `mutation_case` 604-632 with `plant()` 576-582, `changelog_insert()` 584-596):
```python
mutation_case("old_server_name_readme", ["README.md"],
              lambda dst: plant(dst, "README.md", "Sign in to the docs server " + OLD_SERVER_NAME + "."),
              ["no_old_server_name"])
mutation_case("old_server_name_history_exempt", [CHANGELOG],
              lambda dst: changelog_insert(dst, "## 0.2.1", "- " + OLD_SERVER_NAME + " (history).", True), [])
mutation_case("old_server_name_planning_exempt", [".planning/notes.md"],
              lambda dst: plant(dst, ".planning/notes.md", "the docs server " + OLD_SERVER_NAME), [])
```
Add one planted case per variant/scope (README, docs/install.md, SKILL.md, script string, manifest), a history-exempt control, and a `.planning`/CLAUDE.md-exempt control. Cases at lines ~828-829 and ~880-881 that `plant` into `docs/install-claude-code.md` must be repointed to `docs/install.md` (`plant()` would silently recreate the removed page). Expect list uses names without the `layout_` prefix; new gate name e.g. `no_retired_terms`.

---

### `tests/test_install_pages.sh` (test, request-response)

**Analog:** itself. **Page vars** (lines 39-40) become one `PAGE=$DOCS/install.md`.

**Pin helpers** (lines 43-54):
```sh
slug() { printf '%s' "$1" | tr -c 'A-Za-z0-9\n' '_' | cut -c1-40; }
need() {
  if grep -qF -e "$3" "$2"; then gate "$1_has_$(slug "$3")" ok "$3"
  else gate "$1_has_$(slug "$3")" FAIL "$2 lacks: $3"; fi
}
```
Keep `need claude "$PAGE" ...` / `need codex "$PAGE" ...` so the prefix still names the client. Pins naming the retired heading (`'## 3. Enable the local check'`, `'### Enable the local check (bbj-local)'`) become `Enable the plugin \`bbj-local\``; their gate names change with them (D-11). `forbid` (tr newlines to space, `grep -qiE`) keeps the existing forbids list.

**Link loop** (lines 265-292) iterates `README.md CHANGELOG.md docs/*.md` and FAILs on a missing target. CHANGELOG.md line 187 (frozen 0.2.0 entry) links both removed pages, so add a history cut: skip CHANGELOG targets inside entries <= 0.2.1 (mirror `changelog_scan_text`), or the `link_CHANGELOG_md_docs_install_*` gates FAIL. Gate name shape: `link_$(slug "$rel")_$(slug "$path")`.

---

### `tests/test_release_text.py` + `tests/test_release_text_mutation.sh` (test, transform)

**Table parse to extend** (test_release_text.py lines 193-224): `table_cells(line)`, `PLATFORMS = ("Linux","Windows","macOS")`, row detection `cells[:1] == ["Claude Code"] and len(cells) == len(table_columns)`. Add a per-cell gate (explicit names, one per cell, e.g. `release_cell_claude_macos`) comparing the exact cell text (D-05: `` `bbjcpl`, `bbj-ls` (hook run directly); Claude Code 2.1.296 ``; D-20 for Claude Code / Linux). Do not use `readme_has_<slug>`: the 40-character slug collides on the six cells all starting "`bbjcpl`, `bbj-ls` (".

**HINT_FILES** (line 229): `("README.md", "docs/install.md")`. Lines 166, 178, 202 read `docs/install.md` only; `CLAUDE_ON_PLATFORM` still yields one version per platform.

**Mutation script** (test_release_text_mutation.sh): `fresh_root` (lines 25-30) copies `docs/install.md` instead of two pages. `mutate GATE FILE SEDPROGRAM [CASE]` (lines 33-60); retarget the six lines naming the pages (183-193), e.g.
```sh
mutate claude_version_single README.md '/^| Claude Code |/s/[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/9.9.0/' claude_version_single_readme
mutate no_unrun_hint docs/install.md '1s/$/ The plugin has not yet been run on Windows./' no_unrun_hint_install_page
```
Add a sed mutant per README cell (change the qualifier or version in that cell) expecting the new cell gate FAIL. Header comment (lines 5-8) names the five files copied: update.

---

### `tests/run.sh` prefix-block gate (runner, batch)

**Analog:** itself, loop at lines 17-45. Today the header is only echoed and gates are appended untagged:
```sh
echo "== $(basename "$t")"
sh "$t" > "$OUT" 2>&1
rc=$?
cat "$OUT"
grep '^gate ' "$OUT" >> "$OUT.gates" 2>/dev/null
```
Change: `echo "== $(basename "$t")" >> "$OUT.gates"` before the grep in both loops (the SUMMARY awk uses `$3 == "ok"`, so `==` lines are ignored; `python_tests` gates are echoed without a header and must be ignored by the prefix check). After both loops and before SUMMARY, parse the flat block (`- \`test_x.sh\`: \`p1_\`, \`p2_\``) from `.claude/CLAUDE.md` (and compare identical to `.planning/codebase/CONVENTIONS.md` when present; absent = skip without FAIL even under `CI=true`), per file: longest-prefix-first match for every gate name; every listed prefix printed by its file (skip files that did not run); every `tests/test_*` on disk in the block and vice versa. Print one gate (e.g. `run_prefix_block`), counted in SUMMARY. Only tools in the test_ci_gates farm are allowed: `sh cat cp mv mkdir rm mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd tee env` (no `cut`, `comm`, `diff`, `paste`). Block location is `.claude/CLAUDE.md` because `.planning/` is not on `main`.

---

### `tests/test_ci_gates.sh` (test, batch, fixture-based)

**Analog:** itself, lines 9-52. Fixture pattern:
```sh
mkdir -p "$WORK/repo/tests"
cp "$REPO/tests/ci.sh" "$REPO/tests/run.sh" "$WORK/repo/tests/"
printf '#!/bin/sh\necho "gate stub ok stub"\n' > "$WORK/repo/tests/test_stub.sh"
CI=true PATH=$WORK/farm sh "$WORK/repo/tests/run.sh" > "$WORK/run.out" 2>&1
rc=$?
if [ "$rc" = 1 ] && grep -F 'gate python_tests FAIL' "$WORK/run.out" > /dev/null && grep -F 'SUMMARY: ok=1 fail=1' "$WORK/run.out" > /dev/null; then
  gate run_python_missing_fails_in_ci ok "..."
else
  gate run_python_missing_fails_in_ci FAIL "exit $rc: $(tail -n 3 "$WORK/run.out")"
fi
```
Required follow-ups: (1) write a fixture `.claude/CLAUDE.md` with a block listing `test_stub.sh` / `stub_` into `$WORK/repo` (and rename the stub gate to `stub_ok` or keep with a listed prefix), (2) the exact strings `SUMMARY: ok=1 fail=1` (line 39) and `SUMMARY: ok=1 fail=0 skip=1` (line 46) gain the new prefix gate (ok=2 ...), (3) new mutation cases named `run_prefix_*` that plant a missing prefix, an extra unlisted gate name, and a file absent from the block, each expecting `gate run_prefix_block FAIL`, plus a green control. Keep `run_` prefix for these.

---

### Gate renames: 8 test files + `tests/test_hook_mutation.sh` (test)

**Analogs for the target shape:** `test_noroute_notice.sh` (`notice_`) and `test_path_scrub.sh` (`pathscrub_`): every gate starts with one file prefix. Proposed set (RESEARCH section 4): `claudeplugin_` (not `claude_plugin_`, which would nest under `claude_`), `codexpatch_`, `discovery_`, `reviewfix_`, `neverexec_`, `realcpl_`, `tier2fake_`; environment-dependent skip names (`real_compiler`, `shell_<sh>`, `shellcheck`, `claude_cli`, `hook_command`, `real_hostile_reached_compiler`) must carry an always-printed prefix of the file (e.g. `contract_real_compiler`, `static_shellcheck`).

**Cross-file name references that must change in the same commit** (test_hook_mutation.sh lines 113-138): `tier2_noconn_needs_no_ip`, `tier2_noconn_needs_zero_time`, `tier2_once_windows_connect_timeout`, `tier2_once_windows_refused`, `windows_codex_backslash_dot_control`, `windows_codex_backslash_dotdot_skipped`. Grep `-w` every old name across `tests/` before and after.

---

### README.md and skills / manifests (docs, static)

- README table lines 55-64: intro defines `bbjcpl`/`bbj-ls` and the "(hook run directly)" qualifier; it currently holds "first route" (12), "second route" (58), "compiler check" (56), "language server" (57). Rewrite per D-07/D-08.
- SKILL.md line 7 "Use the first route that exists:" and line 10 "of the `bbj-local` server": edit in BOTH copies identically (D-19, suggested "Use the first of these that exists:"). `tests/test_check_order.py` (`checkorder_identical`, `route_order`) requires the copies equal each other and the order bbjcpl, bbj-local, docs server `bbj`; no test pins "first route".
- Manifest strings: `plugins/bbj/.claude-plugin/plugin.json` lines 4 and 15, `plugins/bbj/.codex-plugin/plugin.json` line 4. The Codex overlay must equal the Claude manifest in shared fields, and `docs_url_description` requires the substring "hosted BBj docs server". Edit all three together.

---

### `.claude/CLAUDE.md` / `CONVENTIONS.md` prefix block (docs)

**Current (nested, lossy) form to replace**, `.claude/CLAUDE.md` lines 179-183. `generate-claude-md` keeps only lines starting `#`, `- `, `* `, `|`, so write one flat top-level bullet per file:
```
- `test_ci_gates.sh`: `ci_`, `run_`
- `test_check_order.py`: `checkorder_`
```
Keep `hookmut_`; drop `installer_`/`homeguard_`; remove the "plus free-form names" and "Free-form names, no shared prefix" lines. Term list also as top-level bullets (allowed term | retired variants | meaning). `.claude/CLAUDE.md` must stay green under `layout_no_retired_route` and `layout_no_old_server_name`: do not regenerate it before `PROJECT.md` and the map are fixed (the generator would reintroduce `install-codex.sh`).

---

### Sweep (MAINT-10): `14-SWEEP.md`

Analog: Phase 11 removal commit `0002b72`. Items with evidence in RESEARCH section 5: S1 `FAKE_CYGPATH_W_FAIL` and S2 `FAKE_CYGPATH_GIT_ROOT` in `tests/fake-bin/cygpath`; S3 `tools-list*` modes in `tests/fake_mcp.py`; S4 `tests/fake_mcp.py:2` docstring; S5 optional `SC2181` in `.shellcheckrc` and `.claude/CLAUDE.md:160`. Do not remove seams that have users (`FAKE_CYGDRIVE_ROOT`, `FAKE_CURL_*`, `TIER2_TEST_SYSPATH`, `BBJ_CHECK_STATE_DIR`, `BBJ_CHECK_DEFAULT_HOMES`, ...).

## Shared Patterns

### Gate line grammar and helpers
**Source:** `tests/lib.sh` (`gate`, `mkwork`, `finish`). **Apply to:** every shell test. Tests start with `. "$(dirname "$0")/lib.sh"` then `mkwork`; end with `finish`. Python: `gate(name, ok, detail)` prints `gate layout_<name> ok|FAIL`, `sys.exit(1 if failed else 0)`.

### Mutation proof
**Source:** `mutation_case` in `tests/test_layout.py` (604-632), `mutate` in `tests/test_release_text_mutation.sh` (33-60), fixture tree in `tests/test_ci_gates.sh`. **Apply to:** the term gate, the cell gate, the prefix gate. Every new gate gets: one planted failure per scope, plus exempt controls (rc 0, no FAIL).

### Self-scan avoidance
**Source:** `tests/test_layout.py` lines 150-165. **Apply to:** any test naming a retired variant; assemble from pieces.

### CHANGELOG history cut
**Source:** `HISTORY_CUT = (0, 2, 1)` and `changelog_scan_text()` in `tests/test_layout.py`. **Apply to:** the term gate and the link loop of `test_install_pages.sh` (frozen 0.2.0 entry links the removed pages).

### Whitespace-robust matching
**Source:** `squash()` in `tests/test_release_text.py` (85-88); `tr '\n' ' '` in `forbid()` of `test_install_pages.sh`. **Apply to:** all phrase and term checks on hard-wrapped Markdown.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `run.sh` per-file prefix parser (awk) | runner | transform | No existing code parses gate output by file; build from the existing loop plus awk, within the restricted tool farm |
| `14-CELL-AUDIT.md` / `14-SWEEP.md` | record | n/a | Planning records; follow `11-CLAIM-TRACE.md` shape |

## Metadata

**Analog search scope:** `tests/`, `docs/`, `README.md`, `plugins/bbj/`, `.claude/CLAUDE.md`
**Files read:** `tests/run.sh`, `tests/test_ci_gates.sh`, parts of `tests/test_layout.py`, `tests/test_install_pages.sh`, `tests/test_release_text.py`, `tests/test_release_text_mutation.sh`, `.claude/CLAUDE.md`; CONTEXT.md and RESEARCH.md (lines 1-454)
**Pattern extraction date:** 2026-10-16
