{pkgs, ...}: {
  # Enable systemd-boot bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Set time zone.
  time.timeZone = "America/Los_Angeles";

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic garbage collection
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Basic tools
  environment.systemPackages = with pkgs; [
    git
    p7zip
    tree
    unzip
    tree
    vim
    wget
  ];

  # Add ZSH to /etc/shells
  environment.shells = with pkgs; [zsh];
}
