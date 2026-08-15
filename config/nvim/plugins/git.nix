{
  vim = {
    git = {
      enable = true;

      gitsigns = {
        enable = true;
        mappings = {
          # Navigation
          nextHunk = "]h";
          previousHunk = "[h";

          # Actions
          stageHunk = "<leader>hs";
          resetHunk = "<leader>hr";
          undoStageHunk = "<leader>hu";
          previewHunk = "<leader>hp";

          stageBuffer = "<leader>hS";
          resetBuffer = "<leader>hR";

          blameLine = "<leader>hb";
          toggleBlame = "<leader>hB";

          diffThis = "<leader>hd";
          diffProject = "<leader>hD";
        };
      };
    };

    keymaps = [
      {
        mode = "v";
        key = "<leader>hs";
        action = ''
          function()
            require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end
        '';
        lua = true;
        desc = "Stage hunk";
      }
      {
        mode = "v";
        key = "<leader>hr";
        action = ''
          function()
            require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end
        '';
        lua = true;
        desc = "Reset hunk";
      }
      {
        mode = [ "o" "x" ];
        key = "ih";
        action = ":<C-U>Gitsigns select_hunk<CR>";
        desc = "Gitsigns select hunk";
      }
    ];
  };
}
