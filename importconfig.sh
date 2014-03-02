#!/bin/bash

cd `dirname $0`

# zsh
cp dot.zshrc ~/.zshrc

# Vim
cp ./dot.vimrc ~/.vimrc
cp -R ./dot.vim/ ~/.vim/

source ~/.zshrc
