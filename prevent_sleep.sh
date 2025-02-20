#!/bin/bash
# Jan Gebser - Brainhub24.com
# Email: github@brainhub24.com
# About this Tool:
# - It is a versaitel utility tool to improve the proxmox configurations hosted on a regular laptop device.
# Improvements:
# - Preventing the laptop to fall asleep
# - Added Comments  

# Path to the  logind.conf file
LOGIND_CONF="/etc/systemd/logind.conf"

# Backup the current logind.conf file
cp "$LOGIND_CONF" "LOGIND_CONF.bak"

# Add the required lines to logind.conf
echo "HandleLidSwitch=ignore" >> "$LOGIND_CONF"
echo "HandleLidSwitchDocked=ignore" >> "$LOGIND_CONF"

# Restart the systemd-logind service to apply changes
systemctl restart systemd-logind.service

# Print success message
echo "Lid switch settings updated and service restarted."
