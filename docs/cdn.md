# CDN / NGENIX origin (branch `cdn`)

## Topology

```
NGENIX CDN
    │ HTTPS :443
    ▼
Nginx (ghcr.io/raaad1on/nginx-gag:cdn-latest)
    │ location ^~ $XHTTP_PATH  →  unix:/dev/shm/nginx/cdn-xhttp.sock
    │ other paths              →  /var/www (gag)
    │ /health                  →  JSON 200
    ▼
Xray xHTTP inbound (unix socket)
```

## Environment

| Variable | Default | Notes |
|----------|---------|--------|
| `DOMAIN` | `example.com` | TLS `server_name` + node badge |
| `XHTTP_PATH` | `/api/v1/hs/edge/sigments.ts` | Must match Xray inbound path |

## Certificates

Mount real certs (same as gag):

```
/etc/nginx/ssl/fullchain.pem
/etc/nginx/ssl/privkey.pem
```

## Unix socket

Fixed path: `/dev/shm/nginx/cdn-xhttp.sock`

- Created by **Xray**, not by Nginx
- Compose mounts `/dev/shm/nginx` into the container
- Use `network_mode: host` so host Xray and Nginx share the same shm tree

## Streaming settings

xHTTP `location` disables buffering and gzip, sets long timeouts, and forwards:

- `Host`
- `X-Real-IP`
- `X-Forwarded-For`
- `X-Forwarded-Proto: https`
