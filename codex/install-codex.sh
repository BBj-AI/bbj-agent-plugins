#!/bin/sh
# install-codex.sh -- Codex install script for the BBj docs server, the two BBj skills and the
# BBj check hook (plan 19-05, PLUG-04; decision D-15 of phase 19).
#
# Verified on Linux with Codex CLI 0.156.1 on 2026-10-08 (PLUG-04 human check: registered,
# hook approved in /hooks, a .bbj written through apply_patch got the compiler's feedback,
# skills found in ~/.agents/skills). Not yet run on Windows or macOS. The test suite runs it
# with a fake codex in a temp HOME.
#
# What it does, one factual line per step:
#   1. registers the read-only docs server as bbj-docs: "codex mcp add" when codex is on PATH,
#      else a managed block in config.toml; then approves the five docs tools by name, one
#      table [mcp_servers.bbj-docs.tools.NAME] with approval_mode = "approve" each, for
#      bbj_search, bbj_fetch_page, bbj_lookup, bbj_reserved_word and bbj_examples (they only
#      read). Nothing else of bbj-docs is approved, and no server-wide default is written: the
#      server may also list the hosted check tools bbj_check_syntax, bbj_format and bbj_denum,
#      which send your code to the server and keep Codex's normal prompt. An existing table
#      only gains the missing tool tables; config.toml.bbj-backup is written once before the
#      first change to an existing file. When bbj-docs is already named in config.toml in a
#      form this script does not edit (single-quoted key, spaced or indented header, dotted
#      key, sub-table), config.toml is left alone, the tables are printed and the exit code
#      is 3.
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
# the five read-only docs tools of bbj-docs, approved by name; one list, also checked against
# the tool bullets of AGENTS-snippet.md by the test suite
DOCS_TOOLS='bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples'
TOOL_KEY='approval_mode = "approve"'
# the server-wide line that versions up to 398aac5 of this script wrote; it is only ever
# recognised and removed, never written again
# shellcheck disable=SC2034  # used by the upgrade step
OLD_KEY_LINE='default_tools_approval_mode = "approve"'
STATUS_LINE='Verified on Linux with Codex CLI 0.156.1; not yet run on Windows or macOS.'

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

say "$STATUS_LINE"

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

