{ lib, ...}:
{
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;

    limine = {
      enable = true;

      extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';

      secureBoot.enable = true;

      style.wallpapers = lib.mkForce [ ];

    };
  };
}
