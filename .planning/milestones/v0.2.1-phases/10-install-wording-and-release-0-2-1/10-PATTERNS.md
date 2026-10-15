# Phase 10: Install wording and release 0.2.1 - Pattern Map

**Mapped:** 2026-10-14
**Files analyzed:** 22 (modified or created)
**Analogs found:** 22 / 22 (every file extends itself or a tracked sibling; all paths checked tracked with `git ls-files`)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `codex/install-codex.sh` | installer (script) | file-I/O, request-response | itself: option loop 203-214, `render_hooks` 305-322, Known gaps 1278-1291 | exact (self) |
| `tests/test_install_codex.sh` | test (shell) | file-I/O | itself: `first_status_banner` 167, `command_windows_cygpath` 533-552, `newenv`/`run_inst` 62-77 | exact (self) |
| `tests/fake-bin/cygpath` | test fake | transform | itself: `FAKE_CYGDRIVE_ROOT` seam (Phase 9, off unless set) | exact (self) |
| `tests/test_install_pages.sh` | test (shell) | transform (text pins) | itself: `need`/`forbid`/`check_common` 36-66, phrase lists 171-226, 255-292 | exact (self) |
| `tests/test_release_text.py` | test (python) | transform (text pins) | itself: constants 47-57, `pinned_gate` 139-147, `claude_version_single` 189-197, `not_run` 199-203 | exact (self) |
| `tests/test_release_text_mutation.sh` | test (shell) | transform | itself: `fresh_root` 29-35, `mutate` 38-52, cases 165-177 | exact (self) |
| `tests/test_layout.py` | test (python) | transform | itself: `VERSION` line 28, `bbj_mcp` 113-118, `codex_mcp` 125-131, `mutation_case` 337+ | exact (self) |
| `plugins/bbj/.mcp.json`, `plugins/bbj/.codex-mcp.json` | config | request-response | each other (oauth block) | exact |
| `plugins/bbj/.claude-plugin/plugin.json` (+ other 4 manifests) | config | n/a | itself (`docs_url` description line 15, `version` line 3) | exact (self) |
| `README.md` | doc | n/a | itself (lines 3, 28-29, 44-50) | exact (self) |
| `docs/install-claude-code.md`, `docs/install-codex.md` | doc | n/a | themselves (`## Windows` sections, banner lines) | exact (self) |
| `CHANGELOG.md` (`## 0.2.1`) | doc | n/a | `CHANGELOG.md` `## 0.2.0` lines 3-93 | exact |
| `.planning/phases/10-.../10-WINDOWS-INSTALLER-RUN.md` | record | n/a | `09-WINDOWS-RUN.md` "Installer route (optional)" + `platform-run/windows-runbook.md` | role-match |
| `.planning/phases/10-.../install-gate.sh` (copy, `WANT_VERSION=0.2.1`) | release evidence script | request-response | `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/install-gate.sh` | exact (copy) |
| `.planning/phases/10-.../codex-run/{run.sh,hooks_list.py,owner.sh}` (re-based copies) | evidence harness | event-driven | `.planning/phases/08-codex-plugin-route/linux-run/` | exact (copy, base `bbj-phase10`) |
| `.claude/CLAUDE.md` version lines | doc | n/a | itself (lines 10, 96, 217, 230) | exact (self) |

## Pattern Assignments

### `codex/install-codex.sh` (installer, D-06, D-07, D-08, D-12)

**Analog:** itself. Four edit sites.

**Option loop** (lines 203-214) - add `--sh-exe` exactly like `--skills-dir`:
```sh
    --skills-dir) [ "$#" -ge 2 ] || refuse "--skills-dir needs a value"; skills_dir=$2; shift 2 ;;
    --codex-home) [ "$#" -ge 2 ] || refuse "--codex-home needs a value"; codex_home=$2; shift 2 ;;
    --with-local) with_local=1; shift ;;
```

