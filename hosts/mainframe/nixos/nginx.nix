# Shared web front door: nginx, the wildcard certificate and the firewall
# ports. Each service adds its own virtual host from its own module.
{ config, ... }:

let
  inherit (import ./domain.nix) domain;
in
{
  sops.secrets.cloudflare = {};

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${domain}";
    certs."${domain}" = {
      inherit domain;
      group = "nginx";
      extraDomainNames = [ "*.${domain}" ];
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare.path;
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "default" = {
        default = true;
        rejectSSL = true;
        locations."/".return = "404";
      };

      "${domain}" = {
        forceSSL = true;
        useACMEHost = domain;
      };
    };
  };
}
