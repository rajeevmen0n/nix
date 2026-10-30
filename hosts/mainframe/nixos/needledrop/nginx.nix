# nginx serves the built SPA directly and exposes only the API routes the game
# needs; the Rust API itself stays on loopback.
{ config, lib, pkgs, ... }:
let
  inherit (import ../domain.nix) domain subdomains;
  inherit (import ../lib.nix) autheliaAuthLocation autheliaProtectedConfig;
  app = import ./package.nix pkgs;
  host = subdomains.needledrop;

  # The API listens where the service says it does
  api = "http://${config.systemd.services.needledrop.environment.ND_BIND}";
  sections = [ "general" "pop" "rock" "hip-hop" ];

  static = {
    root = "${app.web}";
  };

  # One public route of the API. The location is exact and proxy_pass repeats
  # the path, so the server is sent the path nginx matched, not the one typed.
  route = methods: extraConfig: path: lib.nameValuePair "= ${path}" {
    proxyPass = "${api}${path}";
    extraConfig = ''
      if ($request_method !~ ^(${methods})$) { return 405; }
    '' + extraConfig;
  };
  limited = zone: burst: ''
    limit_req zone=${zone} burst=${toString burst} nodelay;
    limit_req_status 429;
    error_page 429 @needledrop_rate_limited;
  '';

  # Everything the game in the browser calls, and the health check. A route
  # added to the server is not public until it is added here.
  publicApi = lib.listToAttrs (
    map (route "GET|HEAD" "") (
      [ "/api/health" "/api/today" "/api/random" "/api/random/audio" ]
      ++ lib.concatMap (s: [ "/api/daily/${s}" "/api/daily/${s}/audio" ]) sections
    )
    ++ [
      (route "GET|HEAD" (limited "needledrop_search" 10) "/api/search")
      (route "DELETE" "" "/api/player")
      (route "POST" (limited "needledrop_guess" 14) "/api/random/guess")
      # Random mode: a new session and the next song each draw a song.
      (route "POST" (limited "needledrop_draw" 10) "/api/random/start")
      (route "POST" (limited "needledrop_draw" 10) "/api/random/next")
    ]
    ++ map (s: route "POST" (limited "needledrop_guess" 14) "/api/daily/${s}/guess") sections
  );
in
{
  # Per connecting address: searches, guesses and random mode's draws are
  # what cost Deezer requests, and all players share one budget of 40 per 5 s.
  # A draw is a track lookup and a preview download for a song not cached yet.
  services.nginx.appendHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=needledrop_search:10m rate=2r/s;
    limit_req_zone $binary_remote_addr zone=needledrop_guess:10m rate=1r/s;
    limit_req_zone $binary_remote_addr zone=needledrop_draw:10m rate=1r/s;
  '';

  services.nginx.virtualHosts.${host} = {
    forceSSL = true;
    useACMEHost = domain;

    locations = {
      "/internal/authelia/authz" = autheliaAuthLocation;

      "/" = static // {
        tryFiles = "$uri $uri/ /index.html";
      };

      # Admin pages: the SPA, behind Authelia
      "= /admin" = static // {
        tryFiles = "/index.html =404";
        extraConfig = autheliaProtectedConfig;
      };
      "^~ /admin/" = static // {
        tryFiles = "/index.html =404";
        extraConfig = autheliaProtectedConfig;
      };

      # Admin API, behind Authelia
      "= /api/admin" = {
        proxyPass = api;
        extraConfig = autheliaProtectedConfig;
      };
      "^~ /api/admin/" = {
        proxyPass = api;
        extraConfig = autheliaProtectedConfig;
      };

      # The rest of /api/ is not public. Both answers are in the API's own
      # error format, so the page can show the message.
      "/api/".extraConfig = ''
        default_type application/json;
        return 404 '{"error":"not_found","message":"There is nothing here."}';
      '';
      "@needledrop_rate_limited".extraConfig = ''
        default_type application/json;
        return 429 '{"error":"rate_limited","message":"Too many requests. Wait a moment and try again."}';
      '';
    } // publicApi;
  };
}
