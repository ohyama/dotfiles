#!/bin/bash
# Dev Container 用の dotfiles セットアップスクリプト

set -eu

# dotfiles を適用しない環境ではスキップ
if [[ "${DOTFILES_APPLY_OHYAMA:-}" != "true" ]]; then
  echo "DOTFILES_APPLY_OHYAMA is not set. Skipping dotfiles setup."
  exit 0
fi

# このスクリプトのあるディレクトリ＝既にクローンされた dotfiles を source として apply
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chezmoi init --apply --source="$SCRIPT_DIR"
