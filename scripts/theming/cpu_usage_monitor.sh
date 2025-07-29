#!/usr/bin/env bash

# CPU Usage Monitor with Dynamic Visual Indicators
# Shows overall CPU utilization with dynamic icons

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
cpu_int=$(printf "%.0f" "$cpu_usage")

# Output CPU usage with dynamic icon based on utilization
if [ "$cpu_int" -ge 90 ]; then
    echo "🔥 $cpu_int"  # Critical - fire (90%+)
elif [ "$cpu_int" -ge 70 ]; then
    echo "⚡ $cpu_int"  # High - lightning (70-89%)
elif [ "$cpu_int" -ge 50 ]; then
    echo "🧠 $cpu_int"  # Medium - brain (50-69%)
elif [ "$cpu_int" -ge 30 ]; then
    echo "💻 $cpu_int"  # Active - computer (30-49%)
else
    echo "💤 $cpu_int"  # Idle - sleeping (<30%)
fi