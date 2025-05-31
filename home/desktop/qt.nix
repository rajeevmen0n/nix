{pkgs, ...}: {
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "Breeze";
  };
  xdg.configFile."qt5ct/colors.conf".text = ''
    [ColorScheme]
    name=BreezeDark
  '';

  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=Breeze
    color_scheme_path=${pkgs.libsForQt5.breeze-qt5}/share/color-schemes/BreezeDark.colors
  '';
  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.breeze-qt5
    libsForQt5.qt5ct
  ];
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
