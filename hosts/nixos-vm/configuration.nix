# hosts/nixos-vm/configuration.nix
# Settings ONLY for the Virtual Machine

{ config, pkgs, ... }:

{
  # This imports the VM's specific hardware configuration.
  imports = [ ./hardware-configuration.nix ];

  # Set the hostname for this specific machine.
  networking.hostName = "nixos";

  # Bootloader settings are often machine-specific.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  # Enable networking. While this could be common, keeping it here is fine.
  networking.networkmanager.enable = true;

  # Enable system-wide support for compositors.
  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # This value should be set for each machine.
  system.stateVersion = "25.05";
}
