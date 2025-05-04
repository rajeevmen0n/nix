{
  imports = [
    ./core/keymaps.nix
    ./core/options.nix

    ./plugins/auto-session.nix
    ./plugins/colorscheme.nix
    ./plugins/default.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
  };
}