# Phase 11: Installer removal - Pattern Map

**Mapped:** 2026-10-15
**Files analyzed:** 28 (7 deleted, 21 edited, 0 new files; the new gate is a block inside an existing file)
**Analogs found:** 4 / 4 for the new code (the rest is deletion or rewording)

Source of the term list: `git grep -n -i -e install-codex -e AGENTS-snippet -e installer -- ':!.planning'`
(about 330 hits outside `.planning/`; counts per file below). All analog paths are git-tracked.

## File Classification

| File | Action | Role | Data flow | Closest analog / model | Match |
|------|--------|------|-----------|------------------------|-------|
| `codex/install-codex.sh`, `codex/AGENTS-snippet.md` | delete | installer, doc | n/a | none | n/a |
| `tests/test_install_codex.sh` (2549 lines) | delete | test | n/a | none | n/a |
| `tests/test_home_guard.sh` | delete | test | n/a | none | n/a |
| `tests/fake-bin/codex` | delete | fake binary | n/a | none | n/a |
| `tests/test_layout.py` | edit + new `layout_` gate + mutation case | test (static text scan) | batch file scan | its own `no_skills_lock` scan (lines 257-272) and `mutation_case` (349-379) | exact |
| `tests/test_release_text.py` | edit (D-07..D-10) | test | file read/compare | itself | self |
| `tests/test_release_text_mutation.sh` | edit | test (mutation) | batch | itself | self |
| `plugins/bbj/scripts/bbj-check.sh` | edit (`report` apply_patch branch + 2 header comments) | hook | request-response | its own `*)` arm | self |
| `tests/lib.sh` | edit (remove `home_snapshot`, `home_diff`, comments) | test helper | n/a | itself | self |
| `tests/test_noroute_notice.sh` | edit | test | request-response | its own `notice_codex_plugin_route` block (lines 156-172) | self |
| `tests/test_install_pages.sh` | edit | test (doc text gates) | file read | its own Claude Code page section | self |
| `tests/test_check_order.py` | edit | test | file read | itself | self |
| `tests/test_static_guards.sh`, `tests/run.sh`, `tests/ci.sh` | edit | test infra | n/a | itself | self |
| `README.md`, `docs/install-codex.md`, `docs/install-claude-code.md`, `.claude/CLAUDE.md` | edit | docs | n/a | `docs/install-claude-code.md` (plugin-only page) | role |

## Pattern Assignments

### New gate in `tests/test_layout.py` (INST-02, D-10, D-11, D-12)

**Analog:** `tests/test_layout.py` `no_skills_lock` scan, lines 257-272 (glob list, read each file, collect hits, one `gate`).

```python
scan = []
for pattern in ("tests/*.sh", "tests/*.py", "codex/*.sh", "plugins/bbj/scripts/*.sh",
                ".github/workflows/*.yml", "README.md", "NOTICE", "CHANGELOG.md", "docs/*.md",
                ".claude-plugin/marketplace.json", "plugins/*/.claude-plugin/plugin.json"):
    scan.extend(glob.glob(os.path.join(ROOT, pattern)))
naming = []
for path in sorted(set(scan)):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
    except OSError:
        continue
    if LOCK_NAME in text or HASH_TEST in text:
        naming.append(os.path.relpath(path, ROOT))
gate("no_skills_lock", not gone and not naming, "present=%r naming=%r" % (gone, naming))
```

Constants go with the existing "assembled from pieces" block (lines 49-53), for example
`INSTALL_SCRIPT = "install" + "-codex.sh"`, `SNIPPET_NAME = "AGENTS" + "-snippet"`, `INSTALLER_WORD = "install" + "er"`.
The test files themselves must not contain the literal terms, so the constants file (this one) is in scope of its own scan.

