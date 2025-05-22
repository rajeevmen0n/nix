{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  version = "6.14.5";
  major = lib.versions.major version;
  majorMinor = lib.versions.majorMinor version;

  kernelSrc = fetchurl {
    url = "mirror://kernel/linux/kernel/v${major}.x/linux-${version}.tar.xz";
    hash = "sha256-KCB+xSu+qjUHAQrv+UT0QvfZ8isoa3nK9F7G3xsk9Ak=";
  };

  patchesSrc = fetchFromGitHub {
    owner = "flukejones";
    repo = "cachyos-kernel-patches";
    rev = "a01af6a9d02d4e274cdea273b63036467ca730be";
    hash = "sha256-Noaxr1ncE3hV9bxgleERSLXMG3ug5SBlZK3eQOQP9hE=";
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
          name = "cachy-os-patches";
          patch = "${patchesSrc}/${majorMinor}/all/0001-cachyos-base-all.patch";
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
