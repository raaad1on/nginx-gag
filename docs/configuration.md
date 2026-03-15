# Configuration Guide

This guide explains the configuration options and settings for the nginx-gag security gateway.

## Nginx Configuration

The gateway uses a template-based nginx configuration that supports environment variable substitution.

### Main Server Block (Port 444)

```nginx
server {
    listen 127.0.0.1:444 ssl http2;
    server_name ${DOMAIN};
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    # ... additional SSL and security settings
}
```

**Key Settings:**
- **Port**: 444 (HTTPS only)
- **Interface**: 127.0.0.1 (localhost only)
- **SSL**: Enabled with modern protocols
- **HTTP/2**: Enabled for performance

### Health Check Server Block (Port 9000)

```nginx
server {
    listen 127.0.0.1:9000;
    location /health {
        return 204;
    }
}
```

**Purpose:**
- Simple health check endpoint
- Returns HTTP 204 (No Content)
- Used by Docker health checks and monitoring systems

## SSL Configuration

### Supported Protocols
- TLS 1.2
- TLS 1.3

### Cipher Suites
Priority is given to modern, secure cipher suites:
- ECDHE-ECDSA-AES128-GCM-SHA256
- ECDHE-RSA-AES128-GCM-SHA256
- ECDHE-ECDSA-AES256-GCM-SHA384
- ECDHE-RSA-AES256-GCM-SHA384
- ECDHE-ECDSA-CHACHA20-POLY1305
- ECDHE-RSA-CHACHA20-POLY1305

### SSL Security Features
- **Session caching**: Enabled for performance
- **Session tickets**: Disabled for security
- **OCSP stapling**: Enabled
- **ECDH curves**: X25519, secp384r1, prime256v1

## Security Headers

The gateway includes comprehensive security headers:

### HSTS (HTTP Strict Transport Security)
```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```
- Forces HTTPS for 2 years
- Includes subdomains
- Preload ready

### Content Security Policy
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; frame-ancestors 'none'; form-action 'self';" always;
```
- Restricts content sources
- Prevents XSS attacks
- Blocks frame embedding

### Additional Security Headers
- **X-Frame-Options**: DENY (prevents clickjacking)
- **X-Content-Type-Options**: nosniff (prevents MIME type sniffing)
- **Referrer-Policy**: strict-origin (controls referrer information)
- **Permissions-Policy**: Disables dangerous browser features

## Authentication System

### Fake Authentication
The gateway presents a fake authentication interface:
- **Purpose**: Security through obscurity
- **Behavior**: Always fails authentication
- **Logging**: All attempts are logged and monitored

### Authentication Endpoints
- `/` - Main login page
- `/auth` - Authentication handler
- `/api`, `/v1`, `/status` - Protected endpoints (403 Forbidden)

## File Access Control

### Protected Files
```nginx
location ~ /\.(?!well-known) {
    deny all;
    return 404;
}
```
- Blocks access to hidden files
- Allows `.well-known` directory (for ACME challenges)

### Robots.txt
```nginx
location = /robots.txt {
    return 200 "User-agent: *\nDisallow: /";
}
```
- Disallows all crawling
- Prevents search engine indexing

## Logging Configuration

### Access Logs
```nginx
access_log off;
```
- Disabled for privacy
- No request logging

### Error Logs
```nginx
error_log /dev/null;
```
- Disabled to prevent information leakage
- Errors are not logged

## Environment Variables

### DOMAIN
- **Purpose**: Set the server name
- **Default**: example.com
- **Usage**: Used in nginx template substitution

### Example Usage
```bash
# Set domain in docker-compose.yml
environment:
  - DOMAIN=your-domain.com
```

## Docker Configuration

### Health Check
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 5s
```

**Parameters:**
- **Test**: HTTP request to health endpoint
- **Interval**: Check every 30 seconds
- **Timeout**: 10 second timeout
- **Retries**: 3 failed attempts before marking unhealthy
- **Start period**: 5 second grace period

### Volumes
```yaml
volumes:
  - /etc/nginx/ssl:/etc/nginx/ssl:ro
  - /var/log/nginx:/var/log/nginx
```

**Purpose:**
- SSL certificates (read-only)
- Nginx logs (writable)

### Ports
```yaml
ports:
  - "127.0.0.1:444:444"
  - "127.0.0.1:9000:9000"
```

**Security:**
- Bound to localhost only
- No external network exposure

## Performance Tuning

### Nginx Worker Processes
Default nginx configuration is used with automatic worker process detection.

### SSL Session Cache
```nginx
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
```
- 10MB shared session cache
- 1 day session timeout

### HTTP/2
- Enabled for better performance
- Multiplexed connections
- Header compression

## Monitoring and Observability

### Health Check Endpoint
- **URL**: `http://127.0.0.1:9000/health`
- **Response**: HTTP 204 (No Content)
- **Purpose**: Container health monitoring

### Docker Metrics
- Container resource usage
- Health check status
- Restart count

### Manual Testing
```bash
# Test health endpoint
curl http://127.0.0.1:9000/health

# Test gateway (should show login page)
curl -k https://127.0.0.1:444

# Test protected endpoint (should return 403)
curl -k https://127.0.0.1:444/api
```

## Security Best Practices

### Certificate Management
- Use strong, trusted certificates
- Keep private keys secure
- Regular certificate rotation
- Proper file permissions

### Network Security
- Localhost binding only
- Firewall configuration
- No external exposure

### Container Security
- Minimal base image (nginx:alpine)
- Read-only certificate volumes
- No sensitive data in container
- Regular security updates

### Monitoring
- Health check monitoring
- Container restart alerts
- SSL certificate expiration monitoring

## Troubleshooting Configuration

### Common Issues

1. **SSL Certificate Errors**
   - Verify certificate paths
   - Check file permissions
   - Validate certificate chain

2. **Port Binding Issues**
   - Check for port conflicts
   - Verify localhost binding
   - Check firewall rules

3. **Template Substitution**
   - Verify DOMAIN environment variable
   - Check nginx template syntax
   - Review container logs

### Debug Commands

```bash
# Check nginx configuration
docker exec nginx-gag nginx -t

# View nginx configuration
docker exec nginx-gag cat /etc/nginx/conf.d/default.conf

# Check SSL certificate
docker exec nginx-gag openssl x509 -in /etc/nginx/ssl/fullchain.pem -text -noout
```

This configuration provides a secure, performant, and easily deployable security gateway suitable for production environments.