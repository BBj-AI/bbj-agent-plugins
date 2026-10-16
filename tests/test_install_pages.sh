#!/bin/sh
# tests/test_install_pages.sh -- keeps the install page honest (plan 19-07, PLUG-05; plan 01-07, LOCAL-06;
# plan 14-01, DOCS-05, D-01 to D-04).
#
# There is one install page, docs/install.md, for Claude Code and Codex (D-01). Its pins keep two
# prefixes, claude_ and codex_, so that each prefix still names the client whose reader the pin
# protects (D-04); the forbids run on the one page under both prefixes. When the page exists:
#   - a required-phrase list per client (what the page must state),
#   - gate claude_sections: the "## " headings of the page are exactly the eleven headings of D-01,
#     in that order,
#   - forbidden claims: the go-live host as a default, and "subagent edits are not covered",
#   - the plugin bbj-local (plan 01-07, LOCAL-06; D-13, D-14; plan 14-01, D-08): its own numbered
#     heading, the two reasons it is preferred over the hosted check on the page and in README, and a
#     forbid so that no text ranks bbj-local above the bbjcpl check,
#   - every relative Markdown link in docs/*.md, README.md and CHANGELOG.md resolves,
#   - every "claude plugin <subcommand>" line in the page's fenced blocks names a real
#     subcommand of the installed CLI (claude plugin <words> --help exits 0); skipped when
#     claude is not installed.
#   - the no-route notice wording (plan 02-03, HOOK-02): "once per session" on README and the page,
#     "not compile-checked" on the page, and the old claim that the hook stays silent when no check
#     route exists is forbidden on both (NOROUTE_SILENCE),
#   - the OAuth sign-in of the docs server bbj (quick 261013-cpn; phase 12, NAME-02): port 47613 and the sign-in commands and labels of 12-LINUX-RUN.md on the page and README,
#   - the Codex plugin route (phase 8, CODEX-05, CODEX-06; D-15, D-16; plan 11-03, D-04, D-05): the
#     install heading, the two install commands, the bbj-local opt-in command, the verified line,
#     the sentence on the Codex CLI version the route was verified with, the sentence that only the
#     Claude Code plugin has the docs_url option and the file that holds the Codex URL, the first-use
#     prompts, the plugin-scoped key and the sentence that it is for the five docs tools and nothing
#     else (T-14-03), on the page; the two plugin commands in README; and a forbid so that neither
#     the page nor README recommends the hook-trust bypass flag of codex exec.
#   - the verified platforms (plan 10-06, 10-07, DOCS-01, DOCS-02, DOCS-04; D-01 to D-05): the banner
#     "Verified on Linux, Windows and macOS", the three Claude Code versions (one per platform) and
#     the sections "## Windows" and "## macOS"; the "Observed on <platform> with" lines, the
#     "hook exited" symptom, the plugin's commandWindows lookup and its not-found message (phase 13,
#     D-10), the hosted-server wording and the daemon environment sentence; the README table
#     rows and the BBj version beside them; and two forbids on README and the page
#     (check_released_wording): the old "not yet run" platform hints and the pre-production or go-live
#     wording of the docs server, so neither can come back.
# Nothing here runs BBj code; "claude plugin ... --help" only prints help.

. "$(dirname "$0")/lib.sh"
mkwork

DOCS=$REPO/docs
PAGE=$DOCS/install.md

# slug TEXT: a gate-name-safe form of TEXT, cut at 60 characters (IN-04): two pins that share a long
# stem must still print two different gate names; widen it again if a pin ever shares more than that
slug() {
  printf '%s' "$1" | tr -c 'A-Za-z0-9\n' '_' | cut -c1-60
}

# need NAME FILE PHRASE: gate NAME_has_<phrase> passes when FILE contains PHRASE (fixed string)
need() {
  if grep -qF -e "$3" "$2"; then
    gate "$1_has_$(slug "$3")" ok "$3"
  else
    gate "$1_has_$(slug "$3")" FAIL "$2 lacks: $3"
  fi
}

# forbid NAME FILE ERE LABEL: gate fails when the newline-flattened FILE matches the ERE
forbid() {
  if tr '\n' ' ' < "$2" | grep -qiE -e "$3"; then
    gate "$1_forbids_$4" FAIL "$2 matches the forbidden pattern: $3"
  else
    gate "$1_forbids_$4" ok "no match for: $3"
  fi
}

