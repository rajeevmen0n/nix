{ pkgs, ... }:
{
  vim.treesitter = {
    enable = true;

    highlight.enable = true;
    indent.enable = true;
    autotagHtml = true;

    grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      c
      cmake
      cpp
      csv
      diff
      dockerfile
      go
      json
      lua
      make
      ninja
      python
      regex
      ssh_config
      tmux
      vim
      xml
      yaml
    ];

    mappings.incrementalSelection = {
      init = "<C-space>";
      incrementByNode = "<C-space>";
      decrementByNode = "<bs>";
      incrementByScope = null;
    };
  };
}