{ pkgs, ... }:
let
  inherit (import ../domain.nix) subdomains;
  app = import ./package.nix pkgs;
  stateDir = "/var/lib/needledrop";
  host = subdomains.needledrop;
in
{
  imports = [ ./nginx.nix ];

  users.groups.needledrop = { };
  users.users.needledrop = {
    isSystemUser = true;
    group = "needledrop";
    home = stateDir;
  };

  systemd.services.needledrop = {
    description = "Needledrop song game API";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      ND_BIND = "127.0.0.1:4810";
      ND_DATA_DIR = stateDir;
      ND_PUBLIC_URL = "https://${host}";
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };

    serviceConfig = {
      Type = "simple";
      User = "needledrop";
      Group = "needledrop";
      StateDirectory = "needledrop";
      StateDirectoryMode = "0700";
      WorkingDirectory = stateDir;
      ExecStart = "${app.server}/bin/needledrop-server";
      Restart = "on-failure";
      RestartSec = 5;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  services.ddclient.domains = [ host ];

  # Only the admin pages and admin API are restricted, to needledrop_admin
  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = [ host ];
      resources = [ "^/admin($|/)" "^/api/admin($|/)" ];
      subject = [ [ "group:needledrop_admin" ] ];
      policy = "one_factor";
    }
    {
      domain = [ host ];
      resources = [ "^/admin($|/)" "^/api/admin($|/)" ];
      policy = "deny";
    }
  ];
}
