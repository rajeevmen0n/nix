{ pkgs, ...}: 
let
  users = import ../../config/users.nix;
in {
  nix.settings.trusted-users = [ "root" users.default.username ];

  environment.systemPackages = with pkgs; [
    cachix
  ];
}