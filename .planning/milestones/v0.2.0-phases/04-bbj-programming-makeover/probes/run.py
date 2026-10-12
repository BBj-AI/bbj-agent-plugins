"""probes/run.py -- plan 04-01, PROG-01; decisions D-03, D-07, D-13: the compile-only probe runner.

Compiles every probe file of this directory (one minimal BBj program per file, name of lowercase
letters, digits and '_', ending .bbj) and records what the two local checks say about it, so that
every COMPILE row of the claim ledger (04-LEDGER.md, plan 04-02) can cite a line of OUTPUT.txt that
anyone with a BBj 26.03 can regenerate:

    python3 -I probes/run.py           write probes/OUTPUT.txt (atomically, then print a gate line)
    python3 -I probes/run.py --check   recompute everything and compare it with probes/OUTPUT.txt

Exit codes: 0 written or reproduced; 1 a canary failed, a compiler line could not be attributed,
a bbj-ls reply gave no verdict, or --check found a difference; 2 usage, or the compiler or the
bbj-ls route is missing (nothing written).

Route 1 is one batched call of bbjcpl with -t -N -X (plus one batched call with -W added, for the
probes named *_w.bbj only, still with -N). Route 2 is the loopback bbj-ls, asked with the request
body and headers of the hook. A canary pair (canary_good.bbj, canary_bad.bbj) makes a dead compiler
visible. The probe files are copied into a fresh temporary directory outside the repository, so the
compiler's records name that directory, which is removed from every line before it is recorded.

The only program this script starts is the compiler, with -t -N -X; the only network peer is the
loopback bbj-ls (no proxy, no redirect). The hosted check and the hosted docs server are never
contacted. BBj code is never run; probe text is data, never part of a command.
"""
import http.client
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PATH = os.path.join(HERE, "OUTPUT.txt")
# -N is compile only: no output file, nothing runs (the same constant as tests/test_skill_examples.py)
CPL_ARGS = ["-t", "-N", "-X"]
CPL_TIMEOUT = 300
LS_URL = "http://127.0.0.1:5009/mcp"
PROTOCOL = "2026-07-28"
LS_TIMEOUT = 12
LS_PROBE_TIMEOUT = 2
LS_MAX_REPLY = 1048576
CANARY_GOOD = 'print "a"; rem ok\n'
CANARY_BAD = 'print "a"   rem same line\n'
LS_LINE_RE = re.compile(r"^line ([0-9]+), column ([0-9]+):(.*)$")
VERSION_RE = re.compile(r"[0-9A-Za-z.-]{1,20}")
NAME_RE = re.compile(r"^[a-z0-9_]+\.bbj$")
USAGE = "usage: python3 -I probes/run.py [--check]\n"
RW_PATH = os.path.join(HERE, "rw-words.txt")
RW_WORD_RE = re.compile(r"^[a-z_0-9]+$")
# reserved-word forms (D-13): file name prefix, source line template, name shown in OUTPUT.txt
RW_FORMS = (("n", "%s = 1", "numeric"), ("s", '%s$ = "x"', "string"), ("o", "%s! = 1", "object"))
HEADER = ("# probes/OUTPUT.txt -- written by python3 -I probes/run.py (plan 04-01, D-03); "
          "compile only, nothing was run")


def safe(text):
    """Printable ASCII only: any other character becomes '?', so a compiler line can never start a
    forged gate line or break the file."""
    return re.sub(r"[^\x20-\x7e]", "?", str(text))


def cpl_path():
    """The compiler under BBJ_TEST_HOME (default /opt/bbx) when it is a regular executable file."""
    home = os.environ.get("BBJ_TEST_HOME") or "/opt/bbx"
    path = os.path.join(home, "bin", "bbjcpl")
    if os.path.isfile(path) and os.access(path, os.X_OK):
        return path
    return None


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    """A 3xx reply is an error here, never a second request."""

    def redirect_request(self, *args, **kwargs):
        return None


# one opener for every network access of this file: an empty ProxyHandler ignores the proxy
# variables of the environment, and the refusing redirect handler replaces the default one
OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}), _NoRedirect())


