#!/bin/bash

cd `dirname $0`

# zsh
cp ~/.zshrc dot.zshrc

# Vim
cp ~/.vimrc ./dot.vimrc
cp -R ~/.vim/ ./dot.vim/
