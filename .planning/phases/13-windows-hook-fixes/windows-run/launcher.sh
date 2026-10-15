#!/bin/sh
# .planning/phases/13-windows-hook-fixes/windows-run/launcher.sh -- plan 13-04 (FIX-01, SC1; D-19,
# D-20 case 4): runs the commandWindows of plugins/bbj/hooks/hooks.json outside Codex, through
# Windows PowerShell and pwsh, with each Git for Windows layout faked by environment variables and
# junctions. Evidence for the phase record (13-WINDOWS-RUN.md), never CI: CI has no Windows and no
# PowerShell, and nothing here is a gate.
# Round 3 (the fixes of 13-REVIEW.md, recorded in 13-REVIEW-FIX.md) adds one case or more per fix; the
# case table of runbook.md names the fix each case proves.
#
# Safety rules (threats T-13-13, T-13-14 and T-13-20):
#   - starts no BBj except through the hook itself, whose compiler call is compile-only (-N);
#   - never touches a Codex home, the real ~/.codex or the real ~/.claude;
#   - OUTDIR must be an absolute path below $HOME/.cache/bbj-phase13/, must not contain .. and must
#     not be under /tmp; run also refuses an OUTDIR that exists already, because a previous run's
#     OUTDIR holds junctions;
#   - never deletes recursively while a junction exists: clean removes the junctions first with
#     a non-recursive rmdir, checks that none is left under OUTDIR and that Git's bin\sh.exe still
#     exists, and only then removes OUTDIR (and only a directory that run marked as its own);
#   - the one subst drive (case lad_unset_driveroot_bbj, WR-02) is made only on a free drive letter,
#     its letter is written to OUTDIR/subst.drive at once, and it is removed straight after its case
#     (clean removes it too when a run stopped early);
#   - prints no user name: every value that reaches result.txt or the screen goes through scrub
#     (OUTDIR, the checkout and the Windows home in three forms become <work>, <checkout>, <home>).
#
# Usage: sh launcher.sh MODE [OUTDIR]
#   selftest        any POSIX host: extract_cmd against python3 json, the fingerprint, safe_out,
#                   payload, drivepath, scrub and the verdict rules; prints "selftest ok"
#   run OUTDIR      Git Bash on Windows only: readings, then every case of the table, then the
#                   result block (eight spaces indented, ready to paste)
#   clean OUTDIR    Git Bash on Windows only: junctions first, checks, then OUTDIR
# Output: OUTDIR/result.txt (key: value lines and one result line per case) and raw per-case files
# in OUTDIR/cases/; not committed.
# Exit codes: 0 ran to the end, 1 a step failed, 2 refused or usage error.

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
REALHOME=$HOME
BASE=$HOME/.cache/bbj-phase13
HOOKS=$REPO/plugins/bbj/hooks/hooks.json
# the current pin (13-REVIEW-FIX.md): sha256 of the commandWindows string as hooks.json holds it (before
# the root is set); rounds 1 and 2 ran the plan 13-02 pin
PIN_SHA=812f6bbfa6466334d87995c6528f5b0d6f46c83c496e483c1f99533404de3c51
CLM_PREFIX='$ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"; '
MARKER=launcher.marker
OUT=
SCRUBMAP=
TAB=$(printf '\t')

# refuse DIR WHY: exit 2 with the fixed message
refuse() {
  echo "launcher.sh: refused OUTDIR $1 ($2)" >&2
  exit 2
}

# die2 WHY: exit 2, the run cannot start here
die2() {
  echo "launcher.sh: refused ($1)" >&2
  exit 2
}

# usage: exit 2
usage() {
  echo "usage: sh launcher.sh selftest | run OUTDIR | clean OUTDIR" >&2
  exit 2
}

# safe_out DIR [keep]: the absolute path must be below $HOME/.cache/bbj-phase13/. Without keep DIR must
# not exist and is created (this launcher never deletes and recreates: a previous OUTDIR holds
# junctions). With keep the same checks run, nothing is created and DIR must already exist.
safe_out() {
  case $1 in
    /*) ;;
    *) refuse "$1" "not an absolute path" ;;
  esac
  case $1 in
    /tmp | /tmp/*) refuse "$1" "under /tmp" ;;
    "$REALHOME"/.codex | "$REALHOME"/.codex/*) refuse "$1" "under the real ~/.codex" ;;
    "$REALHOME"/.claude | "$REALHOME"/.claude/*) refuse "$1" "under the real ~/.claude" ;;
    */.. | */../*) refuse "$1" "contains .." ;;
    */) refuse "$1" "ends with a slash" ;;
  esac
  case $1 in
    "$BASE"/?*) ;;
    *) refuse "$1" "outside $BASE/" ;;
  esac
  if [ "${2:-}" = keep ]; then
    [ -d "$1" ] || refuse "$1" "keep mode needs an existing directory"
    return 0
  fi
  [ ! -e "$1" ] || refuse "$1" "exists already; run clean on it first"
  mkdir -p "$1" || refuse "$1" "cannot be created"
}

# drivepath WINPATH: C:\X\Y becomes /c/X/Y (lower-case drive letter, backslashes to slashes). Never use
# cygpath -u for a Git directory: Git Bash mounts / at the Git root and /bin at Git's usr\bin.
drivepath() {
  printf '%s\n' "$1" | awk '{
    s = $0
    gsub(/\\/, "/", s)
    if (substr(s, 2, 1) == ":") s = "/" tolower(substr(s, 1, 1)) substr(s, 3)
    print s
  }'
}

