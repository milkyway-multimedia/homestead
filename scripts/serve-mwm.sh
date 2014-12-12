#!/usr/bin/env bash

site=${1}
dir=${2}
framework='framework'

if [ -e ${2}'/sapphire/main.php' ]; then
    framework='sapphire'
fi

sake=${dir}'/'${framework}'/sake'

block='server {
    listen 80;
    server_name '${site}';
    root '${dir}';

    # FORGE SSL (DO NOT REMOVE!)
    # ssl on;
    # ssl_certificate;
    # ssl_certificate_key;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /'${framework}'/main.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/'${site}'-error.log error;

    error_page 404 /'${framework}'/main.php;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
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

if [ -e ${sake} ]; then
    chmod +x ${sake}
    ${sake} 'dev/build' "flush=1"
fi