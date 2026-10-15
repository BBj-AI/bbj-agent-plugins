#!/bin/sh
# .planning/phases/12-docs-server-renamed-to-bbj/signin-run/run.sh -- plan 12-02 (NAME-02, SC4; D-08 to
# D-11): real Claude Code and real Codex sign-in readings for the docs server, in throwaway homes. A
# cut-down re-base of the Phase 10 harness (.planning/milestones/v0.2.1-phases/10-install-wording-and-
# release-0-2-1/codex-run/run.sh). Evidence for the phase record, never CI: CI has no Codex, and nothing
# here is a gate.
#
# Safety rules (threats T-12-03 and T-12-04):
#   - never runs BBj and calls no compiler: the scenarios only install the plugin from the checkout and
#     read what the two clients list;
#   - never touches the real ~/.codex, ~/.agents or ~/.claude: safe_out refuses any OUTDIR outside
#     $HOME/.cache/bbj-phase12/ (and anything under /tmp, the real ~/.codex, ~/.agents or ~/.claude, a
#     path with .., or a relative path); HOME, CODEX_HOME and CLAUDE_CONFIG_DIR point into OUTDIR for
#     every client call;
#   - never under /tmp (Codex refuses its helper binaries there);
#   - never completes a sign-in: codex mcp login is killed after 25 s; the owner signs in with owner.sh;
#   - never prints an authorization URL, a state, a PKCE value or a token: the login reader prints only
#     the client id and the redirect URI, the credentials readers print key paths with set or empty
#     (values only for serverName, serverUrl, server_url, scope and scopes), and every value that
#     reaches result.txt goes through scrub (the checkout, the home and the run directory become
#     <checkout>, <home> and <out>).
#
# Usage: sh run.sh SCENARIO [ARG]
#   selftest              prove safe_out refuses /tmp, ~/.codex, ~/.claude, ~/elsewhere, <base>/../x
#                         and a relative path
#   realhome FILE         one line per file: <name> <cksum> or <name> absent, for the real Codex
#                         config.toml and the two plugin files of the Claude Code configuration; no
#                         file content is read beyond cksum; FILE must be below $HOME/.cache/bbj-phase12/
#   codex OUTDIR          fresh Codex home, plugin installed from the checkout, the labels Codex
#                         lists, whether codex mcp login starts for the listed name
#   claude OUTDIR         fresh Claude Code configuration and project, plugin installed from the
#                         checkout, the label claude mcp list shows, the OAuth settings claude mcp get shows
#   status                read-only: the codex mcp list and claude mcp list lines of the two prepared
#                         homes, printed as cx_status: and cc_status:
#   after                 keep mode on both homes: the lines and credential key paths after the sign-in
# Output: OUTDIR/result.txt (key: value lines) and raw files beside it; not committed.
# Exit codes: 0 the scenario ran to the end, 1 a client command failed (its last line is in
# result.txt), 2 a refused OUTDIR or a usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
REALHOME=$HOME
BASE=$REALHOME/.cache/bbj-phase12
DOCS_URL=https://mcp.bbj-ai.com/mcp
OUT=

# refuse DIR WHY: exit 2 with the fixed message
refuse() {
  echo "run.sh: refused OUTDIR $1 ($2)" >&2
  exit 2
}

