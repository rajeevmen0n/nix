{pkgs, ...}: {
  imports = [
    ./server.nix
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Basic tools
  environment.systemPackages = with pkgs; [
    google-chrome
    pciutils
    powertop
    sbctl
  ];
}
