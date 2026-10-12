# Phase 6: Release 0.2.0 - Pattern Map

**Mapped:** 2026-10-12
**Files analyzed:** 14 new/modified
**Analogs found:** 13 / 14 (all analogs are git-tracked source, no capability mirrors involved)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `CHANGELOG.md` (0.2.0 entry) | docs | transform (fold 0.1.0 entry) | `CHANGELOG.md` current `## 0.1.0 (unreleased)` | exact |
| `.claude-plugin/marketplace.json` (lines 13, 19) | config | config | itself | exact |
| `plugins/bbj/.claude-plugin/plugin.json` (line 3) | config | config | itself | exact |
| `plugins/bbj-local/.claude-plugin/plugin.json` (line 3) | config | config | itself | exact |
| `tests/test_layout.py` (`VERSION`, line 20; comment line 66) | test | request-response (gate lines) | itself (`versions` gate, lines 66-69) | exact |
| `tests/test_noroute_notice.sh` (lines 68, 323) | test | shell lint fix | `tests/test_exit_contract.sh` line 173 | exact |
| `.planning/phases/04-bbj-programming-makeover/04-REVIEW-DISPOSITION.md` | docs/ledger | CRUD (edit YAML + table) | itself (fixed rows) | exact |
| `plugins/bbj/skills/bbj-programming/SKILL.md` (WR-01, lines ~134-137) | skill doc | transform | itself, IN-06 style narrowing | exact |
| `plugins/bbj/skills/bbj-programming/references/sysgui.md` (IN-02 line 12, IN-01 lines 17-19) | skill doc | transform | itself | exact |
| `plugins/bbj/skills/bbj-programming/references/database.md` (WR-08, no edit; already fixed line ~63) | skill doc | none | n/a | exact |
| `README.md` (line 3 version) | docs | config | itself | exact |
| `docs/install-claude-code.md`, `docs/install-codex.md`, `codex/install-codex.sh` (`STATUS_LINE` line 102, header line 5, line 788) | docs/installer | config | themselves | exact |
| `tests/test_release_text.py` (optional new gate, Open Question 6) | test | request-response (gate lines) | `tests/test_layout.py` | role-match |
| `.claude/CLAUDE.md` (lines 96, 214, 227, 65) | docs | config | itself | exact |

## Pattern Assignments

### `CHANGELOG.md` (docs, fold and rewrite)

**Analog:** current `CHANGELOG.md` 0.1.0 entry. Keep this shape (D-08): `## <version>`, one summary line, bullet list, `### Tested against`, `### Not run`. Add `### Upgrading` between the bullets and `### Tested against`. Drop `### Next` (D-07), and drop old lines not re-run (D-10).

**Shape to copy** (lines 3-8, 17-21):
```markdown
## 0.1.0 (unreleased)

First version of the `basis-bbj` marketplace.

- Marketplace `basis-bbj` with two plugins, both at version 0.1.0:
  - `bbj`: the BBj docs MCP server (`bbj-docs`, option `docs_url`, ...
  - `bbj-local`: registers the `bbj-ls` language server of a running BBjServices on
    `127.0.0.1:5009`; installs disabled.
- Install pages: [Claude Code](docs/install-claude-code.md), [Codex](docs/install-codex.md).
```
Heading becomes `## 0.2.0` (no "(unreleased)"), version text becomes 0.2.0.

**Tested-against line style** (each names tool version, instance, what was exercised, date):
```markdown
- Codex CLI 0.156.1 on Linux: the installer, `codex mcp add`, the skills in `~/.agents/skills`,
  the `/hooks` approval and the hook's feedback after `apply_patch`, 2026-10-08.
```
Rewrite with versions and dates from the release run only (Codex 0.162.1 and Claude Code 2.1.296 are what the machine has; take the real values at run time). The old counts `ok=367` and `ok=365` are history; write counts from the final run.

**Not run** (keep verbatim, D-15):
```markdown
- Windows: the Windows branch of the hook and the `commandWindows` entry were not run on Windows.
- macOS: not run on macOS.
```

**Upgrading wording must match installer output byte for byte** (`codex/install-codex.sh`):
- line 727: `skill $s: $dst differs from the shipped copy and was left untouched; rerun with --force to replace it` (sets `pending=1`, exit 3)
- line 780: `Trust step: Codex skips a hook it did not manage until you review it. Start Codex, open /hooks, and approve the BBj check hook.`
- line 781: `The review is pinned to a hash of the script: a changed bbj-check.sh asks again. This script cannot approve it for you.`

