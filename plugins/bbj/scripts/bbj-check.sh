#!/bin/sh
# bbj-check.sh -- compile-only BBj check for the Claude Code PostToolUse hook
# (plan 19-01, PLUG-01; decisions D-11 and D-12 of phase 19).
#
# Reads the hook JSON on stdin. For a Write or Edit of a .bbj, .src or .bbx file it
# compiles the file with the BBj compiler (bbjcpl or bbjcplw, always with -N: a
# compile-only check) and hands the compiler's error lines back to the model:
#
#   exit 0, no output at all   clean file, any other file, missing file, no BBj found
#   exit 2, feedback on stderr the compiler reported errors (D-12 grammar):
#                                bbjcpl reported N error(s) in <file>:
#                                <compiler lines, verbatim, at most 40>
#                                (M more line(s) not shown)         only when N > 40
#                                bbj_lookup gives exact syntax for a named symbol.
#
# Tier 2 (plan 19-04, D-14): when no usable compiler exists, the script asks the running
# bbj-ls (bbj-local's bbj_check_syntax, one stateless tools/call, the headers and _meta
# keys CheckUpstream.java sends) over loopback, default http://127.0.0.1:5009/mcp, env
# BBJ_LOCAL_MCP_URL. Only a loopback URL over plain http is ever contacted (127.0.0.1,
# localhost, [::1]; no userinfo, query, fragment or whitespace), curl runs with --noproxy
# and --proto =http and no redirect flag, and the hosted check is never called. Tier 2
# parses only: it reports syntax errors, not type errors (the tiers disagree), so its
# header names the route:
#                                bbj-local reported N error(s) in <file>:
# With neither a compiler nor a reachable loopback server the hook exits 0, silently.
#
# stdout stays empty and the exit code is only ever 0 or 2. There is deliberately no
# "set -e": every failure path ends in an explicit "exit 0".
#
# This script never runs BBj and never evaluates, sources or interpolates file content
# into a command; the file name reaches the compiler as one quoted absolute argument.
# The compiler is called as
#     <real path> -t -N -X -P<dir list> <absolute file>   (stdin from /dev/null, stderr captured)
# because the compiler prints its errors on stderr and exits 0 on every outcome (clean,
# erroring and missing file alike); the verdict is read from the output, not the exit code.
# -W is not used (D-11).
#
# Environment, in the order BBj is looked for (PLUG-01): CLAUDE_PLUGIN_OPTION_BBJ_HOME (the
# plugin's bbj_home option), BBJ_HOME, BBJHOME, the compiler on PATH, then the default homes
# (/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx). CLAUDE_PROJECT_DIR (workspace root)
# is added to -P. BBJ_CHECK_DEFAULT_HOMES is a test seam: unset = the built-in default
# homes, set = a colon-separated replacement list, empty = none. With no usable compiler
# the script exits 0 silently. The launcher bbjcpl finds its BBj home from its own path, so
# a symlink to it breaks: symlinks are resolved and the real path is called.
# With Git for Windows (cygpath on PATH) paths are converted: the compiler and -P get
# Windows paths and the -P list is joined with ";".
# Portable by design: POSIX sh plus awk, sed, grep, head, cat, dirname.

# report ROUTE ERRS: writes the D-12 feedback for the error lines ERRS to stderr (header
# naming ROUTE, at most 40 lines, an overflow line, the bbj_lookup line) and exits 2.
report() {
  _n=$(printf '%s\n' "$2" | awk 'END { print NR }')
  {
    printf '%s reported %s error(s) in %s:\n' "$1" "$_n" "$file"
    printf '%s\n' "$2" | head -n 40
    if [ "$_n" -gt 40 ]; then printf '(%s more line(s) not shown)\n' "$((_n - 40))"; fi
    printf 'bbj_lookup gives exact syntax for a named symbol.\n'
  } >&2
  exit 2
}