**Early refusal placement:** after the docs-URL `case` checks (lines 225-236), before `mkdir -p "$codex_home"` (line 276). Existing style (refuse-before-write, `--remove` contradictions at 216-223):
```sh
if [ "$remove" = 1 ] && [ "$with_local" = 1 ]; then
  refuse "--remove and --with-local cannot be combined"
fi
```
Apply the sh.exe check only when `remove=0` (Pitfall 9); refuse `$`, backtick, `"` in the resolved `w_sh` (Pitfall 8); message names the resolved path and `--sh-exe`.

**Call form to change** (lines 310-316, 319-322):
```sh
hook_cmd="sh \"$script_dst\""
hook_cmd_win=$hook_cmd
if command -v cygpath > /dev/null 2>&1; then
  w_sh=$(cygpath -w "$(command -v sh)")
  w_script=$(cygpath -w "$script_dst")
  hook_cmd_win="\"$w_sh\" \"$w_script\""
fi
```
Target: `hook_cmd_win="& \"$w_sh\" \"$w_script\"; exit \$LASTEXITCODE"`. `json_str` (307-309) and `render_hooks` stay; `printf '%s'` does not interpret `$`. Model: the plugin's `plugins/bbj/hooks/hooks.json` line 10 `...; exit $LASTEXITCODE`.

**STATUS_LINE and Known gaps** (line 149, 1278-1291; printed at 195, 1152, 1289):
```sh
STATUS_LINE='Verified on Linux with Codex CLI 0.162.1; not yet run on Windows or macOS.'
...
say "- commandWindows in hooks.json is not yet tried on Windows; if Codex rejects it there, use command_windows in config.toml instead."
```
Replace both with the observed outcome (D-12); also the header sentence at lines 5-8 and the option list 96-99, the `usage()` text 162-193, the exit-code paragraph 100-116. Keep exit contract 0/2/3. The three `UPGRADE_QUOTES` must stay on non-comment lines; leave the three 0.2.0 quote lines until the atomic bump commit.

---

### `tests/test_install_codex.sh` (test, installer gates)

**Analog:** itself.

**Case scaffolding** (lines 62-77): `newenv NAME`, `run_inst PATHVALUE ARGS...`; fake cygpath is on PATH as `$WORK/fbcyg:$WITH_CODEX`.

**Gate to re-pin, status banner** (line 167-168):
```sh
head -n 1 "$WORK/out" | grep 'not yet run on Windows or macOS' > /dev/null \
  && gate first_status_banner ok "..." || gate first_status_banner FAIL "first line: $(head -n 1 "$WORK/out")"
```
Better: compare to the `STATUS_LINE=` value read from the installer so one source feeds both.

**Gate to re-pin, `command_windows_cygpath`** (lines 533-552): Python one-liner via `python3 -I -c`. New asserts: `w.startswith('& "W:')`, `w.endswith('; exit $LASTEXITCODE')`, `w.count('"') == 4`.

**New gates** (free-form names, no new prefix): refusal when `cygpath -w` fails (new fake seam), `--sh-exe /nonexistent/sh.exe` exits 2 with `home_snapshot`/`home_diff` proving nothing written, override lands in `hooks.json`, `--help` documents it, `--remove` unaffected. Use `home_snapshot`/`home_diff` from `tests/lib.sh`. The derived-missing-file case cannot occur with the fake (`command -v sh` always exists): state that in the gate comment.

---

### `tests/fake-bin/cygpath` (test fake)

**Analog:** itself; header comment and the Phase 9 seam style:
```sh
# Phase 9 (plan 09-01, PLAT-02, D-12) adds the seam FAKE_CYGDRIVE_ROOT, which is off unless the
# variable is set and non-empty. ...
  -w) printf 'W:%s\n' "$2" ;;
```
Add `FAKE_CYGPATH_W_FAIL` the same way: off unless non-empty, then `-w` exits 1 with no output. Document it in the header comment. Output without the seam must stay unchanged.

---

### `tests/test_install_pages.sh` (test, page pins)

