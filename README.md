# nginx-gag

A secure authentication gateway built with nginx and Docker. This project provides a security barrier that presents a fake authentication interface while logging all access attempts.

## Features

- **🔒 SSL/TLS Security**: Modern encryption with support for wildcard certificates
- **🛡️ Security Headers**: Comprehensive security headers to prevent common attacks
- **🚫 Fake Authentication**: Always fails authentication for security through obscurity
- **📊 Health Monitoring**: Built-in health check endpoint for monitoring
- **🐳 Docker Ready**: Easy deployment with Docker Compose
- **🔒 Localhost Only**: Ports bound to localhost for enhanced security
- **📝 Audit Logging**: All authentication attempts are logged and monitored

## Quick Start

### Prerequisites

- Docker
- Docker Compose
- SSL certificates in `/etc/nginx/ssl/`

### Installation

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
   Edit `docker-compose.yml` and set your domain:
   ```yaml
   environment:
     - DOMAIN=your-domain.com
   ```

4. **Start the service:**
   ```bash
   docker-compose up -d
   ```

5. **Verify deployment:**
   ```bash
   # Check health status
   curl http://127.0.0.1:9000/health
   
   # Test the gateway
   curl -k https://127.0.0.1:444
   ```

## Architecture

### Ports

- **444**: HTTPS gateway (localhost only)
- **9000**: Health check endpoint (localhost only)

### Security Features

- **SSL/TLS**: TLS 1.2 and 1.3 support
- **HTTP/2**: Enabled for performance
- **Security Headers**: HSTS, CSP, X-Frame-Options, and more
- **Access Control**: Blocks hidden files and restricts API access
- **Authentication**: Fake authentication that always fails

### Certificate Support

- **Wildcard Certificates**: Full support for wildcard SSL certificates
- **Certificate Location**: `/etc/nginx/ssl/` on the host
- **File Names**: `fullchain.pem` and `privkey.pem`

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `example.com` | Your domain name |

### Docker Compose

```yaml
version: '3.8'

services:
  security-gateway:
    build: .
    environment:
      - DOMAIN=your-domain.com
    volumes:
      - /etc/nginx/ssl:/etc/nginx/ssl:ro
      - /var/log/nginx:/var/log/nginx
    ports:
      - "127.0.0.1:444:444"
      - "127.0.0.1:9000:9000"
    restart: unless-stopped
```

## Monitoring

### Health Check

The gateway provides a health check endpoint:
```bash
curl http://127.0.0.1:9000/health
```

Expected response: HTTP 204 (No Content)

### Docker Health Check

Docker automatically monitors container health:
```bash
docker ps
```

### Logs

View container logs:
```bash
docker-compose logs -f
```

## Security

### Network Security

- **Localhost Binding**: All ports bound to 127.0.0.1 only
- **No External Exposure**: No external network access
- **Firewall Friendly**: Minimal port requirements

### SSL Security

- **Modern Protocols**: TLS 1.2 and 1.3 only
- **Strong Ciphers**: Modern cipher suites prioritized
- **OCSP Stapling**: Enabled for certificate validation
- **Session Security**: Session tickets disabled

### Authentication Security

- **Fake Interface**: Always presents authentication form
- **Always Fails**: Authentication never succeeds
- **Audit Trail**: All attempts logged and monitored
- **No Credentials**: No real authentication credentials

## Troubleshooting

### Common Issues

1. **Container won't start**
   - Check port availability (444, 9000)
   - Verify SSL certificate paths
   - Check Docker logs

2. **SSL certificate errors**
   - Verify certificate files exist
   - Check file permissions
   - Validate certificate chain

3. **Health check failures**
   - Verify port binding
   - Check nginx configuration
   - Test connectivity

For detailed troubleshooting, see [docs/troubleshooting.md](docs/troubleshooting.md).

## Documentation

- [Deployment Guide](docs/deployment.md) - Step-by-step deployment instructions
- [Configuration Guide](docs/configuration.md) - Detailed configuration options
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions

## Development

### Building the Image

```bash
docker build -t nginx-gag .
```

### Testing

```bash
# Test nginx configuration
docker exec nginx-gag nginx -t

# Test SSL certificate
docker exec nginx-gag openssl x509 -in /etc/nginx/ssl/fullchain.pem -text -noout

# Test connectivity
curl -k https://127.0.0.1:444
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- [GitHub Issues](https://github.com/raaad1on/nginx-gag/issues)
- [Documentation](docs/)
- [Troubleshooting](docs/troubleshooting.md)

## Security Notes

⚠️ **Important**: This gateway is designed as a security barrier that prevents access rather than facilitates it. All authentication attempts will fail, and all access attempts are logged for security monitoring.

- **No Real Authentication**: The authentication interface is fake
- **Audit Logging**: All attempts are monitored and logged
- **Security Through Obscurity**: Designed to confuse and deter unauthorized access
- **No Sensitive Data**: No real credentials or sensitive information stored

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.