# have_python3: a python3 that runs. On Windows `command -v python3` can find the Microsoft Store
# alias stub in WindowsApps, which only prints a hint and exits non-zero (Windows run, H1).
have_python3() {
  command -v python3 > /dev/null 2>&1 && python3 -I -c pass > /dev/null 2>&1
}

# extract_cmd: the commandWindows JSON string of hooks.json, unescaped (\" and \\ only; anything else
# or a count of lines other than one fails), printed without a newline
extract_cmd() {
  sed -n 's/^[[:space:]]*"commandWindows":[[:space:]]*"\(.*\)",[[:space:]]*$/\1/p' "$HOOKS" | awk '
    {
      s = $0
      out = ""
      while (length(s) > 0) {
        c = substr(s, 1, 1)
        if (c == "\\") {
          n = substr(s, 2, 1)
          if (n == "\"" || n == "\\" || n == "/") {
            out = out n
            s = substr(s, 3)
            continue
          }
          bad = 1
        }
        out = out c
        s = substr(s, 2)
      }
      printf "%s", out
    }
    END { if (NR != 1 || bad) exit 1 }'
}

# subst_root TEXT ROOT: TEXT with every ${CLAUDE_PLUGIN_ROOT} replaced by ROOT (fixed strings:
# index/substr, never a regex), printed without a newline
subst_root() {
  S_TEXT=$1 S_ROOT=$2 awk '
    BEGIN {
      s = ENVIRON["S_TEXT"]
      r = ENVIRON["S_ROOT"]
      k = "${CLAUDE_PLUGIN_ROOT}"
      done = ""
      while ((i = index(s, k)) > 0) {
        done = done substr(s, 1, i - 1) r
        s = substr(s, i + length(k))
      }
      printf "%s", done s
    }'
}

# scrub_add FROM TO: one fixed-string replacement for scrub (an empty FROM is skipped)
scrub_add() {
  [ -n "$1" ] || return 0
  printf '%s%s%s\n' "$1" "$TAB" "$2" >> "$SCRUBMAP"
}

# scrub TEXT: print TEXT with the replacements of SCRUBMAP applied in file order, as fixed strings
# (index/substr: never a regex)
scrub() {
  S_TEXT=$1 awk -v map="$SCRUBMAP" '
    function rep(s, from, to,    done, i) {
      if (from == "") return s
      done = ""
      while ((i = index(s, from)) > 0) {
        done = done substr(s, 1, i - 1) to
        s = substr(s, i + length(from))
      }
      return done s
    }
    BEGIN {
      t = ENVIRON["S_TEXT"]
      while ((getline line < map) > 0) {
        j = index(line, "\t")
        if (j > 1) t = rep(t, substr(line, 1, j - 1), substr(line, j + 1))
      }
      print t
    }'
}

# res KEY VALUE: one reading in OUT/result.txt; the value is scrubbed and kept on one line
res() {
  _v=$(scrub "$2" | tr '\n' ' ' | sed 's/ *$//')
  printf '%s: %s\n' "$1" "$_v" >> "$OUT/result.txt"
}

# jesc TEXT: JSON string content (backslash, quote, tab, CR escaped; newlines become \n)
jesc() {
  _jt=$(printf '\t')
  _jr=$(printf '\r')
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$_jt/\\\\t/g" -e "s/$_jr/\\\\r/g" \
    | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'
}

# payload CWDWIN FILEWIN PATCHBODY: a Codex PostToolUse payload for apply_patch (the key order of
# codex_payload in tests/lib.sh, captured from Codex CLI 0.162.1); PATCHBODY holds the "+" lines of
# one Add File. One physical line, no trailing newline.
payload() {
  payload_patch "$1" "$(printf '*** Begin Patch\n*** Add File: %s\n%s\n*** End Patch' "$2" "$3")"
}

# payload_patch CWDWIN PATCH: the same payload with the whole patch text given
payload_patch() {
  printf '%s' '{"session_id":"s1","turn_id":"t1","transcript_path":null,"cwd":"'"$(jesc "$1")"'","hook_event_name":"PostToolUse","model":"m1","permission_mode":"bypassPermissions","tool_name":"apply_patch","tool_input":{"command":"'"$(jesc "$2")"'"},"tool_response":"Exit code: 0\nWall time: 0 seconds\nOutput:\nSuccess. Updated the following files:\n","tool_use_id":"u1"}'
}

# filler: "+rem" lines, about 11 KB, enough to push a payload past 8192 bytes
filler() {
  awk 'BEGIN { for (i = 1; i <= 150; i++) printf "+rem filler line %d ....................................................\n", i }'
}

# want_kind CASE: the expectation of the case table
want_kind() {
  case $1 in
    default_clean | none_notes | none_web_src) echo clean ;;
    none_bbj | clm_none_bbj | pwsh_none_bbj | othersh_none_bbj | lad_unset_driveroot_bbj | none_update_src) echo notfound ;;
    none_long_bbj | none_long_notes) echo notfound_first ;;
    *) echo bbjcpl ;;
  esac
}

