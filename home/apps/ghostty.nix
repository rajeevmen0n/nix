{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Env
      term = "xterm-256color";

      # Appearance
      window-padding-x = 9;
      window-padding-y = 9;
      mouse-hide-while-typing = true;

      # Cursor settings
      cursor-style = "bar";
      cursor-style-blink = true;

      # Font
      font-family = "JetBrains Mono";
      font-size = 12;

      # Theme
      theme = "Catppuccin Mocha";
      background = "#000000";
      background-opacity = 0.8;
      background-blur = true;
      background-blur-radius = 20;
    };
  };
}
