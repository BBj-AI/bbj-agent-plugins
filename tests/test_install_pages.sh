#!/bin/sh
# tests/test_install_pages.sh -- keeps the install pages honest (plan 19-07, PLUG-05; plan 01-07, LOCAL-06).
#
# For every docs/install-*.md that exists:
#   - a required-phrase list per page (what the page must state),
#   - forbidden claims: the go-live host as a default, and "subagent edits are not covered",
#   - the local check (plan 01-07, LOCAL-06; D-13, D-14): its own numbered step on both install pages,
#     the two reasons it is preferred over the hosted check on both pages and in README, and a forbid
#     so that no page ranks bbj-local above bbjcpl; the bbj-local tool tables of the Codex page equal
#     LOCAL_TOOLS of the installer, and every installer message the Codex page quotes is printed by
#     the installer on a line that is not a comment,
#   - every relative Markdown link in docs/*.md, README.md and CHANGELOG.md resolves,
#   - every "claude plugin <subcommand>" line in the Claude page's fenced blocks names a real
#     subcommand of the installed CLI (claude plugin <words> --help exits 0); skipped when
#     claude is not installed.
#   - the no-route notice wording (plan 02-03, HOOK-02): "once per session" on README, both pages and the
#     installer, "not compile-checked" on both pages, and the old claim that the hook stays silent when
#     no check route exists is forbidden on all four (NOROUTE_SILENCE),
#   - the OAuth sign-in of bbj-docs (quick 261013-cpn): port 47613 and the sign-in steps on both pages,
#     and the installer messages the Codex page quotes about the OAuth table; the Codex page shows the
#     client id of the installer (IN-07),
#   - the Codex plugin route (phase 8, CODEX-05, CODEX-06; D-15, D-16): the plugin-route heading, the
#     two install commands, the bbj-local opt-in command, the verified line, the first-use prompts, the
#     upgrade-trust sentence, the switch heading and --remove, the fallback heading and the
#     plugin-scoped key, on the Codex page; the two plugin commands in README; twelve installer
#     messages quoted on the page (four more for --remove); and a forbid so that neither the Codex page
#     nor README recommends the hook-trust bypass flag of codex exec.
#   - the Codex page, verified platforms (plan 10-07, DOCS-02, DOCS-04; D-03 to D-05, D-10, D-11): the banner "Verified on
#     Linux, Windows and macOS", "## macOS", the --sh-exe option, the "hook exited" symptom and the plugin's
#     commandWindows path, the "Observed on <platform> with" lines, the hosted-server wording and the daemon
#     environment sentence; the two forbids of check_released_wording; and codex_plugin_route_first (the
#     plugin-route heading comes before the fallback heading).
#   - the verified platforms (plan 10-06, DOCS-01, DOCS-02, DOCS-04; D-01 to D-05): the banner "Verified on
#     Linux, Windows and macOS", the three Claude Code versions (one per platform) and the sections
#     "## Windows" and "## macOS" on the Claude Code page; the README table rows and the BBj version
#     beside them; the hosted-server wording on both; the plugin commands before the installer in
#     README (readme_codex_plugin_first); and two forbids on README and the Claude Code page
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
    'subagent' \
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
  # shellcheck disable=SC2088  # the tilde is literal text searched for in the page
  for p in \
    'Verified on Linux, Windows and macOS' \
    'install-codex.sh' \
    '--docs-url' \
    '--skills-dir' \
    '--codex-home' \
    'default_tools_approval_mode' \
    '[mcp_servers.bbj-docs.tools.bbj_search]' \
    '[mcp_servers.bbj-docs.tools.bbj_fetch_page]' \
    '[mcp_servers.bbj-docs.tools.bbj_lookup]' \
    '[mcp_servers.bbj-docs.tools.bbj_reserved_word]' \
    '[mcp_servers.bbj-docs.tools.bbj_examples]' \
    'approval_mode = "approve"' \
    'bbj_check_syntax' \
    '~/.agents/skills' \
    '~/.codex/skills' \
    '/hooks' \
    'apply_patch' \
    '## Check routes' \
    '## Not covered' \
    '## Windows' \
    'Git for Windows' \
    'commandWindows' \
    'guardrail' \
    '--with-local' \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    '## 2. Enable the local check' \
    '[mcp_servers.bbj-local]' \
    '[mcp_servers.bbj-local.tools.bbj_check_syntax]' \
    '[mcp_servers.bbj-local.tools.bbj_format]' \
    '[mcp_servers.bbj-local.tools.bbj_denum]' \
    'http://127.0.0.1:5009/mcp' \
    'codex mcp remove bbj-local' \
    'BBJ_LOCAL_MCP_URL' \
    'tools/list' \
    'once per session' \
    'not compile-checked' \
    '[mcp_servers.bbj-docs.oauth]' \
    'callback_port = 47613' \
    'http://localhost:47613/callback' \
    'codex mcp login bbj-docs' \
    '## Install with the Codex plugin (recommended)' \
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
    '--sh-exe' \
    'hook exited' \
    'C:\PROGRA~1\Git\bin\sh.exe' \
    'the hosted BBj docs server' \
    'stop every Codex process' \
    '### Switch from the installer script' \
    'sh codex/install-codex.sh --remove' \
    '## Fallback: the installer script' \
    '## Add the AGENTS.md snippet (both routes)' \
    'plugins."bbj@basis-bbj".mcp_servers.bbj-docs'
  do
    need "$n" "$CODEX_PAGE" "$p"
  done
  # the client id of the example on the page is the installer's OAUTH_CLIENT_ID, read from the installer
  # (one source; layout_oauth_codex_matches_plugin ties the installer to the plugin manifest) (IN-07)
  _oid=$(sed -n 's/^OAUTH_CLIENT_ID=//p' "$REPO/codex/install-codex.sh" | head -n 1)
  if [ -n "$_oid" ]; then
    need "$n" "$CODEX_PAGE" "client_id = \"$_oid\""
  else
    gate codex_oauth_client_id FAIL "no OAUTH_CLIENT_ID line in codex/install-codex.sh"
  fi
  check_common "$n" "$CODEX_PAGE"
  check_released_wording "$n" "$CODEX_PAGE"
  forbid "$n" "$CODEX_PAGE" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$CODEX_PAGE" "$NOROUTE_SILENCE" noroute_silence
  # no text may tell users to skip the hook review (T-08-26, CODEX-05)
  forbid "$n" "$CODEX_PAGE" "$HOOK_TRUST_BYPASS" hook_trust_bypass

  # the bbj-local tool tables of the page are the installer's LOCAL_TOOLS, one list (plan 01-07)
  INSTALLER=$REPO/codex/install-codex.sh
  inst_local=$(sed -n "s/^LOCAL_TOOLS='\(.*\)'\$/\1/p" "$INSTALLER" | tr ' ' '\n' | sort)
  page_local=$(sed -n 's/^ *\[mcp_servers\.bbj-local\.tools\.\([a-z_]*\)\]$/\1/p' "$CODEX_PAGE" | sort)
  if [ -n "$inst_local" ] && [ "$inst_local" = "$page_local" ]; then
    gate codex_local_tools_single_source ok "LOCAL_TOOLS equals the bbj-local tool tables of the page ($(printf '%s\n' "$inst_local" | awk 'END { print NR }') tools)"
  else
    gate codex_local_tools_single_source FAIL "installer '$(printf '%s' "$inst_local" | tr '\n' ' ')', page '$(printf '%s' "$page_local" | tr '\n' ' ')'"
  fi

  # every installer message the page quotes is printed by the installer, on a line that is not a
  # comment, so the page cannot describe a message the installer does not print (T-01-28)
  grep -v '^[[:space:]]*#' "$INSTALLER" > "$WORK/installer.code"
  quoted_bad=0
  quoted_n=0
  for p in \
    'a bbj-ls answers at' \
    'no bbj-ls answered at' \
    'not probed: curl not found' \
    'is not a loopback http URL' \
    'registering it anyway' \
    'already registered in' \
    'added the OAuth client to' \
    'OAuth settings of its own' \
    'nothing to remove' \
    'left in place' \
    'holds more than the hook this script writes' \
    'rerun with --docs-url' \
    'pass --sh-exe PATH'
  do
    quoted_n=$((quoted_n + 1))
    grep -qF -e "$p" "$CODEX_PAGE" || { gate codex_quoted_messages_in_installer FAIL "the page does not quote: $p"; quoted_bad=1; }
    grep -qF -e "$p" "$WORK/installer.code" || { gate codex_quoted_messages_in_installer FAIL "codex/install-codex.sh does not print: $p"; quoted_bad=1; }
  done
  [ "$quoted_bad" = 1 ] || gate codex_quoted_messages_in_installer ok "$quoted_n quoted fragments, each on the page and on a non-comment installer line"

  # the plugin route comes before the installer script on the page (phase 8 D-15, D-16; plan 10-07)
  _plug=$(grep -n -F -x '## Install with the Codex plugin (recommended)' "$CODEX_PAGE" | head -n 1 | cut -d: -f1)
  _fall=$(grep -n -F -x '## Fallback: the installer script' "$CODEX_PAGE" | head -n 1 | cut -d: -f1)
  if [ -n "$_plug" ] && [ -n "$_fall" ] && [ "$_plug" -lt "$_fall" ]; then
    gate codex_plugin_route_first ok "the plugin-route heading (line $_plug) comes before the fallback heading (line $_fall)"
  else
    gate codex_plugin_route_first FAIL "plugin-route heading line '$_plug', fallback heading line '$_fall'"
  fi
