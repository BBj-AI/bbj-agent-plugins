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
#      first change to an existing file. A docs tool you set to another approval_mode keeps it
#      and is named in the output. Upgrade: versions up to 398aac5 wrote
#      default_tools_approval_mode = "approve" into the bbj-docs table, which approved every
#      tool of the server; a rerun removes exactly that line and says so. Any other
#      default_tools_approval_mode is left alone and reported, and when it still approves
#      every tool (the same value in another spelling) the exit code is 3. Tool tables
#      without the bbj-docs table (Codex cannot load that) get the table added in a managed
#      block, without codex mcp add. When bbj-docs is already named in config.toml in a form
#      this script does not edit (single-quoted key, spaced or indented header, dotted key,
#      sub-table), or its tools are (a [mcp_servers.bbj-docs.tools] table, a quoted tool
#      header, a dotted tools key, an approval_mode written as anything but a bare key),
#      config.toml is left alone, the tables are printed and the exit code is 3.
#   1b. with --with-local (and on every later run once the block is there), registers the local
#      check server bbj-local, the bbj-ls of a running BBjServices 26.03 or later, in one managed
#      block of config.toml between the markers "# >>> bbj-agent-plugins bbj-local (managed) >>>"
#      and "# <<< bbj-agent-plugins bbj-local (managed) <<<": [mcp_servers.bbj-local] with
#      url = "http://127.0.0.1:5009/mcp" and one tool table with approval_mode = "approve" for
#      each of bbj_check_syntax, bbj_format and bbj_denum (plan 01-04, LOCAL-02). These tools run
#      on this machine and are approved by name only at that fixed url (D-12, D-17: the url does
#      not follow BBJ_LOCAL_MCP_URL, which moves only the hook and the probe); never through
#      "codex mcp add" (it cannot set approval_mode), never with default_tools_approval_mode,
#      required, enabled or startup_timeout_sec. It goes through the same pass as bbj-docs, so
#      the rules of step 1 apply: a rerun is byte-identical, missing tool tables and approval
#      keys are added inside the markers and nothing is removed. A run without the flag keeps a
#      managed block and refreshes it the same way (D-09); there is no removal flag (D-10): after
#      "codex mcp remove bbj-local" the lone end marker stays in config.toml as a comment, is
#      tolerated and, with the flag, a fresh block follows it. A plain [mcp_servers.bbj-local]
#      table whose url is exactly the fixed url gains the three approvals; any other form of
#      bbj-local (another url, single-quoted key, dotted key, a sub-table without the table) is
#      left alone, the tables are printed and the exit code is 3 (D-12).
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
# --codex-home DIR (default $CODEX_HOME or ~/.codex), --with-local (register bbj-local, step 1b),
# --force, --help.
# Exit codes: 0 done, 2 usage error or refusal, 3 finished with something left to merge or
# decide by hand: bbj-docs or its tools named in config.toml in a form this script does not
# edit, bbj-local named in a form it does not edit or with another url than the fixed one, a
# default_tools_approval_mode that approves every tool, an existing hooks.json, a skill
# directory that differs.
#
# Exit 2 before the first write means nothing was changed: the options are validated and every
# destination (skills directory, <codex home>/bbj, config.toml) is created or checked up front.
# A failure after a step has run still exits 2 and names the steps that already ran.
#
# It never runs BBj and never calls a compiler; the hook it installs follows the same
# never-execute rule. POSIX sh plus awk, sed, grep, cp, mv, cmp, diff, mktemp.

