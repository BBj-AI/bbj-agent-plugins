#!/bin/sh
# install-codex.sh -- Codex install script for the BBj docs server, the two BBj skills and the
# BBj check hook (plan 19-05, PLUG-04; decision D-15 of phase 19).
#
# Verified on Linux with Codex CLI 0.162.1 on 2026-10-12 (plan 06-05 release run: registered,
# hook approved in /hooks, a .bbj written through apply_patch got the compiler's feedback,
# skills found in ~/.agents/skills). Not yet run on Windows or macOS. The test suite runs it
# with a fake codex in a temp HOME.
#
# What it does, one factual line per step:
#   1. registers the read-only docs server as bbj-docs: "codex mcp add" when codex is on PATH,
#      else a managed block in config.toml; then approves the five docs tools by name, one
#      table [mcp_servers.bbj-docs.tools.NAME] with approval_mode = "approve" each, for
#      bbj_search, bbj_fetch_page, bbj_lookup, bbj_reserved_word and bbj_examples (they only
#      read). Nothing else of bbj-docs is approved, and no server-wide default is written: the
#      server may also list the hosted check tools bbj_check_syntax, bbj_format and bbj_denum,
#      which send your code to the server and keep Codex's normal prompt. The script also
#      writes [mcp_servers.bbj-docs.oauth] with client_id, callback_url and callback_port of the
#      pre-registered OAuth client of the hosted docs server (quick 261013-cpn), right after the
#      bbj-docs table body (inside the managed block when there is one); only for the default
#      docs url, any other --docs-url gets no OAuth table (review 07 WR-02). It never goes through
#      codex mcp add for this: the client-id option of that command starts the sign-in at once and
#      waits for a browser. An OAuth entry of your own for bbj-docs is left alone and named. An
#      existing table only gains the missing OAuth table and tool tables; config.toml.bbj-backup is
#      written once before the first change to an existing file. A docs tool you set to another
#      approval_mode keeps it and is named in the output. Upgrade: versions up to 398aac5 wrote
#      default_tools_approval_mode = "approve" into the bbj-docs table, which approved every
#      tool of the server; a rerun removes exactly that line and says so. Any other
#      default_tools_approval_mode is left alone and reported, and when it still approves
#      every tool (the same value in another spelling) the exit code is 3. Tool tables
#      without the bbj-docs table (Codex cannot load that) get the table added in a managed
#      block, without codex mcp add. When bbj-docs is already named in config.toml in a form
#      this script does not edit (single-quoted key, spaced or indented header, dotted key,
#      sub-table), or its tools are (a [mcp_servers.bbj-docs.tools] table, a quoted tool
#      header, a dotted tools key, an approval_mode written as anything but a bare key),
#      config.toml is left alone, the tables are printed and the exit code is 3.
#   1b. with --with-local (and on every later run once the block is there), registers the local
#      check server bbj-local, the bbj-ls of a running BBjServices 26.03 or later, in one managed
#      block of config.toml between the markers "# >>> bbj-agent-plugins bbj-local (managed) >>>"
#      and "# <<< bbj-agent-plugins bbj-local (managed) <<<": [mcp_servers.bbj-local] with
#      url = "http://127.0.0.1:5009/mcp" and one tool table with approval_mode = "approve" for
#      each of bbj_check_syntax, bbj_format and bbj_denum (plan 01-04, LOCAL-02). These tools run
#      on this machine and are approved by name only at that fixed url (D-12, D-17: the url does
#      not follow BBJ_LOCAL_MCP_URL, which moves only the hook and the probe); never through
#      "codex mcp add" (it cannot set approval_mode), never with default_tools_approval_mode,
#      required, enabled or startup_timeout_sec. It goes through the same pass as bbj-docs, so
#      the rules of step 1 apply: a rerun is byte-identical, missing tool tables and approval
#      keys are added inside the markers and nothing is removed. A run without the flag keeps a
#      managed block and refreshes it the same way (D-09); there is still no flag that removes
#      bbj-local alone (D-10; --remove, R below, removes its managed block together with everything
#      else this script wrote): after
#      "codex mcp remove bbj-local" the lone end marker stays in config.toml as a comment, is
#      tolerated and, with the flag, a fresh block follows it. A plain [mcp_servers.bbj-local]
#      table whose url is exactly the fixed url gains the three approvals; any other form of
#      bbj-local (another url, single-quoted key, dotted key, a sub-table without the table) is
#      left alone, the tables are printed and the exit code is 3 (D-12).
#      The probe (plan 01-06, LOCAL-03, LOCAL-04): without the flag, and with no bbj-local in
#      config.toml at all, one tools/list request goes to a bbj-ls on this machine (BBJ_LOCAL_MCP_URL,
#      else the fixed url; loopback http only, no proxy, no redirect), carries none of your code and
#      only prints a suggestion to rerun with --with-local; a managed or hand-registered bbj-local is
#      never probed. With the flag the same request runs first and bbj-local is registered whatever
#      the answer: one warning line says so when no bbj-ls answered, curl is missing or the url is
#      refused (Codex shows a registered server that is not running as failed). The probe never
#      writes a file and never changes the exit code.
#   2. copies the two skills to the skills directory (default ~/.agents/skills); a directory
#      that differs is left alone unless --force.
#   3. copies the shared check script to <codex home>/bbj/bbj-check.sh, a stable path outside
#      any plugin cache.
#   4. writes <codex home>/hooks.json with an apply_patch matcher, only when that file does not
#      exist; an existing hooks.json is never modified (exit 3 with the block to merge by hand).
#      With cygpath on PATH (Git for Windows) the file also carries commandWindows in the
#      PowerShell call form: & "<sh.exe>" "<bbj-check.sh>"; exit $LASTEXITCODE, the script path
#      through cygpath -w. Codex runs the field through PowerShell, where a command that starts with a
#      quoted string is a parse error (hook exit 1, no output); the call operator runs it and the
#      trailing exit keeps exit code 2 (plan 10-01, D-06 to D-08; Phase 9 W11). The sh.exe is the
#      --sh-exe value as given, else the launcher <Git root>\bin\sh.exe, the Git root being what
#      `cygpath -w /` prints. Not usr\bin\sh.exe: started from PowerShell it gets no Git PATH, so the
#      hook finds no cat, head or awk and does nothing (round 1 of the Windows reading). No cygpath
#      round trip touches a --sh-exe value, because /bin is a mount of /usr/bin and the path came back
#      as usr\bin\sh.exe. Existence is checked through the drive root (cygpath -u of X:/ plus the rest
#      of the path), not through the /bin mount. An install refuses (exit 2, before the first write)
#      when the sh.exe does not exist, / cannot be converted, a --sh-exe has no drive letter or names
#      usr\bin, or the Windows path holds $, a backtick, a double quote or a newline. --remove
#      resolves it the same way and never refuses (plan 10-15, D-27 to D-29).
#   5. prints the AGENTS.md snippet, the /hooks trust step, the sign-in step (codex mcp login
#      bbj-docs, once) and the known gaps.
#   R. --remove (phase 8, CODEX-06; D-01 to D-04) undoes what this script wrote, for a user who
#      switches to the Codex plugin route (codex plugin marketplace add, then codex plugin add):
#      afterwards one hook, one copy of the skills and one bbj-docs server remain. It never calls
#      codex and creates no directory; --docs-url, --skills-dir and --codex-home name the same
#      places and the same url as the install did. It removes, each only in the exact form this
#      script writes it:
#        - config.toml: the [mcp_servers.bbj-docs] table with its [mcp_servers.bbj-docs.oauth]
#          and tool tables, and the same for bbj-local, but only when its tables hold nothing this
#          script does not write, bbj-docs sits at the --docs-url in effect (a registration at
#          another url is also the documented Codex override of the plugin's server, so give the
#          same --docs-url to remove it), and bbj-local sits in its managed block. The managed
#          blocks go with their two marker lines and the one blank line this script put before the
#          begin marker; the forms of versions up to 398aac5 (url plus the server-wide
#          default_tools_approval_mode line) go too. Before the first change of config.toml,
#          config.toml.bbj-backup is written when it does not exist.
#        - the two skill directories, each only when diff -r finds it identical to the shipped copy
#        - <codex home>/bbj/bbj-check.sh, and its directory when that is empty then
#        - hooks.json, only when it is byte-identical to what step 4 writes
#      Never touched: config.toml.bbj-backup, the hooks.state, [marketplaces] and [plugins] tables
#      that Codex writes, the plugin cache, AGENTS.md, and config.toml itself. Whatever stays
#      because it differs is named, and the exit code is 3. A second run changes nothing.
#      Not atomic across objects: an interrupted run is finished by running it again.
#
# Options: --docs-url URL (default DEFAULT_DOCS_URL, the same value as the bbj plugin's
# docs_url default; plain http only to 127.0.0.1, localhost or [::1]), --skills-dir DIR,
# --codex-home DIR (default $CODEX_HOME or ~/.codex), --sh-exe PATH (the Windows path of the sh.exe in
# commandWindows, written as given, step 4; needs cygpath on PATH), --with-local (register bbj-local, step 1b),
# --force, --remove (undo what this script wrote, R), --help.
# Exit codes: 0 done, 2 usage error or refusal, 3 finished with something left to merge or
# decide by hand: bbj-docs or its tools named in config.toml in a form this script does not
# edit, bbj-local named in a form it does not edit or with another url than the fixed one, a
# default_tools_approval_mode that approves every tool, an existing hooks.json, a skill
# directory that differs. With --remove, exit 3 means something was left in place (named in the output)
# because it differs from what this script writes: a bbj-docs or bbj-local entry in another form or
# at another url, a skill directory that differs or is a symbolic link, a hooks.json that holds more
# than this script's hook, a check-script directory that holds other files.
#
# Exit 2 before the first write also covers --sh-exe without cygpath on PATH, and with cygpath an sh.exe
# that does not exist, a --sh-exe without a drive letter or in usr\bin, a root that cygpath cannot
# convert, or a Windows path that holds a dollar sign, a backtick, a double quote or a newline (plan
# 10-01, D-07; plan 10-15, D-27 to D-29): the message names the path as given and --sh-exe.
#
# Exit 2 before the first write means nothing was changed: the options are validated and every
# destination (skills directory, <codex home>/bbj, config.toml) is created or checked up front.
# A failure after a step has run still exits 2 and names the steps that already ran.
# With --remove, exit 2 (always before the first write) also covers: --remove together with
# --with-local or with --force (a skill directory that differs is the user's and is never deleted,
# so --force has nothing to do there), a Codex home that is not a directory (nothing to remove, and
# no directory is created), and a skills directory, check-script directory or Codex home that is not
# a writable directory.
#
# It never runs BBj and never calls a compiler; the hook it installs follows the same
# never-execute rule. POSIX sh plus awk, sed, grep, cp, mv, cmp, diff, mktemp.