def ls_up():
    """True when a GET to LS_URL is answered with 405 (the bbj-ls route probe); anything else is False."""
    try:
        with OPENER.open(urllib.request.Request(LS_URL, method="GET"), timeout=LS_PROBE_TIMEOUT):
            return False
    except urllib.error.HTTPError as e:
        e.close()
        return e.code == 405
    except (urllib.error.URLError, OSError, http.client.HTTPException, ValueError):
        return False


def probe_names():
    """Sorted probe file names of HERE; None when one does not match NAME_RE (exit 2)."""
    names = sorted(n for n in os.listdir(HERE) if n.endswith(".bbj"))
    for n in names:
        if not NAME_RE.match(n):
            sys.stderr.write("probe name %s does not match [a-z0-9_]+.bbj\n" % safe(n))
            return None
    return names


def attribute(text, tmpdir, names):
    """(records by name, stray lines): a line that starts with '<tmpdir>/<name>: ' opens a record of
    that name; every other non-empty line continues the previous record; a non-empty line before the
    first record is stray. A name is taken whole, so a.bbj never takes a record of ab.bbj."""
    prefix = tmpdir + "/"
    known = set(names)
    records, current, stray = {}, None, []
    for line in text.split("\n"):
        owner = None
        if line.startswith(prefix):
            rest = line[len(prefix):]
            cut = rest.find(": ")
            if cut > 0 and rest[:cut] in known:
                owner = rest[:cut]
        if owner is not None:
            current = [line]
            records.setdefault(owner, []).append(current)
        elif line.strip():
            if current is not None:
                current.append(line)
            else:
                stray.append(line)
    return records, stray


def compile_batch(cpl, extra, tmpdir, names):
    """(exit status, stdout byte count, records, stray lines, error text) of ONE compiler call.

    The argument list never goes through a shell, stdin is /dev/null (a bare compiler waits on it)
    and the exit status is evidence only: it is 0 on every outcome."""
    argv = [cpl] + CPL_ARGS + extra + [os.path.join(tmpdir, n) for n in names]
    try:
        done = subprocess.run(argv, cwd=tmpdir, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, timeout=CPL_TIMEOUT)
    except OSError as e:
        return None, 0, {}, [], "cannot start the compiler: %s" % safe(e)
    except subprocess.TimeoutExpired:
        return None, 0, {}, [], "no answer from the compiler in %d s" % CPL_TIMEOUT
    text = done.stderr.decode("utf-8", errors="replace").replace("\r\n", "\n")
    records, stray = attribute(text, tmpdir, names)
    return done.returncode, len(done.stdout), records, stray, ""


def normalize(record, tmpdir):
    """One record as one line: the temporary directory removed everywhere (so the line reads
    '<name>: ...'), continuation lines joined with ' / ', the messages inside the first [...] of a
    type check record sorted, trailing blanks stripped."""
    text = " / ".join(l.rstrip() for l in record).replace(tmpdir + "/", "")
    if "type check" in text and "[" in text and "] at line" in text:
        a = text.index("[") + 1
        b = text.index("] at line")
        if a <= b:
            text = text[:a] + "; ".join(sorted(text[a:b].split("; "))) + text[b:]
    return safe(text.rstrip())


def ls_call(code):
    """(reply dict or None, error text): one bbj_check_syntax call, the hook's request. An
    event-stream reply is reduced to the payload of its last data: line. Every transport, HTTP or
    parse failure is an error text, never an exception."""
    body = {"jsonrpc": "2.0", "id": 1, "method": "tools/call",
            "params": {"name": "bbj_check_syntax", "arguments": {"code": code},
                       "_meta": {"io.modelcontextprotocol/protocolVersion": PROTOCOL,
                                 "io.modelcontextprotocol/clientCapabilities": {}}}}
    headers = {"Content-Type": "application/json", "MCP-Protocol-Version": PROTOCOL,
               "Mcp-Method": "tools/call", "Mcp-Name": "bbj_check_syntax"}
    try:
        req = urllib.request.Request(LS_URL, data=json.dumps(body).encode("utf-8"), headers=headers,
                                     method="POST")
        with OPENER.open(req, timeout=LS_TIMEOUT) as r:
            text = r.read(LS_MAX_REPLY).decode("utf-8", errors="replace")
        data = [l.replace("\r", "") for l in text.split("\n") if l.startswith("data:")]
        if data:
            text = data[-1][len("data:"):].strip()
        return json.loads(text), ""
    except (urllib.error.URLError, OSError, http.client.HTTPException, ValueError) as e:
        return None, safe("%s: %s" % (type(e).__name__, e))[:200]


