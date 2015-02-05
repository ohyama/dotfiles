#!/bin/bash

cd `dirname $0`

# zsh
cp ./.zshrc ~/.zshrc
cp ./.zprofile ~/.zprofile

# Vim
cp ./.vimrc ~/.vimrc
cp -R ./.vim/ ~/.vim/

# Git
cp ./.gitconfig ~/.gitconfig

