#!/bin/sh
# .planning/phases/06-release-0-2-0/evidence/install-gate.sh
#
# plan 06-07, D-05: install the plugins from a git marketplace source into a throwaway
# configuration and smoke the hook.
#
#   sh install-gate.sh SOURCE     SOURCE is what `claude plugin marketplace add` takes, for
#                                 example BBj-AI/bbj-agent-plugins (the default branch) or
#                                 BBj-AI/bbj-agent-plugins#gsd/planning-setup-pr (a ref).
#
# Gates: install_marketplace_add, install_bbj, install_bbj_version (0.2.0, enabled),
# install_bbj_local_disabled, install_hook_bad, install_hook_clean,
# install_real_config_untouched (the real configuration's plugin files are byte-identical
# before and after).
#
# Exit codes: 0 every gate ok, 1 a gate failed, 2 usage or a missing tool (nothing changed).
#
# Nothing here runs BBj: the hook compiles with bbjcpl -t -N -X.
# Every claude call runs against a throwaway CLAUDE_CONFIG_DIR; the user's own
# configuration is only read (fingerprinted), never written.

ROOT=$(cd "$(dirname "$0")/../../../.." && pwd)
. "$ROOT/tests/lib.sh"

SOURCE=$1
WANT_VERSION=0.2.0
BBJ_TEST_HOME=${BBJ_TEST_HOME:-/opt/bbx}

if [ -z "$SOURCE" ]; then
  echo "usage: sh install-gate.sh SOURCE" >&2
  exit 2
fi
for _t in claude python3; do
  if ! command -v "$_t" > /dev/null 2>&1; then
    echo "refused: $_t is not on PATH" >&2
    exit 2
  fi
done
if [ ! -x "$BBJ_TEST_HOME/bin/bbjcpl" ]; then
  echo "refused: no executable $BBJ_TEST_HOME/bin/bbjcpl" >&2
  exit 2
fi

# the real configuration, as a fingerprint, before any call
REAL_CFG=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
fingerprint() {
  cksum < "$REAL_CFG/plugins/installed_plugins.json" 2> /dev/null
  cksum < "$REAL_CFG/plugins/known_marketplaces.json" 2> /dev/null
}
REAL_BEFORE=$(fingerprint)

mkwork
CFG=$WORK/cfg
mkdir "$CFG"

# cc ARGS...: claude with the throwaway configuration directory, for this call only. The
# session variables of a parent Claude Code are removed so the child behaves as a fresh CLI.
cc() {
  env -u CLAUDECODE -u CLAUDE_CODE_CHILD_SESSION -u CLAUDE_CODE_SESSION_ID \
    CLAUDE_CONFIG_DIR="$CFG" CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1 claude "$@"
}

# plugin_state NAME: "enabled" or "disabled" for NAME@basis-bbj in `claude plugin list`,
# nothing when it is not listed (format observed on 2.1.294: a NAME@basis-bbj line, then
# indented "Version: ..." and "Status: <symbol> enabled|disabled" lines).
plugin_state() {
  cc plugin list 2> /dev/null | awk -v n="$1@basis-bbj" '
    index($0, n) { found = 1; next }
    found && /enabled|disabled/ { if ($0 ~ /disabled/) print "disabled"; else print "enabled"; exit }
    found && /@/ { exit }'
}

# plugin_version NAME: the Version line of NAME@basis-bbj
plugin_version() {
  cc plugin list 2> /dev/null | awk -v n="$1@basis-bbj" '
    index($0, n) { found = 1; next }
    found && /Version:/ { sub(/^.*Version:[ \t]*/, ""); print; exit }
    found && /@/ { exit }'
}

out=$(cc plugin marketplace add "$SOURCE" 2>&1)
rc=$?
[ "$rc" = 0 ] && gate install_marketplace_add ok "marketplace added from $SOURCE" \
  || gate install_marketplace_add FAIL "exit $rc: $(printf '%s' "$out" | head -n 2 | tr '\n' ' ')"

out=$(cc plugin install bbj@basis-bbj 2>&1)
rc=$?
[ "$rc" = 0 ] && gate install_bbj ok "bbj@basis-bbj installed" \
  || gate install_bbj FAIL "exit $rc: $(printf '%s' "$out" | head -n 2 | tr '\n' ' ')"