**Analog:** itself.

**Helpers** (lines 36-58): `need NAME FILE PHRASE` (gate name = first 40 chars slugged, so keep banner phrases distinct in their first 40 chars) and `forbid NAME FILE ERE LABEL` (newline-flattened, `grep -qiE`).
```sh
check_common() {
  forbid "$1" "$2" 'bbj-mcp\.basis\.cloud' go_live_host
  ...
}
```
Add to `check_common` forbids for `pre-production|go-live|earlier trial` and the old hints (`Tested on Linux only`, `not yet been run on Windows`, `not yet run on Windows or macOS`, `has not yet been tried`, `not yet tried`). Do not forbid `not yet set` or the plain words "Not run".

**Phrase lists to edit:** Claude page 81-112 (`'not yet been run on Windows'` at 100 becomes a forbid), Codex page 171-226 (`'Tested on Linux only'` at 172 and `'Verified on Linux with Codex CLI 0.162.1 on'` at 218 become forbids; add banners, `'## macOS'`, `--sh-exe`, Git-location sentence), README 282-290 (add table row labels and "Verified on Linux, Windows and macOS"). Quoted installer messages (lines 258-275): add each new refusal/option message the page quotes; the loop requires each fragment on the page and on a non-comment installer line.

---

### `tests/test_release_text.py` (test, release pins)

**Analog:** itself. Follow its bump procedure docstring (lines 23-26).

**Constants to re-pin in the atomic bump commit** (lines 47-57):
```python
UPGRADE_QUOTES = [ ... three strings ... ]
CONTENT_VERSION = "0.2.0"
NOT_RUN_LINES = [ "- Windows: ...", "- macOS: not run on macOS.", ]
```
**Pin gate shape** (139-147): `pinned_gate(name, ok, detail, constants)` FAILs with a re-pin message when `VERSION != CONTENT_VERSION`; never skips.

**Gate to relax, `claude_version_single`** (189-197): today
```python
claude_versions = set(re.findall(r"tested with Claude Code ([0-9]+\.[0-9]+\.[0-9]+)", page))
claude_versions.update(re.findall(r"(?:^| )Claude Code ([0-9]+\.[0-9]+\.[0-9]+): ", squash(sections.get("Tested against", []))))
gate("claude_version_single", len(claude_versions) == 1, ...)
```
New: per platform, `re.findall(r"Claude Code ([0-9.]+) on <Platform>", text)` over README, both pages, installer, newest CHANGELOG entry (squashed); each of Linux, Windows, macOS must be present with exactly one version. The "on <P>" anchor keeps "2.1.281 or later" and "2.1.294" subagent mentions out. Keep `codex_version_single` (183-187) untouched. Any new gate must pass in the 9.9.9 copy used by the mutation harness. If a new gate reads another file, add it to `fresh_root` in the mutation script. Update the docstring (CONTENT_VERSION 0.2.1, add the Codex overlay to the bump list).

---

### `tests/test_release_text_mutation.sh` (test, mutation harness)

**Analog:** itself.

`mutate GATE FILE SEDPROGRAM` (38-52) fails with "the mutation changed nothing" when the sed no longer matches. Re-point in the same commit as the constants (cases at 174-177):
```sh
mutate upgrade_quotes codex/install-codex.sh 's/every update of it makes Codex ask/every update of it makes Codex request/'
mutate claude_version_single docs/install-claude-code.md 's/tested with Claude Code [0-9][0-9.]*/tested with Claude Code 2.1.0/'
mutate not_run CHANGELOG.md 's/^- macOS: not run on macOS\.$/- macOS: run./'
```
Use a generic Not run edit (`'/^### Not run$/,$ s/^- /- x /'`) so the D-23 re-pin does not touch this file. Add cases: STATUS_LINE drift, each re-inserted old hint, per-platform Claude version disagreement.

---

### `tests/test_layout.py` (test, manifests)

