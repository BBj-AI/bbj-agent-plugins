#!/bin/sh
# install-codex.sh -- Codex install script for the BBj docs server, the two BBj skills and the
# BBj check hook (plan 19-05, PLUG-04; decision D-15 of phase 19).
#
# UNRUN: this script has not been verified on a machine with Codex yet. Codex was not
# available where it was written; it is tested with a fake codex in a temp HOME only, and
# the Codex facts it relies on come from OpenAI's documentation. PLUG-04 stays unrun until a
# Codex machine passes the human check (register, approve the hook in /hooks, let Codex write
# a .bbj through apply_patch, see the compiler's feedback).
#
# What it does, one factual line per step:
#   1. registers the read-only docs server as bbj-docs: "codex mcp add" when codex is on PATH,
#      else a managed block in config.toml; then makes sure the bbj-docs table holds
#      default_tools_approval_mode = "approve" (the docs server only reads; nothing else is
#      approved). An existing table only gains that one line; config.toml.bbj-backup is
#      written once before the first change to an existing file. When bbj-docs is already
#      named in config.toml in a form this script does not edit (single-quoted key, spaced or
#      indented header, dotted key, sub-table), config.toml is left alone, the block is
#      printed and the exit code is 3.
#   2. copies the two skills to the skills directory (default ~/.agents/skills); a directory
#      that differs is left alone unless --force.
#   3. copies the shared check script to <codex home>/bbj/bbj-check.sh, a stable path outside
#      any plugin cache.
#   4. writes <codex home>/hooks.json with an apply_patch matcher, only when that file does not
#      exist; an existing hooks.json is never modified (exit 3 with the block to merge by hand).
#   5. prints the AGENTS.md snippet, the /hooks trust step and the known gaps.
#
# Options: --docs-url URL (default DEFAULT_DOCS_URL, the same value as the bbj plugin's
# docs_url default; plain http only to 127.0.0.1, localhost or [::1]), --skills-dir DIR,
# --codex-home DIR (default $CODEX_HOME or ~/.codex), --force, --help.
# Exit codes: 0 done, 2 usage error or refusal, 3 finished with something
# left to merge or decide by hand.
#
# Exit 2 before the first write means nothing was changed: the options are validated and every
# destination (skills directory, <codex home>/bbj, config.toml) is created or checked up front.
# A failure after a step has run still exits 2 and names the steps that already ran.
#
# It never runs BBj and never calls a compiler; the hook it installs follows the same
# never-execute rule. POSIX sh plus awk, sed, grep, cp, mv, cmp, diff, mktemp.

DEFAULT_DOCS_URL=https://bbj-mcp.basis-europe.eu/mcp
MARK_BEGIN='# >>> bbj-agent-plugins (managed) >>>'
MARK_END='# <<< bbj-agent-plugins (managed) <<<'
KEY_LINE='default_tools_approval_mode = "approve"'
UNRUN_LINE='UNRUN: install-codex.sh has not been verified on a machine with Codex yet (PLUG-04).'

say() {
  printf '%s\n' "$*"
}

wrote=
refuse() {
  echo "install-codex: $*" >&2
  [ -z "$wrote" ] || echo "install-codex: steps that had already run: $wrote" >&2
  exit 2
}

usage() {
  cat <<EOF
Usage: sh codex/install-codex.sh [--docs-url URL] [--skills-dir DIR] [--codex-home DIR] [--force]

  --docs-url URL     docs server URL (default $DEFAULT_DOCS_URL);
                     https anywhere, http only to 127.0.0.1, localhost or [::1]
  --skills-dir DIR   where the skills go (default \$HOME/.agents/skills)
  --codex-home DIR   Codex home (default \$CODEX_HOME, else \$HOME/.codex)
  --force            replace a skill directory that differs from the shipped one
  --help             this text

Exit: 0 done, 2 refused (nothing written unless the message names the steps that ran),
      3 done except something to merge by hand.
EOF
}

say "$UNRUN_LINE"

