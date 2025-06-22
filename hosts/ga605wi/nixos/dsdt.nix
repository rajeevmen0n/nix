{ pkgs, ... }: let
  acpiOverrideDrv = pkgs.runCommand "acpi-override" {} ''
    mkdir -p $out
    cp ${./dsdt-upgrade.cpio} $out/dsdt_override
  '';
in {
  boot.initrd.prepend = [ "${acpiOverrideDrv}/dsdt_override" ];
}