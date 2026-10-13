#!/bin/sh
# bbj-check.sh -- compile-only BBj check for the Claude Code PostToolUse hook
# (plan 19-01, PLUG-01; decisions D-11 and D-12 of phase 19). Phase 2 (plans 02-01 and 02-02,
# HOOK-01 to HOOK-04; decisions D-01 to D-19 of phase 2) adds the no-route notice below.
#
# Reads the hook JSON on stdin. For a Write or Edit of a .bbj, .src or .bbx file it
# compiles the file with the BBj compiler (bbjcpl or bbjcplw, always with -N: a
# compile-only check) and hands the compiler's error lines back to the model:
#
#   exit 0, no output at all   clean file, any other file, missing file, a route that was
#                              reached but gave no verdict (route failed, D-03)
#   exit 0, one JSON object on stdout: no check route; the no-route notice, once per
#                              session (see below)
#   exit 2, feedback on stderr the compiler reported errors (D-12 grammar):
#                                bbjcpl reported N error(s) in <file>:
#                                <compiler lines, verbatim, at most 40>
#                                (M more line(s) not shown)         only when N > 40
#                                Not counted: K unresolved use target line(s) ("Cannot find
#                                program").                          only when K > 0 (D-11)
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
# The outcome of tier 2 is one of four (D-01, D-03):
#   curl exit 7 (connection refused)           no route: the notice
#   curl 0, "No errors found."                 clean, silent
#   curl 0, "line N, column M:" error lines    errors, exit 2 as above
#   curl 0 with an empty reply, a JSON-RPC error, an isError result, or text with neither
#   verdict; and every other curl exit (28 timeout, 52 empty reply, 56 reset, 18 short
#   body, 1 not HTTP, 6 unresolved host and the rest)
#                                              route failed, silent
# Only exit 7 is no route: a reachable but slow or broken bbj-ls must never be reported as
# absent. No curl on PATH and a URL the loopback check refuses are no route as well (D-01).
#
# The no-route notice (HOOK-02): when a BBj file of the call had no check route (no compiler
# found, and tier 2 is no route) and no file of the call had compiler errors (D-04), the script
# exits 0 and writes ONE line to stdout, the only stdout write of the script:
#     {"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"<text>"}}
# The text names the files that were written but not compile-checked, the reasons (D-09),
# that later BBj files of the session are not checked either, how to enable a check (three
# texts: by tool_name, D-06, and for apply_patch by whether CLAUDE_PLUGIN_ROOT is non-empty, the
# Codex plugin route or the install-codex.sh route: D-07, D-08 of phase 8), the hosted check as the agent's fallback with its disclosure
# (D-08: it sends the code to a server, so the user must be told; the hook itself never calls
# it and the text names no address), and asks the agent to tell the user (D-07). It is its own
# message class and never uses the error header above (D-12). File names are reduced to
# printable ASCII, escaped, cut to 200 bytes each, and at most 5 are named (D-10).
#
# A compiler that runs but gives no verdict (output without a compiler-format line, or no
# output and exit status 126 or higher) is asked through tier 2 as well. With no tier-2 route
# either, the file is noted as unchecked and the notice reads "bbjcpl found but gave no result"
# instead of "no bbjcpl found" (D-02); with a tier-2 route that was reached without a verdict
# the file stays silent (D-03).
#
# The once-per-session marker (HOOK-02, D-17, D-18). The notice is decided in main after every
# file of the call, so a call that exits 2 or has nothing to report never uses up the slot.
# Location: ${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}/bbj-check-noroute-<key>, the same on both
# hosts (the seam BBJ_CHECK_STATE_DIR is how the tests keep it hermetic). Key: session_id
# reduced to [A-Za-z0-9_-] and cut to 64 bytes, byte-wise under LC_ALL=C, so "/" and "." never
# reach the path and a UUID keeps its hyphens. The marker is a directory made with mkdir (the
# parents flag would always succeed and defeat it), but mkdir alone is not an atomic test-and-set
# on every coreutils: uutils 0.8.0 (the default mkdir on recent Ubuntu) lets several parallel
# calls on one path all exit 0, observed. So the winner is decided by an exclusive create of a
# claim file inside the marker, made by the shell itself in a subshell with set -C (the shell
# opens it with O_CREAT|O_EXCL, no external tool): the one call that creates <marker>/claim
# tells, a call that finds the claim already there is silent. A claim that is a symlink is never
# followed and never taken for "told". The script never creates the state directory and never
# writes into or through a marker that is not a real directory. Fail toward telling (D-17):
# mkdir succeeds, or fails with a real directory (not a symlink) at the name, and the claim is
# made = tell; the claim exists as a regular file = already told, silent; the claim fails for
# any other reason (or the name is a symlink or a file, or the state directory is missing or
# unwritable) = tell, on every call. D-11 wants the notice to say it is "not repeated"; this
# script prints that clause only when this call made the claim, so on D-17's tell-anyway
# failures, as on D-16, the clause is left out: the next call tells again and the clause would be false (D-17 does not say so;
# this is the reading of D-11 with D-17 that plan 02-01 applies). D-16: no session_id, or one
# that sanitises to nothing, tells on every no-route call, with no shared key (it would
# outlive the session). D-19: one notice per session id, so subagents, which carry the
# parent's id, and resumed sessions are not told again; /compact may drop the notice from the
# context, which is accepted. Markers are directories holding one empty claim file, left for
# the OS to clean.
#
# N counts the compiler lines except unresolved uses without a path ("Cannot find program"),
# which are demoted to the trailing note and never cause exit 2 on their own (D-11). A file
# whose basename matches config*.bbx is configuration and is not checked (owner decision).
#
# Codex (plan 19-05, D-15, PLUG-04): a PostToolUse payload with tool_name apply_patch carries
# the patch text in tool_input.command. Every BBj file named by a line that starts exactly
# with "*** Add File: ", "*** Update File: " or "*** Move to: " is checked, resolved against
# the payload cwd (a "+"-prefixed content line never matches; Delete headers are ignored;
# a path with a ".." segment or an absolute path outside cwd is skipped silently; the same
# path is checked once). One block per failing file, one bbj_lookup line after the last
# block, exit 2. The whole payload is read, so headers past the first 8192 bytes count. The
# Codex payload was captured with Codex CLI codex-cli 0.162.1 (plan 02-05); top-level keys in
# that capture: session_id, turn_id, transcript_path, cwd, hook_event_name, model,
# permission_mode, tool_name, tool_input, tool_response, tool_use_id (transcript_path null,
# tool_response a plain string, the "*** Add File: " path absolute); session_id before
# tool_input, read with jget pre and, failing that, jget all.
#
# A path that is itself a symlink is skipped silently (a link to another file must not make
# the hook read or send that file); the same applies to every path a patch names.
#
# stdout is written in exactly one case, the no-route notice, and the exit code is only ever
# 0 or 2. There is deliberately no "set -e": every failure path ends in an explicit "exit 0".
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
# the script asks tier 2, and without a tier-2 route it writes the no-route notice. The
# launcher bbjcpl finds its BBj home from its own path, so a symlink to it breaks: symlinks
# are resolved and the real path is called. BBJ_CHECK_STATE_DIR (default ${TMPDIR:-/tmp}) is
# the directory of the notice's once-per-session marker, a test seam (D-18).
# CLAUDE_PLUGIN_ROOT (set by Claude Code and by the Codex plugin route, absent on the install-codex.sh
# route) is read only to choose the notice's enable step; it is never printed.
# With Git for Windows (cygpath on PATH) paths are converted: the compiler and -P get
# Windows paths and the -P list is joined with ";".
# Portable by design: POSIX sh plus awk, sed, grep, head, cat, dirname, tr, mkdir.

