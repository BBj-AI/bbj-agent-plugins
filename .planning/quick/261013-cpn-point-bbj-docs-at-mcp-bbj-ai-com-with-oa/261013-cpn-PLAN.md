---
phase: quick-261013-cpn
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - plugins/bbj/.mcp.json
  - tests/test_layout.py
  - tests/test_claude_plugin.sh
  - codex/install-codex.sh
  - tests/fake-bin/codex
  - tests/test_install_codex.sh
  - docs/install-claude-code.md
  - docs/install-codex.md
  - tests/test_install_pages.sh
  - README.md
  - CHANGELOG.md
autonomous: true
requirements: [261013-cpn-R1, 261013-cpn-R2, 261013-cpn-R3]

estimate:
  tokens: 155000
  raw_tokens: 155000
  tasks: 3
  confidence: low

must_haves:
  truths:
    - "Claude Code: the bbj-docs entry of plugins/bbj/.mcp.json carries oauth.clientId oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t and oauth.callbackPort 47613; claude mcp get plugin:bbj:bbj-docs in a throwaway configuration reports client_id configured and callback_port 47613; claude plugin validate --strict plugins/bbj passes with no warning (R1)"
    - "The default docs_url is https://mcp.bbj-ai.com/mcp in the bbj plugin and in the Codex installer; this was already true before the plan and gates layout_user_config_docs_url and default_url_equals_plugin keep proving it (R2)"
    - "Codex: every install the installer finishes (codex on PATH or not, a fresh config.toml, a managed block, an existing registration, a CRLF or symlinked config.toml) leaves exactly one [mcp_servers.bbj-docs.oauth] table with client_id, callback_url http://localhost:47613/callback and callback_port 47613; tomllib and the real Codex CLI load it, and a rerun leaves config.toml byte-identical (R3)"
    - "The installer never hands the client to codex mcp add and never starts a sign-in; an OAuth entry of the user's own for bbj-docs is left byte-identical and named in one output line; bbj-local never gets an OAuth table"
    - "When codex mcp add writes the table and then exits with an error (what Codex CLI 0.162.1 does against the hosted server), the installer says so instead of claiming it writes a block it never writes"
    - "The install pages, README and CHANGELOG tell the user about the one-time sign-in (port 47613; /mcp in Claude Code; codex mcp login bbj-docs in Codex), and sh tests/run.sh ends with fail=0"
  artifacts:
    - path: "plugins/bbj/.mcp.json"
      provides: "bbj-docs HTTP entry with the pre-registered OAuth client"
      contains: "\"callbackPort\": 47613"
    - path: "codex/install-codex.sh"
      provides: "OAuth constants, analyze() oauth state, print_oauth, the table insert in sync_server, the sign-in step line"
      contains: "OAUTH_CLIENT_ID=oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"
    - path: "tests/test_install_codex.sh"
      provides: "oauth_ gates and the extended existing gates"
      contains: "oauth_user_forms_kept"
    - path: "tests/test_layout.py"
      provides: "layout_bbj_mcp with the oauth object and layout_oauth_codex_matches_plugin"
      contains: "oauth_codex_matches_plugin"
    - path: "tests/test_claude_plugin.sh"
      provides: "mcp_docs_oauth and mcp_docs_answers"
      contains: "mcp_docs_oauth"
    - path: "docs/install-codex.md"
      provides: "the OAuth table in the What it leaves block and the sign-in sentence"
      contains: "[mcp_servers.bbj-docs.oauth]"
  key_links:
    - from: "tests/test_layout.py"
      to: "plugins/bbj/.mcp.json and codex/install-codex.sh"
      via: "one client id and one port in both clients (layout_oauth_codex_matches_plugin)"
      pattern: "OAUTH_CLIENT_ID="
    - from: "codex/install-codex.sh analyze()"
      to: "codex/install-codex.sh state() and sync_server()"
      via: "the analysis line oauth=missing|ours|other"
      pattern: "oauth="
    - from: "tests/test_install_pages.sh"
      to: "codex/install-codex.sh"
      via: "installer messages quoted by docs/install-codex.md must be printed on a non-comment installer line"
      pattern: "OAuth settings of its own"
---

<objective>
Point the bbj-docs MCP server at the hosted instance with the pre-registered OAuth client, in Claude Code and in Codex.

The user's three changes, as requirement IDs of this quick task:
- 261013-cpn-R1: set oauth.clientId to oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t and oauth.callbackPort to 47613 on the bbj-docs entry.
- 261013-cpn-R2: change the default docs_url to https://mcp.bbj-ai.com/mcp. This is ALREADY SATISFIED: plugins/bbj/.claude-plugin/plugin.json userConfig.docs_url.default and DEFAULT_DOCS_URL in codex/install-codex.sh (line 82) both hold https://mcp.bbj-ai.com/mcp (commit 3c75f4f). No value is edited. Gates layout_user_config_docs_url (tests/test_layout.py) and default_url_equals_plugin (tests/test_install_codex.sh) prove it in every task's verify. The plugin.json description wording ("pre-production instance until the go-live release") is out of scope and stays.
- 261013-cpn-R3: make the same change in the Codex config: the installer writes the TOML table Codex reads, [mcp_servers.bbj-docs.oauth] with client_id, callback_url = "http://localhost:47613/callback" and callback_port = 47613.

