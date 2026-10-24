# Architecture

How fidgot and its companion repos fit together across personal and work
machines, and the decisions behind it. Most of them are about one question:
which machine can reach which code, secrets and data. Each decision lists the
security benefit and the options turned down, so they don't get reopened by
accident.

Status: **in place** means it's built; **planned** means decided but not built
yet.

## The repos

| Repo                 | Visibility | Cloned on               | Holds                                                    |
| -------------------- | ---------- | ----------------------- | -------------------------------------------------------- |
| `fidgot`             | public     | every machine           | Config and the only installer                            |
| `fidgot-shared`      | private    | every machine           | Coding-agent config and tools allowed on work machines   |
| `fidgot-personal`    | private    | the personal machine    | Tools that are personal only                             |
| `context`            | private    | the personal machine    | Personal session handoffs                                |
| `<employer>-context` | private    | that employer's machine | That machine's handoffs, created from `context-template` |

They're cloned side by side in `~/git/github/rscottlundgren/`, with no
submodules.

## Decisions

### 1. One repo per access boundary

**Status:** in place for `fidgot` and `fidgot-personal`; `fidgot-shared`
planned.

Code is split into repos by who may read it, not by what it does. GitHub can
only grant or deny access to a whole repo, so the repo is the smallest unit a
machine can be kept out of.

**Security benefit:** a work machine that has no credentials for
`fidgot-personal` can't fetch it, by mistake or on purpose. Running
`install.sh --profile personal` on a work machine fails at the clone instead of
installing personal tools. Profiles still decide what gets linked, but the
credentials are the lock.

**Turned down:**

- One private repo with `profiles/personal/`: any machine that can clone it has
  every profile on disk, linked or not.
- One repo plus sparse checkout and partial clone: keeps file contents off disk,
  but file names, folder names and commit messages still reach every machine,
  and some git commands fetch contents on demand.
- Submodules: more moving parts than sibling repos plus an installer that knows
  the list.

### 2. The public repo never names personal tools

**Status:** in place.

`fidgot` knows that `fidgot-personal` exists, and nothing more. The `tools` step
clones it, runs `go install ./...` and then runs that repo's own `check.sh`,
which lists the personal data its tools need. Which tools exist, and what data
they keep, is written only in the private repo.

**Security benefit:** reading this public repo tells you nothing about the
personal tools or the kind of data they handle.

**Turned down:** checking for each tool's files from `fidgot` itself, which
would publish their names and data locations.

### 3. No personal data in any repo

**Status:** in place.

Documents, account tables and logs live only on the machine that uses them, in
`~/.config/<tool>/` and `~/.local/state/<tool>/`. Repos commit an `*.example.*`
file to document a format, `.gitignore` blocks data files and documents as a
backstop, and tests use made-up data only.

**Security benefit:** no repo, public or private, can leak personal data,
whether through a visibility change, a fork, a compromised account or a laptop
that's lost. It's also what makes decision 1 safe enough: the private repos hold
code, not data.

### 4. Work machines get deploy keys, registered through a GitHub App

**Status:** planned. The GitHub App (`fidgot-provisioner`) is registered.

A work machine's only GitHub access is one SSH deploy key per repo it may clone:
`fidgot-shared` read-only and its `<employer>-context` read/write. The installer
creates the keys on the machine itself, then registers them through a private
GitHub App using the device flow: it shows a one-time code, which is approved at
`github.com/login/device` on a phone. The resulting token expires within hours,
can only reach repos the app is installed on, and is thrown away (along with its
refresh token) once the keys are added. Keys are named
`<employer>-<hostname>-<repo>-<YYYYMMDD>`.

The app has one permission (repository Administration: read & write, which
covers deploy keys), is installed only on `fidgot-shared` and the
`<employer>-context` repos, and has no client secret, no private key and no
webhook.

**Security benefit:**

- No secret ever travels between machines. Private keys stay on the work
  machine, and the app's client ID is public by design.
- Even the setup token is limited to the app's repos, so it can't see
  `fidgot-personal` or `context`.
- Each approval is a person on a phone, behind the GitHub account's passkey.
- Revoking a machine means deleting the deploy keys with its name. Deploy keys
  don't depend on the app, so removing the app never locks a machine out.
- Without a private key, nothing can use the app on its own.

**Turned down:**

- `gh auth login`: its token reaches every repo on the account.
- Signing into the personal GitHub account in a work machine's browser: leaves a
  full-account session on an employer device.
- A fine-grained personal access token sent to the machine: a real secret has to
  travel, and it expires and needs renewing.
- Deploy keys pasted into GitHub by hand: works, and stays as the fallback, but
  is manual and has no naming convention.
- A hardware key plugged into the work machine: employer USB policies, a tap on
  every push, and GitHub's support for security-key deploy keys is unconfirmed.

### 5. 1Password stays off work machines by default

**Status:** planned.

Tools and config hold only `op://` references, never secret values. The personal
machine resolves them through the 1Password app and Touch ID. A work machine has
no 1Password access at all, and work secrets come from the employer's own tools.
If a shared tool ever needs a secret there, it gets a 1Password service account
with read-only access to one small shared vault, whose token is kept in the
macOS Keychain.

**Security benefit:** a work machine can't read the personal vaults, and a
service account, if one is ever added, can't sign into the app, can't see the
private vault, is logged and can be revoked in one step.

### 6. Work data stays on work machines

**Status:** planned.

Each work machine gets its own `<employer>-context` repo for handoffs, and the
personal machine never clones it. Where that repo lives (this account or the
employer's GitHub organization) follows the employer's policy on storing their
information.

**Security benefit:** employer information doesn't end up on the personal
machine, and personal handoffs don't end up on a work machine.

### 7. One installer, data-only companion repos

**Status:** in place for `fidgot-personal`.

All install logic lives in `fidgot`. Companion repos carry only what's theirs:
their code, plus small files the installer reads, such as `check.sh`. A
`fidgot-template` repo is planned as the skeleton for new companion repos.

**Security benefit:** there's one place to review what runs on a machine during
setup, and a fix reaches every repo at once instead of drifting across copies.

### 8. The account behind everything is protected with a passkey

**Status:** in place on the account owner's side.

Every grant and revocation above happens through the GitHub account, so its
sign-in uses a passkey stored in 1Password (with GitHub Mobile as a second
option), and its recovery codes are kept separately.

**Security benefit:** a stolen password or a phishing page isn't enough to add a
deploy key or authorize the app.
