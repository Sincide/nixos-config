{ config, lib, ... }:
{
  options.modules.waybar.enable = lib.mkEnableOption "Waybar dotfiles";
  config = lib.mkIf config.modules.waybar.enable {
    xdg.configFile."waybar".source = ../dotfiles/waybar;
  };
}
