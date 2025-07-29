#!/usr/bin/env bash

# GPU VRAM Monitor with Dynamic Visual Indicators
# Changes icon based on VRAM usage ranges

vram_used=$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null)

if [ -z "$vram_used" ]; then
    echo "N/A"
    exit 0
fi

# Convert to GB and get integer part for comparison
vram_gb_raw=$(echo "$vram_used" | awk '{printf "%.1f", $1/1024/1024/1024}')
vram_gb_int=$(echo "$vram_gb_raw" | cut -d'.' -f1)

# Output VRAM with dynamic icon based on usage range
if [ "$vram_gb_int" -ge 20 ]; then
    echo "💀 ${vram_gb_raw}G"  # Very high - skull
elif [ "$vram_gb_int" -ge 15 ]; then
    echo "⚠️ ${vram_gb_raw}G"  # High - warning
elif [ "$vram_gb_int" -ge 8 ]; then
    echo "📊 ${vram_gb_raw}G"  # Medium - chart
else
    echo "💾 ${vram_gb_raw}G"  # Low - disk
fi 