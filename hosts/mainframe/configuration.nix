let
  hosts = import ../../config/hosts.nix;
in {
  imports = [
    ./hardware-configuration.nix

    ./nixos/authelia.nix
    ./nixos/ddns.nix
    ./nixos/minecraft.nix
    ./nixos/nginx.nix
    # ./nixos/rummy.nix
    ./nixos/headscale.nix
    ./nixos/headplane.nix
    # ./nixos/wireguard.nix

    ../../nixos/ai.nix
    ../../nixos/server.nix
    ../../nixos/system/podman.nix
    ../../nixos/system/sops.nix
    ../../nixos/system/users.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  networking.hostName = hosts.mainframe.hostname;

  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
