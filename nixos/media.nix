{ pkgs, ... }:
{
  programs.noisetorch.enable = true;

  environment.systemPackages = with pkgs; [
    spotify
    vlc
    ffmpeg
  ];
}
