{
  imports = [
    ./core/keymaps.nix
    ./core/options.nix

    ./plugins/auto-session.nix
    ./plugins/colorscheme.nix
    ./plugins/default.nix
    ./plugins/fzf.nix
    ./plugins/git.nix
    ./plugins/nvim-cmp.nix
    ./plugins/scope-nvim.nix
    ./plugins/treesitter.nix
    ./plugins/trouble.nix
  ];

  vim = {
    viAlias = true;
    vimAlias = true;
  };
}
