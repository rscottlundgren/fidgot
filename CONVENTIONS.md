# Conventions

How shell code in this repo is written: the scripts (`*.sh`, bash) and the zsh
config (`profiles/common/zsh/`). The tests in
[`tests/hygiene_test.go`](tests/hygiene_test.go) check the parts marked
_checked_; `tests/run.sh` runs them.

The zsh config has a few rules of its own on top of these (the shellcheck line,
zsh's special parameters, what a functions file may hold): see
[its README](profiles/common/zsh/README.md#conventions).

## Sections

Shell has no standard for section headers, so files use two levels of comment
rule (_checked_: their widths):

```sh
# --- Section ------------------------------------------------------------------
# ------ Subsection ----------------------------------------
```

The number of leading dashes gives the level. A section rule runs to column 80;
a subsection rule stops at column 60, so it reads as one level down. A line or
two of comment under a rule says what the block is for. Subsections group one
tool or toolchain each (Node, Go, Rust, ...); a section with a single block
doesn't need them.

## Line length

Lines stay within 80 columns (_checked_), as in the
[Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html#line-length-and-long-strings)
and Zed's wrap guide for shell scripts. To shorten a line:

- Break after `&&`, `||` or `|`; the command carries on to the next line.
- End a line with `\` between a command's arguments.
- Turn a long one-liner guard into an `if` block.
- Put a long path in a variable (and `unset` it after, in the zsh config).
- Split a long message into several quoted strings: `echo` joins its arguments
  with spaces, and so does `install.sh`'s `manual_step`.

A URL can't be split, so a line with one may run past 80. Put the URL in a
variable on its own line, so only that line is long.

## Comments

Comments go on their own line, above the code they describe, not at the end of a
line. An end-of-line comment either pushes the line past 80 columns or has to be
lined up by hand.

## Names

Variables use full words: `brewfile`, `directory`, `arguments`, `task`, not `f`,
`dir`, `args`, `m`. Variables inside a function are `local`. Pick a name for
what the value is: `install.sh`'s `link()` uses `target` and `link_name`, the
terms `ln -s <target> <link_name>` uses.

Names another tool reads stay as they are, such as `NVM_DIR`, `JAVA_HOME`,
`HOMEBREW_PREFIX` and `HOMEBREW_BUNDLE_NO_UPGRADE`. Avoid names that are also
shell commands or keywords, such as `source`, `test`, `local` or `time`: they're
legal as variable names (except `time` in zsh), but confusing next to the
command.

## Linting

Every script passes shellcheck and shfmt (_checked_). shfmt takes its 2-space
indent from [`.editorconfig`](.editorconfig).
