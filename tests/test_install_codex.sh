#!/bin/sh
# tests/test_install_codex.sh -- plan 19-05 Task 2 (PLUG-04, D-15): codex/install-codex.sh in
# a temp HOME and CODEX_HOME with a fake codex. Every case has its own temp directories; the
# real ~/.codex and ~/.agents are never touched (gate real_home_untouched). Nothing here runs
# BBj. Codex runs only in the optional gate real_codex_parses_configs (BBJ_TEST_CODEX=/path/to/codex,
# else a codex on the caller's PATH), only as `codex mcp get bbj-docs` (and bbj-local) and `codex mcp add` in temp
# homes, never a session; without a codex that gate is a clean skip.
. "$(dirname "$0")/lib.sh"
mkwork

# the real codex of the optional gate, resolved before any case narrows PATH
REAL_CODEX=${BBJ_TEST_CODEX:-$(command -v codex 2> /dev/null)}
[ -n "$REAL_CODEX" ] && [ -x "$REAL_CODEX" ] || REAL_CODEX=

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

DEFAULT_URL=https://mcp.bbj-ai.com/mcp
HAVE_TOML=0
if command -v python3 > /dev/null 2>&1 && python3 -I -c 'import tomllib' 2> /dev/null; then HAVE_TOML=1; fi

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
  for _t in bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples; do
    printf '%s\n' "> [mcp_servers.bbj-docs.tools.$_t]" '> approval_mode = "approve"'
  done
} | sort > "$WORK/cfg.expected"
if [ "$RC" = 0 ] && [ "$removed" = 0 ] && cmp -s "$WORK/cfg.added" "$WORK/cfg.expected" \
  && [ "$(count 'url = "https://example.invalid/mcp"' "$CFG")" = 1 ] && [ "$(count '[mcp_servers.other]' "$CFG")" = 1 ] \
  && [ "$(awk 'END { print NR }' "$E_LOG")" = 0 ]; then
  gate existing_table_gains_tools ok "nothing removed, the added lines are the five headers and five approvals, url kept, codex not called"
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
[ "${FOREIGN_BAD:-0}" = 1 ] || gate foreign_toml_form ok "five spellings of bbj-docs: exit 3, config.toml byte-identical and parseable, no backup, codex not called, block printed"

# ---- WR-01: the approval key is written in place; a symlinked config.toml keeps its link and mode ----
newenv symlinkcfg
mkdir -p "$E_CODEX" "$E_ROOT/dots"
printf 'model = "x"\n\n[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n' > "$E_ROOT/dots/config.toml"
chmod 644 "$E_ROOT/dots/config.toml"
ln -s "$E_ROOT/dots/config.toml" "$E_CODEX/config.toml"
run_inst "$WITH_CODEX"
note_cfg "$E_ROOT/dots/config.toml"
if [ "$RC" = 0 ] && [ -L "$E_CODEX/config.toml" ] && [ "$(count 'approval_mode = "approve"' "$E_ROOT/dots/config.toml")" = 5 ] \
  && [ "$(count '[mcp_servers.bbj-docs.tools.bbj_search]' "$E_ROOT/dots/config.toml")" = 1 ] \
  && [ "$(ls -l "$E_ROOT/dots/config.toml" | cut -c1-10)" = "-rw-r--r--" ]; then
  gate approval_key_keeps_symlink_and_mode ok "the link survives, its target gained the five tool tables, mode 644 kept"
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
    && grep -Fx '[mcp_servers.bbj-docs.tools.bbj_examples]' "$WORK/out" > /dev/null && [ "$(grep -Fxc 'approval_mode = "approve"' "$WORK/out")" = 5 ]; then
    :
  else
    gate foreign_tool_forms FAIL "form $form: exit $RC, config changed, backup written or codex called"
    FTOOLS_BAD=1
  fi
done
[ "${FTOOLS_BAD:-0}" = 1 ] || gate foreign_tool_forms ok "five forms: exit 3, config.toml byte-identical, no backup, codex not called, the five tool tables printed"
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

# docs_done FILE: a plain bbj-docs table with its five approved tool tables, so the docs pass changes nothing
docs_done() {
  {
    printf '[mcp_servers.bbj-docs]\nurl = "https://example.invalid/mcp"\n'
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

# ---- the tool list has one source: the installer, the AGENTS snippet and the install page ----
inst_tools=$(sed -n 's/^DOCS_TOOLS=//p' "$INSTALLER" | head -n 1 | tr -d "'\"" | tr ' ' '\n' | sort)
snip_tools=$(sed -n 's/^- `\(bbj_[a-z_]*\)`:.*/\1/p' "$SNIPPET" | sort)
page_tools=$(sed -n 's/^ *\[mcp_servers\.bbj-docs\.tools\.\([a-z_]*\)\]$/\1/p' "$REPO/docs/install-codex.md" | sort)
if [ -n "$inst_tools" ] && [ "$inst_tools" = "$snip_tools" ] && [ "$inst_tools" = "$page_tools" ]; then
  gate tools_list_single_source ok "DOCS_TOOLS equals the tool bullets of AGENTS-snippet.md and the tool tables of docs/install-codex.md ($(printf '%s\n' "$inst_tools" | awk 'END { print NR }') tools)"
else
  gate tools_list_single_source FAIL "installer '$(printf '%s' "$inst_tools" | tr '\n' ' ')', snippet '$(printf '%s' "$snip_tools" | tr '\n' ' ')', page '$(printf '%s' "$page_tools" | tr '\n' ' ')'"
fi

# ---- a full install with the real codex on PATH: its own codex mcp add, then the same parse ----
if [ -n "$REAL_CODEX" ]; then
  newenv realcodex
  mkdir -p "$WORK/realbin"
  ln -s "$REAL_CODEX" "$WORK/realbin/codex"
  run_inst "$WORK/realbin:$SYSPATH:$(dirname "$REAL_CODEX")"
  CFG=$E_CODEX/config.toml
  note_cfg "$CFG"
  if [ "$RC" = 0 ] && { [ "$HAVE_TOML" = 0 ] || [ "$(tsum "$CFG")" = "$(five_expected "$DEFAULT_URL")" ]; } && [ "$(count 'approval_mode = "approve"' "$CFG")" = 5 ]; then
    gate real_codex_install ok "codex mcp add by the real codex, then the five tool tables"
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
touched=$(find "$REALHOME/.codex" "$REALHOME/.agents" -newer "$WORK/marker" 2> /dev/null | head -n 3)
[ -z "$touched" ] && gate real_home_untouched ok "nothing under the real ~/.codex or ~/.agents changed" || gate real_home_untouched FAIL "changed: $touched"

finish
