#!/bin/bash

# Please backup your mysql data and configure files first!

brew untap josegonzalez/homebrew-php
brew untap homebrew/dupes

brew uninstall pcre

brew uninstall php56-imagick
brew uninstall php56-igbinary
brew uninstall php56-redis
brew uninstall --force php56-mcrypt
brew uninstall php56-memcached
brew uninstall php56-memcache
# brew uninstall php56-xdebug

brew uninstall --force php56
brew uninstall --force mysql
brew uninstall --force nginx

read -p "Remove: /usr/local/var/mysql/ (Mysql data) ? <y/N>" prompt
if [[ $prompt =~ [yY](es)* ]]; then
  rm -rf /usr/local/var/mysql;
fi

read -p "Remove: /usr/local/etc/nginx/ ? <y/N>" prompt
if [[ $prompt =~ [yY](es)* ]]; then
  rm -rf /usr/local/etc/nginx;
fi

read -p "Remove: /usr/local/etc/php/ ? <y/N>" prompt
if [[ $prompt =~ [yY](es)* ]]; then
  rm -rf /usr/local/etc/php;
fi

sed -i '' -e '/^alias mnmp=/d' ~/.bash_profile;
sed -i '' -e '/^alias mnmp=/d' ~/.zshrc;

if [ -n "$ZSH_VERSION" ]; then
   . ~/.zshrc
else # -n "$BASH_VERSION"
   . ~/.bash_profile
fi
