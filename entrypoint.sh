#!/bin/sh
set -euo pipefail

DOMAIN="${DOMAIN:-example.com}"

mkdir -p /dev/shm/nginx
chmod 755 /dev/shm/nginx

LABEL="${DOMAIN%%.*}"
LABEL_UPPER="$(echo "$LABEL" | tr '[:lower:]' '[:upper:]')"
NODE_RAND="$(awk 'BEGIN{srand(); print int(100+rand()*900)}')"
NODE_ID="${LABEL_UPPER}-NODE-${NODE_RAND}"
NODE_GBPS="$(awk 'BEGIN{srand(); printf "%.1f", 1.5+rand()*3.5}')"

if [ -f /var/www/index.html.template ]; then
    sed -e "s/{{NODE_ID}}/${NODE_ID}/g" -e "s/{{NODE_GBPS}}/${NODE_GBPS}/g" \
        /var/www/index.html.template > /var/www/index.html
elif [ -f /var/www/index.html ]; then
    sed -i -e "s/{{NODE_ID}}/${NODE_ID}/g" -e "s/{{NODE_GBPS}}/${NODE_GBPS}/g" \
        /var/www/index.html
fi

dd if=/dev/urandom of=/var/www/speedtest-10mb.bin bs=1M count=10 status=none

if [ -f /etc/nginx/nginx.conf.template ]; then
    cat > /opt/nginx/conf/nginx.conf <<'NGINX_CONF'
events {
    worker_connections 1024;
}

http {
    limit_req_zone $binary_remote_addr zone=speedtest:1m rate=10r/m;
NGINX_CONF
    sed "s/{{DOMAIN}}/${DOMAIN}/g" /etc/nginx/nginx.conf.template >> /opt/nginx/conf/nginx.conf
    echo "}" >> /opt/nginx/conf/nginx.conf
fi

exec "$@"
