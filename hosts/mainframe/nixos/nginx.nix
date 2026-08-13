let
  users = import ../../../config/users.nix;
  domain = "icyfire.dev";
  wwwDomain = "www.${domain}";
  wireguardDomain = "wireguard.${domain}";
  rummyDomain = "rummy.${domain}";
  headscaleDomain = "headscale.${domain}";
  headplaneDomain = "headplane.${domain}";
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = users.default.email;
    certs."${domain}".extraDomainNames = [
      wireguardDomain
      rummyDomain
      headscaleDomain
      headplaneDomain
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "default" = {
        default = true;
        serverName = "_";
        addSSL = true;
        useACMEHost = domain;
        extraConfig = "ssl_reject_handshake on;";
        locations."/" = {
          return = "404";
        };
      };

      "main" = {
        serverName = domain;
        serverAliases = [ wwwDomain ];
        forceSSL = true;
        enableACME = true;
      };

      "wg-easy" = {
        serverName = wireguardDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:51821";
        };
      };

      "rummy" = {
        serverName = rummyDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3100";
          proxyWebsockets = true;
        };
      };

      "headscale" = {
        serverName = headscaleDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };

      "headplane" = {
        serverName = headplaneDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."= /" = {
          return = "302 https://${headplaneDomain}/admin";
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
        };
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
        '';
      };
    };
  };
}
