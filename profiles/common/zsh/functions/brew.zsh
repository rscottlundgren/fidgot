# Homebrew helpers, sourced by zshrc. Each one runs Homebrew's upkeep around
# what you asked for; see README.md in the folder above.

# doctor, update, upgrade, then `brew <args>` (if any), cleanup and doctor
# again. Stops if update or the command fails. A failed upgrade doesn't block
# the command, and doctor's warnings don't count as a failure.
_fidgot_brew() {
  brew doctor
  brew update || return
  brew upgrade
  if (( $# )); then
    brew "$@" || return
  fi
  brew cleanup
  brew doctor || true
}

# Brew Install - Accepts Formula / Cask Name(s) As Parameter(s)
brew-in() {
  (( $# )) || { print -u2 "usage: brew-in <formula or cask>..."; return 2; }
  _fidgot_brew install "$@"
}

# Brew Uninstall - Accepts Formula / Cask Name(s) As Parameter(s)
brew-un() {
  (( $# )) || { print -u2 "usage: brew-un <formula or cask>..."; return 2; }
  _fidgot_brew uninstall "$@"
}

# Brew Upgrade - No Parameters Needed
brew-up() {
  _fidgot_brew
}