# check_want KIND RC OUT_BYTES ERR_LINES FIRST [TRAIL]: "as expected" or "differs (want ...)"; TRAIL is
# the number of stderr lines that end in a space, which the not-found kinds require to be 0 (IN-04)
check_want() {
  _w=
  case $1 in
    bbjcpl)
      case $5 in
        'bbjcpl reported 1 error(s) in'*) [ "$2" = 2 ] && _w=ok ;;
      esac
      _d='rc=2 and first line "bbjcpl reported 1 error(s) in"'
      ;;
    clean)
      [ "$2" = 0 ] && [ "$3" = 0 ] && [ "$4" = 0 ] && _w=ok
      _d='rc=0 and no output'
      ;;
    notfound)
      case $5 in
        'bbj-check: Git for Windows sh.exe not found'*) [ "$2" = 2 ] && [ "$4" = 3 ] && [ "${6:-0}" = 0 ] && _w=ok ;;
      esac
      _d='rc=2, 3 stderr lines, none ending in a space, and first line "bbj-check: Git for Windows sh.exe not found"'
      ;;
    notfound_first)
      case $5 in
        'bbj-check: Git for Windows sh.exe not found'*) [ "$2" = 2 ] && [ "${6:-0}" = 0 ] && _w=ok ;;
      esac
      _d='rc=2, no stderr line ending in a space, and first line "bbj-check: Git for Windows sh.exe not found"'
      ;;
  esac
  if [ "$_w" = ok ]; then
    echo "as expected"
  else
    echo "differs (want $_d)"
  fi
}

# winenv NAME: the value a native Windows program sees for NAME (from NATIVE_ENV, case-insensitive)
winenv() {
  printf '%s\n' "$NATIVE_ENV" | awk -v n="$1" '{
    i = index($0, "=")
    if (i > 1 && toupper(substr($0, 1, i - 1)) == toupper(n)) { print substr($0, i + 1); exit }
  }'
}

# junction LINK TARGET: a directory junction (no admin needed); LINK and TARGET are Git Bash paths and
# TARGET is a Windows path. The paths travel in environment variables, never in command text.
junction() {
  _jl=$(cygpath -w "$1")
  env LNK="$_jl" TGT="$2" "$PSEXE" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command \
    'New-Item -ItemType Junction -Path $env:LNK -Target $env:TGT | Out-Null' > /dev/null 2>&1
  [ -f "$1/bin/sh.exe" ]
}

# unjunction LINK: remove only the link, never its content (rmdir without /s)
unjunction() {
  _ul=$(cygpath -w "$1")
  cmd.exe /c rmdir "$_ul" > /dev/null 2>&1
}

# subst_make: a subst drive for lay\drv on the first free letter of Z to P; sets SUBST_L and writes
# the letter to OUT/subst.drive at once. A letter in use is never touched.
subst_make() {
  SUBST_L=
  for _l in Z Y X W V U T S R Q P; do
    cmd.exe /c "if exist $_l:\ (exit 1) else (exit 0)" > /dev/null 2>&1 || continue
    cmd.exe /c subst "$_l:" "$OUTW\lay\drv" > /dev/null 2>&1 || continue
    printf '%s\n' "$_l" > "$OUT/subst.drive"
    if cmd.exe /c "if exist $_l:\Programs\Git\bin\sh.exe (exit 0) else (exit 1)" > /dev/null 2>&1; then
      SUBST_L=$_l
      return 0
    fi
    subst_drop
  done
  return 1
}

# subst_drop: removes the subst drive named by OUT/subst.drive (one letter A to Z, else nothing)
subst_drop() {
  [ -f "$OUT/subst.drive" ] || return 0
  _sl=$(head -n 1 "$OUT/subst.drive")
  case $_sl in
    [A-Z]) cmd.exe /c subst "$_sl:" /d > /dev/null 2>&1 ;;
  esac
  rm -f "$OUT/subst.drive"
}

# caseline LINE: one result line in result.txt (scrubbed) and its pass-through on the screen block
caseline() {
  _cl=$(scrub "$1")
  printf '%s\n' "$_cl" >> "$OUT/result.txt"
}

# layout_set LAYOUT [HOST]: sets LPF LPF86 LLAD (Windows paths of the three roots), LW64 (ProgramW6432),
# LUP (USERPROFILE) and LPATH (the cygdrive-form PATH list); an empty LLAD, LW64 or LUP leaves the
# variable unset; fails for an unknown layout
layout_set() {
  LW64=
  LPF=$OUTW'\lay\empty'
  LPF86=$OUTW'\lay\empty'
  LLAD=$OUTW'\lay\empty'
  LUP=$(winenv USERPROFILE)
  LPATH=$SYSP
  case $1 in
    pf86) LPF86=$OUTW'\lay\pf86' ;;
    w6432) LW64=$OUTW'\lay\w64' ;;
    lad) LLAD=$OUTW'\lay\lad' ;;
    ladunset_prof) LLAD='' LUP=$OUTW'\lay\prof' ;;
    ladunset_none) LLAD='' LUP='' ;;
    shpath) LPATH=$SYSP:$GITBIN_P ;;
    usrpath) LPATH=$SYSP:$GITUSR_P ;;
    mingwpath) LPATH=$SYSP:$GITMINGW_P ;;
    othersh) LPATH=$SYSP:$OTHERSH_P ;;
    othersh_git) LPATH=$SYSP:$OTHERSH_P:$GITBIN_P ;;
    gitpath) LPATH=$SYSP:$GITCMD_P ;;
    none) ;;
    *) return 1 ;;
  esac
  case ${2:-} in
    pwsh*) [ -z "$PWSHDIR_P" ] || LPATH=$LPATH:$PWSHDIR_P ;;
  esac
  return 0
}

