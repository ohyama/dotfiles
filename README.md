# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Supports macOS, Dev Containers, and GitHub Codespaces.

## How to install

### macOS (fresh setup)

Run the setup script. It installs Homebrew, Oh My Zsh, chezmoi, and applies the dotfiles.

```sh
curl -fsSL https://raw.githubusercontent.com/ohyama/dotfiles/main/setup.sh | bash
```

During the setup, you will be asked to sign in to 1Password and the App Store.

### Other environments

```sh
chezmoi init --apply ohyama
```

Packages for each OS are defined in [`home/.chezmoidata/packages.yaml`](home/.chezmoidata/packages.yaml).

## Development

This repository uses the following tools:

- [Prettier](https://prettier.io/) — Code formatting
- [commitlint](https://commitlint.js.org/) — Commit message linting
- [husky](https://typicode.github.io/husky/) + [lint-staged](https://github.com/lint-staged/lint-staged) — Pre-commit hooks

```sh
npm ci
```
