"""tests/test_layout.py -- plan 19-03: pins every manifest value the requirements fix.
Plan 01-01 (VEND-01, VEND-03): the skills are ordinary repository files; the hosted-host rule
covers them (D-02) and the lock and hash test stay removed.
Quick 261013-cpn: the bbj-docs entry carries the pre-registered OAuth client, pinned in both
MCP files (layout_bbj_mcp, layout_codex_mcp).
Phase 8 (CODEX-01, CODEX-04; D-10, D-11, D-13): pins the Codex overlay
plugins/bbj/.codex-plugin/plugin.json and its literal-URL file plugins/bbj/.codex-mcp.json.
Plan 10-02 (D-05, D-16): both MCP files ask for offline_access as a string; the docs_url
description calls the default the hosted BBj docs server and names no stage of a release.
Phase 11 (INST-02; D-10 to D-12): layout_no_retired_route scans every tracked file outside
.planning/ (git ls-files, or a walk of a mutation copy) for the retired Codex route, CHANGELOG
entries up to 0.2.1 exempt; the layout_mutation_retired_route_* cases plant a mention in each
scope and in each exemption.
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

VERSION = "0.2.1"
DOCS_HOST = "mcp.bbj-ai.com"
DOCS_DEFAULT = "https://" + DOCS_HOST + "/mcp"
OAUTH_CLIENT_ID = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"
OAUTH_PORT = 47613
OAUTH_SCOPES = "offline_access"
HOOK_COMMAND = 'sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"'
# D-11 of phase 9: Codex's Windows override of the hook command, as the owner chose it for W-1 (the
# 8.3 path of Git for Windows' sh.exe, unquoted, because Codex starts the hook through Windows
# PowerShell where sh is not on the PATH and where a quoted first token is a parse error; the
# trailing exit keeps exit code 2, which a PowerShell -Command wrapper rewrites to 1). This pins
# text, not behaviour: PowerShell cannot run in CI. The plan 09-06 re-run on Windows shows it works.
HOOK_COMMAND_WINDOWS = 'C:\\PROGRA~1\\Git\\bin\\sh.exe "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"; exit $LASTEXITCODE'
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
     servers == {"bbj-docs": {"type": "http", "url": "${user_config.docs_url}",
                              "oauth": {"clientId": OAUTH_CLIENT_ID,
                                        "callbackPort": OAUTH_PORT,
                                        "scopes": OAUTH_SCOPES}}},
     "mcpServers=%r" % (servers,))

# D-11: the Codex file registers bbj-docs at the literal docs URL. Plan 08-08 (owner decision
# "signin: add-block", 2026-10-13): without a pre-registered client the hosted server refuses
# dynamic client registration on the plugin route, so the file carries the public client id and
# the registered loopback callback, the object the Linux owner pass signed in with. Dict equality
# also rejects any extra key such as a client secret, header or token.
codex_servers = codex_mcp.get("mcpServers", {})
gate("codex_mcp",
     codex_servers == {"bbj-docs": {"type": "http", "url": DOCS_DEFAULT,
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
codex_url = codex_servers.get("bbj-docs", {}).get("url") if isinstance(codex_servers, dict) else None
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
        if term.lower() in low_rel:
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
        if term.lower() in low:
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
            d["mcpServers"]["bbj-docs"]["url"] += "/"
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
            d["mcpServers"]["bbj-docs"]["oauth"] = {"clientId": OAUTH_CLIENT_ID,
                                                    "client" + "Secret": "not-a-real-value"}
        edit_json(os.path.join(dst, CODEX_MCP_FILE), fn)

    MCP_FILE = "plugins/bbj/.mcp.json"

    def mcp_scopes_missing(dst):
        def fn(d):
            d["mcpServers"]["bbj-docs"]["oauth"].pop("scopes", None)
        edit_json(os.path.join(dst, MCP_FILE), fn)

    def codex_scopes_array(dst):
        def fn(d):
            d["mcpServers"]["bbj-docs"]["oauth"]["scopes"] = [OAUTH_SCOPES]
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
    mutation_case("retired_route_word_capitalized", ["docs/install-claude-code.md"],
                  lambda dst: plant(dst, "docs/install-claude-code.md",
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
    mutation_case("retired_route_history_exempt", [CHANGELOG],
                  lambda dst: changelog_insert(dst, "## 0.2.1",
                                               "- the Codex " + RETIRED_WORD + " (history).", True),
                  [])
    mutation_case("retired_route_planning_exempt", [".planning/notes.md"],
                  lambda dst: plant(dst, ".planning/notes.md", "the Codex " + RETIRED_WORD),
                  [])

sys.exit(1 if failed else 0)
