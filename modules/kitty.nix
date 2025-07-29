{ config, lib, ... }:
{
  options.modules.kitty.enable = lib.mkEnableOption "Kitty dotfiles";
  config = lib.mkIf config.modules.kitty.enable {
    xdg.configFile."kitty".source = ../dotfiles/kitty;
  };
}
