#!/usr/bin/env bash

# GPU Fan Speed Monitor with Dynamic Visual Indicators
# Changes icon based on fan speed ranges

pwm_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/pwm1 2>/dev/null | head -1)

if [ -z "$pwm_raw" ]; then
    echo "N/A"
    exit 0
fi

fan_percent=$(((pwm_raw * 100) / 255))

# Output fan speed with dynamic icon based on range
if [ "$fan_percent" -ge 80 ]; then
    echo "🌪️ $fan_percent"  # High speed - tornado
elif [ "$fan_percent" -ge 50 ]; then
    echo "💨 $fan_percent"  # Medium speed - wind
elif [ "$fan_percent" -ge 20 ]; then
    echo "🌬️ $fan_percent"  # Low speed - breeze
else
    echo "😴 $fan_percent"  # Very low/idle - sleeping
fi 