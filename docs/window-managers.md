# Window Manager Guide

This configuration provides support for two modern Wayland compositors. This guide explains the differences and how to configure each one.

## Hyprland

Hyprland is a dynamic tiling compositor with advanced visual effects and animations.

### Key Features
- **Dynamic tiling** with floating window support
- **Smooth animations** and advanced visual effects
- **Plugin system** for extensibility
- **IPC support** for runtime configuration changes

### Configuration
- Main config: `dotfiles/hypr/hyprland.conf`
- Split configuration files in `dotfiles/hypr/conf/`:
  - `keybinds.conf` - Keyboard shortcuts
  - `monitors.conf` - Display configuration
  - `animations.conf` - Animation settings
  - `decoration.conf` - Window decorations
  - `windowrules.conf` - Application-specific rules

### Default Keybindings
- `Super + Q` - Close window
- `Super + Enter` - Open terminal
- `Super + D` - Open application launcher
- `Super + W` - Open wallpaper selector
- `Super + [1-9]` - Switch workspace
- `Super + Shift + [1-9]` - Move window to workspace

### Applying Changes
Use `hyprctl reload` to apply configuration changes without restarting.

## Niri

Niri is a scrollable-tiling compositor inspired by PaperWM, where workspaces can expand horizontally.

### Key Features
- **Scrollable tiling** - windows are arranged in horizontal strips
- **Workspace scrolling** - pan left/right through your workspace
- **Predictable layout** - windows maintain their relative positions
- **Minimal resource usage** - lightweight and efficient

### Configuration
- Single configuration file: `dotfiles/niri/niri.kdl`
- Uses KDL (KubeConf Document Language) format
- All settings (keybindings, layout, appearance) in one file

### Default Keybindings
- `Super + Shift + Q` - Exit Niri
- `Super + T` - Open terminal
- `Super + D` - Open application launcher
- `Super + H/L` - Focus left/right window
- `Super + J/K` - Focus up/down window
- `Super + Shift + H/L` - Move window left/right
- `Super + Shift + J/K` - Move window up/down

### Applying Changes
Restart Niri to apply configuration changes (logout and login, or restart the session).

## Choosing Between Them

### Use Hyprland if you want:
- Advanced visual effects and animations
- More traditional tiling window management
- Extensive plugin ecosystem
- Runtime configuration changes

### Use Niri if you prefer:
- Scrollable, horizontal workspace layout
- Minimal resource usage
- Predictable window positioning
- Simpler configuration

## Switching Between Window Managers

1. **At login**: Select your preferred compositor from the display manager
2. **Disable one permanently**: Edit the configuration files as described in the customization guide
3. **Test both**: Keep both enabled and switch between them as needed

Both window managers work with the same applications and dotfiles (Waybar, Kitty, Rofi, etc.), so you can switch between them without losing your workflow.