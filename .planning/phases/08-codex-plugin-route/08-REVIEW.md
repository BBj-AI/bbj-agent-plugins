---
phase: 08-codex-plugin-route
reviewed: 2026-10-13T16:30:00Z
depth: standard
files_reviewed: 13
files_reviewed_list:
  - .claude/CLAUDE.md
  - README.md
  - codex/install-codex.sh
  - docs/install-codex.md
  - plugins/bbj/.codex-mcp.json
  - plugins/bbj/.codex-plugin/plugin.json
  - plugins/bbj/scripts/bbj-check.sh
  - tests/lib.sh
  - tests/test_codex_patch.sh
  - tests/test_install_codex.sh
  - tests/test_install_pages.sh
  - tests/test_layout.py
  - tests/test_noroute_notice.sh
findings:
  critical: 0
  warning: 6
  info: 5
  total: 11
status: issues_found
---

# Phase 8: Code Review Report

**Reviewed:** 2026-10-13T16:30:00Z
**Depth:** standard
**Files Reviewed:** 13
**Status:** issues_found

## Summary

Reviewed the Phase 8 Codex plugin route: the `.codex-plugin/plugin.json` overlay and
`.codex-mcp.json`, the route-aware notice in `bbj-check.sh`, `install-codex.sh --remove` and the
OAuth table, the rewritten Codex page, and the new gates. `shellcheck -s sh` is clean on the
installer, the hook and `tests/lib.sh`. I also ran the installer against scratch homes under the
session scratchpad (never `~/.codex` or `~/.agents`): install then `--remove` round trips (plain,
`--with-local`, CRLF, no trailing newline, Codex-written `[marketplaces]`, `[plugins]` and
`[hooks.state]` tables after the block) restore the user content byte for byte, and a second
`--remove` is a no-op.

I found no crash, injection or exit-contract violation. The hook still writes nothing to stdout
except the one notice object, and `CLAUDE_PLUGIN_ROOT` is only tested for non-empty, never
printed. The defects are one destructive path in `--remove`, an inconsistency in how `--remove`
and the install pass attribute comments, a design mismatch in how the Claude Code manifest applies
the pre-registered OAuth client, a notice instruction that does not do what it says, and
stale or release-sensitive documentation.

## Warnings

### WR-01: `--remove` deletes the shipped skills when `--skills-dir` resolves to the checkout

**File:** `codex/install-codex.sh:1058-1069`
**Issue:** The skill branch of `remove_all` compares `$dst` with `$src_skills/$s` using
`diff -r` and, when they are identical, runs `rm -rf -- "$dst"`. When `$dst` is the shipped
directory itself (or a path that reaches it through a symlinked `--skills-dir`), `diff -r` is
trivially clean and the script deletes the repository's own `plugins/bbj/skills/*`. I reproduced
this on a copy of the tree: `--remove --skills-dir <copy>/plugins/bbj/skills` printed
`removed ... (identical to the shipped copy)` for both skills and left the source directory empty.
The `[ -L "$dst" ]` guard only covers the leaf, not a symlinked parent. The install side is not
affected (it only copies). Because `--remove` is the new destructive operation of this release,
it should refuse to delete its own source.
**Fix:** Skip (and name) a destination that is the same directory as the source, before the
`diff`:
```sh
elif [ "$(cd "$dst" 2>/dev/null && pwd -P)" = "$(cd "$src_skills/$s" && pwd -P)" ]; then
  say "skill $s: $dst is the shipped directory of this checkout; left in place"
  pending=1
```
Add a gate to `tests/test_install_codex.sh` that points `--skills-dir` at a temp copy of
`plugins/bbj/skills` and expects the copy to survive with exit 3.

### WR-02: The Claude Code manifest sends the pre-registered OAuth client to whatever `docs_url` is set

