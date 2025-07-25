# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
  ...
}: {
  boot.kernelModules = [
    "wireguard"
    "ip_tables"
    "iptable_nat"
    "ip6_tables"
    "ip6table_nat"
  ];

  # Containers
  virtualisation.oci-containers.containers."wg-easy" = {
    image = "ghcr.io/wg-easy/wg-easy:15";
    volumes = [
      "/run/current-system/kernel-modules:/lib/modules:ro"
      "/var/lib/wg-easy:/etc/wireguard:rw"
    ];
    ports = [
      "51820:51820/udp"
      "51821:51821/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--cap-add=SYS_MODULE"
      "--ip6=fdcc:ad94:bacf:61a3::2a"
      "--ip=10.42.42.42"
      "--network-alias=wg-easy"
      "--network=wg-easy_wg"
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      "--sysctl=net.ipv4.ip_forward=1"
      "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
      "--sysctl=net.ipv6.conf.all.forwarding=1"
      "--sysctl=net.ipv6.conf.default.forwarding=1"
    ];
  };

  systemd.services."podman-wg-easy" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-wg-easy_wg.service"
      "podman-volume-wg-easy_etc_wireguard.service"
    ];
    requires = [
      "podman-network-wg-easy_wg.service"
      "podman-volume-wg-easy_etc_wireguard.service"
    ];
    partOf = [
      "podman-compose-wg-easy-root.target"
    ];
    wantedBy = [
      "podman-compose-wg-easy-root.target"
    ];
  };

  # Networks
  networking.firewall.allowedUDPPorts = [51820];
  systemd.services."podman-network-wg-easy_wg" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f wg-easy_wg";
    };
    script = ''
      podman network inspect wg-easy_wg || podman network create wg-easy_wg --driver=bridge --subnet=10.42.42.0/24 --subnet=fdcc:ad94:bacf:61a3::/64 --ipv6
    '';
    partOf = ["podman-compose-wg-easy-root.target"];
    wantedBy = ["podman-compose-wg-easy-root.target"];
  };

  # Volumes
  systemd.tmpfiles.rules = [
    #   type path         mode UID   GID   age argument
    "d  /var/lib/wg-easy  0700 root  root  -   -"
  ];
  systemd.services."podman-volume-wg-easy_etc_wireguard" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect wg-easy_etc_wireguard || podman volume create wg-easy_etc_wireguard
    '';
    partOf = ["podman-compose-wg-easy-root.target"];
    wantedBy = ["podman-compose-wg-easy-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-wg-easy-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