DEFAULT_DOCS_URL=https://mcp.bbj-ai.com/mcp
MARK_BEGIN='# >>> bbj-agent-plugins (managed) >>>'
MARK_END='# <<< bbj-agent-plugins (managed) <<<'
# the five read-only docs tools of bbj-docs, approved by name; one list, also checked against
# the tool bullets of AGENTS-snippet.md by the test suite
DOCS_TOOLS='bbj_search bbj_fetch_page bbj_lookup bbj_reserved_word bbj_examples'
# the pre-registered OAuth client of the hosted docs server (quick 261013-cpn): its auth server
# accepts only this client and only a callback on port 47613. Codex needs both callback keys:
# the port alone makes Codex CLI 0.162.1 append a random path to a 127.0.0.1 redirect, which the
# auth server rejects, and the url alone does not fix the listener port. The test suite reads
# these three lines (tests/test_layout.py), one value each.
OAUTH_CLIENT_ID=oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t
OAUTH_CALLBACK_PORT=47613
OAUTH_CALLBACK_URL=http://localhost:47613/callback
# the local check server bbj-local (plan 01-04, LOCAL-02): the bbj-ls of a running BBjServices.
# Its three tools run on this machine and are approved by name only for this fixed loopback url
# (D-12); the registration never follows BBJ_LOCAL_MCP_URL (D-17)
LOCAL_URL=http://127.0.0.1:5009/mcp
LOCAL_MARK_BEGIN='# >>> bbj-agent-plugins bbj-local (managed) >>>'
LOCAL_MARK_END='# <<< bbj-agent-plugins bbj-local (managed) <<<'
LOCAL_TOOLS='bbj_check_syntax bbj_format bbj_denum'
# the tools/list probe of step 1b (plan 01-06, LOCAL-03, D-11): a static request that names no file,
# no code and no project; the _meta keys are the ones the hook's check sends
PROBE_BODY='{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientCapabilities":{}}}}'
TOOL_KEY='approval_mode = "approve"'
# the server-wide line that versions up to 398aac5 of this script wrote; it is only ever
# recognised and removed, never written again
OLD_KEY_LINE='default_tools_approval_mode = "approve"'
STATUS_LINE='Verified on Linux with Codex CLI 0.162.1; not yet run on Windows or macOS.'

say() {
  printf '%s\n' "$*"
}

wrote=
refuse() {
  printf 'install-codex: %s\n' "$*" >&2
  [ -z "$wrote" ] || printf 'install-codex: steps that had already run: %s\n' "$wrote" >&2
  exit 2
}

usage() {
  cat <<EOF
Usage: sh codex/install-codex.sh [--docs-url URL] [--skills-dir DIR] [--codex-home DIR] [--sh-exe PATH] [--with-local] [--force] [--remove]

  --docs-url URL     docs server URL (default $DEFAULT_DOCS_URL);
                     https anywhere, http only to 127.0.0.1, localhost or [::1]
  --skills-dir DIR   where the skills go (default \$HOME/.agents/skills)
  --codex-home DIR   Codex home (default \$CODEX_HOME, else \$HOME/.codex)
  --sh-exe PATH      the Windows path, with a drive letter, of the sh.exe that the Windows hook
                     command (commandWindows) runs, written as given, for a Git for Windows
                     installed elsewhere; default the launcher bin\sh.exe of the Git for Windows
                     this shell belongs to (the Windows path of /); only with cygpath on PATH
                     (Git for Windows), refused without it
  --with-local       register bbj-local, the bbj-ls of a running BBjServices 26.03 or later at
                     http://127.0.0.1:5009/mcp, and approve its three tools by name; a probe (one
                     tools/list request, no code sent) asks first, and with no answer bbj-local is
                     registered anyway with a warning. Without the flag, and with no bbj-local in
                     config.toml, the probe only suggests this option when a bbj-ls answers
  --force            replace a skill directory that differs from the shipped one
  --remove           undo what this script wrote (the bbj-docs and bbj-local entries of config.toml,
                     the two skills when identical to the shipped copy, the check script, hooks.json
                     when it holds only this hook), for a switch to the Codex plugin route; never
                     calls codex; give the same --docs-url, --skills-dir, --codex-home and
                     --sh-exe as the install. Whatever differs from what this script writes stays and is named
  --help             this text

Exit: 0 done, 2 refused (nothing written unless the message names the steps that ran; with
        --remove: combined with --with-local or --force, a Codex home that is not a directory,
        a destination that is not writable; --sh-exe without cygpath; on Windows an sh.exe that
        does not exist, a --sh-exe without a drive letter or in usr\bin, a path cygpath cannot
        convert, or one that holds \$, a backtick or a double quote, which an install refuses
        and --remove never does),
      3 done except something to merge or decide by hand: bbj-docs or its tools named in
        config.toml in a form this script does not edit, a default_tools_approval_mode that
        approves every tool, bbj-local named in a form this script does not edit or with
        another url than http://127.0.0.1:5009/mcp, an existing hooks.json, a skill directory
        that differs; with --remove: something left in place because it differs from what this
        script writes.
EOF
}

say "$STATUS_LINE"

docs_url=$DEFAULT_DOCS_URL
skills_dir=
codex_home=
force=0
with_local=0
remove=0
sh_exe=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --docs-url) [ "$#" -ge 2 ] || refuse "--docs-url needs a value"; docs_url=$2; shift 2 ;;
    --skills-dir) [ "$#" -ge 2 ] || refuse "--skills-dir needs a value"; skills_dir=$2; shift 2 ;;
    --codex-home) [ "$#" -ge 2 ] || refuse "--codex-home needs a value"; codex_home=$2; shift 2 ;;
    --sh-exe) [ "$#" -ge 2 ] && [ -n "$2" ] || refuse "--sh-exe needs a value"; sh_exe=$2; shift 2 ;;
    --with-local) with_local=1; shift ;;
    --force) force=1; shift ;;
    --remove) remove=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) refuse "unknown option: $1 (see --help)" ;;
  esac
done

# --remove contradicts two options (D-01, D-03); refused before any filesystem access, so nothing is written.
# --force would replace a skill directory that differs, and --remove never deletes one: it is the user's
if [ "$remove" = 1 ] && [ "$with_local" = 1 ]; then
  refuse "--remove and --with-local cannot be combined"
fi
if [ "$remove" = 1 ] && [ "$force" = 1 ]; then
  refuse "--remove does not take --force: a skill directory that differs is yours; copy out what you want to keep and delete it by hand"
fi

# the docs URL goes into config.toml and into one codex call: no whitespace, quote, backslash,
# apostrophe, userinfo or control character; https anywhere, plain http only to loopback
case "$docs_url" in
  *[![:print:]]*|*[[:space:]]*|*'"'*|*'\'*|*"'"*|*@*) refuse "--docs-url holds a character that is not allowed" ;;
esac
case "$docs_url" in
  https://?*) ;;
  http://127.0.0.1|http://127.0.0.1[:/]*) ;;
  http://localhost|http://localhost[:/]*) ;;
  'http://[::1]'|'http://[::1]'[:/]*) ;;
  *) refuse "--docs-url must be https://..., or http:// to 127.0.0.1, localhost or [::1] (no clear text over the network)" ;;
esac

if [ -z "$skills_dir" ]; then
  [ -n "${HOME:-}" ] || refuse "HOME is not set; give --skills-dir"
  skills_dir=$HOME/.agents/skills
fi
if [ -z "$codex_home" ]; then
  if [ -n "${CODEX_HOME:-}" ]; then
    codex_home=$CODEX_HOME
  else
    [ -n "${HOME:-}" ] || refuse "HOME is not set; give --codex-home"
    codex_home=$HOME/.codex
  fi
fi
nl='
'
case "$skills_dir$codex_home" in
  *"$nl"*) refuse "a directory name holds a newline" ;;
