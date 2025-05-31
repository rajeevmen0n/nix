{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.kdePackages.breeze-icons;
    name = "breeze_cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.fluent-gtk-theme;
      name = "Fluent-Dark";
    };

    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "breeze-dark";
    };

    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 10;
    };
  };

  home.packages = with pkgs; [
    nwg-look
    fluent-gtk-theme
  ];
}
