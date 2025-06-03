{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    vlc
  ];
}