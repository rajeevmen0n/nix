let
  users = import ../../../config/users.nix;
  domain = "icyfire.dev";
  wwwDomain = "www.${domain}";
  wireguardDomain = "wireguard.${domain}";
in {
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    acceptTerms = true;
    defaults.email = users.default.email;
    certs."${domain}".extraDomainNames = [wireguardDomain];
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
        locations."/" = {return = "404";};
      };

      "main" = {
        serverName = domain;
        serverAliases = [wwwDomain];
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
    };
  };
}
