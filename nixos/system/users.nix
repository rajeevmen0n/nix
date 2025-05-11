{ config, pkgs, ... }:

let
  users = import ../../config/users.nix;

  # Filtering function to check if groups exist
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

in
{
  programs.zsh.enable = true;
  users.users.${users.default.username} = {
    isNormalUser = true;
    description = users.default.name;
    shell = pkgs.zsh;
    extraGroups =
      [ "wheel" ]
      ++ ifGroupsExist [ "networkmanager" ];
  };
}