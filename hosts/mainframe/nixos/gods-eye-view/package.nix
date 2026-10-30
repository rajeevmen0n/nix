# God's Eye View, built from source: sources plus node_modules only. The browser
# bundle is built at service start (see default.nix) so the client-exposed keys
# never land in the store.
{ pkgs, nodejs }:

pkgs.buildNpmPackage {
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
}
