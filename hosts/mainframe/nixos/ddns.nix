let
  users = import ../../../config/users.nix;
in {
  services.ddclient = {
    enable = true;
    usev4 = "webv4, webv4=dynamicdns.park-your-domain.com/getip";
    usev6 = "disabled";
    protocol = "namecheap";
    server = "dynamicdns.park-your-domain.com";
    username = "icyfire.dev";
    passwordFile = "/home/${users.default.username}/.config/.ddclient";
    domains = [ "@" "www" "wireguard" ];
  };
}
