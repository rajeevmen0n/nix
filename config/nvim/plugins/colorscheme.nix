{ pkgs, ... }:
{
  vim.lazy.plugins = {
    "catppuccin-nvim" = {
      package = pkgs.vimPlugins.catppuccin-nvim;
      setupModule = "catppuccin";
      setupOpts = {
        transparent_background = true;
      };
      after = ''
        vim.cmd("colorscheme catppuccin-mocha")
      '';
    };
  };
}