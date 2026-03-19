#!/bin/bash
# Update script for geo-base databases
# Downloads geoip.dat and geosite.dat from raaad1on/geosite-geoip-compact

set -euo pipefail

DEST_DIR="$(pwd)/geo-base"
TMP_DIR="$(mktemp -d)"
LOG_FILE="$DEST_DIR/update.log"

# Cleanup function
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Ensure destination directory exists
mkdir -p "$DEST_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting geo-base database update in $DEST_DIR"

# Download geoip database
log "Downloading geoip database..."
if curl -L -o "${TMP_DIR}/geoip-compact.dat" "https://github.com/raaad1on/geosite-geoip-compact/releases/download/latest/geoip-compact.dat"; then
    log "Successfully downloaded geoip database"
else
    log "ERROR: Failed to download geoip database"
    exit 1
fi

# Download geosite database
log "Downloading geosite database..."
if curl -L -o "${TMP_DIR}/geosite-compact.dat" "https://github.com/raaad1on/geosite-geoip-compact/releases/download/latest/geosite-compact.dat"; then
    log "Successfully downloaded geosite database"
else
    log "ERROR: Failed to download geosite database"
    exit 1
fi

# Install files with proper permissions
log "Installing files..."
install -m 644 "${TMP_DIR}/geoip-compact.dat"   "${DEST_DIR}/geoip.dat"
install -m 644 "${TMP_DIR}/geosite-compact.dat" "${DEST_DIR}/geosite.dat"

# Verify installation
if [ -f "${DEST_DIR}/geoip.dat" ] && [ -f "${DEST_DIR}/geosite.dat" ]; then
    log "SUCCESS: Geo-base database update completed successfully"
    log "Installed files:"
    log "  - geoip.dat ($(stat -c%s "${DEST_DIR}/geoip.dat") bytes)"
    log "  - geosite.dat ($(stat -c%s "${DEST_DIR}/geosite.dat") bytes)"
else
    log "ERROR: Installation verification failed"
    exit 1
fi