#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

# Define log directory and file
LOG_DIR="/var/log/user"
LOG_FILE="$LOG_DIR/user_sessions.log"
SCRIPT_PATH="/usr/local/bin/task10_user_session_logger.sh"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR"

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log active sessions
echo "[$TIMESTAMP] Logged-in users:" >> "$LOG_FILE"
who | awk -v ts="[$TIMESTAMP]" '{printf "%s | User: %s | Terminal: %s | Login: %s %s | From: %s\n", ts, $1, $2, $3, $4, $5}' >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Cron Job Setup
CRON_JOB="0 * * * * $SCRIPT_PATH"

# Check if cron job already exists
if ! crontab -l | grep -Fq "$SCRIPT_PATH"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job added to run the script hourly."
fi
