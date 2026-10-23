#!/usr/bin/env bash
# Set up a Mac from fidgot: Homebrew and the Brewfiles, config links,
# toolchains, Neovim plugins and the coding-agent config. Safe to rerun:
# every step checks first and skips what's already in place.
#
# Usage: ./install.sh --profile <personal|work-profile-name> [--dry-run] [--skip <steps>]
#   --profile   personal: common + personal Brewfiles and the personal agent
#               setup. Any other name is a work machine: common only, and the
#               name is passed to the agent setup as its profile.
#   --dry-run   show what would change; change nothing
#   --skip      comma-separated steps to leave out:
#               xcode,brew,links,toolchains,nvim,agents

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
profile=""
dry_run=false
skip=","
while [ $# -gt 0 ]; do
  case "$1" in
  --profile)
    profile="${2:-}"
    shift 2
    ;;
  --dry-run)
    dry_run=true
    shift
    ;;
  --skip)
    skip=",${2:-},"
    shift 2
    ;;
  -h | --help)
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
  esac
done
[ -n "$profile" ] || {
  echo "usage: $0 --profile <personal|work-profile-name> [--dry-run] [--skip <steps>]" >&2
  exit 2
}

timestamp="$(date +%Y%m%d%H%M%S)"
manual=() # things a person has to do, printed at the end

step() { printf '\n==> %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
run() {
  if $dry_run; then
    note "would run: $*"
  else
    "$@"
  fi
}
skipped() { [[ "$skip" == *",$1,"* ]]; }

# --- Xcode Command Line Tools (git, compilers) -------------------------------
if ! skipped xcode; then
  step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    note "installed"
  else
    run xcode-select --install
    echo "Finish the Command Line Tools installer, then rerun this script." >&2
    exit 1
  fi
fi

# --- Homebrew and the Brewfiles -----------------------------------------------
if ! skipped brew; then
  step "Homebrew"
  if ! command -v brew >/dev/null; then
    for prefix in /opt/homebrew /usr/local; do
      [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)"
    done
  fi
  if command -v brew >/dev/null; then
    note "installed ($(brew --prefix))"
  else
    # Homebrew's own installer (https://brew.sh); asks for an admin password
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! $dry_run; then eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"; fi
  fi

  brewfiles=("$repo/profiles/common/Brewfile")
  [ "$profile" = personal ] && brewfiles+=("$repo/profiles/personal/Brewfile")
  for f in "${brewfiles[@]}"; do
    step "Brewfile ${f#"$repo"/}"
    if command -v brew >/dev/null && brew bundle check --file "$f" >/dev/null 2>&1; then
      note "everything installed"
    else
      # Install what's missing; don't upgrade what's already there
      HOMEBREW_BUNDLE_NO_UPGRADE=1 run brew bundle install --file "$f"
    fi
  done
fi

# --- Config links ----------------------------------------------------------------
# Each line: <path in this repo> <link location>
links="
profiles/common/zsh/zshrc               $HOME/.zshrc
profiles/common/zsh/zprofile            $HOME/.zprofile
profiles/common/starship/starship.toml  $HOME/.config/starship.toml
profiles/common/ghostty                 $HOME/.config/ghostty
profiles/common/zed                     $HOME/.config/zed
profiles/common/nvim                    $HOME/.config/nvim
profiles/common/git/gitconfig           $HOME/.gitconfig
profiles/common/git/ignore              $HOME/.config/git/ignore
profiles/common/gh/config.yml           $HOME/.config/gh/config.yml
"

link() {
  local src="$repo/$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    note "ok      ${dest/#$HOME/~}"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    note "backup  ${dest/#$HOME/~} -> ${dest/#$HOME/~}.bak-$timestamp"
    run mv "$dest" "$dest.bak-$timestamp"
  fi
  note "link    ${dest/#$HOME/~} -> ${src/#$HOME/~}"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

if ! skipped links; then
  step "Config links"
  while read -r src dest; do
    [ -n "$src" ] && link "$src" "$dest"
  done <<<"$links"
fi

# --- Toolchains outside the Brewfile ------------------------------------------------
if ! skipped toolchains; then
  step "Rust (rustup)"
  rustup_bin="$(brew --prefix 2>/dev/null || echo /opt/homebrew)/opt/rustup/bin"
  if [ -x "$rustup_bin/rustup" ]; then
    export PATH="$rustup_bin:$PATH"
    if rustup toolchain list 2>/dev/null | grep -q '^stable'; then
      note "stable toolchain installed"
    else
      run rustup default stable
    fi
    if rustup component list --installed 2>/dev/null | grep -q '^rust-analyzer'; then
      note "rust-analyzer installed"
    else
      run rustup component add rust-analyzer
    fi
  else
    note "rustup isn't installed (common Brewfile); skipping"
  fi

  step "Node (nvm) and pnpm (corepack)"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    # nvm's installer; PROFILE=/dev/null because the tracked zshrc already loads nvm
    run env PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash'
  fi
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    set +u # nvm.sh isn't written for `set -u`
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
    if nvm ls default >/dev/null 2>&1; then
      note "node $(nvm version default) installed"
    else
      run nvm install --lts
    fi
    if command -v pnpm >/dev/null && [[ "$(command -v pnpm)" == "$NVM_DIR"/* ]]; then
      note "pnpm enabled"
    else
      run corepack enable pnpm
    fi
    set -u
  fi
fi

# --- Neovim plugins at the lockfile's revisions -----------------------------------------
if ! skipped nvim; then
  step "Neovim plugins (nvim-pack-lock.json)"
  if command -v nvim >/dev/null && [ -e "$HOME/.config/nvim" ]; then
    # The first start installs missing plugins; update syncs installed ones to the lockfile
    run nvim --headless "+lua vim.pack.update(nil, { target = 'lockfile', force = true })" +qa
  else
    note "nvim or ~/.config/nvim missing; skipping"
  fi
fi

# --- Coding-agent config -------------------------------------------------------------------
if ! skipped agents; then
  step "Coding-agent config (agent-config, context)"
  args=(--profile "$profile")
  $dry_run && args+=(--dry-run)
  if ! "$repo/profiles/common/agents/setup.sh" "${args[@]}"; then
    manual+=("Coding-agent config: sign in with \`gh auth login\`, then rerun with --skip xcode,brew,links,toolchains,nvim")
  fi
fi

# --- Things that need a person -------------------------------------------------------------
manual+=(
  "Open OrbStack once to finish its setup; for Kubernetes: orb start k8s"
  "Sign in to 1Password and turn on its SSH agent (commit signing uses it)"
  "GitHub CLI: gh auth login (once per account)"
  "Git identities: create ~/.config/git/<identity>.gitconfig and allowed_signers (see profiles/common/git/README.md)"
  "Machine-specific settings: ~/.zshrc.local, ~/.config/git/local.gitconfig, Neovim's lua/custom/local.lua"
)
step "Left for you"
for m in "${manual[@]}"; do note "- $m"; done
