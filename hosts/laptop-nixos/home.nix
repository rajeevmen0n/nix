{ pkgs, ... }:
let
  users = import ../../config/users.nix;
in
{
  imports = [
    ../../home/dev.nix
    ../../home/cli/btop.nix
    ../../home/gui/hyprland.nix
    ../../home/gui/gtk.nix
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      google-chrome
      vscode.fhs
    ];

    # Multi-GPU fix for hyprland
    file.".config/uwsm/env-hyprland".text = ''
      export AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
      export AQ_NO_ATOMIC=1
    '';
  };

  # Set internal display resolution for hyprland
  wayland.windowManager.hyprland.settings.monitor = [ "eDP-1, 2560x1600@240, 0x0, 1" ];
}
