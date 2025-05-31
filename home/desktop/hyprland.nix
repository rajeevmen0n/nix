{
  imports = [
    ./pywal.nix
    ./waybar.nix
    ./wofi.nix
    ./swaync.nix
    ./swww.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    settings = {
      # Monitors
      monitor = [ ",preferred,auto,auto" ];

      # Programs
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "pkill wofi || wofi --show drun";

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,breeze_cursors"
      ];

      # Input
      input = {
        touchpad = {
          natural_scroll = true;
        };
      };

      cursor = {
        no_hardware_cursors = true;
      };

      # Keybinds
      "$mod" = "ALT";

      bind = [
        # Basic keybinds
        "$mod, RETURN, exec, $terminal"
        "$mod, X, killactive"
        "$mod, M, exit"
        "$mod, E, exec, $fileManager"
        "$mod, F, toggleFloating"
        "$mod, SPACE, exec, $menu"
        "$mod, Tab, workspace, previous"
        "$mod, B, exec ,pkill -USR1 waybar"

        # Move focus
        "$mod, h, moveFocus, l"
        "$mod, j, moveFocus, d"
        "$mod, k, moveFocus, u"
        "$mod, l, moveFocus, r"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindl = [
        # Audio controls
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      windowrulev2 = [
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"

        "float, class:\.blueman-manager\-wrapped"
        "float, class:nm\-.*"
        "float, class:rog\-control\-center"
        "float, class:com\.saivert\.pwvucontrol"
      ];
    };
  };
}
