{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFormat = "yaml";
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      sshKeyPaths = [ ]; # Use age keys only, do not use SSH keys
    };
  };

  home.packages = [
    pkgs.sops
    pkgs.age
  ];
}
