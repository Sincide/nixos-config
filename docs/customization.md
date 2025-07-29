# Customization

This page describes the most common tweaks you might want to make after cloning
the repository.

## 1. Change the username
Edit the `username` value in `flake.nix`.  The same variable is reused across
all modules so you only need to update it in this single file.  Also adjust your
name and email in the `programs.git` section of `home.nix`.

## 2. Add packages
User packages live in `home.nix` under the `home.packages` list.  Add or remove
packages here and rebuild using:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## 3. Dotfile tweaks
- **Hyprland** – edit individual files in `dotfiles/hypr/conf/` (e.g.
  `keybinds.conf` for shortcuts or `monitors.conf` for layouts).
- **Waybar** – `dotfiles/waybar/config` and `dotfiles/waybar/style.css`.
- **Kitty** – `dotfiles/kitty/kitty.conf`.
Reload the affected application or run `hyprctl reload` to apply changes.

## 4. System settings
Settings that apply to all machines are defined in `hosts/common.nix`.  Per host
configuration belongs in `hosts/<hostname>/configuration.nix`.

## 5. Wallpaper and theming
Wallpapers are read from `~/Pictures/Wallpapers`.  Run `./setup-wallpapers.sh`
to download a few sample images.  Use the `wallpaper-selector` script (bound to
<kbd>Super+W</kbd>) to pick an image and automatically regenerate your color
scheme with Matugen.

## 6. Adding new hosts
Create a directory under `hosts/` named after the machine.  Copy the example
`configuration.nix` into it and generate `hardware-configuration.nix` as shown in
the README.

## 7. Pre‑commit checks
Enable the hardware configuration check by pointing Git to the included hook:
```bash
git config core.hooksPath .githooks
```

## 8. Custom color templates
Matugen templates are stored in the `templates/` directory.  Editing these files
lets you fine‑tune the colors generated for Kitty, Waybar, Rofi and Hyprland.

