{pkgs, ...}: {
  # Load AMD GPU driver for Xorg and Wayland
  services.xserver.videoDrivers = ["amdgpu"];

  # AMD Free-sync
  services.xserver.deviceSection = ''
    Option "TearFree" "True"
    Option "VariableRefresh" "True"
    Option "AsyncFlipSecondaries" "true"
  '';

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];
}