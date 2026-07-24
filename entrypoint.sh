#!/bin/sh
set -euo pipefail

DOMAIN="${DOMAIN:-example.com}"
XHTTP_PATH="${XHTTP_PATH:-/api/v1/hs/edge/sigments.ts}"

# Normalize path: leading slash, no trailing slash (except root)
case "$XHTTP_PATH" in
    /*) ;;
    *) XHTTP_PATH="/$XHTTP_PATH" ;;
esac
while [ "$XHTTP_PATH" != "/" ] && [ "${XHTTP_PATH%/}" != "$XHTTP_PATH" ]; do
    XHTTP_PATH="${XHTTP_PATH%/}"
done

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
chmod 644 /var/www/speedtest-10mb.bin

if [ -f /etc/nginx/nginx.conf.template ]; then
    cat > /opt/nginx/conf/nginx.conf <<'NGINX_CONF'
events {
    worker_connections 1024;
}

http {
    limit_req_zone $binary_remote_addr zone=speedtest:1m rate=10r/m;
NGINX_CONF
    sed -e "s|{{DOMAIN}}|${DOMAIN}|g" \
        -e "s|{{XHTTP_PATH}}|${XHTTP_PATH}|g" \
        /etc/nginx/nginx.conf.template >> /opt/nginx/conf/nginx.conf
    echo "}" >> /opt/nginx/conf/nginx.conf
fi

exec "$@"
