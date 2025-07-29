#!/usr/bin/env bash

# Detailed Uptime Monitor
# Shows uptime with load average and boot time

uptime_info=$(uptime)
uptime_clean=$(echo "$uptime_info" | sed 's/up //' | sed 's/ hours/h/' | sed 's/ hour/h/' | sed 's/ minutes/m/' | sed 's/ minute/m/' | sed 's/ days/d/' | sed 's/ day/d/' | awk -F',' '{print $1}' | xargs)

# Get load average
load_1min=$(echo "$uptime_info" | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')

# Get boot time
boot_time=$(who -b 2>/dev/null | awk '{print $3, $4}' || date -d "$(awk '{print $1}' /proc/uptime) seconds ago" '+%Y-%m-%d %H:%M')

# Dynamic icon based on uptime duration
if [[ "$uptime_clean" =~ "day" ]]; then
    days=$(echo "$uptime_clean" | grep -o '[0-9]*' | head -1)
    if [ "$days" -gt 30 ]; then
        echo "👑 $uptime_clean"  # Over 30 days - legendary
    elif [ "$days" -gt 7 ]; then
        echo "💀 $uptime_clean"  # Over 7 days - evil persistence
    else
        echo "🌌 $uptime_clean"  # Few days - space endurance
    fi
elif [[ "$uptime_clean" =~ "h" ]]; then
    echo "⚡ $uptime_clean"  # Hours - active system
else
    echo "🆕 $uptime_clean"  # Minutes - fresh boot
fi