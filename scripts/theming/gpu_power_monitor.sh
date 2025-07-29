#!/usr/bin/env bash

# GPU Power Monitor with Dynamic Visual Indicators
# Changes icon based on power consumption ranges

power_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/power1_average 2>/dev/null | head -1)

if [ -z "$power_raw" ]; then
    echo "N/A"
    exit 0
fi

# Convert to watts
power_w=$((power_raw/1000000))

# Output power with dynamic icon based on consumption range
if [ "$power_w" -ge 300 ]; then
    echo "💥 $power_w"  # Very high - explosion
elif [ "$power_w" -ge 200 ]; then
    echo "🔥 $power_w"  # High - fire
elif [ "$power_w" -ge 100 ]; then
    echo "⚡ $power_w"  # Medium - lightning
else
    echo "🔋 $power_w"  # Low - battery
fi 