esac
# the codex home ends up inside the hook command that Codex runs through a shell on every
# apply_patch (hooks.json): no character that a double-quoted shell word would expand or end
case "$codex_home" in
  *'$'*|*'`'*|*'"'*|*'\'*|*"'"*) refuse "--codex-home holds a character that is not allowed in a hook command (one of \$ \` \" \\ ')" ;;
esac

# drive_posix WINPATH: the POSIX path of a Windows path with a drive letter, built from the drive root
# (cygpath -u of X:/, trailing slashes removed) followed by the rest of WINPATH with its backslashes turned
# into slashes; prints nothing for any other value, or when cygpath prints nothing. A path under the Git
# root converted whole by cygpath -u comes back under /bin, which Git for Windows mounts on /usr/bin, so the
# existence check would see usr\bin\sh.exe and not the launcher (plan 10-15, D-28; round 1 note 1).
drive_posix() {
  case "$1" in
    [A-Za-z]:[\\/]*) ;;
    *) return 0 ;;
  esac
  _dp_rest=${1#?:}
  _dp_drive=${1%"$_dp_rest"}
  _dp_root=$(cygpath -u "$_dp_drive/" 2> /dev/null)
  [ -n "$_dp_root" ] || return 0
  while :; do
    case "$_dp_root" in
      */) _dp_root=${_dp_root%/} ;;
      *) break ;;
    esac
  done
  printf '%s%s\n' "$_dp_root" "$(printf '%s' "$_dp_rest" | tr '\\' '/')"
}

# the sh.exe of the Windows hook command (plan 10-01, D-07, D-08; plan 10-15, D-27, D-28), resolved before the
# first write: with cygpath on PATH (Git for Windows) the hook command names the Windows path of an sh.exe,
# the one given with --sh-exe or else the launcher <Git root>\bin\sh.exe, where the Git root is what
# `cygpath -w /` prints. Codex runs commandWindows from PowerShell: usr\bin\sh.exe started that way gets the
# plain Windows PATH, so the hook finds no cat, head or awk and exits 0, while the launcher bin\sh.exe puts
# Git's usr\bin on PATH first (plan 10-15, D-27; round 1, notes 1 and 2). An install refuses when that sh.exe
# is missing, cannot be converted, or holds a character PowerShell would expand or end its quoted path on,
# rather than write a hook that cannot start. --remove resolves it the same way (to render the same bytes)
# but never refuses.
w_sh=
sh_why=
if command -v cygpath > /dev/null 2>&1; then
  if [ -n "$sh_exe" ]; then
    # the value is written as given and no cygpath output reaches w_sh: cygpath -u of a path under the Git
    # root lands under /bin, a mount of /usr/bin, and cygpath -w then returned usr\bin\sh.exe (plan 10-15,
    # D-28; round 1 note 1). Reasons, first one wins: no drive letter, a character the PowerShell command
    # cannot carry, an sh.exe in usr\bin (D-29), a file that does not exist.
    w_sh=$sh_exe
    case "$sh_exe" in
      [A-Za-z]:[\\/]*) ;;
      *) sh_why="--sh-exe takes the Windows path of sh.exe with a drive letter, written as given (C:\\... or C:/...); $sh_exe has none" ;;
    esac
    if [ -z "$sh_why" ]; then
      case "$sh_exe" in
        *'$'*|*'`'*|*'"'*|*"$nl"*) sh_why="the --sh-exe value, $sh_exe, holds a character that is not allowed in the hook command (one of \$ \` \" or a newline)" ;;
      esac
    fi
    if [ -z "$sh_why" ]; then
      sh_lc=$(printf '%s' "$sh_exe" | tr '[:upper:]\\' '[:lower:]/')
      case "$sh_lc" in
        */usr/bin/sh.exe|*/usr/bin/sh) sh_why="the sh.exe in usr\\bin, $sh_exe, started by Codex from PowerShell finds no cat, head or awk and the hook does nothing; name the launcher bin\\sh.exe of that Git instead" ;;
      esac
    fi
    if [ -z "$sh_why" ]; then
      sh_posix=$(drive_posix "$sh_exe")
      if [ -z "$sh_posix" ] || { [ ! -f "$sh_posix" ] && [ ! -f "$sh_posix.exe" ]; }; then
        sh_why="no sh.exe at $sh_exe"
      fi
    fi
  else
    w_root=$(cygpath -w / 2> /dev/null)
    if [ -z "$w_root" ]; then
      sh_why="cygpath cannot convert / (the root of this Git for Windows) to a Windows path"
    else
      case "$w_root" in
        *[\\/]) w_root=${w_root%?} ;;
      esac
      w_sh=$w_root'\bin\sh.exe'
      sh_posix=$(drive_posix "$w_sh")
      if [ -z "$sh_posix" ] || { [ ! -f "$sh_posix" ] && [ ! -f "$sh_posix.exe" ]; }; then
        sh_why="no sh.exe at $w_sh"
      fi
    fi
  fi
  if [ -z "$sh_why" ]; then
    w_script_early=$(cygpath -w "$codex_home/bbj/bbj-check.sh" 2> /dev/null)
    if [ -z "$w_script_early" ]; then
      sh_why="cygpath cannot convert $codex_home/bbj/bbj-check.sh to a Windows path"
    else
      case "$w_sh" in
        *'$'*|*'`'*|*'"'*|*"$nl"*) sh_why="the Windows path of sh.exe, $w_sh, holds a character that is not allowed in the hook command (one of \$ \` \" or a newline)" ;;
      esac
    fi
  fi
  if [ -n "$sh_why" ]; then
    w_sh=
    [ "$remove" = 1 ] || refuse "$sh_why; pass --sh-exe PATH with the sh.exe of your Git for Windows, for example C:\\Program Files\\Git\\bin\\sh.exe"
  fi
elif [ -n "$sh_exe" ] && [ "$remove" != 1 ]; then
  refuse "--sh-exe needs cygpath (Git for Windows) on PATH, and cygpath was not found; without it no Windows hook command is written and the option would be used nowhere"
fi

# the checkout this script belongs to
here=$(cd "$(dirname "$0")" && pwd) || refuse "cannot locate this script"
repo=$(cd "$here/.." && pwd) || refuse "cannot locate the repository"
src_script=$repo/plugins/bbj/scripts/bbj-check.sh
src_skills=$repo/plugins/bbj/skills
snippet=$here/AGENTS-snippet.md
for f in "$src_script" "$snippet" "$src_skills/bbj-programming/SKILL.md" "$src_skills/bbj-web-programming/SKILL.md"; do
  [ -f "$f" ] || refuse "missing $f (run this script from a checkout of bbj-agent-plugins)"
done

pending=0
if [ "$remove" = 1 ]; then
  # --remove (D-01) creates no directory: a Codex home that does not exist holds nothing to remove
  [ -d "$codex_home" ] || refuse "$codex_home is not a directory; nothing to remove"
else
  mkdir -p "$codex_home" || refuse "cannot create $codex_home"
fi
codex_home=$(cd "$codex_home" && pwd) || refuse "cannot enter $codex_home"
case "$codex_home" in
  *'$'*|*'`'*|*'"'*|*'\'*|*"'"*) refuse "$codex_home holds a character that is not allowed in a hook command (one of \$ \` \" \\ ')" ;;
esac
config=$codex_home/config.toml

# pre-flight (WR-02): create or check every destination before the first write, so a refusal
# here changes nothing in config.toml, hooks.json or the skills
script_dst=$codex_home/bbj/bbj-check.sh
script_dir=$(dirname "$script_dst")
if [ "$remove" = 1 ]; then
  # what an install would have written must be writable when it exists; nothing is created
  for d in "$codex_home" "$script_dir" "$skills_dir"; do
    [ ! -e "$d" ] || { [ -d "$d" ] && [ -w "$d" ]; } || refuse "$d is not a writable directory"
  done
else
  mkdir -p "$skills_dir" || refuse "cannot create $skills_dir"
  mkdir -p "$script_dir" || refuse "cannot create $script_dir"
  for d in "$codex_home" "$script_dir" "$skills_dir"; do
    [ -d "$d" ] && [ -w "$d" ] || refuse "$d is not a writable directory"
  done
fi
[ ! -e "$config" ] || [ -w "$config" ] || refuse "$config is not writable"
# --remove only unlinks the check script, which needs write permission on its directory (checked above), not on the file
[ "$remove" = 1 ] || [ ! -e "$script_dst" ] || [ -w "$script_dst" ] || refuse "$script_dst is not writable"

# the hooks.json block: one renderer for step 4 and for --remove (D-04), so the cmp of --remove compares
# against the exact bytes the install writes
# json_str VALUE: VALUE as the body of a JSON string
json_str() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}
hook_cmd="sh \"$script_dst\""
hook_cmd_win=$hook_cmd
if [ -n "$w_sh" ]; then
  w_script=$(cygpath -w "$script_dst" 2> /dev/null)
  if [ -n "$w_script" ]; then
    # under Codex's PowerShell launcher a command that starts with a quoted string is a parse error;
    # the call operator runs it, and the trailing exit keeps exit code 2, which a -Command wrapper
    # would rewrite to 1 (plan 10-01, D-06; Phase 9 W11)
    hook_cmd_win="& \"$w_sh\" \"$w_script\"; exit \$LASTEXITCODE"
  elif [ "$remove" != 1 ]; then
    refuse "cygpath cannot convert $script_dst to a Windows path"
  fi
fi
hooks=$codex_home/hooks.json
# render_hooks: the hooks.json this script writes, on stdout
render_hooks() {
  printf '{\n  "hooks": {\n    "PostToolUse": [\n      {\n        "matcher": "apply_patch|Edit|Write",\n        "hooks": [\n          {\n            "type": "command",\n            "command": "%s",\n            "commandWindows": "%s",\n            "timeout": 30\n          }\n        ]\n      }\n    ]\n  }\n}\n' \
    "$(json_str "$hook_cmd")" "$(json_str "$hook_cmd_win")"
}

# ---- 1. the docs server: registration and the per-tool approval ----
# analyze: one pass over config.toml (or nothing when it does not exist) for the server the
# srv_* globals name (SRV below; it reaches awk only as an -v value); prints
#   main=1|0     the [mcp_servers.SRV] table is there (plain or quoted key, column 0)
#   mention=1|0  config.toml defines SRV in a form this script does not edit (single-quoted key,
#                indented or spaced header, dotted key, inline table, another sub-table); our own
#                [mcp_servers.SRV.tools.NAME] headers do not count, and neither does the name inside a
#                path or a value (a [projects."/src/bbj-local"] table is not a server, WR-02)
#   tfor=1|0     SRV tools are named in a form this script does not edit: a [..SRV.tools]
#                table, a quoted or indented tool header, a dotted key, a tools key in the main
#                table, an approval_mode written other than as a bare key in a tool table,
#                or a tool table twice (only acted on when main=1)
#   dstate=      none | ours (exactly srv_old_key) | approve (default_tools_approval_mode set to
#                approve in another spelling) | other:VALUE, from the main table
#   managed=1|0  a line equals the begin marker srv_begin (a lone end marker is a comment: 0)
#   url=VALUE    the url key of the main table (last one), "" when there is none
#   anytool=N    how many [mcp_servers.SRV.tools.NAME] tables there are
#   oauth=       missing | ours | other: the [mcp_servers.SRV.oauth] table is absent, is exactly one
#                table with the three lines of the pre-registered client (srv_oauth_*), or is anything
#                else (own values, extra keys, twice, quoted or spaced header, an inline or dotted
#                oauth key); quick 261013-cpn
#   oauth.client_id=  the client_id value of that table, "" when there is none
#   tool.NAME=   missing | nokey | approve | other:VALUE, for each tool of srv_tools
#   inblock=1|0  the main table header lies between a srv_begin line and the next srv_end line (--remove)
#   closed=1|0   a srv_begin line is followed by a srv_end line (--remove)
#   extra=1|0    a line of the server's main, oauth or tool tables is not one this script writes (a comment,
#                a key other than url, the srv_old_key line, approval_mode and the three OAuth lines), or,
#                between srv_begin and srv_end, a non-blank line lies outside those tables (--remove).
#                A comment outside a managed block that is followed (after blank lines) by a header of another
#                table, a managed-block marker or the end of the file leads into what follows, as in the
#                install pass (flush_main), and is not table content (WR-04)
#   extra_line=  the line number of the first line that set extra, 0 when extra is 0 (--remove message)
analyze() {
  src=$config
  [ -f "$src" ] || src=/dev/null
  awk -v srv="$srv" -v tools="$srv_tools" -v sq="'" -v old_key="$srv_old_key" -v begin="$srv_begin" -v mend="$srv_end" \
    -v oid="$srv_oauth_id" -v ourl="$srv_oauth_url" -v oport="$srv_oauth_port" '
    function val(l) {
      sub(/^[^=]*=/, "", l)
      sub(/[ \t]*#.*$/, "", l)
      gsub(/^[ \t]+|[ \t\r]+$/, "", l)
      if (l ~ /^".*"$/ || l ~ ("^" sq ".*" sq "$")) l = substr(l, 2, length(l) - 2)
      return l
    }
    function flag(ln) {
      extra = 1
      if (!extra_line) extra_line = ln
    }
    BEGIN {
      n = split(tools, tl, " ")
      for (i = 1; i <= n; i++) st[tl[i]] = "missing"
      dstate = "none"
      tools_re = "^[ \t]*[\"" sq "]?tools[\"" sq "]?[ \t]*[.=]"
      key = "(\"" srv "\"|" srv ")"
      main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
      tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
      tool_pre = "^\\[mcp_servers\\." key "\\.tools\\."
      oauth_re = "^\\[mcp_servers\\." key "\\.oauth\\][ \t]*(#.*)?$"
      okey_re = "^[ \t]*[\"" sq "]?oauth[\"" sq "]?[ \t]*[.=]"
      want_id = "client_id = \"" oid "\""
      want_url = "callback_url = \"" ourl "\""
      want_port = "callback_port = " oport
      # WR-02: only a definition of the server counts as a mention, never the name inside a path or a value
      # (a [projects."/src/bbj-local"] trust table is not a server): a header whose key under mcp_servers is
      # exactly SRV (any spelling of the quotes and spaces); under [mcp_servers] itself a key that starts
      # with SRV; at the top level or under [mcp_servers] a dotted key that starts with mcp_servers
      q = "[\"" sq "]?"
      def_hdr_re = "^[ \t]*\\[\\[?[ \t]*" q "mcp_servers" q "[ \t]*\\.[ \t]*" q srv q "[ \t]*(\\.|\\])"
      all_hdr_re = "^[ \t]*\\[[ \t]*" q "mcp_servers" q "[ \t]*\\][ \t]*(#.*)?$"
      all_key_re = "^[ \t]*" q srv q "[ \t]*[.=]"
      dotted_re = "^[ \t]*" q "mcp_servers" q "[ \t]*[.=]"
      mk_re = "^# (>>>|<<<) bbj-agent-plugins"
    }
    {
      line = $0
      sub(/\r$/, "", line)
      isbegin = 0
      if (line == begin) {
        managed = 1
        inb = 1
        xs = ""
        etail = 0
        isbegin = 1
      }
      if (line ~ /^[ \t]*\[/) {
        sect = "other"
        name = ""
        if (line ~ main_re) {
          sect = "main"
          main = 1
          if (inb) inblock = 1
        } else if (line ~ tool_re) {
          sect = "tool"
          name = line
          sub(tool_pre, "", name)
          sub(/\].*$/, "", name)
          anytool++
          if (name in st) {
            if (st[name] != "missing") tfor = 1
            st[name] = "nokey"
          }
        } else if (line ~ oauth_re) {
          sect = "oauth"
          mention = 1
          oauth_n++
        } else if (line ~ def_hdr_re) {
          mention = 1
          if (line ~ /tools/) tfor = 1
          if (line ~ /oauth/) oauth_odd = 1
        } else if (line ~ all_hdr_re) {
          sect = "servers"
        }
      } else if (line !~ /^[ \t]*#/) {
        if (index(line, srv) > 0 && ((line ~ all_key_re && sect == "servers") \
            || (line ~ dotted_re && (sect == "" || sect == "servers")))) {
          mention = 1
          if (line ~ /tools/) tfor = 1
          if (line ~ /oauth/) oauth_odd = 1
        }
        if (sect == "main") {
          if (line ~ /^[ \t]*default_tools_approval_mode[ \t]*=/) {
            v = val(line)
            if (old_key != "" && line == old_key) dstate = "ours"
            else dstate = (v == "approve") ? "approve" : "other:" v
          }
          if (line ~ tools_re) tfor = 1
          if (line ~ okey_re) oauth_odd = 1
          if (line ~ /^[ \t]*url[ \t]*=/) url = val(line)
        } else if (sect == "tool" && (name in st)) {
          if (line ~ /^[ \t]*approval_mode[ \t]*=/) {
            v = val(line)
            st[name] = (v == "approve") ? "approve" : "other:" v
          } else if (line ~ /approval_mode/) {
            tfor = 1
          }
        } else if (sect == "oauth" && line !~ /^[ \t]*$/) {
          t = line
          sub(/[ \t]+$/, "", t)
          if (t == want_id) { if (o_id) oauth_extra = 1; o_id = 1 }
          else if (t == want_url) { if (o_url) oauth_extra = 1; o_url = 1 }
          else if (t == want_port) { if (o_port) oauth_extra = 1; o_port = 1 }
          else oauth_extra = 1
          if (line ~ /^[ \t]*client_id[ \t]*=/) ocid = val(line)
        }
      }
      # --remove (plan 08-03): closed, extra and inblock describe the tables of the server for the removal
      # decision; the install path ignores them. xs is the table the current line belongs to, as sect,
      # but reset by the begin marker; etail is set after the end marker of a complete block
      if (isbegin) {
        # the marker line itself; a comment before it leads into the block
        pc = 0
      } else if (inb && line == mend) {
        closed = 1
        inb = 0
        etail = 1
      } else if (line ~ /^[ \t]*\[/) {
        # a comment held since the last table line leads into this header unless the header is a table of
        # this same server, which makes the comment part of that configuration (WR-04)
        if (pc && (sect == "main" || sect == "tool" || sect == "oauth")) flag(pc)
        pc = 0
        xs = sect
        etail = 0
        if (inb && xs != "main" && xs != "tool" && xs != "oauth") flag(NR)
      } else if (line !~ /^[ \t]*$/) {
        if (line ~ mk_re && !inb) {
          # a managed-block marker of either server ends a table and is not table content
          pc = 0
        } else if (etail) {
          if (line !~ /^[ \t]*#/) flag(NR)
        } else if (!inb && line ~ /^[ \t]*#/ && (xs == "main" || xs == "tool" || xs == "oauth")) {
          # held until the next line says whether it belongs to the table or leads into what follows
          if (!pc) pc = NR
        } else {
          if (pc) { flag(pc); pc = 0 }
          if (xs == "main") {
            if (!(line ~ /^[ \t]*url[ \t]*=/ || (old_key != "" && line == old_key))) flag(NR)
          } else if (xs == "tool") {
            if (line !~ /^[ \t]*approval_mode[ \t]*=/) flag(NR)
          } else if (xs == "oauth") {
            t2 = line
            sub(/[ \t]+$/, "", t2)
            if (t2 != want_id && t2 != want_url && t2 != want_port) flag(NR)
          } else if (inb) {
            flag(NR)
          }
        }
      }
    }
    END {
      print "main=" (main ? 1 : 0)
      print "mention=" (mention ? 1 : 0)
      print "managed=" (managed ? 1 : 0)
      print "url=" url
      print "tfor=" (tfor ? 1 : 0)
      print "dstate=" dstate
      print "anytool=" anytool + 0
      ostate = "missing"
      if (oauth_n > 0 || oauth_odd) {
        ostate = (oauth_n == 1 && !oauth_odd && !oauth_extra && o_id && o_url && o_port) ? "ours" : "other"
      }
      print "oauth=" ostate
      print "oauth.client_id=" ocid
      print "inblock=" (inblock ? 1 : 0)
      print "extra=" (extra ? 1 : 0)
      print "extra_line=" extra_line + 0
      print "closed=" (closed ? 1 : 0)
      for (i = 1; i <= n; i++) print "tool." tl[i] "=" st[tl[i]]
    }' "$src"
}
analysis=
refresh() {
  analysis=$(analyze)
}
# an KEY: the value of one analysis line
an() {
  printf '%s\n' "$analysis" | sed -n "s/^$1=//p" | head -n 1
}
# config_cr: a carriage return when the first line of config.toml ends in one (a CRLF file), else nothing. The
# lines this script inserts follow it, so a CRLF file stays CRLF (IN-02). Command substitution only drops
# newlines, so the carriage return survives.
config_cr() {
  if [ -f "$config" ] && [ "$(awk 'NR == 1 { print ($0 ~ /\r$/) ? 1 : 0; exit }' "$config")" = 1 ]; then
    printf '\r'
  fi
}
# tools_in_state STATE: the srv_tools in that state, space separated
tools_in_state() {
  _out=
  for _t in $srv_tools; do
    [ "$(an "tool.$_t")" = "$1" ] && _out="$_out $_t"
  done
  printf '%s' "${_out# }"
}
# print_tools: the tool tables to put into config.toml by hand
print_tools() {
  for _t in $srv_tools; do
    printf '\n[mcp_servers.%s.tools.%s]\n%s\n' "$srv" "$_t" "$TOOL_KEY"
  done
}
# print_oauth: the OAuth client table to put into config.toml by hand (nothing for a server
# without a pre-registered client: bbj-local, quick 261013-cpn)
print_oauth() {
  [ -n "$srv_oauth_id" ] || return 0
  printf '\n[mcp_servers.%s.oauth]\nclient_id = "%s"\ncallback_url = "%s"\ncallback_port = %s\n' \
    "$srv" "$srv_oauth_id" "$srv_oauth_url" "$srv_oauth_port"
}
# print_block URL: the whole server entry to put into config.toml by hand
print_block() {
  printf '%s\n' "[mcp_servers.$srv]" "url = \"$1\""
  print_oauth
  print_tools
}

# state: the facts the decisions below rest on, recomputed after every change to config.toml
state() {
  foreign=0
  tools_foreign=0
  if [ "$(an main)" = 0 ]; then
    [ "$(an mention)" = 1 ] && foreign=1
  else
    [ "$(an tfor)" = 1 ] && tools_foreign=1
    # D-12: a server with a fixed url is edited only at exactly that url; its tools are never approved
    # on another one, so any other url is a form this script does not edit
    if [ "$srv_fixed_url" = 1 ] && [ "$(an url)" != "$srv_url" ]; then
      foreign=1
      tools_foreign=0
    fi
  fi
  miss=$(tools_in_state missing)
  nokey=$(tools_in_state nokey)
  dstate=$(an dstate)
  # quick 261013-cpn: the pre-registered OAuth client is added only when the table is missing
  oauth_state=$(an oauth)
  oauth_miss=0
  if [ -n "$srv_oauth_id" ] && [ "$oauth_state" = missing ]; then oauth_miss=1; fi
}

# server parameters (POSIX sh has no local, so every server pass sets the same globals and
# sync_server reads only these): srv is the server name; srv_tools its tools to approve by name;
# srv_begin and srv_end the managed-block markers; srv_url the url it is registered with;
# srv_old_key a legacy server-wide line to drop ("" for none); srv_codex_add 1 when a fresh
# registration goes through "codex mcp add"; srv_label, srv_untouched and srv_approved_note the
# words of the messages (LOCAL-01); srv_fixed_url 1 when the url is part of the identity of the
# server and tools are approved only at exactly that url (bbj-local, D-12), 0 when the user's own
# url is kept (bbj-docs); srv_oauth_id, srv_oauth_url and srv_oauth_port the pre-registered OAuth
# client written as [mcp_servers.SRV.oauth] ("" for none, quick 261013-cpn)
use_docs() {
  srv=bbj-docs
  srv_tools=$DOCS_TOOLS
  srv_begin=$MARK_BEGIN
  srv_end=$MARK_END
  srv_url=$docs_url
  srv_old_key=$OLD_KEY_LINE
  srv_codex_add=1
  srv_fixed_url=0
  # the pre-registered client belongs to the hosted server only: for any other --docs-url an
  # explicit client_id would override that server's own registration (review 07 WR-02)
  if [ "$docs_url" = "$DEFAULT_DOCS_URL" ]; then
    srv_oauth_id=$OAUTH_CLIENT_ID
    srv_oauth_url=$OAUTH_CALLBACK_URL
    srv_oauth_port=$OAUTH_CALLBACK_PORT
  else
    srv_oauth_id=
    srv_oauth_url=
    srv_oauth_port=
  fi
  srv_label='the five docs tools'
  srv_untouched='config.toml was not modified.'
  srv_approved_note='(the hosted check tools bbj_check_syntax, bbj_format and bbj_denum send your code to the server)'
}

# use_local: the same globals for bbj-local. The url is the fixed LOCAL_URL, never BBJ_LOCAL_MCP_URL (D-17);
# srv_old_key is empty, so no server-wide key is ever recognised, written or removed; srv_codex_add is 0
# because codex mcp add cannot set approval_mode
use_local() {
  srv=bbj-local
  srv_tools=$LOCAL_TOOLS
  srv_begin=$LOCAL_MARK_BEGIN
  srv_end=$LOCAL_MARK_END
  srv_url=$LOCAL_URL
  srv_old_key=
  srv_codex_add=0
  srv_fixed_url=1
  # bbj-local is a loopback server without sign-in: nothing about OAuth is written, reported or printed
  srv_oauth_id=
  srv_oauth_url=
  srv_oauth_port=
  srv_label='the three bbj-ls tools'
  srv_untouched='the bbj-local entry was not modified.'
  srv_approved_note="(the three bbj-ls tools run on this machine, against this installation's own PREFIX, classpath and config; nothing leaves it)"
}

# sync_server: registration and per-tool approval of the server the srv_* globals describe
sync_server() {
  refresh
  state
  need_change=0
  if [ "$foreign" = 0 ] && [ "$tools_foreign" = 0 ]; then
    if [ "$(an main)" = 0 ] || [ "$dstate" = ours ] || [ -n "$miss" ] || [ -n "$nokey" ] || [ "$oauth_miss" = 1 ]; then need_change=1; fi
  fi
  if [ "$need_change" = 1 ] && [ -f "$config" ] && [ ! -f "$config.bbj-backup" ]; then
    cp "$config" "$config.bbj-backup" || refuse "cannot write $config.bbj-backup"
    wrote="$wrote config.toml(backup)"
    say "config.toml: backup written to $config.bbj-backup"
  fi

  if [ "$foreign" = 0 ] && [ "$(an main)" = 0 ]; then
    if [ "$(an anytool)" != 0 ]; then
      # Codex 0.156.1 cannot load tool tables without the server table, and its mcp add then fails
      say "$srv: $config holds tool tables of $srv but no $srv table, which Codex cannot load; adding the table in a managed block"
    elif [ "$srv_codex_add" = 1 ] && command -v codex > /dev/null 2>&1; then
      # stdin from /dev/null: an unattended installer must never wait on a prompt of codex (WR-03)
      if CODEX_HOME=$codex_home codex mcp add "$srv" --url "$srv_url" < /dev/null > /dev/null 2>&1; then
        say "$srv: registered with codex mcp add $srv --url $srv_url"
      else
        # Codex CLI 0.162.1 writes the table and then exits 1 when its own OAuth sign-in fails
        # (the server takes only a pre-registered client); do not claim a block that is never written
        refresh
        if [ "$(an main)" = 1 ]; then
          say "$srv: codex mcp add wrote the $srv table, then exited with an error; the table is kept and completed below"
        else
          say "$srv: codex mcp add did not succeed; writing the block to config.toml instead"
        fi
      fi
    fi
  fi
  # re-check: a registration by codex in a form this script does not know must not get a second table
  refresh
  state
  if [ "$foreign" = 1 ]; then
    say "$srv: $config already names $srv in a form this script does not edit; $srv_untouched"
    if [ "$srv_fixed_url" = 1 ] && [ "$(an main)" = 1 ] && [ "$(an url)" != "$srv_url" ]; then
      say "$srv: its url is \"$(an url)\", not $srv_url; its tools are approved by name only at $srv_url"
    fi
    say "Check that it holds these tables (url and per-tool approval), or add them by hand:"
    print_block "$srv_url"
    pending=1
  elif [ "$tools_foreign" = 1 ]; then
    say "$srv: $config names tools of $srv in a form this script does not edit; $srv_untouched"
    if [ "$srv_fixed_url" = 1 ]; then
      say "Check that it approves the three bbj-ls tools by name, or add the tables by hand:"
    else
      say "Check that it approves these five tools by name, or add the tables by hand:"
    fi
    print_tools
    if [ "$oauth_miss" = 1 ]; then print_oauth; fi
    [ "$dstate" != ours ] || say "Also remove the line $srv_old_key from the $srv table by hand: an earlier version of this script wrote it and it approves every tool of $srv, including bbj_check_syntax, bbj_format and bbj_denum."
    pending=1
  elif [ "$(an main)" = 0 ] && [ "$(an managed)" = 1 ]; then
    # CR-01: the begin marker is there but the table is not (deleting the lines between the markers, the
    # documented way to drop the registration, leaves exactly this). A second begin marker would break the
    # one-block rule, so the table goes back inside the existing markers: before the end marker, or, when
    # no end marker follows the begin marker, right after the begin marker together with a new end marker.
    _hasend=$(awk -v b="$srv_begin" -v e="$srv_end" '
      { l = $0; sub(/\r$/, "", l) }
      l == b { s = 1; next }
      s && l == e { print 1; exit }
    ' "$config")
    tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
    # shellcheck disable=SC2094  # awk reads $config and writes $tmp; the copy back happens after awk ends
    _cr=$(config_cr)
    if awk -v srv="$srv" -v url="$srv_url" -v b="$srv_begin" -v e="$srv_end" -v hasend="${_hasend:-0}" -v cr="$_cr" '
        function ins() {
          printf "%s%s\n", "[mcp_servers." srv "]", cr
          printf "%s%s\n", "url = \"" url "\"", cr
        }
        {
          l = $0
          sub(/\r$/, "", l)
          if (!done && !inb && l == b) {
            print
            inb = 1
            if (!hasend) { ins(); printf "%s%s\n", e, cr; done = 1; inb = 0 }
            next
          }
          if (!done && inb && l == e) { ins(); done = 1; inb = 0 }
          print
        }
      ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
      rm -f "$tmp"
    else
      rm -f "$tmp"
      refuse "cannot update $config"
    fi
    wrote="$wrote config.toml"
    say "$srv: put the table back inside the managed block in $config (url $srv_url)"
    refresh
    state
  elif [ "$(an main)" = 0 ]; then
    _cr=$(config_cr)
    # shellcheck disable=SC2094  # the group reads $config (its last byte) before the append writes it
    {
      if [ -s "$config" ]; then
        [ -z "$(tail -c 1 "$config")" ] || printf '%s\n' "$_cr"
        printf '%s\n' "$_cr"
      fi
      printf '%s%s\n' "$srv_begin" "$_cr" "[mcp_servers.$srv]" "$_cr" "url = \"$srv_url\"" "$_cr" "$srv_end" "$_cr"
    } >> "$config" || refuse "cannot write $config"
    wrote="$wrote config.toml"
    say "$srv: appended a managed block to $config (url $srv_url)"
    refresh
    state
  elif [ "$need_change" = 0 ]; then
    say "$srv: already registered in $config with $srv_label approved; nothing changed"
  fi

  # what the user chose stays; say so
  if [ "$foreign" = 0 ] && [ "$(an main)" = 1 ]; then
    if [ -z "$srv_old_key" ]; then
      # a server without a legacy server-wide line (bbj-local): report any value, never act on it
      case "$dstate" in
        approve|other:*) say "$srv: $config sets default_tools_approval_mode to ${dstate#other:}; left as is" ;;
      esac
    else
      case "$dstate" in
        approve)
          say "$srv: $config sets default_tools_approval_mode to approve in a form this script did not write; left as is. It approves every tool of $srv, including bbj_check_syntax, bbj_format and bbj_denum, which send your code to the server; remove the line by hand to keep Codex's prompt for them."
          pending=1
          ;;
        other:*) say "$srv: $config sets default_tools_approval_mode to ${dstate#other:}; left as is" ;;
      esac
    fi
    for _t in $srv_tools; do
      case "$(an "tool.$_t")" in
        other:*) say "$srv: tool $_t has approval_mode $(an "tool.$_t" | sed 's/^other://') (yours); left as is" ;;
      esac
    done
    if [ -n "$srv_oauth_id" ] && [ "$oauth_state" = other ]; then
      # like a tool's own approval_mode, this is the user's choice: no pending, no exit 3
      _cid=$(an oauth.client_id)
      _cidtxt=
      [ -z "$_cid" ] || _cidtxt=" (client_id $_cid)"
      say "$srv: $config holds OAuth settings of its own for $srv$_cidtxt; left as is (the pre-registered client is client_id $srv_oauth_id with callback $srv_oauth_url)"
    fi
  fi

  if [ "$foreign" = 0 ] && [ "$tools_foreign" = 0 ] && [ "$(an main)" = 1 ] \
    && { [ "$dstate" = ours ] || [ -n "$miss" ] || [ -n "$nokey" ] || [ "$oauth_miss" = 1 ]; }; then
    drop=0
    [ "$dstate" = ours ] && drop=1
    tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
    _cr=$(config_cr)
    # shellcheck disable=SC2094  # awk reads $config and writes $tmp; the copy back happens after awk ends
    if awk -v srv="$srv" -v miss="$miss" -v nokey="$nokey" -v drop="$drop" -v old_key="$srv_old_key" -v tool_key="$TOOL_KEY" -v mark_end="$srv_end" -v cr="$_cr" \
      -v oauth_add="$oauth_miss" -v oid="$srv_oauth_id" -v ourl="$srv_oauth_url" -v oport="$srv_oauth_port" '
        # the missing tool tables go at the end of the server table body, before the blank
        # lines and comments that lead into the next table (or the end marker)
        function flush_main(atheader,   i, n, names) {
          if (!inmain) return
          inmain = 0
          n = split(miss, names, " ")
          # quick 261013-cpn: the OAuth client goes first; the four lines are byte-equal to the
          # want_* strings of analyze, so a rerun reads them as ours
          if (oauth_add == 1) {
            printf "%s\n", cr
            printf "%s%s\n", "[mcp_servers." srv ".oauth]", cr
            printf "%s%s\n", "client_id = \"" oid "\"", cr
            printf "%s%s\n", "callback_url = \"" ourl "\"", cr
            printf "%s%s\n", "callback_port = " oport, cr
          }
          for (i = 1; i <= n; i++) {
            printf "%s\n", cr
            printf "%s%s\n", "[mcp_servers." srv ".tools." names[i] "]", cr
            printf "%s%s\n", tool_key, cr
          }
          if ((n > 0 || oauth_add == 1) && atheader && !hasblank) printf "%s\n", cr
          for (i = 1; i <= nb; i++) print buf[i]
          nb = 0
          hasblank = 0
        }
        BEGIN {
          key = "(\"" srv "\"|" srv ")"
          main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
          tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
          tool_pre = "^\\[mcp_servers\\." key "\\.tools\\."
        }
        {
          line = $0
          sub(/\r$/, "", line)
          if (inmain) {
            if (line == mark_end || line ~ /^[ \t]*\[/) {
              flush_main(line != mark_end)
            } else if (line ~ /^[ \t]*$/ || line ~ /^[ \t]*#/) {
              buf[++nb] = $0
              if (line ~ /^[ \t]*$/) hasblank = 1
              next
            } else {
              if (drop && line == old_key) next
              for (i = 1; i <= nb; i++) print buf[i]
              nb = 0
              hasblank = 0
            }
          }
          print
          if (line ~ main_re) inmain = 1
          else if (line ~ tool_re) {
            name = line
            sub(tool_pre, "", name)
            sub(/\].*$/, "", name)
            if (index(" " nokey " ", " " name " ") > 0) printf "%s%s\n", tool_key, cr
          }
        }
        END { flush_main(0) }
      ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
      # written in place (not mv'd over it): a symlinked config.toml (dotfile managers) keeps
      # its link and every file keeps its mode (WR-01)
      rm -f "$tmp"
      wrote="$wrote config.toml"
      if [ "$drop" = 1 ]; then
        say "$srv: removed the line $srv_old_key from $config (an earlier version of this script wrote it; it approved every tool of $srv, including the hosted check tools)"
      fi
      if [ "$oauth_miss" = 1 ]; then
        say "$srv: added the OAuth client to $config: [mcp_servers.$srv.oauth] with client_id $srv_oauth_id, callback_url $srv_oauth_url and callback_port $srv_oauth_port"
      fi
      approved="$miss $nokey"
      approved=$(printf '%s' "$approved" | sed -e 's/^ *//' -e 's/ *$//' -e 's/  */, /g')
      if [ -n "$approved" ]; then
        say "$srv: approved by name in $config: $approved; every other tool of $srv keeps Codex's prompt $srv_approved_note"
      fi
    else
      rm -f "$tmp"
      refuse "cannot update $config"
    fi
  fi
}

# probe_local: asks the bbj-ls of a running BBjServices for its tool list (plan 01-06, LOCAL-03, D-11).
# Sets probe (found: a reply names bbj_check_syntax | none: no answer, or another server | nocurl |
# refused: the url is not loopback http) and probe_url (BBJ_LOCAL_MCP_URL, else LOCAL_URL; the seam
# moves only the probe, never the registration, D-17). It never writes a file, never exits and always
# returns 0. Only a validated loopback url reaches curl, with no proxy, no .curlrc and no redirect; the
# verdict is the tool name in the reply, never curl's exit code.
probe_local() {
  probe=none
  probe_url=${BBJ_LOCAL_MCP_URL:-$LOCAL_URL}
  case "$probe_url" in
    *[[:space:]]*|*@*|*'?'*|*'#'*|*'\'*) probe=refused; return 0 ;;
  esac
  _pok=$(printf '%s' "$probe_url" | sed -nE 's#^http://(\[::1\]|127\.0\.0\.1|[Ll][Oo][Cc][Aa][Ll][Hh][Oo][Ss][Tt])(:[0-9]+)?(/[^ ]*)?$#ok#p')
  [ "$_pok" = ok ] || { probe=refused; return 0; }
  command -v curl > /dev/null 2>&1 || { probe=nocurl; return 0; }
  _preply=$(curl -q -sS -g --noproxy '*' --proto =http --connect-timeout 2 -m 3 -X POST -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' -H 'MCP-Protocol-Version: 2026-07-28' -H 'Mcp-Method: tools/list' --data "$PROBE_BODY" --url "$probe_url" 2> /dev/null)
  if printf '%s' "$_preply" | grep -Eq '"name"[[:space:]]*:[[:space:]]*"bbj_check_syntax"'; then
    probe=found
  fi
  return 0
}

# ---- R. --remove: undo what this script wrote (phase 8, CODEX-06; D-01 to D-04) ----
# remove_server: whether the server the srv_* globals name can be taken out of config.toml, in the exact
# forms this script writes it. Sets rm_state (absent | remove | left), rm_why (the first rule that failed,
# for left) and rm_what (what goes, for remove). It reads config.toml and writes nothing.
rm_state=
rm_why=
rm_what=
remove_server() {
  refresh
  state
  rm_state=left
  rm_why=
  rm_what=
  _rm_generic='it names the server in a way this script does not recognise'
  _rm_line="line $(an extra_line) of $config is not one this script writes (a comment or a key among the tables of $srv); move it out of them or delete the tables by hand"
  if [ "$(an main)" = 0 ] && [ "$(an mention)" = 0 ] && [ "$(an anytool)" = 0 ]; then
    if [ "$(an managed)" = 0 ]; then
      rm_state=absent
    elif [ "$(an closed)" = 0 ]; then
      rm_why='its begin marker has no end marker'
    elif [ "$(an extra)" = 0 ]; then
      # markers only: the table between them was deleted by hand (the documented way to drop the registration)
      rm_state=remove
      rm_what='the managed block markers'
    else
      rm_why="line $(an extra_line) of $config, between the markers, is not one this script writes"
    fi
    return 0
  fi
  if [ "$(an main)" != 1 ]; then rm_why=$_rm_generic; return 0; fi
  # D-03: bbj-local is removed only as the managed block; a hand-registered one is the user's
  if [ "$srv_fixed_url" = 1 ] && [ "$(an managed)" != 1 ]; then
    rm_why='it is outside the managed block (registered by hand)'
    return 0
  fi
  if [ "$foreign" != 0 ] || [ "$tools_foreign" != 0 ]; then rm_why=$_rm_generic; return 0; fi
  if [ "$(an extra)" != 0 ]; then rm_why=$_rm_line; return 0; fi
  case "$(an dstate)" in
    none|ours) ;;
    *) rm_why='it sets default_tools_approval_mode in a form this script did not write'; return 0 ;;
  esac
  # RESEARCH A11: a registration at another url is also the documented Codex override of the plugin's server
  if [ "$srv_fixed_url" = 0 ]; then
    if [ -z "$(an url)" ]; then rm_why='it has no url'; return 0; fi
    if [ "$(an url)" != "$docs_url" ]; then
      rm_why="its url is $(an url), not the --docs-url in effect ($docs_url); rerun with --docs-url $(an url) to remove it"
      return 0
    fi
  fi
  _rm_na=0
  for _t in $srv_tools; do
    case "$(an "tool.$_t")" in
      approve) _rm_na=$((_rm_na + 1)) ;;
      missing) ;;
      *) rm_why="its tool table $_t is not approval_mode = \"approve\" as this script writes it"; return 0 ;;
    esac
  done
  if [ "$(an anytool)" != "$_rm_na" ]; then rm_why='it has a tool table this script does not write'; return 0; fi
  case "$(an oauth)" in
    missing|ours) ;;
    *) rm_why='its OAuth table is not the one this script writes'; return 0 ;;
  esac
  if [ "$(an managed)" = 1 ] && { [ "$(an inblock)" != 1 ] || [ "$(an closed)" != 1 ]; }; then
    rm_why='its table does not lie inside one complete managed block'
    return 0
  fi
  rm_state=remove
  rm_what="[mcp_servers.$srv]"
  [ "$(an oauth)" != ours ] || rm_what="$rm_what, [mcp_servers.$srv.oauth]"
  [ "$(an anytool)" = 0 ] || rm_what="$rm_what, $(an anytool) tool table(s)"
  [ "$(an managed)" != 1 ] || rm_what="$rm_what, the managed block markers"
  return 0
}

