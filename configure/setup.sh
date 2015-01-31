#!/bin/sh

apt-get install apache2-utils

htpasswd -b -c ~/.htpasswd milkyway secret