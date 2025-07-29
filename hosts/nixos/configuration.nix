{ config, pkgs, inputs, ... }:

{
  # IMPORTANT: The installer will generate this file.
  # You will need to copy it into this directory.
  imports = [
    ./hardware-configuration.nix
    inputs.impermanence.nixosModules.impermanence
  ];

  # Set the hostname for this machine
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable system-wide support for compositors.
  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # Enable SSH
  services.openssh.enable = true;

  # Persist important directories using impermanence
  environment.persistence."/persist" = {
    directories = [
      "/var/lib"
      "/var/log"
    ];
  };

  # This value should be set for each machine.
  system.stateVersion = "25.05";
}
