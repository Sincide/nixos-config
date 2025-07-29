#!/usr/bin/env bash

# GPU Usage Monitor with Dynamic Visual Indicators
# Changes icon based on GPU utilization ranges

usage=$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null)

if [ -z "$usage" ]; then
    # Fallback to radeontop if available
    if command -v radeontop >/dev/null 2>&1; then
        usage=$(timeout 2s radeontop -d - -l 1 2>/dev/null | grep -o 'gpu [0-9]*' | awk '{print $2}')
    fi
fi

if [ -z "$usage" ]; then
    echo "N/A"
    exit 0
fi

# Output usage with dynamic icon based on range
if [ "$usage" -ge 90 ]; then
    echo "🚀 $usage"  # Very high - rocket
elif [ "$usage" -ge 70 ]; then
    echo "⚡ $usage"  # High - lightning
elif [ "$usage" -ge 30 ]; then
    echo "🔋 $usage"  # Medium - battery
else
    echo "💤 $usage"  # Low - sleeping
fi 