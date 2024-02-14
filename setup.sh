#Bash shell script สำหรับติดตั้ง Apache 2.2.17 บน Ubuntu
#

#!/bin/bash

apt update \
&& apt install build-essential -y \
&& apt install vim wget locales -y

# httpd
wget https://archive.apache.org/dist/httpd/httpd-2.2.17.tar.gz
tar -xvzf httpd-2.2.17.tar.gz
cd ./httpd-2.2.7 \
&& ./configure --enable-so --enable-rewrite \
&& make -j4 \
&& make install 

# libxml
tar -xvzf libxml2-2.8.0.tar.xz 
cd ./libxml2-2.8.0 \
&& ./configure \
&& make -j4 \
&& make install \
&& ldconfig \

# oracle
apt install unzip libaio-dev -y && mkdir /opt/oracle
tar -xvzf ./instantclient-basic-linux.x64-11.2.0.4.0.tar.gz /opt/oracle
tar -xvzf ./instantclient-sdk-linux.x64-11.2.0.4.0.tar.gz /opt/oracle
echo "/opt/oracle/instantclient_11_2" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# php
# ./configure --help
apt install flex libtool libpq-dev libgd-dev libcurl4-openssl-dev libmcrypt-dev -y

ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/ \
&& ln -s /usr/lib/x86_64-linux-gnu/libpng.so /usr/lib/ \
&& ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl \
&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ \
&& ln -s /opt/oracle/instantclient_11_2/libclntsh.so.11.1 /opt/oracle/instantclient_11_2/libclntsh.so \
&& mkdir /opt/oracle/client \
&& ln -s /opt/oracle/instantclient_11_2/sdk/include /opt/oracle/client/include \
&& ln -s /opt/oracle/instantclient_11_2 /opt/oracle/client/lib

tar -xvzf ./php-5.2.17.tar.gz 
cd ./php-5.2.17 \
&& ./configure --with-apxs2=/usr/local/apache2/bin/apxs \
--enable-bcmath \
--enable-calendar \
--enable-ctype \
--enable-date \
--enable-dba \
--enable-dom \
--enable-exif \
--enable-filter \
--enable-ftp \
--enable-gettext \
--enable-hash \
--enable-iconv \
--enable-json \
--enable-libxml \
--enable-mbstring \
--enable-mcrypt \
--enable-mhash \
--enable-mime-magic \
--enable-openssl \
--enable-pcre \
--enable-pdo \
--enable-pspell \
--enable-reflection \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-soap \
--enable-sockets \
--enable-spl \
--enable-sqlite \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-tokenizer \
--enable-wddx \
--enable-xml \
--enable-xmlreader \
--enable-xmlrpc \
--enable-xmlwriter \
--enable-xsl \
--enable-zip \
--enable-zlib \
--with-apxs2=/usr/local/apache2/bin/apxs2 \
--with-bz2 \
--with-curl \
--with-freetype-dir=/usr \
--with-gd \
--with-gettext \
--with-jpeg-dir=/usr \
#--with-ldap \ @TODO: deprec error libldap2-dev; compile source
--with-mcrypt \
--with-mime-magic=/usr/local/apache2/conf/magic \
--with-mysqli=mysqlnd  \
--with-oci8=instantclient,/opt/oracle/instantclient_11_2 \
#--with-openssl \ @TODO: deprec error libssl-dev; compile source
--with-pdo-mysql=mysqlnd \
--with-pdo-oci=instantclient,/opt/oracle,11.2 \
--with-pdo-pgsql \
--with-pdo-sqlite=/usr/bin/sqlite3-config \
--with-pgsql \
--with-png-dir=/usr \
--with-sqlite3=/usr/bin/sqlite3-config \
--with-ttf \
--with-xmlrpc  \
--with-zlib 

 

make -j4 \
&& make install \
&& cp ./php.ini-dist /usr/local/lib/php.ini 

