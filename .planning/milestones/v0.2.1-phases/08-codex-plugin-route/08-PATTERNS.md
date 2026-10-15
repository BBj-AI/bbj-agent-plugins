# Phase 8: Codex plugin route - Pattern Map

**Mapped:** 2026-10-13
**Files analyzed:** 14 (2 new manifests, 1 hook edit, 1 installer edit, 2 docs, 6 test files/helpers, 1 run record)
**Analogs found:** 13 / 14 (the Linux run record has no analog)

All analog paths below were checked against `git ls-files` (tracked source; no gitignored mirror paths).

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `plugins/bbj/.codex-plugin/plugin.json` (new) | config (manifest) | static | `plugins/bbj/.claude-plugin/plugin.json` | exact |
| `plugins/bbj/.codex-mcp.json` (new) | config (MCP) | static | `plugins/bbj/.mcp.json` | exact |
| `plugins/bbj/scripts/bbj-check.sh` (`_how` case, ~l.215) | hook / utility | request-response | itself, `notice()` | exact |
| `codex/install-codex.sh` (`--remove`) | installer / utility | batch, file-I/O | itself: `analyze`, `state`, `print_block`, step 2 and step 4 | exact |
| `docs/install-codex.md` | docs | n/a | itself (restructure) | exact |
| `README.md` (Codex lines 14-15, 31) | docs | n/a | itself | exact |
| `tests/test_layout.py` | test | transform (JSON reads) | itself | exact |
| `tests/test_noroute_notice.sh` | test | request-response | itself, `notice_codex_text` block | exact |
| `tests/test_codex_patch.sh` (`plugin_route_*`) | test | request-response | `tests/test_claude_plugin.sh` section 4 plus this file's fake-compiler setup | role-match |
| `tests/test_install_codex.sh` (`remove_*`) | test | file-I/O | itself (`home_snapshot` use at l.36 and l.1732) | exact |
| `tests/test_install_pages.sh` (new pins) | test | transform | itself | exact |
| `tests/lib.sh` | test helper | n/a | itself (l.50 `unset`, `home_snapshot` comment) | exact |
| `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` prefix block | docs | n/a | Phase 7 plans 07-05 and 07-06 (byte-identical copy by hand) | exact |
| `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` | record | n/a | none | no analog |

## Pattern Assignments

### `plugins/bbj/.codex-plugin/plugin.json` (config, static)

**Analog:** `plugins/bbj/.claude-plugin/plugin.json` (whole file read, lines 1-24).

Copy lines 2-10 verbatim (`name`, `version`, `description`, `author`, `homepage`, `license`, `keywords`), drop the `userConfig` object (lines 11-23), and add one key:

```json
  "keywords": ["bbj", "basis", "mcp", "skills", "compile-check"],
  "mcpServers": "./.codex-mcp.json"
}
```

The file uses 2-space indentation, and `keywords` stays on one line. The version is `0.2.0` and the gate pins it. Do not bump it (Phase 10).

---

### `plugins/bbj/.codex-mcp.json` (config, static)

**Analog:** `plugins/bbj/.mcp.json` (lines 1-12).

```json
{
  "mcpServers": {
    "bbj-docs": {
      "type": "http",
      "url": "${user_config.docs_url}",
      "oauth": {
        "clientId": "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t",
        "callbackPort": 47613
      }
    }
  }
}
```

Replace the `url` with the literal `https://mcp.bbj-ai.com/mcp`, the `docs_url` default at `plugin.json` line 16. Spike 002 validated only `type` and `url`.

The `oauth` block is Open Question 1 of RESEARCH. The research recommends it (same `clientId` and `callbackPort` as `.mcp.json`, optionally `"callbackUrl": "http://localhost:47613/callback"`, which matches `OAUTH_CALLBACK_URL` at `install-codex.sh:102`). It needs the owner's decision and the Linux check before it ships. If it ships, pin the exact dict in a `layout_` gate. Never add `clientSecret`.

