#!/usr/bin/env fish

# Simple test script to verify waybar execution
echo "Test script executed at $(date)" >> /tmp/waybar-test.log
dunstify -t 3000 "Test" "Waybar script execution works!" -i "dialog-information" 