# ---- 1. the docs server: registration and the per-tool approval ----
# analyze: one pass over config.toml (or nothing when it does not exist); prints
#   main=1|0     the [mcp_servers.bbj-docs] table is there (plain or quoted key, column 0)
#   mention=1|0  a line that is not a comment names bbj-docs in a form this script does not edit
#                (single-quoted key, indented or spaced header, dotted key, inline table, another
#                sub-table); our own [mcp_servers.bbj-docs.tools.NAME] headers do not count
#   tool.NAME=   missing | nokey | approve | other:VALUE, for each of the five docs tools
analyze() {
  src=$config
  [ -f "$src" ] || src=/dev/null
  awk -v tools="$DOCS_TOOLS" -v sq="'" '
    function val(l) {
      sub(/^[^=]*=/, "", l)
      sub(/[ \t]*#.*$/, "", l)
      gsub(/^[ \t]+|[ \t\r]+$/, "", l)
      if (l ~ /^".*"$/ || l ~ ("^" sq ".*" sq "$")) l = substr(l, 2, length(l) - 2)
      return l
    }
    BEGIN {
      n = split(tools, tl, " ")
      for (i = 1; i <= n; i++) st[tl[i]] = "missing"
    }
    {
      line = $0
      sub(/\r$/, "", line)
      if (line ~ /^[ \t]*\[/) {
        sect = "other"
        name = ""
        if (line ~ /^\[mcp_servers\.("bbj-docs"|bbj-docs)\][ \t]*(#.*)?$/) {
          sect = "main"
          main = 1
        } else if (line ~ /^\[mcp_servers\.("bbj-docs"|bbj-docs)\.tools\.[A-Za-z0-9_-]+\][ \t]*(#.*)?$/) {
          sect = "tool"
          name = line
          sub(/^\[mcp_servers\.("bbj-docs"|bbj-docs)\.tools\./, "", name)
          sub(/\].*$/, "", name)
          if (name in st) st[name] = "nokey"
        } else if (line ~ /bbj-docs/) {
          mention = 1
        }
      } else if (line !~ /^[ \t]*#/) {
        if (line ~ /bbj-docs/) mention = 1
        if (sect == "tool" && (name in st) && line ~ /^[ \t]*approval_mode[ \t]*=/) {
          v = val(line)
          st[name] = (v == "approve") ? "approve" : "other:" v
        }
      }
    }
    END {
      print "main=" (main ? 1 : 0)
      print "mention=" (mention ? 1 : 0)
      for (i = 1; i <= n; i++) print "tool." tl[i] "=" st[tl[i]]
    }' "$src"
}
analysis=
refresh() {
  analysis=$(analyze)
}
# an KEY: the value of one analysis line
an() {
  printf '%s\n' "$analysis" | sed -n "s/^$1=//p" | head -n 1
}
# tools_in_state STATE: the docs tools in that state, space separated
tools_in_state() {
  _out=
  for _t in $DOCS_TOOLS; do
    [ "$(an "tool.$_t")" = "$1" ] && _out="$_out $_t"
  done
  printf '%s' "${_out# }"
}
# print_block URL: what to put into config.toml by hand
print_block() {
  printf '%s\n' '[mcp_servers.bbj-docs]' "url = \"$1\""
  for _t in $DOCS_TOOLS; do
    printf '\n[mcp_servers.bbj-docs.tools.%s]\n%s\n' "$_t" "$TOOL_KEY"
  done
}

refresh
foreign=0
if [ "$(an main)" = 0 ] && [ "$(an mention)" = 1 ]; then foreign=1; fi
miss=$(tools_in_state missing)
need_change=0
if [ "$foreign" = 0 ] && { [ "$(an main)" = 0 ] || [ -n "$miss" ]; }; then
  need_change=1
fi
if [ "$need_change" = 1 ] && [ -f "$config" ] && [ ! -f "$config.bbj-backup" ]; then
  cp "$config" "$config.bbj-backup" || refuse "cannot write $config.bbj-backup"
  wrote="$wrote config.toml(backup)"
  say "config.toml: backup written to $config.bbj-backup"
fi

if [ "$foreign" = 0 ] && [ "$(an main)" = 0 ]; then
  if command -v codex > /dev/null 2>&1; then
    if CODEX_HOME=$codex_home codex mcp add bbj-docs --url "$docs_url" > /dev/null 2>&1; then
      say "bbj-docs: registered with codex mcp add bbj-docs --url $docs_url"
    else
      say "bbj-docs: codex mcp add did not succeed; writing the block to config.toml instead"
    fi
  fi
fi
# re-check: a registration by codex in a form this script does not know must not get a second table
refresh
if [ "$(an main)" = 0 ] && [ "$(an mention)" = 1 ]; then foreign=1; fi
if [ "$foreign" = 1 ]; then
  say "bbj-docs: $config already names bbj-docs in a form this script does not edit; config.toml was not modified."
  say "Check that it holds these tables (url and per-tool approval), or add them by hand:"
  print_block "$docs_url"
  pending=1
elif [ "$(an main)" = 0 ]; then
  # shellcheck disable=SC2094  # the group reads $config (its last byte) before the append writes it
  {
    if [ -s "$config" ]; then
      [ -z "$(tail -c 1 "$config")" ] || printf '\n'
      printf '\n'
    fi
    printf '%s\n' "$MARK_BEGIN" '[mcp_servers.bbj-docs]' "url = \"$docs_url\"" "$MARK_END"
  } >> "$config" || refuse "cannot write $config"
  wrote="$wrote config.toml"
  say "bbj-docs: appended a managed block to $config (url $docs_url)"
  refresh
elif [ "$need_change" = 0 ]; then
  say "bbj-docs: already registered in $config with the five docs tools approved; nothing changed"
fi
if [ "$foreign" = 0 ]; then
  miss=$(tools_in_state missing)
fi
if [ "$foreign" = 0 ] && [ -n "$miss" ]; then
  tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
  # shellcheck disable=SC2094  # awk reads $config and writes $tmp; the copy back happens after awk ends
  if awk -v miss="$miss" -v tool_key="$TOOL_KEY" -v mark_end="$MARK_END" '
      # the missing tool tables go at the end of the bbj-docs table body, before the blank
      # lines and comments that lead into the next table (or the end marker)
      function flush_main(atheader,   i, n, names) {
        if (!inmain) return
        inmain = 0
        n = split(miss, names, " ")
        for (i = 1; i <= n; i++) {
          print ""
          print "[mcp_servers.bbj-docs.tools." names[i] "]"
          print tool_key
        }
        if (n > 0 && atheader && !hasblank) print ""
        for (i = 1; i <= nb; i++) print buf[i]
        nb = 0
        hasblank = 0
      }
      {
        line = $0
        sub(/\r$/, "", line)
        if (inmain) {
          if (line == mark_end || line ~ /^[ \t]*\[/) {
            flush_main(line != mark_end)
          } else if (line ~ /^[ \t]*$/ || line ~ /^[ \t]*#/) {
            buf[++nb] = $0
            if (line ~ /^[ \t]*$/) hasblank = 1
            next
          } else {
            for (i = 1; i <= nb; i++) print buf[i]
            nb = 0
            hasblank = 0
          }
        }
        print
        if (line ~ /^\[mcp_servers\.("bbj-docs"|bbj-docs)\][ \t]*(#.*)?$/) inmain = 1
      }
      END { flush_main(0) }
    ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
    # written in place (not mv'd over it): a symlinked config.toml (dotfile managers) keeps
    # its link and every file keeps its mode (WR-01)
    rm -f "$tmp"
    wrote="$wrote config.toml"
    added=$(printf '%s' "$miss" | sed 's/ /, /g')
    say "bbj-docs: approved by name in $config: $added; every other tool of bbj-docs keeps Codex's prompt (the hosted check tools bbj_check_syntax, bbj_format and bbj_denum send your code to the server)"
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
say "- If Codex does not list the BBj skills, rerun with --skills-dir ~/.codex/skills (~/.agents/skills worked with Codex CLI 0.156.1)."
say "- commandWindows in hooks.json is not yet tried on Windows; if Codex rejects it there, use command_windows in config.toml instead."
say ""
say "$STATUS_LINE"

[ "$pending" = 0 ] || exit 3
exit 0
