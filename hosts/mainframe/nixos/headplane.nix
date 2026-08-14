{ config, ... }:

{
  sops.secrets."headplane_cookie_secret" = {
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
    };
  };
}