---

### `plugins/bbj/scripts/bbj-check.sh` (hook, request-response)

**Analog:** its own `notice()` function, lines 214-219. The edit is the `apply_patch)` arm only.

```sh
  # the enable steps are the only text that differs by tool (D-06)
  case "$1" in
    apply_patch) _how='To enable a check, set BBJ_HOME to the BBj installation directory or put bbjcpl on PATH, or rerun install-codex.sh --with-local (BBjServices 26.03+ running on this machine).' ;;
    *) _how='To enable a check, set the plugin option bbj_home to the BBj installation directory (for bbjcpl), or enable the bbj-local@basis-bbj plugin (BBjServices 26.03+ running on this machine).' ;;
  esac
```

Pattern to apply (D-07, D-08): split the `apply_patch)` arm on `${CLAUDE_PLUGIN_ROOT:-}`.

```sh
    apply_patch)
      if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
        _how='To enable a check, set BBJ_HOME ... or put bbjcpl on PATH, or run codex plugin add bbj-local@basis-bbj (BBjServices 26.03+ running on this machine).'
      else
        _how='<existing installer text, unchanged>'
      fi ;;
```

Rules:
- Test the variable for non-empty only. Never print or interpolate it (RESEARCH anti-pattern).
- The plugin-route text must contain `BBJ_HOME`, `bbjcpl on PATH`, `codex plugin add bbj-local@basis-bbj`, `BBjServices 26.03`. It must not contain `install-codex.sh`, `bbj_home`, or `enable the bbj-local@basis-bbj plugin`.
- Use `[ ]` and POSIX style, no `local`, no stdout writes beyond the one JSON `printf` at the end of `notice()`.
- Run `sh tests/test_static_guards.sh` and `tests/test_exit_contract.sh` after the edit.
- Fallback if the Linux env probe shows `CLAUDE_PLUGIN_ROOT` does not reach the hook (RESEARCH Pitfall 2): detect via the directory above `scripts/` holding `.codex-plugin/plugin.json`.

---

### `codex/install-codex.sh` (installer, batch / file-I/O) - `--remove`

**Analog:** itself. Reuse the existing classifiers; do not write a second parser.

**Classifiers to reuse** (`analyze` l.263, `print_block` l.419, `state` l.426, `use_docs` l.458, `use_local` l.486). `state` computes `foreign`, `tools_foreign`, `dstate`, `oauth_state`, `miss`, `nokey`, and `analyze` exposes `main`, `url`, `oauth=ours|other|missing`, `tool.NAME=approve|other:V|nokey|missing`, `managed`. Run `use_docs` then `state` (and `use_local` then `state`) to decide removal per server, all-or-nothing per server. Delete with one awk pass that drops the header, body, and the one blank line before each removed header (RESEARCH Pitfall 9). The server pass globals (`srv`, `srv_tools`, `srv_begin`, `srv_end`, ...) are set exactly as the install side does; read the code at l.458-520 and l.759-790 before wiring.

**Constants already defined, lines 100-114** (`OAUTH_*`, `LOCAL_URL`, `LOCAL_MARK_BEGIN`/`LOCAL_MARK_END`, `LOCAL_TOOLS`, `TOOL_KEY`, `STATUS_LINE`). `STATUS_LINE` (l.114) stays verbatim (D-16).

**Skills removal mirrors step 2** (lines 817-832). Reuse the `diff -r "$src" "$dst" > /dev/null 2>&1` identity test:

```sh
  elif diff -r "$src" "$dst" > /dev/null 2>&1; then
    say "skill $s: $dst is identical; nothing changed"
  elif [ "$force" = 1 ]; then
    rm -rf "$dst" && cp -R "$src" "$dst" || refuse "cannot replace $dst"
    ...
  else
    say "skill $s: $dst differs from the shipped copy and was left untouched; rerun with --force to replace it"
    pending=1
```

