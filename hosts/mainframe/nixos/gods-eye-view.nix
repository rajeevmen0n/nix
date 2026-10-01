{ config, pkgs, ... }:
let
  domain = "gev.icyfire.dev";
  port = 4173;
  stateDir = "/var/lib/gods-eye-view";
  nodejs = pkgs.nodejs_24;

  # Source + node_modules only. The browser bundle is built at service start so
  # the client-exposed keys (Google Maps / Cesium ion) never land in the store.
  gev = pkgs.buildNpmPackage {
    pname = "gods-eye-view";
    version = "0.1.1-unstable-2026-09-30";

    src = pkgs.fetchFromGitHub {
      owner = "bilawalsidhu";
      repo = "gods-eye-view";
      rev = "e7707d9a0f34d9fbffc300023c319f95caa5be30";
      hash = "sha256-VjnHrEg59Ew7fi76oeD/Mx4Tj0Z0yc/6ERL2Ysrooww=";
    };

    inherit nodejs;
    npmDepsHash = "sha256-PeShSMMyOhkQlnnAFt5Fo0LzP5/0+tcjsCwfLtpaFIc=";

    env.PUPPETEER_SKIP_DOWNLOAD = "1";

    # vite is a devDependency and is needed at runtime
    dontNpmBuild = true;
    dontNpmPrune = true;

    installPhase = ''
      runHook preInstall
      rm -rf docs/media
      mkdir -p $out/lib
      cp -r . $out/lib/gods-eye-view
      runHook postInstall
    '';
  };

  appDir = "${gev}/lib/gods-eye-view";
  # native loader: the config is plain ESM, and the default loader writes a
  # temp file next to it, which the read-only store refuses
  vite = "${nodejs}/bin/node ${appDir}/node_modules/vite/bin/vite.js";
  viteArgs = "--configLoader native --outDir ${stateDir}/dist";
in {
  # Provider keys, kept as one dotenv file: `sops hosts/mainframe/secrets/gev.env`
  sops.secrets.gev-env = {
    sopsFile = ../secrets/gev.env;
    format = "dotenv";
    key = "";
    restartUnits = [ "gods-eye-view.service" ];
  };

  # The app has no standalone server: its API proxies are Vite plugins, so the
  # built bundle is served with `vite preview`
  systemd.services.gods-eye-view = {
    description = "God's Eye View";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.coreutils ];

    environment = {
      HOME = stateDir;
      HOST = "127.0.0.1";
      PORT = toString port;
      # Vite only accepts local hostnames by default
      __VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS = domain;
      OPENSKY_AUTH_MODE = "anon";
      # nginx is the only peer the app sees, so these act as global ceilings
      GEV_RATELIMIT_OPENAI_PER_MIN = "30";
      GEV_RATELIMIT_GOOGLE_PER_MIN = "60";
    };

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "gods-eye-view";
      # Provider caches (.gev-cache) are written relative to the cwd
      WorkingDirectory = stateDir;

      EnvironmentFile = config.sops.secrets.gev-env.path;

      # Rebuild the bundle only when the package or a browser key changes
      ExecStartPre = pkgs.writeShellScript "gods-eye-view-build" ''
        set -eu
        stamp="${gev} $(printf '%s' "''${GOOGLE_MAPS_API_KEY:-}|''${CESIUM_ION_TOKEN:-}" | sha256sum | cut -d' ' -f1)"
        if [ -f ${stateDir}/dist/cesium/Cesium.js ] && [ "$(cat ${stateDir}/.build-stamp 2>/dev/null)" = "$stamp" ]; then
          exit 0
        fi
        rm -f ${stateDir}/.build-stamp
        # The Cesium runtime is copied out of the store with its read-only
        # modes, which vite cannot clear on its own
        if [ -d ${stateDir}/dist ]; then
          chmod -R u+w ${stateDir}/dist
          rm -rf ${stateDir}/dist
        fi
        # vite-plugin-cesium copies the Cesium runtime from a cwd-relative
        # node_modules and mangles an absolute outDir when a root is passed,
        # so build from inside the app dir instead
        cd ${appDir}
        ${vite} build ${viteArgs} --emptyOutDir
        # the plugin only logs a failed copy
        if [ ! -f ${stateDir}/dist/cesium/Cesium.js ]; then
          echo "Cesium runtime missing from the bundle" >&2
          exit 1
        fi
        printf '%s' "$stamp" > ${stateDir}/.build-stamp
      '';
      TimeoutStartSec = "20min";

      ExecStart = "${vite} preview ${appDir} ${viteArgs} --host 127.0.0.1 --port ${toString port} --strictPort";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
