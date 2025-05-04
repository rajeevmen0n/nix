{
  vim = {
    mini = {
      ai.enable = true;
      bufremove.enable = true;
      comment.enable = true;
      files.enable = true;
      icons.enable = true;
      indentscope.enable = true;
      misc.enable = true;
      operators.enable = true;
      pairs.enable = true;
      starter.enable = true;
      statusline.enable = true;
      surround.enable = true;
      tabline.enable = true;

      hipatterns = {
        enable = true;
        setupOpts = {
          highlighters = {
            fixme = {
              pattern = "%f[%w]()FIXME()%f[%W]";
              group = "MiniHipatternsFixme";
            };
            hack = {
              pattern = "%f[%w]()HACK()%f[%W]";
              group = "MiniHipatternsHack";
            };
            todo = {
              pattern = "%f[%w]()TODO()%f[%W]";
              group = "MiniHipatternsTodo";
            };
            note = {
              pattern = "%f[%w]()NOTE()%f[%W]";
              group = "MiniHipatternsNote";
            };
          };
        };
      };
    };

    keymaps = [
      # Mini bufremove
      {
        mode = "n";
        key = "<leader>bx";
        action = "MiniBufremove.delete";
        lua = true;
        desc = "Close buffer";
      }

      # Mini files
      {
        mode = "n";
        key = "<leader>e";
        action = ''
          function(...)
            if not MiniFiles.close() then MiniFiles.open(...) end
          end
        '';
        lua = true;
        desc = "Close buffer";
      }

      # Mini misc (maximize/minimize)
      {
        mode = "n";
        key = "<leader>sm";
        action = "MiniMisc.zoom";
        lua = true;
        desc = "Maximize/minimize";
      }
    ];
  };
}