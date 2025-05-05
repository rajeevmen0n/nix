{
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../nixos/amdgpu.nix
    ../../nixos/audio.nix
    ../../nixos/basic.nix
    ../../nixos/gaming.nix
    ../../nixos/gnome.nix
    ../../nixos/hyprland.nix
    ../../nixos/ios.nix
    ../../nixos/media.nix
    ../../nixos/nvidia.nix
    ../../nixos/secureboot.nix
    ../../nixos/users.nix
  ];

  # Known issue, kernel freeze when type c port is used
  boot.blacklistedKernelModules = ["ucsi_acpi"];

  # WiFi card doesn't work on the stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Asus linux
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.supergfxd.enable = true;

  system.stateVersion = "24.11";
}