Address it as "If you installed from `main` before 0.2.0". Name no 0.1.0 release (D-09) and do not mention the untested upgrade path (D-12).

**Wording gate** (`tests/test_layout.py` lines 184-196): `CHANGELOG.md` is scanned for the forbidden words built from `VEND_WORD` and `UPSTREAM_NAME`. Say "maintained in this repository". Relative links must resolve (`tests/test_install_pages.sh` lines 255-275).

---

### Version fields (REL-01: one commit)

**Analog:** the files themselves. Change exactly these in one commit:
- `.claude-plugin/marketplace.json:13` `"version": "0.1.0"` and `:19` `"version": "0.1.0",`
- `plugins/bbj/.claude-plugin/plugin.json:3` and `plugins/bbj-local/.claude-plugin/plugin.json:3` `"version": "0.1.0",`
- `tests/test_layout.py:20` `VERSION = "0.1.0"` and the comment at line 66

**Gate that enforces it** (`tests/test_layout.py` lines 66-69):
```python
# versions: two plugin.json and both marketplace entries, all 0.1.0
versions = [bbj.get("version"), local.get("version"), ...]
gate("versions", all(v == VERSION for v in versions), "versions=%r want all %s" % (versions, VERSION))
```
Ungated mentions to update in the same or a docs commit: `README.md:3`, `.claude/CLAUDE.md` lines 96, 214, 227. Commit style: `chore(06-03): ...` or `chore: bump to 0.2.0`. The one-commit proof is in RESEARCH.md "REL-01 one-commit proof".

---

### `tests/test_noroute_notice.sh` (ShellCheck fix, lines 68 and 323)

**Analog:** `tests/test_exit_contract.sh` line 173 (directive with a reason, one line above the assignment):
```sh
  # shellcheck disable=SC2209  # the value is the shell name, not a command to run here
  SHELL_UNDER_TEST=sh
```
Apply to `tests/test_noroute_notice.sh:68` (`SHELL_UNDER_TEST=sh`, SC2209) as is. For line 323 (`SESSION_ID=s1`, SC2034) use:
```sh
  # shellcheck disable=SC2034  # read by claude_payload in lib.sh as ${SESSION_ID:-s1}
  SESSION_ID=s1
```
Project rule: a reason next to every directive; no global disables.

---

### `04-REVIEW-DISPOSITION.md` (D-16)

**Analog:** its own fixed rows. Edit the four `disposition:` values in the YAML header, set `open: 4` to `open: 0` (`total: 15` stays), and the four table rows. Header entry:
```yaml
  - id: WR-01
    severity: warning
    disposition: open     # -> fixed
```
Table row style for resolved findings: `| WR-02 | warning | fixed | 04-REVIEW-FIX.md (not in the current review) |`. For WR-08 (stale, fixed by plan 04-07, commits 36d1fca and 5ed9517) write `fixed` with Source `resolved by plan 04-07 (36d1fca, 5ed9517); not in the current review`. Keep `titles: json`.

---

### `SKILL.md` WR-01 (skill doc, narrowing only)

**Analog:** same file, current text (lines ~130-137):
```
The Numeric Output page lists the sign characters `-`, `+`, `(` and `)`, `CR` and `DR` (https://...numeric_output.htm);
its BBj-specific page adds the mask characters `@` and `&` (https://...numeric_output_bbj.htm).
Put one in every mask that can format a negative value.
```
Fix: list the sign characters, then "Put one of these in every mask that can format a negative value", then a separate sentence that `@` and `&` are currency mask characters, not sign characters. Keep the "skill maintainer confirmed on BBj 26.03; the documentation does not state it" sentence (ledger row L031 is OWNER). Edits may only narrow or separate claims. No new OWNER grant (`ledger_check.py` enforces it). Keep the SKILL.md body near 150 lines.

### `references/sysgui.md` IN-02 (line 12) and IN-01 (lines 17-19)

IN-02: change "For a modal window, pass the Dialog flag." to "For a modal top-level window, pass the Dialog flag." Keep the MDI sentence.
IN-01: change "which includes the Dialog flag" to "which sets the Dialog bit" (or add that two windows with flag `$02$` surround it). Do not extend the front-ordering rule beyond D-24 (04-08, OWNER row L151).

