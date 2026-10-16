"""tests/test_layout.py -- plan 19-03: pins every manifest value the requirements fix.
Plan 01-01 (VEND-01, VEND-03): the skills are ordinary repository files; the hosted-host rule
covers them (D-02) and the lock and hash test stay removed.
Quick 261013-cpn: the entry of the docs server bbj carries the pre-registered OAuth client, pinned in both
MCP files (layout_bbj_mcp, layout_codex_mcp).
Phase 8 (CODEX-01, CODEX-04; D-10, D-11, D-13): pins the Codex overlay
plugins/bbj/.codex-plugin/plugin.json and its literal-URL file plugins/bbj/.codex-mcp.json.
Plan 10-02 (D-05, D-16): both MCP files ask for offline_access as a string; the docs_url
description calls the default the hosted BBj docs server and names no stage of a release.
Phase 11 (INST-02; D-10 to D-12): layout_no_retired_route scans every tracked file outside
.planning/ (git ls-files, or a walk of a mutation copy) for the retired Codex route, CHANGELOG
entries up to 0.2.1 exempt; the layout_mutation_retired_route_* cases plant a mention in each
scope and in each exemption.
Phase 12 (NAME-01; D-01 to D-03): layout_no_old_server_name scans the same tracked files with the
same CHANGELOG cut for the docs server's old name (a literal, case-insensitive match in paths and
text); the layout_mutation_old_server_name_* cases plant it in each scope and each exemption, and
plant two other spellings it does not match.
Phase 14 (DOCS-05; D-02): layout_no_removed_pages scans the same tracked files with the same CHANGELOG
cut for the two former install pages, by path and as text (the names are assembled from pieces in
REMOVED_PAGES); the six layout_mutation_removed_page_* cases plant a mention in the README, in the
conventions file and in a newer CHANGELOG entry, bring a page file back, and plant one in each
exemption (a 0.2.1 entry, .planning/). The two cases that plant into the install page
(retired_route_word_capitalized, old_server_name_capitalized) target docs/install.md, because
plant() would recreate a removed page.
Phase 14 (NAME-04; D-08 to D-10): layout_no_retired_terms scans the shipped text (README.md, docs/*.md, the
skills, the non-comment lines of the hook, the description strings of the four manifests, CHANGELOG
entries newer than 0.2.1) for the six retired variants of the term list (TERM_VARIANTS, assembled
from pieces) on whitespace-squashed, lower-cased text, so a variant split by a line break, written in
capitals or joined by a non-breaking space is found, and a longer word is not. The words "language
server" pass only inside TERM_DEFINITION. .claude/CLAUDE.md, .planning/ and tests/ are outside the scan
(the term list names the variants); the layout_mutation_retired_term_* cases plant a variant in each
scope and each exemption.
Phase 13 (FIX-01; D-01 to D-09): pins the new commandWindows of plugins/bbj/hooks/hooks.json
exactly (layout_hook_command_windows): the ordered lookup of Git for Windows' sh.exe, the loud
not-found branch and the exit-code passthrough. It pins text; the Windows run is 13-WINDOWS-RUN.md.
Two guards outlive any re-pin: layout_hook_windows_safe (no automatic input variable, no Console or
method call, no short-name path, no unconditional per-user item, no space before a cmd redirection) and layout_hook_windows_parts (every lookup location, the findstr
silent-exit condition, the loud branch before the call, the passthrough last); the six
layout_mutation_hook_windows_* cases plant each trap (input variable, method call, short name,
changed passthrough, moved branch, weaker silent-exit test), and one case per review fix of
13-REVIEW.md takes its fix back out (any_sh: WR-01; localappdata: WR-02; any_mention: WR-03;
root_text: WR-04; git_cmd_only: IN-02; no_w6432: IN-03; trailing_space: IN-04).
The layout_mutation_* gates run this file on a temp copy with one change each; passing a root
argument turns them off.

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate layout_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); the mutation check points it at a copy.
Nothing here runs BBj code or touches a Claude Code configuration.
"""
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))

VERSION = "0.2.2"
DOCS_HOST = "mcp.bbj-ai.com"
DOCS_DEFAULT = "https://" + DOCS_HOST + "/mcp"
# NAME-01 (phase 12): the key of the docs server in both MCP files
DOCS_SERVER = "bbj"
OAUTH_CLIENT_ID = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"
OAUTH_PORT = 47613
OAUTH_SCOPES = "offline_access"
HOOK_COMMAND = 'sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"'
# Phase 13 (FIX-01; D-01 to D-09): Codex's Windows override of the hook command. Codex runs it through
# PowerShell (pwsh before Windows PowerShell 5.1), so the string is written in the 5.1 subset.
# Statements 2 to 4 look for Git for Windows' sh.exe and keep the first match:
# - statement 2: $env:ProgramW6432, $env:ProgramFiles, ${env:ProgramFiles(x86)} and the per-user folder,
#   each followed by \Git\bin\sh.exe; an empty variable is skipped. ProgramW6432 comes first because a
#   32-bit PowerShell host sees the x86 folder as ProgramFiles (review IN-03); in a 64-bit host it
#   equals ProgramFiles, and on a 32-bit Windows it is unset. The per-user item is $env:LOCALAPPDATA\Programs,
#   built only when LOCALAPPDATA is set, else $env:USERPROFILE\AppData\Local\Programs, else left out
#   (review WR-02: an expandable string is never empty, so an unset LOCALAPPDATA made it \Programs, a
#   path on the root of the current drive);
# - statement 3: an sh from Get-Command that belongs to Git for Windows, that is its Git folder (two
#   levels up) holds usr\bin\cygpath.exe or bin\cygpath.exe; every sh on PATH is tried in order (review
#   WR-01: a non-Git sh such as busybox has no cygpath, so the hook would pass every BBj file silently);
# - statement 4: bin\sh.exe of the Git folder of git from Get-Command: the parent of the folder that
#   holds git.exe (cmd\git.exe and bin\git.exe), one level more when that parent is mingw*, clang* or
#   ucrt* (mingw64\bin\git.exe: review IN-02); never taken when the Git folder comes out empty, which
#   would make \bin\sh.exe a path on the root of the current drive.
# The not-found branch (statement 5) reads the payload only through the native findstr, because the
# PowerShell host swallows all of stdin when the command text names the automatic input variable
# anywhere, even in a branch that never runs, and sh.exe would then inherit nothing. It stays silent
# only when findstr exited 0, read every payload line in full (each output element is N:text) and no
# file name in it is a BBj file: a file name is the path of an "*** Add File: ", "*** Update File: ",
# "*** Delete File: " or "*** Move to: " header, or the value of "file_path", and it is a BBj file when
# it ends in .bbj, .src or .bbx (any case) right before the escaped line end or the closing quote
# (review WR-03: the text of a change, such as img.src in a web file, never counts). ROADMAP SC1, never a
# silent no-op: a line findstr cannot read in full, such as one over its 8191-byte limit on piped input,
# is reported (accepted D-06 false positive: a non-BBj payload that long is reported too). Otherwise it
# writes three fixed lines to stderr through cmd and exits 2; each echo sits in parentheses before its
# redirection, because cmd keeps the space before 1>&2 as a trailing space of the line (review IN-04). The call takes the script path from
# $env:CLAUDE_PLUGIN_ROOT, which Codex sets for a plugin hook (codex rust-v0.162.1 discovery.rs), because
# PowerShell never expands a variable's value again: a $ or a backtick in the plugin root (a Windows user
# name may hold both) is kept as it is (review WR-04). Only when the variable is unset does the call
# fall back to the ${CLAUDE_PLUGIN_ROOT} text that Codex substitutes into the command, inside a
# double-quoted string. There are no method calls and no type
# literals, so the string also runs under ConstrainedLanguage (D-05). The string ends with the exit-code
# passthrough that keeps exit code 2, which a PowerShell -Command wrapper rewrites to 1; the statement
# before it turns a launch that never set an exit code into exit 1. The logic stays inline (D-08). This
# pins text, not behaviour: PowerShell cannot run in CI; the Windows run is recorded in
# 13-WINDOWS-RUN.md.
HOOK_COMMAND_WINDOWS_STATEMENTS = (
    r'$s = $null',
    r'foreach ($r in $env:ProgramW6432, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" } elseif ($env:USERPROFILE) { "$env:USERPROFILE\AppData\Local\Programs" })) { if ($r -and -not $s) { $p = "$r\Git\bin\sh.exe"; if (Test-Path -LiteralPath $p) { $s = $p } } }',
    r'if (-not $s) { foreach ($c in (Get-Command sh -CommandType Application -ErrorAction SilentlyContinue)) { $q = Split-Path -Parent (Split-Path -Parent $c.Source); if ($q -and -not $s -and ((Test-Path -LiteralPath "$q\usr\bin\cygpath.exe") -or (Test-Path -LiteralPath "$q\bin\cygpath.exe"))) { $s = $c.Source } } }',
    r'''if (-not $s) { $g = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1; if ($g) { $q = Split-Path -Parent (Split-Path -Parent $g.Source); if ($q -and ((Split-Path -Leaf $q) -match '^(mingw|clang|ucrt)')) { $q = Split-Path -Parent $q }; if ($q) { $p = "$q\bin\sh.exe"; if (Test-Path -LiteralPath $p) { $s = $p } } } }''',
    r'''if (-not $s) { $o = findstr /n /r "^" 2>&1; if ($LASTEXITCODE -eq 0 -and -not ($o -notmatch "^[0-9]+:") -and -not ($o -match '(\*\*\* (Add File|Update File|Delete File|Move to): |"file_path"\s*:\s*")([^"\\]|\\[\\/]|\\u[0-9a-f]{4})*\.(bbj|src|bbx)(\\[nr]|")')) { exit 0 }; cmd /c "(echo bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.)1>&2 & (echo Looked in Program Files Git bin, Program Files x86 Git bin, LOCALAPPDATA Programs Git bin, a Git sh on PATH, the Git folder of a git on PATH.)1>&2 & (echo Install Git for Windows or put its bin folder on PATH.)1>&2"; exit 2 }''',
    r'$b = "$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"',
    r'if (-not $env:CLAUDE_PLUGIN_ROOT) { $b = "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" }',
    r'& $s $b',
    r'if ($null -eq $LASTEXITCODE) { exit 1 }',
    r'exit $LASTEXITCODE',
)
HOOK_COMMAND_WINDOWS = "; ".join(HOOK_COMMAND_WINDOWS_STATEMENTS)
# Guards that outlive any re-pin of the string above (phase 13; D-05, D-07, D-09), so the two traps research
# found cannot come back. WINDOWS_FORBIDDEN, matched case-insensitively in the decoded value: the
# automatic input variable (the PowerShell host then reads all of stdin itself and sh.exe inherits
# nothing: stdin starvation; assembled from two pieces so this file never names it whole, the
# self-scan convention), [console], :: and the method calls (a type literal or a method call is
# refused under ConstrainedLanguage), the 8.3 short-name path (it only fits one Git location), and the
# per-user list item as an unconditional expandable string (review WR-02: \Programs on the current
# drive when LOCALAPPDATA is unset), and a space before a cmd redirection (review IN-04: it ends the
# printed line).
WINDOWS_FORBIDDEN = ("$" + "input", "[console]", "::", ".writeerrorline", ".readtoend", ".invoke(",
                     "progra" + "~", r'"$env:localappdata\programs")', " 1>&2")
