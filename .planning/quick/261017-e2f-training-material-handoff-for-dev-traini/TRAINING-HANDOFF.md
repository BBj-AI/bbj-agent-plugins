# Handoff to the BBj AI course: what to teach about the `basis-bbj` plugins

## 1. Purpose and conventions

**Audience.** The maintainers of the BBj AI course (the Docusaurus site in the repository this
handoff calls `dev-training`). Nothing in the course repository was changed to produce this
document; it is a list of what to write, where it goes, and what to correct.

**Scope.** Release 0.2.2 of the `basis-bbj` marketplace (git tag `0.2.2`, commit 979e457), read from
`bbj-agent-plugins` at commit 84089f8. The shipped files at 84089f8 are identical to the tag. The
course was read at `dev-training` commit c41996d. The plugins have two clients, Claude Code and
Codex, and this handoff covers both.

**How a claim is cited.**

- `bbj-agent-plugins/<path>` is a file of the plugin repository. A claim ends in the path (and
  `#anchor` where it helps) of the file that states it.
- `dev-training/<path>` followed by `§ "<Heading>"` is a heading of an existing course file. A
  heading is quoted exactly as it stands in the file.
- `new:dev-training/<path>` is a page that does not exist yet and should be created.
- A claim that no file of either repository backs starts with `Unverified:` and is listed in section 7.
- Files under `bbj-agent-plugins/.planning/` and `bbj-agent-plugins/.claude/`, and the test files under
  `bbj-agent-plugins/tests/`, are maintainer records, not shipped text. They are cited for the term list (which
  README and install page also use), for one test, and for pending todos that no shipped file records; each
  such citation says it is a maintainer record.

**Terms the course should use.** The plugin repository fixes one name for each thing (maintainer source:
`bbj-agent-plugins/.claude/CLAUDE.md`, section Terms; the same names run through
`bbj-agent-plugins/README.md` and `bbj-agent-plugins/docs/install.md`). The older names that course pages
still use are listed in section 6 with the replacement.

| Term | Meaning |
|------|---------|
| the docs server `bbj` | The hosted BBj docs server. Always written with its role noun. |
| the hosted check | `bbj_check_syntax` of the docs server `bbj`. It sends the code to the server and checks it against a stock BBj. |
| the `bbjcpl` check | The hook's compile-only check, `bbjcpl -t -N -X`: syntax and types. |
| `bbj-ls`, the BBj language server in BBjServices | Speaks its language-server RPC on port 5008 and serves MCP on `127.0.0.1:5009`; the plugin uses only the MCP endpoint. Checks syntax only. |
| the plugin `bbj-local` | The opt-in plugin that registers `bbj-ls` with the client, so the agent can call `bbj_check_syntax` itself. Its install step is headed "Enable the plugin `bbj-local`". |
| the plugin `bbj` | The main plugin: the docs server `bbj`, the two skills and the check hook. |
| tier 1 and tier 2 | Maintainer terms for the `bbjcpl` check and the `bbj-ls` check. Use them in a maintainer page at most; an attendee page names the checks. |

## 2. The plugin in one page

This page is written so that an attendee could read it first. Every line is cited in section 3.

The marketplace `basis-bbj` (owner BASIS International Ltd.) holds two plugins, both at version 0.2.2, for
two clients, Claude Code and Codex. Source: `bbj-agent-plugins/.claude-plugin/marketplace.json`.

- **The plugin `bbj`** brings three things: the docs server `bbj` (the hosted BBj docs server, an MCP
  server), the two BBj skills `bbj-programming` and `bbj-web-programming`, and a check hook that compiles
  every BBj file the agent writes. Source: `bbj-agent-plugins/README.md`.
- **The plugin `bbj-local`** is separate and installs disabled. It registers `bbj-ls` of a running
  BBjServices (MCP endpoint `127.0.0.1:5009`, BBj 26.03 or later) with the client, so the agent can call
  `bbj_check_syntax`, `bbj_denum` and `bbj_format` itself. Source: `bbj-agent-plugins/README.md`.
- **What it promises.** Most skill rules were reproduced with `bbjcpl` and `bbj-ls` on BBj 26.03, and the
  others cite the documentation page that states them or say that the skill maintainer confirmed them on
  BBj 26.03. The hook only compiles; BBj code is never run.
  Source: `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`,
  `bbj-agent-plugins/README.md#the-check-hook`.
- **How it is set up.** Two commands per client add the marketplace and install the plugin; then a one-time
  sign-in to the docs server `bbj`; in Codex also a trust step for the hook in `/hooks`. Source:
  `bbj-agent-plugins/docs/install.md`.

**Diagram the maintainers can draw (text description).** Left to right, five boxes and one side box.

1. The agent inside the client (Claude Code or Codex).
2. An arrow to the docs server `bbj` over http, labelled "one-time sign-in"; the server answers with the
   documentation URL it relied on. Source: `bbj-agent-plugins/plugins/bbj/.mcp.json`,
   `bbj-agent-plugins/docs/install.md#2-install`.
3. An arrow from the client's file write (`Write` or `Edit`; `apply_patch` in Codex) to the hook, labelled
   "PostToolUse, 30 s". Source: `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`.
4. From the hook, a first arrow to `bbjcpl` on the same machine, labelled "syntax and types" (the `bbjcpl`
   check), and a second arrow, taken only when no usable compiler exists, to the MCP endpoint of `bbj-ls` on the
   loopback address `127.0.0.1:5009`, labelled "syntax only". Source: `bbj-agent-plugins/docs/install.md#check-routes`.
5. From the hook back to the agent: exit code 2 with the compiler's lines on stderr, or silence for a clean
   file, or, when neither check answers, one notice per session. Source:
   `bbj-agent-plugins/docs/install.md#check-routes`.
6. A side box, drawn dashed and marked "never": the hosted check. The hook does not call it; only the agent
   can, for code it hands back without writing a file, and it says that the code was sent. Source:
   `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`,
   `bbj-agent-plugins/docs/install.md#check-routes`.

## 3. Subjects for the course

Each subject has three parts: what an attendee needs to know (each line ends in its source), the material to
create (with its form: video script change, inline text on a segment page, reference page, or exercise),
and where it goes. Course locations are repeated in the section 4 table.

### 3.1 Features and functions

#### 3.1.1 The docs server `bbj`

**What an attendee needs to know**

- The docs server `bbj` is the hosted BBj docs server, an MCP server over http. Its address is the
  `docs_url` option of the plugin `bbj` (Claude Code), default `https://mcp.bbj-ai.com/mcp`; the Codex file
  holds the same address. Source: `bbj-agent-plugins/docs/install.md#options`,
  `bbj-agent-plugins/plugins/bbj/.codex-mcp.json`.
- It asks for a one-time OAuth sign-in in a browser: `/mcp` in Claude Code, `codex mcp login bbj` in Codex
  (`codex mcp login --no-browser bbj` when the browser is on another machine; paste the callback URL back
  into Codex). Port 47613 must be free while signing in. Until the sign-in, `claude mcp list` shows
  `plugin:bbj:bbj` with `Needs authentication` and `codex mcp list` shows `Not logged in`. Source:
  `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj`.
- It offers five read-only tools, `bbj_search`, `bbj_fetch_page`, `bbj_lookup`, `bbj_reserved_word` and
  `bbj_examples`, and the resource `bbj://primer`. Every answer carries the URL of the documentation page it
  relies on. Source: `bbj-agent-plugins/docs/install.md#2-install`.
- What each tool is for, as the skill tells the agent: `bbj_lookup` for the exact syntax of a named symbol,
  `bbj_reserved_word` before naming a variable, `bbj_examples` for verified code (collections, JDBC,
  SysGui), `bbj_search` for everything else, `bbj_fetch_page` for a whole page; read `bbj://primer` before
  writing BBj and cite the URL of every page relied on. The hook's feedback adds "bbj_lookup gives exact syntax
  for a named symbol". Source: `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`,
  `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh`.
- Claude Code shows the server as `plugin:bbj:bbj` and each tool as `mcp__plugin_bbj_bbj__<tool>`, for
  example `mcp__plugin_bbj_bbj__bbj_search`. Source: `bbj-agent-plugins/CHANGELOG.md#022`.
- Where BASIS runs the hosted check next to the docs server, the server also lists `bbj_check_syntax`,
  `bbj_format` and `bbj_denum`; their answers say `hosted check, stock BBj <version>`, a stock BBj and not
  the user's own PREFIX, classpath and config. The hosted check sends the code to the server. Source:
  `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj`,
  `bbj-agent-plugins/docs/install.md#check-routes`.
- Codex asks before the first call of each tool; the three hosted check tools send code to the server and
  keep Codex's prompt. Source: `bbj-agent-plugins/docs/install.md#codex-tool-prompts-on-first-use`.
- What the hosted server records is stated in its data-handling statement,
  `https://mcp.bbj-ai.com/data-handling`. The hook sends nothing there. Source:
  `bbj-agent-plugins/docs/install.md#check-routes`.

