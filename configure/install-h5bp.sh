#!/usr/bin/env bash

url='https://raw.githubusercontent.com/h5bp/server-configs-nginx/master/h5bp/'
dir='/etc/nginx/h5bp'
mime='/etc/nginx/mime.types'

mkdir -p ${dir}/directive-only
mkdir -p ${dir}/location

curl -L -o ${dir}'/directive-only/cache-file-descriptors.conf' ${url}'directive-only/cache-file-descriptors.conf'
curl -L -o ${dir}'/directive-only/cross-domain-insecure.conf' ${url}'directive-only/cross-domain-insecure.conf'
curl -L -o ${dir}'/directive-only/no-transform.conf' ${url}'directive-only/no-transform.conf'
curl -L -o ${dir}'/directive-only/x-ua-compatible.conf' ${url}'directive-only/x-ua-compatible.conf'

curl -L -o ${dir}'/location/cache-busting.conf' ${url}'location/cache-busting.conf'
curl -L -o ${dir}'/location/cross-domain-fonts.conf' ${url}'location/cross-domain-fonts.conf'
curl -L -o ${dir}'/location/expires.conf' ${url}'location/expires.conf'
curl -L -o ${dir}'/location/protect-system-files.conf' ${url}'location/protect-system-files.conf'

if [-e ${mime} ]; then
	mv ${mime} ${mime}.bak
fi

curl -L -o ${mime} 'https://raw.githubusercontent.com/h5bp/server-configs-nginx/master/mime.types'

block='# Basic h5bp rules

include '${dir}'/location/cache-busting.conf;
include '${dir}'/directive-only/x-ua-compatible.conf;
include '${dir}'/location/expires.conf;
include '${dir}'/location/cross-domain-fonts.conf;
include '${dir}'/location/protect-system-files.conf;
'

touch ${dir}'/basic.conf'
echo "$block" > ${dir}'/basic.conf'

nginx -t && service nginx reload