{
  programs.plasma = {
    enable = true;

    workspace = {
      clickItemTo = "select";
      
      # Cursor theme
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };

      # Fluent dark theme
      iconTheme = "breeze-dark";
      splashScreen.theme = "org.kde.breeze.desktop";
      theme = "Fluent-round-dark"; 
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__Fluent-round-dark";
      };
    };
  };
}