# php config
echo '\n\
date.timezone = Asia/Bangkok\n\
short_open_tag=On\n\
display_errors = On\n\
error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE\n\
log_errors = On\n\
error_log = /var/log/php/error.log\n\
' >> /usr/local/lib/php.ini \
&& sed -i -- "s/magic_quotes_gpc = On/magic_quotes_gpc = Off/g" /usr/local/lib/php.ini

# php xdebug
tar -xvzf ./xdebug-2.2.7.tar.gz 
cd ./xdebug-2.2.7 \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j4 \
    && make install 

echo '\n\
zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20060613/xdebug.so\n\
xdebug.remote_enable=1\n\
xdebug.remote_handler=dbgp\n\
xdebug.remote_mode=req\n\
xdebug.remote_host=${XDEBUG_REMOTE_HOST}\n\
xdebug.remote_port=${XDEBUG_REMOTE_PORT}\n\
xdebug.remote_autostart=1\n\
xdebug.extended_info=1\n\
xdebug.remote_connect_back = 0\n\
xdebug.remote_log = /var/log/php/xdebug.log\n\
\n\' >> /usr/local/lib/php.ini

# php opcache
#COPY ./opcache.php /srv/opcache/index.php
tar -xvzf ./zendopcache-7.0.5.tgz 
cd ./zendopcache-7.0.5 \
    && phpize \
    && ./configure --with-php-config=php-config \
    && make \
    && make install

echo '\n\
zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20060613/opcache.so\n\
opcache.memory_consumption=128\n\
opcache.interned_strings_buffer=8\n\
opcache.max_accelerated_files=4000\n\
opcache.revalidate_freq=2\n\
opcache.fast_shutdown=1\n\
opcache.enable_cli=1\n\
\n\' >> /usr/local/lib/php.ini

# php SOAP includes
tar -xvzf ./soap-includes.tar.gz /usr/local/lib/php

# config httpd
echo '\n\
AddType application/x-httpd-php .php .phtml\n\
User www-data\n\
Group www-data\n\
Alias "/opcache" "/srv/opcache"\n\
<Directory "/srv/opcache">\n\
    Allow from all\n\
</Directory>\n\
' >> /usr/local/apache2/conf/httpd.conf \
&& sed -i -- "s/ErrorLog logs\/error_log/ErrorLog \/var\/log\/apache\/error_log/g" /usr/local/apache2/conf/httpd.conf \
&& sed -i -- "s/CustomLog logs\/access_log/CustomLog \/var\/log\/apache\/access_log/g" /usr/local/apache2/conf/httpd.conf \
&& sed -i -- "s/AllowOverride None/AllowOverride All/g" /usr/local/apache2/conf/httpd.conf \
&& sed -i -- "s/AllowOverride none/AllowOverride All/g" /usr/local/apache2/conf/httpd.conf \
&& sed -i -- "s/DirectoryIndex index.html/DirectoryIndex index.html index.php/g" /usr/local/apache2/conf/httpd.conf

# config OpenSSL
sed -i -- "s/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/g" /usr/lib/ssl/openssl.cnf \
&& sed -i -- "s/MinProtocol = TLSv1.2/MinProtocol = TLSv1.0/g" /usr/lib/ssl/openssl.cnf

# add locale
#locale-gen pt_BR.UTF-8 \
#&& echo "locales locales/locales_to_be_generated multiselect pt_BR.UTF-8 UTF-8" | debconf-set-selections \
#&& rm /etc/locale.gen \
#&& dpkg-reconfigure --frontend noninteractive locales

# create log files
mkdir /var/log/php \
    && mkdir /var/log/apache \
    && touch /var/log/php/error.log \
    && touch /var/log/php/xdebug.log \
    && touch /var/log/apache/access_log \
    && touch /var/log/apache/error_log \
    && chown www-data:www-data /var/log/php/error.log \
    && chown www-data:www-data /var/log/php/xdebug.log \
    && chown www-data:www-data /var/log/apache/access_log \
    && chown www-data:www-data /var/log/apache/error_log
