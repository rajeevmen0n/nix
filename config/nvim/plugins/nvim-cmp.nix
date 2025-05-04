{ lib, ... }:
{
  vim.snippets.luasnip = {
    enable = true;
    loaders = "require('luasnip.loaders.from_vscode').lazy_load()";
  };

  vim.lsp.lspkind.enable = true;

  vim.autocomplete.nvim-cmp = {
    enable = true;

    sourcePlugins = [
      "cmp-buffer"
      "cmp-path"
      "luasnip"
      "cmp-luasnip"
      "friendly-snippets"
      "lspkind-nvim"
    ];

    sources = {
      nvim_lsp = "[LSP]";
      luasnip = "[Snippet]";
      buffer = "[Buffer]";
      path = "[Path]";
    };

    setupOpts.completion.completeopt = "menu,menuone,noinsert";

    mappings = {
      previous = "<C-k>";
      next = "<C-j>";
      scrollDocsDown = "<C-b>";
      scrollDocsUp = "<C-f>";
      complete = "<C-Space>";
      close = "<C-e>";
      confirm = "<CR>";
    };

    format = lib.mkLuaInline ''
      require("lspkind").cmp_format({
        maxwidth = 50,
        ellipsis_char = "...",
      })
    '';
  };
}
