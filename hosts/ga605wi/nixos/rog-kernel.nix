{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.15.6";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
    hash = "sha256-K7WGyVQnfQcMj99tcnX6qTtIB9m/M1O0kdgUnMoCtPw=";
  };

  patchesSrc = fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    rev = "f435ec707555a2d044e8e1a53dac8df89610e06f";
    hash = "sha256-OWhXk361D1SxKF2Sd2DuiNI6YhiWax0AZEjxlsJ2Q3s=";
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
