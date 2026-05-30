#!/bin/sh
set -euo pipefail

if [ -f /etc/nginx/nginx.conf.template ]; then
    sed "s/{{DOMAIN}}/${DOMAIN}/g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
fi

exec "$@"