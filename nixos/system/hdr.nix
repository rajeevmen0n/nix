{pkgs, ...}: let
  users = import ../../config/users.nix;
  home = "/home/${users.default.username}";
in {
  system.activationScripts.createHdrSh = ''
    PLASMA_ENV="${home}/.config/plasma-workspace/env/hdr.sh"
    mkdir -p $(dirname $PLASMA_ENV)
    echo 'export KWIN_FORCE_ASSUME_HDR_SUPPORT=1' > $PLASMA_ENV
  '';

  programs.steam.gamescopeSession.enable = true;
  programs.gamescope = {
    args = ["--hdr-enabled"];
    env = {
      DRI_PRIME = "1";
      DXVK_HDR = "1";
      ENABLE_GAMESCOPE_WSI = "1";
    };
  };

  environment.systemPackages = with pkgs; [
    mpv
    gamescope-wsi
    vulkan-hdr-layer-kwin6
  ];
}
