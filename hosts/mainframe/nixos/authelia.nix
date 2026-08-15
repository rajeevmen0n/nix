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

  sops.secrets."authelia_oidc_hmac_secret" = {
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

  sops.secrets."authelia_oidc_issuer_private_key" = {
    owner = config.services.authelia.instances.main.user;
    group = config.services.authelia.instances.main.group;
  };

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

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = [ "headplane.${domain}" ];
            subject = [ ["group:lldap_admin"] ["user:admin"] ];
            policy = "one_factor";
          }
          {
            domain = [ "headplane.${domain}" ];
            policy = "deny";
          }
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
        ldap = {
          implementation = "lldap";
          address = "ldap://127.0.0.1:3890";
          base_dn = "dc=ldap,dc=icyfire,dc=dev";
          user = "uid=admin,ou=people,dc=ldap,dc=icyfire,dc=dev";
        };
      };

      identity_providers = {
        oidc = {
          cors = {
            endpoints = [ "authorization" "token" "revocation" "introspection" "userinfo" ];
            allowed_origins_from_client_redirect_uris = true;
          };
 
          clients = [
            {
              client_id = "headscale";
              client_name = "Headscale";
              client_secret = "$pbkdf2-sha512$310000$ncYx0TRFSofvssJKZHc/dQ$ISpBlSFuE3tGANyVhZzL0ELTv0s8FIjGFo6J/SqE/0n1OkZPqJPlHCqbBgAHeJzhaRAhHXSWok6.MsP6HnVdZg";
              authorization_policy = "one_factor";
              require_pkce = true;
              pkce_challenge_method = "S256";
              redirect_uris = [
                "https://headscale.${domain}/oidc/callback"
              ];
              scopes = [ "openid" "profile" "email" "groups" ];
            }
            {
              client_id = "headplane";
              client_name = "Headplane";
              client_secret = "$pbkdf2-sha512$310000$YUphTm7Ul5jE1pnkcSbjJA$N6UZKR4MERopfUDJR5IVutOGrpawq02CEKH2r1GxfR9HvOzoE1ML3/wPWqgrC0BaMy2Fx/ggWvqbJgXdA4gu.w";
              authorization_policy = "one_factor";
              token_endpoint_auth_method = "client_secret_post";
              redirect_uris = [
                "https://headplane.${domain}/admin/oidc/callback"
              ];
              scopes = [ "openid" "profile" "email" ];
            }
          ];
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
