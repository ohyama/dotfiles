#!/bin/bash
# Dev Container 用の dotfiles セットアップスクリプト

set -eu

# 管理していない Dev Container の場合はスキップ
if [[ "${DEVCONTAINER_MANAGED_BY_OHYAMA:-}" != "true" ]]; then
  echo "DEVCONTAINER_MANAGED_BY_OHYAMA is not set. Skipping dotfiles setup."
  exit 0
fi

# Install dotfiles
# VS Code or @devcontainers/cli の設定で dotfiles は clone 済みの想定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chezmoi init --apply --source="$SCRIPT_DIR"

# Claude Code / Add MCP server for Notion API
if command -v claude &> /dev/null; then
  claude mcp add --scope user --transport stdio notionApi -- npx -y @notionhq/notion-mcp-server
fi
