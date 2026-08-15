{ config, pkgs, ... }:
{
  sops.secrets."headscale_noise_private_key" = {
    owner = "headscale";
    group = "headscale";
  };

  sops.secrets."headscale_derp_private_key" = {
    owner = "headscale";
    group = "headscale";
  };

  sops.secrets."headscale_oidc_client_secret" = {
    owner = "headscale";
    group = "headscale";
  };

  services.tailscale = {
    enable = true;

    useRoutingFeatures = "server";

    extraUpFlags = [
      "--login-server=https://headscale.icyfire.dev"
      "--advertise-exit-node"
    ];
  };

  services.headscale = {
    enable = true;

    address = "127.0.0.1";
    port = 8080;

    settings = {
      server_url = "https://headscale.icyfire.dev";

      oidc = {
        issuer = "https://auth.icyfire.dev";
        client_id = "headscale";
        client_secret_path = config.sops.secrets.headscale_oidc_client_secret.path;
        scope = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        pkce = {
          enabled = true;
          method = "S256";
        };
      };

      noise = {
        private_key_path = config.sops.secrets.headscale_noise_private_key.path;
      };

      dns = {
        magic_dns = true;
        base_domain = "tailnet.icyfire.dev";
        override_local_dns = true;
        nameservers = {
          global = [
            "1.1.1.1"
            "8.8.8.8"
          ];
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
          private_key_path = config.sops.secrets.headscale_derp_private_key.path;
        };
      };
    };
  };

  systemd.services.tailscale-autokey = {
    description = "Auto-authenticate mainframe to Headscale under server user";
    after = [
      "headscale.service"
      "tailscaled.service"
    ];
    wants = [
      "headscale.service"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [
      config.services.headscale.package
      config.services.tailscale.package
      pkgs.jq
      pkgs.coreutils
    ];
    script = ''
      # Ensure 'server' user exists in Headscale
      headscale users create server 2>/dev/null || true

      # Check if tailscale is logged in
      IF_LOGGED_IN=0
      if tailscale status --json 2>/dev/null | jq -e '.Self.Online' >/dev/null 2>&1; then
        IF_LOGGED_IN=1
      fi

      if [ "$IF_LOGGED_IN" = "0" ]; then
        # Retrieve numeric user ID for 'server' user
        USER_ID=$(headscale users list -o json 2>/dev/null | jq -r 'if type=="array" then (.[] | select(.name=="server") | .id) else empty end')
        if [ -z "$USER_ID" ] || [ "$USER_ID" = "null" ]; then
          echo "ERROR: Could not find 'server' user in Headscale" >&2
          exit 1
        fi

        echo "Auto-generating pre-auth key for mainframe under server user (ID: $USER_ID)..."
        KEY=$(headscale preauthkeys create --user "$USER_ID" --expiration 24h -o json | jq -r 'if type=="object" then .key else . end')

        echo "Logging mainframe into Headscale..."
        tailscale up --login-server=https://headscale.icyfire.dev --authkey "$KEY" --advertise-exit-node
        sleep 2
      fi

      # Auto-approve exit node routes for mainframe
      echo "Auto-approving exit node routes for mainframe..."
      NODE_ID=$(headscale nodes list -o json 2>/dev/null | jq -r 'if type=="array" then (.[] | select(.given_name=="mainframe" or .name=="mainframe") | .id) else empty end')
      if [ -z "$NODE_ID" ] || [ "$NODE_ID" = "null" ]; then
        echo "ERROR: Could not find 'mainframe' node in Headscale" >&2
        exit 1
      fi

      headscale nodes approve-routes --identifier "$NODE_ID" --routes "0.0.0.0/0,::/0" 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
}
