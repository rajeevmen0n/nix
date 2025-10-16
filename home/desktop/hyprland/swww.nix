{ pkgs, lib, ... }:
let
  changeWallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    if [ -n "$1" ]; then
      WALLPAPER="$1"
    else
      WALLPAPER=$(find /mnt/files/wallpapers -type f | shuf -n 1)
    fi
    ${pkgs.pywal}/bin/wal -i $WALLPAPER
    ${pkgs.swww}/bin/swww img --transition-type wipe --transition-angle 30 --transition-step 90 $WALLPAPER
    systemctl --user restart waybar.service
  '';
in
{
  services.swww.enable = true;

  home.packages = [
    changeWallpaper
  ];

  systemd.user.services.swww.Unit = {
    ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
  };
}