**Material to create**

- Inline text on segment 3.3, and the setup sheet: a sign-in step after the install commands, with the
  command of each client and what the two "not yet" states look like.
- Reference page change: a "tools at a glance" table in the setup sheet, five tools and one resource, each with
  the one line above.
- Video script change for 3.4: say the tool name as the client shows it (`mcp__plugin_bbj_bbj__bbj_search`).
- Exercise change: Exercise 3A names the docs server `bbj`, not the old name (section 6).

**Where it goes.** `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "What you are installing", "Claude Code", "Prove it works", "Tools you should see";
`dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "Confirming it worked";
`dev-training/docs/module-3/04-exercise-3a-install-and-prove-it-works.mdx` § "The two check prompts";
`dev-training/docs/module-3/05-watching-it-look-things-up.mdx` § "The habit";
`dev-training/docs/module-3/02-what-mcp-is.mdx` § "What happens during a call".

#### 3.1.2 The two skills

**What an attendee needs to know**

- Two skills live in the plugin `bbj`: `bbj-programming` and `bbj-web-programming`. Claude Code calls them
  `/bbj:bbj-programming` and `/bbj:bbj-web-programming`; Codex lists them as `bbj:bbj-programming` and
  `bbj:bbj-web-programming`. Source: `bbj-agent-plugins/docs/install.md#2-install`.
- `bbj-programming` covers BBj class and method syntax, statement rules (a trailing `rem`, bare calls),
  which classes need `USE`, type-check errors on undeclared values, `str()` sign characters, SysGui window
  flags and list buttons, form validation, JDBC and SQL verbs, and running a program when the user asks.
  Source: `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`.
- `bbj-web-programming` covers browser work (DWC or BUI): injecting CSS and JavaScript with
  `BBjWebManager`, `addClass`, `addOuterStyle`, `setOuterStyle` and `setPanelStyle`, `setAttribute` against
  `setProperty`, Automatic Layout and window flags, `BBjWebComponent` and `setSlot`, DWC themes, client form
  validation, and registering a DWC app. Source:
  `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`.
- References of `bbj-programming`: `sysgui.md`, `database.md`, `callback-performance.md` (form validation
  callbacks) and `running.md` (read only when the user asks to run a program). Source:
  `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`.
- References of `bbj-web-programming`: `styling.md`, `form-validation.md`, `running-dwc-apps.md` and
  `shoelace.md`. Source: `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`.
- Each skill's description lists symptoms that make it apply without BBj being named (for example a syntax
  error on a line with a trailing `rem`, or `No match for method ... setSlot`). Source: the front matter of
  `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md` and
  `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`.
- Traps the skill teaches, usable as course examples: a comment on a statement's line needs `;` before
  `rem`; a bare function-style call is not a statement; a missing `USE` is caught by `bbjcpl` but passed by
  `bbj-ls`; a value held in an undeclared variable fails the type check when it is assigned to a declared
  field, returned from a typed method or passed to a declared object; `bbjcpl` exits 0 even with errors,
  so read its output. Source: `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`.
- Both skills open with the same check order for code handed back without being written to a file: first
  `bbjcpl -t -N -X <file>`, then `bbj_check_syntax` of the plugin `bbj-local`, and only when neither exists
  `bbj_check_syntax` of the docs server `bbj` (the hosted check), telling the user that the code was sent
  to the server and checked against a stock BBj. Source:
  `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`.

**Material to create**

- Inline text on segment 3.3: the two-row table with the correct scope of each skill (section 6).
- Video script change for 3.5: skills come from the plugin in both clients; drop "a Claude Code format".
- Reference page change: a "what each skill covers" table in the setup sheet, with the reference files by
  topic, as a place to send an attendee.
- Module 5 and 6 overview pages: one sentence each that `bbj-web-programming` applies there.

**Where it goes.** `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The two skills";
`dev-training/docs/module-3/06-what-skills-are.mdx` § "MCP versus skills";
`dev-training/docs/module-2/06-comparing-claude-code-and-codex.mdx` § "Picking one";
`dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "What you are installing";
`dev-training/docs/module-5/00-overview.mdx` § "What this module will cover".

#### 3.1.3 The check hook

**What an attendee needs to know**

- After every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file, the hook compiles the file with
  `bbjcpl -t -N -X`, which checks syntax and types. A compile error goes back to the agent (exit code 2) with
  the compiler's own lines; a clean file and a non-BBj file are silent. Source:
  `bbj-agent-plugins/README.md#the-check-hook`.
- Codex checks the files a patch names through `apply_patch`: a file named by an `*** Add File:`,
  `*** Update File:` or `*** Move to:` line. A path outside the working directory is skipped. Source:
  `bbj-agent-plugins/docs/install.md#not-covered`.
- The hook never runs BBj code (it compiles with `-N`, which writes no output) and sends nothing off the
  machine; it does not use the hosted check. Source: `bbj-agent-plugins/docs/install.md#check-routes`,
  `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`.
- BBj is found in this order: the `bbj_home` option (Claude Code), `BBJ_HOME`, `BBJHOME`, `bbjcpl` on
  `PATH`, then `/c/bbx` (`C:\bbx` on Windows), `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. Source:
  `bbj-agent-plugins/docs/install.md#check-routes`.
- The failing message starts `bbjcpl reported N error(s) in <file>:` and then holds the compiler's lines, at
  most 40. Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- With no usable compiler the hook asks `bbj-ls` instead, on its MCP endpoint `127.0.0.1:5009`. That check is syntax only and
  its message starts `bbj-local reported N error(s) in <file>:`, so the attendee can see which check spoke.
  Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- With neither a compiler nor a reachable `bbj-ls`, the hook tells the agent once per session that the file
  was written but not compile-checked, and how to enable a check. Source:
  `bbj-agent-plugins/docs/install.md#check-routes`.
- The hook is a help, not a guarantee: it makes the compiler's verdict reach the agent, but whether the
  agent repairs a file is up to the model. Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- The hook does not see a file written through a shell command, a `NotebookEdit`, or a tool outside the
  matcher `Write|Edit`. Observed on Windows and on macOS: asked to create a file, Claude Code wrote it with
  `Bash` and the hook did not run; after the request to use the Write tool, it did. Source:
  `bbj-agent-plugins/docs/install.md#not-covered`.
- Codex does not run a plugin hook until the user has trusted it in `/hooks`. Source:
  `bbj-agent-plugins/docs/install.md#codex-trust-the-hook-in-hooks`.
- The hook has a timeout of 30 seconds. Source: `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`.
- Windows needs Git for Windows, because the hook runs `sh`. Source:
  `bbj-agent-plugins/docs/install.md#windows`.

**Material to create**

- Video script change for segment 3.6: say that the hook uses the compiler when BBj is found and `bbj-ls`
  only as the fallback, and that a clean file is silent. Drop the claim that the check always needs
  `bbj-ls` (section 6, first row).
- Inline text on the segment page: a short "Which check spoke" passage with the three messages an attendee
  can see (`bbjcpl reported`, `bbj-local reported`, and the once-per-session notice that a file was not
  compile-checked).
- Exercise change: in Exercise 3C, replace the one-line cause of a silent hook with the routes above, and
  add "ask for the Write tool" as the first thing to try.
- Reference page change: rewrite the "Local and hosted" table of the syntax checking page around the
  routes of the hook.

**Where it goes.** `dev-training/docs/module-3/07-write-check-fix.mdx` § "The loop", "What a clean check does not mean", "It runs on your BBjServices", "What it needs";
`dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx` § "If the check never runs";
`dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted", "The three tools", "What the check does not do".

#### 3.1.4 The plugin `bbj-local` and `bbj-ls`

**What an attendee needs to know**

- `bbj-ls`, the BBj language server in BBjServices, has two ports: its language-server RPC on 5008 (the
  port `com.basis.languageServer.addr` sets) and its MCP endpoint on `127.0.0.1:5009` (BBj 26.03 or
  later). The hook and the plugin `bbj-local` talk only to the MCP endpoint; the course should teach
  both numbers so attendees do not mix them up. Source for 5008: the project owner, 2026-10-17; the
  repository names only 5009. The
  plugin `bbj-local` registers it with the client at `http://127.0.0.1:5009/mcp`, so the client has a check
  it can call itself: `bbj_check_syntax`, `bbj_format`, `bbj_denum`. Source:
  `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local`,
  `bbj-agent-plugins/plugins/bbj-local/.mcp.json`.
- It installs disabled (`defaultEnabled` is false in the marketplace entry and in the plugin manifest) and
  stays opt-in, because a registered server without a running BBjServices shows as failed on every start.
  Source: `bbj-agent-plugins/.claude-plugin/marketplace.json`,
  `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local`.
- Enable it: `claude plugin install bbj-local@basis-bbj` then `claude plugin enable bbj-local@basis-bbj`
  in Claude Code; `codex plugin add bbj-local@basis-bbj` in Codex. Source:
  `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local`.
