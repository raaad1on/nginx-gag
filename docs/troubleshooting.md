# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the nginx-gag security gateway.

## Common Issues

### 1. Container Won't Start

**Symptoms:**
- Container exits immediately
- Docker Compose shows container in "exited" state

**Diagnosis:**
```bash
# Check container logs
docker-compose logs

# Check Docker events
docker events --filter "event=die"

# Verify Docker installation
docker --version
docker-compose --version
```

**Solutions:**
1. **Port conflicts**: Check if ports 444 or 9000 are in use
   ```bash
   sudo lsof -i :444
   sudo lsof -i :9000
   ```

2. **Insufficient permissions**: Ensure Docker daemon is running
   ```bash
   sudo systemctl status docker
   ```

3. **Dockerfile issues**: Verify Dockerfile syntax
   ```bash
   docker build -t test-build .
   ```

### 2. SSL Certificate Issues

**Symptoms:**
- SSL handshake failures
- Certificate validation errors
- Nginx won't start

**Diagnosis:**
```bash
# Check certificate files
ls -la /etc/nginx/ssl/

# Verify certificate validity
openssl x509 -in /etc/nginx/ssl/fullchain.pem -text -noout

# Check private key
openssl rsa -in /etc/nginx/ssl/privkey.pem -check -noout
```

**Solutions:**
1. **Missing certificates**: Ensure files exist
   ```bash
   sudo mkdir -p /etc/nginx/ssl
   # Copy your certificates here
   ```

2. **Wrong permissions**: Fix file permissions
   ```bash
   sudo chmod 644 /etc/nginx/ssl/fullchain.pem
   sudo chmod 600 /etc/nginx/ssl/privkey.pem
   ```

3. **Certificate chain issues**: Verify certificate chain
   ```bash
   openssl verify -CAfile /etc/nginx/ssl/fullchain.pem /etc/nginx/ssl/fullchain.pem
   ```

### 3. Health Check Failures

**Symptoms:**
- Container marked as unhealthy
- Health check endpoint returns errors

**Diagnosis:**
```bash
# Test health endpoint manually
curl http://127.0.0.1:9000/health

# Check container health status
docker inspect --format='{{json .State.Health}}' nginx-gag

# View health check logs
docker-compose logs | grep health
```

**Solutions:**
1. **Port binding issues**: Verify ports are bound correctly
   ```bash
   netstat -tlnp | grep 9000
   ```

2. **Container networking**: Check container network
   ```bash
   docker exec nginx-gag curl http://localhost:9000/health
   ```

3. **Nginx configuration**: Verify nginx is running
   ```bash
   docker exec nginx-gag nginx -t
   ```

### 4. Authentication Issues

**Symptoms:**
- Login page not loading
- Authentication always fails
- 404 errors on main page

**Diagnosis:**
```bash
# Test main page
curl -k https://127.0.0.1:444

# Check nginx configuration
docker exec nginx-gag cat /etc/nginx/conf.d/default.conf

# Verify HTML files
docker exec nginx-gag ls -la /var/www/html/
```

**Solutions:**
1. **Missing HTML files**: Rebuild container
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

2. **Configuration issues**: Check nginx template
   ```bash
   docker exec nginx-gag cat /etc/nginx/templates/default.conf.template
   ```

3. **SSL issues**: Verify SSL configuration
   ```bash
   docker exec nginx-gag openssl s_client -connect localhost:444 -servername your-domain.com
   ```

### 5. Network Connectivity Issues

**Symptoms:**
- Cannot access gateway from localhost
- Connection timeouts
- Firewall blocking

**Diagnosis:**
```bash
# Check if ports are listening
netstat -tlnp | grep -E ':(444|9000)'

# Test local connectivity
telnet 127.0.0.1 444
telnet 127.0.0.1 9000

# Check firewall rules
sudo ufw status
sudo iptables -L
```

**Solutions:**
1. **Firewall blocking**: Allow ports
   ```bash
   sudo ufw allow 444
   sudo ufw allow 9000
   ```

2. **Port binding**: Verify localhost binding
   ```bash
   docker exec nginx-gag netstat -tlnp
   ```

