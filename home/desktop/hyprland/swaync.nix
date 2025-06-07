{lib, ...}: let
  users = import ../../../config/users.nix;
in {
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      cssPriority = "user";

      control-center-width = 380;
      control-center-height = 860;
      control-center-margin-top = 2;
      control-center-margin-bottom = 2;
      control-center-margin-right = 1;
      control-center-margin-left = 0;

      notification-window-width = 400;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;

      timeout = 4;
      timeout-low = 2;
      timeout-critical = 6;
      transition-time = 200;

      fit-to-screen = false;
      keyboard-shortcuts = true;
      script-fail-notify = true;

      image-visibility = "when-available";
      notification-visibility = {
        example-name = {
          state = "muted";
          urgency = "Low";
          app-name = "[Ss]potify";
        };
      };

      widgets = [
        "buttons-grid"
        "mpris"
        "title"
        "dnd"
        "label"
        "notifications"
      ];
      widget-config = {
        buttons-grid = {
          actions = [
            {
              label = " ";
              command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            }
            {
              label = "";
              command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            }
            {
              label = " ";
              command = "nm-connection-editor";
            }
            {
              label = "󰂯";
              command = "blueman-manager";
            }
            {
              label = "󰏘";
              command = "nwg-look";
            }
          ];
        };

        mpris = {
          image-size = 96;
          image-radius = 12;
        };

        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = " 󰎟 ";
        };

        dnd = {
          text = "Do not disturb";
        };

        label = {
          max-lines = 1;
          text = " ";
        };
      };
    };

    style = ''
      @import '/home/${users.default.username}/.cache/wal/colors-waybar.css';
      @import 'notifications.css';
      @import 'control-center.css';
    '';
  };

  xdg.configFile = {
    "swaync/notifications.css".source = ../../../config/swaync/notifications.css;
    "swaync/control-center.css".source = ../../../config/swaync/control-center.css;
  };

  systemd.user.services.swaync.Unit = {
    ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
  };
}
