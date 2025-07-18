let
  users = import ../../config/users.nix;
in {
  imports = [
    ../../home/shell.nix
    ../../home/cli/btop.nix
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "25.05";
  };
}
