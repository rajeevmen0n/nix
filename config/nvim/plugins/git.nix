{
  vim.git = {
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
}
