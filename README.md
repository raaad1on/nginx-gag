# nginx-gag (CDN / NGENIX origin)

Nginx origin for CDN (NGENIX) with post-quantum TLS, fake auth landing page, and streaming xHTTP reverse-proxy to Xray over a **unix socket**.

Branch: `cdn` → image `ghcr.io/raaad1on/nginx-gag:cdn-latest`

## Scheme

```
NGENIX → HTTPS :443 → Nginx → unix:/dev/shm/nginx/cdn-xhttp.sock → Xray xHTTP
                      ↘ other paths → gag landing page
```

## Features

- **HTTPS :443** for CDN origin
- **Real TLS certs** from `/etc/nginx/ssl/` (`fullchain.pem`, `privkey.pem`) — same as nginx-gag
- **Post-Quantum TLS**: X25519MLKEM768 hybrid via OpenSSL 3 + OQS
- **xHTTP streaming proxy** to `/dev/shm/nginx/cdn-xhttp.sock` (no buffering, long timeouts)
- **Gag site** + `/testspeed` (rate-limited)
- **`/health`** on :443 → JSON `200` for origin checks; :9000 → `204` for Docker healthcheck
- **`network_mode: host`** so Nginx and Xray share `/dev/shm`

## Prerequisites

- Docker + Docker Compose
- TLS certificates:
  - `/etc/nginx/ssl/fullchain.pem`
  - `/etc/nginx/ssl/privkey.pem`
- Xray xHTTP inbound listening on **`/dev/shm/nginx/cdn-xhttp.sock`**
- Port **443** free on the host

## Deploy

```bash
mkdir -p /opt/nginx-cdn /dev/shm/nginx && cd /opt/nginx-cdn

curl -fsSL -o docker-compose.yml \
  https://raw.githubusercontent.com/raaad1on/nginx-gag/cdn/docker-compose.yml.dist

# Edit DOMAIN and XHTTP_PATH to match your Xray inbound
nano docker-compose.yml

docker compose pull
docker compose up -d
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `example.com` | `server_name` + UI node badge from 3rd-level label |
| `XHTTP_PATH` | `/api/v1/hs/edge/sigments.ts` | Path prefix proxied to Xray (must match inbound) |

### Xray inbound

Listen on the same unix socket (not TCP):

```json
"listen": "/dev/shm/nginx/cdn-xhttp.sock"
```

Path in Xray must equal `XHTTP_PATH`. Socket directory `/dev/shm/nginx` must exist and be writable by Xray before Nginx starts accepting xHTTP traffic.

### SSL

Same as gag:

- `/etc/nginx/ssl/fullchain.pem`
- `/etc/nginx/ssl/privkey.pem`

## Ports / socket

| Endpoint | Purpose |
|----------|---------|
| `0.0.0.0:443` | HTTPS origin (NGENIX) |
| `0.0.0.0:9000` | Docker health (`/health` → 204) |
| `/dev/shm/nginx/cdn-xhttp.sock` | Upstream Xray xHTTP (created by Xray) |

## Verify

```bash
curl -sS https://127.0.0.1/health
# {"status":"ok","service":"nginx-cdn","version":"1.0"}

curl -f http://127.0.0.1:9000/health
# HTTP 204

ls -l /dev/shm/nginx/cdn-xhttp.sock
docker logs --tail 100 nginx-cdn
```

## Build locally

```bash
docker build -t nginx-gag:cdn .
cp docker-compose.yml.dist docker-compose.yml
# point image: nginx-gag:cdn
docker compose up -d
```

## xHTTP proxy rules (CDN requirements)

- HTTPS on 443
- Path match → unix socket upstream (query string preserved)
- GET/POST unrestricted
- `proxy_buffering off` / `proxy_request_buffering off`
- Headers: `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto: https`
- No redirects / gzip / body rewrite on xHTTP location
- Long `proxy_*_timeout` (3600s)
- Everything else → static gag page; `/health` for probes

## CI/CD

Push to `cdn` builds and pushes:

```
ghcr.io/raaad1on/nginx-gag:cdn-latest
```

## Related

- Landing / PQC gag (no xHTTP): branch `feature/pqc-standalone` → `:pqc-latest`
