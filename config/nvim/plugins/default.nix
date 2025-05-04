{ pkgs, ... }:
{
  vim.lazy.plugins = {
    "vim-tmux-navigator" = {
      package = pkgs.vimPlugins.vim-tmux-navigator;
    };
    "plenary.nvim" = {
      package = pkgs.vimPlugins.plenary-nvim;
    };
    "smartyank.nvim" = {
      package = pkgs.vimPlugins.smartyank-nvim;
    };
  };
}