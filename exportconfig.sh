#!/bin/bash

cd `dirname $0`

# zsh
cp ~/.zshrc ./.zshrc

# Vim
cp ~/.vimrc ./.vimrc
cp -R ~/.vim/ ./.vim/