Removal variant:
- Identical: `rm -rf "$skills_dir/$s"`, guarded with `[ -n ... ]` and a fixed child name, and only if the path is not a symlink.
- Differing: report, `pending=1`, remove only with `--force` (RESEARCH A10; owner or planner decides).

**hooks.json removal mirrors step 4** (lines 846-870). Factor the renderer (`json_str`, the `hook_cmd`/`hook_cmd_win` and `cygpath` branch, and the `printf` at l.860) into a function shared by install and removal. Then `cmp -s "$tmp" "$hooks"`:

```sh
hooks=$codex_home/hooks.json
tmp=$(mktemp "$codex_home/hooks.json.XXXXXX") || refuse "cannot create a temp file in $codex_home"
printf '{\n  "hooks": {\n ... }\n}\n' "$(json_str "$hook_cmd")" "$(json_str "$hook_cmd_win")" > "$tmp"
...
elif cmp -s "$tmp" "$hooks"; then
```

Byte-identical: `rm -f`. Otherwise print the entry to remove and set `pending=1` (D-04).

**Check script:** `rm -f "$script_dir/bbj-check.sh"`, then `rmdir "$script_dir"` (never `rm -rf`). Use the `$script_dir` variable. Never write the literal `$codex_home/bbj"`, which `tests/test_static_guards.sh` scans for in non-comment lines. Avoid the bare words `bbj`, `bbjcpl`, `python`, `node`, `jq`, `eval` in message strings; say `bbj-docs`, `bbj-local`, `bbj@basis-bbj`.

**Pre-flight pattern:** the install path runs `mkdir -p` at l.221 (`$codex_home`), l.232 (`$skills_dir`), l.233 (`$script_dir`) before anything else. Remove mode must not create directories. Add its own check for existence and writability, with `refuse` (exit 2, nothing written), before the first write.

**Exit contract:** `say`, `refuse`, `pending=1` then `[ "$pending" = 0 ] || exit 3` (l.901). Document the option in the header comment (options list near l.75, steps 1-5 near l.64-68) and in `usage()` (l.130-152). Refuse `--remove` together with `--with-local` (exit 2).

Other rules:
- Never call `codex` from removal; the fake codex log must stay empty.
- Leave `config.toml.bbj-backup` and `hooks.state.*` alone.
- Also remove `[mcp_servers.bbj-docs.oauth]` when `oauth=ours` (RESEARCH Pitfall 1).
- Remove the docs table only when its url equals the `--docs-url` in effect (Pitfall 6).
- Write `config.toml` in place (`cat "$tmp" > "$config"`) as the install side does, with the one-time backup first.

---

### `docs/install-codex.md` and `README.md` (docs)

**Analog:** the files themselves. The pins that must survive are listed in RESEARCH "Release-text and page pins" (see `tests/test_install_pages.sh:159-201` and `:215`, `tests/test_release_text.py:41-45`).

- Keep every existing heading: `## 2. Enable the local check ...`, `## Check routes`, `## Not covered`, `## Windows`. Add the plugin sections above them.
- Keep verbatim the "Tested on Linux only" banner and the "not yet been run on Windows or macOS" lines.
- Write the plugin-route verification line as "Verified on Linux with Codex CLI 0.162.1 on <date>". It must not match `(was|has been|is) (verified|tested) (on|with) (a )?Codex`.
- Every `Codex CLI N.N.N` string must name one version (`release_codex_version_single`).
- Do not write sign-in, env-var, or upgrade-trust sentences until the Linux run has observed them.
- Never recommend `--dangerously-bypass-hook-trust` to users.
- README must keep the `The \`basis-bbj\` marketplace` line with `, version 0.2.0,`, plus `recommended where BBjServices 26.03`, `preferred over the hosted check`, `PREFIX, classpath and config`, `--with-local`, `## Skills`, `once per session` (`tests/test_install_pages.sh:253-262`).

