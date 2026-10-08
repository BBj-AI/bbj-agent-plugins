#!/bin/sh
# tests/test_tier2_fake.sh -- plan 19-04 Task 1: the tier-2 loopback fallback against a
# stdlib fake MCP server (tests/fake_mcp.py) and a fake curl. Covers the request shape that
# CheckUpstream.java sends (headers, _meta keys, the file text as arguments.code byte for
# byte after control characters are dropped), every fake-server mode, the rule that a
# working compiler means no request, and the loopback-only URL rule: refused URLs never reach
# curl, accepted ones carry --noproxy '*' and --proto =http and no redirect flag.
# Nothing here runs BBj; the "compiler" is the logging fake.
. "$(dirname "$0")/lib.sh"
mkwork

FAKE_PIDS=
cleanup() {
  for _p in $FAKE_PIDS; do kill "$_p" 2> /dev/null; done
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 1' INT TERM HUP

SYSPATH=/usr/bin:/bin
ORIGPATH=$PATH

# start_fake MODE: starts the fake server, sets FAKE_PID, LOGF and BBJ_LOCAL_MCP_URL.
start_fake() {
  PORTF=$WORK/port.$1
  LOGF=$WORK/req.$1.log
  : > "$LOGF"
  rm -f "$PORTF"
  python3 -I "$REPO/tests/fake_mcp.py" --port-file "$PORTF" --log "$LOGF" --mode "$1" &
  FAKE_PID=$!
  FAKE_PIDS="$FAKE_PIDS $FAKE_PID"
  _w=0
  while [ ! -s "$PORTF" ] && [ "$_w" -lt 100 ]; do sleep 0.1; _w=$((_w + 1)); done
  [ -s "$PORTF" ] || { gate "fake_start_$1" FAIL "the fake server wrote no port file"; finish; }
  BBJ_LOCAL_MCP_URL=http://127.0.0.1:$(cat "$PORTF")/mcp
  export BBJ_LOCAL_MCP_URL
}

stop_fake() {
  kill "$FAKE_PID" 2> /dev/null
  wait "$FAKE_PID" 2> /dev/null
}

# run_t2 PAYLOAD [PATH]: run_check with a restricted PATH, then restore PATH.
run_t2() {
  PATH=${2:-$SYSPATH}
  run_check "$1"
  PATH=$ORIGPATH
}

mkdir "$WORK/proj"
# the fixture: a backslash, a double quote, a tab, UTF-8 (cafe with an acute e) and a control
# character (0x01) that must be dropped before sending
printf 'a \\ b "q"\tcaf\303\251\001z\nprint "x"\n' > "$WORK/proj/t2.bbj"
FILE=$WORK/proj/t2.bbj
PAYLOAD=$(claude_payload Write "$FILE" "$WORK/proj")

silent() {
  # silent NAME: exit 0 with empty stdout and stderr
  if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate "$1" ok "exit 0, no output"
  else
    gate "$1" FAIL "exit $RC, output: $(head -c 200 "$WORK/stderr")"
  fi
}

# ---- request shape ----
start_fake clean
run_t2 "$PAYLOAD"
silent clean_reply_silent
cat > "$WORK/shape.py" << 'PYEOF'
import json, re, sys
log, fx = sys.argv[1], sys.argv[2]
entries = [json.loads(l) for l in open(log, encoding="utf-8") if l.strip()]
def out(name, ok, detail=""):
    print(name, "ok" if ok else "FAIL", detail or "-")
out("req_one_request", len(entries) == 1, "%d requests" % len(entries))
if len(entries) != 1:
    sys.exit(0)
r = entries[0]
h = r["headers"]
out("req_post_mcp", r["method"] == "POST" and r["path"] == "/mcp", "%s %s" % (r["method"], r["path"]))
out("req_header_content_type", h.get("content-type") == "application/json", str(h.get("content-type")))
out("req_header_protocol", h.get("mcp-protocol-version") == "2026-07-28", str(h.get("mcp-protocol-version")))
out("req_header_method", h.get("mcp-method") == "tools/call", str(h.get("mcp-method")))
out("req_header_name", h.get("mcp-name") == "bbj_check_syntax", str(h.get("mcp-name")))
b = json.loads(r["body"])
p = b.get("params", {})
out("req_envelope", b.get("jsonrpc") == "2.0" and b.get("id") == 1 and b.get("method") == "tools/call"
    and p.get("name") == "bbj_check_syntax" and list(p.get("arguments", {})) == ["code"],
    "envelope fields")
m = p.get("_meta", {})
out("req_meta_keys", m == {"io.modelcontextprotocol/protocolVersion": "2026-07-28",
                           "io.modelcontextprotocol/clientCapabilities": {}}, "_meta keys")
raw = open(fx, "rb").read()
raw = re.sub(rb"[\x00-\x08\x0b\x0c\x0e-\x1f]", b"", raw).decode("utf-8")
out("req_code_exact", p.get("arguments", {}).get("code") == raw, "arguments.code equals the file text minus control characters")
PYEOF
python3 -I "$WORK/shape.py" "$LOGF" "$FILE" > "$WORK/shape.out" 2>&1
while read -r _n _s _d; do gate "$_n" "$_s" "$_d"; done < "$WORK/shape.out"
stop_fake

# ---- modes ----
start_fake one-error
run_t2 "$PAYLOAD"
if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbj-local reported 1 error(s) in $FILE:" ] \
  && [ "$(sed -n 2p "$WORK/stderr")" = "$(printf "line 1, column 1: [SyntaxError] syntax error near '=' in caf\303\251")" ] \
  && [ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ] \
  && [ ! -s "$WORK/stdout" ]; then
  gate mode_one_error ok "exit 2, header, line (with decoded \\u0027 \\u003d and a UTF-8 e-acute), trailer"
else
  gate mode_one_error FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi
stop_fake

start_fake many
run_t2 "$PAYLOAD"
_lines=$(grep -c '^line [0-9]' "$WORK/stderr")
if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbj-local reported 60 error(s) in $FILE:" ] \
  && [ "$_lines" = 40 ] && grep -Fx '(20 more line(s) not shown)' "$WORK/stderr" > /dev/null \
  && [ "$(tail -n 1 "$WORK/stderr")" = "bbj_lookup gives exact syntax for a named symbol." ]; then
  gate mode_many_cap ok "N=60, 40 lines, overflow line"
else
  gate mode_many_cap FAIL "exit $RC, $_lines error lines: $(head -n 1 "$WORK/stderr")"
fi
stop_fake

start_fake rpc-error
run_t2 "$PAYLOAD"
silent mode_rpc_error_silent
stop_fake

start_fake garbage
run_t2 "$PAYLOAD"
silent mode_garbage_silent
stop_fake

start_fake sse
run_t2 "$PAYLOAD"
if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbj-local reported 1 error(s) in $FILE:" ]; then
  gate mode_sse ok "exit 2 from the data: line"
else
  gate mode_sse FAIL "exit $RC: $(head -c 300 "$WORK/stderr")"
fi
stop_fake

# ---- a skipped config*.bbx file never reaches the loopback either (plan 19-04 Task 2: skip-config) ----
start_fake one-error
printf 'ALIAS X0 SYSGUI\n' > "$WORK/proj/config.bbx"
run_t2 "$(claude_payload Write "$WORK/proj/config.bbx" "$WORK/proj")"
if [ "$RC" = 0 ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$LOGF" ]; then
  gate config_skipped_no_request ok "config.bbx sends nothing to the loopback"
else
  gate config_skipped_no_request FAIL "exit $RC, requests: $(awk 'END { print NR }' "$LOGF")"
fi
stop_fake

# ---- a working compiler wins: no request ----
mkdir -p "$WORK/home/bin"
cp "$REPO/tests/fake-bin/bbjcpl" "$WORK/home/bin/bbjcpl"
chmod 755 "$WORK/home/bin/bbjcpl"
start_fake one-error
BBJ_HOME=$WORK/home
FAKE_LOG=$WORK/calls.log
export BBJ_HOME FAKE_LOG
unset FAKE_OUT FAKE_STDOUT FAKE_EXIT
run_t2 "$PAYLOAD"
if [ "$RC" = 0 ] && [ ! -s "$LOGF" ] && [ -s "$FAKE_LOG" ]; then
  gate tier1_wins_no_request ok "compiler called, fake server saw nothing"
else
  gate tier1_wins_no_request FAIL "exit $RC, requests: $(awk 'END { print NR }' "$LOGF")"
fi

# an unusable compiler (output without a compiler line) falls through to tier 2
printf 'cannot open .envsetup\n' > "$WORK/unusable.txt"
FAKE_OUT=$WORK/unusable.txt
export FAKE_OUT
run_t2 "$PAYLOAD"
if [ "$RC" = 2 ] && [ "$(head -n 1 "$WORK/stderr")" = "bbj-local reported 1 error(s) in $FILE:" ] && [ -s "$LOGF" ]; then
  gate unusable_compiler_falls_to_tier2 ok "tier 2 answered"
else
  gate unusable_compiler_falls_to_tier2 FAIL "exit $RC"
fi
unset FAKE_OUT BBJ_HOME FAKE_LOG
stop_fake

# ---- loopback-only URL rule, with a fake curl ----
mkdir "$WORK/curlbin"
cp "$REPO/tests/fake-bin/curl" "$WORK/curlbin/curl"
chmod 755 "$WORK/curlbin/curl"
FAKE_CURL_LOG=$WORK/curl.log
export FAKE_CURL_LOG
CURLPATH=$WORK/curlbin:$SYSPATH

refused() {
  # refused URL: curl is never invoked, exit 0 silent
  : > "$FAKE_CURL_LOG"
  BBJ_LOCAL_MCP_URL=$1
  export BBJ_LOCAL_MCP_URL
  run_t2 "$PAYLOAD" "$CURLPATH"
  if [ "$RC" = 0 ] && [ ! -s "$FAKE_CURL_LOG" ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ]; then
    gate "url_refused_$2" ok "refused, curl not invoked"
  else
    gate "url_refused_$2" FAIL "reached curl or produced output (exit $RC)"
  fi
}
refused http://example.com/mcp remote_http
refused https://bbj-mcp.basis-europe.eu/mcp hosted_https
refused http://127.0.0.1.evil.example/mcp lookalike_host
refused http://user@127.0.0.1:5009/mcp userinfo
refused http://127.0.0.1:5009/mcp?x=1 query
refused 'http://127.0.0.1:5009/mcp#f' fragment
refused https://127.0.0.1:5009/mcp https_loopback
refused ftp://127.0.0.1/mcp ftp
refused http://localhost.evil.example/mcp lookalike_localhost
refused 'http://127.0.0.1:5009/m cp' whitespace
refused 'HTTP://127.0.0.1:5009/mcp' upper_scheme
refused 'http://127.0.0.1:5009/mcp
http://example.com/mcp' newline

accepted() {
  # accepted URL: curl is invoked once with the safety flags and no redirect flag
  : > "$FAKE_CURL_LOG"
  BBJ_LOCAL_MCP_URL=$1
  export BBJ_LOCAL_MCP_URL
  run_t2 "$PAYLOAD" "$CURLPATH"
  _calls=$(grep -cx CALL "$FAKE_CURL_LOG")
  if [ "$RC" = 0 ] && [ "$_calls" = 1 ] \
    && awk '/^--noproxy$/ { getline; if ($0 == "*") f = 1 } END { exit !f }' "$FAKE_CURL_LOG" \
    && awk '/^--proto$/ { getline; if ($0 == "=http") f = 1 } END { exit !f }' "$FAKE_CURL_LOG" \
    && ! grep -Ex -e '-L|--location|--location-trusted|-[A-Za-z]*L[A-Za-z]*' "$FAKE_CURL_LOG" > /dev/null \
    && grep -Fx "$1" "$FAKE_CURL_LOG" > /dev/null; then
    gate "url_accepted_$2" ok "$1 reached curl with --noproxy '*' --proto =http, no -L"
  else
    gate "url_accepted_$2" FAIL "$1: exit $RC, $_calls curl call(s): $(tr '\n' ' ' < "$FAKE_CURL_LOG" | head -c 300)"
  fi
}
accepted http://localhost:5009/mcp localhost
accepted http://[::1]:5009/mcp ipv6
accepted http://LOCALHOST:5009/mcp localhost_upper
accepted http://127.0.0.1:5009/mcp ipv4

# ---- no curl on PATH: exit 0 silent ----
mkdir "$WORK/nocurl"
for _t in "$SHELL_UNDER_TEST" cat head tail tr sed awk grep dirname basename ls readlink; do
  _c=$(PATH=$SYSPATH command -v "$_t")
  [ -n "$_c" ] && ln -s "$_c" "$WORK/nocurl/$_t"
done
start_fake one-error
run_t2 "$PAYLOAD" "$WORK/nocurl"
if [ "$RC" = 0 ] && [ ! -s "$WORK/stdout" ] && [ ! -s "$WORK/stderr" ] && [ ! -s "$LOGF" ]; then
  gate no_curl_silent ok "exit 0, no output, no request"
else
  gate no_curl_silent FAIL "exit $RC"
fi
stop_fake

finish
