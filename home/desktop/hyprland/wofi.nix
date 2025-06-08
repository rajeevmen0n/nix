let
  users = import ../../../config/users.nix;
in {
  programs.wofi = {
    enable = true;
    settings = {
      term = "ghostty";
      width = "15%";
      lines = 11;
      insensitive = true;
      matching = "fuzzy";
      show = "drun";
      allow_images = true;
      hide_scroll = true;
      no_actions = true;
    };
    style = ''
      @import '/home/${users.default.username}/.cache/wal/colors-waybar.css';
      * {
      	color: @foreground;
      	background: transparent;
      }

      #input {
      	border-radius: 0.75em;
      	border: 2px solid alpha(@color3, 0.3);
      	box-shadow: none;
      	background: alpha(@background, 0.8);
      }

      #outer-box {
      	padding: 10px;
      	border-radius: 0.75em;
      	border: 2px solid alpha(@color3, 0.3);
      	background: @background;
      }

      #scroll {
      	margin-top: 10px;
      }

      #image {
      	margin-right: 2px;
      	-gtk-icon-transform:scale(0.6);
      }

      #entry:selected {
      	border-radius: 0.25em;
      	background-color: alpha(@color4, 0.8);
      }

      #entry #text {
        padding: 0px 0px 0px 10px;
        font-weight: normal;
        color: @color7;
      }
    '';
  };
}