---

### `tests/test_layout.py` (test, transform)

**Analog:** itself. Edits at the known lines:

- Loads (l.46-52): add `codex = load("plugins/bbj/.codex-plugin/plugin.json")` and `codex_mcp = load("plugins/bbj/.codex-mcp.json")` with the existing `load()`.
- `versions` (l.60-61): append `codex.get("version")` and keep the gate name `versions`.

```python
versions = [bbj.get("version"), local.get("version"),
            entries.get("bbj", {}).get("version"), entries.get("bbj-local", {}).get("version")]
gate("versions", all(v == VERSION for v in versions), "versions=%r want all %s" % (versions, VERSION))
```

- `docs_host_single_source` (l.176-177): compare sorted lists (RESEARCH Pitfall 11).

```python
gate("docs_host_single_source",
     sorted(hits) == ["plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj/.codex-mcp.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))
```

- New gates, all prefixed `layout_` and written in the same `gate("name", cond, "detail %r" % ...)` style with 4-space indentation, double quotes, `%`-formatting, and no f-strings:
  - `codex_overlay_fields`: shared fields identical to `bbj`, `userConfig` absent, `mcpServers` equals `"./.codex-mcp.json"`.
  - `codex_mcp_url_equals_default`: `codex_mcp["mcpServers"]["bbj-docs"]["url"] == bbj["userConfig"]["docs_url"]["default"]` (use the existing `DOCS_DEFAULT`).
  - If the `oauth` block ships: pin the dict using `OAUTH_CLIENT_ID` and `OAUTH_PORT` (module constants, l.24-25).
- Mention constants such as the host through `DOCS_HOST` (assembled once at the top); do not repeat the literal host elsewhere in the file.

---

### `tests/test_noroute_notice.sh` (test, request-response)

**Analog:** its own Codex block, lines 163-175 of the file (copied from the read above). Existing structure:

```sh
fresh_state
run_check "$(codex_payload "$CPROJ" "$(patch '*** Add File: a.bbj' '+print "a"')")"
CTEXT=$(notice_text "$WORK/stdout")
_nr=$?
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ "$_nr" = 0 ]; then
  holds_all notice_codex_text "$CTEXT" 'BBJ_HOME' 'bbjcpl on PATH' 'install-codex.sh --with-local' \
    'BBjServices 26.03' 'bbj_check_syntax' 'no bbjcpl found'
  holds_none notice_codex_text_no_claude_steps "$CTEXT" 'bbj_home' 'bbj-local@basis-bbj'
else
  gate notice_codex_text FAIL "exit $RC, notice_text $_nr: $(head -c 160 "$WORK/stdout")"
  gate notice_codex_text_no_claude_steps FAIL "no valid notice object"
fi
```

New gates (D-09), prefix `notice_`:
- Installer route: the block above must run with `CLAUDE_PLUGIN_ROOT` unset, with `holds_all` on `install-codex.sh --with-local` and `holds_none` on `codex plugin add`.
- Plugin route: add a sibling block that exports `CLAUDE_PLUGIN_ROOT="$WORK/plugins/cache/basis-bbj/bbj/0.2.0"`, calls `fresh_state` and `run_check`, then `unset CLAUDE_PLUGIN_ROOT`. Assert `codex plugin add bbj-local@basis-bbj` is present and `install-codex.sh` and `bbj_home` are absent.
- The existing `notice_codex_text_no_claude_steps` `holds_none ... 'bbj-local@basis-bbj'` is valid only for the installer text. Keep the three variants separate: each asserts its full command and the absence of the other two (RESEARCH Pitfall 3).
- Set, export, call, and unset explicitly (RESEARCH Pitfall 4; a prefix assignment before a function call can persist in dash).
- Reuse `holds_all`, `holds_none`, `notice_text`, `fresh_state`, `patch`, `silent_out`. They are defined in this file or in `tests/lib.sh`.

