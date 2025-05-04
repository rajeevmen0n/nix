{
  imports = [
    ./core/keymaps.nix
    ./core/options.nix
    ./plugins/default.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
  };
}