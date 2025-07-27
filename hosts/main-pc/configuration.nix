{ config, pkgs, ... }:

{
  # IMPORTANT: The installer will generate this file.
  # You will need to copy it into this directory.
  imports = [ ./hardware-configuration.nix ];

  # Set the hostname for this machine
  networking.hostName = "nixos";

  # Enable system-wide support for compositors.
  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # This value should be set for each machine.
  system.stateVersion = "25.05";
}