DEFAULT_DOCS_URL=https://mcp.bbj-ai.com/mcp
MARK_BEGIN='# >>> bbj-agent-plugins (managed) >>>'
MARK_END='# <<< bbj-agent-plugins (managed) <<<'
# the five read-only docs tools of bbj-docs, approved by name; one list, also checked against
# the tool bullets of AGENTS-snippet.md by the test suite
DOCS_TOOLS='bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples'
# the local check server bbj-local (plan 01-04, LOCAL-02): the bbj-ls of a running BBjServices.
# Its three tools run on this machine and are approved by name only for this fixed loopback url
# (D-12); the registration never follows BBJ_LOCAL_MCP_URL (D-17)
LOCAL_URL=http://127.0.0.1:5009/mcp
LOCAL_MARK_BEGIN='# >>> bbj-agent-plugins bbj-local (managed) >>>'
LOCAL_MARK_END='# <<< bbj-agent-plugins bbj-local (managed) <<<'
LOCAL_TOOLS='bbj_check_syntax bbj_format bbj_denum'
# the tools/list probe of step 1b (plan 01-06, LOCAL-03, D-11): a static request that names no file,
# no code and no project; the _meta keys are the ones the hook's check sends
PROBE_BODY='{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
TOOL_KEY='approval_mode = "approve"'
# the server-wide line that versions up to 398aac5 of this script wrote; it is only ever
# recognised and removed, never written again
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
Usage: sh codex/install-codex.sh [--docs-url URL] [--skills-dir DIR] [--codex-home DIR] [--with-local] [--force]

  --docs-url URL     docs server URL (default $DEFAULT_DOCS_URL);
                     https anywhere, http only to 127.0.0.1, localhost or [::1]
  --skills-dir DIR   where the skills go (default \$HOME/.agents/skills)
  --codex-home DIR   Codex home (default \$CODEX_HOME, else \$HOME/.codex)
  --with-local       register bbj-local, the bbj-ls of a running BBjServices 26.03 or later at
                     http://127.0.0.1:5009/mcp, and approve its three tools by name
  --force            replace a skill directory that differs from the shipped one
  --help             this text

Exit: 0 done, 2 refused (nothing written unless the message names the steps that ran),
      3 done except something to merge or decide by hand: bbj-docs or its tools named in
        config.toml in a form this script does not edit, a default_tools_approval_mode that
        approves every tool, bbj-local named in a form this script does not edit or with
        another url than http://127.0.0.1:5009/mcp, an existing hooks.json, a skill directory
        that differs.
EOF
}

say "$STATUS_LINE"

