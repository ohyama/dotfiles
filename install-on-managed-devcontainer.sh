#!/bin/bash
# Dev Container 用の dotfiles セットアップスクリプト

set -eu

# 管理していない Dev Container の場合はスキップ
if [[ "${MANAGED_DEVCONTAINER_BY_OHYAMA:-}" != "true" ]]; then
  echo "MANAGED_DEVCONTAINER_BY_OHYAMA is not set. Skipping dotfiles setup."
  exit 0
fi

# Install dotfiles
# VS Code or @devcontainers/cli の設定で dotfiles は clone 済みの想定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chezmoi init --apply --source="$SCRIPT_DIR"
