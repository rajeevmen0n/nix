{ pkgs, ... }:
{
  vim.luaConfigRC.startupTime = ''
    vim.g._startuptime_start = (vim.uv and vim.uv.hrtime()) or (vim.loop and vim.loop.hrtime()) or 0
  '';

  vim.lazy.plugins = {
    "snacks.nvim" = {
      package = pkgs.vimPlugins.snacks-nvim;
      lazy = false;
      priority = 1000;
      setupModule = "snacks";
      beforeSetup = ''
        package.preload["lazy.stats"] = function()
          return {
            stats = function()
              local now = (vim.uv and vim.uv.hrtime()) or (vim.loop and vim.loop.hrtime()) or 0
              local ms = 0
              if vim.g._startuptime_start and vim.g._startuptime_start > 0 then
                ms = (now - vim.g._startuptime_start) / 1e6
              end
              return {
                count = #vim.tbl_keys(package.loaded),
                loaded = #vim.tbl_keys(package.loaded),
                startuptime = ms,
              }
            end,
          }
        end
      '';
      setupOpts = {
        bigfile = {
          enabled = true;
        };
        dashboard = {
          sections = [
            { section = "header"; }
            {
              icon = " ";
              title = "Keymaps";
              section = "keys";
              indent = 2;
              padding = 1;
            }
            {
              icon = " ";
              title = "Recent Files";
              section = "recent_files";
              indent = 2;
              padding = 1;
            }
            {
              icon = " ";
              title = "Projects";
              section = "projects";
              indent = 2;
              padding = 1;
            }
            { section = "startup"; }
          ];
        };
        input = {
          enabled = true;
        };
        notifier = {
          enabled = true;
        };
        quickfile = {
          enabled = true;
        };
      };
    };
  };
}
