{
  config,
  lib,
  pkgs,
  ...
}: let
  hosts = import ../../config/hosts.nix;
in {
  imports = [
    ./extras/gpu-env.nix
    ./hardware-configuration.nix

    ../../nixos/basic.nix
    ../../nixos/gaming.nix

    ../../nixos/desktop/hyprland.nix
    ../../nixos/desktop/plasma.nix
    ../../nixos/desktop/greetd.nix

    ../../nixos/hardware/amdgpu.nix
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/nvidia.nix

    ../../nixos/system/ios.nix
    ../../nixos/system/plymouth.nix
    ../../nixos/system/secureboot.nix
    ../../nixos/system/users.nix
  ];

  # Hostname
  networking.hostName = hosts.ga605wi.hostname;

  # Known issue, kernel freeze when type c port is used
  boot.blacklistedKernelModules = ["ucsi_acpi"];

  # WiFi card doesn't work on the stable kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./extras/rog-kernel.nix {});

  # Use custom nvidia version
  hardware.nvidia.package = lib.mkForce(
    config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.153.02";
      sha256_64bit = "sha256-FIiG5PaVdvqPpnFA5uXdblH5Cy7HSmXxp6czTfpd4bY=";
      openSha256 = "sha256-2DpY3rgQjYFuPfTY4U/5TcrvNqsWWnsOSX0f2TfVgTs=";
      settingsSha256 = "sha256-5m6caud68Owy4WNqxlIQPXgEmbTe4kZV2vZyTWHWe+M=";
      persistencedSha256 = lib.fakeSha256;
    }
  );

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Asus linux
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
  };

  system.stateVersion = "25.05";
}
