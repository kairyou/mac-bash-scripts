#!/bin/bash

# echo "alias mnmp='/Users/leon/leon/bash/mnmp.sh'" >> ~/.bash_profile
# mnmp start | stop | restart

MYSQL="/usr/local/bin/mysql.server"
NGINX="/usr/local/bin/nginx"
PHPFPM="/usr/local/opt/php56/sbin/php56-fpm" # sys default: "/usr/sbin/php-fpm"
# PIDPATH="/usr/local/var/run"
param=$1
type=$2

start()
{
    npids=`ps aux | grep -i nginx | grep -v grep | awk '{print $2}'`
    if [ ! -n "$npids" ]; then
        tmp='/usr/local/var/run/nginx/fastcgi_temp'
        [ -d "$tmp" ] && sudo chmod -R 755 $tmp
        echo "starting php-fpm ..." && $PHPFPM start
        # unable to bind listening socket for address '127.0.0.1:xx': Address already in use # killall -c php-fpm

        echo "starting nginx ..." && sudo $NGINX # sudo for bind to 0.0.0.0:80
        $MYSQL start
    else
        echo "already running"
    fi
}
 
stop()
{
    # npids=`ps aux | grep -i nginx | grep -v grep | awk '{print $2}'`
    # if [ ! -n "$npids" ]; then
    #     echo "already stopped";exit;
    # fi

    echo "stopping mnmp ..."
    # $PHPFPM stop
    killall -c php-fpm
    # sudo $NGINX -s stop
    sudo killall -c nginx
    # $MYSQL stop
    killall -c mysqld
}
# config()
    # nginx -V # /usr/local/etc/nginx/nginx.conf
    # mysql –verbose –help | grep -A 1 'Default options' # /usr/local/opt/mysql/my.cnf
    # /usr/local/opt/php56/sbin/php-fpm -i | grep 'Loaded Configuration File'
    # /usr/local/etc/php/5.6/php.ini, /usr/local/etc/php/5.6/php-fpm.conf, /tmp/php-fpm.log
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
