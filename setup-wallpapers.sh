#!/usr/bin/env bash

# Wallpaper setup script for testing matugen dynamic theming
# Downloads sample wallpapers and creates the required directory structure

set -e

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

echo "🖼️  Setting up wallpapers for matugen testing..."

# Create wallpaper directory
mkdir -p "$WALLPAPER_DIR"
echo "✅ Created directory: $WALLPAPER_DIR"

# Download test wallpapers from Unsplash (high quality, free to use)
echo "📥 Downloading test wallpapers..."

# Wallpaper 1: Mountain landscape (blue/teal dominant)
if [[ ! -f "$WALLPAPER_DIR/mountain-lake.jpg" ]]; then
    curl -L "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1920&h=1080&fit=crop&crop=center" \
         -o "$WALLPAPER_DIR/mountain-lake.jpg" \
         --progress-bar
    echo "✅ Downloaded: mountain-lake.jpg (blue/teal theme)"
else
    echo "⏭️  Skipping mountain-lake.jpg (already exists)"
fi

# Wallpaper 2: Sunset/forest (orange/warm dominant)
if [[ ! -f "$WALLPAPER_DIR/sunset-forest.jpg" ]]; then
    curl -L "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1920&h=1080&fit=crop&crop=center" \
         -o "$WALLPAPER_DIR/sunset-forest.jpg" \
         --progress-bar
    echo "✅ Downloaded: sunset-forest.jpg (orange/warm theme)"
else
    echo "⏭️  Skipping sunset-forest.jpg (already exists)"
fi

# Set permissions
chmod 644 "$WALLPAPER_DIR"/*.jpg

echo ""
echo "🎨 Wallpaper setup complete!"
echo "📁 Location: $WALLPAPER_DIR"
echo "🖼️  Available wallpapers:"
ls -la "$WALLPAPER_DIR"
echo ""
echo "🚀 Usage:"
echo "  - Press Super + W to open wallpaper selector"
echo "  - Select a wallpaper to generate dynamic theme"
echo "  - All applications will auto-reload with new colors"
echo ""
echo "💡 To add your own wallpapers:"
echo "  cp /path/to/your/image.jpg \"$WALLPAPER_DIR/\""