{ lib, ... }:

{
  systemd.tmpfiles.rules = [
    "d /persist/headplane 0700 headscale headscale - -"
  ];

  services.headplane = {
    enable = true;

    settings = {
      server = {
        host = "127.0.0.1";
        port = 3000;
        base_url = "https://headplane.icyfire.dev";
        cookie_secret_path = "/persist/headplane/cookie_secret";
        data_path = "/persist/headplane";
      };

      headscale = {
        url = "http://127.0.0.1:8080";
        public_url = "https://headscale.icyfire.dev";
      };
    };
  };

  systemd.services.headplane = {
    serviceConfig = {
      StateDirectory = lib.mkForce [ ];
      ReadWritePaths = [ "/persist/headplane" ];
    };

    preStart = ''
      if [ ! -f /persist/headplane/cookie_secret ]; then
        tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32 > /persist/headplane/cookie_secret
        chmod 0600 /persist/headplane/cookie_secret
      fi
    '';
  };
}
