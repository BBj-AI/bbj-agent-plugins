#!/bin/sh
# tests/test_static_guards.sh -- plan 19-01 Task 2: static scan of the hook scripts.
# Scans plugins/bbj/scripts/*.sh (override: SCRIPTS_GLOB) with comment lines removed. The
# forbidden patterns live in this file only; the scripts' own comments are not scanned,
# so they may describe the rules in words. One gate per pattern and per file.
# Gate names (D-13): every name starts with static_.
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

# curl_check BODY: sets CURL_STATUS (ok or FAIL) and CURL_DETAIL for every curl call of BODY (comment
# lines already removed): each carries --noproxy and --proto =http and follows no redirect (plan 19-01).
# A line that only tests for curl (command -v) is not a call.
curl_check() {
  _curls=$(printf '%s\n' "$1" | grep -E '(^|[;&|(`[:space:]])curl([[:space:]]|$)' | grep -v 'command -v')
  if [ -z "$_curls" ]; then
    CURL_STATUS=ok
    CURL_DETAIL="no curl call in this file"
  else
    _nosafe=$(printf '%s\n' "$_curls" | grep -v -e '--noproxy' | head -n 1)
    _noproto=$(printf '%s\n' "$_curls" | grep -v -e '--proto =http' | head -n 1)
    _redirect=$(printf '%s\n' "$_curls" | grep -E -e '[[:space:]](-L|--location[a-z-]*|-[A-Za-z]*L[A-Za-z]*)([[:space:]]|$)' | head -n 1)
    if [ -n "$_nosafe" ]; then CURL_STATUS=FAIL; CURL_DETAIL="curl call without --noproxy: $_nosafe"
    elif [ -n "$_noproto" ]; then CURL_STATUS=FAIL; CURL_DETAIL="curl call without --proto =http: $_noproto"
    elif [ -n "$_redirect" ]; then CURL_STATUS=FAIL; CURL_DETAIL="curl call follows redirects: $_redirect"
    else CURL_STATUS=ok; CURL_DETAIL="every curl call has --noproxy and --proto =http, no -L"
    fi
  fi
}

# curl_gate FILE BODY: the gate of one file
curl_gate() {
  curl_check "$2"
  gate "static_curl_call_$(basename "$1")" "$CURL_STATUS" "$CURL_DETAIL"
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

  # the hook writes stdout in exactly one place, the no-route notice (plan 02-02, HOOK-02 and
  # HOOK-03; D-12): in the comment-stripped script exactly one line holds hookSpecificOutput (the
  # one printf of the notice object), so a second stdout writer of the object fails the suite.
  # Any other shipped script must have none.
  _writers=$(printf '%s\n' "$body" | awk '/hookSpecificOutput/ { n++ } END { print n + 0 }')
  case "$(basename "$f")" in
    bbj-check.sh) _want=1 ;;
    *) _want=0 ;;
  esac
  if [ "$_writers" = "$_want" ]; then
    gate "static_notice_single_writer_$(basename "$f")" ok "$_writers line(s) hold hookSpecificOutput"
  else
    gate "static_notice_single_writer_$(basename "$f")" FAIL "$_writers line(s) hold hookSpecificOutput, want $_want"
  fi

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
    gate "static_shellcheck_$(basename "$f")" skip "not installed"
  fi
done
[ "$found" = 1 ] || gate static_files FAIL "no script matched $SCRIPTS_GLOB"

# ---- curl_check has teeth: unsafe calls FAIL, a safe call and a command -v test pass ----
# Each body below is a made-up script line; curl_check must FAIL every unsafe curl call and pass a
# command -v test and a safe call, so a broken curl_check cannot make the curl gate pass by accident.
_mut_n=0
_mut_bad=
for _m in \
  'r=$(curl -sL http://127.0.0.1:1/x)' \
  'curl -L --url "$u"' \
  'curl -s --url "$u"' \
  "curl --noproxy '*' --url \"\$u\"" \
  "curl --proto =http --url \"\$u\"" \
  "curl --noproxy '*' --proto =http -L --url \"\$u\""; do
  _mut_n=$((_mut_n + 1))
  curl_check "$_m"
  [ "$CURL_STATUS" = FAIL ] || _mut_bad="$_mut_bad [$_m]"
done
if [ -n "$_mut_bad" ]; then
  gate static_curl_unsafe_caught FAIL "the guard passed:$_mut_bad"
else
  gate static_curl_unsafe_caught ok "$_mut_n unsafe curl calls are all caught"
fi
_mut_bad=
for _m in \
  '  command -v curl > /dev/null 2>&1 || { probe=nocurl; return 0; }' \
  "_r=\$(curl -q -sS -g --noproxy '*' --proto =http --url \"\$u\" 2> /dev/null)"; do
  curl_check "$_m"
  [ "$CURL_STATUS" = ok ] || _mut_bad="$_mut_bad [$_m]"
done
if [ -n "$_mut_bad" ]; then
  gate static_curl_safe_passes FAIL "the guard flagged:$_mut_bad"
else
  gate static_curl_safe_passes ok "a command -v test and a safe call pass"
fi

finish