# report ROUTE ERRS [K]: writes the D-12 feedback block for the error lines ERRS to stderr
# (header naming ROUTE, at most 40 lines, an overflow line, a "Not counted" line when K > 0
# unresolved use lines were demoted) and sets FAILED=1. main prints the single bbj_lookup
# line after the last block and exits 2.
report() {
  _n=$(printf '%s\n' "$2" | awk 'END { print NR }')
  {
    printf '%s reported %s error(s) in %s:\n' "$1" "$_n" "$file"
    printf '%s\n' "$2" | head -n 40
    if [ "$_n" -gt 40 ]; then printf '(%s more line(s) not shown)\n' "$((_n - 40))"; fi
    if [ "${3:-0}" -gt 0 ]; then printf 'Not counted: %s unresolved use target line(s) ("Cannot find program").\n' "$3"; fi
  } >&2
  FAILED=1
}

# note_noroute KIND: records that the current file had no check route (KIND none = no compiler
# was found; KIND noresult = a compiler gave no verdict, plan 02-02). Uses the globals file, nl.
# NR_COMPILER keeps the first KIND of the call. main decides about the notice after all files.
note_noroute() {
  NR_N=$((NR_N + 1))
  NR_LIST=$NR_LIST$file$nl
  [ -n "$NR_COMPILER" ] || NR_COMPILER=$1
}