fi

# ---- README: the local check, preferred over the hosted check, for two reasons (plan 01-07, D-13) ----
README=$REPO/README.md
if [ -f "$README" ]; then
  n=readme
  for p in \
    'recommended where BBjServices 26.03' \
    'preferred over the hosted check' \
    'PREFIX, classpath and config' \
    '--with-local' \
    '## Skills' \
    'once per session' \
    'codex plugin add bbj@basis-bbj' \
    'codex plugin add bbj-local@basis-bbj' \
    '| Claude Code |' \
    '| Codex plugin |' \
    '| Codex installer |' \
    'Verified on Linux, Windows and macOS' \
    'BBj 26.03' \
    'the hosted BBj docs server'
  do
    need "$n" "$README" "$p"
  done
  check_released_wording "$n" "$README"
  # the plugin commands come before the installer script in README (phase 8 D-15, D-16; plan 10-06)
  _flat=$(tr '\n' ' ' < "$README")
  _before_plugin=${_flat%%codex plugin add*}
  _before_installer=${_flat%%install-codex.sh*}
  if [ "${#_before_plugin}" -lt "${#_flat}" ] && [ "${#_before_installer}" -lt "${#_flat}" ] \
    && [ "${#_before_plugin}" -lt "${#_before_installer}" ]; then
    gate "${n}_codex_plugin_first" ok "the first 'codex plugin add' comes before the first 'install-codex.sh'"
  else
    gate "${n}_codex_plugin_first" FAIL "README names the installer script before the plugin commands, or lacks one of them"
  fi
  forbid "$n" "$README" "$HOOK_TRUST_BYPASS" hook_trust_bypass
  forbid "$n" "$README" 'until this release|release is merged to it|this release is on github' release_time_caveat
  forbid "$n" "$README" "$LOCAL_ABOVE_BBJCPL" local_not_above_bbjcpl
  forbid "$n" "$README" "$NOROUTE_SILENCE" noroute_silence
fi

# ---- installer output: the Known gaps line names the no-route notice (plan 02-03, HOOK-02) ----
if [ -f "$REPO/codex/install-codex.sh" ]; then
  n=installer
  need "$n" "$REPO/codex/install-codex.sh" 'once per session'
  forbid "$n" "$REPO/codex/install-codex.sh" "$NOROUTE_SILENCE" noroute_silence
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