# WINDOWS_PARTS, each must occur verbatim: every lookup location, the findstr read, the whole silent-exit
# condition (silence only after a full read of the payload whose file names are no BBj file: ROADMAP
# SC1, review WR-03), the
# loud branch (message and exit 2) and the call; the value must also end with the exit-code
# passthrough and the loud branch must come before the call.
WINDOWS_PARTS = (
    r'foreach ($r in $env:ProgramW6432, $env:ProgramFiles,',
    r'${env:ProgramFiles(x86)}',
    r'$(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" } elseif ($env:USERPROFILE) { "$env:USERPROFILE\AppData\Local\Programs" })',
    r'Get-Command sh ',
    r'((Test-Path -LiteralPath "$q\usr\bin\cygpath.exe") -or (Test-Path -LiteralPath "$q\bin\cygpath.exe"))) { $s = $c.Source }',
    r'Get-Command git ',
    r"if ($q -and ((Split-Path -Leaf $q) -match '^(mingw|clang|ucrt)')) { $q = Split-Path -Parent $q }; if ($q) {",
    r'findstr /n /r "^" 2>&1',
    r'''if ($LASTEXITCODE -eq 0 -and -not ($o -notmatch "^[0-9]+:") -and -not ($o -match '(\*\*\* (Add File|Update File|Delete File|Move to): |"file_path"\s*:\s*")([^"\\]|\\[\\/]|\\u[0-9a-f]{4})*\.(bbj|src|bbx)(\\[nr]|")')) { exit 0 }''',
    r'cmd /c "(echo bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.)1>&2 & (echo ',
    r'exit 2 }',
    r'$b = "$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"',
    r'if (-not $env:CLAUDE_PLUGIN_ROOT) { $b = "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" }',
    r'& $s $b',
)
# D-10: the seven identity fields the Codex overlay copies from the Claude manifest, and the
# relative path of its MCP file
SHARED_FIELDS = ("name", "version", "description", "author", "homepage", "license", "keywords")
CODEX_MCP_REF = "./.codex-mcp.json"
LOCAL_URL = "http://127.0.0.1:5009/mcp"
# assembled from pieces so this file never names what it searches for (self-scan convention)
LOCK_NAME = "skills" + ".lock.json"
HASH_TEST = "test_sk" + "ills_hash"
VEND_WORD = "vend" + "or"
UPSTREAM_NAME = "bbj" + "skills"
RETIRED_SCRIPT = "install" + "-codex.sh"
RETIRED_SNIPPET = "AGENTS" + "-snippet"
RETIRED_WORD = "install" + "er"
RETIRED_TERMS = (RETIRED_SCRIPT, RETIRED_SNIPPET, RETIRED_WORD)
# The two file names match as substrings. The word matches as a word (REVIEW IN-03): not inside a
# longer word such as "uninstaller", but still in snake_case or a file name, so the boundary is
# "not a letter" rather than \b, and a plural counts.
RETIRED_WORD_RE = re.compile(r"(?<![a-z])" + RETIRED_WORD + r"s?(?![a-z])")
# NAME-01 (phase 12, D-03): the docs server's old name, matched literally and case-insensitively;
# other spellings are not matched
OLD_SERVER_NAME = "bbj" + "-docs"
# DOCS-05 (phase 14, D-02): the two install pages that docs/install.md replaced; matched
# case-insensitively in paths and text. Assembled from pieces, so this file never names them.
# The Claude Code page is matched by its bare stem. The Codex stem is also the start of a retired
# script name (the stem followed by .sh, found in the frozen CHANGELOG entries and in .planning/),
# so that page is matched only as a page: with ".md" or with a "#" anchor (REVIEW IN-01).
REMOVED_PAGES = ("install" + "-claude-code", "install" + "-codex" + ".md", "install" + "-codex" + "#")
# NAME-04 (phase 14, D-08 to D-10): the six retired variants of the term list, each assembled from
# two pieces (self-scan convention), and the one definition that may hold the words "language server".
# The sixth is the retired name of the plugin bbj-local (REVIEW IN-01); it is matched with the
# article, as the term list writes it.
TERM_VARIANTS = (
    "first" + " route",
    "second" + " route",
    "compiler" + " check",
    "docs" + " mcp",
    "local" + " check",
    "the `bbj-local`" + " server",
)
LANGUAGE_SERVER = "language" + " server"
TERM_DEFINITION = "`bbj-ls`, the BBj " + LANGUAGE_SERVER + " in BBjServices"
# "not a letter" on both sides: a longer word or a verb form ("a local checkout", "the compiler
# checks the files") is not a hit. The scan text has its backticks removed (term_scan_text), so the
# regex is built from the variant without them: the sixth variant is found written with or without
# Markdown backticks (REVIEW WR-06); the term list itself keeps them (TERM_LIST_PHRASES).
TERM_RES = {v: re.compile(r"(?<![a-z])" + re.escape(v.replace("`", "")) + r"(?![a-z])") for v in TERM_VARIANTS}
LANGUAGE_SERVER_RE = re.compile(r"(?<![a-z])" + re.escape(LANGUAGE_SERVER) + r"(?![a-z])")
TERM_HOOK = "plugins/bbj/scripts/bbj-check.sh"
TERM_MANIFESTS = (".claude-plugin/marketplace.json", "plugins/bbj/.claude-plugin/plugin.json",
                  "plugins/bbj/.codex-plugin/plugin.json", "plugins/bbj-local/.claude-plugin/plugin.json")
# a missing one of these is a hit: the gate must not pass over a tree that lost its scope
TERM_REQUIRED = ("README.md", "docs/install.md", "plugins/bbj/skills/bbj-programming/SKILL.md",
                 "plugins/bbj/skills/bbj-web-programming/SKILL.md", TERM_HOOK,
                 "plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj/.codex-plugin/plugin.json")


def term_in_scope(rel):
    return (rel in ("README.md", "CHANGELOG.md", TERM_HOOK) or rel in TERM_MANIFESTS
            or (rel.startswith("docs/") and rel.endswith(".md"))
            or (rel.startswith("plugins/bbj/skills/") and rel.endswith(".md")))


