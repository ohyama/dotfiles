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

## wget

```
$ brew install wget
```

## tig

Tig is an ncurses-based text-mode interface for git

https://github.com/jonas/tig

```
$ brew install tig
```

## direnv

https://github.com/direnv/direnv

```
$ brew install direnv
```


# Programing Languages

## Node.js

Install Node.js with using anyenv and nodenv.

https://qiita.com/kyosuke5_20/items/eece817eb283fc9d214f

If you run the import script, the following commands will be added to `.zshrc` .

```
eval "$(anyenv init -)"
```

# Cloud Services

## GitHub

### hub (command line tool)

https://hub.github.com/

```
$ brew install hub
```

## AWS

### AWS CLI

https://aws.amazon.com/jp/cli/

```
$ brew install awscli
```

# Editor

## Vim

### Dein.vim (plugin manager)

https://github.com/Shougo/dein.vim
https://github.com/Shougo/dein-installer.vim

```
$ curl https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh > installer.sh
$ sh ./installer.sh ~/.cache/dein
$ rm ./installer.sh
```

# IDE

## Visual Studio Code

https://code.visualstudio.com/


# Font

## HackGen 

https://github.com/yuru7/HackGen

```
$ brew install font-hackgen-nerd
```

# Terminal

## Starship

https://starship.rs/guide/

```
$ brew install starship
```

## iTerm2 Settings

- Font
    - HackGen35 Console NF, Regular, 13px
- Window size
    - Columns: 160
    - Rows: 48 