# Where to go when no BBj compiler can be used for the file: tier 2, the loopback bbj-local
# check (D-14). Every failure path ends in "exit 0" (no route, no verdict).
no_tier1_route() {
  _url=${BBJ_LOCAL_MCP_URL:-http://127.0.0.1:5009/mcp}
  # loopback only: plain http to 127.0.0.1, localhost or [::1], an optional port and path;
  # no whitespace, backslash, userinfo (@), query (?) or fragment (#). A refused URL is
  # never handed to curl.
  case "$_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) exit 0 ;;
  esac
  _ok=$(printf '%s' "$_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_ok" = ok ] || exit 0
  command -v curl > /dev/null 2>&1 || exit 0

  # the file text as a JSON string: control characters other than tab, LF and CR dropped;
  # backslash, double quote, tab and CR escaped; every line followed by \n
  _tab=$(printf '\t')
  _cr=$(printf '\r')
  _code=$(LC_ALL=C tr -d '\000-\010\013\014\016-\037' < "$file" \
    | LC_ALL=C sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$_tab/\\\\t/g" -e "s/$_cr/\\\\r/g" \
    | LC_ALL=C awk '{ printf "%s%s", $0, "\\n" }')
  _body='{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"bbj_check_syntax","arguments":{"code":"'"$_code"'"},"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'

  _reply=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 1 -m 12 -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' --data-binary @- --url "$_url" 2> /dev/null)
  [ "$?" = 0 ] && [ -n "$_reply" ] || exit 0

  # a text/event-stream reply: the payload of the last data: line
  if printf '%s\n' "$_reply" | grep '^data:' > /dev/null; then
    _reply=$(printf '%s\n' "$_reply" | tr -d '\r' | sed -n 's/^data:[[:space:]]*//p' | tail -n 1)
  fi
  # a JSON-RPC error or an isError result is no verdict
  if printf '%s' "$_reply" | grep -E '"error"[[:space:]]*:|"isError"[[:space:]]*:[[:space:]]*true' > /dev/null; then exit 0; fi
  _text=$(printf '%s' "$_reply" | LC_ALL=C awk -v region=all -v key=text -v uni=1 "$JGET_AWK")
  case "$_text" in
    "No errors found."*) exit 0 ;;
  esac
  _errs=$(printf '%s\n' "$_text" | grep -E '^line [0-9]+, column [0-9]+:')
  [ -n "$_errs" ] || exit 0
  report bbj-local "$_errs"
}

# jget REGION KEY: reads JSON text on stdin and prints the unescaped value of the first
# string field named KEY. REGION pre = the text before the first "tool_input", post = the
# text after it, all = the whole input. Prints nothing when the key is absent, the string
# is not terminated, or the value holds a \u escape and uni is not set (the caller skips the
# file); with -v uni=1 (tier 2, run under LC_ALL=C) \uXXXX is decoded to UTF-8 bytes.
JGET_AWK='
{ s = s $0 "\n" }
END {
  p = index(s, "\"tool_input\"")
  if (region == "pre") { if (p > 0) s = substr(s, 1, p - 1) }
  else if (region == "all") { }
  else { if (p == 0) exit; s = substr(s, p + 12) }
  tag = "\"" key "\""
  while ((p = index(s, tag)) > 0) {
    s = substr(s, p + length(tag))
    if (match(s, /^[ \t\r\n]*:[ \t\r\n]*"/)) {
      body = substr(s, RLENGTH + 1)
      n = length(body); out = ""; i = 1; closed = 0
      while (i <= n) {
        c = substr(body, i, 1)
        if (c == "\"") { closed = 1; break }
        if (c != "\\") { out = out c; i++; continue }
        i++
        d = substr(body, i, 1)
        if (d == "n") out = out "\n"
        else if (d == "t") out = out "\t"
        else if (d == "r") out = out "\r"
        else if (d == "b") out = out "\b"
        else if (d == "f") out = out "\f"
        else if (d == "u") {
          if (!uni) exit
          hex = substr(body, i + 1, 4)
          if (hex !~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) exit
          cp = 0
          for (k = 1; k <= 4; k++) cp = cp * 16 + index("0123456789abcdef", tolower(substr(hex, k, 1))) - 1
          i += 4
          if (cp < 32) out = out " "
          else if (cp < 128) out = out sprintf("%c", cp)
          else if (cp < 2048) out = out sprintf("%c%c", 192 + int(cp / 64), 128 + cp % 64)
          else if (cp >= 55296 && cp < 57344) out = out "?"
          else out = out sprintf("%c%c%c", 224 + int(cp / 4096), 128 + int(cp / 64) % 64, 128 + cp % 64)
        }
        else out = out d
        i++
      }
      if (closed) printf "%s", out
      exit
    }
  }
}'

jget() {
  awk -v region="$1" -v key="$2" "$JGET_AWK"
}

# to_unix PATH: with cygpath, the Unix form of PATH; otherwise PATH unchanged.
to_unix() {
  if [ "$WIN" = 1 ]; then cygpath -u "$1"; else printf '%s' "$1"; fi
}

# resolve_link PATH: sets CPL to the real path behind PATH (at most 16 symlink hops; no
# readlink -f, which older macOS lacks). A relative link target is taken relative to the
# link's directory. Without a symlink, PATH is kept as given.
resolve_link() {
  _p=$1
  _i=0
  while [ -L "$_p" ] && [ "$_i" -lt 16 ]; do
    if command -v readlink > /dev/null 2>&1; then
      _t=$(readlink "$_p")
    else
      _t=$(ls -ld "$_p" | sed -E 's/.* -> //')
    fi
    [ -n "$_t" ] || break
    case "$_t" in
      /*) _p=$_t ;;
      *) _p=$(dirname "$_p")/$_t ;;
    esac
    _i=$((_i + 1))
  done
  if [ "$_i" -gt 0 ]; then
    _dir=$(cd "$(dirname "$_p")" 2> /dev/null && pwd -P)
    [ -n "$_dir" ] && _p=$_dir/$(basename "$_p")
  fi
  CPL=$_p
}

# find_cpl_in_home DIR: sets CPL to the first executable compiler inside DIR (or DIR
# itself when it is the bin directory). Names in order: bbjcpl, bbjcpl.exe, bbjcplw.exe, bbjcplw.
find_cpl_in_home() {
  _hd=$(to_unix "$1")
  [ -n "$_hd" ] || return 1
  for _d in "$_hd/bin" "$_hd"; do
    for _n in bbjcpl bbjcpl.exe bbjcplw.exe bbjcplw; do
      if [ -f "$_d/$_n" ] && [ -x "$_d/$_n" ]; then
        resolve_link "$_d/$_n"
        return 0
      fi
    done
  done
  return 1
}

# find_cpl_on_path: the first bbjcpl, else bbjcplw, found on PATH.
find_cpl_on_path() {
  for _n in bbjcpl bbjcplw; do
    _c=$(command -v "$_n" 2> /dev/null)
    case "$_c" in
      /*)
        if [ -f "$_c" ] && [ -x "$_c" ]; then
          resolve_link "$_c"
          return 0
        fi
        ;;
    esac
  done
  return 1
}

# discover: sets CPL (empty when no compiler is found). Order: the plugin option, BBJ_HOME,
# BBJHOME, PATH, the default homes. A home without a compiler falls through to the next step.
discover() {
  CPL=
  for _h in "$CLAUDE_PLUGIN_OPTION_BBJ_HOME" "$BBJ_HOME" "$BBJHOME"; do
    if [ -n "$_h" ] && find_cpl_in_home "$_h"; then return 0; fi
  done
  if find_cpl_on_path; then return 0; fi
  if [ "${BBJ_CHECK_DEFAULT_HOMES+set}" = set ]; then
    _list=$BBJ_CHECK_DEFAULT_HOMES
    _sep=:
  else
    _list='/c/bbx /Applications/bbx /usr/local/bbx /opt/bbx'
    _sep=' '
  fi
  _oifs=$IFS
  IFS=$_sep
  set -f
  # shellcheck disable=SC2086
  set -- $_list
  set +f
  IFS=$_oifs
  for _h in "$@"; do
    [ -n "$_h" ] || continue
    if find_cpl_in_home "$_h"; then return 0; fi
  done
  return 1
}

main() {
  input=$(cat)
  hd=$(printf '%s' "$input" | head -c 8192)
  tool=$(printf '%s' "$hd" | jget pre tool_name)
  case "$tool" in
    Write|Edit) ;;
    *) exit 0 ;;
  esac
  file=$(printf '%s' "$hd" | jget post file_path)
  cwd=$(printf '%s' "$hd" | jget pre cwd)
  [ -n "$file" ] || exit 0

  case "$file" in
    *.[bB][bB][jJ]|*.[sS][rR][cC]|*.[bB][bB][xX]) ;;
    *) exit 0 ;;
  esac
  nl='
'
  case "$file" in
    *"$nl"*|*'*'*|*'?'*|*'['*) exit 0 ;;
  esac
  WIN=0
  if command -v cygpath > /dev/null 2>&1; then WIN=1; fi
  case "$file" in
    /*) ;;
    [A-Za-z]:*)
      # a drive-letter path is only meaningful under Git for Windows (cygpath)
      [ "$WIN" = 1 ] || exit 0
      file=$(cygpath -u "$file")
      ;;
    *) exit 0 ;;
  esac
  case "$file" in
    /*) ;;
    *) exit 0 ;;
  esac
  [ -f "$file" ] && [ -r "$file" ] || exit 0

  discover || no_tier1_route

  # -P list: the file's directory, the workspace root, the payload cwd; deduplicated,
  # absolute entries only, none containing the list separator. Under Git for Windows the
  # entries are converted with cygpath -w and joined with ";".
  plist=
  wlist=
  for _e in "$(dirname "$file")" "$CLAUDE_PROJECT_DIR" "$cwd"; do
    [ -n "$_e" ] || continue
    case "$_e" in
      [A-Za-z]:*) if [ "$WIN" = 1 ]; then _e=$(cygpath -u "$_e"); fi ;;
    esac
    case "$_e" in
      /*) ;;
      *) continue ;;
    esac
    case "$_e" in
      *:*|*';'*) continue ;;
    esac
    case ":$plist:" in
      *":$_e:"*) continue ;;
    esac
    if [ -z "$plist" ]; then plist=$_e; else plist=$plist:$_e; fi
    if [ "$WIN" = 1 ]; then
      _w=$(cygpath -w "$_e")
      [ -n "$_w" ] || continue
      if [ -z "$wlist" ]; then wlist=$_w; else wlist=$wlist';'$_w; fi
    fi
  done
  if [ "$WIN" = 1 ]; then plist=$wlist; fi
  cfile=$file
  if [ "$WIN" = 1 ]; then cfile=$(cygpath -w "$file"); fi

  out=$("$CPL" -t -N -X ${plist:+"-P$plist"} "$cfile" </dev/null 2>&1)
  rc=$?
  errs=$(printf '%s\n' "$out" | grep -E ': (type check )?error')
  if [ -z "$errs" ]; then
    # Output without a compiler-format line (a launcher or Java failure) or a crashed
    # compiler is no verdict, never "clean": same route as no compiler at all.
    if [ -n "$out" ] || [ "$rc" -ge 126 ]; then no_tier1_route; fi
    exit 0
  fi
  report bbjcpl "$errs"
}

main
exit 0
