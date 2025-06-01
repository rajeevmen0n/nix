{pkgs, ...}: 
let 
  fluent-kde = pkgs.stdenv.mkDerivation {
    pname = "fluent-kvantum";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-kde";
      rev = "315251f3e0099fc7afa7ab183880141a478f584e";
      hash = "sha256-DBliFDKSAEFWqKtGvOzwKxNi3YK5VEbLzKa8byEUg1Y=";
    };

    installPhase = ''
      mkdir -p $out/share/Kvantum
      mkdir -p $out/share/color-schemes
      mkdir -p $out/share/aurorae/themes
      mkdir -p $out/share/plasma/desktoptheme
      mkdir -p $out/share/plasma/look-and-feel
      mkdir -p $out/share/wallpapers
      mkdir -p $out/share/plasma/plasmoids
      mkdir -p $out/share/plasma/layout-templates

      cp -r Kvantum/* $out/share/Kvantum/
      cp -r aurorae/* $out/share/aurorae/themes/
      cp -r plasma/desktoptheme/* $out/share/plasma/desktoptheme/
      cp -r plasma/look-and-feel/* $out/share/plasma/look-and-feel/
      cp -r wallpaper/* $out/share/wallpapers/
      cp -r color-schemes/*.colors $out/share/color-schemes/
      cp -r plasma/plasmoids/* $out/share/plasma/plasmoids/ || true
      cp -r plasma/layout-templates/* $out/share/plasma/layout-templates/ || true
    '';
  };
in {
  home.packages = with pkgs; [
    fluent-kde
  ];

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "kvantum";
  };

  xdg.configFile = {
    "Kvantum/FluentDark/FluentDark.kvconfig".source = "${fluent-kde}/share/Kvantum/Fluent/FluentDark.kvconfig";
    "Kvantum/FluentDark/FluentDark.svg".source = "${fluent-kde}/share/Kvantum/Fluent/FluentDark.svg";
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=FluentDark
    '';
  };
}