Design points the planner must decide, taken from CONTEXT:
- Scope is every git-tracked file except `.planning/` and CHANGELOG entries at or below `## 0.2.1`. The `glob` list above is path-pattern based; `git_mode` (line 208) already shows the `subprocess.run(["git", "-C", ROOT, "ls-files", ...])` call. But the mutation copy (`build_copy`, lines 319-324) is not a git repo, so use `os.walk` over the copy root with skips for `.planning`, `.git`, and the CHANGELOG cut, not `git ls-files`. Note `build_copy` copies only `.claude-plugin plugins codex docs README.md NOTICE CHANGELOG.md`; it must also copy `tests/`, `.claude/CLAUDE.md`, `.github` for the gate to see them, and must drop `"codex"` from the copytree list (the dir is gone).
- CHANGELOG cut: keep lines before the first `## ` heading and all lines under headings newer than 0.2.1; skip from `## 0.2.1` to the end (the file has newest first, so "0.2.1 and older" is the tail). `DOCS_HOST`-style test: compare heading versions numerically (tuple of ints) so a later `## 0.2.2` entry is scanned.
- Match is case-insensitive for the word, so scan `text.lower()`, as the `no_vendoring_wording` gate does (lines 291-300: `low = f.read().lower()`; `for word in (...): if word in low: wording.append("%s:%s" % (rel, word))`).
- Prefix is `layout_` (D-12), so gate name e.g. `no_installer`; do not use `installer_`.

**Mutation case pattern** (lines 380-400 define `change(dst)` helpers; lines 440-445 register them under `if len(sys.argv) == 1:`):

```python
    def host_in_third_file(dst):
        with open(os.path.join(dst, "plugins/bbj/skills/bbj-programming/SKILL.md"), "a", encoding="utf-8") as f:
            f.write("\nSee https://" + DOCS_HOST + "/mcp for the hosted server.\n")
...
    mutation_case("host_elsewhere", [SKILL_FILE], host_in_third_file, ["docs_host_single_source"])
```

Add `def installer_mention(dst)` appending a line with the assembled term to a scanned file (README.md or `docs/install-claude-code.md`), plus `mutation_case("installer_mention", [README], installer_mention, ["no_installer"])`. Also add a control for exemption: a planted mention under `## 0.2.1` in the CHANGELOG copy must still pass (`expect=[]`, as the `control` case at line 441), and one under a newer heading must fail. Update the module docstring (lines 1-17, which names `layout_oauth_codex_matches_plugin` and "installer") in words that avoid the three terms.

**Remove** `oauth_codex_matches_plugin` block (lines 149-167) per D-14; the `oauth_inst` code reads `codex/install-codex.sh`. The OAuth pin of both manifests (lines 114-137) stays.

---

### `tests/test_release_text.py` and `tests/test_release_text_mutation.sh` (D-07, D-08, D-09, D-10)

**Analog:** the files themselves; remove by name.

test_release_text.py, remove:
- `UPGRADE_QUOTES` (lines 56-60) and the `upgrade_quotes` block including `installer = read_lines("codex/install-codex.sh")` / `code_lines` (181-192). `CONTENT_VERSION` stays (`not_run` still uses it; `pinned_gate` at line 156 stays).
- `status_line_in_page` (lines 261-267) and the `installer` variable it uses.
- `"codex/install-codex.sh"` from the `codex_version_single` loop (line 199), the `claude_version_single` tuple (line 224) and `HINT_FILES` (line 251). Edit the comments at 196, 205, 250 and the docstring (lines 11-23, 40-41).
- Three `NOT_RUN_LINES` (lines 63, 65, 69) quote the "Codex installer" and the `0.2.0 run` history. D-10 says the test must assemble the term from pieces. Conflict to flag: these lines are pinned against the frozen `## 0.2.1` CHANGELOG `Not run` section, which stays byte-identical (D-03). So keep the strings but build them, for example `INST = "install" + "er"` and `"- Linux: the 0.2.1 Codex " + INST + " with a real Codex; ..."`. Keep all other bytes identical.

