#!/bin/bash
# Dev Container 用の dotfiles セットアップスクリプト

set -eu

# 管理対象の Dev Container でない場合はスキップ
if [[ "${DOTFILES_MANAGED:-}" != "true" ]]; then
  echo "Not a managed environment. Skipping dotfiles setup."
  exit 0
fi

# このスクリプトのあるディレクトリ＝既にクローンされた dotfiles を source として apply
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chezmoi init --apply --source="$SCRIPT_DIR"
