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
- Files under `bbj-agent-plugins/.planning/` and `bbj-agent-plugins/.claude/` are maintainer records, not
  shipped text; they are cited only where a user-facing file does not hold the fact, and each such
  citation says so.

**Terms the course should use.** The plugin repository fixes one name for each thing (maintainer source:
`bbj-agent-plugins/.claude/CLAUDE.md`, section Terms; the same names run through
`bbj-agent-plugins/README.md` and `bbj-agent-plugins/docs/install.md`). The older names that course pages
still use are listed in section 6 with the replacement.

| Term | Meaning |
|------|---------|
| the docs server `bbj` | The hosted BBj docs server. Always written with its role noun. |
| the hosted check | `bbj_check_syntax` of the docs server `bbj`. It sends the code to the server and checks it against a stock BBj. |
| the `bbjcpl` check | The hook's compile-only check, `bbjcpl -t -N -X`: syntax and types. |
| `bbj-ls`, the BBj language server in BBjServices | Listens on `127.0.0.1:5009`; checks syntax only. |
| the plugin `bbj-local` | The opt-in plugin that registers `bbj-ls` with the client, so the agent can call `bbj_check_syntax` itself. Its install step is headed "Enable the plugin `bbj-local`". |
| the plugin `bbj` | The main plugin: the docs server `bbj`, the two skills and the check hook. |
| tier 1 and tier 2 | Maintainer terms for the `bbjcpl` check and the `bbj-ls` check. Use them in a maintainer page at most; an attendee page names the checks. |

## 2. The plugin in one page

## 3. Subjects for the course

### 3.1 Features and functions

#### 3.1.1 The check hook

**What an attendee needs to know**

- After every `Write` or `Edit` of a `.bbj`, `.src` or `.bbx` file, the hook compiles the file with
  `bbjcpl -t -N -X`, which checks syntax and types. A compile error goes back to the agent (exit code 2) with
  the compiler's own lines; a clean file and a non-BBj file are silent. Source:
  `bbj-agent-plugins/README.md#the-check-hook`.
- Codex checks the files a patch names through `apply_patch`: a file named by an `*** Add File:`,
  `*** Update File:` or `*** Move to:` line. A path outside the working directory is skipped. Source:
  `bbj-agent-plugins/docs/install.md#not-covered`.
- The hook never runs BBj code (it compiles with `-N`, which writes no output) and sends nothing off the
  machine; it does not use the hosted check. Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- BBj is found in this order: the `bbj_home` option (Claude Code), `BBJ_HOME`, `BBJHOME`, `bbjcpl` on
  `PATH`, then `/c/bbx` (`C:\bbx` on Windows), `/Applications/bbx`, `/usr/local/bbx` and `/opt/bbx`. Source:
  `bbj-agent-plugins/docs/install.md#check-routes`.
- The failing message starts `bbjcpl reported N error(s) in <file>:` and then holds the compiler's lines, at
  most 40. Source: `bbj-agent-plugins/docs/install.md#check-routes`.
- With no usable compiler the hook asks `bbj-ls` instead, on `127.0.0.1:5009`. That check is syntax only and
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

### 3.2 Installing and using it

### 3.3 Architecture

### 3.4 Do's and don'ts

## 4. Placement map

| Subject | Existing course location | Action | Notes |
|---------|--------------------------|--------|-------|
| The check hook | `dev-training/docs/module-3/07-write-check-fix.mdx` § "What it needs", "It runs on your BBjServices"; `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx` § "If the check never runs"; `dev-training/docs/reference/02-syntax-checking.mdx` § "Local and hosted" | Correct, then extend | Add the routes and the three messages; the course says the check needs the language server, the hook needs a compiler first. Course rule: inline on the segment page and a reference page (`dev-training/SUPPLEMENTAL-SHEETS.md` § "Where each one should live"). |

## 5. New pages to add

## 6. Out-of-date course text

| Course file and heading | What the course says | Current fact | Source |
|-------------------------|----------------------|--------------|--------|
| `dev-training/docs/module-3/07-write-check-fix.mdx` § "What it needs" | "BBj **26.03 or later**, with the language server switched on." | The check hook compiles with `bbjcpl -t -N -X` wherever BBj is found, and asks `bbj-ls` only when no usable compiler exists; BBj 26.03 or later is the requirement of `bbj-ls`. With neither, the hook is silent except for one notice per session. | `bbj-agent-plugins/docs/install.md#check-routes` |

## 7. Unverified items and open questions

## 8. Sources

**Plugin repository (`bbj-agent-plugins`, commit 84089f8, tag `0.2.2` at 979e457)**, for the check hook:

- `bbj-agent-plugins/README.md` ("The check hook").
- `bbj-agent-plugins/docs/install.md` ("Check routes", "Not covered", "Windows", "Codex: trust the hook in /hooks").
- `bbj-agent-plugins/plugins/bbj/hooks/hooks.json`.
- `bbj-agent-plugins/plugins/bbj/scripts/bbj-check.sh` (header comment).
- `bbj-agent-plugins/.claude/CLAUDE.md` (maintainer source, terms only).

**Course repository (`dev-training`, commit c41996d)**, for the check hook:

- `dev-training/docs/module-3/07-write-check-fix.mdx`
- `dev-training/docs/module-3/10-exercise-3c-run-the-loop-yourself.mdx`
- `dev-training/docs/reference/02-syntax-checking.mdx`
- `dev-training/SUPPLEMENTAL-SHEETS.md`