**Verification after any skill edit:**
```sh
BBJ_SKILLS_LIVE=1 python3 -I tests/test_skill_examples.py
python3 -I .planning/phases/04-bbj-programming-makeover/ledger_check.py   # 151 rows today
```
Add a short dated post-review note to `04-LEDGER.md` for L031/L117 rather than renumbering (the checker reads locations at the base commit).

---

### `tests/test_release_text.py` (optional, new; Open Question 6)

**Analog:** `tests/test_layout.py`. Copy its header and gate idiom:
```python
"""tests/test_layout.py -- plan ...: ...
stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate layout_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
..."""
import json
import os
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))
```
Conventions: module docstring, 4-space indent, `%`-formatting, no f-strings, module-level `failed = False` with `global failed` in `gate()`, `sys.exit(1 if failed else 0)`, gate prefix `release_`. Assemble any forbidden word from pieces (as `VEND_WORD = "vend" + "or"`). Possible gates: README version equals `VERSION`; CHANGELOG holds `## 0.2.0`, `### Upgrading`, `### Tested against`, `### Not run`, no `0.1.0`; the two installer fragments appear in both CHANGELOG and `codex/install-codex.sh` (mirror `codex_quoted_messages_in_installer` in `tests/test_install_codex.sh`). The file needs the `test_` prefix so `tests/run.sh` discovers it. Only create it if the owner accepts Open Question 6.

---

### Version pins in docs/installer (Pitfall 6)

Update only to versions actually exercised in the D-11/D-13 runs, in a docs commit separate from the version commit: `docs/install-claude-code.md:10,136` (2.1.294), `docs/install-codex.md:3,95,102,140` and `codex/install-codex.sh:5,102,788` (0.156.1). Keep the phrase `Tested on Linux only` (`tests/test_install_pages.sh:154`). Changing `STATUS_LINE` does not change `bbj-check.sh`, so the `/hooks` hash is unaffected.

---

### Release evidence harness (reuse, not a repo file)

**Analog:** `.planning/phases/02-hook-no-route-notice/evidence/capture-claude.sh` and `capture-codex.sh` (tracked). Reuse: scratch dirs, `trap` cleanup, before/after comparison of the real config, `env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION`. Use `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` and `codex exec -s danger-full-access` (bwrap unavailable).

## Shared Patterns

### Commit convention
**Source:** `.claude/CLAUDE.md` Git section. Conventional prefix with phase-plan scope: `fix(06-01): ...`, `test(06-02): ...`, `docs(06-03): ...`, `chore(06-03): ...`. Merge to `main` with `gh pr merge --merge --match-head-commit <sha>` (D-02).

### Gate output grammar
**Source:** `tests/lib.sh` `gate NAME STATUS DETAIL` (ok/FAIL/skip); Python tests print `gate <prefix>_<name> ok|FAIL <detail>`. Under `CI=true` a missing prerequisite is FAIL, never skip.

### Shellcheck directives
**Source:** `tests/test_exit_contract.sh:173`. One-line directive plus a reason. `.shellcheckrc` already disables SC1091, SC2012, SC2016, SC1003, SC2015, SC2181.

### Release suite invocation
**Source:** RESEARCH.md "Pre-flight / release suite". Mirror CI with a lockfile claude installed outside the repo tree (a scratch copy of `.github/ci-tools`), daemon stopped (D-18), `CI=true BBJ_LS_LIVE=1 BBJ_SKILLS_LIVE=1 BBJ_TEST_CODEX=$(command -v codex) sh tests/ci.sh`. Expect `ok=N fail=0 skip=0` and `CI SUMMARY: ok=6 fail=0 skip=0`.

### Tag and Release (one-way, owner confirms first)
**Source:** RESEARCH.md Pattern 4. `git tag -a 0.2.0 "$(git rev-parse origin/main)"` (no `v`), `git push origin 0.2.0`, `gh release create 0.2.0 --verify-tag --title 0.2.0 --notes-file <awk-extracted entry>`. Do not run a milestone tool that would create `v0.2.0` (`git.create_tag: true`).

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| Annotated tag `0.2.0` and GitHub Release | release | one-way publish | No tags exist in the repo. Use RESEARCH.md Pattern 4 commands. |

## Metadata

**Analog search scope:** `CHANGELOG.md`, manifests, `tests/test_layout.py`, `tests/test_exit_contract.sh`, `tests/test_noroute_notice.sh`, `codex/install-codex.sh`, Phase 4 review files, Phase 2 evidence scripts, skill files.
**Files scanned:** about 14
**Pattern extraction date:** 2026-10-12
