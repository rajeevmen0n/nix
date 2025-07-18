let
  users = import ../../config/users.nix;
in {
  imports = [
    ./home/hyprland.nix
    ./home/plasma.nix

    ../../home/apps/media.nix
    ../../home/apps/minecraft.nix
    ../../home/dev.nix
    ../../home/fonts.nix
    ../../home/cli/btop.nix
    ../../home/desktop/gtk.nix
    ../../home/desktop/hyprland/hyprland.nix
    ../../home/desktop/plasma/kwin-forceblur.nix
    ../../home/desktop/plasma/plasma.nix
    ../../home/desktop/qt.nix
  ];

  home = {
    username = users.default.username;
    homeDirectory = "/home/${users.default.username}";
    stateVersion = "25.05";
  };
}