docs_url=$DEFAULT_DOCS_URL
skills_dir=
codex_home=
force=0
with_local=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --docs-url) [ "$#" -ge 2 ] || refuse "--docs-url needs a value"; docs_url=$2; shift 2 ;;
    --skills-dir) [ "$#" -ge 2 ] || refuse "--skills-dir needs a value"; skills_dir=$2; shift 2 ;;
    --codex-home) [ "$#" -ge 2 ] || refuse "--codex-home needs a value"; codex_home=$2; shift 2 ;;
    --with-local) with_local=1; shift ;;
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
# analyze: one pass over config.toml (or nothing when it does not exist) for the server the
# srv_* globals name (SRV below; it reaches awk only as an -v value); prints
#   main=1|0     the [mcp_servers.SRV] table is there (plain or quoted key, column 0)
#   mention=1|0  a line that is not a comment names SRV in a form this script does not edit
#                (single-quoted key, indented or spaced header, dotted key, inline table, another
#                sub-table); our own [mcp_servers.SRV.tools.NAME] headers do not count
#   tfor=1|0     SRV tools are named in a form this script does not edit: a [..SRV.tools]
#                table, a quoted or indented tool header, a dotted key, a tools key in the main
#                table, an approval_mode written other than as a bare key in a tool table,
#                or a tool table twice (only acted on when main=1)
#   dstate=      none | ours (exactly srv_old_key) | approve (default_tools_approval_mode set to
#                approve in another spelling) | other:VALUE, from the main table
#   managed=1|0  a line equals the begin marker srv_begin (a lone end marker is a comment: 0)
#   url=VALUE    the url key of the main table (last one), "" when there is none
#   anytool=N    how many [mcp_servers.SRV.tools.NAME] tables there are
#   tool.NAME=   missing | nokey | approve | other:VALUE, for each tool of srv_tools
analyze() {
  src=$config
  [ -f "$src" ] || src=/dev/null
  awk -v srv="$srv" -v tools="$srv_tools" -v sq="'" -v old_key="$srv_old_key" -v begin="$srv_begin" '
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
      dstate = "none"
      tools_re = "^[ \t]*[\"" sq "]?tools[\"" sq "]?[ \t]*[.=]"
      key = "(\"" srv "\"|" srv ")"
      main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
      tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
      tool_pre = "^\\[mcp_servers\\." key "\\.tools\\."
    }
    {
      line = $0
      sub(/\r$/, "", line)
      if (line == begin) managed = 1
      if (line ~ /^[ \t]*\[/) {
        sect = "other"
        name = ""
        if (line ~ main_re) {
          sect = "main"
          main = 1
        } else if (line ~ tool_re) {
          sect = "tool"
          name = line
          sub(tool_pre, "", name)
          sub(/\].*$/, "", name)
          anytool++
          if (name in st) {
            if (st[name] != "missing") tfor = 1
            st[name] = "nokey"
          }
        } else if (index(line, srv) > 0) {
          mention = 1
          if (line ~ /tools/) tfor = 1
        }
      } else if (line !~ /^[ \t]*#/) {
        if (index(line, srv) > 0) {
          mention = 1
          if (line ~ /tools/) tfor = 1
        }
        if (sect == "main") {
          if (line ~ /^[ \t]*default_tools_approval_mode[ \t]*=/) {
            v = val(line)
            if (old_key != "" && line == old_key) dstate = "ours"
            else dstate = (v == "approve") ? "approve" : "other:" v
          }
          if (line ~ tools_re) tfor = 1
          if (line ~ /^[ \t]*url[ \t]*=/) url = val(line)
        } else if (sect == "tool" && (name in st)) {
          if (line ~ /^[ \t]*approval_mode[ \t]*=/) {
            v = val(line)
            st[name] = (v == "approve") ? "approve" : "other:" v
          } else if (line ~ /approval_mode/) {
            tfor = 1
          }
        }
      }
    }
    END {
      print "main=" (main ? 1 : 0)
      print "mention=" (mention ? 1 : 0)
      print "managed=" (managed ? 1 : 0)
      print "url=" url
      print "tfor=" (tfor ? 1 : 0)
      print "dstate=" dstate
      print "anytool=" anytool + 0
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
# tools_in_state STATE: the srv_tools in that state, space separated
tools_in_state() {
  _out=
  for _t in $srv_tools; do
    [ "$(an "tool.$_t")" = "$1" ] && _out="$_out $_t"
  done
  printf '%s' "${_out# }"
}
# print_tools: the tool tables to put into config.toml by hand
print_tools() {
  for _t in $srv_tools; do
    printf '\n[mcp_servers.%s.tools.%s]\n%s\n' "$srv" "$_t" "$TOOL_KEY"
  done
}
# print_block URL: the whole server entry to put into config.toml by hand
print_block() {
  printf '%s\n' "[mcp_servers.$srv]" "url = \"$1\""
  print_tools
}

# state: the facts the decisions below rest on, recomputed after every change to config.toml
state() {
  foreign=0
  tools_foreign=0
  if [ "$(an main)" = 0 ]; then
    [ "$(an mention)" = 1 ] && foreign=1
  else
    [ "$(an tfor)" = 1 ] && tools_foreign=1
    # D-12: a server with a fixed url is edited only at exactly that url; its tools are never approved
    # on another one, so any other url is a form this script does not edit
    if [ "$srv_fixed_url" = 1 ] && [ "$(an url)" != "$srv_url" ]; then
      foreign=1
      tools_foreign=0
    fi
  fi
  miss=$(tools_in_state missing)
  nokey=$(tools_in_state nokey)
  dstate=$(an dstate)
}

# server parameters (POSIX sh has no local, so every server pass sets the same globals and
# sync_server reads only these): srv is the server name; srv_tools its tools to approve by name;
# srv_begin and srv_end the managed-block markers; srv_url the url it is registered with;
# srv_old_key a legacy server-wide line to drop ("" for none); srv_codex_add 1 when a fresh
# registration goes through "codex mcp add"; srv_label, srv_untouched and srv_approved_note the
# words of the messages (LOCAL-01); srv_fixed_url 1 when the url is part of the identity of the
# server and tools are approved only at exactly that url (bbj-local, D-12), 0 when the user's own
# url is kept (bbj-docs)
use_docs() {
  srv=bbj-docs
  srv_tools=$DOCS_TOOLS
  srv_begin=$MARK_BEGIN
  srv_end=$MARK_END
  srv_url=$docs_url
  srv_old_key=$OLD_KEY_LINE
  srv_codex_add=1
  srv_fixed_url=0
  srv_label='the five docs tools'
  srv_untouched='config.toml was not modified.'
  srv_approved_note='(the hosted check tools bbj_check_syntax, bbj_format and bbj_denum send your code to the server)'
}

# use_local: the same globals for bbj-local. The url is the fixed LOCAL_URL, never BBJ_LOCAL_MCP_URL (D-17);
# srv_old_key is empty, so no server-wide key is ever recognised, written or removed; srv_codex_add is 0
# because codex mcp add cannot set approval_mode
use_local() {
  srv=bbj-local
  srv_tools=$LOCAL_TOOLS
  srv_begin=$LOCAL_MARK_BEGIN
  srv_end=$LOCAL_MARK_END
  srv_url=$LOCAL_URL
  srv_old_key=
  srv_codex_add=0
  srv_fixed_url=1
  srv_label='the three bbj-ls tools'
  srv_untouched='the bbj-local entry was not modified.'
  srv_approved_note="(the three bbj-ls tools run on this machine, against this installation's own PREFIX, classpath and config; nothing leaves it)"
}

# sync_server: registration and per-tool approval of the server the srv_* globals describe
sync_server() {
  refresh
  state
  need_change=0
  if [ "$foreign" = 0 ] && [ "$tools_foreign" = 0 ]; then
    if [ "$(an main)" = 0 ] || [ "$dstate" = ours ] || [ -n "$miss" ] || [ -n "$nokey" ]; then need_change=1; fi
  fi
  if [ "$need_change" = 1 ] && [ -f "$config" ] && [ ! -f "$config.bbj-backup" ]; then
    cp "$config" "$config.bbj-backup" || refuse "cannot write $config.bbj-backup"
    wrote="$wrote config.toml(backup)"
    say "config.toml: backup written to $config.bbj-backup"
  fi

  if [ "$foreign" = 0 ] && [ "$(an main)" = 0 ]; then
    if [ "$(an anytool)" != 0 ]; then
      # Codex 0.156.1 cannot load tool tables without the server table, and its mcp add then fails
      say "$srv: $config holds tool tables of $srv but no $srv table, which Codex cannot load; adding the table in a managed block"
    elif [ "$srv_codex_add" = 1 ] && command -v codex > /dev/null 2>&1; then
      if CODEX_HOME=$codex_home codex mcp add "$srv" --url "$srv_url" > /dev/null 2>&1; then
        say "$srv: registered with codex mcp add $srv --url $srv_url"
      else
        say "$srv: codex mcp add did not succeed; writing the block to config.toml instead"
      fi
    fi
  fi
  # re-check: a registration by codex in a form this script does not know must not get a second table
  refresh
  state
  if [ "$foreign" = 1 ]; then
    say "$srv: $config already names $srv in a form this script does not edit; $srv_untouched"
    if [ "$srv_fixed_url" = 1 ] && [ "$(an main)" = 1 ] && [ "$(an url)" != "$srv_url" ]; then
      say "$srv: its url is \"$(an url)\", not $srv_url; its tools are approved by name only at $srv_url"
    fi
    say "Check that it holds these tables (url and per-tool approval), or add them by hand:"
    print_block "$srv_url"
    pending=1
  elif [ "$tools_foreign" = 1 ]; then
    say "$srv: $config names tools of $srv in a form this script does not edit; $srv_untouched"
    if [ "$srv_fixed_url" = 1 ]; then
      say "Check that it approves the three bbj-ls tools by name, or add the tables by hand:"
    else
      say "Check that it approves these five tools by name, or add the tables by hand:"
    fi
    print_tools
    [ "$dstate" != ours ] || say "Also remove the line $srv_old_key from the $srv table by hand: an earlier version of this script wrote it and it approves every tool of $srv, including bbj_check_syntax, bbj_format and bbj_denum."
    pending=1
  elif [ "$(an main)" = 0 ]; then
    # shellcheck disable=SC2094  # the group reads $config (its last byte) before the append writes it
    {
      if [ -s "$config" ]; then
        [ -z "$(tail -c 1 "$config")" ] || printf '\n'
        printf '\n'
      fi
      printf '%s\n' "$srv_begin" "[mcp_servers.$srv]" "url = \"$srv_url\"" "$srv_end"
    } >> "$config" || refuse "cannot write $config"
    wrote="$wrote config.toml"
    say "$srv: appended a managed block to $config (url $srv_url)"
    refresh
    state
  elif [ "$need_change" = 0 ]; then
    say "$srv: already registered in $config with $srv_label approved; nothing changed"
  fi

  # what the user chose stays; say so
  if [ "$foreign" = 0 ] && [ "$(an main)" = 1 ]; then
    if [ -z "$srv_old_key" ]; then
      # a server without a legacy server-wide line (bbj-local): report any value, never act on it
      case "$dstate" in
        approve|other:*) say "$srv: $config sets default_tools_approval_mode to ${dstate#other:}; left as is" ;;
      esac
    else
      case "$dstate" in
        approve)
          say "$srv: $config sets default_tools_approval_mode to approve in a form this script did not write; left as is. It approves every tool of $srv, including bbj_check_syntax, bbj_format and bbj_denum, which send your code to the server; remove the line by hand to keep Codex's prompt for them."
          pending=1
          ;;
        other:*) say "$srv: $config sets default_tools_approval_mode to ${dstate#other:}; left as is" ;;
      esac
    fi
    for _t in $srv_tools; do
      case "$(an "tool.$_t")" in
        other:*) say "$srv: tool $_t has approval_mode $(an "tool.$_t" | sed 's/^other://') (yours); left as is" ;;
      esac
    done
  fi

  if [ "$foreign" = 0 ] && [ "$tools_foreign" = 0 ] && [ "$(an main)" = 1 ] \
    && { [ "$dstate" = ours ] || [ -n "$miss" ] || [ -n "$nokey" ]; }; then
    drop=0
    [ "$dstate" = ours ] && drop=1
    tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
    # shellcheck disable=SC2094  # awk reads $config and writes $tmp; the copy back happens after awk ends
    if awk -v srv="$srv" -v miss="$miss" -v nokey="$nokey" -v drop="$drop" -v old_key="$srv_old_key" -v tool_key="$TOOL_KEY" -v mark_end="$srv_end" '
        # the missing tool tables go at the end of the server table body, before the blank
        # lines and comments that lead into the next table (or the end marker)
        function flush_main(atheader,   i, n, names) {
          if (!inmain) return
          inmain = 0
          n = split(miss, names, " ")
          for (i = 1; i <= n; i++) {
            print ""
            print "[mcp_servers." srv ".tools." names[i] "]"
            print tool_key
          }
          if (n > 0 && atheader && !hasblank) print ""
          for (i = 1; i <= nb; i++) print buf[i]
          nb = 0
          hasblank = 0
        }
        BEGIN {
          key = "(\"" srv "\"|" srv ")"
          main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
          tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
          tool_pre = "^\\[mcp_servers\\." key "\\.tools\\."
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
              if (drop && line == old_key) next
              for (i = 1; i <= nb; i++) print buf[i]
              nb = 0
              hasblank = 0
            }
          }
          print
          if (line ~ main_re) inmain = 1
          else if (line ~ tool_re) {
            name = line
            sub(tool_pre, "", name)
            sub(/\].*$/, "", name)
            if (index(" " nokey " ", " " name " ") > 0) print tool_key
          }
        }
        END { flush_main(0) }
      ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
      # written in place (not mv'd over it): a symlinked config.toml (dotfile managers) keeps
      # its link and every file keeps its mode (WR-01)
      rm -f "$tmp"
      wrote="$wrote config.toml"
      if [ "$drop" = 1 ]; then
        say "$srv: removed the line $srv_old_key from $config (an earlier version of this script wrote it; it approved every tool of $srv, including the hosted check tools)"
      fi
      approved="$miss $nokey"
      approved=$(printf '%s' "$approved" | sed -e 's/^ *//' -e 's/ *$//' -e 's/  */, /g')
      if [ -n "$approved" ]; then
        say "$srv: approved by name in $config: $approved; every other tool of $srv keeps Codex's prompt $srv_approved_note"
      fi
    else
      rm -f "$tmp"
      refuse "cannot update $config"
    fi
  fi
}

