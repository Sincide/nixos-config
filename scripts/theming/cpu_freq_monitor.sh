#!/usr/bin/env bash

# CPU Frequency Monitor with Turbo Detection
# Shows current frequency and turbo status

if [ -f /proc/cpuinfo ]; then
    # Get current frequency from cpuinfo (more reliable than scaling_cur_freq on some systems)
    current_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}' | cut -d. -f1)
    
    if [ -z "$current_freq" ]; then
        # Fallback to scaling frequency if cpuinfo doesn't have it
        current_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
        if [ -n "$current_freq" ]; then
            current_freq=$((current_freq / 1000))
        fi
    fi
    
    # Get base frequency for turbo detection
    base_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency 2>/dev/null)
    if [ -n "$base_freq" ]; then
        base_freq=$((base_freq / 1000))
    else
        base_freq=3000  # Default assumption
    fi
    
    if [ -n "$current_freq" ]; then
        # Format frequency in GHz with dynamic icon
        freq_ghz=$(echo "scale=1; $current_freq / 1000" | bc 2>/dev/null)
        if [ -z "$freq_ghz" ]; then
            freq_ghz=$(awk "BEGIN {printf \"%.1f\", $current_freq/1000}")
        fi
        
        # Check if in turbo mode
        if [ "$current_freq" -gt "$base_freq" ]; then
            echo "🚀 ${freq_ghz}GHz"  # Turbo mode
        elif [ "$current_freq" -gt $((base_freq - 200)) ]; then
            echo "⚡ ${freq_ghz}GHz"  # High frequency
        else
            echo "🐌 ${freq_ghz}GHz"  # Lower frequency
        fi
    else
        echo "❓ N/A"
    fi
else
    echo "❌ N/A"
fi