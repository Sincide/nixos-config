#!/usr/bin/env bash

# Disk I/O Monitor - Shows read/write activity
# Uses /proc/diskstats for real-time I/O monitoring

cache_file="/tmp/disk_io_cache"

# Get total disk I/O from all devices
current_read=0
current_write=0

# Sum up all disk devices (exclude loop, ram, etc.)
while read -r line; do
    # Skip non-physical devices
    device=$(echo "$line" | awk '{print $3}')
    if [[ "$device" =~ ^(loop|ram|sr|dm-) ]]; then
        continue
    fi
    
    # Sum read and write sectors (multiply by 512 to get bytes)
    read_sectors=$(echo "$line" | awk '{print $6}')
    write_sectors=$(echo "$line" | awk '{print $10}')
    
    current_read=$((current_read + read_sectors * 512))
    current_write=$((current_write + write_sectors * 512))
done < /proc/diskstats

current_time=$(date +%s)

# Calculate speed if we have previous data
if [ -f "$cache_file" ]; then
    prev_data=$(cat "$cache_file")
    prev_read=$(echo "$prev_data" | cut -d: -f1)
    prev_write=$(echo "$prev_data" | cut -d: -f2)
    prev_time=$(echo "$prev_data" | cut -d: -f3)
    
    time_diff=$((current_time - prev_time))
    
    if [ "$time_diff" -gt 0 ]; then
        read_diff=$((current_read - prev_read))
        write_diff=$((current_write - prev_write))
        
        if [ "$read_diff" -ge 0 ] && [ "$write_diff" -ge 0 ]; then
            read_mbps=$((read_diff / time_diff / 1048576))
            write_mbps=$((write_diff / time_diff / 1048576))
            
            # Format output based on activity level
            total_mbps=$((read_mbps + write_mbps))
            
            if [ "$total_mbps" -gt 50 ]; then
                echo "🔥 R:${read_mbps} W:${write_mbps}MB/s"
            elif [ "$total_mbps" -gt 10 ]; then
                echo "⚡ R:${read_mbps} W:${write_mbps}MB/s"
            elif [ "$total_mbps" -gt 1 ]; then
                echo "💿 R:${read_mbps} W:${write_mbps}MB/s"
            else
                echo "💤 R:${read_mbps} W:${write_mbps}MB/s"
            fi
        else
            echo "💿 I/O: 0MB/s"
        fi
    else
        echo "💿 I/O: 0MB/s"
    fi
else
    echo "💿 I/O: Calculating..."
fi

# Cache current values
echo "$current_read:$current_write:$current_time" > "$cache_file"