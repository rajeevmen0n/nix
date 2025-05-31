{ pkgs, ... }:
let
  users = import ../../config/users.nix;
in
{
  imports = [
    ../../home/dev.nix
    ../../home/cli/btop.nix
    ../../home/desktop/hyprland.nix
    ../../home/desktop/gtk.nix
    ../../home/desktop/qt.nix
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "25.05";

    packages = with pkgs; [
      google-chrome
      vscode.fhs
    ];
  };

  wayland.windowManager.hyprland.settings = {
    # Set internal display resolution for hyprland
    monitor = [
      "eDP-1, 2560x1600@240, 0x0, 1"
      "eDP-2, 2560x1600@240, 0x0, 1"
    ];

    # Brightness controls
    bindl = [
      ",XF86MonBrightnessUp, exec, brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%-"
      ",code:230, exec, brightnessctl -d asus::kbd_backlight set 1+"
      ",code:229, exec, brightnessctl -d asus::kbd_backlight set 1-"
    ];
  };
}
