{ pkgs, ... }:
{
  vim = {
    lazy.plugins = {
        "auto-session" = {
        package = pkgs.vimPlugins.auto-session;
        setupModule = "auto-session";
        setupOpts = {
            auto_save = true;
            auto_restore = true;
            suppressed_dirs = [ "~/" "~/Downloads" "~/Documents" "~/Desktop/" "~/tmp" "/tmp" ];
        };
        };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>wr";
        action = "<cmd>SessionRestore<CR>";
        desc = "Restore session for cwd";
      }
      {
        mode = "n";
        key = "<leader>ws";
        action = "<cmd>SessionSave<CR>";
        desc = "Save session for auto session root dir";
      }
    ];
  };
}