Purpose: the hosted docs server now requires an OAuth sign-in and accepts only this pre-registered client and only callback port 47613 (dynamic client registration is disabled). Without the settings neither client can sign in. At plan time this was also the one FAIL of the suite (mcp_docs_connected: "Needs authentication"; .planning/phases/07-test-hardening-and-release-prep/07-05-SUMMARY.md says it must be fixed before the release run).

Output: the oauth object in plugins/bbj/.mcp.json; OAuth handling in codex/install-codex.sh; new and extended gates; updated install pages, README and CHANGELOG; sh tests/run.sh with fail=0.
</objective>

<execution_context>
@~/.claude-shared/dot-claude/gsd-core/workflows/execute-plan.md
@~/.claude-shared/dot-claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@.claude/CLAUDE.md
@plugins/bbj/.mcp.json
@codex/install-codex.sh

Facts verified at plan time (2026-10-13, this machine). Do not re-research them:
- Claude Code CLI 2.1.296 is on PATH. A scratch copy of the plugin with the target .mcp.json passed `claude plugin validate --strict plugins/bbj` ("Validation passed", no warning). Installed into a throwaway CLAUDE_CONFIG_DIR, `claude mcp get plugin:bbj:bbj-docs` printed `OAuth: client_id configured, callback_port 47613`, and `claude mcp list` printed `plugin:bbj:bbj-docs: https://mcp.bbj-ai.com/mcp (HTTP) - ! Needs authentication`.
- Codex CLI 0.162.1 is on PATH, so tests/test_install_codex.sh runs real_parse and real_codex_install with it. `codex mcp get bbj-docs` loads a config.toml that holds the three-line oauth table and prints `url: https://mcp.bbj-ai.com/mcp` (exit 0). So real_parse keeps working on every config that carries the table.
- Codex reads: `[mcp_servers.bbj-docs.oauth]` with `client_id = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"`, `callback_url = "http://localhost:47613/callback"` and `callback_port = 47613`. Both callback keys are needed. callback_port alone makes Codex append a random path to a 127.0.0.1 redirect, which the auth server rejects. callback_url alone does not fix the listener port. The auth server rejects every port except 47613 ("Callback URL mismatch").
- `codex mcp add NAME --url URL --oauth-client-id ID` starts an interactive OAuth sign-in and blocks, so the installer must never use it. A plain `codex mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp` writes `[mcp_servers.bbj-docs]` plus the url, prints "Detected OAuth support. Starting OAuth flow…", fails with "dynamic client registration is disabled" and exits 1 within a second. Today the installer then prints "codex mcp add did not succeed; writing the block to config.toml instead", although it writes no block: the table Codex wrote is found on the refresh.
- Baseline `sh tests/run.sh` at plan time: `SUMMARY: ok=809 fail=1 skip=0`, 117 s. The one FAIL is `mcp_docs_connected`. ShellCheck 0.11.0 is installed.
- The URL literal http://localhost:47613/callback in codex/install-codex.sh passes tests/test_static_guards.sh (codex/*.sh URL literals are not scanned; loopback anyway).
- No existing gate name starts with `oauth_`. tests/test_claude_plugin.sh uses free-form gate names. `mcp_docs_` is printed only there.

Conventions (from .claude/CLAUDE.md): POSIX sh, no set -e, `[ ]` tests only, printf for data, underscore-prefixed script temporaries, `> /dev/null` with the space, comments explain why and cite the ID ("quick 261013-cpn"), gate lines `gate NAME ok|FAIL|skip DETAIL`, Python stdlib only with %-formatting and no f-strings. Do not bump versions, do not rename skills or plugins, do not touch plugins/bbj/scripts/bbj-check.sh.
</context>

<tasks>

<task type="tracer">
  <name>Task 1 (tracer): OAuth client on the Claude Code plugin, end to end from .mcp.json to claude mcp get</name>
  <files>plugins/bbj/.mcp.json, tests/test_layout.py, tests/test_claude_plugin.sh</files>
  <precondition>The claude CLI is on PATH (`command -v claude`; 2.1.296 at plan time). Without it, tests/test_claude_plugin.sh only prints skip gates and this tracer proves nothing.</precondition>
  <read_first>plugins/bbj/.mcp.json, tests/test_layout.py (lines 1-80), tests/test_claude_plugin.sh (whole file, about 120 lines)</read_first>
  <action>
1. plugins/bbj/.mcp.json (R1): add an `oauth` object to the bbj-docs entry, after `url`: key `clientId` with the string value oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t, and key `callbackPort` with the JSON number 47613 (a number, not a string). Keep `type` and `url` byte for byte, use 2-space JSON indentation, put one key per line, end the file with a newline. No `clientSecret`: this is a public client and no secret exists. Do not write the host name mcp.bbj-ai.com in this file; gate layout_docs_host_single_source allows it only in plugin.json.

2. R2 needs no edit (see objective). Do not touch plugins/bbj/.claude-plugin/plugin.json.