# json_body: stdin (one line) to the inside of a JSON string. Every byte outside printable
# ASCII becomes one "?" (a Latin-1 or control byte would make the object invalid UTF-8 or
# invalid JSON and the host would drop the whole notice), then backslash and double quote are
# escaped, in that order.
json_body() {
  LC_ALL=C sed -e 's/[^ -~]/?/g' -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# notice TOOL SID: the no-route notice (HOOK-02). Writes ONE JSON object to stdout, the only
# stdout write of this script, and returns 0. The once-per-session marker is the directory
#     ${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}/bbj-check-noroute-<key>
# (key is SID reduced to [A-Za-z0-9_-] and cut to 64 bytes) and the test-and-set is the
# exclusive creation of <marker>/claim: mkdir alone is not atomic on every coreutils (uutils
# 0.8.0 observed), the shell's own O_EXCL create (set -C, then a redirection) is. The marker
# is made only when a notice is about to print (D-17, D-18). Uses NR_N, NR_LIST, NR_COMPILER,
# NR_T2, NR_HOSTPORT.
notice() {
  _key=$(printf '%s' "$2" | LC_ALL=C tr -cd 'A-Za-z0-9_-' | head -c 64)
  _fresh=0
  if [ -n "$_key" ]; then
    _m=${BBJ_CHECK_STATE_DIR:-${TMPDIR:-/tmp}}/bbj-check-noroute-$_key
    # a real directory at the name, made now or earlier; a link or a file there is never used
    if mkdir "$_m" 2> /dev/null || { [ -d "$_m" ] && [ ! -L "$_m" ]; }; then
      if ( set -C; : > "$_m/claim" ) 2> /dev/null; then
        # a claim that is not a regular file of ours (a shell that follows a link to a device
        # accepts the create) is no claim: tell, without the "not repeated" clause
        if [ -f "$_m/claim" ] && [ ! -L "$_m/claim" ]; then _fresh=1; fi
      elif [ -f "$_m/claim" ] && [ ! -L "$_m/claim" ]; then
        # already told in this session
        return 0
      fi
    fi
  fi

  case "$NR_COMPILER" in
    noresult) _why1='bbjcpl found but gave no result' ;;
    none) _why1='no bbjcpl found' ;;
    *) _why1='no bbjcpl found' ;;
  esac
  case "$NR_T2" in
    refused) _why2="no bbj-ls answering on $NR_HOSTPORT" ;;
    nocurl) _why2='curl not found' ;;
    badurl) _why2='bbj-ls URL refused (not loopback)' ;;
    *) _why2='no bbj-ls answering' ;;
  esac
  # the paths: the first 5, each cut to its first 200 bytes (byte-wise under LC_ALL=C), joined
  # with ", "; any more are counted. NR_LIST holds one name per line (a name never holds a
  # newline), so the text handed to json_body is one line.
  _files=$(printf '%s' "$NR_LIST" | LC_ALL=C awk '
    length($0) { n++; if (n <= 5) { printf "%s%s", sep, substr($0, 1, 200); sep = ", " } }
    END { if (n > 5) printf " and %d more", n - 5 }')
  if [ "$NR_N" -gt 1 ]; then
    _were=were
    _these='these files were'
  else
    _were=was
    _these='this file was'
  fi
  _later='Later BBj files in this session are not checked either unless a check is enabled'
  if [ "$_fresh" = 1 ]; then _later="$_later, and this notice is not repeated"; fi
  # the enable steps differ by tool (D-06 of phase 2) and, for apply_patch, by route: Codex sets
  # CLAUDE_PLUGIN_ROOT for a plugin hook, the installer's hooks.json sets nothing (D-07, D-08 of
  # phase 8). The variable is only tested for non-empty, never printed or interpolated.
  case "$1" in
    apply_patch)
      if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
        _how='To enable a check, start BBjServices 26.03+ on this machine so that bbj-ls answers, or set BBJ_HOME to the BBj installation directory, or put bbjcpl on PATH. codex plugin add bbj-local@basis-bbj only gives the model the local bbj_check_syntax tool; the hook does not need it.'
      else
        _how='To enable a check, start BBjServices 26.03+ on this machine so that bbj-ls answers, or set BBJ_HOME to the BBj installation directory, or put bbjcpl on PATH. install-codex.sh --with-local only registers the local bbj_check_syntax tool for the model; the hook does not need it.'
      fi
      ;;
    *) _how='To enable a check, set the plugin option bbj_home to the BBj installation directory (for bbjcpl), or start BBjServices 26.03+ on this machine so that bbj-ls answers. The bbj-local@basis-bbj plugin only gives the model the local bbj_check_syntax tool; the hook does not need it.' ;;
  esac
  _txt="$_files $_were written but not compile-checked: $_why1; $_why2. $_later. $_how"
  _txt="$_txt Otherwise bbj_check_syntax of the hosted docs server bbj-docs can check the code; it sends the code to that server and checks it against a stock BBj, so the user must be told."
  _txt="$_txt Tell the user that $_these not compile-checked and how to enable a check."
  # user data (file names) only ever goes in the printf arguments, never in the format
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' \
    "$(printf '%s' "$_txt" | json_body)"
  return 0
}

