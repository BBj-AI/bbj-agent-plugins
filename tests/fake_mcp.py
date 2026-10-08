"""A stdlib fake of the bbj-ls MCP endpoint, for tests/test_tier2_fake.sh (plan 19-04).

Binds 127.0.0.1 on a free port, writes the port number to --port-file and logs one JSON
line per request to --log: method, path, lowercased headers, body. Like the real server
(CheckUpstream.java wire facts) it answers HTTP 400 with JSON-RPC error -32020 when the
MCP-Protocol-Version header is missing, and 405 to a GET. Modes:

  one-error   a result with "1 error found" and one "line 1, column 1:" line
  many        a result with 60 "line N, column 1:" lines
  clean       a result starting "No errors found."
  rpc-error   HTTP 400 with a JSON-RPC error
  garbage     HTTP 200 with text that is not JSON
  sse         text/event-stream with one "data:" line holding the one-error reply

Like the real server's Gson, the reply JSON writes ' and = as unicode escapes. Nothing here
runs BBj. Standard library only; run it as: python3 -I tests/fake_mcp.py ...
"""

import argparse
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HEADER_LINE = "Checked against the local installation's PREFIX, classpath and config (BBj 26.03)."


def result_for(text):
    return {"jsonrpc": "2.0", "id": 1, "result": {"content": [{"type": "text", "text": text}], "isError": False}}


def gson_style(obj):
    return json.dumps(obj).replace("'", "\\u0027").replace("=", "\\u003d")


def body_for(mode):
    """Returns (status, content_type, body text) for MODE."""
    if mode == "one-error":
        text = "1 error found. " + HEADER_LINE + "\nline 1, column 1: [SyntaxError] syntax error"
        return 200, "application/json", gson_style(result_for(text))
    if mode == "many":
        lines = "\n".join("line %d, column 1: [SyntaxError] syntax error %d" % (i, i) for i in range(1, 61))
        return 200, "application/json", gson_style(result_for("60 errors found. " + HEADER_LINE + "\n" + lines))
    if mode == "clean":
        return 200, "application/json", gson_style(result_for("No errors found. " + HEADER_LINE))
    if mode == "rpc-error":
        err = {"jsonrpc": "2.0", "id": None, "error": {"code": -32020, "message": "unsupported protocol version"}}
        return 400, "application/json", json.dumps(err)
    if mode == "garbage":
        return 200, "text/html", "<html>not json at all</html>"
    if mode == "sse":
        text = "1 error found. " + HEADER_LINE + "\nline 1, column 1: [SyntaxError] syntax error"
        return 200, "text/event-stream", "event: message\ndata: " + gson_style(result_for(text)) + "\n\n"
    raise SystemExit("unknown mode " + mode)


def make_handler(mode, log_path):
    class Handler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def log_message(self, fmt, *args):
            pass

        def _reply(self, status, ctype, text):
            raw = text.encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(raw)))
            self.end_headers()
            self.wfile.write(raw)

        def _log(self, body):
            entry = {
                "method": self.command,
                "path": self.path,
                "headers": {k.lower(): v for k, v in self.headers.items()},
                "body": body,
            }
            with open(log_path, "a", encoding="utf-8") as fh:
                fh.write(json.dumps(entry) + "\n")

        def do_GET(self):
            self._log("")
            self._reply(405, "text/plain", "method not allowed")

        def do_POST(self):
            length = int(self.headers.get("Content-Length") or 0)
            body = self.rfile.read(length).decode("utf-8", "replace")
            self._log(body)
            if not self.headers.get("MCP-Protocol-Version"):
                err = {"jsonrpc": "2.0", "id": None, "error": {"code": -32020, "message": "missing MCP-Protocol-Version"}}
                self._reply(400, "application/json", json.dumps(err))
                return
            self._reply(*body_for(mode))

    return Handler


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port-file", required=True)
    ap.add_argument("--log", required=True)
    ap.add_argument("--mode", default="one-error")
    args = ap.parse_args()
    body_for(args.mode)  # validates the mode
    server = ThreadingHTTPServer(("127.0.0.1", 0), make_handler(args.mode, args.log))
    with open(args.port_file, "w", encoding="utf-8") as fh:
        fh.write(str(server.server_address[1]))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
