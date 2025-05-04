{ pkgs, ... }:
{
  vim.extraPlugins = with pkgs.vimPlugins; {
    scope = {
      package = scope-nvim;
      setup = ''
        vim.opt.sessionoptions = {
            "buffers",
            "tabpages",
            "globals",
        }
        require("scope").setup({})
      '';
    };
  };
}