{ pkgs, lib, ...}: 
let
  users = import ../../config/users.nix;
in {
  nix.settings = {
    substituters = lib.mkAfter [ "https://g16-nixos.cachix.org" ];
    trusted-public-keys = lib.mkAfter [ "g16-nixos.cachix.org-1:JlrHbD35SxKOpf6tnzTVTv6ZYMQYlIcipdXvj2C98Wc=" ];
    trusted-users = lib.mkAfter [ "root" users.default.username ];
  };

  environment.systemPackages = with pkgs; [
    cachix
  ];
}
