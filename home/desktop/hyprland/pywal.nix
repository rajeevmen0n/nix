{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pywal16
    # pywalfox-native
  ];

  # xdg.configFile."wal/templates/".source = ./template;
}
