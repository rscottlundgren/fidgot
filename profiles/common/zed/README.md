# Zed

The whole Zed folder is linked (not just `settings.json`) so Zed's own saves,
which write a temp file and rename it, stay inside the repo instead of replacing
a file-level link. Zed's prompt-library database and `*.bak-*` backups live
there too but are git-ignored.

Zed settings include per-language column rulers (`wrap_guides`) set to each
language's community line length (PEP 8, Prettier, RuboCop, swift-format,
clang-format, …); see the comments in `settings.json`.
