#!/usr/bin/env bash

# Directory containing wallpapers
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WALLPAPER_DIR="$DOTFILES_DIR/assets/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Function to verify GTK configuration (symlinks should exist from dotfiles)
verify_gtk_config() {
    echo "🔧 Verifying GTK configuration..."
    
    local gtk_configs=(
        "$HOME/.config/gtk-3.0/gtk.css"
        "$HOME/.config/gtk-3.0/settings.ini"
        "$HOME/.config/gtk-4.0/gtk.css"
        "$HOME/.config/gtk-4.0/settings.ini"
    )
    
    local missing_configs=()
    for config in "${gtk_configs[@]}"; do
        if [[ ! -f "$config" ]]; then
            missing_configs+=("$config")
        fi
    done
    
    if [[ ${#missing_configs[@]} -gt 0 ]]; then
        echo "  ⚠️  Missing GTK configurations:"
        for config in "${missing_configs[@]}"; do
            echo "     - $config"
        done
        echo "  💡 Run the dotfiles installer to set up symlinks properly"
        return 1
    else
        echo "  ✓ All GTK configurations found"
        return 0
    fi
}



# Function to apply wallpaper and generate colors
apply_wallpaper() {
    local wallpaper="$1"
    
    # GTK configuration should be symlinked from dotfiles by installer
    
    # Save the wallpaper path to cache for persistence
    echo "$wallpaper" > "$CACHE_DIR/current_wallpaper"
    
    # Set the wallpaper using swww
    swww img "$wallpaper" --transition-fps 60 --transition-type grow --transition-pos center
    
    # Apply dynamic theme based on wallpaper category
    echo "🎨 Applying dynamic theme based on wallpaper category..."
    if [[ -f "$DOTFILES_DIR/scripts/theming/dynamic_theme_switcher.sh" ]]; then
        bash "$DOTFILES_DIR/scripts/theming/dynamic_theme_switcher.sh" apply "$wallpaper"
    else
        echo "⚠️  Dynamic theme switcher not found, using matugen fallback..."
        # Generate material colors using matugen with config from dotfiles
        # Correct syntax: matugen image [OPTIONS] <IMAGE>
        matugen image --config "$DOTFILES_DIR/config/themes/matugen/config.toml" "$wallpaper"
    fi
    
    # Restart applications to apply new colors
    # The following block has been moved to scripts/theming/reload_apps.sh
    # to centralize application reloading logic for both Hyprland and Niri.
    #
    # echo "🔄 Reloading applications with new theme..."
    # 
    # # Check if we're running under Wayland/Hyprland
    # if [[ "$WAYLAND_DISPLAY" ]] && pgrep -x Hyprland > /dev/null; then
    #     echo "  • Reloading Hyprland configuration..."
    #     hyprctl reload
    #     
    #     # Restart Waybar (dual bars: top + bottom)
    #     if pgrep -x waybar > /dev/null; then
    #         echo "  • Restarting Waybar instances..."
    #         pkill waybar
    #         sleep 0.5
    #     fi
    #     echo "  • Starting top Waybar..."
    #     waybar > /dev/null 2>&1 &
    #     echo "  • Starting bottom Waybar (AMDGPU monitoring)..."
    #     waybar -c ~/.config/waybar/config-bottom -s ~/.config/waybar/style-bottom.css > /dev/null 2>&1 &
    #     
    #     # Restart Dunst
    #     if pgrep -x dunst > /dev/null; then
    #         echo "  • Restarting Dunst..."
    #         pkill dunst
    #         sleep 0.5
    #     fi
    #     echo "  • Starting Dunst..."
    #     dunst > /dev/null 2>&1 &
    #     
    #     # Reload Kitty configurations
    #     echo "  • Reloading Kitty configurations..."
    #     killall -USR1 kitty 2>/dev/null || echo "    (No kitty instances to reload)"
    #     
    #     # Refresh GTK applications (this will make them pick up the new colors)
    #     echo "  • Refreshing GTK theme cache..."
    #     # Update GTK icon cache
    #     if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    #         gtk-update-icon-cache -f "$HOME/.icons/Papirus-Dark" 2>/dev/null || true
    #     fi
    #     
    #     # Signal GTK applications to reload themes
    #     # This works for some apps that watch for theme changes
    #     if command -v gsettings >/dev/null 2>&1; then
    #         # Toggle the theme setting to force reload
    #         current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "'Adwaita-dark'")
    #         gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
    #         sleep 0.1
    #         gsettings set org.gnome.desktop.interface gtk-theme "${current_theme//\'}" 2>/dev/null || true
    #         echo "    ✓ GTK theme refreshed"
    #     fi
    #     
    #     # Restart applications that need cursor theme updates
    #     echo "  • Restarting applications for cursor theme updates..."
    #     
    #     # Restart Nemo file manager if running (GTK3 limitation - colors don't reload live)
    #     if pgrep -x nemo > /dev/null; then
    #         echo "    - Restarting Nemo file manager for theme update..."
    #         pkill nemo
    #         sleep 0.5
    #         nemo > /dev/null 2>&1 &
    #     fi
    #     
    #     # Note about browser cursor themes
    #     echo "    ℹ️  Browsers (Brave, Firefox) may need manual restart for cursor changes"
    #     
    # else
    #     echo "  ⚠️  Not running under Hyprland - applications won't be restarted"
    #     echo "     Start Hyprland session and run 'wallpaper_manager.sh restore' to apply theme"
    # fi
    # 
    # echo ""
    # echo "✨ Theme applied successfully!"
    # echo "   🎨 Wallpaper: $(basename "$wallpaper")"
    # echo "   🌈 Material You colors generated for:"
    # echo "      • Hyprland window manager"
    # echo "      • Waybar dual bars (top + bottom with AMDGPU)"
    # echo "      • Kitty terminal"
    # echo "      • Dunst notifications"
    # echo "      • Fuzzel launcher"
    # echo "      • GTK3/GTK4 applications"
    # echo ""
    # echo "   💡 Some GTK applications may need to be restarted to see the new theme"

    # Call the centralized application reloader script
    bash "$DOTFILES_DIR/scripts/theming/reload_apps.sh"
}

# Function to restore wallpaper from cache
restore_wallpaper() {
    if [[ -f "$CACHE_DIR/current_wallpaper" ]]; then
        local wallpaper=$(cat "$CACHE_DIR/current_wallpaper")
        if [[ -f "$wallpaper" ]]; then
            echo "🔄 Restoring previous wallpaper..."
            apply_wallpaper "$wallpaper"
        else
            echo "❌ Cached wallpaper not found: $wallpaper"
            echo "Please select a new wallpaper manually"
        fi
    else
        echo "❌ No cached wallpaper found"
        echo "Please select a wallpaper manually"
    fi
}

# Function to list available wallpapers
list_wallpapers() {
    echo "📁 Available wallpapers in $WALLPAPER_DIR:"
    echo ""
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort | while read -r wallpaper; do
        local relative_path=${wallpaper#$WALLPAPER_DIR/}
        echo "  🖼️  $relative_path"
    done
}

# Function to select wallpaper interactively
select_wallpaper() {
    # Check for fuzzel first (preferred for Wayland), then fallback to fzf
    if command -v fuzzel >/dev/null 2>&1; then
        # First, let user select category using fuzzel
        local categories=$(find "$WALLPAPER_DIR" -mindepth 1 -type d -printf "%f\n" | sort)
        local category=$(echo "$categories" | fuzzel --dmenu --prompt="Select category: ")
        
        if [[ -z "$category" ]]; then
            echo "❌ No category selected"
            return 1
        fi
        
        # Then, let user select wallpaper from category using fuzzel
        local wallpapers=$(find "$WALLPAPER_DIR/$category" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -printf "%f\n")
        local wallpaper=$(echo "$wallpapers" | fuzzel --dmenu --prompt="Select wallpaper from $category: ")
        
        if [[ -n "$wallpaper" ]]; then
            apply_wallpaper "$WALLPAPER_DIR/$category/$wallpaper"
        else
            echo "❌ No wallpaper selected"
        fi
        
    elif command -v fzf >/dev/null 2>&1; then
        # Fallback to fzf if fuzzel not available
        echo "🔄 Using fzf fallback (fuzzel not found)"
        local selected_wallpaper
        selected_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort | fzf --preview 'echo "Preview: {}" && file {}' --height 40% --border --prompt "Select wallpaper: ")
        
        if [[ -n "$selected_wallpaper" ]]; then
            apply_wallpaper "$selected_wallpaper"
        else
            echo "❌ No wallpaper selected"
        fi
        
    else
        echo "❌ Neither fuzzel nor fzf found. Please install one for interactive wallpaper selection"
        echo "Available wallpapers:"
        list_wallpapers
        return 1
    fi
}

# Main script logic
case "${1:-}" in
    "list")
        list_wallpapers
        ;;
    "select")
        select_wallpaper
        ;;
    "restore")
        restore_wallpaper
        ;;
    "verify")
        verify_gtk_config
        echo "✅ GTK configuration verification completed!"
        ;;
    *)
        if [[ -n "$1" && -f "$1" ]]; then
            # Direct wallpaper file provided
            apply_wallpaper "$1"
        else
            echo "🌈 Wallpaper Manager - Material Design 3 Theming"
            echo ""
            echo "Usage: $0 [COMMAND|WALLPAPER_FILE]"
            echo ""
            echo "Commands:"
            echo "  list     - List all available wallpapers"
            echo "  select   - Interactively select a wallpaper (requires fzf)"
            echo "  restore  - Restore the last used wallpaper"
            echo "  verify   - Verify GTK configuration files exist"
            echo ""
            echo "  Or provide a direct path to a wallpaper file"
            echo ""
            echo "Examples:"
            echo "  $0 select"
            echo "  $0 ~/Pictures/wallpaper.jpg"
            echo "  $0 restore"
        fi
        ;;
esac