Mutation script `tests/test_release_text_mutation.sh`:
- `fresh_root` (lines 40-45): drop `"$1/codex"` from `mkdir -p` and the `cp ... codex/install-codex.sh` line; update header comment lines 6-7, 17-22 (names the installer 8 times; reword without the terms).
- Remove cases `upgrade_quotes` (line 186), `status_line_in_page` (196), `no_unrun_hint_installer` (199).
- Pattern for the surviving cases: `mutate GATE FILE SEDPROGRAM [CASE]` (lines 50-67).

---

### `plugins/bbj/scripts/bbj-check.sh` (INST-03, D-16)

**Analog:** the `*)` arm of the same `case "$1"` (the one-text form). Current code (lines 220-233) has `apply_patch)` with `if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then ... codex plugin add bbj-local@basis-bbj ... else ... install-codex.sh --with-local ...; fi`. Reduce to:

```sh
  case "$1" in
    apply_patch)
      _how='To enable a check, start BBjServices 26.03+ on this machine so that bbj-ls answers, or set BBJ_HOME to the BBj installation directory, or put bbjcpl on PATH. codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it.'
      ;;
    *) _how='...unchanged...' ;;
  esac
```

Comments to reword (no terms allowed): header lines 49 ("or the install-codex.sh route: D-07, D-08 of phase 8"), 130-131 (CLAUDE_PLUGIN_ROOT "absent on the install-codex.sh route"), 221-223 (comment above the case: "the installer's hooks.json sets nothing"). After D-16 `CLAUDE_PLUGIN_ROOT` is no longer read by `report`; check `grep -n CLAUDE_PLUGIN_ROOT` for other uses (it is used in `hooks.json`, not here) and remove header sentence at 130-131 entirely. Line 228 is a false hit (the word "installation"? it matched "installer"? no, it matches `BBj installa`); re-run the scan after editing. Keep the hook exit contract (exit 0 or 2, empty stdout) and run `tests/test_exit_contract.sh` and `tests/test_static_guards.sh`.

---

### `tests/test_noroute_notice.sh` (D-16)

**Analog:** its own plugin-route block, lines 156-172 (`holds_all`/`holds_none` pair) and the `route_run ROOT PAYLOAD` helper (lines 175-184 region: set, export, run, unset as separate statements, Pitfall 4).

```sh
route_run '' "$CODEX_ADD"
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$RNR" = 0 ] \
  && printf '%s' "$RTEXT" | grep -F 'codex plugin add' > /dev/null; then
  gate notice_codex_empty_root ok "empty CLAUDE_PLUGIN_ROOT gives the plugin text"
```

Edits:
- Lines 21-24 header, 31-32 comment: reword.
- First block (lines ~165-183, `notice_codex_text`) currently expects `install-codex.sh --with-local` with root unset; change its expectation to `codex plugin add bbj-local@basis-bbj`, and `holds_none notice_codex_text_no_claude_steps` drops `'or rerun install-codex.sh'`.
- `notice_codex_plugin_route_no_other_steps` (line 199): drop `'install-codex.sh'` from `holds_none` (that line becomes a term mention otherwise).
- Delete `notice_codex_installer_route` (lines 222-235); rewrite `notice_codex_empty_root` (lines 250-257) to expect the plugin text; add an "unset gives plugin text" gate (the old installer-route gate with the expectation flipped is the natural place; name it e.g. `notice_codex_unset_root`, prefix `notice_`).
- `notice_claude_route_command` (line 245) `! grep -F 'install-codex.sh'` must go (term mention) or be built from pieces.

---

### `tests/lib.sh`

Remove `home_snapshot` and `home_diff` (lines ~226-345; `home_snapshot` spans 226-~330) and their header documentation (lines 32-38). Reword the hermetic-defaults comment (lines 43-44, "installer-route gate into a plugin-route one"): keep the sentence that `CLAUDE_PLUGIN_ROOT` is unset so an inherited value cannot change a gate. Users of the helpers: only `tests/test_home_guard.sh` and `tests/test_install_codex.sh` (both deleted); verify with `grep -rn 'home_snapshot\|home_diff' tests`.

---

### `tests/test_install_pages.sh`

