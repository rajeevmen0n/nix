{ pkgs, ... }:
{
  vim.lazy.plugins = {
    "catppuccin-nvim" = {
      package = pkgs.vimPlugins.catppuccin-nvim;
      setupModule = "catppuccin";
      setupOpts = {
        flavour = "mocha";
        transparent_background = true;
        float = {
          solid = false;
          transparent = true;
        };
      };
      after = ''
        vim.cmd("colorscheme catppuccin")
      '';
    };
  };
}
