#!/bin/bash

# Script to restart applications that need cursor theme updates
# Some applications don't pick up cursor theme changes until restarted

echo "🖱️  Restarting applications for cursor theme updates..."

# Function to restart an application if it's running
restart_if_running() {
    local app_name="$1"
    local start_command="$2"
    
    if pgrep -x "$app_name" > /dev/null; then
        echo "  • Restarting $app_name..."
        pkill "$app_name"
        sleep 1
        if [[ -n "$start_command" ]]; then
            eval "$start_command > /dev/null 2>&1 &"
        fi
    fi
}

# Restart file managers
restart_if_running "nemo" "nemo"
restart_if_running "nautilus" "nautilus"
restart_if_running "thunar" "thunar"

# Restart text editors (if they're GUI versions)
restart_if_running "code" "code"
restart_if_running "cursor" "cursor"
restart_if_running "gedit" "gedit"

# Restart other GUI applications that might be affected
restart_if_running "discord" "discord"
restart_if_running "spotify" "spotify"

echo "✅ Application restart completed!"
echo ""
echo "📝 Note: Some applications may still need manual restart:"
echo "   • Browsers (Brave, Firefox, Chrome)"
echo "   • IDEs (IntelliJ, VS Code if not restarted)"
echo "   • Electron apps"
echo ""
echo "💡 For immediate cursor changes in browsers, restart them manually or:"
echo "   pkill brave && brave > /dev/null 2>&1 &" 