{ pkgs, ... }: let
  acpiOverrideDrv = pkgs.runCommand "acpi-override" {
    nativeBuildInputs = [ pkgs.acpica-tools pkgs.cpio pkgs.patch ];
  } ''
    set -euxo pipefail

    mkdir -p $out/kernel/firmware/acpi
    cd $out
    cp ${./dsdt.dat} ./dsdt.dat

    # Decompile to DSL
    iasl -d dsdt.dat

    # Apply patch
    patch < ${./dsdt.patch}

    # Recompile
    iasl -tc -ve dsdt.dsl

    # Copy the AML into kernel firmware structure
    cp dsdt.aml kernel/firmware/acpi/

    # Create CPIO archive
    find kernel | cpio -H newc --create > dsdt_override
  '';
in {
  boot.initrd.prepend = [ "${acpiOverrideDrv}/dsdt_override" ];
}
