# Software development tools and those configuration files.

This repository is a note for my own development. I record development tools and those configuration files on my Mac. 🛠


# How to install

You install below software development tools and run this script for importing dotfiles.

```bash
$ sh importconfig.sh
```

# Commnad Line Tools 

## Homebrew

Homebrew is the missing package manager for macOS.

http://brew.sh/

```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## wget

```bash
$ brew install wget
```

## direnv

https://github.com/direnv/direnv

```bash
$ brew install direnv
```


# Programing Languages

## Node.js

Install Node.js with using anyenv and nodenv.

https://qiita.com/kyosuke5_20/items/eece817eb283fc9d214f

If you run the import script, the following commands will be added to `.zshrc` .

```bash
eval "$(anyenv init -)"
```

# Cloud Services

## GitHub

### gh

https://docs.github.com/ja/github-cli/github-cli/about-github-cli

```bash
$ brew install gh
```

## AWS

### AWS CLI

https://aws.amazon.com/jp/cli/

```bash
$ brew install awscli
```

# Editor

## Vim

### Dein.vim (plugin manager)

https://github.com/Shougo/dein.vim

```bash
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh)"
```

install to `~/.cache/dein/` and use `.vimrc` .

# IDE

## Visual Studio Code

https://code.visualstudio.com/


# Font

## HackGen 

https://github.com/yuru7/HackGen

```bash
$ brew install font-hackgen-nerd
```

# Terminal

## Starship

https://starship.rs/guide/

```bash
$ brew install starship
```

## iTerm2 Settings

- Font
    - HackGen35 Console NF, Regular, 13px
- Window size
    - Columns: 160
    - Rows: 48 