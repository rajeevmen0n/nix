let
  hosts = import ../../config/hosts.nix;
  users = import ../../config/users.nix;
in {
  imports = [
    ../../nixos/base.nix
    ../../nixos/system/users.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "${users.default.username}";

  networking.hostName = hosts.ga605wi-wsl.hostname;

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  hardware.graphics.enable = true;

  wsl.useWindowsDriver = true;

  system.stateVersion = "26.05";
}