# remove_tables: one awk pass over config.toml for the server the srv_* globals name (remove_server said
# remove): drops the managed block from its begin to its end marker line when there is one, and, outside
# a block, every [mcp_servers.SRV], [mcp_servers.SRV.oauth] and [mcp_servers.SRV.tools.NAME] table, header
# and body up to the next header or managed-block marker. Blank lines are buffered: a removed header or
# begin marker takes the one blank line before it (the one this script wrote); blanks inside a removed
# region go; a kept line emits the blanks before it. A trailing CR is ignored when comparing and kept when
# printing, so a CRLF file stays CRLF. Written in place like the install side (a symlinked config.toml
# keeps its link and mode).
remove_tables() {
  if [ -f "$config" ] && [ ! -f "$config.bbj-backup" ]; then
    cp "$config" "$config.bbj-backup" || refuse "cannot write $config.bbj-backup"
    wrote="$wrote config.toml(backup)"
    say "config.toml: backup written to $config.bbj-backup"
  fi
  tmp=$(mktemp "$codex_home/config.toml.XXXXXX") || refuse "cannot create a temp file in $codex_home"
  # shellcheck disable=SC2094  # awk reads $config and writes $tmp; the copy back happens after awk ends
  if awk -v srv="$srv" -v begin="$srv_begin" -v mend="$srv_end" -v managed="$(an managed)" '
      function flush(   i) {
        for (i = 1; i <= nb; i++) print bl[i]
        nb = 0
      }
      # emit_hold: the blank and comment lines held at the end of a removed table. A comment among them leads into
      # what follows (analyze does not count it as table content, WR-04), so the held lines go out; without a
      # comment they were only the blank lines of the removed region
      function emit_hold(   i, c) {
        c = 0
        for (i = 1; i <= nh; i++) if (hd[i] ~ /^[ \t]*#/) c = 1
        if (c) for (i = 1; i <= nh; i++) print hd[i]
        nh = 0
      }
      BEGIN {
        key = "(\"" srv "\"|" srv ")"
        main_re = "^\\[mcp_servers\\." key "\\][ \t]*(#.*)?$"
        tool_re = "^\\[mcp_servers\\." key "\\.tools\\.[A-Za-z0-9_-]+\\][ \t]*(#.*)?$"
        oauth_re = "^\\[mcp_servers\\." key "\\.oauth\\][ \t]*(#.*)?$"
        mk_re = "^# (>>>|<<<) bbj-agent-plugins"
      }
      {
        line = $0
        sub(/\r$/, "", line)
        if (inblk) {
          if (line == mend) inblk = 0
          next
        }
        if (managed == 1 && line == begin) {
          if (inskip) { nb = 0; emit_hold() }
          else if (nb > 0) nb--
          flush()
          inskip = 0
          inblk = 1
          next
        }
        if (line ~ /^[ \t]*\[/) {
          if (line ~ main_re || line ~ oauth_re || line ~ tool_re) {
            if (inskip) { nb = 0; nh = 0 }
            else if (nb > 0) nb--
            flush()
            inskip = 1
            next
          }
          if (inskip) { nb = 0; inskip = 0; emit_hold() }
          flush()
          print
          next
        }
        if (inskip) {
          if (line ~ mk_re) { nb = 0; inskip = 0; emit_hold(); print; next }
          if (line ~ /^[ \t]*$/ || line ~ /^[ \t]*#/) { hd[++nh] = $0; next }
          nh = 0
          next
        }
        if (line ~ /^[ \t]*$/) { bl[++nb] = $0; next }
        flush()
        print
      }
      END { if (!inskip && !inblk) flush(); else if (inskip) emit_hold() }
    ' "$config" > "$tmp" && cat "$tmp" > "$config"; then
    rm -f "$tmp"
    wrote="$wrote config.toml"
  else
    rm -f "$tmp"
    refuse "cannot update $config"
  fi
}

# remove_all: the whole remove mode; it ends in exit 0, or exit 3 when something was left in place because it
# differs from what this script writes. It calls no other program of Codex and creates no directory (D-01).
remove_all() {
  say "Removing what install-codex.sh wrote under $codex_home and $skills_dir; codex is not called."
  if [ ! -f "$config" ]; then
    say "config.toml: $config does not exist; nothing to remove"
  else
    for _which in use_docs use_local; do
      "$_which"
      remove_server
      case "$rm_state" in
        remove)
          remove_tables
          say "$srv: removed from $config: $rm_what"
          ;;
        left)
          say "$srv: $config holds $srv in a form this script did not write; left in place: $rm_why"
          pending=1
          ;;
        *) say "$srv: not in $config; nothing to remove" ;;
      esac
    done
  fi
  for s in bbj-programming bbj-web-programming; do
    dst=$skills_dir/$s
    if [ -L "$dst" ]; then
      say "skill $s: $dst is a symbolic link; left in place"
      pending=1
    elif [ ! -e "$dst" ]; then
      say "skill $s: $dst not found; nothing to remove"
    elif [ -d "$dst" ] && [ "$(cd "$dst" 2> /dev/null && pwd -P)" = "$(cd "$src_skills/$s" 2> /dev/null && pwd -P)" ]; then
      # WR-01: --skills-dir that reaches this checkout's own skills (directly or through a symlinked parent) is
      # trivially identical to itself; deleting it would delete the source
      say "skill $s: $dst is the shipped directory of this checkout; left in place"
      pending=1
    elif [ -d "$dst" ] && diff -r "$src_skills/$s" "$dst" > /dev/null 2>&1; then
      [ -n "$skills_dir" ] && rm -rf -- "$dst" || refuse "cannot remove $dst"
      wrote="$wrote skill:$s"
      say "skill $s: removed $dst (identical to the shipped copy)"
    else
      say "skill $s: $dst differs from the shipped copy; left in place. Copy out what you want to keep, delete the directory, and run --remove again"
      pending=1
    fi
  done
  if [ -L "$script_dir" ]; then
    say "check script: $script_dir is a symbolic link; left in place"
    pending=1
  else
    if [ -e "$script_dst" ] || [ -L "$script_dst" ]; then
      rm -f -- "$script_dst" || refuse "cannot remove $script_dst"
      wrote="$wrote check-script"
      say "check script: removed $script_dst"
    else
      say "check script: $script_dst not found; nothing to remove"
    fi
    if [ -d "$script_dir" ] && ! rmdir "$script_dir" 2> /dev/null; then
      say "check script: $script_dir holds other files; left in place"
      pending=1
    fi
  fi
  if [ -L "$hooks" ]; then
    say "hooks.json: $hooks is a symbolic link; left in place"
    pending=1
  elif [ ! -e "$hooks" ]; then
    say "hooks.json: $hooks not found; nothing to remove"
  else
    tmp=$(mktemp "$codex_home/hooks.json.XXXXXX") || refuse "cannot create a temp file in $codex_home"
    render_hooks > "$tmp"
    if cmp -s "$tmp" "$hooks"; then
      rm -f "$hooks" || { rm -f "$tmp"; refuse "cannot remove $hooks"; }
      wrote="$wrote hooks.json"
      say "hooks.json: removed $hooks (it held only the hook this script writes)"
    else
      say "hooks.json: $hooks holds more than the hook this script writes; left in place. Delete this PostToolUse entry from it by hand (its script $script_dst is gone):"
      cat "$tmp"
      pending=1
    fi
    rm -f "$tmp"
  fi
  say "Kept: $config.bbj-backup if it exists (your backup) and Codex's own hooks.state entries in config.toml (a stale trust entry is harmless)."
  say "Next: codex plugin marketplace add BBj-AI/bbj-agent-plugins, then codex plugin add bbj@basis-bbj, then open /hooks in Codex and trust the BBj check hook."
  say "$STATUS_LINE"
  [ "$pending" = 0 ] || exit 3
  exit 0
}

