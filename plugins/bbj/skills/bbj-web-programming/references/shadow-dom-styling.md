# Styling inside DWC controls: shadow DOM, parts, and HTML content

Every BBj control renders in DWC as a web component, and **some of them put their
content inside a shadow root**. A page-level stylesheet — whether injected at
`top=0` (body) or `top=1` (head), whether by class, descendant, tag or attribute
selector — **cannot cross that boundary**. Nothing errors. The rule is simply
never applied, and the markup renders unstyled with no clear cause: it could be
the shadow boundary, a sanitised `class` attribute, or an injection that never
landed.

This file is the map of what actually works, established by probing a real app
rather than by reading docs.

---

## The one-minute version

| You want to style | Reachable from a page stylesheet? | Use |
|---|---|---|
| A control's own box (`dwc-button`, `dwc-panel`, …) | ✅ yes | `addClass()` + a normal selector |
| A part the control exposes | ✅ yes | `::part(item)`, `::part(control)`, … |
| HTML you put in a **BBjStaticText** | ✅ yes | ordinary selectors — it is light DOM |
| HTML you put in a **BBjListBox item** | ❌ **no** | inline `style=`, or the two tricks below |
| A slotted child (`setSlot()`) | ✅ yes | ordinary selectors — slotted content stays in light DOM |

**Custom properties are the exception to all of it.** `var(--my-token)` inherits
*through* shadow boundaries, so tokens defined on `:root` reach every stylesheet
inside every shadow root. Theming works even where selectors do not.

---

## Diagnosing "my CSS is not applying"

Three different causes produce **identical** symptoms — text renders, styling
does not:

1. the content is behind a shadow boundary,
2. DWC sanitised the attribute you are selecting on (e.g. `class`),
3. the injection never landed.

Do not guess between them. Drop probe rows in and read the colours off the
screen — each one styles itself a different way and says what it should look
like:

```bbj
REM Injected at top=0 (body)
css! = ".pA{color:red;font-weight:900}"
css! = css! + ".probe b{color:purple;font-weight:900}"
css! = css! + "[data-probe]{color:orange;font-weight:900}"
BBjAPI().getWebManager().injectStyle(css!, 0, "id=probeBody")

REM Injected at top=1 (head)
BBjAPI().getWebManager().injectStyle(".pB{color:blue;font-weight:900}", 1, "id=probeHead")

items!.add("<html><span class='pA'>A class, body-injected -> RED</span></html>")
items!.add("<html><span class='pB'>B class, head-injected -> BLUE</span></html>")
items!.add("<html><b>D bare TAG selector -> PURPLE</b></html>")
items!.add("<html><span data-probe='1'>E attribute selector -> ORANGE</span></html>")
items!.add("<html><span style='color:magenta;font-weight:900'>F inline -> MAGENTA</span></html>")
```

Reading the result:

- **Only F coloured** → shadow DOM. No page selector of any kind gets in.
- **D or E coloured, A/B/C not** → not shadow DOM; the `class` attribute is
  being stripped. Switch to tag or `data-*` selectors and page CSS works.
- **A coloured, B not** → injection position matters; prefer `top=0`.

Running exactly this on a `BBjListBox` gave **only F** — so item content is
shadow DOM, and it is *not* an attribute-stripping problem.

---

## Three ways into a shadow root

### 1. `::part()` — for what the control chooses to expose

Only works for parts the component declares, but it is the cleanest route and
survives upgrades:

```css
.watchRail::part(control)       { overflow-x: hidden; }
.watchRail::part(item)          { padding: 0.35em 0.5em; border-radius: 0.6em; }
.watchRail::part(item-selected) { background-color: var(--accent-bg); }
```

Check the control's docs for its part names. You cannot invent one, and you
cannot add a part to markup you inject yourself.

### 2. A `<style>` element inside the content

A `<style>` that is part of the HTML you hand the control is inserted **on the
shadow side** of the boundary, so it styles the whole shadow tree:

```bbj
blk$ = "<style>.row{display:flex;gap:0.6em}.label{opacity:0.7}</style>"
items!.add("<html>" + blk$ + "<div class='row'>…</div></html>")   REM item 0 only
```

Two things follow from *where* it lives:

- Put it in the **first item only**. Every item is in the same shadow root, so
  one copy styles them all.
- It **dies with that item**. `removeAllItems()` destroys it, so it must be
  re-sent on every rebuild. Fine for a kilobyte of layout rules; wrong for
  anything large.

**This also reaches the control's own internals**, which `::part()` cannot
always express — the stylesheet is inside the tree, so part attributes are just
attributes:

```bbj
REM A list sizes every item to the WIDEST item's content, so one long value
REM widens every row. Only a rule inside the root can pin the item to the control.
css! = css! + "[part~='control']{width:100%;box-sizing:border-box;overflow-x:hidden;"
css! = css! + "overflow-y:auto;scrollbar-gutter:stable}"
css! = css! + "[part~='item']{width:100%;max-width:100%;min-width:0;overflow:hidden}"
```