# Where to go when no BBj compiler can be used for the file: tier 2, the loopback bbj-local
# check (D-14). Returns 0 when a verdict was reached (clean, or report ran), 1 when there is no
# route (NR_T2 says why: refused = nothing answers on the port, nocurl, badurl; NR_HOSTPORT holds
# the authority of the URL), 2 when a route was reached but gave no verdict. Every path ends in
# an explicit return.
no_tier1_route() {
  _url=${BBJ_LOCAL_MCP_URL:-http://127.0.0.1:5009/mcp}
  # loopback only: plain http to 127.0.0.1, localhost or [::1], an optional port and path;
  # no whitespace, backslash, userinfo (@), query (?) or fragment (#). A refused URL is
  # never handed to curl.
  case "$_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) NR_T2=badurl; return 1 ;;
  esac
  _ok=$(printf '%s' "$_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_ok" = ok ] || { NR_T2=badurl; return 1; }
  command -v curl > /dev/null 2>&1 || { NR_T2=nocurl; return 1; }
  # the authority of the validated URL, with ":80" when it names no port (a "[::1]" has colons
  # but no port)
  NR_HOSTPORT=$(printf '%s' "$_url" | sed -E 's#^http://([^/]*).*$#\1#')
  case "$NR_HOSTPORT" in
    *\]) NR_HOSTPORT=$NR_HOSTPORT:80 ;;
    *:[0-9]*) ;;
    *) NR_HOSTPORT=$NR_HOSTPORT:80 ;;
  esac

  # the file text as a JSON string: control characters other than tab, LF and CR dropped;
  # backslash, double quote, tab and CR escaped; every line followed by \n
  _tab=$(printf '\t')
  _cr=$(printf '\r')
  _code=$(LC_ALL=C tr -d '\000-\010\013\014\016-\037' < "$file" \
    | LC_ALL=C sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$_tab/\\\\t/g" -e "s/$_cr/\\\\r/g" \
    | LC_ALL=C awk '{ printf "%s%s", $0, "\\n" }')
  _body='{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"bbj_check_syntax","arguments":{"code":"'"$_code"'"},"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'

  # Windows (WIN=1, cygpath on PATH): a closed loopback port is reported only after about two
  # seconds there, so 1 s ends in curl exit 28 and the call would count as a route that gave no
  # verdict instead of no route (phase 9, W-2). 5 s still fits under -m 12 and the hook timeout.
  _ct=1
  if [ "$WIN" = 1 ]; then _ct=5; fi
  _reply=$(printf '%s' "$_body" | curl -q -sS -g --noproxy '*' --proto =http --connect-timeout "$_ct" -m 12 -X POST -H 'Content-Type: application/json' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/call' -H 'Mcp-Name: bbj_check_syntax' --data-binary @- --url "$_url" 2> /dev/null)
  _rc=$?
  # curl exit 7 (connection refused) is the only "nothing answers" outcome; every other failure
  # or an empty reply reached something and is a route that gave no verdict (see the header)
  if [ "$_rc" = 7 ]; then NR_T2=refused; return 1; fi
  { [ "$_rc" = 0 ] && [ -n "$_reply" ]; } || return 2

  # a text/event-stream reply: the payload of the last data: line
  if printf '%s\n' "$_reply" | grep '^data:' > /dev/null; then
    _reply=$(printf '%s\n' "$_reply" | tr -d '\r' | sed -n 's/^data:[[:space:]]*//p' | tail -n 1)
  fi
  # a JSON-RPC error or an isError result is no verdict
  if printf '%s' "$_reply" | grep -E '"error"[[:space:]]*:|"isError"[[:space:]]*:[[:space:]]*true' > /dev/null; then return 2; fi
  _text=$(printf '%s' "$_reply" | LC_ALL=C awk -v region=all -v key=text -v uni=1 "$JGET_AWK")
  case "$_text" in
    "No errors found."*) return 0 ;;
  esac
  _errs=$(printf '%s\n' "$_text" | grep -E '^line [0-9]+, column [0-9]+:')
  [ -n "$_errs" ] || return 2
  report bbj-local "$_errs"
  return 0
}