Sections (by `# ----` markers): Claude Code page (97), Codex page (193), README (326), installer output (365-372), links (374). Analog for the surviving checks is the Claude Code page block (lines 97-192) using `need`/`forbid`/`check_released_wording` (defined lines 55-96).

- Delete the `installer` block (365-372) entirely.
- In the Codex page block (193-325) remove: line 199 (`'install-codex.sh'` in a required list), lines 256-258 (`### Switch from the installer script`, `sh codex/install-codex.sh --remove`, `## Fallback: the installer script`), the OAuth client id read from the installer (264-277), `codex_local_tools_single_source` (279-287), `codex_quoted_messages_in_installer` (289-314), `codex_plugin_before_installer` (316-324).
- README block (326-363): drop line 341 `'| Codex installer |'` (D-06) and `${n}_codex_plugin_first` (349-359). Reword header comments 10-36.
- Gate prefixes in this file after the edit: `claude_`, `codex_`, `link_`, `readme_`; the `installer_` prefix disappears (matches D-15 and the CLAUDE.md prefix list).

---

### `tests/test_check_order.py` (D-15)

`FILES["snippet"]` (line 24) is read by: `identical` (80-84), `route_order` (87-95), `client_neutral` (loops all FILES), `snippet_check_paragraph_replaced` (125-135), `no_tool_bullets` (140-142). With the snippet gone:
- Remove the `"snippet"` key and the gates that exist only for it (`snippet_check_paragraph_replaced`, and the snippet-only parts).
- Re-base `identical` to compare `bbj_programming` against `bbj_web_programming` text, and `route_order`/`no_tool_bullets` to read the block from a SKILL.md (use `texts["bbj_programming"]`). The block body stays byte-identical in both skills; `skill_placement_*` (lines 112-123) is the model for per-skill checks.
- Docstring line 1-2: reword to name only the two SKILL.md files.

---

### `tests/test_static_guards.sh`, `tests/run.sh`, `tests/ci.sh`

- `tests/test_static_guards.sh` lines 135-169: delete the whole `CODEX_GLOB`/`static_codex_files` block (comment at 135-139 included). The `SCRIPTS_GLOB` loop above it (ending line 133) is the model for what stays.
- `tests/run.sh` lines 13-15: delete the `# ... fake codex ... (IN-06)` comment and `unset FAKE_CODEX_EXIT`. Check for other FAKE_CODEX uses: `grep -rn FAKE_CODEX tests`.
- `tests/ci.sh` line 9: header lists "installer" among the test areas; reword.
- `tests/fake-bin/codex` deleted; other fakes (`bbj`, `bbjcpl`, `curl`, `cygpath`) stay. Check `.github/workflows/ci.yml` and `tests/test_ci_guards.py` for any list naming `fake-bin/codex` (the scan above found none outside tests/).

---

### Docs: `README.md`, `docs/install-codex.md`, `docs/install-claude-code.md`

Model for the page shape: `docs/install-claude-code.md` (plugin-only). Hits: README 10 lines (15-16, 34, 43, 49-50, 67, 69-72), `docs/install-claude-code.md` 2 (line 16 link text `[install-codex.md]` is a filename, which is fine because the page `docs/install-codex.md` keeps its name; the term list checks `install-codex.sh`, `AGENTS-snippet`, `installer`, so `install-codex.md` passes; line 103 "the Codex installer does this by itself" goes), `docs/install-codex.md` 48.

`docs/install-codex.md` sections to delete outright (heading list from `grep '^## \|^### '`): `### Switch from the installer script` (157-223), `## Add the AGENTS.md snippet (both routes)` (239-246, because the snippet file is gone and `~/.agents/skills` as install target was installer-only), `## Fallback: the installer script` with its three `###` subsections (247-381), and `### Pre-approve the docs tools (optional)` (224-238) only if it leans on installer-written tables (read it before deciding). Then scan `## Check routes` (382), `## Not covered` (410), `## Windows` (421), `## macOS` (481) for remaining installer sentences. D-05: add a sentence that on Codex the plugin uses the hosted docs server from `plugins/bbj/.codex-mcp.json`, and only Claude Code has `docs_url`. D-04: name Codex CLI 0.162.1 as verified version.