- It is preferred over the hosted check for two reasons: the code stays on the machine, and it is checked
  against the installation's own PREFIX, classpath and config. It does not replace the compiler: the hook
  still tries the `bbjcpl` check first because that also checks types, while `bbj-ls` checks syntax only.
  Source: `bbj-agent-plugins/README.md`.
- The hook asks `bbj-ls` by itself, so the hook does not need the plugin `bbj-local`; the plugin only gives
  the client the `bbj_check_syntax` tool. Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- `bbj-ls` does not see a method that does not exist or a `use` target that does not resolve. Source:
  `bbj-agent-plugins/docs/install.md#check-routes`.
- Claude Code lists it as `plugin:bbj-local:bbj-local` once installed and enabled; in Codex it is absent from
  `codex mcp list` until `codex plugin add`, and Codex does not probe the server (with nothing listening it
  still reads `enabled`). Source: `bbj-agent-plugins/docs/install.md#windows`,
  `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local`.
- Not run: the plugin `bbj-local` on macOS, in either client. Source:
  `bbj-agent-plugins/docs/install.md#macos`.

**Material to create**

- Reference page change: rewrite the setup sheet section on `bbj-ls` as "Enable the plugin
  `bbj-local`", with the Codex plugin command and without a switch the repository cannot confirm
  (section 7, item 5).
- Reference page change: the syntax checking page's "Local and hosted" table in the terms of section 1, and
  the three tools with their names only until the purpose of `bbj_format` and `bbj_denum` is confirmed
  (section 7, item 13).
- Inline text on segment 3.6: one sentence that `bbj-ls` is the fallback and is syntax only.

**Where it goes.** `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Adding the local syntax check";
`dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted", "The three tools";
`dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup";
`dev-training/docs/reference/08-glossary.mdx` (no headings; entries for the plugin `bbj-local` and `bbj-ls`).

#### 3.1.5 The Codex route

**What an attendee needs to know**

- Codex gets the plugin `bbj` from the same marketplace: `codex plugin marketplace add
  BBj-AI/bbj-agent-plugins`, then `codex plugin add bbj@basis-bbj`. The plugin carries a Codex overlay
  (`plugins/bbj/.codex-plugin/plugin.json`) whose `mcpServers` points to `./.codex-mcp.json`. Source:
  `bbj-agent-plugins/docs/install.md#2-install`, `bbj-agent-plugins/plugins/bbj/.codex-plugin/plugin.json`.
- Codex does not run a plugin hook until the user trusts it in `/hooks`. It trusts a hook by a hash of its
  definition, so a changed definition asks again; an update that changed only the version did not (observed
  on Linux). Source: `bbj-agent-plugins/docs/install.md#codex-trust-the-hook-in-hooks`,
  `bbj-agent-plugins/docs/install.md#update-and-remove`.
- Sign in with `codex mcp login bbj`. Without the pre-registered client Codex tries dynamic client
  registration and the hosted server refuses it. Source:
  `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj`.
- The plugin ships no tool approvals, so Codex asks before the first call of each tool. The Codex
  documentation names a plugin-scoped key to pre-approve the five docs tools (`approval_mode = "approve"`);
  the install page says it was not tried. The prompt itself was not watched in the recorded runs. Source:
  `bbj-agent-plugins/docs/install.md#codex-tool-prompts-on-first-use`,
  `bbj-agent-plugins/docs/install.md#codex-pre-approve-the-docs-tools-optional`.
- Codex has no plugin options, so `BBJ_HOME` (or `bbjcpl` on `PATH`) must be in the environment Codex starts
  from; Codex 0.162.1 runs hooks in a daemon that keeps its start environment, so stop every Codex process
  first. Source: `bbj-agent-plugins/docs/install.md#codex-where-the-hook-finds-bbj`.
- The hook checks files written through `apply_patch`. If the hook cannot start, Codex shows `Hook failed`
  under the change; on Windows an earlier run saw this on every write when `sh` was not found. Source:
  `bbj-agent-plugins/docs/install.md#windows`.
- Verified with Codex CLI 0.162.1 on Linux, Windows and macOS. Source:
  `bbj-agent-plugins/README.md#verified`.

**Material to create**

- Reference page change: the setup sheet's Codex section as three steps (add the marketplace and the plugin,
  sign in, trust the hook), with no script and no `AGENTS.md` step (section 6).
- Inline text on segment 3.3: the Codex card says the same three steps and which of them a screen shows.
- Troubleshooting entries: "Codex shows Hook failed", "Codex asks before every tool call", "the hook is
  not trusted yet".

**Where it goes.** `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Codex";
`dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "Two things the Codex installer cannot do for you";
`dev-training/docs/reference/11-course-reference-sheet.mdx` § "Installing the BBj plugin";
`dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup";
`dev-training/docs/module-2/02-meet-claude-code-and-codex.mdx` § "Permission modes".

### 3.2 Installing and using it

The page to link to is `bbj-agent-plugins/docs/install.md`: it owns the steps, the course should link to it
and copy only the commands (the setup sheet already works this way). Steps in order, for both clients:

1. **Requirements.** Claude Code 2.1.281 or later (tested with 2.1.301 on Linux, 2.1.292 on Windows and
   2.1.296 on macOS); a Codex CLI with plugin, hooks and MCP support (verified with 0.162.1); a network
   connection to the docs server `bbj` and a browser for the sign-in; BBj is optional. Source:
   `bbj-agent-plugins/docs/install.md#requirements`.
2. **Add the marketplace.** `claude plugin marketplace add BBj-AI/bbj-agent-plugins` or
   `codex plugin marketplace add BBj-AI/bbj-agent-plugins`. A local checkout can be added instead. Source:
   `bbj-agent-plugins/docs/install.md#1-add-the-marketplace`.
3. **Install.** `claude plugin install bbj@basis-bbj` or `codex plugin add bbj@basis-bbj`. In Claude Code
   the plugin is enabled right away and `claude plugin list` shows it; Claude Code says two options are
   not yet set, which is expected. Source: `bbj-agent-plugins/docs/install.md#2-install`.
4. **Codex only: trust the hook** in `/hooks`. Source:
   `bbj-agent-plugins/docs/install.md#codex-trust-the-hook-in-hooks`.
5. **Sign in** to the docs server `bbj`: `/mcp` in Claude Code, `codex mcp login bbj` in Codex. Source:
   `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj`.
6. **Optional: enable the plugin `bbj-local`** on a machine where BBjServices 26.03 or later runs. Source:
   `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local`.
7. **Use it.** Ask for code that compiles and for the Write tool; a clean file is silent. Source:
   `bbj-agent-plugins/docs/install.md#check-routes`, `bbj-agent-plugins/docs/install.md#not-covered`.

**Options.** The Claude Code plugin `bbj` has two options, shown with `claude plugin configure bbj@basis-bbj`
or set at install time (`--config docs_url=<url>`): `docs_url` (default `https://mcp.bbj-ai.com/mcp`) and
`bbj_home` (the BBj installation directory for the hook; empty means `BBJ_HOME`, `BBJHOME`, `PATH`, then the
usual folders). Codex has no options. `BBJ_LOCAL_MCP_URL` changes the address the hook asks for `bbj-ls`
(loopback only). Pointing `docs_url` at another server needs the `oauth` block of the plugin's `.mcp.json`
removed if that server rejects the client. Source: `bbj-agent-plugins/docs/install.md#options`,
`bbj-agent-plugins/docs/install.md#check-routes`.

**Update and remove.** Claude Code: `claude plugin marketplace update basis-bbj`, then
`claude plugin update bbj@basis-bbj` (and `bbj-local@basis-bbj` if installed), then restart or
`/reload-plugins`; remove with `claude plugin uninstall` for each plugin and
`claude plugin marketplace remove basis-bbj`. Codex: run `codex plugin add bbj@basis-bbj` again after the
marketplace version changed; `codex plugin marketplace upgrade basis-bbj` is for a Git marketplace. Source:
`bbj-agent-plugins/docs/install.md#update-and-remove`.

**Windows.** Git for Windows is required (the hook runs `sh`). Claude Code finds `sh` through Git Bash;
Codex starts the hook through PowerShell with the `commandWindows` entry, which looks for `sh.exe` in a fixed
order of places and, when none holds it, blocks a Codex change that names a `.bbj`, `.src` or `.bbx` file
with `bbj-check: Git for Windows sh.exe not found, so BBj files are not compile-checked.`. The default homes
the hook tries include `C:\bbx` on Windows. Source: `bbj-agent-plugins/docs/install.md#windows`,
`bbj-agent-plugins/CHANGELOG.md#022`.

**macOS.** The default BBj homes include `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`; a BBj in a `bbx`
folder in the user's home directory was found only because `bbj_home` or `BBJ_HOME` named it. Source:
`bbj-agent-plugins/docs/install.md#macos`.