# runcase NAME HOST MODE PAYLOADFILE [PREFIX]: HOST is powershell, powershell+clm, powershell32 (the
# 32-bit Windows PowerShell of SysWOW64), pwsh or pwsh+clm;
# MODE is asis or a layout name. The payload goes in through a pipe (as Codex writes it), the command is
# CASE_CMD (the shipped string with the plugin root set), after PREFIX (PowerShell text, for example a
# Set-Location). CLAUDE_PLUGIN_ROOT is set to CASE_ROOTW, as Codex sets it for a plugin hook, or left
# unset when CASE_ROOTW is empty. Records one result line.
runcase() {
  _n=$1 _host=$2 _mode=$3 _pf=$4 _pre=${5:-}
  case $_host in
    pwsh*)
      if [ -z "$PWSHEXE" ]; then
        caseline "$_n: -> not run (pwsh not installed)"
        return 0
      fi
      _exe=$PWSHEXE
      ;;
    powershell32*)
      if [ -z "$PS32EXE" ]; then
        caseline "$_n: -> not run (no 32-bit Windows PowerShell under SysWOW64)"
        return 0
      fi
      _exe=$PS32EXE
      ;;
    *) _exe=$PSEXE ;;
  esac
  case $_host in
    *+clm) _cmd=$CLM_PREFIX$_pre$CASE_CMD ;;
    *) _cmd=$_pre$CASE_CMD ;;
  esac
  if [ "$_mode" = asis ]; then
    set -- env -u CLAUDE_PLUGIN_ROOT "MSYS_NO_PATHCONV=1"
  else
    if ! layout_set "$_mode" "$_host"; then
      caseline "$_n: -> not run (unknown layout $_mode)"
      return 0
    fi
    set -- env -i "MSYS_NO_PATHCONV=1"
    for _nm in SYSTEMROOT WINDIR SystemDrive ComSpec PATHEXT TEMP TMP HOMEDRIVE HOMEPATH APPDATA ProgramData BBJ_HOME; do
      _nv=$(winenv "$_nm")
      [ -z "$_nv" ] || set -- "$@" "$_nm=$_nv"
    done
    set -- "$@" "ProgramFiles=$LPF" "ProgramFiles(x86)=$LPF86" "PATH=$LPATH"
    [ -z "$LLAD" ] || set -- "$@" "LOCALAPPDATA=$LLAD"
    [ -z "$LW64" ] || set -- "$@" "ProgramW6432=$LW64"
    [ -z "$LUP" ] || set -- "$@" "USERPROFILE=$LUP"
  fi
  [ -z "$CASE_ROOTW" ] || set -- "$@" "CLAUDE_PLUGIN_ROOT=$CASE_ROOTW"
  cat < "$_pf" | "$@" "$_exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$_cmd" \
    > "$OUT/cases/$_n.out" 2> "$OUT/cases/$_n.err"
  _rc=$?
  tr -d '\r' < "$OUT/cases/$_n.err" > "$OUT/cases/$_n.err.txt"
  _ob=$(wc -c < "$OUT/cases/$_n.out" | tr -d ' ')
  _el=$(awk 'END { print NR }' "$OUT/cases/$_n.err.txt")
  _first=$(head -n 1 "$OUT/cases/$_n.err.txt")
  _trail=$(grep -c ' $' "$OUT/cases/$_n.err.txt")
  _verdict=$(check_want "$(want_kind "$_n")" "$_rc" "$_ob" "$_el" "$_first" "$_trail")
  _shown=$(scrub "$_first" | cut -c1-160)
  caseline "$_n: rc=$_rc out_bytes=$_ob err_lines=$_el first=$_shown -> $_verdict"
}

# selftest: checks that need no Windows. The first failed check is printed on stderr.
selftest() {
  _fail() {
    echo "selftest: FAILED $1" >&2
    exit 1
  }
  _t=$(mktemp -d) || _fail mktemp
  trap 'rm -rf "$_t"' EXIT

  # extract_cmd
  _c=$(extract_cmd) || _fail extract_cmd
  case $_c in
    *'exit $LASTEXITCODE') ;;
    *) _fail "extract_cmd does not end with exit \$LASTEXITCODE" ;;
  esac
  case $_c in
    *'${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh'*) ;;
    *) _fail "extract_cmd lacks the plugin root placeholder" ;;
  esac
  case $_c in
    *'\"'*) _fail "a backslash sits directly before a double quote (MSVC quoting would differ)" ;;
  esac
  case $_c in
    *'"$env:CLAUDE_PLUGIN_ROOT/scripts/bbj-check.sh"'*) ;;
    *) _fail "extract_cmd does not take the root from CLAUDE_PLUGIN_ROOT (WR-04)" ;;
  esac
  if have_python3; then
    python3 -I -c 'import json, sys