def description_strings(node, out):
    """Collect every value of a key named description, anywhere in a parsed JSON value."""
    if isinstance(node, dict):
        for k, v in node.items():
            if k == "description" and isinstance(v, str):
                out.append(v)
            else:
                description_strings(v, out)
    elif isinstance(node, list):
        for v in node:
            description_strings(v, out)
    return out


def term_scan_text(rel, raw):
    """The text the term gate scans in one file, whitespace-squashed (Unicode \\s, so a
    non-breaking space and a line break count) and lower-cased: the CHANGELOG without its released
    history, the hook without full-line comments, a manifest as its description strings, else the
    whole file. Backticks are dropped, so a variant is found with or without Markdown code marks."""
    text = raw
    if rel == "CHANGELOG.md":
        text = changelog_scan_text(raw)
    elif rel == TERM_HOOK:
        text = "\n".join(ln for ln in raw.split("\n") if not ln.lstrip().startswith("#"))
    elif rel in TERM_MANIFESTS:
        try:
            text = "\n".join(description_strings(json.loads(raw), []))
        except ValueError:
            text = raw
    return re.sub(r"\s+", " ", text.replace("`", "")).lower()


def names_retired(term, low):
    """True when the lower-cased text (or path) low names the retired term."""
    if term == RETIRED_WORD:
        return RETIRED_WORD_RE.search(low) is not None
    return term.lower() in low


# CHANGELOG entries headed with this version or an older one are released history and stay as
# published (D-03, D-11)
HISTORY_CUT = (0, 2, 1)
VERSION_HEADING = re.compile(r"^## (\d+)\.(\d+)\.(\d+)(?:\s|$)")

failed = False


def gate(name, ok, detail=""):
    global failed
    if not ok:
        failed = True
    print("gate layout_%s %s %s" % (name, "ok" if ok else "FAIL", detail))


def load(rel):
    try:
        with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError) as e:
        return {"__error__": "%s: %s" % (rel, e)}


market = load(".claude-plugin/marketplace.json")
bbj = load("plugins/bbj/.claude-plugin/plugin.json")
local = load("plugins/bbj-local/.claude-plugin/plugin.json")
bbj_mcp = load("plugins/bbj/.mcp.json")
local_mcp = load("plugins/bbj-local/.mcp.json")
hooks = load("plugins/bbj/hooks/hooks.json")
codex = load("plugins/bbj/.codex-plugin/plugin.json")
codex_mcp = load("plugins/bbj/.codex-mcp.json")

entries = {e.get("name"): e for e in market.get("plugins", []) if isinstance(e, dict)}

# marketplace: name, exactly the two entries, sources exist
sources_ok = all(os.path.isdir(os.path.join(ROOT, e.get("source", "?")))
                 for e in entries.values())
gate("marketplace_entries",
     market.get("name") == "basis-bbj" and sorted(entries) == ["bbj", "bbj-local"]
     and len(market.get("plugins", [])) == 2 and sources_ok,
     "name=%r entries=%r sources_exist=%s" % (market.get("name"), sorted(entries), sources_ok))

# versions: two plugin.json, both marketplace entries and the Codex overlay (five), all equal to VERSION
versions = [bbj.get("version"), local.get("version"),
            entries.get("bbj", {}).get("version"), entries.get("bbj-local", {}).get("version"),
            codex.get("version")]
gate("versions", all(v == VERSION for v in versions), "versions=%r want all %s" % (versions, VERSION))

# licence
gate("license", bbj.get("license") == "Apache-2.0" and local.get("license") == "Apache-2.0",
     "bbj=%r bbj-local=%r" % (bbj.get("license"), local.get("license")))

# D-10: the Codex overlay holds the seven identity fields of the Claude manifest and the relative
# path of its MCP file, nothing else (an explicit skills or hooks key would replace Codex's default
# discovery); the file it names must exist
codex_keys = sorted(codex) if isinstance(codex, dict) else []
want_keys = sorted(SHARED_FIELDS + ("mcpServers",))
differ = [k for k in SHARED_FIELDS if codex.get(k) != bbj.get(k)]
mcp_file = os.path.isfile(os.path.join(ROOT, "plugins/bbj/.codex-mcp.json"))
gate("codex_overlay_fields",
     codex_keys == want_keys and not differ and codex.get("mcpServers") == CODEX_MCP_REF and mcp_file,
     "keys=%r differ_from_claude=%r mcpServers=%r mcp_file_exists=%s" % (
         codex_keys, differ, codex.get("mcpServers"), mcp_file))

# bbj .mcp.json: exactly one http server at ${user_config.docs_url}. The entry carries the
# pre-registered OAuth client of the hosted docs server (quick 261013-cpn); dict equality
# also rejects a string port and any extra key such as a client secret. Claude Code asks for
# offline_access only when told, so the plugin names it as a string, never an array and never a
# key called scope (plan 10-02, D-16).
servers = bbj_mcp.get("mcpServers", {})
gate("bbj_mcp",
     servers == {DOCS_SERVER: {"type": "http", "url": "${user_config.docs_url}",
                               "oauth": {"clientId": OAUTH_CLIENT_ID,
                                         "callbackPort": OAUTH_PORT,
                                         "scopes": OAUTH_SCOPES}}},
     "mcpServers=%r" % (servers,))

# D-11: the Codex file registers the docs server bbj at the literal docs URL. Plan 08-08 (owner decision
# "signin: add-block", 2026-10-13): without a pre-registered client the hosted server refuses
# dynamic client registration on the plugin route, so the file carries the public client id and
# the registered loopback callback, the object the Linux owner pass signed in with. Dict equality
# also rejects any extra key such as a client secret, header or token.
codex_servers = codex_mcp.get("mcpServers", {})
gate("codex_mcp",
     codex_servers == {DOCS_SERVER: {"type": "http", "url": DOCS_DEFAULT,
                                     "oauth": {"clientId": OAUTH_CLIENT_ID,
                                               "callbackUrl": "http://localhost:%d/callback" % OAUTH_PORT,
                                               "callbackPort": OAUTH_PORT,
                                               "scopes": OAUTH_SCOPES}}},
     "mcpServers=%r" % (codex_servers,))

# D-05: the docs_url description calls the default the hosted BBj docs server and names no stage of
# a release. The stage words are assembled from pieces so this file never names them whole.
STAGE_WORDS = ("pre-" + "production", "go-" + "live", "until the go" + "-live", "tempo" + "rary")
docs_desc = (bbj.get("userConfig", {}).get("docs_url", {}) or {}).get("description", "")
stage_hits = [w for w in STAGE_WORDS if w in str(docs_desc).lower()]
gate("docs_url_description",
     isinstance(docs_desc, str) and "hosted BBj docs server" in docs_desc and not stage_hits,
     "description=%r stage words found=%r" % (docs_desc, stage_hits))

# userConfig
uc = bbj.get("userConfig", {})
docs = uc.get("docs_url", {})
gate("user_config_docs_url",
     docs.get("type") == "string" and docs.get("default") == DOCS_DEFAULT
     and bool(docs.get("title")) and bool(docs.get("description")),
     "docs_url=%r" % (docs,))
home = uc.get("bbj_home", {})
gate("user_config_bbj_home",
     home.get("type") == "directory" and "default" not in home
     and bool(home.get("title")) and bool(home.get("description")),
     "bbj_home=%r" % (home,))
gate("user_config_keys", sorted(uc) == ["bbj_home", "docs_url"], "keys=%r" % (sorted(uc),))

# D-13: the Codex url and the docs_url default are one string, compared exactly (no trailing slash)
codex_url = codex_servers.get(DOCS_SERVER, {}).get("url") if isinstance(codex_servers, dict) else None
gate("codex_url_equals_default", codex_url is not None and codex_url == docs.get("default"),
     "codex url=%r docs_url default=%r" % (codex_url, docs.get("default")))

# hooks.json: matcher, one command hook, exact command, timeout
post = hooks.get("hooks", {}).get("PostToolUse", [])
hook_list = post[0].get("hooks", []) if len(post) == 1 else []
gate("hook_matcher", len(post) == 1 and post[0].get("matcher") == "Write|Edit",
     "PostToolUse=%r" % (post,))
gate("hook_command",
     len(hook_list) == 1 and hook_list[0].get("type") == "command"
     and hook_list[0].get("command") == HOOK_COMMAND,
     "hooks=%r" % (hook_list,))
gate("hook_command_windows",
     len(hook_list) == 1 and hook_list[0].get("commandWindows") == HOOK_COMMAND_WINDOWS
     and hook_list[0].get("command") == HOOK_COMMAND,
     "commandWindows=%r" % (hook_list[0].get("commandWindows") if len(hook_list) == 1 else None,))
