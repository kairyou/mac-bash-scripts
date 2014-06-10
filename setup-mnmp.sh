#!/bin/bash

# install homebrew's official php tap
brew tap josegonzalez/homebrew-php
# install homebrew-dupes
brew tap homebrew/dupes

# install nginx + mysql + php 5.4 + php-fpm
brew install pcre
brew install nginx

# for GD build test failed
# brew rm freetype jpeg libpng gd zlib
# brew install freetype jpeg libpng gd zlib
# LDFLAGS="-L/usr/local/opt/zlib/lib"
# CPPFLAGS="-I/usr/local/opt/zlib/include"

brew install php54 --without-apache --with-imap --with-debug --with-pgsql --with-mysql --with-fpm
# brew options php54 # see more options
brew install php54-mcrypt

# Library not loaded: /usr/local/lib/libmcrypt.4.4.8.dylib
# brew rm mcrypt
# brew install mcrypt
# brew link --overwrite mcrypt


# brew uninstall imagemagick
# brew install --fresh imagemagick
# ln -s /usr/local/Cellar/libtool/2.4.2/lib/libltdl.7.dylib /usr/local/lib/libltdl.7.dylib
brew install php54-imagick

# echo 'export PATH="$(brew --prefix php54)/bin:$PATH" # php' >> ~/.bash_profile

brew install mysql
# set up mysql to run as user account
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

mkdir /usr/local/etc/nginx/vhost/
sudo chown -R $(whoami) /usr/local/var/mysql/