README "Verified" table (lines ~63-72): delete the `| Codex installer | ... |` row (line 67) and every installer clause in the "Not run" sentence (69-72); lines 15-16, 34, 43, 49-50 lose their installer alternatives (`--with-local`, `--docs-url`, "fallback"). What stays must trace to `08-LINUX-RUN.md`, `09-WINDOWS-RUN.md`, `09-MACOS-RUN.md`, `10-LINUX-RUN.md`. Because the README table and `claude_version_single` gate read the same row, re-run `tests/test_release_text.py` after editing. `tests/test_install_pages.sh` pins many README/page strings; update it in the same commit as the doc edit.

CHANGELOG.md: no edit (28 hits are all at or below `## 0.2.1`, exempt, D-03).

`.claude/CLAUDE.md`: hand-clean lines 7, 20, 34, 46, 55, 94, 106, 109, 114, 179, 183 and the gate-prefix block (drop `test_install_codex.sh` entry, `homeguard_`, `installer_`, and the `installer_`-shared-prefix sentence), plus the architecture "Installation Flow: Codex" paragraph and the Layers bullet for `codex/install-codex.sh`. No exemption applies to this file (D-11).

## Shared Patterns

### Self-scan convention (assemble forbidden words)
**Source:** `tests/test_layout.py` lines 49-53 (`LOCK_NAME = "skills" + ".lock.json"`, `HASH_TEST = "test_sk" + "ills_hash"`, `VEND_WORD = "vend" + "or"`).
**Apply to:** the new gate constants and the three `NOT_RUN_LINES` in `tests/test_release_text.py`.

### Gate grammar and mutation structure
**Source:** `tests/test_layout.py` `gate()` (line 57) and `mutation_case()` (349-379): `gate layout_<name> ok|FAIL <detail>`; mutation fails when "the mutation changed nothing"; checkout never written, temp dir removed in `finally`.
**Apply to:** the INST-02 mutation case. The shell-side twin is `mutate()` in `tests/test_release_text_mutation.sh` (lines 50-67) if the planner prefers a shell case; D-12 says put it in `test_layout.py`.

### Each commit stays green
Deletion of `codex/` and the edits of `test_release_text.py`, its mutation script, `test_install_pages.sh`, `test_layout.py` (`build_copy`, `oauth_codex_matches_plugin`), `test_check_order.py` and `test_static_guards.sh` must land together; each reads `codex/install-codex.sh` or `codex/AGENTS-snippet.md` (grep shows 9 files). Doc and hook edits can land before or after as long as the matching gate edits go with them. Suggested split: (1) hook + `test_noroute_notice.sh`; (2) delete installer, snippet, its tests/helpers, edit all gate readers; (3) docs + `.claude/CLAUDE.md` + `test_install_pages.sh`; (4) the new `layout_` gate and mutation cases last, once the scan is clean. Verify with `sh tests/run.sh` after each, and finish with `git grep -n -i -e install-codex -e AGENTS-snippet -e installer -- ':!.planning' ':!CHANGELOG.md'` returning only assembled-from-pieces lines (i.e. nothing).

## No Analog Found

| File | Role | Reason |
|------|------|--------|
| CHANGELOG-heading-bounded scan (the `## 0.2.1` and older exemption in the new gate) | test logic | No existing gate scans part of a file by heading. Nearest: `sections` parsing by heading in `tests/test_release_text.py` (lines 116-148, `h2`, `heads`, `sections`); planner may copy its heading split rather than invent one. |

## Metadata

**Analog search scope:** `tests/`, `plugins/bbj/scripts/`, `docs/`, `README.md`, `.claude/CLAUDE.md`, `codex/`.
**Files scanned:** about 20 read in part; `git grep` over all tracked files.
**Pattern extraction date:** 2026-10-15