check_common() {
  # check_common NAME FILE: the claims no page may make
  forbid "$1" "$2" 'bbj-mcp\.basis\.cloud' go_live_host
  forbid "$1" "$2" 'subagent[^.]*not (covered|checked)' subagent_not_covered
  # WR-06: a pre-merge caveat is a release note (CHANGELOG.md), not install-page text that goes stale on merge
  forbid "$1" "$2" 'until this release|release is merged to it|this release is on github' release_time_caveat
}

# check_released_wording NAME FILE: the hints of releases before 0.2.1 must not come back (plan 10-06,
# DOCS-04, D-03, D-05). "not yet set" (a Claude Code message about two options) is not one of them.
check_released_wording() {
  forbid "$1" "$2" 'Tested on Linux only|not yet run|not yet been run|not yet tried|not yet been tried' old_platform_hints
  forbid "$1" "$2" 'pre-production|go-live|earlier trial' docs_server_stage
}

# the hook now speaks when no check route exists (plan 02-03, HOOK-02): no text may say it stays silent
NOROUTE_SILENCE='says nothing|missing compiler is silent'

# the plugin bbj-local must never read as better than the bbjcpl check (D-13): bbjcpl also checks types
LOCAL_ABOVE_BBJCPL='(preferred|better) (than|over) `?bbjcpl'

# nothing may recommend skipping the Codex hook review (phase 8, T-08-26): the flag of codex exec that
# does it is named by its stem only, so this file never holds the whole flag
HOOK_TRUST_BYPASS='dangerously-bypass'

