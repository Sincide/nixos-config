#!/usr/bin/env bash

# This script reloads applications to apply new themes.
# It checks for the running window manager and executes the appropriate commands.

echo "🔄 Reloading applications with new theme..."

# Check for running window manager
if pgrep -x "Hyprland" > /dev/null; then
    echo "  • Reloading Hyprland configuration..."
    hyprctl reload

elif pgrep -x "niri" > /dev/null; then
    # Niri automatically reloads its configuration when the file changes.
    echo "  • Niri configuration reloaded automatically."

else
    echo "  ⚠️  Neither Hyprland nor Niri are running. Skipping WM reload."
fi

# Restart Waybar (dual bars: top + bottom)
if pgrep -x waybar > /dev/null; then
    echo "  • Killing all Waybar instances..."
    pkill -9 waybar
    sleep 1
fi

# Wait to ensure all waybar processes are fully terminated
while pgrep -x waybar > /dev/null; do
    echo "  • Waiting for waybar to terminate..."
    sleep 0.5
done

echo "  • Starting top Waybar..."
waybar -c ~/nixos-config/dotfiles/waybar/config -s ~/nixos-config/dotfiles/waybar/style.css > /dev/null 2>&1 &

echo "  • Starting bottom Waybar (system monitoring)..."
waybar -c ~/nixos-config/dotfiles/waybar/config-bottom -s ~/nixos-config/dotfiles/waybar/style-bottom.css > /dev/null 2>&1 &

# Restart Dunst
if pgrep -x dunst > /dev/null; then
    echo "  • Restarting Dunst..."
    pkill dunst
    sleep 0.5
fi
echo "  • Starting Dunst..."
dunst > /dev/null 2>&1 &

# Reload Kitty configurations
echo "  • Reloading Kitty configurations..."
killall -USR1 kitty 2>/dev/null || echo "    (No kitty instances to reload)"

# Refresh GTK applications (this will make them pick up the new colors)
echo "  • Refreshing GTK theme cache..."
# Update GTK icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f "$HOME/.icons/Papirus-Dark" 2>/dev/null || true
fi

# Signal GTK applications to reload themes
# This works for some apps that watch for theme changes
if command -v gsettings >/dev/null 2>&1; then
    # Toggle the theme setting to force reload
    current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "'Adwaita-dark'")
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
    sleep 0.1
    gsettings set org.gnome.desktop.interface gtk-theme "${current_theme//\'}" 2>/dev/null || true
    echo "    ✓ GTK theme refreshed"
fi

# Restart applications that need cursor theme updates
echo "  • Restarting applications for cursor theme updates..."

# Restart Nemo file manager if running (GTK3 limitation - colors don't reload live)
if pgrep -x nemo > /dev/null; then
    echo "    - Restarting Nemo file manager for theme update..."
    pkill nemo
    sleep 0.5
    nemo > /dev/null 2>&1 &
fi

# Note about browser cursor themes
echo "    ℹ️  Browsers (Brave, Firefox) may need manual restart for cursor changes"

echo ""
echo "✨ Theme applied successfully!"
echo "   🌈 Material You colors generated for:"
echo "      • Hyprland or Niri window manager"
echo "      • Waybar dual bars (top + bottom with monitoring)"
echo "      • Kitty terminal"
echo "      • Dunst notifications"
echo "      • Fuzzel launcher"
echo "      • GTK3/GTK4 applications"
echo ""
echo "   💡 Some GTK applications may need to be restarted to see the new theme"