3. tests/test_layout.py:
   - Add the module constants `OAUTH_CLIENT_ID = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"` and `OAUTH_PORT = 47613` next to DOCS_HOST.
   - Change gate bbj_mcp so the servers dict must equal: bbj-docs with type "http", url "${user_config.docs_url}" and oauth {"clientId": OAUTH_CLIENT_ID, "callbackPort": OAUTH_PORT}. Dict equality also rejects a string "47613" and any extra key.
   - Update the comment above the gate to say the entry carries the pre-registered OAuth client (quick 261013-cpn).
   - Add one line to the module docstring naming quick 261013-cpn.

4. tests/test_claude_plugin.sh, section "3. the plugin's docs server":
   a. New gate `mcp_docs_oauth`, placed before the curl reachability `if`, because it reads configuration. Run `_get=$(cd "$WORK" && cc mcp get plugin:bbj:bbj-docs 2>&1)`. Report ok when one line of `_get` matches `oauth` case-insensitively and also holds `client_id` and `callback_port 47613`. The FAIL detail is the first 8 lines of `_get`, flattened with tr.
   b. Replace gate `mcp_docs_connected` by `mcp_docs_answers`. Keep the same reachability guard, the same `cc mcp list` call and the same skip branch. Report ok when the line naming `https://$DOCS_HOST/mcp` matches `connected` or `needs authentication` (grep -i -e ... -e ...) and does not match `fail` (grep -i -v). The ok detail names the status seen.
   c. Add a why-comment above `mcp_docs_answers`. The server asks for an OAuth sign-in, so a throwaway configuration that never signed in shows "Needs authentication": the server answered with its OAuth challenge. Before quick 261013-cpn this was the suite's one FAIL. `mcp_docs_oauth` now proves that the client settings reach Claude Code.
   d. Rewrite item 3 of the header comment the same way.
   Shell conventions: `[ ]`, printf for data, underscore temporaries.

5. Commit: `feat(261013-cpn): pre-registered OAuth client on the bbj-docs entry of the Claude Code plugin`.
  </action>
  <verify>
    <automated>python3 -I tests/test_layout.py && claude plugin validate --strict plugins/bbj && sh tests/test_claude_plugin.sh && sh tests/test_install_codex.sh | grep -F 'gate default_url_equals_plugin ok' && sh tests/run.sh</automated>
  </verify>
  <done>Gates layout_bbj_mcp, layout_user_config_docs_url and layout_docs_host_single_source are ok. validate_plugins_bbj is ok, with no warning line. mcp_docs_oauth is ok. mcp_docs_answers is ok, or skip when the host is unreachable. default_url_equals_plugin is ok (R2 unchanged). `sh tests/run.sh` prints `SUMMARY:` with `fail=0` and exits 0.</done>
</task>

<task type="auto">
  <name>Task 2: Codex installer writes, keeps and reports the OAuth table of bbj-docs</name>
  <files>codex/install-codex.sh, tests/fake-bin/codex, tests/test_install_codex.sh, tests/test_layout.py</files>
  <read_first>codex/install-codex.sh (whole file), tests/fake-bin/codex, tests/lib.sh (gate, count helpers, finish), tests/test_install_codex.sh lines 1-360, 505-760, 990-1095 and 1476-1531</read_first>
  <action>
A. codex/install-codex.sh (R3; R1 for Codex). Keep every existing behavior of bbj-docs and bbj-local and add only this:

A1. Constants. After the DOCS_TOOLS line, add three literal lines, one value each (tests/test_layout.py reads them): `OAUTH_CLIENT_ID=oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`, `OAUTH_CALLBACK_PORT=47613`, `OAUTH_CALLBACK_URL=http://localhost:47613/callback`. Above them, a why-comment citing quick 261013-cpn:
   - the hosted docs server's auth server accepts only this pre-registered client and only a callback on port 47613;
   - Codex needs both callback keys: the port alone makes Codex CLI 0.162.1 append a random path to a 127.0.0.1 redirect, which the auth server rejects, and the url alone does not fix the listener port.

A2. Header comment.
   - Step 1 gains one factual sentence: the script writes `[mcp_servers.bbj-docs.oauth]` with client_id, callback_url and callback_port of that client, right after the bbj-docs table body (inside the managed block when there is one). It never goes through codex mcp add, whose client-id option starts the sign-in at once and waits for a browser. An OAuth entry of the user's own for bbj-docs is left alone and named.
   - Change "An existing table only gains the missing tool tables" to also name the OAuth table.
   - Step 5 also names the sign-in step.
   - Exit codes do not change.

A3. Server globals. Add `srv_oauth_id`, `srv_oauth_url` and `srv_oauth_port`, and extend the server-parameters comment.
   - use_docs sets them from the three constants.
   - use_local sets all three empty. bbj-local is a loopback server without sign-in, so nothing about OAuth is ever written, reported or printed for it.

