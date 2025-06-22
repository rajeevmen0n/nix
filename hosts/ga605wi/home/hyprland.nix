{

  wayland.windowManager.hyprland.settings = {
    # Set internal display resolution for hyprland
    monitor = [
      "eDP-1, 2560x1600@240, auto, 1"
      "eDP-2, 2560x1600@240, auto, 1"
      "DP-1, 3440x1440@174.96, auto, 1"
      "DP-2, 3440x1440@174.96, auto, 1"
    ];

    device = [
      {
        name = "asuf1209:00-2808:0219-touchpad";
        accel_profile = "adaptive";
      }
      {
        name = "logitech-g305-1";
        accel_profile = "flat";
      }
    ];

    cursor = {
      no_hardware_cursors = true;
    };

    # Brightness controls
    bindl = [
      ",XF86MonBrightnessUp, exec, brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%-"
      ",XF86KbdBrightnessUp, exec, brightnessctl -d asus::kbd_backlight set 1+"
      ",XF86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set 1-"
      ",XF86Launch3, exec, asusctl aura -n"
      ",switch:on:Lid Switch, exec, lid-handler close"
      ",switch:off:Lid Switch, exec, lid-handler open"
    ];
  };

  services.hypridle.settings.listener = [
    # Turn down brightness
    {
      timeout = 150;
      on-timeout = "brightnessctl -d amdgpu_bl1 -s set 10";
      on-resume = "brightnessctl -d amdgpu_bl1 -r";
    }

    # Turn down keyboard brightness
    {
      timeout = 150;
      on-timeout = "brightnessctl -d asus::kbd_backlight -s set 0";
      on-resume = "brightnessctl -d asus::kbd_backlight -r";
    }
  ];
}
