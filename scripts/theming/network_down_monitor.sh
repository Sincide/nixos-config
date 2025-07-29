#!/usr/bin/env bash

# Network Download Speed Monitor
# Shows current download speed with dynamic indicators

cache_file="/tmp/network_down_cache"
interface=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$interface" ]; then
    echo "❌ N/A"
    exit 0
fi

# Get current bytes received
current_rx=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null)

if [ -z "$current_rx" ]; then
    echo "❌ N/A"
    exit 0
fi

current_time=$(date +%s)

# Calculate speed if we have previous data
if [ -f "$cache_file" ]; then
    prev_data=$(cat "$cache_file")
    prev_rx=$(echo "$prev_data" | cut -d: -f1)
    prev_time=$(echo "$prev_data" | cut -d: -f2)
    
    time_diff=$((current_time - prev_time))
    
    if [ "$time_diff" -gt 0 ]; then
        bytes_diff=$((current_rx - prev_rx))
        if [ "$bytes_diff" -ge 0 ]; then
            speed_bps=$((bytes_diff / time_diff))
            
            # Format speed with appropriate unit and icon
            if [ "$speed_bps" -gt 10485760 ]; then  # > 10 MB/s
                speed_mbps=$(echo "scale=1; $speed_bps / 1048576" | bc 2>/dev/null || awk "BEGIN {printf \"%.1f\", $speed_bps/1048576}")
                echo "🚀 ${speed_mbps}MB/s"
            elif [ "$speed_bps" -gt 1048576 ]; then  # > 1 MB/s
                speed_mbps=$(echo "scale=1; $speed_bps / 1048576" | bc 2>/dev/null || awk "BEGIN {printf \"%.1f\", $speed_bps/1048576}")
                echo "⚡ ${speed_mbps}MB/s"
            elif [ "$speed_bps" -gt 1024 ]; then  # > 1 KB/s
                speed_kbps=$((speed_bps / 1024))
                echo "📥 ${speed_kbps}KB/s"
            else
                echo "💤 ${speed_bps}B/s"
            fi
        else
            echo "📥 0B/s"
        fi
    else
        echo "📥 0B/s"
    fi
else
    echo "📥 0B/s"
fi

# Cache current values
echo "$current_rx:$current_time" > "$cache_file"