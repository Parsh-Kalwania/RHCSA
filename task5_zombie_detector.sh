#!/bin/bash

LOG_FILE="/var/log/zombie_processes.log"
SCRIPT_PATH="/usr/local/bin/task5_zombie_detector.sh"

# 1. Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

# 2. Detect zombie processes
ZOMBIES=$(ps -eo pid,ppid,state,cmd --no-headers | awk '$3 ~ /^Z/')

# 3. Log only if zombies found
if [[ -n "$ZOMBIES" ]]; then
    {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Zombie processes detected:"
	echo "PID  PPID  STATE  COMMAND"
        echo "$ZOMBIES"
        echo "------------------------------------------------------------"
    } >> "$LOG_FILE"
fi

# 4. Install cron job
CRON_JOB="0 * * * * $SCRIPT_PATH"
(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH"; echo "$CRON_JOB") | sort -u | crontab -
