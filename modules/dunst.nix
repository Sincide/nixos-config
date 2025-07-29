{ config, lib, ... }:
{
  options.modules.dunst.enable = lib.mkEnableOption "Dunst dotfiles";
  config = lib.mkIf config.modules.dunst.enable {
    xdg.configFile."dunst".source = ../dotfiles/dunst;
  };
}
