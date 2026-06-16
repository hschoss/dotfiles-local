# Security Notes

This repository is intended to contain public dotfiles only.

Secrets, tokens, OAuth credentials, private keys, local app state, generated
logs, shell histories, and machine-private files must not be committed.

Private values should live in ignored local files such as:

- `~/.bashrc.private`
- `~/.gitconfig.private`
- `~/.dotfiles-private/`
- password manager entries

Before publishing or pushing, run:

```sh
gitleaks detect --source . --verbose --no-banner
gitleaks git --verbose
git status --ignored --short
```

If a real secret is ever committed, rotate it immediately and remove it from
Git history.