A4. analyze().
   - Pass `-v oid="$srv_oauth_id" -v ourl="$srv_oauth_url" -v oport="$srv_oauth_port"` to its awk.
   - In BEGIN, add:
     - `oauth_re = "^\\[mcp_servers\\." key "\\.oauth\\][ \t]*(#.*)?$"`
     - `okey_re = "^[ \t]*[\"" sq "]?oauth[\"" sq "]?[ \t]*[.=]"`
     - `want_id = "client_id = \"" oid "\""`
     - `want_url = "callback_url = \"" ourl "\""`
     - `want_port = "callback_port = " oport`
   - Header chain: insert a branch after the tool_re branch and before the def_hdr_re branch: `else if (line ~ oauth_re) { sect = "oauth"; mention = 1; oauth_n++ }`. `mention = 1` keeps today's result: without the server table, this header is still a form the script does not edit, so exit 3.
   - Set `oauth_odd = 1` in three places, each when the line matches `/oauth/` or okey_re as stated:
     - in the def_hdr_re branch, when the line matches `/oauth/` (quoted, spaced or nested oauth headers);
     - in the key-mention branch for dotted and [mcp_servers] keys, when the line matches `/oauth/`;
     - in the `sect == "main"` branch, when the line matches okey_re (an inline `oauth = {...}` or a dotted `oauth.client_id` in the server table).
   - New body branch `else if (sect == "oauth" && line !~ /^[ \t]*$/)`:
     - copy the line to `t` and strip trailing blanks;
     - when t equals want_id, want_url or want_port, set o_id, o_url or o_port; a second occurrence of the same line sets oauth_extra;
     - any other line sets oauth_extra;
     - a `client_id` key line (`/^[ \t]*client_id[ \t]*=/`) sets `ocid = val(line)`.
     - Comment lines are already skipped by the enclosing comment test.
   - END:
     - `ostate = "missing"`;
     - when `oauth_n > 0 || oauth_odd`, set `ostate = (oauth_n == 1 && !oauth_odd && !oauth_extra && o_id && o_url && o_port) ? "ours" : "other"`;
     - print `oauth=` ostate and `oauth.client_id=` ocid.
   - Document both new output lines in the comment above analyze(). Leave the main/tool/tfor/mention/dstate/anytool logic untouched, so every bbj-local and foreign-form gate keeps its result.

A5. state(): set `oauth_state=$(an oauth)`, then `oauth_miss=0`, then `if [ -n "$srv_oauth_id" ] && [ "$oauth_state" = missing ]; then oauth_miss=1; fi`.

A6. Printing.
   - New `print_oauth`: returns at once when srv_oauth_id is empty. Otherwise it prints, with printf, a blank line, `[mcp_servers.SRV.oauth]`, `client_id = "ID"`, `callback_url = "URL"` and `callback_port = PORT`.
   - print_block prints the server table and url line, then print_oauth, then print_tools. This is the hand-merge output of the foreign case.
   - In the tools_foreign branch of sync_server, call print_oauth after print_tools when oauth_miss is 1. config.toml is not modified there, so the user adds the table by hand.

A7. sync_server().
   a. need_change is also 1 when oauth_miss is 1, so the one-time config.toml.bbj-backup is written before the table goes into an existing file.
   b. Keep the line `codex mcp add "$srv" --url "$srv_url"` byte for byte. Never add a client-id option, and never call `codex mcp login`. In its failure branch, call `refresh` first.
      - When `$(an main)` is 1 (codex wrote the table, then failed), say exactly: `$srv: codex mcp add wrote the $srv table, then exited with an error (Codex CLI 0.162.1 does so when it tries to register itself with an OAuth server that takes only a pre-registered client); the table is kept and completed below`
      - Otherwise keep today's "did not succeed; writing the block to config.toml instead" line unchanged.
   c. In the block after the comment "what the user chose stays" (foreign = 0 and main = 1), handle srv_oauth_id set and oauth_state = other:
      - set `_cid=$(an oauth.client_id)`;
      - set `_cidtxt` to empty, or to ` (client_id $_cid)` when _cid is set;
      - say exactly one line: `$srv: $config holds OAuth settings of its own for $srv$_cidtxt; left as is (the pre-registered client is client_id $srv_oauth_id with callback $srv_oauth_url)`.
      - pending is not set and the exit code does not change: like a tool's own approval_mode, this is the user's choice.
   d. Insert pass.
      - The condition that starts the insert pass gains `|| [ "$oauth_miss" = 1 ]` inside its braces.
      - Its awk gains `-v oauth_add="$oauth_miss" -v oid="$srv_oauth_id" -v ourl="$srv_oauth_url" -v oport="$srv_oauth_port"`.
      - When oauth_add is 1, flush_main prints first, BEFORE the missing tool tables: a blank line, `[mcp_servers.SRV.oauth]`, `client_id = "OID"`, `callback_url = "OURL"` and `callback_port = OPORT`. Each line is followed by cr, like the tool lines.
      - The extra-blank rule becomes `if ((n > 0 || oauth_add) && atheader && !hasblank)`.
      - These four lines must be byte-equal to the want_* strings of analyze(), so a rerun reads them as ours and leaves config.toml byte-identical.
      - The write stays in place (`cat "$tmp" > "$config"`), so a symlink and the file mode survive, and CR handling follows config_cr.
   e. After a successful write, when oauth_miss was 1, say exactly: `$srv: added the OAuth client to $config: [mcp_servers.$srv.oauth] with client_id $srv_oauth_id, callback_url $srv_oauth_url and callback_port $srv_oauth_port`
   f. Planner decision: the table is written for every `--docs-url`. The Claude Code entry also carries oauth whatever docs_url says.

A8. Step 5. After the two trust-step lines and before the blank line that leads into "Known gaps:", say exactly: `Sign-in step: the docs server bbj-docs asks for an OAuth sign-in (pre-registered client $OAUTH_CLIENT_ID). Run codex mcp login bbj-docs once; a browser opens, and the sign-in returns to $OAUTH_CALLBACK_URL, so port $OAUTH_CALLBACK_PORT must be free while you sign in.`

