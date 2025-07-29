#!/usr/bin/env bash

# AMDGPU Sensor Test Script
# Tests all the sensor commands used in the bottom Waybar

echo "🚀 Testing AMDGPU sensors for bottom Waybar..."
echo ""

# GPU Temperature
echo "🌡️ GPU Temperature:"
temp_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
if [ -n "$temp_raw" ]; then
    temp_c=$((temp_raw/1000))
    echo "   Raw: ${temp_raw} milli°C"
    echo "   Formatted: ${temp_c}°C"
else
    echo "   ❌ Failed to read temperature"
fi
echo ""

# Fan Speed PWM
echo "🌪️ Fan Speed (PWM):"
pwm_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/pwm1 2>/dev/null | head -1)
if [ -n "$pwm_raw" ]; then
    pwm_percent=$(((pwm_raw * 100) / 255))
    echo "   Raw PWM: ${pwm_raw}/255"
    echo "   Formatted: ${pwm_percent}%"
else
    echo "   ❌ Failed to read PWM"
fi
echo ""

# Fan Speed RPM
echo "🌪️ Fan Speed (RPM):"
fan_rpm=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
if [ -n "$fan_rpm" ]; then
    echo "   RPM: ${fan_rpm}"
else
    echo "   ❌ Failed to read fan RPM"
fi
echo ""

# Power Draw
echo "⚡ Power Draw:"
power_raw=$(cat /sys/class/drm/card1/device/hwmon/hwmon*/power1_average 2>/dev/null | head -1)
if [ -n "$power_raw" ]; then
    power_w=$((power_raw/1000000))
    echo "   Raw: ${power_raw} micro-watts"
    echo "   Formatted: ${power_w}W"
else
    echo "   ❌ Failed to read power draw"
fi
echo ""

# GPU Usage (try multiple methods)
echo "⚡ GPU Usage:"
usage_sysfs=$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null)
if [ -n "$usage_sysfs" ]; then
    echo "   sysfs: ${usage_sysfs}%"
else
    echo "   ⚠️ sysfs gpu_busy_percent not available"
    if command -v radeontop >/dev/null 2>&1; then
        echo "   Testing radeontop fallback..."
        usage_radeon=$(timeout 3s radeontop -d - -l 1 2>/dev/null | grep -o 'gpu [0-9]*' | awk '{print $2}')
        if [ -n "$usage_radeon" ]; then
            echo "   radeontop: ${usage_radeon}%"
        else
            echo "   ⚠️ radeontop also failed"
        fi
    else
        echo "   ⚠️ radeontop not installed"
    fi
fi
echo ""

# VRAM Usage
echo "🧠 VRAM Usage:"
vram_used=$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null)
if [ -n "$vram_used" ]; then
    vram_gb=$(echo "$vram_used" | awk '{printf "%.1f", $1/1024/1024/1024}')
    echo "   Raw: ${vram_used} bytes"
    echo "   Formatted: ${vram_gb}G"
else
    echo "   ❌ Failed to read VRAM usage"
fi
echo ""

echo "✨ Sensor test complete!"
echo ""
echo "📊 Current readings for bottom bar:"
echo "   🌡️ GPU: ${temp_c:-N/A}°C"
echo "   🌪️ Fan: ${pwm_percent:-N/A}%"
echo "   ⚡ GPU: ${usage_sysfs:-${usage_radeon:-N/A}}%"
echo "   🧠 VRAM: ${vram_gb:-N/A}G"
echo "   ⚡ Power: ${power_w:-N/A}W" 