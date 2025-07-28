# NixOS Config: Post-Install Instructions

## 1. Install NixOS (Graphical Installer, No Desktop)
- Complete the installation as usual.

## 2. Clone This Repo
Clone your config repo to your new system:
```sh
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config
```

## 3. Copy Hardware Configuration
Copy the generated hardware config from the installer:
```sh
sudo cp /etc/nixos/hardware-configuration.nix hosts/nixos/hardware-configuration.nix
```

## 4. Enable Flakes (if not already)
Add this to `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

## 5. Rebuild Your System
Run:
```sh
sudo nixos-rebuild switch --flake .#nixos
```

## 6. Reboot
```sh
sudo reboot
```

## 7. Log In and Enjoy
- Hyprland, Firefox, polkit agent, and your dotfiles should be ready.

---

### Troubleshooting
- If `hyprpolkitagent` fails, replace it with `polkit_gnome` in your config and autostart.
- For more help, see the NixOS manual or open an issue in your repo. 