# safe_out DIR [keep]: the absolute path must be below $HOME/.cache/bbj-phase12/; then it is recreated.
# With keep the same checks run, nothing is deleted and DIR must already exist.
# The rm -rf runs after every check, inside the approved prefix only.
safe_out() {
  case $1 in
    /*) ;;
    *) refuse "$1" "not an absolute path" ;;
  esac
  case $1 in
    /tmp | /tmp/*) refuse "$1" "under /tmp" ;;
    "$REALHOME"/.codex | "$REALHOME"/.codex/*) refuse "$1" "under the real ~/.codex" ;;
    "$REALHOME"/.agents | "$REALHOME"/.agents/*) refuse "$1" "under the real ~/.agents" ;;
    "$REALHOME"/.claude | "$REALHOME"/.claude/*) refuse "$1" "under the real ~/.claude" ;;
    */.. | */../*) refuse "$1" "contains .." ;;
  esac
  case $1 in
    "$BASE"/?*) ;;
    *) refuse "$1" "outside $BASE/" ;;
  esac
  if [ "${2:-}" = keep ]; then
    [ -d "$1" ] || refuse "$1" "keep mode needs an existing directory"
    return 0
  fi
  rm -rf "$1" && mkdir -p "$1"
}

# scrub TEXT: print TEXT with the run directory, the checkout and the home directory replaced by
# <out>, <checkout> and <home> (in that order, as fixed strings: index/substr, never a regex)
scrub() {
  S_TEXT=$1 S_OUT=$OUT S_REPO=$REPO S_HOME=$REALHOME awk '
    function rep(s, from, to,    done, i) {
      if (from == "") return s
      done = ""
      while ((i = index(s, from)) > 0) {
        done = done substr(s, 1, i - 1) to
        s = substr(s, i + length(from))
      }
      return done s
    }
    BEGIN {
      t = ENVIRON["S_TEXT"]
      t = rep(t, ENVIRON["S_OUT"], "<out>")
      t = rep(t, ENVIRON["S_REPO"], "<checkout>")
      t = rep(t, ENVIRON["S_HOME"], "<home>")
      print t
    }'
}

# res KEY VALUE: one evidence line in OUT/result.txt; the value is scrubbed and kept on one line
res() {
  _v=$(scrub "$2" | tr '\n' ' ' | sed 's/ *$//')
  printf '%s: %s\n' "$1" "$_v" >> "$OUT/result.txt"
}

# stamp: UTC time for the result lines
stamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# begin DIR [keep]: safe_out, then OUT
begin() {
  safe_out "$1" "${2:-}" || exit 2
  OUT=$1
}

# must LABEL CMD...: run a client command; on failure record its last output line and exit 1
must() {
  _l=$1
  shift
  if "$@" >> "$OUT/setup.txt" 2>&1; then
    return 0
  fi
  res "${_l}_error" "$(tail -n 1 "$OUT/setup.txt")"
  res status "failed at $_l"
  exit 1
}

# cx ARGS...: codex with the throwaway home of OUT, for this call only
cx() {
  env HOME="$OUT/home" CODEX_HOME="$OUT/home/.codex" codex "$@"
}

# cc ARGS...: claude with the throwaway configuration of OUT, for this call only. The session
# variables of a parent Claude Code are removed so the child behaves as a fresh CLI.
cc() {
  env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID \
    HOME="$OUT/home" CLAUDE_CONFIG_DIR="$OUT/cfg" CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1 claude "$@"
}

# cx_line: the squeezed `codex mcp list` line that holds the docs URL, found by URL, not by name
cx_line() {
  cx mcp list 2> /dev/null | awk -v u="$DOCS_URL" 'index($0, u) { $1 = $1; print; exit }'
}

# cc_line: the `claude mcp list` line that holds the docs URL (run in the empty project folder)
cc_line() {
  (cd "$OUT/proj" && cc mcp list 2> /dev/null) | grep -F "$DOCS_URL" | head -n 1
}

# cc_label LINE: the part of a claude mcp list line before ": <docs url>"
cc_label() {
  printf '%s\n' "$1" | awk -v u=": $DOCS_URL" '{ i = index($0, u); if (i > 0) { print substr($0, 1, i - 1); exit } }'
}

# creds_cc FILE: key paths of the Claude Code mcpOAuth entries whose serverUrl is the docs URL, with
# the value set or empty; the values of serverName, serverUrl, scope and scopes are printed
creds_cc() {
  python3 -I -c '
import json, sys
path, url = sys.argv[1], sys.argv[2]
SHOWN = ("serverName", "serverUrl", "server_url", "scope", "scopes")
try:
    data = json.load(open(path))
except FileNotFoundError:
    print("absent")
    sys.exit(0)
except Exception:
    print("unreadable")
    sys.exit(0)
out = []
def walk(node, trail):
    if isinstance(node, dict):
        for key, value in node.items():
            if key in SHOWN and isinstance(value, (str, list)):
                shown = " ".join(value) if isinstance(value, list) else value
                out.append("%s.%s=%s" % (trail, key, shown))
            else:
                walk(value, "%s.%s" % (trail, key))
    elif isinstance(node, list):
        for i, value in enumerate(node):
            walk(value, "%s[%d]" % (trail, i))
    else:
        out.append("%s=%s" % (trail, "set" if node not in ("", None) else "empty"))
entries = data.get("mcpOAuth", {}) if isinstance(data, dict) else {}
for entry in entries.values():
    if isinstance(entry, dict) and entry.get("serverUrl") == url:
        walk(entry, "mcpOAuth[%s]" % entry.get("serverName", "?"))
print("; ".join(out) if out else "no mcpOAuth entry for the docs URL")
' "$1" "$DOCS_URL"
}

# creds_cx FILE: key paths of the Codex credentials file with the value set or empty; the values of
# serverName, serverUrl, server_url, scope and scopes are printed
creds_cx() {
  python3 -I -c '
import json, sys
path = sys.argv[1]
SHOWN = ("serverName", "serverUrl", "server_url", "scope", "scopes")
try:
    data = json.load(open(path))
except FileNotFoundError:
    print("absent")
    sys.exit(0)
except Exception:
    print("unreadable")
    sys.exit(0)
out = []
def walk(node, trail):
    if isinstance(node, dict):
        for key, value in node.items():
            if key in SHOWN and isinstance(value, (str, list)):
                shown = " ".join(value) if isinstance(value, list) else value
                out.append("%s.%s=%s" % (trail, key, shown))
            else:
                walk(value, "%s.%s" % (trail, key))
    elif isinstance(node, list):
        for i, value in enumerate(node):
            walk(value, "%s[%d]" % (trail, i))
    else:
        out.append("%s=%s" % (trail, "set" if node not in ("", None) else "empty"))
walk(data, "credentials")
print("; ".join(out) if out else "empty file")
' "$1"
}

scenario_selftest() {
  _n=0
  (safe_out /tmp/bbj-phase12-selftest) 2> /dev/null && _n=1
  (safe_out "$REALHOME/.codex/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/.claude/x") 2> /dev/null && _n=1
  (safe_out "$REALHOME/elsewhere") 2> /dev/null && _n=1
  (safe_out "$BASE/../x") 2> /dev/null && _n=1
  (safe_out "relative") 2> /dev/null && _n=1
  if [ "$_n" = 0 ]; then
    echo "selftest ok"
    return 0
  fi
  echo "selftest FAIL: a refused path was accepted" >&2
  return 1
}

scenario_realhome() {
  [ -n "$1" ] || { echo "run.sh: realhome needs a FILE" >&2; exit 2; }
  case $1 in
    "$BASE"/?*) ;;
    *) refuse "$1" "outside $BASE/" ;;
  esac
  case $1 in
    */.. | */../*) refuse "$1" "contains .." ;;
  esac
  mkdir -p "$BASE"
  _cfg=${CLAUDE_CONFIG_DIR:-$REALHOME/.claude}
  : > "$1"
  for _pair in \
    "codex_config.toml|$REALHOME/.codex/config.toml" \
    "cc_installed_plugins.json|$_cfg/plugins/installed_plugins.json" \
    "cc_known_marketplaces.json|$_cfg/plugins/known_marketplaces.json"; do
    _name=${_pair%%|*}
    _file=${_pair#*|}
    if [ -f "$_file" ]; then
      printf '%s %s\n' "$_name" "$(cksum < "$_file")" >> "$1"
    else
      printf '%s absent\n' "$_name" >> "$1"
    fi
  done
  echo "run.sh: wrote $1 ($(wc -l < "$1") lines)"
}

scenario_codex() {
  begin "$1"
  mkdir -p "$OUT/home/.codex" "$OUT/proj"
  res cx_run "$(stamp)"
  res cx_version "$(codex --version)"
  res cx_checkout "$(git -C "$REPO" rev-parse --short HEAD)"
  must cx_marketplace_add cx plugin marketplace add "$REPO"
  must cx_plugin_add cx plugin add bbj@basis-bbj
  _line=$(cx_line)
  res cx_list_line "${_line:-dropped}"
  _name=$(printf '%s\n' "$_line" | awk '{ print $1 }')
  res cx_server_name "${_name:-dropped}"
  if [ -z "$_name" ]; then
    res status "the docs server is not listed by codex mcp list"
    exit 1
  fi
  # never completes a sign-in: the login waits for a browser callback and is killed after 25 s
  timeout 25 env HOME="$OUT/home" CODEX_HOME="$OUT/home/.codex" codex mcp login "$_name" \
    > "$OUT/login.txt" 2>&1 < /dev/null
  res cx_login_rc "$?"
  python3 -I -c '
import re, sys
from urllib.parse import parse_qs, urlparse
text = open(sys.argv[1], errors="replace").read()
for url in re.findall(r"https?://[^\s\"<>]+", text):
    query = parse_qs(urlparse(url).query)
    if "client_id" in query:
        # state and PKCE values are never printed; only the public client id and redirect URI
        print("cx_login_started: yes")
        print("cx_login_client_id: " + query["client_id"][0])
        print("cx_login_redirect_uri: " + query.get("redirect_uri", ["<none>"])[0])
        sys.exit(0)
lines = [l.strip() for l in text.splitlines() if l.strip()]
print("cx_login_started: no")
print("cx_login_error: " + (lines[0] if lines else "no output"))
' "$OUT/login.txt" >> "$OUT/result.txt"
  res cx_done yes
}

scenario_claude() {
  begin "$1"
  mkdir -p "$OUT/home" "$OUT/cfg"
  git init -q "$OUT/proj"
  res cc_run "$(stamp)"
  res cc_version "$(claude --version)"
  res cc_checkout "$(git -C "$REPO" rev-parse --short HEAD)"
  must cc_marketplace_add cc plugin marketplace add "$REPO"
  must cc_install cc plugin install bbj@basis-bbj
  _line=$(cc_line)
  res cc_list_line "${_line:-dropped}"
  _label=$(cc_label "$_line")
  res cc_list_label "${_label:-dropped}"
  if [ -z "$_label" ]; then
    res status "the docs server is not listed by claude mcp list"
    exit 1
  fi
  _get=$( (cd "$OUT/proj" && cc mcp get "$_label") 2>&1)
  if printf '%s\n' "$_get" | grep -i 'oauth' | grep 'client_id configured' | grep 'callback_port 47613' > /dev/null; then
    res cc_get_oauth yes
  else
    res cc_get_oauth no
  fi
  res cc_done yes
}

scenario_status() {
  safe_out "$BASE/codex" keep
  safe_out "$BASE/claude" keep
  [ -f "$BASE/codex/result.txt" ] && [ -f "$BASE/claude/result.txt" ] || {
    echo "run.sh: status needs $BASE/codex/result.txt and $BASE/claude/result.txt (run codex and claude first)" >&2
    exit 2
  }
  OUT=$BASE/codex
  _cx=$(cx_line)
  OUT=$BASE/claude
  _cc=$(cc_line)
  scrub "cx_status: ${_cx:-not listed}"
  scrub "cc_status: ${_cc:-not listed}"
}

scenario_after() {
  safe_out "$BASE/codex" keep
  safe_out "$BASE/claude" keep
  OUT=$BASE/codex
  res cx_after_run "$(stamp)"
  res cx_after_line "$(cx_line)"
  res cx_credentials "$(creds_cx "$OUT/home/.codex/.credentials.json")"
  OUT=$BASE/claude
  res cc_after_run "$(stamp)"
  res cc_after_line "$(cc_line)"
  res cc_credentials "$(creds_cc "$OUT/cfg/.credentials.json")"
  echo "run.sh: appended the after readings to $BASE/codex/result.txt and $BASE/claude/result.txt"
}

case ${1:-} in
  selftest) scenario_selftest ;;
  realhome) scenario_realhome "${2:-}" ;;
  status) scenario_status ;;
  after) scenario_after ;;
  codex | claude)
    [ -n "${2:-}" ] || { echo "run.sh: $1 needs an OUTDIR" >&2; exit 2; }
    case $1 in
      codex) scenario_codex "$2" ;;
      claude) scenario_claude "$2" ;;
    esac ;;
  *)
    echo "usage: sh run.sh selftest | realhome FILE | codex OUTDIR | claude OUTDIR | status | after" >&2
    exit 2 ;;
esac
