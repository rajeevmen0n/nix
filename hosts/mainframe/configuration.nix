{
  lib,
  pkgs,
  ...
}: let
  hosts = import ../../config/hosts.nix;
  users = import ../../config/users.nix;
in {
  imports = [
    ./hardware-configuration.nix

    ./nixos/authelia.nix
    ./nixos/ddns.nix
    ./nixos/lldap.nix
    ./nixos/minecraft.nix
    ./nixos/nginx.nix
    ./nixos/headscale.nix
    ./nixos/headplane.nix

    ../../nixos/ai.nix
    ../../nixos/server.nix
    ../../nixos/system/podman.nix
    ../../nixos/system/sops.nix
    ../../nixos/system/users.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  networking.hostName = hosts.mainframe.hostname;

  nix.settings = {
    substituters = lib.mkAfter [
      "https://mainframe.cachix.org"
    ];
    trusted-public-keys = lib.mkAfter [
      "mainframe.cachix.org-1:NZMA0UnbQClWKllDyRVm8dmOB2Zju0ULrLJ8qOmOamQ="
    ];
    trusted-users = lib.mkAfter [ "root" users.default.username ];
  };

  environment.systemPackages = with pkgs; [
    cachix
  ];

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