# phase 13 (FIX-01; D-05, D-07, D-09): guards on the decoded commandWindows, independent of the exact pin
cw = (hook_list[0].get("commandWindows") or "") if len(hook_list) == 1 else ""
if not isinstance(cw, str):
    cw = ""
found = [t for t in WINDOWS_FORBIDDEN if t in cw.lower()]
gate("hook_windows_safe", not found,
     ("forbidden construct(s) in commandWindows: %r" % (found,)) if found
     else "none of %d forbidden constructs" % len(WINDOWS_FORBIDDEN))
missing = [p for p in WINDOWS_PARTS if p not in cw]
problems = ["missing %r" % (p,) for p in missing]
if not cw.endswith("exit $LASTEXITCODE"):
    problems.append("does not end with the exit-code passthrough")
if not missing:
    if cw.index("exit 2 }") > cw.index('& $s $b'):
        problems.append("the not-found branch (exit 2 }) does not come before the call")
gate("hook_windows_parts", not problems,
     ("; ".join(problems)) if problems else "all %d parts present, passthrough last, not-found branch before the call" % len(WINDOWS_PARTS))
gate("hook_timeout", len(hook_list) == 1 and hook_list[0].get("timeout") == 30,
     "timeout=%r" % (hook_list[0].get("timeout") if hook_list else None,))
gate("hook_events_only_post_tool_use", list(hooks.get("hooks", {})) == ["PostToolUse"],
     "events=%r" % (list(hooks.get("hooks", {})),))


# script mode in git: 100755 (a checkout on Windows or a zip would lose the bit)
def git_mode(path):
    try:
        out = subprocess.run(["git", "-C", ROOT, "ls-files", "-s", "--", path],
                             capture_output=True, text=True, timeout=20).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    return out.split()[0] if out.split() else None


mode = git_mode("plugins/bbj/scripts/bbj-check.sh")
if mode is None and not os.path.isdir(os.path.join(ROOT, ".git")):
    # a temp copy without git history: fall back to the file's executable bit
    p = os.path.join(ROOT, "plugins/bbj/scripts/bbj-check.sh")
    mode = "100755" if os.access(p, os.X_OK) else "100644"
gate("script_mode", mode == "100755", "mode=%r" % (mode,))

# bbj-local: off by default in both places, one http server at the loopback URL
gate("local_default_disabled",
     local.get("defaultEnabled") is False and entries.get("bbj-local", {}).get("defaultEnabled") is False,
     "plugin.json=%r marketplace=%r" % (local.get("defaultEnabled"),
                                         entries.get("bbj-local", {}).get("defaultEnabled")))
gate("local_mcp",
     local_mcp.get("mcpServers", {}) == {"bbj-local": {"type": "http", "url": LOCAL_URL}},
     "mcpServers=%r" % (local_mcp.get("mcpServers"),))
gate("bbj_default_enabled", "defaultEnabled" not in bbj
     and "defaultEnabled" not in entries.get("bbj", {}),
     "bbj does not switch itself off")

# the hosted host name occurs in exactly two files under plugins/ (the skills included, D-02): the
# Claude manifest default and the Codex literal-URL file (D-13). The list is compared sorted because
# os.walk order is not fixed (Pitfall 11).
hits = []
plugins_dir = os.path.join(ROOT, "plugins")
for dirpath, dirnames, filenames in os.walk(plugins_dir):
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        try:
            with open(path, "rb") as f:
                if DOCS_HOST.encode() in f.read():
                    hits.append(os.path.relpath(path, ROOT))
        except OSError:
            pass
