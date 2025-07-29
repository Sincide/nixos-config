#!/usr/bin/env bash

# AMDGPU Monitoring Check Script
# Verifies that all required monitoring tools are available

echo "🔍 Checking AMDGPU monitoring capabilities..."
echo ""

# Check for AMD GPU
if ! lspci | grep -i amd > /dev/null; then
    echo "❌ No AMD GPU detected"
    echo "   This bottom bar is designed for AMDGPU monitoring"
    exit 1
fi

echo "✅ AMD GPU detected:"
lspci | grep -i amd | head -1
echo ""

# Check for hwmon interface
if [ ! -d "/sys/class/drm/card1/device/hwmon" ]; then
    echo "⚠️  hwmon interface not found at /sys/class/drm/card1/device/hwmon"
    echo "   GPU temperature/fan monitoring may not work"
else
    echo "✅ hwmon interface found"
    hwmon_path=$(find /sys/class/drm/card1/device/hwmon -name "hwmon*" | head -1)
    if [ -n "$hwmon_path" ]; then
        echo "   📍 Location: $hwmon_path"
        
        # Check specific sensors
        if [ -f "$hwmon_path/temp1_input" ]; then
            temp=$(cat "$hwmon_path/temp1_input")
            echo "   🌡️  Temperature: $((temp/1000))°C"
        fi
        
        if [ -f "$hwmon_path/pwm1" ]; then
            fan_raw=$(cat "$hwmon_path/pwm1")
            fan_percent=$(((fan_raw * 100) / 255))
            echo "   🌪️  Fan speed: ${fan_percent}%"
        fi
    fi
fi
echo ""

# Check for radeontop (GPU usage monitoring)
if command -v radeontop >/dev/null 2>&1; then
    echo "✅ radeontop found (GPU usage monitoring)"
else
    echo "⚠️  radeontop not found"
    echo "   Install with: sudo pacman -S radeontop"
    echo "   Fallback: will try /sys/class/drm/card1/device/gpu_busy_percent"
fi

# Check for checkupdates (package updates)
if command -v checkupdates >/dev/null 2>&1; then
    echo "✅ checkupdates found (package monitoring)"
    update_count=$(checkupdates 2>/dev/null | wc -l)
    echo "   📦 Current updates available: $update_count"
else
    echo "⚠️  checkupdates not found"
    echo "   Install with: sudo pacman -S pacman-contrib"
fi

echo ""
echo "🚀 Bottom bar monitoring features:"
echo "   • AMDGPU temperature, fan speed, usage, VRAM"
echo "   • CPU temperature and usage"
echo "   • Memory and disk usage"
echo "   • System load and uptime"
echo "   • Package updates counter"
echo "   • All with evil space theme + dynamic colors"

echo ""
echo "📋 To install missing tools:"
echo "   sudo pacman -S radeontop pacman-contrib" 