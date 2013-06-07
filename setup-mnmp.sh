#!/bin/bash

# install homebrew's official php tap
brew tap josegonzalez/homebrew-php
# install homebrew-dupes
brew tap homebrew/dupes

# install nginx + mysql + php 5.4 + php-fpm
# # brew install pcre
brew install nginx mysql
# brew options php54 # see more options
brew install php54 --with-imap --with-tidy --with-debug --with-pgsql --with-mysql --with-fpm
brew install php54-mcrypt

# echo '
# export PATH="$(brew --prefix php54)/bin:$PATH" # php
# ' >> ~/.bash_profile

# set up mysql to run as user account
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp


# # launch mysql on startup
# cp `brew --prefix mysql`/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/
# launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

# # launch php-fpm on startup
# cp `brew --prefix php54`/homebrew-php.josegonzalez.php54.plist ~/Library/LaunchAgents/
# launchctl load -w ~/Library/LaunchAgents/homebrew-php.josegonzalez.php54.plist

# # launch nginx at startup as root (in order to listen on privileged port 80):
# sudo cp `brew --prefix nginx`/homebrew.mxcl.nginx.plist /Library/LaunchDaemons/
# sudo sed -i -e 's/`whoami`/root/g' `brew --prefix nginx`/homebrew.mxcl.nginx.plist
# sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

