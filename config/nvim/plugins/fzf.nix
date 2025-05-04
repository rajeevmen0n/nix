{
  vim = {
    fzf-lua.enable = true;
    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Fzf files <CR>";
        desc = "FzfLua files";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Fzf oldfiles<CR>";
        desc = "FzfLua Recent Files";
      }
      {
        mode = "n";
        key = "<leader>fc";
        action = "<cmd>Fzf grep_curbuf<CR>";
        desc = "FzfLua find in file";
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<cmd>Fzf live_grep<CR>";
        desc = "FzfLua live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Fzf buffers<CR>";
        desc = "FzfLua buffers";
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = "<cmd>Fzf keymaps<CR>";
        desc = "FzfLua keymaps";
      }
    ];
  };
}