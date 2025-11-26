#!/bin/bash

export PATH=/usr/sbin:/usr/bin:/sbin:/bin

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# 1. Collect system info
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
LAST_LOGIN=$(last -i | grep -v 'wtmp begins' | head -n 1)

# 2. Generate MOTD
cat <<EOF > /etc/motd
..................................................................
Welcome to $HOSTNAME!

IP Address  : $IP_ADDRESS
Uptime      : $UPTIME
Last Login  : $LAST_LOGIN

Have a productive session!
..................................................................
EOF

# 3. Add cron job (if not already added)
CRON_LINE="*/5 * * * * /usr/local/bin/task25_update_motd.sh"
(crontab -l 2>/dev/null | grep -v -F "$CRON_LINE"; echo "$CRON_LINE") | crontab -
