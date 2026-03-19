#!/bin/bash
# Setup cron jobs for geo-base database updates

set -euo pipefail

PROJECT_DIR="$(pwd)"
GEO_BASE_SCRIPT="$PROJECT_DIR/geo-base/update-geo-base.sh"
LOG_FILE="$PROJECT_DIR/geo-base/update.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Setting up cron jobs for geo-base database updates"

# Check if update script exists
if [ ! -f "$GEO_BASE_SCRIPT" ]; then
    log "ERROR: Geo-base update script not found at $GEO_BASE_SCRIPT"
    exit 1
fi

# Make sure the script is executable
chmod +x "$GEO_BASE_SCRIPT"

# Add cron job for geo-base updates (every 2 days at 3:00 AM)
log "Adding cron job for geo-base updates (every 2 days at 3:00 AM)"

# Get current crontab or create empty if doesn't exist
CURRENT_CRON=$(crontab -l 2>/dev/null || true)

# Check if our cron job already exists
if echo "$CURRENT_CRON" | grep -q "$GEO_BASE_SCRIPT"; then
    log "Cron job for geo-base updates already exists, skipping"
else
    # Add new cron job
    echo "$CURRENT_CRON" | (crontab - 2>/dev/null || true; echo "0 3 */2 * * $GEO_BASE_SCRIPT >> $LOG_FILE 2>&1") | crontab -
    log "Cron job added successfully"
fi

# Display current cron jobs
log "Current cron jobs:"
crontab -l | grep -E "(geo-base|remnanode)" || log "No geo-related cron jobs found"

log "Cron setup completed"
log "Geo-base databases will be updated every 2 days at 3:00 AM"
log "Logs will be written to: $LOG_FILE"