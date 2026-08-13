{ config, pkgs, lib, ... }:
let
  format = pkgs.formats.yaml { };

  settings = lib.recursiveUpdate config.services.headscale.settings {
    tls_cert_path = "/dev/null";
    tls_key_path = "/dev/null";
    policy.path = "/dev/null";
  };

  headscaleConfig = format.generate "headscale.yml" settings;
in
{
  services.headplane = {
    enable = true;
    settings = {
      server = {
        base_url = "https://headplane.icyfire.dev";
        host = "127.0.0.1";
        port = 3000;
        cookie_secret_path = "/var/secrets/headplane/cookie_secret";
      };
      
      headscale = {
        url = "https://headscale.icyfire.dev";
        public_url = "https://headscale.icyfire.dev";
        config_path = "${headscaleConfig}";
      };
      
      integration.agent = {
        enabled = true;
        pre_authkey_path = "/var/secrets/headplane/pre_auth_key";
      };
    };
  };
}
