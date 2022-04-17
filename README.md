# Software development tools and those configuration files.

This repository is a note for my own development. I record development tools and those configuration files on my Mac. 🛠


# How to install

You install below software development tools and run this script for importing dotfiles.

```
$ sh importconfig.sh
```


# Commnad Line Tools 

## Homebrew

Homebrew is the missing package manager for macOS.

http://brew.sh/

```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## tmux

tmux is a terminal multiplexer.

https://github.com/tmux/tmux

```
$ brew install tmux
```

## wget

```
$ brew install wget
```

## tree 

```
$ brew install tree
```

## tig

Tig is an ncurses-based text-mode interface for git

https://github.com/jonas/tig

```
$ brew install tig
```

## direnv

```
$ brew install direnv
```

# Programing Languages

## Node.js

Install Node.js with using anyenv.

https://qiita.com/kyosuke5_20/items/eece817eb283fc9d214f

### vue-cli

Standard Tooling for Vue.js Development.

https://cli.vuejs.org/

```
$ npm install -g @vue/cli
```

# Cloud Services

## GitHub

GitHub is a development platform inspired by the way you work.

https://github.com/

### hub (command line tool)

hub is a command-line wrapper for git that makes you better at GitHub.

https://hub.github.com/

```
$ brew install hub
```

## Heroku

Heroku is a cloud platform that lets companies build, deliver, monitor and scale apps.

https://www.heroku.com/

### Heroku Toolbelt (command line tool)

The Heroku Command Line Interface (CLI) makes it easy to create and manage your Heroku apps directly from the terminal. It’s an essential part of using Heroku.

https://devcenter.heroku.com/articles/heroku-cli

```
$ brew install heroku/brew/heroku
```


# Editor

## Vim

Vim is a highly configurable text editor for efficiently creating and changing any kind of text.

https://www.vim.org/


### Dein.vim (plugin manager)

Dein.vim is a dark powered Vim/Neovim plugin manager.

https://github.com/Shougo/dein.vim

```
$ curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
$ sh ./installer.sh ~/.vim/dein
$ rm ./installer.sh
```


# IDE

## Visual Studio Code

lightweight but powerful source code editor which runs on your desktop and is available for Windows, macOS and Linux.

Download App on this link.

https://code.visualstudio.com/


# Font

## Ricty for Powerline

```
# install fonts
$ brew tap sanemat/font
$ brew install ricty --with-powerline

# copy
$ cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/

# clear cache
$ fc-cache -vf
```