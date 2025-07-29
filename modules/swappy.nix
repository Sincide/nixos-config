{ config, lib, ... }:
{
  options.modules.swappy.enable = lib.mkEnableOption "Swappy dotfiles";
  config = lib.mkIf config.modules.swappy.enable {
    xdg.configFile."swappy".source = ../dotfiles/swappy;
  };
}
