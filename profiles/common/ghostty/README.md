# Ghostty

- It also reads
  `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` after the
  linked file, so keep that one absent or it overrides the repo.
- The window is translucent (`background-opacity`, the one value to change).
  `background-opacity-cells` applies the same opacity to highlighted lines, diff
  colors and the Starship prompt segments. Text selection is the exception:
  Ghostty always draws it solid, so it uses a muted mustard.
- It stays transparent in fullscreen only in its own (non-native) mode: enter
  fullscreen with `cmd-enter`. The green button and `cmd-ctrl-F` use macOS
  native fullscreen, where Ghostty turns transparency off.
- The themes are tuned copies of Ghostty's Atom One in `themes/`, for
  readability over the translucent background: `Atom One Dark Bright` (brighter
  text) and `Atom One Light Deep` (darker green/red/yellow), both with the
  mustard selection. Ghostty finds them through the linked folder.
- The font is CommitMono Nerd Font **Mono**, which fits every icon into one cell
  so icons stay centered (the non-Mono variant draws some, like the Apple logo,
  wider and off-center).
