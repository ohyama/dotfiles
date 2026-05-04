#!/bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# chezmoi
brew install chezmoi

# 1Password
brew install --cask 1password

echo "Sign in to 1Password desktop and the App Store before proceeding."
read -p "Press Enter to continue."

chezmoi init --apply ohyama
