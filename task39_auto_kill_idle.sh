#!/bin/bash

# Root Privilege Check
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root!" >&2
    exit 1
fi

# Settings
IDLE_THRESHOLD=30
LOG_FILE="/var/log/idle_session_killer.log"
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Detect and Kill Idle Sessions
w -h | awk '{print $1, $2, $4}' | while read user tty idle; do
    [[ "$idle" == "-" ]] && continue

    # Convert idle time to minutes
    idle_minutes=0
    if [[ "$idle" =~ ([0-9]+)days ]]; then
        idle_minutes=$((BASH_REMATCH[1] * 1440))
    elif [[ "$idle" == *":"* ]]; then
        IFS=':' read -r h m <<< "$idle"
        idle_minutes=$((10#$h * 60 + 10#$m))
    elif [[ "$idle" == *"m" ]]; then
        idle_minutes=${idle%m}
    elif [[ "$idle" == *"s" ]]; then
        idle_minutes=0
    else
        idle_minutes=$idle
    fi

    if (( idle_minutes > IDLE_THRESHOLD )); then
        # Kill all matching processes for user on that TTY
        ps -eo pid,tty,user,comm --no-headers | awk -v tty="$(basename "$tty")" -v usr="$user" '$2 == tty && $3 == usr {print $1}' | while read pid; do
            kill -9 "$pid"
            echo "$CURRENT_TIME - Killed PID $pid for $user on $tty after ${idle_minutes}m idle." >> "$LOG_FILE"
        done
    fi
done

# Add Cron Job (if not already present)
if ! crontab -l 2>/dev/null | grep -Fq "/usr/local/sbin/task39_auto_kill_idle.sh"; then
    (crontab -l 2>/dev/null; echo "*/15 * * * * /usr/local/sbin/task39_auto_kill_idle.sh") | crontab -
fi