---

### `tests/test_codex_patch.sh` (test, request-response) - `plugin_route_*` gates

**Analogs:** `tests/test_claude_plugin.sh` lines 143-165 (the hooks.json command run through a root with a space), and this file's fake-compiler setup (lines 9-30).

Command extraction (`test_claude_plugin.sh:145`):

```sh
cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$HOOKS" 2> /dev/null)
```

Run pattern (`test_claude_plugin.sh:160-165`):

```sh
CLAUDE_PLUGIN_ROOT="$WORK/plug in" BBJ_HOME=$BBJ_TEST_HOME \
  sh -c "$cmd" < "$WORK/bad.json" > "$WORK/out_bad" 2> "$WORK/err_bad"
rc=$?
```

Adapt as follows:
- Instead of a symlink, build a fake cache path with a space: `CACHE="$WORK/home dir/plugins/cache/basis-bbj/bbj/0.2.0"`, `mkdir -p`, then `cp -R "$REPO/plugins/bbj/." "$CACHE/"`.
- Use this file's existing fake compiler (`BBJ_HOME=$WORK/home`, `FAKE_LOG`, `FAKE_OUT`, exported at l.19-23), `codex_payload "$PROJ" "$(patch '*** Add File: bad.bbj' '+print "a"')"`, and the `calls_list` helper.
- Assert, for a bad file: exit 2, first stderr line `bbjcpl reported 1 error(s) in $PROJ/bad.bbj:` (use `grep -Fx`), stdout empty, one fake-compiler call carrying `-N`.
- For a clean file (unset `FAKE_OUT`, then restore it): exit 0, stdout and stderr empty.
- Prefix: new `plugin_route_`; it must not start with any existing prefix. Update the prefix block in `.claude/CLAUDE.md` and `.planning/codebase/CONVENTIONS.md` together.
- This file uses free-form gate names, so no collision there.

---

### `tests/test_install_codex.sh` (test, file-I/O) - `remove_*` gates

**Analog:** itself. It already snapshots the real home at l.36 and l.1732:

```sh
home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.before"
...
home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.after"
...
elif _changed=$(home_diff "$WORK/home.before" "$WORK/home.after"); then
```

Use the same helpers on throwaway homes under `$WORK`:
1. Pre-create `config.toml` with user content, the Codex home, and the skills dir.
2. `home_snapshot` (before).
3. Run install with the fake `tests/fake-bin/codex` on `PATH`.
4. Run `--remove`.
5. `home_snapshot` (after), then `home_diff`; assert equality.

Cases to cover:
- install, remove, install equals first install;
- second removal is a no-op;
- fake codex log empty during removal;
- `config.toml` with the OAuth table and with a custom `--docs-url` (no OAuth table written);
- hand-written `bbj-local` or `bbj-docs`, differing skill dir, and edited `hooks.json` each give exit 3 with nothing touched;
- `--force` removes a differing skill dir;
- `--remove --with-local` is refused (exit 2, nothing written);
- hostile option values.

Prefix: `remove_` (new). Existing prefixes in this file: `local_`, `first_`, `probe_`, `docs_`, `foreign_`, `existing_`, `with_`, `installer_`, `oauth_`.

---

### `tests/test_install_pages.sh` (test, transform)

**Analog:** itself (`need` phrase pins at l.159-201, forbidden-pattern check at l.215). Add `need` pins for the new plugin-route sections and quoted removal-output messages, in the same plan that rewrites the docs.

---

### `tests/lib.sh` (test helper)

**Analog:** itself.

- Line 50: add `CLAUDE_PLUGIN_ROOT` to the existing `unset`.

```sh
unset BBJ_HOME BBJHOME CLAUDE_PLUGIN_OPTION_BBJ_HOME CLAUDE_PROJECT_DIR
```

  `no_compiler_env` at l.218-219 repeats a shorter `unset`; the research suggests the top-level one suffices, so check that function too.
