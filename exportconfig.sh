#!/bin/bash

cd `dirname $0`

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

# tmux
cp ~/.tmux.conf ./.tmux.conf