### 3. `adoptedStyleSheets` from JavaScript — for anything that must persist

Script can hand a stylesheet to an **open** shadow root. Unlike (2) this is
attached to the *root*, not to an item, so it **survives `removeAllItems()`**
and is sent once:

```bbj
js! = "(function(){var rule='" + #escapeForJsString(css!) + "';var n=0;"
js! = js! + "var t=setInterval(function(){"
js! = js! + "var el=document.querySelector('.watchRail');"
js! = js! + "if(el&&el.shadowRoot){"
js! = js! + "  try{var sh=new CSSStyleSheet();sh.replaceSync(rule);"
js! = js! + "      el.shadowRoot.adoptedStyleSheets=[].concat(el.shadowRoot.adoptedStyleSheets||[],[sh]);}"
js! = js! + "  catch(e){var st=document.createElement('style');st.textContent=rule;"
js! = js! + "      el.shadowRoot.appendChild(st);}"
js! = js! + "  clearInterval(t);return;}"
js! = js! + "if(++n>40){clearInterval(t);console.log('could not reach shadowRoot');}"
js! = js! + "},100);})();"
BBjAPI().getWebManager().executeAsyncScript(js!)
```

The retry loop is not optional: the custom element may not have upgraded when
the script runs. Keep the `<style>`-append fallback for engines without
`adoptedStyleSheets`.

**Choosing between (2) and (3) is a question of lifetime, not preference:**

| | Lives in | Survives a rebuild | Right for |
|---|---|---|---|
| `<style>` in item 0 | an item | ✗ re-sent each time | small layout rules |
| `adoptedStyleSheets` | the shadow **root** | ✓ sent once | large or expensive payloads |

Measured on a 136-row list with base64 thumbnails: rows carrying their own
images cost 3,944 bytes each (**523 KB per filter rebuild**); rows naming a
class whose rule lives in the shadow root cost 277 bytes each (**36 KB**).

---

## Consequences for how you build content

**Inline `style=` always works**, and for a control whose content is shadow DOM
it may be all you get. It costs roughly 1 KB per row in a list — acceptable for
a detail pane, expensive for a list you re-render constantly.

**Prefer a `BBjStaticText` when you need real CSS.** Its HTML is ordinary light
DOM. A whole grouped panel — sections, rows, `<details>` disclosures — can be one
StaticText styled entirely from the app's stylesheet, with no shadow-DOM
workarounds and one control instead of a dozen.

**Slotted children stay in light DOM.** `parent!.setSlot("prefix", icon!)` puts
the control in a slot; it renders inside the shadow tree but remains stylable
from the page. This is why web components with slots are easy to style and
list-item HTML is not.

**Custom properties cross freely.** Define the palette once on `:root` and
reference `var(--app-bg)` inside shadow-root stylesheets — that is how a control
whose internals you cannot select still follows a light/dark theme.

---

## Traps that cost real time

**A missing resource looks exactly like a styling failure.** An `<img>` with an
empty `src` renders nothing, which is indistinguishable from "DWC refused to
render the img". Make missing files fail loudly — count them, name them — or you
will debug the wrong layer.

**Escape anything you embed in `executeAsyncScript`.** CSS containing
`url('data:…')` inside a JS single-quoted string terminates that string early
and the whole script dies with `SyntaxError: Unexpected token '('`. Either drop
the quotes inside `url()` (a base64 data URI needs none — it contains no
whitespace, quotes or parens) or escape backslashes then quotes before
embedding. There is no compiler behind that boundary.

**`text-overflow: ellipsis` does nothing on an inline `<span>`.** Give it
`display:block`, and give every flex ancestor `min-width: 0` — a flex item's
default `min-width` is `auto`, meaning "at least as wide as my content", so text
refuses to shrink and pushes siblings out of view.

**A list sizes all items to the widest one.** If one row is too wide, *every*
row is. Constraining your own markup cannot fix it: `width: 100%` of a
content-sized parent is still too wide. Pin the item box to the control from
inside the root (see above), and consider `scrollbar-gutter: stable` so the
usable width does not change when a scrollbar appears.

**Reserve room for the focus ring.** DWC draws it as an `outline` outside the
border box, and outlines take part in no layout calculation, so a tight toolbar
clips it and keyboard users lose their position indicator:

```css
dwc-button, dwc-field, dwc-choicebox, dwc-radio, dwc-textfield {
    padding: calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap));
}
```

**A field's label stacks above its control by default.** In a single-row toolbar
that doubles the bar height for one word:

```css
.mySearch::part(control) { display: flex; flex-direction: row; align-items: center; gap: 0.5em; }
.mySearch::part(label)   { margin: 0; white-space: nowrap; }
```
