{ config, ... }: {
  services.ddclient = {
    enable = true;
    usev4 = "webv4, webv4=dynamicdns.park-your-domain.com/getip";
    usev6 = "disabled";
    protocol = "namecheap";
    server = "dynamicdns.park-your-domain.com";
    username = "icyfire.dev";
    passwordFile = config.sops.secrets.ddclient.path;
    domains = [ "@" "www" "wireguard" "rummy" "headscale" "headplane" "auth" ];
  };
}
