{pkgs, lib, ...}: let
  users = import ../../../config/users.nix;
in {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [
          "clock"
        ];
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "tray"
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "custom/swaync"
        ];

        "hyprland/workspaces" = {
          active-only = false;
          show-special = false;
          all-outputs = false;
          disable-scroll = true;
          format = "{icon}";
          format-icons = {
            default = "○";
            active = "";
            urgent = "!";
          };
          persistent-workspaces = {
            "*" = 10;
          };
        };

        "clock" = {
          format = ''  {:L%H:%M}'';
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };

        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };

        "memory" = {
          interval = 10;
          format = " {}%";
          tooltip = true;
        };

        "cpu" = {
          interval = 10;
          format = " {usage:2}%";
          tooltip = true;
        };

        "disk" = {
          format = " {free}";
          tooltip = true;
        };

        "tray" = {
          spacing = 20;
          icon-size = 16;
          show-passive-items = true;
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{volume}% {icon} ";
          format-bluetooth-muted = "󰝟 {icon} ";
          format-muted = "󰍭 {format_source} ";
          format-source = " {volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "sleep 0.1 && pwvucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = true;
        };

        "custom/swaync" = {
          tooltip = true;     
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };
      }
    ];

    style = ''
      @import '/home/${users.default.username}/.cache/wal/colors-waybar.css';
      @import 'waybar.css';
    '';
  };

  xdg.configFile = {
    "waybar/waybar.css".source = ../../../config/waybar/waybar.css;
  };

  systemd.user.services.waybar.Unit = {
    ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
  };
}
