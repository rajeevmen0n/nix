{ config, pkgs, ... }:

let
  inherit (import ./domain.nix) subdomains;
  inherit (import ./lib.nix) autheliaAuthLocation autheliaProtectedConfig mkProxyVhost;
  host = subdomains.headplane;
  port = 3000;
  headscale = config.services.headscale;
  headscaleUrl = "http://${headscale.address}:${toString headscale.port}";
in
{
  sops.secrets."headplane_cookie_secret" = {
    owner = "headscale";
    group = "headscale";
  };

  sops.secrets."headplane_oidc_client_secret" = {
    owner = "headscale";
    group = "headscale";
  };

  services.headplane = {
    enable = true;

    settings = {
      server = {
        host = "127.0.0.1";
        inherit port;
        base_url = "https://${host}";
        cookie_secret_path = config.sops.secrets.headplane_cookie_secret.path;
        data_path = "/var/lib/headplane";
      };

      headscale = {
        url = headscaleUrl;
        public_url = "https://${subdomains.headscale}";
        api_key_path = "/var/lib/headplane/api_key";
      };

      oidc = {
        enabled = true;
        issuer = "https://${subdomains.auth}";
        client_id = "headplane";
        client_secret_path = config.sops.secrets.headplane_oidc_client_secret.path;
        token_endpoint_auth_method = "client_secret_post";
        scope = "openid email profile";
        disable_api_key_login = false;
      };
    };
  };

  systemd.services.headplane = {
    after = [ "headscale.service" ];
    requires = [ "headscale.service" ];
    path = [
      config.services.headscale.package
      pkgs.curl
      pkgs.jq
    ];
    preStart = ''
      API_KEY_FILE="/var/lib/headplane/api_key"
      mkdir -p /var/lib/headplane
      NEED_KEY=1

      if [ -f "$API_KEY_FILE" ]; then
        KEY=$(cat "$API_KEY_FILE" | tr -d '\n\r')
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $KEY" ${headscaleUrl}/api/v1/apikey || true)
        if [ "$HTTP_STATUS" = "200" ]; then
          NEED_KEY=0
        fi
      fi

      if [ "$NEED_KEY" = "1" ]; then
        echo "Auto-generating new Headscale API key for Headplane..."
        NEW_KEY=$(headscale apikeys create --expiration 365d -o json | jq -r 'if type=="object" then .key else . end')
        echo -n "$NEW_KEY" > "$API_KEY_FILE"
        chmod 600 "$API_KEY_FILE"
        chown headscale:headscale "$API_KEY_FILE"
      fi
    '';
  };

  # Admin UI, restricted to lldap admins by Authelia
  services.nginx.virtualHosts.${host} = mkProxyVhost {
    proxyPass = "http://127.0.0.1:${toString port}";
    extraConfig = autheliaProtectedConfig;
    extraLocations = {
      "/internal/authelia/authz" = autheliaAuthLocation;
      "= /".return = "302 https://${host}/admin";
    };
  };

  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = [ host ];
      subject = [ ["group:lldap_admin"] ["user:admin"] ];
      policy = "one_factor";
    }
    {
      domain = [ host ];
      policy = "deny";
    }
  ];

  # Sign in to Headplane through Authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "headplane";
      client_name = "Headplane";
      client_secret = "$pbkdf2-sha512$310000$YUphTm7Ul5jE1pnkcSbjJA$N6UZKR4MERopfUDJR5IVutOGrpawq02CEKH2r1GxfR9HvOzoE1ML3/wPWqgrC0BaMy2Fx/ggWvqbJgXdA4gu.w";
      authorization_policy = "one_factor";
      token_endpoint_auth_method = "client_secret_post";
      redirect_uris = [
        "https://${host}/admin/oidc/callback"
      ];
      scopes = [ "openid" "profile" "email" ];
    }
  ];
}
