{
  services.tailscale = {
    enable = true;
    
    useRoutingFeatures = "server";

    extraUpFlags = [
      "--login-server=http://127.0.0.1:8080"
      "--advertise-exit-node"
    ];

    authKeyFile = "/var/secrets/tailscale_auth_key";
  };

  services.headscale = {
    enable = true;
    
    address = "127.0.0.1";
    port = 8080;

    settings = {
      server_url = "https://headscale.icyfire.dev";

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
        };
      };

      database = {
        type = "sqlite";
        sqlite = {
          path = "/var/lib/headscale/db.sqlite";
          write_ahead_log = true;
        };
      };

      log = {
        level = "info";
        format = "text";
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
}