if [ "$remove" = 1 ]; then
  remove_all
fi

use_docs
sync_server

# ---- 1b. the local check server: bbj-local (plan 01-04, LOCAL-02; plan 01-06, LOCAL-03, LOCAL-04; D-09, D-12, D-17) ----
# Runs after the bbj-docs pass on purpose: that pass is complete before this one starts, so
# neither result depends on which block comes first in config.toml (LOCAL-01).
# With the flag, the probe of plan 01-06 asks a running bbj-ls for its tool list first. The outcome
# only selects the line printed (LOCAL-04): bbj-local is registered on every outcome, a warning
# is printed on every outcome except "a bbj-ls answers", and the probe never returns early, sets
# pending or changes the exit code.
# Without the flag, a config.toml that holds a managed bbj-local block (the begin marker line and the
# table, as analyze reports them) gets the pass and no probe: leaving the flag out never removes or
# freezes a block the user opted into (D-09), it refreshes it in place. Markers whose table was
# deleted (the documented removal) get nothing without the flag: no probe, no write, the registration
# stays removed (D-09, opt-in); with the flag the table is put back inside the existing markers, so
# there is never a second begin marker. A lone end marker (what codex mcp
# remove leaves behind, D-10) is a comment and counts as no block; it is never touched.
# Without the flag and with no bbj-local in config.toml at all (no table, no mention, no managed
# block) the probe asks once and only suggests --with-local when a bbj-ls answers (LOCAL-03, D-11); it
# writes nothing and sets nothing. A bbj-local that is in config.toml (hand-registered or foreign) is
# never probed and never mentioned without the flag.
use_local
refresh
if [ "$with_local" = 1 ]; then
  probe_local
  _regat=
  [ "$probe_url" = "$LOCAL_URL" ] || _regat=" at $LOCAL_URL"
  _warn="; registering it anyway$_regat. Codex shows bbj-local as failed until BBjServices 26.03+ runs on this machine."
  case "$probe" in
    found) say "bbj-local: a bbj-ls answers at $probe_url" ;;
    none) say "bbj-local: warning: no bbj-ls answered at $probe_url$_warn" ;;
    nocurl) say "bbj-local: warning: not probed: curl not found$_warn" ;;
    refused) say "bbj-local: warning: not probed: $probe_url (BBJ_LOCAL_MCP_URL) is not a loopback http URL$_warn" ;;
  esac
  sync_server
