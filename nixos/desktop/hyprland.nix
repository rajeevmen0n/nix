{pkgs, ...}: {

  security.polkit.enable = true;  

  environment = {
    systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      dconf
      xwayland
      wofi
      brightnessctl
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}