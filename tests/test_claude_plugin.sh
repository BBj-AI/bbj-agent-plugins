#!/bin/sh
# tests/test_claude_plugin.sh -- plan 19-03: the Claude Code plugin end to end.
#
#   1. claude plugin validate --strict on the marketplace root and on the plugins
#   2. install bbj@basis-bbj from the LOCAL directory marketplace into a throwaway
#      CLAUDE_CONFIG_DIR; the user's own configuration is never touched
#   3. claude mcp get shows the OAuth client of the plugin's docs server bbj; claude mcp list
#      lists it under the label CC_LABEL holds, answering, connected or with its OAuth challenge "Needs authentication"
#      (skip when the host is unreachable; quick 261013-cpn)
#   4. the command string of hooks.json, run with sh -c under a plugin root whose path
#      contains a space, exits 2 on a bad .bbj and 0 silently on a clean one
#
# Without the claude CLI the test prints skip gates and exits 0. Nothing here runs BBj
# code: the only compiler call is bbjcpl -t -N -X inside the hook script.
. "$(dirname "$0")/lib.sh"

if ! command -v claude > /dev/null 2>&1; then
  gate claude_cli skip "claude is not installed on this host (CI installs it)"
  exit 0
fi

REAL_BEFORE=$(claude plugin list 2>&1)
mkwork
CFG=$WORK/cfg
mkdir "$CFG"
DOCS_HOST=mcp.bbj-ai.com
# the docs server's key in plugins/bbj/.mcp.json (NAME-01, phase 12)
DOCS_SERVER=bbj
# the label Claude Code lists for the docs server, as real Claude Code shows it; phase 12 aligns it with the label of its Linux sign-in record (D-08, D-09)
CC_LABEL='plugin:bbj:bbj'

# cc ARGS...: run claude with the throwaway configuration directory, for this call only.
cc() {
  CLAUDE_CONFIG_DIR=$CFG claude "$@"
}

# ---- 1. validate --strict ----------------------------------------------------------
for p in . plugins/bbj plugins/bbj-local; do
  tag=$(printf "%s" "$p" | tr -c "A-Za-z0-9" "_"); [ "$p" = . ] && tag=root
  if [ ! -e "$REPO/$p" ]; then
    gate "validate_$tag" FAIL "$p does not exist"
    continue
  fi
  out=$(cd "$REPO" && cc plugin validate --strict "$p" 2>&1)
  rc=$?
  if [ "$rc" = 0 ] && ! printf '%s\n' "$out" | grep -i -E 'warning|error' > /dev/null; then
    gate "validate_$tag" ok "claude plugin validate --strict $p"
  else
    gate "validate_$tag" FAIL "exit $rc: $(printf '%s' "$out" | head -n 3 | tr '\n' ' ')"
  fi
done

# ---- 2. install from the local marketplace into the throwaway config ---------------
out=$(cc plugin marketplace add "$REPO" 2>&1)
rc=$?
[ "$rc" = 0 ] && gate marketplace_add ok "local directory marketplace" \
  || gate marketplace_add FAIL "exit $rc: $(printf '%s' "$out" | head -n 2 | tr '\n' ' ')"

out=$(cc plugin install bbj@basis-bbj 2>&1)
rc=$?
[ "$rc" = 0 ] && gate install_bbj ok "bbj@basis-bbj installed" \
  || gate install_bbj FAIL "exit $rc: $(printf '%s' "$out" | head -n 2 | tr '\n' ' ')"

# plugin_state NAME: prints "enabled" or "disabled" for the plugin named NAME in
# `claude plugin list`, or nothing when it is not listed. Observed format (Claude Code
# 2.1.294): a "bbj@basis-bbj" line followed by indented lines "Version: ...",
# "Scope: user" and "Status: <symbol> enabled|disabled".
plugin_state() {
  cc plugin list 2> /dev/null | awk -v n="$1@basis-bbj" '
    index($0, n) { found = 1; next }
    found && /enabled|disabled/ { if ($0 ~ /disabled/) print "disabled"; else print "enabled"; exit }
    found && /@/ { exit }'
}

state=$(plugin_state bbj)
[ "$state" = enabled ] && gate list_bbj_enabled ok "bbj is enabled" \
  || gate list_bbj_enabled FAIL "bbj state: '${state:-not listed}'"

# ---- bbj-local installs disabled, bbj stays enabled ---------------------------------
out=$(cc plugin install bbj-local@basis-bbj 2>&1)
rc=$?
[ "$rc" = 0 ] && gate install_bbj_local ok "bbj-local@basis-bbj installed" \
  || gate install_bbj_local FAIL "exit $rc: $(printf '%s' "$out" | head -n 2 | tr '\n' ' ')"
state=$(plugin_state bbj-local)
[ "$state" = disabled ] && gate list_bbj_local_disabled ok "bbj-local is disabled" \
  || gate list_bbj_local_disabled FAIL "bbj-local state: '${state:-not listed}'"
state=$(plugin_state bbj)
[ "$state" = enabled ] && gate list_bbj_still_enabled ok "bbj still enabled" \
  || gate list_bbj_still_enabled FAIL "bbj state: '${state:-not listed}'"