d = json.load(open(sys.argv[1]))
sys.stdout.write(d["hooks"]["PostToolUse"][0]["hooks"][0]["commandWindows"])' "$HOOKS" > "$_t/py" || _fail "python3 json.load"
    printf '%s' "$_c" > "$_t/sh"
    cmp -s "$_t/py" "$_t/sh" || _fail "extract_cmd differs from python3 json.load"
  fi
  _h=$(printf '%s' "$_c" | sha256sum | awk '{ print $1 }')
  [ "$_h" = "$PIN_SHA" ] || _fail "sha256 of commandWindows ($_h) is not the launcher pin"
  _r=$(subst_root "$_c" 'C:/x y/plugins/bbj')
  case $_r in
    *'${CLAUDE_PLUGIN_ROOT}'*) _fail "subst_root left a placeholder" ;;
    *'"C:/x y/plugins/bbj/scripts/bbj-check.sh"'*) ;;
    *) _fail "subst_root did not set the root" ;;
  esac

  # drivepath
  [ "$(drivepath 'C:\Program Files\Git\bin')" = '/c/Program Files/Git/bin' ] || _fail drivepath

  # safe_out
  for _bad in /tmp/bbj-phase13-x "$REALHOME/.codex/x" "$BASE/../x" relative/path "$BASE/x/"; do
    (safe_out "$_bad") > /dev/null 2>&1
    [ "$?" = 2 ] || _fail "safe_out accepted $_bad"
  done
  mkdir -p "$BASE" || _fail "mkdir BASE"
  _ex=$BASE/selftest-existing.$$
  mkdir "$_ex" || _fail "mkdir existing"
  (safe_out "$_ex") > /dev/null 2>&1
  _rc=$?
  (safe_out "$_ex" keep) > /dev/null 2>&1
  _rck=$?
  rmdir "$_ex"
  [ "$_rc" = 2 ] || _fail "safe_out accepted an existing directory"
  [ "$_rck" = 0 ] || _fail "safe_out keep refused an existing directory"
  (safe_out "$BASE/selftest-missing.$$" keep) > /dev/null 2>&1
  [ "$?" = 2 ] || _fail "safe_out keep accepted a missing directory"
  [ ! -e "$BASE/selftest-missing.$$" ] || _fail "safe_out keep created a directory"

  # clean refuses a directory run did not mark
  mkdir "$_ex" || _fail "mkdir unmarked"
  sh "$0" clean "$_ex" > /dev/null 2>&1
  _rc=$?
  [ -d "$_ex" ] || _fail "clean removed an unmarked directory"
  rmdir "$_ex"
  [ "$_rc" = 2 ] || _fail "clean did not refuse an unmarked directory"

  # payload: valid JSON, codex_payload key order
  _long=$(payload 'C:\w\proj' 'C:\w\proj\bad.bbj' "$(printf '%s\n%s' '+print "a"   rem same line' "$(filler)")")
  [ "$(printf '%s' "$_long" | wc -c | tr -d ' ')" -gt 8192 ] || _fail "the long payload is not over 8192 bytes"
  [ "$(printf '%s' "$_long" | wc -l | tr -d ' ')" = 0 ] || _fail "the payload is not one physical line"
  if have_python3; then
    printf '%s' "$_long" | python3 -I -c 'import json, sys
pairs = json.loads(sys.stdin.read(), object_pairs_hook=lambda p: p)
keys = [k for k, v in pairs]
want = ["session_id", "turn_id", "transcript_path", "cwd", "hook_event_name", "model", "permission_mode", "tool_name", "tool_input", "tool_response", "tool_use_id"]
if keys != want:
    sys.exit("keys " + repr(keys))
d = dict(pairs)
if d["cwd"] != "C:\\w\\proj" or d["tool_name"] != "apply_patch":
    sys.exit("cwd or tool_name")
cmd = dict(d["tool_input"])["command"]
if not cmd.startswith("*** Begin Patch\n*** Add File: C:\\w\\proj\\bad.bbj\n+print \"a\"   rem same line\n+rem filler") or not cmd.endswith("*** End Patch"):
    sys.exit("patch text")' > /dev/null 2>&1 || _fail "payload is not the codex_payload shape"
  fi

  # scrub
  SCRUBMAP=$_t/map
  : > "$SCRUBMAP"
  scrub_add 'C:\Users\who\w' '<work>'
  scrub_add 'C:\Users\who' '<home>'
  scrub_add '' 'ignored'
  [ "$(scrub 'a C:\Users\who\w\x and C:\Users\who\y')" = 'a <work>\x and <home>\y' ] || _fail scrub

  # verdict rules
  [ "$(check_want clean 0 0 0 '')" = "as expected" ] || _fail "check_want clean"
  [ "$(check_want clean 0 5 0 '')" != "as expected" ] || _fail "check_want clean with output"
  [ "$(check_want bbjcpl 2 0 3 'bbjcpl reported 1 error(s) in x:')" = "as expected" ] || _fail "check_want bbjcpl"
  [ "$(check_want bbjcpl 1 0 0 '')" != "as expected" ] || _fail "check_want bbjcpl silent"
  [ "$(check_want notfound 2 0 3 'bbj-check: Git for Windows sh.exe not found, so x')" = "as expected" ] || _fail "check_want notfound"
  [ "$(check_want notfound_first 0 0 0 '')" != "as expected" ] || _fail "check_want notfound_first silent"
  [ "$(check_want notfound 2 0 3 'bbj-check: Git for Windows sh.exe not found, so x ' 3)" != "as expected" ] \
    || _fail "check_want notfound with trailing spaces"
  # the expectation table of the round 3 cases (13-REVIEW-FIX.md)
  for _k in othersh_none_bbj:notfound othersh_then_git_bad:bbjcpl usrbin_on_path_bad:bbjcpl \
    lad_unset_profile_bad:bbjcpl lad_unset_driveroot_bbj:notfound none_web_src:clean none_update_src:notfound \
    rootvar_unset_bad:bbjcpl dollar_root_bad:bbjcpl git_mingw_on_path_bad:bbjcpl w6432_bad:bbjcpl \
    wow64_w6432_bad:bbjcpl; do
    [ "$(want_kind "${_k%%:*}")" = "${_k#*:}" ] || _fail "want_kind ${_k%%:*}"
  done

  echo "selftest ok"
}

