#!/bin/sh
# tests/test_static_guards.sh -- plan 19-01 Task 2: static scan of the hook scripts.
# Scans plugins/bbj/scripts/*.sh (override: SCRIPTS_GLOB) with comment lines removed. The
# forbidden patterns live in this file only; the scripts' own comments are not scanned,
# so they may describe the rules in words. One gate per pattern and per file.
# Nothing here runs BBj.
. "$(dirname "$0")/lib.sh"

SCRIPTS_GLOB=${SCRIPTS_GLOB:-$REPO/plugins/bbj/scripts/*.sh}
mkwork

# scan NAME FILE BODY REGEX: FAIL with the first hit, else ok.
scan() {
  _hit=$(printf '%s\n' "$3" | grep -En -e "$4" | head -n 1)
  if [ -n "$_hit" ]; then
    gate "static_$1_$(basename "$2")" FAIL "$_hit"
  else
    gate "static_$1_$(basename "$2")" ok "no match"
  fi
}

# curl_gate FILE BODY: every curl call of BODY (comment lines already removed) carries --noproxy and
# --proto =http and follows no redirect (plan 19-01; applied to codex/*.sh by plan 01-06). A line that
# only tests for curl (command -v) or only prints a message (say "...") is not a call.
curl_gate() {
  _curls=$(printf '%s\n' "$2" | grep -E '(^|[;&|(`[:space:]])curl([[:space:]]|$)' | grep -v 'command -v' | grep -Ev '(^|[[:space:];)])say[[:space:]]+"')
  if [ -z "$_curls" ]; then
    gate "static_curl_call_$(basename "$1")" ok "no curl call in this file"
  else
    _nosafe=$(printf '%s\n' "$_curls" | grep -v -e '--noproxy' | head -n 1)
    _noproto=$(printf '%s\n' "$_curls" | grep -v -e '--proto =http' | head -n 1)
    _redirect=$(printf '%s\n' "$_curls" | grep -E -e '[[:space:]](-L|--location[a-z-]*|-[A-Za-z]*L[A-Za-z]*)([[:space:]]|$)' | head -n 1)
    if [ -n "$_nosafe" ]; then gate "static_curl_call_$(basename "$1")" FAIL "curl call without --noproxy: $_nosafe"
    elif [ -n "$_noproto" ]; then gate "static_curl_call_$(basename "$1")" FAIL "curl call without --proto =http: $_noproto"
    elif [ -n "$_redirect" ]; then gate "static_curl_call_$(basename "$1")" FAIL "curl call follows redirects: $_redirect"
    else gate "static_curl_call_$(basename "$1")" ok "every curl call has --noproxy and --proto =http, no -L"
    fi
  fi
}

found=0
for f in $SCRIPTS_GLOB; do
  [ -f "$f" ] || continue
  found=1
  body=$(grep -Ev '^[[:space:]]*#' "$f")

  # an interpreter call: a bbj command word, /bbj followed by a quote or space, bin/bbj not followed by cpl
  scan interpreter_word "$f" "$body" '(^|[;&|(`[:space:]])bbj([[:space:]]|$)'
  scan interpreter_path "$f" "$body" '/bbj([[:space:]"'"'"']|$)'
  scan interpreter_bin "$f" "$body" 'bin/bbj([^c]|$)'
  scan terminal_io_flag "$f" "$body" '-tIO'
  scan eval "$f" "$body" '(^|[^A-Za-z_])eval([^A-Za-z_]|$)'
  scan json_cli "$f" "$body" '(^|[^A-Za-z_])jq([^A-Za-z_]|$)'
  scan python_node "$f" "$body" '(^|[^A-Za-z_])(python[0-9.]*|node|nodejs)([^A-Za-z_]|$)'
  scan readlink_f "$f" "$body" 'readlink[[:space:]]+-[A-Za-z]*f'
  scan grep_perl "$f" "$body" 'grep[[:space:]]+(-[A-Za-z]*P|--perl)'
  scan sed_in_place "$f" "$body" 'sed[[:space:]]+(-[A-Za-z]*i|--in-place)'
  scan bash_test "$f" "$body" '(^|[[:space:];&|(])\[\[ '
  scan timeout_command "$f" "$body" '(^|[^A-Za-z_-])g?timeout([^A-Za-z_]|$)'

  # every line that calls the compiler variable carries -N
  calls=$(printf '%s\n' "$body" | grep -E '(^|[;&|(`]|\$\()[[:space:]]*"?\$\{?CPL\}?"?([[:space:]]|$)')
  if [ -z "$calls" ]; then
    gate "static_compiler_call_$(basename "$f")" ok "no compiler call in this file"
  else
    nodash=$(printf '%s\n' "$calls" | grep -v -e ' -N ' | head -n 1)
    if [ -n "$nodash" ]; then
      gate "static_compiler_call_$(basename "$f")" FAIL "compiler call without -N: $nodash"
    else
      gate "static_compiler_call_$(basename "$f")" ok "every compiler call carries -N"
    fi
  fi

  # plan 19-04: every URL literal has a loopback host; the curl call carries --noproxy and
  # --proto and no redirect flag (URLs preceded by ^ are the sed pattern that validates them)
  urls=$(printf '%s\n' "$body" | grep -oE '(^|[^^])https?://[^/"'"'"'[:space:]]*' | sed -E 's#^[^h]##')
  badurl=
  OLDIFS=$IFS
  IFS='
'
  for u in $urls; do
    printf '%s\n' "$u" | grep -E '^http://(127\.0\.0\.1|localhost|\[::1\])(:[0-9]+)?$' > /dev/null || badurl="$badurl $u"
  done
  IFS=$OLDIFS
  if [ -n "$badurl" ]; then
    gate "static_url_hosts_$(basename "$f")" FAIL "non-loopback URL literal:$badurl"
  else
    gate "static_url_hosts_$(basename "$f")" ok "every URL literal is loopback http"
  fi
  curl_gate "$f" "$body"

  if sh -n "$f" 2> "$WORK/syntax"; then
    gate "static_syntax_$(basename "$f")" ok "sh -n passes"
  else
    gate "static_syntax_$(basename "$f")" FAIL "$(head -n 1 "$WORK/syntax")"
  fi
  if command -v shellcheck > /dev/null 2>&1; then
    if shellcheck -s sh "$f" > "$WORK/shellcheck" 2>&1; then
      gate "static_shellcheck_$(basename "$f")" ok "shellcheck -s sh passes"
    else
      gate "static_shellcheck_$(basename "$f")" FAIL "$(head -n 3 "$WORK/shellcheck" | tr '\n' ' ')"
    fi
  else
    gate shellcheck skip "not installed"
  fi
done
[ "$found" = 1 ] || gate static_files FAIL "no script matched $SCRIPTS_GLOB"

# ---- plan 19-05: the Codex installer (codex/*.sh) follows the same never-execute rules ----
# No interpreter call, no terminal-I/O flag, no eval, no JSON command-line processor, no
# python or node, and no compiler name at all (the installer installs; it never compiles).
# Its URL literals are not scanned: the default docs URL is the hosted https instance. Its one curl
# call (the tools/list probe of plan 01-06) follows the hook's curl rules, checked by curl_gate.
CODEX_GLOB=${CODEX_GLOB:-$REPO/codex/*.sh}
foundc=0
for f in $CODEX_GLOB; do
  [ -f "$f" ] || continue
  foundc=1
  body=$(grep -Ev '^[[:space:]]*#' "$f")
  scan interpreter_word "$f" "$body" '(^|[;&|(`[:space:]])bbj([[:space:]]|$)'
  scan interpreter_path "$f" "$body" '/bbj([[:space:]"'"'"']|$)'
  scan interpreter_bin "$f" "$body" 'bin/bbj([^c]|$)'
  scan terminal_io_flag "$f" "$body" '-tIO'
  scan eval "$f" "$body" '(^|[^A-Za-z_])eval([^A-Za-z_]|$)'
  scan json_cli "$f" "$body" '(^|[^A-Za-z_])jq([^A-Za-z_]|$)'
  scan python_node "$f" "$body" '(^|[^A-Za-z_])(python[0-9.]*|node|nodejs)([^A-Za-z_]|$)'
  scan compiler_name "$f" "$body" 'bbjcpl'
  scan sed_in_place "$f" "$body" 'sed[[:space:]]+(-[A-Za-z]*i|--in-place)'
  curl_gate "$f" "$body"
  if sh -n "$f" 2> "$WORK/syntax"; then
    gate "static_syntax_$(basename "$f")" ok "sh -n passes"
  else
    gate "static_syntax_$(basename "$f")" FAIL "$(head -n 1 "$WORK/syntax")"
  fi
  if command -v shellcheck > /dev/null 2>&1; then
    if shellcheck -s sh "$f" > "$WORK/shellcheck" 2>&1; then
      gate "static_shellcheck_$(basename "$f")" ok "shellcheck -s sh passes"
    else
      gate "static_shellcheck_$(basename "$f")" FAIL "$(head -n 3 "$WORK/shellcheck" | tr '\n' ' ')"
    fi
  fi
done
[ "$foundc" = 1 ] || gate static_codex_files FAIL "no installer matched $CODEX_GLOB"

finish
