#!/bin/sh
# tests/test_install_codex.sh -- plan 19-05 Task 2 (PLUG-04, D-15): codex/install-codex.sh in
# a temp HOME and CODEX_HOME with a fake codex. Every case has its own temp directories; the
# real ~/.codex and ~/.agents are never touched (the real_home_untouched gate compares content
# checksums of the paths the installer can write). Nothing here runs
# BBj. Codex runs only in the optional gate real_codex_parses_configs (BBJ_TEST_CODEX=/path/to/codex,
# else a codex on the caller's PATH), only as `codex mcp get bbj-docs` (and bbj-local) and `codex mcp add` in temp
# homes, never a session; without a codex that gate is a clean skip. Plan 01-06 adds the tools/list
# probe gates (LOCAL-03, LOCAL-04) against tests/fake_mcp.py and a fake curl; the probe URL is always
# the BBJ_LOCAL_MCP_URL seam (a fake port or the closed port 9), never a real bbj-ls.
# Quick 261013-cpn adds the oauth_ gates: the installer writes, keeps and reports the
# [mcp_servers.bbj-docs.oauth] table of the pre-registered client, and never starts a sign-in.
. "$(dirname "$0")/lib.sh"
mkwork

# a test seam of the fake codex (tests/fake-bin/codex) must not come from the caller's shell: only the
# oauthadderr case sets it, for its own run (IN-06)
unset FAKE_CODEX_EXIT

# plan 01-06: the fake servers of the probe gates are killed with the work directory
FAKE_PIDS=
cleanup() {
  for _p in $FAKE_PIDS; do kill "$_p" 2> /dev/null; done
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP

# the real codex of the optional gate, resolved before any case narrows PATH
REAL_CODEX=${BBJ_TEST_CODEX:-$(command -v codex 2> /dev/null)}
[ -n "$REAL_CODEX" ] && [ -x "$REAL_CODEX" ] || REAL_CODEX=

INSTALLER=$REPO/codex/install-codex.sh
SYSPATH=/usr/bin:/bin
REALHOME=${HOME:-/nonexistent}
home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.before"

if [ ! -f "$INSTALLER" ]; then
  gate installer_exists FAIL "missing $INSTALLER"
  finish
fi
[ -x "$INSTALLER" ] && gate installer_executable ok "mode has the exec bit" || gate installer_executable FAIL "not executable"

# a PATH directory holding only the fake codex, and a PATH of plain tools without any codex
mkdir -p "$WORK/fbcodex" "$WORK/farm" "$WORK/fbcyg" "$WORK/fbcpl"
cp "$REPO/tests/fake-bin/codex" "$WORK/fbcodex/codex"
cp "$REPO/tests/fake-bin/cygpath" "$WORK/fbcyg/cygpath"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/fbcpl/bbjcpl"
cp "$REPO/tests/fake-bin/bbj" "$WORK/fbcpl/bbj"
for _t in sh cat cp mv mkdir rm rmdir diff cmp mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd; do
  _c=$(PATH=$SYSPATH command -v "$_t")
  [ -n "$_c" ] && ln -s "$_c" "$WORK/farm/$_t"
done
WITH_CODEX=$WORK/fbcodex:$SYSPATH
NO_CODEX=$WORK/farm
SNIPPET=$REPO/codex/AGENTS-snippet.md
PLUGIN_SCRIPT=$REPO/plugins/bbj/scripts/bbj-check.sh
SKILLS=$REPO/plugins/bbj/skills

# newenv NAME: fresh HOME and CODEX_HOME for one case
newenv() {
  E_ROOT=$WORK/$1
  E_HOME=$E_ROOT/home
  E_CODEX=$E_HOME/.codex
  E_SKILLS=$E_HOME/.agents/skills
  E_LOG=$E_ROOT/codex.log
  mkdir -p "$E_HOME"
  : > "$E_LOG"
}

# run_inst PATHVALUE ARGS...: the installer with the case's HOME and CODEX_HOME
run_inst() {
  _pv=$1
  shift
  env HOME="$E_HOME" CODEX_HOME="$E_CODEX" PATH="$_pv" FAKE_CODEX_LOG="$E_LOG" sh "$INSTALLER" "$@" > "$WORK/out" 2> "$WORK/err"
  RC=$?
}

count() {
  # count FIXED FILE: number of lines equal to FIXED
  grep -c -Fx -e "$1" "$2" 2> /dev/null
}

DEFAULT_URL=https://mcp.bbj-ai.com/mcp
HAVE_TOML=0
if command -v python3 > /dev/null 2>&1 && python3 -I -c 'import tomllib' 2> /dev/null; then HAVE_TOML=1; fi

# quick 261013-cpn: the pre-registered OAuth client of the hosted docs server, as the installer writes it
OAUTH_ID=oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
OAUTH_HDR='[mcp_servers.bbj-docs.oauth]'
OAUTH_L1="client_id = \"$OAUTH_ID\""
OAUTH_L2='callback_url = "http://localhost:47613/callback"'
OAUTH_L3='callback_port = 47613'

# oauth_once FILE: the OAuth header and its three lines each occur exactly once
oauth_once() {
  [ "$(count "$OAUTH_HDR" "$1")" = 1 ] && [ "$(count "$OAUTH_L1" "$1")" = 1 ] \
    && [ "$(count "$OAUTH_L2" "$1")" = 1 ] && [ "$(count "$OAUTH_L3" "$1")" = 1 ]
}

# oauth_inside FILE: prints how many OAuth headers lie between the bbj-docs managed markers
oauth_inside() {
  awk -v h="$OAUTH_HDR" '$0 == "# >>> bbj-agent-plugins (managed) >>>" { b = 1 } $0 == "# <<< bbj-agent-plugins (managed) <<<" { b = 0 } b && $0 == h { n++ } END { print n + 0 }' "$1"
}

# oauth_parsed FILE: tomllib reads exactly the three keys of the pre-registered client under bbj-docs.oauth
oauth_parsed() {
  python3 -I -c '
import sys, tomllib
d = tomllib.load(open(sys.argv[1], "rb"))
want = {"client_id": sys.argv[2], "callback_url": "http://localhost:47613/callback", "callback_port": 47613}
sys.exit(0 if d["mcp_servers"]["bbj-docs"].get("oauth") == want else 1)
' "$1" "$OAUTH_ID" 2> /dev/null
}

# oauth_added: the four lines the installer adds, as diff shows them (prefix "> "), for expectations
oauth_added() {
  printf '%s\n' "> $OAUTH_HDR" "> $OAUTH_L1" "> $OAUTH_L2" "> $OAUTH_L3"
}

# tsum FILE: canonical summary of the bbj-docs server of a config.toml, parsed with tomllib:
# the url, the default_tools_approval_mode value or -, one "NAME VALUE" line per tool, sorted
tsum() {
  python3 -I -c '
import sys, tomllib
d = tomllib.load(open(sys.argv[1], "rb"))
s = d["mcp_servers"]["bbj-docs"]
print("url", s["url"])
print("default", s.get("default_tools_approval_mode", "-"))
for k in sorted(s.get("tools", {})):
    print(k, s["tools"][k].get("approval_mode", "-"))
' "$1" 2> /dev/null
}

# five_expected URL: the summary of a config with the five docs tools approved
five_expected() {
  printf 'url %s\ndefault -\nbbj_examples approve\nbbj_fetch_page approve\nbbj_lookup approve\nbbj_reserved_word approve\nbbj_search approve\n' "$1"
}

# note_cfg FILE: a config.toml the installer wrote, for the check_tools_never_named aggregate
note_cfg() {
  printf '%s\n' "$1" >> "$WORK/written.list"
}

# real_parse LABEL FILE URL [SERVER]: the real codex loads a copy of FILE (codex mcp get SERVER, default
# bbj-docs, exits 0 and prints the url); no codex means nothing is run and nothing counted
RP_N=0
RP_BAD=
real_parse() {
  [ -n "$REAL_CODEX" ] || return 0
  _rp=$WORK/rp-$1
  mkdir -p "$_rp/home/.codex"
  cp -L "$2" "$_rp/home/.codex/config.toml"
  _rpout=$(env HOME="$_rp/home" CODEX_HOME="$_rp/home/.codex" PATH="$SYSPATH:$(dirname "$REAL_CODEX")" "$REAL_CODEX" mcp get "${4:-bbj-docs}" 2> /dev/null)
  _rprc=$?
  RP_N=$((RP_N + 1))
  case "$_rpout" in
    *"url: $3"*) [ "$_rprc" = 0 ] || RP_BAD="$RP_BAD $1(exit $_rprc)" ;;
    *) RP_BAD="$RP_BAD $1(exit $_rprc, no url)" ;;
  esac
}

# ---- first run, fake codex on PATH ----
newenv first
run_inst "$WITH_CODEX"
[ "$RC" = 0 ] && gate first_exit ok "exit 0" || gate first_exit FAIL "exit $RC: $(head -c 300 "$WORK/err")"
head -n 1 "$WORK/out" | grep 'not yet run on Windows or macOS' > /dev/null \
  && gate first_status_banner ok "first stdout line states the tested platforms" || gate first_status_banner FAIL "first line: $(head -n 1 "$WORK/out")"
grep -Fx 'mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp' "$E_LOG" > /dev/null \
  && gate first_codex_mcp_add ok "codex mcp add bbj-docs --url <default>" || gate first_codex_mcp_add FAIL "log: $(cat "$E_LOG")"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
five_ok=1
for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
  [ "$(count "[mcp_servers.bbj-docs.tools.$_t]" "$CFG")" = 1 ] || five_ok=0
done
if [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] && [ "$five_ok" = 1 ] && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] \
  && [ "$(grep -c default_tools_approval_mode "$CFG")" = 0 ]; then
  gate first_config_toml ok "one bbj-docs table, five tool tables once each, five approvals, no server-wide key"
else
  gate first_config_toml FAIL "$(cat "$CFG" 2> /dev/null)"
fi
# parsed: the five tools hold approve, the url is the default, nothing else is set
if [ "$HAVE_TOML" = 1 ]; then
  [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ] \
    && gate first_tools_tables ok "tomllib: url, no default_tools_approval_mode, the five docs tools approve" || gate first_tools_tables FAIL "$(tsum "$CFG" | tr '\n' ';')"
else
  gate first_tools_tables skip "no python3 with tomllib"
fi
# quick 261013-cpn: the OAuth table is there once, written by the installer and not by codex mcp add
if oauth_once "$CFG" && { [ "$HAVE_TOML" = 0 ] || oauth_parsed "$CFG"; } && [ "$(awk 'END { print NR }' "$E_LOG")" = 1 ] \
  && [ "$(cat "$E_LOG")" = 'mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp' ] \
  && grep -F 'added the OAuth client to' "$WORK/out" > /dev/null && grep -F 'codex mcp login bbj-docs' "$WORK/out" > /dev/null; then
  gate oauth_fresh_table ok "the OAuth table once with the three lines, tomllib reads them, codex got only the plain mcp add, stdout names the table and the sign-in step"
else
  gate oauth_fresh_table FAIL "$(tr '\n' ';' < "$CFG" | head -c 500); log: $(tr '\n' ';' < "$E_LOG")"
fi
real_parse first "$CFG" "$DEFAULT_URL"
if grep -F 'bbj_search' "$WORK/out" > /dev/null && grep -F 'bbj_fetch_page' "$WORK/out" > /dev/null && grep -F 'bbj_lookup' "$WORK/out" > /dev/null \
  && grep -F 'bbj_reserved_word' "$WORK/out" > /dev/null && grep -F 'bbj_examples' "$WORK/out" > /dev/null && grep -F 'bbj_check_syntax' "$WORK/out" > /dev/null; then
  gate first_prints_tools ok "stdout names the five approved tools and bbj_check_syntax as the one that keeps the prompt"
else
  gate first_prints_tools FAIL "a tool name is missing from stdout"
fi
if diff -r "$SKILLS/bbj-programming" "$E_SKILLS/bbj-programming" > /dev/null 2>&1 \
  && diff -r "$SKILLS/bbj-web-programming" "$E_SKILLS/bbj-web-programming" > /dev/null 2>&1; then
  gate first_skills ok "both skills in ~/.agents/skills are identical to plugins/bbj/skills"
else
  gate first_skills FAIL "skills differ or are missing under $E_SKILLS"
fi
COPY=$E_CODEX/bbj/bbj-check.sh
if cmp -s "$PLUGIN_SCRIPT" "$COPY" && [ -x "$COPY" ]; then
  gate first_script_copy ok "script copied outside any plugin cache, executable"
else
  gate first_script_copy FAIL "copy missing, different or not executable"
fi
if command -v python3 > /dev/null 2>&1; then
  if python3 -I -c '
import json, sys
d = json.load(open(sys.argv[1]))
e = d["hooks"]["PostToolUse"][0]
h = e["hooks"][0]
assert "apply_patch" in e["matcher"].split("|"), e["matcher"]
assert h["type"] == "command"
assert sys.argv[2] in h["command"], h["command"]
assert h["command"].startswith("sh "), h["command"]
assert "commandWindows" in h and h["commandWindows"]
assert h["timeout"] == 30
' "$E_CODEX/hooks.json" "$COPY" 2> "$WORK/pyerr"; then
    gate first_hooks_json ok "valid JSON: apply_patch matcher, command names the copy, commandWindows, timeout 30"
  else
    gate first_hooks_json FAIL "$(tail -n 1 "$WORK/pyerr")"
  fi
else
  gate first_hooks_json skip "no python3"
fi
if grep -F "$(grep -F 'Built in: no USE needed.' "$SNIPPET" | head -n 1)" "$WORK/out" > /dev/null && grep -F '/hooks' "$WORK/out" > /dev/null; then
  gate first_prints_snippet_and_trust ok "snippet USE sentence and the /hooks step are printed"
else
  gate first_prints_snippet_and_trust FAIL "USE sentence or /hooks missing from stdout"
fi
if grep -F 'heredoc' "$WORK/out" > /dev/null && grep -F 'BBJ_HOME' "$WORK/out" > /dev/null \
  && grep -F -e '--skills-dir ~/.codex/skills' "$WORK/out" > /dev/null && grep -F 'not a complete enforcement boundary' "$WORK/out" > /dev/null; then
  gate first_prints_gaps ok "gaps: guardrail wording, shell heredoc, BBJ_HOME, skills path fallback"
else
  gate first_prints_gaps FAIL "a gap line is missing"
fi
# the hook command of hooks.json, run as written, gives the compiler's verdict for a patch
if command -v python3 > /dev/null 2>&1; then
  HCMD=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["hooks"]["PostToolUse"][0]["hooks"][0]["command"])' "$E_CODEX/hooks.json")
  mkdir -p "$WORK/hookproj" "$WORK/hookhome/bin"
  cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/hookhome/bin/bbjcpl"
  printf '/x/f.bbj: error at line 10 (1): print\n' > "$WORK/hookcanned"
  : > "$WORK/hookproj/n.bbj"
  codex_payload "$WORK/hookproj" "$(printf '%s\n' '*** Begin Patch' '*** Add File: n.bbj' '+print "a"' '*** End Patch')" > "$WORK/hookpayload"
  env BBJ_HOME="$WORK/hookhome" FAKE_OUT="$WORK/hookcanned" PATH="$SYSPATH" sh -c "$HCMD" < "$WORK/hookpayload" > "$WORK/hookout" 2> "$WORK/hookerr"
  hrc=$?
  if [ "$hrc" = 2 ] && head -n 1 "$WORK/hookerr" | grep -F "bbjcpl reported 1 error(s) in $WORK/hookproj/n.bbj:" > /dev/null; then
    gate first_hook_command_runs ok "the installed command exits 2 with the feedback header"
  else
    gate first_hook_command_runs FAIL "exit $hrc: $(head -c 200 "$WORK/hookerr")"
  fi
else
  gate first_hook_command_runs skip "no python3"
fi

# ---- second run changes nothing ----
cp "$CFG" "$WORK/cfg.1"
cp "$E_CODEX/hooks.json" "$WORK/hooks.1"
calls_before=$(awk 'END { print NR }' "$E_LOG")
run_inst "$WITH_CODEX"
calls_after=$(awk 'END { print NR }' "$E_LOG")
if [ "$RC" = 0 ] && cmp -s "$CFG" "$WORK/cfg.1" && cmp -s "$E_CODEX/hooks.json" "$WORK/hooks.1" && [ "$calls_before" = "$calls_after" ]; then
  gate second_run_idempotent ok "exit 0, config.toml and hooks.json byte-identical, codex not called again"
else
  gate second_run_idempotent FAIL "exit $RC, codex calls $calls_before -> $calls_after"
fi
[ ! -e "$CFG.bbj-backup" ] && gate no_backup_for_fresh_config ok "no backup when config.toml did not exist" || gate no_backup_for_fresh_config FAIL "backup written"

# ---- no codex on PATH: the managed block ----
newenv nocodex
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
# all five tool tables lie between the markers
inside=$(awk '$0 == "# >>> bbj-agent-plugins (managed) >>>" { b = 1 } $0 == "# <<< bbj-agent-plugins (managed) <<<" { b = 0 } b && /^\[mcp_servers\.bbj-docs\.tools\.bbj_(search|fetch_page|lookup|reserved_word|examples)\]$/ { n++ } END { print n + 0 }' "$CFG")
if [ "$RC" = 0 ] \
  && [ "$(count '# >>> bbj-agent-plugins (managed) >>>' "$CFG")" = 1 ] \
  && [ "$(count '# <<< bbj-agent-plugins (managed) <<<' "$CFG")" = 1 ] \
  && [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] \
  && [ "$(count 'url = "https://mcp.bbj-ai.com/mcp"' "$CFG")" = 1 ] \
  && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] && [ "$inside" = 5 ] \
  && [ "$(grep -c default_tools_approval_mode "$CFG")" = 0 ]; then
  gate managed_block ok "markers, table and url once each, the five tool tables between the markers, no server-wide key"
else
  gate managed_block FAIL "exit $RC, $inside tool tables inside: $(head -c 400 "$CFG" 2> /dev/null)"
fi
if [ "$HAVE_TOML" = 1 ]; then
  [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ] \
    && gate managed_block_tools_tables ok "tomllib: the five docs tools approve" || gate managed_block_tools_tables FAIL "$(tsum "$CFG" | tr '\n' ';')"