# do_run OUTDIR: the Windows run
do_run() {
  case $(uname -s 2> /dev/null) in
    MINGW* | MSYS*) ;;
    *) die2 "run needs Git Bash on Windows; this is not one" ;;
  esac
  command -v cygpath > /dev/null 2>&1 || die2 "cygpath not found; run needs Git Bash on Windows"
  MSYS_NO_PATHCONV=1
  export MSYS_NO_PATHCONV
  NATIVE_ENV=$(cmd.exe /c set 2> /dev/null | tr -d '\r')
  [ -n "$NATIVE_ENV" ] || die2 "cmd.exe /c set printed nothing"
  _sr=$(winenv SYSTEMROOT)
  [ -n "$_sr" ] || die2 "SYSTEMROOT is not set"
  SR_U=$(cygpath -u "$_sr")
  SYSP=$(drivepath "$_sr")/System32:$(drivepath "$_sr"):$(drivepath "$_sr")/System32/WindowsPowerShell/v1.0
  PSEXE=$SR_U/System32/WindowsPowerShell/v1.0/powershell.exe
  [ -f "$PSEXE" ] || die2 "powershell.exe not found under SYSTEMROOT"
  PS32EXE=$SR_U/SysWOW64/WindowsPowerShell/v1.0/powershell.exe
  [ -f "$PS32EXE" ] || PS32EXE=
  _bw=$(winenv BBJ_HOME)
  [ -n "$_bw" ] || die2 "BBJ_HOME is not set"
  _bu=$(cygpath -u "$_bw")
  _cpl=
  for _d in "$_bu/bin" "$_bu"; do
    for _f in bbjcpl.exe bbjcplw.exe bbjcpl bbjcplw; do
      [ -n "$_cpl" ] || { [ -f "$_d/$_f" ] && _cpl=$_d/$_f; }
    done
  done
  [ -n "$_cpl" ] || die2 "BBJ_HOME holds no bbjcpl (looked in bin and in the home itself)"
  GITW=$(cygpath -w /)
  GITW=${GITW%\\}
  GIT_U=$(drivepath "$GITW")
  [ -f "$GIT_U/bin/sh.exe" ] || die2 "Git root $GITW holds no bin\\sh.exe"
  GITBIN_P=$(drivepath "$GITW")/bin
  GITCMD_P=$(drivepath "$GITW")/cmd
  GITUSR_P=$(drivepath "$GITW")/usr/bin
  GITMINGW_P=$(drivepath "$GITW")/mingw64/bin
  PWSHEXE=$(command -v pwsh.exe 2> /dev/null || command -v pwsh 2> /dev/null || true)
  PWSHDIR_P=
  [ -z "$PWSHEXE" ] || PWSHDIR_P=$(dirname "$PWSHEXE")
  ROOT_M=$(cygpath -m "$REPO/plugins/bbj")
  # the checkout root also goes into the text the hook falls back to when CLAUDE_PLUGIN_ROOT is unset
  # (rootvar_unset_bad), which PowerShell reads as a double-quoted string; dollar_root_bad makes its
  # own root with a dollar sign and a backtick
  case $ROOT_M in
    *'$'* | *'`'* | *'"'* | *"'"*) die2 "the plugin root holds a dollar sign, a backtick or a quote: $ROOT_M" ;;
  esac
  CMD_RAW=$(extract_cmd) || die2 "commandWindows could not be read from hooks.json"
  CMD=$(subst_root "$CMD_RAW" "$ROOT_M")
  # the value Codex gives CLAUDE_PLUGIN_ROOT: the plugin folder in its Windows form
  ROOT_W=$(cygpath -w "$REPO/plugins/bbj")
  CASE_CMD=$CMD
  CASE_ROOTW=$ROOT_W

  safe_out "$1" || exit 2
  OUT=$1
  OUTW=$(cygpath -w "$OUT")
  : > "$OUT/$MARKER"
  mkdir -p "$OUT/cases" "$OUT/lay/empty" "$OUT/lay/pf86" "$OUT/lay/lad/Programs" "$OUT/lay/othersh/bin" \
    "$OUT/lay/prof/AppData/Local/Programs" "$OUT/lay/drv/Programs" "$OUT/lay/w64" || exit 1
  # WR-01: an sh.exe outside any Git for Windows tree (no cygpath.exe in a usr\bin or bin folder of
  # its Git folder). It is a copy of Git's bin\sh.exe launcher; the hook must never start it, whatever
  # it would do there
  cp "$GIT_U/bin/sh.exe" "$OUT/lay/othersh/bin/sh.exe" || exit 1
  OTHERSH_P=$(drivepath "$OUTW")/lay/othersh/bin
  SCRUBMAP=$OUT/scrub.map
  : > "$SCRUBMAP"
  scrub_add "$OUT" "<work>"
  scrub_add "$OUTW" "<work>"
  scrub_add "$(cygpath -m "$OUT")" "<work>"
  scrub_add "$REPO" "<checkout>"
  scrub_add "$(cygpath -w "$REPO")" "<checkout>"
  scrub_add "$(cygpath -m "$REPO")" "<checkout>"
  scrub_add "$(winenv USERPROFILE)" "<home>"
  scrub_add "$(cygpath -m "$(winenv USERPROFILE)")" "<home>"
  scrub_add "$(cygpath -u "$(winenv USERPROFILE)")" "<home>"
  scrub_add "$REALHOME" "<home>"
  : > "$OUT/result.txt"

  # fixtures and payloads
  _bad='+print "a"   rem same line'
  _clean='+print "a"; rem ok'
  _na=proj-$(printf '\303\251')
  mkdir -p "$OUT/proj" "$OUT/$_na" || exit 1
  printf '%s\n' 'print "a"   rem same line' > "$OUT/proj/bad.bbj" || exit 1
  printf '%s\n' 'print "a"; rem ok' > "$OUT/proj/clean.bbj" || exit 1
  printf '%s\n' 'notes' > "$OUT/proj/notes.md" || exit 1
  printf '%s\n' 'print "a"   rem same line' > "$OUT/$_na/bad.bbj" || exit 1
  _pw=$(cygpath -w "$OUT/proj")
  _nw=$(cygpath -w "$OUT/$_na")
  _fill=$(filler)
  payload "$_pw" "$_pw\\bad.bbj" "$_bad" > "$OUT/p_bad.json"
  payload "$_pw" "$_pw\\clean.bbj" "$_clean" > "$OUT/p_clean.json"
  payload "$_nw" "$_nw\\bad.bbj" "$_bad" > "$OUT/p_nonascii.json"
  payload "$_pw" "$_pw\\bad.bbj" "$_bad