**What was verified, and what was not.** BBj 26.03 on Linux, Windows and macOS: in both clients the `bbjcpl` check
reported on a bad file and stayed silent on a clean one (on Linux with Claude Code the hook was run directly,
not by the client), and `bbj-ls` was seen in every cell in the form the README table names (hook, plugin
`bbj-local`, plugin connected, or hook run by hand). Not run: the
plugin `bbj-local` on macOS; Windows with Git for Windows on another drive, a real per-user install,
PowerShell 7, a ConstrainedLanguage policy, or a plugin folder whose path holds `$` or a backtick; the
sign-in on Windows and macOS; an update through a Git marketplace on Windows or macOS; a Codex patch of
several BBj files with no check route. Source: `bbj-agent-plugins/README.md#verified`,
`bbj-agent-plugins/CHANGELOG.md#022`.

**Open item for the course.** The install page assumes the `claude` CLI, while the course runs Claude Code in
VS Code (`dev-training/docs/module-2/02-meet-claude-code-and-codex.mdx` § "In this video"). Whether the
plugin, the sign-in and the hook work from the VS Code extension alone is not verified (section 7,
item 12). Source: `bbj-agent-plugins/.planning/todos/pending/2026-10-16-vscode-extension-install-route.md`
(maintainer record).

**Material to create.** Setup sheet: requirements line, the seven steps above with both clients' commands,
and a "Windows and macOS" box that links to the install page instead of copying it (reference page change).
Segment 3.3: the sign-in as an on-screen step (video script change plus inline text). Exercise 3A: a step
to confirm the sign-in (exercise). Prerequisites page: the requirements that decide the install (section 4).

**Where it goes.** `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Claude Code", "Codex", "Upgrading from a hand install";
`dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The commands", "Confirming it worked";
`dev-training/docs/module-3/04-exercise-3a-install-and-prove-it-works.mdx` § "The two check prompts";
`dev-training/docs/start-here/02-prerequisites.mdx` § "Before Module 3";
`dev-training/docs/reference/11-course-reference-sheet.mdx` § "Installing the BBj plugin", "Confirming the plugin connected".

### 3.3 Architecture

For an attendee who wants to know why the agent sees what it sees. The parts, in the order a change travels.

- **Manifest layer.** `bbj-agent-plugins/.claude-plugin/marketplace.json` names the marketplace `basis-bbj`
  and lists the plugins `bbj` and `bbj-local` (the second with `defaultEnabled` false). Each plugin has a
  manifest at `.claude-plugin/plugin.json`; the plugin `bbj` declares the two options `docs_url` and
  `bbj_home` there. Codex reads the overlay `plugins/bbj/.codex-plugin/plugin.json`. Source:
  `bbj-agent-plugins/plugins/bbj/.claude-plugin/plugin.json`,
  `bbj-agent-plugins/plugins/bbj-local/.claude-plugin/plugin.json`,
  `bbj-agent-plugins/plugins/bbj/.codex-plugin/plugin.json`.
- **MCP registrations.** `plugins/bbj/.mcp.json` registers the docs server `bbj` (transport http, address
  `${user_config.docs_url}`, with the pre-registered OAuth client and callback port 47613);
  `plugins/bbj/.codex-mcp.json` holds the literal address for Codex; `plugins/bbj-local/.mcp.json` registers
  `http://127.0.0.1:5009/mcp`. The course should not copy the OAuth client settings. Source:
  `bbj-agent-plugins/plugins/bbj/.mcp.json`, `bbj-agent-plugins/plugins/bbj/.codex-mcp.json`,
  `bbj-agent-plugins/plugins/bbj-local/.mcp.json`.
- **The hook entry.** `hooks.json` registers a `PostToolUse` hook with matcher `Write|Edit`, the command
  `sh "${CLAUDE_PLUGIN_ROOT}/scripts/bbj-check.sh"`, a timeout of 30 seconds and the status message "BBj
  compile-only check". Codex accepts `Write` and `Edit` as names for `apply_patch`. Source:
  `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`, `bbj-agent-plugins/docs/install.md#not-covered`.
- **Hook flow.** The script reads the hook JSON on stdin; for a `.bbj`, `.src` or `.bbx` file (a file named
  `config*.bbx` is configuration and is skipped) it finds a compiler, runs
  `bbjcpl -t -N -X -P<directories> <absolute file>` and reads the verdict from the compiler's output, because
  the compiler exits 0 on every outcome. The `-P` directories are the file's directory, the project directory
  and the working directory. Source: `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment),
  `bbj-agent-plugins/docs/install.md#check-routes`.
- **Compiler discovery.** `bbj_home` option, `BBJ_HOME`, `BBJHOME`, `bbjcpl` on `PATH`, then the default
  homes `/c/bbx`, `/Applications/bbx`, `/usr/local/bbx`, `/opt/bbx`. Source:
  `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment).
- **Tier 1 against tier 2.** Tier 1 is the `bbjcpl` check (syntax and types). Tier 2 is the `bbj-ls` check:
  one request to `bbj_check_syntax` over plain http to a loopback address only (`127.0.0.1`, `localhost` or
  `[::1]`; address from `BBJ_LOCAL_MCP_URL`), with a wait of up to 12 seconds for an answer; it reports syntax
  errors only, and its message header reads `bbj-local reported`. The hook never calls the hosted check.
  Source: `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment),
  `bbj-agent-plugins/docs/install.md#check-routes`. Tier 1 and tier 2 are maintainer terms.
- **No-route notice.** When a BBj file had no check route and no file had compiler errors, the hook writes
  one JSON object with a `hookSpecificOutput` key to stdout, once per session, naming the files that were not
  compile-checked and how to enable a check. Source: `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh`
  (header comment).
- **Exit contract.** Exit 0 and silence for a clean file, a file that is not BBj, or a route that was
  reached but gave no verdict; exit 2 with the feedback on stderr when the compiler reported errors: a header
  `bbjcpl reported N error(s) in <file>:`, the compiler's lines (at most 40, then `(M more line(s) not
  shown)`), an optional line `Not counted: K unresolved use target line(s)` (the compiler's "Cannot find
  program" lines never cause a failure alone) and a line pointing to `bbj_lookup`. Stdout is written only for
  the notice. Source: `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment),
  `bbj-agent-plugins/docs/install.md#check-routes`.
- **Codex patch lines.** A Codex `apply_patch` carries the patch text in the tool input; the hook checks the
  files named by `*** Add File:`, `*** Update File:` and `*** Move to:` lines, resolved against the working
  directory, skips a path with a `..` segment or outside the working directory, and skips a symlink. The
  payload shape was captured with Codex CLI 0.162.1. Source: `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh`
  (header comment).
- **Windows launcher.** `commandWindows` runs in PowerShell, looks for Git for Windows `sh.exe`, and calls
  the script through it, ending with `exit $LASTEXITCODE` so that exit code 2 reaches Codex as feedback.
  Source: `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`, `bbj-agent-plugins/docs/install.md#windows`.
- **Safety by test.** A test proves that no BBj interpreter is run and that every compiler call carries
  `-t`, `-N` and `-X`. Source: `bbj-agent-plugins/tests/test_never_execute.sh` (maintainer test, not
  shipped to users).

**Material to create.** One reference page, "How the BBj plugin works" (section 5), with a diagram drawn from
section 2 and the three messages an attendee can see; a glossary line for each term of section 1; in
segment 3.6 only the one-sentence version (the hook compiles; a fallback exists).

**Where it goes.** `new:dev-training/docs/reference/12-how-the-plugin-works.mdx` (section 5);
`dev-training/docs/reference/08-glossary.mdx` (no headings; new entries);
`dev-training/docs/module-3/07-write-check-fix.mdx` § "The loop".

### 3.4 Do's and don'ts

Each rule has its reason and its source. The table is also the outline of the page proposed in section 5.

