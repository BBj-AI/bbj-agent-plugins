# DWC styling: themes, component attributes, shadow parts

## Themes

Page: https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setTheme.htm
Page: https://dwc.style/docs/#/dwc/guide/themes
Page: https://docs.webforj.com/docs/styling/themes

- Themes are for the DWC only. `BBjWebManager.setTheme`: "Themes are only meaningful in the DWC client."
  `setDarkTheme` and `setLightTheme` say the same, and the themes guide adds "setTheme is honored only by
  the DWC client."
- `setTheme` takes the theme name: "theme Specifies a DWC theme name ("light", "dark", "dark-pure"), or
  "system" to use the system default theme." The themes guide: "DWC ships three application themes out of
  the box"; its table lists `dark-pure` as a dark theme with the tint "None (pure neutral grays)". The guide
  adds: "The method accepts the name of any built-in or custom theme." The three names above are the built-in
  ones.
- Calling it again switches the theme: "Calling it again at any time switches the application to a different
  theme." and "Switching themes recalculates colors, shadows, surfaces, and borders across the whole
  application instantly, with no rebuild."
- `setDarkTheme` and `setLightTheme` name the theme to use for each appearance state. `setDarkTheme`: "this
  method sets the name of the theme to use when a DWC application has specified the system theme option with
  setTheme("system") and the user has configured their system to use dark mode." `setLightTheme` is the same
  for light mode.
- `setTheme("system")` follows the user's system: "DWC resolves it at runtime to either the registered light
  or dark theme and re-resolves automatically whenever the OS preference changes."
- `data-app-theme` holds the resolved name: "Once resolved, the actual data-app-theme attribute on the page
  is light or dark", so "any CSS overrides should target those names rather than "system"".

Register the dark and light theme, then switch to `"system"`:

```bbj
declare auto BBjWebManager web!
web! = BBjAPI().getWebManager()
web!.setDarkTheme("dark")
web!.setLightTheme("light")
web!.setTheme("system")
```

## Overriding a theme

Page: https://dwc.style/docs/#/dwc/guide/themes
Page: https://docs.webforj.com/docs/styling/themes

- Light: "The light theme is the default and is scoped to :root. Override it by setting tokens in :root:"
- Dark: "Override dark and dark-pure inside their matching data-app-theme selectors:"
- A new theme: "Pick a unique name and define it under its own data-app-theme block:" and "Activate a new
  theme by name:", whose example is `web!.setTheme("brand")`. For the `brand-dark` block below that is
  `web!.setTheme("brand-dark")`.
- A custom dark theme sets `--dwc-dark-mode: 1` and `color-scheme: dark` on its selector. The guide: "The
  built-in dark and dark-pure themes already set color-scheme: dark for you" and "Light themes don't need the
  declaration - browsers default to light."
- The theme stylesheet is loaded with `injectStyle` (CSS text: "In BBj 22.03 and higher, this method injects
  the specified CSS into the web page.") or `injectStyleUrl` ("this method injects the specified external CSS
  URL into the web page."). The themes guide uses `injectStyleUrl` for its brand stylesheet.
- The tokens are listed at https://docs.webforj.com/docs/styling/ and not repeated here.

The three selector forms, with the values the themes pages use (the `brand-dark` block is the dark variant
of a new theme in the dwc.style themes guide):

```css
:root {
  --dwc-color-primary-h: 215;
  --dwc-color-primary-s: 100%;
}

html[data-app-theme="dark"] {
  --dwc-color-primary-seed: #a855f7;
}

html[data-app-theme="brand-dark"] {
  --dwc-dark-mode: 1;
  --dwc-color-primary-seed: #a855f7;
  color-scheme: dark;
}
```

## Component theme and expanse

Page: https://dwc.style/docs/#/dwc/BBjButton
Page: https://dwc.style/docs/#/dwc/guide/themes

Both are attributes, set with `setAttribute` (SKILL.md, "Attributes and properties").

- `theme`: "individual components accept a theme attribute that picks from the semantic palette set: default,
  primary, success, warning, danger, info, gray. This is independent of the active application theme." The
  BBjButton page lists the values.
- `expanse`: "Most BBj controls support an expanse attribute that unifies their size across the design
  system." and "The standard scale runs xs, s, m, l, xl, and a few controls extend it (icon buttons go down
  to 2xs and up to 3xl)."
- The default: "By default a BBj control is created with no expanse." and "Without expanse and without
  explicit BBj sizing, controls can render at inconsistent dimensions across the page."
- Every component has its own page with its attributes, for example
  https://dwc.style/docs/#/dwc/BBjColorChooser.

```bbj
declare auto BBjSysGui sysgui!
declare auto BBjTopLevelWindow win!
declare auto BBjButton button!
sysgui! = BBjAPI().openSysGui("X0")
win! = sysgui!.addWindow("Theme", $00100083$)
button! = win!.addButton("Save")
button!.setAttribute("theme", "primary")
button!.setAttribute("expanse", "l")
process_events
release
```

## Shadow parts

Page: https://dwc.style/docs/#/theme-engine/css-shadow-parts

- "Inner elements of a Shadow DOM cannot be targeted directly with CSS."
- "Shadow parts allow you to style inside a shadow tree from the outside."
- "You can find the list of exposed parts under the `Shadow Parts` section of the component documentation."
  The BBjListBox page, https://dwc.style/docs/#/dwc/BBjListBox, is one example.

The HTML of a BBjListBox item is inside the control's shadow root, so a page selector does not reach it while an inline style attribute does. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

## Focus ring

Page: https://docs.webforj.com/docs/upgrading/webforj-26.00/design-system
Page: https://docs.webforj.com/docs/styling/state

- The documentation calls it the focus ring: "When a component receives focus, a focus ring is shown around
  it to indicate its active state." The state page lists `--dwc-focus-ring-width` (2px, "Thickness of the
  focus ring") and `--dwc-focus-ring-gap` (2px, "Gap between the component edge and the ring").
- The upgrade guide: "If you reserve space around focusable elements with --dwc-focus-ring-width, add
  --dwc-focus-ring-gap to the padding." Its example:

```css
dwc-button {
  padding: calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap));
}
```

An ancestor with overflow hidden or overflow auto clips the focus ring of a control, and padding of calc(var(--dwc-focus-ring-width) + var(--dwc-focus-ring-gap)) on that ancestor avoids it. That is the rule the skill maintainer confirmed on BBj 26.03; the documentation does not state it.

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setTheme.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setDarkTheme.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setLightTheme.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyle.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjBuiManager_injectStyleUrl.htm
- https://dwc.style/docs/#/dwc/guide/themes
- https://dwc.style/docs/#/dwc/BBjButton
- https://dwc.style/docs/#/dwc/BBjColorChooser
- https://dwc.style/docs/#/dwc/BBjListBox
- https://dwc.style/docs/#/theme-engine/css-shadow-parts
- https://docs.webforj.com/docs/styling/
- https://docs.webforj.com/docs/styling/themes
- https://docs.webforj.com/docs/styling/state
- https://docs.webforj.com/docs/upgrading/webforj-26.00/design-system
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probes p08, p11)