$_fill" > "$OUT/p_long.json"
  payload "$_pw" "$_pw\\notes.md" "+notes" > "$OUT/p_notes.json"
  payload "$_pw" "$_pw\\notes.md" "+notes
$_fill" > "$OUT/p_longnotes.json"
  # WR-03: a web file whose text names .src (and .bbj) but whose file name is no BBj file, and an
  # Update File of an upper-case .SRC file
  payload "$_pw" "$_pw\\page.html" '+<img src="a.png" onload="this.src = b.src">
+var u = img.src
+see prog.bbj and x.BBX' > "$OUT/p_web.json"
  payload_patch "$_pw" "$(printf '*** Begin Patch\n*** Update File: %s\n@@\n-rem a\n+rem b\n*** End Patch' "$_pw\\lib\\x.SRC")" > "$OUT/p_updsrc.json"
  [ "$(wc -c < "$OUT/p_long.json" | tr -d ' ')" -gt 8192 ] || exit 1
  # WR-04: a copy of the hook script under a plugin root that holds a dollar sign and a backtick, as a
  # Windows user name may (single quotes: both are literal here)
  DROOT=$OUT/'r$x`y'/plugins/bbj
  mkdir -p "$DROOT/scripts" || exit 1
  cp "$REPO/plugins/bbj/scripts/bbj-check.sh" "$DROOT/scripts/bbj-check.sh" || exit 1
  [ "$(wc -c < "$OUT/p_longnotes.json" | tr -d ' ')" -gt 8192 ] || exit 1

  # layouts: junctions to the Git root (removed first by clean)
  for _j in lay/pf86/Git lay/lad/Programs/Git lay/prof/AppData/Local/Programs/Git lay/drv/Programs/Git lay/w64/Git; do
    junction "$OUT/$_j" "$GITW" || { echo "launcher.sh: junction $_j failed; run clean" >&2; exit 1; }
  done

  # readings
  _sha=$(printf '%s' "$CMD_RAW" | sha256sum | awk '{ print $1 }')
  if [ "$_sha" = "$PIN_SHA" ]; then
    res cmd_sha256 "$_sha (equals the launcher pin)"
  else
    res cmd_sha256 "$_sha (DIFFERS from the launcher pin $PIN_SHA)"
  fi
  res cmd_chars "$(printf '%s' "$CMD_RAW" | wc -c | tr -d ' ')"
  res date "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  # native git.exe cannot read the MSYS form of REPO while MSYS_NO_PATHCONV is set (Windows run, H3)
  res checkout "$(git -C "$(cygpath -w "$REPO")" rev-parse --short HEAD 2> /dev/null || echo unknown)"
  res ps_version "$("$PSEXE" -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>&1 | tr -d '\r')"
  if [ -n "$PWSHEXE" ]; then
    res pwsh_version "$("$PWSHEXE" -NoLogo -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.ToString()' 2>&1 | tr -d '\r')"
  else
    res pwsh_version absent
  fi
  res git_version "$(git --version 2>&1 | tr -d '\r')"
  _clm=$("$PSEXE" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$CLM_PREFIX"'$ExecutionContext.SessionState.LanguageMode' 2>&1 | tr -d '\r' | head -n 1)
  if [ "$_clm" = ConstrainedLanguage ]; then
    res clm_check "$_clm -> as expected"
  else
    res clm_check "$_clm -> differs (want ConstrainedLanguage)"
  fi

  # the cases
  runcase default_bad powershell asis "$OUT/p_bad.json"
  runcase default_clean powershell asis "$OUT/p_clean.json"
  runcase default_nonascii powershell asis "$OUT/p_nonascii.json"
  runcase default_long powershell asis "$OUT/p_long.json"
  runcase pf86_bad powershell pf86 "$OUT/p_bad.json"
  # IN-03: only ProgramW6432 holds Git, in the 64-bit and in the 32-bit Windows PowerShell (where
  # ProgramFiles names the x86 folder)
  runcase w6432_bad powershell w6432 "$OUT/p_bad.json"
  runcase wow64_w6432_bad powershell32 w6432 "$OUT/p_bad.json"
  runcase localappdata_bad powershell lad "$OUT/p_bad.json"
  runcase sh_on_path_bad powershell shpath "$OUT/p_bad.json"
  runcase git_on_path_bad powershell gitpath "$OUT/p_bad.json"
  # IN-02: only Git's mingw64\bin (git.exe, no sh.exe) on PATH
  if [ -f "$GIT_U/mingw64/bin/git.exe" ]; then
    runcase git_mingw_on_path_bad powershell mingwpath "$OUT/p_bad.json"
  else
    caseline "git_mingw_on_path_bad: -> not run (this Git has no mingw64\\bin\\git.exe)"
  fi
  runcase usrbin_on_path_bad powershell usrpath "$OUT/p_bad.json"
  runcase othersh_none_bbj powershell othersh "$OUT/p_bad.json"
  runcase othersh_then_git_bad powershell othersh_git "$OUT/p_bad.json"
  # WR-02: LOCALAPPDATA unset, the per-user folder taken from USERPROFILE
  runcase lad_unset_profile_bad powershell ladunset_prof "$OUT/p_bad.json"
  # WR-02: LOCALAPPDATA and USERPROFILE unset, the PowerShell location on a subst drive whose root holds
  # Programs\Git: the old string probed \Programs\Git\bin\sh.exe there and ran it
  if subst_make; then
    runcase lad_unset_driveroot_bbj powershell ladunset_none "$OUT/p_bad.json" "Set-Location -LiteralPath '$SUBST_L:\\'; "
    subst_drop
  else
    caseline "lad_unset_driveroot_bbj: -> not run (no free drive letter for subst)"
  fi
  runcase none_bbj powershell none "$OUT/p_bad.json"
  runcase none_notes powershell none "$OUT/p_notes.json"
  runcase none_long_bbj powershell none "$OUT/p_long.json"
  runcase none_long_notes powershell none "$OUT/p_longnotes.json"
  runcase none_web_src powershell none "$OUT/p_web.json"
  runcase none_update_src powershell none "$OUT/p_updsrc.json"
  runcase clm_default_bad powershell+clm asis "$OUT/p_bad.json"
  # WR-04: CLAUDE_PLUGIN_ROOT unset, so the call falls back to the substituted text
  CASE_ROOTW=
  runcase rootvar_unset_bad powershell asis "$OUT/p_bad.json"
  # WR-04: the root with a dollar sign and a backtick, substituted into the text and set in
  # CLAUDE_PLUGIN_ROOT, as Codex does; the old string lost "$x" and the backtick and ran a missing script
  CASE_CMD=$(subst_root "$CMD_RAW" "$(cygpath -m "$DROOT")")
  CASE_ROOTW=$(cygpath -w "$DROOT")
  runcase dollar_root_bad powershell asis "$OUT/p_bad.json"
  CASE_CMD=$CMD
  CASE_ROOTW=$ROOT_W
  runcase clm_none_bbj powershell+clm none "$OUT/p_bad.json"
  runcase pwsh_default_bad pwsh asis "$OUT/p_bad.json"
  runcase pwsh_none_bbj pwsh none "$OUT/p_bad.json"

  _as=$(grep -c -e '-> as expected' "$OUT/result.txt")
  _df=$(grep -c -e '-> differs' "$OUT/result.txt")
  _nr=$(grep -c -e '-> not run' "$OUT/result.txt")
  printf '%s\n' "summary: $_as as expected, $_df differs, $_nr not run" >> "$OUT/result.txt"
  echo "launcher result block (paste it under launcher-block, then run: sh launcher.sh clean <OUTDIR>):"
  sed 's/^/        /' "$OUT/result.txt"
  return 0
}

