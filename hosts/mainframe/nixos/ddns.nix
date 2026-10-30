# Dynamic DNS for the zone. Each service appends its own hostname to
# services.ddclient.domains from its own module.
{ config, pkgs, ... }:

let
  inherit (import ./domain.nix) domain subdomains;
in
{
  environment.systemPackages = [ pkgs.ddclient ];

  sops.secrets.cloudflare = {};

  services.ddclient = {
    enable = true;
    usev4 = "webv4, webv4=https://api.ipify.org";
    usev6 = "disabled";
    protocol = "cloudflare";
    zone = domain;
    username = "token";
    passwordFile = config.sops.secrets.cloudflare.path;
    # TODO(refactor): these move into their service modules.
    domains = with subdomains; [ domain needledrop ];
  };
}