elif [ "$(an managed)" = 1 ] && [ "$(an main)" = 1 ]; then
  sync_server
elif [ "$(an managed)" = 1 ]; then
  # CR-01: the markers are there but the table is not: the user removed the registration (the documented
  # way), so a run without the flag leaves it removed. No probe, no write, no line of output, as for a
  # hand-registered bbj-local; only --with-local puts the table back, inside these markers.
  :
elif [ "$(an main)" = 0 ] && [ "$(an mention)" = 0 ]; then
  probe_local
  # when the seam moved the probe, the none line also names the url the registration always uses (D-17)
  _seam=
  [ "$probe_url" = "$LOCAL_URL" ] || _seam=" The registration always uses $LOCAL_URL."
  case "$probe" in
    found) say "bbj-local: a bbj-ls answers at $probe_url; it is not registered with Codex. Rerun with --with-local to register it as bbj-local ($LOCAL_URL); nothing was written for it." ;;
    none) say "bbj-local: no bbj-ls answered at $probe_url; not registered (rerun with --with-local once BBjServices 26.03+ runs).$_seam" ;;
    nocurl) say "bbj-local: not probed: curl not found." ;;
    refused) say "bbj-local: not probed: $probe_url (BBJ_LOCAL_MCP_URL) is not a loopback http URL." ;;
  esac