state=$(plugin_state bbj)
ver=$(plugin_version bbj)
if [ "$state" = enabled ] && [ "$ver" = "$WANT_VERSION" ]; then
  gate install_bbj_version ok "bbj $ver enabled"
else
  gate install_bbj_version FAIL "bbj version '${ver:-none}' state '${state:-not listed}', want $WANT_VERSION enabled"
fi

out=$(cc plugin install bbj-local@basis-bbj 2>&1)
rc=$?
state=$(plugin_state bbj-local)
if [ "$rc" = 0 ] && [ "$state" = disabled ]; then
  gate install_bbj_local_disabled ok "bbj-local installed and disabled"
else
  gate install_bbj_local_disabled FAIL "exit $rc, bbj-local state '${state:-not listed}'"
fi

# ---- the installed hook command, run as the host would -----------------------------
# The installed root is the cache directory holding plugin.json for bbj at the wanted
# version and a hooks.json; the marketplace clone is not an installed copy.
ROOT_INST=
for _pj in $(find "$CFG/plugins" -path '*/.claude-plugin/plugin.json' 2> /dev/null | sort); do
  _dir=$(dirname "$(dirname "$_pj")")
  case "$_dir" in
    "$CFG"/plugins/cache/*) ;;
    *) continue ;;
  esac
  _meta=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("name",""), d.get("version",""))' "$_pj" 2> /dev/null)
  if [ "$_meta" = "bbj $WANT_VERSION" ] && [ -f "$_dir/hooks/hooks.json" ]; then
    ROOT_INST=$_dir
    break
  fi
done

cmd=
[ -n "$ROOT_INST" ] && cmd=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$ROOT_INST/hooks/hooks.json" 2> /dev/null)

if [ -z "$cmd" ]; then
  gate install_hook_bad FAIL "no installed bbj $WANT_VERSION root with a hook command under $CFG/plugins"
  gate install_hook_clean FAIL "no installed bbj $WANT_VERSION root with a hook command under $CFG/plugins"
else
  mkdir "$WORK/proj"
  printf 'print "a"   rem same line\n' > "$WORK/proj/bad.bbj"
  printf 'print "a"; rem ok\n' > "$WORK/proj/clean.bbj"
  claude_payload Write "$WORK/proj/bad.bbj" "$WORK/proj" > "$WORK/bad.json"
  claude_payload Write "$WORK/proj/clean.bbj" "$WORK/proj" > "$WORK/clean.json"

  CLAUDE_PLUGIN_ROOT=$ROOT_INST BBJ_HOME=$BBJ_TEST_HOME \
    sh -c "$cmd" < "$WORK/bad.json" > "$WORK/out_bad" 2> "$WORK/err_bad"
  rc=$?
  if [ "$rc" = 2 ] && grep -F 'bbjcpl reported 1 error(s) in' "$WORK/err_bad" > /dev/null; then
    gate install_hook_bad ok "exit 2, bbjcpl reported 1 error(s)"
  else
    gate install_hook_bad FAIL "exit $rc; stderr: $(head -n 2 "$WORK/err_bad" | tr '\n' ' ')"
  fi

  CLAUDE_PLUGIN_ROOT=$ROOT_INST BBJ_HOME=$BBJ_TEST_HOME \
    sh -c "$cmd" < "$WORK/clean.json" > "$WORK/out_clean" 2> "$WORK/err_clean"
  rc=$?
  if [ "$rc" = 0 ] && [ ! -s "$WORK/out_clean" ] && [ ! -s "$WORK/err_clean" ]; then
    gate install_hook_clean ok "exit 0, silent"
  else
    gate install_hook_clean FAIL "exit $rc; output present"
  fi
fi

# ---- the real configuration is untouched -------------------------------------------
REAL_AFTER=$(fingerprint)
[ "$REAL_BEFORE" = "$REAL_AFTER" ] && gate install_real_config_untouched ok "plugin files of $REAL_CFG unchanged" \
  || gate install_real_config_untouched FAIL "the real configuration's plugin files changed during the gate"

finish
