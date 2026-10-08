#!/bin/sh
# tests/test_install_codex.sh -- plan 19-05 Task 2 (PLUG-04, D-15): codex/install-codex.sh in
# a temp HOME and CODEX_HOME with a fake codex. Every case has its own temp directories; the
# real ~/.codex and ~/.agents are never touched (gate real_home_untouched). Nothing here runs
# BBj or Codex (the real-Codex check is a human test; it passed on Linux on 2026-10-08).
. "$(dirname "$0")/lib.sh"
mkwork

INSTALLER=$REPO/codex/install-codex.sh
SYSPATH=/usr/bin:/bin
REALHOME=${HOME:-/nonexistent}
: > "$WORK/marker"
sleep 1

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
for _t in sh cat cp mv mkdir rm diff cmp mktemp chmod dirname basename tr tail head awk sed grep printf ls wc sort uniq date pwd; do
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

# ---- first run, fake codex on PATH ----
newenv first
run_inst "$WITH_CODEX"
[ "$RC" = 0 ] && gate first_exit ok "exit 0" || gate first_exit FAIL "exit $RC: $(head -c 300 "$WORK/err")"
head -n 1 "$WORK/out" | grep 'not yet run on Windows or macOS' > /dev/null \
  && gate first_status_banner ok "first stdout line states the tested platforms" || gate first_status_banner FAIL "first line: $(head -n 1 "$WORK/out")"
grep -Fx 'mcp add bbj-docs --url https://bbj-mcp.basis-europe.eu/mcp' "$E_LOG" > /dev/null \
  && gate first_codex_mcp_add ok "codex mcp add bbj-docs --url <default>" || gate first_codex_mcp_add FAIL "log: $(cat "$E_LOG")"
CFG=$E_CODEX/config.toml
if [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] && [ "$(count 'default_tools_approval_mode = "approve"' "$CFG")" = 1 ]; then
  gate first_config_toml ok "one bbj-docs table, one approval key"
else
  gate first_config_toml FAIL "$(cat "$CFG" 2> /dev/null)"
fi
# the approval key sits inside the bbj-docs table
awk '/^\[/ { t = ($0 == "[mcp_servers.bbj-docs]") } t && /^default_tools_approval_mode = "approve"$/ { f = 1 } END { exit !f }' "$CFG" \
  && gate first_key_inside_table ok "key is in the bbj-docs table" || gate first_key_inside_table FAIL "key outside the table"
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
if [ "$RC" = 0 ] \
  && [ "$(count '# >>> bbj-agent-plugins (managed) >>>' "$CFG")" = 1 ] \
  && [ "$(count '# <<< bbj-agent-plugins (managed) <<<' "$CFG")" = 1 ] \
  && [ "$(count '[mcp_servers.bbj-docs]' "$CFG")" = 1 ] \
  && [ "$(count 'url = "https://bbj-mcp.basis-europe.eu/mcp"' "$CFG")" = 1 ] \
  && [ "$(count 'default_tools_approval_mode = "approve"' "$CFG")" = 1 ]; then
  gate managed_block ok "markers, table, url and approval key once each"
else
  gate managed_block FAIL "exit $RC: $(head -c 400 "$CFG" 2> /dev/null)"
fi
cp "$CFG" "$WORK/cfg.m1"
run_inst "$NO_CODEX"
cmp -s "$CFG" "$WORK/cfg.m1" && [ "$RC" = 0 ] && gate managed_block_idempotent ok "second run leaves it as is" || gate managed_block_idempotent FAIL "changed on second run"

# ---- an existing config.toml: only the approval key is added ----
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
added=$(grep -c '^>' "$WORK/cfg.diff")
removed=$(grep -c '^<' "$WORK/cfg.diff")
if [ "$RC" = 0 ] && [ "$added" = 1 ] && [ "$removed" = 0 ] && grep -Fx '> default_tools_approval_mode = "approve"' "$WORK/cfg.diff" > /dev/null \
  && awk '/^\[/ { t = ($0 == "[mcp_servers.bbj-docs]") } t && /^default_tools_approval_mode/ { f = 1 } END { exit !f }' "$CFG" \
  && [ "$(count 'url = "https://example.invalid/mcp"' "$CFG")" = 1 ] && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ]; then
  gate existing_table_gains_key ok "one line added inside bbj-docs, url kept, codex not called"
else
  gate existing_table_gains_key FAIL "exit $RC, added $added, removed $removed"
fi
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
    && grep -Fx 'default_tools_approval_mode = "approve"' "$WORK/out" > /dev/null; then
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
[ "${FOREIGN_BAD:-0}" = 1 ] || gate foreign_toml_form ok "five spellings of bbj-docs: exit 3, config.toml byte-identical and parseable, no backup, codex not called, block printed"

# ---- WR-01: the approval key is written in place; a symlinked config.toml keeps its link and mode ----
newenv symlinkcfg
mkdir -p "$E_CODEX" "$E_ROOT/dots"
printf 'model = "x"\n\n[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n' > "$E_ROOT/dots/config.toml"
chmod 644 "$E_ROOT/dots/config.toml"
ln -s "$E_ROOT/dots/config.toml" "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
if [ "$RC" = 0 ] && [ -L "$E_CODEX/config.toml" ] && grep -Fx 'default_tools_approval_mode = "approve"' "$E_ROOT/dots/config.toml" > /dev/null \
  && [ "$(ls -l "$E_ROOT/dots/config.toml" | cut -c1-10)" = "-rw-r--r--" ]; then
  gate approval_key_keeps_symlink_and_mode ok "the link survives, its target gained the key, mode 644 kept"
else
  gate approval_key_keeps_symlink_and_mode FAIL "exit $RC, link: $([ -L "$E_CODEX/config.toml" ] && echo kept || echo replaced)"
fi

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
newenv httpsother
run_inst "$WITH_CODEX" --docs-url https://docs.example.org/mcp
[ "$RC" = 0 ] && grep -Fx 'mcp add bbj-docs --url https://docs.example.org/mcp' "$E_LOG" > /dev/null \
  && gate docs_url_https_other ok "https to any host is accepted" || gate docs_url_https_other FAIL "exit $RC"

# ---- --skills-dir and --codex-home ----
newenv custom
run_inst "$WITH_CODEX" --skills-dir "$E_ROOT/sk" --codex-home "$E_ROOT/ch"
if [ "$RC" = 0 ] && [ -f "$E_ROOT/sk/bbj-programming/SKILL.md" ] && [ -f "$E_ROOT/ch/hooks.json" ] && [ -f "$E_ROOT/ch/bbj/bbj-check.sh" ] \
  && [ -f "$E_ROOT/ch/config.toml" ] && [ ! -e "$E_HOME/.agents" ] && [ ! -e "$E_CODEX" ]; then
  gate custom_dirs ok "everything under the given directories, nothing under HOME defaults"
else
  gate custom_dirs FAIL "exit $RC"
fi

# ---- Windows command field through cygpath ----
newenv cyg
run_inst "$WORK/fbcyg:$WITH_CODEX"
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

# ---- the real ~/.codex and ~/.agents were never touched ----
touched=$(find "$REALHOME/.codex" "$REALHOME/.agents" -newer "$WORK/marker" 2> /dev/null | head -n 3)
[ -z "$touched" ] && gate real_home_untouched ok "nothing under the real ~/.codex or ~/.agents changed" || gate real_home_untouched FAIL "changed: $touched"

finish
