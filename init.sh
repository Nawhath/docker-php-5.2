#!/bin/bash

tail -f /var/log/php/xdebug.log /var/log/apache/access_log > /dev/stdout & \
tail -f /var/log/php/error.log /var/log/apache/error_log > /dev/stderr & \
/usr/local/apache2/bin/apachectl -D FOREGROUND