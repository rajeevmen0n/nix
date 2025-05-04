{ lib, ... }:
{
  imports = [
    ./languages/default.nix
    ./languages/nix.nix
  ];

  vim = {

    lsp.lspconfig = {
      enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "gR";
        action = "FzfLua lsp_references";
        desc = "Show LSP references";
      }
      {
        mode = "n";
        key = "gD";
        action = "vim.lsp.buf.declaration";
        lua = true;
        desc = "Go to declaration";
      }
      {
        mode = "n";
        key = "gd";
        action = "FzfLua lsp_definitions";
        desc = "Show LSP definitions";
      }
      {
        mode = "n";
        key = "gi";
        action = "FzfLua lsp_implementations";
        desc = "Show LSP implementations";
      }
      {
        mode = "n";
        key = "gt";
        action = "FzfLua lsp_typedefs";
        desc = "Show LSP type definitions";
      }
      {
        mode = [ "n" "v" ];
        key = "<leader>ca";
        action = "vim.lsp.buf.code_action";
        lua = true;
        desc = "See available code actions";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "vim.lsp.buf.rename";
        lua = true;
        desc = "Smart rename";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = "FzfLua diagnostics_document";
        desc = "Show buffer diagnostics";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "vim.diagnostic.open_float";
        lua = true;
        desc = "Show line diagnostics";
      }
      {
        mode = "n";
        key = "K";
        action = "vim.lsp.buf.hover";
        lua = true;
        desc = "Show documentation for what is under cursor";
      }
      {
        mode = "n";
        key = "<leader>rs";
        action = "<cmd>LspRestart<CR>";
        desc = "Restart LSP";
      }
    ];

    diagnostics.config.signs = {
      signs = {
        text = {
          "vim.diagnostic.severity.ERROR" = " ";
          "vim.diagnostic.severity.WARN" = " ";
          "vim.diagnostic.severity.HINT" = "󰠠 ";
          "vim.diagnostic.severity.INFO" = " ";
        };
      };
    };
  };
}
