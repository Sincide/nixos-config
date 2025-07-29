{ config, lib, ... }:
{
  options.modules.rofi.enable = lib.mkEnableOption "Rofi dotfiles";
  config = lib.mkIf config.modules.rofi.enable {
    xdg.configFile."rofi".source = ../dotfiles/rofi;
  };
}