docs_url=$DEFAULT_DOCS_URL
skills_dir=
codex_home=
force=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --docs-url) [ "$#" -ge 2 ] || refuse "--docs-url needs a value"; docs_url=$2; shift 2 ;;
    --skills-dir) [ "$#" -ge 2 ] || refuse "--skills-dir needs a value"; skills_dir=$2; shift 2 ;;
    --codex-home) [ "$#" -ge 2 ] || refuse "--codex-home needs a value"; codex_home=$2; shift 2 ;;
    --force) force=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) refuse "unknown option: $1 (see --help)" ;;
  esac
done

# the docs URL goes into config.toml and into one codex call: no whitespace, quote, backslash,
# apostrophe, userinfo or control character; https anywhere, plain http only to loopback
case "$docs_url" in
  *[![:print:]]*|*[[:space:]]*|*'"'*|*'\'*|*"'"*|*@*) refuse "--docs-url holds a character that is not allowed" ;;
esac
case "$docs_url" in
  https://?*) ;;
  http://127.0.0.1|http://127.0.0.1[:/]*) ;;
  http://localhost|http://localhost[:/]*) ;;
  'http://[::1]'|'http://[::1]'[:/]*) ;;
  *) refuse "--docs-url must be https://..., or http:// to 127.0.0.1, localhost or [::1] (no clear text over the network)" ;;
esac

if [ -z "$skills_dir" ]; then
  [ -n "${HOME:-}" ] || refuse "HOME is not set; give --skills-dir"
  skills_dir=$HOME/.agents/skills
fi
if [ -z "$codex_home" ]; then
  if [ -n "${CODEX_HOME:-}" ]; then
    codex_home=$CODEX_HOME
  else
    [ -n "${HOME:-}" ] || refuse "HOME is not set; give --codex-home"
    codex_home=$HOME/.codex
  fi
fi
nl='
'
case "$skills_dir$codex_home" in
  *"$nl"*) refuse "a directory name holds a newline" ;;
esac
# the codex home ends up inside the hook command that Codex runs through a shell on every
# apply_patch (hooks.json): no character that a double-quoted shell word would expand or end
case "$codex_home" in
  *'$'*|*'`'*|*'"'*|*'\'*|*"'"*) refuse "--codex-home holds a character that is not allowed in a hook command (one of \$ \` \" \\ ')" ;;
esac

# the checkout this script belongs to
here=$(cd "$(dirname "$0")" && pwd) || refuse "cannot locate this script"
repo=$(cd "$here/.." && pwd) || refuse "cannot locate the repository"
src_script=$repo/plugins/bbj/scripts/bbj-check.sh
src_skills=$repo/plugins/bbj/skills
snippet=$here/AGENTS-snippet.md
for f in "$src_script" "$snippet" "$src_skills/bbj-programming/SKILL.md" "$src_skills/bbj-web-programming/SKILL.md"; do
  [ -f "$f" ] || refuse "missing $f (run this script from a checkout of bbj-agent-plugins)"
done

pending=0
mkdir -p "$codex_home" || refuse "cannot create $codex_home"
codex_home=$(cd "$codex_home" && pwd) || refuse "cannot enter $codex_home"
case "$codex_home" in
  *'$'*|*'`'*|*'"'*|*'\'*|*"'"*) refuse "$codex_home holds a character that is not allowed in a hook command (one of \$ \` \" \\ ')" ;;
esac
config=$codex_home/config.toml

# pre-flight (WR-02): create or check every destination before the first write, so a refusal
# here changes nothing in config.toml, hooks.json or the skills
script_dst=$codex_home/bbj/bbj-check.sh
script_dir=$(dirname "$script_dst")
mkdir -p "$skills_dir" || refuse "cannot create $skills_dir"
mkdir -p "$script_dir" || refuse "cannot create $script_dir"
for d in "$codex_home" "$script_dir" "$skills_dir"; do
  [ -d "$d" ] && [ -w "$d" ] || refuse "$d is not a writable directory"
done
[ ! -e "$config" ] || [ -w "$config" ] || refuse "$config is not writable"
[ ! -e "$script_dst" ] || [ -w "$script_dst" ] || refuse "$script_dst is not writable"

