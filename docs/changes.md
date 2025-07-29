# Recent Improvements

This repository was refactored to be easier to reuse on multiple machines.

- **Parameterized username**: change the `username` value in `flake.nix` once and all files pick it up automatically.
- **Automatic host discovery**: any directory under `hosts/` becomes a build target, so adding new machines is trivial.
- **Modular dotfiles**: Hyprland, Kitty, Waybar and other configs are provided as optional Home‑Manager modules.
- **Wallpaper daemon service**: a systemd user service starts `swww` on login for reliable wallpaper changes.
- **Hardware check hook**: a pre‑commit hook prevents commits that are missing `hardware-configuration.nix` for a host.
- **Binary cache**: Cachix is preconfigured for fast downloads of `claude-code` packages.
- **Impermanence example**: the `impermanence` module is included, showing how to persist selected directories.

