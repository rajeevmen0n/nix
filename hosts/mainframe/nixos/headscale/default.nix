{ config, ... }:

let
  inherit (import ../domain.nix) subdomains tailnet;
  inherit (import ../lib.nix) mkProxyVhost;
  host = subdomains.headscale;
  headscale = config.services.headscale;
  secretOwner = {
    owner = "headscale";
    group = "headscale";
  };
in
{
  imports = [ ./tailscale.nix ];

  sops.secrets."headscale_noise_private_key" = secretOwner;
  sops.secrets."headscale_derp_private_key" = secretOwner;
  sops.secrets."headscale_oidc_client_secret" = secretOwner;

  services.headscale = {
    enable = true;

    address = "127.0.0.1";
    port = 8080;

    settings = {
      server_url = "https://${host}";

      oidc = {
        issuer = "https://${subdomains.auth}";
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
        base_domain = tailnet;
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

  # STUN port of the embedded DERP relay
  networking.firewall.allowedUDPPorts = [ 3478 ];

  services.ddclient.domains = [ host ];

  services.nginx.virtualHosts.${host} = mkProxyVhost {
    proxyPass = "http://${headscale.address}:${toString headscale.port}";
  };

  # Sign in to Headscale through Authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "headscale";
      client_name = "Headscale";
      client_secret = "$pbkdf2-sha512$310000$ncYx0TRFSofvssJKZHc/dQ$ISpBlSFuE3tGANyVhZzL0ELTv0s8FIjGFo6J/SqE/0n1OkZPqJPlHCqbBgAHeJzhaRAhHXSWok6.MsP6HnVdZg";
      authorization_policy = "one_factor";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [
        "https://${host}/oidc/callback"
      ];
      scopes = [ "openid" "profile" "email" "groups" ];
    }
  ];
}
