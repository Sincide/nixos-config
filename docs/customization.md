# Customization

### Adding Packages
Add packages to `home.nix` in the `home.packages` section.

### Git Configuration
Your Git username and email are configured declaratively in `home.nix`. No need to run `git config` commands manually!

### Desktop Tweaks
- **Hyprland**: Edit individual config files in `dotfiles/hypr/conf/`:
  - `monitors.conf` - Your multi-monitor setup
  - `keybinds.conf` - Keyboard shortcuts
  - `general.conf` - Gaps, borders, layout
  - `decoration.conf` - Visual effects, blur, shadows
  - `animations.conf` - Animation settings
- **Waybar**: Edit `dotfiles/waybar/config` and `dotfiles/waybar/style.css`
- **Terminal**: Edit `dotfiles/kitty/kitty.conf`

### System Settings
Edit `hosts/common.nix` for system-wide changes that apply to all machines.
