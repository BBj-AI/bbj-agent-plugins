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

Check: after each `apply_patch`, a hook compile-checks the changed `.bbj`, `.src` and `.bbx`
files with the BBj compiler (`bbjcpl -N`) on this machine and never runs them. Files written
through shell commands are not checked.
