# How to install Software for Development

## Homebrew

Homebrew
http://brew.sh/

```
$ brew update
```

## tmux

```
$ brew install tmux
```

## Vim

```
$ brew install vim --with-lua

$ curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
$ sh ./installer.sh ~/.vim/dein
$ rm ./installer.sh
```

## tree 

```
$ brew install tree
```

## wget

```
$ brew install wget
```

## Heroku Toolbelt

```
$ brew install heroku-toolbelt
```

## Go

```
$ zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

$ gvm install go1.7.3 -B
$ gvm use go1.7.3 --default

$ go get golang.org/x/tools/cmd/goimports
$ go get -u github.com/golang/lint/golint
$ go get github.com/tools/godep

$ git config --global url."git@github.com:".insteadOf "https://github.com/"
```

## ruby
```
$ brew install autoconf

$ brew install rbenv ruby-build

$ cat >>~/.zprofile <<'EOS'
$ export PATH="$PATH:$HOME/.rbenv/bin"
$ eval "$(rbenv init -)"
$ EOS

$ RUBY_CONFIGURE_OPTS="--enable-shared --with-readline-dir=$(brew --prefix readline) --with-openssl-dir=$(brew --prefix openssl)" rbenv install 2.2.2

$ rbenv global 2.2.2
$ rbenv rehash

$ gem install bundler
$ rbenv rehash
$ gem list | grep bundler
```
packages
```
$ sudo gem update --system

$ sudo gem install activerecoard

$ sudo gem install sqlite3

$ sudo gem install rails

$ sudo gem install sinatra

$ sudo gem install sinatra-contrib
```

## node.js

```
$ brew install nodebrew
$ mkdir -p ~/.nodebrew/src

$ nodebrew install-binary latest
$ nodebrew use v10.0.5
```

packages
```
$ npm install -g webpack

$ npm install gulp-cli -g
```


## Yeoman

```
$ npm install -g yo

$ npm install -g bower
```

generator
```
$ npm install -g generator-hubot

$ npm install -g generator-gulp-webapp
```


## Hexo (Optional)

```
$ npm install -g hexo-cli
```

## OpenCV (Optional)

```
$ brew tap homebrew/science

$ brew install opencv
```

use node-opencv
```
$ brew install pkg-config

$ npm install opencv
```

## MongoDB (Optional)

```
$ brew install mongodb
```

To have launchd start mongodb at login:
```
$ ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents
```

Then to load mongodb now:
```
$ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
```

Or, if you don't want/need launchctl, you can just run:
```
$ mongod --config /usr/local/etc/mongod.conf
```

# How to install dotfiles

## Run import script

```
$ sh importconfig.sh
```

