#!/usr/bin/env bash

echo "🎨 Testing all component theming..."

# Check if all templates exist
TEMPLATES=(
    "waybar.css"
    "kitty.conf" 
    "dunst.conf"
    "hyprland.conf"
    "rofi.rasi"
)

echo "📋 Checking templates..."
for template in "${TEMPLATES[@]}"; do
    if [[ -f "templates/$template" ]]; then
        echo "  ✅ templates/$template"
    else
        echo "  ❌ templates/$template MISSING"
    fi
done

# Test with a sample wallpaper
WALLPAPER=""
if [[ -d "$HOME/Pictures/Wallpapers" ]]; then
    WALLPAPER=$(find "$HOME/Pictures/Wallpapers" -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -1)
fi

if [[ -z "$WALLPAPER" ]]; then
    echo "❌ No wallpaper found for testing"
    echo "Please add a wallpaper to ~/Pictures/Wallpapers/"
    exit 1
fi

echo "📸 Using test wallpaper: $(basename "$WALLPAPER")"

# Generate all color files
echo "🔄 Generating colors for all components..."

COMPONENTS=(
    "waybar.css:dotfiles/waybar/colors.css"
    "kitty.conf:dotfiles/kitty/colors.conf" 
    "dunst.conf:dotfiles/dunst/colors.conf"
    "hyprland.conf:dotfiles/hypr/colors.conf"
    "rofi.rasi:dotfiles/rofi/colors.rasi"
)

for component in "${COMPONENTS[@]}"; do
    template="${component%:*}"
    output="${component#*:}"
    
    if [[ -f "templates/$template" ]]; then
        echo "  • Generating $output..."
        matugen image "$WALLPAPER" --variant dark --json-format hex -t "templates/$template" > "$output"
        
        if [[ -f "$output" ]]; then
            echo "    ✅ $output generated ($(wc -l < "$output") lines)"
        else
            echo "    ❌ $output FAILED"
        fi
    fi
done

echo ""
echo "🎯 Theming test complete!"
echo "📁 Generated color files:"
find dotfiles -name "colors.*" -type f | sort