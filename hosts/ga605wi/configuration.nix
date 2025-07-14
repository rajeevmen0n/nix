{
  config,
  lib,
  pkgs,
  ...
}: let
  hosts = import ../../config/hosts.nix;
in {
  imports = [
    ./hardware-configuration.nix

    ./nixos/dsdt/dsdt.nix
    ./nixos/gpu-env.nix
    ./nixos/hypr-monitor-toggle.nix
    ./nixos/lid-handler.nix

    ../../nixos/basic.nix
    ../../nixos/gaming.nix

    ../../nixos/desktop/hyprland.nix
    ../../nixos/desktop/plasma.nix
    ../../nixos/desktop/greetd.nix

    ../../nixos/hardware/amdgpu.nix
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/nvidia.nix

    ../../nixos/system/cachix.nix
    ../../nixos/system/hdr.nix
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
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./nixos/rog-kernel.nix {});

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Use custom nvidia version
  hardware.nvidia.package = lib.mkForce(
    config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.169";
      sha256_64bit = "sha256-XzKoR3lcxcP5gPeRiausBw2RSB1702AcAsKCndOHN2U=";
      openSha256 = "sha256-oqY/O5fda+CVCXGVW2bX7LOa8jHJOQPO6mZ/EyleWCU=";
      settingsSha256 = "sha256-0E3UnpMukGMWcX8td6dqmpakaVbj4OhhKXgmqz77XZc=";
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
