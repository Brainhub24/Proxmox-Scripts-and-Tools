#!/bin/bash
# Jan Gebser - Brainhub24.com
# Email: github@brainhub24.com
# About this Tool:
# - It is a safely decommission a single Proxmox node from a cluster including a configuration dump
# PROXMOX Community
# Idea: I created this tiny tool based on the commands i found in the following thread.
# Topic: https://forum.proxmox.com/threads/remove-or-reset-cluster-configuration.114260/

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: This script must be run as root" >&2
        exit 1
    fi
}

# Function to check if this is a Proxmox system
check_proxmox() {
    if [ ! -f "/usr/bin/pvesh" ]; then
        echo "Error: This doesn't appear to be a Proxmox system" >&2
        exit 1
    fi
}

# Function to backup configuration
backup_config() {
    local backup_dir="/root/cluster-backup-$(date '+%Y%m%d_%H%M%S')"
    log_message "Creating backup at $backup_dir"
    
    mkdir -p "$backup_dir"
    if [ -d "/etc/corosync" ]; then
        cp -r /etc/corosync/* "$backup_dir/" 2>/dev/null
    fi
    if [ -f "/etc/pve/corosync.conf" ]; then
        cp /etc/pve/corosync.conf "$backup_dir/" 2>/dev/null
    fi
}

# Main decommission function
decommission_node() {
    log_message "Starting cluster decommission process"
    
    # Stop cluster services
    log_message "Stopping cluster services"
    systemctl stop pve-cluster corosync
    
    # Run pmxcfs in local mode
    log_message "Starting pmxcfs in local mode"
    pmxcfs -l &
    sleep 2
    
    # Remove cluster configuration
    log_message "Removing cluster configuration files"
    rm -f /etc/corosync/* 2>/dev/null
    rm -f /etc/pve/corosync.conf 2>/dev/null
    
    # Kill pmxcfs
    log_message "Terminating pmxcfs process"
    killall pmxcfs 2>/dev/null
    
    # Restart cluster service
    log_message "Restarting PVE cluster service"
    systemctl start pve-cluster
    
    # Verify cluster service is running
    if systemctl is-active --quiet pve-cluster; then
        log_message "PVE cluster service successfully restarted"
    else
        log_message "Warning: PVE cluster service failed to restart"
        return 1
    fi
}

# Main execution
main() {
    check_root
    check_proxmox
    
    echo "WARNING: This script will remove this node from its cluster configuration."
    echo "Make sure all VMs and resources are properly migrated before proceeding."
    echo "A backup of the current configuration will be created."
    read -p "Do you want to continue? (y/N): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_message "Operation cancelled by user"
        exit 0
    fi
    
    backup_config
    if decommission_node; then
        log_message "Node successfully removed from cluster"
        echo "----------------------------------------------------------------"
        echo "Node has been successfully removed from the cluster configuration."
        echo "Backup of the original configuration is available in /root/"
        echo "----------------------------------------------------------------"
    else
        log_message "Error: Decommission process failed"
        echo "Error: Decommission process encountered issues. Check the logs."
        exit 1
    fi
}

main
