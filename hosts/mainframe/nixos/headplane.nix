{ config, pkgs, ... }:

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
        port = 3000;
        base_url = "https://headplane.icyfire.dev";
        cookie_secret_path = config.sops.secrets.headplane_cookie_secret.path;
        data_path = "/var/lib/headplane";
      };

      headscale = {
        url = "http://127.0.0.1:8080";
        public_url = "https://headscale.icyfire.dev";
      };

      oidc = {
        enabled = true;
        issuer = "https://auth.icyfire.dev";
        client_id = "headplane";
        client_secret_path = config.sops.secrets.headplane_oidc_client_secret.path;
        headscale_api_key_path = "/var/lib/headplane/api_key";
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
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $KEY" http://127.0.0.1:8080/api/v1/apikey || true)
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
}
