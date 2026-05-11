# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).
Supports macOS, Dev Containers, and GitHub Codespaces.

## How to install

### macOS (fresh setup)

Run the setup script. It installs Homebrew, Oh My Zsh, chezmoi, and applies the dotfiles.

```sh
curl -fsSL https://raw.githubusercontent.com/ohyama/dotfiles/main/install-on-mac.sh | bash
```

During the setup, you will be asked to sign in to 1Password and the App Store.

### Dev Container (self-managed)

When connecting to a Dev Container using either VS Code or `@devcontainers/cli`, you can automatically apply your dotfiles using their built-in features. This repository provides a setup script (`install-on-managed-devcontainer.sh`) for managed Dev Containers. VS Code and @devcontainers/cli will clone your dotfiles repository into `~/.local/share/chezmoi` by default, so you can simply specify the script as the install command.

- **VS Code**: Use the [dotfiles feature](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories) in Settings Sync. Add the following to your **user** `settings.json` (not workspace settings) to automatically apply your configuration when attaching to a Dev Container:

  Example (user `settings.json`):

  ```json
  {
    "dotfiles.repository": "https://github.com/ohyama/dotfiles.git",
    "dotfiles.targetPath": "~/.local/share/chezmoi",
    "dotfiles.installCommand": "install-on-managed-devcontainer.sh"
  }
  ```

- **@devcontainers/cli**: Pass dotfiles options as command-line arguments to avoid affecting team members via `devcontainer.json`. Example:

  ```sh
  devcontainer up --workspace-folder . \
    --dotfiles-repository "https://github.com/ohyama/dotfiles.git" \
    --dotfiles-target-path "~/.local/share/chezmoi" \
    --dotfiles-install-command "install-on-managed-devcontainer.sh"
  ```

Both methods support initializing and applying dotfiles managed with `chezmoi`.

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
