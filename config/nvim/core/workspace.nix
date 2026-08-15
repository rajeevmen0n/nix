{ pkgs, ... }:
{
  vim = {
    extraPackages = with pkgs; [
      fd
      ripgrep
    ];

    additionalRuntimePaths = [
      (pkgs.runCommand "nvim-workspace" { } ''
        mkdir -p $out/lua/rajeev/core $out/lua
        cp ${./workspace.lua} $out/lua/rajeev/core/workspace.lua
        ln -s $out/lua/rajeev/core/workspace.lua $out/lua/workspace.lua
      '')
    ];

    luaConfigRC.workspace = ''
      require("rajeev.core.workspace").setup()
    '';
  };
}
