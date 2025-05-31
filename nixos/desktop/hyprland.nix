{pkgs, ...}: {

  security.polkit.enable = true;  

  environment = {
    systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      dconf
      xwayland
      brightnessctl
      networkmanagerapplet
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.blueman.enable = true;
}