# ---- 3. the plugin's docs server --------------------------------------------------
# The client settings reach Claude Code: this reads configuration only, so it needs no
# network (quick 261013-cpn). claude mcp get prints "client_id configured", never the id
# itself, so the value is pinned only by layout_bbj_mcp (tests/test_layout.py); here a missing
# or empty client id would print something else and fail.
_get=$(cd "$WORK" && cc mcp get "$CC_LABEL" 2>&1)
if printf '%s\n' "$_get" | grep -i 'oauth' | grep 'client_id configured' | grep 'callback_port 47613' > /dev/null; then
  gate mcp_docs_oauth ok "claude mcp get shows client_id configured and callback_port 47613 (the id itself is pinned by layout_bbj_mcp)"
else
  gate mcp_docs_oauth FAIL "$(printf '%s' "$_get" | head -n 8 | tr '\n' ' ')"
fi

# The hosted docs server asks for an OAuth sign-in, so a throwaway configuration that never
# signed in shows "Needs authentication": the server answered with its OAuth challenge.
# Before quick 261013-cpn this was the suite's one FAIL. mcp_docs_oauth above proves that
# the client settings reach Claude Code. Any HTTP 401 gives "Needs authentication" (a wrong
# client id, a proxy), so this gate proves only that something answers; it is weaker than the
# connected check it replaced, by design: CI has no sign-in (IN-05). "Disconnected" does not match.
if curl -s -o /dev/null --connect-timeout 3 "https://$DOCS_HOST/mcp" 2> /dev/null; then
  mcp=$(cd "$WORK" && cc mcp list 2>&1)
  # the URL is the primary match and the label is pinned separately, so a change of the
  # "label: url" separator between Claude Code versions (WR-02) does not fail this gate
  _line=$(printf '%s\n' "$mcp" | grep -F "https://$DOCS_HOST/mcp" | grep -F "$CC_LABEL" | grep -i -e '[[:space:]]connected' -e 'needs authentication' | grep -i -v 'fail')
  if [ -n "$_line" ]; then
    gate mcp_docs_answers ok "the docs server $DOCS_SERVER at https://$DOCS_HOST/mcp answered (nothing past the 401 challenge is proven): $(printf '%s' "$_line" | head -n 1)"
  else
    gate mcp_docs_answers FAIL "$(printf '%s' "$mcp" | head -n 6 | tr '\n' ' ')"
  fi
else
  gate mcp_docs_answers skip "$DOCS_HOST is not reachable from this host"
fi

# ---- 4. the hook command from hooks.json, through a root with a space --------------
BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}
HOOKS=$REPO/plugins/bbj/hooks/hooks.json
cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$HOOKS" 2> /dev/null)
if [ -z "$cmd" ]; then
  gate hook_command FAIL "no command in $HOOKS"
elif [ ! -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then
  gate hook_command skip "no executable $BBJ_TEST_HOME/bin/bbjcpl on this host"
else
  mkdir "$WORK/proj"
  ln -s "$REPO/plugins/bbj" "$WORK/plug in"
  printf 'print "a"   rem same line\n' > "$WORK/proj/bad.bbj"
  printf 'print "a"; rem ok\n' > "$WORK/proj/clean.bbj"

  claude_payload Write "$WORK/proj/bad.bbj" "$WORK/proj" > "$WORK/bad.json"
  claude_payload Write "$WORK/proj/clean.bbj" "$WORK/proj" > "$WORK/clean.json"

  CLAUDE_PLUGIN_ROOT="$WORK/plug in" BBJ_HOME=$BBJ_TEST_HOME \
    sh -c "$cmd" < "$WORK/bad.json" > "$WORK/out_bad" 2> "$WORK/err_bad"
  rc=$?
  if [ "$rc" = 2 ] && grep -F 'error at line 10 (1)' "$WORK/err_bad" > /dev/null; then
    gate hook_command_bad ok "exit 2 with the compiler line, root contains a space"
  else
    gate hook_command_bad FAIL "exit $rc; stderr: $(head -n 2 "$WORK/err_bad" | tr '\n' ' ')"
  fi

  CLAUDE_PLUGIN_ROOT="$WORK/plug in" BBJ_HOME=$BBJ_TEST_HOME \
    sh -c "$cmd" < "$WORK/clean.json" > "$WORK/out_clean" 2> "$WORK/err_clean"
  rc=$?
  if [ "$rc" = 0 ] && [ ! -s "$WORK/out_clean" ] && [ ! -s "$WORK/err_clean" ]; then
    gate hook_command_clean ok "exit 0, silent"
  else
    gate hook_command_clean FAIL "exit $rc; output present"
  fi
fi

# ---- the user's real configuration is untouched ------------------------------------
# `claude plugin list` without the override, before and after the whole test: identical.
REAL_AFTER=$(claude plugin list 2>&1)
[ "$REAL_BEFORE" = "$REAL_AFTER" ] && gate real_config_untouched ok "plugin list of the real configuration unchanged" \
  || gate real_config_untouched FAIL "the real configuration's plugin list changed during the test"

finish
