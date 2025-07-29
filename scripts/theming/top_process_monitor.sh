#!/usr/bin/env bash

# Top Process Monitor - Shows highest CPU consuming process
# Dynamic icons based on CPU usage

top_process=$(ps -eo pid,pcpu,comm --sort=-pcpu --no-headers | head -1)

if [ -z "$top_process" ]; then
    echo "❌ N/A"
    exit 0
fi

cpu_usage=$(echo "$top_process" | awk '{print $2}')
process_name=$(echo "$top_process" | awk '{print $3}')

# Convert to integer for comparison
cpu_int=$(printf "%.0f" "$cpu_usage")

# Truncate process name if too long
if [ ${#process_name} -gt 12 ]; then
    process_name="${process_name:0:9}..."
fi

# Calculate core usage for clearer display
cores_used=$(echo "scale=1; $cpu_usage / 100" | bc 2>/dev/null)
if [ -z "$cores_used" ]; then
    cores_used=$(awk "BEGIN {printf \"%.1f\", $cpu_usage/100}")
fi

# Output with dynamic icon based on CPU usage
if [ "$cpu_int" -ge 80 ]; then
    echo "🔥 ${process_name} ${cores_used}c"  # Critical CPU hog
elif [ "$cpu_int" -ge 50 ]; then
    echo "⚡ ${process_name} ${cores_used}c"  # High CPU usage
elif [ "$cpu_int" -ge 20 ]; then
    echo "💻 ${process_name} ${cores_used}c"  # Moderate usage
elif [ "$cpu_int" -ge 5 ]; then
    echo "🧠 ${process_name} ${cores_used}c"  # Light usage
else
    echo "💤 ${process_name} ${cores_used}c"  # Minimal usage
fi