B. tests/fake-bin/codex: replace the final `exit 0` with `exit "${FAKE_CODEX_EXIT:-0}"`. Extend the header comment: FAKE_CODEX_EXIT sets the exit code after the write, the way the real Codex CLI 0.162.1 exits 1 after it wrote the table when its own OAuth sign-in fails (quick 261013-cpn).

C. tests/test_install_codex.sh

C0. Header comment: add one sentence naming quick 261013-cpn and the oauth_ gates.

C1. After DEFAULT_URL, add these constants:
   - `OAUTH_ID=oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t`
   - `OAUTH_HDR='[mcp_servers.bbj-docs.oauth]'`
   - `OAUTH_L1="client_id = \"$OAUTH_ID\""`
   - `OAUTH_L2='callback_url = "http://localhost:47613/callback"'`
   - `OAUTH_L3='callback_port = 47613'`
   Then add these helpers, each with a usage comment:
   - `oauth_once FILE`: OAUTH_HDR, OAUTH_L1, OAUTH_L2 and OAUTH_L3 each occur exactly once (count helper).
   - `oauth_inside FILE`: prints how many OAUTH_HDR lines lie between the bbj-docs managed markers (awk, shaped like the existing `inside`).
   - `oauth_parsed FILE`: python3 -I with tomllib; returns 0 when mcp_servers.bbj-docs.oauth equals {"client_id": OAUTH_ID, "callback_url": "http://localhost:47613/callback", "callback_port": 47613}.
   - `oauth_added`: prints the four lines, each prefixed with `> `, for diff expectations.

C2. docs_done: write a blank line and the four OAuth lines between the url line and the first tool table, and update its comment. The fixture means "the docs pass changes nothing", which now includes the OAuth table. Without this change, every byte-identity gate of the local and probe sections fails (local_user_value_kept, local_kept_without_flag, local_markers_*, probe_never_changes_exit and others), because the docs pass would add the table.

C3. Extend these existing gates. Make each stronger, never weaker:
   - existing_table_gains_tools: cfg.expected also holds `oauth_added` (sorted together with the tool lines). The ok text names the OAuth table.
   - foreign_toml_form: stdout also holds OAUTH_HDR, OAUTH_L1, OAUTH_L2 and OAUTH_L3 as whole lines (grep -Fx).
   - foreign_tool_forms: stdout also holds the four lines as whole lines. These fixtures have no OAuth table and config.toml is not modified, so the table is printed to add by hand.
   - approval_key_keeps_symlink_and_mode: the link target also passes oauth_once.
   - crlf_config_stays_crlf: every form also holds OAUTH_HDR followed by a carriage return exactly once. The docsonly form also passes `same_after_rerun "$NO_CODEX" 0`: a CRLF file reads its own table as ours.
   - real_codex_install: also oauth_once, and stdout does not hold `writing the block to config.toml instead`.

C4. Add these new gates. The prefix `oauth_` is unused. Each gate prints one ok line or a FAIL with detail:
   - oauth_fresh_table: in the first case, directly after first_tools_tables and before the second run overwrites $WORK/out. Conditions:
     - oauth_once;
     - oauth_parsed when HAVE_TOML is 1;
     - E_LOG holds exactly one line, and that line is `mcp add bbj-docs --url https://mcp.bbj-ai.com/mcp`;
     - stdout holds `added the OAuth client to` and `codex mcp login bbj-docs`.
   - oauth_managed_block: in the nocodex case, after managed_block_tools_tables and before its rerun. Conditions: oauth_once; oauth_inside prints 1; oauth_parsed when HAVE_TOML is 1.
   - oauth_upgrade_adds_table: two forms.
     - Form managed is the block the previous installer wrote without codex: the begin marker, `[mcp_servers.bbj-docs]`, `url = "$DEFAULT_URL"`, the five tool tables with approve, the end marker. Run it with NO_CODEX.
     - Form plain: `model = "x"`, the docs table at https://example.invalid/mcp with the five tool tables approved, then `[mcp_servers.other]` with its url. Run it with WITH_CODEX.
     - Conditions for each form:
       - exit 0;
       - diff removes nothing;
       - the added non-blank lines, sorted, equal `oauth_added` sorted;
       - oauth_once;
       - the managed form also gets oauth_inside = 1;
       - the backup equals the original;
       - stdout holds `added the OAuth client to`;
       - the codex log is empty;
       - when HAVE_TOML is 1, tsum equals five_expected of the form's url, and oauth_parsed passes;
       - same_after_rerun with the form's PATH and 0.
     - note_cfg and real_parse each config.
   - oauth_user_forms_kept: five forms. The base is the docs table at https://example.invalid/mcp with all five tool tables approved.
     - own: an `[mcp_servers.bbj-docs.oauth]` table with `client_id = "my-own-client"` and `callback_port = 5555`.
     - port: that table with OAUTH_L1, OAUTH_L2 and `callback_port = 5555`.
     - inline: `oauth = { client_id = "my-own-client" }` directly after the url line.
     - dotted: `oauth.client_id = "my-own-client"` directly after the url line.
     - quoted: an `[mcp_servers.bbj-docs."oauth"]` table with `client_id = "my-own-client"`.
     - Conditions for each form:
       - exit 0;
       - config.toml byte-identical;
       - no backup;
       - the codex log is empty;
       - exactly one stdout line holds `OAuth settings of its own`;
       - no stdout line holds `added the OAuth client to`;
       - stdout holds `bbj-docs: already registered in`;
       - when HAVE_TOML is 1, the file parses.
     - The own form's stdout also holds `client_id my-own-client`.
     - No real_parse for these forms: they are the user's tables, not configs this script wrote.
   - oauth_codex_add_error_after_write: run `FAKE_CODEX_EXIT=1; export FAKE_CODEX_EXIT`, then a fresh newenv, then run_inst with WITH_CODEX, then `unset FAKE_CODEX_EXIT` (restore the global). Conditions:
     - exit 0;
     - E_LOG is exactly the mcp add line;
     - config.toml holds `[mcp_servers.bbj-docs]` once and no begin marker;
     - oauth_once;
     - five approvals;
     - stdout holds `then exited with an error`;
     - stdout does not hold `writing the block to config.toml instead`.
     Then note_cfg and real_parse.
   - oauth_never_for_local: after local_check_tools_only_in_local_tables. No file listed in local.list or written.list holds `bbj-local.oauth`, and none holds OAUTH_HDR more than once.
   - oauth_codex_never_logs_in: placed before the real-codex block. Across `"$WORK"/*/codex.log`, at least one line starts with `mcp add bbj-docs --url`, and no line matches `oauth` or `login` case-insensitively.

