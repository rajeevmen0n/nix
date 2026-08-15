{ config, ... }:
let
  domain = "icyfire.dev";
  headscaleDomain = "headscale.${domain}";
  headplaneDomain = "headplane.${domain}";
  authDomain = "auth.${domain}";
  lldapDomain = "ldap.${domain}";
in
{
  sops.secrets.cloudflare = {};

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@icyfire.dev";
    certs."${domain}" = {
      domain = domain;
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
        forceSSL = true;
        useACMEHost = domain;
      };

      "headscale" = {
        serverName = headscaleDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      "headplane" = {
        serverName = headplaneDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/internal/authelia/authz" = {
          extraConfig = ''
            internal;
            proxy_pass http://127.0.0.1:9091/api/authz/auth-request;
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Content-Length "";
            proxy_set_header Connection "";
          '';
        };
        locations."= /" = {
          return = "302 https://${headplaneDomain}/admin";
        };
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;
          extraConfig = ''
            auth_request /internal/authelia/authz;
            auth_request_set $target_url $scheme://$http_host$request_uri;
            error_page 401 =302 https://${authDomain}/?rd=$target_url;

            auth_request_set $user $upstream_http_remote_user;
            auth_request_set $groups $upstream_http_remote_groups;
            auth_request_set $name $upstream_http_remote_name;
            auth_request_set $email $upstream_http_remote_email;
            proxy_set_header Remote-User $user;
            proxy_set_header Remote-Groups $groups;
            proxy_set_header Remote-Name $name;
            proxy_set_header Remote-Email $email;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
          '';
        };
      };

      "auth" = {
        serverName = authDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9091";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-URI $request_uri;
            proxy_set_header X-Forwarded-Ssl on;
          '';
        };
      };

      "lldap" = {
        serverName = lldapDomain;
        useACMEHost = domain;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:17170";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-URI $request_uri;
            proxy_set_header X-Forwarded-Ssl on;
          '';
        };
      };
    };
  };
}
