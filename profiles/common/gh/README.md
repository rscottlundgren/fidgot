# gh

`config.yml`, the GitHub CLI's settings (git protocol, editor, prompts, pager,
aliases, …), linked to `~/.config/gh/config.yml`. `gh config set` and
`gh alias set` write through the link, so changes made with them show up here to
commit.

`~/.config/gh/hosts.yml` is **not** tracked: it records the signed-in accounts
(and a token, when the system keychain isn't used). On a new machine, sign in
with `gh auth login` for each account.
