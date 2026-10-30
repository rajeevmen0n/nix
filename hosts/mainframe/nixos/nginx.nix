# Shared web front door: nginx, the wildcard certificate and the firewall
# ports. Each service adds its own virtual host from its own module.
{ config, ... }:

let
  inherit (import ./domain.nix) domain subdomains;
  inherit (import ./lib.nix)
    autheliaAuthLocation
    autheliaProtectedConfig
    mkProxyVhost
    ;
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

      # TODO(refactor): the vhosts below move into their service modules.
      # Needledrop: nginx serves the built SPA; the Rust API stays on loopback.
      # The public API routes and their rate limits are in needledrop.nix.
      "${subdomains.needledrop}" = mkProxyVhost {
        proxyPass = "http://127.0.0.1:4811";
        extraLocations = {
          "/internal/authelia/authz" = autheliaAuthLocation;
          "= /admin" = {
            proxyPass = "http://127.0.0.1:4811";
            proxyWebsockets = true;
            extraConfig = autheliaProtectedConfig;
          };
          "^~ /admin/" = {
            proxyPass = "http://127.0.0.1:4811";
            proxyWebsockets = true;
            extraConfig = autheliaProtectedConfig;
          };
          "= /api/admin" = {
            proxyPass = "http://127.0.0.1:4810";
            extraConfig = autheliaProtectedConfig;
          };
          "^~ /api/admin/" = {
            proxyPass = "http://127.0.0.1:4810";
            extraConfig = autheliaProtectedConfig;
          };
        };
      };
    };
  };
}
