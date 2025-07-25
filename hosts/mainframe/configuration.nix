let
  hosts = import ../../config/hosts.nix;
in {
  imports = [
    ./hardware-configuration.nix

    ./nixos/ddns.nix
    ./nixos/nginx.nix
    ./nixos/wireguard.nix

    ../../nixos/server.nix
    ../../nixos/system/podman.nix
    ../../nixos/system/users.nix
  ];

  networking.hostName = hosts.mainframe.hostname;

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