else
  gate managed_block_tools_tables skip "no python3 with tomllib"
fi
if oauth_once "$CFG" && [ "$(oauth_inside "$CFG")" = 1 ] && { [ "$HAVE_TOML" = 0 ] || oauth_parsed "$CFG"; }; then
  gate oauth_managed_block ok "the OAuth table once, between the markers, tomllib reads the three lines"
else
  gate oauth_managed_block FAIL "inside: $(oauth_inside "$CFG"): $(tr '\n' ';' < "$CFG" | head -c 500)"
fi
real_parse nocodex "$CFG" "$DEFAULT_URL"
cp "$CFG" "$WORK/cfg.m1"
run_inst "$NO_CODEX"
cmp -s "$CFG" "$WORK/cfg.m1" && [ "$RC" = 0 ] && gate managed_block_idempotent ok "second run leaves it as is" || gate managed_block_idempotent FAIL "changed on second run"

# ---- an existing config.toml: only the five tool tables are added ----
newenv existing
mkdir -p "$E_CODEX"
cat > "$E_CODEX/config.toml" <<'TOML'
model = "x"

[mcp_servers.bbj-docs]
url = "https://example.invalid/mcp"

[mcp_servers.other]
url = "https://other.invalid/mcp"
TOML
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
diff "$WORK/cfg.orig" "$CFG" > "$WORK/cfg.diff"
note_cfg "$CFG"
removed=$(grep -c '^<' "$WORK/cfg.diff")
grep '^>' "$WORK/cfg.diff" | grep -v '^> *$' | sort > "$WORK/cfg.added"
{
  oauth_added
  for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
    printf '%s\n' "> [mcp_servers.bbj-docs.tools.$_t]" '> approval_mode = "approve"'
  done
} | sort > "$WORK/cfg.expected"
if [ "$RC" = 0 ] && [ "$removed" = 0 ] && cmp -s "$WORK/cfg.added" "$WORK/cfg.expected" \
  && [ "$(count 'url = "https://example.invalid/mcp"' "$CFG")" = 1 ] && [ "$(count '[mcp_servers.other]' "$CFG")" = 1 ] \
  && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ]; then
  gate existing_table_gains_tools ok "nothing removed, the added lines are the OAuth table and the five headers and five approvals, url kept, codex not called"
else
  gate existing_table_gains_tools FAIL "exit $RC, removed $removed: $(tr '\n' ';' < "$WORK/cfg.added")"
fi
if [ "$HAVE_TOML" = 1 ]; then
  [ "$(tsum "$CFG")" = "$(five_expected https://example.invalid/mcp)" ] && python3 -I -c 'import sys, tomllib; assert tomllib.load(open(sys.argv[1], "rb"))["mcp_servers"]["other"]["url"] == "https://other.invalid/mcp"' "$CFG" 2> /dev/null \
    && gate existing_parses ok "tomllib: five tools approve, url kept, mcp_servers.other still parses" || gate existing_parses FAIL "$(tsum "$CFG" | tr '\n' ';')"
else
  gate existing_parses skip "no python3 with tomllib"
fi
real_parse existing "$CFG" https://example.invalid/mcp
if cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup"; then
  gate existing_backup ok "config.toml.bbj-backup holds the original"
else
  gate existing_backup FAIL "backup missing or different"
fi
run_inst "$WITH_CODEX"
cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup" && gate existing_backup_once ok "backup not rewritten by the second run" || gate existing_backup_once FAIL "backup changed"

# ---- CR-01: bbj-docs written in a form the installer does not edit: config.toml untouched ----
i=0
for form in "[mcp_servers.'bbj-docs']" '  [mcp_servers.bbj-docs]' '[ mcp_servers . bbj-docs ]' 'mcp_servers.bbj-docs.url = "https://example.invalid/mcp"' '[mcp_servers.bbj-docs.env]'; do
  i=$((i + 1))
  newenv foreigntoml$i
  mkdir -p "$E_CODEX"
  case "$form" in
    '[mcp_servers.bbj-docs.env]') printf 'model = "x"\n\n%s\nK = "v"\n' "$form" > "$E_CODEX/config.toml" ;;
    mcp_servers.*) printf '[mcp_servers]\n%s\n' "$form" > "$E_CODEX/config.toml" ;;
    *) printf 'model = "x"\n\n%s\nurl = "https://example.invalid/mcp"\n' "$form" > "$E_CODEX/config.toml" ;;
  esac
  cp "$E_CODEX/config.toml" "$WORK/cfg.foreign"
  run_inst "$WITH_CODEX"
  if [ "$RC" = 3 ] && cmp -s "$WORK/cfg.foreign" "$E_CODEX/config.toml" && [ ! -e "$E_CODEX/config.toml.bbj-backup" ] \
    && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] && grep -F 'was not modified' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_search]' "$WORK/out" > /dev/null && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_fetch_page]' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_lookup]' "$WORK/out" > /dev/null && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_reserved_word]' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_examples]' "$WORK/out" > /dev/null && [ "$(grep -Fxc 'approval_mode = "approve"' "$WORK/out")" = 5 ] \
    && grep -Fx '[mcp_servers.bbj-docs]' "$WORK/out" > /dev/null && grep -Fx 'url = "https://mcp.bbj-ai.com/mcp"' "$WORK/out" > /dev/null \
    && grep -Fx "$OAUTH_HDR" "$WORK/out" > /dev/null && grep -Fx "$OAUTH_L1" "$WORK/out" > /dev/null \
    && grep -Fx "$OAUTH_L2" "$WORK/out" > /dev/null && grep -Fx "$OAUTH_L3" "$WORK/out" > /dev/null \
    && ! grep -Fx 'default_tools_approval_mode = "approve"' "$WORK/out" > /dev/null; then
    :
  else
    gate foreign_toml_form FAIL "form '$form': exit $RC, config changed or codex called"
    FOREIGN_BAD=1
  fi
  if command -v python3 > /dev/null 2>&1 && python3 -I -c 'import tomllib' 2> /dev/null; then
    python3 -I -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$E_CODEX/config.toml" 2> /dev/null \
      || { gate foreign_toml_parses FAIL "form '$form': config.toml no longer parses"; FOREIGN_BAD=1; }
  fi
done
[ "${FOREIGN_BAD:-0}" = 1 ] || gate foreign_toml_form ok "five spellings of bbj-docs: exit 3, config.toml byte-identical and parseable, no backup, codex not called, block printed with the OAuth table"

# ---- WR-01: the approval key is written in place; a symlinked config.toml keeps its link and mode ----
newenv symlinkcfg
mkdir -p "$E_CODEX" "$E_ROOT/dots"
printf 'model = "x"\n\n[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n' > "$E_ROOT/dots/config.toml"
chmod 644 "$E_ROOT/dots/config.toml"
ln -s "$E_ROOT/dots/config.toml" "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
note_cfg "$E_ROOT/dots/config.toml"
if [ "$RC" = 0 ] && [ -L "$E_CODEX/config.toml" ] && [ "$(count 'approval_mode = "approve"' "$E_ROOT/dots/config.toml")" = 5 ] \
  && [ "$(count '[mcp_servers.bbj-docs.tools.bbj_search]' "$E_ROOT/dots/config.toml")" = 1 ] && oauth_once "$E_ROOT/dots/config.toml" \
  && [ "$(ls -l "$E_ROOT/dots/config.toml" | cut -c1-10)" = "-rw-r--r--" ]; then
  gate approval_key_keeps_symlink_and_mode ok "the link survives, its target gained the OAuth table and the five tool tables, mode 644 kept"
else
  gate approval_key_keeps_symlink_and_mode FAIL "exit $RC, link: $([ -L "$E_CODEX/config.toml" ] && echo kept || echo replaced)"
fi
real_parse symlinkcfg "$E_ROOT/dots/config.toml" https://example.invalid/mcp

# ---- WR-02: exit 2 on an unusable destination happens before any write ----
newenv unusabledest
mkdir -p "$E_CODEX"
printf 'model = "x"\n' > "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.unusable"
printf 'a file, not a directory\n' > "$E_ROOT/notadir"
run_inst "$WITH_CODEX" --skills-dir "$E_ROOT/notadir/skills"
if [ "$RC" = 2 ] && cmp -s "$WORK/cfg.unusable" "$E_CODEX/config.toml" && [ ! -e "$E_CODEX/config.toml.bbj-backup" ] \
  && [ ! -e "$E_CODEX/hooks.json" ] && [ ! -e "$E_CODEX/bbj/bbj-check.sh" ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ]; then
  gate unusable_dest_refused_before_writes ok "exit 2, config.toml byte-identical, no backup, no hooks.json, no script, codex not called"
else
  gate unusable_dest_refused_before_writes FAIL "exit $RC: $(head -c 200 "$WORK/err")"
fi

# ---- WR-03: a codex home that a shell would expand inside the hook command is refused ----
for ch in 'c$(id)h' 'c`id`h' 'c"h' 'c\h' "c'h"; do
  newenv shellchars
  run_inst "$WITH_CODEX" --codex-home "$E_ROOT/$ch"
  if [ "$RC" = 2 ] && [ ! -e "$E_ROOT/$ch" ] && [ ! -e "$E_HOME/.agents" ]; then :; else gate codex_home_shell_chars_refused FAIL "accepted: $ch (exit $RC)"; SHBAD=1; fi
done
[ "${SHBAD:-0}" = 1 ] || gate codex_home_shell_chars_refused ok "dollar, backtick, double quote, backslash, apostrophe in --codex-home: exit 2, nothing created"

# ---- a foreign hooks.json is never modified ----
newenv foreign
mkdir -p "$E_CODEX"
printf '{"hooks":{"PreToolUse":[]}}\n' > "$E_CODEX/hooks.json"
cp "$E_CODEX/hooks.json" "$WORK/hooks.orig"
run_inst "$WITH_CODEX"
if [ "$RC" = 3 ] && cmp -s "$WORK/hooks.orig" "$E_CODEX/hooks.json" && grep -F '"matcher": "apply_patch|Edit|Write"' "$WORK/out" > /dev/null \
  && grep -F 'hooks.json' "$WORK/out" > /dev/null; then
  gate foreign_hooks_untouched ok "exit 3, file byte-identical, the block to merge is printed"
else
  gate foreign_hooks_untouched FAIL "exit $RC"
fi
[ -f "$E_CODEX/bbj/bbj-check.sh" ] && [ -f "$E_SKILLS/bbj-programming/SKILL.md" ] \
  && gate foreign_rest_done ok "skills and script still installed" || gate foreign_rest_done FAIL "rest of the install missing"

# ---- a differing skill directory ----
newenv skilldiff
mkdir -p "$E_SKILLS/bbj-programming"
printf 'mine\n' > "$E_SKILLS/bbj-programming/SKILL.md"
run_inst "$WITH_CODEX"
if [ "$RC" = 3 ] && [ "$(cat "$E_SKILLS/bbj-programming/SKILL.md")" = mine ] && grep -F "$E_SKILLS/bbj-programming" "$WORK/out" > /dev/null \
  && diff -r "$SKILLS/bbj-web-programming" "$E_SKILLS/bbj-web-programming" > /dev/null 2>&1; then
  gate skill_differs_untouched ok "exit 3, differing directory untouched and named, the other skill installed"
else
  gate skill_differs_untouched FAIL "exit $RC"
fi
run_inst "$WITH_CODEX" --force
if [ "$RC" = 0 ] && diff -r "$SKILLS/bbj-programming" "$E_SKILLS/bbj-programming" > /dev/null 2>&1; then
  gate skill_force_replaces ok "--force replaces it, exit 0"
else
  gate skill_force_replaces FAIL "exit $RC"
fi

# ---- --docs-url ----
newenv httpurl
run_inst "$WITH_CODEX" --docs-url http://example.com/mcp
if [ "$RC" = 2 ] && [ ! -e "$E_CODEX" ] && [ ! -e "$E_HOME/.agents" ] && [ ! -s "$E_LOG" ]; then
  gate docs_url_http_refused ok "plain http to a non-loopback host: exit 2, nothing written"
else
  gate docs_url_http_refused FAIL "exit $RC"
fi
for u in 'ftp://example.com/mcp' 'https://exa mple.com/mcp' 'https://example.com/m"cp' 'example.com/mcp' ''; do
  newenv badurl
  run_inst "$WITH_CODEX" --docs-url "$u"
  if [ "$RC" = 2 ] && [ ! -e "$E_CODEX" ]; then :; else gate docs_url_bad_refused FAIL "accepted: $u (exit $RC)"; BADURL=1; fi
done
[ "${BADURL:-0}" = 1 ] || gate docs_url_bad_refused ok "ftp, whitespace, quote, no scheme and empty values: exit 2, nothing written"
newenv loopback
run_inst "$WITH_CODEX" --docs-url http://127.0.0.1:8765/mcp
if [ "$RC" = 0 ] && grep -Fx 'mcp add bbj-docs --url http://127.0.0.1:8765/mcp' "$E_LOG" > /dev/null; then
  gate docs_url_loopback_http ok "http to loopback is accepted"
else
  gate docs_url_loopback_http FAIL "exit $RC"
fi
note_cfg "$E_CODEX/config.toml"
real_parse loopback "$E_CODEX/config.toml" http://127.0.0.1:8765/mcp
newenv httpsother
run_inst "$WITH_CODEX" --docs-url https://docs.example.org/mcp
[ "$RC" = 0 ] && grep -Fx 'mcp add bbj-docs --url https://docs.example.org/mcp' "$E_LOG" > /dev/null \
  && gate docs_url_https_other ok "https to any host is accepted" || gate docs_url_https_other FAIL "exit $RC"
note_cfg "$E_CODEX/config.toml"
real_parse httpsother "$E_CODEX/config.toml" https://docs.example.org/mcp

# review 07 WR-02: the pre-registered OAuth client belongs to the hosted docs server only. A run with another
# --docs-url (codex mcp add path and managed-block path) writes no oauth table, no client id, and says no sign-in
# client was written instead of naming the pre-registered one
_oc_bad=
_oc_n=0
# oauth_custom NAME PATHVALUE URL: one run with another --docs-url; appends to _oc_bad when an OAuth trace shows up
oauth_custom() {
  newenv "oauthcustom-$1"
  run_inst "$2" --docs-url "$3"
  _oc_n=$((_oc_n + 1))
  _oc_cfg=$E_CODEX/config.toml
  if [ "$RC" != 0 ] || [ ! -f "$_oc_cfg" ]; then _oc_bad="$_oc_bad $1(exit $RC)"; return 0; fi
  grep -F 'oauth' "$_oc_cfg" > /dev/null && _oc_bad="$_oc_bad $1(oauth in config.toml)"
  grep -F "$OAUTH_ID" "$_oc_cfg" "$WORK/out" > /dev/null && _oc_bad="$_oc_bad $1(client id written or printed)"
  grep -F 'added the OAuth client' "$WORK/out" > /dev/null && _oc_bad="$_oc_bad $1(says it added the table)"
  grep -F "$3" "$_oc_cfg" > /dev/null || _oc_bad="$_oc_bad $1(url missing)"
  return 0
}
oauth_custom loopback "$WITH_CODEX" http://127.0.0.1:8765/mcp
oauth_custom https "$WITH_CODEX" https://docs.example.org/mcp
oauth_custom block "$NO_CODEX" http://localhost:9999/mcp
[ -z "$_oc_bad" ] && gate oauth_custom_docs_url_no_table ok "$_oc_n runs with another --docs-url (loopback http, other https, managed block): no oauth table, no client id in config.toml or output" \
  || gate oauth_custom_docs_url_no_table FAIL "$_oc_bad"

# ---- --skills-dir and --codex-home ----
newenv custom
run_inst "$WITH_CODEX" --skills-dir "$E_ROOT/sk" --codex-home "$E_ROOT/ch"
if [ "$RC" = 0 ] && [ -f "$E_ROOT/sk/bbj-programming/SKILL.md" ] && [ -f "$E_ROOT/ch/hooks.json" ] && [ -f "$E_ROOT/ch/bbj/bbj-check.sh" ] \
  && [ -f "$E_ROOT/ch/config.toml" ] && [ ! -e "$E_HOME/.agents" ] && [ ! -e "$E_CODEX" ]; then
  gate custom_dirs ok "everything under the given directories, nothing under HOME defaults"
else
  gate custom_dirs FAIL "exit $RC"
fi
note_cfg "$E_ROOT/ch/config.toml"
real_parse custom "$E_ROOT/ch/config.toml" "$DEFAULT_URL"

# ---- Windows command field through cygpath ----
newenv cyg
run_inst "$WORK/fbcyg:$WITH_CODEX"
note_cfg "$E_CODEX/config.toml"
real_parse cyg "$E_CODEX/config.toml" "$DEFAULT_URL"
if command -v python3 > /dev/null 2>&1; then
  if python3 -I -c '
import json, sys
h = json.load(open(sys.argv[1]))["hooks"]["PostToolUse"][0]["hooks"][0]
w = h["commandWindows"]
assert w != h["command"], w
assert w.startswith("\"W:") and "bbj-check.sh\"" in w and w.count("\"") == 4, w
' "$E_CODEX/hooks.json" 2> "$WORK/pyerr"; then
    gate command_windows_cygpath ok "commandWindows holds the two cygpath -w forms, each double-quoted"
  else
    gate command_windows_cygpath FAIL "$(tail -n 1 "$WORK/pyerr")"
  fi
else
  gate command_windows_cygpath skip "no python3"
fi

# ---- the installer never calls a compiler or the interpreter ----
newenv nocompiler
FAKE_LOG=$WORK/compiler.log
export FAKE_LOG
: > "$FAKE_LOG"
run_inst "$WORK/fbcpl:$WITH_CODEX"
note_cfg "$E_CODEX/config.toml"
real_parse nocompiler "$E_CODEX/config.toml" "$DEFAULT_URL"
[ "$RC" = 0 ] && [ ! -s "$FAKE_LOG" ] && gate installer_no_compiler_calls ok "no compiler or bbj call during an install" || gate installer_no_compiler_calls FAIL "exit $RC, log: $(head -c 200 "$FAKE_LOG")"

