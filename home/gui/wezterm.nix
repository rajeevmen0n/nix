{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile(../../config/wezterm.lua);
  };
}