C5. Run `sh tests/test_install_codex.sh`. If any other gate fails, extend its expectation to cover the OAuth table. Never drop or loosen a condition. List each such change in the SUMMARY.

D. tests/test_layout.py: new gate `oauth_codex_matches_plugin`, printed as `gate layout_oauth_codex_matches_plugin`.
   - Read codex/install-codex.sh under ROOT and take the values of the lines that start with `OAUTH_CLIENT_ID=`, `OAUTH_CALLBACK_PORT=` and `OAUTH_CALLBACK_URL=`.
   - Report ok when:
     - the id equals OAUTH_CLIENT_ID and the clientId of plugins/bbj/.mcp.json;
     - the port equals `str(OAUTH_PORT)` and the callbackPort;
     - the url equals `"http://localhost:%d/callback" % OAUTH_PORT`.
   - Parse with startswith (no new import) and use %-formatting.

E. Commit: `feat(261013-cpn): Codex installer writes the bbj-docs OAuth client table`.
  </action>
  <verify>
    <automated>python3 -I tests/test_layout.py && sh tests/test_install_codex.sh && sh tests/test_static_guards.sh && shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh tests/fake-bin/codex && sh tests/run.sh</automated>
  </verify>
  <done>
- New gates ok: oauth_fresh_table, oauth_managed_block, oauth_upgrade_adds_table, oauth_user_forms_kept, oauth_codex_add_error_after_write, oauth_never_for_local, oauth_codex_never_logs_in, layout_oauth_codex_matches_plugin.
- Unchanged-behavior gates still ok: second_run_idempotent, managed_block_idempotent, default_url_equals_plugin, every local_ and probe_ gate.
- Extended gates ok: existing_table_gains_tools, foreign_toml_form, foreign_tool_forms, approval_key_keeps_symlink_and_mode, crlf_config_stays_crlf, real_codex_install.
- real_codex_parses_configs ok, with the real Codex CLI 0.162.1.
- shellcheck prints nothing.
- `sh tests/run.sh` prints `fail=0` and exits 0.
  </done>
</task>

<task type="auto">
  <name>Task 3: Install pages, README and CHANGELOG describe the sign-in; full suite green</name>
  <files>docs/install-claude-code.md, docs/install-codex.md, tests/test_install_pages.sh, README.md, CHANGELOG.md</files>
  <read_first>docs/install-claude-code.md, docs/install-codex.md, tests/test_install_pages.sh (lines 60-230), README.md, CHANGELOG.md (lines 1-40), and the installer messages written in Task 2 (grep -n 'OAuth' codex/install-codex.sh)</read_first>
  <action>
Write plain, factual sentences, with no claim that was not observed at plan time. The Codex page must not contain "was/has been/is verified/tested on/with Codex" (forbid codex_verified_claim). The newest CHANGELOG entry must not contain the placeholder words test_release_text.py rejects. Do not touch the CHANGELOG "Tested against" and "Not run" sections, or the three Upgrading quotes: they record the 2026-10-12 release run, and gates upgrade_quotes and not_run pin them.

1. docs/install-claude-code.md
   - Requirements: the network bullet also says that a browser is needed for the docs server's one-time sign-in.
   - "What you get", the bbj-docs bullet, gains these sentences:
     - The docs server asks for an OAuth sign-in. The plugin brings the pre-registered client (`oauth.clientId` in its `.mcp.json`) and the callback port 47613.
     - Claude Code receives the sign-in at `http://localhost:47613/callback`, so port 47613 must be free while you sign in.
     - Until you sign in, `claude mcp list` shows `plugin:bbj:bbj-docs` with `Needs authentication`. Run `/mcp` in Claude Code, choose `plugin:bbj:bbj-docs` and sign in, in the browser that opens.

