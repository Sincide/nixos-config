{ config, lib, ... }:
{
  options.modules.niri.enable = lib.mkEnableOption "Niri dotfiles";
  config = lib.mkIf config.modules.niri.enable {
    xdg.configFile."niri".source = ../dotfiles/niri;
  };
}
