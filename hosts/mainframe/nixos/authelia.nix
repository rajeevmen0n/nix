{ config, ... }:

let
  domain = "icyfire.dev";
  authDomain = "auth.${domain}";
  port = 9091;
in
{
  sops.secrets."authelia_jwt_secret" = {
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

  sops.secrets."authelia_session_secret" = {
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

  sops.secrets."authelia_storage_encryption_key" = {
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
      sessionSecretFile = config.sops.secrets.authelia_session_secret.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia_storage_encryption_key.path;
    };

    settings = {
      theme = "dark";
      server = {
        address = "tcp://127.0.0.1:${toString port}";
      };

      log = {
        level = "info";
      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = [ "*.${domain}" "${domain}" ];
            policy = "one_factor";
          }
        ];
      };

      session = {
        cookies = [
          {
            domain = domain;
            authelia_url = "https://${authDomain}";
          }
        ];
      };

      authentication_backend = {
        file = {
          path = "/var/lib/authelia-main/users_database.yml";
        };
      };

      storage = {
        local = {
          path = "/var/lib/authelia-main/db.sqlite3";
        };
      };

      notifier = {
        filesystem = {
          filename = "/var/lib/authelia-main/notification.txt";
        };
      };
    };
  };
}