2. docs/install-codex.md
   - Requirements: a browser for the one-time sign-in to the docs server.
   - Section "What it does", step 1:
     - "It then approves the five docs tools by name" also names adding the docs server's OAuth client.
     - The "What it leaves is:" TOML block gains, after the url line and a blank line, `[mcp_servers.bbj-docs.oauth]`, `client_id = "oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t"`, `callback_url = "http://localhost:47613/callback"` and `callback_port = 47613`, before the tool tables. That is the order the installer writes.
     - After the block, add a short paragraph:
       - this table is the pre-registered OAuth client of the docs server, which accepts no other client and only the callback on port 47613;
       - the first use of `bbj-docs` opens a browser login, and `codex mcp login bbj-docs` does it on demand; port 47613 must be free while you sign in;
       - the installer adds this table itself and does not pass the client to `codex mcp add`, which would start the sign-in during the install;
       - with `codex` on PATH, Codex CLI 0.162.1's `codex mcp add` writes the table and then exits with an error, because the server refuses its self-registration; the installer keeps that table and completes it.
     - Change "the installer only adds the missing tool tables to it" so it also names the OAuth table. Quote the installer message fragment `added the OAuth client to`.
     - Add: an OAuth entry of your own for `bbj-docs` (another client, another port, or any other form) is left as it is, and the output says `OAuth settings of its own`.
   - Step 6: "Prints the AGENTS.md snippet, the trust step, the sign-in step and the known gaps."

3. tests/test_install_pages.sh: add required phrases, never removing one.
   - Claude page list: `47613`, `Needs authentication`, `oauth.clientId`.
   - Codex page list: `[mcp_servers.bbj-docs.oauth]`, `callback_port = 47613`, `http://localhost:47613/callback`, `codex mcp login bbj-docs`.
   - The quoted-message loop (codex_quoted_messages_in_installer) gains `added the OAuth client to` and `OAuth settings of its own`. Its ok text "six quoted fragments" becomes "eight quoted fragments".
   - Add one header-comment line naming quick 261013-cpn.

4. README.md: after the paragraph on `docs_url`, add one paragraph. The docs server asks for a one-time OAuth sign-in with the pre-registered client that the plugin and the Codex installer configure (callback port 47613): `/mcp` in Claude Code, `codex mcp login bbj-docs` in Codex.

5. CHANGELOG.md: under `## 0.2.0`, in the top list after the Codex installer bullet, add one bullet:
   - `bbj-docs` signs in with OAuth through the docs server's pre-registered client;
   - the `bbj` plugin's `.mcp.json` sets `oauth.clientId` and `oauth.callbackPort` 47613;
   - the Codex installer writes `[mcp_servers.bbj-docs.oauth]` with `client_id`, `callback_url = "http://localhost:47613/callback"` and `callback_port = 47613`; a rerun adds it to an existing registration, and an OAuth entry of your own is left as it is;
   - sign in once: `/mcp` in Claude Code, `codex mcp login bbj-docs` in Codex.
   Do not change the version.

6. Run the full suite and shellcheck. Record the `SUMMARY:` line in the quick SUMMARY.

7. Commit: `docs(261013-cpn): install pages, README and CHANGELOG describe the bbj-docs OAuth sign-in`.
  </action>
  <verify>
    <automated>sh tests/test_install_pages.sh && python3 -I tests/test_release_text.py && python3 -I tests/test_layout.py && sh tests/test_install_codex.sh | grep -F 'gate tools_list_single_source ok' && shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh tests/test_install_pages.sh tests/test_claude_plugin.sh tests/fake-bin/codex && sh tests/run.sh</automated>
    <human-check>Optional, by the user after the phase: `/mcp` in Claude Code and `codex mcp login bbj-docs` each open a browser, the sign-in succeeds against port 47613, and bbj-docs then lists its tools.</human-check>
  </verify>
  <done>
