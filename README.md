
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

## tmux

```
$ brew install tmux
```

## Vim

```
$ brew install vim --with-lua
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

$ npm install -g coffee-script
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

## Config Import

```
$ git submodule init

$ git submodule update

$ sh importconfig.sh
```