# ---- 1. the docs server: registration and the approval mode ----
# has_table: the bbj-docs table is in config.toml (plain or quoted key)
has_table() {
  [ -f "$config" ] && grep -E '^\[mcp_servers\.("bbj-docs"|bbj-docs)\][[:space:]]*(#.*)?$' "$config" > /dev/null
}
# mentions_docs: a line that is not a comment names bbj-docs in some form has_table does not
# edit (single-quoted key, indented or spaced header, dotted key, inline table, a sub-table).
# Appending our own table next to it would declare the table twice and Codex could no longer
# parse config.toml, so the installer then changes nothing in config.toml (CR-01).
mentions_docs() {
  [ -f "$config" ] && grep -v -E '^[[:space:]]*#' "$config" | grep -F 'bbj-docs' > /dev/null
}
# key_state: "has" when the bbj-docs table holds an approval key, else "missing"
key_state() {
  awk '
    /^\[mcp_servers\.("bbj-docs"|bbj-docs)\][ \t\r]*(#.*)?$/ { t = 1; next }
    /^\[/ { t = 0 }
    t && /^[ \t]*default_tools_approval_mode[ \t]*=/ { has = 1 }
    END { print (has ? "has" : "missing") }' "$config"
}

foreign=0
if ! has_table && mentions_docs; then foreign=1; fi
need_change=0
if [ "$foreign" = 1 ]; then
  need_change=0
elif ! has_table; then
  need_change=1
elif [ "$(key_state)" = missing ]; then
  need_change=1
fi
if [ "$need_change" = 1 ] && [ -f "$config" ] && [ ! -f "$config.bbj-backup" ]; then
  cp "$config" "$config.bbj-backup" || refuse "cannot write $config.bbj-backup"
  wrote="$wrote config.toml(backup)"
  say "config.toml: backup written to $config.bbj-backup"
fi

if [ "$foreign" = 0 ] && ! has_table; then
  if command -v codex > /dev/null 2>&1; then
    if CODEX_HOME=$codex_home codex mcp add bbj-docs --url "$docs_url" > /dev/null 2>&1; then
      say "bbj-docs: registered with codex mcp add bbj-docs --url $docs_url"
    else
      say "bbj-docs: codex mcp add did not succeed; writing the block to config.toml instead"
    fi
  fi
fi
# re-check: a registration by codex in a form has_table does not know must not get a second table
if ! has_table && mentions_docs; then foreign=1; fi
if [ "$foreign" = 1 ]; then
  say "bbj-docs: $config already names bbj-docs in a form this script does not edit; config.toml was not modified."
  say "Check that it holds this block (url and approval mode), or add it by hand:"
  printf '%s\n' '[mcp_servers.bbj-docs]' "url = \"$docs_url\"" "$KEY_LINE"
  pending=1
elif ! has_table; then
  {
    if [ -s "$config" ]; then
      [ -z "$(tail -c 1 "$config")" ] || printf '\n'
      printf '\n'
    fi
    printf '%s\n' "$MARK_BEGIN" '[mcp_servers.bbj-docs]' "url = \"$docs_url\"" "$KEY_LINE" "$MARK_END"
  } >> "$config" || refuse "cannot write $config"
  wrote="$wrote config.toml"
  say "bbj-docs: appended a managed block to $config (url $docs_url, tools approved)"
elif [ "$need_change" = 0 ]; then
  say "bbj-docs: already registered in $config with the approval mode set; nothing changed"
fi
if has_table && [ "$(key_state)" = missing ]; then
  tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
  if awk -v key="$KEY_LINE" '
      { print }
      /^\[mcp_servers\.("bbj-docs"|bbj-docs)\][ \t\r]*(#.*)?$/ && !done { print key; done = 1 }
    ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
    # written in place (not mv'd over it): a symlinked config.toml (dotfile managers) keeps
    # its link and every file keeps its mode (WR-01)
    rm -f "$tmp"
    wrote="$wrote config.toml"
    say "bbj-docs: added $KEY_LINE to the existing table in $config; its url is left as is"
  else
    rm -f "$tmp"
    refuse "cannot update $config"
  fi
fi

# ---- 2. the skills ----
for s in bbj-programming bbj-web-programming; do
  src=$src_skills/$s
  dst=$skills_dir/$s
  if [ ! -e "$dst" ]; then
    mkdir -p "$skills_dir" || refuse "cannot create $skills_dir"
    cp -R "$src" "$dst" || refuse "cannot copy $src to $dst"
    wrote="$wrote skill:$s"
    say "skill $s: installed to $dst"
  elif diff -r "$src" "$dst" > /dev/null 2>&1; then
    say "skill $s: $dst is identical; nothing changed"
  elif [ "$force" = 1 ]; then
    rm -rf "$dst" && cp -R "$src" "$dst" || refuse "cannot replace $dst"
    wrote="$wrote skill:$s"
    say "skill $s: $dst differed and was replaced (--force)"
  else
    say "skill $s: $dst differs from the shipped copy and was left untouched; rerun with --force to replace it"
    pending=1
  fi
done

# ---- 3. the check script, at a stable path outside any plugin cache ----
mkdir -p "$script_dir" || refuse "cannot create $script_dir"
if cmp -s "$src_script" "$script_dst"; then
  say "check script: $script_dst is current; nothing changed"
else
  cp "$src_script" "$script_dst" || refuse "cannot copy the check script"
  wrote="$wrote check-script"
  say "check script: copied to $script_dst (every update of it makes Codex ask for the /hooks review again)"
fi
chmod 755 "$script_dst"

# ---- 4. hooks.json: written only when absent ----
# json_str VALUE: VALUE as the body of a JSON string
json_str() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}
hook_cmd="sh \"$script_dst\""
hook_cmd_win=$hook_cmd
if command -v cygpath > /dev/null 2>&1; then
  w_sh=$(cygpath -w "$(command -v sh)")
  w_script=$(cygpath -w "$script_dst")
  hook_cmd_win="\"$w_sh\" \"$w_script\""
fi
hooks=$codex_home/hooks.json
tmp=$(mktemp "$codex_home/hooks.json.XXXXXX") || refuse "cannot create a temp file in $codex_home"
printf '{\n  "hooks": {\n    "PostToolUse": [\n      {\n        "matcher": "apply_patch|Edit|Write",\n        "hooks": [\n          {\n            "type": "command",\n            "command": "%s",\n            "commandWindows": "%s",\n            "timeout": 30\n          }\n        ]\n      }\n    ]\n  }\n}\n' \
  "$(json_str "$hook_cmd")" "$(json_str "$hook_cmd_win")" > "$tmp"
if [ ! -e "$hooks" ]; then
  mv "$tmp" "$hooks" || { rm -f "$tmp"; refuse "cannot write $hooks"; }
  say "hooks.json: written to $hooks (PostToolUse, matcher apply_patch|Edit|Write, timeout 30)"
elif cmp -s "$tmp" "$hooks"; then
  rm -f "$tmp"
  say "hooks.json: $hooks already holds this hook; nothing changed"
else
  say "hooks.json: $hooks exists and was not written by this script; it was not modified."
  say "Merge this hook into it by hand (a PostToolUse entry), then review it in /hooks:"
  cat "$tmp"
  rm -f "$tmp"
  pending=1
fi

# ---- 5. the AGENTS.md snippet, the trust step, the gaps ----
say ""
say "Add the following to AGENTS.md in your repository, or to $codex_home/AGENTS.md (AGENTS.md files share a 32 KiB cap; a plugin cannot ship one):"
say "----8<----"
cat "$snippet"
say "----8<----"
say ""
say "Trust step: Codex skips a hook it did not manage until you review it. Start Codex, open /hooks, and approve the BBj check hook."
say "The review is pinned to a hash of the script: a changed bbj-check.sh asks again. This script cannot approve it for you."
say ""
say "Known gaps:"
say "- OpenAI calls hooks \"a useful guardrail, not a complete enforcement boundary\"."
say "- Patches applied through a shell heredoc are not seen by the hook; only apply_patch calls are checked."
say "- Codex has no plugin options here: the check finds BBj through BBJ_HOME, then PATH, then the default homes; set BBJ_HOME when BBj is not in a default location."
say "- With no compiler found, the hook asks a running bbj-ls on 127.0.0.1:5009 (syntax only); with neither it does nothing and says nothing."
say "- If Codex does not list the BBj skills, rerun with --skills-dir ~/.codex/skills (the skills location is documentation-derived)."
say "- If Codex does not accept commandWindows in hooks.json, use command_windows in config.toml instead."
say ""
say "$UNRUN_LINE Confirm it on a machine with Codex before relying on it."

[ "$pending" = 0 ] || exit 3
exit 0
