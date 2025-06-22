{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.15.3";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
    hash = "sha256-ErUMiZJUONnNc4WgyvycQz5lYqxd8AohiJ/On1SNZbA=";
  };

  patchesSrc = fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    rev = "1fc243888f62589785f2a9502445aa6ea2b3188f";
    hash = "sha256-Ug9ZzTV5ivMFgh4KL6QHgOCkrpwAHmUllfCDQXQzGeM=";
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
          name = "amd-pstate";
          patch = "${patchesSrc}/${majorMinor}/0001-amd-pstate.patch";
        }
        {
          name = "asus";
          patch = "${patchesSrc}/${majorMinor}/0002-asus.patch";
        }
        {
          name = "async-shutdown";
          patch = "${patchesSrc}/${majorMinor}/0003-async-shutdown.patch";
        }
        {
          name = "bbr3";
          patch = "${patchesSrc}/${majorMinor}/0004-bbr3.patch";
        }
        {
          name = "zstd";
          patch = "${patchesSrc}/${majorMinor}/0005-block.patch";
        }
        {
          name = "cachy";
          patch = "${patchesSrc}/${majorMinor}/0006-cachy.patch";
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
          name = "bore";
          patch = "${patchesSrc}/${majorMinor}/sched/0001-bore-cachy.patch";
        }
      ];
      structuredExtraConfig = with lib.kernel; {
        ASUS_ALLY_HID = module;
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
