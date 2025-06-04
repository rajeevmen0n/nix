{ pkgs, ... }:
let
  users = import ../../config/users.nix;
in
{
  imports = [
    ../../home/dev.nix
    ../../home/cli/btop.nix
    ../../home/desktop/gtk.nix
    ../../home/desktop/hyprland/hyprland.nix
    ../../home/desktop/plasma/kwin-forceblur.nix
    ../../home/desktop/plasma/plasma.nix
    ../../home/desktop/qt.nix
    ../../home/apps/media.nix
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "25.05";
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

  programs.plasma = {
    enable = true;
    input = {
      mice = [
        {
          name = "Logitech G305";
          enable = true;
          accelerationProfile = "none";
          naturalScroll = false;
          vendorId = "046d";
          productId = "4074";
        }
      ];
      touchpads = [
        {
          name = "ASUF1209:00 2808:0219 Touchpad";
          enable = true;
          naturalScroll = true;
          vendorId = "2808";
          productId = "0219";
        }
      ];
    };
  };
}