**Analog:** itself. `VERSION = "0.2.1"` (line 28, single source). Exact-dict gates to extend with `"scopes": "offline_access"` (a string):
```python
gate("bbj_mcp",
     servers == {"bbj-docs": {"type": "http", "url": "${user_config.docs_url}",
                              "oauth": {"clientId": OAUTH_CLIENT_ID, "callbackPort": OAUTH_PORT}}}, ...)
gate("codex_mcp",
     codex_servers == {"bbj-docs": {"type": "http", "url": DOCS_DEFAULT,
                                    "oauth": {"clientId": OAUTH_CLIENT_ID,
                                              "callbackUrl": "http://localhost:%d/callback" % OAUTH_PORT,
                                              "callbackPort": OAUTH_PORT}}}, ...)
```
Add `mutation_case` entries (signature at line 337: `mutation_case(name, rels, change, expect)`): remove `scopes` from `.mcp.json` expects `bbj_mcp` FAIL; array value expects FAIL. Keep the existing `codex_secret` case.

---

### `plugins/bbj/.mcp.json` / `.codex-mcp.json` (config, D-16)

Targeted text edit only, no `json.dump`. Add `"scopes": "offline_access"` inside each `oauth` object. String, not array (array is rejected by `claude plugin validate --strict`).

### Manifests and version bump (REL-07)

Five places via `sed 's/"version": "0.2.0"/"version": "0.2.1"/'`: `plugins/bbj/.claude-plugin/plugin.json` (3), `plugins/bbj-local/.claude-plugin/plugin.json` (3), `plugins/bbj/.codex-plugin/plugin.json` (3), `.claude-plugin/marketplace.json` (13 and 19). Plus `tests/test_layout.py` line 28, README line 3, CHANGELOG heading, `.claude/CLAUDE.md` (10, 96, 217, 230). Reword `plugin.json:15` `docs_url` description (D-05, no gate pins its text; `user_config_docs_url` needs it non-empty; the docs host may appear only in `plugin.json` and `.codex-mcp.json` under `plugins/`).

---

### `CHANGELOG.md` `## 0.2.1`

**Analog:** `CHANGELOG.md` `## 0.2.0` (heading line 3, `### Upgrading` 54, `### Tested against` 70, `### Not run` 91). Shape to repeat:
```markdown
### Upgrading

If you installed from `main` before 0.2.1:
- Claude Code: run `claude plugin marketplace update basis-bbj` and `claude plugin update
  bbj@basis-bbj` ...
### Tested against
- Claude Code 2.1.296: ...            (now: `- Claude Code 2.1.292 on Windows: ...`)
- ... `SUMMARY: ok=738 fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0 run_sh_exit=0`
### Not run
- <one exact line per gap, order = NOT_RUN_LINES>
```
Rules: only the three `### ` headings in that order, no placeholder words, no `### Next`, released entries untouched, Upgrading needs `If you installed from `main` before 0.2.1` and both Claude Code update commands, Not run lines compared with `==` to `NOT_RUN_LINES` after dropping blank lines. Quotes inside Upgrading must be byte-equal to non-comment installer line fragments. Linux Claude Code version: read `claude --version` at write time (2.1.299 now, not 2.1.296; Pitfall 7).

---

### `10-WINDOWS-INSTALLER-RUN.md` (record, owner re-run, D-09)

**Analog:** `.planning/phases/09-windows-and-macos-verification/09-WINDOWS-RUN.md` `## Installer route (optional)` (line 660) and `platform-run/windows-runbook.md`. Reuse: placeholders `<home>`, `<checkout>`, BBj home as written (`C:\bbx`); a dated reading, "Sentence for the docs", verdict line; never paste an authorization URL or token; throwaway Codex home; start Codex in a project folder with `-a on-request`. Separate file recommended (check-records.sh enforces a fixed heading list on the closed Phase 9 record).

### `install-gate.sh` copy and Codex run harness copies (release evidence)