# ---- usage ----
run_inst "$WITH_CODEX" --nonsense
[ "$RC" = 2 ] && gate unknown_option_refused ok "exit 2" || gate unknown_option_refused FAIL "exit $RC"
run_inst "$WITH_CODEX" --help
[ "$RC" = 0 ] && grep -F -e '--docs-url' "$WORK/out" > /dev/null && gate help_exit_zero ok "usage printed, exit 0" || gate help_exit_zero FAIL "exit $RC"

# ---- the default URL is the plugin's default (single source) ----
inst_url=$(sed -n 's/^DEFAULT_DOCS_URL=//p' "$INSTALLER" | head -n 1)
if command -v python3 > /dev/null 2>&1; then
  plug_url=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["userConfig"]["docs_url"]["default"])' "$REPO/plugins/bbj/.claude-plugin/plugin.json")
  [ -n "$inst_url" ] && [ "$inst_url" = "$plug_url" ] \
    && gate default_url_equals_plugin ok "$inst_url" || gate default_url_equals_plugin FAIL "installer '$inst_url', plugin '$plug_url'"
else
  gate default_url_equals_plugin skip "no python3"
fi

# ---- the snippet ----
lines=$(awk 'END { print NR }' "$SNIPPET")
[ "$lines" -lt 60 ] && grep -F 'Built in: no USE needed.' "$SNIPPET" > /dev/null \
  && gate snippet_shape ok "$lines lines, carries the USE sentence" || gate snippet_shape FAIL "$lines lines or no USE sentence"

# ---- the upgrade, user values, partial sets, foreign tool forms, tool tables without a table ----
OLDLINE='default_tools_approval_mode = "approve"'
# five_with: the five_expected summary with the default line "default VALUE"
five_with() {
  five_expected "$1" | sed "s/^default -\$/default $2/"
}
# all_once FILE: the bbj-docs table and each of the five tool tables are there exactly once
all_once() {
  [ "$(count '[mcp_servers.bbj-docs]' "$1")" = 1 ] || return 1
  for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
    [ "$(count "[mcp_servers.bbj-docs.tools.$_t]" "$1")" = 1 ] || return 1
  done
}
# same_after_rerun: a second run changes no byte of config.toml
same_after_rerun() {
  cp "$CFG" "$WORK/cfg.rerun"
  run_inst "$1"
  [ "$RC" = "$2" ] && cmp -s "$WORK/cfg.rerun" "$CFG"
}

newenv upgrade
mkdir -p "$E_CODEX"
printf '%s\n' 'model = "x"' '' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' "$OLDLINE" '' '[mcp_servers.other]' 'url = "https://other.invalid/mcp"' > "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 0 ] && ! grep -Fx "$OLDLINE" "$CFG" > /dev/null && all_once "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] \
  && grep -F "removed the line $OLDLINE" "$WORK/out" > /dev/null && cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup" \
  && [ "$(count '[mcp_servers.other]' "$CFG")" = 1 ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected https://example.invalid/mcp)" ]; } && same_after_rerun "$WITH_CODEX" 0; then
  gate upgrade_removes_old_key ok "the old line removed and reported, five tool tables, backup holds the original, rerun byte-identical"
else
  gate upgrade_removes_old_key FAIL "exit $RC: $(tr '\n' ';' < "$CFG")"
fi
real_parse upgrade "$CFG" https://example.invalid/mcp

newenv upgradeblock
mkdir -p "$E_CODEX"
printf '%s\n' '# >>> bbj-agent-plugins (managed) >>>' '[mcp_servers.bbj-docs]' "url = \"$DEFAULT_URL\"" "$OLDLINE" '# <<< bbj-agent-plugins (managed) <<<' > "$E_CODEX/config.toml"
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
inside=$(awk '$0 == "# >>> bbj-agent-plugins (managed) >>>" { b = 1 } $0 == "# <<< bbj-agent-plugins (managed) <<<" { b = 0 } b && /^\[mcp_servers\.bbj-docs\.tools\.bbj_(search|fetch_page|lookup|reserved_word|examples)\]$/ { n++ } END { print n + 0 }' "$CFG")
if [ "$RC" = 0 ] && ! grep -Fx "$OLDLINE" "$CFG" > /dev/null && all_once "$CFG" && [ "$inside" = 5 ] \
  && [ "$(count '# >>> bbj-agent-plugins (managed) >>>' "$CFG")" = 1 ] && [ "$(count '# <<< bbj-agent-plugins (managed) <<<' "$CFG")" = 1 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ]; } && same_after_rerun "$NO_CODEX" 0; then
  gate upgrade_managed_block ok "the managed block of an earlier version loses the old line and gets the five tool tables inside the markers"
else
  gate upgrade_managed_block FAIL "exit $RC, $inside inside: $(tr '\n' ';' < "$CFG")"
fi
real_parse upgradeblock "$CFG" "$DEFAULT_URL"

newenv defprompt
mkdir -p "$E_CODEX"
printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' 'default_tools_approval_mode = "prompt"' > "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 0 ] && grep -Fx 'default_tools_approval_mode = "prompt"' "$CFG" > /dev/null && all_once "$CFG" \
  && grep -F 'default_tools_approval_mode to prompt; left as is' "$WORK/out" > /dev/null \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_with https://example.invalid/mcp prompt)" ]; }; then
  gate default_other_value_kept ok "a prompt default stays byte for byte, is reported, the tools are added, exit 0"
else
  gate default_other_value_kept FAIL "exit $RC: $(tr '\n' ';' < "$CFG")"
fi
real_parse defprompt "$CFG" https://example.invalid/mcp

newenv defapprove
mkdir -p "$E_CODEX"
printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' 'default_tools_approval_mode="approve"' > "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 3 ] && grep -Fx 'default_tools_approval_mode="approve"' "$CFG" > /dev/null && all_once "$CFG" \
  && grep -F 'bbj_check_syntax' "$WORK/out" | grep -F 'remove the line by hand' > /dev/null \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_with https://example.invalid/mcp approve)" ]; }; then
  gate default_approve_other_spelling ok "an approve default in another spelling stays, the tools are added, the output names bbj_check_syntax, exit 3"
else
  gate default_approve_other_spelling FAIL "exit $RC: $(tr '\n' ';' < "$CFG")"
fi
real_parse defapprove "$CFG" https://example.invalid/mcp

newenv partial
mkdir -p "$E_CODEX"
printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.bbj-docs.tools.bbj_search]' 'approval_mode = "approve"' '' '[mcp_servers.bbj-docs.tools.bbj_lookup]' 'approval_mode = "prompt"' > "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
{
  printf 'url https://example.invalid/mcp\ndefault -\n'
  printf '%s\n' 'bbj_examples approve' 'bbj_fetch_page approve' 'bbj_lookup prompt' 'bbj_reserved_word approve' 'bbj_search approve'
} > "$WORK/partial.expected"
if [ "$RC" = 0 ] && all_once "$CFG" && [ "$(count 'approval_mode = "prompt"' "$CFG")" = 1 ] \
  && grep -F 'tool bbj_lookup has approval_mode prompt (yours); left as is' "$WORK/out" > /dev/null \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(cat "$WORK/partial.expected")" ]; } && same_after_rerun "$WITH_CODEX" 0; then
  gate partial_set_completed ok "three tool tables added once each, the user's prompt for bbj_lookup kept and reported, rerun byte-identical"
else
  gate partial_set_completed FAIL "exit $RC: $(tr '\n' ';' < "$CFG")"
fi
real_parse partial "$CFG" https://example.invalid/mcp

newenv nokey
mkdir -p "$E_CODEX"
printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.bbj-docs.tools.bbj_examples]' '' '[mcp_servers.other]' 'url = "https://other.invalid/mcp"' > "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 0 ] && all_once "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] \
  && [ "$(grep -A 1 -Fx '[mcp_servers.bbj-docs.tools.bbj_examples]' "$CFG" | tail -n 1)" = 'approval_mode = "approve"' ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected https://example.invalid/mcp)" ]; }; then
  gate tool_table_without_key ok "a tool table without approval_mode gains it directly under its header, header once"
else
  gate tool_table_without_key FAIL "exit $RC: $(tr '\n' ';' < "$CFG")"
fi
real_parse nokey "$CFG" https://example.invalid/mcp

newenv subtables
mkdir -p "$E_CODEX"
printf '%s\n' 'model = "x"' '' '[mcp_servers.bbj-docs.tools.bbj_search]' 'approval_mode = "approve"' '' '[mcp_servers.bbj-docs.tools.bbj_lookup]' 'approval_mode = "approve"' > "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 0 ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] && all_once "$CFG" && [ "$(count "url = \"$DEFAULT_URL\"" "$CFG")" = 1 ] \
  && [ "$(count '# >>> bbj-agent-plugins (managed) >>>' "$CFG")" = 1 ] && [ "$(count '# <<< bbj-agent-plugins (managed) <<<' "$CFG")" = 1 ] \
  && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] && cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup" \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ]; } && same_after_rerun "$WITH_CODEX" 0; then
  gate subtables_without_main_table ok "codex not called, the table appended once in a managed block, the missing tools added, every header once, backup written"
else
  gate subtables_without_main_table FAIL "exit $RC, codex calls $(awk 'END { print NR }' "$E_LOG"): $(tr '\n' ';' < "$CFG")"
fi
real_parse subtables "$CFG" "$DEFAULT_URL"

# tool approvals written in a form this script does not edit: config.toml stays as it is
i=0
for form in inline dotted quotedname singlequoted quotedkey; do
  i=$((i + 1))
  newenv foreigntools$i
  mkdir -p "$E_CODEX"
  case "$form" in
    inline) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.bbj-docs.tools]' 'bbj_search = { approval_mode = "approve" }' > "$E_CODEX/config.toml" ;;
    dotted) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' 'tools.bbj_search.approval_mode = "approve"' > "$E_CODEX/config.toml" ;;
    quotedname) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.bbj-docs.tools."bbj_search"]' 'approval_mode = "approve"' > "$E_CODEX/config.toml" ;;
    singlequoted) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' "[mcp_servers.'bbj-docs'.tools.bbj_search]" 'approval_mode = "approve"' > "$E_CODEX/config.toml" ;;
    quotedkey) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.bbj-docs.tools.bbj_search]' '"approval_mode" = "approve"' > "$E_CODEX/config.toml" ;;
  esac
  cp "$E_CODEX/config.toml" "$WORK/cfg.foreign"
  run_inst "$WITH_CODEX"
  if [ "$RC" = 3 ] && cmp -s "$WORK/cfg.foreign" "$E_CODEX/config.toml" && [ ! -e "$E_CODEX/config.toml.bbj-backup" ] \
    && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] && grep -F 'in a form this script does not edit' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_search]' "$WORK/out" > /dev/null && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_fetch_page]' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_lookup]' "$WORK/out" > /dev/null && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_reserved_word]' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_examples]' "$WORK/out" > /dev/null && [ "$(grep -Fxc 'approval_mode = "approve"' "$WORK/out")" = 5 ] \
    && grep -Fx "$OAUTH_HDR" "$WORK/out" > /dev/null && grep -Fx "$OAUTH_L1" "$WORK/out" > /dev/null \
    && grep -Fx "$OAUTH_L2" "$WORK/out" > /dev/null && grep -Fx "$OAUTH_L3" "$WORK/out" > /dev/null; then
    :
  else
    gate foreign_tool_forms FAIL "form $form: exit $RC, config changed, backup written or codex called"
    FTOOLS_BAD=1
  fi
done
[ "${FTOOLS_BAD:-0}" = 1 ] || gate foreign_tool_forms ok "five forms: exit 3, config.toml byte-identical, no backup, codex not called, the five tool tables and the OAuth table printed"
# the same, with the old server-wide line in the table: the output says to remove it by hand
newenv foreigntoolsold
mkdir -p "$E_CODEX"
printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' "$OLDLINE" '' '[mcp_servers.bbj-docs.tools]' 'bbj_search = { approval_mode = "approve" }' > "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.foreign"
run_inst "$WITH_CODEX"
if [ "$RC" = 3 ] && cmp -s "$WORK/cfg.foreign" "$E_CODEX/config.toml" && grep -F "remove the line $OLDLINE" "$WORK/out" > /dev/null; then
  gate foreign_tool_forms_old_line ok "the old line is left, the output says to remove it by hand, exit 3"
else
  gate foreign_tool_forms_old_line FAIL "exit $RC"
fi

# ---- quick 261013-cpn: the OAuth client table of bbj-docs is added, kept, reported; no sign-in is started ----
# oauth_tools FILE: appends the five approved tool tables of bbj-docs, in the shape the installer writes them
oauth_tools() {
  for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
    printf '\n[mcp_servers.bbj-docs.tools.%s]\napproval_mode = "approve"\n' "$_t"
  done >> "$1"
}

# a config of an earlier version of this script (no OAuth table) gains exactly the four lines: in a managed
# block (no codex) and in a plain table (codex on PATH, which must not be called)
OAUTH_UP_BAD=
for form in managed plain; do
  newenv oauthup-$form
  mkdir -p "$E_CODEX"
  case "$form" in
    managed)
      printf '%s\n' '# >>> bbj-agent-plugins (managed) >>>' '[mcp_servers.bbj-docs]' "url = \"$DEFAULT_URL\"" > "$E_CODEX/config.toml"
      oauth_tools "$E_CODEX/config.toml"
      printf '%s\n' '# <<< bbj-agent-plugins (managed) <<<' >> "$E_CODEX/config.toml"
      _url=$DEFAULT_URL; _pv=$NO_CODEX
      ;;
    plain)
      printf '%s\n' 'model = "x"' '' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' > "$E_CODEX/config.toml"
      oauth_tools "$E_CODEX/config.toml"
      printf '%s\n' '' '[mcp_servers.other]' 'url = "https://other.invalid/mcp"' >> "$E_CODEX/config.toml"
      _url=https://example.invalid/mcp; _pv=$WITH_CODEX
      ;;
  esac
  cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
  run_inst "$_pv"
  CFG=$E_CODEX/config.toml
  note_cfg "$CFG"
  diff "$WORK/cfg.orig" "$CFG" > "$WORK/cfg.diff"
  _removed=$(grep -c '^<' "$WORK/cfg.diff")
  grep '^>' "$WORK/cfg.diff" | grep -v '^> *$' | sort > "$WORK/cfg.added"
  oauth_added | sort > "$WORK/cfg.expected"
  if [ "$RC" = 0 ] && [ "$_removed" = 0 ] && cmp -s "$WORK/cfg.added" "$WORK/cfg.expected" && oauth_once "$CFG" \
    && { [ "$form" != managed ] || [ "$(oauth_inside "$CFG")" = 1 ]; } && cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup" \
    && grep -F 'added the OAuth client to' "$WORK/out" > /dev/null && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] \
    && { [ "$HAVE_TOML" = 0 ] || { [ "$(tsum "$CFG")" = "$(five_expected "$_url")" ] && oauth_parsed "$CFG"; }; } \
    && same_after_rerun "$_pv" 0; then
    :
  else
    OAUTH_UP_BAD="$OAUTH_UP_BAD $form(exit $RC, removed $_removed): $(tr '\n' ';' < "$WORK/cfg.added" | head -c 300)"
  fi
  real_parse "oauthup-$form" "$CFG" "$_url"
done
[ -z "$OAUTH_UP_BAD" ] && gate oauth_upgrade_adds_table ok "managed block and plain table without the OAuth table: nothing removed, exactly the four lines added (inside the markers for the block), backup holds the original, codex not called, tomllib reads them, rerun byte-identical" \
  || gate oauth_upgrade_adds_table FAIL "$OAUTH_UP_BAD"

# OAuth settings of the user's own are never edited, never doubled, and named once
OAUTH_USER_BAD=
for form in own port inline dotted quoted; do
  newenv oauthuser-$form
  mkdir -p "$E_CODEX"
  printf '[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n' > "$E_CODEX/config.toml"
  case "$form" in
    inline) printf '%s\n' 'oauth = { client_id = "my-own-client" }' >> "$E_CODEX/config.toml" ;;
    dotted) printf '%s\n' 'oauth.client_id = "my-own-client"' >> "$E_CODEX/config.toml" ;;
  esac
  oauth_tools "$E_CODEX/config.toml"
  case "$form" in
    own) printf '\n%s\n%s\n%s\n' "$OAUTH_HDR" 'client_id = "my-own-client"' 'callback_port = 5555' >> "$E_CODEX/config.toml" ;;
    port) printf '\n%s\n%s\n%s\n%s\n' "$OAUTH_HDR" "$OAUTH_L1" "$OAUTH_L2" 'callback_port = 5555' >> "$E_CODEX/config.toml" ;;
    quoted) printf '\n%s\n%s\n' '[mcp_servers.bbj-docs."oauth"]' 'client_id = "my-own-client"' >> "$E_CODEX/config.toml" ;;
  esac
  cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
  run_inst "$WITH_CODEX"
  CFG=$E_CODEX/config.toml
  _own=$(grep -c 'OAuth settings of its own' "$WORK/out")
  if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.orig" "$CFG" && [ ! -e "$CFG.bbj-backup" ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ] \
    && [ "$_own" = 1 ] && ! grep -F 'added the OAuth client to' "$WORK/out" > /dev/null \
    && grep -F 'bbj-docs: already registered in' "$WORK/out" > /dev/null \
    && { [ "$HAVE_TOML" = 0 ] || python3 -I -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$CFG" 2> /dev/null; } \
    && { [ "$form" != own ] || grep -F 'client_id my-own-client' "$WORK/out" > /dev/null; }; then
    :
  else
    OAUTH_USER_BAD="$OAUTH_USER_BAD $form(exit $RC, $_own naming line(s))"
  fi
done
[ -z "$OAUTH_USER_BAD" ] && gate oauth_user_forms_kept ok "own values, a changed port, an inline table, a dotted key and a quoted header: config.toml byte-identical, no backup, codex not called, one line names the OAuth settings of its own, exit 0" \
  || gate oauth_user_forms_kept FAIL "$OAUTH_USER_BAD"

