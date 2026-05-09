#!/bin/bash
# macOS の初期セットアップスクリプト

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# oh-my-zsh plug-in / zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# oh-my-zsh plug-in / zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# chezmoi
brew install chezmoi

# 1Password
brew install --cask 1password

echo "Sign in to 1Password desktop and the App Store before proceeding."
read -p "Press Enter to continue."

# Install dotfiles
chezmoi init --apply ohyama

# Claude Code / Add MCP server for Notion API
if command -v claude &> /dev/null; then
  claude mcp add --scope user --transport stdio notionApi -- npx -y @notionhq/notion-mcp-server
fi
