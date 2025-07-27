# hosts/common.nix
# Settings that will be applied to ALL machines

{ config, pkgs, ... }:

{

  # Use systemd-boot on all UEFI machines
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set Swedish keyboard layout for graphical sessions and the console
  services.xserver.xkb.layout = "se";
  console.keyMap = "sv-latin1";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

    # Enable the fish shell program module
  programs.fish.enable = true;

  # Define your user account here so it exists on all machines
  users.users.martin = {
    isNormalUser = true;
    description = "Martin";
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
  ];
}