# codex mcp add writes the table and then exits with an error (what Codex CLI 0.162.1 does against the hosted
# server): the table is kept and completed, and the output says what happened
FAKE_CODEX_EXIT=1
export FAKE_CODEX_EXIT
newenv oauthadderr
run_inst "$WITH_CODEX"
unset FAKE_CODEX_EXIT
CFG=$E_CODEX/config.toml
note_cfg "$CFG"
if [ "$RC" = 0 ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 1 ] && [ "$(cat "$E_LOG")" = 'mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp' ] \
  && [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] && ! grep -F '>>> bbj-agent-plugins' "$CFG" > /dev/null \
  && oauth_once "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] \
  && grep -F 'then exited with an error' "$WORK/out" > /dev/null && ! grep -F 'writing the block to config.toml instead' "$WORK/out" > /dev/null; then
  gate oauth_codex_add_error_after_write ok "codex mcp add wrote the table and exited 1: one table, no managed block, the OAuth table and five approvals added, the output says so"
else
  gate oauth_codex_add_error_after_write FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 400); out: $(grep 'codex mcp add' "$WORK/out" | head -c 300)"
fi
real_parse oauthadderr "$CFG" "$DEFAULT_URL"

# ---- plan 01-04: --with-local, the managed bbj-local block (LOCAL-02, D-09, D-10, D-12, D-17) ----
# The three bbj-ls tools run on this machine and are approved by name only on the fixed loopback
# url. Their names appear only in configs of this section (WORK/local.list), never in written.list:
# check_tools_never_named forbids them there.
LMB='# >>> bbj-agent-plugins bbj-local (managed) >>>'
LME='# <<< bbj-agent-plugins bbj-local (managed) <<<'
LOCAL_URL_T=http://127.0.0.1:5009/mcp
: > "$WORK/local.list"

# lsum FILE: canonical summary of the bbj-local server of a config.toml, in tsum's shape
lsum() {
  python3 -I -c '
import sys, tomllib
d = tomllib.load(open(sys.argv[1], "rb"))
s = d["mcp_servers"]["bbj-local"]
print("url", s["url"])
print("default", s.get("default_tools_approval_mode", "-"))
for k in sorted(s.get("tools", {})):
    print(k, s["tools"][k].get("approval_mode", "-"))
' "$1" 2> /dev/null
}

# three_expected: the summary of a bbj-local server with its three tools approved
three_expected() {
  printf 'url %s\ndefault -\nbbj_check_syntax approve\nbbj_denum approve\nbbj_format approve\n' "$LOCAL_URL_T"
}

# docs_done FILE: a plain bbj-docs table with the OAuth table of the pre-registered client (quick 261013-cpn)
# and its five approved tool tables, so the docs pass changes nothing
docs_done() {
  {
    printf '[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n'
    printf '\n%s\n%s\n%s\n%s\n' "$OAUTH_HDR" "$OAUTH_L1" "$OAUTH_L2" "$OAUTH_L3"
    for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
      printf '\n[mcp_servers.bbj-docs.tools.%s]\napproval_mode = "approve"\n' "$_t"
    done
  } >> "$1"
}

# note_local FILE: a config of this section (kept out of written.list on purpose)
note_local() {
  printf '%s\n' "$1" >> "$WORK/local.list"
}

# local_parse LABEL FILE: the real codex loads both servers of a local-run config
local_parse() {
  real_parse "$1-local" "$2" "$LOCAL_URL_T" bbj-local
  real_parse "$1-docs" "$2" "$3" bbj-docs
}

# local_shape FILE: one begin and one end marker, one bbj-local table, the url once, the three tool tables
# between the markers, no server-wide key; prints nothing, returns 0 or 1
local_shape() {
  [ "$(count "$LMB" "$1")" = 1 ] && [ "$(count "$LME" "$1")" -ge 1 ] && [ "$(count '[mcp_servers.bbj-local]' "$1")" = 1 ] \
    && [ "$(count "url = \"$LOCAL_URL_T\"" "$1")" = 1 ] || return 1
  _in=$(awk -v b="$LMB" -v e="$LME" '$0 == b { s = 1 } $0 == e { s = 0 } s && /^\[mcp_servers\.bbj-local\.tools\.bbj_(check_syntax|format|denum)\]$/ { n++ } END { print n + 0 }' "$1")
  [ "$_in" = 3 ] && [ "$(grep -c default_tools_approval_mode "$1")" = 0 ] \
    && ! grep -Eq '^(required|enabled|startup_timeout_sec)[ ]*=' "$1"
}

newenv localfresh
run_inst "$NO_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && local_shape "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; }; then
  gate local_block_fresh_no_codex ok "--with-local, no codex: the markers once, [mcp_servers.bbj-local] once, the fixed url, the three tool tables between the markers, eight approvals, no server-wide key"
else
  gate local_block_fresh_no_codex FAIL "exit $RC: $(tr '\n' ';' < "$CFG" 2> /dev/null | head -c 600)"
fi
local_parse localfresh "$CFG" "$DEFAULT_URL"

newenv localcodex
run_inst "$WITH_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && grep -Fx 'mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp' "$E_LOG" > /dev/null && ! grep -q '^mcp add bbj-local' "$E_LOG" \
  && local_shape "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; }; then
  gate local_block_fresh_with_codex_on_path ok "codex on PATH: mcp add for bbj-docs only, never for bbj-local; the same block shape"
else
  gate local_block_fresh_with_codex_on_path FAIL "exit $RC, codex log: $(tr '\n' ';' < "$E_LOG")"
fi
local_parse localcodex "$CFG" "$DEFAULT_URL"

newenv localseam
BBJ_LOCAL_MCP_URL=http://127.0.0.1:9999/mcp
export BBJ_LOCAL_MCP_URL
run_inst "$NO_CODEX" --with-local
unset BBJ_LOCAL_MCP_URL
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && local_shape "$CFG" && ! grep -F 9999 "$CFG" > /dev/null; then
  gate local_url_fixed_ignores_seam ok "BBJ_LOCAL_MCP_URL=...:9999 does not move the registration: the url is $LOCAL_URL_T, 9999 is nowhere in config.toml (D-17)"
else
  gate local_url_fixed_ignores_seam FAIL "exit $RC: $(tr '\n' ';' < "$CFG" 2> /dev/null | head -c 400)"
fi

newenv localnoflag
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
if [ "$RC" = 0 ] && ! grep -F bbj-local "$CFG" > /dev/null; then
  gate local_no_flag_writes_nothing ok "a fresh run without --with-local: no line of config.toml names bbj-local"
else
  gate local_no_flag_writes_nothing FAIL "exit $RC"
fi

# ---- reruns refresh the managed block in place, with or without the flag; a lone end marker is tolerated (D-09, D-10) ----
newenv localrerun
run_inst "$NO_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
cp "$CFG" "$WORK/cfg.l1"
run_inst "$NO_CODEX" --with-local
if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.l1" "$CFG" && grep -F 'bbj-local: already registered' "$WORK/out" > /dev/null; then
  gate local_rerun_idempotent ok "a second --with-local run: exit 0, config.toml byte-identical, bbj-local reported as already registered"
else
  gate local_rerun_idempotent FAIL "exit $RC, identical: $(cmp -s "$WORK/cfg.l1" "$CFG" && echo yes || echo no)"
fi
run_inst "$NO_CODEX"
if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.l1" "$CFG"; then
  gate local_kept_without_flag ok "a run without the flag keeps the managed block: exit 0, config.toml byte-identical"
else
  gate local_kept_without_flag FAIL "exit $RC, identical: $(cmp -s "$WORK/cfg.l1" "$CFG" && echo yes || echo no)"
fi

newenv localrefresh
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' "$LMB" '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" '' '[mcp_servers.bbj-local.tools.bbj_check_syntax]' 'approval_mode = "approve"' '' '[mcp_servers.bbj-local.tools.bbj_format]' "$LME" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && local_shape "$CFG" && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; } \
  && [ "$(diff "$WORK/cfg.orig" "$CFG" | grep -c '^<')" = 0 ]; then
  gate local_rerun_without_flag_refreshes_in_place ok "no flag, an older managed block: the bbj_format key and the bbj_denum table added inside the markers, nothing removed, each header once"
else
  gate local_rerun_without_flag_refreshes_in_place FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi
local_parse localrefresh "$CFG" https://example.invalid/mcp

newenv locallone
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' "$LME" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.lone"
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.lone" "$CFG" && ! grep -Fx "$LMB" "$CFG" > /dev/null; then
  gate local_lone_end_marker_without_flag ok "a lone end marker and no flag: exit 0, config.toml byte-identical, no block added"
else
  gate local_lone_end_marker_without_flag FAIL "exit $RC"
fi
run_inst "$NO_CODEX" --with-local
note_local "$CFG"
if [ "$RC" = 0 ] && [ "$(count '[mcp_servers.bbj-local]' "$CFG")" = 1 ] && [ "$(count "$LMB" "$CFG")" = 1 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; } && same_after_rerun "$NO_CODEX" 0; then
  gate local_lone_end_marker ok "a lone end marker (what codex mcp remove leaves) and the flag: a fresh block follows it, [mcp_servers.bbj-local] once, a rerun byte-identical"
else
  gate local_lone_end_marker FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi
local_parse locallone "$CFG" https://example.invalid/mcp

# CR-01: both markers, the table deleted between them (the documented removal). No flag: nothing is
# registered and config.toml stays byte-identical, no backup (the registration stays removed, D-09 opt-in).
# With the flag: the table goes back inside the existing markers, never a second begin marker.
newenv localmarkers
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' "$LMB" "$LME" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.markers"
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.markers" "$CFG" && [ ! -e "$CFG.bbj-backup" ] && [ "$(count '[mcp_servers.bbj-local]' "$CFG")" = 0 ] \
  && ! grep -F 'appended a managed block' "$WORK/out" > /dev/null; then
  gate local_markers_without_table_no_flag ok "both markers, no table, no flag: exit 0, config.toml byte-identical, no backup, bbj-local not registered"
else
  gate local_markers_without_table_no_flag FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi
run_inst "$NO_CODEX" --with-local
note_local "$CFG"
if [ "$RC" = 0 ] && local_shape "$CFG" && [ "$(count "$LME" "$CFG")" = 1 ] && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; } && same_after_rerun "$NO_CODEX" 0; then
  gate local_markers_without_table_with_flag ok "both markers, no table, the flag: the table and its three approvals sit between the existing markers, one begin and one end marker, a rerun byte-identical"
else
  gate local_markers_without_table_with_flag FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi
awk -v b="$LMB" -v e="$LME" '$0 == b { s = 1 } s && /^\[mcp_servers\.bbj-local\]$/ { t = 1 } $0 == e { s = 0 } END { exit !t }' "$CFG" \
  && gate local_markers_table_inside ok "the restored bbj-local table lies between the begin and the end marker" \
  || gate local_markers_table_inside FAIL "the table is outside the markers"
local_parse localmarkers "$CFG" https://example.invalid/mcp
# a begin marker alone (the end marker deleted too): no flag leaves it, the flag adds the table and one end marker
newenv localbeginonly
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' "$LMB" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.markers"
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
_noflag_rc=$RC
_noflag_same=0
cmp -s "$WORK/cfg.markers" "$CFG" && _noflag_same=1
run_inst "$NO_CODEX" --with-local
note_local "$CFG"
if [ "$_noflag_rc" = 0 ] && [ "$_noflag_same" = 1 ] && [ "$RC" = 0 ] && local_shape "$CFG" && [ "$(count "$LME" "$CFG")" = 1 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; } && same_after_rerun "$NO_CODEX" 0; then
  gate local_begin_marker_alone ok "a begin marker alone: no flag leaves config.toml byte-identical, the flag adds the table and one end marker after it, a rerun byte-identical"
else
  gate local_begin_marker_alone FAIL "no-flag exit $_noflag_rc identical $_noflag_same, flag exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi

# ---- every bbj-local form the installer meets in real configs (D-12, LOCAL-01 adjacency and ordering) ----
# a plain table at the fixed url, as codex mcp add bbj-local --url writes it, gains the three approvals
newenv localhand
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$WITH_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && [ "$(count '[mcp_servers.bbj-local]' "$CFG")" = 1 ] && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] \
  && ! grep -F 'bbj-agent-plugins bbj-local' "$CFG" > /dev/null && cmp -s "$WORK/cfg.orig" "$CFG.bbj-backup" \
  && ! grep -q 'bbj-local' "$E_LOG" \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; }; then
  gate local_hand_registered_same_url ok "a hand-registered table at the fixed url gains the three approvals, no marker added, backup holds the original, codex not called for bbj-local, exit 0"
else
  gate local_hand_registered_same_url FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 600)"
fi
local_parse localhand "$CFG" https://example.invalid/mcp

# any other form of bbj-local: exit 3, config.toml byte-identical, no backup, the block printed
i=0
for form in otherurl singlequoted dotted subtable; do
  i=$((i + 1))
  newenv localforeign$i
  mkdir -p "$E_CODEX"
  case "$form" in
    otherurl) docs_done "$E_CODEX/config.toml"; printf '%s\n' '' '[mcp_servers.bbj-local]' 'url = "http://127.0.0.1:5010/mcp"' >> "$E_CODEX/config.toml" ;;
    singlequoted) docs_done "$E_CODEX/config.toml"; printf '%s\n' '' "[mcp_servers.'bbj-local']" "url = \"$LOCAL_URL_T\"" >> "$E_CODEX/config.toml" ;;
    dotted) printf '%s\n' '[mcp_servers]' "bbj-local.url = \"$LOCAL_URL_T\"" '' > "$E_CODEX/config.toml"; docs_done "$E_CODEX/config.toml" ;;
    subtable) docs_done "$E_CODEX/config.toml"; printf '%s\n' '' '[mcp_servers.bbj-local.env]' 'K = "v"' >> "$E_CODEX/config.toml" ;;
  esac
  cp "$E_CODEX/config.toml" "$WORK/cfg.foreign"
  run_inst "$WITH_CODEX" --with-local
  note_local "$E_CODEX/config.toml"
  if [ "$RC" = 3 ] && cmp -s "$WORK/cfg.foreign" "$E_CODEX/config.toml" && [ ! -e "$E_CODEX/config.toml.bbj-backup" ] \
    && ! grep -q 'bbj-local' "$E_LOG" && grep -F 'the bbj-local entry was not modified' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-local]' "$WORK/out" > /dev/null && grep -Fx "url = \"$LOCAL_URL_T\"" "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-local.tools.bbj_check_syntax]' "$WORK/out" > /dev/null && grep -Fx '[mcp_servers.bbj-local.tools.bbj_format]' "$WORK/out" > /dev/null \
    && grep -Fx '[mcp_servers.bbj-local.tools.bbj_denum]' "$WORK/out" > /dev/null; then
    :
  else
    gate local_foreign_forms FAIL "form $form: exit $RC, config changed, backup written, codex called or the block not printed"
    LFOREIGN_BAD=1
  fi
  if [ "$HAVE_TOML" = 1 ]; then
    python3 -I -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$E_CODEX/config.toml" 2> /dev/null \
      || { gate local_foreign_forms FAIL "form $form: config.toml no longer parses"; LFOREIGN_BAD=1; }
  fi
  # the real codex refuses a whole config that holds a bbj-local server without a transport (the sub-table form)
  case "$form" in
    subtable) ;;
    *) real_parse "localforeign$i-docs" "$E_CODEX/config.toml" https://example.invalid/mcp bbj-docs ;;
  esac
  case "$form" in
    otherurl) real_parse "localforeign$i-local" "$E_CODEX/config.toml" http://127.0.0.1:5010/mcp bbj-local ;;
    singlequoted|dotted) real_parse "localforeign$i-local" "$E_CODEX/config.toml" "$LOCAL_URL_T" bbj-local ;;
  esac
done
[ "${LFOREIGN_BAD:-0}" = 1 ] || gate local_foreign_forms ok "another url, a single-quoted key, a dotted key, a sub-table without the table: exit 3, config.toml byte-identical and parseable, no backup, codex not called, the block printed"

# WR-02: two more spellings of a bbj-local definition are still foreign: a dotted key at the top level and a
# quoted key under [mcp_servers]
i=0
for form in rootdotted quotedkey; do
  i=$((i + 1))
  newenv localforeignkey$i
  mkdir -p "$E_CODEX"
  case "$form" in
    rootdotted) printf '%s\n' "mcp_servers.bbj-local.url = \"$LOCAL_URL_T\"" '' > "$E_CODEX/config.toml" ;;
    quotedkey) printf '%s\n' '[mcp_servers]' "\"bbj-local\" = { url = \"$LOCAL_URL_T\" }" '' > "$E_CODEX/config.toml" ;;
  esac
  docs_done "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/cfg.foreign"
  run_inst "$NO_CODEX" --with-local
  note_local "$E_CODEX/config.toml"
  if [ "$RC" = 3 ] && cmp -s "$WORK/cfg.foreign" "$E_CODEX/config.toml" && [ ! -e "$E_CODEX/config.toml.bbj-backup" ] \
    && grep -F 'the bbj-local entry was not modified' "$WORK/out" > /dev/null; then
    :
  else
    gate local_foreign_key_forms FAIL "form $form: exit $RC, config changed or no refusal printed"
    LFKEY_BAD=1
  fi
done
[ "${LFKEY_BAD:-0}" = 1 ] || gate local_foreign_key_forms ok "a top-level dotted key and a quoted key under [mcp_servers]: exit 3, config.toml byte-identical, no backup"

# WR-02: a server name inside a path or a value is not a server definition. Codex writes [projects."<path>"]
# trust tables itself; a project directory called bbj-local or bbj-docs must not make the installer refuse
newenv localprojects
mkdir -p "$E_CODEX"
printf '%s\n' '[projects."/home/u/src/bbj-local"]' 'trust_level = "trusted"' '' '[projects."/home/u/src/bbj-docs"]' 'trust_level = "trusted"' '' '[notes]' 'text = "bbj-local and bbj-docs are names"' > "$E_CODEX/config.toml"
run_inst "$NO_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && local_shape "$CFG" && all_once "$CFG" && ! grep -F 'in a form this script does not edit' "$WORK/out" > /dev/null \
  && [ "$(count '[projects."/home/u/src/bbj-local"]' "$CFG")" = 1 ] && [ "$(count 'text = "bbj-local and bbj-docs are names"' "$CFG")" = 1 ] \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG")" = "$(three_expected)" ]; } && same_after_rerun "$NO_CODEX" 0; then
  gate local_name_in_path_not_foreign ok "bbj-local and bbj-docs inside a [projects] path and a string value: exit 0, both servers registered normally, nothing refused, a rerun byte-identical"
else
  gate local_name_in_path_not_foreign FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 700)"
