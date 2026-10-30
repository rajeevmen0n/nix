{ config, ... }:

let
  inherit (import ./domain.nix) domain subdomains ldapBaseDn;
  inherit (import ./lib.nix) forwardAuthHeaders mkProxyVhost;
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
      ldap_base_dn = ldapBaseDn;
      ldap_user_email = "admin@${domain}";
      ldap_user_pass_file = config.sops.secrets.lldap_user_pass.path;
      jwt_secret_file = config.sops.secrets.lldap_jwt_secret.path;

      http_host = "127.0.0.1";
      http_port = port;
      http_url = "https://${subdomains.ldap}";

      ldap_host = "127.0.0.1";
      ldap_port = ldapPort;
    };
  };

  services.nginx.virtualHosts.${subdomains.ldap} = mkProxyVhost {
    proxyPass = "http://127.0.0.1:${toString port}";
    extraConfig = forwardAuthHeaders;
  };
}