# probe_local: asks the bbj-ls of a running BBjServices for its tool list (plan 01-06, LOCAL-03, D-11).
# Sets probe (found: a reply names bbj_check_syntax | none: no answer, or another server | nocurl |
# refused: the url is not loopback http) and probe_url (BBJ_LOCAL_MCP_URL, else LOCAL_URL; the seam
# moves only the probe, never the registration, D-17). It never writes a file, never exits and always
# returns 0. Only a validated loopback url reaches curl, with no proxy, no .curlrc and no redirect; the
# verdict is the tool name in the reply, never curl's exit code.
probe_local() {
  probe=none
  probe_url=${BBJ_LOCAL_MCP_URL:-$LOCAL_URL}
  case "$probe_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) probe=refused; return 0 ;;
  esac
  _pok=$(printf '%s' "$probe_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_pok" = ok ] || { probe=refused; return 0; }
  command -v curl > /dev/null 2>&1 || { probe=nocurl; return 0; }
  _preply=$(curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 3 -X POST -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/list' --data "$PROBE_BODY" --url "$probe_url" 2> /dev/null)
  if printf '%s' "$_preply" | grep -Eq '"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"'; then
    probe=found
  fi
  return 0
}

use_docs
sync_server

# ---- 1b. the local check server: bbj-local (plan 01-04, LOCAL-02; D-09, D-12, D-17) ----
# Runs after the bbj-docs pass on purpose: that pass is complete before this one starts, so
# neither result depends on which block comes first in config.toml (LOCAL-01).
# With the flag, or when config.toml already holds a managed bbj-local block (the begin marker
# line, as analyze reports it), the pass runs: leaving the flag out never removes or freezes a
# block the user opted into (D-09), it refreshes it in place. A lone end marker (what codex mcp
# remove leaves behind, D-10) is a comment and counts as no block; it is never touched.
# Without the flag and with no bbj-local in config.toml at all (no table, no mention, no managed
# block) the probe of plan 01-06 asks a running bbj-ls on this machine for its tool list, once, and
# only suggests --with-local when it answers (LOCAL-03, D-11); it writes nothing and sets nothing.
# A bbj-local that is in config.toml (hand-registered or foreign) is never probed and never
# mentioned without the flag.
use_local
refresh
if [ "$with_local" = 1 ] || [ "$(an managed)" = 1 ]; then
  sync_server
elif [ "$(an main)" = 0 ] && [ "$(an mention)" = 0 ]; then
  probe_local
  # when the seam moved the probe, the none line also names the url the registration always uses (D-17)
  _seam=
  [ "$probe_url" = "$LOCAL_URL" ] || _seam=" The registration always uses $LOCAL_URL."
  case "$probe" in
    found) say "bbj-local: a bbj-ls answers at $probe_url; it is not registered with Codex. Rerun with --with-local to register it as bbj-local ($LOCAL_URL); nothing was written for it." ;;
    none) say "bbj-local: no bbj-ls answered at $probe_url; not registered (rerun with --with-local once BBjServices 26.03+ runs).$_seam" ;;
    nocurl) say "bbj-local: not probed: curl not found." ;;
    refused) say "bbj-local: not probed: $probe_url (BBJ_LOCAL_MCP_URL) is not a loopback http URL." ;;
  esac
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