fi
local_parse localprojects "$CFG" "$DEFAULT_URL"

# IN-02: a CRLF config.toml stays CRLF: every line the installer inserts ends in a carriage return as well
# crlf FILE: rewrite FILE with CRLF line ends; bare_lf FILE: how many lines do not end in a carriage return
crlf() {
  awk '{ sub(/\r$/, ""); printf "%s\r\n", $0 }' "$1" > "$1.crlf" && cat "$1.crlf" > "$1" && rm -f "$1.crlf"
}
bare_lf() {
  awk '{ if ($0 !~ /\r$/) n++ } END { print n + 0 }' "$1"
}
CRLF_BAD=
for form in docsonly appended restored; do
  newenv crlf$form
  mkdir -p "$E_CODEX"
  case "$form" in
    docsonly) printf '%s\n' 'model = "x"' '' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' '' '[mcp_servers.other]' 'url = "https://other.invalid/mcp"' > "$E_CODEX/config.toml"; crlf "$E_CODEX/config.toml"; _args= ;;
    appended) docs_done "$E_CODEX/config.toml"; crlf "$E_CODEX/config.toml"; _args=--with-local ;;
    restored) docs_done "$E_CODEX/config.toml"; printf '%s\n' '' "$LMB" "$LME" >> "$E_CODEX/config.toml"; crlf "$E_CODEX/config.toml"; _args=--with-local ;;
  esac
  # shellcheck disable=SC2086  # _args is empty or the one flag
  run_inst "$NO_CODEX" $_args
  CFG=$E_CODEX/config.toml
  note_local "$CFG"
  _bare=$(bare_lf "$CFG")
  if [ "$RC" != 0 ] || [ "$_bare" != 0 ] || [ "$(count '[mcp_servers.bbj-docs.tools.bbj_lookup]'"$(printf '\r')" "$CFG")" != 1 ] \
    || { [ "$form" != docsonly ] && [ "$(count '[mcp_servers.bbj-local]'"$(printf '\r')" "$CFG")" != 1 ]; } \
    || { [ "$HAVE_TOML" = 1 ] && ! python3 -I -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$CFG" 2> /dev/null; } \
    || [ "$(count "$OAUTH_HDR$(printf '\r')" "$CFG")" != 1 ] \
    || { [ "$form" = docsonly ] && ! same_after_rerun "$NO_CODEX" 0; }; then
    CRLF_BAD="$CRLF_BAD $form(exit $RC, $_bare line(s) without a carriage return)"
  fi
done
[ -z "$CRLF_BAD" ] && gate crlf_config_stays_crlf ok "a CRLF config.toml (OAuth and tool tables added, a block appended, a table restored between markers): every line still ends CRLF, the OAuth header once, the file still parses, a rerun of the first form changes nothing" \
  || gate crlf_config_stays_crlf FAIL "$CRLF_BAD"

# both servers: the docs table directly followed by the local block, and the reverse; the begin marker stays above its table
for order in docs_first local_first; do
  newenv localboth-$order
  mkdir -p "$E_CODEX"
  case "$order" in
    docs_first) printf '%s\n' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' "$LMB" '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" "$LME" > "$E_CODEX/config.toml" ;;
    local_first) printf '%s\n' "$LMB" '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" "$LME" '' '[mcp_servers.bbj-docs]' 'url = "https://example.invalid/mcp"' > "$E_CODEX/config.toml" ;;
  esac
  run_inst "$WITH_CODEX" --with-local
  CFG=$E_CODEX/config.toml
  note_local "$CFG"
  above=$(grep -B 1 -Fx '[mcp_servers.bbj-local]' "$CFG" | head -n 1)
  if [ "$RC" = 0 ] && [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] && [ "$(count '[mcp_servers.bbj-local]' "$CFG")" = 1 ] \
    && [ "$(count 'approval_mode = "approve"' "$CFG")" = 8 ] && [ "$above" = "$LMB" ] && local_shape "$CFG" \
    && { [ "$HAVE_TOML" = 0 ] || { [ "$(tsum "$CFG")" = "$(five_expected https://example.invalid/mcp)" ] && [ "$(lsum "$CFG")" = "$(three_expected)" ]; }; }; then
    :
  else
    gate local_and_docs_coexist_both_orders FAIL "order $order: exit $RC, above bbj-local: '$above': $(tr '\n' ';' < "$CFG" | head -c 500)"
    LBOTH_BAD=1
  fi
  local_parse "localboth-$order" "$CFG" https://example.invalid/mcp
done
[ "${LBOTH_BAD:-0}" = 1 ] || gate local_and_docs_coexist_both_orders ok "docs first and local first: five docs approvals, three local approvals, each table once, the begin marker directly above [mcp_servers.bbj-local]"

# a user value of a local tool stays and is named
newenv localuser
mkdir -p "$E_CODEX"
docs_done "$E_CODEX/config.toml"
printf '%s\n' '' "$LMB" '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" '' '[mcp_servers.bbj-local.tools.bbj_check_syntax]' 'approval_mode = "approve"' '' '[mcp_servers.bbj-local.tools.bbj_format]' 'approval_mode = "prompt"' '' '[mcp_servers.bbj-local.tools.bbj_denum]' 'approval_mode = "approve"' "$LME" >> "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/cfg.orig"
run_inst "$WITH_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if [ "$RC" = 0 ] && cmp -s "$WORK/cfg.orig" "$CFG" && [ "$(count 'approval_mode = "prompt"' "$CFG")" = 1 ] \
  && grep -F 'tool bbj_format has approval_mode prompt (yours); left as is' "$WORK/out" > /dev/null \
  && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$CFG" | grep -c '^bbj_format prompt$')" = 1 ]; }; then
  gate local_user_value_kept ok "a prompt on bbj_format stays byte for byte and is named in the output, exit 0"
else
  gate local_user_value_kept FAIL "exit $RC: $(tr '\n' ';' < "$CFG" | head -c 500)"
fi
local_parse localuser "$CFG" https://example.invalid/mcp

