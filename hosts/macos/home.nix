{ lib, ... }:

let
  users = import ../../config/users.nix;
in
{
  imports = [
    ../../home/ai.nix
    ../../home/shell.nix
    ../../home/fonts.nix
    ../../home/apps/ghostty.nix
  ];

  # Ghostty isn't buildable on darwin from nixpkgs — installed via Homebrew
  # cask instead. package = null generates config without installing anything.
  programs.ghostty.package = lib.mkForce null;

  home = {
    username = users.default.username;
    homeDirectory = "/Users/${users.default.username}";
    stateVersion = "26.05";
  };
}
