{ pkgs, ... }:
let
  users = import ../../../config/users.nix;

  rummySrc = pkgs.fetchFromGitHub {
    owner = "rajeevmen0n";
    repo = "rummy";
    rev = "000552cbcc9d4bc7d65ae8cdac4a296afe56fb6e";
    hash = "sha256-l9qDi+ca6xRRpTg7/xQyoY/gAIk0xkiZNJTER4xZevg=";
  };
in {
  # Persistent data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/rummy 0755 root root - -"
  ];

  # Systemd service to run the app on the host
  systemd.services.rummy = {
    description = "Rummy Scorekeeper Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.nodejs_20 pkgs.git pkgs.python3 pkgs.gnumake pkgs.gcc pkgs.bash pkgs.coreutils ];

    environment = {
      NODE_ENV = "production";
      PORT = "3100";
      DATABASE_PATH = "/var/lib/rummy/rummy.db";
      NEXT_TELEMETRY_DISABLED = "1";
    };

    serviceConfig = {
      Type = "simple";
      User = "root";
      WorkingDirectory = "/var/lib/rummy";

      # Copy source from Nix store to /var/lib/rummy/app on start to allow npm to write
      # Then build and start
      ExecStartPre = pkgs.writeShellScript "rummy-setup" ''
        mkdir -p /var/lib/rummy/app
        cp -rT ${rummySrc}/ /var/lib/rummy/app/
        chmod -R u+w /var/lib/rummy/app/
        cd /var/lib/rummy/app
        npm ci
        npm run build
      '';

      ExecStart = "${pkgs.nodejs_20}/bin/npm --prefix app run start";
      Restart = "always";

      # Load API Key from environment file
      EnvironmentFile = "/home/${users.default.username}/.config/.gemini-api-key";
    };
  };
}