- `home_snapshot` (l.252+): the comment at l.253 says "Phase 8 adds its plugin-route paths here". The research recommends not adding Codex-written paths (`plugins/`, `[marketplaces]`, `[plugins]`); update the comment to record that decision, with no change to the watched list unless the planner decides otherwise.

---

## Shared Patterns

### Gate output and file header
**Source:** `tests/lib.sh` (`gate`, `mkwork`, `finish`) and each test's header comment.
**Apply to:** every new or edited test file.
- Shell tests begin `. "$(dirname "$0")/lib.sh"` then `mkwork`. Python tests use the `gate(name, cond, detail)` style with `sys.exit(1 if failed else 0)`.
- Gates print `gate <prefix>_<name> ok|FAIL|skip DETAIL`. New gate names must not begin with an existing prefix.
- Open each file with a block comment naming plan and decision IDs (`D-14`, `CODEX-02`) and "Nothing here runs BBj".

### Fakes only, never the real Codex home
**Source:** `tests/fake-bin/bbjcpl`, `tests/fake-bin/codex`, `tests/lib.sh` `codex_payload` (l.141-146) and `run_check` (l.148-153).
**Apply to:** the D-14 gate, the notice gates, and the removal tests. Real-Codex runs belong in `08-LINUX-RUN.md` only, in a throwaway home under `~/.cache`, never under `/tmp`, never `~/.codex` or `~/.agents`.

### Shell style and static guards
**Source:** `.claude/CLAUDE.md` Conventions; `tests/test_static_guards.sh` (codex scan around l.150-166).
**Apply to:** `bbj-check.sh` and `install-codex.sh` edits. POSIX `sh`; `[ ]`; `$(...)`; `printf` for user data; no `local`; no `set -e`; `command -v`; underscore temporaries; every failure path ends in an explicit return or exit. Comments may name forbidden tokens in words. Run `sh tests/test_static_guards.sh` and `shellcheck -s sh` after each edit.

### Installer exit contract and write rules
**Source:** `codex/install-codex.sh` header and `refuse`/`say`/`pending` (l.119-128, l.901).
**Apply to:** `--remove`. Exit 0 done, 2 refusal before any write, 3 something left by hand. Validate everything before the first write. Back up `config.toml` once. Never edit JSON the installer did not write.

### Hosted-host naming rule
**Source:** `tests/test_layout.py` `docs_host_single_source`.
**Apply to:** every new shipped file under `plugins/`. Only the two allowed files may name the hosted host. Assemble self-matching strings from pieces in tests.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `.planning/phases/08-codex-plugin-route/08-LINUX-RUN.md` | record | n/a | New artifact. Content is the Codex version, date, route and outcome per run. Reuse `.planning/spikes/001-codex-plugin-hooks/run.sh` and `fake_responses.py` for the runs; the shape follows `.planning/milestones/v0.2.0-phases/06-release-0-2-0/evidence/codex/checks.txt`. These are planning files, not shipped source, so the tracked-source gate does not apply to them. |

## Metadata

**Analog search scope:** `plugins/bbj/`, `codex/`, `docs/`, `tests/`, `.planning/phases/08-codex-plugin-route/`.
**Files read:** CONTEXT.md, RESEARCH.md (lines 1-441, then 442-639), `plugin.json`, `.mcp.json`, `bbj-check.sh` (l.195-235), `test_noroute_notice.sh` (l.1-200), `install-codex.sh` (selected ranges), `test_claude_plugin.sh` (l.100-165), `test_layout.py` (selected ranges), `tests/lib.sh` (selected ranges), `test_codex_patch.sh` (l.1-40, 120-160).
**Not re-read:** `docs/install-codex.md`, `README.md`, `test_install_pages.sh`, `test_release_text.py` (pins taken from RESEARCH, which cites exact lines; confirm against the files before editing).
**Pattern extraction date:** 2026-10-13
