#!/usr/bin/env bash

site=${1}
dir=${2}
php=$(which php)
passwd=

if [ -e '/home/vagrant/.htpasswd' ]; then
    passwd='
    auth_basic "Restricted";
    auth_basic_user_file /home/vagrant/.htpasswd;
    '
fi

block='server {
    listen 80;
    server_name '${site}';
    root '${dir}';

    index index.html index.htm index.php;
    '${passwd}'
    charset utf-8;

    location / {
        try_files $uri /app.php$is_args$args;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/'${site}'-error.log error;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    client_max_body_size 10M;

    location ~* (.+)\.(?:\d+)\.(js|css|png|jpg|jpeg|gif)$ {
       try_files $uri $1.$2;
    }

    include /etc/nginx/h5bp/basic.conf;
}

'

echo > '/etc/nginx/sites-available/'${site}
echo "$block" >> '/etc/nginx/sites-available/'${site}
ln -s '/etc/nginx/sites-available/'${site} '/etc/nginx/sites-enabled/'${site}

service nginx restart && service php5-fpm restart

dir=$(dirname ${dir})

mkdir -p ${dir}/app/{toran,logs}
mkdir -p ${dir}'/web/repo'
touch ${dir}'/app/bootstrap.php.cache'

rm -R ${dir}/app/cache
mkdir ${dir}/app/cache

chmod -R 777 ${dir}'/app/toran'
chmod -R 777 ${dir}'/app/cache'
chmod -R 777 ${dir}'/app/logs'
chmod -R 777 ${dir}'/web/repo'
chmod -R 777 ${dir}'/app/bootstrap.php.cache'

if [ -n ${php} -a -e ${dir}'/app/console' ]; then
    ${php} ${dir}'/app/console' toran:update &
fi

if [ -n ${php} -a -e ${dir}'/bin/cron' ]; then
    ${php} ${dir}'/bin/cron' -v &
fi