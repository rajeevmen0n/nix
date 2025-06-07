{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pywal16
  ];

  xdg.configFile."wal/templates/colors-hyprland.conf".source = ../../../config/pywal/colors-hyprland.conf;
}