- The new claude_has_*, codex_has_* and codex_quoted_messages_in_installer gates are ok.
- These gates stay ok: release_changelog_heading, release_changelog_sections, release_changelog_leftovers, release_upgrade_quotes, release_not_run, release_codex_version_single, codex_forbids_codex_verified_claim, tools_list_single_source and the link_ gates.
- shellcheck prints nothing.
- `sh tests/run.sh` prints `SUMMARY: ok=N fail=0 skip=0` and exits 0. N is above the baseline 809 because of the new gates.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| plugin manifest -> Claude Code | plugins/bbj/.mcp.json is read by the host; the oauth object decides which client and callback Claude Code uses |
| installer -> user's config.toml | codex/install-codex.sh edits a file the user owns, which may be hand-written, CRLF or a symlink |
| installer -> codex CLI | a subprocess whose output goes to /dev/null; an interactive sign-in there would hang the install unseen |
| browser/auth server -> localhost:47613 | the OAuth redirect lands on a loopback listener of the client |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-261013-cpn-01 | Spoofing | OAuth callback http://localhost:47613/callback (both clients) | low | accept | The redirect URI is fixed by the auth server's registration (port 47613, loopback only). The plan writes only that loopback callback, and the pages tell the user the port must be free while signing in. A local process that holds the port is outside what a config file can prevent. |
| T-261013-cpn-02 | Information disclosure | client id in shipped files | low | mitigate | The id is a public client id, and no secret exists or is written. layout_bbj_mcp (dict equality) and oauth_parsed (dict equality) pin the exact key sets, so a client secret or any extra key cannot be added unnoticed. |
| T-261013-cpn-03 | Tampering | analyze()/sync_server() edit of config.toml | medium | mitigate | A second oauth table, or one next to an inline or dotted oauth key, would make Codex reject config.toml. analyze() reports missing/ours/other; the table is added only when missing; user forms stay byte-identical (oauth_user_forms_kept); reruns are byte-identical; tomllib and the real Codex CLI parse every written config (real_parse); CRLF and symlinks are kept (crlf_config_stays_crlf, approval_key_keeps_symlink_and_mode). |
| T-261013-cpn-04 | Denial of service | the installer's codex call | medium | mitigate | The installer never passes the client to codex mcp add and never calls codex mcp login, either of which starts an interactive sign-in that blocks with output discarded. oauth_fresh_table pins the exact mcp add line, and oauth_codex_never_logs_in scans every fake codex log. |
| T-261013-cpn-05 | Repudiation | installer output after codex mcp add exits 1 having written the table | low | mitigate | A new message states what happened, instead of claiming a block was written. Checked by oauth_codex_add_error_after_write. |
| T-261013-cpn-06 | Elevation of privilege | bbj-local registration | low | mitigate | use_local leaves srv_oauth_* empty, so the loopback check server never gains OAuth settings. Checked by oauth_never_for_local, and every local_ gate stays ok. |
| T-261013-cpn-07 | Tampering | never-execute rule of the hook | low | mitigate | plugins/bbj/scripts/bbj-check.sh is not modified. test_never_execute.sh and test_static_guards.sh run in every task's sh tests/run.sh. |
| T-261013-cpn-SC | Tampering | npm/pip/cargo installs | high | mitigate | No package-manager install in this plan and no new dependency (POSIX sh + Python stdlib). Any install would need the package-legitimacy gate and a blocking human checkpoint. |
</threat_model>

<verification>
Source coverage audit:

| Source | Item | Covered by |
|--------|------|------------|
| GOAL | bbj-docs on mcp.bbj-ai.com with the OAuth client in Claude Code and Codex | Tasks 1-3 |
| REQ 261013-cpn-R1 | oauth.clientId and oauth.callbackPort on bbj-docs | Task 1 (Claude Code), Task 2 (Codex equivalent) |
| REQ 261013-cpn-R2 | default docs_url https://mcp.bbj-ai.com/mcp | Already satisfied (3c75f4f); proven by layout_user_config_docs_url and default_url_equals_plugin in Task 1's verify and in every sh tests/run.sh |
| REQ 261013-cpn-R3 | the same change in the Codex config | Task 2 |
| FACT A | layout_bbj_mcp pins the new .mcp.json shape | Task 1 |
| FACT B | claude plugin validate --strict plugins/bbj with no warning | Task 1 |
| FACT C | Codex TOML table, no client option on codex mcp add, analyze states, print_block, gate updates, oauth_ prefix | Task 2 |
| FACT D | install pages, CHANGELOG under 0.2.0, page pins | Task 3 |
| Plan-time finding | mcp_docs_connected FAIL ("Needs authentication") | Task 1 (mcp_docs_answers + mcp_docs_oauth) |
| Plan-time finding | codex mcp add exits 1 after writing the table; misleading installer line | Task 2 (A7b, oauth_codex_add_error_after_write) |
| Out of scope | rewording the docs_url description; version bumps; bbj-check.sh; CHANGELOG Tested against numbers; .claude/CLAUDE.md gate-prefix list | not planned |

Final checks, from the checkout root:
- python3 -I tests/test_layout.py
- claude plugin validate --strict plugins/bbj
- sh tests/test_install_codex.sh
- sh tests/test_static_guards.sh
- shellcheck -s sh codex/install-codex.sh tests/test_install_codex.sh tests/test_install_pages.sh tests/test_claude_plugin.sh tests/fake-bin/codex
- sh tests/run.sh, which prints SUMMARY with fail=0 and skip=0 on this machine
</verification>

<success_criteria>
- plugins/bbj/.mcp.json: bbj-docs has type http, url ${user_config.docs_url} and oauth {clientId oP9iTNuR2iiBOSqYolEHMNOoy9DGJG3t, callbackPort 47613}; claude mcp get shows them.
- docs_url default stays https://mcp.bbj-ai.com/mcp in both clients (R2), unedited.
- codex/install-codex.sh writes exactly one [mcp_servers.bbj-docs.oauth] table with the three lines on every install path, leaves user OAuth entries byte-identical and names them, never starts a sign-in, and never touches bbj-local's OAuth.
- Install pages, README and CHANGELOG describe the one-time sign-in.
- sh tests/run.sh: fail=0 (baseline was fail=1 on mcp_docs_connected).
</success_criteria>

<output>
Create `.planning/quick/261013-cpn-point-bbj-docs-at-mcp-bbj-ai-com-with-oa/261013-cpn-SUMMARY.md` with `status: complete` in its frontmatter. It records: the three commit SHAs; the final `SUMMARY:` line of sh tests/run.sh; every existing gate whose expectation was extended, and why; and the residual CI note: CI pins claude 2.1.293; mcp_docs_oauth was checked on 2.1.296 only.
</output>
