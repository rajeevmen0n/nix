pkgs:
let
  rev = "ec2dff7af8c6b9f9c8ca9aaec4fc60757a9bf942";
  src = pkgs.fetchFromGitHub {
    owner = "rajeevmen0n";
    repo = "needledrop";
    inherit rev;
    hash = "sha256-rvicZ4fVFSnf5fF65wz7juVQkTdU1d4DuRXyLslr0AA=";
  };

  server = pkgs.rustPlatform.buildRustPackage {
    pname = "needledrop-server";
    version = "0.1.0-${builtins.substring 0 7 rev}";
    inherit src;
    cargoRoot = "server";
    buildAndTestSubdir = "server";
    cargoLock.lockFile = "${src}/server/Cargo.lock";
    env.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  web = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "needledrop-web";
    version = "0.1.0-${builtins.substring 0 7 rev}";
    inherit src;
    sourceRoot = "${src.name}/web";

    nativeBuildInputs = [
      pkgs.nodejs_24
      pkgs.pnpm
      pkgs.pnpmConfigHook
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src sourceRoot;
      pnpm = pkgs.pnpm;
      fetcherVersion = 3;
      hash = "sha256-zeVFIWW4B48ygUz6u+0cyQV3VEIRAHRBtQ1pKoti0Fs=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/. $out/
      runHook postInstall
    '';
  });
in
{
  inherit rev src server web;
}
