{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.14.8";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
    hash = "sha256-YrEuzTB1o1frMgk1ZX3oTgFVKANxfa04P6fMOqSqKQU=";
  };

  patchesSrc = fetchFromGitHub {
    owner = "flukejones";
    repo = "cachyos-kernel-patches";
    rev = "8d39b9876bd6ed3353b3089591c82cd8549b6fc1";
    hash = "sha256-pM8Dtpna4publpvKVUy7vACF3JwhMjMQBZyKnPSV/Wk=";
  };
in
  buildLinux (
    args
    // {
      inherit version;
      pname = "linux-rog";
      modDirVersion = version;
      src = kernelSrc;
      kernelPatches = [
        {
          name = "amd-pstate";
          patch = "${patchesSrc}/${majorMinor}/0001-amd-pstate.patch";
        }
        {
          name = "amd-tlb-broadcast";
          patch = "${patchesSrc}/${majorMinor}/0002-amd-tlb-broadcast.patch";
        }
        {
          name = "asus";
          patch = "${patchesSrc}/${majorMinor}/0003-asus.patch";
        }
        {
          name = "bbr3";
          patch = "${patchesSrc}/${majorMinor}/0004-bbr3.patch";
        }
        {
          name = "cachy";
          patch = "${patchesSrc}/${majorMinor}/0005-cachy.patch";
        }
        {
          name = "crypto";
          patch = "${patchesSrc}/${majorMinor}/0006-crypto.patch";
        }
        {
          name = "fixes";
          patch = "${patchesSrc}/${majorMinor}/0007-fixes.patch";
        }
        {
          name = "t2";
          patch = "${patchesSrc}/${majorMinor}/0008-t2.patch";
        }
        {
          name = "zstd";
          patch = "${patchesSrc}/${majorMinor}/0009-zstd.patch";
        }
        {
          name = "zotac-zone";
          patch = "${patchesSrc}/${majorMinor}/0010-zotac-zone.patch";
        }
      ];
      structuredExtraConfig = with lib.kernel; {
        ASUS_ALLY_HID = module;
        ASUS_ARMOURY = module;
      };
      extraMakeFlags = ["-j32"];
      extraMeta = {
        branch = majorMinor;
      };
    }
  )
