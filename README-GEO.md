# Geo Database Setup for nginx-gag

This document describes how to set up geo database serving functionality for the nginx-gag project.

## Overview

The nginx-gag container now serves geo databases that can be downloaded by clients:
- `https://your-domain/client/geo/geoip.dat`
- `https://your-domain/client/geo/geosite.dat`

## Features

- Automatic download of geo databases on first container startup
- Regular updates via cron (every 2 days at 3:00 AM)
- Detailed logging of download operations
- Security headers for file downloads
- Health checks for database availability

## Setup Instructions

### 1. Build and Start Container

```bash
# Build the container
docker-compose build

# Start the container
docker-compose up -d
```

### 2. Setup Cron Jobs

Run the cron setup script to configure automatic updates:

```bash
./setup-cron.sh
```

This will:
- Add a cron job to update geo databases every 2 days
- Set up logging to `./geo-base/update.log`
- Verify the cron job was added successfully

### 3. Manual Updates

You can manually update the geo databases at any time:

```bash
./geo-base/update-geo-base.sh
```

### 4. Check Logs

Monitor the update process:

```bash
# View update logs
tail -f ./geo-base/update.log

# View container initialization logs
docker-compose logs nginx-gag
```

## File Locations

### On Host System
- Geo databases: `./geo-base/`
- Update script: `./geo-base/update-geo-base.sh`
- Update logs: `./geo-base/update.log`
- Container logs: `/var/log/geo-base-init.log` (inside container)

### Inside Container
- Geo databases: `/var/www/files/`
- Entry script: `/entrypoint.sh`

## Cron Schedule

The geo databases are automatically updated every 2 days at 3:00 AM with the following cron job:

```
0 3 */2 * * /path/to/geo-base/update-geo-base.sh >> /path/to/geo-base/update.log 2>&1
```

## Database Sources

The geo databases are downloaded from:
- **Source**: `raaad1on/geosite-geoip-compact` repository
- **Files**: `geoip.dat` and `geosite.dat`

## Security Features

- Files are served with security headers:
  - `Content-Disposition: attachment` - Forces download
  - `X-Content-Type-Options: nosniff` - Prevents MIME type sniffing
  - `X-Frame-Options: DENY` - Prevents clickjacking
- Container has read-only access to SSL certificates
- Write access only for geo database updates

## Troubleshooting

### Container Won't Start
Check if geo-base files are being downloaded:
```bash
docker-compose logs nginx-gag
```

### Manual Download Fails
Check network connectivity and script permissions:
```bash
chmod +x ./geo-base/update-geo-base.sh
./geo-base/update-geo-base.sh
```

### Cron Job Not Running
Verify cron job is installed:
```bash
crontab -l | grep geo-base
```

Check cron service status:
```bash
sudo systemctl status cron
```

### Files Not Accessible
Verify volume mount is working:
```bash
docker-compose exec nginx-gag ls -la /var/www/files/
```

## Health Checks

The container includes health checks for:
- Nginx service availability (port 9000)
- Geo database file presence
- File download functionality

## Resetting Databases

To force a fresh download of geo databases:

```bash
# Stop container
docker-compose down

# Remove existing files
rm -f ./geo-base/*.dat

# Start container (will trigger fresh download)
docker-compose up -d
```

## Monitoring

Monitor database update status:

```bash
# Check last update time
ls -la ./geo-base/*.dat

# View recent logs
tail -20 ./geo-base/update.log