#!/usr/bin/env fish

# Claude Status Script for Waybar
# Calls the Python Claude monitor and formats output for waybar

set -l script_path ~/nixos-config/scripts/ai/claude_waybar.py

# Check if the Python script exists
if not test -f "$script_path"
    echo "❌ Claude: NO SCRIPT"
    exit 0
end

# Run the Python script and capture output
set -l output (python3 "$script_path" 2>/dev/null)
set -l exit_code $status

# Handle different exit codes
switch $exit_code
    case 0
        # Success - output the result
        echo "$output"
    case 1
        # No active session
        echo "🤖 Claude: IDLE"
    case 2
        # API/connection error
        echo "❌ Claude: OFFLINE"
    case '*'
        # Unknown error
        echo "⚠️ Claude: ERROR"
end 