# ---- the install page, Claude Code pins ----
if [ -f "$PAGE" ]; then
  n=claude
  # IN-04: the pins both lists hold on purpose (D-04; one gate per prefix, each naming the reader it
  # protects): '## Check routes', '## Not covered', '## Windows', '## macOS', 'Git for Windows',
  # 'commandWindows', 'once per session', 'not compile-checked', 'recommended where BBjServices 26.03',
  # 'preferred over the hosted check', 'PREFIX, classpath and config', '## 4. Enable the plugin
  # `bbj-local`', 'Verified on Linux, Windows and macOS' and 'the hosted BBj docs server'. A failure of
  # one of them names its prefix, not which of the two lists caught it: look in both lists.
  for p in \
    'claude plugin install bbj@basis-bbj' \
    'claude plugin marketplace add BBj-AI/bbj-agent-plugins' \
    'docs_url' \
    'bbj_home' \
    'https://mcp.bbj-ai.com/mcp' \
    'bbj-local' \
    '## Check routes' \
    'bbjcpl -t -N -X' \
    '127.0.0.1:5009' \
    'syntax only' \
    '## Not covered' \
    'Bash' \
    'NotebookEdit' \
    '## Windows' \
    'Git for Windows' \
    'data-handling' \
    'config*.bbx' \
    '## macOS' \
    'Verified on Linux, Windows and macOS' \
    'the hosted BBj docs server' \
    'commandWindows' \
    'Claude Code 2.1.299 on Linux' \
    'Claude Code 2.1.292 on Windows' \
    'Claude Code 2.1.296 on macOS' \
    '`bbj-local reported' \
    '`bbjcpl reported' \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    '## 3. Sign in to the docs server `bbj`' \
    '## 4. Enable the plugin `bbj-local`' \
    'claude plugin enable bbj-local@basis-bbj' \
    'once per session' \
    'not compile-checked' \
    '47613' \
    'Needs authentication' \
    '`plugin:bbj:bbj`' \
    'mcp__plugin_bbj_bbj__' \
    'oauth.clientId'
  do
    need "$n" "$PAGE" "$p"
  done
  check_common "$n" "$PAGE"
  check_released_wording "$n" "$PAGE"
  forbid "$n" "$PAGE" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$PAGE" "$NOROUTE_SILENCE" noroute_silence

  # the "## " headings are exactly the eleven of D-01, in order (an extra or a missing step fails)
  printf '%s\n' \
    '## Requirements' \
    '## 1. Add the marketplace' \
    '## 2. Install' \
    '## 3. Sign in to the docs server `bbj`' \
    '## 4. Enable the plugin `bbj-local`' \
    '## Options' \
    '## Check routes' \
    '## Not covered' \
    '## Windows' \
    '## macOS' \
    '## Update and remove' > "$WORK/headings.want"
  grep '^## ' "$PAGE" > "$WORK/headings.got"
  _diff=$(awk 'NR == FNR { want[NR] = $0; nw = NR; next }
    { got[FNR] = $0; ng = FNR }
    END {
      n = (nw > ng) ? nw : ng
      for (i = 1; i <= n; i++)
        if (want[i] != got[i]) { printf "heading %d: wanted [%s], got [%s]", i, want[i], got[i]; exit }
    }' "$WORK/headings.want" "$WORK/headings.got")
  if [ -z "$_diff" ]; then
    gate "${n}_sections" ok "the D-01 headings in order"
  else
    gate "${n}_sections" FAIL "$_diff"
  fi

  # every "claude plugin <words>" line in a fenced block names a real subcommand
  if command -v claude > /dev/null 2>&1; then
    awk '/^```/ { f = !f; next } f && /^claude plugin / { print }' "$PAGE" > "$WORK/cmds"
    count=0
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      words=
      set -f
      # shellcheck disable=SC2086
      set -- $line
      set +f
      shift 2   # drop "claude plugin"
      for w in "$@"; do
        case "$w" in
          *[!a-z]*|'') break ;;
        esac
        words="$words $w"
      done
      if [ -z "$words" ]; then
        gate "${n}_command" FAIL "no subcommand in: $line"
        continue
      fi
      count=$((count + 1))
      # shellcheck disable=SC2086
      if CLAUDE_CONFIG_DIR="$WORK/cc" claude plugin $words --help > /dev/null 2>&1; then
        gate "${n}_command_$(slug "$words")" ok "claude plugin$words --help (from: $line)"
      else
        gate "${n}_command_$(slug "$words")" FAIL "claude plugin$words --help failed (from: $line)"
      fi
    done < "$WORK/cmds"
    if [ "$count" -ge 1 ]; then
      gate "${n}_commands_found" ok "$count command line(s) checked"
    else
      gate "${n}_commands_found" FAIL "no claude plugin command lines in a fenced block"
    fi
  else
    gate "${n}_commands" skip "claude is not installed"
  fi

  # ---- the install page, Codex pins ----
  n=codex
  for p in \
    'Verified on Linux, Windows and macOS' \
    'The plugin route was verified with Codex CLI 0.162.1' \
    'bbj_check_syntax' \
    '/hooks' \
    'apply_patch' \
    '## Check routes' \
    '## Not covered' \
    '## Windows' \
    'Git for Windows' \
    'commandWindows' \
    'guardrail' \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    '## 4. Enable the plugin `bbj-local`' \
    'http://127.0.0.1:5009/mcp' \
    'once per session' \
    'not compile-checked' \
    'http://localhost:47613/callback' \
    '`codex mcp login bbj`' \
    'only the Claude Code plugin has the `docs_url` option' \
    'plugins/bbj/.codex-mcp.json' \
    '## 2. Install' \
    'codex plugin marketplace add BBj-AI/bbj-agent-plugins' \
    'codex plugin add bbj@basis-bbj' \
    'codex plugin add bbj-local@basis-bbj' \
    'Verified on Linux with Codex CLI 0.162.1 on' \
    '### Codex: trust the hook in /hooks' \
    'first use' \
    'Observed on Linux with Codex CLI 0.162.1:' \
    'Observed on Windows with' \
    'Observed on macOS with' \
    '## macOS' \
    'hook exited' \
    '%LOCALAPPDATA%\Programs\Git' \
    'Git for Windows sh.exe not found' \
    'the hosted BBj docs server' \
    'stop every Codex process' \
    'approval_mode = "approve"' \
    '`plugins."bbj@basis-bbj".mcp_servers.bbj`' \
    'and for nothing else'
  do
    need "$n" "$PAGE" "$p"
  done
  check_common "$n" "$PAGE"
  check_released_wording "$n" "$PAGE"
  forbid "$n" "$PAGE" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$PAGE" "$NOROUTE_SILENCE" noroute_silence
  # no text may tell users to skip the hook review (T-08-26, CODEX-05)
  forbid "$n" "$PAGE" "$HOOK_TRUST_BYPASS" hook_trust_bypass
fi

