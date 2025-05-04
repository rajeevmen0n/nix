{
  pkgs,
  lib,
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
    ../../nixos/ios.nix
    ../../nixos/media.nix
    ../../nixos/nvidia.nix
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

  # Enable compression on partitions
  fileSystems."/".options = ["compress=zstd"];
  fileSystems."/mnt/files".options = ["compress=zstd"];

  # Asus linux
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.supergfxd.enable = true;

  # Disable gnome-remote-desktop, because it prevents nvidia GPU from sleeping.
  systemd.services.gnome-remote-desktop.wantedBy = lib.mkForce [];

  environment.sessionVariables = {
    # First the iGPU, then the dGPU
    KWIN_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    COSMIC_RENDER_DEVICE = "/dev/dri/renderD129";
  };

  system.stateVersion = "24.11";
}
