#!/usr/bin/env bash

# Process Count Monitor - Shows running/sleeping/zombie process counts
# Provides overview of system process health

# Get process states from /proc/stat or ps
running=$(ps -eo state --no-headers | grep -c R)
sleeping=$(ps -eo state --no-headers | grep -c S)
zombie=$(ps -eo state --no-headers | grep -c Z)
total=$(ps --no-headers | wc -l)

# Output with dynamic icon based on total process count
if [ "$total" -gt 500 ]; then
    echo "🔥 R:$running S:$sleeping Z:$zombie"  # High process count
elif [ "$total" -gt 300 ]; then
    echo "⚡ R:$running S:$sleeping Z:$zombie"  # Moderate process count
elif [ "$total" -gt 150 ]; then
    echo "💻 R:$running S:$sleeping Z:$zombie"  # Normal process count
else
    echo "💤 R:$running S:$sleeping Z:$zombie"  # Low process count
fi