# ---- README: the plugin bbj-local, preferred over the hosted check, for two reasons (plan 01-07, D-13) ----
README=$REPO/README.md
if [ -f "$README" ]; then
  n=readme
  for p in \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    '## Skills' \
    'once per session' \
    'codex plugin add bbj@basis-bbj' \
    'codex plugin add bbj-local@basis-bbj' \
    '`codex mcp login bbj`' \
    '](docs/install.md)' \
    '| Claude Code |' \
    '| Codex plugin |' \
    'Verified on Linux, Windows and macOS' \
    'BBj 26.03' \
    'the hosted BBj docs server'
  do
    need "$n" "$README" "$p"
  done
  check_released_wording "$n" "$README"
  forbid "$n" "$README" "$HOOK_TRUST_BYPASS" hook_trust_bypass
  forbid "$n" "$README" 'until this release|release is merged to it|this release is on github' release_time_caveat
  forbid "$n" "$README" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$README" "$NOROUTE_SILENCE" noroute_silence
fi

# ---- relative Markdown links resolve ----
# The 0.2.0 entry of CHANGELOG.md is frozen (11 D-03) and links pages that no longer exist; the cut
# below drops the entries headed 0.2.1 or older (compared as integers, the rule of changelog_scan_text
# in tests/test_layout.py), so a link in a newer entry is still checked. Any other "## " line keeps
# the text after it (fail closed).
CUT_MAJOR=0
CUT_MINOR=2
CUT_PATCH=1

# history_cut FILE: prints FILE without the CHANGELOG entries headed CUT_MAJOR.CUT_MINOR.CUT_PATCH or older
history_cut() {
  awk -v c1="$CUT_MAJOR" -v c2="$CUT_MINOR" -v c3="$CUT_PATCH" '
    BEGIN { keep = 1 }
    /^## / {
      keep = 1
      if ($0 ~ /^## [0-9]+\.[0-9]+\.[0-9]+( |\t|$)/) {
        split(substr($0, 4), v, /[. \t]/)
        a = v[1] + 0; b = v[2] + 0; c = v[3] + 0
        if (a < c1 || (a == c1 && (b < c2 || (b == c2 && c <= c3)))) keep = 0
      }
    }
    keep { print }
  ' "$1"
}

# check_links FILE: gate link_<file>_<target> for every relative Markdown link of FILE; a file named
# CHANGELOG.md is read through history_cut
check_links() {
  _f=$1
  [ -f "$_f" ] || return 0
  _dir=$(dirname "$_f")
  _rel=${_f#"$REPO"/}
  _src=$_f
  if [ "$(basename "$_f")" = CHANGELOG.md ]; then
    history_cut "$_f" > "$WORK/changelog.cut"
    _src=$WORK/changelog.cut
  fi
  grep -o '\]([^)]*)' "$_src" | sed -e 's/^\](//' -e 's/)$//' > "$WORK/links"
  while IFS= read -r _target; do
    [ -n "$_target" ] || continue
    case "$_target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    _path=${_target%%#*}
    [ -n "$_path" ] || continue
    if [ -e "$_dir/$_path" ]; then
      gate "link_$(slug "$_rel")_$(slug "$_path")" ok "$_rel -> $_path"
    else
      gate "link_$(slug "$_rel")_$(slug "$_path")" FAIL "$_rel links to $_path, which does not exist"
    fi
  done < "$WORK/links"
}

for f in "$REPO"/README.md "$REPO"/CHANGELOG.md "$DOCS"/*.md; do
  check_links "$f"
done

# proof that the cut skips only history: a scratch CHANGELOG with a missing link in a newer entry
# and one in a 0.2.1 entry. Their gate lines go to a file, not to this test's output.
mkdir -p "$WORK/cl"
printf '%s\n' \
  '# Changelog' \
  '' \
  '## 9.9.9' \
  '' \
  '- [new](docs/gone-new.md)' \
  '' \
  '## 0.2.1' \
  '' \
  '- [old](docs/gone-old.md)' > "$WORK/cl/CHANGELOG.md"
( check_links "$WORK/cl/CHANGELOG.md" ) > "$WORK/cl.out" 2>&1
if grep -q '^gate link_.* FAIL .*gone-new\.md' "$WORK/cl.out"; then
  gate link_history_cut_newer_entry ok "a link to a missing page in a 9.9.9 entry fails"
else
  gate link_history_cut_newer_entry FAIL "no FAIL line for the missing page of the newer entry"
fi
if grep -q 'gone-old\.md' "$WORK/cl.out"; then
  gate link_history_cut_old_entry FAIL "the 0.2.1 entry was checked"
else
  gate link_history_cut_old_entry ok "the links of a 0.2.1 entry are not checked"
fi

finish