gate("docs_host_single_source",
     sorted(hits) == ["plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj/.codex-mcp.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))

# VEND-01: the lock file and the hash test are gone and nothing names them
gone = [n for n in (LOCK_NAME, os.path.join("tests", HASH_TEST + ".py"))
        if os.path.exists(os.path.join(ROOT, n))]
scan = []
for pattern in ("tests/*.sh", "tests/*.py", "plugins/bbj/scripts/*.sh",
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
gate("no_skills_lock", not gone and not naming,
     "present=%r naming=%r" % (gone, naming))

# VEND-03: the one property of the removed hash test worth keeping: no executable skill file
execs = []
for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, "plugins", "bbj", "skills")):
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        if os.path.isfile(path) and os.access(path, os.X_OK):
            execs.append(os.path.relpath(path, ROOT))
gate("skills_not_executable", not execs,
     ", ".join(sorted(execs)) if execs else "no skill file is executable")

# VEND-02: shipped text says the skills are maintained here; no history, no upstream name.
# CHANGELOG.md is read too (phase 1 UAT ruling).
texts = ["README.md", "NOTICE", "CHANGELOG.md", ".claude-plugin/marketplace.json",
         "plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj-local/.claude-plugin/plugin.json",
         "plugins/bbj/.codex-plugin/plugin.json"]
texts.extend(os.path.relpath(p, ROOT) for p in sorted(glob.glob(os.path.join(ROOT, "docs", "*.md"))))
wording = []
for rel in texts:
    try:
        with open(os.path.join(ROOT, rel), encoding="utf-8", errors="replace") as f:
            low = f.read().lower()
    except OSError:
        continue
    for word in (VEND_WORD, UPSTREAM_NAME):
        if word in low:
            wording.append("%s:%s" % (rel, word))
gate("no_" + VEND_WORD + "ing_wording", not wording,
     ", ".join(wording) if wording else "%d shipped texts hold no forbidden wording" % len(texts))

# VEND-02, T-01-04: NOTICE is the name and the copyright line, nothing else
try:
    with open(os.path.join(ROOT, "NOTICE"), encoding="utf-8") as f:
        notice = [ln.strip() for ln in f.read().splitlines() if ln.strip()]
except OSError:
    notice = None
gate("notice_no_provenance",
     notice == ["bbj-agent-plugins", "Copyright 2026 BASIS International Ltd."],
     "NOTICE lines=%r" % (notice,))


# INST-02 (D-10 to D-12): the retired Codex route stays out of every tracked file, comments
# included; terms are assembled from pieces above so this file passes its own scan. Only the
# CHANGELOG entries of released versions (HISTORY_CUT and older) and .planning/ are exempt.
def tracked_files(root):
    """Return (mode, rels): the git-tracked files under root ("git"), or a walk of root ("walk").
    Only a run given a root argument (a mutation copy, which has no .git) may walk; a checkout
    run where git lists nothing returns ("nogit", []) so the gate fails instead of scanning
    untracked trees such as .github/ci-tools/node_modules. .planning/ is dropped."""
    try:
        r = subprocess.run(["git", "-C", root, "ls-files", "-z"], capture_output=True, timeout=20)
        out = r.stdout if r.returncode == 0 else b""
    except (OSError, subprocess.SubprocessError):
        out = b""
    rels = []
    if out:
        mode = "git"
        rels = [p.decode("utf-8", errors="replace") for p in out.split(b"\0") if p]
    elif len(sys.argv) < 2:
        mode = "nogit"
    else:
        mode = "walk"
        for dirpath, dirnames, filenames in os.walk(root):
            top = dirpath == root
            # prune .git, the top-level .planning and any nested checkout or worktree
            dirnames[:] = [d for d in dirnames
                           if d not in (".git", "node_modules") and not (top and d == ".planning")
                           and not os.path.exists(os.path.join(dirpath, d, ".git"))]
            for fn in filenames:
                if fn != ".git":
                    rels.append(os.path.relpath(os.path.join(dirpath, fn), root).replace(os.sep, "/"))
    return mode, sorted({r for r in rels if not r.startswith(".planning/")})


def changelog_scan_text(text):
    """The CHANGELOG lines the gate scans: the text above the first "## " heading, every entry
    newer than HISTORY_CUT and every heading that is not a version (fail closed)."""
    kept = []
    keep = True
    for line in text.split("\n"):
        if line.startswith("## "):
            m = VERSION_HEADING.match(line)
            keep = not (m and tuple(int(g) for g in m.groups()) <= HISTORY_CUT)
        if keep:
            kept.append(line)
    return "\n".join(kept)


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
    for term in RETIRED_TERMS:
        if names_retired(term, low):
            retired_hits.append("%s:%s" % (rel, term))
if retired_mode == "nogit":
    retired_detail = "git ls-files listed nothing in the checkout (git missing, unsafe directory or GIT_DIR set)"
elif retired_scanned == 0:
    retired_detail = "no file scanned (%s mode)" % (retired_mode,)
elif retired_hits:
    retired_detail = "files naming the retired route (%s mode): %r" % (retired_mode, sorted(retired_hits))
else:
    retired_detail = ("%d tracked files scanned (%s mode); none names the retired route "
                      "(.planning/ and CHANGELOG entries up to 0.2.1 exempt)" % (retired_scanned, retired_mode))
gate("no_retired_route", retired_scanned > 0 and not retired_hits, retired_detail)


# NAME-01 (D-01 to D-03 of phase 12): the docs server's old name stays out of every tracked file,
# comments included; same file list and CHANGELOG cut as no_retired_route; .planning/ and
# CHANGELOG entries up to 0.2.1 exempt
old_hits = []
old_scanned = 0
for rel in retired_rels:
    if OLD_SERVER_NAME in rel.lower():
        old_hits.append("%s:path" % (rel,))
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
    old_detail = "git ls-files listed nothing in the checkout (git missing, unsafe directory or GIT_DIR set)"
elif old_scanned == 0:
    old_detail = "no file scanned (%s mode)" % (retired_mode,)
elif old_hits:
    old_detail = "files naming the docs server's old name (%s mode): %r" % (retired_mode, sorted(old_hits))
else:
    old_detail = ("%d tracked files scanned (%s mode); none names the docs server's old name "
                  "(.planning/ and CHANGELOG entries up to 0.2.1 exempt)" % (old_scanned, retired_mode))
gate("no_old_server_name", old_scanned > 0 and not old_hits, old_detail)


# DOCS-05 (phase 14, D-02): the two former install pages stay out of every tracked file, as a path
# and as text, comments included; same file list and CHANGELOG cut as no_old_server_name, so only
# .planning/ and the CHANGELOG entries up to 0.2.1 (the frozen 0.2.0 entry links both) are exempt
removed_hits = []
removed_scanned = 0
for rel in retired_rels:
    low_rel = rel.lower()
    for term in REMOVED_PAGES:
        if term in low_rel:
            removed_hits.append("%s:path" % (rel,))
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            text = f.read().decode("utf-8", errors="replace")
    except OSError:
        continue
    removed_scanned += 1
    if rel == "CHANGELOG.md":
        text = changelog_scan_text(text)
    low = text.lower()
    for term in REMOVED_PAGES:
        if term in low:
            removed_hits.append(rel)
if retired_mode == "nogit":
    removed_detail = "git ls-files listed nothing in the checkout (git missing, unsafe directory or GIT_DIR set)"
elif removed_scanned == 0:
    removed_detail = "no file scanned (%s mode)" % (retired_mode,)
elif removed_hits:
    removed_detail = "files naming a removed install page (%s mode): %r" % (retired_mode, sorted(set(removed_hits)))
else:
    removed_detail = ("%d tracked files scanned (%s mode); none names a removed install page "
                      "(.planning/ and CHANGELOG entries up to 0.2.1 exempt)" % (removed_scanned, retired_mode))
gate("no_removed_pages", removed_scanned > 0 and not removed_hits, removed_detail)


# NAME-04 (phase 14, D-08 to D-10): one term list. The retired variants stay out of the shipped text;
# "language server" passes only inside TERM_DEFINITION. Exempt: CHANGELOG entries up to 0.2.1,
# .planning/, .claude/CLAUDE.md (the term list names the variants), tests/ and full-line comments
# of the hook. Hits print as file:variant, sorted.
term_hits = []
term_scanned = 0
for rel in TERM_REQUIRED:
    if rel not in retired_rels:
        term_hits.append("%s:missing" % (rel,))
for rel in retired_rels:
    if not term_in_scope(rel):
        continue
    try:
        with open(os.path.join(ROOT, rel), "rb") as f:
            raw = f.read().decode("utf-8", errors="replace")
    except OSError:
        if rel in TERM_REQUIRED:
            term_hits.append("%s:unreadable" % (rel,))
        continue
    term_scanned += 1
    low = term_scan_text(rel, raw)
    for v in TERM_VARIANTS:
        if TERM_RES[v].search(low):
            term_hits.append("%s:%s" % (rel, v))
    if LANGUAGE_SERVER_RE.search(low.replace(TERM_DEFINITION.lower().replace("`", ""), "")):
        term_hits.append("%s:%s" % (rel, LANGUAGE_SERVER))
if retired_mode == "nogit":
    term_detail = "git ls-files listed nothing in the checkout (git missing, unsafe directory or GIT_DIR set)"
elif term_scanned == 0:
    term_detail = "no file scanned (%s mode)" % (retired_mode,)
elif term_hits:
    term_detail = "retired terms in shipped text (%s mode): %s" % (retired_mode, ", ".join(sorted(set(term_hits))))
else:
    term_detail = ("%d shipped files scanned (%s mode); no retired term, the words language server only in "
                   "the definition (CHANGELOG up to 0.2.1, .planning/, .claude/CLAUDE.md, tests/ and hook "
                   "comments exempt)" % (term_scanned, retired_mode))
gate("no_retired_terms", retired_mode != "nogit" and term_scanned > 0 and not term_hits, term_detail)


# NAME-04 (D-07, D-09): the term list stands in the conventions: the six retired variants, the
# words of the definition and the allowed terms; a list that loses one fails
TERM_LIST_FILE = ".claude/CLAUDE.md"
TERM_LIST_PHRASES = TERM_VARIANTS + (LANGUAGE_SERVER, TERM_DEFINITION.lower(), "tier 1", "tier 2",
                                     "the hosted check", "the plugin `bbj-local`",
                                     "the docs server `bbj`", "the `bbjcpl` check")
try:
    with open(os.path.join(ROOT, TERM_LIST_FILE), encoding="utf-8") as f:
        conv_low = re.sub(r"\s+", " ", f.read()).lower()
except OSError:
    conv_low = None
if conv_low is None:
    gate("term_list", False, "%s cannot be read" % (TERM_LIST_FILE,))
else:
    term_missing = [t for t in TERM_LIST_PHRASES if t not in conv_low]
    gate("term_list", not term_missing,
         ("missing from the term list: %r" % (term_missing,)) if term_missing else
         "%s names all %d variants and terms" % (TERM_LIST_FILE, len(TERM_LIST_PHRASES)))

# NAME-04 (D-08): the install page holds the one definition that may carry the words "language server"
try:
    with open(os.path.join(ROOT, "docs/install.md"), encoding="utf-8") as f:
        page_low = re.sub(r"\s+", " ", f.read()).lower()
except OSError:
    page_low = None
gate("term_definition", page_low is not None and TERM_DEFINITION.lower() in page_low,
     "docs/install.md holds the definition" if page_low is not None and TERM_DEFINITION.lower() in page_low
     else "docs/install.md lacks %r or cannot be read" % (TERM_DEFINITION,))


# CODEX-04: prove the gates above can fail. Each case copies the repository files this script
# reads into a fresh temp directory, changes one thing, runs this file on the copy (a root
# argument turns this section off, so a copy run never recurses) and requires the named gates to
# print FAIL and the exit code to be 1. A mutation that changes nothing is itself a FAIL. The
# checkout is never written; the temp directory is removed in a finally.
def build_copy(dst):
    """Copy every tracked file, so the copy run (walk mode) scans what the checkout run (git
    mode) scans; the copy has no .git."""
    os.makedirs(dst, exist_ok=True)
    for rel in tracked_files(ROOT)[1]:
        src = os.path.join(ROOT, rel)
        if not os.path.lexists(src) or os.path.isdir(src):
            continue
        target = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copy2(src, target, follow_symlinks=False)


def run_copy(root):
    r = subprocess.run([sys.executable, "-I", os.path.abspath(__file__), root],
                       capture_output=True, text=True, timeout=60)
    return r.returncode, r.stdout


def edit_json(path, fn):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    fn(data)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def plant(dst, rel, line):
    """Append a line to dst/rel, creating the file and its directories when missing."""
    path = os.path.join(dst, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write("\n" + line + "\n")


def changelog_insert(dst, anchor, new_text, after):
    """Insert new_text directly after (after=True) or before the first CHANGELOG.md line that
    equals anchor."""
    path = os.path.join(dst, "CHANGELOG.md")
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.read().split("\n")
    i = lines.index(anchor) + (1 if after else 0)
    lines[i:i] = new_text.split("\n")
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write("\n".join(lines))


def read_bytes(path):
    try:
        with open(path, "rb") as f:
            return f.read()
    except OSError:
        return None


def mutation_case(name, rels, change, expect):
    """Run one mutation: rels are the files it touches, change(dst) edits the copy, expect lists
    the gate names (without the layout_ prefix) that must print FAIL; an empty list is the
    control: rc 0 and no FAIL line."""
    tmp = tempfile.mkdtemp(prefix="layoutmut.")
    try:
        dst = os.path.join(tmp, "copy")
        build_copy(dst)
        before = [read_bytes(os.path.join(dst, r)) for r in rels]
        change(dst)
        after = [read_bytes(os.path.join(dst, r)) for r in rels]
        if rels and before == after:
            gate("mutation_" + name, False, "the mutation changed nothing in %s" % (", ".join(rels),))
            return
        rc, out = run_copy(dst)
        fails = [ln for ln in out.splitlines() if " FAIL " in ln]
        if not expect:
            ok = rc == 0 and not fails
            detail = "the unchanged copy passes" if ok else "rc=%d first FAIL lines: %r" % (rc, fails[:2])
        else:
            missing = [g for g in expect if not any(ln.startswith("gate layout_%s FAIL" % g) for ln in fails)]
            ok = rc == 1 and not missing
            detail = ("gate layout_%s fails on the changed copy" % ", layout_".join(expect)) if ok else (
                "rc=%d missing FAIL for %r, first FAIL lines: %r" % (rc, missing, fails[:2]))
        gate("mutation_" + name, ok, detail)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as e:
        gate("mutation_" + name, False, "case error: %s" % (e,))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if len(sys.argv) == 1:
    CLAUDE_MANIFEST = "plugins/bbj/.claude-plugin/plugin.json"
    CODEX_MANIFEST = "plugins/bbj/.codex-plugin/plugin.json"
    CODEX_MCP_FILE = "plugins/bbj/.codex-mcp.json"
    SKILL_FILE = "plugins/bbj/skills/bbj-programming/SKILL.md"

    def set_overlay_version(dst):
        edit_json(os.path.join(dst, CODEX_MANIFEST), lambda d: d.update(version="9.9.9"))

    def slash_codex_url(dst):
        def fn(d):
            d["mcpServers"][DOCS_SERVER]["url"] += "/"
        edit_json(os.path.join(dst, CODEX_MCP_FILE), fn)

    def slash_default_url(dst):
        def fn(d):
            d["userConfig"]["docs_url"]["default"] += "/"
        edit_json(os.path.join(dst, CLAUDE_MANIFEST), fn)

    def host_in_third_file(dst):
        with open(os.path.join(dst, SKILL_FILE), "a", encoding="utf-8") as f:
            f.write("\nSee https://" + DOCS_HOST + "/mcp for the hosted server.\n")

    def delete_codex_mcp(dst):
        os.remove(os.path.join(dst, CODEX_MCP_FILE))

    def overlay_extra_key(dst):
        edit_json(os.path.join(dst, CODEX_MANIFEST), lambda d: d.update(skills="./skills/"))

    def codex_secret(dst):
        def fn(d):
            # the key name is assembled from two pieces (self-scan convention)
            d["mcpServers"][DOCS_SERVER]["oauth"] = {"clientId": OAUTH_CLIENT_ID,
                                                     "client" + "Secret": "not-a-real-value"}
        edit_json(os.path.join(dst, CODEX_MCP_FILE), fn)

    MCP_FILE = "plugins/bbj/.mcp.json"

    def mcp_scopes_missing(dst):
        def fn(d):
            d["mcpServers"][DOCS_SERVER]["oauth"].pop("scopes", None)
        edit_json(os.path.join(dst, MCP_FILE), fn)

    def codex_scopes_array(dst):
        def fn(d):
            d["mcpServers"][DOCS_SERVER]["oauth"]["scopes"] = [OAUTH_SCOPES]
        edit_json(os.path.join(dst, CODEX_MCP_FILE), fn)

    def docs_url_stage(dst):
        def fn(d):
            d["userConfig"]["docs_url"]["description"] += " It is the pre-" + "production instance."
        edit_json(os.path.join(dst, CLAUDE_MANIFEST), fn)

    HOOKS_FILE = "plugins/bbj/hooks/hooks.json"

    def drop_command_windows(dst):
        def fn(d):
            d["hooks"]["PostToolUse"][0]["hooks"][0].pop("commandWindows", None)
        edit_json(os.path.join(dst, HOOKS_FILE), fn)

    # phase 13: edit the commandWindows value of the copy with a string function (the mutation
    # must change it; mutation_case fails a change that changes nothing)
    def edit_windows(dst, fn):
        def edit(d):
            h = d["hooks"]["PostToolUse"][0]["hooks"][0]
            h["commandWindows"] = fn(h["commandWindows"])
        edit_json(os.path.join(dst, HOOKS_FILE), edit)

    # the automatic input variable, assembled from pieces (self-scan convention)
    AUTO_INPUT = "$" + "input"
    SILENT_EXIT = r'''if ($LASTEXITCODE -eq 0 -and -not ($o -notmatch "^[0-9]+:") -and -not ($o -match '(\*\*\* (Add File|Update File|Delete File|Move to): |"file_path"\s*:\s*")([^"\\]|\\[\\/]|\\u[0-9a-f]{4})*\.(bbj|src|bbx)(\\[nr]|")')) { exit 0 }'''
    NOT_FOUND_START = "if (-not $s) { $o = findstr"
    CALL_START = '& $s $b'

    def windows_input(dst):
        edit_windows(dst, lambda v: v.replace("$s = $null", "$s = $null; $x = @(" + AUTO_INPUT + ")", 1))

    def windows_method(dst):
        edit_windows(dst, lambda v: v.replace('cmd /c "(echo', "[Console]" + "::Error.Write" + "Line('x'); " + 'cmd /c "(echo', 1))

    def windows_short_name(dst):
        edit_windows(dst, lambda v: v.replace("$env:ProgramFiles,", "'C:\\" + "PROGRA" + "~1',", 1))

    def windows_passthrough(dst):
        def fn(v):
            i = v.rindex("exit $LASTEXITCODE")
            return v[:i] + "exit 0" + v[i + len("exit $LASTEXITCODE"):]
        edit_windows(dst, fn)

    def windows_order(dst):
        def fn(v):
            a = v.index(NOT_FOUND_START)
            b = v.index(CALL_START)
            cut = v[a:b]
            rest = v[:a] + v[b:]
            i = rest.rindex("exit $LASTEXITCODE")
            return rest[:i] + cut + rest[i:]
        edit_windows(dst, fn)

    def windows_silent_exit(dst):
        edit_windows(dst, lambda v: v.replace(SILENT_EXIT, 'if ($LASTEXITCODE -eq 1 -and -not $o) { exit 0 }', 1))

    # review WR-01: any sh on PATH is taken again, Git for Windows or not
    GIT_SH_TEST = r'if ($q -and -not $s -and ((Test-Path -LiteralPath "$q\usr\bin\cygpath.exe") -or (Test-Path -LiteralPath "$q\bin\cygpath.exe"))) { $s = $c.Source }'

    def windows_any_sh(dst):
        edit_windows(dst, lambda v: v.replace(GIT_SH_TEST, 'if (-not $s) { $s = $c.Source }', 1))

    # review WR-02: the per-user item is an unconditional expandable string again
    PER_USER = r'$(if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\Programs" } elseif ($env:USERPROFILE) { "$env:USERPROFILE\AppData\Local\Programs" })'

    # review WR-03: any mention of the three extensions counts again, patch text included
    NAME_MATCH = r'''-not ($o -match '(\*\*\* (Add File|Update File|Delete File|Move to): |"file_path"\s*:\s*")([^"\\]|\\[\\/]|\\u[0-9a-f]{4})*\.(bbj|src|bbx)(\\[nr]|")')'''

    def windows_any_mention(dst):
        edit_windows(dst, lambda v: v.replace(NAME_MATCH, r'-not ($o -match "\.(bbj|src|bbx)")', 1))

    # review WR-04: the plugin root is read from the substituted text only, inside a double-quoted
    # string, so PowerShell expands a $ or a backtick in it
    ROOT_FROM_ENV = r'$b = "$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"; if (-not $env:CLAUDE_PLUGIN_ROOT) { $b = "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh" }; & $s $b'

    def windows_root_text(dst):
        edit_windows(dst, lambda v: v.replace(ROOT_FROM_ENV, r'& $s "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"', 1))

    # review IN-02: the git-derived lookup fits cmd\git.exe only again
    MINGW_STEP = r"if ($q -and ((Split-Path -Leaf $q) -match '^(mingw|clang|ucrt)')) { $q = Split-Path -Parent $q }; "

    def windows_git_cmd_only(dst):
        edit_windows(dst, lambda v: v.replace(MINGW_STEP, "", 1))

    # review IN-03: ProgramW6432 is no longer looked at
    def windows_no_w6432(dst):
        edit_windows(dst, lambda v: v.replace("$env:ProgramW6432, ", "", 1))

    # review IN-04: the first echo of the not-found branch is written without parentheses again
    FIRST_ECHO = "(echo bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.)1>&2"

    def windows_trailing_space(dst):
        edit_windows(dst, lambda v: v.replace(FIRST_ECHO, FIRST_ECHO[1:].replace(".)1>&2", ". 1>&2"), 1))

    def windows_localappdata(dst):
        edit_windows(dst, lambda v: v.replace(PER_USER + ")", r'"$env:LOCALAPPDATA\Programs")', 1))


    mutation_case("control", [], lambda dst: None, [])
    mutation_case("overlay_version", [CODEX_MANIFEST], set_overlay_version, ["versions"])
    mutation_case("codex_url", [CODEX_MCP_FILE], slash_codex_url, ["codex_url_equals_default"])
    mutation_case("default_url", [CLAUDE_MANIFEST], slash_default_url, ["codex_url_equals_default"])
    mutation_case("host_elsewhere", [SKILL_FILE], host_in_third_file, ["docs_host_single_source"])
    mutation_case("codex_mcp_missing", [CODEX_MCP_FILE], delete_codex_mcp,
                  ["codex_overlay_fields", "codex_mcp"])
    mutation_case("overlay_extra_key", [CODEX_MANIFEST], overlay_extra_key, ["codex_overlay_fields"])
    mutation_case("codex_secret", [CODEX_MCP_FILE], codex_secret, ["codex_mcp"])
    mutation_case("hook_command_windows", [HOOKS_FILE], drop_command_windows, ["hook_command_windows"])
    mutation_case("hook_windows_input", [HOOKS_FILE], windows_input,
                  ["hook_command_windows", "hook_windows_safe"])
    mutation_case("hook_windows_method", [HOOKS_FILE], windows_method, ["hook_windows_safe"])
    mutation_case("hook_windows_short_name", [HOOKS_FILE], windows_short_name,
                  ["hook_windows_safe", "hook_windows_parts"])
    mutation_case("hook_windows_passthrough", [HOOKS_FILE], windows_passthrough, ["hook_windows_parts"])
    mutation_case("hook_windows_order", [HOOKS_FILE], windows_order, ["hook_windows_parts"])
    mutation_case("hook_windows_silent_exit", [HOOKS_FILE], windows_silent_exit,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_any_sh", [HOOKS_FILE], windows_any_sh,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_localappdata", [HOOKS_FILE], windows_localappdata,
                  ["hook_command_windows", "hook_windows_safe", "hook_windows_parts"])
    mutation_case("hook_windows_any_mention", [HOOKS_FILE], windows_any_mention,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_root_text", [HOOKS_FILE], windows_root_text,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_git_cmd_only", [HOOKS_FILE], windows_git_cmd_only,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_no_w6432", [HOOKS_FILE], windows_no_w6432,
                  ["hook_command_windows", "hook_windows_parts"])
    mutation_case("hook_windows_trailing_space", [HOOKS_FILE], windows_trailing_space,
                  ["hook_command_windows", "hook_windows_safe", "hook_windows_parts"])
    mutation_case("mcp_scopes_missing", [MCP_FILE], mcp_scopes_missing, ["bbj_mcp"])
    mutation_case("codex_scopes_array", [CODEX_MCP_FILE], codex_scopes_array, ["codex_mcp"])
    mutation_case("docs_url_stage", [CLAUDE_MANIFEST], docs_url_stage, ["docs_url_description"])
    mutation_case("retired_route_readme", ["README.md"],
                  lambda dst: plant(dst, "README.md", "Or run sh codex/" + RETIRED_SCRIPT + "."),
                  ["no_retired_route"])

    def file_back(dst):
        target = os.path.join(dst, "codex", RETIRED_SCRIPT)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        open(target, "w").close()

    CHANGELOG = "CHANGELOG.md"
    CHANGELOG_TITLE = "# Changelog"
    CLAUDE_MD = ".claude/CLAUDE.md"
    mutation_case("retired_route_file_back", ["codex/" + RETIRED_SCRIPT], file_back, ["no_retired_route"])
    INSTALL_PAGE = "docs/install.md"
    mutation_case("retired_route_word_capitalized", [INSTALL_PAGE],
                  lambda dst: plant(dst, INSTALL_PAGE,
                                    "The Codex " + RETIRED_WORD.capitalize() + " is gone."),
                  ["no_retired_route"])
    mutation_case("retired_route_conventions", [CLAUDE_MD],
                  lambda dst: plant(dst, CLAUDE_MD, "- see codex/" + RETIRED_SNIPPET + ".md"),
                  ["no_retired_route"])
    mutation_case("retired_route_test_comment", ["tests/lib.sh"],
                  lambda dst: plant(dst, "tests/lib.sh", "# the Codex " + RETIRED_WORD + " route"),
                  ["no_retired_route"])
    mutation_case("retired_route_changelog_preamble", [CHANGELOG],
                  lambda dst: changelog_insert(dst, CHANGELOG_TITLE,
                                               "Notes on the Codex " + RETIRED_WORD + ".", True),
                  ["no_retired_route"])
    mutation_case("retired_route_newer_entry", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "## 0.2.2\n\n- dropped the Codex " + RETIRED_WORD + ".\n", False),
                  ["no_retired_route"])
    # IN-03: the word matches as a word, also as a plural or inside snake_case, but not inside a
    # longer word
    mutation_case("retired_route_word_plural_snake", ["README.md"],
                  lambda dst: plant(dst, "README.md", "see the codex_" + RETIRED_WORD + "s list"),
                  ["no_retired_route"])
    mutation_case("retired_route_longer_word_exempt", ["README.md"],
                  lambda dst: plant(dst, "README.md", "the un" + RETIRED_WORD + " question"),
                  [])
    mutation_case("retired_route_history_exempt", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "- the Codex " + RETIRED_WORD + " (history).", True),
                  [])
    mutation_case("retired_route_planning_exempt", [".planning/notes.md"],
                  lambda dst: plant(dst, ".planning/notes.md", "the Codex " + RETIRED_WORD),
                  [])

    # NAME-01 (phase 12, D-02): a planted mention of the docs server's old name fails its gate
    mutation_case("old_server_name_readme", ["README.md"],
                  lambda dst: plant(dst, "README.md", "Sign in to the docs server " + OLD_SERVER_NAME + "."),
                  ["no_old_server_name"])

    def old_name_key(dst):
        def fn(d):
            d["mcpServers"] = {OLD_SERVER_NAME: d["mcpServers"][DOCS_SERVER]}
        edit_json(os.path.join(dst, MCP_FILE), fn)

    def old_name_path(dst):
        target = os.path.join(dst, "docs", OLD_SERVER_NAME + ".md")
        os.makedirs(os.path.dirname(target), exist_ok=True)
        open(target, "w").close()

    # the rename undone in the MCP file fails the key gate too
    mutation_case("old_server_name_key", [MCP_FILE], old_name_key, ["bbj_mcp", "no_old_server_name"])
    # case-insensitive
    mutation_case("old_server_name_capitalized", [INSTALL_PAGE],
                  lambda dst: plant(dst, INSTALL_PAGE,
                                    "Choose plugin:bbj:" + OLD_SERVER_NAME.title() + " in /mcp."),
                  ["no_old_server_name"])
    # a tool name the client builds (D-03)
    mutation_case("old_server_name_tool_name", [SKILL_FILE],
                  lambda dst: plant(dst, SKILL_FILE, "Call mcp__plugin_bbj_" + OLD_SERVER_NAME + "__bbj_search."),
                  ["no_old_server_name"])
    # no exemption for the conventions file or the tests (D-01)
    mutation_case("old_server_name_conventions", [CLAUDE_MD],
                  lambda dst: plant(dst, CLAUDE_MD, "- the hosted " + OLD_SERVER_NAME + " server"),
                  ["no_old_server_name"])
    mutation_case("old_server_name_test_comment", ["tests/lib.sh"],
                  lambda dst: plant(dst, "tests/lib.sh", "# plugin:bbj:" + OLD_SERVER_NAME),
                  ["no_old_server_name"])
    # a file whose path holds the name
    mutation_case("old_server_name_path", ["docs/" + OLD_SERVER_NAME + ".md"], old_name_path,
                  ["no_old_server_name"])
    # CHANGELOG: text above the first heading and a newer entry are scanned, 0.2.1 is exempt
    mutation_case("old_server_name_changelog_preamble", [CHANGELOG],
                  lambda dst: changelog_insert(dst, CHANGELOG_TITLE, "Sign in to " + OLD_SERVER_NAME + ".", True),
                  ["no_old_server_name"])
    mutation_case("old_server_name_newer_entry", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "## 0.2.2\n\n- the docs server " + OLD_SERVER_NAME + ".\n", False),
                  ["no_old_server_name"])
    mutation_case("old_server_name_history_exempt", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1", "- " + OLD_SERVER_NAME + " (history).", True),
                  [])
    mutation_case("old_server_name_planning_exempt", [".planning/notes.md"],
                  lambda dst: plant(dst, ".planning/notes.md", "the docs server " + OLD_SERVER_NAME),
                  [])
    # D-03: only the literal hyphenated name; planted in a test comment, outside shipped Markdown
    mutation_case("old_server_name_variants_exempt", ["tests/lib.sh"],
                  lambda dst: plant(dst, "tests/lib.sh",
                                    "# " + "bbj_" + "docs and " + "bbj" + "docs are other spellings"),
                  [])

    # DOCS-05 (phase 14, D-02): a mention of a removed install page fails its gate in each scope
    mutation_case("removed_page_readme", ["README.md"],
                  lambda dst: plant(dst, "README.md", "See docs/" + REMOVED_PAGES[1] + "."),
                  ["no_removed_pages"])
    # the page file back in the tree (a path hit), spelled in capitals: case-insensitive
    mutation_case("removed_page_file_back", ["docs/" + REMOVED_PAGES[0].upper() + ".md"],
                  lambda dst: plant(dst, "docs/" + REMOVED_PAGES[0].upper() + ".md", "# back"),
                  ["no_removed_pages"])
    # REVIEW IN-07: the anchor form of the Codex page (stem followed by #) is a hit too
    mutation_case("removed_page_anchor", ["README.md"],
                  lambda dst: plant(dst, "README.md", "See docs/" + REMOVED_PAGES[2] + "section."),
                  ["no_removed_pages"])
    mutation_case("removed_page_conventions", [CLAUDE_MD],
                  lambda dst: plant(dst, CLAUDE_MD, "- `docs/" + REMOVED_PAGES[0] + ".md` describes installation"),
                  ["no_removed_pages"])
    mutation_case("removed_page_newer_entry", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "## 0.2.2\n\n- [page](docs/" + REMOVED_PAGES[1] + ").\n", False),
                  ["no_removed_pages"])
    mutation_case("removed_page_history_exempt", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1", "- [page](docs/" + REMOVED_PAGES[1] + ") (history).", True),
                  [])
    mutation_case("removed_page_planning_exempt", [".planning/notes.md"],
                  lambda dst: plant(dst, ".planning/notes.md", "the page docs/" + REMOVED_PAGES[1]),
                  [])

    # NAME-04 (phase 14, D-10): a planted retired variant fails the term gate
    mutation_case("retired_term_readme", ["README.md"],
                  lambda dst: plant(dst, "README.md", "Use the " + TERM_VARIANTS[0] + " that exists."),
                  ["no_retired_terms"])
    WEB_SKILL = "plugins/bbj/skills/bbj-web-programming/SKILL.md"
    REFERENCE = "plugins/bbj/skills/bbj-programming/references/running.md"
    # encoding: capitals (D-10)
    mutation_case("retired_term_install_page_caps", [INSTALL_PAGE],
                  lambda dst: plant(dst, INSTALL_PAGE, "Run the " + TERM_VARIANTS[3].upper() + " SERVER."),
                  ["no_retired_terms"])
    # encoding: a non-breaking space between the two words
    mutation_case("retired_term_nbsp", ["README.md"],
                  lambda dst: plant(dst, "README.md", "Run the " + TERM_VARIANTS[4].replace(" ", "\u00a0") + "."),
                  ["no_retired_terms"])
    # adjacency: the two words split by a line break
    mutation_case("retired_term_wrapped", [WEB_SKILL],
                  lambda dst: plant(dst, WEB_SKILL, "Run the " + TERM_VARIANTS[4].replace(" ", "\n") + "."),
                  ["no_retired_terms"])
    # the sixth variant: the retired name of the plugin bbj-local (REVIEW IN-01)
    mutation_case("retired_term_bbj_local_server", ["README.md"],
                  lambda dst: plant(dst, "README.md", "Start " + TERM_VARIANTS[5] + " first."),
                  ["no_retired_terms"])
    # scope: a skill reference
    mutation_case("retired_term_reference", [REFERENCE],
                  lambda dst: plant(dst, REFERENCE, "Run the " + TERM_VARIANTS[2] + "."),
                  ["no_retired_terms"])
    # adjacency: a longer word or a verb form is not a hit
    mutation_case("retired_term_longer_word_exempt", ["README.md"],
                  lambda dst: plant(dst, "README.md",
                                    "Install from a local checkout; the compiler checks the files."),
                  [])
    # scope: a code line of the hook is scanned, a full-line comment is exempt
    mutation_case("retired_term_hook_string", [TERM_HOOK],
                  lambda dst: plant(dst, TERM_HOOK, '_route="' + TERM_VARIANTS[1] + '"'),
                  ["no_retired_terms"])
    mutation_case("retired_term_hook_comment_exempt", [TERM_HOOK],
                  lambda dst: plant(dst, TERM_HOOK, "# the " + TERM_VARIANTS[1]),
                  [])

    # scope: the description strings of a manifest, also a nested one
    def manifest_description(dst):
        def fn(d):
            d["description"] += " Not the " + TERM_VARIANTS[3] + "."
        edit_json(os.path.join(dst, CLAUDE_MANIFEST), fn)

    def docs_url_description(dst):
        def fn(d):
            d["userConfig"]["docs_url"]["description"] += " Not the " + TERM_VARIANTS[3] + "."
        edit_json(os.path.join(dst, CLAUDE_MANIFEST), fn)

    mutation_case("retired_term_manifest", [CLAUDE_MANIFEST], manifest_description, ["no_retired_terms"])
    mutation_case("retired_term_docs_url_description", [CLAUDE_MANIFEST], docs_url_description,
                  ["no_retired_terms"])

    # REVIEW WR-06: the sixth variant written without backticks, as a manifest description writes it
    def manifest_plain_sixth(dst):
        def fn(d):
            d["description"] += " Start " + TERM_VARIANTS[5].replace("`", "") + " first."
        edit_json(os.path.join(dst, CLAUDE_MANIFEST), fn)

    mutation_case("retired_term_bbj_local_server_plain", [CLAUDE_MANIFEST], manifest_plain_sixth,
                  ["no_retired_terms"])
    # D-08: the words "language server" only inside the definition
    mutation_case("language_server_outside_definition", [INSTALL_PAGE],
                  lambda dst: plant(dst, INSTALL_PAGE, "The " + LANGUAGE_SERVER + " answers."),
                  ["no_retired_terms"])
    mutation_case("language_server_definition_allowed", ["README.md"],
                  lambda dst: plant(dst, "README.md", TERM_DEFINITION),
                  [])
    # CHANGELOG: a newer entry is scanned, a 0.2.1 entry is exempt
    mutation_case("retired_term_newer_entry", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "## 0.2.2\n\n- the " + TERM_VARIANTS[0] + ".\n", False),
                  ["no_retired_terms"])
    mutation_case("retired_term_history_exempt", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1", "- the " + TERM_VARIANTS[0] + " (history).", True),
                  [])
    # D-10 exemptions: the conventions file (the term list names the variants), .planning/, tests/
    mutation_case("retired_term_claude_md_exempt", [CLAUDE_MD],
                  lambda dst: plant(dst, CLAUDE_MD, "- the " + TERM_VARIANTS[1]),
                  [])
    mutation_case("retired_term_planning_exempt", [".planning/notes.md"],
                  lambda dst: plant(dst, ".planning/notes.md", "the " + TERM_VARIANTS[0]),
                  [])
    mutation_case("retired_term_tests_exempt", ["tests/lib.sh"],
                  lambda dst: plant(dst, "tests/lib.sh", "# the " + TERM_VARIANTS[0]),
                  [])

    # empty input: a tree that lost a required scope file fails closed
    mutation_case("retired_terms_scope_missing", [INSTALL_PAGE],
                  lambda dst: os.remove(os.path.join(dst, INSTALL_PAGE)),
                  ["no_retired_terms"])

    # the positive gates fail when the list or the definition goes
    def term_list_missing(dst):
        path = os.path.join(dst, CLAUDE_MD)
        with open(path, encoding="utf-8", newline="") as f:
            lines = f.read().split("\n")
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write("\n".join(ln for ln in lines if TERM_VARIANTS[0] not in ln.lower()))

    def term_definition_missing(dst):
        path = os.path.join(dst, INSTALL_PAGE)
        with open(path, encoding="utf-8", newline="") as f:
            text = f.read()
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(text.replace(TERM_DEFINITION, "`bbj-ls`"))

    mutation_case("term_list_missing", [CLAUDE_MD], term_list_missing, ["term_list"])
    mutation_case("term_definition_missing", [INSTALL_PAGE], term_definition_missing, ["term_definition"])

sys.exit(1 if failed else 0)
