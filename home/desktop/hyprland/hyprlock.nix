{pkgs, ...}: let
  users = import ../../../config/users.nix;
  screenlock = pkgs.writeShellScriptBin "screen-lock" ''
    grim -s 1.5 -l 0 /home/${users.default.username}/.cache/screenlock.png
    ${pkgs.hyprlock}/bin/hyprlock
  '';
in {
  home.packages = with pkgs; [
    grim
    screenlock
  ];

  programs.hyprlock = {
    enable = true;

    settings = {
      source = "/home/${users.default.username}/.cache/wal/colors-hyprland.conf";
      background = {
        monitor = "";
        path = "/home/${users.default.username}/.cache/screenlock.png";

        blur_size = 4;
        blur_passes = 3;
        noise = 0.0117;
        contrast = 1.3000;
        brightness = 0.8000;
        vibrancy = 0.2100;
        vibrancy_darkness = 0.0;
      };

      # Hours
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<b><big> $(date +\"%H\") </big></b>\"";
          color = "$color6";
          font_size = 112;
          font_family = "JetBrainsMono Nerd Font 10";
          shadow_passes = 3;
          shadow_size = 4;

          position = "0, 220";
          halign = "center";
          valign = "center";
        }

        # Minutes
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<b><big> $(date +\"%M\") </big></b>\"";
          color = "$color6";
          font_size = 112;
          font_family = "JetBrainsMono Nerd Font 10";
          shadow_passes = 3;
          shadow_size = 4;

          position = "0, 80";
          halign = "center";
          valign = "center";
        }

        # Today
        {
          monitor = "";
          text = "cmd[update:18000000] echo \"<b><big> \"$(date +'%A')\" </big></b>\"";
          color = "$color7";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font 10";

          position = "0, -50";
          halign = "center";
          valign = "center";
        }

        # Week
        {
          monitor = "";
          text = "cmd[update:18000000] echo \"<b> \"$(date +'%d %b')\" </b>\"";
          color = "$color7";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font 10";

          position = "0, -80";
          halign = "center";
          valign = "center";
        }

        # Degrees
        {
          monitor = "";
          text = "cmd[update:18000000] echo \"<b>Feels like<big> $(curl -s 'wttr.in?format=%t' | tr -d '+') </big></b>\"";
          color = "$color7";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font 10";

          position = "0, 40";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 3;

        dots_size = 0.26;
        dots_spacing = 0.64;
        dots_center = true;
        dots_rounding = -1;

        rounding = 22;
        outer_color = "$color0";
        inner_color = "$color0";
        font_color = "$color6";
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";

        position = "0, 120";
        halign = "center";
        valign = "bottom";
      };
    };
  };
}
