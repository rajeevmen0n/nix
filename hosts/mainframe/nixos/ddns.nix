{ config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.ddclient ];

  sops.secrets.cloudflare = {};

  services.ddclient = {
    enable = true;
    usev4 = "webv4, webv4=https://api.ipify.org";
    usev6 = "disabled";
    protocol = "cloudflare";
    zone = "icyfire.dev";
    username = "token";
    passwordFile = config.sops.secrets.cloudflare.path;
    domains = [ "icyfire.dev" "headscale.icyfire.dev" ];
  };
}
