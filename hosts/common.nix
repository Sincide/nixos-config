# hosts/common.nix
# Settings that will be applied to ALL machines

{ config, pkgs, ... }:

{
  # Set Swedish keyboard layout for graphical sessions and the console
  services.xserver.layout = "se";
  console.keyMap = "sv-latin1";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

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
