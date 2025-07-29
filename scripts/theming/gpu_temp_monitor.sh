#!/usr/bin/env bash

# GPU Temperature Monitor with Dynamic Visual Indicators
# Changes icon and color based on temperature ranges

temp_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)

if [ -z "$temp_raw" ]; then
    echo "N/A"
    exit 0
fi

temp_c=$((temp_raw/1000))

# Output temperature with dynamic icon based on range
if [ "$temp_c" -ge 100 ]; then
    echo "💀 $temp_c"  # Critical - skull (100°C+)
elif [ "$temp_c" -ge 85 ]; then
    echo "🔥 $temp_c"  # Warning - fire (85-99°C)
elif [ "$temp_c" -ge 70 ]; then
    echo "🌡️ $temp_c"  # Medium - thermometer (70-84°C)
else
    echo "❄️ $temp_c"   # Cool - snowflake (<70°C)
fi 