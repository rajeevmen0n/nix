{pkgs, ...}: {

  security.polkit.enable = true;  

  environment = {
    sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    };

    systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      dconf
      xwayland
      kitty
      hyprland
    ];
  };

  programs.hyprland.enable = true;
}