# do_clean OUTDIR: junctions first (non-recursive rmdir), checks, then OUTDIR
do_clean() {
  safe_out "$1" keep || exit 2
  [ -f "$1/$MARKER" ] || refuse "$1" "not a directory this launcher created (no $MARKER)"
  case $(uname -s 2> /dev/null) in
    MINGW* | MSYS*) ;;
    *) die2 "clean needs Git Bash on Windows; this is not one" ;;
  esac
  command -v cygpath > /dev/null 2>&1 || die2 "cygpath not found"
  MSYS_NO_PATHCONV=1
  export MSYS_NO_PATHCONV
  _gw=$(cygpath -w /)
  _gw=${_gw%\\}
  _gu=$(drivepath "$_gw")
  [ -f "$_gu/bin/sh.exe" ] || die2 "Git root $_gw holds no bin\\sh.exe before the cleanup; nothing removed"
  OUT=$1
  subst_drop
  if cmd.exe /c subst 2> /dev/null | tr -d '\r' | grep -iF -- "$(cygpath -w "$1")" > /dev/null; then
    echo "launcher.sh: a subst drive still points into OUTDIR; nothing removed (subst X: /d it first)" >&2
    exit 1
  fi
  for _j in "$1/lay/pf86/Git" "$1/lay/lad/Programs/Git" "$1/lay/prof/AppData/Local/Programs/Git" "$1/lay/drv/Programs/Git" \
    "$1/lay/w64/Git"; do
    if [ -e "$_j" ]; then
      unjunction "$_j" || { echo "launcher.sh: could not remove the junction $_j; nothing else removed" >&2; exit 1; }
    fi
  done
  _left=$(cmd.exe /c dir /s /b /al "$(cygpath -w "$1")" 2> /dev/null | tr -d '\r')
  if [ -n "$_left" ]; then
    echo "launcher.sh: a link is left under OUTDIR; nothing removed:" >&2
    printf '%s\n' "$_left" >&2
    exit 1
  fi
  [ -f "$_gu/bin/sh.exe" ] || { echo "launcher.sh: Git's bin\\sh.exe is gone after the junctions were removed; nothing else removed" >&2; exit 1; }
  rm -rf "$1" || exit 1
  echo "cleaned $1"
  return 0
}

case ${1:-} in
  selftest)
    [ $# -eq 1 ] || usage
    selftest
    ;;
  run)
    [ $# -eq 2 ] || usage
    do_run "$2"
    ;;
  clean)
    [ $# -eq 2 ] || usage
    do_clean "$2"
    ;;
  *) usage ;;
esac