fi

# ---- 2. the skills ----
for s in bbj-programming bbj-web-programming; do
  src=$src_skills/$s
  dst=$skills_dir/$s
  if [ ! -e "$dst" ]; then
    mkdir -p "$skills_dir" || refuse "cannot create $skills_dir"
    cp -R "$src" "$dst" || refuse "cannot copy $src to $dst"
    wrote="$wrote skill:$s"
    say "skill $s: installed to $dst"
  elif diff -r "$src" "$dst" > /dev/null 2>&1; then
    say "skill $s: $dst is identical; nothing changed"
  elif [ "$force" = 1 ]; then
    rm -rf "$dst" && cp -R "$src" "$dst" || refuse "cannot replace $dst"
    wrote="$wrote skill:$s"
    say "skill $s: $dst differed and was replaced (--force)"
  else
    say "skill $s: $dst differs from the shipped copy and was left untouched; rerun with --force to replace it"
    pending=1
  fi
done

# ---- 3. the check script, at a stable path outside any plugin cache ----
mkdir -p "$script_dir" || refuse "cannot create $script_dir"
if cmp -s "$src_script" "$script_dst"; then
  say "check script: $script_dst is current; nothing changed"
else
  cp "$src_script" "$script_dst" || refuse "cannot copy the check script"
  wrote="$wrote check-script"
  say "check script: copied to $script_dst (every update of it makes Codex ask for the /hooks review again)"