# in every config of this section the check tools sit only in bbj-local tables, and bbj-local holds no server-wide key
if [ "$HAVE_TOML" = 1 ]; then
  bad=$(python3 -I -c '
import sys, tomllib
check = {"bbj_check_syntax", "bbj_format", "bbj_denum"}
bad = []
for path in open(sys.argv[1]).read().split():
    try:
        d = tomllib.load(open(path, "rb"))
    except (OSError, tomllib.TOMLDecodeError):
        bad.append(path + "(not parsed)")
        continue
    for name, srv in d.get("mcp_servers", {}).items():
        if name == "bbj-local":
            for key in ("default_tools_approval_mode", "required", "enabled", "startup_timeout_sec"):
                if key in srv:
                    bad.append(path + " bbj-local " + key)
        elif check & set(srv.get("tools", {})):
            bad.append(path + " " + name)
print(" ".join(bad))
' "$WORK/local.list")
  n=$(awk 'END { print NR }' "$WORK/local.list")
  [ -z "$bad" ] && gate local_check_tools_only_in_local_tables ok "$n configs: bbj_check_syntax, bbj_format and bbj_denum are named under no server but bbj-local; bbj-local has no default_tools_approval_mode, required, enabled or startup_timeout_sec" \
    || gate local_check_tools_only_in_local_tables FAIL "$bad"
else
  gate local_check_tools_only_in_local_tables skip "no python3 with tomllib"
fi

# quick 261013-cpn: bbj-local is a loopback server without sign-in: no config of this section or of the written
# list names bbj-local.oauth, and none holds the bbj-docs OAuth header twice
_obad=
_on=0
for _list in "$WORK/local.list" "$WORK/written.list"; do
  while IFS= read -r _f; do
    [ -f "$_f" ] || continue
    _on=$((_on + 1))
    grep -F 'bbj-local.oauth' "$_f" > /dev/null && _obad="$_obad $_f(bbj-local.oauth)"
    [ "$(grep -c -Fx "$OAUTH_HDR" "$_f")" -le 1 ] || _obad="$_obad $_f(header twice)"
  done < "$_list"
done
[ -z "$_obad" ] && gate oauth_never_for_local ok "$_on configs: none names bbj-local.oauth, none holds the bbj-docs OAuth header twice" \
  || gate oauth_never_for_local FAIL "$_obad"

# ---- plan 01-06: the tools/list probe (LOCAL-03, LOCAL-04, D-09, D-11, D-17) ----
# Without --with-local and with no bbj-local in config.toml the installer sends one static tools/list
# request to the probe URL (BBJ_LOCAL_MCP_URL, else the fixed url) and only suggests; with the flag
# it registers on every outcome and warns unless a bbj-ls answered. Every case here has the seam on a
# fake server or on the closed port, so a bbj-ls running on this machine is never contacted.
CLOSED_URL=http://127.0.0.1:9/mcp

# start_fake MODE: starts tests/fake_mcp.py, sets FAKE_PID, LOGF and BBJ_LOCAL_MCP_URL (the seam)
start_fake() {
  PORTF=$WORK/port.$1
  LOGF=$WORK/req.$1.log
  : > "$LOGF"
  rm -f "$PORTF"
  python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &
  FAKE_PID=$!
  FAKE_PIDS="$FAKE_PIDS $FAKE_PID"
  _w=0
  while [ ! -s "$PORTF" ] && [ "$_w" -lt 100 ]; do sleep 0.1; _w=$((_w + 1)); done
  [ -s "$PORTF" ] || { gate "fake_start_$1" FAIL "the fake server wrote no port file"; finish; }
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:$(cat "$PORTF")/mcp
  export BBJ_LOCAL_MCP_URL
}

# stop_fake: kills the fake and puts the seam back on the closed port, so later cases stay hermetic
stop_fake() {
  kill "$FAKE_PID" 2> /dev/null
  wait "$FAKE_PID" 2> /dev/null
  BBJ_LOCAL_MCP_URL=$CLOSED_URL
  export BBJ_LOCAL_MCP_URL
}

# nlines PREFIX: how many lines of the last run's stdout start with PREFIX
nlines() {
  grep -c -e "^$1" "$WORK/out"
}

if command -v python3 > /dev/null 2>&1; then
  newenv probefound
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  _sug=$(grep -e '^bbj-local: a bbj-ls answers at' "$WORK/out")
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if [ "$RC" = 0 ] && [ "$(nlines 'bbj-local: a bbj-ls answers at')" = 1 ] && printf '%s\n' "$_sug" | grep -F -e '--with-local' > /dev/null \
    && printf '%s\n' "$_sug" | grep -F -e "$LOCAL_URL_T" > /dev/null && ! grep -F bbj-local "$CFG" > /dev/null && [ "$_reqs" = 1 ]; then
    gate probe_found_suggests ok "a bbj-ls answers: exit 0, one suggestion line naming --with-local and $LOCAL_URL_T, no line of config.toml names bbj-local, one request"
  else
    gate probe_found_suggests FAIL "exit $RC, suggestions: $(nlines 'bbj-local: a bbj-ls answers at'), requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi
  cat > "$WORK/probe_shape.py" << 'PYEOF'
import json, sys
entries = [json.loads(l) for l in open(sys.argv[1], encoding="utf-8") if l.strip()]
if len(entries) != 1:
    print("FAIL %d requests" % len(entries))
    sys.exit(0)
r = entries[0]
h = r["headers"]
problems = []
if r["method"] != "POST" or r["path"] != "/mcp":
    problems.append("%s %s" % (r["method"], r["path"]))
if h.get("mcp-method") != "tools/list":
    problems.append("Mcp-Method %r" % h.get("mcp-method"))
if h.get("mcp-protocol-version") != "2026-07-28":
    problems.append("MCP-Protocol-Version %r" % h.get("mcp-protocol-version"))
if h.get("content-type") != "application/json":
    problems.append("Content-Type %r" % h.get("content-type"))
try:
    b = json.loads(r["body"])
except ValueError:
    b = {}
    problems.append("body is not JSON")
if b.get("method") != "tools/list":
    problems.append("method %r" % b.get("method"))
if list(b.get("params", {})) != ["_meta"]:
    problems.append("params %r" % list(b.get("params", {})))
if "arguments" in r["body"] or "code" in r["body"]:
    problems.append("the body names arguments or code")
print("FAIL " + "; ".join(problems) if problems else "ok")
PYEOF
  _shape=$(python3 -I "$WORK/probe_shape.py" "$LOGF" 2>&1)
  if [ "$_shape" = ok ]; then
    gate probe_request_shape ok "one POST /mcp: Mcp-Method tools/list, MCP-Protocol-Version 2026-07-28, Content-Type application/json; the body is a tools/list whose params hold only _meta and names neither arguments nor code (T-01-17)"
  else
    gate probe_request_shape FAIL "$_shape"
  fi
else
  gate probe_found_suggests skip "no python3"
  gate probe_request_shape skip "no python3"
fi

# ---- plan 01-06 Task 2: every other no-flag outcome is one line and writes nothing ----
# fake curl first on PATH (it logs its arguments and exits 7); the farm keeps the case free of codex
mkdir -p "$WORK/fbcurl"
cp "$REPO/tests/fake-bin/curl" "$WORK/fbcurl/curl"
FAKE_CURL_PATH=$WORK/fbcurl:$NO_CODEX

# the seam is at the closed port 127.0.0.1:9 (lib.sh, restored by stop_fake): nothing answers, curl exits 7
newenv probenone
run_inst "$WITH_CODEX"
CFG=$E_CODEX/config.toml
_line=$(grep -e '^bbj-local: no bbj-ls answered at http://127.0.0.1:9/mcp' "$WORK/out")
if [ "$RC" = 0 ] && [ "$(nlines 'bbj-local: no bbj-ls answered at')" = 1 ] && printf '%s\n' "$_line" | grep -F -e "$LOCAL_URL_T" > /dev/null \
  && printf '%s\n' "$_line" | grep -F -e '--with-local' > /dev/null && ! grep -F bbj-local "$CFG" > /dev/null; then
  gate probe_no_answer_no_flag ok "a closed port: exit 0, one 'no bbj-ls answered' line naming the probe url, $LOCAL_URL_T and --with-local, nothing about bbj-local in config.toml"
else
  gate probe_no_answer_no_flag FAIL "exit $RC, out: $(grep bbj-local "$WORK/out" | head -c 300)"
fi

newenv probenocurl
run_inst "$NO_CODEX"
CFG=$E_CODEX/config.toml
if [ "$RC" = 0 ] && [ "$(count 'bbj-local: not probed: curl not found.' "$WORK/out")" = 1 ] && ! grep -F bbj-local "$CFG" > /dev/null; then
  gate probe_no_curl ok "no curl on PATH: exit 0, the line 'bbj-local: not probed: curl not found.', nothing about bbj-local in config.toml"
else
  gate probe_no_curl FAIL "exit $RC, out: $(grep bbj-local "$WORK/out" | head -c 300)"
fi

if command -v python3 > /dev/null 2>&1; then
  newenv probeother
  start_fake tools-list-other
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if [ "$RC" = 0 ] && [ "$_reqs" = 1 ] && [ "$(nlines 'bbj-local: a bbj-ls answers')" = 0 ] && [ "$(nlines 'bbj-local: no bbj-ls answered at')" = 1 ] \
    && ! grep -F bbj-local "$CFG" > /dev/null; then
    gate probe_other_server_no_suggestion ok "another server on the port (a tool list without bbj_check_syntax): one request, no suggestion, the 'no bbj-ls answered' line, nothing written"
  else
    gate probe_other_server_no_suggestion FAIL "exit $RC, requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi
else
  gate probe_other_server_no_suggestion skip "no python3"
fi

# a seam that is not loopback http never reaches curl (T-01-18)
newenv proberefused
: > "$WORK/curl.refused"
BBJ_LOCAL_MCP_URL=http://example.invalid:5009/mcp
export BBJ_LOCAL_MCP_URL
FAKE_CURL_LOG=$WORK/curl.refused
export FAKE_CURL_LOG
run_inst "$FAKE_CURL_PATH"
unset FAKE_CURL_LOG
BBJ_LOCAL_MCP_URL=$CLOSED_URL
export BBJ_LOCAL_MCP_URL
CFG=$E_CODEX/config.toml
if [ "$RC" = 0 ] && [ ! -s "$WORK/curl.refused" ] && [ "$(nlines 'bbj-local: not probed:')" = 1 ] \
  && grep -e '^bbj-local: not probed:' "$WORK/out" | grep -F -e 'http://example.invalid:5009/mcp' > /dev/null && ! grep -F bbj-local "$CFG" > /dev/null; then
  gate probe_refuses_non_loopback_seam ok "BBJ_LOCAL_MCP_URL=http://example.invalid:5009/mcp: curl never called, one 'not probed:' line naming the value, exit 0, nothing written"
else
  gate probe_refuses_non_loopback_seam FAIL "exit $RC, curl log: $(head -c 200 "$WORK/curl.refused"), out: $(grep bbj-local "$WORK/out" | head -c 300)"
fi

# the one curl call: no .curlrc, no proxy, http only, short timeouts, no redirect, a static body (T-01-19, T-01-20, T-01-21)
newenv probeflags
: > "$WORK/curl.flags"
FAKE_CURL_LOG=$WORK/curl.flags
export FAKE_CURL_LOG
run_inst "$FAKE_CURL_PATH"
unset FAKE_CURL_LOG
_calls=$(grep -c -x CALL "$WORK/curl.flags")
_flags_ok=1
for _a in -q --noproxy '*' --proto =http --connect-timeout 2 -m 3 'Mcp-Method: tools/list' 'MCP-Protocol-Version: 2026-07-28' --url "$CLOSED_URL"; do
  grep -c -x -F -e "$_a" "$WORK/curl.flags" > /dev/null || { _flags_ok=0; _miss=$_a; }
done
_data=$(grep -A 1 -x -e '--data' "$WORK/curl.flags" | tail -n 1)
if [ "$RC" = 0 ] && [ "$_calls" = 1 ] && [ "$_flags_ok" = 1 ] && ! grep -E -x -e '-L|--location|-[A-Za-z]*L[A-Za-z]*' "$WORK/curl.flags" > /dev/null \
  && printf '%s\n' "$_data" | grep -F -e '"method":"tools/list"' > /dev/null && ! printf '%s\n' "$_data" | grep -F -e 'arguments' > /dev/null; then
  gate probe_curl_flags ok "one curl call with -q, --noproxy '*', --proto =http, --connect-timeout 2, -m 3, Mcp-Method and MCP-Protocol-Version headers, --url the seam, no -L or --location, a static tools/list body"
else
  gate probe_curl_flags FAIL "exit $RC, calls: $_calls, missing: ${_miss:-none}, data: $_data"
fi

# ---- plan 01-06 Task 3: --with-local probes first; every outcome registers, only "found" is silent (LOCAL-04) ----
# matrix_registered: the last run exited 0 and left exactly the managed bbj-local block at the fixed url
# with the three approvals (the registration never depends on the probe)
matrix_registered() {
  [ "$RC" = 0 ] && [ "$(count '[mcp_servers.bbj-local]' "$1")" = 1 ] && local_shape "$1" \
    && { [ "$HAVE_TOML" = 0 ] || [ "$(lsum "$1")" = "$(three_expected)" ]; }
}

# one_warning NEEDLE...: exactly one line starts with "bbj-local: warning:" and it holds every NEEDLE
# and the words "registering it anyway"
one_warning() {
  [ "$(nlines 'bbj-local: warning:')" = 1 ] || return 1
  _wl=$(grep -e '^bbj-local: warning:' "$WORK/out")
  printf '%s\n' "$_wl" | grep -F -e 'registering it anyway' > /dev/null || return 1
  for _n in "$@"; do
    printf '%s\n' "$_wl" | grep -F -e "$_n" > /dev/null || return 1
  done
  return 0
}

if command -v python3 > /dev/null 2>&1; then
  # found: a bbj-ls answers
  newenv matrixfound
  start_fake tools-list
  run_inst "$WITH_CODEX" --with-local
  stop_fake
  CFG=$E_CODEX/config.toml
  note_local "$CFG"
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if matrix_registered "$CFG" && [ "$_reqs" = 1 ] && [ "$(nlines 'bbj-local: a bbj-ls answers at')" = 1 ] && [ "$(nlines 'bbj-local: warning:')" = 0 ]; then
    gate with_local_probe_found_registers ok "a bbj-ls answers: one request, the managed block written (fixed url, three approvals), one 'a bbj-ls answers' line, no warning, exit 0"
  else
    gate with_local_probe_found_registers FAIL "exit $RC, requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 400)"
  fi
  local_parse matrixfound "$CFG" "$DEFAULT_URL"
else
  gate with_local_probe_found_registers skip "no python3"
fi

# no answer: the closed port
newenv matrixnone
run_inst "$WITH_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if matrix_registered "$CFG" && one_warning 'no bbj-ls answered at' "$CLOSED_URL" && [ "$(nlines 'bbj-local: a bbj-ls answers')" = 0 ]; then
  gate with_local_probe_fail_registers_and_warns ok "nothing answers: the managed block is written all the same, exactly one 'bbj-local: warning:' line naming the probe url and 'registering it anyway', exit 0"
else
  gate with_local_probe_fail_registers_and_warns FAIL "exit $RC, out: $(grep bbj-local "$WORK/out" | head -c 400)"
fi
local_parse matrixnone "$CFG" "$DEFAULT_URL"

# another server on the port
if command -v python3 > /dev/null 2>&1; then
  newenv matrixother
  start_fake tools-list-other
  run_inst "$WITH_CODEX" --with-local
  stop_fake
  CFG=$E_CODEX/config.toml
  note_local "$CFG"
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if matrix_registered "$CFG" && [ "$_reqs" = 1 ] && one_warning 'no bbj-ls answered at' && [ "$(nlines 'bbj-local: a bbj-ls answers')" = 0 ]; then
    gate with_local_probe_other_server_registers_and_warns ok "another server answers (no bbj_check_syntax): one request, the block written, exactly one warning line, no 'a bbj-ls answers' line, exit 0"
  else
    gate with_local_probe_other_server_registers_and_warns FAIL "exit $RC, requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 400)"
  fi
  local_parse matrixother "$CFG" "$DEFAULT_URL"
else
  gate with_local_probe_other_server_registers_and_warns skip "no python3"
fi

# no curl
newenv matrixnocurl
run_inst "$NO_CODEX" --with-local
CFG=$E_CODEX/config.toml
note_local "$CFG"
if matrix_registered "$CFG" && one_warning 'not probed: curl not found'; then
  gate with_local_probe_nocurl_registers_and_warns ok "no curl: the managed block is written, exactly one warning line 'not probed: curl not found' ... 'registering it anyway', exit 0"
else
  gate with_local_probe_nocurl_registers_and_warns FAIL "exit $RC, out: $(grep bbj-local "$WORK/out" | head -c 400)"
fi
local_parse matrixnocurl "$CFG" "$DEFAULT_URL"

# a seam that is not loopback http: refused before curl, registered all the same, example.invalid nowhere in config.toml
newenv matrixrefused
: > "$WORK/curl.matrix"
BBJ_LOCAL_MCP_URL=http://example.invalid:5009/mcp
export BBJ_LOCAL_MCP_URL
FAKE_CURL_LOG=$WORK/curl.matrix
export FAKE_CURL_LOG
run_inst "$FAKE_CURL_PATH" --with-local
unset FAKE_CURL_LOG
BBJ_LOCAL_MCP_URL=$CLOSED_URL
export BBJ_LOCAL_MCP_URL
CFG=$E_CODEX/config.toml
note_local "$CFG"
if matrix_registered "$CFG" && [ ! -s "$WORK/curl.matrix" ] && one_warning 'is not a loopback http URL' && ! grep -F 'example.invalid' "$CFG" > /dev/null; then
  gate with_local_probe_refused_registers_and_warns ok "a non-loopback seam: curl never called, the block written at the fixed url, exactly one warning line, example.invalid nowhere in config.toml, exit 0"
else
  gate with_local_probe_refused_registers_and_warns FAIL "exit $RC, curl log: $(head -c 100 "$WORK/curl.matrix"), out: $(grep bbj-local "$WORK/out" | head -c 400)"
fi
local_parse matrixrefused "$CFG" "$DEFAULT_URL"

# D-09: a managed block is refreshed without a probe
if command -v python3 > /dev/null 2>&1; then
  newenv probemanaged
  run_inst "$NO_CODEX" --with-local
  CFG=$E_CODEX/config.toml
  note_local "$CFG"
  cp "$CFG" "$WORK/cfg.managed"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  if [ "$RC" = 0 ] && [ ! -s "$LOGF" ] && cmp -s "$WORK/cfg.managed" "$CFG" && [ "$(nlines 'bbj-local: a bbj-ls answers')" = 0 ]; then
    gate local_rerun_without_flag_skips_probe ok "a managed block and no flag: the block is refreshed (byte-identical), no request reached the fake, no suggestion, exit 0"
  else
    gate local_rerun_without_flag_skips_probe FAIL "exit $RC, requests: $(awk 'END { print NR }' "$LOGF")"
  fi

  # a hand-registered bbj-local is never probed and never mentioned without the flag
  newenv probehand
  mkdir -p "$E_CODEX"
  docs_done "$E_CODEX/config.toml"
  printf '%s\n' '' '[mcp_servers.bbj-local]' "url = \"$LOCAL_URL_T\"" >> "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/cfg.hand"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  if [ "$RC" = 0 ] && [ ! -s "$LOGF" ] && cmp -s "$WORK/cfg.hand" "$CFG" && [ "$(nlines 'bbj-local:')" = 0 ]; then
    gate local_hand_registered_no_probe ok "a hand-registered bbj-local and no flag: no request, no bbj-local line of output, config.toml byte-identical, exit 0"
  else
    gate local_hand_registered_no_probe FAIL "exit $RC, requests: $(awk 'END { print NR }' "$LOGF"), out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi

  # a lone end marker is a comment: it counts as no bbj-local, so the probe runs and only suggests
  newenv probelone
  mkdir -p "$E_CODEX"
  docs_done "$E_CODEX/config.toml"
  printf '%s\n' '' "$LME" >> "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/cfg.lone"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if [ "$RC" = 0 ] && [ "$_reqs" = 1 ] && [ "$(nlines 'bbj-local: a bbj-ls answers at')" = 1 ] && cmp -s "$WORK/cfg.lone" "$CFG"; then
    gate local_lone_end_marker_without_flag_only_suggests ok "a lone end marker and no flag: one request, the suggestion line, config.toml byte-identical, exit 0"
  else
    gate local_lone_end_marker_without_flag_only_suggests FAIL "exit $RC, requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi

  # CR-01: both markers without a table and no flag: no probe, no suggestion, nothing written
  newenv probemarkers
  mkdir -p "$E_CODEX"
  docs_done "$E_CODEX/config.toml"
  printf '%s\n' '' "$LMB" "$LME" >> "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/cfg.markers"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  if [ "$RC" = 0 ] && [ ! -s "$LOGF" ] && cmp -s "$WORK/cfg.markers" "$CFG" && [ "$(nlines 'bbj-local:')" = 0 ]; then
    gate local_markers_without_table_no_probe ok "both markers, no table, no flag: no request reached the fake, no bbj-local line of output, config.toml byte-identical, exit 0"
  else
    gate local_markers_without_table_no_probe FAIL "exit $RC, requests: $(awk 'END { print NR }' "$LOGF"), out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi

  # WR-02: bbj-local inside a [projects] path is no registration, so the flagless run probes and suggests
  newenv probeprojects
  mkdir -p "$E_CODEX"
  docs_done "$E_CODEX/config.toml"
  printf '%s\n' '' '[projects."/home/u/src/bbj-local"]' 'trust_level = "trusted"' >> "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/cfg.projects"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  stop_fake
  CFG=$E_CODEX/config.toml
  _reqs=$(awk 'END { print NR }' "$LOGF")
  if [ "$RC" = 0 ] && [ "$_reqs" = 1 ] && [ "$(nlines 'bbj-local: a bbj-ls answers at')" = 1 ] && cmp -s "$WORK/cfg.projects" "$CFG"; then
    gate local_name_in_path_is_probed ok "bbj-local only in a [projects] path and no flag: one request, the suggestion line, config.toml byte-identical, exit 0"
  else
    gate local_name_in_path_is_probed FAIL "exit $RC, requests: $_reqs, out: $(grep bbj-local "$WORK/out" | head -c 300)"
  fi

  # the probe never changes the exit code: a foreign bbj-docs form still exits 3, the fixed form exits 0
  newenv probeexit
  mkdir -p "$E_CODEX"
  printf '%s\n' "[mcp_servers.'bbj-docs']" 'url = "https://example.invalid/mcp"' > "$E_CODEX/config.toml"
  start_fake tools-list
  run_inst "$WITH_CODEX"
  _rc_foreign=$RC
  : > "$E_CODEX/config.toml"
  docs_done "$E_CODEX/config.toml"
  run_inst "$WITH_CODEX"
  _rc_fixed=$RC
  _suggested=$(nlines 'bbj-local: a bbj-ls answers at')
  stop_fake
  if [ "$_rc_foreign" = 3 ] && [ "$_rc_fixed" = 0 ] && [ "$_suggested" = 1 ]; then
    gate probe_never_changes_exit ok "a foreign bbj-docs form with a suggestion still exits 3, the same home with the form fixed and a suggestion exits 0"
  else
    gate probe_never_changes_exit FAIL "foreign form exit $_rc_foreign, fixed form exit $_rc_fixed, suggestions: $_suggested"
  fi
else
  for _g in local_rerun_without_flag_skips_probe local_hand_registered_no_probe local_lone_end_marker_without_flag_only_suggests probe_never_changes_exit; do
    gate "$_g" skip "no python3"
  done
fi

# ---- the tool list has one source: the installer, the AGENTS snippet and the install page ----
inst_tools=$(sed -n 's/^DOCS_TOOLS=//p' "$INSTALLER" | head -n 1 | tr -d "'\"" | tr ' ' '\n' | sort)
snip_tools=$(sed -n 's/^- `\(bbj_[a-z_]*\)`:.*/\1/p' "$SNIPPET" | sort)
page_tools=$(sed -n 's/^ *\[mcp_servers\.bbj-docs\.tools\.\([a-z_]*\)\]$/\1/p' "$REPO/docs/install-codex.md" | sort)
if [ -n "$inst_tools" ] && [ "$inst_tools" = "$snip_tools" ] && [ "$inst_tools" = "$page_tools" ]; then
  gate tools_list_single_source ok "DOCS_TOOLS equals the tool bullets of AGENTS-snippet.md and the tool tables of docs/install-codex.md ($(printf '%s\n' "$inst_tools" | awk 'END { print NR }') tools)"
else
  gate tools_list_single_source FAIL "installer '$(printf '%s' "$inst_tools" | tr '\n' ' ')', snippet '$(printf '%s' "$snip_tools" | tr '\n' ' ')', page '$(printf '%s' "$page_tools" | tr '\n' ' ')'"
fi

# ---- quick 261013-cpn: the installer never starts a sign-in: no fake codex call of any case names oauth or login ----
cat "$WORK"/*/codex.log > "$WORK/codex.all" 2> /dev/null
if grep -q '^mcp add bbj-docs --url' "$WORK/codex.all" && ! grep -i -E 'oauth|login' "$WORK/codex.all" > /dev/null; then
  gate oauth_codex_never_logs_in ok "$(awk 'END { print NR }' "$WORK/codex.all") codex calls over all cases: only plain mcp add lines, none with oauth or login"
else
  gate oauth_codex_never_logs_in FAIL "$(grep -i -E 'oauth|login' "$WORK/codex.all" | head -n 3 | tr '\n' ';')"
fi

# ---- Phase 8 (CODEX-06, D-01 to D-05): --remove undoes what the installer wrote ----
# Every case has its own temp home; the installer is the real script, codex is the fake (or absent), and
# the proof is a content snapshot of the Codex home and the skills dir before the install and after the
# removal (home_snapshot), not a list of expected files.

# rm_env NAME: a fresh home whose Codex home and skills dir exist before the install, as in a real home
rm_env() {
  newenv "$1"
  mkdir -p "$E_CODEX" "$E_SKILLS"
}

# rm_user_cfg FILE: user content that ends in a non-blank line (a comment, a key, a blank line, a table)
rm_user_cfg() {
  printf '%s\n' '# my codex settings' 'model_reasoning_effort = "high"' '' '[projects."/src/x"]' 'trust_level = "trusted"' > "$1"
}

# rm_snap FILE: snapshot of the case's homes into FILE, without the backup line (the one file --remove keeps)
rm_snap() {
  home_snapshot "$E_CODEX" "$E_SKILLS" | grep -v -F "$E_CODEX/config.toml.bbj-backup" > "$1"
}

# rm_installed: 0 when the case's home holds an installer install (config entry, a skill, the script, hooks.json),
# so an equal before/after snapshot is not an empty round trip
rm_installed() {
  grep -F '[mcp_servers.bbj-docs]' "$E_CODEX/config.toml" > /dev/null 2>&1 \
    && [ -d "$E_SKILLS/bbj-programming" ] && [ -f "$E_CODEX/bbj/bbj-check.sh" ] && [ -f "$E_CODEX/hooks.json" ]
}

rm_env rmcodex
rm_user_cfg "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/rmcodex.cfg0"
rm_snap "$WORK/rmcodex.before"
run_inst "$WITH_CODEX"
RM_RC1=$RC
RM_LOG1=$(awk 'END { print NR }' "$E_LOG")
rm_installed && RM_INSTALLED=1 || RM_INSTALLED=0
run_inst "$WITH_CODEX" --remove
RM_RC2=$RC
cp "$WORK/out" "$WORK/rmcodex.out1"
cp "$WORK/err" "$WORK/rmcodex.err1"
RM_LOG2=$(awk 'END { print NR }' "$E_LOG")
rm_snap "$WORK/rmcodex.after"
if [ "$RM_RC1" = 0 ] && [ "$RM_INSTALLED" = 1 ] && [ "$RM_RC2" = 0 ] && _d=$(home_diff "$WORK/rmcodex.before" "$WORK/rmcodex.after"); then
  gate remove_round_trip_codex ok "install with the fake codex, then --remove: the Codex home and the skills dir equal the pre-install content, except the added config.toml.bbj-backup"
else
  gate remove_round_trip_codex FAIL "install exit $RM_RC1 (installed=$RM_INSTALLED), remove exit $RM_RC2: ${_d:-$(head -c 300 "$WORK/rmcodex.err1")}"
fi
if cmp -s "$E_CODEX/config.toml.bbj-backup" "$WORK/rmcodex.cfg0"; then
  gate remove_backup_kept ok "config.toml.bbj-backup is kept and equals the pre-install config.toml byte for byte"
else
  gate remove_backup_kept FAIL "the backup is missing or differs from the pre-install config.toml"
fi
if [ "$RM_LOG1" -gt 0 ] && [ "$RM_LOG1" = "$RM_LOG2" ]; then
  gate remove_never_calls_codex ok "the fake codex log holds $RM_LOG1 lines after the install and the same after --remove"
else
  gate remove_never_calls_codex FAIL "codex log lines: $RM_LOG1 after the install, $RM_LOG2 after --remove"
fi
if grep -F -e 'codex plugin marketplace add BBj-AI/bbj-agent-plugins' "$WORK/rmcodex.out1" > /dev/null \
  && grep -F -e 'codex plugin add bbj@basis-bbj' "$WORK/rmcodex.out1" > /dev/null && grep -F -e '/hooks' "$WORK/rmcodex.out1" > /dev/null; then
  gate remove_prints_next_steps ok "the output names codex plugin marketplace add BBj-AI/bbj-agent-plugins, codex plugin add bbj@basis-bbj and /hooks"
else
  gate remove_prints_next_steps FAIL "$(tail -n 4 "$WORK/rmcodex.out1" | tr '\n' ';')"
fi
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmcodex.afterfull"
run_inst "$WITH_CODEX" --remove
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmcodex.after2"
RM_NOTHING=$(grep -c 'nothing to remove' "$WORK/out")
if [ "$RC" = 0 ] && cmp -s "$WORK/rmcodex.afterfull" "$WORK/rmcodex.after2" && [ "$RM_NOTHING" = 6 ]; then
  gate remove_second_run_noop ok "a second --remove exits 0, changes nothing and says nothing to remove for the six objects"
else
  gate remove_second_run_noop FAIL "exit $RC, $RM_NOTHING nothing-to-remove lines: $(head -c 300 "$WORK/err"), $(home_diff "$WORK/rmcodex.afterfull" "$WORK/rmcodex.after2" | tr '\n' ';')"
fi
sh "$INSTALLER" --help > "$WORK/help.out" 2>&1
if grep -F -e '--remove' "$WORK/help.out" > /dev/null; then
  gate remove_usage ok "--help lists --remove"
else
  gate remove_usage FAIL "--help does not name --remove"
fi

# ---- --remove for every form the installer writes (CODEX-06, D-02, D-03) ----
# rm_cycle ENV PATHVALUE ARGS...: a pre-install snapshot, an install with ARGS under PATHVALUE, then --remove under
# the same PATHVALUE and the same ARGS minus nothing (--remove takes the install's --docs-url, never --with-local).
# Sets RM_RC1 and RM_RC2 (exit codes), RM_INSTALLED (1 when the install left an install behind) and the files
# $WORK/ENV.before, $WORK/ENV.after (snapshots without the backup line) and $WORK/ENV.cfg0 (the user config).
rm_cycle() {
  _rc_env=$1
  _rc_path=$2
  shift 2
  rm_env "$_rc_env"
  rm_user_cfg "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/$_rc_env.cfg0"
  rm_snap "$WORK/$_rc_env.before"
  run_inst "$_rc_path" "$@"
  RM_RC1=$RC
  rm_installed && RM_INSTALLED=1 || RM_INSTALLED=0
  _rc_url=
  for _rc_a in "$@"; do
    case "$_rc_a" in http://*) _rc_url=$_rc_a ;; esac
  done
  if [ -n "$_rc_url" ]; then run_inst "$_rc_path" --remove --docs-url "$_rc_url"; else run_inst "$_rc_path" --remove; fi
  RM_RC2=$RC
  rm_snap "$WORK/$_rc_env.after"
}

# rm_equal NAME OKTEXT: the gate for a cycle that must end at the pre-install home
rm_equal() {
  if [ "$RM_RC1" = 0 ] && [ "$RM_INSTALLED" = 1 ] && [ "$RM_RC2" = 0 ] && _d=$(home_diff "$WORK/$1.before" "$WORK/$1.after") \
    && cmp -s "$E_CODEX/config.toml" "$WORK/$1.cfg0"; then
    gate "$2" ok "$3"
  else
    gate "$2" FAIL "install exit $RM_RC1 (installed=$RM_INSTALLED), remove exit $RM_RC2: ${_d:-$(head -c 300 "$WORK/err")} $(tr '\n' ';' < "$E_CODEX/config.toml" 2> /dev/null | head -c 300)"
  fi
}

rm_cycle rmmanaged "$NO_CODEX"
rm_equal rmmanaged remove_round_trip_managed "no codex: the managed bbj-docs block, its marker lines and the blank line before it are gone; config.toml equals the pre-install bytes"

rm_cycle rmlocal "$NO_CODEX" --with-local
rm_equal rmlocal remove_round_trip_with_local "no codex, --with-local: both managed blocks are gone; config.toml equals the pre-install bytes"

# markers only: the documented manual removal (delete the lines between the markers) leaves four marker lines
rm_env rmmarkers
rm_user_cfg "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/rmmarkers.cfg0"
rm_snap "$WORK/rmmarkers.before"
run_inst "$NO_CODEX" --with-local
RM_RC1=$RC
awk '
  $0 == "# >>> bbj-agent-plugins (managed) >>>" || $0 == "# >>> bbj-agent-plugins bbj-local (managed) >>>" { print; skip = 1; next }
  $0 == "# <<< bbj-agent-plugins (managed) <<<" || $0 == "# <<< bbj-agent-plugins bbj-local (managed) <<<" { skip = 0 }
  !skip { print }
' "$E_CODEX/config.toml" > "$WORK/rmmarkers.hollow"
cat "$WORK/rmmarkers.hollow" > "$E_CODEX/config.toml"
RM_MARKERS=$(grep -c -e '^# [<>][<>][<>] bbj-agent-plugins' "$E_CODEX/config.toml")
run_inst "$NO_CODEX" --remove
RM_RC2=$RC
rm_snap "$WORK/rmmarkers.after"
if [ "$RM_RC1" = 0 ] && [ "$RM_MARKERS" = 4 ] && [ "$RM_RC2" = 0 ] && _d=$(home_diff "$WORK/rmmarkers.before" "$WORK/rmmarkers.after") \
  && cmp -s "$E_CODEX/config.toml" "$WORK/rmmarkers.cfg0"; then
  gate remove_markers_only ok "four marker lines and nothing between them (the manual removal): --remove deletes the markers and the blank lines before them; config.toml equals the pre-install bytes"
else
  gate remove_markers_only FAIL "install exit $RM_RC1, $RM_MARKERS markers, remove exit $RM_RC2: ${_d:-$(head -c 300 "$WORK/err")} $(tr '\n' ';' < "$E_CODEX/config.toml" | head -c 300)"
fi

# the form of versions up to 398aac5: url and default_tools_approval_mode, no tool tables, no OAuth table
rm_env rmoldkey
rm_user_cfg "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/rmoldkey.cfg0"
{
  cat "$WORK/rmoldkey.cfg0"
  printf '\n[mcp_servers.bbj-docs]\nurl = "%s"\ndefault_tools_approval_mode = "approve"\n' "$DEFAULT_URL"
} > "$E_CODEX/config.toml"
run_inst "$NO_CODEX" --remove
if [ "$RC" = 0 ] && cmp -s "$E_CODEX/config.toml" "$WORK/rmoldkey.cfg0" && ! grep -F 'bbj-docs' "$E_CODEX/config.toml" > /dev/null; then
  gate remove_old_key_form ok "the table with url and the server-wide approval line (versions up to 398aac5) is removed; config.toml holds only the user content"
else
  gate remove_old_key_form FAIL "exit $RC: $(tr '\n' ';' < "$E_CODEX/config.toml" | head -c 300) $(head -c 200 "$WORK/err")"
fi

# a registration at another url stays unless --remove gets the same --docs-url
CUSTOM_URL=http://127.0.0.1:7777/mcp
rm_env rmcustom
rm_user_cfg "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/rmcustom.cfg0"
run_inst "$WITH_CODEX" --docs-url "$CUSTOM_URL"
RM_RC1=$RC
cp "$E_CODEX/config.toml" "$WORK/rmcustom.installed"
run_inst "$WITH_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && cmp -s "$E_CODEX/config.toml" "$WORK/rmcustom.installed" \
  && grep -F "rerun with --docs-url $CUSTOM_URL" "$WORK/out" > /dev/null \
  && [ ! -e "$E_SKILLS/bbj-programming" ] && [ ! -e "$E_SKILLS/bbj-web-programming" ] && [ ! -e "$E_CODEX/bbj/bbj-check.sh" ] && [ ! -e "$E_CODEX/hooks.json" ]; then
  gate remove_custom_url_left ok "a bbj-docs table at $CUSTOM_URL is left in place (byte-identical), named with the rerun hint, exit 3; skills, script and hooks.json are removed"
else
  gate remove_custom_url_left FAIL "install exit $RM_RC1, remove exit $RC: $(head -c 400 "$WORK/out" | tr '\n' ';')"
fi
run_inst "$WITH_CODEX" --remove --docs-url "$CUSTOM_URL"
if [ "$RC" = 0 ] && cmp -s "$E_CODEX/config.toml" "$WORK/rmcustom.cfg0"; then
  gate remove_custom_url_with_flag ok "--remove with the same --docs-url removes the table; config.toml equals the pre-install bytes"
else
  gate remove_custom_url_with_flag FAIL "exit $RC: $(tr '\n' ';' < "$E_CODEX/config.toml" | head -c 300)"
fi

# a CRLF config.toml: the block the installer appends is CRLF, and its removal leaves the original bytes
rm_env rmcrlf
printf '# my codex settings\r\nmodel_reasoning_effort = "high"\r\n\r\n[projects."/src/x"]\r\ntrust_level = "trusted"\r\n' > "$E_CODEX/config.toml"
cp "$E_CODEX/config.toml" "$WORK/rmcrlf.cfg0"
run_inst "$NO_CODEX"
RM_RC1=$RC
rm_installed && RM_INSTALLED=1 || RM_INSTALLED=0
run_inst "$NO_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RM_INSTALLED" = 1 ] && [ "$RC" = 0 ] && cmp -s "$E_CODEX/config.toml" "$WORK/rmcrlf.cfg0"; then
  gate remove_crlf_config ok "CRLF config.toml with an appended managed block: --remove restores the original bytes"
else
  gate remove_crlf_config FAIL "install exit $RM_RC1 (installed=$RM_INSTALLED), remove exit $RC: $(od -c "$E_CODEX/config.toml" | head -n 6 | tr '\n' ';')"
fi

# install, remove, install: the second install equals the first, backup included
rm_env rmagain
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmagain.s1"
run_inst "$WITH_CODEX" --remove
RM_RC2=$RC
run_inst "$WITH_CODEX"
RM_RC3=$RC
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmagain.s2"
if [ "$RM_RC1" = 0 ] && [ "$RM_RC2" = 0 ] && [ "$RM_RC3" = 0 ] && _d=$(home_diff "$WORK/rmagain.s1" "$WORK/rmagain.s2"); then
  gate remove_reinstall_equals_first ok "install, --remove, install: the second home equals the first, config.toml.bbj-backup included"
else
  gate remove_reinstall_equals_first FAIL "exits $RM_RC1 $RM_RC2 $RM_RC3: $_d"
fi

# ---- --remove refusals: exit 2 before any write (CODEX-06, D-01, D-03; T-08-13, T-08-16) ----
# rm_refused ENV: the home after a fake-codex install holds a skill that differs from the shipped copy,
# so a refusal that wrongly went on to remove would be seen as a change of the snapshot
rm_refused() {
  rm_env "$1"
  rm_user_cfg "$E_CODEX/config.toml"
  run_inst "$WITH_CODEX"
  RM_RC1=$RC
  printf '# my own note\n' >> "$E_SKILLS/bbj-programming/SKILL.md"
  home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/$1.before"
  RM_LOG1=$(awk 'END { print NR }' "$E_LOG")
}

rm_refused rmwithlocal
run_inst "$WITH_CODEX" --remove --with-local
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmwithlocal.after"
if [ "$RM_RC1" = 0 ] && [ "$RC" = 2 ] && grep -F -e '--remove and --with-local cannot be combined' "$WORK/err" > /dev/null \
  && _d=$(home_diff "$WORK/rmwithlocal.before" "$WORK/rmwithlocal.after") && [ "$(awk 'END { print NR }' "$E_LOG")" = "$RM_LOG1" ]; then
  gate remove_refuses_with_local ok "--remove --with-local: exit 2, the message names the combination, the home snapshot is unchanged, codex not called"
else
  gate remove_refuses_with_local FAIL "install exit $RM_RC1, exit $RC: ${_d:-$(head -c 200 "$WORK/err")}"
fi

rm_refused rmforce
run_inst "$WITH_CODEX" --remove --force
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmforce.after"
if [ "$RM_RC1" = 0 ] && [ "$RC" = 2 ] && grep -F -e '--remove does not take --force' "$WORK/err" > /dev/null \
  && _d=$(home_diff "$WORK/rmforce.before" "$WORK/rmforce.after") && grep -F 'my own note' "$E_SKILLS/bbj-programming/SKILL.md" > /dev/null; then
  gate remove_refuses_force ok "--remove --force: exit 2, the message says a differing skill directory is the user's, the home snapshot is unchanged and the edited skill is still there"
else
  gate remove_refuses_force FAIL "install exit $RM_RC1, exit $RC: ${_d:-$(head -c 200 "$WORK/err")}"
fi

# a Codex home that does not exist holds nothing to remove: refused, and no directory is created for it
newenv rmmissing
run_inst "$WITH_CODEX" --remove --codex-home "$E_ROOT/no such home" --skills-dir "$E_ROOT/no such skills"
if [ "$RC" = 2 ] && grep -F -e 'is not a directory; nothing to remove' "$WORK/err" > /dev/null \
  && [ ! -e "$E_ROOT/no such home" ] && [ ! -e "$E_ROOT/no such skills" ] && [ ! -e "$E_HOME/.codex" ] && [ ! -e "$E_HOME/.agents" ]; then
  gate remove_refuses_missing_home ok "--remove with a missing Codex home: exit 2 'is not a directory; nothing to remove', no directory created"
else
  gate remove_refuses_missing_home FAIL "exit $RC: $(head -c 200 "$WORK/err")"
fi

# the refusal message carries the path as given: a backslash sequence in it is printed, not expanded (IN-04). The
# skills dir is a plain file here, so the pre-flight refuses it by name
newenv rmbackslash
mkdir -p "$E_CODEX"
RM_BS_SK="$E_ROOT/no\\tsuch"
: > "$RM_BS_SK"
run_inst "$WITH_CODEX" --remove --skills-dir "$RM_BS_SK"
if [ "$RC" = 2 ] && grep -F -e "install-codex: $RM_BS_SK is not a writable directory" "$WORK/err" > /dev/null; then
  gate remove_refusal_prints_path_verbatim ok "a backslash-t in --skills-dir reaches the refusal message unexpanded"
else
  gate remove_refusal_prints_path_verbatim FAIL "exit $RC: $(head -c 200 "$WORK/err")"
fi

# the existing newline check runs in remove mode too
rm_refused rmnewline
RM_NL='
'
run_inst "$WITH_CODEX" --remove --skills-dir "$E_ROOT/sk${RM_NL}x"
home_snapshot "$E_CODEX" "$E_SKILLS" > "$WORK/rmnewline.after"
if [ "$RM_RC1" = 0 ] && [ "$RC" = 2 ] && grep -F -e 'a directory name holds a newline' "$WORK/err" > /dev/null \
  && _d=$(home_diff "$WORK/rmnewline.before" "$WORK/rmnewline.after") && [ ! -e "$E_ROOT/sk${RM_NL}x" ]; then
  gate remove_refuses_newline ok "--remove with a newline in --skills-dir: exit 2, nothing changed"
else
  gate remove_refuses_newline FAIL "install exit $RM_RC1, exit $RC: ${_d:-$(head -c 200 "$WORK/err")}"
fi

# a Codex home and a skills dir whose names hold a space: install, then --remove, ends at the pre-install home
newenv rmspace
RM_SP_CODEX="$E_ROOT/codex home"
RM_SP_SKILLS="$E_ROOT/skills dir"
mkdir -p "$RM_SP_CODEX" "$RM_SP_SKILLS"
rm_user_cfg "$RM_SP_CODEX/config.toml"
cp "$RM_SP_CODEX/config.toml" "$WORK/rmspace.cfg0"
home_snapshot "$RM_SP_CODEX" "$RM_SP_SKILLS" | grep -v -F "$RM_SP_CODEX/config.toml.bbj-backup" > "$WORK/rmspace.before"
run_inst "$WITH_CODEX" --codex-home "$RM_SP_CODEX" --skills-dir "$RM_SP_SKILLS"
RM_RC1=$RC
[ -d "$RM_SP_SKILLS/bbj-programming" ] && [ -f "$RM_SP_CODEX/bbj/bbj-check.sh" ] && [ -f "$RM_SP_CODEX/hooks.json" ] && RM_INSTALLED=1 || RM_INSTALLED=0
run_inst "$WITH_CODEX" --remove --codex-home "$RM_SP_CODEX" --skills-dir "$RM_SP_SKILLS"
RM_RC2=$RC
home_snapshot "$RM_SP_CODEX" "$RM_SP_SKILLS" | grep -v -F "$RM_SP_CODEX/config.toml.bbj-backup" > "$WORK/rmspace.after"
if [ "$RM_RC1" = 0 ] && [ "$RM_INSTALLED" = 1 ] && [ "$RM_RC2" = 0 ] && _d=$(home_diff "$WORK/rmspace.before" "$WORK/rmspace.after") \
  && cmp -s "$RM_SP_CODEX/config.toml" "$WORK/rmspace.cfg0"; then
  gate remove_codex_home_with_space ok "a Codex home and a skills dir with a space in the name: install, then --remove, ends at the pre-install snapshot (the backup line aside)"
else
  gate remove_codex_home_with_space FAIL "install exit $RM_RC1 (installed=$RM_INSTALLED), remove exit $RM_RC2: ${_d:-$(head -c 300 "$WORK/err")}"
fi

# ---- --remove leaves what the installer did not write, byte for byte, with exit 3 (CODEX-06, D-02 to D-04; T-08-14, T-08-15) ----
# rm_docs_case NAME AWKPROGRAM: a fake-codex install, config.toml changed in one way by the awk program (-v hdr is the
# single-quoted bbj-docs header), then --remove. The case is good when the exit code is 3, config.toml is byte-identical to
# its changed state, and the output names bbj-docs as left in place. A failing case name is appended to RM_BAD. The change is
# built with awk into a new file, never with sed -i.
RM_BAD=
RM_SQHDR="[mcp_servers.'bbj-docs']"
rm_docs_case() {
  _rd_n=rmdocs$1
  rm_env "$_rd_n"
  rm_user_cfg "$E_CODEX/config.toml"
  run_inst "$WITH_CODEX"
  _rd_rc1=$RC
  cp "$E_CODEX/config.toml" "$WORK/$_rd_n.installed"
  awk -v hdr="$RM_SQHDR" "$2" "$WORK/$_rd_n.installed" > "$WORK/$_rd_n.changed"
  cat "$WORK/$_rd_n.changed" > "$E_CODEX/config.toml"
  run_inst "$WITH_CODEX" --remove
  if [ "$_rd_rc1" = 0 ] && ! cmp -s "$WORK/$_rd_n.installed" "$WORK/$_rd_n.changed" && [ "$RC" = 3 ] \
    && cmp -s "$E_CODEX/config.toml" "$WORK/$_rd_n.changed" && grep -F 'bbj-docs:' "$WORK/out" | grep -F 'left in place' > /dev/null; then :
  else
    RM_BAD="$RM_BAD $1(install $_rd_rc1, remove $RC)"
  fi
}

rm_docs_case a_extra_key '{ print } /^url = / && !d { print "startup_timeout_sec = 30"; d = 1 }'
rm_docs_case b_comment '{ print } /^url = / && !d { print "# my note on this server"; d = 1 }'
rm_docs_case c_own_oauth '/^client_id = / { print "client_id = \"my-own-client\""; next } { print }'
rm_docs_case d_other_approval '$0 == "[mcp_servers.bbj-docs.tools.bbj_search]" { t = 1 } t && /^approval_mode = / { print "approval_mode = \"prompt\""; t = 0; next } { print }'
rm_docs_case e_single_quoted_key '$0 == "[mcp_servers.bbj-docs]" { print hdr; next } { print }'
rm_docs_case f_extra_tool_table '{ print } END { print ""; print "[mcp_servers.bbj-docs.tools.bbj_check_syntax]"; print "approval_mode = \"approve\"" }'
if [ -z "$RM_BAD" ]; then
  gate remove_left_docs_forms ok "six bbj-docs forms the installer does not write (extra key, comment, own OAuth table, another approval_mode, single-quoted key, extra tool table bbj_check_syntax): exit 3, config.toml byte-identical, 'bbj-docs:' named as left in place"
else
  gate remove_left_docs_forms FAIL "failing sub-case(s):$RM_BAD"
fi

# a comment between the last installed table and a table of the user's leads into that table (WR-04): it is not
# content of bbj-docs, so --remove takes the installed tables and keeps the comment and the user's table. Two
# shapes: a user table follows, and the comment is the last thing in the file
RM_NOTE='# my note about the next'
rm_note_case() {
  _rn_n=rmnote$1
  rm_env "$_rn_n"
  rm_user_cfg "$E_CODEX/config.toml"
  cp "$E_CODEX/config.toml" "$WORK/$_rn_n.cfg0"
  run_inst "$WITH_CODEX"
  _rn_rc1=$RC
  printf '\n%s\n' "$RM_NOTE" >> "$E_CODEX/config.toml"
  if [ "$2" = table ]; then printf '[mcp_servers.zzz]\nurl = "https://example.invalid/mcp"\n' >> "$E_CODEX/config.toml"; fi
  { cat "$WORK/$_rn_n.cfg0"; printf '\n%s\n' "$RM_NOTE"; if [ "$2" = table ]; then printf '[mcp_servers.zzz]\nurl = "https://example.invalid/mcp"\n'; fi; } > "$WORK/$_rn_n.expected"
  run_inst "$WITH_CODEX" --remove
  if [ "$_rn_rc1" = 0 ] && [ "$RC" = 0 ] && cmp -s "$E_CODEX/config.toml" "$WORK/$_rn_n.expected" && ! grep -F 'bbj-docs' "$E_CODEX/config.toml" > /dev/null; then :
  else
    RM_BAD="$RM_BAD $2(install $_rn_rc1, remove $RC)"
  fi
}
RM_BAD=
rm_note_case a table
rm_note_case b eof
if [ -z "$RM_BAD" ]; then
  gate remove_keeps_comment_before_next_table ok "a comment after the last installed table, before a user table and at the end of the file: exit 0, the bbj-docs tables are gone, the comment and the user table are kept"
else
  gate remove_keeps_comment_before_next_table FAIL "failing sub-case(s):$RM_BAD"
fi

# a left-in-place report names the first offending line, once (WR-04): the comment inside the table (case b_comment)
rm_env rmwhy
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
awk '{ print } /^url = / && !d { print "# my note on this server"; d = 1 }' "$E_CODEX/config.toml" > "$WORK/rmwhy.changed"
cat "$WORK/rmwhy.changed" > "$E_CODEX/config.toml"
RM_WHY_LINE=$(awk '$0 == "# my note on this server" { print NR; exit }' "$E_CODEX/config.toml")
run_inst "$WITH_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && grep -F "left in place: line $RM_WHY_LINE of " "$WORK/out" > /dev/null \
  && ! grep -F 'form this script did not write; left in place: it is in a form this script did not write' "$WORK/out" > /dev/null; then
  gate remove_left_reason_names_line ok "a comment inside the bbj-docs table: left in place, the report names line $RM_WHY_LINE, no doubled sentence"
else
  gate remove_left_reason_names_line FAIL "exit $RC: $(grep -F 'bbj-docs:' "$WORK/out" | head -c 300)"
fi

# a bbj-local the installer did not write as its managed block: config.toml holds only the user content and that form
rm_local_case() {
  _rl_n=rmlocal$1
  rm_env "$_rl_n"
  rm_user_cfg "$E_CODEX/config.toml"
  { cat "$E_CODEX/config.toml"; printf '\n'; cat; } > "$WORK/$_rl_n.changed"
  cat "$WORK/$_rl_n.changed" > "$E_CODEX/config.toml"
  run_inst "$WITH_CODEX" --remove
  if [ "$RC" = 3 ] && cmp -s "$E_CODEX/config.toml" "$WORK/$_rl_n.changed" && grep -F 'bbj-local:' "$WORK/out" | grep -F 'left in place' > /dev/null; then :
  else
    RM_BAD="$RM_BAD $1(remove $RC)"
  fi
}
RM_BAD=
rm_local_case a_by_hand <<'EOF_LOCAL_A'
[mcp_servers.bbj-local]
url = "http://127.0.0.1:5009/mcp"
EOF_LOCAL_A
rm_local_case b_edited_block <<'EOF_LOCAL_B'
# >>> bbj-agent-plugins bbj-local (managed) >>>
[mcp_servers.bbj-local]
url = "http://127.0.0.1:5009/mcp"
startup_timeout_sec = 30

[mcp_servers.bbj-local.tools.bbj_check_syntax]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_format]
approval_mode = "approve"

[mcp_servers.bbj-local.tools.bbj_denum]
approval_mode = "approve"
# <<< bbj-agent-plugins bbj-local (managed) <<<
EOF_LOCAL_B
if [ -z "$RM_BAD" ]; then
  gate remove_left_local_forms ok "a bbj-local table registered by hand outside the markers and a managed block with an edited line: exit 3, config.toml byte-identical, 'bbj-local:' named as left in place"
else
  gate remove_left_local_forms FAIL "failing sub-case(s):$RM_BAD"
fi

# a skill directory that differs from the shipped copy is the user's: kept, with exit 3; the other objects still go
rm_env rmskilldiff
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
printf '# my own note on this skill\n' >> "$E_SKILLS/bbj-programming/SKILL.md"
rm -rf "$WORK/rmskilldiff.saved"
cp -R "$E_SKILLS/bbj-programming" "$WORK/rmskilldiff.saved"
run_inst "$WITH_CODEX" --remove
RM_RC2=$RC
if [ "$RM_RC1" = 0 ] && [ "$RM_RC2" = 3 ] && diff -r "$WORK/rmskilldiff.saved" "$E_SKILLS/bbj-programming" > /dev/null 2>&1 \
  && grep -F 'differs from the shipped copy; left in place' "$WORK/out" > /dev/null; then
  gate remove_left_skill_differs ok "a bbj-programming directory with one edited file: exit 3, diff -r against the saved copy is clean, 'differs from the shipped copy; left in place' printed"
else
  gate remove_left_skill_differs FAIL "install exit $RM_RC1, remove exit $RM_RC2: $(grep -F 'bbj-programming' "$WORK/out" | head -c 300)"
fi
# per object, not all or nothing: in that same run the installer's other objects are gone
if ! grep -F 'bbj-docs' "$E_CODEX/config.toml" > /dev/null && [ ! -e "$E_CODEX/bbj" ] && [ ! -e "$E_CODEX/hooks.json" ] && [ ! -e "$E_SKILLS/bbj-web-programming" ] && grep -F '# my codex settings' "$E_CODEX/config.toml" > /dev/null; then
  gate remove_left_others_removed ok "with a differing skill directory left, config.toml no longer names bbj-docs (user content kept), the check script and its directory, hooks.json and the identical skill are removed"
else
  gate remove_left_others_removed FAIL "config: $(tr '\n' ';' < "$E_CODEX/config.toml" | head -c 200); codex home: $(ls "$E_CODEX" | tr '\n' ' '); skills: $(ls "$E_SKILLS" | tr '\n' ' ')"
fi

# a skill directory that is a symbolic link: the link and its target are kept
rm_env rmskilllink
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
mkdir -p "$E_ROOT/outside"
mv "$E_SKILLS/bbj-web-programming" "$E_ROOT/outside/web"
ln -s "$E_ROOT/outside/web" "$E_SKILLS/bbj-web-programming"
cp -R "$E_ROOT/outside/web" "$WORK/rmskilllink.saved"
RM_LINK0=$(readlink "$E_SKILLS/bbj-web-programming")
run_inst "$WITH_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && [ -L "$E_SKILLS/bbj-web-programming" ] && [ "$(readlink "$E_SKILLS/bbj-web-programming")" = "$RM_LINK0" ] \
  && diff -r "$WORK/rmskilllink.saved" "$E_ROOT/outside/web" > /dev/null 2>&1 && grep -F 'symbolic link; left in place' "$WORK/out" > /dev/null; then
  gate remove_left_skill_symlink ok "a symlinked bbj-web-programming keeps its link and its target (diff -r clean): exit 3, 'symbolic link; left in place' printed"
else
  gate remove_left_skill_symlink FAIL "install exit $RM_RC1, remove exit $RC: $(grep -F 'bbj-web-programming' "$WORK/out" | head -c 300)"
fi

# --skills-dir that is the shipped skills of the checkout the script runs from (WR-01): a copy of the tree, so the
# real checkout is never at risk; --remove must leave the source in place, directly and through a symlink
rm_env rmsamedir
RM_COPY=$E_ROOT/tree
mkdir -p "$RM_COPY/codex" "$RM_COPY/plugins/bbj"
cp "$REPO/codex/install-codex.sh" "$REPO/codex/AGENTS-snippet.md" "$RM_COPY/codex/"
cp -R "$REPO/plugins/bbj/scripts" "$REPO/plugins/bbj/skills" "$RM_COPY/plugins/bbj/"
mkdir -p "$E_CODEX"
home_snapshot "$RM_COPY/plugins/bbj/skills" > "$WORK/rmsamedir.before"
env HOME="$E_HOME" CODEX_HOME="$E_CODEX" PATH="$WITH_CODEX" FAKE_CODEX_LOG="$E_LOG" sh "$RM_COPY/codex/install-codex.sh" \
  --remove --skills-dir "$RM_COPY/plugins/bbj/skills" > "$WORK/out" 2> "$WORK/err"
RM_RC1=$?
ln -s "$RM_COPY/plugins/bbj/skills" "$E_ROOT/skills-link"
env HOME="$E_HOME" CODEX_HOME="$E_CODEX" PATH="$WITH_CODEX" FAKE_CODEX_LOG="$E_LOG" sh "$RM_COPY/codex/install-codex.sh" \
  --remove --skills-dir "$E_ROOT/skills-link" > "$WORK/out2" 2> "$WORK/err2"
RM_RC2=$?
home_snapshot "$RM_COPY/plugins/bbj/skills" > "$WORK/rmsamedir.after"
if [ "$RM_RC1" = 3 ] && [ "$RM_RC2" = 3 ] && _d=$(home_diff "$WORK/rmsamedir.before" "$WORK/rmsamedir.after") \
  && [ -f "$RM_COPY/plugins/bbj/skills/bbj-programming/SKILL.md" ] && [ -f "$RM_COPY/plugins/bbj/skills/bbj-web-programming/SKILL.md" ] \
  && [ "$(grep -c 'is the shipped directory of this checkout; left in place' "$WORK/out")" = 2 ] \
  && [ "$(grep -c 'is the shipped directory of this checkout; left in place' "$WORK/out2")" = 2 ]; then
  gate remove_left_shipped_skills_dir ok "--skills-dir at the shipped skills of a copy of the tree, directly and through a symlink: exit 3, the source is untouched, both skills named as the shipped directory"
else
  gate remove_left_shipped_skills_dir FAIL "exits $RM_RC1 $RM_RC2: ${_d:-$(head -c 300 "$WORK/out")}"
fi

# a file of the user's in <codex home>/bbj keeps the directory
rm_env rmscriptdir
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
printf 'my notes\n' > "$E_CODEX/bbj/notes.txt"
run_inst "$WITH_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && [ ! -e "$E_CODEX/bbj/bbj-check.sh" ] && [ -d "$E_CODEX/bbj" ] && [ "$(cat "$E_CODEX/bbj/notes.txt")" = "my notes" ] \
  && grep -F 'holds other files; left in place' "$WORK/out" > /dev/null; then
  gate remove_left_script_dir_extra_file ok "notes.txt in <codex home>/bbj: the check script is gone, the file and the directory stay, exit 3, 'holds other files; left in place' printed"
else
  gate remove_left_script_dir_extra_file FAIL "install exit $RM_RC1, remove exit $RC: $(ls "$E_CODEX/bbj" 2> /dev/null | tr '\n' ' ')"
fi

# a hooks.json with a second entry: kept byte for byte, with the entry to delete by hand
rm_env rmhooksedit
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
awk '{ print } /"PostToolUse": \[/ { print "      { \"matcher\": \"Write\", \"hooks\": [] }," }' "$E_CODEX/hooks.json" > "$WORK/rmhooksedit.changed"
cat "$WORK/rmhooksedit.changed" > "$E_CODEX/hooks.json"
run_inst "$WITH_CODEX" --remove
RM_AFTERMSG=$(awk '/Delete this PostToolUse entry from it by hand/ { f = 1 } f && /"matcher": "apply_patch\|Edit\|Write"/ { n++ } END { print n + 0 }' "$WORK/out")
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && cmp -s "$E_CODEX/hooks.json" "$WORK/rmhooksedit.changed" && [ "$RM_AFTERMSG" -ge 1 ]; then
  gate remove_left_hooks_edited ok "a hooks.json with a second PostToolUse entry stays byte for byte: exit 3, the output prints the entry to delete by hand and its rendered block"
else
  gate remove_left_hooks_edited FAIL "install exit $RM_RC1, remove exit $RC, rendered-block lines after the message: $RM_AFTERMSG"
fi

# a hooks.json that is a symbolic link to an identical file: the link and the target stay
rm_env rmhookslink
rm_user_cfg "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
RM_RC1=$RC
mkdir -p "$E_ROOT/dots"
mv "$E_CODEX/hooks.json" "$E_ROOT/dots/hooks.json"
ln -s "$E_ROOT/dots/hooks.json" "$E_CODEX/hooks.json"
cp "$E_ROOT/dots/hooks.json" "$WORK/rmhookslink.saved"
run_inst "$WITH_CODEX" --remove
if [ "$RM_RC1" = 0 ] && [ "$RC" = 3 ] && [ -L "$E_CODEX/hooks.json" ] && [ "$(readlink "$E_CODEX/hooks.json")" = "$E_ROOT/dots/hooks.json" ] \
  && cmp -s "$E_ROOT/dots/hooks.json" "$WORK/rmhookslink.saved" && grep -F 'hooks.json' "$WORK/out" | grep -F 'symbolic link; left in place' > /dev/null; then
  gate remove_left_hooks_symlink ok "a symlinked hooks.json keeps its link and its identical target: exit 3, 'symbolic link; left in place' printed"
else
  gate remove_left_hooks_symlink FAIL "install exit $RM_RC1, remove exit $RC: $(grep -F 'hooks.json' "$WORK/out" | head -c 300)"
fi

# ---- a full install with the real codex on PATH: its own codex mcp add, then the same parse ----
if [ -n "$REAL_CODEX" ]; then
  newenv realcodex
  mkdir -p "$WORK/realbin"
  ln -s "$REAL_CODEX" "$WORK/realbin/codex"
  run_inst "$WORK/realbin:$SYSPATH:$(dirname "$REAL_CODEX")"
  CFG=$E_CODEX/config.toml
  note_cfg "$CFG"
  if [ "$RC" = 0 ] && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ]; } && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ] \
    && oauth_once "$CFG" && ! grep -F 'writing the block to config.toml instead' "$WORK/out" > /dev/null; then
    gate real_codex_install ok "codex mcp add by the real codex, then the OAuth table and the five tool tables, no claim of a block that is never written"
  else
    gate real_codex_install FAIL "exit $RC: $(head -c 300 "$WORK/err")"
  fi
  real_parse realcodex "$CFG" "$DEFAULT_URL"
fi

# ---- the real codex loads every config the installer wrote above ----
if [ -z "$REAL_CODEX" ]; then
  gate real_codex_parses_configs skip "no real codex (set BBJ_TEST_CODEX=/path/to/codex)"
elif [ -z "$RP_BAD" ]; then
  gate real_codex_parses_configs ok "$RP_N configs"
else
  gate real_codex_parses_configs FAIL "$RP_N configs, not loaded:$RP_BAD"
fi

# ---- no config the installer wrote names a hosted check tool: they keep Codex's prompt ----
named=
while IFS= read -r _f; do
  [ -f "$_f" ] || continue
  grep -E 'bbj_check_syntax|bbj_format|bbj_denum' "$_f" > /dev/null && named="$named $_f"
done < "$WORK/written.list"
[ -z "$named" ] && gate check_tools_never_named ok "$(awk 'END { print NR }' "$WORK/written.list") written configs: none names bbj_check_syntax, bbj_format or bbj_denum" || gate check_tools_never_named FAIL "named in:$named"

# ---- the real ~/.codex and ~/.agents were never touched ----
# MAINT-07, D-08 to D-10: content of the paths the installer can write; daemon files are ignored
home_snapshot "$REALHOME/.codex" "$REALHOME/.agents/skills" > "$WORK/home.after"
if _incomplete=$(home_incomplete "$WORK/home.before" "$WORK/home.after"); then
  # WR-02: an identical pair of incomplete snapshots proves nothing, so it is never reported ok
  gate real_home_untouched "$(home_incomplete_status)" "the snapshot of the real home cannot prove it unchanged: $_incomplete"
elif _changed=$(home_diff "$WORK/home.before" "$WORK/home.after"); then
  gate real_home_untouched ok "no watched path under the real ~/.codex or ~/.agents/skills changed (config.toml, config.toml.bbj-backup, hooks.json, bbj/, bbj-programming/, bbj-web-programming/, the six-character installer temp suffixes config.toml.XXXXXX and hooks.json.XXXXXX, and the existence of both parent directories)"
else
  gate real_home_untouched FAIL "changed: $(printf '%s' "$_changed" | tr '\n' ' ')"
fi

finish
