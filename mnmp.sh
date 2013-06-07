#!/bin/bash

# echo "alias mnmp='/Users/leon/leon/bash/mnmp.sh'" >> ~/.bash_profile
# mnmp start | stop | restart

MYSQL="/usr/local/bin/mysql.server"
NGINX="/usr/local/bin/nginx"
# "/usr/local/opt/php54/sbin/php-fpm" "/usr/sbin/php-fpm"
PHPFPM="/usr/local/opt/php54/sbin/php-fpm"
# PIDPATH="/usr/local/var/run"
param=$1

# sudo chown -R $(whoami) /usr/local/var/mysql/

start()
{
    npids=`ps aux | grep -i nginx | grep -v grep | awk '{print $2}'`
    if [ ! -n "$npids" ]; then
        echo "starting php-fpm ..."
        $PHPFPM
        echo "starting nginx ..."
        sudo $NGINX
        $MYSQL start
    else
        echo "already running"
    fi
}
 
stop()
{
    echo "stopping mnmp ..."
    killall -c php-fpm
    sudo $NGINX -s stop
    $MYSQL stop
    # killall -c mysqld
}

case $param in
    'start')
        start;;
    'stop') 
        stop;;
    'restart')
        stop
        start;;
    *)
    echo "Usage: ./mnmp.sh start | stop | restart";;
esac