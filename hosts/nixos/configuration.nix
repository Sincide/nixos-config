{ config, pkgs, inputs, ... }:

{
  # IMPORTANT: Generate hardware-configuration.nix with:
  # sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
  imports = [
    ./hardware-configuration.nix
    # inputs.impermanence.nixosModules.impermanence  # Disabled for standard filesystems
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

  # NOTE: Impermanence disabled for standard VM/desktop setups
  # Uncomment and configure for btrfs with impermanence:
  # environment.persistence."/persist" = {
  #   directories = [
  #     "/var/lib"
  #     "/var/log"
  #   ];
  # };

  # This value should be set for each machine.
  system.stateVersion = "25.05";
}
