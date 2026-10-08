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
# Environment: BBJ_HOME (BBj install directory), CLAUDE_PROJECT_DIR (workspace root, added
# to -P), BBJ_CHECK_DEFAULT_HOMES (test seam: unset = the built-in default homes, set =
# a colon-separated replacement list, empty = none).
# Portable by design: POSIX sh plus awk, sed, grep, head, cat, dirname.

# Where to go when no BBj compiler can be used for the file. Plan 19-04 changes this one
# place (tier 2, the loopback bbj-local check); until then the hook does nothing.
no_tier1_route() {
  exit 0
}

# jget REGION KEY: reads JSON text on stdin and prints the unescaped value of the first
# string field named KEY. REGION pre = the text before the first "tool_input", post = the
# text after it. Prints nothing when the key is absent, the string is not terminated, or
# the value holds a \u escape (unsupported: the caller skips the file).
JGET_AWK='
{ s = s $0 "\n" }
END {
  p = index(s, "\"tool_input\"")
  if (region == "pre") { if (p > 0) s = substr(s, 1, p - 1) }
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
        else if (d == "u") { exit }
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

# find_cpl_in_home DIR: sets CPL to the first executable compiler inside DIR (or DIR
# itself when it is the bin directory). Names in order: bbjcpl, bbjcpl.exe, bbjcplw.exe, bbjcplw.
find_cpl_in_home() {
  for _d in "$1/bin" "$1"; do
    for _n in bbjcpl bbjcpl.exe bbjcplw.exe bbjcplw; do
      if [ -f "$_d/$_n" ] && [ -x "$_d/$_n" ]; then
        CPL=$_d/$_n
        return 0
      fi
    done
  done
  return 1
}

# discover: sets CPL (empty when no compiler is found). Order: BBJ_HOME, the default homes.
discover() {
  CPL=
  if [ -n "$BBJ_HOME" ] && find_cpl_in_home "$BBJ_HOME"; then return 0; fi
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
  case "$file" in
    /*) ;;
    *) exit 0 ;;
  esac
  [ -f "$file" ] && [ -r "$file" ] || exit 0

  discover || no_tier1_route

  # -P list: the file's directory, the workspace root, the payload cwd; deduplicated,
  # absolute entries only, none containing the list separator.
  plist=
  for _e in "$(dirname "$file")" "$CLAUDE_PROJECT_DIR" "$cwd"; do
    [ -n "$_e" ] || continue
    case "$_e" in
      /*) ;;
      *) continue ;;
    esac
    case "$_e" in
      *:*) continue ;;
    esac
    case ":$plist:" in
      *":$_e:"*) continue ;;
    esac
    if [ -z "$plist" ]; then plist=$_e; else plist=$plist:$_e; fi
  done

  out=$("$CPL" -t -N -X ${plist:+"-P$plist"} "$file" </dev/null 2>&1)
  errs=$(printf '%s\n' "$out" | grep -E ': (type check )?error')
  [ -n "$errs" ] || exit 0
  n=$(printf '%s\n' "$errs" | awk 'END { print NR }')
  {
    printf 'bbjcpl reported %s error(s) in %s:\n' "$n" "$file"
    printf '%s\n' "$errs" | head -n 40
    if [ "$n" -gt 40 ]; then printf '(%s more line(s) not shown)\n' "$((n - 40))"; fi
    printf 'bbj_lookup gives exact syntax for a named symbol.\n'
  } >&2
  exit 2
}

main
exit 0
