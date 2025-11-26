{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.17.9";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
    hash = "sha256-bQiAO5U8UJ30jUTTKB7TklJDIdi7NT6yHAVVeQyPjgY=";
  };

  patchesSrc = fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    rev = "b8f46aff318e08b1d088b8d6f8f46c7f463a78cc";
    hash = "sha256-WyNbpFLNUMhOgezAsOpjRovuDz2LcyU2gwrN99xG5dg=";
  };
in
  buildLinux (
    args
    // {
      inherit version;
      pname = "linux-rog-cachyos";
      modDirVersion = version;
      src = kernelSrc;
      kernelPatches = [
        {
          name = "base-patch";
          patch = "${patchesSrc}/${majorMinor}/all/0001-cachyos-base-all.patch";
        }
        {
          name = "bore";
          patch = "${patchesSrc}/${majorMinor}/sched/0001-bore-cachy.patch";
        }
      ];
      structuredExtraConfig = with lib.kernel; {
        ASUS_ARMOURY = module;
        AMD_PRIVATE_COLOR = yes;
        CACHY=yes;
        SCHED_BORE=yes;
      };
      extraMakeFlags = ["-j32"];
      extraMeta = {
        branch = majorMinor;
      };
    }
  )
