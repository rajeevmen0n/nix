{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../nixos/audio.nix
    ../../nixos/basic.nix
    ../../nixos/gaming.nix
    ../../nixos/gnome.nix
    ../../nixos/ios.nix
    ../../nixos/nvidia.nix
    ../../nixos/users.nix
  ];

  # Known issue, kernel freeze when type c port is used
  boot.blacklistedKernelModules = [ "ucsi_acpi" ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable compression on partitions
  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/mnt/files".options = [ "compress=zstd" ];

  # Asus linux
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.supergfxd.enable = true;

  system.stateVersion = "24.11";
}