def ls_verdict(reply):
    """(verdict, error lines, version): verdict is clean, errors or noverdict. Like the hook: no
    verdict unless the reply is an object without an 'error' member whose result is an object with
    isError exactly false; clean when the text starts 'No errors found.', errors when lines
    'line N, column M:' exist, else no verdict."""
    if not isinstance(reply, dict) or "error" in reply:
        return "noverdict", [], None
    result = reply.get("result")
    if not isinstance(result, dict) or result.get("isError") is not False:
        return "noverdict", [], None
    version = None
    structured = result.get("structuredContent")
    if isinstance(structured, dict):
        value = structured.get("bbjVersion")
        if isinstance(value, str) and VERSION_RE.fullmatch(value):
            version = value
    content = result.get("content")
    text = "\n".join(c["text"] for c in content if isinstance(c, dict) and isinstance(c.get("text"), str)
                     ) if isinstance(content, list) else ""
    if text.startswith("No errors found."):
        return "clean", [], version
    found = [l.rstrip() for l in text.split("\n") if LS_LINE_RE.match(l)]
    if found:
        return "errors", found, version
    return "noverdict", [], version


def ls_check(code):
    """(verdict, error lines, version, error text) of one probe's text."""
    reply, err = ls_call(code)
    if reply is None:
        return "noverdict", [], None, err
    verdict, lines, version = ls_verdict(reply)
    return verdict, lines, version, ""


def rw_words():
    """(words, problem): the lines of rw-words.txt, each one [a-z_0-9]+ (D-13)."""
    try:
        with open(RW_PATH, "r", encoding="utf-8") as f:
            words = [l.rstrip("\n") for l in f.read().split("\n") if l.strip()]
    except OSError as e:
        return None, "cannot read rw-words.txt: %s" % safe(e)
    for w in words:
        if not RW_WORD_RE.match(w):
            return None, "rw-words.txt holds a line that is not [a-z_0-9]+: %s" % safe(w)
    return words, ""


def read_text(path):
    with open(path, "rb") as f:
        return f.read().decode("utf-8", errors="replace")


