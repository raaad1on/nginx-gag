#!/bin/bash
# Entrypoint script for nginx-gag container
# Checks for geo-base files and downloads them if missing

set -euo pipefail

GEO_BASE_DIR="/var/www/files"
GEO_BASE_SCRIPT="/geo-base/update-geo-base.sh"
LOG_FILE="/var/log/geo-base-init.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting nginx-gag container initialization"

# Check if geo-base files exist
if [ ! -f "${GEO_BASE_DIR}/geoip.dat" ] || [ ! -f "${GEO_BASE_DIR}/geosite.dat" ]; then
    log "Geo-base files not found, starting initial download"
    
    # Ensure geo-base directory exists
    mkdir -p "$GEO_BASE_DIR"
    
    # Check if update script exists
    if [ -f "$GEO_BASE_SCRIPT" ]; then
        log "Running geo-base update script"
        if "$GEO_BASE_SCRIPT"; then
            log "Geo-base files downloaded successfully"
        else
            log "ERROR: Failed to download geo-base files"
            exit 1
        fi
    else
        log "ERROR: Geo-base update script not found at $GEO_BASE_SCRIPT"
        exit 1
    fi
else
    log "Geo-base files already exist, skipping download"
fi

# Verify files are present
if [ -f "${GEO_BASE_DIR}/geoip.dat" ] && [ -f "${GEO_BASE_DIR}/geosite.dat" ]; then
    log "SUCCESS: All geo-base files are available"
    log "geoip.dat: $(stat -c%s "${GEO_BASE_DIR}/geoip.dat") bytes"
    log "geosite.dat: $(stat -c%s "${GEO_BASE_DIR}/geosite.dat") bytes"
else
    log "ERROR: Geo-base files verification failed"
    exit 1
fi

log "Container initialization completed, starting nginx"

# Start nginx
exec "$@"