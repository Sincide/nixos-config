{ config, lib, ... }:
{
  options.modules.hyprland.enable = lib.mkEnableOption "Hyprland dotfiles";

  config = lib.mkIf config.modules.hyprland.enable {
    xdg.configFile."hypr".source = ../dotfiles/hypr;
  };
}
