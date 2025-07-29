#!/bin/bash

# Theme Cache Manager for Dotfiles
# Downloads and manages themes locally to avoid re-downloading on fresh installs

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEMES_CACHE_DIR="$DOTFILES_DIR/config/themes/assets/cached"
USER_THEMES_DIR="$HOME/.themes"
USER_ICONS_DIR="$HOME/.icons"

# Ensure cache directories exist
mkdir -p "$THEMES_CACHE_DIR"/{gtk,icons,cursors}
mkdir -p "$USER_THEMES_DIR" "$USER_ICONS_DIR"

# Theme definitions with download information
declare -A THEME_DOWNLOADS=(
    # GTK Themes
    ["Nordic"]="aur|nordic-theme|gtk"
    ["Orchis-Green-Dark"]="aur|orchis-theme|gtk"
    ["Ultimate-Dark"]="aur|arc-gtk-theme|gtk"
    ["Graphite-Dark"]="aur|arc-gtk-theme|gtk"
    ["Yaru-Colors"]="aur|yaru-colors-git|gtk"
    
    # Icon Themes
    ["Papirus-Dark"]="aur|papirus-icon-theme|icons"
    ["Papirus"]="aur|papirus-icon-theme|icons"
    ["Tela-circle-green"]="aur|tela-circle-icon-theme-green|icons"
    
    # Cursor Themes
    ["Bibata-Modern-Ice"]="aur|bibata-cursor-theme|cursors"
    ["Bibata-Modern-Amber"]="aur|bibata-cursor-theme|cursors"
    ["Bibata-Modern-Classic"]="aur|bibata-cursor-theme|cursors"
    ["Capitaine-Cursors"]="aur|capitaine-cursors|cursors"
)

# Function to check if theme is already installed
is_theme_installed() {
    local theme_name="$1"
    local theme_type="$2"
    
    case "$theme_type" in
        "gtk")
            [[ -d "$USER_THEMES_DIR/$theme_name" ]] || [[ -d "/usr/share/themes/$theme_name" ]]
            ;;
        "icons")
            [[ -d "$USER_ICONS_DIR/$theme_name" ]] || [[ -d "/usr/share/icons/$theme_name" ]]
            ;;
        "cursors")
            [[ -d "$USER_ICONS_DIR/$theme_name" ]] || [[ -d "/usr/share/icons/$theme_name" ]]
            ;;
    esac
}

# Function to check if theme is cached
is_theme_cached() {
    local theme_name="$1"
    local theme_type="$2"
    
    [[ -d "$THEMES_CACHE_DIR/$theme_type/$theme_name" ]]
}

# Function to install from cache
install_from_cache() {
    local theme_name="$1"
    local theme_type="$2"
    local cache_path="$THEMES_CACHE_DIR/$theme_type/$theme_name"
    
    echo "📦 Installing $theme_name from cache..."
    
    case "$theme_type" in
        "gtk")
            if [[ -f "$cache_path/install.sh" ]]; then
                cd "$cache_path"
                ./install.sh -d "$USER_THEMES_DIR" 2>/dev/null || {
                    # Fallback: direct copy
                    cp -r "$cache_path" "$USER_THEMES_DIR/" 2>/dev/null
                }
            else
                cp -r "$cache_path" "$USER_THEMES_DIR/" 2>/dev/null
            fi
            ;;
        "icons")
            if [[ -f "$cache_path/install.sh" ]]; then
                cd "$cache_path"
                ./install.sh -d "$USER_ICONS_DIR" 2>/dev/null || {
                    # Fallback: direct copy
                    cp -r "$cache_path" "$USER_ICONS_DIR/" 2>/dev/null
                }
            else
                cp -r "$cache_path" "$USER_ICONS_DIR/" 2>/dev/null
            fi
            ;;
        "cursors")
            cp -r "$cache_path" "$USER_ICONS_DIR/" 2>/dev/null
            ;;
    esac
    
    if is_theme_installed "$theme_name" "$theme_type"; then
        echo "✅ $theme_name installed from cache"
        return 0
    else
        echo "❌ Failed to install $theme_name from cache"
        return 1
    fi
}

# Function to download and cache theme
download_and_cache_theme() {
    local theme_name="$1"
    local download_info="${THEME_DOWNLOADS[$theme_name]}"
    
    if [[ -z "$download_info" ]]; then
        echo "❌ No download info for $theme_name"
        return 1
    fi
    
    IFS='|' read -ra INFO <<< "$download_info"
    local method="${INFO[0]}"
    local source="${INFO[1]}"
    local theme_type="${INFO[2]}"
    local install_cmd="${INFO[3]:-}"
    
    local cache_path="$THEMES_CACHE_DIR/$theme_type/$theme_name"
    
    echo "📥 Downloading $theme_name ($theme_type)..."
    
    case "$method" in
        "git")
            if git clone --depth=1 "$source" "$cache_path" 2>/dev/null; then
                echo "✅ Downloaded $theme_name to cache"
                
                # If there's a custom install command, run it
                if [[ -n "$install_cmd" ]]; then
                    cd "$cache_path"
                    eval "$install_cmd" 2>/dev/null || echo "⚠️  Custom install command failed for $theme_name"
                fi
                
                return 0
            else
                echo "❌ Failed to download $theme_name"
                return 1
            fi
            ;;
        "aur")
            # For AUR packages, we can't cache them, but we can note they're available
            echo "📝 $theme_name is an AUR package ($source)"
            return 2  # Special return code for AUR packages
            ;;
    esac
}

