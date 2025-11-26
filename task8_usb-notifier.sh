#!/bin/bash

LOG_DIR="/var/log/usb"
LOG_FILE="$LOG_DIR/monitor.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"

# Get current time
TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Device name passed by udev
DEVICE="$1"

# Full device path
DEV_PATH="/dev/$DEVICE"

# Check if device exists
if [[ ! -b "$DEV_PATH" ]]; then
    exit 1
fi

# Check if it's a USB storage device
if udevadm info --query=all --name="$DEV_PATH" | grep -q "ID_USB_DRIVER=usb-storage"; then

    INFO=$(lsblk "$DEV_PATH" -o NAME,MOUNTPOINT,SIZE,FSTYPE -nr | head -n 1)

    echo "[$TIME] USB Device Detected: $DEV_PATH - $INFO" >> "$LOG_FILE"

fi

# Create a udev rule so that the script runs whenever an usb is connected like 
# ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", RUN+="/usr/local/bin/task8_usb-notifier.sh %k"
# Place the rule file in /etc/udev/rules.d/99-usb-notifier.rules

