{ pkgs, lib, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "taj-ny";
    repo = "kwin-effects-forceblur";
    rev = "fea9f80f27389aa8a62befb5babf40b28fed328d";
    hash = "sha256-71cyYKUul9owRzbcObXkzhTBcmnXJsvmk1gq0RbP5PQ=c";
  };
  
  kwin-better-blur = pkgs.kdePackages.callPackage "${src}/package.nix" { };
in
{
  home.packages = [ kwin-better-blur ];
}
