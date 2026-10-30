{ config, ... }:

let
  inherit (import ../domain.nix) domain subdomains ldapBaseDn;
  inherit (import ../lib.nix) forwardAuthHeaders mkProxyVhost;
  port = 9091;
  instance = config.services.authelia.instances.main;
  secretOwner = {
    owner = instance.user;
    group = instance.group;
  };
in
{
  imports = [
    ./access-control.nix
    ./oidc.nix
  ];

  sops.secrets."authelia_jwt_secret" = secretOwner;
  sops.secrets."authelia_session_secret" = secretOwner;
  sops.secrets."authelia_storage_encryption_key" = secretOwner;
  sops.secrets."authelia_oidc_hmac_secret" = secretOwner;
  sops.secrets."authelia_oidc_issuer_private_key" = secretOwner;

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
      sessionSecretFile = config.sops.secrets.authelia_session_secret.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia_storage_encryption_key.path;
      oidcHmacSecretFile = config.sops.secrets.authelia_oidc_hmac_secret.path;
      oidcIssuerPrivateKeyFile = config.sops.secrets.authelia_oidc_issuer_private_key.path;
    };

    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets.lldap_user_pass.path;
    };

    settings = {
      theme = "dark";
      server = {
        address = "tcp://127.0.0.1:${toString port}";
      };

      session = {
        cookies = [
          {
            domain = domain;
            authelia_url = "https://${subdomains.auth}";
          }
        ];
      };

      authentication_backend = {
        ldap = {
          implementation = "lldap";
          address = "ldap://127.0.0.1:${toString config.services.lldap.settings.ldap_port}";
          base_dn = ldapBaseDn;
          user = "uid=admin,ou=people,${ldapBaseDn}";
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

  services.ddclient.domains = [ subdomains.auth ];

  services.nginx.virtualHosts.${subdomains.auth} = mkProxyVhost {
    proxyPass = "http://127.0.0.1:${toString port}";
    extraConfig = forwardAuthHeaders;
  };
}
