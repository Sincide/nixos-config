#!/usr/bin/env bash

echo "🔄 Restarting Waybar instances..."

# Kill all waybar processes aggressively
echo "  • Terminating waybar processes..."
killall -9 waybar 2>/dev/null || true
pkill -9 waybar 2>/dev/null || true
sleep 2

# Ensure all are dead
while pgrep waybar >/dev/null; do
    echo "  • Force killing remaining waybar..."
    killall -9 waybar 2>/dev/null || true
    pkill -9 waybar 2>/dev/null || true
    sleep 1
done

echo "  • All waybar processes terminated"

# Start top waybar
echo "  • Starting top waybar..."
nohup waybar -c ~/nixos-config/dotfiles/waybar/config -s ~/nixos-config/dotfiles/waybar/style.css > /tmp/waybar-top.log 2>&1 &
TOP_PID=$!

# Start bottom waybar  
echo "  • Starting bottom waybar..."
nohup waybar -c ~/nixos-config/dotfiles/waybar/config-bottom -s ~/nixos-config/dotfiles/waybar/style-bottom.css > /tmp/waybar-bottom.log 2>&1 &
BOTTOM_PID=$!

sleep 2

# Check if both started successfully
if kill -0 $TOP_PID 2>/dev/null; then
    echo "  ✓ Top waybar started (PID: $TOP_PID)"
else
    echo "  ❌ Top waybar failed to start"
    echo "  Check logs: cat /tmp/waybar-top.log"
fi

if kill -0 $BOTTOM_PID 2>/dev/null; then
    echo "  ✓ Bottom waybar started (PID: $BOTTOM_PID)"
else
    echo "  ❌ Bottom waybar failed to start"
    echo "  Check logs: cat /tmp/waybar-bottom.log"
fi

echo "✨ Waybar restart complete!"