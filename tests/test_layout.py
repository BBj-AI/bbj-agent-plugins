"""tests/test_layout.py -- plan 19-03: pins every manifest value the requirements fix.
Plan 01-01 (VEND-01, VEND-03): the skills are ordinary repository files; the hosted-host rule
covers them (D-02) and the lock and hash test stay removed.

stdlib only, run by tests/run.sh with python3 -I. Prints one line per assertion,
    gate layout_<name> ok|FAIL <detail>
and exits 1 when any gate failed. An optional argv[1] is the repository root to check
(default: the parent of the tests directory); the mutation check points it at a copy.
Nothing here runs BBj code or touches a Claude Code configuration.
"""
import glob
import json
import os
import subprocess
import sys

ROOT = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))

VERSION = "0.1.0"
DOCS_HOST = "mcp.bbj-ai.com"
DOCS_DEFAULT = "https://" + DOCS_HOST + "/mcp"
HOOK_COMMAND = 'sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"'
LOCAL_URL = "http://127.0.0.1:5009/mcp"
# assembled from pieces so this file never names what it searches for (self-scan convention)
LOCK_NAME = "skills" + ".lock.json"
HASH_TEST = "test_sk" + "ills_hash"
VEND_WORD = "vend" + "or"
UPSTREAM_NAME = "bbj" + "skills"

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

entries = {e.get("name"): e for e in market.get("plugins", []) if isinstance(e, dict)}

# marketplace: name, exactly the two entries, sources exist
sources_ok = all(os.path.isdir(os.path.join(ROOT, e.get("source", "?")))
                 for e in entries.values())
gate("marketplace_entries",
     market.get("name") == "basis-bbj" and sorted(entries) == ["bbj", "bbj-local"]
     and len(market.get("plugins", [])) == 2 and sources_ok,
     "name=%r entries=%r sources_exist=%s" % (market.get("name"), sorted(entries), sources_ok))

# versions: two plugin.json and both marketplace entries, all 0.1.0
versions = [bbj.get("version"), local.get("version"),
            entries.get("bbj", {}).get("version"), entries.get("bbj-local", {}).get("version")]
gate("versions", all(v == VERSION for v in versions), "versions=%r want all %s" % (versions, VERSION))

# licence
gate("license", bbj.get("license") == "Apache-2.0" and local.get("license") == "Apache-2.0",
     "bbj=%r bbj-local=%r" % (bbj.get("license"), local.get("license")))

# bbj .mcp.json: exactly one http server at ${user_config.docs_url}
servers = bbj_mcp.get("mcpServers", {})
gate("bbj_mcp", servers == {"bbj-docs": {"type": "http", "url": "${user_config.docs_url}"}},
     "mcpServers=%r" % (servers,))

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

# hooks.json: matcher, one command hook, exact command, timeout
post = hooks.get("hooks", {}).get("PostToolUse", [])
hook_list = post[0].get("hooks", []) if len(post) == 1 else []
gate("hook_matcher", len(post) == 1 and post[0].get("matcher") == "Write|Edit",
     "PostToolUse=%r" % (post,))
gate("hook_command",
     len(hook_list) == 1 and hook_list[0].get("type") == "command"
     and hook_list[0].get("command") == HOOK_COMMAND,
     "hooks=%r" % (hook_list,))
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

# the hosted host name occurs once under plugins/ (the skills included, D-02)
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
gate("docs_host_single_source", hits == ["plugins/bbj/.claude-plugin/plugin.json"],
     "files naming %s: %r" % (DOCS_HOST, sorted(hits)))

# VEND-01: the lock file and the hash test are gone and nothing names them
gone = [n for n in (LOCK_NAME, os.path.join("tests", HASH_TEST + ".py"))
        if os.path.exists(os.path.join(ROOT, n))]
scan = []
for pattern in ("tests/*.sh", "tests/*.py", "codex/*.sh", "plugins/bbj/scripts/*.sh",
                ".github/workflows/*.yml", "README.md", "NOTICE", "docs/*.md",
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
# CHANGELOG.md is not read: its never-tagged 0.1.0 entry keeps its historical wording.
texts = ["README.md", "NOTICE", ".claude-plugin/marketplace.json",
         "plugins/bbj/.claude-plugin/plugin.json", "plugins/bbj-local/.claude-plugin/plugin.json"]
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

sys.exit(1 if failed else 0)