# Function to install theme (cache-aware)
install_theme() {
    local theme_name="$1"
    
    # Check if already installed
    if [[ -n "${THEME_DOWNLOADS[$theme_name]}" ]]; then
        IFS='|' read -ra INFO <<< "${THEME_DOWNLOADS[$theme_name]}"
        local theme_type="${INFO[2]}"
        
        if is_theme_installed "$theme_name" "$theme_type"; then
            echo "✅ $theme_name already installed"
            return 0
        fi
        
        # Try to install from cache first
        if is_theme_cached "$theme_name" "$theme_type"; then
            if install_from_cache "$theme_name" "$theme_type"; then
                return 0
            fi
        fi
        
        # Download and cache if not available
        local download_result
        download_and_cache_theme "$theme_name"
        download_result=$?
        
        if [[ $download_result -eq 0 ]]; then
            # Successfully downloaded, now install from cache
            install_from_cache "$theme_name" "$theme_type"
        elif [[ $download_result -eq 2 ]]; then
            # AUR package, install directly
            IFS='|' read -ra INFO <<< "${THEME_DOWNLOADS[$theme_name]}"
            local aur_package="${INFO[1]}"
            echo "📦 Installing AUR package: $aur_package"
            yay -S --needed --noconfirm "$aur_package" 2>/dev/null || echo "❌ Failed to install $aur_package"
        else
            echo "❌ Failed to download $theme_name"
            return 1
        fi
    else
        echo "❌ Unknown theme: $theme_name"
        return 1
    fi
}

# Function to cache all themes
cache_all_themes() {
    echo "🎨 Caching all dynamic themes..."
    echo "This will download themes to $THEMES_CACHE_DIR"
    echo ""
    
    local cached_count=0
    local total_git_themes=0
    
    # Count git-based themes
    for theme_name in "${!THEME_DOWNLOADS[@]}"; do
        IFS='|' read -ra INFO <<< "${THEME_DOWNLOADS[$theme_name]}"
        if [[ "${INFO[0]}" == "git" ]]; then
            ((total_git_themes++))
        fi
    done
    
    echo "📋 Found $total_git_themes git-based themes to cache"
    echo ""
    
    for theme_name in "${!THEME_DOWNLOADS[@]}"; do
        IFS='|' read -ra INFO <<< "${THEME_DOWNLOADS[$theme_name]}"
        local method="${INFO[0]}"
        local theme_type="${INFO[2]}"
        
        if [[ "$method" == "git" ]]; then
            if is_theme_cached "$theme_name" "$theme_type"; then
                echo "✅ $theme_name already cached"
            else
                if download_and_cache_theme "$theme_name"; then
                    ((cached_count++))
                fi
            fi
        else
            echo "⏭️  Skipping $theme_name (AUR package)"
        fi
    done
    
    echo ""
    echo "✅ Cached $cached_count new themes"
    echo "📂 Cache location: $THEMES_CACHE_DIR"
}

# Function to list cached themes
list_cached_themes() {
    echo "📦 Cached Themes in $THEMES_CACHE_DIR:"
    echo ""
    
    for type_dir in "$THEMES_CACHE_DIR"/*; do
        if [[ -d "$type_dir" ]]; then
            local type_name=$(basename "$type_dir")
            echo "🎨 $type_name themes:"
            
            if [[ -n "$(ls -A "$type_dir" 2>/dev/null)" ]]; then
                for theme_dir in "$type_dir"/*; do
                    if [[ -d "$theme_dir" ]]; then
                        local theme_name=$(basename "$theme_dir")
                        echo "  ✓ $theme_name"
                    fi
                done
            else
                echo "  (none cached)"
            fi
            echo
        fi
    done
}

# Function to clean cache
clean_cache() {
    echo "🧹 Cleaning theme cache..."
    if [[ -d "$THEMES_CACHE_DIR" ]]; then
        rm -rf "$THEMES_CACHE_DIR"
        mkdir -p "$THEMES_CACHE_DIR"/{gtk,icons,cursors}
        echo "✅ Theme cache cleaned"
    else
        echo "ℹ️  No cache to clean"
    fi
}

# Main function
main() {
    case "${1:-}" in
        "install")
            if [[ -z "$2" ]]; then
                echo "Usage: $0 install <theme_name>"
                exit 1
            fi
            install_theme "$2"
            ;;
        "cache-all")
            cache_all_themes
            ;;
        "list")
            list_cached_themes
            ;;
        "clean")
            clean_cache
            ;;
        "list-available")
            echo "📋 Available themes for caching:"
            for theme_name in "${!THEME_DOWNLOADS[@]}"; do
                IFS='|' read -ra INFO <<< "${THEME_DOWNLOADS[$theme_name]}"
                local method="${INFO[0]}"
                local theme_type="${INFO[2]}"
                echo "  $theme_name ($theme_type, $method)"
            done
            ;;
        *)
            echo "Theme Cache Manager"
            echo "Usage: $0 {install|cache-all|list|clean|list-available}"
            echo ""
            echo "Commands:"
            echo "  install <theme>   - Install specific theme (from cache if available)"
            echo "  cache-all         - Download and cache all git-based themes"
            echo "  list              - Show cached themes"
            echo "  clean             - Clean theme cache"
            echo "  list-available    - Show all available themes"
            echo ""
            echo "Cache location: $THEMES_CACHE_DIR"
            ;;
    esac
}

main "$@" 