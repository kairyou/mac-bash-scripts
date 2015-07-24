#!/bin/bash

CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# install homebrew's official php tap
brew tap josegonzalez/homebrew-php
# install homebrew-dupes
brew tap homebrew/dupes

# install nginx + mysql + php56 + php-fpm
brew install pcre
brew install nginx

# brew tap raggi/ale && brew install openssl-osx-ca # or: echo insecure >> ~/.curlrc

# fix curl https (nginx 502)
# brew options php56 # see more options
brew install php56 --with-imap --with-mysql --with-fpm --with-postgresql --without-apache --with-homebrew-openssl --with-homebrew-curl #--with-pdo-oci
# brew search php56-
# brew uninstall imagemagick && brew install --fresh imagemagick
brew install php56-imagick --build-from-source
brew install php56-igbinary
brew install php56-redis #--with-igbinary --build-from-source
brew install php56-mcrypt
brew install php56-memcached
brew install php56-memcache
# brew install php56-tidy
# brew install php56-xdebug

# brew reinstall php56-{xx} --build-from-source


brew install mysql
# set up mysql to run as user account
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

# echo 'export PATH="$(brew --prefix php56)/bin:$PATH" # php' >> ~/.zshrc

mkdir -p /usr/local/etc/nginx/vhost/ #vhost
# sudo chown -R $(whoami) /usr/local/var/mysql/

# echo "alias mnmp='$CWD/mnmp.sh'" >> ~/.zshrc
echo "alias mnmp='$CWD/mnmp.sh'" | tee -a ~/.zshrc ~/.bash_profile;
if [ -n "$ZSH_VERSION" ]; then
   . ~/.zshrc
else # -n "$BASH_VERSION"
   . ~/.bash_profile
fi

# TODO:
# 1. vim /usr/local/etc/php/5.6/php.ini; # set a specific date.timezone value, (e.g., change ";date.timezone =" to "date.timezone = America/Chicago" or "date.timezone = Asia/Shanghai")
# run: /usr/local/opt/php56/sbin/php-fpm -i | grep 'Loaded Configuration File' # for test
# 2. vim /usr/local/etc/php/5.6/php-fpm.conf
# change : error_log = /tmp/php-fpm.log, and comment out the following lines:
# ;user = _www;
# ;group = _www

# FAQ:
# Library not loaded: /usr/local/lib/libmcrypt.4.4.8.dylib
	# brew rm mcrypt && brew install mcrypt && brew link --overwrite mcrypt

# for GD build test failed
	# brew rm freetype jpeg libpng gd zlib
	# brew install freetype jpeg libpng gd zlib
	# LDFLAGS="-L/usr/local/opt/zlib/lib"
	# CPPFLAGS="-I/usr/local/opt/zlib/include"
