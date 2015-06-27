# How to install software

## iTerm2

iTerm2
http://iterm2.com/

iTerm2 Color Scheme
https://gist.github.com/luan/6362811


## Homebrew

Homebrew
http://brew.sh/

```
$ brew update
```

## zsh

```
brew install zsh
```

## tmux

```
$ brew install tmux

$ brew install reattach-to-user-namespace
```

## Vim

```
$ brew install vim --with-lua
```

## tree 

```
$ brew install tree
```

## wget

```
$ brew install wget
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

## Heroku Toolbelt

```
$ brew install heroku-toolbelt
```

## Node.js

```
$ brew install node
```

packages
```
$ npm install -g less

$ npm install -g grunt-cli

$ npm install -g gulp

$ npm install -g jshint

$ npm install -g coffee-script

$ npm install -g coffeelint

$ npm install -g csslint
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

# How to Install dotfiles

## Run import script

```
$ git submodule init

$ git submodule update

$ sh importconfig.sh
```

