#!/bin/bash

# install homebrew's official php tap
brew tap josegonzalez/homebrew-php
# install homebrew-dupes
brew tap homebrew/dupes

# install nginx + mysql + php 5.4 + php-fpm
brew install pcre
brew install nginx

# brew options php54 # see more options
brew install php54 --with-imap --with-tidy --with-debug --with-pgsql --with-mysql --with-fpm
brew install php54-mcrypt

# echo 'export PATH="$(brew --prefix php54)/bin:$PATH" # php' >> ~/.bash_profile

brew install mysql
# set up mysql to run as user account
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

mkdir /usr/local/etc/nginx/vhost/
sudo chown -R $(whoami) /usr/local/var/mysql/
