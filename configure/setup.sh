#!/bin/sh

apt-get install -y --force-yes apache2-utils

htpasswd -b -c ~/.htpasswd milkyway secret
chown vagrant:vagrant ~/.htpasswd