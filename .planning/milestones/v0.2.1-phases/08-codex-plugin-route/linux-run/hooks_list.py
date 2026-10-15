#!/usr/bin/env python3
"""hooks_list.py -- plan 08-05: read Codex hook trust through the app server (never CI).

Usage: python3 -I hooks_list.py CODEX_HOME

Starts `codex app-server` (stdio) with HOME set to the parent of CODEX_HOME and CODEX_HOME
set to the throwaway home, sends newline-delimited JSON-RPC, and prints one line per hook:

    key=<key> source=<source> trustStatus=<status> currentHash=<hash> command=<command>

The request shapes come from `codex app-server generate-json-schema` (codex-cli 0.162.1):
  initialize  params {"clientInfo": {"name", "version"}}   (ClientInfo requires name, version)
  initialized notification (no params), sent after the initialize reply
  hooks/list  params {"cwds": [<project dir>]}   (cwds empty = the session cwd)
The reply holds objects with the HookMetadata fields (key, source, trustStatus, currentHash,
eventName, command for handlerType "command"); this script walks the whole reply and prints
every object that has both key and trustStatus, so a change of the wrapper object (a list of
per-cwd entries today) does not break it.

Refuses a CODEX_HOME that is not below $HOME/.cache/bbj-phase8/ (the real ~/.codex is never
read). Never runs BBj and never contacts a model: the app server is only asked for hooks.
Exit codes: 0 printed (even when no hook is found), 1 the server failed or timed out, 2 refused.
"""
import json
import os
import select
import subprocess
import sys
import time

TIMEOUT = 30


def refuse(msg):
    sys.stderr.write("hooks_list.py: refused %s\n" % msg)
    sys.exit(2)


def walk(node, found):
    if isinstance(node, dict):
        if "key" in node and "trustStatus" in node:
            found.append(node)
        for value in node.values():
            walk(value, found)
    elif isinstance(node, list):
        for value in node:
            walk(value, found)


def main():
    if len(sys.argv) != 2:
        refuse("(usage: hooks_list.py CODEX_HOME)")
    real_home = os.environ.get("HOME", "")
    base = os.path.join(real_home, ".cache", "bbj-phase8") + os.sep
    codex_home = os.path.abspath(sys.argv[1])
    if not codex_home.startswith(base) or ".." in sys.argv[1].split(os.sep):
        refuse("CODEX_HOME %s (must be below %s)" % (codex_home, base))
    home = os.path.dirname(codex_home)
    project = os.path.join(home, "..", "proj")
    project = os.path.abspath(project)
    env = dict(os.environ)
    env["HOME"] = home
    env["CODEX_HOME"] = codex_home
    for name in ("CLAUDE_PLUGIN_ROOT", "PLUGIN_ROOT", "CLAUDE_PLUGIN_DATA"):
        env.pop(name, None)
    proc = subprocess.Popen(
        ["codex", "app-server"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        env=env,
        cwd=project if os.path.isdir(project) else home,
    )

    def send(obj):
        proc.stdin.write((json.dumps(obj) + "\n").encode())
        proc.stdin.flush()

    def read_reply(want_id, deadline):
        buf = b""
        while time.time() < deadline:
            ready, _, _ = select.select([proc.stdout], [], [], 0.5)
            if not ready:
                if proc.poll() is not None:
                    return None
                continue
            chunk = os.read(proc.stdout.fileno(), 65536)
            if not chunk:
                return None
            buf += chunk
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                try:
                    msg = json.loads(line)
                except ValueError:
                    continue
                if isinstance(msg, dict) and msg.get("id") == want_id and (
                    "result" in msg or "error" in msg
                ):
                    return msg
        return None

    status = 1
    try:
        deadline = time.time() + TIMEOUT
        send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
              "params": {"clientInfo": {"name": "bbj-phase8-hooks-list", "version": "0"}}})
        reply = read_reply(1, deadline)
        if reply is None or "error" in reply:
            sys.stderr.write("hooks_list.py: initialize failed: %s\n" % (reply,))
            return 1
        send({"jsonrpc": "2.0", "method": "initialized"})
        cwds = [project] if os.path.isdir(project) else []
        send({"jsonrpc": "2.0", "id": 2, "method": "hooks/list", "params": {"cwds": cwds}})
        reply = read_reply(2, deadline)
        if reply is None or "error" in reply:
            sys.stderr.write("hooks_list.py: hooks/list failed: %s\n" % (reply,))
            return 1
        found = []
        walk(reply.get("result"), found)
        for hook in found:
            meta = hook.get("command")
            print("key=%s source=%s trustStatus=%s currentHash=%s command=%s" % (
                hook.get("key"), hook.get("source"), hook.get("trustStatus"),
                hook.get("currentHash"), meta))
        status = 0
    finally:
        try:
            proc.stdin.close()
        except OSError:
            pass
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
    return status


if __name__ == "__main__":
    sys.exit(main())
