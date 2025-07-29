#!/usr/bin/env bash

echo "🎨 Testing waybar color generation..."

# Check if template exists
if [[ ! -f "templates/waybar.css" ]]; then
    echo "❌ waybar.css template not found in templates/"
    exit 1
fi

# Test with a sample wallpaper (if exists)
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

# Generate colors
echo "🔄 Generating waybar colors..."
matugen image "$WALLPAPER" --variant dark --json-format hex -t templates/waybar.css > dotfiles/waybar/colors.css

# Check if colors.css was generated
if [[ -f "dotfiles/waybar/colors.css" ]]; then
    echo "✅ waybar colors.css generated successfully"
    echo "📄 First few lines:"
    head -10 dotfiles/waybar/colors.css
else
    echo "❌ Failed to generate waybar colors.css"
    exit 1
fi

echo "🎯 Test complete!"