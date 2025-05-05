{pkgs, ...}: {

  security.polkit.enable = true;  

  environment = {
    systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      dconf
      xwayland
      wofi
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