fi
chmod 755 "$script_dst"

# ---- 4. hooks.json: written only when absent ----
# (render_hooks, above, prints the block: --remove compares an existing file against the same bytes)
tmp=$(mktemp "$codex_home/hooks.json.XXXXXX") || refuse "cannot create a temp file in $codex_home"
render_hooks > "$tmp"
if [ ! -e "$hooks" ]; then
  mv "$tmp" "$hooks" || { rm -f "$tmp"; refuse "cannot write $hooks"; }
  say "hooks.json: written to $hooks (PostToolUse, matcher apply_patch|Edit|Write, timeout 30)"
elif cmp -s "$tmp" "$hooks"; then
  rm -f "$tmp"
  say "hooks.json: $hooks already holds this hook; nothing changed"
else
  say "hooks.json: $hooks exists and was not written by this script; it was not modified."
  say "Merge this hook into it by hand (a PostToolUse entry), then review it in /hooks:"
  cat "$tmp"
  rm -f "$tmp"
  pending=1
fi

# ---- 5. the AGENTS.md snippet, the trust step, the gaps ----
say ""
say "Add the following to AGENTS.md in your repository, or to $codex_home/AGENTS.md (AGENTS.md files share a 32 KiB cap; a plugin cannot ship one):"
say "----8<----"
cat "$snippet"
say "----8<----"
say ""
say "Trust step: Codex skips a hook it did not manage until you review it. Start Codex, open /hooks, and approve the BBj check hook."
say "The review is pinned to a hash of the script: a changed bbj-check.sh asks again. This script cannot approve it for you."
if [ "$docs_url" = "$DEFAULT_DOCS_URL" ]; then
  say "Sign-in step: the docs server bbj-docs asks for an OAuth sign-in (pre-registered client $OAUTH_CLIENT_ID). Run codex mcp login bbj-docs once; a browser opens, and the sign-in returns to $OAUTH_CALLBACK_URL, so port $OAUTH_CALLBACK_PORT must be free while you sign in."
else
  say "Sign-in step: none written. The pre-registered OAuth client belongs to the hosted docs server only, so $docs_url got no OAuth table; if that server asks for a sign-in, run codex mcp login bbj-docs."
fi
say ""
say "Known gaps:"
say "- OpenAI calls hooks \"a useful guardrail, not a complete enforcement boundary\"."
say "- Patches applied through a shell heredoc are not seen by the hook; only apply_patch calls are checked."
say "- Codex has no plugin options here: the check finds BBj through BBJ_HOME, then PATH, then the default homes; set BBJ_HOME when BBj is not in a default location."
say "- With no compiler found, the hook asks a running bbj-ls on 127.0.0.1:5009 (syntax only); with neither, it tells Codex once per session that the file was written but not compile-checked."
say "- If Codex does not list the BBj skills, rerun with --skills-dir ~/.codex/skills (~/.agents/skills worked with Codex CLI 0.162.1)."
say "- commandWindows in hooks.json is not yet tried on Windows; if Codex rejects it there, use command_windows in config.toml instead."
say ""
say "$STATUS_LINE"

[ "$pending" = 0 ] || exit 3
exit 0
