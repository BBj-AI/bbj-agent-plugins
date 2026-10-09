## BBj (BASIS)

Before you write or review BBj code, read the resource `bbj://primer` from the `bbj-docs` MCP
server: the BBj language primer, the rules agents usually get wrong, each with its source.

Tools of `bbj-docs`:

- `bbj_lookup`: exact syntax for a named symbol (verb, function, mnemonic, BBjAPI class or
  method, event or SETOPTS bit).
- `bbj_examples`: verified code examples.
- `bbj_reserved_word`: check a name before you use it for a variable.
- `bbj_search`: documentation search for everything else.
- `bbj_fetch_page`: the full text of one documentation page.

Cite the URL of every documentation page you rely on.

Style: PRO/5-style syntax is valid BBj and is answered fully. The modern Java-object form
(`a!`, BBjAPI, `PROCESS_EVENTS`, DWC) is preferred for new code. Say in every answer which
style it uses.

Built in: no USE needed. USE is only for Java classes (`USE java.util.HashMap`) and classes from BBj source files (`USE ::file.bbj::ClassName`).

<!-- bbj-check-order:begin -->
**Check BBj code before you hand it back.** Use the first route that exists:

1. `bbjcpl -t -N -X <file>`, when BBj is installed on this machine. It checks syntax and types. `-N` writes no output files; the errors arrive on stderr.
2. `bbj_check_syntax` of the `bbj-local` server (the `bbj-ls` of a running BBjServices, BBj 26.03 or later), when that server is registered. It runs on this machine, against the installation's own PREFIX, classpath and config. It checks syntax only, not types.
3. Only when neither exists: `bbj_check_syntax` of the `bbj-docs` server, the hosted check. You may use it without asking, but tell the user that the code was sent to the server and checked against a stock BBj, not against their installation.

A hook checks the BBj files you write or edit. This order is for code you hand back without writing it to a file: answers, and code from earlier turns.
<!-- bbj-check-order:end -->

In Codex only `apply_patch` calls reach the hook; files written through shell commands are not checked.
