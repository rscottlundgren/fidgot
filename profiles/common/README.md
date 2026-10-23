# Common profile

Config for every machine. Each tool's folder has its own README; this one covers
the [`Brewfile`](Brewfile), which `install.sh` installs on every machine (the
personal machine adds `../personal/Brewfile`).

## Brewfile

By hand, from the repo root:

```sh
brew bundle install --file profiles/common/Brewfile
brew bundle check --file profiles/common/Brewfile   # what's missing
```

`brew bundle cleanup` compares against one Brewfile, so combine them to see
what's installed but listed in neither:

```sh
cat profiles/*/Brewfile | brew bundle cleanup --file=-
```

Notes:

- App Store apps (the `mas` lines) install with
  [`mas`](https://github.com/mas-cli/mas), which needs the App Store app signed
  in to an Apple Account. If it isn't, `install.sh` finishes anyway and lists
  the Brewfile under "Left for you". Find an app's id with `mas search <name>`
  or `mas list`.
- Docker comes from OrbStack, which includes the Docker CLI, `docker compose`
  and `docker buildx`. Homebrew's `docker` formula is left out on purpose:
  OrbStack would defer to it, and it needs separate Compose and buildx formulas.
- Kubernetes is OrbStack's local single-node cluster: turn it on with
  `orb start k8s` (context `orbstack`). OrbStack's bundled `kubectl` is too far
  behind the cluster's version, so `kubectl` comes from Homebrew's
  `kubernetes-cli`, which is earlier on `PATH`.
- Terraform isn't in Homebrew's core repository any more; it comes from
  HashiCorp's tap (`hashicorp/tap`).
- Rust comes from Homebrew's `rustup`, which manages the toolchains:
  `rustup default stable` and `rustup component add rust-analyzer` (done by
  `install.sh`), `rustup update` to update. Don't also install Homebrew's `rust`
  formula; it's a separate toolchain that conflicts.
- Zig and its language server, ZLS, both come from Homebrew. ZLS has to be the
  same release as Zig, so upgrade them together: `brew upgrade zig zls`.
- Java's JDK is Homebrew's `openjdk`, which Homebrew doesn't link; the zsh
  config puts it on `PATH` (see [zsh](zsh/README.md)).

## Installed outside Homebrew

`install.sh` sets these up too:

- Node, through [nvm](https://github.com/nvm-sh/nvm) (its maintainers ask not to
  install it with Homebrew):

  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
  nvm install --lts
  ```

- pnpm and yarn, through Node's corepack: `corepack enable pnpm`. Each project
  pins its version with `packageManager` in `package.json`.
