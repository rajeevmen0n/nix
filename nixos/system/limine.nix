{ lib, ...}:
{
  boot.loader = {
    efi.canTouchEfiVariables = true;

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
