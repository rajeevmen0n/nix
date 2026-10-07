{ lib, pkgs, ... }:
let
  app = import ./needledrop-package.nix pkgs;
  stateDir = "/var/lib/needledrop";
  host = "needledrop.icyfire.dev";

  static = {
    proxyPass = lib.mkForce null;
    proxyWebsockets = lib.mkForce false;
    root = "${app.web}";
  };

  api = "http://127.0.0.1:4810";
  sections = [ "general" "pop" "rock" "hip-hop" ];

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
  users.groups.needledrop = { };
  users.users.needledrop = {
    isSystemUser = true;
    group = "needledrop";
    home = stateDir;
  };

  systemd.services.needledrop = {
    description = "Needledrop song game API";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      ND_BIND = "127.0.0.1:4810";
      ND_DATA_DIR = stateDir;
      ND_PUBLIC_URL = "https://${host}";
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };

    serviceConfig = {
      Type = "simple";
      User = "needledrop";
      Group = "needledrop";
      StateDirectory = "needledrop";
      StateDirectoryMode = "0700";
      WorkingDirectory = stateDir;
      ExecStart = "${app.server}/bin/needledrop-server";
      Restart = "on-failure";
      RestartSec = 5;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # Per connecting address: searches, guesses and random mode's draws are
  # what cost Deezer requests, and all players share one budget of 40 per 5 s.
  # A draw is a track lookup and a preview download for a song not cached yet.
  services.nginx.appendHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=needledrop_search:10m rate=2r/s;
    limit_req_zone $binary_remote_addr zone=needledrop_guess:10m rate=1r/s;
    limit_req_zone $binary_remote_addr zone=needledrop_draw:10m rate=1r/s;
  '';

  # The existing virtual host supplies TLS and protects the admin paths.
  # Serve the built SPA directly from nginx instead of keeping Vite running.
  services.nginx.virtualHosts.${host}.locations = {
    "/" = static // {
      tryFiles = "$uri $uri/ /index.html";
    };
    "= /admin" = static // {
      tryFiles = "/index.html =404";
    };
    "^~ /admin/" = static // {
      tryFiles = "/index.html =404";
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
}
