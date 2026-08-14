{ config, ... }:

let
  domain = "icyfire.dev";
  lldapDomain = "ldap.${domain}";
  port = 17170;
  ldapPort = 3890;
in
{
  sops.secrets."lldap_jwt_secret" = {
    mode = "0444";
  };

  sops.secrets."lldap_user_pass" = {
    mode = "0444";
  };

  services.lldap = {
    enable = true;
    silenceForceUserPassResetWarning = true;

    settings = {
      ldap_base_dn = "dc=ldap,dc=icyfire,dc=dev";
      ldap_user_email = "admin@${domain}";
      ldap_user_pass_file = config.sops.secrets.lldap_user_pass.path;
      jwt_secret_file = config.sops.secrets.lldap_jwt_secret.path;

      http_host = "127.0.0.1";
      http_port = port;
      http_url = "https://${lldapDomain}";

      ldap_host = "127.0.0.1";
      ldap_port = ldapPort;
    };
  };
}
