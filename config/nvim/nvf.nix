{
  imports = [
    ./core/keymaps.nix
    ./core/options.nix
    ./plugins/default.nix
    ./plugins/colorscheme.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
  };
}