#!/bin/bash

cd `dirname $0`

echo "This will export dotfiles from your home directory to this repository."
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Canceled."
    exit 1
fi

# zsh
cp ~/.zshrc ./.zshrc
cp ~/.zprofile ./.zprofile

# ssh
cp ~/.ssh/config ./.ssh/config

# vim
cp ~/.vimrc ./.vimrc
cp -R ~/.vim/colors ./.vim/

# git
cp ~/.gitconfig ./.gitconfig
cp ~/.gitconfig_commit_template ./.gitconfig_commit_template

# claude code
cp ~/.claude/settings.json ./.claude/settings.json
cp ~/.claude/mcp.json ./.claude/mcp.json

# starship
cp ~/.config/starship.toml ./.config/starship.toml

echo "Done."