# jget REGION KEY: reads JSON text on stdin and prints the unescaped value of the first
# string field named KEY. REGION pre = the text before the first "tool_input", post = the
# text after it, all = the whole input. Prints nothing when the key is absent, the string
# is not terminated, or the value holds a \u escape and uni is not set (the caller skips the
# file); with -v uni=1 (tier 2, run under LC_ALL=C) \uXXXX is decoded to UTF-8 bytes.
UNESC_AWK='
function unesc(body,    n, out, i, c, d, hex, cp, k) {
  n = length(body); out = ""; i = 1; closed = 0; bad = 0
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
      if (!uni) { bad = 1; return "" }
      hex = substr(body, i + 1, 4)
      if (hex !~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) { bad = 1; return "" }
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
  return out
}'
JGET_AWK="$UNESC_AWK"'
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
      v = unesc(substr(s, RLENGTH + 1))
      if (closed && !bad) printf "%s", v
      exit
    }
  }
}'
# PATHS_AWK: each input line is the raw JSON text of one patch header path (it ends at the
# line end or at the closing quote of the string); prints the decoded paths, one per line.
# A line holding a \u escape that cannot be decoded is dropped.
PATHS_AWK="$UNESC_AWK"'
{ v = unesc($0); if (!bad) print v }'

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

