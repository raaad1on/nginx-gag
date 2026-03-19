# Quick Start Guide

## Setup Geo Database Serving

This guide will help you set up geo database serving functionality for nginx-gag.

### Prerequisites

- Docker and docker-compose installed
- Domain configured for your nginx-gag instance

### Steps

1. **Build and Start Container**
   ```bash
   docker-compose build
   docker-compose up -d
   ```

2. **Setup Automatic Updates**
   ```bash
   ./setup-cron.sh
   ```

3. **Verify Installation**
   ```bash
   # Check if files are downloaded
   ls -la geo-base/
   
   # Test nginx configuration
   docker-compose exec nginx-gag ls -la /var/www/files/
   ```

4. **Test File Access**
   Visit: `https://your-domain/client/geo/geoip.dat`
   Visit: `https://your-domain/client/geo/geosite.dat`

### Files Created

- `geo-base/update-geo-base.sh` - Update script
- `entrypoint.sh` - Container initialization
- `setup-cron.sh` - Cron job setup
- `README-GEO.md` - Detailed documentation

### Cron Schedule

Geo databases update automatically every 2 days at 3:00 AM.

### Logs

- Update logs: `geo-base/update.log`
- Container logs: `docker-compose logs nginx-gag`

### Manual Updates

```bash
./geo-base/update-geo-base.sh
```

### Troubleshooting

If files don't download on first startup:
```bash
docker-compose down
rm -f geo-base/*.dat
docker-compose up -d