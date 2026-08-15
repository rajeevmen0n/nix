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

      # Shader
      custom-shader = [
        "bloom.glsl"
        "cursor_blaze_no_trail.glsl"
        "cursor_smear.glsl"
      ];
    };
  };

  xdg.configFile = {
    "ghostty/shaders".source = ../../config/ghostty/shaders;
    "ghostty/bloom.glsl".source = ../../config/ghostty/shaders/bloom.glsl;
    "ghostty/cursor_blaze_no_trail.glsl".source = ../../config/ghostty/shaders/cursor_blaze_no_trail.glsl;
    "ghostty/cursor_smear.glsl".source = ../../config/ghostty/shaders/cursor_smear.glsl;
  };
}
