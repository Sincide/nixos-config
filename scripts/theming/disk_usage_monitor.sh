#!/usr/bin/env bash

# Disk Usage Monitor for Specific Mount Points
# Usage: disk_usage_monitor.sh /path/to/mount

mount_point="${1:-/}"

if [ ! -d "$mount_point" ]; then
    echo "❌ N/A"
    exit 0
fi

# Get disk usage information
disk_info=$(df -h "$mount_point" 2>/dev/null | tail -1)

if [ -z "$disk_info" ]; then
    echo "❌ N/A"
    exit 0
fi

# Extract usage percentage (remove % symbol)
usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
used_space=$(echo "$disk_info" | awk '{print $3}')
total_space=$(echo "$disk_info" | awk '{print $2}')

# Output with dynamic icon based on usage percentage
if [ "$usage_percent" -ge 95 ]; then
    echo "💀 ${used_space}/${total_space} (${usage_percent}%)"  # Critical
elif [ "$usage_percent" -ge 85 ]; then
    echo "🔥 ${used_space}/${total_space} (${usage_percent}%)"  # Warning
elif [ "$usage_percent" -ge 70 ]; then
    echo "📊 ${used_space}/${total_space} (${usage_percent}%)"  # Medium
else
    echo "💿 ${used_space}/${total_space} (${usage_percent}%)"  # Good
fi