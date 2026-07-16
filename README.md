# nginx-gag

Post-quantum secure authentication gateway built with nginx and Open Quantum Safe. Presents a fake authentication interface while logging all access attempts.

## Features

- **Post-Quantum TLS**: ML-KEM (X25519MLKEM768) hybrid key exchange via OpenSSL 3 + OQS
- **Security Headers**: HSTS, CSP, X-Frame-Options, and more
- **Fake Authentication**: Always fails authentication for security through obscurity
- **Dynamic Node ID**: Badge like `DE2-NODE-387` from the third-level DOMAIN label + random digits
- **Speed Test**: `/testspeed` serves a fresh 10MB binary (rate-limited to 10/min per IP)
- **Unix Socket**: Also listens on `/dev/shm/nginx/nginx.sock` (ssl)
- **Health Monitoring**: Built-in health check endpoint
- **Docker Ready**: Automated CI/CD build, pull and run
- **Localhost Only**: Ports bound to 127.0.0.1

## Quick Start

### Prerequisites

- Docker + Docker Compose
- SSL certificates in `/etc/nginx/ssl/` (`fullchain.pem`, `privkey.pem`)

### Deploy

```bash
mkdir -p /opt/nginx-gag && cd /opt/nginx-gag

curl -fsSL -o docker-compose.yml \
  https://raw.githubusercontent.com/raaad1on/nginx-gag/feature/pqc-standalone/docker-compose.yml.dist

# edit DOMAIN=example.com to your FQDN
nano docker-compose.yml

docker compose pull
docker compose up -d
```

Config and UI are baked into the image. You only need compose + SSL certs + `DOMAIN`.

### Build locally

```bash
docker build -t nginx-gag .
docker compose up -d
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `example.com` | FQDN for `server_name`; third-level label drives UI node ID |
| `TAG` | `latest` | Docker image tag |

### Node ID

On each container start, the entrypoint builds a badge from `DOMAIN`:

- `node1.example.com` → `NODE1-NODE-387` (random 100–999)
- Substituted into `index.html` as `{{NODE_ID}}`

### Optional config override

To override the baked-in nginx template, mount your own file:

```yaml
volumes:
  - ./nginx.conf:/etc/nginx/nginx.conf.template:ro
```

### SSL Certificates

Place your certificates at:
- `/etc/nginx/ssl/fullchain.pem`
- `/etc/nginx/ssl/privkey.pem`

## Ports and Socket

- **444**: HTTPS gateway (127.0.0.1 only)
- **9000**: Health check endpoint (127.0.0.1 only)
- **Unix socket**: `/dev/shm/nginx/nginx.sock` (ssl), mounted via compose volume

## Speed Test

- Endpoint: `GET /testspeed` → 10MB random binary (`Content-Disposition: attachment`)
- File written to `/var/www/speedtest-10mb.bin` on every container start
- Rate limit: 10 downloads per minute per IP (`429` when exceeded)
- Button on the login page: **Test Speed**

## CI/CD

On push to `feature/pqc-standalone`, GitHub Actions builds and pushes:

```
ghcr.io/raaad1on/nginx-gag:pqc-latest
```

On the server:
```bash
docker compose pull
docker compose up -d
```

## Health Check

```bash
curl http://127.0.0.1:9000/health
# Expected: HTTP 204
```

## TLS Configuration

- **Protocol**: TLS 1.3 only
- **Key Exchange**: X25519MLKEM768 (post-quantum hybrid), X25519, secp384r1
- **Ciphers**: AES-256-GCM, ChaCha20-Poly1305, AES-128-GCM
- **OCSP Stapling**: Enabled
- **Session Tickets**: Disabled

## Security

- All ports bound to 127.0.0.1 — no external exposure
- Authentication interface is fake — always fails
- Speed test endpoint is rate-limited
- All access attempts are logged and monitored
