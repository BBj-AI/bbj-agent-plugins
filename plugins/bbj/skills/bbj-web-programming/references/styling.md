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
  the box"; its table lists `dark-pure` as a dark theme with the tint "None (pure neutral grays)".
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

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setTheme.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setDarkTheme.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bui/BBjBuiManager/BBjWebManager_setLightTheme.htm
- https://dwc.style/docs/#/dwc/guide/themes
- https://docs.webforj.com/docs/styling/themes
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probe p11)
