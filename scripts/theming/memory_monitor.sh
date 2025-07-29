#!/usr/bin/env bash

# Memory Usage Monitor with Dynamic Visual Indicators
# Changes icon and color based on memory usage percentage

# Get memory information from /proc/meminfo
mem_info=$(cat /proc/meminfo)
mem_total=$(echo "$mem_info" | grep MemTotal | awk '{print $2}')
mem_available=$(echo "$mem_info" | grep MemAvailable | awk '{print $2}')

if [ -z "$mem_total" ] || [ -z "$mem_available" ]; then
    echo "N/A"
    exit 0
fi

# Calculate used memory and percentage
mem_used=$((mem_total - mem_available))
mem_percent=$((mem_used * 100 / mem_total))

# Format memory in GB with one decimal place
mem_used_gb=$(echo "scale=1; $mem_used / 1024 / 1024" | bc 2>/dev/null)
mem_total_gb=$(echo "scale=1; $mem_total / 1024 / 1024" | bc 2>/dev/null)

# Fallback to awk if bc is not available
if [ -z "$mem_used_gb" ]; then
    mem_used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used/1024/1024}")
    mem_total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total/1024/1024}")
fi

# Output memory with dynamic icon based on usage percentage
if [ "$mem_percent" -ge 90 ]; then
    echo "💀 ${mem_used_gb}/${mem_total_gb}GB (${mem_percent}%)"  # Critical - skull (90%+)
elif [ "$mem_percent" -ge 80 ]; then
    echo "🔥 ${mem_used_gb}/${mem_total_gb}GB (${mem_percent}%)"  # Warning - fire (80-89%)
elif [ "$mem_percent" -ge 60 ]; then
    echo "🧠 ${mem_used_gb}/${mem_total_gb}GB (${mem_percent}%)"  # Medium - brain (60-79%)
else
    echo "💾 ${mem_used_gb}/${mem_total_gb}GB (${mem_percent}%)"  # Good - disk (<60%)
fi