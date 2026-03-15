# Deployment Guide

This guide explains how to deploy the nginx-gag security gateway using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose installed
- SSL certificates in `/etc/nginx/ssl/` directory

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/raaad1on/nginx-gag.git
   cd nginx-gag
   ```

2. **Prepare SSL certificates:**
   ```bash
   sudo mkdir -p /etc/nginx/ssl
   sudo cp fullchain.pem /etc/nginx/ssl/
   sudo cp privkey.pem /etc/nginx/ssl/
   sudo chmod 644 /etc/nginx/ssl/fullchain.pem
   sudo chmod 600 /etc/nginx/ssl/privkey.pem
   ```

3. **Configure your domain:**
   ```bash
   # Set your domain in docker-compose.yml
   # Change DOMAIN=your-domain.com
   ```

4. **Start the service:**
   ```bash
   docker-compose up -d
   ```

5. **Verify deployment:**
   ```bash
   # Check health status
   curl http://127.0.0.1:9000/health
   
   # Test the gateway (should show login page)
   curl -k https://127.0.0.1:444
   ```

## Configuration

### Environment Variables

- `DOMAIN`: Your domain name (default: example.com)

### Volumes

- `/etc/nginx/ssl:/etc/nginx/ssl:ro` - SSL certificates (read-only)
- `/var/log/nginx:/var/log/nginx` - Nginx logs

### Ports

- `127.0.0.1:444:444` - HTTPS gateway (localhost only)
- `127.0.0.1:9000:9000` - Health check endpoint (localhost only)

## SSL Certificates

The gateway expects SSL certificates in the following location:
- Certificate: `/etc/nginx/ssl/fullchain.pem`
- Private key: `/etc/nginx/ssl/privkey.pem`

### Wildcard Certificates

This gateway supports wildcard certificates. For example, if you have a wildcard certificate for `*.example.com`, it will work for any subdomain.

### Certificate Permissions

Ensure proper permissions for security:
```bash
sudo chmod 644 /etc/nginx/ssl/fullchain.pem
sudo chmod 600 /etc/nginx/ssl/privkey.pem
```

## Monitoring

### Health Check

The gateway provides a health check endpoint:
```bash
curl http://127.0.0.1:9000/health
```

Expected response: HTTP 204 (No Content)

### Docker Health Check

Docker automatically monitors the container health using the built-in health check. You can view the status with:
```bash
docker ps
```

### Logs

View container logs:
```bash
docker-compose logs -f
```

## Troubleshooting

### Container Won't Start

1. Check if ports 444 and 9000 are available:
   ```bash
   sudo lsof -i :444
   sudo lsof -i :9000
   ```

2. Verify SSL certificate paths:
   ```bash
   ls -la /etc/nginx/ssl/
   ```

3. Check Docker logs:
   ```bash
   docker-compose logs
   ```

### SSL Certificate Issues

1. Verify certificate files exist:
   ```bash
   ls -la /etc/nginx/ssl/fullchain.pem
   ls -la /etc/nginx/ssl/privkey.pem
   ```

2. Check certificate validity:
   ```bash
   openssl x509 -in /etc/nginx/ssl/fullchain.pem -text -noout
   ```

3. Verify private key matches certificate:
   ```bash
   openssl rsa -in /etc/nginx/ssl/privkey.pem -pubout -outform DER | openssl sha256
   openssl x509 -in /etc/nginx/ssl/fullchain.pem -pubkey -noout -outform DER | openssl sha256
   ```

### Network Issues

1. Verify container is listening on correct interfaces:
   ```bash
   docker exec nginx-gag netstat -tlnp
   ```

2. Check firewall rules if accessing from external networks.

## Security Considerations

- Ports are bound to localhost only (127.0.0.1)
- SSL certificates are mounted read-only
- No sensitive information is stored in the container
- All authentication attempts are logged and monitored

## Updates

To update the gateway:

1. Pull latest changes:
   ```bash
   git pull origin master
   ```

2. Rebuild and restart:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

## Backup

Backup important data:
- SSL certificates in `/etc/nginx/ssl/`
- Docker Compose configuration
- Any custom configurations

## Support

For issues and support, please check:
- [GitHub Issues](https://github.com/raaad1on/nginx-gag/issues)
- [Troubleshooting Guide](troubleshooting.md)