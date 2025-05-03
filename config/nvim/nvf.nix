{ pkgs, lib, ... }:
{
  config.vim = {
    viAlias = true;
    vimAlias = true;
    lazy.plugins = {
      "vim-tmux-navigator" = {
        package = pkgs.vimPlugins.vim-tmux-navigator;
      };
    };
  };
}