**File:** `plugins/bbj/.mcp.json:5-9` (pinned by `tests/test_layout.py` gate `bbj_mcp`)
**Issue:** The installer was deliberately changed so the pre-registered client is written only for
the default hosted URL (`use_docs`, lines 597-607: "an explicit client_id would override that
server's own registration (review 07 WR-02)", gate `oauth_custom_docs_url_no_table`). The Claude
Code plugin has the opposite behaviour: `.mcp.json` carries `oauth.clientId` and `callbackPort`
unconditionally while `url` is `${user_config.docs_url}`. A user who points `docs_url` at a
self-hosted or staging docs server gets this client id forced on a server that has never
registered it, which breaks the sign-in the server would otherwise negotiate by dynamic client
registration. The README and the Claude page both present this as plain configuration, and the
layout gate locks the behaviour in.
**Fix:** Decide the rule once for all three routes. Either document that `docs_url` must be a
server that accepts this client (and say so in README and `docs/install-claude-code.md`), or stop
shipping `oauth` in `.mcp.json` for non-default URLs. The Codex overlay cannot follow `docs_url`
at all (the URL is literal), so the page should also say explicitly that a custom docs URL on
Codex needs the installer script with `--docs-url`.

### WR-03: `codex mcp add` runs unattended with stdin attached, no timeout, and is documented to fail on the supported version

**File:** `codex/install-codex.sh:652-664`
**Issue:** `CODEX_HOME=$codex_home codex mcp add "$srv" --url "$srv_url" > /dev/null 2>&1` keeps
the terminal as stdin and has no timeout. The comments in this file (header, lines 22-23 and
656-657) say that Codex CLI 0.162.1 starts an OAuth flow for this server and exits 1 after writing
the table, and that the client-id variant "waits for a browser". If the hosted server ever
accepts dynamic client registration, or Codex changes, the bare `mcp add` can block the installer
with all output suppressed. On 0.162.1 the call also fails on every install against the default
URL, so the user always sees the long "exited with an error" message while the script then writes
the OAuth and tool tables itself anyway. The fallback message also asserts one cause
("when it tries to register itself with an OAuth server") for any non-zero exit, including
failures that have nothing to do with OAuth.
**Fix:** Since the script now writes the OAuth table and tool tables itself, drop `codex mcp add`
for the default URL and use the managed-block path, or at least run it as
`codex mcp add ... < /dev/null` and keep the message generic ("exited with an error"). The
`oauth_codex_add_error_after_write` gate then still covers the second case.

### WR-04: `--remove` and the install pass disagree on which table a trailing comment belongs to

**File:** `codex/install-codex.sh:473-489` (analyze `extra`) against `codex/install-codex.sh:821-826` (install `flush_main`); message at `codex/install-codex.sh:1051`
**Issue:** The install pass treats blank lines and comments after a table body as leading into the
next table and inserts new tables before them. `analyze`'s `extra` flag treats every non-blank
line after a table header, including such a comment, as content of the previous table. I
reproduced it: an installed plain `bbj-docs` table set (with the tool tables the script wrote)
followed by `# my note about the next` and a user's `[mcp_servers.zzz]` makes `--remove` exit 3
and leave the whole bbj-docs configuration in place. This is a common shape (a comment above the
next table). The message printed is `holds bbj-docs in a form this script did not write; left in
place: it is in a form this script did not write`, which repeats itself and names neither the
line nor the cause, although `docs/install-codex.md` promises that the output "says what it did"
with what to do about it. The only fix the user is given is a hand edit they cannot locate.
**Fix:** In `analyze`, ignore a comment line that is followed (after blank lines) by a header or by
a managed-block marker, or make `remove_tables` leave leading comments in place. At minimum make
`rm_why` specific (record the first offending line number in the awk `END`) and drop the doubled
sentence in `_rm_generic`. Add a gate with a comment between the last installed table and a user
table.

### WR-05: The plugin-route notice tells the user to run a command that does not enable the hook's check

**File:** `plugins/bbj/scripts/bbj-check.sh:223-224` (also the Codex page, lines 332-337)
**Issue:** The hook reaches tier 2 by calling the loopback `bbj-ls` at `127.0.0.1:5009` itself
(`no_tier1_route`), independent of whether Codex has `bbj-local` registered. When the notice fires
the reason is already "no bbj-ls answering on <host:port>" (or curl missing/URL refused). Running
`codex plugin add bbj-local@basis-bbj` only registers the MCP tools for the model; it changes
nothing for the hook, and with BBjServices running the hook would already have checked the file.
The notice therefore names a step that cannot make the next file get checked, which contradicts
the project rule that every claim handed to the agent is correct. The installer-route wording
(`--with-local`) and the Claude wording have the same defect from earlier phases; this phase adds
a third copy and gates it as correct (`notice_codex_plugin_route`).
**Fix:** Say what the hook actually needs: start BBjServices 26.03+ on this machine (or set
`BBJ_HOME` or put `bbjcpl` on `PATH`), and mention `codex plugin add bbj-local@basis-bbj` only as
the way to give the model the local `bbj_check_syntax` tool. Update the three notice texts, the
Codex page "Check routes" item 3 and the gates together.

### WR-06: Release-time and self-contradicting statements in the shipped Codex text

**File:** `docs/install-codex.md:45-53`, `README.md` (Install block), `docs/install-codex.md:132` and `docs/install-codex.md:149`
**Issue:** (a) The page says the GitHub shorthand `codex plugin marketplace add BBj-AI/bbj-agent-plugins`
"holds no Codex plugin files until this release is merged" and tells readers to use a local
checkout "until this release is on GitHub". README's Install block recommends exactly that
shorthand. Once the release is merged both statements are false, and nothing gates their removal
(`tests/test_install_pages.sh` only requires the page to contain the shorthand and the heading).
(b) `--remove` "creates nothing" (page line 132) but writes `config.toml.bbj-backup` and a temp
file (line 149 and the script's `remove_tables`); the script header says "creates no directory",
which is the true statement.
**Fix:** Put the pre-merge caveat in the CHANGELOG or release checklist, or add a release-text
gate that fails while the page still contains "until this release is" so the paragraph cannot
ship. Change "creates nothing" to "creates no directory".

## Info

### IN-01: `.claude/CLAUDE.md` still says to bump four version places

**File:** `.claude/CLAUDE.md:217`
**Issue:** "Versions are identical across both plugin manifests and both marketplace entries ...
Bump all four together." `tests/test_layout.py` now also pins `plugins/bbj/.codex-plugin/plugin.json`
(five places, gate `layout_versions`). A maintainer who follows the baseline file fails the gate.
**Fix:** Say "all five" and name the Codex overlay.

### IN-02: Stale guard and comment in the Codex page checks

**File:** `tests/test_install_pages.sh` (the `codex_verified_claim` forbid and its comment, "The Codex route is unverified")
**Issue:** The comment says the page must not claim verification on Codex, yet the page now opens
with "verified on Linux with Codex CLI 0.162.1" and the new `need` list requires
`Verified on Linux with Codex CLI 0.162.1 on`. The regex `(was|has been|is) (verified|tested) (on|with) (a )?Codex`
only matches the word directly after "on/with", so it never fires on the real wording and guards
nothing.
**Fix:** Remove the forbid and its comment, or replace it with a check that every "verified" line
names the Codex version and the platform.

### IN-03: `plugin_route_env_clean` cannot fail

**File:** `tests/test_codex_patch.sh` (gate `plugin_route_env_clean`)
**Issue:** The variable is assigned only as a prefix on `sh -c`, an external command, so it never
reaches the test shell in any POSIX shell (the Pitfall 4 concern applies to functions, not to
`sh -c`). `lib.sh` already unsets it. The gate counts as coverage but has no failing input.
**Fix:** Drop it, or export and unset in a function the way `tests/test_noroute_notice.sh` does
and keep the gate there.

### IN-04: New `refuse` messages pass user paths through `echo`

**File:** `codex/install-codex.sh:157-158` (used by the new `refuse "$codex_home is not a directory; nothing to remove"` at line 274)
**Issue:** `refuse` uses `echo "install-codex: $*"`. Under dash, a path holding a backslash
sequence such as `\t` is expanded in the message (reproduced). The project rule is `printf` when
the output contains user data. The helper is older than this phase, but `--remove` adds callers
that print the raw `--codex-home` and `--skills-dir`.
**Fix:** `printf 'install-codex: %s\n' "$*" >&2`.

### IN-05: `--remove` pre-flight needs write permission on the files it only unlinks

**File:** `codex/install-codex.sh:300-301`
**Issue:** The shared checks `[ -w "$config" ]` and `[ -w "$script_dst" ]` also run in remove mode.
Removing the check script needs write permission on its directory (already checked), not on the
file, so a read-only `bbj-check.sh` (for example after a manual `chmod 444`) makes `--remove` exit
2 with a misleading "is not writable" although it could remove it.
**Fix:** Keep the `config` check (it is edited in place) and apply the `script_dst` check only
outside remove mode.

---

_Reviewed: 2026-10-13T16:30:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
