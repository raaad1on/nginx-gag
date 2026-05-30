#!/bin/sh
set -euo pipefail

if [ -f /etc/nginx/nginx.conf.template ]; then
    cat > /opt/nginx/conf/nginx.conf <<'NGINX_CONF'
events {
    worker_connections 1024;
}

http {
NGINX_CONF
    sed "s/{{DOMAIN}}/${DOMAIN}/g" /etc/nginx/nginx.conf.template >> /opt/nginx/conf/nginx.conf
    echo "}" >> /opt/nginx/conf/nginx.conf
fi

exec "$@"