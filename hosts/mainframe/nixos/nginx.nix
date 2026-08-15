{ config, ... }:

let
  domain = "icyfire.dev";
  authDomain = "auth.${domain}";

  # Reusable Authelia auth verification endpoint
  autheliaAuthLocation = {
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

  # Directives to protect a location with Authelia forward-auth
  autheliaProtectedConfig = ''
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
  '';

  # Extra headers for identity / auth endpoints
  forwardAuthHeaders = ''
    proxy_set_header X-Forwarded-URI $request_uri;
    proxy_set_header X-Forwarded-Ssl on;
  '';

  # Helper for standard SSL-enabled reverse proxy vhosts
  mkProxyVhost = {
    proxyPass,
    proxyWebsockets ? true,
    extraConfig ? "",
    extraLocations ? { },
  }: {
    forceSSL = true;
    useACMEHost = domain;
    locations = {
      "/" = {
        inherit proxyPass proxyWebsockets extraConfig;
      };
    } // extraLocations;
  };
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

      "headscale.${domain}" = mkProxyVhost {
        proxyPass = "http://127.0.0.1:8080";
      };

      "headplane.${domain}" = mkProxyVhost {
        proxyPass = "http://127.0.0.1:3000";
        extraConfig = autheliaProtectedConfig;
        extraLocations = {
          "/internal/authelia/authz" = autheliaAuthLocation;
          "= /".return = "302 https://headplane.${domain}/admin";
        };
      };

      "auth.${domain}" = mkProxyVhost {
        proxyPass = "http://127.0.0.1:9091";
        extraConfig = forwardAuthHeaders;
      };

      "ldap.${domain}" = mkProxyVhost {
        proxyPass = "http://127.0.0.1:17170";
        extraConfig = forwardAuthHeaders;
      };
    };
  };
}
