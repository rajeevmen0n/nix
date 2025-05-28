{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pywal
    # pywalfox-native
  ];

  # xdg.configFile."wal/templates/".source = ./template;
}