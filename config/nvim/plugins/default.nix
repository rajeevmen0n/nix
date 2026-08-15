{ pkgs, ... }:
{
  vim.lazy.plugins = {
    "vim-tmux-navigator" = {
      package = pkgs.vimPlugins.vim-tmux-navigator;
    };
    "smartyank.nvim" = {
      package = pkgs.vimPlugins.smartyank-nvim;
    };
  };
}