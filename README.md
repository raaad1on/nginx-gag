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
- SSL certificates in `/etc/nginx/ssl/`

### Deploy

```bash
git clone https://github.com/raaad1on/nginx-gag.git
cd nginx-gag
git checkout feature/pqc-standalone
```

Create compose file from template:
```bash
cp docker-compose.yml.dist docker-compose.yml
```

Edit `docker-compose.yml` and set your domain (third-level label becomes the node prefix):
```yaml
environment:
  - DOMAIN=de2.edgestream.xyz
```

Place SSL certificates:
```bash
sudo mkdir -p /etc/nginx/ssl
sudo cp fullchain.pem /etc/nginx/ssl/
sudo cp privkey.pem /etc/nginx/ssl/
```

Start:
```bash
docker compose up -d
```

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

- `de2.edgestream.xyz` → `DE2-NODE-387` (random 100–999)
- Substituted into `index.html` as `{{NODE_ID}}`

### Nginx Config

`nginx.conf` is mounted into the container as a template. The entrypoint script replaces `{{DOMAIN}}` with the value of the `DOMAIN` environment variable at startup.

To apply config changes, restart the container:
```bash
docker compose restart
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
- File regenerated on every container start
- Rate limit: 10 downloads per minute per IP (`429` when exceeded)
- Button on the login page: **Test Speed**

## CI/CD

On push to `feature/pqc-standalone`, GitHub Actions automatically builds and pushes the image to GHCR:

```
ghcr.io/raaad1on/nginx-gag:pqc-latest
```

On the server:
```bash
docker pull ghcr.io/raaad1on/nginx-gag:pqc-latest
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
