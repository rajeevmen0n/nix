{pkgs, ...}: let
  users = import ../../config/users.nix;
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
          "network"
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
        "network" = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰈁";
          format-wifi = "{icon}";
          format-disconnected = "󰤮";
          tooltip = false;
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
      }
    ];

    style = ''
      @import '/home/${users.default.username}/.cache/wal/colors-waybar.css';

      /* Reset all styles */
      * {
      	border: none;
      	border-radius: 0;
      	min-height: 0;
      	margin: 0;
      	padding: 0;
      	box-shadow: none;
      	text-shadow: none;
      	icon-shadow: none;
      }

      #waybar {
          font-family: "JetBrainsMono Nerd Font";
      		font-size: 22px;
          background: rgba(40, 40, 40, 0.8784313725);
      }

      #window {
          padding: 0 10px;
      }

      window#waybar {
          border: none;
          border-radius: 0;
          box-shadow: none;
          text-shadow: none;
          transition-duration: 0s;
          color: @foreground;
          background: @background;
      }

      #workspaces {
          margin: 0;
      		margin-left: 3px;
      		padding: 0;
      		font-size: 16px;
      		border-radius: 4px;
      }

      #workspaces button {
          padding: 0px 5px;
      		margin: 3px;
      		border-radius: 4px;
          color: @color1;
      }

      #workspaces button.visible {
          color: @color2;
      }

      #workspaces button.active {
          color: @color2;
      }

      #workspaces button.urgent {
          background-color: @color3;
          color: white;
      }

      /* Repeat style here to ensure properties are overwritten as there's no !important and button:hover above resets the colour */

      #workspaces button.focused {
          color: @color2;
      }
      #workspaces button.focused:hover {
          color: @color3;
      }

      #tray,
      #mode,
      #battery,
      #temperature,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #backlight,
      #custom-media {
        padding: 0 8px;
        margin: 0 1px;
        color: @color1;
        border-radius: 6px 6px;
      }

      #battery.warning {
          color: rgba(255, 210, 4, 1);
      }

      #battery.critical {
          color: rgba(238, 46, 36, 1);
      }
    '';
  };
}