3. **Network configuration**: Check Docker network
   ```bash
   docker network ls
   docker network inspect nginx-gag-network
   ```

### 6. Performance Issues

**Symptoms:**
- Slow response times
- High resource usage
- Container restarts

**Diagnosis:**
```bash
# Check resource usage
docker stats nginx-gag

# Monitor logs for errors
docker-compose logs -f

# Check nginx performance
docker exec nginx-gag nginx -V
```

**Solutions:**
1. **Resource limits**: Adjust Docker resource limits
   ```yaml
   # In docker-compose.yml
   deploy:
     resources:
       limits:
         cpus: '1.0'
         memory: 512M
   ```

2. **Nginx tuning**: Optimize nginx configuration
   ```bash
   # Edit nginx.conf.template
   # Adjust worker_processes, worker_connections
   ```

3. **SSL optimization**: Enable SSL session caching
   ```nginx
   ssl_session_cache shared:SSL:10m;
   ssl_session_timeout 1d;
   ```

## Debug Commands

### Container Diagnostics
```bash
# View container information
docker inspect nginx-gag

# Check container processes
docker exec nginx-gag ps aux

# View container logs
docker logs nginx-gag

# Enter container shell
docker exec -it nginx-gag sh
```

### Nginx Diagnostics
```bash
# Test nginx configuration
docker exec nginx-gag nginx -t

# Reload nginx configuration
docker exec nginx-gag nginx -s reload

# View nginx status
docker exec nginx-gag nginx -s status

# Check nginx version and modules
docker exec nginx-gag nginx -V
```

### SSL Diagnostics
```bash
# Check certificate expiration
openssl x509 -in /etc/nginx/ssl/fullchain.pem -noout -dates

# Verify certificate chain
openssl verify -CAfile /etc/nginx/ssl/fullchain.pem /etc/nginx/ssl/fullchain.pem

# Test SSL connection
openssl s_client -connect 127.0.0.1:444 -servername your-domain.com
```

### Network Diagnostics
```bash
# Check port binding
netstat -tlnp | grep -E ':(444|9000)'

# Test connectivity
curl -v http://127.0.0.1:9000/health
curl -vk https://127.0.0.1:444

# Check DNS resolution
nslookup your-domain.com
```

## Log Analysis

### Docker Logs
```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs nginx-gag

# View logs with timestamps
docker-compose logs -t
```

### Nginx Logs
```bash
# View access logs (if enabled)
docker exec nginx-gag tail -f /var/log/nginx/access.log

# View error logs
docker exec nginx-gag tail -f /var/log/nginx/error.log

# View combined logs
docker exec nginx-gag tail -f /var/log/nginx/*.log
```

## Recovery Procedures

### Container Recovery
```bash
# Restart container
docker-compose restart

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d

# Force recreate
docker-compose up -d --force-recreate
```

### Configuration Recovery
```bash
# Reset nginx configuration
docker-compose down
docker volume rm nginx-gag_nginx-gag-network
docker-compose up -d

# Restore from backup
# (Assuming you have backups of your configuration)
```

### Certificate Recovery
```bash
# Regenerate certificates (if using Let's Encrypt)
# This depends on your certificate provider

# Restore from backup
sudo cp backup/fullchain.pem /etc/nginx/ssl/
sudo cp backup/privkey.pem /etc/nginx/ssl/
sudo chmod 644 /etc/nginx/ssl/fullchain.pem
sudo chmod 600 /etc/nginx/ssl/privkey.pem
```

## When to Seek Help

Contact support or create a GitHub issue if you encounter:

1. **Persistent SSL errors** after following troubleshooting steps
2. **Container crashes** that cannot be resolved
3. **Security concerns** or vulnerabilities
4. **Feature requests** or enhancement suggestions

### Information to Include
When reporting issues, please provide:

1. **Error messages** and logs
2. **Docker and Docker Compose versions**
3. **Operating system** and version
4. **Steps to reproduce** the issue
5. **Configuration files** (with sensitive data redacted)
6. **Expected vs actual behavior**

This troubleshooting guide covers the most common issues. For additional support, check the [GitHub repository](https://github.com/raaad1on/nginx-gag) or create a new issue.