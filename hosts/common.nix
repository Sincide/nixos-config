# hosts/common.nix
# Settings that will be applied to ALL machines

{ config, pkgs, username, ... }:

{

  # This permanently enables flakes and the new nix command syntax
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use systemd-boot on all UEFI machines
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest stable kernel for newest hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set Swedish keyboard layout for graphical sessions and the console
  services.xserver.xkb.layout = "se";
  console.keyMap = "sv-latin1";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Enable the fish shell program module
  programs.fish.enable = true;

  # Define your user account here so it exists on all machines
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ]; # 'wheel' allows sudo
    shell = pkgs.fish;
  };

  # Allow unfree packages on all systems
  nixpkgs.config.allowUnfree = true;

  # Set a few essential system-wide packages for all machines
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    hyprpolkitagent # If this fails, use polkit_gnome instead
  ];

  # Enable polkit for authentication dialogs (required for many desktop actions)
  security.polkit.enable = true;

  # Use Cachix binary cache for faster installs
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://claude-code.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
  ];
}
