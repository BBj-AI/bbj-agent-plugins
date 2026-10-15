#!/bin/sh
# tests/test_install_pages.sh -- keeps the install pages honest (plan 19-07, PLUG-05; plan 01-07, LOCAL-06).
#
# For every docs/install-*.md that exists:
#   - a required-phrase list per page (what the page must state),
#   - forbidden claims: the go-live host as a default, and "subagent edits are not covered",
#   - the local check (plan 01-07, LOCAL-06; D-13, D-14): its own heading on both install pages, the
#     two reasons it is preferred over the hosted check on both pages and in README, and a forbid so
#     that no page ranks bbj-local above bbjcpl,
#   - every relative Markdown link in docs/*.md, README.md and CHANGELOG.md resolves,
#   - every "claude plugin <subcommand>" line in the Claude page's fenced blocks names a real
#     subcommand of the installed CLI (claude plugin <words> --help exits 0); skipped when
#     claude is not installed.
#   - the no-route notice wording (plan 02-03, HOOK-02): "once per session" on README and both pages,
#     "not compile-checked" on both pages, and the old claim that the hook stays silent when no check
#     route exists is forbidden on all three (NOROUTE_SILENCE),
#   - the OAuth sign-in of the docs server bbj (quick 261013-cpn; phase 12, NAME-02): port 47613 and the sign-in commands and labels of 12-LINUX-RUN.md on both pages and README,
#   - the Codex plugin route (phase 8, CODEX-05, CODEX-06; D-15, D-16; plan 11-03, D-04, D-05): the
#     plugin-route heading, the two install commands, the bbj-local opt-in command, the verified line,
#     the sentence on the Codex CLI version the route was verified with, the sentence that only the
#     Claude Code plugin has the docs_url option and the file that holds the Codex URL, the first-use
#     prompts, the plugin-scoped key, on the Codex page; the two plugin commands and the docs_url
#     sentence in README; and a forbid so that neither the Codex page nor README recommends the
#     hook-trust bypass flag of codex exec.
#   - the verified platforms (plan 10-06, 10-07, DOCS-01, DOCS-02, DOCS-04; D-01 to D-05): the banner
#     "Verified on Linux, Windows and macOS" on both pages, the three Claude Code versions (one per
#     platform) and the sections "## Windows" and "## macOS" on the Claude Code page; the "Observed on
#     <platform> with" lines, "## macOS", the "hook exited" symptom, the plugin's commandWindows lookup
#     and its not-found message (phase 13, D-10), the hosted-server wording and the daemon environment sentence on the Codex page; the README table
#     rows and the BBj version beside them; and two forbids on README and both pages
#     (check_released_wording): the old "not yet run" platform hints and the pre-production or go-live
#     wording of the docs server, so neither can come back.
# Nothing here runs BBj code; "claude plugin ... --help" only prints help.

. "$(dirname "$0")/lib.sh"
mkwork

DOCS=$REPO/docs
CLAUDE_PAGE=$DOCS/install-claude-code.md
CODEX_PAGE=$DOCS/install-codex.md

# slug TEXT: a gate-name-safe form of TEXT
slug() {
  printf '%s' "$1" | tr -c 'A-Za-z0-9\n' '_' | cut -c1-40
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

# the local check must never read as better than the compiler (D-13): bbjcpl also checks types
LOCAL_ABOVE_BBJCPL='(preferred|better) (than|over) `?bbjcpl'

# nothing may recommend skipping the Codex hook review (phase 8, T-08-26): the flag of codex exec that
# does it is named by its stem only, so this file never holds the whole flag
HOOK_TRUST_BYPASS='dangerously-bypass'

# ---- Claude Code page ----
if [ -f "$CLAUDE_PAGE" ]; then
  n=claude
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
    '## 3. Enable the local check' \
    'claude plugin enable bbj-local@basis-bbj' \
    'once per session' \
    'not compile-checked' \
    '47613' \
    'Needs authentication' \
    '`plugin:bbj:bbj`' \
    'mcp__plugin_bbj_bbj__' \
    'oauth.clientId'
  do
    need "$n" "$CLAUDE_PAGE" "$p"
  done
  check_common "$n" "$CLAUDE_PAGE"
  check_released_wording "$n" "$CLAUDE_PAGE"
  forbid "$n" "$CLAUDE_PAGE" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$CLAUDE_PAGE" "$NOROUTE_SILENCE" noroute_silence

  sections=$(grep -c '^## ' "$CLAUDE_PAGE")
  if [ "$sections" -ge 5 ]; then
    gate "${n}_sections" ok "$sections sections"
  else
    gate "${n}_sections" FAIL "only $sections sections"
  fi

  # every "claude plugin <words>" line in a fenced block names a real subcommand
  if command -v claude > /dev/null 2>&1; then
    awk '/^```/ { f = !f; next } f && /^claude plugin / { print }' "$CLAUDE_PAGE" > "$WORK/cmds"
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
fi

# ---- Codex page ----
if [ -f "$CODEX_PAGE" ]; then
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
    '### Enable the local check (bbj-local)' \
    'http://127.0.0.1:5009/mcp' \
    'once per session' \
    'not compile-checked' \
    'http://localhost:47613/callback' \
    '`codex mcp login bbj`' \
    'only the Claude Code plugin has the `docs_url` option' \
    'plugins/bbj/.codex-mcp.json' \
    '## Install with the Codex plugin' \
    'codex plugin marketplace add BBj-AI/bbj-agent-plugins' \
    'codex plugin add bbj@basis-bbj' \
    'codex plugin add bbj-local@basis-bbj' \
    'Verified on Linux with Codex CLI 0.162.1 on' \
    '### Trust the hook in /hooks' \
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
    '`plugins."bbj@basis-bbj".mcp_servers.bbj`'
  do
    need "$n" "$CODEX_PAGE" "$p"
  done
  check_common "$n" "$CODEX_PAGE"
  check_released_wording "$n" "$CODEX_PAGE"
  forbid "$n" "$CODEX_PAGE" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$CODEX_PAGE" "$NOROUTE_SILENCE" noroute_silence
  # no text may tell users to skip the hook review (T-08-26, CODEX-05)
  forbid "$n" "$CODEX_PAGE" "$HOOK_TRUST_BYPASS" hook_trust_bypass
fi

# ---- README: the local check, preferred over the hosted check, for two reasons (plan 01-07, D-13) ----
README=$REPO/README.md
if [ -f "$README" ]; then
  n=readme
  for p in \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    'only the Claude Code plugin has the `docs_url` option' \
    '## Skills' \
    'once per session' \
    'codex plugin add bbj@basis-bbj' \
    'codex plugin add bbj-local@basis-bbj' \
    '`codex mcp login bbj`' \
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
for f in "$REPO"/README.md "$REPO"/CHANGELOG.md "$DOCS"/*.md; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  rel=${f#"$REPO"/}
  grep -o '\]([^)]*)' "$f" | sed -e 's/^\](//' -e 's/)$//' > "$WORK/links"
  checked=0
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    case "$target" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    path=${target%%#*}
    [ -n "$path" ] || continue
    checked=$((checked + 1))
    if [ -e "$dir/$path" ]; then
      gate "link_$(slug "$rel")_$(slug "$path")" ok "$rel -> $path"
    else
      gate "link_$(slug "$rel")_$(slug "$path")" FAIL "$rel links to $path, which does not exist"
    fi
  done < "$WORK/links"
done

finish
