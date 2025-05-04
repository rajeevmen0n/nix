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
      css
      csv
      diff
      dockerfile
      go
      html
      json
      lua
      make
      ninja
      nix
      python
      regex
      rust
      ssh_config
      tmux
      vim
      toml
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