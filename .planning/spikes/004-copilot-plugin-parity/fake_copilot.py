#!/usr/bin/env python3
"""Fake OpenAI Responses API for spike 004 (Copilot CLI BYOK); adapted from spike 001 (loopback only, stdlib only).

Codex is pointed at it as a custom model provider. Turn 1 answers with one apply_patch
call that adds bad.bbj; every later turn answers with a plain message. Every request body
is appended to LOG (one JSON object per line) so the spike can see the tool list Codex
advertises and whether hook feedback came back as model input. Nothing here runs BBj.

Usage: python3 -I fake_responses.py PORT LOG
"""
import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1])
LOG = sys.argv[2]
PATCH = "*** Begin Patch\n*** Add File: bad.bbj\n+PRINT x   rem missing semicolon\n*** End Patch\n"


def sse(name, data):
    return ("event: %s\ndata: %s\n\n" % (name, json.dumps(data))).encode()


def usage():
    return {"input_tokens": 1, "input_tokens_details": {"cached_tokens": 0},
            "output_tokens": 1, "output_tokens_details": {"reasoning_tokens": 0},
            "total_tokens": 2}


def copilot_item(tools):
    name = os.environ.get("FAKE_TOOL", "")
    if not name:
        return None
    if name == "apply_patch":
        return patch_item(tools)
    args = json.loads(os.environ.get("FAKE_ARGS", "{}"))
    return {"type": "function_call", "name": name, "call_id": "call_1", "arguments": json.dumps(args)}


def patch_item(tools):
    kind = "custom"
    for t in tools or []:
        if t.get("name") == "apply_patch":
            kind = t.get("type", "custom")
    if kind == "function":
        return {"type": "function_call", "id": "fc_1", "name": "apply_patch", "call_id": "call_1",
                "arguments": json.dumps({"input": PATCH})}
    return {"type": "custom_tool_call", "id": "ctc_1", "name": "apply_patch", "call_id": "call_1",
            "input": PATCH}


class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def do_GET(self):
        with open(LOG, "a") as f:
            f.write(json.dumps({"method": "GET", "path": self.path}) + "\n")
        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        body = self.rfile.read(int(self.headers.get("Content-Length", "0") or 0))
        try:
            req = json.loads(body)
        except ValueError:
            req = {"raw": body.decode("utf-8", "replace")}
        with open(LOG, "a") as f:
            f.write(json.dumps({"method": "POST", "path": self.path, "body": req}) + "\n")
        items = req.get("input") or []
        answered = any(isinstance(i, dict) and i.get("type", "").endswith("_output") for i in items)
        if answered:
            item = {"type": "message", "role": "assistant", "id": "msg_1",
                    "content": [{"type": "output_text", "text": "done"}]}
        else:
            item = copilot_item(req.get("tools")) or {"type": "message", "role": "assistant", "id": "msg_0",
                                                     "content": [{"type": "output_text", "text": "noop"}]}
        rid = "resp_%d" % len(items)
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.end_headers()
        base = {"id": rid, "object": "response", "created_at": 0, "model": req.get("model", "m"),
                "status": "in_progress", "output": []}
        self.wfile.write(sse("response.created", {"type": "response.created", "sequence_number": 0, "response": base}))
        self.wfile.write(sse("response.in_progress", {"type": "response.in_progress", "sequence_number": 1, "response": base}))
        self.wfile.write(sse("response.output_item.added", {"type": "response.output_item.added", "sequence_number": 2,
                                                            "output_index": 0, "item": dict(item, status="in_progress")}))
        if item["type"] == "message":
            text = item["content"][0]["text"]
            self.wfile.write(sse("response.output_text.delta", {"type": "response.output_text.delta", "sequence_number": 3,
                                                                "item_id": item["id"], "output_index": 0,
                                                                "content_index": 0, "delta": text}))
        done = dict(item, status="completed")
        self.wfile.write(sse("response.output_item.done", {"type": "response.output_item.done", "sequence_number": 4,
                                                           "output_index": 0, "item": done}))
        final = dict(base, status="completed", output=[done], usage=usage())
        self.wfile.write(sse("response.completed", {"type": "response.completed", "sequence_number": 5,
                                                    "response": final}))
        self.wfile.flush()


HTTPServer(("127.0.0.1", PORT), H).serve_forever()
