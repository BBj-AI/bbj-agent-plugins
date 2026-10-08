#!/bin/sh
# tests/test_install_pages.sh -- keeps the install pages honest (plan 19-07, PLUG-05).
#
# For every docs/install-*.md that exists:
#   - a required-phrase list per page (what the page must state),
#   - forbidden claims: the go-live host as a default, and "subagent edits are not covered",
#   - every relative Markdown link in docs/*.md, README.md and CHANGELOG.md resolves,
#   - every "claude plugin <subcommand>" line in the Claude page's fenced blocks names a real
#     subcommand of the installed CLI (claude plugin <words> --help exits 0); skipped when
#     claude is not installed.
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
}

# ---- Claude Code page ----
if [ -f "$CLAUDE_PAGE" ]; then
  n=claude
  for p in \
    'claude plugin install bbj@basis-bbj' \
    'claude plugin marketplace add BBj-AI/bbj-agent-plugins' \
    'docs_url' \
    'bbj_home' \
    'https://bbj-mcp.basis-europe.eu/mcp' \
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
    'not yet been run on Windows' \
    '`bbj-local reported' \
    '`bbjcpl reported'
  do
    need "$n" "$CLAUDE_PAGE" "$p"
  done
  check_common "$n" "$CLAUDE_PAGE"

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
    'UNRUN' \
    'install-codex.sh' \
    '--docs-url' \
    '--skills-dir' \
    '--codex-home' \
    'default_tools_approval_mode' \
    '~/.agents/skills' \
    '~/.codex/skills' \
    '/hooks' \
    'apply_patch' \
    '## Check routes' \
    '## Not covered' \
    '## Windows' \
    'Git for Windows' \
    'commandWindows' \
    'guardrail'
  do
    need "$n" "$CODEX_PAGE" "$p"
  done
  check_common "$n" "$CODEX_PAGE"
  # the Codex route is unverified: the page must not say it was verified or tested on Codex
  forbid "$n" "$CODEX_PAGE" '(was|has been|is) (verified|tested) (on|with) (a )?Codex' codex_verified_claim
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