# check_file FILE: the per-file check both tools share. FILE is the path as the tool named
# it (an absolute path; under Git for Windows a drive-letter path). Returns 0 in every case;
# a failing file leaves its feedback block on stderr and FAILED=1. Uses the globals WIN, cwd.
check_file() {
  file=$1
  case "$file" in
    *.[bB][bB][jJ]|*.[sS][rR][cC]|*.[bB][bB][xX]) ;;
    *) return 0 ;;
  esac
  nl='
'
  case "$file" in
    *"$nl"*|*'*'*|*'?'*|*'['*) return 0 ;;
  esac
  case "$file" in
    /*) ;;
    [A-Za-z]:*)
      # a drive-letter path is only meaningful under Git for Windows (cygpath)
      [ "$WIN" = 1 ] || return 0
      file=$(cygpath -u "$file")
      ;;
    *) return 0 ;;
  esac
  case "$file" in
    /*) ;;
    *) return 0 ;;
  esac
  [ -f "$file" ] && [ -r "$file" ] || return 0
  # a file that is itself a symlink is not checked: a *.bbj link to another file would hand
  # that file's lines back as compiler feedback (or post them to bbj-ls in tier 2)
  [ -L "$file" ] && return 0

  # Owner decision 2026-10-08 (plan 19-04 Task 2, auto-selected "skip-config"; one line to
  # reverse): a basename matching config*.bbx, any case, is BBj configuration, not a program;
  # the compiler reports an error on every line of it. Skipped before any route is tried.
  case "${file##*/}" in
    [cC][oO][nN][fF][iI][gG]*.[bB][bB][xX]) return 0 ;;
  esac

  if ! discover; then
    no_tier1_route
    _t2=$?
    if [ "$_t2" = 1 ]; then note_noroute none; fi
    return 0
  fi

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
    # compiler is no verdict, never "clean": same route as no compiler at all. When tier 2
    # has no route either (status 1) the file went unchecked, so it counts as no route and
    # is noted with KIND noresult (D-02); a tier-2 route that was reached without a verdict
    # (status 2) stays silent (D-03), and a tier-2 error reply was reported by the call.
    if [ -n "$out" ] || [ "$rc" -ge 126 ]; then
      no_tier1_route
      _t2=$?
      if [ "$_t2" = 1 ]; then note_noroute noresult; fi
    fi
    return 0
  fi
  # D-11: an unresolved use without a path ("Cannot find program") is demoted to a trailing
  # note and never causes exit 2 on its own; N counts only the other error lines.
  counted=$(printf '%s\n' "$errs" | grep -v -F 'Cannot find program')
  [ -n "$counted" ] || return 0
  demoted=$(printf '%s\n' "$errs" | grep -c -F 'Cannot find program')
  report bbjcpl "$counted" "$demoted"
  return 0
}

