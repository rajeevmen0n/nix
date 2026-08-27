{
  pkgs,
  ...
}:

let
  users = import ../../config/users.nix;
in
{

  nixpkgs.config.allowUnfree = true;

  users.users.${users.default.username} = {
    name = users.default.username;
    home = "/Users/${users.default.username}";
    shell = pkgs.zsh;
  };

  system = {
    stateVersion = 6;
    primaryUser = users.default.username;
    keyboard.enableKeyMapping = true;
    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        mineffect = "genie";
      };
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    casks = [
      "discord"
      "ghostty"
      "google-chrome"
      "spotify"
      "vlc"
      "vorssaint"
      "whatsapp"
    ];
  };
}
