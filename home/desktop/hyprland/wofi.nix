let
  users = import ../../../config/users.nix;
in {
  programs.wofi = {
    enable = true;
    style = ''
      @import '/home/${users.default.username}/.cache/wal/colors-waybar.css';

      *{
        border: none;
        box-shadow: none;
        outline: none;
      }

      window {
        font-size: 14px;
        font-family: "JetBrains Mono";
        background-color: @background;
        border-radius: 8px;
      }

      #outer-box {
        margin: 10px 10px 20px 10px;
        background-color: @background;
      }

      #inner-box {
        margin: 10px;
        background-color: @background;
      }

      #entry {
        padding: 5px 10px;
        border-radius: 20px;
      }

      #entry #text {
        padding: 0px 0px 0px 10px;
        font-weight: normal;
        color: @color7;
      }

      #entry:selected {
        background-color: @color4;
      }

      #entry:selected #text {
        padding: 0px 0px 0px 10px;
        font-weight: normal;
        color: @color0;
      }

      #input {
        background: transparent;
        margin: 0px 5px 0px 20px;
        color: @color7;
        padding: 5px;
      }

      #image {
        margin-left: 20px;
        margin-right: 20px;
      }

      #scroll {
        margin: 0px;
      }
    '';
  };
}
