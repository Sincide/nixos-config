#!/usr/bin/env bash

# Wallpaper Thumbnail Generator
# Generates cached thumbnails for wallpaper preview system

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WALLPAPER_DIR="$DOTFILES_DIR/assets/wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbnails"
THUMBNAIL_SIZE="150x150"
THUMBNAIL_QUALITY="85"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v convert >/dev/null 2>&1; then
        missing_deps+=("imagemagick")
    fi
    
    if ! command -v identify >/dev/null 2>&1; then
        missing_deps+=("imagemagick")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Install with: sudo pacman -S imagemagick"
        return 1
    fi
    
    return 0
}

# Generate thumbnail for a single wallpaper
generate_thumbnail() {
    local wallpaper="$1"
    local relative_path="${wallpaper#$WALLPAPER_DIR/}"
    local thumbnail_path="$THUMBNAIL_DIR/${relative_path%.*}.jpg"
    local thumbnail_dir="$(dirname "$thumbnail_path")"
    
    # Create thumbnail directory if needed
    mkdir -p "$thumbnail_dir"
    
    # Skip if thumbnail already exists and is newer than source
    if [[ -f "$thumbnail_path" ]] && [[ "$thumbnail_path" -nt "$wallpaper" ]]; then
        return 0
    fi
    
    # Generate thumbnail with ImageMagick
    if convert "$wallpaper" \
        -thumbnail "${THUMBNAIL_SIZE}^" \
        -gravity center \
        -extent "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" \
        -strip \
        "$thumbnail_path" 2>/dev/null; then
        return 0
    else
        print_warning "Failed to generate thumbnail for: $relative_path"
        return 1
    fi
}

# Generate all thumbnails
generate_all_thumbnails() {
    print_status "🖼️  Generating wallpaper thumbnails..."
    
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        print_error "Wallpaper directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    # Create thumbnail cache directory
    mkdir -p "$THUMBNAIL_DIR"
    
    local total_wallpapers=0
    local generated_count=0
    local skipped_count=0
    
    # Find all wallpapers
    while IFS= read -r -d '' wallpaper; do
        ((total_wallpapers++))
        
        local relative_path="${wallpaper#$WALLPAPER_DIR/}"
        local thumbnail_path="$THUMBNAIL_DIR/${relative_path%.*}.jpg"
        
        if [[ -f "$thumbnail_path" ]] && [[ "$thumbnail_path" -nt "$wallpaper" ]]; then
            ((skipped_count++))
            continue
        fi
        
        printf "\r${BLUE}[*]${NC} Processing: $relative_path"
        
        if generate_thumbnail "$wallpaper"; then
            ((generated_count++))
        fi
        
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) -print0)
    
    printf "\r\033[K"  # Clear line
    
    print_success "Thumbnail generation complete!"
    print_status "Total wallpapers: $total_wallpapers"
    print_status "Generated: $generated_count"
    print_status "Skipped (up-to-date): $skipped_count"
    print_status "Thumbnail directory: $THUMBNAIL_DIR"
}

# Clean up old thumbnails
clean_thumbnails() {
    print_status "🧹 Cleaning up old thumbnails..."
    
    if [[ ! -d "$THUMBNAIL_DIR" ]]; then
        print_warning "Thumbnail directory doesn't exist: $THUMBNAIL_DIR"
        return 0
    fi
    
    local cleaned_count=0
    
    # Find thumbnails that don't have corresponding wallpapers
    while IFS= read -r -d '' thumbnail; do
        local relative_path="${thumbnail#$THUMBNAIL_DIR/}"
        local base_name="${relative_path%.*}"
        
        # Check if corresponding wallpaper exists (any supported format)
        local found=false
        for ext in jpg jpeg png webp bmp; do
            if [[ -f "$WALLPAPER_DIR/${base_name}.${ext}" ]]; then
                found=true
                break
            fi
        done
        
        if [[ "$found" == false ]]; then
            rm -f "$thumbnail"
            ((cleaned_count++))
        fi
        
    done < <(find "$THUMBNAIL_DIR" -type f -name "*.jpg" -print0)
    
    print_success "Cleaned $cleaned_count old thumbnails"
}

# Get thumbnail path for a wallpaper
get_thumbnail_path() {
    local wallpaper="$1"
    local relative_path="${wallpaper#$WALLPAPER_DIR/}"
    echo "$THUMBNAIL_DIR/${relative_path%.*}.jpg"
}

# List wallpapers with their thumbnail paths (for rofi)
list_wallpapers_with_thumbnails() {
    local category="${1:-}"
    local search_dir="$WALLPAPER_DIR"
    
    if [[ -n "$category" ]]; then
        search_dir="$WALLPAPER_DIR/$category"
        if [[ ! -d "$search_dir" ]]; then
            print_error "Category not found: $category"
            return 1
        fi
    fi
    
    while IFS= read -r -d '' wallpaper; do
        local relative_path="${wallpaper#$WALLPAPER_DIR/}"
        local thumbnail_path="$(get_thumbnail_path "$wallpaper")"
        local display_name="$(basename "$wallpaper")"
        
        # Generate thumbnail if it doesn't exist
        if [[ ! -f "$thumbnail_path" ]]; then
            generate_thumbnail "$wallpaper" >/dev/null 2>&1
        fi
        
        # Output format: thumbnail_path|wallpaper_path|display_name
        echo "${thumbnail_path}|${wallpaper}|${display_name}"
        
    done < <(find "$search_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) -print0 | sort -z)
}

# Main function
main() {
    case "${1:-generate}" in
        "generate"|"gen")
            check_dependencies || exit 1
            generate_all_thumbnails
            ;;
        "clean")
            clean_thumbnails
            ;;
        "list")
            list_wallpapers_with_thumbnails "${2:-}"
            ;;
        "thumbnail"|"thumb")
            if [[ -z "$2" ]]; then
                print_error "Usage: $0 thumbnail <wallpaper_path>"
                exit 1
            fi
            check_dependencies || exit 1
            generate_thumbnail "$2"
            ;;
        "help"|"-h"|"--help")
            cat <<EOF
Wallpaper Thumbnail Generator

Usage: $0 [command] [options]

Commands:
  generate, gen     Generate thumbnails for all wallpapers (default)
  clean            Clean up old thumbnails for deleted wallpapers
  list [category]  List wallpapers with thumbnail paths (for rofi)
  thumbnail <path> Generate thumbnail for specific wallpaper
  help             Show this help

Examples:
  $0 generate              # Generate all thumbnails
  $0 list space           # List space category wallpapers
  $0 clean                # Clean up old thumbnails
EOF
            ;;
        *)
            print_error "Unknown command: $1"
            print_status "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@" 