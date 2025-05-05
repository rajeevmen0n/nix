{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.14.2";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  patches-src = fetchFromGitHub {
    owner = "flukejones";
    repo = "cachyos-kernel-patches";
    rev = "4df02d6037a2ea9ac1dc67f80db59798117694f1";
    hash = "sha256-VM7JHbkYpjQGmVcnrshfVwKWfkA1rpt8e4rQZHIr9pY=";
  };
in
  buildLinux (
    args
    // {
      inherit version;
      pname = "linux-rog";
      modDirVersion = version;
      src = fetchurl {
        url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
        hash = "sha256-xcaCo1TqMZATk1elfTSnnlw3IhrOgjqTjhARa1d6Lhs=";
      };
      kernelPatches = [
        {
          name = "amd-pstate";
          patch = "${patches-src}/${majorMinor}/0001-amd-pstate.patch";
        }
        {
          name = "amd-tlb-broadcast";
          patch = "${patches-src}/${majorMinor}/0002-amd-tlb-broadcast.patch";
        }
        {
          name = "asus";
          patch = "${patches-src}/${majorMinor}/0003-asus.patch";
        }
        {
          name = "bbr3";
          patch = "${patches-src}/${majorMinor}/0004-bbr3.patch";
        }
        {
          name = "cachy";
          patch = "${patches-src}/${majorMinor}/0005-cachy.patch";
        }
        {
          name = "crypto";
          patch = "${patches-src}/${majorMinor}/0006-crypto.patch";
        }
        {
          name = "fixes";
          patch = "${patches-src}/${majorMinor}/0007-fixes.patch";
        }
        {
          name = "t2";
          patch = "${patches-src}/${majorMinor}/0008-t2.patch";
        }
        {
          name = "zstd";
          patch = "${patches-src}/${majorMinor}/0009-zstd.patch";
        }
        {
          name = "zotac-zone";
          patch = "${patches-src}/${majorMinor}/0010-zotac-zone.patch";
        }
        {
          name = "bore-cachy";
          patch = "${patches-src}/${majorMinor}/sched/0001-bore-cachy.patch";
        }
      ];
      structuredExtraConfig = with lib.kernel; {
        ASUS_ALLY_HID = module;
        ASUS_ARMOURY = module;
      };
      extraMakeFlags = ["-j24"];
      extraMeta = {
        branch = majorMinor;
      };
    }
  )
