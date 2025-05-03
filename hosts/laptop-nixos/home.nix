{ config, pkgs, ... }:
let
  users = import ../../config/users.nix;
in
{
  imports = [
    ../../home/dev.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    vscode.fhs
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "24.11";
  };
}