| Rule | Reason | Source |
|------|--------|--------|
| Do: check by compiling; run a program only when you decide to. | The hook compiles with `-N` and never runs BBj; the skill tells the agent that checking never needs a run and not to run a program on its own initiative. | `bbj-agent-plugins/docs/install.md#check-routes`, `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/references/running.md`, `bbj-agent-plugins/tests/test_never_execute.sh` |
| Do: expect that the hook sends nothing off the machine, and say so. | The hook never uses the hosted check. | `bbj-agent-plugins/docs/install.md#check-routes` |
| Do: know that the hosted check does send code. | The agent may use it only when no compiler and no `bbj-local` exist, and tells the user. | `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md` |
| Do: keep the plugin `bbj-local` opt-in; enable it only where BBjServices 26.03 or later runs. | A registered server without a running BBjServices shows as failed on every start. | `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local` |
| Do: set `BBJ_HOME` (Codex) or `bbj_home` (Claude Code) when BBj is outside the default folders. | Otherwise the hook falls back to `bbj-ls` or says nothing could be checked. | `bbj-agent-plugins/docs/install.md#check-routes` |
| Do: in Codex, start Codex from a shell that has `BBJ_HOME`, after stopping every Codex process. | The daemon that runs hooks keeps the environment it started with. | `bbj-agent-plugins/docs/install.md#codex-where-the-hook-finds-bbj` |
| Do: trust the hook in `/hooks`, and again when Codex asks after a changed hook. | Codex runs a plugin hook only after review and trusts it by hash. | `bbj-agent-plugins/docs/install.md#codex-trust-the-hook-in-hooks` |
| Do: on Windows, install Git for Windows. | The hook runs `sh`; without it a Codex change that names a BBj file is blocked. | `bbj-agent-plugins/docs/install.md#windows` |
| Do: ask for the Write tool, and for code that compiles. | A client that writes a file through `Bash` is not seen by the hook; asking for a compiling file can help. | `bbj-agent-plugins/docs/install.md#not-covered`, `bbj-agent-plugins/docs/install.md#check-routes` |
| Do: have the agent cite the URL of every page it relies on, and open it (opening it is the course's habit, not a plugin rule). | The skills require the citation; the docs server answers with it. | `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`, `bbj-agent-plugins/docs/install.md#2-install` |
| Don't: read a clean check as a correct program. | The check covers syntax and types (`bbj-ls`: syntax only); neither validates an event constant. | `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`, `bbj-agent-plugins/docs/install.md#check-routes` |
| Don't: expect the hook to see files written by a shell command, a `NotebookEdit`, or tools outside `Write` and `Edit`. | They do not match the hook. | `bbj-agent-plugins/docs/install.md#not-covered` |
| Don't: treat the hook as enforcement. | It helps the agent notice a compile error; whether the agent repairs a file is up to the model. | `bbj-agent-plugins/docs/install.md#check-routes` |
| Don't: copy the OAuth client settings or the callback details into course pages. | The plugin's `.mcp.json` already carries them, and a second copy has nothing to keep it true (this handoff's recommendation). | `bbj-agent-plugins/plugins/bbj/.mcp.json` |
| Don't: point `docs_url` at a server that rejects this client without removing the `oauth` block. | The block is static and applies to any `docs_url`. | `bbj-agent-plugins/docs/install.md#options` |
| Don't: claim a platform or route was tested when it was not. | The README table names what was seen and the "Not run" lists name what was not. | `bbj-agent-plugins/README.md#verified`, `bbj-agent-plugins/CHANGELOG.md#022` |

**Platform caveats to repeat on the course page.** Not run: the plugin `bbj-local` on macOS; the sign-in on
Windows and macOS; Windows with Git for Windows in unusual places, PowerShell 7 and ConstrainedLanguage;
Claude Code with the shipped `commandWindows` entry; an update through a Git marketplace on Windows or macOS.
Source: `bbj-agent-plugins/CHANGELOG.md#022`.

**Material to create.** One reference sheet, "Using the BBj plugin: do's and don'ts" (section 5), made from the
table; the top five rules also as an inline box on segment 3.6 and on the 3.9 prompting habits page.

**Where it goes.** `new:dev-training/docs/reference/13-plugin-dos-and-donts.mdx` (section 5);
`dev-training/docs/module-3/12-prompting-habits.mdx` § "The four habits";
`dev-training/docs/module-3/11-project-instructions.mdx` § "CLAUDE.md and AGENTS.md";
`dev-training/docs/reference/03-trusting-an-answer.mdx` § "Checking an answer".

## 4. Placement map

The course's own rule decides inline against reference (`dev-training/SUPPLEMENTAL-SHEETS.md` § "Where each one should live"): text needed once, while watching a video, goes inline on the segment page; text that is looked up again goes in `dev-training/docs/reference/`; some subjects get both, a short inline version and a link. The Action column uses: correct (the text is wrong now), extend (add), rewrite, link, create. Rows are grouped by where the attendee is: start-here and Module 2, Module 3 pages in order, reference pages, Modules 5 and 6, the course's own notes.

| Subject | Existing course location | Action | Notes |
|---------|--------------------------|--------|-------|
| Requirements before Module 3 | `dev-training/docs/start-here/02-prerequisites.mdx` § "Before Module 3" | Correct, extend | Add: Claude Code 2.1.281 or later or a Codex CLI with plugin support, a browser for the sign-in, Git for Windows on Windows, BBj optional. Drop the claim that `bbj-ls` needs a switch the repository cannot confirm (section 6). |
| Permission modes, Codex prompts and hook trust | `dev-training/docs/module-2/02-meet-claude-code-and-codex.mdx` § "Permission modes" | Extend | One forward sentence only: in Module 3 Codex will ask before the first call of each tool and wants the hook trusted in `/hooks`. Detail stays in Module 3 (inline rule). |
| Skills are not Claude Code only | `dev-training/docs/module-2/06-comparing-claude-code-and-codex.mdx` § "Picking one" | Correct | Codex lists both skills from the plugin (section 6). |
| What a call looks like | `dev-training/docs/module-3/02-what-mcp-is.mdx` § "What happens during a call" | Extend (optional) | Name a real call, `mcp__plugin_bbj_bbj__bbj_search`; keeps the "ecosystem" point intact. |
| Install, both clients; sign-in; hook trust | `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "One install, three things", "The commands", "Two things the Codex installer cannot do for you", "Confirming it worked" | Correct, rewrite | Codex is two plugin commands, then the sign-in and the `/hooks` trust; no script, no snippet. Add the sign-in as an on-screen step; list what each state looks like. |
| The two skills, scope and references | `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The two skills" | Correct, extend | Correct the scope of `bbj-web-programming`; drop "a Claude Code format"; add the reference files by topic (section 3.1.2). |
| Exercise 3A prompts and confirmation | `dev-training/docs/module-3/04-exercise-3a-install-and-prove-it-works.mdx` § "The two check prompts", "Why step 4 is not optional" | Correct, extend | Server name in the second prompt; step 1 says "one script in Codex"; add the sign-in and the expected `plugin:bbj:bbj` listing. |
| Watching a lookup | `dev-training/docs/module-3/05-watching-it-look-things-up.mdx` § "The habit", "The honest before-and-after" | Extend | Say the tool name as the client shows it; the habit (open the cited page) is unchanged. |
| Skills against MCP | `dev-training/docs/module-3/06-what-skills-are.mdx` § "MCP versus skills" | Extend | Name the two plugin skills as the worked example and the check-call order they open with. |
| The check hook loop | `dev-training/docs/module-3/07-write-check-fix.mdx` § "The loop", "What a clean check does not mean", "It runs on your BBjServices", "What it needs"; `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx` § "What to look for in the last check", "If the check never runs"; `dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted" | Correct, extend | Routes, the three messages and the silent clean file (sections 3.1.3 and 6); the hook is the Write-and-Edit loop, `bbj_check_syntax` is the agent's own call. Course rule: inline plus reference. |
| Ask and verify | `dev-training/docs/module-3/08-exercise-3b-ask-and-verify.mdx` § "The point is not whether it got them right" | Link | Link the do's and don'ts page; the three questions stay unchanged. |
| Putting it together | `dev-training/docs/module-3/09-putting-it-together.mdx` § "On repeatability" | Extend | "The check having the last word" holds only when a check route exists; add the notice as the third possible outcome. |
| Project instructions | `dev-training/docs/module-3/11-project-instructions.mdx` § "CLAUDE.md and AGENTS.md"; `dev-training/docs/module-3/12-prompting-habits.mdx` § "The four habits" | Extend | Add "ask for the Write tool" and "ask for code that compiles" as habits; the plugin repository names both. |
| Reference overview | `dev-training/docs/reference/00-overview.mdx` § "Using the BBj MCP server and skills" | Extend | Two new cards for the pages of section 5. |
| Setup sheet | `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "What you are installing", "Claude Code", "Codex", "Prove it works", "Tools you should see", "Adding the local syntax check", "Upgrading from a hand install" | Correct, rewrite | The largest set of changes (section 6). Keep the rule that the sheet owns the commands and the plugin repository's install page owns the steps. |
| Syntax checking reference | `dev-training/docs/reference/02-syntax-checking.mdx` § "The loop", "The three tools", "What the check does not do", "A note on the course" | Rewrite | Rebuild around the routes (section 3.3). The "Not covered in the videos yet" note and "A note on the course" are stale since segment 3.6 exists (`dev-training/COURSE-NOTES.md` § "8c. Module 3 has drifted from the outline"). |
| Trusting an answer | `dev-training/docs/reference/03-trusting-an-answer.mdx` § "What the docs server gives you", "The identity footer" | Verify, correct | The style label and the footer line have no backing file in the plugin repository (section 7); the footer example uses the old name. |
| Data handling | `dev-training/docs/reference/04-data-handling.mdx` § "What the server does with your requests", "Code you send" | Verify with the statement's owner | States no sign-in; the plugin signs in once. Do not edit a statement of record without its owner (`dev-training/COURSE-NOTES.md` § "5. The data-handling statement now lives here, and needs an owner"). |
| Troubleshooting | `dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup", "Where the videos have gone out of date" | Correct, extend | Silent hook, sign-in states, `Hook failed`, Codex prompts, the notice. |
| Glossary | `dev-training/docs/reference/08-glossary.mdx` | Correct, extend | File has no headings; replace the old-name entries and add the terms of section 1. |
| Command collection | `dev-training/docs/reference/11-course-reference-sheet.mdx` § "Installing the BBj plugin", "Confirming the plugin connected", "The two check prompts", "Switching on the BBj language server" | Correct | Mirrors the setup sheet; fix both together. |
| DWC modules | `dev-training/docs/module-5/00-overview.mdx` § "What this module will cover"; `dev-training/docs/module-6/00-overview.mdx` § "What this module will cover" | Extend | One sentence each: the skill `bbj-web-programming` and its four references apply; no segment pages yet (section 5). |
| Course notes: addresses and status | `dev-training/COURSE-NOTES.md` § "1. The MCP addresses and install routes are not final", "3. Module 3's install narration is out of date", "4. The hosted syntax check is not deployed" | Update status | The address table lists two addresses that differ from the manifests; item 3 repeats the script route. |
| Supplemental sheet status | `dev-training/SUPPLEMENTAL-SHEETS.md` § "14. BBj MCP setup sheet — DONE", "16. `BBj.properties` language-server line — DONE" | Change status | Both are marked DONE but are out of date or unverified (sections 6 and 7). |

## 5. New pages to add

Only two pages are proposed. Everything else fits an existing file (section 4). Both are reference pages, because they are looked up repeatedly and a colleague should be sendable straight to them (`dev-training/SUPPLEMENTAL-SHEETS.md` § "Where each one should live").

**Page 1: `new:dev-training/docs/reference/12-how-the-plugin-works.mdx`**

- Title: "How the BBj plugin works". Purpose: answer "why does the agent show me this?" for an attendee who wants the mechanism, from section 3.3 in plain words.
- Outline: the marketplace and the two plugins; the three parts of the plugin `bbj`; a diagram (text description in section 2); what the hook does on a write (the `bbjcpl` check, the `bbj-ls` fallback, the notice); the three messages with an example each; what the hook never does; a short "for maintainers" box with tier 1 and tier 2.
- Edits the course needs to add it: a card in `dev-training/docs/reference/00-overview.mdx` § "Using the BBj MCP server and skills" (the page lists its pages as `DocCardList` items with `href`, `label`, `docId` and `description`); links to it from `dev-training/docs/module-3/07-write-check-fix.mdx` § "The loop" and from `dev-training/docs/reference/08-glossary.mdx`.

**Page 2: `new:dev-training/docs/reference/13-plugin-dos-and-donts.mdx`**

- Title: "Using the BBj plugin: do's and don'ts". Purpose: one sheet an attendee keeps open while working, made from the table in section 3.4.
- Outline: do's (compile, `BBJ_HOME`, `/hooks` trust, Git for Windows, the Write tool, cite and open the URL); don'ts (a clean check is not a correct program, shell-written files are not seen, no enforcement, the hosted check sends code); platform caveats and the not-run list; a link to the install page.
- Edits: a card in `dev-training/docs/reference/00-overview.mdx` § "Using the BBj MCP server and skills"; a link from `dev-training/docs/reference/03-trusting-an-answer.mdx` § "Checking an answer" and from `dev-training/docs/module-3/12-prompting-habits.mdx` § "The four habits".

**Why the numbers 12 and 13.** The reference pages run from `00-` to `11-` in `dev-training/docs/reference/`, so `12-` and `13-` are the next free prefixes.

**No sidebar edit.** `dev-training/sidebars.ts` builds the reference sidebar with `{type: 'autogenerated', dirName: 'reference'}`; its own comment says adding a segment is one file and no sidebar edit, and `dev-training/README.md` § "Adding a segment" says the same. The category label and order come from `dev-training/docs/reference/_category_.json`, which needs no change either.

**No new module segment is proposed.** Module 3 has a segment for each subject already (3.3 install, 3.5 skills, 3.6 write, check, fix). A new segment would need the entry in `dev-training/src/data/curriculum.ts`, an entry in `dev-training/src/data/videos.ts` with kind pending, and a page `docs/module-3/<NN>-<slug>.mdx` whose numeric prefix matches its place in the run of show (`dev-training/README.md` § "Adding a segment"); because the prefix sets the order, every later page would need renaming (an inference from that rule), so inline text on the existing segments is the cheaper route. For Modules 5 and 6, which have only overview pages with a "Materials still to come" section, wait for the run of show to settle (`dev-training/src/data/curriculum.ts` carries the same advice in its Module 4 comment).

## 6. Out-of-date course text

Each row is a place where the course at commit c41996d contradicts release 0.2.2 or states what no file of the plugin repository backs. Quoted words are the course's. A row whose current fact starts `Unverified:` is repeated in section 7.

| Course file and heading | What the course says | Current fact | Source |
|-------------------------|----------------------|--------------|--------|
| `dev-training/docs/module-3/07-write-check-fix.mdx` § "What it needs" | "BBj **26.03 or later**, with the language server switched on." | The check hook compiles with `bbjcpl -t -N -X` wherever BBj is found, and asks `bbj-ls` only when no usable compiler exists; BBj 26.03 or later is the requirement of `bbj-ls`. With neither, the hook is silent except for one notice per session. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/module-3/07-write-check-fix.mdx` § "It runs on your BBjServices" | "The check runs against **your own installation** — your PREFIX, your classpath, your config." | The `bbjcpl` check runs the compiler found on the machine with `-P` directories for the file, the project and the working directory. `Unverified:` that the compiler uses the PREFIX, classpath and config; the repository states that only for `bbj-ls`. | `bbj-agent-plugins/docs/install.md#check-routes`, `bbj-agent-plugins/README.md` |
| `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx` § "What to look for in the last check" | "When the check comes back clean it reports where it ran and which BBj version judged it." | A clean file is silent in every route of the hook; only errors and the no-route notice are shown. An answer of the hosted check says `hosted check, stock BBj <version>`. `Unverified:` the wording of a `bbj-ls` answer (section 7, item 13). | `bbj-agent-plugins/docs/install.md#check-routes`, `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx` § "If the check never runs" | "It needs BBj 26.03 or later with the language server switched on." | It needs a BBj compiler the hook can find (`bbj_home`, `BBJ_HOME`, `BBJHOME`, `PATH`, default folders) or a running `bbj-ls`; with neither the hook says so once per session. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "One install, three things" | "Two commands in Claude Code; one installer script in Codex." | Codex uses the plugin: `codex plugin marketplace add BBj-AI/bbj-agent-plugins`, then `codex plugin add bbj@basis-bbj`. The script and the `AGENTS.md` snippet are in git tag 0.2.1 and absent from tag 0.2.2. | `bbj-agent-plugins/README.md`, `bbj-agent-plugins/docs/install.md#2-install` |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "Two things the Codex installer cannot do for you" | "Approving the hook, and adding the `AGENTS.md` snippet." | The remaining Codex steps are the sign-in (`codex mcp login bbj`) and trusting the hook in `/hooks`; there is no snippet. | `bbj-agent-plugins/docs/install.md#codex-trust-the-hook-in-hooks`, `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "Confirming it worked" | "a server that failed to connect looks exactly like one that was never added" | Before the sign-in `claude mcp list` shows `plugin:bbj:bbj` with `Needs authentication` and `codex mcp list` shows `Not logged in`; the course never mentions the sign-in. | `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The two skills" | "`bbj-web-programming` ... DWC and BUI theming, and DOM structure" and "**Skills are a Claude Code format.** Other clients treat them as ordinary context files, or ignore them entirely" | The skill also covers CSS and JavaScript injection, `setAttribute` against `setProperty`, Automatic Layout, web components, client form validation and DWC registration. Codex lists both skills from the plugin as `bbj:bbj-programming` and `bbj:bbj-web-programming`. | `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`, `bbj-agent-plugins/docs/install.md#2-install` |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The two skills" | ":::note[If you installed the skills by hand] An earlier route had you copy two folders ... That still works" | `Unverified:` no file of the plugin repository describes a hand install, so "still works" has no source. | none (section 7, item 7) |
| `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The commands" | ":::note[The addresses are pre-production]" ... "the server URL, the marketplace and the install commands may still change" | The manifests of release 0.2.2 carry `https://mcp.bbj-ai.com/mcp` as the default `docs_url`; the marketplace is `basis-bbj`. `Unverified:` whether that address is final. | `bbj-agent-plugins/plugins/bbj/.claude-plugin/plugin.json`, `bbj-agent-plugins/docs/install.md#options` |
| `dev-training/docs/module-3/00-overview.mdx` § "What you need" | "The setup sheet with the MCP server URL" | The setup sheet holds no server URL (the address is the default of the plugin's `docs_url` option and a fixed value in the Codex file). | `bbj-agent-plugins/plugins/bbj/.codex-mcp.json` |
| `dev-training/docs/module-3/04-exercise-3a-install-and-prove-it-works.mdx` § "The two check prompts" | "Read the MCP resource `bbj://primer` from the `bbj-docs` server" | The docs server is named `bbj`; Claude Code shows it as `plugin:bbj:bbj`. | `bbj-agent-plugins/CHANGELOG.md#022` |
| `dev-training/docs/module-2/06-comparing-claude-code-and-codex.mdx` § "Picking one" | "**skills are a Claude Code format**. Other clients treat them as ordinary context files or ignore them" | Codex lists both skills from the plugin. | `bbj-agent-plugins/docs/install.md#2-install` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "What you are installing" | "**`bbj-docs`** - the hosted documentation server" | The docs server `bbj`; the old name is retired in all user text. | `bbj-agent-plugins/CHANGELOG.md#022` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Claude Code" | "[the plugin's Claude Code install page](https://github.com/BBj-AI/bbj-agent-plugins/blob/main/docs/install-claude-code.md)" and "a `plugin:bbj:bbj-docs` line marked connected" | One install page, `docs/install.md`, covers both clients; the page named here is not in tag 0.2.2. The listing reads `plugin:bbj:bbj`. | `bbj-agent-plugins/CHANGELOG.md#022`, `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Codex" | "git clone ... cd bbj-agent-plugins ... sh codex/install-codex.sh" and "The installer approves the `bbj-docs` tools only" | Plugin commands (`codex plugin marketplace add`, `codex plugin add bbj@basis-bbj`); the plugin ships no tool approvals, so Codex asks before the first call of each tool. | `bbj-agent-plugins/docs/install.md#codex-tool-prompts-on-first-use` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Codex" | "verified on Linux with Codex CLI 0.156.1 on 8 Oct 2026. It has not yet been run on Windows or macOS." | Verified with Codex CLI 0.162.1 on Linux, Windows and macOS (what was not run is listed in the README). | `bbj-agent-plugins/README.md#verified` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Prove it works" | "With no BBj on the machine the hook is silent by design." and the footer `bbj-docs · hosted · docs` | With no compiler and no `bbj-ls`, the hook tells the agent once per session that the file was not compile-checked. `Unverified:` the footer line and its first field after the rename. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Adding the local syntax check" | "codex mcp add bbj-local --url http://127.0.0.1:5009/mcp" and the key `com.basis.languageServer.addr` ending in `:true` | The Codex command is `codex plugin add bbj-local@basis-bbj`; the step is "Enable the plugin `bbj-local`". Port 5008 in the key is correct: it is the language-server RPC port, while 5009 is the MCP endpoint (project owner, 2026-10-17). The course should say which number is which. `Unverified:` the key name and its `:true` suffix. | `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local` |
| `dev-training/docs/reference/01-mcp-setup-sheet.mdx` § "Upgrading from a hand install" | "claude mcp remove bbj-docs -s user" and "delete the `[mcp_servers.bbj-docs]` table ... before running the installer" | The old name and the script are retired. Updating the plugin is `claude plugin marketplace update basis-bbj` and `claude plugin update bbj@basis-bbj` (Claude Code), `codex plugin marketplace upgrade basis-bbj` and `codex plugin add bbj@basis-bbj` (Codex). | `bbj-agent-plugins/CHANGELOG.md#022`, `bbj-agent-plugins/docs/install.md#update-and-remove` |
| `dev-training/docs/reference/02-syntax-checking.mdx` § "The loop" | "It sends the draft to `bbj_check_syntax`" | The hook compiles every BBj file the agent writes (`Write`, `Edit`, `apply_patch`); `bbj_check_syntax` is the agent's own call for code it hands back without writing a file. | `bbj-agent-plugins/README.md#the-check-hook`, `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md` |
| `dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted" | "Registered as ... `bbj-local` ... `bbj-docs` (the server you already have)" | The plugin `bbj-local` registers `bbj-ls`; the hosted check is `bbj_check_syntax` of the docs server `bbj`. The `bbjcpl` check, which the hook tries first, is missing from the table. | `bbj-agent-plugins/README.md`, `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted" | ":::warning[The hosted check is not deployed yet]" | `Unverified:` whether the hosted check is deployed. The install page says "Where BASIS runs the hosted check next to the docs server". | none (section 7, item 1) |
| `dev-training/docs/reference/03-trusting-an-answer.mdx` § "The identity footer" | "bbj-docs · hosted · docs · 2026-10-02 · a1b2c3d" | `Unverified:` the footer line and its first field after the rename; no file of the plugin repository states a footer. | none (section 7, item 3) |
| `dev-training/docs/reference/03-trusting-an-answer.mdx` § "What the docs server gives you" | "**A style label** - `PRO/5-style` ... or `modern (BBj only)`" | `Unverified:` the label; no file of the plugin repository states it. | none (section 7, item 2) |
| `dev-training/docs/reference/04-data-handling.mdx` § "What the server does with your requests" | "There are no accounts, no sign-in and no per-user profile." | The docs server `bbj` asks for a one-time OAuth sign-in in both clients. | `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup" | "With none of those it is silent by design." and "or a running `bbj-local`" | The `bbj_home` option is a route too; the hook asks `bbj-ls` itself and does not need the plugin `bbj-local`; with no route it gives the once-per-session notice. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup" | "the address may have changed" (server not connected) | Check the sign-in first: `Needs authentication` (Claude Code) or `Not logged in` (Codex). | `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/reference/07-troubleshooting-guide.mdx` § "Setup" | "**`bbj-local` will not connect.** It needs BBj 26.03 or later and the language server switched on" | The plugin installs disabled and must be enabled; it needs BBjServices 26.03 or later running. `Unverified:` the `BBj.properties` key. | `bbj-agent-plugins/docs/install.md#4-enable-the-plugin-bbj-local` |
| `dev-training/docs/reference/08-glossary.mdx` | "**`bbj-docs`** - the hosted BBj documentation MCP server" and "**`bbj-local`** - the MCP endpoint served by `bbj-ls`" | The docs server `bbj`; the plugin `bbj-local` registers `bbj-ls` with the client. | `bbj-agent-plugins/README.md` |
| `dev-training/docs/reference/11-course-reference-sheet.mdx` § "Installing the BBj plugin" | "git clone ... sh codex/install-codex.sh" | As the setup sheet's Codex row above. | `bbj-agent-plugins/README.md` |
| `dev-training/docs/reference/11-course-reference-sheet.mdx` § "Confirming the plugin connected" | "You are looking for a `bbj-docs` line marked connected." | `plugin:bbj:bbj` in Claude Code, `bbj` in Codex, after the sign-in. | `bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj` |
| `dev-training/docs/reference/11-course-reference-sheet.mdx` § "Switching on the BBj language server" | "**For Module 3's check hook** — one line in `BBj.properties`" | The hook uses the `bbjcpl` check first and needs no `BBj.properties` line for it. `Unverified:` the line itself. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/docs/start-here/02-prerequisites.mdx` § "Before Module 3" | "Nothing to do in advance" and "The language server switched on" for the local check | Requirements are Claude Code 2.1.281 or later or a Codex CLI with plugin support, a browser for the sign-in, and Git for Windows on Windows. | `bbj-agent-plugins/docs/install.md#requirements`, `bbj-agent-plugins/docs/install.md#windows` |
| `dev-training/docs/module-1/04-installing-the-bbj-extension.mdx` § "The written guide: BBjServices and the Language Server" | ":::note[Also needed in Module 3] Module 3's check hook needs the language server too, configured through `BBj.properties`" | As the first row: the hook needs a compiler or `bbj-ls`, and the repository does not state a `BBj.properties` step. | `bbj-agent-plugins/docs/install.md#check-routes` |
| `dev-training/COURSE-NOTES.md` § "1. The MCP addresses and install routes are not final" | "`https://bbj-mcp.basis-europe.eu/mcp`" (pre-production) and "`https://bbj-mcp.basis.cloud/mcp`" (production) | The manifests of release 0.2.2 carry `https://mcp.bbj-ai.com/mcp`. The note's claim that every address "lives in **one place**", the setup sheet, no longer holds: the sheet holds no docs server address. | `bbj-agent-plugins/plugins/bbj/.codex-mcp.json` |
| `dev-training/COURSE-NOTES.md` § "3. Module 3's install narration is out of date" | "two commands in Claude Code, one installer script in Codex" | Plugin commands in both clients, as in the first Codex row. | `bbj-agent-plugins/README.md` |

## 7. Unverified items and open questions

Items 1 to 14 are claims or states that no file of `bbj-agent-plugins` backs, or that the course states and the repository does not. They need an answer from BASIS or a run on a real machine before they are taught as fact.

1. **Is the hosted check deployed?** The course says it is not (`dev-training/COURSE-NOTES.md` § "4. The hosted syntax check is not deployed"). The install page says "Where BASIS runs the hosted check next to the docs server, as on the hosted server, the server also lists" the three tools (`bbj-agent-plugins/docs/install.md#3-sign-in-to-the-docs-server-bbj`). No file settles it. `Unverified:` until BASIS confirms.
2. **The style label** (`PRO/5-style` and `modern (BBj only)`) on docs-server answers, taught in `dev-training/docs/reference/03-trusting-an-answer.mdx` § "What the docs server gives you" and the glossary. `Unverified:` no file of the plugin repository states it.
3. **The identity footer line** and whether its first field still reads the old name after the rename (`dev-training/docs/reference/03-trusting-an-answer.mdx` § "The identity footer"). `Unverified:`.
4. **The owner of the data-handling statement**, and whether its line "no sign-in" is to be changed for the one-time OAuth sign-in. The copy in the course is the published statement of record (`dev-training/COURSE-NOTES.md` § "5. The data-handling statement now lives here, and needs an owner"); the plugin repository only links the hosted server's page, `https://mcp.bbj-ai.com/data-handling`. Decision needed from the statement's owner, not from the course.
5. **The `BBj.properties` key** `com.basis.languageServer.addr` and its value ending in `:true`, taught in four course pages (section 6). The port is settled: 5008 is the language-server RPC port that this key sets, and 5009 is the MCP endpoint the plugin uses (project owner, 2026-10-17). `Unverified:` the key name and the meaning of `:true`. `README.md` and `docs/install.md` of this repository now name `127.0.0.1:5009` as the MCP endpoint and 5008 as the RPC port.
6. **Whether the `bbjcpl` check uses the installation's PREFIX, classpath and config.** The README states this for `bbj-ls` and the plugin `bbj-local`. `Unverified:` for the compiler.
7. **A hand install "still works"** (`dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx` § "The two skills"). `Unverified:` no file of the plugin repository describes a hand install; remove the sentence or get a source.
8. **Is `https://mcp.bbj-ai.com/mcp` the final production address?** It is the default in release 0.2.2; the course notes call their addresses pre-production. `Unverified:` finality.
9. **The minimum BBj version for the `bbjcpl` check.** The repository states BBj 26.03 for `bbj-ls`, and all runs used BBj 26.03. `Unverified:` whether an older BBj compiler is supported.
10. **The Codex pre-approval key** `plugins."bbj@basis-bbj".mcp_servers.bbj` with `approval_mode = "approve"`. The install page says it is from the Codex documentation and was not tried. Do not teach it as verified.
11. **The Codex tool prompt itself** was not watched in the recorded runs (`bbj-agent-plugins/docs/install.md#codex-tool-prompts-on-first-use`); do not show a screenshot as verified.
12. **The VS Code extension.** The install page assumes the `claude` CLI; the course installs Claude Code as a VS Code extension (`dev-training/docs/module-2/02-meet-claude-code-and-codex.mdx` § "In this video"). Whether plugin, sign-in and hook work from the extension alone is an open todo of the plugin repository, not shipped (`bbj-agent-plugins/.planning/todos/pending/2026-10-16-vscode-extension-install-route.md`, maintainer record).
13. **What `bbj_format` and `bbj_denum` do.** The repository gives their names and says they are tools of `bbj-ls` and of the hosted check. The course's one-line purposes (`dev-training/docs/reference/02-syntax-checking.mdx` § "The three tools") are `Unverified:`, and so is the wording of the summary line of a `bbj-ls` answer that the course quotes (`dev-training/docs/reference/02-syntax-checking.mdx` § "Reading the result").
14. **Older client versions.** The plugin repository has a pending todo to refuse versions older than the tested ones and a pending todo on social sign-in for the hosted server (`bbj-agent-plugins/.planning/todos/pending/2026-10-16-refuse-untested-client-versions.md`, `bbj-agent-plugins/.planning/todos/pending/2026-10-16-social-sign-in-needs-no-client-change.md`; maintainer records, nothing shipped). Until the first ships, state the tested versions only.

Not Unverified but not run (so not to be claimed): the list in section 3.2 under "What was verified, and what was not".

**Decisions the course maintainers need to take.**

- Whether the setup sheet keeps its own copy of the commands or only links to the install page. Recommendation: keep the commands (the course rule is that the sheet owns them), link everything else.
- Whether the Module 3 demos run on the `bbjcpl` check or on `bbj-ls`. The hook tries `bbjcpl` first; a demo machine with BBj installed shows `bbjcpl reported`.
- Whether to rename the page slugs and `_category_.json` labels that still carry the old terms; no Module 3 file name carries the old name, but `dev-training/docs/reference/01-mcp-setup-sheet.mdx` still has the old name inside the text (section 6).
- Who re-reads this handoff against the next plugin release; the quoted facts are those of 0.2.2.

## 8. Sources

**Plugin repository (`bbj-agent-plugins`, commit 84089f8; shipped files identical to git tag `0.2.2`, commit 979e457).** For the check hook, the docs server, the skills, `bbj-local`, the Codex route, install, architecture and the do's and don'ts:

- Shipped text: `bbj-agent-plugins/README.md`, `bbj-agent-plugins/CHANGELOG.md`, `bbj-agent-plugins/docs/install.md`.
- Manifests and registrations: `bbj-agent-plugins/.claude-plugin/marketplace.json`, `bbj-agent-plugins/plugins/bbj/.claude-plugin/plugin.json`, `bbj-agent-plugins/plugins/bbj-local/.claude-plugin/plugin.json`, `bbj-agent-plugins/plugins/bbj/.codex-plugin/plugin.json`, `bbj-agent-plugins/plugins/bbj/.mcp.json`, `bbj-agent-plugins/plugins/bbj-local/.mcp.json`, `bbj-agent-plugins/plugins/bbj/.codex-mcp.json`.
- Check hook: `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`, `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment).
- Skills: `bbj-agent-plugins/plugins/bbj/skills/bbj-programming/SKILL.md`, `bbj-agent-plugins/plugins/bbj/skills/bbj-web-programming/SKILL.md`.
- Maintainer records (not shipped): `bbj-agent-plugins/.claude/CLAUDE.md` (terms), `bbj-agent-plugins/tests/test_never_execute.sh`, `bbj-agent-plugins/.planning/todos/pending/2026-10-16-vscode-extension-install-route.md`, `bbj-agent-plugins/.planning/todos/pending/2026-10-16-refuse-untested-client-versions.md`, `bbj-agent-plugins/.planning/todos/pending/2026-10-16-social-sign-in-needs-no-client-change.md`.

**Course repository (`dev-training`, commit c41996d, read only).** Files whose text or headings are cited:

- Start here and Modules 1, 2: `dev-training/docs/start-here/02-prerequisites.mdx`, `dev-training/docs/module-1/04-installing-the-bbj-extension.mdx`, `dev-training/docs/module-2/02-meet-claude-code-and-codex.mdx`, `dev-training/docs/module-2/06-comparing-claude-code-and-codex.mdx`.
- Module 3: `dev-training/docs/module-3/00-overview.mdx`, `dev-training/docs/module-3/02-what-mcp-is.mdx`, `dev-training/docs/module-3/03-installing-the-bbj-plugin.mdx`, `dev-training/docs/module-3/04-exercise-3a-install-and-prove-it-works.mdx`, `dev-training/docs/module-3/05-watching-it-look-things-up.mdx`, `dev-training/docs/module-3/06-what-skills-are.mdx`, `dev-training/docs/module-3/07-write-check-fix.mdx`, `dev-training/docs/module-3/08-exercise-3b-ask-and-verify.mdx`, `dev-training/docs/module-3/09-putting-it-together.mdx`, `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx`, `dev-training/docs/module-3/11-project-instructions.mdx`, `dev-training/docs/module-3/12-prompting-habits.mdx`.
- Modules 5, 6: `dev-training/docs/module-5/00-overview.mdx`, `dev-training/docs/module-6/00-overview.mdx`.
- Reference: `dev-training/docs/reference/00-overview.mdx`, `dev-training/docs/reference/01-mcp-setup-sheet.mdx`, `dev-training/docs/reference/02-syntax-checking.mdx`, `dev-training/docs/reference/03-trusting-an-answer.mdx`, `dev-training/docs/reference/04-data-handling.mdx`, `dev-training/docs/reference/07-troubleshooting-guide.mdx`, `dev-training/docs/reference/08-glossary.mdx`, `dev-training/docs/reference/11-course-reference-sheet.mdx`, `dev-training/docs/reference/_category_.json`.
- Site and working notes: `dev-training/sidebars.ts`, `dev-training/src/data/curriculum.ts`, `dev-training/src/data/videos.ts`, `dev-training/README.md`, `dev-training/COURSE-NOTES.md`, `dev-training/SUPPLEMENTAL-SHEETS.md`.