# codex_patch: the apply_patch branch (see the header). Reads the globals input, hd, WIN;
# sets cwd. Checks every BBj file the patch headers name, once each.
codex_patch() {
  cwd=$(printf '%s' "$hd" | jget pre cwd)
  [ -n "$cwd" ] || cwd=$(printf '%s' "$input" | jget all cwd)
  [ -n "$cwd" ] || exit 0
  case "$cwd" in
    [A-Za-z]:*) if [ "$WIN" = 1 ]; then cwd=$(cygpath -u "$cwd"); fi ;;
  esac
  case "$cwd" in
    /*) ;;
    *) exit 0 ;;
  esac
  base=${cwd%/}

  # the header paths of the patch, extracted in linear time (WR-05): the raw JSON is split at
  # its \n escapes with sed (an escaped backslash is protected first, so a "+" content line
  # that holds a backslash-n text never forges a header), only the "*** Add File: " style
  # lines are kept and only those few paths are unescaped; the patch text itself is never
  # decoded, so a patch of any size is read in one pass
  _ph=$(printf '\001')
  paths=$(printf '%s' "$input" | LC_ALL=C sed -e "s/\\\\\\\\/$_ph/g" \
      -e 's/"command"[[:space:]]*:[[:space:]]*"/&\
/' -e 's/\\n/\
/g' \
    | LC_ALL=C sed -n -e 's/^\*\*\* Add File: //p' -e 's/^\*\*\* Update File: //p' -e 's/^\*\*\* Move to: //p' \
    | LC_ALL=C sed -e "s/$_ph/\\\\\\\\/g" \
    | LC_ALL=C awk -v uni=1 "$PATHS_AWK" | LC_ALL=C tr -d '\r')
  [ -n "$paths" ] || exit 0

  nl='
'
  seen=$nl
  rest=$paths
  while [ -n "$rest" ]; do
    _p=${rest%%"$nl"*}
    case "$rest" in
      *"$nl"*) rest=${rest#*"$nl"} ;;
      *) rest= ;;
    esac
    [ -n "$_p" ] || continue
    case "$_p" in
      [A-Za-z]:*) if [ "$WIN" = 1 ]; then _p=$(cygpath -u "$_p"); fi ;;
    esac
    case "$_p" in
      /*)
        # absolute: only inside cwd
        case "$_p" in
          "$base"/*) ;;
          *) continue ;;
        esac
        ;;
      *) _p=$base/$_p ;;
    esac
    # "/./" segments collapse (so ./a and a count as one path); a ".." segment would leave
    # the workspace: skipped silently
    while :; do
      case "$_p" in
        *"/./"*) _p=${_p%%/./*}/${_p#*/./} ;;
        *) break ;;
      esac
    done
    case "$_p" in
      */..|*/../*) continue ;;
    esac
    case "$seen" in
      *"$nl$_p$nl"*) continue ;;
    esac
    seen=$seen$_p$nl
    check_file "$_p"
  done
}

main() {
  input=$(cat)
  hd=$(printf '%s' "$input" | head -c 8192)
  FAILED=0
  NR_N=0
  NR_LIST=
  NR_COMPILER=
  NR_T2=
  NR_HOSTPORT=
  WIN=0
  if command -v cygpath > /dev/null 2>&1; then WIN=1; fi
  tool=$(printf '%s' "$hd" | jget pre tool_name)
  if [ -z "$tool" ]; then
    # Codex: tool_name may come after a long tool_input; only apply_patch is taken from there
    tool=$(printf '%s' "$input" | jget all tool_name)
    [ "$tool" = apply_patch ] || tool=
  fi
  case "$tool" in
    Write|Edit)
      file=$(printf '%s' "$hd" | jget post file_path)
      cwd=$(printf '%s' "$hd" | jget pre cwd)
      [ -n "$file" ] || exit 0
      check_file "$file"
      ;;
    apply_patch) codex_patch ;;
    *) exit 0 ;;
  esac
  if [ "$FAILED" = 1 ]; then
    printf 'bbj_lookup gives exact syntax for a named symbol.\n' >&2
    exit 2
  fi
  # no check route for a file of this call (D-04: only when no file failed): the once-per-session
  # notice. The session id sits before tool_input on Claude Code and, in the plan 02-05 capture,
  # on Codex too; a search of the whole input stays as the fallback (as for tool_name above).
  if [ "$NR_N" -gt 0 ]; then
    sid=$(printf '%s' "$hd" | jget pre session_id)
    [ -n "$sid" ] || sid=$(printf '%s' "$input" | jget all session_id)
    notice "$tool" "$sid"
  fi
  exit 0
}

main
# shellcheck disable=SC2317  # main always exits; this line is the fail-safe if it ever returns
exit 0
