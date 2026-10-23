# ssh

The SSH client config, linked to `~/.ssh/config`, and the public keys it names,
linked into `~/.ssh/`. These are file links: `~/.ssh` also holds private keys
and `known_hosts`, which stay out of the repo. `install.sh` also makes `~/.ssh`
private (`chmod 700`).

- Each GitHub account has a host alias, so a clone's remote picks the account:
  `git@github.com-rscottlundgren:rscottlundgren/fidgot.git`,
  `git@github.com-studioelif:studio-elif/<repo>.git`. With `IdentitiesOnly`,
  each alias offers only that account's key.
- The private keys live in 1Password, whose SSH agent serves them
  (`IdentityAgent`); turn the agent on in 1Password's settings. The `.pub` files
  tell SSH which of the agent's keys to offer for each alias. They're the same
  keys GitHub publishes at `github.com/<account>.keys`, so tracking them reveals
  nothing.
- OrbStack's include (its `orb` host for Linux machines) is kept; SSH ignores it
  where OrbStack isn't installed.

## Not in this repo

Anything for one machine, or not for a public repo (work servers, internal
hostnames, cloud instances), goes in `~/.ssh/config.local`. It's included first,
so its settings win:

```ssh-config
Host build-box
  HostName 10.0.0.12
  User me
```

Keys for one-off hosts (e.g. an AWS key pair's `.pem`) stay in `~/.ssh`
untracked, used with `ssh -i` or an `IdentityFile` in `config.local`.

Check a host's settings without connecting:
`ssh -G github.com-rscottlundgren | grep -E '^(hostname|user|identityfile) '`.

## If SSH stops working

`~/.ssh/config` and the keys link into this checkout, so checking out a commit
or branch from before they were added removes them. Every GitHub alias then
fails, this repo's own remote included:

```text
ssh: Could not resolve hostname github.com-rscottlundgren: nodename nor servname provided, or not known
```

Switch back to `main`, which needs no network: `git switch main`. If your local
`main` doesn't have the files yet (e.g. right after merging the change that
added them), pull it over HTTPS instead, which works without signing in because
the repo is public:

```sh
git pull --ff-only https://github.com/rscottlundgren/fidgot.git main
```