**Analogs:** `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/install-gate.sh` (change `WANT_VERSION=0.2.0` at line 26 to 0.2.1; `ROOT=$(cd "$(dirname "$0")/../../../.." && pwd)` depth must be rechecked after the copy; keep `BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}`). `.planning/phases/08-codex-plugin-route/linux-run/{run.sh,hooks_list.py,owner.sh}`: base `bbj-phase8` is hard-coded at `run.sh:45`, `hooks_list.py:54`, `owner.sh:16`; re-base to `bbj-phase10` in all three. Add a `gitupgrade` scenario for D-22. Throwaway homes live under `$HOME/.cache`, never `/tmp`.

---

### Docs (README, two install pages)

**Analog:** themselves. Edit sites and their decisions are tabulated in 10-RESEARCH.md "Shipped strings to change" (README 3, 28-29, 44-50; Claude page 10, 70, 79, 154-160; Codex page 3-6, 19-21, 28-32, 112-121, 171-177, 216-224, 366-372). Keep `## Windows` heading and add `## macOS` on both pages. Keep exactly one README line beginning ``The `basis-bbj` marketplace`` containing `, version 0.2.1,` (`readme_version`). Every wording change travels with its gate change in one commit.

## Shared Patterns

### Gate and text change together
**Source:** `tests/test_release_text.py:139-147`. A reworded pinned line without its gate fails the suite. Order: wording and gates first at `VERSION = "0.2.0"`, then one atomic commit with the five manifest bumps, `VERSION`, README line, CHANGELOG entry, `CONTENT_VERSION`, `UPGRADE_QUOTES`, `NOT_RUN_LINES`, mutation re-pointing.

### Shell style and installer contract
**Source:** `.claude/CLAUDE.md`, `codex/install-codex.sh` header 100-116. `[ ]`, `printf`, `$(...)`, `command -v x > /dev/null 2>&1`, no `set -e`, no `local`; validate before first write; exit 0/2/3; shellcheck `-s sh` clean.

### Gate output grammar
**Source:** `tests/lib.sh` `gate NAME ok|FAIL|skip DETAIL`; Python `gate("name", ok, detail)` prints `gate <prefix>_<name>`. Keep the file's existing prefix (`installer_`, `claude_`, `codex_`, `readme_`, `release_`, `release_mut_`, `layout_`); no new prefix is needed.

### Release pattern
**Source:** 10-RESEARCH.md "Release pattern" (Phase 6 commands). PR branch from `main` limited to `9f178d2..gsd/planning-setup` (not `main..`, Pitfall 2); branch name `gsd/planning-setup-pr` already exists locally and on origin; merge commit via `gh pr merge N --merge --match-head-commit <sha>`; annotated tag `0.2.1` (no `v`) on the second (D-23) merge commit; `gh release create 0.2.1 --verify-tag --notes-file <entry>`. Every push, merge, tag push and Release waits for owner confirmation.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `gitupgrade` scenario in the Codex run harness copy | evidence harness | event-driven | Phase 8 `run.sh` has `upgrade` for a local marketplace only; the Git-marketplace upgrade reading (D-22) is new. Build from the existing `shorthand` and `upgrade` scenarios plus `hooks_list.py` |
| README verified-configurations table | doc | n/a | No table of that shape exists; use the D-01 rows/columns and gate the row labels in `test_install_pages.sh` |
| Per-platform Claude version gate | test | transform | Existing gate is single-version; design per RESEARCH "Per-platform Claude gate" |

## Metadata

**Analog search scope:** `codex/`, `tests/`, `tests/fake-bin/`, `plugins/bbj/`, `CHANGELOG.md`, `README.md`, `docs/`, `.planning/phases/08-*`, `09-*`, `.planning/milestones/v0.2.0-phases/06-*`
**Files scanned:** about 14 read or excerpted
**Tracked-source gate:** `tests/fake-bin/cygpath` and `.planning/phases/08-codex-plugin-route/linux-run/run.sh` confirmed with `git ls-files`; no gitignored mirror paths named
**Pattern extraction date:** 2026-10-14
