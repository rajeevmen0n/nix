{ lib, ... }:

{
  systemd.tmpfiles.rules = [
    "d /persist/headscale 0700 headscale headscale - -"
    "d /persist/tailscale 0700 root root - -"
  ];

  services.tailscale = {
    enable = true;
    
    useRoutingFeatures = "server";

    extraUpFlags = [
      "--login-server=https://headscale.icyfire.dev"
      "--advertise-exit-node"
    ];

    extraDaemonFlags = [
      "--state=/persist/tailscale/tailscaled.state"
    ];
  };

  systemd.services.tailscaled.serviceConfig = {
    StateDirectory = lib.mkForce [ ];
    ReadWritePaths = [ "/persist/tailscale" ];
  };

  services.headscale = {
    enable = true;
    
    address = "127.0.0.1";
    port = 8080;

    settings = {
      server_url = "https://headscale.icyfire.dev";

      noise = {
        private_key_path = "/persist/headscale/noise_private.key";
      };

      prefixes = {
        v4 = "100.64.0.0/10";
        v6 = "fd7a:115c:a1e0::/48";
        allocation = "sequential";
      };

      dns = {
        magic_dns = true;
        base_domain = "tailnet.icyfire.dev"; 
        override_local_dns = true;
        nameservers = {
          global = [ "1.1.1.1" "8.8.8.8" ];
        };
      };

      derp = {
        urls = [ ];
        auto_update_enabled = false;

        server = {
          enabled = true;
          region_id = 999;
          region_code = "icyfire";
          region_name = "Icyfire Local Relay";
          stun_listen_addr = "0.0.0.0:3478";
          private_key_path = "/persist/headscale/derp_server_private.key";
        };
      };

      database = {
        type = "sqlite";
        sqlite = {
          path = "/persist/headscale/db.sqlite";
          write_ahead_log = true;
        };
      };

      log = {
        level = "info";
        format = "text";
      };
    };
  };

  systemd.services.headscale.serviceConfig = {
    StateDirectory = lib.mkForce [ ];
    ReadWritePaths = [ "/persist/headscale" ];
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
}