def collect(cpl, names, tmpdir):
    """(output lines, problem): everything one run records, or (None, problem) when a check of the
    evidence itself fails. The canary result is printed as a gate line."""
    for n in names:
        shutil.copyfile(os.path.join(HERE, n), os.path.join(tmpdir, n))
    with open(os.path.join(tmpdir, "canary_good.bbj"), "w", encoding="utf-8", newline="\n") as f:
        f.write(CANARY_GOOD)
    with open(os.path.join(tmpdir, "canary_bad.bbj"), "w", encoding="utf-8", newline="\n") as f:
        f.write(CANARY_BAD)
    words, problem = rw_words()
    if words is None:
        return None, problem
    rwfiles = {}
    for w in words:
        for prefix, template, form in RW_FORMS:
            rwname = "%s_%s.bbj" % (prefix, w)
            with open(os.path.join(tmpdir, rwname), "w", encoding="utf-8", newline="\n") as f:
                f.write(template % w + "\n")
            rwfiles[rwname] = (w, form)
    everything = names + sorted(rwfiles) + ["canary_good.bbj", "canary_bad.bbj"]
    rc, nout, records, stray, err = compile_batch(cpl, [], tmpdir, everything)
    if err:
        return None, err
    if stray:
        return None, "unattributed compiler line: %s" % safe(stray[0])[:200]
    if "canary_bad.bbj" not in records or "canary_good.bbj" in records:
        print("gate probes_canary FAIL bbjcpl canary failed")
        return None, "bbjcpl canary failed"
    print("gate probes_canary ok bbjcpl and canaries agree")
    wnames = [n for n in names if n.endswith("_w.bbj")]
    wrc, wnout, wrecords, wstray = None, 0, {}, []
    if wnames:
        wrc, wnout, wrecords, wstray, err = compile_batch(cpl, ["-W"], tmpdir, wnames)
        if err:
            return None, err
        if wstray:
            return None, "unattributed compiler line (-W): %s" % safe(wstray[0])[:200]
    verdicts, version = {}, None
    for n in names:
        verdict, lines, ver, err = ls_check(read_text(os.path.join(HERE, n)))
        if verdict == "noverdict":
            return None, "bbj-ls gave no verdict for %s%s" % (n, (": " + err) if err else "")
        verdicts[n] = lines
        if version is None and ver is not None:
            version = ver
    failing = {}
    for rwname in sorted(rwfiles):
        w, form = rwfiles[rwname]
        if rwname in records:
            failing.setdefault(("bbjcpl", form), []).append(w)
        verdict, lines, ver, err = ls_check(read_text(os.path.join(tmpdir, rwname)))
        if verdict == "noverdict":
            return None, "bbj-ls gave no verdict for %s%s" % (rwname, (": " + err) if err else "")
        if verdict == "errors":
            failing.setdefault(("bbj-ls", form), []).append(w)
    out = [HEADER,
           "BBj version: %s (bbj-ls structuredContent.bbjVersion)" % (version or "unknown"),
           "bbjcpl %s, one batched call: exit status %s, stdout %d bytes"
           % (" ".join(CPL_ARGS), rc, nout)]
    if wnames:
        out.append("bbjcpl %s -W, one batched call: exit status %s, stdout %d bytes"
                   % (" ".join(CPL_ARGS), wrc, wnout))
    for n in names:
        out.append("")
        out.append("== %s" % n)
        mine = records.get(n)
        if mine:
            for rec in mine:
                out.append("bbjcpl: %s" % normalize(rec, tmpdir))
        else:
            out.append("bbjcpl: clean")
        if n in wnames:
            wmine = wrecords.get(n)
            if wmine:
                for rec in wmine:
                    out.append("bbjcpl -W: %s" % normalize(rec, tmpdir))
            else:
                out.append("bbjcpl -W: clean")
        if verdicts[n]:
            for line in verdicts[n]:
                out.append("bbj-ls: %s" % safe(line))
        else:
            out.append("bbj-ls: clean")
    out.append("")
    out.append("== rw (%d words x 3 forms, generated from rw-words.txt)" % len(words))
    for route in ("bbjcpl", "bbj-ls"):
        for prefix, template, form in RW_FORMS:
            bad = sorted(failing.get((route, form), []))
            out.append(("rw %s %s %d: %s" % (route, form, len(bad), " ".join(bad))).rstrip())
    return out, ""


def render(cpl, names):
    """(lines, problem): collect() inside a fresh temporary directory that is always removed."""
    tmpdir = tempfile.mkdtemp(prefix="bbjprobe")
    try:
        return collect(cpl, names, tmpdir)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def write_output(lines):
    """Write OUTPUT_PATH atomically: a temporary file in HERE, then os.replace."""
    fd, tmp = tempfile.mkstemp(prefix="OUTPUT.", suffix=".tmp", dir=HERE)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")
        os.replace(tmp, OUTPUT_PATH)
    except OSError:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def main(argv):
    if argv not in ([], ["--check"]):
        sys.stderr.write(USAGE)
        return 2
    check = bool(argv)
    cpl = cpl_path()
    if cpl is None:
        sys.stderr.write("no executable bbjcpl under BBJ_TEST_HOME or /opt/bbx\n")
        return 2
    if not ls_up():
        sys.stderr.write("bbj-ls does not answer 405 on %s\n" % LS_URL)
        return 2
    names = probe_names()
    if names is None:
        return 2
    lines, problem = render(cpl, names)
    if lines is None:
        sys.stderr.write("%s\n" % problem)
        return 1
    if not check:
        write_output(lines)
        print("gate probes_written ok %d probes" % len(names))
        return 0
    try:
        with open(OUTPUT_PATH, "r", encoding="utf-8", newline="") as f:
            old = f.read().split("\n")
    except OSError as e:
        print("gate probes_reproduce FAIL cannot read OUTPUT.txt: %s" % safe(e))
        return 1
    if old and old[-1] == "":
        old.pop()
    for k in range(max(len(old), len(lines))):
        a = old[k] if k < len(old) else "<missing>"
        b = lines[k] if k < len(lines) else "<missing>"
        if a != b:
            print("gate probes_reproduce FAIL line %d: expected %s got %s"
                  % (k + 1, safe(a)[:160], safe(b)[:160]))
            return 1
    print("gate probes_reproduce ok %d probes" % len(names))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
