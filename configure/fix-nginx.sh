#!/usr/bin/env bash

file='/etc/nginx/nginx.conf'

if [ -e ${file} ]; then
	mv ${file} ${file}.bak
fi

block='user vagrant;

worker_processes auto;
worker_rlimit_nofile 8192;

events {
  # When you need > 8000 * cpu_cores connections, you start optimizing your OS,
  # and this is probably the point at which you hire people who are smarter than
  # you, as this is *a lot* of requests.
  worker_connections 8000;
}

# Default error log file
# (this is only used when you dont override error_log on a server{} level)
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

http {
  server_tokens off;

  # Define the MIME types for files.
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  # Update charset_types due to updated mime.types
  charset_types text/xml text/plain text/vnd.wap.wml application/x-javascript application/rss+xml text/css application/javascript application/json;

  keepalive_timeout 20;
  sendfile        off;
  tcp_nopush      on;
  tcp_nodelay     off;
  types_hash_max_size 2048;

  server_names_hash_bucket_size 64;
  # server_name_in_redirect off;

  gzip on;
  gzip_http_version  1.0;
  gzip_comp_level    5;
  gzip_min_length    256;
  gzip_proxied       any;
  gzip_vary          on;

  gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/rss+xml
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/opentype
    image/svg+xml
    image/x-icon
    text/css
    text/plain
    text/x-component;
  # text/html is always compressed by HttpGzipModule


  # This should be turned on if you are going to have pre-compressed copies (.gz) of
  # static files available. If not it should be left off as it will cause extra I/O
  # for the check. It is best if you enable this in a location{} block for
  # a specific directory, or on an individual server{} level.
  # gzip_static on;

  # Protect against the BEAST attack by preferring RC4-SHA when using SSLv3 and TLS protocols.
  # Note that TLSv1.1 and TLSv1.2 are immune to the beast attack but only work with OpenSSL v1.0.1 and higher and has limited client support.
  # Ciphers set to best allow protection from Beast, while providing forwarding secrecy, as defined by Mozilla - https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx
  ssl_protocols              SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers                ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK;
  ssl_prefer_server_ciphers  on;

  # Optimize SSL by caching session parameters for 10 minutes. This cuts down on the number of expensive SSL handshakes.
  # The handshake is the most CPU-intensive operation, and by default it is re-negotiated on every new/parallel connection.
  # By enabling a cache (of type "shared between all Nginx workers"), we tell the client to re-use the already negotiated state.
  # Further optimization can be achieved by raising keepalive_timeout, but that shouldnt be done unless you serve primarily HTTPS.
  ssl_session_cache    shared:SSL:10m; # a 1mb cache can hold about 4000 sessions, so we can hold 40000 sessions
  ssl_session_timeout  10m;

  # This default SSL certificate will be served whenever the client lacks support for SNI (Server Name Indication).
  # Make it a symlink to the most important certificate you have, so that users of IE 8 and below on WinXP can see your main site without SSL errors.
  #ssl_certificate      /etc/nginx/default_ssl.crt;
  #ssl_certificate_key  /etc/nginx/default_ssl.key;

  fastcgi_temp_file_write_size 10m;
  fastcgi_connect_timeout 300;
  fastcgi_send_timeout 300;
  fastcgi_read_timeout 1200;

  include /etc/nginx/conf.d/*.conf;
  include /etc/nginx/sites-enabled/*;
}
'

echo > "$file"
echo "$block" >> "$file"

service nginx restart && service php5-fpm restart
