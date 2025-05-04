{ lib, ... }:
{
  vim = {
    languages.nix = {
      enable = true;
      format.enable = true;
      lsp.enable = true;
      treesitter.enable = true;
    };
    autocmds = [
      {
        enable = true;
        event = [ "FileType" ];
        callback = lib.mkLuaInline ''
          function()
            vim.bo.tabstop = 2
            vim.bo.shiftwidth = 2
          end
        '';
        pattern = [ "nix" ];
      }
    ];
  };
}